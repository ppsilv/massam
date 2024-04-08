;Replica 1 keyboard decoder firmware
;
;Revision C
;
;(c) 2004 Briel Computers
;
;Written by Vincent Briel
;
;Revision C with extended keypad and clearscreen key
;
;    This program is free software; you can redistribute it and/or modify
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
;
;
;
;
;7 Bit ASCII portC C0-C6, Strobe is C7 (8th bit) ASCII keyboard port
;INT1 is keyboard Data (portD3) 
;Keyboard Clock is portB0

.include "m8515def.inc"


.DSEG
KeyStack:	.BYTE	15		


.CSEG

.org $100

chardata:
;PS/2 to ASCII database 
	.db 0x00,0x00	
	.db 0x00,0x00	;02 03		
	.db 0x00,0x00	;04 05
	.db 0x00,0x00	;06 07
	.db 0x00,0x00	;08 09
	.db 0x00,0x00	;0A 0B
	.db 0x00,0x09	;0C 0D
	.db 0x60,0x00	;0E 0F
	.db 0x00,0x00	;10 11
	.db 0x00,0x00	;12 13
	.db 0x00,0x51	;14 15		
	.db 0x31,0x00	;16 17
	.db 0x00,0x00	;18 19
	.db 0x5A,0x53	;1A 1B		
	.db 0x41,0x57	;1C 1D		
	.db 0x32,0x00	;1E 1F		
	.db 0x00,0x43	;20 21		
	.db 0x58,0x44	;22 23		
	.db 0x45,0x34	;24 25		
	.db 0x33,0x00	;26 27		
	.db 0x00,0x20	;28 29
	.db 0x56,0x46	;2A 2B		
	.db 0x54,0x52	;2C 2D		
	.db 0x35,0x00	;2E 2F		
	.db 0x00,0x4E	;30 31		
	.db 0x42,0x48	;32 33		
	.db 0x47,0x59	;34 35		
	.db 0x36,0x00	;36 37		
	.db 0x00,0x00	;38 39
	.db 0x4D,0x4A	;3A 3B		
	.db 0x55,0x37	;3C 3D		
	.db 0x38,0x00	;3E 3F		
	.db 0x00,0x2C	;40 41
	.db 0x4B,0x49	;42 43
	.db 0x4F,0x30	;44 45		
	.db 0x39,0x00	;46 47
	.db 0x00,0x2E	;48 49
	.db 0x2F,0x4C	;4A 4B		
	.db 0x3B,0x50	;4C 4D		
	.db 0x2D,0x00	;4E 4F
	.db 0x00,0x00	;50 51
	.db 0x27,0x00	;52 53
	.db 0x5B,0x3D	;54 55
	.db 0x00,0x00	;56 57
	.db 0x00,0x00	;58 59
	.db 0x0D,0x5D	;5A 5B
	.db 0x00,0x5C	;5C 5D
	.db 0x00,0x00	;5E 5F
	.db 0x00,0x00	;60 61
	.db 0x00,0x00	;62 63
	.db 0x00,0x00	;64 65
	.db 0x08,0x00	;66 67
	.db 0x00,0x31	;68 69
	.db 0x00,0x34	;6A 6B
	.db 0x37,0x00	;6C 6D
	.db 0x00,0x00	;6E 6F
	.db 0x30,0x2E	;70,71			
	.db 0x32,0x35	;72,73
	.db 0x36,0x38	;74,75
	.db 0x1B,0x00	;76,77
	.db 0x00,0x2B	;78,79
	.db 0x33,0x2D	;7A,7B
	.db 0x2A,0x2A	;7C,7D
	.db 0x39,0x00	;7E,7F
	.db 0x00,0x00	;80,81			
	.db 0x00,0x00	;82 83
	.db 0x00,0x00	;74 75
	.db 0x1B,0x00	;76 77
	.db 0x00,0x00	;78 79
	.db 0x00,0x00	;7A 7B
	.db 0x00,0x09	;7C 7D		
	.db 0x7E,0x00	;7E 7F
	.db 0x00,0x00	;80 81		
	.db 0x00,0x00	;82 83
	.db 0x00,0x51	;84 85
	.db 0x21,0x00	;86 87
	.db 0x00,0x00	;88 89
	.db 0x5A,0x53	;8A 8B
	.db 0x41,0x57	;8C 8D
	.db 0x40,0x00	;8E 8F
	.db 0x00,0x43	;90 91
	.db 0x58,0x44	;92 93
	.db 0x45,0x24	;94 95
	.db 0x23,0x00	;96 97
	.db 0x00,0x20	;98 99
	.db 0x56,0x46	;9A 9B
	.db 0x54,0x52	;9C 9D
	.db 0x25,0x00	;9E 9F
	.db 0x00,0x4E	;A0 A1
	.db 0x42,0x48	;A2 A3
	.db 0x47,0x59	;A4 A5
	.db 0x5E,0x00	;A6 A7
	.db 0x00,0x00	;A8 A9
	.db 0x4D,0x4A	;AA AB
	.db 0x55,0x26	;AC AD
	.db 0x2A,0x00	;AE AF
	.db 0x00,0x3C	;B0 B1
	.db 0x4B,0x49	;B2 B3
	.db 0x4F,0x29	;B4 B5
	.db 0x28,0x00	;B6 B7
	.db 0x00,0x3E	;B8 B9
	.db 0x3F,0x4C	;BA BB
	.db 0x3A,0x50	;BC BD
	.db 0x5F,0x00	;BE BF
	.db 0x00,0x00	;C0 C1
	.db 0x22,0x00	;C2 C3
	.db 0x7B,0x2B	;C4 C5		
	.db 0x00,0x00	;C6 C7
	.db 0x00,0x00	;C8 C9
	.db 0x0D,0x7D	;CA CB		
	.db 0x00,0x7C	;CC CD		
	.db 0x00,0x00	;CE CF
	.db 0x00,0x00	;E0 E1
	.db 0x00,0x00	;E2 E3
	.db 0x00,0x00	;E4 E5
	.db 0x08,0x00	;E6 E7
	.db 0x00,0x31	;E8 E9
	.db 0x00,0x34	;EA EB
	.db 0x37,0x00	;EC ED
	.db 0x00,0x00	;EE EF
	.db 0x30,0x2E	;F0,F1			
	.db 0x32,0x35	;F2,F3
	.db 0x36,0x38	;F4,F5
	.db 0x1B,0x00	;F6,F7
	.db 0x00,0x2B	;F8,F9
	.db 0x33,0x2D	;FA,FB
	.db 0x2A,0x39	;FC,FD
	.db 0x39,0x00	;FE,FF

