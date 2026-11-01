# tools/altairsim — reference

Sections split out of [README.md](README.md), which has the layout, disk images, build and session steps, the host bridge, and ending a session. Start there.

### Display resolution — each project pins its own

The CADzilla board drives a fixed-frequency VESA monitor chosen by cad0's
`mode` strap: **640x480, 800x600 or 1024x768**. A program programs the
ACRTC's timing for one of those, and the machine's strap has to agree. The
board does **not** reject a mismatch: a program timed for one mode on a
monitor strapped for another still "runs", but its picture lands in the
wrong place in the monitor's frame. (That happened when altairsim's own
board default moved from 640x480 to 1024x768: every project inherited the
new strap silently.)

So the resolution is stated, never inherited:

- **Pristine** `cadzilla.toml` sets `mode = "1024x768"` explicitly — the
  default for new projects.
- **Each project** that draws pins its own in a small tracked overlay,
  `software/<toolchain>/<project>/machine.toml`:
  ```toml
  [[board]]
  id   = "cad0"
  mode = "1024x768"   # or 640x480 / 800x600
  ```
  `sync_pristine.sh` appends it to the project's `work/cadzilla.toml` on
  every sync (a later `[[board]]` block for the same id overrides the
  pristine one), so it survives resyncs and fresh clones. The overlay may
  only contain `[[board]]` tables; the script refuses anything else. The
  `new-cadzilla-project` skill writes one for every new project
  (`--mode`, default 1024x768).
- **The code must match.** czgfx programs pass the matching descriptor to
  `GINIT`: `CZM640`, `CZM800` or `CZM1K` (bare `GINIT` means `CZM640`, so
  always name it). ASM programs carry their own register table — the
  values for each mode are in altairsim's `docs/boards/cadzilla.md`.

To **change** a project's resolution: edit its `machine.toml` and its
code, then `sync_pristine.sh --machine-only software/<toolchain>/<name>/work` (plus
`attach_libdisk.sh` again for an M80 project) and `CONFIG LOAD` it. To
**check** one: `board_get cad0` after a run — `mode` is the strap, and
`picture` should read the mode's full size `at (0,0)` with `wiring` `ok`. A
picture anywhere else, or smaller than the mode, means program and strap
disagree. To try another mode for one session without changing anything,
`monitor {command: "SET cad0 mode=800x600"}` works until the next `CONFIG
LOAD`.

### Choosing the CPU — `cpu0` in the same overlay

Pristine's machine has an 8080, the CPU of the `ASM.COM` and M80 projects. A
project built with z88dk (assembly or C) for an **8085 or Z80** puts that CPU in its
emulator with a `cpu0` block in its `machine.toml`:

```toml
[[board]]
type     = "z80"          # 8080 | 8085 | z80
id       = "cpu0"
clock_hz = 0
```

- A `[[board]]` with a `type` and an existing id **replaces** that board, so
  this swaps pristine's 8080 card for altairsim's 8085 or Z80 card. The
  replacement starts from scratch, which is why `clock_hz` is restated.
  `cadzilla-real.toml` still sets 2 MHz on top.
- CP/M 2.2, the DBL boot PROM and the BIOS are 8080 code, so they boot
  unchanged on all three cores. The tools on the disk (ASM, M80, ...) run as
  well.
- `tools/z88dk/z88build.sh` reads the same block for z80asm's `-m` flag, and
  `tools/z88dk/zccbuild.sh` reads it to choose zcc's C library. So a z88dk
  program and its machine can't disagree about the CPU. The
  `new-cadzilla-project` skill writes the block for every z88dk and zcc
  project (`--cpu`, default 8080).

To **change** it: edit the block, run `sync_pristine.sh --machine-only
software/<toolchain>/<name>/work`, then rebuild and `CONFIG LOAD`. To **check** it: the
register line `CONFIG LOAD` prints shows `IX`/`IY` and the alternate bank on a
Z80, and the extra `V`/`K` flags on an 8085. `SHOW cpu0` names the core.

### Running in real time — `work/cadzilla-real.toml`

`work/cadzilla.toml` runs flat out: the 8080 at host speed (`clock_hz = 0`)
and every ACRTC command done the moment it lands (cad0 `draw_rate =
"full"`). That is right for building and for most testing. For anything
timing-sensitive — a game, an animation, how long a big fill really takes —
load the project's `work/cadzilla-real.toml` instead. It is the same
machine (it has `base = "cadzilla.toml"`, so the project's disks, library
disk and resolution all carry over) with two straps changed:

