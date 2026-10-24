# CADzilla memory-cycle timing

Worst-case timing budget for the frame-buffer (U11–U18) and overlay (U19)
SRAM cycles, for display and drawing cycles, at 2CLK = 8 MHz in single access
mode (AMODE = 0, PCLK = 64 MHz). The 1024x768 case, with a 65 MHz PCLK and
2CLK = 8.125 MHz, is given alongside.

Analysis date 2026-10-23. Logic is from `pld/src/u48.pld` and
`u55.pld`–`u58.pld` (revisions of 10/02/26). Nets are from the saved KiCad
schematic.

## Method and sources

- Every figure is a datasheet min/max. Nothing is derated for trace length or
  bus loading. The MAD bus carries U1, U49/U50, sixteen 74F245s and U36/U37.
- HD63484-8 AC characteristics, items 49–66 and 72, are from
  `docs/datasheets/HD63484_Electrical_Specification.md`. The edge each item is
  measured from was checked against the original scans of Fig T-7 (read) and
  Fig T-8 (write), manual pages 323–324.
- Part timing comes from the datasheets in `docs/datasheets/`, except the
  74LS244, which has no datasheet in the repo. Its 18 ns maximum is TI's
  figure.
- "Margin" is available time minus needed time. A negative margin is a
  violation on paper.

### Parts in the memory path

| Ref | Part | Role | Timing used (ns) |
|---|---|---|---|
| U1 | HD63484-8 | ACRTC | see below |
| U49, U50 | 74ALS573 (the schematic Value says 74LS573; the board uses ALS) | MAD0–15 → MA0–15 latch, LE = ALE | D→Q 2–14, LE→Q 6–20, tsu 10, th 7 |
| U51 | 74LS244 | MA16/RA0–MA19/RA3 → MA16–19 buffer | tpd ≤ 18 |
| U52–U54 | 74ALS857 | U19 address mux (S0 = OADISP) | A/B→Y 4–18, S→Y 7–33 |
| U11–U19 | CY62136ESL-45 | 128K x16 SRAM | tAA 45, tACE 45, tDOE 22, tPWE 35, tSD 25, tHD 0, tAW 35, tSCE 35, tSA 0, tHA 0, tOHA ≥ 10 |
| U20–U37 | 74F245 | SRAM ↔ MAD data buffers | A↔B 1.7–7, OE→on 2.2–9, OE→off ≥ 1.2 |
| U2–U10 | 74F676 | pixel shift registers, load on CP↓ | Pn tsu 3 / th 4; M (LD) tsu 8 / th 2 |
| U48 | GAL16V8-7 | 2CLK, FETCH, PLOAD, PCLK | tpd 1–7.5, tco 1–5, tsu 5 |
| U55, U57 | GAL16V8-10 | ~MWE, ALE, OADISP, ~OLxx; ~MOEn | tpd 3–10 |
| U56, U58 | GAL16V8-15 | ~MCEn; ~MDENn | tpd 3–15 |

### Address and data paths

- MAD0–15 pass through U49/U50 to MA0–15.
- MA16/RA0–MA19/RA3 pass through U51 to MA16–19. They are not latched.
- Frame-buffer SRAM A0–A16 are wired to MA3–MA19. MA0–2 pick the bank.
- U19's address comes from U52–U54. During drawing (OADISP = 0), A0–A15 =
  MA0–MA15 and A16 = OLSEL. During display (OADISP = 1), A0–A16 = MA3–MA19.
- Frame-buffer SRAM I/O connects to MAD through U20–U35, and directly to the
  74F676 inputs.
- U19's I/O connects to MAD through U36/U37, and directly to U6.

## Memory cycle structure

Every HD63484 memory parameter is measured from a 2CLK **falling** edge. A
memory cycle is two 2CLK periods. MCYC is low in the address half and high in
the data half.

| Edge | 8 MHz | 8.125 MHz | What happens |
|---|---|---|---|
| F1 (2CLK ↓) | 0 | 0 | Address half starts |
| R1 (2CLK ↑) | 62.5 | 61.5 | |
| F2 (2CLK ↓) | 125 | 123.1 | Data half starts |
| R2 (2CLK ↑) | 187.5 | 184.6 | ~MWE asserts on a drawing write |
| F3 (2CLK ↓) | 250 | 246.2 | Cycle ends |

### HD63484-8 parameters used

| Item | Parameter | Value (ns) | Reference edge |
|---|---|---|---|
| 50 | ~AS ↓ delay | ≤ 65 | F1 |
| 51 | ~AS low width | 30 to tPWCL (62.5) | |
| 52 | MAD address valid | ≤ 70 | F1 |
| 53 | Address hold (tMAH1) | ≥ 10 | ~AS ↑ |
| 49 | Address hold (tMAH2) | ≥ 10 | F2 |
| 54 | Address turn-off | ≤ 50 | F2 |
| 57/58 | MA16–19 valid / hold | ≤ 70 / ≥ 10 | F1 / F3 |
| 59 | MCYC delay, both edges | ≤ 40 (no minimum given) | F1 ↓, F2 ↑ |
| 60–63, 72 | MRD, ~DRAW, CHR valid / hold | ≤ 70 / ≥ 10 | F1 / F3 |
| 55/56 | Read data setup / hold | ≥ 40 / ≥ 10 | F3 |
| 64 | Write data valid | ≤ 70 | F2 |
| 65/66 | Write data hold / turn-off | ≥ 10 / ≤ 40 | F3 |
| 1–3 | 2CLK period / high / low | ≥ 125 / ≥ 55 / ≥ 55 | |

