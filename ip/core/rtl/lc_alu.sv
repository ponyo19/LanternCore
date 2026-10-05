// ALU Unit
import lc_pkg::*;

module lc_alu #(
    parameter lc_config_T LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input logic [LC_CONFIG.DATA_WIDTH-1:0]      i_op_a,
    input logic [LC_CONFIG.DATA_WIDTH-1:0]      i_op_b,
    input lc_pkg::lc_alu_op_T                   i_alu_op,

    output logic [LC_CONFIG.DATA_WIDTH-1:0]     o_alu_result,
    output logic                                o_eq,    // op_a == op_b
    output logic                                o_lt,    // op_a <  op_b, signed
    output logic                                o_ltu    // op_a <  op_b, unsigned
);

    assign o_alu_result    = '0;
    assign o_eq            = '0;
    assign o_lt            = '0;
    assign o_ltu           = '0;

endmodule