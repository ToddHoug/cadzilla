# SN5485/SN54LS85/SN54S85, SN7485/SN74LS85/SN74S85 — 4-Bit Magnitude Comparators (Markdown Transcription)

Transcribed from `sn74ls85.pdf` (Texas Instruments SDLS123, March 1974, revised March 1988). Only datasheet pages 1–7 are included; the TI package addendum, packaging and mechanical pages (8–23) are left out. Each page was rendered to PNG and transcribed visually. Schematics and application circuits are described in text. Repeated headers and footers (title block, TI logo and address, production-data notice) have been removed, and the page numbers are kept. Two obvious typos in the scan are corrected and marked where they occur.

---

# SN5485, SN54LS85, SN54S85 / SN7485, SN74LS85, SN74S85 — 4-Bit Magnitude Comparators

*(source page 1)*

*SDLS123 – March 1974 – Revised March 1988*

| Type | Typical Power Dissipation | Typical Delay (4-Bit Words) |
|------|--------------------------:|----------------------------:|
| '85 | 275 mW | 23 ns |
| 'LS85 | 52 mW | 24 ns |
| 'S85 | 365 mW | 11 ns |

## description

These four-bit magnitude comparators perform comparison of straight binary and straight BCD (8-4-2-1) codes. Three fully decoded decisions about two 4-bit words (A, B) are made and are externally available at three outputs. These devices are fully expandable to any number of bits without external gates. Words of greater length may be compared by connecting comparators in cascade. The A > B, A < B, and A = B outputs of a stage handling less-significant bits are connected to the corresponding A > B, A < B, and A = B inputs of the next stage handling more-significant bits. The stage handling the least-significant bits must have a high-level voltage applied to the A = B input. The cascading paths of the '85, 'LS85, and 'S85 are implemented with only a two-gate-level delay to reduce overall comparison times for long words. An alternate method of cascading which further reduces the comparison time is shown in the typical application data.

## Pinouts

**SN5485, SN54LS85, SN54S85 . . . J or W package; SN7485 . . . N package; SN74LS85, SN74S85 . . . D or N package (top view)**

| Pin | Name | | Pin | Name |
|----:|------|-|----:|------|
| 1 | B3 | | 16 | V<sub>CC</sub> |
| 2 | A< Bin | | 15 | A3 |
| 3 | A= Bin | | 14 | B2 |
| 4 | A> Bin | | 13 | A2 |
| 5 | A> Bout | | 12 | A1 |
| 6 | A= Bout | | 11 | B1 |
| 7 | A< Bout | | 10 | A0 |
| 8 | GND | | 9 | B0 |

**SN54LS85, SN54S85 . . . FK package (top view)**

| Pin | Name | Pin | Name | Pin | Name | Pin | Name |
|----:|------|----:|------|----:|------|----:|------|
| 1 | NC | 6 | NC | 11 | NC | 16 | NC |
| 2 | B3 | 7 | A> Bout | 12 | B0 | 17 | A2 |
| 3 | A< Bin | 8 | A= Bout | 13 | A0 | 18 | B2 |
| 4 | A= Bin | 9 | A< Bout | 14 | B1 | 19 | A3 |
| 5 | A> Bin | 10 | GND | 15 | A1 | 20 | V<sub>CC</sub> |

NC – No internal connection

## FUNCTION TABLE

