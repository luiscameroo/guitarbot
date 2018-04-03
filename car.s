#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
.equ car_move_time, 200000000 #200 million (2sec)
.equ press_time, 50000000 #50 million (0.5sec) [this is tbd tho styll, fam]
.equ PWM_ON, 30000
.equ PWM_OFF, 70000

#=== INTERRUPT HANDLER ===#
#NOTE: this is exclusive to timer1 for car.
.section .exceptions, "ax"
ISR:

check_ISR:

    subi sp, sp, 20
    stw r8, 16(sp)
    stw et, et, 12(sp)
    stw r9, 8(sp)
    stw ea, 4(sp)
    rdctl r8, ctl1
    stw r8, (sp)

    rdctl et, ctl4
    andi et, et, 0b01
    beq r0, et, timer2_int

timer1_int:
    movia et, LEGO
    stwio r0, (et)

    movia r8, LEGO
    ldwio et, (r8)
    andi et, et, 0b0100000
    beq r0, et, reverse

forward:
    movia et, 0xFFFFFFCF
    stwio et, (r8)
    br done

reverse:
    movia et, 0xFFFFFFEF
    stwio et, (r8)
    br done

timer2_int:
    movui et, 0x1
    wrctl ctl3, et
    wrctl status, et

    movia r8, LEGO

    ldwio et, (r8)
    andi et, et, 0b010000

    beq r0, et, off

on:
    ldwio et, (r8)
    andi et, et, 0xFFEF
    stwio et, (r8)

    movia r8, TIMER2

    stwio r0, (r8)
    movui et, %lo(PWM_ON)
    stwio et, 8(r8)

    movui et, %hi(PWM_ON)
    stwio et, 12(r8)

    movui et, 0b0101
    stwio et, 4(r8)

done:
    wrctl status, r0
    movui et, 0b0101
    wrctl ctl3, et

    ldw r8, (sp)
    wrctl ctl1, r8
    ldw r8, 16(sp)
    ldw et, et, 12(sp)
    ldw r9, 8(sp)
    ldw ea, 4(sp)
    addi sp, sp, 20





#=== DATA ===#
.section .data

#flags below; initialize all to 0 at the beginning.
is_strumming: .word 0x0
is_moving: .word 0x0
is_pressing: .word 0x0


.section .text
.global _start

_start:

initialize_stack:
    movia sp, STACK

initialize_interrupts:
    addi r8, r8, 1
    wrctl ctl0, r8
    addi r8, r8, 4
    wrctl ctl3, r8

initialize_motor2: #it is the 3rd motor associated with the car.
    movia r8, LEGO
#Parellel port- setting to default
    movia r9, 0x07F557FF
    stw r9, 4(r8)
#Turn motor2 on
    movi r9, 0b000101
    stw r9, (r8)


initialize_timer1:
    movia r8, TIMER1
#load car_move_time into timer (2 seconds)
#load low 16 bits
    movia r9, %lo(car_move_time)
    stwio r9, 8(r8)
#load top 16 bits
    movia r9, %hi(car_move_time)
    stwio r9, 12(r8)
#enable interrupts, turn on timer, run once until timeout bit
    movui r9, 0b101
    stwio r9, 4(r8)

initialize_timer2:
    movia r8, TIMER2
    movui r9, %lo(PWM_ON)
    stwio r9, 8(r8)

    movui r9, %hi(PWM_ON)
    stwio r9, 12(r8)

    stwio r0, (r8)

    movui r9, 0b0101
    stwio r9, 4(r8)


loop:
    br loop


