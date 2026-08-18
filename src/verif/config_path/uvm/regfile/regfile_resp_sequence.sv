class regfile_resp_write_sequence extends uvm_sequence #(regfile_resp_item);
    `uvm_object_utils(regfile_resp_write_sequence)

    int unsigned num_transactions = 40;

    function new(string name = "regfile_resp_write_sequence");
        super.new(name);
    endfunction

    task body();
        regfile_resp_item item;

        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::SUCCESS;
            finish_item(item);
        end
        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::INVALID_ADDRESS;
            finish_item(item);
        end
        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::READ_ONLY;
            finish_item(item);
        end
        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::WRITE_PROTECTED;
            finish_item(item);
        end
    endtask
endclass

class regfile_resp_read_sequence extends uvm_sequence #(regfile_resp_item);
    `uvm_object_utils(regfile_resp_read_sequence)

    int unsigned num_transactions = 40;

    function new(string name = "regfile_resp_read_sequence");
        super.new(name);
    endfunction

    task body();
        regfile_resp_item item;
        
        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::SUCCESS;
            item.r_data       = $urandom;
            finish_item(item);
        end
        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::INVALID_ADDRESS;
            item.r_data       = $urandom;
            finish_item(item);
        end
        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::READ_ONLY;
            item.r_data       = $urandom;
            finish_item(item);
        end
        repeat (num_transactions/4) begin
            item = regfile_resp_item::type_id::create("item");
            start_item(item);
            item.regfile_resp = regfile_pkg::WRITE_PROTECTED;
            item.r_data       = $urandom;
            finish_item(item);
        end
    endtask
endclass