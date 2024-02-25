;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  GRAPH.S
;*  This is the graphics module, to handle text and hires
;*  graphics.  On startup, the BBC DIP settings define
;*  whether the computer will go in to 32 or 40 column
;*  screen mode.  The kernel code calls the right
;*  initialisation code.
;*  For text modes, this module keeps track of where to
;*  next put a character, and also takes care of wrapping
;*  to the next line as well as scrolling the contents up
;*  when the cursor has reached the bottom right.  This
;*  module also enables text input which is echoed to the
;*  screen, to allow interactive input and editing.
;*
;**********************************************************

	; ROM code
	code

mod_sz_graph_s

;****************************************
;* gr_init_screen_common
;* Common screen initialisation code
;* A = Blank character
;****************************************
gr_init_screen_common
	; Store blank char
	sta vdp_blank
	; Save value for cursor
	sta vdp_curval
	
	; VRAM address of screen data
	lda vdp_base+vdp_addr_nme
	sta gr_scrngeom+gr_screen_start
	lda vdp_base+vdp_addr_nme+1
	sta gr_scrngeom+gr_screen_start+1

	; Top left cursor position 0,0
	ldx #0
	stx gr_scrngeom+gr_cur_x
	ldy #0
	sty gr_scrngeom+gr_cur_y

	; Clear screen
	jsr gr_cls

	; Cursor pointer in to screen
	jsr gr_set_cur	
	
	rts

;****************************************
;* gr_init_screen_g1 if A=1 else g2 if A=2
;* initialise the screen in graphic mode 1/2
;****************************************
gr_init_screen_g
	cmp #1
	bne gr_init_screen_skip_g1
	jsr init_vdp_g1
	bra gr_init_screen_cont

gr_init_screen_skip_g1
	jsr init_vdp_g2

gr_init_screen_cont	
	; Size of screen in bytes
	lda #lo(768)					
	sta gr_scrngeom+gr_screen_size
	lda #hi(768)	
	sta gr_scrngeom+gr_screen_size+1

	; Width and height
	lda #32
	sta gr_scrngeom+gr_screen_w
	lda #24
	sta gr_scrngeom+gr_screen_h
	stz gr_scrngeom+gr_cur_off		; No cursor offset

	lda #' '						; Blank is SPACE
	jsr gr_init_screen_common
	rts

;****************************************
;* gr_init_screen_txt
;* initialise the screen in text mode
;****************************************
gr_init_screen_txt
	jsr init_vdp_txt

	; Size of screen in bytes
	lda #lo(960)					
	sta gr_scrngeom+gr_screen_size
	lda #hi(960)	
	sta gr_scrngeom+gr_screen_size+1

	; Width and height
	lda #40
	sta gr_scrngeom+gr_screen_w
	lda #24
	sta gr_scrngeom+gr_screen_h
	stz gr_scrngeom+gr_cur_off		; No cursor offset

	lda #' '						; Blank is SPACE
	jsr gr_init_screen_common

	rts

;****************************************
;* gr_init_hires
;* Input : X = Colour table fill value
;* initialise the screen in hires mode
;****************************************
gr_init_hires
	stx gr_scrngeom+gr_pixcol		; Save pixel colour

	inc vdp_curoff
	
	jsr init_vdp_hires

	; Size of screen in bytes
	lda #lo(6144)					
	sta gr_scrngeom+gr_screen_size
	lda #hi(6144)	
	sta gr_scrngeom+gr_screen_size+1

	; Width and height
	lda #32
	sta gr_scrngeom+gr_screen_w
	lda #192
	sta gr_scrngeom+gr_screen_h
	lda #7
	sta gr_scrngeom+gr_cur_off		; Cursor on bottom row

	; default pixel mode and mask
	lda #1
	sta gr_scrngeom+gr_pixmode
	lda #255
	sta gr_scrngeom+gr_pixmask
	
	sei
	; point to colour table
	ldx vdp_base+vdp_addr_col
	lda vdp_base+vdp_addr_col+1
	jsr vdp_wr_addr
	; set colour for 0x18 pages (6144) bytes
	lda gr_scrngeom+gr_pixcol		; Get the colour value
	ldx #0							; And fill 18 pages
	ldy #0x18						
	jsr vdp_fill_vram

	cli
	
	; Now point screen at pattern for HIRES
	lda vdp_base+vdp_addr_pat
	sta vdp_base+vdp_addr_nme
	lda vdp_base+vdp_addr_pat+1
	sta vdp_base+vdp_addr_nme+1
	
	lda #0							; Blank is ZERO
	jsr gr_init_screen_common
	

	rts

;****************************************
;* gr_init_screen
;* A = Mode (0 = text, Not zero = graphic)
;* initialise the screen in text mode
;****************************************
gr_init_screen
	cmp #0
	bne gr_init_skip_txt
	jmp gr_init_screen_txt
