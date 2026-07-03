`timescale 1ns / 1ps

module CU_DCDR(
    input logic IR_FUNC7,
    input logic [6:0] IR_OPCODE,
    input logic [2:0] IR_FUNC3,
	 input logic br_eq,
	 input logic br_lt,
	 input logic br_ltu,

    output logic [3:0] ALU_FUN,
    output logic ALU_SRCA,
    output logic [1:0] ALU_SRCB,
    output logic [1:0] PC_SOURCE,
    output logic [1:0] RF_WR_SEL,
    output logic REG_WRITE,
    output logic MEM_WE2,
    output logic MEM_RDEN2,
	 output logic BRANCH
    );
    
    //Create always comb clock for decoder logic

    always_comb begin
        //Instantiate all outputs to 0 so as to avoid
        //unwanted leftovers from previous operations
        //and maintain direct control of outputs through
        //case statement below
        ALU_FUN = 4'b0000;
        ALU_SRCA = 1'b0;
        ALU_SRCB = 2'b00;
        PC_SOURCE = 2'b00;
        RF_WR_SEL = 2'b11;
        REG_WRITE = 1'b0;
        MEM_WE2 = 1'b0;
        MEM_RDEN2 = 1'b0;
		  BRANCH = 1'b0;
        
        
        //Case statement depending on the opcode for the 
        //instruction, or the last seven bits of each instruction
        case (IR_OPCODE)
            7'b0010111: begin // AUIPC
                ALU_SRCA = 1'b1;
                ALU_SRCB = 2'b11;
                RF_WR_SEL = 2'b00;
                REG_WRITE = 1'b1;
            end
            7'b1101111: begin // JAL
                PC_SOURCE = 2'b11;
                REG_WRITE = 1'b1;
            end
            7'b1100111: begin // JALR
                PC_SOURCE = 2'b01;
                REG_WRITE = 1'b1;
            end
            7'b0100011: begin // Store Instructions
                ALU_SRCB = 2'b10;
                MEM_WE2 = 1'b1;
            end
            7'b0000011: begin // Load Instructions
                ALU_SRCB = 2'b01;
                RF_WR_SEL = 2'b01;
                REG_WRITE = 1'b1;
                MEM_RDEN2 = 1'b1;
            end
            7'b0110111: begin // LUI
                ALU_FUN = 4'b1001; //lui copy
                ALU_SRCA = 1'b1;
                RF_WR_SEL = 2'b00;
                REG_WRITE = 1'b1;
            end
            7'b0010011: begin // I-Type
                //set constants for all I-type instructions
                ALU_SRCB = 2'b01;
                RF_WR_SEL = 2'b00;
                REG_WRITE = 1'b1;
                
                //Nested case statement
                //dependent on the function 3 bits
                case (IR_FUNC3)
                    3'b000: begin ALU_FUN = 4'b0000; end //ADD
                    3'b001: begin ALU_FUN = 4'b0001; end //SLL
                    3'b010: begin ALU_FUN = 4'b0010; end //SLT
                    3'b011: begin ALU_FUN = 4'b0011; end //SLTU
                    3'b100: begin ALU_FUN = 4'b0100; end //XOR
                    3'b101: begin
                        //nested case statement
                        //dependent on the 30th bit for 
                        //instructions that have the same opcode and 
                        //fucntion 3 bits
                        case(IR_FUNC7)
                            1'b0: begin ALU_FUN = 4'b0101; end //SRL
                            1'b1: begin ALU_FUN = 4'b1101; end //SRA
                            default: begin end
                        endcase
                    end
                    3'b110: begin ALU_FUN = 4'b0110; end //or
                    3'b111: begin ALU_FUN = 4'b0111; end //and
                endcase
            end
            7'b0110011: begin // R-Type
                //set constants for all R-types;
                //ALU_FUN is just the concatenation of
                //the 30th bit and the function 3 bits
                RF_WR_SEL = 2'b00;
                ALU_FUN = {IR_FUNC7, IR_FUNC3};
                REG_WRITE = 1'b1;
            end
            7'b1100011: begin // B-Type
                //nested case statement dependent on the
                //function three bits.
                //Because there are six real branch instructions, there
                //are six pairs of if-else statements in each of six cases
                //for the branch instructions.
                case(IR_FUNC3)
                    3'b000: begin   //BEQ
                            
									 if(br_eq) begin
										PC_SOURCE = 2'b10;
										BRANCH = 1;
									 end else begin
										PC_SOURCE = 2'b00;
										BRANCH = 0;
									 end
                    end
                    3'b001: begin   //BNE
                            if(!br_eq) begin
										PC_SOURCE = 2'b10;
										BRANCH = 1;
									 end else begin
										PC_SOURCE = 2'b00;
										BRANCH = 0;
									 end
                    end
                    3'b100: begin   //BLT
                            if(br_lt) begin
										PC_SOURCE = 2'b10;
										BRANCH = 1;
									 end else begin
										PC_SOURCE = 2'b00;
										BRANCH = 0;
									 end
                    end
                    3'b101: begin   //BGE
                            if(br_eq | !br_lt) begin
										PC_SOURCE = 2'b10;
										BRANCH = 1;
									 end else begin
										PC_SOURCE = 2'b00;
										BRANCH = 0;
									 end

                    end
                    3'b110: begin   //BLTU
                            if(br_ltu) begin
										PC_SOURCE = 2'b10;
										BRANCH = 1;
									 end else begin
										PC_SOURCE = 2'b00;
										BRANCH = 0;
									 end

                    end
                    3'b111: begin   //BGEU
                            if(br_eq | !br_ltu) begin
										PC_SOURCE = 2'b10;
										BRANCH = 1;
									 end else begin
										PC_SOURCE = 2'b00;
										BRANCH = 0;
									 end

                    end
                    default: begin
                        PC_SOURCE = 2'b00;
                    end
                endcase
            end
            default: begin end
        endcase
    end
    
endmodule
