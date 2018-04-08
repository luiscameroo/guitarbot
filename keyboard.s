#code will recognize key presses using interrupts, acknowledge
#which key was pressed and have the bot play the corresponding chord on guitar

#=== EQU'S === #
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x00002000

#=== DATA ===#
.section .data

#=== INTERRUPT SERVICE ROUTINE ===#
.section . exceptions, "ax"

#=== PROGRAM INSTRUCTIONS ===#
.section .text
