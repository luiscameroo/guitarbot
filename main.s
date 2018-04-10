#Final product!

#=== EQU'S ===#
.equ LEGO, 0xFF200060
.equ LEGO_CONFIG, 0x07F577FF
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x03FFFFFC
.equ PS201, 0xFF200100

#------ MOTOR TIMING ------#
.equ PWM_ON, 30000 #Duty Cycle of 0.3
.equ PWM_OFF, 70000
.equ strum_on, 50000000
#=== KEYBOARD EQU'S ===#
.equ BREAK, 0x0f0
.equ MAKEA, 0x01c
.equ MAKEF, 0x02b
.equ MAKEG, 0x034
.equ MAKEP, 0x04d

#=== DATA ===#
.section .data
.align 1

default: .incbin "image/default.raw"
chordA: .incbin "image/chordA.raw"
chordF: .incbin "image/chordF.raw"
chordG: .incbin "image/chordG.raw"

.align 2

byte1: .long 0x0
byte2: .long 0x0
byte3: .long 0x0

current_fret: .long 0x01
next_fret: .long 0x01
direction: .long 0x01
going_up: .long 0x02

#strum_on: .long 50000000
strum_off: .long 50000000

PWM_FLAG: .word 0x0 # reserve area in memory for checking whether power is on or off.

#=== INTERRUPT SERVICE ROUTINE ===#
.section .exceptions, "ax"
ISR:
    subi sp, sp, 40
    stw r6, (sp)
    stw r8, 4(sp)
    stw r9, 8(sp)
    stw r10, 12(sp)
    stw r11, 16(sp)
    stw r12, 20(sp)
	stw et, 24(sp)
    stw ra, 28(sp)
	rdctl et, estatus
	stw et, 32(sp)
	stw ea, 36(sp)
	

    rdctl r16, ipending
    andi r17, r16, 0x0001
    bne r17, r0, timer1_int
	
	andi r17, r16, 0x0080
    bne r17, r0, keyboard_int
	
	andi r17, r16, 0x0800
	bne r17, r0, sensor_int
	
    andi r17, r16, 0x0004
    bne r17, r0, timer2_int

	br ISR_done

timer1_int:
    call timer1_subroutine
    br ISR_done

keyboard_int:
	movui r9, 0x01
	wrctl ctl3, r9
	wrctl ctl0, r9
	
    call read_keyboard
    movia et, byte3
    ldw r8, (et)
    movia r9, MAKEA
    beq r8, r9, draw_A
    movia r9, MAKEF
    beq r8, r9, draw_F
    movia r9, MAKEG
    beq r8, r9, draw_G
    movia r9, MAKEP
    beq r8, r9, draw_P

    br keyboard_done

draw_A:
    movia r4, chordA
    call drawscreen
    movia r8, next_fret
    movi r9, 3
    stw r9, (r8)

	#Move chord press up
	movia r8, LEGO
	movia r9, 0xFFFFFFFB
	stwio r9, (r8)
    br keyboard_done #which_direction

draw_F:
    movia r4, chordF
    call drawscreen
    movia r8, next_fret
    movi r9, 1
    stw r9, (r8)
	
	#Move chord press up
	movia r8, LEGO
	movia r9, 0xFFFFFFFB
	stwio r9, (r8)
    br keyboard_done #which_direction

draw_G:
    movia r4, chordG
    call drawscreen
    movia r8, next_fret
    movi r9, 2
    stw r9, (r8)
	
	#Move chord press up
	movia r8, LEGO
	movia r9, 0xFFFFFFFB
	stwio r9, (r8)
    br keyboard_done #which_direction

draw_P:
    movia r4, default
    call drawscreen
	br keyboard_done

sensor_int: 
	call SENSOR_IRQ
	br ISR_done
	
timer2_int:
    call timer2_subroutine
    br ISR_done


keyboard_done:

ISR_done:
	wrctl ctl0, r0
	movui r9, 0b100010000101
	wrctl ctl3, r9

	ldw ea, 36(sp)
	ldw et, 32(sp)
	wrctl status, et
	ldw ra, 28(sp)
	ldw et, 24(sp)
	ldw r12, 20(sp)
	ldw r11, 16(sp)
	ldw r10, 12(sp)
	ldw r9, 8(sp)
	ldw r8, 4(sp)
	ldw r6, 0(sp)
	
    addi sp, sp, 40

    subi ea, ea, 4
    eret

#=== PROGRAM INSTRUCTIONS ===#
.section .text

.global _start
_start:
#=== initializations ===#
	movia sp, STACK

#timer config below
initialize_timer1:
    movia r8, TIMER1
#load car_move_time into timer (2 seconds)
#load low 16 bits
    movui r9, %lo(strum_on)
    stwio r9, 8(r8)
#load top 16 bits
    movui r9, %hi(strum_on)
    stwio r9, 12(r8)
#enable interrupts, turn on timer, run once until timeout bit
    movui r9, 0b111
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

#intialize LEGO
	movia r8, LEGO

