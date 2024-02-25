.setcpu "6502"
.segment "WOZMON"

;variaveis

LEDON   =   $8800
LEDOFF  =   $8801

RESET:                           ;codigo
                    SEI              ;Disable interrupt

                    
LOOP:       
                    LDX             #$00
                    STX              LEDON

                    JMP         LOOP
                    
                    
                    
;Cpu reset address
.segment    "RESETVEC"
                                        .word   $0F00
                                        .word   RESET
                                        .word   $0000
