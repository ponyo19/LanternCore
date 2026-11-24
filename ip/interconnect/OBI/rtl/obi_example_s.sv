// Example OBI Subordinate
import obi_pkg::*;

module obi_example_s (
    input logic clk,
    input logic rst_n,
    
    // Handshake
    input logic req,
    output logic gnt,
    output logic rvalid,

    // Payload (e.g., instruction bus)
    input obi_inst_req_t req_payload,
    output obi_inst_resp_t resp_payload
);

    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        GNT     = 2'b01,
        PROCESS = 2'b10
    } state_t;

    state_t state, state_next;

    logic [INSTR_DATA_WIDTH-1:0] addr_reg;

    always_ff @(posedge clk) begin
        if (!rst_n) state <= IDLE;
        else        state <= state_next;
    end

    always_comb begin
        state_next                = state;
        gnt                = 1'b0;
        rvalid             = 1'b0;
        resp_payload.rdata = '0;
        resp_payload.err   = 1'b0;

        case (state)
        IDLE: if (req) state_next = GNT;
        GNT: begin
            gnt = 1'b1;
            state_next = PROCESS;
        end
        PROCESS: begin
            rvalid             = 1'b1;   // 1-cycle pulse
            resp_payload.rdata = addr_reg;
            state_next                = IDLE;
        end
        default: state_next = IDLE;
        endcase
    end

    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            addr_reg <= '0;
        end else if (state == IDLE) begin
            addr_reg <= '0;
        end else if (state == GNT) begin
            addr_reg <= req_payload.addr;
        end 
    end

endmodule
