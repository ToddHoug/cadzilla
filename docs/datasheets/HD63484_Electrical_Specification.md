# Hitachi HD63484 ACRTC — Electrical Specification

*Extracted from the Hitachi HD63484 Advanced CRT Controller User's Manual (source/printed pages 309–330; PDF pages 320–341).*

*This document covers the Electrical Specification section only: Absolute Maximum Ratings, Recommended Operating Conditions, DC Characteristics, AC Characteristics, and the associated timing diagrams (Figures T-1 through T-16) and test load circuits. It was produced separately from the main HD63484_User_Manual.md at the user's request, since the main manual conversion was stopped at printed page 308 (the end of the 'Use of Arc and Ellipse Arc Command' appendix) and this section was explicitly excluded from it.*

---

*(source page 309)*

# ELECTRICAL SPECIFICATION

---

*(source page 310)*

*(This page is blank.)*

---

*(source page 311)*

○ Absolute Maximum Ratings

| Item | Symbol | Rating | Unit |
|---|---|---|---|
| Supply voltage | Vcc * | −0.3 ~ +7.0 | V |
| Input voltage | Vin * | −0.3 ~ +7.0 | V |
| Allowable output current | \|Io\| ** | 5 | mA |
| Total allowable output current | \|ΣIo\| *** | 120 | mA |
| Operating temperature | Topr | −20 ~ +75 | °C |
| Storage temperature | Tstg | −55 ~ +150 | °C |

\* This value is in reference to Vss = 0V.

\*\* The allowable output current is the maximum current that may be drawn from, or flow out to, one output terminal or one input/output common terminal.

\*\*\* The total allowable output current is the total sum of currents that may be drawn from, or flow out to, output terminals or input/output common terminals.

Note: Using an LSI beyond its maximum ratings may result in its permanent destruction. LSI's should usually be used under recommended operating conditions. Exceeding any of these conditions may adversely affect its reliability.

○ Recommended Operating Conditions

| Item | Symbol | min | typ | max | Unit |
|---|---|---|---|---|---|
| Supply voltage | Vcc * | 4.5 | 5.0 | 5.5 | V |
| Input "low" level voltage | VIL * | 0 | — | 0.8 | V |
| Input "high" level voltage | VIH * | 2.2 | — | Vcc | V |
| Operating temperature | Topr | −20 | 25 | 75 | °C |

\* This value is in reference to Vss = 0V.

---

*(source page 312)*

○ Electrical Characteristics

• DC characteristics (Vcc = 5.0V ± 10%, Vss = 0V, Ta = −20 to 75°C unless otherwise noted)

| Item | Pins | Symbol | Measuring condition | 4 MHz Version HD63484-4 min | max | 6 MHz Version HD63484-6 min | max | 8 MHz Version HD63484-8 min | max | Unit |
|---|---|---|---|---|---|---|---|---|---|---|
| Input "high" level voltage | All Inputs | VIH | | 2.2 | Vcc | 2.2 | Vcc | 2.2 | Vcc | V |
| Input "low" level voltage | All Inputs | VIL | | −0.3 | 0.8 | −0.3 | 0.8 | −0.3 | 0.8 | V |
| Input leak current | R/W, CS, RS, RES, DACK, 2CLK, LPSTB | Iin | Vin=0~Vcc | −2.5 | 2.5 | −2.5 | 2.5 | −2.5 | 2.5 | μA |
| Three state (off state) input current | D0~D15, EXSYNC, MAD0~MAD15 | ITSI | Vin=0.4~Vcc | −10 | 10 | −10 | 10 | −10 | 10 | μA |
| Output "high" level voltage | D0~D15, MAD0~MAD15, CUD1, CUD2, DREQ, DTACK, HSYNC, VSYNC, EXSYNC | VOH | IOH=−400μA | Vcc−1.0 | — | Vcc−1.0 | — | Vcc−1.0 | — | V |
| Output "low" level voltage | DISP1, DISP2, CHR, MRD, DRAW, AS, MCYC, RA4, MA16/RA0~MA19/RA3 | VOL | IOL=2.2mA | — | 0.5 | — | 0.5 | — | 0.5 | V |
| Output leak current (off state) | IRQ, DONE | ILOH | VOH=Vcc | — | 10 | — | 10 | — | 10 | μA |
| Input capacity | D0~D15, EXSYNC, MAD0~MAD15 | Cin | Vin=0V, Ta=25°C, f=1.0MHz | — | 15 | — | 15 | — | 15 | pF |
| Input capacity | R/W, CS, RS, RES, DACK, 2CLK, LPSTB | Cin | (same conditions) | — | 15 | — | 15 | — | 15 | pF |

Note: signal names above with an overbar in the original (R/W, CS, RS, RES, DACK, DREQ, DTACK, DISP1, DISP2, DRAW, AS, IRQ, DONE) denote active-low signals; overbars are not reproduced in this transcription.

---

*(source page 313)*

