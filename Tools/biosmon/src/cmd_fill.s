
CMD_FILL:
            STA     LAST_CMD
            LDA     #<MSG11
            STA     MSGL
            LDA     #>MSG11
            STA     MSGH
            JSR     SHWMSG
            JSR     GETLINE
            ;Get addr from 
            LDY     #$00    
            JSR     CONV_ADDR_TO_HEX
            BCC     FIM_CMD_FILL
            LDX     TMP1
            LDY     TMP2
            JSR     SWAP_XY
            STX     ADDR1L
            STY     ADDR1H

            LDY     #$04   
            LDA     BIN,Y
            CMP     #'.'
            BNE     FILL_BLOCK_SYNTAX_ERROR

            ;Get addr to 
            LDY     #$05    
            JSR     CONV_ADDR_TO_HEX
            BCC     FIM_CMD_FILL
            LDX     TMP1
            LDY     TMP2
            JSR     SWAP_XY
            STX     ADDR2L
            STY     ADDR2H

            LDY     #$09   
            LDA     BIN,Y
            CMP     #':'
            BNE     FILL_BLOCK_SYNTAX_ERROR

            ;Get data to fill
            LDY     #$0A
            LDA     BIN,Y
            STA     RPHX
            INY
            LDA     BIN,Y
            STA     RPHY
            JSR     CONV_ASCII_2_HEX

            ;JSR     PRINT_ADDR_HEXA
FILL:       
            LDY     #$0
            LDA     TMP
            STA     (ADDR1L),Y
            JSR     INC_ADDR
            JSR     COMP_ADDR
            BCC     FILL
            LDY     #$0
            LDA     TMP
            STA     (ADDR1L),Y
                       
FIM_CMD_FILL:
            JMP     NEXT_CHAR
            
FILL_BLOCK_SYNTAX_ERROR:
            LDA     ERR03
            JMP     SYNTAX_ERROR             