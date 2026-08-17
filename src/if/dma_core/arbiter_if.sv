interface arbiter_if;
    import global_pkg :: DATA_W;
    import global_pkg :: NUM_CH;

    logic              descriptor_valid [NUM_CH-1:0];
    logic              descriptor_ready [NUM_CH-1:0];
    logic [DATA_W-1:0] src        [NUM_CH-1:0];
    logic [DATA_W-1:0] dst        [NUM_CH-1:0];
    logic [DATA_W-1:0] xfer       [NUM_CH-1:0];

    logic              complete_valid [NUM_CH-1:0];
    logic              complete_ready [NUM_CH-1:0];
    logic              done       [NUM_CH-1:0];
    logic              error      [NUM_CH-1:0];

    modport channel (
        output descriptor_valid,
        input  descriptor_ready,
        output src,
        output dst,
        output xfer,

        input  complete_valid,
        output complete_ready,
        input  done,
        input  error
    );

    modport arbiter (
        input  descriptor_valid,
        output descriptor_ready,
        input  src,
        input  dst,
        input  xfer,

        output complete_valid,
        input  complete_ready,
        output done,
        output error
    );
endinterface
