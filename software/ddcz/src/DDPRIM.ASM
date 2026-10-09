;
; DDPRIM.ASM -- CADzilla GSX driver: the output primitives. Polyline (6),
; polymarker (7), text (8), cell array (10), the GDPs (11: bar, arc, pie
; slice, circle) and inquire cell array (27).
;
        PUBLIC  PLINE,PMARK,TEXT,CELLA,GDP,QCELL
;
        EXTRN   CONTRL,INTIN,PTSIN,INTOUT
        EXTRN   WMODE,LCOL,LTYPE,MCOL,MTYPE,MHGT
        EXTRN   TCOL,TFONT,TSCAL,TDIR,FCOL,FSTYL,PSTATE
        EXTRN   CTLW,INW,PTW,OUTW,SETC5,DRWCOL,NOXOR,LDXY,LDPTR,LDCOL
        EXTRN   USEPAT,FPAT,FMET
        EXTRN   FPOLY,FCIRC,OUTLN
        EXTRN   MULDIV,MUL,UDIV,NEGHL,CPSGN,ISIN,ICOS,SMULQ,SWRMOD
        EXTRN   CZMOVE,CZLINE,CZRECT,CZFRCT,CZDOT,CZCRCL,CZARC
        EXTRN   CZWPR,CZWAIT,CZRDOT,CZDM
        EXTRN   CZTFNT,CZTSTR,CZTPOS,CZTATR,CZF8,CZF11
;
OPAARC  EQU     0B0H            ;AARC: absolute arc, counter-clockwise
TXOPAQ  EQU     1               ;CZTATR: the cell's 0 bits in CL0
TXMAX   EQU     128             ;the longest string drawn
MAXPIE  EQU     40              ;pie slice points
OMMASK  EQU     0E0H            ;CZDM's area-mode bits
;
        CSEG
;
; ==== 6: Polyline ===========================================================
;
; Lines don't draw their end points, so each vertex is drawn once, and the
; last one is drawn as a dot. A single point draws nothing.
;
PLINE:  MVI     A,2
        CALL    CTLW
        MOV     A,H
        ORA     A
        JNZ     PL1
        MOV     A,L
        CPI     2
        RC
PL1:    SHLD    PLCNT
        LDA     LTYPE
        CALL    USEPAT
        LDA     LCOL
        CALL    DRWCOL
        LHLD    PTSIN
        CALL    LDXY
        CALL    CZMOVE
PL2:    LHLD    PLCNT
        DCX     H
        SHLD    PLCNT
        MOV     A,H
        ORA     L
        JZ      PL3
        LHLD    LDPTR
        CALL    LDXY
        CALL    CZLINE          ;(keeps HL, DE)
        SHLD    LASTX
        XCHG
        SHLD    LASTY
        JMP     PL2
PL3:    LHLD    LASTY
        XCHG
        LHLD    LASTX
        JMP     CZDOT
;
; ==== 7: Polymarker =========================================================
;
; 1 dot, 2 plus, 3 asterisk, 4 circle, 5 diagonal cross, MHGT high. Each
; is the centre dot and "spokes" drawn from their outer ends in to the
; centre, which a line doesn't draw -- so no pixel twice, and XOR works.
;
PMARK:  MVI     A,2
        CALL    CTLW
        MOV     A,H
        ORA     L
        RZ
        SHLD    PLCNT
        MVI     A,1
        CALL    USEPAT
        LDA     MCOL
        CALL    DRWCOL
        LHLD    MHGT            ;the arm: half the height
        ORA     A
        MOV     A,H
        RAR
        MOV     H,A
        MOV     A,L
        RAR
        MOV     L,A
        SHLD    MARM
        LXI     B,181           ;and a diagonal arm: * 0.707
        XCHG
        LXI     H,256
        CALL    MULDIV
        SHLD    MDIA
        LHLD    PTSIN
        SHLD    LDPTR
