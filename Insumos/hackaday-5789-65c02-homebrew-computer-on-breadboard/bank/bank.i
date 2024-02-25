bankjsr_nul_addr	=	0xc000
bankjsr_nul_bank	=	0x00
ROM_ZMASK			=	0x3f
RAM_ZMASK			=	0xcf

_bankjsr	macro	addr,bank
	; Save A
	sta tmp_bank1
	
	; Save current bank
	lda bank_num
	pha
	
	; Switch to new bank
	lda IO_0+PRB
	and #ROM_ZMASK
	ora #(bank^3) << 6			; Shift left 6 bits
	sta IO_0+PRB

	; Restore A
	lda tmp_bank1
	; JSR to the routine
	jsr addr
	
	jmp _restore_bank
	; 62 clock cycles inc restore vs 6 for a near jsr

	endm
	
_bankram macro bank
	pha
	lda IO_0+PRB
	and #RAM_ZMASK
	ora #bank << 4
	sta IO_0+PRB
	pla
	endm
	
_bankram_fast macro bank
	lda IO_0+PRB
	and #RAM_ZMASK
	ora #bank << 4
	sta IO_0+PRB
	endm
	
