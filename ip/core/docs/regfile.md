# LanternCore M1 — Register file (`lc_regfile`)

**Goal**: Implementing RV32I's general-purpose register file with two combinational read ports and one synchronous write port.

## Interface

```systemverilog
module lc_regfile #(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input  logic                              clk_i,

    // Read ports
    input  logic [4:0]                        rs1_addr_i,
    input  logic [4:0]                        rs2_addr_i,
    output logic [g_LC_CONFIG.DATA_WIDTH-1:0] rs1_data_o,
    output logic [g_LC_CONFIG.DATA_WIDTH-1:0] rs2_data_o,

    // Write port
    input  logic                              wr_en_i,
    input  logic [4:0]                        wr_addr_i,
    input  logic [g_LC_CONFIG.DATA_WIDTH-1:0] wr_data_i
);
```

## Requirements

1. Read of general purpose registers is combinational. Writing is sequential.
2. Two independent reading ports for `rs1` and `rs2`. Synchronous writing port, updating on `posedge clk_i` when `wr_en_i` = 1.
2. Contains 32 general-purpose registers (`x0-x31`).
3. Registers `x0` is hardwired to zero. Reading always returns 0, while writing to this register is ignored.
4. No reset required. Initially, all registers have unspecific contents except for `x0`.

## Done when

- [] `rtl/lc_regfile.sv` is pushed
- [] Verilator lint passes with `-Wall`
- [] Self-checking testbench in `tests/test_regfile/` checks important cases: Read and write of `x0`, register file functions as intended,...

