;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  SND-LOW.S
;*  Low level sound routines which will always be present
;*  in every ROM bank.  Mainly to provide fast OS vectored
;*	access to VDP routines for M/C from BASIC
;*
;**********************************************************

;****************************************
;* snd_set
;* Set AY register X to value Y
;* Input : X = Reg no, Y = Value
;* Output : None
;* Regs affected : None
;****************************************
snd_set
	pha

	lda #0xff				; Set Port A to output
	sta IO_1 + DDRA

	stx SND_ADBUS			; Put X on the sound bus (X = reg address)

	lda SND_MODE			; Need to preserve contents of other bits
	and #SND_DESELECT_MASK	; Mask off mode bits
	ora #SND_SELSETADDR		; Select AY mode to latch address
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE

	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command
	
	sty SND_ADBUS			; Put Y on the sound bus (Y = value)
	ora #SND_SELWRITE		; Select mode for writing data
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE
	
	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command

	pla
	
	rts

;****************************************
;* snd_get
;* Get AY register X to Y
;* Input : X = Reg no
;* Output : Y = Value
;* Regs affected : None
;****************************************
snd_get
	pha

	lda #0xff				; Set Port A to output
	sta IO_1 + DDRA

	stx SND_ADBUS			; Put X on the sound bus (X = reg address)

	lda SND_MODE			; Need to preserve contents of other bits
	and #SND_DESELECT_MASK	; Mask off mode bits
	ora #SND_SELSETADDR		; Select AY mode to latch address
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE

	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command

	lda #0x00				; Set Port A to input
	sta IO_1 + DDRA

	lda SND_MODE			; Need to preserve contents of other bits
	and #SND_DESELECT_MASK	; Mask off mode bits
	ora #SND_SELREAD		; Select mode for reading data
	sta SND_MODE			; This write will process the data in ADBUS according to SND_MODE

	ldy SND_ADBUS			; Get value in to Y
	
	and #SND_DESELECT_MASK	; Mask off mode bits
	sta SND_MODE			; This write will deselect the AY ready for next command

	pla
	
	rts

;****************************************
;* snd_get_joy0
;* Return value of joystick 0
;* Input : None
;* Output : Y = Value
;* Regs affected : X
;****************************************
snd_get_joy0
	ldx #SND_REG_IOB		; Joystick is plugged in to IOB
	jsr snd_get				; Get IOB, result in Y
	rts
