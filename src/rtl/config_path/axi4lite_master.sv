module axi4lite_master (
    input logic                     clk, 
    input logic                     rst_n,
    user_config_if .axi4lite_master user,
    axi4lite_if    .master          axi
);
        // AW 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.aw_valid      <= 1'b0;
            user.w_addr_ready <= 1'b0;
        end
        else begin
            user.w_addr_ready <= 1'b0;
            if (axi.aw_valid) begin
                if (axi.aw_ready) 
                    axi.aw_valid <= 1'b0; 
            end
            else if (user.w_addr_valid) begin
                axi.aw_addr       <= user.w_addr;
                axi.aw_prot       <= user.w_prot;
                axi.aw_valid      <= 1'b1;
                user.w_addr_ready <= 1'b1;
            end
        end
    end
        // W
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.w_valid       <= 1'b0;
            user.w_data_ready <= 1'b0;
        end
        else begin
            user.w_data_ready <= 1'b0;
            if (axi.w_valid) begin
                if (axi.w_ready) 
                    axi.w_valid <= 1'b0;
            end
            else if (user.w_data_valid) begin
                axi.w_data        <= user.w_data;
                axi.w_strb        <= user.w_strb;
                axi.w_valid       <= 1'b1;
                user.w_data_ready <= 1'b1;
            end 
        end
    end
        // B
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            user.w_resp_valid <= 1'b0;
            axi.b_ready       <= 1'b0;
        end
        else begin
            axi.b_ready <= 1'b0;
            if (user.w_resp_valid) begin
                if (user.w_resp_ready)
                    user.w_resp_valid <= 1'b0;
            end
            else if (axi.b_valid) begin
                user.w_resp       <= axi.b_resp;
                user.w_resp_valid <= 1'b1;
                axi.b_ready       <= 1'b1;
            end
        end
    end
        // AR
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            axi.ar_valid <= 1'b0;
            user.r_ready <= 1'b0;
        end
        else begin
            user.r_ready <= 1'b0;
            if (axi.ar_valid) begin
                if (axi.ar_ready) 
                    axi.ar_valid <= 1'b0; 
            end
            else if (user.r_valid) begin
                axi.ar_addr  <= user.r_addr;
                axi.ar_prot  <= user.r_prot;
                axi.ar_valid <= 1'b1;
                user.r_ready <= 1'b1;
            end
        end
    end
        // R
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            user.r_resp_valid <= 1'b0;
            axi.r_ready       <= 1'b0;
        end        
        else begin
            axi.r_ready <= 1'b0;
            if (user.r_resp_valid) begin
                if (user.r_resp_ready) 
                    user.r_resp_valid <= 1'b0;
            end
            else if (axi.r_valid) begin
                user.r_data       <= axi.r_data;
                user.r_resp       <= axi.r_resp;
                user.r_resp_valid <= 1'b1;
                axi.r_ready       <= 1'b1;
            end
        end
    end
endmodule
