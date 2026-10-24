# CADzilla +5V power estimate

An estimate of the board's +5V supply current from datasheet figures, and the
heat it puts into the regulator, U59 (LM1084-5.0). U59 drops the S-100 bus's
unregulated +8V to +5V.

Analysis date 2026-10-23. The parts list is from the saved KiCad schematic.

## Method and sources

- Each part's supply current comes from its datasheet in `docs/datasheets/`.
  The three exceptions are marked in the tables: the 74LS273 (TI's published
  figures), Y1 (an assumed value) and the HD63484 (the only figure is a
  maximum).
- The typical column uses each datasheet's typical figure, at VCC = 5.0 V and
  25 °C.
  - When a part has different currents for outputs high, low and disabled,
    the estimate uses the state the part is actually in most of the time.
  - When a datasheet gives only a maximum, that maximum is used in both
    columns. This makes the typical total slightly pessimistic.
- The maximum column uses datasheet maximums, which are specified at
  VCC = 5.5 V (5.25 V for the Bt453). At 5.0 V the real worst case will be
  somewhat lower.
- The video mode assumed is 1024x768: a 65 MHz pixel clock and
  2CLK = 8.125 MHz.
- Output load currents into the S-100 bus and the monitor's 75 Ω
  terminations are not counted separately. The Bt453's supply-current spec
  already includes its DAC output current.

## Supply current by part

| Ref | Part | Qty | Typ each | Max each | Typ total | Max total | Notes |
|---|---|---|---|---|---|---|---|
| U20–U40 | 74F245 | 21 | 85 | 110 / 120 | 1785 | 2330 | Outputs disabled most of the time: 85 typical, 110 max. Max total assumes 19 disabled plus one enabled pair with outputs low (120 each) |
| U2–U10 | 74F676 | 9 | — | 72 | 648 | 648 | Fairchild gives only a maximum |
| U45, U46, U48, U55–U58, U60 | GAL16V8, L suffix | 8 | 75 | 115 / 90 | 600 | 795 | Max is 115 for the -7 and -10 parts (U48, U55, U57) and 90 for the -15s. Specified at a 15 MHz toggle rate; U48 runs at 65 MHz |
| U47 | Bt453, 66 MHz grade | 1 | 220 | 275 | 220 | 275 | VAA supply current at the maximum clock, including the DAC outputs |
| U1 | HD63484-8 | 1 | — | 100 | 100 | 100 | `HD63484_datasheet_1.md`. The electrical specification lists Icc as "T.B.D" |
| U52–U54 | 74ALS857 | 3 | 16 | 33 | 48 | 99 | Outputs always enabled (S1 and COMP are tied to GND) |
| U11–U19 | CY62136ESL-45 | 9 | 5 | 7 | 45 | 63 | Interpolated between 2/2.5 mA at 1 MHz and 15/20 mA at 22 MHz, for a 4 MHz cycle rate. Raised slightly because the inputs see TTL, not CMOS, levels |
| U49, U50 | 74ALS573 | 2 | 12.5 | 24 | 25 | 48 | Average of outputs high and low; ~OE is tied to GND |
| U51 | 74LS244 | 1 | 22 | 46 | 22 | 46 | Average of outputs high and low; max is outputs low |
| Y1 | ACO-series oscillator, 65 MHz | 1 | 30 | 45 | 30 | 45 | **Assumed**: no part number or datasheet yet |
| U41 | 74LS273 | 1 | 17 | 27 | 17 | 27 | TI figures; no datasheet in the repo |
| U44 | 74LS85 | 1 | 10.4 | 20 | 10.4 | 20 | |
| U43 | 74LS86 | 1 | 6.1 | 10 | 6.1 | 10 | |
| U42 | 74LS04 | 1 | 2.4 | 4.5 | 2.4 | 4.5 | Average of high and low |
| R1, RN1, D1 | Pull-ups, 1.2 V reference | | | | 5 | 5 | Allowance |
| **Total** | | | | | **≈ 3560 mA** | **≈ 4520 mA** | |

All currents are in mA.

| | Typical | Maximum |
|---|---|---|
| +5V current | 3.56 A | 4.52 A |
| +5V power | 17.8 W | 22.6 W |

### Where the current goes

| Group | Typical | Share |
|---|---|---|
| 74F245 data buffers (21) | 1.79 A | 50% |
| 74F676 shift registers (9) | 0.65 A | 18% |
| GAL16V8s (8) | 0.60 A | 17% |
| Bt453 | 0.22 A | 6% |
| Everything else | 0.31 A | 9% |

