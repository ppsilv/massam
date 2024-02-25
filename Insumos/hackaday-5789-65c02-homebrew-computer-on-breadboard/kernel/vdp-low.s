;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  VDP-LOW.S
;*  Low level VDP routines which will always be present in
;*  every ROM bank.  This is to ensure if IRQ needs it then
;*  no slow bank switching is needed, but also to provide
;*	OS vectored access to VDP routines for M/C from BASIC
;*
;**********************************************************

;****************************************
;* vdp_wr_reg
;* Write to Register A the value X
;* Input : A - Register Number, X - Data
;* Output : None
;* Regs affected : P
;****************************************
vdp_wr_reg
	stx VDP_MODE1
; Extra nop for fast CPU
	nop
	nop
	ora #0x80
	sta VDP_MODE1
	eor #0x80
	rts
	
;****************************************
;* vdp_wr_addr
;* Write to address in X (low) and A (high) - for writing
;* Input : A - Address high byte, X - Address low byte
;* Output : None
;* Regs affected : P
;****************************************
vdp_wr_addr
	stx VDP_MODE1
; Extra nop for fast CPU
	nop
	nop
	ora #0x40		; Required by VDP
	sta VDP_MODE1
	eor #0x40		; Undo that bit
	rts


;****************************************
;* vdp_mem_wait
;* Delay some time before a memory access,
;* taking in to account mode 9918 needs up
;* to 3.1uS for text mode, 8uS for graphics
;* I and II
;* @ 5.35Mhz	= 16 cycles for 3.1uS
;*				= 43 cycles for 8uS
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
vdp_mem_wait
	phx								; 3
	ldx vdp_delay					; 3
	beq vdp_mem_wait_end			; 3
vdp_mem_wait_loop
	dex								; 2
	bne	vdp_mem_wait_loop			; 3
vdp_mem_wait_end
	plx								; 3
	rts								; 6
	
;****************************************
;* vdp_rd_addr
;* Set read address 
;* Input : A - high, X - low 
;* Output : None
;* Regs affected : None
;****************************************
vdp_rd_addr
	stx VDP_MODE1
; These nops are needed for fast CPU
	nop
	nop
	sta VDP_MODE1
	bra vdp_mem_wait
	
;****************************************
;* vdp_rd_vram
;* Read VRAM byte, result in A
;* Input : None
;* Output : A - Byte from VRAM
;* Regs affected : P
;****************************************
vdp_rd_vram
	lda VDP_VRAM
	bra vdp_mem_wait
	
;****************************************
;* vdp_wr_vram
;* Write VRAM byte in A
;* Input : A - Byte to write
;* Output : None
;* Regs affected : None
;****************************************
vdp_wr_vram
	sta VDP_VRAM
	bra vdp_mem_wait
	
;****************************************
;* vdp_poke
;* Write VRAM byte in A, (YX)
;* Input : A - Byte to write
;*		   X = Low Address
;*		   Y = High Address
;* Output : None
;* Regs affected : None
;****************************************
vdp_poke
	pha
	tya
	sei
	jsr vdp_wr_addr
	pla
	jsr vdp_wr_vram
	cli
	rts

;****************************************
;* vdp_peek
;* Get VRAM byte in (AX)
;*		   X = Low Address
;*		   A = High Address
;* Output : A = byte read
;* Regs affected : None
;****************************************
vdp_peek
	sei
	jsr vdp_rd_addr
	jsr vdp_rd_vram
	cli
	rts
