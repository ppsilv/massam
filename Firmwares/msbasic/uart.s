;Uart registers
UART = $C000    ;;Uart address
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
.if .not .def(CR)
	CR  = $0D ; Carriage Return
.endif	
.if .not .def(CR)
	LF  = $0A ; Line feed
.endif	
.if .not .def(Q)
	Q 		= $75
.endif	
.if .not .def(T1)
	T1		= $76
.endif	

SP  = $20 ; Space
ESC = $1B ; Escape

UART_INIT:
	jsr init_9600
	rts
	
;PrintString:
;		STX T1
;		STY T1+1
;		LDY #0
;@loop:	LDA (T1),Y
;		BEQ done
;		JSR CHROUT
;		INY
;		BNE @loop       ; if doesn't branch, string is too long
;done:	RTS
;
;ClearScreen:
;	lda #12
;	sta Q
;@loop:
; ;	LDX #<LineClear
;	LDY #>LineClear
;	jsr PrintString
;	dec Q
;	bne @loop
;	rts
	
;LineClear:
;	.byte "                                                                                ",CR,LF,0

;/* --------------------------------------------------------------------------------------- 
;Read a byte from the UART into A. Blocks until a byte is available. 
;If there was an error, set the C flag.
;C flag clear means a byte was successfully read into A.
;*/
CHRIN:
read_byte:
	lda ULSR 													; check the line status register
	and #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT)	; check for errors
	beq no_err 													; if no error bits, are set, no error
	lda RBR 													; otherwise, there was an error. Clear the error byte
	sec 														; set the carry flag to indicate error
	rts

no_err:
	lda ULSR 													; reload the line status register

	and #DATA_READY
	beq read_byte 												; if data ready is not set, loop
	
	lda RBR 													;// otherwise, we have data! Load it.
	clc 														;// clear the carry flag to indicate no error

	rts 														;// return

	
;--------------------------------------------------------------------------------------- 
;Write a byte in A to the UART.
;Blocks until the UART is ready to send (transmitter holding register is empty)
;
CHROUT:
write_byte:
	pha
wait_for_thr_empty:
	lda ULSR
	and #THR_EMPTY
	beq wait_for_thr_empty 									; loop while the THR is not empty
	pla
	sta THR 												; send the byte
	jsr	delay
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
    
    
