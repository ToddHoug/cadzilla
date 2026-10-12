; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
; DDFILL.ASM -- CADzilla GSX driver: filled area
; (opcode 9), the polygon scan fill, spans, filled circles and outlines.
;
; The ACRTC has no polygon fill (PAINT is a seed fill, which a picture
; already on the screen would leak through), so polygons are filled here:
; an edge table, one scan line at a time, the even-odd rule, each span a
; one-raster filled rectangle. A span sets the pattern pointer to the
; pixel's place in a 16x16 grid first, so halftones and hatches line up
; from span to span and shape to shape.
;
; Scan line Y crosses an edge whose ends are at YLO < YHI if YLO <= Y <
; YHI (the top end excluded, so a vertex between two edges counts once).
; That leaves a polygon's top raster unfilled, so a filled area also gets
; its perimeter -- except in XOR mode, where drawing the edge again would
; take it away.
;
        PUBLIC  FAREA,FPOLY,FSPAN,FCIRC,OUTLN
;
        EXTRN   PTSIN,FCOL,FSTYL
        EXTRN   CTLW,DRWCOL,NOXOR,LDXY,LDPTR,COPY
        EXTRN   USEPAT,FPAT
        EXTRN   UDIV,NEG32,CPSGN,NEGHL
        EXTRN   CZMOVE,CZLINE,CZFRCT,CZDOT,CZWPR
;
MAXE    EQU     48              ;the most polygon edges (vertices) filled
;
        CSEG
;
; ==== 9: Filled area =========================================================
;
FAREA:  MVI     A,2             ;n = contrl(2)
        CALL    CTLW
        MOV     A,H
        ORA     A
        JNZ     FA1
        MOV     A,L
        CPI     2
        RC                      ;one point: nothing
FA1:    SHLD    FAN
        LDA     FSTYL
        ORA     A
        JZ      FAOUT           ;hollow: the outline only
        CALL    FPAT
        CALL    USEPAT
        LDA     FCOL
        CALL    DRWCOL
        LHLD    FAN
        MOV     B,H
        MOV     C,L
        LHLD    PTSIN
        CALL    FPOLY
        CALL    NOXOR
        RZ                      ;XOR: no perimeter
FAOUT:  MVI     A,1
        CALL    USEPAT
        LDA     FCOL
        CALL    DRWCOL
        LHLD    FAN
        MOV     B,H
        MOV     C,L
        LHLD    PTSIN
        JMP     OUTLN
;
; ==== Outline ================================================================
;
; OUTLN -- the closed polygon of BC points at HL, in the current color and
; pattern: every vertex and edge pixel drawn once (lines don't draw their
; end points). Two points are a line with both ends.
;
OUTLN:  MOV     A,B
        ORA     A
        JNZ     OL1
        MOV     A,C
        CPI     2
        RC
        JZ      OLTWO
OL1:    PUSH    H               ;the first point, to close on
        DCX     B
        CALL    LDXY
        CALL    CZMOVE
OL2:    LHLD    LDPTR
        CALL    LDXY
        CALL    CZLINE
        DCX     B
        MOV     A,B
        ORA     C
        JNZ     OL2
        POP     H
        CALL    LDXY
        JMP     CZLINE
OLTWO:  CALL    LDXY
        CALL    CZMOVE
        LHLD    LDPTR
        CALL    LDXY
        CALL    CZLINE
        JMP     CZDOT
;
; ==== Spans ==================================================================
;
; FSPAN -- fill X = HL .. BC (HL <= BC) on raster Y = DE, the pattern
; pointer first put at (X AND 15, Y AND 15). Keeps BC, DE, HL.
;
FSPAN:  PUSH    H
        MOV     A,L             ;Pr05 = (Y AND 15) * 1000H + (X AND 15) * 10H
        ANI     0FH
        RLC
        RLC
        RLC
        RLC
        MOV     L,A
        MOV     A,E
        ANI     0FH
        RLC
        RLC
        RLC
        RLC
        MOV     H,A
        MVI     A,05H
        CALL    CZWPR
        POP     H
        CALL    CZMOVE
        PUSH    H
        MOV     H,B
        MOV     L,C
        CALL    CZFRCT
        POP     H
        RET
