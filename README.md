# cadzilla

Board design project: KiCAD schematics/PCB, GAL16V8 PLD logic, and supporting
software projects that run on it (assembled and tested on an emulator).

## Layout

- `schematics/` — KiCAD project (schematic, PCB, libraries, fab outputs)
- `pld/` — GAL16V8 PLD source (`src/`) and assembled fuse maps (`jed/`)
- `software/` — one directory per software project targeting the board
  - `firstdraw/` — first software project
- `docs/` — design notes and reference datasheets
- `tools/` — build/assemble/program scripts
- `tests/` — emulator test programs and expected output

See [CLAUDE.md](CLAUDE.md) for AI-assistance working notes.
