package config_path_tb_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg      :: *;
    import global_pkg   :: *;
    import axi_pkg      :: *;
    import regfile_pkg  :: *;

    `include "./uvm/user/user_req_item.sv"
    `include "./uvm/user/user_resp_item.sv"
    `include "./uvm/axi4lite/axi4lite_req_item.sv"
    `include "./uvm/axi4lite/axi4lite_resp_item.sv"
    `include "./uvm/adapter/adapter_req_item.sv"
    `include "./uvm/adapter/adapter_resp_item.sv"
    `include "./uvm/regfile/regfile_req_item.sv"
    `include "./uvm/regfile/regfile_resp_item.sv"

    `include "./uvm/user/user_req_sequence.sv"
    `include "./uvm/regfile/regfile_resp_sequence.sv"

    `include "./uvm/user/user_sequencer.sv"
    `include "./uvm/regfile/regfile_sequencer.sv"

    `include "./uvm/user/user_driver_config.sv"
    `include "./uvm/regfile/regfile_driver_config.sv"

    `include "./uvm/user/user_driver.sv"
    `include "./uvm/regfile/regfile_driver.sv"
    
    `include "./uvm/user/user_monitor.sv"
    `include "./uvm/axi4lite/axi4lite_monitor.sv"
    `include "./uvm/adapter/adapter_monitor.sv"
    `include "./uvm/regfile/regfile_monitor.sv"

    `include "./uvm/user/user_agent.sv"
    `include "./uvm/regfile/regfile_agent.sv"

    `include "./uvm/config_path/config_path_scoreboard.sv"

    `include "./uvm/config_path/config_path_env.sv"

    `include "./uvm/config_path/config_path_test.sv"
endpackage