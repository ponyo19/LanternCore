from pathlib import Path
import random
import cocotb
from cocotb.triggers import Timer
import re

ROOT = Path(__file__).resolve().parents[2]
DECODER_MD = ROOT/"docs"/"decoder.md"

class instr_opcode: 
    LUI    = 0b0110111
    AUIPC  = 0b0010111
    JAL    = 0b1101111
    JALR   = 0b1100111
    BRANCH = 0b1100011
    LOAD   = 0b0000011
    STORE  = 0b0100011
    IMM    = 0b0010011
    REG    = 0b0110011
    FENCE  = 0b0001111
    ECALL_EBREAK = 0b1110011

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

class lc_alu_op_a_sel:
    OPA_RS1     = 0b00
    OPA_PC      = 0b01
    OPA_ZERO    = 0b10

class lc_alu_op_b_sel:
    OPB_RS2     = 0b0
    OPB_IMM     = 0b1

class lc_mem_size_T:
    MEM_B       = 0b00
    MEM_H       = 0b01
    MEM_W       = 0b10

class lc_wb_sel_T:
    WB_ALU      = 0b00
    WB_MEM      = 0b01
    WB_PC4      = 0b10

SIGNALS = [
    "o_alu_op",
    "o_op_a_sel",
    "o_op_b_sel",
    "o_rd_we",
    "o_mem_re",
    "o_mem_we",
    "o_mem_size",
    "o_mem_unsigned",
    "o_branch",
    "o_wb_sel",
]

CONSTANTS = {
    # ALU
    "ALU_ADD":  lc_alu_op_T.ALU_ADD,
    "ALU_SUB":  lc_alu_op_T.ALU_SUB,
    "ALU_SLL":  lc_alu_op_T.ALU_SLL,
    "ALU_SLT":  lc_alu_op_T.ALU_SLT,
    "ALU_SLTU": lc_alu_op_T.ALU_SLTU,
    "ALU_XOR":  lc_alu_op_T.ALU_XOR,
    "ALU_SRL":  lc_alu_op_T.ALU_SRL,
    "ALU_SRA":  lc_alu_op_T.ALU_SRA,
    "ALU_OR":   lc_alu_op_T.ALU_OR,
    "ALU_AND":  lc_alu_op_T.ALU_AND,

    # Operand A
    "OPA_RS1":  lc_alu_op_a_sel.OPA_RS1,
    "OPA_PC":   lc_alu_op_a_sel.OPA_PC,
    "OPA_ZERO": lc_alu_op_a_sel.OPA_ZERO,

    # Operand B
    "OPB_RS2": lc_alu_op_b_sel.OPB_RS2,
    "OPB_IMM": lc_alu_op_b_sel.OPB_IMM,

    # Memory
    "MEM_B": lc_mem_size_T.MEM_B,
    "MEM_H": lc_mem_size_T.MEM_H,
    "MEM_W": lc_mem_size_T.MEM_W,

    # Writeback
    "WB_ALU": lc_wb_sel_T.WB_ALU,
    "WB_MEM": lc_wb_sel_T.WB_MEM,
    "WB_PC4": lc_wb_sel_T.WB_PC4,
}

"bitstring slice"
def bits(value, msb, lsb):
    width = msb - lsb + 1
    return (value >> lsb) & ((1 << width) - 1)

def sign_extend(imm, length):
    sign_bit = 1 <<(length-1)

    if sign_bit & imm:
        imm -= 1 << length

    return imm & 0xFFFFFFFF

"encoder generator"
def r_encoder(funct7, rs2, rs1, funct3, rd, opcode):
    return (
        (funct7 << 25) |
        (rs2    << 20) |
        (rs1    << 15) |
        (funct3 << 12) |
        (rd     <<  7) |
        opcode
    )

def i_encoder(imm, rs1, funct3, rd, opcode):
    imm &= 0xFFF

    return (
        (imm    << 20) |
        (rs1    << 15) |
        (funct3 << 12) |
        (rd     << 7)  |
        opcode
    )
def s_encoder(imm, rs2, rs1, funct3, opcode):
    imm &= 0xFFF

    return (
        (bits(imm, 11, 5) << 25) |
        (rs2              << 20) |
        (rs1              << 15) |
        (funct3           << 12) |
        (bits(imm, 4, 0)  << 7)  |
        opcode
    )

def b_encoder(imm, rs2, rs1, funct3, opcode):
    imm &= 0x1FFF

    return (
        (bits(imm, 12, 12) << 31) |
        (bits(imm, 10, 5)  << 25) |
        (rs2                << 20) |
        (rs1                << 15) |
        (funct3             << 12) |
        (bits(imm, 4, 1)    << 8)  |
        (bits(imm, 11, 11)  << 7)  |
        opcode
    )