;
; ==== The polygon scan fill ==================================================
;
; FPOLY -- fill the polygon of BC points at HL (X,Y word pairs), the
; spans only, in the current color and pattern. At most MAXE points are
; used.
;
FPOLY:  SHLD    FPP
        MOV     A,B             ;at most MAXE
        ORA     A
        JNZ     FP0
        MOV     A,C
        CPI     MAXE+1
        JC      FP00
FP0:    LXI     B,MAXE
FP00:   MOV     H,B
        MOV     L,C
        SHLD    FPI
        LHLD    FPP
        SHLD    FPA
        LXI     H,ETAB
        SHLD    FPE
        XRA     A
        STA     FNE
        LXI     H,7FFFH
        SHLD    YMIN
        LXI     H,8000H
        SHLD    YMAX
;
; The edge table: each edge from point A to point B (the last back to the
; first), but not the horizontal ones, as YLO, YHI, X (16.16, at YLO),
; and the slope dX/dY (16.16).
FE1:    LHLD    FPI
        DCX     H
        SHLD    FPI
        MOV     A,H
        ORA     L
        LHLD    FPA
        LXI     D,4
        DAD     D
        JNZ     FE2
        LHLD    FPP             ;the last edge closes on the first point
FE2:    SHLD    FPB
        LHLD    FPA
        CALL    LDXY
        SHLD    EX1
        XCHG
        SHLD    EY1
        LHLD    FPB
        CALL    LDXY
        SHLD    EX2
        XCHG
        SHLD    EY2
        XCHG                    ;DE = EY2
        LHLD    EY1
        MOV     A,L             ;horizontal? skip it
        CMP     E
        JNZ     FE3
        MOV     A,H
        CMP     D
        JZ      FENX
FE3:    CALL    CPSGN           ;EY1 < EY2? else swap the ends
        JC      FE4
        LHLD    EY1
        XCHG
        LHLD    EY2
        SHLD    EY1
        XCHG
        SHLD    EY2
        LHLD    EX1
        XCHG
        LHLD    EX2
        SHLD    EX1
        XCHG
        SHLD    EX2