- `cpu0` `clock_hz = 2000000` — a real 2 MHz Altair in wall-clock time.
- `cad0` `draw_rate = "real"` — each drawing command takes the time the
  HD63484 data sheet gives it, in the memory cycles the display leaves
  free, so the write FIFO fills and CED comes late, as on the board.

Build with `cadzilla.toml`, then switch to run:

```
monitor {command: "CONFIG LOAD <repo-root>/software/<toolchain>/<name>/work/cadzilla-real.toml"}
run {from: 0xFF00, until: "A0>"}
run {input: "<NAME>\r", until: "A0>", timeout_ms: 120000}
```

Don't build under it: at 2 MHz the assemblers take their real time, and
console input through `run` is paced (see pristine `cadzilla.toml`'s
`cpu0` note). It needs an altairsim with cad0's `draw_rate` strap; an
older binary refuses the file instead of running it untimed.
`sync_pristine.sh` copies it into every `work/`, so a new project gets it
with the rest; an existing `work/` gets it (or a changed version) from
`sync_pristine.sh --machine-only`.

### The prompt is `A0>`, not `A>`

`CPM22SYS.DSK` boots a CP/M build for an 8MB virtual drive, which
numbers logical units — the prompt is `A0>` (or `B0>` after `B:`), not the
plain `A>` of the old 8" floppy image. Every `until` in a `run` call needs
to match `A0>` — matching against `A>` simply never matches, so the call
runs to its full timeout instead of stopping cleanly at the prompt.

## The M80/L80 toolchain and the czgfx library

The pristine CP/M disk also carries Microsoft's MACRO-80 package:
- **M80.COM** (MACRO-80 3.44), the assembler
- **L80.COM** (LINK-80 3.44), the linker
- **LIB80.COM**, the librarian
- **CREF80.COM**, the cross-reference lister

LIB80 and CREF80 were added to the pristine disk on 2026-09-24 from
`MASM-80.ZIP`, after being validated on a separate test disk. That zip's
M80/L80 are byte-identical to the copies already on the disk. The
additions are:

| File | SHA-256 |
|---|---|
| `LIB80.COM` | `28f5af4a73e5317af265abde3d58658df13090bd28a59dafeb5a061f4623aaba` |
| `CREF80.COM` | `2e616ed60957d3179aca7a1acf0dfcf9e11cc4fbcddb7aacb216cdd8eff72218` |

Work disks copied before that date don't have the two new tools;
re-running `sync_pristine.sh` on a work dir brings them in, but that also
discards what's built on that disk.

- **LIB80** combines `.REL` modules into one library:
  - `LIB80 LIB=MOD1,MOD2,.../E` builds it
  - `LIB80 LIB/L/E` lists its modules, entry points and cross-references
  - `LIB80 LIB/U/E` lists the unresolved externals
  - L80 then searches it with `LIB/S`. Keep the module order right
    (callers before callees), because L80 searches in one pass.
- **CREF80** produces a cross-reference listing:
  - assemble with `M80 X,X=X/C`, which writes `X.CRF` instead of `X.PRN`
  - then `CREF80 X=X` writes `X.PRN`, the numbered listing plus a symbol
    table in which `#` marks the defining line

Unlike `ASM.COM`, M80 has `INCLUDE`, real macros (`MACRO`,
`REPT`, `IRP`, `LOCAL`, `IFNB`...), `PUBLIC`/`EXTRN`, and emits
relocatable `.REL` modules that L80 links into a `.COM`. That's what makes
a shared library possible:

- **`software/m80/czgfx/`** is the CADzilla graphics-primitive library. It has
  three parts:
  - the `CZGFX.INC` header: board equates and the `G...` drawing macros
  - `CZGFX.REL`, a LIB80 library of its fourteen modules
  - `CZLINK.SUB`, the link script (`L80 $1,B:CZGFX/S,$1/N$2/E`)

  API reference: `software/m80/czgfx/README.md`.
- czgfx builds all of that onto its **build disk**,
  `software/m80/czgfx/libdisk/CZGFXLIB.DSK` (gitignored — a build product),
  which czgfx's own `work/` mounts **writable** as drive 1.
