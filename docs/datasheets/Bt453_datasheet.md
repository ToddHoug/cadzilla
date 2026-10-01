# Brooktree Bt453 RAMDAC — Datasheet (Markdown Transcription)

Transcribed from the scanned, image-only PDF `Brooktree_Bt453.pdf` (Brooktree document L453001 Rev. J, 17 pages, data book pages 4-3 through 4-19). Each page was rendered to PNG and transcribed visually. Tables are reproduced as markdown tables; block diagrams, schematics, pinout drawings and timing diagrams are described in text or converted to tables. Repeating page headers and footers ("SECTION 4", "PC GRAPHICS", the Brooktree address block) have been removed; the data book page numbers are kept at the end of each page.

---

# Bt453 — 66 MHz Monolithic CMOS 256 x 24 Color Palette RAMDAC™

*(source page 1)*

## Distinguishing Features

- 66, 40 MHz Operation
- Triple 8-bit D/A Converters
- 256 x 24 Color Palette RAM
- 3 x 24 Overlay Palette
- RS-343A/RS-170-Compatible Outputs
- Standard MPU Interface
- +5 V CMOS Monolithic Construction
- 40-pin DIP or 44-pin PLCC Package
- Typical Power Dissipation: 1 W

## Applications

- High-Resolution Color Graphics
- CAE/CAD/CAM
- Image Processing
- Instrumentation
- Desktop Publishing

## Related Products

- Bt477, Bt478

## Product Description

The Bt453 RAMDAC is designed specifically for high-resolution color graphics.

The Bt453 has a 256 x 24 color lookup table with triple 8-bit video D/A converters, supporting up to 259 simultaneous colors from a 16.8-million color palette. Three overlay registers provide, for example, overlaying cursors, grids, menus. The MPU bus operates asynchronously to the video data, simplifying the design interface to the system.

The Bt453 generates RS-343A-compatible video signals into a doubly-terminated 75 Ω load.

Both the differential and linearity errors of the D/A converters are guaranteed to be a maximum of ±1 LSB over the full temperature range.

## Functional Block Diagram

*(Diagram described in text.)*

- **Inputs on the left:** CLOCK, P0–P7, SYNC\*, BLANK\*, OL0, OL1 all enter an input **LATCH**.
- The latch drives the **256 x 24 Color Palette RAM** with an 8-bit pixel address (P0–P7) and the **3 x 24 Overlay Palette** with a 2-bit overlay select (OL0, OL1).
- The palette RAM / overlay palette outputs feed three 8-bit buses into three **DACs**, which produce the analog outputs **IOR**, **IOG**, and **IOB**. A separate **ISYNC** current output is also provided.
- A reference amplifier (connected to **FS ADJUST** and **VREF**, with a **COMP** pin) sets the DAC full-scale current.
- Power pins: **VAA** and **GND**.
- MPU side: an 8-bit **ADDR REG** and an **R G B** holding register connect to the 8-bit data bus **D0–D7**. A **BUS CONTROL** block takes **CS\***, **RD\***, **WR\***, **C0**, and **C1**.

*Document L453001 Rev. J*

**Page 4-3**

---

# Circuit Description

*(source page 2)*

## MPU Interface

As illustrated in the functional block diagram, the Bt453 supports a standard MPU bus interface, allowing the MPU direct access to the color palette RAM and overlay color registers. The MPU interface operates asynchronously to the video data, simplifying the design interface.

The C0 and C1 control inputs specify whether the MPU is accessing the address register, the color palette RAM, or the overlay registers, as indicated in Table 1. The 8-bit address register is used to address the color palette RAM and overlay registers, eliminating the requirement for external address multiplexers. ADDR0 corresponds to D0 and is the least significant bit.

To write color data, the MPU loads the address register with the address of the color palette RAM location or overlay register to be modified. The MPU performs three successive write cycles (8 bits each of red, green, and blue), using C0 and C1 to select either the color palette RAM or overlay registers. During the blue write cycle, the 3 bytes of color information are concatenated into a 24-bit word and written to the location specified by the address register. The address register then increments to the next location, which the MPU may modify by writing another sequence of red, green, and blue data.

To read color data, the MPU loads the address register with the address of the color palette RAM location or overlay register to be read. The MPU performs three successive read cycles (8 bits each of red, green, and blue), using C0 and C1 to select either the color palette RAM or overlay registers. Following the blue read cycle, the address register increments to the next location, which the MPU may read by reading another sequence of red, green, and blue data.

Any time the CS\* input is a logical zero, the video outputs are forced to the black level. When the MPU is accessing the color palette RAM, the address register resets to $00 following a blue read or write cycle to RAM location $FF. While the MPU is accessing the overlay color registers, the 6 most significant bits of the address register (ADDR2–7) are ignored.

To keep track of the red, green, and blue read/write cycles, the address register has 2 additional bits (ADDRa and ADDRb) that count modulo three, as shown in Table 2. They are reset to zero when the MPU writes to the address register and are not reset to zero when the MPU reads the address register. The MPU does not have access to these bits. The other 8 bits of the address register (ADDR0–7) are accessible to the MPU and are used to address color palette RAM locations and overlay registers, as specified in Table 2.

Figure 1 illustrates the MPU read/write timing.

| C1 | C0 | Addressed by MPU |
|:--:|:--:|------------------|
| 0 | 0 | address register |
| 0 | 1 | color palette RAM |
| 1 | 0 | address register |
| 1 | 1 | overlay registers |

***Table 1. Control Input Truth Table.***

**Page 4-4**

---

# Circuit Description (continued)

*(source page 3)*

