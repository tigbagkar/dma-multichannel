import global_pkg :: NUM_CH;

module dma_core (
    input logic                              clk,
    input logic                              rst_n,
    regfile_config_if       .regfile         regfile,
    user_irq_if             .source          irq,
    transfer_engine_axi4_if .transfer_engine axi  
);
    channels_if        channels_if_inst ();
    arbiter_if         arbiter_if_inst ();
    transfer_engine_if transfer_engine_if_inst ();

    regfile regfile_instance (
        .clk(clk),
        .rst_n(rst_n),
        .config_source(regfile),
        .channels(channels_if_inst),
        .irq_out(irq)
    );

    genvar ch;
    generate
        for (ch = 0; ch < NUM_CH; ch++) begin
            channel #(
                .CH_ID(ch)
            ) channel_inst (
                .clk(clk),
                .rst_n(rst_n),
                .regfile(channels_if_inst),
                .arbiter(arbiter_if_inst)
            );
        end
    endgenerate

    arbiter arbiter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .channels(arbiter_if_inst),
        .transfer_engine(transfer_engine_if_inst)
    );

    transfer_engine transfer_engine_inst (
        .clk(clk),
        .rst_n(rst_n),
        .arbiter(transfer_engine_if_inst),
        .axi(axi)
    );
endmodule
