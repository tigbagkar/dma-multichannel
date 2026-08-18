class regfile_resp_item extends uvm_sequence_item;
         bit              is_write;
    rand regfile_resp_t   regfile_resp;
    rand bit [DATA_W-1:0] r_data;

    `uvm_object_utils_begin (regfile_resp_item)
        `uvm_field_int      (                is_write,     UVM_ALL_ON)
        `uvm_field_enum     (regfile_resp_t, regfile_resp, UVM_ALL_ON)
        `uvm_field_int      (                r_data,       UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "regfile_resp_item");
        super.new(name);
    endfunction

    function string convert2string();
        if (is_write)
            return $sformatf("WRITE RESP regfile_resp=%s",
                                         regfile_resp.name());
        else 
            return $sformatf("READ RESP regfile_resp=%s, r_data=0x%0h",
                                        regfile_resp.name(), r_data);
    endfunction
endclass
