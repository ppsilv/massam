.setcpu "65C02"
.segment "CODE"

.include "../../libs/pageZero.s"
		
RESET:
	sei						; No interrupt
	cld						; Set decimal
	ldx #$ff				; Set stack pointer
	txs						; 
	jsr	delay				;
	jsr initUart			; Configure uart to 9600 baudrate
	;jsr init_8255
	jsr	delay				;
	ldx #<Title1
	ldy #>Title1
	jsr PrintString
	ldx #<Title2
	ldy #>Title2
	jsr PrintString
NewLoop:
    lda #$0A                  
	jsr write_byte
    lda #$0D                  
	jsr write_byte
    lda #'>'                  
	jsr write_byte
	jsr	delay				;
	jsr	read_byte
	jsr	delay				;
	jsr write_byte
	cmp	#'H'
	beq	ShowCommands
	cmp	#'?'
	beq	ShowCommands
	cmp	#'P'
	beq	Poke
	jsr	delay				;
	jmp NewLoop		;;Infinit loop
ShowCommands:
	ldx #<showCmd
	ldy #>showCmd
	jsr PrintString
	jmp NewLoop
Poke:
	jsr	read_line
	ldx #<CMD_BUF
	ldy	#0
	lda (CMD_BUF),y
	jsr write_byte
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	iny
	lda (CMD_BUF),y
	jsr write_byte
	jmp NewLoop

Title1:
	.byte $0A,$0D,"6502 - SystemTest Copyright (C) 2024",CR,LF
	.byte "CPU HBC-56 - Spartan 56",CR,LF,CR,LF,0,0,0,0
Title2:
	.byte "CPU parameters: ",CR,LF
	.byte "Clock......:	1.8Mhz",CR,LF
	.byte "Memoria RAM:	32k",CR,LF
	.byte "Memoria ROM:	12k",CR,LF
	.byte "Serial.....:	16C550",CR,LF
	.byte "Serial clk.:	1.8Mhz",CR,LF
	.byte "Via........:	P8255A",CR,LF
	.byte "Decod......: GAL20V8B",CR,LF
	.byte "Bus........: SC112",CR,LF,0,0,0

showCmd:
	.byte	"H/? - show commands",CR,LF
	.byte	"M,<addr> 		- Set memory addr",CR,LF
	.byte	"S,<addr> 		- Show memory addr",CR,LF
	.byte	"P,<addr>,data 	- Poke data int addr memory",CR,LF
	.byte	"R,<addr> 		- Run program at memory addr",CR,LF
	.byte	"All address must be in hexadecimal $0000 to $FFFF",CR,LF
	.byte	"Commands Version 0.1.0",CR,LF,0,0,0

.include "serial16550.s"
.include "../../libs/delay.s"
;.include "drv8255a.s"

;Cpu reset address
.segment    "RESETVEC"

	.word   $0000
	.word   RESET
	.word   $0000
