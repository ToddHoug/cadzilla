# ddcz — the CADzilla GSX-80 screen driver

`ddcz` is a GSX-80 GIOS, a device driver for DRI's Graphics System eXtension
to CP/M (BDOS function 115). It makes the CADzilla frame buffer a GSX
workstation, so unmodified GSX programs draw on the board. Tested with:
- John Elliott's GSXTEST;
- DRI's DEMOGRAF;
- DRI's DR Graph;
- z88dk C programs that use `<cpm.h>`'s `gios_*`, for example
  `software/cgsxdemo`.

It is an RMAC + LINK-80 project (`cadzilla-build-rmac`). A GSX driver has
to be a `.PRL`, and only DRI LINK writes those. The driver is linked
against the czgfx library release pinned in `czgfx.version`, which the
project's machine mounts read-only as `B:`.

## The drivers

One source builds three drivers, one for each display mode the board drives:

| Driver | Mode | czgfx descriptor | Workstation (`ASSIGN.SYS`) |
|---|---|---|---|
| `DDCZ1K.PRL` | 1024x768 | `CZM1K` | 01 |
| `DDCZ800.PRL` | 800x600 | `CZM800` | 02 |
| `DDCZ640.PRL` | 640x480 | `CZM640` | 03 |

The machine's cad0 `mode` strap must match the driver that opens. The
board doesn't refuse a mismatch; the picture just lands in the wrong
place. GSX programs normally open workstation 1, so list the driver
matching the strap first in `ASSIGN.SYS`. GDOS reserves room for the
first driver listed, but all three are the same size (11.5 KB, 2D1FH).

## Building

```
monitor: CONFIG LOAD <repo>/software/ddcz/work/cadzilla.toml, boot
monitor: SET hb0 HOSTDIR=<repo>/software/ddcz/src
A0>R *.*
A0>SUBMIT DDCZ          (RMAC each module, then LINK the three drivers)
```

`DDCZ.SUB` assembles the seven modules and three mode modules, then links
each driver:

```
LINK DDCZ1K=DDCZ,DM1K,DDATTR,DDPRIM,DDFILL,DDCOL,DDESC,DDMATH,B:CZGFX[S,OP]
```

- `DDCZ` must come first, because its first byte is the driver's entry.
- `[S]` searches the czgfx library.
- `[OP]` writes a `.PRL`.

`W DDCZ*.PRL` (binary) brings the drivers back to `build/`.

## Running GSX programs

A program needs the GSX runtime on its disk. The runtime is DRI's and its
licence is unsettled (`tools/altairsim/upstream/README.md`), so it lives
only in the local cache and on this project's `work/` disk. To set it up:
1. run `tools/altairsim/scripts/fetch_upstream.sh` once;
2. `R` the files you need from `upstream/GSX/` (and `upstream/DRGRAPH/`
   for DR Graph);
3. `R` this project's `ASSIGN.SYS` and the drivers.

| File | Is |
|---|---|
| `GSX.SYS` | the GDOS, GSX-80 1.0 |
| `GENGRAF.COM` | attaches the GSX loader to a program: `GENGRAF NAME` |
| `ASSIGN.SYS` | workstation numbers to drivers (`src/ASSIGN.SYS`) |
| `DDCZ*.PRL` | the drivers |
| `GSXTEST.COM`, `DEMOGRAF.COM` | test programs, already GENGRAF'd |
| `GRAPH.COM` + `GRAPH*.OVL`, `GRAPHY.MNU`, `GRAPHZ.TBL` | DR Graph; its sample charts are `SAMPLE1`, `SAMPLE2` |

`R *.*` skips files with no type, so `R SAMPLE1` and the others one at a
time.