def u_encoder(imm, rd, opcode):
    imm &= 0xFFFFF

    return (
        (imm << 12) |
        (rd  << 7)  |
        opcode
    )

def j_encoder(imm, rd, opcode):
    imm &= 0x1FFFFF

    return (
        (bits(imm, 20, 20) << 31) |
        (bits(imm, 10, 1)  << 21) |
        (bits(imm, 11, 11) << 20) |
        (bits(imm, 19, 12) << 12) |
        (rd                 << 7)  |
        opcode
    )


"Immediate generator"
def imm_gen(instr): 
    opcode = instr & 0x7F
    match opcode:
        case instr_opcode.LUI | instr_opcode.AUIPC:
            return bits(instr, 31, 12) << 12
        
        case instr_opcode.JAL:
            imm = (
                (bits(instr, 31, 31) << 20) |
                (bits(instr, 19, 12) << 12) |
                (bits(instr, 20, 20) << 11) |
                (bits(instr, 30, 21) << 1) 
            )
            return sign_extend(imm, 21)

        case instr_opcode.BRANCH:
            imm = (
                (bits(instr, 31, 31)  << 12) |
                (bits(instr, 7, 7)    << 11) |
                (bits(instr, 30, 25)  << 5)  |
                (bits(instr, 11, 8)  << 1)
            )
            return sign_extend(imm, 13)


        case instr_opcode.JALR | instr_opcode.LOAD:
            imm = bits(instr, 31,20)
            return sign_extend(imm, 12 )

        case instr_opcode.STORE:
            imm = (
                (bits(instr, 31, 25) << 5) |
                bits(instr, 11, 7)  
            )
            return sign_extend(imm, 12)
        case instr_opcode.IMM: 
            if bits(instr,14,12) == 0b101 or bits(instr,14,12) == 0b001:
                return bits(instr, 24, 20)
            else: 
                return sign_extend(bits(instr, 31, 20), 12)
        case _:
            return 0

"read the decoder table and define correct signals' values for each instruction"
def load_decode_table(filename):
    with open(filename, "r") as f:
        lines = f.readlines()

    table = {}

    for line in lines:
        line = line.strip()

        if not line.startswith("|"):
            continue

        columns = [x.strip() for x in line.split("|")[1:-1]]

        if not columns:
            continue

        if columns[0] == "Instruction":
            continue

        if all(set(x) <= {"-", ":"} for x in columns):
            continue

        instr = columns[0]

        # everything after instruction name
        table[instr] = columns[1:]

    return table

EXPECTED = load_decode_table(DECODER_MD)

"use to check the what type of instruction is decoded"
def reference_decode(instr):
    opcode = bits(instr, 6, 0)
    funct3 = bits(instr, 14, 12)
    funct7 = bits(instr, 31, 25)

    # U-type
    if opcode == instr_opcode.LUI:
        return "LUI"

    elif opcode == instr_opcode.AUIPC:
        return "AUIPC"

    # J-type
    elif opcode == instr_opcode.JAL:
        return "JAL"

    # JALR
    elif opcode == instr_opcode.JALR:
        if funct3 == 0b000:
            return "JALR"
        return "ILLEGAL"

    # BRANCH
    elif opcode == instr_opcode.BRANCH:
        branch_map = {
            0b000: "BEQ",
            0b001: "BNE",
            0b100: "BLT",
            0b101: "BGE",
            0b110: "BLTU",
            0b111: "BGEU",
        }

        return branch_map.get(funct3, "ILLEGAL")

    # LOAD
    elif opcode == instr_opcode.LOAD:
        load_map = {
            0b000: "LB",
            0b001: "LH",
            0b010: "LW",
            0b100: "LBU",
            0b101: "LHU",
        }

        return load_map.get(funct3, "ILLEGAL")

    # STORE
    elif opcode == instr_opcode.STORE:
        store_map = {
            0b000: "SB",
            0b001: "SH",
            0b010: "SW",
        }

        return store_map.get(funct3, "ILLEGAL")

    # OP-IMM
    elif opcode == instr_opcode.IMM:

        imm_map = {
            0b000: "ADDI",
            0b010: "SLTI",
            0b011: "SLTIU",
            0b100: "XORI",
            0b110: "ORI",
            0b111: "ANDI",
        }

        if funct3 in imm_map:
            return imm_map[funct3]

        # SLLI
        elif funct3 == 0b001:
            if funct7 == 0b0000000:
                return "SLLI"
            return "ILLEGAL"

        # SRLI / SRAI
        elif funct3 == 0b101:
            if funct7 == 0b0000000:
                return "SRLI"

            elif funct7 == 0b0100000:
                return "SRAI"

            return "ILLEGAL"

        return "ILLEGAL"

    # OP / register-register
    elif opcode == instr_opcode.REG:

        reg_map = {
            (0b000, 0b0000000): "ADD",
            (0b000, 0b0100000): "SUB",

            (0b001, 0b0000000): "SLL",
            (0b010, 0b0000000): "SLT",
            (0b011, 0b0000000): "SLTU",
            (0b100, 0b0000000): "XOR",

            (0b101, 0b0000000): "SRL",
            (0b101, 0b0100000): "SRA",

            (0b110, 0b0000000): "OR",
            (0b111, 0b0000000): "AND",
        }

        return reg_map.get((funct3, funct7), "ILLEGAL")

    # FENCE
    elif opcode == instr_opcode.FENCE:

        if funct3 != 0b000:
            return "ILLEGAL"

        # FENCE.TSO encoding
        if instr == 0x8330000F:
            return "ILLEGAL"

        # Exact PAUSE encoding
        elif instr == 0x0100000F:
            return "ILLEGAL"

        else:
            return "FENCE"

    # SYSTEM
    elif opcode == instr_opcode.ECALL_EBREAK:

        if instr == 0x00000073:
            return "ECALL"

        elif instr == 0x00100073:
            return "EBREAK"

        return "ILLEGAL"

    # Unknown opcode
    return "ILLEGAL"

