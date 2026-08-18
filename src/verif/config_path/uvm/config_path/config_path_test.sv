class config_path_test extends uvm_test;
    `uvm_component_utils(config_path_test)

    config_path_env       env;
    user_driver_config    user_cfg;
    regfile_driver_config regfile_cfg;
    virtual clk_rst_if    clk_vif;

    function new(string name = "config_path_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = config_path_env::type_id::create("env", this);

        user_cfg = user_driver_config::type_id::create("user_cfg");
        uvm_config_db #(user_driver_config)::set(this, "env.user_agent_inst.driver", "cfg", user_cfg);

        regfile_cfg = regfile_driver_config::type_id::create("regfile_cfg");
        uvm_config_db #(regfile_driver_config)::set(this, "env.regfile_agent_inst.driver", "cfg", regfile_cfg);

        if (!uvm_config_db #(virtual clk_rst_if)::get(this, "", "clk_vif", clk_vif))
            `uvm_fatal("NOVIF", "config_path_test: virtual interface 'clk_vif' not set via uvm_config_db")
    endfunction

    task run_phase(uvm_phase phase);
        user_req_write_sequence     user_write_sequence;
        regfile_resp_write_sequence regfile_write_sequence;
        user_req_read_sequence      user_read_sequence;
        regfile_resp_read_sequence  regfile_read_sequence;
        
        phase.raise_objection(this);

        user_write_sequence    = user_req_write_sequence     :: type_id::create("user_write_sequence");
        regfile_write_sequence = regfile_resp_write_sequence :: type_id::create("regfile_write_sequence");

        fork
            user_write_sequence    .start(env.user_agent_inst    .sequencer);
            regfile_write_sequence .start(env.regfile_agent_inst .sequencer);
        join

        user_read_sequence    = user_req_read_sequence     :: type_id::create("user_read_sequence");
        regfile_read_sequence = regfile_resp_read_sequence :: type_id::create("regfile_read_sequence");

        fork
            user_read_sequence    .start(env.user_agent_inst    .sequencer);
            regfile_read_sequence .start(env.regfile_agent_inst .sequencer);
        join

        repeat (20) @(posedge clk_vif.clk);

        phase.drop_objection(this);
    endtask
endclass
