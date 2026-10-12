        .XLIST                  ;(.LIST again at the end of this file)
; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
; CZGFX.INC -- CADzilla graphics library: equates and macros
;
; Use from an M80 program:
;
;               INCLUDE B:CZGFX.INC
;
; with the czgfx library disk mounted as drive B: (see software/m80/czgfx/
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
;     GLINE ,100 draws to X = HL, Y = 100. The shapes drawn round a
;     point (GCIRC, GELLIP, GPAINT, GFLOOD, GPTN) are the exception for
;     that point: x,y both blank means "at the CP", with no move
;   - everything but GMOVE/GRMOVE draws in the current drawing mode
;     (GMODE: operation, color and area modes; GINIT resets it)
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
; Version: CZVERS is this library's release, major in the high byte,
; minor in the low one. A release is the library disk image
; software/m80/czgfx/releases/CZGFXLIB-<major>.<minor>.DSK; each project pins
; one in its software/<toolchain>/<project>/czgfx.version and builds against its own
; copy of it (tools/altairsim/scripts/attach_libdisk.sh).
;
CZVERS  EQU     0100H           ;1.0
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
DACOVL  EQU     CZBASE+7        ;Bt453 overlay colors (R,G,B)
;
; ---- MODE register bits (write-only: CZMREG keeps its value) ----
;
MDOLEN  EQU     08H             ;overlay shown
MDOLSL  EQU     10H             ;overlay half a CHR screen draws (A16)
;
; ---- ACRTC status register bits ----
;
SRWFE   EQU     01H             ;write FIFO empty
SRWFR   EQU     02H             ;write FIFO ready (not full)
SRRFR   EQU     04H             ;read FIFO ready (holds a byte)
SRCED   EQU     20H             ;command end
SRARD   EQU     40H             ;area detect (AREA modes; RPR/ABT clear)
SRCER   EQU     80H             ;command error
;
; ---- ACRTC command high bytes ----
;
; A drawing command's low byte is the drawing mode, AREA COL OPM
; (below), which the library keeps in CZDM and adds to every drawing
; command it sends. AMOVE/RMOVE take no mode.
;
OPMOVE  EQU     80H             ;AMOVE  X,Y
OPRMOV  EQU     84H             ;RMOVE  dX,dY
OPLINE  EQU     88H             ;ALINE  X,Y (end point not drawn)
OPRLIN  EQU     8CH             ;RLINE  dX,dY (end point not drawn)
OPRECT  EQU     90H             ;ARCT   X,Y (CP unchanged)
OPRRCT  EQU     94H             ;RRCT   dX,dY (CP unchanged)
OPAPLL  EQU     98H             ;APLL   n, X1,Y1 .. Xn,Yn (CP = end)
OPAPLG  EQU     0A0H            ;APLG   n, X1,Y1 .. (closes on CP)
OPCRCL  EQU     0A8H            ;CRCL   r (centre CP)
OPELPS  EQU     0ACH            ;ELPS   a,b,dX (centre CP)
OPAARC  EQU     0B0H            ;AARC   Xc,Yc,Xe,Ye (from CP; CP = Pe)
OPRARC  EQU     0B4H            ;RARC   the same relative to CP
OPAEAR  EQU     0B8H            ;AEARC  a,b,Xc,Yc,Xe,Ye
OPREAR  EQU     0BCH            ;REARC  the same relative to CP
OPFRCT  EQU     0C0H            ;AFRCT  X,Y (CP.Y = one past far edge)
OPRFRC  EQU     0C4H            ;RFRCT  dX,dY (likewise)
OPPANT  EQU     0C8H            ;PAINT  (from CP, bounded by EDG)
OPDOT   EQU     0CCH            ;DOT    (the pixel at CP)
OPPTN   EQU     0D0H            ;PTN    SZ (pattern RAM drawn at CP)
OPAGCP  EQU     0E0H            ;AGCPY  Xs,Ys,DX,DY (to CP)
OPRGCP  EQU     0F0H            ;RGCPY  dXs,dYs,DX,DY
OPRD    EQU     44H             ;RD     (the word at RWP to the read FIFO)
CMDDOT  EQU     0CC00H          ;DOT    (whole word, mode 0)
;
; Direction, added to a curve's high byte (CRCL, ELPS, the arcs):
;
DIRCCW  EQU     0               ;counter-clockwise (the default)
DIRCW   EQU     1               ;clockwise
;
; ---- drawing mode: AREA (bits 7-5) + COL (4-3) + OPM (2-0) ----
;
; Operation mode: how the color C being drawn meets the pixel P
; already there. C is CL1 or CL0 (GCOLOR/GBCOL) as the color mode picks.
;
OMREP   EQU     0               ;P = C (replace)
OMOR    EQU     1               ;P = P OR C
OMAND   EQU     2               ;P = P AND C
OMEOR   EQU     3               ;P = P XOR C (twice restores P)
OMEQ    EQU     4               ;P = C where P = CCMP (GCCMP)
OMNE    EQU     5               ;P = C where P <> CCMP
OMLT    EQU     6               ;P = C where P < C
OMGT    EQU     7               ;P = C where P > C
;
; Color mode: what each pattern RAM bit draws (GLDPAT, GLSTYL).
;
CMSEL   EQU     00H             ;1 = CL1, 0 = CL0 (two colors)
CMCL1   EQU     08H             ;1 = CL1, 0 = left alone (transparent)
CMCL0   EQU     10H             ;0 = CL0, 1 = left alone
CMPRAM  EQU     18H             ;pattern RAM direct: a 4x4 color tile
;
; Area mode: against the area rectangle (GAREA; GINIT sets the screen).
;
AMNONE  EQU     00H             ;no checking
AMSTOP  EQU     20H             ;stop at the first pixel outside; ARD
AMCLIP  EQU     40H             ;draw only inside
AMCLPD  EQU     60H             ;draw only inside; ARD if any outside
AMSTPI  EQU     0A0H            ;stop at the first pixel inside; ARD
AMHOLE  EQU     0C0H            ;draw only outside
AMHOLD  EQU     0E0H            ;draw only outside; ARD if any inside
;
; ---- GCOPY transforms: how the source lands at the destination ----
;
CPNORM  EQU     0               ;as it is
CPMIRY  EQU     1               ;flipped top to bottom
CPMIRX  EQU     2               ;mirrored left to right
CPR180  EQU     3               ;turned 180 degrees
CPTRAN  EQU     4               ;transposed (mirrored in the diagonal)
CPR270  EQU     5               ;turned 90 degrees clockwise
CPR90   EQU     6               ;turned 90 degrees counter-clockwise
CPATRN  EQU     7               ;mirrored in the other diagonal
;
; ---- GPTN directions: rows run SD*45 degrees CCW from +X ----
;
PTSLNT  EQU     8               ;add to slant the rows 45 (not 90)
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
; CZAT x,y -- move to x,y unless both are blank (then: at the CP).
; (GMOVE is defined below; a macro is expanded only where it is used.)
;
CZAT    MACRO   XV,YV
        IFNB    <XV>
        GMOVE   XV,YV
        ELSE
        IFNB    <YV>
        GMOVE   ,YV
        ENDIF
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
; ================= drawing mode and colors =================
;
; The drawing mode (AREA COL OPM) applies to every drawing command
; from here on: lines, rectangles, fills, dots, polys, curves, PAINT,
; PTN and GCOPY. GINIT resets it to 0: replace, CMSEL, no area.
;
; GMODE [m] -- set the whole mode, e.g. GMODE OMEOR+CMCL1+AMCLIP
; (default 0). GOPM op / GCMODE cm / GAMODE am set one field only.
;
GMODE   MACRO   MV
        IFB     <MV>
        XRA     A
        ELSE
        MVI     A,MV
        ENDIF
        STA     CZDM##
        ENDM
GOPM    MACRO   MV
        IFNB    <MV>
        MVI     A,MV
        ENDIF
        CALL    CZOPM##
        ENDM
GCMODE  MACRO   MV
        IFNB    <MV>
        MVI     A,MV
        ENDIF
        CALL    CZCMOD##
        ENDM
GAMODE  MACRO   MV
        IFNB    <MV>
        MVI     A,MV
        ENDIF
        CALL    CZAMOD##
        ENDM
;
; GBCOL [c] -- set CL0, the color a pattern's 0 bits draw (CMSEL,
; CMCL0). GINIT sets 0.
; GCCMP [c] -- set CCMP, the color OMEQ/OMNE compare pixels with
;
GBCOL   MACRO   CV
        IFNB    <CV>
        MVI     A,CV
        ENDIF
        CALL    CZCOL0##
        ENDM
