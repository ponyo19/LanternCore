// OBI Interface

interface obi_if import obi_pkg::*; #(
    // Default to instruction bus
    parameter REQ_TYPE = obi_inst_req_t,
    parameter RESP_TYPE = obi_inst_resp_t;
);
    // Decouple handshake signals from payloads
    // A Channel
    obi_req_t       req;

    obi_gnt_t       gnt;
    REQ_TYPE        req_payload;

    // R Channel
    obi_rvalid_t    rvalid;
    RESP_TYPE       resp_payload;

    modport manager_if (
        input gnt, rvalid, resp_payload,
        output req, req_payload
    );

    modport subordinate_if (
        input req, req_payload,
        output gnt, rvalid, resp_payload
    );
    
endinterface: obi_if