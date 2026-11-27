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
    input  logic ready_o
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
- The fetcher shall issue a read request to instruction memory in
        the same cycle (or ≤ 1 cycle after) the core requests the next
        instruction.

-  The fetcher shall return the instruction to the core within
        L_mem cycles of the request, where L_mem is the memory latency.

- The fetcher shall accept a new fetch request in the cycle after
        it delivers an instruction, i.e. it supports back-to-back fetches
        without idle cycles.

- The fetcher shall hold the delivered instruction stable until the
        core acknowledges it.

- The fetcher shall fetch from the PC provided by the core for every
        request; no sequential-PC assumption (branches need no flush).
- The fetcher decouples OBI transaction from its output interface.

## IF
- `instr_o` is received combinationally from `rdata` and is active until `done_o` and `ready_o` handshake. 
- When `instr_o` contains the needed data, assert `done_o` until until `done_o` and `ready_o` handshake.
- `err_o` is received combinationally from err resp payload and is active until `done_o` and `ready_o` handshake.
- `err` happens when instruction rom received pc outside of its range, and is handled by the rom. 
## OBI
- when synchronous `rst_ni` is LOW, reset the FSM to IDLE and deassert req.
- When `re_i` is HIGH, assert `req` and send `pc_i` as `addr`. 
- Keep `req` asserted and `addr` stable until `req && gnt`(request accepted) is sampled at a rising clock edge.
- When the request is accepted, deassert `req` and wait for response.
- When `rvalid` is HIGH, the instruction can be received from `rdata`.
- Takes a minimum one clock cycle counted from `req` HIGH to get the required data.


# Done when

- [ ] Verilator lint passes with `-Wall`
- [ ] `rtl/lc_if.sv` is pushed
- [ ] Self-checking testbench in `tests/test_if/` checks correct output according to `pc_i`, checks correct OBI's behavior 
