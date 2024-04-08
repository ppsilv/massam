;Replica 1 Video Firmware
;
;Written by Greg Glawitsch
;(c) 2004 www.ultradense.com
;
;Modified by Vince Briel
;
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
;ATMEGA8 contains 8 KBytes of Flash
;organized as 4K * 16 bits
;i.e. word addresses 0x000 to 0xFFF are available 
:(boot flash section at the top)
;RAM layout:
;char data from 0x60 thru 0x41F
;stack downwards from 0x45F
;
;wiring: PB3 and PB2 apply a signal to the video output
;(which one is "blank" and which one is "black" is arbitrary)
;FOR NOW, KEEP BOTH ONES AT "1" except during HSYNC
;the "blank" output is connected to a 1500 Ohms resistor (via a diode)
;PB0 is connected to the "parallel load" pin of the shift register
;(the output of the shift register is connected to a 470 Ohms resistor-via a diode)
;
; register allocation:
; Y ... points to last RAM location a character has been written 
;       it is always pre-incremented when writing a char
; Z ... doubles as a scrolling mem pointer (R/W) and a Flash ROM lookup pointer (R)

;**** Includes ****

.include "m8def.inc"			; change if an other device is used

;**** Global I2C Constants ****

.equ	SCLP	= 1			; SCL Pin number (port D)
.equ	SDAP	= 0			; SDA Pin number (port D)

.equ	b_dir	= 0			; transfer direction bit in i2cadr

.equ	i2crd	= 1
.equ	i2cwr	= 0

;**** Global Register Variables ****

; r0 is used for LPM/LPR instruction, dedicated             	
; r1 is used for LD instruction                             	
; r2,r3,r4,r5 ... up to 32 bits of interesting shift data   	
; r6, r7 ... 16 bits of de-mangled shift data               	
; r8 ... output of the inputhexbyte subroutine
; r9 ... second byte of 16-bit writedata
; r11, r10 ... savearea for r27,r26 
; r13, r12 ... ring buffer read pointer (points to location to be read next)
; r15, r14 ... ring buffer write pointer (points to location to be written next)

.def	flashreadcnt 	= r16			
.def	flashreadcnt2	= r17	
.def	bang	     	= r18				
.def    fudgefactor	= r19	
.def    stored_char 	= r20					
.def    ggloop  	= r21		
.def    ggloop2 	= r23				
; r25:24 can be used with ADIW instruction
.def	needtoscroll   	= r24	 
.def    column  	= r25	; 0-based
; X = r27:r26  
; Y = r29,r28  
; Z = r31,r30  

; memory map:
;
; $60 thru $84 ... working copy of safeconf
; $85 thru $A4 ... up to 32 bytes of FLASH BLOCK WRITE DATA
; $A5 thru $C4 ... 32 bytes of UART receive ring buffer
; $C5 thru $DF ... stack

;**** Interrupt Vectors ****


	.ORG	0x100 
line1data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x08	;  ! blank and bang
	.db	0x14,0x14	; "#
	.db	0x08,0x06	; $%
	.db	0x04,0x08	; &'
	.db	0x08,0x08	; ()
	.db	0x08,0x00	; *+
	.db	0x00,0x00	; ,-
	.db	0x00,0x00	; ./
	
	.db	0x1C,0x08	; 01
	.db	0x1C,0x3E	; 23
	.db	0x10,0x3E	; 45
	.db	0x38,0x3E	; 67
	.db	0x1C,0x1C	; 89
	.db	0x00,0x00	; :;
	.db	0x10,0x00	; <=
	.db	0x04,0x1C	; >?
	
	.db	0x1C,0x08	; @A
	.db	0x1E,0x1C	; BC
	.db	0x1E,0x3E	; DE
	.db	0x3E,0x1C	; FG
	.db	0x22,0x1C	; HI
	.db	0x38,0x22	; JK
	.db	0x02,0x22	; LM
	.db	0x22,0x1C	; NO
	
	.db	0x1E,0x1C	; PQ
	.db	0x1E,0x1C	; RS
	.db	0x3E,0x22	; TU
	.db	0x22,0x22	; VW
	.db	0x22,0x22	; XY
	.db	0x3E,0x3E	; Z[
	.db	0x00,0x3E	; \]
	.db	0x00,0x00	; ^_
	
	.db	0x08,0x00	; `a not used in replica 1
	.db	0x00,0x00	; bc		
	.db	0x00,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x00	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x20	; z{
	.db	0x08,0x02	; |}
	.db	0x14,0x00	; ~¦
	
	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.ORG	0x200 
line2data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x08	;  ! blank and bang
	.db	0x14,0x14	; "#
	.db	0x3C,0x26	; $%
	.db	0x0A,0x08	; &'
	.db	0x04,0x10	; ()
	.db	0x2A,0x08	; *+
	.db	0x00,0x00	; ,-
	.db	0x00,0x20	; ./
	
	.db	0x22,0x0C	; 01
	.db	0x22,0x20	; 23
	.db	0x18,0x02	; 45
	.db	0x04,0x20	; 67
	.db	0x22,0x22	; 89
	.db	0x08,0x00	; :;
	.db	0x08,0x00	; <=
	.db	0x08,0x22	; >?
	
	.db	0x22,0x14	; @A
	.db	0x22,0x22	; BC
	.db	0x22,0x02	; DE
	.db	0x02,0x22	; FG
	.db	0x22,0x08	; HI
	.db	0x10,0x12	; JK
	.db	0x02,0x36	; LM
	.db	0x22,0x22	; NO
	
	.db	0x22,0x22	; PQ
	.db	0x22,0x22	; RS
	.db	0x08,0x22	; TU
	.db	0x22,0x22	; VW
	.db	0x22,0x22	; XY
	.db	0x20,0x06	; Z[
	.db	0x02,0x30	; \]
	.db	0x00,0x00	; ^_
	
	.db	0x10,0x00	; `a
	.db	0x00,0x00	; bc
	.db	0x00,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x00	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x10	; z{
	.db	0x08,0x04	; |}
	.db	0x0A,0x00	; ~¦

	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.ORG	0x300 ; was 180, worked
