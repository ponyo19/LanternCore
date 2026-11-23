module lc_regfile
    import lc_pkg::*;
#(
    parameter lc_config_t g_LC_CONFIG = LC_CONFIG_DEFAULT
)(
    input  logic                                clk_i,

    // Read ports
    input  logic                                re_rs1_i,
    input  logic                                re_rs2_i,
    input  logic [4:0]                        rs1_addr_i,
    input  logic [4:0]                        rs2_addr_i,
    output logic [g_LC_CONFIG.DATA_WIDTH-1:0] rs1_data_o,
    output logic [g_LC_CONFIG.DATA_WIDTH-1:0] rs2_data_o,

    // Write port
    input  logic                              wr_en_i,
    input  logic [4:0]                        wr_addr_i,
    input  logic [g_LC_CONFIG.DATA_WIDTH-1:0] wr_data_i
);
logic [g_LC_CONFIG.DATA_WIDTH-1:0] gpr [0:31];

always_comb begin 
    rs1_data_o = (re_rs1_i && rs1_addr_i != 0) ? gpr[rs1_addr_i] : '0;
    rs2_data_o = (re_rs2_i && rs2_addr_i != 0) ? gpr[rs2_addr_i] : '0;

end

always_ff @(posedge clk_i) begin 
    if (wr_en_i && wr_addr_i != 0) begin
        gpr[wr_addr_i] <= wr_data_i;
    end

end
endmodule
