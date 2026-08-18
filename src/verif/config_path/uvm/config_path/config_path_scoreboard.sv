class config_path_scoreboard extends uvm_component;
    `uvm_component_utils(config_path_scoreboard)

    uvm_analysis_export   #(user_req_item)      user_req_export;
    uvm_analysis_export   #(user_resp_item)     user_resp_export;
    uvm_analysis_export   #(axi4lite_req_item)  axi4lite_req_export;
    uvm_analysis_export   #(axi4lite_resp_item) axi4lite_resp_export;
    uvm_analysis_export   #(adapter_req_item)   adapter_req_export;
    uvm_analysis_export   #(adapter_resp_item)  adapter_resp_export;
    uvm_analysis_export   #(regfile_req_item)   regfile_req_export;
    uvm_analysis_export   #(regfile_resp_item)  regfile_resp_export;

    uvm_tlm_analysis_fifo #(user_req_item)      user_req_fifo;
    uvm_tlm_analysis_fifo #(user_resp_item)     user_resp_fifo;
    uvm_tlm_analysis_fifo #(axi4lite_req_item)  axi4lite_req_fifo;
    uvm_tlm_analysis_fifo #(axi4lite_resp_item) axi4lite_resp_fifo;
    uvm_tlm_analysis_fifo #(adapter_req_item)   adapter_req_fifo;
    uvm_tlm_analysis_fifo #(adapter_resp_item)  adapter_resp_fifo;
    uvm_tlm_analysis_fifo #(regfile_req_item)   regfile_req_fifo;
    uvm_tlm_analysis_fifo #(regfile_resp_item)  regfile_resp_fifo;

    int unsigned num_checked = 0;
    int unsigned num_errors  = 0;

    function new(string name = "config_path_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        user_req_export      = new("user_req_export", this);
        user_resp_export     = new("user_resp_export", this);
        axi4lite_req_export  = new("axi4lite_req_export", this);
        axi4lite_resp_export = new("axi4lite_resp_export", this);
        adapter_req_export   = new("adapter_req_export", this);
        adapter_resp_export  = new("adapter_resp_export", this);
        regfile_req_export   = new("regfile_req_export", this);
        regfile_resp_export  = new("regfile_resp_export", this);

        user_req_fifo        = new("user_req_fifo", this);
        user_resp_fifo       = new("user_resp_fifo", this);
        axi4lite_req_fifo    = new("axi4lite_req_fifo", this);
        axi4lite_resp_fifo   = new("axi4lite_resp_fifo", this);
        adapter_req_fifo     = new("adapter_req_fifo", this);
        adapter_resp_fifo    = new("adapter_resp_fifo", this);
        regfile_req_fifo     = new("regfile_req_fifo", this);
        regfile_resp_fifo    = new("regfile_resp_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        user_req_export      .connect(user_req_fifo      .analysis_export);
        user_resp_export     .connect(user_resp_fifo     .analysis_export);
        axi4lite_req_export  .connect(axi4lite_req_fifo  .analysis_export);
        axi4lite_resp_export .connect(axi4lite_resp_fifo .analysis_export);
        adapter_req_export   .connect(adapter_req_fifo   .analysis_export);
        adapter_resp_export  .connect(adapter_resp_fifo  .analysis_export);
        regfile_req_export   .connect(regfile_req_fifo   .analysis_export);
        regfile_resp_export  .connect(regfile_resp_fifo  .analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        user_req_item      user_req;
        user_resp_item     user_resp;
        axi4lite_req_item  axi4lite_req;
        axi4lite_resp_item axi4lite_resp;
        adapter_req_item   adapter_req;
        adapter_resp_item  adapter_resp;
        regfile_req_item   regfile_req;
        regfile_resp_item  regfile_resp;

        forever begin
            fork
                user_req_fifo      .get(user_req);
                user_resp_fifo     .get(user_resp);
                axi4lite_req_fifo  .get(axi4lite_req);
                axi4lite_resp_fifo .get(axi4lite_resp);
                adapter_req_fifo   .get(adapter_req);
                adapter_resp_fifo  .get(adapter_resp);
                regfile_req_fifo   .get(regfile_req);
                regfile_resp_fifo  .get(regfile_resp);
            join

            num_checked++;

            check_req  (user_req,  axi4lite_req,  adapter_req,  regfile_req);
            check_resp (user_resp, axi4lite_resp, adapter_resp, regfile_resp);
        end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", 
                    $sformatf("Total transactions checked: %0d, errors: %0d", num_checked, num_errors),
                    UVM_LOW)
    endfunction

    function void check_req(
        input user_req_item user_req,
        input axi4lite_req_item axi4lite_req,
        input adapter_req_item adapter_req,
        input regfile_req_item regfile_req
    );
        if (!((user_req.is_write == axi4lite_req.is_write) && 
              (axi4lite_req.is_write == adapter_req.is_write) &&
              (adapter_req.is_write == regfile_req.is_write))) begin
            report_error(
                $sformatf(
                    "req is_write mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                    user_req.is_write, axi4lite_req.is_write, adapter_req.is_write, regfile_req.is_write
                )
            );
            return;
        end

        if (!((user_req.addr == axi4lite_req.addr) && 
              (axi4lite_req.addr == adapter_req.addr) &&
              (adapter_req.addr == regfile_req.addr))) begin
            report_error(
                $sformatf(
                    "req addr mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                    user_req.addr, axi4lite_req.addr, adapter_req.addr, regfile_req.addr
                )
            );
            return;
        end

        if (!((user_req.prot == axi4lite_req.prot) && 
              (axi4lite_req.prot == adapter_req.prot) &&
              (adapter_req.prot == regfile_req.prot))) begin
            report_error(
                $sformatf(
                    "req prot mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                    user_req.prot, axi4lite_req.prot, adapter_req.prot, regfile_req.prot
                )
            );
            return;
        end

        if (user_req.is_write) begin
            if (!((user_req.data == axi4lite_req.data) && 
              (axi4lite_req.data == adapter_req.data) &&
              (adapter_req.data == regfile_req.data))) begin
                report_error(
                    $sformatf(
                        "req data mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                        user_req.data, axi4lite_req.data, adapter_req.data, regfile_req.data
                    )
                );
                return;
            end

            if (!((user_req.strb == axi4lite_req.strb) && 
              (axi4lite_req.strb == adapter_req.strb) &&
              (adapter_req.strb == regfile_req.strb))) begin
                report_error(
                    $sformatf(
                        "req strb mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                        user_req.strb, axi4lite_req.strb, adapter_req.strb, regfile_req.strb
                    )
                );
                return;
            end
        end
    endfunction

    function void check_resp(
        input user_resp_item     user_resp,
        input axi4lite_resp_item axi4lite_resp,
        input adapter_resp_item  adapter_resp,
        input regfile_resp_item  regfile_resp
    );
        axi_pkg::axi_resp_t regfile_mapped;
        regfile_mapped = predict_resp(regfile_resp.regfile_resp);
        
        if (!((user_resp.is_write == axi4lite_resp.is_write) && 
              (axi4lite_resp.is_write == adapter_resp.is_write) &&
              (adapter_resp.is_write == regfile_resp.is_write))) begin
            report_error(
                $sformatf(
                    "resp is_write mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                    user_resp.is_write, axi4lite_resp.is_write, adapter_resp.is_write, regfile_resp.is_write
                )
            );
            return;
        end

        if (!((user_resp.axi_resp == axi4lite_resp.axi_resp) && 
              (axi4lite_resp.axi_resp == adapter_resp.axi_resp) &&
              (adapter_resp.axi_resp == regfile_mapped))) begin
            report_error(
                $sformatf(
                    "resp resp_code mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                    user_resp.axi_resp, axi4lite_resp.axi_resp, adapter_resp.axi_resp, regfile_mapped
                )
            );
            return;
        end

        if (!user_resp.is_write) begin
            if (!((user_resp.r_data == axi4lite_resp.r_data) && 
              (axi4lite_resp.r_data == adapter_resp.r_data) &&
              (adapter_resp.r_data == regfile_resp.r_data))) begin
                report_error(
                    $sformatf(
                        "resp r_data mismatch: user=%0d axi4lite=%0d adapter=%0d regfile=%0d", 
                        user_resp.r_data, axi4lite_resp.r_data, adapter_resp.r_data, regfile_resp.r_data
                    )
                );
                return;
            end 
        end
    endfunction

    function void report_error(string msg);
        num_errors++;
        `uvm_error("SCOREBOARD", msg)
    endfunction
    
    function axi_pkg::axi_resp_t predict_resp(input regfile_pkg::regfile_resp_t regfile_resp);
        case (regfile_resp)
            regfile_pkg::SUCCESS:         return axi_pkg::OKAY;
            regfile_pkg::INVALID_ADDRESS: return axi_pkg::DECERR;
            regfile_pkg::READ_ONLY:       return axi_pkg::SLVERR;
            regfile_pkg::WRITE_PROTECTED: return axi_pkg::SLVERR;
            default:                      return axi_pkg::SLVERR;
        endcase
    endfunction
endclass