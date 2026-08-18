class config_path_env extends uvm_env;
    `uvm_component_utils(config_path_env)

    user_agent user_agent_inst;
    axi4lite_monitor axi4lite_monitor_inst;
    adapter_monitor adapter_monitor_inst;
    regfile_agent regfile_agent_inst;
    config_path_scoreboard scoreboard;

    function new(string name = "config_path_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        user_agent_inst       = user_agent             :: type_id::create("user_agent_inst", this);
        axi4lite_monitor_inst = axi4lite_monitor       :: type_id::create("axi4lite_monitor_inst", this);
        adapter_monitor_inst  = adapter_monitor        :: type_id::create("adapter_monitor_inst", this);
        regfile_agent_inst    = regfile_agent          :: type_id::create("regfile_agent_inst", this);
        scoreboard            = config_path_scoreboard :: type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        user_agent_inst       .req_ap  .connect(scoreboard.user_req_export);
        user_agent_inst       .resp_ap .connect(scoreboard.user_resp_export);
        axi4lite_monitor_inst .req_ap  .connect(scoreboard.axi4lite_req_export);
        axi4lite_monitor_inst .resp_ap .connect(scoreboard.axi4lite_resp_export);
        adapter_monitor_inst  .req_ap  .connect(scoreboard.adapter_req_export);
        adapter_monitor_inst  .resp_ap .connect(scoreboard.adapter_resp_export);
        regfile_agent_inst    .req_ap  .connect(scoreboard.regfile_req_export);
        regfile_agent_inst    .resp_ap .connect(scoreboard.regfile_resp_export);
    endfunction
endclass
