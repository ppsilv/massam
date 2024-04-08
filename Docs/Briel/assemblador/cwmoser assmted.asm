;
; CW Moser MAE ASSM/TED for the KIM-1
; 
; Reconstructed source from disassmembly of dumped original binary 1979
; Comments taken from source Junior version
; TApe I/O form Fast Cassette source listing 
; Binary compatible with original 
;
; Hans Otten, Februari 2024,  TASM32
;
; Zeropage  
;  
NULVECTOR 	=  $00
USRVECTOR 	=  $03
;
DISCI 	 	=  $AC
DISCO 	 	=  $AD
DISCCVEC 	=  $AE
DISC1 	 	=  $B0
DISC2 	 	=  $B2
DISCOVEC 	=  $B4
DISCIVEC 	=  $B6
;
SAVEM 	 	=  $B9
ASSMLNKNO 	=  $BA
MACSUPPRS 	=  $BB
MACEXPAND 	=  $BC
MACSRCH 	=  $BD
CALLEXP 	=  $BE
;
CONDSUP 	=  $BF
SYMBOLIC 	=  $C0
LSTEXPOB 	=  $C1
MACSEQ 		=  $C2
FILESEQ 	=  $C4
;
SAVEXX 		=  $C6
SAVEYY 		=  $C7
;
PURECL 		=  $C8
PURECH 		=  $C9
;
MGFLAG 		=  $CA
MGADDR 		=  $CB
;
DELIM 		=  $CD
SAVE 		=  $CE
DC 			=  $CF
PNTR 		=  $D0
PROCADDRS 	=  $D1
TPRES 		=  $D3
SPRES 		=  $D5
PC 			=  $D7
REL 		=  $D9
ERRORS 		=  $DB
SCRAT0 		=  $DD
SCRAT1 		=  $DF
SCRAT2 		=  $E0
SCRAT3 		=  $E1
SCRAT4 		=  $E2
SUPPRESS0	=  $E3
SAVEY 		=  $E4
SAVEX 		=  $E5
;
LN2BOUT 	=  $E6
LNINDEX 	=  $E7
LIBYM 		=  $E8
LINELEN 	=  $E9
AUTOTAB 	=  $EA
;
;
TXST 		=  $100
TXEN 		=  $102
STST 		=  $104
STEN 		=  $106
FIRST 		=  $108
LAST 		=  $10A
INCBY 		=  $10C
MANU 		=  $10E
FORMAT		=  $10F
FILENO 		=  $110
HEXDEC 		=  $111
TERM 		=  $112
PASS 		=  $113
CONTAPE 	=  $114
AU 			=  $115
OSTORE 		=  $116
TLIST 		=  $117
ADDRS 		=  $118
ADDPAD 		=  $11A
CURSAVE 	=  $11C
EXT			=  $11E
PRINTCTL 	=  $11F
CRTEX 		=  $18F
LINECNTR 	=  $120
PAGENUMB 	=  $121
RECPOINT 	=  $122
LOADNO 		=  $123
TSTART 		=  $124
TEND 		=  $126
HFILENO 	=  $128
HSTART 		=  $129
HEND 		=  $12B
DELAY1 		=  $12D
DELAY2 		=  $12E
ASLNSV 		=  $12F
EDITFINDC 	=  $131
TABSN 		=  $133
CRT 		=  $135
;
TOP 		=  $1FE
;
; Zeropage for Fast cassette interface
;
CHECKSUM	= $B2				; (16 bit checksum)
FORMBYTE	= $B4
SYNCCOUNT	= FORMBYTE
BITCOUNT	= $B5
ADDR		= $B6
COUNT		= ADDR
;
; Page 1 for Fast cassete interface
;
; LOADNO	= $0123				; 00 =No load, 01 = load
START		= $0124				; start address
END			= $0126				; End address + 1


; KIM I/O for character I/O, Break test and Fast Cassette interface
;
; Ports:
CPORT		=	$1702			; Data port for I/O motor and ausio cassette
								; bit 0 is motor control save recorder
								; bit 1  is motor control load recorder
								; bit 2 is read from cassette, bit 3 write to
CPORTD		=	$1703			; Data direction register CPORT
SAD			= 	$1740			; TTY in bit, for breaktest
; 
; KIM Monitor
GETCH		= 	$1E5A			; read from TTY in A with hardware echo
OUTCH		= 	$1EA0 			; write to TTY 
IRQVEC		= 	$17FE			; IRQ /BRK vector
;
          .org $2000
;
          	JMP 	COLDSTART 	; Jump coldstart
;			
          	JMP 	WARMSTRT	; Jump warmstart
			
; defaults for memory areas 
			.WORD	DEFAULTS
			.WORD 	HALAYOUT
          	.WORD	EXIT0000
          	.WORD 	ERR.0
			.WORD	HALAYOUT1
;
COLDSTART  	LDX 	#$FF		; 
          	TXS 	
          	INX 	
          	STX 	DISCI
          	STX 	DISCO
          	STX 	PASS
          	STX 	SUPPRESS0
          	STX 	PRINTCTL
          	LDA 	#$17		; $3A in 65C02 version
          	NOP 	
          	JSR 	SETBNDS
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	JSR 	INIT
          	LDA 	#$01
          	STA 	LINECNTR
          	STA 	PAGENUMB
          	STA 	FORMAT
          	STA 	ERRORS
          	STX 	INCBY
          	STX 	INCBY+1
          	STX 	MANU
          	LDY 	#MESCOLD-MESERROR
          	JSR 	MESSAGE
          	LDA 	#$0B
          	STA 	AUTOTAB
CLEAR     	JSR 	TXTCLEAR
          	STX 	HFILENO
          	JSR 	PRBOUNDS
;			
MONL0OFF   	JSR 	TD0OFF 
MONL1OFF   	JSR 	TD1OFF
MONLOOP    	LDX 	#$00
MONLOOP1   	CLD 	
          	NOP 	
          	NOP 	
          	NOP 	
          	LDA 	#$00
          	NOP 	
          	NOP 	
          	NOP 	
          	STA 	PASS
          	STA 	TABSN
          	JSR 	OUTCR
LNCOM     	LDX 	#$FF
          	STX 	TERM
          	STX 	HEXDEC
          	TXS 	
          	INX 	
          	STX 	CONTAPE
          	STX 	AU
          	JSR 	INTXT
          	LDY 	#$00
          	JSR 	NXTLETTER
          	CPY 	#$50
          	BCS 	LNCOM
          	JSR 	SRCHCOM 
          	LDX 	#$ED
          	JMP 	ERR.0		; ERROR IN COMMAND INPUT
;
TXTCLEAR   	LDA 	TXST
          	STA 	TPRES
          	LDA 	TXST+1 
          	STA 	TPRES+1
TXTEND0    	TXA 	
          	LDY 	#$02
          	STA 	(TPRES),Y
          	RTS 	
;			
BREAK     	LDA 	#$80
          	NOP 	
          	NOP 	
          	NOP 	
          	BRK 	
          	NOP 	
          	NOP 	
WARMSTRT	JSR 	PRBOUNDS
          	JMP 	MONLOOP
;			
AUTO       	LDX 	#INCBY-TXST
          	JSR 	GETDECPARM 
          	JMP 	MONLOOP1
;			
GET1       	JSR 	GET
          	JMP 	MONLOOP
;			
FORMAT1    	JSR 	GETCRTUP
          	STA 	FORMAT
          	CMP 	#'C'
          	BNE 	FORMSETD
          	STX 	FORMAT
FORMSETD   	JSR 	NXTWORD
          	CPY 	#$50
          	BCS 	MONLOOP11
          	STX 	HEXDEC
          	LDA 	#$01
          	STA 	PASS
          	JSR 	OPERTST
          	INC 	PROCADDRS 
          	LDA 	PROCADDRS 
          	AND 	#$1F
          	STA 	AUTOTAB
MONLOOP11  	JMP 	MONLOOP1
;
MANUSCR    	JSR 	GETCRTUP
          	STA 	MANU
          	CMP 	#'C'
          	BNE 	MONLOOP12
          	STX 	MANU
MONLOOP12  	JMP 	MONLOOP1
;
ASSMBLE    	STX 	CONTAPE
          	STX 	PASS
          	TYA 	
          	PHA 	
          	JSR 	SPRESSTST
          	JSR 	STEND0
          	STX 	HEXDEC
          	PLA 	
          	TAY 	
          	STX 	TLIST
          	JSR 	GETCRTUP
          	CMP 	#'N'
          	BEQ 	ASLC	
          	CMP 	#'L'
          	BNE 	ASGFRST
          	INC 	TLIST
ASLC    	JSR 	NXTWORD
ASGFRST    	JSR 	INFL
          	LDA 	FIRST
          	STA 	ASLNSV
          	LDA 	FIRST+1
          	STA 	ASLNSV+1
          	JMP 	ASSEMBLE
			
RUN          	LDA 	#$01
          	STX 	HEXDEC
          	STA 	PASS
          	JSR 	OPERTST
          	JSR 	NXTWORD
          	JSR 	EXRUN
          	JMP 	MONLOOP1
;			
EXRUN     	JMP 	(PROCADDRS)
;
PRINTP     	LDA 	CRT,Y
          	CMP 	#'/'
          	BNE 	LIFL
          	LDA 	#$FF
          	STA 	FIRST+1
          	JSR 	FINDLNGE
          	LDA 	CURSAVE
          	STA 	SCRAT0
          	LDA 	CURSAVE+1
          	STA 	SCRAT0+1
          	JSR 	LILINE
          	JMP 	MONLOOP1
			
LIFL     	JSR 	INFL
          	JSR 	LILAST
          	JMP 	MONLOOP1
;			
PUTRBUF    	LDA 	PURECL
          	STA 	HSTART
          	CLC 	
          	ADC 	RECPOINT
          	STA 	HEND
          	LDA 	PURECH
          	STA 	HSTART+1
          	ADC 	#$00
          	STA 	HEND+1
          	STX 	RECPOINT
PUTIT     	JSR 	TD0ONW 
          	STY 	SAVE
          	JSR 	PUTHF 
          	LDY 	SAVE
          	JSR 	TD0OFW
          	RTS 	
;			
GETFILNO   	STX 	FILENO
          	JSR 	GETCRTUP
          	CMP 	#'F'
          	BNE 	RETGFLN
          	INY 	
          	LDX 	#LAST-TXST
          	JSR 	GETDECPARM 
          	LDA 	LAST
          	STA 	FILENO
          	JSR 	NXTLETTER
RETGFLN    	RTS 	

LILAST     	BEQ 	LILAST3
          	BCC 	LILINE
LILAST1    	LDY 	#$02
LILAST2    	DEY 	
          	BMI 	LILINE
          	LDA 	LAST,Y
          	CMP 	(SCRAT0),Y
          	BEQ 	LILAST2
          	BCS 	LILINE
LILAST3    	JSR 	LIEND
          	RTS 	
			
LILINE     	JSR 	CRTTXTLIN
          	LDA 	MANU
          	BNE 	LINOLNNR
          	JSR 	PRSPFRST
          	JSR 	OUT2SP
LINOLNNR   	JSR 	PRCRT
          	JSR 	OUTCR
          	JSR 	NXTLILA
          	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	BNE 	LILAST1
LIEND     	JSR 	CLRSPR
          	JSR 	OUTCR
          	RTS 
;			
CLRSPR     	STX 	SUPPRESS0
          	LDA 	#'/'
          	JSR 	OUTCHAR
          	LDA 	#'/'
          	JSR 	OUTCHAR
          	RTS 	

INFL     	LDX 	#FIRST-TXST
          	JSR 	GETDECPARM 
          	CPY 	#$50
          	BCC 	INLAST
          	LDA 	#$FF
          	STA 	LAST+1
          	BNE 	FINDLNGE
;			
INLAST     	JSR 	NXTLETTER
          	LDX 	#LAST-TXST
          	JSR 	GETDECPARM 
FINDLNGE    JSR 	SR0TXST
FNDEOF     	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	BNE 	CMPLNNR
FNDLNGE    	CLC 	
          	RTS 
;			
CMPLNNR   	DEY 	
          	BMI  	FNDLNGE
          	LDA 	(SCRAT0),Y
          	CMP 	FIRST,Y
          	BEQ 	CMPLNNR
          	BCC 	LNNRLESS
          	RTS 	
;			
LNNRLESS   	LDA 	SCRAT0
          	STA 	CURSAVE
          	LDA 	SCRAT0+1 
          	STA 	CURSAVE+1
          	JSR 	NXTLILA
          	JMP 	FNDEOF
;			
STINRBUF   	STY 	SAVE
          	LDY 	RECPOINT
          	STA 	(PURECL),Y
          	INC 	RECPOINT
          	LDY 	SAVE
          	RTS 	
;			
SEILOW     	LDA 	PASS
          	BPL 	SEINP2
          	LDA 	#$4F
          	INC 	HEXDEC
          	JSR 	STPROB
SEINP2     	JMP 	STPRLOPR 

GETFRSTCH     	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	RTS 
;			
EXPASS2   	INC 	PASS
          	JMP 	ASAUTOP2
;			
INTXT     	JSR 	INLINE
          	LDY 	#$00
          	LDA 	CRT,Y
          	CMP 	#'0'
          	BCC 	INNOTXT 
          	CMP 	#':'
          	BCC 	INTXTLINE 
INNOTXT    	RTS
; 	
INTXTLINE    LDX 	#FIRST-TXST
          	JSR 	PARM
          	STY 	SCRAT3
          	LDA 	ADDPAD
          	SEC 	
          	SBC 	SCRAT3
          	STA 	ADDPAD
SRCHENTRY  	JSR 	FILNDEL
          	LDY 	SCRAT3
          	JSR 	NXTLETTER
          	CPY 	#$50
          	BCS 	AU1
          	LDY 	SCRAT3
          	JSR 	INSRTLN
AU1    	 	JSR 	ADJAU 
          	BEQ 	LNCOM1
          	LDA 	FIRST
          	CLC 	
          	SED 	
          	ADC 	INCBY
          	STA 	FIRST
          	LDA 	FIRST+1
          	ADC 	INCBY+1
          	STA 	FIRST+1
          	CLD 	
          	JSR 	PRFIRST 
          	JSR 	INLINE
          	LDY 	#$00
          	STY 	SCRAT3
          	JSR 	CMP11
          	BNE 	SRCHENTRY
          	JSR 	OUTCR
LNCOM1     	JMP 	LNCOM
;
CMP11     	LDY 	#$00
          	JSR 	NXTLETTER
          	LDA 	CRT,Y
          	CMP 	#'/'
          	BNE 	RET3
          	CMP 	CRT+1,Y
RET3     	RTS 
;	
PARMDCML   	JSR 	PARM
          	CPY 	#$50
          	BCS 	RET4
          	LDA 	SCRAT1
          	BEQ 	RET4
ILLCHINDEC  LDX 	#$00
          	JMP 	ERR.9
;			
RET4     	RTS 	
;
GETDECPARM  JSR 	PARMDCML
          	LDA 	#$20
          	CMP 	CRT,Y
          	BNE 	ILLCHINDEC
          	RTS 	
;
ADJAU      	CLC 	
          	LDA 	INCBY
          	ADC 	INCBY+1
          	STA 	AU
          	RTS 	
;			
INSRTLN    	TYA 	
          	PHA 	
          	JSR 	SR12TPRES
          	LDA  	ADDPAD
          	SEC 	
          	ADC 	TPRES
          	PHA 	
          	TXA 	
          	ADC 	TPRES+1
          	CMP 	TXEN+1
          	BCC 	NEWTPRES
          	BEQ 	TXTOVFLW1
TXTOVFLW  	JMP 	ERR.F
;
TXTOVFLW1  	TAY 	
          	PLA 	
          	CMP 	TXEN
          	BCS 	TXTOVFLW
          	PHA 	
          	TYA 	
NEWTPRES   	STA 	TPRES+1
          	PLA 	
          	STA 	TPRES
          	JSR 	SR34TPRES
          	JMP 	MOVEDUP
;			
MOVEUP    	JSR 	DECSCR12
          	JSR 	DECSCR34
          	LDA 	(SCRAT1,X)
          	STA 	(SCRAT3,X)
MOVEDUP    	LDA 	SCRAT0
          	CMP 	SCRAT1
          	BNE 	MOVEUP
          	LDA 	SCRAT0+1
          	CMP 	SCRAT2
          	BNE 	MOVEUP
          	LDY 	#$00
          	LDA 	FIRST
          	STA 	(SCRAT0),Y
          	LDA 	FIRST+1
          	INY 	
          	STA 	(SCRAT0),Y
          	PLA 	
          	TAX 	
ADDLINE    	INY 	
          	LDA 	CRT,X
          	INX 	
          	STA 	(SCRAT0),Y
          	CPY  	ADDPAD
          	BNE 	ADDLINE
          	ORA 	#$80
          	STA 	(SCRAT0),Y
          	LDX 	#$00
          	JSR 	TXTEND0
          	RTS 	
;
FILNDEL    	JSR 	FINDLNGE
          	BNE 	DELIFEQ
RETF     	RTS 	
;
DELIFEQ    	BCS 	RETF
          	JSR 	SR12SR0 
          	JSR 	NXTLILA
MOVEDOWN   	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	BNE 	MVDLNNR
          	LDA 	SCRAT1
          	STA 	TPRES
          	LDA 	SCRAT2
          	STA 	TPRES+1
          	JSR 	TXTEND0
          	JSR 	FINDLNGE
          	RTS 	
