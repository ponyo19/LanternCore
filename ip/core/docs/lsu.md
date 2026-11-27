# LanternCore M1 — Load-Store Unit (`lc_lsu`)

**Goal:** Load-Store Unit that executes all load and store instructions through OBI interface. 

**Reference:** 
- RISC-V Unprivileged ISA spec, chapter 2 (RV32I).
- [OBI Protocol](https://github.com/pulp-platform/obi)

## Interface

```systemverilog
module lc_lsu 
    import lc_pkg::*;
    import obi_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,

    input logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0] addr_i,
    input logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0] rs2_i,

    // Memory read signal
    input  logic                                    re_i, 
    output logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0] data_o,

    // Memory write signals
    input logic         we_i,
    input logic         mem_unsigned_i,
    input lc_mem_size_T mem_size_i,

    output logic done_o,
    output logic err_o,

    // OBI's interface
    input  logic gnt, rvalid,
    output logic req,

    input  obi_data_resp_t resp_payload,
    output obi_data_req_t  req_payload
);
```
# Operations
## LSU
- `done_o` is asserted when lsu operation finnish, including error response.
- `err_o` is received from resp payload and active for one cycle. `err` is handled by the RAM.
  
LOAD operation(`re_i=1`)
- Wait and take the according memory value, perform sign/zero extension depending on the `mem_unsigned_i` and `mem_size_i`.
- `data_o` receives the result combinationally, and is active for one cycle.

STORE operation (`we_i=1`)
- Use `rs2_i` with the according `mem_size_i` to get the correct aligned `wdata`. 
- No sign extension.

## OBI
- For STORE operation, assert `we`, send the `addr`, the according `wdata` based on `mem_size_i`, and `be` through OBI. 
- For LOAD operation, deassert `we`, send the `addr` and the according `be` based on `mem_size_i`. `wdata` is ignored by memory.
- In IDLE state, when `re_i || we_i`, assert `req` and send the data request payload accordingly to the input.
- Keep `req` asserted and data request payload stable until `req && gnt`(request accepted) is sampled at a rising clock edge.
- When the request is accepted, deassert `req` and wait for response.
- When `rvalid` is HIGH, `rdata` can be received in LOAD, while this mean STORE response is available.
- Takes a minimum one clock cycle counted from `req` HIGH to get the required data.

# Assumption for current implementation
- `re_i` and `we_i` remain asserted throughout the lsu operation and are deasserted when the core advances out of MEM stage upon `done_o`.
  
# Done when
- [ ] Verilator lint passes with `-Wall`
- [ ] `rtl/lc_lsu.sv` is pushed
- [ ] Self-checking testbench in `tests/test_lsu/` performs accordingly to the operations.