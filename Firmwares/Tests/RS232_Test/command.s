
clr:
	;ESC [ 2 J
	lda	#$1b		
	jsr write_byte
	lda	#'['
	jsr write_byte
	lda	#'2'
	jsr write_byte
	lda	#'J'
	jsr write_byte
    rts

sc:
	ldx #<showCmd
	ldy #>showCmd
	jsr PrintString
    rts
showCmd:
	.byte	CR,LF,"Commands Version 0.1.0",CR,LF
	.byte	"?..............: Show this help",CR,LF
	.byte	"C..............: Clear screen",CR,LF
	.byte	"M,<addr>.......: Set memory addr",CR,LF
	.byte	"S,<addr>.......: Show memory addr",CR,LF
	.byte	"P,<addr>,data..: Poke data int addr memory",CR,LF
	.byte	"R,<addr>.......: Run program at memory addr",CR,LF,0
	;;.byte	"All address must be in hexadecimal $0000 to $FFFF",CR,LF
pk:
	jsr	read_line
	ldy	#0
READ_CMD:	
	lda (CMD_BUF),y
	cmp #$0d
	beq	fim_read_cmd
	jsr write_byte
	iny
	cpy #13
	bne READ_CMD
	lda #$0d
fim_read_cmd:
	jsr write_byte
    rts
