# sim/run_core.tcl
# Questa/ModelSim RTL simulation script for the RISC-V core

# Sim only

transcript on

# Old simulation library
if {[file exists work]} {
    puts "INFO: Removing old work library"
    vdel -lib work -all
}

vlib work
vmap work work

# Defaults from Makefile

if {![info exists TB_SRC]} {
    set TB_SRC "tests/TB_core/TB_core.sv"
}

if {![info exists TB_TOP]} {
    set TB_TOP "TB_core"
}

if {![info exists MEM_FILE]} {
    set MEM_FILE "memory.mem"
}

if {![info exists WAVE_DO]} {
    set WAVE_DO "sim/waves/core_wave.do"
}

puts "------------------------------------------------------------"
puts "INFO: Questa simulation configuration"
puts "INFO: Testbench source: $TB_SRC"
puts "INFO: Testbench top:    $TB_TOP"
puts "INFO: Memory file:      $MEM_FILE"
puts "INFO: Wave script:      $WAVE_DO"
puts "------------------------------------------------------------"

# Include directories

set INCDIRS "+incdir+rtl +incdir+rtl/core +incdir+rtl/memory +incdir+rtl/utils"

# Compile RTL
# Compile packages first
# Then compile reusable utility modules
# Then compile core blocks
# Then memory
# Then the core top

puts "INFO: Compiling RTL packages"

vlog -sv +define+SIMULATION $INCDIRS rtl/core/isa_pkg.sv

puts "INFO: Compiling RTL utility modules"

vlog -sv +define+SIMULATION $INCDIRS rtl/utils/mux_2t1_nb.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/utils/mux_4t1_nb.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/utils/reg_nb_sclr.sv

puts "INFO: Compiling core modules"

vlog -sv +define+SIMULATION $INCDIRS rtl/core/RegFile.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/core/ALU.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/core/IMMED_GEN.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/core/BRANCH_ADDR_GEN.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/core/BRANCH_COND_GEN.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/core/CU_DCDR.sv
vlog -sv +define+SIMULATION $INCDIRS rtl/core/CU_FSM.sv

puts "INFO: Compiling memory modules"

vlog -sv +define+SIMULATION $INCDIRS rtl/memory/Memory.sv

puts "INFO: Compiling core top"

vlog -sv +define+SIMULATION $INCDIRS rtl/core/core.sv

# Compile selected testbench

puts "INFO: Compiling testbench: $TB_SRC"

vlog -sv +define+SIMULATION $INCDIRS $TB_SRC

# Simulate selected testbench top

puts "INFO: Starting simulation: work.$TB_TOP"
puts "INFO: Passing memory image with +MEM=$MEM_FILE"

vsim -voptargs=+acc work.$TB_TOP +MEM=$MEM_FILE

# Waveform setup

view wave

if {$WAVE_DO ne "" && [file exists $WAVE_DO]} {

    puts "INFO: Loading waveform script: $WAVE_DO"
    do $WAVE_DO

} else {

    puts "INFO: No waveform script found. Creating default wave view."

    add wave -noupdate -divider {Testbench}

    if {[find signals sim:/$TB_TOP/clk] ne ""} {
        add wave -noupdate sim:/$TB_TOP/clk
    }

    if {[find signals sim:/$TB_TOP/rst] ne ""} {
        add wave -noupdate sim:/$TB_TOP/rst
    }

    if {[find signals sim:/$TB_TOP/in] ne ""} {
        add wave -noupdate -radix hexadecimal sim:/$TB_TOP/in
    }

    if {[find signals sim:/$TB_TOP/out] ne ""} {
        add wave -noupdate -radix hexadecimal sim:/$TB_TOP/out
    }

    if {[find signals sim:/$TB_TOP/addr] ne ""} {
        add wave -noupdate -radix hexadecimal sim:/$TB_TOP/addr
    }

    if {[find signals sim:/$TB_TOP/wr] ne ""} {
        add wave -noupdate sim:/$TB_TOP/wr
    }

    # Common DUT instance names
    # Your TB_core_no_mem used UUT earlier
    # If your normal TB_core uses a different name, add it here
    set DUT_PATH ""

    if {[find instances sim:/$TB_TOP/UUT] ne ""} {
        set DUT_PATH "sim:/$TB_TOP/UUT"
    } elseif {[find instances sim:/$TB_TOP/dut] ne ""} {
        set DUT_PATH "sim:/$TB_TOP/dut"
    } elseif {[find instances sim:/$TB_TOP/DUT] ne ""} {
        set DUT_PATH "sim:/$TB_TOP/DUT"
    }

    if {$DUT_PATH ne ""} {
        puts "INFO: Found DUT instance: $DUT_PATH"

        add wave -noupdate -divider {Core Interface}

        if {[find signals $DUT_PATH/clk] ne ""} {
            add wave -noupdate $DUT_PATH/clk
        }

        if {[find signals $DUT_PATH/RST] ne ""} {
            add wave -noupdate $DUT_PATH/RST
        }

        if {[find signals $DUT_PATH/iobus_in] ne ""} {
            add wave -noupdate -radix hexadecimal $DUT_PATH/iobus_in
        }

        if {[find signals $DUT_PATH/iobus_out] ne ""} {
            add wave -noupdate -radix hexadecimal $DUT_PATH/iobus_out
        }

        if {[find signals $DUT_PATH/iobus_addr] ne ""} {
            add wave -noupdate -radix hexadecimal $DUT_PATH/iobus_addr
        }

        if {[find signals $DUT_PATH/iobus_wr] ne ""} {
            add wave -noupdate $DUT_PATH/iobus_wr
        }

        add wave -noupdate -divider {Core Internals}
        add wave -noupdate -r $DUT_PATH/*
    } else {
        puts "WARNING: Could not find DUT instance named UUT, dut, or DUT."
        puts "WARNING: Only testbench-level signals were added."
    }

    update
}

# Run simulation

puts "INFO: Running simulation"
run -all

puts "INFO: Simulation finished"