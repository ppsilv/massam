           = $2000
          JMP L2010
          JMP L20AC
          BIT $D436
          SEC
          .BYTE $47    ;%01000111 'G'
          .BYTE $3C    ;%00111100 ''
          .BYTE $4B    ;%01001011 'K'
          BIT $CF
          .BYTE $33    ;%00110011 '3'
L2010     LDX #$FF
          TXS
          INX
          STX $AC
          STX $AD
          STX $0113
          STX $E3
          STX $011F
          LDA #$17
          NOP
          JSR L360B
          NOP
          NOP
          NOP
          NOP
          NOP
          JSR L3FA6
          LDA #$01
          STA $0120
          STA $0121
          STA $010F
          STA $DB
          STX $010C
          STX $010D
          STX $010E
          LDY #$47
          JSR L252C
          LDA #$0B
          STA $EA
L204D     JSR L2094
          STX $0128
          JSR L3B14
L2056     JSR L332F
          JSR L3338
L205C     LDX #$00
L205E     CLD
          NOP
          NOP
          NOP
          LDA #$00
          NOP
          NOP
          NOP
          STA $0113
          STA $0133
          JSR L33EA
L2070     LDX #$FF
          STX $0112
          STX $0111
          TXS
          INX
          STX $0114
          STX $0115
          JSR L2262
          LDY #$00
          JSR L2510
          CPY #$50
          BCS L2070
          JSR L269E
          LDX #$ED
          JMP L244B
L2094     LDA $0100
          STA $D3
          LDA $0101
          STA $D4
L209E     TXA
          LDY #$02
          STA ($D3),Y
          RTS
L20A4     LDA #$80
          NOP
          NOP
          NOP
          BRK
          NOP
          NOP
L20AC     JSR L3B14
          JMP L205C
          LDX #$0C
          JSR L22E4
          JMP L205E
          JSR L3469
          JMP L205C
          JSR L2690
          STA $010F
          CMP #$43
          BNE L20CD
          STX $010F
L20CD     JSR L250D
          CPY #$50
          BCS L20E7
          STX $0111
          LDA #$01
          STA $0113
          JSR L3260
          INC $D1
          LDA $D1
          AND #$1F
          STA $EA
L20E7     JMP L205E
          JSR L2690
          STA $010E
          CMP #$43
          BNE L20F7
          STX $010E
L20F7     JMP L205E
          STX $0114
          STX $0113
          TYA
          PHA
          JSR L2F57
          JSR L3075
          STX $0111
          PLA
          TAY
          STX $0117
          JSR L2690
          CMP #$4E
          BEQ L211E
          CMP #$4C
          BNE L2121
          INC $0117
L211E     JSR L250D
L2121     JSR L21FA
          LDA $0108
          STA $012F
          LDA $0109
          STA $0130
          JMP L2BC0
          LDA #$01
          STX $0111
          STA $0113
          JSR L3260
          JSR L250D
          JSR L2147
          JMP L205E
L2147     JMP ($00D1)
          LDA $0135,Y
          CMP #$2F
          BNE L2169
          LDA #$FF
          STA $0109
          JSR L2212
          LDA $011C
          STA $DD
          LDA $011D
          STA $DE
          JSR L21C9
          JMP L205E
L2169     JSR L21FA
          JSR L21B3
          JMP L205E
L2172     LDA $C8
          STA $0129
          CLC
          ADC $0122
          STA $012B
          LDA $C9
          STA $012A
          ADC #$00
          STA $012C
          STX $0122
L218B     JSR L33AF
          STY $CE
          JSR L359C
          LDY $CE
          JSR L33BD
          RTS
L2199     STX $0110
          JSR L2690
          CMP #$46
          BNE L21B2
          INY
          LDX #$0A
          JSR L22E4
          LDA $010A
          STA $0110
          JSR L2510
L21B2     RTS
L21B3     BEQ L21C5
          BCC L21C9
L21B7     LDY #$02
L21B9     DEY
          BMI L21C9
          LDA $010A,Y
          CMP ($DD),Y
          BEQ L21B9
          BCS L21C9
L21C5     JSR L21E6
          RTS
L21C9     JSR L23B0
          LDA $010E
          BNE L21D7
          JSR L2622
          JSR L33F9
L21D7     JSR L2598
          JSR L33EA
          JSR L23A2
          LDY #$02
          LDA ($DD),Y
          BNE L21B7
L21E6     JSR L21ED
          JSR L33EA
          RTS
L21ED     STX $E3
          LDA #$2F
          JSR L33C4
          LDA #$2F
          JSR L33C4
          RTS
L21FA     LDX #$08
          JSR L22E4
          CPY #$50
          BCC L220A
          LDA #$FF
          STA $010B
          BNE L2212
L220A     JSR L2510
          LDX #$0A
          JSR L22E4
L2212     JSR L24BA
L2215     LDY #$02
          LDA ($DD),Y
          BNE L221D
L221B     CLC
          RTS
L221D     DEY
          BMI L221B
          LDA ($DD),Y
          CMP $0108,Y
          BEQ L221D
          BCC L222A
          RTS
L222A     LDA $DD
          STA $011C
          LDA $DE
          STA $011D
          JSR L23A2
          JMP L2215
L223A     STY $CE
          LDY $0122
          STA ($C8),Y
          INC $0122
          LDY $CE
          RTS
L2247     LDA $0113
          BPL L2254
          LDA #$4F
          INC $0111
          JSR L2E90
L2254     JMP L2E31
L2257     LDY #$02
          LDA ($DD),Y
          RTS
L225C     INC $0113
          JMP L2BB1
L2262     JSR L25AB
          LDY #$00
          LDA $0135,Y
          CMP #$30
          BCC L2272
          CMP #$3A
          BCC L2273
L2272     RTS
L2273     LDX #$08
          JSR L2632
          STY $E1
          LDA $011A
          SEC
          SBC $E1
          STA $011A
L2283     JSR L2362
          LDY $E1
          JSR L2510
          CPY #$50
          BCS L2294
          LDY $E1
          JSR L22FA
L2294     JSR L22EF
          BEQ L22C0
          LDA $0108
          CLC
          SED
          ADC $010C
          STA $0108
          LDA $0109
          ADC $010D
          STA $0109
          CLD
          JSR L2625
          JSR L25AB
          LDY #$00
          STY $E1
          JSR L22C3
          BNE L2283
          JSR L33EA
L22C0     JMP L2070
L22C3     LDY #$00
          JSR L2510
          LDA $0135,Y
          CMP #$2F
          BNE L22D2
          CMP $0136,Y
L22D2     RTS
L22D3     JSR L2632
          CPY #$50
          BCS L22E3
          LDA $DF
          BEQ L22E3
L22DE     LDX #$00
          JMP L2442
L22E3     RTS
L22E4     JSR L22D3
          LDA #$20
          CMP $0135,Y
          BNE L22DE
          RTS
L22EF     CLC
          LDA $010C
          ADC $010D
          STA $0115
          RTS
L22FA     TYA
          PHA
          JSR L24A8
          LDA $011A
          SEC
          ADC $D3
          PHA
          TXA
          ADC $D4
          CMP $0103
          BCC L231C
          BEQ L2313
L2310     JMP L243C
L2313     TAY
          PLA
          CMP $0102
          BCS L2310
          PHA
          TYA
L231C     STA $D4
          PLA
          STA $D3
          JSR L24B1
          JMP L2331
L2327     JSR L24E4
          JSR L24E3
          LDA ($DF,X)
          STA ($E1,X)
L2331     LDA $DD
          CMP $DF
          BNE L2327
          LDA $DE
          CMP $E0
          BNE L2327
          LDY #$00
          LDA $0108
          STA ($DD),Y
          LDA $0109
          INY
          STA ($DD),Y
          PLA
          TAX
L234C     INY
          LDA $0135,X
          INX
          STA ($DD),Y
          CPY $011A
          BNE L234C
          ORA #$80
          STA ($DD),Y
          LDX #$00
          JSR L209E
          RTS
L2362     JSR L2212
          BNE L2368
L2367     RTS
L2368     BCS L2367
          JSR L249F
          JSR L23A2
L2370     LDY #$02
          LDA ($DD),Y
          BNE L2385
          LDA $DF
          STA $D3
          LDA $E0
          STA $D4
          JSR L209E
          JSR L2212
          RTS
L2385     LDA ($DD,X)
          STA ($DF,X)
          JSR L24D2
          JSR L24D1
          DEY
          BNE L2385
L2392     LDA ($DD,X)
          STA ($DF,X)
          PHP
          JSR L24D2
          JSR L24D1
          PLP
          BPL L2392
          BMI L2370
L23A2     JSR L24D2
L23A5     JSR L24D2
          LDA ($DD,X)
          BPL L23A5
          JSR L24D2
          RTS
L23B0     JSR L2616
          LDA ($DD),Y
          STA $0108
          INY
          LDA ($DD),Y
          STA $0109
          INY
          LDA $010F
          BEQ L23F1
          LDA ($DD),Y
          CMP #$3B
          BEQ L23F1
          CMP #$20
          BEQ L23D1
          JSR L2407
L23D1     JSR L23F7
          LDX $EA
          CMP #$3B
          BEQ L23F1
          JSR L2407
          JSR L23F7
          CMP #$3B
          BEQ L23EE
          JSR L2407
          JSR L23F7
          CMP #$3B
          BNE L23F1
L23EE     JSR L2400
L23F1     JSR L2407
          JMP L23F1
L23F7     LDA ($DD),Y
          INY
          CMP #$20
          BEQ L23F7
          DEY
          RTS
L2400     INX
          TXA
          AND #$07
          BNE L2400
          RTS
L2407     CPX #$50
          BCS L2426
          LDA ($DD),Y
          BMI L241D
          CMP #$09
          BEQ L242D
          STA $0135,X
          INY
          INX
          CMP #$20
          BNE L2407
          RTS
L241D     AND #$7F
          CMP #$09
          BEQ L2426
          STA $0135,X
L2426     TXA
          TAY
          LDX #$00
          PLA
          PLA
          RTS
L242D     JSR L2400
          INY
          BNE L2407
          INX
L2434     INX
L2435     INX
L2436     INX
          INX
          INX
L2439     INX
L243A     INX
L243B     INX
L243C     INX
L243D     INX
L243E     INX
L243F     INX
L2440     INX
L2441     INX
L2442     INX
L2443     INX
L2444     INX
L2445     INX
L2446     INX
L2447     INX
L2448     INX
L2449     INX
L244A     INX
L244B     TXA
          PHA
          LDX #$00
          JSR L37D7
          LDA $0113
          BPL L245A
          STA $0112
L245A     LDA $E3
          STA $CF
          STX $E3
          LDA #$07
          JSR L33C4
          JSR L2F62
          JSR L33EA
          LDA #$21
          JSR L33C4
          PLA
          JSR L3402
          TYA
          PHA
          LDY #$00
          JSR L252C
          PLA
          TAY
          JSR L2622
          LDA #$2F
          JSR L33C4
          LDA $0128
          JSR L3402
          JSR L33EA
          LDA $0112
          BNE L2498
          LDA $CF
          STA $E3
          RTS
L2498     LDA #$FF
          STA $DB
          JMP L2056
L249F     LDA $DD
          STA $DF
          LDA $DE
          STA $E0
          RTS
L24A8     LDA $D3
          STA $DF
          LDA $D4
          STA $E0
          RTS
L24B1     LDA $D3
          STA $E1
          LDA $D4
          STA $E2
          RTS
L24BA     LDA $0100
          STA $DD
          LDA $0101
          STA $DE
          RTS
L24C5     LDA $0104
          STA $DD
          LDA $0105
          STA $DE
          RTS
L24D0     INX
L24D1     INX
L24D2     INX
          INX
L24D4     INX
L24D5     INX
L24D6     INX
          TXA
          ASL A
          TAX
          INC $D3,X
          BNE L24E0
          INC $D4,X
L24E0     LDX #$00
          RTS
L24E3     INX
L24E4     INX
          INX
          INX
L24E7     INX
          INX
          INX
          TXA
          ASL A
          TAX
L24ED     DEC $D3,X
          LDA $D3,X
          CMP #$FF
          BNE L24F7
          DEC $D4,X
L24F7     LDX #$00
          RTS
L24FA     LDA $0135,Y
          CMP #$21
          BEQ L250A
          BNE L250D
L2503     LDA $0135,Y
          CMP #$2E
          BNE L250D
L250A     INY
          INY
          INY
L250D     JSR L251E
L2510     LDA $0135,Y
          INY
          CPY #$50
          BCS L251D
          CMP #$20
          BEQ L2510
          DEY
L251D     RTS
L251E     LDA $0135,Y
          INY
          CPY #$50
          BCS L252B
          CMP #$20
          BNE L251E
          DEY
L252B     RTS
L252C     LDA $2538,Y
          BNE L2532
          RTS
