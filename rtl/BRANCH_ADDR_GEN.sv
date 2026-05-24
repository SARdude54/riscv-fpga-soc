`timescale 1ns / 1ps

module BRANCH_ADDR_GEN(J_type, B_type, I_type, rs, PC, jal, branch, jalr);
    input [31:0] J_type, B_type, I_type, rs, PC;
    output [31:0] jal, branch, jalr;
    assign jal = (PC + J_type);
    assign jalr = (rs + I_type);
    assign branch = (PC + B_type);
endmodule
