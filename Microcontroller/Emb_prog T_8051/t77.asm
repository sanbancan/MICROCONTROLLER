;t7.asm
;Generating timer interrupt
;blinking LED
;----------------------------------------------------------------------
	CHIP 8052
	.list on
;----------------------------------------------------------------------
;Define byte variables...
ds1:		EQU	30h	;location for displaying value on display1
ds2:		EQU	31h	;location for displaying value on display2
ds3:		EQU	32h	;location for displaying value on display3
ds4:		EQU	33h	;location for displaying value on display4
;
dcount_1:	EQU	34h	;variable for generating delay
dcount_2:	EQU	35h	;variable for generating delay
dcount_3:	EQU	36h	;variable for generating delay
;
count:		EQU	37h	;
;----------------------------------------------------------------------
;define bit variables here

sl1:	REG	P2.0		;display1
sl2:	REG	P2.1		;display2
sl3:	REG	P2.2		;display3
sl4:	REG	P2.3		;display4

;----------------------------------------------------------------------
	org 	0000h
	jmp	main
;----------------------------------------------------------------------
	org     0003h
	reti			;ljmp	isr_i0
;
	org     000bh
	ljmp	isr_t0		;timer0 interrupt
;
	org     0013h
	reti			;ljmp    isr_i1
;
	org     001bh
	reti			;ljmp	isr_t1
				;timer1 interrupt
				;(isr_t1)baud rate for Usart
				;(...hence no Interrupt)

	org     0023h
        reti			;ljmp    isr_receive
				;Interrupt enabled only for receive.
;
	org     002bh
        reti			;ljmp    isr_t2
;----------------------------------------------------------------------
main:
	clr	sl1		;selecting display1
	setb	sl2
	setb	sl3
	setb	sl4
;
	mov	p0,#00h		;clear display
	mov	count,#20d
	call	init_timer0
	setb	ea		;enable all interupts
	jmp	$	
;----------------------------------------------------------------------
;initialising routines done here...
;----------------------------------------------------------------------
	;(89h)
	;TMOD-->GATE, C/T, M1,	M0, GATE, C/T, M1, M0, T/C (timer1,timer0)
	;init timer 0  for 1msec
init_timer0:
	orl	tmod,#01h		;t0 in 16 bit timer mode.
	mov	tl0,#00h		;Init timer0 with count for 65msec.
	mov	th0,#00h		;count=0000h for 65msec.
	setb	tr0			;start timer 0.
        setb	et0			;enable timer 0 Interrupt.
	ret 
;---------------------------------------------------------------------
isr_t0:
	call	init_timer0
	djnz	count,out_isr
	mov	count,#20d
	
	cpl	p0.0			;dp segment 
out_isr:
	reti
;----------------------------------------------------------------------
end