GCCMP   MACRO   CV
        IFNB    <CV>
        MVI     A,CV
        ENDIF
        CALL    CZCCMP##
        ENDM
;
; GAREA x1,y1,x2,y2 -- set the area rectangle the AREA modes test,
; x1,y1 the low corner and x2,y2 the high one, both inside the area.
; GAFULL -- the area is the whole screen again (as after GINIT)
;
GAREA   MACRO   X1,Y1,X2,Y2
        CZLXY   X1,Y1
        CALL    CZAMIN##
        CZLXY   X2,Y2
        CALL    CZAMAX##
        ENDM
GAFULL  MACRO
        CALL    CZAFUL##
        ENDM
;
; GGETCP -- read back the drawing pointer: HL = X, DE = Y. Where an
; AREA stop mode stopped. Also clears ARD, so GWAIT and test SRARD
; first.
;
GGETCP  MACRO
        CALL    CZGCP##
        ENDM
;
; GRDOT x,y -- read the pixel at x,y (blank: in HL, DE): A = its color,
; NC; or C with A = 0 if x,y is off the screen
;
GRDOT   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRDOT##
        ENDM
;
; ================= the overlay =================
;
; A one-bit plane over the picture, one bit per pixel, shown in its own
; color (overlay color 2, GOVPAL) wherever a bit is set, while GOVON has
; it on. GINIT clears it, hides it and makes its color white.
;
; Every drawing macro draws on it between GOVL and GFRAME -- with the
; same X,Y as the frame -- at 1 bit per pixel, so its only colors are
; OVSET (bit on) and OVCLR (bit off): GCOLOR OVSET, or GBCOL OVCLR for a
; pattern's 0 bits. OMEOR toggles bits, which draws and undraws a
; cursor without touching the picture under it. CMPRAM tiles mean
; nothing at 1 bit per pixel. GOVL and GFRAME wait for the ACRTC to
; finish, and leave CP at 0,0 (ORG resets it): GMOVE after either.
;
OVSET   EQU     0FFH            ;GCOLOR OVSET: draw overlay bits on
OVCLR   EQU     0               ;GCOLOR OVCLR: draw them off
;
; GOVON / GOVOFF -- show / hide the overlay (what is in it stays)
; GOVPAL r,g,b -- the overlay's color (0..255 each). Clobbers BC, E.
; GOVL -- draw on the overlay from here on
; GFRAME -- draw on the frame again
; GOVCLS -- clear the whole overlay, from either
;
GOVON   MACRO
        CALL    CZOVON##
        ENDM