L2532     JSR L33C4
          INY
          BNE L252C
          JSR $5441
          JSR $494C
          LSR $0045
          ORA $0A0A
          ASL A
          JMP $4241
          EOR $4C
          JSR $4946
          JMP L3A45
          JSR $5B20
          JSR L202F
          AND $4520,X
          CLI
          .BYTE $54    ;%01010100 'T'
          EOR $52
          LSR $4C41
          JSR $0D5D
          ASL A
          ASL A
          BRK
          .BYTE $52    ;%01010010 'R'
          EOR $41
          .BYTE $44    ;%01000100 'D'
          EOR $4620,Y
          .BYTE $4F    ;%01001111 'O'
          .BYTE $52    ;%01010010 'R'
          JSR L4150
          .BYTE $53    ;%01010011 'S'
          .BYTE $53    ;%01010011 'S'
          JSR $0D32
          ASL A
          BRK
          BVC L25BC
          .BYTE $47    ;%01000111 'G'
          EOR $20
          BRK
          ORA $430A
          JSR L3931
          .BYTE $37    ;%00110111 '7'
          AND $4220,Y
          EOR $4320,Y
          ROL $4D20
          .BYTE $4F    ;%01001111 'O'
          .BYTE $53    ;%01010011 'S'
          EOR $52
          ORA $0D0A
          ASL A
          BRK
L2598     LDX #$00
L259A     TXA
L259B     PHA
          LDA $0135,X
          JSR L33C4
          PLA
          TAX
          INX
          DEY
          BPL L259A
          LDX #$00
          RTS
L25AB     STX $E3
L25AD     LDA #$3E
          JSR L33C4
          JSR L2616
L25B5     JSR L33DD
          CMP #$0D
          BNE L25C4
L25BC     INY
          STY $011A
          RTS
L25C1     JSR L33C4
L25C4     CMP #$08
          BEQ L25D1
          CMP #$7F
          BNE L25EA
          LDA #$5C
          JSR L33C4
L25D1     DEY
          BMI L25DC
          LDA #$20
          STA $0135,Y
          JMP L25B5
L25DC     JSR L33EA
          LDA $0115
          BEQ L25AB
          JSR L2625
          JMP L25AD
L25EA     CMP #$18
          BEQ L25DC
          STA $0135,Y
          CMP #$09
          BEQ L2605
          INY
          CPY #$50
          BCC L25B5
          LDA #$07
          JSR L33C4
L25FF     LDA #$08
          BNE L25C1
          BEQ L259B
L2605     TYA
          PHA
L2607     JSR L33FC
          INY
          TYA
          AND #$07
          BNE L2607
          PLA
          TAY
          INY
          JMP L25FF
L2616     LDY #$55
          LDA #$20
L261A     STA $0135,Y
          DEY
          BPL L261A
          INY
          RTS
L2622     JSR L33FC
L2625     LDA $0109
          JSR L3402
          LDA $0108
          JSR L3402
          RTS
L2632     LDA #$00
          STA $0100,X
          STA $0101,X
          STA $DF
          STA $E0
L263E     JSR L266E
          BNE L2646
          LDX #$00
          RTS
L2646     PHA
          LDA $DF
          BEQ L2654
          LDA $0111
          BEQ L2654
          LDX #$00
          PLA
          RTS
L2654     INY
          TYA
          PHA
          LDY #$04
L2659     ASL $0100,X
          ROL $0101,X
          DEY
          BNE L2659
          PLA
          TAY
          PLA
          ORA $0100,X
          STA $0100,X
          JMP L263E
L266E     JSR L2690
          CMP #$30
          BCC L268D
          CMP #$3A
          BCC L2688
          CMP #$41
          BCC L268D
          CMP #$47
          BCS L268D
          AND #$0F
          CLC
          ADC #$09
          INC $DF
L2688     AND #$0F
          INC $E0
          RTS
L268D     LDA #$00
          RTS
L2690     LDA $0135,Y
L2693     CMP #$61
          BCC L269D
          CMP #$7B
          BCS L269D
          AND #$DF
L269D     RTS
L269E     LDA #$00
          BEQ L26A8
L26A2     LDA #$01
          BNE L26A8
L26A6     LDA #$FF
L26A8     STA $E1
          STY $E2
L26AC     LDY $E2
L26AE     LDA $E1
          BEQ L26C0
          BPL L26BA
          LDA L28B7,X
          BNE L26C6
          RTS
L26BA     LDA $2831,X
          BNE L26C6
          RTS
L26C0     LDA $2731,X
          BNE L26C6
          RTS
L26C6     STA $011A
          JSR L2690
          CMP $011A
          PHP
          TYA
          SEC
          SBC $E2
          INY
          INX
          PLP
          BEQ L26FB
          CMP #$01
          BEQ L26E2
          CMP #$02
          BEQ L26E3
          INX
L26E2     INX
L26E3     INX
          LDA $E1
          BMI L26ED
          BNE L26AC
          JMP L26AC
L26ED     LDA $28B6,X
          AND #$0F
          STX $E0
          SEC
          ADC $E0
          TAX
          JMP L26AC
L26FB     PHA
          LDA $E1
          BNE L2707
          PLA
          CMP #$01
          BNE L26AE
          BEQ L270C
L2707     PLA
          CMP #$02
          BNE L26AE
L270C     LDA $E1
          BEQ L2713
          STX $D0
          RTS
L2713     LDA $2731,X
          STA $E1
          LDA $2732,X
          STA $E2
          PLA
          PLA
          CPX #$85
          BCS L2729
          JSR L250D
          JMP L272C
L2729     JSR L2510
L272C     LDX #$00
          JMP ($00E1)
          .BYTE $42    ;%01000010 'B'
          .BYTE $52    ;%01010010 'R'
          LDY $20
          .BYTE $43    ;%01000011 'C'
          JMP L204D
          BVC L2790
          .BYTE $44    ;%01000100 'D'
          AND $46,X
          .BYTE $4F    ;%01001111 'O'
          CPY #$20
          BVC L2795
          LSR A
          AND ($41,X)
          EOR $B2,X
          JSR $5341
          .BYTE $FA    ;%11111010
          JSR L4150
          CMP $5232
          EOR $33,X
          AND ($4D,X)
          EOR ($EA,X)
          JSR $554F
          LDY #$2B
          .BYTE $4F    ;%01001111 'O'
          LSR $3370
          .BYTE $4F    ;%01001111 'O'
          LSR $53
          .BYTE $33    ;%00110011 '3'
          PHA
          EOR ($2F,X)
          AND $4547,Y
          TSX
          JSR L414C
          JSR $452F
          .BYTE $44    ;%01000100 'D'
          .BYTE $3C    ;%00111100 ''
          ROL $4E,X
          EOR $1D,X
          .BYTE $34    ;%00110100 '4'
          .BYTE $44    ;%01000100 'D'
          EOR $AD
          .BYTE $3A    ;%00111010 ''
          LSR $49
          ROL $36,X
          EOR $A44F
          .BYTE $3A    ;%00111010 ''
          .BYTE $43    ;%01000011 'C'
          .BYTE $4F    ;%01001111 'O'
          ADC ($39,X)
          .BYTE $53    ;%01010011 'S'
          EOR $DA
          .BYTE $3A    ;%00111010 ''
          EOR $53,X
          .BYTE $03    ;%00000011
L2790     BRK
          .BYTE $44    ;%01000100 'D'
          EOR $68,X
          .BYTE $3B    ;%00111011 ';'
L2795     EOR $4E
          .BYTE $9E    ;%10011110
          .BYTE $3B    ;%00111011 ';'
          JMP $AF4F
          .BYTE $3B    ;%00111011 ';'
          .BYTE $44    ;%01000100 'D'
          .BYTE $43    ;%01000011 'C'
          CPY #$3B
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
L27AC     BNE L27B2
          PLA
          JMP L2D5E
L27B2     PLA
          JMP L2D53
          .BYTE $53    ;%01010011 'S'
          EOR #$3F
          ROL A
          .BYTE $42    ;%01000010 'B'
          EOR ($53,X)
          ROL A
          EOR $4E
          .BYTE $5C    ;%01011100 ''
          .BYTE $2B    ;%00101011 '+'
          .BYTE $42    ;%01000010 'B'
          EOR $2ABD,Y
          .BYTE $53    ;%01010011 'S'
          EOR $48
          ROL A
          .BYTE $44    ;%01000100 'D'
          EOR #$F7
          ROL A
          JMP L3453
          ROL A
          JMP L3943
          ROL A
          EOR $9343
          ROL A
          .BYTE $4F    ;%01001111 'O'
          .BYTE $43    ;%01000011 'C'
          ROL A
          ROL A
          .BYTE $4F    ;%01001111 'O'
          .BYTE $53    ;%01010011 'S'
          AND $2A
          .BYTE $43    ;%01000011 'C'
          EOR $20
          ROL A
          .BYTE $43    ;%01000011 'C'
          .BYTE $54    ;%01010100 'T'
          .BYTE $2F    ;%00101111 ''
          ROL A
          .BYTE $52    ;%01010010 'R'
          .BYTE $53    ;%01010011 'S'
          .BYTE $1B    ;%00011011
          ROL A
          .BYTE $44    ;%01000100 'D'
          EOR $00
          .BYTE $2B    ;%00101011 '+'
          .BYTE $52    ;%01010010 'R'
          .BYTE $43    ;%01000011 'C'
          .BYTE $57    ;%01010111 'W'
          .BYTE $34    ;%00110100 '4'
          .BYTE $44    ;%01000100 'D'
          .BYTE $53    ;%01010011 'S'
          LDA $29
          EOR $53
          .BYTE $5B    ;%01011011 '['
          ROL $4345,X
          RTS
          ROL $4A45,X
          .BYTE $04    ;%00000100
          ROL A
          EOR $A744
          ROL $454D,X
          EOR $4D3F
          .BYTE $47    ;%01000111 'G'
          LDY #$29
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          EOR ($20,X)
          NOP
          AND $2900
          JSR L2E2A
          BRK
          .BYTE $54    ;%01010100 'T'
          EOR ($58,X)
          TAX
          .BYTE $54    ;%01010100 'T'
          EOR ($59,X)
          TAY
          .BYTE $54    ;%01010100 'T'
          .BYTE $53    ;%01010011 'S'
          CLI
          TSX
          .BYTE $54    ;%01010100 'T'
          CLI
          EOR ($8A,X)
          .BYTE $54    ;%01010100 'T'
          CLI
          .BYTE $53    ;%01010011 'S'
          TXS
          .BYTE $54    ;%01010100 'T'
          EOR $9841,Y
          .BYTE $43    ;%01000011 'C'
          JMP $1843
          .BYTE $43    ;%01000011 'C'
          JMP $D844
          .BYTE $43    ;%01000011 'C'
          JMP $5849
          .BYTE $43    ;%01000011 'C'
          JMP $B856
          .BYTE $53    ;%01010011 'S'
          EOR $43
          SEC
          .BYTE $53    ;%01010011 'S'
          EOR $44
          SED
          .BYTE $53    ;%01010011 'S'
          EOR $49
          SEI
          LSR $504F
          NOP
          .BYTE $52    ;%01010010 'R'
          .BYTE $54    ;%01010100 'T'
          EOR #$40
          .BYTE $52    ;%01010010 'R'
          .BYTE $54    ;%01010100 'T'
          .BYTE $53    ;%01010011 'S'
          RTS
          .BYTE $44    ;%01000100 'D'
          EOR $58
          DEX
          .BYTE $44    ;%01000100 'D'
          EOR $59
          DEY
          EOR #$4E
          CLI
          INX
          EOR #$4E
          EOR $50C8,Y
          PHA
          EOR ($48,X)
          BVC L28CF
          BVC L2891
          BVC L28D7
          EOR ($68,X)
          BVC L28DB
          BVC L28B9
L2891     .BYTE $42    ;%01000010 'B'
          .BYTE $52    ;%01010010 'R'
          .BYTE $4B    ;%01001011 'K'
          BRK
          BRK
          .BYTE $42    ;%01000010 'B'
          .BYTE $43    ;%01000011 'C'
          .BYTE $43    ;%01000011 'C'
          BCC L28DD
          .BYTE $43    ;%01000011 'C'
          .BYTE $53    ;%01010011 'S'
          BCS L28E1
          EOR $51
          BEQ L28E5
          EOR $3049
          .BYTE $42    ;%01000010 'B'
          LSR $D045
          .BYTE $42    ;%01000010 'B'
          BVC L28F9
          BPL L28F1
          LSR $43,X
          BVC L28F5
          LSR $53,X
          BVS L28B7
L28B7     .BYTE $52    ;%01010010 'R'
          .BYTE $4F    ;%01001111 'O'
L28B9     .BYTE $52    ;%01010010 'R'
          CMP $C1
          ROR $667E
          ROR $6A,X
          EOR ($44,X)
          .BYTE $43    ;%01000011 'C'
          INX
          .BYTE $DA    ;%11011010
          ADC $797D
          ADC $75
          ADC ($61),Y
          ADC #$41
L28CF     LSR $E844
          .BYTE $DA    ;%11011010
          AND $393D
          AND $35
          AND ($21),Y
          AND #$41
          .BYTE $53    ;%01010011 'S'
L28DD     JMP $C1C5
          ASL $061E
          ASL $0A,X
L28E5     .BYTE $42    ;%01000010 'B'
          EOR #$54
          .BYTE $82    ;%10000010
          .BYTE $80    ;%10000000
          BIT $4324
          EOR $E850
          .BYTE $DA    ;%11011010