gr_init_skip_txt
	jmp gr_init_screen_g

;****************************************
;* gr_cls
;* Clear the screen
;****************************************
gr_cls
	pha
	phx
	phy

	; Set VDP Address
	sei
	ldx gr_scrngeom+gr_screen_start
	lda gr_scrngeom+gr_screen_start+1
	jsr vdp_wr_addr

	; X and Y count bytes to fill
	ldx #0
	ldy #0
	lda vdp_blank
gr_cls_loop
	jsr vdp_wr_vram
	inx
	bne gr_cls_skipy
	iny
gr_cls_skipy
	cpx gr_scrngeom+gr_screen_size
	bne gr_cls_loop
	cpy gr_scrngeom+gr_screen_size+1
	bne gr_cls_loop
	
	cli
	
	ply
	plx
	pla
	
	rts
	
;****************************************
;* gr_getXY_ptr
;* Get VRAM address of screen from X,Y
;* Input : X, Y = coords
;* Output : X,Y = low and high VRAM address
;* Regs affected : A
;****************************************
gr_getXY_ptr
	; 32 or 40 columns table selection
	lda gr_scrngeom+gr_screen_w
	cmp #40
	bne gr_set_skip_40

	clc
	lda gr_offset_40lo, y
	adc gr_scrngeom+gr_screen_start
	sta gr_scrngeom+gr_geom_tmp
	lda gr_offset_40hi, y
	adc gr_scrngeom+gr_screen_start+1
	sta gr_scrngeom+gr_geom_tmp+1
	bra gr_add_x_offset

gr_set_skip_40
	; 32 byte width window - but what if hi-res (because cursor offset not zero)
	lda gr_scrngeom+gr_cur_off
	bne gr_calc_hires_ptr
	clc
	lda gr_offset_32lo, y
	adc gr_scrngeom+gr_screen_start
	sta gr_scrngeom+gr_geom_tmp
	lda gr_offset_32hi, y
	adc gr_scrngeom+gr_screen_start+1
	sta gr_scrngeom+gr_geom_tmp+1

gr_add_x_offset	
	clc
	txa
	adc gr_scrngeom+gr_geom_tmp
	tax								; vram addr lo in X
	lda gr_scrngeom+gr_geom_tmp+1
	adc #0
	tay								; vram addr hi in Y
	rts
	
gr_calc_hires_ptr
	; Low byte = X&F8 | Y&07
	txa
	and #0xf8
	sta gr_scrngeom+gr_geom_tmp
	tya
	and #0x07
	ora gr_scrngeom+gr_geom_tmp
	tax			; Low address in X
	; High byte = Y>>3
	tya
	lsr a
	lsr a
	lsr a
	tay			; High address in Y
	rts

;****************************************
;* gr_plot
;* Write a byte in the screen pos
;* Input : X,Y = coord, A = Byte to put
;* Output : None
;* Regs affected : All
;****************************************
gr_plot
	pha					; Save byte to put
	jsr gr_getXY_ptr	; vram addr in x,y
	pla					; Get byte to put
	jsr vdp_poke
	rts

;****************************************
;* gr_put
;* Write a byte in the current cursor position
;* Input : A = Byte to put
;* Output : None
;* Regs affected : All
;****************************************
gr_put
	inc vdp_curoff		; Disable cusror
	sta vdp_curval		; Update cursor value
	; Load cursor address
	ldx gr_scrngeom+gr_cur_ptr
	ldy gr_scrngeom+gr_cur_ptr+1
	jsr vdp_poke
	dec vdp_curoff		; Allow cursor flashing
	rts
	
	
;****************************************
;* gr_get
;* Get the byte in the screen pos
;* Input : X,Y = coord
;* Output : X,Y = address, A = peeked byte
;* Regs affected : All
;****************************************
gr_get
	jsr gr_getXY_ptr	; vram addr in x,y
	tya					; hi needs to be in A for peek
	jsr vdp_peek
	rts

;****************************************
;* gr_set_cur
;* Set the cursor position
;* Input : X, Y = position
;* Output : None
;* Regs affected : None
;****************************************
gr_set_cur
	inc vdp_curoff				; Disable cursor
	
	; Save new cursor position
	stx gr_scrngeom+gr_cur_x
	sty gr_scrngeom+gr_cur_y
	
	; First restore what is under the cursor
	lda vdp_curval
	jsr gr_put

	; Now calculate the new cursor vram address
	ldx gr_scrngeom+gr_cur_x
	ldy gr_scrngeom+gr_cur_y
	jsr gr_get					; X,Y=address,A=vram contents
	stx gr_scrngeom+gr_cur_ptr
	sty gr_scrngeom+gr_cur_ptr+1
	sta vdp_curval

	dec vdp_curoff
	
	rts
	

