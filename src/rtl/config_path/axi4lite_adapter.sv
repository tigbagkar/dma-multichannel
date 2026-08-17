import axi_pkg     :: axi_resp_t;
import regfile_pkg :: regfile_resp_t;

module axi4lite_adapter (
    input logic                        clk,
    input logic                        rst_n,
    axi4lite_adapter_if .adapter       slave,
    regfile_config_if   .config_source regfile
);
    typedef enum logic [2:0] {  
        IDLE            = 3'b000,
        WRITE_REQ       = 3'b001,
        WRITE_WAIT_ADDR = 3'b010,
        WRITE_WAIT_DATA = 3'b011,
        WRITE_WAIT_RESP = 3'b100,
        READ_REQ        = 3'b101,
        READ_WAIT_RESP  = 3'b110
    } state_t;
    state_t state;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;

            regfile.w_valid      <= 1'b0;
            regfile.w_resp_ready <= 1'b0;
            regfile.r_valid      <= 1'b0;
            regfile.r_resp_ready <= 1'b0;

            slave.w_addr_ready   <= 1'b0;
            slave.w_data_ready   <= 1'b0;
            slave.w_resp_valid   <= 1'b0;
            slave.r_ready        <= 1'b0;
            slave.r_resp_valid   <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (slave.w_addr_valid && slave.w_data_valid) begin
                        state              <= WRITE_REQ;
                        regfile.w_addr     <= slave.w_addr;
                        regfile.w_prot     <= slave.w_prot;
                        regfile.w_data     <= slave.w_data;
                        regfile.w_strb     <= slave.w_strb;
                        regfile.w_valid    <= 1'b1;
                        slave.w_addr_ready <= 1'b1;
                        slave.w_data_ready <= 1'b1;
                    end 
                    else if (slave.r_valid) begin
                       state               <= READ_REQ;
                       regfile.r_addr      <= slave.r_addr;
                       regfile.r_prot      <= slave.r_prot;
                       regfile.r_valid     <= 1'b1;
                       slave.r_ready       <= 1'b1; 
                    end
                    else if (slave.w_addr_valid && !slave.w_data_valid) begin
                        state              <= WRITE_WAIT_DATA;
                        regfile.w_addr     <= slave.w_addr;
                        regfile.w_prot     <= slave.w_prot;
                        slave.w_addr_ready <= 1'b1;
                    end
                    else if (!slave.w_addr_valid && slave.w_data_valid) begin
                        state              <= WRITE_WAIT_ADDR;
                        regfile.w_data     <= slave.w_data;
                        regfile.w_strb     <= slave.w_strb;
                        slave.w_data_ready <= 1'b1;
                    end
                end
                WRITE_REQ: begin
                    slave.w_addr_ready <= 1'b0;
                    slave.w_data_ready <= 1'b0;
                    if (regfile.w_valid) begin
                        if (regfile.w_ready) begin
                            state           <= WRITE_WAIT_RESP;
                            regfile.w_valid <= 1'b0;                   
                        end
                    end
                end
                WRITE_WAIT_DATA: begin
                    slave.w_addr_ready <= 1'b0;
                    slave.w_data_ready <= 1'b0;
                    if (regfile.w_valid) begin
                        if (regfile.w_ready) begin
                            state           <= WRITE_WAIT_RESP;
                            regfile.w_valid <= 1'b0;
                        end
                    end
                    else if (slave.w_data_valid) begin
                        regfile.w_data     <= slave.w_data;
                        regfile.w_strb     <= slave.w_strb;
                        regfile.w_valid    <= 1'b1;
                        slave.w_data_ready <= 1'b1;
                    end
                end
                WRITE_WAIT_ADDR: begin
                    slave.w_addr_ready <= 1'b0;
                    slave.w_data_ready <= 1'b0;
                    if (regfile.w_valid) begin
                        if (regfile.w_ready) begin
                            state           <= WRITE_WAIT_RESP;
                            regfile.w_valid <= 1'b0;
                        end
                    end
                    else if (slave.w_addr_valid) begin
                        regfile.w_addr     <= slave.w_addr;
                        regfile.w_prot     <= slave.w_prot;
                        regfile.w_valid    <= 1'b1;
                        slave.w_addr_ready <= 1'b1;
                    end
                end
                WRITE_WAIT_RESP: begin
                    regfile.w_resp_ready <= 1'b0;
                    if (slave.w_resp_valid) begin
                        if (slave.w_resp_ready) begin
                            state              <= IDLE;
                            slave.w_resp_valid <= 1'b0;
                        end
                    end
                    else if (regfile.w_resp_valid) begin
                        slave.w_resp         <= map_resp(regfile.w_resp);
                        slave.w_resp_valid   <= 1'b1;
                        regfile.w_resp_ready <= 1'b1;
                    end
                end
                READ_REQ: begin
                    slave.r_ready <= 1'b0;
                    if (regfile.r_valid) begin
                        if (regfile.r_ready) begin
                            state           <= READ_WAIT_RESP;
                            regfile.r_valid <= 1'b0;
                        end
                    end 
                end
                READ_WAIT_RESP: begin
                    regfile.r_resp_ready <= 1'b0;
                    if (slave.r_resp_valid) begin
                        if (slave.r_resp_ready) begin
                            state              <= IDLE;
                            slave.r_resp_valid <= 1'b0;
                        end
                    end
                    else if (regfile.r_resp_valid) begin
                        slave.r_resp         <= map_resp(regfile.r_resp);
                        slave.r_data         <= regfile.r_data;
                        slave.r_resp_valid   <= 1'b1;
                        regfile.r_resp_ready <= 1'b1;
                    end
                end
                default:
                    state <= IDLE;
            endcase
        end
    end

    function axi_resp_t map_resp(input regfile_resp_t regfile_resp);
        case (regfile_resp)
            regfile_pkg::SUCCESS:
                return axi_pkg::OKAY; 
            regfile_pkg::INVALID_ADDRESS:
                return axi_pkg::DECERR;
            regfile_pkg::READ_ONLY:
                return axi_pkg::SLVERR;
            regfile_pkg::WRITE_PROTECTED:
                return axi_pkg::SLVERR;
            default:
                return axi_pkg::SLVERR;
        endcase
    endfunction
endmodule
