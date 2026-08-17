package global_pkg;
    parameter  int ADDR_W = 32;
    parameter  int DATA_W = 32;
    localparam int STRB_W = DATA_W/8;

    parameter  int NUM_CH   = 4;
    localparam int CH_IDX_W = $clog2(NUM_CH);

    parameter  int MAX_BURST_LEN   = 256;
    localparam int MAX_BURST_LEN_W = $clog2(MAX_BURST_LEN);
    localparam int ADDR_INCR       = 4;
    localparam int XFER_DIV        = 4;
endpackage
