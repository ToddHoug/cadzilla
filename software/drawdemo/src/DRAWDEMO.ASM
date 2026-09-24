;
; DRAWDEMO.ASM -- CADzilla graphics drawing command demo
;
; Steps through every graphic drawing command the altairsim HD63484
; model executes, one screen per command. Each screen is described on
; the console; press any key for the next one, ESC (or ^C) to quit.
;
;    1  DOT    single pixels (with AMOVE and RMOVE placing them)
;    2  ALINE  absolute lines
;    3  RLINE  relative lines
;    4  ARCT   absolute rectangles
;    5  RRCT   relative rectangles
;    6  APLL   absolute polylines
;    7  RPLL   relative polylines
;    8  APLG   absolute polygons
;    9  RPLG   relative polygons
;   10  AFRCT  absolute filled rectangles
;   11  RFRCT  relative filled rectangles
;
; Not shown: CRCL, ELPS, the arcs, PAINT, PTN, AGCPY and RGCPY -- the
; model recognizes them but does not execute them (it sets CER).
;
; Board setup (MODE register, ACRTC registers, Bt453 palette, drawing
; parameters) is the same as software/firstdraw: 640x480, 8 bpp, single
; access, origin at the bottom-left pixel, so X runs 0..639 left to
; right and Y runs 0..479 BOTTOM to TOP.
;
        ORG     0100H
;
BDOS    EQU     0005H
CONDIO  EQU     6               ;direct console I/O
PSTRING EQU     9
CR      EQU     0DH
LF      EQU     0AH
ESC     EQU     1BH
CTLC    EQU     03H
;
; ---- board I/O map: one 8-port block, base set by SW1-1..SW1-5 ----
;
CZBASE  EQU     70H
ACRSR   EQU     CZBASE+0        ;ACRTC RS=0: address reg (W) / status (R)
MODEREG EQU     CZBASE+1        ;board MODE register (write only)
ACRDAT  EQU     CZBASE+2        ;ACRTC RS=1: control reg data / FIFO
DACADR  EQU     CZBASE+4        ;Bt453 address register
DACPAL  EQU     CZBASE+5        ;Bt453 color palette RAM (R,G,B)
;
; ---- MODE register: HSPOL(0) VSPOL(1) AMODE(2) OLEN(3) ----
; VESA 640x480@60 uses negative H and V sync; single access mode.
;
MODEVAL EQU     03H
;
; ---- ACRTC status register bits ----
;
SRWFE   EQU     01H             ;write FIFO empty
SRWFR   EQU     02H             ;write FIFO ready (not full)
SRCED   EQU     20H             ;command end
SRCER   EQU     80H             ;command error
;
; ---- ACRTC command high bytes (AREA=0, COL=00, OPM=replace) ----
;
OPMOVE  EQU     80H             ;AMOVE  X,Y
OPRMOV  EQU     84H             ;RMOVE  dX,dY
OPLINE  EQU     88H             ;ALINE  X,Y (end point not drawn)
OPRLIN  EQU     8CH             ;RLINE  dX,dY (end point not drawn)
OPRECT  EQU     90H             ;ARCT   X,Y (CP unchanged)
OPRRCT  EQU     94H             ;RRCT   dX,dY (CP unchanged)
OPAPLL  EQU     98H             ;APLL   n, X1,Y1 .. Xn,Yn (CP = end)
OPRPLL  EQU     9CH             ;RPLL   n, dX1,dY1 .. (each from the last)
OPAPLG  EQU     0A0H            ;APLG   n, X1,Y1 .. (closes on CP)
OPRPLG  EQU     0A4H            ;RPLG   n, dX1,dY1 .. (closes on CP)
OPFRCT  EQU     0C0H            ;AFRCT  X,Y (CP.Y = one past far edge)
OPRFRC  EQU     0C4H            ;RFRCT  dX,dY (likewise)
CMDDOT  EQU     0CC00H          ;DOT    (whole word, no parameters)
;
; ---- palette: index = hue*32 + level (level 0..31) ----
;
ORANGE  EQU     0
BLUE    EQU     32
GREEN   EQU     64
CYAN    EQU     96
RED     EQU     128
MAGENTA EQU     160
YELLOW  EQU     192
WHITE   EQU     224
BRIGHT  EQU     31              ;full brightness level
;
; ---- screen geometry ----
;
XMAX    EQU     639
YMAX    EQU     479
;
;
START:  LXI     H,0             ;keep CCP's stack, run on our own
        DAD     SP
        SHLD    OLDSP
        LXI     SP,STACK
;
        LXI     D,MSGHI
        CALL    PRINT
;
        MVI     A,MODEVAL       ;board glue: sync polarity, access mode
        OUT     MODEREG
        CALL    REGINIT         ;ACRTC control registers, display started
        CALL    PALINIT         ;Bt453 color palette
;
        XRA     A               ;AR = r00: FIFO entry from here on
        OUT     ACRSR
        LXI     H,DPINIT        ;drawing parameters and origin
        LXI     B,(DPEND-DPINIT)/2
        CALL    SENDBLK
;
; Screen loop: SCRTAB holds (message, routine) pairs, 0 ends it.
;
        LXI     H,SCRTAB
