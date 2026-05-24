`timescale 1ns/1ps


package isa_pkg;


typedef enum logic [6:0] {
           LUI      = 7'b0110111,
           AUIPC    = 7'b0010111,
           JAL      = 7'b1101111,
           JALR     = 7'b1100111,
           BRANCH   = 7'b1100011,
           LOAD     = 7'b0000011,
           STORE    = 7'b0100011,
           OP_IMM   = 7'b0010011,
           OP       = 7'b0110011,
           SYSTEM   = 7'b1110011
 } opcode_t;

typedef struct packed{
    opcode_t opcode;
    logic [31:0] instruction;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [31:0] alu_result;
    logic [31:0] rd;
    // logic rs1_used;
    // logic rs2_used;
    logic rd_used;
    logic [3:0] alu_fun;
    logic [31:0] mem_data;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [1:0] rf_wr_sel;
    logic [1:0] mem_type;  //sign
    logic mem_size;
    logic [31:0] pc;
} instr_t;
    
endpackage : isa_pkg