The 74F245s draw 85 mA each even with their outputs disabled, which is the
state most of them are in almost all the time. The 18 frame-buffer and
overlay buffers turn on only for one bank during a drawing cycle, and the
three S-100 buffers only during a board I/O cycle.

## Regulator dissipation (U59, LM1084-5.0)

U59 is a linear regulator, so it dissipates (Vin − 5 V) × I. Its input is the
S-100 +8V line, which is unregulated and in practice often runs above 8 V.

| +8V line actually at | Typical (3.56 A) | Maximum (4.52 A) |
|---|---|---|
| 7.0 V | 7.1 W | 9.0 W |
| 8.0 V | 10.7 W | 13.5 W |
| 9.0 V | 14.3 W | 18.1 W |
| 10.0 V | 17.8 W | 22.6 W |

- **Heatsink.** U59 needs a substantial heatsink at any realistic input
  voltage. To size it, use the highest +8V voltage your backplane delivers
  under load and the maximum current.
- **Current headroom.** The 4.52 A maximum is 90% of the LM1084's 5 A
  rating.
- **Dropout.** The LM1084's dropout at 4–5 A is about 1.3–1.5 V, so U59 needs
  at least about 6.5 V in. A heavily loaded or sagging +8V supply near 7 V
  leaves little margin.
- **Bus contacts.** The whole board current comes in through the S-100 +8V
  contacts, P1 pins 1 and 51, about 2.3 A per contact at the maximum. Check
  that against the edge connector's contact rating.

## Ways to reduce the load

These are noted for reference only; nothing here is a planned change.

### Replacing the 74F245s

The 21 74F245s are half the board's current. That is because a bipolar F245
draws 85 mA even when its outputs are disabled.

**Timing limits for the memory buffers (U20–U37).** A replacement must keep
the drawing read inside the budget in `memory-timing.md` (8 MHz figures):

- **Data delay (max) ≤ 13 ns.** The data path is ~MOE/~OLOE at 175 ns, plus
  SRAM tDOE 22, plus the buffer's delay, and the data must arrive by 210 ns.
- **Enable time (max) ≤ 30 ns.** ~MDEN asserts at 180 ns (U58, GAL16V8-15).
  U36/U37 are enabled by ~OLDEN at 175 ns (U55, -10), so they can take
  35 ns.

Write setup is much looser: a delay up to 33 ns and an enable time up to
48 ns both still pass. The write-data hold margin equals the buffer's
minimum delay (+1.7 ns for the F245).

**Drive requirement for U38–U40.** These face the S-100 bus. Bus I/O cycles
are stretched by RDY wait states, so they aren't timing-critical, but the bus
needs 24 mA of drive.

Read margin is 210 − max(197 + delay, 180 + enable time):

| Part | Max delay | Max enable | Min delay | Read margin, 8 MHz (8.125 MHz) | Disabled ICC typ / max | Drive (IOL) | I/O capacitance | Available by 1984 |
|---|---|---|---|---|---|---|---|---|
| 74F245 (current) | 7 | 9 | 1.7 | +6.0 (+4.1) | 85 / 110 mA | 24 mA A side, 64 mA B side | | yes |
| 74ALS245A | 10 | 20 | 3 | +3.0 (+1.1) | 38 / 58 mA | 24 mA (48 mA for -1) | | yes |
| 74AS245 | 7.5 | 9 | 2 | +5.5 (+3.6) | 95 / 143 mA (outputs low) | 64 mA | | yes |
| 74LS245 | 12 | 40 | | **−10** (limited by enable time) | 62 / 90 mA | 24 mA | | yes |
| 74HCT245 | 28 | 58 | | **−28** | µA | 6 mA | | yes (datasheet dated March 1984) |
| 74BCT245 | 7 | 11.6 | 1 | +6.0 (+4.1) | 10 / 15 mA | 64 mA | | no (BiCMOS, late 1980s) |
| 74ABT245B | 3.9 | 6.2 | 1 | +9.1 (+7.2) | 0.001 / 0.25 mA | 64 mA | 8 pF | no (1991) |
| 74ACT245 | 9 | 12 | 1 | +4.0 (+2.1) | µA, plus 1.5 mA per input at TTL levels | 24 mA | 15 pF | no (mid-1980s) |
| 74AHCT245 | 9.5 | 16 | 1 | +3.5 (+1.6) | µA | 8 mA | 4 pF | no (1995) |

- Times are in ns: SN74 maximums over temperature at CL = 50 pF, from TI's
  current datasheets.
