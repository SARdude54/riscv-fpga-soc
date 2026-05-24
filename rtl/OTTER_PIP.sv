`timescale 1ns / 1ps

import isa_pkg::*;
    

module OTTER_PIP(input clk,
                input RST,
                input intr,
                input [31:0] iobus_in,
                output [31:0] iobus_out,
                output [31:0] iobus_addr,
                output logic iobus_wr 
);           
    wire [6:0] opcode;
    wire [31:0] pc, pc_value, next_pc, jalr_pc, jal_pc, branch_pc, jump_pc, int_pc,A,B,
         aluBin, aluAin, aluResult, rfIn, mem_data, rs1, rs2;
    wire [31:0] I_immed,S_immed,U_immed, B_immed, J_immed;
    wire [31:0] IR;
    wire [31:0] alu_result;
    
    wire pcWrite,regWrite,memWrite, op1_sel,mem_op,IorD,pcWriteCond,memRead, memRead2;
    wire [1:0] pc_source;
    wire [1:0] opB_sel, rf_sel, wb_sel, mSize;
    logic [1:0] pc_sel;
    wire [1:0] rf_wr_sel;
    wire [3:0]alu_fun;
    wire opA_sel;
                 
              
              
    instr_t de_inst, ex_inst, mem_inst, wb_inst;
//==== Instruction Fetch ===========================================

     
    assign pcWrite = 1'b1; 	//Hardwired high, assuming now hazards

    mux_4t1_nb #(.n(32)) PC_mux (
        .SEL (pc_source),
        .D0 (pc + 4),
        .D1 (jalr_pc),
        .D2 (branch_pc),
        .D3 (jal_pc),
        .D_OUT (pc_value) );
     
    reg_nb_sclr otter_pc(
      .clk(clk), 
      .clr(RST), 
      .ld(pcWrite), 
      .data_in(pc_value),
      .data_out(pc));

    assign next_pc = pc + 4;
           
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
    
    opcode_t OPCODE;
    assign OPCODE = opcode_t'(opcode);

    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [4:0] rd_addr;
       
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
             
            
                 
    RegFile regfile(
    .clk(clk),
    .en(regWrite),
    .addr1(rs1_addr),
    .addr2(rs2_addr),
    .w_adr(rd_addr),
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
    .J_type(J_immed));
    
    BRANCH_ADDR_GEN OTTER_BAG(.rs(rs1), .I_type(I_immed), .J_type(J_immed), .B_type(B_immed), .PC(de_inst.pc),
         .jal(jal_pc), .jalr(jalr_pc), .branch(branch_pc));
    

     
    logic br_lt,br_eq,br_ltu;       //branch condition wires

    // control unit
    CU_DCDR control_unit(
    .IR_FUNC7(IR[30]),
    .IR_OPCODE(de_inst.opcode),
    .IR_FUNC3(IR[14:12]),
    .ALU_FUN(alu_fun),
    .ALU_SRCA(opA_sel),
    .ALU_SRCB(opB_sel),
    .PC_SOURCE(pc_source),
    .RF_WR_SEL(rf_wr_sel),
    .REG_WRITE(regWrite),
    .MEM_WE2(memWrite),
    .MEM_RDEN2(memRead2)
    );
        
    //ALU muxes
    mux_2t1_nb alu_muxA(.SEL(opA_sel), .D0(rs1), .D1(U_immed), .D_OUT(aluAin));
    mux_4t1_nb alu_muxB(.SEL(opB_sel), .D0(rs2), .D1(I_immed), .D2(S_immed), .D3(pc), .D_OUT(aluBin));

   //pipeline register
   always_ff @(posedge clk) begin

        ex_inst.instruction <= IR;
        ex_inst.rs1_addr <= rs1_addr;
        ex_inst.rs2_addr <= rs2_addr;
        ex_inst.rd_addr <= rd_addr;
        ex_inst.opcode <= OPCODE;
        ex_inst.alu_fun <= alu_fun;
        ex_inst.rs1 <= rs1;
        ex_inst.rs2 <= rs2;
        ex_inst.mem_type <= IR[13:12];
        ex_inst.mem_size <= IR[14];
        ex_inst.rf_wr_sel <= rf_wr_sel;
        ex_inst.regWrite <= regWrite;
        ex_inst.memWrite <= memWrite;
        ex_inst.memRead2 <= memRead2;
        ex_inst <= de_inst;
    end    
	
	
//==== Execute ======================================================

     logic [31:0] mem_rs2;
     logic mem_aluRes = 0;
     logic [31:0] opA_forwarded;
     logic [31:0] opB_forwarded;
    

    BRANCH_COND_GEN OTTER_BCG(.rs1(ex_inst.rs1), .rs2(ex_inst.rs2), .br_eq(br_eq), .br_lt(br_lt), .br_ltu(br_ltu));
     
     // Creates a RISC-V ALU
    ALU OTTER_ALU (    
    .srcA(aluAin),
    .srcB(aluBin),
    .alu_fun(ex_inst.alu_fun),
    .result(alu_result)); // the ALU
    
    always_ff @(posedge clk) begin
                mem_inst.alu_result <= alu_result;
                mem_inst <= ex_inst;
     end


////==== Memory ======================================================
     
    assign iobus_addr = mem_inst.alu_result;
    assign iobus_out = mem_inst.rs2;
    
    
    always_ff @(posedge clk) begin //
        wb_inst <= mem_inst;
    end
 
     
//==== Write Back ==================================================

    mux_4t1_nb WB_mux (
        .SEL(wb_sel),
        .D0(wb_inst.alu_result),
        .D1(wb_inst.mem_data),
        .D2(wb_inst.pc+4),
        .D3(0),
        .D_OUT(rfIn)
    );

       
            
endmodule
