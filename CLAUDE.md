# CLAUDE.md — CADzilla

Working notes for AI assistance on this project.

## What this project is

CADzilla is an S100 bus board based on the Hitachi HD63484 ACRTC combined with the Brooktree Bt453 video DAC. It contains about 2.2 MBytes of video memory in total:
- a 2 MByte frame buffer, U11-U18. It supports only 8 bits per pixel
  displays, up to 1024x768 display resolution.
- a 256 KByte 1bpp overlay, U19 (128K x16), mapped 1:1 onto frame-buffer
  pixels and shown in the Bt453's overlay color.
  - It is used for text, cursors, grids and annotations, and is drawn or
    cleared without touching the picture underneath.
  - It is drawn through an ACRTC screen with CHR set in its Memory Width
    register. That screen must never be displayed.
  - MODE register bits: OLEN shows or hides the overlay; OLSEL picks
    which 64K-word half a CHR screen addresses.
  - README.md, "MODE register", has the details.
Includes: KiCAD schematics/PCB Layout, GAL PLD logic equations and programming files for the board's glue logic, and one or more software projects (assembly source) that target the
board and can be assembled/run on real S100/Altair bus hardware or altairsim emulator.

## Layout

- `schematics/` — KiCAD project files, libraries, fab outputs
- `pld/src/` — GAL16V8 source (equations), `pld/jed/` — assembled fuse maps
- `software/<toolchain>/<project>/` — independent software projects targeting
  the board, grouped by toolchain. The `<toolchain>` directory names are the
  `--toolchain` values of new-cadzilla-project:
  - `asm/`: hello, firstdraw, drawdemo
  - `m80/`: czgfx, gfxdemo, czbasic, testpat
  - `rmac/`: rhello, ddcz
  - `z88dk/`: cz88gfx, zhello, z88demo, czdiag (the standalone board
    diagnostic: Bt453, ACRTC registers/FIFOs, clocks, video memory)
  - `zcc/`: chello, cgfxdemo, cgsxdemo, dxfview

  Each shared library lives with the toolchain that builds it. `rmac/ddcz`
  links czgfx, and the zcc projects use cz88gfx. A project name is unique
  across all the toolchain directories. Each project has its own `src/`,
  `include/`, `build/`, and `work/` (its own, gitignored altairsim CP/M disk — see `tools/altairsim/README.md`). A
  project that draws also has a tracked `machine.toml` overlay pinning its
  display resolution (cad0 `mode`: 640x480, 800x600 or 1024x768, default
  1024x768); the code's timing (`GINIT CZM...` or its own register table)
  must match it. A z88dk or zcc project's `machine.toml` also pins its CPU (a
  `cpu0` block: 8080, 8085 or z80), which the build and the emulator both
  follow.
  - Every project has a tracked `build.sh`, which runs `tools/build.sh` on
    itself. It builds the project's `work/` machine and disks, then its
    program, and puts the program on `A:`, with no assistant (below).
  - A project that the default recipe doesn't fit has a tracked
    `cpmbuild.conf`: czbasic, czgfx and dxfview.
- `software/m80/czgfx/` — the shared czgfx graphics-primitive library (M80
  macros + relocatable modules). It is deliberately built only with period
  tools (M80/LIB80/L80 inside CP/M), as the all-vintage example; the z88dk
  flow has its own port, cz88gfx (below).
  - It builds onto its gitignored build disk
    `software/m80/czgfx/libdisk/CZGFXLIB.DSK`.
  - `tools/release.sh` snapshots that disk as a tracked, never-changed
    release, `software/m80/czgfx/releases/CZGFXLIB-<version>.DSK` (version:
    `CZVERS` in `CZGFX.INC`).
  - An M80 consumer project (e.g. `software/m80/gfxdemo/`) pins a release in
    its tracked `czgfx.version`, and mounts its own copy of it from
    `work/` read-only as CP/M `B:`. So `work/` is self-contained, and a
    czgfx change reaches a project only when its pin moves.

  See `software/m80/czgfx/README.md`.
