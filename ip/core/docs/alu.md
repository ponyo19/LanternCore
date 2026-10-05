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

To-do:
- Define type `alu_op_T` in `lc_pkg.sv` with all ALU operations. Check what can be reused.

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
