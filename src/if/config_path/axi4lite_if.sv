interface axi4lite_if;
    import global_pkg :: ADDR_W;
    import global_pkg :: DATA_W;
    import global_pkg :: STRB_W;
    import axi_pkg    :: axi_resp_t;

    logic [ADDR_W-1:0] aw_addr;
    logic [2:0]        aw_prot; 
    logic              aw_valid;
    logic              aw_ready;

    logic [DATA_W-1:0] w_data;
    logic [STRB_W-1:0] w_strb;
    logic              w_valid;
    logic              w_ready;

    axi_resp_t         b_resp;
    logic              b_valid;
    logic              b_ready;

    logic [ADDR_W-1:0] ar_addr;
    logic [2:0]        ar_prot; 
    logic              ar_valid;
    logic              ar_ready;

    logic [DATA_W-1:0] r_data;
    axi_resp_t         r_resp;
    logic              r_valid;
    logic              r_ready;

    modport master (
        output aw_addr,
        output aw_prot,
        output aw_valid,
        input  aw_ready,
        
        output w_data,
        output w_strb,
        output w_valid,
        input  w_ready,
        
        input  b_resp,
        input  b_valid,
        output b_ready,
        
        output ar_addr,
        output ar_prot,
        output ar_valid,
        input  ar_ready,
        
        input  r_data,
        input  r_resp,
        input  r_valid,
        output r_ready
    );

    modport slave (
        input  aw_addr,
        input  aw_prot,
        input  aw_valid,
        output aw_ready,
        
        input  w_data,
        input  w_strb,
        input  w_valid,
        output w_ready,
        
        output b_resp,
        output b_valid,
        input  b_ready,
        
        input  ar_addr,
        input  ar_prot,
        input  ar_valid,
        output ar_ready,
        
        output r_data,
        output r_resp,
        output r_valid,
        input  r_ready
    );
endinterface 