L28F1     CMP $D9DD
          CMP $D5
          CMP ($C1),Y
          CMP #$43
          BVC L2954
          .BYTE $83    ;%10000011
          .BYTE $82    ;%10000010
          CPX $E0E4
          .BYTE $43    ;%01000011 'C'
          BVC L295D
          .BYTE $83    ;%10000011
          .BYTE $82    ;%10000010
          CPY $C0C4
          .BYTE $44    ;%01000100 'D'
          EOR $43
          CPY $C0
          DEC $C6DE
          DEC $45,X
          .BYTE $4F    ;%01001111 'O'
          .BYTE $52    ;%01010010 'R'
          INX
          .BYTE $DA    ;%11011010
          EOR $595D
          EOR $55
          EOR ($41),Y
          EOR #$49
          LSR $C443
          CPY #$EE
          INC $F6E6,X
          LSR A
          EOR $9250
          BRK
          JMP $4C6C
          .BYTE $44    ;%01000100 'D'
          EOR ($E8,X)
          .BYTE $DA    ;%11011010
          LDA $B9BD
          LDA $B5
          LDA ($A1),Y
          LDA #$4C
          .BYTE $44    ;%01000100 'D'
          CLI
          LDA $A2
          LDX $A6BE
          LDX $A2,Y
          JMP $5944
          CMP $C2
          LDY $A4BC
          LDY $A0,X
          JMP $5253
          CPY $C1
          LSR $465E
          LSR $4A,X
          .BYTE $53    ;%01010011 'S'
          .BYTE $52    ;%01010010 'R'
          STA ($00,X)
          JSR $524F
          EOR ($E8,X)
          .BYTE $DA    ;%11011010
          ORA $191D
          ORA $15
          ORA ($01),Y
          ORA #$52
          .BYTE $4F    ;%01001111 'O'
          JMP $C1C5
          ROL L263E
          ROL $2A,X
          .BYTE $53    ;%01010011 'S'
          .BYTE $42    ;%01000010 'B'
          .BYTE $43    ;%01000011 'C'
          INX
          .BYTE $DA    ;%11011010
          SBC $F9FD
          SBC $F5
          SBC ($E1),Y
          SBC #$53
          .BYTE $54    ;%01010100 'T'
          EOR ($E7,X)
          CLD
          STA $999D
          STA $95
          STA ($81),Y
          .BYTE $53    ;%01010011 'S'
          .BYTE $54    ;%01010100 'T'
          CLI
          .BYTE $83    ;%10000011
          LDY #$8E
          STX $96
          .BYTE $53    ;%01010011 'S'
          .BYTE $54    ;%01010100 'T'
          EOR $C083,Y
          STY $9484
          BRK
          INC $CA
          JMP L2C04
          LDA $0117
          BEQ L29BC
          LDA $0113
          CMP #$01
          BNE L29BC
          LDA $BC
          BNE L29BC
          JSR L2EDF
          LDA #$05
          STA $E7
L29BC     JSR L3260
          LDA $011A
          BEQ L29CA
          STY $0112
          JMP L2447
L29CA     LDA $D1
          CLC
          ADC $D7
          STA $D7
          LDA $D2
          ADC $D8
          STA $D8
          LDA $D1
          CLC
          ADC $D9
          STA $D9
          LDA $D2
          ADC $DA
          STA $DA
          LDA $0113
          BPL L2A01
          LDA #$7F
          INC $0111
          JSR L2E90
          LDA $D1
          INC $0111
          JSR L2E90
          LDA $D2
          INC $0111
          JSR L2E90
L2A01     JMP L2C04
          LDA $0113
          BEQ L2A18
          BMI L2A18
          LDA $0117
          BEQ L2A18
          LDA $011F
          BEQ L2A18
          JSR L38EE
L2A18     JMP L2C04
          LDA #$5F
          JMP L2DBB
          STX $0112
          BEQ L2A3C
          STY $0116
          BEQ L2A3C
          STX $0116
          BEQ L2A3C
          STY $0114
          BEQ L2A3C
          STY $0117
          BEQ L2A3C
          STX $0117
L2A3C     JMP L2C04
          JSR L3260
          INC $011E
          JMP L2247
          JSR L3260
          LDX #$00
          STX $011E
          JMP L2247
          LDA $DD
          PHA
          LDA $DE
          PHA
          JSR L3260
          LDA $011A
          BEQ L2A67
          STY $0112
          JMP L2447
L2A67     PLA
          STA $DE
          PLA
          STA $DD
          LDA $D1
          STA $D7
          STA $D9
          LDA $D2
          STA $D8
          STA $DA
          LDA $0135
          CMP #$20
          BEQ L2A88
          LDA $0113
          BNE L2A88
          JSR L2B50
L2A88     LDA $0113
          BPL L2A90
          JSR L2F0D
L2A90     JMP L2C04
          LDA $0112
          PHA
          STY $0112
          JSR L3260
          PLA
          STA $0112
          LDA $D1
          STA $D9
          LDA $D2
          STA $DA
          JMP L2C04
L2AAC     JSR L3260
          LDA $D1
          JSR L2AE4
L2AB4     JSR L2510
          CPY #$50
          BCS L2A90
          BCC L2AC7
          CPY #$50
          BCC L2AC7
L2AC1     JSR L2441
          JMP L2C04
L2AC7     CMP #$3B
          BEQ L2A90
          CMP #$27
          BNE L2AAC
L2ACF     INY
          CPY #$50
          BCS L2AC1
          LDA $0135,Y
          CMP #$27
          BNE L2ADE
          INY
          BNE L2AB4
L2ADE     JSR L2AE4
          CLV
          BVC L2ACF
L2AE4     PHA
          LDA $0113
          BPL L2AF2
          LDA #$3F
          INC $0111
          JSR L2E90
L2AF2     PLA
          JSR L2E90
          RTS
          JSR L2B28
          JSR L2B50
          JMP L2C04
          JSR L2B28
          BNE L2B22
          LDY #$01
L2B07     INY
          LDA ($CE),Y
          BPL L2B07
L2B0C     LDA ($CE),Y
          INY
          STA ($CE),Y
          DEY
          DEY
          CPY #$01
          BNE L2B0C
          INY
          LDA #$2F
          STA ($CE),Y
          JSR L24D6
          JSR L3075
L2B22     JSR L2B50
          JMP L2C04
L2B28     JSR L3260
          LDA $0135
          CMP #$20
          BNE L2B38
          JSR L2446
          JMP L2C04
L2B38     LDY #$00
          JSR L3130
          LDA $DD
          STA $CE
          LDA $DE
          STA $CF
          LDA $0113
          BEQ L2B4F
          STX $011E
          LDA #$FF
L2B4F     RTS
L2B50     LDY #$00
          LDA $D1
          STA ($CE),Y
          INY
          LDA $D2
          STA ($CE),Y
          RTS
          JSR L2F67
          LDA $BC
          BNE L2B6D
          LDA $BF
          BNE L2B71
          LDA $BB
          BNE L2B75
          BEQ L2B7A
L2B6D     LDX #$21
          BNE L2B77
L2B71     LDX #$22
          BNE L2B77
L2B75     LDX #$23
L2B77     JSR L244B
L2B7A     LDA $0113
          BEQ L2B8D
          BMI L2B87
          LDA $0117
          JMP L2F1E
L2B87     JSR L2F0D
          JMP L2056
L2B8D     INC $0113
          LDA $0114
          BEQ L2BB1
          JSR L33BD
          LDY #$2E
          JSR L252C
          JMP L2056
          STX $0122
          JSR L2199
          STX $0111
          LDX #$FF
          STX $0113
          STX $010A
L2BB1     LDA $012F
          STA $0108
          LDA $0130
          STA $0109
          JSR L2212
L2BC0     LDX #$00
          STX $E6
          STX $DC
          STX $DB
          LDX #$FF
          TXS
          INX
          STX $0116
          STX $CA
          LDA $0100
          STA $CB
          LDA $0101
          STA $CC
          LDA #$01
          STA $C4
          STX $C5
          STX $C2
          STX $C3
          STX $BB
          STX $BC
          STX $BF
          STX $C1
          LDA #$00
          STA $D7
          STA $D9
          LDA #$02
          STA $D8
          STA $DA
          LDA $0113
          BPL L2C0F
          JSR L2F10
          JMP L2C0F
L2C04     LDX #$00
          PLA
          STA $DD
          PLA
          STA $DE
          JSR L23A2
L2C0F     LDA $DE
          PHA
          LDA $DD
          PHA
          STX $011E
          JSR L2257
          BNE L2C8A
          LDA $BB
          BEQ L2C26
          LDX #$27
          JSR L244B
L2C26     INC $C4
          BNE L2C33
          INC $C5
          BNE L2C33
          LDX #$2F
          JSR L244B
L2C33     LDA $0114
          BNE L2C40
          LDA #$01
          STA $0112
          JMP L2444
L2C40     JSR L2F67
          JSR L33EA
          JSR L33EA
          JSR L33EA
          LDA $CA
          BEQ L2C58
          LDA $D3
          STA $CB
          LDA $D4
          STA $CC
L2C58     LDA #$00
          STA $CA
          LDA $CB
          STA $D3
          LDA $CC
          STA $D4
          STX $0110
          JSR L349B
          LDA #$00
          STA $0111
          LDA $012F
          STA $0108
          LDA $0130
          STA $0109
          LDA $CB
          STA $DD
          LDA $CC
          STA $DE
          LDX #$FF
          TXS
          INX
          JMP L2C0F
L2C8A     LDX #$00
          LDA $0117
          BEQ L2CA6
          JSR L2F67
          LDA $0113
          CMP #$01
          BNE L2CA6
          LDA $BC
          BEQ L2CA3
          LDA $C1
          BEQ L2CA6
L2CA3     JSR L33EA
L2CA6     JSR L23B0
          STY $E9
          INC $E6
          LDY #$00
          LDA $0135,Y
          CMP #$3B
          BEQ L2CB9
          JSR L250D
L2CB9     STX $BD
          LDA $BB
          BEQ L2CC7
          LDX #$24
          JSR L3D5E
          JMP L2C04
L2CC7     LDA $BF
          BEQ L2CD3
          LDX #$19
          JSR L3D5E
          JMP L2C04
L2CD3     LDY #$00
          LDA $0135,Y
          CMP #$3B
          BNE L2CDF
L2CDC     JMP L2C04
L2CDF     CMP #$20
          BEQ L2CEB
          LDA $0113
          BNE L2CEB
          JSR L2F99
L2CEB     JSR L24FA
          LDA $0135,Y
          CMP #$3B
          BEQ L2CDC
          CPY #$50
          BCS L2CDC
          CMP #$2E
          BNE L2D15
          INY
          LDA $0137,Y
          CMP #$20
          BEQ L2D0B
L2D05     JSR L2448
          JMP L2C04
L2D0B     LDX #$85
          JSR L269E
          LDX #$00
          JMP L2D05
L2D15     LDA $0138,Y
          CMP #$20
          BNE L2D6C
          JSR L26A2
          BEQ L2D2A
          LDA $2831,X
L2D24     JSR L2E90
          JMP L2C04
L2D2A     LDX #$65
          JSR L26A2
          BEQ L2D65
          LDA $2831,X
          JSR L2E90
          JSR L250D
          LDA $0113
          BEQ L2D62
          JSR L3260
          CLC
          LDA $D1
          SBC $D7
          PHA
          LDA $D2
          SBC $D8
          BNE L2D59
          PLA
          CMP #$80
          BCC L2D62
L2D53     JSR L244A
          JMP L2D24
L2D59     CMP #$FF
          JMP L27AC
L2D5E     CMP #$80
          BCC L2D53
L2D62     JMP L2D24
L2D65     LDX #$00
          JSR L26A6
          BNE L2D6F
L2D6C     JMP L3CA5
L2D6F     JSR L2510
          LDA $0135,Y
          CMP #$23
          BNE L2DF2
          LDX #$0B
          JSR L2E5D
          LDX #$55
          JSR L3D5E
          INY
          LDA $0135,Y
          CMP #$27
          BNE L2D91
          LDA $0136,Y
          JMP L2D24
L2D91     LDX #$00
          JSR L3260
          LDA $D1
          JMP L2D24
          JSR L3260
          LDA $D1
          JSR L2E90
          LDA $011E
          BEQ L2DCE
          LDA #$1F
          BNE L2DBB
          JSR L3260
          LDA $D2
          JSR L2E90
          LDA $011E
          BEQ L2DCE
          LDA #$2F
L2DBB     PHA
          LDA $0113
          BPL L2DD1
          PLA
          INC $0111
          PHA
          JSR L2E90
          PLA
          CMP #$2F
          BEQ L2DD5
L2DCE     JMP L2C04
L2DD1     PLA
          JMP L2C04
L2DD5     LDA $D1
          INC $0111
          JMP L2D24
L2DDD     JSR L2E90
          LDA $011E
          BNE L2DCE
          LDA #$0F
          JMP L2DBB
          LDX #$0C
          JSR L2E5D
          JMP L2C04
L2DF2     LDX #$F6
          JSR L269E
          TAX
          LDA $0135,Y
          CMP #$2A
          BNE L2E09
          INY
          JSR L30D7
          BEQ L2E3F
          LDX #$3F
          BNE L2E23
L2E09     CMP #$28
          BNE L2E1C
          INY
          JSR L30D7
          LDX #$FB
          JSR L269E
          LDX #$34
          BNE L2E23
          BNE L2E23
