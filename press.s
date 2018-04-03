#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
.equ car_move_time, 200000000 #200 million (2sec)
.equ press_time, 50000000 #50 million (0.5sec) [this is tbd tho styll, fam]

#=== INTERRUPT HANDLER ===#
.section .exceptions, "ax"

#=== DATA ===#
.section .data

#=== TEXT/INSTRUCTIONS ===#
.section .text
