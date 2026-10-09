;
; DDCZ.ASM -- CADzilla GSX-80 screen driver (GIOS): entry, dispatch and
; the output functions. Built with DRI RMAC + LINK-80 into a .PRL, and
; linked with the czgfx library (B:CZGFX.REL) and one mode module (DM1K,
; ...), which says which display mode this copy of the driver drives:
;   A0>SUBMIT DDCZ        (cadzilla-build-rmac skill; see DDCZ.SUB)
;
; GDOS calls the driver's first byte -- DDCZ, so this module links first --
; with DE = the GSX parameter block: the addresses of contrl, intin, ptsin,
; intout and ptsout. Every element is a 16-bit word; the GSX spec numbers
; them from 1, so contrl(1) is the word at contrl+0. Coordinates arrive in
; device units (GDOS has scaled them), origin bottom-left -- czgfx's own
; orientation, so they go to czgfx as they are. The driver returns with
; RET, having set contrl(3) (ptsout vertices) and contrl(5) (intout words).
;
; Phase 0 (spike): open/close/clear/update workstation, polyline, polyline
; color index, writing mode. Every other opcode is accepted and does
; nothing.
;
        EXTRN   DMDESC          ;mode module: DW the czgfx mode descriptor
        EXTRN   CZINIT,CZCLS,CZCOL,CZMOVE,CZLINE,CZDOT
        EXTRN   CZPALS,CZWAIT,CZXMAX,CZYMAX,CZDM
;
NOPS    EQU     33              ;GSX opcodes 1-33
;
; czgfx drawing-mode fields (CZGFX.INC): operation, color and area modes
OMREP   EQU     0               ;P = C
OMEOR   EQU     3               ;P = P XOR C
CMSEL   EQU     00H             ;pattern 1 = CL1, 0 = CL0
CMCL1   EQU     08H             ;pattern 1 = CL1, 0 = left alone
AMMASK  EQU     0E0H            ;the area-mode bits, kept as they are
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
OPTAB:  DW      OPEN,CLOSE,CLEAR,UPDATE,NOOP            ;1-5
        DW      PLINE,NOOP,NOOP,NOOP,NOOP               ;6-10
        DW      NOOP,NOOP,NOOP,NOOP,NOOP                ;11-15
        DW      NOOP,SLCOL,NOOP,NOOP,NOOP               ;16-20
        DW      NOOP,NOOP,NOOP,NOOP,NOOP                ;21-25
        DW      NOOP,NOOP,NOOP,NOOP,NOOP                ;26-30
        DW      NOOP,SWRMOD,NOOP                        ;31-33
;
NOOP:   RET
;
; ==== 1: Open workstation ===================================================
;
OPEN:   LHLD    DMDESC          ;this driver's mode
        CALL    CZINIT          ;board, palette, drawing defaults; clear to 0
        CALL    GSXPAL          ;GSX's default colors
        MVI     A,1             ;writing mode: replace
        STA     WMODE
        LDA     CZDM
        ANI     AMMASK
        ORI     OMREP+CMSEL
        STA     CZDM
        LHLD    INTIN           ;polyline color index: intin(3)
        LXI     D,4
        DAD     D
        CALL    LDCOL
        STA     LCOL
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
; Load GSX's default color table: 0 black, 1 red, 2 green, 3 blue, 4 cyan,
; 5 yellow, 6 magenta, 7 and up white.
GSXPAL: XRA     A
GPLOOP: STA     PALI
        CPI     8
        JNC     GPWHT
        MOV     L,A             ;HL = GPTAB + 3 * index
        MVI     H,0
        MOV     E,L
        MOV     D,H
        DAD     H
        DAD     D
        LXI     D,GPTAB
        DAD     D
        MOV     B,M
        INX     H
        MOV     C,M
        INX     H
        MOV     E,M
        JMP     GPSET
GPWHT:  MVI     B,255
        MVI     C,255
        MVI     E,255
GPSET:  LDA     PALI
        CALL    CZPALS          ;A = index, B/C/E = R/G/B
        LDA     PALI
        INR     A
        JNZ     GPLOOP
        RET
;
GPTAB:  DB      0,0,0, 255,0,0, 0,255,0, 0,0,255
        DB      0,255,255, 255,255,0, 255,0,255, 255,255,255
;
; ==== 2: Close workstation; 3: Clear workstation =================================
;
CLOSE:
CLEAR:  XRA     A               ;the background, color 0
        JMP     CZCLS