line3data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x08	;  ! blank and bang
	.db	0x14,0x3E	; "#
	.db	0x0A,0x10	; $%
	.db	0x0A,0x08	; &'
	.db	0x02,0x20	; ()
	.db	0x1C,0x08	; *+
	.db	0x00,0x00	; ,-
	.db	0x00,0x10	; ./
	
	.db	0x32,0x08	; 01
	.db	0x20,0x10	; 23
	.db	0x14,0x1E	; 45
	.db	0x02,0x10	; 67
	.db	0x22,0x22	; 89
	.db	0x08,0x08	; :;
	.db	0x04,0x3E	; <=
	.db	0x10,0x10	; >?
	
	.db	0x2C,0x22	; @A
	.db	0x22,0x02	; BC
	.db	0x22,0x02	; DE
	.db	0x02,0x02	; FG
	.db	0x22,0x08	; HI
	.db	0x10,0x0A	; JK
	.db	0x02,0x2A	; LM
	.db	0x26,0x22	; NO
	
	.db	0x22,0x22	; PQ
	.db	0x22,0x02	; RS
	.db	0x08,0x22	; TU
	.db	0x22,0x22	; VW
	.db	0x14,0x22	; XY
	.db	0x10,0x06	; Z[
	.db	0x04,0x30	; \]
	.db	0x08,0x00	; ^_
	
	.db	0x20,0x00	; `a		
	.db	0x0,0x00	; bc
	.db	0x0,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x00	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x10	; z{
	.db	0x08,0x04	; |}
	.db	0x00,0x00	; ~¦

	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	
	.ORG	0x400 ; was 200, worked
line4data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x08	;  ! blank and bang
	.db	0x00,0x14	; "#
	.db	0x1C,0x08	; $%
	.db	0x04,0x00	; &'
	.db	0x02,0x20	; ()
	.db	0x08,0x3E	; *+
	.db	0x00,0x3E	; ,-
	.db	0x00,0x08	; ./
	
	.db	0x2A,0x08	; 01
	.db	0x18,0x18	; 23
	.db	0x12,0x20	; 45
	.db	0x1E,0x08	; 67
	.db	0x1C,0x3C	; 89
	.db	0x00,0x00	; :;
	.db	0x02,0x00	; <=
	.db	0x20,0x08	; >?
	
	.db	0x2A,0x22	; @A
	.db	0x1E,0x02	; BC
	.db	0x22,0x1E	; DE
	.db	0x1E,0x3A	; FG
	.db	0x3E,0x08	; HI
	.db	0x10,0x06	; JK
	.db	0x02,0x2A	; LM
	.db	0x2A,0x22	; NO
	
	.db	0x1E,0x22	; PQ
	.db	0x1E,0x1C	; RS
	.db	0x08,0x22	; TU
	.db	0x22,0x2A	; VW
	.db	0x08,0x14	; XY
	.db	0x08,0x06	; Z[
	.db	0x08,0x30	; \]
	.db	0x14,0x00	; ^_
	
	.db	0x00,0x00	; `a			
	.db	0x00,0x00	; bc
	.db	0x00,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x00	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x08	; z{
	.db	0x08,0x08	; |}
	.db	0x00,0x00	; ~¦

	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	
	.ORG	0x500 