| Register | Value | C1 | C0 | Addressed by MPU |
|----------|:-----:|:--:|:--:|------------------|
| ADDRa, b (counts modulo 3) | 00 | x | 1 | red value |
| | 01 | x | 1 | green value |
| | 10 | x | 1 | blue value |
| ADDR0–7 (counts binary) | $00 – $FF | 0 | 1 | color palette RAM |
| | xxxx xx00 | 1 | 1 | reserved |
| | xxxx xx01 | 1 | 1 | overlay color 1 |
| | xxxx xx10 | 1 | 1 | overlay color 2 |
| | xxxx xx11 | 1 | 1 | overlay color 3 |

***Table 2. Address Register (ADDR) Operation.***

### Figure 1. MPU Read/Write Timing

*(Timing diagram described in text.)*

| Signal | Behavior |
|--------|----------|
| CS\*, C0, C1 | Must be VALID for the whole cycle, bracketing the RD\*/WR\* low pulse. |
| RD\*, WR\* | Active-low strobe; goes low after CS\*/C0/C1 are valid and returns high before they change. |
| D0–D7 (READ) | DATA OUT (RD\* = 0): driven by the Bt453 some time after RD\* falls, and released (three-stated) after RD\* rises. |
| D0–D7 (WRITE) | DATA IN (WR\* = 0): must be valid toward the end of the WR\* low pulse and held briefly after WR\* rises. |

***Figure 1. MPU Read/Write Timing.***

**Page 4-5**

---

# Circuit Description (continued)

*(source page 4)*

## Frame Buffer Interface

While CS\* is a logical one, the P0–P7, OL0, and OL1 inputs are used to address the color palette RAM and overlay registers, as specified in Table 3. The addressed location provides 24 bits of color information to the three D/A converters. (See Figure 2 for timing information.)

The SYNC\* and BLANK\* inputs are also latched on the rising edge of CLOCK to maintain synchronization with the color data. They add appropriately weighted currents to the analog outputs, producing the specific output levels required for video applications, as illustrated in Figure 3. Table 4 details how the SYNC\* and BLANK\* inputs modify the output levels.

The analog outputs of the Bt453 can directly drive a 37.5 Ω load, such as a doubly-terminated 75 Ω coaxial cable.

## ESD and Latchup Considerations

Correct ESD-sensitive handling procedures are required to prevent device damage, which can produce symptoms of catastrophic failure or erratic device behavior with somewhat leaky inputs.

All logic inputs should be held low until power to the device has settled to the specified tolerance. DAC power decoupling networks with large time constants should be avoided. They could delay VAA power to the device. Ferrite beads must be used only for analog power VAA decoupling. Inductors cause a time constant delay that induces latchup.

Latchup can be prevented by ensuring that all VAA pins are at the same potential and that the VAA supply voltage is applied before the signal pin voltages. The correct power-up sequence ensures that any signal pin voltage will never exceed the power supply voltage by more than +0.5 V.

| OL1 | OL0 | P0 – P7 | Addressed by frame buffer |
|:---:|:---:|:-------:|---------------------------|
| 0 | 0 | $00 | color palette RAM location $00 |
| 0 | 0 | $01 | color palette RAM location $01 |
| : | : | : | : |
| 0 | 0 | $FF | color palette RAM location $FF |
| 0 | 1 | $xx | overlay color 1 |
| 1 | 0 | $xx | overlay color 2 |

***Table 3. Pixel and Overlay Control Truth Table.***

*(Note: the printed table ends at overlay color 2; by Table 2, OL1 = 1, OL0 = 1 would select overlay color 3.)*

### Figure 2. Video Input/Output Timing

*(Timing diagram described in text.)*

- **CLOCK:** continuous pixel clock.
- **P0–P7, OL0, OL1, SYNC\*, BLANK\*:** DATA must be set up before, and held after, a rising edge of CLOCK, where it is latched.
- **IOR, IOG, IOB, ISYNC:** the analog outputs change to reflect that DATA after a pipeline delay — in the drawing, the output transition (with a small settling ring) follows the latching edge by two more rising CLOCK edges.

***Figure 2. Video Input/Output Timing.***

**Page 4-6**

---

# Circuit Description (continued)

*(source page 5)*

### Figure 3. Composite Video Output Waveforms

Output levels (left side of the figure):

| Level | Red, Blue (mA) | Red, Blue (V) | Green (mA) | Green (V) |
|-------|---------------:|--------------:|-----------:|----------:|
| WHITE LEVEL | 19.05 | 0.714 | 26.67 | 1.000 |
| BLACK LEVEL | 1.44 | 0.054 | 9.05 | 0.340 |
| BLANK LEVEL | 0.00 | 0.000 | 7.62 | 0.286 |
| SYNC LEVEL | — | — | 0.00 | 0.000 |

IRE spacing shown on the waveform (right side of the figure):

- White level to black level: **92.5 IRE**
- Black level to blank level: **7.5 IRE** (setup / pedestal)
- Blank level to sync level: **40 IRE** (sync present on green only)

The drawn waveform shows active video swinging between black and white, dropping to the blank level during the blanking interval, with a sync pulse down to the sync level in the middle of blanking.

*Note:* 75 Ω doubly-terminated load, RSET = 280 Ω, and VREF = 1.235 V. ISYNC is connected to IOG. RS-343A levels and tolerances are assumed on all levels.

***Figure 3. Composite Video Output Waveforms.***

