;Fonte from Kiran cornel edu

; VIA addresses
PORTA = $7801
PORTB = $7800
DDA = $7803
DDB = $7802
PCR = $780c
IFR = $780d
IER = $780e

; VIA Port B bits
E  = %00001000
RW = %00000100
RS = %00000010

; VIA interrupt bits
CA1 = %00000010
IE = %10000000
CA1_RISING = %00000001

; LCD instructions
FUNCTION_SET_0 = %00100000
FUNCTION_SET = %00101000
DISPLAY_ON = %00001110
ENTRY_MODE = %00000110
CLEAR_DISPLAY = %00000001
CURSOR_RIGHT = %00010100
CURSOR_LEFT = %00010000
SCROLL_RIGHT = %00011100
SCROLL_LEFT = %00011000
RETURN_HOME = %00000010
SET_ADDR = %10000000

; keyboard flags
R_SHIFT_DOWN = %00000001
L_SHIFT_DOWN = %00000010
RELEASE_NXT = %00000100
EXTENDED_NXT = %00001000

; keyboard scancodes
K_RELEASE = $f0
K_ESC = $76
K_BACKSPACE = $66
K_CAPS_LOCK = $58
K_ENTER = $5a
K_L_SHIFT = $12
K_R_SHIFT = $59
K_F11 = $78
K_F12 = $07

K_EXTENDED = $e0
KX_DOWN = $72
KX_UP = $75
KX_LEFT = $6b
KX_RIGHT = $74

; Zero page addresses

NUM1 = $00                          ; two bytes
NUM2 = $02                          ; two bytes
REM = $04                           ; two bytes
NUM_TO_DEC = $06                    ; two bytes
DEC_REVERSE = $08                   ; five bytes
KB_READ_PTR = $0d                   ; one byte
KB_WRITE_PTR = $0e                  ; one byte
KB_FLAGS = $0f                      ; one byte
NIBBLE_STASH = $10                  ; one byte


KB_BUFFER = $f0                     ; sixteen bytes (f0-ff)

; other RAM addresses


  .org $8000                          ; ROM starts at address $8000

reset
  cli
  cld

  lda #CA1_RISING                 ; keyboard interrupt on rising edge
  sta PCR

  lda #(CA1  IE)                 ; enable interrupts on CA1 (keyboard)
  sta IER

  lda #%11111110                  ; setup LCD pins as output
  sta DDB

  lda #%00000000                  ; setup kb pins as input
  sta DDA

  lda #FUNCTION_SET_0             ; tell LCD to use 4 bit mode
  sta PORTB
  eor #E
  sta PORTB
  eor #E
  sta PORTB

  lda #FUNCTION_SET
  jsr lcd_instruction

  lda #CLEAR_DISPLAY
  jsr lcd_instruction

  lda #ENTRY_MODE
  jsr lcd_instruction

  lda #DISPLAY_ON
  jsr lcd_instruction

  lda #0
  sta KB_FLAGS
  sta KB_READ_PTR
  sta KB_WRITE_PTR

loop
  sei
  lda KB_READ_PTR
  cmp KB_WRITE_PTR
  cli
  bne key_pressed
  jmp loop


f11_pressed
  lda #SCROLL_RIGHT
  jsr lcd_instruction             ; send scroll right instruction
  jmp update_read_ptr

f12_pressed
  lda #SCROLL_LEFT
  jsr lcd_instruction             ; send scroll left instruction
  jmp update_read_ptr


