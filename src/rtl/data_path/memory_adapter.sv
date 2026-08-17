import global_pkg :: ADDR_W;
import global_pkg :: MAX_BURST_LEN_W;
import global_pkg :: ADDR_INCR;

module memory_adapter(
    input logic                clk,
    input logic                rst_n,
    memory_adapter_if .adapter slave,
    memory_if         .adapter memory
);
    typedef enum {
        IDLE,
        READ_REQ,
        READ_MEM_REQ,
        READ_MEM_RESP, 
        READ_RESP,
        WRITE_REQ,
        WRITE_DATA,
        WRITE_MEM_REQ,
        WRITE_MEM_RESP,
        WRITE_RESP
    } state_t;  
    state_t state;

    logic [0:0]                 curr_id;
    logic [ADDR_W-1:0]          curr_addr;
    logic [MAX_BURST_LEN_W-1:0] r_counter;
    logic [MAX_BURST_LEN_W-1:0] r_len;
    logic                       w_last;
    logic                       error;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            curr_id   <=   '0;
            curr_addr <=   '0;
            r_counter <=   '0;
            r_len     <=   '0;
            w_last    <= 1'b0;
            error     <= 1'b0;

            slave.w_addr_ready <= 1'b0;
            slave.w_data_ready <= 1'b0;
            slave.w_resp_valid <= 1'b0;
            slave.r_ready      <= 1'b0;
            slave.r_resp_valid <= 1'b0;

            memory.w_valid      <= 1'b0;
            memory.w_resp_ready <= 1'b0;
            memory.r_valid      <= 1'b0;
            memory.r_resp_ready <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    curr_id   <=   '0;
                    curr_addr <=   '0;
                    r_counter <=   '0;
                    r_len     <=   '0;
                    w_last    <= 1'b0;
                    error     <= 1'b0;
                    if (slave.r_valid) begin
                        state <= READ_REQ; 
                    end
                    else if (slave.w_addr_valid) begin
                        state <= WRITE_REQ; 
                    end
                end
                READ_REQ: begin
                    state         <= READ_MEM_REQ;
                    curr_id       <= slave.r_id;
                    curr_addr     <= slave.r_addr;
                    r_len         <= slave.r_len;
                    slave.r_ready <= 1'b1;
                end
                READ_MEM_REQ: begin
                    slave.r_ready <= 1'b0;
                    if (memory.r_valid) begin
                        if (memory.r_ready) begin
                            state          <= READ_MEM_RESP;
                            memory.r_valid <= 1'b0; 
                        end
                    end
                    else begin
                        memory.r_addr  <= curr_addr;
                        memory.r_valid <= 1'b1;
                        
                        curr_addr      <= curr_addr + ADDR_INCR;
                    end
                end
                READ_MEM_RESP: begin
                    if (memory.r_resp_valid) begin
                        state        <= READ_RESP;
                        
                        slave.r_resp_id <= curr_id;
                        slave.r_resp    <= axi_pkg::OKAY;
                        slave.r_data    <= memory.r_data;
                        slave.r_last    <= 1'b0;

                        if (memory.r_resp != memory_pkg::SUCCESS) begin
                            error        <= 1'b1;
                            slave.r_resp <= axi_pkg::DECERR; 
                        end 
                        if (r_counter == r_len)
                            slave.r_last <= 1'b1;
                        
                        slave.r_resp_valid  <= 1'b1;
                        memory.r_resp_ready <= 1'b1;
                    end
                end
                READ_RESP: begin
                    memory.r_resp_ready <= 1'b0;
                    if (slave.r_resp_valid) begin
                        if (slave.r_resp_ready) begin
                            state              <= READ_MEM_REQ;
                            slave.r_resp_valid <= 1'b0;
                            r_counter          <= r_counter + 1;
                            
                            if (error || r_counter == r_len)
                                state <= IDLE;
                        end
                    end
                end
                WRITE_REQ: begin
                    state              <= WRITE_DATA;
                    curr_id            <= slave.w_id;
                    curr_addr          <= slave.w_addr;
                    slave.w_addr_ready <= 1'b1; 
                end
                WRITE_DATA: begin
                    slave.w_addr_ready  <= 1'b0;
                    slave.w_data_ready  <= 1'b0;
                    memory.w_resp_ready <= 1'b0;
                    if (slave.w_data_valid) begin
                        state <= WRITE_MEM_REQ;
                        memory.w_addr <= curr_addr;
                        memory.w_data <= slave.w_data;
                        curr_addr     <= curr_addr + ADDR_INCR;
                        if (slave.w_last)
                            w_last <= 1'b1;
                        memory.w_valid <= 1'b1;
                        if (error) begin
                            state <= WRITE_DATA;
                            if (slave.w_last)
                                state <= WRITE_RESP;
                            memory.w_valid <= 1'b0; 
                        end
                        slave.w_data_ready <= 1'b1;
                    end
                end
                WRITE_MEM_REQ: begin
                    slave.w_data_ready <= 1'b0;
                    if (memory.w_valid) begin
                        if (memory.w_ready) begin
                            state <= WRITE_MEM_RESP;
                            memory.w_valid <= 1'b0; 
                        end
                    end
                end
                WRITE_MEM_RESP: begin
                    if (memory.w_resp_valid) begin
                        state <= WRITE_DATA;
                        if (memory.w_resp != memory_pkg::SUCCESS)
                            error <= 1'b1;
                        if (w_last) begin
                            state <= WRITE_RESP;
                        end
                        memory.w_resp_ready <= 1'b1;
                    end
                end
                WRITE_RESP: begin
                    if (slave.w_resp_valid) begin
                        if (slave.w_resp_ready) begin
                            state              <= IDLE;
                            slave.w_resp_valid <= 1'b0;
                        end
                    end
                    else begin
                        slave.w_resp_id <= curr_id;
                        slave.w_resp    <= axi_pkg::OKAY;
                        if (error)
                            slave.w_resp <= axi_pkg::DECERR;
                        slave.w_resp_valid <= 1'b1;  
                    end
                end
                default:
                    state <= IDLE;
            endcase
        end 
    end
endmodule
