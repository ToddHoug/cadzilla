# ROCKFALL

A vector space rock shooter for CADzilla, written in 8080 assembly with z88dk
and drawn with cz88gfx 1.5, at 1024x768.

You fly a small ship through a field of drifting rocks. When shot, a large
rock breaks into two medium ones and a medium rock into three small ones. A
small rock is destroyed. Now and then a magenta raider crosses the screen and
fires at the ship. Hitting a rock, the raider or one of its shots costs a
ship. You start with five, and you get a bonus ship every 10,000 points, up
to nine. Everything wraps around the screen edges, the ship included.

**A lost ship comes back at once,** in the middle of the screen, on the next
frame. It flashes blue and can't be hit for `INVULF` frames (56, about 3
seconds). Its protection ends sooner, the moment no rock, raider or raider
shot is within `CLRAD` (100) pixels of it. A ship that comes back into empty
space can therefore be hit straight away. After the last ship is lost,
GAME OVER comes up `DEADF` frames (30) later, so the explosion shows first.

**Rocks never run out.** The screen always holds at least `MINBIG` large or
medium rocks: 2 on wave 1, one more every other wave, up to 5. When they run
short, another large rock drifts in about 1.5 seconds later. It comes in on
the left or bottom edge, well away from the ship. Each wave has a quota of
large rocks, the wave number plus 4 (14 at most). A wave starts with
`MINBIG`+1 of them; once the quota is spent, the next wave starts the moment
the big rocks run short again.

**Each wave is harder:**
- more big rocks at once;
- faster rocks;
- raiders that come sooner and fire faster.

Inside a wave, every half minute or so the next rocks get faster again.

**The raider aims at the ship** to 1/128 of a turn (2.8 degrees), with its
shots at 7 pixels a frame:

| Wave | Raider fire |
|---|---|
| 1 | aimed at the ship, up to 3 steps (8 degrees) off either way |
| 2 | leads the ship, up to 2 steps off |
| 3, 4 | leads the ship, up to 1 step off |
| 5 on | leads the ship, exactly |

To lead, it aims where the ship will be when the shot arrives if the ship
coasts. That allows for friction, which slows a coasting ship by 1/64 a frame
(the `EFFT` table). A ship under thrust or turning gets away from it.

| Key | Does |
|---|---|
| W | thrust |
| A / D | turn left / right |
| space | fire, up to 8 shots in flight (start a game on the title screen) |
| P | pause (any key resumes) |
| Q, ESC, ^C | back to CP/M |

| Target | Points |
|---|---|
| large rock | 20 |
| medium rock | 50 |
| small rock | 100 |
| raider | 300 |

Keys are read through BDOS function 6, which has no key-up events. After
each character, a key keeps working for a few frames (`HOLDT` for thrust,
`HOLDR` for turning), so holding a key down relies on the terminal's
auto-repeat. A single tap turns the ship 22.5 degrees.

## Files

| File | What |
|---|---|
| `src/ROCKFALL.Z88` | the game |
| `src/RFTAB.INC` | lookup tables, generated: don't edit |
| `tools/mktables.py` | writes `RFTAB.INC`: the per-heading vectors, the ship and flame outlines for 32 headings, the raider's shot velocities for 128 aim directions, the rock outlines in three sizes (random, from a fixed seed), the raider, the life icon, the aiming arctangent and the coasting table |
| `machine.toml` | 1024x768, 8080 |
| `cz88gfx.version` | 1.5 |

Build it with `software/z88dk/rockfall/build.sh`, after
`python3 software/z88dk/rockfall/tools/mktables.py` if the tables changed.
Then run `ROCKFALL` on the project's `work/` machine (skill
`cadzilla-build-z88dk`).

## How it draws

- **XOR vectors.** The playfield is drawn in `OMEOR` with `AMCLIP`. Each
  frame, every object is drawn again where it was, which erases it, then
  moved and drawn at its new place. Each shape is one RPLG polygon: an AMOVE
  to its first vertex, then a fixed list of deltas from the table, so the
  8080 adds nothing per vertex.
- **Wrap ghosts.** An object within its radius of an edge is drawn at the
  opposite side too, and the area clip trims both copies. Objects slide
  across the wrap instead of jumping.
- **The overlay** holds the score, the high score, the wave, the ships left
  and every message. None of it touches the XOR picture.
- **The stars** are drawn once per game, in replace mode. XOR drawing passes
  over them without harm.
- **FSEND.** Most of a frame is the 8080 feeding words to the ACRTC.
  - `CZPUTW` checks the status before every word, about 140 T-states a word
    with the loop around it.
  - `FSEND` waits once for the 8-word write FIFO to empty, then fills it from
    an unrolled `LDAX`/`OUT`/`INX` block, about 45 T-states a word.
  - The shape tables store the deltas high byte first for it.
  - `FSWAIT` and `FSBLK` are the program's only ACRTC port accesses, and they
    are aligned to cz88gfx 1.5's A1 rule: after port 70H the next opcode
    fetch has A1 = 0, after 72H A1 = 1. The build's listing and map show
    `FSWAIT` at 2 mod 4 and `FSBLK` at 3 mod 4. Keep it that way if code
    above them changes.

## Timing

The board has no timer and no vertical sync, so each frame ends with `GWAIT`
and a delay of `FRAMED` loops, less `OBJK` for every object drawn or erased.
The frame rate stays even until that delay runs out; past that, a crowded
screen runs slower.

Measured in altairsim under `work/cadzilla-real.toml` (2 MHz,
`draw_rate = "real"`): about 18 frames a second on wave 1, and still about
19 on wave 6 with six big rocks and a raider on screen. Every speed in the
tuning block at the top of `ROCKFALL.Z88` is per frame, so a real board that
draws at a different rate needs those numbers tuned again.

## Not tested yet

- It has run in altairsim only. The real Altair is an 8080 at 2 MHz, which is
  what this targets, but it hasn't been played on boards A or B.
- altairsim doesn't model the real chip's hangs. ROCKFALL avoids all the
  known ones: it uses no PAINT, no ELPS or arcs, and no AREA stop modes.
