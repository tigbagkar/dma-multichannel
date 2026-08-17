import global_pkg  :: DATA_W;

module channel # (
    parameter int CH_ID = 0
)(
    input logic          clk,
    input logic          rst_n,
    channels_if .channel regfile,
    arbiter_if  .channel arbiter
);
    typedef enum logic [1:0] {
        IDLE           = 2'b00,
        DESCRIPTOR_REQ = 2'b01,
        WAIT_COMPLETE  = 2'b10
    } state_t;    
    state_t state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;

            regfile.start_clear [CH_ID] <= 1'b0;
            regfile.busy_set    [CH_ID] <= 1'b0; 
            regfile.busy_clear  [CH_ID] <= 1'b0;
            regfile.done_set    [CH_ID] <= 1'b0;
            regfile.irq_set     [CH_ID] <= 1'b0;
            regfile.error_set   [CH_ID] <= 1'b0;
            
            arbiter.descriptor_valid [CH_ID] <= 1'b0;
            arbiter.complete_ready   [CH_ID] <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    regfile.busy_clear  [CH_ID] <= 1'b0;
                    regfile.done_set    [CH_ID] <= 1'b0;
                    regfile.irq_set     [CH_ID] <= 1'b0;
                    regfile.error_set   [CH_ID] <= 1'b0;

                    arbiter.complete_ready [CH_ID] <= 1'b0;

                    if (regfile.global_ctrl.enable && 
                        regfile.channel_ctrl[CH_ID].enable && 
                        regfile.channel_ctrl[CH_ID].start) begin
                        state <= DESCRIPTOR_REQ;
                    
                        regfile.start_clear      [CH_ID] <= 1'b1;
                        regfile.busy_set         [CH_ID] <= 1'b1;
                        arbiter.src              [CH_ID] <= regfile.src  [CH_ID];
                        arbiter.dst              [CH_ID] <= regfile.dst  [CH_ID];
                        arbiter.xfer             [CH_ID] <= regfile.xfer [CH_ID];
                        arbiter.descriptor_valid [CH_ID] <= 1'b1;
                    end
                end
                DESCRIPTOR_REQ: begin
                    regfile.start_clear [CH_ID] <= 1'b0;
                    regfile.busy_set    [CH_ID] <= 1'b0;

                    if (arbiter.descriptor_valid[CH_ID]) begin
                        if (arbiter.descriptor_ready[CH_ID]) begin
                            state                           <= WAIT_COMPLETE;
                            arbiter.descriptor_valid[CH_ID] <= 1'b0;
                        end
                    end
                end
                WAIT_COMPLETE: begin
                    if (arbiter.complete_valid[CH_ID]) begin
                        state <= IDLE;

                        if (arbiter.done[CH_ID]) begin
                           regfile.busy_clear [CH_ID] <= 1'b1;
                           regfile.done_set   [CH_ID] <= 1'b1; 
                        end
                        else if (arbiter.error[CH_ID]) begin
                            regfile.busy_clear [CH_ID] <= 1'b1;
                            regfile.error_set  [CH_ID] <= 1'b1;
                        end

                        if (regfile.global_ctrl.irq_enable && 
                            regfile.channel_ctrl[CH_ID].irq_enable) begin
                            regfile.irq_set [CH_ID] <= 1'b1; 
                        end

                        arbiter.complete_ready [CH_ID] <= 1'b1;
                    end
                end
                default:
                    state <= IDLE;
            endcase
        end 
    end
endmodule
