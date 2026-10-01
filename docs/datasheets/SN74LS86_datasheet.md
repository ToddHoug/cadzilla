# SN5486/SN54LS86A/SN54S86, SN7486/SN74LS86A/SN74S86 — Quadruple 2-Input Exclusive-OR Gates (Markdown Transcription)

Transcribed from `sn74ls86.pdf` (Texas Instruments SDLS124, December 1972, revised March 1988). Only datasheet pages 1–5 are included; the TI package addendum, packaging and mechanical pages (6–17) are left out. Each page was rendered to PNG and transcribed visually. Schematics and logic symbols are described in text or turned into tables. Repeated headers and footers (title block, TI logo and address, production-data notice) have been removed, and the page numbers are kept.

---

# SN5486, SN54LS86A, SN54S86 / SN7486, SN74LS86A, SN74S86 — Quadruple 2-Input Exclusive-OR Gates

*(source page 1)*

*SDLS124 – December 1972 – Revised March 1988*

- Package Options Include Plastic "Small Outline" Packages, Ceramic Chip Carriers and Flat Packages, and Standard Plastic and Ceramic 300-mil DIPs
- Dependable Texas Instruments Quality and Reliability

| Type | Typical Average Propagation Delay Time | Typical Total Power Dissipation |
|------|---------------------------------------:|--------------------------------:|
| '86 | 14 ns | 150 mW |
| 'LS86A | 10 ns | 30.5 mW |
| 'S86 | 7 ns | 250 mW |

## description

These devices contain four independent 2-input Exclusive-OR gates. They perform the Boolean functions Y = A ⊕ B = A̅B + AB̅ in positive logic.

A common application is as a true/complement element. If one of the inputs is low, the other input will be reproduced in true form at the output. If one of the inputs is high, the signal on the other input will be reproduced inverted at the output.

The SN5486, 54LS86A, and the SN54S86 are characterized for operation over the full military temperature range of –55°C to 125°C. The SN7486, SN74LS86A, and the SN74S86 are characterized for operation from 0°C to 70°C.

## Pinouts

**SN5486, SN54LS86A, SN54S86 . . . J or W package; SN7486 . . . N package; SN74LS86A, SN74S86 . . . D or N package (top view)**

| Pin | Name | | Pin | Name |
|----:|------|-|----:|------|
| 1 | 1A | | 14 | V<sub>CC</sub> |
| 2 | 1B | | 13 | 4B |
| 3 | 1Y | | 12 | 4A |
| 4 | 2A | | 11 | 4Y |
| 5 | 2B | | 10 | 3B |
| 6 | 2Y | | 9 | 3A |
| 7 | GND | | 8 | 3Y |

**SN54LS86A, SN54S86 . . . FK package (top view)**

| Pin | Name | Pin | Name | Pin | Name | Pin | Name |
|----:|------|----:|------|----:|------|----:|------|
| 1 | NC | 6 | 2A | 11 | NC | 16 | 4Y |
| 2 | 1A | 7 | NC | 12 | 3Y | 17 | NC |
| 3 | 1B | 8 | 2B | 13 | 3A | 18 | 4A |
| 4 | 1Y | 9 | 2Y | 14 | 3B | 19 | 4B |
| 5 | NC | 10 | GND | 15 | NC | 20 | V<sub>CC</sub> |

NC – No internal connection

## exclusive-OR logic

An exclusive-OR gate has many applications, some of which can be represented better by alternative logic symbols.

**EXCLUSIVE-OR:** *(five equivalent symbols are drawn: the IEC "=1" rectangular block, the distinctive-shape XOR gate, and three distinctive-shape XOR gates with inversion bubbles on two of the ports.)*

These are five equivalent Exclusive-OR symbols valid for an '86 or 'LS86A gate in positive logic; negation may be shown at any two ports.