.org $000					
	rjmp	Main				;Reset Handle
.org INT1addr
	rjmp	Keyboardint			;Interrupt routine

;Register variables

.def	KEYCNT	=r17
.def	KEYIN	=r18
.def	KEYOUT	=r19
.def	TEMP	=r16
.def	ASCII	=r20
.def	SHIFT	=r21
.def	CTRL	=r23
.def	RELCODE	=r22	
.def	STROBE	=r24
.def	LOOP	=r25

;R28 AS CAPS LOCK
;R29 as E0 extended key pressed.

Main:
	ldi 	TEMP,high(RAMEND)   		;Set stack pointer to top of RAM
	out 	SPH,TEMP
	ldi 	TEMP,low(RAMEND)
	out 	SPL,TEMP
	ldi 	STROBE,$80
	ldi 	LOOP,$00
	ldi 	r28,1				;set caps lock to off
	ldi 	CTRL,$00
	ldi 	RELCODE,$00
	ldi 	SHIFT,$00
	ldi	XH,high(KeyStack)		;Set X to KeyStack
	ldi	XL,low(KeyStack)
	ldi	KEYCNT,$0B			;initialize bit counter for keyboard input
	sbi	DDRB,DDB3			;portB pins 3 & 4 output
	sbi	DDRB,DDB4
	ser	TEMP				;portC output
	out	DDRC,TEMP
	ldi 	TEMP,0x00
	out 	PORTC,TEMP
	in	TEMP,MCUCR			;set INT1 neg/edge irq enable
	ori	TEMP,0b00001000			;ISC11=1
	andi	TEMP,0b11111011			;ISC10=0 MAKE THIS =1 FOR RISING EDGE INT 0b11111111
	out	MCUCR,TEMP
	in	TEMP,GIMSK			;enable INT1
	ori	TEMP,$80
	out	GIMSK,TEMP
	sei					;turn on global interupts
