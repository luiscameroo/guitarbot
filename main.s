#Final product!

#=== EQU'S ===#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x00002000
.equ PS201, 0xFF200100

#------ MOTOR TIMING ------#
.equ X_MOVE,  2000000
.equ Y_MOVE,  2000000
.equ X_PWM,  2000000
.equ Y_PWM,  2000000
.equ PWM_ON, 50000000
.equ PWM_OFF, 50000000

#=== VGA EQU'S ===#
.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000
.equ WIDTH, 320
.equ HEIGHT, 240
.equ BYTES_PER_ROW, 10 #log2(1024)
.equ BYTES_PER_PIXEL, 1 #log2(2)

#=== KEYBOARD EQU'S ===#
.equ BREAK, 0x0f0
.equ MAKEA, 0x01c
.equ MAKEF, 0x02b
.equ MAKEG, 0x034
.equ MAKEP, 0x04d

#=== DATA ===#
.section .data
.align 1

goat: .incbin "image/paul_de_raw.raw"
default: .incbin "image/default.raw"
chordA: .incbin "image/chordA.raw"
chordF: .incbin "image/chordF.raw"
chordG: .incbin "image/chordG.raw"

.align 2

byte1: .long 0x0
byte2: .long 0x0
byte3: .long 0x0

pwm_x_counter: .word 0x000000 #Ratio of Duty Cycle, if 0 then always on,
pwm_y_counter: .word 0x000000 #if 1 then half the time, if 2 then third of the time

PWM_FLAG: .word 0x0 # reserve area in memory for checking whether power is on or off.

#=== INTERRUPT SERVICE ROUTINE ===#
.section .exceptions, "ax"
ISR:
    subi sp, sp, 24
    stw r8, 20(sp)
    stw r9, 16(sp)
    stw r10, 12(sp)
    stw r11, 8(sp)
    stw r12, 4(sp)
    stw ra, (sp)

timer1_int:
    call timer1_subroutine

timer2_int:
    call timer2_subroutine

keyboard_int:
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
    beq r8, r8, draw_P
    br keyboard_done

draw_A:
    movia r4, chordA
    call drawscreen
    br keyboard_done

draw_F:
    movia r4, chordF
    call drawscreen
    br keyboard_done

draw_G:
    movia r4, chordG
    call drawscreen
    br keyboard_done

draw_P:
    movia r4, goat
    call drwscreen

keyboard_done:

ISR_done:

    subi ea ea, 4
    eret

#=== PROGRAM INSTRUCTIONS ===#
.section .text

.global _start
_start:
	movia r4, goat
	drawscreen
loop: br loop

#=== initializations ===#



#=== subroutines ===#

# READ KEYBOARD SUBROUTINE #
#will return byte value in r2
#might return a boolean in r3? (indicating whether read was valid but should be unnecessary in interrupts).
read_keyboard:
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
br timer2_done

low_done:
    addi et, et, 0x01 #set PWM_FLAG to 1 (indicating it will be on after serviced).
    stw et, (r8)
    movia r8, LEGO
    ldwio et, (r8)
    andi et, et, 0xFFEA # (1111 1111 1110 1010), this example turns on motors 2 to 0.
    stwio et, (r8)
timer2_done:
    ret

# TIMER1 STRUM SUBROUTINE #
#warning: same as timer2
timer1_subroutine:
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

timer1_done:
    ret

# VGA SUBROUTINE #

