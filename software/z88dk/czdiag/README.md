# czdiag — CADzilla low-level test and debug utility

`CZDIAG` tests a CADzilla board one layer at a time, from the bottom up. Each
layer is tested using only what the layers below it have already shown to
work:

1. the Bt453 DAC
2. the MODE register
3. the HD63484 ACRTC's host interface (its registers), then its FIFOs and
   command interface
4. the clock and display time base
5. frame-buffer and overlay memory, written and read back through the
   command interface

Each check prints one `PASS` or `FAIL` line. A failure is preceded by
details naming the register, address, bank, bit or chip at fault. Where
testpat (`software/m80/testpat`) shows a picture to be judged by eye, czdiag
reads values back and compares them itself.

It is an 8080 program built with the z88dk host toolchain (skill
`cadzilla-build-z88dk`). It runs on an 8080, 8085 or Z80. It is
**standalone**: it links neither czgfx nor cz88gfx, so a library bug can't
hide a hardware fault, or invent one. It copies czgfx's mode register tables
(`src/TABLES.Z88`) and default palette, so it sets the board up exactly as
czgfx does.

```
software/z88dk/czdiag/build.sh          # builds build/CZDIAG.COM onto work/'s A:
A0>CZDIAG                               # the menu
A0>CZDIAG ALL MHZ=4                     # every stage, CPU clock 4 MHz
A0>CZDIAG FRAME OVL FULL                # the memory, every word
```

## Command line

```
CZDIAG [ALL] [DAC MODE ACRTC FIFO CLOCK FRAME OVL] [FULL] [GO] [MHZ=n.nnn] [RES=640|800|1024]
```

- With no stage named, CZDIAG opens the menu.
- Named stages always run in the order above.
- If ACRTC or FIFO fails, the stages after it are skipped, because they
  depend on it. `GO` runs them anyway.
- `FULL` marches over every word of video memory: 1M frame words and 128K
  overlay words, two passes each. On a 2 MHz 8080 that takes about 8
  minutes. ESC stops it. Without `FULL`, the march covers the first and last
  16K frame words and the first and last 4K words of each overlay half.
- `MHZ` is the CPU clock, from 0.001 to 10 MHz, for the clock measurement.
  If you don't give it, 2 MHz is assumed, and a frequency that doesn't match
  is reported as INFO, not as a FAIL.
- `RES` picks the display mode. The default is 1024x768. It must match the
  monitor, which in altairsim is the cad0 `mode` in `machine.toml`.

The run ends with a line `czdiag: <n> passed, <m> failed`. Every line starts
with `PASS`, `FAIL`, `INFO`, `  !` (an error's detail) or `--` (a stage
heading), so a headless run is easy to grep.

The menu has the same seven stages as keys `1`-`7`, plus:

- `A`: run all seven stages
- `L`: turn the FULL memory tests on or off
- `C`: set the CPU clock
- `R`: set the display mode
- `V`: the visual check (below)
- `P`: register peek and poke

## Read this before the first run on new hardware

- **The ACRTC can hang the machine, and no software can catch it.** U45 holds
  S-100 RDY low until the ACRTC answers with ~DTACK (`pld/src/u45.pld`). With
  no 2CLK, the ACRTC never answers, and the first `IN` or `OUT` to Base+0 or
  Base+2 leaves the CPU in a wait state for good. That is why the DAC and
  MODE stages run first: they don't use RDY. Before its first ACRTC access,
  czdiag prints a warning naming what to check: Y1, U48 (2CLK), U45 (CS, RDY)
  and SW1.
- **czdiag never sets MODE AMODE (bit 2).** AMODE makes U48 divide by 4
  instead of 8. With the 65 MHz oscillator, that gives a 16.25 MHz 2CLK, twice
  the HD63484-8's rating. Peek/poke masks AMODE out as well.
- **CCR interrupt enables are never set.** SW1-8 may connect the ACRTC's IRQ
  to the bus.
- **The base address is fixed at build time,** because the 8080's `IN` and
  `OUT` take the port as an immediate byte. The default is 70H. For another
  SW1 setting, put `-DCZBASE=0x..` in a `z88dk.flags` file in the project
  and rebuild.