;****************************************
;* gr_hchar
;* Plot a char to hires X,Y coordinates with char code A
;* Input : X,Y = coord, A = Char code
;* Output : None
;* Regs affected : None
;****************************************
gr_hchar
	stx tmp_blo				; Save X coord
	sty tmp_bhi				; Save Y coord
	
	; Calculate font address of char code A in to tmp_clo,hi
	sta tmp_clo
	stz tmp_chi
	; Multiply by 8
	asl tmp_clo
	rol tmp_chi
	asl tmp_clo
	rol tmp_chi
	asl tmp_clo
	rol tmp_chi
	; Add font ROM address
	lda #lo(vdp_font)
	adc tmp_clo
	sta tmp_clo
	lda #hi(vdp_font)
	adc tmp_chi
	sta tmp_chi
	
	; Save 3LSB of x coord
	txa
	and #7
	sta tmp_a
	
	; Generate the shifted character for each line (2 bytes) and write to VDP
	; 16 bytes to store a 2x8 byte shifted image of the character in num_a
	ldx #0	
gr_hchar_shiftline
	; load up a line of font in to 16 bits, left justified A has font data
	lda (tmp_clo)
	inc tmp_clo
	stz ztmp_16+8,x
	; Get 3LSB of x coord in to Y = number of columns to shift
	ldy tmp_a
gr_hchar_shiftcol
	beq gr_hchar_shiftdone		; Branch on Y = 0
	lsr a
	ror ztmp_16+8,x
	dey
	bra gr_hchar_shiftcol
gr_hchar_shiftdone
	sta ztmp_16,x
	inx
	cpx #8						; Do 8 lines each 16 bits wide
	bne gr_hchar_shiftline

	; Ok we have a char image in dram ztmp_16, need merge with VRAM

	inc vdp_curoff				; Disable cursor
	
	; do 8 lines of left image
	ldx #0
gr_hchar_getlimage
	phx					; Save index
	; Get x,y coord and calc address in to tmp_alo
	ldx tmp_blo
	ldy tmp_bhi
	jsr gr_getXY_ptr
	stx tmp_alo
	sty tmp_ahi
	; high need to be in A for peek
	tya
	jsr vdp_peek		; Get image byte from vram
	sta tmp_clo
	plx					; Restore index but don't lose it
	phx
	ldy gr_scrngeom+gr_pixmode		; Get the mode to plot 0,1,2 (erase, draw, xor)
	ora ztmp_16,x		; First assume draw
	cpy #1				; Is that the mode
	beq gr_hchar_getlimage_plot
	eor ztmp_16,x		; Then assume erase
	cpy #0
	beq gr_hchar_getlimage_plot
	lda tmp_clo			; Else we want to EOR
	eor ztmp_16,x		; EOR VRAM with Image
gr_hchar_getlimage_plot
	; Get vram address from tmp_alo
	ldx tmp_alo
	ldy tmp_ahi
	jsr vdp_poke		; Put image on
	inc tmp_bhi			; Update y coord
	plx					; Restore index
	inx
	cpx #8
	bne gr_hchar_getlimage

	sec					; Re-adjust y coord back to top
	lda tmp_bhi
	sbc #8
	sta tmp_bhi
	clc					; Move x coord across to RHS by adding 8
	lda tmp_blo
	adc #8
	sta tmp_blo
	bcs	gr_hchar_skip_rimage	; Don't do RHS if out of bounds
	
	; do 8 lines of right image
	ldx #0
gr_hchar_getrimage
	phx					; Save index
	; Get x,y coord and calc address in to tmp_alo
	ldx tmp_blo
	ldy tmp_bhi
	jsr gr_getXY_ptr
	stx tmp_alo
	sty tmp_ahi
	; high need to be in A for peek
	tya
	jsr vdp_peek		; Get image byte from vram
	sta tmp_clo
	plx					; Restore index but don't lose it
	phx
	ldy gr_scrngeom+gr_pixmode		; Get the mode to plot 0,1,2 (erase, draw, xor)
	ora ztmp_16+8,x		; First assume draw
	cpy #1				; Is that the mode
	beq gr_hchar_getrimage_plot
	eor ztmp_16+8,x		; Then assume erase
	cpy #0
	beq gr_hchar_getrimage_plot
	lda tmp_clo			; Else we want to EOR
	eor ztmp_16+8,x		; EOR VRAM with Image
gr_hchar_getrimage_plot
	; Get vram address from tmp_alo
	ldx tmp_alo
	ldy tmp_ahi
	jsr vdp_poke		; Put image on
	inc tmp_bhi			; Update y coord
	plx					; Restore index
	inx
	cpx #8
	bne gr_hchar_getrimage
gr_hchar_skip_rimage
	dec vdp_curoff				; Enable cursor

	rts