| A3, B3 | A2, B2 | A1, B1 | A0, B0 | In A > B | In A < B | In A = B | Out A > B | Out A < B | Out A = B |
|--------|--------|--------|--------|:-:|:-:|:-:|:-:|:-:|:-:|
| A3 > B3 | X | X | X | X | X | X | H | L | L |
| A3 < B3 | X | X | X | X | X | X | L | H | L |
| A3 = B3 | A2 > B2 | X | X | X | X | X | H | L | L |
| A3 = B3 | A2 < B2 | X | X | X | X | X | L | H | L |
| A3 = B3 | A2 = B2 | A1 > B1 | X | X | X | X | H | L | L |
| A3 = B3 | A2 = B2 | A1 < B1 | X | X | X | X | L | H | L |
| A3 = B3 | A2 = B2 | A1 = B1 | A0 > B0 | X | X | X | H | L | L |
| A3 = B3 | A2 = B2 | A1 = B1 | A0 < B0 | X | X | X | L | H | L |
| A3 = B3 | A2 = B2 | A1 = B1 | A0 = B0 | H | L | L | H | L | L |
| A3 = B3 | A2 = B2 | A1 = B1 | A0 = B0 | L | H | L | L | H | L |
| A3 = B3 | A2 = B2 | A1 = B1 | A0 = B0 | X | X | H | L | L | H |
| A3 = B3 | A2 = B2 | A1 = B1 | A0 = B0 | H | H | L | L | L | L |
| A3 = B3 | A2 = B2 | A1 = B1 | A0 = B0 | L | L | L | H | H | L |

*(Transcription note: the scan prints "A3 = B2" in row 5 and "A2 = B3" in row 7; these are typos in the original and are shown here as A3 = B3.)*

**Page 1**

---

# Logic Diagram and Logic Symbol

*(source page 2)*

## logic diagrams (positive logic)

*(Gate-level schematic described in text. Pin numbers in parentheses.)*

- **Bit comparators:** each bit pair — A3 (15)/B3 (1), A2 (13)/B2 (14), A1 (12)/B1 (11), A0 (10)/B0 (9) — feeds a 2-input NAND gate. The NAND output and the two inputs feed a pair of 2-input AND gates whose outputs go to a NOR gate. For each bit this produces an "equal" term (from the NOR) and the gated A-greater / B-greater terms.
- **Cascade inputs:** A < B (2), A = B (3), A > B (4).
- **A > B output (5):** a 5-input NOR-type output gate (drawn as an AND with inverted inputs) whose inputs are 5 AND gates. They decode "A3 > B3", "A3 = B3 and A2 > B2", "A3 = B3, A2 = B2 and A1 > B1", "A3–A1 equal and A0 > B0", and "all bits equal and cascade input A > B (with A = B low)".
- **A = B output (6):** a single AND gate combining the four per-bit "equal" signals with the A = B cascade input.
- **A < B output (7):** mirrors the A > B structure — 5 AND gates feeding a NOR-type output gate, using the B-greater terms and the A < B cascade input.
- There are two cascade paths from the inputs to the outputs, each two gate levels deep.

## logic symbol†

*(ANSI/IEEE block symbol "COMP", described in text.)*

| Input | Pin | Function in symbol | | Output | Pin |
|-------|----:|--------------------|-|--------|----:|
| P0 | 10 | P word bit 0 | | P<Q | 7 |
| P1 | 12 | P word bit 1 | | P=Q | 6 |
| P2 | 13 | P word bit 2 | | P>Q | 5 |
| P3 | 15 | P word bit 3 | | | |
| P<Q | 2 | cascade "<" input | | | |
| P=Q | 3 | cascade "=" input | | | |
| P>Q | 4 | cascade ">" input | | | |
| Q0 | 9 | Q word bit 0 | | | |
| Q1 | 11 | Q word bit 1 | | | |
| Q2 | 14 | Q word bit 2 | | | |
| Q3 | 1 | Q word bit 3 | | | |

(P corresponds to the A word and Q to the B word.)

† This symbol is in accordance with ANSI/IEEE Std 91-1984 and IEC Publication 617-12.

Pin numbers shown are for D, J, N, and W packages.

**Page 2**

---

# Schematics of Inputs and Outputs; Absolute Maximum Ratings

*(source page 3)*

## schematics of inputs and outputs

*(Transistor-level equivalent circuits described in text.)*

