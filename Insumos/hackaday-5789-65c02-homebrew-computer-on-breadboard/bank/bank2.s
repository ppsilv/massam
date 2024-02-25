	include "kernel\kernel.s"
	
; Bank specific code goes here
	include "sdcard\sdcard.s"
	include "sdcard\sd_fs.s"
	include "monitor\cmd.s"

	; End of Code
_code_end
