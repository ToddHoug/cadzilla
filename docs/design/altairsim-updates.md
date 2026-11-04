# altairsim updates needed for CADzilla

The changes altairsim (`~/altairsim`, the owner's fork) needs before it
matches the real board. Each item says what the real chip does, what
altairsim does now, and where to change it. Add new items as they turn up,
and remove one once it's fixed.

## Display timing (found 2026-11-04)

Source: the board B scope measurements in `video-timing-test.md` and the
memory note `acrtc-horizontal-timing-rules`. czgfx 1.5, cz88gfx 1.6, czdiag,
firstdraw and drawdemo already use the new tables. Until altairsim follows,
their pictures render 16 px left of where they should be, and too narrow by
one word (1008 px at 1024x768).

1. **Display fetches per line.**
   - Real chip, single access: HDW+2 fetches, the first one memory cycle
     before ~DISP1 falls. U48 shows every fetch, so the picture starts at
     ~DISP1's fall (HDS+1 cycles after the HSYNC rise) and is HDW+2 words
     of 16 px wide.
   - Real chip, interleaved access (MODE AMODE=1, OMR ACM=10): one fetch
     every second memory cycle, starting 2 cycles before ~DISP1, one more
     fetch than ~DISP1 covers. The picture is (HDW+1)/2 + 1 words wide and
     starts one 8-px cycle before ~DISP1.
   - altairsim: HDW+1 at HDS+1 (`CadzillaBoard::programmedWidth()`,
     `programmedX()`, and `run(dst, (hds - hbp) * ppmc, hdw, addr)` in the
     render loop, `src/boards/cadzilla.cpp`; `hdw()`/`hds()` in
     `src/chips/hd63484.h`).
2. **Minimum front porch.**
   - Real chip: if HC+1 − HSW − (HDS+1) − (HDW+1) is under 5 memory cycles,
     the line is stretched until it is 5. With at least 5, the line is
     exactly HC+1.
   - altairsim: probably takes the line as HC+1 regardless. Check whatever
     derives time from HC (RCR, frame rate, czdiag's CLOCK stage).
3. **Monitor modes (`kModes` in `src/boards/cadzilla.cpp`).** The expected
   porches have to match the new tables, so `board_get cad0`'s `picture`
   line reads full size `at (0,0)`.

   | Mode | Pixel clock | Access | Line (cycles) | HSW | ~DISP1 after HSYNC rise | Picture starts |
   |---|---|---|---|---|---|---|
   | 1024x768 | **64 MHz** (was 65) | single, 16 px/cycle | 84 | 6 | 9 | 9 |
   | 800x600 | 40 MHz | single, 16 px/cycle | 66 | 7 | 5 | 5 |
   | 640x480 | 25.175 MHz | **interleaved**, 8 px/cycle | 100 | 12 | 4 | 3 |

   Vertical timing is unchanged.
4. **`docs/boards/cadzilla.md` and the tests.** Update the mode table, the
   65 MHz figure, and `tests/test_cadzilla.cpp` / `tests/test_hd63484.cpp`
   expectations to the register values below.

The new CADzilla register values, for the tests:

| Mode | MODE | OMR (running) | HSR | HDR | VSR | VDR |
|---|---|---|---|---|---|---|
| 1024x768 | 03H | C0B0H | 5306H | 083EH | 0326H | 1C06H |
| 800x600 | 00H | C0B0H | 4107H | 0430H | 0274H | 1604H |
| 640x480 | 07H | C0B8H | 630CH | 034DH | 020DH | 2002H |

Done when: altairsim builds and passes its tests, and z88demo (1024x768) and
gfxdemo in 640x480 both show `picture ... at (0,0)` at full size.

## Already known, not modelled

From CLAUDE.md and the library READMEs; listed here so the gaps are in one
place. Each one would need its own design in altairsim:

- ELPS/EARC parameter limit: the real chip hangs past it (`acrtc-elps-param-limit`).
- PAINT's 4-seed stack overflowing to the read FIFO (`acrtc-paint-seed-stack`).
- PAINT in CMPRAM (any color mode but CMSEL) never ending (`acrtc-paint-cmpram-endless`).
- After an AREA stop-mode truncation the chip ignores everything until an
  abort, and sets no ARD (`acrtc-stop-mode-rpr-dead`).
- A second program's commands queued behind CZINIT's clears hanging (`acrtc-second-program-hang`).
- RCR always reads 0 (czdiag README, "In altairsim").
