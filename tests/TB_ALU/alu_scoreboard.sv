
class alu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(alu_scoreboard)

    // tell the scoreboard that it can recieve alu_transaction objects
    // uvm_analysis_imp(transaction type being received, class containing the write() method)
    uvm_analysis_imp #(alu_transaction, alu_scoreboard) analysis_export;
    

    function new(
        string name = "alu_scoreboard",
        uvm_component parent = null
    );

        super.new(name, parent);

        analysis_export = new("analysis_export", this);
    endfunction

    function void write(alu_transaction tx);
    
        logic [31:0] expected;

        // build reference model
        case (tx.alu_fun)
        
            ALU_ADD:
                expected = tx.srcA + tx.srcB;

            ALU_SUB:
                expected = tx.srcA - tx.srcB;

            ALU_OR:
                expected = tx.srcA | tx.srcB;

            ALU_AND:
                expected = tx.srcA & tx.srcB;

            ALU_XOR:
                expected = tx.srcA ^ tx.srcB;

            ALU_SRL:
                expected = tx.srcA >> tx.srcB;

            ALU_SLL:
                expected = tx.srcA << tx.srcB;

            ALU_SRA:
                expected = $signed(tx.srcA) >>> tx.srcB[4:0];

            ALU_SLT:
                expected = ($signed(tx.srcA) < $signed(tx.srcB))
                ? 32'd1
                : 32'd0;

            ALU_COPY:
                expected = tx.srcA;

            default:
                expected = 32'hDEAD_BEEF;
        endcase

        // compare expected and actual

        if(tx.result !== expected) begin // include X and Z
            `uvm_error(
                "ALU_MISMATCH",
                $sformatf(
                    {
                        "ALU result mismatch: ",
                        "srcA=0x%08h srcB=0x%08h op=%s ",
                        "expected=0x%08h actual=0x%08h"
                    },
                    tx.srcA,
                    tx.srcB,
                    tx.alu_fun.name(),
                    expected,
                    tx.result
                )
            )
        end else begin 
        
            `uvm_info(
                "ALU_PASS",
                $sformatf(
                    {
                        "PASS: srcA=0x%08h srcB=0x%08h op=%s ",
                        "result=0x%08h"
                    },
                    tx.srcA,
                    tx.srcB,
                    tx.alu_fun.name(),
                    tx.result
                ),
                UVM_LOW
            )
        
        end
    
    endfunction

endclass
