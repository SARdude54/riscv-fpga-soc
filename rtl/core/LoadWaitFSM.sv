`timescale 1 ps / 1 ps


module LoadWaitFSM (
	input logic CLK,
	input logic RST,
	input logic load_wait_start,
	output logic mem_wait
);
	
	typedef enum{
	  ST_RUN,
	  ST_RELEASE
	} state_type;
	state_type PS, NS;

	always_ff @(posedge CLK) begin
		if (RST==1)
			PS <= ST_RUN;
		else
			PS <= NS;
	end
	
	always_comb begin
		  mem_wait = 1'b0;
        NS = PS;
		case(PS)
			ST_RUN: begin
				if(load_wait_start) begin
					mem_wait = 1;
					NS = ST_RELEASE;
				end else begin
					mem_wait = 0;
					NS = PS;
				end
			end
			ST_RELEASE: begin
				mem_wait = 0;
				NS = ST_RUN;
			end
		endcase
	end

endmodule
