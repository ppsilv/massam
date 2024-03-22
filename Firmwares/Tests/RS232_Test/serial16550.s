;***********************************************************************
; SERIAL 16c550 DRIVER
;

;Uart registers
;UART_PORT   = $C000            ;;Uart address
RBR         = $C000    ;;receiver buffer register (read only)
THR         = $C000    ;;transmitter holding register (write only)
DLL         = $C000    ;;divisor latch LSB (if DLAB=1)
DLH         = $C001    ;;divisor latch HSB (if DLAB=1)
IER         = $C001    ;;interrupt enable register
IIR         = $C002    ;;interrupt identification register
FCR         = $C002    ;;FIFO control register
LCR         = $C003    ;;line control register
MCR         = $C004    ;;modem control register
ULSR        = $C005    ;;line status register
MSR         = $C006    ;;modem status register
SCR	        = $C007	   ;;scratch register

; Constants
CR  = $0D ; Carriage Return
LF  = $0A ; Line feed
SP  = $20 ; Space
ESC = $1B ; Escape

DIV_9600_LO = 12
DIV_9600_HI = 0
POLLED_MODE = %00000000
LCR_8N1 = %00000011
DLAB    = %10000000
FIFO_ENABLE = %00000111 ;%00000111
THR_EMPTY = %01100000       ;;

DATA_READY = %00000001
OVERRUN_ERR = %00000010
PARITY_ERR = %00000100
FRAMING_ERR = %00001000
BREAK_INT = %00010000


initUart:
    pha	
    lda #DLAB
    sta LCR                 ;set the divisor latch access bit (DLAB)
    lda #DIV_9600_LO
    sta DLL                 ;store divisor low byte (4800 baud @ 1 MHz clock)
    lda #DIV_9600_HI                                       
    sta DLH                 ;store divisor hi byte
                            ;set 8 data bits, 1 stop bit, no parity, disable DLAB
    lda #FIFO_ENABLE
    sta FCR                 ;enable the UART FIFO
    lda #POLLED_MODE	
    sta IER                 ;disable all interrupts
	lda #LCR_8N1
    sta LCR    
    pla
    rts	

; A: Data read
; Returns:  F = C if character read
;           F = NC if no character read
;
read_byte:
	lda ULSR 												    ;// check the line status register:
	and #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT)   ; check for errors
	beq no_err 												    ;// if no error bits, are set, no error
	lda RBR 												    ;// otherwise, there was an error. Clear the error byte
	jmp read_byte													 
	
no_err:
	lda ULSR 												    ;// reload the line status register
	and #DATA_READY	
	beq read_byte   											;// if data ready is not set, loop
	lda RBR 		    										;// otherwise, we have data! Load it.
	;clc 				    									;// clear the carry flag to indicate no error
	rts            	

; A: Data to write
;
write_byte:
    pha                     ;
wait_for_thr_empty:         ;
    lda ULSR                ; Get the line status register
    and #THR_EMPTY          ; Check for TX empty
    beq wait_for_thr_empty 	; loop while the THR is not empty
	pla                     ;
	sta THR 				; send the byte		
    
	ldx  #$50   ; (2 cycles)
delay22: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne  delay22 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end
    rts                     ;

PrintString:
	stx T1
	sty T1+1
	ldy #0
@loop:                      	
	lda (T1),Y
	beq done
	jsr write_byte          
	iny             
	jmp @loop       ; if doesn't branch, string is too long 
done: 
	rts                      

read_line:
	ldx #<LINE
	ldy #>LINE
	jsr PrintString
	ldy	#0
	lda	#13
	sta	COUNTER
@read_line:
	jsr	read_byte
	jsr	write_byte
	sta	(CMD_BUF),y
	iny
	dec	COUNTER
	beq	fim
	cmp	#$0D
	bne	@read_line
	lda	#$0A
	sta	(CMD_BUF),y
	jsr	write_byte
	iny
	lda	#$00
	sta	(CMD_BUF),y
	jsr	write_byte
	rts	
fim:	
	lda	#$0D
	sta	(CMD_BUF),y
	jsr	write_byte
	iny
	lda	#$0A
	sta	(CMD_BUF),y
	jsr	write_byte
	iny
	lda	#$00
	sta	(CMD_BUF),y
	rts
LINE:
    .byte "Digite uma linha de comando",CR,LF
    .byte "# ",0,0,0    
