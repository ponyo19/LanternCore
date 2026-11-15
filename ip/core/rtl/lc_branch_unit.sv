module lc_branch_unit 
    import lc_pkg::*;
#(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
)(
    input logic branch_i,
    input logic jal_i,
    input logic jalr_i,

    input logic [2:0] branch_cond_i,
    input logic eq_i,
    input logic lt_i,
    input logic ltu_i,
     
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] offset_i,
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] rs1_data_i,
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0] pc_i,

    output logic [g_LC_CONFIG.DATA_WIDTH-1:0] branch_pc_o,
    output logic                              branch_sl_o
);

always_comb begin
    branch_pc_o = pc_i;
    branch_sl_o = 0;

    if (jal_i) begin
        branch_pc_o = pc_i + offset_i;
        branch_sl_o = 1'b1;
    end 

    else if (jalr_i) begin
        branch_pc_o = (rs1_data_i + offset_i) & ~g_LC_CONFIG.DATA_WIDTH'(1);
        branch_sl_o = 1'b1;
    end

    else if (branch_i) begin
        if ((branch_cond_i == 3'b000 &&  eq_i)   ||    //BEQ
            (branch_cond_i == 3'b001 && !eq_i)   ||    //BNE
            (branch_cond_i == 3'b100 &&  lt_i)   ||    //BLT
            (branch_cond_i == 3'b101 && !lt_i)   ||    //BGE
            (branch_cond_i == 3'b110 &&  ltu_i)  ||    //BLTU
            (branch_cond_i == 3'b111 && !ltu_i)) begin //BGEU

            branch_pc_o = pc_i + offset_i;
            branch_sl_o = 1'b1;
        end
    end
end
endmodule
