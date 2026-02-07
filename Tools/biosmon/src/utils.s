RESULT_H  : .res 1
RESULT_L  : .res 1 
DADO1_L   = ADDR1L
DADO1_H   = ADDR1H
DADO2_L   = ADDR2L
DADO2_H   = ADDR2H
FROM      = ADDR1L
TO        = ADDR2L
LENGHT    : .res 2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert 2 bytes ascii in 1 byte hexa
; Ex.: 41 35 = $A5                
; Input : RPHX with byte to be converted
;         RPHY with byte to be converted
; Ouput : TMP with byte converted
; Registers affected: A
;
CONV_ASCII_2_HEX:
                ;;Digit high byte
                LDA     RPHX
                JSR     ROL_LEFT
               ; BCC     @FIM
                STA     TMP
                ;;Digit Low byte
                LDA     RPHY
                JSR     GET_DIG_RIGHT
               ; BCC     @FIM
                ORA     TMP
                STA     TMP
                LDA     TMP
@FIM:           
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert a number in Acc frp, HEX to ASCII
; Input.: Acc number to be converted 
; Output: Acc number converted
; Registers affected: A
; The data must be in 01 to 0F
; OBS: THIS ROUTINE ASSUMES THE VALUE IN ACC IS A VALID 
;      HEXACIMAL 
; 
HEX_2_ASC:
            CMP     #$A
            BCC     IT_IS_NUMBER
            ADC     #6
IT_IS_NUMBER:            
            ADC     #$30
            RTS

ASC_2_HEX:
            CMP     #$3A         
            BCC     @IT_IS_NUMBER
            CLC
            SBC     #7
@IT_IS_NUMBER:
            SBC     #$2F
            RTS    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRINT_HEXA: Print the data hexadecimal in Acc
; Inputs: Acc = byte to be printed
; 
; Registers affected: A
;
PRINT_HEXA:
            PHA    
            JSR    ROTATE_RIGHT
            JSR    PRHIGH_NIBBLE
            PLA
            AND    #$0F     
PRHIGH_NIBBLE:
            JSR    HEX_2_ASC
            JSR    WRITE_BYTE
            RTS             ;*Done, over and out...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The same as PRINT_HEXA
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
ECHO:       
            AND #$7F        ;*Change to "standard ASCII"
            JSR  WRITE_BYTE
            RTS             ;*Done, over and out...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy memory block with size below 256
; Inputs: BASE = Address origin of copy
;         DEST = Address destiny of copy
;         LENGHT = Total of bytes to copy
; Registers affected: A, X
;
COPY_BLK_255:
        LDX     LENGHT
NEXT_BYTE:
        LDA     FROM, X        
        STA     TO,X
        DEX
        BNE     NEXT_BYTE
        RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sum 2 16bits data
; DADO1 + DADO2 = RESULT
; Registers affected: A
;
SUM_2_16BITS:
        CLC
        LDA     DADO1_L
        ADC     DADO2_L
        STA     RESULT_L
        LDA     DADO1_H
        ADC     DADO2_H
        STA     RESULT_H
        RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subtract 2 16bits data
; DADO1 - DADO2 = RESULT
; Registers affected: A
;
SUBTRACT_2_16BITS:
        SEC
        LDA     DADO1_L
        SBC     DADO2_L
        STA     RESULT_L
        LDA     DADO1_H
        SBC     DADO2_H
        STA     RESULT_H
        RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inc Address
; Registers affected: A
;
INC_ADDR:
            CLC
            LDA #$01
            ADC ADDR1L
            STA ADDR1L
            LDA #$00
            ADC ADDR1H
            STA ADDR1H
            RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compara enderecos            
; Registers affected: None
;
COMP_ADDR:
            LDA ADDR1H
            CMP ADDR2H
            BNE COMP_ADDR_FIM
            LDA ADDR1L
            CMP ADDR2L
COMP_ADDR_FIM:
            RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ROTATE_RIGHT: 
; Rotate the Acc 4 times to right and get the hy nibble of
; acumulator.
; Registers affected: A
;
ROTATE_RIGHT:
                ROR
                ROR
                ROR
                ROR
                AND     #$0F
                RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GET_ADDRESS:     Get input from keyboard and put it in BIN
; Inputs: NONE
;
; Registers affected: A, Y
;
GET_ADDRESS:      
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SHWMSG: Show message from pointer MSGL in FP
; Inputs: MSGL
;
; Registers affected: A, Y
;
;         
SHWMSG:          
                LDY #$0
SMSG:           
                LDA (MSGL),Y
                BEQ SMDONE
                JSR WRITE_BYTE
                INY 
                BNE SMSG
SMDONE:         
                RTS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subtract (TMP Acc) - (TMP2 TMP1)
; TMP High byte   TMP2 High byte
; Acc Low byte    TMP1 low byte
; Result in TMP2,TMP1
;
SUBTRACT_2_BYTES:
    SEC
    SBC     TMP1    
    STA     TMP1
    LDA     TMP
    SBC     TMP2
    STA     TMP2
    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GETLINE: Get data inputed from keyboard and
