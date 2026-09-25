# czgfx — CADzilla graphics primitive library

czgfx is the shared 8080 graphics library for CADzilla programs built with
Microsoft **M80/L80** under CP/M. It contains the board setup (MODE
register, HD63484 ACRTC control registers, Bt453 palette, ACRTC drawing
parameters) and the drawing primitives. Before czgfx, every program carried
its own copy of this code (`software/firstdraw`, `software/drawdemo`). It
comes in two parts:

- **`CZGFX.INC`**, the header a program `INCLUDE`s: board equates and the
  `G...` macros.
- **`CZGFX.REL`**, a LIB80 library of five relocatable modules (`CZPOLY`,
  `CZDRAW`, `CZINIT`, `CZPAL`, `CZCORE`). L80's `/S` search links in only the
  modules a program uses. A program that draws only boxes, for example, gets
  no polygon code.

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
   `LIB80 CZGFX=CZPOLY,CZDRAW,CZINIT,CZPAL,CZCORE/E`, in single-pass
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
        GINIT                   ;640x480, default palette, screen cleared
        GCOLOR  WHITE+BRIGHT
        GBOX    0,0,639,479
        GFBOX   280,200,360,280,BLUE+BRIGHT
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
  `GFXDEMO.MAC`).
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
  - the port names `ACRSR MODEREG ACRDAT DACADR DACPAL`;
  - the status bits `SR...`.

  Don't reuse these names in a program.
- The library never calls BDOS; console I/O is up to the program.

### Default palette

Index = hue × 32 + level. The hues are `ORANGE` 0, `BLUE` 32, `GREEN` 64,
`CYAN` 96, `RED` 128, `MAGENTA` 160, `YELLOW` 192 and `WHITE` 224. Levels run
0 (black) to 31 (`BRIGHT`) on a linear ramp.

### Macros

| Macro | Does | Notes |
|---|---|---|
| `GINIT [mode]` | set up board, palette and drawing parameters; clear to 0 | `CZM640` (default) or `CZM1K` (1024×768, monitor strapped for it); for your own descriptor use `LXI H,yours` / `CALL CZINIT##`. Clobbers all |
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

A point table is `DW n` followed by n X,Y pairs. `GPTS` builds one. For a
list too long for one source line, write the `DW`s by hand (`SINE` in
`GFXDEMO.MAC`). Argument lists with spaces in them (e.g.
`(N MOD 8)*32`) go in `<...>`.

### Routines

These can be called directly, written `NAME##` (see Conventions). The
macros are thin wrappers around them.

| Module | Routines |
|---|---|
| `CZINIT` | `CZINIT` (HL = mode descriptor), `CZCLS` (A = color); data `CZM640`, `CZM1K`, `CZXMAX`, `CZYMAX` |
| `CZDRAW` | `CZCOL`, `CZMOVE`, `CZLINE`, `CZRECT`, `CZFRCT`, `CZDOT`, `CZRMOV`, `CZRLIN`, `CZRRCT`, `CZRFRC` |
| `CZPOLY` | `CZPLL`, `CZPLG` (HL = point table) |
| `CZPAL` | `CZPALD` (load the default palette), `CZPALS` (A = index, B/C/E = R/G/B) |
| `CZCORE` | `CZWREG` (B = register, HL = value), `CZPUTW` (HL → FIFO), `CZWAIT`, `CZXY` (A = opcode, HL/DE), `CZSEND` (HL = table, BC = words), `CZRTAB`, `CZLDW`, `CZABT` |

### Not supported

The altairsim ACRTC model doesn't execute CRCL, ELPS, the arcs, PAINT, PTN,
AGCPY or RGCPY; it sets CER instead. czgfx therefore has no circle, ellipse
or fill primitives yet.

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
