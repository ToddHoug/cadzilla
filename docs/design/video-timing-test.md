# 1024x768 video timing test (64 MHz)

Bench procedure for the line-length problem found on 2026-11-04. At
HC=83 (manual: 84 memory cycles), the scope read a 45.977 kHz line, which is
87 cycles, and 1040 active pixels, which is 65 cycles. The tests below show
which register field (or U48) the extra cycles come from, before any mode
table is changed.

Y1 = 64 MHz, so 2CLK = 8 MHz and one memory cycle (M) = 250 ns = 16 px.
Line rate = 4 MHz / cycles.

## Setup

Use czdiag only (it links no graphics library). On the Altair:

```
A>CZDIAG RES=1024
```

1. `V` draws the picture: a white frame at the screen edge, bars, a gray
   ramp, and the overlay grid. Then go back to the menu.
2. `P` opens peek/poke. Every change below uses the same pattern: stop the
   display, write the register, then restart it.

   ```
   W 04 80B0        OMR: STR=0 (display stopped)
   W rr vvvv        the register under test
   W 04 C0B0        OMR: STR=1 (running)
   R rr             read it back (so an RS race shows up)
   ```

3. Restore the baseline before each test, the same way: `W 82 5308`,
   `W 84 093F`, `W 86 0326`, `W 88 1C06`.

## Probe points

| Signal | Where | Why |
|---|---|---|
| ~HSYNC | U1 pin 12 (U48 pin 4) | the line period and sync width, straight from the chip |
| ~DISP1 | U1 pin 63 (U48 pin 3) | the chip's own display window, independent of U48 |
| ~BLANK | U48 pin 13 / Bt453 pin 21 | what's actually shown (U48 releases it on display fetches) |
| ~VSYNC | U1 pin 13 | the frame |
| 2CLK | U48 pin 14 | to confirm 8.000 MHz first |

Probe the ACRTC pins (U1), not J1: U60 may invert the syncs.

## Horizontal tests

Expected values follow the manual (HC+1, HSW, HDS+1, HDW+1). Write down the
measured value next to each one.

| # | Poke | Manual says | What it tells us |
|---|---|---|---|
| H0 | baseline 5308 / 093F | line 84 M = 47.619 kHz (seen: 45.977 = 87). HSYNC low 8 M = 2.00 µs. HSYNC↑ to DISP1↓ 10 M = 2.50 µs. DISP1 low 64 M = 16.00 µs | Measure HSYNC low, HSYNC↑→DISP1↓, DISP1 low and BLANK high. These split the 87 cycles into sync, back porch, display and front porch |
| H1 | `W 82 5008` (HC=80) | 81 M = 49.383 kHz | If it reads 84 M (47.619), HC carries a fixed +3 |
| H2 | `W 82 5A08` (HC=90) | 91 M = 43.956 kHz | If it reads 94 M (42.553): a fixed +3. If 91 M: HC is right, and at HC=83 the chip stretched a front porch it found too short |
| H3 | `W 82 5304` (HSW=4) | line unchanged (84); HSYNC low 1.00 µs | If the line gets shorter, the total is built from the fields rather than from HC |
| H4 | `W 84 083F` (HDS=8) | DISP1 starts 1 M earlier; line unchanged | Same question for HDS |
| H5 | `W 84 093E` (HDW=62) | DISP1 low 63 M = 15.75 µs; line unchanged | Compare DISP1 with BLANK. If DISP1 is 64 M and BLANK 65 M at baseline, the extra 16 px are the single-access fetch made just before DISP1 (Fig 2.1(d)); the fix then goes in U48 or HDS, not HDW |

H1 and H2 together give the answer. A constant +3 means an offset, and
every table's HC goes down by 3. A correct reading at HC=90 means a
minimum-front-porch rule, so HDS/HSW need rebalancing instead. That
second case also needs the 640 and 800 tables checked (their front porches
are 1 M and 2 M by the manual, against 2 M here).

## Vertical tests

| # | Poke | Manual says | What it tells us |
|---|---|---|---|
| V0 | baseline 0326 / 1C06 | 806 lines. At 87-M lines the frame is 57.04 Hz (59.08 at 84). VSYNC low 6 lines | Measure the VSYNC period and its width in HSYNC periods (scope: VSYNC period ÷ HSYNC period). Also count DISP1's active lines (768 expected) and VSYNC↑ to the first active line (VDS+1 = 29) |
| V1 | `W 86 0323` (VC=803) | 803 lines | A fixed offset in VC shows as the same difference here |
| V2 | `W 88 1C03` (VSW=3) | VSYNC 3 lines, frame unchanged | Same check as H3, vertically |

## After the tests

- Restore the baseline, or just rerun CZDIAG.
- Record the readings in the `pixel-clock-64mhz` memory note, then fix the
  1024x768 tables. They live in czgfx `CZINIT.MAC` and cz88gfx
  `CZINIT.Z88` (each needs a new release), czdiag `TABLES.Z88`,
  firstdraw, drawdemo and ddcz `DM1K.ASM`.
- czdiag's CLOCK stage works its PCLK out from HC+1, so it's only right once
  the tables are.

## Results: 640x480 interleaved on a monitor

2026-11-04, board B with the 25.175 MHz oscillator. TESTPAT (czgfx 1.5) `M 6`
sets MODE 07H, OMR ACM=10, HSR 630CH and HDR 034DH. On the monitor:
- Screen 1 (border): correct, every edge pixel visible.
- Screen 7 (overlay bands): yellow covers red exactly. With the overlay
  hidden, the red staircase matches it. The overlay stays registered in
  interleaved access.
- Screen C (checkerboards): 1x1, 2x2, vertical and horizontal 1-on-1-off
  lines are all crisp, with no smear or shimmer.

No scope readings were taken in this run.
