;***********************************************************************
; SERIAL 16c550 DRIVER
;
.setcpu "65C02"
.segment "BIOS"

;Uart registers
;UART_PORT   = $C000            ;;Uart address
RBR  = $B000    ;;receiver buffer register (read only)
THR  = $B000    ;;transmitter holding register (write only)
DLL  = $B000    ;;divisor latch LSB (if DLAB=1)
DLH  = $B001    ;;divisor latch HSB (if DLAB=1)
IER  = $B001    ;;interrupt enable register
IIR  = $B002    ;;interrupt identification register
FCR  = $B002    ;;FIFO control register
LCR  = $B003    ;;line control register
MCR  = $B004    ;;modem control register
ULSR = $B005    ;;line status register
MSR  = $B006    ;;modem status register
SCR	 = $B007	   ;;scratch register

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

DIV_4800_LO   = 24
DIV_4800_HI   = 0
DIV_9600_LO   = 12
DIV_9600_HI   = 0
DIV_19200_LO  = 6
DIV_19200_HI  = 0
DIV_115200_LO = 1
DIV_115200_HI = 0
POLLED_MODE   = %00000000
LCR_8N1       = %00000011
DLAB          = %10000000
FIFO_ENABLE   = %00000111 ;%00000111
THR_EMPTY     = %01100000       ;;

DATA_READY  = %00000001
OVERRUN_ERR = %00000010
PARITY_ERR  = %00000100
FRAMING_ERR = %00001000
BREAK_INT   = %00010000

INITUART:
    PHA	
    LDA        #DLAB               ;set the divisor latch access bit (DLAB)
    STA        LCR
    LDA        #DIV_9600_LO        ;store divisor low byte (9600 baud @ 1,8 MHz clock)
    STA        DLL
    LDA        #DIV_9600_HI        ;store divisor hi byte                               
    STA        DLH
    LDA        #FIFO_ENABLE        ;enable the UART FIFO
    STA        FCR
    LDA        #POLLED_MODE	       ;disable all interrupts
    STA        IER
	LDA        #LCR_8N1            ;set 8 data bits, 1 stop bit, no parity, disable DLAB
    STA        LCR
    PLA
    RTS	

; A: Data read
; Returns:  F = C if character read
;           F = NC if no character read
;
CHRIN:
READ_BYTE:
	LDA ULSR 												    ;// check the line status register:
	AND #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT)   ; check for errors
	BEQ NO_ERR 												    ;// if no error bits, are set, no error
	LDA RBR 												    ;// otherwise, there was an error. Clear the error byte
	JMP READ_BYTE													 
NO_ERR:
	LDA ULSR 												    ;// reload the line status register
	AND #DATA_READY	
	BEQ READ_BYTE   											;// if data ready is not set, loop
	LDA RBR 		    										;// otherwise, we have data! Load it. 				    									;// clear the carry flag to indicate no error
	RTS            	

; A: Data to write
;
WRITE_0A:
	LDA	#$0A
CHROUT:	
WRITE_BYTE:
    PHA                     ;
WAIT_FOR_THR_EMPTY:	
    LDA ULSR                ; Get the line status register
    AND #THR_EMPTY          ; Check for TX empty
    BEQ WAIT_FOR_THR_EMPTY 	; loop while the THR is not empty
	PLA                     ;	
	STA THR 				; send the byte		

	CMP	#$0D
	BEQ	WRITE_0A

	LDX  #$80   ; (2 cycles)
DELAY22: 
	NOP			; (2 cycles) 1us
	DEX         ; (2 cycles) 1us
	BNE  DELAY22 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end
    RTS                     ;

SAVE:
	RTS
LOAD:
	RTS	