# czgfx — CADzilla graphics primitive library

czgfx is the shared 8080 graphics library for CADzilla programs built with
Microsoft **M80/L80** under CP/M. It contains the board setup (MODE
register, HD63484 ACRTC control registers, Bt453 palette, ACRTC drawing
parameters) and the drawing primitives. Before czgfx, every program carried
its own copy of this code (`software/firstdraw`, `software/drawdemo`). It
comes in two parts:

- **`CZGFX.INC`**, the header a program `INCLUDE`s: board equates and the
  `G...` macros.
- **`CZGFX.REL`**, a LIB80 library of nine relocatable modules (`CZPOLY`,
  `CZCURV`, `CZFILL`, `CZPAT`, `CZMODE`, `CZDRAW`, `CZINIT`, `CZPAL`,
  `CZCORE`). L80's `/S` search links in only the modules a program uses. A
  program that draws only boxes, for example, gets no polygon or curve
  code.

`software/gfxdemo/` is the worked example.

## How it's delivered: the library disk

The library lives on a CP/M disk of its own:

| Where | What |
|---|---|
| `software/czgfx/src/` | sources: `CZGFX.INC`, `CZ*.MAC`, `CZBUILD.SUB`, `CZLINK.SUB`, `CZCHK.MAC` |
| `software/czgfx/libdisk/CZGFX.DSK` | **the library disk**: `CZGFX.INC`, `CZGFX.REL` and `CZLINK.SUB` (gitignored, since it is built from `src/`) |
| `software/czgfx/build/` | `CZGFX.REL`, the module `.REL`s and the `.PRN` listings, pulled back to the host for reading (gitignored) |
| `software/czgfx/work/` | czgfx's own altairsim machine: drive 0 is its CP/M disk, drive 1 is the library disk, **writable** |

Consumer projects mount the library disk as **`B:`, read-only**
(`tools/altairsim/scripts/attach_libdisk.sh <work-dir>`, which
`new_project.sh --toolchain m80` runs for you).

### Building the library

This is done on czgfx's own machine, from a clean `A0>`. The
`cadzilla-build-m80` skill has the full procedure.

```
tools/altairsim/scripts/crlf.sh software/czgfx/src/*          # host: CR/LF
monitor {command: "CONFIG LOAD <repo>/software/czgfx/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>"}
monitor {command: "SET hb0 HOSTDIR=<repo>/software/czgfx/src"}
run {input: "R *.*\r", until: "A0>"}
run {input: "SUBMIT CZBUILD\r", timeout_ms: 120000}           # stops when idle
```

`CZBUILD.SUB` runs these steps:
1. assembles each module;
2. combines them into `CZGFX.REL` with
   `LIB80 CZGFX=CZPOLY,CZCURV,CZFILL,CZPAT,CZMODE,CZDRAW,CZINIT,CZPAL,CZCORE/E`,
   in single-pass
   search order: every module comes before the modules it calls;
3. checks the library with `LIB80 CZGFX/U/E`, which lists any unsatisfied
   external requests and prints nothing when the library is
   self-contained;
4. replaces the `.REL` on `B:` with `CZGFX.REL`, then copies `CZGFX.INC`
   and `CZLINK.SUB` there;
5. assembles **`CZCHK.MAC`** against the header *as published on `B:`*
   and links it with `SUBMIT B:CZLINK CZCHK`.

`CZCHK` expands every macro and references every entry point. A broken
macro, a missing `PUBLIC` or a wrong module order therefore fails the
library build rather than the first consumer. The build is good when:
- every assembly prints `No Fatal error(s)`
- `LIB80 /U` prints nothing
- L80 prints no `?Undefined` or `%Mult. Def.` lines

## Using it from a program

```
        INCLUDE B:CZGFX.INC     ;equates and macros
        CSEG                    ;relocatable -- no ORG
START:  ...
        GINIT   CZM1K           ;1024x768, default palette, screen cleared
        GCOLOR  WHITE+BRIGHT
        GBOX    0,0,1023,767
        GFBOX   448,320,576,448,BLUE+BRIGHT
        GWAIT                   ;Z = drawn cleanly, NZ = command error
        ...
        END     START
```

```
A0>M80 NAME,NAME=NAME
A0>SUBMIT B:CZLINK NAME
```

`CZLINK.SUB` is `L80 $1,B:CZGFX/S,$1/N$2/E`. An optional second argument is
passed to L80 as an extra switch. `SUBMIT B:CZLINK NAME /M` prints the link
map, which shows which library modules were loaded. After a map, L80 stops
at its `*` prompt instead of exiting, so type `/E` to finish the link.

