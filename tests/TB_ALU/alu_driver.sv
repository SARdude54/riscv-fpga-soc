class alu_driver extends uvm_driver #(alu_transaction);

    `uvm_component_utils(alu_driver)

    virtual alu_if vif; // virtual because class is abstraction, it doesn't physically connect ports like a module
                        // so its a reference
                        // The driver will get a reference to an already-existing interface instance

    function new(string name = "alu_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // The driver needs to obtain the interface
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // The driver will ask for the object stored as "vif"
        if(!uvm_config_db #(virtual alu_if)::get(
            this,
            "",
            "vif", // key
            vif // value
        )) begin
            `uvm_fatal("NO_VIF", "alu_driver could not get virtual interface")
        end

    endfunction

    // transaction handshake
    task run_phase(uvm_phase phase);
        alu_transaction tx;

        forever begin
        
            seq_item_port.get_next_item(tx);

            vif.srcA = tx.srcA;
            vif.srcB = tx.srcB;
            vif.alu_fun = tx.alu_fun;

            #1; // ALU is combinational, so it needs at least a simulation delta cycle

            seq_item_port.item_done();

        end 

    endtask

    // NOTE: seq_item_port.get_next_item(tx)
    //          asks the sequencer for the next transaction.

    // NOTE: seq_item_port.item_done(tx)
    //          means the drivewr has finished processing this sequence item


endclass