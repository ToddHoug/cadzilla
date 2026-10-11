# CZBASIC

CZBASIC is a BASIC interpreter for CP/M 2.2 that runs Microsoft BASIC-80
(MBASIC) 5.21 programs. It adds `CZ...` statements for the CADzilla board:
the HD63484 ACRTC's drawing commands, the Bt453 palette, and text in
czgfx's 8x8 font. It is written in 8080 assembly for Microsoft M80/L80. All of
its board access goes through the shared czgfx library (`software/m80/czgfx`),
linked from the `B:` library disk. BGFX and BGTEXT take the ports, opcodes
and mode values from `B:CZGFX.INC`, call czgfx's routines (including
`CZRDOT` for CZPOINT, `CZPSCN`/`CZPDEF` for the pattern scan window, and
`CZTFNT`/`CZTSTR` for CZTEXT),
and touch no port themselves.

```
A0>CZBASIC                     command level
A0>CZBASIC CZDEMO              load and RUN CZDEMO.BAS
A0>CZBASIC STARTRK /X          no graphics: their memory goes to programs
```

## Contents

- [Compatibility](#compatibility)
- [Switches](#switches)
- [The CADzilla statements](#the-cadzilla-statements)
- [Memory and size](#memory-and-size)
- [Speed](#speed)
- [Building](#building)
- [Testing](#testing)
- [Demo disk](#demo-disk)
- [Source layout](#source-layout)

## Compatibility

CZBASIC implements the MBASIC 5.21 language and is checked against the real
`MBASIC.COM`, which is used only as a black box (see [Testing](#testing)).
It implements:

- **Numbers:** integer, single and double precision in Microsoft Binary
  Format. PRINT formats numbers the way MBASIC does, digit for digit.
- **Strings, arrays and user functions:** strings with garbage collection;
  arrays with DIM, ERASE and OPTION BASE; DEF FN.
- **Program control:** FOR/NEXT, WHILE/WEND, GOSUB, ON...GOTO/GOSUB, and
  IF...THEN...ELSE.
- **Errors:** ON ERROR, RESUME, ERR and ERL, with MBASIC's error numbers and
  messages.
- **Input and output:** PRINT USING, INPUT, LINE INPUT and READ/DATA.
- **Files:** sequential files, and random files with FIELD, GET, PUT,
  LSET/RSET and MKI$/CVI.
- **Programs:** LOAD, SAVE (binary, `,A` and `,P`), MERGE, RUN "file", and
  CHAIN [MERGE] with COMMON, ALL and DELETE.
- **Editing:** EDIT, AUTO, RENUM and DELETE.
- **Machine level:** PEEK, POKE, INP, OUT, WAIT, USR and CALL.

Programs are stored in MBASIC's tokenized format. The binary files SAVEd by
either interpreter LOAD in the other: STARTRK round-trips identically both
ways.

The known differences are listed in
[tests/DEVIATIONS.md](tests/DEVIATIONS.md):

- **Double-precision constants:** CZBASIC converts them exactly, where
  MBASIC is off in the last digit.
- **Open files and CHAIN:** files survive a CHAIN to an ASCII program.
  MBASIC loses them.
- **Last line without CR/LF:** a program whose last line has no CR/LF loads
  correctly. MBASIC appends the next typed line to it.
- **RND:** the sequence differs from MBASIC's. The range and uniformity are
  the same.

`CZ` names are keywords, so a variable name can't start with `CZ`. This is
the same rule that stops MBASIC variables starting with a keyword.

## Switches

| Switch | Meaning |
|---|---|
| `/F:n` | number of files (default 3) |
| `/S:n` | largest random record (default 128) |
| `/M:addr` | highest memory address for BASIC (`&Hxxxx` or decimal) |
| `/X` | no graphics: the graphics code's memory (4,031 bytes) becomes program space. A `CZ` statement then gives *Illegal function call* |

Use `/X` for large programs that don't draw. STARTRK, for example, doesn't
fit alongside the graphics code.

## The CADzilla statements

Coordinates are pixels, with 0,0 at the **bottom left** and Y going up.
Colors are palette indexes: the default palette is hue × 32 + level. The
hues are 0 orange, 32 blue, 64 green, 96 cyan, 128 red, 160 magenta, 192
yellow and 224 white, and the levels run from 0 (black) to 31. An optional
color `c` at the end of a drawing statement is used for that statement only;
CZCOLOR sets the color that stays.

| Statement | Does |
|---|---|
| `CZINIT [640\|800\|1024]` | set up the board and clear the screen (default 1024, as `machine.toml` straps it) |
| `CZCLS [c]` | clear to color c (0) |
| `CZCOLOR fg[,bg]` | drawing color; background CL0 |
| `CZPAL i,r,g,b` / `CZPAL` | set a palette entry (0-255 each) / the default palette |
| `CZMODE op[,cm[,am]]` | ACRTC operation, color and area modes (op 3 = EOR) |
| `CZAREA x1,y1,x2,y2` / `CZAREA` | clipping area / the whole screen |
| `CZMOVE x,y`, `CZRMOVE dx,dy` | move the pen |
| `CZDOT x,y[,c]` | one pixel |
| `CZLINE x1,y1,x2,y2[,c]`, `CZLINE TO x,y[,c]`, `CZRLINE dx,dy[,c]` | lines, both ends drawn |
| `CZRECT` / `CZFRECT x1,y1,x2,y2[,c]` | rectangle outline / filled |
| `CZCIRCLE x,y,r[,c]`, `CZELLIPSE x,y,rx,ry[,c]` | circle, ellipse |
| `CZARC xc,yc,xs,ys,xe,ye[,c[,dir]]` | circular arc, counter-clockwise (dir ≠ 0: clockwise) |
| `CZEARC xc,yc,rx,ry,xs,ys,xe,ye[,c[,dir]]` | elliptical arc |
| `CZPOLY a%(i),n[,c]`, `CZPLINE a%(i),n[,c]` | polygon / polyline through n x,y pairs in an integer array |
| `CZPAINT x,y,edge[,c]` | fill the area bounded by color `edge` |
| `CZFLOOD x,y,region[,c]` | recolor the region of color `region` |
| `CZCOPY x1,y1,x2,y2,xd,yd[,t]` | copy a block (t: one of the ACRTC's 8 transforms) |
| `CZPAT start,w0[,w1...]` | load pattern RAM words |
| `CZLSTYLE pat[,zoom]` | line style (16 bits) |
| `CZPSCAN x0,y0,x1,y1[,zx,zy]` | pattern scan window and zoom |
| `CZPTN x,y,w,h[,dir]` | draw the pattern |
| `CZTEXT x,y,s$[,c[,scale[,dir]]]` | text: 8x8 font, scale 1-16, dir 0-7 in 45° steps |
| `CZWAIT` | wait for the ACRTC to finish |

| Function | Returns |
|---|---|
| `CZPOINT(x,y)` | the pixel's color, or -1 off the screen |
| `CZXMAX`, `CZYMAX` | the largest X and Y |
| `CZXPOS`, `CZYPOS` | the pen position |

[src/CZDEMO.BAS](src/CZDEMO.BAS) tours the statements on four screens.

## Memory and size

On the project's 56K CP/M (TPA 0100H-B5FFH):

| | Bytes free |
|---|---|
| MBASIC 5.21 | 21,048 |
| CZBASIC | 14,703 |
| CZBASIC `/X` | about 18,700 |

`CZBASIC.COM` is 30,336 bytes (237 records). The layout in memory, low to high:

```
0100H   BINIT   start-up code; afterwards the run-time buffers (BUF,
                KBUF, the value stack and others: 1,135 bytes)
        the interpreter core
GFXBEG  BGFX, BGTEXT (1,492 bytes) and the czgfx modules, its CZF8 font
        included (2,539): 4,031 bytes, which /X frees
        the file blocks (/F:, /S:)
TXTTAB  program text, variables, arrays, free, strings
        the stack (512 bytes, CLEAR ,,n)
MEMTOP  the BDOS page, or /M:
```

To save space:

- The one-time start-up code is overlaid by the buffers.
- EDIT works in the input buffer.
- LOAD/SAVE and FILES use CP/M's own buffer at 0080H.
- The font (czgfx's CZF8) is bit-packed: 5 bytes per character.
- The error messages share a small fragment dictionary.

The core is still about 2K bigger than MBASIC.

## Speed

`tests/BENCH.BAS` times six loops, in millions of 8080 t-states:

| Section | MBASIC | CZBASIC |
|---|---|---|
| integer FOR, `J%=I%*2+3` ×2000 | 19.0 | 24.7 |
| single, `X=X+I*1.5/3` ×1000 | 24.8 | 35.7 |
| strings, `LEFT$(...)+"X"` ×300 | 6.6 | 8.0 |
| GOSUB/RETURN ×1000 | 11.1 | 14.4 |
| arrays, 1111 reads/writes | 17.5 | 24.5 |
| SIN+SQR+LOG ×100 | 20.2 | 22.8 |
| **total** | **99.2** | **130.1** |

`tests/GBENCH.BAS` times the CZ statements the same way. It shows the
graphics code spends little time in czgfx: most of a statement is its
arguments. GETINT, which reads every CZ argument, array subscript and
integer argument, therefore takes a constant or a simple variable
directly, without the expression evaluator. That, and a byte-at-a-time
FRCINT, cut these times by 15-22%:

| GBENCH section | before | now |
|---|---|---|
| `CZLINE 10,10,500,400,7` ×300 | 4.60 | 3.59 |
| `CZDOT I,Y,C` ×300 | 6.40 | 5.15 |
| `P=CZPOINT(I,Y)` ×300 | 7.30 | 6.20 |
| `CZTEXT 10,10,"HELLO",255` ×50 | 2.41 | 2.37 |

Single-precision multiply, divide and add run in registers. Double precision
uses a slower generic engine that works for any byte count. The remaining
gap is mostly the per-statement and per-operand overhead of the
interpreter. The value stack, PTRGET and the generic FOR/NEXT are the next
places to look.

## Building

M80/L80 run on the project's altairsim CP/M work disk, with czgfx's library
disk as `B:` (see the `cadzilla-build-m80` skill). Point `hb0` at `src/` and
upload the sources with `R`. Then:

```
A0>SUBMIT CZBBLD         assemble every module, then link (CZL.SUB)
A0>SUBMIT CZB BVAR       R and assemble one module, then link
A0>SUBMIT CZL            link only
```

The whole link line doesn't fit CP/M's 127-character command limit, so
CZL.SUB puts the modules into three libraries first (`CZB1`-`CZB3`). The link
order is BINIT first and graphics last:

```
L80 BINIT,CZBASIC,CZB1,CZB2,CZB3,B:CZGFX/S,CZBASIC/N/Y/E
```

It also writes `CZBASIC.SYM` for the debugger's `SYMBOLS LOAD`. Watch L80's
own "Bytes Free" (613 at present): the memory L80 has left for the program
it is loading and its symbol table, so it shrinks as CZBASIC grows.

BGFX and BGTEXT `INCLUDE B:CZGFX.INC`, so rebuild them (and relink) after
czgfx changes. czgfx reserves global names starting with `CZ`, so
CZBASIC's own entry points into the graphics are `XSTMT`, `XFUNC`,
`XTEXT`, `XGO` and `XGOF`. BGFX's handlers are `Z...`, because czgfx's
macros already use the `G...` names.

CZTEXT is drawn by czgfx's text routines (CZTXT.MAC) in czgfx's 8x8 font,
CZF8. BGTEXT only parses the statement: it stores the pen, scale and
direction straight into czgfx's text state (`CZTST`) and calls `CZTFNT` and
`CZTSTR`, so CZBASIC doesn't link czgfx's other text calls (CZTXL.MAC) or
its 9x11 font. The font's glyphs are in `software/m80/czgfx/tools/mkfont.py`,
which `tools/mkmanual.py` also reads for the manual's character chart.

## Testing

`tests/` holds the test programs, and `tests/expected/` holds MBASIC's
output for each one. Every expected file is MBASIC's own output, except the
GFX tests, which MBASIC can't run:

| Tests | Cover |
|---|---|
| T01-T13 | numbers and PRINT formatting, PRINT zones, strings, control flow, DEF FN, errors, math functions, PRINT USING, USR/CALL, sequential and random files |
| CH1-CH4, CM1-CM2, CF1-CF2B | CHAIN, CHAIN MERGE, COMMON, ALL and DELETE, and files across a CHAIN |
| GFX01 | every CZ statement |
| GFX02 | pixels read back with CZPOINT |
| GFX03 | CZPOINT in all three modes |

To run them, copy the `.BAS` files to the work disk (`hb0` at `tests/`, then
`R`), then:

```
A0>SUBMIT RUNALL
```

Paste the `run` output (JSON-escaped, as the tool returns it) into the
checker:

```
python3 tests/check.py --all <<'EOF'
...
EOF
```

It prints `Tnn OK` or a diff for each test. `check.py Tnn` checks a single
run.

## Demo disk

`demodisk/CZBDEMO.DSK` is a bootable 8MB CP/M 2.2 disk carrying
`CZBASIC.COM`, the CADzilla demos (`CZDEMO` and the short `STARBRST`,
`XORBAND`, `SHAPES` and `PALANIM` from `demos/`), the MBASIC sample programs
(`STARTRK`, `STARINS`, `LUNAR`, `TICTAK`), `PIP`, `STAT`, and a
`CZBASIC.TXT` readme. No sources are on it. Boot it on its own:

```
cd software/m80/czbasic/demodisk && altairsim cadzilla.toml
A0>CZBASIC CZDEMO
```

Running it writes to the image, as any CP/M disk would. To rebuild it, copy
the empty 8MB template (`tools/altairsim/pristine/EMPTY.DSK`), SYSGEN it,
and PIP the files on through altairsim.

## Source layout

| File | Contents |
|---|---|
| `BINIT` | start-up, command-line switches, the buffers laid over it |
| `CZBASIC` | console I/O, the command loop, shared helpers (MOVB, SUBDE, LHLI, ...) |
| `BTOKEN` `BTAB` | keyword tables, crunch/list, the dispatch tables |
| `BLINE` `BEDIT` | program lines, LIST, DELETE, CLEAR; EDIT, AUTO, RENUM |
| `BEXEC` `BEVAL` | statement loop and control flow; expressions |
| `BVAR` `BSTR` | variables, arrays, DEF FN; strings and their functions |
| `BFLT` `BFIO` `BFMATH` | floating point, number conversion, SQR/SIN/LOG/... |
| `BPRINT` `BUSING` `BINPUT` | PRINT/WRITE, PRINT USING, INPUT/READ |
| `BFILE` `BRAND` `BDISK` `BCHAIN` | files, random files, LOAD/SAVE, CHAIN/COMMON |
| `BERR` `BMISC` | errors and messages; PEEK/POKE/USR/CALL |
| `BGFX` `BGTEXT` | the CZ statements, CZTEXT (drawn by czgfx, in its CZF8 font) |

`ref/` is gitignored. It holds the MBASIC.COM used for the comparisons and
the sample programs from the same disk (STARTRK, LUNAR, TICTAK, STARINS).
MBASIC.COM is never committed; the four samples, which have been widely
published, are on the demo disk.
