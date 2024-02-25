;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  SERIAL.S
;*  Serial input/output handler - driving a 6551 ACIA.
;*  To handle WDC65c51 bug on transmit, use a delay
;*  to ensure byte is transmitted before the next byte.
;*
;**********************************************************

	; ROM code
	code


;****************************************
;* get_byte
;* Get a byte (wait forever or just check)
;* Input : C = 1 for synchronous, 0 for async
;* Output : A = Byte code, C = 1 means A is invalid
;* Regs affected : P, A
;****************************************
get_byte
	lda SER_STATUS			; Check status register
	and #SER_RDRF			; Is Receive Data Register Full bit set?
	bne got_byte
	bcs get_byte			; If C then keep waiting
	sec						; Indicate byte was not got
	rts						; If not C then return immediately
got_byte
	clc						; Indicate byte was got
	lda SER_DATA			; Read data
	rts

;****************************************
;* put_byte
;* Put a byte out
;* Input : A = Byte to put
;* Output : None
;* Regs affected : None
;****************************************
put_byte
	pha						; Save A
;	phx
;	ldx #112				; Loop 112 times
put_byte_wait				; Delay 2512 cycles (19200bps, 10 bits)
;	nop						; For 5.36Mhz clock
;	nop						; ~25 cycles per loop (10xnop+dex+bne)
;	nop						; 
;	nop						; 
;	nop						; 
;	nop						; 
;	nop						; 
;	nop						; 
;	nop						; 
;	nop						; 
;	dex						;
	lda SER_STATUS			; Check status register
	and #SER_TDRE			; Is transmit reg empty?
	beq put_byte_wait		; Keep waiting if not
;	plx						; restore X
	pla						; Get A back
	sta SER_DATA			; Write the data
	rts


;****************************************
;* init_acia
;* ACIA initialisation (this is IO_2)
;* Input : None
;* Output : None
;* Regs affected : X
;****************************************
init_acia
	ldx #0b00011111			; 19200 baud, 8 bits, 1 stop bit, internal clock		
	stx SER_CTL
	ldx #0b00001011			; No parity, no TX int plus RTS low, no RX int, DTR
	stx SER_CMD
	ldx SER_STATUS			; Read status reg to clear stuff

	rts
