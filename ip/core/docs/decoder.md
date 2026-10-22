# LanternCore M1 — Decoder (`lc_decoder`)

**Goal:** Combinational decoder that turns a 32-bit RV32I instruction into register addresses, an immediate, and datapath control signals.

**Not in scope:** CSRs, M/A extensions, compressed instructions (all treated as illegal for now).

**Reference:** RISC-V Unprivileged ISA spec, chapter 2 (RV32I).

## Interface

```systemverilog
module lc_decoder
  import lc_pkg::*;
(
  input  logic [31:0]   instr_i,

  output logic [4:0]    rs1_addr_o, rs2_addr_o, rd_addr_o,
  output logic          rd_we_o,
  output logic [31:0]   imm_o,          // sign-extended, correct format per instruction

  output lc_alu_op_T    alu_op_o,
  output lc_alu_op_a_sel_T  op_a_sel_o,     // OPA_RS1 | OPA_PC | OPA_ZERO
  output lc_alu_op_b_sel_T  op_b_sel_o,     // OPB_RS2 | OPB_IMM

  output logic          mem_re_o, mem_we_o,
  output lc_mem_size_T  mem_size_o,     // MEM_B | MEM_H | MEM_W
  output logic          mem_unsigned_o,

  output lc_wb_sel_T    wb_sel_o,       // WB_ALU | WB_MEM | WB_PC4

  output logic          branch_o,
  output logic [2:0]    branch_cond_o,  // funct3 of the branch
  output logic          jal_o, jalr_o,

  output logic          fence_o, ecall_o, ebreak_o,
  output logic          illegal_o
);
```

All enums are defined in `lc_pkg.sv`. `lc_alu_op_T` is shared with the ALU and uses the `{funct7[5], funct3}` encoding.

## Decode Table
| Instruction |  alu_op_o | op_a_sel_o | op_b_sel_o| rd_we_o | mem_re_o | mem_we_o | mem_size_o | mem_unsigned_o | branch_o | wb_sel_o |
|---|---|---|---|---|---|---|---|---|---|---|
|     LUI     |  ALU_ADD  |  OPA_ZERO  |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  | 
|    AUIPC    |  ALU_ADD  |  OPA_PC    |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |        
|     JAL     |  ALU_ADD  |  OPA_PC    |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_PC4  |        
|     JALR    |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_PC4  | 
|     BEQ     |  ALU_SUB  |  OPA_RS1   |  OPB_RS2  |    0    |    0     |    0     |     x      |        x       |     1    |    x     |        
|     BNE     |  ALU_SUB  |  OPA_RS1   |  OPB_RS2  |    0    |    0     |    0     |     x      |        x       |     1    |    x     |       
|     BLT     |  ALU_SUB  |  OPA_RS1   |  OPB_RS2  |    0    |    0     |    0     |     x      |        x       |     1    |    x     |          
|     BGE     |  ALU_SUB  |  OPA_RS1   |  OPB_RS2  |    0    |    0     |    0     |     x      |        x       |     1    |    x     |     
|     BLTU    |  ALU_SUB  |  OPA_RS1   |  OPB_RS2  |    0    |    0     |    0     |     x      |        x       |     1    |    x     |         
|     BGEU    |  ALU_SUB  |  OPA_RS1   |  OPB_RS2  |    0    |    0     |    0     |     x      |        x       |     1    |    x     |      
|     LB      |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    1    |    1     |    0     |    MEM_B   |        0       |     0    |  WB_MEM  | 
|     LH      |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    1    |    1     |    0     |    MEM_H   |        0       |     0    |  WB_MEM  |    
|     LW      |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    1    |    1     |    0     |    MEM_W   |        0       |     0    |  WB_MEM  |        
|     LBU     |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    1    |    1     |    0     |    MEM_B   |        1       |     0    |  WB_MEM  |        
|     LHU     |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    1    |    1     |    0     |    MEM_H   |        1       |     0    |  WB_MEM  |        
|     SB      |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    0    |    0     |    1     |    MEM_B   |        x       |     0    |    x     |         
|     SH      |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    0    |    0     |    1     |    MEM_H   |        x       |     0    |    x     |      
|     SW      |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    0    |    0     |    1     |    MEM_W   |        x       |     0    |    x     |        
|     ADDI    |  ALU_ADD  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SLTI    |  ALU_SLT  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |    
|     SLTIU   |  ALU_SLTU |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |     
|     XORI    |  ALU_XOR  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     ORI     |  ALU_OR   |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     ANDI    |  ALU_AND  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SLLI    |  ALU_SLL  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SRLI    |  ALU_SRL  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |  
|     SRAI    |  ALU_SRA  |  OPA_RS1   |  OPB_IMM  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     ADD     |  ALU_ADD  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SUB     |  ALU_SUB  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SLL     |  ALU_SLL  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SLT     |  ALU_SLT  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SLTU    |  ALU_SLTU |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |  
|     XOR     |  ALU_XOR  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SRL     |  ALU_SRL  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     SRA     |  ALU_SRA  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     OR      |  ALU_OR   |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     AND     |  ALU_AND  |  OPA_RS1   |  OPB_RS2  |    1    |    0     |    0     |     x      |        x       |     0    |  WB_ALU  |   
|     FENCE   |     x     |     x      |     x     |    0    |    0     |    0     |     x      |        x       |     0    |    x     |    
|   FENCE.TSO |     x     |     x      |     x     |    0    |    0     |    0     |     x      |        x       |     0    |    x     |   
|     PAUSE   |     x     |     x      |     x     |    0    |    0     |    0     |     x      |        x       |     0    |    x     |    
|     ECALL   |     x     |     x      |     x     |    0    |    0     |    0     |     x      |        x       |     0    |    x     |    
|     EBREAK  |     x     |     x      |     x     |    0    |    0     |    0     |     x      |        x       |     0    |    x     |   

**Note**
- x means the field can be ignored
- FENCE, ECALL, EBREAK is NOP
- FENCE.TSO, PAUSE is illegal


## Requirements

1. Purely combinational: no clock, no reset, no latches. Remember to assign every combinational path!
2. Decode **all RV32I instructions**. Working out the control values for each one from the ISA spec is part of the task.
3. Hint: LUI = `0 + imm`, AUIPC = `PC + imm`, and loads/stores/JALR use the ALU to compute `rs1 + imm`.
4. Do not special-case `rd = x0`. The register file handles it.
5. FENCE is a NOP for now.
6. Anything not in RV32I sets `illegal_o = 1`. When it does, **all side-effect signals must be 0**: `rd_we`, `mem_re`, `mem_we`, `branch`, `jal`, `jalr`.
7. Immediate generator implemented as a submodule

## Done when

- [X] `rtl/lc_decoder.sv` is pushed
- [X] Verilator lint passes with `-Wall`
- [X] Self-checking testbench in `tests/test_decoder/` checks every RV32I instruction, immediate edge cases (sign bit 0 and 1), and a set of illegal encodings
- [X] Decode table