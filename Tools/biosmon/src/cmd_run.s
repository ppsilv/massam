CMD_RUN:
                STA     LAST_CMD
                LDA     #<MSG4
                STA     MSGL
                LDA     #>MSG4
                STA     MSGH
                JSR     SHWMSG
                JSR     GET_ADDRESS
                LDY     #$00    
                JSR     CONV_ADDR_TO_HEX
                LDX     TMP1
                LDY     TMP2
                JSR     SWAP_XY
                STX     ADDR1L
                STY     ADDR1H
                ;JSR     PRINT_ADDR_HEXA
                JMP     (ADDR1L)
                JMP     NEXT_CHAR
