;
; DDCZ.ASM -- CADzilla GSX-80 screen driver (GIOS): entry, dispatch, the
; workstation functions and the state and helpers the other modules share.
;
; The driver is built with DRI RMAC + LINK-80 into a .PRL, from these
; modules and the czgfx library (B:CZGFX.REL); one mode module (DM1K, ...)
; says which display mode this copy drives (DDCZ.SUB, cadzilla-build-rmac):
;   DDCZ    entry, dispatch, opcodes 1-4 and 32, shared state and helpers
;   DDATTR  attribute setters (12, 13, 15-25, 33) and the pattern RAM
;   DDPRIM  polyline, polymarker, text, cell array, GDPs (6-8, 10, 11, 27)
;   DDFILL  filled area (9): the polygon scan fill, spans, filled circles
;   DDCOL   the color table (14, 26)
;   DDESC   escape (5): alpha text on the CP/M console, graphic cursor
;   DDMATH  multiply, divide, sine
;
; GDOS calls the driver's first byte -- DDCZ, so this module links first --
; with DE = the GSX parameter block: the addresses of contrl, intin, ptsin,
; intout and ptsout. Every element is a 16-bit word; the GSX spec numbers
; them from 1, so contrl(1) is the word at contrl+0. Coordinates arrive in
; device units (GDOS has scaled them), origin bottom-left -- czgfx's own
; orientation, so they go to czgfx as they are. The driver returns with
; RET, having set contrl(3) (ptsout vertices) and contrl(5) (intout words).
;
; Every primitive sets its own color (DRWCOL) and pattern (USEPAT) before
; drawing: they share the ACRTC's CL1 and pattern RAM.
;
        PUBLIC  CONTRL,INTIN,PTSIN,INTOUT,PTSOUT
        PUBLIC  WMODE,LCOL,LTYPE,MCOL,MTYPE,MHGT
        PUBLIC  TCOL,TFONT,TSCAL,TDIR,TREQH,FCOL,FSTYL,FINDX,PSTATE
        PUBLIC  SETC3,SETC5,RET1A,RETHL,LDCOL,LDXY,STDE,COPY,DRWCOL
        PUBLIC  CTLW,INW,PTW,OUTW,PTOUT,NOXOR,LDPTR,SWRMOD
;
        EXTRN   DMDESC          ;mode module: DW the czgfx mode descriptor
        EXTRN   CZINIT,CZCLS,CZCOL,CZWAIT,CZXMAX,CZYMAX,CZDM
        EXTRN   CZOCLS,CZOVON,CZOPAL
        EXTRN   PLINE,PMARK,TEXT,CELLA,GDP,QCELL        ;DDPRIM
        EXTRN   FAREA                                   ;DDFILL
        EXTRN   SCHH,SCUP,SLTYP,SLWID,SLCOL,SMTYP       ;DDATTR
        EXTRN   SMHGT,SMCOL,STFNT,STCOL,SFINT,SFSTY
        EXTRN   SFCOL,SINMD,ATRINI
        EXTRN   SCOLR,QCOLR,PALINI                      ;DDCOL
        EXTRN   ESCAPE,ESCINI,GCOFF                     ;DDESC
;
NOPS    EQU     33              ;GSX opcodes 1-33
;
; czgfx drawing-mode fields (CZGFX.INC): operation, color and area modes
OMREP   EQU     0               ;P = C
OMEOR   EQU     3               ;P = P XOR C
CMSEL   EQU     00H             ;pattern 1 = CL1, 0 = CL0
CMCL1   EQU     08H             ;pattern 1 = CL1, 0 = left alone
AMCLIP  EQU     40H             ;draw only inside the area (the screen)
;
        CSEG
;
; ==== Entry ================================================================
;
DDCZ:   LXI     H,0             ;run on our own stack
        DAD     SP
        SHLD    OLDSP
        LXI     SP,STACK
        XCHG                    ;HL = parameter block
        LXI     D,CONTRL        ;keep its five array addresses
        MVI     B,10
DDPB:   MOV     A,M
        STAX    D
        INX     H
        INX     D
        DCR     B
        JNZ     DDPB
        LXI     H,0             ;nothing returned unless a function says so
        CALL    SETC3
        LXI     H,0
        CALL    SETC5
        LHLD    CONTRL          ;DE = the opcode, contrl(1)
        MOV     E,M
        INX     H
        MOV     D,M
        MOV     A,D
        ORA     A
        JNZ     DDRET           ;out of range: no action
        MOV     A,E
        DCR     A
        CPI     NOPS
        JNC     DDRET           ;0 or over 33: no action
        LXI     H,DDRET         ;the functions return to DDRET
        PUSH    H
        ADD     A
        MOV     E,A
        MVI     D,0
        LXI     H,OPTAB
        DAD     D
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        PCHL
;
DDRET:  LHLD    OLDSP
        SPHL
        RET
