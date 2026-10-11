;
; DDCOL.ASM -- CADzilla GSX driver: the color table (opcodes 14, 26).
;
; GSX colors are RGB in tenths of a percent, 0-1000; the Bt453 takes 0-255
; a channel. Every one of the 256 indexes is a palette entry: setting one
; recolors what is already drawn in it.
;
; To keep the driver small (GDOS loads it below itself, out of the
; application's memory), the table holds one byte a channel: what was
; asked for, in quarters of a tenth of a percent (0-250). Inquire color
; representation gives that back "as set" (to within 2 tenths of a
; percent), and works out "as realized" from it the way the DAC was set.
;
        PUBLIC  SCOLR,QCOLR,PALINI
;
        EXTRN   INTIN,INW,OUTW,SETC5,LDCOL
        EXTRN   MULDIV
        EXTRN   CZPALS
;
        CSEG
;
; ==== Open workstation: GSX's default colors ================================
;
; 0 black, 1 red, 2 green, 3 blue, 4 cyan, 5 yellow, 6 magenta, 7-255 white
;
PALINI: XRA     A
PI1:    STA     PIX
        CPI     8
        LXI     H,DEFW          ;7 up: white
        JNC     PI2
        MOV     L,A             ;HL = DEFTAB + 3 * index
        MVI     H,0
        MOV     D,H
        MOV     E,L
        DAD     H
        DAD     D
        LXI     D,DEFTAB
        DAD     D
PI2:    LXI     D,RGBQ          ;the three channels to set
        MVI     B,3
PI3:    MOV     A,M
        STAX    D
        INX     H
        INX     D
        DCR     B
        JNZ     PI3
        LDA     PIX
        CALL    SETIDX
        LDA     PIX
        INR     A
        JNZ     PI1
        RET
;
; (quarters of a tenth of a percent: 250 = 100%)
DEFTAB: DB      0,0,0, 250,0,0, 0,250,0, 0,0,250
        DB      0,250,250, 250,250,0, 250,0,250
DEFW:   DB      250,250,250
;
; ==== 14: Set color representation ==========================================
;
; intin(1) = the index (out of range: nothing done), intin(2)-(4) = R, G,
; B, each 0-1000.
;
SCOLR:  MVI     A,1
        CALL    INW
        MOV     A,H
        ORA     A
        RNZ                     ;not 0-255: no operation
        MOV     A,L
        STA     PIX
        LXI     D,RGBQ
        MVI     B,2             ;intin(2..4)
SC1:    MOV     A,B
        CALL    INW
        MOV     A,H
        ORA     A
        JP      SC2
        LXI     H,0             ;negative: 0
SC2:    PUSH    D
        LXI     D,1001
        MOV     A,L
        SUB     E
        MOV     A,H
        SBB     D
        POP     D
        JC      SC3
        LXI     H,1000          ;over: 1000
SC3:    INX     H               ;q = (t + 2) / 4
        INX     H
        MVI     C,2
SC4:    ORA     A
        MOV     A,H
        RAR
        MOV     H,A
        MOV     A,L
        RAR
        MOV     L,A
        DCR     C
        JNZ     SC4
        MOV     A,L
        STAX    D
        INX     D
        INR     B
        MOV     A,B
        CPI     5
        JC      SC1
        LDA     PIX
;
; SETIDX -- give index A the color RGBQ: into the table and the DAC
SETIDX: STA     PIX
        CALL    QADDR           ;HL = the table's entry
        XCHG
        LXI     H,RGBQ
        MVI     B,3
SI1:    MOV     A,M             ;the table: q
        STAX    D
        INX     D
        PUSH    H               ;the DAC: q * 255 / 250
        PUSH    D
        PUSH    B
        CALL    Q2V
        POP     B
        POP     D
        POP     H
        MOV     M,A             ;(RGBQ now holds the DAC's value)
        INX     H
        DCR     B
        JNZ     SI1
        LXI     H,RGBQ          ;B/C/E = R/G/B
        MOV     B,M
        INX     H
        MOV     C,M
        INX     H
        MOV     E,M
        LDA     PIX
        JMP     CZPALS
;
; Q2V -- A = q (0-250) * 255 / 250, the DAC's 0-255
Q2V:    MOV     C,A
        MVI     B,0
        LXI     D,255
        LXI     H,250
        CALL    MULDIV
        MOV     A,L
        RET
;
; QADDR -- HL = the table entry for index PIX
QADDR:  LDA     PIX
        MOV     L,A
        MVI     H,0
        MOV     D,H
        MOV     E,L
        DAD     H
        DAD     D
        LXI     D,COLQ
        DAD     D
        RET
;
; ==== 26: Inquire color representation =======================================
;
; intin(1) = the index (out of range: 255), intin(2) = 0 for the values
; set, 1 for those realized. intout(1) = the index, (2)-(4) = R, G, B.
;
QCOLR:  LHLD    INTIN
        CALL    LDCOL
        STA     PIX
        MOV     L,A
        MVI     H,0
        MVI     A,1
        CALL    OUTW
        MVI     A,2
        CALL    INW
        MOV     A,H
        ORA     L
        STA     QFLG
        CALL    QADDR
        SHLD    QPTR
        MVI     A,2
QC1:    STA     SCNT
        LHLD    QPTR
        MOV     A,M
        INX     H
        SHLD    QPTR
        MOV     L,A
        MVI     H,0
        LDA     QFLG
        ORA     A
        JNZ     QC3
        DAD     H               ;as set: q * 4
        DAD     H
        JMP     QC2
QC3:    MOV     A,L             ;as realized: the DAC's v * 1000 / 255
        CALL    Q2V
        MOV     C,A
        MVI     B,0
        LXI     D,1000
        LXI     H,255
        CALL    MULDIV
QC2:    LDA     SCNT
        CALL    OUTW
        LDA     SCNT
        INR     A
        CPI     5
        JC      QC1
        LXI     H,4
        JMP     SETC5
;
        DSEG
PIX:    DS      1
SCNT:   DS      1
QFLG:   DS      1
QPTR:   DS      2
RGBQ:   DS      3               ;R, G, B being set (q, then the DAC's v)
COLQ:   DS      3*256           ;as set, 0-250 (quarters of a tenth of a %)
;
        END
