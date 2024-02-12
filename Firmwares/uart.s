#importonce
.filenamespace uart

.cpu _65c02
.encoding "ascii"

#if !MACROS_ONLY

#import "zp.lib"
#import "macros.lib"

/*
UART Addresses

Note: 
breadboard version uses 782x for UART, but 
also selects for 7?2x as long as ? >= 8.
PCB version uses 7Axx for UART.
Using 7A2X thus works with both
*/
.label RBR = $7a20											// receiver buffer register (read only)
.label THR = $7a20                                          // transmitter holding register (write only)
.label IER = $7a21                                          // interrupt enable register
.label IIR = $7a22                                          // interrupt identification register
.label FCR = $7a22                                          // FIFO control register
.label LCR = $7a23                                          // line control register
.label MCR = $7a24                                          // modem control register
.label LSR = $7a25                                          // line status register
.label MSR = $7a26                                          // modem status register
.label DLL = $7a20                                      	// divisor latch LSB (if DLAB=1)
.label DLM = $7a21											// divisor latch MSB (if DLAB=1)


// FCR (FIFO Control) constants
.label NO_FIFO = %00000000
.label FIFO_ENABLE = %00000111

// LCR (Line Control) constants
.label LCR_8N1 = %00000011
.label DLAB = %10000000

// LSR (Line Status) constants
.label DATA_READY = %00000001
.label OVERRUN_ERR = %00000010
.label PARITY_ERR = %00000100
.label FRAMING_ERR = %00001000
.label BREAK_INT = %00010000
.label THR_EMPTY = %00100000
.label TX_EMPTY = %01000000
.label RX_FIFO_ERR = %10000000

// IER (Interrupt Enable) constants
.label POLLED_MODE = %00000000
.label DATA_INT = %00000001
.label THR_EMPTY_INT = %00000010
.label ERROR_INT = %00000100
.label MODEM_STATUS_INT = %00001000

// IIR (Interrupt Identification) constants
.label IIR_DATA_AVAILABLE = %00000100
.label IIR_ERROR = %00000110
.label IIR_CHR_TIMEOUT = %00001100
.label IIR_THR_EMPTY = %00000010
.label IIR_MODEM_STATUS = %00000000

// DLL/DLM (Divisor Latch) constants
.label DIV_4800_LO = 13
.label DIV_4800_HI = 0

.label DIV_9600_LO = 12
.label DIV_9600_HI = 0

.label DIV_38400_LO = 3
.label DIV_38400_HI = 0


// zp.uart_flag bits
.label ERROR_FLAG = %10000000
.label OVERRUN_FLAG = %10000000
.label PARITY_ERR_FLAG = %10000000
.label FRAMING_ERR_FLAG = %10000000
.label BREAK_INT_FLAG = %10000000


// Other constants
.label UART_BUFFER_SIZE = 16



/* --------------------------------------------------------------------------------------- 
Initialize the UART
Uses 8n1 mode with no FIFO and 4800 baud @ 1MHz clock
*/
init:
	pha

	lda #DLAB
    sta LCR                                            		// set the divisor latch access bit (DLAB)

    lda #DIV_4800_LO
    sta DLL                                            		// store divisor low byte (4800 baud @ 1 MHz clock)

    lda #DIV_4800_HI                                       
    sta DLM                                            		// store divisor hi byte
     

                                      						// set 8 data bits, 1 stop bit, no parity, disable DLAB
    lda #FIFO_ENABLE
    sta FCR                                            		// enable the UART FIFO

    lda #POLLED_MODE
    sta IER                                            		// disable all interrupts


    lda #LCR_8N1
    sta LCR     

    // stz zp.uart_read_ptr
    // stz zp.uart_write_ptr

    pla
    rts


/* --------------------------------------------------------------------------------------- 
Initialize the UART
Uses 8n1 mode with no FIFO and 38400 baud @ 1.8...MHz clock
*/
init_38400:
    pha

    lda #DLAB
    sta LCR                                                 // set the divisor latch access bit (DLAB)

    lda #DIV_38400_LO
    sta DLL                                                 // store divisor low byte (4800 baud @ 1 MHz clock)

    lda #DIV_38400_HI                                       
    sta DLM                                                 // store divisor hi byte

    lda #FIFO_ENABLE
    sta FCR                                                 // enable the UART FIFO

    lda #POLLED_MODE
    sta uart.IER                                                 // disable all interrupts

    lda #LCR_8N1
    sta LCR                                                 // set 8 data bits, 1 stop bit, no parity, disable DLAB                                             // set 8 data bits, 1 stop bit, no parity, disable DLAB


    pla
    rts