**Memory.** GDOS loads the driver below itself, out of the program's TPA.
On the old 56K CP/M that cost too much: DR Graph needs the driver to be
6.2 KB or less there, and DEMOGRAF about 8 KB. So the pristine system disk
became a 62K CP/M on 2026-10-08 (`tools/altairsim/README.md`, "Disk
images"). With 62K, both run with this 11.5 KB driver. A `work/` disk
synced before then is still 56K, so re-sync it.

## What the driver does

Every function GSX requires of a CRT is implemented, apart from the input
functions.

| Opcode | Function | Notes |
|---|---|---|
| 1 | Open workstation | czgfx `CZINIT`, GSX's default palette (0 black … 7+ white), the overlay cleared and shown; returns intout(1)-(45), ptsout(1)-(6) |
| 2, 3 | Close, clear workstation | the screen to color 0, and the graphic cursor removed |
| 4 | Update workstation | waits for the ACRTC to finish |
| 5 | Escape | 1-15 go to the CP/M console as ANSI/VT100 (24x80, cursor tracked by the driver); 2 and 3 do nothing (the graphics screen is separate); 16: no tablet; 18 and 19: an XOR crosshair on the overlay plane |
| 6 | Polyline | 5 linetypes from GSX's masks; width 1 only; every vertex drawn once |
| 7 | Polymarker | dot, plus, asterisk, circle, cross; heights 5-49 |
| 8 | Text | font 1 = czgfx CZF8 (5x7), font 2 = CZF11 (7x10, descenders); scale 1-16; positioned by the baseline; up vector to the nearest 45 degrees; opaque cells in replace mode |
| 9 | Filled area | a software scan-line fill (even-odd, up to 64 vertices); hollow, solid, halftone 1-6, hatch 1-6, the patterns lined up on a 16x16 screen grid; the perimeter drawn except in XOR mode |
| 10 | Cell array | each cell a filled rectangle, in the array's own writing mode |
| 11 | GDP | bar, arc (the ACRTC's), pie slice (a polygon, 10 degree steps), circle; ruling characters: nothing |
| 12, 13, 15-25 | attributes | each returns the value selected |
| 14, 26 | color representation | all 256 indexes are Bt453 palette entries; "as set" and "as realized" both returned |
| 27 | Inquire cell array | read back from the frame buffer (the pixel at each cell's centre) |
| 28-31 | input | no input devices: nothing returned |
| 32 | Writing mode | replace, transparent, XOR, erase (ACRTC OPM and color modes) |
| 33 | Input mode | accepted |

**Writing modes.** All four follow GSX's definitions:
- **Replace** draws a pattern's 0 bits in color 0.
- **Transparent** leaves them alone.
- **XOR** XORs the palette index.
- **Erase** draws color 0 where the pattern is 1.

**Open workstation** reports:
- the mode's size;
- square pixels;
- 16 character heights and 2 fonts;
- 5 linetypes and 1 line width;
- 5 markers in 8 sizes;
- 6 patterns and 6 hatches;
- 256 colors shown at once, from more than 32767;
- 4 GDPs;
- color, text rotation, fill and cell-array read-back all available;
- no input devices, so an output-only workstation.

## Source

| Module | Is |
|---|---|
| `DDCZ.ASM` | entry (on its own 192-byte stack), dispatch, opcodes 1-4 and 32, the shared state and helpers |
| `DDATTR.ASM` | the attribute setters; `USEPAT`, which keeps the ACRTC pattern RAM (shared by lines, fills and text) holding what each primitive needs |
| `DDPRIM.ASM` | polyline, polymarker, text, cell array, GDPs, inquire cell array |
| `DDFILL.ASM` | filled area: the edge table (16.16 fixed point), the spans, filled circles, outlines |
| `DDCOL.ASM` | the color table: one byte a channel, what was asked for |
| `DDESC.ASM` | escapes: the console (BIOS CONOUT) and the overlay crosshair |
| `DDMATH.ASM` | multiply, 32/16 divide, signed compare, a degree sine |
| `DM1K/DM800/DM640.ASM` | the mode modules: `DMDESC`, the czgfx mode descriptor |

GDOS calls the driver's first byte with DE = the parameter block (the
addresses of contrl, intin, ptsin, intout and ptsout). GDOS has already
scaled coordinates to device units, with the origin at the bottom left,
which is czgfx's own orientation. The driver always sets contrl(3) and
contrl(5) before it returns.

## Testing

GSXTEST (`upstream/GSX/GSXTEST.TXT` describes each screen) is the main
check. `GSXTEST 2` and `GSXTEST 3` open the 800x600 and 640x480 drivers.
`SET cad0 mode=...` restraps the board to match, and `SET cad0
mode=1024x768` puts it back.

The screen is checked from a `snapshot`, rendered with
`tools/altairsim/scripts/cadzilla_png.py --size WxH`.

Driving it:
- **Wait for a menu to finish printing before typing.** GSXTEST prints
  with BDOS 9 and polls with BDOS 6, and drops a key typed in between.
- **Send control keys through the monitor**, for example `TYPE "\^["` for
  ESC (which exits) or `TYPE "\r"`.

## Known limits

- **Line widths:** one only.
- **Text:** rotation is in 45-degree steps.
- **Pie slices:** filled as 10-degree polygons.
- **Polygons:** at most 64 vertices are filled.
- **Input:** none yet, so no locator, valuator, choice or string. DR Draw
  needs a locator.
- **Alpha text** goes to the console. The overlay plane could carry a text
  screen instead (a later phase).
- **z88dk on the 8080:** `gios_1pm`, `gios_1px` and `gios_2px` (and the
  `gios_draw`, `gios_t_size` … macros built on them) return to the wrong
  address on an 8080. They keep their return address in AF, and the
  8080's flags byte can't hold every value. Fill `gios_ptsin` and
  `gios_intin` and call `gios()` instead, as `software/cgsxdemo` does.
