;****************************************
;*	DOLO-1 HOMEBREW COMPUTER			*
;*	HW & SW DESIGN : Dolo Miah			*
;*	(C) 2014-2015						*
;****************************************

	; ROM code
	code  

monitor
	lda #0						; Initialise monitor
	sta mad_lo					; Monitor address lo
	sta mad_hi					; Monitor address hi
	sta mad_mem					; Memory = 0 RAM, 1 = VRAM
mon_ready
	_println msg_ready

	ldy #80						; Maximum line length
	sty buf_sz
	sec							; Set carry flag = echo characters
	jsr io_read_line			; Get a command line
	ldy #0						; Start at command byte
	lda (buf_lo),y				; Get the command byte (alpha)
	and #0b11011111				; Mask of lower-case so in alpha A-Z range
	
	ldx #cmd_tbl_end-cmd_tbl-3	; Index in to last entry of command table
find_cmd
	cmp cmd_tbl,x				; Found command?
	beq exec_cmd				; If so, execute it
	dex							; Else advance 2 bytes to 
	dex							; Next command table entry
	dex
	bpl find_cmd				; Look for another command if x >=0

	_println msg_error			; Didn't find a command match
	rts

exec_cmd
	inx							; Store jump vector lo
	lda cmd_tbl,x
	sta tmp_blo
	inx							; Store jump vector hi
	lda cmd_tbl,x
	sta tmp_bhi
	jsr cmd_jsr					; Run as a subroutine
	
	jmp mon_ready				; Back to ready prompt when done
cmd_jsr
	jmp (tmp_blo)				; Jump to the command to execute - return with rts
	
mon_cmd_quit
	rts

mon_cmd_run
	rts

mon_cmd_addr
	iny							; Skip the space
	iny							; Point to first char
	jsr mon_read_byte			; Read a byte and convert to A
	sta mad_hi
	iny							; Point to 3rd char
	jsr mon_read_byte			; Read a byte and convert to A
	sta mad_lo
	
	rts

mon_cmd_dump
	jsr mon_show_addr
	lda #' '
	jsr io_put_ch
	ldy #0
	lda mad_hi
	ldx mad_lo
	jsr mon_set_addr_read
mon_d_byte
	phy
	jsr mon_get_byte
	jsr mon_show_byte
	lda #' '
	jsr io_put_ch
	ply
	iny
	cpy #8
	bne mon_d_byte
	clc
	lda mad_lo
	adc #8
	sta mad_lo
	lda mad_hi
	adc #0
	sta mad_hi

	lda #UTF_CR
	jsr io_put_ch

	sec
	jsr io_get_ch
	cmp #UTF_CR
	beq mon_cmd_dump
	
	rts
	
mon_cmd_mem
	iny
	iny
	lda #0				; Assume normal RAM
	sta mad_mem
	lda (buf_lo),y
	ora #0x20			; If A-Z then make lower case
	cmp #'v'
	bne skip_vram_setting
	lda #1				; Set to VRAM
	sta mad_mem
skip_vram_setting	
	rts

mon_cmd_store
	iny						; Skip space
mon_s_byte
	iny						; point to 1st char
	lda (buf_lo),y			; Check if
	cmp #UTF_CR				; CR?
	beq mon_s_done			; Finish if so
	jsr mon_read_byte		; Get a byte
	sty tmp_c				; save Y
	ldy #0					; Zero it
	jsr mon_set_byte		; Store the byte
	jsr mon_add_inc			; Move pointer
	ldy tmp_c				; Restore Y
	bra mon_s_byte			; Unconditional branch for another byte	
mon_s_done
	rts

mon_add_inc
	inc mad_lo
	bne skip_mad_hi
	inc mad_hi
skip_mad_hi
	rts

mon_read_byte
	lda (buf_lo),y				; Load high char
	pha
	iny							; Point to high char
	lda (buf_lo),y				; Load low char
	tax							; X = Low
	pla							; A = High
	jsr str_x_to_a				; Convert value
	rts
	
