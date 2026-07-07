ENTRY(entry)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 32K
    RAM (rwx) : ORIGIN = 0x00008000, LENGTH = 32K
}

SECTIONS
{
    .text.init : {
        KEEP(*(.text.init))
    } > ROM

    .text : {
        *(.text)
        *(.text.*)
    } > ROM

    .rodata : {
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
    } > ROM

    . = ALIGN(4);

    _sidata = LOADADDR(.data);

    .data : {
        _sdata = .;
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
        *(.got*)
        . = ALIGN(4);
        _edata = .;
    } > RAM AT> ROM

    .bss : {
        _sbss = .;
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    _end = .;

    __stack_top = ORIGIN(RAM) + LENGTH(RAM);

    ASSERT(_edata <= 0x0000F000, "ERROR: .data overlaps stack region")
    ASSERT(_ebss <= 0x0000F000, "ERROR: .bss overlaps stack region")
}