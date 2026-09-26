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
;   12  CRCL   circles
;   13  ELPS   ellipses
;   14  AARC   circular arcs, absolute and relative (RARC)
;   15  AEARC  elliptical arcs, absolute and relative (REARC)
;   16  PAINT  area fill out to an edge color, solid and patterned
;   17  PTN    the pattern RAM drawn as a picture
;   18  AGCPY  graphic copy, absolute and relative (RGCPY)
;   19  the eight operation modes (OPM)
;   20  the color modes (COL), line styles and pattern zoom
;   21  the area modes (AREA): clip, hole, stop
;
; Screens 1-11 are drawn by code. Screens 12-21 are FIFO scripts: tables
; of ACRTC command words and their parameters, sent to the chip as they
; are (see RUNSCR). Each command's low byte is its drawing mode: AREA
; (bits 7-5), COL (bits 4-3) and OPM (bits 2-0).
;
; Before each screen the drawing parameters are reset (DPINIT up to
; DPREND): pattern RAM all ones, pattern scan, CL0/CL1, CCMP, EDG, and
; the area set to the whole screen.
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
        LXI     H,DPINIT        ;reset the drawing parameters
        LXI     B,(DPREND-DPINIT)/2
        CALL    SENDBLK
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
        DW      MSG12,DEM12
        DW      MSG13,DEM13
        DW      MSG14,DEM14
        DW      MSG15,DEM15
        DW      MSG16,DEM16
        DW      MSG17,DEM17
        DW      MSG18,DEM18
        DW      MSG19,DEM19
        DW      MSG20,DEM20
        DW      MSG21,DEM21
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
; RUNSCR -- send the FIFO script at HL: chunks of DW n (n > 0) and n
; words, each chunk one ACRTC command; DW 0 ends the script.
;
RUNSCR: CALL    LDW             ;DE = n
        MOV     A,D
        ORA     E
        RZ
        MOV     B,D
        MOV     C,E
        CALL    SENDBLK
        JMP     RUNSCR
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
; field of 5000 random dots, each placed by AMOVE.
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
DDSTAR: LXI     H,5000
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
; shrinking toward the center and brightening: a stepped pyramid.
; AFRCT's time is proportional to the pixels it fills, so each step
; but the last is drawn as a ring -- four strips round the next,
; smaller rectangle -- rather than a solid rectangle the next one
; mostly covers. Every pixel is filled once: 0.7M pixels, not 4.3M.
;
DEMAFR: LXI     H,QUADS
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
        CALL    AFRING
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
; AFRING -- fill the ring between the rectangle QX,QY +/- HW,HH and
; the next step in (14 pixels narrower each side in X, 11 in Y); the
; last step (LEV = 31) is filled solid.
;
AFRING: LHLD    HW              ;XL,XR = QX -/+ HW
        XCHG
        LHLD    QX
        CALL    SUBHD
        SHLD    XL
        DAD     D
        DAD     D
        SHLD    XR
        LHLD    HH              ;YB,YT = QY -/+ HH
        XCHG
        LHLD    QY
        CALL    SUBHD
        SHLD    YB
        DAD     D
        DAD     D
        SHLD    YT
        LHLD    YB              ;bottom strip, or the whole of the last
        XCHG
        LHLD    XL
        MVI     A,OPMOVE
        CALL    XYCMD
        LDA     LEV
        CPI     31
        JNZ     AFSTRP
        LHLD    YT
        XCHG
        LHLD    XR
        MVI     A,OPFRCT
        JMP     XYCMD
AFSTRP: LXI     H,10            ;bottom: XL,YB .. XR,YB+10
        DAD     D
        XCHG
        LHLD    XR
        MVI     A,OPFRCT
        CALL    XYCMD
        LHLD    YT              ;top: XL,YT-10 .. XR,YT
        LXI     D,0-10
        DAD     D
        XCHG
        LHLD    XL
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    YT
        XCHG
        LHLD    XR
        MVI     A,OPFRCT
        CALL    XYCMD
        LHLD    YB              ;left: XL,YB+11 .. XL+13,YT-11
        LXI     D,11
        DAD     D
        XCHG
        LHLD    XL
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    YT
        LXI     D,0-11
        DAD     D
        XCHG
        LHLD    XL
        LXI     B,13
        DAD     B
        MVI     A,OPFRCT
        CALL    XYCMD
        LHLD    YB              ;right: XR-13,YB+11 .. XR,YT-11
        LXI     D,11
        DAD     D
        XCHG
        LHLD    XR
        LXI     B,0-13
        DAD     B
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    YT
        LXI     D,0-11
        DAD     D
        XCHG
        LHLD    XR
        MVI     A,OPFRCT
        JMP     XYCMD
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
; ================= screens 12-21: FIFO scripts =================
;
DEM12:  LXI     H,SCR12
        JMP     RUNSCR
DEM13:  LXI     H,SCR13
        JMP     RUNSCR
DEM14:  LXI     H,SCR14
        JMP     RUNSCR
DEM15:  LXI     H,SCR15
        JMP     RUNSCR
DEM16:  LXI     H,SCR16
        JMP     RUNSCR
DEM17:  LXI     H,SCR17
        JMP     RUNSCR
DEM18:  LXI     H,SCR18
        JMP     RUNSCR
DEM19:  LXI     H,SCR19
        JMP     RUNSCR
DEM20:  LXI     H,SCR20
        JMP     RUNSCR
DEM21:  LXI     H,SCR21
        JMP     RUNSCR
;
SCR12:
        DW      3,8000H,512,384         ;AMOVE 512,384
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      2,0A800H,16             ;CRCL r=16
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      2,0A800H,32             ;CRCL r=32
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      2,0A800H,48             ;CRCL r=48
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      2,0A800H,80             ;CRCL r=80
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      2,0A800H,96             ;CRCL r=96
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      2,0A800H,112            ;CRCL r=112
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      2,0A800H,128            ;CRCL r=128
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      2,0A800H,144            ;CRCL r=144
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      2,0A800H,160            ;CRCL r=160
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      2,0A800H,176            ;CRCL r=176
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      2,0A800H,192            ;CRCL r=192
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      2,0A800H,208            ;CRCL r=208
        DW      3,8000H,812,384         ;AMOVE 812,384
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,09696H          ;WPR CL1 = RED+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,08E8EH          ;WPR CL1 = RED+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,772,534         ;AMOVE 772,534
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,5654            ;WPR CL1 = ORANGE+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,3598            ;WPR CL1 = ORANGE+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,662,644         ;AMOVE 662,644
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,0D6D6H          ;WPR CL1 = YELLOW+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,0CECEH          ;WPR CL1 = YELLOW+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,512,684         ;AMOVE 512,684
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,22102           ;WPR CL1 = GREEN+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,20046           ;WPR CL1 = GREEN+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,362,644         ;AMOVE 362,644
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,30326           ;WPR CL1 = CYAN+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,28270           ;WPR CL1 = CYAN+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,252,534         ;AMOVE 252,534
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,13878           ;WPR CL1 = BLUE+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,11822           ;WPR CL1 = BLUE+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,212,384         ;AMOVE 212,384
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,0B6B6H          ;WPR CL1 = MAGENTA+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,0AEAEH          ;WPR CL1 = MAGENTA+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,252,234         ;AMOVE 252,234
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,09696H          ;WPR CL1 = RED+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,08E8EH          ;WPR CL1 = RED+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,362,124         ;AMOVE 362,124
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,5654            ;WPR CL1 = ORANGE+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,3598            ;WPR CL1 = ORANGE+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,512,84          ;AMOVE 512,84
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,0D6D6H          ;WPR CL1 = YELLOW+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,0CECEH          ;WPR CL1 = YELLOW+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,662,124         ;AMOVE 662,124
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,22102           ;WPR CL1 = GREEN+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,20046           ;WPR CL1 = GREEN+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      3,8000H,772,234         ;AMOVE 772,234
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      2,0A800H,64             ;CRCL r=64
        DW      2,0801H,30326           ;WPR CL1 = CYAN+22
        DW      2,0A800H,44             ;CRCL r=44
        DW      2,0801H,28270           ;WPR CL1 = CYAN+14
        DW      2,0A800H,24             ;CRCL r=24
        DW      0
