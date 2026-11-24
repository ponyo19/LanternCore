module lc_if
    import lc_pkg::*;
    import obi_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,
    input logic re_i,

    input  logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0] pc_i,
    output logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0] instr_o,
    output logic done_o, err_o,

    // OBI's interface
    input  logic gnt, rvalid,
    output logic req,

    input  obi_inst_resp_t resp_payload,
    output obi_inst_req_t  req_payload
);

typedef enum logic [1:0] {
    IDLE, GNT, PROCESS
} state_t;

state_t state, state_next;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        state <= IDLE;
    end else begin
        state <= state_next;
    end
end

always_comb begin
    req = 0;
    err_o = 0;
    done_o = 0;
    instr_o = 0;
    req_payload = OBI_INST_REQ_RESET_VAL;
    state_next = state;

    case (state)
        IDLE: begin
            if (re_i && rst_ni) begin
                req_payload.addr = pc_i;
                req = 1;
                state_next = GNT;
            end
        end

        GNT: begin
            req = 1;
            req_payload.addr = pc_i;
            if (gnt) begin
                state_next = PROCESS;
            end
        end

        PROCESS: begin
            if (rvalid) begin
                instr_o = resp_payload.rdata;
                err_o = resp_payload.err;
                done_o = 1;
                state_next = IDLE;
            end
        end

        default: begin
            state_next = IDLE;
        end
    endcase
end

endmodule