NEXT:   CALL    LDW             ;DE = screen description
        MOV     A,D
        ORA     E
        JZ      FINISH
        PUSH    D
        CALL    LDW             ;DE = drawing routine
        SHLD    SCRPTR
        XCHG
        SHLD    ROUTN
        POP     D
        CALL    PRINT
        CALL    CLS
        LXI     H,DRAWN         ;call the routine
        PUSH    H
        LHLD    ROUTN
        PCHL
DRAWN:  CALL    WAITDN          ;let the ACRTC finish drawing
        ANI     SRCER
        JZ      DRAWOK
        LXI     D,MSGER
        CALL    PRINT
DRAWOK: LXI     D,MSGKEY
        CALL    PRINT
        CALL    GETKEY
        PUSH    PSW
        LXI     D,MSGNL
        CALL    PRINT
        POP     PSW
        CPI     ESC
        JZ      FINISH
        CPI     CTLC
        JZ      FINISH
        LHLD    SCRPTR
        JMP     NEXT
;
FINISH: LXI     D,MSGEND
        CALL    PRINT
        LHLD    OLDSP
        SPHL
        RET
;
SCRTAB: DW      MSG1,DEMDOT
        DW      MSG2,DEMALN
        DW      MSG3,DEMRLN
        DW      MSG4,DEMARC
        DW      MSG5,DEMRRC
        DW      MSG6,DEMAPL
        DW      MSG7,DEMRPL
        DW      MSG8,DEMAPG
        DW      MSG9,DEMRPG
        DW      MSG10,DEMAFR
        DW      MSG11,DEMRFR
        DW      0
;
;
; ================= console =================
;
; PRINT -- print the '$'-terminated string at DE
;
PRINT:  MVI     C,PSTRING
        JMP     BDOS
;
; GETKEY -- wait for a key (no echo). Returns A = character.
;
GETKEY: MVI     C,CONDIO
        MVI     E,0FFH
        CALL    BDOS
        ORA     A
        JZ      GETKEY
        RET
;
;
; ================= ACRTC low-level access =================
;
; WRREG -- write a 16-bit ACRTC control register (8-bit bus mode).
; B = register address (even), HL = value. Even AR takes the high
; byte, odd AR the low byte. AR is set explicitly for both bytes, so
; this works for r00-r7F (no auto-increment) and r80-rFF alike.
;
WRREG:  MOV     A,B
        OUT     ACRSR
        MOV     A,H
        OUT     ACRDAT
        MOV     A,B
        INR     A
        OUT     ACRSR
        MOV     A,L
        OUT     ACRDAT
        RET
;
; PUTW -- write the word in HL to the write FIFO, high byte first.
; AR must already be r00. Waits for WFR. Uses A only.
;
PUTW:   IN      ACRSR
        ANI     SRWFR
        JZ      PUTW
        MOV     A,H
        OUT     ACRDAT
        MOV     A,L
        OUT     ACRDAT
        RET
;
; LDW -- DE = word at (HL), HL += 2
;
LDW:    MOV     E,M
        INX     H
        MOV     D,M
        INX     H
        RET
;
; SENDBLK -- send BC words (BC > 0) from table at HL to the FIFO
;
SENDBLK:
        CALL    LDW
        XCHG
        CALL    PUTW
        XCHG
        DCX     B
        MOV     A,B
        ORA     C
        JNZ     SENDBLK
        RET
;
; WAITDN -- wait until the write FIFO is empty and the last command
; has ended. Returns A = status register.
;
WAITDN: IN      ACRSR
        MOV     B,A
        ANI     SRWFE
        JZ      WAITDN
        MOV     A,B
        ANI     SRCED
        JZ      WAITDN
        MOV     A,B
        RET
;
;
; ================= drawing helpers =================
;
; CLS -- clear the whole base screen to palette index 0
;
CLS:    LXI     H,CLSTAB
        LXI     B,(CLSEND-CLSTAB)/2
        JMP     SENDBLK
;
CLSTAB: DW      080CH,4000H     ;RWP: base screen, address 0 (top raster)
        DW      080DH,0000H
        DW      5800H,0000H,319,0-479 ;CLR 320 words x 480 rasters to 0
CLSEND:
;
; SETCOL -- set drawing color to palette index A (WPR CL1). The
; pattern RAM is all ones, so COL=00 always draws with CL1. At 8 bpp
; the index is replicated into both bytes of the color register.
; Preserves BC, DE, HL.
;
SETCOL: PUSH    H
        PUSH    PSW
        LXI     H,0801H         ;WPR CL1
        CALL    PUTW
        POP     PSW
        MOV     H,A
        MOV     L,A
        CALL    PUTW
        POP     H
        RET
;
; XYCMD -- send graphic command (A = command high byte) with
; parameters X = HL, Y = DE. Preserves BC, DE, HL.
;
XYCMD:  PUSH    H
        MOV     H,A
        MVI     L,0
        CALL    PUTW
        POP     H
        CALL    PUTW
        XCHG
        CALL    PUTW
        XCHG
        RET
;
; PLYCMD -- send polyline/polygon command (A = command high byte)
; with its parameters from the table at HL: DW n, then n X,Y pairs
; (n > 0). Returns HL past the table.
;
PLYCMD: PUSH    H
        MOV     H,A
        MVI     L,0
        CALL    PUTW
        POP     H
        CALL    LDW             ;DE = n
        XCHG
        CALL    PUTW
        XCHG
        MOV     A,E             ;BC = 2n words of points
        ADD     A
        MOV     C,A
        MOV     A,D
        ADC     A
        MOV     B,A
        JMP     SENDBLK