/* --------------------------------------------------------------------------------------- 
Initialize the UART
Uses 8n1 mode with no FIFO and 4800 baud @ 1MHz clock
*/
init_9600:
	pha

	lda #DLAB
    sta LCR                                            		// set the divisor latch access bit (DLAB)

    lda #DIV_9600_LO
    sta DLL                                            		// store divisor low byte (4800 baud @ 1 MHz clock)

    lda #DIV_9600_HI                                       
    sta DLM                                            		// store divisor hi byte
                                      		// set 8 data bits, 1 stop bit, no parity, disable DLAB

    lda #FIFO_ENABLE
    sta FCR                                            		// enable the UART FIFO

    lda #POLLED_MODE
    sta IER                                            		// disable all interrupts


    lda #LCR_8N1
    sta LCR      
    // stz zp.uart_read_ptr
    // stz zp.uart_write_ptr

    pla
    rts


/* --------------------------------------------------------------------------------------- 
Read a byte from the UART into A. Blocks until a byte is available. 
If there was an error, set the C flag.
C flag clear means a byte was successfully read into A.
*/
read_byte:

	lda LSR 												// check the line status register
	and #(OVERRUN_ERR | PARITY_ERR | FRAMING_ERR | BREAK_INT) // check for errors
	beq no_err 												// if no error bits, are set, no error
	lda RBR 												// otherwise, there was an error. Clear the error byte
	sec 													// set the carry flag to indicate error
	rts

no_err:
	lda LSR 												// reload the line status register

	and #DATA_READY
	beq read_byte 											// if data ready is not set, loop
	
	lda RBR 												// otherwise, we have data! Load it.
	clc 													// clear the carry flag to indicate no error

	rts 													// return
	

	

/* --------------------------------------------------------------------------------------- 
Write a byte in A to the UART.
Blocks until the UART is ready to send (transmitter holding register is empty)
*/
write_byte:
	pha
wait_for_thr_empty:
	lda LSR
	and #THR_EMPTY
	beq wait_for_thr_empty 									// loop while the THR is not empty

	pla
	sta THR 												// send the byte
	rts

#endif




/* --------------------------------------------------------------------------------------- 
Read two bytes into target and target+1. Blocking. Clobbers A
Sets carry bit if either byte has an error.
If no error, clear carry bit
*/
.macro @uart_read_2(target) {
	jsr uart.read_byte
	sta target
	bcs byte1_err

	jsr uart.read_byte
	sta target+1
	jmp done

byte1_err:
	jsr uart.read_byte
	sta target+1
	sec 													// set carry bit to indicate error in byte 1

done:
}


/* --------------------------------------------------------------------------------------- 
Read (n_addr) bytes into (target_addr), ..., (target_addr)+(n_addr)-1. 
Blocking. Clobbers A, zp.B,C,D
Address n_addr, n_addr+1 should contain the number of bytes to read
Address target_addr, target_addr+1 should contain the target address
The Fletcher checksum of the received bytes will be stored in checksum_addr,checksum_addr+1 
*/
.macro @uart_read_n_with_checksum(n_addr, target_addr, checksum_addr) {
	phx
	phy

	stz checksum_addr
	stz checksum_addr+1 									// initialize checksum

	ldx #0 													// store num bytes copied low byte in X
	stz zp.B 												// store num pages copied in X

	ldy #0 													// store 0 in y for indirect addressing								

	mov2 target_addr : zp.C 								// store the target address in zp.C,D

loop:
	jsr uart.read_byte 										// get a byte
	sta (zp.C),y 											// store the byte in the pointer in zp.C,D

	clc
	adc checksum_addr
	sta checksum_addr 										// update the first checksum byte
	clc 
	adc checksum_addr+1
	sta checksum_addr+1 									// update the second checksum byte

	inc zp.C 												// increment the pointer
	bne no_carry 											// if it doesn't become 0, no need to carry
	inc zp.C+1 												// if it does become 0, carry to high byte
no_carry:
	inx 													// increment num bytes copied
	bne no_x_carry
	inc zp.B 												// if carrying, increment num pages copied
no_x_carry:
	cpx n_addr
	bne loop												// if x doesn't match file size low bytes, still copying
	lda zp.B
	cmp n_addr+1
	bcc loop												// if num pages copied less than filesize high byte, still copying

	ply
	plx
}


// /* --------------------------------------------------------------------------------------- 
// Check for and handle a data available interrupt.
// Assumes all other interrupts are disabled
// */
// .macro @check_and_handle_uart_irq() {
// 	lda uart.IIR
//     cmp #uart.DATA_AVAILABLE                                // check for UART interrupt      
//     bne done                           						// if no data is available, done

//     lda uart.RBR    		                                // clear UART interrupt and load available data
//     ldx zp.uart_write_ptr	
//     sta zp.uart_buffer,x                                   	// store received byte in buffer
//     inx                                                  	// increment write pointer
//     cpx #uart.UART_BUFFER_SIZE                              // check if we've reached buffer size
//     bcc save_write_ptr                                   	// if write_ptr < buffer size, we're good to save it
//     ldx #0                                               	// otherwise, reset to 0
// save_write_ptr:	
//     stx zp.uart_write_ptr                                  	// update write_ptr
// done:
// }

