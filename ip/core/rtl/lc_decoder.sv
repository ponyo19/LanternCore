// Decoder Unit
import lc_pkg::*;

module lc_decoder #(
    parameter lc_config_T g_LC_CONFIG = '{DATA_WIDTH: 32}
) (
    input  logic [31:0]   instr_i,

    output logic [4:0]    rs1_addr_o, rs2_addr_o, rd_addr_o,
    output logic          rd_we_o,
    output logic [31:0]   imm_o,          // sign-extended, correct format per instruction

    output lc_alu_op_T    alu_op_o,
    output lc_alu_op_a_sel_T  op_a_sel_o,     // OPA_RS1 | OPA_PC | OPA_ZERO
    output lc_alu_op_b_sel_T  op_b_sel_o,     // OPB_RS2 | OPB_IMM

    output logic          mem_re_o, mem_we_o,
    output lc_mem_size_T  mem_size_o,     // MEM_B | MEM_H | MEM_W
    output logic          mem_unsigned_o,

    output lc_wb_sel_T    wb_sel_o,       // WB_ALU | WB_MEM | WB_PC4

    output logic          branch_o,
    output logic [2:0]    branch_cond_o,  // funct3 of the branch
    output logic          jal_o, jalr_o,

    output logic          fence_o, ecall_o, ebreak_o,
    output logic          illegal_o
);

lc_imm_gen imm_gen (
    .instr_i(instr_i),
    .imm_o(imm_o)
);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
assign opcode = instr_i[6:0];
assign funct3 = instr_i[14:12];
assign funct7 = instr_i[31:25];

always_comb begin
    rs1_addr_o = instr_i[19:15];
    rs2_addr_o = instr_i[24:20];
    rd_addr_o = instr_i[11:7];

    alu_op_o = ALU_ADD;
    op_a_sel_o = OPA_ZERO;
    op_b_sel_o = OPB_IMM;

    wb_sel_o = WB_ALU;
    rd_we_o = 1'b0;

    mem_size_o = lc_mem_size_T'(funct3[1:0]);
    mem_unsigned_o = funct3[2];
    mem_re_o = 1'b0;
    mem_we_o = 1'b0;

    branch_cond_o = instr_i[14:12];
    branch_o = 1'b0;
    jal_o = 1'b0;
    jalr_o = 1'b0;

    fence_o = 1'b0;
    ecall_o = 1'b0;
    ebreak_o = 1'b0;
    illegal_o = 1'b0;

    case (opcode) 
        7'b0110111: begin    //LUI
            rd_we_o = 1'b1;
        end

        7'b0010111: begin     //AUIPC
            op_a_sel_o = OPA_PC;
            rd_we_o = 1'b1;
        end
     
        7'b1101111: begin     //JAL
            jal_o = 1'b1;
            op_a_sel_o = OPA_PC;
            wb_sel_o = WB_PC4;
            rd_we_o = 1'b1;
        end
        
        7'b1100111: begin    //JALR
            if (funct3 == 3'b0) begin
                jalr_o = 1'b1;
                op_a_sel_o = OPA_RS1;
                wb_sel_o = WB_PC4;
                rd_we_o = 1'b1;
            end 

            else begin
                illegal_o = 1'b1;
            end
        end
        
        7'b1100011: begin    //BRANCH
            if (funct3 != 3'b010 && funct3 != 3'b011) begin
                alu_op_o = ALU_SUB;
                op_a_sel_o = OPA_RS1;
                op_b_sel_o = OPB_RS2;
                branch_o = 1'b1;
            end

            else begin
                illegal_o = 1'b1;
            end
        end
        
        7'b0000011: begin     //LOAD
            case (funct3)
                3'b000, 3'b001, 3'b010, 3'b100, 3'b101: begin
                    alu_op_o = ALU_ADD;
                    wb_sel_o = WB_MEM;
                    op_a_sel_o = OPA_RS1;
                    rd_we_o = 1'b1;
                    mem_re_o = 1'b1;
                end
                default: 
                    illegal_o = 1'b1;
            endcase
        end

        7'b0100011: begin     //STORE
            case (funct3) 
                3'b000, 3'b001, 3'b010: begin
                    alu_op_o = ALU_ADD;
                    op_a_sel_o = OPA_RS1;
                    mem_we_o = 1'b1;
                end
                default: illegal_o = 1'b1;
            endcase

        end

        7'b0010011: begin    //RS1 & IMM
            case (funct3) 
                3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: begin
                    alu_op_o = lc_alu_op_T'({1'b0, funct3});
                    wb_sel_o = WB_ALU;
                    op_a_sel_o = OPA_RS1;
                    rd_we_o = 1'b1;
                end
                
                3'b001: begin     //SLLI
                    if (funct7 == 7'b0) begin
                        alu_op_o = lc_alu_op_T'({instr_i[30], funct3});
                        wb_sel_o = WB_ALU;
                        op_a_sel_o = OPA_RS1;
                        rd_we_o = 1'b1;
                    end 
                    
                    else begin
                        illegal_o = 1'b1;
                    end
                end

                3'b101: begin     //SRLI, SRAI
                    if (funct7 == 7'b0100000 || funct7 == 7'b0) begin
                        alu_op_o = lc_alu_op_T'({instr_i[30], funct3});
                        wb_sel_o = WB_ALU;
                        op_a_sel_o = OPA_RS1;
                        rd_we_o = 1'b1;
                    end 
                    
                    else begin
                        illegal_o = 1'b1;
                    end
                end
            endcase  
        end   
        
        7'b0110011: begin    // RS1 & RS2
            case (funct7)
                7'b0: begin 
                    alu_op_o = lc_alu_op_T'({instr_i[30], funct3});
                    wb_sel_o = WB_ALU;
                    op_a_sel_o = OPA_RS1;
                    op_b_sel_o = OPB_RS2;
                    rd_we_o = 1'b1;
                end
                7'b0100000: begin
                    if (funct3 == 3'b000 || funct3 == 3'b101) begin
                        alu_op_o = lc_alu_op_T'({instr_i[30], funct3});
                        wb_sel_o = WB_ALU;
                        op_a_sel_o = OPA_RS1;
                        op_b_sel_o = OPB_RS2;
                        rd_we_o = 1'b1;
                    end
                    else begin
                        illegal_o = 1'b1;
                    end
                end
                default: illegal_o = 1'b1;
            endcase
        end
        
        7'b0001111: begin    // FENCE
            if (funct3 == 3'b000) begin
                if (instr_i == 32'h8330000F)  //FENCE.TSO
                  illegal_o = 1'b1;
                else if (instr_i == 32'h0100000F)  //PAUSE
                  illegal_o = 1'b1;
                else
                  fence_o = 1'b1;
            end
            else
                illegal_o =1'b1;
        end
        
        7'b1110011: begin    // EBREAK, ECALL
            if (instr_i == 32'h00000073)
              ecall_o = 1'b1;
            else if (instr_i == 32'h00100073)
              ebreak_o = 1'b1;
            else 
              illegal_o = 1'b1;
        end
        
        default:
            illegal_o = 1'b1;
    endcase
end
endmodule
