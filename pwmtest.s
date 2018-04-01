#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------# 
.equ X_MOVE,  2000000
.equ Y_MOVE,  2000000
.equ X_PWM,  2000000
.equ Y_PWM,  2000000
.equ PWM_ON, 50000000
.equ PWM_OFF, 50000000

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
