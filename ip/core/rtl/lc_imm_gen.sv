// Immediate generator unit
module lc_imm_gen (
    input  logic [31:0]   instr_i,
    output logic [31:0]   imm_o
);

logic [6:0] opcode;
logic [2:0] funct3;
assign opcode = instr_i[6:0];
assign funct3 = instr_i[14:12];

always_comb begin
    case (opcode)
        7'b0010111, 7'b0110111:            
            // LUI, AUIPC
            imm_o = {instr_i[31:12], 12'b0};

        7'b1101111:            
            // JAL
            imm_o = {{12{instr_i[31]}}, {instr_i[19:12]}, {instr_i[20]}, {instr_i[30:21]}, 1'b0};

        7'b1100011:            
            imm_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};

        7'b1100111, 7'b0000011: 
            // JALR, LOAD
            imm_o = {{20{instr_i[31]}}, instr_i[31:20]};

        7'b0100011:            
            // STORE
            imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            
        7'b0010011: 
            if (funct3 == 3'b001 || funct3 == 3'b101)     
                // SLLI, SRLI, SRAI
                imm_o = {27'b0, instr_i[24:20]};
            else                                         
                // ADDI, SLTI[U], ANDI, ORI, XORI                                                                
                imm_o = {{20{instr_i[31]}}, instr_i[31:20]};

        default:
            imm_o = 32'b0;
    endcase
end
endmodule