;
MVDLNNR    	LDA 	(SCRAT0,X)
          	STA 	(SCRAT1,X)
          	JSR 	INCSCR0 
          	JSR 	INCSCR12
          	DEY 	
          	BNE 	MVDLNNR
MVDLINE1   	LDA 	(SCRAT0,X)
          	STA 	(SCRAT1,X)
          	PHP 	
          	JSR 	INCSCR0 
          	JSR 	INCSCR12
          	PLP 	
          	BPL 	MVDLINE1
          	BMI 	MOVEDOWN
;			
NXTLILA    	JSR 	INCSCR0 
MVDLINE   	JSR 	INCSCR0 
          	LDA 	(SCRAT0,X)
          	BPL 	MVDLINE
          	JSR 	INCSCR0 
          	RTS 	
;
CRTTXTLIN  	JSR 	CLRCRTBUF 
          	LDA 	(SCRAT0),Y
          	STA 	FIRST
          	INY 	
          	LDA 	(SCRAT0),Y
          	STA 	FIRST+1
          	INY 	
          	LDA 	FORMAT
          	BEQ 	UNTILEOL
          	LDA 	(SCRAT0),Y
          	CMP 	#$3B
          	BEQ 	UNTILEOL
          	CMP 	#$20
          	BEQ 	MNEMFIELD
          	JSR 	ONEWORD
MNEMFIELD  	JSR 	TONXTWRD
          	LDX 	AUTOTAB
          	CMP 	#$3B			; ';'
          	BEQ 	UNTILEOL
          	JSR 	ONEWORD
          	JSR 	TONXTWRD
          	CMP 	#$3B			; ';'
          	BEQ 	COMMFIELD 
          	JSR 	ONEWORD
          	JSR 	TONXTWRD
          	CMP 	#$3B
          	BNE 	UNTILEOL
COMMFIELD   JSR 	XNXTTAB
UNTILEOL    JSR 	ONEWORD
          	JMP 	UNTILEOL
;			
TONXTWRD    LDA 	(SCRAT0),Y
          	INY 	
          	CMP 	#$20
          	BEQ 	TONXTWRD
          	DEY 	
          	RTS 
;
; 			
XNXTTAB    	INX 	
          	TXA 	
          	AND 	#$07
          	BNE 	XNXTTAB
          	RTS 	
;
ONEWORD    	CPX 	#$50
          	BCS 	SAVEEOLY
          	LDA 	(SCRAT0),Y
          	BMI 	EOLABORT 
          	CMP 	#$09			; TAB?
          	BEQ 	NXTTAB
          	STA 	CRT,X
          	INY 	
          	INX 	
          	CMP 	#$20
          	BNE 	ONEWORD
          	RTS 	
;			
EOLABORT   	AND 	#$7F
          	CMP 	#$09
          	BEQ 	SAVEEOLY
          	STA 	CRT,X
SAVEEOLY   	TXA 	
          	TAY 	
          	LDX 	#$00
          	PLA 	
          	PLA 	
          	RTS 	
;			
NXTTAB     	JSR 	XNXTTAB
          	INY 	
          	BNE 	ONEWORD
;			
          	INX 	
ERR.17     	INX 	
ERR.16    	INX 	
ERR.15     	INX 	
          	INX 	
          	INX 	
ERR.12    	INX 	
ERR.11     	INX 	
ERR.10     	INX 	
ERR.F     	INX 	
ERR.E    	INX 	
ERR.D     	INX 	
ERR.C    	INX 	
ERR.B     	INX 	
ERR.A     	INX 	
ERR.9     	INX 	
ERR.8     	INX 	
ERR.7    	INX 	
ERR.6     	INX 	
ERR.5     	INX 	
ERR.4     	INX 	
ERR.3     	INX 	
ERR.2     	INX 	
ERR.1     	INX 	
ERR.0     	TXA 	
          	PHA 	
          	LDX 	#$00
          	JSR 	INCERRORS
          	LDA 	PASS
          	BPL 	PRERRMSG
          	STA 	TERM
PRERRMSG   	LDA 	SUPPRESS0
          	STA 	DC
          	STX 	SUPPRESS0
          	LDA 	#$07				; bell
          	JSR 	OUTCHAR
          	JSR 	PRASLNER
          	JSR 	OUTCR
          	LDA 	#'!'
          	JSR 	OUTCHAR
          	PLA 	
          	JSR 	OUTBYTE
          	TYA 	
          	PHA 	
          	LDY 	#MESERROR-MESERROR
          	JSR 	MESSAGE
          	PLA 	
          	TAY 	
          	JSR 	PRSPFRST
          	LDA 	#'/'
          	JSR 	OUTCHAR
          	LDA 	HFILENO 
          	JSR 	OUTBYTE
          	JSR 	OUTCR
          	LDA 	TERM
          	BNE 	TERMINATE
          	LDA 	DC
          	STA 	SUPPRESS0
          	RTS 	
;
TERMINATE  	LDA 	#$FF
          	STA 	ERRORS
          	JMP 	MONL0OFF
;			
SR12SR0    	LDA 	SCRAT0
          	STA 	SCRAT1
          	LDA 	SCRAT0+1
          	STA 	SCRAT2
          	RTS 	
;			
SR12TPRES  	LDA 	TPRES
          	STA 	SCRAT1
          	LDA 	TPRES+1
          	STA 	SCRAT2
          	RTS 	
			
SR34TPRES  	LDA 	TPRES
          	STA 	SCRAT3
          	LDA 	TPRES+1
          	STA 	SCRAT4
          	RTS 	

SR0TXST    	LDA 	TXST
          	STA 	SCRAT0
          	LDA 	TXST+1
          	STA 	SCRAT0+1
          	RTS 	
			
SR0STST    	LDA 	STST
          	STA 	SCRAT0
          	LDA 	$STST+1
          	STA 	SCRAT0+1
          	RTS 	
			
INCSCR34   	INX 	
INCSCR12   	INX 	
INCSCR0    	INX 	
          	INX 	
INCREL     	INX 	
INCPC     	INX 	
INCSPRES   	INX 	
          	TXA 	
          	ASL 	A
          	TAX 	
          	INC 	TPRES,X
          	BNE 	INCOK
          	INC 	TPRES+1,X
INCOK     	LDX 	#$00
          	RTS 	
DECSCR34   	INX 	
DECSCR12   	INX 	
          	INX 	
          	INX 	
DECREL     	INX 	
          	INX 	
          	INX 	
          	TXA 	
          	ASL 	A
          	TAX 	
DECTPRES   	DEC 	TPRES,X
          	LDA 	TPRES,X
          	CMP 	#$FF
          	BNE 	DECOK
          	DEC 	TPRES+1,X
DECOK     	LDX 	#$00
          	RTS 	
;			
NXTWSK     	LDA 	CRT,Y
          	CMP 	#'!'
          	BEQ 	SKIP3
          	BNE 	NXTWORD
COMP     	LDA 	CRT,Y
          	CMP 	#'.'
          	BNE 	NXTWORD
SKIP3     	INY 	
          	INY 	
          	INY 	
NXTWORD    	JSR 	NXTSPACE 
NXTLETTER  	LDA 	CRT,Y
          	INY 	
          	CPY 	#$50
          	BCS 	RET1
          	CMP 	#' '
          	BEQ 	NXTLETTER
          	DEY 	
RET1     	RTS 
;	
NXTSPACE   	LDA 	CRT,Y
          	INY 	
          	CPY 	#$50
          	BCS 	RET2
          	CMP 	#$20
          	BNE 	NXTSPACE 
          	DEY 	
RET2     	RTS 	

MESSAGE    	LDA 	MESERROR,Y
          	BNE 	MESSDO
          	RTS 
			
MESSDO     	JSR 	OUTCHAR
          	INY 	
          	BNE 	MESSAGE
;
MESERROR 	.TEXT 	" AT LINE"
			.BYTE 	$00
MESLABS 	.BYTE 	$0D, $0A, $0A, $0A
			.TEXT	"LABEL FILE:  "
			.TEXT 	"[ / = EXTERNAL ]"
			.BYTE 	$0D, $0A, $0A, $00
MESPASS2 	.TEXT 	"READY FOR PASS 2"
			.BYTE 	$0D, $0A, $00
MESPAGE 	.TEXT 	"PAGE " 
			.BYTE	$00
MESCOLD 	.BYTE 	$0D, $0A 
			.TEXT	"C 1979 BY C. MOSER"
			.BYTE	$0D, $0A, $0D, $0A, $00
;			
PRCRT     	LDX 	#$00
PRCRTNXT   	TXA 	
PRCRT2    	PHA 	
          	LDA 	CRT,X
          	JSR 	OUTCHAR
          	PLA 	
          	TAX 	
          	INX 	
          	DEY 	
          	BPL 	PRCRTNXT
          	LDX 	#$00
          	RTS 
;			
INLINE     	STX 	SUPPRESS0
PROMPT     	LDA 	#'>'
          	JSR 	OUTCHAR
          	JSR 	CLRCRTBUF 
INCHALNE   	JSR 	INSAVXY
          	CMP 	#$0D			; CR
          	BNE 	TSTBS
GOTALINE   	INY 	
          	STY 	 ADDPAD
          	RTS 
;			
CURSBACK   	JSR 	OUTCHAR
TSTBS     	CMP 	#$08			; backspace?
          	BEQ 	CRTBACK
          	CMP 	#$7F
          	BNE 	TSTLINDEL 
          	LDA 	#$5C
          	JSR 	OUTCHAR
CRTBACK    	DEY 	
          	BMI 	LINEAGN
          	LDA 	#' '
          	STA 	CRT,Y
          	JMP 	INCHALNE
;			
LINEAGN 	JSR 	OUTCR
          	LDA 	AU
          	BEQ 	INLINE
          	JSR 	PRFIRST 
          	JMP 	PROMPT
;			
TSTLINDEL  	CMP 	#$18			; CTRL-X? Cancel?
          	BEQ 	LINEAGN
          	STA 	CRT,Y
          	CMP 	#$09			; tab?
          	BEQ 	PRTAB
          	INY 	
          	CPY 	#$50
          	BCC 	INCHALNE
          	LDA 	#$07			; bell
          	JSR 	OUTCHAR
TSTLNOVFL  	LDA 	#$08
          	BNE 	CURSBACK
          	BEQ 	PRCRT2			; 65c02?
PRTAB     	TYA 	
          	PHA 	
PRTABSP    	JSR 	OUTSP
          	INY 	
          	TYA 	
          	AND 	#$07
          	BNE 	PRTABSP
          	PLA 	
          	TAY 	
          	INY 	
          	JMP 	TSTLNOVFL		; 65c02 jumps to CPY#$50
;
CLRCRTBUF  	LDY 	#$55
          	LDA 	#' '
CLRCRTDO   	STA 	CRT,Y
          	DEY 	
          	BPL 	CLRCRTDO
          	INY 	
          	RTS 
;			
PRSPFRST   	JSR 	OUTSP
PRFIRST    	LDA 	FIRST+1
          	JSR 	OUTBYTE
          	LDA 	FIRST
          	JSR 	OUTBYTE
          	RTS 	
;			
PARM     	LDA 	#$00
          	STA 	TXST,X
          	STA 	TXST+1,X
          	STA 	SCRAT1
          	STA 	SCRAT2
PARMGET   	JSR 	GETCRTHX
          	BNE 	PARMNITST
          	LDX 	#$00
          	RTS 	
;			
PARMNITST  	PHA 	
          	LDA 	SCRAT1
          	BEQ 	PARMNIBOK 
          	LDA 	HEXDEC
          	BEQ 	PARMNIBOK 
          	LDX 	#$00
          	PLA 	
          	RTS 	
			
PARMNIBOK   INY 	
          	TYA 	
          	PHA 	
          	LDY 	#$04
PARMNIBIN  	ASL 	TXST,X
          	ROL 	TXST+1,X
          	DEY 	
          	BNE 	PARMNIBIN
          	PLA 	
          	TAY 	
          	PLA 	
          	ORA 	TXST,X
          	STA 	TXST,X
          	JMP 	PARMGET
;			
GETCRTHX   	JSR 	GETCRTUP
          	CMP 	#'0'
          	BCC 	NOTHEX
          	CMP 	#':'
          	BCC 	NUMHEX
          	CMP 	#'A'
          	BCC 	NOTHEX
          	CMP 	#'G'		
          	BCS 	NOTHEX		
          	AND 	#$0F
          	CLC 	
          	ADC 	#$09
          	INC 	SCRAT1
NUMHEX     	AND 	#$0F
          	INC 	SCRAT2
          	RTS 	
			
NOTHEX     	LDA 	#$00
          	RTS
;
;			
GETCRTUP   	LDA 	CRT,Y
UPPERCASE     	CMP 	#'a'
          	BCC 	NOTLOWER
          	CMP 	#'{'
          	BCS 	NOTLOWER
          	AND 	#SCRAT1
NOTLOWER   	RTS 
;	
SRCHCOM    	LDA 	#$00
          	BEQ 	STRTSRCH 
SRCHMNEM   	LDA 	#$01
          	BNE 	STRTSRCH 
SRCHMODS   	LDA 	#$FF
STRTSRCH   	STA 	SCRAT3
          	STY 	SCRAT4
CONTSRCH   	LDY 	SCRAT4
CMPNXT     	LDA 	SCRAT3
          	BEQ 	CMPCOM
          	BPL 	CMPMODS
          	LDA 	MNEMMODS,X
          	BNE 	COMPARE
          	RTS 
;			
CMPMODS    	LDA 	MNEMTABLE,X
          	BNE 	COMPARE
          	RTS 	
CMPCOM     	LDA 	COMTABLE,X
          	BNE 	COMPARE
          	RTS 
			
COMPARE     STA 	ADDPAD
          	JSR 	GETCRTUP
          	CMP 	ADDPAD
          	PHP 	
          	TYA 	
          	SEC 	
          	SBC 	SCRAT4
          	INY 	
          	INX 	
          	PLP 	
          	BEQ 	MATCH23
          	CMP 	#$01
          	BEQ 	FALSE2ND
          	CMP 	#$02
          	BEQ 	FALSE3TH
          	INX 	
FALSE2ND   	INX 	
FALSE3TH   	INX 	
          	LDA 	SCRAT3
          	BMI 	SKIPOPS
          	BNE 	CONTSRCH
          	JMP 	CONTSRCH
;			
SKIPOPS    	LDA 	MNEMMODS-1,X
          	AND 	#$0F
          	STX 	SCRAT2
          	SEC 	
          	ADC 	SCRAT2
          	TAX 	
          	JMP 	CONTSRCH
;			
MATCH23    	PHA 	
          	LDA 	SCRAT3
          	BNE 	MATCH3
          	PLA 	
          	CMP 	#$01
          	BNE 	CMPNXT
          	BEQ 	MATCHOK 
MATCH3     	PLA 	
          	CMP 	#$02
          	BNE 	CMPNXT
MATCHOK    	LDA 	SCRAT3
          	BEQ 	XPSEUCOM
          	STX 	PNTR
          	RTS 
;			
XPSEUCOM   LDA 		COMTABLE,X
          	STA 	SCRAT3
          	LDA 	COMTABLE+1,X
          	STA 	SCRAT4
          	PLA 	
          	PLA 	
          	CPX 	#PSEUTABLE-COMTABLE
          	BCS 	EXPSEU
          	JSR 	NXTWORD
          	JMP 	EXCOM
;			
EXPSEU     	JSR 	NXTLETTER
EXCOM     	LDX 	#$00
          	JMP 	(SCRAT3)
;
; Command table  
;			
COMTABLE  
			.TEXT "BR"
			.WORD  BREAK
			.TEXT "CL"
			.WORD  CLEAR
			.TEXT "PU"
			.WORD  PUT
			.TEXT "FO"
			.WORD  FORMAT1
			.TEXT "PR"
			.WORD  PRINTP
			.TEXT "AU"
			.WORD  AUTO
			.TEXT "AS"
			.WORD  ASSMBLE
			.TEXT "PA"
			.WORD  PASS1
			.TEXT "RU"
			.WORD  RUN
			.TEXT "MA"
			.WORD  MANUSCR
			.TEXT "OU"
			.WORD  OUTPUT
			.TEXT "ON"
			.WORD  ON
			.TEXT "OF"
			.WORD  OFF
			.TEXT "HA"
			.WORD  HARD
			.TEXT "GE"
			.WORD  GET1
			.TEXT "LA"
			.WORD  LABELS
			.TEXT "ED"
			.WORD  EDIT
			.TEXT "NU"
			.WORD  NUMBER
			.TEXT "DE"
			.WORD  DELETE
			.TEXT "FI"
			.WORD  FIND
			.TEXT "MO"
			.WORD  MOVE
			.TEXT "CO"
			.WORD  COPY
			.TEXT "SE"
			.WORD  SET
			.TEXT "US"
			.WORD USRVECTOR
			.TEXT "DU"
			.WORD  DUPLCT
			.TEXT "EN"
			.WORD  ENTER
			.TEXT "LO"
			.WORD  LOOKUP
			.TEXT "DC"
			.WORD  DISCCOM
;			
 			.BYTE 	$00, $00, $00, $00, $00
			.BYTE 	$00, $00, $00, $00, $00
			.BYTE 	$00
			
BRA1     	BNE 	BRA2
          	PLA 	
          	JMP 	BRA
;
BRA2     	PLA 	
          	JMP 	RANGEER
