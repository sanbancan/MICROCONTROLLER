;t1.asm	
;Driver for LED.	                                     
;----------------------------------------------------------------------
	CHIP	8052		;chip family 8051 or 8052
	.list 	on		;generate list file

;----------------------------------------------------------------------
	org	0000h
	clr	sl1		;select display by clearing bit and
	clr	P2.1		;deselect display by seting bit
	clr	P2.2		
	clr	P2.3
;
	setb	P0.0		;dp seg
	setb	P0.1		;g seg
	setb	P0.2		;f seg
	setb	P0.3		;e seg
	setb	P0.4		;d seg
	setb	P0.5		;c seg
	setb	P0.6		;b seg
	setb	P0.7		;a seg
;
;	mov	P0,#11010111b	;giving value in binary
;	mov	P0,#0C7h	;giving value in hex
	jmp	$
;
;----------------------------------------------------------------------
	sl1:	REG	P2.0
;	end
	clr	P3.0
;----------------------------------------------------------------------
;T1 t1.asm