forever:
	ldi	TEMP,low(KeyStack)		;check Keyboard input stack
	cpse	XL,TEMP				;is there data there?
	rcall	KeyBuff				;yep, lets start processing
	rjmp 	forever

KeyBuff:
	ld	KEYOUT,-X			;send last keyboard scancode -> portc
	cpi 	KEYOUT,$F0			;Check for $F0, is it a release code?
	BRNE 	nof0				;no check 1st shift/ctrl
	ldi 	RELCODE,$01			;yes set rel flag
	rjmp 	noout				;return with no output
extkey:						;set extended key so I can check for extended characters later
	ldi 	R29,1
	rjmp 	noout
nof0:						;CHECK FOR E0 IN CHARACTER IF YES THEN SKIP EXTENDED CHAR
	cpi 	KEYOUT,$E0			;is character $E0?
	brne 	noe0				;no
	rjmp 	extkey				;yes, skip and continue
noe0:
	cpi 	RELCODE,$01			;is release flag set?
	brne 	norel				;no goto regular output code
	ldi 	RELCODE,$00
	cpi 	KEYOUT,$12			;is 1st key notice left shift?
	brne 	setrt				;no, check right shift
	ldi 	SHIFT,$00			;yes, set shift flag
	ldi 	RELCODE,$00
	rjmp 	noout				;return with no output
setrt:
	cpi 	KEYOUT,$59			;is 1st key notice right shift?
	brne 	tryctrl				;no, check for control press
	ldi 	SHIFT,$00			;yes, set shift flag
	ldi 	RELCODE,$00
	rjmp 	noout
tryctrl:					;check control key here
	cpi 	KEYOUT,$14			;is it 1st CTRL key?
	brne 	testme				;no, return
	ldi 	CTRL,$00			;yes, set CTRL flag
	ldi 	RELCODE,$00
	rjmp 	noout				;return

norel:						;begin regular check of keys to ouput
Lfshift:
	cpi 	KEYOUT,$12			;is key left shift?
	brne 	Rtshift				;no, check right shift
	ldi 	SHIFT,$01			;yes, set shift reg back to 0
	rjmp 	Noout
Rtshift:
	cpi 	KEYOUT,$59			;is it right shift?
	brne 	Nort				;no

	ldi 	SHIFT,$01			;yes, set shift register back to 0
	rjmp 	Noout
testme:
	rjmp 	noout
Nort:						;New code to check control release
	cpi 	KEYOUT,$14			;is it CTRL release?
	brne 	tryprint			;no, continue on
	ldi 	CTRL,$01			;yes clear CTRL flag
tryprint:
	cpi 	SHIFT,$01			;YES! is shift key being pressed?
	brne 	eep_not				;no dont add to ascii val
	ldi 	TEMP,0x80
	add 	KEYOUT,TEMP			;make flash addy +$70
	
eep_not:					;FLASH CODE ROUTINE HERE
	ldi 	r31,0x02			;load from 0x100...
	ldi 	r30, 0x00			;reset register 30 to 0x00
	ldi 	TEMP,0x01
	adc 	r30,KEYOUT			;set the address to get it from
	cpi 	KEYOUT,0x7C			;is it shifted?
	brlo 	subshift
	rjmp 	rdflash
