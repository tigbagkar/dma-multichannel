interface transfer_engine_axi4_if;
    import global_pkg :: ADDR_W;
    import global_pkg :: DATA_W;
    import global_pkg :: STRB_W;
    import axi_pkg    :: axi_resp_t;
    
    logic [0:0]        w_id;
    logic [ADDR_W-1:0] w_addr;
    logic [7:0]        w_len;
    logic [2:0]        w_size;
    logic [2:0]        w_burst;
    logic [0:0]        w_lock;
    logic [3:0]        w_cache;
    logic [2:0]        w_prot;
    logic [3:0]        w_qos;
    logic [3:0]        w_region;
    logic              w_addr_valid;
    logic              w_addr_ready;

    logic [DATA_W-1:0] w_data;
    logic [STRB_W-1:0] w_strb;
    logic              w_last;
    logic              w_data_valid;
    logic              w_data_ready;

    logic [0:0]        w_resp_id;      
    axi_resp_t         w_resp;
    logic              w_resp_valid;
    logic              w_resp_ready;

    logic [0:0]        r_id;
    logic [ADDR_W-1:0] r_addr;
    logic [7:0]        r_len;
    logic [2:0]        r_size;
    logic [2:0]        r_burst;
    logic [0:0]        r_lock;
    logic [3:0]        r_cache;
    logic [2:0]        r_prot; 
    logic [3:0]        r_qos;  
    logic [3:0]        r_region;
    logic              r_valid;
    logic              r_ready;

    logic [0:0]        r_resp_id;
    logic [DATA_W-1:0] r_data;
    axi_resp_t         r_resp;
    logic              r_last;
    logic              r_resp_valid;
    logic              r_resp_ready;

    modport transfer_engine (
        output w_id,
        output w_addr,
        output w_len,
        output w_size,
        output w_burst,
        output w_lock,
        output w_cache,
        output w_prot,
        output w_qos,
        output w_region,
        output w_addr_valid,
        input  w_addr_ready,

        output w_data,
        output w_strb,
        output w_last,
        output w_data_valid,
        input  w_data_ready,

        input  w_resp_id,      
        input  w_resp,
        input  w_resp_valid,
        output w_resp_ready,

        output r_id,
        output r_addr,
        output r_len,
        output r_size,
        output r_burst,
        output r_lock,
        output r_cache,
        output r_prot, 
        output r_qos,  
        output r_region,
        output r_valid,
        input  r_ready,

        input  r_resp_id,
        input  r_data,
        input  r_resp,
        input  r_last,
        input  r_resp_valid,
        output r_resp_ready
    );
    
    modport axi4_master (
        input  w_id,
        input  w_addr,
        input  w_len,
        input  w_size,
        input  w_burst,
        input  w_lock,
        input  w_cache,
        input  w_prot,
        input  w_qos,
        input  w_region,
        input  w_addr_valid,
        output w_addr_ready,

        input  w_data,
        input  w_strb,
        input  w_last,
        input  w_data_valid,
        output w_data_ready,

        output w_resp_id,      
        output w_resp,
        output w_resp_valid,
        input  w_resp_ready,

        input  r_id,
        input  r_addr,
        input  r_len,
        input  r_size,
        input  r_burst,
        input  r_lock,
        input  r_cache,
        input  r_prot, 
        input  r_qos,  
        input  r_region,
        input  r_valid,
        output r_ready,

        output r_resp_id,
        output r_data,
        output r_resp,
        output r_last,
        output r_resp_valid,
        input  r_resp_ready
    );
endinterface