| Description | IOG (mA) | IOR, IOB (mA) | SYNC\* | BLANK\* | DAC Input Data |
|-------------|---------:|--------------:|:------:|:-------:|:--------------:|
| WHITE | 26.67 | 19.05 | 1 | 1 | $FF |
| DATA | data + 9.05 | data + 1.44 | 1 | 1 | data |
| DATA - SYNC | data + 1.44 | data + 1.44 | 0 | 1 | data |
| BLACK | 9.05 | 1.44 | 1 | 1 | $00 |
| BLACK - SYNC | 1.44 | 1.44 | 0 | 1 | $00 |
| BLANK | 7.62 | 0 | 1 | 0 | $xx |
| SYNC | 0 | 0 | 0 | 0 | $xx |

*Note:* Typical with full-scale IOG = 26.67 mA. RSET = 280 Ω and VREF = 1.235 V. ISYNC is connected to IOG.

***Table 4. Video Output Truth Table.***

**Page 4-7**

---

# Pin Descriptions

*(source page 6)*

| Pin Name | Description |
|----------|-------------|
| BLANK\* | Composite blank control input (TTL compatible). A logical zero drives the IOR, IOG, and IOB outputs to the blanking level, as specified in Table 4. BLANK\* is latched on the rising edge of CLOCK. When BLANK\* is a logical zero, the pixel and overlay inputs are ignored. |
| SYNC\* | Composite sync control input (TTL compatible). A logical zero on this input switches off a 40 IRE current source on the ISYNC output (see Figure 3). SYNC\* does not override any other control or data input, as shown in Table 4; therefore, SYNC\* should be asserted only during the blanking interval. SYNC\* is latched on the rising edge of CLOCK. |
| CLOCK | Clock input (TTL compatible). The rising edge of CLOCK latches the P0–P7, OL0, OL1, SYNC\*, and BLANK\* inputs. It is typically the pixel clock rate of the video system. It is recommended that CLOCK be driven by a dedicated TTL buffer to avoid reflection-induced jitter. |
| P0–P7 | Pixel select inputs (TTL compatible). These inputs specify, on a pixel basis, which 1 of the 256 entries in the color palette RAM is to be used to provide color information. They are latched on the rising edge of CLOCK. P0 is the LSB. Unused inputs should be connected to GND. |
| OL0, OL1 | Overlay select inputs (TTL compatible). These inputs specify which palette is to be used to provide color information, as specified in Table 3. When accessing the overlay palette, the P0–P7 inputs are ignored. They are latched on the rising edge of CLOCK. OL0 is the LSB. Unused inputs should be connected to GND. |
| IOR, IOG, IOB | Red, green, and blue current outputs. These high-impedance current sources can directly drive a doubly-terminated 75 Ω coaxial cable (Figure 4 in the PC Board Layout Considerations section). All outputs, whether used or not, should have the same output load. |
| ISYNC | Sync current output. This high-impedance current source is typically connected directly to the IOG output (Figure 4) and is used to encode sync information onto the green channel. ISYNC does not output any current while SYNC\* is a logical zero. The amount of current output while SYNC\* is a logical one is:<br><br>`ISYNC (mA) = 1,728 * VREF (V) / RSET (Ω)`<br><br>If sync information is not required on the green channel, this output should be connected to GND. |
| FS ADJUST | Full-scale adjust control. A resistor (RSET) connected between this pin and GND controls the magnitude of the full-scale video signal (Figure 4). The IRE relationships in Figure 3 are maintained, regardless of the full-scale output current.<br><br>The relationship between RSET and the full-scale output current on IOG is (assuming ISYNC is connected to IOG):<br><br>`RSET (Ω) = 6,047 * VREF (V) / IOG (mA)`<br><br>The relationship between RSET and the full-scale output current on IOR and IOB is:<br><br>`IOR, IOB (mA) = 4,319 * VREF (V) / RSET (Ω)` |

**Page 4-8**

---

# Pin Descriptions (continued)

*(source page 7)*

| Pin Name | Description |
|----------|-------------|
| COMP | Compensation pin. This pin provides compensation for the internal reference amplifier. A 0.1 µF ceramic capacitor must be connected between this pin and VAA (Figure 4). The COMP capacitor must be as close to the device as possible to keep lead lengths to an absolute minimum. *The PC Board Layout Considerations section contains critical layout criteria.* |
| VREF | Voltage reference input. An external voltage reference circuit, such as that shown in Figure 4, must supply this input with a 1.2 V (typical) reference. The Bt453 has an internal pullup resistor between VREF and VAA. As the value of this resistor may vary slightly with process variations, the use of a resistor divider network to generate the reference voltage is not recommended. A 0.1 µF ceramic capacitor is used to decouple this input to VAA, as shown in Figure 4. If VAA is excessively noisy, better performance may be obtained by decoupling VREF to GND. The decoupling capacitor must be as close to the device as possible to keep lead lengths to an absolute minimum. Refer to the PC Board Layout Considerations section for critical layout criteria. |
| VAA | Analog power. All VAA pins must be connected together on the same PCB plane to prevent latchup. Refer to the PC Board Layout Considerations section for critical layout criteria. |
| GND | Analog ground. All GND pins must be connected together on the same PCB plane to prevent latchup. Refer to the PC Board Layout Considerations section for critical layout criteria. |
| CS\* | Chip select control input (TTL compatible). This input must be a logical zero to enable data to be written to or read from the device. While CS\* is a logical zero, the IOR, IOG, and IOB outputs are forced to the black level. The Bt453 will not function correctly while CS\*, RD\*, and WR\* are simultaneously a logical zero. |
| WR\* | Write control input (TTL compatible). To write data to the device, both CS\* and WR\* must be a logical zero. Data is latched on the rising edge of WR\* or CS\*, whichever occurs first (see Figure 1). |
| RD\* | Read control input (TTL compatible). To read data from the device, both CS\* and RD\* must be a logical zero (see Figure 1). |
| C0, C1 | Command control inputs (TTL compatible). C0 and C1 specify the type of read or write operation being performed, as listed in Table 1. |
| D0–D7 | Data bus (TTL compatible). Data is transferred into and out of the device over this 8-bit bidirectional data bus. D0 is the least significant bit. |