;****************************************
;* gr_point
;* Write a point to the X,Y coordinates
;* Input : X,Y = coord
;* Output : None
;* Regs affected : None
;****************************************
gr_point
	; Save A and X for later
	phx

	; Get hires address from X,Y coordinates
	jsr gr_getXY_ptr
	stx tmp_alo
	sty tmp_ahi

	; A is hi byte for peek
	tya
	
	jsr vdp_peek
	; Save in temp
	sta tmp_blo

	; Get X back and mask off 3 LSBs
	pla
	and #0x07
	; Use this to find the bit number mask and save in temp
	tax
	lda gr_point_mask,x
	sta tmp_bhi
	; Get the mode number in to X
	ldx gr_scrngeom+gr_pixmode
	; load VRAM byte
	lda tmp_blo
	; first assume that we want to set a bit - OR with VRAM
	ora tmp_bhi
	; if that is correct then done
	cpx #1
	beq gr_point_done
	; now assume that actually we want to erase but - EOR with VRAM
	eor tmp_bhi
	; if that is correct then done
	cpx #0
	beq gr_point_done
	; else we want to really just do an eor of VRAM with bit mask
	lda tmp_blo
	eor tmp_bhi
	; so now we have the VRAM bit set properly in temp - poke it back
gr_point_done
	ldx tmp_alo
	ldy tmp_ahi
	jsr vdp_poke

	; now put in the right colour
	; add the x,y offset in to the colour table
	clc
	lda vdp_base+vdp_addr_col
	adc tmp_alo
	tax
	lda vdp_base+vdp_addr_col+1
	adc tmp_ahi
	tay
	lda gr_scrngeom+gr_pixcol
	jsr vdp_poke

	rts
gr_point_mask
	db 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01


;****************************************
;* gr_box
;* Draw a box from x0,y0 -> x1,y1
;* Input :	num_a   = x0
;*			num_a+1 = y0
;*			num_a+2 = x1
;*			num_a+3 = y1
;* Output : None
;* Regs affected : None
;****************************************
gr_box
	lda num_a					; If x0,x1 in same byte column
	and #0xf8					; then special handling
	sta tmp_blo
	lda num_a+2
	and #0xf8
	cmp tmp_blo
	beq gr_box_tiny_width
	; x0, x1 in different byte columns
	lda num_a					; Get lhs mask
	and #7
	tax
	lda gr_box_lmask,x
	sta tmp_blo
	ldx num_a					; Do top left
	ldy num_a+1
	jsr gr_box_plot
	lda tmp_blo
	ldx num_a					; Do bottom left
	ldy num_a+3
	jsr gr_box_plot
	lda num_a+2					; Get rhs mask
	and #7
	tax
	lda gr_box_rmask,x
	sta tmp_blo
	ldx num_a+2					; Do top right
	ldy num_a+1
	jsr gr_box_plot
	lda tmp_blo
	ldx num_a+2					; Do bottom right
	ldy num_a+3
	jsr gr_box_plot
	; Do fast horz lines if x0,x1
	; are in different byte columns
	lda num_a					; Byte align x0
	and #0xf8
	sta tmp_blo
	lda num_a+2					; Byte align x1
	and #0xf8
	sta tmp_bhi
gr_box_8line
	lda tmp_bhi					; Move left 1 column
	sec
	sbc #8
	sta tmp_bhi
	cmp tmp_blo
	beq gr_box_do_vert			; if columns same then done
	ldx tmp_bhi					; Do top from right to left
	ldy num_a+1
	lda #0xff
	jsr gr_box_plot
	ldx tmp_bhi					; Do top from right to left
	ldy num_a+3
	lda #0xff
	jsr gr_box_plot
	bra gr_box_8line			; Looping
gr_box_tiny_width
	lda num_a
	and #7
	pha
	lda num_a+2
	and #7
	tax
	lda gr_box_rmask,x			; Get rhs mask
	plx
	and gr_box_lmask,x			; AND with lhs mask
	sta tmp_blo					; This is the intra column mask
	ldx num_a					; Plot top
	ldy num_a+1
	jsr gr_box_plot
	ldx num_a+2					; Plot bottom
	ldy num_a+3
	cpy num_a+1					; but only if different from top
	beq gr_box_done				; if top=bottom then finished for tiny width
	jsr gr_box_plot
gr_box_do_vert
	; Do the vertical sides of the box
	lda num_a					; Find bit position of x0 (left)
	and #7
	tax							; And get value to write
	lda gr_point_mask,x
	sta tmp_blo
	
	lda num_a+2					; Find bit position of x1 (right)
	and #7
	tax							; And get value to write
	lda gr_point_mask,x
	sta tmp_bhi

	ldy num_a+1					; Get y0 coord and save
	sty num_tmp