PM1:    LHLD    LDPTR
        CALL    LDXY
        SHLD    MX
        XCHG
        SHLD    MY
        LDA     MTYPE
        CPI     4
        JZ      PMCIR
        LHLD    MY              ;the centre dot
        XCHG
        LHLD    MX
        CALL    CZDOT
        LDA     MTYPE
        CPI     1
        JZ      PMNX
        CPI     5
        JZ      PMX
        LHLD    MARM            ;plus, asterisk: the four straight spokes
        SHLD    SPLEN
        LXI     H,SPPLUS
        CALL    SPOKES
        LDA     MTYPE
        CPI     3
        JNZ     PMNX
        LHLD    MDIA            ;asterisk: and four shorter diagonals
        SHLD    SPLEN
        LXI     H,SPDIAG
        CALL    SPOKES
        JMP     PMNX
PMX:    LHLD    MARM            ;cross: the diagonals, full length
        SHLD    SPLEN
        LXI     H,SPDIAG
        CALL    SPOKES
        JMP     PMNX
PMCIR:  LHLD    MY
        XCHG
        LHLD    MX
        CALL    CZMOVE
        LHLD    MARM
        CALL    CZCRCL
PMNX:   LHLD    PLCNT
        DCX     H
        SHLD    PLCNT
        MOV     A,H
        ORA     L
        JNZ     PM1
        RET
;
; SPOKES -- four spokes round MX, MY, SPLEN long, in the directions at HL
; (DB dx, dy: -1, 0 or 1)
SPOKES: MVI     B,4
SPK1:   PUSH    B
        MOV     A,M             ;the outer end: MX + dx * SPLEN
        INX     H
        PUSH    H
        LHLD    MX
        CALL    ADDSL
        SHLD    SPX
        POP     H
        MOV     A,M
        INX     H
        PUSH    H
        LHLD    MY
        CALL    ADDSL
        XCHG
        LHLD    SPX
        CALL    CZMOVE
        LHLD    MY              ;in to the centre
        XCHG
        LHLD    MX
        CALL    CZLINE
        POP     H
        POP     B
        DCR     B
        JNZ     SPK1
        RET
;
; ADDSL -- HL += A * SPLEN, A = -1, 0 or 1
ADDSL:  ORA     A
        RZ
        XCHG
        LHLD    SPLEN
        JP      AS1
        CALL    NEGHL
AS1:    DAD     D
        RET
;
SPPLUS: DB      1,0, 0,1, 0FFH,0, 0,0FFH
SPDIAG: DB      1,1, 0FFH,1, 0FFH,0FFH, 1,0FFH
;
; ==== 8: Text ===============================================================
;
; contrl(4) characters in intin, from ptsin(1), ptsin(2): the bottom left
; of the first character itself (its baseline), not of its cell. In
; replace mode the cells are opaque (their 0 bits in color 0).
;
TEXT:   MVI     A,4
        CALL    CTLW
        MOV     A,H
        ORA     L
        RZ
        MOV     A,H             ;at most TXMAX
        ORA     A
        JNZ     TX0
        MOV     A,L
        CPI     TXMAX+1
        JC      TX00
TX0:    LXI     H,TXMAX
TX00:   MOV     B,L
        PUSH    B
        LHLD    INTIN           ;the words' low bytes into TXBUF
        LXI     D,TXBUF
TX1:    MOV     A,M
        STAX    D
        INX     H
        INX     H
        INX     D
        DCR     B
        JNZ     TX1
        LDA     TFONT           ;the font
        LXI     H,CZF8
        CPI     2
        JNZ     TX2
        LXI     H,CZF11
TX2:    CALL    CZTFNT
        LDA     WMODE           ;opaque in replace mode
        CPI     1
        MVI     C,0
        JNZ     TX3
        MVI     C,TXOPAQ
