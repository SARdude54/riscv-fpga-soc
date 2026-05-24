`timescale 1ns / 1ps

module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_fun,
    output reg [31:0] result
    );
    
    always @(*)
        begin
        case(alu_fun)
        4'b0000: assign result = srcA + srcB; //add
        4'b1000: assign result = srcA - srcB; //sub
        4'b0110: assign result = srcA | srcB; //or
        4'b0111: assign result = srcA & srcB; //and        
        4'b0100: assign result = srcA ^ srcB; //xor
        4'b0101: assign result = srcA >> srcB[4:0]; //srl
        4'b0001: assign result = srcA << srcB[4:0]; //sll
        4'b1101: assign result = $signed(srcA) >>> srcB[4:0]; //sra
   //slt  
        4'b0010: assign result = ($signed(srcA) < $signed(srcB))? 1:0;
        4'b0011: assign result = srcA < srcB ? 1:0;//sltu
        4'b1001: assign result = srcA; // lui-copy
        default: assign result = 32'hDEADBEEF;
        endcase
        end
endmodule
