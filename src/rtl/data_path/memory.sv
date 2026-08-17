import global_pkg :: ADDR_W;
import global_pkg :: DATA_W;
import memory_pkg :: MEM_SIZE_W;
import memory_pkg :: MEM_SIZE;

module memory(
    input logic       clk, 
    input logic       rst_n,
    memory_if .memory adapter
);
    logic [DATA_W-1:0] regs [MEM_SIZE-1:0];

    typedef enum {
        IDLE,
        WRITE_REQ,
        WRITE_RESP,
        READ_REQ,
        READ_RESP
    } state_t;
    state_t state;

    logic [ADDR_W-1:0] addr;
    logic [DATA_W-1:0] data;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adapter.w_ready      <= 1'b0;
            adapter.w_resp_valid <= 1'b0;
            adapter.r_ready      <= 1'b0;
            adapter.r_resp_valid <= 1'b0; 
        end
        else begin
            case (state)
                IDLE: begin
                    if (adapter.w_valid) begin
                        state <= WRITE_REQ;
                    end
                    else if (adapter.r_valid) begin
                        state <= READ_REQ;
                    end
                end
                WRITE_REQ: begin
                    state           <= WRITE_RESP;
                    addr            <= adapter.w_addr;
                    data            <= adapter.w_data;
                    adapter.w_ready <= 1'b1;
                end
                WRITE_RESP: begin
                    adapter.w_ready <= 1'b0;
                    if (adapter.w_resp_valid) begin
                        if (adapter.w_resp_ready) begin
                            state                <= IDLE;
                            adapter.w_resp_valid <= 1'b0; 
                        end
                    end
                    else begin
                        adapter.w_resp <= memory_pkg::SUCCESS;
                        if (addr[ADDR_W-1:2] >= MEM_SIZE)
                            adapter.w_resp <= memory_pkg::INVALID_ADDRESS;
                        else begin
                            regs[addr[ADDR_W-1:2]] <= data;   
                        end
                        adapter.w_resp_valid <= 1'b1;
                    end
                end
                READ_REQ: begin
                    state           <= READ_RESP;
                    addr            <= adapter.r_addr;
                    adapter.r_ready <= 1'b1;
                end
                READ_RESP: begin
                    adapter.r_ready <= 1'b0;
                    if (adapter.r_resp_valid) begin
                        if (adapter.r_resp_ready) begin
                            state                <= IDLE;
                            adapter.r_resp_valid <= 1'b0; 
                        end
                    end
                    else begin
                        adapter.r_resp <= memory_pkg::SUCCESS;
                        if (addr[ADDR_W-1:2] >= MEM_SIZE) begin
                            adapter.r_resp <= memory_pkg::INVALID_ADDRESS;
                            adapter.r_data <= '0; 
                        end
                        else 
                            adapter.r_data <= regs[addr[ADDR_W-1:2]];
                        adapter.r_resp_valid <= 1'b1;
                    end
                end
                default: 
                    state <= IDLE;
            endcase
        end
    end
endmodule
