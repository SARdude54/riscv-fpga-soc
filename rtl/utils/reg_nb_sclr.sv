`timescale 1ns / 1ps


module reg_nb_sclr
#(parameter n = 32)(
    input clk,
    input clr,
    input ld,
    input logic [n-1:0] data_in,
    output logic [n-1:0] data_out=0
    );
    
    always_ff @(posedge clk)
    begin
        if (clr == 1'b1)
            data_out <= '0;
        else if (ld == 1'b1)
            data_out <= data_in;
    end
    
endmodule
