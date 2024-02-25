;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  RTSUBS.S
;*  Module that implements the runtime execution of dflat
;*  keywords and functions.
;*  So this is where most of the action is for runtime, when
;*  a line is being executed, the dflat runtime controller
;*  jumps through the runtime table to routines here.
;*  Every dflat statement begins with a token (ignoring any
;*  whitespace), even the implicit assignment and procedure
;*  invocation.
;*
;**********************************************************

	; ROM code
	code  

mod_sz_rtsubs_s

	include "dflat\numop.s"

df_rt_monitor
	jsr _command_line
	rts
	
df_rt_new
	jmp df_clear
	
df_rt_while
	; push statement address
	jsr df_rt_push_stat
	; DFRT_WHILE token
	lda #DFRT_WHILE
	jsr df_st_pushByte

	; get value in A,X
	jsr df_rt_getnval

	; if value<>0 then continue
	cpx #0
	beq df_rt_while_done
	rts
df_rt_while_done
	; pop while data off stack as not needed
	jsr df_st_popByte
	jsr df_st_popByte
	jsr df_st_popWord
	; while evaluated false so find wend
	; but check for any nested while/wends
	; nest = 1 to start
	lda df_ifnest
	pha
	lda #1
	sta df_ifnest
	; find the matching else/elseif/endif
	; start from current statement
	_cpyZPWord df_currlin,df_nextlin
df_rt_findwend
	ldx df_nextlin
	lda df_nextlin+1
	ldy df_curstidx
	jsr df_rt_nextstat
	; got to end of program, then a problem
	bcs df_rt_wend_end
	stx df_nextlin
	sta df_nextlin+1
	sty df_curstidx
	; find the command token
df_rt_while_cmd
	iny
	lda (df_nextlin),y
	bpl df_rt_while_cmd
	; check for wend
	cmp #DFRT_WEND
	bne df_rt_check_while
	; decrement nest
	dec df_ifnest
	; if not zero then go find more commands
	bne df_rt_findwend
	; else found it, restore if nest
	; and skip the wend statement
	pla
	sta df_ifnest
	ldx df_nextlin
	lda df_nextlin+1
	ldy df_curstidx
	jsr df_rt_nextstat
	; got to end of program, then a problem
	bcs df_rt_wend_end
	; need to update nxtstidx to transfer control
	stx df_nextlin
	sta df_nextlin+1
	sty df_nxtstidx	
	rts
df_rt_check_while
	; check for while
	cmp #DFRT_WHILE
	bne df_rt_findwend
	; if while found then increment nest
	inc df_ifnest
	bra df_rt_findwend
df_rt_wend_end
	SWBRK DFERR_IMMEDIATE

df_rt_wend
	jsr df_st_popByte
	cmp #DFRT_WHILE
	bne df_rt_wend_err
	; pop the stat and continue
	jsr df_st_popWord
	stx	df_nextlin
	sta df_nextlin+1
	jsr df_st_popByte
	sta df_nxtstidx
	rts
df_rt_wend_err
	SWBRK DFERR_WEND

;move to next statement during if/else matching
;end of program is an error
df_rt_if_stat
	ldx df_nextlin
	lda df_nextlin+1
	ldy df_curstidx
	jsr df_rt_nextstat
	; got to end of program, then a problem
	bcs df_rt_if_stat_err
	stx df_nextlin
	sta df_nextlin+1
	sty df_curstidx
	sty df_nxtstidx
	rts
; program ended with no match
df_rt_if_stat_err
	SWBRK DFERR_UNCLOSEDIF
	
; find matching else/elseif/endif
; C = 0 match else/elseif/endif
; C = 1 match endif only
; endif is always matched
; ** MAKE SURE NEXTLIN IS POPULATED! **
df_rt_if_match
	; save the current if nest level
	lda df_ifnest
	pha
	; local if nest level is zero to start with
	stz df_ifnest	
	; save match pref
	php
	; find the matching else/elseif/endif
	; start from df_nextlin, df_curstidx
df_rt_findelseendif
	jsr df_rt_if_stat
	; find command
df_rt_ifcmd
	iny
	lda (df_nextlin),y
	bpl df_rt_ifcmd
	; check for endif
	cmp #DFRT_ENDIF
	beq df_rt_ifelse

	plp
	php
	
	bcs df_rt_ifskipelseif
	cmp #DFRT_ELSE
	beq df_rt_ifelse
	cmp #DFRT_ELSEIF
	beq df_rt_ifelse
df_rt_ifskipelseif
	; another if token found - increment lcoal if nest level
	cmp #DFRT_IF
	bne df_rt_skipnestif
	inc df_ifnest
df_rt_skipnestif
	; no tokens of interest found, so next statement
	bra df_rt_findelseendif
	
	; found else/elseif/endif
	; but check if this is nested
df_rt_ifelse
	; nest counter zero then found matching else/elseif/endif
	ldx df_ifnest
	beq df_rt_if_found
	; endif token found so decrement local nest
	cmp #DFRT_ENDIF
	bne df_rt_skipnestendif
	dec df_ifnest
df_rt_skipnestendif	
	; continue to search for else/endif
	bra df_rt_findelseendif
	; ok got a match
df_rt_if_found
	; remove pref
	plp
	; restore global if nest
	plx
	stx df_ifnest

	;A contains the token found, Y is index in to df_nextlin of cmd
;	clc
	rts

df_rt_endif
	; decrement if next level
	dec df_ifnest
	bmi df_rt_noif_err
;	clc
	rts
	
	; else and ifelse encountered in a normal sequence
	; only happens when the clause has been executed
	; so we only now need to find the endif
df_rt_elseif
df_rt_else
	; not in if mode then error
	lda df_ifnest
	beq df_rt_noif_err
	; find endif only
	; starting from current line and curstidx
	_cpyZPWord df_currlin,df_nextlin
	sec
	jmp df_rt_if_match

; endif/else/elseif encountered outside of an if	
df_rt_noif_err
	SWBRK DFERR_NOIF
	
	; when if is encountered, the job of this routine is
	; to determine which clause to execute, then transfer
	; program control to that point.  in normal program
	; sequence else/elseif statements will signify the end
	; of an if construct.
df_rt_if
	; increment global if nest counter
	inc df_ifnest
df_rt_ifeval
	; get value
	jsr df_rt_getnval
	; if value<>0 if is successful then continue normal sequence
	cmp #0
	bne df_rt_if_done
	cpx #0
	bne df_rt_if_done
	; got here then if clause evaluated to false
	; match with else/elseif/endif
	; df_nextlin is used to find the clause to execute
	_cpyZPWord df_currlin,df_nextlin
	clc						
	jsr df_rt_if_match
	; A contains the token found, Y is index of this token

	cmp #DFRT_ELSE
	; else: df_nextlin and df_nxtstidx points to the stat
	beq df_rt_do_else

	cmp #DFRT_ENDIF
	; else: df_nextlin and df_nxtstidx points to the stat
	beq df_rt_if_done

	; elif detected - increment past the token and evaluate like if
	; make this the current line and token index
	_cpyZPWord df_nextlin,df_currlin
	; move past the token and save position
	iny
	phy
	; initialise statement pointer
	ldy df_curstidx
	ldx df_currlin
	lda df_currlin+1
	jsr df_rt_init_stat_ptr
	; restore Y (one byte past the token) and save in exeoff
	ply
	sty df_exeoff
	; don't force a jump as we've initalised all vars here
	stz df_nextlin+1
	; now everyting is set up to evaluate the elif condition
	bra df_rt_ifeval
	
df_rt_do_else
	; we need to point to the next statement not this one
	jsr df_rt_if_stat
df_rt_if_done
;	clc
	rts
	
df_rt_for
	; push statement address to rt stack
	jsr df_rt_push_stat
	; get lvar
	jsr df_rt_getlvar
	; Save lvar pointer
	pha
	phx
	inc df_exeoff

	; find starting value
	jsr df_rt_findescval
	; evaluate the starting value
	; can't use df_rt_getnval as need to use A,X first
	jsr df_rt_neval
	; get ready to update the counter
	plx
	stx df_tmpptra
	pla
	sta df_tmpptra+1
	pha
	phx
	; get the starting value from op stack
	jsr df_st_popInt
	; save it to counter slot
	ldy #1
	sta (df_tmpptra),y
	txa
	dey
	sta (df_tmpptra)

	; find end value
	jsr df_rt_findescval
	; evaluate the end value
	jsr df_rt_getnval
	; and put on rt stack
	jsr df_st_pushWord

	; find step value
	jsr df_rt_findescval
	; evaluate the end value
	jsr df_rt_getnval
	; and push on rt stack
	jsr df_st_pushWord
	; save the counter slot address
	plx
	pla
	jsr df_st_pushWord
	; all done - counter set to start
	; stack contains counter slot, step val, end val, next stat
	; now push for token
	lda #DFRT_FOR
	jmp df_st_pushByte
;	rts

df_rt_next
	; remember stack position
	ldy df_rtstop
	phy
	jsr df_st_popByte
	cmp #DFRT_FOR
	bne df_rt_next_err
	; get the slot address
	jsr df_st_popWord
	; save address to ptrd, contents to ptra
	stx df_tmpptrd
	sta df_tmpptrd+1
	lda (df_tmpptrd)
	sta df_tmpptra
	ldy #1
	lda (df_tmpptrd),y
	sta df_tmpptra+1
	
	; get step value, save in ptrb
	jsr df_st_popWord
	stx df_tmpptrb
	sta df_tmpptrb+1

	; add step to counter and save back to counter
	_addZPWord df_tmpptra,df_tmpptrb
	lda df_tmpptra
	sta (df_tmpptrd)
	ldy #1
	lda df_tmpptra+1
	sta (df_tmpptrd),y
	
	; get end value, save in ptrb
	jsr df_st_popWord
	stx df_tmpptrb
	sta df_tmpptrb+1
	
	; call lte operation but no need to get ints
	; as already in ptra and ptrb
	jsr df_rt_lte_calc
	; check if true or false
	jsr df_st_popInt
	cpx #0
	; if false then next is done
	beq df_next_done
	; else we continue
	jmp df_rt_pop_stat_go
	; if done, then continue with next statement
