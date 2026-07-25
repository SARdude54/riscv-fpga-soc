`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    import alu_pkg::*;

    alu_if alu_vif();

    ALU dut (
        .srcA(alu_vif.srcA),
        .srcB(alu_vif.srcB),
        .alu_fun(alu_vif.alu_fun),
        .result(alu_vif.result)

    );

    initial begin
     
        uvm_config_db #(virtual alu_if)::set( // store the UVM components
            null,
            "*", // make available throughout the UVM hierarchy
            "vif",
            alu_vif
        );

        run_test("alu_test");

    end

endmodule
