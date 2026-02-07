CMD_DUMP:
                STA     LAST_CMD
                LDA     #<MSG3
                STA     MSGL
                LDA     #>MSG3
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

                LDY     #$04   
                LDA     BIN,Y
                CMP     #'.'
                BNE     DIGITOU_D_SHOWMEM

                ;Get addr to 
                LDY     #$05    
                JSR     CONV_ADDR_TO_HEX
                LDX     TMP1
                LDY     TMP2
                JSR     SWAP_XY
                STX     ADDR2L
                STY     ADDR2H
                
                ;JSR     PRINT_ADDR_HEXA
                
                LDA     #$08
                STA     TMP2    
LINHA:          LDX     #$08
                LDA     #$0D
                JSR     WRITE_BYTE
                LDA     ADDR1H
                JSR     PRINT_HEXA    
                LDA     ADDR1L
                JSR     PRINT_HEXA    
                LDA     #' '
                JSR     WRITE_BYTE
DIGITOU_D_WORK:
                ;addressing mode of 65C02
                ;LDA     (ADDR1L)
                ;addressing mode of 6502
                LDY     #$0
                ;to work ADDR1L must be in zeropage
                ;and register must be Y
                LDA     (ADDR1L),Y   
                ;******************
                JSR     PRINT_HEXA    
                LDA     #' '
                JSR     WRITE_BYTE
                JSR     INC_ADDR
                JSR     COMP_ADDR
                BEQ     DIGITOU_D_WORK
                BCS     DIGITOU_D_FIM
                ;JSR     PRINT_ADDR_HEXA                
                ;JSR     READ_BYTE
                DEX
                BEQ     LINHA
                JMP     DIGITOU_D_WORK
DIGITOU_D_FIM:
                JMP     NEXT_CHAR
DIGITOU_D_SHOWMEM:
                LDY     #$04   
                LDA     BIN,Y
                CMP     #$3A
                BEQ     DIGITOU_D_SHOWMEM_FIM
                LDA     ADDR1H
                JSR     PRINT_HEXA    
                LDA     ADDR1L
                JSR     PRINT_HEXA    
                LDA     #' '
                JSR     WRITE_BYTE
                ;addressing mode of 65C02
                ;LDA     (ADDR1L)
                ;addressing mode of 6502
                LDY     #$0
                LDA     (ADDR1L),Y

                JSR     PRINT_HEXA    
DIGITOU_D_SHOWMEM_FIM:
                JMP     NEXT_CHAR

