#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x2000

#------ MOTOR TIMING ------#
.equ car_move_time, 200000000 #200 million (2sec)
.equ press_time, 100000000 #10 million (0.1sec) [this is tbd tho styll, fam]
.equ PWM_ON, 30000
.equ PWM_OFF, 70000


#=== INTERRUPT HANDLER ===#
.section .exceptions, "ax"
ISR:
#save registers
    subi sp, sp, 16
    stw r8, (sp)
	stw et, 4(sp)
	
	rdctl et, estatus
	stw et, 8(sp)
	stw ea, 12(sp)

IRQ:
	rdctl et, ipending
	andi et, et, 0b0001
	bne r0, et, T1_IRQ
	
	rdctl et, ipending
	andi et, et, 0b0100
	bne r0, et, T2_IRQ
	
	br done
	
T1_IRQ:
	movia et, TIMER1
	stwio r0, (et)
	
	movia r8, LEGO
	ldwio et, (r8)
	andi et, et, 0b1000
	
	beq r0, et, reverse

forward:
	movia et, 0xFFFFFFF3
	stwio et, (r8)
	br done

reverse:
	movia et, 0xFFFFFFFB
	stwio et, (r8)
	br done

T2_IRQ:
	movui et, 0x1
	wrctl ctl3, et
	wrctl status, et
	
	movia r8, LEGO
	
	ldwio et, (r8)
	andi et, et, 0b0100
	
	beq r0, et, off
	
on: ldwio et, (r8)
	andi et, et, 0xFFFB
	stwio et, (r8)
	
	movia r8, TIMER2
	
	stwio r0, (r8)
	movui et, %lo(PWM_ON)
	stwio et, 8(r8)
	
	movui et, %hi(PWM_ON)
	stwio et, 12(r8)
	
	
	movui et, 0b0101
	stwio et, 4(r8)
	
	br done

off: 
	ldwio et, (r8)
	ori et, et, 0b0100 
	stwio et, (r8)
	
	movia r8, TIMER2
	
	stwio r0, (r8)
	
	movui et, %lo(PWM_OFF)
	stwio et, 8(r8)
	
	movui et, %hi(PWM_OFF)
	stwio et, 12(r8)
	
	movui et, 0b0101
	stwio et, 4(r8)

done:
	wrctl status, r0
	movui et, 0b0101
	wrctl ctl3, et
	ldw ea, 12(sp)
	ldw et, 8(sp)
	wrctl estatus, et
	ldw et, 4(sp)
	ldw r8, (sp)
	
	addi sp, sp, 16
	subi ea, ea, 4

	eret
	
#=== DATA ===#
.section .data

#=== TEXT/INSTRUCTIONS ===#
.section .text
.global _start
_start:

initialize_stack:
    movia sp, STACK

enable_interrupts:
    addi r8, r0, 1
#enable all interrupts
    wrctl ctl0, r8
#enable IRQ line 0 (Timer1)
    movui r8, 0b0101
	wrctl ctl3, r8

initialize_motor1:
    movia r8, LEGO
#parallel port boi
    movia r9, 0x07F557FF
    stw r9, 4(r8)
#turn motor1 on (motor0 left off)
    movia r9, 0xFFFFFFF3
	stw r9, (r8)
	
initialize_timer1:
    movia r8, TIMER1

#load low 16 bits
    movui r9, %lo(press_time)
    stwio r9, 8(r8)
#load top 16 bits
    movui r9, %hi(press_time)
    stwio r9, 12(r8)
	
	stwio r0, (r8)
#enable interrupts, turn on timer, run once until timeout bit
    movui r9, 0b111
    stwio r9, 4(r8)

initialize_timer2:
    movia r8, TIMER2

#load low 16 bits
    movui r9, %lo(PWM_ON)
    stwio r9, 8(r8)
#load top 16 bits
    movui r9, %hi(PWM_OFF)
    stwio r9, 12(r8)
	
	stwio r0, (r8)
#enable interrupts, turn on timer, run once until timeout bit
    movui r9, 0b101
    stwio r9, 4(r8)	

loop:
    br loop