async def test_decoder(dut, instruction): 
  instr_name = reference_decode(instruction)
  dut.i_instr.value = instruction
  await Timer(1, unit="ns")

  if instr_name == "ILLEGAL":
      assert int(dut.o_illegal.value) == 1
      assert int(dut.o_rd_we.value) == 0
      assert int(dut.o_mem_re.value) == 0
      assert int(dut.o_mem_we.value) == 0
      assert int(dut.o_branch.value) == 0
      assert int(dut.o_jal.value) == 0
      assert int(dut.o_jalr.value) == 0

  else:
      expected = EXPECTED[instr_name]
      assert int(dut.o_illegal.value) == 0

      for signal, expected_value in zip(SIGNALS, expected):

          if expected_value == "x":
              continue

          if expected_value in CONSTANTS:
               expected_value = CONSTANTS[expected_value]

          else:
              expected_value = int(expected_value)

          actual = int(getattr(dut, signal).value)

          assert actual == expected_value, (
              f"{instr_name}: {signal} "
              f"expected {expected_value}, got {actual}"
          )

      assert int(dut.o_imm.value) == imm_gen(instruction)

@cocotb.test()
async def random_test(dut):

    for _ in range(100000):
        instr = random.getrandbits(32)

        await test_decoder(dut, instr)