line5data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x08	;  ! blank and bang
	.db	0x00,0x3E	; "#
	.db	0x28,0x04	; $%
	.db	0x2A,0x00	; &'
	.db	0x02,0x20	; ()
	.db	0x1C,0x08	; *+
	.db	0x08,0x00	; ,-
	.db	0x00,0x04	; ./
	
	.db	0x26,0x08	; 01
	.db	0x04,0x20	; 23
	.db	0x3E,0x20	; 45
	.db	0x22,0x04	; 67
	.db	0x22,0x20	; 89
	.db	0x00,0x08	; :;
	.db	0x04,0x3E	; <=
	.db	0x10,0x08	; >?
	
	.db	0x2A,0x3E	; @A
	.db	0x22,0x02	; BC
	.db	0x22,0x02	; DE
	.db	0x02,0x22	; FG
	.db	0x22,0x08	; HI
	.db	0x10,0x0A	; JK
	.db	0x02,0x22	; LM
	.db	0x32,0x22	; NO
	
	.db	0x02,0x2A	; PQ
	.db	0x22,0x20	; RS
	.db	0x08,0x22	; TU
	.db	0x22,0x2A	; VW
	.db	0x14,0x08	; XY
	.db	0x04,0x06	; Z[
	.db	0x10,0x30	; \]
	.db	0x22,0x00	; ^_
	
	.db	0x00,0x00	; `a			
	.db	0x00,0x00	; bc
	.db	0x00,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x20	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x10	; z{
	.db	0x08,0x04	; |}
	.db	0x00,0x00	; ~¦

	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	
	.ORG	0x600 
line6data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x00	;  ! blank and bang
	.db	0x00,0x14	; "#
	.db	0x1E,0x32	; $%
	.db	0x12,0x00	; &'
	.db	0x04,0x10	; ()
	.db	0x2A,0x08	; *+
	.db	0x08,0x00	; ,-
	.db	0x00,0x02	; ./
	
	.db	0x22,0x08	; 01
	.db	0x02,0x22	; 23
	.db	0x10,0x22	; 45
	.db	0x22,0x04	; 67
	.db	0x22,0x10	; 89
	.db	0x08,0x08	; :;
	.db	0x08,0x00	; <=
	.db	0x08,0x00	; >?
	
	.db	0x2A,0x22	; @A
	.db	0x22,0x22	; BC
	.db	0x22,0x02	; DE
	.db	0x02,0x22	; FG
	.db	0x22,0x08	; HI
	.db	0x12,0x12	; JK
	.db	0x02,0x22	; LM
	.db	0x22,0x22	; NO
	
	.db	0x02,0x12	; PQ
	.db	0x22,0x22	; RS
	.db	0x08,0x22	; TU
	.db	0x14,0x2A	; VW
	.db	0x22,0x08	; XY
	.db	0x02,0x06	; Z[
	.db	0x20,0x30	; \]
	.db	0x00,0x00	; ^_
	
	.db	0x00,0x00	; `a			
	.db	0x00,0x00	; bc
	.db	0x00,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x00	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x10	; z{
	.db	0x08,0x04	; |}
	.db	0x00,0x00	; ~¦

	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	
	.ORG	0x700 ; was 380, worked
line7data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x08	;  ! blank and bang
	.db	0x00,0x14	; "#
	.db	0x08,0x30	; $%
	.db	0x2C,0x00	; &'
	.db	0x08,0x08	; ()
	.db	0x08,0x00	; *+
	.db	0x04,0x00	; ,-
	.db	0x08,0x00	; ./
	
	.db	0x1C,0x1C	; 01
	.db	0x3E,0x1C	; 23
	.db	0x10,0x1C	; 45
	.db	0x1C,0x04	; 67
	.db	0x1C,0x0E	; 89
	.db	0x08,0x04	; :;
	.db	0x10,0x00	; <=
	.db	0x04,0x08	; >?
	
	.db	0x1C,0x22	; @A
	.db	0x1E,0x1C	; BC
	.db	0x1E,0x3E	; DE
	.db	0x02,0x1C	; FG
	.db	0x22,0x1C	; HI
	.db	0x0C,0x22	; JK
	.db	0x3E,0x22	; LM
	.db	0x22,0x1C	; NO
	
	.db	0x02,0x2C	; PQ
	.db	0x22,0x1C	; RS
	.db	0x08,0x1C	; TU
	.db	0x08,0x14	; VW
	.db	0x22,0x08	; XY
	.db	0x3E,0x3E	; Z[
	.db	0x00,0x3E	; \]
	.db	0x00,0x00	; ^_
	
	.db	0x00,0x00	; `a			
	.db	0x00,0x00	; bc
	.db	0x00,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x00	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x20	; z{
	.db	0x08,0x02	; |}
	.db	0x00,0x00	; ~¦

	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	
	.ORG	0x800 
line8data:
	.db	0x00,0x00	; 0,1	
	.db	0x00,0x00	; 2,3
	.db	0x00,0x00	; 4,5
	.db	0x00,0x00	; 6,7	
	.db	0x00,0x00	; 8,9
	.db	0x00,0x00	; A,B
	.db	0x00,0x00	; C,D
	.db	0x00,0x00	; E,F
	.db	0x00,0x00	; 10,11
	.db	0x00,0x00	; 12,13
	.db	0x00,0x00	; 14,15	
	.db	0x00,0x00	; 16,17
	.db	0x00,0x00	; 18,19
	.db	0x00,0x00	; 1A,1B
	.db	0x00,0x00	; 1C,1D
	.db	0x00,0x00	; 1E,1F
	
	.db	0x00,0x00	;  ! blank and bang
	.db	0x00,0x00	; "#
	.db	0x00,0x00	; $%
	.db	0x00,0x00	; &'
	.db	0x00,0x00	; ()
	.db	0x00,0x00	; *+
	.db	0x00,0x00	; ,-
	.db	0x00,0x00	; ./
	
	.db	0x00,0x00	; 01
	.db	0x00,0x00	; 23
	.db	0x00,0x00	; 45
	.db	0x00,0x00	; 67
	.db	0x00,0x00	; 89
	.db	0x00,0x00	; :;
	.db	0x00,0x00	; <=
	.db	0x00,0x00	; >?
	
	.db	0x00,0x00	; @A
	.db	0x00,0x00	; BC
	.db	0x00,0x00	; DE
	.db	0x00,0x00	; FG
	.db	0x00,0x00	; HI
	.db	0x00,0x00	; JK
	.db	0x00,0x00	; LM
	.db	0x00,0x00	; NO
	
	.db	0x00,0x00	; PQ
	.db	0x00,0x00	; RS
	.db	0x00,0x00	; TU
	.db	0x00,0x00	; VW
	.db	0x00,0x00	; XY
	.db	0x00,0x00	; Z[
	.db	0x00,0x00	; \]
	.db	0x00,0x3E	; ^_
	
	.db	0x00,0x00	; `a
	.db	0x00,0x00	; bc
	.db	0x00,0x00	; de
	.db	0x00,0x00	; fg
	.db	0x00,0x00	; hi
	.db	0x00,0x00	; jk
	.db	0x00,0x00	; lm
	.db	0x00,0x00	; no
	
	.db	0x00,0x00	; pq
	.db	0x00,0x00	; rs
	.db	0x00,0x00	; tu
	.db	0x00,0x00	; vw
	.db	0x00,0x00	; xy
	.db	0x00,0x00	; z{
	.db	0x00,0x00	; |}
	.db	0x00,0x00	; ~¦

	; cursor data here (a solid white block)
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF

	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	.db	0xFF,0xFF
	
	.ORG	0x900 
