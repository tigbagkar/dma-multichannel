import global_pkg :: NUM_CH;
import global_pkg :: CH_IDX_W;

module arbiter(
    input logic                 clk,
    input logic                 rst_n,
    arbiter_if         .arbiter channels,
    transfer_engine_if .arbiter transfer_engine
);
    logic                queue [NUM_CH-1:0];
    logic [CH_IDX_W-1:0] grant_counter,      curr_grant;
    logic [CH_IDX_W-1:0] grant_counter_next, curr_grant_next;
    logic                found;

    typedef enum logic [1:0] {
        IDLE,
        GRANT_WAIT,
        COMPLETE_WAIT
    } state_t;
    state_t state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            
            grant_counter <= '0;
            curr_grant    <= '0;

            transfer_engine.grant_valid    <= 1'b0;
            transfer_engine.complete_ready <= 1'b0;
            
            for (int i = 0; i < NUM_CH; i++) begin
                queue [i] <= 1'b0;
                
                channels.descriptor_ready [i] <= 1'b0;
                channels.complete_valid   [i] <= 1'b0;
            end
        end
        else begin
            case (state)
                IDLE: begin
                    transfer_engine.complete_ready <= 1'b0;
                    if (found) begin
                        state <= GRANT_WAIT;

                        curr_grant    <= curr_grant_next;
                        grant_counter <= grant_counter_next;

                        transfer_engine.ch_id       <= curr_grant_next;
                        transfer_engine.grant_valid <= 1'b1;
                        if (channels.descriptor_valid[curr_grant_next] && !queue[curr_grant_next]) begin
                            queue              [curr_grant_next] <= 1'b1;
                            channels.descriptor_ready [curr_grant_next] <= 1'b1;
                            transfer_engine.src                         <= channels.src  [curr_grant_next];
                            transfer_engine.dst                         <= channels.dst  [curr_grant_next];
                            transfer_engine.xfer                        <= channels.xfer [curr_grant_next];    
                        end
                    end
                    else begin
                        state <= IDLE; 
                    end
                end
                GRANT_WAIT: begin
                    channels.descriptor_ready[curr_grant] <= 1'b0;
                    if (transfer_engine.grant_valid) begin
                        if (transfer_engine.grant_ready) begin
                            state                <= COMPLETE_WAIT;
                            transfer_engine.grant_valid <= 1'b0; 
                        end
                    end
                end
                COMPLETE_WAIT: begin
                    transfer_engine.complete_ready <= 1'b0;
                    if (channels.complete_valid[curr_grant]) begin
                        if (channels.complete_ready[curr_grant]) begin
                            channels.complete_valid[curr_grant] <= 1'b0;
                            state                          <= IDLE; 
                        end
                    end
                    else if (transfer_engine.complete_valid) begin
                        transfer_engine.complete_ready <= 1'b1;
                        if (transfer_engine.error) begin
                            queue                   [curr_grant] <= 1'b0;
                            channels.done           [curr_grant] <= 1'b0;
                            channels.error          [curr_grant] <= 1'b1;
                            channels.complete_valid [curr_grant] <= 1'b1;
                        end
                        else if (transfer_engine.transfer_done) begin
                            queue                   [curr_grant] <= 1'b0;
                            channels.done           [curr_grant] <= 1'b1;
                            channels.error          [curr_grant] <= 1'b0;
                            channels.complete_valid [curr_grant] <= 1'b1;
                        end
                        else if (transfer_engine.burst_done) begin
                            state <= IDLE;
                        end
                        else begin
                            queue                   [curr_grant] <= 1'b0;
                            channels.done           [curr_grant] <= 1'b0;
                            channels.error          [curr_grant] <= 1'b1;
                            channels.complete_valid [curr_grant] <= 1'b1;
                        end
                    end
                end
                default:
                    state <= IDLE;   
            endcase
        end
    end

    always_comb begin
        int idx;
        found              = 1'b0;
        curr_grant_next    = curr_grant;
        grant_counter_next = grant_counter;
        
        idx = 0;
        if (state == IDLE) begin
            for (int i = 0; i < NUM_CH; i++) begin
                idx = (grant_counter + i) % NUM_CH;
                if (!found && (channels.descriptor_valid[idx] || queue[idx])) begin
                    curr_grant_next    = idx;
                    grant_counter_next = (idx + 1) % NUM_CH;
                    found              = 1'b1; 
                end
            end
        end 
    end
endmodule