;			
PSEUTABLE 
			.TEXT 	"SI"
			.WORD 	SI
			.TEXT 	"BA"
			.WORD 	BA
			.TEXT 	"EN"
			.WORD 	EN
			.TEXT 	"BY"
			.WORD 	BY
			.TEXT 	"SE"
			.WORD 	SE
			.TEXT 	"DI"
			.WORD 	DI
			.TEXT 	"LS"
			.WORD 	LS
			.TEXT 	"LC"
			.WORD 	LC
			.TEXT 	"MC"
			.WORD 	MC
			.TEXT 	"OC"
			.WORD 	OC
			.TEXT 	"OS"
			.WORD 	OS
			.TEXT 	"CE"
			.WORD 	CE
			.TEXT 	"CT"
			.WORD 	CT
			.TEXT 	"RS"
			.WORD 	RS
			.TEXT 	"DE"
			.WORD 	DE
			.TEXT 	"RC"
			.WORD 	RC
			.TEXT 	"DS"
			.WORD 	DS
			.TEXT 	"ES"
			.WORD 	ES
			.TEXT 	"EC"
			.WORD 	EC
			.TEXT 	"EJ"
			.WORD 	EJ
			.TEXT 	"MD"
			.WORD 	MD
			.TEXT 	"ME"
			.WORD 	ME
			.TEXT 	"MG"
			.WORD 	MG
;
			.BYTE	$00, $00, $00, $00, $00
			.BYTE	$00, $00, $00, $00, $00
			.BYTE	$00, $00, $00, $00, $00
			.BYTE	$00, $00, $00, $00, $00
			.BYTE   $00	

;
MODACCU 	.TEXT 	"A "
			.WORD	ACCU
			.BYTE 	$00
;
MODIND 		.TEXT 	") "
			.WORD 	INDABS
			.BYTE 	$00
			
MNEMTABLE  	
			.TEXT 	"TAX" 
			.BYTE	$AA
			.TEXT "TAY" 
			.BYTE	$A8
			.TEXT "TSX" 
			.BYTE	$BA
			.TEXT "TXA" 
			.BYTE	$8A
			.TEXT "TXS" 
			.BYTE	$9A
			.TEXT "TYA" 
			.BYTE	$98
			.TEXT "CLC" 
			.BYTE	$18
			.TEXT "CLD" 
			.BYTE	$D8
			.TEXT "CLI" 
			.BYTE	$58
			.TEXT "CLV" 
			.BYTE	$B8
			.TEXT "SEC" 
			.BYTE	$38
			.TEXT "SED" 
			.BYTE	$F8
			.TEXT "SEI" 
			.BYTE	$78
 			.TEXT "NOP" 
			.BYTE	$EA
 			.TEXT "RTI" 
			.BYTE	$40
 			.TEXT "RTS" 
			.BYTE	$60
 			.TEXT "DEX" 
			.BYTE	$CA
 			.TEXT "DEY" 
			.BYTE	$88
 			.TEXT "INX" 
			.BYTE	$E8
 			.TEXT "INY" 
			.BYTE	$C8
 			.TEXT "PHA" 
			.BYTE	$48
 			.TEXT "PHP" 
			.BYTE	$08
 			.TEXT "PLA" 
			.BYTE	$68
 			.TEXT "PLP" 
			.BYTE	$28
 			.TEXT "BRK" 
			.BYTE	$00		
;
			.BYTE 	$00 
;			
MNEMBRA 
			.TEXT  "BCC" 
			.BYTE 	$90
			.TEXT  "BCS" 
			.BYTE 	$B0
			.TEXT  "BEQ" 
			.BYTE 	$F0
			.TEXT  "BMI" 
			.BYTE 	$30
			.TEXT  "BNE" 
			.BYTE 	$D0
			.TEXT  "BPL" 
			.BYTE 	$10
			.TEXT  "BVC" 
			.BYTE 	$50
			.TEXT  "BVS" 
			.BYTE 	$70
			
			.BYTE $00			
;		
MNEMMODS  	.TEXT  "ROR" 
			.BYTE	%11000000+5 
			.BYTE	%11000001
 			.BYTE  $6E,$7E,$66,$76,$6A
;			
 			.TEXT  "ADC" 
			.BYTE  %11100000+8
			.BYTE  %11011010
 			.BYTE $6D, $7D, $79, $65,  $75,  $71, $61 , $69
;			
 			.TEXT  "AND" 
			.BYTE  %11100000+8 
			.BYTE  %11011010
 			.BYTE $2D , $3D , $39 , $25 , $35 , $31 , $21 , $29
;			
 			.TEXT  "ASL" 
			.BYTE  %11000000+5 
			.BYTE  %11000001
 			.BYTE $0E , $1E , $06 , $16 , $0A
;			
 			.TEXT  "BIT" 
			.BYTE  %10000000+2 
			.BYTE  %10000000
 			.BYTE $2C , $24
;			
 			.TEXT  "CMP" 
			.BYTE  %11100000+8 
			.BYTE  %11011010
 			.BYTE $CD , $DD ,$D9 , $C5 , $D5 , $D1 , $C1 , $C9
;			
 			.TEXT  "CPX" 
			.BYTE  %10000000+3 
			.BYTE  %10000010
 			.BYTE $EC , $E4 , $E0
;			
 			.TEXT  "CPY" 
			.BYTE  %10000000+3 
			.BYTE  %10000010
 			.BYTE $CC , $C4 , $C0
;			
 			.TEXT  "DEC" 
			.BYTE  %11000000+4 
			.BYTE  %11000000
 			.BYTE $CE , $DE , $C6 , $D6
;			
 			.TEXT  "EOR" 
			.BYTE  %11100000+8 
			.BYTE  %11011010
 			.BYTE $4D , $5D , $59 , $45 , $55 , $51 , $41 , $49
;			
 			.TEXT  "INC" 
			.BYTE  %11000000+4 
			.BYTE  %11000000
 			.BYTE  $EE , $FE , $E6 , $F6
;			
 			.TEXT  "JMP" 
			.BYTE  %10010000+2 
			.BYTE  %00000000
 			.BYTE  $4C , $6C
;			
 			.TEXT  "LDA" 
			.BYTE  %11100000+8 
			.BYTE  %11011010
			.BYTE  $AD , $BD , $B9 , $A5 , $B5 , $B1 , $A1 , $A9
;
; 			.BYTE  $AE , $BE , $A6 , $B6 , $A2						;65C02?
;			
			.TEXT 	"LDX"
			.BYTE	%10100000+5 
			.BYTE	%10100010
			.BYTE 	$AE, CALLEXP, $A6, $B6, $A2
;
 			.TEXT  "LDY" 
			.BYTE  %11000000+5 
			.BYTE  %11000010
 			.BYTE  $AC, $BC, $A4, $B4, $A0
;			
 			.TEXT  "LSR" 
			.BYTE  %11000000+4 
			.BYTE  %11000001
 			.BYTE  $4E , $5E , $46 , $56
;			
 			.TEXT  "JSR" 
			.BYTE  %10000000+1 
			.BYTE  %00000000
 			.BYTE  $20
;			
 			.TEXT  "ORA" 
			.BYTE  %11100000+8 
			.BYTE  %11011010
 			.BYTE  $0D , $1D , $19 , $05 , $15 , $11 , $01 , $09
;			
 			.TEXT  "ROL" 
			.BYTE  %11000000+5 
			.BYTE  %11000001
 			.BYTE  $2E , $3E , $26 , $36 , $2A
;			
 			.TEXT  "SBC" 
			.BYTE  %11100000+8 
			.BYTE  %11011010
 			.BYTE  $ED , $FD , $F9 , $E5 , $F5 , $F1 , $E1 , $E9
;			
 			.TEXT  "STA" 
			.BYTE  %11100000+7 
			.BYTE  %11011000
 			.BYTE  $8D , $9D , $99 , $85 , $95 , $91 , $81
;			
 			.TEXT  "STX" 
			.BYTE  %10000000+3 
			.BYTE  %10100000
 			.BYTE  $8E , $86 , $96
;			
 			.TEXT  "STY" 
			.BYTE  %10000000+3 
			.BYTE  %11000000
 			.BYTE  $8C , $84 , $94
;			
 			.BYTE $00
 			
;	
MG      	INC 	MGFLAG
          	JMP 	ASGOON
;			
DS         	LDA 	TLIST
          	BEQ 	BLOCKSIZE
          	LDA 	PASS
          	CMP 	#$01
          	BNE 	BLOCKSIZE
          	LDA 	MACEXPAND
          	BNE 	BLOCKSIZE
          	JSR 	PRPC
          	LDA 	#$05
          	STA 	LNINDEX
BLOCKSIZE  	JSR 	OPERTST
          	LDA 	ADDPAD
          	BEQ 	EXDS
          	STY 	TERM
          	JMP 	ERR.4			;OPERAND UNDEFINED 
;			
EXDS     	LDA 	PROCADDRS
          	CLC 	
          	ADC 	PC
          	STA 	PC
          	LDA 	PROCADDRS+1
          	ADC 	PC+1
          	STA 	PC+1
          	LDA 	PROCADDRS
          	CLC 	
          	ADC 	REL
          	STA 	REL
          	LDA 	PROCADDRS+1
          	ADC 	REL+1
          	STA 	REL+1
          	LDA 	PASS
          	BPL 	ASGOON1
          	LDA 	#$7F
          	INC 	HEXDEC
          	JSR 	STPROB
          	LDA 	PROCADDRS
          	INC 	HEXDEC
          	JSR 	STPROB
          	LDA 	PROCADDRS+1
          	INC 	HEXDEC
          	JSR 	STPROB
ASGOON1    	JMP 	ASGOON

EJ         	LDA 	PASS
          	BEQ 	ASGOON2 
          	BMI 	ASGOON2 
          	LDA 	TLIST
          	BEQ 	ASGOON2 
          	LDA 	PRINTCTL
          	BEQ 	ASGOON2 
          	JSR 	HAPAGE 
ASGOON2    	JMP 	ASGOON

RS         	LDA 	#$5F
          	JMP 	P3RDIR
;			
CE         	STX 	TERM
          	BEQ 	ASGOON3
;			
OS         	STY 	OSTORE
          	BEQ 	ASGOON3
;			
OC         	STX 	OSTORE
          	BEQ 	ASGOON3
;			
CT         	STY 	CONTAPE
          	BEQ 	ASGOON3
;			
LS         	STY 	TLIST
          	BEQ 	ASGOON3
;			
LC         	STX 	TLIST
ASGOON3    	JMP 	ASGOON

SI         	JSR 	OPERTST
          	INC 	EXT
          	JMP 	SEILOW 

SE         	JSR 	OPERTST
          	LDX 	#$00
          	STX 	EXT
          	JMP 	SEILOW 
			
BA         	LDA 	SCRAT0
          	PHA 	
          	LDA 	SCRAT0+1
          	PHA 	
          	JSR 	OPERTST
          	LDA  	ADDPAD
          	BEQ 	EXBA
          	STY 	TERM
          	JMP 	ERR.4
			
EXBA     	PLA 	
          	STA 	SCRAT0+1
          	PLA 	
          	STA 	SCRAT0
          	LDA 	PROCADDRS
          	STA 	PC
          	STA 	REL
          	LDA 	PROCADDRS+1
          	STA 	PC+1
          	STA 	REL+1
          	LDA 	CRT
          	CMP 	#' '
          	BEQ 	BAP3
          	LDA 	PASS
          	BNE 	BAP3
          	JSR 	CHNGEVALUE
BAP3     	LDA 	PASS
          	BPL 	ASGOON4
          	JSR 	PUTRBUFR 
ASGOON4    	JMP 	ASGOON
;
MC         	LDA 	TERM
          	PHA 	
          	STY 	TERM
          	JSR 	OPERTST
          	PLA 	
          	STA 	TERM
          	LDA 	PROCADDRS
          	STA 	REL
          	LDA 	PROCADDRS+1
          	STA 	REL+1
          	JMP 	ASGOON
;			
BYOPER     	JSR 	OPERTST
          	LDA 	PROCADDRS
          	JSR 	BYSTORE 
BYDONE     	JSR 	NXTLETTER
          	CPY 	#$50
          	BCS 	ASGOON4
          	BCC 	BYOPRS
;			
BY         	CPY 	#$50
          	BCC 	BYOPRS
OPER      	JSR 	ERR.A
          	JMP 	ASGOON
;
BYOPRS     	CMP 	#$3B			; ';'
          	BEQ 	ASGOON4
          	CMP 	#$27			; '
          	BNE 	BYOPER
BYSTRING   	INY 	
          	CPY 	#$50
          	BCS 	OPER 
          	LDA 	CRT,Y
          	CMP 	#$27			; '
          	BNE 	BYNXTCH
          	INY 	
          	BNE 	BYDONE
;
BYNXTCH    	JSR 	BYSTORE 
          	CLV 	
          	BVC 	BYSTRING
;			
BYSTORE    	PHA 	
          	LDA 	PASS
          	BPL 	BYSTDAT
          	LDA 	#$3F
          	INC 	HEXDEC
          	JSR 	STPROB
BYSTDAT    	PLA 	
          	JSR 	STPROB
          	RTS 
;			
DI         	JSR 	DEFLAB
          	JSR 	CHNGEVALUE
          	JMP 	ASGOON
;			
DE         	JSR 	DEFLAB
          	BNE 	EXTMARKED
          	LDY 	#$01
MARKEXT    	INY 	
          	LDA 	(SAVE),Y
          	BPL 	MARKEXT
INSERT     	LDA 	(SAVE),Y
          	INY 	
          	STA 	(SAVE),Y
          	DEY 	
          	DEY 	
          	CPY 	#$01
          	BNE 	INSERT
          	INY 	
          	LDA 	#$2F
          	STA 	(SAVE),Y
          	JSR 	INCSPRES
          	JSR 	STEND0
EXTMARKED  	JSR 	CHNGEVALUE
          	JMP 	ASGOON
;			
DEFLAB     	JSR 	OPERTST
          	LDA 	CRT
          	CMP 	#$20
          	BNE 	LABWHERE
          	JSR 	ERR.5
          	JMP 	ASGOON
;			
LABWHERE   	LDY 	#$00
          	JSR 	EVLABEX 
          	LDA 	SCRAT0
          	STA 	SAVE
          	LDA 	SCRAT0+1
          	STA 	SAVE+1
          	LDA 	PASS
          	BEQ 	RETZIFP1
          	STX 	EXT
          	LDA 	#$FF
RETZIFP1   	RTS 
	
CHNGEVALUE 	LDY 	#$00
          	LDA 	PROCADDRS
          	STA 	(SAVE),Y
          	INY 	
          	LDA 	PROCADDRS+1
          	STA 	(SAVE),Y
          	RTS 
;			
EN         	JSR 	PRASLIN 
          	LDA 	MACEXPAND
          	BNE 	MACEXPEN
          	LDA 	CONDSUP
          	BNE 	CONSUPEN
          	LDA 	MACSUPPRS
          	BNE 	MACDEFEN
          	BEQ 	EXEN
;
MACEXPEN   	LDX 	#$21
          	BNE 	ERR01				;MACRO IN EXP STATE AT .EN 
;			
CONSUPEN   	LDX 	#$22
          	BNE 	ERR01
;
MACDEFEN   	LDX 	#$23
ERR01     	JSR 	ERR.0				;MACRO DEF INCOMPLETE AT .EN 
EXEN     	LDA 	PASS
          	BEQ 	STRTPASS2
          	BMI 	ENPASS3
          	LDA 	TLIST
          	JMP 	ENPASS2
;
ENPASS3    	JSR 	PUTRBUFR 
          	JMP 	MONL0OFF
;
STRTPASS2  	INC 	PASS
          	LDA 	CONTAPE
          	BEQ 	ASAUTOP2
          	JSR 	TD0OFW
          	LDY 	#$2E
          	JSR 	MESSAGE
          	JMP 	MONL0OFF
;			
OUTPUT     	STX 	RECPOINT
          	JSR 	GETFILNO
          	STX 	HEXDEC
          	LDX 	#$FF
          	STX 	PASS
          	STX 	LAST
ASAUTOP2   	LDA 	ASLNSV
          	STA 	FIRST
          	LDA 	ASLNSV+1
          	STA 	FIRST+1
          	JSR 	FINDLNGE
ASSEMBLE   	LDX 	#$00
          	STX 	LN2BOUT
          	STX 	ERRORS+1
          	STX 	ERRORS
          	LDX 	#$FF
          	TXS 	
          	INX 	
          	STX 	OSTORE
          	STX 	MGFLAG
          	LDA 	TXST
          	STA 	MGADDR
          	LDA 	TXST+1
          	STA 	MGADDR+1
          	LDA 	#$01
          	STA 	FILESEQ
          	STX 	FILESEQ+1
          	STX 	MACSEQ
          	STX 	MACSEQ+1
          	STX 	MACSUPPRS
          	STX 	MACEXPAND
          	STX 	CONDSUP
          	STX 	LSTEXPOB 
          	LDA 	#$00
          	STA 	PC
          	STA 	REL
          	LDA 	#$02
          	STA 	PC+1
          	STA 	REL+1
          	LDA 	PASS
          	BPL 	ASNEW
          	JSR 	RESETRBUF
          	JMP 	ASNEW
;			
ASGOON     	LDX 	#$00
          	PLA 	
          	STA 	SCRAT0
          	PLA 	
          	STA 	SCRAT0+1
          	JSR 	NXTLILA
