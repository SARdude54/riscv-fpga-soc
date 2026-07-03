`timescale 1ns/1ps

module TB_core;

  logic clk, rst, wr;
  logic [31:0] in, out, addr;

  localparam int TIMEOUT_CYCLES = 20000;
  localparam logic [31:0] TEST_STATUS_ADDR = 32'h1100_0000;
  localparam logic [31:0] PASS_CODE = 32'd1;
  localparam logic [31:0] FAIL_CODE = 32'd2;
  localparam logic [31:0] PASS_LABEL = 32'h000004fc;
  localparam logic [31:0] FAIL_LABEL = 32'h00000520;

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
    $dumpvars(0, TB_core);
  end

  // Reset
  initial begin
    rst = 1'b1;
    in  = 32'h0;

    // hold reset for a few cycles so PC clears and FSM starts cleanly
    repeat (5) @(posedge clk);
    rst = 1'b0;

    

    // run up to a limit unless MMIO write tells us to finish
    repeat (20000) @(posedge clk);  // ~200 us at 100 MHz
    $display("TIMEOUT: no MMIO completion detected");
    $finish;
  end

  // prev pc
  logic [31:0] pc;
  logic [31:0] pc_prev1;
  logic [31:0] pc_prev2;
  logic [31:0] pc_prev3;
  logic [31:0] pc_prev4;



// MMIO completion monitor
  always_ff @(posedge clk) begin
    if (!rst && wr) begin
      $display("MMIO write: addr=%h data=%h @%0t", addr, out, $time);

      if (addr == TEST_STATUS_ADDR) begin
        if (out == PASS_CODE) begin
          $display("PASS: RV32I no-hazard assembly test passed");
          $finish;
        end
        else if (out == FAIL_CODE) begin
          $fatal(1, "FAIL: RV32I no-hazard assembly test failed");
        end
        else begin
          $fatal(1, "FAIL: unknown test status code %h", out);
        end
      end
    end
  end

// PC mointor
always_ff @(posedge clk) begin
  if(rst) begin
    pc <= 32'h0;
    pc_prev1 <= 32'h0;
    pc_prev2 <= 32'h0;
    pc_prev3 <= 32'h0;
    pc_prev4 <= 32'h0;
  end

  else begin

    pc_prev4 <= pc_prev3;
    pc_prev3 <= pc_prev2;
    pc_prev2 <= pc_prev1;
    pc_prev1 <= pc;
    pc <= UUT.pc;

    if(UUT.pc == PASS_LABEL) begin
      $display("PASS: RV32I reached pass label");
    end
    else if (UUT.pc == FAIL_LABEL) begin
      $display("FAIL: RV32I reached fail label");
      $display("PC HISTORY");
      $display("PC: %h", pc);
      $display("PC Prev1: %h", pc_prev1);
      $display("PC Prev2: %h", pc_prev2);
      $display("PC Prev3: %h", pc_prev3);
      $display("PC Prev4: %h", pc_prev4);
      $finish;
    end
  end
end

endmodule
