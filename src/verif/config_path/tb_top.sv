`timescale 1ns/1ps

module tb_top;

    import uvm_pkg :: *;
    `include "uvm_macros.svh"
    import config_path_tb_pkg :: *;
    
    logic clk = 1'b0;
    always #5 clk = ~clk; // 100 MHz

    clk_rst_if        clk_rst_vif (.clk(clk));
    user_config_if    user_vif ();
    regfile_config_if regfile_vif ();

    config_path dut (
        .clk     (clk),
        .rst_n   (clk_rst_vif.rst_n),
        .user    (user_vif),
        .regfile (regfile_vif)
    );

    initial begin
        clk_rst_vif.rst_n = 1'b0;
        repeat (5) @(posedge clk);
        clk_rst_vif.rst_n = 1'b1;
    end

    initial begin
        uvm_config_db #(virtual clk_rst_if)::set(null, "*", "clk_vif", clk_rst_vif);

        uvm_config_db #(virtual user_config_if)::set(
            null, "uvm_test_top.env.user_agent_inst.driver", "vif", user_vif);
        uvm_config_db #(virtual user_config_if)::set(
            null, "uvm_test_top.env.user_agent_inst.monitor", "vif", user_vif);

        uvm_config_db #(virtual regfile_config_if)::set(
            null, "uvm_test_top.env.regfile_agent_inst.driver", "vif", regfile_vif);
        uvm_config_db #(virtual regfile_config_if)::set(
            null, "uvm_test_top.env.regfile_agent_inst.monitor", "vif", regfile_vif);

        run_test();
    end
endmodule