emptydata:									
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	

	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	.db	0b00000000, 0b00000000	
	rjmp	RESET			; Reset handler at $000
;------------------------------------------------------------------------------
	
RESET:
main:	

        ldi     bang,0x5F
        out     SPL,bang		; stack pointer low
        ldi	bang,0x4
        out	SPH,bang		; stack pointer high
        
        ldi	bang,0x3F		; bits 7, 6 input, 5..0 output
        out	DDRB,bang
        
        ldi	bang,0x21		; do not load the shift register
        out	PORTB,bang
        
        ldi	bang,0x20
        out     UCSRA,bang		; U2X is set to 0
        
        ldi     bang,0			
        out     UBRRH,bang			
        ldi 	bang,0x3		; 3 = 115 kBit at 7.3728 MHz
        out	UBRRL,bang
        
	ldi	bang,0x00		; RECEIVER AND TRANSMITTER OFF
        out     UCSRB,bang
        ldi     i2cstat,0x00		; pins 7..0 input
	out	DDRD,bang            
        
	clr	bang			
	out	PORTD,bang		; inputs tri-state, outputs 0

	ldi	bang,0xFF
	out	DDRC,bang		; all pins of port C are output
	
; now set new Y pointer to start of line 0

	ldi	r29,0			; Yhigh  
	ldi	r28,0x60		; Ylow    
	
    	ldi     r27,0			; high part of X
    	ldi     r26,0x60		; bottom of static RAM, well clear of the stack

; CPU is clocked with 14.31818 MHz, shift register is clocked with half of that
; shift register shifts 6 bits before being reloaded
; this means the CPU can execute 12 instructions between SR reloads
; port B0 is -PE (parallel enable) of the shift register 
; (note: needs clock rising edge!!!)
; port PC0..5 is the load data
; PC0 is connected to D7 (appears immediately at Q7 on rising edge)
; DC5 is connected to D2
; D0 and D1 as well as serial input are connected to GND

	ldi	bang,0xFF		; all bits output
	out 	DDRC,bang		; all bits output
	ldi 	bang,0x00
	out 	PORTC,bang
	
	ldi	bang,0x21		; parallel load INACTIVE high, -RDA inactive high
	out	PORTB,bang

	ldi	column,0
	ldi	needtoscroll,0
    	ldi     fudgefactor,0
			
; initialize the RAM with 40 x 24  '@' characters

	ldi	r27,0			; Xhigh
	ldi	r26,0x60		; Xlow
	ldi	bang,32			; BLANK character
	ldi	ggloop,2
initram:	
	ldi	ggloop2,40
initram_inner:
	st	X+,bang
	cpi	bang,0x60		
	brne	initram_skip
	ldi	bang,32			; start with blank this time
initram_skip:	
	dec	ggloop2
	brne	initram_inner
	dec	ggloop
	brne	initram
	ldi	bang,0x80  		; 0x80 cursor (anything with bit 7 set)
	sts	0x060,bang			

; real video image with char lookup
; 455 woz dots in a line (320 are payload, 135 are non-payload)
; 910 instructions in a line (640 are payload, 270 are non-payload)
; 242 hsync lines (24*8=192 of which contain real payload
; rest is 50=2*25)
; followed by
;  20 vsync lines
; 
realimage:
; character line 0
	ldi	r27,0			; Xhigh
	ldi	r26,0x60		; Xlow
	rcall	tencharlines		