GOVOFF  MACRO
        CALL    CZOVOF##
        ENDM
GOVPAL  MACRO   RV,GV,BV
        MVI     B,RV
        MVI     C,GV
        MVI     E,BV
        CALL    CZOPAL##
        ENDM
GOVL    MACRO
        CALL    CZOVL##
        ENDM
GFRAME  MACRO
        CALL    CZFRM##
        ENDM
GOVCLS  MACRO
        CALL    CZOCLS##
        ENDM
;
; ================= text =================
;
; Text is drawn character by character with PTN (CZTXT.MAC), in CL1
; (GCOLOR) and the drawing mode, onto the frame or the overlay. It can be
; scaled 1-16 times and turned in 45-degree steps. A font is chosen by
; naming it, which is also what links it in, so a program carries only
; the fonts it names:
;   CZF8   8x8 cell, 5x7 glyphs (475 bytes)
;   CZF11  9x11 cell, 7x10 glyphs with descenders (855 bytes)
; The pen is the bottom-left corner of the next character's cell, and
; moves one cell (times the scale) along the direction per character.
; A string leaves the pattern RAM as GINIT does (GPDEF), so reload a
; pattern of your own after text.
;
TXOPAQ  EQU     1               ;GTATTR flag: the cell's 0 bits in CL0
;
; GFONT f -- draw text in font f (CZF8 or CZF11). Clobbers HL.
; GTPOS x,y -- put the pen at x,y (blank: in HL, DE); also the start of
; the line for GTNL
; GTATTR s[,d[,TXOPAQ]] -- scale s (1-16), direction d (0-7, rows 45
; degrees apart counter-clockwise from +X; default 0), TXOPAQ: draw the
; whole cell, its 0 bits in CL0 (GBCOL) -- text that covers what was
; there (GBCOL OVCLR on the overlay). Clobbers BC.
; GTEXT <'text'> -- draw the text, placed inline. Clobbers HL, B.
; GTSTR -- draw the B characters at HL
; GTCHR [c] -- draw the character c (blank: in A)
; GTNL -- a new line: the pen to the start of the line, one line on
; GTEXT, GTSTR and GTCHR return C, drawing nothing, until GFONT.
;
GFONT   MACRO   FV
        LXI     H,FV##
        CALL    CZTFNT##
        ENDM