ASNEW     	LDA 	SCRAT0+1
          	PHA 	
          	LDA 	SCRAT0
          	PHA 	
          	STX 	EXT
          	JSR 	GETFRSTCH
          	BNE 	ASLINE
          	LDA 	MACSUPPRS
          	BEQ 	INCFILSEQ
          	LDX 	#$27
          	JSR 	ERR.0				;MACRO DEF OVERLAPS FILE-BOUND 
INCFILSEQ  	INC 	FILESEQ
          	BNE 	TSTCTAPE
          	INC 	$C5
          	BNE 	TSTCTAPE
          	LDX 	#$2F
          	JSR 	ERR.0				;OVRFLW IN FILE SEQ COUNT 
TSTCTAPE   	LDA 	CONTAPE
          	BNE 	NXTFILE
          	LDA 	#$01
          	STA 	TERM
          	JMP 	ERR.7
;			
NXTFILE    	JSR 	PRASLIN 
          	JSR 	OUTCR
          	JSR 	OUTCR
          	JSR 	OUTCR
          	LDA 	MGFLAG
          	BEQ 	NOMG 
          	LDA 	TPRES
          	STA 	MGADDR
          	LDA 	TPRES+1
          	STA 	MGADDR+1
NOMG      	LDA 	#$00
          	STA 	MGFLAG
          	LDA 	MGADDR
          	STA 	TPRES
          	LDA 	MGADDR+1
          	STA 	TPRES+1
          	STX 	FILENO
          	JSR 	GSA
          	LDA 	#$00
          	STA 	HEXDEC
          	LDA 	ASLNSV
          	STA 	FIRST
          	LDA 	ASLNSV+1
          	STA 	FIRST+1
          	LDA 	MGADDR
          	STA 	SCRAT0
          	LDA 	MGADDR+1
          	STA 	SCRAT0+1
          	LDX 	#$FF
          	TXS 	
          	INX 	
          	JMP 	ASNEW
;			
ASLINE     	LDX 	#$00
          	LDA 	TLIST
          	BEQ 	TERMNTYET 
          	JSR 	PRASLIN 
          	LDA 	PASS
          	CMP 	#$01
          	BNE 	TERMNTYET 
          	LDA 	MACEXPAND
          	BEQ 	TERMLLINE
          	LDA 	LSTEXPOB
          	BEQ 	TERMNTYET 
TERMLLINE   JSR 	OUTCR
TERMNTYET  	JSR 	CRTTXTLIN
          	STY 	LINELEN 
          	INC 	LN2BOUT
          	LDY 	#$00
          	LDA 	CRT,Y
          	CMP 	#$3B				; ';'
          	BEQ 	MACRINP
          	JSR 	NXTWORD
MACRINP    	STX 	MACSRCH
          	LDA 	MACSUPPRS
          	BEQ 	ASSUPR
          	LDX 	#$24
          	JSR 	SRCHAT 
          	JMP 	ASGOON
;			
ASSUPR     	LDA 	CONDSUP
          	BEQ 	CMNTONLY
          	LDX 	#$19
          	JSR 	SRCHAT 
          	JMP 	ASGOON
;			
CMNTONLY    LDY 	#$00
          	LDA 	CRT,Y
          	CMP 	#$3B
          	BNE 	NEWLAB
ASGOON5    	JMP 	ASGOON

NEWLAB     	CMP 	#$20
          	BEQ 	NONEWLAB
          	LDA 	PASS
          	BNE 	NONEWLAB
          	JSR 	NEWLABEL 
NONEWLAB   	JSR 	NXTWSK
          	LDA 	CRT,Y
          	CMP 	#$3B				; '
          	BEQ 	ASGOON5
          	CPY 	#$50
          	BCS 	ASGOON5
          	CMP 	#'.'				
          	BNE 	MNEM
          	INY 	
          	LDA 	CRT+2,Y
          	CMP 	#$20
          	BEQ 	FIEXPSEU
PSEUER     	JSR 	ERR.3
          	JMP 	ASGOON
FIEXPSEU   	LDX 	#$85
          	JSR 	SRCHCOM 
          	LDX 	#$00
          	JMP 	PSEUER
			
MNEM     	LDA 	CRT+3,Y
          	CMP 	#$20
          	BNE 	IFPSEU
          	JSR 	SRCHMNEM
          	BEQ 	BRA0
          	LDA 	MNEMTABLE,X
LASTOB     	JSR 	STPROB
          	JMP 	ASGOON
			
BRA0     	LDX 	#$65
          	JSR 	SRCHMNEM
          	BEQ 	MOD
          	LDA 	MNEMTABLE,X
          	JSR 	STPROB
          	JSR 	NXTWORD
          	LDA 	PASS
          	BEQ 	LASTOB1
          	JSR 	OPERTST
          	CLC 	
          	LDA 	PROCADDRS
          	SBC 	PC
          	PHA 	
          	LDA 	PROCADDRS+1
          	SBC 	PC+1
          	BNE 	BRA11
          	PLA 	
          	CMP 	#$80
          	BCC 	LASTOB1
RANGEER    	JSR 	ERR.1
          	JMP 	LASTOB
;			
BRA11     	CMP 	#$FF
          	JMP 	BRA1
			
BRA     	CMP 	#$80
          	BCC 	RANGEER
LASTOB1    	JMP 	LASTOB
;
MOD     	LDX 	#$00
          	JSR 	SRCHMODS
          	BNE 	WHICHMODE
IFPSEU     	JMP 	IFPSEU1
;
WHICHMODE  	JSR 	NXTLETTER
          	LDA 	CRT,Y
          	CMP 	#$23			; '
          	BNE 	ACCU1
          	LDX 	#$0B
          	JSR 	FETCHOP
          	LDX 	#$55
          	JSR 	SRCHAT 
          	INY 	
          	LDA 	CRT,Y
          	CMP 	#$27
          	BNE 	IMMLABEX 
          	LDA 	CRT+1,Y
          	JMP 	LASTOB
;			
IMMLABEX   	LDX 	#$00
          	JSR 	OPERTST
          	LDA 	PROCADDRS
          	JMP 	LASTOB
;			
IMMLABL    	JSR 	OPERTST
          	LDA 	PROCADDRS
          	JSR 	STPROB
          	LDA 	EXT
          	BEQ 	ASGOON6
          	LDA 	#$1F
          	BNE 	P3RDIR
			
IMMLABH    	JSR 	OPERTST
          	LDA 	PROCADDRS+1
          	JSR 	STPROB
          	LDA 	EXT
          	BEQ 	ASGOON6
          	LDA 	#$2F
P3RDIR     	PHA 	
          	LDA 	PASS
          	BPL 	NOTP3
          	PLA 	
          	INC 	HEXDEC
          	PHA 	
          	JSR 	STPROB
          	PLA 	
          	CMP 	#$2F				;
          	BEQ 	P3LALSO 
ASGOON6    	JMP 	ASGOON
;
NOTP3     	PLA 	
          	JMP 	ASGOON
P3LALSO    	LDA 	PROCADDRS
          	INC 	HEXDEC
          	JMP 	LASTOB
;
EXTP3     	JSR 	STPROB
          	LDA 	EXT
          	BNE 	ASGOON6
          	LDA 	#$0F
          	JMP 	P3RDIR
;			
ACCU       	LDX 	#$0C
          	JSR 	FETCHOP
          	JMP 	ASGOON
;			
ACCU1     	LDX 	#MODACCU-COMTABLE
          	JSR 	SRCHCOM 
          	TAX 	
          	LDA 	CRT,Y
          	CMP 	#$2A
          	BNE 	INDIR
          	INY 	
          	JSR 	GETOPER
          	BEQ 	ZEROPG
          	LDX 	#ATZXY-ATCOND				
          	BNE 	ABSINDX
;			
INDIR     	CMP 	#'('
          	BNE 	ABS1
          	INY 	
          	JSR 	GETOPER
          	LDX 	#MODIND-COMTABLE
          	JSR 	SRCHCOM 
          	LDX 	#ATINDXY-ATCOND				
          	BNE 	ABSINDX
          	BNE 	ABSINDX
			
ABS1     	JSR 	GETOPER
          	BEQ 	ABS
          	LDX 	#ATAXY-ATCOND
ABSINDX   	JSR 	SRCHAT 
          	TAX 	
          	JMP 	OPER 
;			
INDABS     	INX 	
ABSY       	INX 	
ABSX     	INX 	
ABS     	INX 	
          	JSR 	FETCHOP
STPRLOPR   	LDA 	PROCADDRS
          	JSR 	STPROB
          	LDA 	PROCADDRS+1
          	JMP 	EXTP3
;			
INDX       	INX 	
INDY       	INX 	
ZEROY      	INX 	
ZEROX      	INX 	
ZEROPG     	INX 	
          	INX 	
          	INX 	
          	INX 	
          	INX 	
          	JSR 	FETCHOP
          	LDA 	PROCADDRS
          	JSR 	STPROB
          	LDA 	PROCADDRS+1
          	BEQ 	ASGOOND
          	LDX 	#$00
          	LDA 	PASS
          	BEQ 	ASGOOND
          	JSR 	ERR.0
ASGOOND    	JMP 	ASGOON

FETCHOP    	STX 	SCRAT0
          	LDX 	PNTR
          	LDA 	MNEMMODS+1,X
          	STA 	SCRAT0+1
          	LDA 	#$04
          	STA 	SCRAT1
          	LDA 	MNEMMODS,X
NXTA     	DEC 	SCRAT1
          	BMI 	TRYZOPS
          	ASL 	A
          	BCC 	DONTSKA
          	INX 	
DONTSKA    	DEC 	SCRAT0
          	BNE 	NXTA
          	BCS 	FETCHIT
MODEER     	LDX 	#$00
          	JSR 	ERR.B			;  ;UNIMPLEMENTED ADDR MODE
          	RTS 	
			
TRYZOPS    	LDA 	SCRAT0+1
NXTZOP     	ASL 	A
          	BCC 	DONTSKZ
          	INX 	
DONTSKZ    	DEC 	SCRAT0
          	BNE 	NXTZOP 
          	BCC 	MODEER
FETCHIT    	LDA 	MNEMMODS+1,X
STPROB     	PHA 	
          	LDX 	#$00
          	LDA 	PASS
          	BEQ 	SKIPSTOR
          	BMI 	P3STORE 
          	LDA 	TLIST
          	BEQ 	STOBJBYT
          	LDA 	MACEXPAND
          	BEQ 	PROB
          	LDA 	LSTEXPOB
          	BEQ 	STOBJBYT
PROB     	LDA 	LNINDEX 
          	BNE 	PROBNL
PR1EOB     	LDA 	#$05
          	STA 	LNINDEX 
          	JSR 	PRPC
PROBNL     	LDA 	LNINDEX 
          	CMP 	#$0E
          	BNE 	PROBJBYT
          	JSR 	PRASLIN 
          	JSR 	OUTCR
          	JMP 	PR1EOB
			
PROBJBYT   	JSR 	OUTSP
          	LDA 	LNINDEX
          	CLC 	
          	ADC 	#$03
          	STA 	LNINDEX
          	PLA 	
          	PHA 	
          	JSR 	OUTBYTE
STOBJBYT   	LDA 	OSTORE
          	BEQ 	SKIPSTOR
          	PLA 	
          	STA 	(REL,X)
INCPCREL   	JSR 	INCPC
          	JSR 	INCREL
          	RTS 	
			
PRPC     	LDA 	$PC+1
          	JSR 	OUTBYTE
          	LDA 	PC
          	JSR 	OUTBYTE
          	LDA 	#'-'			; 
          	JSR 	OUTCHAR
          	RTS 	
			
SKIPSTOR    PLA 	
          	CLV 	
          	BVC 	INCPCREL 
;			
P3STORE     PLA 	
          	JSR 	STINRBUF
          	LDA 	HEXDEC
          	BNE 	RDIRSTRD
          	JSR 	INCPC
          	JMP 	RBUFULL
;
RDIRSTRD   	DEC 	HEXDEC
RBUFULL    	LDA 	RECPOINT
          	CMP 	#$FF
          	BCS 	PUTRBUFR 
          	RTS 
;			
PUTRBUFR    JSR 	PUTRBUF
RESETRBUF   STX 	RECPOINT
          	LDA 	PC
          	JSR 	STINRBUF
          	LDA 	PC+1
          	JSR 	STINRBUF
          	RTS 
	
ENPASS2    	BEQ 	NOLA
LABELS     	JSR 	EXLA
NOLA     	JSR 	CLRSPR
          	JSR 	PRERRORS
          	JSR 	PRPCREL
          	JMP 	MONLOOP
			
PRERRORS   	LDA 	ERRORS+1
          	JSR 	OUTBYTE
          	LDA 	ERRORS
          	JMP 	OUTBYTE
;			
PRPCREL    	LDA 	#','
          	JSR 	OUTCHAR
          	LDA 	PC+1 
          	JSR 	OUTBYTE
          	LDA 	PC
          	JSR 	OUTBYTE
          	LDA 	#','
          	JSR 	OUTCHAR
          	LDA 	REL+1
          	JSR 	OUTBYTE
          	LDA 	REL
          	JMP 	OUTBYTE
			
SPRESSTST   LDA 	STST
          	STA 	SPRES
          	LDA 	STST+1 
          	STA 	SPRES+1
          	RTS 	
;			
PRASLNER   	TYA 	
          	PHA 	
          	JMP 	PRSUPR
;			
PRASLIN    	TYA 	
          	PHA 	
          	LDA 	PASS
          	CMP 	#$01
          	BNE 	ASLNPRNTD
          	LDA 	TLIST
          	BEQ 	ASLNPRNTD
PRSUPR     	LDA 	LN2BOUT
          	BEQ 	ASLNPRNTD
          	LDY 	LNINDEX
          	LDA 	MACEXPAND
          	BNE 	ASLNPRNTD
TO16     	INY 	
          	JSR 	OUTSP
          	CPY 	#$10
          	BCC 	TO16
          	LDY 	LINELEN 
          	JSR 	PRFIRST 
          	JSR 	OUTSP
          	JSR 	PRCRT
ASLNPRNTD   STX 	LNINDEX
          	PLA 	
          	TAY 	
          	STX 	LN2BOUT
          	RTS 	
;			
NEWLABEL   	LDA 	SPRES
          	STA 	SAVEM
          	LDA 	SPRES+1
          	STA 	SAVEM+1
          	LDA 	MACEXPAND
          	BEQ 	NLMDEF
          	JSR 	MACDEF
          	BNE 	NLMLAB
          	CLC 	
          	RTS 	
;
NLMLAB    	JSR 	MACLAB
          	BNE 	NLNORM
          	JSR 	SETMSEQ
          	JMP 	NLSTSEQ
			
NLMDEF     	JSR 	MACDEF
          	BNE 	NLNORM
          	JSR 	PRASLIN 
          	LDA 	#$00
          	STA 	CRT+1,Y
          	STA 	CRT+2,Y
          	LDA 	MGFLAG
          	BNE 	NLSTSEQ
          	JSR 	SETFSEQ 
NLSTSEQ    	STY 	SAVEY
          	JSR 	STLABADR
          	LDX 	SAVEY
          	JSR 	STLABCH
          	JSR 	STLABCH
          	JSR 	STLABCH
          	JMP 	NLSTLAB
;			
NLNORM     	STY 	SAVEY
          	JSR 	STLABADR
          	LDX 	SAVEY
NLSTLAB    	LDA 	CRT,X
          	CMP 	#'@'
          	BCC 	NLILLCH
NLCHAR1    	JSR 	STLABCH
          	LDA 	CRT,X
          	CMP 	#$20
          	BEQ 	NLLAST
          	LDA 	MACEXPAND
          	BEQ 	NLNXTCH
          	LDA 	CRT,X
          	CMP 	#')'
          	BEQ 	NLLAST
NLNXTCH    	LDA 	CRT,X
          	JSR 	TSTLABCH
          	BCC 	NLCHAR1 
NLILLCH   	JSR 	STEND0
          	LDX 	#$00
          	JSR 	ERR.C				;ILLEGAL CHAR IN LABEL
          	SEC 	
          	RTS 
;	
NLLAST     	LDA 	(SPRES),Y
          	ORA 	#$80
          	STA 	(SPRES),Y
          	SEC 	
          	TYA 	
          	ADC 	SPRES
          	STA 	SPRES
          	LDX 	#$00
          	TXA 	
          	ADC 	SPRES+1
          	STA 	SPRES+1
          	CMP 	STEN+1
          	BEQ 	SOVFLW
          	BCS 	SOVFLW1				; 65C02 SOVFLW 
NLDUP     	JSR 	STEND0
          	LDY 	SAVEY
          	JSR 	EVLABEX 
          	LDA 	SCRAT0+1
          	PHA 	
          	LDA 	SCRAT0
          	PHA 	
          	JSR 	NXTLABSK 
          	JSR 	GETFRSTCH
          	BEQ 	NLOK 
          	PLA 	
          	STA 	SCRAT0
          	PLA 	
          	STA 	SCRAT0+1
          	JSR 	ERR.6				;DULPLICATE LABEL 
          	JMP 	OLDSPRES
			
NLOK      	PLA 	
          	STA 	SCRAT0
          	PLA 	
          	STA 	SCRAT0+1
          	LDY 	SAVEY
          	CLC 	
          	RTS 
			
SOVFLW     	LDA 	SPRES
          	CMP 	STEN
          	BCC 	NLDUP
SOVFLW1    	JSR 	ERR.E
OLDSPRES   	LDA 	$B9
          	STA 	SPRES
          	LDA 	$BA
          	STA 	SPRES+1
          	JSR 	STEND0
          	LDY 	SAVEY
          	SEC 	
          	RTS 
