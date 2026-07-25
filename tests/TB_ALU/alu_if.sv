
interface alu_if;

    import isa_pkg::*;

    logic [31:0] srcA;
    logic [31:0] srcB;
    alu_op_t     alu_fun;
    logic [31:0] result;

endinterface
