interface user_config_if;
    import global_pkg :: ADDR_W;
    import global_pkg :: DATA_W;
    import global_pkg :: STRB_W;
    import axi_pkg    :: axi_resp_t;
    
    logic [ADDR_W-1:0] w_addr;
    logic [2:0]        w_prot; 
    logic              w_addr_valid;
    logic              w_addr_ready;
    
    logic [DATA_W-1:0] w_data;
    logic [STRB_W-1:0] w_strb;
    logic              w_data_valid;
    logic              w_data_ready;
    
    axi_resp_t         w_resp;
    logic              w_resp_valid;
    logic              w_resp_ready;
    
    logic [ADDR_W-1:0] r_addr;
    logic [2:0]        r_prot; 
    logic              r_valid;
    logic              r_ready;
    
    logic [DATA_W-1:0] r_data;
    axi_resp_t         r_resp;
    logic              r_resp_valid;
    logic              r_resp_ready;

    modport user (
        output w_addr,
        output w_prot,
        output w_addr_valid,
        input  w_addr_ready,
        
        output w_data,
        output w_strb,
        output w_data_valid,
        input  w_data_ready,
        
        input  w_resp,
        input  w_resp_valid,
        output w_resp_ready,
        
        output r_addr,
        output r_prot,
        output r_valid,
        input  r_ready,
        
        input  r_data,
        input  r_resp,
        input  r_resp_valid,
        output r_resp_ready
    );

    modport axi4lite_master (
        input  w_addr,
        input  w_prot,
        input  w_addr_valid,
        output w_addr_ready,
        
        input  w_data,
        input  w_strb,
        input  w_data_valid,
        output w_data_ready,
        
        output w_resp,
        output w_resp_valid,
        input  w_resp_ready,
        
        input  r_addr,
        input  r_prot,
        input  r_valid,
        output r_ready,
        
        output r_data,
        output r_resp,
        output r_resp_valid,
        input  r_resp_ready
    );
endinterface 
