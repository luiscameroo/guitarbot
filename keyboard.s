#code will recognize key presses using interrupts, acknowledge
#which key was pressed and have the bot play the corresponding chord on guitar

#=== EQU'S ===#
.equ LEGO, 0xFF200060
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x00002000
.equ PS201, 0xFF200100

#=== DATA ===#
.section .data

.align 2

byte1: .long 0x0
byte2: .long 0x0
byte3: .long 0x0


#=== INTERRUPT SERVICE ROUTINE ===#
.section .exceptions, "ax"
ISR:
#save registers
    subi sp, sp, 24
    stw r8, 20(sp)
    stw r9, 16(sp)
    stw r10, 12(sp)
    stw r11, 8(sp)
    stw r12, 4(sp)
    stw ra, (sp)

    call read_keyboard

#reload registers
    ldw r8, 20(sp)
    ldw r9, 16(sp)
    ldw r10, 12(sp)
    ldw r11, 8(sp)
    ldw r12, 4(sp)
    ldw ra, (sp)
    addi sp, sp, 24
    subi ea, ea, 4
    eret



#=== PROGRAM INSTRUCTIONS ===#
.section .text

.global _start
_start:
#initialize stack
    movia sp, STACK

#enable interrupts (add keyboard to IRQ line)
    addi r9, r9, 0b010000000
    wrctl ctl3, r9

    movi r9, 0b01
    wrctl ctl0, r9

#initialize keyboard interrupts (write 1 to 1st bit of control register)
    movia r8, PS201
    stwio r9, 4(r8)

done:
    br done

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



