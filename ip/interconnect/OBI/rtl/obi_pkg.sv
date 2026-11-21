package obi_pkg;

  parameter INSTR_ADDR_WIDTH = 32;
  parameter INSTR_DATA_WIDTH = 32;
  parameter DATA_ADDR_WIDTH  = 32;
  parameter DATA_DATA_WIDTH  = 32;

  typedef struct packed {

  } obi_cfg_T;

  // Handshake signals
  typedef struct packed {
    logic        req;
  } obi_req_T;

  typedef struct packed {
    logic        gnt;
  } obi_gnt_T;

  typedef struct packed {
    logic        rvalid;
  } obi_rvalid_T;

  // Instruction bus payloads (read-only)
  typedef struct packed {
    logic [INSTR_ADDR_WIDTH-1:0] addr;
  } obi_inst_req_T;

  typedef struct packed {
    logic [INSTR_DATA_WIDTH-1:0] rdata;
    logic                        err;
  } obi_inst_resp_T;

  // Data bus payloads
  typedef struct packed {
    logic [DATA_ADDR_WIDTH-1:0]     addr;
    logic                           we;
    logic [(DATA_DATA_WIDTH/8)-1:0] be;
    logic [DATA_DATA_WIDTH-1:0]     wdata;
  } obi_data_req_T;

  typedef struct packed {
    logic [DATA_DATA_WIDTH-1:0] rdata;
    logic                       err;
  } obi_data_resp_T;

  // Reset values
  parameter obi_inst_req_T OBI_INST_REQ_RESET_VAL = '{addr: '0};
  parameter obi_data_req_T OBI_DATA_REQ_RESET_VAL = '{addr: '0, we: 1'b0, be: '0, wdata: '0};

endpackage