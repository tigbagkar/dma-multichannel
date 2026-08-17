module placeholder_tb;
    logic clk;
    logic rst_n;

    user_config_if user_if ();
    user_irq_if    irq_if  ();

    top dut (
        .clk  (clk),
        .rst_n(rst_n),
        .user (user_if),
        .irq  (irq_if)
    );
endmodule
