# sim/run_core.do

transcript on

# Clean old simulation library
if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# Compile RTL
# -sv                 = compile as SystemVerilog
# +define+SIMULATION  = enables `ifdef SIMULATION in Memory.sv
# +incdir+rtl         = lets files find headers/includes in rtl/

vlog -sv +define+SIMULATION +incdir+rtl rtl/isa_pkg.sv

vlog -sv +define+SIMULATION +incdir+rtl rtl/mux_2t1_nb.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/mux_4t1_nb.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/reg_nb_sclr.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/RegFile.sv

vlog -sv +define+SIMULATION +incdir+rtl rtl/ALU.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/IMMED_GEN.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/BRANCH_ADDR_GEN.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/BRANCH_COND_GEN.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/CU_DCDR.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/CU_FSM.sv

vlog -sv +define+SIMULATION +incdir+rtl rtl/Memory.sv
vlog -sv +define+SIMULATION +incdir+rtl rtl/core.sv

# Compile testbench

vlog -sv +define+SIMULATION +incdir+rtl tests/TB_core/TB_core.sv

# Select memory file.
# Default if user does not pass MEM_FILE from Tcl command line.
if {![info exists MEM_FILE]} {
    set MEM_FILE "memory.mem"
}

puts "INFO: Using memory file: $MEM_FILE"

vsim -voptargs=+acc work.TB_core +MEM=$MEM_FILE

view wave
do core_wave.do

run -all

run -all