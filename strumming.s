#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------# 
.equ X_MOVE,  2000000
.equ Y_MOVE,  2000000
.equ X_PWM,  2000000
.equ Y_PWM,  2000000

####################################
#============ INTERRUPT ===========#

.section .exceptions, "ax"
ISR:
#Clear timeout bit
	movia r8, TIMER1
	stwio r0, (r8)
	
	movia r8, LEGO
	ldwio et, (r8)
	andi et, et, 0b010
	beq et, r0, setreverse

setforward:
	ldwio et, (r8)
	andi et, et, 0xFFFD
	stwio et, (r8)
	br done
	
setreverse:
	ldwio et, (r8)
	ori et, et, 0x0002
	stwio et, (r8)
	
done:
	subi ea, ea, 4
	eret

#======== END OF INTERRUPT ========#
####################################
#=========== VARIABLES ============#

.section .data
pwm_x_counter	.word 0x000000 #Ratio of Duty Cycle, if 0 then always on, 	
pwm_y_counter   .word 0x000000 #if 1 then half the time, if 2 then third of the time 

#= END OF VARIABLE INITIALIZATION =#
####################################
#========== INSTRUCTIONS ==========#

.section .text

.global _start
_start:
#============ INITIALIZATIONS ============#
	#---- Stack ----#
	movia sp, STACK
	#---- Interrupts ----#
	movi r9, 0b001
	wrctl ctl0, r9
	wrctl ctl3, r9
	#---- Motors ----# 
	movia r8, LEGO
	movia r9, 0x07F557FF #Parrallel Port - Setting Input Output Ports
	stwio r9, 4(r8) 

	movi r9, 0b0101 #Turn both motors off
	stwio r9, (r8)
	#---- Timers ----#
	movia r8, TIMER1
	
	movia r9, %lo(X_MOVE)
	andi r9, r9, 0xFFFF
	stwio r9, 8(r8)
	
	movia r9, %hi(X_MOVE)
	andi r9, r9, 0xFFFF
	stwio r9, 12(r8)
	
	movui r9, 0b111
	stwio r9, 4(r8)
	
loop:
	br loop
	
#========== END OF INSTRUCTIONS ===========#
############################################
#============ QUICK REFERENCES ============#
# DEVICES: http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/