- `software/z88dk/cz88gfx/` — cz88gfx, czgfx ported to z88dk's z80asm: the same
  8080 routines, names and macros, but independent of czgfx (no shared
  files). From 1.1 it also has C bindings for zcc: `cz88gfx.h` and the
  `CZC*.Z88` stub modules, which jump into the same routines.
  - `tools/build.sh` builds it on the host into the gitignored
    `build/CZ88GFX.LIB`. It links the check programs `CZ88CHK` (assembly)
    and `czcchk.c` (C) for all three CPUs.
  - `tools/release.sh` snapshots that library, `CZ88GFX.INC` and
    `cz88gfx.h` into the tracked, read-only `releases/<version>/`. The
    version is `CZ88VER` in `CZ88GFX.INC`, matched by `CZ88GFX_VERSION` in
    `cz88gfx.h`.
  - A z88dk or zcc project pins a release (or `dev`) in its tracked
    `cz88gfx.version`. `tools/z88dk/z88build.sh` or `zccbuild.sh` then adds
    the include path and links the library; C needs 1.1 or later.
  - `software/z88dk/z88demo/` is gfxdemo ported to it. `software/zcc/cgfxdemo/` is
    the same in C, pixel-identical.

  See `software/z88dk/cz88gfx/README.md`.
- `tools/altairsim/pristine/` — master CP/M machine + disk images.
  **Never boot, `CONFIG LOAD` or `MOUNT` anything from here**; always use a
  project's own `work/`. Kept read-only on the host; its git status must
  stay clean.
- `docs/` — design notes, decisions, datasheets
- `tools/` — build/assemble/program scripts; `tools/z88dk/` is the z88dk host
  toolchain (`z88build.sh`, README)
  - `tools/setup.sh` is the fresh-clone setup. It checks the dependencies,
    then builds every project with `tools/build.sh`.
  - `tools/build.sh <project>` builds one project: it syncs `work/`, does
    the host build for z88dk/zcc, then the CP/M side.
  - The CP/M side is `tools/altairsim/scripts/cpmsession.py`. It drives
    `altairsim --mcp` headlessly, typing the same commands the skills do.
    Its transcript goes to `build/<NAME>.LOG`.
  - Never run it on a `work/` that the MCP server has loaded: both would
    write the same disk image.
  - `tools/demodisk.py` gathers every program but the hello examples
    onto one bootable 8MB disk, the gitignored `demodisk/CADZILLA.DSK`, with
    a Z80 machine to boot it (skill `cadzilla-demo-disk`).
- `tests/` — emulator test programs and expected output

## Conventions
The project name CADzilla should be used for all documentation and textual references.
However, lower case cadzilla should be used for all filename, directory or command line references.

Files that pass through the CP/M toolchain — assembly source and the build
artifacts it produces, i.e. everything under `software/<toolchain>/<project>/src/` and
`software/<toolchain>/<project>/build/` (`.ASM`, `.MAC`, `.Z88`, `.INC`, `.SUB`, `.REL`, `.COM`,
`.HEX`, `.PRN`, `.LIS`, `.MAP`, `.SYM`, etc.), plus CP/M disk images (`.DSK`) — are the
one exception to the lowercase rule above: they are UPPERCASE on **both**
the host and the CP/M side (8.3 names as they exist on the emulated CP/M
disk, e.g. `HELLO.ASM`), so the same name is used consistently everywhere.
Directory names (`software/asm/hello/`, `src/`, `build/`) still follow the
normal lowercase rule — only the files themselves are uppercase. See
`tools/altairsim/README.md` for the CP/M-side mechanics this also
sidesteps: CP/M uppercases everything typed at its console anyway, so a
mixed-case CP/M-side name could never be created from the command line in
the first place.

The one exception to *that*: a zcc project's C sources (`src/*.c`,
`include/*.h`) are lowercase. They never reach a CP/M disk, and zcc only
recognises a lowercase `.c`. The main module's name, uppercased, is still the
CP/M program name (`chello.c` → `CHELLO.COM`). Its `.Z88` modules and every
build output stay uppercase.

Licensing (`LICENSE` has the full map; the texts are in `LICENSES/`):
- The hardware is CERN-OHL-P-2.0: `schematics/`, `pld/`, and the board
  manual. The software is GPL-3.0-or-later: `software/`, `tools/`, `tests/`
  and `.claude/`. Datasheets and the third-party CP/M tools on the `.DSK`
  images keep their owners' terms.
