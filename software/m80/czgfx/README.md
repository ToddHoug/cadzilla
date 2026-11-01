# czgfx — CADzilla graphics primitive library

czgfx is the shared 8080 graphics library for CADzilla programs built with
Microsoft **M80/L80** under CP/M. It contains the board setup (MODE
register, HD63484 ACRTC control registers, Bt453 palette, ACRTC drawing
parameters) and the drawing primitives. Before czgfx, every program carried
its own copy of this code (`software/asm/firstdraw`, `software/asm/drawdemo`). It
comes in two parts:

- **`CZGFX.INC`**, the header a program `INCLUDE`s: board equates and the
  `G...` macros.
- **`CZGFX.REL`**, a LIB80 library of fourteen relocatable modules
  (`CZPOLY`, `CZCURV`, `CZFILL`, `CZTXL`, `CZTXT`, `CZPAT`, `CZMODE`,
  `CZOVL`, `CZDRAW`, `CZINIT`, `CZFNT8`, `CZFN11`, `CZPAL`, `CZCORE`). L80's `/S` search links in only the modules a program uses. A
  program that draws only boxes, for example, gets no polygon or curve
  code.

`software/m80/gfxdemo/` is the worked example. The user guide,
`docs/czgfx-guide.pdf`, covers the library chapter by chapter with gfxdemo's
screens; regenerate it with `python3 software/m80/czgfx/tools/mkguide.py`.

## How it's delivered: versioned library disks

The library lives on a CP/M disk of its own, released in numbered versions.
A program builds against the release it pins in its own `work/`, so czgfx
can change without moving any program onto the new library, or making it
rebuild, until that program chooses to.

| Where | What |
|---|---|
| `software/m80/czgfx/src/` | sources: `CZGFX.INC`, `CZ*.MAC`, `CZBUILD.SUB`, `CZLINK.SUB`, `CZCHK.MAC` |
| `software/m80/czgfx/libdisk/CZGFXLIB.DSK` | **the build disk**: the library as last built from `src/` -- `CZGFX.INC`, `CZGFX.REL` and `CZLINK.SUB` (gitignored) |
| `software/m80/czgfx/releases/CZGFXLIB-<version>.DSK` | **the releases**: snapshots of the build disk, one per version, tracked and never changed |
| `software/m80/czgfx/build/` | `CZGFX.REL`, the module `.REL`s and the `.PRN` listings, pulled back to the host for reading (gitignored) |
| `software/m80/czgfx/work/` | czgfx's own altairsim machine: drive 0 is its CP/M disk, drive 1 the build disk, **writable** |

A program that uses czgfx:
- pins a release in its tracked `software/<toolchain>/<project>/czgfx.version`, a
  single line such as `1.1`;
- has its own copy of that release in `work/`, `CZGFXLIB-1.1.DSK`, which
  it mounts as **`B:`, read-only**.

`tools/altairsim/scripts/attach_libdisk.sh <work-dir>` makes the copy and
the mount. `new_project.sh --toolchain m80` pins the newest release and runs
it for you.

To move a program to another release:
1. edit its `czgfx.version`;
2. run `attach_libdisk.sh` on its `work/` again;
3. rebuild and relink it.

A pin of `dev` instead copies the current build disk, refreshed on every
attach. That is for trying an unreleased library in a program.

### Versions and releases

`CZGFX.INC` carries the version: `CZVERS EQU 0104H` (1.4), the major number in the
high byte and the minor in the low one, so a program can check it at
assembly time. To release:
1. raise `CZVERS`;
2. rebuild the library (below);
3. run `software/m80/czgfx/tools/release.sh`.

`release.sh` copies the build disk to `releases/CZGFXLIB-<major>.<minor>.DSK`
and makes it read-only. It refuses to overwrite an existing release, or to
release a build disk older than its sources. `git add` the new release.

