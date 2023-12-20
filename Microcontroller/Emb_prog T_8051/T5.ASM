;t5.asm
;counter with ascii values.
;0000 to 9999
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
main:
	mov 	ds1,#"0"		;data for ds1
	mov 	ds2,#"0"	 	;data for ds2
	mov 	ds3,#"0"	 	;data for ds3
	mov 	ds4,#"0"		;data for ds4
	mov	count,#28d

l10:	call 	display
	djnz 	count,l10

	mov 	count,#28d
	call 	inc_d
	jmp 	l10
;----------------------------------------------------------------------

;----------------------------------------------------------------------
;Subroutines here onwards...
;display
;adisp1,2,3,4
;delay
;inc_d
;------------------------------------------------------------
display:
	clr 	sl1	;select display1
	setb	sl2	;
	setb	sl3	;
	setb	sl4	;
;
	call	adisp1
;	
	call 	delay
;----------------------------------------
	setb 	sl1
	clr 	sl2	;select display2
	setb 	sl3 
	setb 	sl4
;
	call	adisp2
;	
	call 	delay
;----------------------------------------
	setb 	sl1
	setb 	sl2
	clr 	sl3	;select display3
	setb 	sl4
;
	call	adisp3
;		
	call 	delay
;----------------------------------------
	setb 	sl1
	setb 	sl2
	setb 	sl3
	clr 	sl4	;select display4
;
	call	adisp4
;		
	call 	delay
;
	ret

;----------------------------------------
adisp1:
	mov 	dptr,#adisp_lut
	mov 	a,ds1
	clr	c
	subb	a,#"0"
	movc 	a,@a+dptr
	mov 	p0,a
	ret

;----------------------------------------
adisp2:
	mov 	dptr,#adisp_lut
	mov 	a,ds2
	clr	c
	subb	a,#"0"
	movc 	a,@a+dptr
	mov 	p0,a
	ret

;----------------------------------------
adisp3:
	mov 	dptr,#adisp_lut
	mov 	a,ds3
	clr	c
	subb	a,#"0"
	movc 	a,@a+dptr
	mov 	p0,a
	ret

;----------------------------------------
adisp4:
	mov 	dptr,#adisp_lut
	mov 	a,ds4
	clr	c
	subb	a,#"0"
	movc 	a,@a+dptr
	mov 	p0,a
	ret
;------------------------------------------------------------

;------------------------------------------------------------
delay:
;	mov	dcount_3,#07d
l2:	mov 	dcount_2,#10h
l1:	mov 	dcount_1,#0ffh
	djnz 	dcount_1,$
	djnz 	dcount_2,l1
;	djnz 	dcount_3,l2
	ret
;------------------------------------------------------------

;------------------------------------------------------------

adisp_lut:
	db 	11111100b	;0
	db 	01100000b	;1
	db 	11011010b	;2
	db 	11110010b	;3
	db 	01100110b	;4
	db 	10110110b	;5
	db 	10111110b	;6
	db 	11100000b	;7
	db 	11111110b	;8
	db 	11110110b	;9
;
	db	11111111b	;3a
	db	11111111b	;3b
	db	11111111b	;3c
	db	11111111b	;3d
	db	11111111b	;3e
	db	11111111b	;3f
	db	11111111b	;40
;
	db 	11101110b	;a
	db 	00111110b	;b
	db 	10011100b	;c
	db 	01111010b	;d
	db 	10011110b	;e			
	db 	10001110b	;f

;------------------------------------------------------------


;------------------------------------------------------------
;Increments value of ds4 ds3 ds2 ds1 considering as a single
;four digit no from 0000 to 9999
inc_d:
	inc 	ds1
	mov 	a,ds1
	cjne 	a,#"9"+1,$+3
	jnc 	l1_id 
	ret

;----------------------------------------
l1_id:	mov 	ds1,#"0"
	inc 	ds2
	mov 	a,ds2
	cjne 	a,#"9"+1,$+3
	jnc 	l2_id
	ret

;----------------------------------------
l2_id:	mov 	ds2,#"0"
	inc 	ds3
	mov 	a,ds3
	cjne 	a,#"9"+1,$+3 
	jnc 	l3_id
	ret

;----------------------------------------
l3_id:	mov 	ds3,#"0"
	inc 	ds4 
	mov 	a,ds4
	cjne 	a,#"9"+1,$+3
	jnc	l4_id
	ret

;----------------------------------------

l4_id:	mov	ds1,#"0"
	mov	ds2,#"0"
	mov	ds3,#"0"
	mov	ds4,#"0"
	ret	

;------------------------------------------------------------


;----------------------------------------------------------------------
	end
	