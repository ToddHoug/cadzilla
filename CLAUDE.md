# CLAUDE.md — cadzilla

Working notes for AI assistance on this project.

## What this project is

A board design project: KiCAD schematics/PCB, GAL16V8 PLD logic for the board's
glue logic, and one or more software projects (assembly source) that target the
board and are assembled/run on an emulator.

## Layout

- `schematics/` — KiCAD project files, libraries, fab outputs
- `pld/src/` — GAL16V8 source (equations), `pld/jed/` — assembled fuse maps
- `software/<project>/` — independent software projects targeting the board;
  each has its own `src/`, `include/`, `build/`
- `docs/` — design notes, decisions, datasheets
- `tools/` — build/assemble/program scripts
- `tests/` — emulator test programs and expected output

## Conventions

_TBD — fill in as tooling is chosen: KiCAD version, GAL assembler
(e.g. WinCUPL/GALasm), target emulator, assembler for the software projects,
default git branch, commit attribution._

## Git attribution

- Only commit/push when the owner asks.