;
; DRAWPL -- draw a list of polylines/polygons at HL with command A.
; Entries: DB color / DW X0,Y0 (AMOVE here first) / DW n, points.
; DB 0 ends the list.
;
DRAWPL: STA     PLOP
DPLOOP: MOV     A,M
        ORA     A
        RZ
        INX     H
        CALL    SETCOL
        CALL    LDW             ;DE = X0
        PUSH    D
        CALL    LDW             ;DE = Y0
        XTHL                    ;HL = X0, list pointer on stack
        MVI     A,OPMOVE
        CALL    XYCMD
        POP     H
        LDA     PLOP
        CALL    PLYCMD
        JMP     DPLOOP
;
; CRECT -- rectangle command ROP from (QX-HW,QY-HH) to (QX+HW,QY+HH)
;
CRECT:  LHLD    HH
        XCHG
        LHLD    QY
        CALL    SUBHD
        PUSH    H
        LHLD    HW
        XCHG
        LHLD    QX
        CALL    SUBHD
        POP     D
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    HH
        XCHG
        LHLD    QY
        DAD     D
        PUSH    H
        LHLD    HW
        XCHG
        LHLD    QX
        DAD     D
        POP     D
        LDA     ROP
        JMP     XYCMD
;
; HUECOL -- A = hue number (low 3 bits) at full brightness
;
HUECOL: ANI     7
        RRC
        RRC
        RRC
        ORI     BRIGHT
        RET
;
; SUBHD -- HL = HL - DE
;
SUBHD:  MOV     A,L
        SUB     E
        MOV     L,A
        MOV     A,H
        SBB     D
        MOV     H,A
        RET
;
; NEGHL -- HL = -HL
;
NEGHL:  MOV     A,H
        CMA
        MOV     H,A
        MOV     A,L
        CMA
        MOV     L,A
        INX     H
        RET
;
; RAND -- 16-bit xorshift (7,9,8), period 65535. HL = SEED = next.
; Uses A, B.
;
RAND:   LHLD    SEED
        MOV     A,H             ;x ^= x << 7
        RAR                     ;  CY = H bit 0
        MOV     A,L
        RAR                     ;  A = H0:L7..L1, CY = L bit 0
        MOV     B,A
        MVI     A,0
        RAR                     ;  A = L0:0000000
        XRA     L
        MOV     L,A
        MOV     A,B
        XRA     H
        MOV     H,A
        MOV     A,H             ;x ^= x >> 9
        ORA     A
        RAR
        XRA     L
        MOV     L,A
        MOV     A,L             ;x ^= x << 8
        XRA     H
        MOV     H,A
        SHLD    SEED
        RET
;
;
; ================= the demo screens =================
;
; 1  DOT -- a dotted border, stepped by RMOVE between DOTs, and a
; field of 4000 random dots, each placed by AMOVE.
;
DEMDOT: LXI     H,0ACE1H
        SHLD    SEED
        LXI     H,8
        LXI     D,8
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,DSIDES
DDSIDE: MOV     A,M
        ORA     A
        JZ      DDSTAR
        INX     H
        CALL    SETCOL
        CALL    LDW             ;DE = dX
        PUSH    D
        CALL    LDW             ;DE = dY
        MOV     B,M             ;B = dots on this side
        INX     H
        XTHL                    ;HL = dX, list pointer on stack
DDLOOP: PUSH    H
        LXI     H,CMDDOT
        CALL    PUTW
        POP     H
        MVI     A,OPRMOV
        CALL    XYCMD
        DCR     B
        JNZ     DDLOOP
        POP     H
        JMP     DDSIDE
;
DDSTAR: LXI     H,4000
        SHLD    CNT16
DDRX:   CALL    RAND            ;X = 16..623
        MOV     A,H
        ANI     3
        MOV     H,A
        PUSH    H
        LXI     D,0-608
        DAD     D
        POP     H
        JC      DDRX
        LXI     D,16
        DAD     D
        SHLD    GX
DDRY:   CALL    RAND            ;Y = 16..463
        MOV     A,H
        ANI     1
        MOV     H,A
        PUSH    H
        LXI     D,0-448
        DAD     D
        POP     H
        JC      DDRY
        LXI     D,16
        DAD     D
        XCHG
        LDA     SEED            ;random hue, upper half brightness
        ORI     10H
        CALL    SETCOL
        LHLD    GX
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,CMDDOT
        CALL    PUTW
        LHLD    CNT16
        DCX     H
        SHLD    CNT16
        MOV     A,H
        ORA     L
        JNZ     DDRX
        RET
;
; Border sides: color / dX,dY / dot count. Starts at (8,8).
;
DSIDES: DB      RED+BRIGHT
        DW      8,0
        DB      78
        DB      GREEN+BRIGHT
        DW      0,8
        DB      58
        DB      BLUE+BRIGHT
        DW      0-8,0
        DB      78
        DB      YELLOW+BRIGHT
        DW      0,0-8
        DB      58
        DB      0
;
; 2  ALINE -- string art: in each corner, 31 lines from a point on
; the side edge to a point on the top/bottom edge, sliding together.
;
DEMALN: LXI     H,20
        SHLD    IX
        LXI     H,465
        SHLD    IY
        MVI     A,1
        STA     LEV
