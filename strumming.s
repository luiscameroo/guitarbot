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
.equ PWM_ON, 50000000
.equ PWM_OFF, 50000000


####################################
#============ INTERRUPT ===========#

.section .exceptions, "ax"
ISR: #used: r8, et

save_nested:
	subi sp, sp, 16
	stwio r8, 0(sp) #save r8
	stwio et, 4(sp) #save et
	stwio ea, 8(sp) #save ea (requirement for nested)
	rdctl r8, ctl1 #save ctl1
	stwio r8, 12(sp)
	
	movia r8, TIMER1
	ldwio et, (r8)
	andi et, et, 0x01
	beq et, r0, timer2_int
	
timer1_int:
#Clear timeout bit
	movia r8, TIMER1
	stwio r0, (r8)
	
	addi et, et, 0x1 #enable interrupts (nested)
	wrctl ctl0, et
	
	
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
	br done
	
timer2_int:
	movia r8, TIMER2 #clear timeout bit
	stwio r0, (r8)
	movia r8, PWM_FLAG #check bit of PWM_FLAG
	beq r8, r0, low_done
	
high_done:
	stw r0, (r8) #set PWM_FLAG to 0 (indicating it is off after serviced).
	movia r8, LEGO
    ldwio et, (r8)
	ori et, et, 0x0015 #(0000 0000 0001 0101), this example turns off motors 2 to 0.
    stwio et, (r8)
	br done

low_done:
	addi et, et, 0x01 #set PWM_FLAG to 1 (indicating it will be on after serviced).
	stw et, (r8)
	movia r8, LEGO
    ldwio et, (r8)
	andi et, et, 0xFFEA # (1111 1111 1110 1010), this example turns on motors 2 to 0.
    stwio et, (r8)
	
done:
	ldwio r8, 0(sp) #save r8
	ldwio et, 4(sp) #save et
	ldwio ea, 8(sp) #save ea (requirement for nested)
	ldwio r8, 12(sp) #restore ctl1
	wrctl ctl1, r8
	addi sp, sp, 16
	
	subi ea, ea, 4
	eret

#======== END OF INTERRUPT ========#
####################################
#=========== VARIABLES ============#

.section .data
pwm_x_counter:	 .word 0x000000 #Ratio of Duty Cycle, if 0 then always on, 	
pwm_y_counter:   .word 0x000000 #if 1 then half the time, if 2 then third of the time 
PWM_FLAG: .word 0x0 # reserve area in memory for checking whether power is on or off.

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
	movi r9, 0b0101 #enable timer1 and timer2 interrupts.
	wrctl ctl3, r9
	#---- Motors ----# 
	movia r8, LEGO
	movia r9, 0x07F557FF #Parrallel Port - Setting Input Output Ports
	stwio r9, 4(r8) 

	movi r9, 0b0101 #Turn both motors off
	stwio r9, (r8)
	#---- Timers ----#
	#TIMER1
	movia r8, TIMER1
	
	movia r9, %lo(X_MOVE)
	andi r9, r9, 0xFFFF
	stwio r9, 8(r8)
	
	movia r9, %hi(X_MOVE)
	andi r9, r9, 0xFFFF
	stwio r9, 12(r8)
	
	movui r9, 0b111
	stwio r9, 4(r8)
	
	#TIMER2
	movia r8, TIMER2
	
	movia r9, %lo(PWM_OFF)
	andi r9, r9, 0xFFFF
	Stwio r9, 8(r8)
	
	movia r9, %hi(PWM_OFF)
	andi r9, r9, 0xFFFF
	stwio r9, 12(r8)
	
	movui r9, 0b101 #enable interrupt in timer2, start, not run continuously.
	stwio r9, 4(r8)
	
	
	
loop:
	br loop
	
#========== END OF INSTRUCTIONS ===========#
############################################
#============ QUICK REFERENCES ============#
# DEVICES: http://www-ug.eecg.utoronto.ca/desl/nios_devices_SoC/
