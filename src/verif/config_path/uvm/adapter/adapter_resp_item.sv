class adapter_resp_item extends uvm_object;

    bit              is_write;
    axi_resp_t       axi_resp;
    bit [DATA_W-1:0] r_data;

    `uvm_object_utils_begin (adapter_resp_item)
        `uvm_field_int      (            is_write, UVM_ALL_ON)
        `uvm_field_enum     (axi_resp_t, axi_resp, UVM_ALL_ON)
        `uvm_field_int      (            r_data,   UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "adapter_resp_item");
        super.new(name);
    endfunction

    function string convert2string();
        if (is_write) 
            return $sformatf("WRITE RESP axi_resp=%s", 
                                         axi_resp.name()); 
        else 
            return $sformatf("READ RESP axi_resp=%s, r_data=0x%0h", 
                                        axi_resp.name(), r_data);
    endfunction
endclass
