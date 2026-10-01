# Hitachi HD63484 Advanced CRT Controller (ACRTC) — Datasheet

*Converted from a 47-page scanned PDF (source pages 213–259) via OCR/transcription. Diagrams (block diagrams, timing diagrams, pinouts, waveform figures) are described in words rather than reproduced graphically. Per-page footers (the HITACHI wordmark and Hitachi America address/phone line) have been removed; page numbers are retained via the "(source page NNN)" markers.*

*Revision note: Figure 5's register bit-field tables (pages 222–225), Table 1's DN field (page 226), and Table 4's command opcode table (page 232) were re-scanned and corrected after an initial pass approximated several bit-field boundaries instead of measuring them. The corrections were independently verified by pixel-measuring the divider lines in the source page images against the 16-bit ruler grid. See the "Re-scanned and corrected" notes inline at each affected table.*

---
## HD63484
# Advanced CRT Controller (ACRTC)

*(source page 213)*

The advanced CRT controller (ACRTC) CMOS VLSI microcomputer peripheral device can display both graphics and characters on raster-scan displays. It is a new generation CRT controller based on bitmapped technology. It executes high-level commands, like Line, Ellipse, Paint, Pattern, and Copy, issued by the MPU in screen X-Y coordinates, and performs the address translation necessary to draw into frame memory. It can draw in up to 64k colors, on three split screens and an independent window, and perform area clipping and hitting.

The ACRTC controls a CRT in one of three modes: character only, graphics only, and multiplexed character/graphics modes. Therefore, the ACRTC has many applications, from character-only displays to large full-graphics systems.

The ACRTC reduces CPU software overhead and enhances system throughput.

### Features

- High-speed graphics
  - Drawing rate: 408 ns/pixel max (color drawing)
  - Commands: 38 commands including 23 graphic drawing commands
    Dot, Line, Rectangle, Poly-line, Polygon, Circle, Ellipse, Paint, Copy, etc.
- Colors: 16 bits/word
  1, 2, 4, 8, 16 bits/pixel (5 types)
  Monochrome to 64k colors max
- Pattern RAM: 32 bytes
- Converts logical X-Y coordinates to physical address
- Color operation and conditional drawing
- Drawing area control for hardware clipping and hitting
- Large frame-memory space
  - Maximum 2 Mbytes graphic memory and 128 kbytes character memory separate from the MPU memory
  - Maximum resolution: 4096x4096 pixels (1 bit/pixel mode)
- CRT display control
  - Split screens: three displays and one window
  - Zoom: 1 to 16 times
  - Scroll: vertical and horizontal
- Interleaved access mode for flashless display and superimposition
- External synchronization between ACRTCs or between ACRTC and external device (TV system or other controller)
- DMA interface
- Two programmable cursors
- Three scan modes
  - Non-interlaced
  - Interlace sync
  - Interlace sync and video
- Interrupt request to MPU
- 256 characters/line 32 raster/line, 4096 rasters/screen
- Maximum clock frequency: 9.8 MHz
- CMOS, single +5 V power supply

### Ordering Information

| Part No. | Clock Frequency (2CLK) | Package |
|---|---|---|
| HD63484-4 | 4 MHz | DC-64 |
| HD63484-6 | 6 MHz | (64-pin ceramic DIP) |
| HD63484-8 | 8 MHz | |
| HD63484-98 | 9.8 MHz | |
| HD63484P4 | 4 MHz | DP-64 |
| HD63484P6 | 6 MHz | (64-pin plastic DIP) |
| HD63484P8 | 8 MHz | |
| HD63484P98 | 9.8 MHz | |
| HD63484CP4 | 4 MHz | CP-68 |
| HD63484CP6* | 6 MHz | (68-pin plastic PLCC) |
| HD63484CP8 | 8 MHz | |
| HD63484CP98 | 9.8 MHz | |
| HD63484Y4 | 4 MHz | PC-68 |
| HD63484Y6 | 6 MHz | (68-pin PGA) |
| HD63484Y8 | 8 MHz | |
| HD63484Y98 | 9.8 MHz | |
| HD63484PS4 | 4 MHz | DP-64S |
| HD63484PS6 | 6 MHz | (64-pin plastic shrink DIP) |
| HD63484PS8 | 8 MHz | |
| HD63484PS98 | 9.8 MHz | |

Note: Wide temperature range (-40C to +80C) version is available.

HITACHI

Hitachi America, Ltd. • Hitachi Plaza • 2000 Sierra Point Pkwy. • Brisbane, CA 94005-1819 • (415) 589-8300

---

## HD63484

*(source page 214)*

**Figure: HD63484Y package pinout (PGA, 68-pin), Top View and Bottom View.** Top view shows the die orientation with Pin 1 marked at the upper-left corner. Bottom view shows the pin grid array (68 pins arranged around the perimeter in a square grid).

**Pin No. / Pin Name table (PGA):**

| Pin No. | Pin Name | Pin No. | Pin Name | Pin No. | Pin Name | Pin No. | Pin Name |
|---|---|---|---|---|---|---|---|
| 1 | MAD₁₄ (T) | 18 | RS | 35 | MA₁₈/RA₂ | 52 | DREQ̄ |
| 2 | MAD₁₁ (T) | 19 | DTACK (T) | 36 | MA₁₉/RA₃ | 53 | HSYNC̄ |
| 3 | MAD₉ (T) | 20 | IRQ̄ (O,D) | 37 | MAD₁₃ (T) | 54 | EXSYNC̄ |
| 4 | MAD₈ (T) | 21 | VSYNC̄ | 38 | MAD₁₀ (T) | 55 | D₀ (T) |
| 5 | MAD₆ (T) | 22 | Vcc | 39 | MAD₇ (T) | 56 | D₄ (T) |
| 6 | Vcc | 23 | Vss | 40 | MAD₆ (T) | 57 | D₃ (T) |
| 7 | Vss | 24 | Vss | 41 | 2CLK | 58 | D₅ (T) |
| 8 | Vss | 25 | D₁ (T) | 42 | MCYC | 59 | D₉ (T) |
| 9 | AS̄ | 26 | D₂ (T) | 43 | DRAW̄ | 60 | D₁₁ (T) |
| 10 | MRD̄ | 27 | D₆ (T) | 44 | MAD₄ (T) | 61 | D₁₄ (T) |
| 11 | MAD₃ (T) | 28 | D₈ (T) | 45 | MAD₂ (T) | 62 | RA₄ |
| 12 | MAD₁ (T) | 29 | D₁₀ (T) | 46 | MAD₅ (T) | 63 | MA₁₇/RA₁ |
| 13 | DISP̄₂ | 30 | D₁₂ (T) | 47 | DISP̄₁ | 64 | MAD₁₅ (T) |
| 14 | LPSTB | 31 | D₁₃ (T) | 48 | CUD̄₁ | 65 | MAD₁₂ (T) |
| 15 | Vcc | 32 | D₁₅ (T) | 49 | CS̄ | 66 | CHR |
| 16 | CUD̄₂ | 33 | Vss | 50 | RES̄ | 67 | DACK̄ |
| 17 | R/W̄ | 34 | MA₁₆/RA₀ | 51 | DONĒ (O,D) | 68 | D₇ |

### Pin Arrangement

**Figure: Two DIP/PLCC pinout diagrams side by side.**

Left diagram — **HD63484, HD63484P, HD63484PS** (64-pin DIP), pins 1–32 on the left side (top to bottom): CUD̄1, CUD̄2, R/W̄, CS̄, RS, RES̄, DONĒ(O,D), DREQ̄, DACK̄, DTACK(T), IRQ̄(O,D), HSYNC̄, VSYNC̄, Vcc, EXSYNC̄, Vss, D₀(T), D₁(T), D₇(T), D₃(T), D₄(T), D₅(T), D₆(T), D₇(T), D₈(T), D₉(T), D₁₀(T), D₁₁(T), D₁₂(T), D₁₃(T), D₁₄(T), D₁₅(T); pins 64–33 on the right side (top to bottom): LPSTB, DISP̄1, DISP̄2, MAD₀(T), MAD₁(T), MAD₂(T), MAD₃(T), MAD₄(T), CHR, MRD̄, DRAW̄, AS̄, MCYC, 2CLK, Vcc, MAD₅(T), MAD₆(T), MAD₇(T), MAD₈(T), MAD₉(T), MAD₁₀(T), MAD₁₁(T), MAD₁₂(T), MAD₁₃(T), MAD₁₄(T), MAD₁₅(T), MA₁₆/RA₀, MA₁₇/RA₁, MA₁₈/RA₂, MA₁₉/RA₃, RA₄.

Right diagram — **HD63484CP** (68-pin PLCC), pins numbered 1–68 around all four edges. Top edge (left to right): DREQ̄, DONĒ(O,D), RES̄, RS, CS̄, R/W̄, CUD̄2, CUD̄1, Vcc, DISP̄1, DISP̄2, MAD₀(T), MAD₁(T), MAD₂(T), MAD₃(T), MAD₄(T). Left edge (top to bottom, pins 10–26): DACK̄, DTACK(T), IRQ̄(O,D), HSYNC̄, VSYNC̄, Vcc, EXSYNC̄, Vss, Vss, D₀(T), D₁(T), D₂(T), D₃(T), D₄(T), D₅(T), D₆(T), D₇(T). Bottom edge (pins 27–43, left to right): D₈(T), D₉(T), D₁₀(T), D₁₁(T), D₁₂(T), D₁₃(T), D₁₄(T), D₁₅(T), Vss, RA₄, MA₁₆/RA₀, MA₁₇/RA₁, MA₁₈/RA₂, MA₁₉/RA₃, MAD₁₅(T), MAD₁₄(T), MAD₁₃(T). Right edge (pins 44–59, bottom to top): MAD₁₂(T), MAD₁₁(T), MAD₁₀(T), MAD₉(T), MAD₈(T), MAD₇(T), MAD₆(T), MAD₅(T), Vcc, 2CLK, Vss, Vss, AS̄, DRAW̄, MRD̄, CHR (pin 59), MRD̄ (pin 59 label per diagram), pins 60 CHR is at top-right corner near pin 60. (Index arrow marks pin-1 corner.)

O,D: Open drain
T: Three state

---

## HD63484

*(source page 215)*

### Pin Description

| Group | Mnemonic | Pin Number DIP | Pin Number PLCC | Pin Number PGA | I/O | Function |
|---|---|---|---|---|---|---|
| MPU Interface | RES̄ | 6 | 7 | 50 | I | ACRTC reset |
| | D₀-D₁₅* | 17-32 | 19-34 | 25-32, 55-61, 68 | I/O | Data bus (three state) |
| | R/W̄ | 3 | 4 | 17 | I | Read/write strobe |
| | CS̄ | 4 | 5 | 49 | I | Chip select |
| | RS | 5 | 6 | 18 | I | Register select |
| | DTACK̄ | 10 | 11 | 19 | O | Data transfer acknowledge (three state) |
| | IRQ̄ | 11 | 12 | 20 | O | Interrupt request (open drain) |
| DMAC Interface | DREQ̄ | 8 | 9 | 52 | O | DMA request |
| | DACK̄ | 9 | 10 | 67 | I | DMA acknowledge |
| | DONĒ | 7 | 8 | 51 | I/O | DMA done (open drain) |
| CRT Interface | 2CLK | 50 | 53 | 41 | I | ACRTC clock |
| | MAD₀-MAD₁₅* | 61-57, 48-38 | 65-61, 51-41 | 1-5, 11,12, 37-40,44-46, 64, 65 | I/O | Multiplexed frame buffer address/data bus |
| | AS̄ | 53 | 57 | 9 | O | Address strobe |
| | MA₁₆/RA₀*-MA₁₉/RA₃ | 37-34 | 40-37 | 34-36 | O | Higher-order address bits/character screen raster address |
| | RA₄ | 33 | 36 | 62 | O | High-order character screen raster address bit |
| | CHR | 56 | 60 | 66 | O | Graphic or character screen access |
| | MCYC | 52 | 56 | 42 | O | Frame buffer memory access timing signal |
| | MRD̄ | 55 | 59 | 10 | O | Frame buffer memory read |
| | DRAW̄ | 54 | 58 | 43 | O | Draw/refresh signal |
| | DISP̄1, DISP̄2 | 63, 62 | 67, 66 | 47, 13 | O | Display enable |
| | CUD̄1, CUD̄2 | 1, 2 | 2, 3 | 48, 16 | | Cursor display |
| | VSYNC̄ | 13 | 14 | 21 | O | CRT vertical sync pulse |
| | HSYNC̄ | 12 | 13 | 53 | | CRT horizontal sync pulse |
| | EXSYNC̄ | 15 | 16 | 54 | I/O | External sync |
| | LPSTB | 64 | 68 | 14 | I | Lightpen strobe |
| Power Supply | Vcc | 14, 49 | 1, 15, 52 | 6, 15, 22 | | +5 V |
| | Vss | 16, 51 | 17, 18, 35, 54, 55 | 7, 8, 23, 24, 33 | | Ground |

\*: PGA pin numbers don't correspond to D₀-D₁₅, MAD₀-MAD₁₅, MA₁₆/RA₀-MA₁₉/RA₃. Please refer to the pin arrangement.

---

## HD63484

*(source page 216)*

**MPU Interface**

**RES̄ (Reset):** RES̄ is the MPU hardware reset.

**D₀-D₁₅ (Data Bus):** D₀-D₁₅ are the bidirectional data bus to/from the host MPU or DMAC. D₀-D₇ are used in 8-bit data bus mode.

**R/W̄ (Read/Write):** R/W̄ input controls the direction of host/ACRTC transfers.

**CS̄ (Chip Select):** CS̄ input enables transfers between the host and the ACRTC.

**RS (Register Select):** RS input selects the ACRTC register to be accessed. It is usually connected to the least significant bit of the host address bus.

**DTACK̄ (Data Transfer Acknowledge):** DTACK̄ output provides asynchronous bus cycle timing. It is compatible with the HD68000 MPU DTACK̄ output.