- **The FRAME and OVL stages are destructive.** What they write shows on the
  screen. The DAC stage puts black specks on the screen while it runs,
  because the Bt453 blanks its output whenever it is selected.

## The stages

| Stage | What it checks | What it proves |
|---|---|---|
| **DAC** | The Bt453 address register is written at +4 and +6 and read at both (20 patterns). The address steps on after blue and wraps from 0FFH to 0. All 256 palette entries, R, G and B, take 22 patterns: walking 1s, walking 0s, 00, FF, 55, AA, and one value per address. Writing the address resets the R/G/B phase. Overlay colors 1-3 take the same 22 patterns. Palette entries and overlay colors don't overwrite each other. Afterwards the default palette is restored | Board decode for +4 to +7 (U45 `DAC_RD`/`DAC_WR`), the data bus D0-D7, and the Bt453's MPU port. It says nothing about the pixel clock, because the MPU port is asynchronous to the video |
| **MODE** | Writes the mode's MODE value. Base+1 and +3 are read and shown as INFO: no chip drives them, so the bus floats | MODE can't be read back. OLSEL is checked by OVL. OLEN and the sync polarities can only be checked by eye (`V`) |
| **ACRTC** | Abort, then SR = 23H (an LPD bit set is reported separately). With the display stopped (STR=0), every bit of timing RAM r82-r9C and display-control RAM rC0-rEA is walked (36 patterns; r9E is skipped, it is the chip's work area). Then a different value goes into every register and all are read back. AR auto-increments from r80 up, on writes and on reads, but not below r80. DCR's ATR byte is walked, CCR's GBM is set to 0-4, and OMR bits 13-0 are walked. Last, the mode is loaded and every register is read back | U45 chip select and RS, AR, both halves of every register, D0-D7 through the ACRTC, and AR decode |
| **FIFO** | Drawing parameter registers Pr00-Pr0D with all patterns, through WPR and RPR (bits the manual says always read 0, in Pr06 and RWP, are masked). The 16-word pattern RAM with 3 patterns, through WPTN and RPTN. A command sent half-way must leave CED clear, and AMOVE must move CP (read back with RPR, including negative values). The FIFO flags: RPTN of 16 words fills the 8-word read FIFO (RFF and RFR must set) and stalls, so 8 more words fill the write FIFO (WFR and WFE must clear); then everything drains (CED set, RFR clear). An undefined command (0000H) must set CER, and abort must clear it | Both FIFOs, the command processor, and the status register's bits in both states |
| **CLOCK** | Samples the raster counter RCR 512 times: it must change, stay within 0..VC-1, and keep bits 15-12 at 0. Then it times 4 frames by RCR's wrap with a loop of known cycle count (290/268/277 cycles per pass on an 8080/8085/Z80, detected at run time) and works out the frame rate, raster rate, 2CLK and pixel clock. These are compared with the mode's own (25.175/40/65 MHz) and with the standard oscillators. Last, STR=0 must hold a CLR, and STR=1 must let it finish | See "Can the host see the clocks?" below |
| **FRAME** | In each of the 8 banks, all 16 data bits (36 patterns at words 0-7). Bank select: words 0-15, two of each bank, take different values. Every address line: in each bank, words b and b+2^k (k = 3..19, the chips' A0-A16) take different values, and all are written before any is read. Then an address-in-address march (DWT writes, DRD reads, then all of it again complemented): quick by default, or every word with `FULL` | U11-U18, the bank decode U56-U58, the address latches U49/U50, and the data buffers |
| **OVL** | The same tests on U19, through the never-displayed CHR screen (DN 0): data bits, address lines A0-A15 in both halves, and a march. OLSEL must pick the half: word 0 of each half holds a different value | U19, the drawing-side address mux, and MODE OLSEL (U41) driving U19 A16 |

A frame-buffer error names the bank and the chip, and says whether the bad
bits are in the low byte (the even pixel) or the high byte (the odd pixel):

| bank (word address mod 8) | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| SRAM | U11 | U13 | U15 | U17 | U12 | U14 | U16 | U18 |

Word address bit k (k ≥ 3) is SRAM pin A(k−3). testpat's README maps each
byte to its 74F245 and 74F676.

## Can the host see the clocks?

Partly. The board has one oscillator, Y1 (PCLK). U48 divides it by 8 into
the ACRTC's 2CLK.

- **2CLK, and so Y1, is running** if any ACRTC access completes. With a dead
  clock the CPU hangs on the access (above), so czdiag reaching the ACRTC
  stage is itself the proof.
- **The display time base is running** if RCR (r80-r81) counts up. RCR only
  counts with STR=1.
- **Frequencies.** Given the CPU clock, timing RCR's wraps measures the frame
  rate. The mode's VC and HC+1 then give:
  - raster rate = frame rate × VC
  - 2CLK = raster rate × (HC+1) × 2 (an ACRTC memory cycle is two 2CLKs)
  - PCLK = 8 × 2CLK

  This tells which oscillator is fitted.

  - RCR is read high, low, high. A read whose two high bytes differ is
    dropped (the manual allows reads only while HSYNC is high).
  - A drop of RCR counts as a wrap only if it is over VC/2 and lands below
    VC/4.
  - If the 4 frames disagree by more than 1/32, the measurement is flagged.
  - Wait states make the CPU loop slower than its nominal cycle count, so the
    clocks then read low. That includes the ACRTC's ~DTACK on each of the
    loop's 3 accesses.

- **Not visible from the host:** PCLK at the shift registers and the Bt453,
  the syncs and their polarity, and OLEN. The `V` picture covers these: a
  white frame at the screen's edge, eight bars (one per hue), a 32-step gray
  ramp, and an overlay grid every 64 pixels. `O` turns the overlay off and
  on.

## Other host-visible checks, and what is left

- **Also checked:** port decode and aliasing (DAC and ACRTC registers), D0-D7
  on every path, both states of every SR flag, CER and abort recovery, STR
  gating, and OLSEL/A16 through the overlay memory.
- **Not yet checked:**
  - the CCR interrupt enables and the SW1-8 interrupt strap
  - ARD (area detect)
  - LPD: the board has no light pen. If LPD is ever set, the test reports
    it, since LPSTB may not be tied inactive

## In altairsim

`CZDIAG ALL MHZ=2` gives 28 PASS and 1 FAIL. The results are the same with
cad0 `draw_rate=real` (datasheet command timing).

What altairsim can't show:

- **RCR always reads 0.** "CLOCK raster counter RCR runs" therefore fails,
  with an INFO line saying why, and the frame timing is skipped.
- **Drawing is not held with STR=0.** The CLR runs anyway, which is reported
  as INFO.
- **Wait states and DTACK** aren't modelled.

What was checked by hand:

- **The loop timing.** The 8080 timing loop measured exactly 290 cycles per
  pass. The frequency arithmetic was checked by putting a 60 Hz set of frame
  counts into the loop's results and jumping to the calculation. It reported
  59.970 Hz, 48.335 kHz, 2CLK 8.120 MHz and PCLK 64.960 MHz, which it named
  as the 65 MHz oscillator.
- **No board at the base address.** With cad0 moved to another port, every
  test fails cleanly, nothing hangs, and with `GO` all the stages still run
  and fail.
- **The `V` picture,** decoded from a snapshot.
- **FULL.** Both marches pass.

## Files

| File | Contents |
|---|---|
| `src/CZDIAG.Z88` | Main: the command line, the menu, the stage sequencer, `V` and `P` |
| `src/CZDIAG.INC` | Ports, MODE and SR bits, ACRTC opcodes, mode descriptor offsets |
| `src/HW.Z88` | ACRTC and MODE access. Every wait has a timeout (TOFLG), and AR is kept at r00 |
| `src/REPORT.Z88` | `PASS`/`FAIL`/`INFO` reporting, and 32-bit arithmetic |
| `src/CONIO.Z88` | Console I/O and number parsing |
| `src/TABLES.Z88` | The three modes (czgfx's tables), `LDMODE`, `CLS` |
| `src/TDAC.Z88` | Stages DAC and MODE, and the default palette |
| `src/TACR.Z88` | Stages ACRTC and FIFO |
| `src/TCLK.Z88` | Stage CLOCK, and CPU detection |
| `src/TMEM.Z88` | Stages FRAME and OVL |
