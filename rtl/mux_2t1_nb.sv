`timescale 1ns / 1ps


module mux_2t1_nb
#(parameter n = 32)(
    input logic SEL,
    input logic [n-1:0] D0,
    input logic [n-1:0] D1,
    output logic [n-1:0] D_OUT
    );
    
    always_comb begin 
        if(SEL == 0) begin 
            D_OUT = D0;
        end
        else if(SEL == 1) begin 
            D_OUT = D1;
        end
        else begin
            D_OUT = 0;
        end
    end
    
endmodule