;
SCR13:
        DW      3,8000H,512,384         ;AMOVE 512,384
        DW      2,0801H,27242           ;WPR CL1 = CYAN+10
        DW      4,0AC00H,8191,72,480    ;ELPS semi-axes 480,45 (a:b = 8191:72)
        DW      2,0801H,28013           ;WPR CL1 = CYAN+13
        DW      4,0AC00H,8191,288,480   ;ELPS semi-axes 480,90 (a:b = 8191:288)
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      4,0AC00H,8191,648,480   ;ELPS semi-axes 480,135 (a:b = 8191:648)
        DW      2,0801H,29555           ;WPR CL1 = CYAN+19
        DW      4,0AC00H,8191,1152,480  ;ELPS semi-axes 480,180 (a:b = 8191:1152)
        DW      2,0801H,30326           ;WPR CL1 = CYAN+22
        DW      4,0AC00H,8191,1800,480  ;ELPS semi-axes 480,225 (a:b = 8191:1800)
        DW      2,0801H,31097           ;WPR CL1 = CYAN+25
        DW      4,0AC00H,8191,2592,480  ;ELPS semi-axes 480,270 (a:b = 8191:2592)
        DW      2,0801H,31868           ;WPR CL1 = CYAN+28
        DW      4,0AC00H,8191,3528,480  ;ELPS semi-axes 480,315 (a:b = 8191:3528)
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      4,0AC00H,8191,4607,480  ;ELPS semi-axes 480,360 (a:b = 8191:4607)
        DW      2,0801H,0AAAAH          ;WPR CL1 = MAGENTA+10
        DW      4,0AC00H,228,8191,60    ;ELPS semi-axes 60,360 (a:b = 228:8191)
        DW      2,0801H,0ADADH          ;WPR CL1 = MAGENTA+13
        DW      4,0AC00H,910,8191,120   ;ELPS semi-axes 120,360 (a:b = 910:8191)
        DW      2,0801H,0B0B0H          ;WPR CL1 = MAGENTA+16
        DW      4,0AC00H,2048,8191,180  ;ELPS semi-axes 180,360 (a:b = 2048:8191)
        DW      2,0801H,0B3B3H          ;WPR CL1 = MAGENTA+19
        DW      4,0AC00H,3640,8191,240  ;ELPS semi-axes 240,360 (a:b = 3640:8191)
        DW      2,0801H,0B6B6H          ;WPR CL1 = MAGENTA+22
        DW      4,0AC00H,5688,8191,300  ;ELPS semi-axes 300,360 (a:b = 5688:8191)
        DW      2,0801H,0B9B9H          ;WPR CL1 = MAGENTA+25
        DW      4,0AC00H,8191,8191,360  ;ELPS semi-axes 360,360 (a:b = 8191:8191)
        DW      2,0801H,0BCBCH          ;WPR CL1 = MAGENTA+28
        DW      4,0AC00H,8191,6018,420  ;ELPS semi-axes 420,360 (a:b = 8191:6018)
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      4,0AC00H,8191,4607,480  ;ELPS semi-axes 480,360 (a:b = 8191:4607)
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      4,0AC00H,8191,4607,120  ;ELPS semi-axes 120,90 (a:b = 8191:4607)
        DW      2,0A800H,20             ;CRCL r=20
        DW      0
;
SCR14:
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      3,8000H,572,430         ;AMOVE 572,430
        DW      5,0B000H,512,430,452,430 ;AARC round 512,430 to 452,430
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      3,8000H,592,430         ;AMOVE 592,430
        DW      5,0B000H,512,430,432,430 ;AARC round 512,430 to 432,430
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,8000H,612,430         ;AMOVE 612,430
        DW      5,0B000H,512,430,412,430 ;AARC round 512,430 to 412,430
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      3,8000H,632,430         ;AMOVE 632,430
        DW      5,0B000H,512,430,392,430 ;AARC round 512,430 to 392,430
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      3,8000H,652,430         ;AMOVE 652,430
        DW      5,0B000H,512,430,372,430 ;AARC round 512,430 to 372,430
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      3,8000H,672,430         ;AMOVE 672,430
        DW      5,0B000H,512,430,352,430 ;AARC round 512,430 to 352,430
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      3,8000H,692,430         ;AMOVE 692,430
        DW      5,0B000H,512,430,332,430 ;AARC round 512,430 to 332,430
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      3,8000H,712,430         ;AMOVE 712,430
        DW      5,0B000H,512,430,312,430 ;AARC round 512,430 to 312,430
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      3,8000H,732,430         ;AMOVE 732,430
        DW      5,0B000H,512,430,292,430 ;AARC round 512,430 to 292,430
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,8000H,752,430         ;AMOVE 752,430
        DW      5,0B000H,512,430,272,430 ;AARC round 512,430 to 272,430
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      3,8000H,772,430         ;AMOVE 772,430
        DW      5,0B000H,512,430,252,430 ;AARC round 512,430 to 252,430
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      3,8000H,792,430         ;AMOVE 792,430
        DW      5,0B000H,512,430,232,430 ;AARC round 512,430 to 232,430
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      3,8000H,812,430         ;AMOVE 812,430
        DW      5,0B000H,512,430,212,430 ;AARC round 512,430 to 212,430
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      3,8000H,832,430         ;AMOVE 832,430
        DW      5,0B000H,512,430,192,430 ;AARC round 512,430 to 192,430
        DW      2,0801H,0EEEEH          ;WPR CL1 = WHITE+14
        DW      3,8000H,552,430         ;AMOVE 552,430
        DW      5,0B100H,512,430,472,430 ;AARC round 512,430 to 472,430 CW
        DW      2,0801H,0F2F2H          ;WPR CL1 = WHITE+18
        DW      3,8000H,577,430         ;AMOVE 577,430
        DW      5,0B100H,512,430,447,430 ;AARC round 512,430 to 447,430 CW
        DW      2,0801H,0F6F6H          ;WPR CL1 = WHITE+22
        DW      3,8000H,602,430         ;AMOVE 602,430
        DW      5,0B100H,512,430,422,430 ;AARC round 512,430 to 422,430 CW
        DW      2,0801H,0FAFAH          ;WPR CL1 = WHITE+26
        DW      3,8000H,627,430         ;AMOVE 627,430
        DW      5,0B100H,512,430,397,430 ;AARC round 512,430 to 397,430 CW
        DW      2,0801H,0FEFEH          ;WPR CL1 = WHITE+30
        DW      3,8000H,652,430         ;AMOVE 652,430
        DW      5,0B100H,512,430,372,430 ;AARC round 512,430 to 372,430 CW
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      3,8000H,32,170          ;AMOVE 32,170
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      5,0B500H,30,0,60,0      ;RARC round +30,0 to +60,0 CW
        DW      5,0B400H,30,0,60,0      ;RARC round +30,0 to +60,0
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,8000H,32,70           ;AMOVE 32,70
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      5,0B400H,20,0,40,0      ;RARC round +20,0 to +40,0
        DW      5,0B500H,20,0,40,0      ;RARC round +20,0 to +40,0 CW
        DW      0
;
SCR15:
        DW      2,0801H,27756           ;WPR CL1 = CYAN+12
        DW      3,8000H,552,420         ;AMOVE 552,420
        DW      7,0B800H,146,8191,512,420,472,420 ;AEARC 40:300 round 512,420 to 472,420
        DW      2,0801H,28270           ;WPR CL1 = CYAN+14
        DW      3,8000H,592,420         ;AMOVE 592,420
        DW      7,0B800H,582,8191,512,420,432,420 ;AEARC 80:300 round 512,420 to 432,420
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,632,420         ;AMOVE 632,420
        DW      7,0B800H,1311,8191,512,420,392,420 ;AEARC 120:300 round 512,420 to 392,420
        DW      2,0801H,29298           ;WPR CL1 = CYAN+18
        DW      3,8000H,672,420         ;AMOVE 672,420
        DW      7,0B800H,2330,8191,512,420,352,420 ;AEARC 160:300 round 512,420 to 352,420
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,712,420         ;AMOVE 712,420
        DW      7,0B800H,3640,8191,512,420,312,420 ;AEARC 200:300 round 512,420 to 312,420
        DW      2,0801H,30326           ;WPR CL1 = CYAN+22
        DW      3,8000H,752,420         ;AMOVE 752,420
        DW      7,0B800H,5242,8191,512,420,272,420 ;AEARC 240:300 round 512,420 to 272,420
        DW      2,0801H,30840           ;WPR CL1 = CYAN+24
        DW      3,8000H,792,420         ;AMOVE 792,420
        DW      7,0B800H,7135,8191,512,420,232,420 ;AEARC 280:300 round 512,420 to 232,420
        DW      2,0801H,31354           ;WPR CL1 = CYAN+26
        DW      3,8000H,832,420         ;AMOVE 832,420
        DW      7,0B800H,8191,7199,512,420,192,420 ;AEARC 320:300 round 512,420 to 192,420
        DW      2,0801H,31868           ;WPR CL1 = CYAN+28
        DW      3,8000H,872,420         ;AMOVE 872,420
        DW      7,0B800H,8191,5688,512,420,152,420 ;AEARC 360:300 round 512,420 to 152,420
        DW      2,0801H,32382           ;WPR CL1 = CYAN+30
        DW      3,8000H,912,420         ;AMOVE 912,420
        DW      7,0B800H,8191,4607,512,420,112,420 ;AEARC 400:300 round 512,420 to 112,420
        DW      2,0801H,3084            ;WPR CL1 = ORANGE+12
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,38,512,420,952,420 ;AEARC 440:30 round 512,420 to 952,420 CW
        DW      2,0801H,3598            ;WPR CL1 = ORANGE+14
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,152,512,420,952,420 ;AEARC 440:60 round 512,420 to 952,420 CW
        DW      2,0801H,4112            ;WPR CL1 = ORANGE+16
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,343,512,420,952,420 ;AEARC 440:90 round 512,420 to 952,420 CW
        DW      2,0801H,4626            ;WPR CL1 = ORANGE+18
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,609,512,420,952,420 ;AEARC 440:120 round 512,420 to 952,420 CW
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,952,512,420,952,420 ;AEARC 440:150 round 512,420 to 952,420 CW
        DW      2,0801H,5654            ;WPR CL1 = ORANGE+22
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,1371,512,420,952,420 ;AEARC 440:180 round 512,420 to 952,420 CW
        DW      2,0801H,6168            ;WPR CL1 = ORANGE+24
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,1866,512,420,952,420 ;AEARC 440:210 round 512,420 to 952,420 CW
        DW      2,0801H,6682            ;WPR CL1 = ORANGE+26
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,2437,512,420,952,420 ;AEARC 440:240 round 512,420 to 952,420 CW
        DW      2,0801H,7196            ;WPR CL1 = ORANGE+28
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,3084,512,420,952,420 ;AEARC 440:270 round 512,420 to 952,420 CW
        DW      2,0801H,7710            ;WPR CL1 = ORANGE+30
        DW      3,8000H,72,420          ;AMOVE 72,420
        DW      7,0B900H,8191,3808,512,420,952,420 ;AEARC 440:300 round 512,420 to 952,420 CW
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      3,8000H,40,40           ;AMOVE 40,40
        DW      7,0BD00H,1083,8191,120,0,240,0 ;REARC 120:330 round +120,0 to +240,0 CW
        DW      7,0BD00H,1722,8191,94,0,188,0 ;REARC 94:205 round +94,0 to +188,0 CW
        DW      7,0BD00H,2706,8191,73,0,146,0 ;REARC 73:127 round +73,0 to +146,0 CW
        DW      7,0BD00H,4264,8191,57,0,114,0 ;REARC 57:79 round +57,0 to +114,0 CW
        DW      7,0BD00H,6605,8191,44,0,88,0 ;REARC 44:49 round +44,0 to +88,0 CW
        DW      7,0BD00H,8191,6018,35,0,70,0 ;REARC 35:30 round +35,0 to +70,0 CW
        DW      7,0BD00H,8191,4056,27,0,54,0 ;REARC 27:19 round +27,0 to +54,0 CW
        DW      7,0BD00H,8191,2675,21,0,42,0 ;REARC 21:12 round +21,0 to +42,0 CW
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,160,387         ;AMOVE 160,387
        DW      2,0A800H,16             ;CRCL r=16
        DW      0
