#we rly hate ourselves so lets use sensors now!

#=== EQU'S ===#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x03FFFFFC
.equ PS201, 0xFF200100

#------ MOTOR TIMING ------#
.equ X_MOVE,  2000000
.equ Y_MOVE,  2000000
.equ X_PWM,  2000000
.equ Y_PWM,  2000000
.equ PWM_ON, 50000000
.equ PWM_OFF, 50000000

#=== KEYBOARD EQU'S ===#
.equ BREAK, 0x0f0
.equ MAKEA, 0x01c
.equ MAKEF, 0x02b
.equ MAKEG, 0x034
.equ MAKEP, 0x04d

#=== DATA ===#
.section .data
.align 2

current_fret: .long 0x01
next_fret: .long 0x01

#=== INTERRUPT SERVICE ROUTINE ===#
.section .exceptions, "ax"
ISR:

#=== PROGRAM INSTRUCTIONS ===#
.section .text

.global _start
_start:
