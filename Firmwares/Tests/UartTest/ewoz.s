;EWoz 1.0
;by fsafstrom » Mar Wed 14, 2007 12:23 pm
;http://www.brielcomputers.com/phpBB3/viewtopic.php?f=9&t=197#p888
;via http://jefftranter.blogspot.co.uk/2012/05/woz-mon.html
;
;The EWoz 1.0 is just the good old Woz mon with a few improvements and extensions so to say. 
;
;It's using ACIA @ 19200 Baud. 
;It prints a small welcome message when started. 
;All key strokes are converted to uppercase. 
;The backspace works so the _ is no longer needed. 
;When you run a program, it's called with an JSR so if the program ends with an RTS, you will be taken back to the monitor. 
;You can load Intel HEX format files and it keeps track of the checksum. 
;To load an Intel Hex file, just type L and hit return. 
;Now just send a Text file that is in the Intel HEX Format just as you would send a text file for the Woz mon. 
;You can abort the transfer by hitting ESC. 
;
;The reason for implementing a loader for HEX files is the 6502 Assembler @ http://home.pacbell.net/michal_k/6502.html 
;This assembler saves the code as Intel HEX format. 
;
;In the future I might implement XModem, that is if anyone would have any use for it...  
;
;Enjoy...
;
;7000: D8 58 A9 1F 8D 03 C0 A9 0B 8D 02 C0 A9 0D 20 2A 
;7010: 71 A9 2F 85 2C A9 72 85 2D 20 39 71 A9 0D 20 2A 
;7020: 71 A9 9B C9 88 F0 13 C9 9B F0 03 C8 10 19 A9 DC 
;7030: 20 2A 71 A9 8D 20 2A 71 A0 01 88 30 F6 A9 A0 20 
;7040: 2A 71 A9 88 20 2A 71 AD 01 C0 29 08 F0 F9 AD 00 
;7050: C0 C9 60 30 02 29 5F 09 80 99 00 02 20 2A 71 C9 
;7060: 8D D0 C0 A0 FF A9 00 AA 0A 85 2B C8 B9 00 02 C9 
;7070: 8D F0 C0 C9 AE 90 F4 F0 F0 C9 BA F0 EB C9 D2 F0 
;7080: 31 C9 CC F0 36 86 28 86 29 84 2A B9 00 02 49 B0 
;7090: C9 0A 90 06 69 88 C9 FA 90 11 0A 0A 0A 0A A2 04 
;70A0: 0A 26 28 26 29 CA D0 F8 C8 D0 E0 C4 2A D0 12 4C 
;70B0: 2E 70 20 B8 70 4C 21 70 6C 24 00 20 46 71 4C 21 
;70C0: 70 24 2B 50 0D A5 28 81 26 E6 26 D0 9F E6 27 4C 
;70D0: 6C 70 30 2B A2 02 B5 27 95 25 95 23 CA D0 F7 D0 
;70E0: 14 A9 8D 20 2A 71 A5 25 20 17 71 A5 24 20 17 71 
;70F0: A9 BA 20 2A 71 A9 A0 20 2A 71 A1 24 20 17 71 86 
;7100: 2B A5 24 C5 28 A5 25 E5 29 B0 C4 E6 24 D0 02 E6 
;7110: 25 A5 24 29 0F 10 C8 48 4A 4A 4A 4A 20 20 71 68 
;7120: 29 0F 09 B0 C9 BA 90 02 69 06 48 29 7F 8D 00 C0 
;7130: AD 01 C0 29 10 F0 F9 68 60 A0 00 B1 2C F0 06 20 
;7140: 2A 71 C8 D0 F6 60 A9 0D 20 2A 71 A9 44 85 2C A9 
;7150: 72 85 2D 20 39 71 A9 0D 20 2A 71 A0 00 84 30 20 
;7160: 24 72 99 00 02 C8 C9 1B F0 67 C9 0D D0 F1 A0 FF 
;7170: C8 B9 00 02 C9 3A D0 F8 C8 A2 00 86 2F 20 01 72 
;7180: 85 2E 18 65 2F 85 2F 20 01 72 85 27 18 65 2F 85 
;7190: 2F 20 01 72 85 26 18 65 2F 85 2F A9 2E 20 2A 71 
;71A0: 20 01 72 C9 01 F0 2A 18 65 2F 85 2F 20 01 72 81 
;71B0: 26 18 65 2F 85 2F E6 26 D0 02 E6 27 C6 2E D0 EC 
;71C0: 20 01 72 A0 00 18 65 2F F0 95 A9 01 85 30 4C 5F 
;71D0: 71 A5 30 F0 16 A9 0D 20 2A 71 A9 7A 85 2C A9 72 
;71E0: 85 2D 20 39 71 A9 0D 20 2A 71 60 A9 0D 20 2A 71 
;71F0: A9 63 85 2C A9 72 85 2D 20 39 71 A9 0D 20 2A 71 
;7200: 60 B9 00 02 49 30 C9 0A 90 02 69 08 0A 0A 0A 0A 
;7210: 85 28 C8 B9 00 02 49 30 C9 0A 90 02 69 08 29 0F 
;7220: 05 28 C8 60 AD 01 C0 29 08 F0 F9 AD 00 C0 60 57 
;7230: 65 6C 63 6F 6D 65 20 74 6F 20 45 57 4F 5A 20 31 
;7240: 2E 30 2E 00 53 74 61 72 74 20 49 6E 74 65 6C 20 
;7250: 48 65 78 20 63 6F 64 65 20 54 72 61 6E 73 66 65 
;7260: 72 2E 00 49 6E 74 65 6C 20 48 65 78 20 49 6D 70 
;7270: 6F 72 74 65 64 20 4F 4B 2E 00 49 6E 74 65 6C 20 
;7280: 48 65 78 20 49 6D 70 6F 72 74 65 64 20 77 69 74 
;7290: 68 20 63 68 65 63 6B 73 75 6D 20 65 72 72 6F 72 
;72A0: 2E 00
;
; EWOZ Extended Woz Monitor.
; Just a few mods to the original monitor.