L2E1C     JSR L30D7
          BEQ L2E2D
          LDX #$4A
L2E23     JSR L3D5E
          TAX
          JMP L2AC1
L2E2A     INX
          INX
L2E2C     INX
L2E2D     INX
          JSR L2E5D
L2E31     LDA $D1
          JSR L2E90
          LDA $D2
          JMP L2DDD
          INX
          INX
          INX
          INX
L2E3F     INX
          INX
          INX
          INX
          INX
          JSR L2E5D
          LDA $D1
          JSR L2E90
          LDA $D2
          BEQ L2E5A
          LDX #$00
          LDA $0113
          BEQ L2E5A
          JSR L244B
L2E5A     JMP L2C04
L2E5D     STX $DD
          LDX $D0
          LDA $28B8,X
          STA $DE
          LDA #$04
          STA $DF
          LDA L28B7,X
L2E6D     DEC $DF
          BMI L2E81
          ASL A
          BCC L2E75
          INX
L2E75     DEC $DD
          BNE L2E6D
          BCS L2E8D
L2E7B     LDX #$00
          JSR L2440
          RTS
L2E81     LDA $DE
L2E83     ASL A
          BCC L2E87
          INX
L2E87     DEC $DD
          BNE L2E83
          BCC L2E7B
L2E8D     LDA $28B8,X
L2E90     PHA
          LDX #$00
          LDA $0113
          BEQ L2EEF
          BMI L2EF3
          LDA $0117
          BEQ L2ED0
          LDA $BC
          BEQ L2EA7
          LDA $C1
          BEQ L2ED0
L2EA7     LDA $E7
          BNE L2EB2
L2EAB     LDA #$05
          STA $E7
          JSR L2EDF
L2EB2     LDA $E7
          CMP #$0E
          BNE L2EC1
          JSR L2F67
          JSR L33EA
          JMP L2EAB
L2EC1     JSR L33FC
          LDA $E7
          CLC
          ADC #$03
          STA $E7
          PLA
          PHA
          JSR L3402
L2ED0     LDA $0116
          BEQ L2EEF
          PLA
          STA ($D9,X)
L2ED8     JSR L24D5
          JSR L24D4
          RTS
L2EDF     LDA $D8
          JSR L3402
          LDA $D7
          JSR L3402
          LDA #$2D
          JSR L33C4
          RTS
L2EEF     PLA
          CLV
          BVC L2ED8
L2EF3     PLA
          JSR L223A
          LDA $0111
          BNE L2F02
          JSR L24D5
          JMP L2F05
L2F02     DEC $0111
L2F05     LDA $0122
          CMP #$FF
          BCS L2F0D
          RTS
L2F0D     JSR L2172
L2F10     STX $0122
          LDA $D7
          JSR L223A
          LDA $D8
          JSR L223A
          RTS
L2F1E     BEQ L2F23
          JSR L3278
L2F23     JSR L21ED
          JSR L2F2F
          JSR L2F39
          JMP L205C
L2F2F     LDA $DC
          JSR L3402
          LDA $DB
          JMP L3402
L2F39     LDA #$2C
          JSR L33C4
          LDA $D8
          JSR L3402
          LDA $D7
          JSR L3402
          LDA #$2C
          JSR L33C4
          LDA $DA
          JSR L3402
          LDA $D9
          JMP L3402
L2F57     LDA $0104
          STA $D5
          LDA $0105
          STA $D6
          RTS
L2F62     TYA
          PHA
          JMP L2F75
L2F67     TYA
          PHA
          LDA $0113
          CMP #$01
          BNE L2F92
          LDA $0117
          BEQ L2F92
L2F75     LDA $E6
          BEQ L2F92
          LDY $E7
          LDA $BC
          BNE L2F92
L2F7F     INY
          JSR L33FC
          CPY #$10
          BCC L2F7F
          LDY $E9
          JSR L2625
          JSR L33FC
          JSR L2598
L2F92     STX $E7
          PLA
          TAY
          STX $E6
          RTS
L2F99     LDA $D5
          STA $B9
          LDA $D6
          STA $BA
          LDA $BC
          BEQ L2FB7
          JSR L307C
          BNE L2FAC
          CLC
          RTS
L2FAC     JSR L308C
          BNE L2FE1
          JSR L309F
          JMP L2FCE
L2FB7     JSR L307C
          BNE L2FE1
          JSR L2F67
          LDA #$00
          STA $0136,Y
          STA $0137,Y
          LDA $CA
          BNE L2FCE
          JSR L3094
L2FCE     STY $E4
          JSR L30AA
          LDX $E4
          JSR L30B6
          JSR L30B6
          JSR L30B6
          JMP L2FE8
L2FE1     STY $E4
          JSR L30AA
          LDX $E4
L2FE8     LDA $0135,X
          CMP #$40
          BCC L300C
L2FEF     JSR L30B6
          LDA $0135,X
          CMP #$20
          BEQ L3016
          LDA $BC
          BEQ L3004
          LDA $0135,X
          CMP #$29
          BEQ L3016
L3004     LDA $0135,X
          JSR L326A
          BCC L2FEF
L300C     JSR L3075
          LDX #$00
          JSR L243F
          SEC
          RTS
L3016     LDA ($D5),Y
          ORA #$80
          STA ($D5),Y
          SEC
          TYA
          ADC $D5
          STA $D5
          LDX #$00
          TXA
          ADC $D6
          STA $D6
          CMP $0107
          BEQ L305C
          BCS L3063
L3030     JSR L3075
          LDY $E4
          JSR L3130
          LDA $DE
          PHA
          LDA $DD
          PHA
          JSR L30BE
          JSR L2257
          BEQ L3052
          PLA
          STA $DD
          PLA
          STA $DE
          JSR L2445
          JMP L3066
L3052     PLA
          STA $DD
          PLA
          STA $DE
          LDY $E4
          CLC
          RTS
L305C     LDA $D5
          CMP $0106
          BCC L3030
L3063     JSR L243D
L3066     LDA $B9
          STA $D5
          LDA $BA
          STA $D6
          JSR L3075
          LDY $E4
          SEC
          RTS
L3075     LDA #$00
          LDY #$02
          STA ($D5),Y
          RTS
L307C     LDA $0135,Y
          CMP #$21
L3081     BNE L308B
          CMP $0136,Y
          BNE L308B
          CMP $0137,Y
L308B     RTS
L308C     LDA $0135,Y
          CMP #$2E
          JMP L3081
L3094     LDA $C4
          STA $0136,Y
          LDA $C5
          STA $0137,Y
          RTS
L309F     LDA $C2
          STA $0136,Y
          LDA $C3
          STA $0137,Y
          RTS
L30AA     LDY #$00
          LDA $D7
          STA ($D5),Y
          LDA $D8
          INY
          STA ($D5),Y
          RTS
L30B6     LDA $0135,X
          INY
          STA ($D5),Y
          INX
          RTS
L30BE     LDY #$02
          LDA ($DD),Y
          CMP #$2E
          BEQ L30CA
          CMP #$21
          BNE L30D3
L30CA     JSR L24D2
          JSR L24D2
          JSR L24D2
L30D3     JSR L23A2
          RTS
L30D7     STX $011E
          CPY #$50
          BCC L30E2
          JSR L2441
          RTS
L30E2     STX $D1
          STX $D2
          STX $011A
          JMP L30FB
L30EC     LDA $0135,Y
          CMP #$2B
          BEQ L30FA
          CMP #$2D
          BEQ L3115
          CMP #$20
          RTS
L30FA     INY
L30FB     JSR L3130
          BCS L3103
          INC $011A
L3103     CLC
          LDA $0118
          ADC $D1
          STA $D1
          LDA $0119
          ADC $D2
          STA $D2
          JMP L30EC
L3115     INY
          JSR L3130
          BCS L311E
          INC $011A
L311E     SEC
          LDA $D1
          SBC $0118
          STA $D1
          LDA $D2
          SBC $0119
          STA $D2
          JMP L30EC
L3130     JSR L24C5
          STX $C0
          STY $E1
          STX $0118
          STX $0119
          LDA $0135,Y
          CMP #$25
          BNE L315F
L3144     INY
          LDA $0135,Y
          CMP #$30
          BEQ L3152
          CMP #$31
          BEQ L3155
          SEC
          RTS
L3152     CLC
          BCC L3156
L3155     SEC
L3156     ROL $0118
          ROL $0119
          JMP L3144
L315F     JSR L31B0
          BCS L316A
          LDA $0135,Y
          JMP L31BE
L316A     INY
          LDA $0135,Y
          JSR L31B0
          BCS L316A
          TYA
          PHA
L3175     DEY
          LDA $0135,Y
          STY $CE
          JSR L31B0
          BCC L31A0
          BEQ L3199
          TAY
L3183     LDA $31A6,X
          CLC
          ADC $0118
          STA $0118
          LDA $31AB,X
          ADC $0119
          STA $0119
          DEY
          BNE L3183
L3199     LDY $CE
          INX
          CPX #$05
          BNE L3175
L31A0     PLA
          TAY
          LDX #$00
          SEC
          RTS
          ORA ($0A,X)
          .BYTE $64    ;%01100100 'd'
          INX
          BPL L31AC
