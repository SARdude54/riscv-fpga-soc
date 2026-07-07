`timescale 1ns / 1ps

import isa_pkg::*;

module BRANCH_COND_GEN(
	input opcode_t opcode,
	input logic [2:0] IR_FUNC3,
   input logic [31:0] rs1,
   input logic [31:0] rs2,
   output logic br_eq,
   output logic br_lt,
   output logic br_ltu,
	output logic [1:0] PC_SOURCE,
	output logic BRANCH_TAKEN
);

    assign br_eq = (rs1 == rs2) && (opcode == BRANCH);
    assign br_ltu = (rs1 < rs2) && (opcode == BRANCH);
    assign br_lt = ($signed(rs1) < $signed(rs2)) && (opcode == BRANCH);
	 
	 always_comb begin
		if(opcode == BRANCH) begin
			case(IR_FUNC3)
			3'b000: begin   //BEQ
					 
					 if(br_eq) begin
						PC_SOURCE = 2'b10;
						BRANCH_TAKEN = 1;
					 end else begin
						PC_SOURCE = 2'b00;
						BRANCH_TAKEN = 0;
					 end
			end
			3'b001: begin   //BNE
					 if(!br_eq) begin
						PC_SOURCE = 2'b10;
						BRANCH_TAKEN = 1;
					 end else begin
						PC_SOURCE = 2'b00;
						BRANCH_TAKEN = 0;
					 end
			end
			3'b100: begin   //BLT
					 if(br_lt) begin
						PC_SOURCE = 2'b10;
						BRANCH_TAKEN = 1;
					 end else begin
						PC_SOURCE = 2'b00;
						BRANCH_TAKEN = 0;
					 end
			end
			3'b101: begin   //BGE
					 if(br_eq | !br_lt) begin
						PC_SOURCE = 2'b10;
						BRANCH_TAKEN = 1;
					 end else begin
						PC_SOURCE = 2'b00;
						BRANCH_TAKEN = 0;
					 end

			end
			3'b110: begin   //BLTU
					 if(br_ltu) begin
						PC_SOURCE = 2'b10;
						BRANCH_TAKEN = 1;
					 end else begin
						PC_SOURCE = 2'b00;
						BRANCH_TAKEN = 0;
					 end

			end
			3'b111: begin   //BGEU
					 if(br_eq | !br_ltu) begin
						PC_SOURCE = 2'b10;
						BRANCH_TAKEN = 1;
					 end else begin
						PC_SOURCE = 2'b00;
						BRANCH_TAKEN = 0;
					 end

			end
			default: begin
				PC_SOURCE = 2'b00;
				BRANCH_TAKEN = 0;
			end
			endcase
		end else if (opcode == JALR) begin
			PC_SOURCE = 2'b01;
			BRANCH_TAKEN = 1;
		end else if (opcode == JAL) begin
			PC_SOURCE = 2'b11;
			BRANCH_TAKEN = 1;
		end else begin
			PC_SOURCE = 2'b00;
			BRANCH_TAKEN = 0;
		end
	 end
	 
endmodule
