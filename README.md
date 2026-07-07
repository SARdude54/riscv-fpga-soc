# RV32IMAC and FreeRTOS Implimentation on the DE10-Lite FPGA
### By Saul Rodriguez

An RV32IMAC implementation on the DE10-Lite FPGA Board.

The DE10-Lite board uses the 10M50DAF484C7G.

## Background
## ISA Extension
## Design Goals
## Current Status

* Project created on 5/24/2026
* Classic 5-stage RV32I pipeline with data and control hazards. No branch predictor or CSR yet. 
* Current core and GNU link script supports boot ROM and scratchpad RAM only

## Next Steps
* Better Documentation
* Integrate SDRAM

## Schematic

## Memory Map

### Overall Memory Map

Planned memory map. SDRAM regions not implemented yet. 

| Region                      |                 Address range |    Size | Type                                | Purpose                                                                                      |
| --------------------------- | ----------------------------: | ------: | ----------------------------------- | -------------------------------------------------------------------------------------------- |
| Boot ROM                    | `0x0000_0000` – `0x0000_7FFF` |  32 KiB | BRAM / ROM IP                       | Reset code, bootloader, trap vectors                        |
| Scratchpad RAM              | `0x0000_8000` – `0x0000_FFFF` |  32 KiB | BRAM / RAM IP                       | Fast local RAM, early stack, interrupt scratch area                  |
| Reserved low BRAM expansion | `0x0001_0000` – `0x000F_FFFF` | 960 KiB | Reserved                            | Future reserved for cache              |
| MMIO / peripheral space     | `0x1000_0000` – `0x1000_FFFF` |  64 KiB | Registers / custom RTL / Quartus IP | LEDs, switches, UART, SPI, I2C, timer, ADC, accelerometer, VGA control, SDRAM control/status |
| Reserved system space       | `0x1001_0000` – `0x7FFF_FFFF` |   large | Reserved                            | Future MMIO expansion, DMA, custom accelerators                                       |
| External SDRAM              | `0x8000_0000` – `0x83FF_FFFF` |  64 MiB | SDRAM                               | Main RAM for FreeRTOS, heap, stacks, large buffers, DSP data, application code/data          |
| Reserved high memory        | `0x8400_0000` – `0xFFFF_FFFF` |   large | Reserved                            | Future reserved for external devices, framebuffers, DMA windows, memory-mapped accelerators        |


### Boot Rom Regions

| Boot ROM subregion                             |                 Address range |   Size | Type     | Purpose                                                       |
| ---------------------------------------------- | ----------------------------: | -----: | -------- | ------------------------------------------------------------- |
| Reset / trap vector area                       | `0x0000_0000` – `0x0000_00FF` |  256 B | BRAM ROM | Reset entry, early trap stubs, boot jumps                     |
| Boot startup code                              | `0x0000_0100` – `0x0000_0FFF` | ~4 KiB | BRAM ROM | C runtime setup, copy `.data`, clear `.bss`, initialize stack |
| Bootloader / diagnostics                       | `0x0000_1000` – `0x0000_3FFF` | 12 KiB | BRAM ROM | Memory test, UART boot later, SDRAM init/test code            |
| ROM `.text` / tiny bare-metal app              | `0x0000_4000` – `0x0000_6FFF` | 12 KiB | BRAM ROM | Small standalone programs or boot monitor                     |
| ROM constants / `.rodata` / `.data` load image | `0x0000_7000` – `0x0000_7FFF` |  4 KiB | BRAM ROM | Constants and initial values copied into RAM                  |


### Scratchpad RAM


| Scratchpad subregion                |                 Address range |   Size | Type     | Purpose                                                |
| ----------------------------------- | ----------------------------: | -----: | -------- | ------------------------------------------------------ |
| Early boot RAM / `.data` small mode | `0x0000_8000` – `0x0000_8FFF` |  4 KiB | BRAM RAM | Current `.data`, early runtime variables               |
| Early `.bss` / zero-init            | `0x0000_9000` – `0x0000_9FFF` |  4 KiB | BRAM RAM | Small boot `.bss`                                      |
| Interrupt / trap scratch            | `0x0000_A000` – `0x0000_AFFF` |  4 KiB | BRAM RAM | Trap stack, ISR scratch, machine-mode data             |
| Fast DSP scratch / TCM              | `0x0000_B000` – `0x0000_DFFF` | 12 KiB | BRAM RAM | Small FIR buffers, coefficient cache, low-latency data |
| Early boot stack                    | `0x0000_E000` – `0x0000_FFFF` |  8 KiB | BRAM RAM | Boot stack, fallback stack, bring-up tests             |



### SDRAM Regions

| SDRAM subregion                         |                 Address range |   Size | Type  | Purpose                                                  |
| --------------------------------------- | ----------------------------: | -----: | ----- | -------------------------------------------------------- |
| SDRAM boot/application code             | `0x8000_0000` – `0x800F_FFFF` |  1 MiB | SDRAM | Optional copied `.text` for larger apps / FreeRTOS image |
| SDRAM read-only data                    | `0x8010_0000` – `0x801F_FFFF` |  1 MiB | SDRAM | Large lookup tables, DSP coefficients, const data        |
| SDRAM initialized data                  | `0x8020_0000` – `0x802F_FFFF` |  1 MiB | SDRAM | `.data` copied from ROM/loader                           |
| SDRAM zero-init data                    | `0x8030_0000` – `0x803F_FFFF` |  1 MiB | SDRAM | `.bss`                                                   |
| FreeRTOS kernel heap                    | `0x8040_0000` – `0x807F_FFFF` |  4 MiB | SDRAM | `heap_4.c` or `heap_5.c` heap region                     |
| FreeRTOS task stacks / task data        | `0x8080_0000` – `0x80FF_FFFF` |  8 MiB | SDRAM | Task stacks, queues, buffers                             |
| DSP working buffers                     | `0x8100_0000` – `0x81FF_FFFF` | 16 MiB | SDRAM | ADC samples, FIR/FFT buffers, audio/image data           |
| DMA / accelerator buffers               | `0x8200_0000` – `0x82FF_FFFF` | 16 MiB | SDRAM | DMA-safe buffers for SPI/VGA/DSP accelerators            |
| Framebuffer / video / large I/O buffers | `0x8300_0000` – `0x83EF_FFFF` | 15 MiB | SDRAM | VGA framebuffer, logging buffers, streaming data         |
| SDRAM top stack / guard                 | `0x83F0_0000` – `0x83FF_FFFF` |  1 MiB | SDRAM | Main application stack, guard/debug area                 |