**IRQ̄ (Interrupt Request):** IRQ̄ output generates interrupt service requests to the host MPU.

**DMAC Interface**

**DREQ̄ (DMA Acknowledge):** DACK̄ receives DMA acknowledge timing from the host DMAC.

**DONĒ (DMA Done):** DONĒ terminates DMA transfer. It is compatible with the HD68450 DMAC DONĒ signal.

**CRT Interface**

**2CLK (Dot Clock):** 2CLK is the basic ACRTC operating clock, twice the frequency of the dot clock.

**MAD₀-MAD₁₅ (Frame Memory Address/Data Bus):** MAD₀-MAD₁₅ are the multiplexed frame buffer address/data bus.

**AS̄ (Address Strobe):** The AS̄ output demultiplexes the address/data bus (MAD₀-MAD₁₅).

**MA₁₆/RA₀-MA₁₉/RA₃ (Memory Address/Raster Address):** MA₁₆/RA₀-MA₁₉/RA₃ are the upper bits of the graphics screen address multiplexed with the lower bits of the character screen raster address.

**RA₄ (Raster Address):** RA₄ is the high bit of the character screen raster address (up to 32 rasters).

**CHR (Character):** CHR output indicates whether a graphic or character screen is being accessed.

**MCYC (Memory Cycle):** MCYC is the frame buffer memory access timing output, one-half the frequency of 2CLK.

**MRD̄ (Memory Read):** MRD̄ output controls the frame buffer data bus direction.

**DRAW̄ (Draw):** DRAW̄ output differentiates between drawing and CRT display refresh cycles.

**DISP̄1, DISP̄2 (Display 1, 2):** The DISP̄1 and DISP̄2 programmable display enable outputs can enable, disable, and blank logical screens.

**CUD̄1, CUD̄2 (Cursor Display 1, 2):** CUD̄1 and CUD̄2 outputs provides cursor timing programmed by ACRTC parameters such as cursor definition, cursor mode, cursor address, etc.

**VSYNC̄ (Vertical Sync):** VSYNC̄ outputs the CRT vertical synchronization pulse.

**HSYNC̄ (Horizontal Sync):** HSYNC̄ outputs the CRT horizontal synchronization pulse.

**EXSYNC̄ (External Sync):** EXSYNC̄ allows synchronization between multiple ACRTCs and other video signal generators.

**LPSTB (Lightpen Strobe):** LPSTB is the lightpen input.

### Block Diagrams

**ACRTC Functions**

The ACRTC consists of 5 major functional blocks (figure 1). They operate in parallel to achieve maximum performance.

**MPU Interface:** The MPU interface interfaces asynchronously with the host MPU. Its functions include programmable interrupts handling, and DMA handshaking control.

**CRT Interface:** The CRT interface manages the frame buffer bus and the CRT timing input and output control signals. It also selects display refresh or drawing address outputs.

---

## HD63484

*(source page 217)*

**Drawing Processor:** The drawing processor interprets commands and command parameters issued by the host bus (MPU and/or DMAC) and performs drawing operations on the frame buffer memory. It executes ACRTC drawing algorithms and converts logical X-Y addresses to physical frame buffer addresses.

It communicates with the host bus via separate 16-byte read and write FIFOs.

**Display Processor:** The display processor manages frame buffer refresh addressing based on the user-specified display screen organization. It combines and displays as many as 4 independent screen segments (3 horizontal split screens and 1 window) using an internal high-speed address calculation unit. It controls display refresh outputs in graphic (physical frame buffer address) or character (physical refresh memory address + row address) modes.

**Timing Processor:** The timing processor generates the CRT synchronization signals and signals used internally by the ACRTC.

**Registers:** The ACRTC registers that are visible to software are partitioned in the same way. They reside in the internal processor appropriate to their function. The registers in the display and timing processors are loaded with the basic display parameters during system initialization. During operation, the host communicates primarily with the ACRTC's drawing processor via the on-chip FIFOs.

**High-Speed (= 9.8 MHz) Version of ACRTC**

To keep up with the demand for improvements in the quality and resolution of CRT monitors, Hitachi has introduced a 9.8 MHz version of the HD63484 (ACRTC).

It can be used for:
1. High-resolution displays such as in office workstations, business personal computers, and CAD/CAM displays.
2. Applications requiring faster drawing than the current ACRTC with an 8-MHz 2CLK operation frequency.

**High-Resolution Display**

As shown in figure A, the 9.8-MHz allows the following configurations for a 4-bit/pixel system:
1. CRT monitor with 1024 x 808 dots, +8 DA or +4 SA
2. CRT monitor from 800 x 480 to 960 x 720 dots, +4 DA

**Figure A. ACRTC Operation Frequency and Supportable CRT Display Range** — A chart plotting CRT resolution/dot clock (vertical axis: 840×400, 640×400 (24 MHz), 800×480 (33 MHz), 960×720 (38 MHz), 1024×808 (68 MHz), 1280×1024 (109 MHz)) against ACRTC operation mode (horizontal axis: +8 SA, +8 DA/+4 SA, -4 DA), with diagonal boundary lines for 4 MHz, 6 MHz, 8 MHz, and 9.8 MHz clock rates and a shaded region labeled "4 bits/pixel" showing the supportable range extended by the 9.8 MHz clock. Note: ACRTC operation mode — +4, +8 = Address increment mode; SA = Single Access mode; DA = Dual access mode.

**High-Speed Drawing Support**

The ACRTC drawing speed depends on its operation frequency. Consequently it takes less time to draw with a 9.8-MHz clock than with an 8-MHz clock. Figure B compares drawing capabilities of the 9.8-MHz ACRTC and the 8-MHz ACRTC.

**Figure B. Drawing Capability Comparison between 9.8-MHz and 8-MHz ACRTCs.**

(a) Short vector drawing (50 dots/vector) — bar chart, k vectors/sec.: 8 MHz = 40, 9.8 MHz = 49.

(b) Block transfer of 1k x 1k dots — bar chart, M dots/sec.: 8 MHz = 1.7, 9.8 MHz = 2.1.

Note: Figure B shows the ideal drawing speed where the ACRTC is assumed to perform only drawing.

---

## HD63484

*(source page 218)*

**Figure 1. ACRTC Block Diagram** — Block diagram showing five major functional blocks inside the ACRTC. Left side inputs: RES̄ (into DMA Control Unit/Interrupt Control Unit), DREQ̄/DACK̄/DONĒ (DMA Control Unit), IRQ̄ (Interrupt Control Unit), D₀-D₁₅ (16-bit, into MPU Interface), CS̄/RS/R/W̄/DTACK̄ (MPU Interface). The MPU Interface block feeds Register Address and Data buses to the Drawing Processor, Display Processor, and Timing Processor blocks. The Drawing Processor outputs Drawing Address (20 bits) and Drawing Data (16 bits) and a Draw Enable/Write signal to the CRT Interface. The Display Processor outputs Display Address (20 bits), Raster Address (5 bits), CHR, and CCUD to the CRT Interface, and receives GCUD. The Timing Processor outputs HSYNC, VSYNC, EXSYNC, DISP, MCLK, AS, 2CLK to the CRT Interface. The CRT Interface block outputs DRAW̄, MRD̄, MAD₀-MAD₁₅ (16-bit), MA₁₆/RA₀-MA₁₉/RA₃ (4-bit), RA₄, CHR, LPSTB, CUD̄1/CUD̄2 (2-bit), HSYNC̄, VSYNC̄, EXSYNC̄, DISP̄1/DISP̄2 (2-bit), MCYC, AS̄, 2CLK. Power pins Vcc/Vss (2,3,2,5 grouping) enter at the bottom below the MPU Interface block.

### System Configuration

Current CRT controllers provide a single bus interface to the frame buffer that must be shared with the host MPU. However, refreshing large frame buffers, and accessing the frame buffer for drawing operations can quickly saturate the shared bus.

As shown in figure 2, the ACRTC uses separate host MPU and frame buffer interfaces. This allows the ACRTC full access to the frame buffer for display refresh and drawing operations and minimizes the ACRTC's use of the MPU system bus. A related benefit is that a large frame buffer (2 Mbyte for each ACRTC) can be used, even if the host MPU has a smaller address space or segment size restriction.

The ACRTC can use an external DMA controller. A DMA controller increases system throughput when many commands, parameters, and data must be transferred to the ACRTC. Advanced DMAC features, such as the HD68450 "chaining" modes can be used to develop powerful graphics system architectures.

However, more cost-sensitive or less performance-sensitive applications do not require a DMAC. The interface to the ACRTC can be handled under MPU software control.

While both ACRTC bus interfaces (host MPU and frame buffer) are 16 bits wide, the ACRTC also offers an 8-bit MPU mode for easy connection to popular 8-bit busses.

---

## HD63484

*(source page 219)*

**Figure 2. System Configuration** — Block diagram: MPU (8/16b), System Memory, and DMAC each connect via shared Address, Data, and Control buses to the ACRTC. Signals into the ACRTC from that bus: RES̄, IRQ̄, D₀-D₁₅, DTACK̄, CS̄, RS, R/W̄, DREQ̄, DACK̄, DONĒ, 2CLK, Vcc/Vss. From the ACRTC to the frame buffer (Max. 2 MB): MA₁₆-MA₁₉, AS̄ (through a latch "L"), MRD̄, MAD₀-MAD₁₅. The frame buffer feeds a Dot Shifter, which drives the CRT. The ACRTC also outputs DISP1,2, CUD1,2, LPSTB, EXSYNC̄, VSYNC̄, HSYNC̄ to the Dot Shifter/CRT section, producing the Video Signal to the CRT monitor.

### Programming Model

**Address Space**

The ACRTC allows the host to issue commands in logical X-Y coordinates. The ACRTC converts these physical linear word addresses with bit field offsets in the frame buffer. Figure 3 shows the relationship between the logical X-Y screen address and the frame buffer memory, which is organized as sequential 16-bit words. The host may specify logical pixels of 1, 2, 4, 8, or 16 physical bits in the frame buffer. The system in figure 3 uses 4-bit logical pixels, allowing 16 colors or tones to be selected.

Up to four logical screens (upper, base, lower, and window) are mapped onto the ACRTC physical address space. The host specifies a logical screen physical start address, logical screen physical memory width (memory words per raster), logical pixel physical memory width (bit per pixel), and the logical origin physical address. Then the ACRTC converts logical pixel X-Y addresses issued by the host MPU or the ACRTC drawing processor to physical frame buffer addresses. The ACRTC also performs bit extraction and masking to map logical pixel operations (for example, 4 bits), to 16-bit word frame buffer addresses.

**Registers**

The ACRTC has over 200 bytes of accessible registers (figures 4, 5 and table 1). They are organized as hardware access, direct access, and FIFO access.

**Hardware Access:** The ACRTC is connected to the host MPU as a standard memory-mapped peripheral that occupies two word locations of the host's address space. The RS (register select) pin selects one of these two locations. When RS = 0 (low), read operations access the status register, and write operations access the address register.

The status register summarizes the ACRTC state. It monitors the overall state of the ACRTC for the host MPU.

When the MPU wants to access a direct access register, it puts the register's address

---

## HD63484

*(source page 220)*

**Figure 3. Logical/Physical Addressing** — Diagram with three sections. Left, "Physical Addressing (Frame Buffer)": a vertical memory column labeled bit 0 to bit 15, showing "1 pixel data" spanning several bits near the top, a bracket labeled "MW" (memory width) marking a run of rows, an "SAD" (screen address) marker partway down pointing to a row, and a shaded cell further down. Middle, "Logical Addressing": four stacked parallelogram planes (representing up to four logical screens), each with its own X-Y axes, an "Origin" point, a sample point "(x,y)", and width "MW"; diagonal lines connect corresponding bit-field rows in the physical addressing column to positions in these logical planes. Right, "Display Screen": a rectangle with Y axis (vertical) and X axis (horizontal), an "SAD" marker at the top-left, an "Origin" point, and a sample point "(x,y)" shown via dashed projection lines from the logical addressing planes.

into the ACRTC address register.

**Direct Access:** The MPU accesses the direct access registers by first loading the register address into the address register. Then, when the MPU accesses the ACRTC with RS = 1 (high), the chosen register is accessed.

The FIFO entry register enables the MPU to access FIFO access registers using the ACRTC read and write FIFOs.

The command control register controls overall ACRTC operations, such as aborting or pausing commands, defining DMA protocols, and enabling/disabling interrupt sources.

The operation mode register defines basic parameters of ACRTC operation, such as frame buffer access mode, display or drawing priority, cursor and display timing skew factors, and raster scan mode.

The display control register independently enables and disables the four ACRTC logical address screens (upper, base, lower, and window). It also contains 8 user-defined video attribute bits.

The timing control RAM registers define ACRTC timing, including timing specifications for CRT control signals (HSYNC̄, VSYNC̄, etc), logical display screen size and display period, and blink period.

The display control RAM contains registers which define logical screen display parameters, such as start address, raster address, and memory width. It also includes the cursor(s) definition, zoom factor, and lightpen registers.

**FIFO Access:** For high-performance drawing, key drawing processor registers are coupled to the host MPU via the ACRTC's 16-byte read and write FIFOs.

ACRTC commands are sent from the MPU via the write FIFO to the command register. As the ACRTC completes a command, the next command is automaticaly fetched from the write FIFO and put into the command register.

The pattern RAM defines drawing and painting patterns. It is accessed with the ACRTC's Read Pattern RAM (RPTN) and Write Pattern RAM (WPTN) register access commands.

The drawing parameter registers define detailed parameters of the drawing process, such as color data, area control (hitting/clipping), and pattern RAM pointers. The drawing parameter registers are accessed using the ACRTC's Read Parameter Register (RPR) and Write Parameter Register (WPR) commands.

---

## HD63484

*(source page 221)*

**Figure 4. Programming Model** — Diagram of the ACRTC's internal register organization, split into four groupings:

Left column, labeled **Control Register** (8-bit, bit 7 to bit 0 headers shown above the top three): Address Register, Status Register, FIFO Entry (dashed box, shown as a pass-through to/from the Write FIFO and Read FIFO on the right), Command Control Register, Operation Mode Register, Display Control Register, then a bracketed group of timing/control-RAM entries: Raster Counter, Horizontal Sync., Horizontal Display, Vertical Sync., Vertical Display, Split Screen Width, Blink Control, Horizontal Window Display, Vertical Window Display, Graphic Cursor; then a second bracketed group: Split Screen 0 Control (Upper Screen), Split Screen 1 Control (Base Screen), Split Screen 2 Control (Lower Screen), Split Screen 3 Control (Window Screen), Block Cursor, Cursor Definition, Zoom Factor, Light Pen Address.

Right side, top (16-bit, bit 15 to bit 0 headers): Write FIFO and Read FIFO boxes, connected (dashed arrows) to/from the FIFO Entry register; below them, a Command Register box that exchanges data bidirectionally with both FIFOs.

Below that, **Pattern RAM**: a 16 x 16 memory block (16 words x 16 bits).

Below that, labeled **Drawing Parameter Register**: Color 0, Color 1, Color Comparison, Edge Color, Mask, Pattern RAM Control, Area Definition, Read/Write Pointer, Drawing Pointer, Current Pointer.

---

## HD63484

*(source page 222)*

### Figure 5. Hardware Access and Direct Access Registers

Each register below is shown as a 16-bit word split into Data High (bits 15-8) and Data Low (bits 7-0), per the source diagram's column header. Field widths are transcribed from the diagram's box proportions; a few wide multi-bit fields (marked *) are corroborated against resolution/timing figures stated elsewhere in this datasheet — see the note under each.