TX3:    LDA     TDIR
        MOV     B,A
        LDA     TSCAL
        CALL    CZTATR
        LDA     TCOL
        CALL    DRWCOL
        CALL    FMET            ;the pen: the baseline's rows below it,
        LXI     D,4             ;scaled, back along the up direction
        DAD     D
        MOV     A,M
        LXI     H,0
        ORA     A
        JZ      TX5
        MOV     B,A
        LDA     TSCAL
        MOV     C,A
TX4:    MOV     E,C
        MVI     D,0
        DAD     D
        DCR     B
        JNZ     TX4
TX5:    SHLD    SPLEN           ;the offset
        LDA     TDIR            ;the up vector, at TDIR + 90 degrees
        ADD     A
        MOV     E,A
        MVI     D,0
        LXI     H,UPVEC
        DAD     D
        MOV     A,M             ;-ux
        INX     H
        PUSH    H
        CMA
        INR     A
        PUSH    PSW
        MVI     A,1
        CALL    PTW
        POP     PSW
        CALL    ADDSL
        SHLD    SPX
        POP     H
        MOV     A,M             ;-uy
        CMA
        INR     A
        PUSH    PSW
        MVI     A,2
        CALL    PTW
        POP     PSW
        CALL    ADDSL
        XCHG
        LHLD    SPX
        CALL    CZTPOS
        POP     B
        LXI     H,TXBUF
        CALL    CZTSTR
        MVI     A,1             ;czgfx left the pattern RAM solid
        STA     PSTATE
        RET
;
UPVEC:  DB      0,1, 0FFH,1, 0FFH,0, 0FFH,0FFH
        DB      0,0FFH, 1,0FFH, 1,0, 1,1
;
; ==== 11: Generalized drawing primitives =====================================
;
GDP:    MVI     A,6             ;the primitive, contrl(6)
        CALL    CTLW
        MOV     A,H
        ORA     A
        RNZ
        MOV     A,L
        CPI     1
        JZ      BAR
        CPI     2
        JZ      ARC
        CPI     3
        JZ      PIE
        CPI     4
        JZ      CIRCLE
        RET                     ;5, ruling characters, and the rest: nothing
;
; 1: bar, ptsin(1)-(4) = two opposite corners, in the fill attributes
BAR:    CALL    CORNRS          ;BX0, BY0 .. BX1, BY1
        LDA     FCOL
        CALL    DRWCOL
        LDA     FSTYL
        ORA     A
        JZ      BAROUT
        CALL    FPAT
        CALL    USEPAT
        LHLD    BX0             ;the pattern lined up with the screen's grid
        MOV     A,L
        ANI     0FH
        RLC
        RLC
        RLC
        RLC
        MOV     L,A
        LDA     BY0
        ANI     0FH
        RLC
        RLC
        RLC
        RLC
        MOV     H,A
        MVI     A,05H
        CALL    CZWPR
        CALL    BMOVE
        LHLD    BY1
        XCHG
        LHLD    BX1
        CALL    CZFRCT
        LDA     FSTYL
        CPI     1
        RZ                      ;solid: no perimeter needed
        CALL    NOXOR
        RZ
BAROUT: MVI     A,1
        CALL    USEPAT
        LDA     FCOL
        CALL    DRWCOL
        CALL    BMOVE
        LHLD    BY1
        XCHG
        LHLD    BX1
        JMP     CZRECT
BMOVE:  LHLD    BY0
        XCHG
        LHLD    BX0
        JMP     CZMOVE
;
; CORNRS -- BX0, BY0 = the lower left, BX1, BY1 = the upper right of the
; corners in ptsin(1)-(4)
CORNRS: MVI     A,1
        CALL    PTW
        SHLD    BX0
        MVI     A,3
        CALL    PTW
        SHLD    BX1
        LXI     H,BX0
        CALL    ORDER
        MVI     A,2
        CALL    PTW
        SHLD    BY0
        MVI     A,4
        CALL    PTW
        SHLD    BY1
        LXI     H,BY0