GTPOS   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZTPOS##
        ENDM
GTATTR  MACRO   SV,DV,FV
        IFB     <DV>
        MVI     B,0
        ELSE
        MVI     B,DV
        ENDIF
        IFB     <FV>
        MVI     C,0
        ELSE
        MVI     C,FV
        ENDIF
        MVI     A,SV
        CALL    CZTATR##
        ENDM
GTEXT   MACRO   TV
        LOCAL   SKIP,STR,SEND
        JMP     SKIP
STR:    DB      TV
SEND:
SKIP:   LXI     H,STR
        MVI     B,SEND-STR
        CALL    CZTSTR##
        ENDM
GTSTR   MACRO
        CALL    CZTSTR##
        ENDM
GTCHR   MACRO   CV
        IFNB    <CV>
        MVI     A,CV
        ENDIF
        CALL    CZTCHR##
        ENDM
GTNL    MACRO
        CALL    CZTNL##
        ENDM
;
; ================= pattern RAM =================
;
; The ACRTC's pattern RAM is 16 words. In the bit color modes (CMSEL,
; CMCL1, CMCL0) word n is pattern row n and bit m its column m: bit 0
; is the leftmost pixel and row 0 the first row drawn (at the bottom of
; a fill). The pattern pointer walks it one bit per pixel -- along a
; line, round a rectangle, polygon or circle -- and, in a fill, one row
; per raster, inside the scan window set by GPSCAN (GINIT: all 16x16,
; pattern all ones). The pointer is live: it stays wherever the last
; drawing left it, so GPPTR it back before a fill that must line up.
;
; In CMPRAM the pattern RAM is instead a 4x4 tile of colors, word
; row*4+column, each word the color in both bytes (GTILE builds one).
;
; GPAT name,<w0,w1,...> -- define a pattern table (DW n, then n words)
; GTILE name,<c0,...,c15> -- define a CMPRAM tile table; c0..c3 are
; its bottom row, left to right
;
GPAT    MACRO   NM,WDS
        LOCAL   TEND
