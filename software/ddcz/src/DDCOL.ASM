;
; DDCOL.ASM -- CADzilla GSX driver: the color table (opcodes 14, 26).
;
; GSX colors are RGB in tenths of a percent, 0-1000; the Bt453 takes 0-255
; a channel. The driver keeps both what was asked for (REQ, words) and
; what the DAC got (REAL, bytes), since inquire color representation can
; ask for either. Every one of the 256 indexes is a palette entry: setting
; one recolors what is already drawn in it.
;
        PUBLIC  SCOLR,QCOLR,PALINI
;
        EXTRN   INTIN,INTOUT,INW,OUTW,SETC5,LDCOL
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
        MOV     L,A             ;HL = DEFTAB + 6 * index
        MVI     H,0
        DAD     H
        MOV     D,H
        MOV     E,L
        DAD     H
        DAD     D
        LXI     D,DEFTAB
        DAD     D
PI2:    LXI     D,RGBW          ;the three words to set
        LXI     B,6
        CALL    COPYB
        LDA     PIX
        CALL    SETIDX
        LDA     PIX
        INR     A
        JNZ     PI1
        RET
;
DEFTAB: DW      0,0,0, 1000,0,0, 0,1000,0, 0,0,1000
        DW      0,1000,1000, 1000,1000,0, 1000,0,1000
DEFW:   DW      1000,1000,1000
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
        LXI     D,RGBW
        MVI     B,3
SC1:    MOV     A,B             ;intin(2..4), each into 0-1000
        CMA
        ADI     6               ;A = 5 - B: 2, 3, 4
        PUSH    B
        PUSH    D
        CALL    INW
        MOV     A,H
        ORA     A
        JP      SC2
        LXI     H,0             ;negative: 0
SC2:    LXI     D,1001
        MOV     A,L
        SUB     E
        MOV     A,H
        SBB     D
        JC      SC3
        LXI     H,1000          ;over: 1000
SC3:    POP     D
        XCHG
        MOV     M,E
        INX     H
        MOV     M,D
        INX     H
        XCHG
        POP     B
        DCR     B
        JNZ     SC1
        LDA     PIX
;
; SETIDX -- give index A the color RGBW: into REQ, REAL and the DAC
SETIDX: STA     PIX
        MOV     L,A             ;HL = REQ + 6 * index
        MVI     H,0
        DAD     H
        MOV     D,H
        MOV     E,L
        DAD     H
        DAD     D
        LXI     D,REQ
        DAD     D
        XCHG
        LXI     H,RGBW
        LXI     B,6
        CALL    COPYB
        LDA     PIX             ;HL = REAL + 3 * index
        MOV     L,A
        MVI     H,0
        MOV     D,H
        MOV     E,L
        DAD     H
        DAD     D
        LXI     D,REAL
        DAD     D
        SHLD    RPTR
        LXI     H,RGBW
        SHLD    WPTR
        MVI     A,3
SI1:    STA     SCNT
        LHLD    WPTR            ;v = t * 255 / 1000
        MOV     C,M
        INX     H
        MOV     B,M
        INX     H
        SHLD    WPTR
        LXI     D,255
        LXI     H,1000
        CALL    MULDIV
        XCHG
        LHLD    RPTR
        MOV     M,E
        INX     H
        SHLD    RPTR
        LDA     SCNT
        DCR     A
        JNZ     SI1
        LHLD    RPTR            ;the DAC: B/C/E = R/G/B
        DCX     H
        MOV     E,M
        DCX     H
        MOV     C,M
        DCX     H
        MOV     B,M
        LDA     PIX
        JMP     CZPALS
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
        JNZ     QREAL
        LDA     PIX             ;as set: REQ's three words
        MOV     L,A
        MVI     H,0
        DAD     H
        MOV     D,H
        MOV     E,L
        DAD     H
        DAD     D
        LXI     D,REQ
        DAD     D
        XCHG
        LHLD    INTOUT
        INX     H
        INX     H
        XCHG
        LXI     B,6
        CALL    COPYB
        JMP     QRET
QREAL:  LDA     PIX             ;as realized: v * 1000 / 255
        MOV     L,A
        MVI     H,0
        MOV     D,H
        MOV     E,L
        DAD     H
        DAD     D
        LXI     D,REAL
        DAD     D
        SHLD    RPTR
        MVI     A,2
QR1:    STA     SCNT
        LHLD    RPTR
        MOV     C,M
        INX     H
        SHLD    RPTR
        MVI     B,0
        LXI     D,1000
        LXI     H,255
        CALL    MULDIV
        LDA     SCNT
        CALL    OUTW
        LDA     SCNT
        INR     A
        CPI     5
        JC      QR1
QRET:   LXI     H,4
        JMP     SETC5
;
; COPYB -- copy BC bytes from HL to DE
COPYB:  MOV     A,M
        STAX    D
        INX     H
        INX     D
        DCX     B
        MOV     A,B
        ORA     C
        JNZ     COPYB
        RET
;
        DSEG
PIX:    DS      1
SCNT:   DS      1
RPTR:   DS      2
WPTR:   DS      2
RGBW:   DS      6               ;R, G, B being set (0-1000)
REQ:    DS      6*256           ;as set, 0-1000
REAL:   DS      3*256           ;as realized, 0-255
;
        END
