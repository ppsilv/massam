;Driver for P8255A

PORTA = $C100
PORTB = $C101
PORTC = $C102
DDR   = $C103


init_8255:
    lda $80
    sta DDR
    rts

piscaA:
	ldx  #$5
@piscaA: 
	nop
	dex
    lda #$0
    sta PORTA
    jsr delay3
    lda #$FF
    sta PORTA
    jsr delay3
	bne  @piscaA
    rts

piscaB:
	ldx  #$5
@piscaB: 
	nop
	dex
    lda #$0
    sta PORTB
    jsr delay3
    lda #$FF
    sta PORTB
    jsr delay3
	bne  @piscaB
    rts
    
piscaC:
	ldx  #$5
@piscaC: 
	nop
	dex
    lda #$0
    sta PORTC
    jsr delay3
    lda #$FF
    sta PORTC
    jsr delay3
	bne  @piscaC
    rts
