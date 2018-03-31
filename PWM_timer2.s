#------ DEVICE LOCATIONS ------#
.equ LEGO, 0xFF200060 #Use Motor 1 of lego controller
.equ TIMER1, 0xFF202000
.equ TIMER2, 0xFF202020
.equ STACK, 0x7FFFFFFF

#------ MOTOR TIMING ------#
.equ PWM_T 0x00 #Currently uninitialized.

####################################
#=== PWM MODULE ===#

.section .text

#NOTES PWM_initialize
#assuming period of power_HIGH and power_LOW are equal.
#to decrease power, making length of power_HIGH < length of power_LOW.

.global PWM_initialize
PWM_initialize:
    movia r16, TIMER2
    movui r17, %lo(PWM_T)
    stwio r17, 8(r16)

    movui r17, %hi(PWM_t)
    stwio r17, 12(r16)

    movui r17, 0b111
    stwio r17, 4(r16)

    ret

#NOTES PWM_timer2
#May need to check if writing is valid first(polling as this will be called in exception handler.

.global PWM_timer2
PWM_timer2:
    movia r16, LEGO
    ldwio r17, (r16)
    andi r17, 0b01 # check on/off of first motor, all motors use the same duty cycle and on/off toggle is them.
    beq r0, r17, turn_off

turn_on:
    andi r17, r17, 0xFFEA # (1111 1111 1110 1010), this example turns on motors 2 to 0.
    stwio r17, (r16)
    br PWM_done

turn_off:
    ori r17, r17, 0x0015 #(0000 0000 0001 0101), this example turns off motors 2 to 0.
    stwio r17, (r16)

PWM_done:
    ret
