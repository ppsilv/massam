.setcpu "6502"



;Block 0
;------------------------------------
;Zero page general-purpose addresses
;("extra registers" to augment A, X, Y)

B = $00
C = $01
D = $02
E = $03
F = $04
G = $05
H = $06
I = $07
J = $08
K = $09
L = $0a
M = $0b
N = $0c
O = $0d
P = $0e
Q = $0f


;;*
;Block 1
;------------------------------------
;Pointers, flags, and counters for keyboard, video, UART, and monitor
;*;
kb_read_ptr = $10							;; one byte
kb_write_ptr = $11							;; one byte
kb_flags = $12								;; one byte
vid_ptr = $13 								;; two bytes
;;; $14
cursor_blink_count = $15 					;; one byte
txt_ptr = $16 								;; two bytes
;;; $17
vid_flags = $18 								;; one byte
mon_addr = $19 								;; two bytes
;;; $1a
mon_arg1 = $1b 								;; two bytes
;;; $1c
uart_flags = $1d								;; one byte
irq_addr = $1e 								;; two bytes
;;; $1f

;;*
;Block 2
;------------------------------------
;Keyboard buffer
;*;
kb_buffer = $20    							;; 16 bytes


;;*
;Block 3
;------------------------------------
;Assorted stashes and pointers
;*;
cg_0 = $30
cg_1 = $31
read_ptr = $32
;;; $33
write_ptr = $34
;;; $35
counter = $36
;;; $37 


;;*
;Block 4
;------------------------------------
;Storage for ssd
;*;
ssd_write_addr = $40							;; two bytes
;;; $41
ssd_sector = $42								;; one byte
ssd_read_addr = $43 							;; two bytes
;;; $44
ssd_pages_filled = $45 						;; one byte



;*
;Blocks 5, 6
;------------------------------------
;Storage for SID
;
track1_notes_addr = $50 						;; two bytes
;; $51
track2_notes_addr = $52 						;; two bytes
;; $53
track3_notes_addr = $54 						;; two bytes
;; $55
track1_lengths_addr = $56 					;; two bytes
;; $57
track2_lengths_addr = $58 					;; two bytes
;; $59
track3_lengths_addr = $5a 					;; two bytes
;; $5b
track1_insts_addr = $5c 						;; two bytes
;; $5d
track2_insts_addr = $5e 						;; two bytes
;; $5f
track3_insts_addr = $60 						;; two bytes
;; $61