| Symbol | Qualifier | Meaning |
|--------|-----------|---------|
| **Logic identity element** | "=" (with active-low output indicator) | The output is active (low) if all inputs stand at the same logic level (i.e., A = B). |
| **Even-parity element** | "2k" (with active-low output indicator) | The output is active (low) if an even number of inputs (i.e., 0 or 2) are active. |
| **Odd-parity element** | "2k+1" | The output is active (high) if an odd number of inputs (i.e., only 1 of the 2) are active. |

**Page 1**

---

# Schematics, Logic Symbol, and Function Table

*(source page 2)*

## schematics of inputs and outputs

*(Transistor-level equivalent circuits described in text.)*

| Device | Equivalent of each input | Typical of all outputs |
|--------|--------------------------|------------------------|
| **'86** | Multi-emitter input transistor, base pulled to V<sub>CC</sub> through 4 kΩ NOM; clamp diode from INPUT to ground. | Standard TTL totem-pole: 130 Ω NOM collector resistor from V<sub>CC</sub>, upper transistor plus series diode to OUTPUT, lower transistor to ground. |
| **'LS86A** | Schottky-diode input: 12.5 kΩ NOM pull-up from V<sub>CC</sub>; INPUT connects through a Schottky diode, with a Schottky clamp diode to ground. | Schottky Darlington pull-up with 150 Ω NOM resistor from V<sub>CC</sub>; Schottky pull-down transistor with active base network to ground. |
| **'S86** | Schottky-clamped multi-emitter input transistor, 2.8 kΩ NOM pull-up from V<sub>CC</sub>; Schottky clamp diode to ground. | Schottky Darlington pull-up with 50 Ω NOM resistor from V<sub>CC</sub>; Schottky pull-down transistor with active base network to ground. |

## logic symbol†

*(IEC block symbol: four "=1" XOR elements stacked.)*

| Gate | Input A (pin) | Input B (pin) | Output Y (pin) |
|------|:-:|:-:|:-:|
| 1 | 1A (1) | 1B (2) | 1Y (3) |
| 2 | 2A (4) | 2B (5) | 2Y (6) |
| 3 | 3A (9) | 3B (10) | 3Y (8) |
| 4 | 4A (12) | 4B (13) | 4Y (11) |

† This symbol is in accordance with ANSI/IEEE Std. 91-1984 and IEC Publication 617-12.
Pin numbers shown are for D, J, N, and W packages.

## FUNCTION TABLE

| A | B | Y |
|:-:|:-:|:-:|
| L | L | L |
| L | H | H |
| H | L | H |
| H | H | L |

H = high level, L = low level

**Page 2**

---

# SN5486, SN7486 — Ratings, Operating Conditions and Characteristics

*(source page 3)*

## absolute maximum ratings over operating free-air temperature range (unless otherwise noted)

| Rating | Value |
|--------|-------|
| Supply voltage, V<sub>CC</sub> (see Note 1) | 7 V |
| Input voltage | 5.5 V |
| Operating free-air temperature range: SN5486 | –55°C to 125°C |
| Operating free-air temperature range: SN7486 | 0°C to 70°C |
| Storage temperature range | –65°C to 150°C |

NOTE 1: Voltage values are with respect to network ground terminal.

## recommended operating conditions

| | SN5486 MIN | SN5486 NOM | SN5486 MAX | SN7486 MIN | SN7486 NOM | SN7486 MAX | UNIT |
|---|---:|---:|---:|---:|---:|---:|:--:|
| Supply voltage, V<sub>CC</sub> | 4.5 | 5 | 5.5 | 4.75 | 5 | 5.25 | V |
| High-level output current, I<sub>OH</sub> | | | –800 | | | –800 | µA |
| Low-level output current, I<sub>OL</sub> | | | 16 | | | 16 | mA |
| Operating free-air temperature, T<sub>A</sub> | –55 | | 125 | 0 | | 70 | °C |

## electrical characteristics over recommended operating free-air temperature range (unless otherwise noted)