| Circuit | Description |
|---------|-------------|
| **Equivalent of each input for '85** | Multi-emitter input transistor: V<sub>CC</sub> through R<sub>eq</sub> to the base; INPUT to an emitter; input clamp diode to ground. **A = B, any A or B:** R<sub>eq</sub> = 1.67 kΩ NOM. **A > B, A < B:** R<sub>eq</sub> = 4 kΩ NOM. |
| **Equivalent of each input for 'LS85** | Schottky-diode input: V<sub>CC</sub> through R<sub>eq</sub> = 17 kΩ to the internal node; INPUT connects through a Schottky diode to that node, with a Schottky clamp diode to ground; two series diodes from the internal node to ground. |
| **Equivalent of each input for 'S85** | Schottky-clamped multi-emitter input transistor with R<sub>eq</sub> from V<sub>CC</sub>, Schottky input clamp diode to ground. **A = B, any A or B:** R<sub>eq</sub> = 933 Ω NOM. **A > B, A < B:** R<sub>eq</sub> = 2.8 kΩ NOM. |
| **Typical of all outputs for '85** | Standard TTL totem-pole: 100 Ω NOM collector resistor from V<sub>CC</sub>, upper transistor and series diode to OUTPUT, lower transistor from OUTPUT to ground. |
| **Typical of all outputs for 'LS85** | Schottky Darlington pull-up with 120 Ω NOM resistor from V<sub>CC</sub>; Schottky pull-down transistor with active (squaring) base network to ground. |
| **Typical of all outputs for 'S85** | Schottky Darlington pull-up with 50 Ω NOM resistor from V<sub>CC</sub>; Schottky pull-down transistor with active base network to ground. |

## absolute maximum ratings over operating free-air temperature range (unless otherwise noted)

| | SN54', SN54S' | SN54LS' | SN74', SN74S' | SN74LS' | UNIT |
|---|:--:|:--:|:--:|:--:|:--:|
| Supply voltage, V<sub>CC</sub> (see Note 1) | 7 | 7 | 7 | 7 | V |
| Input voltage | 5.5 | 7 | 5.5 | 7 | V |
| Interemitter voltage (see Note 2) | 5.5 | | 5.5 | | V |
| Operating free-air temperature range | –55 to 125 (SN54 family) | | 0 to 70 (SN74 family) | | °C |
| Storage temperature range | –65 to 150 | | –65 to 150 | | °C |

NOTES:
1. Voltage values, except interemitter voltage, are with respect to network ground terminal.
2. This is the voltage between two emitters of a multiple-emitter input transistor. This rating applies to each A input in conjunction with its respective B input of the '85 and 'S85.

**Page 3**

---

# SN5485, SN7485 — Operating Conditions and Characteristics

*(source page 4)*

## recommended operating conditions

| | SN5485 MIN | SN5485 NOM | SN5485 MAX | SN7485 MIN | SN7485 NOM | SN7485 MAX | UNIT |
|---|---:|---:|---:|---:|---:|---:|:--:|
| Supply voltage, V<sub>CC</sub> | 4.5 | 5 | 5.5 | 4.75 | 5 | 5.25 | V |
| High-level output current, I<sub>OH</sub> | | | –400 | | | –400 | µA |
| Low-level output current, I<sub>OL</sub> | | | 16 | | | 16 | mA |
| Operating free-air temperature, T<sub>A</sub> | –55 | | 125 | 0 | | 70 | °C |

## electrical characteristics over recommended operating free-air temperature range (unless otherwise noted)