key_pressed
  ldx KB_READ_PTR
  ldy KB_BUFFER,x                 ; load scancode into Y

  cpy #K_EXTENDED                 ; check for the extended scancode
  beq extended_pressed

  cpy #K_RELEASE                  ; check for the release scancode
  beq key_release_byte

  lda #RELEASE_NXT                ; check if this scancode is for a released key
  and KB_FLAGS
  bne key_released

  lda #EXTENDED_NXT               ; check if this is an extended key press
  and KB_FLAGS
  bne x_key_pressed_jmp

  cpy #K_L_SHIFT                  ; check for left shift press
  beq l_shift_pressed

  cpy #K_R_SHIFT                  ; check for right shift press
  beq r_shift_pressed

  cpy #K_ESC                      ; check for esc press
  beq esc_pressed

  cpy #K_ENTER                    ; check for enter press
  beq enter_pressed

  cpy #K_BACKSPACE                ; check for backspace
  beq backspace_pressed

  cpy #K_F11                      ; check for F11
  beq f11_pressed

  cpy #K_F12                      ; check for F12
  beq f12_pressed

  lda #(R_SHIFT_DOWN  L_SHIFT_DOWN)
  and KB_FLAGS                    ; check if either shift is down
  bne shift_down

  lda keymap,y                    ; load corresponding ascii into A
  jsr lcd_write                   ; write the pressed key
  jmp update_read_ptr

shift_down
  lda keymap_shifted,y            ; load shifted ascii into A
  jsr lcd_write                   ; write the pressed key
  jmp update_read_ptr

set_kb_flag
  ora KB_FLAGS
  sta KB_FLAGS

update_read_ptr
  inx
  cpx #16
  bcc exit_key_pressed            ; if KB_READ_PTR reached 16, reset to 0
  ldx #0

exit_key_pressed
  stx KB_READ_PTR                 ; update KB_READ_PTR
  jmp loop


x_key_pressed_jmp
  jmp x_key_pressed               ; long range jump to fix branch out of range


extended_pressed
  lda #EXTENDED_NXT
  jmp set_kb_flag


key_release_byte
  lda #RELEASE_NXT
  jmp set_kb_flag


key_released
  lda KB_FLAGS
  and #EXTENDED_NXT
  bne exit_key_released           ; if we're releasing an extended key, don't check shift release

  cpy #K_L_SHIFT
  beq l_shift_released

  cpy #K_R_SHIFT
  beq r_shift_released

exit_key_released
  lda KB_FLAGS
  eor #RELEASE_NXT                ; flip release next bit, since we're handling it
  and #(~EXTENDED_NXT)            ; zero out the extended next bit
  sta KB_FLAGS

  jmp update_read_ptr


l_shift_pressed
  lda #L_SHIFT_DOWN
  jmp set_kb_flag


r_shift_pressed
  lda #R_SHIFT_DOWN
  jmp set_kb_flag


esc_pressed
  jmp reset


backspace_pressed
  lda #CURSOR_LEFT
  jsr lcd_instruction

  lda # 
  jsr lcd_write

  lda #CURSOR_LEFT
  jsr lcd_instruction

  jmp update_read_ptr

enter_pressed
  lda #SET_ADDR
  clc
  adc #40                         ; set the LCD addr to 40
  jsr lcd_instruction

  jmp update_read_ptr


l_shift_released
  lda KB_FLAGS
  eor #L_SHIFT_DOWN
  sta KB_FLAGS
  jmp exit_key_released

r_shift_released
  lda KB_FLAGS
  eor #R_SHIFT_DOWN
  sta KB_FLAGS
  jmp exit_key_released


x_key_pressed
  lda KB_FLAGS
  and #(~EXTENDED_NXT)
  sta KB_FLAGS                    ; clear the extended flag

  cpy #KX_DOWN
  beq down_pressed

  cpy #KX_UP
  beq up_pressed

  cpy #KX_RIGHT
  beq right_pressed

  cpy #KX_LEFT
  beq left_pressed

  jmp update_read_ptr

down_pressed
  jsr lcd_read_addr               ; load current LCD addr into A
  cmp #$40
  bcs return_from_press           ; if address is $40 or greater, do nothing
  adc #$40                        ; otherwise, add $40 -- we know carry bit is clear
  ora #SET_ADDR
  jsr lcd_instruction             ; send set_addr with new address
return_from_press
  jmp update_read_ptr

