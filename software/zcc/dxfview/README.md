# DXFVIEW — an AutoCAD Release 10 DXF viewer

DXFVIEW reads an AutoCAD DXF file under CP/M and draws it on the CADzilla
board at 1024x768 in AutoCAD's 256 colors. You can then zoom and pan with
the keyboard. It is written in C for the 8080 with z88dk's zcc and draws with
cz88gfx. As in AutoCAD's own display-list drivers, it turns the drawing into
a list of 2D vectors once (a regen), and keeps the list in the board's spare
video memory. Zooming and panning redraw from that list in seconds.

```
A0>DXFVIEW SHUTTLE          (.DXF is the default extension)
A0>DXFVIEW SHUTTLE P        (start in the plan view)
```

| Key | |
|---|---|
| `+` `-` | zoom in, out (×2, about the screen center) |
| `W` `A` `S` `D` (or `K` `H` `J` `L`) | pan a quarter screen up, left, down, right |
| `F` | fit the whole drawing to the screen again |
| `V` | switch between the drawing's saved view and the plan view |
| `R` | redraw, from the display list |
| `G` | regen: rebuild the display list from the file |
| `ESC` `^C` `Q` | quit |

A key pressed during a redraw or regen stops it, and DXFVIEW acts on that
key at once. A regen prints a dot every 256 entities.

## The drawings

`dxf/` holds the drawings, ready to copy onto a CP/M disk:

| File | |
|---|---|
| `SHUTTLE.DXF` | The Space Shuttle stack on the launch pad: a 3D wireframe model of 765 3DFACEs in nested blocks. It opens in its saved perspective view. Its crawler and gantry are on frozen layers, so they are hidden, as in AutoCAD |
| `COLUMBIA.DXF` | The orbiter Columbia as a 2D line drawing, made of LINEs, ARCs, CIRCLEs and POINTs |
| `TEST.DXF` | A small drawing that covers every case DXFVIEW handles (see below) |

SHUTTLE and COLUMBIA were converted from two vintage AutoCAD drawings
(`shuttle.dwg`, DWG Release 10, and `columbia.dwg`, Release 13c3) by
`tools/dwg2dxf.sh`. The script uses the Open Design Alliance's free (not
open source) ODA File Converter, which is not part of this repo. Its header
says where to get it:

```
software/zcc/dxfview/tools/dwg2dxf.sh ~/Downloads/shuttle.dwg ...
```

It writes `dxf/<NAME>.DXF` as Release 10 DXF (`$ACADVER` `AC1006`) with
CR/LF line endings, and refuses any other version.

## What it draws

- **Entities:** LINE, 3DLINE, POINT, CIRCLE, ARC, TRACE and SOLID
  (outlined), 3DFACE (with its invisible edges), TEXT and ATTRIB, POLYLINE
  with bulges (arcs) and 2D elevation.
- **Blocks:** INSERT with scale, rotation and mirroring, MINSERT arrays, and
  DIMENSION (its `*D` block). Blocks nest up to 8 deep.
- **Layers and colors, as AutoCAD has them:**
  - Off and frozen layers are hidden. An INSERT on a frozen layer hides its
    whole block.
  - Inside a block, an entity on layer 0 takes the INSERT's layer.
  - BYLAYER and BYBLOCK colors are resolved.
- **The view:** the `*ACTIVE` VPORT's view, as AutoCAD's DVIEW sets it up:
  view direction, target, twist, and perspective (VPORT group 71 bit 0). A
  3D drawing therefore opens as it was last seen. `V` gives the plan view,
  looking down Z. Either way the drawing is first fitted to the screen.
- **Text:** in cz88gfx's 8x8 font, scaled to the text height and turned to
  the nearest 45°. Text too small to read is drawn as a line along its
  baseline.

Not drawn: linetypes (every line is solid), widths and fills, 3D and
polyface meshes, shapes, and extrusion directions (210/220/230; entities
are taken as lying in the WCS XY plane at their Z).

## How it works

### Regen: the file to a display list

A regen reads the whole DXF file and does all of the floating point. It
runs every entity through its block INSERTs and the view, including 3D and
perspective, and produces 2D integer vectors:

- **The virtual screen.** Coordinates are 16-bit integers, −8000..8000,
  at 2^k units per pixel of the zoom the regen was made for. When the whole
  drawing fits, k = 4 (16 units a pixel). A regen made while zoomed well in
  uses k = 2 and holds the 2000 pixels around the view.
- **Lines** are clipped to the virtual screen and stored as vertices. A
  polyline costs one vertex per corner.
- **Circles and arcs** of a 2D view are stored as circles and arcs, for
  the ACRTC to draw. In a 3D view they are stored as short lines.
- **Text** is stored with its height, direction and the end of its
  baseline.

The list lives in the CADzilla's own frame memory, past the 1024x768
picture, from word address 60000H. That leaves 1.25 MB that is never
displayed: SHUTTLE's list takes 32 KB, COLUMBIA's 8 KB. The regen writes it
256 words at a time with the ACRTC's DWT command, run by the CPU (no DMA
controller is needed).

