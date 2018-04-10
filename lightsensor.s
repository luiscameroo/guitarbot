#we rly hate ourselves so lets use sensors now!

#=== EQU'S ===#
.equ LEGO, 0xFF200060
.equ LEGO_CONFIG, 0x07F557FF
.equ LEGO_IRQ, 0x0800
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

.equ THRESHOLD, 0x08

#=== DATA ===#
.section .data
.align 2

current_fret: .long 0x01
next_fret: .long 0x01
direction: .long 0x01

#=== INTERRUPT SERVICE ROUTINE ===#
.section .exceptions, "ax"
ISR:
    movia r8, LEGO
    ldw r9, (r8)
    andi r10, r9, 0b01
    beq r10, r0, turn_off
turn_on:
    addi r10, r9, -1
    stw r10, (r8)
    br ISR_done
turn_off:
    addi r10, r9, 1
    stw r10, (r8)
ISR_done:
    subi ea, ea, 4
    eret




#=== PROGRAM INSTRUCTIONS ===#
.section .text

.global _start
_start:
    movia sp, STACK
    movia r8, LEGO
    movia r9, LEGO_CONFIG
    stwio r9, 4(r8)

    movia r9, 0xF83FFBFF #this might be super incorrect
    stwio r9, (r8)

    movia r9, 0xF85FFFFF
    stwio r9, (r8)

    movia r9, 0x08000000
    stwio r9, 8(r8)

    movia r8, LEGO_IRQ
    wrctl ctl3, r8

    movia r8, 1
    wrctl ctl0, r8

loop:
    br loop

#=== SUBROUTINES ===#

#assuming keyboard would now have written to next_fret
light_sensor_subroutine:
    movia r8, current_fret
    movia r9, direction
    ldw r10, (r9)
    bgt r9, r0, light_sensor_fwd

light_sensor_rev:
    ldw r10, (r8)
    addi r10, r10, -1
    movia r8, next_fret
    ldw r11, (r8)
    beq r11, r10, light_sensor_stop_motor
    br light_sensor_done

light_sensor_fwd:
    ldw r10, (r8)
    addi r10, r10, 1
    movia r8, next_fret
    ldw r11, (r8)
    beq r11, r10, light_sensor_stop_motor
    br light_sensor_done

light_sensor_stop_motor:
    movia r8, LEGO
    ldw r9, (r8)
    ori r9, r9, 0x010
    stw r9, (r8)

light_sensor_done:
    ret

