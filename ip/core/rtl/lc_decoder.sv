// Decoder Unit
import lc_pkg::*;

module lc_decoder #(
    parameter lc_config_T LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input  logic [31:0]   i_instr,

    output logic [4:0]    o_rs1_addr, o_rs2_addr, o_rd_addr,
    output logic          o_rd_we,
    output logic [31:0]   o_imm,          // sign-extended, correct format per instruction

    output lc_alu_op_T    o_alu_op,
    output lc_alu_op_a_sel_T  o_op_a_sel,     // OPA_RS1 | OPA_PC | OPA_ZERO
    output lc_alu_op_b_sel_T  o_op_b_sel,     // OPB_RS2 | OPB_IMM

    output logic          o_mem_re, o_mem_we,
    output lc_mem_size_T  o_mem_size,     // MEM_B | MEM_H | MEM_W
    output logic          o_mem_unsigned,

    output lc_wb_sel_T    o_wb_sel,       // WB_ALU | WB_MEM | WB_PC4

    output logic          o_branch,
    output logic [2:0]    o_branch_cond,  // funct3 of the branch
    output logic          o_jal, o_jalr,

    output logic          o_fence, o_ecall, o_ebreak,
    output logic          o_illegal
);
    
endmodule