;         put it into buffer BIN
; Inputs: NONE
;
; Registers affected: A, Y
;
GETLINE:        LDY     #$00
GETLINE1:       JSR     READ_BYTE
                ;JSR     WRITE_BYTE
                STA     BIN,Y
                INY
                CMP     #$0D
                BNE     GETLINE1     
                LDA     #$00
                STA     BIN,Y
                STY     BSZ
                RTS

ROL_LEFT:       
                JSR     ASC_2_HEX
                ROL
                ROL
                ROL
                ROL
                AND     #$F0
                RTS

GET_DIG_RIGHT:
                JSR     ASC_2_HEX
                AND     #$0F
                RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONV_ADDR_TO_HEX:
; Ex.: 46 45 31 30 = $FE10
; Convert 4 bytes ASCII in 2 bytes hexa. 
;
CONV_ADDR_TO_HEX:
                ;;Dig 4
                LDA     BIN,Y
                STA     RPHX
                ;;Dig 3
                INY
                LDA     BIN,Y
                STA     RPHY
                JSR     CONV_ASCII_2_HEX
                ;BCC     @FIM
                STA     TMP1
                ;;Dig 2
                INY
                LDA     BIN,Y
                STA     RPHX
                ;;Dig 1
                INY
                LDA     BIN,Y
                STA     RPHY
                JSR     CONV_ASCII_2_HEX
                ;BCC     @FIM
                STA     TMP2

                SEC
                RTS
;@FIM:
                RTS

SWAP_XY:
                STY     TMP     ; Y 2 M
                TXA             ; X 2 A
                TAY             ; A 2 Y    
                LDX     TMP     ; M 2 X
                RTS

FORMAT_ADDRESS:
            ;Get addr from 
            LDY     #$00    
            JSR     CONV_ADDR_TO_HEX
            BCC     FORMAT_FIM
            LDX     TMP1
            LDY     TMP2
            JSR     SWAP_XY
            STX     ADDR1L
            STY     ADDR1H

            LDY     #$04   
            LDA     BIN,Y
            CMP     #'.'
            BNE     FORMAT_ERROR

            ;Get addr to 
            LDY     #$05    
            JSR     CONV_ADDR_TO_HEX
            BCC     FORMAT_FIM
            LDX     TMP1
            LDY     TMP2
            JSR     SWAP_XY
            STX     ADDR2L
            STY     ADDR2H
            RTS
FORMAT_16BITS_DATA:
            LDY     #$09   
            LDA     BIN,Y
            CMP     #':'
            BNE     FORMAT_ERROR
            LDY     #$0A    
            JSR     CONV_ADDR_TO_HEX
            BCC     FORMAT_FIM
            LDX     TMP1
            LDY     TMP2
            JSR     SWAP_XY
            STX     LENGHT
            STY     LENGHT+1
            RTS    
FORMAT_ERROR:
            LDA     ERR03
            JMP     SYNTAX_ERROR 
FORMAT_FIM:
            JMP     NEXT_CHAR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
GET_ADDRESS_HEX:
            JSR     GET_ADDRESS

            ;First byte    
            LDY     #$00
            LDA     BIN,Y
            STA     RPHX
            LDY     #$01
            LDA     BIN,Y
            STA     RPHY
            JSR     CONV_ASCII_2_HEX
            STA     ADDR1H
            ;Second byte    
            LDY     #$02
            LDA     BIN,Y
            STA     RPHX
            LDY     #$03
            LDA     BIN,Y
            STA     RPHY
            JSR     CONV_ASCII_2_HEX
            STA     ADDR1L
            RTS       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Verify app.
; $FE = disasm Disassembler for 6502
; $FD = basic  Basic Interpreter
; $FF,$A5,$5A,$FE                 
VERIFY_APP:
           LDA  $A000
           CMP  #$FF
           BNE  VERIFY_APP_FIM
           LDA  $A001
           CMP  #$A5
           BNE  VERIFY_APP_FIM
           LDA  $A002
           CMP  #$5A
           BNE  VERIFY_APP_FIM
           LDA  $A003
           CMP  #$FE
           BNE  VERIFY_APP_FIM
           LDA  #$FE           
           STA  APP_TABLE     
           LDA  #$A0
           STA  APP_TABLE + 1     
VERIFY_APP_FIM:
           RTS     
                      
;;********************************************
;;Print 4 digits hexadecimal
;PRINT_ADDR_HEXA:
;                LDA     #'['
;                JSR     WRITE_BYTE
;                LDA     ADDR1H
;                JSR     PRINT_HEXA ;PRBYTE
;                LDA     ADDR1L
;                JSR     PRBYTE
;                LDA     LAST_CMD
;                CMP     #'D'
;                BNE     PRINT_ADDR_HEXA_1
;                LDA     #'.'
;                JSR     WRITE_BYTE
;PRINT_ADDR_HEXA_1:
;                LDA     ADDR2H
;                JSR     PRINT_HEXA ;PRBYTE
;                LDA     ADDR2L
;                JSR     PRBYTE
;                LDA     #']'
;                JSR     WRITE_BYTE
;                RTS
    

;;;
;;; EXPERIMENTAL
;;; 
         