**Re-scanned and corrected (this page and the three that follow, through page 225):** an earlier pass approximated several register boxes' internal field splits without measuring them, since most rows here don't repeat the bit-position ruler printed above (only the header row has one). Field boundaries below were re-derived by measuring the pixel x-position of each internal divider line against that 16-bit ruler and mapping to the nearest bit boundary, carrying the same grid down the page (and across pages 223-225, whose box proportions match this page's). Address Register, Status Register, FIFO Entry, CCR, OMR, DCR, RCR, HDR, and VSR were already correct and are unchanged; HSR and VDR below needed correction.

**Address Register** — Register No.=AR — CS̄=0, RS=0, R/W̄=0

| Bits | Field |
|---|---|
| 15-8 | — |
| 7-0 | Address |

**Status Register** — Register No.=AR — CS̄=0, RS=0, R/W̄=0

| Bits | Field |
|---|---|
| 15-8 | (unused) |
| 7 | CER |
| 6 | ARD |
| 5 | CED |
| 4 | LPD |
| 3 | RFF |
| 2 | RFR |
| 1 | WFR |
| 0 | WFE |

**FIFO Entry (FE)** — Register No.=r00 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-0 | FIFO Entry |

**Command Control (CCR)** — Register No.=r02 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15 | ABT |
| 14 | PSE |
| 13 | DDM |
| 12 | CDM |
| 11 | DRC |
| 10-8 | GBM |
| 7 | CRE |
| 6 | ARE |
| 5 | CEE |
| 4 | LPE |
| 3 | RFE |
| 2 | RRE |
| 1 | WRE |
| 0 | WEE |

**Operation Mode (OMR)** — Register No.=r04 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15 | M/S |
| 14 | STR |
| 13 | ACP |
| 12 | WSS |
| 11-10 | CSK |
| 9-8 | DSK |
| 7 | RAM |
| 6-5 | GAI |
| 4-3 | ACM |
| 2-0 | RSM |

**Display Control (DCR)** — Register No.=r06 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15 | DSP |
| 14 | SE1 |
| 13-12 | SE0 |
| 11-10 | SE2 |
| 9-8 | SE3 |
| 7-0 | ATR |

*ATR is 8 bits, matching the "8 user-defined video attribute bits" called out earlier in this datasheet (page 220).*

**(Undefined)** — Register No.=r08-R7E — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-0 | — |

**Raster Count (RCR)** — Register No.=r80 — CS̄=0, RS=1, R/W̄=1 (read only)

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | RC* |

*RC is a 12-bit counter, consistent with the "4096 rasters/screen" maximum stated on page 213.*

**Horizontal Sync (HSR)** — Register No.=r82 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-8 | HC |
| 7-5 | — |
| 4-0 | HSW |

*Re-scanned and corrected: HSW is 5 bits (4-0), not 6. Verified by direct pixel measurement of the divider lines against the 16-bit ruler on this page.*

**Horizontal Display (HDR)** — Register No.=r84 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-8 | HDS |
| 7-0 | HDW |

*HDS/HDW are each 8 bits, consistent with "256 characters/line" stated on page 213.*

**Vertical Sync (VSR)** — Register No.=r86 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | VC* |

*VC is a 12-bit counter (mirrors RC's 12-bit width above).*

**Vertical Display (VDR)** — Register No.=r88 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-8 | VDS |
| 7-5 | — |
| 4-0 | VSW |

*Re-scanned and corrected: VSW is 5 bits (4-0), not 6. Verified by direct pixel measurement.*

---

## HD63484

*(source page 223)*

### Figure 5. Hardware Access and Direct Access Registers (cont)

**Split Screen Width (SSW)** — Register No.=8A, 8C, 8E — CS̄=0, RS=1, R/W̄=0/1

Three registers, one per split screen, each laid out the same way:

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | SP1 |

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | SP0 |

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | SP2 |

**Blink Control (BCR)** — Register No.=r90 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-12 | BON1 |
| 11-8 | BOFF1 |
| 7-4 | BON2 |
| 3-0 | BOFF2 |

**Horizontal Window Display (HWR)** — Register No.=r92 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-8 | HWS |
| 7-0 | HWW |

**Vertical Window Display (VDR)** — Register No.=r94, 96 — CS̄=0, RS=1, R/W̄=0/1

Two registers:

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | VWS |

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | VWW |

**Graphic Cursor (GCR)** — Register No.=r98, 9A, 9C — CS̄=0, RS=1, R/W̄=0/1

Three registers:

| Bits | Field |
|---|---|
| 15-8 | CXE |
| 7-0 | CXS |

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | CYS |

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-0 | CYE |

*Re-scanned and corrected: CYS and CYE are 12-bit fields (11-0), not 8-bit. Verified by direct pixel measurement; also consistent with RC/VC's 12-bit width elsewhere in this figure.*

**(Undefined)** — Register No.=r9E-BE — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-0 | — |

**Upper Screen**

**Raster Address 0 (RAR0)** — Register No.=rC0 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-13 | — |
| 12-8 | LRA0 |
| 7-5 | — |
| 4-0 | FRA0 |

*Re-scanned and corrected: LRA0 and FRA0 are each 5 bits, not 7. Verified by direct pixel measurement.*

**Memory Width 0 (MWR0)** — Register No.=C2 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15 | CHR |
| 14-12 | — |
| 11-0 | MW0 |

*Re-scanned and corrected: MW0 is 12 bits (11-0), not 8.*

**Start Address 0 (SAR0)** — Register No.=rC4, C6 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-8 | SDA0 |
| 7-4 | — |
| 3-0 | SA0H/SRA0 |
| 15-0 (2nd word) | SA0L |

*Re-scanned and corrected: SDA0 and SA0H/SRA0 are each 4 bits (11-8 and 3-0), not 7-bit fields starting at bit 14/6.*

---

## HD63484

*(source page 224)*

### Figure 5. Hardware Access and Direct Access Registers (cont)

**Base Screen**

**Raster Address 1 (RAR1)** — Register No.=rC8 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-13 | — |
| 12-8 | LRA1 |
| 7-5 | — |
| 4-0 | FRA1 |

**Memory Width 1 (MWR1)** — Register No.=rCA — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15 | CHR |
| 14-12 | — |
| 11-0 | MW1 |

**Start Address 1 (SAR1)** — Register No.=rCC, rCE — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-8 | SDA1 |
| 7-4 | — |
| 3-0 | SA1H/SRA1 |
| 15-0 (2nd word) | SA1L |

*RAR1/MWR1/SAR1 re-scanned and corrected: same bit layout as RAR0/MWR0/SAR0 (page 223) — LRA1/FRA1 are 5 bits each, MW1 is 12 bits, SDA1 and SA1H/SRA1 are 4 bits each.*

**Lower Screen**

**Raster Address 2 (RAR2)** — Register No.=rD0 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-13 | — |
| 12-8 | LRA2 |
| 7-5 | — |
| 4-0 | FRA2 |

**Memory Width 0 (MWR2)** — Register No.=rD2 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15 | CHR |
| 14-12 | — |
| 11-0 | MW2 |

**Start Address 0 (SAR2)** — Register No.=rD4, D6 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-8 | SDA2 |
| 7-4 | — |
| 3-0 | SA2H/SRA2 |
| 15-0 (2nd word) | SA2L |

*RAR2/MWR2/SAR2 re-scanned and corrected: same bit layout as RAR0/MWR0/SAR0.*

**Window Screen**

**Raster Address 3 (RAR3)** — Register No.=rD8 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-13 | — |
| 12-8 | LRA3 |
| 7-5 | — |
| 4-0 | FRA3 |

**Memory Width 0 (MWR3)** — Register No.=rDA — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15 | CHR |
| 14-12 | — |
| 11-0 | MW3 |

**Start Address 0 (SAR3)** — Register No.=rDC, rDE — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-12 | — |
| 11-8 | SDA3 |
| 7-4 | — |
| 3-0 | SA3H/SRA3 |
| 15-0 (2nd word) | SA3L |

*RAR3/MWR3/SAR3 re-scanned and corrected: same bit layout as RAR0/MWR0/SAR0.*

**Block Cursor 1 (BCUR1)** — Register No.=rE0, rE2 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-13 | BCW1 |
| 12-8 | BCSR1 |
| 7-5 | — |
| 4-0 | BCER1 |
| 15-0 (2nd word) | BCA1 |

**Block Cursor 2 (BCUR2)** — Register No.=rE4, rE6 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-13 | BCW2 |
| 12-8 | BCSR2 |
| 7-5 | — |
| 4-0 | BCER2 |
| 15-0 (2nd word) | BCA2 |

*BCUR1/BCUR2 re-scanned and corrected: BCW is 3 bits, BCSR is 5 bits, BCER is 5 bits (same 3/5/3/5 split as the RAR registers), not the 4/4/1/7 split originally transcribed.*

---

## HD63484

*(source page 225)*

### Figure 5. Hardware Access and Direct Access Registers (cont)

**Cursor Definition (CDR)** — Register No.=rE8 — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-14 | CM |
| 13-11 | CON1 |
| 10-8 | COFF1 |
| 7-6 | — |
| 5-3 | CON2 |
| 2-0 | COFF2 |

*Re-scanned and corrected: CON1/COFF1/CON2/COFF2 are each 3 bits, not the 6/2/2/2 split originally transcribed. Verified by direct pixel measurement of the divider lines.*

**Zoom Factor (ZFR)** — Register No.=rEA — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-12 | HZF |
| 11-8 | VZF |
| 7-0 | — |

**Lightpen Address (LPAR)** — Register No.=rEC, rEE — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-8 | — |
| 7 | CHR |
| 6-3 | — |
| 2-0 | LPAH |
| 15-0 (2nd word) | LPAL |

*Re-scanned and corrected: CHR is at bit 7 (not bit 8) and LPAH is 3 bits (2-0), not 7.*

**(Undefined)** — Register No.=rF0-rFE — CS̄=0, RS=1, R/W̄=0/1

| Bits | Field |
|---|---|
| 15-0 | — |

### Register Mnemonic Glossary

| Mnemonic | Meaning |
|---|---|
| ABT | Abort |
| ACM | Access Mode |
| ACP | Access Priority |
| Address | Control Register number |
| ARD | Area Detect |
| ARE | Area Detect Interrupt Enable |
| ATR | Attribute Control |
| CDM | Command DMA Mode |
| CED | Command End |
| CEE | Command End Interrupt Enable |
| CER | Command Error |
| CSK | Cursor Display Skew |
| DDM | Data DMA Mode |
| DRC | DMA Request Control |
| DSK | DISP̄ Skew |
| DSP | DISP̄ Signal Control |
| FE | FIFO Entry |
| GAI | Graphic Address Increment Mode |
| GBM | Graphic Bit Mode |
| HC | Horizontal Cycle |
| HDS | Horizontal Display Start |
| HDW | Horizontal Display Width |
| HSW | Horizontal Sync Width |
| LPD | Light Pen Strobe Detect |
| LPE | Light Pen Strobe Interrupt Enable |
| M/S | Master/Slave |
| PSE | Pause |
| RAM | RAM Mode |
| RC | Raster Count |
| RFE | Read FIFO Full Interrupt Enable |
| RFF | Read FIFO Full |
| RFR | Read FIFO Ready |
| RRE | Read FIFO Ready Interrupt Enable |
| RSM | Raster Scan Mode |
| SE0 | Split Enable 0 |
| SE1 | Split Enable 1 |
| SE2 | Split Enable 2 |
| SE3 | Split Enable 3 |
| STR | Start |
| VC | Vertical Cycle |
| VDS | Vertical Display Start |
| VSW | Vertical Sync Width |
| WEE | Write FIFO Empty Interrupt Enable |
| WFE | Write FIFO Empty |
| WFR | Write FIFO Ready |
| WRE | Write FIFO Ready Interrupt Enable |
| WSS | Window Smooth Scroll |
| SP0, SP1, SP2 | Split Screen 0 Width, Split Screen 1 Width, Split Screen 2 Width |
| BON1, BON2 | Blink On 1, Blink On 2 |
| BOFF1, BOFF2 | Blink Off 1, Blink Off 2 |
| HWS | Horizontal Window Start |
| HWW | Horizontal Window Width |
| VWS | Vertical Window Start |
| VWW | Vertical Window Width |
| CXS, CYS | Cursor X Start, Cursor Y Start |
| CXE, CYE | Cursor X End, Cursor Y End |
| FRA | First Raster Address |
| LRA | Last Raster Address |
| CHR | Character |
| MW | Memory Width |
| SDA | Start Dot Address |
| SAH/SRA | Start Address High/Start Raster Address |
| SAL | Start Address Low |
| BCW1, BCW2 | Block Cursor Width 1, Block Cursor Width 2 |
| BCSR1, BCSR2 | Block Cursor Start Raster 1, Block Cursor Start Raster 2 |
| BCER1, BCER2 | Block Cursor End Raster 1, Block Cursor End Raster 2 |
| BCA1, BCA2 | Block Cursor Address 1, Block Cursor Address 2 |
| CM | Cursor Mode |
| CON1, CON2 | Cursor On 1, Cursor On 2 |
| COFF1, COFF2 | Cursor Off 1, Cursor Off 2 |
| HZF, VZF | Horizontal Zoom Factor, Vertical Zoom Factor |
| LPAH | Light Pen Address High |
| LPAL | Light Pen Address Low |

---

## HD63484

*(source page 226)*

### Table 1. Drawing Parameter Registers

Columns: Register No. | Read/Write | Name of Register | Abbr. | bit layout (Data(H) = bits 15-8, Data(L) = bits 7-0)

| Register No. | R/W | Name of Register | Abbr. | Bits | Field |
|---|---|---|---|---|---|
| Pr00 | R/W | Color 0 | CL0 | 15-0 | CL0 |
| Pr01 | R/W | Color 1 | CL1 | 15-0 | CL1 |
| Pr02 | R/W | Color Comparison | CCMP | 15-0 | CCMP |
| Pr03 | R/W | Edge Color | EDG | 15-0 | EDG |
| Pr04 | R/W | Mask | MASK | 15-0 | MASK |
| Pr05 | R/W | Pattern RAM Control | PRC | 15-12 / 11-8 / 7-4 / 3-0 | PPY / PZCY / PPX / PZCX |
| Pr06 | ↓ | | | 15-12 / 11-8 / 7-4 / 3-0 | PSY / — / PSX / — |
| Pr07 | | | | 15-12 / 11-8 / 7-4 / 3-0 | PEY / PZY / PEX / PZX |
| Pr08 | R/W | Area Definition** | ADR | 15-0 | XMIN |
| Pr09 | ↓ | | | 15-0 | YMIN |
| Pr0A | | | | 15-0 | XMAX |
| Pr0B | | | | 15-0 | YMAX |
| Pr0C | R/W | Read Write Pointer | RWP | 15-14 / 13-8 / 7-0 | DN / — / RWPH |
| Pr0D | | | | 15-4 / 3-0 | RWPL / — |
| Pr0E | — | Undefined | — | 15-0 | — |
| Pr0F | | | | 15-0 | — |
| Pr010 | R | Drawing Pointer | DP | 15-14 / 13-8 / 7-0 | DN / — / DPAH |
| Pr11 | | | | 15-4 / 3-0 | DPAL / DPD |
| Pr12 | R | Current Pointer** | CP | 15-0 | X |
| Pr13 | | | | 15-0 | Y |
| Pr14 | — | Undefined | — | 15-0 | — |
| Pr15 | | | | 15-0 | — |

—: Always set to 0.
**: Set two's complements for negative values of X and Y axis.

*Correction: DN (Screen Number) is a 2-bit field (bits 15-14), not 1 bit, in both RWP and DP.*

Note: the source lists the last Area Definition register's number as "Pr08" a second time (appears to be a printing erratum for what is logically **Pr0B**, following Pr08→XMIN, Pr09→YMIN, Pr0A→XMAX, Pr0B→YMAX).

**Drawing Parameter Register**

R: Register which can be read by Read Parameter Register Command (RPR)
W: Register which can be written into by Write Parameter Register Command (WPR)
—: Access is not allowed

CL0: Defines the color data used for the drawing when logical drawing data=0
CL1: Defines the color data used for the drawing when logical drawing data=1
CCMP: Defines the comparison color of the drawing operation
PSX, PSY: Pattern Start Point
PEX, PEY: Pattern End Point
PPX, PPY: Pattern Scan Start Point
PZX, PZY: Pattern Zoom
PZCX, PZCY: Pattern Zoom Count
XMIN, YMIN: Start point of Area definition
XMAX, YMAX: End point of Area definition
Dn: Screen Number
RWPH: High-order 8 bits of Read Write Pointer Address
RWPL: Low-order 12 bits of Read Write Pointer Address
DPAH: High-order 8 bits of Drawing Pointer Address
DPAL: Low-order 12 bits of Drawing Pointer Address
DPD: Drawing Pointer Dot Address
X, Y: Position indicated by Current Pointer on X-Y coodinate

---

## HD63484

*(source page 227)*

### Display Functions

**Logical Display Screens**

The ACRTC allows the frame buffer to be divided into four separate logical screens (table 2, figure 6).

In the simplest case, only the base screen parameters must be defined. Other screens may be selectively enabled, disabled, and blanked under software control.

The background screens (upper, base, and lower) split the screen into three horizontal partitions whose positions are fully programmable. A typical application might use the base screen for the bulk of user interaction, using the lower screen for a "status line(s)" and the upper screen for "pulldown menus".

The window screen is unique, since the ACRTC usually gives it higher priority than the background screens. Thus, when the window, whose size and position is completely programmable, overlaps a background screen, the window is displayed. The exception is in the ACRTC superimposed mode, in which the window has the same priority as the background screens. In this mode, the window and background screens are "superimposed" on the display.

### Table 2. Logical Screen

| Screen Number | Screen Name | Screen Group |
|---|---|---|
| 0 | Upper screen | Background screens |
| 1 | Base screen | |
| 2 | Low screen | |
| 3 | Window screen | |

**Figure 6. Screen Combination Examples** — Four example screen layouts:

1. Upper/Base/Lower stacked vertically on the left (Upper on top, Base in the middle, Lower at bottom), with a separate Window pane to the right spanning the Base row's height.
2. A large Base screen with a smaller Window overlapping its upper-right area.
3. Upper, Base, Lower, and Window stacked vertically in that order (four full-width horizontal bands).
4. Upper screen on top, Base screen below it with a Window overlapping the base screen's right portion, and a Lower screen band at the bottom.

---

## HD63484

*(source page 228)*

**Frame Memory Setup**

The ACRTC can have two independent frame memories, a 2-Mbyte frame buffer and a 128-kbyte refresh memory. The CHR output controls which memory is accessed.

Frame memory width is defined by setting up the memory width register (MWR). The horizontal width is independently defined by the horizontal display register (HDR). The memory area can therefore be specified bigger than the display area (figure 7).

Horizontal display control registers are set in units of memory cycles. Vertical display control registers are set in units of rasters.

Note that display width of registers marked with an asterisk (*) in figure 9 is:

(Display width) = (Register value) + 1 memory cycles

**Figure 7. Frame Memory and Display Screen Area** — Diagram of a large outer rectangle representing the full frame memory, spanned horizontally by "Memory Width" (marked with arrows at the top). A "Start Address" label points to the top-left corner of a smaller inner rectangle labeled "Display Screen Area", which is inset from the top-left of the memory area (offset shown by a small notch at its corner). The inner rectangle's horizontal extent is dimensioned below as "Horizontal Display Width", and its vertical extent is dimensioned at the right as "Vertical Display Width".

---

## HD63484

*(source page 229)*

**Display Control**

Figure 8 shows the relation between the frame memory and display screens. Each screen has its own memory width, vertical display width, and character/graphic attribution. These specifications are set by the control registers.

**Figure 8. Frame Memory and Display Screens** — Diagram with two memory address columns on the left and their mapped display images on the right:

Top-left: "Refresh Memory (Character)", address range $0000 to $FFFF, split into two regions. The upper region (start address SA0) maps to a frame-memory image of width MW0 containing a dashed box labeled "File Name: MOS". The lower region (start address SA2) maps to a frame-memory image of width MW2 containing a dashed box with two lines of text: "Left : Layout" and "Right : Symbol".

Bottom-left: "Frame Buffer (Graphic)", address range $00000 to $FFFFF, also split into two regions. The upper region (start address SA1) maps to a graphic image of width MW1 containing a small drawn symbol/component icon. The lower region (start address SA3) maps to a graphic image of width MW3 containing a drawn schematic symbol (a logic-gate-like shape).

Right side: these four sources are combined (via arrows) into one composite display, shown as a box with "File Name: MOS" at the top, the component icon (from MW1/SA1) below it, and to its right the schematic symbol (from MW3/SA3), and at the bottom two lines "Left : Layout" and "Right : Symbol" (from MW2/SA2) — illustrating how character text and graphic screens are superimposed into a single displayed image.

---

## HD63484

*(source page 230)*

**Figure 9. Display Screen Specification** — A combined horizontal-timing / vertical-layout diagram.

Top: an HSYNC̄ waveform (a pulse going low then high) with a series of bracketed horizontal timing intervals measured from the sync edge: HSW (the sync pulse width itself), HDS* (horizontal display start), HWS* (horizontal window start), HC* (total horizontal cycle, spanning the full width), HWW* (horizontal window width), and HDW* (horizontal display width, spanning from HDS to the end of the display area). Intervals marked with an asterisk follow the "(Display width) = (Register value) + 1 memory cycles" rule noted on the previous page.

Below: a large rectangle representing the "Display Screen Period", vertically divided into horizontal bands from top to bottom: (Upper), (Base), (Window) [drawn as a smaller box overlapping/inset within the (Base) band and repeated as a second (Base) band beneath it], and (Lower). To the right of this rectangle, vertical bracket labels mark corresponding vertical timing intervals top to bottom: VDS (vertical display start), VWS (vertical window start), SP0, SP1 (bracketing VWW, vertical window width), SP2, all together spanning VC (vertical cycle, the full height), with VSW (vertical sync width) marked as a separate short interval below the main rectangle. VSYNC̄ is marked at the top-right as the vertical sync reference edge.

### Commands

The ACRTC has 38 commands classified into three groups (tables 3, 4):

- Register access
- Data transfer
- Graphic drawing

Five register access commands give the host MPU access to drawing processor drawing parameter registers and the pattern RAM.

Ten data transfer commands move data between the host system memory and the frame buffer, or within the frame buffer.

Twenty-three graphic drawing commands cause the ACRTC to draw. Parameters for these commands are specified using logical X-Y addressing.

All commands, parameters, and data are trasnferred via the ACRTC read and write FIFOs.

Assuming the ACRTC has been properly initialized, the MPU must perform two steps to make the ACRTC draw:

1. First the MPU must specify drawing parameters that define the details associated with the drawing. For example, to draw a figure or paint an area, the MPU must specify the drawing or painting pattern by initializing the ACRTC pattern RAM and related pointers. If clipping or hitting control are desired, the MPU must specify the area to be monitored during drawing by initilizing the area definition registers. Other drawing parameters include color, edge definition, etc.

2. After the drawing parameters have been specified, the MPU issues a drawing command and any required command parameters, such as the CRCL (circle) command with a radius parameter.

The ACRTC then performs the specified drawing operation by reading, modifying, and rewriting the contents of the frame buffer.

---

## HD63484

*(source page 231)*

### Table 3. ACRTC Command Table

| Type | Mnemonic | Command Name | # (words) | Operation Cycles *1 |
|---|---|---|---|---|
| Register Access Command | ORG | Origin | 3 | 8 |
| | WPR | Write Parameter Register | 2 | 6 |
| | RPR | Read Parameter Register | 1 | 6 |
| | WPTN | Write Pattern RAM | n+2 | 4n+8 |
| | RPTN | Read Pattern RAM | 2 | 4n+10 |
| Data Transfer Command | DRD | DMA Read | 3 | (4x+8)y+12[x·y/8↑]+(62~68) |
| | DWT | DMA Write | 3 | (4x+8)y+16[x·y/8↑]+34 |
| | DMOD | DMA Modify | 3 | (4x+8)y+16[x·y/8↑]+34 |
| | RD | Read | 1 | 12 |
| | WT | Write | 2 | 8 |
| | MOD | Modify | 2 | 8 |
| | CLR | Clear | 4 | (2x+8)y+12 |
| | SCLR | Selective Clear | 4 | (4x+6)y+12 |
| | CPY | Copy | 5 | (6x+10)y+12 |
| | SCPY | Selective Copy | 5 | (6x+10)y+12 |
| Graphic Drawing Command | AMOVE | Absolute Move | 3 | 56 |
| | RMOVE | Relative Move | 3 | 56 |
| | ALINE | Absolute Line | 3 | P·L+18 |
| | RLINE | Relative Line | 3 | P·L+18 |
| | ARCT | Absolute Rectangle | 3 | 2P(A+B)+54 |
| | RRCT | Relative Rectangle | 3 | 2P(A+B)+54 |
| | APLL | Absolute Polyline | 2n+2 | Σ[P·L+16]+8 |
| | RPLL | Relative Polyline | 2n+2 | Σ[P·L+16]+8 |
| | APLG | Absolute Polygon | 2n+2 | Σ[P·L+16]+P·Lo+20 |
| | RPLG | Relative Polygon | 2n+2 | Σ[P·L+16]+P·Lo+20 |
| | CRCL | Circle | 2 | 8d+66 |
| | ELPS | Ellipse | 4 | 10d+90 |
| | AARC | Absolute Arc | 5 | 8d+18 |
| | RARC | Relative Arc | 5 | 8d+18 |
| | AEARC | Absolute Ellipse Arc | 7 | 10d+96 |
| | REARC | Relative Ellipse Arc | 7 | 10d+96 |
| | AFRCT | Absolute Filled Rectangle | 3 | (P·A+8)B+18 |
| | RFRCT | Relative Filled Rectangle | 3 | (P·A+8)B+18 |
| | PAINT | Paint | 1 | (18A+102)B-58 *2 |
| | DOT | Dot | 1 | 8 |
| | PTN | Pattern | 2 | (P·A+10)B+20 |
| | AGCPY | Absolute Graphic Copy | 5 | ((P+2)A+10)B+70 |
| | RGCPY | Relative Graphic Copy | 5 | ((P+2)A+10)B+70 |

Notes:
1. 2CLK cycles.
2. Applies to rectangular figures. Time varies for other shapes.
3. Abbreviations:
   - n: Number of read/write data words
   - x: Number of words in X direction
   - y: Number of words in Y direction
   - ↑: Round up
   - P: Operation cycles — P=4 cycles when OPM=000-011; P=6 cycles when OPM=100-111
   - L, Lo: Number of dots in a straight line
   - d: Total number of dots
   - A: Number of dots in main scan direction
   - B: Number of dots in sub scan direction

---

## HD63484

*(source page 232)*

### Table 4. Command Operation Codes and Parameters

**Re-scanned and corrected.** The source page prints each command's Operation Code as a row of 0/1 digits interspersed with named multi-bit field labels (AREA, COL, OPM, RN, PRA, MM, S, DSD, SL, SD, C, E), but does not print a bit-position ruler above the codes, and several digits sit close enough together that a plain read undercounts or misplaces trailing zeros. This version was re-derived by measuring the pixel position and width of every digit/label glyph on the page (each opcode word is 16 bits wide), which caught dropped/misaligned bits in the first transcription and fixed the layout so every row's bit sequence lines up under the same 15→0 ruler below.

Named-field bit widths aren't printed explicitly anywhere on this page; they were inferred from the one constraint that's certain — every Operation Code is exactly 16 bits — checked across every row that uses each field: **AREA**=3 bits, **COL**=2 bits, **OPM**=3 bits (corroborated by the note on the previous page that OPM's value ranges "000–011" and "100–111", i.e. a 3-bit field), **RN**=5 bits, **PRA**=4 bits, **MM**=2 bits, **C**=1 bit, **E**=1 bit. **S** and **DSD** together span 3 bits, and **SL** and **SD** together span 4 bits, but the split between each pair isn't separately determinable from this page, so they're shown as a combined span.

```
Mnemonic| 15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0 | Parameter
-------|------------------------------------------------|----------
ORG    | 0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0 | DPH, DPL
WPR    | 0  0  0  0  1  0  0  0  0  0  0        RN      | D
RPR    | 0  0  0  0  1  1  0  0  0  0  0        RN      |
WPTN   | 0  0  0  1  1  0  0  0  0  0  0  0     PRA     | n, D1,…,Dn
RPTN   | 0  0  0  1  1  1  0  0  0  0  0  0     PRA     | n
DRD    | 0  0  1  0  0  1  0  0  0  0  0  0  0  0  0  0 | AX, AY
DWT    | 0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0 | AX, AY
DMOD   | 0  0  1  0  1  1  0  0  0  0  0  0  0  0   MM  | AX, AY
RD     | 0  1  0  0  0  1  0  0  0  0  0  0  0  0  0  0 |
WT     | 0  1  0  0  1  0  0  0  0  0  0  0  0  0  0  0 | D
MOD    | 0  1  0  0  1  1  0  0  0  0  0  0  0  0   MM  | D
CLR    | 0  1  0  1  1  0  0  0  0  0  0  0  0  0  0  0 | D, AX, AY
SCLR   | 0  1  0  1  1  1  0  0  0  0  0  0  0  0   MM  | D, AX, AY
CPY    | 0  1  1  0  0   S,DSD   0  0  0  0  0  0  0  0 | SAH, SAL, AX, AY
SCPY   | 0  1  1  1  0   S,DSD   0  0  0  0  0  0   MM  | SAH, SAL, AX, AY
AMOVE  | 1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 | X, Y
RMOVE  | 1  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0 | dX, dY
ALINE  | 1  0  0  0  1  0  0  0    AREA   COL     OPM   | X, Y
RLINE  | 1  0  0  0  1  1  0  0    AREA   COL     OPM   | dX, dY
ARCT   | 1  0  0  1  0  0  0  0    AREA   COL     OPM   | X, Y
RRCT   | 1  0  0  1  0  1  0  0    AREA   COL     OPM   | dX, dY
APLL   | 1  0  0  1  1  0  0  0    AREA   COL     OPM   | n, X1,Y1,..Xn,Yn
RPLL   | 1  0  0  1  1  1  0  0    AREA   COL     OPM   | n, dX1,dY1,..dXn,dYn
APLG   | 1  0  1  0  0  0  0  0    AREA   COL     OPM   | n, X1,Y1,..Xn,Yn
RPLG   | 1  0  1  0  0  1  0  0    AREA   COL     OPM   | n, dX1,dY1,..dXn,dYn
CRCL   | 1  0  1  0  1  0  0  C    AREA   COL     OPM   | r
ELPS   | 1  0  1  0  1  1  0  C    AREA   COL     OPM   | a, b, DX
AARC   | 1  0  1  1  0  0  0  C    AREA   COL     OPM   | Xc, Yc, Xe, Ye
RARC   | 1  0  1  1  0  1  0  C    AREA   COL     OPM   | dXc, dYc, dXe, dYe
AEARC  | 1  0  1  1  1  0  0  C    AREA   COL     OPM   | a, b, Xc, Yc, Xe, Ye
REARC  | 1  0  1  1  1  1  0  C    AREA   COL     OPM   | a, b, dXc, dYc, dXe, dYe
AFRCT  | 1  1  0  0  0  0  0  0    AREA   COL     OPM   | X, Y
RFRCT  | 1  1  0  0  0  1  0  0    AREA   COL     OPM   | dX, dY
PAINT  | 1  1  0  0  1  0  0  E    AREA   0  0  0  0  0 |
DOT    | 1  1  0  0  1  1  0  0    AREA   COL     OPM   |
PTN    | 1  1  0  1   SL    SD     AREA   COL     OPM   | SZ
AGCPY  | 1  1  1  0  0   S,DSD     AREA   0  0    OPM   | Xs, Ys, DX, DY
RGCPY  | 1  1  1  1  0   S,DSD     AREA   0  0    OPM   | dXs, dYs, DX, DY
```

Command groups, top to bottom: **Register Access Command** (ORG–RPTN), **Data Transfer Command** (DRD–SCPY), **Graphic Drawing Command** (AMOVE–RGCPY).

Notes:

1. Register access commands abbreviations:
   - RN: Drawing parameter register number ($0–$13)
   - PRA: Pattern RAM read/write operation starting address ($0–$F)
   - DPH: Drawing pointer register high word (figure 29)
   - DPL: Drawing pointer register low word (figure 29)
   - DPAH: Higher 8 bits of drawing pointer address
   - DPAL: Lower 12 bits of drawing pointer address
   - DPD: Dot position in memory address

2. Data transfer commands abbreviations:
   - MM: Modify mode
   - S: Source scan direction (figure 30)
   - DSD: Destination scan direction (figure 31)
   - AX: Number of words in X direction − 1
   - AY: Number of words in Y direction − 1
   - D: Write data
   - SAH: Source start address high word (figure 32)
   - SAL: Source start address low word

3. Graphic drawing commands abbreviations:
   - AREA: Area mode
   - COL: Color mode
   - OPM: Operation mode
   - C: Circle drawing direction — C = 0 for counterclockwise; C = 1 for clockwise
   - E: Paint edge mode
   - SL, SD: Pattern scan direction
   - SZ: Pattern size

---

## HD63484

*(source page 233)*

(Table 4 notes, continued)

- E: Edge color definition — E = 0, edge color is data in edge color register; E = 1, edge color is any color except data in color register
- SL: Slant (figure 33)
- SD: Scan direction (figure 33)
- S: Source scan direction (figure 30)
- DSD: Destination scan direction (figure 31)

4. Parameter abbreviations
   - X, X1, …, Xn: Absolute X address from origin point
   - Y, Y1, …, Yn: Absolute Y address from origin point
   - dX: Relative X address from current pointer
   - dY: Relative Y address from current pointer
   - n: Number of nodes
   - dX1, …, dXn: Relative X address from each node
   - dY1, …, dYn: Relative Y address from each node
   - r: Number of dots on radius
   - a, b: ratio of dX squared to dY squared in ellipse — a:b = dX²:dY²
   - DX: X-direction dot number
   - DY: Y-direction dot number
   - Xc: Absolute X address of center point of arc/ellipse
   - Yc: Absolute Y address of center point of arc/ellipse
   - dXc: Relative X address from current point to center point of arc/ellipse
   - dYc: Relative Y address from current point to center point of arc/ellipse
   - Xe: Absolute X address of end point of arc/ellipse
   - Ye: Absolute Y address of end point of arc/ellipse
   - dXe: Relative X address from current point to end point of arc/ellipse
   - dYe: Relative Y address from current point to end point of arc/ellipse
   - Xs: Absolute X address of start point of arc/ellipse
   - Ys: Absolute Y address of start point of arc/ellipse
   - dXs: Relative X address from current point to start point of arc/ellipse
   - dYs: Relative Y address from current point to start point of arc/ellipse

**Program Transfer**

For program transfer, the MPU specifies the FIFO entry address and then writes commands/parameters to the write FIFO under program control (RS = high, R/W̄, CS̄ = low). The MPU writes are normally synchronized with FIFO status by software polling or interrupt.

**Software Polling:** WFR, WFE interrupts are disabled.

1. MPU program checks the SR (status register) for write FIFO ready flag (WFR) = 1, then writes 1 command/parameter word.
2. MPU program checks the SR (status register) for write FIFO empty flag (WFE) = 1, then writes 1 to 8 command/parameter words.

**Interrupt Driven:** WFR, WFE interrupts are enabled.

1. MPU WFR interrupt service routine writes 1 command/parameter word.
2. MPU WFE interrupt service routine writes 1 to 8 command/parameter words.

**Register Access Commands:** When writing register access commands to an initially empty write FIFO, the MPU does not have to synchronize to write FIFO status. The ACRTC can fetch and execute these commands faster than the MPU can issue them.

**Command DMA Transfer**

Commands and parameters can be transferred from the MPU system memory by an external DMAC. The MPU initiates and terminates command DMA transfer under software control (CDM bit of CCR). Command DMA transfer can also be terminated by asserting the ACRTC DONĒ signal. DONĒ is an input in command DMA transfer mode.

In command DMA transfer mode, the ACRTC issues cycle stealing DMA requests to the DMAC when the write FIFO is ready. The DMA data is automatically sent from system memory to the ACRTC write FIFO regardless of the contents of the address register.

Make sure that the write FIFO is empty and all previous commands are terminated before starting the command DMA transfer.

Data DMA transfer cannot be executed in command DMA transfer mode.

---

## HD63484

*(source page 234)*

### Table 5. Register Access Commands

| Command | Function |
|---|---|
| ORG | Initialize the relation between the origin point in the X-Y coordenates and the physical address |
| WPR | Write into parameter register |
| RPR | Read the parameter register |
| WPTN | Write into pattern RAM |
| RPTN | Read pattern RAM |

**Register Access Commands**

Registers associated with the drawing processor (pattern RAM and drawing parameter registers) are accessed throught the read and write FIFOs using register access commands (table 5).

**Data Transfer Commands**

Data transfer commands move blocks of data between the MPU system memory and the ACRTC frame buffer, or within the frame buffer itself (table 6). Before issuing these commands, a physical 20-bit frame buffer address must be specified in the RWP (read/write pointer) drawing parameter register.

**Graphic Drawing Commands**

The ACRTC has 23 graphic drawing commands (table 7). Graphic drawing is performed by modifying the contents of the frame buffer based on microcoded drawing algorithms in the ACRTC drawing processor.

Most drawing coordinate parameters are specified by logical pixel X-Y addresses. The ACRTC high-speed hardware performs the complex task of translating a logical pixel address to a linear frame buffer word address, and further, selecting the proper subfield of the word (for example, a 4-bit logical pixel might reside in bits 8-11 of a certain frame buffer word).

Many instructions allow specification in either absolute or relative X-Y coordinates (for example, ALINE and RLINE). In both cases, two's complement numbers represent both positive and negative values.

### Table 6. Data Transfer Commands

| Command | Function |
|---|---|
| DRD | Transfer data, by DMA transfer, from the frame buffer to the MPU system memory |
| DWT | Transfer data, by DMA transfer, from the MPU system memory to the frame buffer |
| DMOD | Transfer data, by DMA transfer, from the MPU system to the frame buffer subject to logical modification (bit maskable) |
| RD | Read one word of data from the frame buffer specified by the read/write pointer (RWP), and load the word into read FIFO |
| WT | Write one word of data to the frame buffer specified by the read/write pointer (RWP) |
| MOD | Perform logical operation on one word in the frame buffer specified by the read/write pointer (RWP) (bit maskable) |
| CLR | Clear a rectangular area of the frame buffer with data in the command parameter |
| SCLR | Initialize a rectangular area of the frame buffer with 1-word data subject to logical operation (bit maskable) |
| CPY | Copy frame buffer data from one area (source area) to another area (destination area) specified by the read/write pointer (RWP) |
| SCPY | Copy frame buffer data from one area (source area) to another area (destination area) subject to logical modification by word. The source and destination areas must reside on the same screen (bit maskable) |

---

## HD63484

*(source page 235)*

### Table 7. Graphic Drawing Commands

| Command | Function |
|---|---|
| AMOVE | Move the current pointer (CP) to an absolute logical pixel X-Y address |
| RMOVE | Move the current pointer (CP) to a relative logical pixel X-Y address |
| ALINE | Draw a straight line from the current pointer (CP) to a command-specified end point in absolute coordinates |
| RLINE | Draw a straight line from the current pointer (CP) to a command-specified end point in relative corrdinates |
| ARCT | Draw a rectangle defined by the current pointer (CP) and a command-specified diagonal point in absolute coordinates |
| RRCT | Draw a rectangle defined by the current pointer (CP) and a command-specified diagonal point in relative coordinates |
| APLL | Draw a polyline (multiple contiguous segments) from the current pointer (CP) through command-specified points in absolute coordinates |
| RPLL | Draw a polyline (multiple contiguous segments) from the current pointer (CP) through command-specified points in relative coordinates |
| APLG | Draw a polygon which connects the current pointer (CP) and command-specified points in absolute coordinates |
| RPLG | Draw a polygon which connects the current pointer (CP) and command-specified points in relative coordinates |
| CRCL | Draw a circle of radius R placing the current pointer (CP) at the center |
| ELPS | Draw a ellipse whose shape is specifed by command parameters, placing the current pointer (CP) at the center |
| AARC | Draw an arc by using the current pointer (CP) as a start point with an end point and a center point in absolute coordinates |
| RARC | Draw an arc by using the current pointer (CP) as a start point with an end point and a center point in relative coordinates |
| AEARC | Draw an ellipse arc by using the current pointer (CP) as a start point with an end point and a center point in absolute coordinates |
| REARC | Draw an ellipse arc by using the current pointer (CP) as a start point with an end point and a center point in relative coordinates |
| AFRCT | Paint a rectangular area specifed by the current pointer (CP) and command parameters (absolute coordinates) according to a figure pattern stored in the pattern RAM (tiling) |
| RFRCT | Paint a rectangular area specifed by the current point (CP) and command parameters (relative coordinates) according to a figure pattern stored in the pattern RAM (tiling) |
| PAINT | Paint a closed area surrounded by edge color using a figure pattern stored in the pattern RAM (tiling) |
| DOT | Mark a dot on the coordinates indicated by the current pointer (CP) |
| PTN | Draw a graphic pattern defined in the pattern RAM onto a rectangular area specifed by the current point (CP) and by the pattern size (rotation angle: 45°) |
| AGCPY | Copy a rectangular area specifed by the absolute coordinates to the address specifed by the current pointer (CP) (rotation angle: 90°/mirror reflection) |
| RGCPY | Copy a rectangular area specified by the relative coordinates to the address specified by the current pointer (CP) (rotation angle: 90°/mirror reflection) |

---

## HD63484

*(source page 236)*

### Notes on System Design

**Power-On Sequence**

The conditions in figure 10 must be satisfied at power-on.

**Output Waveform**

If excessive ringing (figure 11) occurs on CRT data buses, (MAD₀-MAD₁₅, MA₁₆/RA₀-MA₁₉/RA₄), damping resistors may be required as shown in figure 12.

**Figure 10. Power-On Sequence** — Timing diagram showing Vcc rising from 0.8V to 4.5V with a t2CH interval of 100 ms marked at the crossing point; below it, a 2CLK-like waveform shown as a train of small oscillations settling to a steady level (labeled 2.2V for the 4/6/8 MHz versions, 2.4V for the 9.8 MHz version); further below, a reset-related signal transitions from a low level to a high level of 0.7V after an interval tREH of 100 ms.

**Figure 11. Ringing Noise** — A Vout vs. t waveform: the signal drops from VOH to VOL and settles with a damped oscillation ("Ringing Noise") superimposed near the VOL level. Note: The ringing level depends on the load capacity, and can be VOL + 0.1 V.

**Figure 12. Damping Resistors** — Diagram showing the ACRTC's MAD₀-MAD₁₅ outputs each routed through a series damping resistor before continuing to the frame buffer bus; a bracket notes "Damping Resistors (50 Ω – 100 Ω)".

---

## HD63484

*(source page 237)*

**Power Supply Circuit**

When laying out the Vcc and Vss traces on the circuit board, locate capacitors as close as possible to each power supply pin (figures 13, 14, 15).

**Figure 13. Power Supply Circuit Example, 64-Pin DIP** — Schematic showing two decoupling capacitors: one between Vcc (pin 14) and Vss (pin 16), and another between pin 51 (Vss) and pin 49 (Vcc), each a 1 µF/35 V tantalum capacitor (×2 total).

**Figure 14. Power Supply Circuit Example, 68-Pin PLCC** — Schematic of the PLCC package showing Vcc(1) at the top, with decoupling capacitors placed between: Vcc(15)/Vss(17)/Vss(18) on the left side (bonded to external Vcc and Vss rails), Vss(35) at the bottom, and Vss(55)/Vss(54)/Vcc(52) on the right side (bonded to external Vss and Vcc rails) — three 1 µF/35 V tantalum capacitors total, one per side grouping.

**Figure 15. Power Supply Circuit Example 68-Pin PGA** — Diagram of the 68-pin PGA bottom view pin grid, with Vss and Vcc external rails on the left connected to specific pins (filled-in pin markers), and additional decoupling capacitors on the right connected between nearby Vcc/Vss pins. Legend: Vcc: No. 6, 15, 22. Vss: No. 7, 8, 23, 24, 33.

---

## HD63484

*(source page 238)*

### Absolute Maximum Ratings

| Item | Symbol | Rating | Unit |
|---|---|---|---|
| Supply Voltage | Vcc (Note 1) | −0.3 to +7.0 | V |
| Input Voltage | Vin (Note 1) | −0.3 to Vcc +0.3 | V |
| Allowable Output Current | \|IO\| (Note 2) | 5 | mA |
| Total Allowable Output Current | \|ΣIO\| (Note 3) | 120 | mA |
| Operating Temperature | Topr | 0 to +70 | °C |
| Storage Temperature | Tstg | −55 to +150 | °C |

Notes:
1. Referenced to Vss = 0 V.
2. The maximum current that may be drawn from, or flow out of, one output, or one common input/output terminal.
3. The total sum of currents that may be drawn from, or flow out of, all output or common input/output terminals.
4. Using an LSI beyond its maximum rating may result in its permanent destruction. LSIs should usually be used under recommended operating conditions. Exceeding any of these conditions may adversely affect reliability.

### Recommended Operating Conditions

| Item | Symbol | Min | Typ | Max | Unit |
|---|---|---|---|---|---|
| Supply Voltage | Vcc (Note) | 4.75 | 5.0 | 5.25 | V |
| Input Low Voltage | VIL (Note) | 0 | | 0.7 | V |
| Input High Voltage (4, 6, 8 MHz versions) | VIH (Note) | 2.2 | | Vcc | V |
| Input High Voltage (9.8 MHz version) | VIH (Note) | 2.4 | | Vcc | V |
| Operating Temperature | Topr | 0 | 25 | 75 | °C |

Note: Referenced to Vss = 0 V

---

## HD63484

*(source page 239)*

### Electrical Characteristics

**DC Characteristics** (Vcc=5.0V ± 5%, Vss=0V, Ta=0°C to +70°C unless otherwise noted)

| Item | Applies to | Symbol | Min | Max | Unit | Test Condition |
|---|---|---|---|---|---|---|
| Input High Level Voltage | All inputs | VIH | 2.2 | Vcc | V | 4, 6, 8 MHz versions |
| | | | 2.4 | Vcc | V | 9.8 MHz version ★ |
| Input Low Level Voltage | All inputs | VIL | −0.3 | 0.7 | V | |
| Input Leak Current | R/W̄, CS̄, RS, RES̄, DACK̄, 2CLK, LPSTB | Iin | −2.5 | 2.5 | µA | Vin=−0.4 to Vcc |
| Hi-Z Input Current | D₀-D₁₅, MAD₀-MAD₁₅, EXSYNC̄ | ITSI | −10 | 10 | µA | Vin=−0.4 to Vcc |
| Output High Level Voltage | D₀-D₁₅, MAD₀-MAD₁₅, CUD1, CUD2, DREQ̄, DTACK̄, HSYNC̄, VSYNC̄, EXSYNC̄, MRD̄, DRAW̄, AS̄, DISP1, DISP2, CHR, MCYC, RA₄, MA₁₆/RA₀-MA₁₉/RA₃ | VOH | Vcc−1.0 | | µA | IOH=−400µA |
| Output Low Level Voltage | D₀-D₁₅, MAD₀-MAD₁₅, CUD1, CUD2, DREQ̄, DTACK̄, HSYNC̄, VSYNC̄, EXSYNC̄, MRD̄, DRAW̄, AS̄, DISP1, DISP2, CHR, MCYC, RA₄, MA₁₆/RA₀-MA₁₉/RA₃ | VOL | | 0.5 | V | IOL=2.2mA |
| Output Low Level Voltage | IRQ̄, DONĒ | VOL | | 0.5 | V | IOL=2.5 mA |
| Output Leak Current (Hi-Z) | IRQ̄, DONĒ | ILOD | | 10 | µA | VOH=Vcc |
| Input Capacitance | D₀-D₁₅, MAD₀-MAD₁₅, EXSYNC̄, R/W̄, CS̄, RS, RES̄, DACK̄, 2CLK, LPSTB | Cin | | 17 | pF | Vin=0V, Ta=25°C, f=1.0 MHz |
| Output Capacitance | IRQ̄, DONĒ | Cout | | 15 | pF | Vin=0V, Ta=25°C, f=1.0 MHz |
| Current Consumption | | Icc | | 60 | mA | 4 MHz version |
| | | | | 80 | mA | 6 MHz version |
| | | | | 100 | mA | 8 MHz version |
| | | | | 120 | mA | 9.8 MHz version |

---

## HD63484

*(source page 240)*

### AC Characteristics (Vcc=5.0V ± 5%, Vss=0V, Ta=0 to +70°C unless otherwise noted)

**Clock Timing**

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| | Operation Frequency of 2CLK | f | 1 | 4 | 1 | 6 | 1 | 8 | 1 | 9.8 | MHz | |
| 1 | Clock Cycle Time | tcyc | 250 | 1000 | 167 | 1000 | 125 | 1000 | 102 | 1000 | ns | |
| 2 | Clock High Level Pulse Width | tPWCH | 115 | 500 | 75 | 500 | 55 | 500 | 46 | 500 | ns | 17 |
| 3 | Clock Low Level Pulse Width | tPWCL | 115 | 500 | 75 | 500 | 55 | 500 | 46 | 500 | ns | |
| 4 | Clock Rise Time | tcr | — | 10 | — | 10 | — | 10 | — | 5 | ns | |
| 5 | Clock Fall Time | tcf | — | 10 | — | 10 | — | 10 | — | 5 | ns | |

**MPU Read/Write Cycle Timing**

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 6 | R/W̄ Setup Time | tRWS | 70 | — | 60 | — | 50 | — | 50 | — | ns | 18-20 |
| 7 | R/W̄ Hold Time | tRWH | 0 | — | 0 | — | 0 | — | 0 | — | ns | |
| 8 | RS Setup Time | tRSS | 70 | — | 60 | — | 50 | — | 50 | — | ns | |
| 9 | RS Hold Time | tRSH | 0 | — | 0 | — | 0 | — | 0 | — | ns | |
| 10 | CS̄ Setup Time | tCSS | 50 | — | 40 | — | 40 | — | 40 | — | ns | |
| 11 | CS̄ High Level Width | tWCSH | 80 | — | 70 | — | 60 | — | 60 | — | ns | 18, 19 |
| 12 | (not used) | | | | | | | | | | | |
| 13 | Read Wait Time | tRWAI | 0 | — | 0 | — | 0 | — | 0 | — | ns | 18, 20 |
| 14 | Read Data Access Time | tRDAC | — | 120 | — | 100 | — | 80 | — | 80 | ns | |
| 15 | Read Data Hold Time | tRDH | 10 | — | 10 | — | 10 | — | 10 | — | ns | |
| 16 | Read Data Turn Off Time | tRDZ | — | 60 | — | 60 | — | 60 | — | 60 | ns | |
| 17 | DTACK̄ Delay Time (Z to L) | tDTKZL | — | 90 | — | 80 | — | 70 | — | 70 | ns | 18-20 |
| 18 | DTACK̄ Delay Time (D to L) | tDTKDL | 0 | — | 0 | — | 0 | — | 0 | — | ns | 18, 20 |
| 19 | DTACK̄ Release Time (L to H) | tDTKLH | — | 100 | — | 90 | — | 80 | — | 80 | ns | 18-20 |
| 20 | DTACK̄ Turn Off Time (H to Z) | tDTKZ | — | 100 | — | 100 | — | 100 | — | 100 | ns | |
| 21 | Data Bus 3-State Recovery Time 1 | tDBRT1 | 0 | — | 0 | — | 0 | — | 0 | — | ns | 18, 20 |
| 22 | Write Wait Time | tWWAI | 0 | — | 0 | — | 0 | — | 0 | — | ns | 19, 20 |
| 23 | Write Data Setup Time | tWDS | 80 | — | 60 | — | 40 | — | 40 | — | ns | |
| 24 | Write Data Hold Time | tWDH | 10 | — | 10 | — | 10 | — | 10 | — | ns | |

---

## HD63484

*(source page 241)*

### DMA Read/Write Cycle Timing

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | DREQ̄ Delay Time 1 | tDRQD1 | — | 150 | — | 130 | — | 110 | — | 110 | ns | 21-24 |
| 26 | DREQ̄ Delay Time 2 | tDRQD2 | — | 90 | — | 80 | — | 70 | — | 70 | ns | |
| 27 | DMA R/W̄ Setup Time | tDMRWS | 70 | — | 60 | — | 50 | — | 50 | — | ns | |
| 28 | DMA R/W̄ Hold Time | tDMRWH | 0 | — | 0 | — | 0 | — | 0 | — | ns | |
| 29 | DACK̄ Setup Time | tDAKS | 50 | — | 40 | — | 40 | — | 40 | — | ns | |
| 30 | DACK̄ High Level Width | tWDAKH | 80 | — | 70 | — | 60 | — | 60 | — | ns | |
| 31 | (not used) | | | | | | | | | | | |
| 32 | DMA Read Wait Time | tDRW | 0 | — | 0 | — | 0 | — | 0 | — | ns | 21, 22 |
| 33 | DMA Read Data Access Time | tDRDAC | — | 120 | — | 100 | — | 80 | — | 80 | ns | |
| 34 | DMA Read Data Hold Time | tDRDH | 10 | — | 10 | — | 10 | — | 10 | — | ns | |
| 35 | DMA Read Data Turn Off Time | tDRDZ | — | 60 | — | 60 | — | 60 | — | 60 | ns | |
| 36 | DMA DTACK̄ Delay Time (Z to L) | tDDTZL | — | 90 | — | 80 | — | 70 | — | 70 | ns | 21-24 |
| 37 | DMA DTACK̄ Delay Time (D to L) | tDDTDL | 0 | — | 0 | — | 0 | — | 0 | — | ns | 21, 22 |
| 38 | DMA DTACK̄ Release Time (L to H) | tDDTLH | — | 100 | — | 90 | — | 80 | — | 80 | ns | 21-24 |
| 39 | DMA DTACK̄ Turn Off Time (H to Z) | tDDTHZ | — | 100 | — | 100 | — | 100 | — | 100 | ns | |
| 40 | DONĒ Output Delay Time | tDND | — | 90 | — | 80 | — | 70 | — | 70 | ns | |
| 41 | DONĒ Output Turn Off Time (L to Z) | tDNLZ | — | 100 | — | 90 | — | 80 | — | 80 | ns | |
| 42 | Data Bus 3-State Recovery Time 2 | tDBRT2 | 0 | — | 0 | — | 0 | — | 0 | — | ns | 21, 22 |
| 43 | DONĒ Input Pulse Width | tDNPW | 2 | — | 2 | — | 2 | — | 2 | — | tcyc | 23, 24 |
| 44 | DMA Write Wait Time | tDWW | 0 | — | 0 | — | 0 | — | 0 | — | ns | |
| 45 | DMA Write Data Setup Time | tDWDS | 80 | — | 60 | — | 40 | — | 40 | — | ns | |
| 46 | DMA Write Data Hold Time | tDWDH | 10 | — | 10 | — | 10 | — | 10 | — | ns | |
| 47 | (not used) | | | | | | | | | | | |

---

## HD63484

*(source page 242)*

### Frame Memory Read/Write Cycle Timing

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 48 | AS̄ "Low" Level Pulse Width | tPWASL | 80 | — | 40 | — | 25 | — | 20 | — | ns | 25-28 |
| 49 | Memory Address Hold Time 2 | tMAH2 | 10 | — | 10 | — | 10 | — | 5 | — | ns | |
| 50 | AS̄ Delay Time 1 | tASD1 | — | 90 | — | 75 | — | 60 | — | 50 | ns | |
| 51 | AS̄ Delay Time 2 | tASD2 | 5 | 90 | 5 | 75 | 5 | 65 | 5 | 40 | ns | |
| 52 | Memory Address Delay Time | tMAD | 15 | 95 | 15 | 80 | 15 | 70 | 10 | 50 | ns | |
| 53 | Memory Address Hold Time 1 | tMAH1 | 25 | — | 25 | — | 25 | — | 15 | — | ns | |
| 54 | Memory Address Turn Off Time (A to Z) | tMAAZ | — | 50 | — | 50 | — | 50 | — | 35 | ns | |
| 55 | Memory Read Data Setup Time | tMRDS | 60 | — | 50 | — | 35 | — | 30 | — | ns | 26 |
| 56 | Memory Read Data Hold Time | tMRDH | 10 | — | 10 | — | 10 | — | 0 | — | ns | |
| 57 | MA/RA Delay Time | tMARAD | — | 100 | — | 90 | — | 80 | — | 60 | ns | 25-28 |
| 58 | MA/RA Hold Time | tMARAH | 10 | — | 10 | — | 10 | — | 5 | — | ns | 25-27 |
| 59 | MCYC Delay Time | tMCYCD | 5 | 60 | 5 | 50 | 5 | 50 | 5 | 40 | ns | 25-29 |
| 60 | MRD̄ Delay Time | tMRDD | — | 90 | — | 80 | — | 70 | — | 50 | ns | 24-28 |
| 61 | MRD̄ Hold Time | tMRH | 10 | — | 10 | — | 10 | — | 5 | — | ns | |
| 62 | DRAW̄ Delay Time | tDRWD | — | 90 | — | 80 | — | 70 | — | 50 | ns | |
| 63 | DRAW̄ Hold Time | tDRWH | 10 | — | 10 | — | 10 | — | 5 | — | ns | |
| 64 | Memory Write Data Delay Time | tMWDD | — | 90 | — | 80 | — | 70 | — | 50 | ns | 27 |
| 65 | Memory Write Data Hold Time | tMWDH | 10 | — | 10 | — | 10 | — | 5 | — | ns | |
| 110 | Memory Address Setup Time 1 | tMAS1 | 10 | — | 10 | — | 10 | — | 10 | — | ns | 25-28 |
| 112 | Memory Address Setup Time 2 | tMAS2 | 10 | — | 10 | — | 10 | — | 10 | — | ns | |

Notes:
1. Characteristic No.52 is independent of the 2CLK operation frequency (f) and timing of No.51 and No.110.
2. New characteristics No.50 and No.52 shown above are applicable only to lot numbers 5M*, 6*, 7**, and greater (* means don't care).

For the other lot numbers, applicable characteristics are as follows:

| No. | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | Unit |
|---|---|---|---|---|---|---|---|---|
| 50 | tASD1 | — | 90 | — | 75 | — | 65 | ns |
| 52 | tMAD | — | 95 | — | 80 | — | 70 | ns |

---

## HD63484

*(source page 243)*

### Display Control Signal Output Timing

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 67 | HSYNC̄ Delay Time | tHSD | — | 90 | — | 80 | — | 70 | — | 50 | ns | 28-30 |
| 68 | VSYNC̄ Delay Time | tVSD | — | 90 | — | 80 | — | 70 | — | 50 | ns | 29 |
| 69 | DISP1, DISP2 Delay Time | tDSPD | — | 90 | — | 80 | — | 70 | — | 50 | ns | |
| 70 | CUD1, CUD2 Delay Time | tCUDD | — | 90 | — | 80 | — | 70 | — | 50 | ns | |
| 71 | EXSYNC̄ Output Delay Time | tEXD | 20 | 90 | 20 | 80 | 20 | 70 | 15 | 50 | ns | |
| 72 | CHR Delay Time | tCHD | — | 90 | — | 80 | — | 70 | — | 50 | ns | |
| 73 | (not used) | | | | | | | | | | | |
| 74 | (not used) | | | | | | | | | | | |

### EXSYNC̄ Input Timing

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 75 | EXSYNC̄ Input Pulse Width | tEXSW | 3 | — | 3 | — | 3 | — | 3 | — | tcyc | 30 |
| 76 | EXSYNC̄ Input Setup Time | tEXS | 60 | — | 60 | — | 50 | — | 30 | — | ns | |
| 77 | EXSYNC̄ Input Hold Time | tEXH | 15 | — | 15 | — | 15 | — | 10 | — | ns | |

### LPSTB Input Timing

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 78 | LPSTB Uncertain Time 1 | tLPD1 | 70 | — | 70 | — | 70 | — | 45 | — | ns | 31, 32 |
| 79 | LPSTB Uncertain Time 2 | tLPD2 | 10 | — | 10 | — | 10 | — | 10 | — | ns | |
| 80 | LPSTB Input Hold Time | tLPH | 10 | — | 10 | — | 10 | — | 10 | — | ns | |
| 81 | LPSTB Input Inhibit time | tLPI | 4 | — | 4 | — | 4 | — | 4 | — | tcyc | |

### RES̄ and DACK̄ Input Timing

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 82 | DACK̄ Setup Time for RES̄ | tDAKSR | 100 | — | 100 | — | 100 | — | 100 | — | ns | 33 |
| 83 | DACK̄ Hold Time for RES̄ | tDAKHR | 0 | — | 0 | — | 0 | — | 0 | — | ns | |
| 84 | RES̄ Input Pulse Width | tRES | 10 | — | 10 | — | 10 | — | 10 | — | tcyc | |

---

## HD63484

*(source page 244)*

### IRQ̄ and Attributes Output Cycle Timing

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 85 | IRQ̄ Delay Time 1 | tIRQ1 | — | 250 | — | 200 | — | 150 | — | 150 | ns | 34, 35 |
| 86 | IRQ̄ Delay Time 2 | tIRQ2 | — | 500 | — | 500 | — | 500 | — | 500 | ns | |
| 87 | ATR Delay Time 1 | tATRD1 | — | 100 | — | 90 | — | 80 | — | 60 | ns | 28 |
| 88 | ATR Hold Time 1 | tATRH1 | 10 | — | 10 | — | 10 | — | 5 | — | ns | |
| 89 | (not used) | | | | | | | | | | | |
| 90 | ATR Delay Time 2 | tATRD2 | — | 100 | — | 90 | — | 80 | — | 60 | ns | 28 |
| 91 | ATR Hold Time 2 | tATRH2 | 10 | — | 10 | — | 10 | — | 5 | — | ns | |

### Synchronous Bus Timing, MPU or DMA Read/Write Cycle

| No. | Item | Symbol | 4 MHz Min | 4 MHz Max | 6 MHz Min | 6 MHz Max | 8 MHz Min | 8 MHz Max | 9.8 MHz Min | 9.8 MHz Max | Unit | Ref. Fig. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 100 | CS̄ Cycle Time | tCSC | 4 | — | 4 | — | 4 | — | 4 | — | tcyc | 18, 19 |
| 101 | CS̄ Low Level Width | tWCSL | 2 | — | 2 | — | 2 | — | 2 | — | tcyc | |
| 102 | CS̄ High Level Width | tWCSH | 2 | — | 2 | — | 2 | — | 2 | — | tcyc | |
| 104 | DACK̄ Cycle Time | tDACKC | 4 | — | 4 | — | 4 | — | 4 | — | tcyc | 22, 24 |
| 105 | DACK̄ Low Level Width | tWDACKL | 2 | — | 2 | — | 2 | — | 2 | — | tcyc | |
| 106 | DACK̄ High Level Width | tWDACKH | 2 | — | 2 | — | 2 | — | 2 | — | tcyc | |

**Figure 16. Test Points** — A voltage-vs-time waveform: V starts at VOH, drops through a damped oscillation toward VOL, with two reference dashed lines marked "VOL at the timing measurement (0.8 V)" and "VOL at the DC level (0.5 V)", and the "0 measuring point" marked at the start of the time axis. Caption: VOL Reference at Timing Measurement.

**Figure 17. 2CLK Waveform** — A clock waveform diagram showing 2CLK transitioning between 0.7V and 2.2V threshold levels across three cycles, with the measured intervals tcyc (①, full period), tPWCL (③, low pulse width), tPWCH (②, high pulse width), tCr (④, rise time), and tCf (⑤, fall time) marked between the corresponding threshold crossings. Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 245)*

**Figure 18. MPU Read Cycle Timing (MPU ↔ ACRTC)** — A rotated (landscape) timing-diagram page showing five signal traces — 2CLK, R/W̄, RS, CS̄, D₀-D₁₅, and DTACK̄ — across a read cycle, split into three annotated regions along the time axis: "Asynchronous bus timing (1)", "Asynchronous bus timing (2)", and "Synchronous bus timing (The MPU read cycle timing is fixed.)". The 2CLK trace is drawn as a continuous square/triangle wave across all regions, with the T0, T1, …, Tn, Tn1, Tn2 clock-cycle labels marking successive clock edges. Each of R/W̄, RS, and CS̄ shows a transition referenced to 2.2V/0.7V threshold levels, with numbered callouts (matching the AC-characteristics table numbers, e.g. ⑥ ⑧ ⑨ ⑩ ⑦ etc.) marking the specific setup/hold intervals defined in the preceding timing tables. The D₀-D₁₅ trace shows a hatched "data valid" region bounded by Vcc-2.0V/0.8V levels with callouts for read data access/hold/turn-off timing (⑭ ⑮ ⑯ etc.). The DTACK̄ trace shows its low-going pulse with callouts ⑫ ⑬ ⑰ ⑱ ⑲ ⑳ ㉑ marking its delay, release, and turn-off timing relative to CS̄ and the data valid window. This pattern (one set of traces per labeled region) repeats three times across the page, once for each of the three timing-mode regions listed above.

Notes:
1. CS̄ high level width must satisfy specification ⑩②. Unless spec ⑩② is satisfied, DTACK̄ and read data responses to the succeeding cycle are delayed.
2. ⑩⓪, ⑩①, and ⑩② are synchronous bus timing specifications.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 246)*

**Figure 19. MPU Write Cycle Timing (MPU → ACRTC)** — A rotated (landscape) timing-diagram page, structured like Figure 18 but for a write cycle. Five signal traces — 2CLK, R/W̄, RS, CS̄, D₀-D₁₅, and DTACK̄ — are shown across three regions: "Asynchronous bus timing (1)", "Asynchronous bus timing (2)", and "Synchronous bus timing (The MPU write cycle timing is fixed.)". Numbered callouts (⑥⑧⑨⑩⑦, ⑰-㉔, etc., matching the AC-characteristics table entries) mark setup/hold/delay intervals on R/W̄, RS, CS̄, the write data valid window on D₀-D₁₅, and the DTACK̄ response pulse, referenced to 2.2V/0.7V (digital) and Vcc-2.0V/0.8V (data valid) threshold levels.

Notes:
1. CS̄ high width must satisfy the specification ⑩②. Unless spec ⑩② is satisfied, DTACK̄ response to the succeeding cycle is delayed.
2. When the ACRTC is used with the synchronous bus timing, the specifications ⑩⓪, ⑩① and ⑩② must be satisfied.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 247)*

**Figure 20. MPU Read/Write Cycle Timing** — A rotated (landscape) timing-diagram page combining a read cycle immediately followed by a write cycle, using the same five traces (2CLK, R/W̄, RS, CS̄, D₀-D₁₅, DTACK̄) and the same numbered callout scheme as Figures 18-19, shown across several repeated clock-cycle blocks (T0...Tn2) to illustrate back-to-back read-then-write bus activity.

Note: When the MPU read cycle immediately follows the MPU write cycle execution, DTACK̄ and the read data responses are delayed (by 3 cycles of 2CLK) even though spec ⑩② is satisfied.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 248)*

