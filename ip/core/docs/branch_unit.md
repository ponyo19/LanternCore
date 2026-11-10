# LanternCore M1 — Branch unit (`lc_branch_unit`)

**Goal:** Implementing combinational branch unit of RV32I, producing the the new PC with offset added.

## Interface

```systemverilog
module lc_branch_unit #(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input logic branch_i,
    input logic jal_i,
    input logic jalr_i,

    input logic [2:0] branch_cond_i,
    input logic eq_i,
    input logic lt_i,
    input logic ltu_i,
     
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] offset_i,
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] rs1_data_i,
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] pc_i,

    output logic [g_LC_CONFIG.DATA_WIDTH-1:0] branch_pc_o,
    output logic                              branch_sl_o
);
```

## Requirements

1. Purely combinational: no clock, no reset, no latches. Remember to assign every combinational path!
2. Calculate the correct branch target address `branch_pc_o` and generate control flag for PC selection.
3. While JALR and JAL are unconditional jump, other branches need correct comparison flag with `branch condition` and `branch_i` high to assert `branch_sl_o`
4. Remember JALR has a different offset calculation compared to others.

## Done when
- [] `branch_pc_o` table for different branch instructions
- [] `rtl/lc_branch_unit.sv` is pushed
- [] Verilator lint passes with `-Wall`
- [] Self-checking testbench in `tests/test_branch_unit/` checks important cases: Correct functionality of each branch instructions, correct `branch_pc_o` for different branches, JAL and JALR automatically asserts `branch_sl_o`,...