;			
STEND0     	LDA 	#$00
          	LDY 	#$02
          	STA 	(SPRES),Y
          	RTS 	
;			
MACDEF     	LDA 	CRT,Y
          	CMP 	#'!'
MACCMP23   	BNE 	RETM 
          	CMP 	CRT+1,Y
          	BNE 	RETM 
          	CMP 	CRT+2,Y

RETM      	RTS 	
MACLAB     	LDA 	CRT,Y
          	CMP 	#$2E
          	JMP 	MACCMP23
;
SETFSEQ    	LDA 	FILESEQ
          	STA 	CRT+1,Y
          	LDA 	FILESEQ+1
          	STA 	CRT+2,Y
          	RTS 	
;
SETMSEQ     LDA 	MACSEQ
          	STA 	CRT+1,Y
          	LDA 	MACSEQ+1
          	STA 	CRT+2,Y
          	RTS 	
;
STLABADR  	LDY 	#$00
          	LDA 	PC
          	STA 	(SPRES),Y
          	LDA 	PC+1
          	INY 	
          	STA 	(SPRES),Y
          	RTS 	
;
STLABCH    	LDA 	CRT,X
          	INY 	
          	STA 	(SPRES),Y
          	INX 	
          	RTS 	
;
NXTLABSK   	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	CMP 	#'.'
          	BEQ 	SKIPSEQ
          	CMP 	#'!'
          	BNE 	NOSEQ 
SKIPSEQ    	JSR 	INCSCR0 
          	JSR 	INCSCR0 
          	JSR 	INCSCR0 
NOSEQ      	JSR 	NXTLILA
          	RTS 	
;
GETOPER    	STX 	EXT
          	CPY 	#$50
          	BCC 	GETOPRDO
          	JSR 	ERR.A
          	RTS 
;			
GETOPRDO   	STX 	PROCADDRS
          	STX 	PROCADDRS+1
          	STX 	ADDPAD
          	JMP 	ADDGET
;			
GOTIT     	LDA 	CRT,Y
          	CMP 	#'+'
          	BEQ 	ADD
          	CMP 	#'-'
          	BEQ 	SUBTR
          	CMP 	#$20
          	RTS 	
;			
ADD     	INY 	
ADDGET     	JSR 	EVLABEX 
          	BCS 	ADDDO 
          	INC 	ADDPAD
ADDDO    	CLC 	
          	LDA 	ADDRS
          	ADC 	PROCADDRS
          	STA 	PROCADDRS
          	LDA 	ADDRS+1
          	ADC 	PROCADDRS+1
          	STA 	PROCADDRS+1
          	JMP 	GOTIT
;
SUBTR     	INY  	
          	JSR 	EVLABEX 
          	BCS 	SUBTRDO
          	INC 	 ADDPAD
SUBTRDO    	SEC 	
          	LDA 	PROCADDRS
          	SBC 	ADDRS
          	STA 	PROCADDRS
          	LDA 	PROCADDRS+1
          	SBC 	ADDRS+1
          	STA 	PROCADDRS+1
          	JMP 	GOTIT
;
EVLABEX    	JSR 	SR0STST
          	STX 	SYMBOLIC
          	STY 	SCRAT3
          	STX 	ADDRS
          	STX 	ADDRS+1
          	LDA 	CRT,Y
          	CMP 	#'%'
          	BNE 	EVTSTDEC
EVBINEX     INY 	
          	LDA 	CRT,Y
          	CMP 	#'0'
          	BEQ 	EVBIN0
          	CMP 	#'1'
          	BEQ 	EVBIN1
          	SEC 	
          	RTS 	
;
EVBIN0     	CLC 	
          	BCC 	EVBININ

EVBIN1     	SEC 	
EVBININ    	ROL 	ADDRS
          	ROL 	ADDRS+1
          	JMP 	EVBINEX
;
EVTSTDEC   	JSR 	EVDEC
          	BCS 	EVDECEX
          	LDA 	CRT,Y
          	JMP 	EVTSTHX
;
EVDECEX    	INY 	
          	LDA 	CRT,Y
          	JSR 	EVDEC
          	BCS 	EVDECEX
          	TYA 	
          	PHA 	
EVDECCNT   	DEY 	
          	LDA 	CRT,Y
          	STY 	SAVE
          	JSR 	EVDEC
          	BCC 	EVDECOK
          	BEQ 	EVDECNXT
          	TAY 	
EVDECCONV  	LDA 	DECTABL,X
          	CLC 	
          	ADC 	ADDRS
          	STA 	ADDRS
          	LDA 	DECTABH,X
          	ADC 	ADDRS+1
          	STA 	ADDRS+1
          	DEY 	
          	BNE 	EVDECCONV
EVDECNXT   	LDY 	SAVE
          	INX 	
          	CPX 	#$05
          	BNE 	EVDECCNT
EVDECOK    	PLA 	
          	TAY 	
          	LDX 	#$00
          	SEC 	
          	RTS 	
;
DECTABL		.BYTE $01, $0A, $64, $E8, $10
DECTABH		.BYTE $00, $00, $00, $03, $27

EVDEC     	CMP 	#'0'
          	BCC 	EVNODEC 
          	CMP 	#':'
          	BCC 	DECIM
EVNODEC     CLC 	
          	RTS
;			
DECIM     	AND 	#$0F
          	SEC 	
          	RTS 	
		
EVTSTHX    	CMP 	#'$'
          	BEQ 	EVHEXEX 
          	CMP 	#'='
          	BEQ 	EVPC
EVSYM   	LDX 	SCRAT3
          	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	CMP 	#'/'
          	BNE 	EVTABEND1
          	INY 	
EVTABEND1  	LDA 	(SCRAT0),Y
          	BEQ 	EVTABEND
          	JMP 	EVMSEQ
;			
EVTABEND   	LDX 	#$00
          	LDY 	SCRAT3
EVSKLAB	   	INY 	
          	LDA 	CRT,Y
          	JSR 	TSTLABCH
          	BCC 	EVSKLAB
          	CMP 	#'!'
          	BEQ 	EVNEST
          	CMP 	#'.'
          	BNE 	EVTSTP2
EVNEST     	LDA 	MACSRCH
          	BNE 	EVSKLAB
          	LDA 	MACEXPAND
          	BNE 	EVSKLAB
EVTSTP2    	LDA 	PASS
          	BEQ 	EVNOTOK
          	JSR 	ERR.8				 ;UNDEFINED LABEL
EVNOTOK    	CLC 	
          	RTS 
;			
EVPC     	LDA 	PC
          	STA 	ADDRS
          	LDA 	PC+1
          	STA 	ADDRS+1
          	INY 	
          	SEC 	
          	RTS 
;			
EVHEXEX    	LDX 	#ADDRS-TXST
          	INY 	
          	JSR 	PARM
          	LDA 	SCRAT2
          	BNE 	EVOK
          	JSR 	ERR.D
          	CLC 	
          	RTS 
;			
EVCOMP     	LDA 	(SCRAT0),Y
          	PHP 	
          	AND 	#$7F
          	CMP 	CRT,X
          	BNE 	EVNOMATCH
          	INX 	
          	INY 	
          	PLP 	
          	BPL 	EVCOMP
          	TXA 	
          	TAY 	
          	LDA 	CRT,Y
          	JSR 	TSTLABCH
          	BCS 	EVSYMEQ 
          	BCC 	EVTONXT
;			
EVNOMATCH   PLP 	
EVTONXT     LDX 	#$00
          	JSR 	NXTLABSK 
          	CLV 	
          	BVC 	EVSYM  
;			
EVSYMEQ    	TYA 	
          	TAX 	
          	LDY 	#$00
          	LDA 	(SCRAT0),Y
          	STA 	ADDRS
          	INY 	
          	LDA 	(SCRAT0),Y
          	STA 	ADDRS+1
          	INY 	
          	LDA 	(SCRAT0),Y
          	CMP 	#'/'
          	BEQ 	EVEXT
          	INC 	EXT
EVEXT     	TXA 	
          	TAY 	
          	LDX 	#$00
          	INC 	SYMBOLIC
EVOK     	SEC 	
          	RTS 
			
OPERTST    	JSR 	GETOPER
          	BNE 	OPER1
          	RTS 
			
OPER1     	JSR 	ERR.A				;ERR IN OR NO OPERAND 
          	RTS
;			
TSTLABCH   	CMP 	#'.'
          	BCC 	BADLACHA 
          	CMP 	#'='
          	BEQ 	BADLACHA 
          	CMP 	#'{'
          	BCC 	LABCHAOK
BADLACHA   	SEC 	
LABCHAOK   	RTS
 	
EXLA     	LDY 	#MESLABS-MESERROR
          	JSR 	MESSAGE
          	JSR 	SR0STST
LAPRALL    	STX 	DC
          	JSR 	OUTCR
LAEND     	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	BNE 	LANORM
          	JSR 	OUTCR
          	RTS 	
;			
LANORM     	JSR 	CRTTXTLIN
          	LDA 	CRT
          	CMP 	#'!'
          	BEQ 	LANXT
          	CMP 	#'.'
          	BNE 	LAPRONE 
LANXT     	JSR 	NXTLABSK 
          	JMP 	LAEND

LAPRONE    	TYA 	
          	CLC 	
          	ADC 	DC
          	STA 	DC
          	JSR 	PRCRT
          	LDA 	#'='
          	JSR 	OUTCHAR
          	JSR 	PRFIRST 
          	JSR 	NXTLABSK 
          	LDY 	DC
LACOL     	LDY 	DC
          	JSR 	OUTSP
          	INY 	
          	STY 	DC
          	CPY 	#$12
          	BEQ 	LAEND
          	CPY 	#$24
          	BEQ 	LAEND
          	BCS 	LAPRALL
          	BNE 	LACOL
;			
PASS1      	STX 	HEXDEC
          	JMP 	EXPASS2
;		
EVMSEQ     	LDA 	(SCRAT0),Y
          	CMP 	#'.'
          	BNE 	EVFSEQ1
          	LDA 	MACEXPAND
          	BEQ 	EVTONXT1
          	INY 	
          	LDA 	(SCRAT0),Y
          	CMP 	MACSEQ
          	BNE 	EVTONXT1
          	INY 	
          	LDA 	(SCRAT0),Y
          	CMP 	MACSEQ+1
          	BNE 	EVTONXT1
          	LDA 	CRT,X
          	CMP 	#'.'
          	BNE 	EVTONXT1
          	BEQ 	EVMACSRCH 
EVFSEQ1    	CMP 	#'!'
          	BNE 	EVMSRCH
          	INY 	
          	LDA 	(SCRAT0),Y
          	BNE 	EVFSEQ 
          	INY 	
          	LDA 	(SCRAT0),Y
          	BEQ 	EVFSEQOK 
          	DEY 	
          	LDA 	(SCRAT0),Y
EVFSEQ    	CMP 	FILESEQ
          	BNE 	EVTONXT1
          	INY 	
          	LDA 	(SCRAT0),Y
          	CMP 	FILESEQ+1
          	BNE 	EVTONXT1
EVFSEQOK   	LDA 	MACSRCH
          	BEQ 	EVMACSRCH 
          	BNE 	EVMACDEF 
EVMSRCH    	LDA 	MACSRCH
          	BNE 	EVTONXT1
          	LDA 	CRT,X
          	CMP 	#'.'
          	BEQ 	EVTONXT1
          	CMP 	#'!'
          	BNE 	EVCOMP1  
EVTONXT1   	JMP 	EVTONXT
;
EVMACSRCH   INX 	
          	INX 	
          	INX 	
EVMACDEF   	INY 	
EVCOMP1   	JMP 	EVCOMP
;
; Tape 0 1 device off KIM-1
;
TD0OFF     	LDA 	CPORT
          	AND 	#$FE
          	STA 	CPORT
          	RTS 	
;			
TD1OFF     	LDA 	CPORT
          	AND 	#$FD
          	STA 	CPORT
          	RTS 	
;
; Tape device 0 1 on KIM-1 
;
TD0ON     	LDA 	CPORT
          	ORA 	#$01
          	STA 	CPORT
          	RTS 	
;			
TD1ON     	LDA 	CPORT
          	ORA 	#$02
          	STA 	CPORT
          	RTS 
;
; 			
OFF        	LDX 	#FIRST-TXST
          	JSR 	GETDECPARM 
          	LDA 	FIRST
          	BNE 	TSTTD1
          	JSR 	TD0OFF 
          	JMP 	MONLOOP1
;			
TSTTD1     	CMP 	#$01
          	BEQ 	TD1OFF1 
ERR161     	JMP 	ERR.16
;
TD1OFF1    	JSR 	TD1OFF
          	JMP 	MONLOOP1
;			
ON         	LDX 	#FIRST-TXST
          	JSR 	GETDECPARM 
          	LDA 	FIRST
          	BNE 	TSTTD11
          	JSR 	TD0ON
          	JMP 	MONLOOP1
;			
TSTTD11    	CMP 	#$01
          	BNE 	ERR161				;ILLEGAL TAPEDECK NR
          	JSR 	TD1ON
          	JMP 	MONLOOP1
			
DELAY8T    	JSR 	DELAY4T
DELAY4T    	JSR 	DELAY2T
DELAY2T    	JSR 	DELAYT
DELAYT    	LDX 	#$60
          	STX 	DELAY1
          	STX 	DELAY2
DELAYON    	INC 	DELAY1
          	BNE 	DELAYON
          	INC 	DELAY2
          	BNE 	DELAYON
          	LDX 	#$00
          	RTS 
;			
TD1ONW     	JSR 	TD1ON
          	JSR 	DELAYT
          	RTS 	
;
TD0ONW     	JSR 	TD0ON
          	JSR 	DELAY8T
          	RTS 	
;
TD1OFW      	JSR 	DELAYT
          	JSR 	TD1OFF
          	RTS 	
;
TD0OFW     	JSR 	DELAYT
          	JSR 	TD0OFF 
          	RTS 	
;
OUTCHAR    	PHA 	
          	STY 	SAVEY
          	STX 	SAVEX
          	LDA 	PRINTCTL
          	BEQ 	NOHARDCP 
          	PLA 	
HALAYOUT1  	PHA 	
          	JSR 	HALAYOUT 
NOHARDCP   	PLA 	
          	JSR 	PRBRKTST
          	LDY 	SAVEY
          	LDX 	SAVEX
          	CLD 	
          	RTS
;			
INSAVXY    	STY 	SAVEY
          	STX 	SAVEX
          	JSR 	INTSTCHR
          	LDY 	SAVEY
          	LDX 	SAVEX
          	CLD 	
          	RTS 	

OUTCR     	JSR 	JSROUTCR1
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	RTS 
;			
JSROUTCR1  	LDA 	#$0D
          	JSR 	OUTCHAR
          	RTS 
;			
OUT2SP     	JSR 	OUTSP
OUTSP     	LDA 	#' '
          	JSR 	OUTCHAR
          	RTS 	
			
OUTBYTE     PHA 	
          	LSR 	A
          	LSR 	A
          	LSR 	A
          	LSR 	A
          	JSR 	OUTNIBBLE
          	PLA 	
          	JSR 	OUTNIBBLE
          	RTS
;			
OUTNIBBLE  	AND 	#$0F
          	ORA 	#$30
          	CMP 	#':'
          	BCC 	NODEC
          	ADC 	#$06
NODEC     	JSR 	OUTCHAR
          	RTS 	
;			
NUMBER     	JSR 	EXNUMB
          	JMP 	MONLOOP
			
EXNUMB    	JSR 	INFL
          	LDA 	LAST+1 
          	CMP 	#$FF
          	BNE 	RENUMB
          	JMP 	ERR.11				; MISSING PARM IN NU COMM
			
RENUMB     	LDY 	#$00
          	CLC 	
          	SED 	
RENULN     	PHP 	
          	CPY 	#$02
          	BNE 	RENUADD
          	JSR 	NXTLILA
          	PLP 	
          	BCC 	RENUMBD
          	JMP 	ERR.10				;LINE # OVRFLW 
			
RENUMBD    	LDA 	(SCRAT0),Y
          	BNE 	RENUMB
          	CLD 	
          	RTS
;			
RENUADD    	PLP 	
          	LDA 	LAST,Y
          	ADC 	FIRST,Y
          	STA 	FIRST,Y
          	STA 	(SCRAT0),Y
          	INY 	
          	BNE 	RENULN
			
RC         	LDA 	#$6F
          	JMP 	P3RDIR
;
GPLNGE      	LDX 	#FIRST-TXST 
          	JSR 	GETDECPARM 
PXFEOF     	STY 	SAVE
          	JSR 	FINDLNGE
          	LDY 	SAVE
          	RTS 
;			
GET     	JSR 	GPARMS
GGOTIT     	LDA 	HFILENO 
          	CMP 	#$EE
          	BEQ 	GEOF
          	LDA 	LOADNO 
          	BEQ 	GTRYAGN
          	JMP 	MONLOOP
			
GTRYAGN    	JSR 	GHFILE
          	JMP 	GGOTIT

GEOF     	JSR 	TXTEND0
          	JMP 	MONLOOP
;
GPARMS    	JSR 	GETFILNO
          	JSR 	GETCRTUP
          	CMP 	#' '
          	BNE 	GAPP
GCLEAR      	JSR 	TXTCLEAR
          	CLC 	
          	BCC 	GSA
;			
GAPP     	CMP 	#'A'
          	BNE 	GSRCHSA
