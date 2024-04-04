.segment "DRV"

;Uart registers
PORT = $B000            ;;Uart address
R_RX = $00    ;;receiver buffer register (read only)
R_TX = $00    ;;transmitter holding register (write only)
RDLL = $00    ;;divisor latch LSB (if DLAB=1)
RDLH = $01    ;;divisor latch HSB (if DLAB=1)
RIER = $01    ;;interrupt enable register
RIIR = $02    ;;interrupt identification register
RFCR = $02    ;;FIFO control register
RLCR = $03    ;;line control register
RMCR = $04    ;;modem control register
RLSR = $05    ;;line status register
RMSR = $06    ;;modem status register
RSCR = $07	;;scratch register

; Constants
.if .not .def(CR)
	CR  = $0D ; Carriage Return
.endif	
.if .not .def(LF)
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
MCR_DTR  = $01  ;dtr output 
MCR_RTS  = $02  ;rts output 
MCR_OUT1 = $04  ;output #1  
MCR_OUT2 = $08  ;output #2  
MCR_LOOP = $10  ;loop back  
MCR_AFCE = $20  ;auto flow control enable


INITUART:
    LDA        #DLAB               ;set the divisor latch access bit (DLAB)
    STA        PORT+RLCR
    LDA        #DIV_9600_LO        ;store divisor low byte (9600 baud @ 1,8 MHz clock)
    STA        PORT+RDLL
    LDA        #DIV_9600_HI        ;store divisor hi byte                               
    STA        PORT+RDLH
    LDA        #FIFO_ENABLE        ;enable the UART FIFO
    STA        PORT+RFCR
    LDA        #POLLED_MODE	       ;disable all interrupts
    STA        PORT+RIER
	LDA        #LCR_8N1            ;set 8 data bits, 1 stop bit, no parity, disable DLAB
    STA        PORT+RLCR
    LDA        #MCR_OUT2 + MCR_RTS + MCR_DTR + MCR_AFCE
    STA        PORT+RMCR 
    LDA        PORT+R_RX           ;Clear RX buffer      
    RTS	


; A: Data read
; Returns:  F = C if character read
;           F = NC if no character read
; FUNÇÃO BLOCANTE COM CARACTER ECHO
B_READ_BYTE_ECHO:
READ_BYTE:
	LDA PORT+RLSR 												    ;// check the line status register:
	AND #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT)   ; check for errors
	BEQ NO_ERR 												    ;// if no error bits, are set, no error
	LDA PORT+R_RX
	JMP READ_BYTE													 
NO_ERR:
	LDA PORT+RLSR 												    ;// reload the line status register
	AND #DATA_READY	
	BEQ READ_BYTE   											;// if data ready is not set, loop
	LDA PORT+R_RX 
;ECHO CHAR
    ;JSR WRITE_BYTE
;*********
	SEC		    										;// otherwise, we have data! Load it. 				    									;// clear the carry flag to indicate no error
	RTS            	
										    ;// otherwise, there was an error. Clear the error byte

;*************************************************
; A: Data to write
;
WRITE_BYTE:
    STA     RACC                     ; Save A Reg
WAIT_FOR_THR_EMPTY:	
    LDA     PORT+RLSR           ; Get the Line Status Register
    AND     #THR_EMPTY          ; Check for TX empty
    BEQ     WAIT_FOR_THR_EMPTY 	; loop while the THR is not empty
	LDA     RACC                ;	
	STA     PORT+R_TX 			; send the byte		
;;DELAY BETWEEN CHAR SENT

    LDA     #$FF
    STA     COUNTER
@txdelay:
    DEC     COUNTER    
    BNE     @txdelay

    LDA     RACC
    JSR     WRITE_LF
FIM:
    LDA     RACC                     ; Restore A Reg
    RTS

WRITE_LF:
    CMP     #$0D
    BNE     WRITE_BYTE_WITH_ECHO_FIM
@WAIT_FOR_THR_EMPTY:
    LDA     PORT+RLSR           ; Get the Line Status Register
    AND     #THR_EMPTY          ; Check for TX empty
    BEQ     @WAIT_FOR_THR_EMPTY 	; loop while the THR is not empty
    LDA     #$0A
	STA     PORT+R_TX 			; send the byte
WRITE_BYTE_WITH_ECHO_FIM:
    RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; READ_BYTE_NB: Read byte from UART waiting for it (NO BLOCANT) No echo
; Registers changed: A, Y
; Flag CARRY: Set when character ready
;             Clear when no character ready
READ_BYTE_NB:
	LDA PORT+RLSR 												;// check the line status register:
	AND #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT)   ; check for errors
	BEQ @NO_ERR 												    ;// if no error bits, are set, no error
	LDA PORT+R_RX
	JMP NO_CHAR
@NO_ERR:
	LDA PORT+RLSR 												    ;// reload the line status register
	AND #DATA_READY
	BEQ NO_CHAR   											;// if data ready is not set, loop
	LDA PORT+R_RX
    JSR     WRITE_BYTE
    JSR     ACC_DELAY
	SEC		    										;// otherwise, we have data! Load it. 				    									;// clear the carry flag to indicate no error
	RTS
NO_CHAR:
    JSR     ACC_DELAY
    CLC
    RTS

ACC_DELAY:   
    PHA
    LDY     #$FF
@txdelay1:
    DEY
    BNE     @txdelay1
    PLA
    RTS    