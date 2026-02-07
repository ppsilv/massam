;***********************************************************************
; SERIAL 16c550 DRIVER
;
.setcpu "65C02"

.zeropage

ACC: .res 1

.segment "BIOS"

;Uart registers
;UART_PORT   = $7800            ;;Uart address
RBR  = $7800    ;;receiver buffer register (read only)
THR  = $7800    ;;transmitter holding register (write only)
DLL  = $7800    ;;divisor latch LSB (if DLAB=1)
DLH  = $7801    ;;divisor latch HSB (if DLAB=1)
IER  = $7801    ;;interrupt enable register
IIR  = $7802    ;;interrupt identification register
FCR  = $7802    ;;FIFO control register
LCR  = $7803    ;;line control register
MCR  = $7804    ;;modem control register
ULSR = $7805    ;;line status register
MSR  = $7806    ;;modem status register
SCR	 = $7807	   ;;scratch register



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
MONRDKEY:
CHRIN:
READ_BYTE:
	LDA ULSR 												    ;// check the line status register:
	AND #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT)   ; check for errors
	BEQ NO_ERR 												    ;// if no error bits, are set, no error
	LDA RBR
	JMP READ_BYTE													 
NO_ERR:
	LDA ULSR 												    ;// reload the line status register
	AND #DATA_READY	
	BEQ READ_BYTE   											;// if data ready is not set, loop
	LDA RBR 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Echoes the caracter    
;    PHA                     
;WAIT_FOR_THR:	
;    LDA ULSR                ; Get the line status register
;    AND #THR_EMPTY          ; Check for TX empty
;    BEQ WAIT_FOR_THR 	; loop while the THR is not empty
;	PLA                     ;	
;	STA THR 				; send the byte	
;    PHA                     ;
;    lda     #$FF
;@txdelay:
;    nop
;    dec
;    bne     @txdelay
;
;    lda     #$FF
;@txdelay1:
;    nop
;    dec
;    bne     @txdelay1
;	PLA                     ;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SEC		    										;// otherwise, we have data! Load it. 				    									;// clear the carry flag to indicate no error
	RTS            	
										    ;// otherwise, there was an error. Clear the error byte

;*************************************************
; A: Data to write
;
MONCOUT:
CHROUT:	
WRITE_BYTE:
    STA     ACC                     ;
WAIT_FOR_THR_EMPTY:	
    LDA ULSR                ; Get the line status register
    AND #THR_EMPTY          ; Check for TX empty
    BEQ WAIT_FOR_THR_EMPTY 	; loop while the THR is not empty
	LDA     ACC                     ;	
	STA THR 				; send the byte		

;;DELAY BETWEEN CHAR SEND
    lda     #$FF
@txdelay:
    dec
    bne     @txdelay
    LDA     ACC
    CMP     #$0D
    BNE     FIM
    LDA     #$0A
    JMP     WRITE_BYTE
FIM:
    RTS                     ;

SAVE:
	RTS
LOAD:
	RTS	

.include "wozmon.s"

.segment "RESETVEC"

                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector
