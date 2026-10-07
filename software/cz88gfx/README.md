# cz88gfx — CADzilla graphics library for z88dk

cz88gfx is CADzilla's graphics primitive library for programs built with
**z88dk's z80asm** on the host (`tools/z88dk/z88build.sh`). It is a port of
czgfx (`software/czgfx/`): the same board setup, drawing primitives, text and
overlay code, with the same routine names and register conventions. It is
built with modern host tools instead of M80/L80 inside CP/M.

The two libraries are independent and share no files. czgfx stays the
all-period-tools example (M80, LIB80, L80 and a CP/M library disk), and
cz88gfx serves the z88dk flow. A change to one doesn't reach the other.

cz88gfx comes in two parts:

- **`CZ88GFX.INC`**, the header a program `INCLUDE`s: board equates, an
  `EXTERN` for every library symbol, and the `G...` macros.
- **`CZ88GFX.LIB`**, a z80asm library of fourteen modules (`CZCORE`,
  `CZINIT`, `CZPAL`, `CZDRAW`, `CZPOLY`, `CZMODE`, `CZPAT`, `CZCURV`,
  `CZFILL`, `CZOVL`, `CZTXT`, `CZTXL`, `CZFNT8`, `CZFN11`). The linker
  takes only the modules a program references. A program that only sets
  up the screen and draws a line is 953 bytes in all (CZCORE, CZINIT,
  CZPAL and CZDRAW), with no curve, text or font code.

The library is **8080 code** in Intel mnemonics, assembled `-m8080`. z80asm
links it unchanged into an 8080, 8085 or Z80 program, so one library serves
every CPU a project's `machine.toml` can pick. Each module assembles to the
same bytes as czgfx 1.0's M80 module; that was checked against the M80
listings when the port was made.

`software/z88demo/` is the worked example: gfxdemo's ten screens ported line
for line, built for the Z80. Each screen's frame, palette and overlay are
identical, pixel for pixel, to gfxdemo's (czgfx on the 8080).

## How it's delivered: versioned releases

| Where | What |
|---|---|
| `software/cz88gfx/src/` | sources: `CZ88GFX.INC`, `CZ*.Z88` (one per module), `CZ88CHK.Z88` (the build check) |
| `software/cz88gfx/tools/` | `build.sh`, `release.sh`, `mkfont.py` |
| `software/cz88gfx/build/` | **the dev build**: `CZ88GFX.LIB`, module `.O`/`.LIS`, the check's `.COM`/`.MAP` (gitignored) |
| `software/cz88gfx/releases/<major>.<minor>/` | **the releases**: `CZ88GFX.LIB` and `CZ88GFX.INC`, tracked, read-only, never changed |

A program that uses cz88gfx pins a release in its tracked
`software/<project>/cz88gfx.version`, a single line such as `1.0`. From that
pin, `z88build.sh` puts the release directory on the include path and links
its `CZ88GFX.LIB`. Nothing needs to be mounted or copied, because the library
is linked on the host. `new_project.sh --toolchain z88dk` pins the newest
release for you.

A pin of `dev` builds against the library's own `src/` and `build/` instead.
That is for trying an unreleased library in a program. `z88build.sh` warns if
the dev build is older than its sources.

To move a program to another release, edit its `cz88gfx.version` and rebuild
it.

### Versions and releases

`CZ88GFX.INC` carries the version: `CZ88VER EQU 0100H`, with the major number
in the high byte and the minor in the low one. To release:
1. raise `CZ88VER`;
2. rebuild the library (below);
3. run `software/cz88gfx/tools/release.sh`;
4. `git add` the new release directory.

`release.sh` copies `build/CZ88GFX.LIB` and `src/CZ88GFX.INC` into
`releases/<major>.<minor>/` and makes them read-only. It refuses to
overwrite an existing release, or to release a library older than its
sources.

### Building the library

Everything runs on the host:

```
software/cz88gfx/tools/build.sh
```

It does three things:
1. assembles every module in `src/` (except the check program) into
   `build/CZ88GFX.LIB`, with listings;