ALLOOP: LDA     LEV             ;bottom left
        ORI     CYAN
        CALL    SETCOL
        LHLD    IY
        XCHG
        LXI     H,0
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    IX
        LXI     D,0
        MVI     A,OPLINE
        CALL    XYCMD
        LDA     LEV             ;bottom right
        ORI     MAGENTA
        CALL    SETCOL
        LHLD    IY
        XCHG
        LXI     H,XMAX
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    IX
        XCHG
        LXI     H,XMAX
        CALL    SUBHD
        LXI     D,0
        MVI     A,OPLINE
        CALL    XYCMD
        LDA     LEV             ;top left
        ORI     YELLOW
        CALL    SETCOL
        LHLD    IY
        XCHG
        LXI     H,YMAX
        CALL    SUBHD
        XCHG
        LXI     H,0
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    IX
        LXI     D,YMAX
        MVI     A,OPLINE
        CALL    XYCMD
        LDA     LEV             ;top right
        ORI     GREEN
        CALL    SETCOL
        LHLD    IY
        XCHG
        LXI     H,YMAX
        CALL    SUBHD
        XCHG
        LXI     H,XMAX
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    IX
        XCHG
        LXI     H,XMAX
        CALL    SUBHD
        LXI     D,YMAX
        MVI     A,OPLINE
        CALL    XYCMD
        LHLD    IX              ;IX += 20, IY -= 15
        LXI     D,20
        DAD     D
        SHLD    IX
        LHLD    IY
        LXI     D,0-15
        DAD     D
        SHLD    IY
        LDA     LEV
        INR     A
        STA     LEV
        CPI     32
        JC      ALLOOP
        RET
;
; 3  RLINE -- square spiral out from the center: 150 relative
; segments turning left each time, each 3 pixels longer than the
; last. Each segment starts where the last one ended (CP = Pe).
;
DEMRLN: LXI     H,320
        LXI     D,240
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,4
        SHLD    LEN
        XRA     A
        STA     DIR
        STA     TURN
        MVI     A,150
        STA     CNT8
RLLOOP: LDA     DIR             ;new color at the start of each turn
        ORA     A
        JNZ     RLDIR
        LDA     TURN
        INR     A
        STA     TURN
        CALL    HUECOL
        CALL    SETCOL
RLDIR:  LHLD    LEN             ;DIR 0 right, 1 up, 2 left, 3 down
        LXI     D,0
        LDA     DIR
        ANI     1
        JZ      RLHORZ
        XCHG                    ;vertical: dX = 0, dY = LEN
RLHORZ: LDA     DIR
        ANI     2
        JZ      RLGO
        CALL    NEGHL           ;left/down: negate both
        XCHG
        CALL    NEGHL
        XCHG
RLGO:   MVI     A,OPRLIN
        CALL    XYCMD
        LHLD    LEN
        INX     H
        INX     H
        INX     H
        SHLD    LEN
        LDA     DIR
        INR     A
        ANI     3
        STA     DIR
        LDA     CNT8
        DCR     A
        STA     CNT8
        JNZ     RLLOOP
        RET
;
; 4  ARCT -- 22 concentric rectangle outlines about the center
;
DEMARC: LXI     H,320
        SHLD    QX
        LXI     H,240
        SHLD    QY
        LXI     H,13
        SHLD    HW
        LXI     H,10
        SHLD    HH
        MVI     A,OPRECT
        STA     ROP
        MVI     A,1
        STA     CNT8
ARLOOP: LDA     CNT8
        CALL    HUECOL
        CALL    SETCOL
        CALL    CRECT
        LHLD    HW
        LXI     D,13
        DAD     D
        SHLD    HW
        LHLD    HH
        LXI     D,10
        DAD     D
        SHLD    HH
        LDA     CNT8
        INR     A
        STA     CNT8
        CPI     23
        JC      ARLOOP
        RET
;
; 5  RRCT -- two crossing cascades of 24 rectangles, each the same
; relative size, stepped along by RMOVE (the second one leftwards,
; with negative dX).
;
DEMRRC: LXI     H,24
        LXI     D,24
        MVI     A,OPMOVE
        CALL    XYCMD
        MVI     A,BLUE
        STA     HUE
        LXI     H,160
        SHLD    RW
        LXI     H,18
        SHLD    SX
        CALL    CASC
        LXI     H,615
        LXI     D,24
        MVI     A,OPMOVE
        CALL    XYCMD
        MVI     A,RED
        STA     HUE
        LXI     H,0-160
        SHLD    RW
        LXI     H,0-18
        SHLD    SX
;
; CASC -- 24 x (RRCT RW,120 / RMOVE SX,13), levels 8..31 of HUE
;
CASC:   MVI     A,8
        STA     LEV
CSLOOP: LDA     LEV
        MOV     B,A
        LDA     HUE
        ORA     B
        CALL    SETCOL
        LHLD    RW
        LXI     D,120
        MVI     A,OPRRCT
        CALL    XYCMD
        LHLD    SX
        LXI     D,13
        MVI     A,OPRMOV
        CALL    XYCMD
        LDA     LEV
        INR     A
        STA     LEV
        CPI     32
        JC      CSLOOP
        RET
