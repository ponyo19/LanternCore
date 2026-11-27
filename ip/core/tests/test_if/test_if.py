import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge, ReadOnly

ROM_SIZE = 256
random.seed(42)

rom = [random.getrandbits(32) for _ in range(ROM_SIZE)]
def generate_rom():
    with open("test_rom.hex", "w") as f:
        for instr in rom:
            f.write(f"{instr:08x}\n")


async def reset(dut):
    dut.rst_ni.value = 0

    await RisingEdge(dut.clk_i)
    await ReadOnly()
    assert dut.req.value == 0, "When reset, req signal should be LOW"
    assert dut.req_payload.value == 0, "When reset, the addr should be 0"
    assert dut.gnt.value == 0, "When reset, gnt signal should be LOW"
    assert dut.rvalid.value == 0, "When reset, rvalid signal should be LOW"

    await FallingEdge(dut.clk_i)
    dut.rst_ni.value = 1

    await RisingEdge(dut.clk_i)


async def re_en_pulse(dut):
    dut.re_i.value = 1
    await ReadOnly()
    assert dut.req.value == 1, "req signal should remain HIGH when re_i is HIGH"
    await RisingEdge(dut.clk_i)
    await FallingEdge(dut.clk_i)
    dut.re_i.value = 0


async def control_monitor(dut):
    # IDLE
    await RisingEdge(dut.re_i)
    await ReadOnly()

    assert dut.req.value == 1, "The req signal should go HIGH"
    assert dut.gnt.value == 1, "gnt should still be HIGH"

    await RisingEdge(dut.clk_i)
    await ReadOnly()

    # PROCESS
    assert dut.req.value == 0, "The req signal should be LOW at transaction phase"
    assert dut.gnt.value == 0, "The gnt signal should be LOW at transaction phase"
    assert dut.rvalid.value == 1, "ROM response should be ready"
    assert dut.done_o.value == 1, "done_o should be HIGH when instruction is ready"
    
    await RisingEdge(dut.clk_i)
    await ReadOnly()

    # IDLE
    assert dut.instr_o.value == 0, f"instr_o should be 0 at IDLE, but received {dut.instr_o.value}"
    assert dut.done_o.value == 0, "done_o should be HIGH for only one cycle"
    assert dut.err_o.value == 0, "err_o should be HIGH for only one cycle"


async def if_model(dut, rom, pc):
    index = pc // 4

    await RisingEdge(dut.rvalid)
    await ReadOnly()

    actual = int(dut.instr_o.value)
    assert dut.done_o.value == 1, "done_o should be HIGH when instruction is ready"

    if index >= ROM_SIZE:
        expect = 0
        assert dut.err_o.value == 1, "err should be HIGH when address is out of range"

    else:
        expect = rom[index]
        assert dut.err_o.value == 0, "err should be LOW when address valid"

    assert actual == expect, (
        f"Instruction mismatch:\n"
        f"Expect: {expect:08X}. Receive: {actual:08X}"
    )


@cocotb.test()
async def random_test(dut):
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())
    await reset(dut)

    dut.rom_en.value = 1
    
    for _ in range (300):
        await FallingEdge(dut.clk_i)
        pc = random.randrange(ROM_SIZE + 50) * 4
        dut.pc_i.value = pc 

        monitor = cocotb.start_soon(control_monitor(dut))
        if_monitor = cocotb.start_soon(if_model(dut, rom ,pc))

        await re_en_pulse(dut)
        await if_monitor
        await monitor


@cocotb.test()
async def reset_mid_stream(dut):

    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())
    dut.rom_en.value = 1

    # IDLE reset
    await reset(dut)

    # PROCESS reset
    await re_en_pulse(dut)
    await reset(dut)


@cocotb.test()
async def req_back_pressure(dut):
    pc = 10*4

    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())

    await reset(dut)

    dut.rom_en.value = 0
    dut.pc_i.value = pc

    await re_en_pulse(dut)

    for _ in range (30):
        await RisingEdge(dut.clk_i)
        assert dut.gnt.value == 0, "The gnt should not be allowed to go HIGH here"
        assert dut.req.value == 1, "req signal should remain HIGH until gnt is asserted"
        assert dut.req_payload.value == pc, "The address should remains stable until gnt is asserted"

    dut.rom_en.value = 1
    await ReadOnly()
    assert dut.gnt.value == 1, "gnt signal should go HIGH now"

    await RisingEdge(dut.clk_i)
    await ReadOnly()
    assert int(dut.instr_o.value) == int(rom[pc // 4]), (
        f"Instruction mismatch:\n"
        f"Expect: {rom[pc // 4]:08X}. Receive: {int(dut.instr_o.value):08X}"
    )

if __name__ == "__main__":
    generate_rom()
