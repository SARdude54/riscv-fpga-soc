
// The sequencer arbitrates transactions between sequences and the driver
// Will manage a bunch of transaction traffic. 
// May be overkill for ALU, but need to understand this for further CPU
// verification later on

class alu_sequencer extends uvm_sequencer #(alu_transaction);

    `uvm_component_utils(alu_sequencer)

    function new(string name = "alu_sequencer",
                    uvm_component parent = null);
            super.new(name, parent);
    endfunction

endclass