;
; 6  APLL -- a framed plot: sine and damped cosine curves, 70
; segments each, every one a single APLL command
;
DEMAPL: LXI     H,PLTAB
        MVI     A,OPAPLL
        JMP     DRAWPL
;
; 7  RPLL -- bands of a repeating motif. Each motif is one short
; RPLL list; since RPLL leaves CP at its end point, sending the same
; list again continues the band where the last copy stopped.
;
DEMRPL: LXI     H,BANDS
BNLOOP: MOV     A,M
        ORA     A
        RZ
        CALL    SETCOL
        INX     H
        MOV     A,M             ;repeat count
        STA     CNT8
        INX     H
        CALL    LDW             ;DE = X0
        PUSH    D
        CALL    LDW             ;DE = Y0
        XTHL
        MVI     A,OPMOVE
        CALL    XYCMD
        POP     H
        CALL    LDW             ;DE = motif
        SHLD    PTR
        XCHG
        SHLD    MOTIF
BNREP:  LHLD    MOTIF
        MVI     A,OPRPLL
        CALL    PLYCMD
        LDA     CNT8
        DCR     A
        STA     CNT8
        JNZ     BNREP
        LHLD    PTR
        JMP     BNLOOP
;
; Bands: color, repeats / X0,Y0 / motif. All are 576 pixels wide.
;
BANDS:  DB      RED+BRIGHT,18
        DW      32,410,CREN
        DB      GREEN+BRIGHT,18
        DW      32,320,TRI
        DB      CYAN+BRIGHT,12
        DW      32,230,STAIR
        DB      YELLOW+BRIGHT,18
        DW      32,140,TRAP
        DB      MAGENTA+BRIGHT,36
        DW      32,50,SAW
        DB      0
;
CREN:   DW      4               ;crenellation, 32 wide
        DW      0,16,16,0,0,0-16,16,0
TRI:    DW      2               ;triangle wave, 32 wide
        DW      16,24,16,0-24
STAIR:  DW      12              ;steps up and down, 48 wide
        DW      0,8,8,0,0,8,8,0,0,8,8,0
        DW      0,0-8,8,0,0,0-8,8,0,0,0-8,8,0
TRAP:   DW      4               ;trapezoid wave, 32 wide
        DW      8,16,8,0,8,0-16,8,0
SAW:    DW      2               ;sawtooth, 16 wide
        DW      16,24,0,0-24
;
; 8  APLG -- nested regular polygons and star polygons, each one
; APLG command that closes itself back on the starting point
;
DEMAPG: LXI     H,PGTAB
        MVI     A,OPAPLG
        JMP     DRAWPL
;
; 9  RPLG -- a honeycomb: one relative hexagon list, stamped 260
; times by just moving CP and resending it
;
DEMRPG: LXI     H,20
        SHLD    CX
        XRA     A
        STA     COLC
RPCOL:  LXI     H,24            ;odd columns sit half a cell higher
        LDA     COLC
        ANI     1
        JZ      RPEVEN
        LXI     H,41
RPEVEN: SHLD    CY
        XRA     A
        STA     ROWR
RPROW:  LDA     ROWR            ;hue by column, dimmer going up
        ADD     A
        MOV     B,A
        MVI     A,BRIGHT
        SUB     B
        MOV     B,A
        LDA     COLC
        CALL    HUECOL
        ANI     0E0H
        ORA     B
        CALL    SETCOL
        LHLD    CY
        XCHG
        LHLD    CX
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,HEXREL
        MVI     A,OPRPLG
        CALL    PLYCMD
        LHLD    CY
        LXI     D,34
        DAD     D
        SHLD    CY
        LDA     ROWR
        INR     A
        STA     ROWR
        CPI     13
        JNZ     RPROW
        LHLD    CX
        LXI     D,30
        DAD     D
        SHLD    CX
        LDA     COLC
        INR     A
        STA     COLC
        CPI     20
        JNZ     RPCOL
        RET
;
; Flat-topped hexagon, side 20, from its left vertex
;
HEXREL: DW      5
        DW      10,17,20,0,10,0-17,0-10,0-17,0-20,0
;
; 10  AFRCT -- in each quarter of the screen, 16 filled rectangles
; shrinking toward the center and brightening: a stepped pyramid
;
DEMAFR: MVI     A,OPFRCT
        STA     ROP
        LXI     H,QUADS
AFQUAD: MOV     A,M
        CPI     0FFH
        RZ
        STA     HUE
        INX     H
        CALL    LDW
        XCHG
        SHLD    QX
        XCHG
        CALL    LDW
        XCHG
        SHLD    QY
        XCHG
        SHLD    PTR
        LXI     H,152
        SHLD    HW
        LXI     H,112
        SHLD    HH
        MVI     A,1
        STA     LEV
AFLOOP: LDA     LEV
        MOV     B,A
        LDA     HUE
        ORA     B
        CALL    SETCOL
        CALL    CRECT
        LHLD    HW
        LXI     D,0-9
        DAD     D
        SHLD    HW
        LHLD    HH
        LXI     D,0-7
        DAD     D
        SHLD    HH
        LDA     LEV
        ADI     2
        STA     LEV
        CPI     33
        JC      AFLOOP
        LHLD    PTR
        JMP     AFQUAD
