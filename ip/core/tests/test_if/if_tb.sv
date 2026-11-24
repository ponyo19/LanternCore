module if_tb 
    import lc_pkg::*;
    import obi_pkg::*;
#(
    parameter ROM_FILE = "test_rom.hex",
    parameter ROM_SIZE = 256
)(
    input logic clk_i,
    input logic rst_ni,
    input logic re_i,

    input  logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0 ] pc_i,
    output logic [LC_CONFIG_DEFAULT.DATA_WIDTH-1:0 ] instr_o,

    output logic done_o, err_o
);

logic req, gnt, rvalid;
obi_inst_req_t req_payload;
obi_inst_resp_t resp_payload;

lc_if if_u (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .re_i(re_i),
    .pc_i(pc_i),
    .instr_o(instr_o),
    .done_o(done_o),
    .err_o(err_o),
    .gnt(gnt),
    .rvalid(rvalid),
    .req(req),
    .resp_payload(resp_payload),
    .req_payload(req_payload)
);

lc_pc_rom #(
    .ROM_FILE(ROM_FILE),
    .ROM_SIZE(ROM_SIZE)
) rom_u (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .req(req),
    .gnt(gnt),
    .rvalid(rvalid),
    .req_payload(req_payload),
    .resp_payload(resp_payload)
);
endmodule
