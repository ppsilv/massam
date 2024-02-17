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

B = $00
C = $01
D = $02
E = $03
F = $04
G = $05
H = $06
I = $07
J = $08
K = $09
L = $0a
M = $0b
N = $0c
O = $0d
P = $0e
Q = $0f
T1   = $35      ; temp variable 1
T2   = $36      ; temp variable 2
SL   = $37      ; start address low byte
SH   = $38      ; start address high byte
EL   = $39      ; end address low byte
EH   = $3A      ; end address high byte
DA   = $3F      ; fill data byte
DL   = $40      ; destination address low byte
DH   = $41      ; destination address high byte
BIN  = $42      ; holds binary value low byte
BINH = $43      ; holds binary value high byte
BCD  = $44      ; holds BCD decimal number
BCD2 = $45      ; holds BCD decimal number
BCD3 = $46      ; holds BCD decimal number
LZ   = $47      ; boolean for leading zero suppression
LAST = $48      ; boolean for leading zero suppression / indicates last byte

	.macro  sendUart     dado     ; Send a data byte via serial output
		lda     Arg
	.endmacro
		
RESET:
    sei						; No interrupt
    cld						; Set decimal
    ldx #$ff				; Set stack pointer
    txs						; 
    jsr init_9600			; Configure uart to 9600 baudrate
    jsr	delay				;No need but why not?
	jsr ClearScreen
	lda	#24
	sta P
Loop:
; Display Welcome message
	LDX #<WelcomeMessage
	LDY #>WelcomeMessage
	JSR PrintString

	jsr delay

	dec	P
	bne Loop
	jsr ClearScreen
	lda	#24
	sta P
	jmp Loop		;;Infinit loop
  
PrintString:
		STX T1
		STY T1+1
		LDY #0
@loop:	LDA (T1),Y
		BEQ done
		JSR PrintChar
		INY
		BNE @loop       ; if doesn't branch, string is too long
done:	RTS
 
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
  
WelcomeMessage:
	.byte CR,"SPARTAN - 6502 is alive...",CR,LF,0
LineClear:
	.byte "                                                                                ",CR,LF,0

;/* --------------------------------------------------------------------------------------- 
;Read a byte from the UART into A. Blocks until a byte is available. 
;If there was an error, set the C flag.
;C flag clear means a byte was successfully read into A.
;*/
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
	rts 													; return

;-----------------------------------------------------------------------------------------
; Delay 
;cpu clock..: 1.843.200 hz
;period.....: 0,542 ns
;deley total: 1,0 ms 
delay:
	ldx  #$CD   ; (2 cycles)
delay1: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne  delay1 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end
	rts

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