| Parameter | | Test Conditions† | MIN | TYP‡ | MAX | UNIT |
|-----------|---|------------------|---:|---:|---:|:--:|
| V<sub>IH</sub> | High-level input voltage | | 2 | | | V |
| V<sub>IL</sub> | Low-level input voltage | | | | 0.8 | V |
| V<sub>IK</sub> | Input clamp voltage | V<sub>CC</sub> = MIN, I<sub>I</sub> = –12 mA | | | –1.5 | V |
| V<sub>OH</sub> | High-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OH</sub> = –400 µA | 2.4 | 3.4 | | V |
| V<sub>OL</sub> | Low-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OL</sub> = 16 mA | | 0.2 | 0.4 | V |
| I<sub>I</sub> | Input current at maximum input voltage | V<sub>CC</sub> = MAX, V<sub>I</sub> = 5.5 V | | | 1 | mA |
| I<sub>IH</sub> | High-level input current — A < B, A > B inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.4 V | | | 40 | µA |
| I<sub>IH</sub> | High-level input current — all other inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.4 V | | | 120 | µA |
| I<sub>IL</sub> | Low-level input current — A < B, A > B inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.4 V | | | –1.6 | mA |
| I<sub>IL</sub> | Low-level input current — all other inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.4 V | | | –4.8 | mA |
| I<sub>OS</sub> | Short-circuit output current§ — SN5485 | V<sub>CC</sub> = MAX, V<sub>O</sub> = 0 | –20 | | –55 | mA |
| I<sub>OS</sub> | Short-circuit output current§ — SN7485 | V<sub>CC</sub> = MAX, V<sub>O</sub> = 0 | –18 | | –55 | mA |
| I<sub>CC</sub> | Supply current | V<sub>CC</sub> = MAX, See Note 4 | | 55 | 88 | mA |

† For conditions shown as MIN or MAX, use the appropriate value specified under recommended operating conditions.
‡ All typical values are at V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C.
§ Not more than one output should be shorted at a time.
NOTE 4: I<sub>CC</sub> is measured with outputs open, A = B grounded, and all other inputs at 4.5 V.

## switching characteristics, V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C

Test conditions for all rows: C<sub>L</sub> = 15 pF, R<sub>L</sub> = 400 Ω, See Note 5.

| Parameter¶ | From (Input) | To (Output) | Number of Gate Levels | MIN | TYP | MAX | UNIT |
|------------|--------------|-------------|:--:|---:|---:|---:|:--:|
| t<sub>PLH</sub> | Any A or B data input | A < B, A > B | 1 | | 7 | | ns |
| | | A < B, A > B | 2 | | 12 | | ns |
| | | A < B, A > B | 3 | | 17 | 26 | ns |
| | | A = B | 4 | | 23 | 35 | ns |
| t<sub>PHL</sub> | Any A or B data input | A < B, A > B | 1 | | 11 | | ns |
| | | A < B, A > B | 2 | | 15 | | ns |
| | | A < B, A > B | 3 | | 20 | 30 | ns |
| | | A = B | 4 | | 20 | 30 | ns |
| t<sub>PLH</sub> | A < B or A = B | A > B | 1 | | 7 | 11 | ns |
| t<sub>PHL</sub> | A < B or A = B | A > B | 1 | | 11 | 17 | ns |
| t<sub>PLH</sub> | A = B | A = B | 2 | | 13 | 20 | ns |
| t<sub>PHL</sub> | A = B | A = B | 2 | | 11 | 17 | ns |
| t<sub>PLH</sub> | A > B or A = B | A < B | 1 | | 7 | 11 | ns |
| t<sub>PHL</sub> | A > B or A = B | A < B | 1 | | 11 | 17 | ns |

¶ t<sub>PLH</sub> = propagation delay time, low-to-high-level output; t<sub>PHL</sub> = propagation delay time, high-to-low-level output.
NOTE 5: Load circuits and voltage waveforms are shown in Section 1.

**Page 4**

---

# SN54LS85, SN74LS85 — Operating Conditions and Characteristics

*(source page 5)*

## recommended operating conditions

| | SN54LS85 MIN | SN54LS85 NOM | SN54LS85 MAX | SN74LS85 MIN | SN74LS85 NOM | SN74LS85 MAX | UNIT |
|---|---:|---:|---:|---:|---:|---:|:--:|
| Supply voltage, V<sub>CC</sub> | 4.5 | 5 | 5.5 | 4.75 | 5 | 5.25 | V |
| High-level output current, I<sub>OH</sub> | | | –400 | | | –400 | µA |
| Low-level output current, I<sub>OL</sub> | | | 4 | | | 8 | mA |
| Operating free-air temperature, T<sub>A</sub> | –55 | | 125 | 0 | | 70 | °C |

## electrical characteristics over recommended operating free-air temperature range (unless otherwise noted)