### Conventions

- **Coordinates:** the origin is the **bottom-left** pixel. X runs
  0..`CZXMAX` left to right and Y runs 0..`CZYMAX` **bottom to top**.
- **Registers:**
  - X goes in HL, Y in DE, and a color (palette index) in A.
  - Every routine preserves BC, DE and HL unless noted, and always
    clobbers A and the flags.
- **Blank macro arguments** mean "already in the register". For example,
  `GLINE ,100` draws to X = HL, Y = 100, and `GCOLOR` alone uses A. That
  is how computed coordinates go through the macros (see `SCR1` in
  `GFXDEMO.MAC`). The one exception is the point a shape is drawn round
  (`GCIRC`, `GELLIP`, `GPAINT`, `GFLOOD`, `GPTN`): leaving both x and y
  blank there means "at the CP", with no move, so `GCIRC` alone is a
  circle round the CP with its radius in HL.
- **Drawing mode:** every drawing command (everything except `GMOVE` and
  `GRMOVE`) is sent in the current drawing mode. See *Drawing modes* below.
- **Library symbols outside the macros are written `NAME##`**, M80's inline
  external, as in `CALL CZLDW##` or `LHLD CZXMAX##`. The macros do this
  themselves. Don't `EXTRN` library names you don't use: M80 turns every
  `EXTRN` into a link request, and L80 then loads that module whether
  anything calls it or not. Tested: one unused `EXTRN CZPLL` added CZPOLY's
  51 bytes to a program. That is also why the header has no `EXTRN` block.
- **Global names are 6 characters**, because L80 keeps only the first 6.
  Every czgfx global is `CZ` plus 4 characters or fewer. Don't define `CZ...`
  names of your own.
- The header also defines, **without** a prefix:
  - the hue constants `ORANGE BLUE GREEN CYAN RED MAGENTA YELLOW WHITE`
    and `BRIGHT`;
  - the `OP...` opcodes;
  - the mode values `OM...`, `CM...` and `AM...`, the copy transforms
    `CP...`, and `DIRCW DIRCCW PTSLNT`;
  - the port names `ACRSR MODEREG ACRDAT DACADR DACPAL`;
  - the status bits `SR...`.

  Don't reuse these names in a program.
- The library never calls BDOS; console I/O is up to the program.

### Display resolution

The board drives a fixed-frequency VESA monitor chosen by cad0's `mode`
strap in the project's machine file: 640x480, 800x600 or 1024x768.
1024x768 is the default (pristine `cadzilla.toml`); a project that wants
another one says so in its tracked `software/<project>/machine.toml` — see
`tools/altairsim/README.md`. `GINIT` must be given the matching descriptor
(`CZM640`, `CZM800`, `CZM1K`). The board doesn't reject a mismatch: the
picture just lands in the wrong place in the monitor's frame, which
`board_get cad0`'s `picture` line shows (it should read the mode's full
size `at (0,0)`). Name the descriptor explicitly even for 640x480 —
`GINIT` with no argument means `CZM640`, which no longer matches the
default machine.

### Default palette

Index = hue × 32 + level. The hues are `ORANGE` 0, `BLUE` 32, `GREEN` 64,
`CYAN` 96, `RED` 128, `MAGENTA` 160, `YELLOW` 192 and `WHITE` 224. Levels run
0 (black) to 31 (`BRIGHT`) on a linear ramp.

### Macros

