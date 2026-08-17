import global_pkg  :: ADDR_W;
import global_pkg  :: DATA_W;
import global_pkg  :: STRB_W;
import global_pkg  :: NUM_CH;
import global_pkg  :: CH_IDX_W;
import regfile_pkg :: OFS_W;
import regfile_pkg :: MSB_POS;
import regfile_pkg :: OFS_CTRL;
import regfile_pkg :: OFS_STATUS;
import regfile_pkg :: OFS_SRC;
import regfile_pkg :: OFS_DST;
import regfile_pkg :: OFS_XFER;
import regfile_pkg :: global_regs_t;
import regfile_pkg :: channel_regs_t;

module regfile (
    input logic                clk,
    input logic                rst_n,
    regfile_config_if .regfile config_source,
    channels_if       .regfile channels,
    user_irq_if       .source  irq_out
);
    global_regs_t  global_regs;
    channel_regs_t channel_regs [NUM_CH-1:0];

    typedef enum logic [1:0] {
        IDLE,
        WRITE_RESP,
        READ_RESP
    } state_t;
    state_t state;

    logic [ADDR_W-1:0]   latch_addr;
    logic [2:0]          latch_prot;
    logic [DATA_W-1:0]   latch_data;
    logic [STRB_W-1:0]   latch_strb;
    logic [CH_IDX_W-1:0] ch;
    assign ch = latch_addr[MSB_POS-1:OFS_W];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state                      <= IDLE;
            config_source.w_ready      <= 1'b0;
            config_source.w_resp_valid <= 1'b0;
            config_source.r_ready      <= 1'b0;
            config_source.r_resp_valid <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (config_source.w_valid) begin
                        state                 <= WRITE_RESP;
                        latch_addr            <= config_source.w_addr;
                        latch_prot            <= config_source.w_prot;
                        latch_data            <= config_source.w_data;
                        latch_strb            <= config_source.w_strb;
                        config_source.w_ready <= 1'b1;
                    end
                    else if (config_source.r_valid) begin
                        state                 <= READ_RESP;
                        latch_addr            <= config_source.r_addr;
                        latch_prot            <= config_source.r_prot;
                        config_source.r_ready <= 1'b1;
                    end                    
                end
                WRITE_RESP: begin
                    config_source.w_ready <= 1'b0;
                    if (config_source.w_resp_valid) begin
                        if (config_source.w_resp_ready) begin
                            state                      <= IDLE;
                            config_source.w_resp_valid <= 1'b0;
                        end
                    end
                    else if (latch_addr[MSB_POS]) begin
                        config_source.w_resp <= regfile_pkg::SUCCESS;
                        case (latch_addr[OFS_W-1:0])
                            OFS_CTRL: begin
                                if (channel_regs[ch].status.busy) 
                                    config_source.w_resp <= regfile_pkg::WRITE_PROTECTED;
                                else 
                                    channel_regs[ch].ctrl <= apply_strb(
                                        channel_regs[ch].ctrl, 
                                        latch_data, 
                                        latch_strb
                                    );
                            end
                            OFS_STATUS: begin
                                config_source.w_resp <= regfile_pkg::READ_ONLY;
                            end 
                            OFS_SRC: begin
                                if (channel_regs[ch].status.busy) 
                                    config_source.w_resp <= regfile_pkg::WRITE_PROTECTED;
                                else 
                                    channel_regs[ch].src <= apply_strb(
                                        channel_regs[ch].src, 
                                        latch_data,     
                                        latch_strb
                                    );
                            end
                            OFS_DST: begin
                                if (channel_regs[ch].status.busy)
                                    config_source.w_resp <= regfile_pkg::WRITE_PROTECTED;
                                else 
                                    channel_regs[ch].dst <= apply_strb(
                                        channel_regs[ch].dst, 
                                        latch_data, 
                                        latch_strb
                                    );     
                            end
                            OFS_XFER: begin
                                if (channel_regs[ch].status.busy) 
                                    config_source.w_resp <= regfile_pkg::WRITE_PROTECTED;
                                else 
                                    channel_regs[ch].xfer <= apply_strb(
                                        channel_regs[ch].xfer, 
                                        latch_data, 
                                        latch_strb
                                    );
                            end
                            default: 
                                config_source.w_resp <= regfile_pkg::INVALID_ADDRESS;
                        endcase
                        config_source.w_resp_valid <= 1'b1;
                    end
                    else begin
                        if (latch_addr[MSB_POS-1:OFS_W] == '0) begin
                            config_source.w_resp <= regfile_pkg::SUCCESS;
                            case (latch_addr[OFS_W-1:0])
                                OFS_CTRL: begin
                                    if (global_regs.status.busy) 
                                        config_source.w_resp <= regfile_pkg::WRITE_PROTECTED; 
                                    else 
                                        global_regs.ctrl <= apply_strb(
                                            global_regs.ctrl, 
                                            latch_data, 
                                            latch_strb
                                        );
                                end
                                OFS_STATUS: 
                                    config_source.w_resp <= regfile_pkg::READ_ONLY;
                                default:     
                                    config_source.w_resp <= regfile_pkg::INVALID_ADDRESS;        
                            endcase
                        end
                        else begin 
                            config_source.w_resp <= regfile_pkg::INVALID_ADDRESS;
                        end    
                        config_source.w_resp_valid <= 1'b1;
                    end         
                end
                READ_RESP: begin
                    config_source.r_ready <= 1'b0;
                    if (config_source.r_resp_valid) begin
                        if (config_source.r_resp_ready) begin
                            state                      <= IDLE;
                            config_source.r_resp_valid <= 1'b0;
                        end
                    end
                    else if (latch_addr[MSB_POS]) begin
                        config_source.r_resp <= regfile_pkg::SUCCESS;
                        case (latch_addr[OFS_W-1:0])
                            OFS_CTRL:   
                                config_source.r_data <= channel_regs[ch].ctrl; 
                            OFS_STATUS: 
                                config_source.r_data <= channel_regs[ch].status;
                            OFS_SRC:    
                                config_source.r_data <= channel_regs[ch].src;
                            OFS_DST:    
                                config_source.r_data <= channel_regs[ch].dst;
                            OFS_XFER:   
                                config_source.r_data <= channel_regs[ch].xfer;
                            default: begin
                                config_source.r_data <= '0;
                                config_source.r_resp <= regfile_pkg::INVALID_ADDRESS;
                            end
                        endcase
                        config_source.r_resp_valid <= 1'b1;
                    end
                    else begin
                        config_source.r_resp <= regfile_pkg::SUCCESS;
                        case (latch_addr[OFS_W-1:0])
                            OFS_CTRL:   
                                config_source.r_data <= global_regs.ctrl;
                            OFS_STATUS: 
                                config_source.r_data <= global_regs.status;
                            default: begin
                                config_source.r_data <= '0;
                                config_source.r_resp <= regfile_pkg::INVALID_ADDRESS;
                            end
                        endcase
                        config_source.r_resp_valid <= 1'b1;
                    end 
                end
                default: 
                    state <= IDLE;
            endcase 

            channels.global_ctrl <= global_regs.ctrl;
            for (int i = 0; i < NUM_CH; i++) begin

                if (channel_regs[i].ctrl.start) begin
                    channel_regs[i].status.done  <= 1'b0;
                    channel_regs[i].status.irq   <= 1'b0;
                    channel_regs[i].status.error <= 1'b0; 
                end

                if (channels.start_clear[i])
                    channel_regs[i].ctrl.start   <= 1'b0;
                if (channels.busy_set[i])
                    channel_regs[i].status.busy  <= 1'b1;
                if (channels.busy_clear[i])
                    channel_regs[i].status.busy  <= 1'b0;
                if (channels.done_set[i]) 
                    channel_regs[i].status.done  <= 1'b1;
                if (channels.irq_set[i])
                    channel_regs[i].status.irq   <= 1'b1;
                if (channels.error_set[i])
                    channel_regs[i].status.error <= 1'b1;
                
                channels.channel_ctrl[i] <= channel_regs[i].ctrl;
                channels.src[i]          <= channel_regs[i].src;
                channels.dst[i]          <= channel_regs[i].dst;
                channels.xfer[i]         <= channel_regs[i].xfer; 

                irq_out.irq[i] <= channel_regs[i].status.irq;
            end
        end 
    end

    always_comb begin
        global_regs.status.busy  = 1'b0;
        global_regs.status.done  = 1'b0;
        global_regs.status.irq   = 1'b0;
        global_regs.status.error = 1'b0;
        for (int i = 0; i < NUM_CH; i++) begin
            global_regs.status.busy  = global_regs.status.busy  || channel_regs[i].status.busy;
            global_regs.status.done  = global_regs.status.done  || channel_regs[i].status.done;
            global_regs.status.irq   = global_regs.status.irq   || channel_regs[i].status.irq;
            global_regs.status.error = global_regs.status.error || channel_regs[i].status.error;
        end
    end
    
    function logic [DATA_W-1:0] apply_strb (
        input logic [DATA_W-1:0] old_val,
        input logic [DATA_W-1:0] new_val,
        input logic [STRB_W-1:0] strb
    );
        logic [DATA_W-1:0] result;
        result = old_val;
        for (int i = 0; i < STRB_W; i++) begin
            if (strb[i]) 
                result[i*8+:8] = new_val[i*8+:8];
        end
        return result;       
    endfunction    
endmodule
