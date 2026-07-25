
class alu_test extends uvm_test;

    `uvm_component_utils(alu_test)

    alu_env env;


    function new(
        string name = "alu_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        e = alu_env::type_id::create(
            "env",
            this
        );

    endfunction

    task run_phase(uvm_phase phase);

        alu_sequence seq;

        phase.raise_objection(this);

        seq = alu_sequence::type_id::create("seq");

        seq.start(env.agent.sequencer);

        phase.drop_objection(this);

    endtask


endclass
