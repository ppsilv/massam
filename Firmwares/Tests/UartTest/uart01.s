/****************************************************************************
   
    OS/A65 Version 1.3.10
    Multitasking Operating System for 6502 Computers

    Copyright (C) 1989-1997 Andre Fachat 

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

****************************************************************************/

/*
 * This is (part of) an UART 16550A serial line driver for CS/A65.
 * It uses the hardware installed in my personal C64. The
 * 16550A is mapped at $d600, above the SID.
 *
 * The 16550 is not really an easy chip, but it has 16 byte
 * input and output FIFO buffers, which allows much higher
 * interrupt latencies.
 */

#define UART	$d600

#define RXTX       0               /* DLAB=0 */
#define IER        1               /* DLAB=0 */
#define DLL        0               /* divisor latch low, DLAB=1 */
#define DLH        1               /* divisor latch high, DLAB=1 */
#define IIR        2               /* Irq Ident. Reg., read only */
#define FCR        2               /* FIFO Ctrl Reg., write only */
#define LCR        3               /* Line Ctrl Reg */
#define MCR        4               /* Modem Ctrl Reg */
#define LSR        5               /* Line Status Reg */
#define MSR        6               /* Modem Status Reg */
#define SCR        7               /* 'scratchpad', i.e. unused */

#define	E_OK		0
#define	E_NOTIMP	<-1
#define	E_NOIRQ		<-2
#define	E_SLWM		<-3
#define	E_NUL		<-4
#define	E_SEMPTY	<-5
#define	E_SFULL		<-6
#define	E_SHWM		<-7
#define	E_EOF		<-8
#define	E_DON		<-9
#define	E_DOFF		<-10

/*        Device-Commands          */

#define   DC_IRQ    0
#define   DC_RES    1
#define   DC_GS     2
#define   DC_PS     3
#define   DC_RX_ON  4  
#define   DC_TX_ON  5
#define   DC_RX_OFF 6
#define   DC_TX_OFF 7
#define   DC_SPD    8
#define   DC_HS     9
#define   DC_ST     10
#define   DC_EXIT   11

#define   DC_SW_RX  %10000000
#define   DC_SW_TX  %01000000


/* 	  Stream Commands           */

#define   SC_GET    0
#define   SC_REG_RD 1
#define   SC_REG_WR 2
#define   SC_CLR    3
#define   SC_EOF    4
#define   SC_NUL    5
#define   SC_FRE    6
#define   SC_STAT   7
#define   SC_GANZ   8
#define   SC_RWANZ  9



/*
 * status: Bit 	0 = 1= handshake enabled
 *		1 : 1= no ACIA found
 * 		5 : 1= set RTS hi
 *		6 : 1= we are transmitting
 *	  	7 : 1= we are receiving
 *
 */


/***************************************************************************
 * local variables
 */


dev       =$033c
div       =$033d
status    =$033e

inp	  =$033f
outp	  =$0340
tmpy	  =$0341
buf	  =$0400

/***************************************************************************
 * BASIC start for C64 program
 */

	.word $0801
	*=$0801
	.word basicend
	.word 10
	.byt $9e, "2061",0
basicend
	.word 0
	jmp prgstart

/* 
 * 16550 divisor values for BAUD rates ?, 50, 75, 110, 134.5, 150, 
 * 300, 600, 1200, 1800, 2400, 3600, 4800, 7200, 9600, 19200
 */
divisor	.word 	-1, 2304, 1536, 1047, 857, 768, 384, 192, 96
	.word	64, 48, 32, 24, 16, 12, 6

prgstart
	jsr devini
	bcs eop

	sei
	lda #<C64IRQ
	sta $0314
	lda #>C64IRQ
	sta $0315
	cli

	jsr txon
	jsr rxon

l0	jsr $ffe4
	beq l0
	sei
	jsr PUTC
	cli
	jmp l0
eop	rts

C64IRQ	jsr devirq
	jmp $EA31

/***************************************************************************
 * init UART 
 * 
 * This routine is according to the Serial FAQ by Chris Blum, Release 18
 * The FAQ is posted regularly to comp.sys.ibm.pc.hardware.comm and
 * comp.os.msdos.programmer and can be obtained by ftp at
 * ftp://ftp.phil.uni-sb.de/pub/people/chris/The_Serial_Port
 * 
 * (These routines get called with the device number in the x register.
 * As this driver supports one UART only, x is always 0 - that may change)
 */