df_next_done
	jmp df_rt_untilnext_done
	
df_rt_next_err
	SWBRK DFERR_NEXTFOR

	
df_rt_repeat
	; push statement address
	jsr df_rt_push_stat
	; DFRT_REPEAT token
	lda #DFRT_REPEAT
	jmp df_st_pushByte
;	rts
	
df_rt_until
	; remember stack position
	ldy df_rtstop
	phy
	jsr df_st_popByte
	cmp #DFRT_REPEAT
	bne df_rt_until_err
	; evaluate expression in to A,X
	jsr df_rt_getnval
	; if value<>0 then continue
	cpx #0
	bne df_rt_untilnext_done

	; pop the stat and continue
	jmp df_rt_pop_stat_go

df_rt_untilnext_done
	ply
	; pop 2 items off stack (line address, index)
	jsr df_st_popWord
	jmp df_st_popByte
	; and continue
;	clc
;	rts

df_rt_until_err
	SWBRK DFERR_UNTIL
	
df_rt_sadd
;	clc
	rts
	
df_rt_print_num
	jsr df_st_popInt
	clc
	jmp print_a_to_d
;	rts
	
df_rt_print_str
	jsr df_st_popStr
	stx df_tmpptra
	sta df_tmpptra+1
	ldy #0
df_rt_print_str_ch
	lda (df_tmpptra),y
	beq df_rt_print_str_done
	jsr io_put_ch
	iny
	bra df_rt_print_str_ch
df_rt_print_str_done
;	clc
	rts

; * Find the position of the next data item to read
df_rt_nextdatum
	; load data line offset
	ldy df_datoff 
	; if data pointer unitialised (because high byte == 0)
	lda df_currdat+1
	bne df_rt_skipinitdataptr
	; then start at program beginning
	_cpyZPWord df_prgstrt,df_currdat
df_rt_datlinstart
	; if end of program then error
	lda (df_currdat)
	beq df_rt_datumerr
	; index in to first line byte
	ldy #3
	sty df_datoff
	; find first 'data' statement
df_rt_datastatement
	iny
	tya
	; end of line reached?
	cmp (df_currdat)
	; if not find data token
	bne df_rt_getdatatk
df_rt_datnextlin
	; if so then go to next line
	clc
	lda df_currdat
	adc (df_currdat)
	sta df_currdat
	lda df_currdat+1
	adc #0
	sta df_currdat+1
	bra df_rt_datlinstart
df_rt_getdatatk
	lda (df_currdat),y
	bpl df_rt_datastatement
	; found data statement?
	cmp #DFRT_DATA
	; if not then go to next line	
	bne df_rt_datnextlin
	sty df_datoff	
df_rt_skipinitdataptr
	tya
	; end of line reached?
	cmp (df_currdat)
	; if so go to next line
	beq df_rt_datnextlin
	; else see if escape value
	lda (df_currdat),y
	cmp #DFTK_ESCVAL
	iny
	bcs df_rt_skipinitdataptr
	; ok found an escape value
	; save position and return
	dey
	sty df_datoff
;	clc
	rts
df_rt_datumerr
	SWBRK DFERR_NODATA

; read a datum
df_rt_readdatum
	; update data pointer to next data item
	jsr df_rt_nextdatum

	; now get lvar X,A from current statement
	jsr df_rt_getlvar
	; save lvar in tmpb, vvt ptr in tmpa
	stx df_tmpptrb
	sta df_tmpptrb+1
		
	; first save save current prgoram line and offset
	lda df_currlin
	pha
	lda df_currlin+1
	pha
	lda df_exeoff
	pha
	lda df_eolidx
	pha
	lda df_nxtstidx
	pha
	lda df_curstidx
	pha

	; use data pointer as current position for evalution routines
	_cpyZPWord df_currdat,df_currlin
	lda df_datoff
	sta df_exeoff
	lda (df_currdat)
	sta df_eolidx
	stz df_nxtstidx
	lda #3
	sta df_curstidx
	
	; get type from vvt ptr in tmpa
	lda (df_tmpptra)
	tay
	; get lvar point from tmpb
	ldx df_tmpptrb
	lda df_tmpptrb+1
	
	; X,A and Y set up, now evaluate and perform assignment
	jsr df_rt_doassign

	; update data offset as data has been consumed
	lda df_exeoff
	sta df_datoff
	; restore line settings
	pla
	sta df_curstidx
	pla
	sta df_nxtstidx
	pla
	sta df_eolidx
	pla
	sta df_exeoff
	pla
	sta df_currlin+1
	pla
	sta df_currlin
	rts


df_rt_read
	; find variable to read in to from current position
	ldy df_exeoff
df_rt_read_find_var
	iny
	; if end of line or statement then done
	cpy df_eolidx
	beq df_rt_read_done
	cpy df_nxtstidx
	beq df_rt_read_done
	; if not found escape then next byte
	lda (df_currlin),y
	cmp #DFTK_ESCVAL
	bcs df_rt_read_find_var
	; ok found escape, save position
	sty df_exeoff
	; go and read in the value
	jsr df_rt_readdatum
	; try find another variable
	bra df_rt_read

df_rt_read_done
	; save position
	sty df_exeoff
	rts

df_rt_input
	; df_tmpptra has the vvt address, X,A is the lvar ptr
	jsr df_rt_getlvar
	; Save lvar pointer
	stx df_tmpptrb
	sta df_tmpptrb+1
	; go read a line of input
	; buf_lo ptr has the input, Y is size
	sec
	jsr io_read_line
	; check the type
	lda (df_tmpptra)
	and #DFVVT_STR
	bne df_rt_input_str
	lda (df_tmpptra)
	and #DFVVT_INT|DFVVT_BYT
	bne df_rt_input_num
	; if not int or byte then error
	bra df_rt_input_err
df_rt_input_str
	lda (buf_lo),y
	sta (df_tmpptrb),y
	dey
	bpl df_rt_input_str
;	clc
	rts

df_rt_input_num
	; X,A = address, linbuff must be on page boundary
	lda buf_lo+1
	ldx buf_lo
	ldy #0				; any numeric format
	jsr con_n_to_a
	bcs df_rt_input_err
	ldy #0
	lda num_a
	sta (df_tmpptrb),y
	iny
	lda num_a+1
	sta (df_tmpptrb),y
;	clc
	rts
df_rt_input_err
	SWBRK DFERR_TYPEMISM
	
df_rt_local
	; get current local count off rt stack
	jsr df_st_popByte
	; save on pc stack for incrmenting
	pha
	ldy df_exeoff
	dey
df_rt_local_findesc
	iny
	; check end of line
	cpy df_eolidx
	beq df_rt_local_done
	cpy df_nxtstidx
	beq df_rt_local_done
	; find a var
	lda (df_currlin),y
	cmp #DFTK_VAR
	bne df_rt_local_findesc
	; jump over escape value
	iny
	; get var index
	lda (df_currlin),y
	sty df_exeoff
	; localise this variable
	jsr df_rt_proc_local
	; increment local counter
	pla
	inc a
	pha
	ldy df_exeoff
	bra df_rt_local_findesc
df_rt_local_done
	; get the local counter
	; put on to rt stack
	pla
	jmp df_st_pushByte
;	clc
;	rts
	
df_rt_dim
	ldy df_exeoff
	dey
df_rt_dim_findesc
	; check end of line
	iny
	cpy df_eolidx
	beq df_rt_dim_done
	cpy df_nxtstidx
	beq df_rt_dim_done
	; find a var
	lda (df_currlin),y
	cmp #DFTK_VAR
	bne df_rt_dim_findesc
	; jump over escape value
	iny
	; get var index
	lda (df_currlin),y
	; move to open bracket
	iny
	sty df_exeoff
	; Calcuate VVT slot address in to tmpa
	jsr df_var_addr
	; check if already dim'd
	ldy #DFVVT_DIM1
	lda (df_tmpptra),y
	bne df_rt_dim_err
	; Save slot address found earlier
	lda df_tmpptra
	pha
	lda df_tmpptra+1
	pha
	jsr df_rt_arry_parm2
	; Restore slot address
	pla
	sta df_tmpptra+1
	pla
	sta df_tmpptra
;	bcs df_rt_dim_err
	; save x,y to dim1,2
	phy
	phx
	ldy #DFVVT_DIM1
	pla
	sta (df_tmpptra),y
	iny
	pla
	sta (df_tmpptra),y	
df_rt_dim_alloc
	; ok we have up to 2 dimensions
	; mult dim 1 and 2 if dim 2 <> 0
	ldy #DFVVT_DIM1
	lda (df_tmpptra),y
	sta num_a
	stz num_a+1
	iny
	lda (df_tmpptra),y
	bne df_rt_dim2_nz
	lda #1
df_rt_dim2_nz
	sta num_b
	stz num_b+1
	jsr int_fast_mult
	; check the type if int then mult2
	lda (df_tmpptra)
	and #DFVVT_INT
	beq df_rt_dim2_mul2
	asl num_a
	rol num_a+1
