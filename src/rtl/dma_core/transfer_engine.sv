import global_pkg :: DATA_W;
import global_pkg :: NUM_CH;
import global_pkg :: CH_IDX_W;
import global_pkg :: MAX_BURST_LEN;
import global_pkg :: MAX_BURST_LEN_W;
import global_pkg :: ADDR_INCR;
import global_pkg :: XFER_DIV;

module transfer_engine(
    input logic                              clk,
    input logic                              rst_n,
    transfer_engine_if      .transfer_engine arbiter,
    transfer_engine_axi4_if .transfer_engine axi
);
    logic                       queue     [NUM_CH-1:0];
    logic [CH_IDX_W-1:0]        curr_ch_id;
    logic [DATA_W-1:0]          curr_src  [NUM_CH-1:0];
    logic [DATA_W-1:0]          curr_dst  [NUM_CH-1:0];
    logic [DATA_W-1:0]          curr_xfer [NUM_CH-1:0];
    logic [MAX_BURST_LEN_W-1:0] buff_read_counter;
    logic [MAX_BURST_LEN_W-1:0] buff_write_counter;
    logic [DATA_W-1:0]          buff      [MAX_BURST_LEN-1:0];
    logic                       error;

    typedef enum logic [2:0] {
        IDLE,
        READ_REQ,
        READ_DATA,
        WRITE_REQ,
        WRITE_DATA,
        WRITE_WAIT_RESP,
        DONE
    } state_t;    
    state_t state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;

            buff_read_counter  <= '0;
            buff_write_counter <= '0;

            arbiter.grant_ready    <= 1'b0;
            arbiter.complete_valid <= 1'b0;
            
            axi.w_addr_valid   <= 1'b0;
            axi.w_data_valid   <= 1'b0;
            axi.r_valid        <= 1'b0;
            axi.r_resp_ready   <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    error <= 1'b0;
                    if (arbiter.grant_valid) begin
                        state      <= READ_REQ;
                        curr_ch_id <= arbiter.ch_id;
                        if (!queue[arbiter.ch_id]) begin
                            curr_src  [arbiter.ch_id] <= arbiter.src;
                            curr_dst  [arbiter.ch_id] <= arbiter.dst;
                            curr_xfer [arbiter.ch_id] <= arbiter.xfer;
                            queue     [arbiter.ch_id] <= 1'b1;
                            if (arbiter.xfer == '0) 
                                state <= DONE;
                        end
                        arbiter.grant_ready <= 1'b1;
                    end
                end
                READ_REQ: begin
                    arbiter.grant_ready <= 1'b0;
                    if (axi.r_valid) begin
                        if (axi.r_ready) begin
                            state       <= READ_DATA;
                            axi.r_valid <= 1'b0;
                        end
                    end
                    else begin
                        if (curr_xfer[curr_ch_id] / XFER_DIV >= MAX_BURST_LEN) begin
                            axi.r_len             <= MAX_BURST_LEN-1;
                            curr_xfer[curr_ch_id] <= curr_xfer[curr_ch_id] - (MAX_BURST_LEN * XFER_DIV); 
                        end
                        else begin
                            axi.r_len             <= curr_xfer[curr_ch_id] / XFER_DIV;
                            curr_xfer[curr_ch_id] <= '0;
                        end
                        
                        axi.r_id     <= 1'b0;
                        axi.r_addr   <= curr_src[curr_ch_id];
                        axi.r_size   <= 3'b010;
                        axi.r_burst  <= 3'b000;
                        axi.r_lock   <= 1'b0;
                        axi.r_cache  <= '0;
                        axi.r_prot   <= '0;
                        axi.r_qos    <= '0;
                        axi.r_region <= '0;
                        axi.r_valid  <= 1'b1; 
                    end
                end
                READ_DATA: begin
                    axi.r_resp_ready <= 1'b0;
                    if (axi.r_resp_valid) begin
                        buff[buff_read_counter] <= axi.r_data;
                        curr_src[curr_ch_id]    <= curr_src[curr_ch_id] + ADDR_INCR;
                        buff_read_counter       <= buff_read_counter + 1;
                        axi.r_resp_ready        <= 1'b1;
                        if (axi.r_resp != axi_pkg::OKAY) begin
                            state <= DONE;
                            error <= 1'b1; 
                        end
                        else if (axi.r_last) begin
                            state <= WRITE_REQ; 
                        end
                    end
                end
                WRITE_REQ: begin
                    axi.r_resp_ready <= 1'b0;
                    if (axi.w_addr_valid) begin
                        if (axi.w_addr_ready) begin
                            state            <= WRITE_DATA;
                            axi.w_addr_valid <= 1'b0;
                        end
                    end
                    else begin
                        axi.w_id         <= 1'b0;
                        axi.w_addr       <= curr_dst[curr_ch_id];
                        axi.w_len        <= buff_read_counter - 1;
                        axi.w_size       <= 3'b010; // 4B
                        axi.w_burst      <= 3'b000;
                        axi.w_lock       <= 1'b0;
                        axi.w_cache      <= '0;
                        axi.w_prot       <= '0;
                        axi.w_qos        <= '0;
                        axi.w_region     <= '0;
                        axi.w_addr_valid <= 1'b1; 
                    end
                end
                WRITE_DATA: begin
                    if (axi.w_data_valid) begin
                        if (axi.w_data_ready) 
                            axi.w_data_valid <= 1'b0; 
                        if (axi.w_last) 
                            state <= WRITE_WAIT_RESP; 
                    end
                    else begin
                        if (buff_write_counter == buff_read_counter - 1) 
                            axi.w_last <= 1'b1;
                        axi.w_data           <= buff[buff_write_counter];
                        buff_write_counter   <= buff_write_counter + 1;
                        curr_dst[curr_ch_id] <= curr_dst[curr_ch_id] + ADDR_INCR; 
                        axi.w_data_valid     <= 1'b1;
                    end
                end
                WRITE_WAIT_RESP: begin
                    if (axi.w_resp_valid) begin
                        state            <= DONE;
                        axi.w_resp_ready <= 1'b1; 
                        if (axi.w_resp != axi_pkg::OKAY)
                            error <= 1'b1; 
                    end
                end
                DONE: begin
                    axi.w_resp_ready    <= 1'b0;
                    axi.r_resp_ready    <= 1'b0;
                    arbiter.grant_ready <= 1'b0;
                    if (arbiter.complete_valid) begin
                        if (arbiter.complete_ready) begin
                            state <= IDLE;
                            arbiter.complete_valid <= 1'b0;
                        end
                    end
                    else begin
                        buff_read_counter  <= '0;
                        buff_write_counter <= '0;

                        arbiter.error         <= 1'b0;
                        arbiter.transfer_done <= 1'b0;
                        arbiter.burst_done    <= 1'b0;
                        if (error) begin
                            arbiter.error     <= 1'b1;
                            queue[curr_ch_id] <= 1'b0;
                        end
                        else if (curr_xfer[curr_ch_id] == '0) begin
                            arbiter.transfer_done <= 1'b1;
                            queue[curr_ch_id]     <= 1'b0; 
                        end
                        else 
                            arbiter.burst_done <= 1'b1;
                        
                        arbiter.complete_valid <= 1'b1;
                    end
                end
                default:
                    state <= IDLE;
            endcase    
        end 
    end
endmodule
