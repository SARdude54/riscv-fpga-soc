# RV32IMAC and FreeRTOS Implimentation on the DE10-Lite FPGA
### By Saul Rodriguez

The goal of this personal project is to implement a RV32IMAC processor and run freeRTOS. This project will run on the DE10-Lite FPGA. 

The DE10-Lite board uses the 10M50DAF484C7G.

# Background
# ISA Extension
# Design Goals
# Current Status

* Project created on 5/24/2026
* Base project is non-hazard 5-stage RV32I pipeline

# Next Steps
* Better Documentation
* Change memory from Basys3 to DE10-LIte and run RV32I non-hazard pipeline on the FPGA
* Design data hazard schematic
* Implement data hazards
* Start thinking about branch predictor and cache

# Schematic

# Notes to Self
* Need to rebuild the memory.sv file
    - Port 1: Instruction Fetch
        - address = PC[15:2]
        - output = instruction word
    - Port 2: data load/store
        - address = ALU result
        - input = store data
        - output = load data or MMIO input
    - MMIO
        - route to external iobus if data address is outside RAM range