;
SCR16:
        DW      2,0803H,0FFFFH          ;WPR EDG = WHITE+31
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,220,540         ;AMOVE 220,540
        DW      2,0A800H,170            ;CRCL r=170
        DW      3,8000H,220,700         ;AMOVE 220,700
        DW      10,0A000H,4,126,411,372,589,68,589,314 ;APLG 5 points
        DW      411
        DW      3,8000H,600,560         ;AMOVE 600,560
        DW      2,0A800H,120            ;CRCL r=120
        DW      3,8000H,780,560         ;AMOVE 780,560
        DW      2,0A800H,120            ;CRCL r=120
        DW      3,8000H,690,405         ;AMOVE 690,405
        DW      2,0A800H,120            ;CRCL r=120
        DW      3,8000H,360,175         ;AMOVE 360,175
        DW      12,0A000H,5,290,296,150,296,80,175,150 ;APLG 6 points
        DW      54,290,54
        DW      2,0801H,10794           ;WPR CL1 = BLUE+10
        DW      3,8000H,560,40          ;AMOVE 560,40
        DW      3,0C000H,960,260        ;AFRCT 960,260
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      3,8000H,640,110         ;AMOVE 640,110
        DW      2,0A800H,36             ;CRCL r=36
        DW      3,8000H,760,110         ;AMOVE 760,110
        DW      2,0A800H,36             ;CRCL r=36
        DW      3,8000H,880,110         ;AMOVE 880,110
        DW      2,0A800H,36             ;CRCL r=36
        DW      3,8000H,640,200         ;AMOVE 640,200
        DW      2,0A800H,36             ;CRCL r=36
        DW      3,8000H,760,200         ;AMOVE 760,200
        DW      2,0A800H,36             ;CRCL r=36
        DW      3,8000H,880,200         ;AMOVE 880,200
        DW      2,0A800H,36             ;CRCL r=36
        DW      2,0800H,09696H          ;WPR CL0 = RED+22
        DW      2,0801H,09696H          ;WPR CL1 = RED+22
        DW      3,8000H,220,540         ;AMOVE 220,540
        DW      1,0C800H                ;PAINT
        DW      2,0800H,0DFDFH          ;WPR CL0 = YELLOW+31
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,8000H,220,660         ;AMOVE 220,660
        DW      1,0C800H                ;PAINT
        DW      3,8000H,106,577         ;AMOVE 106,577
        DW      1,0C800H                ;PAINT
        DW      3,8000H,149,443         ;AMOVE 149,443
        DW      1,0C800H                ;PAINT
        DW      3,8000H,291,443         ;AMOVE 291,443
        DW      1,0C800H                ;PAINT
        DW      3,8000H,334,577         ;AMOVE 334,577
        DW      1,0C800H                ;PAINT
        DW      2,0800H,12850           ;WPR CL0 = BLUE+18
        DW      2,0801H,12850           ;WPR CL1 = BLUE+18
        DW      3,8000H,220,420         ;AMOVE 220,420
        DW      1,0C800H                ;PAINT
        DW      2,0800H,09494H          ;WPR CL0 = RED+20
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,572,577         ;AMOVE 572,577
        DW      1,0C800H                ;PAINT
        DW      2,0800H,21588           ;WPR CL0 = GREEN+20
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,808,577         ;AMOVE 808,577
        DW      1,0C800H                ;PAINT
        DW      2,0800H,14906           ;WPR CL0 = BLUE+26
        DW      2,0801H,14906           ;WPR CL1 = BLUE+26
        DW      3,8000H,690,373         ;AMOVE 690,373
        DW      1,0C800H                ;PAINT
        DW      2,0800H,0D4D4H          ;WPR CL0 = YELLOW+20
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,690,559         ;AMOVE 690,559
        DW      1,0C800H                ;PAINT
        DW      2,0800H,0B4B4H          ;WPR CL0 = MAGENTA+20
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,646,483         ;AMOVE 646,483
        DW      1,0C800H                ;PAINT
        DW      2,0800H,29812           ;WPR CL0 = CYAN+20
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,734,483         ;AMOVE 734,483
        DW      1,0C800H                ;PAINT
        DW      2,0800H,0FAFAH          ;WPR CL0 = WHITE+26
        DW      2,0801H,0FAFAH          ;WPR CL1 = WHITE+26
        DW      3,8000H,690,509         ;AMOVE 690,509
        DW      1,0C800H                ;PAINT
        DW      18,1800H,32,0,0FFFEH,0FFFEH,0FFFEH ;WPTN bricks
        DW      0FFFEH,0FFFEH,0FFFEH,0FFFEH,0,0FEFFH
        DW      0FEFFH,0FEFFH,0FEFFH,0FEFFH,0FEFFH
        DW      0FEFFH
        DW      2,0801H,6682            ;WPR CL1 = ORANGE+26
        DW      2,0800H,2056            ;WPR CL0 = ORANGE+8
        DW      3,8000H,220,175         ;AMOVE 220,175
        DW      1,0C800H                ;PAINT
        DW      18,1800H,32,0FFFFH,0FFFFH,0FFFFH ;WPTN all ones (solid)
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH,0FFFFH
        DW      0FFFFH,0FFFFH,0FFFFH,0FFFFH,0FFFFH
        DW      0FFFFH,0FFFFH,0FFFFH
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F0F0H          ;WPR PRC: scan end 15,15, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      2,0803H,10794           ;WPR EDG = BLUE+10
        DW      2,0800H,0D0D0H          ;WPR CL0 = YELLOW+16
        DW      2,0801H,0D0D0H          ;WPR CL1 = YELLOW+16
        DW      3,8000H,566,46          ;AMOVE 566,46
        DW      1,0C900H                ;PAINT E=1 (flood)
        DW      0