GSA     	LDA 	TPRES
          	STA 	SCRAT0
          	LDA 	TPRES+1
          	STA 	SCRAT0+1
          	CLC 	
          	BCC 	GHFILE
;			
GSRCHSA    	JSR 	GPLNGE 
GHFILE    	JSR 	TD1ONW
          	JSR 	TADSHFADS 
          	STA 	LOADNO 
          	JSR 	LOADER
          	BNE 	GLOADERR
          	LDA 	SCRAT0
          	STA 	TSTART 
          	LDA 	SCRAT0+1
          	STA 	TSTART+1
          	SEC 	
          	LDA 	HEND
          	SBC 	HSTART
          	PHA 	
          	LDA 	HEND+1
          	SBC 	HSTART+1
          	TAX 	
          	PLA 	
          	STA 	PROCADDRS
          	CLC 	
          	ADC 	SCRAT0
          	STA 	TEND
          	TXA 	
          	STA 	PROCADDRS+1
          	ADC 	SCRAT0+1
          	STA 	TEND+1
          	LDA 	#$00
          	STA 	LOADNO 
          	LDA 	FILENO
          	BEQ 	GDOLOAD
          	CMP 	HFILENO 
          	BNE 	GAFILE
GDOLOAD   	INC 	LOADNO 
          	LDA 	TEND+1
          	CMP 	TXEN+1
          	BCC 	GAFILE
          	BNE 	GTXTOVFLW
          	LDA 	TEND
          	CMP 	TXEN
          	BCC 	GAFILE
GTXTOVFLW  	LDA 	#$01
          	STA 	TERM
          	LDX 	#$00
          	JMP 	ERR.F				;TEXT FILE OVRFLW 
;			
GAFILE     	JSR 	LOADER
          	BNE 	GLOADERR
          	LDX 	#$00
          	JSR 	GLOADED
          	JSR 	TD1OFW 
          	JSR 	PRFILINFO
          	RTS 
			
GLOADERR   	LDX 	#$00
          	LDA 	LOADNO 
          	BEQ 	GNTFATAL
          	STA 	TERM
GNTFATAL    	JSR 	TXTEND0
          	JSR 	ERR.17
          	RTS 
			
TADSHFADS  	LDA 	#HFILENO &$FF
          	STA 	TSTART 
          	LDA 	#HEND+2 &$FF
          	STA 	TEND
          	LDA 	#$01
          	STA 	$TSTART+1
          	STA 	TEND+1
          	RTS 
;			
PUT        	JSR 	HFLTXTADS
          	JSR 	GETCRTUP
          	CMP 	#$20
          	BEQ 	PUTITRETM
          	CMP 	#'X'
          	BNE 	PFILNO
          	LDA 	#$EE
          	STA 	FILENO
          	STA 	FIRST+1
          	JSR 	PXFEOF
          	INY 	
          	BNE 	PSA 
PFILNO     	JSR 	GETFILNO
          	CPY 	#$50
          	BCS 	PUTITRETM
          	JSR 	GPLNGE 
PSA      	LDA 	SCRAT0
          	STA 	HSTART
          	LDA 	SCRAT0+1
          	STA 	HSTART+1
          	JSR 	NXTLETTER
          	LDX 	#FIRST-TXST
          	JSR 	GETDECPARM 
          	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	BEQ 	PEA
          	JSR 	LNNRLESS
          	BCS 	PEA
          	BPL 	PEA
          	JSR 	NXTLILA
PEA     	LDA 	SCRAT0
          	STA 	HEND
          	LDA 	SCRAT0+1
          	STA 	HEND+1
PUTITRETM   JSR 	PUTIT
          	JMP 	MONLOOP
;			
PUTHF      	JSR 	TADSHFADS 
          	LDA 	FILENO
          	STA 	HFILENO 
          	JSR 	PUTH 
          	LDY 	#$03
PUTF     	LDA 	HSTART,Y
          	STA 	TSTART ,Y
          	DEY 	
          	BPL 	PUTF
PUTH      	JSR 	SAVER
          	RTS 
;			
GLOADED    	LDA 	LOADNO 
          	BEQ 	GRET
          	LDA 	TEND
          	STA 	TPRES
          	LDA 	TEND+1
          	STA 	TPRES+1
          	JSR 	TXTEND0
GRET     	RTS 	

PRFILINFO  	LDA 	#'F'
          	JSR 	OUTCHAR
          	LDA 	HFILENO 
          	JSR 	OUTBYTE
          	JSR 	OUT2SP
          	LDA 	PROCADDRS+1
          	JSR 	OUTBYTE
          	LDA 	PROCADDRS
          	JSR 	OUTBYTE
          	LDA 	LOADNO 
          	BEQ 	PRNOADRS 
          	JSR 	OUT2SP
          	LDA 	TSTART+1
          	JSR 	OUTBYTE
          	LDA 	TSTART 
          	JSR 	OUTBYTE
          	LDA 	#$2D
          	JSR 	OUTCHAR
          	LDA 	TEND+1
          	JSR 	OUTBYTE
          	LDA 	TEND
          	JSR 	OUTBYTE
PRNOADRS   	JSR 	OUTCR
          	RTS 	
;
SETBNDS    	LDA 	DEFAULTS,X
          	STA 	TXST,X
          	INX 	
          	CPX 	#$08
          	BCC 	SETBNDS
          	LDA 	DEFAULTS+8
          	STA 	PURECL
          	LDA 	DEFAULTS+9
          	STA 	PURECH
          	LDX 	#$00
CLRTXTST   	JSR 	TXTCLEAR
          	JSR 	SPRESSTST
          	JSR 	STEND0
          	RTS 	
;			
DEFAULTS  	.WORD 	$4163			; Workspace defaults
			.WORD 	$53FC
			.WORD 	$5400
			.WORD 	$5EFC
			.WORD	$5F00
			
FIND      	STY 	EDITFINDC
          	JMP 	EDSTRING
			
EDIT       	STX 	EDITFINDC
          	STX 	SCRAT1
          	JSR 	GETCRTHX
          	BEQ 	EDSTRING
          	LDA 	SCRAT1
          	BNE 	EDSTRING
          	JMP 	EDLINE
;			
EDSYNER    	LDX 	#$00
          	JMP 	ERR.15			; syntax error in ED command
			
EDSTRING   	LDA 	#'%'
          	STA 	DC
          	STX 	ERRORS
          	STX 	ERRORS+1
          	INC 	TABSN
          	LDX 	#$02
          	LDA 	CRT,Y
          	STA 	DELIM
          	INY 	
          	TYA 	
          	STA 	CRTEX,X
EDSAVSTRS  	CPX 	#$01
          	BNE 	EFSAVSTR
          	LDA 	EDITFINDC
          	BNE 	EFEMPTY
EFSAVSTR   	LDA 	CRT,Y
          	STA 	CRTEX,Y
          	INY 	
          	CPY 	#$4C
          	BCS 	EDSYNER
          	CMP 	DELIM
          	BNE 	EDSAVSTRS
          	TYA 	
          	DEX 	
          	STA 	CRTEX,X
          	BNE 	EDSAVSTRS
EFEMPTY    	LDA 	CRTEX+1 
          	CLC 	
          	SBC 	CRTEX+2
          	BEQ 	EDSYNER
          	LDX 	#$00
          	STX 	CRTEX+3
          	JSR 	NXTLETTER
          	LDA 	CRT,Y
          	CMP 	#'%'
          	BNE 	EDSUBCS
          	INY 	
          	LDA 	CRT,Y
          	STA 	DC
          	INY 	
          	JSR 	NXTLETTER
          	LDA 	CRT,Y
EDSUBCS    	CMP 	#'*'
          	BNE 	EFSUPPRO
          	INC 	CRTEX+3
          	BNE 	EFTOPARMS
;			
EFSUPPRO    CMP 	#'#'
          	BNE 	EFGTPARMS
          	DEC 	CRTEX+3
EFTOPARMS  	JSR 	NXTWORD
EFGTPARMS   JSR 	INFL
EFEOF     	LDY 	#$02
          	LDA 	(SCRAT0),Y
          	BNE 	EFSRCHSTR
          	JMP 	EDDONE
;			
EFSRCHSTR   JSR 	EFCT 
          	STX 	ADDRS
EFSRCHA1    LDX 	CRTEX+2 
          	LDY 	ADDRS
EFEOL     	CPY 	SAVE
          	BEQ 	EFDCDLM
          	BCS 	EFNEWLN
EFDCDLM    	LDA 	CRTEX,X
          	CMP 	DC
          	BEQ 	EFMATCH
          	CMP 	DELIM
          	BNE 	EFCMPCH 
          	LDX 	#$00
          	STY 	CRTEX-1
          	BEQ 	EFFOUND
;			
EFCMPCH    	CMP 	CRT,Y
          	BEQ 	EFMATCH
EFSRCHON   	INC 	ADDRS
          	BNE 	EFSRCHA1
;
EFMATCH    	INX 	
          	INY 	
          	BNE 	EFEOL

EFNEWLN    	LDX 	#$00
EFNXTLN     	JSR 	NXTLILA
          	LDY 	#$02
EFDONE     	DEY 	
          	BMI 	EFEOF1 
          	LDA 	LAST,Y
          	CMP 	(SCRAT0),Y
          	BEQ 	EFDONE
          	BCC 	EDDONE
EFEOF1     	JMP 	EFEOF
;
EFFOUND    	JSR 	INCERRORS
          	LDA 	EDITFINDC
          	BNE 	EFPRCOLNR
          	LDA 	CRTEX+3
          	BMI 	EDCHNGE
          	BEQ 	EDCHNGE
EFPRCOLNR  	LDA 	CRTEX+3
          	BMI 	EDSUBCIN
          	JSR 	OUTSP
          	LDA 	ADDRS
          	JSR 	OUTBYTE
          	JSR 	EFPRLIN
EDCR     	JSR 	OUTCR
EDSUBCIN   	LDA 	EDITFINDC
          	BNE 	EFSRCHON
          	LDA 	#'*'
          	JSR 	OUTCHAR
          	JSR 	INSAVXY
          	JSR 	UPPERCASE
          	PHA 	
          	JSR 	OUTCR
          	PLA 	
          	CMP 	#'S'
          	BEQ 	EFNEWLN
          	CMP 	#'X'
          	BNE 	EDMAF
EDDONE     	JSR 	CLRSPR
          	JSR 	PRERRORS
          	JMP 	MONLOOP1
;			
EDMAF     	CMP 	#'M'
          	BEQ 	EFSRCHON
          	CMP 	#'A'
          	BEQ 	EDCHNGE
          	CMP 	#$06				; ACK?
          	BNE 	EDD
          	JSR 	ELSTART
          	JSR 	OUTCR
          	JMP 	EFNEWLN
;			
EDD     	CMP 	#'D'
          	BNE 	EDCR
          	JSR 	FILNDEL
          	JMP 	EFNXTLN
;			
EDCHNGE   	LDA 	EDITFINDC
          	BEQ 	EDCHNGE1
          	JMP 	EFSRCHON
			
EDCHNGE1   	LDA 	CRTEX-1
          	TAY 	
          	SEC 	
          	SBC 	ADDRS
          	TAX 	
EDDELSTR   	JSR 	EDDELCH 
          	DEX 	
          	BNE 	EDDELSTR
          	LDX 	CRTEX+1 
EDINSSTR   	LDA 	CRTEX,X
          	CMP 	DELIM
          	BEQ 	EDLINOK 
          	JSR 	EDINSCH 
          	INY 	
          	INX 	
          	BNE 	EDINSSTR 
EDLINOK    	STY 	ADDRS
          	JSR 	EDCHNGELN 
          	BCS 	EDPRNEW
          	JMP 	EFEOF1 
;
EDPRNEW    	LDA 	CRTEX+3
          	BPL 	EDPRNEW1
          	LDA 	#$00
          	JSR 	OUTCHAR
          	JMP 	EFSRCHA1
			
EDPRNEW1   	JSR 	EFPRLIN
          	JSR 	OUTCR
          	JMP 	EFSRCHA1
;			
EFCT      	LDA 	FORMAT
          	PHA 	
          	STX 	FORMAT
          	JSR 	CRTTXTLIN
          	PLA 	
          	STA 	FORMAT
          	INY 	
          	STY 	SAVE
          	RTS 	
;
INCERRORS  	SED 	
          	CLC 	
          	LDA 	ERRORS
          	ADC 	#$01
          	STA 	ERRORS
          	LDA 	$DC
          	ADC 	#$00
          	STA 	$DC
          	CLD 	
          	RTS 
;			
EDLINE     	JSR 	INFL
          	BPL 	MONLOOP13 
          	BCS 	MONLOOP13 
          	JSR 	EFCT 
          	JSR 	PRCRT
          	JSR 	OUTCR
          	JSR 	ELSTART
MONLOOP13   JMP 	MONLOOP1

ELSTART    	LDY 	#$00
ELF     	JSR 	INSAVXY
          	CMP 	#$06				;ACK? (^F) 
          	BNE 	ELDEL1		
          	LDA 	#'>'
          	JSR 	OUTCHAR
          	JSR 	INSAVXY
          	CMP 	#$06				;ACK? (^F)	
          	BEQ 	ELF
          	STA 	CRTEX-2
ELNXTCH    	INY 	
          	CPY 	SAVE
          	BCC 	ELPRCH 
          	BEQ 	ELPRCH 
          	RTS 	
;
ELPRCH     	LDA 	CRT-1,Y
          	PHA 	
          	JSR 	OUTCHAR
          	PLA 	
          	CMP 	CRTEX-2
          	BNE 	ELNXTCH
          	BEQ 	ELF
;			
ELDEL1     	CMP 	#$08				; BS?
          	BEQ 	ELDEL				; DEL?
          	CMP 	#$7F
          	BNE 	ELCR1
          	LDA 	#$5C
          	JSR 	OUTCHAR
ELDEL     	JSR 	EDDELCH 
          	JMP 	ELF

ELCR1     	CMP 	#$0D				; CR?
          	BNE 	ELD
          	JSR 	EDCHNGELN 
EL.DONE    	BCC 	ELRET
          	JSR 	OUTCR
EFPRLIN    	JSR 	OUTSP
          	JSR 	PRSPFRST
          	JSR 	OUT2SP
          	LDY 	SAVE
          	JSR 	PRCRT
ELRET     	RTS 
;	
ELD     	CMP 	#$04				; EOT?
          	BNE 	ELINSERT
          	JSR 	OUTCR
          	DEY 	
          	STY 	SAVE
          	INY 	
          	JSR 	EDMAX80
          	JMP 	EL.DONE
;			
ELINSERT   	JSR 	EDINSCH 
          	INY 	
          	JMP 	ELF
;
EDINSCH    	PHA 	
          	STY 	ADDRS+1
          	LDY 	SAVE
EDUPW     	LDA 	CRT,Y
          	STA 	CRT+1,Y
          	DEY 	
          	BMI 	ED76
          	CPY 	ADDRS+1
          	BCS 	EDUPW
ED76     	PLA 	
          	INY 	
          	STA 	CRT,Y
          	CPY 	#76			
          	BCC 	EDINCEOL 
          	DEY 	
EDINCEOL   	INC 	SAVE
          	LDA 	SAVE
          	CMP 	#76
          	BCC 	EDIRET
          	DEC 	SAVE
EDIRET     	RTS 	
;
EDDELCH    	DEY 	
          	BPL 	EDSVCUR
          	INY 	
EDSVCUR    	TYA 	
          	PHA 	
EDDOWNW    	INY 	
          	LDA 	CRT,Y
          	STA 	CRT-1,Y
          	CPY 	SAVE
          	BCC 	EDDOWNW
          	DEC 	SAVE
          	BPL 	EDGTCUR
          	INC 	SAVE
EDGTCUR    	PLA 	
          	TAY 	
          	RTS 	
;
EDCHNGELN  	LDY 	SAVE
EDMAX80    	INY 	
          	CPY 	#82
          	BCC 	EDTOTXT
          	LDY 	#81
EDTOTXT    	STY 	 ADDPAD
          	LDX 	#$00
          	JSR 	FILNDEL
          	LDY 	ADDPAD
          	CPY 	#$02
          	BCC 	EDCRET 
          	LDY 	#$00
          	JSR 	INSRTLN
          	SEC 	
EDCRET      RTS 	
;
HALAYOUT   	NOP 	
          	NOP 	
          	NOP 	
          	CMP 	#$0A				; LF?
          	BNE 	HARET
          	INC 	LINECNTR
          	LDA 	LINECNTR
          	CMP 	#4
          	BEQ 	HA36SP 
          	CMP 	#$40
          	BNE 	HARET
HASKTONXT  	LDA 	#$0A
          	JSR 	OUTCHAR
HAPAGE     	LDA 	LINECNTR
          	CMP 	#$3F
          	BNE 	HATST4
          	LDA 	#$0A
          	BNE 	HALAYOUT 
HATST4     	CMP 	#$46
          	BNE 	HASKTONXT
          	LDA 	#$04
          	STA 	LINECNTR
HA36SP     	LDA 	#$24
          	STA 	DELAY1
HANXTSP    	JSR 	OUTSP
          	DEC 	DELAY1
          	BNE 	HANXTSP
          	TYA 	
          	PHA 	
          	LDY 	#MESPAGE-MESERROR 
          	JSR 	MESSAGE
          	PLA 	
          	TAY 	
          	LDA 	PAGENUMB
          	PHA 	
          	JSR 	OUTBYTE
          	PLA 	
          	SED 	
          	CLC 	
          	ADC 	#$01
          	CLD 	
          	STA 	PAGENUMB
          	JSR 	OUTCR
          	JSR 	OUTCR
