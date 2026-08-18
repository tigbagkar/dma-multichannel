class axi4lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi4lite_monitor)

    virtual axi4lite_if vif;
    virtual clk_rst_if  clk_vif;

    uvm_analysis_port #(axi4lite_req_item)  req_ap;
    uvm_analysis_port #(axi4lite_resp_item) resp_ap;

    function new(string name = "axi4lite_monitor", uvm_component parent = null);
        super.new(name, parent);
        req_ap  = new("req_ap", this);
        resp_ap = new("resp_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual axi4lite_if) :: get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "axi4lite_monitor: virtual interface 'vif' not set via uvm_config_db")

        if (!uvm_config_db #(virtual clk_rst_if)  :: get(this, "", "clk_vif", clk_vif))
            `uvm_fatal("NOVIF", "axi4lite_monitor: virtual interface 'clk_vif' not set via uvm_config_db")
    endfunction

    task run_phase(uvm_phase phase);
        wait (clk_vif.rst_n === 1'b1);
        
        fork
            begin
                forever begin
                    if ((vif.aw_valid && vif.aw_ready) || (vif.w_valid && vif.w_ready))
                        collect_write_req();
                    else if (vif.ar_valid && vif.ar_ready)
                        collect_read_req();
                    @(posedge clk_vif.clk);
                end
            end

            begin
                forever begin
                    if (vif.b_valid && vif.b_ready)
                        collect_resp(1'b1);
                    else if (vif.r_valid && vif.r_ready)
                        collect_resp(1'b0);
                    @(posedge clk_vif.clk);
                end    
            end
        join_none   
    endtask

    task collect_write_req();
        axi4lite_req_item item;
        bit               addr_done;
        bit               data_done;

        item          = axi4lite_req_item::type_id::create("item");
        item.is_write = 1'b1;
        
        addr_done = 1'b0;
        data_done = 1'b0;

        while (!addr_done || !data_done) begin
            if (!addr_done && vif.aw_valid && vif.aw_ready) begin
                item.addr = vif.aw_addr;
                item.prot = vif.aw_prot;
                addr_done = 1'b1;
            end
            if (!data_done && vif.w_valid && vif.w_ready) begin
                item.data = vif.w_data;
                item.strb = vif.w_strb;
                data_done = 1'b1;
            end
            if (!addr_done || !data_done)
                @(posedge clk_vif.clk);
        end

        `uvm_info("AXI4LITE_MON", $sformatf("Collected %s", item.convert2string()), UVM_HIGH)
        req_ap.write(item);
    endtask

    task collect_read_req();
        axi4lite_req_item item;

        item          = axi4lite_req_item::type_id::create("item");
        item.is_write = 1'b0;
        item.addr     = vif.ar_addr;
        item.prot     = vif.ar_prot;

        `uvm_info("AXI4LITE_MON", $sformatf("Collected %s", item.convert2string()), UVM_HIGH)
        req_ap.write(item);
    endtask

    task collect_resp(input bit is_write);
        axi4lite_resp_item item;

        item = axi4lite_resp_item::type_id::create("item");
        
        item.is_write = is_write;
        if (is_write) begin
            item.axi_resp = vif.b_resp;
            item.r_data   = '0;    
        end 
        else if (!is_write) begin
            item.axi_resp = vif.r_resp;
            item.r_data   = vif.r_data;
        end

        `uvm_info("AXI4LITE_MON", $sformatf("Collected %s", item.convert2string()), UVM_HIGH)
        resp_ap.write(item); 
    endtask
endclass
