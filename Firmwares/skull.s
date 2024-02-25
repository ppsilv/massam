.setcpu "6502"
.segment "CODE"
		
RESET:
	sei						; No interrupt
	cld						; Set decimal
	ldx #$ff				; Set stack pointer
	txs						; 
	jsr init_9600			; Configure uart to 9600 baudrate
	jsr	delay				;No need but why not?
	jsr ClearScreen

Loop:
; Display Welcome message
	LDX #<WelcomeMessage
	LDY #>WelcomeMessage
	JSR PrintString
	jsr delay
	jmp Loop		;;Infinit loop

WelcomeMessage:
	.byte CR,"SPARTAN - Test of P8255A...",CR,LF,0


;Cpu reset address
.segment    "RESETVEC"

	.word   $0F00
	.word   RESET
	.word   $0000
