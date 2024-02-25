;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  ASM.S
;*  This is the main controller code file for the assembler
;*  This file includes all the required source files needed
;*	in addition to dflat.s
;*
;**********************************************************

	; ROM code
	code  

mod_sz_asm_s

	;	dflat.s is already included, so just the additionals
	include "dflat\asm.i"
	include "dflat\tkasm.s"
	include "dflat\rtasm.s"
	include "dflat\asmsymtab.s"
	include	"dflat\asmjmptab.s"

;****************************************
;* as_init
;* Initialise assembler settings
;****************************************
asm_init
	; Zero the PC
	stz df_asmpc
	stz df_asmpc+1
	; Zero the option
	stz df_asmopt
	rts
	
mod_sz_asm_e
