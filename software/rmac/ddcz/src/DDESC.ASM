; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
; DDESC.ASM -- CADzilla GSX driver: escape (opcode 5).
;
; The alpha (text) functions, 1-15, go to the CP/M console: CADzilla's
; display has no text mode, and the console is a separate terminal, taken
; to understand ANSI (VT100) sequences. Output goes straight to the BIOS's
; CONOUT, as GSX drivers do (the GDOS is in the middle of a BDOS call).
; The driver can't ask the terminal where its cursor is, so it keeps
; count itself (24 x 80). Enter and exit graphics mode do nothing: the
; graphics are always on their own screen.
;
; The graphic cursor, 18 and 19, is a crosshair XORed onto the overlay
; plane, so it never touches the picture.
;
        PUBLIC  ESCAPE,ESCINI,GCOFF,GCAT,COUT
;
        EXTRN   CONTRL,INTIN
        EXTRN   CTLW,INW,PTW,OUTW,SETC5,USEPAT
        EXTRN   CZOVL,CZFRM,CZCOL,CZMOVE,CZLINE,CZDM
;
ESC     EQU     1BH
NROW    EQU     24
NCOL    EQU     80
NESC    EQU     19
OMEOR   EQU     3
AMCLIP  EQU     40H
OVSET   EQU     0FFH
GCARM   EQU     8               ;the crosshair's arms, in pixels
;
        CSEG
;
ESCINI: MVI     A,1             ;open workstation: home, no graphic cursor
        STA     CROW
        STA     CCOL
        XRA     A
        STA     GCON
        RET
;
ESCAPE: MVI     A,6             ;the function, contrl(6)
        CALL    CTLW
        MOV     A,H
        ORA     A
        RNZ
        MOV     A,L
        DCR     A
        CPI     NESC
        RNC                     ;0 or over 19: nothing
        ADD     A
        MOV     E,A
        MVI     D,0
        LXI     H,ESCTAB
        DAD     D
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        PCHL
;
ESCTAB: DW      EINQ,ENOP,ENOP,EUP,EDOWN                ;1-5
        DW      ERIGHT,ELEFT,EHOME,EEOS,EEOL            ;6-10
        DW      EADDR,ETEXT,ERVON,ERVOFF,EQPOS          ;11-15
        DW      ETAB,ENOP,EGCUR,GCOFF                   ;16-19
;
ENOP:   RET
;
; 1: inquire addressable character cells: intout(1) rows, (2) columns
EINQ:   LXI     H,NROW
        MVI     A,1
        CALL    OUTW
        LXI     H,NCOL
RET2:   MVI     A,2
        CALL    OUTW
        LXI     H,2
        JMP     SETC5
;
; 15: inquire current cursor address: intout(1) row, (2) column
EQPOS:  LDA     CROW
        MOV     L,A
        MVI     H,0
        MVI     A,1
        CALL    OUTW
        LDA     CCOL
        MOV     L,A
        MVI     H,0
        JMP     RET2
;
; 16: inquire tablet status: none
ETAB:   LXI     H,0
        MVI     A,1
        CALL    OUTW
        LXI     H,1
        JMP     SETC5
;
; 4-7: the cursor one step, stopping at the edges
EUP:    LXI     H,CROW
        MOV     A,M
        CPI     2
        RC
        DCR     M
        MVI     A,'A'
        JMP     CSI
EDOWN:  LXI     H,CROW
        MOV     A,M
        CPI     NROW
        RNC
        INR     M
        MVI     A,'B'
        JMP     CSI
ERIGHT: LXI     H,CCOL
        MOV     A,M
        CPI     NCOL
        RNC
        INR     M
        MVI     A,'C'
        JMP     CSI
ELEFT:  LXI     H,CCOL
        MOV     A,M
        CPI     2
        RC
        DCR     M
        MVI     A,'D'
        JMP     CSI
;
; 8: home; 9: erase to end of screen; 10: to end of line
EHOME:  MVI     A,1
        STA     CROW
        STA     CCOL
        MVI     A,'H'
        JMP     CSI
EEOS:   MVI     A,'J'
        JMP     CSI
EEOL:   MVI     A,'K'
        JMP     CSI
;
; 13, 14: reverse video on, off
ERVON:  MVI     A,'7'
        JMP     SGR
ERVOFF: MVI     A,'0'
SGR:    PUSH    PSW
        CALL    CSI0
        POP     PSW
        CALL    COUT
        MVI     A,'m'
        JMP     COUT