**Figure 21. DMA Read Cycle Timing (Memory ↔ ACRTC)** — A rotated (landscape) timing-diagram page showing the DMA read cycle across traces 2CLK, DREQ̄, R/W̄, DACK̄, D₀-D₁₅, DTACK̄ (READY), and DONĒ (OUTPUT). The 2CLK trace runs continuously across clock periods T0…Tn2, with a break (dashed) shown to indicate an extended/variable number of cycles. Two DREQ̄ variants are shown, one for DRC="1" and one for DRC="0" (DMA Request Control bit), branching at the point DREQ̄ is asserted. Numbered callouts ㉕–㉚, ㉜–㊲ (matching the DMA Read/Write Cycle Timing table entries 25-42) mark the DREQ̄ delay times, R/W̄ and DACK̄ setup/hold times, the read-data valid window on D₀-D₁₅ (hatched region referenced to Vcc-2.0V/0.8V), and the DTACK̄/DONĒ delay and turn-off timings.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 249)*

**Figure 22. DMA Ready Cycle Timing (Memory ↔ ACRTC): Burst Mode** — A rotated (landscape) timing-diagram page similar to Figure 21, but illustrating burst-mode DMA transfers: the 2CLK, DREQ̄, R/W̄, DACK̄, D₀-D₁₅, DTACK̄ (READY), and DONĒ (OUTPUT) traces are shown repeating across four consecutive burst sub-cycles (each a block of T0…Tn2 periods), with the same numbered callouts (㉖-㊴, ⑩④, ⑩⑤, ⑩⑥) marking DACK̄ cycle/pulse-width timing and the DTACK̄/READY response in each burst segment.

