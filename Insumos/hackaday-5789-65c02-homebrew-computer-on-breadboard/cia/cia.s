;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  CIA.S
;*  Code to initialise and utilise the two WDC65c22 VIAs
;*
;*  VIA1 is for keyboard, LEDs and RAM memory banking
;*		Port A
;*			PA0 to PA7 	- All output to keyboard
;*		Port B
;*			PB0			- Input from BBC keboard to sense matrix
;*			PB1			- Output - Led 0 (cassette motor Led)
;*			PB2			- Output - Led 1 (caps lock Led)
;*			PB3			- Output - Led 2 (shift lock Led)
;*			PB4			- Output bit X0 RAM bank selector
;*			PB5			- Output bit X1 RAM bank selector
;*			PB6			- Output bit Y0 ROM bank selector
;*			PB7			- Output bit Y1 ROM bank selector
;*
;*  VIA2 is for AY-3-8910 sound chip, SD Card interface and ROM Disable
;*		Port A
;*			PA0 to PA7	- Connected to 8910 data bus for input or output
;*		Port B
;*			PB0			- Output to SD card clock
;*			PB1			- Output - Sound write select
;*			PB2			- Input - SD Card detect
;*			PB3			- Output - SD Card chip select
;*			PB4			- Output - Data out from VIA to SD Card
;*			PB5			- Output - ROM Disable (active low)
;*			PB6			- Output - Sound read select
;*			PB7			- Input - Data in to VIA from SD Card
;*
;*  This file is called cia.s because the original design
;*  used a MOS 6526 from a CMB64.  However I updated the HW
;*  design to use two 6522 chips, but never got around to
;*  renaming the file ;-)
;*
;**********************************************************


	; ROM code
	code

mod_sz_cia_s
	
;********************************
;* set_led0
;* Set the LED0 (cassette motor)
;* Input : C = status (1 = on, 0 = off)
;* Output : None
;* Regs affected : None
;****************************************
set_led0
	pha							; Save A
	lda IO_0 + PRB				; Get current led status
	ora #KB_LED0					; Initially assume off
	bcc skip_led0_on
	eor #KB_LED0					; Switch on if C=1
skip_led0_on
	sta IO_0 + PRB				; Set the leds
	pla							; Restore A
	rts

;********************************
;* set_led1
;* Set the LED1 (caps lock)
;* Input : C = status (1 = on, 0 = off)
;* Output : None
;* Regs affected : None
;****************************************
set_led1
	pha							; Save A
	lda IO_0 + PRB				; Get current led status
	ora #KB_LED1				; Initially assume off
	bcc skip_led1_on
	eor #KB_LED1				; Switch on if C=1
skip_led1_on
	sta IO_0 + PRB				; Set the leds
	pla							; Restore A
	rts

;********************************
;* set_led2
;* Set the LED2 (shift lock)
;* Input : C = status (1 = on, 0 = off)
;* Output : None
;* Regs affected : None
;****************************************
set_led2
	pha							; Save A
	lda IO_0 + PRB				; Get current led status
	ora #KB_LED2				; Initially assume off
	bcc skip_led2_on
	eor #KB_LED2				; Switch on if C=1
skip_led2_on
	sta IO_0 + PRB				; Set the leds
	pla							; Restore A
	rts

;****************************************
;* init_cia0
;* Initialise cia 0, controls the BBC keyboard
;* Input : None
;* Output : None
;* Regs affected : A
;****************************************
init_cia0
	lda #0x7f					; Disable all interrupts
	sta IO_0 + IER
	lda #0xff					; Clear IFR
	sta IO_0 + IFR				; Set IFR to clear flags
	

	lda #0xff			
	sta IO_0 + DDRA				; Port A all output

	lda #0xfe					; Make sure all outputs are high!
	sta IO_0 + PRB
	
	sta IO_0 + DDRB				; Port B output for leds and ROM,RAM banking

	lda #0x00					; Init control register - nothing doing
	sta IO_0 + ACR
	lda #0x02					; CA2 independent interrupt
	sta IO_0 + PCR

	lda #KB_EN 					; Set KB_EN bit to allow h/w strobe
	sta IO_0 + PRA
	
	; LEDS off
	sec
	jsr set_led0
	jsr set_led1
	jsr set_led2

	rts							; return from sub
	
;****************************************
;* init_cia1
;* Initialise cia 1, controls the sound chip
;* Input : None
;* Output : None
;* Regs affected : A
;****************************************
init_cia1
	lda #0x7f					; Disable all interrupts
	sta IO_1 + IER
	
	lda #0xff					; Port A all output (AY-3 data bus)
	sta IO_1 + DDRA
	
	lda #MM_DIS					; Make sure ROM is enabled in port B before
	sta IO_1+PRB				; setting the data direction register!
	
	lda #0b01111011				; Set Port B input/output SD, AY + DIS)
	sta IO_1+DDRB
	
	lda #0x00					; Init control register - nothing doing
	sta IO_1 + ACR
	sta IO_1 + PCR

	lda #0xff					; Clear IFR
	sta IO_1 + IFR				; Read ICR to clear flags
	
	rts							; return from sub

mod_sz_cia_e