devini  lda #0
        sta status

	; check if there's something like an UART at all
	ldy UART+MCR
	lda #$10
	sta UART+MCR
	lda UART+MSR
	and #$f0
	bne nodev
	lda #$1f
	sta UART+MCR
	lda UART+MSR
	and #$f0
	cmp #$f0
	bne nodev
	sty UART+MCR

	; check if it has a scratchpad register - if not then it's plain 8250
	ldy UART+SCR
	lda #%10101010
	sta UART+SCR
	cmp UART+SCR
	bne dev8250
	lsr
	sta UART+SCR
	cmp UART+SCR
	bne dev8250
	sty UART+SCR

	; now check the 16xxx versions
	lda #1
	sta UART+FCR
	lda UART+IIR
	ldy #0
	sty UART+FCR
	asl
	bcc dev16450
	asl
	bcc dev16550
	; else dev16550A; currently only this one is supported

	; ok, we detected a 16550A, i.e. a chip with working FIFO
	lda #%10000000
	sta UART+LCR
	ldx #14*2		; 9600 BAUD
	lda divisor,x
	sta UART+DLL
	lda divisor+1,x
	sta UART+DLH
	lda #%00000011		; 8N1
	sta UART+LCR
 
 	lda #7			; no FIFO enable and clear FIFOs, 
	sta UART+FCR		; trigger at 1 byte
	lda #0
	sta UART+IER		; polled mode (so far) 
	sta UART+MCR		; reset DTR, RTS

        clc
        rts

nodev					; no UART at all
dev8250					; no Scratchpad, no FIFO
dev16450				; scratchpad, no FIFO
dev16550				; FIFO bug
	  lda status
          ora #2
          sta status
          lda #E_NOTIMP
          sec
          rts
          
/***************************************************************************
 * UART interrupt routine
 * 
 * The interrupt routines are called one after each other in this OS.
 * If an interrupt source has been removed, then E_OK is returned, 
 * E_NOIRQ otherwise. So this routine even gets called, when lower level
 * interrupts occur. This is due to the single level interrupt structure
 * of the 6502 (not counting the NMI, which is not really of use in this OS)
 *
 * The routine is nasty due to several reasons: The UART doesn't
 * periodically generate interrupts, when the transmitter is empty, as
 * the ACIA does. So it is possible to be able to send (i.e. put 
 * characters in software send FIFO) but the interrupt driven
 * driver doesn't know about it. Therefore, the Serial FAQ suggests
 * to start the transmission manually when data is written to the drivers
 * internal buffers. In this OS the buffers (software FIFOs) are totally 
 * independent FIFOs (Streams) written to and read with PUTC and GETC.  
 * To avoid lockups, I therefore check if I can start sending every time 
 * the interrupt routine is called, even if the interrupt source is not 
 * the UART itself.
 *
 * The FAQ suggests checking if data is to be sent after all UART interrupt
 * sources have been handled. But "Start transmission by simply calling the
 * tx interrupt handler after you've written to the tx fifo [software-FIFO]
 * of the program..." (These are things you can do with DOS.... ts,ts,ts)
 *
 */

devirq    
        .(
	lda UART+IIR	; UART IIR
	lsr
	bcc intr		; ok, found IRQ
irqend  lda #E_NOIRQ		; no irq source found
	jmp irqe		; not this one

	;-----------------------------------------------

intr
	and #%00000011		; interrupt mask - makes four possible IRQs
	tay
	bne int_tx

	;--------------
				; modem status interrupt
	lda UART+MSR	; de-locked by reading the MSR
	jmp checkint		; do it, even if this IRQ is not enabled...

int_tx	;--------------
	dey
	bne int_rx
tx_loop 			; transmitter empty interrupt
	jsr tx2			; write data bytes to UART FIFO
	jmp checkint

int_rx  ;--------------
	dey
	bne int_status
rx_loop				; receiver interrupt
	jsr rx2			; get one char and save
	lda UART+LSR
	lsr
	bcs rx_loop		; still data in UART FIFO?
	jmp checkint

int_status ;--------------
	lda UART+LSR	; line status interrupt, de-locked by reading 
				; MSR

	;--------------
checkint			; still another IRQ pending?
	lda UART+IIR
	lsr
	bcc intr		; irq still pending

	jsr nobyt		; check if we are still allowed to receive
				; (i.e. stream has not been closed from reader)

	;--------------
irqok   lda #E_OK		; irq source removed
irqe	pha			; we get here no matter if UART IRQ or not

	lda UART+LSR	; check if we are allowed to start sending
	and #$40		; manually (THRE = LSR bit 6)
	beq nbyt		; no then end
	jsr tx2			; otherwise fill FIFO

	jsr nobyt		; check if we are still allowed to receive
				; (this ensures to check even if no traffic)
nbyt
	pla
	rts

	;-----------------------------------------------

	; Receive a single byte
rx2	.(
	lda UART+RXTX	; load data byte
	bit status		; are we receiving?
	bpl rx2end		; no, then end
        jsr PUTC		; and save in software FIFO
        bcc rx2end		; no error -> end
	cmp #E_SLWM		; stream below low water mark? this happens
	bne test		; most and is caught by nobyt anyway
rx2end	rts

	; check stream (software-FIFO) status
&nobyt  
	bit status		; are we receiving?
	bpl rx2end		; no -> end
        jsr STRCMD		; get state of stream
        bcc rx2end		; ok -> end
test
        cmp #E_NUL		; stream has been closed from reader?
        bne tstwater
        jmp rxoff		; yes, then shut receiver off
tstwater  
	cmp #E_SEMPTY		; stream is empty? 
        beq wl			; ok, ensure that RTS is low
        tax
        lda status		; we want RTS hi?
        and #1			
        bne wh			; yes, then high
        txa
        cmp #E_SFULL		; stream full
        beq wh			; then RTS high
        cmp #E_SHWM		; stream above high water mark?
        bne twl			; no then branch
wh      ldx #0  
	jmp rtsoff
twl     cmp #E_SLWM		; stream below low water mark? 
        bne rx2end		; no then end
wl      ldx #0  		; otherwise RTS low
	jmp rtson
	.)

	;-----------------------------------------------

	; Fill transmitter FIFO
tx2 	.(
	bit status		; are we transmitting?
        bvc txrt		; reading IIR should clear this line

	lda UART+MSR	; are CTS and DSR ok?
	and #%00110000
	cmp #%00110000		; cts or dsr inactive
	bne txrt		; yes then end

	ldy #15			; number of byte
txloop
        jsr GETC
        bcs test2
        sta UART+RXTX	; send new data byte
	dey
	bne txloop		; fill up FIFO
        bcc txrt

test2   cmp #E_EOF		; we got a stream End-Of-File?
        bne txrt
        jmp txoff		; yes, then shut transmitter off
txrt	rts
	.)

          .)

