#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
.equ PRESS_TIME 0x00 #Currently uninitialized.

####################################
#=== CHORD MODULE ===#

.section .text

.global chord_down
chord_down:
# CALLEE-SAVE HERE

# load LEGO IO address
    movia r16, LEGO

# set motor to forward, on (preserve other info)
    ldw r17, (r16)
    andi r17, r17, 0xFFF3 #(....0011)
    stwio r17, (r16)

# return to previous
    ret

.global chord_up
chord_up:
# CALLEE-SAVE HERE

#load LEGO IO address
    movia r16, LEGO

# set motor to reverse, on (preserve other info)
    ldw r17, (r16)
    andi r17, r17, 0xFFFB #(....1011)
    stwio r17, (r16)

# return to previous
    ret