;
SCR17:
        DW      18,1800H,32,0,6,6,6,6,6,6,6,1022,1022 ;WPTN 16x16 letter F
        DW      6,6,6,16382,16382,0
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      2,0800H,08585H          ;WPR CL0 = RED+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F0F0H          ;WPR PRC: scan end 15,15, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,30,724          ;AMOVE 30,724
        DW      2,0D000H,3855           ;PTN 16x16 dir 0
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      2,0800H,1285            ;WPR CL0 = ORANGE+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F1F1H          ;WPR PRC: scan end 15,15, zoom x2 y2
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,70,708          ;AMOVE 70,708
        DW      2,0D000H,7967           ;PTN 32x32 dir 0
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      2,0800H,0C5C5H          ;WPR CL0 = YELLOW+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,126,692         ;AMOVE 126,692
        DW      2,0D000H,12079          ;PTN 48x48 dir 0
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      2,0800H,17733           ;WPR CL0 = GREEN+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,198,676         ;AMOVE 198,676
        DW      2,0D000H,16191          ;PTN 64x64 dir 0
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      2,0800H,25957           ;WPR CL0 = CYAN+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F4F4H          ;WPR PRC: scan end 15,15, zoom x5 y5
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,286,660         ;AMOVE 286,660
        DW      2,0D000H,20303          ;PTN 80x80 dir 0
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      2,0800H,08585H          ;WPR CL0 = RED+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,602,400         ;AMOVE 602,400
        DW      2,0D000H,16191          ;PTN 64x64 dir 0
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      2,0800H,1285            ;WPR CL0 = ORANGE+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,576,464         ;AMOVE 576,464
        DW      2,0D100H,16191          ;PTN 64x64 dir 1
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      2,0800H,0C5C5H          ;WPR CL0 = YELLOW+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,512,490         ;AMOVE 512,490
        DW      2,0D200H,16191          ;PTN 64x64 dir 2
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      2,0800H,17733           ;WPR CL0 = GREEN+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,448,464         ;AMOVE 448,464
        DW      2,0D300H,16191          ;PTN 64x64 dir 3
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      2,0800H,25957           ;WPR CL0 = CYAN+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,422,400         ;AMOVE 422,400
        DW      2,0D400H,16191          ;PTN 64x64 dir 4
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      2,0800H,9509            ;WPR CL0 = BLUE+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,448,336         ;AMOVE 448,336
        DW      2,0D500H,16191          ;PTN 64x64 dir 5
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      2,0800H,0A5A5H          ;WPR CL0 = MAGENTA+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,512,310         ;AMOVE 512,310
        DW      2,0D600H,16191          ;PTN 64x64 dir 6
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      2,0800H,0E5E5H          ;WPR CL0 = WHITE+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,576,336         ;AMOVE 576,336
        DW      2,0D700H,16191          ;PTN 64x64 dir 7
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      2,0800H,08585H          ;WPR CL0 = RED+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,16,20           ;AMOVE 16,20
        DW      2,0D800H,12079          ;PTN 48x48 dir 0 slanted
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      2,0800H,1285            ;WPR CL0 = ORANGE+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,142,20          ;AMOVE 142,20
        DW      2,0D900H,12079          ;PTN 48x48 dir 1 slanted
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      2,0800H,0C5C5H          ;WPR CL0 = YELLOW+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,315,20          ;AMOVE 315,20
        DW      2,0DA00H,12079          ;PTN 48x48 dir 2 slanted
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      2,0800H,17733           ;WPR CL0 = GREEN+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,488,20          ;AMOVE 488,20
        DW      2,0DB00H,12079          ;PTN 48x48 dir 3 slanted
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      2,0800H,25957           ;WPR CL0 = CYAN+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,614,67          ;AMOVE 614,67
        DW      2,0DC00H,12079          ;PTN 48x48 dir 4 slanted
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      2,0800H,9509            ;WPR CL0 = BLUE+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,693,114         ;AMOVE 693,114
        DW      2,0DD00H,12079          ;PTN 48x48 dir 5 slanted
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      2,0800H,0A5A5H          ;WPR CL0 = MAGENTA+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,772,114         ;AMOVE 772,114
        DW      2,0DE00H,12079          ;PTN 48x48 dir 6 slanted
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      2,0800H,0E5E5H          ;WPR CL0 = WHITE+5
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,898,67          ;AMOVE 898,67
        DW      2,0DF00H,12079          ;PTN 48x48 dir 7 slanted
        DW      0
;
SCR18:
        DW      2,0801H,9766            ;WPR CL1 = BLUE+6
        DW      3,8000H,40,600          ;AMOVE 40,600
        DW      3,0C000H,135,695        ;AFRCT 135,695
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      3,8000H,52,612          ;AMOVE 52,612
        DW      3,0C000H,67,683         ;AFRCT 67,683
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,8000H,52,668          ;AMOVE 52,668
        DW      3,0C000H,123,683        ;AFRCT 123,683
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      3,8000H,52,640          ;AMOVE 52,640
        DW      3,0C000H,103,651        ;AFRCT 103,651
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      3,8000H,112,620         ;AMOVE 112,620
        DW      2,0A800H,10             ;CRCL r=10
        DW      2,0A800H,5              ;CRCL r=5
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,40,600          ;AMOVE 40,600
        DW      3,9000H,135,695         ;ARCT 135,695
        DW      3,8000H,200,600         ;AMOVE 200,600
        DW      5,0E000H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 0
        DW      3,8000H,400,695         ;AMOVE 400,695
        DW      5,0E100H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 1
        DW      3,8000H,695,600         ;AMOVE 695,600
        DW      5,0E200H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 2
        DW      3,8000H,895,695         ;AMOVE 895,695
        DW      5,0E300H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 3
        DW      3,8000H,200,440         ;AMOVE 200,440
        DW      5,0E400H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 4
        DW      3,8000H,400,535         ;AMOVE 400,535
        DW      5,0E500H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 5
        DW      3,8000H,695,440         ;AMOVE 695,440
        DW      5,0E600H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 6
        DW      3,8000H,895,535         ;AMOVE 895,535
        DW      5,0E700H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 7
        DW      3,8000H,40,360          ;AMOVE 40,360
        DW      5,0E500H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      5,0F500H,0FFA0H,0FFA1H,95,95 ;RGCPY from -96,-95 size 96,96, transform 5
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,40,40           ;AMOVE 40,40
        DW      3,0C000H,63,200         ;AFRCT 63,200
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,64,40           ;AMOVE 64,40
        DW      3,0C000H,87,200         ;AFRCT 87,200
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,88,40           ;AMOVE 88,40
        DW      3,0C000H,111,200        ;AFRCT 111,200
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,112,40          ;AMOVE 112,40
        DW      3,0C000H,135,200        ;AFRCT 135,200
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,136,40          ;AMOVE 136,40
        DW      3,0C000H,159,200        ;AFRCT 159,200
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,160,40          ;AMOVE 160,40
        DW      3,0C000H,183,200        ;AFRCT 183,200
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,184,40          ;AMOVE 184,40
        DW      3,0C000H,207,200        ;AFRCT 207,200
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,208,40          ;AMOVE 208,40
        DW      3,0C000H,231,200        ;AFRCT 231,200
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,232,40          ;AMOVE 232,40
        DW      3,0C000H,255,200        ;AFRCT 255,200
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,256,40          ;AMOVE 256,40
        DW      3,0C000H,279,200        ;AFRCT 279,200
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,280,40          ;AMOVE 280,40
        DW      3,0C000H,303,200        ;AFRCT 303,200
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,304,40          ;AMOVE 304,40
        DW      3,0C000H,327,200        ;AFRCT 327,200
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,328,40          ;AMOVE 328,40
        DW      3,0C000H,351,200        ;AFRCT 351,200
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,352,40          ;AMOVE 352,40
        DW      3,0C000H,375,200        ;AFRCT 375,200
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,376,40          ;AMOVE 376,40
        DW      3,0C000H,399,200        ;AFRCT 399,200
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,400,40          ;AMOVE 400,40
        DW      3,0C000H,423,200        ;AFRCT 423,200
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,424,40          ;AMOVE 424,40
        DW      3,0C000H,447,200        ;AFRCT 447,200
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,448,40          ;AMOVE 448,40
        DW      3,0C000H,471,200        ;AFRCT 471,200
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,472,40          ;AMOVE 472,40
        DW      3,0C000H,495,200        ;AFRCT 495,200
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,496,40          ;AMOVE 496,40
        DW      3,0C000H,519,200        ;AFRCT 519,200
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,520,40          ;AMOVE 520,40
        DW      3,0C000H,543,200        ;AFRCT 543,200
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,544,40          ;AMOVE 544,40
        DW      3,0C000H,567,200        ;AFRCT 567,200
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,568,40          ;AMOVE 568,40
        DW      3,0C000H,591,200        ;AFRCT 591,200
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,592,40          ;AMOVE 592,40
        DW      3,0C000H,615,200        ;AFRCT 615,200
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,616,40          ;AMOVE 616,40
        DW      3,0C000H,639,200        ;AFRCT 639,200
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,640,40          ;AMOVE 640,40
        DW      3,0C000H,663,200        ;AFRCT 663,200
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,664,40          ;AMOVE 664,40
        DW      3,0C000H,687,200        ;AFRCT 687,200
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,688,40          ;AMOVE 688,40
        DW      3,0C000H,711,200        ;AFRCT 711,200
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,712,40          ;AMOVE 712,40
        DW      3,0C000H,735,200        ;AFRCT 735,200
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,736,40          ;AMOVE 736,40
        DW      3,0C000H,759,200        ;AFRCT 759,200
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,760,40          ;AMOVE 760,40
        DW      3,0C000H,783,200        ;AFRCT 783,200
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,784,40          ;AMOVE 784,40
        DW      3,0C000H,807,200        ;AFRCT 807,200
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,808,40          ;AMOVE 808,40
        DW      3,0C000H,831,200        ;AFRCT 831,200
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,832,40          ;AMOVE 832,40
        DW      3,0C000H,855,200        ;AFRCT 855,200
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,856,40          ;AMOVE 856,40
        DW      3,0C000H,879,200        ;AFRCT 879,200
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,880,40          ;AMOVE 880,40
        DW      3,0C000H,903,200        ;AFRCT 903,200
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,904,40          ;AMOVE 904,40
        DW      3,0C000H,927,200        ;AFRCT 927,200
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,928,40          ;AMOVE 928,40
        DW      3,0C000H,951,200        ;AFRCT 951,200
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,952,40          ;AMOVE 952,40
        DW      3,0C000H,975,200        ;AFRCT 975,200
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,976,40          ;AMOVE 976,40
        DW      3,0C000H,999,200        ;AFRCT 999,200
        DW      3,8000H,100,72          ;AMOVE 100,72
        DW      5,0E000H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 0
        DW      3,8000H,330,72          ;AMOVE 330,72
        DW      5,0E001H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 0 OR
        DW      3,8000H,560,72          ;AMOVE 560,72
        DW      5,0E002H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 0 AND
        DW      3,8000H,790,72          ;AMOVE 790,72
        DW      5,0E003H,40,600,95,95   ;AGCPY from 40,600 size 96,96, transform 0 EOR
        DW      0
;
SCR19:
        DW      2,0802H,0B4B4H          ;WPR CCMP = MAGENTA+20
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,16,400          ;AMOVE 16,400
        DW      3,0C000H,44,735         ;AFRCT 44,735
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,45,400          ;AMOVE 45,400
        DW      3,0C000H,73,735         ;AFRCT 73,735
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,74,400          ;AMOVE 74,400
        DW      3,0C000H,102,735        ;AFRCT 102,735
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,103,400         ;AMOVE 103,400
        DW      3,0C000H,131,735        ;AFRCT 131,735
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,132,400         ;AMOVE 132,400
        DW      3,0C000H,160,735        ;AFRCT 160,735
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,161,400         ;AMOVE 161,400
        DW      3,0C000H,189,735        ;AFRCT 189,735
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,190,400         ;AMOVE 190,400
        DW      3,0C000H,218,735        ;AFRCT 218,735
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,219,400         ;AMOVE 219,400
        DW      3,0C000H,247,735        ;AFRCT 247,735
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,14,398          ;AMOVE 14,398
        DW      3,9000H,249,737         ;ARCT 249,737
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,46,450          ;AMOVE 46,450
        DW      3,0C000H,221,685        ;AFRCT 221,685
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,268,400         ;AMOVE 268,400
        DW      3,0C000H,296,735        ;AFRCT 296,735
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,297,400         ;AMOVE 297,400
        DW      3,0C000H,325,735        ;AFRCT 325,735
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,326,400         ;AMOVE 326,400
        DW      3,0C000H,354,735        ;AFRCT 354,735
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,355,400         ;AMOVE 355,400
        DW      3,0C000H,383,735        ;AFRCT 383,735
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,384,400         ;AMOVE 384,400
        DW      3,0C000H,412,735        ;AFRCT 412,735
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,413,400         ;AMOVE 413,400
        DW      3,0C000H,441,735        ;AFRCT 441,735
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,442,400         ;AMOVE 442,400
        DW      3,0C000H,470,735        ;AFRCT 470,735
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,471,400         ;AMOVE 471,400
        DW      3,0C000H,499,735        ;AFRCT 499,735
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,266,398         ;AMOVE 266,398
        DW      3,9000H,501,737         ;ARCT 501,737
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,298,450         ;AMOVE 298,450
        DW      3,0C001H,473,685        ;AFRCT 473,685 OR
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,520,400         ;AMOVE 520,400
        DW      3,0C000H,548,735        ;AFRCT 548,735
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,549,400         ;AMOVE 549,400
        DW      3,0C000H,577,735        ;AFRCT 577,735
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,578,400         ;AMOVE 578,400
        DW      3,0C000H,606,735        ;AFRCT 606,735
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,607,400         ;AMOVE 607,400
        DW      3,0C000H,635,735        ;AFRCT 635,735
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,636,400         ;AMOVE 636,400
        DW      3,0C000H,664,735        ;AFRCT 664,735
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,665,400         ;AMOVE 665,400
        DW      3,0C000H,693,735        ;AFRCT 693,735
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,694,400         ;AMOVE 694,400
        DW      3,0C000H,722,735        ;AFRCT 722,735
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,723,400         ;AMOVE 723,400
        DW      3,0C000H,751,735        ;AFRCT 751,735
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,518,398         ;AMOVE 518,398
        DW      3,9000H,753,737         ;ARCT 753,737
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,550,450         ;AMOVE 550,450
        DW      3,0C002H,725,685        ;AFRCT 725,685 AND
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,772,400         ;AMOVE 772,400
        DW      3,0C000H,800,735        ;AFRCT 800,735
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,801,400         ;AMOVE 801,400
        DW      3,0C000H,829,735        ;AFRCT 829,735
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,830,400         ;AMOVE 830,400
        DW      3,0C000H,858,735        ;AFRCT 858,735
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,859,400         ;AMOVE 859,400
        DW      3,0C000H,887,735        ;AFRCT 887,735
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,888,400         ;AMOVE 888,400
        DW      3,0C000H,916,735        ;AFRCT 916,735
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,917,400         ;AMOVE 917,400
        DW      3,0C000H,945,735        ;AFRCT 945,735
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,946,400         ;AMOVE 946,400
        DW      3,0C000H,974,735        ;AFRCT 974,735
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,975,400         ;AMOVE 975,400
        DW      3,0C000H,1003,735       ;AFRCT 1003,735
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,770,398         ;AMOVE 770,398
        DW      3,9000H,1005,737        ;ARCT 1005,737
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,792,440         ;AMOVE 792,440
        DW      3,0C003H,922,620        ;AFRCT 922,620 EOR
        DW      3,8000H,858,516         ;AMOVE 858,516
        DW      3,0C003H,988,696        ;AFRCT 988,696 EOR
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,16,24           ;AMOVE 16,24
        DW      3,0C000H,44,359         ;AFRCT 44,359
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,45,24           ;AMOVE 45,24
        DW      3,0C000H,73,359         ;AFRCT 73,359
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,74,24           ;AMOVE 74,24
        DW      3,0C000H,102,359        ;AFRCT 102,359
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,103,24          ;AMOVE 103,24
        DW      3,0C000H,131,359        ;AFRCT 131,359
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,132,24          ;AMOVE 132,24
        DW      3,0C000H,160,359        ;AFRCT 160,359
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,161,24          ;AMOVE 161,24
        DW      3,0C000H,189,359        ;AFRCT 189,359
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,190,24          ;AMOVE 190,24
        DW      3,0C000H,218,359        ;AFRCT 218,359
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,219,24          ;AMOVE 219,24
        DW      3,0C000H,247,359        ;AFRCT 247,359
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,14,22           ;AMOVE 14,22
        DW      3,9000H,249,361         ;ARCT 249,361
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,46,74           ;AMOVE 46,74
        DW      3,0C004H,221,309        ;AFRCT 221,309 EQ
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,268,24          ;AMOVE 268,24
        DW      3,0C000H,296,359        ;AFRCT 296,359
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,297,24          ;AMOVE 297,24
        DW      3,0C000H,325,359        ;AFRCT 325,359
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,326,24          ;AMOVE 326,24
        DW      3,0C000H,354,359        ;AFRCT 354,359
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,355,24          ;AMOVE 355,24
        DW      3,0C000H,383,359        ;AFRCT 383,359
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,384,24          ;AMOVE 384,24
        DW      3,0C000H,412,359        ;AFRCT 412,359
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,413,24          ;AMOVE 413,24
        DW      3,0C000H,441,359        ;AFRCT 441,359
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,442,24          ;AMOVE 442,24
        DW      3,0C000H,470,359        ;AFRCT 470,359
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,471,24          ;AMOVE 471,24
        DW      3,0C000H,499,359        ;AFRCT 499,359
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,266,22          ;AMOVE 266,22
        DW      3,9000H,501,361         ;ARCT 501,361
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,298,74          ;AMOVE 298,74
        DW      3,0C005H,473,309        ;AFRCT 473,309 NE
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,520,24          ;AMOVE 520,24
        DW      3,0C000H,548,359        ;AFRCT 548,359
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,549,24          ;AMOVE 549,24
        DW      3,0C000H,577,359        ;AFRCT 577,359
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,578,24          ;AMOVE 578,24
        DW      3,0C000H,606,359        ;AFRCT 606,359
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,607,24          ;AMOVE 607,24
        DW      3,0C000H,635,359        ;AFRCT 635,359
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,636,24          ;AMOVE 636,24
        DW      3,0C000H,664,359        ;AFRCT 664,359
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,665,24          ;AMOVE 665,24
        DW      3,0C000H,693,359        ;AFRCT 693,359
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,694,24          ;AMOVE 694,24
        DW      3,0C000H,722,359        ;AFRCT 722,359
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,723,24          ;AMOVE 723,24
        DW      3,0C000H,751,359        ;AFRCT 751,359
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,518,22          ;AMOVE 518,22
        DW      3,9000H,753,361         ;ARCT 753,361
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,550,74          ;AMOVE 550,74
        DW      3,0C006H,725,309        ;AFRCT 725,309 LT
        DW      2,0801H,5140            ;WPR CL1 = ORANGE+20
        DW      3,8000H,772,24          ;AMOVE 772,24
        DW      3,0C000H,800,359        ;AFRCT 800,359
        DW      2,0801H,13364           ;WPR CL1 = BLUE+20
        DW      3,8000H,801,24          ;AMOVE 801,24
        DW      3,0C000H,829,359        ;AFRCT 829,359
        DW      2,0801H,21588           ;WPR CL1 = GREEN+20
        DW      3,8000H,830,24          ;AMOVE 830,24
        DW      3,0C000H,858,359        ;AFRCT 858,359
        DW      2,0801H,29812           ;WPR CL1 = CYAN+20
        DW      3,8000H,859,24          ;AMOVE 859,24
        DW      3,0C000H,887,359        ;AFRCT 887,359
        DW      2,0801H,09494H          ;WPR CL1 = RED+20
        DW      3,8000H,888,24          ;AMOVE 888,24
        DW      3,0C000H,916,359        ;AFRCT 916,359
        DW      2,0801H,0B4B4H          ;WPR CL1 = MAGENTA+20
        DW      3,8000H,917,24          ;AMOVE 917,24
        DW      3,0C000H,945,359        ;AFRCT 945,359
        DW      2,0801H,0D4D4H          ;WPR CL1 = YELLOW+20
        DW      3,8000H,946,24          ;AMOVE 946,24
        DW      3,0C000H,974,359        ;AFRCT 974,359
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,975,24          ;AMOVE 975,24
        DW      3,0C000H,1003,359       ;AFRCT 1003,359
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,770,22          ;AMOVE 770,22
        DW      3,9000H,1005,361        ;ARCT 1005,361
        DW      2,0801H,28784           ;WPR CL1 = CYAN+16
        DW      3,8000H,802,74          ;AMOVE 802,74
        DW      3,0C007H,977,309        ;AFRCT 977,309 GT
        DW      0
;
SCR20:
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,14,398          ;AMOVE 14,398
        DW      3,9000H,251,737         ;ARCT 251,737
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,266,398         ;AMOVE 266,398
        DW      3,9000H,503,737         ;ARCT 503,737
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,518,398         ;AMOVE 518,398
        DW      3,9000H,755,737         ;ARCT 755,737
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,8000H,770,398         ;AMOVE 770,398
        DW      3,9000H,1007,737        ;ARCT 1007,737
        DW      18,1800H,32,0,0FFFEH,0FFFEH,0FFFEH ;WPTN bricks
        DW      0FFFEH,0FFFEH,0FFFEH,0FFFEH,0,0FEFFH
        DW      0FEFFH,0FEFFH,0FEFFH,0FEFFH,0FEFFH
        DW      0FEFFH
        DW      2,0801H,09696H          ;WPR CL1 = RED+22
        DW      2,0800H,0ECECH          ;WPR CL0 = WHITE+12
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,16,400          ;AMOVE 16,400
        DW      3,0C000H,249,735        ;AFRCT 249,735
        DW      2,0801H,09898H          ;WPR CL1 = RED+24
        DW      3,8000H,268,400         ;AMOVE 268,400
        DW      3,0C000H,501,441        ;AFRCT 501,441
        DW      2,0801H,6168            ;WPR CL1 = ORANGE+24
        DW      3,8000H,268,442         ;AMOVE 268,442
        DW      3,0C000H,501,483        ;AFRCT 501,483
        DW      2,0801H,0D8D8H          ;WPR CL1 = YELLOW+24
        DW      3,8000H,268,484         ;AMOVE 268,484
        DW      3,0C000H,501,525        ;AFRCT 501,525
        DW      2,0801H,22616           ;WPR CL1 = GREEN+24
        DW      3,8000H,268,526         ;AMOVE 268,526
        DW      3,0C000H,501,567        ;AFRCT 501,567
        DW      2,0801H,30840           ;WPR CL1 = CYAN+24
        DW      3,8000H,268,568         ;AMOVE 268,568
        DW      3,0C000H,501,609        ;AFRCT 501,609
        DW      2,0801H,14392           ;WPR CL1 = BLUE+24
        DW      3,8000H,268,610         ;AMOVE 268,610
        DW      3,0C000H,501,651        ;AFRCT 501,651
        DW      2,0801H,0B8B8H          ;WPR CL1 = MAGENTA+24
        DW      3,8000H,268,652         ;AMOVE 268,652
        DW      3,0C000H,501,693        ;AFRCT 501,693
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,268,694         ;AMOVE 268,694
        DW      3,0C000H,501,735        ;AFRCT 501,735
        DW      2,0801H,09898H          ;WPR CL1 = RED+24
        DW      3,8000H,520,400         ;AMOVE 520,400
        DW      3,0C000H,753,441        ;AFRCT 753,441
        DW      2,0801H,6168            ;WPR CL1 = ORANGE+24
        DW      3,8000H,520,442         ;AMOVE 520,442
        DW      3,0C000H,753,483        ;AFRCT 753,483
        DW      2,0801H,0D8D8H          ;WPR CL1 = YELLOW+24
        DW      3,8000H,520,484         ;AMOVE 520,484
        DW      3,0C000H,753,525        ;AFRCT 753,525
        DW      2,0801H,22616           ;WPR CL1 = GREEN+24
        DW      3,8000H,520,526         ;AMOVE 520,526
        DW      3,0C000H,753,567        ;AFRCT 753,567
        DW      2,0801H,30840           ;WPR CL1 = CYAN+24
        DW      3,8000H,520,568         ;AMOVE 520,568
        DW      3,0C000H,753,609        ;AFRCT 753,609
        DW      2,0801H,14392           ;WPR CL1 = BLUE+24
        DW      3,8000H,520,610         ;AMOVE 520,610
        DW      3,0C000H,753,651        ;AFRCT 753,651
        DW      2,0801H,0B8B8H          ;WPR CL1 = MAGENTA+24
        DW      3,8000H,520,652         ;AMOVE 520,652
        DW      3,0C000H,753,693        ;AFRCT 753,693
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,520,694         ;AMOVE 520,694
        DW      3,0C000H,753,735        ;AFRCT 753,735
        DW      18,1800H,32,771,1542,3084,6168,12336 ;WPTN diagonal hatch
        DW      24672,0C0C0H,08181H,771,1542,3084,6168
        DW      12336,24672,0C0C0H,08181H
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,268,400         ;AMOVE 268,400
        DW      3,0C008H,501,735        ;AFRCT 501,735 CMCL1
        DW      2,0800H,8995            ;WPR CL0 = BLUE+3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,520,400         ;AMOVE 520,400
        DW      3,0C010H,753,735        ;AFRCT 753,735 CMCL0
        DW      18,1800H,32,09F9FH,09898H,09191H ;WPTN 4x4 color tile
        DW      08A8AH,0DFDFH,0D8D8H,0D1D1H,0CACAH
        DW      24415,22616,20817,19018,16191,14392
        DW      12593,10794
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F7F7H          ;WPR PRC: scan end 15,15, zoom x8 y8
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,772,400         ;AMOVE 772,400
        DW      3,0C018H,1005,735       ;AFRCT 1005,735 CMPRAM
        DW      2,0800H,0               ;WPR CL0 = ORANGE+0
        DW      2,0801H,09F9FH          ;WPR CL1 = RED+31
        DW      3,1800H,2,4095          ;WPTN line style long dash
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,240             ;WPR PRC: scan end 15,0, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,360          ;AMOVE 20,360
        DW      3,8808H,376,360         ;ALINE 376,360 CMCL1
        DW      2,0801H,7967            ;WPR CL1 = ORANGE+31
        DW      3,1800H,2,255           ;WPTN line style dash
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,240             ;WPR PRC: scan end 15,0, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,316          ;AMOVE 20,316
        DW      3,8808H,376,316         ;ALINE 376,316 CMCL1
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,1800H,2,13107         ;WPTN line style short dash
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,240             ;WPR PRC: scan end 15,0, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,272          ;AMOVE 20,272
        DW      3,8808H,376,272         ;ALINE 376,272 CMCL1
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      3,1800H,2,21845         ;WPTN line style dots
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,240             ;WPR PRC: scan end 15,0, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,228          ;AMOVE 20,228
        DW      3,8808H,376,228         ;ALINE 376,228 CMCL1
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      3,1800H,2,6399          ;WPTN line style dash dot
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,240             ;WPR PRC: scan end 15,0, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,184          ;AMOVE 20,184
        DW      3,8808H,376,184         ;ALINE 376,184 CMCL1
        DW      2,0801H,16191           ;WPR CL1 = BLUE+31
        DW      3,1800H,2,255           ;WPTN line style dash, zoom x3
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,242             ;WPR PRC: scan end 15,0, zoom x3 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,140          ;AMOVE 20,140
        DW      3,8808H,376,140         ;ALINE 376,140 CMCL1
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      3,1800H,2,6399          ;WPTN line style dash dot, zoom x2
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,241             ;WPR PRC: scan end 15,0, zoom x2 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,96           ;AMOVE 20,96
        DW      3,8808H,376,96          ;ALINE 376,96 CMCL1
        DW      2,0801H,0FFFFH          ;WPR CL1 = WHITE+31
        DW      3,1800H,2,21845         ;WPTN line style dots, zoom x4
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,243             ;WPR PRC: scan end 15,0, zoom x4 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,20,52           ;AMOVE 20,52
        DW      3,8808H,376,52          ;ALINE 376,52 CMCL1
        DW      3,1800H,2,4095          ;WPTN line style long dash, zoom x2
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,241             ;WPR PRC: scan end 15,0, zoom x2 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,8000H,410,215         ;AMOVE 410,215
        DW      3,9008H,570,365         ;ARCT 570,365 CMCL1
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      3,8000H,670,290         ;AMOVE 670,290
        DW      2,0A808H,75             ;CRCL r=75 CMCL1
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      3,8000H,880,370         ;AMOVE 880,370
        DW      10,0A008H,4,833,225,956,315,804,315 ;APLG 5 points CMCL1
        DW      927,225
        DW      18,1800H,32,255,255,255,255,255,255 ;WPTN checkerboard
        DW      255,255,0FF00H,0FF00H,0FF00H,0FF00H
        DW      0FF00H,0FF00H,0FF00H,0FF00H
        DW      2,0801H,30840           ;WPR CL1 = CYAN+24
        DW      2,0800H,9766            ;WPR CL0 = BLUE+6
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F0F0H          ;WPR PRC: scan end 15,15, zoom x1 y1
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,410,30          ;AMOVE 410,30
        DW      3,0C000H,549,180        ;AFRCT 549,180
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F1F1H          ;WPR PRC: scan end 15,15, zoom x2 y2
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,560,30          ;AMOVE 560,30
        DW      3,0C000H,699,180        ;AFRCT 699,180
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F2F2H          ;WPR PRC: scan end 15,15, zoom x3 y3
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,710,30          ;AMOVE 710,30
        DW      3,0C000H,849,180        ;AFRCT 849,180
        DW      2,0806H,0               ;WPR PRC: scan start 0,0
        DW      2,0807H,0F3F3H          ;WPR PRC: scan end 15,15, zoom x4 y4
        DW      2,0805H,0               ;WPR PRC: pattern pointer 0,0
        DW      3,8000H,860,30          ;AMOVE 860,30
        DW      3,0C000H,999,180        ;AFRCT 999,180
        DW      0
;
SCR21:
        DW      2,0808H,0               ;WPR XMIN 0
        DW      2,0809H,0               ;WPR YMIN 0
        DW      2,080AH,1023            ;WPR XMAX 1023
        DW      2,080BH,767             ;WPR YMAX 767
        DW      2,0801H,18761           ;WPR CL1 = GREEN+9
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,40,760          ;ALINE 40,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,63,760          ;ALINE 63,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,86,760          ;ALINE 86,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,109,760         ;ALINE 109,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,132,760         ;ALINE 132,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,155,760         ;ALINE 155,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,178,760         ;ALINE 178,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,201,760         ;ALINE 201,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,224,760         ;ALINE 224,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,247,760         ;ALINE 247,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,270,760         ;ALINE 270,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,293,760         ;ALINE 293,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,316,760         ;ALINE 316,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,339,760         ;ALINE 339,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,362,760         ;ALINE 362,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,385,760         ;ALINE 385,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,408,760         ;ALINE 408,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,431,760         ;ALINE 431,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,454,760         ;ALINE 454,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,477,760         ;ALINE 477,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,760         ;ALINE 500,760
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,737         ;ALINE 500,737
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,714         ;ALINE 500,714
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,691         ;ALINE 500,691
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,668         ;ALINE 500,668
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,645         ;ALINE 500,645
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,622         ;ALINE 500,622
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,599         ;ALINE 500,599
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,576         ;ALINE 500,576
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,553         ;ALINE 500,553
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,530         ;ALINE 500,530
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,507         ;ALINE 500,507
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,484         ;ALINE 500,484
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,461         ;ALINE 500,461
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8800H,500,438         ;ALINE 500,438
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,165,500         ;AMOVE 165,500
        DW      3,9000H,347,652         ;ARCT 347,652
        DW      2,0808H,166             ;WPR XMIN 166
        DW      2,0809H,501             ;WPR YMIN 501
        DW      2,080AH,346             ;WPR XMAX 346
        DW      2,080BH,651             ;WPR YMAX 651
        DW      2,0801H,24415           ;WPR CL1 = GREEN+31
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,40,760          ;ALINE 40,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,63,760          ;ALINE 63,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,86,760          ;ALINE 86,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,109,760         ;ALINE 109,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,132,760         ;ALINE 132,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,155,760         ;ALINE 155,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,178,760         ;ALINE 178,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,201,760         ;ALINE 201,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,224,760         ;ALINE 224,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,247,760         ;ALINE 247,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,270,760         ;ALINE 270,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,293,760         ;ALINE 293,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,316,760         ;ALINE 316,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,339,760         ;ALINE 339,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,362,760         ;ALINE 362,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,385,760         ;ALINE 385,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,408,760         ;ALINE 408,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,431,760         ;ALINE 431,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,454,760         ;ALINE 454,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,477,760         ;ALINE 477,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,760         ;ALINE 500,760 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,737         ;ALINE 500,737 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,714         ;ALINE 500,714 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,691         ;ALINE 500,691 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,668         ;ALINE 500,668 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,645         ;ALINE 500,645 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,622         ;ALINE 500,622 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,599         ;ALINE 500,599 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,576         ;ALINE 500,576 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,553         ;ALINE 500,553 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,530         ;ALINE 500,530 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,507         ;ALINE 500,507 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,484         ;ALINE 500,484 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,461         ;ALINE 500,461 AMCLIP
        DW      3,8000H,20,400          ;AMOVE 20,400
        DW      3,8840H,500,438         ;ALINE 500,438 AMCLIP
        DW      2,0808H,0               ;WPR XMIN 0
        DW      2,0809H,0               ;WPR YMIN 0
        DW      2,080AH,1023            ;WPR XMAX 1023
        DW      2,080BH,767             ;WPR YMAX 767
        DW      2,0801H,26985           ;WPR CL1 = CYAN+9
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,984,760         ;ALINE 984,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,961,760         ;ALINE 961,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,938,760         ;ALINE 938,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,915,760         ;ALINE 915,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,892,760         ;ALINE 892,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,869,760         ;ALINE 869,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,846,760         ;ALINE 846,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,823,760         ;ALINE 823,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,800,760         ;ALINE 800,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,777,760         ;ALINE 777,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,754,760         ;ALINE 754,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,731,760         ;ALINE 731,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,708,760         ;ALINE 708,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,685,760         ;ALINE 685,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,662,760         ;ALINE 662,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,639,760         ;ALINE 639,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,616,760         ;ALINE 616,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,593,760         ;ALINE 593,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,570,760         ;ALINE 570,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,547,760         ;ALINE 547,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,760         ;ALINE 524,760
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,737         ;ALINE 524,737
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,714         ;ALINE 524,714
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,691         ;ALINE 524,691
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,668         ;ALINE 524,668
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,645         ;ALINE 524,645
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,622         ;ALINE 524,622
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,599         ;ALINE 524,599
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,576         ;ALINE 524,576
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,553         ;ALINE 524,553
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,530         ;ALINE 524,530
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,507         ;ALINE 524,507
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,484         ;ALINE 524,484
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,461         ;ALINE 524,461
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,8800H,524,438         ;ALINE 524,438
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,677,500         ;AMOVE 677,500
        DW      3,9000H,859,652         ;ARCT 859,652
        DW      2,0808H,678             ;WPR XMIN 678
        DW      2,0809H,501             ;WPR YMIN 501
        DW      2,080AH,858             ;WPR XMAX 858
        DW      2,080BH,651             ;WPR YMAX 651
        DW      2,0801H,32639           ;WPR CL1 = CYAN+31
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,984,760         ;ALINE 984,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,961,760         ;ALINE 961,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,938,760         ;ALINE 938,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,915,760         ;ALINE 915,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,892,760         ;ALINE 892,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,869,760         ;ALINE 869,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,846,760         ;ALINE 846,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,823,760         ;ALINE 823,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,800,760         ;ALINE 800,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,777,760         ;ALINE 777,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,754,760         ;ALINE 754,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,731,760         ;ALINE 731,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,708,760         ;ALINE 708,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,685,760         ;ALINE 685,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,662,760         ;ALINE 662,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,639,760         ;ALINE 639,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,616,760         ;ALINE 616,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,593,760         ;ALINE 593,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,570,760         ;ALINE 570,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,547,760         ;ALINE 547,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,760         ;ALINE 524,760 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,737         ;ALINE 524,737 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,714         ;ALINE 524,714 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,691         ;ALINE 524,691 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,668         ;ALINE 524,668 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,645         ;ALINE 524,645 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,622         ;ALINE 524,622 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,599         ;ALINE 524,599 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,576         ;ALINE 524,576 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,553         ;ALINE 524,553 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,530         ;ALINE 524,530 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,507         ;ALINE 524,507 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,484         ;ALINE 524,484 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,461         ;ALINE 524,461 AMHOLE
        DW      3,8000H,1003,400        ;AMOVE 1003,400
        DW      3,88C0H,524,438         ;ALINE 524,438 AMHOLE
        DW      2,0808H,0               ;WPR XMIN 0
        DW      2,0809H,0               ;WPR YMIN 0
        DW      2,080AH,1023            ;WPR XMAX 1023
        DW      2,080BH,767             ;WPR YMAX 767
        DW      2,0801H,0C9C9H          ;WPR CL1 = YELLOW+9
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,425,214         ;ALINE 425,214
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,413,257         ;ALINE 413,257
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,391,295         ;ALINE 391,295
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,359,327         ;ALINE 359,327
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,321,349         ;ALINE 321,349
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,278,361         ;ALINE 278,361
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,234,361         ;ALINE 234,361
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,191,349         ;ALINE 191,349
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,153,327         ;ALINE 153,327
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,121,295         ;ALINE 121,295
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,99,257          ;ALINE 99,257
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,87,214          ;ALINE 87,214
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,87,170          ;ALINE 87,170
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,99,127          ;ALINE 99,127
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,121,89          ;ALINE 121,89
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,153,57          ;ALINE 153,57
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,191,35          ;ALINE 191,35
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,234,23          ;ALINE 234,23
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,278,23          ;ALINE 278,23
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,321,35          ;ALINE 321,35
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,359,57          ;ALINE 359,57
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,391,89          ;ALINE 391,89
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,413,127         ;ALINE 413,127
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8800H,425,170         ;ALINE 425,170
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,165,116         ;AMOVE 165,116
        DW      3,9000H,347,268         ;ARCT 347,268
        DW      2,0808H,166             ;WPR XMIN 166
        DW      2,0809H,117             ;WPR YMIN 117
        DW      2,080AH,346             ;WPR XMAX 346
        DW      2,080BH,267             ;WPR YMAX 267
        DW      2,0801H,0DFDFH          ;WPR CL1 = YELLOW+31
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,425,214         ;ALINE 425,214 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,413,257         ;ALINE 413,257 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,391,295         ;ALINE 391,295 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,359,327         ;ALINE 359,327 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,321,349         ;ALINE 321,349 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,278,361         ;ALINE 278,361 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,234,361         ;ALINE 234,361 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,191,349         ;ALINE 191,349 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,153,327         ;ALINE 153,327 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,121,295         ;ALINE 121,295 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,99,257          ;ALINE 99,257 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,87,214          ;ALINE 87,214 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,87,170          ;ALINE 87,170 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,99,127          ;ALINE 99,127 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,121,89          ;ALINE 121,89 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,153,57          ;ALINE 153,57 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,191,35          ;ALINE 191,35 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,234,23          ;ALINE 234,23 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,278,23          ;ALINE 278,23 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,321,35          ;ALINE 321,35 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,359,57          ;ALINE 359,57 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,391,89          ;ALINE 391,89 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,413,127         ;ALINE 413,127 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,256,192         ;AMOVE 256,192
        DW      3,8820H,425,170         ;ALINE 425,170 AMSTOP
        DW      2,0A800H,4              ;CRCL r=4
        DW      2,0808H,0               ;WPR XMIN 0
        DW      2,0809H,0               ;WPR YMIN 0
        DW      2,080AH,1023            ;WPR XMAX 1023
        DW      2,080BH,767             ;WPR YMAX 767
        DW      2,0801H,0A9A9H          ;WPR CL1 = MAGENTA+9
        DW      3,8000H,937,214         ;AMOVE 937,214
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,925,257         ;AMOVE 925,257
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,903,295         ;AMOVE 903,295
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,871,327         ;AMOVE 871,327
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,833,349         ;AMOVE 833,349
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,790,361         ;AMOVE 790,361
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,746,361         ;AMOVE 746,361
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,703,349         ;AMOVE 703,349
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,665,327         ;AMOVE 665,327
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,633,295         ;AMOVE 633,295
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,611,257         ;AMOVE 611,257
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,599,214         ;AMOVE 599,214
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,599,170         ;AMOVE 599,170
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,611,127         ;AMOVE 611,127
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,633,89          ;AMOVE 633,89
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,665,57          ;AMOVE 665,57
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,703,35          ;AMOVE 703,35
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,746,23          ;AMOVE 746,23
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,790,23          ;AMOVE 790,23
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,833,35          ;AMOVE 833,35
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,871,57          ;AMOVE 871,57
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,903,89          ;AMOVE 903,89
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,925,127         ;AMOVE 925,127
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      3,8000H,937,170         ;AMOVE 937,170
        DW      3,8800H,768,192         ;ALINE 768,192
        DW      2,0801H,0F4F4H          ;WPR CL1 = WHITE+20
        DW      3,8000H,677,116         ;AMOVE 677,116
        DW      3,9000H,859,268         ;ARCT 859,268
        DW      2,0808H,678             ;WPR XMIN 678
        DW      2,0809H,117             ;WPR YMIN 117
        DW      2,080AH,858             ;WPR XMAX 858
        DW      2,080BH,267             ;WPR YMAX 267
        DW      2,0801H,0BFBFH          ;WPR CL1 = MAGENTA+31
        DW      3,8000H,937,214         ;AMOVE 937,214
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,925,257         ;AMOVE 925,257
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,903,295         ;AMOVE 903,295
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,871,327         ;AMOVE 871,327
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,833,349         ;AMOVE 833,349
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,790,361         ;AMOVE 790,361
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,746,361         ;AMOVE 746,361
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,703,349         ;AMOVE 703,349
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,665,327         ;AMOVE 665,327
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,633,295         ;AMOVE 633,295
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,611,257         ;AMOVE 611,257
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,599,214         ;AMOVE 599,214
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,599,170         ;AMOVE 599,170
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,611,127         ;AMOVE 611,127
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,633,89          ;AMOVE 633,89
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,665,57          ;AMOVE 665,57
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,703,35          ;AMOVE 703,35
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,746,23          ;AMOVE 746,23
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,790,23          ;AMOVE 790,23
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,833,35          ;AMOVE 833,35
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,871,57          ;AMOVE 871,57
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,903,89          ;AMOVE 903,89
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,925,127         ;AMOVE 925,127
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      3,8000H,937,170         ;AMOVE 937,170
        DW      3,88A0H,768,192         ;ALINE 768,192 AMSTPI
        DW      2,0A800H,4              ;CRCL r=4
        DW      2,0808H,0               ;WPR XMIN 0
        DW      2,0809H,0               ;WPR YMIN 0
        DW      2,080AH,1023            ;WPR XMAX 1023
        DW      2,080BH,767             ;WPR YMAX 767
        DW      0
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
DPREND:
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
        DB      ' 1/21  DOT   - '
        DB      'random dots placed by AMOVE; border dots stepped'
        DB      CR,LF,'              by RMOVE',CR,LF,'$'
MSG2:   DB      CR,LF
        DB      ' 2/21  ALINE - '
        DB      'absolute lines: string art in each corner',CR,LF,'$'
MSG3:   DB      CR,LF
        DB      ' 3/21  RLINE - '
        DB      'relative lines: a square spiral from the center'
        DB      CR,LF,'$'
MSG4:   DB      CR,LF
        DB      ' 4/21  ARCT  - '
        DB      'absolute rectangles: concentric outlines',CR,LF,'$'
MSG5:   DB      CR,LF
        DB      ' 5/21  RRCT  - '
        DB      'relative rectangles: two cascades, stepped by RMOVE'
        DB      CR,LF,'$'
MSG6:   DB      CR,LF
        DB      ' 6/21  APLL  - '
        DB      'absolute polylines: a framed sine/damped cosine plot'
        DB      CR,LF,'$'
MSG7:   DB      CR,LF
        DB      ' 7/21  RPLL  - '
        DB      'relative polylines: one motif resent, chaining from CP'
        DB      CR,LF,'$'
MSG8:   DB      CR,LF
        DB      ' 8/21  APLG  - '
        DB      'absolute polygons: nested polygons and star polygons'
        DB      CR,LF,'$'
MSG9:   DB      CR,LF
        DB      ' 9/21  RPLG  - '
        DB      'relative polygons: one hexagon stamped as a honeycomb'
        DB      CR,LF,'$'
MSG10:  DB      CR,LF
        DB      '10/21  AFRCT - '
        DB      'absolute filled rectangles: stepped color pyramids'
        DB      CR,LF,'$'
MSG11:  DB      CR,LF
        DB      '11/21  RFRCT - '
        DB      'relative filled rectangles: a stacked bar chart'
        DB      CR,LF,'$'
MSG12:  DB      CR,LF
        DB      '12/21  CRCL  - '
        DB      'circles: concentric rings and a ring of circles'
        DB      CR,LF,'$'
MSG13:  DB      CR,LF
        DB      '13/21  ELPS  - '
        DB      'ellipses: two families round one center'
        DB      CR,LF,'$'
MSG14:  DB      CR,LF
        DB      '14/21  AARC  - '
        DB      'arcs: rainbow (CCW), bowls (CW), RARC waves'
        DB      CR,LF,'$'
MSG15:  DB      CR,LF
        DB      '15/21  AEARC - '
        DB      'elliptical arcs, and an REARC bouncing ball'
        DB      CR,LF,'$'
MSG16:  DB      CR,LF
        DB      '16/21  PAINT - '
        DB      'fills to an edge color, a brick fill, a flood (E=1)'
        DB      CR,LF,'$'
MSG17:  DB      CR,LF
        DB      '17/21  PTN   - '
        DB      'the pattern RAM as a picture: zoom, turns, slants'
        DB      CR,LF,'$'
MSG18:  DB      CR,LF
        DB      '18/21  AGCPY - '
        DB      '8 transforms; RGCPY chain; copies in REP OR AND EOR'
        DB      CR,LF,'$'
MSG19:  DB      CR,LF
        DB      '19/21  OPM   - '
        DB      'top: REP OR AND EOR, bottom: EQ NE LT GT'
        DB      CR,LF,'$'
MSG20:  DB      CR,LF
        DB      '20/21  COL   - '
        DB      'CMSEL CMCL1 CMCL0 CMPRAM, line styles, pattern zoom'
        DB      CR,LF,'$'
MSG21:  DB      CR,LF
        DB      '21/21  AREA  - '
        DB      'top: clip, hole; bottom: stop, stop inside'
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
XL:     DS      2               ;AFRING
XR:     DS      2
YB:     DS      2
YT:     DS      2
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