gr_box_vert
	inc num_tmp					; Increment y first
	ldy num_tmp
	cpy num_a+3					; if thisY>=y1 then done
	bcs gr_box_vert_done
	ldx num_a					; Do left side
	lda tmp_blo
	jsr gr_box_plot
	ldx num_a+2					; Do right line
	cpx num_a					; Only if not same as lhs
	beq gr_box_skip_rhs
	ldy num_tmp
	lda tmp_bhi
	jsr gr_box_plot
gr_box_skip_rhs
	bra gr_box_vert				; looping
gr_box_vert_done
gr_box_done
	rts

; Box draw common draw routine
; x,y is pixel coord
; a is the value to write
gr_box_plot
	sta tmp_clo					; Save mask to write
	txa
	tya
	jsr gr_getXY_ptr
	phx
	tya							; A=high byte for peek
	jsr vdp_peek				; Get current screen byte
	sta tmp_chi
	ldx gr_scrngeom+gr_pixmode	; Use screen mode
	ora tmp_clo					; Assume mode 1 (or)
	cpx #1						; Done if correct
	beq gr_box_write
	eor tmp_clo					; Assume mode 0 (eor erases or)
	cpx #0						; Done if correct
	beq gr_box_write
	lda tmp_chi					; Else eor with source
	eor tmp_clo
gr_box_write
	plx							; Restore x, y is intact
	jsr vdp_poke				; Poke the value
	clc							; Calculate the colour table offset
	txa							; Low byte
	adc vdp_base+vdp_addr_col
	tax
	tya							; High byte
	adc vdp_base+vdp_addr_col+1
	tay
	lda gr_scrngeom+gr_pixcol	; Colour
	jmp vdp_poke

gr_box_lmask
	db 0xff,0x7f,0x3f,0x1f,0x0f,0x07,0x03,0x01
gr_box_rmask
	db 0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff

	
;****************************************
;* gr_circle
;* Draw a circle centre x0,y0, radius r
;* Input :	num_a   = x0
;*			num_a+1 = y0
;*			num_a+2 = r
;* Output : None
;* Regs affected : None
;****************************************
gr_circle
; Local definitions of temp space to make
; the rest of the code easier to read
grc_x0 	= (num_a)
grc_y0 	= (num_a+1)
grc_r 	= (num_a+2)
grc_x 	= (num_a+3)
grc_y	= (num_b+1)
grc_d	= (num_b+2)

	;x = radius
	lda grc_r
	sta grc_x
	;y = 0
	stz grc_y
	;decision = 1 - x
	lda #1
	sec
	sbc grc_x
	sta grc_d
gr_circle_plot
	;while(x >= y)
	lda grc_x
	cmp grc_y
	bcc gr_circle_done
	;plot 8 points on current x,y
	jsr gr_circle_points
	;y++
	inc grc_y
	;if d<=0
	lda grc_d
	beq gr_circle_d_lte0
	bmi gr_circle_d_lte0
	;else
	;x--
	dec grc_x
	;decision += 2 * (y - x) + 1
	lda grc_y
	sec
	sbc grc_x
	asl a
	clc
	adc #1
	adc grc_d
	sta grc_d
	bra gr_circle_plot	
gr_circle_d_lte0
	;decision += 2 * y + 1
	lda grc_y
	asl a
	clc
	adc #1
	adc grc_d
	sta grc_d
	bra gr_circle_plot	
gr_circle_done
	rts
gr_circle_points
; Local names of temp storage
; to make code easier to read
	;DrawPixel( x + x0,  yh + y0);
	lda grc_x
	clc
	adc grc_x0
	tax
	lda grc_y
	clc
	adc grc_y0
	tay
	jsr gr_point
	;DrawPixel( y + x0,  xh + y0);
	lda grc_y
	clc
	adc grc_x0
	tax
	lda grc_x
	clc
	adc grc_y0
	tay
	jsr gr_point
	;DrawPixel(-x + x0,  yh + y0);
	lda grc_x0
	sec
	sbc grc_x
	tax
	lda grc_y
	clc
	adc grc_y0
	tay
	jsr gr_point
	;DrawPixel(-y + x0,  xh + y0);
	lda grc_x0
	sec
	sbc grc_y
	tax
	lda grc_x
	clc
	adc grc_y0
	tay
	jsr gr_point
	;DrawPixel(-x + x0, -yh + y0);
	lda grc_x0
	sec
	sbc grc_x
	tax
	lda grc_y0
	sec
	sbc grc_y
	tay
	jsr gr_point
	;DrawPixel(-y + x0, -xh + y0);
	lda grc_x0
	sec
	sbc grc_y
	tax
	lda grc_y0
	sec
	sbc grc_x
	tay
	jsr gr_point
	;DrawPixel( x + x0, -yh + y0);
	lda grc_x
	clc
	adc grc_x0
	tax
	lda grc_y0
	sec
	sbc grc_y
	tay
	jsr gr_point
	;DrawPixel( y + x0, -xh + y0);
	lda grc_y
	clc
	adc grc_x0
	tax
	lda grc_y0
	sec
	sbc grc_x
	tay
	jsr gr_point
	rts

	
	
