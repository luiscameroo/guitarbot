#Final product!

#=== EQU'S ===#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x00002000
.equ PS201, 0xFF200100

#=== DATA ===#
.section .data

.align 2

byte1: .long 0x0
byte2: .long 0x0
byte3: .long 0x0

#=== INTERRUPT SERVICE ROUTINE ===#
.section .exceptions, "ax"
ISR:

#=== PROGRAM INSTRUCTIONS ===#
.section .text

.global _start
_start:

#=== initializations ===#



#=== subroutines ===#

# READ KEYBOARD SUBROUTINE #
#will return byte value in r2
#might return a boolean in r3? (indicating whether read was valid but should be unnecessary in interrupts).
read_keyboard:
    movia r8, PS201
    ldwio r9, (r8)
    andi r10, r9, 0x08000
    beq r0, r10, read_invalid
    andi r10, r9, 0x0FF
#shift bytes read from keyboard

#byte1 = byte2;
    movia r9, byte1
    movia r11, byte2
    ldw r12, (r11)
    stw r12, (r9)
#byte2 = byte3;
    movia r9, byte3
    ldw r12, (r9)
    stw r12, (r11)
#byte3 = data_read;
    stw r10, (r9)
    br done_read_keyboard
read_invalid:
    mov r2, r0
done_read_keyboard:
    ret

# TIMER2 PWM SUBROUTINE #

# TIMER1 STRUM SUBROUTINE #

# VGA SUBROUTINE #