df_rt_dim2_mul2	
	; finally, we have a size of array
	ldx num_a
	lda num_a+1

	; get a block of that size from heap
	jsr df_st_malloc
	; save pointer to block in var
	ldy #DFVVT_HI
	sta (df_tmpptra),y
	txa
	dey
	sta (df_tmpptra),y
	; finally, update the type to indicate array
	lda (df_tmpptra)
	ora #DFVVT_ARRY
	sta (df_tmpptra)
	; don't increment byte again - go check for more vars
	bra df_rt_dim	
df_rt_dim_next_byte
	inc df_exeoff
	bra df_rt_dim
df_rt_dim_done
;	clc
	rts
df_rt_dim_err
	SWBRK DFERR_DIM

df_rt_cls
	; set cursror position to top left first
	ldx #0
	ldy #0
	jsr _gr_set_cur
	jmp _gr_cls
;	clc
;	rts
	
df_rt_plot
	; evaluate the expression
	jsr df_rt_getnval
	; save lo byte
	phx
	; jump over comma
	inc df_exeoff
	; evaluate the expression
	jsr df_rt_getnval
	; save lo byte
	phx
	; jump over comma
	inc df_exeoff
	; evaluate the expression
	jsr df_rt_neval
	; check the type on the stack
	jsr df_st_peekType
	; if >=0x80 then a pointer / string
	cpy #0x80
	bcs df_rt_plotstr
	; else it is int
	jsr df_st_popInt
	; put low byte of pop result in a
	txa
	; get y and x in that order
	ply
	plx
	jmp _gr_plot
;	clc
;	rts

df_rt_plotstr
	; pop string pointer
	jsr df_st_popPtr
	; save pointer to tmpa
	stx df_tmpptra
	sta df_tmpptra+1
	; get y and x in that order
	ply
	plx
	; set cursror position
df_rt_plotstrch
	lda (df_tmpptra)
	beq df_rt_plotstrdone
	_incZPWord df_tmpptra
	phx
	phy
	jsr _gr_plot
	ply
	plx
	inx
	bra df_rt_plotstrch
df_rt_plotstrdone
;	clc
	rts
	
df_rt_cursor
	; evaluate the expression
	jsr df_rt_getnval
	; write low byte of vdp_curoff
	; by writing a zero then cursor on else not
	stx vdp_curoff
;	clc
	rts
		
df_rt_himem
	; evaluate the expression
	jsr df_rt_getnval
	; write X,A to df_memtop
	stx df_memtop
	sta df_memtop+1
	; now clear everything down
	jmp df_clear
	rts

df_rt_mode
	; evaluate the expression
	jsr df_rt_getnval
	; only interested in low byte
	txa
	jmp _gr_init_screen
;	clc
;	rts

df_rt_hires
	; evaluate the expression X = colour fg/bg
	jsr df_rt_getnval
	jmp _gr_init_hires
;	clc
;	rts
	
df_rt_pixmode
	; evaluate the expression X = mode
	jsr df_rt_getnval
	stx gr_scrngeom+gr_pixmode
;	clc
	rts

df_rt_pixmask
	; evaluate the expression X = mask
	jsr df_rt_getnval
	stx gr_scrngeom+gr_pixmask
;	clc
	rts

df_rt_pixcol
	; evaluate the expression X = col
	jsr df_rt_getnval
	stx gr_scrngeom+gr_pixcol
;	clc
	rts

df_rt_point
	jsr df_rt_parm_2ints
	ldx df_tmpptra
	ldy df_tmpptrb
	jmp _gr_point
;	clc
;	rts

df_rt_circle
	jsr df_rt_parm_3ints
	lda df_tmpptra				; load x0
	sta num_a
	lda	df_tmpptrb				; load y0
	sta num_a+1
	lda df_tmpptrc				; load r
	sta num_a+2
	jmp _gr_circle

df_rt_line
	jsr df_rt_parm_4ints
	lda df_tmpptra				; load x0
	sta num_a
	lda	df_tmpptrb				; load y0
	sta num_a+1
	lda df_tmpptrc				; load x1
	sta num_a+2
	lda df_tmpptrd				; load y1
	sta num_a+3
	jmp _gr_line

df_rt_box
	jsr df_rt_parm_4ints
	lda df_tmpptra				; load x0
	sta num_a
	lda	df_tmpptrb				; load y0
	sta num_a+1
	lda df_tmpptrc				; load x1
	sta num_a+2
	lda df_tmpptrd				; load y1
	sta num_a+3
	jmp _gr_box

df_rt_hplot
	jsr df_rt_parm_3ints
	ldx df_tmpptra
	ldy df_tmpptrb
	lda df_tmpptrc
	jmp _gr_hchar

df_rt_shape
	jsr df_rt_parm_3ints
	ldx df_tmpptra				; load x
	phx
	ldy	df_tmpptrb				; load y
	phy
	ldx df_tmpptrc				; load coords[]
	lda df_tmpptrc+1			; load coords[]
	jsr df_st_pushWord
df_rt_shapeLoop
	jsr df_st_popWord			; Get pointer
	stx df_tmpptra
	sta df_tmpptra+1
	lda (df_tmpptra)			; Get X coord as int
	sta tmp_alo
	ldy #1
	lda (df_tmpptra),y			; Get X hi byte
	sta tmp_ahi
	iny
	lda (df_tmpptra),y			; Get Y coord as int
	sta tmp_blo
	iny
	lda (df_tmpptra),y			; Get Y hi byte
	sta tmp_bhi
	lda tmp_alo					; If X and Y low are zero then end
	bne df_rt_shapeCalc
	lda tmp_blo
	bne df_rt_shapeCalc
	; Got here then must be finished
	pla							; Pop bytes off 6502 stack
	pla
	rts
df_rt_shapeCalc
	clc
	lda df_tmpptra				; Increment coord pointer 
	adc #4						; 2 ints is 4 bytes per coord
	tax
	lda df_tmpptra+1
	adc #0
	jsr df_st_pushWord			; Put pointer on runtime stack
	; previous cursor is starting position
	; plus delta is new position
	pla							; get y0 off stack
	clc
	sta num_a+1
	adc tmp_blo
	sta num_a+3					; y1 = y0+dy
	tax							; save y1 in X reg
	pla							; get x0 off stack
	clc
	sta num_a					; x0
	adc tmp_alo
	sta num_a+2					; x1
	pha							; save x1
	phx							; save y1
	jsr _gr_line				; line x0,y0,x1,y1
	bra df_rt_shapeLoop			; go back to next coord
	
df_rt_wait
	; evaluate the expression
	jsr df_rt_getnval
	; put high byte in to Y (X,Y)=16 bits
	tay
df_rt_wait_counter
	; get vdp low byte timer val in A
	lda vdp_cnt	
df_rt_wait_tick
	; check if a tick has occurred (i.e. val <> A)
	cmp vdp_cnt
	beq df_rt_wait_tick
	; countdown tick
	dex
	cpx #0xff
	bne df_rt_wait_skiphi
	dey
df_rt_wait_skiphi
	cpx #0
	bne df_rt_wait_counter
	cpy #0
	bne df_rt_wait_counter
	rts
	
df_rt_printat
	; Get x,y
	jsr df_rt_parm_2ints
	ldx df_tmpptra
	ldy df_tmpptrb
	; Set the cursror here
	jsr _gr_set_cur
	; and continue to normal print command
df_rt_print
	ldy df_exeoff
	dey
df_rt_print_ws
	iny
	; evaluate an expression
	cpy df_eolidx
	beq df_rt_print_done
	cpy df_nxtstidx
	beq df_rt_print_done
	lda (df_currlin),y
	cmp #' '
	beq df_rt_print_ws
	cmp #','
	beq df_rt_print_ws
	; save index
	sty df_exeoff
	
	; if starts with string literal then process seval
	cmp #DFTK_STRLIT
	beq df_rt_print_string
	; else evaluate a numeric
	jsr df_rt_neval
	; check what is on the argument stack
	ldy df_parmtop
	dey
	lda df_opstck,y
	bmi df_rt_print_gotstr
	jsr df_rt_print_num
	bra df_rt_print
df_rt_print_gotstr
	jsr df_rt_print_str
	bra df_rt_print
df_rt_print_string
	; point to string accumulator
	ldx df_sevalptr
	lda df_sevalptr+1
	jsr df_rt_seval
	bra df_rt_print_gotstr
df_rt_print_done
	sty df_exeoff
	rts
	
df_rt_println
	jsr df_rt_print
	lda #UTF_CR
	jmp io_put_ch


; assign to a number variable
; X,A must have lvar
df_rt_nassign
	pha
	phx
	; now go evaluate expression in to A,X
	jsr df_rt_getnval
	; restore variable address to write to
	ply
	sty df_tmpptra
	ply
	sty df_tmpptra+1
	; save X,A int in contents section
	ldy #1
	sta (df_tmpptra),y
	txa
	ldy #0
	sta (df_tmpptra),y

	rts

; assign to a string variable
; X,A must have lvar
df_rt_sassign
	; now go evaluate expression
	; with the destination being X,A
	jsr df_rt_seval

	; get string pointer from top of runtime stack
	jmp df_st_popStr
	
;	clc
;	rts

; generate lvar from a var token ready for assignment
df_rt_generate_lvar
	; move past escape val
	inc df_exeoff
	ldy df_exeoff
	; pointing to variable index
	lda (df_currlin),y
	; get the vvt address
	jsr df_var_addr

	; get the type and save
	lda (df_tmpptra)
	pha

	; set carry flag to return pointer (lvar)
	sec
	jsr df_rt_eval_var
	jsr df_st_popPtr
	; pull the type previously saved into Y
	ply
	; move past the lvar variable index
	inc df_exeoff
;	clc
	rts

