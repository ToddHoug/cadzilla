# CADzilla software

The programs and libraries in this directory run on the CADzilla board under
CP/M 2.2. They are tested on the altairsim emulator, and they also run on real
S100/Altair hardware. Projects are grouped by the toolchain that builds them:

```
software/
  asm/     DRI ASM + LOAD          hello  firstdraw  drawdemo
  m80/     Microsoft M80 + L80     czgfx (library)  gfxdemo  czbasic  testpat
  rmac/    DRI RMAC + LINK         rhello  ddcz
  z88dk/   z88dk z80asm            cz88gfx (library)  zhello  z88demo
  zcc/     z88dk zcc (C)           chello  cgfxdemo  cgsxdemo  dxfview
```

The directory names are the values of the `--toolchain` option used to create
a new project (see [Starting a new project](#starting-a-new-project)). Each
project name is used only once across all five directories.

## The toolchains

The first three toolchains are period tools and run inside CP/M on the
emulator. The two z88dk toolchains run on the host (Linux), and CP/M only
receives the finished `.COM` file.

### `asm/` — Digital Research ASM + LOAD

The original CP/M 2.2 assembler. A program is one self-contained
`src/<NAME>.ASM` with `ORG 0100H`. There are no include files, macros or
linker. It is built inside CP/M with:

```
A0>ASM <NAME>
A0>LOAD <NAME>
```

| Project | What it is |
|---|---|
| `hello` | Prints a greeting: the smallest working program |
| `firstdraw` | First-light test: sets up the board for 1024x768, loads the palette, draws a border and a test pattern |
| `drawdemo` | Steps through every HD63484 ACRTC drawing command, one screen per command |

### `m80/` — Microsoft M80 + L80

Microsoft's macro assembler and linker (3.44), the main toolchain for 8080
programs that draw. Sources are relocatable `.MAC` modules with macros. They
use the shared **czgfx** graphics library, which handles the board setup and
the drawing primitives.

A project pins a czgfx release in its `czgfx.version` file. Its emulated
machine mounts its own read-only copy of that release as drive `B:`. A
program is built inside CP/M with:

```
A0>M80 <NAME>,<NAME>=<NAME>
A0>SUBMIT B:CZLINK <NAME>
```

| Project | What it is |
|---|---|
| [`czgfx`](m80/czgfx/README.md) | The czgfx graphics library: macros and relocatable modules, built with M80, LIB80 and L80 into versioned releases |
| `gfxdemo` | A ten-screen demo of everything czgfx draws |
| [`czbasic`](m80/czbasic/README.md) | A BASIC interpreter that runs MBASIC 5.21 programs, with added graphics statements |
| [`testpat`](m80/testpat/README.md) | Bring-up test patterns for a new board. Each screen tells you which chips it exercises |

### `rmac/` — Digital Research RMAC + LINK

DRI's relocating assembler and linker (RMAC 1.1, LINK 1.31, plus LIB and
XREF). Sources are relocatable `.ASM` modules (`CSEG`/`DSEG`, `PUBLIC`/`EXTRN`,
no `ORG`). Each project's `src/<NAME>.SUB` builds it inside CP/M:

```
A0>SUBMIT <NAME>
```

LINK can also write a `.PRL` (page-relocatable) file, which is the format of
GSX-80 device drivers. L80 cannot write that format.

| Project | What it is |
|---|---|
| `rhello` | A two-module hello program: the starting point for RMAC projects |
| [`ddcz`](rmac/ddcz/README.md) | The CADzilla GSX-80 screen driver (`DDCZ1K`, `DDCZ800` and `DDCZ640.PRL`), linked with czgfx |

### `z88dk/` — z88dk z80asm (host cross-assembler)

z88dk's `z80asm` assembles on the host for the 8080, 8085 or Z80, and accepts
Intel and/or Zilog mnemonics. Sources are `src/*.Z88`. The target CPU comes
from the project's `machine.toml`, so the build and the emulated CPU always
match. Programs draw with **cz88gfx**, czgfx ported to z80asm, pinned in
`cz88gfx.version`. A program is built with:

```bash
tools/z88dk/z88build.sh software/z88dk/<name>      # -> build/<NAME>.COM
```

| Project | What it is |
|---|---|
| [`cz88gfx`](z88dk/cz88gfx/README.md) | The cz88gfx graphics library: czgfx's routines and macros for z80asm, plus C bindings for zcc |
| `zhello` | A hello program: the starting point for z88dk projects |
| `z88demo` | gfxdemo ported to z80asm and cz88gfx, running on a Z80 |

### `zcc/` — z88dk zcc (C)

z88dk's C compiler (sccz80 with the classic CP/M C library) compiles on the
host for the 8080, 8085 or Z80. Sources are lowercase `src/*.c` files, plus
any `.Z88` assembly modules. `#include <cadzilla.h>` gives direct access to
the board's I/O ports. `#include <cz88gfx.h>` gives the cz88gfx drawing
functions (release 1.1 or later). A program is built with:

```bash
tools/z88dk/zccbuild.sh software/zcc/<name>        # -> build/<NAME>.COM
```

| Project | What it is |
|---|---|
| `chello` | A hello program in C. An assembly module helps it report the CPU it was built for and the one it is running on |
| `cgfxdemo` | z88demo ported to C. It produces exactly the same pixels |
| `cgsxdemo` | A GSX-80 client in C that draws through the `ddcz` driver |
| [`dxfview`](zcc/dxfview/README.md) | An AutoCAD Release 10 DXF viewer, with 2D and 3D views. Zooming and panning redraw in seconds from a display list kept in the board's spare video memory. Comes with two vintage Space Shuttle drawings |

## What's in a project

Every project directory has the same layout:

| Path | Tracked | Contents |
|---|---|---|
| `src/` | yes | Source files |
| `include/` | yes | Project-local include files |
| `build/` | no | Build output: `.COM`, `.PRN`, `.REL`, `.MAP` and so on |
| `work/` | no | The project's own emulated machine (`cadzilla.toml`) and CP/M disks |
| `machine.toml` | yes | The display resolution (`640x480`, `800x600` or `1024x768`) and, for z88dk and zcc, the CPU |
| `czgfx.version` / `cz88gfx.version` | yes | The graphics library release the project builds against |

Naming rules:
- Directory names are lowercase.
- Files that pass through CP/M (`.ASM`, `.MAC`, `.Z88`, `.INC`, `.SUB`, `.COM`
  and so on) are UPPERCASE 8.3 names, on the host as well as in CP/M.
- C sources are lowercase, because zcc accepts only a lowercase `.c`.

Each project's `work/` is a private copy of the master machine in
`tools/altairsim/pristine/`. Never boot or mount anything from `pristine/`
directly. To create or refresh a project's `work/`, run
`tools/altairsim/scripts/sync_pristine.sh software/<toolchain>/<name>/work`. To
start the emulator on a project by hand:

```bash
cd software/<toolchain>/<name>/work && altairsim cadzilla.toml
```

It boots to CP/M's `A0>` prompt. `R <file>` copies a file from the host into
CP/M, and `W <file>` copies one back. Both use the directory set by the
emulator's `hb0 HOSTDIR`. For the full workflow, see
[tools/altairsim/README.md](../tools/altairsim/README.md).

## Starting a new project

Use the scaffold script. It creates the directory, a starter program that
builds, the `machine.toml`, the graphics library pin for the m80, z88dk and
zcc toolchains, and the project's own `work/` machine:

```bash
.claude/skills/new-cadzilla-project/scripts/new_project.sh <name> \
    --toolchain asm|m80|rmac|z88dk|zcc \
    [--cpu 8080|8085|z80] [--mode 640x480|800x600|1024x768] \
    [--cpm-name NAME] ["welcome message"]
```

- `<name>`: lowercase letters and digits, used only once across all the
  toolchain directories. The project is created in
  `software/<toolchain>/<name>/`.
- `--toolchain`: which toolchain to use. The default is `asm`.
- `--cpu`: for z88dk and zcc only. The default is `8080`.
- `--mode`: the display resolution. The default is `1024x768`.
- `--cpm-name`: the CP/M program name, when `<name>` is longer than 8
  characters.

For example:

```bash
.claude/skills/new-cadzilla-project/scripts/new_project.sh myprog --toolchain m80
.claude/skills/new-cadzilla-project/scripts/new_project.sh cdraw --toolchain zcc --cpu z80 --mode 800x600
```

Then build and run the project with its toolchain's commands above. If you
use Claude Code in this repo, you can instead ask it to "make a new project
called X". The `new-cadzilla-project` skill runs the same script, then builds
and runs the starter program on the emulator to prove the toolchain works.
After that, the `cadzilla-build-<toolchain>` skills handle building and
running.

## More detail

- [tools/altairsim/README.md](../tools/altairsim/README.md): the emulator and
  CP/M environment, moving files between the host and CP/M, display
  resolution, and the M80 and RMAC toolchains in depth.
- [tools/z88dk/README.md](../tools/z88dk/README.md): the z88dk toolchains,
  z80asm and zcc.
- [m80/czgfx/README.md](m80/czgfx/README.md) and
  [z88dk/cz88gfx/README.md](z88dk/cz88gfx/README.md): the graphics library
  APIs. The PDF guides are in [docs/](../docs/).

## License

All of the software here is Copyright (C) 2026 Todd Houg. It is licensed
under the [GNU General Public License](../LICENSES/GPL-3.0.txt), version 3
or (at your option) any later version. Each source file names this in its
`SPDX-License-Identifier` line. A program that links czgfx or cz88gfx is a
combined work, and the GPL covers it as a whole. The board itself is open
hardware under CERN-OHL-P-2.0. See [LICENSE](../LICENSE).
