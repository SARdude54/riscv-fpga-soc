`timescale 1ns / 1ps

import isa_pkg::*;
    
`default_nettype none

module core(
		input wire clk,
		input wire RST,
		input wire intr,
		input wire [31:0] iobus_in,
		output wire [31:0] iobus_out,
		output wire [31:0] iobus_addr,
		output wire iobus_wr 
);           

	// memory regions
	localparam logic [31:0] ROM_BASE        = 32'h0000_0000;
	localparam logic [31:0] ROM_END         = 32'h0000_7FFF;

	localparam logic [31:0] SPM_BASE        = 32'h0000_8000;
	localparam logic [31:0] SPM_END         = 32'h0000_FFFF;

	localparam logic [31:0] MMIO_BASE       = 32'h1000_0000;
	localparam logic [31:0] MMIO_END        = 32'h1000_FFFF;

	localparam logic [31:0] SDRAM_BASE      = 32'h8000_0000;
	localparam logic [31:0] SDRAM_END       = 32'h83FF_FFFF;

	wire [31:0] I_immed,S_immed,U_immed, B_immed, J_immed;
	wire [31:0] IR, old_IR;
	
	wire mem_op,memRead;
	wire [1:0] pc_source;
				  
	logic mem_wait;
	wire BRANCH_TAKEN;
			  
	instr_t de_inst, ex_inst, mem_inst, wb_inst;
	//==== Instruction Fetch ===========================================
	wire [31:0] pc, pc_value, jalr_pc, branch_pc, jal_pc;
	wire pcWrite, memRead1;
	wire STALL, FLUSH;
	reg HOLD_FLUSH;


	assign pcWrite = !RST && !mem_wait && (pc_source != 2'b00 || !STALL);
	assign memRead1 = !RST && !mem_wait && (pc_source != 2'b00 || !STALL);

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
	
	wire [31:0] rom_data, old_mem_data;
	wire memRead2;
	boot_rom Instr_Mem(
		
		.clk_clk(clk),           //     clk.clk
		.reset_reset_n(!RST),     //   reset.reset_n
		.reset_1_reset(RST),     // reset_1.reset
		.reset_1_reset_req(RST), //        .reset_req
		.reset_2_reset(RST),     // reset_2.reset
		.reset_2_reset_req(RST), //        .reset_req
		.s1_address(pc[14:2]),        //      s1.address
		.s1_debugaccess(0),    //        .debugaccess
		.s1_clken(memRead1),          //        .clken
		.s1_chipselect(1),     //        .chipselect TODO: Should be high when PC is inside ROM range
		.s1_write('0),          //        .write
		.s1_readdata(IR),       //        .readdata
		.s1_writedata('0),      //        .writedata
		.s1_byteenable(4'b1111),     //        .byteenable
		.s2_address(mem_inst.alu_result[14:2]),        //      s2.address
		.s2_chipselect(mem_inst.romRead),     //        .chipselect
		.s2_clken(mem_inst.memRead2 & mem_inst.romRead),          //        .clken
		.s2_write(0),          //        .write
		.s2_readdata(rom_data),       //        .readdata
		.s2_writedata(0),      //        .writedata
		.s2_byteenable(4'b1111)      //        .byteenable
		
	);
	
	//Memory memory(
	//.MEM_CLK (clk),
	//.MEM_RDEN1 (0),        // always read new instruction
	//.MEM_RDEN2 (mem_inst.memRead2),        // read enable data
//	.MEM_WE2 (mem_inst.memWrite),          // write enable.
	//.MEM_ADDR1 (12'b0), // Instruction Memory word Addr (Connect to PC[15:2])
	//.MEM_ADDR2 (mem_inst.alu_result), // Data Memory Addr
	//.MEM_DIN2 (mem_inst.rs2),  // Data to save
	//.MEM_SIZE (mem_inst.mem_type),   // 0-Byte, 1-Half, 2-Word
	//.MEM_SIGN (de_inst.instruction[14]),         // 1-unsigned 0-signed
	//.IO_IN (iobus_in),     // Data from IO
	//output
	//.IO_WR (iobus_wr),     // IO 1-write 0-read
	//.MEM_DOUT1 (old_IR),  // Instruction
	//.MEM_DOUT2 (old_mem_data)); // Data
	
	reg [31:0] if_pc_q;
	always_ff @(posedge clk) begin
		if (RST) begin
			if_pc_q <= 32'b0;
		end
		else if (memRead1) begin
			if_pc_q <= pc;
		end
	end
	
	logic flush_d;
	wire squash;

	assign squash = FLUSH || flush_d;
	
	always_ff @(posedge clk) begin
		if (RST)
			flush_d <= 1'b0;
   else if (!mem_wait)
			flush_d <= FLUSH;
	end
	
	//pipeline register
	always_ff @(posedge clk) begin
		HOLD_FLUSH <= FLUSH;
		if(RST || FLUSH || squash) begin
			de_inst.instruction <= 32'b0;
			de_inst.pc <= 32'b0;
		end else if (STALL || mem_wait) begin
			de_inst.instruction <= de_inst.instruction;
			de_inst.pc <= de_inst.pc;
		end else begin
			de_inst.instruction <= IR;
			de_inst.pc <= if_pc_q;
		end
	end 


	//==== Instruction Decode ===========================================
	
	wire [6:0] opcode;
	wire [4:0] rs1_addr, rs2_addr, rd_addr;
	wire mem_size;

	assign opcode = de_inst.instruction[6:0];
	assign rs1_addr = de_inst.instruction[19:15];
   assign rs2_addr = de_inst.instruction[24:20];
   assign rd_addr = de_inst.instruction[11:7];
	assign mem_size = de_inst.instruction[14];
	
	
	
	wire [31:0] rs1, rs2;

	opcode_t OPCODE;
	assign OPCODE = opcode_t'(opcode);	
			 
			
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
	wire rs1_used, rs2_used, rd_used;
	assign rs1_used = rs1_addr !=0 && opcode != LUI && opcode != AUIPC && opcode != JAL;
	assign rs2_used = rs2_addr !=0 && opcode != LOAD && opcode != OP_IMM && opcode != LUI && opcode != AUIPC && opcode != JAL;
	assign rd_used =  rd_addr != 0 && opcode != BRANCH && opcode != STORE;

	IMMED_GEN IMMED_GEN(
		.ir(de_inst.instruction),
		.U_type(U_immed),
		.I_type(I_immed),
		.S_type(S_immed),
		.B_type(B_immed),
		.J_type(J_immed)
	);
	
	wire [1:0] fsel1, fsel2;
	DataHazardUnit DataHazardUnit(
		 .ex_opcode(ex_inst.opcode),
		 .mem_opcode(mem_inst.opcode),
		 .dec_rs1(rs1_addr),
		 .dec_rs2(rs2_addr),
		 .ex_rs1(ex_inst.rs1_addr),
		 .ex_rs2(ex_inst.rs2_addr),
		 .ex_rd(ex_inst.rd_addr),
		 .mem_rd(mem_inst.rd_addr),
		 .wb_rd(wb_inst.rd_addr),
		 .memRegWrite(mem_inst.regWrite),
		 .wbRegWrite(wb_inst.regWrite),
		 .dec_rs1_used(rs1_used),
		 .dec_rs2_used(rs2_used),
		 .ex_rs1_used(ex_inst.rs1_used),
		 .ex_rs2_used(ex_inst.rs2_used),
		 .memRead2(mem_inst.memRead2),
		 .fsel1(fsel1),
		 .fsel2(fsel2),
		 .STALL(STALL)
	);

assign FLUSH = (pc_source != 2'b00);



	logic br_lt,br_eq,br_ltu;       //branch condition wires
	
	wire opA_sel;
	wire [1:0] opB_sel;
	
	wire [3:0] alu_fun;
	wire [1:0] rf_wr_sel;
	wire memWrite;
	
	

	// Decoder
	
	CU_DCDR decoder(
		//inputs
		.IR_FUNC7(de_inst.instruction[30]),
		.IR_OPCODE(OPCODE),
		.IR_FUNC3(de_inst.instruction[14:12]),
		//outputs
		.ALU_FUN(alu_fun),
		.ALU_SRCA(opA_sel),
		.ALU_SRCB(opB_sel),
		.RF_WR_SEL(rf_wr_sel),
		.REG_WRITE(regWrite),
		.MEM_WE2(memWrite),
		.MEM_RDEN2(memRead2)
	);

	
	//pipeline register
	always_ff @(posedge clk) begin

	if(RST || FLUSH || squash || STALL) begin
		ex_inst.opcode <= opcode_t'(7'b0);
		ex_inst.rs1_addr <= 5'b0;
		ex_inst.rs2_addr <= 5'b0;
		ex_inst.rs1 <= 32'b0;
		ex_inst.rs2 <= 32'b0;
		ex_inst.rs1 <= 0;
		ex_inst.rs2 <= 0;
		ex_inst.opA_sel <= 0;
		ex_inst.opB_sel <= 2'b0;
		ex_inst.rd_addr <= 5'b0;
		ex_inst.alu_fun <= 4'b0;
		ex_inst.rf_wr_sel <= 2'b0;
		ex_inst.regWrite <= 0;
		ex_inst.memWrite <= 0;
		ex_inst.memRead2 <= 0;
		ex_inst.mem_type <= 2'b0;
		ex_inst.mem_size <= 0;
		ex_inst.I_immed <= 32'b0;
		ex_inst.S_immed <= 32'b0;
		ex_inst.U_immed <= 32'b0;
		ex_inst.B_immed <= 32'b0; 
		ex_inst.J_immed <= 32'b0;
		
	end else if (mem_wait) begin 
		ex_inst.instruction <= ex_inst.instruction;
		ex_inst.pc <= ex_inst.pc;
		ex_inst.opcode <= ex_inst.opcode;
		ex_inst.rs1_addr <= ex_inst.rs1_addr;
		ex_inst.rs2_addr <= ex_inst.rs2_addr;
		ex_inst.rd_addr <= ex_inst.rd_addr;
		ex_inst.rs1 <= ex_inst.rs1;
		ex_inst.rs2 <= ex_inst.rs2;
		ex_inst.rs1_used <= ex_inst.rs1_used;
		ex_inst.rs2_used <= ex_inst.rs2_used;
		ex_inst.opA_sel <= ex_inst.opA_sel;
		ex_inst.opB_sel <= ex_inst.opB_sel;
		ex_inst.alu_fun <= ex_inst.alu_fun;
		ex_inst.rf_wr_sel <= ex_inst.rf_wr_sel;
		ex_inst.regWrite <= ex_inst.regWrite;
		ex_inst.memWrite <= ex_inst.memWrite;
		ex_inst.memRead2 <= ex_inst.memRead2;
		ex_inst.mem_type <= ex_inst.instruction[13:12];
		ex_inst.mem_size <= ex_inst.instruction[14];
		ex_inst.I_immed <= ex_inst.I_immed;
		ex_inst.S_immed <= ex_inst.S_immed;
		ex_inst.U_immed <= ex_inst.U_immed;
		ex_inst.B_immed <= ex_inst.B_immed; 
		ex_inst.J_immed <= ex_inst.J_immed;
	
	end else begin 
		ex_inst.instruction <= de_inst.instruction;
		ex_inst.pc <= de_inst.pc;
		ex_inst.opcode <= OPCODE;
		ex_inst.rs1_addr <= rs1_addr;
		ex_inst.rs2_addr <= rs2_addr;
		ex_inst.rd_addr <= rd_addr;
		ex_inst.rs1 <= rs1;
		ex_inst.rs2 <= rs2;
		ex_inst.rs1_used <= rs1_used;
		ex_inst.rs2_used <= rs2_used;
		ex_inst.opA_sel <= opA_sel;
		ex_inst.opB_sel <= opB_sel;
		ex_inst.alu_fun <= alu_fun;
		ex_inst.rf_wr_sel <= rf_wr_sel;
		ex_inst.regWrite <= regWrite;
		ex_inst.memWrite <= memWrite;
		ex_inst.memRead2 <= memRead2;
		ex_inst.mem_type <= de_inst.instruction[13:12];
		ex_inst.mem_size <= de_inst.instruction[14];
		ex_inst.I_immed <= I_immed;
		ex_inst.S_immed <= S_immed;
		ex_inst.U_immed <= U_immed;
		ex_inst.B_immed <= B_immed; 
		ex_inst.J_immed <= J_immed;
	
	end
	  
	end    


	//==== Execute ======================================================

	logic [31:0] mem_rs2;
	logic mem_aluRes = 0;
	logic [31:0] opA_forwarded;
	logic [31:0] opB_forwarded;

	wire [31:0] alu_result;
	
	mux_4t1_nb forwardMuxA (
		.SEL(fsel1),
		.D0(ex_inst.rs1),
		.D1(mem_inst.alu_result),
		.D2(rfIn),
		.D3(32'b0),
		.D_OUT(opA_forwarded)
	);
	
	mux_4t1_nb forwardMuxB (
		.SEL(fsel2),
		.D0(ex_inst.rs2),
		.D1(mem_inst.alu_result),
		.D2(rfIn),
		.D3(32'b0),
		.D_OUT(opB_forwarded)
	);
	
	wire [31:0] aluAin;
	mux_2t1_nb aluMuxA (
		.SEL(ex_inst.opA_sel),
		.D0(opA_forwarded),
		.D1(ex_inst.U_immed),
		.D_OUT(aluAin)
	);
	
	wire [31:0] aluBin;
	mux_4t1_nb aluMuxB (
		.SEL(ex_inst.opB_sel),
		.D0(opB_forwarded),
		.D1(ex_inst.I_immed),
		.D2(ex_inst.S_immed),
		.D3(ex_inst.pc),
		.D_OUT(aluBin)
	);
	
	ALU ALU (    
		.srcA(aluAin),
		.srcB(aluBin),
		.alu_fun(ex_inst.alu_fun),
		.result(alu_result)
	); // the ALU
	
	BRANCH_ADDR_GEN BAG(
		.rs(opA_forwarded), 
		.I_type(ex_inst.I_immed), 
		.J_type(ex_inst.J_immed), 
		.B_type(ex_inst.B_immed), 
		.PC(ex_inst.pc),
		.jal(jal_pc), 
		.jalr(jalr_pc), 
		.branch(branch_pc)
	);
	
	BRANCH_COND_GEN BCG(
		.IR_FUNC3(ex_inst.instruction[14:12]),
		.opcode(ex_inst.opcode),
		.rs1(opA_forwarded), 
		.rs2(opB_forwarded),
		.br_eq(br_eq), 
		.br_lt(br_lt), 
		.br_ltu(br_ltu),
		.PC_SOURCE(pc_source),
		.BRANCH_TAKEN(BRANCH_TAKEN)
	);
	
	wire [1:0] mem_data_sel;
	wire scratchRead, romRead;
	
	assign romRead = alu_result <= 32'h0000_7FFF && (ex_inst.opcode == LOAD);
	assign scratchRead = ((alu_result >= 32'h0000_8000) && (alu_result <= 32'h0000_FFFF)) && (ex_inst.opcode == LOAD || ex_inst.opcode == STORE);
	
	assign mem_data_sel = ((ex_inst.opcode == LOAD || ex_inst.opcode == STORE) && (alu_result <= 32'h0000_7FFF)) ? 2'b00 : 
								((ex_inst.opcode == LOAD || ex_inst.opcode == STORE) && ((alu_result >= 32'h0000_8000) && (alu_result <= 32'h0000_FFFF))) ? 2'b01 :
								((ex_inst.opcode == LOAD || ex_inst.opcode == STORE) && ((alu_result >= 32'h0000_8000) && (alu_result <= 32'h0000_FFFF))) ? 2'b01 :
								((ex_inst.opcode == LOAD || ex_inst.opcode == STORE) && ((alu_result >= 32'h1000_0000) && (alu_result <= 32'h1000_FFFF))) ? 2'b10 : 2'b11;
							
	
		
	always_ff @(posedge clk) begin
		if(RST) begin
			mem_inst.opcode <= opcode_t'(7'b0);
			mem_inst.rs1_addr <= 5'b0;
			mem_inst.rs2_addr <= 5'b0;
			mem_inst.rs1 <= 32'b0;
			mem_inst.rs2 <= 32'b0;
			mem_inst.rs1_used <= 0;
			mem_inst.rs2_used <= 0;
			mem_inst.opA_sel <= 2'b0;
			mem_inst.opB_sel <= 2'b0;
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
			mem_inst.romRead <= 0;
			mem_inst.scratchRead <= 0;
			mem_inst.mem_data_sel <= 2'b00;
			
		end else if (mem_wait) begin
			mem_inst.instruction <= mem_inst.instruction;
			mem_inst.pc <= mem_inst.pc;
			mem_inst.opcode <= mem_inst.opcode;
			mem_inst.rs1_addr <= mem_inst.rs1_addr;
			mem_inst.rs2_addr <= mem_inst.rs2_addr;
			mem_inst.rs1 <= mem_inst.rs1;
			mem_inst.rs2 <= mem_inst.rs2;
			mem_inst.rs2_forwarded <= mem_inst.rs2_forwarded;
			mem_inst.rs1_used <= mem_inst.rs1_used;
			mem_inst.rs2_used <= mem_inst.rs2_used;
			mem_inst.opA_sel <= mem_inst.opA_sel;
			mem_inst.opB_sel <= mem_inst.opB_sel;
			mem_inst.rd_addr <= mem_inst.rd_addr;
			mem_inst.alu_fun <= mem_inst.alu_fun;
			mem_inst.rf_wr_sel <= mem_inst.rf_wr_sel;
			mem_inst.regWrite <= mem_inst.regWrite;
			mem_inst.memWrite <= mem_inst.memWrite;
			mem_inst.memRead2 <= mem_inst.memRead2;
			mem_inst.aluAin <= mem_inst.aluAin;
			mem_inst.aluBin <= mem_inst.aluBin;
			mem_inst.mem_type <= mem_inst.instruction[13:12];
			mem_inst.mem_size <= mem_inst.instruction[14];
			mem_inst.alu_result <= mem_inst.alu_result;
			mem_inst.romRead <= mem_inst.romRead;
			mem_inst.scratchRead <= mem_inst.scratchRead;
			mem_inst.mem_data_sel <= mem_inst.mem_data_sel;
			mem_inst.I_immed <= mem_inst.I_immed;
			mem_inst.S_immed <= mem_inst.S_immed;
			mem_inst.U_immed <= mem_inst.U_immed;
			mem_inst.B_immed <= mem_inst.B_immed; 
			mem_inst.J_immed <= mem_inst.J_immed;

		end else begin
			mem_inst.instruction <= ex_inst.instruction;
			mem_inst.pc <= ex_inst.pc;
			mem_inst.opcode <= ex_inst.opcode;
			mem_inst.rs1_addr <= ex_inst.rs1_addr;
			mem_inst.rs2_addr <= ex_inst.rs2_addr;
			mem_inst.rs1 <= ex_inst.rs1;
			mem_inst.rs2 <= ex_inst.rs2;
			mem_inst.rs2_forwarded <= opB_forwarded;
			mem_inst.rs1_used <= ex_inst.rs1_used;
			mem_inst.rs2_used <= ex_inst.rs2_used;
			mem_inst.opA_sel <= ex_inst.opA_sel;
			mem_inst.opB_sel <= ex_inst.opB_sel;
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
			mem_inst.romRead <= romRead;
			mem_inst.scratchRead <= scratchRead;
			mem_inst.mem_data_sel <= mem_data_sel;
			mem_inst.I_immed <= ex_inst.I_immed;
			mem_inst.S_immed <= ex_inst.S_immed;
			mem_inst.U_immed <= ex_inst.U_immed;
			mem_inst.B_immed <= ex_inst.B_immed; 
			mem_inst.J_immed <= ex_inst.J_immed;

		end
	end


	////==== Memory ======================================================

	logic load_wait_start;
	assign load_wait_start = mem_inst.opcode == LOAD && mem_inst.memRead2 && (mem_inst.mem_data_sel == 2'b01 || mem_inst.mem_data_sel == 2'b00);	
	 
	LoadWaitFSM LoadWaitFSM (
	.CLK(clk),
	.RST(RST),
	.load_wait_start(load_wait_start),
	.mem_wait(mem_wait)
	);
	
	assign iobus_addr = mem_inst.alu_result;
	assign iobus_out = mem_inst.rs2_forwarded;
	
	wire [31:0] scratch_data;
	scratchpad_ram scratchpad_ram(
		.clk_clk(clk),          //    clk.clk
		.reset_reset_n(!RST),    //  reset.reset_n
		.reset1_reset(RST),     // reset1.reset
		.reset1_reset_req(RST), //       .reset_req
		.s_address(mem_inst.alu_result[14:2]),//      s.address word address for scratchpad, not byte address
		.s_clken(mem_inst.scratchRead && (mem_inst.memRead2 || mem_inst.memWrite)),          //       .clken
		.s_chipselect(mem_inst.scratchRead),     //       .chipselect
		.s_write(mem_inst.memWrite & mem_inst.scratchRead),          //       .write
		.s_readdata(scratch_data),       //       .readdata
		.s_writedata(mem_inst.rs2_forwarded),      //       .writedata
		.s_byteenable(4'b1111)      //       .byteenable
	);
	
	// memory data mux
	wire [31:0] mem_data;
	
	mux_4t1_nb DataMemMux(
		.SEL(mem_inst.mem_data_sel),
		.D0(rom_data),
		.D1(scratch_data),
		.D2(iobus_in),
		.D3(32'b0),
		.D_OUT(mem_data)
	);
	
	assign iobus_wr = ((mem_inst.alu_result >= 32'h1000_0000) && (mem_inst.alu_result <= 32'h1000_FFFF)) && (mem_inst.opcode == STORE) && mem_inst.memWrite;

	always_ff @(posedge clk) begin //
		if(RST) begin
			wb_inst.mem_data <= 32'b0;
			wb_inst <= 'b0;
			
		end else if (mem_wait) begin
		
			wb_inst.instruction <= wb_inst.instruction;
			wb_inst.pc <= wb_inst.pc;
			wb_inst.opcode <= wb_inst.opcode;
			wb_inst.rs1_addr <= wb_inst.rs1_addr;
			wb_inst.rs2_addr <= wb_inst.rs2_addr;
			wb_inst.rs1 <= wb_inst.rs1;
			wb_inst.rs2 <= wb_inst.rs2;
			wb_inst.rd_addr <= wb_inst.rd_addr;
			wb_inst.rs1_used <= wb_inst.rs1_used;
			wb_inst.rs2_used <= wb_inst.rs2_used;
			wb_inst.opA_sel <= wb_inst.opA_sel;
			wb_inst.opB_sel <= wb_inst.opB_sel;
			wb_inst.alu_fun <= wb_inst.alu_fun;
			wb_inst.rf_wr_sel <= wb_inst.rf_wr_sel;
			wb_inst.regWrite <= wb_inst.regWrite;
			wb_inst.memWrite <= wb_inst.memWrite;
			wb_inst.memRead2 <= wb_inst.memRead2;
			wb_inst.aluAin <= wb_inst.aluAin;
			wb_inst.aluBin <= wb_inst.aluBin;
			wb_inst.mem_type <= wb_inst.instruction[13:12];
			wb_inst.mem_size <= wb_inst.instruction[14];
			wb_inst.alu_result <= wb_inst.alu_result;
			wb_inst.mem_data <= wb_inst.mem_data;
			wb_inst.romRead <= wb_inst.romRead;
			wb_inst.scratchRead <= wb_inst.scratchRead;
			wb_inst.mem_data_sel <= wb_inst.mem_data_sel;
			wb_inst.I_immed <= wb_inst.I_immed;
			wb_inst.S_immed <= wb_inst.S_immed;
			wb_inst.U_immed <= wb_inst.U_immed;
			wb_inst.B_immed <= wb_inst.B_immed; 
			wb_inst.J_immed <= wb_inst.J_immed;
		
		end else begin
			wb_inst.instruction <= mem_inst.instruction;
			wb_inst.pc <= mem_inst.pc;
			wb_inst.opcode <= mem_inst.opcode;
			wb_inst.rs1_addr <= mem_inst.rs1_addr;
			wb_inst.rs2_addr <= mem_inst.rs2_addr;
			wb_inst.rs1 <= mem_inst.rs1;
			wb_inst.rs2 <= mem_inst.rs2;
			wb_inst.rd_addr <= mem_inst.rd_addr;
			wb_inst.rs1_used <= mem_inst.rs1_used;
			wb_inst.rs2_used <= mem_inst.rs2_used;
			wb_inst.opA_sel <= mem_inst.opA_sel;
			wb_inst.opB_sel <= mem_inst.opB_sel;
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
			wb_inst.romRead <= mem_inst.romRead;
			wb_inst.scratchRead <= mem_inst.scratchRead;
			wb_inst.mem_data_sel <= mem_inst.mem_data_sel;
			wb_inst.I_immed <= mem_inst.I_immed;
			wb_inst.S_immed <= mem_inst.S_immed;
			wb_inst.U_immed <= mem_inst.U_immed;
			wb_inst.B_immed <= mem_inst.B_immed; 
			wb_inst.J_immed <= mem_inst.J_immed;


		end
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

`default_nettype wire

