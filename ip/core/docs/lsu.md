# LanternCore M1 — Load-Store Unit (`lc_lsu`)

**Goal:** Load-Store Unit that executes all load and store instructions through OBI interface. 

**Reference:** 
- RISC-V Unprivileged ISA spec, chapter 2 (RV32I).
- [OBI Protocol](https://github.com/pulp-platform/obi)

## Interface

```systemverilog
module lc_lsu 
    import lc_pkg::*;
#(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
)(
    input logic clk_i,

    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] addr_i,
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] rs2_i,

    // Memory read signal
    input  logic                        mem_re_i, 
    output [g_LC_CONFIG.DATA_WIDTH-1:0] data_o,

    // Memory write signals
    input logic         mem_we_i,
    input logic         mem_unsigned_i,
    input lc_mem_size_T mem_size_i,

    obi_if.manager_if #(
        .REQ_TYPE(obi_data_req_T),
        .RESP_TYPE(obi_data_resp_T)
    ) m2s_obi
);
```
# Operations
## LSU
LOAD operation(`mem_re_i=1`)
- Wait and take the according memory value, perform sign/zero extension depending on the `mem_unsigned_i` and `mem_size_i`.
- Send the result sequentially to `data_o`. 

STORE operation (`mem_we_i=1`)
- Use `rs2_i` with the according `mem_size_i` to get the correct aligned `wdata`. 
- No sign extension.

## OBI
- For STORE operation, assert `we`, send the `addr`, the according `wdata` based on `mem_size_i`, and `be` through OBI. 
- For LOAD operation, deassert `we`, send the `addr` and the according `be` based on `mem_size_i`. `wdata` is ignored by memory.
- When `mem_re_i || mem_we_i` in IDLE state, assert `req` and send the data request payload accordingly to the input.
- Keep `req` asserted and data request payload stable until `req && gnt`(request accepted) is sampled at a rising clock edge.
- When the request is accepted, deassert `req` and wait for response.
- When `rvalid` is HIGH, `rdata` can be received in LOAD, while this mean STORE response is available.

# Assumption for current implementation
- Assume `err` = 0.
- Assume the core blocks the combinational signals `mem_rd_i` and `mem_we_i` from constantly activating lsu when not needed.
  
# Done when
- [ ] Verilator lint passes with `-Wall`
- [ ] `rtl/lc_lsu.sv` is pushed
- [ ] Self-checking testbench in `tests/test_lsu/` performs accordingly to the operations.