#initialize SENSORS
    movia r9, 0x07F557FF
    stwio r9, 4(r8)
	
	movia r9, 0xFFFFFFFF
	stwio r9, 12(r8)
	
#threshold value of sensor
	movia r9, 0xFFBFEFFF #sensor1
	stwio r9, (r8)
	
	movia r9, 0xFFDFFFFF
	stwio r9, (r8)
	
	movia r9, 0xFFBFBFFF #sensor2
	stwio r9, (r8)
	
	movia r9, 0xFFDFFFFF
	stwio r9, (r8)
	
	movia r9, 0xF8000000
	stwio r9, 8(r8)
	
initialize_motor0:
#turn motor0 on (motor1 left off)
    movia r9, 0xFFDFFFFC
	stwio r9, (r8)
	

#ps2 config below
    movui r8, 0x0885 
	wrctl ctl3, r8
	movui r8, 0b01
	wrctl ctl0, r8
	
	movia r9, PS201
	stwio r8, 4(r9)
	
	movia r4, default
	call drawscreen
#=== end main ===#
loop: br loop

#=== subroutines ===#

# READ KEYBOARD SUBROUTINE #
#will return byte value in r2
#might return a boolean in r3? (indicating whether read was valid but should be unnecessary in interrupts).
read_keyboard:

#enable interrupts for timer 1.
    addi r8, r8, 1
    wrctl ctl3, r8
    wrctl ctl0, r8

    movia r8, PS201
    ldwio r9, (r8)
    andi r10, r9, 0x08000
    beq r0, r10, read_invalid
    andi r10, r9, 0x0FF
#shift bytes read from keyboard

#byte1 = byte2;
    movia r9, byte1
    movia r11, byte2
    ldw r12, (r11)
    stw r12, (r9)
#byte2 = byte3;
    movia r9, byte3
    ldw r12, (r9)
    stw r12, (r11)
#byte3 = data_read;
    stw r10, (r9)
    br done_read_keyboard
read_invalid:
    mov r2, r0
done_read_keyboard:
    ret

# TIMER2 PWM SUBROUTINE #
#warning: copied from strumming.s ISR section, may need to format as correct subroutine
timer2_subroutine:
	movui r9, 0x881
	wrctl ctl3, r9
	
	movui r9, 0x01
	wrctl ctl0, r9
	
    movia r8, LEGO

    ldwio et, (r8)
    andi et, et, 0b01

    beq r0, et, off

on:
    ldwio et, (r8)
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

    br timer2_done

off:
    ldwio et, (r8)
    ori et, et, 0x0001
    stwio et, (r8)

    movia r8, TIMER2

    stwio r0, (r8)
    movui et, %lo(PWM_OFF)
    stwio et, 8(r8)

    movui et, %hi(PWM_OFF)
    stwio et, 12(r8)

    movui et, 0b0101
    stwio et, 4(r8)

timer2_done:
    ret

# TIMER1 STRUM SUBROUTINE #
#warning: same as timer2
timer1_subroutine:
#Clear timeout bit
    movia r8, TIMER1
    stwio r0, (r8)

#addi et, et, 0x1 #enable interrupts (nested)
#wrctl ctl0, et

    movia r8, LEGO
    ldwio et, (r8)
    andi et, et, 0b010
    beq et, r0, setreverse

setforward:
    ldwio et, (r8)
    andi et, et, 0xFFFD
    stwio et, (r8)
    br timer1_done

setreverse:
    ldwio et, (r8)
    ori et, et, 0x0002
    stwio et, (r8)

timer1_done:
    ret

# VGA SUBROUTINE #

# LIGHT SENSOR SUBROUTINE #
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

# TOUCH SENSOR SUBROUTINE #
SENSOR_IRQ:
	movui et, 0x801
	wrctl ctl3, et
	
	movui et, 0x01
	wrctl ctl0, et
	
	movia r8, LEGO
	ldwio et, (r8)
	
	#Check which sensor caused interrupt
	movia r9, 0x10000000
	and r9, r9, et
	bne r0, r9, SENSOR_DOWN

	movia r9, 0x20000000
	and r9, r9, et
	bne r0, r9, SENSOR_UP
	
	br SENSOR_DONE
	
SENSOR_DOWN:
	#Set correct value of going_up
	movia r8, going_up
	ldw r9, (r8)
	bne r0, r9, SENSOR_DONE
	
	movui r9, 0x01
	stw r9, (r8)

	#Turn off motor 
	movia r8, LEGO
	movui r9, 0x04
	ldwio et, (r8)
	and et, r9, et
	stwio et, (r8)
	
	br SENSOR_DONE
	
SENSOR_UP:
	#Set correct value of going_up
	movia r8, going_up
	ldw r9, (r8)
	beq r0, r9, SENSOR_DONE
	
	stw r0, (r8)
	
	#Turn off motor
	movia r8, LEGO
	movui r9, 0x04
	ldwio et, (r8)
	and et, r9, et
	stwio et, (r8)
	
SENSOR_DONE: ret	
