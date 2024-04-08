;	REPLICA I SERIAL I/O FIRMWARE
;	(c) 2005 BRIEL COMPUTERS
;
;   This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;   
;    Commercial use of this software code without permission is prohibited
; 
;Ports:	A - INCOMING KEYBOARD 
;	B - INCOMING VIDEO
;	C - OUTGOING KEYBOARD DATA TO 6821
;	INT0 - DA VIDEO STROBE
;	INT1 - KYBD STROBE
.CSEG
.ORG $000					
	RJMP	RESET				;RESET INTERRUPT
.ORG INT0addr
	RJMP	KEY_INT				;KEYBOARD INPUT INTERRUPT ROUTINE
.ORG INT1addr
	RJMP	VID_INT				;VIDEO INTERRUPT ROUTINE

	.include "8515def.inc"
	.def	temp =r16			;TEMP REGISTER
	.def	DELAY=r17			;DELAY VALUE 1
	.def	delay2 =r18			;DELAY VALUE 2
	.def	STROBE =r21			;KEYBOARD STROBE VALUE
	
RESET:
	LDI 	TEMP,low(RAMEND)		;SET STACK POINTER TO RAM END
	OUT 	SPL,TEMP
	LDI 	TEMP, high(RAMEND)
	OUT 	SPH, TEMP
	LDI 	TEMP,0x3F		
	OUT 	MCUCR,TEMP 			;FLAG ISC11 &ISC10
	LDI 	TEMP,0xC0		
	OUT 	GIFR,TEMP			;SET UP INTERRUPTS
	OUT 	GIMSK,TEMP
	SER	TEMP			
	OUT	DDRC,TEMP			;SET PORTC TO OUTPUT (KEYBOARD CODE TO 6821)
	LDI	TEMP,0
	OUT	DDRA,TEMP			;SET PORTA TO INPUT (FROM KEYBOARD)
	OUT	DDRB,TEMP			;SET PORTB TO INPUT (VIDEO DATA)
	LDI	TEMP,255
	LDI	TEMP,0x0C
	LDI	TEMP,191			;207 IS BAUD FOR 2400 AT 8 Mhz
	OUT	UBRR,Temp			
	SBI	UCR,TXEN
	SBI 	UCR,RXEN

	LDI 	STROBE,0x80			;THIS IS TO SET 8TH BIT IN KEYBOARD
	SEI
DATA_IN:					;LOOP FOR SERIAL DATA IN
	SBIS 	USR,RXC				;CHECK IF CHARACTER RECEIVED
	RJMP	DATA_IN
	IN	TEMP,UDR
	OUT	PORTC,TEMP			;SEND TO KEYBOARD PORT
	LDI 	delay,$1F
PAUSE:
	LDI 	delay2,$FF
PAU2:
	DEC 	delay2
	CPI 	DELAY2,$00
	BRNE 	PAU2
	DEC 	DELAY
	CPI 	DELAY,$00
	BRNE 	PAUSE
	SUB 	TEMP,STROBE		
	OUT 	PORTC,TEMP			;TURN OFF STROBE
	RJMP	DATA_IN	 			;REPEAT LOOP FOREVER 
VID_INT:					;VIDEO OUT INTERRUPT
	IN	r22,SREG
	PUSH	r22
	IN	TEMP,PINB			;GET 7 BIT ASCII CODE
	ADD	TEMP,STROBE			;ADD THIS TO MAKE IT CORRECT

	OUT	UDR,TEMP			;SEND IT TO THE SERIAL PORT
SDOUT:						;WAIT FOR IT TO FINISH SENDING
	SBIS	USR,TXC
	RJMP	SDOUT
	POP	r22
	OUT	SREG,r22
	RETI
KEY_INT:					;KEYBOARD INTERRUPT
	IN	r22,SREG
	PUSH	r22
	IN	TEMP,PINA			;GET KEYBOARD DATA
	cpi	temp,0x80			;is 8th bit set 
	brlo	eight
	sub	temp,strobe			;8th bit set so subtract it
eight:
	ADD	TEMP,STROBE			;ADD STROBE VALUE
	OUT	PORTC,TEMP			;SEND IT TO 6821 AS A KEYSTROKE
	LDI	DELAY,0x02			;LOOP PAUSE FOR STROBE
LOOP:
	LDI 	DELAY2,$FF
LOOP2:
	DEC 	DELAY2
	CPI 	DELAY2,$00
	BRNE 	LOOP2
	DEC		DELAY
	CPI 	DELAY,$00
	BRNE 	LOOP
	SUB	TEMP,STROBE			;REMOVE STROBE SIGNAL
	OUT	PORTC,TEMP
	POP	r22
	OUT	SREG,r22
	RETI