`timescale 1ns / 1ps


module RegFile(
		input logic clk,
		input logic rst,
		input logic en,
		input logic [4:0] addr1,
		input logic [4:0] addr2,
		input logic [4:0] w_addr,
		input logic [31:0] w_data,
		output logic [31:0] rs1,
		output logic [31:0] rs2
	);
    
		//Instantiate 32, 32-bit registers
		logic [31:0] ram[0:31];

		//Create asynchronous reads for RS1, RS2
		assign rs1 = ram[addr1];
		assign rs2 = ram[addr2];

		//Create register flip flop while ensuring that register
		//0 (x0) is never written to and remains 0.
		always_ff@(negedge clk) begin
			if (rst == 1'b1) begin
				for(int i = 0; i < 32; ++i) begin
					ram[i] <= 32'b0;
				end
			end else if (en == 1'b1 && w_addr != 5'd0) begin
				ram[w_addr] <= w_data;
			end
		end 
    
endmodule
