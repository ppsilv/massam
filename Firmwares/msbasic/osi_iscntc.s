.segment "CODE"
;;ISCNTC:
;;        lda     $D011           ; keyboard status
;;        bmi     L0ECC           ; branch if key pressed
;;        rts                     ; return
;;L0ECC:
;;        lda     $D010           ; get key data
;;        cmp     #$83            ; is it Ctrl-C ?

ISCNTC:
        lda     $7805           ; keyboard status
        CMP     #$01
        BEQ     L0ECC           ; branch if key pressed
        rts                     ; return
L0ECC:
        lda     $7800           ; get key data
        cmp     #$3            ; is it Ctrl-C ?



;;;!!! *used*to* run into "STOP"
;;ISCNTC:
;;        JSR     MONRDKEY
;;        CMP     #3
;;        BNE     NOT_CNTC
;;        JMP     IS_CNTC
;;NOT_CNTC:
;;        rts
;;
;;IS_CNTC:
        ; Fall trough 
