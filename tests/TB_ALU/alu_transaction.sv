

class alu_transaction extends uvm_sequence_item;

    // note to self:    uvm_compnent_utils is when UVM class is a component
    //                  uvm_object_utils is when UVM class is an objec

    `uvm_object_utils(alu_transaction)

    rand logic [31:0] srcA;
    rand logic [31:0] srcB;
    rand alu_op_t alu_fun;

    logic [31:0] result;

    function new(string name = "alu_transaction");
        super.new(name);
    endfunction
    
endclass
