module top(
    input logic clk,
    input logic rst_n,
    user_config_if .axi4lite_master user,
    user_irq_if    .source          irq
);
    regfile_config_if       regfile_config_if_inst ();
    transfer_engine_axi4_if transfer_engine_axi4_if_inst ();

    config_path config_path_inst (
        .clk(clk),
        .rst_n(rst_n),
        .user(user),
        .regfile(regfile_config_if_inst)
    );

    dma_core dma_core_inst (
        .clk(clk),
        .rst_n(rst_n),
        .regfile(regfile_config_if_inst),
        .irq(irq),
        .axi(transfer_engine_axi4_if_inst)
    );

    data_path data_path_inst (
        .clk(clk),
        .rst_n(rst_n),
        .transfer_engine(transfer_engine_axi4_if_inst)
    );
endmodule
