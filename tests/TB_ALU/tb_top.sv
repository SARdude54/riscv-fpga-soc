`timescale 1ns/1ps

module tb_top;

    alu_if alu_vif();

    ALU dut (
        .srcA(alu_vif.srcA),
        .srcB(alu_vif.srcB),
        .alu_fun(alu_vif.alu_fun),
        .result(alu_vif.result)

    );
endmodule