(continued — DC characteristics, Vcc = 5.0V ± 10%, Vss = 0V, Ta = −20 to 75°C unless otherwise noted)

| Item | Pins | Symbol | Measuring condition | 4 MHz Version HD63484-4 min | max | 6 MHz Version HD63484-6 min | max | 8 MHz Version HD63484-8 min | max | Unit |
|---|---|---|---|---|---|---|---|---|---|---|
| Output capacity | IRQ, DONE | Cout | | — | 15 | — | 15 | — | 15 | pF |
| Current consumption | | Icc | Chip not selected; Display in progress | — | T.B.D | — | T.B.D | — | T.B.D | mA |
| Current consumption | | Icc | Data bus in read/write operation; Display in progress; Command execution in progress | — | T.B.D | — | T.B.D | — | T.B.D | mA |

---

*(source page 314)*

• AC characteristics (Vcc = 5.0 ± 10%, Vss = 0V, Ta = −20 to 75°C unless otherwise noted)

| No. | Item | Symbol | 4 MHz Version HD63484-4 min | max | 6 MHz Version HD63484-6 min | max | 8 MHz Version HD63484-8 min | max | Unit |
|---|---|---|---|---|---|---|---|---|---|
| | Frequency of Operation | f | 1 | 4 | 1 | 6 | 1 | 8 | MHz |
| 1 | Clock Cycle Time | tcyc | 250 | 1000 | 167 | 1000 | 125 | 1000 | ns |
| 2 | Clock "High" Level Pulse Width | tPWCH | 115 | 500 | 75 | 500 | 55 | 500 | ns |
| 3 | Clock "Low" Level Pulse Width | tPWCL | 115 | 500 | 75 | 500 | 55 | 500 | ns |
| 4 | Clock Rise Time | tcr | — | 10 | — | 10 | — | 10 | ns |
| 5 | Clock Fall Time | tcf | — | 10 | — | 10 | — | 10 | ns |
| 6 | R/W Setup Time | tRWS | 70 | — | 60 | — | 50 | — | ns |
| 7 | R/W Hold Time | tRWH | 0 | — | 0 | — | 0 | — | ns |
| 8 | RS Setup Time | tRSS | 70 | — | 60 | — | 50 | — | ns |
| 9 | RS Hold Time | tRSH | 0 | — | 0 | — | 0 | — | ns |
| 10 | CS Setup Time | tCSS | 50 | — | 40 | — | 40 | — | ns |
| 11 | CS Hold Time | tCSH | 60 | — | 60 | — | 60 | — | ns |
| 12 | *(no entry in source)* | | | | | | | | |
| 13 | Read Wait Time | tRWAI | 0 | — | 0 | — | 0 | — | ns |
| 14 | Read Data Access Time | tRDAC | — | 120 | — | 100 | — | 80 | ns |
| 15 | Read Data Hold Time | tRDH | 10 | — | 10 | — | 10 | — | ns |
| 16 | Read Data Turn Off Time | tRDZ | — | 60 | — | 60 | — | 60 | ns |
| 17 | DTACK Delay Time (Z to L) | tDTKZL | — | 90 | — | 80 | — | 70 | ns |
| 18 | DTACK Delay Time (D to L) | tDTKDL | 0 | — | 0 | — | 0 | — | ns |
| 19 | DTACK Hold Time (L to H) | tDTKLH | — | 60 | — | 60 | — | 60 | ns |
| 20 | DTACK Turn Off Time (H to Z) | tDTKZ | — | 100 | — | 100 | — | 100 | ns |
| 21 | Data Bus 3 State Recovery Time 1 | tDBRT1 | 0 | — | 0 | — | 0 | — | ns |
| 22 | Write Wait Time | tWWAI | 0 | — | 0 | — | 0 | — | ns |
| 23 | WRITE Data Setup Time | tWDS | 80 | — | 60 | — | 40 | — | ns |
| 24 | WRITE Data Hold Time | tWDH | 10 | — | 10 | — | 10 | — | ns |
| 25 | DREQ Delay Time1 | tDRQD1 | 70 | — | 60 | — | 50 | — | ns |
| 26 | DREQ Delay Time2 | tDRQD2 | 70 | — | 60 | — | 50 | — | ns |
| 27 | DMA R/W Setup Time | tDRWS | 70 | — | 60 | — | 50 | — | ns |
| 28 | DMA R/W Hold Time | tDRWH | 0 | — | 0 | — | 0 | — | ns |
| 29 | DACK Setup Time | tDAKS | 50 | — | 40 | — | 40 | — | ns |
| 30 | DACK Hold Time | tDAKH | 60 | — | 60 | — | 60 | — | ns |
| 31 | *(no entry in source)* | | | | | | | | |
| 32 | DMA Read Wait Time | tDRW | 0 | — | 0 | — | 0 | — | ns |
| 33 | DMA Read Data Access Time | tDRDAC | — | 120 | — | 100 | — | 80 | ns |
| 34 | DMA Read Data Hold Time | tDRDH | 10 | — | 10 | — | 10 | — | ns |