;
; ORDER -- the words at HL and HL+4: the smaller first (signed)
ORDER:  PUSH    H
        MOV     E,M
        INX     H
        MOV     D,M
        INX     H
        INX     H
        INX     H
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A             ;HL = the second, DE = the first
        CALL    CPSGN
        POP     B
        RNC                     ;second >= first: as they are
        MOV     A,L             ;swap
        STAX    B
        INX     B
        MOV     A,H
        STAX    B
        INX     B
        INX     B
        INX     B
        MOV     A,E
        STAX    B
        INX     B
        MOV     A,D
        STAX    B
        RET
;
; 2: arc, in the line attributes: the ACRTC's own, counter-clockwise from
; the start point, ptsin(3)-(4), round the centre, ptsin(1)-(2), to the
; ray through the end point, ptsin(5)-(6)
ARC:    LDA     LTYPE
        CALL    USEPAT
        LDA     LCOL
        CALL    DRWCOL
        MVI     A,4
        CALL    PTW
        XCHG
        MVI     A,3
        CALL    PTW
        CALL    CZMOVE
        LXI     D,ARCT          ;Xc, Yc, Xe, Ye
        MVI     A,1
        CALL    PTW
        CALL    STDEL
        MVI     A,2
        CALL    PTW
        CALL    STDEL
        MVI     A,5
        CALL    PTW
        CALL    STDEL
        MVI     A,6
        CALL    PTW
        CALL    STDEL
        LXI     H,ARCT
        MVI     A,OPAARC
        JMP     CZARC
;
; STDEL -- the word HL at DE; DE += 2
STDEL:  XCHG
        MOV     M,E
        INX     H
        MOV     M,D
        INX     H
        XCHG
        RET
;
; 4: circle, centre ptsin(1)-(2), radius ptsin(5), in the fill attributes
CIRCLE: MVI     A,1
        CALL    PTW
        SHLD    MX
        MVI     A,2
        CALL    PTW
        SHLD    MY
        MVI     A,5
        CALL    PTW
        SHLD    SPLEN
        LDA     FCOL
        CALL    DRWCOL
        LDA     FSTYL
        ORA     A
        JZ      CIROUT
        CALL    FPAT
        CALL    USEPAT
        LHLD    SPLEN
        MOV     B,H
        MOV     C,L
        LHLD    MY
        XCHG
        LHLD    MX
        CALL    FCIRC
        LDA     FSTYL
        CPI     1
        RZ                      ;solid: the spans cover its edge
        CALL    NOXOR
        RZ
CIROUT: MVI     A,1
        CALL    USEPAT
        LDA     FCOL
        CALL    DRWCOL
        LHLD    MY
        XCHG
        LHLD    MX
        CALL    CZMOVE
        LHLD    SPLEN
        JMP     CZCRCL
;
; 3: pie slice, centre ptsin(1)-(2), radius ptsin(7), from intin(1) to
; intin(2) tenths of a degree, counter-clockwise, in the fill attributes:
; a polygon, the centre and points on the arc 10 degrees apart.
PIE:    MVI     A,1
        CALL    PTW
        SHLD    MX
        MVI     A,2
        CALL    PTW
        SHLD    MY
        MVI     A,7
        CALL    PTW
        SHLD    SPLEN
        MVI     A,1             ;the angles, to whole degrees
        CALL    ANGDEG
        SHLD    PA0
        MVI     A,2
        CALL    ANGDEG
        XCHG
        LHLD    PA0             ;the end at or before the start: + 360
        CALL    CPSGN           ;start < end?
        XCHG
        JC      PI1
        LXI     D,360
        DAD     D
PI1:    SHLD    PA1
        LXI     H,PIEPT         ;the centre first
        SHLD    PPTR
        LHLD    MX
        CALL    PPUT
        LHLD    MY
        CALL    PPUT
        LXI     H,1
        SHLD    PNPT
