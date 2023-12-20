;t2.asm	
;Driver for 7seg display.	                                      
;----------------------------------------------------------------------
	CHIP	8052
	.list 	on		;generate list file

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;Define byte variables here...

ds1:		EQU	30h	;location for displaying value on display1
ds2:		EQU	31h	;location for displaying value on display2
ds3:		EQU	32h	;location for displaying value on display3
ds4:		EQU	33h	;location for displaying value on display4
;
dcount_1:	EQU	34h	;variable for generating delay
dcount_2:	EQU	35h	;variable for generating delay
dcount_3:	EQU	36h	;variable for generating delay
;----------------------------------------------------------------------
;Define bit variables here...

sl1:	REG	P2.0		;display1
sl2:	REG	P2.1		;display2
sl3:	REG	P2.2		;display3
sl4:	REG	P2.3		;display4

;----------------------------------------------------------------------
	org	0000h

;----------------------------------------------------------------------
;Write your main program here onwards...
loop:
;-----------------------------------------------------------
	clr	sl1		;select display1
	setb	sl2		;deselect display2
	setb	sl3		;deselect display3
	setb	sl4		;deselect display4
;
	
	mov	ds1,#01100000b	;pattern for 1
	mov	P0,ds1
	
	call	delay
;-----------------------------------------------------------
	setb	sl1		;deselect display1
	clr	sl2		;select display2
	setb	sl3		;deselect display3
	setb	sl4		;deselect display4
;
	mov	ds2,#11011010b	;pattern for 2
	mov	P0,ds2
	call	delay
;-----------------------------------------------------------
	setb	sl1		;deselect display1
	setb	sl2		;deselect display2
	clr	sl3		;select display3
	setb	sl4		;deselect display4
;
	mov	ds3,#11110010b	;pattern for 3
	mov	P0,ds3
	call	delay
;-----------------------------------------------------------
	setb	sl1		;deselect display1
	setb	sl2		;deselect display2
	setb	sl3		;deselect display3
	clr	sl4		;seselect display4
;
	mov	ds4,#01100110b	;pattern for 4
	mov	P0,ds4
	call	delay
;
	jmp	loop

;----------------------------------------------------------------------
	end

;----------------------------------------------------------------------
;Initialising subroutine code....

	ret

;----------------------------------------------------------------------
;Other subroutines..
delay:
	mov	dcount_3,#07h
l2:	mov	dcount_2,#0ffh
l1:	mov	dcount_1,#0ffh
	djnz	dcount_1,$
	djnz	dcount_2,l1
	djnz	dcount_3,l2
	ret

;----------------------------------------------------------------------


;----------------------------------------------------------------------
;T2 t2.asm