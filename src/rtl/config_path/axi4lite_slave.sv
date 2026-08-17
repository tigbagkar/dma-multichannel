module axi4lite_slave (
    input logic                clk,
    input logic                rst_n,
    axi4lite_if         .slave axi,
    axi4lite_adapter_if .slave adapter
);
        // AW
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adapter.w_addr_valid <= 1'b0;
            axi.aw_ready         <= 1'b0;
        end
        else begin
            axi.aw_ready <= 1'b0;
            if (adapter.w_addr_valid) begin
                if (adapter.w_addr_ready)
                    adapter.w_addr_valid <= 1'b0;  
            end
            else if (axi.aw_valid) begin
                adapter.w_addr       <= axi.aw_addr;
                adapter.w_prot       <= axi.aw_prot;
                adapter.w_addr_valid <= 1'b1;
                axi.aw_ready         <= 1'b1;
            end
        end
    end
        // W
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adapter.w_data_valid <= 1'b0;
            axi.w_ready          <= 1'b0;
        end
        else begin
            axi.w_ready <= 1'b0;
            if (adapter.w_data_valid) begin
                if (adapter.w_data_ready)
                    adapter.w_data_valid <= 1'b0; 
            end
            else if (axi.w_valid) begin
                adapter.w_data       <= axi.w_data;
                adapter.w_strb       <= axi.w_strb;
                adapter.w_data_valid <= 1'b1;
                axi.w_ready          <= 1'b1;
            end
        end
    end
        // B
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.b_valid          <= 1'b0;
            adapter.w_resp_ready <= 1'b0;
        end
        else begin
            adapter.w_resp_ready <= 1'b0;
            if (axi.b_valid) begin
                if (axi.b_ready) 
                    axi.b_valid <= 1'b0;
            end
            else if (adapter.w_resp_valid) begin
                axi.b_resp           <= adapter.w_resp;
                axi.b_valid          <= 1'b1;
                adapter.w_resp_ready <= 1'b1;
            end
        end
    end
        // AR
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adapter.r_valid <= 1'b0;
            axi.ar_ready    <= 1'b0;
        end
        else begin
            axi.ar_ready <= 1'b0;
            if (adapter.r_valid) begin
                if (adapter.r_ready) 
                    adapter.r_valid <= 1'b0;
            end
            else if (axi.ar_valid) begin
                adapter.r_addr  <= axi.ar_addr;
                adapter.r_prot  <= axi.ar_prot;
                adapter.r_valid <= 1'b1;
                axi.ar_ready    <= 1'b1;
            end
        end
    end
        // R
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.r_valid          <= 1'b0;
            adapter.r_resp_ready <= 1'b0;
        end
        else begin
            adapter.r_resp_ready <= 1'b0;
            if (axi.r_valid) begin
                if (axi.r_ready)
                    axi.r_valid <= 1'b0; 
            end
            else if (adapter.r_resp_valid) begin
                axi.r_data           <= adapter.r_data;
                axi.r_resp           <= adapter.r_resp;
                axi.r_valid          <= 1'b1;
                adapter.r_resp_ready <= 1'b1;
            end
        end
    end
endmodule