; character line 1
	nop
	nop
	ldi	r27,0			; Xhigh
	ldi	r26,0x88		; Xlow
	rcall	tencharlines		; character line 2
	nop
	nop
	ldi	r27,0			; Xhigh
	ldi	r26,0xB0		; Xlow
	rcall	tencharlines			
; character line 3
	nop
	nop
	ldi	r27,0			; Xhigh
	ldi	r26,0xD8		; Xlow
	rcall	tencharlines
; character line 4
	nop
	nop
	ldi	r27,1			; Xhigh
	ldi	r26,0x00		; Xlow
	rcall	tencharlines
; character line 5
	nop
	nop
	ldi	r27,1			; Xhigh
	ldi	r26,0x28		; Xlow
	rcall	tencharlines
; character line 6
	nop
	nop
	ldi	r27,1			; Xhigh
	ldi	r26,0x50		; Xlow
	rcall	tencharlines
; character line 7
	nop
	nop
	ldi	r27,1			; Xhigh
	ldi	r26,0x78		; Xlow
	rcall	tencharlines
; character line 8
	nop
	nop
	ldi	r27,1			; Xhigh
	ldi	r26,0xA0		; Xlow
	rcall	tencharlines
; character line 9
	nop
	nop
	ldi	r27,1			; Xhigh
	ldi	r26,0xC8		; Xlow
	rcall	tencharlines
; character line 10
	nop
	nop
	ldi	r27,1			; Xhigh
	ldi	r26,0xF0		; Xlow
	rcall	tencharlines
; character line 11
	nop
	nop
	ldi	r27,2			; Xhigh
	ldi	r26,0x18		; Xlow
	rcall	tencharlines
; character line 12
	nop
	nop
	ldi	r27,2			; Xhigh
	ldi	r26,0x40		; Xlow
	rcall	tencharlines
; character line 13
	nop
	nop
	ldi	r27,2			; Xhigh
	ldi	r26,0x68		; Xlow
	rcall	tencharlines
; character line 14
	nop
	nop
	ldi	r27,2			; Xhigh
	ldi	r26,0x90		; Xlow
	rcall	tencharlines
; character line 15
	nop
	nop
	ldi	r27,2			; Xhigh
	ldi	r26,0xB8		; Xlow
	rcall	tencharlines
; character line 16
	nop
	nop
	ldi	r27,2			; Xhigh
	ldi	r26,0xE0		; Xlow
	rcall	tencharlines
; character line 17
	nop
	nop
	ldi	r27,3			; Xhigh
	ldi	r26,0x08		; Xlow
	rcall	tencharlines
; character line 18
	nop
	nop
	ldi	r27,3			; Xhigh
	ldi	r26,0x30		; Xlow
	rcall	tencharlines
; character line 19
	nop
	nop
	ldi	r27,3			; Xhigh
	ldi	r26,0x58		; Xlow
	rcall	tencharlines
; character line 20
	nop
	nop
	ldi	r27,3			; Xhigh
	ldi	r26,0x80		; Xlow
	rcall	tencharlines
; character line 21
	nop
	nop
	ldi	r27,3			; Xhigh
	ldi	r26,0xA8		; Xlow
	rcall	tencharlines
; character line 22
	nop
	nop
	ldi	r27,3			; Xhigh
	ldi	r26,0xD0		; Xlow
	rcall	tencharlines			
; character line 23
	nop
	nop
	ldi	r27,3			; Xhigh
	ldi	r26,0xF8		; Xlow
	rcall	tencharlines		; char data goes to 0x41F
	nop
	nop
	nop
	nop
	rcall 	thirteendummylines		
	nop
	nop
	ldi	r31,0			; Zhigh pointer for scrolling
	ldi	r30,0x60		; Zlow  pointer for scrolling
	rcall	twentyvsynclines		
	nop
	nop
	nop
	nop
	rcall 	thirteendummylines		
	rjmp	realimage		
tencharlines: ; actually only 8 now					
	ldi	r31,HIGH(line1data*2)	; Zhigh 
	rcall	onepixelline		
	ldi	fudgefactor,0		
	nop				
	nop				
	nop				
	nop				
	nop				
	nop				
	ldi	r31,HIGH(line2data*2)	; Zhigh  
	rcall	onepixelline	
	ldi	fudgefactor,0
	nop
	nop
	nop
	nop
	nop
	nop
	ldi	r31,HIGH(line3data*2)	; Zhigh
	rcall	onepixelline		
	ldi	fudgefactor,0
	nop
	nop
	nop
	nop
	nop
	nop
	ldi	r31,HIGH(line4data*2)	; Zhigh
	rcall	onepixelline		
	ldi	fudgefactor,0
	nop
	nop
	nop
	nop
	nop
	nop
	ldi	r31,HIGH(line5data*2)	; Zhigh
	rcall	onepixelline		
	ldi	fudgefactor,0
	nop
	nop
	nop
	nop
	nop
	nop
	ldi	r31,HIGH(line6data*2)	; Zhigh
	rcall	onepixelline		
	ldi	fudgefactor,0
	nop
	nop
	nop
	nop
	nop
	nop
	ldi	r31,HIGH(line7data*2)	; Zhigh
	rcall	onepixelline		
	ldi	fudgefactor,0
	nop
	nop
	nop
	nop
	nop
	nop
	ldi	r31,HIGH(line8data*2)	; Zhigh
	nop
	rjmp	onepixelline		; return from there
