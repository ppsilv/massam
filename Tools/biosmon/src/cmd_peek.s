CMD_PEEK:
                STA     LAST_CMD
                LDA     #<MSG71
                STA     MSGL
                LDA     #>MSG71
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
                LDY     #$00   
                LDA     (ADDR1L),Y
                JSR     PRBYTE
                JMP     NEXT_CHAR