Note: DACK̄ high width must satisfy spec ⑩⑥. Unless spec ⑩⑥ is satisfied, DTACK̄ and the read data responses to the succeeding cycle are delayed. When the ACRTC is used with synchronous bus timing, the specifications ⑩④, ⑩⑤ and ⑩⑥ must be satisfied.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 250)*

**Figure 23. DMA Write Cycle Timing (Memory ↔ ACRTC)** — A rotated (landscape) timing-diagram page for a DMA write, using traces 2CLK, DREQ̄, R/W̄, DACK̄, D₀-D₁₅, DTACK̄ (READY), DONĒ (OUTPUT), and DONĒ (INPUT). As in Figure 21, two DREQ̄ branches are shown for DRC="1" and DRC="0". Numbered callouts ㉖-㊵ mark the same class of setup/hold/delay timings as the DMA read cycle, applied here to the write-data valid window on D₀-D₁₅ and the DONĒ input/output handshake.

Note: *DONĒ must be asserted low while DACK̄ remains low. DONĒ low width must satisfy spec ㊳.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 251)*

**Figure 24. DMA Write Cycle Timing (Memory ↔ ACRTC): Burst Mode** — A rotated (landscape) timing-diagram page, the burst-mode counterpart to Figure 23, repeating the DMA write handshake (2CLK, DREQ̄, R/W̄, DACK̄, D₀-D₁₅, DTACK̄ (READY), DONĒ (OUTPUT), DONĒ (INPUT)) across four consecutive burst sub-cycles with the same numbered callouts.