| Release | Changes |
|---|---|
| 1.0 | the first release: drawing, curves, modes, pattern RAM, PAINT and copy, the overlay, text |
| 1.1 | WPTN's count is in words, as the real HD63484 takes it, even on the 8-bit bus. The manual's WPTN-1 says bytes; 1.0 sent byte counts, which made `GINIT` swallow its own setup words on the real board. `GINIT`, `GLDPAT`, `GLSTYL` and text are fixed. Needs an altairsim that counts words too (fork master from 2026-10-27); an older altairsim draws 1.1 wrongly |
| 1.2 | ellipses and elliptical arcs keep to the HD63484's ELPS parameter limit (see *Ellipses and the ELPS limit*), which 1.0 and 1.1 broke for all but small ellipses: the real board hangs (CED never sets), and altairsim doesn't check it. `GELLIP` uses ELPS only where it fits to within a pixel, and otherwise draws a polygon of 64-256 sides. `GEARC`/`GREARC` coarsen the rx:ry ratio to fit the arc's size, and refuse one too big for the chip (carry set, nothing drawn). New equate `OPRPLG` |
| 1.3 | `GPAINT`/`GFLOOD` (`CZPANT`/`CZFLOD`) finish the fill on the real chip. The chip keeps four pending seeds and hands any more to the host through the read FIFO, then stalls until they are read; 1.2 and earlier never read them, so a complex fill hung the board. They now drain the seeds and re-PAINT from each, return when the fill is done (CP back at the start point, the pattern pointer as it was), and return carry set if more than 32 seeds were pending at once. New public `CZRDW` (read a word from the read FIFO) |
| 1.4 | After an AREA stop mode (`AMSTOP`, `AMSTPI`) cuts a command short, the real HD63484 answers no RPR or RD until it is aborted, so in 1.3 `GGETCP`, `GRDOT`, `GPAINT`/`GFLOOD` and `GEARC`/`GREARC` (which read the CP) could hang the board (gfxdemo screen 7 did). The chip in fact drops every command after a stop until it is aborted, so after any command drawn in a stop mode czgfx aborts before sending the next one (`CZSTA`), and every read-back goes through `CZRDY`, which waits and always aborts (the real chip sets no ARD for a stop); the abort keeps the CP and the drawing parameters. `GINIT` now waits for its own screen and overlay clears before returning: on the real chip, commands queued behind them ended in a command error and a stalled FIFO whenever another program had run since the last hardware reset. `GABORT`/`CZABT` now keep the pixel depth too: they used to put the chip back to 8 bpp even while drawing on the overlay. `GPAINT`/`GFLOOD` refuse any color mode but `CMSEL` (carry set, nothing painted), because on the real chip a PAINT whose pixels aren't CL0 or CL1 never ends (gfxdemo screen 7's CMPRAM wedge hung the board), and give up with carry set at 4096 seeds. New public `CZRDY`, `CZPUTC` (send a command word), `CZSTA`, `CZSTM` and data `CZCCR`, `CZSTF` |

### Building the library

This is done on czgfx's own machine, from a clean `A0>`. The
`cadzilla-build-m80` skill has the full procedure.

```
tools/altairsim/scripts/crlf.sh software/m80/czgfx/src/*          # host: CR/LF
monitor {command: "CONFIG LOAD <repo>/software/m80/czgfx/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>"}
monitor {command: "SET hb0 HOSTDIR=<repo>/software/m80/czgfx/src"}
run {input: "R *.*\r", until: "A0>"}
run {input: "SUBMIT CZBUILD\r", timeout_ms: 120000}           # stops when idle
```

`CZBUILD.SUB` runs these steps:
1. assembles each module;
2. combines them into `CZGFX.REL` with
   `LIB80 CZGFX=CZPOLY,CZCURV,CZFILL,CZTXL,CZTXT,CZPAT,CZMODE,CZOVL,CZDRAW,CZINIT,CZFNT8,CZFN11,CZPAL,CZCORE/E`,
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

### Reference

The rest of the library guide is in [REFERENCE.md](REFERENCE.md); open only
the section the task needs.

- Conventions, display resolution, palette
- Macros and routines
- Ellipses and the ELPS limit, drawing modes, the pattern RAM
- PAINT, the overlay, text
- Not in czgfx yet, changing the library
