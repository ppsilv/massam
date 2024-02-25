;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  KERNEL.S
;*	The 'kernel' routine includes code and data which must
;* 	be in every ROM bank.  In the auto-generated bank#.s
;*  files, the kernel is added before the bank specific
;*	code.  See bank0.s as an example.
;*
;**********************************************************

;* Include all definition and code files in the right order
	include "inc\includes.i"
	include "inc\graph.i"
	include "io\io.i"
	include "dflat\dflat.i"
	include "kernel\zeropage.i"
	include "dflat\dflat.i"
	include "dflat\error.i"
	include "bank\bank.i"


;****************************************
;*	Set 6502 default vectors	*
;****************************************
	data				; Set vectors
	org 0xfffa			; Vectors lie at addresses
	fcw nmi				; 0xfffa : NMI Vector
	fcw init			; 0xfffc : Reset Vector
	fcw call_irq_master	; 0xfffe : IRQ Vector
	
	; ROM code
	code				;  
	org 0xc000			; Start of ROM

	; The bank number is hardwired and aligned to PB6,7
bank_num
	if BANK0
	  db 192
	endif
	if BANK1
	  db 128
	endif
	if BANK2
	  db 64
	endif
	if BANK3
	  db 0
	endif

_code_start
	; Restore current bank always at address c001
_OSVectors
	include "kernel\osvec.s"
_restore_bank
	; Save A
	sta tmp_bank1
	; Get old bank from stack
	pla
	sta tmp_bank2
	lda IO_0+PRB
	and #ROM_ZMASK
	ora tmp_bank2
	sta IO_0+PRB
	
	; Restore A
	lda tmp_bank1

	rts

	; include cross-bank functions (see extern.mak)
	include "bank\autogen.s"	
	
mod_sz_kernel_s

;* Include all common code in the right order
	include "io\io.s"
	include "kernel\vdp-low.s"
	include "kernel\snd-low.s"
	include "kernel\main.s"
	include "kernel\irq.s"
	include "utils\misc.s"
	include "utils\utils.s"

;* Reset vector points here - 6502 starts here
init
;	jmp init_test
	; First clear ram
;	sei					; No need as disabled on startup
	jmp init_ram		; jmp not jsr to ram initialiser
init_2					; init_ram will jump back to here
	ldx #0xff			; Initialise stack pointer
	txs
;	cld					; No need as disabled on startup
	
	jsr kernel_init

	jmp main

kernel_init
	jsr init_irq		; Initialise IRQ handling
	jsr _init_acia		; initialise the serial chip
	
	jsr _init_cia0		; initialise cia 0
	jsr _init_cia1		; initialise cia 1

kernel_test
	jsr _init_snd		; initialise the sound chip
	jsr _init_keyboard	; initialise keyboard timer settings
	jsr _vdp_init		; initialise vdp
	lda #0				; Default = 40 column mode
	jsr _gr_init_screen
	jsr io_init			; Set default input/output device
	jsr _init_sdcard	; initialise the sd card interface
	jsr _init_fs		; initialise the filesystem
	stz vdp_cnt
	jsr _df_init		; Initialise interpreter

	cli					; irq interrupts enable

	rts

	
;* Initialises RAM, skipping pages 4-8 which are for IO
;* Zeroes all addressable RAM in the default bank i.e. up to 0xffff
init_ram
	stz 0x00			; Start at page 0
	stz 0x01
	ldy #0x02			; But Y initially at 2 to not overwrite pointer
	ldx #0x00			; Page counter starts at zero
init_ram_1
	cpx	#4				; Page <4 is ok
	bcc init_ram_fill
	cpx #8				; Page >=8 is ok
	bcs init_ram_fill
	bra init_ram_skip
init_ram_fill
	lda #0				; Normal RAM filled with zero
	cpx #0xc0			; but page 0xC0-0xFF copied from ROM
	bcc init_ram_zero
	lda (0x00),y		; Read from ROM area
init_ram_zero
	sta (0x00),y		; Write byte to RAM (zero or copy of ROM)
init_ram_skip
	iny
	bne init_ram_1		; Do a whole page
	inc 0x01			; Increase page pointer
	inx					; Reduce page count
	cpx #0x00			; Do all pages until page 0xff done and X wraps to 0
	bne init_ram_1
	
	jmp init_2			; Carry on initialisation

; 6502 Non-maskable interrupt come here
nmi
	rti

mod_sz_kernel_e