**Page 4-9**

---

# Pin Descriptions (continued)

*(source page 8)*

*(Package pinout drawings transcribed as tables.)*

## 40-pin DIP Package

| Pin | Name | | Pin | Name |
|----:|------|-|----:|------|
| 1 | D0 | | 40 | FS ADJUST |
| 2 | D1 | | 39 | VREF |
| 3 | D2 | | 38 | VAA |
| 4 | D3 | | 37 | COMP |
| 5 | D4 | | 36 | IOR |
| 6 | D5 | | 35 | IOG |
| 7 | D6 | | 34 | ISYNC |
| 8 | D7 | | 33 | IOB |
| 9 | GND | | 32 | GND |
| 10 | VAA | | 31 | VAA |
| 11 | P7 | | 30 | VAA |
| 12 | P6 | | 29 | VAA |
| 13 | P5 | | 28 | WR\* |
| 14 | P4 | | 27 | RD\* |
| 15 | P3 | | 26 | CS\* |
| 16 | P2 | | 25 | C1 |
| 17 | P1 | | 24 | C0 |
| 18 | P0 | | 23 | CLOCK |
| 19 | OL1 | | 22 | SYNC\* |
| 20 | OL0 | | 21 | BLANK\* |

## 44-pin Plastic J-Lead (PLCC) Package

| Pin | Name | Pin | Name | Pin | Name | Pin | Name |
|----:|------|----:|------|----:|------|----:|------|
| 1 | D0 | 12 | VAA | 23 | BLANK\* | 34 | VAA |
| 2 | D1 | 13 | P7 | 24 | SYNC\* | 35 | GND |
| 3 | D2 | 14 | P6 | 25 | CLOCK | 36 | GND |
| 4 | D3 | 15 | P5 | 26 | C0 | 37 | IOB |
| 5 | D4 | 16 | P4 | 27 | C1 | 38 | ISYNC |
| 6 | D5 | 17 | P3 | 28 | CS\* | 39 | IOG |
| 7 | D6 | 18 | P2 | 29 | RD\* | 40 | IOR |
| 8 | D7 | 19 | P1 | 30 | WR\* | 41 | COMP |
| 9 | GND | 20 | P0 | 31 | VAA | 42 | VAA |
| 10 | GND | 21 | OL1 | 32 | VAA | 43 | VREF |
| 11 | VAA | 22 | OL0 | 33 | VAA | 44 | FS ADJUST |

Physical layout (top view): pins 40–44 and 1–6 run down the left side (IOR at top to D5), pins 7–17 across the bottom (D6 to P3), pins 18–28 up the right side (P2 to CS\*), and pins 29–39 across the top (RD\* at right to IOG at left). Pin 1 (D0) is marked with a dot.

**Page 4-10**

---

# PC Board Layout Considerations

*(source page 9)*

## PC Board Considerations

For optimum performance of the Bt453, proper CMOS RAMDAC layout techniques should be studied in the Bt451/7/8 Evaluation Module Operation and Measurements, Application Note (AN-16), before PC board layout is begun. This application note can be found in Brooktree's *Applications Handbook*.

The layout should be optimized for lowest noise on the Bt453 power and ground planes by providing good decoupling. The trace length between groups of VAA and GND pins should be as short as possible to minimize inductive ringing.

A well-designed power distribution network is critical to eliminating digital switching noise. The ground plane must provide a low-impedance return path for the digital circuits. A PC board with a minimum of four layers is recommended, with layers 1 (top) and 4 (bottom) for signals and layers 2 and 3 for power and ground.

## Component Placement

Components should be placed as close as possible to the associated RAMDAC pin. Whenever possible, components should be placed so traces can be connected point to point.

The optimum layout enables the Bt453 to be located as close as possible to the power supply connector and the video output connector.

## Ground Planes

For optimum performance, a common digital and analog ground plane is recommended.

## Power Planes

Separate digital and analog power planes are recommended. The digital power plane should provide power to all digital logic on the PC board, and the analog power plane should provide power to all Bt453 power pins, VREF circuitry, and COMP and VREF decoupling. There should be at least a 1/8-inch gap between the digital power plane and the analog power plane.

The analog power plane should be connected to the digital power plane (VCC) at a single point through a ferrite bead, as illustrated in Figure 4. This bead should be located within 3 inches of the Bt453. The bead provides resistance to switching currents, acting as a resistance at high frequencies. A low-resistance bead should be used, such as Ferroxcube 5659065-3B, Fair-Rite 2743001111, or TDK BF45-4001.

## Device Decoupling

For optimum performance, all capacitors should be located as close as possible to the device, and the shortest possible leads (consistent with reliable operation) should be used to reduce the lead inductance. Chip capacitors are recommended for minimum lead inductance. Radial lead ceramic capacitors may be substituted for chip capacitors and are better than axial lead capacitors for self-resonance. Values are chosen to have self-resonance above the pixel clock.

### Power Supply Decoupling

