; configuration
CONFIG_2A := 2

CONFIG_SCRTCH_ORDER := 2
;
;; zero page
ZP_START1 = $00
ZP_START2 = $0A
ZP_START3 = $60
ZP_START4 = $6B
;
USR	:= GORESTART ; XXX
;
;; inputbuffer
;INPUTBUFFER     := $0200
;
; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP		:= $FA
WIDTH			:= 40
WIDTH2			:= 30
RAMSTART2		:= $0400

ISCNTC	:= $FFE1 


