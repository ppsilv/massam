;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  GRAPH.I
;*  This is the definition file for graphics, specifically
;*  The graphics screen handling module.  It is just a
;*  structure definition - but this structure is used to
;*  record the important attributes of a text screen.
;*  Needed because there is both a 40 and 32 columns mode
;*  supported by the VDP, and the screens are not in the
;*  same location.
;*
;**********************************************************

	struct gr_screen
	dw gr_screen_start			; Start of screen memory in VDP
	dw gr_screen_size			; Number of bytes screen occupies
	db gr_screen_w				; Number of columns
	db gr_screen_h				; Number of rows
	db gr_cur_off				; Y offset of cursor image from current position
	db gr_cur_x					; Current X position of cursor
	db gr_cur_y					; Current Y position of cursor
	dw gr_cur_ptr				; VDP address of cursor
	db gr_pixmode				; Pixel plot mode (0=Erase, 1=Plot, 2=XOR)
	db gr_pixmask				; Pixel plot mask
	db gr_pixcol				; Pixel colour
	dw gr_geom_tmp				; One word of temp storage for local use
	end struct