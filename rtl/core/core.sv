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
	
	wire mem_op,memRead;
	wire [1:0] pc_source;
				  
			  
			  
	instr_t de_inst, ex_inst, mem_inst, wb_inst;
	//==== Instruction Fetch ===========================================
	wire [31:0] pc, pc_value, jalr_pc, branch_pc, jal_pc;
	wire pcWrite, memRead1;

	assign pcWrite = !RST; 	//Hardwired high, assuming no hazards
	assign memRead1 = !RST;

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
	
	wire [31:0] mem_data;	
	
	Memory memory(
	.MEM_CLK (clk),
	.MEM_RDEN1 (memRead1),        // always read new instruction
	.MEM_RDEN2 (mem_inst.memRead2),        // read enable data
	.MEM_WE2 (mem_inst.memWrite),          // write enable.
	.MEM_ADDR1 (pc[15:2]), // Instruction Memory word Addr (Connect to PC[15:2])
	.MEM_ADDR2 (mem_inst.alu_result), // Data Memory Addr
	.MEM_DIN2 (mem_inst.rs2),  // Data to save
	.MEM_SIZE (mem_inst.mem_type),   // 0-Byte, 1-Half, 2-Word
	.MEM_SIGN (de_inst.instruction[14]),         // 1-unsigned 0-signed
	.IO_IN (iobus_in),     // Data from IO
	//output
	.IO_WR (iobus_wr),     // IO 1-write 0-read
	.MEM_DOUT1 (IR),  // Instruction
	.MEM_DOUT2 (mem_data)); // Data
	
	reg [31:0] if_pc_q;
	always_ff @(posedge clk) begin
		if (RST) begin
			if_pc_q <= 32'b0;
		end
		else if (memRead1) begin
			if_pc_q <= pc;
		end
	end
	
	//pipeline register
	always_ff @(posedge clk) begin //
		if(RST) begin
			de_inst.instruction <= 32'b0;
			de_inst.pc <= 32'b0;
		end else begin
			de_inst.instruction <= IR;
			de_inst.pc <= if_pc_q;
		end
	end 


	//==== Instruction Decode ===========================================
	
	wire [6:0] opcode;
	wire [5:0] rs1_addr, rs2_addr, rd_addr;
	wire mem_size;

	assign opcode = de_inst.instruction[6:0];
	assign rs1_addr = de_inst.instruction[19:15];
   assign rs2_addr = de_inst.instruction[24:20];
   assign rd_addr = de_inst.instruction[11:7];
	assign mem_size = de_inst.instruction[14];
	
	wire [31:0] rs1, rs2;

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
	wire regWrite;
	RegFile regfile(
		.clk(clk),
		.rst(RST),
		.en(wb_inst.regWrite),
		.addr1(rs1_addr),
		.addr2(rs2_addr),
		.w_addr(wb_inst.rd_addr),
		.w_data(rfIn),
		.rs1(rs1), 
		.rs2(rs2) 
	);

	IMMED_GEN IMMED_GEN(
		.ir(de_inst.instruction),
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
	
	wire [3:0] alu_fun;
	wire [1:0] rf_wr_sel;
	wire memWrite;
	wire memRead2;
	

	// Decoder
	
	wire branch;
	
	CU_DCDR decoder(
		//inputs
		.IR_FUNC7(de_inst.instruction[30]),
		.IR_OPCODE(OPCODE),
		.IR_FUNC3(de_inst.instruction[14:12]),
		.br_eq(br_eq),
		.br_lt(br_lt),
		.br_ltu(br_ltu),
		//outputs
		.ALU_FUN(alu_fun),
		.ALU_SRCA(opA_sel),
		.ALU_SRCB(opB_sel),
		.PC_SOURCE(pc_source),
		.RF_WR_SEL(rf_wr_sel),
		.REG_WRITE(regWrite),
		.MEM_WE2(memWrite),
		.MEM_RDEN2(memRead2),
		.BRANCH(branch)
	);
	
		BRANCH_COND_GEN BCG(
			.rs1(rs1), 
			.rs2(rs2), 
			.br_eq(br_eq), 
			.br_lt(br_lt), 
			.br_ltu(br_ltu)
	);
	  
	//ALU muxes
	wire [31:0] aluAin, aluBin;
	mux_2t1_nb alu_muxA(.SEL(opA_sel), .D0(rs1), .D1(U_immed), .D_OUT(aluAin));
	mux_4t1_nb alu_muxB(.SEL(opB_sel), .D0(rs2), .D1(I_immed), .D2(S_immed), .D3(de_inst.pc), .D_OUT(aluBin));

	//pipeline register
	always_ff @(posedge clk) begin

	if(RST) begin
		ex_inst.opcode <= opcode_t'(7'b0);
		ex_inst.rs1_addr <= 5'b0;
		ex_inst.rs2_addr <= 5'b0;
		ex_inst.rs1 <= 32'b0;
		ex_inst.rs2 <= 32'b0;
		ex_inst.rd_addr <= 5'b0;
		ex_inst.alu_fun <= 4'b0;
		ex_inst.rf_wr_sel <= 2'b0;
		ex_inst.regWrite <= 0;
		ex_inst.memWrite <= 0;
		ex_inst.memRead2 <= 0;
		ex_inst.aluAin <= 32'b0;
		ex_inst.aluBin <= 32'b0;
		ex_inst.mem_type <= 2'b0;
		ex_inst.mem_size <= 0;

	end begin 
		ex_inst.instruction <= de_inst.instruction;
		ex_inst.pc <= de_inst.pc;
		ex_inst.opcode <= OPCODE;
		ex_inst.rs1_addr <= rs1_addr;
		ex_inst.rs2_addr <= rs2_addr;
		ex_inst.rs1 <= rs1;
		ex_inst.rs2 <= rs2;
		ex_inst.rd_addr <= rd_addr;
		ex_inst.alu_fun <= alu_fun;
		ex_inst.rf_wr_sel <= rf_wr_sel;
		ex_inst.regWrite <= regWrite;
		ex_inst.memWrite <= memWrite;
		ex_inst.memRead2 <= memRead2;
		ex_inst.aluAin <= aluAin;
		ex_inst.aluBin <= aluBin;
		ex_inst.mem_type <= de_inst.instruction[13:12];
		ex_inst.mem_size <= de_inst.instruction[14];
	
	end
	  
	end    


	//==== Execute ======================================================

	logic [31:0] mem_rs2;
	logic mem_aluRes = 0;
	logic [31:0] opA_forwarded;
	logic [31:0] opB_forwarded;

	wire [31:0] alu_result;
	ALU ALU (    
		.srcA(ex_inst.aluAin),
		.srcB(ex_inst.aluBin),
		.alu_fun(ex_inst.alu_fun),
		.result(alu_result)
	); // the ALU
		
	always_ff @(posedge clk) begin
		if(RST) begin
			mem_inst.opcode <= opcode_t'(7'b0);
			mem_inst.rs1_addr <= 5'b0;
			mem_inst.rs2_addr <= 5'b0;
			mem_inst.rs1 <= 32'b0;
			mem_inst.rs2 <= 32'b0;
			mem_inst.rd_addr <= 5'b0;
			mem_inst.alu_fun <= 4'b0;
			mem_inst.rf_wr_sel <= 2'b0;
			mem_inst.regWrite <= 0;
			mem_inst.memWrite <= 0;
			mem_inst.memRead2 <= 0;
			mem_inst.aluAin <= 32'b0;
			mem_inst.aluBin <= 32'b0;
			mem_inst.mem_type <= 2'b0;
			mem_inst.mem_size <= 0;
			mem_inst.alu_result <= 32'b0;

		end else begin
			mem_inst.instruction <= ex_inst.instruction;
			mem_inst.pc <= ex_inst.pc;
			mem_inst.opcode <= ex_inst.opcode;
			mem_inst.rs1_addr <= ex_inst.rs1_addr;
			mem_inst.rs2_addr <= ex_inst.rs2_addr;
			mem_inst.rs1 <= ex_inst.rs1;
			mem_inst.rs2 <= ex_inst.rs2;
			mem_inst.rd_addr <= ex_inst.rd_addr;
			mem_inst.alu_fun <= ex_inst.alu_fun;
			mem_inst.rf_wr_sel <= ex_inst.rf_wr_sel;
			mem_inst.regWrite <= ex_inst.regWrite;
			mem_inst.memWrite <= ex_inst.memWrite;
			mem_inst.memRead2 <= ex_inst.memRead2;
			mem_inst.aluAin <= ex_inst.aluAin;
			mem_inst.aluBin <= ex_inst.aluBin;
			mem_inst.mem_type <= ex_inst.instruction[13:12];
			mem_inst.mem_size <= ex_inst.instruction[14];
			mem_inst.alu_result <= alu_result;

		end
	end


	////==== Memory ======================================================

	assign iobus_addr = mem_inst.alu_result;
	assign iobus_out = mem_inst.rs2;

	always_ff @(posedge clk) begin //
		if(RST) begin
			wb_inst.mem_data <= 32'b0;
			wb_inst <= 'b0;
		end else begin
			wb_inst.instruction <= mem_inst.instruction;
			wb_inst.pc <= mem_inst.pc;
			wb_inst.opcode <= mem_inst.opcode;
			wb_inst.rs1_addr <= mem_inst.rs1_addr;
			wb_inst.rs2_addr <= mem_inst.rs2_addr;
			wb_inst.rs1 <= mem_inst.rs1;
			wb_inst.rs2 <= mem_inst.rs2;
			wb_inst.rd_addr <= mem_inst.rd_addr;
			wb_inst.alu_fun <= mem_inst.alu_fun;
			wb_inst.rf_wr_sel <= mem_inst.rf_wr_sel;
			wb_inst.regWrite <= mem_inst.regWrite;
			wb_inst.memWrite <= mem_inst.memWrite;
			wb_inst.memRead2 <= mem_inst.memRead2;
			wb_inst.aluAin <= mem_inst.aluAin;
			wb_inst.aluBin <= mem_inst.aluBin;
			wb_inst.mem_type <= mem_inst.instruction[13:12];
			wb_inst.mem_size <= mem_inst.instruction[14];
			wb_inst.alu_result <= mem_inst.alu_result;
			wb_inst.mem_data <= mem_data;

		end
	end


	//==== Write Back ==================================================

	mux_4t1_nb WB_mux (
	  .SEL(wb_inst.rf_wr_sel),
	  .D0(wb_inst.alu_result),
	  .D1(mem_data),
	  .D2(wb_inst.pc+4),
	  .D3(0),
	  .D_OUT(rfIn)
	);

	 
				
endmodule
