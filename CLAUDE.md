# CLAUDE.md — CADzilla

Working notes for AI assistance on this project.

## What this project is

CADzilla is an S100 bus board based on the Hitachi HD63484 ACRTC combined with the Brooktree Bt453 video DAC. It contains 2 MBytes of video frame buffer memory and supports only 8 bits per pixel displays up to 1024x768 display resolution.
Includes: KiCAD schematics/PCB Layout, GAL PLD logic equations and programming files for the board's glue logic, and one or more software projects (assembly source) that target the
board and can be assembled/run on real S100/Altair bus hardware or altairsim emulator.

## Layout

- `schematics/` — KiCAD project files, libraries, fab outputs
- `pld/src/` — GAL16V8 source (equations), `pld/jed/` — assembled fuse maps
- `software/<project>/` — independent software projects targeting the board;
  each has its own `src/`, `include/`, `build/`, and `work/` (its own,
  gitignored altairsim CP/M disk — see `tools/altairsim/README.md`)
- `software/czgfx/` — the shared czgfx graphics-primitive library (M80
  macros + relocatable modules). It builds its own gitignored library disk,
  `software/czgfx/libdisk/CZGFX.DSK`, which M80 consumer projects (e.g.
  `software/gfxdemo/`) mount read-only as CP/M `B:` — see
  `software/czgfx/README.md`
- `tools/altairsim/pristine/` — master CP/M machine + disk images.
  **Never boot, `CONFIG LOAD` or `MOUNT` anything from here**; always use a
  project's own `work/`. Kept read-only on the host; its git status must
  stay clean.
- `docs/` — design notes, decisions, datasheets
- `tools/` — build/assemble/program scripts
- `tests/` — emulator test programs and expected output

## Conventions
The project name CADzilla should be used for all documentation and textual references.
However, lower case cadzilla should be used for all filename, directory or command line references.

Files that pass through the CP/M toolchain — assembly source and the build
artifacts it produces, i.e. everything under `software/<project>/src/` and
`software/<project>/build/` (`.ASM`, `.MAC`, `.INC`, `.SUB`, `.REL`, `.COM`,
`.HEX`, `.PRN`, etc.), plus CP/M disk images (`.DSK`) — are the
one exception to the lowercase rule above: they are UPPERCASE on **both**
the host and the CP/M side (8.3 names as they exist on the emulated CP/M
disk, e.g. `HELLO.ASM`), so the same name is used consistently everywhere.
Directory names (`software/hello/`, `src/`, `build/`) still follow the
normal lowercase rule — only the files themselves are uppercase. See
`tools/altairsim/README.md` for the CP/M-side mechanics this also
sidesteps: CP/M uppercases everything typed at its console anyway, so a
mixed-case CP/M-side name could never be created from the command line in
the first place.

Software toolchains (both run inside CP/M 2.2 on altairsim, driven over
its MCP server; `tools/altairsim/README.md`):
- **DRI `ASM.COM` + `LOAD.COM`** — the original flow: one self-contained
  `.ASM` per program, no INCLUDE/macros/linker (`hello`, `firstdraw`,
  `drawdemo`; skill `cadzilla-build-asm`).
- **Microsoft `M80` + `L80`** (3.44) — for new work and anything that draws:
  relocatable `.MAC` sources, macros, and the shared czgfx library linked
  from the `B:` library disk (`czgfx`, `gfxdemo`; skill `cadzilla-build-m80`).
- New projects: skill `new-cadzilla-project` (`--toolchain asm|m80`).

_TBD — fill in as tooling is chosen: KiCAD version, GAL assembler
(e.g. WinCUPL/GALasm), default git branch, commit attribution._

## Git attribution

- Only commit/push when the owner asks.
