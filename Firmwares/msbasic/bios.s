;***********************************************************************
; SERIAL 16c550 DRIVER
;
; Version.: 0.0.4
;
; The verion 0.0.3 does not has the change of read and write bytes to support msbasic.
;

.setcpu "6502"


.zeropage
.org ZP_START5
RACC: .res 1     ;= $30               ;;: .res 1
;RPHY     ;= $31               ;;: .res 1
;RPHX     ;= $32               ;;: .res 1
MSGL: .res 1     ;= $33
MSGH: .res 1     ;= $34
TMP:     .res 1 ;= $35              ;;TEMPORARY REGISTERS
TMP1:    .res 1 ;= $36
TMP2:    .res 1 ;= $37
LAST_CMD:.res 1 ;= $38  
ADDR1L:  .res 1 ;= $39          ; Digito 4 A do hexa 0xABCD
ADDR1H:  .res 1 ;= $3A          ; Digito 3 B do hexa 0xABCD
ADDR2L:  .res 1 ;= $3B          ; Digito 2 C do hexa 0xABCD
ADDR2H:  .res 1 ;= $3C          ; Digito 1 D do hexa 0xABCD
BSZ:     .res 1 ;= $3D          ; string size in buffer 
ERRO:    .res 1 ;= $3E          ; CODIGO DO ERRO
COUNTER: .res 1 ;= $3F
;
BIN      = $200          ; Buffer size = 128 bytes


.segment "BIOS"

;*************************************************************
;*************************************************************
; RESET
;*************************************************************
;*************************************************************

RESET:
	            SEI					; No interrupt
	            CLD					; Set decimal
	            LDX #$FE 			; Set stack pointer
	            TXS

                ;;Initializing some variables
                LDA     #$00
                STA     ADDR1L
                STA     ADDR1H
                STA     ADDR2L
                STA     ADDR2H

                JSR     INITUART
                LDA     #<MSG1
                STA     MSGL
                LDA     #>MSG1
                STA     MSGH
                JSR     SHWMSG
NEXT_CHAR:
                LDA     #$0D
                JSR     WRITE_BYTE
                LDA     #'>'
                JSR     WRITE_BYTE
                
                JSR     READ_BYTE
                JSR     WRITE_BYTE
                CMP     #'Q'            ;Show memory address data format: ADDR
                BEQ     TEMP_Q
                CMP     #'D'            ;Dump de memoria format: ADDR:ADDR
                BEQ     TEMP_D
                CMP     #'M'            ;Put byte into memory address
                BEQ     TEMP_M
                CMP     #'R'            ;Run programa na format: ADDR R
                BEQ     TEMP_R
                CMP     #'H'            ;Show help 
                BEQ     TEMP_H
                JMP     NEXT_CHAR
TEMP_Q:         RTS
TEMP_D:         JMP     DIGITOU_D
TEMP_M:         JMP     DIGITOU_M
TEMP_R:         JMP     DIGITOU_R
TEMP_H:         JMP     DIGITOU_H
              
DIGITOU_S:      
                STA     LAST_CMD
                LDA     #<MSG2
                STA     MSGL
                LDA     #>MSG2
                STA     MSGH
                JSR     SHWMSG
                JSR     GETLINE
                LDA     #<BIN
                STA     MSGL
                LDA     #>BIN
                STA     MSGH
                JSR     SHWMSG
                RTS
                JMP     NEXT_CHAR
DIGITOU_D:
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
                CMP     #$3E
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
                JSR     PRBYTE    
                LDA     ADDR1L
                JSR     PRBYTE    
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
                JSR     PRBYTE    
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
                JSR     PRBYTE    
                LDA     ADDR1L
                JSR     PRBYTE    
                LDA     #' '
                JSR     WRITE_BYTE
                ;addressing mode of 65C02
                ;LDA     (ADDR1L)
                ;addressing mode of 6502
                LDY     #$0
                LDA     (ADDR1L),Y

                JSR     PRBYTE    
DIGITOU_D_SHOWMEM_FIM:
                JMP     NEXT_CHAR

DIGITOU_M:      
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
                JSR     NO_ROL_RIGHT
                ORA     TMP1
                STA     TMP1
                ;addressing mode of 65C02
                ;STA     (ADDR1L)
                ;addressing mode of 6502
                LDY     #$0
                STA     (ADDR1L),Y                

DIGITOU_M_FIM:                
                JMP     NEXT_CHAR

DIGITOU_H:
                STA     LAST_CMD
                LDA     #<HELP
                STA     MSGL
                LDA     #>HELP
                STA     MSGH
                JSR     SHWMSG
                JMP     NEXT_CHAR

DIGITOU_R:
                STA     LAST_CMD
                LDA     #<MSG4
                STA     MSGL
                LDA     #>MSG4
                STA     MSGH
                JSR     SHWMSG
                JSR     DIGITOU_S
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
SWAP_XY:
                STY     TMP     ; Y 2 M
                TXA             ; X 2 A
                TAY             ; A 2 Y    
                LDX     TMP     ; M 2 X
                RTS


ROL_LEFT:
                JSR     CONV_HEX_1DIG
                BCC     CONV_HEX_4DIG_FIM
                ROL
                ROL
                ROL
                ROL
                AND     #$F0
                RTS
NO_ROL_RIGHT:
                JSR     CONV_HEX_1DIG
                BCC     CONV_HEX_4DIG_FIM
                AND     #$0F
                RTS
