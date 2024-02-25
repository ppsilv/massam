;****************************************
;* cmd_watch
;* Watch memory at a number of locations
;* Input : buflo, bufhi
;* Output : y = start of first parm byte
;* Regs affected : A
;****************************************
cmd_watch
	pha
	phx
	phy

	clc
	jsr cmd_parse_word			; Get 1st word
	bcs cmd_watch_err
	stx watch_slot				; Store in first watch slot
	sta watch_slot+1			; hi byte of watch slot
	ldx #2						; Point to next empty slot
cmd_fill_watch_slots
	phx							; Preserve slot index
	jsr cmd_parse_next_parm		; Try and find next watch parm
	bcs cmd_watch_start			; If error then no more parms
	jsr cmd_parse_word			; Get the word
	bcs cmd_watch_errl			; Should be no error
	stx tmp_watch				; Store low byte
	plx							; Get slot index back
	cpx #08						; If all slots filled, then error
	bne	cmd_watch_slots_avail
	lda #CMD_ERR_PARM			; Use parm error code
	sta errno
	sec
	bra cmd_watch_err
cmd_watch_slots_avail
	sta watch_slot+1,x			; Store hi byte
	lda tmp_watch				; Load lo byte from temp
	sta watch_slot,x			; Store low byte
	inx							; Point to next slot
	inx
	bra	cmd_fill_watch_slots	; Try and find more parms
cmd_watch_start
	pla							; Pull saved slot index
	sta tmp_watch				; Save pos. after last slot
cmd_watch_do
	ldx #0
cmd_watch_loop
	lda watch_slot,x			; Get address hi and lo
	sta tmp_alo
	lda watch_slot+1,x
	sta tmp_ahi
	lda (tmp_alo)				; Get value at this location
	phx							; Save index
	jsr str_a_to_x				; Convert to hex
	jsr io_put_ch
	txa
	jsr io_put_ch
	lda #' '
	jsr io_put_ch
	plx							; Restore index
	inx							; Point to next watch slot
	inx
	cpx tmp_watch				; Done all?
	bne cmd_watch_loop
	lda #UTF_CR					; New line
	jsr io_put_ch
	clc							; Async input check
	jsr io_get_ch				; Any key pressed?
	bcs cmd_watch_do			; No start again

	ply
	plx
	pla
	rts
cmd_watch_errl
	pla
cmd_watch_err
	ply
	plx
	pla
	rts
	
;****************************************
;* cmd_vdp
;* Set the VDP register XX to YY
;* Input : buflo, bufhi
;* Output : y = start of first parm byte
;*          x = index to routine pointer
;****************************************
cmd_vdp
	pha
	phx
	
	clc
cmd_set_vdp_reg
	jsr cmd_parse_next_parm		; Try and find another parm
	bcs cmd_vdp_err
	jsr cmd_parse_byte			; Get register number
	bcs cmd_vdp_err
	pha							; Save it temporarily
	jsr cmd_parse_next_parm		; Try and find another parm
	bcs cmd_vdp_errl
	jsr cmd_parse_byte			; Get register value
	bcs cmd_vdp_errl
	tax							; Value goes in X
	pla							; Pull Reg number
	jsr vdp_wr_reg
	jsr cmd_parse_next_parm		; Try and find another parm
	bcc cmd_set_vdp_reg			; Process if found, else fin
	clc
	plx
	pla
	rts
cmd_vdp_errl
	pla
cmd_vdp_err
	sec
	plx
	pla
	rts


;****************************************
;* cmd_vdp
;* Set the Sound register XX to YY
;* Input : buflo, bufhi
;* Output : y = start of first parm byte
;*          x = index to routine pointer
;****************************************
cmd_snd
	pha
	phx
	
	clc
cmd_set_snd_reg
	jsr cmd_parse_next_parm		; Try and find another parm
	bcs cmd_snd_err
	jsr cmd_parse_byte			; Get register number
	bcs cmd_snd_err
	pha							; Save it temporarily
	jsr cmd_parse_next_parm		; Try and find another parm
	bcs cmd_snd_errl
	jsr cmd_parse_byte			; Get register value
	bcs cmd_snd_errl
	plx							; Pull Reg number in to X
	phy
	tay							; Value goes in Y
	jsr snd_set					; Set X to Y
	ply
	jsr cmd_parse_next_parm		; Try and find another parm
	bcc cmd_set_snd_reg			; Process if found, else fin
	clc
	plx
	pla
	rts
cmd_snd_errl
	pla
cmd_snd_err
	sec
	plx
	pla
	rts


;****************************************
;* cmd_joystick
;* Joystick test
;* Input : None
;* Output : None
;* Regs affected : 
;****************************************
cmd_joystick
	pha
	phx
	phy

cmd_joystick_rep
	jsr snd_get_joy0
	tya
	ldy #8
cmd_joystick_bit
	asl a
	pha
	bcs cmd_joystick_bit_1
	lda #'0'
	bra cmd_joystick_bit_put
cmd_joystick_bit_1
	lda #'1'
cmd_joystick_bit_put
	jsr io_put_ch
	pla
	dey
	bne cmd_joystick_bit
	lda #UTF_CR
	jsr io_put_ch

	clc
	jsr io_get_ch
	bcs cmd_joystick_rep

	ply
	plx
	pla
	clc
	rts

