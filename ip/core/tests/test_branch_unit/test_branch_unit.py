from pathlib import Path
import random
import cocotb 
from cocotb.triggers import Timer


async def branch_reference(dut, branch, jal, jalr,
                           branch_cond, eq, lt, ltu,
                           offset, rs1_data, pc_i):

    dut.branch_i.value = branch
    dut.jal_i.value = jal
    dut.jalr_i.value = jalr

    dut.branch_cond_i.value = branch_cond
    dut.eq_i.value = eq
    dut.lt_i.value = lt
    dut.ltu_i.value = ltu

    dut.offset_i.value = offset
    dut.rs1_data_i.value = rs1_data
    dut.pc_i.value = pc_i

    mask = (1 << len(dut.branch_pc_o)) - 1

    expected_pc = pc_i
    expected_sl = 0

    if jal:
        expected_pc = (pc_i + offset) & mask
        expected_sl = 1

    elif jalr:
        expected_pc = ((rs1_data + offset) & mask) & ~1
        expected_sl = 1

    elif branch:
        taken = (
            (branch_cond == 0b000 and eq) or
            (branch_cond == 0b001 and not eq) or
            (branch_cond == 0b100 and lt) or
            (branch_cond == 0b101 and not lt) or
            (branch_cond == 0b110 and ltu) or
            (branch_cond == 0b111 and not ltu)
        )

        if taken:
            expected_pc = (pc_i + offset) & mask
            expected_sl = 1

    await Timer(1, unit="ns")

    actual_pc = int(dut.branch_pc_o.value)
    actual_sl = int(dut.branch_sl_o.value)

    assert actual_pc == expected_pc, (
        f"Branch PC: Got {actual_pc:#010x}, "
        f"Expected {expected_pc:#010x}"
    )

    assert actual_sl == expected_sl, (
        f"Branch select: Got {actual_sl}, "
        f"Expected {expected_sl}"
    )

@cocotb.test()
async def test_branch_unit(dut):

    # Normal instructions
    for _ in range(10):
        await branch_reference(
            dut, branch=0, jal=0, jalr=0,
            branch_cond=0, eq=0, lt=0, ltu=0,
            offset=random.getrandbits(32),
            rs1_data=random.getrandbits(32),
            pc_i=random.getrandbits(32)
        )

    # JAL and JALR
    for _ in range(50):
        await branch_reference(
            dut, branch=0,
            jal=random.randint(0, 1),
            jalr=0,
            branch_cond=0, eq=0, lt=0, ltu=0,
            offset=random.getrandbits(32),
            rs1_data=random.getrandbits(32),
            pc_i=random.getrandbits(32)
        )

        await branch_reference(
            dut, branch=0, jal=0, jalr=1,
            branch_cond=0, eq=0, lt=0, ltu=0,
            offset=random.getrandbits(32),
            rs1_data=random.getrandbits(32),
            pc_i=random.getrandbits(32)
        )

    # Six branch conditions
    for cond in [0b000, 0b001, 0b100,
                 0b101, 0b110, 0b111]:

        for _ in range(20):
            await branch_reference(
                dut, branch=1, jal=0, jalr=0,
                branch_cond=cond,
                eq=random.randint(0, 1),
                lt=random.randint(0, 1),
                ltu=random.randint(0, 1),
                offset=random.getrandbits(32),
                rs1_data=random.getrandbits(32),
                pc_i=random.getrandbits(32)
            )