; START @ $7000
;*           = $7000
.setcpu "6502"
.segment "UART"

;Exemplo https://github.com/ppsilv/6502/blob/master/asm/6551acia/jmon.s

;Uart registers
RBR  = $C000    ;;receiver buffer register (read only)
THR  = $C000    ;;transmitter holding register (write only)
IER  = $C001    ;;interrupt enable register
IIR  = $C002    ;;interrupt identification register
FCR  = $C002    ;;FIFO control register
LCR  = $C003    ;;line control register
MCR  = $C004    ;;modem control register
ULSR = $C005    ;;line status register
MSR  = $C006    ;;modem status register
DLL  = $C000    ;;divisor latch LSB (if DLAB=1)
DLM  = $C001    ;;divisor latch MSB (if DLAB=1)

;FCR (FIFO Control) constants
NO_FIFO = %00000000
FIFO_ENABLE = %00000111

;LCR (Line Control) constants
LCR_8N1 = %00000011
DLAB = %10000000

;LSR (Line Status) constants
DATA_READY = %00000001
OVERRUN_ERR = %00000010
PARITY_ERR = %00000100
FRAMING_ERR = %00001000
BREAK_INT = %00010000
THR_EMPTY = %00100000
TX_EMPTY = %01000000
RX_FIFO_ERR = %10000000

;IER (Interrupt Enable) constants
POLLED_MODE = %00000000
DATA_INT = %00000001
THR_EMPTY_INT = %00000010
ERROR_INT = %00000100
MODEM_STATUS_INT = %00001000

;IIR (Interrupt Identification) constants
IIR_DATA_AVAILABLE = %00000100
IIR_ERROR = %00000110
IIR_CHR_TIMEOUT = %00001100
IIR_THR_EMPTY = %00000010
IIR_MODEM_STATUS = %00000000

;DLL/DLM (Divisor Latch) constants
DIV_4800_LO = 13
DIV_4800_HI = 0

DIV_9600_LO = 12
DIV_9600_HI = 0

DIV_38400_LO = 3
DIV_38400_HI = 0


;zp.uart_flag bits
ERROR_FLAG = %10000000
OVERRUN_FLAG = %10000000
PARITY_ERR_FLAG = %10000000
FRAMING_ERR_FLAG = %10000000
BREAK_INT_FLAG = %10000000


