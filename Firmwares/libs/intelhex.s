


IN       = $0200          ;*Input buffer

;External routines
GETCHAR:
	rts 
SHWMSG:
	rts 
ECHO:  
	rts 




;+---------------------------------------------------------------------------+
;|Load an program in Intel Hex Format.                                       |
;|Subroutines needed:                                                        |
;|echo.....: prints a character                                              |
;|shwmsg...: prints a string                                                 |
;|getchar..: read a character from uart                                      |
;|gethex...: read a hex-character from uart                                  |
;|                                                                           |
;+---------------------------------------------------------------------------+
LOADINTEL:
   LDA #$0D
   JSR ECHO      ;New line.
   LDA #<MSG2
   STA MSGL
   LDA #>MSG2
   STA MSGH
   JSR SHWMSG      ;Show Start Transfer.
   LDA #$0D
   JSR ECHO      ;New line.
   LDY #$00
   STY CRCCHECK   ;If CRCCHECK=0, all is good.
INTELLINE:
   JSR GETCHAR      ;Get char
   STA IN,Y      ;Store it
   INY            ;Next
   CMP   #$1B      ;Escape ?
   BEQ   INTELDONE   ;Yes, abort.
   CMP #$0D      ;Did we find a new line ?
   BNE INTELLINE   ;Nope, continue to scan line.
   LDY #$FF      ;Find (:)
FINDCOL:
   INY
   LDA IN,Y
   CMP #$3A      ; Is it Colon ?
   BNE FINDCOL      ; Nope, try next.
   INY            ; Skip colon
   LDX   #$00      ; Zero in X
   STX   CRC         ; Zero Check sum
   JSR GETHEX      ; Get Number of bytes.
   STA COUNTER      ; Number of bytes in Counter.
   CLC            ; Clear carry
   ADC CRC         ; Add CRC
   STA CRC         ; Store it
   JSR GETHEX      ; Get Hi byte
   STA STH         ; Store it
   CLC            ; Clear carry
   ADC CRC         ; Add CRC
   STA CRC         ; Store it
   JSR GETHEX      ; Get Lo byte
   STA STL         ; Store it
   CLC            ; Clear carry
   ADC CRC         ; Add CRC
   STA CRC         ; Store it
   LDA #$2E      ; Load "."
   JSR ECHO      ; Print it to indicate activity.
NODOT:
   JSR GETHEX      ; Get Control byte.
   CMP   #$01      ; Is it a Termination record ?
   BEQ   INTELDONE   ; Yes, we are done.
   CLC            ; Clear carry
   ADC CRC         ; Add CRC
   STA CRC         ; Store it
INTELSTORE:
   JSR GETHEX      ; Get Data Byte
   STA (STL,X)      ; Store it
   CLC            ; Clear carry
   ADC CRC         ; Add CRC
   STA CRC         ; Store it
   INC STL         ; Next Address
   BNE TESTCOUNT   ; Test to see if Hi byte needs INC
   INC STH         ; If so, INC it.
TESTCOUNT:
   DEC   COUNTER      ; Count down.
   BNE INTELSTORE   ; Next byte
   JSR GETHEX      ; Get Checksum
   LDY #$00      ; Zero Y
   CLC            ; Clear carry
   ADC CRC         ; Add CRC
   BEQ INTELLINE   ; Checksum OK.
   LDA #$01      ; Flag CRC error.
   STA   CRCCHECK   ; Store it
   JMP INTELLINE   ; Process next line.

INTELDONE:
   LDA CRCCHECK   ; Test if everything is OK.
   BEQ OKMESS      ; Show OK message.
   LDA #$0D
   JSR ECHO      ;New line.
   LDA #<MSG4      ; Load Error Message
   STA MSGL
   LDA #>MSG4
   STA MSGH
   JSR SHWMSG      ;Show Error.
   LDA #$0D
   JSR ECHO      ;New line.
   RTS

OKMESS:
   LDA #$0D
   JSR ECHO      ;New line.
   LDA #<MSG3      ;Load OK Message.
   STA MSGL
   LDA #>MSG3
   STA MSGH
   JSR SHWMSG      ;Show Done.
   LDA #$0D
   JSR ECHO      ;New line.
   RTS

GETHEX:
   LDA IN,Y      ;Get first char.
   EOR #$30
   CMP #$0A
   BCC DONEFIRST
   ADC #$08
DONEFIRST:
   ASL
   ASL
   ASL
   ASL
   STA L
   INY
   LDA IN,Y      ;Get next char.
   EOR #$30
   CMP #$0A
   BCC DONESECOND
   ADC #$08
DONESECOND:
   AND #$0F
   ORA L
   INY
   RTS
   
MSG2:      .byte "Start Intel Hex code Transfer.",$0A,0
MSG3:      .byte "Intel Hex Imported OK.",$0A,0
MSG4:      .byte "Intel Hex Imported with checksum error.",$0A,0
   
;+---------------------------------------------------------------------------+


