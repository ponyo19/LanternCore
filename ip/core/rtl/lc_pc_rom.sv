module lc_pc_rom
    import lc_pkg::*;
    import obi_pkg::*;
#(
    parameter ROM_FILE = "" ,
    parameter ROM_SIZE = 256
)
(
    input logic clk_i,
    input logic rst_ni,

    // OBI's interface
    input  logic req,
    output logic gnt, rvalid,

    input  obi_inst_req_t  req_payload,
    output obi_inst_resp_t resp_payload
);

logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0] pc_rom [0:ROM_SIZE-1];

initial begin
    if (ROM_FILE != "") begin
        $readmemh(ROM_FILE, pc_rom);
    end
end

typedef enum logic[1:0] {
    IDLE, GNT, PROCESS
} state_t;

state_t state, state_next;

logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0] addr_r;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        state <= IDLE;
        addr_r <= 0;
    end else begin
        state <= state_next;
        if (req && gnt) begin
            addr_r <= req_payload.addr;
        
        end
    end
end

always_comb begin
    gnt = 1'b0;
    rvalid = 1'b0;
    resp_payload.rdata = '0;
    resp_payload.err = 1'b0;
    state_next = state;

    case (state) 
        IDLE: begin
            if (req) begin
                state_next = GNT;
            end
        end

        GNT: begin
            gnt = 1'b1;
            state_next = PROCESS;
        end

        PROCESS: begin
            rvalid = 1'b1;
            state_next = IDLE;

            if ((addr_r >> 2) >= ROM_SIZE) begin
                resp_payload.err = 1'b1;
                resp_payload.rdata = '0;
            end else begin
                resp_payload.rdata = pc_rom[addr_r >> 2];
            end
        end

        default: begin
            state_next = IDLE;
        end
    endcase        
end
endmodule