onepixelline:
; We arrive here 11 instructions into the line
; At the end, the "ret" burns another 4 cycles for a total of 15
; Since a video line lasts a total of 910 instructions,
; we have to burn exactly 910-15 = 895 instructions in the body of
; this subroutine.
;
; start by taking HSYNC to 0V for 67 instructions 
; (taking HSYNC low is the reference point)
; 172 instructions from the reference point (12 us), the payload starts
; payload length is 40 * 16 = 640 instructions
; 172+640 == 812 instructions from the reference point, the payload ends
; after that, we have to burn another 895-812=83 instructions in the body
; of this subroutine
; front porch (22 instructions till taking HSYNC low)
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop			
; taking HSYNC low means turning PB2 and PB3 off keep PB0 high
	ldi	flashreadcnt,0x21		
	out	PORTB,flashreadcnt	; take HSYNC low 
	ldi	ggloop,21		
hsyncloop:
	dec	ggloop			
	brne	hsyncloop		
	nop				
	nop				
; taking HSYNC high means turning PB2 and PB3 on keep PB0 high

	ldi	flashreadcnt,0x2F	
	out	PORTB,flashreadcnt	; take HSYNC high 
; waste some time now (back porch)
	ldi	ggloop,39		    
wasteloop:
	dec	ggloop			
	brne	wasteloop		
	cpi	fudgefactor,1		
	breq	fudgetarget		
fudgetarget: 					
	ldi	ggloop,40		 
	ldi	flashreadcnt,0x2C	; parallel load PB0 active low  
	ldi	flashreadcnt2,0x2F	; parallel load PB0 inactive    
onepixloop2:
	nop					
	nop				
	nop				
	ld	r30,X+			; load character from RAM into Zlow
	lpm	bang,Z			; load pixel data from Flash-based char table
	out	PORTC,bang		
	nop				
	out	PORTB,flashreadcnt	; parallel load is active low
	nop				
	out	PORTB,flashreadcnt2	; parallel load is off again
	dec	ggloop			
	brne	onepixloop2		
	nop				; DECREASE X pointer by 40 (dec)
	com	r26			
	com	r27			
	adiw	r27:r26,41		; (for NEG) +40 (video)
	com	r26
	com 	r27			
	adiw	r27:r26,1	
; END: DECREASE X pointer by 40 (dec)
; waste some time now (back porch)
; loaded with 15, this loop lasts 45 cycles including the ldi
	ldi	ggloop,15		 
burnloop:
	dec	ggloop			
	brne	burnloop		
	nop				
	nop									
	ret
thirteendummylines: ; really 25, not 13
; we arrive here 7 instructions into the line
; dummy line 1
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 2
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 3
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 4
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 5
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 6
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 7
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 8
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 9
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 10
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 11
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 12
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 13
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		

	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 14
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 15
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 16
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 17
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 18
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 19
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 20
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 21
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 22
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 23
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 24
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	rcall	onepixelline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
; dummy line 25
	ldi	r31,HIGH(emptydata*2)	; Zhigh
	nop
	rjmp	onepixelline		;return from there
twentyvsynclines:
; we arrive here 7 instructions into the line
	nop
	rcall	onevsyncline0		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline2	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline3
	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rcall	onevsyncline		
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	nop
	rjmp	onevsyncline		;return from there	
onevsyncline:
; we arrive here 11 instructions into the line
; At the end, the "ret" burns another 4 cycles for a total of 15
; Since a video line lasts a total of 910 instructions,
; we have to burn exactly 910-15 = 895 instructions in the body of
; this subroutine.
; front porch (22 instructions till taking HSYNC low)
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop		
; THIS IS A VSYNC LINE keep HSYNC high (PB0, PB2 and PB3 high)
	ldi	flashreadcnt,0x2F	
	out	PORTB,flashreadcnt	; take HSYNC low
	ldi	ggloop,21		 
hsyncloop2:
	dec	ggloop			
	brne	hsyncloop2					
	nop				
	nop				
	
; THIS IS A VSYNC LINE (HSYNC low, PB2,PB3 low PB0 high)
	ldi	flashreadcnt,0x21	
	out	PORTB,flashreadcnt	; take HSYNC high 
	ldi	ggloop,0		
killloop:
	dec	ggloop			
	brne	killloop					
	ldi	ggloop,16		
killloop2:
	dec	ggloop			
	brne	killloop2					
	nop				
	ret				
vjaz3:
	rjmp	reset	
onevsyncline2:	
; this is the vsync line that also scrolls the text by one line
; we arrive here 11 instructions into the line
; At the end, the "ret" burns another 4 cycles for a total of 15
; Since a video line lasts a total of 910 instructions,
; we have to burn exactly 910-15 = 895 instructions in the body of
; this subroutine.

