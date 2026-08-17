interface channels_if;
    import global_pkg  :: DATA_W;
    import global_pkg  :: NUM_CH;
    import regfile_pkg :: global_ctrl_t;
    import regfile_pkg :: channel_ctrl_t;
    
    global_ctrl_t      global_ctrl;
    channel_ctrl_t     channel_ctrl [NUM_CH-1:0];
    logic [DATA_W-1:0] src          [NUM_CH-1:0];
    logic [DATA_W-1:0] dst          [NUM_CH-1:0];
    logic [DATA_W-1:0] xfer         [NUM_CH-1:0];

    logic              start_clear  [NUM_CH-1:0];
    logic              busy_set     [NUM_CH-1:0];
    logic              busy_clear   [NUM_CH-1:0];
    logic              done_set     [NUM_CH-1:0];
    logic              irq_set      [NUM_CH-1:0];
    logic              error_set    [NUM_CH-1:0];
    
    modport regfile (
        output global_ctrl,
        output channel_ctrl,
        output src,
        output dst,
        output xfer,
        input  start_clear,
        input  busy_set,
        input  busy_clear,
        input  done_set,
        input  irq_set,
        input  error_set
    );
    modport channel (
        input  global_ctrl,
        input  channel_ctrl,
        input  src,
        input  dst,
        input  xfer,
        output start_clear,
        output busy_set,
        output busy_clear,
        output done_set,
        output irq_set,
        output error_set
    );
endinterface