## Signal arrival times (8 MHz, worst case, from F1)

| Signal | Path | Valid by |
|---|---|---|
| ALE ↑ | ~AS 65 + U55 10 | 75 |
| MA0–15 | max(MAD 70 + D→Q 14, ALE 75 + LE→Q 20) | 95 |
| MA16–19 | 70 + LS244 18 | 88 |
| OADISP | ~DRAW 70 + U55 10 | 80 |
| OA0–16 (U19) | max(MA 95 + 18, OADISP 80 + S→Y 33) | 113 |
| FETCH (U48) | first PCLK edge ≥ ~AS + tsu, then tco | 82.1 |
| ~MCEn, drawing | MA0–2 95 + U56 15 | 110 |
| ~MCEn, display | FETCH 82.1 + U56 15 | 97.1 |
| MCYC ↑ | F2 + 40 | 165 |
| ~MOEn / ~OLOE | MCYC 165 + GAL 10 | 175 |
| ~MDENn | MCYC 165 + U58 15 | 180 |

## Display cycle

All eight frame-buffer banks and U19 are read together; GAI is 8, so one
fetch is 16 pixels.

- ~AS sets FETCH in U48. FETCH enables every ~MCEn and ~OLCE.
- MCYC high enables ~MOE0–7 and ~OLOE.
- The 74F245s stay off. Data goes straight into the 74F676s.
- PLOAD is high for the last PCLK of the data half. The 74F676s load on the
  falling PCLK edge in the middle of that PLOAD pulse. The earliest that edge
  can come is F2 − 5 (2CLK tco) + 7.5 × 15.625 + 1 (PCLK tpd) = 238.2 ns.

| Check | Available | Needed | 8 MHz margin | 8.125 MHz |
|---|---|---|---|---|
| Frame-buffer data → 74F676 setup. OE path: 175 + tDOE 22 = 197. Address path 140, CE path 142 | 235.2 | 197.0 | **+38.2** | +36.4 |
| Overlay data → U6 setup. OE path 197. Address path 113 + 45 = 158 | 235.2 | 197.0 | +38.2 | +36.4 |
| Data hold after CP ↓: FETCH clears on the edge after PLOAD, and ~MCE goes high ≥ 4.3 ns after the latest CP ↓. Assumes zero SRAM output hold | 4.3 | 4.0 | +0.3 | +0.2 |
| ~AS width vs FETCH capture: one PCLK + tsu | 30 | 20.6 | +9.4 | +9.6 |
| PLOAD (M) setup to CP ↓: half PCLK + PCLK tpd min − PLOAD tco max | 3.8 | 8.0 | **−4.2** | −4.3 |
| PLOAD (M) hold after CP ↓ | 1.3 | 2.0 | −0.7 | −0.8 |

The PLOAD rows pair U48's minimum tpd with its maximum tco. Both signals come
from the same die, so the two will track, and the real margins should be
positive. The 8 ns M setup is still the tightest thing in the pixel-clock
domain. Check it with a scope.

## Drawing cycle: read

MA0–2 select one bank (~MCEn, ~MOEn, ~MDENn in U56–U58), or U19 if CHR = 1
(~OLCE, ~OLOE, ~OLDEN in U55). ~MOE and ~MDEN are on only during the data
half. MDIR = 0 makes the buffers drive B → A.

| Check | Available | Needed | 8 MHz margin | 8.125 MHz |
|---|---|---|---|---|
| Frame-buffer data setup to F3: max(OE 197, CE 155, address 140) + F245 7 = 204. Buffer on at 180 + 9 = 189 | 210 | 204 | **+6.0** | +4.1 |
| Overlay data setup to F3: OE 197 + 7. ~OLDEN 175 + 9 | 210 | 204 | +6.0 | +4.1 |
| Data hold after F3: MCYC ↓ (minimum not specified, taken as 0) + GAL 3 + F245 off 1.2 | F3 + 4.2 | F3 + 10 | **−5.8** | −5.8 |

**This is the tightest guaranteed path on the board.** It adds up to 119 ns of
the 125 ns data half:

| Step | ns |
|---|---|
| MCYC delay | 40 |
| U57 GAL16V8-10 | 10 |
| SRAM tDOE | 22 |
| 74F245 | 7 |
| ACRTC read-data setup | 40 |

Fitting a GAL16V8-7 in U57 (and U55, for the overlay) adds 2.5 ns, for a
margin of +8.5 ns.

The hold row depends on MCYC's minimum delay, which the datasheet doesn't
give. When the buffers let go, MAD floats and its capacitance holds the data,
so the risk is low.

## Drawing cycle: write

