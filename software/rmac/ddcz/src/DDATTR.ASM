; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
; DDATTR.ASM -- CADzilla GSX driver: the attribute functions and the
; pattern RAM.
;
; Every setter returns the value it selected (intout(1), or ptsout for the
; sizes); out-of-range requests get the GSX spec's fallback. ATRINI sets
; them all from Open Workstation's intin(2)-(10).
;
; The ACRTC draws every pixel through its pattern RAM -- lines, fills and
; (czgfx resets it after) text alike -- so each primitive asks USEPAT for
; the pattern it needs; USEPAT reloads the RAM only when that changes.
; PSTATE (DDCZ) says what it holds:
;   1        all ones, 16x16 (CZPDEF): solid lines and fills, markers
;   2-5      a linetype's mask in row 0 (CZLSTY)
;   11H-16H  halftone pattern 1-6, 16x16
;   21H-26H  hatch style 1-6, 16x16
;   0        unknown
;
        PUBLIC  SCHH,SCUP,SLTYP,SLWID,SLCOL,SMTYP,SMHGT,SMCOL
        PUBLIC  STFNT,STCOL,SFINT,SFSTY,SFCOL,ATRINI
        PUBLIC  USEPAT,FPAT,FMET
;
        EXTRN   INTIN,LCOL,LTYPE,MCOL,MTYPE,MHGT
        EXTRN   TCOL,TFONT,TSCAL,TDIR,TREQH,FCOL,FSTYL,FINDX,PSTATE
        EXTRN   SETC3,RET1A,RETHL,LDCOL,INW,PTW,PTOUT
        EXTRN   CZPDEF,CZLSTY,CZLPAT
;
PSSOL   EQU     1               ;PSTATE: solid
;
        CSEG
;
; ==== The pattern RAM ========================================================
;
; USEPAT -- make the pattern RAM hold pattern A (a PSTATE value)
;
USEPAT: LXI     H,PSTATE
        CMP     M
        RZ                      ;it does already
        MOV     M,A
        CPI     2
        JC      UPSOL
        CPI     10H
        JC      UPLIN
        PUSH    PSW             ;a fill pattern: the window 16x16 at 0,0
        CALL    CZPDEF
        POP     PSW
        MOV     B,A             ;HL = its table
        ANI     0FH
        DCR     A
        ADD     A
        MOV     E,A
        MVI     D,0
        LXI     H,HTPTR
        MOV     A,B
        CPI     20H
        JC      UPF1
        LXI     H,HAPTR
UPF1:   DAD     D
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        PUSH    H               ;8 rows, twice: rows 0-7, then 8-15
        XRA     A
        CALL    CZLPAT
        POP     H
        MVI     A,8
        JMP     CZLPAT
UPSOL:  MVI     M,PSSOL
        JMP     CZPDEF
UPLIN:  DCR     A               ;HL = linetype A's mask
        ADD     A
        MOV     E,A
        MVI     D,0
        LXI     H,LTMASK
        DAD     D
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        XRA     A               ;no zoom
        JMP     CZLSTY
;
; FPAT -- A = the pattern the fill attributes call for: hollow and solid
; are solid (hollow draws an outline), halftone 11H+, hatch 21H+
;
FPAT:   LDA     FSTYL
        CPI     2
        MVI     B,10H
        JZ      FP1
        CPI     3
        MVI     B,20H
        JZ      FP1
        MVI     A,PSSOL
        RET
FP1:    LDA     FINDX
        ADD     B
        RET
;
; ==== The setters ============================================================
;
; SELA -- A = intin(1) if it is B..C, else E
SELA:   MVI     A,1
        CALL    INW
        MOV     A,H
        ORA     A
        JNZ     SELDF
        MOV     A,L
        CMP     B
        JC      SELDF           ;under B
        MOV     D,A
        MOV     A,C
        CMP     D
        MOV     A,D
        RNC                     ;not over C
SELDF:  MOV     A,E
        RET
;
; 15: polyline linetype, 1-5 (else 1)
SLTYP:  LXI     B,0105H
        MVI     E,1
        CALL    SELA
        STA     LTYPE
        JMP     RET1A
;
; 16: polyline width: always 1
SLWID:  LXI     H,1
        MVI     A,1
        CALL    PTOUT
        LXI     H,0
        MVI     A,2
        CALL    PTOUT
        LXI     H,1
        JMP     SETC3
;
; 17, 20, 22, 25: the color indexes
SLCOL:  CALL    INCOL
        STA     LCOL
        JMP     RET1A
SMCOL:  CALL    INCOL
        STA     MCOL
        JMP     RET1A
STCOL:  CALL    INCOL
        STA     TCOL
        JMP     RET1A
SFCOL:  CALL    INCOL
        STA     FCOL
        JMP     RET1A
INCOL:  LHLD    INTIN
        JMP     LDCOL
;
; 18: polymarker type, 1-5 (else 3)
SMTYP:  LXI     B,0105H
        MVI     E,3
        CALL    SELA
        STA     MTYPE
        JMP     RET1A
