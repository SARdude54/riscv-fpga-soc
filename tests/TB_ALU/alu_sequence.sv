
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

        // randomize the "rand" fields 
        if(!tx.randomize()) begin
            `uvm_fatal("RAND_FAIL", "ALU transaction randomization failed")
        end

        // print transaction
        `uvm_info(
            "ALU_SEQ",
            $sformatf("Generrated transaction: srcA=0x08h srcB=0x08h alu_fun=0x08h", 
                tx.srcA, tx.srcB, tx.alu_fun.name()
            ),
            UVM_LOW
        )

    endtask

endclass