HARET     	RTS 
;	
HARD       	JSR 	GETCRTUP
          	CMP 	#'P'
          	BEQ 	HASKIPP
          	STX 	PRINTCTL
          	CMP 	#'S'
          	BNE 	HASEPGNR
          	STX 	LINECNTR
          	INC 	PRINTCTL
HASEPGNR   	JSR 	NXTWORD
          	CPY 	#80
          	BCS 	MONLOOP14
          	LDX 	#PAGENUMB-TXST
          	JSR 	GETDECPARM 
MONLOOP14  	JMP 	MONLOOP1

HASKIPP    	LDA 	PRINTCTL
          	BEQ 	HASEPGNR
          	TYA 	
          	PHA 	
          	JSR 	HAPAGE 
          	PLA 	
          	TAY 	
          	JMP 	HASEPGNR
;			
COPY       	JSR 	EXCOPY 
          	JMP 	MONLOOP
;			
EXCOPY     	JSR 	NXTLETTER
          	LDX 	#FIRST-TXST
          	JSR 	GETDECPARM 
          	LDA 	FIRST
          	PHA 	
          	LDA 	FIRST+1
          	PHA 	
          	STY 	SAVE
          	JSR 	FINDLNGE
          	BPL 	CDESTFND
          	JSR 	NXTLILA
CDESTFND   	LDA 	SCRAT0
          	STA 	SCRAT3
          	LDA 	SCRAT0+1
          	STA 	SCRAT4
          	LDY 	SAVE
          	JSR 	NXTLETTER
          	JSR 	INFL
          	PHP 	
          	LDA 	LAST+1 
          	CMP 	#$FF
          	BNE 	CFROM
          	JMP 	ERR.11				;MISSING PARM
			
CFROM     	JSR 	SR12SR0 
          	PLP 	
          	BPL 	CUNTIL
          	JSR 	NXTLILA
CUNTIL     	JSR 	FIRSTLAST
          	JSR 	FNDEOF
          	BPL 	CCALCTP
          	JSR 	NXTLILA
CCALCTP     PLA 	
          	STA 	FIRST+1
          	PLA 	
          	STA 	FIRST
          	SEC 	
          	LDA 	SCRAT0
          	SBC 	SCRAT1
          	STA 	PC
          	LDA 	SCRAT0+1
          	SBC 	SCRAT2
          	STA 	PC+1
          	LDA 	PC
          	CLC 	
          	ADC 	TPRES
          	STA 	REL
          	PHA 	
          	LDA 	PC+1
          	ADC 	TPRES+1
          	STA 	REL+1 
          	PHA 	
          	CMP 	TXEN+1
          	BEQ 	COVFLW
          	BCC 	CDU1
ERRF1     	JMP 	ERR.F				;TEXT FILE OVRFLW 
;
COVFLW     	LDA 	REL
          	CMP 	TXEN
          	BCS 	ERRF1
CDU1     	LDA 	SCRAT4
          	CMP 	SCRAT0+1
          	BEQ 	CDU2
          	BCC 	CDF1
          	BCS 	CMOVED
;			
CDU2     	LDA 	SCRAT3
          	CMP 	SCRAT0
          	BCS 	CMOVED
CDF1     	LDA 	SCRAT2
          	CMP 	SCRAT4
          	BEQ 	CDF22
          	BCC 	ERR121
          	BCS 	CADJFU
;			
CDF22     	LDA 	SCRAT1
          	CMP 	SCRAT3
          	BCS 	CADJFU
ERR121     	JMP 	ERR.12				;OUT OF RANGE
;
CADJFU     	LDX 	#$02
CADJU      	CLC 	
          	LDA 	SCRAT0,X
          	ADC 	PC
          	STA 	SCRAT0,X
          	LDA 	SCRAT0+1,X
          	ADC 	PC+1
          	STA 	SCRAT0+1,X
          	DEX 	
          	DEX 	
          	BPL 	CADJU 
          	LDX 	#$00
CMOVEUP    	JSR 	DECTPRES
          	JSR 	DECREL
          	LDA 	(TPRES,X)
          	STA 	(REL,X)
CMOVED     	LDA 	SCRAT4
          	CMP 	TPRES+1
          	BNE 	CMOVEUP
          	LDA 	SCRAT3
          	CMP 	TPRES
          	BNE 	CMOVEUP
          	LDA 	SCRAT1
          	PHA 	
          	LDA 	SCRAT2
          	PHA 	
          	LDA 	SCRAT3
          	STA 	PC
          	LDA 	SCRAT4
          	STA 	PC+1
CCOPYED1   	LDA 	SCRAT0
          	CMP 	SCRAT1
CCOPYED11   BNE 	CCOPY
          	LDA 	SCRAT0+1
          	CMP 	SCRAT2
          	BEQ 	CCOPYED
CCOPY     	LDA 	(SCRAT1,X)
          	STA 	(SCRAT3,X)
          	JSR 	INCSCR12
          	JSR 	INCSCR34
          	JMP 	CCOPYED1
			
CCOPYED    	PLA 	
          	STA 	SCRAT2
          	PLA 	
          	STA 	SCRAT1
          	PLA 	
          	STA 	TPRES+1
          	PLA 	
          	STA 	TPRES
          	JSR 	TXTEND0
          	LDA 	SCRAT0+1
          	PHA 	
          	LDA 	SCRAT0
          	PHA 	
          	LDY 	#$02
          	LDA 	(SCRAT3),Y
          	PHA 	
          	LDA 	#$00
          	STA 	(SCRAT3),Y
          	STA 	LAST
          	STA 	LAST+1 
          	LDA 	PC
          	STA 	SCRAT0
          	LDA 	PC+1
          	STA 	SCRAT0+1
          	LDA 	(SCRAT0),Y
          	BEQ 	CDONE
          	JSR 	RENUMB
CDONE     	PLA 	
          	STA 	(SCRAT3),Y
          	PLA 	
          	STA 	SCRAT0
          	PLA 	
          	STA 	SCRAT0+1
          	RTS 	
;			
FIRSTLAST   LDA 	LAST
          	STA 	FIRST
          	LDA 	LAST+1 
          	STA 	FIRST+1
          	RTS 
;			
MOVE       	JSR 	EXCOPY 
          	JSR 	MOVEDOWN
          	JMP 	MONLOOP
;			
DELETE     	JSR 	NXTLETTER
          	CPY 	#64
          	BCC 	DPARMS
          	JMP 	ERR.11					;MISSING PARM
;			
DPARMS     	JSR 	INFL
          	BEQ 	ERR122
          	PHP 	
          	JSR 	SR12SR0 
          	JSR 	FIRSTLAST
          	PLP 	
          	BPL 	DUNTIL
          	JSR 	NXTLILA
DUNTIL     	JSR 	FNDEOF
          	BPL 	DDELETE
          	JSR 	NXTLILA
DDELETE    	JSR 	MOVEDOWN
          	JMP 	MONLOOP
;			
ERR122     	JMP 	ERR.12
;
SET        	INC 	PASS
          	STX 	HEXDEC
NEWBOUNDS  	CPY 	#$50
          	BCS 	PRBOUNDS
          	TXA 	
          	PHA 	
          	LDX 	#$00
          	JSR 	OPERTST
          	PLA 	
          	TAX 	
          	LDA 	PROCADDRS
          	STA 	TXST,X
          	INX 	
          	LDA 	PROCADDRS+1
          	STA 	TXST,X
          	INX 	
          	JSR 	NXTLETTER
          	CPX 	#$08
          	BCC 	NEWBOUNDS
          	CPY 	#$50
          	BCS 	PRBOUNDS
          	LDX 	#$00
          	JSR 	OPERTST
          	LDA 	PROCADDRS
          	STA 	PURECL
          	LDA 	PROCADDRS+1
          	STA 	PURECH
          	JSR 	CLRTXTST
PRBOUNDS   	LDX 	#$00
          	JSR 	OUTCR
PRBTXST    	LDA 	TXST+1,X
          	JSR 	OUTBYTE
          	LDA 	TXST,X
          	JSR 	OUTBYTE
          	CPX 	#$00
          	BNE 	PRB2SP
PRB     	LDA 	#'-'
          	JSR 	OUTCHAR
          	JMP 	PRBPRES
;			
PRB2SP     	CPX 	#$04
          	BEQ 	PRB
          	JSR 	OUT2SP
PRBPRES    	INX 	
          	INX 	
          	CPX 	#$08
          	BCC 	PRBTXST
          	LDA 	PURECH
          	JSR 	OUTBYTE
          	LDA 	PURECL
          	JSR 	OUTBYTE
          	JSR 	OUTCR
          	LDA 	TPRES+1
          	JSR 	OUTBYTE
          	LDA 	TPRES
          	JSR 	OUTBYTE
          	JSR 	OUT2SP
          	LDA 	SPRES+1
          	JSR 	OUTBYTE
          	LDA 	SPRES
          	JSR 	OUTBYTE
          	JSR 	OUTCR
          	JMP 	MONLOOP
;			
DUPLCT     	JSR 	GETFILNO
DUPLCT1    	STX 	FILENO
          	JSR 	GCLEAR 
          	LDA 	HFILENO 
          	STA 	FILENO
          	CMP 	#$EE
          	BEQ 	MONLOOP111
          	CMP 	LAST
          	BEQ 	MONLOOP111 
          	JSR 	HFLTXTADS
          	JSR 	PUTIT
          	JMP 	DUPLCT1
			
MONLOOP111 	JMP 	MONLOOP
;
HFLTXTADS  	LDX 	#$01
HFLNXT     	LDA 	TXST,X
          	STA 	HSTART,X
          	LDA 	TPRES,X
          	STA 	HEND,X
          	DEX 	
          	BPL 	HFLNXT
          	INX 	
          	RTS

ENTER		STX 	DISCO
			CPY 	#80
          	BCS 	ENTER2
          	INC 	DISCO
ENTER2   	JSR 	ENTER1
          	JMP 	MONLOOP
			
ENTER1    	JMP 	(DISC1)

LOOKUP     	STX 	DISCI
          	CPY 	#$50
          	BCS 	LOOKUP2
          	INC 	DISCI
LOOKUP2   	JSR 	LOOKUP1
          	JMP 	MONLOOP
;			
LOOKUP1    	JMP 	(DISC2)
;
DISCCOM    	JSR 	DISCCOM1
          	JMP 	MONLOOP
			
DISCCOM1   	JMP 	(DISCCVEC)

PRBRKTST    JSR 	PRINTTSTO
          	CMP 	#$0D				; CR
          	NOP 	
          	BNE 	RETPB 
          	NOP 	
          	JSR 	BRKTST
          	BCC 	RETPB 
          	PHA 	
          	NOP 	
          	NOP 	
BROKEN     	JSR 	INTSTCHR
          	CMP 	#$0F				; SI? (^O)
          	BNE 	GOON1
          	LDA 	#$0D				; CR
          	NOP 	
          	NOP 	
          	NOP 	
          	JSR 	JMPPRINT
          	PLA 	
          	RTS 	
;			
GOON1     	CMP 	#$11
          	BNE 	BROKEN
          	PLA 	
RETPB      	RTS 
	
PRINTTSTO  	AND 	#$7F
          	PHA 	
          	LDA 	SUPPRESS0
          	BEQ 	TESTCCHAR
          	PLA 	
          	RTS 	
;
TESTCCHAR   PLA 	
          	PHA 	
          	CMP 	#$00				; nul?
          	BEQ 	NOCCHAR 
          	CMP 	#$1B				; Escape
          	BEQ 	NOCCHAR 
          	CMP 	#$0D				; CR?
          	BEQ 	NOCCHAR 
          	CMP 	#$0A				; LF
          	BEQ 	NOCCHAR 
          	CMP 	#$07				; Bell?
          	BEQ 	NOCCHAR 
          	CMP 	#$08				; BS
          	BEQ 	NOCCHAR 
          	CMP 	#$20				; SP?
          	BCS 	NOCCHAR 
          	PHA 	
          	LDA 	#'^'				; 
          	JSR 	JMPPRINT
          	PLA 	
          	CLC 	
          	ADC 	#$40
NOCCHAR     JSR 	JMPPRINT
          	PLA 	
          	RTS 
;			
JMPPRINT   	JMP 	PRINT

INTSTCHR   	LDA 	#$00
          	STA 	SUPPRESS0
INAGN     	JSR 	INCHAR
          	CMP 	#$00				; NUL?
          	BEQ 	INAGN
          	CMP 	#$1A				; ^Z
          	BNE 	TSTC 
          	JMP 	MONLOOP
;			
TSTC      	CMP 	#$03
          	BNE 	TSTY 
          	JMP 	BREAK
;
TSTY      	CMP 	#$19				; EM? (^Y)
          	BNE 	TSTSTX
EXIT0000   	JMP 	NULVECTOR
			
TSTSTX     	CMP 	#$02				; STX?
          	BNE 	TSTBEL 
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	JMP 	$0006
			
TSTBEL    	CMP 	#$07				; Bell?
          	BNE 	TSTSI
          	NOP 	
          	NOP 	
          	NOP 	
TSTSI     	CMP 	#$0F				; SI? ^O
          	BNE 	TSTDC4
          	INC 	SUPPRESS0
          	RTS 	
;			
TSTDC4     	CMP 	#$14				; DC4? ^T?
          	BNE 	RET5
          	JSR 	INCHAR
          	CMP 	#'0'
          	BEQ 	TD0TGGL
          	CMP 	#'1'
          	BNE 	RET5
          	LDA 	CPORT				; tape motor 1
          	EOR 	#$02
          	STA 	CPORT
          	JMP 	RETCAN
			
TD0TGGL    	LDA 	CPORT				; tape motor 1
          	EOR 	#$01
          	STA 	CPORT
RETCAN     	LDA 	#$18				; CAN (^X)
RET5     	RTS 
;
; read KIM character
;	
INCHAR     	JSR 	GETCH
          	AND 	#$7F
          	PHA 	
          	LDA 	TABSN
          	BNE 	ECHO
          	PLA 	
          	PHA 	
          	CMP 	#$11				; DC1? ^Q
          	BEQ 	NOECHO
          	CMP 	#$09				; tab?
          	BEQ 	NOECHO
ECHO     	PLA 	
          	NOP 	
          	NOP 	
          	NOP 	
          	RTS 
;			
NOECHO     	PLA 	
          	RTS 	
;
IFPSEU1     LDX 	#$00
          	LDA 	CRT+3,Y
          	CMP 	#$20
          	BNE 	MACRO1
          	JSR 	SRCHAT 
MACRO1     	LDA 	#$01
          	STA 	MACSRCH
          	JSR 	EVLABEX 
          	BCS 	MFOUND
ILLMNEM    	JSR 	ERR.2				 ;ILLEGAL MNEMONIC 
          	JMP 	ASGOON
;
MFOUND   	LDA 	SYMBOLIC
          	BEQ 	ILLMNEM
          	LDA 	CRT,Y
          	CMP 	#$20
          	BEQ 	MDEFD1
          	JSR 	ERR.2
          	JMP 	ASGOON
		
MDEFD1     	LDA 	TOP+1 
          	CMP 	ADDRS+1
          	BEQ 	MDEFD22
          	BCS 	MPARMS1
MNOTDEFD   	LDX 	#$20
          	JSR 	ERR.0
          	JMP 	ASGOON
;			
MDEFD22    	LDA 	TOP
          	CMP 	ADDRS
          	BCC 	MNOTDEFD
MPARMS1    	LDA 	ADDRS+1
          	PHA 	
          	LDA 	ADDRS
          	PHA 	
          	STX 	MACSRCH
          	STX 	CRTEX
          	JSR 	NXTWORD
          	CPY 	#80
          	BCS 	MCALLEXP
          	CMP 	#$3B				; ';'
          	BEQ 	MCALLEXP
          	CMP 	#'('			
          	BEQ 	MPARMIN
          	JSR 	ERR.A
          	PLA 	
          	PLA 	
          	JMP 	ASGOON
;
MPARMIN    	INY 	
MNXTPARM    JSR 	NXTLETTER
          	CPY 	#$50
          	BCS 	MCALLEXP
          	LDA 	CRT,Y
          	CMP 	#')'
          	BEQ 	MCALLEXP
          	TXA 	
          	PHA 	
          	LDX 	#$00
          	JSR 	GETOPER
          	PLA 	
          	TAX 	
          	LDA 	PROCADDRS
          	STA 	CRTEX+1 ,X
          	LDA 	PROCADDRS+1
          	INX 	
          	STA 	CRTEX+1 ,X
          	INX 	
          	INC 	CRTEX
          	BNE 	MNXTPARM
MCALLEXP   	LDX 	#$00
          	PLA 	
          	STA 	SCRAT0
          	PLA 	
          	STA 	SCRAT0+1
          	PHA 	
          	LDA 	SCRAT0
          	PHA 	
          	JSR 	PRASLIN 
          	LDA 	#$01
          	STA 	CALLEXP
          	INC 	MACEXPAND
          	LDA 	MACEXPAND
          	CMP 	#$20
          	BCC 	ASLINE1
          	LDX 	#$24
          	STX 	TERM
          	JMP 	ERR.0					;TOO MANY NESTED MACROS 