;
; Quarters: hue / center X,Y
;
QUADS:  DB      YELLOW
        DW      160,360
        DB      GREEN
        DW      480,360
        DB      BLUE
        DW      160,120
        DB      RED
        DW      480,120
        DB      0FFH
;
; 11  RFRCT -- a stacked bar chart. After a fill, CP.Y is one past
; the far edge, so each RFRCT segment starts on top of the last.
;
DEMRFR: LXI     H,0ACE1H
        SHLD    SEED
        MVI     A,WHITE+20      ;base line
        CALL    SETCOL
        LXI     H,24
        LXI     D,38
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,617
        MVI     A,OPLINE
        CALL    XYCMD
        LXI     H,40
        SHLD    QX
        MVI     A,16
        STA     CNTB
RFBAR:  LHLD    QX
        LXI     D,40
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,SEGCOL
        SHLD    PTR
RFSEG:  LHLD    PTR
        MOV     A,M
        CPI     0FFH
        JZ      RFNEXT
        INX     H
        SHLD    PTR
        CALL    SETCOL
        CALL    RAND            ;segment height 24..87
        MOV     A,L
        ANI     63
        ADI     23
        MOV     E,A
        MVI     D,0
        LXI     H,27            ;28 pixels wide
        MVI     A,OPRFRC
        CALL    XYCMD
        LXI     H,0             ;2 pixel gap before the next segment
        LXI     D,2
        MVI     A,OPRMOV
        CALL    XYCMD
        JMP     RFSEG
RFNEXT: LHLD    QX
        LXI     D,36
        DAD     D
        SHLD    QX
        LDA     CNTB
        DCR     A
        STA     CNTB
        JNZ     RFBAR
        RET
;
SEGCOL: DB      BLUE+BRIGHT,GREEN+BRIGHT,ORANGE+BRIGHT,MAGENTA+BRIGHT
        DB      0FFH
;
;
; ================= polyline and polygon tables =================
;
; Entries: DB color / DW X0,Y0 (AMOVE) / DW n / n X,Y pairs; DB 0 ends.
;
PLTAB:  DB      WHITE+20        ;plot frame
        DW      40,40
        DW      4
        DW      600,40,600,440,40,440,40,40
        DB      WHITE+12        ;zero axis
        DW      41,240
        DW      1
        DW      600,240
        DB      YELLOW+BRIGHT   ;sine, 2 cycles
        DW      40,240
        DW      70
        DW      48,272,56,303,64,332,72,358
        DW      80,381,88,399,96,411,104,418
        DW      112,420,120,415,128,406,136,390
        DW      144,370,152,346,160,318,168,288
        DW      176,256,184,224,192,192,200,162
        DW      208,134,216,110,224,90,232,74
        DW      240,65,248,60,256,62,264,69
        DW      272,81,280,99,288,122,296,148
        DW      304,177,312,208,320,240,328,272
        DW      336,303,344,332,352,358,360,381
        DW      368,399,376,411,384,418,392,420
        DW      400,415,408,406,416,390,424,370
        DW      432,346,440,318,448,288,456,256
        DW      464,224,472,192,480,162,488,134
        DW      496,110,504,90,512,74,520,65
        DW      528,60,536,62,544,69,552,81
        DW      560,99,568,122,576,148,584,177
        DW      592,208,600,240
        DB      CYAN+BRIGHT     ;damped cosine
        DW      40,420
        DW      70
        DW      48,395,56,343,64,275,72,206
        DW      80,149,88,115,96,107,104,125
        DW      112,164,120,214,128,265,136,307
        DW      144,333,152,339,160,325,168,297
        DW      176,259,184,221,192,190,200,171
        DW      208,167,216,177,224,198,232,226
        DW      240,254,248,277,256,291,264,294
        DW      272,287,280,271,288,251,296,230
        DW      304,213,312,202,320,200,328,205
        DW      336,217,344,232,352,248,360,260
        DW      368,268,376,270,384,266,392,257
        DW      400,246,408,234,416,225,424,219
        DW      432,218,440,221,448,227,456,236
        DW      464,244,472,251,480,255,488,256
        DW      496,254,504,249,512,243,520,237
        DW      528,232,536,229,544,228,552,230
        DW      560,233,568,238,576,242,584,246
        DW      592,248,600,249
        DB      0
;
PGTAB:  DB      RED+BRIGHT      ;pentagram {5/2} r=105
        DW      160,460
        DW      4
        DW      98,270,260,387,60,387,222,270
        DB      ORANGE+BRIGHT   ;pentagram {5/2} r=70
        DW      160,425
        DW      4
        DW      119,298,227,377,93,377,201,298
        DB      YELLOW+BRIGHT   ;pentagram {5/2} r=35
        DW      160,390
        DW      4
        DW      139,327,193,366,127,366,181,327
        DB      CYAN+31         ;hexagon r=105
        DW      480,460
        DW      5
        DW      389,408,389,302,480,250,571,302
        DW      571,408
        DB      CYAN+27         ;hexagon r=85
        DW      458,437
        DW      5
        DW      398,377,420,295,502,273,562,333
        DW      540,415
        DB      CYAN+23         ;hexagon r=65
        DW      448,411
        DW      5
        DW      415,355,448,299,512,299,545,355
        DW      512,411
        DB      CYAN+19         ;hexagon r=45
        DW      448,387
        DW      5
        DW      437,343,468,312,512,323,523,367
        DW      492,398
        DB      CYAN+15         ;hexagon r=25
        DW      458,368
        DW      5
        DW      458,342,480,330,502,342,502,368
        DW      480,380
        DB      GREEN+31        ;octagon r=105
        DW      160,230
        DW      7
        DW      86,199,55,125,86,51,160,20
        DW      234,51,265,125,234,199
        DB      GREEN+25        ;octagon r=75
        DW      131,194
        DW      7
        DW      91,154,91,96,131,56,189,56
        DW      229,96,229,154,189,194
        DB      GREEN+19        ;octagon r=45
        DW      160,170
        DW      7
        DW      128,157,115,125,128,93,160,80
        DW      192,93,205,125,192,157
        DB      MAGENTA+BRIGHT  ;heptagram {7/3} r=105
        DW      480,230
        DW      6
        DW      434,30,562,190,378,102,582,102
        DW      398,190,526,30
        DB      BLUE+BRIGHT     ;heptagram {7/2} r=60
        DW      480,65
        DW      6
        DW      538,138,454,179,433,88,527,88
        DW      506,179,422,138
        DB      0