;
OPTAB:  DW      OPEN,CLOSE,CLEAR,UPDATE,ESCAPE          ;1-5
        DW      PLINE,PMARK,TEXT,FAREA,CELLA            ;6-10
        DW      GDP,SCHH,SCUP,SCOLR,SLTYP               ;11-15
        DW      SLWID,SLCOL,SMTYP,SMHGT,SMCOL           ;16-20
        DW      STFNT,STCOL,SFINT,SFSTY,SFCOL           ;21-25
        DW      QCOLR,QCELL,NOOP,NOOP,NOOP              ;26-30 (no input)
        DW      NOOP,SWRMOD,SINMD                       ;31-33
;
NOOP:   RET
;
; ==== 1: Open workstation ===================================================
;
OPEN:   LHLD    DMDESC          ;this driver's mode
        CALL    CZINIT          ;board, palette, drawing defaults; clear to 0
        CALL    PALINI          ;GSX's default color table
        MVI     A,0FFH          ;the overlay (the graphic cursor) in white
        MOV     B,A
        MOV     C,A
        MOV     E,A
        CALL    CZOPAL
        CALL    CZOCLS
        CALL    CZOVON
        CALL    ESCINI          ;alpha cursor, no graphic cursor
        XRA     A
        STA     PSTATE          ;the pattern RAM: unknown
        LXI     H,ONE           ;writing mode 1, replace, clipped
        SHLD    INTIN0
        LHLD    INTIN
        PUSH    H
        LXI     H,INTIN0
        SHLD    INTIN
        CALL    SWRMOD
        POP     H
        SHLD    INTIN
        CALL    ATRINI          ;the attributes from intin(2)-(10)
        LHLD    INTOUT          ;intout(1)-(45): what this device can do
        XCHG
        LXI     H,OWTAB
        LXI     B,90
        CALL    COPY
        LHLD    INTOUT          ;intout(1), (2): the largest X and Y
        XCHG
        LHLD    CZXMAX
        CALL    STDE
        LHLD    CZYMAX
        CALL    STDE
        LHLD    PTSOUT          ;ptsout(1)-(12): size limits
        XCHG
        LXI     H,OWPTS
        LXI     B,24
        CALL    COPY
        LXI     H,6
        CALL    SETC3
        LXI     H,45
        JMP     SETC5
;
; ==== 2: Close workstation; 3: Clear workstation =================================
;
CLOSE:
CLEAR:  CALL    GCOFF           ;the graphic cursor goes with the picture
        CALL    CZOCLS
        XRA     A               ;the background, color 0
        JMP     CZCLS
;
; ==== 4: Update workstation =================================================
;
UPDATE: JMP     CZWAIT          ;let the ACRTC finish what it was given
;
; ==== 32: Set writing mode ==================================================
;
; 1 replace, 2 transparent, 3 XOR, 4 erase (anything else: replace). Erase
; draws in color 0, the background (DRWCOL), with transparent gaps. The
; area mode stays AMCLIP: everything is clipped to the screen.
SWRMOD: MVI     A,1
        CALL    INW
        MOV     A,H
        ORA     A
        JNZ     SWREP
        MOV     A,L
        ORA     A
        JZ      SWREP
        CPI     5
        JC      SW1
SWREP:  MVI     A,1             ;out of range: replace
SW1:    STA     WMODE
        LXI     H,WMBITS-1      ;this mode's drawing-mode bits
        MOV     E,A
        MVI     D,0
        DAD     D
        MOV     A,M
        ORI     AMCLIP
        STA     CZDM
        LDA     WMODE
        JMP     RET1A
;
WMBITS: DB      OMREP+CMSEL     ;1 replace: gaps drawn in color 0
        DB      OMREP+CMCL1     ;2 transparent: gaps left alone
        DB      OMEOR+CMCL1     ;3 XOR
        DB      OMREP+CMCL1     ;4 erase: color 0 (DRWCOL), gaps left alone
;
; ==== Helpers ===============================================================
;
; Set the drawing color to A, or to the background in erase mode.
DRWCOL: MOV     B,A
        LDA     WMODE
        CPI     4
        MOV     A,B
        JNZ     CZCOL
        XRA     A
        JMP     CZCOL
;
; NZ unless the writing mode is XOR: whether a filled shape gets its
; perimeter drawn (XOR would undo the edge the fill already drew).
NOXOR:  LDA     WMODE
        CPI     3
        RET
;
; A = the color index in the word at HL, 0-255: out of range gives 255,
; the largest (GSX spec).
LDCOL:  MOV     A,M
        INX     H
        MOV     B,M
        INR     B
        DCR     B
        RZ
        MVI     A,255
        RET
;
; HL = the x, DE = the y of the point at HL; LDPTR = the next point.
LDXY:   MOV     E,M
        INX     H
        MOV     D,M
        INX     H
        PUSH    D
        MOV     E,M
        INX     H
        MOV     D,M
        INX     H
        SHLD    LDPTR
        POP     H
        RET
