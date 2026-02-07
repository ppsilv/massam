;SOURCE = $1000
;DEST   = $2000
;LENGHT: .res 2
;FROM   = ADDR1L
;TO     = ADDR2L

CMD_CP_BLOCK:
        ;    ;Load address from
        ;    LDA     #<SOURCE
        ;    STA     FROM 
        ;    ;JSR     PRBYTE
;
        ;    LDA     #>SOURCE
        ;    STA     FROM+1
        ;    ;JSR     PRBYTE
        ;    ;Load address to
        ;    LDA     #<DEST
        ;    STA     TO
        ;    ;JSR     PRBYTE
;
        ;    LDA     #>DEST
        ;    STA     TO+1
        ;    ;JSR     PRBYTE
            
            STA     LAST_CMD
            LDA     #<MSG8
            STA     MSGL
            LDA     #>MSG8
            STA     MSGH
            JSR     SHWMSG
            JSR     GETLINE

            JSR     FORMAT_ADDRESS
            JSR     FORMAT_16BITS_DATA

            ;Load how many blocks to copy
            LDX     #>LENGHT 
            ;Block size
            BEQ     REMAIN      ;Handle < $100
            LDY     #$FF        ;Copy from top
            ;Do it
NEXT:       
            LDA     (FROM),Y    ;Read element
            STA     (TO),Y      ;Save it to destiny
            DEY                 ;Update pointer
            CPY     #$FF        ;Dowm to 0
            BNE     NEXT        ;Finished?
NEXTBLK:
            INC     FROM+1      ;Increment block pointer FROM
            INC     TO+1        ;Same to pointer TO
            DEX                 ;Block counter
            BMI     DONE 
            BNE     NEXT
REMAIN:
            LDY     #<LENGHT    ;Add remain lable
            BEQ     DONE        ;handle no remain
            DEY                 ;Fix extra byte bug
            BNE     NEXT        
DONE:
            JMP     NEXT_CHAR