;****************************************
;* gr_line
;* Draw a line from x0,y0 -> x1,y1
;* Input :	num_a   = x0
;*			num_a+1 = y0
;*			num_a+2 = x1
;*			num_a+3 = y1
;* Output : None
;* Regs affected : None
;****************************************
gr_line

; Local definitions of temp space to make
; the rest of the code easier to read
grl_x0 	= (num_a)
grl_y0 	= (num_a+1)
grl_x1 	= (num_a+2)
grl_y1 	= (num_a+3)
grl_dx	= (num_b+1)
grl_dy	= (num_b+2)
grl_xyyx= (num_b+3)
grl_2dx	= (num_x)
grl_2dy	= (num_x+2)
grl_2dxy= (num_tmp)
grl_inx	= (num_tmp+2)
grl_iny = (num_tmp+3)
grl_p	= (num_buf)

	stz grl_xyyx				; Assume normal xy axis
	
;    int dx, dy, p, x, y;
	; check if abs(dy)>abs(dx) if so need to swap xy
	; num_b = abs(x), num_b+1 = abs(dy)
	sec
	lda grl_x1
	sbc grl_x0
	bcs gr_line_skip_dx_neg
	eor #0xff
	inc a
gr_line_skip_dx_neg
	sta grl_dx
	sec
	lda grl_y1
	sbc grl_y0
	bcs gr_line_skip_dy_neg
	eor #0xff
	inc a
gr_line_skip_dy_neg
	sta grl_dy
	cmp grl_dx
	bcc gr_line_skip_xy_swap
	; swap xy axes and also dx and dy
	lda grl_x0					; swap x0 and y0
	ldx grl_y0
	sta grl_y0
	stx grl_x0
	lda grl_x1					; swap x1 and y1
	ldx grl_y1
	sta grl_y1
	stx grl_x1
	lda grl_dx					; swap dy and dx
	ldx grl_dy
	sta grl_dy
	stx grl_dx
	inc grl_xyyx				; set flag to Not Z to know about axis change
	
gr_line_skip_xy_swap	
	; assume going from left to right
	lda #1
	sta grl_inx
	lda grl_x0
	cmp grl_x1
	bcc gr_line_skip_x_swap
	lda #0xff					; make x increment negative
	sta grl_inx
	
gr_line_skip_x_swap
	; assume going from top to bottom
	lda #1
	sta grl_iny
	lda grl_y0
	cmp grl_y1
	bcc gr_line_skip_y_up
	lda #0xff					; make y increment negative
	sta grl_iny

gr_line_skip_y_up
	lda grl_dx
	asl a
	sta grl_2dx					; 2*dx (word)
	stz grl_2dx+1
	rol grl_2dx+1

	lda grl_dy
	asl a
	sta grl_2dy					; 2*dy (word)
	stz grl_2dy+1
	rol grl_2dy+1
	
;    p=2*dy-dx;					; p (word)
	sec
	lda grl_2dy
	sbc grl_dx
	sta grl_p
	lda grl_2dy+1
	sbc #0
	sta grl_p+1
	
;   2*(dy-dx)					; num_tmp+2 = 2*(dy-dx)
	sec
	lda grl_2dy
	sbc grl_2dx
	sta grl_2dxy
	lda grl_2dy+1
	sbc grl_2dx+1
	sta grl_2dxy+1

gr_line_pixel
	; plot the current pixel position
	ldx grl_x0
	ldy grl_y0
	lda grl_xyyx				; is xy swapped?
	beq gr_skip_xy_swap2
	ldx grl_y0
	ldy grl_x0	
gr_skip_xy_swap2
	jsr gr_point
	
	lda grl_x0					; Check if done
	cmp grl_x1
	beq gr_line_done

	; check sign of p
	lda grl_p+1
	bmi gr_line_neg_p

	; if p >=0
	
	; y=y+increment
	clc
	lda grl_y0
	adc grl_iny
	sta grl_y0

	; p=p+2*dy-2*dx
	_addZPWord grl_p,grl_2dxy
	bra gr_line_incx

gr_line_neg_p
	; if p < 0
	; p=p+2*dy
	_addZPWord grl_p,grl_2dy
	
gr_line_incx
	clc
	lda grl_x0
	adc grl_inx
	sta grl_x0
	bra gr_line_pixel
gr_line_done
	rts
	

;    while(x<x1)
;    {
;        if(p>=0)
;        {
;            putpixel(x,y,7);
;            y=y+1;
;            p=p+2*dy-2*dx;
;        }
;        else
;        {
;            putpixel(x,y,7);
;            p=p+2*dy;
;        }
;        x=x+1;
;    }


