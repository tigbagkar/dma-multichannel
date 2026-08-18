class user_req_write_sequence extends uvm_sequence #(user_req_item);
    `uvm_object_utils(user_req_write_sequence)

    int unsigned num_transactions = 40;

    function new(string name = "user_req_write_sequence");
        super.new(name);
    endfunction

    task body();
        user_req_item item;

        repeat (num_transactions) begin
            item = user_req_item::type_id::create("item");
            start_item(item);
            item.is_write = 1;
            item.addr = $urandom;
            item.prot = $urandom_range(7, 0);
            item.data = $urandom;
            item.strb = $urandom_range((1 << STRB_W) - 1, 0);
            finish_item(item);
        end
    endtask
endclass

class user_req_read_sequence extends uvm_sequence #(user_req_item);
    `uvm_object_utils(user_req_read_sequence)

    int unsigned num_transactions = 40;

    function new(string name = "user_req_read_sequence");
        super.new(name);
    endfunction

    task body();
        user_req_item item;

        repeat (num_transactions) begin
            item = user_req_item::type_id::create("item");
            start_item(item);
            item.is_write = 0;
            item.addr = $urandom;
            item.prot = $urandom_range(7, 0);
            finish_item(item);
        end
    endtask
endclass