;
; 19: polymarker height, ptsin(2): the largest of MHTAB not over it (or
; the smallest)
SMHGT:  MVI     A,2
        CALL    PTW
        XCHG                    ;DE = the height asked for
        LXI     H,MHTAB
        MVI     B,MHN
        MOV     A,M             ;the smallest, to start with
        STA     MHGT
        INX     H
        MOV     A,M
        STA     MHGT+1
        INX     H
SMH1:   DCR     B
        JZ      SMH2
        MOV     C,M             ;A:C = the next height
        INX     H
        MOV     A,M
        INX     H
        PUSH    H
        MOV     H,A
        MOV     L,C
        MOV     A,E             ;over the request? stop
        SUB     L
        MOV     A,D
        SBB     H
        JC      SMH3
        SHLD    MHGT
        POP     H
        JMP     SMH1
SMH3:   POP     H
SMH2:   LXI     H,0
        MVI     A,1
        CALL    PTOUT
        LHLD    MHGT
        MVI     A,2
        CALL    PTOUT
        LXI     H,1
        JMP     SETC3
;
; 21: text font, 1-2 (else 1): 1 = CZF8, 2 = CZF11. Keeps the height
; asked for, so the scale follows.
STFNT:  LXI     B,0102H
        MVI     E,1
        CALL    SELA
        STA     TFONT
        PUSH    PSW
        CALL    SETSCL
        POP     PSW
        JMP     RET1A
;
; 23: fill interior style, 0-3 (else 0, hollow)
SFINT:  LXI     B,0003H
        MVI     E,0
        CALL    SELA
        STA     FSTYL
        JMP     RET1A
;
; 24: fill style index, 1-6 (else 1)
SFSTY:  LXI     B,0106H
        MVI     E,1
        CALL    SELA
        STA     FINDX
        JMP     RET1A
;
; 12: character height, ptsin(2): the font's 'W' height times a scale
; 1-16, the largest not over the request (or scale 1). Returns ptsout(1)
; = character width, (2) = height, (3) = cell width, (4) = cell height.
SCHH:   MVI     A,2
        CALL    PTW
        SHLD    TREQH
        CALL    SETSCL
        CALL    FMET            ;HL = this font's metrics
        LDA     TSCAL
        MOV     C,A
        INX     H               ;glyph width
        MOV     A,M
        CALL    MULC            ;HL' = A * C
        MVI     A,1
        CALL    PTOUTM
        DCX     H
        MOV     A,M             ;'W' height
        CALL    MULC
        MVI     A,2
        CALL    PTOUTM
        INX     H
        INX     H               ;cell width
        MOV     A,M
        CALL    MULC
        MVI     A,3
        CALL    PTOUTM
        INX     H               ;cell height
        MOV     A,M
        CALL    MULC
        MVI     A,4
        CALL    PTOUTM
        LXI     H,2
        JMP     SETC3
;
; PTOUTM -- ptsout(A) = DE, keeping HL
PTOUTM: PUSH    H
        XCHG
        CALL    PTOUT
        POP     H
        RET
;
; MULC -- DE = A * C (small numbers). Keeps HL, BC.
MULC:   LXI     D,0
        ORA     A
        RZ
        PUSH    B
        PUSH    H
        MOV     L,A
        MVI     H,0
        MOV     B,C
        INR     B
        DCR     B
        JZ      MC2
MC1:    XCHG
        DAD     D
        XCHG
        DCR     B
        JNZ     MC1
MC2:    POP     H
        POP     B
        RET
;
; SETSCL -- TSCAL = TREQH / this font's 'W' height, 1-16
SETSCL: CALL    FMET
        MOV     C,M             ;C = the 'W' height
        MVI     B,0             ;B = the scale
        LHLD    TREQH
        MOV     A,H
        ORA     A
        JM      SS2             ;(negative: scale 1)
SS1:    MOV     A,L             ;HL -= height; another step while >= 0
        SUB     C
        MOV     L,A
        MOV     A,H
        SBI     0
        MOV     H,A
        JC      SS2
        INR     B
        MOV     A,B
        CPI     16
        JC      SS1
SS2:    MOV     A,B
        ORA     A
        JNZ     SS3
        INR     A
SS3:    STA     TSCAL
        RET
;
; FMET -- HL = the current font's metrics: DB 'W' height, glyph width,
; cell width, cell height, baseline (rows below it in the cell)
FMET:   LDA     TFONT
        LXI     H,FMET1
        DCR     A
        RZ
        LXI     H,FMET2
        RET