PI2:    LHLD    PA1             ;each 10 degrees from the start, then the end
        XCHG
        LHLD    PA0
        CALL    CPSGN           ;angle < end?
        JNC     PI3
        CALL    PPOINT
        LHLD    PA0
        LXI     D,10
        DAD     D
        SHLD    PA0
        JMP     PI2
PI3:    LHLD    PA1
        SHLD    PA0
        CALL    PPOINT
        LDA     FCOL
        CALL    DRWCOL
        LDA     FSTYL
        ORA     A
        JZ      PIOUT
        CALL    FPAT
        CALL    USEPAT
        LHLD    PNPT
        MOV     B,H
        MOV     C,L
        LXI     H,PIEPT
        CALL    FPOLY
        CALL    NOXOR
        RZ
PIOUT:  MVI     A,1
        CALL    USEPAT
        LDA     FCOL
        CALL    DRWCOL
        LHLD    PNPT
        MOV     B,H
        MOV     C,L
        LXI     H,PIEPT
        JMP     OUTLN
;
; PPOINT -- the arc's point at PA0 degrees onto the polygon
PPOINT: LHLD    PNPT
        LXI     D,MAXPIE
        MOV     A,L
        SUB     E
        MOV     A,H
        SBB     D
        RNC                     ;full
        INX     H
        SHLD    PNPT
        LHLD    PA0             ;X = MX + r cos a
        CALL    ICOS
        XCHG
        LHLD    SPLEN
        XCHG
        CALL    SMULQ
        XCHG
        LHLD    MX
        DAD     D
        CALL    PPUT
        LHLD    PA0             ;Y = MY + r sin a
        CALL    ISIN
        XCHG
        LHLD    SPLEN
        XCHG
        CALL    SMULQ
        XCHG
        LHLD    MY
        DAD     D
;
; PPUT -- the word HL onto the pie's points
PPUT:   XCHG
        LHLD    PPTR
        MOV     M,E
        INX     H
        MOV     M,D
        INX     H
        SHLD    PPTR
        RET
;
; ANGDEG -- HL = intin(A), tenths of a degree, as whole degrees (rounded;
; negative is 0)
ANGDEG: CALL    INW
        MOV     A,H
        ORA     A
        JP      AD1
        LXI     H,0
AD1:    LXI     D,5
        DAD     D
        XCHG
        LXI     H,0
        XCHG                    ;DE:HL = the tenths + 5
        LXI     B,10
        JMP     UDIV
