.setcpu "65C02"
.segment "CODE"

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
		
RESET:
	sei						; No interrupt
	cld						; Set decimal
	ldx #$ff				; Set stack pointer
	txs						; 

	ldx  #$CD   ; (2 cycles)
@delay: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne  @delay ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end


	;; Configure uart to 9600 baudrate
initUart:
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

	ldx  #$CD   ; (2 cycles)
@delay: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne  @delay ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end

	ldx #<Title1
	ldy #>Title1

PrintString:
	ldy #0
loop:                      	

wait_for_thr_empty:         ;
    lda ULSR                ; Get the line status register
    and #THR_EMPTY          ; Check for TX empty
    beq wait_for_thr_empty 	; loop while the THR is not empty
	lda Title1,Y
	beq done
	sta THR 				; send the byte		
    
	ldx  #$50   ; (2 cycles)
@delay20: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne @delay20 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end

	iny             
	jmp loop       ; if doesn't branch, string is too long 
done: 


NewLoop:
	ldx  #$50   ; (2 cycles)
@delay21: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne @delay21 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end

@wait_for_thr_empty:         ;
    lda ULSR                ; Get the line status register
    and #THR_EMPTY          ; Check for TX empty
    beq @wait_for_thr_empty 	; loop while the THR is not empty

read_byte:
	lda ULSR 												    ;// reload the line status register
	and #DATA_READY	
	beq read_byte   											;// if data ready is not set, loop
	lda RBR 

	sta THR 				; send the byte		
    
	ldx  #$50   ; (2 cycles)
@delay22: 
	nop			; (2 cycles) 1us
	dex         ; (2 cycles) 1us
	bne @delay22 ; (3 cycles in loop, 2 cycles at end) 1,5us in loop, 1us at end

	jmp NewLoop		;;Infinit loop

Title1:
	.byte $0A,$0D,"6502 - SystemTest Copyright (C) 2024",CR,LF
	.byte "CPU HBC-56 - Spartan 56",CR,LF,CR,LF,0,0,0,0


;Cpu reset address
.segment    "RESETVEC"

	.word   $0000
	.word   RESET
	.word   $0000
