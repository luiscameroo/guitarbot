#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x00002000

#------ MOTOR TIMING ------#
#100MHz; currently duty cycle of 0.5
.equ PWM_ON, 	30000
.equ PWM_OFF,	70000
.equ HALF_SEC,  100000000

#----- DATA -----#

.section .data
.PWM_FLAG: .word 0x0


####################################
#============ INTERRUPT ===========#

.section .exceptions, "ax"
ISR:
	subi sp, sp, 16 
	stw r8, 0(sp)
	stw et, 4(sp)
	
	rdctl et, estatus
	stw et, 8(sp)
	stw ea, 12(sp)
	
IRQ: 
	#Check for higher priority interrupt first#
	#rdctl et, ipending
	#andi et, et, 0b0001
	#bne r0, et, T1_IRQ	
	
	rdctl et, ipending
	andi et, et, 0b0100
	bne r0, et, T2_IRQ
	
	#br done

T1_IRQ:
	movia et, TIMER1
	stwio r0, (et)
	
	movia r8, LEGO
	ldwio et, (r8)
	andi et, et, 0b0010
	
	beq r0, et, reverse

forward:
	movia et, 0xFFFFFFFC
	stwio et, (r8)
	br done

reverse:
	movia et, 0xFFFFFFFE
	stwio et, (r8)		
	br done
	
T2_IRQ:
	movui et, 0x1
	wrctl ctl3, et
	wrctl status, et
	
	movia r8, LEGO
	
	ldwio et, (r8)
	andi et, et, 0b0001
	
	beq r0, et, off

on: ldwio et, (r8)
	andi et, et, 0xFFFE
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
	ori et, et, 0b0001 
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
		
initialize_timer1:
	movia r8, TIMER1

load_timer1:
	movui r9, %lo(HALF_SEC)
	stwio r9, 8(r8)
	
	movui r9, %hi(HALF_SEC)
	stwio r9, 12(r8)
	
	stwio r0, (r8) 
	
	movui r9, 0b0111
	stwio r9, 4(r8)
	
initialize_timer2:
	movia r8, TIMER2
	
load_timer2:
	movui r9, %lo(PWM_ON)
	stwio r9, 8(r8)
	
	movui r9, %hi(PWM_ON)
	stwio r9, 12(r8)
	
	stwio r0, (r8) 
	
	movui r9, 0b0101
	stwio r9, 4(r8)

enable_interrupts:
	movui r9, 0b0101
	wrctl ctl3, r9
	
	movui r9, 0b0001
	wrctl ctl0, r9

loop: br loop