| Parameter | | Test Conditions† | 54LS MIN | 54LS TYP‡ | 54LS MAX | 74LS MIN | 74LS TYP‡ | 74LS MAX | UNIT |
|-----------|---|------------------|---:|---:|---:|---:|---:|---:|:--:|
| V<sub>IH</sub> | High-level input voltage | | 2 | | | 2 | | | V |
| V<sub>IL</sub> | Low-level input voltage | | | | 0.7 | | | 0.7 | V |
| V<sub>IK</sub> | Input clamp voltage | V<sub>CC</sub> = MIN, I<sub>I</sub> = –18 mA | | | –1.5 | | | –1.5 | V |
| V<sub>OH</sub> | High-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = V<sub>IL</sub> max, I<sub>OH</sub> = –400 µA | 2.5 | 3.4 | | 2.7 | 3.4 | | V |
| V<sub>OL</sub> | Low-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = V<sub>IL</sub> max, I<sub>OL</sub> = 4 mA | | 0.25 | 0.4 | | 0.25 | 0.4 | V |
| V<sub>OL</sub> | Low-level output voltage | same, I<sub>OL</sub> = 8 mA | | | | | 0.35 | 0.5 | V |
| I<sub>I</sub> | Input current at maximum input voltage — A < B, A > B inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 7 V | | | 0.1 | | | 0.1 | mA |
| I<sub>I</sub> | Input current at maximum input voltage — all other inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 7 V | | | 0.3 | | | 0.3 | mA |
| I<sub>IH</sub> | High-level input current — A < B, A > B inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.7 V | | | 20 | | | 20 | µA |
| I<sub>IH</sub> | High-level input current — all other inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.7 V | | | 60 | | | 60 | µA |
| I<sub>IL</sub> | Low-level input current — A < B, A > B inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.4 V | | | –0.4 | | | –0.4 | mA |
| I<sub>IL</sub> | Low-level input current — all other inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.4 V | | | –1.2 | | | –1.2 | mA |
| I<sub>OS</sub> | Short-circuit output current§ | V<sub>CC</sub> = MAX | –20 | | –100 | –20 | | –100 | mA |
| I<sub>CC</sub> | Supply current | V<sub>CC</sub> = MAX, See Note 4 | | 10.4 | 20 | | 10.4 | 20 | mA |

† For conditions shown as MIN or MAX, use the appropriate value specified under recommended operating conditions.
‡ All typical values are at V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C.
§ Not more than one output should be shorted at a time, and duration of the short-circuit should not exceed one second.
NOTE 4: I<sub>CC</sub> is measured with outputs open, A = B grounded, and all other inputs at 4.5 V.

## switching characteristics, V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C

Test conditions for all rows: C<sub>L</sub> = 15 pF, R<sub>L</sub> = 2 kΩ, See Note 5.

| Parameter¶ | From (Input) | To (Output) | Number of Gate Levels | MIN | TYP | MAX | UNIT |
|------------|--------------|-------------|:--:|---:|---:|---:|:--:|
| t<sub>PLH</sub> | Any A or B data input | A < B, A > B | 1 | | 14 | | ns |
| | | A < B, A > B | 2 | | 19 | | ns |
| | | A < B, A > B | 3 | | 24 | 36 | ns |
| | | A = B | 4 | | 27 | 45 | ns |
| t<sub>PHL</sub> | Any A or B data input | A < B, A > B | 1 | | 11 | | ns |
| | | A < B, A > B | 2 | | 15 | | ns |
| | | A < B, A > B | 3 | | 20 | 30 | ns |
| | | A = B | 4 | | 23 | 45 | ns |
| t<sub>PLH</sub> | A < B or A = B | A > B | 1 | | 14 | 22 | ns |
| t<sub>PHL</sub> | A < B or A = B | A > B | 1 | | 11 | 17 | ns |
| t<sub>PLH</sub> | A = B | A = B | 2 | | 13 | 20 | ns |
| t<sub>PHL</sub> | A = B | A = B | 2 | | 13 | 26 | ns |
| t<sub>PLH</sub> | A > B or A = B | A < B | 1 | | 14 | 22 | ns |
| t<sub>PHL</sub> | A > B or A = B | A < B | 1 | | 11 | 17 | ns |

