# CADzilla

![CADzilla](docs/images/cadzilla.png)

CADzilla is an S-100 bus board built around the Hitachi HD63484 Advanced CRT
Controller (ACRTC) paired with a Brooktree Bt453 video DAC. The board
carries 2 MBytes of video frame buffer memory and supports 8-bit-per-pixel
display modes at resolutions up to 1024x768.

Board design project: KiCAD schematics/PCB, GAL16V8 PLD logic, and supporting
software projects that run on it (assembled and tested on an emulator).

For the full board reference, see the
[CADzilla User Reference Manual](docs/cadzilla-manual.pdf).

## Design philosophy

CADzilla exists for one reason: to enjoy the graphics board design process
the way I did it forty years ago. The circuit architecture, schematic
design, and PCB layout were all done by hand, with no AI assistance — the
way boards like this were designed back then.

Every component on the board, aside from the modern SRAM used for the
frame buffer, is a part that would have been available in 1984, when the
Hitachi HD63484 was released and the S-100 bus was still a going concern.
As far as I could find, no one had ever built an HD63484-based S-100
board — so I built one.

AI did play a role, but not in the hardware: it made it possible to build
a CP/M software development environment and toolchain for the board that I
could never have put together on my own.

## Layout

- `schematics/` — KiCAD project (schematic, PCB, libraries, fab outputs)
- `pld/` — GAL16V8 PLD source (`src/`) and assembled fuse maps (`jed/`)
- `software/` — one directory per software project targeting the board
  - `firstdraw/` — first software project
- `docs/` — design notes and reference datasheets
  - `docs/cadzilla-manual.pdf` — user reference manual
  - `docs/images/` — logo and other documentation images
- `tools/` — build/assemble/program scripts
- `tests/` — emulator test programs and expected output

## Board specification

### I/O address map

The board decodes a single 8-byte-aligned base I/O address, set by SW1
(see below). All board registers are addressed as offsets from that base
address:

| Offset             | Register                                      | Access     |
|---------------------|------------------------------------------------|------------|
| `Base + 0`          | HD63484 Address/Status Register (RS = 0)        | Read/Write |
| `Base + 1`          | MODE register (board configuration, write only) | Write only |
| `Base + 2`          | HD63484 Control/FIFO Register (RS = 1)          | Read/Write |
| `Base + 3`          | Reserved / not decoded                          | —          |
| `Base + 4`–`Base + 7` | Bt453 video DAC registers                     | Read/Write |

### MODE register (`Base + 1`, write only)

| Bit | Name  | Description |
|-----|-------|-------------|
| 0   | HSPOL | Horizontal sync polarity: 0 = positive sync pulse, 1 = negative sync pulse |
| 1   | VSPOL | Vertical sync polarity: 0 = positive sync pulse, 1 = negative sync pulse |
| 2   | AMODE | Address mode: 0 = single access mode, 1 = interleaved access mode |
| 3   | OLEN  | Overlay enable (TBD) — set to 0 for now |
| 4–7 | —     | Reserved |

### Configuration DIP switch (SW1)

SW1 is an 8-position DIP switch that sets the board's I/O base address and
host interface options:

| Switch          | Function | On | Off |
|-----------------|----------|----|-----|
| SW1-1 – SW1-5   | I/O base address (address bits 7:3) | — | — |
| SW1-6           | 16-bit host mode select | HD63484 set to 16-bit host interface mode at reset | HD63484 set to 8-bit host interface mode at reset |
| SW1-7           | 16-bit address decode enable | Decodes full 16-bit I/O address | Decodes only 8-bit I/O address |
| SW1-8           | Interrupt enable | HD63484 interrupt request connected to the S-100 bus | Interrupt request disconnected from the S-100 bus |

### Frame buffer and feature support

- 2 MBytes of SRAM frame buffer — no refresh cycles required
- 8 bits per pixel only, Graphics Address Increment (GAI) = 8
- Cursors, superimposed access mode, light pen, zooming, video attributes,
  external sync, and DMA transfers are **not supported**
- Interrupts are supported, enabled via SW1-8

See the [board manual](docs/cadzilla-manual.pdf) for full details.

See [CLAUDE.md](CLAUDE.md) for AI-assistance working notes.
