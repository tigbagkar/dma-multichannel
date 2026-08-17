module config_path (
    input logic                        clk,
    input logic                        rst_n,
    user_config_if    .axi4lite_master user,
    regfile_config_if .config_source   regfile
);
    axi4lite_if         axi4lite_if_inst ();
    axi4lite_adapter_if axi4lite_adapter_if_inst ();

    axi4lite_master axi4lite_master_inst (
        .clk    (clk),
        .rst_n  (rst_n),
        .user   (user),
        .axi    (axi4lite_if_inst)
    );

    axi4lite_slave axi4lite_slave_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .axi     (axi4lite_if_inst),
        .adapter (axi4lite_adapter_if_inst)
    );

    axi4lite_adapter axi4lite_adapter_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .slave   (axi4lite_adapter_if_inst),
        .regfile (regfile)
    );
endmodule