;
; ==== 4: Update workstation =================================================
;
UPDATE: JMP     CZWAIT          ;let the ACRTC finish what it was given
;
; ==== 6: Polyline ===========================================================
;
PLINE:  LHLD    CONTRL          ;DE = n, contrl(2)
        INX     H
        INX     H
        MOV     E,M
        INX     H
        MOV     D,M
        MOV     A,D
        ORA     A
        JNZ     PL1
        MOV     A,E
        CPI     2
        RC                      ;a single point is not drawn
PL1:    XCHG
        SHLD    PLCNT
        LDA     LCOL
        CALL    DRWCOL
        LHLD    PTSIN
        CALL    LDXY            ;HL = x, DE = y of the first point
        CALL    CZMOVE
PLLOOP: LHLD    PLCNT
        DCX     H
        SHLD    PLCNT
        MOV     A,H
        ORA     L
        JZ      PLEND
        LHLD    PTR
        CALL    LDXY
        CALL    CZLINE          ;keeps HL, DE
        SHLD    LASTX
        XCHG
        SHLD    LASTY
        JMP     PLLOOP
PLEND:  LHLD    LASTY           ;the ACRTC doesn't draw a line's end point
        XCHG
        LHLD    LASTX
        JMP     CZDOT
;
; ==== 17: Set polyline color index ==========================================
;
SLCOL:  LHLD    INTIN
        CALL    LDCOL
        STA     LCOL
;
; Return A as intout(1), the value selected.
RET1A:  LHLD    INTOUT
        MOV     M,A
        INX     H
        MVI     M,0
        LXI     H,1
        JMP     SETC5
;
; ==== 32: Set writing mode ==================================================
;
; 1 replace, 2 transparent, 3 XOR, 4 erase (anything else: replace). Erase
; draws in color 0, the background (DRWCOL), with transparent gaps.
SWRMOD: LHLD    INTIN
        MOV     A,M
        INX     H
        ORA     M               ;intin(1) = 0: replace
        JZ      SWREP
        MOV     A,M
        ORA     A
        JNZ     SWREP           ;over 255: replace
        DCX     H
        MOV     A,M
        CPI     5
        JNC     SWREP
        STA     WMODE
        LXI     H,WMBITS-1      ;A = this mode's drawing-mode bits
        MOV     E,A
        MVI     D,0
        DAD     D
        MOV     B,M
        LDA     CZDM
        ANI     AMMASK
        ORA     B
        STA     CZDM
        LDA     WMODE
        JMP     RET1A
SWREP:  LXI     H,1             ;out of range: replace
        SHLD    TMPW
        LXI     H,TMPW          ;go round again with intin = TMPW
        SHLD    INTIN
        JMP     SWRMOD
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
; HL = the x, DE = the y of the point at HL; PTR = the next point.
LDXY:   MOV     E,M
        INX     H
        MOV     D,M
        INX     H
        PUSH    D
        MOV     E,M
        INX     H
        MOV     D,M
        INX     H
        SHLD    PTR
        POP     H
        RET
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
; ==== Open workstation's answers =============================================
;
OWTAB:  DW      0,0             ;1-2 largest X, Y (filled in from czgfx)
        DW      1               ;3 a CRT: not a precisely scaled image
        DW      300,300         ;4-5 pixel width, height in um: square
        DW      16              ;6 character heights
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
        DW      0               ;39 no cell array read-back
        DW      0               ;40 colors available: 0 = over 32767
        DW      0,0,0,0         ;41-44 no locator, valuator, choice, string
        DW      0               ;45 output only
;
OWPTS:  DW      0,7             ;min character height
        DW      0,112           ;max character height
        DW      1,0             ;min line width
        DW      1,0             ;max line width
        DW      0,5             ;min marker height
        DW      0,120           ;max marker height
;
        DSEG
;
CONTRL: DS      2               ;the parameter block's five arrays
INTIN:  DS      2
PTSIN:  DS      2
INTOUT: DS      2
PTSOUT: DS      2
;
OLDSP:  DS      2               ;GDOS's stack pointer
LCOL:   DS      1               ;polyline color index
WMODE:  DS      1               ;writing mode, 1-4
PALI:   DS      1
PLCNT:  DS      2
PTR:    DS      2
LASTX:  DS      2
LASTY:  DS      2
TMPW:   DS      2
;
        DS      256             ;the driver's stack
STACK:
;
        END
