interface memory_if;
    import global_pkg :: ADDR_W;
    import global_pkg :: DATA_W;
    import memory_pkg :: memory_resp_t;    

    logic [ADDR_W-1:0] w_addr;
    logic [DATA_W-1:0] w_data;
    logic              w_valid;
    logic              w_ready;

    memory_resp_t      w_resp;
    logic              w_resp_valid;
    logic              w_resp_ready;

    logic [ADDR_W-1:0] r_addr;
    logic              r_valid;
    logic              r_ready;

    memory_resp_t      r_resp;
    logic [DATA_W-1:0] r_data;
    logic              r_resp_valid;
    logic              r_resp_ready;

    modport adapter (
        output w_addr,
        output w_data,
        output w_valid,
        input  w_ready,

        input  w_resp,
        input  w_resp_valid,
        output w_resp_ready,

        output r_addr,
        output r_valid,
        input  r_ready,

        input  r_resp,
        output r_data,
        input  r_resp_valid,
        output r_resp_ready
    );

    modport memory (
        input  w_addr,
        input  w_data,
        input  w_valid,
        output w_ready,

        output w_resp,
        output w_resp_valid,
        input  w_resp_ready,

        input  r_addr,
        input  r_valid,
        output r_ready,

        output r_resp,
        output r_data,
        output r_resp_valid,
        input  r_resp_ready
    );
endinterface
