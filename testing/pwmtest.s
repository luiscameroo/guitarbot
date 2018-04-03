#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x00002000

#------ MOTOR TIMING ------#
#100MHz; currently duty cycle of 0.5
.equ PWM_ON, 	25000
.equ PWM_OFF,	75000

#----- DATA -----#

.section .data
.PWM_FLAG: .word 0x0


####################################
#============ INTERRUPT ===========#

.section .exceptions, "ax"
ISR:
	subi sp, sp, 4
	stw r8, (sp)
	movia r8, LEGO
	
	ldwio et, (r8)
	andi et, et, 0b0001
	beq r0, et, off
on: movia et, 0xFFFFFFFE
	stwio et, (r8)
	
	movia r8, TIMER2
	
	movui et, %lo(PWM_ON)
	stwio et, 8(r8)
	
	movui et, %hi(PWM_ON)
	stwio et, 12(r8)
	
	stwio r0, (r8)
	
	movui et, 0b0101
	stwio et, 4(r8)
	
	br done

off: movia et, 0xFFFFFFFF
	stwio et, (r8)
	
	movia r8, TIMER2
	
	movui et, %lo(PWM_OFF)
	stwio et, 8(r8)
	
	movui et, %hi(PWM_OFF)
	stwio et, 12(r8)
	
	stwio r0, (r8)
	
	movui et, 0b0101
	stwio et, 4(r8)
	

done: ldw r8, (sp)
	addi sp, sp, 4
	subi ea, ea, 4
	eret


#========== INSTRUCTIONS ==========#

.section .text

.global _start
_start:

initialize_stack:
	movia sp, STACK

initialize_strum_motor:
	movia r8, LEGO
	
	movia r9, 0x07F557FF
	stwio r9, 4(r8)
	
	moviA r9, 0xFFFFFFFE
	stwio r9, (r8)
		
initialize_timer2:
	movia r8, TIMER2

enable_interrupts:
	movui r9, 0b0100
	wrctl ctl3, r9
	
	movui r9, 0b0001
	wrctl ctl0, r9
	
load_timer2:
	movui r9, %lo(PWM_ON)
	stwio r9, 8(r8)
	
	movui r9, %hi(PWM_ON)
	stwio r9, 12(r8)
	
	stwio r0, (r8) 
	
	movui r9, 0b0101
	stwio r9, 4(r8)

loop: br loop