The best power supply decoupling performance is obtained with a 0.1 µF ceramic capacitor, decoupling each of the three groups of VAA pins to GND. For operation above 75 MHz, a 0.1 µF capacitor in parallel with a 0.01 µF chip capacitor is recommended. The capacitors should be placed as close as possible to the device VAA and GND pins and connected with short, wide traces.

The 10 µF capacitor shown in Figure 4 is for low-frequency power supply ripple; the 0.1 µF capacitors are for high-frequency power supply noise rejection.

When a linear regulator is used, the power-up sequence must be verified to prevent latchup. A linear regulator is recommended to filter the analog power supply if the power supply noise is greater than or equal to 200 mV. This is especially important when a switching power supply is used, and the switching frequency is close to the raster scan frequency. About 10 percent of the power supply hum and ripple noise less than 1 MHz will couple onto the analog outputs.

### COMP Decoupling

The COMP pin must be decoupled to VAA, typically with a 0.1 µF ceramic capacitor. Low-frequency supply noise will require a larger value. The COMP capacitor must be as close as possible to the COMP and VAA pins. A surface-mount ceramic chip capacitor is preferred for minimal lead inductance. Lead inductance degrades the noise rejection of the circuit. Short, wide traces will also reduce lead inductance.

If the display has a ghosting problem, additional capacitance in parallel with the COMP capacitor may help.

### VREF Decoupling

A 0.1 µF ceramic capacitor should be used to decouple this input to GND.

**Page 4-11**

---

# PC Board Layout Considerations (continued)

*(source page 10)*

## Digital Signal Interconnect

The digital inputs to the Bt453 should be isolated as much as possible from the analog outputs and other analog circuitry. Also, these input signals should not overlay the analog power plane or analog output signals.

Most of the noise on the analog outputs will be caused by excessive edge rates (less than 3 ns), overshoot, undershoot, and ringing on the digital inputs.

The digital edge rates should not be faster than necessary, as feedthrough noise is proportional to the digital edge rates. Lower-speed applications will benefit from using lower-speed logic (3–5 ns edge rates) to reduce data-related noise on the analog outputs.

Transmission lines will mismatch if the lines do not match the source and destination impedance. This will degrade signal fidelity if the line length reflection time is greater than one fourth the signal edge time (refer to Brooktree Application Notes AN-11 and AN-12). Line termination or line-length reduction is the solution. For example, logic edge rates of 2 ns require line lengths of less than 4 inches without use of termination. Ringing may be reduced by damping the line with a series resistor (30–300 Ω). The RS-select inputs and RD\*/WR\* lines must be verified for proper levels with no ringing, undershoot, or overshoot. Ringing on these lines can cause improper operation.

Radiation of digital signals can also be picked up by the analog circuitry. This is prevented by reducing the digital edge rates (rise/fall time), minimizing ringing with damping resistors, and minimizing coupling through PC board capacitance by routing the digital signals at a 90 degree angle to any analog signals.

The clock driver and all other digital devices must be adequately decoupled to prevent noise generated by the digital devices from coupling into the analog circuitry.

## Clock Interfacing

The Bt453 requires a pixel clock with monotonic clock edges for proper operation. Impedance mismatch on the pixel clock line will induce reflections on the pixel clock, which may cause erratic operation.

*The Pixel Clock Pulse Width High Time and Pixel Clock Pulse Width Low Time minimum specifications (see the AC Characteristics section) must not be violated, or erratic operation can occur.*

The pixel clock line must be terminated to prevent impedance mismatch. A series termination of 33–68 Ω placed at the pixel clock driver may be used, or a parallel termination may be used at the pixel clock input to the RAMDAC. A parallel termination of 220 Ω to VCC and 330 Ω to ground will provide a Thevenin equivalent of a 110 Ω termination, which is normally sufficient to absorb reflections. The series or parallel resistor values should be adjusted to provide the optimum clock signal fidelity.

## MPU Control Signal Interfacing

The Bt453 uses the RD\*, WR\*, and RS lines to determine which MPU accesses will take place. Glitches or ringing on any of these lines may cause improper MPU operation. When a VGA controller with edge rate control is used on these lines, a series termination is not necessary. In non-VGA controller application or in applications where the MPU control signals are daisy chained, a series termination, pull-down resistors, or additional capacitance to ground should be used to prevent glitches that could cause improper MPU accesses.

## Analog Signal Interconnect

The Bt453 should be located as close as possible to the output connectors to minimize noise pickup and reflections caused by impedance mismatch.

*The analog outputs are susceptible to crosstalk from digital lines; digital traces must not be routed under or adjacent to the analog output traces.*

To maximize the high-frequency power supply rejection, the video output signals should not overlay the analog power plane.

For maximum performance, the analog video output impedance, cable impedance, and load impedance should be the same. The load resistor connection between the video outputs and GND should be as close as possible to the Bt453 to minimize reflections. Unused analog outputs should be connected to GND.

Analog output video edges exceeding the CRT monitor bandwidth can be reflected, producing cable-length dependent ghosts. Simple pulse filters can reduce high-frequency energy, reducing EMI and noise. The filter impedance must match the line impedance.

## Analog Output Protection

The Bt453 analog output should be protected against high-energy discharges, such as those from monitor arc-over or from hot-switching AC-coupled monitors.

The diode protection circuit shown in Figure 4 can prevent latchup under severe discharge conditions without adversely degrading analog transition times. The 1N4148/9 parts are low-capacitance, fast-switching diodes, which are also available in multiple-device packages (FSA250X or FSA270X) or surface-mountable pairs (BAV99 or MMBD7001).

**Page 4-12**

---

# PC Board Layout Considerations (continued)

*(source page 11)*

