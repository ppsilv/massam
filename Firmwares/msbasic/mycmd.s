.segment "CODE"

MYCMD:
    LDA     #<MSG1
    STA     MSGL
    LDA     #>MSG1
    STA     MSGH
    JSR     SHWMSG    
    LDA     #$07
    JSR     PRBYTE
    RTS    

DUMP:
dump:
       ; LDA     FLAGECHO
       ; EOR     #$FF
       ; STA     FLAGECHO

        LDA     #$A5            ;MAGIC NUMBER TO INDICATE TO BIOSMON THAT IT WAS CALLED FROM BASIC
        STA     FLAGBASIC
        JSR     DIGITOU_D

        ;LDA     FLAGECHO
        ;EOR     #$FF
        ;STA     FLAGECHO
        rts