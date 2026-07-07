## RV32I instruction test program

.data
TESTLOAD:   .word 50
TESTSTORE:  .word 0
TESTU:      .word 0x01000770


.text
.global main

main:
    # Setup
    li a0, 50
    li a1, 1


# R-type instruction tests
R_tests:
    # ADD: 25 + 25 = 50
    li t0, 25
    add a2, t0, t0
    bne a0, a2, fail

    # SUB: 75 - 25 = 50
    li a2, 75
    sub a2, a2, t0
    bne a0, a2, fail

    # SLL: 25 << 1 = 50
    sll a2, t0, a1
    bne a0, a2, fail

    # SLT: 25 < 50 should be true
    slt a2, t0, a0
    beqz a2, fail

    # SLTU: unsigned -75 < 50 should be false
    li t0, -75
    sltu a2, t0, a0
    bnez a2, fail

    # XOR
    xor a2, t0, t0
    bnez a2, fail

    xor a2, t0, zero
    bne a2, t0, fail

    # SRL: 100 >> 1 = 50
    li a2, 100
    srl a2, a2, a1
    bne a0, a2, fail

    # SRA positive: 100 >>> 1 = 50
    li t1, -100
    li t2, -50
    li a2, 100
    sra a2, a2, a1
    bne a0, a2, fail

    # SRA negative: -100 >>> 1 = -50
    sra a2, t1, a1
    bne a2, t2, fail

    # OR
    or a2, a0, a0
    bne a0, a2, fail

    or a2, a0, zero
    bne a0, a2, fail

    # AND
    and a2, a0, a0
    bne a0, a2, fail

    and a2, a0, zero
    bnez a2, fail


# I-type instruction tests
I_tests:
    # ADDI
    li t0, 50
    bne a0, t0, fail

    addi a2, t0, -50
    bnez a2, fail

    # SLTI: 25 < 50 should be true
    li t0, 25
    slti a2, t0, 50
    beqz a2, fail

    # SLTIU: unsigned -75 < 50 should be false
    li t0, -75
    sltiu a2, t0, 50
    bnez a2, fail

    # XORI
    li t0, 25
    xori a2, t0, 25
    bnez a2, fail

    xori a2, t0, 0
    bne a2, t0, fail

    # ORI
    ori a2, a0, 50
    bne a0, a2, fail

    ori a2, a0, 0
    bne a0, a2, fail

    # ANDI
    andi a2, a0, 50
    bne a0, a2, fail

    andi a2, a0, 0
    bnez a2, fail

    # SLLI
    li t0, 25
    slli a2, t0, 1
    bne a0, a2, fail

    # SRLI
    li a2, 100
    srli a2, a2, 1
    bne a0, a2, fail

    # SRAI positive
    li t1, -100
    li t2, -50
    li a2, 100
    srai a2, a2, 1
    bne a0, a2, fail

    # SRAI negative
    srai a2, t1, 1
    bne a2, t2, fail


# Branch instruction tests
B_tests:
    li t0, -50

    # BEQ should not branch
    beq zero, a0, fail

    # BNE should not branch
    bne zero, zero, fail

    # BLT should not branch: 50 < 0 is false
    blt a0, zero, fail

    # BGE should not branch: 0 >= 50 is false
    bge zero, a0, fail

    # BLTU should not branch:
    # unsigned -50 is a large positive number, so it is not < 0
    bltu t0, zero, fail

    # BGEU should not branch:
    # unsigned 0 is not >= unsigned -50
    bgeu zero, t0, fail


# Jump instruction tests
Jump_tests:
    la t1, Load_tests

    jal t0, skip
    j fail

skip:
    jalr t0, 0(t1)

    # If JALR worked, execution should continue at Load_tests.
    # Reaching here means failure.
    j fail


# Load instruction tests
Load_tests:
    la t0, TESTLOAD
    lw t1, 0(t0)
    bne t1, a0, fail


# Store instruction tests
STORE_tests:
    la t0, TESTSTORE

    sw a0, 0(t0)
    lw t1, 0(t0)

    bne t1, a0, fail


# U-type and data-addressing test
U_tests:
    la t0, TESTU
    lw t1, 0(t0)

    # check loaded value
    li t2, 0x01000770
    bne t1, t2, fail

    j pass


# Test status routines
fail:
    li t0, 2
    li t1, 0x10000000
    sw t0, 0(t1)

fail_loop:
    j fail_loop


pass:
    li t0, 1
    li t1, 0x10000000
    sw t0, 0(t1)

pass_loop:
    j pass_loop