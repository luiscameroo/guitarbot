.equ ADDR_VGA, 0x08000000
.equ WIDTH, 320
.equ HEIGHT, 240
.equ BYTES_PER_ROW, 10 #log2(1024)
.equ BYTES_PER_PIXEL, 1 #log2(2)

.section .text
.global drawscreen 

drawscreen:
	subi sp, sp, 24
    stw r16, 0(sp)		# Save some registers
    stw r17, 4(sp)
    stw r18, 8(sp)
	stw r19, 12(sp)
	stw r20, 16(sp)
    stw ra, 20(sp)
    
	movia r20, WIDTH
	movia r19, HEIGHT
    subi r18, r4, 2
    # Two loops to draw each pixel
    movi r16, HEIGHT
    1:	movi r17, WIDTH
        2:  addi r18, r18, 2
			sub r4, r19, r16
            sub r5, r20, r17
            ldh r6, (r18)
            call DrawPixel		# Draw one pixel
            subi r17, r17, 1
            bne r17, r0, 2b
        subi r16, r16, 1
        bne r16, r0, 1b
    
    ldw ra, 20(sp)
	ldw r20, 16(sp)
	ldw r19, 12(sp)
	ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)    
    addi sp, sp, 24
	ret

DrawPixel:
	movi r2, BYTES_PER_ROW		# log2(bytes per row)
    movi r3, BYTES_PER_PIXEL	# log2(bytes per pixel)
    
    sll r5, r5, r3
    sll r4, r4, r2
    add r5, r5, r4
    movia r4, ADDR_VGA
    add r5, r5, r4
    
	sthio r6, 0(r5)		# Write 16-bit pixel
	ret