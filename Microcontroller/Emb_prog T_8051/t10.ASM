;t10.asm
;stopwatch
	CHIP 8052
	.list on
;---------------------------------------------------
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
scan_no:	EQU	38h	;scan number for counting interrupts and key identification
dcount:		EQU	39h	;debounce count
krcount:	EQU	40h	;key release count
key_code:	EQU	41h	;key code
cnt_1sl		EQU	42h	;1sec lower byte
cnt_1sh		EQU	43h	;1sec higher byte
;---------------------------------------------------
;define imidiate values..
top_of_stack:	EQU	60h
;---------------------------------------------------

;---------------------------------------------------
;define bit variables here...
sl1:		REG	P2.0		;display1/row1
sl2:		REG	P2.1		;display2/row2
sl3:		REG	P2.2		;display3/row3
sl4:		REG	P2.3		;display4/row4
;
krl1:		REG	p2.4		;key return line 1
krl2:		REG	p2.5		;key return line 2
krl3:		REG	p2.6		;key return line 3
krl4:		REG	p2.7		;key return line 4
;----------------------------------------------------
key_ready:	REG	00h		;this flag is set when key is detected (after debounce).
nkp:		REG	01h		;this flag is set when no key is pressed.
tb:		REG	02h		;temp bit location
;----------------------------------------------------
start_sw	REG	03h		;start stopwatch bit
s1_over		REG	04h		;1sec over bit
start_buzzer:	REG	05h		;buzzer bit
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
	reti
	;ljmp	isr_t1		;timer1 interrupt
				;(isr_t1)baud rate for Usart
				;(...hence no Interrupt)
;
	org     0023h
         reti
	;ljmp    isr_receive         ;Interrupt enabled only for receive.
;
	org     002bh
         reti
	;ljmp    isr_t2
;
;----------------------------------------------------------------------

;----------------------------------------------------------------------
;Specification for stopwatch...
;A --> START	;start the stopwatch from the current count.
;B --> STOP	;stops the stopwatch current count frozen.
;C --> RESET	;reset the stopwatch to 0000.
;----------------------------------------------------------------------
main:
	mov	sp,#top_of_stack
	call	init		;init timer,display,etc.
;
	setb	ea		;enable all interupts
;
	call	test_display
;
	call	disp_sw		;display stopwatch
loop:	call	get_key
	call	keyprocess
	jmp	loop
;**********************************************************


;---------------------------------------------------
;initialising routines done here...
;--------------------------------------------------------------------
init:
;--------------------------
	call	init_timer0
;--------------------------
	call	init_display
;--------------------------
	call	init_keypad
;--------------------------
	call	init_delay_1sec
;--------------------------
	ret
;--------------------------------------------------------------------

;---------------------------------------------------
init_display:
	mov	ds1,#"Z"+2	;glow all segments
	mov	ds2,#"Z"+2
	mov	ds3,#"Z"+2
	mov	ds4,#"Z"+2
	ret
;---------------------------------------------------
;---------------------------------------------------
init_keypad:
	setb	krl1
	setb	krl2
	setb	krl3
	setb	krl4
	mov	scan_no,#00d
	mov	dcount,#33d
	mov	krcount,#32d
	clr	key_ready
	clr	nkp
	clr	start_buzzer
	ret
;---------------------------------------------------
;---------------------------------------------------

	;(89h)
	;TMOD-->GATE, C/T, M1,	M0, GATE, C/T, M1, M0, T/C (timer1,timer0)
	;init timer 0  for 1msec
init_timer0:
	orl	tmod,#01h		;t0 in 16 bit timer mode.
	mov	tl0,#66h		;Init timer0 with count for 1msec.
	mov	th0,#0fch		;count=0fc66h for 1msec.
	setb	tr0			;start timer 0.
        setb	et0			;enable timer 0 Interrupt.
	ret 
;---------------------------------------------------
;---------------------------------------------------
init_delay_1sec:
	mov	cnt_1sl,#0e8h
	mov	cnt_1sh,#04h
	setb	s1_over
	ret
;---------------------------------------------------

;--------------------------------------------------------------------
isr_t0:
	push	a
	push	psw
	push	dph
	push	dpl

	call	init_timer0
;
	call	delay_1sec
;	
	call	buzzer

	call	scanner			;spoils a,psw,dptr
