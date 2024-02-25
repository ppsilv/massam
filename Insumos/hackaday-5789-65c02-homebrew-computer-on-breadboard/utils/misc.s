;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  MISC.S
;*  Miscellaneous module for commmon utility functions.
;*
;**********************************************************

	; ROM code
	code

;****************************************
;* long_delay
;* Long delay (X decremented every 0.125ms)
;* Input : X = number of 0.125ms ticks to wait (max wait approx 0.32s)
;* Output : None
;* Regs affected : None
;****************************************
long_delay
	php
	_pushAXY
	
	ldy #0x00
long_delay_1
	nop
	nop
	nop
	nop
	dey
	bne long_delay_1
	dex
	bne long_delay_1

	_pullAXY
	plp
	
	rts

