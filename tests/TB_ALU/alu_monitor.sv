
class alu_monitor extends uvm_monitor;

    `uvm_component_utils(alu_monitor)

    virtual alu_if vif;

    // broadcast channel
    uvm_analysis_port #(alu_transaction) ap;

    function new(
        string name = "alu_monitor",
        uvm_component parent = null
    );

        super.new(name, parent);
        ap = new("ap", this);

    endfunction

    function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // tb_top saves vif to data base
    // So both driver and monitor can retrieve it
    if(!uvm_config_db #(virtual alu_if)::get(
        this,
        "",
        "vif",
        vif
    )) begin

        `uvm_fatal(
            "NO_VIF",
            "alu_monitor could not get virtual interface"
        )

    end
        
    endfunction

    task run_phase(uvm_phase phase);

        // monitor creates a new transaction
        // it independently observes the DUT interface
        // and then creates an observed transaction
        alu_transaction tx;

        forever begin

            // ALU is combinational
            // Wait until inputs change
            @(vif.srcA or vif.srcB or vif.alu_fun)

            // allow DUT to settle
            #1;

            tx = alu_transaction::type_id::create("tx");

            tx.srcA = vif.srcA;
            tx.srcB = vif.srcB;
            tx.alu_fun = vif.alu_fun;
            tx.result = vif.result;

            `uvm_info(
                "ALU_MONITOR",
                $sformatf(
                    "Observed srcA=0x%08h srcB=0x%08h alu_fun=0x%08h result=0x%08h",
                    tx.srcA,
                    tx.srcB,
                    tx.alu_fun.name(),
                    tx.result
                ),
                UVM_LOW
            )

            // any subscriber connewcted to the AP recieves the transaction
            ap.write(tx);
        
        end

    endtask

endclass