FMET1:  DB      7,5,8,8,0       ;CZF8: 5x7 in an 8x8 cell, no descenders
FMET2:  DB      8,7,9,11,2      ;CZF11: 'W' 8 high in 9x11, 2 rows below
;
; 13: character up vector, intin(1) in tenths of a degree: to the nearest
; 45 degrees (the ACRTC's eight PTN directions); returns the angle used
SCUP:   MVI     A,1
        CALL    INW
SCU0:   MOV     A,H             ;negative: + 3600 until it isn't
        ORA     A
        JP      SCU1
        LXI     D,3600
        DAD     D
        JMP     SCU0
SCU1:   LXI     D,3600          ;then - 3600 while it is 3600 or more
        CALL    SUBGE
        JNC     SCU1
        LXI     D,225           ;+ half a step, and count the 450s
        DAD     D
        MVI     B,0
SCU2:   LXI     D,450
        CALL    SUBGE
        JC      SCU3
        INR     B
        JMP     SCU2
SCU3:   MOV     A,B
        ANI     7
        STA     TDIR
        ADD     A               ;intout(1) = the angle used
        MOV     E,A
        MVI     D,0
        LXI     H,DIRANG
        DAD     D
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        JMP     RETHL
;
; SUBGE -- if HL >= DE (unsigned): HL -= DE, NC; else C, HL kept
SUBGE:  MOV     A,L
        SUB     E
        MOV     C,A
        MOV     A,H
        SBB     D
        RC
        MOV     H,A
        MOV     L,C
        RET
;
DIRANG: DW      0,450,900,1350,1800,2250,2700,3150
;
; Open workstation: the attributes from intin(2)-(10)
;
ATRINI: LXI     H,0             ;character height: the smallest
        SHLD    TREQH
        MVI     A,1
        STA     TSCAL
        XRA     A
        STA     TDIR
        LXI     H,5             ;marker height: the smallest
        SHLD    MHGT
        LHLD    INTIN
        SHLD    AIBASE
        LXI     H,AITAB
AILP:   MOV     E,M             ;DE = the next setter
        INX     H
        MOV     D,M
        INX     H
        MOV     A,D
        ORA     E
        JZ      AIX
        PUSH    H
        LHLD    AIBASE          ;intin -> the next word
        INX     H
        INX     H
        SHLD    AIBASE
        SHLD    INTIN
        LXI     H,AIRET
        PUSH    H
        XCHG
        PCHL
AIRET:  POP     H
        JMP     AILP
AIX:    LHLD    INTIN           ;put intin back (intin(1) + 9 words)
        LXI     D,0-18
        DAD     D
        SHLD    INTIN
        RET
;
AITAB:  DW      SLTYP,SLCOL,SMTYP,SMCOL,STFNT   ;intin(2)-(6)
        DW      STCOL,SFINT,SFSTY,SFCOL,0       ;intin(7)-(10)
;
; ==== Tables =================================================================
;
MHTAB:  DW      5,7,9,13,17,25,33,49
MHN     EQU     8
;
; linetypes 1-5: GSX's masks, the first-drawn bit as bit 0
LTMASK: DW      0FFFFH,0007FH,00707H,01C7FH,00FFFH
;
HTPTR:  DW      HT1,HT2,HT3,HT4,HT5,HT6
HAPTR:  DW      HA1,HA2,HA3,HA4,HA5,HA6
;
; halftone 1-6, lightest to darkest: a 4x4 ordered dither, repeated. Each
; pattern repeats every 8 rows, so 8 are stored and loaded twice.
; Pattern row 0 is the bottom (the driver aligns it to Y AND 15), bit 0
; the left.
HT1:    DW      8
        DW      01111H,00000H,04444H,00000H,01111H,00000H,04444H,00000H
HT2:    DW      8
        DW      05555H,00000H,05555H,00000H,05555H,00000H,05555H,00000H
HT3:    DW      8
        DW      05555H,02222H,05555H,08888H,05555H,02222H,05555H,08888H
HT4:    DW      8
        DW      05555H,0AAAAH,05555H,0AAAAH,05555H,0AAAAH,05555H,0AAAAH
HT5:    DW      8
        DW      0FFFFH,0AAAAH,0DDDDH,0AAAAH,0FFFFH,0AAAAH,0DDDDH,0AAAAH
HT6:    DW      8
        DW      0FFFFH,0BBBBH,0FFFFH,0EEEEH,0FFFFH,0BBBBH,0FFFFH,0EEEEH
;
; hatch 1-6: vertical, horizontal, +45, -45, cross, X; 8 pixels apart
HA1:    DW      8
        DW      00101H,00101H,00101H,00101H,00101H,00101H,00101H,00101H
HA2:    DW      8
        DW      0FFFFH,00000H,00000H,00000H,00000H,00000H,00000H,00000H
HA3:    DW      8
        DW      00101H,00202H,00404H,00808H,01010H,02020H,04040H,08080H
HA4:    DW      8
        DW      08080H,04040H,02020H,01010H,00808H,00404H,00202H,00101H
HA5:    DW      8
        DW      0FFFFH,00101H,00101H,00101H,00101H,00101H,00101H,00101H
HA6:    DW      8
        DW      08181H,04242H,02424H,01818H,01818H,02424H,04242H,08181H
;
        DSEG
AIBASE: DS      2
;
        END