; ENTRY CONDITION: Z pointer has been set to top of character 
; RAM (0x0060) 92 characters are scrolled, hence we need 10 
;invocations to scroll 23*40 chars	
; front porch (22 instructions till taking HSYNC low)
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
; THIS IS A VSYNC LINE (keep HSYNC high PB0, PB2 and PB3 high)
	ldi	flashreadcnt,0x2F	;
	out	PORTB,flashreadcnt	; take HSYNC low 
	; loaded with 21, this loop lasts 63 cycles including the ldi
	ldi	ggloop,21		
hsyncloop3:
	dec	ggloop			
	brne	hsyncloop3		
	nop				
	nop				
; THIS IS A VSYNC LINE (take HSYNC low, PB2, PB3 low PB0 high)
	ldi	flashreadcnt,0x21	
	out	PORTB,flashreadcnt	; take HSYNC high 
	cpi	needtoscroll,1		
	brne	noneedtoscroll
; now scroll as many lines as we can  
; this copy loop burns 7 cycles per count 		
	ldi	ggloop,115		 
copyloop:	
	ldd	bang,Z+40		
	st	Z+,bang		
	dec	ggloop			
	brne	copyloop				
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop						
	ret		
noneedtoscroll:	
	ldi	ggloop,203
burn666:nop		
	dec	ggloop
	brne	burn666
	nop				
	nop	
	ret				
vjaz2:	
	jmp vjaz3				

onevsyncline3:	
; this is the vsync line that also erases the very last line
; and/or writes a character into the screen buffer
; we arrive here 11 instructions into the line
; At the end, the "ret" burns another 4 cycles for a total of 15
; Since a video line lasts a total of 910 instructions,
; we have to burn exactly 910-15 = 895 instructions in the body of
; this subroutine.

; ENTRY CONDITION: Z pointer points to the line that is to be erased
	
; front porch (22 instructions till taking HSYNC low)
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	

