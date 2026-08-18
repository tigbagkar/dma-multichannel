import uvm_pkg::*;
`include "uvm_macros.svh"

module axi4lite_if_bind_wrapper (axi4lite_if axi4lite);
    initial begin
        uvm_config_db #(virtual axi4lite_if)::set(null, "*.axi4lite_monitor_inst", "vif", axi4lite);
    end
endmodule

module adapter_if_bind_wrapper (axi4lite_adapter_if adapter);
    initial begin
        uvm_config_db #(virtual axi4lite_adapter_if)::set(null, "*.adapter_monitor_inst", "vif", adapter);
    end
endmodule

bind config_path axi4lite_if_bind_wrapper   u_axi4lite_if_bind_wrapper   (.axi4lite (axi4lite_if_inst));
bind config_path adapter_if_bind_wrapper    u_adapter_if_bind_wrapper    (.adapter  (axi4lite_adapter_if_inst));