| Parameter | | Test Conditions† | 5486 MIN | 5486 TYP‡ | 5486 MAX | 7486 MIN | 7486 TYP‡ | 7486 MAX | UNIT |
|-----------|---|------------------|---:|---:|---:|---:|---:|---:|:--:|
| V<sub>IH</sub> | High-level input voltage | | 2 | | | 2 | | | V |
| V<sub>IL</sub> | Low-level input voltage | | | | 0.8 | | | 0.8 | V |
| V<sub>IK</sub> | Input clamp voltage | V<sub>CC</sub> = MIN, I<sub>I</sub> = –8 mA | | | –1.5 | | | –1.5 | V |
| V<sub>OH</sub> | High-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OH</sub> = –800 µA | 2.4 | 3.4 | | 2.4 | 3.4 | | V |
| V<sub>OL</sub> | Low-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OL</sub> = 16 mA | | 0.2 | 0.4 | | 0.2 | 0.4 | V |
| I<sub>I</sub> | Input current at maximum input voltage | V<sub>CC</sub> = MAX, V<sub>I</sub> = 5.5 V | | | 1 | | | 1 | mA |
| I<sub>IH</sub> | High-level input current | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.4 V | | | 40 | | | 40 | µA |
| I<sub>IL</sub> | Low-level input current | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.4 V | | | –1.6 | | | –1.6 | mA |
| I<sub>OS</sub> | Short-circuit output current§ | V<sub>CC</sub> = MAX | –20 | | –55 | –18 | | –55 | mA |
| I<sub>CC</sub> | Supply current | V<sub>CC</sub> = MAX, See Note 2 | | 30 | 43 | | 30 | 50 | mA |

† For conditions shown as MIN or MAX, use the appropriate value specified under recommended operating conditions for the applicable type.
‡ All typical values are at V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C.
§ Not more than one output should be shorted at a time.
NOTE 2: I<sub>CC</sub> is measured with the inputs grounded and the outputs open.

## switching characteristics, V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C

Load for all rows: C<sub>L</sub> = 15 pF, R<sub>L</sub> = 400 Ω, See Note 3.

| Parameter¶ | From (Input) | Test Conditions | MIN | TYP | MAX | UNIT |
|------------|:------------:|-----------------|---:|---:|---:|:--:|
| t<sub>PLH</sub> | A or B | Other input low | | 15 | 23 | ns |
| t<sub>PHL</sub> | A or B | Other input low | | 11 | 17 | ns |
| t<sub>PLH</sub> | A or B | Other input high | | 18 | 30 | ns |
| t<sub>PHL</sub> | A or B | Other input high | | 13 | 22 | ns |

¶ t<sub>PLH</sub> = propagation delay time, low-to-high-level output; t<sub>PHL</sub> = propagation delay time, high-to-low-level output.
NOTE 3: Load circuits and voltage waveforms are shown in Section 1.

**Page 3**

---

# SN54LS86A, SN74LS86A — Ratings, Operating Conditions and Characteristics

*(source page 4)*

## absolute maximum ratings over operating free-air temperature range (unless otherwise noted)

| Rating | Value |
|--------|-------|
| Supply voltage, V<sub>CC</sub> (see Note 1) | 7 V |
| Input voltage | 7 V |
| Operating free-air temperature range: SN54LS86A | –55°C to 125°C |
| Operating free-air temperature range: SN74LS86A | 0°C to 70°C |
| Storage temperature range | –65°C to 150°C |

NOTE 1: Voltage values are with respect to network ground terminal.

## recommended operating conditions

| | SN54LS86A MIN | SN54LS86A NOM | SN54LS86A MAX | SN74LS86A MIN | SN74LS86A NOM | SN74LS86A MAX | UNIT |
|---|---:|---:|---:|---:|---:|---:|:--:|
| Supply voltage, V<sub>CC</sub> | 4.5 | 5 | 5.5 | 4.75 | 5 | 5.25 | V |
| High-level output current, I<sub>OH</sub> | | | –400 | | | –400 | µA |
| Low-level output current, I<sub>OL</sub> | | | 4 | | | 8 | mA |
| Operating free-air temperature, T<sub>A</sub> | –55 | | 125 | 0 | | 70 | °C |