Note: DACK̄ high width must satisfy the spec ㉚. Unless spec ㉚ is satisfied, DTACK̄ response to the succeeding cycle is delayed. When the ACRTC is used with synchronous bus timing, the specifications ⑩④, ⑩⑤ and ⑩⑥ must be satisfied.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 252)*

**Figure 25. Display Cycle Timing** — A standard (portrait) timing diagram showing traces 2CLK, AS̄, MAD₀-MAD₁₅, MA₁₆/RA₀-MA₁₉/RA₃ (and RA), MCYC, MRD̄, and DRAW̄, across two consecutive display memory-access cycles. 2CLK is a continuous clock waveform switching between 0.7V and 2.2V thresholds. AS̄ pulses low once per cycle (timing callouts ㊿, ㊽, ⑤①). MAD₀-MAD₁₅ shows an address-valid window referenced to Vcc-2.0V/0.8V (callouts ⑤②, ⑩⑩, ⑤③, ⑤④). MA₁₆/RA₀-MA₁₉/RA₃/RA transitions are marked by callouts ⑤⑦, ⑩②, and ⑤⑧. MCYC toggles with callouts ⑤⑨ marking its delay from the address-strobe edges. MRD̄ goes active (callouts ⑥⓪, ⑥①) and DRAW̄ goes active (callouts ⑥②, ⑥③) during the display (non-drawing) portion of the cycle.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 253)*