L31AC     BRK
          BRK
          .BYTE $03    ;%00000011
          .BYTE $27    ;%00100111 '''
L31B0     CMP #$30
          BCC L31B8
          CMP #$3A
          BCC L31BA
L31B8     CLC
          RTS
L31BA     AND #$0F
          SEC
          RTS
L31BE     CMP #$24
          BEQ L320C
          CMP #$3D
          BEQ L31FF
L31C6     LDX $E1
          LDY #$02
          LDA ($DD),Y
          CMP #$2F
          BNE L31D1
          INY
L31D1     LDA ($DD),Y
          BEQ L31D8
          JMP L32D3
L31D8     LDX #$00
          LDY $E1
L31DC     INY
          LDA $0135,Y
          JSR L326A
          BCC L31DC
          CMP #$21
          BEQ L31ED
          CMP #$2E
          BNE L31F5
L31ED     LDA $BD
          BNE L31DC
          LDA $BC
          BNE L31DC
L31F5     LDA $0113
          BEQ L31FD
          JSR L2443
L31FD     CLC
          RTS
L31FF     LDA $D7
          STA $0118
          LDA $D8
          STA $0119
          INY
          SEC
          RTS
L320C     LDX #$18
          INY
          JSR L2632
          LDA $E0
          BNE L325E
          JSR L243E
          CLC
          RTS
L321B     LDA ($DD),Y
          PHP
          AND #$7F
          CMP $0135,X
          BNE L3236
          INX
          INY
          PLP
          BPL L321B
          TXA
          TAY
          LDA $0135,Y
          JSR L326A
          BCS L323F
          BCC L3237
L3236     PLP
L3237     LDX #$00
          JSR L30BE
          CLV
          BVC L31C6
L323F     TYA
          TAX
          LDY #$00
          LDA ($DD),Y
          STA $0118
          INY
          LDA ($DD),Y
          STA $0119
          INY
          LDA ($DD),Y
          CMP #$2F
          BEQ L3258
          INC $011E
L3258     TXA
          TAY
          LDX #$00
          INC $C0
L325E     SEC
          RTS
L3260     JSR L30D7
          BNE L3266
          RTS
L3266     JSR L2441
          RTS
L326A     CMP #$2E
          BCC L3276
          CMP #$3D
          BEQ L3276
          CMP #$7B
          BCC L3277
L3276     SEC
L3277     RTS
L3278     LDY #$09
          JSR L252C
          JSR L24C5
L3280     STX $CF
          JSR L33EA
L3285     LDY #$02
          LDA ($DD),Y
          BNE L328F
          JSR L33EA
          RTS
L328F     JSR L23B0
          LDA $0135
          CMP #$21
          BEQ L329D
          CMP #$2E
          BNE L32A3
L329D     JSR L30BE
          JMP L3285
L32A3     TYA
          CLC
          ADC $CF
          STA $CF
          JSR L2598
          LDA #$3D
          JSR L33C4
          JSR L2625
          JSR L30BE
          LDY $CF
L32B9     LDY $CF
          JSR L33FC
          INY
          STY $CF
          CPY #$12
          BEQ L3285
          CPY #$24
          BEQ L3285
          BCS L3280
          BNE L32B9
          STX $0111
          JMP L225C
L32D3     LDA ($DD),Y
          CMP #$2E
          BNE L32F4
          LDA $BC
          BEQ L3325
          INY
          LDA ($DD),Y
          CMP $C2
          BNE L3325
          INY
          LDA ($DD),Y
          CMP $C3
          BNE L3325
          LDA $0135,X
          CMP #$2E
          BNE L3325
          BEQ L3328
L32F4     CMP #$21
          BNE L3316
          INY
          LDA ($DD),Y
          BNE L3305
          INY
          LDA ($DD),Y
          BEQ L3310
          DEY
          LDA ($DD),Y
L3305     CMP $C4
          BNE L3325
          INY
          LDA ($DD),Y
          CMP $C5
          BNE L3325
L3310     LDA $BD
          BEQ L3328
          BNE L332B
L3316     LDA $BD
          BNE L3325
          LDA $0135,X
          CMP #$2E
          BEQ L3325
          CMP #$21
          BNE L332C
L3325     JMP L3237
L3328     INX
          INX
          INX
L332B     INY
L332C     JMP L321B
L332F     LDA $1702
          AND #$FE
          STA $1702
          RTS
L3338     LDA $1702
          AND #$FD
          STA $1702
          RTS
L3341     LDA $1702
          ORA #$01
          STA $1702
          RTS
L334A     LDA $1702
          ORA #$02
          STA $1702
          RTS
          LDX #$08
          JSR L22E4
          LDA $0108
          BNE L3363
          JSR L332F
          JMP L205E
L3363     CMP #$01
          BEQ L336A
L3367     JMP L2435
L336A     JSR L3338
          JMP L205E
          LDX #$08
          JSR L22E4
          LDA $0108
          BNE L3380
          JSR L3341
          JMP L205E
L3380     CMP #$01
          BNE L3367
          JSR L334A
          JMP L205E
L338A     JSR L338D
L338D     JSR L3390
L3390     JSR L3393
L3393     LDX #$60
          STX $012D
          STX $012E
L339B     INC $012D
          BNE L339B
          INC $012E
          BNE L339B
          LDX #$00
          RTS
L33A8     JSR L334A
          JSR L3393
          RTS
L33AF     JSR L3341
          JSR L338A
          RTS
L33B6     JSR L3393
          JSR L3338
          RTS
L33BD     JSR L3393
          JSR L332F
          RTS
L33C4     PHA
          STY $E4
          STX $E5
          LDA $011F
          BEQ L33D3
          PLA
          PHA
          JSR L38D4
L33D3     PLA
          JSR L3BC9
          LDY $E4
          LDX $E5
          CLD
          RTS
L33DD     STY $E4
          STX $E5
          JSR L3C2A
          LDY $E4
          LDX $E5
          CLD
          RTS
L33EA     JSR L33F3
          NOP
          NOP
          NOP
          NOP
          NOP
          RTS
L33F3     LDA #$0D
          JSR L33C4
          RTS
L33F9     JSR L33FC
L33FC     LDA #$20
          JSR L33C4
          RTS
L3402     PHA
          LSR A
          LSR A
          LSR A
          LSR A
          JSR L340F
          PLA
          JSR L340F
          RTS
L340F     AND #$0F
          ORA #$30
          CMP #$3A
          BCC L3419
          ADC #$06
L3419     JSR L33C4
          RTS
          JSR L3423
          JMP L205C
L3423     JSR L21FA
          LDA $010B
          CMP #$FF
          BNE L3430
          JMP L243A
L3430     LDY #$00
          CLC
          SED
L3434     PHP
          CPY #$02
          BNE L3448
          JSR L23A2
          PLP
          BCC L3442
          JMP L243B
L3442     LDA ($DD),Y
          BNE L3430
          CLD
          RTS
L3448     PLP
          LDA $010A,Y
          ADC $0108,Y
          STA $0108,Y
          STA ($DD),Y
          INY
          BNE L3434
          LDA #$6F
          JMP L2DBB
L345C     LDX #$08
          JSR L22E4
L3461     STY $CE
          JSR L2212
          LDY $CE
          RTS
L3469     JSR L3487
L346C     LDA $0128
          CMP #$EE
          BEQ L3481
          LDA $0123
          BEQ L347B
          JMP L205C
L347B     JSR L34A9
          JMP L346C
L3481     JSR L209E
          JMP L205C
L3487     JSR L2199
          JSR L2690
          CMP #$20
          BNE L3497
L3491     JSR L2094
          CLC
          BCC L349B
L3497     CMP #$41
          BNE L34A6
L349B     LDA $D3
          STA $DD
          LDA $D4
          STA $DE
          CLC
          BCC L34A9
L34A6     JSR L345C
L34A9     JSR L33A8
          JSR L3531
          STA $0123
          JSR L3F98
          BNE L3520
          LDA $DD
          STA $0124
          LDA $DE
          STA $0125
          SEC
          LDA $012B
          SBC $0129
          PHA
          LDA $012C
          SBC $012A
          TAX
          PLA
          STA $D1
          CLC
          ADC $DD
          STA $0126
          TXA
          STA $D2
          ADC $DE
          STA $0127
          LDA #$00
          STA $0123
          LDA $0110
          BEQ L34F0
          CMP $0128
          BNE L350F
L34F0     INC $0123
          LDA $0127
          CMP $0103
          BCC L350F
          BNE L3505
          LDA $0126
          CMP $0102
          BCC L350F
L3505     LDA #$01
          STA $0112
          LDX #$00
          JMP L243C
L350F     JSR L3F98
          BNE L3520
          LDX #$00
          JSR L35B7
          JSR L33B6
          JSR L35CA
          RTS
L3520     LDX #$00
          LDA $0123
          BEQ L352A
          STA $0112
L352A     JSR L209E
          JSR L2434
          RTS
L3531     LDA #$28
          STA $0124
          LDA #$2D
          STA $0126
          LDA #$01
          STA $0125
          STA $0127
          RTS
          JSR L3B8C
          JSR L2690
          CMP #$20
          BEQ L3596
          CMP #$58
          BNE L3560
          LDA #$EE
          STA $0110
          STA $0109
          JSR L3461
          INY
          BNE L356A
L3560     JSR L2199
          CPY #$50
          BCS L3596
          JSR L345C
L356A     LDA $DD
          STA $0129
          LDA $DE
          STA $012A
          JSR L2510
          LDX #$08
          JSR L22E4
          LDY #$02
          LDA ($DD),Y
          BEQ L358C
          JSR L222A
          BCS L358C
          BPL L358C
          JSR L23A2
L358C     LDA $DD
          STA $012B
          LDA $DE
          STA $012C
L3596     JSR L218B
          JMP L205C
L359C     JSR L3531
          LDA $0110
          STA $0128
          JSR L35B3
          LDY #$03
L35AA     LDA $0129,Y
          STA $0124,Y
          DEY
          BPL L35AA
L35B3     JSR L3FC8
          RTS
L35B7     LDA $0123
          BEQ L35C9
          LDA $0126
          STA $D3
          LDA $0127
          STA $D4
          JSR L209E
L35C9     RTS
L35CA     LDA #$46
          JSR L33C4
          LDA $0128
          JSR L3402
          JSR L33F9
          LDA $D2
          JSR L3402
          LDA $D1
          JSR L3402
          LDA $0123
          BEQ L3607
          JSR L33F9
          LDA $0125
          JSR L3402
          LDA $0124
          JSR L3402
          LDA #$2D
          JSR L33C4
          LDA $0127
          JSR L3402
          LDA $0126
          JSR L3402
L3607     JSR L33EA
          RTS
L360B     LDA $362C,X
          STA $0100,X
          INX
          CPX #$08
          BCC L360B
          LDA $3634
          STA $C8
          LDA $3635
          STA $C9
          LDX #$00
L3622     JSR L2094
          JSR L2F57
          JSR L3075
          RTS
          .BYTE $63    ;%01100011 'c'
          EOR ($FC,X)
          .BYTE $53    ;%01010011 'S'
          BRK
          .BYTE $54    ;%01010100 'T'
          .BYTE $FC    ;%11111100
          LSR $5F00,X
          STY $0131
          JMP L3652
          STX $0131
          STX $DF
          JSR L266E
          BEQ L3652
          LDA $DF
          BNE L3652
          JMP L37E7
L364D     LDX #$00
          JMP L2436
L3652     LDA #$25
          STA $CF
          STX $DB
          STX $DC
          INC $0133
          LDX #$02
          LDA $0135,Y
          STA $CD
          INY
          TYA
          STA $018F,X
L3669     CPX #$01
          BNE L3672
          LDA $0131
          BNE L3688
L3672     LDA $0135,Y
          STA $018F,Y
          INY
          CPY #$4C
          BCS L364D
          CMP $CD
          BNE L3669
          TYA
          DEX
          STA $018F,X
          BNE L3669
L3688     LDA $0190
          CLC
          SBC $0191
          BEQ L364D
          LDX #$00
          STX $0192
          JSR L2510
          LDA $0135,Y
          CMP #$25
          BNE L36AD
          INY
          LDA $0135,Y
          STA $CF
          INY
          JSR L2510
          LDA $0135,Y
L36AD     CMP #$2A
          BNE L36B6
          INC $0192
          BNE L36BD
L36B6     CMP #$23
          BNE L36C0
          DEC $0192
L36BD     JSR L250D
L36C0     JSR L21FA
L36C3     LDY #$02
          LDA ($DD),Y
          BNE L36CC
          JMP L3754
L36CC     JSR L37C5
          STX $0118
L36D2     LDX $0191
          LDY $0118
L36D8     CPY $CE
          BEQ L36DE
          BCS L36FE
L36DE     LDA $018F,X
          CMP $CF
          BEQ L36FA
          CMP $CD
          BNE L36F0
          LDX #$00
          STY $018E
          BEQ L3714
L36F0     CMP $0135,Y
          BEQ L36FA
L36F5     INC $0118
          BNE L36D2
L36FA     INX
          INY
          BNE L36D8
L36FE     LDX #$00
L3700     JSR L23A2
          LDY #$02
L3705     DEY
          BMI L3711
          LDA $010A,Y
          CMP ($DD),Y
          BEQ L3705
          BCC L3754
L3711     JMP L36C3
L3714     JSR L37D7
          LDA $0131
          BNE L3723
          LDA $0192
          BMI L377C
          BEQ L377C
L3723     LDA $0192
          BMI L3737
          JSR L33FC
          LDA $0118
          JSR L3402
          JSR L384B
L3734     JSR L33EA
L3737     LDA $0131
          BNE L36F5
          LDA #$2A
          JSR L33C4
          JSR L33DD
          JSR L2693
          PHA
          JSR L33EA
          PLA
          CMP #$53
          BEQ L36FE
          CMP #$58
          BNE L375D
L3754     JSR L21ED
          JSR L2F2F
          JMP L205E
L375D     CMP #$4D
          BEQ L36F5
          CMP #$41
          BEQ L377C
          CMP #$06
          BNE L3772
          JSR L37FD
          JSR L33EA
          JMP L36FE
L3772     CMP #$44
          BNE L3734
          JSR L2362
          JMP L3700
L377C     LDA $0131
          BEQ L3784
          JMP L36F5
L3784     LDA $018E
          TAY
          SEC
          SBC $0118
          TAX
L378D     JSR L389B
          DEX
          BNE L378D
          LDX $0190
L3796     LDA $018F,X
          CMP $CD
          BEQ L37A4
          JSR L3872
          INY
          INX
          BNE L3796
L37A4     STY $0118
          JSR L38B5
          BCS L37AF
          JMP L3711
L37AF     LDA $0192
          BPL L37BC
          LDA #$00
          JSR L33C4
          JMP L36D2
L37BC     JSR L384B
          JSR L33EA
          JMP L36D2
L37C5     LDA $010F
          PHA
          STX $010F
          JSR L23B0
          PLA
          STA $010F
          INY
          STY $CE
          RTS
L37D7     SED
          CLC
          LDA $DB
          ADC #$01
          STA $DB
          LDA $DC
          ADC #$00
          STA $DC
          CLD
          RTS
L37E7     JSR L21FA
          BPL L37FA
          BCS L37FA
          JSR L37C5
          JSR L2598
          JSR L33EA
          JSR L37FD
L37FA     JMP L205E
L37FD     LDY #$00
L37FF     JSR L33DD
          CMP #$06
          BNE L382C
          LDA #$3E
          JSR L33C4
          JSR L33DD
          CMP #$06
          BEQ L37FF
          STA $018D
L3815     INY
          CPY $CE
          BCC L381D
          BEQ L381D
          RTS
L381D     LDA $0134,Y
          PHA
          JSR L33C4
          PLA
          CMP $018D
          BNE L3815
          BEQ L37FF
L382C     CMP #$08
          BEQ L3839
          CMP #$7F
          BNE L383F
          LDA #$5C
          JSR L33C4
L3839     JSR L389B
          JMP L37FF
L383F     CMP #$0D
          BNE L385A
          JSR L38B5
L3846     BCC L3859
          JSR L33EA
L384B     JSR L33FC
          JSR L2622
          JSR L33F9
          LDY $CE
          JSR L2598
L3859     RTS
L385A     CMP #$04
          BNE L386B
          JSR L33EA
          DEY
          STY $CE
          INY
          JSR L38B7
          JMP L3846
L386B     JSR L3872
          INY
          JMP L37FF
L3872     PHA
          STY $0119
          LDY $CE
L3878     LDA $0135,Y
          STA $0136,Y
          DEY
          BMI L3886
          CPY $0119
          BCS L3878
L3886     PLA
          INY
          STA $0135,Y
          CPY #$4C
          BCC L3890
          DEY
L3890     INC $CE
          LDA $CE
          CMP #$4C
          BCC L389A
          DEC $CE
L389A     RTS
L389B     DEY
          BPL L389F
          INY
L389F     TYA
          PHA
L38A1     INY
          LDA $0135,Y
          STA $0134,Y
          CPY $CE
          BCC L38A1
          DEC $CE
          BPL L38B2
          INC $CE
L38B2     PLA
          TAY
          RTS
L38B5     LDY $CE
L38B7     INY
          CPY #$52
          BCC L38BE
          LDY #$51
L38BE     STY $011A
          LDX #$00
          JSR L2362
          LDY $011A
          CPY #$02
          BCC L38D3
          LDY #$00
          JSR L22FA
          SEC
L38D3     RTS
L38D4     NOP
          NOP
          NOP
          CMP #$0A
          BNE L392E
          INC $0120
          LDA $0120
          CMP #$04
          BEQ L3902
          CMP #$40
          BNE L392E
L38E9     LDA #$0A
          JSR L33C4
L38EE     LDA $0120
          CMP #$3F
          BNE L38F9
          LDA #$0A
          BNE L38D4
L38F9     CMP #$46
          BNE L38E9
          LDA #$04
          STA $0120
L3902     LDA #$24
          STA $012D
L3907     JSR L33FC
          DEC $012D
          BNE L3907
          TYA
          PHA
          LDY #$41
          JSR L252C
          PLA
          TAY
          LDA $0121
          PHA
          JSR L3402
          PLA
          SED
          CLC
          ADC #$01
          CLD
          STA $0121
          JSR L33EA
          JSR L33EA
L392E     RTS
          JSR L2690
          CMP #$50
          BEQ L3952
          STX $011F
          CMP #$53
          BNE L3943
          STX $0120
          INC $011F
L3943     JSR L250D
          CPY #$50
          BCS L394F
          LDX #$21
          JSR L22E4
L394F     JMP L205E
L3952     LDA $011F
          BEQ L3943
          TYA
          PHA
          JSR L38EE
          PLA
          TAY
          JMP L3943
          JSR L3967
          JMP L205C
L3967     JSR L2510
          LDX #$08
          JSR L22E4
          LDA $0108
          PHA
          LDA $0109
          PHA
          STY $CE
          JSR L2212
          BPL L3981
          JSR L23A2
L3981     LDA $DD
          STA $E1
          LDA $DE
          STA $E2
          LDY $CE
          JSR L2510
          JSR L21FA
          PHP
          LDA $010B
          CMP #$FF
          BNE L399C
          JMP L243A
L399C     JSR L249F
          PLP
          BPL L39A5
          JSR L23A2
L39A5     JSR L3A97
          JSR L2215
          BPL L39B0
          JSR L23A2
L39B0     PLA
          STA $0109
          PLA
          STA $0108
          SEC
          LDA $DD
          SBC $DF
          STA $D7
          LDA $DE
          SBC $E0
          STA $D8
          LDA $D7
          CLC
          ADC $D3
          STA $D9
          PHA
          LDA $D8
          ADC $D4
          STA $DA
          PHA
          CMP $0103
          BEQ L39DE
          BCC L39E5
L39DB     JMP L243C
L39DE     LDA $D9
          CMP $0102
          BCS L39DB
L39E5     LDA $E2
          CMP $DE
          BEQ L39EF
          BCC L39F5
          BCS L3A27
L39EF     LDA $E1
          CMP $DD
          BCS L3A27
L39F5     LDA $E0
          CMP $E2
          BEQ L39FF
          BCC L3A05
          BCS L3A08
L39FF     LDA $DF
          CMP $E1
          BCS L3A08
L3A05     JMP L2439
L3A08     LDX #$02
L3A0A     CLC
          LDA $DD,X
          ADC $D7
          STA $DD,X
          LDA $DE,X
          ADC $D8
          STA $DE,X
          DEX
          DEX
          BPL L3A0A
          LDX #$00
L3A1D     JSR L24ED
          JSR L24E7
          LDA ($D3,X)
          STA ($D9,X)
L3A27     LDA $E2
          CMP $D4
          BNE L3A1D
          LDA $E1
          CMP $D3
          BNE L3A1D
          LDA $DF
          PHA
          LDA $E0
          PHA
          LDA $E1
          STA $D7
          LDA $E2
          STA $D8
L3A41     LDA $DD
          CMP $DF
L3A45     BNE L3A4D
          LDA $DE
          CMP $E0
          BEQ L3A5A
L3A4D     LDA ($DF,X)
          STA ($E1,X)
          JSR L24D1
          JSR L24D0
          JMP L3A41
L3A5A     PLA
          STA $E0
          PLA
          STA $DF
          PLA
          STA $D4
          PLA
          STA $D3
          JSR L209E
          LDA $DE
          PHA
          LDA $DD
          PHA
          LDY #$02
          LDA ($E1),Y
          PHA
          LDA #$00
          STA ($E1),Y
          STA $010A
          STA $010B
          LDA $D7
          STA $DD
          LDA $D8
          STA $DE
          LDA ($DD),Y
          BEQ L3A8D
          JSR L3430
L3A8D     PLA
          STA ($E1),Y
          PLA
          STA $DD
          PLA
          STA $DE
          RTS
L3A97     LDA $010A
          STA $0108
          LDA $010B
          STA $0109
          RTS
          JSR L3967
          JSR L2370
          JMP L205C
          JSR L2510
          CPY #$40
          BCC L3AB7
          JMP L243A
L3AB7     JSR L21FA
          BEQ L3AD7
          PHP
          JSR L249F
          JSR L3A97
          PLP
          BPL L3AC9
          JSR L23A2
L3AC9     JSR L2215
          BPL L3AD1
          JSR L23A2
L3AD1     JSR L2370
          JMP L205C
L3AD7     JMP L2439
          INC $0113
          STX $0111
L3AE0     CPY #$50
          BCS L3B14
          TXA
          PHA
          LDX #$00
          JSR L3260
          PLA
          TAX
          LDA $D1
          STA $0100,X
          INX
          LDA $D2
          STA $0100,X
          INX
          JSR L2510
          CPX #$08
          BCC L3AE0
          CPY #$50
          BCS L3B14
          LDX #$00
          JSR L3260
          LDA $D1
          STA $C8
          LDA $D2
          STA $C9
          JSR L3622
L3B14     LDX #$00
          JSR L33EA
L3B19     LDA $0101,X
          JSR L3402
          LDA $0100,X
          JSR L3402
          CPX #$00
          BNE L3B31
L3B29     LDA #$2D
          JSR L33C4
          JMP L3B38
L3B31     CPX #$04
          BEQ L3B29
          JSR L33F9
L3B38     INX
          INX
          CPX #$08
          BCC L3B19
          LDA $C9
          JSR L3402
          LDA $C8
          JSR L3402
          JSR L33EA
          LDA $D4
          JSR L3402
          LDA $D3
          JSR L3402
          JSR L33F9
          LDA $D6
          JSR L3402
          LDA $D5
          JSR L3402
          JSR L33EA
          JMP L205C
          JSR L2199
L3B6B     STX $0110
          JSR L3491
          LDA $0128
          STA $0110
          CMP #$EE
          BEQ L3B89
          CMP $010A
          BEQ L3B89
          JSR L3B8C
          JSR L218B
          JMP L3B6B
L3B89     JMP L205C
L3B8C     LDX #$01
L3B8E     LDA $0100,X
          STA $0129,X
          LDA $D3,X
          STA $012B,X
          DEX
          BPL L3B8E
          INX
          RTS
          STX $AD
          CPY #$50
          BCS L3BA6
          INC $AD
L3BA6     JSR L3BAC
          JMP L205C
L3BAC     JMP ($00B0)
          STX $AC
          CPY #$50
          BCS L3BB7
          INC $AC
L3BB7     JSR L3BBD
          JMP L205C
L3BBD     JMP ($00B2)
          JSR L3BC6
          JMP L205C
L3BC6     JMP ($00AE)
L3BC9     JSR L3BF1
          CMP #$0D
          NOP
          BNE L3BF0
          NOP
          JSR L3F77
          BCC L3BF0
          PHA
          NOP
          NOP
L3BDA     JSR L3C2A
          CMP #$0F
          BNE L3BEB
          LDA #$0D
          NOP
          NOP
          NOP
          JSR L3C27
          PLA
          RTS
L3BEB     CMP #$11
          BNE L3BDA
          PLA
L3BF0     RTS
L3BF1     AND #$7F
          PHA
          LDA $E3
          BEQ L3BFA
          PLA
          RTS
L3BFA     PLA
          PHA
          CMP #$00
          BEQ L3C22
          CMP #$1B
          BEQ L3C22
          CMP #$0D
          BEQ L3C22
          CMP #$0A
          BEQ L3C22
          CMP #$07
          BEQ L3C22
          CMP #$08
          BEQ L3C22
          CMP #$20
          BCS L3C22
          PHA
          LDA #$5E
          JSR L3C27
          PLA
          CLC
          ADC #$40
L3C22     JSR L3C27
          PLA
          RTS
L3C27     JMP L3FE8
L3C2A     LDA #$00
          STA $E3
L3C2E     JSR L3C89
          CMP #$00
          BEQ L3C2E
          CMP #$1A
          BNE L3C3C
          JMP L205C
L3C3C     CMP #$03
          BNE L3C43
          JMP L20A4
L3C43     CMP #$19
          BNE L3C4A
          JMP $0000
L3C4A     CMP #$02
          BNE L3C56
          NOP
          NOP
          NOP
          NOP
          NOP
          JMP $0006
L3C56     CMP #$07
          BNE L3C5D
          NOP
          NOP
          NOP
L3C5D     CMP #$0F
          BNE L3C64
          INC $E3
          RTS
L3C64     CMP #$14
          BNE L3C88
          JSR L3C89
          CMP #$30
          BEQ L3C7E
          CMP #$31
          BNE L3C88
          LDA $1702
          EOR #$02
          STA $1702
          JMP L3C86
L3C7E     LDA $1702
          EOR #$01
          STA $1702
L3C86     LDA #$18
L3C88     RTS
L3C89     JSR $1E5A
          AND #$7F
          PHA
          LDA $0133
          BNE L3C9E
          PLA
          PHA
          CMP #$11
          BEQ L3CA3
          CMP #$09
          BEQ L3CA3
L3C9E     PLA
          NOP
          NOP
          NOP
          RTS
L3CA3     PLA
          RTS
L3CA5     LDX #$00
          LDA $0138,Y
          CMP #$20
          BNE L3CB1
          JSR L3D5E
L3CB1     LDA #$01
          STA $BD
          JSR L3130
          BCS L3CC0
L3CBA     JSR L2449
          JMP L2C04
L3CC0     LDA $C0
          BEQ L3CBA
          LDA $0135,Y
          CMP #$20
          BEQ L3CD1
          JSR L2449
          JMP L2C04
L3CD1     LDA $01FF
          CMP $0119
          BEQ L3CE3
          BCS L3CEB
L3CDB     LDX #$20
          JSR L244B
          JMP L2C04
L3CE3     LDA $01FE
          CMP $0118
          BCC L3CDB
L3CEB     LDA $0119
          PHA
          LDA $0118
          PHA
          STX $BD
          STX $018F
          JSR L250D
          CPY #$50
          BCS L3D38
          CMP #$3B
          BEQ L3D38
          CMP #$28
          BEQ L3D0F
          JSR L2441
          PLA
          PLA
          JMP L2C04
L3D0F     INY
L3D10     JSR L2510
          CPY #$50
          BCS L3D38
          LDA $0135,Y
          CMP #$29
          BEQ L3D38
          TXA
          PHA
          LDX #$00
          JSR L30D7
          PLA
          TAX
          LDA $D1
          STA $0190,X
          LDA $D2
          INX
          STA $0190,X
          INX
          INC $018F
          BNE L3D10
L3D38     LDX #$00
          PLA
          STA $DD
          PLA
          STA $DE
          PHA
          LDA $DD
          PHA
          JSR L2F67
          LDA #$01
          STA $BE
          INC $BC
          LDA $BC
          CMP #$20
          BCC L3D5B
          LDX #$24
          STX $0112
          JMP L244B
L3D5B     JMP L2C8A
L3D5E     LDA $0135,Y
          JSR L2693
          CMP $3DA0,X
          BNE L3D93
          LDA $0136,Y
          JSR L2693
          CMP $3DA1,X
          BNE L3D93
          LDA $0137,Y
          JSR L2693
          CMP $3DA2,X
          BNE L3D93
          LDA $3DA3,X
          STA $E1
          LDA $3DA4,X
          STA $E2
          PLA
          PLA
          INY
          INY
          INY
          LDX #$00
          JMP L2729
L3D93     INX
          INX
          INX
          INX
          INX
          LDA $3DA0,X
          BNE L3D5E
          LDX #$00
          RTS
          EOR #$46
          EOR $12
          ROL $4649,X
          LSR $3E22
          EOR #$46
          BVC L3DDD
          ROL $4649,X
          EOR $3E3B
          .BYTE $53    ;%01010011 'S'
          EOR $54
          ADC $3E
          ROL A
          ROL A
          ROL A
          BRK
          ROL $452E,X
          LSR $2B5C
          BRK
          ROL $454D
          ORA $3E
          ROL $444D
          ASL A
          ROL $452E,X
          LSR $2B5C
          BRK
          BIT $2958
          .BYTE $3B    ;%00111011 ';'
          ROL $2C29
          EOR $2E3C,Y
          BRK
          BIT $2058
          ROL $2C2E,X
          EOR $3D20,Y
          ROL $2C00
          CLI
          JSR L2E2C
          BIT $2059
          .BYTE $2B    ;%00101011 '+'
          ROL $2300
          JMP $9B2C
          AND $4823
          BIT $2DAC
          BRK
          STX $BF
          JMP L2C04
          STX $BB
          JMP L2C04
          LDX #$29
          JSR L244B
          JMP L2C04
          JSR L3E47
          LDA $D1
          BNE L3E1F
          LDA $D2
          BNE L3E1F
L3E1D     STX $BF
L3E1F     JMP L2C04
          JSR L3E47
          LDA $D1
          BNE L3E1D
          LDA $D2
          BEQ L3E1F
          BNE L3E1D
          JSR L3E47
          LDA $D2
          BMI L3E38
          STX $BF
L3E38     JMP L2C04
          JSR L3E47
          LDA $D2
          BPL L3E44
          STX $BF
L3E44     JMP L2C04
L3E47     STY $BF
L3E49     JSR L2510
          JSR L3260
          LDA $011A
          BEQ L3E5A
L3E54     STY $0112
          JSR L2447
L3E5A     RTS
          STY $C1
          JMP L2C04
          STX $C1
          JMP L2C04
          JSR L3130
          BCS L3E6D
          JMP L3E54
L3E6D     LDA $C0
          BNE L3E79
          LDX #$2A
          JSR L244B
          JMP L2C04
L3E79     JSR L2510
          LDA $0135,Y
          CMP #$3D
          BEQ L3E89
          JSR L2441
          JMP L2C04
L3E89     LDA $DE
          PHA
          LDA $DD
          PHA
          INY
          JSR L3E49
          PLA
          STA $DD
          PLA
          STA $DE
          LDY #$00
          LDA $D1
          STA ($DD),Y
          LDA $D2
          INY
          STA ($DD),Y
          JMP L2C04
          LDA $BC
          BEQ L3EB7
          LDA $BE
          BNE L3ECF
          LDX #$29
          JSR L244B
          JMP L2C04
L3EB7     INC $BB
          LDA $0113
          BNE L3ECC
          LDY #$00
          PLA
          STA ($DD),Y
          PLA
          PHA
          INY
          STA ($DD),Y
          DEY
          LDA ($DD),Y
          PHA
L3ECC     JMP L2C04
L3ECF     INC $C2
          BNE L3EDC
          INC $C3
          BNE L3EDC
          LDX #$2E
          JSR L244B
L3EDC     STX $BE
          STX $BD
          LDA $018F
          BEQ L3F40
          LDA $0135,Y
          CMP #$28
          BEQ L3EF4
L3EEC     LDX #$25
          JSR L244B
L3EF1     JMP L3F56
L3EF4     STX $E5
          INY
L3EF7     JSR L2510
          CMP #$3B
          BEQ L3F38
          CPY #$50
          BCS L3F38
          CMP #$29
          BEQ L3F38
          STY $E4
          JSR L3130
          BCS L3F14
          LDY $E4
          JSR L2F99
          BCS L3EF1
L3F14     STY $E4
          LDY #$00
          LDX $E5
          LDA $0190,X
          STA ($DD),Y
          INX
          LDA $0190,X
          INX
          INY
          STA ($DD),Y
          LDY $E4
          STX $E5
          LDX #$00
          DEC $018F
          BMI L3EEC
          JSR L2503
          JMP L3EF7
L3F38     LDA $018F
          BNE L3EEC
L3F3D     JMP L2C04
L3F40     LDA $0135,Y
          CMP #$3B
          BEQ L3F3D
          CPY #$50
          BCS L3F3D
          BCC L3EEC
          LDA $BC
          BNE L3F56
          STX $BB
          JMP L2C04
L3F56     STX $E6
          DEC $BC
          BMI L3F6D
          BEQ L3F68
          DEC $C2
          LDA $C2
          CMP #$FF
          BNE L3F68
          DEC $C3
L3F68     PLA
          PLA
          JMP L2C04
L3F6D     STX $BC
          LDX #$2B
          JSR L244B
          JMP L2C04
L3F77     BIT $1740
          CLC
          BMI L3F86
L3F7D     BIT $1740
          BPL L3F7D
          JSR $1E5A
          SEC
L3F86     RTS
L3F87     PHA
L3F88     PHA
L3F89     SBC #$01
          BNE L3F89
          PLA
          SBC #$01
          BNE L3F88
          PLA
          SBC #$01
          BNE L3F87
          RTS
L3F98     LDA $AC
          BEQ L3FA3
          JSR L3FA0
          RTS
L3FA0     JMP ($00B6)
L3FA3     JMP L40A5
L3FA6     LDA #$00
          STA $17FE
          LDA #$1C
          STA $17FF
          LDA $1703
          ORA #$0B
          STA $1703
          RTS
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
          BRK
L3FC8     LDA $AD
          BEQ L3FD3
          JSR L3FD0
          RTS
L3FD0     JMP ($00B4)
L3FD3     JMP L4000
L3FD6     LDA #$1F
          JSR L3F87
          LDA #$0A
          JSR L3FE8
          LDA #$1F
          JSR L3F87
          NOP
          NOP
          NOP
L3FE8     PHA
          NOP
          NOP
          NOP
          NOP
          NOP
          JSR $1EA0
          PLA
          CMP #$0D
          BEQ L3FD6
          RTS
          BRK
          BRK
          BRK
          BRK
          .BYTE $22    ;%00100010 ''
          BRK
          .BYTE $FF    ;%11111111
          .BYTE $FF    ;%11111111
          .BYTE $FF    ;%11111111
L4000     LDA $1703
          ORA #$08
          STA $1703
          LDA #$E0
          STA $B6
L400C     LDA #$16
          JSR L4041
          LDA #$10
          STA $B4
L4015     JSR L405D
          DEC $B4
          BNE L4015
          DEC $B6
          BNE L400C
          JSR L4084
          LDA #$0F
          JSR L4041
          LDX #$00
          STX $B2
          STX $B3
L402E     LDA ($B6,X)
          JSR L4041
          JSR L408F
          BCC L402E
          LDA $B3
          PHA
          LDA $B2
          JSR L4041
          PLA
L4041     STA $B4
          JSR L4134
          JSR L407C
          LDA #$08
          STA $B5
L404D     ASL $B4
          BCC L4056
          JSR L407C
          BEQ L4059
L4056     JSR L405D
L4059     DEC $B5
          BNE L404D
L405D     LDA #$20
L405F     PHA
          LDA $1702
          ORA #$08
          STA $1702
          PLA
          PHA
          TAX
          JSR L4078
          LDA $1702
          AND #$F7
          STA $1702
          PLA
          TAX
L4078     DEX
          BNE L4078
          RTS
L407C     LDA #$50
          BNE L405F
L4080     LDX #$30
          BNE L4078
L4084     LDA $0124
          STA $B6
          LDA $0125
          STA $B7
          RTS
L408F     INC $B6
          BNE L4095
          INC $B7
L4095     LDA $B7
          CMP $0127
          BCC L40A4
          LDA $B6
          CMP $0126
          BCC L40A4
          SEC
L40A4     RTS
L40A5     LDX #$00
          STX $B6
L40A9     JSR L40EF
          CMP #$16
          BNE L40B4
          INC $B6
          BNE L40A9
L40B4     LDY $B6
          CPY #$0A
          BCC L40A5
          CMP #$0F
          BNE L40A5
          LDY #$00
          STY $B2
          STY $B3
          JSR L4084
L40C7     JSR L40EF
          LDY $0123
          BEQ L40D1
          STA ($B6,X)
L40D1     JSR L408F
          BCC L40C7
          LDA $B3
          PHA
          LDA $B2
          PHA
          JSR L40EF
          PLA
          CMP $B4
          BNE L40EB
          JSR L40EF
          PLA
          CMP $B4
          RTS
L40EB     PLA
          LDA #$FF
          RTS
L40EF     JSR L415B
          BNE L40EF
L40F4     JSR L415B
          BEQ L40F4
          JSR L4080
          JSR L415B
          BEQ L40F4
L4101     JSR L415B
          BNE L4101
          LDA #$08
          STA $B5
L410A     JSR L415B
          BEQ L410A
          JSR L4080
          JSR L415B
          BEQ L411F
L4117     JSR L415B
          BNE L4117
          SEC
          BCS L4120
L411F     CLC
L4120     ROL $B4
          DEC $B5
          BNE L410A
          LDA $B4
          JSR L4134
          LDA $B4
          RTS
          LDA $1702
          AND #$04
          RTS
L4134     CLC
          CLD
          ADC $B2
          STA $B2
          LDA #$00
          ADC $B3
          STA $B3
          RTS
L4141     JSR L40A5
          BNE L414E
          LDA #$00
L4148     BRK
          NOP
          NOP
          JMP L4141
L414E     LDA #$EE
L4150     BNE L4148
L4152     JSR L4000
          BRK
          NOP
          NOP
          JMP L4152
L415B     LDA $1702
          AND #$FF
          AND #$04
          RTS
          .END

;auto-generated symbols and labels
 L2010      $2010
 L2056      $2056
 L2070      $2070
 L2094      $2094
 L2121      $2121
 L2147      $2147
 L2169      $2169
 L2172      $2172
 L2199      $2199
 L2212      $2212
 L2215      $2215
 L2247      $2247
 L2254      $2254
 L2257      $2257
 L2262      $2262
 L2272      $2272
 L2273      $2273
 L2283      $2283
 L2294      $2294
 L2310      $2310
 L2313      $2313
 L2327      $2327
 L2331      $2331
 L2362      $2362
 L2367      $2367
 L2368      $2368
 L2370      $2370
 L2385      $2385
 L2392      $2392
 L2400      $2400
 L2407      $2407
 L2426      $2426
 L2434      $2434
 L2435      $2435
 L2436      $2436
 L2439      $2439
 L2440      $2440
 L2441      $2441
 L2442      $2442
 L2443      $2443
 L2444      $2444
 L2445      $2445
 L2446      $2446
 L2447      $2447
 L2448      $2448
 L2449      $2449
 L2498      $2498
 L2503      $2503
 L2510      $2510
 L2532      $2532
 L2598      $2598
 L2605      $2605
 L2607      $2607
 L2616      $2616
 L2622      $2622
 L2625      $2625
 L2632      $2632
 L2646      $2646
 L2654      $2654
 L2659      $2659
 L2688      $2688
 L2690      $2690
 L2693      $2693
 L2707      $2707
 L2713      $2713
 L2729      $2729
 L2790      $2790
 L2795      $2795
 L2891      $2891
 L2954      $2954
 L3004      $3004
 L3016      $3016
 L3030      $3030
 L3052      $3052
 L3063      $3063
 L3066      $3066
 L3075      $3075
 L3081      $3081
 L3094      $3094
 L3103      $3103
 L3115      $3115
 L3130      $3130
 L3144      $3144
 L3152      $3152
 L3155      $3155
 L3156      $3156
 L3175      $3175
 L3183      $3183
 L3199      $3199
 L3236      $3236
 L3237      $3237
 L3258      $3258
 L3260      $3260
 L3266      $3266
 L3276      $3276
 L3277      $3277
 L3278      $3278
 L3280      $3280
 L3285      $3285
 L3305      $3305
 L3310      $3310
 L3316      $3316
 L3325      $3325
 L3328      $3328
 L3338      $3338
 L3341      $3341
 L3363      $3363
 L3367      $3367
 L3380      $3380
 L3390      $3390
 L3393      $3393
 L3402      $3402
 L3419      $3419
 L3423      $3423
 L3430      $3430
 L3434      $3434
 L3442      $3442
 L3448      $3448
 L3453      $3453
 L3461      $3461
 L3469      $3469
 L3481      $3481
 L3487      $3487
 L3491      $3491
 L3497      $3497
 L3505      $3505
 L3520      $3520
 L3531      $3531
 L3560      $3560
 L3596      $3596
 L3607      $3607
 L3622      $3622
 L3652      $3652
 L3669      $3669
 L3672      $3672
 L3688      $3688
 L3700      $3700
 L3705      $3705
 L3711      $3711
 L3714      $3714
 L3723      $3723
 L3734      $3734
 L3737      $3737
 L3754      $3754
 L3772      $3772
 L3784      $3784
 L3796      $3796
 L3815      $3815
 L3839      $3839
 L3846      $3846
 L3859      $3859
 L3872      $3872
 L3878      $3878
 L3886      $3886
 L3890      $3890
 L3902      $3902
 L3907      $3907
 L3931      $3931
 L3943      $3943
 L3952      $3952
 L3967      $3967
 L3981      $3981
 L4000      $4000
 L4015      $4015
 L4041      $4041
 L4056      $4056
 L4059      $4059
 L4078      $4078
 L4080      $4080
 L4084      $4084
 L4095      $4095
 L4101      $4101
 L4117      $4117
 L4120      $4120
 L4134      $4134
 L4141      $4141
 L4148      $4148
 L4150      $4150
 L4152      $4152
 L20AC      $20AC
 L360B      $360B
 L3FA6      $3FA6
 L252C      $252C
 L3B14      $3B14
 L332F      $332F
 L33EA      $33EA
 L269E      $269E
 L244B      $244B
 L205C      $205C
 L22E4      $22E4
 L205E      $205E
 L20CD      $20CD
 L250D      $250D
 L20E7      $20E7
 L20F7      $20F7
 L2F57      $2F57
 L211E      $211E
 L21FA      $21FA
 L2BC0      $2BC0
 L21C9      $21C9
 L21B3      $21B3
 L33AF      $33AF
 L359C      $359C
 L33BD      $33BD
 L21B2      $21B2
 L21C5      $21C5
 L21B9      $21B9
 L21E6      $21E6
 L23B0      $23B0
 L21D7      $21D7
 L33F9      $33F9
 L23A2      $23A2
 L21B7      $21B7
 L21ED      $21ED
 L33C4      $33C4
 L220A      $220A
 L24BA      $24BA
 L221D      $221D
 L221B      $221B
 L222A      $222A
 L2E90      $2E90
 L2E31      $2E31
 L2BB1      $2BB1
 L25AB      $25AB
 L22FA      $22FA
 L22EF      $22EF
 L22C0      $22C0
 L22C3      $22C3
 L22D2      $22D2
 L22E3      $22E3
 L22D3      $22D3
 L22DE      $22DE
 L24A8      $24A8
 L231C      $231C
 L243C      $243C
 L24B1      $24B1
 L24E4      $24E4
 L24E3      $24E3
 L234C      $234C
 L209E      $209E
 L249F      $249F
 L24D2      $24D2
 L24D1      $24D1
 L23A5      $23A5
 L23F1      $23F1
 L23D1      $23D1
 L23F7      $23F7
 L23EE      $23EE
 L241D      $241D
 L242D      $242D
 L37D7      $37D7
 L245A      $245A
 L2F62      $2F62
 L24E0      $24E0
 L24F7      $24F7
 L250A      $250A
 L251E      $251E
 L251D      $251D
 L252B      $252B
 L3A45      $3A45
 L202F      $202F
 L25BC      $25BC
 L259A      $259A
 L33DD      $33DD
 L25C4      $25C4
 L25D1      $25D1
 L25EA      $25EA
 L25DC      $25DC
 L25B5      $25B5
 L25AD      $25AD
 L25C1      $25C1
 L259B      $259B
 L33FC      $33FC
 L25FF      $25FF
 L261A      $261A
 L266E      $266E
 L263E      $263E
 L268D      $268D
 L269D      $269D
 L26A8      $26A8
 L26C0      $26C0
 L26BA      $26BA
 L26C6      $26C6
 L26FB      $26FB
 L26E2      $26E2
 L26E3      $26E3
 L26ED      $26ED
 L26AC      $26AC
 L26AE      $26AE
 L270C      $270C
 L272C      $272C
 L204D      $204D
 L414C      $414C
 L27B2      $27B2
 L2D5E      $2D5E
 L2D53      $2D53
 L2E2A      $2E2A
 L28CF      $28CF
 L28D7      $28D7
 L28DB      $28DB
 L28B9      $28B9
 L28DD      $28DD
 L28E1      $28E1
 L28E5      $28E5
 L28F9      $28F9
 L28F1      $28F1
 L28F5      $28F5
 L28B7      $28B7
 L295D      $295D
 L2C04      $2C04
 L29BC      $29BC
 L2EDF      $2EDF
 L29CA      $29CA
 L2A01      $2A01
 L2A18      $2A18
 L38EE      $38EE
 L2DBB      $2DBB
 L2A3C      $2A3C
 L2A67      $2A67
 L2A88      $2A88
 L2B50      $2B50
 L2A90      $2A90
 L2F0D      $2F0D
 L2AE4      $2AE4
 L2AC7      $2AC7
 L2AAC      $2AAC
 L2AC1      $2AC1
 L2ADE      $2ADE
 L2AB4      $2AB4
 L2ACF      $2ACF
 L2AF2      $2AF2
 L2B28      $2B28
 L2B22      $2B22
 L2B07      $2B07
 L2B0C      $2B0C
 L24D6      $24D6
 L2B38      $2B38
 L2B4F      $2B4F
 L2F67      $2F67
 L2B6D      $2B6D
 L2B71      $2B71
 L2B75      $2B75
 L2B7A      $2B7A
 L2B77      $2B77
 L2B8D      $2B8D
 L2B87      $2B87
 L2F1E      $2F1E
 L2C0F      $2C0F
 L2F10      $2F10
 L2C8A      $2C8A
 L2C26      $2C26
 L2C33      $2C33
 L2C40      $2C40
 L2C58      $2C58
 L349B      $349B
 L2CA6      $2CA6
 L2CA3      $2CA3
 L2CB9      $2CB9
 L2CC7      $2CC7
 L3D5E      $3D5E
 L2CD3      $2CD3
 L2CDF      $2CDF
 L2CEB      $2CEB
 L2F99      $2F99
 L24FA      $24FA
 L2CDC      $2CDC
 L2D15      $2D15
 L2D0B      $2D0B
 L2D05      $2D05
 L2D6C      $2D6C
 L26A2      $26A2
 L2D2A      $2D2A
 L2D65      $2D65
 L2D62      $2D62
 L2D59      $2D59
 L244A      $244A
 L2D24      $2D24
 L27AC      $27AC
 L26A6      $26A6
 L2D6F      $2D6F
 L3CA5      $3CA5
 L2DF2      $2DF2
 L2E5D      $2E5D
 L2D91      $2D91
 L2DCE      $2DCE
 L2DD1      $2DD1
 L2DD5      $2DD5
 L2E09      $2E09
 L30D7      $30D7
 L2E3F      $2E3F
 L2E23      $2E23
 L2E1C      $2E1C
 L2E2D      $2E2D
 L2DDD      $2DDD
 L2E5A      $2E5A
 L2E81      $2E81
 L2E75      $2E75
 L2E6D      $2E6D
 L2E8D      $2E8D
 L2E87      $2E87
 L2E83      $2E83
 L2E7B      $2E7B
 L2EEF      $2EEF
 L2EF3      $2EF3
 L2ED0      $2ED0
 L2EA7      $2EA7
 L2EB2      $2EB2
 L2EC1      $2EC1
 L2EAB      $2EAB
 L24D5      $24D5
 L24D4      $24D4
 L2ED8      $2ED8
 L223A      $223A
 L2F02      $2F02
 L2F05      $2F05
 L2F23      $2F23
 L2F2F      $2F2F
 L2F39      $2F39
 L2F75      $2F75
 L2F92      $2F92
 L2F7F      $2F7F
 L2FB7      $2FB7
 L307C      $307C
 L2FAC      $2FAC
 L308C      $308C
 L2FE1      $2FE1
 L309F      $309F
 L2FCE      $2FCE
 L30AA      $30AA
 L30B6      $30B6
 L2FE8      $2FE8
 L300C      $300C
 L326A      $326A
 L2FEF      $2FEF
 L243F      $243F
 L305C      $305C
 L30BE      $30BE
 L243D      $243D
 L308B      $308B
 L30CA      $30CA
 L30D3      $30D3
 L30E2      $30E2
 L30FB      $30FB
 L30FA      $30FA
 L30EC      $30EC
 L311E      $311E
 L24C5      $24C5
 L315F      $315F
 L31B0      $31B0
 L316A      $316A
 L31BE      $31BE
 L31A0      $31A0
 L31AC      $31AC
 L31B8      $31B8
 L31BA      $31BA
 L320C      $320C
 L31FF      $31FF
 L31D1      $31D1
 L31D8      $31D8
 L32D3      $32D3
 L31DC      $31DC
 L31ED      $31ED
 L31F5      $31F5
 L31FD      $31FD
 L325E      $325E
 L243E      $243E
 L321B      $321B
 L323F      $323F
 L31C6      $31C6
 L328F      $328F
 L329D      $329D
 L32A3      $32A3
 L32B9      $32B9
 L225C      $225C
 L32F4      $32F4
 L332B      $332B
 L332C      $332C
 L336A      $336A
 L334A      $334A
 L338D      $338D
 L339B      $339B
 L338A      $338A
 L33D3      $33D3
 L38D4      $38D4
 L3BC9      $3BC9
 L3C2A      $3C2A
 L33F3      $33F3
 L340F      $340F
 L243A      $243A
 L243B      $243B
 L347B      $347B
 L34A9      $34A9
 L346C      $346C
 L34A6      $34A6
 L345C      $345C
 L33A8      $33A8
 L3F98      $3F98
 L34F0      $34F0
 L350F      $350F
 L35B7      $35B7
 L33B6      $33B6
 L35CA      $35CA
 L352A      $352A
 L3B8C      $3B8C
 L356A      $356A
 L358C      $358C
 L218B      $218B
 L35B3      $35B3
 L35AA      $35AA
 L3FC8      $3FC8
 L35C9      $35C9
 L37E7      $37E7
 L364D      $364D
 L36AD      $36AD
 L36B6      $36B6
 L36BD      $36BD
 L36C0      $36C0
 L36CC      $36CC
 L37C5      $37C5
 L36DE      $36DE
 L36FE      $36FE
 L36FA      $36FA
 L36F0      $36F0
 L36D2      $36D2
 L36D8      $36D8
 L36C3      $36C3
 L377C      $377C
 L384B      $384B
 L36F5      $36F5
 L375D      $375D
 L37FD      $37FD
 L389B      $389B
 L378D      $378D
 L37A4      $37A4
 L38B5      $38B5
 L37AF      $37AF
 L37BC      $37BC
 L37FA      $37FA
 L382C      $382C
 L37FF      $37FF
 L381D      $381D
 L383F      $383F
 L385A      $385A
 L386B      $386B
 L38B7      $38B7
 L389A      $389A
 L389F      $389F
 L38A1      $38A1
 L38B2      $38B2
 L38BE      $38BE
 L38D3      $38D3
 L392E      $392E
 L38F9      $38F9
 L38E9      $38E9
 L394F      $394F
 L399C      $399C
 L39A5      $39A5
 L3A97      $3A97
 L39B0      $39B0
 L39DE      $39DE
 L39E5      $39E5
 L39DB      $39DB
 L39EF      $39EF
 L39F5      $39F5
 L3A27      $3A27
 L39FF      $39FF
 L3A05      $3A05
 L3A08      $3A08
 L3A0A      $3A0A
 L24ED      $24ED
 L24E7      $24E7
 L3A1D      $3A1D
 L3A4D      $3A4D
 L3A5A      $3A5A
 L24D0      $24D0
 L3A41      $3A41
 L3A8D      $3A8D
 L3AB7      $3AB7
 L3AD7      $3AD7
 L3AC9      $3AC9
 L3AD1      $3AD1
 L3AE0      $3AE0
 L3B31      $3B31
 L3B38      $3B38
 L3B29      $3B29
 L3B19      $3B19
 L3B89      $3B89
 L3B6B      $3B6B
 L3B8E      $3B8E
 L3BA6      $3BA6
 L3BAC      $3BAC
 L3BB7      $3BB7
 L3BBD      $3BBD
 L3BC6      $3BC6
 L3BF1      $3BF1
 L3BF0      $3BF0
 L3F77      $3F77
 L3BEB      $3BEB
 L3C27      $3C27
 L3BDA      $3BDA
 L3BFA      $3BFA
 L3C22      $3C22
 L3FE8      $3FE8
 L3C89      $3C89
 L3C2E      $3C2E
 L3C3C      $3C3C
 L3C43      $3C43
 L20A4      $20A4
 L3C4A      $3C4A
 L3C56      $3C56
 L3C5D      $3C5D
 L3C64      $3C64
 L3C88      $3C88
 L3C7E      $3C7E
 L3C86      $3C86
 L3C9E      $3C9E
 L3CA3      $3CA3
 L3CB1      $3CB1
 L3CC0      $3CC0
 L3CBA      $3CBA
 L3CD1      $3CD1
 L3CE3      $3CE3
 L3CEB      $3CEB
 L3CDB      $3CDB
 L3D38      $3D38
 L3D0F      $3D0F
 L3D10      $3D10
 L3D5B      $3D5B
 L3D93      $3D93
 L3DDD      $3DDD
 L2E2C      $2E2C
 L3E47      $3E47
 L3E1F      $3E1F
 L3E1D      $3E1D
 L3E38      $3E38
 L3E44      $3E44
 L3E5A      $3E5A
 L3E6D      $3E6D
 L3E54      $3E54
 L3E79      $3E79
 L3E89      $3E89
 L3E49      $3E49
 L3EB7      $3EB7
 L3ECF      $3ECF
 L3ECC      $3ECC
 L3EDC      $3EDC
 L3F40      $3F40
 L3EF4      $3EF4
 L3F56      $3F56
 L3F38      $3F38
 L3F14      $3F14
 L3EF1      $3EF1
 L3EEC      $3EEC
 L3EF7      $3EF7
 L3F3D      $3F3D
 L3F6D      $3F6D
 L3F68      $3F68
 L3F86      $3F86
 L3F7D      $3F7D
 L3F89      $3F89
 L3F88      $3F88
 L3F87      $3F87
 L3FA3      $3FA3
 L3FA0      $3FA0
 L40A5      $40A5
 L3FD3      $3FD3
 L3FD0      $3FD0
 L3FD6      $3FD6
 L405D      $405D
 L400C      $400C
 L408F      $408F
 L402E      $402E
 L407C      $407C
 L404D      $404D
 L405F      $405F
 L40A4      $40A4
 L40EF      $40EF
 L40B4      $40B4
 L40A9      $40A9
 L40D1      $40D1
 L40C7      $40C7
 L40EB      $40EB
 L415B      $415B
 L40F4      $40F4
 L410A      $410A
 L411F      $411F
 L414E      $414E
