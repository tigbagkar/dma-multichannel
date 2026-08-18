class user_sequencer extends uvm_sequencer #(user_req_item);
    `uvm_component_utils(user_sequencer)

    function new(string name = "user_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