;
	jnb	s1_over,out_isr
	call	inc_d
	clr	s1_over
;
out_isr:
	pop	dpl
	pop	dph
	pop	psw
	pop	a
	reti

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;count for 1000ms (04e8h) is loaded in cnt_1sl (0e8h) and cnt_1sh (04h)
;s1_over flag initially set.
delay_1sec:
	jb	s1_over,out_ds1sec
	djnz	cnt_1sl,out_ds1sec
	djnz	cnt_1sh,reinit_1sl
;count over..
	mov	cnt_1sh,#04h
	mov	cnt_1sl,#0e8h
	setb	s1_over
	ret	
reinit_1sl:
	mov	cnt_1sl,#0ffh
out_ds1sec:
	ret	
;----------------------------------------------------------------------
;----------------------------------------------------------------------
scanner:	
;----------------------------------------------------------------------
	mov	a,scan_no
;----------------------------------------------------------------------


;-(0)------------------------------------------------------------------
zero:
	cjne	a,#00d,one		;
;----------------------------------------
;key_output_line
	clr	sl1			;select display/row 1
	setb	sl2			;
	setb	sl3			;
	setb	sl4			;
;----------------------------------------
	call	adisp1
;----------------------------------------
	mov	c,krl1
	call	k
;----------------------------------------
	mov	scan_no,#01d
	ajmp	out_scanner
;----------------------------------------------------------------------


;-(1)------------------------------------------------------------------
one:
	cjne	a,#01d,two		;
;----------------------------------------

;----------------------------------------
	mov	c,krl2
	call	k
;----------------------------------------
	mov	scan_no,#02d	
	ajmp	out_scanner
;----------------------------------------------------------------------


;-(2)------------------------------------------------------------------
two:
	cjne	a,#02d,three		;
;----------------------------------------

;----------------------------------------
	mov	c,krl3
	call	k
;----------------------------------------
	mov	scan_no,#03d
	ajmp	out_scanner
;----------------------------------------------------------------------



;-(3)------------------------------------------------------------------
three:
	cjne	a,#03d,four		;
;----------------------------------------
	call	disp_blank
;----------------------------------------
	mov	c,krl4
	call	k
;----------------------------------------
	mov	scan_no,#04d
	ajmp	out_scanner
;----------------------------------------------------------------------



;-(4)------------------------------------------------------------------
four:
	cjne	a,#04d,five		;
;----------------------------------------
;key_output_line
	setb	sl1			;
	clr	sl2			;select display/row 2
	setb	sl3			;
	setb	sl4			;
;----------------------------------------
	call	adisp2
;----------------------------------------
	mov	c,krl1
	call	k
;----------------------------------------
	mov	scan_no,#05d
	ajmp	out_scanner
;----------------------------------------------------------------------



;-(5)------------------------------------------------------------------
five:
	cjne	a,#05d,six		;
;----------------------------------------

;----------------------------------------
	mov	c,krl2
	call	k
;----------------------------------------
	mov	scan_no,#06d
	ajmp	out_scanner
;----------------------------------------------------------------------



;-(6)------------------------------------------------------------------
six:
	cjne	a,#06d,seven		;
;----------------------------------------

;----------------------------------------
	mov	c,krl3
	call	k
;----------------------------------------
	mov	scan_no,#07d
	ajmp	out_scanner
;----------------------------------------------------------------------



;-(7)------------------------------------------------------------------
seven:
	cjne	a,#07d,eight		;
;----------------------------------------
	call	disp_blank
;----------------------------------------
	mov	c,krl4
	call	k
;----------------------------------------
	mov	scan_no,#08d
	ajmp	out_scanner
;----------------------------------------------------------------------



;-(8)------------------------------------------------------------------
eight:
	cjne	a,#08d,nine		;
;----------------------------------------
;key_output_line
	setb	sl1			;
	setb	sl2			;
	clr	sl3			;select display/row 3
	setb	sl4			;
;----------------------------------------
	call	adisp3
;----------------------------------------
	mov	c,krl1
	call	k
;----------------------------------------
	mov	scan_no,#09d
	ajmp	out_scanner
;----------------------------------------------------------------------


;-(9)------------------------------------------------------------------
nine:
	cjne	a,#09d,ten		;
;----------------------------------------

;----------------------------------------
	mov	c,krl2
	call	k
