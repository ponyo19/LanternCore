# LanternCore M1 — Decoder (`lc_decoder`)

**Goal:** Combinational decoder that turns a 32-bit RV32I instruction into register addresses, an immediate, and datapath control signals.

**Not in scope:** CSRs, M/A extensions, compressed instructions (all treated as illegal for now).

**Reference:** RISC-V Unprivileged ISA spec, chapter 2 (RV32I).

## Interface

```systemverilog
module lc_decoder
  import lc_pkg::*;
(
  input  logic [31:0]   i_instr,

  output logic [4:0]    o_rs1_addr, o_rs2_addr, o_rd_addr,
  output logic          o_rd_we,
  output logic [31:0]   o_imm,          // sign-extended, correct format per instruction

  output lc_alu_op_T    o_alu_op,
  output lc_alu_op_a_sel_T  o_op_a_sel,     // OPA_RS1 | OPA_PC | OPA_ZERO
  output lc_alu_op_b_sel_T  o_op_b_sel,     // OPB_RS2 | OPB_IMM

  output logic          o_mem_re, o_mem_we,
  output lc_mem_size_T  o_mem_size,     // MEM_B | MEM_H | MEM_W
  output logic          o_mem_unsigned,

  output lc_wb_sel_T    o_wb_sel,       // WB_ALU | WB_MEM | WB_PC4

  output logic          o_branch,
  output logic [2:0]    o_branch_cond,  // funct3 of the branch
  output logic          o_jal, o_jalr,

  output logic          o_fence, o_ecall, o_ebreak,
  output logic          o_illegal
);
```

All enums are defined in `lc_pkg.sv`. `lc_alu_op_T` is shared with the ALU and uses the `{funct7[5], funct3}` encoding.

## Decode Table
To-do

## Requirements

1. Purely combinational: no clock, no reset, no latches. Remember to assign every combinational path!
2. Decode **all RV32I instructions**. Working out the control values for each one from the ISA spec is part of the task.
3. Hint: LUI = `0 + imm`, AUIPC = `PC + imm`, and loads/stores/JALR use the ALU to compute `rs1 + imm`.
4. Do not special-case `rd = x0`. The register file handles it.
5. FENCE is a NOP for now.
6. Anything not in RV32I sets `illegal_o = 1`. When it does, **all side-effect signals must be 0**: `rd_we`, `mem_re`, `mem_we`, `branch`, `jal`, `jalr`.
7. Immediate generator implemented as a submodule

## Done when

- [ ] `rtl/lc_decoder.sv` is pushed
- [ ] Verilator lint passes with `-Wall`
- [ ] Self-checking testbench in `tests/test_decoder/` checks every RV32I instruction, immediate edge cases (sign bit 0 and 1), and a set of illegal encodings
- [ ] Decode table