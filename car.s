#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
.equ FRET1_TIME, 0x00
.equ FRET2_TIME, 0x00
.equ FRET3_TIME, 0x00
.equ FRET4_TIME, 0x00
.equ FRET5_TIME, 0x00
.equ FRET6_TIME, 0x00
.equ FRET7_TIME, 0x00

#=== CAR MODULES ===#

.section .text

.global car_forward
car_forward:

.global car_reverse
car_reverse:


