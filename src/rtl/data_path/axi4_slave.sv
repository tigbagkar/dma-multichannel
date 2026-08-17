module axi4_slave(
    input logic              clk, 
    input logic              rst_n,
    axi4_if           .slave axi,
    memory_adapter_if .slave adapter
);
    
        // AW
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.aw_ready         <= 1'b0;
            adapter.w_addr_valid <= 1'b0;
        end 
        else begin
            axi.aw_ready <= 1'b0;
            if (adapter.w_addr_valid) begin
                if (adapter.w_addr_ready) 
                    adapter.w_addr_valid <= 1'b0;
            end
            else if (axi.aw_valid) begin
                adapter.w_id         <= axi.aw_id;
                adapter.w_addr       <= axi.aw_addr;
                adapter.w_len        <= axi.aw_len;
                adapter.w_addr_valid <= 1'b1;
                axi.aw_ready         <= 1'b1; 
            end
        end
    end
        // W
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.w_ready          <= 1'b0;
            adapter.w_data_valid <= 1'b0;
        end 
        else begin
            axi.w_ready <= 1'b0;
            if (adapter.w_data_valid) begin
                if (adapter.w_data_ready) 
                    adapter.w_data_valid <= 1'b0;
            end
            else if (axi.w_valid) begin
                adapter.w_data       <= axi.w_data;
                adapter.w_last       <= axi.w_last;
                adapter.w_data_valid <= 1'b1;
                axi.w_ready          <= 1'b1; 
            end
        end
    end
        // B
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adapter.w_resp_ready <= 1'b0;
            axi.b_valid          <= 1'b0;
        end else begin
            adapter.w_resp_ready <= 1'b0;
            if (axi.b_valid) begin
                if (axi.b_ready)
                    axi.b_valid <= 1'b0;
            end
            else if (adapter.w_resp_valid) begin
                axi.b_id             <= adapter.w_resp_id;
                axi.b_resp           <= adapter.w_resp;
                axi.b_valid          <= 1'b1;
                adapter.w_resp_ready <= 1'b1; 
            end
        end
    end
        // AR
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.ar_ready    <= 1'b0;
            adapter.r_valid <= 1'b0;    
        end 
        else begin
            axi.ar_ready <= 1'b0;
            if (adapter.r_valid) begin
                if (adapter.r_ready)
                    adapter.r_valid <= 1'b0;
            end
            else if (axi.ar_valid) begin
                adapter.r_id    <= axi.ar_id;
                adapter.r_addr  <= axi.ar_addr;
                adapter.r_len   <= axi.ar_len;
                adapter.r_valid <= 1'b1;
                axi.ar_ready    <= 1'b1; 
            end
        end
    end
        // R
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adapter.r_resp_ready <= 1'b0;
            axi.r_valid          <= 1'b0;
        end
        else begin
            adapter.r_resp_ready <= 1'b0;
            if (axi.r_valid) begin
                if (axi.r_ready)
                    axi.r_valid <= 1'b0;
            end
            else if (adapter.r_resp_valid) begin
                axi.r_id             <= adapter.r_resp_id;
                axi.r_data           <= adapter.r_data;
                axi.r_resp           <= adapter.r_resp;
                axi.r_last           <= adapter.r_last;
                axi.r_valid          <= 1'b1;
                adapter.r_resp_ready <= 1'b1; 
            end
        end
    end
endmodule