;****************************************
;* gr_scroll_up
;* Scroll screen one line up
;****************************************
gr_scroll_up
	inc vdp_curoff
	
	; Get VDP Address of line + 1 line (source addr)
	clc
	lda gr_scrngeom+gr_screen_start
	adc gr_scrngeom+gr_screen_w
	sta tmp_alo
	lda gr_scrngeom+gr_screen_start+1
	adc #0
	sta tmp_ahi
	
	; Get destinaton address = first line of screen
	lda gr_scrngeom+gr_screen_start
	sta tmp_blo
	lda gr_scrngeom+gr_screen_start+1
	sta tmp_bhi
	
	ldy gr_scrngeom+gr_screen_h
	dey
	
	sei						; Stop IRQ as it messes with VDP
	; Only use vdp primitives inside sei,cli

	; Restore what was underneath cursor
	ldx gr_scrngeom+gr_cur_ptr
	lda gr_scrngeom+gr_cur_ptr+1
	jsr vdp_wr_addr
	lda vdp_curval
	jsr vdp_wr_vram

gr_scroll_cpy_ln
	; Set VDP with source address to read
	ldx tmp_alo
	lda tmp_ahi
	jsr vdp_rd_addr

	; Read in a line worth of screen
	ldx gr_scrngeom+gr_screen_w
gr_scroll_read_ln
	jsr vdp_rd_vram
	sta scratch,x
	dex
	bne gr_scroll_read_ln

	; Set VDP with destinaton to write
	ldx tmp_blo
	lda tmp_bhi
	jsr vdp_wr_addr
	
	; Write out a line worth of screen
	ldx gr_scrngeom+gr_screen_w
gr_scroll_write_ln
	lda scratch,x
	jsr vdp_wr_vram
	dex
	bne gr_scroll_write_ln

	; Update source address
	clc
	lda tmp_alo
	adc gr_scrngeom+gr_screen_w
	sta tmp_alo
	lda tmp_ahi
	adc #0
	sta tmp_ahi
	; Update destinaton address
	clc
	lda tmp_blo
	adc gr_scrngeom+gr_screen_w
	sta tmp_blo
	lda tmp_bhi
	adc #0
	sta tmp_bhi

	; One line complete
	dey
	bne gr_scroll_cpy_ln
	
	; VDP is pointing at last line
	; Needs to be filled with blank
	lda vdp_blank
	sta vdp_curval			; Also this is the cursor value
	ldx gr_scrngeom+gr_screen_w
gr_scroll_erase_ln
	jsr vdp_wr_vram
	dex
	bne gr_scroll_erase_ln

	cli			; Enable IRQ

	dec vdp_curoff

	rts

;****************************************
;* gr_cur_right
;* Advance cursor position
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_right
	_pushAXY
	; Load cursor x,y position
	ldx gr_scrngeom+gr_cur_x
	ldy gr_scrngeom+gr_cur_y

	; Move cursor right
	inx
	; Check if reached past edge of line
	cpx gr_scrngeom+gr_screen_w
	bne gr_adv_skip_nl
	; If got here then wrap to next line
	ldx #0
	iny
	cpy gr_scrngeom+gr_screen_h
	bne gr_adv_skip_nl
	; If got here then screen needs to scroll
	dey					; First put y back in bound
	phx
	phy
	jsr gr_scroll_up
	ply
	plx
gr_adv_skip_nl
	jsr gr_set_cur
	_pullAXY
	rts

;****************************************
;* gr_cur_left
;* Advance cursor left
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_left
	_pushAXY
	; Load cursor x,y position, load X last to check for 0
	ldy gr_scrngeom+gr_cur_y
	ldx gr_scrngeom+gr_cur_x
	
	; Decrement screen pointer
	; Move cursor left
	bne gr_cur_skip_at_left		; If already at the left
	cpy #0						; If already at the top left
	beq gr_cur_skip_at_tl
	dey
	ldx gr_scrngeom+gr_screen_w
gr_cur_skip_at_left
	dex
	jsr gr_set_cur

gr_cur_skip_at_tl	
	_pullAXY
	rts

;****************************************
;* gr_cur_up
;* Advance cursor up
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_up
	_pushAXY
	; Load cursor x,y position, load Y last to check for zero
	ldx gr_scrngeom+gr_cur_x
	ldy gr_scrngeom+gr_cur_y
	
	beq gr_cur_skip_at_top	; If already at the top, don't do anything
	dey
	jsr gr_set_cur
	
gr_cur_skip_at_top	
	_pullAXY
	rts

;****************************************
;* gr_cur_down
;* Advance cursor down
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_cur_down
	_pushAXY
	; Load cursor x,y position
	ldx gr_scrngeom+gr_cur_x
	ldy gr_scrngeom+gr_cur_y
	iny
	cpy gr_scrngeom+gr_screen_h			; If already at  bottom
	beq gr_cur_skip_at_bot				; then don't do anything
	
	jsr gr_set_cur