NM:     DW      (TEND-NM-2)/2
        IRP     V,<WDS>
        DW      V
        ENDM
TEND:
        ENDM
GTILE   MACRO   NM,CLS
        LOCAL   TEND
NM:     DW      (TEND-NM-2)/2
        IRP     V,<CLS>
        DW      (V)*101H
        ENDM
TEND:
        ENDM
;
; GLDPAT tbl[,pra] -- load a GPAT/GTILE table into the pattern RAM
; from word pra (default 0). HL is left pointing just past the table.
;
GLDPAT  MACRO   TV,PV
        CZLXY   TV
        IFB     <PV>
        XRA     A
        ELSE
        MVI     A,PV
        ENDIF
        CALL    CZLPAT##
        ENDM
;
; GPSCAN x0,y0,x1,y1[,zx,zy] -- the pattern scan window: columns
; x0..x1 and rows y0..y1 of the pattern RAM (0..15 each), each bit
; drawn zx+1 times across and zy+1 times up (default 1). Also puts
; the pointer at x0,y0. Clobbers HL.
; GPPTR x,y -- put the pattern pointer at column x, row y. Clobbers HL.
;
CZWP    MACRO   RN,VAL
        MVI     A,RN
        LXI     H,VAL
        CALL    CZWPR##
        ENDM
GPSCAN  MACRO   X0,Y0,X1,Y1,ZX,ZY
        CZWP    6,<(Y0)*1000H+(X0)*10H>
        IFB     <ZX>
        CZWP    7,<(Y1)*1000H+(X1)*10H>
        ELSE
        CZWP    7,<(Y1)*1000H+(ZY)*100H+(X1)*10H+(ZX)>
        ENDIF
        CZWP    5,<(Y0)*1000H+(X0)*10H>
        ENDM
GPPTR   MACRO   XV,YV
        CZWP    5,<(YV)*1000H+(XV)*10H>
        ENDM
;
; GPDEF -- the pattern RAM back as GINIT leaves it: all ones, the whole
; 16x16 scan window, no zoom, the pointer at 0,0
;
GPDEF   MACRO
        CALL    CZPDEF##
        ENDM
;
; GLSTYL pat[,zoom] -- line style: pattern row 0 = pat (bit 0 first),
; a 16x1 scan window with each bit drawn zoom+1 times, the pointer at
; its start. Every drawing then uses it, fills included; GLSTYL 0FFFFH
; is solid again. pat blank = in HL.
;
GLSTYL  MACRO   PV,ZV
        CZLXY   PV
        IFB     <ZV>
        XRA     A
        ELSE
        MVI     A,ZV
        ENDIF
        CALL    CZLSTY##
        ENDM
;
; GPTN x,y,w,h[,dir] -- draw the pattern RAM as a w x h pixel picture
; with its corner at x,y (x,y blank: at the CP), from the pointer,
; bit 0 of row 0 at the corner. dir: rows run dir*45 degrees CCW from
; +X, rows stacked 90 degrees further round (+PTSLNT: 45 -- slanted).
; CP ends one row past the last. w,h 1..256.
;
GPTN    MACRO   XV,YV,WV,HV,DV
        CZAT    XV,YV
        LXI     H,((HV)-1)*100H+(WV)-1
        IFB     <DV>
        XRA     A
        ELSE
        MVI     A,DV
        ENDIF
        CALL    CZPTN##
        ENDM
;
; ================= curves =================
;
; GCIRC x,y,r -- circle of radius r centred on x,y (x,y blank: on the
; CP; r blank: in HL). CP is left at the centre.
; GELLIP x,y,rx,ry -- ellipse with semi-axes rx (along X), ry (along
; Y), likewise (rx,ry blank: in HL,DE). Both radii up to 4095.
;
GCIRC   MACRO   XV,YV,RV
        CZAT    XV,YV
        CZLXY   RV
        CALL    CZCRCL##
        ENDM
