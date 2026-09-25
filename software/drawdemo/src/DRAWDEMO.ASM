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
; parameters) is the same as software/firstdraw: 1024x768, 8 bpp, single
; access, origin at the bottom-left pixel, so X runs 0..1023 left to
; right and Y runs 0..767 BOTTOM to TOP. The machine's monitor must be
; strapped for 1024x768 (cad0 mode, the pristine machine's default).
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
; VESA 1024x768@60 uses negative H and V sync; single access mode.
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
XMAX    EQU     1023
YMAX    EQU     767
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
        DW      5800H,0000H,511,0-767 ;CLR 512 words x 768 rasters to 0
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
; field of 10000 random dots, each placed by AMOVE.
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
DDSTAR: LXI     H,10000
        SHLD    CNT16
DDRX:   CALL    RAND            ;X = 16..1007
        MOV     A,H
        ANI     3
        MOV     H,A
        PUSH    H
        LXI     D,0-992
        DAD     D
        POP     H
        JC      DDRX
        LXI     D,16
        DAD     D
        SHLD    GX
DDRY:   CALL    RAND            ;Y = 16..751
        MOV     A,H
        ANI     3
        MOV     H,A
        PUSH    H
        LXI     D,0-736
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
        DB      126
        DB      GREEN+BRIGHT
        DW      0,8
        DB      94
        DB      BLUE+BRIGHT
        DW      0-8,0
        DB      126
        DB      YELLOW+BRIGHT
        DW      0,0-8
        DB      94
        DB      0
;
; 2  ALINE -- string art: in each corner, 31 lines from a point on
; the side edge to a point on the top/bottom edge, sliding together.
;
DEMALN: LXI     H,32
        SHLD    IX
        LXI     H,744
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
        LHLD    IX              ;IX += 32, IY -= 24
        LXI     D,32
        DAD     D
        SHLD    IX
        LHLD    IY
        LXI     D,0-24
        DAD     D
        SHLD    IY
        LDA     LEV
        INR     A
        STA     LEV
        CPI     32
        JC      ALLOOP
        RET
;
; 3  RLINE -- square spiral out from the center: 146 relative
; segments turning left each time, each 5 pixels longer than the
; last. Each segment starts where the last one ended (CP = Pe).
;
DEMRLN: LXI     H,512
        LXI     D,384
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,6
        SHLD    LEN
        XRA     A
        STA     DIR
        STA     TURN
        MVI     A,146
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
        LXI     D,5
        DAD     D
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
DEMARC: LXI     H,512
        SHLD    QX
        LXI     H,384
        SHLD    QY
        LXI     H,21
        SHLD    HW
        LXI     H,16
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
        LXI     D,21
        DAD     D
        SHLD    HW
        LHLD    HH
        LXI     D,16
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
DEMRRC: LXI     H,38
        LXI     D,38
        MVI     A,OPMOVE
        CALL    XYCMD
        MVI     A,BLUE
        STA     HUE
        LXI     H,256
        SHLD    RW
        LXI     H,29
        SHLD    SX
        CALL    CASC
        LXI     H,984
        LXI     D,38
        MVI     A,OPMOVE
        CALL    XYCMD
        MVI     A,RED
        STA     HUE
        LXI     H,0-256
        SHLD    RW
        LXI     H,0-29
        SHLD    SX
;
; CASC -- 24 x (RRCT RW,192 / RMOVE SX,21), levels 8..31 of HUE
;
CASC:   MVI     A,8
        STA     LEV
CSLOOP: LDA     LEV
        MOV     B,A
        LDA     HUE
        ORA     B
        CALL    SETCOL
        LHLD    RW
        LXI     D,192
        MVI     A,OPRRCT
        CALL    XYCMD
        LHLD    SX
        LXI     D,21
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
; Bands: color, repeats / X0,Y0 / motif. All are 864 pixels wide.
;
BANDS:  DB      RED+BRIGHT,18
        DW      80,656,CREN
        DB      GREEN+BRIGHT,18
        DW      80,512,TRI
        DB      CYAN+BRIGHT,12
        DW      80,368,STAIR
        DB      YELLOW+BRIGHT,18
        DW      80,224,TRAP
        DB      MAGENTA+BRIGHT,36
        DW      80,80,SAW
        DB      0
;
CREN:   DW      4               ;crenellation, 48 wide
        DW      0,24,24,0,0,0-24,24,0
TRI:    DW      2               ;triangle wave, 48 wide
        DW      24,36,24,0-36
STAIR:  DW      12              ;steps up and down, 72 wide
        DW      0,12,12,0,0,12,12,0,0,12,12,0
        DW      0,0-12,12,0,0,0-12,12,0,0,0-12,12,0
TRAP:   DW      4               ;trapezoid wave, 48 wide
        DW      12,24,12,0,12,0-24,12,0
SAW:    DW      2               ;sawtooth, 24 wide
        DW      24,36,0,0-36
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
DEMRPG: LXI     H,24
        SHLD    CX
        XRA     A
        STA     COLC
RPCOL:  LXI     H,36            ;odd columns sit half a cell higher
        LDA     COLC
        ANI     1
        JZ      RPEVEN
        LXI     H,64
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
        LXI     D,56
        DAD     D
        SHLD    CY
        LDA     ROWR
        INR     A
        STA     ROWR
        CPI     13
        JNZ     RPROW
        LHLD    CX
        LXI     D,48
        DAD     D
        SHLD    CX
        LDA     COLC
        INR     A
        STA     COLC
        CPI     20
        JNZ     RPCOL
        RET
;
; Flat-topped hexagon, side 32, from its left vertex
;
HEXREL: DW      5
        DW      16,28,32,0,16,0-28,0-16,0-28,0-32,0
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
        LXI     H,243
        SHLD    HW
        LXI     H,179
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
        LXI     D,0-14
        DAD     D
        SHLD    HW
        LHLD    HH
        LXI     D,0-11
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
        DW      256,576
        DB      GREEN
        DW      768,576
        DB      BLUE
        DW      256,192
        DB      RED
        DW      768,192
        DB      0FFH
;
; 11  RFRCT -- a stacked bar chart. After a fill, CP.Y is one past
; the far edge, so each RFRCT segment starts on top of the last.
;
DEMRFR: LXI     H,0ACE1H
        SHLD    SEED
        MVI     A,WHITE+20      ;base line
        CALL    SETCOL
        LXI     H,38
        LXI     D,61
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,987
        MVI     A,OPLINE
        CALL    XYCMD
        LXI     H,64
        SHLD    QX
        MVI     A,16
        STA     CNTB
RFBAR:  LHLD    QX
        LXI     D,64
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
        CALL    RAND            ;segment height 38..132: b + b/2 + 37
        MOV     A,L
        ANI     63              ;b (ANI also clears CY for the RAR)
        MOV     E,A
        RAR
        ADD     E
        ADI     37
        MOV     E,A
        MVI     D,0
        LXI     H,44            ;45 pixels wide
        MVI     A,OPRFRC
        CALL    XYCMD
        LXI     H,0             ;3 pixel gap before the next segment
        LXI     D,3
        MVI     A,OPRMOV
        CALL    XYCMD
        JMP     RFSEG
RFNEXT: LHLD    QX
        LXI     D,58
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
        DW      64,64
        DW      4
        DW      960,64,960,704,64,704,64,64
        DB      WHITE+12        ;zero axis
        DW      65,384
        DW      1
        DW      960,384
        DB      YELLOW+BRIGHT   ;sine, 2 cycles
        DW      64,384
        DW      70
        DW      77,435,90,485,102,532,115,573
        DW      128,609,141,638,154,658,166,669
        DW      179,672,192,665,205,649,218,624
        DW      230,592,243,553,256,509,269,461
        DW      282,410,294,358,307,307,320,259
        DW      333,215,346,176,358,144,371,119
        DW      384,103,397,96,410,99,422,110
        DW      435,130,448,159,461,195,474,236
        DW      486,283,499,333,512,384,525,435
        DW      538,485,550,532,563,573,576,609
        DW      589,638,602,658,614,669,627,672
        DW      640,665,653,649,666,624,678,592
        DW      691,553,704,509,717,461,730,410
        DW      742,358,755,307,768,259,781,215
        DW      794,176,806,144,819,119,832,103
        DW      845,96,858,99,870,110,883,130
        DW      896,159,909,195,922,236,934,283
        DW      947,333,960,384
        DB      CYAN+BRIGHT     ;damped cosine
        DW      64,672
        DW      70
        DW      77,633,90,549,102,440,115,330
        DW      128,239,141,183,154,171,166,200
        DW      179,262,192,342,205,424,218,491
        DW      230,533,243,542,256,521,269,475
        DW      282,415,294,354,307,304,320,274
        DW      333,267,346,283,358,317,371,361
        DW      384,406,397,443,410,466,422,471
        DW      435,459,448,434,461,401,474,368
        DW      486,340,499,323,512,320,525,328
        DW      538,347,550,371,563,396,576,416
        DW      589,429,602,432,614,425,627,411
        DW      640,393,653,375,666,360,678,351
        DW      691,349,704,353,717,364,730,377
        DW      742,391,755,402,768,409,781,410
        DW      794,407,806,399,819,389,832,379
        DW      845,371,858,366,870,365,883,367
        DW      896,373,909,380,922,388,934,394
        DW      947,398,960,398
        DB      0
;
PGTAB:  DB      RED+BRIGHT      ;pentagram {5/2} r=168
        DW      256,736
        DW      4
        DW      157,432,416,619,96,619,355,432
        DB      ORANGE+BRIGHT   ;pentagram {5/2} r=112
        DW      256,680
        DW      4
        DW      190,477,363,603,149,603,322,477
        DB      YELLOW+BRIGHT   ;pentagram {5/2} r=56
        DW      256,624
        DW      4
        DW      222,523,309,586,203,586,290,523
        DB      CYAN+31         ;hexagon r=168
        DW      768,736
        DW      5
        DW      622,653,622,483,768,400,914,483
        DW      914,653
        DB      CYAN+27         ;hexagon r=136
        DW      733,699
        DW      5
        DW      637,603,672,472,803,437,899,533
        DW      864,664
        DB      CYAN+23         ;hexagon r=104
        DW      717,658
        DW      5
        DW      664,568,717,478,819,478,872,568
        DW      819,658
        DB      CYAN+19         ;hexagon r=72
        DW      717,619
        DW      5
        DW      699,549,749,499,819,517,837,587
        DW      787,637
        DB      CYAN+15         ;hexagon r=40
        DW      733,589
        DW      5
        DW      733,547,768,528,803,547,803,589
        DW      768,608
        DB      GREEN+31        ;octagon r=168
        DW      256,368
        DW      7
        DW      138,318,88,200,138,82,256,32
        DW      374,82,424,200,374,318
        DB      GREEN+25        ;octagon r=120
        DW      210,310
        DW      7
        DW      146,246,146,154,210,90,302,90
        DW      366,154,366,246,302,310
        DB      GREEN+19        ;octagon r=72
        DW      256,272
        DW      7
        DW      205,251,184,200,205,149,256,128
        DW      307,149,328,200,307,251
        DB      MAGENTA+BRIGHT  ;heptagram {7/3} r=168
        DW      768,368
        DW      6
        DW      694,48,899,304,605,163,931,163
        DW      637,304,842,48
        DB      BLUE+BRIGHT     ;heptagram {7/2} r=96
        DW      768,104
        DW      6
        DW      861,221,726,286,693,141,843,141
        DW      810,286,675,221
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
; 1024x768 single access, 16 pixels per memory cycle (8 words, GAI +8).
; Timing from the board's VESA mode table (altairsim docs/boards/cadzilla.md).
;
REGTAB: DB      02H             ;CCR: ABT - abort, flush FIFOs
        DW      8300H
        DB      02H             ;CCR: GBM=011 8 bpp, no interrupts
        DW      0300H
        DB      04H             ;OMR: M/S=1, STR=0 (stopped), RAM=1
        DW      80B0H           ;  static RAM, GAI=011 +8, ACM=00 single
        DB      06H             ;DCR: all screens off while programming
        DW      0000H
        DB      82H             ;HSR: HC=83 (84 cycles), HSW=8
        DW      5308H
        DB      84H             ;HDR: HDS=9, HDW=63 (64 cycles = 1024 px)
        DW      093FH
        DB      86H             ;VSR: VC=806 rasters
        DW      0326H
        DB      88H             ;VDR: VDS=28, VSW=6
        DW      1C06H
        DB      8AH             ;SP1: base screen 768 rasters
        DW      0300H
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
        DB      0CAH            ;MWR1: graphic, 512 words per raster
        DW      0200H
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
        DW      0400H,405FH,0E000H ;ORG: base screen, word 5FE00H
;                               ; = 767*512, bottom-left pixel, DPD=0
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
        DB      'commands, 1024x768, 8 bpp'
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
