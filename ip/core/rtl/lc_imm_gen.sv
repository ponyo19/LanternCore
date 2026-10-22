// Immediate generator unit
module lc_imm_gen (
    input  logic [31:0]   i_instr,
    output logic [31:0]   o_imm
);

logic [6:0] opcode;
logic [2:0] funct3;
assign opcode = i_instr[6:0];
assign funct3 = i_instr[14:12];

always_comb begin
    case (opcode)
        7'b0010111, 7'b0110111:            
            // LUI, AUIPC
            o_imm = {i_instr[31:12], 12'b0};                                                          

        7'b1101111:            
            // JAL
            o_imm = {{12{i_instr[31]}}, {i_instr[19:12]}, {i_instr[20]}, {i_instr[30:21]}, 1'b0};     

        7'b1100011:            
            o_imm = {{19{i_instr[31]}}, i_instr[31], i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};

        7'b1100111, 7'b0000011: 
            // JALR, LOAD
            o_imm = {{20{i_instr[31]}}, i_instr[31:20]};                                              

        7'b0100011:            
            // STORE
            o_imm = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};                               
            
        7'b0010011: 
            if (funct3 == 3'b001 || funct3 == 3'b101)     
                // SLLI, SRLI, SRAI
                o_imm = {27'b0, i_instr[24:20]};                                                             
            else                                         
                // ADDI, SLTI[U], ANDI, ORI, XORI                                                                
                o_imm = {{20{i_instr[31]}}, i_instr[31:20]};

        default:
            o_imm = 32'b0;
    endcase
end
endmodule