| Macro | Does | Notes |
|---|---|---|
| `GINIT [mode]` | set up board, palette and drawing parameters; clear to 0 | `CZM640` (640×480, the default when omitted), `CZM800` (800×600) or `CZM1K` (1024×768). Must match the monitor the project's machine is strapped for — see *Display resolution* below. For your own descriptor use `LXI H,yours` / `CALL CZINIT##`. Clobbers all |
| `GCLS [c]` | clear the screen to color c (default 0) | |
| `GCOLOR [c]` | set the drawing color | |
| `GPAL i,r,g,b` | set palette entry i | clobbers BC, E |
| `GMOVE x,y` | move the drawing pointer (CP) | |
| `GLINE x,y` | line from CP to x,y | the end point is not drawn |
| `GRECT x,y` | rectangle outline, corners CP and x,y | CP unchanged |
| `GFRECT x,y` | filled rectangle, corners CP and x,y | |
| `GDOT x,y` | one pixel | |
| `GRMOVE` `GRLINE` `GRRECT` `GRFRCT dx,dy` | relative forms of the above | |
| `GSEG x1,y1,x2,y2` | line x1,y1 → x2,y2 | |
| `GBOX x1,y1,x2,y2` | rectangle outline | |
| `GFBOX x1,y1,x2,y2[,c]` | filled rectangle, optional color | |
| `GPLINE <x0,y0,x1,y1,...>` | open polyline, points inline | at least 2 points; clobbers HL |
| `GPOLY <x0,y0,x1,y1,...>` | closed polygon, points inline | at least 2 points; clobbers HL |
| `GPTS name,<x0,y0,...>` | define a named point table (in data) | |
| `GPLT tbl` / `GPLG tbl` | polyline / polygon from a table | HL ends up past the table |
| `GWAIT` | wait for drawing to finish | A = status; Z = OK, NZ = command error (CER) |
| `GABORT` | abort: flush the FIFOs, clear CER | |
| `GCIRC x,y,r` | circle of radius r centred on x,y | CP is left at the centre |
| `GELLIP x,y,rx,ry` | ellipse with semi-axes rx (X) and ry (Y), 0..4095 | |
| `GARC xc,yc,xe,ye[,DIRCW]` | arc from the CP round xc,yc to the ray through xe,ye | radius = the CP's distance from the centre; counter-clockwise unless `DIRCW`; CP = xe,ye (not drawn). Clobbers HL |
| `GRARC` | the same, centre and end relative to the CP | clobbers HL |
| `GEARC rx,ry,xc,yc,xe,ye[,DIRCW]` / `GREARC` | elliptical arc: semi-axes in the ratio rx:ry | only the ratio matters, each at most 90; the size comes from the CP. Clobbers HL |
| `GPAINT x,y,e` | fill round x,y out to pixels of color e | see *PAINT* below |
| `GFLOOD x,y,c` | fill the connected region of color c round x,y | recolors one shape |
| `GCOPY x1,y1,x2,y2,xd,yd[,t]` | copy a rectangle so its corner x1,y1 lands on xd,yd | transform t: `CPNORM` (default), `CPMIRX`, `CPMIRY`, `CPR180`, `CPTRAN`, `CPR90` (CCW), `CPR270` (CW), `CPATRN`. Clobbers HL |
| `GMODE [m]` | set the whole drawing mode, e.g. `OMEOR+CMCL1+AMCLIP` | default 0: replace, `CMSEL`, no area |
| `GOPM op` / `GCMODE cm` / `GAMODE am` | set one field of the drawing mode | |
| `GBCOL [c]` | set CL0, the color a pattern's 0 bits draw | GINIT: 0 |
| `GCCMP [c]` | set CCMP, the compare color of `OMEQ`/`OMNE` | |
| `GAREA x1,y1,x2,y2` | set the area rectangle (low corner, high corner; both inside) | |
| `GAFULL` | the area is the whole screen again | |
| `GGETCP` | read the CP back: HL = X, DE = Y | clears ARD |
| `GRDOT x,y` | read the pixel at x,y: A = its color | C (A = 0) if x,y is off the screen; moves RWP |
| `GPAT name,<w0,...>` | define a pattern table (data) | `DW n`, then n words |
| `GTILE name,<c0,...,c15>` | define a `CMPRAM` 4x4 color tile (data) | c0..c3 is the bottom row |
| `GLDPAT tbl[,pra]` | load a table into the pattern RAM from word pra | HL ends up past the table |
| `GPSCAN x0,y0,x1,y1[,zx,zy]` | pattern scan window, zoom, pointer to x0,y0 | clobbers HL |
| `GPPTR x,y` | put the pattern pointer at column x, row y | clobbers HL |
| `GPDEF` | the pattern RAM, scan window and pointer back as `GINIT` leaves them | |
| `GLSTYL pat[,zoom]` | line style: pattern row 0 = pat, a 16x1 window | `GLSTYL 0FFFFH` is solid again |
| `GPTN x,y,w,h[,dir]` | draw the pattern RAM as a w x h picture at x,y | dir 0..7 = x45 degrees CCW, `+PTSLNT` slants it |

A point table is `DW n` followed by n X,Y pairs. `GPTS` builds one. For a
list too long for one source line, write the `DW`s by hand (`SINE` in
`GFXDEMO.MAC`). Argument lists with spaces in them (e.g.
`(N MOD 8)*32`) go in `<...>`.

### Routines