; assign
; X,A,Y contain lvar pointer and type
df_rt_doassign
	; save A and put type Y in to A
	pha
	tya
	and #DFVVT_STR
	; if a string then string expression
	beq df_rt_assign_num
	; remember to restore A
	; jump to string expression evaluator
	pla
	jmp df_rt_sassign
df_rt_assign_num
	; else jump to numeric expression evaluator
	; remember to restore A
	pla
	jmp df_rt_nassign

; general assignment execution
df_rt_assign
	jsr df_rt_generate_lvar
	; go and do the assignment
	jmp df_rt_doassign
	
; comment or data token is ignored by runtime
df_rt_comment
df_rt_data
;	clc
	rts

	
; run token	
df_rt_run
;	sec
	rts

; end of line / statement indicator
; CS = End, CC = not end
df_rt_eos
	ldy df_exeoff
	cpy df_eolidx
	beq df_rt_eos_true
	lda (df_currlin),y
	cmp #':'
	beq df_rt_eos_true
	cpy df_nxtstidx
	beq df_rt_eos_true
	clc
	rts
df_rt_eos_true
	sec
	rts

; renum start,offset,increment
; if increment == 0 then just add offset to the affected lines
; if increment <> 0 then renumber from first affected line with increment
; renumbers from the first matching line to end of program
df_rt_renum
	inc df_exeoff
	jsr df_rt_parm_3ints
	; starting line number
	ldx df_tmpptra
	lda df_tmpptra+1
	jsr df_pg_find_line
	bcc df_rt_renum_ok
	SWBRK DFERR_NOLINE
df_rt_renum_ok
	; save starting position in program
	stx df_tmpptrd
	sta df_tmpptrd+1
df_rt_renum_do
	; if not end of program
	lda (df_tmpptrd)
	; then renumber this line
	bne df_rt_renum_update
	; else done
	rts
df_rt_renum_update
	; add offset to start line number
	; add increment to start line number
	; if increment <> 0 then update this line number with start line number
	; if increment == 0 then add offset to this  line number
	
	; add offset to start line number
	_addZPWord df_tmpptra,df_tmpptrb
	; if increment == 0 then update this line with start line
	lda df_tmpptrc
	ora df_tmpptrc+1
	beq df_rt_renum_mode2
	; mode 1 means increment <> 0
	; so set this line number to current value of start line number
	ldy #DFTK_LINNUM
	lda df_tmpptra
	sta (df_tmpptrd),y
	iny
	lda df_tmpptra+1
	sta (df_tmpptrd),y
	; add increment to start line
	_addZPWord df_tmpptra,df_tmpptrc
	bra df_rt_renum_next
df_rt_renum_mode2
	; mode 2 means increment == 0
	; so just add offset to this line number
	ldy #DFTK_LINNUM
	clc
	lda (df_tmpptrd),y
	adc df_tmpptrb
	sta (df_tmpptrd),y
	iny
	lda (df_tmpptrd),y
	adc df_tmpptrb+1
	sta (df_tmpptrd),y	
df_rt_renum_next
	clc
	lda df_tmpptrd
	adc (df_tmpptrd)
	sta df_tmpptrd
	lda df_tmpptrd+1
	adc #0
	sta df_tmpptrd+1
	bra df_rt_renum_do


; * List all procs in VNT
df_rt_listprocnames
	; start at the beginning of the vnt table
	_cpyZPWord df_vntstrt,df_tmpptra
	; start at index 0
	stz df_tmpptrb
df_rt_listcheckvnt
	; If reached the var count then not found
	lda df_tmpptrb
	cmp df_varcnt
	beq df_rt_listpn_done
	ldy #0
	lda (df_tmpptra),y
	cmp #'_'
	bne df_rt_listnextvnt
df_rt_listprocch
	lda (df_tmpptra),y
	jsr io_put_ch
	cmp #0
	beq df_rt_listproccr
	iny
	bra df_rt_listprocch
df_rt_listproccr
	lda #UTF_CR
	jsr io_put_ch
	clc
df_rt_listprocpause
	jsr io_get_ch
	cmp #' '
	bne df_rt_listnextvnt
df_rt_listwait
	sec
	bra df_rt_listprocpause
df_rt_listnextvnt
	lda (df_tmpptra),y
	beq df_rt_listgotnext
	iny
	bra df_rt_listnextvnt
df_rt_listgotnext
	; increment vnt #
	inc df_tmpptrb
	; skip past zero terminator
	iny
	; add this to vnt pointer
	clc
	tya
	adc df_tmpptra
	sta df_tmpptra
	lda df_tmpptra+1
	adc #0
	sta df_tmpptra+1
	bra df_rt_listcheckvnt
df_rt_listpn_done
	rts

df_rt_listproc
	;copy procname to linbuff
	; always put '_'
	lda #'_'
	sta df_linbuff
	ldx #0
	ldy df_exeoff
df_rt_listp_copy
	iny
	inx
	lda (df_currlin),y
	sta df_linbuff,x
	jsr df_tk_isalphanum
	bcs df_rt_listp_copy
	; zero the line index
	stz df_linoff
	; save runtime pos
	sty df_exeoff
	; Now try and find in VNT
	jsr df_var_find
	bcs df_rt_listp_notfound
	; Ok we have got a match in A, find the proc
	jsr df_rt_findproc
	; Save the line pointer
	stx df_tmpptra
	sta df_tmpptra+1
	; save statement index in to line
	sty df_lineidx
	; Check if '-' option used
	ldy df_exeoff
	lda (df_currlin),y
	cmp #'-'
	; if so, list to end of program
	beq df_rt_listprgend
	; Now try and find the end of this procedure
	; enddef or another def
	; A,X=Line ptr, Y=line idx
	ldx df_tmpptra
	lda df_tmpptra+1
	ldy df_lineidx
df_rt_listp_findend
	; Go to next stat
	jsr df_rt_nextstat
	bcs df_rt_listprgend
	; save y (a,x in lineptr)
	phy
	; find the command
df_rt_listp_findcmd
	iny
	lda (df_lineptr),y
	bpl df_rt_listp_findcmd
	; restore y to stat beginning
	ply
	; check A - looking for enddef or def
	cmp #DFRT_ENDDEF
	beq df_rt_listp_done
	cmp #DFRT_DEF
	beq df_rt_listp_done
	; if neither then next stat from current
	ldx df_lineptr
	lda df_lineptr+1
	bra df_rt_listp_findend
df_rt_listp_done
	; Push end line on to stack
	lda df_lineptr+1
	pha
	phx
	bra df_rt_list_line 
df_rt_listp_notfound
	; Fatal error if proc not found
	SWBRK DFERR_NOPROC
	
; list token
df_rt_list
	stz df_tmpptre		; Zero means in normal list mode not save mode
	; find non-ws
	jsr df_rt_skip_ws
	; if end of statement then no line specifiers
	jsr df_rt_eos
	; so list whole program
	bcs df_rt_listprg
	
	;if '_' then use procnames
	cmp #'_'
	bne df_rt_list_all
	jmp df_rt_listproc
df_rt_list_all
	;if '*' then display all procnames
	cmp #'*'
	bne df_rt_list_linno
	jmp df_rt_listprocnames
df_rt_list_linno
	; else get 1st parameter
	jsr df_rt_getnval
	; find the starting line number in X,A
	jsr df_pg_find_line
	stx df_tmpptra
	sta df_tmpptra+1
	
	; if end of statement then only start line was provided
	jsr df_rt_eos
	; so list until end of program
	bcs df_rt_listprgend
	; else get 2nd parameter
	inc df_exeoff
	jsr df_rt_getnval
	; find the starting line number in X,A
	jsr df_pg_find_line
	pha
	phx
	bra df_rt_list_line

; Common listing routine used by LIST and SAVE
; tmpe = 0 means in LIST mode else SAVE mode
; can stop the listing in LIST mode with CTRL-C
df_rt_listprg
	; program start and end as for pointer value
	_cpyZPWord df_prgstrt, df_tmpptra
df_rt_listprgend
	lda df_prgend+1
	pha
	lda df_prgend
	pha
df_rt_list_line
	; if line length = 0 then end of program
	lda (df_tmpptra)
	beq df_rt_list_line_fin
	; if in list mode and CTRL-C then also stop
	lda df_tmpptre
	bne df_rt_list_line_cont
	; check for break, asynch get
	clc
df_rt_list_synckey
	lda df_tmpptre					; Ignore keys on save mode
	bne df_rt_list_line_cont
	jsr io_get_ch
	cmp #' '						; Space = PAUSE
	beq df_rt_list_pause
	cmp #UTF_ETX					; CTRL-C?
	beq df_rt_list_line_fin
	bra df_rt_list_line_cont		; any other key continues
df_rt_list_pause
	sec								; Check key sync
	bra df_rt_list_synckey
df_rt_list_line_fin
	pla
	pla
	clc
	rts
df_rt_list_line_cont
	ldy #0
	sty df_exeoff
	jsr df_rt_list_linnum
	jsr df_rt_list_line_only
df_rt_list_next_line
	; new line
	lda #UTF_CR
	jsr io_put_ch
	; increment pointer to next line
	clc
	lda df_tmpptra
	adc (df_tmpptra)
	sta df_tmpptra
	lda df_tmpptra+1
	adc #0
	sta df_tmpptra+1
	; if pointer > end then listing is done
	sec
	pla
	tax
	sbc df_tmpptra
	pla
	pha
	phx
	sbc df_tmpptra+1
	bcs df_rt_list_line
	
	; if got here then reached tmpb
	pla
	pla
	rts

;Using df_tmpptra as line pointer
;Print decode an entire line
df_rt_list_line_only
	ldy #3
	lda (df_tmpptra),y
	sta df_nxtstidx
	iny
	sty df_exeoff
