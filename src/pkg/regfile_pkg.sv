package regfile_pkg;
    import global_pkg :: ADDR_W;
    import global_pkg :: DATA_W;
    import global_pkg :: NUM_CH;
    import global_pkg :: CH_IDX_W;

    localparam int OFS_W   = 8;
    localparam int MSB_POS = CH_IDX_W + OFS_W;

    localparam logic [7:0] OFS_CTRL   = 8'h00;
    localparam logic [7:0] OFS_STATUS = 8'h04;
    localparam logic [7:0] OFS_SRC    = 8'h08;
    localparam logic [7:0] OFS_DST    = 8'h0C;
    localparam logic [7:0] OFS_XFER   = 8'h10;
    
    typedef struct packed {
        logic [29:0] reserved;
        logic        irq_enable;
        logic        enable;
    } global_ctrl_t;

    typedef struct packed {
        logic [27:0] reserved;
        logic        error;
        logic        irq;
        logic        done;
        logic        busy;
    } global_status_t;
    
    typedef struct {
        global_ctrl_t   ctrl;
        global_status_t status;
    } global_regs_t;
    
    typedef struct packed {
        logic [28:0] reserved;
        logic        irq_enable;
        logic        start;
        logic        enable;
    } channel_ctrl_t;
    
    typedef struct packed {
        logic [27:0] reserved;
        logic        error;
        logic        irq;
        logic        done;
        logic        busy;
    } channel_status_t;

    typedef struct {
        channel_ctrl_t     ctrl;
        channel_status_t   status;
        logic [DATA_W-1:0] src;
        logic [DATA_W-1:0] dst;
        logic [DATA_W-1:0] xfer;
    } channel_regs_t;

    typedef enum logic [1:0] {
        SUCCESS,
        INVALID_ADDRESS,
        READ_ONLY,
        WRITE_PROTECTED
    } regfile_resp_t;    
endpackage
