 .setcpu "6502"
.segment "WOZMON"

;variaveis

LEDON   =   $8000
LEDOFF  =   $8001

RESET:                           ;codigo
                    sei
;;A15 A14 A13 A12  | A11 A10 A09 A08
;;    0      1      0     0   |     0     0      0      1
;;    0      1      0     0   |     0     0      1      0
LOOP:       
                    LDA             #$00
                    STA              $C000
                    NOP
                    NOP
                    NOP
                    NOP
                    LDA          #$FF
                    STA          $C800
                    NOP
                    NOP
                    NOP
                    NOP
                    JMP   LOOP   
                  
                    
;Cpu reset address
.segment    "RESETVEC"

                                        .word   $0F00
                                        .word   RESET
                                        .word   $0000
