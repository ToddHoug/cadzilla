; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
; CZ88GFX.INC -- CADzilla graphics library for z88dk: equates and macros
;
; cz88gfx is czgfx (software/m80/czgfx/) ported to z88dk's z80asm: the same
; 8080 code, routines, names and register conventions, built on the
; host into a z80asm library that links into an 8080, 8085 or Z80
; program. Use it from a .Z88 program built by tools/z88dk/z88build.sh:
;
;               INCLUDE "CZ88GFX.INC"
;
; with the project's cz88gfx.version pinning a release; z88build.sh then
; puts this file on the include path and links the library. See
; software/z88dk/cz88gfx/README.md.
;
; Coordinates: GINIT puts the ACRTC origin at the bottom-left pixel, so
; X runs 0..CZXMAX left to right and Y runs 0..CZYMAX BOTTOM to TOP.
;
; Register conventions (routines and macros alike):
;   - X arguments go in HL, Y arguments in DE, colors in A
;   - every routine preserves BC, DE and HL unless its entry below says
;     otherwise; A and the flags are always clobbered
;   - every macro argument is required: z80asm can't test for a blank
;     one. Where czgfx left an argument blank to mean "already in the
;     register" (GLINE ,100) or "at the CP" (GCIRC ,,7), load the
;     registers and CALL the routine the macro names instead (LXI D,100
;     / CALL CZLINE). Where it meant a default (GMODE, GTATTR 2), write
;     the default out (GMODE 0, GTATTR 2,0,0).
;   - a point or word list is one argument in parentheses:
;     GPTS TRI,(10,10,100,10,55,90). When the list is the macro's only
;     argument (GPLINE, GPOLY), double them -- GPOLY ((10,10,100,10,55,90))
;     -- or z80asm reads the parentheses as the call's own argument list.
;     Likewise an argument that starts with "(" but doesn't end with its
;     ")" is miscounted: write 0+(N+1)*2, not (N+1)*2.
;   - strings are double-quoted: GTEXT "Hello, world"
;   - an assembly-time counter (czgfx's SET) is DEFL, parenthesized:
;     N DEFL (N+1). z80asm substitutes a DEFL's text, so after two
;     N DEFL N+1, a GBOX at 10+N*19 lands at 10+0+1+1*19.
;   - everything but GMOVE/GRMOVE draws in the current drawing mode
;     (GMODE: operation, color and area modes; GINIT resets it)
;
; Externals: this file declares every library symbol EXTERN, so a
; program calls or reads any of them by name (CALL CZLDW, LHLD CZXMAX).
; z80asm links in only the library modules a program really references.
;
; Version: CZ88VER is this library's release, major in the high byte,
; minor in the low one. A release is software/z88dk/cz88gfx/releases/
; <major>.<minor>/ (CZ88GFX.LIB and this file); each project pins one in
; its software/<toolchain>/<project>/cz88gfx.version.
;
CZ88VER EQU     0101H           ;1.1
;
; ---- the library's symbols (see each module for its entry conditions) ----
;
        EXTERN  CZWREG,CZPUTW,CZWAIT,CZXY,CZSEND,CZRTAB,CZLDW,CZABT
        EXTERN  CZDM,CZCMD,CZXYM,CZWPR
        EXTERN  CZINIT,CZM640,CZM800,CZM1K,CZXMAX,CZYMAX,CZCLS,CZPDEF
        EXTERN  CZOCLS,CZMREG,CZDPB
        EXTERN  CZPALD,CZPALS
        EXTERN  CZCOL,CZMOVE,CZLINE,CZRECT,CZFRCT,CZDOT
        EXTERN  CZRMOV,CZRLIN,CZRRCT,CZRFRC
        EXTERN  CZPLL,CZPLG
        EXTERN  CZOPM,CZCMOD,CZAMOD,CZCOL0,CZCCMP,CZAMIN,CZAMAX,CZAFUL
        EXTERN  CZGCP,CZRDOT
        EXTERN  CZLPAT,CZLSTY,CZPTN,CZPSCN
        EXTERN  CZCRCL,CZELPS,CZARC
        EXTERN  CZPANT,CZFLOD,CZGCPY
        EXTERN  CZOVON,CZOVOF,CZOPAL,CZOVL,CZFRM
        EXTERN  CZTFNT,CZTSTR,CZTST
        EXTERN  CZTPOS,CZTATR,CZTCHR,CZTNL
        EXTERN  CZF8,CZF11
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
; CZLXY -- load HL = XV and DE = YV
;
CZLXY   MACRO   XV,YV
        LXI     H,XV
        LXI     D,YV
        ENDM
;
; GINIT mode -- set up the board and clear the screen to color 0. mode
; is a library descriptor: CZM640 (640x480), CZM800 (800x600) or CZM1K
; (1024x768). It must match the monitor the project's machine is
; strapped for (cad0 `mode`; 1024x768 unless the project's machine.toml
; says otherwise). For a descriptor of your own, LXI H,yours / CALL
; CZINIT instead. Clobbers all registers.
;
GINIT   MACRO   MV
        LXI     H,MV
        CALL    CZINIT
        ENDM
;
; GCLS c -- clear the whole screen to color c
;
GCLS    MACRO   CV
        MVI     A,CV
        CALL    CZCLS
        ENDM
;
; GCOLOR c -- set the drawing color to palette index c (in A: CALL CZCOL)
;
GCOLOR  MACRO   CV
        MVI     A,CV
        CALL    CZCOL
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
        CALL    CZPALS
        ENDM
;
; Single commands at X,Y (absolute) or dX,dY (relative to the CP). With
; X,Y already in HL,DE: CALL CZMOVE, CZLINE, CZRECT, CZFRCT, CZDOT,
; CZRMOV, CZRLIN, CZRRCT or CZRFRC.
;
GMOVE   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZMOVE
        ENDM
GLINE   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZLINE
        ENDM
GRECT   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRECT
        ENDM
GFRECT  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZFRCT
        ENDM
GDOT    MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZDOT
        ENDM
GRMOVE  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRMOV
        ENDM
GRLINE  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRLIN
        ENDM
GRRECT  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRRCT
        ENDM
GRFRCT  MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRFRC
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
; GFBOX x1,y1,x2,y2,c -- filled rectangle in color c (in the current
; color: GMOVE x1,y1 / GFRECT x2,y2)
;
GFBOX   MACRO   X1,Y1,X2,Y2,CV
        GCOLOR  CV
        GMOVE   X1,Y1
        GFRECT  X2,Y2
        ENDM
;
; GPLINE ((x0,y0,x1,y1,...)) -- open polyline through the points
; GPOLY  ((x0,y0,x1,y1,...)) -- closed polygon through the points
; (the list in double parentheses: it is the only argument)
; The point list is placed inline (and jumped over). At least 2 points.
; Clobbers HL.
;
GPLINE  MACRO   PTS
        LOCAL   SKIP,TBL,TEND
        JMP     SKIP
TBL:    DW      (TEND-TBL-2)/4
        REPTI   V,PTS
        DW      V
        ENDR
TEND:
SKIP:   LXI     H,TBL
        CALL    CZPLL
        ENDM
GPOLY   MACRO   PTS
        LOCAL   SKIP,TBL,TEND
        JMP     SKIP
TBL:    DW      (TEND-TBL-2)/4
        REPTI   V,PTS
        DW      V
        ENDR
TEND:
SKIP:   LXI     H,TBL
        CALL    CZPLG
        ENDM
;
; GPTS name,(x0,y0,x1,y1,...) -- define a named point table (in data,
; not inline) for GPLT/GPLG: DW count, then the X,Y pairs. A table too
; long for one line can be written out the same way by hand.
;
GPTS    MACRO   NM,PTS
        LOCAL   TEND
NM:     DW      (TEND-NM-2)/4
        REPTI   V,PTS
        DW      V
        ENDR
TEND:
        ENDM
;
; GPLT tbl / GPLG tbl -- polyline / polygon from a GPTS table.
; HL is left pointing just past the table.
;
GPLT    MACRO   TV
        LXI     H,TV
        CALL    CZPLL
        ENDM
GPLG    MACRO   TV
        LXI     H,TV
        CALL    CZPLG
        ENDM
;
; GWAIT -- wait for the ACRTC to finish drawing. Returns A = status
; register, Z set if the drawing ended cleanly, NZ on a command error.
;
GWAIT   MACRO
        CALL    CZWAIT
        ENDM
;
; GABORT -- abort the ACRTC (clears a command error, flushes the FIFOs)
;
GABORT  MACRO
        CALL    CZABT
        ENDM
;
; ================= drawing mode and colors =================
;
; The drawing mode (AREA COL OPM) applies to every drawing command
; from here on: lines, rectangles, fills, dots, polys, curves, PAINT,
; PTN and GCOPY. GINIT resets it to 0: replace, CMSEL, no area.
;
; GMODE m -- set the whole mode, e.g. GMODE OMEOR+CMCL1+AMCLIP; GMODE 0
; is GINIT's. GOPM op / GCMODE cm / GAMODE am set one field only (in A:
; CALL CZOPM, CZCMOD, CZAMOD).
;
GMODE   MACRO   MV
        MVI     A,MV
        STA     CZDM
        ENDM
