;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  ERROR.S
;*  Error handling module.
;*  Whan an error is thrown using BRK, this module handles
;*  displaying the error plus any associated line number
;*  if it was running a program.  It then resets necessary
;*  settings and takes the system back to program edit
;*  mode.  The message uses the general IO handler, thus
;*  output will be to either screen or serial depending on
;*  the BBC keyboard DIP switch.
;*
;**********************************************************

	; ROM code
	code  
	include "dflat\error.i"

	
	
	
	
; Error message table, each msg null terminated
df_tk_errortab
	db	"Ok", 0
	db	"General", 0
	db	"Syntax", 0
	db	"Runtime", 0
	db	"Type mismatch", 0
	db	"Re-dim", 0
	db	"No repeat", 0
	db	"Proc not found", 0
	db	"Proc parm mismatch", 0
	db	"Unexpected end", 0
	db	"Unclosed if", 0
	db	"No if", 0
	db	"No for", 0
	db	"Filename not found", 0
	db	"String too long", 0
	db	"Break", 0
	db	"Out of data", 0
	db	"No while", 0
	db	"No line", 0
	db	"No return value", 0
	db	"Program aborted", 0
	db	"Out of bounds", 0
	db	"No assembly origin", 0
	db	"No addresing mode", 0
	db	0

df_tk_error_inline
	db	" in line ", 0
df_tk_error_atpos
	db	" pos ", 0
df_tk_error_error
	db	" error", 0

;****************************************
;* df_trap_error
;* Show an error message
;* errno is error number
;* currlin = Line number
;* exeoff = offset
;* at the end jump to program editor
;****************************************
df_trap_error
	; reset SP
	ldx df_sp
	txs
	; set IO back to normal
	jsr io_set_default
	
	lda #lo(df_tk_errortab)
	sta df_tmpptra
	lda #hi(df_tk_errortab)
	sta df_tmpptra+1
	ldx errno				; 0 or >=128 goes to monitor
	beq df_trap_monitor
	bmi df_trap_monitor
df_show_err_find
	cpx #0
	beq df_show_err_found
	; If on a zero, then error table exhausted
	; so drop in to the monitor
	lda (df_tmpptra)
	beq df_trap_monitor
df_show_err_skip
	_incZPWord df_tmpptra
	lda (df_tmpptra)
	bne df_show_err_skip
	_incZPWord df_tmpptra
	dex
	bra df_show_err_find
df_show_err_found
	ldx df_tmpptra
	lda df_tmpptra+1
	jsr io_print_line
	ldx #lo(df_tk_error_error)
	lda #hi(df_tk_error_error)
	jsr io_print_line
	; if line number <> 0 then print it
	ldy #DFTK_LINNUM
	lda (df_currlin),y
	tax
	iny
	lda (df_currlin),y
	cmp #0x00
	bne df_show_err_linnum
	cpx #0x00
	bne df_show_err_linnum
	bra df_show_err_fin
df_show_err_linnum
	_println df_tk_error_inline
	clc
	jsr print_a_to_d
df_show_err_fin
	ldy df_exeoff
	beq df_show_err_done
	_println df_tk_error_atpos
	tya
	tax
	lda #0
	clc
	jsr print_a_to_d	
df_show_err_done
	lda #UTF_CR
	jsr io_put_ch
	clc
	; back to editor
	jmp df_pg_dflat

; For unknown errors, jump to monitor
df_trap_monitor
	; Print PC
	lda #'P'
	jsr io_put_ch
	lda #'C'
	jsr io_put_ch
	lda #':'
	jsr io_put_ch
	lda df_brkpc+1
	jsr jsrPrintA
	lda df_brkpc
	jsr jsrPrintA
	lda #' '
	jsr io_put_ch

	; Print A
	lda #'A'
	jsr io_put_ch
	lda #':'
	jsr io_put_ch
	lda num_a
	jsr jsrPrintA
	lda #' '
	jsr io_put_ch

	; Print X
	lda #'X'
	jsr io_put_ch
	lda #':'
	jsr io_put_ch
	lda num_a+1
	jsr jsrPrintA
	lda #' '
	jsr io_put_ch

	; Print Y
	lda #'Y'
	jsr io_put_ch
	lda #':'
	jsr io_put_ch
	lda num_a+2
	jsr jsrPrintA
	lda #UTF_CR
	jsr io_put_ch
	
	jsr df_rt_monitor
	; back to editor
	jmp df_pg_dflat