;Other constants
UART_BUFFER_SIZE = 16

; Constants
CR  = $0D ; Carriage Return
LF  = $0A ; Line feed
SP  = $20 ; Space
ESC = $1B ; Escape

; Page Zero locations
;Block 0
;------------------------------------
;Zero page general-purpose addresses
;("extra registers" to augment A, X, Y)
B        = $00
C        = $01
D        = $02
E        = $03
F        = $04
G        = $05
H        = $06
I        = $07
J        = $08
K        = $09
L        = $0a
M        = $0b
N        = $0c
O        = $0d
P        = $0e
Q        = $0f
XAML     = $24            ;*Index pointers
XAMH     = $25
STL      = $26
STH      = $27
YSAV     = $2A
MODE     = $2B
MSGL     = $2C
MSGH     = $2D
COUNTER  = $2E
CRC      = $2F
CRCCHECK = $30
T1       = $35      ; temp variable 1
T2       = $36      ; temp variable 2
SL       = $37      ; start address low byte
SH       = $38      ; start address high byte
EL       = $39      ; end address low byte
EH       = $3A      ; end address high byte
DA       = $3F      ; fill data byte
DL       = $40      ; destination address low byte
DH       = $41      ; destination address high byte
BIN      = $42      ; holds binary value low byte
BINH     = $43      ; holds binary value high byte
BCD      = $44      ; holds BCD decimal number
BCD2     = $45      ; holds BCD decimal number
BCD3     = $46      ; holds BCD decimal number
LZ       = $47      ; boolean for leading zero suppression
LAST     = $48      ; boolean for leading zero suppression / indicates last byte
IN       = $0200          ;*Input buffer


RESET:       
   CLD             ;Clear decimal arithmetic mode.
   CLI
   sei						; No interrupt
   cld						; Set decimal
   ldx #$ff				; Set stack pointer
   txs						; 
   jsr init_9600			; Configure uart to 9600 baudrate

   LDA #$0A
   JSR ECHO          ;* New line.
   LDA #$0A
   JSR ECHO          ;* New line.
   LDA #<MSG1
   STA MSGL
   LDA #>MSG1
   STA MSGH
   JSR SHWMSG        ;* Show Welcome.
SOFTRESET:
   LDA #$1B          ;* Auto escape.
NOTCR:
   CMP #$08        ;"<-"? * Note this was changed to $88 which is the back space key.
   BEQ BACKSPACE   ;Yes.
   CMP #$1B        ;ESC?
   BEQ ESCAPE      ;Yes.
   INY             ;Advance text index.
   BPL NEXTCHAR    ;Auto ESC if >127.
ESCAPE:
   LDA #$5C        ;"\"
   JSR ECHO        ;Output it.
GETLINE:
   LDA #$0A        ;CR.
   JSR ECHO        ;Output it.
   LDY #$01        ;Initiallize text index.
BACKSPACE:
   DEY             ;Backup text index.
   BMI GETLINE     ;Beyond start of line, reinitialize.
   LDA #$08      ;*Space, overwrite the backspaced char.
   JSR ECHO
   LDA #$08      ;*Backspace again to get to correct pos.
   JSR ECHO
NEXTCHAR:
                   ;LDA ACIA_SR     ;*See if we got an incoming char
                   ;AND #$08        ;*Test bit 3
                   ;BEQ NEXTCHAR    ;*Wait for character
                   ;LDA ACIA_DAT    ;*Load char
   jsr   GETCHAR   ;*Load char
   CMP #$60        ;*Is it Lower case
   BMI   CONVERT   ;*Nope, just convert it
   AND #$DF        ;*If lower case, convert to Upper case
CONVERT:
   STA IN,Y        ;Add to text buffer.
   JSR ECHO        ;Display character.
   CMP #$0D        ;CR?
   BNE NOTCR       ;No.
   LDY #$FF        ;Reset text index.
   LDA #$00        ;For XAM mode.
   TAX             ;0->X.
SETSTOR:
   ASL             ;Leaves $7B if setting STOR mode.
