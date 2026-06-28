onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Signals}
add wave -noupdate /TB_core/clk
add wave -noupdate /TB_core/rst
add wave -noupdate /TB_core/wr
add wave -noupdate /TB_core/in
add wave -noupdate /TB_core/out
add wave -noupdate /TB_core/addr
add wave -noupdate -divider {Core IO}
add wave -noupdate /TB_core/UUT/clk
add wave -noupdate /TB_core/UUT/RST
add wave -noupdate /TB_core/UUT/intr
add wave -noupdate /TB_core/UUT/iobus_in
add wave -noupdate /TB_core/UUT/iobus_out
add wave -noupdate /TB_core/UUT/iobus_addr
add wave -noupdate /TB_core/UUT/iobus_wr
add wave -noupdate -divider Instructions
add wave -noupdate /TB_core/UUT/IR
add wave -noupdate /TB_core/UUT/de_inst.instruction
add wave -noupdate /TB_core/UUT/ex_inst.instruction
add wave -noupdate /TB_core/UUT/mem_inst.instruction
add wave -noupdate /TB_core/UUT/wb_inst.instruction
add wave -noupdate /TB_core/UUT/opcode
add wave -noupdate -divider {PC Values}
add wave -noupdate /TB_core/UUT/pcWrite
add wave -noupdate /TB_core/UUT/pc_source
add wave -noupdate /TB_core/UUT/pc
add wave -noupdate /TB_core/UUT/pc_value
add wave -noupdate /TB_core/UUT/pc_sel
add wave -noupdate /TB_core/UUT/jalr_pc
add wave -noupdate /TB_core/UUT/jal_pc
add wave -noupdate /TB_core/UUT/branch_pc
add wave -noupdate /TB_core/UUT/jump_pc
add wave -noupdate -divider PCMux
add wave -noupdate /TB_core/UUT/PC_mux/SEL
add wave -noupdate /TB_core/UUT/PC_mux/D0
add wave -noupdate /TB_core/UUT/PC_mux/D1
add wave -noupdate /TB_core/UUT/PC_mux/D2
add wave -noupdate /TB_core/UUT/PC_mux/D3
add wave -noupdate /TB_core/UUT/PC_mux/D_OUT
add wave -noupdate -divider {ALU Intermediate}
add wave -noupdate /TB_core/UUT/opA_sel
add wave -noupdate /TB_core/UUT/opB_sel
add wave -noupdate /TB_core/UUT/alu_fun
add wave -noupdate /TB_core/UUT/aluBin
add wave -noupdate /TB_core/UUT/aluAin
add wave -noupdate /TB_core/UUT/alu_result
add wave -noupdate -divider {Register File}
add wave -noupdate /TB_core/UUT/regWrite
add wave -noupdate /TB_core/UUT/rfIn
add wave -noupdate /TB_core/UUT/rs1
add wave -noupdate /TB_core/UUT/rs2
add wave -noupdate /TB_core/UUT/rf_wr_sel
add wave -noupdate -divider {Immediate Values}
add wave -noupdate /TB_core/UUT/I_immed
add wave -noupdate /TB_core/UUT/S_immed
add wave -noupdate /TB_core/UUT/U_immed
add wave -noupdate /TB_core/UUT/B_immed
add wave -noupdate /TB_core/UUT/J_immed
add wave -noupdate -divider {Memory Signals}
add wave -noupdate /TB_core/UUT/mem_data
add wave -noupdate /TB_core/UUT/memWrite
add wave -noupdate /TB_core/UUT/mem_op
add wave -noupdate /TB_core/UUT/memRead
add wave -noupdate /TB_core/UUT/memRead2
add wave -noupdate /TB_core/UUT/mem_rs2
add wave -noupdate /TB_core/UUT/mem_aluRes
add wave -noupdate -divider {Branch Condition Signals}
add wave -noupdate /TB_core/UUT/br_lt
add wave -noupdate /TB_core/UUT/br_eq
add wave -noupdate /TB_core/UUT/br_ltu
add wave -noupdate -divider {Data Hazrd Signals}
add wave -noupdate /TB_core/UUT/opA_forwarded
add wave -noupdate /TB_core/UUT/opB_forwarded
add wave -noupdate -divider {Memory Modules Ports}
add wave -noupdate /TB_core/UUT/memory/MEM_CLK
add wave -noupdate /TB_core/UUT/memory/MEM_RDEN1
add wave -noupdate /TB_core/UUT/memory/MEM_RDEN2
add wave -noupdate /TB_core/UUT/memory/MEM_WE2
add wave -noupdate /TB_core/UUT/memory/MEM_ADDR1
add wave -noupdate /TB_core/UUT/memory/MEM_ADDR2
add wave -noupdate /TB_core/UUT/memory/MEM_DIN2
add wave -noupdate /TB_core/UUT/memory/MEM_SIZE
add wave -noupdate /TB_core/UUT/memory/MEM_SIGN
add wave -noupdate /TB_core/UUT/memory/IO_IN
add wave -noupdate /TB_core/UUT/memory/IO_WR
add wave -noupdate /TB_core/UUT/memory/MEM_DOUT1
add wave -noupdate /TB_core/UUT/memory/MEM_DOUT2
add wave -noupdate -divider {ALU Mux Ports}
add wave -noupdate /TB_core/UUT/alu_muxA/SEL
add wave -noupdate /TB_core/UUT/alu_muxA/D0
add wave -noupdate /TB_core/UUT/alu_muxA/D1
add wave -noupdate /TB_core/UUT/alu_muxA/D_OUT
add wave -noupdate /TB_core/UUT/alu_muxB/SEL
add wave -noupdate /TB_core/UUT/alu_muxB/D0
add wave -noupdate /TB_core/UUT/alu_muxB/D1
add wave -noupdate /TB_core/UUT/alu_muxB/D2
add wave -noupdate /TB_core/UUT/alu_muxB/D3
add wave -noupdate /TB_core/UUT/alu_muxB/D_OUT
add wave -noupdate -divider {Writeback Mux}
add wave -noupdate /TB_core/UUT/WB_mux/SEL
add wave -noupdate /TB_core/UUT/WB_mux/D0
add wave -noupdate /TB_core/UUT/WB_mux/D1
add wave -noupdate /TB_core/UUT/WB_mux/D2
add wave -noupdate /TB_core/UUT/WB_mux/D3
add wave -noupdate /TB_core/UUT/WB_mux/D_OUT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 294
configure wave -valuecolwidth 203
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {205128 ps}