;			
ASLINE1    	JMP 	ASLINE
;
SRCHAT     	LDA 	CRT,Y
          	JSR 	UPPERCASE
          	CMP 	ATCOND,X
          	BNE 	SRATNXT
          	LDA 	CRT+1,Y
          	JSR 	UPPERCASE
          	CMP 	ATCOND+1,X
          	BNE 	SRATNXT
          	LDA 	CRT+2,Y
          	JSR 	UPPERCASE
          	CMP 	ATCOND+2,X
          	BNE 	SRATNXT
          	LDA 	ATCOND+3,X
          	STA 	SCRAT3
          	LDA 	ATCOND+4,X
          	STA 	SCRAT4
          	PLA 	
          	PLA 	
          	INY 	
          	INY 	
          	INY 	
          	LDX 	#$00
          	JMP 	EXPSEU
;			
SRATNXT    	INX 	
          	INX 	
          	INX 	
          	INX 	
          	INX 	
          	LDA 	ATCOND,X
          	BNE 	SRCHAT 
          	LDX 	#$00
          	RTS 
			
ATCOND 		.TEXT	"IFE"
			.WORD 	IFE
			.TEXT	"IFN"
			.WORD	IFN
			.TEXT	"IFP"
			.WORD	IFP
			.TEXT	"IFM"
			.WORD	IFM
			.TEXT	"SET"
			.WORD	SETLABEL
;
ATSTARS		.BYTE 	$2A
			.BYTE 	$2A
			.BYTE 	$2A
			.WORD  	STARS
			.TEXT   ".EN"
			.WORD	EN
			.BYTE   $00	
;
ATMEMDEN	.TEXT	".ME"
			.WORD	MEINP
			.TEXT	".MD"
			.WORD	ILLNEST
			.TEXT	".EN"
			.WORD	EN
			.BYTE 	$00
			
ATINDXY 	.TEXT	",X)"
			.WORD	INDX
			.TEXT 	"),Y"
			.WORD	INDY
			.BYTE 	$00
;
ATZXY 		.TEXT	",X "
			.WORD	ZEROX
			.TEXT 	",Y "
			.WORD	ZEROY
			.BYTE 	$00
;
ATAXY 		.TEXT	",X "
			.WORD	ABSX
			.TEXT	",Y "
			.WORD	ABSY
			.BYTE	$00
;
ATLABLH 	.TEXT	"#L,"
			.WORD	IMMLABL
			.TEXT	"#H,"
			.WORD	IMMLABH
			.BYTE 	$00
			
STARS     	STX 	CONDSUP
          	JMP 	ASGOON
;
MEINP		STX 	MACSUPPRS
          	JMP 	ASGOON
;
ILLNEST    	LDX 	#$29
          	JSR 	ERR.0				 ;ILL NESTED DEFINITION
          	JMP 	ASGOON
			
IFE        	JSR 	IFGETOPER
          	LDA 	PROCADDRS
          	BNE 	ASGOON8 
          	LDA 	PROCADDRS+1
          	BNE 	ASGOON8 
IFNOSUPR    STX 	CONDSUP
ASGOON8    	JMP 	ASGOON
;
IFN        	JSR 	IFGETOPER
          	LDA 	PROCADDRS
          	BNE 	IFNOSUPR
          	LDA 	PROCADDRS+1
          	BEQ 	ASGOON8 
          	BNE 	IFNOSUPR
;
IFP        	JSR 	IFGETOPER
          	LDA 	PROCADDRS+1
          	BMI 	ASGOON9
          	STX 	CONDSUP
ASGOON9    	JMP 	ASGOON

IFM        	JSR 	IFGETOPER
          	LDA 	PROCADDRS+1
          	BPL 	ASGOONA
			STX 	CONDSUP
ASGOONA     JMP 	ASGOON

IFGETOPER   STY 	CONDSUP
IFSGET     	JSR 	NXTLETTER
          	JSR 	OPERTST
          	LDA 	ADDPAD
          	BEQ 	IFSGOT 
IFSERR     	STY 	TERM
          	JSR 	ERR.4				;OPERAND UNDEFINED 
IFSGOT     	RTS 
;	
ES         	STY 	LSTEXPOB
          	JMP 	ASGOON
;
EC         	STX 	LSTEXPOB
          	JMP 	ASGOON
			
SETLABEL   	JSR 	EVLABEX 
          	BCS 	SETSYMB1
          	JMP 	IFSERR 
			
SETSYMB1   	LDA 	SYMBOLIC
          	BNE 	SETOPR1
          	LDX 	#$2A
          	JSR 	ERR.0				;MUST BE SYBOLIC (SET) 
          	JMP 	ASGOON

SETOPR1    	JSR 	NXTLETTER
          	LDA 	CRT,Y
          	CMP 	#'='
          	BEQ 	SETLABEL1
          	JSR 	ERR.A
          	JMP 	ASGOON
;			
SETLABEL1  	LDA 	SCRAT0+1
          	PHA 	
          	LDA 	SCRAT0
          	PHA 	
          	INY 	
          	JSR 	IFSGET
          	PLA 	
          	STA 	SCRAT0
          	PLA 	
          	STA 	SCRAT0+1
          	LDY 	#$00
          	LDA 	PROCADDRS
          	STA 	(SCRAT0),Y
          	LDA 	PROCADDRS+1
          	INY 	
          	STA 	(SCRAT0),Y
          	JMP 	ASGOON
;			
MD        	LDA 	MACEXPAND
          	BEQ 	MINPUT
          	LDA 	CALLEXP
          	BNE 	MEXPAND
          	LDX 	#$29
          	JSR 	ERR.0
          	JMP 	ASGOON
;			
MINPUT     	INC 	MACSUPPRS
          	LDA 	PASS
          	BNE 	ASGOONB
          	LDY 	#$00
          	PLA 	
          	STA 	(SCRAT0),Y
          	PLA 	
          	PHA 	
          	INY 	
          	STA 	(SCRAT0),Y
          	DEY 	
          	LDA 	(SCRAT0),Y
          	PHA 	
ASGOONB    	JMP 	ASGOON
;
MEXPAND    	INC 	MACSEQ
          	BNE 	EXPPARMS1
          	INC 	MACSEQ+1
          	BNE 	EXPPARMS1
          	LDX 	#$2E
          	JSR 	ERR.0					;MAC # OVRFLW 
EXPPARMS1  	STX 	CALLEXP
          	STX 	MACSRCH
          	LDA 	CRTEX
          	BEQ 	EXPNOPARM
          	LDA 	CRT,Y
          	CMP 	#'('
          	BEQ 	EXPFETCH 
EXPPRMERR  	LDX 	#$25
          	JSR 	ERR.0					;MACRO PARM MISMATCH 
EXME1     	JMP 	EXME 
;
EXPFETCH   	STX 	SAVEX
          	INY 	
EXPNXTPRM  	JSR 	NXTLETTER
          	CMP 	#$3B					; ';'
          	BEQ 	EXPALL1
          	CPY 	#$50
          	BCS 	EXPALL1
          	CMP 	#')'
          	BEQ 	EXPALL1
          	STY 	SAVEY
          	JSR 	EVLABEX 
          	BCS 	EXPACTUAL
          	LDY 	SAVEY
          	JSR 	NEWLABEL 
          	BCS 	EXME1
EXPACTUAL   STY 	SAVEY
          	LDY 	#$00
          	LDX 	SAVEX
          	LDA 	CRTEX+1 ,X
          	STA 	(SCRAT0),Y
          	INX 	
          	LDA 	CRTEX+1 ,X
          	INX 	
          	INY 	
          	STA 	(SCRAT0),Y
          	LDY 	SAVEY
          	STX 	SAVEX
          	LDX 	#$00
          	DEC 	CRTEX
          	BMI 	EXPPRMERR
          	JSR 	COMP
          	JMP 	EXPNXTPRM
			
EXPALL1    	LDA 	CRTEX
          	BNE 	EXPPRMERR
ASGOONC    	JMP 	ASGOON

EXPNOPARM  	LDA 	CRT,Y
          	CMP 	#$3B					; ';'
          	BEQ 	ASGOONC
          	CPY 	#$50
          	BCS 	ASGOONC
          	BCC 	EXPPRMERR
;			
ME         	LDA 	MACEXPAND
          	BNE 	EXME 
          	STX 	MACSUPPRS
          	JMP 	ASGOON
;
EXME      	STX 	LN2BOUT
          	DEC 	MACEXPAND
          	BMI 	NOMDER
          	BEQ 	MRETURN
          	DEC 	MACSEQ
          	LDA 	MACSEQ
          	CMP 	#$FF
          	BNE 	MRETURN
          	DEC 	MACSEQ+1
MRETURN    	PLA 	
          	PLA 	
          	JMP 	ASGOON
;
NOMDER     	STX 	MACEXPAND
          	LDX 	#$2B
          	JSR 	ERR.0
          	JMP 	ASGOON
;
; break test
;			
BRKTST     	BIT 	SAD			; look at KIM TTY input bit
          	CLC 					; clear carry, no break
          	BMI 	BRKRET			; no break
BRKEND     	BIT 	SAD			
          	BPL 	BRKEND			; wait for end of break 
          	JSR 	GETCH			; get typed character and discard
          	SEC 					; Carry set: it was break
BRKRET     	RTS 	
;
WAIT     	PHA 	
WAIT+1     	PHA 	
WAIT+2     	SBC 	#$01
          	BNE 	WAIT+2
          	PLA 	
          	SBC 	#$01
          	BNE 	WAIT+1
          	PLA 	
          	SBC 	#$01
          	BNE 	WAIT
          	RTS 	
			
LOADER     	LDA 	DISCI
          	BEQ  	TAPELOAD
          	JSR 	DISCLOAD
          	RTS 	
;
DISCLOAD    JMP 	(DISCIVEC)
;
TAPELOAD    JMP 	LOADEXT 
;
INIT     	LDA 	#$00		; load KIM IRQ/BRK vector
          	STA 	IRQVEC 
          	LDA 	#$1C
          	STA 	IRQVEC+1
          	LDA 	CPORTD	; tape motors off
          	ORA 	#$0B
          	STA 	CPORTD
          	RTS 	
; 
 BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 
;			
SAVER   	LDA 	DISCO
          	BEQ 	TAPESAVE
          	JSR 	DISCSAVE
          	RTS 
;			
DISCSAVE   	JMP 	(DISCOVEC)
;
TAPESAVE  	JMP 	SAVEEXT
;
WAITLF     	LDA 	#$1F
          	JSR 	WAIT
          	LDA 	#$0A
          	JSR 	PRINT
          	LDA 	#$1F
          	JSR 	WAIT
          	NOP 	
          	NOP 	
			NOP						; should be RTS					
;			
PRINT     	PHA 	
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	NOP 	
          	JSR 	OUTCH			; KIM TTY in character
          	PLA 	
          	CMP 	#$0D
          	BEQ 	WAITLF			; echo CR with linefeed
          	RTS 	
;			
          	BRK 	
          	BRK 	
          	BRK 	
          	BRK 	
          	.BYTE $22    ;%00100010 '"'
          	BRK 	
          	.BYTE $FF    ;%11111111
          	.BYTE $FF    ;%11111111
          	.BYTE $FF    ;%11111111
;
; fast cassette interface?
;
SAVEEXT     LDA 	CPORTD				; tape motor Data direction
          	ORA 	#$08				; bit 3 cassette out
          	STA 	CPORTD
;
          	LDA 	#SCRAT2
          	STA 	COUNT
LOOPRECST  	LDA 	#$16
          	JSR 	WRITEBYTE
;
          	LDA 	#$10
          	STA 	SYNCCOUNT
LOOPDELSY  	JSR 	OUTZERO
          	DEC 	FORMBYTE
          	BNE 	LOOPDELSY
;
          	DEC 	COUNT
          	BNE 	LOOPRECST
;			
          	JSR 	MOVESTAD			; Start > Address
; 
			LDA		#$0F				; record start char.
          	JSR 	WRITEBYTE
;			
          	LDX 	#$00
          	STX 	CHECKSUM
          	STX 	CHECKSUM+1
			
LOOPDATA   	LDA 	(ADDR,X)
          	JSR 	WRITEBYTE
          	JSR 	INCCOMP
          	BCC 	LOOPDATA
; write checksum
          	LDA 	CHECKSUM+1
          	PHA 	
          	LDA 	CHECKSUM
          	JSR 	WRITEBYTE
          	PLA 	
;
WRITEBYTE   STA 	FORMBYTE
          	JSR 	CHKSUMADD			; update checksum
          	JSR 	OUTONE
          	LDA 	#$08				; 8 bits
          	STA 	BITCOUNT
DATALOOP   	ASL 	FORMBYTE			; shift left into carry
          	BCC 	ZEROBIT
          	JSR 	OUTONE
          	BEQ 	CKENDBY
ZEROBIT    	JSR 	OUTZERO
CKENDBY    	DEC 	BITCOUNT
          	BNE 	DATALOOP
;
; output a zero to tape
;
OUTZERO     LDA 	#$20
;
; write to tape
;
WRITE     	PHA 	
          	LDA 	CPORT
          	ORA 	#$08				; Out a '1' on bit 3
          	STA 	CPORT
          	PLA 	
          	PHA 	
          	TAX 	
          	JSR 	LOOPD
          	LDA 	CPORT
          	AND 	#$F7				; Out a '0 on bit 3
          	STA 	CPORT
          	PLA 	
          	TAX 						; delay constant	
LOOPD     	DEX 	
          	BNE 	LOOPD
          	RTS 	
;
;
;
OUTONE     	LDA 	#$50
          	BNE 	WRITE
;	
;	Delay for '0 time for read
;
READDELAY     	LDX 	#$30
          	BNE 	LOOPD
;
; Move from Start Address to ADDR
;
MOVESTAD    LDA  	START 
          	STA 	ADDR
          	LDA 	START+1
          	STA 	ADDR+1
          	RTS 	
			
INCCOMP    	INC 	ADDR
          	BNE 	SKIPINC
          	INC 	ADDR+1
SKIPINC    	LDA 	ADDR+1
          	CMP 	END+1
          	BCC 	NOTEND
          	LDA 	ADDR
          	CMP 	END
          	BCC 	NOTEND
          	SEC 	
NOTEND     	RTS 	
;
; Read from tape to (start) to (end)
;
LOADEXT     LDX 	#$00
          	STX 	COUNT
LOOPLOAD 	JSR 	READBYTE
          	CMP 	#$16					; sync
          	BNE 	SKIP1
          	INC 	COUNT
          	BNE 	LOOPLOAD
;			
SKIP1     	LDY 	COUNT
          	CPY 	#$0A					; must be more than 10 syncs
          	BCC 	LOADEXT 
          	CMP 	#$0F					; record start?
          	BNE 	LOADEXT 
          	LDY 	#$00
          	STY 	CHECKSUM
          	STY 	CHECKSUM+1
          	JSR 	MOVESTAD
;
; Now load data
;			
LOOP69     	JSR 	READBYTE
          	LDY 	LOADNO 
          	BEQ 	SKIPSTORE
          	STA 	(ADDR,X)
SKIPSTORE  	JSR 	INCCOMP
          	BCC 	LOOP69
          	LDA 	CHECKSUM+1
          	PHA 	
          	LDA 	CHECKSUM
          	PHA 	
          	JSR 	READBYTE
          	PLA 	
          	CMP 	FORMBYTE				; check checksum
          	BNE 	RETURN
          	JSR 	READBYTE
          	PLA 	
          	CMP 	FORMBYTE
          	RTS 	
RETURN     	PLA 	
          	LDA 	#$FF					; clear Z 
          	RTS 	
;
; Read a byte form tape
;
READBYTE   	JSR 	INPORT
          	BNE 	READBYTE
WAITFOR1   	JSR 	INPORT
          	BEQ 	WAITFOR1				; loop until 1
;			
          	JSR 	READDELAY
          	JSR 	INPORT
          	BEQ 	WAITFOR1
;
WAITFOR0   	JSR 	INPORT
          	BNE 	WAITFOR0				; wait till end of start bit
          	LDA 	#$08
          	STA 	BITCOUNT
;			
WAITTOON   	JSR 	INPORT
          	BEQ 	WAITTOON				; loop unitl 1
          	JSR 	READDELAY
          	JSR 	INPORT
          	BEQ 	PROCESS0				; if '0' then zero else one
PROCESS1   	JSR 	INPORT
          	BNE 	PROCESS1				; loop until '0'
          	SEC 	
          	BCS 	ROTATEIN
PROCESS0   	CLC 	
ROTATEIN    ROL 	FORMBYTE				; rotate carry
          	DEC 	BITCOUNT
          	BNE 	WAITTOON
          	LDA 	FORMBYTE
          	JSR 	CHKSUMADD
          	LDA 	FORMBYTE
          	RTS 	
;
; input from tape
;
          	LDA 	CPORT
          	AND 	#$04
          	RTS 	
;
; Update checksum
;
CHKSUMADD   CLC 	
          	CLD 	
          	ADC 	CHECKSUM
          	STA 	CHECKSUM
          	LDA 	#$00
          	ADC 	CHECKSUM+1
          	STA 	CHECKSUM+1 
          	RTS 	
;
LOADENTRY  	JSR 	LOADEXT 
          	BNE 	BAD
          	LDA 	#$00
B     		BRK 	
          	NOP 	
          	NOP 	
          	JMP 	LOADENTRY
BAD     	LDA 	#$EE
			BNE 	B

RECORDENT  	JSR 	SAVEEXT
          	BRK 	
          	NOP 	
          	NOP 	
          	JMP 	RECORDENT
;
INPORT     	LDA 	CPORT
          	AND 	#$FF
          	AND 	#$04
          	RTS 	
;
          	.END	