SETMODE:
   STA MODE        ;$00 = XAM, $7B = STOR, $AE = BLOK XAM.
BLSKIP:
   INY             ;Advance text index.
NEXTITEM:
   LDA IN,Y        ;Get character.
   CMP #$0D        ;CR?
   BEQ GETLINE     ;Yes, done this line.
   CMP #$2E        ;"."?
   BCC BLSKIP      ;Skip delimiter.
   BEQ SETMODE     ;Set BLOCK XAM mode.
   CMP #$3A        ;":"?
   BEQ SETSTOR     ;Yes, set STOR mode.
   CMP #$52        ;"R"?
   BEQ RUN         ;Yes, run user program.
   CMP #$4C        ;* "L"?
   BEQ LOADINT     ;* Yes, Load Intel Code.
   STX L           ;$00->L.
   STX H           ; and H.
   STY YSAV        ;Save Y for comparison.
NEXTHEX:
   LDA IN,Y        ;Get character for hex test.
   EOR #$30        ;Map digits to $0-9.
   CMP #$0A        ;Digit?
   BCC DIG         ;Yes.
   ADC #$88        ;Map letter "A"-"F" to $FA-FF.
   CMP #$FA        ;Hex letter?
   BCC NOTHEX      ;No, character not hex.
DIG:
   ASL
   ASL             ;Hex digit to MSD of A.
   ASL
   ASL
   LDX #$04        ;Shift count.
HEXSHIFT:
   ASL             ;Hex digit left MSB to carry.
   ROL L           ;Rotate into LSD.
   ROL H           ;Rotate into MSD's.
   DEX             ;Done 4 shifts?
   BNE HEXSHIFT    ;No, loop.
   INY             ;Advance text index.
   BNE NEXTHEX     ;Always taken. Check next character for hex.
NOTHEX:
   CPY YSAV        ;Check if L, H empty (no hex digits).
   BNE NOESCAPE   ;* Branch out of range, had to improvise...
   JMP ESCAPE      ;Yes, generate ESC sequence.

RUN:
   JSR ACTRUN      ;* JSR to the Address we want to run.
   JMP   SOFTRESET   ;* When returned for the program, reset EWOZ.
ACTRUN:
   JMP (XAML)      ;Run at current XAM index.

LOADINT:
   JSR LOADINTEL   ;* Load the Intel code.
   JMP   SOFTRESET   ;* When returned from the program, reset EWOZ.

NOESCAPE:
   BIT MODE        ;Test MODE byte.
   BVC NOTSTOR     ;B6=0 for STOR, 1 for XAM and BLOCK XAM
   LDA L           ;LSD's of hex data.
   STA (STL, X)    ;Store at current "store index".
   INC STL         ;Increment store index.
   BNE NEXTITEM    ;Get next item. (no carry).
   INC STH         ;Add carry to 'store index' high order.
TONEXTITEM:
   JMP NEXTITEM    ;Get next command item.
NOTSTOR:
   BMI XAMNEXT     ;B7=0 for XAM, 1 for BLOCK XAM.
   LDX #$02        ;Byte count.
SETADR:
   LDA L-1,X       ;Copy hex data to
   STA STL-1,X     ;"store index".
   STA XAML-1,X    ;And to "XAM index'.
   DEX             ;Next of 2 bytes.
   BNE SETADR      ;Loop unless X = 0.
NXTPRNT:
   BNE PRDATA      ;NE means no address to print.
   LDA #$0D        ;CR.
   JSR ECHO        ;Output it.
   LDA #$0A
   JSR ECHO        ;Output it.
   LDA XAMH        ;'Examine index' high-order byte.
   JSR PRBYTE      ;Output it in hex format.
   LDA XAML        ;Low-order "examine index" byte.
   JSR PRBYTE      ;Output it in hex format.
   LDA #$3A        ;":".
   JSR ECHO        ;Output it.
PRDATA:
   LDA #$20        ;Blank.
   JSR ECHO        ;Output it.
   LDA (XAML,X)    ;Get data byte at 'examine index".
   JSR PRBYTE      ;Output it in hex format.