;
;
; ================= initialization =================
;
; REGINIT -- load the ACRTC control registers from REGTAB
;
REGINIT:
        LXI     H,REGTAB
RILOOP: MOV     A,M
        CPI     0FFH
        RZ
        MOV     B,A
        INX     H
        CALL    LDW
        PUSH    H
        XCHG
        CALL    WRREG
        POP     H
        JMP     RILOOP
;
; Control register table: DB register / DW value, 0FFH ends.
; 640x480 single access, 16 pixels per memory cycle (8 words, GAI +8).
;
REGTAB: DB      02H             ;CCR: ABT - abort, flush FIFOs
        DW      8300H
        DB      02H             ;CCR: GBM=011 8 bpp, no interrupts
        DW      0300H
        DB      04H             ;OMR: M/S=1, STR=0 (stopped), RAM=1
        DW      80B0H           ;  static RAM, GAI=011 +8, ACM=00 single
        DB      06H             ;DCR: all screens off while programming
        DW      0000H
        DB      82H             ;HSR: HC=49 (50 cycles), HSW=6
        DW      3106H
        DB      84H             ;HDR: HDS=2, HDW=39 (40 cycles = 640 px)
        DW      0227H
        DB      86H             ;VSR: VC=525 rasters
        DW      020DH
        DB      88H             ;VDR: VDS=32, VSW=2
        DW      2002H
        DB      8AH             ;SP1: base screen 480 rasters
        DW      01E0H
        DB      8CH             ;SP0: upper screen (disabled)
        DW      0000H
        DB      8EH             ;SP2: lower screen (disabled)
        DW      0000H
        DB      90H             ;BCR: no blink
        DW      0000H
        DB      92H             ;HWR: window (disabled)
        DW      0000H
        DB      94H             ;VWS
        DW      0000H
        DB      96H             ;VWW
        DW      0000H
        DB      98H             ;GCR: graphic cursor (not supported)
        DW      0000H
        DB      9AH
        DW      0000H
        DB      9CH
        DW      0000H
        DB      0C8H            ;RAR1: base screen raster address
        DW      0000H
        DB      0CAH            ;MWR1: graphic, 320 words per raster
        DW      0140H
        DB      0CCH            ;SAR1: start address = 0 (high nibble)
        DW      0000H
        DB      0CEH            ;SAR1: start address = 0 (low word)
        DW      0000H
        DB      0E0H            ;BCUR1/2: block cursors (not supported)
        DW      0000H
        DB      0E2H
        DW      0000H
        DB      0E4H
        DW      0000H
        DB      0E6H
        DW      0000H
        DB      0E8H            ;CDR: cursor definition
        DW      0000H
        DB      0EAH            ;ZFR: no zoom (not supported)
        DW      0000H
        DB      06H             ;DCR: SE1 - base screen displayed
        DW      4000H
        DB      04H             ;OMR: as above with STR=1 - start
        DW      0C0B0H
        DB      0FFH
;
; Drawing parameter setup, streamed through the FIFO as words.
;
DPINIT: DW      1800H,32        ;WPTN PRA=0, n=32 bytes (8-bit bus)
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH     ;pattern RAM all ones
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH
        DW      0805H,0000H     ;PRC: PPY=PPX=0, zoom counts 0
        DW      0806H,0000H     ;PRC: PSY=PSX=0
        DW      0807H,0F0F0H    ;PRC: PEY=PEX=15, no pattern zoom
        DW      0800H,0000H     ;CL0 = 0
        DW      0801H,0FFFFH    ;CL1 = 0FFH (bright white)
        DW      0802H,0000H     ;CCMP
        DW      0803H,0000H     ;EDG
        DW      0804H,0FFFFH    ;MASK: all bits
        DW      0808H,0         ;ADR XMIN
        DW      0809H,0         ;ADR YMIN
        DW      080AH,XMAX      ;ADR XMAX
        DW      080BH,YMAX      ;ADR YMAX
        DW      0400H,4025H,6C00H ;ORG: base screen, word 256C0H
;                               ; = 479*320, bottom-left pixel, DPD=0
        DW      080CH,4000H     ;RWP: base screen, address 0 (top raster)
        DW      080DH,0000H
