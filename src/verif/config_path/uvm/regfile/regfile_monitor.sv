class regfile_monitor extends uvm_monitor;
    `uvm_component_utils(regfile_monitor)

    virtual regfile_config_if vif;
    virtual clk_rst_if                 clk_vif;

    uvm_analysis_port #(regfile_req_item)  req_ap;
    uvm_analysis_port #(regfile_resp_item) resp_ap;

    function new(string name = "regfile_monitor", uvm_component parent = null);
        super.new(name, parent);
        req_ap  = new("req_ap", this);
        resp_ap = new("resp_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual regfile_config_if) :: get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "regfile_monitor: virtual interface 'vif' not set via uvm_config_db")

        if (!uvm_config_db #(virtual clk_rst_if)                :: get(this, "", "clk_vif", clk_vif))
            `uvm_fatal("NOVIF", "regfile_monitor: virtual interface 'clk_vif' not set via uvm_config_db")
    endfunction

    task run_phase(uvm_phase phase);
        wait (clk_vif.rst_n === 1'b1);
        fork
            begin
                forever begin
                    if (vif.w_valid && vif.w_ready)
                        collect_write_req();
                    else if (vif.r_valid && vif.r_ready)
                        collect_read_req();
                    @(posedge clk_vif.clk);
                end
            end

            begin
                forever begin
                    if (vif.w_resp_valid && vif.w_resp_ready)
                        collect_resp(1'b1);
                    else if (vif.r_resp_valid && vif.r_resp_ready)
                        collect_resp(1'b0);
                    @(posedge clk_vif.clk); 
                end
            end
        join_none
    endtask

    task collect_write_req();
        regfile_req_item item;

        item          = regfile_req_item::type_id::create("item");
        item.is_write = 1'b1;
        item.addr     = vif.w_addr;
        item.data     = vif.w_data;
        item.strb     = vif.w_strb;
        item.prot     = vif.w_prot;

        `uvm_info("REGFILE_MON", $sformatf("Collected %s", item.convert2string()), UVM_HIGH)
        req_ap.write(item);
    endtask

    task collect_read_req();
        regfile_req_item item;

        item          = regfile_req_item::type_id::create("item");
        item.is_write = 1'b0;
        item.addr     = vif.r_addr;
        item.data     = '0;
        item.strb     = '0;
        item.prot     = vif.r_prot;

        `uvm_info("REGFILE_MON", $sformatf("Collected %s", item.convert2string()), UVM_HIGH)
        req_ap.write(item);
    endtask

    task collect_resp(input bit is_write);
        regfile_resp_item item;

        item = regfile_resp_item::type_id::create("item");
        
        item.is_write = is_write;
        if (is_write) begin
            item.regfile_resp = vif.w_resp;
            item.r_data       = '0;
        end
        else if (!is_write) begin
            item.regfile_resp = vif.r_resp;
            item.r_data       = vif.r_data;
        end
        
        `uvm_info("REGFILE_MON", $sformatf("Collected %s", item.convert2string()), UVM_HIGH);
        resp_ap.write(item);
    endtask
endclass
