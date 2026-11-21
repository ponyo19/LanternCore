# LanternCore M1 — Instruction fetch (`lc_if`)

**Goal:** fetch instruction from the provided address

**Reference:** 
- RISC-V Unprivileged ISA spec, chapter 2 (RV32I).
- [OBI Protocol](https://github.com/pulp-platform/obi)

## Interface

```systemverilog
module lc_if #(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input logic clk_i,
    input logic re_en_i,

    input  logic [g_LC_CONFIG.DATA_WIDTH-1:0 ] pc_i,
    output logic [g_LC_CONFIG.DATA_WIDTH-1:0 ] instr_o,

    obi_if.manager_if #(
        .REQ_TYPE(obi_inst_req_T),
        .RESP_TYPE(obi_inst_resp_T)
    ) m2s_obi
);
```

# Operations
- When `re_en_i` is HIGH, assert `req` and send `pc_i` as `addr`. 
- Keep `req` asserted and `addr` stable until `req && gnt`(request accepted) is sampled at a rising clock edge.
- When the request is accepted, deassert `req` and wait for response.
- When `rvalid` is HIGH, the instruction can be received from `rdata`.

# Assumption for current implementation
- assume `err` = 0.
- Assume `re_en_i` is a one-clock-cycle pulse.

# Done when

- [ ] Verilator lint passes with `-Wall`
- [ ] `rtl/lc_if.sv` is pushed
- [ ] Self-checking testbench in `tests/test_if/` checks correct output according to `pc_i`, checks correct OBI's behavior 
