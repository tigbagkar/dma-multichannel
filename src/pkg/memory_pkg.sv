package memory_pkg;
    localparam int MEM_SIZE_W = 10;
    localparam int MEM_SIZE   = 2**MEM_SIZE_W;

    typedef enum logic [0:0] {
        SUCCESS         = 1'b0,
        INVALID_ADDRESS = 1'b1
    } memory_resp_t;
endpackage
