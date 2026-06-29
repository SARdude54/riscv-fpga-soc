`timescale 1ns / 1ps

module BRANCH_ADDR_GEN(
	input		[31:0] J_type, 
	input 	[31:0] B_type, 
	input 	[31:0] I_type, 
	input 	[31:0] rs, 
	input 	[31:0] PC, 
	output 	[31:0] jal, 
	output 	[31:0] branch, 
	output 	[31:0] jalr
);

    assign jal = (PC + J_type);
    assign jalr = (rs + I_type);
    assign branch = (PC + B_type);
endmodule