Measuring condition column is blank for all rows in the source.

---

*(source page 315)*

(continued — AC characteristics)

| No. | Item | Symbol | 4 MHz Version HD63484-4 min | max | 6 MHz Version HD63484-6 min | max | 8 MHz Version HD63484-8 min | max | Unit |
|---|---|---|---|---|---|---|---|---|---|
| 35 | DMA Read Data Turn Off Time | tDRDZ | — | 60 | — | 60 | — | 60 | ns |
| 36 | DMA DTACK Delay Time (Z to L) | tDDTZL | — | 90 | — | 80 | — | 70 | ns |
| 37 | DMA DTACK Delay Time (D to L) | tDDTDL | 0 | — | 0 | — | 0 | — | ns |
| 38 | DMA DTACK Hold Time (L to H) | tDDTLH | 60 | — | 60 | — | 60 | — | ns |
| 39 | DMA DTACK Turn Off Time (H to Z) | tDDTHZ | — | 100 | — | 100 | — | 100 | ns |
| 40 | DONE Output Delay Time | tDND | — | 70 | — | 60 | — | 50 | ns |
| 41 | DONE Output Turn Off Time (L to Z) | tDNLZ | — | 100 | — | 90 | — | 80 | ns |
| 42 | Data Bus 3 State Recovery Time 2 | tDBRT2 | 0 | — | 0 | — | 0 | — | ns |
| 43 | DONE Input Pulse Width | tDNPW | 2 | — | 2 | — | 2 | — | Clk. Cyc |
| 44 | DMA Write Wait Time | tDWW | 0 | — | 0 | — | 0 | — | ns |
| 45 | DMA Write Data Setup Time | tDWDS | 80 | — | 60 | — | 40 | — | ns |
| 46 | DMA Write Data Hold Time | tDWDH | 10 | — | 10 | — | 10 | — | ns |
| 47 | *(no entry in source)* | | | | | | | | |
| 48 | *(no entry in source)* | | | | | | | | |
| 49 | Memory Address Hold Time 2 | tMAH2 | 10 | — | 10 | — | 10 | — | ns |
| 50 | AS Delay Time | tASD | — | 90 | — | 75 | — | 65 | ns |
| 51 | AS "Low" Level Pulse Width | tPWASL | 80 | tPWCL+30 | 50 | tPWCL+10 | 30 | tPWCL | ns |
| 52 | Memory Address Delay Time | tMAD | — | 90 | — | 80 | — | 70 | ns |
| 53 | Memory Address Hold Time 1 | tMAH1 | 10 | — | 10 | — | 10 | — | ns |
| 54 | Memory Address Turn Off Time (A-Z) | tMAAZ | — | 50 | — | 50 | — | 50 | ns |
| 55 | Memory Address Data Setup Time | tMRDS | 60 | — | 50 | — | 40 | — | ns |
| 56 | Memory Read Data Hold Time | tMRDH | 10 | — | 10 | — | 10 | — | ns |
| 57 | MA/RA Delay Time | tMARAD | — | 90 | — | 80 | — | 70 | ns |
| 58 | MA/RA Hold Time | tMARAH | 10 | — | 10 | — | 10 | — | ns |
| 59 | MCYC Delay Time | tMCYCD | — | 60 | — | 50 | — | 40 | ns |
| 60 | MRD Delay Time | tMRDD | — | 90 | — | 80 | — | 70 | ns |
| 61 | MRD Hold Time | tMRDH | 10 | — | 10 | — | 10 | — | ns |
| 62 | DRAW Delay Time | tDRWD | — | 90 | — | 80 | — | 70 | ns |
| 63 | DRAW Hold Time | tDRWH | 10 | — | 10 | — | 10 | — | ns |
| 64 | Memory Write Data Delay Time | tMWDD | — | 90 | — | 80 | — | 70 | ns |
| 65 | Memory Write Data Hold Time | tMWDH | 10 | — | 10 | — | 10 | — | ns |

---

*(source page 316)*

(continued — AC characteristics)