## electrical characteristics over recommended operating free-air temperature range (unless otherwise noted)

| Parameter | | Test Conditions† | 54LS MIN | 54LS TYP‡ | 54LS MAX | 74LS MIN | 74LS TYP‡ | 74LS MAX | UNIT |
|-----------|---|------------------|---:|---:|---:|---:|---:|---:|:--:|
| V<sub>IH</sub> | High-level input voltage | | 2 | | | 2 | | | V |
| V<sub>IL</sub> | Low-level input voltage | | | | 0.7 | | | 0.8 | V |
| V<sub>IK</sub> | Input clamp voltage | V<sub>CC</sub> = MIN, I<sub>I</sub> = –18 mA | | | –1.5 | | | –1.5 | V |
| V<sub>OH</sub> | High-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = V<sub>IL</sub> max, I<sub>OH</sub> = –400 µA | 2.5 | 3.4 | | 2.7 | 3.4 | | V |
| V<sub>OL</sub> | Low-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = V<sub>IL</sub> max, I<sub>OL</sub> = 4 mA | | 0.25 | 0.4 | | 0.25 | 0.4 | V |
| V<sub>OL</sub> | Low-level output voltage | same, I<sub>OL</sub> = 8 mA | | | | | 0.35 | 0.5 | V |
| I<sub>I</sub> | Input current at maximum input voltage | V<sub>CC</sub> = MAX, V<sub>I</sub> = 7 V | | | 0.2 | | | 0.2 | mA |
| I<sub>IH</sub> | High-level input current | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.7 V | | | 40 | | | 40 | µA |
| I<sub>IL</sub> | Low-level input current | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.4 V | | | –0.8 | | | –0.8 | mA |
| I<sub>OS</sub> | Short-circuit output current§ | V<sub>CC</sub> = MAX | –20 | | –100 | –20 | | –100 | mA |
| I<sub>CC</sub> | Supply current | V<sub>CC</sub> = MAX, See Note 2 | | 6.1 | 10 | | 6.1 | 10 | mA |

† For conditions shown as MIN or MAX, use the appropriate value specified under recommended operating conditions for the applicable type.
‡ All typical values are at V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C.
§ Not more than one output should be shorted at a time.
NOTE 2: I<sub>CC</sub> is measured with the inputs grounded and the outputs open.

## switching characteristics, V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C

Load for all rows: C<sub>L</sub> = 15 pF, R<sub>L</sub> = 2 kΩ, See Note 3.

| Parameter¶ | From (Input) | Test Conditions | MIN | TYP | MAX | UNIT |
|------------|:------------:|-----------------|---:|---:|---:|:--:|
| t<sub>PLH</sub> | A or B | Other input low | | 12 | 23 | ns |
| t<sub>PHL</sub> | A or B | Other input low | | 10 | 17 | ns |
| t<sub>PLH</sub> | A or B | Other input high | | 20 | 30 | ns |
| t<sub>PHL</sub> | A or B | Other input high | | 13 | 22 | ns |

¶ t<sub>PLH</sub> = propagation delay time, low-to-high-level output; t<sub>PHL</sub> = propagation delay time, high-to-low-level output.
NOTE 3: Load circuits and voltage waveforms are shown in Section 1.

**Page 4**

---

# SN54S86, SN74S86 — Ratings, Operating Conditions and Characteristics

*(source page 5)*

## absolute maximum ratings over operating free-air temperature range (unless otherwise noted)

| Rating | Value |
|--------|-------|
| Supply voltage, V<sub>CC</sub> (see Note 1) | 7 V |
| Input voltage | 5.5 V |
| Operating free-air temperature range: SN54S86 | –55°C to 125°C |
| Operating free-air temperature range: SN74S86 | 0°C to 70°C |
| Storage temperature range | –65°C to 150°C |

NOTE 1: Voltage values are with respect to network ground terminal.

## recommended operating conditions

