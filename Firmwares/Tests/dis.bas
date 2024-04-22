   10 S%=1
   20 :
   30 CLEAR
   40 :
   50 zpbase=&A8
   60 ptr=zpbase
   70 max=zpbase+2
   80 pflags=zpbase+4
   90 temp=zpbase+5
  100 oldptr=zpbase+6
  110 arg=zpbase+4
  120 :
  130 PRINT "Stage ";S%
  140 FOR pass%=0 TO 2 STEP 2
  150 P%=&900
  160 IF S%=1 PROCasm ELSE PROCasm2
  170 NEXT
  180 :
  190 PRINT "  ";P%-&900;" bytes"
  200 F$="DIS":IF S%=2 F$=F$+"2"
  210 C$="SAVE "+F$+" 900 "+STR$~P%
  220 PRINT "  ";C$
  230 OSCLI(C$)
  240 :
  250 IF S%=1 THEN S%=2:GOTO 30
  260 :
  270 END
  280 :
  290 DEFPROCasm
  300 [OPT pass%
  310 .entry
  320 LDA #1
  330 LDX #oldptr
  340 LDY #0
  350 JSR &FFDA
  360 JSR parsehexarg : BCS noaddress
  370 STX ptr : STY ptr+1
  380 JSR parsehexarg : BCC gotmax
  390 LDX #&FF : LDY #&FF
  400 .gotmax STX max : STY max+1
  410 LDX #cmd AND &FF
  420 LDY #cmd DIV &FF
  430 JMP &FFF7
  440 :
  450 .cmd EQUS "DIS2" : EQUB 13
  460 :
  470 .noaddress BRK : EQUB 252
  480 EQUS "No address"
  490 .badhex BRK : EQUB 252
  500 EQUS "Bad hex"
  510 BRK
  520 :
  530 .parsehexarg
  540 LDA #0 : STA arg : STA arg+1
  550 JSR gethex : BCS parsehexreturn
  560 .parsehexloop
  570 LDX #4
  580 .shiftloop ASL arg : ROL arg+1
  590 DEX : BNE shiftloop
  600 ORA arg : STA arg
  610 JSR gethex : BCC parsehexloop
  620 LDX arg : LDY arg+1 : CLC
  630 .parsehexreturn RTS
  640 :
  650 .getchar
  660 LDX #0 : LDA (oldptr,X)
  670 CMP #13 : BEQ rts2
  680 INC oldptr : BNE rts2
  690 INC oldptr+1
  700 .rts2 RTS
  710 :
  720 .gethex
  730 JSR getchar
  740 CMP #13 : BEQ gethexnotdigit
  750 CMP #32 : BEQ gethexskipspaces
  760 SBC #48 : BCC badhex
  770 CMP #10 : BCC gethexreturn
  780 SBC #7 : CMP #16 : BCS badhex
  790 .gethexreturn RTS
  800 .gethexskipspaces
  810 CMP (oldptr,X) : BEQ gethex
  820 .gethexnotdigit
  830 SEC : RTS
  840 ]
  850 ENDPROC
  860 :
  870 DEFPROCasm2
  880 [OPT pass%
  890 .loop
  900 :
  910 BIT &FF : BMI rts3
  920 :
  930 LDA ptr+1 : STA oldptr+1
  940 JSR printbyte
  950 LDA ptr : STA oldptr
  960 JSR printbytespace
  970 JSR space
  980 :
  990 JSR dis1
 1000 :
 1010 .spcloop
 1020 JSR space
 1030 LDX &318
 1040 CPX #19
 1050 BCC spcloop
 1060 :
 1070 LDA #ASC"\" : JSR &FFEE
 1080 JSR space
 1090 :
 1100 LDX ptr
 1110 .bytesloop
 1120 LDY #0
 1130 LDA (oldptr),Y
 1140 JSR printbytespace
 1150 INC oldptr
 1160 BNE bytesloopcheckend
 1170 INC oldptr+1
 1180 .bytesloopcheckend
 1190 CPX oldptr
 1200 BNE bytesloop
 1210 :
 1220 JSR &FFE7
 1230 :
 1240 SEC : LDA ptr : SBC max
 1250 LDA ptr+1 : SBC max+1
 1260 BCC loop
 1270 :
 1280 .rts3 RTS
 1290 :
 1300 .printstandardmnemonic
 1310 PHA : AND #3 : ASL A : STA temp
 1320 PLA : AND #&E0 : SEC : ROR A
 1330 LSR A : ORA temp
 1340 BNE printmnemonic
 1350 :
 1360 .printimpliedmnemonic
 1370 AND #&F2 : LSR A : LSR A
 1380 BCC printmnemonic : ADC #1
 1390 :
 1400 .printmnemonic
 1410 TAY
 1420 LDA mnem+1,Y : STA temp
 1430 LDA mnem,Y
 1440 LDX #3
 1450 .printmnemonicloop
 1460 PHA
 1470 AND #31 : ORA #&40 : JSR &FFEE
 1480 PLA
 1490 LDY #5
 1500 .getbitsloop
 1510 LSR temp : ROR A
 1520 DEY : BNE getbitsloop
 1530 DEX : BNE printmnemonicloop
 1540 STA temp : JSR space
 1550 LDA temp : RTS
 1560 :
 1570 .printbytespace JSR printbyte
 1580 .space LDA #ASC" " : BNE pchar
 1590 :
 1600 .printbyte
 1610 PHA
 1620 LSR A : LSR A : LSR A : LSR A
 1630 JSR printhexdigit
 1640 PLA : AND #&0F
 1650 .printhexdigit
 1660 CMP #10 : BCC pdigit : ADC #6
 1670 .pdigit ADC #ASC"0" : BNE pchar
 1680 :
 1690 .read
 1700 LDX #0 : LDA (ptr,X)
 1710 INC ptr : BNE rts : INC ptr+1
 1720 .rts RTS
 1730 :
 1740 .branch
 1750 PLA : ORA #3
 1760 JSR printstandardmnemonic
 1770 JSR read
 1780 TAY : BPL branchadd : DEX
 1790 .branchadd CLC : ADC ptr : TAY
 1800 TXA : ADC ptr+1 : PHA
 1810 LDA #&20 : STA pflags : BNE printarg2
 1820 :
 1830 .dis1
 1840 JSR read : PHA
 1850 AND #&9F : BEQ brkjsrrtirts
 1860 AND #&1F : CMP #&10 : BEQ branch
 1870 AND #&0D : CMP #&08 : BNE standard
 1880 :
 1890 \ Implied operations
 1900 PLA
 1910 JSR printimpliedmnemonic
 1920 BEQ rts
 1930 LDA #65
 1940 .pchar JMP &FFEE
 1950 :
 1960 .brkjsrrtirts
 1970 PLA : ORA #&1A
 1980 JSR printimpliedmnemonic
 1990 BEQ rts
 2000 JSR read : TAY : LDA #&20 : BNE printarg
 2010 :
 2020 .standard
 2030 PLA : PHA
 2040 JSR printstandardmnemonic
 2050 JSR read : TAY
 2060 PLA
 2070 CMP #&6C : BEQ jmpindirect
 2080 AND #&1D
 2090 BNE bnotzero : LDA #&09
 2100 .bnotzero
 2110 LSR A : LSR A
 2120 TAX : LDA lut,X
 2130 :
 2140 .printarg
 2150 STA pflags
 2160 AND #&20 : BEQ notabs
 2170 JSR read : PHA
 2180 .notabs
 2190 :
 2200 .printarg2
 2210 LDA #ASC"#" : JSR maybepchar
 2220 LDA #ASC"(" : JSR maybepchar
 2230 LDA #ASC"&" : JSR &FFEE
 2240 ROL pflags : BCC nohighbyte
 2250 PLA : JSR printbyte
 2260 .nohighbyte
 2270 TYA : JSR printbyte
 2280 LDA #ASC"X" : ORA temp : TAX
 2290 JSR maybeprintindex
 2300 LDA #ASC")" : JSR maybepchar
 2310 LDX #ASC"Y"
 2320 :
 2330 .maybeprintindex
 2340 LDA #ASC"," : JSR maybepchar
 2350 TXA
 2360 .maybepchar ROL pflags : BCS pchar
 2370 .rts1 RTS
 2380 :
 2390 .jmpindirect LDA #&64 : BNE printarg
 2400 :
 2410 \  #  ( xx  ,     X  )  ,  Y
 2420 :
 2430 .lut
 2440 EQUB &5C   \ (&nn,x)
 2450 EQUB &00   \ &nn
 2460 EQUB &80   \ #&nn
 2470 EQUB &20   \ &nnnn
 2480 EQUB &47   \ (&nn),y
 2490 EQUB &18   \ &nn,x
 2500 EQUB &23   \ &nnnn,y
 2510 EQUB &38   \ &nnnn,x
 2520 :
 2530 .mnem
 2540 ]
 2550 :
 2560 DATA "PHP ASLACLC BRK "
 2570 DATA "PLP ROLASEC JSR*"
 2580 DATA "PHA LSRACLI RTI "
 2590 DATA "PLA RORASEI RTS "
 2600 DATA "DEY TXA TYA TXS "
 2610 DATA "TAY TAX CLV TSX "
 2620 DATA "INY DEX CLD NOP "
 2630 DATA "INX NOP SED NOP "
 2640 :
 2650 DATA "NOP ORA ASL BPL "
 2660 DATA "BIT AND ROL BMI "
 2670 DATA "JMP EOR LSR BVC "
 2680 DATA "JMP(ADC ROR BVS "
 2690 DATA "STY STA STXYBCC "
 2700 DATA "LDY LDA LDXYBCS "
 2710 DATA "CPY CMP DEC BNE "
 2720 DATA "CPX SBC INC BEQ "
 2730 :
 2740 RESTORE 2560
 2750 FOR I%=0 TO 15
 2760 READ A$
 2770 FOR J%=1 TO 13 STEP 4
 2780 [OPT2:EQUW FNmnem(MID$(A$,J%,4)):]
 2790 NEXT,
 2800 :
 2810 ENDPROC
 2820 :
 2830 DEFFNmnem(A$)
 2840 LOCAL A%,B%,C%,D%
 2850 A%=ASCMID$(A$,1,1) AND &1F
 2860 B%=ASCMID$(A$,2,1) AND &1F
 2870 C%=ASCMID$(A$,3,1) AND &1F
 2880 D%=(MID$(A$,4,1)<>" ")
 2890 =A% OR (B%*32) OR (C%*1024) OR (D% AND 32768)
