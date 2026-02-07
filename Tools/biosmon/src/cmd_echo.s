DIGITOU_AST:
                LDA     #<MSG10
                STA     MSGL
                LDA     #>MSG10
                STA     MSGH
                JSR     SHWMSG 
                LDA     FLAGECHO
                EOR     #$FF
                STA     FLAGECHO
                JMP     NEXT_CHAR    
