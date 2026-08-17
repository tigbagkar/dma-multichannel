interface transfer_engine_if;
    import global_pkg :: DATA_W;
    import global_pkg :: NUM_CH;
    import global_pkg :: CH_IDX_W;
    
    logic [CH_IDX_W-1:0] ch_id;
    logic [DATA_W-1:0]   src;
    logic [DATA_W-1:0]   dst;
    logic [DATA_W-1:0]   xfer;
    logic                grant_valid;       
    logic                grant_ready;
    
    logic                transfer_done;
    logic                burst_done;
    logic                error;
    logic                complete_valid;
    logic                complete_ready;

    modport arbiter (
        output ch_id,
        output src,
        output dst,
        output xfer,
        output grant_valid,
        input  grant_ready,
        
        input  transfer_done,
        input  burst_done,
        input  error,
        input  complete_valid,
        output complete_ready
    );

    modport transfer_engine (
        input  ch_id,
        input  src,
        input  dst,
        input  xfer,
        input  grant_valid,
        output grant_ready,
        
        output transfer_done,
        output burst_done,
        output error,
        output complete_valid,
        input  complete_ready
    );
endinterface