;----------------------------------------
	mov	scan_no,#10d
	ajmp	out_scanner
;----------------------------------------------------------------------

;-(10(a))--------------------------------------------------------------
ten:
	cjne	a,#10d,eleven		;
;----------------------------------------

;----------------------------------------
	mov	c,krl3
	call	k
;----------------------------------------
	mov	scan_no,#11d
	ajmp	out_scanner
;----------------------------------------------------------------------


;-(11(b))--------------------------------------------------------------
eleven:
	cjne	a,#11d,twelve		;
;----------------------------------------
	call	disp_blank
;----------------------------------------
	mov	c,krl4
	call	k
;----------------------------------------
	mov	scan_no,#12d
	ajmp	out_scanner
;----------------------------------------------------------------------


;-(12(c))--------------------------------------------------------------
twelve:
	cjne	a,#12d,thirteen		;
;----------------------------------------
;key_output_line
	setb	sl1			;
	setb	sl2			;
	setb	sl3			;
	clr	sl4			;select display/row 4
;----------------------------------------
	call	adisp4
;----------------------------------------
	mov	c,krl1
	call	k
;----------------------------------------
	mov	scan_no,#13d
	ajmp	out_scanner
;----------------------------------------------------------------------

;-(13(d))--------------------------------------------------------------
thirteen:
	cjne	a,#13d,fourteen		;
;----------------------------------------

;----------------------------------------
	mov	c,krl2
	call	k
;----------------------------------------
	mov	scan_no,#14d
	ajmp	out_scanner
;----------------------------------------------------------------------

;-(14(e))--------------------------------------------------------------
fourteen:
	cjne	a,#14d,fifteen		;
;----------------------------------------

;----------------------------------------
	mov	c,krl3
	call	k
;----------------------------------------
	mov	scan_no,#15d
	ajmp	out_scanner
;----------------------------------------------------------------------

;-(15(f))--------------------------------------------------------------
fifteen:
	cjne	a,#15d,dummy		;
;----------------------------------------
	call	disp_blank
;----------------------------------------
	mov	c,krl4
	call	k
;----------------------------------------
dummy:	mov	scan_no,#00d
	ajmp	out_scanner
;----------------------------------------------------------------------


;----------------------------------------------------------------------
out_scanner:
;	
	ret
;----------------------------------------------------------------------

;---------------------------------------------------
;comes with c flag having the status of the corrosponding krl line.
k:
	jb	key_ready,out_debounce
;----------------------------------------
;key detect....
	mov	tb,c			;save carry bit
	mov	a,dcount
	cjne	a,#33d,debounce
	mov	c,tb			;restore carry bit
;key pressed for the first time...
	jc	out_k
	dec	dcount
	mov	key_code,scan_no	;copy the scan_no in key_code
	jmp	out_k
;----------------------------------------	
debounce:
	djnz	dcount,out_k
;debounce complete..now check for key press...
	mov	c,tb			;restore carry bit
	jc	spurious_key
	mov	dcount,#33d
	setb	key_ready		;key still pressed (after debounce)
	setb	start_buzzer		;buzzer on
	jmp	out_k
spurious_key:
	mov	dcount,#33d
	jmp	out_k
out_debounce:
;----------------------------------------
;check for key release...
	jc	l1_k
	mov	krcount,#32d
	jmp	out_k
l1_k:
	djnz	krcount,out_k
	setb	nkp			;key release
	clr	start_buzzer		;buzzer off
	mov	krcount,#32d
;	jmp	out_k
;----------------------------------------
out_k:
	ret		
;---------------------------------------------------



;---------------------------------------------------
;Subroutines here onwards3...
;disp_blank
;adisp1,2,3,4
;test_display
;wait_1sec
;wait_20ms
;inc_d
;key_release
;get_key
;keyprocess
;disp_sw
;---------------------------------------------------
disp_blank:
	mov 	p0,#00h
	ret
;---------------------------------------------------


;---------------------------------------------------
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
;----------------------------------------

;----------------------------------------

adisp_lut:
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
;
	db	 11111111b	;3a
	db	 11111111b	;3b
	db	 11111111b	;3c
	db	 11111111b	;3d
	db	 11111111b	;3e
	db	 11111111b	;3f
	db	 11111111b	;40
