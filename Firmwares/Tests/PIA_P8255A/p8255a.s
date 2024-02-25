.setcpu "6502"
.segment "CODE"

.include "../../libs/pageZero.s"
		
RESET:
	sei						; No interrupt
	cld						; Set decimal
	ldx #$ff				; Set stack pointer
	txs						; 
	jsr init_9600			; Configure uart to 9600 baudrate
	jsr init_8255			
	jsr	delay				;No need but why not?
	jsr ClearScreen

Loop:
    ; Display Welcome message
	lda #24
	sta Q
@loop:
	LDX #<WelcomeMessage
	LDY #>WelcomeMessage
	jsr PrintString
	dec Q
	bne @loop
	lda #$00
	sta PORTA
	lda #$00
	sta PORTB
	lda #$00
	sta PORTC
	jsr delay
	jsr ClearScreen
	lda #$FF
	sta PORTA
	lda #$FF
	sta PORTB
	lda #$FF
	sta PORTC
	jmp Loop		;;Infinit loop

.include "../../libs/uartinit.s"
.include "../../libs/delay.s"
.include "drv8255a.s"

WelcomeMessage:
	.byte "SPARTAN - Test of P8255A...",CR,LF,0


;Cpu reset address
.segment    "RESETVEC"

	.word   $0F00
	.word   RESET
	.word   $0000
