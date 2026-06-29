`timescale 1ns/1ps

module TB_core_no_mem;

	logic clk, rst, wr;
	logic [31:0] in, out, addr;

	// DUT
	core UUT (
		.RST       (rst),
		.intr      (1'b0),
		.clk       (clk),
		.iobus_in  (in),
		.iobus_addr(addr),
		.iobus_out (out),
		.iobus_wr  (wr)
	);

	initial clk = 0;
	always #5 clk = ~clk;

	// VCD
	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, TB_core_no_mem);
	end
	
	task set_instruction (
		input logic [31:0] ir_bin
	);
	
	force UUT.IR = ir_bin;
	
	repeat (5) @(posedge clk);
	
	release UUT.IR;
	
	endtask

	// Reset
	initial begin
		rst = 1'b1;
		in  = 32'h0;

		// hold reset for a few cycles so PC clears and FSM starts cleanly
		repeat (5) @(posedge clk);
		rst = 1'b0;

		set_instruction(8'h01900293);

		// run up to a limit unless MMIO write tells us to finish
		repeat (20000) @(posedge clk);  // ~200 us at 100 MHz
		$display("TIMEOUT: no MMIO completion detected");
		$finish;
	end


	always @(posedge clk) begin
		if (!rst && wr) begin
			$display("MMIO write: addr=%h data=%h @%0t", addr, out, $time);
			$finish;
		end
	end
endmodule