;
; 11: direct cursor address: intin(1) row, (2) column (beyond the screen:
; its edge)
EADDR:  MVI     A,1
        CALL    INW
        MVI     B,NROW
        CALL    CLAMP
        STA     CROW
        MVI     A,2
        CALL    INW
        MVI     B,NCOL
        CALL    CLAMP
        STA     CCOL
        CALL    CSI0            ;ESC [ row ; col H
        LDA     CROW
        CALL    CDEC
        MVI     A,';'
        CALL    COUT
        LDA     CCOL
        CALL    CDEC
        MVI     A,'H'
        JMP     COUT
;
; CLAMP -- A = HL kept to 1..B
CLAMP:  MOV     A,H
        ORA     A
        JM      CL1
        JNZ     CL2
        MOV     A,L
        ORA     A
        JZ      CL1
        CMP     B
        RC
        RZ
CL2:    MOV     A,B
        RET
CL1:    MVI     A,1
        RET
;
; 12: output cursor addressable text: contrl(4) characters in intin
ETEXT:  MVI     A,4
        CALL    CTLW
        MOV     B,H
        MOV     C,L
        LHLD    INTIN
ET1:    MOV     A,B
        ORA     C
        RZ
        MOV     A,M
        INX     H
        INX     H
        PUSH    B
        PUSH    H
        CALL    COUT
        LXI     H,CCOL          ;the column, kept to the screen
        MOV     A,M
        CPI     NCOL
        JNC     ET2
        INR     M
ET2:    POP     H
        POP     B
        DCX     B
        JMP     ET1
;
; ==== The console ===========================================================
;
; CSI -- ESC [ then the character A
CSI:    PUSH    PSW
        CALL    CSI0
        POP     PSW
        JMP     COUT
CSI0:   MVI     A,ESC
        CALL    COUT
        MVI     A,'['
        JMP     COUT
;
; CDEC -- A (1-99) in decimal
CDEC:   MVI     B,'0'-1
CD1:    INR     B
        SUI     10
        JNC     CD1
        ADI     10+'0'
        PUSH    PSW
        MOV     A,B
        CPI     '0'
        CNZ     COUT
        POP     PSW
        JMP     COUT
;
; COUT -- the character A to the console, by the BIOS's CONOUT (its jump
; is 9 bytes past the warm boot entry, whose address is at 0001H). Keeps
; BC, DE, HL.
COUT:   PUSH    B
        PUSH    D
        PUSH    H
        MOV     C,A
        LHLD    1
        LXI     D,9
        DAD     D
        CALL    CALLHL
        POP     H
        POP     D
        POP     B
        RET
CALLHL: PCHL
;
; ==== The graphic cursor ====================================================
;
; 18: place it at ptsin(1), ptsin(2) (moving it if it is up already)
EGCUR:  MVI     A,2
        CALL    PTW
        XCHG
        MVI     A,1
        CALL    PTW
;
; GCAT -- the graphic cursor at X = HL, Y = DE (moved if it is up already)
GCAT:   PUSH    D
        PUSH    H
        CALL    GCOFF
        POP     H
        SHLD    GCX
        POP     H
        SHLD    GCY
        MVI     A,1
        STA     GCON
        JMP     GCXOR
;
; 19 (and clear and close workstation): take it down, if it is up
GCOFF:  LDA     GCON
        ORA     A
        RZ
        XRA     A
        STA     GCON
;
; GCXOR -- XOR the crosshair at GCX, GCY on the overlay: a horizontal arm
; through the centre, then the vertical one in two halves that stop short
; of it, so no pixel is drawn twice.
GCXOR:  LDA     CZDM
        STA     GCDM
        CALL    CZOVL
        MVI     A,OMEOR+AMCLIP
        STA     CZDM
        MVI     A,1             ;solid
        CALL    USEPAT
        MVI     A,OVSET
        CALL    CZCOL
        LHLD    GCY
        XCHG
        LHLD    GCX             ;X - arm .. X + arm
        LXI     B,0-GCARM
        DAD     B
        CALL    CZMOVE
        LXI     B,2*GCARM+1
        DAD     B
        CALL    CZLINE
        LHLD    GCY             ;Y + arm down to Y + 1
        LXI     B,GCARM
        DAD     B
        XCHG
        LHLD    GCX
        CALL    CZMOVE
        LHLD    GCY
        XCHG
        LHLD    GCX
        CALL    CZLINE
        LHLD    GCY             ;Y - arm up to Y - 1
        LXI     B,0-GCARM
        DAD     B
        XCHG
        LHLD    GCX
        CALL    CZMOVE
        LHLD    GCY
        XCHG
        LHLD    GCX
        CALL    CZLINE
        CALL    CZFRM
        LDA     GCDM
        STA     CZDM
        RET
;
        DSEG
CROW:   DS      1               ;the alpha cursor, 1-24
CCOL:   DS      1               ;1-80
GCON:   DS      1               ;1: the graphic cursor is up
GCDM:   DS      1
GCX:    DS      2
GCY:    DS      2
;
        END