mon_get_byte
	lda mad_mem
	bne vram_access
	lda (mad_lo),y
	rts
vram_access
	jsr vdp_rd_vram
	rts

mon_set_addr_write
	stx mad_lo
	sta mad_hi
	pha
	lda mad_mem
	bne vram_wr_addr
	pla
	rts
vram_wr_addr
	pla
	jsr vdp_wr_addr
	rts

mon_set_addr_read
	stx mad_lo
	sta mad_hi
	pha
	lda mad_mem
	bne vram_rd_addr
	pla
	rts
vram_rd_addr
	pla
	jsr vdp_rd_addr
	rts

mon_set_byte
	pha
	lda mad_mem
	bne vram_write
	pla
	sta (mad_lo),y
	rts
vram_write
	lda mad_hi
	ldx mad_lo
	jsr vdp_wr_addr
	pla
	jsr vdp_wr_vram
	rts
	
; * A = Byte to show
mon_show_byte
	jsr str_a_to_x		; A = High, X = Low
	jsr io_put_ch
	txa					; Transfer low to A
	jsr io_put_ch
	rts
	
mon_show_addr
	lda mad_hi
	jsr mon_show_byte
	lda mad_lo
	jsr mon_show_byte
	rts
	
cmd_tbl
	db 'Q', lo(mon_cmd_quit), hi(mon_cmd_quit)
	db 'A', lo(mon_cmd_addr), hi(mon_cmd_addr)
	db 'D', lo(mon_cmd_dump), hi(mon_cmd_dump)
	db 'M', lo(mon_cmd_mem), hi(mon_cmd_mem)
	db 'S', lo(mon_cmd_store), hi(mon_cmd_store)
	db 'R', lo(mon_cmd_run), hi(mon_cmd_run)
	db 'J', lo(mon_cmd_game), hi(mon_cmd_game)
	db 'T', lo(sd_mon_writeblock), hi(sd_mon_writeblock)
	db 'G', lo(sd_mon_readblock), hi(sd_mon_readblock)
cmd_tbl_end
	
msg_ready
	db "Ready\r", 0
msg_error
	db "Error - Only following commands are valid\r"
	db " M [V|R]: Select Video or Standard RAM\r"
	db " A XXXX : Set address to XXXX\r"
	db " D      : Dump memory\r"
	db " S XX*  : Set byte(s) to XX\r"
	db " R xxxx : Run from address XXXX\r"
	db " J      : Joystick Game Test!\r"
	db " T	    : Transfer block to SD Card\r"
	db " G		: Get block from SD Card\r"
	db " Q      : Obvious!\r"
	db "\r", 0

	
	
; Not a game at the moment - demo of sprites and joystick working
mon_cmd_game
	lda #0
	sta spr0_y
	sta spr0_x
	lda vdp_cnt
	sta spr0_t
game_loop
	lda vdp_cnt			; vdp_cnt is updated every VB
	sta spr0_t
	jsr snd_get_joy0
	tya
	_printA
	lsr a				; Check bit 0 - Up
	bcs skip_up
	dec spr0_y
skip_up
	lsr a				; Check bit 1 - Down
	bcs skip_down
	inc spr0_y
skip_down
	lsr a				; Check bit 2 - Left
	bcs skip_left
	dec spr0_x
skip_left
	lsr a				; Check bit 3 - Right
	bcs skip_right
	inc spr0_x
skip_right
	lsr a				; Check bit 4 - Fire button
	bcc fire_finished
wait_blank
	lda vdp_cnt			; vdp_cnt is updated every VB
	cmp spr0_t			; so when it changes, then proceed
	beq wait_blank
draw_sprite
	ldx #lo(VDP_SPRT_ATT_G1)
	lda #hi(VDP_SPRT_ATT_G1)
	jsr vdp_wr_addr
	lda spr0_y
	jsr vdp_wr_vram
	lda spr0_x
	jsr vdp_wr_vram
	jmp game_loop
fire_finished
	rts
	
test_messages
	db "The quick brown fox\r\xff"