¶ t<sub>PLH</sub> = propagation delay time, low-to-high-level output; t<sub>PHL</sub> = propagation delay time, high-to-low-level output.
NOTE 5: Load circuits and voltage waveforms are shown in Section 1.

**Page 5**

---

# SN54S85, SN74S85 — Operating Conditions and Characteristics

*(source page 6)*

## recommended operating conditions

| | SN54S85 MIN | SN54S85 NOM | SN54S85 MAX | SN74S85 MIN | SN74S85 NOM | SN74S85 MAX | UNIT |
|---|---:|---:|---:|---:|---:|---:|:--:|
| Supply voltage, V<sub>CC</sub> | 4.5 | 5 | 5.5 | 4.75 | 5 | 5.25 | V |
| High-level output current, I<sub>OH</sub> | | | –1 | | | –1 | mA |
| Low-level output current, I<sub>OL</sub> | | | 20 | | | 20 | mA |
| Operating free-air temperature, T<sub>A</sub> | –55 | | 125 | 0 | | 70 | °C |

## electrical characteristics over recommended operating free-air temperature range (unless otherwise noted)

| Parameter | | Test Conditions† | MIN | TYP‡ | MAX | UNIT |
|-----------|---|------------------|---:|---:|---:|:--:|
| V<sub>IH</sub> | High-level input voltage | | 2 | | | V |
| V<sub>IL</sub> | Low-level input voltage | | | | 0.8 | V |
| V<sub>IK</sub> | Input clamp voltage | V<sub>CC</sub> = MIN, I<sub>I</sub> = –18 mA | | | –1.2 | V |
| V<sub>OH</sub> | High-level output voltage — SN54S85 | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OH</sub> = –1 mA | 2.5 | 3.4 | | V |
| V<sub>OH</sub> | High-level output voltage — SN74S85 | same | 2.7 | 3.4 | | V |
| V<sub>OL</sub> | Low-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OL</sub> = 20 mA | | | 0.5 | V |
| I<sub>I</sub> | Input current at maximum input voltage | V<sub>CC</sub> = MAX, V<sub>I</sub> = 5.5 V | | | 1 | mA |
| I<sub>IH</sub> | High-level input current — A < B, A > B inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.7 V | | | 50 | µA |
| I<sub>IH</sub> | High-level input current — all other inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.7 V | | | 150 | µA |
| I<sub>IL</sub> | Low-level input current — A < B, A > B inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.5 V | | | –2 | mA |
| I<sub>IL</sub> | Low-level input current — all other inputs | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.5 V | | | –6 | mA |
| I<sub>OS</sub> | Short-circuit output current§ | V<sub>CC</sub> = MAX | –40 | | –100 | mA |
| I<sub>CC</sub> | Supply current | V<sub>CC</sub> = MAX, See Note 4 | | 73 | 115 | mA |
| I<sub>CC</sub> | Supply current — SN54S85W | V<sub>CC</sub> = MAX, T<sub>A</sub> = 125°C, See Note 4 | | | 110 | mA |

† For conditions shown as MIN or MAX, use the appropriate value specified under recommended operating conditions.
‡ All typical values are at V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C.
§ Not more than one output should be shorted at a time, and duration of the short-circuit should not exceed one second.
NOTE 4: I<sub>CC</sub> is measured with outputs open, A = B grounded, and all other inputs at 4.5 V.

## switching characteristics, V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C

Test conditions for all rows: C<sub>L</sub> = 15 pF, R<sub>L</sub> = 280 Ω, See Note 5.

