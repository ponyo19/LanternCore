# LanternCore M1 — Instruction fetch (`lc_if`)

**Goal:** fetch instruction from the provided address

**Reference:** 
- RISC-V Unprivileged ISA spec, chapter 2 (RV32I).
- [OBI Protocol](https://github.com/pulp-platform/obi)

## Interface

```systemverilog
module lc_if
    import lc_pkg::*;
    import obi_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,
    input logic re_i,

    input  logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0 ] pc_i,
    output logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0 ] instr_o,
    output logic done_o, err_o,

    // OBI's interface
    input  logic gnt, rvalid,
    output logic req,

    input  obi_inst_resp_t resp_payload,
    output obi_inst_req_t  req_payload
);
```

# Operations
## IF
- `instr_o` is received combinationally from `rdata` and only active for one cycle. 
- When `instr_o` contains the needed data, pulse `done_o` HIGH for one cycle.
- `err_o` is received combinationally from err resp payload and only active for one cycle.
- `err` happens when instruction rom received pc outside of its range, and is handled by the rom. 
## OBI
- when synchronous `rst_ni` is LOW, reset the FSM to IDLE and deassert req.
- When `re_i` is HIGH, assert `req` and send `pc_i` as `addr`. 
- Keep `req` asserted and `addr` stable until `req && gnt`(request accepted) is sampled at a rising clock edge.
- When the request is accepted, deassert `req` and wait for response.
- When `rvalid` is HIGH, the instruction can be received from `rdata`.

# Assumption for current implementation
- Assume `re_i` is a one-clock-cycle pulse.

# Done when

- [ ] Verilator lint passes with `-Wall`
- [ ] `rtl/lc_if.sv` is pushed
- [ ] Self-checking testbench in `tests/test_if/` checks correct output according to `pc_i`, checks correct OBI's behavior 
