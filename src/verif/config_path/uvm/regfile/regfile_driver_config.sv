class regfile_driver_config extends uvm_object;

    rand int unsigned min_req_ready_delay = 0;
    rand int unsigned max_req_ready_delay = 5;

    rand int unsigned min_resp_delay = 0;
    rand int unsigned max_resp_delay = 5;

    `uvm_object_utils_begin (regfile_driver_config)
        `uvm_field_int      (min_req_ready_delay, UVM_ALL_ON)
        `uvm_field_int      (max_req_ready_delay, UVM_ALL_ON)
        `uvm_field_int      (min_resp_delay,      UVM_ALL_ON)
        `uvm_field_int      (max_resp_delay,      UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "regfile_driver_config");
        super.new(name);
    endfunction

    constraint ranges_valid_c {
        min_req_ready_delay <= max_req_ready_delay;
        min_resp_delay      <= max_resp_delay;
    }
endclass