df_rt_list_decode
	ldy df_exeoff
	lda (df_tmpptra),y
	bmi df_rt_list_token
	cmp #DFTK_ESCVAL
	bcc df_rt_list_escval
	; normal char just print it
	jsr io_put_ch
	bra df_rt_list_nexttok
df_rt_list_escval
	; A and Y need to be valid on entry
	jsr df_rt_list_decode_esc
	bra df_rt_list_nexttok
df_rt_list_token
	jsr df_rt_list_decode_token
df_rt_list_nexttok	
	; advance the line offset
	inc df_exeoff
	lda df_exeoff
	; check if at end of line
	cmp (df_tmpptra)
	beq df_rt_list_line_only_fin
	; check if at end of statement
	cmp df_nxtstidx
	bne df_rt_list_decode
	tay
	; save the next statement offset
	lda (df_tmpptra),y
	sta df_nxtstidx
	iny
	sty df_exeoff
	bra df_rt_list_decode
df_rt_list_line_only_fin
	rts
	
	
; decode escape sequences
df_rt_list_decode_esc
	; jump over esc byte
	iny
	sty df_exeoff
	; get the next two bytes in case needed
	pha
	lda (df_tmpptra),y
	sta df_tmpptrb
	iny
	lda (df_tmpptra),y
	sta df_tmpptrb+1
	dey
	pla
	; x2 to get jmp offset
	asl a
	tax
	; now jump to decoder
	jmp (df_rt_escjmp,x)

; reserved
df_rt_lst_reserved
	rts

; decode a byte char
df_rt_lst_chr
	lda #0x27			; Single quote
	jsr io_put_ch
	lda df_tmpptrb
	jsr io_put_ch
	lda #0x27			; Single quote
	jsr io_put_ch
	iny
	sty df_exeoff
	rts

; Output 0x for hex chars
df_rt_lst_hex_pre
	lda #'0'
	jsr io_put_ch
	lda #'x'
	jmp io_put_ch
;	rts

; Decode a byte hex	
df_rt_lst_bythex
	jsr df_rt_lst_hex_pre
df_rt_lst_lo_hex
	lda df_tmpptrb
	jsr str_a_to_x
	jsr io_put_ch
	txa
	jsr io_put_ch
	iny
	sty df_exeoff
	rts

; Decode an int hex
df_rt_lst_inthex
	jsr df_rt_lst_hex_pre
	lda df_tmpptrb+1
	jsr str_a_to_x
	jsr io_put_ch
	txa
	jsr io_put_ch
	jmp df_rt_lst_lo_hex

; Decode a byte binary
df_rt_lst_bytbin
	ldx #8
	lda df_tmpptrb
	sta df_tmpptrb+1
	bra df_rt_lst_bin

; Decode a int binary

df_rt_lst_intbin
	ldx #16
	iny
	sty df_exeoff

; Main 01 decoding of binary
df_rt_lst_bin
	lda #'0'
	jsr io_put_ch
	lda #'b'
	jsr io_put_ch
df_rt_lst_bit
	lda #'0'
	asl df_tmpptrb
	rol df_tmpptrb+1
	bcc df_rt_lst_bit_skip0
	lda #'1'
df_rt_lst_bit_skip0
	jsr io_put_ch
	dex
	bne df_rt_lst_bit
	iny
	sty df_exeoff
;	clc
	rts
	
; Decode a decimal integer
df_rt_lst_intdec	
	ldx df_tmpptrb
	lda df_tmpptrb+1
	iny
	sty df_exeoff
	clc
	jmp print_a_to_d
;	rts

; decode a variable or procedure
df_rt_lst_var
df_rt_lst_proc
	; get var index
	lda (df_tmpptra),y
	tax
	_cpyZPWord df_vntstrt,df_tmpptrb
df_rt_list_findvvt
	cpx #0
	beq df_rt_list_gotvvt
df_rt_list_vvtend
	lda (df_tmpptrb)
	beq df_rt_list_gotvvtend
	_incZPWord df_tmpptrb
	bra df_rt_list_vvtend
df_rt_list_gotvvtend
	_incZPWord df_tmpptrb
	dex
	bra df_rt_list_findvvt
df_rt_list_gotvvt
	lda (df_tmpptrb)
	beq df_rt_list_donvvt
	jsr io_put_ch
	_incZPWord df_tmpptrb
	bra df_rt_list_gotvvt
df_rt_list_donvvt
	rts

df_rt_lst_strlit
	lda #0x22
	jsr io_put_ch
	ldy df_exeoff
df_rt_lst_strlitch
	lda (df_tmpptra),y
	beq df_rt_lst_strlitdon
	jsr io_put_ch
	iny
	bra df_rt_lst_strlitch
df_rt_lst_strlitdon
	lda #0x22
	jsr io_put_ch
	sty df_exeoff
	rts

df_rt_list_linnum
	ldy #1
	lda (df_tmpptra),y
	tax
	ldy #2
	lda (df_tmpptra),y
	clc
	jmp print_a_to_d

; decode a token value with MSB set
df_rt_list_decode_token
	; if not assembler then normal listing
	cmp #DFRT_ASM
	bne df_rt_list_decode_token_normal
	jmp df_rt_asm_decode_token
df_rt_list_decode_token_normal
	and #0x7f
	; token 0 and 1 don't get decoded they are implicit
	cmp #2
	bcs df_rt_list_do_decode_tkn	
	rts
df_rt_list_do_decode_tkn
	tax
	lda #lo(df_tokensyms)
	sta df_tmpptrb
	lda #hi(df_tokensyms)
	sta df_tmpptrb+1
df_rt_list_find_sym
	cpx #0
	beq df_rt_list_got_sym
df_rt_list_next_ch
	lda (df_tmpptrb)
	pha
	_incZPWord df_tmpptrb
	pla
	bpl df_rt_list_next_ch
df_rt_list_got_last_sym
	; ok got to the last ch
	; advance to next sym
	dex
	bra df_rt_list_find_sym
df_rt_list_got_sym
	lda (df_tmpptrb)
	php
	and #0x7f
	jsr io_put_ch
	_incZPWord df_tmpptrb
	plp
	bpl df_rt_list_got_sym
	rts 

;** Decode assembler token in A **
df_rt_asm_decode_token
	lda #'.'			;Always put out the . symbol
	jsr io_put_ch
	ldy df_exeoff		;Print out any whitespace
df_rt_asm_decode_token_ws
	iny					;Point to char after the asm token
	lda (df_tmpptra),y	;What is the char?
	jsr df_tk_isws		;If not then found the keyword
	bcc df_rt_asm_decode_token_found
	jsr io_put_ch		;Print the space
	bra df_rt_asm_decode_token_ws
df_rt_asm_decode_token_found
	cmp #DFTK_VAR		; If is a label variable?
	bne df_rt_asm_decode_token_keyword
	; if so then process as normal escape handling
	jmp df_rt_list_decode_esc
df_rt_asm_decode_token_keyword
	and #0x7f			; Mask off MSB
	tax					;Put it in to X as the counter
	; Point to asm symbol table
	lda #lo(df_asm_tokensyms)
	sta df_tmpptrb
	lda #hi(df_asm_tokensyms)
	sta df_tmpptrb+1
df_rt_list_find_asm_sym
	cpx #0
	beq df_rt_list_got_asm_sym
df_rt_list_next_asm_ch
	_incZPWord df_tmpptrb
	lda (df_tmpptrb)
	cmp #' '			; Skip all chars >=' '
	bcs df_rt_list_next_asm_ch
	sec					; Skip offset and mode bytes
	adc df_tmpptrb
	sta df_tmpptrb
	lda df_tmpptrb+1
	adc #0
	sta df_tmpptrb+1
	dex					; One less symbol to skip over
	bra df_rt_list_find_asm_sym
df_rt_list_got_asm_sym
	lda (df_tmpptrb)
	cmp #' '
	bcc df_rt_asm_decode_token_done
	jsr io_put_ch
	_incZPWord df_tmpptrb
	bra df_rt_list_got_asm_sym
df_rt_asm_decode_token_done
	sty df_exeoff		; Save offset
	rts 


df_rt_doke
	jsr df_rt_parm_2ints
	lda df_tmpptrb
	sta (df_tmpptra)
	; get high byte to doke
	lda df_tmpptrb+1
	ldy #1
	; poke hi byte
	sta (df_tmpptra),y
	rts
	
df_rt_poke
	jsr df_rt_parm_2ints
	lda df_tmpptrb
	sta (df_tmpptra)
;	clc
	rts

df_rt_vpoke
	jsr df_rt_parm_2ints
	ldx df_tmpptra
	ldy df_tmpptra+1
	lda df_tmpptrb
	jmp _vdp_poke
;	clc
;	rts

df_rt_setvdp
	jsr df_rt_parm_2ints
	lda df_tmpptra
	ldx df_tmpptrb
	jmp vdp_wr_reg
;	clc
;	rts

df_rt_colour
	jsr df_rt_parm_3ints
	; colour is a combination of b and c parms
	lda df_tmpptrb
	asl a
	asl a
	asl a
	asl a
	ora df_tmpptrc
	pha
	lda df_tmpptra
	cmp #32					; 32 = border colour
	beq df_rt_colour_border
	; else write to the colour table
	; first calculate the colour table address
	clc
	adc vdp_base+vdp_addr_col
	tax
	lda vdp_base+vdp_addr_col+1
	adc #0
	tay
	pla
	; A = colour, YX = address
	jsr vdp_poke
	rts
df_rt_colour_border
	lda #7
	plx
	jmp vdp_wr_reg