;
	db	 11101110b	;A
	db	 00111110b	;B
	db	 10011100b	;C
	db	 01111010b	;D
	db	 10011110b	;E
	db	 10001110b	;F
	db	 10111100b	;G
	db	 01101110b	;H
	db	 00001100b	;I
	db	 01110000b	;J
	db	 00001110b	;K
	db	 00011100b	;L
	db	 10101010b	;M
	db	 00101010b	;N
	db	 00111010b	;O
	db	 11001110b	;P
	db	 11010110b	;Q
	db	 00001010b	;R
	db	 10110110b	;S
	db	 00011110b	;T
	db	 01111100b	;U
	db	 00111000b	;V
	db	 10111000b	;W
	db	 01100010b	;X
	db	 01100110b	;Y
	db	 10010010b	;Z
	db	 00000000b	;Z+1 for space
	db	 11111111b	;Z+2 for all segment glow
;---------------------------------------------------

;---------------------------------------------------
test_display:
	mov	ds1,#"Z"+2	;glow all segments
	mov	ds2,#"Z"+2
	mov	ds3,#"Z"+2
	mov	ds4,#"Z"+2
;
	call	wait_1sec
;
	mov	ds1,#"Z"+1	;put off all segments
	mov	ds2,#"Z"+1
	mov	ds3,#"Z"+1
	mov	ds4,#"Z"+1
;
	call	wait_1sec
;
	ret
;---------------------------------------------------

;--------------------------------------------------- 
wait_1sec:
	mov	dcount_3,#07d
l2:	mov 	dcount_2,#0ffh
l1:	mov 	dcount_1,#0ffh
	djnz 	dcount_1,$
	djnz 	dcount_2,l1
	djnz 	dcount_3,l2
	ret
;---------------------------------------------------

;---------------------------------------------------
wait_20ms:
	mov	dcount_2,#55h
	mov	dcount_1,#0ffh		;$-3-3
	djnz	dcount_1,$		;$-3
	djnz	dcount_2,$-3-3
	ret
;---------------------------------------------------

;---------------------------------------------------
;Increments value of ds4 ds3 ds2 ds1 considering as a singal
;four digit no from 0000 to 9999
inc_d:
	jnb	start_sw,out_id 
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
	cjne 	a,#"9"+1,out_id
;
	mov	ds1,#"0"
	mov	ds2,#"0"
	mov	ds3,#"0"
	mov	ds4,#"0"

;----------------------------------------
out_id:
	ret
;---------------------------------------------------

;---------------------------------------------------
key_release:
	jnb	nkp,$	;wait for no key press flag
	clr	key_ready
	clr	nkp
	ret
;---------------------------------------------------

;---------------------------------------------------
;gets ascii code for key pressed in "a" and key_code.
get_key:
	jnb	key_ready,$
	mov	a,key_code
	mov	dptr,#ascii_key
	movc	a,@a+dptr
	mov	key_code,a
	ret
ascii_key:	db	"0123456789ABCDEF"
;---------------------------------------------------

;---------------------------------------------------
keyprocess:
	mov	a,key_code
;
	cjne	a,#"A",chk_b
;---------------------------
	call	process_a
	jmp	out_kp
;---------------------------
chk_b:	cjne	a,#"B",chk_c
;---------------------------
	call	process_b
	jmp	out_kp
;---------------------------
chk_c:	cjne	a,#"C",out_kp
;---------------------------
	call	process_c
	jmp	out_kp
;---------------------------
out_kp:
	call	key_release
	ret
;---------------------------------------------------


;----------------------------------------
process_a:
	setb	start_sw
	ret
;----------------------------------------

;----------------------------------------
process_b:
	clr	start_sw
	ret
;----------------------------------------

;----------------------------------------
process_c:
	clr	start_sw
;
	mov	ds1,#"0"		;reset count to 0000
	mov	ds2,#"0"
	mov	ds3,#"0"
	mov	ds4,#"0"
;
	ret
;---------------------------------------------------

;---------------------------------------------------
disp_sw:
	mov	ds1,#"Z"+1
	mov	ds2,#"Z"+1
	mov	ds3,#"W"
	mov	ds4,#"S"
	ret
;---------------------------------------------------
buzzer:
	jnb	start_buzzer,out_b

	cpl	p1.5
out_b:
	ret
;---------------------------------------------------
	end
	