2. runs the repo's JP/CP lint over the sources (`tools/z88dk/z88common.sh`);
3. links **`CZ88CHK.Z88`** against the new library for the 8080, 8085 and
   Z80.

`CZ88CHK` expands every macro in the header, references every entry point,
and makes every register-form `CALL`. A broken macro or a missing `PUBLIC`
therefore fails the library build rather than the first program that uses
it, as czgfx's `LIB80 /U` and `CZCHK` link do. The build is good when it
ends with three `check: ... links` lines and the library size.

## Using it from a program

```
        INCLUDE "CZ88GFX.INC"   ;equates, EXTERNs and macros
        ORG     0100H           ;the main module: a CP/M .COM
START:  ...
        GINIT   CZM1K           ;1024x768, default palette, screen cleared
        GCOLOR  WHITE+BRIGHT
        GBOX    0,0,1023,767
        GFBOX   448,320,576,448,BLUE+BRIGHT
        GWAIT                   ;Z = drawn cleanly, NZ = command error
        ...
```

```
echo 1.0 > software/<project>/cz88gfx.version     # once
tools/z88dk/z88build.sh software/<project>
```

Then `R <NAME>.COM` onto the project's disk and run it, as for any z88dk
project (skill `cadzilla-build-z88dk`). `build/<NAME>.MAP` shows which
library modules went in, and `build/<NAME>.SYM` includes the library's
labels for `SYMBOLS LOAD`.

### Conventions

These are czgfx's conventions. The places where cz88gfx differs are marked
**(z80asm)**.

- **Coordinates:** the origin is the **bottom-left** pixel. X runs
  0..`CZXMAX` left to right and Y runs 0..`CZYMAX` **bottom to top**.
- **Registers:**
  - X goes in HL, Y in DE, and a color (palette index) in A.
  - Every routine preserves BC, DE and HL unless noted, and always
    clobbers A and the flags.
- **Every macro argument is required (z80asm).** z80asm's macros can't
  test for a blank argument, so cz88gfx has none of czgfx's blank forms:
  - **"Already in a register" becomes a plain `CALL`.** Load the registers,
    then call the routine the macro names: `CALL CZLINE` for czgfx's bare
    `GLINE`; `LXI D,420` / `CALL CZMOVE` for `GMOVE ,420`; `LXI H,7` /
    `CALL CZCRCL` for `GCIRC ,,7` (round the CP).
  - **A default becomes explicit:** `GMODE 0`, `GCLS 0`, `GTATTR 2,0,0`,
    `GLSTYL 0FFFFH,0`, `GARC ...,DIRCCW`, `GCOPY ...,CPNORM`.
- **Lists go in parentheses (z80asm)**, not czgfx's `<...>`:
  `GPTS TRI,(480,448,576,704,400,640)`. When the list is a macro's **only**
  argument (`GPLINE`, `GPOLY`), double the parentheses:
  `GPOLY ((400,24,488,24,444,184))`. Otherwise z80asm reads the parentheses
  as the call's own argument list.
- **An argument that starts with `(` must end with its `)` (z80asm)**, or
  the arguments are miscounted. Write `GCOLOR 0+(N % 8)*32+BRIGHT`, not
  `GCOLOR (N % 8)*32+BRIGHT`.
- **Strings are double-quoted (z80asm):** `GTEXT "Hello, world"`. Single
  quotes are for single characters (`GTCHR 'A'`).
- **Assembly-time counters (z80asm):** czgfx's `SET` is `DEFL`, `MOD` is
  `%`, `IRP` is `REPTI`, and a `REPT`/`REPTI` ends with `ENDR`. **Always
  parenthesize a `DEFL` that refers to itself: `N DEFL (N+1)`.** z80asm
  substitutes a `DEFL`'s text rather than its value, so after two
  `N DEFL N+1`, `N*19` is `0+1+1*19` = 20. That is a silent wrong-picture
  bug, which the z88demo port hit.
- **Drawing mode:** every drawing command (everything except `GMOVE` and
  `GRMOVE`) is sent in the current drawing mode. See *Drawing modes* below.