df_rt_sprite
	jsr df_rt_parm_5ints
	; calculate the sprite number in vram
	lda df_tmpptra
	asl a
	asl a
	clc
	adc vdp_base+vdp_addr_spa
	tax
	lda vdp_base+vdp_addr_spa+1
	adc #0
	sei				; Disable interrupts
	jsr vdp_wr_addr
	; now write the vertical position (tmpc, not b)
	lda df_tmpptrc
	jsr vdp_wr_vram
	; now write the horizontal position (tmpb)
	lda df_tmpptrb
	jsr vdp_wr_vram
	; now write the pattern name (tmpd)
	lda df_tmpptrd
	jsr vdp_wr_vram
	; now write the colour / ec byte (tmpe)
	lda df_tmpptre
	jsr vdp_wr_vram
	cli				; Enable interrupts
	rts


; copy pattern array to sprite pattern vram
; pattern array is a mim 4 element int
df_rt_spritepat
	jsr df_rt_parm_2ints
	; save sprite number
	stx df_tmpptra
	stz df_tmpptra+1
	; multiply by 8 to get pattern offset
	asl df_tmpptra
	rol df_tmpptra+1
	asl df_tmpptra
	rol df_tmpptra+1
	asl df_tmpptra
	rol df_tmpptra+1
	; add offset to sprite pattern base
	; and put in X,A
	lda df_tmpptra
	adc vdp_base+vdp_addr_spp
	tax
	lda df_tmpptra+1
	adc vdp_base+vdp_addr_spp+1
	sei			; Disable interrupts
	; set vdp address
	jsr vdp_wr_addr
	; start from beginning of array
	ldy #0
df_rt_spritepat_line
	; get the sprite patten from array
	lda (df_tmpptrb),y
	; and write to vdp
	jsr vdp_wr_vram
	iny
	; do this for 8 bytes (4 elements)
	cpy #8
	bne df_rt_spritepat_line
	cli			; Enable interrupts
	rts

df_rt_spritepos
	jsr df_rt_parm_3ints
	; calculate the sprite number in vram
	lda df_tmpptra
	asl a
	asl a
	adc vdp_base+vdp_addr_spa
	tax
	lda vdp_base+vdp_addr_spa+1
	adc #0
	sei
	jsr vdp_wr_addr
	; now write the vertical position (tmpc, not b)
	lda df_tmpptrc
	jsr vdp_wr_vram
	; now write the horizontal position (tmpb)
	lda df_tmpptrb
	jsr vdp_wr_vram
	cli
	rts

; common routine for col and nme variations
; A contains offset in to sprite table to update
df_rt_spriteattr
	; save A which contains the offset
	pha
	jsr df_rt_parm_2ints
	; calculate the sprite number in vram
	lda df_tmpptra
	asl a
	asl a
	adc vdp_base+vdp_addr_spa
	sta df_tmpptra
	lda vdp_base+vdp_addr_spa+1
	adc #0
	sta df_tmpptra+1
	; add offset and put in X,A to set VRAM address
	pla							; get offset from stack
	adc df_tmpptra
	tax
	lda df_tmpptra+1
	adc #0
	tay
	lda df_tmpptrb
	jmp vdp_poke

df_rt_spritecol
	; offset is 3 for colour byte
	lda #3
	jmp df_rt_spriteattr

df_rt_spritenme
	; offset is 2 for name byte
	lda #2
	jmp df_rt_spriteattr

df_rt_snd_common
	; 3 inputs
	; tmpa = channel (1,2,3), tmpb = period, tmpc = vol
	lda df_tmpptra
	; tone channel addressing is 0 to 2
	dec a
	and #3
	; ok doing a tone channel, get reg index for period
	asl a
	tax
	; get low byte of period
	ldy df_tmpptrb
	jsr _snd_set
	; increment reg number to high byte
	inx
	; get high byte of period
	lda df_tmpptrb+1
	and #0x0f
	tay
	; set period
	jsr _snd_set
	; get volume register index (8 = channel 1)
	clc
	lda df_tmpptra
	and #3
	adc #7
	tax
	; get volume
	lda df_tmpptrc
	and #0x0f
	bne df_rt_sound_env_skip
	; envelope mode
	ora #0x10
df_rt_sound_env_skip
	tay
	jmp _snd_set
;	rts

; sound chan,period,volume	
df_rt_sound
	jsr df_rt_parm_3ints
df_rt_dosound
	; check which channel (0 = noise)
	lda df_tmpptra
	beq df_rt_sound_noise
	jmp df_rt_snd_common
df_rt_sound_noise
	; ok update the noise channel, volume is irrelevant
	ldx #6
	lda df_tmpptrb
	and #0x1f
	tay
	jmp _snd_set
;	clc
;	rts

; music chan,octave,note,volume
df_rt_music
	jsr df_rt_parm_4ints
	; parm 2 = octave, need to x 12word = 24
	clc
	lda df_tmpptrb
	adc df_tmpptrb
	adc df_tmpptrb
	asl a
	asl a
	; we have x12, now add note to get index
	adc df_tmpptrc
	asl a
	tay
	; get period A,X (hi/lo)
	jsr _snd_get_note
	stx df_tmpptrb
	sta df_tmpptrb+1
	; put vol in tmpc
	lda df_tmpptrd
	sta df_tmpptrc
	; tmpa,b,c contain chan,per,vol
	jmp df_rt_dosound
	
	
; play tonemask,noisemask,envelope,period
df_rt_play
	jsr df_rt_parm_4ints
	; parm 1 = tone enable
	lda df_tmpptra
	and #7
	sta df_tmpptra
	; parm 2 = noise enable
	lda df_tmpptrb
	and #7
	asl a
	asl a
	asl a
	ora df_tmpptra
	; we now have bits set for channels to enable
	; but need to invert for the 8910
	; keep top 2 bits 0 as these are port a and b inputs
	eor #0x3f
	tay
	; reg 7 is control register
	ldx #7
	jsr _snd_set
	; parm 3 = envelope mode
	lda df_tmpptrc
	and #0xf
	tay
	; 13 is envelope shape register
	ldx #13
	jsr _snd_set
	; parm 4 = envelope period
	; 11 is envelope period register
	ldx #11
	; get low
	ldy df_tmpptrd
	jsr _snd_set
	; get high
	inx
	ldy df_tmpptrd+1
	jmp _snd_set
;	clc
;	rts


;* Binary save mem,hdr,addr,len,filename
df_rt_bsave
	; Get mem type, 0=RAM, else VRAM
	jsr df_rt_neval				; Get mem type
	jsr df_st_popInt			; X,A = mem type (only X)
	; if check X for v or r
	cpx #'v'
	bne df_rt_bsave_tryr
	clc							; Clear C for vram
	bra df_rt_bsave_savep
df_rt_bsave_tryr
	cpx #'r'
	beq	 df_rt_bsave_setR
	SWBRK DFERR_TYPEMISM		; was not v or r!
df_rt_bsave_setR
	sec							; Set C for ram
df_rt_bsave_savep
	; save C, clear=VRAM, set=RAM
	php

	; jump over comma
	inc df_exeoff
	; Get header length
	jsr df_rt_neval				; Get header length
	jsr df_st_popInt			; X,A = Header length (only X)
	; save X as header length
	phx

	; jump over comma
	inc df_exeoff
	jsr df_rt_neval				; Get address
	jsr df_st_popInt			; X,A = Address
	pha
	phx

	; jump over comma
	inc df_exeoff
	jsr df_rt_neval				; Get length
	jsr df_st_popInt			; X,A = Length
	pha
	phx

	; jump over comma
	inc df_exeoff
	; Process filename
	jsr df_rt_parse_file
	jsr io_open_write
	bcs df_rt_file_errc3		; Error condition resets the stack

	; On the stack, we have lenlo,lenhi,adlo,adhi,head,mem
	tsx
	ldy 0x105,x					; Get header len
	beq df_rt_bsave_byte
	lda #0						; Zero filler
df_rt_bsave_header
	jsr io_put_ch				; Write a byte to disk
	dey
	bne df_rt_bsave_header
df_rt_bsave_byte
	tsx							; Restore SP to X
	lda 0x101,x					; low<>0 carry on
	bne df_rt_bsave_byte_do
	lda 0x102,x					; hi<>0 carry on
	beq df_rt_bsave_done		; else done
df_rt_bsave_byte_do
	lda 0x106,x					; Get the C status
	pha
	plp							; C unaffected by next ops
	
	lda 0x103,x					; Get low address
	ldy 0x104,x					; Get high address
	tax							; X,Y contain address

	bcs df_rt_bsave_ram			; RAM or VRAM?
	; Read from VRAM
	tya							; A needs to contain high byte
	jsr _vdp_peek				; Peek VRAM
	bra df_rt_bsave_write
df_rt_bsave_ram
	; Read from RAM
	stx df_tmpptra				; Save address
	sty df_tmpptra+1
	lda (df_tmpptra)			; Peek RAM
df_rt_bsave_write
	jsr io_put_ch				; Write to disk
	tsx							; Get SP to X
	inc 0x103,x					; Increment low address
	bne df_rt_bsave_skiph
	inc 0x104,x					; Increment high address
df_rt_bsave_skiph
	ldy 0x101,x					; Get low len byte
	beq df_rt_bsave_dech
	dec 0x101,x					; A simple decrement
	bra df_rt_bsave_byte		; Process next byte
df_rt_bsave_dech
	dec 0x101,x					; Decrement low in readiness
	dec 0x102,x					; Decrement high
	bra df_rt_bsave_byte		; Process next byte
df_rt_bsave_done
	; Tidy the stack
	pla
	pla
	pla
	pla
	pla
	pla
	jmp df_rt_file_cleanup		; Clean up FS

