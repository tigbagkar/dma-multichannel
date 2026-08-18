class user_driver extends uvm_driver #(user_req_item);
    `uvm_component_utils(user_driver)

    virtual user_config_if vif;
    virtual clk_rst_if           clk_vif;
    user_driver_config           cfg;

    function new(string name = "user_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual user_config_if) :: get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "user_driver: virtual interface 'vif' not set via uvm_config_db")

        if (!uvm_config_db #(virtual clk_rst_if)          :: get(this, "", "clk_vif", clk_vif))
            `uvm_fatal("NOVIF", "user_driver: virtual interface 'clk_vif' not set via uvm_config_db")

        if (!uvm_config_db #(user_driver_config)          :: get(this, "", "cfg", cfg)) begin
            `uvm_info("NOCFG", "user_driver: no user_driver_config found, using defaults", UVM_MEDIUM)
            cfg = user_driver_config::type_id::create("cfg");
        end
    endfunction

    task run_phase(uvm_phase phase);
        drive_reset();
        wait (clk_vif.rst_n === 1'b1);

        fork
            begin
                forever begin
                    seq_item_port.get_next_item(req);
                    if (req.is_write)
                        drive_write_req(req);
                    else if (!req.is_write)
                        drive_read_req(req);
                    seq_item_port.item_done();
                end
            end
            
            begin
                forever begin
                    if (vif.w_resp_valid)
                        drive_resp_ready(1'b1);
                    else if (vif.r_resp_valid)
                        drive_resp_ready(1'b0);
                    @(posedge clk_vif.clk);
                end
            end 
        join_none
    endtask

    task drive_reset();
        vif.w_addr       <=   '0;
        vif.w_prot       <=   '0;
        vif.w_addr_valid <= 1'b0;
        vif.w_data       <=   '0;
        vif.w_strb       <=   '0;
        vif.w_data_valid <= 1'b0;
        vif.w_resp_ready <= 1'b0;
        vif.r_addr       <=   '0;
        vif.r_prot       <=   '0;
        vif.r_valid      <= 1'b0;
        vif.r_resp_ready <= 1'b0;
    endtask

    task drive_write_req(input user_req_item item);
        int unsigned addr_delay;
        int unsigned data_delay;
        bit          addr_done;
        bit          data_done;

        addr_delay = $urandom_range(cfg.max_addr_delay, cfg.min_addr_delay);
        data_delay = cfg.split_addr_data ? $urandom_range(cfg.max_data_delay, cfg.min_data_delay) : addr_delay;   
        addr_done  = 1'b0;
        data_done  = 1'b0;

        fork
            begin
                repeat (addr_delay) 
                    @(posedge clk_vif.clk);
                vif.w_addr       <= item.addr;
                vif.w_prot       <= item.prot;
                vif.w_addr_valid <= 1'b1;
            end
            begin
                repeat (data_delay) 
                    @(posedge clk_vif.clk);
                vif.w_data       <= item.data;
                vif.w_strb       <= item.strb;
                vif.w_data_valid <= 1'b1;
            end
        join_none

        while (!addr_done || !data_done) begin
            if (vif.w_addr_valid && vif.w_addr_ready) begin
                vif.w_addr_valid <= 1'b0;
                addr_done         = 1'b1;
            end
            if (vif.w_data_valid && vif.w_data_ready) begin
                vif.w_data_valid <= 1'b0;
                data_done         = 1'b1;
            end
            if (!addr_done || !data_done)
                @(posedge clk_vif.clk);
        end
    endtask

    task drive_read_req(input user_req_item item);
        int unsigned addr_delay;

        addr_delay = $urandom_range(cfg.max_addr_delay, cfg.min_addr_delay);
        
        repeat (addr_delay) 
            @(posedge clk_vif.clk);

        vif.r_addr  <= item.addr;
        vif.r_prot  <= item.prot;
        vif.r_valid <= 1'b1;

        while (!(vif.r_valid && vif.r_ready))
            @(posedge clk_vif.clk);
        vif.r_valid <= 1'b0;
    endtask

    task drive_resp_ready(input bit is_write);
        int unsigned resp_ready_delay;
        resp_ready_delay = $urandom_range(cfg.max_resp_ready_delay, cfg.min_resp_ready_delay);

        repeat (resp_ready_delay) 
            @(posedge clk_vif.clk);

        if (is_write) begin
            vif.w_resp_ready <= 1'b1;
            @(posedge clk_vif.clk);
            vif.w_resp_ready <= 1'b0; 
        end
        else if (!is_write) begin
            vif.r_resp_ready <= 1'b1;
            @(posedge clk_vif.clk);
            vif.r_resp_ready <= 1'b0;
        end
    endtask
endclass