- **Library symbols are plain names (z80asm).** The header declares them
  all `EXTERN`, so `CALL CZLDW` and `LHLD CZXMAX` just work. An `EXTERN`
  that nothing references costs nothing: z80asm links only the modules a
  program actually uses. (M80's `NAME##` is not z80asm syntax.)
- **Names:** every library global is `CZ` plus up to 4 characters, as in
  czgfx (z80asm has no 6-character limit, but the names are kept). Don't
  define `CZ...` names of your own. The header also defines, **without** a
  prefix:
  - the hue constants `ORANGE BLUE GREEN CYAN RED MAGENTA YELLOW WHITE`
    and `BRIGHT`;
  - the `OP...` opcodes;
  - the mode values `OM...`, `CM...` and `AM...`, the copy transforms
    `CP...`, and `DIRCW DIRCCW PTSLNT TXOPAQ`;
  - the overlay colors `OVSET OVCLR` and the MODE bits `MDOLEN MDOLSL`;
  - the port names `ACRSR MODEREG ACRDAT DACADR DACPAL DACOVL`;
  - the status bits `SR...`.

  Don't reuse these names in a program. Symbols are case-sensitive in
  z80asm, and all of these are upper case.
- **Intel mnemonics:** `JP` and `CP` take their Zilog meanings in z80asm
  (unconditional jump, compare). Intel jump-if-plus is `JP P,x`, and the
  build lints for it. The one such jump in czgfx (in `CZTXL`) is `JP P,NLA1`
  here.
- The library never calls BDOS; console I/O is up to the program.

### Porting a czgfx program

`software/z88demo/src/Z88DEMO.Z88` is `software/gfxdemo/src/GFXDEMO.MAC`
ported this way:

| czgfx (M80) | cz88gfx (z80asm) |
|---|---|
| `INCLUDE B:CZGFX.INC` / `CSEG` / `END START` | `INCLUDE "CZ88GFX.INC"` / `ORG 0100H` / (no `END`) |
| `CALL CZLDW##`, `LHLD CZXMAX##` | `CALL CZLDW`, `LHLD CZXMAX` |
| `GINIT` | `GINIT CZM640` (always name the mode) |
| `GCLS`, `GMODE` | `GCLS 0`, `GMODE 0` |
| `GCOLOR`, `GBCOL`, `GCCMP`, `GOPM`, `GCMODE`, `GAMODE`, `GTCHR` (A set) | `CALL CZCOL`, `CZCOL0`, `CZCCMP`, `CZOPM`, `CZCMOD`, `CZAMOD`, `CZTCHR` |
| `GMOVE`, `GLINE`, `GRECT`, `GFRECT`, `GDOT`, `GRDOT`, `GTPOS` (HL, DE set) | `CALL CZMOVE`, `CZLINE`, `CZRECT`, `CZFRCT`, `CZDOT`, `CZRDOT`, `CZTPOS` |
| `GMOVE ,420` | `LXI D,420` / `CALL CZMOVE` |
| `GCIRC` / `GCIRC ,,7` | `CALL CZCRCL` / `LXI H,7` / `CALL CZCRCL` |
| `GELLIP` / `GELLIP ,,20,10` | `CALL CZELPS` / `LXI H,20` / `LXI D,10` / `CALL CZELPS` |
| `GPAINT` / `GFLOOD` (at the CP, A set) | `CALL CZPANT` / `CALL CZFLOD` |
| `GPTN ,,16,16,d` (at the CP) | `LXI H,0F0FH` / `MVI A,d` / `CALL CZPTN` |
| `GPLT` (HL set) | `CALL CZPLL` |
| `GFBOX x1,y1,x2,y2` (no color) | `GMOVE x1,y1` / `GFRECT x2,y2` |
| `GTATTR 2` / `GTATTR 1,2` | `GTATTR 2,0,0` / `GTATTR 1,2,0` |
| `GLDPAT t` / `GLSTYL p` / `GPTN x,y,w,h` | `GLDPAT t,0` / `GLSTYL p,0` / `GPTN x,y,w,h,0` |
| `GPSCAN x0,y0,x1,y1` | `GPSCAN x0,y0,x1,y1,0,0` |
| `GARC xc,yc,xe,ye` (and `GRARC`, `GEARC`, `GREARC`) | `GARC xc,yc,xe,ye,DIRCCW` |
| `GCOPY x1,y1,x2,y2,xd,yd` | `GCOPY x1,y1,x2,y2,xd,yd,CPNORM` |
| `GAREA` (HL/DE set twice) | `CALL CZAMIN` / ... / `CALL CZAMAX` |
| `GPOLY <x0,y0,...>` / `GPLINE <...>` | `GPOLY ((x0,y0,...))` / `GPLINE ((...))` |
| `GPTS n,<...>`, `GPAT n,<...>`, `GTILE n,<...>` | `GPTS n,(...)`, `GPAT n,(...)`, `GTILE n,(...)` |
| `GTEXT <'text'>` | `GTEXT "text"` |
| `GCOLOR <(N MOD 8)*32>` | `GCOLOR 0+(N % 8)*32` |
| `N SET N+1` | `N DEFL (N+1)` |
| `IRP V,<a,b,c>` ... `ENDM` / `REPT n` ... `ENDM` | `REPTI V,a,b,c` ... `ENDR` / `REPT n` ... `ENDR` |
| `DB 'text',CR,LF,'$'` | `DB "text",CR,LF,'$'` |

### Display resolution

The board drives a fixed-frequency VESA monitor chosen by cad0's `mode` strap
in the project's machine file: 640x480, 800x600 or 1024x768. 1024x768 is the
default. A project that wants another resolution says so in its tracked
`software/<project>/machine.toml`; see `tools/altairsim/README.md`. `GINIT`
must be given the matching descriptor: `CZM640`, `CZM800` or `CZM1K`. The
board doesn't reject a mismatch. The picture just lands in the wrong place in
the monitor's frame, which `board_get cad0`'s `picture` line shows; it should
read the mode's full size `at (0,0)`.

### Default palette

Index = hue × 32 + level. The hues are `ORANGE` 0, `BLUE` 32, `GREEN` 64,
`CYAN` 96, `RED` 128, `MAGENTA` 160, `YELLOW` 192 and `WHITE` 224. Levels run
0 (black) to 31 (`BRIGHT`) on a linear ramp.

### Macros

Every argument is required. Each routine's register form is in *Routines*
below.

| Macro | Does | Notes |
|---|---|---|
| `GINIT mode` | set up board, palette and drawing parameters; clear to 0 | `CZM640`, `CZM800` or `CZM1K`; must match the project's monitor. Own descriptor: `LXI H,yours` / `CALL CZINIT`. Clobbers all |
| `GCLS c` | clear the screen to color c | |
| `GCOLOR c` | set the drawing color | |
| `GPAL i,r,g,b` | set palette entry i | clobbers BC, E |
| `GMOVE x,y` | move the drawing pointer (CP) | |
| `GLINE x,y` | line from CP to x,y | the end point is not drawn |
| `GRECT x,y` | rectangle outline, corners CP and x,y | CP unchanged |
| `GFRECT x,y` | filled rectangle, corners CP and x,y | |
| `GDOT x,y` | one pixel | |
| `GRMOVE` `GRLINE` `GRRECT` `GRFRCT dx,dy` | relative forms of the above | |
| `GSEG x1,y1,x2,y2` | line x1,y1 → x2,y2 | |
| `GBOX x1,y1,x2,y2` | rectangle outline | |
| `GFBOX x1,y1,x2,y2,c` | filled rectangle in color c | in the current color: `GMOVE` + `GFRECT` |
| `GPLINE ((x0,y0,x1,y1,...))` | open polyline, points inline | at least 2 points; clobbers HL |
| `GPOLY ((x0,y0,x1,y1,...))` | closed polygon, points inline | at least 2 points; clobbers HL |
| `GPTS name,(x0,y0,...)` | define a named point table (in data) | |
| `GPLT tbl` / `GPLG tbl` | polyline / polygon from a table | HL ends up past the table |
| `GWAIT` | wait for drawing to finish | A = status; Z = OK, NZ = command error (CER) |
| `GABORT` | abort: flush the FIFOs, clear CER | |
| `GCIRC x,y,r` | circle of radius r centred on x,y | CP is left at the centre |
| `GELLIP x,y,rx,ry` | ellipse with semi-axes rx (X) and ry (Y), 0..4095 | |
| `GARC xc,yc,xe,ye,dir` | arc from the CP round xc,yc to the ray through xe,ye | dir `DIRCCW` or `DIRCW`; radius = the CP's distance from the centre; CP = xe,ye (not drawn). Clobbers HL |
| `GRARC xc,yc,xe,ye,dir` | the same, centre and end relative to the CP | clobbers HL |
| `GEARC rx,ry,xc,yc,xe,ye,dir` / `GREARC` | elliptical arc: semi-axes in the ratio rx:ry | only the ratio matters, each at most 90; the size comes from the CP. Clobbers HL |
| `GPAINT x,y,e` | fill round x,y out to pixels of color e | see *PAINT* below |
| `GFLOOD x,y,c` | fill the connected region of color c round x,y | recolors one shape |
| `GCOPY x1,y1,x2,y2,xd,yd,t` | copy a rectangle so its corner x1,y1 lands on xd,yd | t: `CPNORM`, `CPMIRX`, `CPMIRY`, `CPR180`, `CPTRAN`, `CPR90` (CCW), `CPR270` (CW), `CPATRN`. Clobbers HL |
| `GMODE m` | set the whole drawing mode, e.g. `OMEOR+CMCL1+AMCLIP` | `GMODE 0`: replace, `CMSEL`, no area |
| `GOPM op` / `GCMODE cm` / `GAMODE am` | set one field of the drawing mode | |
| `GBCOL c` | set CL0, the color a pattern's 0 bits draw | GINIT: 0 |
| `GCCMP c` | set CCMP, the compare color of `OMEQ`/`OMNE` | |
| `GAREA x1,y1,x2,y2` | set the area rectangle (low corner, high corner; both inside) | |
| `GAFULL` | the area is the whole screen again | |
| `GGETCP` | read the CP back: HL = X, DE = Y | clears ARD |
| `GRDOT x,y` | read the pixel at x,y: A = its color | C (A = 0) if x,y is off the screen; moves RWP |
| `GPAT name,(w0,...)` | define a pattern table (data) | `DW n`, then n words |
| `GTILE name,(c0,...,c15)` | define a `CMPRAM` 4x4 color tile (data) | c0..c3 is the bottom row |
| `GLDPAT tbl,pra` | load a table into the pattern RAM from word pra | HL ends up past the table |
| `GPSCAN x0,y0,x1,y1,zx,zy` | pattern scan window, zoom (0,0: none), pointer to x0,y0 | clobbers HL |
| `GPPTR x,y` | put the pattern pointer at column x, row y | clobbers HL |
| `GPDEF` | the pattern RAM, scan window and pointer back as `GINIT` leaves them | |
| `GLSTYL pat,zoom` | line style: pattern row 0 = pat, a 16x1 window | `GLSTYL 0FFFFH,0` is solid again |
| `GPTN x,y,w,h,dir` | draw the pattern RAM as a w x h picture at x,y | dir 0..7 = x45 degrees CCW, `+PTSLNT` slants it |
| `GOVON` / `GOVOFF` | show / hide the overlay | what is drawn in it stays |
| `GOVPAL r,g,b` | the overlay's color (Bt453 overlay color 2) | clobbers BC, E |
| `GOVL` | draw on the overlay from here on | waits for the ACRTC; CP = 0,0 |
| `GFRAME` | draw on the frame again | waits for the ACRTC; CP = 0,0 |
| `GOVCLS` | clear the whole overlay | works from either |
| `GFONT f` | draw text in font f: `CZF8` or `CZF11` | naming a font links it in; clobbers HL |
| `GTPOS x,y` | put the text pen at x,y (the bottom-left of the next cell) | also the start of the line for `GTNL` |
| `GTATTR s,d,f` | text scale 1-16, direction 0-7 (×45° CCW), flags 0 or `TXOPAQ` | clobbers BC |
| `GTEXT "text"` | draw the text (placed inline) at the pen | clobbers HL, B |
| `GTSTR` | draw the B characters at HL | |
| `GTCHR c` | draw one character | |
| `GTNL` | new line: the pen back to the line's start, one line on | |

A point table is `DW n` followed by n X,Y pairs, and `GPTS` builds one. A
macro call must fit on one source line, so write a longer table's `DW`s by
hand (`SINE` in `Z88DEMO.Z88`).

### Routines

These are the macros' register forms, and can be called directly by name.

| Module | Routines |
|---|---|
| `CZINIT` | `CZINIT` (HL = mode descriptor), `CZCLS` (A = color), `CZOCLS` (clear the overlay), `CZPDEF` (the pattern defaults); data `CZM640`, `CZM800`, `CZM1K`, `CZXMAX`, `CZYMAX`, `CZMREG` (the MODE register's value), `CZDPB` (the mode's drawing parameter block) |
| `CZDRAW` | `CZCOL` (A = color), `CZMOVE`, `CZLINE`, `CZRECT`, `CZFRCT`, `CZDOT`, `CZRMOV`, `CZRLIN`, `CZRRCT`, `CZRFRC` (HL = X, DE = Y) |
| `CZPOLY` | `CZPLL`, `CZPLG` (HL = point table) |
| `CZCURV` | `CZCRCL` (HL = radius, round the CP), `CZELPS` (HL = rx, DE = ry, round the CP), `CZARC` (A = `OPAARC`/`OPRARC`/`OPAEAR`/`OPREAR` + `DIRCW`, HL = parameter table) |
| `CZFILL` | `CZPANT` (A = edge color), `CZFLOD` (A = region color), `CZGCPY` (A = transform, +10H for RGCPY; HL = Xs,Ys,DX,DY table) |
| `CZPAT` | `CZLPAT` (A = start word, HL = table), `CZLSTY` (HL = pattern, A = zoom), `CZPTN` (HL = size: H = height-1, L = width-1; A = direction), `CZPSCN` (HL = table: DB x0,y0,x1,y1,zx,zy -- the scan window at run time) |
| `CZMODE` | `CZOPM`, `CZCMOD`, `CZAMOD` (A = field value), `CZCOL0`, `CZCCMP` (A = color), `CZAMIN`, `CZAMAX` (HL = X, DE = Y), `CZAFUL`, `CZGCP` (returns HL = X, DE = Y), `CZRDOT` (HL = X, DE = Y: A = the pixel's color; C if off the screen) |
| `CZTXT` | `CZTFNT` (HL = font), `CZTSTR` (HL = text, B = length); data `CZTST`, the text state |
| `CZTXL` | `CZTPOS` (HL = X, DE = Y), `CZTATR` (A = scale, B = direction, C = flags), `CZTCHR` (A = character), `CZTNL` |
| `CZFNT8`, `CZFN11` | the fonts: data `CZF8`, `CZF11` |
| `CZOVL` | `CZOVON`, `CZOVOF` (show / hide), `CZOPAL` (B/C/E = R/G/B), `CZOVL` (draw on the overlay), `CZFRM` (draw on the frame) |
| `CZPAL` | `CZPALD` (load the default palette), `CZPALS` (A = index, B/C/E = R/G/B) |
| `CZCORE` | `CZWREG` (B = register, HL = value), `CZPUTW` (HL → FIFO), `CZWAIT`, `CZXY` (A = opcode, HL/DE), `CZXYM` (the same, with the drawing mode), `CZCMD` (A = opcode: the command word with the drawing mode), `CZWPR` (A = drawing parameter register, HL = value), `CZSEND` (HL = table, BC = words), `CZRTAB`, `CZLDW`, `CZABT`; data `CZDM`, the drawing mode byte |

### Drawing modes

The low byte of every ACRTC drawing command has three fields. cz88gfx keeps
them in one byte, `CZDM`, and adds it to each drawing command it sends.
`GINIT` resets it to 0. `GMODE` sets the whole byte, for example
`GMODE OMEOR+CMCL1+AMCLIP`. `GOPM`, `GCMODE` and `GAMODE` each change one
field and keep the other two.

- **Operation mode** (`OM...`, bits 2-0) says how the color C being drawn
  meets the pixel P already there: `OMREP` C; `OMOR` P OR C; `OMAND`
  P AND C; `OMEOR` P XOR C (drawing twice restores the picture); `OMEQ` /
  `OMNE` C only where P = / ≠ CCMP (`GCCMP`); `OMLT` / `OMGT` C only where
  P < / > C. The comparisons are on the palette index.
- **Color mode** (`CM...`, bits 4-3) says what each bit of the pattern RAM
  draws:
  - `CMSEL`: a 1 bit draws CL1 (`GCOLOR`) and a 0 bit CL0 (`GBCOL`);
  - `CMCL1`: a 1 bit draws CL1 and a 0 bit nothing;
  - `CMCL0`: a 0 bit draws CL0 and a 1 bit nothing;
  - `CMPRAM`: the pattern RAM is a 4x4 tile of colors (`GTILE`).
- **Area mode** (`AM...`, bits 7-5) is checked against the rectangle
  `GAREA` sets (`GINIT`: the whole screen):
  - `AMNONE`: no checking;
  - `AMCLIP` / `AMHOLE`: draw only inside / outside the area;
  - `AMCLPD` / `AMHOLD`: as those, and set ARD if a pixel was dropped;
  - `AMSTOP` / `AMSTPI`: stop at the first pixel outside / inside the
    area and set ARD.

  After a stop, the CP is the pixel where the drawing stopped. `GWAIT`
  returns the status, so `ANI SRARD` tests it. `GGETCP` reads the CP back
  and also clears ARD.

### The pattern RAM

The ACRTC draws every pixel through its 16-word pattern RAM, lines and fills
alike. `GINIT` loads it with all ones, so everything is drawn in CL1 until a
program changes it.

- **Layout.** In the bit color modes, word n is pattern row n and bit m is
  column m. Row 0 is the first row drawn (the bottom of a fill), and bit 0
  is the leftmost pixel. `GPAT` builds a table and `GLDPAT` loads it.
- **The pointer and scan window.** A pattern pointer walks the RAM, one
  bit per pixel along a line and one row per raster in a fill, inside the
  window `GPSCAN` sets. The pointer is **live**: it stays wherever the
  last drawing left it. Put it back with `GPPTR` (or `GPSCAN`) before a
  fill whose tiling must line up.
- **Line styles.** `GLSTYL pat,zoom` makes pattern row 0 the style, sets a
  16x1 window and resets the pointer. Fills use the style too, so restore
  it afterwards with `GLSTYL 0FFFFH,0`, or with `GPDEF`.
- **Color tiles.** In `CMPRAM`, word row\*4+column holds a color in both
  bytes. `GTILE` builds such a tile.
- **Drawing the pattern itself.** `GPTN` draws the pattern RAM as a small
  picture, turned in 45-degree steps and optionally slanted.

### PAINT

`GPAINT` fills out from a point, in the current color, pattern and modes,
up to pixels of the edge color. `GFLOOD` fills the connected region of one
color, recoloring it.

- **CL0 and CL1 are edges too.** The chip also stops at any pixel already in
  CL0 or CL1. `GINIT`'s CL0 is 0, so to paint over black, `GBCOL` something
  else first. For a solid fill, set CL0 to the fill color.
- **Outlines must be closed.** The fill is 4-connected. Lines don't draw
  their end point, so run spokes a pixel or two past the circle they meet.
- **The seed stack.** On the real chip, PAINT keeps only four pending seeds
  and hands the rest to the host to re-issue. The altairsim model has no
  such limit, and cz88gfx (like czgfx) doesn't implement the re-issue loop.

### The overlay

The board has a second plane over the 8-bit picture: the **overlay**, one
bit per pixel. Wherever a bit is set and the overlay is shown (`GOVON`), the
Bt453 shows the overlay color (`GOVPAL`) instead of the pixel's color. This
suits a cursor, a grid or selection marks.

- `GOVL` switches every drawing macro to the overlay, and `GFRAME` switches
  back. The coordinates are the frame's own.
- On the overlay, the only colors are `OVSET` (on) and `OVCLR` (off).
  `OMEOR` toggles bits, so drawing a shape twice undraws it. For `GPAINT`
  on the overlay, set `GBCOL OVSET` first. `CMPRAM` tiles mean nothing at
  1 bit per pixel.
- `GOVL` and `GFRAME` wait for the ACRTC and leave the CP at 0,0, so
  `GMOVE` after either.
- After `GINIT` the overlay is cleared and hidden, its color is white, and
  drawing is on the frame. `GOVCLS` clears it from either side.

For how the overlay works (the CHR screen, the per-mode ORGs in `CZDPB`, the
GBM switch), see *The overlay* in `software/czgfx/README.md`. The code is the
same.

### Text

Text is drawn one character at a time with the ACRTC's PTN command, in CL1
and the drawing mode, on the frame or the overlay. `GTATTR` scales it 1-16
times and turns it in 45-degree steps. It is transparent by default; with
`TXOPAQ`, each cell's 0 bits are drawn in CL0 (`GBCOL`), for text rewritten
in place.

```
        GOVL                    ;text on the overlay
        GCOLOR  OVSET
        GFONT   CZF11
        GTATTR  2,0,0           ;scale 2, along +X, transparent
        GTPOS   24,730
        GTEXT   "CADzilla text overlay"
        GTNL                    ;the next line, under it
        GFRAME
```

| Font | Cell | Glyphs | Bytes |
|---|---|---|---|
| `CZF8` | 8x8 | 5x7, no true descenders | 480 |
| `CZF11` | 9x11 | 7x10: capitals 8 rows, 2 descender rows | 860 |

- Naming a font with `GFONT` is what links it in.
- The **pen** is the bottom-left corner of the next character's cell, and
  moves one cell × scale along the direction per character.
- `GTNL` moves the line start one cell height × scale, 90° clockwise from
  the direction, and puts the pen there.
- Until `GFONT`, `GTEXT`, `GTSTR` and `GTCHR` return C and draw nothing.
  Characters outside 20H-7EH draw as a blank.
- A string leaves the pattern RAM as `GINIT` does (`CZPDEF`), and moves
  the CP.
- `CZTXT` (strings) is what every text program links. `CZTXL` adds the pen,
  attribute, character and newline calls. A program can skip `CZTXL` by
  storing into `CZTST` directly: +0/+2 the pen's X and Y, +8 the scale, +9
  the direction, +10 the flags.

`tools/mkfont.py` holds both fonts' glyph art (the same as czgfx's) and
writes `src/CZFNT8.Z88` and `src/CZFN11.Z88`; run
`python3 software/cz88gfx/tools/mkfont.py`. `--preview f.png` renders both
fonts to an image.

### Not in cz88gfx yet

- The ACRTC commands czgfx also lacks: CPY, SCPY, DRD, DWT, DMOD, WT, MOD,
  and most read-backs. Send them yourself with `CZCMD` or `CZPUTW`.
- **C bindings.** The library links only into `.Z88` assembly programs
  (`z88build.sh`). A C program (`zccbuild.sh`) can't use it yet: that needs
  `_`-prefixed sccz80 wrappers and the zcc section layout.
- **Z80-specific fast paths.** It is 8080 code everywhere. A Z80 program
  runs the same code an 8080 one does.

## Changing the library

- **New routine in an existing module:**
  - make it `PUBLIC` in the module;
  - add it to the `EXTERN` block in `CZ88GFX.INC`, and a macro if it
    helps;
  - exercise it in `CZ88CHK.Z88`.
- **New module:**
  - create `src/CZxxxx.Z88`: `INCLUDE "CZ88GFX.INC"`, `SECTION code_user`,
    and its `PUBLIC`s;
  - add its names to the header's `EXTERN` block.

  `build.sh` picks up every `.Z88` in `src/` except the check program.
  Unlike LIB80, z80asm has no module order to keep.
- Rebuild with `tools/build.sh`. Try it in a program pinned to `dev` (e.g.
  z88demo) if you like.
- Programs are not affected until they move: each builds against the
  release it pins.
- When the change is ready, raise `CZ88VER`, release it, then move the
  programs that want it to the new release.