df_rt_file_errc3				; Stepping stone!!!
	bcs df_rt_file_errc3

;* common filename procesing routine
;* 
df_rt_init_filename
	; evaluate string
	jsr df_rt_neval
	jsr df_st_popStr

	; save string address
	stx df_tmpptrb
	sta df_tmpptrb+1
	
	; copy string to fhandle
	ldy #0
df_rt_copy_fn
	lda (df_tmpptrb),y
	bit #0x40					; If 0x40 bit not set
	beq df_rt_fname_case		; then not an alpha char
	and #0xdf					; Else mask out 0x20 bit to make upper case
df_rt_fname_case	
	sta fh_handle,y
	iny
	cmp #0
	bne df_rt_copy_fn
	rts
	
;* common file parsing routine
df_rt_parse_file
	; now process filename
	jsr df_rt_init_filename
	lda #2					; Only works for SD card now
	jsr io_active_device
;	clc
	rts
df_rt_file_errc
	SWBRK DFERR_FNAME
; save "file"
df_rt_save
	jsr df_rt_parse_file
	jsr io_open_write
	bcs df_rt_file_errc
	; ok now have redirected output to device
	; go and list the program in save mode
	lda #1
	sta df_tmpptre
	jsr df_rt_listprg
	; final CR to end the save
	lda #UTF_CR
	jsr io_put_ch
df_rt_file_cleanup
	; close the file
	jsr io_close
	clc
	; restore to default device io
	jmp io_set_default
;	clc
;	rts

; load 'x',"file" where 0=serial, 1=SDCard
df_rt_load
	jsr df_rt_parse_file
	jsr io_open_read
df_rt_file_errc2		; Used as a stepping stone further down!
	bcs df_rt_file_errc
	; no echo - very important
	; else might try and write to a device
	; only open for reading (i.e. SD CARD)
df_rt_loadline
	clc
	jsr df_pg_inputline
	; if C clear then tokenise line
	bcc df_rt_ldtokenise
	; else done
	; clear dflat runtime else will try to execute
	; the last tokenised line!
	stz df_tokbuff			; Offset to next line
	stz df_tokbuff+1		; Clear line low
	stz df_tokbuff+2		; Clear line high
	stz df_nxtstidx			; Clear next statement
	lda #1					; Set immediate mode
	sta df_immed
	bra df_rt_file_cleanup	; Ok now can close and done	
df_rt_ldtokenise
	jsr df_pg_tokenise		; Tokenise loaded string
	bra df_rt_loadline		; Continue with next until blank

df_rt_del
	jsr df_rt_init_filename		; Parse filename
	jsr _fs_delete				; Delete file
	rts

df_rt_chdir
	jsr df_rt_init_filename		; Parse filename
	jsr _fs_chdir				; Try and change directory
	bcs df_rt_file_errc
	rts

; bload MEM,HEAD,ADDR,FNAME
df_rt_bload
	; Get mem type, 0=RAM, else VRAM
	jsr df_rt_neval				; Get mem type
	jsr df_st_popInt			; X,A = mem type (only X)
	; if check X for v or r
	cpx #'v'
	bne df_rt_bload_tryr
	clc							; Clear C for vram
	bra df_rt_bload_savep
df_rt_bload_tryr
	cpx #'r'
	beq	 df_rt_bload_setR
	SWBRK DFERR_TYPEMISM		; was not v or r!
df_rt_bload_setR
	sec							; Set C for ram
df_rt_bload_savep
	; save C, clear=VRAM, set=RAM
	php
	; jump over comma
	inc df_exeoff
	; Get header length
	jsr df_rt_neval				; Get header length
	jsr df_st_popInt			; X,A = Header length (only X)
	; save X as header length
	phx
	; jump over comma
	inc df_exeoff
	bra df_rt_bvload
df_rt_vload
	clc							; Hardcode for VRAM
	php
	ldx #7						; Hardcode header length
	phx
df_rt_bvload
	jsr df_rt_neval				; Get address
	jsr df_st_popInt			; X,A = Address
	pha
	phx
	; jump over comma
	inc df_exeoff
	jsr df_rt_parse_file
	jsr io_open_read
	bcs df_rt_file_errc2		; Error condition resets the stack
	; On the stack, we have adlo,adhi,head,mem
	tsx
	ldy 0x103,x					; Get header
	beq df_rt_vload_byte
df_rt_vload_header
	jsr io_get_ch				; Get a character
	bcs df_rt_vload_done		; If EOF then done
	dey
	bne df_rt_vload_header
df_rt_vload_byte
	tsx							; Restore SP to X
	lda 0x104,x					; Get the C status
	pha
	plp							; C unaffected by next ops
	
	lda 0x101,x					; Get low address
	ldy 0x102,x					; Get high address
	tax							; X,Y contain address

	bcs df_rt_vload_ram			; RAM or VRAM?
	; Poke to VRAM
	jsr io_get_ch				; Get a character
	bcs df_rt_vload_done		; If EOF then done
	jsr _vdp_poke				; Write to VRAM
	bra df_rt_vload_next
df_rt_vload_ram
	; Poke to RAM
	jsr io_get_ch				; Get a character
	bcs df_rt_vload_done		; If EOF then done
	stx df_tmpptra				; Save address
	sty df_tmpptra+1
	sta (df_tmpptra)			; Poke byte to RAM
df_rt_vload_next
	tsx							; Get SP to X
	inc 0x101,x					; Increment low address
	bne df_rt_vload_byte_skip
	inc 0x102,x					; Increment high address
df_rt_vload_byte_skip
	bra df_rt_vload_byte		; Back for next video byte
df_rt_vload_done
	; Tidy the stack
	pla
	pla
	pla
	pla
	jmp df_rt_file_cleanup

df_rt_dir_string				; Name of a directory
	db "<DIR>  ",0				; 7 chars + terminator
df_rt_dir
	jsr _fs_dir_root_start		; Start at root
	ldx #22						; Count of how many files before pause
	phx
df_rt_dir_show_entry
	clc							; Only looking for valid files
	jsr _fs_dir_find_entry		; Find a valid entry
	bcs df_rt_dir_done			; If C then no more entries so done
	ldx #lo(fh_dir)				; Set up pointer to name
	lda #hi(fh_dir)
	jsr io_print_line			; Print name
	lda #' '					; print spaces
df_rt_dir_pad
	jsr io_put_ch
	iny							; pad to 13 chars
	cpy #13
	bne df_rt_dir_pad
	lda fh_dir+FH_Attr			; Is it a directory?
	and #0x10					; Bit 4 set?
	beq df_rt_dir_size
	ldx #lo(df_rt_dir_string)	; Set up pointer to name
	lda #hi(df_rt_dir_string)
	jsr io_print_line			; Print directory indicator
	bra df_rt_dir_line
df_rt_dir_size
	ldx fh_dir+FH_Size			; Low byte of size
	lda fh_dir+FH_Size+1		; High byte of size
	clc							; Don't show leading zeros
	jsr print_a_to_d			; Print a string Y=chars
	lda #' '
df_rt_dir_padsz					; Pad to 7 digits
	jsr io_put_ch
	iny
	cpy #7
	bne df_rt_dir_padsz
	; Printed exactly 20 chars per size
df_rt_dir_line
	plx							; Decrement file line counter
	dex
	bne df_rt_dir_skip_pause
	ldx #lo(df_rt_pausemsg)		; Show pause message
	lda #hi(df_rt_pausemsg)
	jsr io_print_line
	sec
	jsr io_get_ch				; Wait for any key
	ldx #22						; Reset line counter
df_rt_dir_skip_pause	
	phx							; Save line counter
	bra df_rt_dir_show_entry	; Find another entry
df_rt_dir_done
	plx							; Pop line counter
	lda #UTF_CR					; Final CR
	jsr io_put_ch
	rts
df_rt_pausemsg
	db "Press any key for more..",UTF_CR,0
	
; reset %var
df_rt_reset
	; now get lvar X,A from current statement
	jsr df_rt_getlvar
	; save lvar in tmpb, vvt ptr in tmpa
	stx df_tmpptrb
	sta df_tmpptrb+1
	; load the vdp count as the reset value of timer
	; turn off interrupts while reading vdp lo,hi
	ldy #1	; This is in readiness to read high byte of var value
	; clear interrupts to access 3 byte vdp counter (only use low 2 bytes)
	sei
	lda vdp_cnt
	sta (df_tmpptrb)
	lda vdp_cnt+1
	sta (df_tmpptrb),y
	; restore interrupts asap
	cli
	rts

;***** FUNCTIONS *****

df_rt_deek
	sec
	bra df_rt_readbyte
df_rt_peek
	clc
df_rt_readbyte
	php
	inc df_exeoff
	jsr df_rt_getnval
	stx df_tmpptra
	sta df_tmpptra+1
	lda (df_tmpptra)
	tax
	lda #0
	plp
	bcc df_rt_readbyte_skip
	clc
	ldy #1
	lda (df_tmpptra),y
df_rt_readbyte_skip
	jmp df_st_pushInt

df_rt_vpeek
	inc df_exeoff
	jsr df_rt_getnval
	jsr _vdp_peek
	tax
	lda #0
	jmp df_st_pushInt

; Random number generator
; rnd(0) = get next number
; rnd(>0) = set seed
df_rt_rnd
	inc df_exeoff
	jsr df_rt_getnval
	; if input is 0 then generate next random number
	cpx #0
	bne df_rt_rnd_set
	cmp #0
	bne df_rt_rnd_set
	; generate next number
	lda df_rnd+1
	lsr a
	rol df_rnd
	bcc df_rt_rnd_noeor
	eor #0xb4