up_pressed
  jsr lcd_read_addr               ; load current LCD addr into A
  cmp #$40
  bcc return_from_press           ; if address if $40 or more, do nothing
  sbc #$40                        ; new address should be current address - 40 -- we know carry bit is set
  ora #SET_ADDR
  jsr lcd_instruction             ; send set_addr to new address
  jmp update_read_ptr

right_pressed
  lda #CURSOR_RIGHT
  jsr lcd_instruction             ; send cursor right instruction
  jmp update_read_ptr


left_pressed
  lda #CURSOR_LEFT
  jsr lcd_instruction             ; send cursor left instruction
  jmp update_read_ptr


divide                             ; divide two-byte NUM1 by two-byte NUM2. result goes in NUM1, remainder in REM
  pha
  phx
  phy

  ldx #16                         ; counter for bits to rotate
  lda #0                          ; initialize remainder to zero
  sta REM
  sta REM+1

div_loop
  asl NUM1                        ; rotate zero into low bit of result, rotate into remainder
  rol NUM1+1
  rol REM
  rol REM+1

  sec                 ; set carry bit for borrowing, try subtracting num2 from remainder
  lda REM
  sbc NUM2
  tay
  lda REM+1
  sbc NUM2+1

  bcc div_after_save              ; if carry bit is clear, subtraction failed
  sty REM                         ; if subtraction succeeded, save sub result and set bit of division result to 1
  sta REM+1
  inc NUM1

div_after_save
  dex                 ; loop until x = 0 (16 times for two-byte division)
  bne div_loop

  ply
  plx
  pla
  rts

lcd_read_addr                      ; read the LCD address counter into A
  lda #%00001110                  ; setup LCD data bits as input
  sta DDB

  lda #RW                         ; tell LCD to send data
  sta PORTB
  lda #(RW  E)                   ; send enable bit to read high nibble
  sta PORTB
  lda PORTB                       ; read response
  and #%01110000                  ; zero out low nibble and busy flag
  sta NIBBLE_STASH                ; stash high nibble

  lda #RW
  sta PORTB
  lda #(RW  E)                   ; toggle enable bit to read low nibble
  sta PORTB
  lda PORTB
  ror
  ror
  ror
  ror
  and #%00001111                  ; shift low nibble and zero out high nibble
  ora NIBBLE_STASH                ; combine with stashed high nibble

  rts

lcd_wait
  pha
  phx
  lda #%00001110                  ; setup LCD data bits as input
  sta DDB

lcd_busy
  lda #RW                         ; tell LCD to send data
  sta PORTB

  lda #(RW  E)                   ; send enable bit
  sta PORTB

  lda PORTB                       ; read response
  tax                 ; stash for second read

  lda #RW
  sta PORTB
  lda #(RW  E)                   ; toggle enable bit, ignore read
  sta PORTB
  lda PORTB

  txa
  and #%10000000                  ; check the busy flag
  bne lcd_busy                    ; if busy flag set, loop

  lda #RW
  sta PORTB

  lda #%11111110                  ; setup LCD pins as output
  sta DDB

  plx
  pla
  rts

lcd_instruction                    ; sends the byte in register A
  jsr lcd_wait
  pha                 ; store on stack
  and #%11110000                  ; discard low nibble

  sta PORTB
  eor #E                          ; toggle enable bit on
  sta PORTB
  eor #E                          ; toggle enable bit off
  sta PORTB

  pla                 ; reload to send low nibble
  asl
  asl
  asl
  asl
  and #%11110000

  sta PORTB
  eor #E                          ; toggle enable bit on
  sta PORTB
  eor #E                          ; toggle enable bit off
  sta PORTB

  rts


lcd_write                          ; write the contents of A
  jsr lcd_wait
  pha                 ; store on stack
  and #%11110000                  ; discard low nibble
  ora #RS                         ; turn RS bit on to write

  sta PORTB
  eor #E                          ; toggle enable bit on
  sta PORTB
  eor #E                          ; toggle enable bit off
  sta PORTB

  pla                 ; reload to send low nibble
  asl
  asl
  asl
  asl
  and #%11110000
  ora #RS                         ; turn RS bit on to write

  sta PORTB
  eor #E                          ; toggle enable bit on
  sta PORTB
  eor #E                          ; toggle enable bit off
  sta PORTB

  rts


