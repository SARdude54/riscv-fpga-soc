.section .text.init
.global entry
.extern main

entry:
    # Set stack pointer
    la sp, __stack_top

    # Copy .data from boot ROM load image to scratchpad RAM
    # t0 = _sidata : source address in boot ROM
    # t1 = _sdata  : destination address in scratchpad RAM
    # t2 = _edata  : end of .data in scratchpad RAM

    la t0, _sidata
    la t1, _sdata
    la t2, _edata

copy_data_loop:
    beq t1, t2, clear_bss

    lw t3, 0(t0)
    sw t3, 0(t1)

    addi t0, t0, 4
    addi t1, t1, 4

    j copy_data_loop

clear_bss:
    # Clear .bss
    # t1 = _sbss
    # t2 = _ebss
    la t1, _sbss
    la t2, _ebss

clear_bss_loop:
    beq t1, t2, call_main

    sw zero, 0(t1)
    addi t1, t1, 4

    j clear_bss_loop

call_main:
    j main

end:
    j end