;
; HL = word A (1-based) of contrl, intin or ptsin. Keeps BC, DE.
CTLW:   PUSH    D
        LHLD    CONTRL
        JMP     ARRW
INW:    PUSH    D
        LHLD    INTIN
        JMP     ARRW
PTW:    PUSH    D
        LHLD    PTSIN
ARRW:   DCR     A
        ADD     A
        MOV     E,A
        MVI     D,0
        DAD     D
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        POP     D
        RET
;
; intout(A) = HL; ptsout(A) = HL. Keeps BC.
OUTW:   PUSH    H
        LHLD    INTOUT
        JMP     ARRS
PTOUT:  PUSH    H
        LHLD    PTSOUT
ARRS:   DCR     A
        ADD     A
        MOV     E,A
        MVI     D,0
        DAD     D
        POP     D
        MOV     M,E
        INX     H
        MOV     M,D
        RET
;
; Return A as intout(1), the value selected; RETHL returns HL.
RET1A:  MOV     L,A
        MVI     H,0
RETHL:  MVI     A,1
        CALL    OUTW
        LXI     H,1
        JMP     SETC5
;
; contrl(3) = HL; contrl(5) = HL.
SETC3:  XCHG
        LHLD    CONTRL
        INX     H
        INX     H
        INX     H
        INX     H
        MOV     M,E
        INX     H
        MOV     M,D
        RET
SETC5:  XCHG
        LHLD    CONTRL
        LXI     B,8
        DAD     B
        MOV     M,E
        INX     H
        MOV     M,D
        RET
;
; Store HL at DE as a word; DE = the next word.
STDE:   XCHG
        MOV     M,E
        INX     H
        MOV     M,D
        INX     H
        XCHG
        RET
;
; Copy BC bytes from HL to DE.
COPY:   MOV     A,M
        STAX    D
        INX     H
        INX     D
        DCX     B
        MOV     A,B
        ORA     C
        JNZ     COPY
        RET
;
ONE:    DW      1
;
; ==== Open workstation's answers =============================================
;
OWTAB:  DW      0,0             ;1-2 largest X, Y (filled in from czgfx)
        DW      1               ;3 a CRT: not a precisely scaled image
        DW      300,300         ;4-5 pixel width, height in um: square
        DW      16              ;6 character heights (per font: 1-16 times)
        DW      5               ;7 linetypes
        DW      1               ;8 line widths
        DW      5               ;9 marker types
        DW      8               ;10 marker sizes
        DW      2               ;11 fonts
        DW      6               ;12 patterns
        DW      6               ;13 hatch styles
        DW      256             ;14 colors shown at once
        DW      4               ;15 GDPs:
        DW      1,2,3,4         ;16-25 bar, arc, pie slice, circle
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH,0FFFFH,0FFFFH
        DW      3,0,3,3         ;26-35 their attributes: fill, line, fill, fill
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH,0FFFFH,0FFFFH
        DW      1               ;36 color
        DW      1               ;37 text rotation
        DW      1               ;38 fill area
        DW      1               ;39 cell array read-back
        DW      0               ;40 colors available: 0 = over 32767
        DW      0,0,0,0         ;41-44 no locator, valuator, choice, string
        DW      0               ;45 output only
;
OWPTS:  DW      0,7             ;min character height (CZF8 x1)
        DW      0,128           ;max character height (CZF11 x16)
        DW      1,0             ;min line width
        DW      1,0             ;max line width
        DW      0,5             ;min marker height
        DW      0,49            ;max marker height
;
        DSEG
;
CONTRL: DS      2               ;the parameter block's five arrays
INTIN:  DS      2
PTSIN:  DS      2
INTOUT: DS      2
PTSOUT: DS      2
;
WMODE:  DS      1               ;writing mode, 1-4
LCOL:   DS      1               ;polyline color index
LTYPE:  DS      1               ;polyline linetype, 1-5
MCOL:   DS      1               ;polymarker color index
MTYPE:  DS      1               ;polymarker type, 1-5
MHGT:   DS      2               ;polymarker height
TCOL:   DS      1               ;text color index
TFONT:  DS      1               ;text font, 1-2
TSCAL:  DS      1               ;text scale, 1-16
TDIR:   DS      1               ;text direction, 0-7 (45 degree steps)
TREQH:  DS      2               ;the character height last asked for
FCOL:   DS      1               ;fill color index
FSTYL:  DS      1               ;fill interior style, 0-3
FINDX:  DS      1               ;fill style index, 1-6
PSTATE: DS      1               ;what the pattern RAM holds (DDATTR USEPAT)
;
OLDSP:  DS      2               ;GDOS's stack pointer
LDPTR:  DS      2
INTIN0: DS      2
;
        DS      192             ;the driver's stack
STACK:
;
        END