These can be called directly, written `NAME##` (see Conventions). The
macros are thin wrappers around them.

| Module | Routines |
|---|---|
| `CZINIT` | `CZINIT` (HL = mode descriptor), `CZCLS` (A = color), `CZPDEF` (the pattern defaults); data `CZM640`, `CZM800`, `CZM1K`, `CZXMAX`, `CZYMAX` |
| `CZDRAW` | `CZCOL`, `CZMOVE`, `CZLINE`, `CZRECT`, `CZFRCT`, `CZDOT`, `CZRMOV`, `CZRLIN`, `CZRRCT`, `CZRFRC` |
| `CZPOLY` | `CZPLL`, `CZPLG` (HL = point table) |
| `CZCURV` | `CZCRCL` (HL = radius, round the CP), `CZELPS` (HL = rx, DE = ry, round the CP), `CZARC` (A = `OPAARC`/`OPRARC`/`OPAEAR`/`OPREAR` + `DIRCW`, HL = parameter table) |
| `CZFILL` | `CZPANT` (A = edge color), `CZFLOD` (A = region color), `CZGCPY` (A = transform, +10H for RGCPY; HL = Xs,Ys,DX,DY table) |
| `CZPAT` | `CZLPAT` (A = start word, HL = table), `CZLSTY` (HL = pattern, A = zoom), `CZPTN` (HL = size: H = height-1, L = width-1; A = direction), `CZPSCN` (HL = table: DB x0,y0,x1,y1,zx,zy -- the scan window at run time) |
| `CZMODE` | `CZOPM`, `CZCMOD`, `CZAMOD` (A = field value), `CZCOL0`, `CZCCMP` (A = color), `CZAMIN`, `CZAMAX` (HL = X, DE = Y), `CZAFUL`, `CZGCP` (returns HL = X, DE = Y), `CZRDOT` (HL = X, DE = Y: A = the pixel's color; C if off the screen) |
| `CZPAL` | `CZPALD` (load the default palette), `CZPALS` (A = index, B/C/E = R/G/B) |
| `CZCORE` | `CZWREG` (B = register, HL = value), `CZPUTW` (HL → FIFO), `CZWAIT`, `CZXY` (A = opcode, HL/DE), `CZXYM` (the same, with the drawing mode), `CZCMD` (A = opcode: the command word with the drawing mode), `CZWPR` (A = drawing parameter register, HL = value), `CZSEND` (HL = table, BC = words), `CZRTAB`, `CZLDW`, `CZABT`; data `CZDM`, the drawing mode byte |

### Drawing modes

The low byte of every ACRTC drawing command has three fields. czgfx keeps
them in one byte, `CZDM`, and adds it to each drawing command it sends.
`GINIT` resets it to 0. `GMODE` sets the whole byte, for example
`GMODE OMEOR+CMCL1+AMCLIP`. `GOPM`, `GCMODE` and `GAMODE` each change one
field and keep the other two.

- **Operation mode** (`OM...`, bits 2-0) says how the color C being
  drawn meets the pixel P already there:

  | Value | Result |
  |---|---|
  | `OMREP` | C (replace) |
  | `OMOR` | P OR C |
  | `OMAND` | P AND C |
  | `OMEOR` | P XOR C; drawing the same shape twice restores the picture |
  | `OMEQ` | C only where P = CCMP (`GCCMP`) |
  | `OMNE` | C only where P ≠ CCMP |
  | `OMLT` | C only where P < C |
  | `OMGT` | C only where P > C |

  The comparisons are on the palette index.
- **Color mode** (`CM...`, bits 4-3) says what each bit of the pattern
  RAM draws:

  | Value | A 1 bit draws | A 0 bit draws |
  |---|---|---|
  | `CMSEL` | CL1 (`GCOLOR`) | CL0 (`GBCOL`) |
  | `CMCL1` | CL1 | nothing (the pattern is transparent) |
  | `CMCL0` | nothing | CL0 |
  | `CMPRAM` | the pattern RAM is a 4x4 tile of colors (`GTILE`) | |

- **Area mode** (`AM...`, bits 7-5) is checked against the rectangle
  `GAREA` sets. `GINIT` sets that rectangle to the whole screen.

  | Value | Effect |
  |---|---|
  | `AMNONE` | no checking |
  | `AMCLIP` | draw only inside the area |
  | `AMHOLE` | draw only outside it |
  | `AMCLPD` / `AMHOLD` | as `AMCLIP` / `AMHOLE`, and set ARD if a pixel was dropped |
  | `AMSTOP` | stop at the first pixel outside the area and set ARD |
  | `AMSTPI` | stop at the first pixel inside the area and set ARD |

  After a stop, the CP is the pixel where the drawing stopped. `GWAIT`
  returns the status, so `ANI SRARD` tests it. `GGETCP` reads the CP back
  and also clears ARD.

### The pattern RAM

The ACRTC draws every pixel through its 16-word pattern RAM, fills and
lines alike. `GINIT` loads it with all ones, so everything is drawn in
CL1 until a program changes it.

- **Layout.** In the bit color modes, word n is pattern row n, and bit m
  is column m. Row 0 is the first row drawn, which is the bottom of a
  fill. Bit 0 is the leftmost pixel. `GPAT` builds a table and `GLDPAT`
  loads it.
- **The pointer and scan window.** A pattern pointer walks the RAM:
  - one bit per pixel along a line, continuing round the corners of a
    rectangle, polygon or circle;
  - one row per raster in a fill.

  `GPSCAN` sets the window it walks, and optionally a zoom that draws
  each bit several times. The pointer is **live**: it stays wherever the
  last drawing left it. Put it back with `GPPTR` (or `GPSCAN`) before a
  fill whose tiling must line up with something.
- **Line styles.** `GLSTYL` is the quick way to get dashed lines: pattern
  row 0 becomes the style, the window is 16x1 and the pointer is reset.
  Fills use the style too, so restore it afterwards: `GLSTYL 0FFFFH`, or
  `GLDPAT` all ones plus `GPSCAN 0,0,15,15`.
- **Color tiles.** In `CMPRAM` the RAM is a 4x4 tile of colors instead:
  word row\*4+column holds the color in both bytes. `GTILE` builds such a
  tile.
- **Drawing the pattern itself.** `GPTN` draws the pattern RAM as a small
  picture. It can be turned in 45-degree steps and slanted. A diagonal
  `GPTN` leaves gaps between its pixels, as the chip's does.

### PAINT

`GPAINT` fills out from a point in the current color, pattern and modes,
up to pixels of the edge color. `GFLOOD` instead fills the connected
region of one color, recoloring it.

- **CL0 and CL1 are edges too.** The chip also stops at any pixel that
  is already in CL0 or CL1, which is how it avoids refilling what it has
  just painted. `GINIT`'s CL0 is 0, so painting over black paints
  nothing until `GBCOL` sets CL0 to something else. For a solid fill,
  set it to the fill color.
- **Outlines must be closed.** The fill is 4-connected, so an
  8-connected outline (lines, circles) is enough to hold it. Lines don't
  draw their end point, though, so a spoke that ends exactly on a circle
  can leave a one-pixel gap. Run spokes a pixel or two past the circle.
- **No seed-stack limit.** On the real chip PAINT keeps only four
  pending seeds and hands the rest to the host through the read FIFO to
  be re-issued. The altairsim model has no such limit, and czgfx doesn't
  implement the re-issue loop, so one `GPAINT` fills a complex area there
  but may leave parts unfilled on the board.

### Not in czgfx yet

The ACRTC commands czgfx has no routine for are the word-address block
commands CPY, SCPY, DRD, DWT and DMOD, WT and MOD, and the read-backs
other than the CP and a single pixel (RPTN, most of RPR; `CZRDOT` uses
RD). `GCOPY` covers copying on screen,
in pixel units. For any of these, send the command word yourself: use
`CZCMD##` (with the drawing mode) or `CZPUTW##`, then `CZPUTW##` for each
parameter.

## Changing the library

- **New routine in an existing module:**
  - make it `PUBLIC` in the module
  - add a macro if it helps; the macro calls the routine as `NAME##`, never
    through an `EXTRN` in the header
  - exercise it in `CZCHK.MAC`
- **New module:**
  1. Create `CZxxxx.MAC`: `INCLUDE CZGFX.INC`, then its `PUBLIC`s and an
     `EXTRN` for each routine it calls in other modules.
  2. Add its `M80` line to `CZBUILD.SUB`.
  3. Add it to the `LIB80 CZGFX=...` list in `CZBUILD.SUB`, **after**
     every module that calls it and **before** every module it calls,
     because L80 searches the library in a single pass. `LIB80 /U` in
     the build flags a missing module. `CZLINK.SUB` doesn't change.
- Rebuild the library, then rebuild the consumers. Their `.COM` files have the
  old library code linked in until they are relinked.
