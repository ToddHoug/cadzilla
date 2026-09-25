        .XLIST                  ;(.LIST again at the end of this file)
;
; CZGFX.INC -- CADzilla graphics library: equates and macros
;
; Use from an M80 program:
;
;               INCLUDE B:CZGFX.INC
;
; with the czgfx library disk mounted as drive B: (see software/czgfx/
; README.md), and link with
;
;       A0>SUBMIT B:CZLINK <NAME>
;
; Coordinates: GINIT puts the ACRTC origin at the bottom-left pixel, so
; X runs 0..CZXMAX left to right and Y runs 0..CZYMAX BOTTOM to TOP.
;
; Register conventions (routines and macros alike):
;   - X arguments go in HL, Y arguments in DE, colors in A
;   - every routine preserves BC, DE and HL unless its entry below says
;     otherwise; A and the flags are always clobbered
;   - a macro argument left blank means "already in the register": e.g.
;     GLINE ,100 draws to X = HL, Y = 100
;
; Global names are 6 characters: L80 keeps only the first 6.
;
; Externals: the macros reference the library as NAME## (M80's inline
; external), so a program links in only the modules it really uses. To
; call a routine or read a data symbol directly, write it the same way
; (CALL CZLDW##, LHLD CZXMAX##). Don't EXTRN library names you don't
; use: M80 emits every EXTRN as a link request, and L80 then loads that
; module whether anything calls it or not.
;
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
OPAPLG  EQU     0A0H            ;APLG   n, X1,Y1 .. (closes on CP)
OPFRCT  EQU     0C0H            ;AFRCT  X,Y (CP.Y = one past far edge)
OPRFRC  EQU     0C4H            ;RFRCT  dX,dY (likewise)
CMDDOT  EQU     0CC00H          ;DOT    (whole word, no parameters)
;
; ---- default palette: index = hue*32 + level (level 0..31) ----
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
; ================= macros =================
;
; CZLXY -- load HL = XV and DE = YV, skipping either one left blank
;
CZLXY   MACRO   XV,YV
        IFNB    <XV>
        LXI     H,XV
        ENDIF
        IFNB    <YV>
        LXI     D,YV
        ENDIF
        ENDM
;
; GINIT [mode] -- set up the board and clear the screen to color 0.
; mode is a library descriptor: CZM640 (640x480, the default when
; omitted), CZM800 (800x600) or CZM1K (1024x768). It must match the
; monitor the project's machine is strapped for (cad0 `mode`; 1024x768
; unless the project's machine.toml says otherwise), so name it
; explicitly. For a descriptor of your own, LXI H,yours / CALL CZINIT##
; instead. Clobbers all registers.
;
GINIT   MACRO   MV
        IFB     <MV>
        LXI     H,CZM640##
        ELSE
        LXI     H,MV##
        ENDIF
        CALL    CZINIT##
        ENDM
;
; GCLS [c] -- clear the whole screen to color c (default 0)
;
GCLS    MACRO   CV
        IFB     <CV>
        XRA     A
        ELSE
        MVI     A,CV
        ENDIF
        CALL    CZCLS##
        ENDM
;
; GCOLOR [c] -- set the drawing color to palette index c
;
GCOLOR  MACRO   CV
        IFNB    <CV>
        MVI     A,CV
        ENDIF
        CALL    CZCOL##
        ENDM
;
; GPAL i,r,g,b -- set palette entry i to r,g,b (0..255 each).
; Clobbers BC and E.
;
GPAL    MACRO   IV,RV,GV,BV
        MVI     B,RV
        MVI     C,GV
        MVI     E,BV
        MVI     A,IV
        CALL    CZPALS##
        ENDM
;
; Single commands at X,Y (absolute) or dX,dY (relative to the CP)
;
GMOVE   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZMOVE##
        ENDM
GLINE   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZLINE##
        ENDM
GRECT   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRECT##
        ENDM
GFRECT  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZFRCT##
        ENDM
GDOT    MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZDOT##
        ENDM
GRMOVE  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRMOV##
        ENDM
GRLINE  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRLIN##
        ENDM
GRRECT  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRRCT##
        ENDM
GRFRCT  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRFRC##
        ENDM
;
; GSEG x1,y1,x2,y2 -- line from x1,y1 to x2,y2 (x2,y2 itself not drawn)
;
GSEG    MACRO   X1,Y1,X2,Y2
        GMOVE   X1,Y1
        GLINE   X2,Y2
        ENDM
;
; GBOX x1,y1,x2,y2 -- rectangle outline with corners x1,y1 and x2,y2
;
GBOX    MACRO   X1,Y1,X2,Y2
        GMOVE   X1,Y1
        GRECT   X2,Y2
        ENDM
;
; GFBOX x1,y1,x2,y2[,c] -- filled rectangle, in color c if given
;
GFBOX   MACRO   X1,Y1,X2,Y2,CV
        IFNB    <CV>
        GCOLOR  CV
        ENDIF
        GMOVE   X1,Y1
        GFRECT  X2,Y2
        ENDM
;
; GPLINE <x0,y0,x1,y1,...> -- open polyline through the points
; GPOLY  <x0,y0,x1,y1,...> -- closed polygon through the points
; The point list is placed inline (and jumped over). At least 2 points.
; Clobbers HL.
;
GPLINE  MACRO   PTS
        LOCAL   SKIP,TBL,TEND
        JMP     SKIP
TBL:    DW      (TEND-TBL-2)/4
        IRP     V,<PTS>
        DW      V
        ENDM
TEND:
SKIP:   LXI     H,TBL
        CALL    CZPLL##
        ENDM
GPOLY   MACRO   PTS
        LOCAL   SKIP,TBL,TEND
        JMP     SKIP
TBL:    DW      (TEND-TBL-2)/4
        IRP     V,<PTS>
        DW      V
        ENDM
TEND:
SKIP:   LXI     H,TBL
        CALL    CZPLG##
        ENDM
;
; GPTS name,<x0,y0,x1,y1,...> -- define a named point table (in data,
; not inline) for GPLT/GPLG: DW count, then the X,Y pairs
;
GPTS    MACRO   NM,PTS
        LOCAL   TEND
NM:     DW      (TEND-NM-2)/4
        IRP     V,<PTS>
        DW      V
        ENDM
TEND:
        ENDM
;
; GPLT tbl / GPLG tbl -- polyline / polygon from a GPTS table.
; HL is left pointing just past the table.
;
GPLT    MACRO   TV
        CZLXY   TV
        CALL    CZPLL##
        ENDM
GPLG    MACRO   TV
        CZLXY   TV
        CALL    CZPLG##
        ENDM
;
; GWAIT -- wait for the ACRTC to finish drawing. Returns A = status
; register, Z set if the drawing ended cleanly, NZ on a command error.
;
GWAIT   MACRO
        CALL    CZWAIT##
        ENDM
;
; GABORT -- abort the ACRTC (clears a command error, flushes the FIFOs)
;
GABORT  MACRO
        CALL    CZABT##
        ENDM
;
        .LIST
