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
  each has its own `src/`, `include/`, `build/`
- `docs/` — design notes, decisions, datasheets
- `tools/` — build/assemble/program scripts
- `tests/` — emulator test programs and expected output

## Conventions
The project name CADzilla should be used for all documentation and textual references.
However, lower case cadzilla should be used for all filename, directory or command line references.

Files that pass through the CP/M toolchain — assembly source and the build
artifacts it produces, i.e. everything under `software/<project>/src/` and
`software/<project>/build/` (`.ASM`, `.COM`, `.HEX`, `.PRN`, etc.) — are the
one exception to the lowercase rule above: they are UPPERCASE on **both**
the host and the CP/M side (8.3 names as they exist on the emulated CP/M
disk, e.g. `HELLO.ASM`), so the same name is used consistently everywhere.
Directory names (`software/hello/`, `src/`, `build/`) still follow the
normal lowercase rule — only the files themselves are uppercase. See
`tools/altairsim/README.md` for the CP/M-side mechanics this also
sidesteps: CP/M uppercases everything typed at its console anyway, so a
mixed-case CP/M-side name could never be created from the command line in
the first place.

_TBD — fill in as tooling is chosen: KiCAD version, GAL assembler
(e.g. WinCUPL/GALasm), target emulator, assembler for the software projects,
default git branch, commit attribution._

## Git attribution

- Only commit/push when the owner asks.