- `software/m80/czgfx/tools/release.sh` snapshots the build disk as a numbered,
  tracked **release**, `software/m80/czgfx/releases/CZGFXLIB-<version>.DSK`.
  The version comes from `CZVERS` in `CZGFX.INC`.
- Every M80 consumer project:
  - pins a release in `software/<toolchain>/<project>/czgfx.version`;
  - mounts its own copy of that release from its `work/` as **`B:`,
    read-only** (`readonly = true` in its `work/cadzilla.toml`; `SHOW
    MOUNTS` says `(write-protected)`);
  - `INCLUDE`s `B:CZGFX.INC`, and links with `SUBMIT B:CZLINK <NAME>`.
    So it never lists library modules itself, and L80's `/S` search
    pulls in only the modules the program uses.

  A czgfx change reaches a project only when the project moves its pin.
  `software/m80/gfxdemo/` is the working example.

```
drive 0  A:  software/<toolchain>/<project>/work/CPM22SYS.DSK       the project's own disk
drive 1  B:  software/<toolchain>/<project>/work/CZGFXLIB-1.1.DSK   its czgfx release (read-only)
```

Build a consumer (from a clean `A0>` on the project's own machine):

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<toolchain>/<proj>/src"}
run {input: "R <NAME>.MAC\r", until: "A0>"}
run {input: "M80 <NAME>,<NAME>=<NAME>\r", until: "A0>", timeout_ms: 60000}   # -> .REL + .PRN
run {input: "SUBMIT B:CZLINK <NAME>\r", timeout_ms: 60000}                 # -> .COM (no until: stops when idle)
run {input: "<NAME>\r", until: "A0>"}
```

then `W <NAME>.COM` (binary) and `W <NAME>.PRN T` into `build/` as usual.

**A consumer never needs the library rebuilt**: it builds against its
pinned release. The build disk matters only to czgfx itself, and to a
project pinned to `dev`. Rebuild it when anything in `software/m80/czgfx/src/` is
newer than `libdisk/CZGFXLIB.DSK`, or the disk doesn't exist yet:
1. `CONFIG LOAD` czgfx's own `work/cadzilla.toml` and boot;
2. `R *.*` from `czgfx/src`, then `SUBMIT CZBUILD`;
3. `W` the `.REL`/`.PRN` into `czgfx/build`;
4. unmount both drives *before* switching the server to another project.

The `cadzilla-build-m80` skill has the full procedure.

M80/L80 gotchas (the `cadzilla-build-m80` skill has more):
- **Global names are 6 characters.** L80 keeps only the first 6 of a
  `PUBLIC`/`EXTRN` name — `LONGNAME1` and `LONGNAME2` link as one
  `%Mult. Def. Global LONGNA`.
- **Every `EXTRN` is a link request.** M80 emits even an unused `EXTRN`,
  and L80 then loads the module that defines it, so a header full of
  `EXTRN`s defeats library pruning. Reference library symbols inline as
  `NAME##` instead; that's what the czgfx macros do.
- With `/M` (link map), L80 stops at its `*` prompt after the map, even
  with `/E` on the line; type `/E` to finish.
- M80's default source extension is `.MAC`; the command is
  `M80 <rel>,<prn>=<src>`. Success prints `No Fatal error(s)`; also
  scan the `.PRN` for a flag letter in column 1.
- **L80 searches libraries in one pass**, both across `/S` files on the
  command line and across the modules inside a LIB80 library: a module
  must come after every module that references it. czgfx's library is
  built in that order, high-level first and `CZCORE` last, by the
  `LIB80 CZGFX=...` line in `CZBUILD.SUB`.
- Source must be relocatable: `CSEG`, no `ORG` — L80 puts the program at
  0100H.
- `SUBMIT` here is SuperSUB; it echoes each line at an `A0>` prompt, so
  don't use `until: "A0>"` on a `SUBMIT` — let the `run` stop when idle.

## The DRI RMAC/LINK toolchain

The pristine CP/M disk also carries Digital Research's relocating
assembler package, from the CP/M 3 distribution:
- **RMAC.COM** (RMAC 1.1), the relocating macro assembler
- **LINK.COM** (LINK-80 1.31), the linker
- **LIB.COM** (LIB 1.1), the librarian
- **XREF.COM** (XREF 1.3), the cross-reference lister

They are here for one thing L80 can't do. `LINK [OP]` writes a **`.PRL`**
(page-relocatable) file, which is the format of a GSX-80 device driver
(`DD*.PRL`). A project builds with them through its tracked
`src/<NAME>.SUB`. `software/rmac/rhello` is the example, the
`cadzilla-build-rmac` skill has the procedure, and `new-cadzilla-project
--toolchain rmac` scaffolds a new one.

They were added on 2026-10-08 from `yazecpm3.zip`, after being validated on
separate test disks:
- the image was staged on a copy and never mounted in place;
- 408 sectors changed: 2 directory sectors plus the tools' 406 records,
  all well-formed.

Where they came from, the licence, and how the two upstream copies of RMAC
differ are covered in `upstream/README.md`. `scripts/fetch_upstream.sh`
re-downloads them into the local, gitignored `upstream/`.

| File | SHA-256 |
|---|---|
| `RMAC.COM` | `d3132c8e356d0c8e71b53757445e7ef89e55dfda9dbda11c48cf7ede6c2c40f3` |
| `LINK.COM` | `714115910168df0900a41698551d518c921fe8329dae78378756f2445a4dc175` |
| `LIB.COM` | `2a7d7214b675396abaabc42b653d14bb07be409d9639a2e890ed08b9ad3edac5` |
| `XREF.COM` | `75bb1b8cb9aa6474583b02befe6d31fb476c11109ee034a34f8eb737e13ced7a` |

Work disks copied before that date don't have the tools. To add them
without losing what's built on a disk:
1. run `scripts/fetch_upstream.sh`;
2. on that project's booted machine,
   `SET hb0 HOSTDIR=<repo-root>/tools/altairsim/upstream/DRI`;
3. `R` each of the four tools.

They run unchanged on this CP/M 2.2. Verified on the 8080 machine:
- RMAC's source extension is `.ASM`. `RMAC X` writes `X.REL`, `X.PRN` and
  `X.SYM`.
- **`LINK X,Y`** links `X.REL` and `Y.REL` into `X.COM` (plus `X.SYM`).
  Name the output with `LINK OUT=X,Y`. Use `CSEG`/`DSEG`, `PUBLIC`/`EXTRN`
  and no `ORG`. LINK places code at 0100H and data right after it, and
  prints the globals and the segment sizes.
- **`LINK OUT=X,Y[OP]`** writes `OUT.PRL`:
  - a 256-byte header whose bytes 1–2 hold the image length;
  - the image itself, linked for **0100H** and byte-identical to the
    `.COM`;
  - a relocation bitmap, one bit per byte, MSB first. A set bit marks the
    high byte of a relocatable address. The loader adds (load page − 1)
    to each such byte, so absolute addresses such as `JMP 5` are left
    alone.
- **`LIB L=X,Y`** builds `L.REL`. `LINK MAIN,L[S]` searches it and loads
  only the modules that are needed.
- **`XREF X`** reads RMAC's `X.PRN` and `X.SYM` and writes `X.XRF`.
- **The REL files are compatible with Microsoft's tools.** L80 links
  RMAC's `.REL` files, and DRI LINK links M80's, including a mixed
  RMAC+M80 link. That's the path for a GSX driver whose code comes from
  F80 (Microsoft FORTRAN-80) or M80.

## GSX graphics

GSX-80 is DRI's device-independent graphics layer for CP/M (BDOS function
115). `software/rmac/ddcz` is the CADzilla GSX screen driver: three `.PRL`s, one
per display mode, built with RMAC + LINK against czgfx.
`software/rmac/ddcz/README.md` covers:
- what the driver implements;
- how to set up a disk for it;
- how it's tested, with GSXTEST, DEMOGRAF, DR Graph and
  `software/zcc/cgsxdemo` (a z88dk C client).

The runtime files are cached locally by `scripts/fetch_upstream.sh` and are
never tracked or put on pristine, because GSX-80's licence is unsettled
(`upstream/README.md`):
- the GDOS, `GSX.SYS`;
- `GENGRAF.COM`, which attaches the GSX loader to a program;
- the test programs and DR Graph.

To try GSX on a project's `work/` disk, `R` from `upstream/GSX/`:
- `GSX.SYS` and `GENGRAF.COM`;
- the driver;
- an `ASSIGN.SYS` naming the driver for workstation 01.

Then `GENGRAF` your program and run it. GSX programs need the 62K system
(above).