gr_cur_skip_at_bot
	_pullAXY
	rts


;****************************************
;* gr_new_ln
;* Carry out a new line
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_new_ln
	_pushAXY
	; X pos is zero, Y needs to increment
	ldx #0
	ldy gr_scrngeom+gr_cur_y
	iny
	cpy gr_scrngeom+gr_screen_h
	bne gr_nl_skip_nl
	; If got here then screen needs to scroll
	dey
	phx
	phy
	jsr gr_scroll_up
	ply
	plx
gr_nl_skip_nl
	jsr gr_set_cur
	_pullAXY
	rts
	
;****************************************
;* gr_del
;* Action del
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
gr_del
	_pushAXY
	jsr gr_cur_left
	lda #' '							; Put a space
	jsr gr_put
	_pullAXY
	rts


;****************************************
;* gr_get_key
;* Waits for a key press, C=1 synchronous
;* A = Key code
;****************************************
gr_get_key
	jsr kb_get_key
	bcs gr_key_no_key
	cmp #UTF_ACK						; Copy key pressed?
	bne gr_not_copy
	lda vdp_curval						; If yes the get char under cursor
gr_not_copy
	clc
gr_key_no_key
	rts	
	
;****************************************
;* gr_put_byte
;* Put a byte out
;* Input : A = Byte to put
;* Output : None
;* Regs affected : None
;****************************************
gr_put_byte
	cmp #UTF_DEL			; Del key
	beq gr_process_special
	cmp #32					; Special char?
	bcs gr_pb_notspecial	; >=32 == carry clear

gr_process_special
	cmp #UTF_CR				; New line?
	bne gr_skip_new_ln
	jmp gr_new_ln
gr_skip_new_ln
	cmp #UTF_DEL			; Delete?
	bne gr_skip_del
	jmp gr_del
gr_skip_del
	cmp #CRSR_LEFT
	bne gr_skip_left
	jmp gr_cur_left
gr_skip_left
	cmp #CRSR_RIGHT
	bne gr_skip_right
	jmp gr_cur_right
gr_skip_right
	cmp #CRSR_UP
	bne gr_skip_up
	jmp gr_cur_up
gr_skip_up
	cmp #CRSR_DOWN
	bne gr_skip_down
	jmp gr_cur_down
gr_skip_down
	cmp #UTF_FF
	bne gr_skip_cls
	jmp gr_cls
gr_skip_cls
	rts

;	Normal caracter processing here.
gr_pb_notspecial
	_pushAXY
	
	; Place in current position and move right
	jsr gr_put
	jsr gr_cur_right

	_pullAXY
	
	rts

;* These tables are to speed up calculating the 
;* offset for plot commands, rather than using
;* a series of left shifts and additions.
;* Not sure if it is worth the 96 bytes :-O
gr_offset_40lo
	db lo(0*40), lo(1*40), lo(2*40), lo(3*40)
	db lo(4*40), lo(5*40), lo(6*40), lo(7*40)
	db lo(8*40), lo(9*40), lo(10*40), lo(11*40)
	db lo(12*40), lo(13*40), lo(14*40), lo(15*40)
	db lo(16*40), lo(17*40), lo(18*40), lo(19*40)
	db lo(20*40), lo(21*40), lo(22*40), lo(23*40)
gr_offset_40hi
	db hi(0*40), hi(1*40), hi(2*40), hi(3*40)
	db hi(4*40), hi(5*40), hi(6*40), hi(7*40)
	db hi(8*40), hi(9*40), hi(10*40), hi(11*40)
	db hi(12*40), hi(13*40), hi(14*40), hi(15*40)
	db hi(16*40), hi(17*40), hi(18*40), hi(19*40)
	db hi(20*40), hi(21*40), hi(22*40), hi(23*40)
gr_offset_32lo
	db lo(0*32), lo(1*32), lo(2*32), lo(3*32)
	db lo(4*32), lo(5*32), lo(6*32), lo(7*32)
	db lo(8*32), lo(9*32), lo(10*32), lo(11*32)
	db lo(12*32), lo(13*32), lo(14*32), lo(15*32)
	db lo(16*32), lo(17*32), lo(18*32), lo(19*32)
	db lo(20*32), lo(21*32), lo(22*32), lo(23*32)
gr_offset_32hi
	db hi(0*32), hi(1*32), hi(2*32), hi(3*32)
	db hi(4*32), hi(5*32), hi(6*32), hi(7*32)
	db hi(8*32), hi(9*32), hi(10*32), hi(11*32)
	db hi(12*32), hi(13*32), hi(14*32), hi(15*32)
	db hi(16*32), hi(17*32), hi(18*32), hi(19*32)
	db hi(20*32), hi(21*32), hi(22*32), hi(23*32)
	
mod_sz_graph_e