GOPM    MACRO   MV
        MVI     A,MV
        CALL    CZOPM
        ENDM
GCMODE  MACRO   MV
        MVI     A,MV
        CALL    CZCMOD
        ENDM
GAMODE  MACRO   MV
        MVI     A,MV
        CALL    CZAMOD
        ENDM
;
; GBCOL c -- set CL0, the color a pattern's 0 bits draw (CMSEL,
; CMCL0). GINIT sets 0.
; GCCMP c -- set CCMP, the color OMEQ/OMNE compare pixels with
; (in A: CALL CZCOL0, CZCCMP)
;
GBCOL   MACRO   CV
        MVI     A,CV
        CALL    CZCOL0
        ENDM
GCCMP   MACRO   CV
        MVI     A,CV
        CALL    CZCCMP
        ENDM
;
; GAREA x1,y1,x2,y2 -- set the area rectangle the AREA modes test,
; x1,y1 the low corner and x2,y2 the high one, both inside the area.
; GAFULL -- the area is the whole screen again (as after GINIT)
;
GAREA   MACRO   X1,Y1,X2,Y2
        CZLXY   X1,Y1
        CALL    CZAMIN
        CZLXY   X2,Y2
        CALL    CZAMAX
        ENDM
GAFULL  MACRO
        CALL    CZAFUL
        ENDM