- Blank I/O-capacitance cells mean the datasheet doesn't give a figure.
- Every part listed is still active in PDIP.
- All the datasheets are in `docs/datasheets/`: `sn74als245a.pdf` (which
  also covers the 74AS245), `sn74ls245.pdf`, `sn74hct245.pdf`,
  `sn74bct245.pdf`, `sn74abt245b.pdf`, `sn74act245.pdf` and
  `sn74ahct245.pdf`.

**Bus loading caveat.** These delays are specified at 50 pF. A MAD line
actually carries all of these:

- the ACRTC's 17 pF;
- one latch;
- eight disabled buffer ports;
- the trace.

That comes to roughly 100–150 pF. The HCT245 datasheet shows its delay
growing by 10 ns between 50 pF and 150 pF. Parts with small margins or weak
drive (ALS245A, AHCT245) lose the most. The current F245's +6.0 ns is
exposed to this too, because `memory-timing.md` doesn't derate for load. The
ACT245 also adds load of its own: its 15 pF ports put about 120 pF on each
MAD line from the disabled buffers alone.

**Board +5V current with each replacement:**

| Option | +5V typical | +5V maximum | U59 at 8 V in, typ / max |
|---|---|---|---|
| All 74F245 (current) | 3.56 A | 4.52 A | 10.7 / 13.5 W |
| 74ALS245A in U38–U40 only | 3.42 A | 4.36 A | 10.3 / 13.1 W |
| All 74ALS245A | 2.58 A | 3.41 A | 7.7 / 10.2 W |
| All 74BCT245 | 1.99 A | 2.65 A | 6.0 / 8.0 W |
| All 74ABT245B | 1.78 A | 2.25 A | 5.3 / 6.8 W |

The maximum totals assume 19 buffers disabled and one pair enabled with
outputs low.

**How the options compare:**

1. **74ABT245B.** It has the most timing margin (+9.1 ns), 64 mA drive on
   both ports, low I/O capacitance, and the lowest current, saving about
   1.8 A. It is **substantially cheaper than the 74BCT245**.
   - It is a 1991 part, so it breaks the board's 1984-parts rule.
   - Its fast edges on long MAD traces are worth checking for ringing.
   - Its 1 ns minimum delay reduces the write-data hold margin from +1.7 ns
     to +1.0 ns.
2. **74BCT245.** It is effectively a drop-in: the same 7 ns delay as the
   F245, so the same +6.0 ns margin, with 64 mA drive. It saves about 1.6 A
   but costs more than the ABT245B, and it is also post-1984.
3. **74ALS245A**, the only period-correct part that meets the budget. It
   saves about 1 A, but its +3.0 ns paper margin (+1.1 ns at 1024x768) is
   not enough once the real MAD bus load is counted.
   - GAL16V8-7s in U57 and U55 would bring it to +5.5 ns (+3.6 ns at
     8.125 MHz), still less than the F245 has today.
   - In U38–U40 alone, the ALS245A is low risk: those cycles aren't
     timing-critical, it meets the S-100 bus's 24 mA drive, and it saves
     about 140 mA.
4. **Not viable:**
   - the 74HCT245 and 74LS245 fail the read budget, and the LS245 wouldn't
     save power anyway;
   - the 74AHCT245's 8 mA drive is too weak for the MAD bus and the S-100
     bus;
   - the 74ACT245 meets timing on paper but loads MAD heavily, and it
     offers nothing over the ABT245B;
   - the 74AS245 draws more current than the F245.

### GAL16V8 Q parts

Q parts in the five -15 positions (U45, U46, U56, U58, U60) would save about
150 mA typical and 175 mA maximum.

## Gaps and assumptions

| Item | Assumption | Effect |
|---|---|---|
| Y1 has no part number ("ACO-xxxMHz") | 30 mA typical, 45 mA max at 65 MHz | ±20 mA |
| GAL16V8 L or Q suffix not recorded | L for all eight | Q -15 parts would be 150–175 mA lower |
| Bt453 speed grade | 66 MHz grade, needed for a 65 MHz PCLK | The 40 MHz grade is 30 mA lower, but too slow for 1024x768 |
| HD63484-8 and 74F676 have no typical figure | Maximum used in both columns | Typical total is pessimistic by perhaps 100–200 mA |
| 74LS273 datasheet not in the repo | TI figures (17 typical / 27 max) | Small |
| S-100 +8V voltage under load | 7–10 V shown | Sets U59's dissipation |

## To measure on hardware

1. +5V current at U59's output, in each of these states:
   - idle with display on;
   - during continuous drawing;
   - at each display mode.
2. The +8V voltage at P1 under load, to size U59's heatsink.
3. U59's case temperature after it has reached a steady temperature, in the
   enclosure it will run in.
