import random
import cocotb
from cocotb.triggers import Timer

WIDTH = 32
MASK = (1 << WIDTH) - 1

class lc_alu_op_T:
    ALU_ADD  = 0b0000
    ALU_SUB  = 0b1000
    ALU_SLL  = 0b0001
    ALU_SLT  = 0b0010
    ALU_SLTU = 0b0011
    ALU_XOR  = 0b0100
    ALU_SRL  = 0b0101
    ALU_SRA  = 0b1101
    ALU_OR   = 0b0110
    ALU_AND  = 0b0111

VALID_OPS = [
    lc_alu_op_T.ALU_ADD,
    lc_alu_op_T.ALU_SUB,
    lc_alu_op_T.ALU_SLL,
    lc_alu_op_T.ALU_SLT,
    lc_alu_op_T.ALU_SLTU,
    lc_alu_op_T.ALU_XOR,
    lc_alu_op_T.ALU_SRL,
    lc_alu_op_T.ALU_SRA,
    lc_alu_op_T.ALU_OR,
    lc_alu_op_T.ALU_AND,
]

"encodings of the 4-bit alu_op that are not used, must return 0"
UNUSED_OPS = [op for op in range(16) if op not in VALID_OPS]

SHIFT_OPS = [lc_alu_op_T.ALU_SLL, lc_alu_op_T.ALU_SRL, lc_alu_op_T.ALU_SRA]

CORNERS = [
    0x00000000,  # 0
    0x00000001,  # 1
    0xFFFFFFFF,  # -1
    0xFFFFFFFE,  # -2
    0x7FFFFFFF,  # max signed
    0x7FFFFFFE,
    0x80000000,  # min signed
    0x80000001,
    0x0000001F,  # max shift amount
    0x00000020,  # shift amount 32 -> must shift by 0
    0x0000041F,  # SRAI immediate: imm[10] set, shamt = 31
    0xAAAAAAAA,
    0x55555555,
]

def op_name(op):
    for name, value in vars(lc_alu_op_T).items():
        if name.startswith("ALU_") and value == op:
            return name
    return f"UNUSED_{op:04b}"

def to_signed(value):
    value &= MASK
    if value & (1 << (WIDTH - 1)):
        value -= 1 << WIDTH
    return value

"reference model"
def reference_alu(op, a, b):
    match op:
        case lc_alu_op_T.ALU_ADD:
            result = a + b
        case lc_alu_op_T.ALU_SUB:
            result = a - b
        case lc_alu_op_T.ALU_SLL:
            result = a << (b & 0x1F)
        case lc_alu_op_T.ALU_SLT:
            result = int(to_signed(a) < to_signed(b))
        case lc_alu_op_T.ALU_SLTU:
            result = int(a < b)
        case lc_alu_op_T.ALU_XOR:
            result = a ^ b
        case lc_alu_op_T.ALU_SRL:
            result = a >> (b & 0x1F)
        case lc_alu_op_T.ALU_SRA:
            result = to_signed(a) >> (b & 0x1F)   # python >> on negative ints is arithmetic
        case lc_alu_op_T.ALU_OR:
            result = a | b
        case lc_alu_op_T.ALU_AND:
            result = a & b
        case _:
            result = 0

    return result & MASK

def reference_flags(a, b):
    return {
        "eq_o":  int(a == b),
        "lt_o":  int(to_signed(a) < to_signed(b)),
        "ltu_o": int(a < b),
    }

async def check_alu(dut, op, a, b):
    a &= MASK
    b &= MASK

    dut.op_a_i.value = a
    dut.op_b_i.value = b
    dut.alu_op_i.value = op
    await Timer(1, unit="ns")

    msg = f"{op_name(op)} a=0x{a:08x} b=0x{b:08x}"

    expected = reference_alu(op, a, b)
    actual = int(dut.alu_result_o.value)
    assert actual == expected, (
        f"{msg}: alu_result_o expected 0x{expected:08x}, got 0x{actual:08x}"
    )

    for signal, expected_value in reference_flags(a, b).items():
        actual = int(getattr(dut, signal).value)
        assert actual == expected_value, (
            f"{msg}: {signal} expected {expected_value}, got {actual}"
        )

@cocotb.test()
async def corner_test(dut):
    "every encoding (valid and unused) with every pair of corner values"
    for op in range(16):
        for a in CORNERS:
            for b in CORNERS:
                await check_alu(dut, op, a, b)

@cocotb.test()
async def shift_test(dut):
    "all shift amounts, with and without upper bits set in op_b"
    values = [
        0x00000001,
        0x80000000,
        0x80000001,
        0x7FFFFFFF,
        0xFFFFFFFF,
        0xAAAAAAAA,
        0x55555555,
    ] + [random.getrandbits(WIDTH) for _ in range(8)]

    for op in SHIFT_OPS:
        for shift in range(32):
            for a in values:
                await check_alu(dut, op, a, shift)                          
                await check_alu(dut, op, a, 0x400 | shift)                  
                await check_alu(dut, op, a, 0xFFFFFFE0 | shift)             
                await check_alu(dut, op, a, (random.getrandbits(27) << 5) | shift)

@cocotb.test()
async def unused_op_test(dut):
    "unused alu_op encodings return 0"
    for op in UNUSED_OPS:
        for _ in range(1000):
            await check_alu(dut, op, random.getrandbits(WIDTH), random.getrandbits(WIDTH))

@cocotb.test()
async def random_test(dut):
    "random vectors against the reference model"
    for _ in range(100000):
        op = random.choice(VALID_OPS)
        await check_alu(dut, op, random.getrandbits(WIDTH), random.getrandbits(WIDTH))
