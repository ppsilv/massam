	include "kernel\kernel.s"
	
; Bank specific code goes here
	include "cia\cia.s"
	include "serial\serial.s"
	include "keyboard\keyboard.s"
	include "sound\sound.s"
	include "vdp\vdp.s"
	include "vdp\graph.s"
	; End of Code
_code_end
