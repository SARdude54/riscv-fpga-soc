# RISC-V baremetal init.s
# This code is executed first.

.section .text.init
.global entry
entry:
    j main
    nop
    nop
    nop
    nop

end:
    j end
    nop
    nop
    nop
    nop