| Parameter¶ | From (Input) | To (Output) | Number of Gate Levels | MIN | TYP | MAX | UNIT |
|------------|--------------|-------------|:--:|---:|---:|---:|:--:|
| t<sub>PLH</sub> | Any A or B data input | A < B, A > B | 1 | | 5 | | ns |
| | | A < B, A > B | 2 | | 7.5 | | ns |
| | | A < B, A > B | 3 | | 10.5 | 16 | ns |
| | | A = B | 4 | | 12 | 18 | ns |
| t<sub>PHL</sub> | Any A or B data input | A < B, A > B | 1 | | 5.5 | | ns |
| | | A < B, A > B | 2 | | 7 | | ns |
| | | A < B, A > B | 3 | | 11 | 16.5 | ns |
| | | A = B | 4 | | 11 | 16.5 | ns |
| t<sub>PLH</sub> | A < B or A = B | A > B | 1 | | 5 | 7.5 | ns |
| t<sub>PHL</sub> | A < B or A = B | A > B | 1 | | 5.5 | 8.5 | ns |
| t<sub>PLH</sub> | A = B | A = B | 2 | | 7 | 10.5 | ns |
| t<sub>PHL</sub> | A = B | A = B | 2 | | 5 | 7.5 | ns |
| t<sub>PLH</sub> | A > B or A = B | A < B | 1 | | 5 | 7.5 | ns |
| t<sub>PHL</sub> | A > B or A = B | A < B | 1 | | 5.5 | 8.5 | ns |

¶ t<sub>PLH</sub> = propagation delay time, low-to-high-level output; t<sub>PHL</sub> = propagation delay time, high-to-low-level output.
NOTE 5: Load circuits and voltage waveforms are shown in Section 1.

**Page 6**

---

# Typical Application Data

*(source page 7)*

## COMPARISON OF TWO N-BIT WORDS

This application demonstrates how these magnitude comparators can be cascaded to compare longer words. The example illustrated shows the comparison of two 24-bit words; however, the design is expandable to n-bits. As an example, one comparator can be used with five of the 24-bit comparators illustrated to expand the word length to 120-bits. Typical comparison times for various word lengths using the '85, 'LS85, or 'S85 are:

| Word Length | Number of Pkgs | '85 | 'LS85 | 'S85 |
|-------------|:--------------:|----:|------:|-----:|
| 1-4 bits | 1 | 23 ns | 24 ns | 11 ns |
| 5-24 bits | 2-6 | 46 ns | 48 ns | 22 ns |
| 25-120 bits | 8-31 | 69 ns | 72 ns | 33 ns |

### Figure: Comparison of Two 24-Bit Words

*(Circuit diagram described in text.)*

Six '85/'LS85/'S85 comparators are used: five in a first rank and one final comparator.

**First rank:** each device compares 4 bits of each word on its A3–A0/B3–A0 inputs. The fifth input bit pair of each group goes into the cascade inputs, so each device handles 5 bits:

| Device | B3/A3 | B2/A2 | B1/A1 | B0/A0 | A < B input | A = B input | A > B input |
|--------|-------|-------|-------|-------|-------------|-------------|-------------|
| 1 (MSB) | B23/A23 | B22/A22 | B21/A21 | B20/A20 | B19 | L | A19 |
| 2 | B18/A18 | B17/A17 | B16/A16 | B15/A15 | B14 | L | A14 |
| 3 | B13/A13 | B12/A12 | B11/A11 | B10/A10 | B9 | L | A9 |
| 4 | B8/A8 | B7/A7 | B6/A6 | B5/A5 | B4 | L | A4 |
| 5 (LSB) | B3/A3 | B2/A2 | B1/A1 | B0/A0 | L | H | L |

On devices 1–4 the A = B output is not connected (NC). On all five devices the **A < B** and **A > B** outputs feed the final comparator.

**Final comparator:** the A < B / A > B outputs of devices 1–4 drive its B3/A3, B2/A2, B1/A1 and B0/A0 inputs respectively (A < B → B input, A > B → A input). Device 5's A < B, A = B and A > B outputs drive its cascade inputs A < B, A = B and A > B. Its A < B, A = B and A > B outputs are the final **OUTPUTS**.

*(Transcription note: the second device in the scan is labeled "B1, A0, B0, A0"; the first "A0" is a typo for A1.)*

**Page 7**
