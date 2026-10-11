;
; DDINP.ASM -- CADzilla GSX driver: input (opcodes 28-31, 33), all from
; the CP/M console's keyboard, read through the BIOS (CONST, CONIN) as the
; rest of the driver writes through CONOUT.
;
; Keys: an ANSI terminal's arrows (ESC [ A..D, or ESC O A..D) move 8
; pixels, or 10 on a valuator; the WordStar keys ^E ^X ^S ^D move 1. Any
; other key ends a request and is returned as its terminator. (An ESC that
; isn't an arrow takes the next key with it: press ESC twice.)
;
;   locator   request: the graphic cursor (DDESC's overlay crosshair)
;             from ptsin(1), (2), moved by the keys until a terminator.
;             Sample: no cursor; a move returns the new point, a
;             terminator returns the key, no key returns nothing.
;   valuator  intin(2) is the start; up/down change it.
;   choice    the keys 1-9.
;   string    up to intin(2) keys, to RETURN; in request mode echoed on the
;             screen at ptsin(1), (2) in the text attributes if intin(3).
;
        PUBLIC  LOCAT,VALUAT,CHOICE,STRING,SINMD,INPINI
;
        EXTRN   CONTRL,INTIN,INTOUT
        EXTRN   CTLW,INW,PTW,OUTW,PTOUT,SETC3,SETC5,RET1A,RETHL
        EXTRN   GCAT,GCOFF,TXECHO
        EXTRN   CZXMAX,CZYMAX
;
ESC     EQU     1BH
CR      EQU     0DH
BS      EQU     08H
DEL     EQU     7FH
;
        CSEG
;
; Open workstation: every class in request mode, the locator mid-screen
INPINI: LXI     H,0101H
        SHLD    IMODE
        SHLD    IMODE+2
        LHLD    CZXMAX
        CALL    HALF
        SHLD    LX
        LHLD    CZYMAX
        CALL    HALF
        SHLD    LY
        LXI     H,0
        SHLD    VAL
        RET
HALF:   ORA     A
        MOV     A,H
        RAR
        MOV     H,A
        MOV     A,L
        RAR
        MOV     L,A
        RET
;
; ==== 33: Set input mode ======================================================
;
; intin(1) = the class (1 locator, 2 valuator, 3 choice, 4 string), intin(2)
; = 1 request or 2 sample. Returns the mode set.
SINMD:  MVI     A,1
        CALL    INW
        MOV     A,H
        ORA     A
        RNZ
        MOV     A,L
        DCR     A
        CPI     4
        RNC
        MOV     E,A
        MVI     D,0
        MVI     A,2
        CALL    INW
        MOV     A,L
        CPI     2
        JZ      SI1
        MVI     A,1
SI1:    LXI     H,IMODE
        DAD     D
        MOV     M,A
        JMP     RET1A
;
; ==== 28: Input locator =======================================================
;
LOCAT:  MVI     A,2             ;ptsin(1), (2): where to start, if given
        CALL    CTLW
        MOV     A,H
        ORA     L
        JZ      LC0
        MVI     A,1
        CALL    PTW
        SHLD    LX
        MVI     A,2
        CALL    PTW
        SHLD    LY
        LXI     B,0             ;(kept on the screen)
        CALL    KMOVE
LC0:    LDA     IMODE
        CPI     2
        JZ      LCS
LCR:    LHLD    LY              ;request: the cursor, moved by the keys
        XCHG
        LHLD    LX
        CALL    GCAT
        CALL    KEY
        MOV     D,A
        MOV     A,B
        ORA     A
        JZ      LCR2
        CALL    KMOVE
        JMP     LCR
LCR2:   PUSH    D
        CALL    GCOFF
        POP     PSW
        CALL    RETKEY          ;intout(1) = the terminator
LCPT:   LHLD    LX              ;ptsout(1), (2) = the point
        MVI     A,1
        CALL    PTOUT
        LHLD    LY
        MVI     A,2
        CALL    PTOUT
        LXI     H,1
        JMP     SETC3
LCS:    CALL    KSAMP           ;sample: nothing, a move or a terminator
        RZ
        MOV     D,A
        MOV     A,B
        ORA     A
        MOV     A,D
        JZ      RETKEY
        CALL    KMOVE
        JMP     LCPT
;
; RETKEY -- intout(1) = the key A, contrl(5) = 1
RETKEY: MOV     L,A
        MVI     H,0
        JMP     RETHL
;
; ==== 29: Input valuator ======================================================
;
VALUAT: LDA     IMODE+1
        CPI     2
        JZ      VLS
        MVI     A,2             ;request: from intin(2)
        CALL    INW
        SHLD    VAL
VLR:    CALL    KEY
        MOV     D,A
        MOV     A,B
        ORA     A
        JZ      VLR2
        CALL    VMOVE
        JMP     VLR
VLR2:   MOV     A,D
VLTRM:  MOV     L,A             ;intout(2) = the terminator
        MVI     H,0
        MVI     A,2
        CALL    OUTW
        CALL    VOUT
        LXI     H,2
        JMP     SETC5
VLS:    CALL    KSAMP           ;sample
        RZ
        MOV     D,A
        MOV     A,B
        ORA     A
        MOV     A,D
        JZ      VLTRM
        CALL    VMOVE
VOUT:   LHLD    VAL             ;intout(1) = the value
        JMP     RETHL
;
; VMOVE -- up adds the step, down takes it off; an arrow's step is 10
VMOVE:  MOV     A,C
        CPI     8
        LXI     D,1
        JNZ     VM1
        LXI     D,10
VM1:    MOV     A,B
        CPI     2
        JZ      VM2
        CPI     1
        RNZ                     ;left, right: nothing
        JMP     VM3
VM2:    CALL    NEGDE
VM3:    LHLD    VAL
        DAD     D
        SHLD    VAL
        RET
;
; ==== 30: Input choice =========================================================
;
CHOICE: LDA     IMODE+2
        CPI     2
        JZ      CHS
CHR:    CALL    KGET            ;request: wait for 1-9
        CALL    DIGIT
        JC      CHR
        JMP     RET1A
CHS:    CALL    KREADY          ;sample
        RZ
        CALL    KGET
        MOV     D,A
        CALL    DIGIT
        JNC     RET1A
        MOV     L,D             ;not a choice: intout(2) = the key
        MVI     H,0
        MVI     A,2
        CALL    OUTW
        LXI     H,2
        JMP     SETC5
;
; DIGIT -- A = 1-9 for the keys '1'-'9', NC; else C
DIGIT:  SUI     '1'
        RC
        CPI     9
        CMC
        RC
        INR     A
        RET
;
; ==== 31: Input string =========================================================
;
STRING: MVI     A,2             ;the longest: intin(2), at most 80
        CALL    INW
        MOV     A,H
        ORA     A
        JNZ     ST0
        MOV     A,L
        CPI     81
        JC      ST1
ST0:    MVI     A,80
ST1:    STA     SMAX
        XRA     A
        STA     SECHO
        STA     SCNT
        LDA     IMODE+3
        STA     SSAMP
        CPI     2
        JZ      ST2
        MVI     A,3             ;request: echo if intin(3) (and a point)
        CALL    INW
        MOV     A,H
        ORA     L
        JZ      ST2
        MVI     A,2
        CALL    CTLW
        MOV     A,H
        ORA     L
        JZ      ST2
        MVI     A,1
        CALL    PTW
        SHLD    SX
        MVI     A,2
        CALL    PTW
        SHLD    SY
        MVI     A,1
        STA     SECHO
ST2:    LDA     SMAX            ;full?
        MOV     B,A
        LDA     SCNT
        CMP     B
        JNC     STX
        LDA     SSAMP           ;sample mode: only what's waiting
        CPI     2
        JNZ     ST3
        CALL    KREADY
        JZ      STX
ST3:    CALL    KGET
        CPI     CR
        JZ      STX
        CPI     BS
        JZ      STBS
        CPI     DEL
        JZ      STBS
        MOV     D,A             ;intout(n) = the key
        LDA     SCNT
        INR     A
        STA     SCNT
        MOV     L,D
        MVI     H,0
        PUSH    D
        CALL    OUTW
        POP     D
        LDA     SECHO
        ORA     A
        JZ      ST2
        MOV     A,D             ;echo it, and move on a cell
        CALL    STECHO
        XCHG
        LHLD    SX
        DAD     D
        SHLD    SX
        JMP     ST2
STBS:   LDA     SCNT            ;back a key (and a cell)
        ORA     A
        JZ      ST2
        DCR     A
        STA     SCNT
        LDA     SECHO
        ORA     A
        JZ      ST2
        MVI     A,' '           ;size the cell, step back over it, blank it
        LHLD    SY
        XCHG
        LHLD    SX
        CALL    TXECHO
        CALL    NEGHL
        XCHG
        LHLD    SX
        DAD     D
        SHLD    SX
        MVI     A,' '
        CALL    STECHO
        JMP     ST2
STX:    LDA     SCNT            ;contrl(5) = the length
        MOV     L,A
        MVI     H,0
        JMP     SETC5
STECHO: PUSH    PSW
        LHLD    SY
        XCHG
        LHLD    SX
        POP     PSW
        JMP     TXECHO
;
; ==== The keyboard =============================================================
;
; KREADY -- NZ if a key is waiting (the BIOS's CONST, 3 past the warm boot
; entry); KGET -- wait for it, A = the key, 7 bits (CONIN, 6 past)
KREADY: LXI     D,3
        CALL    BIOS
        ORA     A
        RET
KGET:   LXI     D,6
        CALL    BIOS
        ANI     7FH
        RET
BIOS:   PUSH    B
        LHLD    1
        DAD     D
        LXI     D,BIOSX
        PUSH    D
        PCHL
BIOSX:  POP     B
        RET
;
; KSAMP -- Z if no key is waiting; else KEY's results
KSAMP:  CALL    KREADY
        RZ
        CALL    KEY
        MOV     D,A             ;(NZ, A kept)
        MVI     A,1
        ORA     A
        MOV     A,D
        RET
;
; KEY -- wait for a key: B = 0 and A = the key, or B = a direction (1 up,
; 2 down, 3 left, 4 right) and C = its step (8 for an arrow, 1 for ^E^X^S^D)
KEY:    CALL    KGET
        CPI     ESC
        JZ      KESC
        MVI     C,1
        LXI     H,KTAB1
        JMP     KLOOK
KESC:   CALL    KGET
        CPI     '['
        JZ      KESC2
        CPI     'O'
        JZ      KESC2
        MVI     B,0             ;not an arrow: ESC is the key
        MVI     A,ESC
        RET
KESC2:  CALL    KGET
        MVI     C,8
        LXI     H,KTAB2
KLOOK:  MOV     E,A
        MVI     B,1
KL1:    MOV     A,M
        CMP     E
        JZ      KL2
        INX     H
        INR     B
        MOV     A,B
        CPI     5
        JC      KL1
        MVI     B,0
KL2:    MOV     A,E
        RET
KTAB1:  DB      05H,18H,13H,04H ;^E ^X ^S ^D
KTAB2:  DB      'A','B','D','C' ;up, down, left, right
;
; KMOVE -- move LX, LY C pixels in direction B (0: none), kept on the
; screen
KMOVE:  MOV     E,C
        MVI     D,0
        MOV     A,B
        CPI     2
        JZ      KM1
        CPI     3
        JNZ     KM2
KM1:    CALL    NEGDE
KM2:    MOV     A,B             ;up, down: Y; left, right: X
        CPI     3
        JNC     KM3
        LHLD    LY
        DAD     D
        XCHG
        LHLD    CZYMAX
        CALL    CLAMP
        SHLD    LY
        MOV     A,B             ;B = 0: X too (unmoved: DE = 0 again)
        ORA     A
        RNZ
        LXI     D,0
KM3:    LHLD    LX
        DAD     D
        XCHG
        LHLD    CZXMAX
        CALL    CLAMP
        SHLD    LX
        RET
;
; CLAMP -- HL = DE kept to 0..HL
CLAMP:  MOV     A,D
        ORA     A
        JP      CLP1
        LXI     H,0             ;negative
        RET
CLP1:   MOV     A,L             ;over the top?
        SUB     E
        MOV     A,H
        SBB     D
        RC
        XCHG
        RET
;
NEGDE:  MOV     A,D
        CMA
        MOV     D,A
        MOV     A,E
        CMA
        MOV     E,A
        INX     D
        RET
NEGHL:  MOV     A,H
        CMA
        MOV     H,A
        MOV     A,L
        CMA
        MOV     L,A
        INX     H
        RET
;
        DSEG
IMODE:  DS      4               ;each class: 1 request, 2 sample
LX:     DS      2               ;the locator
LY:     DS      2
VAL:    DS      2               ;the valuator
SMAX:   DS      1               ;string input: the longest
SCNT:   DS      1               ;the keys so far
SECHO:  DS      1               ;1: echo them
SSAMP:  DS      1
SX:     DS      2               ;where the next echo goes
SY:     DS      2
;
        END