| | SN54S86 MIN | SN54S86 NOM | SN54S86 MAX | SN74S86 MIN | SN74S86 NOM | SN74S86 MAX | UNIT |
|---|---:|---:|---:|---:|---:|---:|:--:|
| Supply voltage, V<sub>CC</sub> | 4.5 | 5 | 5.5 | 4.75 | 5 | 5.25 | V |
| High-level output current, I<sub>OH</sub> | | | –1 | | | –1 | mA |
| Low-level output current, I<sub>OL</sub> | | | 20 | | | 20 | mA |
| Operating free-air temperature, T<sub>A</sub> | –55 | | 125 | 0 | | 70 | °C |

## electrical characteristics over recommended operating free-air temperature range (unless otherwise noted)

| Parameter | | Test Conditions† | 54S MIN | 54S TYP‡ | 54S MAX | 74S MIN | 74S TYP‡ | 74S MAX | UNIT |
|-----------|---|------------------|---:|---:|---:|---:|---:|---:|:--:|
| V<sub>IH</sub> | High-level input voltage | | 2 | | | 2 | | | V |
| V<sub>IL</sub> | Low-level input voltage | | | | 0.8 | | | 0.8 | V |
| V<sub>IK</sub> | Input clamp voltage | V<sub>CC</sub> = MIN, I<sub>I</sub> = –18 mA | | | –1.2 | | | –1.2 | V |
| V<sub>OH</sub> | High-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OH</sub> = –1 mA | 2.5 | 3.4 | | 2.7 | 3.4 | | V |
| V<sub>OL</sub> | Low-level output voltage | V<sub>CC</sub> = MIN, V<sub>IH</sub> = 2 V, V<sub>IL</sub> = 0.8 V, I<sub>OL</sub> = 20 mA | | | 0.5 | | | 0.5 | V |
| I<sub>I</sub> | Input current at maximum input voltage | V<sub>CC</sub> = MAX, V<sub>I</sub> = 5.5 V | | | 1 | | | 1 | mA |
| I<sub>IH</sub> | High-level input current | V<sub>CC</sub> = MAX, V<sub>I</sub> = 2.7 V | | | 50 | | | 50 | µA |
| I<sub>IL</sub> | Low-level input current | V<sub>CC</sub> = MAX, V<sub>I</sub> = 0.5 V | | | –2 | | | –2 | mA |
| I<sub>OS</sub> | Short-circuit output current§ | V<sub>CC</sub> = MAX | –40 | | –100 | –40 | | –100 | mA |
| I<sub>CC</sub> | Supply current | V<sub>CC</sub> = MAX, See Note 2 | | 50 | 75 | | 50 | 75 | mA |

† For conditions shown as MIN or MAX, use the appropriate value specified under recommended operating conditions for the applicable type.
‡ All typical values are at V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C.
§ Not more than one output should be shorted at a time, and duration of the short-circuit should not exceed one second.
NOTE 2: I<sub>CC</sub> is measured with the inputs grounded and the outputs open.

## switching characteristics, V<sub>CC</sub> = 5 V, T<sub>A</sub> = 25°C

Load for all rows: C<sub>L</sub> = 15 pF, R<sub>L</sub> = 280 Ω, See Note 3.

| Parameter¶ | From (Input) | Test Conditions | MIN | TYP | MAX | UNIT |
|------------|:------------:|-----------------|---:|---:|---:|:--:|
| t<sub>PLH</sub> | A or B | Other input low | | 7 | 10.5 | ns |
| t<sub>PHL</sub> | A or B | Other input low | | 6.5 | 10 | ns |
| t<sub>PLH</sub> | A or B | Other input high | | 7 | 10.5 | ns |
| t<sub>PHL</sub> | A or B | Other input high | | 6.5 | 10 | ns |

¶ t<sub>PLH</sub> = propagation delay time, low-to-high-level output; t<sub>PHL</sub> = propagation delay time, high-to-low-level output.
NOTE 3: Load circuits and voltage waveforms are shown in Section 1.

**Page 5**
