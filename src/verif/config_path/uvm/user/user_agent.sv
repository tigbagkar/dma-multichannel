class user_agent extends uvm_agent;
    `uvm_component_utils(user_agent)

    user_sequencer sequencer;
    user_driver    driver;
    user_monitor   monitor;

    uvm_analysis_port #(user_req_item)  req_ap;
    uvm_analysis_port #(user_resp_item) resp_ap;

    function new(string name = "user_agent", uvm_component parent = null);
        super.new(name, parent);
        req_ap  = new("req_ap", this);
        resp_ap = new("resp_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor = user_monitor :: type_id::create("monitor", this);

        if (is_active == UVM_ACTIVE) begin
            sequencer = user_sequencer :: type_id::create("sequencer", this);
            driver    = user_driver    :: type_id::create("driver", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        monitor.req_ap  .connect(req_ap);
        monitor.resp_ap .connect(resp_ap);
        
        if (is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass
