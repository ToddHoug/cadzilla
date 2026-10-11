;
; FIRSTDRW.ASM -- CADzilla first-light program
;
; Initializes the CADzilla board for 1024x768, 8 bits per pixel, single
; access mode, loads the Bt453 palette with 8 hues x 32 brightness levels,
; clears the base screen and draws a border and a visual test pattern.
; The machine's monitor must be strapped for 1024x768 (cad0 mode, the
; default in tools/altairsim/pristine/cadzilla.toml).
;
; Coordinates: the ACRTC origin is set to the bottom-left pixel, so X runs
; 0..1023 left to right and Y runs 0..767 BOTTOM to TOP. The base screen
; starts at frame buffer word address 0 (the top raster).
;
; Expected picture (verify visually):
;   - white 1-pixel border around the full 1024x768 frame
;   - dim white horizontal line across the middle (Y=384)
;   - 8x8 corner markers: TOP-LEFT blue, TOP-RIGHT yellow,
;     BOTTOM-LEFT red, BOTTOM-RIGHT green (wrong corners = axis flipped)
;   - lower half: 32 x 8 palette grid, all 256 entries; rows top to bottom
;     orange, blue, green, cyan, red, magenta, yellow, white; each row
;     ramps from black (left) to full brightness (right)
;   - upper left: 6 nested rectangles with an X through them
;   - upper middle: 48-line starburst (all line octants), hues cycling
;   - upper right: 13 x 13 line grid, 25 pixel pitch
;   (the three upper figures are each 300 pixels square, Y 426..726)
;
        ORG     0100H
;
BDOS    EQU     0005H
PSTRING EQU     9
CR      EQU     0DH
LF      EQU     0AH
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
OPLINE  EQU     88H             ;ALINE  X,Y (end point not drawn)
OPRECT  EQU     90H             ;ARCT   X,Y
OPFRCT  EQU     0C0H            ;AFRCT  X,Y
DLCOL   EQU     01H             ;display list only: set color
DLEND   EQU     00H             ;display list only: end of list
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
YMID    EQU     (YMAX+1)/2      ;center line
;
;
START:  LXI     H,0             ;keep CCP's stack, run on our own
        DAD     SP
        SHLD    OLDSP
        LXI     SP,STACK
;
        LXI     D,MSGHI
        MVI     C,PSTRING
        CALL    BDOS
;
        MVI     A,MODEVAL       ;board glue: sync polarity, access mode
        OUT     MODEREG
        CALL    REGINIT         ;ACRTC control registers, display started
        CALL    PALINIT         ;Bt453 color palette
;
        XRA     A               ;AR = r00: FIFO entry from here on
        OUT     ACRSR
        LXI     H,DPINIT        ;drawing parameters, origin, clear screen
        LXI     B,(DPEND-DPINIT)/2
        CALL    SENDBLK
;
        CALL    GRID            ;palette grid
        CALL    STARB           ;starburst
        CALL    LGRID           ;line grid
        LXI     H,DLIST         ;border, markers, rectangles
        CALL    DLRUN
;
        CALL    WAITDN          ;let the ACRTC finish drawing
        LXI     D,MSGOK
        ANI     SRCER
        JZ      DONE
        LXI     D,MSGER
DONE:   MVI     C,PSTRING
        CALL    BDOS
        LHLD    OLDSP
        SPHL
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
; SENDBLK -- send BC words from table at HL to the FIFO
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
; ================= drawing primitives =================
;
; SETCOL -- set drawing color to palette index A (WPR CL1). The
; pattern RAM is all ones, so COL=00 always draws with CL1. At 8 bpp
; the index is replicated into both bytes of the color register.
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
; DLRUN -- run a display list at HL. Entries:
;   DB DLCOL,index           set color
;   DB op / DW x,y           op = OPMOVE, OPLINE, OPRECT, OPFRCT
;   DB DLEND                 end of list
;
DLRUN:  MOV     A,M
        INX     H
        ORA     A
        RZ
        CPI     DLCOL
        JZ      DLC
        MOV     C,A             ;C = command
        CALL    LDW             ;DE = X
        PUSH    D
        CALL    LDW             ;DE = Y
        XTHL                    ;HL = X, list pointer on stack
        MOV     A,C
        CALL    XYCMD
        POP     H
        JMP     DLRUN
DLC:    MOV     A,M
        INX     H
        CALL    SETCOL
        JMP     DLRUN
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
        DW      5800H,0000H,511,0-767 ;CLR 512 words x 768 rasters to 0
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
; ================= test pattern =================
;
; GRID -- palette grid in the lower half: 32 columns (levels) x
; 8 rows (hues), 22x32 pixel cells on a 26x38 pitch. Hue 0 on top.
;
GRID:   XRA     A
        STA     COLIDX
        LXI     H,326           ;bottom Y of the top row
        SHLD    GY
GRROW:  LXI     H,98            ;left X of the first column
        SHLD    GX
GRCELL: LDA     COLIDX
        CALL    SETCOL
        LHLD    GY
        XCHG
        LHLD    GX
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     B,21            ;far corner = (GX+21, GY+31)
        DAD     B
        PUSH    H
        LHLD    GY
        LXI     B,31
        DAD     B
        XCHG
        POP     H
        MVI     A,OPFRCT
        CALL    XYCMD
        LHLD    GX
        LXI     B,26
        DAD     B
        SHLD    GX
        LDA     COLIDX
        INR     A
        STA     COLIDX
        RZ                      ;wrapped past 255: all 256 drawn
        ANI     31
        JNZ     GRCELL          ;more cells in this row
        LHLD    GY              ;next row down
        LXI     B,0-38
        DAD     B
        SHLD    GY
        JMP     GRROW
;
; STARB -- starburst: lines from (CENX,CENY) to every 25th point
; around a 300x300 square, one color per line.
;
CENX    EQU     512
CENY    EQU     576
;
STARB:  XRA     A
        STA     COLIDX
        LXI     H,SIDES
        MVI     B,4             ;sides
STSIDE: CALL    LDW
        XCHG
        SHLD    EX
        XCHG
        CALL    LDW
        XCHG
        SHLD    EY
        XCHG
        CALL    LDW
        XCHG
        SHLD    SDX
        XCHG
        CALL    LDW
        XCHG
        SHLD    SDY
        XCHG
        PUSH    H
        PUSH    B
        MVI     B,12            ;lines per side
STLINE: LDA     COLIDX          ;hue = line number mod 8, full level
        INR     A
        STA     COLIDX
        ANI     7
        RRC
        RRC
        RRC
        ORI     BRIGHT
        CALL    SETCOL
        LXI     H,CENX
        LXI     D,CENY
        MVI     A,OPMOVE
        CALL    XYCMD
        LHLD    EY
        XCHG
        LHLD    EX
        MVI     A,OPLINE
        CALL    XYCMD
        LHLD    SDY             ;EY += SDY (DE = EY after XYCMD)
        DAD     D
        SHLD    EY
        LHLD    SDX             ;EX += SDX
        XCHG
        LHLD    EX
        DAD     D
        SHLD    EX
        DCR     B
        JNZ     STLINE
        POP     B
        POP     H
        DCR     B
        JNZ     STSIDE
        RET
;
; Starburst sides: start X, start Y, step X, step Y
;
SIDES:  DW      CENX-150,CENY+150,25,0  ;top, left to right
        DW      CENX+150,CENY+150,0,0-25 ;right, top to bottom
        DW      CENX+150,CENY-150,0-25,0 ;bottom, right to left
        DW      CENX-150,CENY-150,0,25  ;left, bottom to top
;
; LGRID -- 13 x 13 line grid, 25 pixel pitch, upper right
;
LGRID:  MVI     A,CYAN+20
        CALL    SETCOL
        LXI     H,692           ;vertical lines, X = 692..992
        MVI     B,13
LGV:    LXI     D,426
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     D,727           ;end point is not drawn
        MVI     A,OPLINE
        CALL    XYCMD
        LXI     D,25
        DAD     D
        DCR     B
        JNZ     LGV
        LXI     D,426           ;horizontal lines, Y = 426..726
        MVI     B,13
LGH:    LXI     H,692
        MVI     A,OPMOVE
        CALL    XYCMD
        LXI     H,993
        MVI     A,OPLINE
        CALL    XYCMD
        LXI     H,25
        DAD     D
        XCHG
        DCR     B
        JNZ     LGH
        RET
;
; Display list: border, center line, corner markers, nested rectangles
;
DLIST:  DB      DLCOL,WHITE+BRIGHT      ;border
        DB      OPMOVE
        DW      0,0
        DB      OPRECT
        DW      XMAX,YMAX
        DB      DLCOL,WHITE+15          ;center line
        DB      OPMOVE
        DW      1,YMID
        DB      OPLINE
        DW      XMAX,YMID
        DB      DLCOL,RED+BRIGHT        ;bottom-left marker
        DB      OPMOVE
        DW      4,4
        DB      OPFRCT
        DW      11,11
        DB      DLCOL,GREEN+BRIGHT      ;bottom-right marker
        DB      OPMOVE
        DW      XMAX-11,4
        DB      OPFRCT
        DW      XMAX-4,11
        DB      DLCOL,BLUE+BRIGHT       ;top-left marker
        DB      OPMOVE
        DW      4,YMAX-11
        DB      OPFRCT
        DW      11,YMAX-4
        DB      DLCOL,YELLOW+BRIGHT     ;top-right marker
        DB      OPMOVE
        DW      XMAX-11,YMAX-11
        DB      OPFRCT
        DW      XMAX-4,YMAX-4
        DB      DLCOL,RED+BRIGHT        ;nested rectangles at (180,576)
        DB      OPMOVE
        DW      155,551
        DB      OPRECT
        DW      205,601
        DB      DLCOL,ORANGE+BRIGHT
        DB      OPMOVE
        DW      130,526
        DB      OPRECT
        DW      230,626
        DB      DLCOL,YELLOW+BRIGHT
        DB      OPMOVE
        DW      105,501
        DB      OPRECT
        DW      255,651
        DB      DLCOL,GREEN+BRIGHT
        DB      OPMOVE
        DW      80,476
        DB      OPRECT
        DW      280,676
        DB      DLCOL,CYAN+BRIGHT
        DB      OPMOVE
        DW      55,451
        DB      OPRECT
        DW      305,701
        DB      DLCOL,BLUE+BRIGHT
        DB      OPMOVE
        DW      30,426
        DB      OPRECT
        DW      330,726
        DB      DLCOL,MAGENTA+BRIGHT    ;X through the rectangles
        DB      OPMOVE
        DW      30,426
        DB      OPLINE
        DW      331,727
        DB      OPMOVE
        DW      30,726
        DB      OPLINE
        DW      331,425
        DB      DLEND
;
;
MSGHI:  DB      'CADzilla firstdraw: 1024x768, 8 bpp',CR,LF,'$'
MSGOK:  DB      'Test pattern drawn.',CR,LF,'$'
MSGER:  DB      'ACRTC command error (CER set)!',CR,LF,'$'
;
; ---- variables ----
;
OLDSP:  DS      2
LEVEL:  DS      1
COLIDX: DS      1
GX:     DS      2
GY:     DS      2
EX:     DS      2
EY:     DS      2
SDX:    DS      2
SDY:    DS      2
        DS      64
STACK:
;
        END     START
