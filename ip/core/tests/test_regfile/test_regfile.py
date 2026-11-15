import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

async def read_port(dut, re_rs1_en, re_rs2_en,
                    rs1_addr, rs2_addr, rs1_data, rs2_data):

    dut.re_rs1_i.value = re_rs1_en
    dut.re_rs2_i.value = re_rs2_en
    dut.rs1_addr_i.value = rs1_addr
    dut.rs2_addr_i.value = rs2_addr

    await Timer(1, unit="ns")

    actual_rs1 = int(dut.rs1_data_o.value)
    actual_rs2 = int(dut.rs2_data_o.value)

    expected_rs1 = rs1_data if (re_rs1_en and rs1_addr != 0) else 0
    expected_rs2 = rs2_data if (re_rs2_en and rs2_addr != 0) else 0
    
    assert actual_rs1 == expected_rs1, (
        f"RS1: Got {actual_rs1}, expected {expected_rs1}"
    )

    assert actual_rs2 == expected_rs2, (
        f"RS2: Got {actual_rs2}, expected {expected_rs2}"
    )

         
async def write_port(dut, waddr, wr_en, wdata, gpr):
    dut.wr_en_i.value = wr_en
    dut.wr_addr_i.value = waddr
    dut.wr_data_i.value = wdata

    before = gpr[waddr]

    await RisingEdge(dut.clk_i)

    dut.re_rs1_i.value = 1
    dut.rs1_addr_i.value = waddr

    await Timer(1, unit="ns")

    actual = int(dut.rs1_data_o.value)

    if wr_en:
        if waddr != 0:
            gpr[waddr] = wdata
            assert actual  == wdata, f"Write port should write {wdata} to gpir at {waddr} address, but wrote {actual}"
        else:
            assert actual == 0, f"Writing at address 0 is ignored"
    else:
        assert actual == before, f"No write occurs"
    
async def initialize_gpr(dut, gpr):
    for addr in range(1,32):    
        await write_port(dut, waddr=addr, wr_en=1, wdata=gpr[addr], gpr=gpr)

    dut.wr_en_i.value = 0
    


@cocotb.test()
async def read_test(dut):
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())
    gpr = [0] + [random.getrandbits(32) for _ in range(31)]
    await initialize_gpr(dut, gpr)

    for _ in range (50):
        re_rs1_en = random.randint(0,1)
        re_rs2_en = random.randint(0,1)
        rs1_addr = random.randint(0,31)
        rs2_addr = random.randint(0,31)
        rs1_data = gpr[rs1_addr]
        rs2_data = gpr[rs2_addr]
        await read_port(dut, re_rs1_en=re_rs1_en, re_rs2_en= re_rs2_en, 
                        rs1_addr=rs1_addr, rs2_addr=rs2_addr, 
                        rs1_data=rs1_data, rs2_data=rs2_data)

    for _ in range (10):
        await read_port(dut, re_rs1_en=1, re_rs2_en=1,
                        rs1_addr=0, rs2_addr=0, 
                        rs1_data=50, rs2_data=60)
        
@cocotb.test()
async def write_test(dut):
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())

    gpr = [0] + [random.getrandbits(32) for _ in range(31)]
    await initialize_gpr(dut, gpr)

    for _ in range(50):
        wr_en = random.randint(0,1)
        waddr = random.randint(0,31)
        wdata = random.getrandbits(32)
        await write_port(dut, waddr=waddr, wr_en=wr_en, wdata=wdata, gpr=gpr)


    




