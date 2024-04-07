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
        JSR     DIGITOU_D
        rts