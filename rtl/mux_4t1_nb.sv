`timescale 1ns / 1ps


module mux_4t1_nb
#(parameter n = 32)(
    input logic [1:0] SEL,
    input logic [n-1:0] D0,
    input logic [n-1:0] D1,
    input logic [n-1:0] D2,
    input logic [n-1:0] D3,
    output logic [n-1:0] D_OUT
    );
    
    always_comb begin 
        if(SEL == 2'b00) begin 
            D_OUT = D0;
        end
        else if(SEL == 2'b01) begin 
            D_OUT = D1;
        end
        else if(SEL == 2'b10) begin 
            D_OUT = D2;
        end
        else if(SEL == 2'b11) begin 
            D_OUT = D3;
        end else begin
            D_OUT = 0;
        end
    end
    
endmodule
