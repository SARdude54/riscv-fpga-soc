onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate /TB_core/clk
add wave -noupdate /TB_core/rst
add wave -noupdate -radix hexadecimal /TB_core/in
add wave -noupdate -radix hexadecimal /TB_core/out
add wave -noupdate -radix hexadecimal /TB_core/addr
add wave -noupdate /TB_core/wr
add wave -noupdate -divider {Core Interface}
add wave -noupdate /TB_core/UUT/clk
add wave -noupdate /TB_core/UUT/RST
add wave -noupdate -radix hexadecimal /TB_core/UUT/iobus_in
add wave -noupdate -radix hexadecimal /TB_core/UUT/iobus_out
add wave -noupdate -radix hexadecimal /TB_core/UUT/iobus_addr
add wave -noupdate /TB_core/UUT/iobus_wr
add wave -noupdate -divider {Core Internals}
add wave -noupdate -expand -group {Core IO} /TB_core/UUT/clk
add wave -noupdate -expand -group {Core IO} /TB_core/UUT/RST
add wave -noupdate -expand -group {Core IO} /TB_core/UUT/intr
add wave -noupdate -expand -group {Core IO} /TB_core/UUT/iobus_in
add wave -noupdate -expand -group {Core IO} /TB_core/UUT/iobus_out
add wave -noupdate -expand -group {Core IO} /TB_core/UUT/iobus_addr
add wave -noupdate -expand -group {Core IO} /TB_core/UUT/iobus_wr
add wave -noupdate -expand -group {Immediate Value Generator} /TB_core/UUT/I_immed
add wave -noupdate -expand -group {Immediate Value Generator} /TB_core/UUT/S_immed
add wave -noupdate -expand -group {Immediate Value Generator} /TB_core/UUT/U_immed
add wave -noupdate -expand -group {Immediate Value Generator} /TB_core/UUT/B_immed
add wave -noupdate -expand -group {Immediate Value Generator} /TB_core/UUT/J_immed
add wave -noupdate -expand -group Instructions /TB_core/UUT/IR
add wave -noupdate -expand -group Instructions /TB_core/UUT/de_inst.instruction
add wave -noupdate -expand -group Instructions /TB_core/UUT/ex_inst.instruction
add wave -noupdate -expand -group Instructions /TB_core/UUT/mem_inst.instruction
add wave -noupdate -expand -group Instructions /TB_core/UUT/wb_inst.instruction
add wave -noupdate -expand -group Opcodes /TB_core/UUT/OPCODE
add wave -noupdate -expand -group Opcodes /TB_core/UUT/opcode
add wave -noupdate -expand -group Opcodes /TB_core/UUT/ex_inst.opcode
add wave -noupdate -expand -group Opcodes /TB_core/UUT/mem_inst.opcode
add wave -noupdate -expand -group Opcodes /TB_core/UUT/wb_inst.opcode
add wave -noupdate /TB_core/UUT/regWrite
add wave -noupdate /TB_core/UUT/memWrite
add wave -noupdate /TB_core/UUT/mem_op
add wave -noupdate /TB_core/UUT/memRead
add wave -noupdate /TB_core/UUT/memRead2
add wave -noupdate /TB_core/UUT/branch
add wave -noupdate /TB_core/UUT/br_lt
add wave -noupdate /TB_core/UUT/br_eq
add wave -noupdate /TB_core/UUT/br_ltu
add wave -noupdate /TB_core/UUT/memRead1
add wave -noupdate -expand -group {PC Core Signals} /TB_core/UUT/pcWrite
add wave -noupdate -expand -group {PC Core Signals} /TB_core/UUT/pc_source
add wave -noupdate -expand -group {PC Core Signals} /TB_core/UUT/pc
add wave -noupdate -expand -group {PC Core Signals} /TB_core/UUT/jalr_pc
add wave -noupdate -expand -group {PC Core Signals} /TB_core/UUT/branch_pc
add wave -noupdate -expand -group {PC Core Signals} /TB_core/UUT/jal_pc
add wave -noupdate -expand -group {PC Core Signals} /TB_core/UUT/pc_value
add wave -noupdate /TB_core/UUT/rf_wr_sel
add wave -noupdate /TB_core/UUT/alu_fun
add wave -noupdate -expand -group {Pipeline Data} /TB_core/UUT/de_inst
add wave -noupdate -expand -group {Pipeline Data} /TB_core/UUT/ex_inst
add wave -noupdate -expand -group {Pipeline Data} -expand /TB_core/UUT/mem_inst
add wave -noupdate -expand -group {Pipeline Data} /TB_core/UUT/wb_inst
add wave -noupdate /TB_core/UUT/mem_inst.scratchRead
add wave -noupdate /TB_core/UUT/mem_data
add wave -noupdate /TB_core/UUT/rfIn
add wave -noupdate /TB_core/UUT/rs1
add wave -noupdate /TB_core/UUT/rs2
add wave -noupdate /TB_core/UUT/opA_sel
add wave -noupdate /TB_core/UUT/opB_sel
add wave -noupdate /TB_core/UUT/aluAin
add wave -noupdate /TB_core/UUT/aluBin
add wave -noupdate /TB_core/UUT/mem_rs2
add wave -noupdate /TB_core/UUT/mem_aluRes
add wave -noupdate /TB_core/UUT/opA_forwarded
add wave -noupdate /TB_core/UUT/opB_forwarded
add wave -noupdate /TB_core/UUT/alu_result
add wave -noupdate -group {PC MUX} /TB_core/UUT/PC_mux/SEL
add wave -noupdate -group {PC MUX} /TB_core/UUT/PC_mux/D0
add wave -noupdate -group {PC MUX} /TB_core/UUT/PC_mux/D1
add wave -noupdate -group {PC MUX} /TB_core/UUT/PC_mux/D2
add wave -noupdate -group {PC MUX} /TB_core/UUT/PC_mux/D3
add wave -noupdate -group {PC MUX} /TB_core/UUT/PC_mux/D_OUT
add wave -noupdate -group {PC REG} /TB_core/UUT/PC/clk
add wave -noupdate -group {PC REG} /TB_core/UUT/PC/clr
add wave -noupdate -group {PC REG} /TB_core/UUT/PC/ld
add wave -noupdate -group {PC REG} /TB_core/UUT/PC/data_in
add wave -noupdate -group {PC REG} /TB_core/UUT/PC/data_out
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/clk
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/rst
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/en
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/addr1
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/addr2
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/w_addr
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/w_data
add wave -noupdate -group {Register File Module} -expand /TB_core/UUT/regfile/ram
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/rs1
add wave -noupdate -group {Register File Module} /TB_core/UUT/regfile/rs2
add wave -noupdate -group IMMED_GEN /TB_core/UUT/IMMED_GEN/ir
add wave -noupdate -group IMMED_GEN /TB_core/UUT/IMMED_GEN/U_type
add wave -noupdate -group IMMED_GEN /TB_core/UUT/IMMED_GEN/I_type
add wave -noupdate -group IMMED_GEN /TB_core/UUT/IMMED_GEN/S_type
add wave -noupdate -group IMMED_GEN /TB_core/UUT/IMMED_GEN/J_type
add wave -noupdate -group IMMED_GEN /TB_core/UUT/IMMED_GEN/B_type
add wave -noupdate -group BAG /TB_core/UUT/BAG/J_type
add wave -noupdate -group BAG /TB_core/UUT/BAG/B_type
add wave -noupdate -group BAG /TB_core/UUT/BAG/I_type
add wave -noupdate -group BAG /TB_core/UUT/BAG/rs
add wave -noupdate -group BAG /TB_core/UUT/BAG/PC
add wave -noupdate -group BAG /TB_core/UUT/BAG/jal
add wave -noupdate -group BAG /TB_core/UUT/BAG/branch
add wave -noupdate -group BAG /TB_core/UUT/BAG/jalr
add wave -noupdate -group Decoder /TB_core/UUT/decoder/IR_FUNC7
add wave -noupdate -group Decoder /TB_core/UUT/decoder/IR_OPCODE
add wave -noupdate -group Decoder /TB_core/UUT/decoder/IR_FUNC3
add wave -noupdate -group Decoder /TB_core/UUT/decoder/ALU_FUN
add wave -noupdate -group Decoder /TB_core/UUT/decoder/ALU_SRCA
add wave -noupdate -group Decoder /TB_core/UUT/decoder/ALU_SRCB
add wave -noupdate -group Decoder /TB_core/UUT/decoder/PC_SOURCE
add wave -noupdate -group Decoder /TB_core/UUT/decoder/RF_WR_SEL
add wave -noupdate -group Decoder /TB_core/UUT/decoder/REG_WRITE
add wave -noupdate -group Decoder /TB_core/UUT/decoder/MEM_WE2
add wave -noupdate -group Decoder /TB_core/UUT/decoder/MEM_RDEN2
add wave -noupdate -group {ALU MUX A} /TB_core/UUT/alu_muxA/SEL
add wave -noupdate -group {ALU MUX A} /TB_core/UUT/alu_muxA/D0
add wave -noupdate -group {ALU MUX A} /TB_core/UUT/alu_muxA/D1
add wave -noupdate -group {ALU MUX A} /TB_core/UUT/alu_muxA/D_OUT
add wave -noupdate -group {ALU MUX B} /TB_core/UUT/alu_muxB/SEL
add wave -noupdate -group {ALU MUX B} /TB_core/UUT/alu_muxB/D0
add wave -noupdate -group {ALU MUX B} /TB_core/UUT/alu_muxB/D1
add wave -noupdate -group {ALU MUX B} /TB_core/UUT/alu_muxB/D2
add wave -noupdate -group {ALU MUX B} /TB_core/UUT/alu_muxB/D3
add wave -noupdate -group {ALU MUX B} /TB_core/UUT/alu_muxB/D_OUT
add wave -noupdate -group BCG /TB_core/UUT/BCG/rs1
add wave -noupdate -group BCG /TB_core/UUT/BCG/rs2
add wave -noupdate -group BCG /TB_core/UUT/BCG/br_eq
add wave -noupdate -group BCG /TB_core/UUT/BCG/br_lt
add wave -noupdate -group BCG /TB_core/UUT/BCG/br_ltu
add wave -noupdate -group ALU /TB_core/UUT/ALU/srcA
add wave -noupdate -group ALU /TB_core/UUT/ALU/srcB
add wave -noupdate -group ALU /TB_core/UUT/ALU/alu_fun
add wave -noupdate -group ALU /TB_core/UUT/ALU/result
add wave -noupdate -group {WB MUX} /TB_core/UUT/WB_mux/SEL
add wave -noupdate -group {WB MUX} /TB_core/UUT/WB_mux/D0
add wave -noupdate -group {WB MUX} /TB_core/UUT/WB_mux/D1
add wave -noupdate -group {WB MUX} /TB_core/UUT/WB_mux/D2
add wave -noupdate -group {WB MUX} /TB_core/UUT/WB_mux/D3
add wave -noupdate -group {WB MUX} /TB_core/UUT/WB_mux/D_OUT
add wave -noupdate -group {PC History Table} /TB_core/pc
add wave -noupdate -group {PC History Table} /TB_core/pc_prev1
add wave -noupdate -group {PC History Table} /TB_core/pc_prev2
add wave -noupdate -group {PC History Table} /TB_core/pc_prev3
add wave -noupdate -group {PC History Table} /TB_core/pc_prev4
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/readdata
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/readdata2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/address
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/address2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/byteenable
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/byteenable2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/chipselect
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/chipselect2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/clk
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/clk2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/clken
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/clken2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/debugaccess
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/freeze
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/reset
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/reset2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/reset_req
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/reset_req2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/write
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/write2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/writedata
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/writedata2
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/clocken0
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/clocken1
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/wren
add wave -noupdate -group {BOOT ROM} /TB_core/UUT/Instr_Mem/boot_rom/wren2
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/clk_clk
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/reset_reset_n
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/reset1_reset
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/reset1_reset_req
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/s_address
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/s_clken
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/s_chipselect
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/s_write
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/s_readdata
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/s_writedata
add wave -noupdate -expand -group Scratchpad /TB_core/UUT/scratchpad_ram/s_byteenable
add wave -noupdate /TB_core/UUT/wb_inst.scratchRead
add wave -noupdate /TB_core/UUT/scratchRead
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {85000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 369
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {479705 ps}
bookmark add wave bookmark0 {{2353934 ps} {2573752 ps}} 15