subshift:
	sub 	r30,TEMP
rdflash:
	lpm 	ASCII,Z				;get character
	cpi 	CTRL,$01			;check if its a ctrl character, is ctrl flag set?
	brne 	sendit				;no, regular character
	cpi 	ASCII,$40			;is ASCII character less than $40
	brlo 	sendit				;Yes, then don't subtract for CTRL
	ldi 	TEMP,0x40
	sub 	ASCII,TEMP			;subtract $40 from ascii val
sendit:
	cpi 	ASCII,$00			;Is ASCII a legal text character?
	brne 	okprint				;yes, go send it
	rjmp 	noout				;no, not a legal character skip output
okprint:					;check for extended characters
	cpi 	r29,0				;was character extended key?
	breq	oknow				;no, continue
	cpi 	ASCII,$2E			;yes, was it del?
	brne 	notdel
	ldi 	ASCII,$08			;make del same as backspace
	rjmp 	oknow
notdel:
	cpi 	ASCII,$34			;left arrow same as backspace
	brne 	nolarrow
	ldi 	ASCII,$08
	rjmp 	oknow
nolarrow:
	cpi 	ASCII,$37			;is it home key(looks like '7')
	brne 	nohome
	ldi 	ASCII,$02			;load so video will go to home position
	rjmp 	oknow
nohome:
	cpi 	ASCII,$31			;is it end key (looks like '1') end will clear screen
	brne 	noend
	ldi 	ASCII,$01
	rjmp 	oknow
noend:
	cpi 	ASCII,$36			;is it rt arrow?
	brne 	norarrow			;no check other keys
	ldi 	ASCII,$20
	rjmp 	oknow
norarrow:
	cpi 	ASCII,$32			;is it downarrow?
	brne 	nodown				;no check other keys
	ldi 	ASCII,$0D			;make it LF command
	rjmp 	oknow
nodown:
	cpi 	ASCII,$38			;is it up arrow?
	brne 	noup				;no check other keys
	ldi 	ASCII,$02			;make up arrow home
	rjmp 	oknow
noup:						;no other keys get sent
	cpi 	ASCII,$30			;is it insert?
	brne 	noinsert			;no continue
	ldi 	ASCII,$10
	rjmp 	oknow
noinsert:
	cpi 	ASCII,$39			;is it pageup?
	brne 	nopageup			;no check pagedown
	ldi 	ASCII,$02			;home position again
	rjmp 	oknow
nopageup:
	cpi 	ASCII,$33			;is it pagedown
	brne 	oknow				;no, just continue
	ldi 	ASCII,$03			
oknow:						;main check here if caps is on and between 0x61 - 0x7A 

okprint2:
	add 	ASCII,STROBE			;set the strobe bit
	out	PORTC,ASCII			;send ASCII character to Port C
	ldi 	LOOP,$1F
pause:
	ldi 	TEMP,$FF
pau2:
	dec 	TEMP
	cpi 	TEMP,0
	brne 	pau2
	dec 	LOOP
	cpi 	LOOP,$00
	brne 	pause
	sub 	ASCII,STROBE
	out 	PORTC,ASCII
	ldi 	r29,0				;reset extended key to 0
Noout:
	ret
Keyboardint:					;KEYBOARD BIT DETECTED, GET BIT STORE AND RETURN
	dec	KEYCNT				
	cpi	KEYCNT,$0A			
	breq	Intret
	cpi	KEYCNT,$01			
	breq	Intret
	cpi	KEYCNT,$00			
	brne	KeyINBit			
	st	X+,KEYIN			
	ldi	KEYCNT,$0B			
	clr	KEYIN				
	rjmp	Intret				
KeyINBit: 
	sbic	PINB,PB0			
	sec					
	sbis	PINB,PB0
	clc					
	ror	KEYIN				
Intret:	
	reti					;return from interrupt

