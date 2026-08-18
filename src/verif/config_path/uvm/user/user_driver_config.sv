class user_driver_config extends uvm_object;

    rand int unsigned min_addr_delay = 0;
    rand int unsigned max_addr_delay = 5;

    rand int unsigned min_data_delay = 0;
    rand int unsigned max_data_delay = 5;

    rand bit          split_addr_data = 1;

    rand int unsigned min_resp_ready_delay  = 0;
    rand int unsigned max_resp_ready_delay  = 5;

    `uvm_object_utils_begin (user_driver_config)
        `uvm_field_int      (min_addr_delay,        UVM_ALL_ON)
        `uvm_field_int      (max_addr_delay,        UVM_ALL_ON)
        `uvm_field_int      (min_data_delay,        UVM_ALL_ON)
        `uvm_field_int      (max_data_delay,        UVM_ALL_ON)
        `uvm_field_int      (split_addr_data,       UVM_ALL_ON)
        `uvm_field_int      (min_resp_ready_delay,  UVM_ALL_ON)
        `uvm_field_int      (max_resp_ready_delay,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "user_driver_config");
        super.new(name);
    endfunction

    constraint ranges_valid_c {
        min_addr_delay       <= max_addr_delay;
        min_data_delay       <= max_data_delay;
        min_resp_ready_delay <= max_resp_ready_delay;
    }
endclass