**Figure 26. Frame Memory Read Cycle Timing (ACRTC ← Frame Memory)** — A standard (portrait) timing diagram, structurally similar to Figure 25, showing 2CLK, AS̄, MAD₀-MAD₁₅, MA₁₆/RA₀-MA₁₉/RA₃/RA₄, MCYC, MRD̄, and DRAW̄. Here the MAD₀-MAD₁₅ trace is explicitly split into an "Address" phase (referenced to Vcc-2.0V/0.8V, callouts ㊿,⑩⑩,⑤③,⑤④) followed by a "Data" phase (referenced to 2.2V/0.7V, callouts ⑤⑤,⑤⑥) within the same bus cycle, illustrating the address-then-data multiplexed transfer on the frame-memory bus during an ACRTC read from frame memory. MA₁₆/RA₀-MA₁₉/RA₃/RA₄ transitions are marked by callouts ⑤⑦,⑩②,⑤⑧; MCYC by ⑤⑨; MRD̄ by ⑥⓪,⑥①; DRAW̄ by ⑥②,⑥③.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 254)*

**Figure 27. Frame Memory Write Cycle Timing (ACRTC → Frame Memory)** — A standard (portrait) timing diagram, similar to Figure 26 but for a write cycle: traces 2CLK, AS̄, MAD₀-MAD₁₅ (again split into an "Address" phase and a "Data" phase, both referenced to Vcc-2.0V/0.8V, callouts ㊿,⑩⑩,⑤③,⑥④), MA₁₆/RA₀-MA₁₉/RA₃/RA₄ (callouts ⑤⑦,⑩②,⑤⑧), MCYC (⑤⑨), MRD̄ (⑥⓪,⑥①), and DRAW̄ (⑥②,⑥③), illustrating the address-then-data multiplexed transfer when the ACRTC writes to frame memory.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 255)*

**Figure 28. Frame Memory Refresh/Video Attributes Output Cycle Timing** — A standard (portrait) timing diagram covering two back-to-back cycle types, bracketed at the top: a "Refresh Cycle" followed by an "Attribute Control Information Output Cycle". Traces: 2CLK, AS̄, MAD₀-MAD₁₅, MA₁₆/RA₀-MA₁₉/RA₃/RA (shown going "Low" during these cycles), MCYC, MRD̄, DRAW̄, and HSYNC̄.

During the Refresh Cycle, MAD₀-MAD₁₅ carries a "Refresh Address" (referenced to Vcc-2.0V/0.8V, callouts ㊿,⑩⑩,⑤③,⑤④), and MCYC/MRD̄/DRAW̄/HSYNC̄ transition with callouts ⑤⑨,⑥⓪,⑥②,⑥⑦ respectively.

During the Attribute Control Information Output Cycle, MAD₀-MAD₁₅ again carries a "Refresh Address" (marked with an asterisk — footnoted "When AS̄ is high, a 0 is output") followed by the "ATR" (attribute) value, with callouts ⑧⑦,⑨⓪ marking the ATR delay times and ⑧⑧,⑨① marking the ATR hold times; MCYC/MRD̄/DRAW̄ repeat with callouts ⑥①,⑥③,⑥⑦.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 256)*

**Figure 29. Display Control Signal Output Timing** — A standard (portrait) timing diagram showing 2CLK and MCYC (with callouts ⑤⑨ marking MCYC's edges relative to 2CLK), followed by the paired output traces HSYNC̄/VSYNC̄ (callouts ⑥⑦,⑥⑧), DISP̄1/DISP̄2 (callout ⑥⑨), CUD̄1/CUD̄2 (callout ⑦⓪), EXSYNC̄ (OUTPUT) (callout ⑦①), and CHR (callout ⑦②). Each pair of signal traces shows a falling edge referenced to 0.8V and, after a break in the timeline (denoted by a small break/slash mark), a rising edge referenced to Vcc-2.0V, with the same numbered delay callout applied at both edges — illustrating that each output signal's delay from MCYC is specified consistently whether the signal is transitioning low or high.

---

## HD63484

*(source page 257)*

**Figure 30. EXSYNC̄ Input Timing** — Two stacked timing diagrams. The top one shows 2CLK, EXSYNC̄ (FROM MASTER), and HSYNC̄ (SLAVE): EXSYNC̄ is asserted (hatched transition region referenced to 0.7V/2.2V, callouts ⑦⑤,⑦⑦,⑦⑥) and, after an interval labeled "11 Cycle (2CLK)", the slave's HSYNC̄ responds (callout ⑥⑦, referenced to 0.8V).

The bottom diagram details the "(EXSYNC Rise Cycle)" relative to a "(Sync Cycle)" of labeled clock periods T0-T6: traces 2CLK, EXSYNC̄ (with the same ⑦⑤,⑦⑦,⑦⑥ callouts), and two alternative MCYC traces — one labeled "(Phase Shifted)" and one "(Phase Not Shifted)" — with curved arrows showing how the EXSYNC̄ rising edge realigns (phase-shifts) the MCYC clock when it falls within the marked window. Caption note: "(When the leading edge of EXSYNC̄ enters this period, ACRTC shifts the internal phase as shown.)"

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

**Figure 31. LPSTB Input Timing (Single Access Mode)** — A timing diagram showing 2CLK (with a "Single Access Mode (Light Pen Rise Cycle)" bracket at the transition point), a signal labeled "M", and MAD₀-MAD₁₅ carrying successive memory addresses labeled M, M+1, M+2, M+3. Below, the LPSTB trace shows two hatched pulse regions referenced to 0.7V/2.2V, with callouts ⑦⑨ (setup before the first pulse), ⑦⑧ and ⑧⓪ (marking the pulse/uncertain-time windows around the M/M+1 boundary), and ⑧① (the long inhibit interval spanning M+1 through M+3 before LPSTB can rise again). Annotation with an arrow: "When LPSTB rises in this period, memory address M + 2 is set in the light pen address register."

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 258)*

**Figure 32. LPSTB Input Timing (Dual Access Mode)** — A timing diagram labeled "Interleave Mode/Superimpose Mode (Dual Access Mode 0/1)" with a bracket marking "One Displaying Period" across two 2CLK cycles. Traces: 2CLK, M, MAD₀-MAD₁₅ (carrying addresses M, M+1, M+2, each footnoted "Note 3"), and two separate LPSTB traces (one below the other) each with their own hatched pulse windows and callouts ⑦⑨,⑦⑧,⑧⓪,⑧① — the first LPSTB trace labeled "(1) Note 1" and the second "(2) Note 2".

Notes:
1. When LPSTB rises in the period (1), memory address M + 1 is set in the lightpen address register.
2. When LPSTB rises in the period (2), memory address M + 2 is set in the lightpen address register.
3. In the interleave mode, memory addresses M, M+1, M+2 denote the display address. In the superimpose mode, memory addresses M, M+1, M+2 denote the display address of the background screen.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

**Figure 33. RES̄ Input and DACK̄ Input Timing (System Reset and 16-Bit/8-Bit Selection)** — A small timing diagram with two traces: DACK̄ (a pulse referenced to 0.7V, with callouts ⑧② and ⑧③ marking its setup/hold relative to RES̄) and RES̄ (a pulse referenced to 0.7V/2.2V, with callout ⑧④ marking its pulse width).

**Figure 34. IRQ̄ Output Timing** — A small timing diagram with 2CLK (referenced to 2.2V) and IRQ̄ (falling to 0.8V then rising to Vcc-2.0V), with callouts ⑧⑤ and ⑧⑥ marking the two IRQ̄ delay times relative to the 2CLK edges.

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

---

## HD63484

*(source page 259)*

**Figure 35. IRQ̄ Output Timing (Example: Read FIFO Full Interrupt Enable)** — A timing diagram showing 2CLK across two labeled intervals ("4 to 5 Cycles (tcyc)" and "3 Cycles (tcyc)"), CS̄ (two pulses referenced to 0.7V/2.2V, callouts ⑩ each), D₀-D₁₅ (a hatched "Read Data" valid window, callouts ㉑,⑭), and IRQ̄ (rising to Vcc-2.0 then falling to 0.8V, callouts ⑧⑥,⑧⑤).

This is an IRQ̄ output timing example. In this case, IRQ̄ is generated by status flag RFF (Read FIFO Full).

When issuing read commands (RD) which transfer data exceeding Read FIFO space (8 words), the FIFO becomes full, and the command execution pauses (RFF: set, IRQ̄: generated). By reading out 1-word data, spare occurs in the FIFO, and the ACRTC resets RFF flag and then negates IRQ̄, while on the other hand the ACRTC resumes the internal operation (command execution) to fill the FIFO, and sets RFF flag and then asserts IRQ̄ again.

In this case, the timing from IRQ̄ negate to assert is 3 cycles (tcyc).

Note: VIH (input high voltage minimum value) is 2.2 V in 4-, 6-, 8-MHz version. Note that in 9.8 MHz version, VIH is 2.4 V.

**Figure 36. Test Load Circuit A** — Schematic: a "Test Point" node connects to a capacitor C and resistor R to ground, and through a diode network to a pull-up resistor RL to 5.0V and to ground via additional diodes (representing the diode bridge load used for AC testing). Accompanying table:

| Signal | Load Condition |
|---|---|
| D₀-D₁₅, DTACK̄, DREQ̄, MAD₀-MAD₁₅, MA₁₆/RA₀-MA₁₉/RA₃, RA₄, VSYNC̄, HSYNC̄, EXSYNC̄, MCYC, AS̄, MRD̄, DRAW̄, CHR, DISP1, DISP2, CUD1, CUD2 | RL = 1.8 kΩ, C = 40 pF, R = 10 kΩ. All diodes are 1S2074(H)'s or the equivalent. |

**Figure 37. Test Load Circuit B** — Schematic: IRQ̄, DONĒ node connects to a pull-up resistor RL to 5.0V and a capacitor C to ground. RL = 1.8 kΩ, C = 40 pF.