| No. | Item | Symbol | 4 MHz Version HD63484-4 min | max | 6 MHz Version HD63484-6 min | max | 8 MHz Version HD63484-8 min | max | Unit |
|---|---|---|---|---|---|---|---|---|---|
| 66 | Memory Write Data Turn Off Time | tMWDZ | — | 60 | — | 50 | — | 40 | ns |
| 67 | HSYNC Delay Time | tHSD | — | 90 | — | 80 | — | 70 | ns |
| 68 | VSYNC Delay Time | tVSD | — | 90 | — | 80 | — | 70 | ns |
| 69 | DISP1, DISP2 Delay Time | tDSPD | — | 90 | — | 80 | — | 70 | ns |
| 70 | CUD1, CUD2 Delay Time | tCUDD | — | 90 | — | 80 | — | 70 | ns |
| 71 | EXSYNC Output Delay Time | tEXD | 30 | 90 | 30 | 80 | 30 | 70 | ns |
| 72 | CHR Delay Time | tCHD | — | 90 | — | 80 | — | 70 | ns |
| 73 | *(no entry in source)* | | | | | | | | |
| 74 | *(no entry in source)* | | | | | | | | |
| 75 | EXSYNC Input Pulse Width | tEXSW | 3 | — | 3 | — | 3 | — | Clk. Cyc |
| 76 | EXSYNC Input Setup Time | tEXS | 60 | — | 60 | — | 50 | — | ns |
| 77 | EXSYNC Input Hold Time | tEXH | 30 | — | 30 | — | 30 | — | ns |
| 78 | LPSTB Uncertain Time 1 | tLPD1 | 70 | — | 70 | — | 70 | — | ns |
| 79 | LPSTB Uncertain Time 2 | tLPD2 | 10 | — | 10 | — | 10 | — | ns |
| 80 | LPSTB Input Hold Time | tLPH | 10 | — | 10 | — | 10 | — | ns |
| 81 | LPSTB Input Inhibit time | tLPI | 4 | — | 4 | — | 4 | — | Clk. Cyc |
| 82 | DACK Setup Time for RES | tDAKSR | 100 | — | 100 | — | 100 | — | ns |
| 83 | DACK Hold Time for RES | tDAKHR | 0 | — | 0 | — | 0 | — | ns |
| 84 | RES Input Pulse Width | tRES | 10 | — | 10 | — | 10 | — | Clk. Cyc |
| 85 | IRQ Delay Time 1 | tIRQ1 | 100 | — | 100 | — | 100 | — | ns |
| 86 | IRQ Delay Time 2 | tIRQ2 | 500 | — | 500 | — | 500 | — | ns |
| 87 | ATR Delay Time 1 | tATRD1 | — | 100 | — | 90 | — | 80 | ns |
| 88 | ATR Hold Time 1 | tATRH1 | 10 | — | 10 | — | 10 | — | ns |
| 89 | ATR Turn Off Time | tATRZ | — | 60 | — | 50 | — | 40 | ns |
| 90 | ATR Delay Time 2 | tATRD2 | — | 100 | — | 90 | — | 80 | ns |
| 91 | ATR Hold Time 2 | tATRH2 | 10 | — | 10 | — | 10 | — | ns |

---

*(source page 317)*

*(Timing diagram: 2CLK waveform showing one full clock cycle. The 2CLK signal rises from 0.8V through a falling edge into a "low" period labeled tPWCL (item ③), then rises through 2.2V into a "high" period labeled tPWCH (item ②), then falls again. The rising edge is labeled tcr (item ④) and the falling edge tcf (item ⑤). The full period from one falling-edge crossing to the next is labeled tcyc (item ①), spanning from the 2.2V/0.8V crossing points at the start of one low period to the equivalent crossing point one cycle later.)*

**Figure T-1 2CLK Waveform**

---

*(source page 318)*

*(Timing diagram: MPU Read Cycle Timing (MPU ← ACRTC), showing signals 2CLK, R/W, RS, CS, D0~D15, and DTACK across clock states T0, T1, T2, T3, T4, ... Tn (n = min. 5).)*

2CLK runs continuously as a train of clock pulses crossing 2.2V (high) and 0.8V (low) at each state boundary T0–Tn.

R/W is shown transitioning near T0 (item ⑥, R/W Setup Time, crossing 2.2V) and again near Tn (item ⑦, R/W Hold Time, crossing 2.2V then returning low).

RS crosses near T0 (item ⑧, RS Setup Time, transitioning between 2.2V and 0.8V) and again near Tn (item ⑨, RS Hold Time).

CS falls near T0 (item ⑩, CS Setup Time, crossing from 2.2V to 0.8V) and rises again near Tn (item ⑪, CS Hold Time, crossing from 0.8V back to 2.2V).

D0~D15 shows a hatched/undefined region from before T0 through item ㉑ (Data Bus 3-State Recovery Time 1) and item ⑭ (Read Wait Time), then valid read data appears (bounded by Vcc−2.0V high level and 0.5V low level) and is held through item ⑮/⑯ (Read Data Access Time / Read Data Hold Time) until near Tn.

DTACK stays high until item ⑰ (Read Data Access Time related delay) then falls to 0.5V, remaining low for a duration marked ⑬ (spanning most of the wait states) before rising again near Tn at items ⑲/⑳ (DTACK Hold Time / DTACK Turn Off Time), transitioning through Vcc−2.0V.

**Figure T-2 MPU Read Cycle Timing (MPU ← ACRTC)**

---

*(source page 319)*

*(Timing diagram: MPU Write Cycle Timing (MPU → ACRTC), showing signals 2CLK, R/W, RS, CS, D0~D15, and DTACK across clock states T0, T1, T2, T3, T4, ... Tn (n = min. 5).)*

2CLK runs continuously as a train of clock pulses crossing 2.2V/0.8V at each state boundary.

