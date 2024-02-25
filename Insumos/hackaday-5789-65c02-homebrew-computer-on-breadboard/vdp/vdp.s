;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  VDP.S
;*  This module implements the drivers of the VDP, which is
;*  a TMS9918a.  The VDP is interfaced to the 6502 bus
;*  through a memory mapped IO (that's how the 6502 likes it).
;*  There are only two bytes in the IO space that are used
;*  and the 6502 needs to poke or read from these with enough
;*  delay to allow the VDP to detect and respond to the
;*  request.  It's interesting that delays are needed - the
;*  MSX computer also used a TMS9918a but with Z80a as the
;*  CPU, which actually didn't need delays.  The 6502 is
;*  a simple processor but a write instruction only needs
;*  4 cycles, hence needing delays.
;*  Considering it came out in the late 70s, the TMS9900
;*  series of VDP are pretty impressive - 2 text modes and
;*  a hires mode too ('a' variant).  Plus 32 hardware
;*  sprites and 15 colours - very good indeed. Also the VDP
;*  uses its own memory so doesn't eat 6502 space.
;*  Downside to having its own memory is that it can be
;*  slow to do large updates e.g. scrolling.  Ok sure a 40
;*  column screen can be scrolled and it looks ok, but
;*  no way would I try to scroll a hires screen.  Hence
;*  why many games on the MSX didn't do smooth scrolling.
;*
;*  NOTE:	As part of the ROM banking strategy, the very
;*			lowest level routines have been factored out
;*			to the 'kernel' which means they are present
;*			in every code bank.
;*
;**********************************************************


	; ROM code
	code

mod_sz_vdp_s

	include "vdp\font.s"



;****************************************
;* vdp_init
;* Initialise VDP
;* Clears all of VRAM to zero
;****************************************
vdp_init
	jsr clear_vram
	rts

;****************************************
;* vdp_init_mode
;* Initialise VDP  to required mode and addresses
;* Input : Y = Offset in to VDP init table
;* Output : None
;* Regs affected : All
;****************************************
vdp_init_mode
	sei
	ldx vdp_base_table+0,y		; Get delay
	stx vdp_delay

	lda	#0						; Do R0
	ldx vdp_base_table+1,y		; Get R0 value
	jsr vdp_wr_reg				; Write X to Reg A

	lda	#1						; Do R1
	ldx vdp_base_table+2,y		; Get R1 value
	jsr vdp_wr_reg				; Write X to Reg A

	ldx vdp_base_table+3,y		; Get name table low address
	stx vdp_base+vdp_addr_nme	; Save in vdp_base
	ldx vdp_base_table+4,y		; Get name table high address
	stx vdp_base+vdp_addr_nme+1	; Save in vdp_base
	lda #2						; Do R2
	ldx vdp_base_table+5,y		; Get R2 value
	jsr vdp_wr_reg				; Write X to Reg A

	ldx vdp_base_table+6,y		; Get col table low address
	stx vdp_base+vdp_addr_col	; Save in vdp_base
	ldx vdp_base_table+7,y		; Get col table high address
	stx vdp_base+vdp_addr_col+1	; Save in vdp_base
	lda #3						; Do R3
	ldx vdp_base_table+8,y		; Get R3 value
	jsr vdp_wr_reg				; Write X to Reg A

	ldx vdp_base_table+9,y		; Get pat table low address
	stx vdp_base+vdp_addr_pat	; Save in vdp_base
	ldx vdp_base_table+10,y		; Get pat table high address
	stx vdp_base+vdp_addr_pat+1	; Save in vdp_base
	lda #4						; Do R4
	ldx vdp_base_table+11,y		; Get R4 value
	jsr vdp_wr_reg				; Write X to Reg A

	ldx vdp_base_table+12,y		; Get spr att table low address
	stx vdp_base+vdp_addr_spa	; Save in vdp_base
	ldx vdp_base_table+13,y		; Get spr att table high address
	stx vdp_base+vdp_addr_spa+1	; Save in vdp_base
	lda #5						; Do R5
	ldx vdp_base_table+14,y		; Get R5 value
	jsr vdp_wr_reg				; Write X to Reg A

	ldx vdp_base_table+15,y		; Get spr pat table low address
	stx vdp_base+vdp_addr_spp	; Save in vdp_base
	ldx vdp_base_table+16,y		; Get spr pat table high address
	stx vdp_base+vdp_addr_spp+1	; Save in vdp_base
	lda #6						; Do R6
	ldx vdp_base_table+17,y		; Get R6 value
	jsr vdp_wr_reg				; Write X to Reg A

	lda #7						; Do R7
	ldx vdp_base_table+18,y		; Get R7 value
	stx vdp_base+vdp_bord_col	; Save border colour
	jsr vdp_wr_reg				; Write X to Reg A
	
	cli

	rts
	

;****************************************
;* vdp_set_txt_mode
;* Set up text mode
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_txt_mode
	ldy #vdp_base_table_txt-vdp_base_table
	jsr vdp_init_mode
	jmp init_fonts

	
;****************************************
;* vdp_set_g1_mode
;* Set up G1 mode
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_g1_mode
	ldy #vdp_base_table_g1-vdp_base_table
	jsr vdp_init_mode
	jmp init_fonts

;****************************************
;* vdp_set_g2_mode
;* Set up G2 mode
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_g2_mode
	ldy #vdp_base_table_g2-vdp_base_table
	jsr vdp_init_mode
	jmp init_fonts

;****************************************
;* vdp_set_hires
;* Set up HI mode
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_hires
	ldy #vdp_base_table_hi-vdp_base_table
	jsr vdp_init_mode
	
	; No fonts to init but pre-fill name table
	; to use all 3 character sets
	sei

	; Point at name table
	ldx vdp_base+vdp_addr_nme
	lda vdp_base+vdp_addr_nme+1
	jsr vdp_wr_addr
	
	; set name for 3 pages (768)
	ldx #0
	ldy #3
vdp_set_hires_fill_nme
	txa						; Name table is 0..255 for 3 pages
	jsr vdp_wr_vram
	inx
	bne vdp_set_hires_fill_nme
	dey
	bne vdp_set_hires_fill_nme
	
	cli
	
	rts

	
;****************************************
;* init_vdp_g1
;* Initialise video processor graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;***************************************
init_vdp_g1
	jsr vdp_set_g1_mode
	jsr init_sprtpat_g1
	jsr init_colours_g1
	jsr init_sprites_g1
	rts

;****************************************
;* init_vdp_g1
;* Initialise video processor graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;***************************************
init_vdp_g2
	jsr vdp_set_g2_mode
	jsr init_sprtpat_g1		; Same as G1
	jsr init_colours_g2
	jsr init_sprites_g1		; Same as G1
	rts

;****************************************
;* init_vdp_hires
;* Initialise video processor graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;***************************************
init_vdp_hires
	jsr vdp_set_hires
	jsr init_sprtpat_g1
	jmp init_sprites_g1


;****************************************
;* init_vdp_txt
;* Initialise video processor text mode
;* Input : None
;* Output : None
;* Regs affected : All
;***************************************
init_vdp_txt
	jmp vdp_set_txt_mode
	

;****************************************
;* fill_vram
;* Fill a number of VRAM bytes with a value
;* Input : X,Y = Fill length (lo,hi), A = Value
;* Output : None
;* Regs affected : All
;* ASSUMES vdp_wr_vram already called
;* Works for < 256 bytes as long as Y=1
;* Else only use for WHOLE pages at a time so X must be ZERO
;* INTERRUPTS MUST HAVE BEEN DISABLED BY THE CALLER!!!!
;****************************************
vdp_fill_vram
	jsr vdp_wr_vram
	dex
	bne vdp_fill_vram
	dey
	bne vdp_fill_vram
	rts

;****************************************
;* clear_vram
;* Set all 16k VDP vram to 0x00
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
clear_vram
;	sei
	ldx #0x00			; Low byte of address
	lda #0x00			; High byte of address
	jsr vdp_wr_addr		; Write address to VDP

	ldy #0x40			; 0x40 pages = 16k (X already zero)
	jsr vdp_fill_vram
;	cli
	rts
	
;****************************************
;* init_colours_g1
;* Initialise colour table for graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_colours_g1
	sei
	ldx vdp_base+vdp_addr_col
	lda vdp_base+vdp_addr_col+1
	jsr vdp_wr_addr				; Set VDP address
	
	ldx #0x20					; 32 bytes to fill	
	ldy #0x01					; Only 1 pass through
	lda vdp_base+vdp_bord_col	; Border colour
	jsr vdp_fill_vram
	cli
	rts

;****************************************
;* init_colours_g2
;* Initialise colour table for graphics 2
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_colours_g2
	sei
	ldx vdp_base+vdp_addr_col
	lda vdp_base+vdp_addr_col+1
	jsr vdp_wr_addr				; Set VDP address
	
	ldx #0x00					; 2048 bytes to fill	
	ldy #0x08					; 8 pass through
	lda vdp_base+vdp_bord_col	; Border colour
	jsr vdp_fill_vram
	cli
	rts

;****************************************
;* init_sprites_g1
;* Initialise sprite attribute table for graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_sprites_g1
	sei
	ldx vdp_base+vdp_addr_spa
	lda vdp_base+vdp_addr_spa+1
	jsr vdp_wr_addr				; Set VDP address
	
	ldx #0x80					; 128 bytes of attribute to fill
	ldy #0x01					; Only 1 pass
	lda #0xd0					; Sprite terminator
	jsr vdp_fill_vram
	cli
	rts

;****************************************
;* init_fonts
;* Initialise fonts 
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_fonts
	sei
	ldx vdp_base+vdp_addr_pat
	lda vdp_base+vdp_addr_pat+1
	jsr vdp_wr_addr				; Write the address
	jsr init_fonts_sub
	cli
	rts

;****************************************
;* init_sprtpat_g1
;* Initialise fonts for sprites
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_sprtpat_g1
	sei
	ldx vdp_base+vdp_addr_spp
	lda vdp_base+vdp_addr_spp+1
	jsr vdp_wr_addr				; Write the address
	jsr init_fonts_sub
	cli
	rts
	
;****************************************
;* init_fonts_sub
;* Initialise fonts common subroutine
;* Input : None
;* Output : None
;* Regs affected : All
;* INTERRUPTS MUST HAVE BEEN DISABLED BY CALLER!!!
;****************************************
init_fonts_sub
	stz tmp_a				; XOR with zero = no change
	ldy #0					; byte within page
init_write_fonts
	lda #lo(vdp_font)		; Low byte of fonts source
	sta tmp_alo
	lda #hi(vdp_font)		; High byte of fonts source
	sta tmp_ahi
	ldx #0x04				; 4 pages = 1024 bytes
init_pattern
	tya
	lda (tmp_alo),y			; Get byte from font table
	eor tmp_a				; Invert if tmp_a is 0xff
	jsr vdp_wr_vram			; Write the byte to VRAM
	iny
	bne init_pattern		; keep going for 1 page
	inc tmp_ahi				; only need to increment high byte of font ptr
	dex						; page counter
	bne init_pattern		; keep going for 4 pages
	lda tmp_a				; get the current eor mask
	eor	#0xff				; Invert the EOR mask
	sta tmp_a				; And save for next go around
	bne init_write_fonts
	rts

;**** BASE TABLES ****
vdp_base_table
vdp_base_table_g1
	db	VDP_LONGDELAY	; Long delay
	db	%00000000		; R0 - No-extvid
	db	%11100000		; R1 - 16K,Disp-enable,Int-enable,8x8,No-mag
	dw	0x1000			; Name table address
	db	0x1000>>10		; R2 Name table value
	dw	0x1380			; Colour table
	db	0x1380>>6		; R3 Colour table value
	dw	0x0000			; Pattern table
	db	0x0000>>11		; R4 Pattern table value
	dw	0x1300			; Sprite attribute table
	db	0x1300>>7		; R5 Sprite attribute table value
	dw	0x0800			; Sprite pattern table
	db	0x0800>>11		; R6 Sprite pattern table value
	db	0xf4			; R7 White f/gnd, blue background

vdp_base_table_g2
	db	VDP_LONGDELAY	; Long delay
	db	%00000010		; R0 - GR2HiRes,No-extvid
	db	%11100000		; R1 - 16K,Disp-enable,Int-enable,8x8,No-mag
	dw	0x3800			; Name table address
	db	0x3800>>10		; R2 Name table value
	dw	0x2000			; Colour table
	db	0x9f			; R3 Colour table magic value 0x9f
	dw	0x0000			; Pattern table
	db	0x0000>>11		; R4 Pattern table value
	dw	0x3b00			; Sprite attribute table
	db	0x3b00>>7		; R5 Sprite attribute table value
	dw	0x1800			; Sprite pattern table
	db	0x1800>>11		; R6 Sprite pattern table value
	db	0xfc			; R7 White f/gnd, green background

vdp_base_table_hi
	db	VDP_LONGDELAY	; Long delay
	db	%00000010		; R0 - GR2HiRes,No-extvid
	db	%11100000		; R1 - 16K,Disp-enable,Int-enable,8x8,No-mag
	dw	0x3800			; Name table
	db	0x3800>>10		; R2 Name table value
	dw	0x2000			; Colour table
	db	0xff			; R3 Colour table value - always 0xff
	dw	0x0000			; Pattern table
	db	0x03			; R4 Pattern table value - always 0x03
	dw	0x3b00			; Sprite attribute table
	db	0x3b00>>7		; R5 Sprite attribute table value
	dw	0x1800			; Sprite pattern table
	db	0x1800>>11		; R6 Sprite pattern table value
	db	0xf4			; R7 White f/gnd, blue background

vdp_base_table_txt
	db	VDP_SHORTDELAY	; Short delay
	db	%00000000		; R0 - No-extvid
	db	%11110000		; R1 - 16K,Disp-enable,Int-enable,TXT,8x8,No-mag
	dw	0x0800			; Name table
	db	0x0800>>10		; R2 Name table value
	dw	0				; Colour table NA
	db	0				; R3 Colour table value
	dw	0x0000			; Pattern table
	db	0x0000>>11		; R4 Pattern table value
	dw	0				; Sprite attribute table NA
	db	0				; R5 Sprite attribute table value
	dw	0				; Sprite pattern table NA
	db	0				; R6 Sprite pattern table value
	db	0xfd			; R7 White f/gnd, magenta background

mod_sz_vdp_e
