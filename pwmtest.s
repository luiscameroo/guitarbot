#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
#100MHz; currently duty cycle of 0.5
.equ PWM_ON, 5000000
.equ PWM_OFF, 5000000

#----- DATA -----#

.section .data
.PWM_FLAG: .word 0x0


####################################
#============ INTERRUPT ===========#

.section .exceptions, "ax"
ISR:


#========== INSTRUCTIONS ==========#

.section .text

.global _start
_start:

initialize_stack:
movia sp, STACK

initialize_timer2:
movia r8, TIMER2
