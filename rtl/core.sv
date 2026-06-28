`timescale 1ns / 1ps

import isa_pkg::*;
    

module core(input clk,
                input RST,
                input intr,
                input [31:0] iobus_in,
                output [31:0] iobus_out,
                output [31:0] iobus_addr,
                output logic iobus_wr 
);           

	wire [31:0] I_immed,S_immed,U_immed, B_immed, J_immed;
	wire [31:0] IR;
	
	wire regWrite,memWrite,mem_op,memRead, memRead2;
	wire [1:0] pc_source;
	logic [1:0] pc_sel;
	wire [1:0] rf_wr_sel;
	wire [3:0]alu_fun;
				  
			  
			  
	instr_t de_inst, ex_inst, mem_inst, wb_inst;
	//==== Instruction Fetch ===========================================
	wire [31:0] pc, pc_value, jalr_pc, branch_pc, jump_pc;
	wire pcWrite;

	assign pcWrite = 1'b1; 	//Hardwired high, assuming no hazards

	mux_4t1_nb #(.n(32)) PC_mux (
	  .SEL (pc_source),
	  .D0 (pc + 4),
	  .D1 (jalr_pc),
	  .D2 (branch_pc),
	  .D3 (jal_pc),
	  .D_OUT (pc_value) );

	reg_nb_sclr PC(
		.clk(clk), 
		.clr(RST), 
		.ld(pcWrite), 
		.data_in(pc_value),
		.data_out(pc)
		);
	
	wire [32:0] mem_data;
	Memory memory(
	.MEM_CLK (clk),
	.MEM_RDEN1 (1'b1),        // always read new instruction
	.MEM_RDEN2 (mem_inst.memRead2),        // read enable data
	.MEM_WE2 (mem_inst.memWrite),          // write enable.
	.MEM_ADDR1 (pc[15:2]), // Instruction Memory word Addr (Connect to PC[15:2])
	.MEM_ADDR2 (iobus_addr), // Data Memory Addr
	.MEM_DIN2 (mem_inst.alu_result),  // Data to save
	.MEM_SIZE (mem_inst.mem_type),   // 0-Byte, 1-Half, 2-Word
	.MEM_SIGN (de_inst.mem_size),         // 1-unsigned 0-signed
	.IO_IN (iobus_in),     // Data from IO
	//output
	.IO_WR (iobus_wr),     // IO 1-write 0-read
	.MEM_DOUT1 (IR),  // Instruction
	.MEM_DOUT2 (mem_data)); // Data
	
	//pipeline register
	always_ff @(posedge clk) begin //
	  de_inst.instruction <= IR;
	  de_inst.pc <= pc;
	end 


	//==== Instruction Decode ===========================================
	
	wire [6:0] opcode;

	opcode_t OPCODE;
	assign OPCODE = opcode_t'(opcode);	
	 
	// TODO: Hazards, deal with later
	// assign de_inst.rs1_used =    de_inst.rs1 != 0
	//                             && de_inst.opcode != LUI
	//                             && de_inst.opcode != AUIPC
	//                             && de_inst.opcode != JAL;


	// assign de_inst.rs2_used = de_inst.rs2 != 0
	//                            && de_inst.opcode != LOAD
	//                             && de_inst.opcode != OP_IMM
	//                             && de_inst.opcode != LUI
	//                             && de_inst.opcode != AUIPC
	//                             && de_inst.opcode != JAL;
			 
			
	wire [31:0] rfIn;
	
	RegFile regfile(
		.clk(clk),
		.rst(RST),
		.en(de_inst.regWrite),
		.addr1(de_inst.rs1_addr),
		.addr2(de_inst.rs2_addr),
		.w_addr(de_inst.rd_addr),
		.w_data(rfIn),
		.rs1(de_inst.rs1), 
		.rs2(de_inst.rs2) 
	);

	IMMED_GEN IMMED_GEN(
		.ir(IR),
		.U_type(U_immed),
		.I_type(I_immed),
		.S_type(S_immed),
		.B_type(B_immed),
		.J_type(J_immed)
	);

	BRANCH_ADDR_GEN BAG(
		.rs(rs1), 
		.I_type(I_immed), 
		.J_type(J_immed), 
		.B_type(B_immed), 
		.PC(de_inst.pc),
		.jal(jal_pc), 
		.jalr(jalr_pc), 
		.branch(branch_pc)
	);



	logic br_lt,br_eq,br_ltu;       //branch condition wires
	
	wire opA_sel;
	wire [1:0] opB_sel;

	// Decoder
	CU_DCDR decoder(
		.IR_FUNC7(IR[30]),
		.IR_OPCODE(IR[6:0]),
		.IR_FUNC3(IR[14:12]),
		.ALU_FUN(de_inst.alu_fun),
		.ALU_SRCA(opA_sel),
		.ALU_SRCB(opB_sel),
		.PC_SOURCE(pc_source),
		.RF_WR_SEL(de_inst.rf_wr_sel),
		.REG_WRITE(de_inst.regWrite),
		.MEM_WE2(de_inst.memWrite),
		.MEM_RDEN2(de_inst.memRead2)
	);
	  
	//ALU muxes
	wire [31:0] aluAin, aluBin;
	mux_2t1_nb alu_muxA(.SEL(opA_sel), .D0(rs1), .D1(U_immed), .D_OUT(de_inst.aluAin));
	mux_4t1_nb alu_muxB(.SEL(opB_sel), .D0(rs2), .D1(I_immed), .D2(S_immed), .D3(pc), .D_OUT(de_inst.aluBin));

	//pipeline register
	always_ff @(posedge clk) begin

	  ex_inst.opcode <= OPCODE;
	  ex_inst.mem_type <= de_inst.instruction[13:12];
	  ex_inst.mem_size <= de_inst.instruction[14];
	  ex_inst <= de_inst;
	  
	end    


	//==== Execute ======================================================

	logic [31:0] mem_rs2;
	logic mem_aluRes = 0;
	logic [31:0] opA_forwarded;
	logic [31:0] opB_forwarded;


	BRANCH_COND_GEN BCG(
			.rs1(ex_inst.rs1), 
			.rs2(ex_inst.rs2), 
			.br_eq(br_eq), 
			.br_lt(br_lt), 
			.br_ltu(br_ltu)
	);

	wire [32:0] alu_result;
	ALU ALU (    
		.srcA(ex_inst.aluAin),
		.srcB(ex_inst.aluBin),
		.alu_fun(mem_inst.alu_fun),
		.result(alu_result)
	); // the ALU
		
	always_ff @(posedge clk) begin
		mem_inst.alu_result <= alu_result;
		mem_inst <= ex_inst;
	end


	////==== Memory ======================================================

	assign iobus_addr = mem_inst.alu_result;
	assign iobus_out = mem_inst.rs2;

	always_ff @(posedge clk) begin //
		wb_inst.mem_data <= mem_data;
		wb_inst <= mem_inst;
	end


	//==== Write Back ==================================================

	mux_4t1_nb WB_mux (
	  .SEL(wb_inst.rf_wr_sel),
	  .D0(wb_inst.alu_result),
	  .D1(wb_inst.mem_data),
	  .D2(wb_inst.pc+4),
	  .D3(0),
	  .D_OUT(rfIn)
	);

	 
				
endmodule
