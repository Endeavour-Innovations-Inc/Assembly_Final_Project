.text
.global main

.equ LED_DATA, 0x41210000
.equ PWM1_blueEn, 0x43C00000
.equ PWM1_greenEn, 0x43C00010
.equ PWM1_redEn, 0x43C00020

.equ SVN_SEG_CTRL, 0x43C10000
.equ SVN_SEG_DATA, 0x43C10004

.equ UART1_CR, 0xE0001000 // uart1 control register
.equ UART1_MR, 0xE0001004 // uart1 mode register
.equ UART1_BAUDGEN, 0xE0001018
.equ UART1_BAUDDIV, 0xE0001034
.equ UART1_SR, 0xE000102C
.equ UART1_FIFO, 0xE0001030

// works!!!

main:
    ldr r6,=SVN_SEG_CTRL
    ldr r7,=SVN_SEG_DATA
	bl configure_uart1
	bl ssdEn
	loop:
		bl getChar // receive data
		bl data2rgb // send data to rgb and ssd
	b loop

ssdEn:
    mov r0,#1
    str r0,[r6]
    bx lr

data2rgb:
	ldr r1,=LED_DATA
	ldr r2,[r1] // loads led values
	cmp r0,#'r'
    beq PWM1_red
	eoreq r2,#0b0001 // toggles light
	cmp r0,#'g'
    beq PWM1_green
	eoreq r2,#0b0010
	cmp r0,#'b'
    beq PWM1_blue
	eoreq r2,#0b0100
	str r2,[r1]
    bx lr

configure_uart1:
	push {lr}
	bl uart1_rst
	ldr r1, =UART1_MR
	mov r0, #0x20
	str r0,[r1]
	ldr r1, =UART1_CR
	mov r0,#4
	orr r0,r0,#16
	str r0,[r1]
	ldr r1, =UART1_BAUDGEN
	mov r0, #0x7C
	str r0,[r1]
	ldr r1, =UART1_BAUDDIV
	mov r0, #6
	str r0,[r1]
	pop {lr}
	bx lr

getChar:
	ldr r1,=UART1_SR
	ldr r2,[r1] // current value of SR to r2
	and r2,#0b10 // masking
	cmp r2,#0b10 // empty check
	beq getChar // go again if fifo is empty
	ldr r1,=UART1_FIFO
	ldr r0,[r1] // get character from fifo
	bx lr

uart1_rst:
	ldr r1,=UART1_CR
	mov r0, #3	// resets uart
	str r0,[r1] // stores it back
	rst_loop:
		ldr r0,[r1]
		ands r0,#3
		bne rst_loop
	bx lr

// RBG Control module
PWM1_red:
	eoreq r2,#1
	str r2,[r1]
	add r1,#0x04 // needs, otherwise cannot be turned off
	ldr r1,=PWM1_redEn
	ldr r3,=SVN_SEG_DATA
	eoreq r4, #0b0001001 // displays R
	str r4,[r3]
	str r2,[r1] // otherwise does not light up
	add r1,#0x04 // needed
	add r1,#0x04
    str r0,[r1]
	b main

PWM1_green:
	eoreq r2,#1
	str r2,[r1]
	add r1,#0x04 // needs, otherwise cannot be turned off
	ldr r1,=PWM1_greenEn
	ldr r3,=SVN_SEG_DATA
	eoreq r4, #0b0000101 // displays g
	str r4,[r3]
	str r2,[r1] // otherwise does not light up
	add r1,#0x04 // needed
	add r1,#0x04
    str r0,[r1]
	b main

PWM1_blue:
	eoreq r2,#1
	str r2,[r1]
	add r1,#0x04 // needs, otherwise cannot be turned off
	ldr r1,=PWM1_blueEn
	ldr r3,=SVN_SEG_DATA
	eoreq r4, #0b0001000 // displays b
	str r4,[r3]
	str r2,[r1] // otherwise does not light up
	add r1,#0x04 // needed
	add r1,#0x04
    str r0,[r1]
	b main

.end