lcd_write_dec                      ; write the number at NUM_TO_DEC (two bytes) in decimal
  pha
  phx
  ldx #0

  lda NUM_TO_DEC
  sta NUM1
  lda NUM_TO_DEC+1
  sta NUM1+1

store_dec_loop
  lda #10
  sta NUM2
  lda #0
  sta NUM2+1

  jsr divide                      ; divide NUM1 by 10

  lda REM
  clc
  adc #0                        ; convert to ASCII code
  sta DEC_REVERSE,x               ; store digits in reverse order
  inx

  lda NUM1                        ; check if result is 0
  ora NUM1+1

  bne store_dec_loop              ; if not, divide again
  dex

write_dec_loop
  lda DEC_REVERSE,x               ; write digits in reverse order
  jsr lcd_write
  dex
  bpl write_dec_loop

  plx
  pla
  rts


lcd_write_hex                      ; write the number in reg A to the LCD

  phx

  tax                 ; stash in X

  ror
  ror
  ror
  ror
  and #%00001111                  ; pick out high nibble

  cmp #$0a
  bcc hi_nibble_num               ; branch if high nibble is number

  clc
  adc #(A-10)                   ; set A to ascii letter (
  jmp write_hi_nibble

hi_nibble_num
  clc
  adc #0                        ; set A to ascii number

write_hi_nibble
  jsr lcd_write                   ; write the high nibble of number

  txa
  and #%00001111                  ; pick out low nibble

  cmp #$0a
  bcc lo_nibble_num               ; branch if low nibble is number

  clc
  adc #(A-10)                   ; set A to ascii letter
  jmp write_lo_nibble

lo_nibble_num
  clc
  adc #0                        ; set A to ascii number

write_lo_nibble
  jsr lcd_write                   ; write the low nibble of number

  plx

  rts

irq
  pha
  phx
  lda PORTA                       ; read scancode
  ldx KB_WRITE_PTR

  sta KB_BUFFER,x                 ; store keyboard scancode in buffer

  inx
  cpx #16
  bcc exit_irq                    ; if KB_WRITE_PTR reached 16, reset to 0
  ldx #0

exit_irq
  stx KB_WRITE_PTR                ; update KB_WRITE_PTR
  plx
  pla
  rti

keymap
  .byte  `            ; 00-0F
  .byte q1zsaw2            ; 10-1F
  .byte cxde43 vftr5            ; 20-2F
  .byte nbhgy6mju78            ; 30-3F
  .byte ,kio09.l;p-            ; 40-4F
  .byte '[=]            ; 50-5F
  .byte 147            ; 60-6F
  .byte 0.2568+3-9            ; 70-7F
  .byte             ; 80-8F
  .byte             ; 90-9F
  .byte             ; A0-AF
  .byte             ; B0-BF
  .byte             ; C0-CF
  .byte             ; D0-DF
  .byte             ; E0-EF
  .byte             ; F0-FF
keymap_shifted
  .byte  ~            ; 00-0F
  .byte Q!ZSAW@            ; 10-1F
  .byte CXDE#$ VFTR%            ; 20-2F
  .byte NBHGY^MJU&            ; 30-3F
  .byte KIO)(LP_            ; 40-4F
  .byte '{+}' ; 50-5F
  .byte 147 ; 60-6F
  .byte 0.2568+3-9 ; 70-7F
  .byte  ; 80-8F
  .byte  ; 90-9F
  .byte  ; A0-AF
  .byte  ; B0-BF
  .byte  ; C0-CF
  .byte  ; D0-DF
  .byte  ; E0-EF
  .byte  ; F0-FF


  .org $fffc                               ; the CPU reads address $fffc to read start of program address
  .word reset                               ; reset address
  .word irq                                 ; IRQ handler address