- A new source file starts with an SPDX header in its own comment style,
  e.g. `; SPDX-License-Identifier: GPL-3.0-or-later` then
  `; Copyright (C) <year> Todd Houg` (`/* ... */` in `.pld`/`.c`, `#` in
  scripts; after `.XLIST` in an M80 `.INC`). `new_project.sh` and both
  `mkfont.py`s already emit it. `.SUB` and `.BAS` files carry none:
  SUBMIT has no comment syntax, and a `REM` would need a line number.
- Never edit a frozen release (`releases/`) or a KiCad file just to add a
  header.

Software toolchains (`tools/altairsim/README.md`):
- The first three run inside CP/M 2.2 (62K) on altairsim.
- Every toolchain builds with the project's `build.sh`, which drives
  altairsim headlessly. The MCP server is for running and debugging, and
  for a build step done by hand.
- **DRI `ASM.COM` + `LOAD.COM`** — the original flow: one self-contained
  `.ASM` per program, no INCLUDE/macros/linker (`hello`, `firstdraw`,
  `drawdemo`; skill `cadzilla-build-asm`).
- **Microsoft `M80` + `L80`** (3.44) — for new work and anything that draws:
  relocatable `.MAC` sources, macros, and the shared czgfx library linked
  from the project's pinned czgfx release on `B:` (`czgfx`, `gfxdemo`,
  `czbasic`; skill `cadzilla-build-m80`).
- **DRI `RMAC` + `LINK` 1.31** (plus `LIB`, `XREF`) — relocatable `.ASM`
  modules (`CSEG`/`DSEG`, `EXTRN`/`PUBLIC`, no `ORG`), built by the
  project's tracked `src/<NAME>.SUB` (`SUBMIT <NAME>`). `LINK [OP]` writes
  the `.PRL` files a GSX-80 driver needs, which L80 can't (`rhello`; skill
  `cadzilla-build-rmac`; "The DRI RMAC/LINK toolchain" in
  `tools/altairsim/README.md`).
  `software/rmac/ddcz` is the CADzilla GSX-80 screen driver built this way
  (`DDCZ1K`/`DDCZ800`/`DDCZ640.PRL`, linked with czgfx); `software/zcc/cgsxdemo`
  is a zcc GSX client. The GSX runtime is local-only
  (`tools/altairsim/scripts/fetch_upstream.sh`); see `software/rmac/ddcz/README.md`.
- **z88dk `z80asm`** (snap) — a host cross-assembler for the 8080, 8085 or
  Z80, taking Intel and/or Zilog mnemonics: `src/*.Z88` built on the host by
  `tools/z88dk/z88build.sh` into `build/<NAME>.COM`, which altairsim only
  `R`s onto the project's disk and runs. The CPU is the `cpu0` block in the
  project's `machine.toml`, which sets both z80asm's `-m` and the emulated
  CPU. Draws with cz88gfx, pinned in `cz88gfx.version` (`zhello`,
  `z88demo`; skill `cadzilla-build-z88dk`; `tools/z88dk/README.md`).
- **z88dk `zcc`** (snap) — **C** for the 8080, 8085 or Z80, compiled on the
  host by `tools/z88dk/zccbuild.sh`:
  - lowercase `src/*.c`, plus any `.Z88` assembly modules, become
    `build/<NAME>.COM`;
  - the compiler is sccz80, and the program links the classic CP/M C library;
  - the CPU comes from the same `cpu0` block, which picks zcc's C library;
  - `#include <cadzilla.h>` gives the board's ports as inline `IN`/`OUT`
    `__sfr`s. It lives in `tools/z88dk/include/` and is independent of
    czgfx;
  - draws with cz88gfx's C bindings, `#include <cz88gfx.h>`, pinned in
    `cz88gfx.version` (1.1 or later).

  Projects `chello`, `cgfxdemo` (draws) and `dxfview` (an AutoCAD R10 DXF
  viewer; its drawings are in `dxf/`, converted from DWG by its
  `tools/dwg2dxf.sh`). Skill `cadzilla-build-zcc`; see
  "C with zcc" in `tools/z88dk/README.md`.
- New projects: skill `new-cadzilla-project`
  (`--toolchain asm|m80|z88dk|zcc|rmac`, `--cpu 8080|8085|z80` for z88dk and zcc,
  `--mode WxH`).

_TBD — fill in as tooling is chosen: KiCAD version, GAL assembler
(e.g. WinCUPL/GALasm), default git branch, commit attribution._

## Git attribution

- Only commit/push when the owner asks.
