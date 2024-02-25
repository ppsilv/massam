;-----------------------------------------------------------------------------------------
; Delay 
;cpu clock..: 1.843.200 hz
;period.....: 0,542 ns
;deley total: 1,0 ms 
delay:
	ldx  #$CD   ; (2 cycles)
delay1: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne  delay1 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end
	rts
