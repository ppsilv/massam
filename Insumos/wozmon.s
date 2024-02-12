	.ORG *


;variaveis

LEDON   =   $8800
LEDOFF  =   $8801

RESET:                           ;codigo
                    SEI              ;Disable interrupt

                    
LOOP:       
                    LDX             #$00
                    STX              LEDON
                    ldy                 #$FF
DELAY:
                    JMP             tempo1
ret1:                    
                    DEY 
                    BNE         DELAY
                    LDX             #$FF
                    STX           LEDOFF
                    ldy                 #$FF
DELAY1:
                    JMP            tempo2
ret2:                    
                    DEY 
                    BNE         DELAY1
                    JMP         LOOP

tempo1:
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    JMP  ret1   
tempo2:
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    NOP
                    JMP  ret2   
                  
                    
;Cpu reset address
;.segment    "RESETVEC"

                                        .word   $0F00
                                        .word   RESET
                                        .word   $0000
