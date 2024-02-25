.segment "UART"
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

;UART Addresses
;Note: 
;Uart 16C550 address 0xC000

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



;--------------------------------------------------------------------------------------- 
;Initialize the UART
;Uses 8n1 mode with no FIFO and 4800 baud @ 1MHz clock
;
init_4800:
	pha

	lda #DLAB
    sta LCR                     ;set the divisor latch access bit (DLAB)

    lda #DIV_4800_LO
    sta DLL                     ;store divisor low byte (4800 baud @ 1 MHz clock)

    lda #DIV_4800_HI                                       
    sta DLM                     ;store divisor hi byte
                                      						
    lda #FIFO_ENABLE
    sta FCR                     ;enable the UART FIFO

    lda #POLLED_MODE
    sta IER                     ;disable all interrupts

    lda #LCR_8N1				;set 8 data bits, 1 stop bit, no parity, disable DLAB
    sta LCR     

    pla
    rts


;--------------------------------------------------------------------------------------- 
;Initialize the UART
;Uses 8n1 mode with no FIFO and 38400 baud @ 1.8...MHz clock
;
init_38400:
    pha

    lda #DLAB
    sta LCR                                                 ;set the divisor latch access bit (DLAB)

    lda #DIV_38400_LO
    sta DLL                                                 ;store divisor low byte (4800 baud @ 1 MHz clock)

    lda #DIV_38400_HI                                       
    sta DLM                                                 ;store divisor hi byte

    lda #FIFO_ENABLE
    sta FCR                                                 ;enable the UART FIFO

    lda #POLLED_MODE
    sta IER                                                 ;disable all interrupts

    lda #LCR_8N1
    sta LCR                                                 ;set 8 data bits, 1 stop bit, no parity, disable DLAB                                             ;set 8 data bits, 1 stop bit, no parity, disable DLAB


    pla
    rts

;--------------------------------------------------------------------------------------- 
;Initialize the UART
;Uses 8n1 mode with no FIFO and 4800 baud @ 1MHz clock
;
init_9600:
    pha

    lda #DLAB
    sta LCR                                            		;set the divisor latch access bit (DLAB)

    lda #DIV_9600_LO
    sta DLL                                            		;store divisor low byte (4800 baud @ 1 MHz clock)

    lda #DIV_9600_HI                                       
    sta DLM                                            		;store divisor hi byte
                                      		;set 8 data bits, 1 stop bit, no parity, disable DLAB

    lda #FIFO_ENABLE
    sta FCR                                            		;enable the UART FIFO

    lda #POLLED_MODE
    sta IER                                            		;disable all interrupts


    lda #LCR_8N1
    sta LCR      

    pla
    rts


;--------------------------------------------------------------------------------------- 
;Read a byte from the UART into A. Blocks until a byte is available. 
;If there was an error, set the C flag.
;C flag clear means a byte was successfully read into A.
;
read_byte:

	lda ULSR 												;check the line status register
	and #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT) ;check for errors
	beq no_err 												;if no error bits, are set, no error
	lda RBR 												;otherwise, there was an error. Clear the error byte
	sec 													;set the carry flag to indicate error
	rts

no_err:
	lda ULSR 												;reload the line status register

	and #DATA_READY
	beq read_byte 											;if data ready is not set, loop
	
	lda RBR 												;otherwise, we have data! Load it.
	clc 													;clear the carry flag to indicate no error

	rts 													;return
	

	

;--------------------------------------------------------------------------------------- 
;Write a byte in A to the UART.
;Blocks until the UART is ready to send (transmitter holding register is empty)
;
write_byte:
	pha
wait_for_thr_empty:
	lda ULSR
	and #THR_EMPTY
	beq wait_for_thr_empty 									;loop while the THR is not empty

	pla
	sta THR 												;send the byte
	rts


;--------------------------------------------------------------------------------------- 
;Read two bytes into target and target+1. Blocking. Clobbers A
;Sets carry bit if either byte has an error.
;If no error, clear carry bit
;
;.macro uart_read_2 target
;	jsr read_byte
;	sta target
;	bcs byte1_err
;
;	jsr read_byte
;	sta target+1
;	jmp done
;
;byte1_err:
;	jsr read_byte
;	sta target+1
;	sec 													;set carry bit to indicate error in byte 1
;
;done:
;.endmacro


;--------------------------------------------------------------------------------------- 
;Read (n_addr) bytes into (target_addr), ..., (target_addr)+(n_addr)-1. 
;Blocking. Clobbers A, zp.B,C,D
;Address n_addr, n_addr+1 should contain the number of bytes to read
;Address target_addr, target_addr+1 should contain the target address
;The Fletcher checksum of the received bytes will be stored in checksum_addr,checksum_addr+1 
;
;.macro uart_read_n_with_checksum n_addr, target_addr, checksum_addr
;	phx
;	phy
;
;	stz checksum_addr
;	stz checksum_addr+1 									;initialize checksum
;
;	ldx #0 													;store num bytes copied low byte in X
;	stz B 												;store num pages copied in X
;
;	ldy #0 													;store 0 in y for indirect addressing								
;
;	mov2 target_addr : C 								;store the target address in zp.C,D
;
;loop:
;	jsr read_byte 										;get a byte
;	sta C,y 											;store the byte in the pointer in zp.C,D
;
;	clc
;	adc checksum_addr
;	sta checksum_addr 										;update the first checksum byte
;	clc 
;	adc checksum_addr+1
;	sta checksum_addr+1 									;update the second checksum byte
;
;	inc C 												;increment the pointer
;	bne no_carry 											;if it doesn't become 0, no need to carry
;	inc C+1 												;if it does become 0, carry to high byte
;no_carry:
;	inx 													;increment num bytes copied
;	bne no_x_carry
;	inc B 												;if carrying, increment num pages copied
;no_x_carry:
;	cpx n_addr
;	bne loop												;if x doesn't match file size low bytes, still copying
;	lda B
;	cmp n_addr+1
;	bcc loop												;if num pages copied less than filesize high byte, still copying
;
;	ply
;	plx
;
;.endmacro