R/W falls near T0 (item ⑥, crossing 0.8V) and rises again near Tn (item ⑦, crossing 0.8V upward).

RS crosses near T0 (item ⑧, between 2.2V and 0.8V) and again near Tn (item ⑨).

CS falls near T0 (item ⑩, crossing from 2.2V to 0.8V) and rises again near Tn (item ⑪, from 0.8V to 2.2V).

D0~D15 shows valid write data appearing around Tn, bounded between 2.2V and 0.8V levels, with item ㉓ (WRITE Data Setup Time) marking the interval before the write-latching edge and item ㉔ (WRITE Data Hold Time) marking the interval after it.

DTACK stays high until item ⑰ then falls to 0.5V, remaining low for a duration marked ㉒ (spanning the wait states) before rising again near Tn at items ⑲/⑳, transitioning through Vcc−2.0V.

**Figure T-3 MPU Write Cycle Timing (MPU → ACRTC)**

---

*(source page 320)*

*(Timing diagram: DMA Read Cycle timing (Memory ← ACRTC), showing signals 2CLK, DREQ, R/W, DACK, D0~D15 (OUTPUT), DTACK (with associated DMAC PCL ← ACRTC / READY etc. labels), DONE (OUTPUT), and DONE (INPUT), across clock states TRQ, T0, T1, T2, T3, T4, ... Tn (n = min. 5).)*

2CLK runs continuously as a train of clock pulses crossing 2.2V/0.8V.

DREQ falls near TRQ (item ㉕, crossing 0.5V) and later shows a branch point near T1 (item ㉖) where it can go either to a "DRC=1" level (rising, crossing Vcc−2.0V) or remain at a "DRC=0" level (staying low); a matching pair of transitions (also labeled ㉖) recurs near Tn.

R/W transitions near T1 (crossing 0.8V) and again near Tn (item ㉘, crossing 0.8V).

DACK falls near T1 (items ㉗/㉙, crossing from 2.2V to 0.8V) and rises again near Tn (items ㉙/㉚, from 0.8V to 2.2V).

D0~D15 (OUTPUT) shows a hatched/undefined region through items ㊵/㉝ before valid output data appears (bounded by Vcc−2.0V and 0.5V) and is held through items ㉞ until near Tn.

DTACK falls partway through the cycle (items ㊱/㊲, crossing 0.5V) and rises again near Tn (items ㉟/㉖ region, transitioning through Vcc−2.0V), labeled as associated with "DMAC PCL ← ACRTC" / "READY" etc. on the same signal row.

DONE (OUTPUT) falls near T1 (item ㊵, crossing 0.5V) and rises again near Tn (item ㊶).

