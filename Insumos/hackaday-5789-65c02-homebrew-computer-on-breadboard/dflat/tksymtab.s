;**********************************************************
;*
;*	BBC-128 HOMEBREW COMPUTER
;*	Hardware and software design by @6502Nerd (Dolo Miah)
;*	Copyright 2014-20
;*  Free to use for any non-commercial purpose subject to
;*  appropriate credit of my authorship please!
;*
;*  TKSYMTAB.S
;*  Runtime token jump table.
;*  dflat uses four key tables to tokenise and run programs:
;*  - df_tokensyms    - table of token symbols
;*  - df_tk_tokentype - table of token types
;*  - df_tk_tokenjmp  - table of tokenising routines
;*  - df_rt_tokenjmp  - table of runtime routines
;*  The key is the token symbols.  When a line is entered
;*  in to the raw (untokenised) buffer, df_tokensyms is
;*  used to identify tokens.  The position of the found
;*  token is used to then look up type and jump vectors
;*  in the other tables.
;*
;**********************************************************

	; ROM code
	code  

; Statement Token table
; keywords
df_tokensyms
	db	0x80						; Implicit numeric assign
	db	0x80						; Implicit call procedure
	db	";"+0x80					; Comment
	db	"printl",'n'+0x80			; println exprlist
	db	"printa",'t'+0x80			; printat x,y,exprlist
	db	"prin",'t'+0x80				; print exprlist
	db	"de",'f'+0x80				; def_subname
	db	"endde",'f'+0x80			; enddef
	db	"retur",'n'+0x80			; return
	db	"abor",'t'+0x80				; abort
	db	"loca",'l'+0x80				; local varlist
	db	"di",'m'+0x80				; dim varlist
	db	"repea",'t'+0x80			; repeat
	db	"unti", 'l'+0x80			; until condition
	db	"fo",'r'+0x80				; for var=start,end,increment
	db	"nex",'t'+0x80				; next
	db	"whil",'e'+0x80				; while condition
	db	"wen",'d'+0x80				; wend
	db	"i",'f'+0x80				; if condition
	db	"els",'e'+0x80				; else
	db	"endi",'f'+0x80				; endif
	db	"eli",'f'+0x80				; elif condition
	db	"dat",'a'+0x80				; data
	db	'.'+0x80					; assembler command
	db	"ru",'n'+0x80				; run
	db	"lis",'t'+0x80				; list _proc-|*|line,line
	db	"inpu",'t'+0x80				; input var
	db	"mod",'e'+0x80				; mode n
	db	"plo",'t'+0x80				; plot x,y,char|string
	db	"curso",'r'+0x80			; cursor n
	db	"cl",'s'+0x80				; cls
	db	"vpok",'e'+0x80				; vpoke addr,val
	db	"setvd",'p'+0x80			; setvdp reg,val
	db	"colou",'r'+0x80			; colour reg,val
	db	"spritepa",'t'+0x80			; spritepat patnum,array
	db	"spritepo",'s'+0x80			; spritepos sprnum,x,y
	db	"spriteco",'l'+0x80			; spritecol sprnum,col
	db	"spritenm",'e'+0x80			; spritenme sprnum,patnum
	db	"sprit",'e'+0x80			; sprite n,x,y,p,c
	db	"pok",'e'+0x80				; poke a,v
	db	"dok",'e'+0x80				; doke a,v
	db	"soun",'d'+0x80				; sound
	db	"musi",'c'+0x80				; music
	db	"pla",'y'+0x80				; play
	db	"sav",'e'+0x80				; save
	db	"loa",'d'+0x80				; load
	db	"di",'r'+0x80				; dir
	db 	"de",'l'+0x80				; del
	db	"rea",'d'+0x80				; read
	db	"ne",'w'+0x80				; new
	db	"renu",'m'+0x80				; renum start,offset,increment
	db	"wai",'t'+0x80				; wait delay
	db	"rese",'t'+0x80				; reset var
	db	"hire",'s'+0x80				; hires col
	db	"poin",'t'+0x80				; point x,y,mode
	db	"lin",'e'+0x80				; line x0,y0,x1,y1
	db	"hplo",'t'+0x80				; hplot x,y,char|string
	db	"pixmod",'e'+0x80			; pixmode n
	db	"pixmas",'k'+0x80			; pixmask n
	db	"pixco",'l'+0x80			; pixcol n
	db	"bo",'x'+0x80				; box x0,y0,x1,y1
	db	"circl",'e'+0x80			; circle x0,y0,r
	db	"shap",'e'+0x80				; shape x,y,coords[]
	db	"vloa",'d'+0x80				; vload addr,filename
	db	"bloa",'d'+0x80				; bload mem,hrd,addr,filename
	db	"bsav",'e'+0x80				; bsave mem,hdr,addr,len,filename
	db	"hime",'m'+0x80				; himem addr
	db	"monito",'r'+0x80			; monitor
	db	"chdi",'r'+0x80				; chdir fname
; Functions
	db	"vpeek",'('+0x80			; vpeek(x)
	db	"peek",'('+0x80				; peek(x)
	db	"deek",'('+0x80				; peek(x)
	db	"stick",'('+0x80			; stick(x)
	db	"key",'('+0x80				; key(x)
	db	"chr",'('+0x80				; chr(x)
	db	"left",'('+0x80				; left(x$,y)
	db	"right",'('+0x80			; right(x$,y)
	db	"mid",'('+0x80				; mid(x$,y)
	db	"len",'('+0x80				; len(x$)
	db	"mem",'('+0x80				; mem(x)
	db	"scrn",'('+0x80				; scrn(x,y)
	db	"rnd",'('+0x80				; rnd(x)
	db	"elapsed",'('+0x80			; elapsed(var)
	db	"call",'('+0x80				; call(addr,A,X,Y)
	db	"hex",'('+0x80				; hex(x)
	db	"asc",'('+0x80				; asc(x$)
	db	"val",'('+0x80				; val(x$)
	db	"msbyte",'('+0x80			; msbyte(x)
	db	"lsbyte",'('+0x80			; lsbyte(x)
; Numeric operators, in priority
	db	'*'+0x80					; Multiply
	db 	'/'+0x80					; Divide
	db 	'\\'+0x80					; Modulus
	db	'<','<'+0x80				; Shift left
	db	'>','>'+0x80				; Shift right
	db 	'+'+0x80					; Add
	db	'-'+0x80					; Subtract
; Conditional operators, in priority
	db "an",'d'+0x80				; AND
	db "o",'r'+0x80					; OR
	db "<",'='+0x80					; Less than or equal
	db ">",'='+0x80					; Greater than or equal
	db "<",'>'+0x80					; Not equal
	db '<'+0x80						; Less than
	db '>'+0x80						; Greater than
	db "=",'='+0x80					; Equality (always last)
; String conditional operators, in priority
	db "$",'+'+0x80					; String cat
	db "$<",'='+0x80				; Less than or equal
	db "$>",'='+0x80				; Greater than or equal
	db "$<",'>'+0x80				; Not equal
	db "$",'<'+0x80					; Less than
	db "$",'>'+0x80					; Greater than
	db "$=",'='+0x80				; Equality (always last)

	db  0


	
	