XAMNEXT:
   STX MODE        ;0-> MODE (XAM mode).
   LDA XAML
   CMP L           ;Compare 'examine index" to hex data.
   LDA XAMH
   SBC H
   BCS TONEXTITEM  ;Not less, so no more data to output.
   INC XAML
   BNE MOD8CHK     ;Increment 'examine index".
   INC XAMH
MOD8CHK:
   LDA XAML        ;Check low-order 'exainine index' byte
   AND #$0F        ;For MOD 8=0 ** changed to $0F to get 16 values per row **
   BPL NXTPRNT     ;Always taken.
PRBYTE:
   PHA             ;Save A for LSD.
   LSR
   LSR
   LSR             ;MSD to LSD position.
   LSR
   JSR PRHEX       ;Output hex digit.
   PLA             ;Restore A.
PRHEX:
   AND #$0F        ;Mask LSD for hex print.
   ORA #$30        ;Add "0".
   CMP #$3A        ;Digit?
   BCC ECHO        ;Yes, output it.
   ADC #$06        ;Add offset for letter.
ECHO:
   PHA             ;*Save A
   jsr PrintChar
   PLA             ;*Restore A
   RTS             ;*Done, over and out...

PrintString:
SHWMSG:
   LDY #$0
@PRINT:
   LDA (MSGL),Y
   BEQ @DONE
   JSR ECHO
   INY 
   BNE @PRINT
@DONE:
   RTS 

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
;+---------------------------------------------------------------------------+

   
;/* --------------------------------------------------------------------------------------- 
;Write a byte in A to the UART.
;Blocks until the UART is ready to send (transmitter holding register is empty)
;*/
PrintChar:
write_byte:
	pha
wait_for_thr_empty:
	lda ULSR
	and #THR_EMPTY
	beq wait_for_thr_empty 									; loop while the THR is not empty
	pla
	sta THR 												; send the byte
	rts
;/* --------------------------------------------------------------------------------------- 
;Read a byte from the UART into A. Blocks until a byte is available. 
;If there was an error, set the C flag.
;C flag clear means a byte was successfully read into A.
;*/
GETCHAR:
read_byte:
	lda ULSR 														; check the line status register
	and #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT) 	; check for errors
	beq no_err 												  	; if no error bits, are set, no erro	r
	lda RBR 												  	; otherwise, there was an error. Clear the error byt	e
	sec 															  	; set the carry flag to indicate erro	r
	rts

no_err:
	lda ULSR 												; reload the line status register
	and #DATA_READY                                         
	beq read_byte 											; if data ready is not set, loop
	lda RBR 												; otherwise, we have data! Load it.
	clc 													; clear the carry flag to indicate no error
	rts 

MSG1:      .byte $0A,$0A,$0A,$0A,$0A,"Welcome to EWOZ 1.0.",$0D,$0A,0
MSG2:      .byte "Start Intel Hex code Transfer.",$0A,0
MSG3:      .byte "Intel Hex Imported OK.",$0A,0
MSG4:      .byte "Intel Hex Imported with checksum error.",$0A,0
LineClear: .byte "                                                                                ",CR,LF,0

ClearScreen:
	lda #24
	sta Q
@loop:
 	LDX #<LineClear
	LDY #>LineClear
	jsr PrintString
	dec Q
	bne @loop
	rts


;--------------------------------------------------------------------------------------- 
;Initialize the UART
;Uses 8n1 mode with no FIFO and 4800 baud @ 1MHz clock
;
init_9600:
    pha
    lda #DLAB
    sta LCR                 ;set the divisor latch access bit (DLAB)
    lda #DIV_9600_LO
    sta DLL                 ;store divisor low byte (4800 baud @ 1 MHz clock)
    lda #DIV_9600_HI                                       
    sta DLM                 ;store divisor hi byte
                            ;set 8 data bits, 1 stop bit, no parity, disable DLAB
    lda #FIFO_ENABLE
    sta FCR                 ;enable the UART FIFO
    lda #POLLED_MODE		
    sta IER                 ;disable all interrupts
    lda #LCR_8N1
    sta LCR      
    pla
    rts

;Cpu reset address
.segment    "RESETVEC"

            .word   $0F00
            .word   RESET
            .word   $0000