DONE (INPUT) shows a hatched (don't-care) region from before T1 through a point marked with item ㊷ (asterisk-noted) crossing 0.5V twice, spanning to a second hatched region near Tn.

A note at the right states: "* DONE needs to be asserted 'low' while DACK remains 'low'."

**Figure T-4 DMA Read Cycle timing (Memory ← ACRTC)**

---

*(source page 321)*

*(Timing diagram: DMA Write Cycle timing (Memory → ACRTC), showing signals 2CLK, DREQ, R/W, DACK, D0~D15 (INPUT), DTACK (with DMAC PCL ← ACRTC / READY etc. labels), DONE (OUTPUT), and DONE (INPUT), across clock states TRQ, T0, T1, T2, T3, T4, ... Tn (n = min. 5).)*

2CLK runs continuously as a train of clock pulses crossing 2.2V/0.8V.

DREQ falls near TRQ (item ㉕, crossing 0.5V) and shows branch points near T1 and Tn (both item ㉖) toggling between a "DRC=1" level (Vcc−2.0V) and a "DRC=0" level (low).

R/W rises near T1 (crossing 2.2V) and falls again near Tn (item ㉘, crossing 2.2V).

DACK falls near T1 (items ㉗/㉙, from 2.2V to 0.8V) and rises again near Tn (items ㉙/㉚, from 0.8V to 2.2V).

D0~D15 (INPUT) shows valid input data appearing mid-cycle (bounded between 2.2V and 0.8V) spanning items ㊺ (DMA Write Data Setup Time) and ㊻ (DMA Write Data Hold Time), positioned around the DACK transition near Tn.

DTACK falls partway through (items ㊱/㊴, crossing 0.5V) and rises again near Tn (items ㊳/㊲, transitioning through Vcc−2.0V), associated with "DMAC PCL ← ACRTC / READY etc." on the same row.

DONE (OUTPUT) falls near T1 (item ㊵, crossing 0.5V) and rises again near Tn (item ㊶).

DONE (INPUT) shows a hatched (don't-care) region from before T1 through a point marked ㊷ (asterisk-noted) crossing 0.5V twice, spanning to a second hatched region near Tn.

A note at the right states: "* DONE needs to be asserted 'low' while DACK remains 'low'."

**Figure T-5 DMA Write Cycle timing (Memory → ACRTC)**

---

*(source page 322)*

*(Timing diagram: Screen Display Cycle Timing, showing signals 2CLK, AS, MAD, MA/RA, MCYC, MRD, and DRAW across three successive clock cycles.)*

2CLK runs as a train of clock pulses crossing 0.8V at each falling transition marked by vertical reference lines.

AS falls near the first reference line (item ㊿, crossing 0.5V) and rises again (item ㊾, crossing Vcc−2.0V) within the same cycle; the item ㊿ label recurs at the third reference line.

MAD shows valid address data (item ㊿-52, bounded by Vcc−2.0V/0.5V) appearing after the AS falling edge and held until item ㊿-53/54 near the next AS transition.

MA/RA crosses (item ㊿-57, between Vcc−2.0V and 0.5V) near the first reference line and again (item ㊿-58) near the third.

MCYC falls (item ㊿-59, crossing 0.5V) near the first reference line and rises (item ㊿-59 again, crossing Vcc−2.0V) near the second.

MRD rises (item ㊿-60, crossing Vcc−2.0V) near the first reference line and falls (item ㊿-61) near the third.

DRAW rises (item ㊿-62, crossing Vcc−2.0V) near the first reference line and falls (item ㊿-63) near the third.

(Item numbers on this figure correspond to AC characteristics table entries 50, 51, 52, 53, 54, 57, 58, 59, 60, 61, 62, 63.)

**Figure T-6 Screen Display Cycle Timing**

---

*(source page 323)*

*(Timing diagram: Frame Memory Read Cycle Timing (ACRTC ← Frame Memory), showing signals 2CLK, AS, MAD0~MAD15, MA16/RA0, MA17/RA1, MA18/RA2, MA19/RA3, RA4, MCYC, MRD, and DRAW, across clock cycles marked by 0.8V crossing reference lines.)*

2CLK runs as a train of clock pulses crossing 0.8V at each cycle boundary.

AS falls near the first reference line (item 50, crossing 0.5V) then rises (item 51, crossing Vcc−2.0V) before the second reference line.

MAD0~MAD15 shows an "Address" phase (items 52/53, bounded by Vcc−2.0V/0.5V) followed immediately by a "Data" phase (items 55/56, bounded by 2.2V/0.8V), with item 54 marking the transition point between address and data phases (aligned with the second reference line) and item 49 marking a small gap between them.

MA16/RA0 through MA19/RA3, RA4 (grouped as one bus row) cross (item 57, between Vcc−2.0V and 0.5V) near the first reference line and again (item 58) near the third.

MCYC falls (item 59, crossing 0.5V) near the first reference line and rises (item 59 again, crossing Vcc−2.0V) near the second.

MRD rises (item 60, crossing Vcc−2.0V) near the first reference line and falls (item 61) near the third.

DRAW falls (item 62, crossing 0.5V) near the first reference line and rises (item 63) near the third.

**Figure T-7 Frame Memory Read Cycle Timing (ACRTC ← Frame Memory)**

---

*(source page 324)*

*(Timing diagram: Frame Memory Write Cycle Timing (ACRTC → Frame Memory), showing signals 2CLK, AS, MAD0~MAD15, MA16/RA0, MA17/RA1, MA18/RA2, MA19/RA3, RA4, MCYC, MRD, and DRAW, across clock cycles marked by 0.8V crossing reference lines.)*

2CLK runs as a train of clock pulses crossing 0.8V at each cycle boundary.

AS falls near the first reference line (item 50, crossing 0.5V) then rises (item 51, crossing Vcc−2.0V) before the second reference line.

MAD0~MAD15 shows an "Address" phase (items 52/53, bounded by Vcc−2.0V/0.5V) followed by a "Data" phase (item 64, also Vcc−2.0V/0.5V), with item 49 marking the small gap between address and data phases, and item 65/66 marking the data phase's end near the third reference line.

MA16/RA0 through MA19/RA3, RA4 cross (item 57, between Vcc−2.0V and 0.5V) near the first reference line and again (item 58) near the third.

MCYC falls (item 59, crossing 0.5V) near the first reference line and rises (item 59 again, crossing Vcc−2.0V) near the second.

MRD stays low throughout this write cycle (rising only outside the shown window, items 60/61 marking edges at the first and third reference lines).

DRAW rises (item 62, crossing 0.5V threshold) near the first reference line and falls (item 63) near the third.

**Figure T-8 Frame Memory Write Cycle Timing (ACRTC → Frame Memory)**

---

*(source page 325)*

*(Timing diagram: Frame Memory Refresh/Attribute Control Information Output Cycle Timing, showing signals 2CLK, AS, MAD, MA/RA, MCYC, MRD, DRAW, and HSYNC, spanning two labeled phases at the top: "Refresh Cycle" (left, covering the first two clock cycles) and "Attribute Control Information Output Cycle" (right, covering the remaining cycles).)*

2CLK runs as a train of clock pulses crossing 0.8V at each cycle boundary throughout both phases.

AS falls (item 50, crossing 0.5V) then rises (item 51, crossing Vcc−2.0V) within the Refresh Cycle, then falls and rises again (dashed transition) within the Attribute Control Information Output Cycle, with item 89 marking a further AS transition near the end.

MAD shows a "Refresh Address" block (items 52/53/54, Vcc−2.0V/0.5V) during the Refresh Cycle, a second "Refresh* Address" block during the Attribute Control cycle (marked with an asterisk referring to the footnote), and an "ATR" (Attribute) data block (item 87/88) near the end.

MA/RA shows a "Low" level held through most of both cycles (item 57 crossing at the start), with an "ATR" block (items 90/91) appearing near the end alongside the MAD ATR block.

MCYC falls (item 59, crossing 0.5V) and rises (item 59 again, crossing Vcc−2.0V) at the start of the Refresh Cycle, then falls and rises again between the Refresh and Attribute Control phases, and once more near the end.

MRD rises (item 60, crossing Vcc−2.0V) at the start and falls (item 61) near the end.

DRAW rises (item 62, crossing Vcc−2.0V) at the start and falls (item 63) near the end.

HSYNC falls (item 67, crossing 0.5V) at the start of the Refresh Cycle and rises again (item 67, crossing Vcc−2.0V) near the end of the Attribute Control Information Output Cycle.

A footnote at the bottom right states: "* When AS is 'High', a '0' output is given."

**Figure T-9 Frame Memory Refresh/Attribute Control Information Output Cycle Timing**

---

*(source page 326)*

### Figure T-10 Display Control Signal Output Timing

*(Timing diagram showing the 2CLK clock waveform along the top, followed by MCYC, then the paired signals HSYNC/VSYNC, DISP1/DISP2, CUD1/CUD2, and EXSYNC (OUTPUT), and finally CHR. The diagram illustrates three successive 2CLK cycles with a break (shown by the double-slash "break" marks) between the second and third cycles shown.)*

- **2CLK**: shown as a clock waveform crossing the 0.8V reference level at each falling edge over three depicted cycles.
- **MCYC**: falls to 0.5V referenced to the first 2CLK falling edge (delay item ⑨), then rises to Vcc − 2.0V referenced to the following 2CLK falling edge (also delay item ⑨), and falls again at the third 2CLK edge shown.
- **HSYNC/VSYNC**: falls to 0.5V referenced to the first MCYC-related 2CLK edge (delay items ⑥⑦, ⑥⑧), remains low across the break, then rises to Vcc − 2.0V referenced to the 2CLK edge at the right side of the diagram (again items ⑥⑦, ⑥⑧).
- **DISP1/DISP2**: falls to 0.5V referenced to the same 2CLK edge (delay item ⑥⑨), remains low across the break, then rises to Vcc − 2.0V at the corresponding later edge (item ⑥⑨).
- **CUD1/CUD2**: falls to 0.5V referenced to the same 2CLK edge (delay item ⑦⓪), remains low across the break, then rises to Vcc − 2.0V at the corresponding later edge (item ⑦⓪).
- **EXSYNC (OUTPUT)**: falls to 0.5V referenced to the same 2CLK edge (delay item ⑦①), remains low across the break, then rises to Vcc − 2.0V at the corresponding later edge (item ⑦①).
- **CHR**: rises to Vcc − 2.0V referenced to the first 2CLK edge (delay item ⑦②), remains high across the break, then falls to 0.5V at the corresponding later edge (item ⑦②).

All delay-time item numbers (⑤⑨, ⑥⑦, ⑥⑧, ⑥⑨, ⑦⓪, ⑦①, ⑦②) correspond to the numbered rows of the AC Characteristics tables given earlier in this section.

---

*(source page 327)*

### Figure T-11 EXSYNC Input Timing

*(This figure has two parts, stacked vertically.)*

**Upper diagram — EXSYNC/HSYNC relationship:**

The 2CLK waveform is shown running continuously (with a break shown partway through). EXSYNC (From MASTER) is normally high, falls low, then rises again; the rising edge is referenced to a 2CLK falling edge, with delay item ⑦⑦ measured from the 0.8V crossing of 2CLK to the start of the EXSYNC transition region (shown hatched), and delay item ⑦⑥ measured from that same 2CLK edge to the completed EXSYNC rising edge. A span of "11 Cycle (2CLK)" is marked from the EXSYNC rising-edge region to a later 2CLK edge. HSYNC (SLAVE) remains high through this span and then falls to 0.5V at that later 2CLK edge, with delay item ⑥⑦ measuring from the 2CLK 0.8V crossing to the HSYNC falling edge.

**Lower diagram — EXSYNC Rise Cycle and internal phase shift:**

The 2CLK waveform is shown with a break, then continuing as a series of numbered clock states T0 through T6 (the "Sync Cycle"). EXSYNC transitions from high to low then back to a hatched rising-edge region ("EXSYNC Rise Cycle") positioned just before T0. Delay item ⑦⑤ measures from the initial EXSYNC falling edge (referenced at the 0.8V level) to the start of this rise-cycle region; delay item ⑦⑦ measures from the 2CLK 0.8V crossing to the start of the hatched EXSYNC transition; delay item ⑦⑥ measures from that same 2CLK edge to the completed EXSYNC rising edge (crossing 2.2V).

Two MCYC waveforms are shown below, both beginning identically and diverging after the EXSYNC Rise Cycle: one is labeled "(Phase Shifted)" and the other "(Phase Not Shifted)", illustrating that if the leading (rising) edge of EXSYNC falls within the shown "EXSYNC Rise Cycle" window, the ACRTC shifts its internal MCYC phase according to the timing shown; if it falls outside that window, the phase is not shifted.

A note below the diagram states: "When the leading edge of EXSYNC enters this period, ACRTC shifts the internal phase according to the above sequence."

---

*(source page 328)*

### Figure T-12 Input LPSTB Timing and Light Pen Address

*(Timing diagram showing 2CLK, MCYC, the memory address bus MAD0~MAD15, and the light-pen strobe input LPSTB.)*

- **2CLK**: a continuous clock waveform; a window near the start is labeled "(Light pen rise cycle)".
- **MCYC**: toggles low/high in step with successive memory cycles.
- **MAD0~MAD15**: shown as a sequence of hexagonal bus-value symbols labeled, in order, M, M+1, M+2, M+3, representing four successive memory addresses output during successive MCYC cycles.
- **LPSTB**: normally at 0.8V (low reference); rises through a hatched transition region to 2.2V, remains high (hatched again through a second transition back down) for a period, then falls back to 0.8V, and later rises again. Delay item ⑦⑨ measures from the start of the "Light pen rise cycle" window to the start of the first hatched LPSTB transition. Delay item ⑦⑧ measures across the region where LPSTB is high, up to a second hatched transition marked with delay item ⑧⓪. Delay item ⑧① measures from the falling edge of LPSTB (after the M+1 window) to its next rising edge (0.8V crossing) at the far right of the diagram.

A note with an arrow pointing to the region spanning the M and M+1 address windows states: "(When LPSTB rises in this period, memory address "M + 3" is set in the light pen address register.)" — that is, the address latched into the light-pen address register is offset by three memory cycles from the point at which LPSTB's rising edge is sampled.

---

*(source page 329)*

### Figure T-13 RES Input and DACK Input Timing (System Reset and 16-bit/8-bit Selection)

*(Timing diagram showing the DACK and RES signals.)*

- **DACK**: normally high; falls to 0.8V, remains low for a period, then rises back to 0.8V. Delay item ⑧② measures the low-level duration of DACK, and delay item ⑧③ measures a short interval from the DACK rising edge to a following reference point.
- **RES**: normally high; falls to 0.5V, remains low, then rises back through 2.2V. Delay item ⑧④ measures the low-level duration of RES, spanning from just after the DACK falling edge to just before the DACK rising edge — that is, RES must be held low for a defined period that overlaps the DACK low pulse, since the state of DACK at the rising edge of RES determines the 16-bit/8-bit data bus width selection.

### Figure T-14 IRQ Output Timing

*(Timing diagram showing 2CLK and IRQ across two separate 2CLK cycles separated by a break.)*

- **2CLK**: a clock waveform crossing 2.2V at its rising edges, shown for one cycle, a break, then another cycle.
- **IRQ**: normally high; falls to 0.5V referenced to the first shown 2CLK rising edge (delay item ⑧⑤), remains low across the break, then rises to Vcc − 2.0V referenced to the second shown 2CLK rising edge (delay item ⑧⑥).

---

*(source page 330)*

### Figure T-15 Test Load Circuit A

*(Schematic diagram: a "Test Point" node connects to a capacitor C to ground, a resistor R to ground, and through a diode to a node that ties to a pull-up resistor RL to 5.0V and a stack of three diodes to ground, all in parallel.)*

A table lists the signals this load circuit applies to, grouped by load condition:

| Signal | Load Condition |
|---|---|
| D0~D15, DTACK, DREQ | (no discrete R/C load — see note) |
| MAD0~MAD15, MA16/RA0~MA19/RA3, RA4 | RL = 1.8 kΩ, C = 40 pF, R = 10 kΩ |
| VSYNC, HSYNC, EXSYNC, MCYC, AS, MRD, DRAW, CHR, DISP1, DISP2, CUD1, CUD2 | RL = 1.8 kΩ, C = 40 pF, R = 10 kΩ |

Note: All diodes are 1S2074(H)'s or the equivalent.

*(The table in the original groups all listed signals under a single load-condition specification of RL = 1.8 kΩ, C = 40 pF, R = 10 kΩ, with the diode note applying to the whole circuit.)*

### Figure T-16 Test Load Circuit B

*(Schematic diagram: the IRQ, DONE output node connects to a pull-up resistor RL to 5.0V and a capacitor C to ground.)*

Load condition: RL = 1.8 kΩ, C = 40 pF.

---