; THIS IS A VSYNC LINE (keep HSYNC high (PB0, PB2 and PB3 high)
	ldi	flashreadcnt,0x2F	
	out	PORTB,flashreadcnt	; take HSYNC low 
	ldi	ggloop,21		
hsyncloop4:
	dec	ggloop			
	brne	hsyncloop4					
	nop			
	nop		
; THIS IS A VSYNC LINE (take HSYNC low, PB2, PB3 low PB0 high)
	ldi	flashreadcnt,0x21	
	out	PORTB,flashreadcnt	; take HSYNC high 
	cpi	needtoscroll,1		
	brne	noneedtoerase					
; now erase the very last line  
	ldi	bang,0x20		; BLANK  
; this copy loop burns 5 cycles per count 
	ldi	ggloop,40		 
zaploop:	
	st	Z+,bang		
	dec	ggloop			
	brne	zaploop						
	cpi	stored_char,0xFF	
	breq	noneed_to_store_2
; store the char
; now set new Y pointer to start of line 23
	ldi	r29,3			; Yhigh    
	ldi	r28,0xF8		; Ylow    
	
	st	Y+,stored_char		 
	ldi	bang,0x80		; CURSOR
	st	Y,bang			; STORE CURSOR
	ldi	stored_char,0xFF	
	ldi	column,1		
	rjmp	common987	
noneed_to_store_2:			
; now set new Y pointer to start of line 23
	ldi	r29,3			; Yhigh  
	ldi	r28,0xF8		; Ylow   
	nop				
	nop				
	nop				
	nop				
	nop				
	nop				
	nop				
	nop	
common987:				
	ldi	ggloop,199		
killloop4:
	dec	ggloop			
	brne	killloop4		
	ldi	bang,0x80		; CURSOR (any 7 bit value will do)
	st	Y,i2cstat		; STORE CURSOR	
	ldi	needtoscroll,0		
	ret				
noneedtoerase:				
	cpi	stored_char,0xFF	
	breq	noneedtostore		
; store the char
	st	Y+,stored_char		
	ldi	bang,0x80		; CURSOR
	st	Y,bang			; STORE CURSOR
	ldi	stored_char,0xFF	
	rjmp	common789			
noneedtostore:				
	nop				
	nop				
	nop				
	nop				
	nop				
	nop				
	nop				
common789:				
	ldi	ggloop,201
burn555:nop		
	dec	ggloop
	brne	burn555
	ret				
vjaz1:
	rjmp	reset
home:
; home the cursor to top of screen
	ldi	bang,0x20		
	st	Y,bang			
	ldi	r29,0				
	ldi 	r28,0x60			
	ldi 	i2cstat,0x80		
	st	Y,bang			
	ldi 	column,0			
	ldi 	ggloop,2			
	nop
	nop						
	nop
	nop
	nop
	rjmp xxxxxx
tilda:					
	ldi stored_char,0x6C
	rjmp yyyyyy

onevsyncline0:
; this is the vsync line that also INPUTS A CHAR FROM PARALLEL PORT D
; we arrive here 11 instructions into the line
; At the end, the "ret" burns another 4 cycles for a total of 15
; Since a video line lasts a total of 910 instructions,
; we have to burn exactly 910-15 = 895 instructions in the body of
; this subroutine.

; ENTRY CONDITION: Y pointer points to location the char is to be stored at
	
; front porch (22 instructions till taking HSYNC low)
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	
	nop	

; THIS IS A VSYNC LINE (keep HSYNC high PB0, PB2 and PB3 high) 
	ldi	flashreadcnt,0x2F	
	out	PORTB,flashreadcnt	; take HSYNC low 
	ldi	ggloop,21		
hsyncloop5:
	dec	ggloop			
	brne	hsyncloop5		
	nop				
	nop					
; THIS IS A VSYNC LINE (take HSYNC low PB2, PB3 low PB0 high)
	ldi	flashreadcnt,0x21		
	out	PORTB,flashreadcnt	; take HSYNC high 
; read port D (accept the char only if bit 7 is HIGH)
	in	bang,PIND		
	lsl	bang			; bit 7 into carry
	brcc	no_new_char		
; bit 7 (DA) was set - we got a character!!!
	lsr	bang			; clear bit 7 (is a status bit)
; take -RDA portB.5 low then high after 3.5us
	ldi	flashreadcnt,0x01	; keep PB0 high
	out	PORTB,flashreadcnt	
	ldi	ggloop,15		
burn3point5us:
	dec	ggloop			
	brne	burn3point5us		
	ldi	flashreadcnt,0x21	; keep PB0 high
	out	PORTB,flashreadcnt	

;CLEAR SCREEN?
	cpi	bang,0x01		; Clear screen (END key)?
	breq	vjaz1			; if yes perform reset
	nop
	nop
;HOME CURSOR TO TOP OF SCREEN 0X60 FOR BOTH BOARD AND REPLICA
	cpi	bang,0x02		; is it home screen key? 
	breq	home
; character other than CR here: check for less than 0x20
	cpi	bang,0x0D		; carriage return???
	breq	intercept		; intercept was carriage_return
    	cpi	bang,0x20		
	brlo	vsyncline0_unprintable 
; character other than CR here: check for autoscroll
	cpi	column,40			
	breq	autoscroll				
; regular character here, no autoscroll
	inc	column			 
	mov	stored_char,bang	
	ldi	needtoscroll,0		
	ldi	ggloop,45		
	nop							
	nop							
	nop							
	nop	
yyyyyy:
	rjmp	xxxxxx	
no_new_char:					
	ldi	needtoscroll,0		
	ldi	stored_char,0xFF	; 0xFF means "no char"
	ldi 	ggloop,66		; 66 burns 198 cycles
burn888:
	dec	ggloop
	brne	burn888
	rjmp	common			
fin_bs:	
	ldi	stored_char,0xFF
	nop
	nop
	nop
	nop							
	nop							
	nop							
	nop							
	nop							
burn_bs:
	ldi	ggloop,43			
bs_loop:
	dec	ggloop
	brne	bs_loop
	ldi	stored_char,0xFF	
	nop							
	nop							
	nop							
	rjmp	common	
intercept:
	rjmp	carriage_return
vsyncline0_unprintable:		
	ldi	stored_char,0xFF	; 0xFF means "no char"
	ldi	needtoscroll,0		
	nop							
	nop							
	nop							
	ldi	ggloop,45			
	nop							
	nop							
	nop							
	nop							
	nop							
	rjmp	xxxxxx				
autoscroll:
	mov	stored_char,bang	
	ldi	column,1			
	ldi	ggloop,0x04				
	cp 	r29,ggloop				
	brne	vvnoscroll			
	ldi	r29,3					
	ldi 	r28,0xF8				
	ldi 	ggloop, 43		; variable diff from vvnoscroll
	ldi	needtoscroll,1		
	rjmp xxxxxx		
vvnoscroll:
	nop								
	ldi	ggloop, 43				
	nop							
	nop							
	nop
xxxxxx:							
; either a char was stored or it was not stored
; we are done and needtoscroll should be set to 0
	nop							
	nop							 
	ldi 	ggloop,45
burn999:
	dec	ggloop
	brne	burn999
	rjmp	common				

carriage_return:			; first erase the cursor
	ldi	bang,0x20			
	st	Y,bang				
	ldi 	ggloop,0x28		; advance character pointer to NEW LINE			
	sub	ggloop,column		
	clc				; clear carry flag
	add	r28,ggloop			
	ldi	column,0				
	adc	r29,column				
	ldi	bang,0x80			
	st	Y,bang				
	ldi	bang,0x04		; did we scroll past 24th line			
	cp 	r29,bang			
	brne	vnoscroll			
	ldi	r29,3					
	ldi 	r28,0xF8				
	ldi 	bang,4			; variable diff from vnoscroll
	ldi 	needtoscroll,1			
	jmp 	afterscroll				
vnoscroll:
	ldi 	bang,4				
	nop
	nop
	nop
	nop
	nop
afterscroll:
	ldi 	ggloop,42	
	sub	ggloop,bang		
burn777:
	dec	ggloop
	brne	burn777								
	ldi	stored_char,0xFF	; 0xFF means "no char"
	nop				
	nop							
	rjmp	common		
common:	
	ldi	ggloop,203		
killloop5:
	dec	ggloop			
	brne	killloop5		
	nop				
	nop					
	ret


;**** End of File ****

