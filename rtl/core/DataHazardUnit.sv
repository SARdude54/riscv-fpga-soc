`timescale 1ns/1ps

import isa_pkg::*;


module DataHazardUnit(
    input opcode_t ex_opcode,
	 input opcode_t mem_opcode,
    input logic [4:0] dec_rs1,
    input logic [4:0] dec_rs2,
    input logic [4:0] ex_rs1,
    input logic [4:0] ex_rs2,
    input logic [4:0] ex_rd,
    input logic [4:0] mem_rd,
    input logic [4:0] wb_rd,
    input logic memRegWrite,
    input logic wbRegWrite,
    input logic dec_rs1_used,
    input logic dec_rs2_used,
    input logic ex_rs1_used,
    input logic ex_rs2_used,
	 input logic memRead2,

    output logic [1:0] fsel1,
    output logic [1:0] fsel2,
    output wire STALL
    );
	 
	logic mem_hazard_rs2;
	logic wb_hazard_rs2;

	assign mem_hazard_rs2 = memRegWrite && !memRead2 && ex_rs2_used && (mem_rd != 5'd0) && (mem_rd == ex_rs2);

	assign wb_hazard_rs2 = wbRegWrite && ex_rs2_used && (wb_rd != 5'd0) && (wb_rd == ex_rs2) && !mem_hazard_rs2;


	assign fsel1 = ((mem_rd == ex_rs1 && ex_rs1_used && memRegWrite) && (mem_opcode != LOAD)) ? 2'b01 : 
							(wb_rd == ex_rs1 && ex_rs1_used && wbRegWrite) ? 2'b10 : 2'b00;
							
	assign fsel2 = mem_hazard_rs2 ? 2'b01 :
						wb_hazard_rs2  ? 2'b10 : 2'b00;
	 
	assign STALL = ((ex_opcode == LOAD) && ((dec_rs1 == ex_rd && dec_rs1_used) || (dec_rs2 == ex_rd && dec_rs2_used)) && (ex_rd != 32'b0));
	
endmodule


