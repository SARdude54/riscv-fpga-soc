`timescale 1ns / 1ps


module CU_FSM(
    input intr,
    input clk,
    input RST,
    input [6:0] opcode,     // ir[6:0]
    output logic PC_WE,
    output logic RF_WE,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset
  );
    
    typedef  enum logic [1:0] {
       st_INIT,
	   st_FET,
       st_EX,
       st_WB
    }  state_type; 
    state_type  NS,PS; 
      
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011
    } opcode_t;
    
	opcode_t OPCODE;    //- symbolic names for instruction opcodes
     
	assign OPCODE = opcode_t'(opcode); //- Cast input as enum 
	 

	//- state registers (PS)
	always @ (posedge clk)  
        if (RST == 1)
            PS <= st_INIT;
        else
            PS <= NS;

    always_comb
    begin              
        //- schedule all outputs to avoid latch
        PC_WE = 1'b0;    RF_WE = 1'b0;    reset = 1'b0;  
		memWE2 = 1'b0;     memRDEN1 = 1'b0;    memRDEN2 = 1'b0;
                   
        case (PS)

            st_INIT: //waiting state  
            begin
                reset = 1'b1;                    
                NS = st_FET; 
            end

            st_FET: //waiting state  
            begin
                memRDEN1 = 1'b1;                    
                NS = st_EX; 
            end
              
            st_EX: //decode + execute
            begin
                PC_WE = 1'b1;
				case (OPCODE)
				    LOAD: 
                       begin
                          PC_WE = 1'b0;   
                          memRDEN2 = 1'b1;
                          NS = st_WB;
                       end
                       
                    AUIPC:
                        begin
                        RF_WE = 1'b1;
                        NS = st_FET;
                        end
     
					STORE: 
                       begin
                          RF_WE = 1'b0;
                          PC_WE = 1'b1; 
                          memWE2 = 1'b1;
                          NS = st_FET;
                       end
                    
					BRANCH: 
                       begin
                          PC_WE = 1'b1;
                          NS = st_FET;
                       end
					
					LUI: 
					   begin
                          RF_WE = 1'b1;	
                          PC_WE = 1'b1;				      
					      NS = st_FET;
					   end
					  
					OP_IMM:  // addi 
					   begin 
					      RF_WE = 1'b1;	
					      PC_WE = 1'b1;
					      NS = st_FET;
					   end
					OP_RG3: begin //Add was excluded previously
                        PC_WE = 1'b1;
                        RF_WE = 1'b1;
                        NS = st_FET;
                        end
	                JAL: 
					   begin
					      RF_WE = 1'b1; //to save address of the next instruction
					      NS = st_FET;
					   end
				    JALR:
                        begin
                        RF_WE = 1'b1;
                        NS = st_FET;
                        end
                    default:  
					   begin 
					      NS = st_FET;
					   end
					   		
                endcase
            end
               
            st_WB:
            begin
               RF_WE = 1'b1; 
               PC_WE = 1'b1;
               NS = st_FET;
               memRDEN2 = 1'b0;
            end
 
            default: NS = st_FET;
           
        endcase //- case statement for FSM states
    end
           
endmodule
