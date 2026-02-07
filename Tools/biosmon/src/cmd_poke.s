CMD_POKE:      
                STA     LAST_CMD
                LDA     #<MSG7
                STA     MSGL
                LDA     #>MSG7
                STA     MSGH
                JSR     SHWMSG
                JSR     GETLINE
                ;Get addr from 
                LDY     #$00    
                JSR     CONV_ADDR_TO_HEX
                LDX     TMP1
                LDY     TMP2
                JSR     SWAP_XY
                STX     ADDR1L
                STY     ADDR1H

                ;VERIFICAR SE O COMANDO É :
                LDY     #$04   
                LDA     BIN,Y
                CMP     #$3A
                BNE     DIGITOU_M_FIM

                LDY     #$05
                LDA     BIN,Y
                JSR     ROL_LEFT    
                STA     TMP1
                INY
                LDA     BIN,Y
                JSR     GET_DIG_RIGHT
                ORA     TMP1
                STA     TMP1
                ;addressing mode of 65C02
                ;STA     (ADDR1L)
                ;addressing mode of 6502
                LDY     #$0
                STA     (ADDR1L),Y                

DIGITOU_M_FIM:                
                JMP     NEXT_CHAR
