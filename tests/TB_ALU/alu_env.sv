
class alu_env extends uvm_env;

    // The test component describes what scenario to run
    // The environment should describe how the verification components
    //      exist and how are they connecte

    // Future tests can reuse the environment without rebuilding the agent-scoreboard wiring
    // Ex: alu_basic_test, alu_shift_test, alu_compare_test, alu_corner_test

    `uvm_component_utils(alu_env)

    alu_agent agent;
    alu_scoreboard scoreboard;

    function new(
        string name = "alu_env",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = alu_agent::type_id::create(
            "agent",
            this
        );

        scoreboard = alu_scoreboard::type_id::create(
            "scoreboard",
            this
        );

    endfunction

    function void connect_phase(uvm_phase phase);
    
        // connect monitor to the scoreboard
        super.connect_phase(phase);

        agent.monitor.ap.connect(
            scoreboard.analysis_export
        );

    endfunction

endclass
