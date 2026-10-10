// ALU Unit
import lc_pkg::*;

module lc_alu #(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0]    i_op_a,
    input logic [g_LC_CONFIG.DATA_WIDTH-1:0]    i_op_b,
    input lc_pkg::lc_alu_op_T                   i_alu_op,

    output logic [g_LC_CONFIG.DATA_WIDTH-1:0]   o_alu_result,
    output logic                                o_eq,    // op_a == op_b
    output logic                                o_lt,    // op_a <  op_b, signed
    output logic                                o_ltu    // op_a <  op_b, unsigned
);
    assign o_eq = (i_op_a == i_op_b);
    assign o_lt = signed'(i_op_a) < signed'(i_op_b);
    assign o_ltu = i_op_a < i_op_b;

    always_comb begin
        case(i_alu_op)
            ALU_ADD: o_alu_result = i_op_a + i_op_b;
            ALU_SUB: o_alu_result = i_op_a - i_op_b;
            ALU_SLL: o_alu_result = i_op_a << i_op_b[4:0];
            ALU_SLT: o_alu_result = {{(g_LC_CONFIG.DATA_WIDTH-1){1'b0}}, o_lt};
            ALU_SLTU: o_alu_result = {{(g_LC_CONFIG.DATA_WIDTH-1){1'b0}}, o_ltu};
            ALU_XOR: o_alu_result = i_op_a ^ i_op_b;
            ALU_SRL: o_alu_result = i_op_a >> i_op_b[4:0];
            ALU_SRA: o_alu_result = signed'(i_op_a) >>> i_op_b[4:0];
            ALU_OR: o_alu_result = i_op_a | i_op_b;
            ALU_AND: o_alu_result = i_op_a & i_op_b;
            default: o_alu_result = '0;
        endcase
    end
endmodule