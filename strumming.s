.equ LEGO, 0xFF200060
.equ TIMER, 0xFF202000
.equ STACK, 0x7FFFFFFF
.equ HALF,  0x003D0900
.section .text

.global _start

_start:
	#Initialize Motors 
	movia r8, (LEGO)
	movia r9, 0x07F557FF
	stwio r9, 4(r8)
	
	movi r9, 0b0011 #TURN MOTOR OFF
	stwio r9, (r8)
	
	#Initialize Timer
	movia r8, TIMER
	
	#Enable Interrupts
	movi r9, 0b001
	wrctl ctl0, r9
	wrctl ctl3, r9
	
	movia r9, %lo(HALF)
	andi r9, r9, 0xFFFF
	stwio r9, 8(r8)
	
	movia r9, %hi(HALF)
	andi r9, r9, 0xFFFF
	stwio r9, 12(r8)
	
	movi r9, 0b111
	stwio r9, 4(r8)
	
loop:
	br loop
	
.section .exceptions, "ax"

ISR:
	movia r8, (LEGO)
	ldwio et, (r8)
	andi et, et, 0b010
	beq et, r0, setreverse

setforward:
	ldwio et, (r8)
	andi et, et, 0b1101
	br done
	
setreverse:
	
done:
	subi ea, ea, 4
	eret

	
