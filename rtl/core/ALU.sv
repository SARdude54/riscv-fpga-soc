`timescale 1ns / 1ps

import isa_pkg::*;

module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_fun,
    output reg [31:0] result
    );
    
    always @(*)
        begin
        case(alu_fun)
        ALU_ADD: result = srcA + srcB; //add
        ALU_SUB: result = srcA - srcB; //sub
        ALU_OR: result = srcA | srcB; //or
        ALU_AND: result = srcA & srcB; //and        
        ALU_XOR: result = srcA ^ srcB; //xor
        ALU_SRL: result = srcA >> srcB[4:0]; //srl
        ALU_SLL: result = srcA << srcB[4:0]; //sll
        ALU_SRA: result = $signed(srcA) >>> srcB[4:0]; //sra
   //slt  
        ALU_SLT: result = ($signed(srcA) < $signed(srcB))? 1:0;
        ALU_SLTU: result = srcA < srcB ? 1:0;//sltu
        ALU_COPY: result = srcA; // lui-copy
        default: result = 32'hDEADBEEF;
        endcase
        end
endmodule