GELLIP  MACRO   XV,YV,RX,RY
        CZAT    XV,YV
        CZLXY   RX,RY
        CALL    CZELPS##
        ENDM
;
; GARC xc,yc,xe,ye[,DIRCW] -- circular arc from the CP round the
; centre xc,yc (radius = the CP's distance from it), counter-clockwise
; unless DIRCW, to where it meets the ray from the centre through
; xe,ye. CP = xe,ye, which is not drawn.
; GRARC -- the same, the centre and xe,ye relative to the CP
; GEARC rx,ry,xc,yc,xe,ye[,DIRCW] -- elliptical arc: as GARC on an
; ellipse whose semi-axes are in the ratio rx:ry (only the ratio
; matters, each at most 90; the size comes from the CP)
; GREARC -- the same, relative. All four clobber HL.
;
CZARCM  MACRO   OP,DV,PTS
        LOCAL   SKIP,TBL
        JMP     SKIP
TBL:
        IRP     V,<PTS>
        DW      V
        ENDM
SKIP:   LXI     H,TBL
        IFB     <DV>
        MVI     A,OP
        ELSE
        MVI     A,OP+DV
        ENDIF
        CALL    CZARC##
        ENDM
GARC    MACRO   XC,YC,XE,YE,DV
        CZARCM  OPAARC,DV,<XC,YC,XE,YE>
        ENDM
GRARC   MACRO   XC,YC,XE,YE,DV
        CZARCM  OPRARC,DV,<XC,YC,XE,YE>
        ENDM
GEARC   MACRO   RX,RY,XC,YC,XE,YE,DV
        CZARCM  OPAEAR,DV,<(RX)*(RX),(RY)*(RY),XC,YC,XE,YE>
        ENDM
GREARC  MACRO   RX,RY,XC,YC,XE,YE,DV
        CZARCM  OPREAR,DV,<(RX)*(RX),(RY)*(RY),XC,YC,XE,YE>
        ENDM
;
; ================= PAINT and copy =================
;
; GPAINT x,y,e -- fill the area round x,y (blank: the CP) out to
; pixels of edge color e (blank: in A)
; GFLOOD x,y,c -- fill the connected region of color c round x,y (its
; edge is every other color): recolors one shape
; Both fill with the current color and pattern, and also stop at any
; pixel already in CL1 or CL0 (the chip's rule) -- so to paint over
; color 0 with GINIT's CL0 = 0, GBCOL something else first.
;
GPAINT  MACRO   XV,YV,EV
        CZAT    XV,YV
        IFNB    <EV>
        MVI     A,EV
        ENDIF
        CALL    CZPANT##
        ENDM
GFLOOD  MACRO   XV,YV,CV
        CZAT    XV,YV
        IFNB    <CV>
        MVI     A,CV
        ENDIF
        CALL    CZFLOD##
        ENDM
;
; GCOPY x1,y1,x2,y2,xd,yd[,t] -- copy the rectangle with corners
; x1,y1 and x2,y2 so that corner x1,y1 lands on xd,yd, transformed by
; t (a CP... transform, default CPNORM). The operation and area modes
; apply at the destination; the color mode doesn't (the source pixel
; is the color). CP ends one line past the last. Clobbers HL.
;
GCOPY   MACRO   X1,Y1,X2,Y2,XD,YD,TV
        LOCAL   SKIP,TBL
        GMOVE   XD,YD
        JMP     SKIP
TBL:    DW      X1,Y1,(X2)-(X1),(Y2)-(Y1)
SKIP:   LXI     H,TBL
        IFB     <TV>
        XRA     A
        ELSE
        MVI     A,TV
        ENDIF
        CALL    CZGCPY##
        ENDM
;
        .LIST
