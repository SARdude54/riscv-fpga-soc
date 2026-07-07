`timescale 1ns/1ps

module TB_core;

  logic clk, rst, wr;
  logic [31:0] in, out, addr;

  localparam int TIMEOUT_CYCLES = 20000;
  localparam logic [31:0] TEST_STATUS_ADDR = 32'h1000_0000;
  localparam logic [31:0] PASS_CODE = 32'd1;
  localparam logic [31:0] FAIL_CODE = 32'd2;
  localparam logic [31:0] PASS_LABEL = 32'h00000208;
  localparam logic [31:0] FAIL_LABEL = 32'h000001f8;

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
always @(posedge clk) begin
  #1;

  if (!rst && wr) begin
    $display("MMIO write: addr=%h data=%h @%0t", addr, out, $time);

    if (addr == TEST_STATUS_ADDR) begin
      if (out == PASS_CODE) begin
        $display("PASS: RV32I assembly test passed");
        $finish;
      end
      else if (out == FAIL_CODE) begin
        $fatal(1, "FAIL: RV32I assembly test failed");
      end
      else begin
        $fatal(1, "FAIL: unknown test status code %h", out);
      end
    end
  end
end

always @(posedge clk) begin
  #1;

  if (!rst && UUT.ex_inst.pc >= 32'h0000_01e4 && UUT.ex_inst.pc <= 32'h0000_01f4) begin
    $display("U_TEST EX pc=%h ir=%h op=%h rs1=x%0d rs2=x%0d rd=x%0d opA=%h opB=%h fsel1=%b fsel2=%b br_eq=%b pcsrc=%b brpc=%h | MEM pc=%h ir=%h rd=x%0d alu=%h regW=%b op=%h | WB pc=%h ir=%h rd=x%0d rfIn=%h regW=%b | x6=%h x7=%h",
      UUT.ex_inst.pc,
      UUT.ex_inst.instruction,
      UUT.ex_inst.opcode,
      UUT.ex_inst.rs1_addr,
      UUT.ex_inst.rs2_addr,
      UUT.ex_inst.rd_addr,
      UUT.opA_forwarded,
      UUT.opB_forwarded,
      UUT.fsel1,
      UUT.fsel2,
      UUT.br_eq,
      UUT.pc_source,
      UUT.branch_pc,
      UUT.mem_inst.pc,
      UUT.mem_inst.instruction,
      UUT.mem_inst.rd_addr,
      UUT.mem_inst.alu_result,
      UUT.mem_inst.regWrite,
      UUT.mem_inst.opcode,
      UUT.wb_inst.pc,
      UUT.wb_inst.instruction,
      UUT.wb_inst.rd_addr,
      UUT.rfIn,
      UUT.wb_inst.regWrite,
      UUT.regfile.ram[6],   // t1
      UUT.regfile.ram[7]    // t2
    );
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

    if (UUT.mem_inst.pc >= 32'h0000_01f8 && UUT.pc <= 32'h0000_0214) begin
      $display("END REGION pc=%h wr=%b addr=%h out=%h t0=%h t1=%h mem_pc=%h mem_ir=%h mem_alu=%h mem_memWrite=%b mem_opcode=%h",
              UUT.pc, wr, addr, out,
              UUT.regfile.ram[5],
              UUT.regfile.ram[6],
              UUT.mem_inst.pc,
              UUT.mem_inst.instruction,
              UUT.mem_inst.alu_result,
              UUT.mem_inst.memWrite,
              UUT.mem_inst.opcode);
    end

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
      
    end
  end
end

endmodule
