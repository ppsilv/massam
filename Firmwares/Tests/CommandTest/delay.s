;-----------------------------------------------------------------------------------------
; Delay 
;cpu clock..: 1.843.200 hz
;period.....: 0,542 ns
;delay total: 1,0 ms 
delay:
	PHX
	ldx  #$CD   ; (2 cycles)
delay1: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne  delay1 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end
	PLX
	rts


delay2:
	pha
	txa
	pha
	ldx  #$5   ; (2 cycles)
delay21: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne  delay21 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end
	pla
	tax
	pla
	rts