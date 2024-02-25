;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  OSVEC.S
;*  Simply this is a bunch of JMP XXXX the order of which
;*  will always be maintained.  This is to allow machine
;*  code programs to be able to rely on fixed locations for
;*  some key low-level functions.
;*  Only low level functions are needed, the idea is that
;*  as the assembler is part of the BASIC, one can do high
;*  level slow stuff using BASIC then switch to M/C for the
;*  speed up.
;*  This code goes straight after the bank number, so
;*  Each JMP is at 0xc001+3*(vector #)
;*
;**********************************************************

	jmp	io_put_ch			; Vec 0
	jmp io_get_ch			; Vec 1
	jmp vdp_wr_reg			; Vec 2
	jmp vdp_poke			; Vec 3
	jmp vdp_peek			; Vec 4
	jmp snd_get_joy0		; Vec 5
	jmp snd_set				; Vec 6
	jmp vdp_wr_addr			; Vec 7
	jmp	vdp_rd_addr			; Vec 8