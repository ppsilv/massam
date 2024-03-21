;Driver for P8255A

PORTA = $C100
PORTB = $C101
PORTC = $C102
DDR   = $C103


init_8255:
    lda $80
    sta DDR
    rts


    
