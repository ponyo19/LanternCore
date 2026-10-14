# LanternCore M1 — ALU (`lc_alu`)

**Goal:** Combinational ALU for all RV32I integer operations, plus compare flags for branches.

**Not in scope:** MUL/DIV (separate block in M2), branch target calculation.

## Interface

```systemverilog
module lc_alu #(
    lc_config_t LC_CONFIG
) (
    input logic [LC_CONFIG.DATA_WIDTH-1:0]      i_op_a,
    input logic [LC_CONFIG.DATA_WIDTH-1:0]      i_op_b,
    input alu_top_T                             i_alu_op,

    output logic [LC_CONFIG.DATA_WIDTH-1:0]     o_alu_result,
    output logic                                o_eq,    // op_a == op_b
    output logic                                o_lt,    // op_a <  op_b, signed
    output logic                                o_ltu    // op_a <  op_b, unsigned
);
```

## Operations

`lc_alu_op_T` in `lc_pkg.sv`. The encoding is `{funct7[5], funct3}`, so R-type instructions map directly.

| `lc_alu_op_T` | Encoding | Result                    | Used by                                         |
|---------------|----------|---------------------------|-------------------------------------------------|
| `ALU_ADD`     | `0000`   | `a + b`                   | ADD, ADDI, LUI, AUIPC, JAL, JALR, loads, stores |
| `ALU_SUB`     | `1000`   | `a - b`                   | SUB                                             |
| `ALU_SLL`     | `0001`   | `a << b[4:0]`             | SLL, SLLI                                       |
| `ALU_SLT`     | `0010`   | `a < b` signed, 0 or 1    | SLT, SLTI                                       |
| `ALU_SLTU`    | `0011`   | `a < b` unsigned, 0 or 1  | SLTU, SLTIU                                     |
| `ALU_XOR`     | `0100`   | `a ^ b`                   | XOR, XORI                                       |
| `ALU_SRL`     | `0101`   | `a >> b[4:0]`             | SRL, SRLI                                       |
| `ALU_SRA`     | `1101`   | `a >>> b[4:0]` signed     | SRA, SRAI                                       |
| `ALU_OR`      | `0110`   | `a \| b`                  | OR, ORI                                         |
| `ALU_AND`     | `0111`   | `a & b`                   | AND, ANDI                                       |

- LUI uses `0 + imm` (`OPA_ZERO`), AUIPC and JAL use `pc + imm` (`OPA_PC`), JALR, loads and stores use `rs1 + imm`.
- Branches (BEQ/BNE/BLT/BGE/BLTU/BGEU) only use the flags `o_eq`, `o_lt`, `o_ltu` with `op_a = rs1`, `op_b = rs2`.
- FENCE, ECALL and EBREAK do not use the ALU.

## Requirements

1. Purely combinational: no clock, no reset, no latches.
2. Arithmetic wraps mod 2³². No overflow or carry outputs.
3. Shifts use only `op_b[4:0]`.
4. SLT/SLTU return 0 or 1.
5. Flags are valid for **every** `alu_op`. The branch unit uses them directly.
6. Unused `alu_op` encodings return `0`, never X.

## Done when

- [ ] `rtl/lc_alu.sv` is pushed
- [ ] Verilator lint passes with `-Wall`
- [ ] Self-checking testbench in `tests/test_alu/` covers corner cases (0, -1, `0x7FFFFFFF`, `0x80000000`, all shift amounts) plus random vectors against a reference model