/***************************************************************************
 * support routines
 */

dtroff
	lda UART+MCR
	and #%11111110
	sta UART+MCR
	lda #0
	sta UART+IER
	rts

dtron
	lda UART+MCR
	ora #%00000001
	sta UART+MCR
	lda #3
	sta UART+IER
	rts

rtsoff
	lda UART+MCR
	and #%11111101
	sta UART+MCR
	lda status,x
	ora #%00100000
	sta status,x
	rts

rtson
	lda UART+MCR
	ora #%00000010
	sta UART+MCR
	lda status,x
	and #%11011111
	sta status,x
	rts

/***************************************************************************
 * control handling
 *
 * This is rather OS specific, so maybe it's not necessary here.
 * One thing to mention is, that rxoff and txoff just reset their 
 * bit in the status byte. rxoff then sets RTS high (rtsoff).
 * After that, both check if transmitter or receiver are on. If both
 * are shut off, then DTR is set high (dtroff).
 *
 * If the transmitter or receiver are enabled, both set DTR low (dtron).
 * The receiver also sets CTS low (ctslo).
 */

rxon
	  jsr rtson
	  jsr dtron
          lda #DC_SW_RX
          bne o2a
txon
	  jsr dtron
          lda #DC_SW_TX
o2a       ora status
          sta status
          bne ok

rxoff     
	  lda status
          and #DC_SW_RX
          beq devoff
	  jsr rtsoff
	  ; signal eof to software FIFO here
          lda status
          and #255-DC_SW_RX
          sta status
	  jmp checkdtr
txoff  
          lda status
          and #DC_SW_TX
          beq devoff
	  ; signal close to software FIFO here
          lda status
          and #255-DC_SW_TX
          sta status,x
checkdtr
	  and #DC_SW_TX+DC_SW_RX
	  bne active
	  jsr dtroff
active 	  jmp ok

setspeed
          tya
          and #%00001111
	  asl
          tax
	  beq ok

	  lda UART+LCR
	  ora #$80
	  sta UART+LCR
  	  lda divisor,x
	  sta UART+DLL
	  lda divisor+1,x
	  sta UART+DLH
	  lda UART+LCR
	  and #$7f
	  sta UART+LCR

ok        lda #E_OK
          .byt $2c
devon     lda #E_DON
          .byt $2c
devoff    lda #E_DOFF
          .byt $2c
onotimp   lda #E_NOTIMP
          cmp #1
          rts

/***************************************************************************/

bufinit	lda #0
	sta inp
	sta outp
	rts

PUTC	sty tmpy
	ldy inp
	sta buf,y
	iny
	cpy outp
	beq full
	sty inp
	ldy tmpy

STRCMD	sty tmpy
	lda inp
	sec
	sbc outp
	beq empty
	cmp #$ff
	beq full
	cmp #$40
	bcc low
	cmp #$c0
	bcs high
	lda #E_OK
	.byt $2c
high	lda #E_SHWM
	.byt $2c
low	lda #E_SLWM
	.byt $2c
full	lda #E_SFULL
	.byt $2c
empty	lda #E_SEMPTY
	ldy tmpy
	cmp #1
	rts

GETC	sty tmpy
	ldy outp
	cpy inp
	beq nobyte
	lda buf,y
	inc outp
	ldy tmpy
	clc
	rts
nobyte	lda #E_SEMPTY
	ldy tmpy
	sec
	rts


