# testpat — CADzilla bring-up test patterns

`TESTPAT` is an interactive menu of test screens for bringing up and debugging
a new CADzilla board. Each screen is exact to the pixel. For each one, the
console says what a good picture looks like and which chips it exercises, so a
fault on the monitor can be traced to a part.

It is an M80/L80 program built on the czgfx library (pinned in
`czgfx.version`); see `software/czgfx/README.md` and the `cadzilla-build-m80`
skill.

```
A0>M80 TESTPAT,TESTPAT=TESTPAT
A0>SUBMIT B:CZLINK TESTPAT
A0>TESTPAT
```

## How the board turns memory into pixels

The patterns are built around these facts, which come from the Rev A
schematic netlist:

- Each display fetch reads all 8 frame banks at once (ACRTC GAI = 8), which is
  **16 pixels, P0 (leftmost) to P15**. In all three modes every raster is a
  whole number of fetches, so **a pixel's stage is X mod 16**.
- **Bank n** holds P2n in its low byte and P2n+1 in its high byte. Each pixel
  byte has its own 74F245 bus buffer.
- Pixel **bit b** of all 16 pixels goes into one 74F676, with pixel Pn on input
  D(15−n). D15 shifts out first. The overlay has its own 74F676, wired the
  same way.

| X mod 16 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| bank / byte | 0L | 0H | 1L | 1H | 2L | 2H | 3L | 3H | 4L | 4H | 5L | 5H | 6L | 6H | 7L | 7H |
| SRAM | U11 | U11 | U13 | U13 | U15 | U15 | U17 | U17 | U12 | U12 | U14 | U14 | U16 | U16 | U18 | U18 |
| 74F245 | U20 | U21 | U24 | U25 | U28 | U29 | U32 | U33 | U22 | U23 | U26 | U27 | U30 | U31 | U34 | U35 |
| 74F676 input | D15 | D14 | D13 | D12 | D11 | D10 | D9 | D8 | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 |

| pixel bit | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | overlay |
|---|---|---|---|---|---|---|---|---|---|
| 74F676 | U2 | U3 | U4 | U5 | U7 | U8 | U9 | U10 | U6 |

The overlay plane is SRAM U19 with buffers U36 (P0–7) and U37 (P8–15).

## The screens

| Key | Screen | A good board shows | What a fault shows |
|---|---|---|---|
| 1 | Border | A 1-pixel white rectangle on the outermost pixels, a green one 2 pixels in, red corner pixels, and the mode in the centre | Missing edge pixels: overscan or a timing (HDS/VDS) problem |
| 2 | Offset lines | White 1-pixel lines at X mod 16 = k, for one k. `+`/`-` (also space `,` `.`) step k, and `0`–`F` set it. The console names that stage's chips | A missing, doubled or shifted line points at that stage's SRAM byte, buffer and 74F676 input |
| 3 | Offset bands | All 16 offsets in one picture: band n (top = 0, labelled) has lines at X mod 16 = n, so the lines step 1 pixel right per band | A bad stage is one wrong band |
| 4 | Bit planes | Top row: index 1<<b, walking 1, one colour per bit. Then a white FF strip. Then FF xor 1<<b, walking 0, at half colour. Then 00 inside an FF outline | A bar in an unexpected colour, or a tinted strip, is a bad data bit: that 74F676, or Bt453 input P0–P7 |
| 5 | Pixel position | Each X mod 16 in its own colour, repeating, with a key along the bottom | Swapped colours are a swapped bank or byte lane |
| 6 | Overlay lines | Red frame lines at offset k under yellow overlay lines at the same offset, plus an overlay border. Keys as screen 2; `O` toggles the overlay | Red showing next to yellow is a registration fault. Lines missing on the overlay only point at U6, U19 or U36/U37 |
| 7 | Overlay bands | Screen 3's staircase, in red on the frame and yellow on the overlay, pixel for pixel. `O` toggles | |
| 8 | Solid fields | The whole screen in one colour. `K` `W` `R` `G` `B` `Y` `C` `M` `O` pick a colour, `H` is 50% grey | Speckle, stripes or tint: DAC channel, video path or monitor |
| 9 | Ramps | Red, green, blue and white, each in 32 even steps from black | A step out of order is a DAC fault |
| A | Grey ramp | Palette entry i set to grey i, with all 256 indices as bars from left to right | A jump or repeat at a power-of-2 boundary is a stuck pixel bit |
| C | Checkerboards | 1x1 and 2x2 checkerboards, then vertical and horizontal 1-on-1-off lines, white on black. Space or `C` steps through them | Smear or shimmer: shift clock, DAC settling or monitor bandwidth. This is the highest dot rate the board produces |
| G | Grid | A 32-pixel crosshatch centred on the screen, white every 128 pixels, a large circle, corner circles and the border | Non-round circles or an off-centre picture: monitor geometry or sync timing |
| M | Mode | Runs `GINIT` again for 640x480, 800x600 or 1024x768 | |
| Q | Quit | Also ESC or ^C. Any key the screen doesn't use goes back to the menu | |

The patterns are sized from the current mode, so every screen works in all
three. The program starts in 1024x768, which `machine.toml` straps for altairsim.
After `M`, the monitor must match the new mode. In altairsim that's
`monitor {command: "SET cad0 mode=800x600"}`, which lasts until the next
`CONFIG LOAD`.

## Verified in altairsim

Every screen was checked pixel by pixel against the frame buffer and overlay
from an altairsim snapshot, in all three modes: line positions, band offsets,
bar indices, palette entries, frame/overlay registration and edge pixels.
`board_get cad0` showed the mode's full size at (0,0), wiring `ok` and CER
clear throughout. The real board is still to come.
