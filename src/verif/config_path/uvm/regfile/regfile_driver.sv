class regfile_driver extends uvm_driver #(regfile_resp_item);
    `uvm_component_utils(regfile_driver)

    virtual regfile_config_if vif;
    virtual clk_rst_if                clk_vif;
    regfile_driver_config             cfg;

    function new(string name = "regfile_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual regfile_config_if) :: get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "regfile_driver: virtual interface 'vif' not set via uvm_config_db")

        if (!uvm_config_db #(virtual clk_rst_if)                :: get(this, "", "clk_vif", clk_vif))
            `uvm_fatal("NOVIF", "regfile_driver: virtual interface 'clk_vif' not set via uvm_config_db")
        
        if (!uvm_config_db #(regfile_driver_config)             :: get(this, "", "cfg", cfg)) begin
            `uvm_info("NOCFG", "regfile_driver: no regfile_driver_config found, using defaults", UVM_MEDIUM)
            cfg = regfile_driver_config::type_id::create("cfg");
        end
    endfunction

    task run_phase(uvm_phase phase);
        drive_reset();
        wait (clk_vif.rst_n === 1'b1);

        forever begin
            seq_item_port.get_next_item(rsp);
            
            while (!vif.w_valid && !vif.r_valid)
                @(posedge clk_vif.clk);
            
            if (vif.w_valid)
                drive_write(rsp);
            else if (vif.r_valid)
                drive_read(rsp);

            seq_item_port.item_done();
        end
    endtask

    task drive_reset();
        vif.w_ready      <= 1'b0;
        vif.w_resp       <= SUCCESS;
        vif.w_resp_valid <= 1'b0;
        vif.r_ready      <= 1'b0;
        vif.r_data       <=   '0;
        vif.r_resp       <= SUCCESS;
        vif.r_resp_valid <= 1'b0;
    endtask

    task drive_write(input regfile_resp_item item);
        
        int unsigned req_ready_delay;
        int unsigned resp_delay;
        req_ready_delay = $urandom_range(cfg.max_req_ready_delay,  cfg.min_req_ready_delay);
        resp_delay      = $urandom_range(cfg.max_resp_delay, cfg.min_resp_delay);

        repeat (req_ready_delay) 
            @(posedge clk_vif.clk);

        vif.w_ready <= 1'b1;
        @(posedge clk_vif.clk);
        vif.w_ready <= 1'b0;

        repeat (resp_delay) 
            @(posedge clk_vif.clk);

        vif.w_resp       <= item.regfile_resp;
        vif.w_resp_valid <= 1'b1;
            
        while (!(vif.w_resp_valid && vif.w_resp_ready)) 
            @(posedge clk_vif.clk);
        
        vif.w_resp_valid <= 1'b0;
    endtask

    task drive_read(input regfile_resp_item item);

        int unsigned req_ready_delay;
        int unsigned resp_delay;
        req_ready_delay = $urandom_range(cfg.max_req_ready_delay,  cfg.min_req_ready_delay);
        resp_delay      = $urandom_range(cfg.max_resp_delay, cfg.min_resp_delay);

        repeat (req_ready_delay) 
            @(posedge clk_vif.clk);

        vif.r_ready <= 1'b1;
        @(posedge clk_vif.clk);
        vif.r_ready <= 1'b0;

        repeat (resp_delay) 
            @(posedge clk_vif.clk);

        vif.r_resp        <= item.regfile_resp;
        vif.r_data        <= item.r_data;
        vif.r_resp_valid  <= 1'b1;

        while (!(vif.r_resp_valid && vif.r_resp_ready))
            @(posedge clk_vif.clk);
        
        vif.r_resp_valid <= 1'b0;
    endtask
endclass