@cocotb.test()
async def edge_test(dut):
    EDGE_CASES = [

    # U-TYPE
    u_encoder(0x00000, 0,  instr_opcode.LUI),
    u_encoder(0xFFFFF, 31, instr_opcode.LUI),

    u_encoder(0x00000, 0,  instr_opcode.AUIPC),
    u_encoder(0xFFFFF, 31, instr_opcode.AUIPC),


    # J-TYPE, JAL
    j_encoder(0,        0,  instr_opcode.JAL),
    j_encoder(2,        31, instr_opcode.JAL),
    j_encoder(-2,       1,  instr_opcode.JAL),
    j_encoder(1048574,  31, instr_opcode.JAL),
    j_encoder(-1048576, 0,  instr_opcode.JAL),


    # I-TYPE: JALR
    i_encoder(0,     0,  0b000, 0,  instr_opcode.JALR),
    i_encoder(2047,  31, 0b000, 31, instr_opcode.JALR),
    i_encoder(-2048, 1,  0b000, 1,  instr_opcode.JALR),

    # illegal JALR funct3
    i_encoder(0, 1, 0b001, 1, instr_opcode.JALR),


    # B-TYPE: 
    b_encoder(-4096, 0,  0,  0b000, instr_opcode.BRANCH),  # BEQ
    b_encoder(4094,  31, 31, 0b001, instr_opcode.BRANCH),  # BNE
    b_encoder(-2,    1,  31, 0b100, instr_opcode.BRANCH),  # BLT
    b_encoder(2,     31, 1,  0b101, instr_opcode.BRANCH),  # BGE
    b_encoder(0,     0,  31, 0b110, instr_opcode.BRANCH),  # BLTU
    b_encoder(0,     31, 0,  0b111, instr_opcode.BRANCH),  # BGEU

    # illegal branch funct3
    b_encoder(0, 1, 2, 0b010, instr_opcode.BRANCH),
    b_encoder(0, 1, 2, 0b011, instr_opcode.BRANCH),


    # I-TYPE: LOAD
    i_encoder(-2048, 0,  0b000, 0,  instr_opcode.LOAD),  # LB
    i_encoder(2047,  31, 0b001, 31, instr_opcode.LOAD),  # LH
    i_encoder(-1,    1,  0b010, 1,  instr_opcode.LOAD),  # LW
    i_encoder(0,     0,  0b100, 31, instr_opcode.LOAD),  # LBU
    i_encoder(2047,  31, 0b101, 0,  instr_opcode.LOAD),  # LHU

    # illegal loads
    i_encoder(0, 1, 0b011, 1, instr_opcode.LOAD),
    i_encoder(0, 1, 0b110, 1, instr_opcode.LOAD),
    i_encoder(0, 1, 0b111, 1, instr_opcode.LOAD),


    # S-TYPE: 
    s_encoder(-2048, 0,  0,  0b000, instr_opcode.STORE),  # SB
    s_encoder(2047,  31, 31, 0b001, instr_opcode.STORE),  # SH
    s_encoder(-1,    1,  31, 0b010, instr_opcode.STORE),  # SW

    # illegal store funct3
    s_encoder(0, 1, 2, 0b111, instr_opcode.STORE),


    # I-TYPE: OP-IMM
    i_encoder(-2048, 0,  0b000, 0,  instr_opcode.IMM),  # ADDI
    i_encoder(2047,  31, 0b010, 31, instr_opcode.IMM),  # SLTI
    i_encoder(-1,    1,  0b011, 1,  instr_opcode.IMM),  # SLTIU
    i_encoder(0,     0,  0b100, 31, instr_opcode.IMM),  # XORI
    i_encoder(2047,  31, 0b110, 0,  instr_opcode.IMM),  # ORI
    i_encoder(-2048, 1,  0b111, 31, instr_opcode.IMM),  # ANDI


    # SHIFT-IMM
    i_encoder(
        (0b0000000 << 5) | 0,
        1, 0b001, 1, instr_opcode.IMM
    ),

    i_encoder(
        (0b0000000 << 5) | 31,
        31, 0b001, 31, instr_opcode.IMM
    ),

    i_encoder(
        (0b0000000 << 5) | 31,
        31, 0b101, 31, instr_opcode.IMM
    ),

    i_encoder(
        (0b0100000 << 5) | 31,
        31, 0b101, 31, instr_opcode.IMM
    ),

    # illegal shift funct7
    i_encoder(
        (0b1111111 << 5) | 1,
        1, 0b001, 1, instr_opcode.IMM
    ),


    # R-TYPE
    r_encoder(0b0000000, 0,  0,  0b000, 0,  instr_opcode.REG),  # ADD
    r_encoder(0b0100000, 31, 31, 0b000, 31, instr_opcode.REG),  # SUB
    r_encoder(0b0000000, 31, 0,  0b001, 31, instr_opcode.REG),  # SLL
    r_encoder(0b0000000, 0,  31, 0b010, 0,  instr_opcode.REG),  # SLT
    r_encoder(0b0000000, 31, 31, 0b011, 31, instr_opcode.REG),  # SLTU
    r_encoder(0b0000000, 1,  2,  0b100, 3,  instr_opcode.REG),  # XOR
    r_encoder(0b0000000, 31, 31, 0b101, 31, instr_opcode.REG),  # SRL
    r_encoder(0b0100000, 31, 31, 0b101, 31, instr_opcode.REG),  # SRA
    r_encoder(0b0000000, 1,  2,  0b110, 3,  instr_opcode.REG),  # OR
    r_encoder(0b0000000, 31, 31, 0b111, 31, instr_opcode.REG),  # AND

    # illegal R-type funct7
    r_encoder(0b1111111, 1, 2, 0b000, 3, instr_opcode.REG),


    # FENCE / SYSTEM
    0x0000000F,   # FENCE
    0x8330000F,   # FENCE.TSO
    0x0100000F,   # PAUSE 

    0x00000073,   # ECALL
    0x00100073,   # EBREAK


    # UNKNOWN OPCODES
    0x00000000,
    0xFFFFFFFF,
]

    for instr in EDGE_CASES:
        await test_decoder(dut,instr)
    