Each 256-word chunk starts with its bounding box. It also starts with its
own color and a move, so any chunk can be drawn on its own.

### Redraw, zoom and pan: the list to the screen

A redraw reads each chunk back with DRD. A chunk whose bounding box is all
off the screen is skipped after reading just its 4-word header. The vertices
then go through `DLRUN.Z88`, an 8080 loop:

- **Scaling** takes no multiply: screen x is `((x − cx) >> s) + 512`. A
  zoom by 2 is one shift more or less, and a pan is a different `cx`. The
  shift is done as an unrolled 24-bit left shift, patched for each redraw.
- **Clipping:** a line wholly off one side of the screen is dropped. A line
  that reaches the screen goes to the ACRTC, whose area clip cuts it, as
  long as both ends are within 1024 pixels of the screen. Only a line beyond
  that is clipped in C.
- **Drawing:** AMOVE and ALINE go straight into the ACRTC's FIFO.

A regen is needed only for these:
- zooming in further than k steps past the regen's zoom;
- panning beyond what a zoomed-in list holds;
- switching views (`V`);
- `G`.

### Files

| File | |
|---|---|
| `src/dxfview.c` | the main program: arguments, the view, regen or redraw, the keys |
| `src/dxfread.c`, `src/RDLINE.Z88` | the reader: group code/value pairs, byte offsets and seeks; the inner line loop is 8080 assembly |
| `src/dxfscan.c` | the first pass: the LAYER and VPORT tables, and where every BLOCK is |
| `src/dxfent.c` | the entity walker: entity fields, layers and colors, POLYLINEs, INSERTs |
| `src/render.c` | the regen's floating point: projection and clipping into the display list |
| `src/dlist.c`, `src/DLRUN.Z88` | the display list: writing it, reading it back, the 8080 redraw loop |
| `src/aci.c` | AutoCAD's 256 colors, computed and loaded into the Bt453, so a DXF color number is a palette index |

### Memory

This CP/M's BDOS is at CE06H, and the CCP at C600H, so a `.COM` must end
below C600H to load at all. DXFVIEW is about 46 KB. Above it, the heap holds
the layer table (96 layers), the block table (160 blocks) and a pool of
about 1.3 KB for their names. Below the BDOS is 2.5 KB of stack: SHUTTLE uses
under 2 KB of it. Nothing else of the drawing is in RAM: the file is read
from the disk, and the display list is in video memory. The DXF reader's
512-byte buffer is used again for the display-list chunks during a redraw.

## Speed

Measured on altairsim with the CPU at 2 MHz and the ACRTC at its datasheet
drawing speed (`draw_rate = real`):

| Drawing | First view (measure + regen) | Redraw, zoom, pan | A regen zoomed in |
|---|---|---|---|
| `TEST.DXF` (5 KB) | 51 s | 0.9 s | 23 s |
| `COLUMBIA.DXF` (104 KB, 747 entities) | 4½ minutes | 2.0 s | 2¼ minutes |
| `SHUTTLE.DXF` (241 KB, 7430 vertices) | 42 minutes | 6.4 s | 20 minutes |

Before the display list, every zoom and pan was a regen: 20 s, 2 minutes
and 20 minutes respectively.

About 0.5 s of each redraw is the ACRTC clearing the screen. In
single-access mode it draws only during retrace. The rest is the 8080 at
about 1600 T-states per vertex:
- about 15% reading the list back through DRD;
- about 20% the shifts;
- the remainder the outcodes and feeding the FIFO.

The ACRTC itself keeps up.

A regen is slow because it is software floating point (z88dk's math32):
each 3D point costs 18 float operations and a divide, and each number has
to be read from text first. altairsim's default machine runs the CPU flat
out, so testing there doesn't wait on it.

## Building and running

Build and run it as any zcc project (skill `cadzilla-build-zcc`):

```
tools/z88dk/zccbuild.sh software/zcc/dxfview       # -> build/DXFVIEW.COM
```

Then, in the project's own `work/` machine:

```
SET hb0 HOSTDIR=<repo>/software/zcc/dxfview/build      (monitor)
A0>R DXFVIEW.COM
SET hb0 HOSTDIR=<repo>/software/zcc/dxfview/dxf        (monitor)
A0>R SHUTTLE.DXF
A0>DXFVIEW SHUTTLE
```

To check a view without a screen, take an altairsim `snapshot` and render
it with `tools/altairsim/scripts/cadzilla_png.py`. The display list is in
the same snapshot, in frame memory from byte C0000H.

## sccz80 traps met here

Two code-generation bugs in sccz80 (the 8080 target) shaped this code:

- `>>` on a negative `int` gave a logical shift here, not an arithmetic
  one. Record coordinates therefore go through `DLRUN.Z88`'s shift
  (`dl_tx`, `dl_ty`).
- `(255 + (unsigned int)c) >> 1`, assigned to an `unsigned char`, shifted
  only the low byte of the 16-bit sum, losing bit 8. `aci.c` keeps that
  arithmetic in 8 bits.
