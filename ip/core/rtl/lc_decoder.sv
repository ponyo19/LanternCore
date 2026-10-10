// Decoder Unit
import lc_pkg::*;

module lc_decoder #(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
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

lc_imm_gen imm_gen (
    .i_instr(i_instr),
    .o_imm(o_imm)
);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
assign opcode = i_instr[6:0];
assign funct3 = i_instr[14:12];
assign funct7 = i_instr[31:25];

always_comb begin
    o_rs1_addr = i_instr[19:15];
    o_rs2_addr = i_instr[24:20];
    o_rd_addr = i_instr[11:7];

    o_alu_op = ALU_ADD; 
    o_op_a_sel = OPA_ZERO;
    o_op_b_sel = OPB_IMM;

    o_wb_sel = WB_ALU; 
    o_rd_we = 1'b0; 

    o_mem_size = funct3[1:0];
    o_mem_unsigned = funct3[2];
    o_mem_re = 1'b0; 
    o_mem_we = 1'b0; 

    o_branch_cond = i_instr[14:12];
    o_branch = 1'b0; 
    o_jal = 1'b0;
    o_jalr = 1'b0;

    o_fence = 1'b0; 
    o_ecall = 1'b0; 
    o_ebreak = 1'b0;
    o_illegal = 1'b0;

    case (opcode) 
        7'b0110111: begin    //LUI
            o_rd_we = 1'b1;
        end

        7'b0010111: begin     //AUIPC
            o_op_a_sel = OPA_PC;
            o_rd_we = 1'b1;
        end
     
        7'b1101111: begin     //JAL
            o_jal = 1'b1;
            o_op_a_sel = OPA_PC;
            o_wb_sel = WB_PC4;
            o_rd_we = 1'b1;
        end
        
        7'b1100111: begin    //JALR
            if (funct3 == 3'b0) begin
                o_jalr = 1'b1;
                o_op_a_sel = OPA_RS1;
                o_wb_sel = WB_PC4;
                o_rd_we = 1'b1;
            end 

            else begin
                o_illegal = 1'b1;
            end
        end
        
        7'b1100011: begin    //BRANCH
            if (funct3 != 3'b010 && funct3 != 3'b011) begin
                o_alu_op = ALU_SUB;
                o_op_a_sel = OPA_RS1;
                o_op_b_sel = OPB_RS2;
                o_branch = 1'b1;
            end

            else begin
                o_illegal = 1'b1;
            end
        end
        
        7'b0000011: begin     //LOAD
            case (funct3)
                3'b000, 3'b001, 3'b010, 3'b100, 3'b101: begin
                    o_alu_op = ALU_ADD;
                    o_wb_sel = WB_MEM;
                    o_op_a_sel = OPA_RS1;
                    o_rd_we = 1'b1;
                    o_mem_re = 1'b1;
                end
                default: 
                    o_illegal = 1'b1;
            endcase
        end

        7'b0100011: begin     //STORE
            case (funct3) 
                3'b000, 3'b001, 3'b010: begin
                    o_alu_op = ALU_ADD;
                    o_op_a_sel = OPA_RS1;
                    o_mem_we = 1'b1;  
                end
                default: o_illegal = 1'b1;
            endcase

        end

        7'b0010011: begin    //RS1 & IMM
            case (funct3) 
                3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: begin
                    o_alu_op = {1'b0, funct3};
                    o_wb_sel = WB_ALU;
                    o_op_a_sel = OPA_RS1;
                    o_rd_we = 1'b1;
                end
                
                3'b001: begin     //SLLI
                    if (funct7 == 7'b0) begin
                        o_alu_op = {i_instr[30], funct3};
                        o_wb_sel = WB_ALU;
                        o_op_a_sel = OPA_RS1;
                        o_rd_we = 1'b1;
                    end 
                    
                    else begin
                        o_illegal = 1'b1;
                    end
                end

                3'b101: begin     //SRLI, SRAI
                    if (funct7 == 7'b0100000 || funct7 == 7'b0) begin
                        o_alu_op = {i_instr[30], funct3};
                        o_wb_sel = WB_ALU;
                        o_op_a_sel = OPA_RS1;
                        o_rd_we = 1'b1;  
                    end 
                    
                    else begin
                        o_illegal = 1'b1;
                    end
                end
            endcase  
        end   
        
        7'b0110011: begin    // RS1 & RS2
            case (funct7)
                7'b0: begin 
                    o_alu_op = {i_instr[30], funct3};
                    o_wb_sel = WB_ALU;
                    o_op_a_sel = OPA_RS1;
                    o_op_b_sel = OPB_RS2;
                    o_rd_we = 1'b1;
                end
                7'b0100000: begin
                    if (funct3 == 3'b000 || funct3 == 3'b101) begin
                        o_alu_op = {i_instr[30], funct3};
                        o_wb_sel = WB_ALU;
                        o_op_a_sel = OPA_RS1;
                        o_op_b_sel = OPB_RS2;
                        o_rd_we = 1'b1;
                    end
                    else begin
                        o_illegal = 1'b1;
                    end
                end
                default: o_illegal = 1'b1;
            endcase
        end
        
        7'b0001111: begin    // FENCE
            o_fence = 1'b1;
        end
        
        7'b1110011: begin    // EBREAK, ECALL
            o_ebreak = 1'b1;
        end
        
        default:
            o_illegal = 1'b1;
    endcase
end
endmodule