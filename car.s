#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
.equ car_move_time, 200000000 #200 million


#=== INTERRUPT HANDLER ===#
#NOTE: this is exclusive to timer1 for car.
.section .exceptions, "ax"
ISR:
#clear timeout bit
    movia et, TIMER1
    stwio r0, et

turn_off_motor2:
    

.section .text
.global _start

_start:

initialize_stack:
    movia sp, STACK

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
    andi r9, r9, 0xFFFF
    stwio r9, 8(r8)
#load top 16 bits
    movia r9, %hi(car_move_time)
    andi r9, r9, 0xFFFF
    stwio r9, 12(r8)
#enable interrupts, turn on timer, run once until timeout bit
    movui r9, 0b101
    stwio r9, 4(r8)

loop:
    br loop


