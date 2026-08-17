module data_path(
    input logic clk,
    input logic rst_n,
    transfer_engine_axi4_if .axi4_master transfer_engine
);
    axi4_if           axi4_if_inst ();
    memory_adapter_if memory_adapter_if_inst ();
    memory_if         memory_if_inst ();    

    axi4_master axi4_master_inst (
        .clk(clk),
        .rst_n(rst_n),
        .transfer_engine(transfer_engine),
        .axi(axi4_if_inst)
    );
    
    axi4_slave axi4_slave_inst (
        .clk(clk),
        .rst_n(rst_n),
        .axi(axi4_if_inst),
        .adapter(memory_adapter_if_inst)
    );

    memory_adapter memory_adapter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .slave(memory_adapter_if_inst),
        .memory(memory_if_inst)
    );

    memory memory_inst (
        .clk(clk),
        .rst_n(rst_n),
        .adapter(memory_if_inst)
    );
endmodule
