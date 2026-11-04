# cz88gfx — CADzilla graphics library for z88dk

cz88gfx is CADzilla's graphics primitive library for programs built on the
host with **z88dk**: assembly with z80asm (`tools/z88dk/z88build.sh`), and,
from release 1.1, **C** with zcc (`tools/z88dk/zccbuild.sh`; see
[Using it from C](REFERENCE.md#using-it-from-c)). It is a port of
czgfx (`software/m80/czgfx/`): the same board setup, drawing primitives, text and
overlay code, with the same routine names and register conventions. It is
built with modern host tools instead of M80/L80 inside CP/M.

The two libraries are independent and share no files. czgfx stays the
all-period-tools example (M80, LIB80, L80 and a CP/M library disk), and
cz88gfx serves the z88dk flow. A change to one doesn't reach the other.

cz88gfx comes in three parts:

- **`CZ88GFX.INC`**, the header an assembly program `INCLUDE`s: board
  equates, an `EXTERN` for every library symbol, and the `G...` macros.
- **`cz88gfx.h`**, the header a C program `#include`s (1.1 on): a
  prototype for every C entry point, and the constants.
- **`CZ88GFX.LIB`**, a z80asm library of the fifteen graphics modules
  (`CZPORT`, `CZCORE`, `CZINIT`, `CZPAL`, `CZDRAW`, `CZPOLY`, `CZMODE`, `CZPAT`,
  `CZCURV`, `CZFILL`, `CZOVL`, `CZTXT`, `CZTXL`, `CZFNT8`, `CZFN11`), plus,
  from 1.1, the C bindings' modules (`CZC*`). The linker takes only the
  modules a program references, so an assembly program never carries the
  C bindings. A program that only sets up the screen and draws a line is
  about 1,000 bytes in all (CZPORT, CZCORE, CZINIT, CZPAL and CZDRAW), with
  no curve, text or font code.

The library is **8080 code** in Intel mnemonics, assembled `-m8080`. z80asm
links it unchanged into an 8080, 8085 or Z80 program, so one library serves
every CPU a project's `machine.toml` can pick. Each module assembles to the
same bytes as czgfx 1.0's M80 module; that was checked against the M80
listings when the port was made. From 1.2, `CZINIT`, `CZPAT` and `CZTXT`
differ from czgfx 1.0 in WPTN's count (words, not bytes; see the release
table below), as czgfx 1.1 does.

`software/z88dk/z88demo/` is the worked example: gfxdemo's ten screens ported line
for line, built for the Z80. Each screen's frame, palette and overlay are
identical, pixel for pixel, to gfxdemo's (czgfx on the 8080).
`software/zcc/cgfxdemo/` is the same ten screens in C, again identical pixel for
pixel, on the Z80 and the 8080. The user guide, `docs/cz88gfx-guide.pdf`,
covers the library chapter by chapter for both languages, assembly and C side
by side, with the demo's screens; regenerate it with
`python3 software/z88dk/cz88gfx/tools/mkguide.py`.

## How it's delivered: versioned releases

| Where | What |
|---|---|
| `software/z88dk/cz88gfx/src/` | sources: `CZ88GFX.INC`, `CZ*.Z88` (one per module), `CZ88CHK.Z88` (the build check); the C bindings: `cz88gfx.h`, `CZC*.Z88`, `czcchk.c` (their build check) |
| `software/z88dk/cz88gfx/tools/` | `build.sh`, `release.sh`, `chkalign.py` (the ACRTC alignment check), `mkfont.py`, `mkguide.py` (the user guide) |
| `software/z88dk/cz88gfx/build/` | **the dev build**: `CZ88GFX.LIB`, module `.O`/`.LIS`, the checks' `.COM`/`.MAP`, `PAD0`-`PAD3.MAP` (gitignored) |
| `software/z88dk/cz88gfx/releases/<major>.<minor>/` | **the releases**: `CZ88GFX.LIB`, `CZ88GFX.INC` and (1.1 on) `cz88gfx.h`, tracked, read-only, never changed |

A program that uses cz88gfx pins a release in its tracked
`software/<toolchain>/<project>/cz88gfx.version`, a single line such as `1.1`. From that
pin, `z88build.sh` (or `zccbuild.sh`, for C) puts the release directory on
the include path and links its `CZ88GFX.LIB`. Nothing needs to be mounted or
copied, because the library is linked on the host. `new_project.sh
--toolchain z88dk` (or `zcc`) pins the newest release for you. A C program
needs 1.1 or later; `zccbuild.sh` refuses an older pin.

A pin of `dev` builds against the library's own `src/` and `build/` instead.
That is for trying an unreleased library in a program. `z88build.sh` warns if
the dev build is older than its sources (`zccbuild.sh` too).

To move a program to another release, edit its `cz88gfx.version` and rebuild
it.

### Versions and releases

`CZ88GFX.INC` carries the version: `CZ88VER EQU 0101H`, with the major number
in the high byte and the minor in the low one. `cz88gfx.h` carries it again as
`CZ88GFX_VERSION 0x0101`. To release:
1. raise `CZ88VER` and `CZ88GFX_VERSION` together;
2. rebuild the library (below);
3. run `software/z88dk/cz88gfx/tools/release.sh`;
4. `git add` the new release directory.

`release.sh` copies `build/CZ88GFX.LIB`, `src/CZ88GFX.INC` and
`src/cz88gfx.h` into `releases/<major>.<minor>/` and makes them read-only. It
refuses to overwrite an existing release, to release a library older than its
sources, or to release when the two version numbers disagree.

| Release | What changed |
|---|---|
| 1.0 | czgfx 1.0 ported to z80asm |
| 1.1 | the C bindings (`cz88gfx.h`, the `CZC*` modules); the graphics modules are byte-for-byte 1.0's |
| 1.2 | WPTN's count n is in words, as the real HD63484 counts it on the 8-bit bus (measured on two boards), not the manual's bytes: `CZINIT`'s pattern load, `CZLPAT`, `CZLSTY` and the text code. Before, a real board took twice the data each WPTN sent, so `GINIT` never set PRC, CL0, CL1, CCMP, EDG or MASK. Needs an altairsim that counts words too |
| 1.3 | two real-HD63484 hangs, ported from czgfx 1.2/1.3: `CZELPS` keeps ELPS's parameter limit or draws a polygon, and `CZARC` fits an elliptical arc to it or refuses it (see *Curves and the ELPS limit*); `CZPANT`/`CZFLOD` read back PAINT's overflow seeds (see *PAINT*). New public `CZRDW`, equate `OPRPLG`. In C, `cz_paint`, `cz_flood`, their `_cp` forms and `cz_earc_sq`/`cz_rearc_sq` return 0/1. `CZCURV`, `CZFILL` and `CZMODE` are byte-for-byte czgfx 1.3's |
| 1.4 | a third real-HD63484 hang: after a command cut short by an AREA stop mode the chip ignores every command, WPR and RPR until it is aborted, and sets no ARD. A drawing command sent in `AMSTOP`/`AMSTPI` is now marked (new public `CZMARK`, flag `CZSTPF`), and every routine that sends a command word starts with new public `CZSYNC` (C: `cz_sync`), which then waits and aborts (CCR ABT keeps the CP, the parameters and the depth). So whatever follows a stop line works, `GGETCP` included (see *Drawing modes*). `CZPANT`/`CZFLOD` fill only in CMSEL (CY, nothing drawn, in any other color mode: the real chip never ends such a fill) and abort a fill past 4096 seeds (CY); see *PAINT*. `CZINIT` returns only once its clears are done: a second program drawing straight behind them hung board B. `CZABT` (`GABORT`, `cz_abort`) aborts back to the CCR in force, kept in the new public `CZCCR` by `CZINIT`, `CZOVL` and `CZFRM`: before, it always went back to 8 bpp, which broke drawing on the overlay after an abort |
| 1.5 | every IN and OUT to the ACRTC is independent of where the linker puts the library. On the real board the opcode fetched right after an ACRTC access must have A1 = 0 after port 70H and A1 = 1 after port 72H (suspected cause of the AUTODEMO hangs on board A, which followed the address of that fetch; see *The ACRTC port accesses*). Those accesses now live in one new module, `CZPORT` (`CZWREG`, `CZPUTW`, `CZWAIT` and `CZRDW`, moved out of `CZCORE` and `CZMODE`, and new public `CZRSR`, the status read `CZFILL`'s PAINT poll used to do itself), in a section aligned to 4 with the accesses padded to the right address. `tools/build.sh` fails if any access could be followed by a fetch with the wrong A1, at any link base. No other change: pictures are identical to 1.4's, and the C bindings are unchanged |
| 1.6 | display timing as measured on the real HD63484 (`docs/design/video-timing-test.md`), ported from czgfx 1.5: every mode's front porch is now at least 5 memory cycles (the chip stretched the old 1-2 cycle porches, so every line was too long), and HDW is the visible fetches - 2 (the chip makes HDW+2 fetches, so the old value showed one extra word, the next line's first). 1024x768 assumes a 64 MHz oscillator. `CZM640` now uses interleaved access, for drawing speed: MODE `07H` (AMODE=1) and OMR ACM=10, and `CZINIT` sets OMR's ACM from the descriptor's MODE AMODE bit; it needs the 25.175 MHz oscillator. New equate `MDAMOD`. The C bindings are unchanged. altairsim still models the manual's rules, so its picture may sit 16 px off |

### Building the library

Everything runs on the host:

```
software/z88dk/cz88gfx/tools/build.sh
```

It does five things:
1. assembles every module in `src/` (except the check program) into
   `build/CZ88GFX.LIB`, with listings;
2. runs the repo's JP/CP lint over the sources (`tools/z88dk/z88common.sh`);
3. links **`CZ88CHK.Z88`** against the new library for the 8080, 8085 and
   Z80;
4. compiles **`czcchk.c`** with zcc for each CPU's C library and links it
   against the new library;
5. runs **`tools/chkalign.py`** (1.5): only `CZPORT` may touch the ACRTC's
   ports, and every access there must be followed by an opcode fetch with
   the right A1 at every link base, checked on the listings, on the check
   programs and on a stub linked behind 0 to 3 bytes of padding.

`CZ88CHK` expands every macro in the header, references every entry point,
and makes every register-form `CALL`. `czcchk.c` calls every C entry point
in `cz88gfx.h` and names every constant. A broken macro, a wrong prototype
or a missing `PUBLIC` therefore fails the library build rather than the
first program that uses it, as czgfx's `LIB80 /U` and `CZCHK` link do. The
build is good when it ends with six `check: ... links` lines (three
assembly, three C), two `align:` lines (the last is `ok`) and the library
size.

## Using it from assembly

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
echo 1.1 > software/<toolchain>/<project>/cz88gfx.version     # once
tools/z88dk/z88build.sh software/<toolchain>/<project>
```

Then `R <NAME>.COM` onto the project's disk and run it, as for any z88dk
project (skill `cadzilla-build-z88dk`). `build/<NAME>.MAP` shows which
library modules went in, and `build/<NAME>.SYM` includes the library's
labels for `SYMBOLS LOAD`.

### Reference

The rest of the library guide is in [REFERENCE.md](REFERENCE.md); open only
the section the task needs.

- Conventions, porting a czgfx program, display resolution, palette
- Macros and routines
- Drawing modes, the pattern RAM
- PAINT, curves and the ELPS limit
- The overlay, text, what is not in cz88gfx yet
- Using it from C: how the bindings work, conventions in C, the C functions
- Changing the library