### Figure 4. Typical Connection Diagram

*(Schematic described in text.)*

**Power:**

- +5 V (VCC) passes through ferrite bead **L1** onto the **Analog Power Plane**, which connects to the Bt453 **VAA** pins.
- **C1** decouples VCC to GROUND on the supply side of L1; **C7** (10 µF tantalum, polarized) decouples the analog power plane to GROUND on the device side of L1.
- **C2–C4** decouple the VAA pins to **GND**.
- **C6** connects between **COMP** and **VAA**.

**Reference:**

- **Z1** (1.2 V voltage reference) connects from **VREF** to **GND**; **C5** decouples the VREF node to the analog power plane (VAA).
- **RSET** connects from **FS ADJUST** to **GND**.

**Outputs:**

- **IOR**, **IOG**, and **IOB** each have a 75 Ω load resistor (**R1**, **R2**, **R3** respectively) to GND at the device, then run through a protection network (circled "P") to the video connector.
- **ISYNC** is tied directly to **IOG**.

**Protection network ("P") detail:** the DAC output line runs to the monitor; one 1N4148/9 diode clamps it to **VAA** (anode on the signal, cathode to VAA) and a second 1N4148/9 clamps it to **GND** (anode to GND, cathode on the signal).

| Location | Description | Vendor Part Number |
|----------|-------------|--------------------|
| C1–C6 | 0.1 µF ceramic capacitor | Erie RPE112Z5U104M50V |
| C7 | 10 µF tantalum capacitor | Mallory CSR13G106KM |
| L1 | ferrite bead | Fair-Rite 2743001111 |
| R1, R2, R3 | 75 Ω 1% metal film resistor | Dale CMF-55C |
| RSET | 280 Ω 1% metal film resistor | Dale CMF-55C |
| Z1 | 1.2 V voltage reference | National Semiconductor LM385BZ-1.2 |

*Note:* The vendor numbers above are listed only as a guide. Substitution of devices with similar characteristics will not affect the performance of the Bt453.

***Figure 4. Typical Connection Diagram and Parts List.***

**Page 4-13**

---

# Recommended Operating Conditions

*(source page 12)*

| Parameter | Symbol | Min | Typ | Max | Units |
|-----------|--------|----:|----:|----:|-------|
| Power Supply | VAA | 4.75 | 5.00 | 5.25 | V |
| Ambient Operating Temperature | TA | 0 | | +70 | °C |
| Output Load | RL | | 37.5 | | Ω |
| Reference Voltage | VREF | 1.14 | 1.235 | 1.26 | V |
| FS ADJUST Resistor | RSET | | 280 | | Ω |

# Absolute Maximum Ratings