;
; GGETCP -- read back the drawing pointer: HL = X, DE = Y. Where an
; AREA stop mode stopped. Also clears ARD, so GWAIT and test SRARD
; first.
;
GGETCP  MACRO
        CALL    CZGCP
        ENDM
;
; GRDOT x,y -- read the pixel at x,y (in HL, DE: CALL CZRDOT): A = its
; color, NC; or C with A = 0 if x,y is off the screen
;
GRDOT   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZRDOT
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
        CALL    CZOVON
        ENDM
GOVOFF  MACRO
        CALL    CZOVOF
        ENDM
GOVPAL  MACRO   RV,GV,BV
        MVI     B,RV
        MVI     C,GV
        MVI     E,BV
        CALL    CZOPAL
        ENDM
GOVL    MACRO
        CALL    CZOVL
        ENDM
GFRAME  MACRO
        CALL    CZFRM
        ENDM
GOVCLS  MACRO
        CALL    CZOCLS
        ENDM
;
; ================= text =================
;
; Text is drawn character by character with PTN (CZTXT.Z88), in CL1
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
; GTPOS x,y -- put the pen at x,y (in HL, DE: CALL CZTPOS); also the
; start of the line for GTNL
; GTATTR s,d,f -- scale s (1-16), direction d (0-7, rows 45 degrees
; apart counter-clockwise from +X; 0 is GINIT's), flags f: 0, or
; TXOPAQ: draw the whole cell, its 0 bits in CL0 (GBCOL) -- text that
; covers what was there (GBCOL OVCLR on the overlay). Clobbers BC.
; GTEXT "text" -- draw the text, placed inline. Clobbers HL, B.
; GTSTR -- draw the B characters at HL
; GTCHR c -- draw the character c (in A: CALL CZTCHR)
; GTNL -- a new line: the pen to the start of the line, one line on
; GTEXT, GTSTR and GTCHR return C, drawing nothing, until GFONT.
;
GFONT   MACRO   FV
        LXI     H,FV
        CALL    CZTFNT
        ENDM
GTPOS   MACRO   XV,YV
        CZLXY   XV,YV
        CALL    CZTPOS
        ENDM
GTATTR  MACRO   SV,DV,FV
        MVI     B,DV
        MVI     C,FV
        MVI     A,SV
        CALL    CZTATR
        ENDM
GTEXT   MACRO   TV
        LOCAL   SKIP,STR,SEND
        JMP     SKIP
STR:    DB      TV
SEND:
SKIP:   LXI     H,STR
        MVI     B,SEND-STR
        CALL    CZTSTR
        ENDM
GTSTR   MACRO
        CALL    CZTSTR
        ENDM
GTCHR   MACRO   CV
        MVI     A,CV
        CALL    CZTCHR
        ENDM
GTNL    MACRO
        CALL    CZTNL
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
; GPAT name,(w0,w1,...) -- define a pattern table (DW n, then n words)
; GTILE name,(c0,...,c15) -- define a CMPRAM tile table; c0..c3 are
; its bottom row, left to right
;
GPAT    MACRO   NM,WDS
        LOCAL   TEND
NM:     DW      (TEND-NM-2)/2
        REPTI   V,WDS
        DW      V
        ENDR
TEND:
        ENDM
GTILE   MACRO   NM,CLS
        LOCAL   TEND
NM:     DW      (TEND-NM-2)/2
        REPTI   V,CLS
        DW      (V)*101H
        ENDR
TEND:
        ENDM
;
; GLDPAT tbl,pra -- load a GPAT/GTILE table into the pattern RAM from
; word pra (0: the start). HL is left pointing just past the table.
;
GLDPAT  MACRO   TV,PV
        LXI     H,TV
        MVI     A,PV
        CALL    CZLPAT
        ENDM
;
; GPSCAN x0,y0,x1,y1,zx,zy -- the pattern scan window: columns x0..x1
; and rows y0..y1 of the pattern RAM (0..15 each), each bit drawn zx+1
; times across and zy+1 times up (0,0: once). Also puts the pointer at
; x0,y0. Clobbers HL.
; GPPTR x,y -- put the pattern pointer at column x, row y. Clobbers HL.
;
CZWP    MACRO   RN,VAL
        MVI     A,RN
        LXI     H,VAL
        CALL    CZWPR
        ENDM
GPSCAN  MACRO   X0,Y0,X1,Y1,ZX,ZY
        CZWP    6,0+(Y0)*1000H+(X0)*10H
        CZWP    7,0+(Y1)*1000H+(ZY)*100H+(X1)*10H+(ZX)
        CZWP    5,0+(Y0)*1000H+(X0)*10H
        ENDM
GPPTR   MACRO   XV,YV
        CZWP    5,0+(YV)*1000H+(XV)*10H
        ENDM
;
; GPDEF -- the pattern RAM back as GINIT leaves it: all ones, the whole
; 16x16 scan window, no zoom, the pointer at 0,0
;
GPDEF   MACRO
        CALL    CZPDEF
        ENDM
;
; GLSTYL pat,zoom -- line style: pattern row 0 = pat (bit 0 first), a
; 16x1 scan window with each bit drawn zoom+1 times (0: once), the
; pointer at its start. Every drawing then uses it, fills included;
; GLSTYL 0FFFFH,0 is solid again. (pat in HL, zoom in A: CALL CZLSTY)
;
GLSTYL  MACRO   PV,ZV
        LXI     H,PV
        MVI     A,ZV
        CALL    CZLSTY
        ENDM
;
; GPTN x,y,w,h,dir -- draw the pattern RAM as a w x h pixel picture
; with its corner at x,y, from the pointer, bit 0 of row 0 at the
; corner. dir: rows run dir*45 degrees CCW from +X, rows stacked 90
; degrees further round (+PTSLNT: 45 -- slanted); 0 is upright. CP ends
; one row past the last. w,h 1..256. At the CP: LXI H,(h-1)*100H+w-1 /
; MVI A,dir / CALL CZPTN.
;
GPTN    MACRO   XV,YV,WV,HV,DV
        GMOVE   XV,YV
        LXI     H,0+((HV)-1)*100H+(WV)-1
        MVI     A,DV
        CALL    CZPTN
        ENDM
;
; ================= curves =================
;
; GCIRC x,y,r -- circle of radius r centred on x,y. CP is left at the
; centre. (On the CP, radius in HL: CALL CZCRCL.)
; GELLIP x,y,rx,ry -- ellipse with semi-axes rx (along X), ry (along
; Y), likewise (on the CP, rx,ry in HL,DE: CALL CZELPS). Both radii up
; to 4095.
;
GCIRC   MACRO   XV,YV,RV
        GMOVE   XV,YV
        LXI     H,RV
        CALL    CZCRCL
        ENDM
GELLIP  MACRO   XV,YV,RX,RY
        GMOVE   XV,YV
        CZLXY   RX,RY
        CALL    CZELPS
        ENDM
;
; GARC xc,yc,xe,ye,dir -- circular arc from the CP round the centre
; xc,yc (radius = the CP's distance from it), counter-clockwise for
; DIRCCW or clockwise for DIRCW, to where it meets the ray from the
; centre through xe,ye. CP = xe,ye, which is not drawn.
; GRARC -- the same, the centre and xe,ye relative to the CP
; GEARC rx,ry,xc,yc,xe,ye,dir -- elliptical arc: as GARC on an ellipse
; whose semi-axes are in the ratio rx:ry (only the ratio matters, each
; at most 90; the size comes from the CP)
; GREARC -- the same, relative. All four clobber HL.
;
CZARCM  MACRO   OP,PTS
        LOCAL   SKIP,TBL
        JMP     SKIP
TBL:
        REPTI   V,PTS
        DW      V
        ENDR
SKIP:   LXI     H,TBL
        MVI     A,OP
        CALL    CZARC
        ENDM
GARC    MACRO   XC,YC,XE,YE,DV
        CZARCM  OPAARC+(DV),(XC,YC,XE,YE)
        ENDM
GRARC   MACRO   XC,YC,XE,YE,DV
        CZARCM  OPRARC+(DV),(XC,YC,XE,YE)
        ENDM
GEARC   MACRO   RX,RY,XC,YC,XE,YE,DV
        CZARCM  OPAEAR+(DV),((RX)*(RX),(RY)*(RY),XC,YC,XE,YE)
        ENDM
GREARC  MACRO   RX,RY,XC,YC,XE,YE,DV
        CZARCM  OPREAR+(DV),((RX)*(RX),(RY)*(RY),XC,YC,XE,YE)
        ENDM
;
; ================= PAINT and copy =================
;
; GPAINT x,y,e -- fill the area round x,y out to pixels of edge color e
; (at the CP, e in A: CALL CZPANT)
; GFLOOD x,y,c -- fill the connected region of color c round x,y (its
; edge is every other color): recolors one shape (at the CP, c in A:
; CALL CZFLOD)
; Both fill with the current color and pattern, and also stop at any
; pixel already in CL1 or CL0 (the chip's rule) -- so to paint over
; color 0 with GINIT's CL0 = 0, GBCOL something else first.
;
GPAINT  MACRO   XV,YV,EV
        GMOVE   XV,YV
        MVI     A,EV
        CALL    CZPANT
        ENDM
GFLOOD  MACRO   XV,YV,CV
        GMOVE   XV,YV
        MVI     A,CV
        CALL    CZFLOD
        ENDM
;
; GCOPY x1,y1,x2,y2,xd,yd,t -- copy the rectangle with corners x1,y1
; and x2,y2 so that corner x1,y1 lands on xd,yd, transformed by t (a
; CP... transform; CPNORM: as it is). The operation and area modes
; apply at the destination; the color mode doesn't (the source pixel
; is the color). CP ends one line past the last. Clobbers HL.
;
GCOPY   MACRO   X1,Y1,X2,Y2,XD,YD,TV
        LOCAL   SKIP,TBL
        GMOVE   XD,YD
        JMP     SKIP
TBL:    DW      X1,Y1,(X2)-(X1),(Y2)-(Y1)
SKIP:   LXI     H,TBL
        MVI     A,TV
        CALL    CZGCPY
        ENDM
