// Packages and structs
package lc_pkg;

    typedef struct packed {
        int unsigned DATA_WIDTH;
    } lc_config_T;

    typedef enum logic [3:0] {   // {funct7[5], funct3}
    ALU_ADD  = 4'b0000,  ALU_SUB = 4'b1000,
    ALU_SLL  = 4'b0001,  ALU_SLT = 4'b0010,
    ALU_SLTU = 4'b0011,  ALU_XOR = 4'b0100,
    ALU_SRL  = 4'b0101,  ALU_SRA = 4'b1101,
    ALU_OR   = 4'b0110,  ALU_AND = 4'b0111
    } lc_alu_op_T;

    typedef enum logic [1:0] {
        OPA_RS1     = 2'b00, 
        OPA_PC      = 2'b01,
        OPA_ZERO    = 2'b10
    } lc_alu_op_a_sel_T;

    typedef enum logic [0:0] { 
        OPB_RS2     = 1'b0,
        OPB_IMM     = 1'b1
    } lc_alu_op_b_sel_T;

    typedef enum logic [1:0] {
        MEM_B       = 2'b00,
        MEM_H       = 2'b01,
        MEM_W       = 2'b10
    } lc_mem_size_T;

    typedef enum logic [1:0] {
        WB_ALU      = 2'b00,
        WB_MEM      = 2'b01,
        WB_PC4      = 2'b10
    } lc_wb_sel_T;

endpackage