| Parameter | Symbol | Min | Typ | Max | Units |
|-----------|--------|----:|----:|----:|-------|
| VAA (measured to GND) | | | | 7.0 | V |
| Voltage on Any Signal Pin (Note 1) | | GND–0.5 | | VAA + 0.5 | V |
| Analog Output Short Circuit Duration to Any Power Supply or Common | ISC | | indefinite | | |
| Ambient Operating Temperature | TA | –55 | | +125 | °C |
| Storage Temperature | TS | –65 | | +150 | °C |
| Junction Temperature — Ceramic Package | TJ | | | +175 | °C |
| Junction Temperature — Plastic Package | TJ | | | +150 | °C |
| Soldering Temperature (5 seconds, 1/4" from pin) | TSOL | | | 260 | °C |
| Vapor Phase Soldering (1 minute) | TVSOL | | | 220 | °C |

Stresses above those listed under "Absolute Maximum Ratings" may cause permanent damage to the device. This is a stress rating only, and functional operation of the device at these or any other conditions above those listed in the operational sections of this specification is not implied. Exposure to absolute maximum rating conditions for extended periods may affect device reliability.

*Note 1:* This device employs high-impedance CMOS devices on all signal pins. It should be handled as an ESD-sensitive device. Voltage on any signal pin that exceeds the power supply voltage by more than +0.5 V can induce destructive latchup.

**Page 4-14**

---

# DC Characteristics

*(source page 13)*

| Parameter | Symbol | Min | Typ | Max | Units |
|-----------|--------|----:|----:|----:|-------|
| Resolution (each DAC) | | 8 | 8 | 8 | Bits |
| **Accuracy (each DAC)** | | | | | |
| &nbsp;&nbsp;Integral Linearity Error | IL | | | ±1 | LSB |
| &nbsp;&nbsp;Differential Linearity Error | DL | | | ±1 | LSB |
| &nbsp;&nbsp;Gray-Scale Error | | | | ±5 | % Gray Scale |
| &nbsp;&nbsp;Monotonicity | | | guaranteed | | |
| Coding | | | | | Binary |
| **Digital Inputs** | | | | | |
| &nbsp;&nbsp;Input High Voltage | VIH | 2.0 | | VAA + 0.5 | V |
| &nbsp;&nbsp;Input Low Voltage | VIL | GND–0.5 | | 0.8 | V |
| &nbsp;&nbsp;Input High Current (Vin = 2.4 V) | IIH | | | 1 | µA |
| &nbsp;&nbsp;Input Low Current (Vin = 0.4 V) | IIL | | | –1 | µA |
| &nbsp;&nbsp;Input Capacitance (f = 1 MHz, Vin = 2.4 V) | CIN | | 10 | | pF |
| **Digital Outputs** | | | | | |
| &nbsp;&nbsp;Output High Voltage (IOH = –400 µA) | VOH | 2.4 | | | V |
| &nbsp;&nbsp;Output Low Voltage (IOL = 3.2 mA) | VOL | | | 0.4 | V |
| &nbsp;&nbsp;3-State Current | IOZ | | | 10 | µA |
| &nbsp;&nbsp;Output Capacitance | CDOUT | | 20 | | pF |
| **Analog Outputs** | | | | | |
| &nbsp;&nbsp;Gray-Scale Current Range | | 15 | | 22 | mA |
| &nbsp;&nbsp;Output Current: | | | | | |
| &nbsp;&nbsp;&nbsp;&nbsp;White Level Relative to Blank | | 17.69 | 19.05 | 20.40 | mA |
| &nbsp;&nbsp;&nbsp;&nbsp;White Level Relative to Black | | 16.74 | 17.62 | 18.50 | mA |
| &nbsp;&nbsp;&nbsp;&nbsp;Black Level Relative to Blank | | 0.95 | 1.44 | 1.90 | mA |
| &nbsp;&nbsp;&nbsp;&nbsp;Blank Level on IOR, IOB | | 0 | 5 | 50 | µA |
| &nbsp;&nbsp;&nbsp;&nbsp;Blank Level on IOG | | 6.29 | 7.62 | 8.96 | mA |
| &nbsp;&nbsp;&nbsp;&nbsp;Sync Level on IOG | | 0 | 5 | 50 | µA |
| &nbsp;&nbsp;&nbsp;&nbsp;LSB Size | | | 69.1 | | µA |
| &nbsp;&nbsp;DAC-to-DAC Matching (25–70 °C) | | | 2 | 5 | % |
| &nbsp;&nbsp;Output Compliance | VOC | –1.0 | | +1.4 | V |
| &nbsp;&nbsp;Output Impedance | RAOUT | | 10 | | kΩ |
| &nbsp;&nbsp;Output Capacitance (f = 1 MHz, IOUT = 0 mA) | CAOUT | | 30 | | pF |
| Voltage Reference Input Current | IREF | | 10 | | µA |
| Power Supply Rejection Ratio (COMP = 0.1 µF, f = 1 kHz) | PSRR | | 0.12 | 0.5 | % / % ΔVAA |

Test conditions (unless otherwise specified): "Recommended Operating Conditions" with RSET = 280 Ω, VREF = 1.235 V, and ISYNC connected to IOG. As the above parameters are guaranteed over the full temperature range, temperature coefficients are not specified or required. Typical values are based on nominal temperature, i.e., room temperature, and nominal voltage, i.e., 5 V.

**Page 4-15**

---

# AC Characteristics

*(source page 14)*

| Parameter | Symbol | 66 MHz Min | 66 MHz Typ | 66 MHz Max | 40 MHz Min | 40 MHz Typ | 40 MHz Max | Units |
|-----------|:------:|---:|---:|---:|---:|---:|---:|-------|
| Clock Rate | Fmax | | | 66 | | | 40 | MHz |
| CS\*, C0, C1 Setup Time | 1 | 35 | | | 35 | | | ns |
| CS\*, C0, C1 Hold Time | 2 | 35 | | | 35 | | | ns |
| RD\*, WR\* High Time | 3 | 25 | | | 25 | | | ns |
| RD\* Asserted to Data Bus Driven | 4 | 5 | | | 5 | | | ns |
| RD\* Asserted to Data Valid | 5 | | | 100 | | | 100 | ns |
| RD\* Negated to Data Bus 3-Stated | 6 | | | 15 | | | 15 | ns |
| WR\* Low Time | 7 | 50 | | | 50 | | | ns |
| Write Data Setup Time | 8 | 35 | | | 35 | | | ns |
| Write Data Hold Time | 9 | 5 | | | 5 | | | ns |
| Pixel and Control Setup Time | 10 | 5 | | | 7 | | | ns |
| Pixel and Control Hold Time | 11 | 2 | | | 3 | | | ns |
| Clock Cycle Time | 12 | 15 | | | 25 | | | ns |
| Clock Pulse Width High Time | 13 | 5 | | | 7 | | | ns |
| Clock Pulse Width Low Time | 14 | 5 | | | 7 | | | ns |
| Analog Output Delay | 15 | | 20 | 30 | | 20 | 30 | ns |
| Analog Output Rise/Fall Time | 16 | | 3 | | | 3 | | ns |
| Analog Output Settling Time (Note 1) | 17 | | 25 | | | 25 | | ns |
| Clock and Data Feedthrough (Note 1) | | | –48 | | | –48 | | dB |
| Glitch Impulse (Note 1) | | | 50 | | | 50 | | pV-sec |
| DAC-to-DAC Crosstalk | | | –22 | | | –22 | | dB |
| Analog Output Skew | | | 1 | 2 | | 1 | 2 | ns |
| Pipeline Delay | 18 | 2 | 2 | 2 | 2 | 2 | 2 | Clocks |
| VAA Supply Current (Note 2) | IAA | | 220 | 275 | | 190 | 250 | mA |

Test conditions (unless otherwise specified): "Recommended Operating Conditions" with RSET = 280 Ω, VREF = 1.235 V, and ISYNC connected to IOG. TTL input values are 0–3 V with input rise/fall times ≤ 4 ns, measured between the 10-percent and 90-percent points. Timing reference points at 50 percent for inputs and outputs. Analog output load ≤ 10 pF and D0–D7 output load ≤ 75 pF. See timing waveforms and notes in Figures 5 and 6. As the above parameters are guaranteed over the full temperature range, temperature coefficients are not specified or required. Typical values are based on nominal temperature, i.e., room temperature, and nominal voltage, i.e., 5 V.

*Note 1:* Clock and data feedthrough is a function of the number of edge rates, and the amount of overshoot and undershoot on the digital inputs. For this test, the digital inputs have a 1 kΩ resistor to ground and are driven by 74HC logic. Settling time does not include clock and data feedthrough. Glitch impulse includes clock and data feedthrough, and –3 dB test bandwidth = 2x clock rate.

*Note 2:* At Fmax. IAA (typ) at VAA = 5.0 V. IAA (max) at VAA = 5.25 V.

**Page 4-16**

---

# Timing Waveforms

*(source page 15)*

*(Timing diagrams described in text. Numbers refer to the Symbol column of the AC Characteristics table.)*

### Figure 5. MPU Read/Write Timing Dimensions

| # | Parameter | Measured between |
|--:|-----------|------------------|
| 1 | CS\*, C0, C1 Setup Time | CS\*/C0/C1 becoming VALID → RD\*/WR\* falling edge |
| 2 | CS\*, C0, C1 Hold Time | RD\*/WR\* rising edge → CS\*/C0/C1 changing |
| 3 | RD\*, WR\* High Time | RD\*/WR\* rising edge → next falling edge |
| 4 | RD\* Asserted to Data Bus Driven | RD\* falling edge → D0–D7 leaves high-impedance |
| 5 | RD\* Asserted to Data Valid | RD\* falling edge → DATA OUT (RD\* = 0) valid |
| 6 | RD\* Negated to Data Bus 3-Stated | RD\* rising edge → D0–D7 returns to high-impedance |
| 7 | WR\* Low Time | WR\* falling edge → WR\* rising edge |
| 8 | Write Data Setup Time | DATA IN (WR\* = 0) valid → WR\* rising edge |
| 9 | Write Data Hold Time | WR\* rising edge → DATA IN changing |

***Figure 5. MPU Read/Write Timing Dimensions.***

### Figure 6. Video Input/Output Timing

| # | Parameter | Measured between |
|--:|-----------|------------------|
| 12 | Clock Cycle Time | rising edge → next rising edge of CLOCK |
| 13 | Clock Pulse Width High Time | CLOCK high portion of the cycle |
| 14 | Clock Pulse Width Low Time | CLOCK low portion of the cycle |
| 10 | Pixel and Control Setup Time | P0–P7, OL0, OL1, SYNC\*, BLANK\* DATA valid → latching CLOCK rising edge |
| 11 | Pixel and Control Hold Time | latching CLOCK rising edge → DATA changing |
| 18 | Pipeline Delay | latching CLOCK rising edge → CLOCK edge at which the corresponding output begins |
| 15 | Analog Output Delay | CLOCK rising edge → 50% point of IOR/IOG/IOB/ISYNC transition |
| 16 | Analog Output Rise/Fall Time | 10% → 90% of output transition |
| 17 | Analog Output Settling Time | 50% point of output transition → output settled within ±1 LSB |

*Note 1:* Output delay is measured from the 50-percent point of the rising edge of CLOCK to the 50-percent point of full-scale transition.

*Note 2:* Settling time is measured from the 50-percent point of full-scale transition to the output remaining within ±1 LSB.

*Note 3:* Output rise/fall time is measured between the 10-percent and 90-percent points of full-scale transition.

***Figure 6. Video Input/Output Timing.***

**Page 4-17**

---

# Ordering Information

*(source page 16)*

| Model Number | Speed | Package | Ambient Temperature Range |
|--------------|-------|---------|---------------------------|
| Bt453KP66 | 66 MHz | 40-pin 0.6" Plastic DIP | 0° to +70° C |
| Bt453KPJ66 | 66 MHz | 44-pin Plastic J-Lead | 0° to +70° C |
| Bt453KC66 | 66 MHz | 40-pin 0.6" CERDIP | 0° to +70° C |
| Bt453KC | 40 MHz | 40-pin 0.6" CERDIP | 0° to +70° C |
| Bt453KP | 40 MHz | 40-pin 0.6" Plastic DIP | 0° to +70° C |
| Bt453KPJ | 40 MHz | 44-pin Plastic J-Lead | 0° to +70° C |

**Page 4-18**

---

# Device Circuit Data

*(source page 17)*

### Equivalent Circuit of the Reference Amplifier

*(Schematic described in text.)*

- **VREF** pin connects through a **1 kΩ** internal pullup resistor to **VAA**, and through a **500 Ω** series resistor to the **inverting (–)** input of the reference op-amp.
- **FS ADJUST** pin connects through a **500 Ω** series resistor to the **non-inverting (+)** input of the op-amp.
- Protection diodes clamp the VREF and FS ADJUST nodes to VAA, and the op-amp inputs to GND.
- The op-amp output drives a current-mirror/output device that sends reference current **TO DACS**; an **IFEEDBACK** path returns to the FS ADJUST node (which is loaded externally by RSET to GND).
- The amplifier is powered from **VAA** and **GND**.

***Equivalent Circuit of the Reference Amplifier.***

### Equivalent Circuit of the Current Output (IOG)

*(Schematic described in text.)*

- Inside the Bt453, three groups of switched current sources hang from **VAA** and sum onto the **IOG** output node:
  - a sync current source switched by **SYNC\*** (IOG only),
  - a blank/setup current source switched by **BLANK\***,
  - the weighted data current sources switched by **G0–G7** (the green palette data bits).
- The IOG node has approximately **30 pF** of internal capacitance to ground.
- Externally, IOG is loaded by **RL** to ground and by **C(stray + load)**.

***Equivalent Circuit of the Current Output (IOG).***

**Page 4-19**
