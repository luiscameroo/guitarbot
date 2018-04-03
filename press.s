#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x2000

#------ MOTOR TIMING ------#
.equ car_move_time, 200000000 #200 million (2sec)
.equ press_time, 10000000 #10 million (0.1sec) [this is tbd tho styll, fam]

#=== INTERRUPT HANDLER ===#
.section .exceptions, "ax"
ISR:
#save registers
    subi sp, sp, 8
    stw r9, 4(sp)
    stw r8, (sp)
#clear timeout bit
    movia r8, TIMER1
#turn press motor off
    movia r8, LEGO
    ldw r9, (r8)
    addi r9, r9, 0b0100 #turn off motor1
    stw r9, (r8)
#reload registers
    ldw r9, 4(sp)
    stw r8, (sp)
    addi sp, sp, 8
    subi ea, ea, 4
    eret


#=== DATA ===#
.section .data

#=== TEXT/INSTRUCTIONS ===#
.section .text
.global _start:
_start:

initialize_stack:
    movia sp, STACK

enable_interrupts:
    addi r8, r8, 1
#enable all interrupts
    wrctl r8, ctl0
#enable IRQ line 0 (Timer1)
    wrctl r8, ctl3

initialize_motor1:
    movia r8, LEGO
#parallel port boi
    movia r9, 0x07F557FF
    stw r9, 4(r8)
#turn motor1 on (motor0 left off)
    movi r9, 0b0001

initialize_timer1:
    movia r8, TIMER1

#load low 16 bits
    movui r9, %lo(press_time)
    stwio r9, 8(r8)
#load top 16 bits
    movui r9, %hi(press_time)
    stwio r9, 12(r8)
#enable interrupts, turn on timer, run once until timeout bit
    movui r9, 0b101
    stwio r9, 4(r8)

loop:
    br loop
