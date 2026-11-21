module obi_example (
    input clk,
    input rst_n,

    obi_if.subordinate_if #(
        .REQ_TYPE(obi_inst_req_T),
        .RESP_TYPE(obi_inst_resp_T)
    ) s_port;
);

    typedef enum logic [1:0] { 
        IDLE = 2'b00,
        GNT = 2'b01,
        PROCESS = 2'b10
    } state_t;

    state_t state, state_next;

    always_ff @( posedge clk ) begin
        if (!rst_n) begin
            state = IDLE;
        end else begin
            state = state_next;
        end
    end

    always_comb begin
        s_port.gnt = 0;
        s_port.rvalid = 0
        s_port.resp_payload.rdata = '0;
        s_port.resp_payload.err = 0;
        case (state)
            IDLE: begin
                if (req) begin
                    state_next = GNT;
                end
            end
            GNT: begin
                s_port.gnt = 1'b1;
                state_next = PROCESS
            end 
            PROCESS: begin
                s_port.resp_payload.rdata = 32'd16;
                s_port.resp_payload.err = 0;
                s_port.rvalid = 1'b1; // Pulsed
                state_next = IDLE;
            end
            default: 
        endcase
    end
    

endmodule