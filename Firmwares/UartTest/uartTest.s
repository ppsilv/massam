.setcpu "6502"
.segment "UART"



RESET:                      ;codigo
    sei
    cld
    ldx #$ff
    txs
    jsr init_9600

LOOP:       
    
    jsr	delay

    lda #$41
    jsr write_byte

    jsr	delay

    JMP LOOP   

delay:
        ldy  #$ff   ; (2 cycles)
        ldx  #$ff   ; (2 cycles)
delay1: dex         ; (2 cycles)
        bne  delay1 ; (3 cycles in loop, 2 cycles at end)
        dey         ; (2 cycles)
        bne  delay1 ; (3 cycles in loop, 2 cycles at end)
	rts

                  
.include "uart.s"

;Cpu reset address
.segment    "RESETVEC"

            .word   $0F00
            .word   RESET
            .word   $0000
