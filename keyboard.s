#code will recognize key presses using interrupts, acknowledge
#which key was pressed and have the bot play the corresponding chord on guitar

#=== EQU'S === #
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x00002000
.equ 1PS2, 0xFF200100

#=== DATA ===#
.section .data



#=== INTERRUPT SERVICE ROUTINE ===#
.section . exceptions, "ax"



#=== PROGRAM INSTRUCTIONS ===#
.section .text

#initialize stack
movia sp, STACK

#initialize keyboard interrupts (write 1 to 1st bit of control register)
movia r8, 1PS2
addi r9, r9, 1
stw r9, 4(r8)



