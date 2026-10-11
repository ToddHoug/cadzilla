# CADzilla

![CADzilla](docs/images/cadzilla.png)

CADzilla is an S-100 bus board built around the Hitachi HD63484 Advanced CRT
Controller (ACRTC) paired with a Brooktree Bt453 video DAC. The board
carries about 2.2 MBytes of video memory in total:
- a 2 MByte frame buffer for 8-bit-per-pixel display modes at resolutions
  up to 1024x768;
- a 256 KByte, 1-bit-per-pixel overlay layer, mapped pixel for pixel onto
  the frame buffer and shown on top of it in the Bt453's overlay color. It
  can be drawn, shown and hidden without disturbing the picture underneath,
  which suits text, cursors, grids and annotations.

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
- `software/` — software projects targeting the board, grouped by toolchain
  - `asm/` — Digital Research ASM + LOAD: hello, firstdraw, drawdemo
  - `m80/` — Microsoft M80 + L80: the czgfx graphics library, gfxdemo,
    czbasic, testpat
  - `rmac/` — Digital Research RMAC + LINK: rhello, ddcz (GSX-80 driver)
  - `z88dk/` — z88dk z80asm (host cross-assembler): the cz88gfx graphics
    library, zhello, z88demo
  - `zcc/` — z88dk zcc (C): chello, cgfxdemo, cgsxdemo
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
| 3   | OLEN  | Overlay enable: 0 = overlay plane blanked (shift register loads zeros), 1 = overlay pixels displayed over the frame buffer |
| 4   | OLSEL | Overlay select: 0 = lower half, 1 = upper half of the overlay memory — selects which 64K-word half of the 128K-word overlay SRAM a drawing-mode CHR screen addresses |
| 5–7 | —     | Reserved |

The overlay (U19, 1 bit per pixel, mapped 1:1 onto frame-buffer pixels) is
drawn by targeting an ACRTC screen with the CHR bit set in its Memory Width
register. A CHR screen only has a 64K-word address space, so OLSEL selects
which 64K-word half of the 128K-word overlay SRAM that screen addresses.
OLSEL is cleared to 0 by reset. A CHR screen must never be displayed —
overlay display is driven by the frame buffer's own display cycles,
independent of OLSEL.

### Configuration DIP switch (SW1)

SW1 is an 8-position DIP switch that sets the board's I/O base address and
host interface options:

| Switch          | Function | On | Off |
|-----------------|----------|----|-----|
| SW1-1 – SW1-5   | I/O base address (address bits 7:3) | — | — |
| SW1-6           | HD63484 host bus width | 8-bit host interface: DACK\* follows RESET\*, so it is low during reset | 16-bit host interface: DACK\* is pulled high |
| SW1-7           | 16-bit address decode enable | Decodes the full 16-bit I/O address (A15–A8 must be 00h) | Decodes only the 8-bit I/O address |
| SW1-8           | Interrupt enable | HD63484 interrupt request connected to the S-100 bus | Interrupt request disconnected from the S-100 bus |

### Frame buffer and feature support

- About 2.2 MBytes of video SRAM in total — no refresh cycles required
- 2 MByte frame buffer (U11–U18): 8 bits per pixel only, Graphics Address
  Increment (GAI) = 8
- 256 KByte 1-bit-per-pixel overlay (U19, 128K x 16):
  - mapped 1:1 onto frame-buffer pixels, and read during the frame buffer's
    own display cycles;
  - shown over the picture in the Bt453's programmable overlay color, and
    turned on or off with MODE register bit OLEN;
  - drawn through an ACRTC screen with CHR set, which is never displayed.
    MODE register bit OLSEL selects which half of the overlay it addresses
- The ACRTC's own hardware cursor, superimposed access mode, light pen,
  zooming, video attributes, external sync, and DMA transfers are **not
  supported**. A cursor can be drawn in the overlay instead
- Interrupts are supported, enabled via SW1-8

See the [board manual](docs/cadzilla-manual.pdf) for full details.

See [CLAUDE.md](CLAUDE.md) for AI-assistance working notes.
