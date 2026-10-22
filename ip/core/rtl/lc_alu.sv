// ALU Unit
import lc_pkg::*;

module lc_alu #(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0]    op_a_i,
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0]    op_b_i,
    input lc_pkg::lc_alu_op_T                   alu_op_i,

    output logic [g_LC_CONFIG.DATA_WIDTH-1:0]   alu_result_o,
    output logic                                eq_o,    // op_a == op_b
    output logic                                lt_o,    // op_a <  op_b, signed
    output logic                                ltu_o    // op_a <  op_b, unsigned
);
    assign eq_o = (op_a_i == op_b_i);
    assign lt_o = signed'(op_a_i) < signed'(op_b_i);
    assign ltu_o = op_a_i < op_b_i;

    always_comb begin
        case(alu_op_i)
            ALU_ADD: alu_result_o = op_a_i + op_b_i;
            ALU_SUB: alu_result_o = op_a_i - op_b_i;
            ALU_SLL: alu_result_o = op_a_i << op_b_i[4:0];
            ALU_SLT: alu_result_o = {{(g_LC_CONFIG.DATA_WIDTH-1){1'b0}}, lt_o};
            ALU_SLTU: alu_result_o = {{(g_LC_CONFIG.DATA_WIDTH-1){1'b0}}, ltu_o};
            ALU_XOR: alu_result_o = op_a_i ^ op_b_i;
            ALU_SRL: alu_result_o = op_a_i >> op_b_i[4:0];
            ALU_SRA: alu_result_o = signed'(op_a_i) >>> op_b_i[4:0];
            ALU_OR: alu_result_o = op_a_i | op_b_i;
            ALU_AND: alu_result_o = op_a_i & op_b_i;
            default: alu_result_o = '0;
        endcase
    end
endmodule