FE4:    LHLD    EY1             ;the record: YLO, YHI
        SHLD    EREC
        LHLD    EY2
        SHLD    EREC+2
        LXI     H,8000H         ;X = EX1 + 1/2
        SHLD    EREC+4
        LHLD    EX1
        SHLD    EREC+6
        LHLD    EY1             ;BC = dY = EY2 - EY1 (> 0)
        XCHG
        LHLD    EY2
        MOV     A,L
        SUB     E
        MOV     C,A
        MOV     A,H
        SBB     D
        MOV     B,A
        LHLD    EX1             ;HL = dX = EX2 - EX1
        XCHG
        LHLD    EX2
        MOV     A,L
        SUB     E
        MOV     L,A
        MOV     A,H
        SBB     D
        MOV     H,A
        STA     ESGN            ;(its sign, in A's top bit)
        ORA     A
        JP      FE5
        CALL    NEGHL
FE5:    XCHG                    ;slope = |dX| * 10000H / dY
        LXI     H,0
        CALL    UDIV
        LDA     ESGN
        ORA     A
        JP      FE6
        CALL    NEG32
FE6:    SHLD    EREC+8
        XCHG
        SHLD    EREC+10
        LHLD    FPE             ;into the table
        XCHG
        LXI     H,EREC
        LXI     B,12
        CALL    COPY
        XCHG
        SHLD    FPE
        LXI     H,FNE
        INR     M
        LHLD    EY1             ;YMIN, YMAX
        XCHG
        LHLD    YMIN
        CALL    CPSGN           ;YMIN < EY1? keep it
        JC      FE7
        XCHG
        SHLD    YMIN
FE7:    LHLD    EY2
        XCHG
        LHLD    YMAX
        CALL    CPSGN           ;YMAX < EY2? take EY2
        JNC     FENX
        XCHG
        SHLD    YMAX
FENX:   LHLD    FPB
        SHLD    FPA
        LHLD    FPI
        MOV     A,H
        ORA     L
        JNZ     FE1
;
; The scan, from YMIN up to (not including) YMAX.
        LDA     FNE
        ORA     A
        RZ
        LHLD    YMIN
        SHLD    FY
FS1:    LHLD    YMAX            ;FY < YMAX?
        XCHG
        LHLD    FY
        CALL    CPSGN
        RNC
        XRA     A               ;the crossings: the X of each edge it meets
        STA     FNX
        LXI     H,ETAB
        SHLD    FPE
        LDA     FNE
        STA     FCNT
FS2:    LHLD    FPE
        MOV     E,M             ;DE = YLO
        INX     H
        MOV     D,M
        INX     H
        PUSH    H
        LHLD    FY
        CALL    CPSGN           ;FY < YLO: not yet
        POP     H
        JC      FSNX
        MOV     E,M             ;DE = YHI
        INX     H
        MOV     D,M
        INX     H
        PUSH    H
        LHLD    FY
        CALL    CPSGN           ;FY < YHI: it crosses
        POP     H
        JNC     FSNX
        PUSH    H               ;HL -> X
        MOV     C,M             ;BC = X's fraction
        INX     H
        MOV     B,M
        INX     H
        MOV     E,M             ;DE = X's whole part: the crossing
        INX     H
        MOV     D,M
        INX     H
        PUSH    H               ;HL -> the slope
        LDA     FNX
        MOV     L,A
        MVI     H,0
        DAD     H
        PUSH    D
        LXI     D,XSTAB
        DAD     D
        POP     D
        MOV     M,E
        INX     H
        MOV     M,D
        LXI     H,FNX
        INR     M
        POP     H
        MOV     A,C             ;X += the slope
        ADD     M
        MOV     C,A
        INX     H
        MOV     A,B
        ADC     M
        MOV     B,A
        INX     H
        MOV     A,E
        ADC     M
        MOV     E,A
        INX     H
        MOV     A,D
        ADC     M
        MOV     D,A
        POP     H
        MOV     M,C
        INX     H
        MOV     M,B
        INX     H
        MOV     M,E
        INX     H
        MOV     M,D
FSNX:   LHLD    FPE
        LXI     D,12
        DAD     D
        SHLD    FPE
        LXI     H,FCNT
        DCR     M
        JNZ     FS2
        CALL    XSORT
        LDA     FNX             ;fill between each pair of crossings
        ORA     A
        RAR
        ORA     A
        JZ      FSNY
        STA     FCNT
        LXI     H,XSTAB
FS3:    MOV     E,M             ;DE = the left X
        INX     H
        MOV     D,M
        INX     H
        MOV     C,M             ;BC = the right X
        INX     H
        MOV     B,M
        INX     H
        PUSH    H
        XCHG
        PUSH    H
        LHLD    FY
        XCHG
        POP     H
        CALL    FSPAN
        POP     H
        LDA     FCNT
        DCR     A
        STA     FCNT
        JNZ     FS3
FSNY:   LHLD    FY
        INX     H
        SHLD    FY
        JMP     FS1
;
; XSORT -- sort the FNX crossings at XSTAB, signed, smallest first
; (a bubble sort: there are seldom more than four)
;
XSORT:  LDA     FNX
        CPI     2
        RC
XSP:    XRA     A
        STA     XSW
        LDA     FNX
        DCR     A
        MOV     B,A
        LXI     H,XSTAB
XSC:    MOV     E,M             ;DE = this one
        INX     H
        MOV     D,M
        INX     H
        MOV     C,M             ;HL' = the next
        INX     H
        MOV     A,M
        DCX     H
        PUSH    H
        MOV     H,A
        MOV     L,C
        CALL    CPSGN           ;next < this? swap them
        POP     H
        JNC     XSN
        MOV     C,M             ;HL -> the next: A:C = it, it = this
        MOV     M,E
        INX     H
        MOV     A,M
        MOV     M,D
        DCX     H
        DCX     H
        MOV     M,A             ;this = the next
        DCX     H
        MOV     M,C
        INX     H
        INX     H
        MVI     A,1
        STA     XSW
XSN:    DCR     B
        JNZ     XSC
        LDA     XSW
        ORA     A
        JNZ     XSP
        RET
;
; ==== Filled circles =========================================================
;
; FCIRC -- fill the circle of radius BC round X = HL, Y = DE: for each
; raster from the centre out, the half-width W with W^2 + dY^2 <= r^2.
; F = W^2 + dY^2 - r^2 is kept small, so it fits 16 bits: dY up one adds
; 2dY - 1, W down one takes 2W - 1 off.
;
FCIRC:  SHLD    FCX
        XCHG
        SHLD    FCY
        MOV     H,B
        MOV     L,C
        SHLD    FCR
        SHLD    FCW
        LXI     H,0
        SHLD    FCDY
        SHLD    FCF
FC1:    LHLD    FCX             ;HL = X - W, BC = X + W
        XCHG
        LHLD    FCW
        DAD     D
        MOV     B,H
        MOV     C,L
        LHLD    FCW
        CALL    NEGHL
        DAD     D
        PUSH    H
        LHLD    FCY             ;the raster above the centre
        XCHG
        LHLD    FCDY
        DAD     D
        XCHG
        POP     H
        CALL    FSPAN
        PUSH    H
        LHLD    FCDY            ;and below it (not the centre twice)
        MOV     A,H
        ORA     L
        JZ      FC2
        CALL    NEGHL
        XCHG
        LHLD    FCY
        DAD     D
        XCHG
        POP     H
        CALL    FSPAN
        PUSH    H
FC2:    POP     H
        LHLD    FCDY            ;dY up one: done past the radius
        INX     H
        SHLD    FCDY
        XCHG
        LHLD    FCR
        CALL    CPSGN           ;r < dY?
        RC
        LHLD    FCDY            ;F += 2dY - 1
        DAD     H
        DCX     H
        XCHG
        LHLD    FCF
        DAD     D
        SHLD    FCF
FC3:    LHLD    FCF             ;while F > 0: F -= 2W - 1, W down one
        MOV     A,H
        ORA     A
        JM      FC1
        ORA     L
        JZ      FC1
        LHLD    FCW
        DAD     H
        DCX     H
        CALL    NEGHL
        XCHG
        LHLD    FCF
        DAD     D
        SHLD    FCF
        LHLD    FCW
        DCX     H
        SHLD    FCW
        JMP     FC3
;
        DSEG
FAN:    DS      2
FPP:    DS      2               ;the points
FPI:    DS      2               ;edges still to set up
FPA:    DS      2               ;this edge's two points
FPB:    DS      2
FPE:    DS      2               ;in the edge table
FNE:    DS      1               ;edges in it
FNX:    DS      1               ;crossings on this raster
FCNT:   DS      1
XSW:    DS      1
ESGN:   DS      1
EX1:    DS      2
EY1:    DS      2
EX2:    DS      2
EY2:    DS      2
YMIN:   DS      2
YMAX:   DS      2
FY:     DS      2
EREC:   DS      12
FCX:    DS      2
FCY:    DS      2
FCR:    DS      2
FCW:    DS      2
FCDY:   DS      2
FCF:    DS      2
ETAB:   DS      12*MAXE         ;the edge table
XSTAB:  DS      2*MAXE          ;the crossings
;
        END