DPEND:
;
; PALINIT -- load all 256 Bt453 palette entries: 8 hues of 32 levels.
;
PALINIT:
        XRA     A               ;address 0, resets color phase to red
        OUT     DACADR
        LXI     H,HUETAB
        MVI     C,8             ;hues
PALH:   LXI     D,LEVTAB
        MVI     B,32            ;levels per hue
PALL:   LDAX    D
        STA     LEVEL
        PUSH    H
        CALL    CHAN            ;red
        CALL    CHAN            ;green
        CALL    CHAN            ;blue
        POP     H
        INX     D
        DCR     B
        JNZ     PALL
        INX     H               ;next hue
        INX     H
        INX     H
        DCR     C
        JNZ     PALH
        RET
;
; CHAN -- write one color component. (HL) = channel code
; (0 off, 1 full, 2 half), LEVEL = intensity. HL += 1.
;
CHAN:   MOV     A,M
        INX     H
        ORA     A
        JZ      CHOUT           ;off: A = 0
        CPI     2
        LDA     LEVEL
        JNZ     CHOUT           ;full
        ORA     A               ;half: clear carry, shift right
        RAR
CHOUT:  OUT     DACPAL
        RET
;
; Channel codes R,G,B for each hue (index order)
;
HUETAB: DB      1,2,0           ;0 orange
        DB      0,0,1           ;1 blue
        DB      0,1,0           ;2 green
        DB      0,1,1           ;3 cyan
        DB      1,0,0           ;4 red
        DB      1,0,1           ;5 magenta
        DB      1,1,0           ;6 yellow
        DB      1,1,1           ;7 white
;
; Linear brightness ramp: level*255/31
;
LEVTAB: DB      0,8,16,25,33,41,49,58
        DB      66,74,82,90,99,107,115,123
        DB      132,140,148,156,165,173,181,189
        DB      197,206,214,222,230,239,247,255
;
;
;
; ================= messages and variables =================
;
MSGHI:  DB      CR,LF
        DB      'CADzilla drawdemo: the ACRTC drawing '
        DB      'commands, 640x480, 8 bpp'
        DB      CR,LF,'$'
MSG1:   DB      CR,LF
        DB      ' 1/11  DOT   - '
        DB      'random dots placed by AMOVE; border dots stepped'
        DB      CR,LF,'              by RMOVE',CR,LF,'$'
MSG2:   DB      CR,LF
        DB      ' 2/11  ALINE - '
        DB      'absolute lines: string art in each corner',CR,LF,'$'
MSG3:   DB      CR,LF
        DB      ' 3/11  RLINE - '
        DB      'relative lines: a square spiral from the center'
        DB      CR,LF,'$'
MSG4:   DB      CR,LF
        DB      ' 4/11  ARCT  - '
        DB      'absolute rectangles: concentric outlines',CR,LF,'$'
MSG5:   DB      CR,LF
        DB      ' 5/11  RRCT  - '
        DB      'relative rectangles: two cascades, stepped by RMOVE'
        DB      CR,LF,'$'
MSG6:   DB      CR,LF
        DB      ' 6/11  APLL  - '
        DB      'absolute polylines: a framed sine/damped cosine plot'
        DB      CR,LF,'$'
MSG7:   DB      CR,LF
        DB      ' 7/11  RPLL  - '
        DB      'relative polylines: one motif resent, chaining from CP'
        DB      CR,LF,'$'
MSG8:   DB      CR,LF
        DB      ' 8/11  APLG  - '
        DB      'absolute polygons: nested polygons and star polygons'
        DB      CR,LF,'$'
MSG9:   DB      CR,LF
        DB      ' 9/11  RPLG  - '
        DB      'relative polygons: one hexagon stamped as a honeycomb'
        DB      CR,LF,'$'
MSG10:  DB      CR,LF
        DB      '10/11  AFRCT - '
        DB      'absolute filled rectangles: stepped color pyramids'
        DB      CR,LF,'$'
MSG11:  DB      CR,LF
        DB      '11/11  RFRCT - '
        DB      'relative filled rectangles: a stacked bar chart'
        DB      CR,LF,'$'
MSGKEY: DB      'Press any key for the next screen (ESC '
        DB      'quits)... $'
MSGNL:  DB      CR,LF,'$'
MSGER:  DB      'ACRTC command error (CER set)!',CR,LF,'$'
MSGEND: DB      CR,LF,'drawdemo done.',CR,LF,'$'
;
; ---- variables ----
;
OLDSP:  DS      2
LEVEL:  DS      1               ;PALINIT
SCRPTR: DS      2               ;screen loop
ROUTN:  DS      2
PLOP:   DS      1               ;DRAWPL command
ROP:    DS      1               ;CRECT command
SEED:   DS      2               ;RAND state
CNT16:  DS      2
CNT8:   DS      1
CNTB:   DS      1
GX:     DS      2
IX:     DS      2
IY:     DS      2
LEV:    DS      1
HUE:    DS      1
LEN:    DS      2
DIR:    DS      1
TURN:   DS      1
QX:     DS      2
QY:     DS      2
HW:     DS      2
HH:     DS      2
RW:     DS      2
SX:     DS      2
PTR:    DS      2
MOTIF:  DS      2
CX:     DS      2
CY:     DS      2
COLC:   DS      1
ROWR:   DS      1
        DS      64
STACK:
;
        END     START