;
; ==== 10: Cell array ========================================================
;
; ptsin(1)-(2) the lower left, (3)-(4) the upper right; contrl(6) the
; length of a row in intin, (7) the cells used of each, (8) the rows,
; (9) the writing mode for it. Rows go top down. Each cell is a filled
; rectangle in its color index.
;
CELLA:  CALL    CORNRS
        MVI     A,7
        CALL    CTLW
        SHLD    CAX
        MVI     A,8
        CALL    CTLW
        SHLD    CNR
        MVI     A,6
        CALL    CTLW
        SHLD    CRL
        LHLD    CAX             ;no cells: just the outline, in line color
        MOV     A,H
        ORA     L
        JZ      CAOUT
        LHLD    CNR
        MOV     A,H
        ORA     L
        JZ      CAOUT
        LDA     WMODE           ;this array's own writing mode
        STA     CWM
        LDA     CZDM
        STA     CDM
        MVI     A,9
        CALL    CTLW
        SHLD    CTMP
        LHLD    INTIN
        PUSH    H
        LXI     H,CTMP
        SHLD    INTIN
        CALL    SWRMOD
        POP     H
        SHLD    INTIN
        LXI     H,0             ;(SWRMOD's intout(1) isn't this call's)
        CALL    SETC5
        MVI     A,1
        CALL    USEPAT
        CALL    CWH             ;CW, CH = the width, height
        LXI     H,0
        SHLD    CR
CA1:    LHLD    CR              ;this row's top and bottom
        CALL    CROWY
        SHLD    CYT
        LHLD    CR
        INX     H
        CALL    CROWY
        INX     H
        SHLD    CYB
        LHLD    CR              ;CPTR = intin + CR * CRL words
        MOV     B,H
        MOV     C,L
        LHLD    CRL
        XCHG
        CALL    MULW
        DAD     H
        XCHG
        LHLD    INTIN
        DAD     D
        SHLD    CPTR
        LXI     H,0
        SHLD    CCX
CA2:    LHLD    CCX              ;this cell's left and right
        CALL    CCOLX
        SHLD    CXL
        LHLD    CCX
        INX     H
        CALL    CCOLX
        DCX     H
        SHLD    CXR
        XCHG                    ;too narrow to draw? skip it
        LHLD    CXL
        XCHG
        CALL    CPSGN           ;right < left?
        JC      CA3
        LHLD    CYT
        XCHG
        LHLD    CYB
        XCHG
        CALL    CPSGN           ;top < bottom?
        JC      CA3
        LHLD    CPTR
        CALL    LDCOL
        CALL    DRWCOL
        LHLD    CYB
        XCHG
        LHLD    CXL
        CALL    CZMOVE
        LHLD    CYT
        XCHG
        LHLD    CXR
        CALL    CZFRCT
CA3:    LHLD    CPTR
        INX     H
        INX     H
        SHLD    CPTR
        LHLD    CCX
        INX     H
        SHLD    CCX
        XCHG
        LHLD    CAX
        MOV     A,E
        SUB     L
        MOV     A,D
        SBB     H
        JC      CA2
        LHLD    CR
        INX     H
        SHLD    CR
        XCHG
        LHLD    CNR
        MOV     A,E
        SUB     L
        MOV     A,D
        SBB     H
        JC      CA1
        LDA     CWM             ;the writing mode back
        STA     WMODE
        LDA     CDM
        STA     CZDM
        RET
CAOUT:  MVI     A,1
        CALL    USEPAT
        LDA     LCOL
        CALL    DRWCOL
        CALL    BMOVE
        LHLD    BY1
        XCHG
        LHLD    BX1
        JMP     CZRECT
;
; CWH -- CW = BX1 - BX0 + 1, CH = BY1 - BY0 + 1
CWH:    LHLD    BX0
        XCHG
        LHLD    BX1
        CALL    SUBDE
        INX     H
        SHLD    CW
        LHLD    BY0
        XCHG
        LHLD    BY1
        CALL    SUBDE
        INX     H
        SHLD    CH
        RET
;
; SUBDE -- HL = HL - DE
SUBDE:  MOV     A,L
        SUB     E
        MOV     L,A
        MOV     A,H
        SBB     D
        MOV     H,A
        RET
;
; CCOLX -- HL = BX0 + HL * CW / CAX, a column's left edge
CCOLX:  MOV     B,H
        MOV     C,L
        LHLD    CW
        XCHG
        LHLD    CAX
        CALL    MULDIV
        XCHG
        LHLD    BX0
        DAD     D
        RET
;
; CROWY -- HL = BY1 - HL * CH / CNR, the top of a row (rows from the top)
CROWY:  MOV     B,H
        MOV     C,L
        LHLD    CH
        XCHG
        LHLD    CNR
        CALL    MULDIV
        XCHG
        LHLD    BY1
        JMP     SUBDE
;
; MULW -- HL = BC * DE, the low word
MULW:   CALL    MUL
        XCHG
        RET
;
; ==== 27: Inquire cell array =================================================
;
; Read the array back: contrl(6) cells across, (7) rows, over ptsin(1)-(4);
; each cell's color is the pixel at its centre. intout gets them a row at
; a time from the top; contrl(8), (9) the size used, (10) = 0, no errors.
;
QCELL:  CALL    CORNRS
        MVI     A,6
        CALL    CTLW
        SHLD    CAX
        MVI     A,7
        CALL    CTLW
        SHLD    CNR
        CALL    CWH
        CALL    CZWAIT          ;the ACRTC done drawing first
        LHLD    INTOUT
        SHLD    CPTR
        LXI     H,0
        SHLD    CNT
        LHLD    CNR             ;none: nothing
        MOV     A,H
        ORA     L
        JZ      QC4
        LHLD    CAX
        MOV     A,H
        ORA     L
        JZ      QC4
        LXI     H,0
        SHLD    CR
QC1:    LHLD    CR              ;the row's centre: BY1 - (2r+1) * CH / 2CNR
        DAD     H
        INX     H
        MOV     B,H
        MOV     C,L
        LHLD    CH
        XCHG
        LHLD    CNR
        DAD     H
        CALL    MULDIV
        XCHG
        LHLD    BY1
        CALL    SUBDE
        SHLD    CYT
        LXI     H,0
        SHLD    CCX
QC2:    LHLD    CCX              ;the column's: BX0 + (2c+1) * CW / 2CNC
        DAD     H
        INX     H
        MOV     B,H
        MOV     C,L
        LHLD    CW
        XCHG
        LHLD    CAX
        DAD     H
        CALL    MULDIV
        XCHG
        LHLD    BX0
        DAD     D
        XCHG                    ;DE = X
        LHLD    CYT
        XCHG                    ;HL = X, DE = Y
        CALL    CZRDOT
        MOV     L,A
        MVI     H,0
        JNC     QC3
        LXI     H,0FFFFH        ;off the screen: -1
QC3:    XCHG
        LHLD    CPTR
        MOV     M,E
        INX     H
        MOV     M,D
        INX     H
        SHLD    CPTR
        LHLD    CNT
        INX     H
        SHLD    CNT
        LHLD    CCX
        INX     H
        SHLD    CCX
        XCHG
        LHLD    CAX
        MOV     A,E
        SUB     L
        MOV     A,D
        SBB     H
        JC      QC2
        LHLD    CR
        INX     H
        SHLD    CR
        XCHG
        LHLD    CNR
        MOV     A,E
        SUB     L
        MOV     A,D
        SBB     H
        JC      QC1
QC4:    LHLD    CONTRL          ;contrl(8), (9), (10)
        LXI     D,14
        DAD     D
        XCHG
        LHLD    CAX
        CALL    STDEL
        LHLD    CNR
        CALL    STDEL
        LXI     H,0
        CALL    STDEL
        LHLD    CNT
        JMP     SETC5
;
        DSEG
PLCNT:  DS      2
LASTX:  DS      2
LASTY:  DS      2
MARM:   DS      2               ;the marker's arm
MDIA:   DS      2               ;its diagonal arm
MX:     DS      2               ;this marker's (circle's, pie's) centre
MY:     DS      2
SPLEN:  DS      2
SPX:    DS      2
TXBUF:  DS      TXMAX
BX0:    DS      2               ;bar and cell array corners (ORDER: the
BY0:    DS      2               ;same order matters: X0, Y0, X1, Y1)
BX1:    DS      2
BY1:    DS      2
ARCT:   DS      8
PA0:    DS      2
PA1:    DS      2
PPTR:   DS      2
PNPT:   DS      2
PIEPT:  DS      4*MAXPIE+4
CAX:    DS      2               ;cell array: cells across
CNR:    DS      2               ;rows
CRL:    DS      2               ;intin words a row
CW:     DS      2
CH:     DS      2
CR:     DS      2
CCX:     DS      2
CYT:    DS      2
CYB:    DS      2
CXL:    DS      2
CXR:    DS      2
CPTR:   DS      2
CNT:    DS      2
CTMP:   DS      2
CWM:    DS      1
CDM:    DS      1
;
        END
