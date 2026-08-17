module axi4_master(
    input logic                          clk, 
    input logic                          rst_n,
    transfer_engine_axi4_if .axi4_master transfer_engine,
    axi4_if                 .master      axi  
);
        // AW
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.aw_valid           <= 1'b0;
            transfer_engine.w_addr_ready <= 1'b0; 
        end
        else begin
            transfer_engine.w_addr_ready <= 1'b0;
            if (axi.aw_valid) begin
                if (axi.aw_ready) 
                    axi.aw_valid <= 1'b0;
            end
            else if (transfer_engine.w_addr_valid) begin
                axi.aw_id              <= transfer_engine.w_id;
                axi.aw_addr            <= transfer_engine.w_addr;
                axi.aw_len             <= transfer_engine.w_len;
                axi.aw_size            <= transfer_engine.w_size;
                axi.aw_burst           <= transfer_engine.w_burst;
                axi.aw_lock            <= transfer_engine.w_lock;
                axi.aw_cache           <= transfer_engine.w_cache;
                axi.aw_prot            <= transfer_engine.w_prot;
                axi.aw_qos             <= transfer_engine.w_qos;
                axi.aw_region          <= transfer_engine.w_region;
                axi.aw_valid           <= 1'b1;
                transfer_engine.w_addr_ready <= 1'b1;
            end
        end
    end
        // W
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.w_valid            <= 1'b0;
            transfer_engine.w_data_ready <= 1'b0;
        end
        else begin
            transfer_engine.w_data_ready <= 1'b0;
            if (axi.w_valid) begin
                if (axi.w_ready)
                    axi.w_valid <= 1'b0;
            end
            else if (transfer_engine.w_data_valid) begin
                axi.w_data             <= transfer_engine.w_data;
                axi.w_strb             <= transfer_engine.w_strb;
                axi.w_last             <= transfer_engine.w_last;
                axi.w_valid            <= 1'b1; 
                transfer_engine.w_data_ready <= 1'b1;
            end
        end
    end
        // B
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.b_ready            <= 1'b0;
            transfer_engine.w_resp_valid <= 1'b0; 
        end
        else begin
            axi.b_ready <= 1'b0;
            if (transfer_engine.w_resp_valid) begin
                if (transfer_engine.w_resp_ready) begin
                    transfer_engine.w_resp_valid <= 1'b0; 
                end
            end
            else if (axi.b_valid) begin
                transfer_engine.w_resp_id    <= axi.b_id;
                transfer_engine.w_resp       <= axi.b_resp;
                transfer_engine.w_resp_valid <= 1'b1;
                axi.b_ready            <= 1'b1;
            end
        end
    end    
        // AR
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.ar_valid      <= 1'b0;
            transfer_engine.r_ready <= 1'b0;
        end 
        else begin
            transfer_engine.r_ready <= 1'b0;
            if (axi.ar_valid) begin
                if (axi.ar_ready)
                    axi.ar_valid <= 1'b0;
            end
            else if (transfer_engine.r_valid) begin
                axi.ar_id         <= transfer_engine.r_id;
                axi.ar_addr       <= transfer_engine.r_addr;
                axi.ar_len        <= transfer_engine.r_len;
                axi.ar_size       <= transfer_engine.r_size;
                axi.ar_burst      <= transfer_engine.r_burst;
                axi.ar_lock       <= transfer_engine.r_lock;
                axi.ar_cache      <= transfer_engine.r_cache;
                axi.ar_prot       <= transfer_engine.r_prot;
                axi.ar_qos        <= transfer_engine.r_qos;
                axi.ar_region     <= transfer_engine.r_region;
                axi.ar_valid      <= 1'b1;
                transfer_engine.r_ready <= 1'b1;
            end
        end
    end  
        // R
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.r_ready            <= 1'b0;
            transfer_engine.r_resp_valid <= 1'b0; 
        end
        else begin
            axi.r_ready <= 1'b0;
            if (transfer_engine.r_resp_valid) begin
                if (transfer_engine.r_resp_ready) 
                    transfer_engine.r_resp_valid <= 1'b0;
            end
            else if (axi.r_valid) begin
                transfer_engine.r_resp_id    <= axi.r_id;
                transfer_engine.r_resp       <= axi.r_resp;
                transfer_engine.r_data       <= axi.r_data;
                transfer_engine.r_resp_valid <= 1'b1;
                axi.r_ready            <= 1'b1;
            end
        end
    end
endmodule