df_rt_rnd_noeor
	sta df_rnd+1
	eor df_rnd
	tax
	lda #0
	jmp df_st_pushInt
	; else set the seed to that number and done
df_rt_rnd_set
	stx df_rnd
	sta df_rnd+1
	jmp df_st_pushInt


; Get joystick status	
df_rt_stick
	inc df_exeoff
	jsr df_rt_getnval
	; only low byte is used
	stx df_tmpptra
	jsr _snd_get_joy0
	tya
	; invert the bits so that 1=switch on
	eor #0xff
	and df_tmpptra
	tax
	lda #0
	jmp df_st_pushInt

; l = msbyte(x)
df_rt_msbyte
	inc df_exeoff
	jsr df_rt_getnval
	; only high byte is used
	tax
	lda #0
	jmp df_st_pushInt
	
; l = lsbyte(x)
df_rt_lsbyte
	inc df_exeoff
	jsr df_rt_getnval
	; only low byte is used
	lda #0
	jmp df_st_pushInt



;* Return memory footprint as follows:
;* 0	Return free memory (start of vvt - end of heap)
;* 1	Return program size (end of prg - start of prg)
;* 2	Return size of vars (end of vnt - start of vvt)
df_rt_mem
	inc df_exeoff
	jsr df_rt_getnval
	; only low byte is used
	cpx #1
	beq df_rt_mem_prg
	cpx #2
	beq df_rt_mem_var
	; default is free memory
df_rt_mem_free
	_cpyZPWord df_vvtstrt,df_tmpptra
	_cpyZPWord df_starend,df_tmpptrb
	bra df_rt_mem_calc
df_rt_mem_prg
	_cpyZPWord df_prgend,df_tmpptra
	_cpyZPWord df_prgstrt,df_tmpptrb
	bra df_rt_mem_calc
df_rt_mem_var
	_cpyZPWord df_vntend,df_tmpptra
	_cpyZPWord df_vvtstrt,df_tmpptrb
df_rt_mem_calc
	; tmpa-tmpb result in X,A
	sec
	lda df_tmpptra
	sbc df_tmpptrb
	tax
	lda df_tmpptra+1
	sbc df_tmpptrb+1
	jmp df_st_pushInt

; %k=key(%sync) %sync>=1 means sync
df_rt_key
	inc df_exeoff
	jsr df_rt_getnval
	; only low byte is used, check for sync or async
	; c=1 if x==0 else x>0 makes c=0
	cpx #1
	jsr io_get_ch
	bcc df_rt_key_valid
	; zero out A
	lda #0
	clc
df_rt_key_valid
	tax
	lda #0
	jmp df_st_pushInt

	
; s = scrn(x,y)
df_rt_scrn
	inc df_exeoff
	jsr df_rt_parm_2ints
	ldx df_tmpptra
	ldy df_tmpptrb
	jsr _gr_get
	tax
	lda #0
	jmp df_st_pushInt

; %e=elapsed(%var)
df_rt_elapsed
	; now get lvar X,A from current statement
	jsr df_rt_getlvar
	inc df_exeoff
	; save lvar in tmpb, vvt ptr in tmpa
	stx df_tmpptrb
	sta df_tmpptrb+1
	; subtract vdp counter from value
	; turn off interrupts while reading vdp lo,hi
	ldy #1	; This is in readiness to read high byte of var value
	sec
	; disable interrupts to access vdp counter
	sei
	lda vdp_cnt
	sbc (df_tmpptrb)
	tax
	lda vdp_cnt+1
	; restore interrupts asap
	cli
	sbc (df_tmpptrb),y
	jmp df_st_pushInt

df_rt_call
	inc df_exeoff
	jsr df_rt_parm_4ints
	lda df_tmpptrb				; load A
	ldx	df_tmpptrc				; load X
	ldy df_tmpptrd				; load Y
	jsr df_rt_calljsr
	jmp df_st_pushInt			; A,X pair is return value	
df_rt_calljsr
	jmp (df_tmpptra)			; tmpptra is address, return with RTS

; string length calculator
; X,A = source
; A = length not including zero
df_rt_strlen_common
	stx df_tmpptra
	sta df_tmpptra+1
	ldy #0xff
df_rt_strlen_count
	iny
	lda (df_tmpptra),y
	bne df_rt_strlen_count
	tya
	rts
	
	
; common routine to extract a string
; tmpa = source string
; tmpb = dest string
; tmpc = start pos
; tmpd = endpos	
df_rt_str_extract
	; source string
	jsr df_st_popStr
	stx df_tmpptra
	sta df_tmpptra+1
	; destination is string accumulator
	lda df_sevalptr
	sta df_tmpptrb
	lda df_sevalptr+1
	sta df_tmpptrb+1
	; start pos
	ldy df_tmpptrc
df_rt_str_cpy_ch
	cpy df_tmpptrd
	beq df_str_src_end
	lda (df_tmpptra),y
	beq df_str_src_end
	sta (df_tmpptrb)
	_incZPWord df_tmpptrb
	iny
	bne df_rt_str_cpy_ch
	SWBRK DFERR_STRLONG
df_str_src_end
	lda #0
	sta (df_tmpptrb)
	ldx df_sevalptr
	lda df_sevalptr+1
	jmp df_st_pushStr

; $c = chr(x)
df_rt_chr
	inc df_exeoff
	; get char in X
	jsr df_rt_getnval
	ldy #0
	; transfer lo byte to A
	txa
	sta (df_sevalptr),y
	iny
	; zero terminator
	lda #0
	sta (df_sevalptr),y
	; point to seval scratch area
	ldx df_sevalptr
	lda df_sevalptr+1
	jmp df_st_pushStr

; $c = hex(x)
df_rt_hex
	inc df_exeoff
	; create hex digits
	jsr df_rt_getnval
	sta df_tmpptra	; Save the high byte
	txa				; Convert low byte first
	jsr str_a_to_x	; Hex digits in A,X
	phx				; Push low digit of low byte
	pha				; Push high digit of low byte
	lda df_tmpptra	; Get the high byte
	jsr str_a_to_x	; Hex digits in A,X
	; create string
	ldy #0			; Index in to string temp area
	; hi/hi
	sta (df_sevalptr),y
	iny
	; hi/lo
	txa
	sta (df_sevalptr),y
	iny
	; lo/hi
	pla
	sta (df_sevalptr),y
	iny
	; lo/lo
	pla
	sta (df_sevalptr),y
	iny
	; zero terminator
	lda #0
	sta (df_sevalptr),y
	; point to seval scratch area
	ldx df_sevalptr
	lda df_sevalptr+1
	jmp df_st_pushStr

; $l = left($s, x)
df_rt_left
	inc df_exeoff
	; first get the string to act on
	; point to string accumulator
	ldx df_sevalptr
	lda df_sevalptr+1
	jsr df_rt_seval
	; now get the num of chars
	inc df_exeoff
	jsr df_rt_getnval
	; number of chars to extract
	stx df_tmpptrd
	; start position
	stz df_tmpptrc
	jmp df_rt_str_extract

; $r = right($s, x)
df_rt_right
	inc df_exeoff
	; first get the string to act on
	; point to string accumulator
	ldx df_sevalptr
	lda df_sevalptr+1
	jsr df_rt_seval
	; now get the num of chars from the right
	inc df_exeoff
	jsr df_rt_getnval
	; number of chars to extract from the right
	stx df_tmpptrc
	; end pos = len
	ldx df_sevalptr
	lda df_sevalptr+1
	jsr df_rt_strlen_common
	sta df_tmpptrd
	; subtract num chars to extract to get start pos
	sec
	sbc df_tmpptrc
	sta df_tmpptrc
	jmp df_rt_str_extract

; $m = mid($s, x, y)
df_rt_mid
	inc df_exeoff
	; first get the string to act on
	; point to string accumulator
	ldx df_sevalptr
	lda df_sevalptr+1
	jsr df_rt_seval
	; now get start of string segment
	inc df_exeoff
	jsr df_rt_neval
	; number of chars to extract
	inc df_exeoff
	jsr df_rt_getnval
	stx df_tmpptrd
	; start position
	jsr df_st_popInt
	stx df_tmpptrc
	; update end pos by adding start pos
	txa
	clc
	adc df_tmpptrd
	sta df_tmpptrd
	jmp df_rt_str_extract

; %l = len($s)
df_rt_len
	inc df_exeoff
	ldx df_sevalptr
	lda df_sevalptr+1
	jsr df_rt_seval
	jsr df_st_popStr
	jsr df_rt_strlen_common
	tax
	lda #0
	jmp df_st_pushInt

; %l = asc($s)
df_rt_asc
	inc df_exeoff
	ldx df_sevalptr
	lda df_sevalptr+1
	; Evaluate the string with pointer in X,A
	jsr df_rt_seval
	jsr df_st_popStr
	; Store point in ZP
	stx df_tmpptra
	sta df_tmpptra+1
	; Find the character at beginning
	lda (df_tmpptra)
	tax
	lda #0
	; Save as an int
	jmp df_st_pushInt

; %l = val($s)
df_rt_val
	inc df_exeoff
	ldx df_sevalptr
	lda df_sevalptr+1
	jsr df_rt_seval
	; X,A = address of string
	jsr df_st_popStr
	ldy #0				; any numeric format
	jsr con_n_to_a		; result in num_a
	bcs df_rt_val_err
	ldx num_a
	lda num_a+1
	; Save as an int
	jmp df_st_pushInt
df_rt_val_err
	SWBRK DFERR_TYPEMISM

; stop execution
df_rt_abort
	SWBRK DFERR_ABORT
	
mod_sz_rtsubs_e

