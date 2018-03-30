#NOTES
#use timer1 (when NOT counting strums)
#initiate timer in this file, make sure it is NOT continuous
#(stop timer when finished period of PRESS_TIME)

#OR

#Poll current timer1 for a certain time to lift chords up
#Basically do not stop strumming while lifting/moving chords


#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
.equ PRESS_TIME 0x00 #Currently uninitialized.

####################################
#=== CHORD MODULES ===#

.section .text

#=== CHORD_DOWN ===#
.global chord_down
chord_down:
# CALLEE-SAVE HERE

# load LEGO IO address
    movia r16, LEGO

# set motor to forward, on (preserve other info)
    ldw r17, (r16)
    andi r17, r17, 0xFFF3 #(....0011)
    stwio r17, (r16)

    movia r18, TIMER1
    movia r19, PRESS_TIME

poll_to_STOP: #poll timer1 to see if it is equal to or has exceeded PRESS_TIME.
    ldw r20, (r16)
    bge r20, r17, chord_down_stop
    br poll_to_STOP

chord_down_stop:
    addi r17, r17, 0x04
    stwio r17, (r16)

# return to previous
    ret


#=== CHORD_UP ===#
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


