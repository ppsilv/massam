;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  IO.S
;*  General IO module.  Allows different IO devices to be
;*  utilised transparently by the rest of the code.
;*  Other code should use "io_" commands so that they
;*  do not need to know what specific device is providing
;*  input and output capabilities.  On startup, the kernel
;*  examines the BBC DIP switch to decide whether to
;*  initialise the IO to serial through the ACIA or use
;*  the BBC keyboard for input with the VDP for output.
;*  Loading and saving files from the SD card is similarly
;*  achieved by pointing to SD card get and put byte
;*  routines.
;*
;**********************************************************

	; ROM code
	code

mod_sz_io_s

;****************************************
;* io_init
;* Initialise the default device and make active
;* No keys pressed = serial (default)
;* F0 pressed = KB/VDP
;* F1 pressed = Serial
;* Keyboard and screen or serial port
;* Output : None
;* Regs affected : P, A
;****************************************
io_init
	jsr _kb_read_raw	; Check pressed key
	lda #0				; Default = Serial
	cpx #0x80			; f0 key pressed?
	bne io_init_skip_f0
	lda #1				; Default = KB/VDP
	bra io_init_done
io_init_skip_f0
	cpx #0x81			; f1 key pressed?
	bne io_init_done
	lda #0				; f1 pressed = serial
io_init_done
	sta io_default
	jmp io_active_device; Activate the device


;****************************************
;* io_set_default, io_active_device
;* Activate device based on default or A
;* Input : A = Device number
;* Output : None
;* Regs affected : P, A
;****************************************
io_set_default			; Entry point for default
	lda io_default
io_active_device		; Entry point for A set
	asl	a				; x16 the Block number
	asl a
	asl a
	asl a
	tay
	ldx #0
	; Copy device settings to io block
io_copy_data
	lda io_devices,y
	sta io_block,x
	iny
	inx
	cpx #16
	bne io_copy_data
	
	lda #lo(ser_buf)	; Initialise buffer and size
	sta buf_lo
	lda #hi(ser_buf)
	sta buf_hi
	lda #255
	sta buf_sz
	lda #UTF_CR		; Line terminator is CR
	sta buf_ef
	rts

;****************************************
;* io_get_ch
;* Get a char (wait forever or just check)
;* Input : C = 1 for synchronous, 0 for async
;* Output : A = Byte code, C = 0 means A is invalid
;* Regs affected : P, A
;****************************************
io_get_ch
	jmp (io_block+io_get_byte)
	

;****************************************
;* io_put_ch
;* Put a char
;* Input : A = char
;* Regs affected : P, A
;****************************************
io_put_ch
	jmp (io_block+io_put_byte)
	
;****************************************
;* io_open_read
;* Open for reading
;* Input : X,A = pointer to filename (zero terminated)
;* Output : C=0 success
;* Regs affected : All
;****************************************
io_open_read
	jmp (io_block+io_open_r)
	
;****************************************
;* io_open_write
;* Open for reading
;* Input : X,A = pointer to filename (zero terminated)
;* Output : C=0 success
;* Regs affected : All
;****************************************
io_open_write
	jmp (io_block+io_open_w)

;****************************************
;* io_close
;* Close a file
;* Input : 
;* Output : C=0 success
;* Regs affected : All
;****************************************
io_close
	jmp (io_block+io_close_f)
	
;****************************************
;* io_delete
;* Delete a file
;* Input : 
;* Output : C=0 success
;* Regs affected : All
;****************************************
io_delete
	jmp (io_block+io_del_f)
	
;****************************************
;* io_read_line
;* Read a line, terminated by terminating char or max buffer length
;* Input : buf_(lo/hi/sz/ef) : Address, Max size, end marker, C = 1 means echo
;* Output : Y = Line length C = Buffer limit reached
;* Regs affected : None
;****************************************
io_read_line
	pha

	php					; Save echo state
	
	ldy #0x00			; Starting at first byte
io_get_line_byte
	sec					; Getting bytes synchronously
	jsr io_get_ch		; Get a byte
	bcs io_get_line_done; Got nothing then finish
	plp					; Get echo state
	php					; Instantly save it back
	bcc io_skip_echo	; Carry not set = don't echo
	cmp #UTF_DEL		; Delete?
	bne io_do_echo
	cpy #0				; Already at beginning?
	beq io_skip_echo	; Don't echo delete
	dey					; Else decrement length
io_do_echo
	jsr io_put_ch		; Echo it
io_skip_echo
	cmp #UTF_SPECIAL	; Special character?
	bcc io_skip_special	; Skip if so (don't add to buffer)
	cmp #UTF_DEL		; Don't proces DEL either
	beq io_skip_special
	sta (buf_lo),y		; Save it
	iny					; Increase length
io_skip_special
	cmp buf_ef			; Is it the terminating char?
	beq io_get_line_done	; If yes then done
	cpy buf_sz			; Reached the buffer max size?
	bne io_get_line_byte	; No, get another byte
	plp					; Remember to pull echo state off stack
	sec					; Yes, set carry flag
	pla
	rts					; And done
io_get_line_done
	lda #0
	sta (buf_lo),y		; Terminate with 0
	plp					; Remember to pull echo state off stack
	clc					; Clear carry flag
	pla
	rts					; Fin

;****************************************
;* io_print_line
;* Print a line (when data is not already in serial buffer)
;* Input : X = Address Lo, A = Address Hi
;* Output : Y=number chars output
;* Regs affected : All
;****************************************
io_print_line
	pha

	stx tmp_clo					; Store the string pointer
	sta tmp_chi					; lo and hi
	ldy #0						; Start at the beginning!
io_print_line_byte
	lda (tmp_clo),y				; Copy byte to
	beq io_print_done			; If zero then done - print
	jsr io_put_ch				; Transmit
	iny
	bne io_print_line_byte		; Carry on until zero found or Y wraps
io_print_done
	pla
	rts


;*** Null operation just clc and return ***
io_null_op
	clc
	rts
	
;* IO devices defined here
io_devices
;* Device zero is the serial port
;* only offers get and put
io_device0					; Serial device, input = Ser, output = Ser
	dw	_get_byte			; io_get_ch
	dw	_put_byte			; io_put_ch
	dw	io_null_op			; io_open_r
	dw	io_null_op			; io_open_w
	dw	io_null_op			; io_close_f
	dw	io_null_op			; io_del_f
	dw	io_null_op			; io_ext1
	dw	io_null_op			; io_ext2
;* Device one is keyboard / screen
;* only offers get and put
io_device1					; Default device, input = screen editor, output = screen editor
	dw	_gr_get_key			; io_get_ch
	dw	_gr_put_byte		; io_put_ch
	dw	io_null_op			; io_open_r
	dw	io_null_op			; io_open_w
	dw	io_null_op			; io_close_f
	dw	io_null_op			; io_del_f
	dw	io_null_op			; io_ext1
	dw	io_null_op			; io_ext2
;* Device two is the file system on SD card
;* Offers all IO functions
io_device2					; SD device, input = SD, output = SD
	dw	_fs_get_next_byte	; io_get_ch
	dw	_fs_put_byte		; io_put_ch
	dw	_fs_open_read		; io_open_r
	dw	_fs_open_write		; io_open_w
	dw	_fs_close			; io_close_f
	dw	_fs_delete			; io_del_f
	dw	io_null_op			; io_ext1
	dw	io_null_op			; io_ext2

mod_sz_io_e