CONV_HEX_4DIG_FIM:
                LDA     #<MSG6
                STA     MSGL
                LDA     #>MSG6
                STA     MSGH
                JSR     SHWMSG
                LDA     #$01
                STA     ERRO
                CLC
                RTS                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONV_ADDR_TO_HEX:
;
CONV_ADDR_TO_HEX:
                ;;Dig 4
                LDA     BIN,Y
                JSR     ROL_LEFT    
                STA     TMP1
                ;;Dig 3
                INY
                LDA     BIN,Y
                JSR     NO_ROL_RIGHT
                ORA     TMP1
                STA     TMP1
                ;;Dig 2
                INY
                LDA     BIN,Y
                JSR     ROL_LEFT
                STA     TMP
                ;;Dig 1
                INY
                LDA     BIN,Y
                JSR     NO_ROL_RIGHT
                ORA     TMP
                STA     TMP2

                SEC
                RTS

;*******************************************
;CONV_HEX_1DIG:  
;Parameter: A digit to be converted
;Return...: A digit converted
CONV_HEX_1DIG:  
                CMP     #$30
                BCC     CONV_HEX_1DIG_FIM
                CMP     #$3A
                BCC     DIG_0_A_9
                CMP     #$41
                BCS     DIG_A_TO_Z
                ;CARACTER PODE SER UM DESSES : ; < = > ? @
                CLC     ;CLEAR CARRY FLAG DIG NOT CONVERTED
                RTS
DIG_A_TO_Z:     
                CMP     #$47
                BCS     CONV_HEX_1DIG_FIM
                CLC
                SBC     #$36
                SEC     ;SET CARRY FLAG DIG CONVERTED
                RTS                
DIG_0_A_9:
                CLC
                SBC     #$2F
                SEC     ;SET CARRY FLAG DIG CONVERTED
                RTS
CONV_HEX_1DIG_FIM:  
                CLC
                RTS
;********************************************
;Print 4 digits hexadecimal
PRINT_ADDR_HEXA:
                LDA     #'['
                JSR     WRITE_BYTE
                LDA     ADDR1L
                JSR     PRBYTE
                LDA     ADDR1H
                JSR     PRBYTE
                LDA     LAST_CMD
                CMP     #'D'
                BNE     PRINT_ADDR_HEXA_FIM
                LDA     #'.'
                JSR     WRITE_BYTE
                LDA     ADDR2L
                JSR     PRBYTE
                LDA     ADDR2H
                JSR     PRBYTE
PRINT_ADDR_HEXA_FIM:                
                LDA     #']'
                JSR     WRITE_BYTE
                RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GETLINE:        LDY     #$00
GETLINE1:       JSR     READ_BYTE
                JSR     WRITE_BYTE
                STA     BIN,Y
                INY
                CMP     #$0D
                BNE     GETLINE1     
                LDA     #$00
                STA     BIN,Y
                STY     BSZ
                RTS
SHWMSG:          LDY #$0
SMSG:            LDA (MSGL),Y
                 BEQ SMDONE
                 JSR WRITE_BYTE
                 INY 
                 BNE SMSG
SMDONE:          RTS 

PRBYTE:     PHA             ;Save A for LSD.
            LSR
            LSR
            LSR             ;MSD to LSD position.
            LSR
            JSR PRHEX       ;Output hex digit.
            PLA             ;Restore A.
PRHEX:      AND #$0F        ;Mask LSD for hex print.
            ORA #$B0        ;Add "0".
            CMP #$BA        ;Digit?
            BCC ECHO        ;Yes, output it.
            ADC #$06        ;Add offset for letter.
ECHO:       PHA             ;*Save A
            AND #$7F        ;*Change to "standard ASCII"
            JSR  WRITE_BYTE
            PLA             ;*Restore A
            RTS             ;*Done, over and out...
;Incrementa endereco
INC_ADDR:
            CLC
            LDA #$01
            ADC ADDR1L
            STA ADDR1L
            LDA #$00
            ADC ADDR1H
            STA ADDR1H
            RTS
;Compara enderecos            
COMP_ADDR:
            LDA ADDR1H
            CMP ADDR2H
            BNE COMP_ADDR_FIM
            LDA ADDR1L
            CMP ADDR2L
COMP_ADDR_FIM:
            RTS

VERSION:    .byte "0.0.4"
MSG1:            .byte CR,LF,"PDSILVA - BIOSMON 2024 - Version: ",CR,0
MSG2:            .byte CR,"Input Addr: ",CR,0
MSG3:            .byte CR,"Dump Mem. Addr: Fmt XXXX>XXXX or XXXX:",CR,0
MSG4:            .byte CR,"Run program in Addr: Format abcd",CR,0
MSG5:            .byte CR,"EXECUTADO",CR,0
MSG6:            .byte CR,"Hex conv. error",CR,0
MSG7:            .byte CR,"Poke: Fmt addr:dt",CR,0
HELP:            .byte CR,"Help BIOSMON v 0.1",CR,LF
                 .byte "Commands:",CR
                 .byte "         S - Put data into buffer",CR
                 .byte "         D - Dump memory",CR
                 .byte "         M - Poke",CR
                 .byte "         R - Run program",CR
                 .byte "         H - Show help",CR,LF,0

;Used just for test of run cmd. 

OLD_WOZ:
                LDA     #<MSG5
                STA     MSGL
                LDA     #>MSG5
                STA     MSGH
                JSR     SHWMSG
                JMP     NEXT_CHAR

.include "drv16550.s"

.segment "RESETVEC"

                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector
