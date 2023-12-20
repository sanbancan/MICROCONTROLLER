;t3.asm
;Driver for 7seg display using display look up table.
;----------------------------------------------------------------------
	CHIP 8052
	.list on
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
;define bit variables here

sl1:	REG	P2.0		;display1
sl2:	REG	P2.1		;display2
sl3:	REG	P2.2		;display3
sl4:	REG	P2.3		;display4

;----------------------------------------------------------------------
	ORG 	0000h
	mov	p0,#00h
main:	mov	ds1,#01h		;value for display 1
	mov	ds2,#02h	 	;value for display 2
	mov	ds3,#03h	 	;value for display 3
	mov	ds4,#04h		;value for display 4

	call	display

	jmp	main
;----------------------------------------------------------------------
display:
disp1:	clr	sl1		;select display1
	setb	sl2		;deselect display2
	setb	sl3		;deselect display3
	setb	sl4		;deselect display4
	mov	dptr,#disp_lut
	mov	a,ds1
	movc	a,@a+dptr
	mov	p0,a
	
	call	delay
;------------------------------------------------------------

disp2:	setb	sl1		;deselect display1
	clr	sl2		;select display2
	setb	sl3 		;deselect display3
	setb	sl4		;deselect display4
	mov	dptr,#disp_lut
	mov	a,ds2
	movc	a,@a+dptr
	mov	p0,a
	
	call	delay
;------------------------------------------------------------

disp3:	setb	sl1		;deselect display1
	setb	sl2		;deselect display2
	clr	sl3		;select display3
	setb	sl4		;deselect display4
	mov	dptr,#disp_lut
	mov	a,ds3
	movc	a,@a+dptr
	mov	p0,a
		
	call	delay
;------------------------------------------------------------

disp4:	setb	sl1		;deselect display1
	setb	sl2		;deselect display2
	setb	sl3		;deselect display3
	clr	sl4		;select display4
	mov	dptr,#disp_lut
	mov	a,ds4
	movc	a,@a+dptr
	mov	p0,a
		
	call	delay
	
	ret
 ;----------------------------------------------------------------------
 
delay:
	mov	dcount_3,#07d
l2:	mov	dcount_2,#0ffh
l1:	mov	dcount_1,#0ffh
	djnz	dcount_1,$
	djnz	dcount_2,l1
	djnz	dcount_3,l2
	ret
;----------------------------------------------------------------------

disp_lut:
;		-abcdefgd-		
	db	 11111100b	;0
	db	 01100000b	;1
	db	 11011010b	;2
	db	 11110010b	;3
	db	 01100110b	;4
	db	 10110110b	;5
	db	 10111110b	;6
	db	 11100000b	;7
	db	 11111110b	;8
	db	 11100110b	;9

;----------------------------------------------------------------------
	end
;----------------------------------------------------------------------	