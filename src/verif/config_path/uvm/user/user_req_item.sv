class user_req_item extends uvm_sequence_item;

         bit              is_write; 
    rand bit [ADDR_W-1:0] addr;   
    rand bit [DATA_W-1:0] data;   
    rand bit [STRB_W-1:0] strb;   
    rand bit [2:0]        prot;      

    `uvm_object_utils_begin (user_req_item)
        `uvm_field_int      (is_write, UVM_ALL_ON)
        `uvm_field_int      (addr,     UVM_ALL_ON)
        `uvm_field_int      (data,     UVM_ALL_ON)
        `uvm_field_int      (strb,     UVM_ALL_ON)
        `uvm_field_int      (prot,     UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "user_req_item");
        super.new(name);
    endfunction

    constraint strb_reasonable_c {
        strb != '0 -> is_write == 1'b1;
    }

    function string convert2string();
        if (is_write)
            return $sformatf("WRITE REQ addr=0x%0h data=0x%0h strb=0b%0b prot=%0d",
                                        addr, data, strb, prot);
        else
            return $sformatf("READ REQ addr=0x%0h prot=%0d",
                                       addr, prot);
    endfunction
endclass