~MWE = DRAW & !MRD & MCYC & TWOCLK (U55), so it is low from R2 to F3.
U11–U19 share it, and the chip enables pick the target. MDIR is set during
the address half, and ~MDENn or ~OLDEN turns on during the data half.

| Check | Available | Needed | 8 MHz margin | 8.125 MHz |
|---|---|---|---|---|
| MCYC settled before 2CLK ↑, so MCYC delay can't stretch ~MWE | 187.5 | 165 | +22.5 | +21.5 |
| ~MWE pulse width: 2CLK high minus U55's 3–10 ns delay spread | 55.5 | 35 | +20.5 | +19.5 |
| Write data setup to ~MWE ↑: max(F2 + 70 + 7, ~MDEN 189) = 202 vs ~MWE ↑ ≥ 253 − tSD 25 | 228 | 202 | +26.0 | +24.1 |
| Write data hold: ACRTC holds ≥ F3 + 10 (+1.7 through the F245) vs ~MWE ↑ ≤ F3 + 10 | F3 + 11.7 | F3 + 10 | +1.7 | +1.7 |
| Write data hold: ~MDEN drops when MCYC falls (minimum taken as 0) | F3 + 4.2 | F3 + 10 | **−5.8** | −5.8 |
| Address setup to ~MWE ↓ (tSA): overlay OA is the worst case | 190.5 | 113 | +77.5 | +74.6 |
| Address valid to write end (tAW) | 140 | 35 | +105 | +101 |
| CE to write end (tSCE) | 143 | 35 | +108 | +104 |
| MA16–19 hold after ~MWE ↑ (tHA 0): ACRTC F3 + 10 vs ~MWE ≤ F3 + 10 | F3 + 10 | F3 + 10 | 0 (+ LS244 minimum delay) | 0 |

Header comments in U55 already budget the ACRTC write-data hold (+1.7 ns with
the -10). They don't cover ~MDEN dropping on MCYC. As with the read hold, the
data is left on a floating SRAM-side bus while ~MWE is still low.

## Address latch hold

ALE closes U49/U50 at most 10 ns after ~AS rises (U55). The 74ALS573 needs
7 ns of hold. The ACRTC keeps the address on MAD until whichever comes later:
~AS ↑ + 10 (tMAH1) or F2 + 10 (tMAH2).

    margin = max(0, F2 − t(~AS ↑)) + 10 − 10 − 7

- The margin is positive when ~AS rises at least **7 ns before F2**, that is,
  by 118 ns at 8 MHz or 116.1 ns at 8.125 MHz.
- At the spec limit, ~AS rises at 65 + 62.5 = 127.5 ns, and the margin is
  **−7.0 ns**. A GAL16V8-7 in U55 improves this to −4.5 ns.
- The manual's figures show ~AS rising soon after 2CLK rises, about 60 ns
  before F2, so the real margin is probably large. Measure ~AS ↑ against
  2CLK ↓ on hardware.

## MAD bus contention (no timing failure)

- **Start of a drawing read.** A 74F245 can start driving MAD as early as
  F2 + 5.2 ns (MCYC minimum 0, GAL 3, F245 2.2). The ACRTC may keep driving
  its address until F2 + 50 (item 54).
- **End of a drawing read.** The buffers can stay on until
  F3 + 40 + 15 + 7.5 = F3 + 62.5. That overlaps the window in which the ACRTC
  drives the next address (valid ≤ 70 ns; the start isn't specified).
- **Effect on timing.** Even if the next address only becomes clean at
  F3 + 62.5, it reaches MA by 76.5 ns, inside the 95 ns budget above. The
  concern is driver stress, not timing.

## 2CLK

| Check | 8 MHz | 8.125 MHz |
|---|---|---|
| Period vs tcyc min 125 | 0 | **−1.9** (1.6% over the HD63484-8's 8 MHz maximum) |
| High/low width vs 55 min (U48 divider, 50% duty) | +7.5 | +6.5 |

## Summary

- Every setup and access path meets spec. The display fetch has +38 ns. The
  drawing read is the critical path, at +6.0 ns (+4.1 ns at 1024x768).
- Negative on paper:
  - address latch hold, −7.0 ns, only when ~AS rises at its spec limit;
  - read data hold and write data hold, −5.8 ns each, only if MCYC has zero
    delay;
  - PLOAD M setup/hold, −4.2 / −0.7 ns, a same-die corner.

  None of these is expected to fail in practice. Each depends on a minimum
  that is unspecified or tracks on the same die.
- Running 1024x768 from a 65 MHz pixel clock puts 2CLK 1.6% above the
  HD63484-8's rating.

## To measure on hardware

1. ~AS ↑ relative to 2CLK ↓ (F2): it must lead by at least 7 ns for the
   latch hold.
2. MCYC delay after 2CLK ↓, both edges. It sets the read-data setup margin
   and the two hold checks.
3. PLOAD vs PCLK at the 74F676 pins (8 ns M setup).
4. ~AS low width at the slowest PCLK, 25.175 MHz interleaved. FETCH capture
   needs one PCLK + 5 ns = 45 ns, against the ACRTC's 30 ns minimum (see the
   U48 header).
