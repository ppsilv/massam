.setcpu "6502"
.debuginfo
.segment "BIOS"

LOAD:
	rts
SAVE:
	rts

.include "uart.s"
.include "delay.s"
.include "wozmon.s"
