
class alu_sequence extends uvm_sequence #(alu_transaction);

    // A sequence is an object that gets created, runs, generates transactions,
    // then dissappears. It represents a strategy for producing operations
    
    `uvm_object_utils(alu_sequence) 

    function new(string name = "alu_sequence");
        super.new(name);
    endfunction

    // performs work in here
    virtual task body();
        // ask: what should this sequence run?
        // For this alu sequence, it should generate many randomized ALU
        //  transactions

        alu_transaction tx;

        // create through the factory
        tx = alu_transaction::type_id::create("tx"); // uvm factory construction

        // Tells the sequencer for permission to send this item
        // The sequencer may arbitrate between multiple sequences.
        // This allows the sequence ot participate in that arbitration.
        start_item(tx);

        tx.srcA    = 32'd5;
        tx.srcB    = 32'd7;
        tx.alu_fun = ALU_ADD;

        // completes the request
        // blocks until the driver completes the handshake
        finish_item(tx);

        // SUB
        tx = alu_transaction::type_id::create("tx_sub");

        start_item(tx);

        tx.srcA    = 32'd20;
        tx.srcB    = 32'd8;
        tx.alu_fun = ALU_SUB;

        finish_item(tx);


        // AND
        tx = alu_transaction::type_id::create("tx_and");

        start_item(tx);

        tx.srcA    = 32'hFFFF_00FF;
        tx.srcB    = 32'h0F0F_0F0F;
        tx.alu_fun = ALU_AND;

    endtask

endclass