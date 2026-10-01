# Hitachi HD63484 ACRTC Advanced CRT Controller — User's Manual

*Converted from the 343-page scanned PDF via page-by-page vision OCR/transcription. Diagrams and figures too complex for tables are described in italicized prose. Footers are omitted; page numbers are retained via the source-page markers.*

*Conversion status: STOPPED per user instruction after source (printed) page 308 (PDF page 319). Covers Sections 1 through 5 in full, Section 6 (Function of Commands) commands [1] ORG through [38] RGCPY, and the appendix "Use of Arc and Ellipse Arc Command". Per user instruction, the following Electrical Specification section (and anything beyond it) was skipped as not needed.*

---
*(source page i)*

**HITACHI** — HD63484 ACRTC ADVANCED CRT CONTROLLER USER'S MANUAL

*(faint preliminary cover page; "#U75" printed at lower left)*

---
*(source page ii)*

# HD63484 ACRTC
# ADVANCED CRT CONTROLLER
# USER'S MANUAL

**HITACHI**

*("#U75" printed at lower left)*

---
*(source page iii)*

November 1984 — Printed in USA

When using this manual, the reader should keep the following in mind:

1. This manual may, wholly or partially, be subject to change without notice.
2. All rights reserved: No one is permitted to reproduce or duplicate, in any form, the whole or part of this manual without Hitachi's permission.
3. Hitachi will not be responsible for any damage to the user that may result from accidents or any other reasons during operation of his unit according to this manual.
4. This manual neither ensures the enforcement of any industrial properties or other rights, nor sanctions the enforcement right thereof.

---
*(source page iv)*

## TABLE OF CONTENTS

**1. ACRTC INTRODUCTION**
| | | |
|---|---|---|
|1.1|Applications|3|
|1.2|System Configuration|5|
|1.3|Block Diagram|6|
|1.4|Signal Description|8|
|1.5|Address Space|10|
|1.6|Registers|12|
|1.7|Commands|15|
|1.8|Graphic Drawing|16|

**2. SYSTEM INTERFACE**
| | | |
|---|---|---|
|2.1|Basic Clock|17|
|2.2|CRT Interface|17|
|2.3|MPU Interface|28|

**3. DISPLAY FUNCTION**
| | | |
|---|---|---|
|3.1|Logical Display Screens|30|
|3.2|Cursor Control|37|
|3.3|Scrolling|40|
|3.4|Raster Scan Modes|43|
|3.5|Zooming|45|
|3.6|Light Pen|46|

**4. SIGNAL DESCRIPTION**
| | | |
|---|---|---|
|4.1|Pin Arrangement|47|
|4.2|Signal Functions|48|

**5. REGISTER DESCRIPTION**
| | | |
|---|---|---|
|5.1|Internal Register Access|57|
|5.2|Address Register|60|
|5.3|Status Register|61|
|5.4|FIFO Entry|64|
|5.5|Command Control Register|65|
|5.6|Operation Mode Register|69|
|5.7|Display Control Register|75|
|5.8|Timing Control RAM|79|
|5.9|Display Control RAM|96|
|5.10|Drawing Control Registers|113|

---
*(source page v)*

## TABLE OF CONTENTS (continued)

**6. COMMANDS**
| | | |
|---|---|---|
|6.1|Command Overview|125|
|6.2|Command Format|125|
|6.3|Command Transfer Modes|126|
|6.4|Register Access Commands|127|
|6.5|Data Transfer Commands|128|
|6.6|Graphic Drawing Commands|135|
|6.7|Graphic Drawing Processor|162|
|6.8|Graphic Drawing Operation|166|

| | |
|---|---|
|FUNCTION OF COMMANDS|171|
|USE OF ARC AND ELLIPSE ARC COMMAND|301|
|ELECTRICAL SPECIFICATION|309|

---
*(source page vi)*

## Abbreviations

| Name | Description |
|---|---|
| AARC | Absolute Arc |
| ABT | Abort |
| ACM | Access Mode |
| ACP | Access Priority |
| ADR | Area Definition Register |
| AEARC | Absolute Ellipse Arc |
| AFRCT | Absolute Filled Rectangle |
| AGCPY | Absolute Graphic Copy |
| ALINE | Absolute Line |
| AMOVE | Absolute Move |
| APLG | Absolute Polygon |
| APLL | Absolute Poly Line |
| AR | Address Register |
| ARCT | Absolute Rectangle |
| ARD | Area Detect |
| ARE | Area Detect Interrupt Enable |
| AREA | Area Detect Mode |
| ATC | Attribute Code |
| ATR | Attribute Control |
| BCA | Block Cursor Address |
| BCA1 | Block Cursor Address 1 |
| BCA2 | Block Cursor Address 2 |
| BCER1 | Block Cursor End Raster 1 |
| BCER2 | Block Cursor End Raster 2 |
| BCR | Blink Control Register |
| BCSR1 | Block Cursor Start Raster 1 |
| BCSR2 | Block Cursor Start Raster 2 |
| BCUR1 | Block Cursor Register 1 |
| BCUR2 | Block Cursor Register 2 |
| BCW1 | Block Cursor Width 1 |
| BCW2 | Block Cursor Width 2 |
| BLINK1 | Blink 1 |
| BLINK2 | Blink 2 |
| BOFF1 | Blink Off 1 |
| BOFF2 | Blink Off 2 |
| BON1 | Blink On 1 |
| BON2 | Blink On 2 |

---
*(source page vii)*

## Abbreviations (continued)

| Name | Description |
|---|---|
| CCR | Command Control Register |
| CDM | Command DMA Mode |
| CDR | Cursor Definition Register |
| CED | Command End |
| CEE | Command End Interrupt Enable |
| CER | Command Error |
| CHR | Character |
| CLR | Clear |
| CL0 | Color 0 Register |
| CL1 | Color 1 Register |
| CM | Cursor Mode |
| CCMP | Color Comparison Register |
| COFF1 | Cursor Off 1 |
| COFF2 | Cursor Off 2 |
| CON1 | Cursor On 1 |
| CON2 | Cursor On 2 |
| CP | Current Pointer |
| CPY | Copy |
| CRCL | Circle |
| CRE | Command Error Interrupt Enable |
| CSK | Cursor Display Skew |
| CXE | Cursor X End |
| CXS | Cursor X Start |
| CYE | Cursor Y End |
| CYS | Cursor Y Start |
| DCR | Display Control Register |
| DDM | Data DMA Mode |
| DMOD | DMA Modify |
| DN | Display Number |
| DOT | Dot |
| DP | Drawing Pointer |
| DPAH | Drawing Pointer Address High |
| DPAL | Drawing Pointer Address Low |
| DPD | Drawing Pointer Dot |
| DRC | DMA Request Control |
| DRD | DMA Read |
| DSD | Destination Scan Direction |

---
*(source page viii)*

## Abbreviations (continued)

| Name | Description |
|---|---|
| DSK | DISP Skew |
| DSP | DISP Signal Control |
| DWT | DMA Write |
| EDG | Edge Color Register |
| ELPS | Ellipse |
| FE | FIFO Entry |
| FRA | First Raster Address |
| FRA0 | First Raster Address 0 |
| FRA1 | First Raster Address 1 |
| FRA2 | First Raster Address 2 |
| FRA3 | First Raster Address 3 |
| GAI | Graphic Address Increment Mode |
| GBM | Graphic Bit Mode |
| GCR | Graphic Cursor Register |
| HC | Horizontal Cycle |
| HDR | Horizontal Display Register |
| HDS | Horizontal Display Start |
| HDW | Horizontal Display Width |
| HSD | Horizontal Scroll Dot |
| HSR | Horizontal Sync Register |
| HSW | Horizontal Sync Width |
| HWR | Horizontal Window Display Register |
| HWS | Horizontal Window Start |
| HWW | Horizontal Window Width |
| HZ | Horizontal Zoom |
| HZF | Horizontal Zoom Factor |
| IE | Interrupt Enable |
| LPAH | Light Pen Address High |
| LPAL | Light Pen Address Low |
| LPAR | Light Pen Address Register |
| LPD | Light Pen Strobe Detect |
| LPE | Light Pen Strobe Interrupt Enable |
| LRA | Last Raster Address |
| LRA0 | Last Raster Address 0 |
| LRA1 | Last Raster Address 1 |
| LRA2 | Last Raster Address 2 |
| LRA3 | Last Raster Address 3 |

---
*(source page ix)*

## Abbreviations (continued)

| Name | Description |
|---|---|
| M/S | Master/Slave |
| MM | Modify Mode |
| MOD | Modify |
| MASK | Mask Register |
| MW | Memory Width |
| MW0 | Memory Width 0 |
| MW1 | Memory Width 1 |
| MW2 | Memory Width 2 |
| MW3 | Memory Width 3 |
| MWR | Memory Width Register |
| MWR0 | Memory Width Register 0 |
| MWR1 | Memory Width Register 1 |
| MWR2 | Memory Width Register 2 |
| MWR3 | Memory Width Register 3 |
| OMR | Operation Mode Register |
| OPM | Operation Mode |
| ORG | Origin |
| PAINT | Paint |
| PE | Pattern End |
| PEX | Pattern End X |
| PEY | Pattern End Y |
| PP | Pattern Pointer |
| PPX | Pattern Pointer X |
| PPY | Pattern Pointer Y |
| PRA | Pattern RAM Address |
| PRC | Pattern RAM Control Register |
| PS | Pattern Start |
| PSE | Pause |
| PSX | Pattern Start X |
| PSY | Pattern Start Y |
| PTN | Pattern |
| PZCX | Pattern Zoom Count X |
| PZCY | Pattern Zoom Count Y |
| PZX | Pattern Zoom X |
| PZY | Pattern Zoom Y |
| RAM | RAM Mode |
| RARC | Relative Arc |

---
*(source page x)*

## Abbreviations (continued)

| Name | Description |
|---|---|
| RAR | Raster Address Register |
| RAR0 | Raster Address Register 0 |
| RAR1 | Raster Address Register 1 |
| RAR2 | Raster Address Register 2 |
| RAR3 | Raster Address Register 3 |
| RC | Raster Count |
| RCR | Raster Count Register |
| RD | Read |
| REARC | Relative Ellipse Arc |
| RFE | Read FIFO Full Interrupt Enable |
| RFF | Read FIFO Full |
| RFR | Read FIFO Ready |
| RFRCT | Relative Filled Rectangle |
| RGCPY | Relative Graphic Copy |
| RLINE | Relative Line |
| RMOVE | Relative Move |
| RN | Register Number |
| RPLG | Relative Polygon |
| RPLL | Relative Poly Line |
| RPR | Read Parameter Register |
| RPTN | Read Pattern RAM |
| RRCT | Relative Rectangle |
| RRE | Read FIFO Ready Interrupt Enable |
| RSM | Raster Scan Mode |
| RWP | Read/Write Pointer |
| RWPH | Read/Write Pointer High |
| RWPL | Read/Write Pointer Low |
| S | Source Scan Direction |
| SAH | Start Address High |
| SAL | Start Address Low |
| SAR | Start Address Register |
| SAR0 | Start Address Register 0 |
| SAR1 | Start Address Register 1 |
| SAR2 | Start Address Register 2 |
| SAR3 | Start Address Register 3 |
| SCLR | Selective Clear |
| SCPY | Selective Copy |

---
*(source page xi)*

## Abbreviations (continued)

| Name | Description |
|---|---|
| SD | Scan Direction |
| SDA | Start Dot Address |
| SE | Split Screen Enable |
| SE0 | Split Screen 0 Enable |
| SE1 | Split Screen 1 Enable |
| SE2 | Split Screen 2 Enable |
| SE3 | Split Screen 3 Enable |
| SL | Slant |
| SPL | Split |
| SP0 | Split Screen 0 Width |
| SP1 | Split Screen 1 Width |
| SP2 | Split Screen 2 Width |
| SR | Status Register |
| SRA | Start Raster Address |
| SSW | Split Screen Width |
| STR | Start |
| VC | Vertical Cycle |
| VDR | Vertical Display Register |
| VDS | Vertical Display Start |
| VSR | Vertical Sync Register |
| VSW | Vertical Sync Width |
| VWR | Vertical Window Register |
| VWS | Vertical Window Start |
| VWW | Vertical Window Width |
| VZF | Vertical Zoom Factor |
| WEE | Write FIFO Empty Interrupt Enable |
| WFE | Write FIFO Empty |
| WFR | Write FIFO Ready |
| WPR | Write Parameter Register |
| WPTN | Write Pattern RAM |
| WRE | Write FIFO Ready Interrupt Enable |
| WSS | Window Smooth Scroll |
| WT | Write |
| XMAX | X Maximum |
| XMIN | X Minimum |
| YMAX | Y Maximum |
| YMIN | Y Minimum |
| ZFR | Zoom Factor Register |

---
*(source page 1)*

## HD63484 ACRTC (Advanced CRT Controller)

Powerful visual interfaces are a key component of advanced system architectures. A proven technique uses raster scanned CRT technology for the display of graphics and text information.

Systems which use first generation CRT Controllers (CRTCs) are constrained by hardware/software design time, manufacturing cost, and limited MPU bandwidth.

To meet the functional requirements for powerful visual interfaces, and to support their use in high volume, cost sensitive applications, advanced circuit design and VLSI CMOS manufacturing technologies have been used to create a next generation CRTC, the HD63484 ACRTC (Advanced CRT Controller).

The ACRTC concept is to incorporate major functionality, formerly requiring external hardware and software, on-chip. In this way, both higher performance and reduced system cost benefits are achieved.

* High Level Command Language Increases Performance and Reduces Software Development Cost.
  - ACRTC Converts Logical X-Y Coordinates to Physical Frame Buffer Addresses.
  - 38 Commands including 23 Graphic Drawing Commands — LINE, RECTANGLE, POLYLINE, POLYGON, CIRCLE, ELLIPSE, ARC, ELLIPSE ARC, FILLED RECTANGLE, PAINT, PATTERN and COPY.
  - On-chip 32 Byte Pattern RAM.
  - Conditional Drawing function (8 conditions) for Drawing Patterns, Color Mixing and Software Windowing.
  - Drawing Area Control with Hardware Clipping and Hitting.
  - Maximum Drawing Speed of 2 Million Logical Pixels per Second is the same for Monochrome and Color applications.

---
*(source page 2)*

* High Resolution Display with Advanced Screen Control
  - Up to 4096 by 4096 Bit Map GRAPHIC Display and/or 256 Line by 256 Character by 32 Raster CHARACTER Display.
  - Separate Bit Map GRAPHIC (2M byte) and CHARACTER (128K byte) Address Spaces with Combined GRAPHIC/CHARACTER Display.
  - Three Horizontal Split Screens and One Window Screen. Size and Postition Fully Programmable.
  - Independent Horizontal and Vertical Smooth Scroll for each Screen.
  - 1 to 16 Zoom Magnitude — Independent X and Y Zoom Factors.
  - Logical Pixel Specification as 1, 2, 4, 8 or 16 Bits for Monochrome, Gray Scale and Color Displays.
  - Programmable Address Increment Supports Frame Buffer Memory Widths to 128 Bits for Video Bit Rates > 500 MHz.
  - Unique Interleaved Access Mode for Screen Superimposition or 'Flashless' Displays.
  - ACRTC provides Dynamic RAM Refresh Address.
* High Performance MPU Interface
  - Optimized Interface with the HD68000 MPU and HD68450 DMAC.
  - 8 or 16 Bit Bus — Compatible With Other MPUs.
  - Separate on-chip 16 Byte READ and WRITE FIFOs.
  - Maskable Interrupts Including FIFO status.
* Versatile CRT Interface
  - Full Programmability of CRT Timing Signals.
  - Three Raster Scanning Modes.
  - Master or Slave Synchronization to Multiple ACRTCs or Other Video Generating Devices.
  - Two Hardware Cursors. Three Cursor Modes.
  - Progreammable Cursor and Display Timing Skew.
  - Eight User Defineable Video Attributes.
  - Light Pen Detection.
* VLSI CMOS Process

---
*(source page 3)*

# 1. ACRTC INTRODUCTION

### 1.1 Applications

The overall function of a visual interface is logically partitioned into layers. At the lowest layer are CRT timing and control signal generation. At the top layer are general purpose drawing procedures which provide a high-level interface to the users OS or applcation software. At this layer, a number of popular standards have emerged including GKS, Core, NAPLP, GSX and others.

Figure 1.1 shows how the ACRTC performs the key functions or logical drawing algorithm and physical drawing execution. Formerly, these function were performed by external hardware and/or MPU software.

**Figure 1.1 ACRTC vs. CRTC** — Two stacked-layer diagrams compared side by side. The left column lists the full function stack top-to-bottom: Drawing Procedures / Co-ordinates Conversion / Drawing Pre-process / Drawing Process (Algorithms) / Drawing Execution / Display Control / Synchronizing / Signals Generation / Others. The middle column ("conventional CRTC" system) shows this stack split into two blocks: "MPU Software" covering everything down through Drawing Execution, and "CRTC" covering Display Control through Others. The right column (ACRTC system) shows the same stack split differently: "MPU Software" now covers only Drawing Procedures through Drawing Pre-process, while "ACRTC" covers Drawing Process (Algorithms) through Others — i.e. the ACRTC absorbs the drawing algorithm and execution work that used to require MPU software.

---
*(source page 4)*

As shown, the ACRTC reduces the 'gap' between device functionality and high level graphics procedures. Since the ACRTC device itself provides capabilities closely related to those of high level graphics packages, the effort (hardware and software design time and cost) required to develop a visual interface is significantly reduced.

Noting the traditional and emerging applications for visual interfaces, figure 1.2 shows that a single ACRTC is suitable for a broad range of products in both alphanumeric and graphics areas.

Multiple ACRTCs can achieve performance beyond that of any first generation CRTC configuration.

**Figure 1.2 Application Spectrum** — A diagram mapping application types to ACRTC coverage. Left side lists applications top-to-bottom: Flight Simulator / Work Station / CAD/CAM Terminal (top group), Game Machine / Business Computer / High-end Personal Computer / Word Processor (middle group), Videotex, and Dumb Terminal (bottom). Right side shows a tapered block diagram: the top group maps to "ACRTC × n" (multiple ACRTCs), narrowing down through a single "ACRTC × 1" block, with a diagonal division inside it separating "Graphic" (upper, wider) from "Character" (lower, narrower) coverage, down to "CRTC" at the bottom for the simplest applications (Dumb Terminal). The vertical extent of the ACRTC block spans from Flight Simulator down through Videotex, illustrating that a single ACRTC covers most of the application spectrum while only the simplest terminals need just a CRTC.

---
*(source page 5)*

### 1.2 System Configuration

**Figure 1.3 System Configuration** — Block diagram showing a CPU (8/16b), System Memory, and DMAC connected via shared Address/Data/Control buses to the ACRTC. The ACRTC's host-side pins shown: RES̄, ĪRQ, D0-15, DTACK̄, CS̄, RS, R/W̄, DREQ̄, DACK̄, DONĒ, 2CLK, Vcc/Vss. On the frame-buffer/CRT side, the ACRTC connects via MA16-19 and MRD̄ (through a latch L) and AS̄ to a Frame Buffer (Max. 2MB), and via MAD0-15 to both the Frame Buffer and a Dot Shifter. The ACRTC also outputs DISP1,2, CUD1,2, LPSTB, EXSYNC̄, VSYNC̄, HSYNC̄. The Dot Shifter feeds a CRT, which outputs Video Signal.

Existing CRTCs provide a single bus interface to the frame buffer which must be shared with the host MPU. However, the refresh of large frame buffers and the requirement to access the frame buffer for drawing operations can quickly saturate this shared bus bandwidth.

As shown, the ACRTC uses separate host MPU and frame buffer bus interfaces. This allows the ACRTC full access to the frame buffer for display refresh, DRAM refresh and drawing operations while minimizing the ACRTCs usage of the MPU system bus. Thus, overall system performance is maximized. A related benefit is that a large frame buffer (2M byte for each ACRTC) is useable even if the host MPU has a smaller address space or segment size restriction.

The ACRTC can utilize an external DMA Controller. This increases system throughput when large amounts of command, parameter and data information must be transferred to the ACRTC. Also, advanced DMAC features, such as the HD68450 DMACs 'chaining' modes, can be used to develop powerful graphics system architectures.

However, more cost sensitive or less performance sensitive applications do not require a DMAC. The interface to the ACRTC can be handled completely under MPU software control.

While both ACRTC bus interfaces (Host MPU and Frame Buffer) exploit 16 bit data paths for maximum performance, the ACRTC also offers an 8 bit MPU mode for easy connection to popular 8 bit bus structures.

---
*(source page 6)*

### 1.3 Block Diagram

**Figure 1.4 Block Diagram** — Internal block diagram of the ACRTC showing five major functional blocks. On the left, an "MPU Interface" block receives D0~15 (16 bits), CS̄, RS, R/W̄, DTACK̄, and connects internally via Register Address and Data buses to the other blocks. Above it, a combined "DMA Control Unit" / "Interrupt Control Unit" block handles DREQ̄, DACK̄, DONĒ (DMA) and IRQ̄ (interrupt), gated by RES̄. Three parallel microprogrammed processors sit in the middle: "Drawing Processor" (outputs 20-bit Drawing Address and 16-bit Drawing Data, plus Draw Enable and Write, to the CRT Interface), "Display Processor" (outputs 20-bit Display Address, 5-bit Raster Address, CHR and CCUD to the CRT Interface, and exchanges GCUD with the Timing Processor), and "Timing Processor" (outputs GCUD (2-bit), HSYNC, VSYNC, EXSYNC, DISP (2-bit), MCLK, AS, 2CLK). On the right, a "CRT Interface" block takes the Drawing/Display/Raster addresses and timing signals and drives the external pins: DRAW̄, MRD, MAD0~15 (16-bit bidirectional), MA16/RA0~MA19/RA3, RA4, CHR, LPSTB, CUD1~2, HSYNC̄, VSYNC̄, EXSYNC̄, DISP1~2, MCYC, AS̄, 2CLK. Power pins Vcc, Vss (2 each) feed the MPU Interface and Timing Processor blocks.

---
*(source page 7)*

The ACRTC consists of five major functional blocks. These functional blocks operate in parallel to achieve maximum performance. Two of the blocks perform the external bus interface for the host MPU and CRT respectively.

○ **MPU Interface**
Manages the asynchronous host MPU interface including the programmable interrupt control unit and DMA handshaking control unit.

○ **CRT Interface**
Manages the frame buffer bus and CRT timing input and output control signals. Also, the selection of either display refresh address or drawing address outputs is performed.

The other three blocks are separately microprogrammed processors which operate in parallel to perform the major functions of drawing, display control and timing.

○ **Drawing Processor**
Interprets commands and command parameters issued by the host bus (MPU and/or DMAC) and performs the drawing operations on the frame buffer memory. This processor is responsible for the execution of ACRTC drawing algorithms and conversion of logical pixel X-Y addresses to physical frame buffer addresses.
Communication with the host bus is via separate 16 byte read and write FIFOs.

○ **Display Processor**
Manages frame buffer refresh addressing based on the user programmed specification of display screen organization. Combines and displays as many as 4 independent screen segments (3 horizontal splits and 1 window) using an internal high speed address calculation unit. Controls display refresh address outputs based on GRAPHIC (physical frame buffer address) or CHARACTER (physical frame buffer address + row address) display modes.

○ **Timing Processor**
Generates the CRT synchronization signals and other timing signals used internally by the ACRTC.
The ACRTCs software visible registers are similarly partitioned and reside in the appropriate internal processor depending on function. The registers in the Display and Timing processors are loaded with basic display parameters during system initialization. During operation, the host primarily communicates with the ACRTCs Drawing processor via the on-chip FIFOs.

---
*(source page 8)*

### 1.4 Signal Description

Following is a brief description of the ACRTC pin functions organized as MPU Interface, DMAC Interface, CRT Interface and Power Supply. The detailed signal description is provided in section 4.

**MPU Interface**

**RES̄ — Input**
Hardware reset input to the ACRTC.

**D0 – D15 — Input/Output**
The bidirectional data bus for communication with the host MPU or DMAC. In 8 bit data bus mode, D0-D7 are used.

**R/W̄ — Input**
Controls the direction of host ⟷ ACRTC transfers.

**CS̄ — Input**
Enables data transfers between the host and the ACRTC.

**RS — Input**
Selects the ACRTC register to be accessed and is normally connected to the least significant bit of the host address bus.

**DTACK̄ — Output**
Provides asynchronous bus cycle timing and is compatible with the HD68000 MPU DTACK̄ input.

**IRQ̄ — Output**
Generates interrupt service requests to the host MPU.

**DMAC Interface**

**DREQ̄ — Output**
Generates DMA service requests to the host DMAC.

**DACK̄ — Input**
Receives DMA acknowledge timing from the host DMAC.

**DONĒ — Input/Output**
Terminates DMA transfer and is compatible with the HD68450 DMAC DONĒ signal.

---
*(source page 9)*

**CRT Interface**

**2CLK — Input**
Basic ACRTC operating clock derived from the dot clock.

**MAD0-15 — Input/Output**
Multiplexed frame buffer address/data bus.

**AS̄ — Output**
Address strobe for demultiplexing the frame buffer address/data bus (MAD0-15).

**MA16/RA0-MA19/RA3 — Output**
The high order address bits for graphic screens and the raster address outputs for character screens.

**RA4 — Output**
Provides the high order raster address bit (up to 32 rasters) for character screens.

**CHR — Output**
Indicates whether a graphic or character screen is being accessed.

**MCYC — Output**
Frame buffer memory access timing — one half the frequency of 2CLK.

**MRD — Output**
Frame Buffer data bus direction control.

**DRAW̄ — Output**
Differentiates between drawing cycles and CRT display refresh cycles.

**DISP1, DISP2 — Output**
Programmable display enable timing used to selectively enable, disable and blank logical screens.

**CUD1, CUD2 — Output**
Provides cursor timing determined by ACRTC programmed parameters such as cursor definition, cursor mode, cursor address, etc.

---
*(source page 10)*

**VSYNC̄ — Output**
CRT device vertical synchronization pulse.

**HSYNC̄ — Output**
CRT device horizontal synchronization pulse.

**EXSYNC̄ — Input/Output**
For synchronization between multiple ACRTCs and other video signal generating devices.

**LPSTB — Input**
Connection to an external light pen.

### 1.5 Address Space

The ACRTC allows the host to issue commands using logical X-Y coordinate addressing. The ACRTC converts these to physical linear word addresses with bit field offsets in the frame buffer.

Figure 1.5 shows the relationship between a logical X-Y screen address and the frame buffer memory, organized as sequential 16 bit words. The host may specify that a logical pixel consists of 1, 2, 4, 8 or 16 physical bits in the frame buffer. In the example, 4 bits per logical pixel is used allowing 16 colors or tones to be selected.

Up to four logical screens (Upper, Base, Lower and Window) are mapped into the ACRTC physical address space. The host specifies a logical screen physical start address, logical screen physical memory width (number of memory words per raster), logical pixel physical memory width (number of bits per pixel) and the logical origin physical address. Then, logical pixel X-Y addresses issued by the host or by the ACRTC Drawing processor are converted to physical frame buffer addresses. The ACRTC also performs bit extraction and masking to map logical pixel operations (in the example, 4 bits) to 16 bit word frame buffer accesses.

---
*(source page 11, landscape orientation)*

**Figure 1.5 Logical/Physical Addressing** — A three-part diagram (drawn landscape/rotated 90°) showing the mapping from physical frame buffer bits to logical screen coordinates to the displayed screen.

Left part, "Physical Addressing (Frame Buffer)": a column of 16-bit words (bit 0 at left, bit 15 at right) making up a memory width MW; one word is exploded to show "1 pixel data" as a narrow bit-field slice within the word. Further down, a word is shown with a start-address boundary "SAD" and, below that, a word with a hatched bit-field region indicating a masked/extracted pixel field within it.

Middle part, "Logical Addressing": four stacked parallelogram "screen" planes (representing up to four logical screens), each with its own local Origin and X/Y axes and a point (x,y), receding in perspective; each plane's rows correspond to MW physical words, with small circles marking where a given physical word's pixel data maps onto pixels along a row.

Right part, "Display Screen": the final composited screen with axes X (horizontal) and Y (vertical), an Origin, and a displayed point (x,y) at horizontal offset x and vertical offset y from the origin; "SAD" marks the start-address-derived top-left origin corner of the screen.

Arrows/lines connect: a given 16-bit physical word (bit 0-15) → its pixel data feeding into the corresponding logical-screen plane's row → and ultimately to the displayed (x,y) point on the CRT screen, illustrating the physical-word → logical-pixel → displayed-pixel address translation chain.

---
*(source page 12)*

### 1.6 Registers

**Figure 1.6 Accessible Registers** — Diagram of the ACRTC's internal register map, grouped by access method.

"Hardware Access" (top-left, 8-bit registers, bits 7-0): Address Register and Status Register — both reached directly by the host via the RS pin without going through the address-register mechanism.

"Direct Access" (left column, 16-bit registers, bits 15-0, reached after loading the Address Register): FIFO Entry, Command Control Register, Operation Mode Register, Display Control Register, and two larger register blocks — Timing Control Ram and Display Control Ram.

The FIFO Entry register connects (bidirectional arrow) to a pair of 16-bit "Write FIFO" and "Read FIFO" blocks (top right).

"FIFO Access" (right column, reached via the Read/Write FIFOs): the Read FIFO connects bidirectionally to a "Command Register", which in turn connects to two further blocks reached only through FIFO access — "Pattern Ram" and "Drawing Parameter Registers".

In short: Address Register/Status Register are hardware-accessed; FIFO Entry/Command Control/Operation Mode/Display Control registers and the Timing Control RAM/Display Control RAM are directly addressed; and the Command Register, Pattern RAM, and Drawing Parameter Registers are reached only indirectly through the Read/Write FIFOs.

---
*(source page 13)*

The ACRTC has over two hundred bytes of accessible registers. These are organized as Hardware, Directly and FIFO accessible.

○ **Hardware Accessible**
The ACRTC is connected to the host MPU as a standard peripheral which occupies two word locations of the host address space. The RS (Register Select) pin selects one of these two locations. When RS is low, reads access the Status Register and writes access the Address Register.
The Status Register summarizes the ACRTC state and is used by the MPU to monitor the overall operation of the ACRTC. The Address Register is used to program the ACRTC with the address of the specific directly accessible register which the MPU wishes to access.

○ **Directly Accessible**
These registers are accessed by prior loading of the Address Register with the chosen register address. Then, when the MPU accesses the ACRTC with RS=1, the chosen register is accessed.
The FIFO entry enables access to FIFO accessible registers using the ACRTC read and write FIFOs.
The Command Control Register is used to control overall ACRTC operation such as aborting or pausing commands, defining DMA protocols, enabling/disabling interrupt sources, etc.
The Operation Mode Register defines basic parameters of ACRTC operation such as frame buffer access mode, display or drawing priority, cursor and display timing skew factors, raster scan mode, etc.
The Display Control Register allows the independent enabling and disabling of each of the four ACRTC logical display screens (Base, Upper, Lower and Window). Also, this register contains the 8 bits of user defineable video attributes.
The Timing Control RAM contains registers which define ACRTC timing. This includes timing specification for CRT control signals (e.g. HSYNC̄, VSYNC̄), logical display screen size and display period, blink timing, etc.

---
*(source page 14)*

The Display Control RAM contains registers which define logical screen display parameters such as start addresses, raster addresses and memory width. Also included are the cursor(s) definition, zoom factor and light pen registers.

○ **FIFO Accessible**
For high performance drawing, key Drawing Processor registers are coupled to the host via the ACRTCs separate 16 byte read and write FIFOs.
ACRTC commands are sent from the MPU via the write FIFO to the Command register. As the ACRTC completes command execution, the next command is automatically fetched from the FIFO into the Command register.
The Pattern RAM is used to define drawing and painting 'patterns'. The Pattern RAM is accessed using the ACRTCs Read Pattern RAM (RPTN) and Write Pattern RAM (WPTN) register access commands.
The Drawing Parameter Registers define detailed parameters of the drawing process, such as color control, area control (hitting/clipping) and Pattern RAM pointers. The Drawing Parameter Registers are accessed using the ACRTCs Read Parameter Register (RPR) and Write Parameter Register (WPR) register access commands.

---
*(source page 15)*

### 1.7 Commands

**Figure 1.7 Commands** — Table of all 38 ACRTC commands grouped by type.

| Type | Mnemonic | Function |
|---|---|---|
| Register Access Commands | ORG | Set Origin Point |
| | RPR, WPR | Read/Write Parameter Registers |
| | RPTN, WPTN | Read/Write Pattern RAM |
| Data Transfer Commands | DRD, DWT, DMOD | DMA Read/Write/Modify |
| | RD, WT, MOD | Read/Write/Modify |
| | CLR | Clear |
| | CPY, SCPY | Copy |
| Graphic Drawing Commands | AMOVE, RMOVE | Move |
| | ALINE, RLINE | Line |
| | ARCT, RRCT | Rectangle |
| | APLL, RPLL | Polyline |
| | APLG, RPLG | Polygon |
| | CRCL | Circle |
| | ELPS | Ellipse |
| | AARC, RARC | Arc |
| | AEARC, REARC | Ellipse Arc |
| | AFRCT, RFRCT | Filled Rectangle |
| | PAINT | Paint |
| | DOT | Dot |
| | PTN | Pattern |
| | AGCPY, RGCPY | Graphic Copy |

The ACRTC has 38 commands classified into three groups — REGISTER ACCESS, DATA TRANSFER and GRAPHIC DRAWING.

Five REGISTER ACCESS commands allow access to Drawing processor Drawing Parameter Registers and the Pattern RAM.

Ten DATA TRANSFER commands are used to move data between the host system memory and the frame buffer, or within the frame buffer.

Twenty three GRAPHIC DRAWING commands cause the ACRTC to perform drawing operations. Parameters for these commands are specified using logical X-Y addressing.

All the above commands, parameters and data are transferred via the ACRTC read and write FIFOs.

---
*(source page 16)*

### 1.8 Graphic Drawing

Assuming the ACRTC has been properly initialized, the MPU must perform two steps to cause graphic drawing.

First, the MPU must specify certain drawing parameters which define a number of details associated with the drawing process. For excample, to draw a figure or paint an area, the MPU must specify the drawing or painting 'pattern' by initializing the ACRTC Pattern RAM and related pointers. Also, if clipping and hitting control are desired, the MPU specifies the 'arera' to be monitored during drawing by initializing area definition registers. Other drawing parameters include color, edge definition, etc.

After the drawing parameters have been specified, the MPU issues a graphic drawing command and any required command parameters, such as the CRCL (Circle) command with a radius parameter. The ACRTC then performs the specified drawing operation by reading, modifying and rewriting the contents of the frame buffer.

---
*(source page 17)*

# 2. SYSTEM INTERFACE

### 2.1 Basic Clock

The ACRTC basic clock is 2CLK. 2CLK controls all primary ACRTC display and logic timing parameters.

2CLK, along with the specification of number of bits per logical pixel, the Graphic Address Increment mode and the Display Access mode, also determines the video data rate.

### 2.2 CRT Interface

#### 2.2.1 Frame Buffer Access

##### 2.2.1.1 Access Modes

The three ACRTC display memory access modes are Single, Interleaved and Superimposed.

**(a) Single Access Mode**
A display (or drawing) cycle is defined as two cycles of 2CLK. During the first 2CLK cycle, the frame buffer display or drawing address is output. During the second 2CLK cycle, the frame buffer data is read (display cycles and/or drawing cycles) or written (drawing cycles).
In this mode, display and drawing cycles contend for access to the frame buffer. The ACRTC allows the priority to be defined as display priority or drawing priority. If display priority, drawing cycles are only allowed to occur during vertical retrace. So, a 'flashless' display is obtained at the expense of slower drawing. If drawing priority, drawing may occur during display so high speed drawing is obtained, however the display may flash.

**(b) Interleaved Access Mode (Dual Access Mode 0)**
In this mode, display cycles and drawing cycles are interleaved. A display/drawing cycle is defined as four cycles of 2CLK. During the first 2CLK cycle, the frame buffer display address is output. During the second 2CLK cycle, the display data is read from the frame buffer. During the third 2CLK cycle, the frame buffer drawing address is output. During the fourth 2CLK cycle, the drawing data is read or written.
Since there is no contention between display and drawing cycles, a 'flashless' display is obtained while maintaining full drawing speed. However, for a given configuration, frame buffer memory access time must be twice as fast as an equivalent Single Access Mode configuration.

---
*(source page 18)*

**(c) Superimposed Access Mode (Dual Access Mode 1)**
In this mode, two separate logical screens are accessed during each display cycle. The display cycle is defined as four 2CLK cycles. During the first 2CLK cycle, the Background (Upper, Base or Lower) screen frame buffer address is output. During the second 2CLK cycle, the Background screen display or drawing data is read (display or drawing) or written (drawing). During the third 2CLK cycle, the window screen frame buffer address is output. During the fourth 2CLK cycle, the window screen display or drawing data is read (display or drawing) or written (drawing). Note that the third and fourth cycles can be used for Background screen drawing (similar to Interleaved mode) when these cycles are not used for Window display.

---
*(source page 19, landscape orientation)*

### SA (SINGLE ACCESS MODE)

**Figure 2.1(a) Access Mode Timing** — Three stacked timing diagrams for Single Access Mode.

*Display Cycle:* Signals 2CLK, AS̄, MAD, MA/RA/CHR, MCYC, MRD ('HIGH'), DRAW̄ ('HIGH'). One "MEMORY CYCLE" spans two 2CLK periods; the "DISPLAY CYCLE" bracket spans the same width. MAD and MA/RA/CHR each carry one address value "A" per display cycle, with AS̄ pulsing once per cycle to latch the address, and MCYC toggling once per cycle. MRD and DRAW̄ stay high throughout (read-only display, no drawing).

*Display Cycle (Zoom):* Same signal set, but a "ZOOMING CYCLE ×2" bracket spans two consecutive display cycles that repeat the same address "A" (illustrating a zoom factor of 2, where each source pixel/address is held for two output cycles). MRD and DRAW̄ again stay high.

*Drawing Cycle:* Signals AS̄, MAD, MA/RA/CHR, MCYC, MRD, DRAW̄. Two consecutive memory cycles are shown: a "READ" cycle where MAD carries address "A" then data "D" is read back (MRD pulses low to enable read, DRAW̄ goes low marking a drawing/frame-buffer-owned cycle), followed by a "WRITE" cycle where MAD again carries "A" then "D" is written (MRD stays high for write, DRAW̄ remains low). This illustrates the read-modify-write pattern used during drawing.

---
*(source page 20, landscape orientation)*

### INTERLEAVED ACCESS MODE

**Figure 2.1(b) Access Mode Timing** — Three stacked timing diagrams for Interleaved Access Mode (analogous to Figure 2.1(a) but with display and drawing cycles interleaved).

*Display Cycle:* 2CLK, AS̄, MAD, MA/RA/CHR, MCYC, MRD, DRAW̄. One "MEMORY CYCLE" spans two 2CLK periods; the "DISPLAY CYCLE" bracket spans two memory cycles. The first memory cycle carries display address/data "A"; the second memory cycle (marked "READ") carries address "A" then data "D" being read for a drawing operation, with DRAW̄ going low during that half. A third and fourth memory cycle (marked "WRITE") repeat the display "A" cycle followed by an "A"/"D" write cycle with DRAW̄ low.

*Display Cycle (Zoom):* Same signals; a repeated "A" address across consecutive cycles under a combined READ (mid) and WRITE (right) bracket, illustrating zoomed display holding the same source address across multiple output cycles while drawing read/write cycles are interleaved in between.

*Drawing Cycle:* AS̄, MAD, MA/RA/CHR, MCYC, MRD, DRAW̄. Shows alternating "WRITE" and "READ" cycles, each a two-part address-then-data (A then D) memory cycle, with MRD toggling to distinguish read vs. write and DRAW̄ low throughout the drawing cycles.

---
*(source page 22, landscape orientation — note: this page appears out of numeric order in the scanned source, between source pages 20 and 21)*

**Figure 2.1(d) Access Mode Timing** — A detailed timing diagram comparing SA (Single Access), DA0 (Dual Access mode 0/Interleaved) and DA1 (Dual Access mode 1/Superimposed) cycle sequences against 2CLK, MCYC and HSYNC̄, with DISP1̄ and DISP2̄ (WSS=0 and WSS="1" variants) shown.

Legend: **S** = Split Screen Display Cycle; **R** = Refresh Address Output Cycle (in DRAM mode); **W** = Window Display Cycle; **A** (circled) = Attribute Output Cycle; **O** = Drawing-Possible Cycle (when no drawing is executed the output is fixed at "0"); **O\*** = in this cycle the output will be fixed at "0".

**[SA] row group:** AS̄, MAD and MA/RA cycle through R→A→O→O→S→S→S→S→S→W→W→W→W→S→S→O→O→O in sequence (one address/attribute type output per AS̄ pulse); MRD and DRAW̄ held "HIGH" throughout (display-only, single access).

**[DA0] row group:** AS̄, MAD, MA/RA alternate more finely — R→A→O, then S→O, S→O, S→O→S→O, S→O→S→O, W→O→W→O, W→O→W→O, S→O, S→O, O→O→O — interleaving a Drawing-Possible "O" cycle after most display cycles; MRD/DRAW̄ "HIGH" at the start, with DISP2̄ (WSS="1") shown pulsing low over the window-cycle region.

**[DA1] row group:** similar interleaving to DA0 but the window cycles alternate S↔W directly (S,W,S,W) rather than W,O,W,O, reflecting the Superimposed mode's alternation between background and window screens each cycle; MRD pulses low during the W cycles (window reads), and DISP2̄ (WSS="1") again goes low over the S/W alternation region.

---
*(source page 21, landscape orientation — note: this page appears out of numeric order in the scanned source, after source page 22)*

### SUPERIMPOSED ACCESS MODE

**Figure 2.1(c) Access Mode Timing** — Three stacked timing diagrams for Superimposed Access Mode.

*Display Cycle:* 2CLK, AS̄, MAD, MA/RA/CHR, MCYC, MRD ('HIGH'), DRAW̄. The "DISPLAY CYCLE" bracket spans two "MEMORY CYCLE" periods, split into a "BACKGROUND" half (first memory cycle, address "A") and a "WINDOW" half (second memory cycle, address "A").

*Display Cycle (Zoom):* Same signals over a "ZOOMING CYCLE ×2" bracket spanning four memory cycles, each carrying address "A" (background, window, background, window), illustrating each screen's address held across the zoom factor.

*Drawing Cycle:* AS̄, MAD, MA/RA/CHR, MCYC, MRD, DRAW̄. Two memory cycles shown as background/window address-only "A" cycles, followed by a "READ" cycle (A then D, MRD high) and a "WRITE" cycle (A then D, MRD low), i.e. read-modify-write against one of the two superimposed screens.

---
*(source page 23)*

##### 2.2.1.2 Graphic Address Increment Mode

During display operation, the ACRTC can be programmed to control the graphic display address in six ways including increment by 1, 2, 4 and 8 words, 1 word every two display cycles and no increment.

Setting GAI to increment by 2, 4 or 8 words per display cycle achieves linear increases in the video data rate i.e. for a given configuration setting GAI to 2, 4 or 8 words will achieve 2, 4 or 8 times the video data rate corresponding to GAI=1. This allows increasing the number of bits/logical pixel and logical pixel resolution while meeting the 2CLK maximum frequency constraint.

Figure 2.2 shows the summary relationship between 2CLK, Display Access Mode, Graphic Address Increment, # bits/logical pixel, memory access time and video data rate. The frame buffer cycle frequency (Fc) is shown by the following equation where:

Fv = Dot Clock
N = # bits/logical pixel
D = Display Access Mode
&nbsp;&nbsp;&nbsp;&nbsp;1 for Single Access Mode
&nbsp;&nbsp;&nbsp;&nbsp;2 for interleaved and Superimposed Access Modes
A = Graphic Address Increment (1/2, 1, 2, 4, 8)
Fc = (Fv × N × D)/(A × 16)

**Figure 2.2 Graphic Address Increment Modes** — Table of required address-increment setting (as a multiple, e.g. +1/2, +1, +2, +4, +8, or "—" for not achievable) needed for each combination of dot rate (16/32/64/128 MHz), access mode (S=Single, D=Dual/interleaved), color depth (1/2/4/8/16 bits per pixel) and memory cycle time (250ns or 500ns):

| Color No. (bit/pixel) | Memory Cycle | 16MHz S | 16MHz D | 32MHz S | 32MHz D | 64MHz S | 64MHz D | 128MHz S | 128MHz D |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 250ns | — | +1/2 | +1/2 | +1 | +1 | +2 | +2 | +4 |
| 1 | 500ns | +1/2 | +1 | +1 | +2 | +2 | +4 | +4 | +8 |
| 2 | 250ns | +1/2 | +1 | +1 | +2 | +2 | +4 | +4 | +8 |
| 2 | 500ns | +1 | +2 | +2 | +4 | +4 | +8 | +8 | — |
| 4 | 250ns | +1 | +2 | +2 | +4 | +4 | +8 | +8 | — |
| 4 | 500ns | +2 | +4 | +4 | +8 | +8 | — | — | — |
| 8 | 250ns | +2 | +4 | +4 | +8 | +8 | — | — | — |
| 8 | 500ns | +4 | +8 | +8 | — | — | — | — | — |
| 16 | 250ns | +4 | +8 | +8 | — | — | — | — | — |
| 16 | 500ns | +8 | — | — | — | — | — | — | — |

---
*(source page 24)*

#### 2.2.2 Dynamic RAM Refresh

When dynamic RAMs (DRAMs) are used for the frame buffer memory, the ACRTC can automatically provide DRAM refresh addressing.

The ACRTC maintains an 8 bit DRAM refresh counter which is decremented on each frame buffer access. During HSYNC̄ low, the ACRTC will output the sequential refresh addresses on MAD. The refresh address assignment depends on Graphic Address Increment (GAI) mode as shown in figure 2.3(a).

**Figure 2.3(a) GAI and DRAM Refresh Addressing**

| Address Increment Mode | Refresh Address Output Terminal |
|---|---|
| +1 (GAI=000) | MAD0-7 |
| +2 (GAI=001) | MAD1-8 |
| +4 (GAI=010) | MAD2-9 |
| +8 (GAI=011) | MAD3-10 |
| +1/2 (GAI=111) | MAD0-7 |

The ACRTC provides "0" output on the remaining address line of MAD and MA/RA.

DRAM refresh cycle timing must be factored into the determination of HSYNC̄ low pulse width (HSW — specified in units of frame buffer memory cycles).

If the horizontal scan rate is Fh (kHz), number of DRAM refresh cycles is N and the DRAM refresh cycle time is Tr (msec) then horizontal sync width (HSW) is specified by the following equation:

HSW ≥ N / (Tr × Fh)

For example, if the scan rate is 15.75 kHz and the DRAMS have 128 refresh cycles of 2 msec, HSW must be greater than or equal to 5.

HSW ≥ 128 / (2 × 15.75) = 4.06

---
*(source page 25, landscape orientation)*

**Figure 2.3(b) DRAM Refresh Timing** — Timing diagram spanning one full horizontal line, from one Display Period through the Retrace Period (Front Porch, H-Sync Cycle/Refresh Cycle, Attribute cycle, Back Porch) to the next Display Period.

Signals: 2CLK, MCYC (both free-running); DISP̄ (high during the Display Period, low during retrace); HSYNC̄ (high, pulsing low for the H-Sync Cycle within the retrace period); AS̄ (pulses once per memory cycle throughout); MAD and MA/RA carry, in sequence: "A" (display address, during Display Period), "0","0" (Front Porch, non-display, address forced to 0), "REF","REF" (DRAM refresh addresses during the H-Sync Cycle/Refresh Cycle), "ATB" (Attribute output cycle, coincident with the HSYNC̄ rising edge), "0","0" (Back Porch, non-display), then "A" again at the start of the next Display Period. RA4 and CHR stay low/inactive through the non-display portion and resume with the next Display Period. DRAW̄ and MRD are held "High" throughout (no drawing shown).

---
*(source page 26)*

#### 2.2.3 External Synchronization

The ACRTC EXSYNC̄ pin allows synchronization of multiple ACRTCs or other video signal generators. The ACRTC may be programmed as a single Master device, or as one of a number of Slave devices.

To synchronize multiple ACRTCs, simply connect all the EXSYNC̄ pins together.

For synchronizing to other video signals, the connection scheme depends on the raster scan mode. In Non-Interlace mode, EXSYNC̄ corresponds to VSYNC̄. In Interlace modes, EXSYNC̄ corresponds to VSYNC̄ of the odd field.

**Figure 2.4(a) External Synchronization** — Wiring diagram: a common Clock Signal feeds the 2CLK input of an "ACRTC (Master)" and two "ACRTC (slave)" devices. The Master's EXSYNC̄ output is wired to a common node that feeds the EXSYNC̄ input of both slave ACRTCs, synchronizing all three devices to the Master's timing.

---
*(source page 27, landscape orientation)*

**Figure 2.4(b) EXSYNC̄ Timing** — Two related timing diagrams illustrating Master/Slave synchronization via EXSYNC̄.

*Top diagram:* 2CLK (Master) shown with a gap/resync point at 0.8V/2.2V threshold markers labeled with timing-parameter callouts ⑦⑦ and ⑦⑥, followed by "11 Cycle (2CLK)" span. EXSYNC̄ (From MASTER) drops low then has a hatched transition region aligned with the ⑦⑦/⑦⑥ callouts. HSYNC̄ (SLAVE) stays high for the shown span then falls (crossing 0.5V) with callout ⑥⑦ marking the delay from the reference point to this falling edge.

*Bottom diagram:* 2CLK with an "EXSYNC̄ Rise Cycle" region leading into labeled cycles T0-T6 ("Sync Cycle" bracket spans T0 through T6). EXSYNC̄ shown falling to 0.8V then rising through the hatched region to 2.2V, with callout ⑦⑤ marking the interval before the transition and ⑦⑦/⑦⑥ marking the narrow transition window itself. Two MCYC traces are shown below, both keyed off the EXSYNC̄ transition: one labeled "(Phase Shifted)" showing MCYC's phase shifting at cycle T6, and one labeled "(Phase Not Shifted)" showing MCYC continuing unshifted. Caption: "When the leading edge of EXSYNC̄ enters this period, ACRTC shifts the internal phase according to the above sequence."

---
*(source page 28)*

### 2.3 MPU Interface

#### 2.3.1 MPU Bus Cycle

The ACRTC interfaces to the MPU as a peripheral occupying two addresses in the MPU address space. The ACRTC can operate as an 8 or 16 bit peripheral as configured during RES̄.

An MPU bus cycle is initiated when CS̄ is asserted (following the assertion of RS and R/W̄). The ACRTC responds to CS̄ low by asserting DTACK̄ low to complete the data transfer. DTACK̄ will be returned to the MPU in between 1 and 1.5 2CLK cycles.

MPU WAIT states will be added in the following two cases.

**(a)** If the ACRTC 2CLK input is much slower than the MPU clock, continuous ACRTC accesses may be delayed due to internal processing of the previous bus cycle.

**(b)** If an ACRTC read cycle immediately follows an ACRTC write cycle, a WAIT state may occur due to ACRTC preparation for bus 'turn-around'. However, MPUs normally have no instructions which immediately follow a write cycle with a read cycle.

For connection to synchronous bus interface MPUs, DTACK̄ can simply be left open assuming the system design guarantees that WAIT states cannot occur as described above. If WAIT states may occur, DTACK̄ can be used with external logic to synthesize a READY signal.

#### 2.3.2 DMA Transfer

The ACRTC can interface with an external DMA controller using three handshake signals, DMA Request (DREQ̄), DMA Acknowledge (DACK̄) and DMA Done (DONĒ).

The ACRTC uses the external DMAC for two types of transfers, Command/Parameter DMA and Data DMA. For both types, DMA transfers use the ACRTC read and write FIFOs.

##### 2.3.2.1 Command/Parameter DMA

The MPU initiates this mode by setting bit 12 (CDM) in the ACRTC Command Control Register to 1. Then, the ACRTC will automatically request DMA transfer for commands and their associated parameters as long the write FIFO has space. Only cycle steal request mode (DREQ̄ pulses low for each data transfer) can be used. Command/Parameter DMA is terminated when the MPU resets bit 12 in CCR to 0 or the external DONĒ input is asserted.

---
*(source page 29)*

##### 2.3.2.2 Data DMA

Data DMA is used to move data between the MPU system memory and the ACRTC frame buffer.

The MPU sets-up the transfer by specifying the frame buffer transfer address (and other parameters of the transfer, such as 'on-the fly' logical operations) to the ACRTC. Next, when the MPU issues a Data Transfer Command to the ACRTC, the ACRTC will request DMA transfer to and from system memory. The ACRTC will request DMA, automatically monitoring FIFO status, until the DMA Transfer Command is completed.

Data DMA request mode can be cycle steal (as in Command/Parameter DMA) or burst mode in which DREQ̄ is a low level control output to the DMAC which allows multiple data transfers during each acquisition of the MPU bus.

#### 2.3.3 Interrupts

The ACRTC recognizes eight separate conditions which can generate an interrupt including command error detection, command end, drawing edge detection, light pen strobe and four FIFO status conditions. Each condition has an associated mask bit for enabling/disabling the associated interrupt. The ACRTC removes the interrupt request when the MPU performs appropriate interrupt service by reading or writing to the ACRTC.

---
*(source page 30)*

# 3. DISPLAY FUNCTION

### 3.1 Logical Display Screens

The ACRTC allows division of the frame buffer into four separate logical screens.

| Screen Number | Screen Name | Screen Group Name |
|---|---|---|
| 0 | Upper Screen | Background Screens |
| 1 | Base Screen | Background Screens |
| 2 | Lower Screen | Background Screens |
| 3 | Window Screen | (Window) |

In the simplest case, only the Base screen parameters must be defined. Other screens may be selectively enabled, disabled and blanked under software control.

The Background (Upper, Base and Lower) screens partition the display into three horizontal splits whose position is fully programmable. A typical application might use the Base screen for the bulk of user interaction, using the Lower screen for a 'status line(s)' and the Upper screen for 'pull-down menu(s)'.

The Window screen is unique, since the ACRTC gives the Window screen higher priority than Background screens. thus, when the Window, whose size and position is fully programmable, overlaps a Background screen, the Window screen is displayed. One exception is the ACRTC Superimposed Access Mode, in which the Window has the same display priority as Background screens. In this case, the Window and Background screen are 'superimposed' on the display.

The ACRTC logical screen organization can be programmed to best suit a number of display applications.

---
*(source page 31)*

**Figure 3.1 Display Screen/Frame Buffer Relationship** — Diagram showing a large rectangle representing the frame buffer memory, of total "Memory Width". Inside it, near the top-left, a "Start Address" arrow points to the top-left corner of a smaller inset rectangle labeled "Display Screen Area", which is inset from the left edge of the frame buffer (its width does not span the full Memory Width). The inset rectangle's height is labeled "Vertical Display Width" (measured on the right) and its width is labeled "Horizontal Display Width" (measured along the bottom), illustrating that a logical screen occupies a horizontal-width-limited sub-window starting at its Start Address within the wider physical memory row (Memory Width).

---
*(source page 32)*

**Figure 3.2 Display Screen Combination** — Diagram illustrating how the Character and Graphic frame buffers combine into one composite display, using an example CAD-style screen (file "MOS").

Left side, "Frame Buffer for Character" (addressed 0000-FFFF): divided at some boundary into two regions feeding Start Address Registers SAR0 (pointing into a "Defined Frame Buffer" region of width MW0, containing a dashed box "File Name: MOS" — character/text content) and SAR2 (region of width MW2, containing dashed text "Left: Layout / Right: Symbol").

Below it, "Frame Buffer for Graphic" (addressed 00000-FFFFF): similarly divided, feeding SAR1 (region of width MW1, containing a graphic drawing of a transistor-like symbol with two small square pads) and SAR3 (region of width MW3, containing a graphic drawing of a transistor schematic symbol).

A legend maps Screen # to Position: 0=Upper, 1=Base, 2=Lower, 3=Window.

Two large arrows on the right show the character regions (SAR0, SAR2) combining with the graphic regions (SAR1, SAR3) into the final composite display: a box headed "File Name: MOS" containing the graphic transistor-pad drawing and the transistor schematic side by side, with "Left: Layout" and "Right: Symbol" labels below — i.e., the character screen supplies text/labels while the graphic screen (SAR1/SAR3, shown separately as the pad-array drawing and schematic drawing) supplies the corresponding graphic content, and the two are overlaid/combined into one displayed screen.

---
*(source page 33)*

**Figure 3.3 Display Screen Specification** — Diagram defining the horizontal and vertical timing/geometry parameters of a display screen with three split screens and a window.

Top portion (horizontal): a horizontal sync waveform spans "HC" (Horizontal Cycle) total width. "HSW" (Horizontal Sync Width) marks the sync pulse; "HDS" (Horizontal Display Start) follows it; "HWS" (Horizontal Window Start) and "HWW" (Horizontal Window Width) mark the window's horizontal position/size within "HDW" (Horizontal Display Width), which spans from the display-start point to near the end of the cycle.

Bottom portion (vertical/screen layout, using the horizontal parameters as its top edge): a large outer rectangle represents the full display; nested inside it, a smaller rectangle represents the union of the three split screens, itself containing an inner nested window rectangle. On the right, a vertical bracket "VC" (Vertical Cycle) spans the whole height, broken down top-to-bottom into "VDS"+"VWS" (Vertical Display Start / Vertical Window Start bracket), then "SP0" (Split screen 0, paired with "VWS"/"VWW" bracket), "SP1" (paired with "VWW"), "SP2", and finally "VSW" (Vertical Sync Width) as a separate small block below the main screen area. This shows how the three horizontal splits (SP0/SP1/SP2 vertical widths) and the window (VWS start, VWW width) are all positioned within the overall vertical cycle VC.

---
*(source page 34, landscape orientation)*

**Figure 3.4 Display Screen Timing** — Two-part timing diagram deriving the Figure 3.3 geometry parameters from actual clock cycles, where M = memory cycle length and H = one horizontal line time.

*Top part (horizontal, in units of M):* 2CLK and MCYC free-running with one "Memory Cycle" = M. HSYNC̄ pulses low for "Horizontal Sync Width" = HSW·M, after which DISP1̄ goes low starting at "Horizontal Display start" = (HDS+1)·M and stays low for "Horizontal Display Width" = (HDW+1)·M. DISP2̄ goes low starting at "Horizontal Window Start" = (HWS+1)·M for "Horizontal Window Width" = (HWW+1)·M, nested within the DISP1̄ active period. The total period shown is "Horizontal Cycle" = (HC+1)·M.

*Bottom part (vertical, in units of H, one row per HSYNC̄ pulse):* HSYNC̄ pulses once per line; VSYNC̄ pulses low for "Vertical Sync Width" = VSW·M at the end of the cycle. DISP1̄ and DISP2̄ pulse low on the lines corresponding to each active screen region: "Vertical Display Start" = (VDS+1)·H, then "Split Screen 0 Vertical Display Width" = SP0·H, "Split Screen 1 Vertical Display Width" = SP1·H, "Split Screen 2 Vertical Display Width" = SP2·H — together spanning "Vertical Window Start" = (VWS+1)·H and "Vertical Window Width" = VWW·H as sub-brackets — with the whole frame spanning "Vertical Cycle" = VC·H.

---
*(source page 35)*

**Figure 3.5 Example Screen Combinations** — Four example layouts of the four logical screens (SP0-Upper, SP1-Base, SP2-Lower, SP3-Window):

EX.1: SP0-Upper, SP1-Base and SP2-Lower stacked vertically on the left, with SP3-Window occupying the full-height right-hand portion beside them.

EX.2: SP1-Base fills the whole area, with a smaller SP3-Window box overlapping/inset near its top-right corner.

EX.3: SP0-Upper, SP1-Base, SP2-Lower and SP3-Window all stacked vertically as four horizontal bands (Window used as a fourth band rather than an overlay).

EX.4: SP0-Upper (top band) and SP2-Lower (bottom band) sandwich a middle row containing SP1-Base on the left and a smaller SP3-Window box inset at the right side of that middle row.

---
*(source page 36)*

#### 3.1.1 Graphic/Character Address Spaces

The ACRTC controls two separate logical address spaces. The CHR pin allows external decoding if physically separate frame buffers are desired.

Each of the four logical screens (Upper, Base, Lower and Window) is programmed as residing in the Graphics address space or the Character address space.

ACRTC accesses to Graphics screens are treated as bit mapped using a 20 bit frame buffer address, with an address space of one megaword (1M by 16 bit).

ACRTC accesses to Character screens are treated as character generator mapped. In this case, a 64K word address space is used and 5 bits of raster address are output to an external character generator.

Multiple logical screens defined as Character can be externally decoded to use separate character generators or different addresses within a combined character generator. Also, each Character screen may be defined with separate line spacing, separate cursors, etc.

**Figure 3.6 Character Screen Raster Addressing** — Diagram of raster lines numbered 1F (top) then 00 through 08 (First Raster Address "FRA" at 00, Last Raster Address "LRA" at 08 in this example), with circles marking selected raster lines (00-02 and 04-06, skipping 03 and 07) on two example character columns, illustrating that the raster address range from FRA to LRA defines which raster lines within the character cell are used/displayed.

---
*(source page 37)*

### 3.2 Cursor Control

The ACRTC has two Block Cursor Registers and a Graphics Cursor Register.

A Block cursor is used with Character screens. The cursor start and ending raster addresses are fully programmable. Also, the cursor width can be defined as one to eight memory cycles.

A Graphics cursor is defined by specifying the start and end addresses in both the X and Y dimensions.

**Figure 3.7(a) Two Separate Block Cursors** — A screen showing the text "HITACHI" near the top, with "Cursor1" pointed at the underline beneath the "C" in "HITACHI", and the text "ACRTC" further down with "Cursor2" pointed at a boxed cursor covering the "C" in "ACRTC" — illustrating two independently-positioned block cursors on a character screen.

---
*(source page 38)*

**Figure 3.7(b) Block Cursor Examples** — Three raster-line diagrams (lines 1F down to 00-08) each showing circles marking which raster rows the cursor covers, for three BCSR (Block Cursor Start Raster)/BCER (Block Cursor End Raster) settings: BCSR=07, BCER=07 (a single-row underline cursor at the bottom row); BCSR=02, BCER=07 (a tall block cursor spanning rows 02-07); and BCSR=00, BCER=02 (a short block cursor spanning rows 00-02 at the top).

**Figure 3.8 Graphic Cursor** — Diagram of a rectangular graphic cursor outline (drawn as a frame with small notches marking its corner reference points) surrounding a display area; a dashed line labeled CUD1̄ points from the top-right notch of the cursor frame, and a small square inside the frame marks a sample cursor/pixel position, illustrating how the graphic cursor's rectangular frame is defined and output via CUD1̄.

---
*(source page 39)*

The ACRTC provides two separate cursor outputs, CUD1̄ and CUD2̄. These are combined with two character cursor registers and a graphics cursor register to provide three cursor modes.

#### 3.2.1 Block Mode
Two Block cursors are output on CUD1̄ and CUD2̄ respectively.

#### 3.2.2 Graphic Mode
The Graphic cursor is output on CUD1̄. Using an external cursor pattern memory allows a graphic cursor of various shapes. Two Block cursors are multiplexed on CUD2̄.

#### 3.2.3 Crosshair Mode
The horizontal and vertical components of the Graphic cursor are output on CUD1̄ and CUD2̄ respectively. This allows simple generation of a crosshair cursor control signal.

**Figure 3.9 Crosshair Cursor** — Timing/diagram pair: CUD1̄ shown as a "Horizontal Cursor Signal" waveform that dips low twice (marking two vertical crosshair lines' horizontal position) with two corresponding narrow pulses just below it. Below, a 3×3 grid represents the screen; a bracket on the right labeled "Vertical Cursor Signal" / CUD2̄ marks two of the three row-bands, showing that CUD2̄'s pulses mark the horizontal crosshair line's vertical position — together CUD1̄ and CUD2̄'s pulse timings define the crosshair's screen position.

---
*(source page 40)*

## 3.3 Scrolling

### 3.3.1 Vertical Scroll

Each logical screen performs independent vertical scroll. On Character Screens, vertical smooth scroll is accomplished using the programmable Start Raster Address (SRA). Line by line scroll is accomplished by increasing or decreasing the screen start address by one unit of horizontal memory width.

On Graphics screens, vertical smooth scroll is accomplished by increasing or decreasing the screen start address by one unit of horizontal memory width.

### 3.3.2 Horizontal Scroll

Horizontal scroll can be performed in units of characters for Character screens and units of words (multi logical pixels) for Graphic screens by increasing or decreasing the screen start address by 1.

For smooth horizontal scroll, the ACRTC has dot shift video attributes which can be used with an external circuit which conditions shift register load/clocking.

Since this dot shift information is output each raster, horizontal smooth scroll is limited to either the Background screens or the Window screen at any given time. However, horizontal smooth scroll is independent for each of the Background screens (Upper, Base, Lower).

---
*(source page 41)*

**Figure 3.10 Scrolling By SAR (Start Address Register) Rewrite**

The figure illustrates scrolling by rewriting the Start Address Register. A large rectangle labeled "Defined Frame Buffer" contains a smaller dashed/solid rectangle pair labeled with the display window position: the solid-line box marked "SAR" (original start address) and a dashed-line box marked "SAR'" (new start address) overlapping it, offset diagonally down and to the right, each containing a small icon labeled "MOS" (a cursor/mouse symbol). A label "Scrolling" with an arrow points from the SAR box toward the SAR' box, indicating the display window moves from the SAR position to the SAR' position within the frame buffer. Below, two additional boxes show the same "MOS" icon before (solid box, connected by a line from the SAR box) and after (dashed box, connected by a dashed line from the SAR' box) the scroll, with an arrow between them showing the transition. To the left, a small diagram shows "Start Address [SAR]" pointing down to "Start Address [SAR']", indicating the start address register value changes to produce the scroll effect.

---
*(source page 42)*

**Figure 3.11 Horizontal Smooth Scroll — Base Screen**

The figure shows a rectangular screen area with a horizontal dashed centerline. Below it, a timing diagram shows the DISP (display enable, active low, shown with overbar) signal going low during the active display period and high during blanking. Below that, the "Memory Address" row shows sequential memory address labels B1, B2, B3, ... (continuing through a dashed gap) ..., Bn, representing the background screen memory addresses fetched during one display line, illustrating that horizontal smooth scroll shifts which addresses (B1, B2, B3...) are fetched relative to the display window.

**Figure 3.12 Horizontal Smooth Scroll — Window Screen**

The figure shows a rectangular screen area labeled "Background" containing a smaller rectangle labeled "Window" positioned within it (not centered — offset toward the upper-right area). Below, a timing diagram shows two display-enable signals: DISP1 (overbar, for the Background) and DISP2 (overbar, for the Window), with DISP2 additionally labeled "1 Display Cycle". Below both, the "MAD" (Memory Address) row shows a sequence of address labels: B1, B2, ... Bk (background addresses), then W1 ... W2 (window addresses), then more background addresses Bl, Wm, Bk+1, * (empty/drawing cycle), ..., Bn, *, illustrating how the memory address stream interleaves background (B) and window (W) address fetches, with "*" cycles representing empty cycles or drawing cycles. A legend below the diagram states: "B  Background Address", "*  Empty Cycle or Drawing Cycle", "W  Window Address".

---
*(source page 43)*

## 3.4 Raster Scan Modes

The ACRTC has three software selectable raster scan modes — Non-Interlace, Interlace Sync and Interlace Sync & Video. In Non-Interlace mode a frame consists of one field. In the Interlace modes, a frame consists of two fields, the even and odd fields.

The Interlace modes allow increasing screen resolution while avoiding limits imposed by the CRT display device, such as maximum horizontal scan frequency or maximum video dot rate.

Interlace Sync mode simply repeats each raster address for both the even and odd fields. This is useful for increasing the quality of a displayed figure when using an interlaced CRT device such as a Television Set with RF modulator.

Interlace Sync & Video mode displays alternate even and odd rasters on alternate even and odd fields. For a given number of rasters/character, this mode allows twice as many characters to be displayed in the vertical direction as Non-Interlace mode.

Note that for Interlace modes, the refresh frequency for a given dot on the screen is one-half that of the Non-Interlace mode. Interlace modes normally require the use of a CRT with a more persistent phosphor to avoid a flickering display.

**Figure 3.13 Raster Scan Modes**

The figure compares raster addressing for the three modes side by side, using vertically stacked raster-address labels (in hex) connected by lines with circle markers indicating which rasters are actually scanned, and "X" marks showing repeated/merged rasters:

- **Non-Interlace** (left): a single sequence of raster addresses 1F, 00, 01, 02, 03 (shown with a run of overlapping circles indicating multiple consecutive scan lines merge visually at this scale), 04, 05, 06, 07, 08 — one continuous field, solid line only.
- **Interlace Sync.** (middle): two parallel columns, one solid line (Even) and one dashed line (Odd), both showing the same raster address sequence 1F, 00, 01, 02, 03 (with the overlapping-circles run), 04, 05, 06, 07, 08 — the same raster addresses are repeated identically for both even and odd fields.
- **Interlace Sync. & Video** (right): two parallel columns, solid (Even) numbered 1E, 00, 02, 04, 06 (with an overlapping-circles run), 08, 0A, 0C, 0E, 10, and dashed (Odd) numbered 1F, 01, 03, 05 (with an overlapping-circles run at 09), 0B, 0D, 0F, 11 — even and odd fields display alternating (interleaved) raster addresses rather than identical ones.

A legend at the top right indicates: "Even ———" (solid line) and "Odd -----" (dashed line).

---
*(source page 44, landscape orientation)*

**Figure 3.14 Raster Scan Timing**

This landscape-oriented timing diagram shows three raster scan timing waveforms stacked vertically, each showing HSYNC (or reference to it), RCR (Raster Count Register) value sequence, VSYNC (overbar), EXSYNC, and an OUTPUT/field indicator bar.

**[NON-INTERLACE]:** HSYNC is a regular pulse train, with one pulse period labeled "H". The RCR value sequence reads: 0, 1, 2, 3, ... VC-2, VC-1, 0, 1, 2, 3, ... VC-2, VC-1, 0, 1 (wrapping and repeating each frame). VSYNC (overbar) and EXSYNC each go low briefly at the frame boundary (near RCR = VC-2/VC-1) and return high. The OUTPUT bar below spans one "FRAME" from one VSYNC pulse to the next; a note "(VSW=2)" appears near the second frame boundary shown, indicating the vertical sync width is 2 raster lines in this example.

**[INTERLACE-SYNC]:** The RCR sequence reads: 0, 1, 2, 3, ... VC2, VC1, [a hatched "Dummy" cell labeled VC] , 0, 1, 2, 3, ... VC-2, VC-1, 0. VSYNC and EXSYNC each pulse low near the VC2/VC1/Dummy region. The OUTPUT bar is divided into "EVEN-FIELD" then "ODD-FIELD" segments, together spanning one "FRAME"; a small offset labeled "H/2" (half a horizontal period) is marked at the transition between the dummy raster and field boundary, showing the odd field is offset by half a line relative to the even field.

**[INTERLACE-SYNC & VIDEO] (VC = ODD):** The RCR sequence reads: 0, 2, 4, 6, ... VC-5, VC-3, [hatched "Dummy" cell labeled VC-1], 1, 3, 5, 7, ... VC-4, VC-2, 0 — i.e., even-numbered raster addresses during the even field and odd-numbered raster addresses during the odd field. VSYNC and EXSYNC pulse low near the VC-5/VC-3/Dummy region. The OUTPUT bar again shows "EVEN-FIELD" then "ODD-FIELD" spanning one "FRAME", with the "H/2" half-line offset marked at the field transition.

---
*(source page 45)*

## 3.5 Zooming

The Base screen (Screen 1) is supported by the ACRTC zooming function. Note that ACRTC zooming is performed by controlling the CRT timing signals. The contents of the frame buffer area being zoomed are not changed.

The ACRTC allows specification of a zoom factor (1 to 16) independently in the X and Y directions.

For horizontal zoom, the programmed zoom factor is output as video attributes. An external circuit uses this factor to condition the external shift register clock to accomplish horizontal zooming.

For vertical zoom, no external circuit is required. The ACRTC will scan a single raster multiple times to accomplish vertical zooming.

**Figure 3.15 Zooming**

The figure shows an "H"-shaped character zoomed by different X and Y factors, arranged in a 2x2 grid of examples with arrows showing the transformations:

- **1x1** (top left): the original, unzoomed "H" character, with a small icon above showing a single circle with an arrow (representing one dot per horizontal clock).
- **3x1** (top right, reached by a horizontal arrow from 1x1): the "H" stretched 3 times wider horizontally but the same height, with a small icon showing three overlapping circles with an arrow (representing the horizontal zoom factor of 3).
- **1x2** (bottom left, reached by a vertical arrow from 1x1): the "H" the same width but stretched 2 times taller vertically, with a small icon showing a stack of two circles.
- **3x2** (bottom right, reached by a diagonal arrow from 1x1): the "H" stretched both 3 times wider and 2 times taller, with a small icon showing a 3x2 grid-like cluster of circles.

---
*(source page 46)*

## 3.6 Light Pen

The ACRTC provides a 20 bit Light Pen Address Register and a Light Pen Strobe (LPSTB) input pin for connection with a light pen.

A light pen strobe pulse will occur when the CRT electron beam passes under the light pen during display refresh. When this pulse occurs, the contents of the ACRTC display refresh address counter will be latched into the Light Pen Address Register along with a logical screen (Character or Graphic screen) designator. Also, an ACRTC status flag indicating light pen activity is set, generating an optional (maskable) MPU interrupt. Note that for Superimposed access mode, when the light pen strobe occurs in an area in which the Window overlaps a Background (Upper, Base or Lower) screen, the Background screen address will be latched.

Various system and ACRTC delays will cause the latched address to differ slightly from the actual light pen position. The light pen address can be corrected using software, based upon system specific delays. Or, if the application does not require the highest light pen pointing resolution, software can 'bound' the light pen address by specifying a range of values associated with a given area of the screen.

---
*(source page 47)*

# 4. SIGNAL DESCRIPTION

## 4.1 Pin Arrangement

**Figure 4.1 Pin Arrangement**

The figure shows the 64-pin DIP package pinout for the ACRTC, with pins 1-32 down the left side and pins 33-64 up the right side (pin 1 and pin 64 both at the top, notch indicator at top center). Pin functions and I/O direction groupings, reading left side top to bottom then right side bottom to top:

Left side (pins 1-32):
| Pin | Signal | I/O |
|-----|--------|-----|
| 1 | CUD1 (overbar) | Out |
| 2 | CUD2 (overbar) | Out |
| 3 | R/W (overbar on W) | In |
| 4 | CS (overbar) | In |
| 5 | RS | In |
| 6 | RES (overbar) | In |
| 7 | DONE (overbar) | In/Out |
| 8 | DREQ (overbar) | Out |
| 9 | DACK (overbar) | In |
| 10 | DTACK (overbar) | Out |
| 11 | IRQ (overbar) | Out |
| 12 | HSYNC (overbar) | Out |
| 13 | VSYNC (overbar) | Out |
| 14 | Vcc | — |
| 15 | EXSYNC (overbar) | In/Out |
| 16 | Vss | — |
| 17 | D0 | In/Out |
| 18 | D1 | In/Out |
| 19 | D2 | In/Out |
| 20 | D3 | In/Out |
| 21 | D4 | In/Out |
| 22 | D5 | In/Out |
| 23 | D6 | In/Out |
| 24 | D7 | In/Out |
| 25 | D8 | In/Out |
| 26 | D9 | In/Out |
| 27 | D10 | In/Out |
| 28 | D11 | In/Out |
| 29 | D12 | In/Out |
| 30 | D13 | In/Out |
| 31 | D14 | In/Out |
| 32 | D15 | In/Out |

Right side (pins 33-64):
| Pin | Signal | I/O |
|-----|--------|-----|
| 33 | RA4 | Out |
| 34 | MA19/RA3 | Out |
| 35 | MA18/RA2 | Out |
| 36 | MA17/RA1 | Out |
| 37 | MA16/RA0 | Out |
| 38 | MAD15 | In/Out |
| 39 | MAD14 | In/Out |
| 40 | MAD13 | In/Out |
| 41 | MAD12 | In/Out |
| 42 | MAD11 | In/Out |
| 43 | MAD10 | In/Out |
| 44 | MAD9 | In/Out |
| 45 | MAD8 | In/Out |
| 46 | MAD7 | In/Out |
| 47 | MAD6 | In/Out |
| 48 | MAD5 | In/Out |
| 49 | Vcc | — |
| 50 | 2CLK | In |
| 51 | Vss | — |
| 52 | MCYC | Out |
| 53 | AS (overbar) | Out |
| 54 | DRAW (overbar) | Out |
| 55 | MRD | Out |
| 56 | CHR | Out |
| 57 | MAD4 | In/Out |
| 58 | MAD3 | In/Out |
| 59 | MAD2 | In/Out |
| 60 | MAD1 | In/Out |
| 61 | MAD0 | In/Out |
| 62 | DISP2 (overbar) | Out |
| 63 | DISP1 (overbar) | Out |
| 64 | LPSTB | In |

Pins are additionally bracket-grouped in the diagram by function: CUD1/CUD2 (Out); R/W, CS, RS, RES (In); DONE (In/Out); DREQ (Out); DACK (In); DTACK (Out); IRQ (Out); HSYNC/VSYNC (Out); EXSYNC (In/Out); D0-D15 (In/Out); MAD0-MAD4 and MAD5-MAD15 (In/Out, shown as two bracket groups on the two sides); CHR/MRD/DRAW/AS/MCYC (Out); 2CLK (In); MA16/RA0-MA19/RA3 and RA4 (Out); DISP1/DISP2 (Out); LPSTB (In).

---
*(source page 48)*

## 4.2 Signal Functions

The ACRTC signal functions are grouped into 4 functional categories, MPU Interface, DMAC Interface, CRT Interface and Power Supply. All signals are TTL compatible.

### 4.2.1 MPU Interface

#### 4.2.1.1 Reset (RES̄:INPUT)

A low level on the RES̄ input forces the ACRTC into the following state.

(a) Drawing and Display operation is stopped.

(b) ACRTC registers are initialized as follows.
Status register (SR) — CED, WFR and WFE bits are set to 1, all other bits reset to 0.
Command Control Register (CCR) — The ABT bit is set to 1. All other bits are reset to 0.
Operation Mode Register (OMR) — The M/S and STR bits are reset to 0. All other bits are unaffected.
All other ACRTC registers are unaffected by RES̄.

(c) The DRAM refresh address is placed on the MAD lines determined by the graphic address increment (GAI) mode. This remains the case until the start bit (STR) in the Operation Mode Register (OMR) is set to 1. HSYNC̄ is also held low during the period from RES̄ until the start bit in OMR is set to 1 by the host.

#### 4.2.1.2 Bi-directional Host System Data Bus (D0-D15:INPUT/OUTPUT:3-STATE)

These lines are used for data transfer between the ACRTC and the host system data bus (MPU and/or DMAC). D0-D15 outputs are three state buffers and remain in the high impedance state except during host reads of ACRTC registers.

During reset, depending on the state of the DACK̄ input, the ACRTC can be configured for an 8 bit data bus using D0-D7. In this case, D8-D15 should be left open.

#### 4.2.1.3 Read/Write (R/W̄:INPUT)

R/W̄ controls the direction of transfer between the host system bus and the ACRTC. During non-DMA transfers, when R/W̄ is high, data is transferred from the ACRTC to the host, and when low, data is transferred from the host to the ACRTC.

---
*(source page 49)*

When the ACRTC executes a DMA transfer using an external DMAC, the polarity of R/W̄ is reversed. In this case, when R/W̄ is high, data is transferred from the host to the ACRTC, and when low, data is transferred from the ACRTC to the host.

#### 4.2.1.4 Chip Select (CS̄:INPUT)

The Chip Select, when low, enables access of the ACRTC by the host MPU. Note that Chip Select must not be low during DMA transfers (DACK̄ = low). RS and R/W̄ must be valid when CS̄ is asserted and write data must be valid prior to the trailing (rising) edge of CS̄.

When the ACRTC host data bus mode is 16 bit data bus, 8 bit data transfers are not allowed.

#### 4.2.1.5 Register Select (RS: INPUT)

RS is used to select ACRTC hardware accessed registers. When RS is low, reads (R/W̄ = high) access the Status register and writes (R/W̄ = low) access the Address register. When RS is high, reads and writes access the particular ACRTC Control register with address defined in the previous write to the Address register. If the accessed register is in the range of r80 – rFF, the address register will automatically be incremented to allow access to the next sequential register address. This allows high speed initialization of registers in the address range of r80 – rFF without requiring the MPU to reload the address register for each sequential access. Note that the address increment is 1 for 8 bit host interface mode and 2 for 16 bit host interface mode.

Normally, RS is connected to the least significant bit of the MPU address bus.

#### 4.2.1.6 Data Transfer Acknowledge (DTACK̄:OUTPUT:OPEN DRAIN)

The ACRTC will drive DTACK̄ low to indicate completion of a data transfer cycle. DTACK̄ is compatible with asynchronous bus interface hosts including the HD68000 MPU and HD68450 DMAC.

#### 4.2.1.7 Interrupt Request (IRQ̄:OUTPUT:OPEN DRAIN)

This open drain output is driven low when the ACRTC requires interrupt service. In order to generate an IRQ̄, the interrupting condition must be enabled in the Command Control Register (CCR).

The action required to clear the interrupting condition is specified in the Status Register description (section 5.3).

---
*(source page 50)*

### 4.2.2 DMAC Interface

Three DMA handshaking lines allow the ACRTC to use an external DMA controller. The DMA protocol is directly compatible with HD68450 DMAC single address mode transfers.

#### 4.2.2.1 DMA Request (DREQ̄:OUTPUT)

During DMA transfer mode, DREQ̄ is used to request data transfer service from the host bus DMAC. DREQ̄ is asserted to active low level by ACRTC execution of a Data DMA transfer command (when the Data DMA Mode bit (DDM) in CCR is set to 1) or by setting the Command/Parameter DMA transfer mode bit (CDM) in the CCR to 1. Data DMA can be programmed as burst or cycle steal, while Command/Parameter DMA can only be burst mode.

#### 4.2.2.2 DMA Acknowledge (DACK̄:INPUT)

DACK̄ is an answer back signal from the DMAC to which DREQ̄ has been issued and indicates that the host bus has been acquired, and data transfer can occur. Note that when DACK̄ is asserted low, CS̄ must not be low and the R/W̄ signal polarity is reversed.

RS and R/W̄ must be valid prior to DACK̄ assertion and data written to the ACRTC must be valid prior to the trailing (rising) edge of DACK̄.

DACK̄ is also used to define whether an 8 or 16 bit host data bus is used. During reset, if DACK̄ is low, 8 bit mode is used and if DACK̄ is high, 16 bit mode is used. In the case of 8 bit mode, host-ACRTC communication occurs on the D0-D7 portion of the data bus, while D8-D15 are disabled and driven high. When 8 bit bus mode is selected the automatic increment mode for the Address Register is set to '+1' (alternating even and odd register addresses), while 16 bit bus mode sets it to '+2' (even addresses only).

When 16 bit host data bus mode is used, 8 bit transfers are not allowed. When DMA is not used, DACK̄ should be pulled up to a high level.

#### 4.2.2.3 Done (DONĒ:INPUT/OUTPUT:OPEN DRAIN)

DONĒ is used to terminate DMA transfers. During Data DMA transfers, DONĒ is an output and when asserted low indicates DMA termination to the external DMAC. During Command/Parameter DMA transfers, DONĒ is an input asserted low by the external DMAC to terminate DMA. Note that Data DMA cannot be terminated by externally forcing DONĒ low.

DONĒ is open drain when in the output state, and should be pulled up to high level when not used.

---
*(source page 51)*

### 4.2.3 CRT Interface

#### 4.2.3.1 Clock (2CLK:INPUT)

This is the basic operating clock for the ACRTC which is derived from the external dot clock. The ACRTC internally divides 2CLK by 2 to generate the MCYC Memory Cycle Clock. Thus, 2CLK is twice the frequency of the frame buffer memory access timing. 2CLK must be a continuous clock input.

#### 4.2.3.2 Vertical Synchronization (VSYNC̄:OUTPUT)

VSYNC̄ is used to output the active low Vertical Synchronization timing signal required by the CRT display device.

#### 4.2.3.3 Horizontal Synchronization (HSYNC̄:OUTPUT)

HSYNC̄ is used to output the active low Horizontal Synchronization timing signal required by the CRT display device.

HSYNC̄ is also used when the ACRTC performs DRAM refresh addressing of the frame buffer. In the case that the STR start bit or the RAM bit in the Operation Mode Register (OMR) are set to 0, HSYNC̄ asserted low indicates that the DRAM refresh addresses are present on MAD frame buffer address/data bus.

#### 4.2.3.4 External Synchronization (EXSYNC̄:INPUT/OUTPUT)

EXSYNC̄ is an active low input and output signal used for synchronizing multiple ACRTCs or synchronizing the ACRTC with other video generating devices. The ACRTC is programmed as a master or slave by the state of the M/S bit in the Operation Mode Register (OMR). When the ACRTC is master, EXSYNC̄ is an output which may be used to drive a slave video generating devices VSYNC̄ input or a slave ACRTCs EXSYNC̄ input. When the ACRTC is slave, EXSYNC̄ is an input which receives the masters EXSYNC̄ (master is another ACRTC) or VSYNC̄ (master is another video generating device).

In both master and slave configurations, the timing of EXSYNC̄ depends on the interlace mode. For example, in interlaced modes, EXSYNC̄ timing corresponds to VSYNC̄ of the odd field.

---
*(source page 52)*

#### 4.2.3.5 Light Pen Strobe (LPSTB:INPUT)

LPSTB input accepts a positive strobe pulse generated by an external light pen. When asserted high, the current frame buffer display refresh address is latched into the Light Pen Address Register and the LPD (Light Pen Detect) bit in the Status Register is set to 1, generating an interrupt if enabled to do so by the MPU. The stored address will be different from the actual address due to the following delays.

(a) ACRTC address output delay
(b) Address output to video signal output delay
(c) Light pen detection to LPSTB delay
(d) LPSTB to internal recognition delay

The actual address should be calculated by adjusting the stored address considering the above delays. Also note that, for Superimposed access mode, when the light pen strobe occurs in the Window screen, the overlapped Background (Upper, Base, Lower) screen address is latched.

#### 4.2.3.6 Memory Cycle (MCYC:OUTPUT)

MCYC frequency is one-half that of thr ACRTC 2CLK input and is output continuously. MCYC determines frame buffer memory access timing. MCYC low indicates the address portion of the memory access while MCYC high indicates the data portion of the memory access.

#### 4.2.3.7 Address Strobe (AS̄:OUTPUT)

AS̄ output is used to latch the frame buffer address. When AS̄ is low, the MAD outputs contain the frame buffer address. AS̄ is also used to load the external parallel to serial (shift register) converter with the data from frame buffer during the display cycle.

#### 4.2.3.8 Memory Read (MRD:OUTPUT)

During a frame buffer access, MRD indicates the direction of data transfer between the ACRTC and the frame buffer. When MRD is high, a frame buffer read cycle occurs, and when MRD is low, a frame buffer write cycle occurs. In superimposed mode, MRD low indicates the read cycle of window screen data (second phase).

#### 4.2.3.9 Draw (DRAW̄:OUTPUT)

The DRAW̄ signal differentiates between ACRTC drawing and CRT display refresh cycles. When DRAW̄ is low, the MAD outputs contain multiplexed drawing address and data information. When DRAW̄ is high, the MAD outputs contain a display refresh address during the address portion of the cycle, and are high impedance during the data portion of the cycle.

---
*(source page 53)*

#### 4.2.3.10 Frame Buffer Memory Address/Data (MAD0-MAD15:INPUT/OUTPUT:3-STATE)

MAD0-MAD15 are the time multiplexed, bi-directional frame buffer memory address and data bus. When AS̄ is low, MAD contains the lower 16 bits of the drawing or display address. When AS̄ is high and DRAW̄ is low, MAD transfers the drawing data to and from the frame buffer.

When no frame buffer access is occurring, the MAD bus is 3-stated.

When the RAM bit in the Operation Mode Register (OMR) is set to 0, the 8 bit DRAM refresh address is output on MAD during HSYNC̄ low. The particular bits of MAD used for this 8 bit refresh address depend on the programmed Graphic Address Increment (GAI) mode.

#### 4.2.3.11 Memory Address/Raster Address (MA16/RA0-MA19/RA3:OUTPUT)

These lines output either the 4 most significant bits of the frame buffer address (MA16-MA19) or the 4 least significant bits of the raster address (RA0-RA3). In Character mode (CHR = high), these lines are used as a raster address for connection to an external character generator. In Graphic mode (CHR = low) these lines are used with MAD0-MAD15 to provide a 20 bit linear frame buffer address.

#### 4.2.3.12 Raster Address 4 (RA4:OUTPUT)

In Character mode (CHR = high), RA4 output the most significant bit of the raster address. Thus, 5 bits (RA0-RA4) provide up to 32 rasters per character.

In Graphic mode (CHR = low), the state of this output is undefined.

#### 4.2.3.13 Character (CHR:OUTPUT)

CHR is an output indicating whether the current frame buffer address on MAD has been defined as corresponding to character (CHR = high) or graphic (CHR = low). When high, MAD0-MAD15 contains a 16 bit frame buffer address, while other MAD lines contain raster address information. When low, MAD0-MAD15, MA16-MA19 contains a 20 bit linear frame buffer address. CHR can be used to enable an external character generator. Also, CHR can be used to enable the appropriate memory bank in the case that character and graphic memory are separated.

---
*(source page 54)*

#### 4.2.3.14 Display Timing (DISP1,DISP2:OUTPUT)

These active low outputs indicate the active display period of the screen. They can be used in one of two ways.

(a) Background screen/window screen display timing signal
(b) Vertical/horizontal display timing signal

#### 4.2.3.15 Cursor Display (CUD1,CUD2:OUTPUT)

These outputs are externally logically combined with the video signal to produce the cursor display on the screen. Three modes of cursor display are selectable by setting the cursor mode (CM) bits in the Cursor Definition Register (CDR).

**Table: Cursor Mode / CUD1 / CUD2**

| Cursor Mode | Description | CUD1 | CUD2 |
|---|---|---|---|
| BLOCK | The separate display of two BLOCK cursors | Block cursor 1 | Block cursor 2 |
| GRAPHIC | The display of a GRAPHIC cursor and two multiplexed BLOCK cursors | Graphic cursor | Block cursor 1&2 |
| CROSSHAIR | The X and Y portions of a CROSSHAIR cursor | X portion | Y portion |

### 4.2.4 Power Supply

#### 4.2.4.1 Vcc, Vss

These pins supply power to the ACRTC. Vcc is specified as 5V ± 10% (4.5V～5.5V).

---
*(source page 55)*

### 4.2.5 Video Attributes

The ACRTC outputs 20 bits of video attributes on MAD0-MAD15 and MA16/RA0-MA19/RA3. These attributes are output at the last cycle prior to the rising edge of HSYNC̄ and should be latched externally. Thus, video attributes can be set on a raster by raster basis.

**Figure 4.2 Video Attributes**

The figure shows a vertical bit-field diagram mapping ACRTC output pins to video attribute field names, from MA19 (top/MSB) down to MAD0 (bottom/LSB):

| Pin | Field | Group |
|---|---|---|
| MA19 | BLINK2 | Blink |
| MA18 | BLINK1 | Blink |
| MA17 | SPL2 | Split Screen Number |
| MA16 | SPL1 | Split Screen Number |
| MAD15 | HZ3 | Horizontal Zoom |
| MAD14 | HZ2 | Horizontal Zoom |
| MAD13 | HZ1 | Horizontal Zoom |
| MAD12 | HZ0 | Horizontal Zoom |
| MAD11 | HSD3 | Horizontal Scroll Dot |
| MAD10 | HSD2 | Horizontal Scroll Dot |
| MAD9 | HSD1 | Horizontal Scroll Dot |
| MAD8 | HSD0 | Horizontal Scroll Dot |
| MAD7 | ATC7 | Attribute Code |
| MAD6-MAD1 | ATC6-ATC1 | Attribute Code |
| MAD0 | ATC0 | Attribute Code |

(The diagram shows the intermediate MAD1-MAD6 rows as a bracketed range between MAD7/ATC7 and MAD0/ATC0, all part of the 8-bit Attribute Code field; similarly MAD12-MAD15 are bracketed for Horizontal Zoom and MAD8-MAD11 for Horizontal Scroll Dot.)

---
*(source page 56)*

#### 4.2.5.1 Attribute Code (ATC0-ATC7:MAD0-MAD7)

These are user defined attributes. The programmed contents of the Attribute Control bits (ATR) of the Display Control Register (DCR) are output on these lines.

#### 4.2.5.2 Horizontal Scroll Dot (HSD0-HSD3:MAD8-MAD11)

These are used in conjunction with external circuitry to implement smooth horizontal scroll. These lines contain the encoded start dot address which is used to control the external shift register load timing and data. HSD usually corresponds to the start dot address of the background screens. However, if the window smooth scroll (SWS) bit of OMR (Operation Mode Register) is set to 1, HSD outputs the start dot address of the window screen segment.

#### 4.2.5.3 Horizontal Zoom Factor (HZ0-HZ3:MAD12-MAD15)

These lines output the encoded (1-16) horizontal zoom factor as stored in the Zoom Factor Register (ZFR). Horizontal zoom is accomplished by the ACRTC repeating a single display address and using the HZ outputs to control the external shift register clock. Horizontal zoom can only be applied to the Base screen.

#### 4.2.5.4 Split Position (SPL1-SPL2:MA16-MA17)

These lines present the encoded information showing the enabled background screen currently being displayed by the ACRTC.

| SPL2 | SPL1 | |
|---|---|---|
| 0 | 0 | Background Screen not enabled or displayed |
| 0 | 1 | Base Screen |
| 1 | 0 | Upper Screen |
| 1 | 1 | Lower Screen |

#### 4.2.5.5 Blink (BLINK1-BLINK2:MA18-MA19)

The lines alternate from high to low periodically as defined in the Blink Control Register (BCR). the blink frequency is specified in units of 4 field times. A field is defined as the period between successive VSYNC̄ pulses. These lines are used to implement character and screen blink.

---
*(source page 57)*

# 5. REGISTER DESCRIPTION

## 5.1 Internal Register Access

The ACRTC incorporates more than 200 bytes of internal Control registers and Control RAM which are accessible by the host MPU. The programming model is shown in figure 5.1.

For the detailed register descriptions in this section, the following terminology is used.

Hexadecimal numbers are denoted by a leading $ i.e. $1234, $FF, etc.

For directly accessible registers, the register address is shown as 'rNN' where NN is interpreted as an 8 bit hexadecimal value. For example, the Zoom Factor Register address is 0EA hexadecimal, so ZFRs register address is shown as 'rEA'.

For FIFO accessible Drawing Parameter Registers, the register address is shown as 'PrNN'. For example, the Color Comparison Register is addressed as parameter register 2 hex, so the CMP register address is shown as 'Pr02'.

Bit subfields within the register are denoted using decimal bit numbers in which bit 0 is the least significant bit and bit 15 the most significant bit.

When the register diagram is shown, unused bits will be shaded. Unless stated otherwise, unused bits may be freely written with any value, and that value will be returned on subsequent reads of the register.

---
*(source page 58)*

**Figure 5.1 Programming Model**

The figure is a block diagram of the ACRTC's internal register/RAM organization, showing four major groupings:

**Control Register** (left column, 8-bit wide boxes, addresses implied by later figure): Address Register, Status Register, a dashed box "FIFO Entry" (which connects via arrows to both the Write FIFO and Read FIFO blocks at right), Command Control Register, Operation Mode Register, Display Control Register, then a bracketed group of CRT-timing registers — Raster Counter, Horizontal Sync., Horizontal Display, Vertical Sync., Vertical Display, Split Screen Width, Blink Control, Horizontal Window Display, Vertical Window Display, Graphic Cursor — followed by a second bracketed group of per-screen and cursor registers: Split Screen 0 Control (Upper Screen), Split Screen 1 Control (Base Screen), Split Screen 2 Control (Lower Screen), Split Screen 3 Control (Window Screen), Block Cursor, Cursor Definition, Zoom Factor, Light Pen Address.

**Write FIFO / Read FIFO** (top right, 16-bit wide boxes, bits 15-0 labeled): the dashed "FIFO Entry" box has arrows pointing into the Write FIFO and out of the Read FIFO, indicating FIFO Entry register accesses route to these hardware FIFOs. Below both FIFOs, a "Command Register" box receives from/sends to the FIFOs (double-headed arrow).

**Pattern RAM** (middle right, tall 16-bit wide box): a separate block of pattern storage RAM, drawn as a 3D block.

**Drawing Parameter Register** (bottom right, 16-bit wide boxes): Color 0, Color 1, Color Comparison, Edge Color, Mask, Pattern RAM Control, Area Definition, Read/Write Pointer, Drawing Pointer, Current Pointer.

Bracket labels on the far left/middle identify the "Control Register" group and "Drawing Parameter Register" group as the two register banks accessed via the 8-bit Address/Status registers and FIFO, respectively.

---
*(source page 59)*

**Figure 5.1 (cont.) Programming Model**

This is a detailed register map table listing every ACRTC register address, its bit-field layout across DATA(H) bits 15-8 and DATA(L) bits 7-0, selected by CS (Chip Select), RS (Register Select) and R/W. Columns: CS, RS, R/W, Reg. No. (hex register address), Register Name, Abbr. (abbreviation), then the 16 data bits 15 down to 0 (DATA(H) = bits 15-8, DATA(L) = bits 7-0), with bit-field labels shown spanning the bit positions they occupy (a "—" marks unused/reserved bit positions).

| CS | RS | R/W | Reg. No. | Register Name | Abbr. | DATA(H) [15..8] | DATA(L) [7..0] |
|---|---|---|---|---|---|---|---|
| 1 | — | — | — | — | — | — | — |
| 0 | 0 | 0 | AR | Address Register | AR | — | Address |
| 0 | 0 | 1 | SR | Status Register | SR | — | CER, ARD, CED, LPD, RFF, RFR, WFR, WFE |
| 0 | 1 | 1/0 | r00 | FIFO Entry | FE | FE (spans full 16 bits) | FE (spans full 16 bits) |
| 0 | 1 | 1/0 | r02 | Command Control | CCR | ABT, PSE, DDM, CDM, DRC, GBM(bits 10-8) | CRE, ARE, CEE, LPE, RFE, RRE, WRE, WEE |
| 0 | 1 | 1/0 | r04 | Operation Mode | OMR | M/S, STR, ACP, WSS, CSK(11-10), DSK(9-8) | RAM, GAI(6-4), ACM(3-2), RSM(1-0) |
| 0 | 1 | 1/0 | r06 | Display Control | DCR | DSP, SE1, SE0(13-12), SE2(11-10), SE3(9-8) | ATR (bits 7-0) |
| 0 | 1 | — | r08–r7E | (unassigned) | — | No USE and RESERVED | No USE and RESERVED |
| 0 | 1 | 1 | r80 | Raster Count | RCR | —(15-11), RC(10-8) | RC (7-0) |
| 0 | 1 | 1/0 | r82 | Horizontal Sync. | HSR | HC (11-8, spans into DATA(L) high nibble) | —, HSW |
| 0 | 1 | 1/0 | r84 | Horizontal Display | HDR | HDS | —, HDW |
| 0 | 1 | 1/0 | r86 | Vertical Sync. | VSR | —(15-11), VC(10-8) | VC (7-0) |
| 0 | 1 | 1/0 | r88 | Vertical Display | VDR | VDS | —, VSW |
| 0 | 1 | 1/0 | r8A/r8C/r8E | Split Screen Width | SSW | —(15-11) each row | SP1 (r8A), SP0 (r8C), SP2 (r8E) |
| 0 | 1 | 1/0 | r90 | Blink Control | BCR | BON1, BOFF1 | BON2, BOFF2 |
| 0 | 1 | 1/0 | r92 | Horizontal Window Display | HWR | HWS | —, HWW |
| 0 | 1 | 1/0 | r94/r96 | Vertical Window Display | VWR | —(15-11) each row | VWS (r94), VWW (r96) |
| 0 | 1 | 1/0 | r98/r9A/r9C | Graphic Cursor | GCR | —(15-11)/CXE row | CXS (r98), CYS (r9A), CYE (r9C) |
| 0 | 1 | — | r9E | ACRTC Work Area | — | — | — |
| 0 | 1 | — | rA0–rBE | (unassigned) | — | No USE and RESERVED | No USE and RESERVED |
| 0 | 1 | 1/0 | rC0/rC2/rC4/rC6 | UPPER (Background) — Raster Address 0 / Memory Width 0 / Start Address 0 | RAR0 / MWR0 / SAR0 | RAR0: —,LRA0; MWR0: CHR,—; SAR0: —,SDA0,SA0L | RAR0: —,FRA0; MWR0: MW0; SAR0: —,SA0H/SAR0 |
| 0 | 1 | 1/0 | rC8/rCA/rCC/rCE | BASE (Background) — Raster Address 1 / Memory Width 1 / Start Address 1 | RAR1 / MWR1 / SAR1 | analogous to Screen 0, for Base screen (RAR1: —,LRA1; MWR1: CHR,—; SAR1: —,SDA1,SA1L) | analogous (RAR1: —,FRA1; MWR1: MW1; SAR1: —,SA1H/SRA1) |
| 0 | 1 | 1/0 | rD0/rD2/rD4/rD6 | LOWER (Background) — Raster Address 2 / Memory Width 2 / Start Address 2 / Star 3 | RAR2 / MWR2 / SAR2 | analogous (RAR2: —,LRA2; MWR2: CHR,—; SAR2: —,SDA2,SA2L) | analogous (RAR2: —,FRA2; MWR2: MW2; SAR2: —,SA2H/SRA2) |
| 0 | 1 | 1/0 | rD8/rDA/rDC/rDE | Window — Raster Address 3 / Memory Width 3 / Start Address 3 | RAR3 / MWR3 / SAR3 | analogous (RAR3: —,LRA3; MWR3: CHR,—; SAR3: —,SDA3,SA3L) | analogous (RAR3: —,FRA3; MWR3: MW3; SAR3: —,SA3H/SRA3) |
| 0 | 1 | 1/0 | rE0/rE2 | Block Cursor 1 | BCUR1 | BCW1, BCSR1 | —,BCER1 (rE0); BCA1 (rE2) |
| 0 | 1 | 1/0 | rE4/rE6 | Block Cursor 2 | BCUR2 | BCW2, BCSR2 | —,BCER2 (rE4); BCA2 (rE6) |
| 0 | 1 | 1/0 | rE8 | Cursor Definition | CDR | CM, CON1, COFF1 | —, CON2, COFF2 |
| 0 | 1 | 1/0 | rEA | Zoom Factor | ZFR | HZF, VZF | — |
| 0 | 1 | 1 | rEC/rEE | Light Pen Address | LPAR | —, CHR, —, LPAH (rEC) | LPAL (rEE) |
| 0 | 1 | — | rF0–rFE | (unassigned) | — | No USE and RESERVED | No USE and RESERVED |

Note: this table is a best-effort linearization of a dense two-dimensional bit-field diagram; where a register's bit-field boundaries could not be determined precisely from the scan, the field names are listed in bit-position order (high to low) without exact bit-index boundaries. Individual registers are described in detail, with precise bit-field diagrams, in the following subsections of Section 5.

---
*(source page 60)*

## 5.2 Address Register

**Figure 5.2 Address Register (AR)**

A 16-bit register diagram, bits 15 down to 0, divided into "High-order" (bits 15-8) and "Low-order" (bits 7-0) groups. Bits 15-8 are shown shaded/hatched (unused/reserved). Bits 7-0 are labeled "Address".

AR is a write only register used to specify the address (0-$FF) of the ACRTC control register to be accessed. AR is written during MPU write cycles in which CS̄ and RS are both low.

In the 16 bit mode, the least significant bit of AR is always recognized as 0, and thus the AR provides a word register address. In the 8 bit bus mode, if AR is even, the most significant byte of the control register is accessed. If odd, the least significant byte of the control register is accessed. Independent of 8 or 16 bit bus mode, AR should be loaded with 0 to access the read and write FIFOs.

The Timing Control RAM and Display Control RAM occupy the register address space from r80-r9F and rC0-rEF respectively. To support block move type initialization/access of these registers, reads and writes to the register address space r80-rFF result in automatic incrementing of AR. Thus, the programmer need not explicitly address each register for sequential access. AR is incremented by 1 in 8 bit bus mode, and by 2 in 16 bit bus mode.

AR is not incremented for accesses of r00-r7F.

---
*(source page 61)*

## 5.3 Status Register (SR: CS̄, RS̄ = low, R/W̄ = high)

**Figure 5.3 Status Register (SR)**

A 16-bit register diagram, bits 15 down to 0. Bits 15-8 are shaded/hatched (unused/reserved). Bits 7-0 are labeled, from bit 7 to bit 0: CER, ARD, CED, LPD, RFF, RFR, WFR, WFE. Callout lines from each bit lead to full names, listed bottom to top: Command Error (bit 7, CER), Area Detect (bit 6, ARD), Command End (bit 5, CED), Light Pen Strobe Detect (bit 4, LPD), Read FIFO Full (bit 3, RFF), Read FIFO Ready (bit 2, RFR), Write FIFO Ready (bit 1, WFR), Write FIFO Empty (bit 0, WFE).

SR is a read-only register containing 8 bits which reflect the state of internal status flags. If enabled by an interrupt enable bit in the CCR, a 1 bit in the corresponding SR flag will cause an interrupt (IRQ̄) to be generated.

When hardware RES̄ is asserted, the CED, WFE and WFR bits are set to 1 and all other bits are reset to 0.

○ Command Error Flag (CER: bit 7)
CER set to 1 indicates that the ACRTC has detected an undefined command or invalid parameter.
CER is cleared by setting the ABT bit in CCR = 1.

○ Area Detect Flag (ARD: bit 6)
ARD is set to 1 depending on the AREA mode programmed for ACRTC graphic drawing commands. The ARD flag allows the MPU to detect whether the ACRTC has performed clipping or hitting during graphic drawing.
ARD is cleared by execution of the RPR (Read Parameter Register) command or setting the ABT bit in CCR = 1.

---
*(source page 62)*

○ Command End (CED: bit 5)
CED set to 1 indicates that the ACRTC is able to accept a new command.
CED is cleared by writing a command to the write FIFO.

○ Light Pen Detect (LPD: bit 4)
LPD set to 1 indicates that the light pen strobe (LPSTB) has occurred and the Light Pen Address Register contains the latched address.
LPD is cleared by reading the Light Pen Address Register or setting the ABT bit in CCR = 1.

○ Read FIFO Full (RFF: bit 3)
RFF set to 1 indicates that the read FIFO is full (contains 8 words/16 bytes of data).
RFF is cleared by reading at least one 16 bit word from the read FIFO or setting the ABT bit in CCR = 1.

○ Read FIFO Ready (RFR: bit 2)
RFR set to 1 indicates that the read FIFO contains one or more words of data.
RFR is cleared by reading all data from the read FIFO.

○ Write FIFO Ready (WFR: bit 1)
WFR set to 1 indicates that the write FIFO is not full, and MPU writes can occur. WRF is also set to 1 when the ABT bit in CCR is set to 1.
WFR is cleared when the write FIFO contains 8 words/16 bytes of data.

○ Write FIFO Empty (WFE: bit 0)
WFE set to 1 indicates that the write FIFO is empty. WFE is also set to 1 when the ABT bit in CCR is set to 1.
WFE is cleared when a 16 bit word data is written to the write FIFO.

---
*(source page 63)*

**Table 5.1 Setting and Resetting of Status Register**

| Bit | Status Register | Set | Reset |
|---|---|---|---|
| 7 | CER (Command Error) | An undefined command has been detected | Abort |
| 6 | ARD (Area Detect) | An area has been detected according to the AREA mode command | Execute a Read Parameter Register (RPR) command · Abort |
| 5 | CED (Command End) | A command has been executed · Abort | Write a command to the write FIFO |
| 4 | LPD (Light Pen Strobe Detect) | LPSTB has occurred | Read the Light Pen Address Register after reading the Status Register · Abort |
| 3 | RFF (Read FIFO Full) | The read FIFO is full | Read data from the read FIFO |
| 2 | RFR (Read FIFO Ready) | The read FIFO contains data | Read all data from the read FIFO · Abort |
| 1 | WFR (Write FIFO Ready) | The write FIFO is not full · Abort | The write FIFO is full |
| 0 | WFE (Write FIFO Empty) | The write FIFO is empty · Abort | Write data into the write FIFO |

---
*(source page 64)*

## 5.4 FIFO Entry (FE: r00-r01)

**Figure 5.4 FIFO Entry (FE)**

A 16-bit register diagram, bits 15 down to 0, divided into "High-order (r00)" (bits 15-8) and "Low-order (r01)" (bits 7-0) groups. The entire 16-bit field is labeled "FE" and captioned below as "FIFO Entry".

When the AR contains the FIFO Entry address (r00), reads and writes to the ACRTC (CS̄ = low, RS = high) utilize the corresponding 16 byte read or write FIFOs.

In 16 bit bus mode, 16 bit words are written and read to/from the appropriate FIFO. In 8 bit bus mode, FIFO writes are in the order of high byte-low byte, while FIFO reads are in the order of high byte-low byte.

In DMA transfer mode, the read and write FIFOs are selected regardless of the contents of AR and AR remains unchanged.

---
*(source page 65)*

## 5.5 Command Control Register (CCR: r02-r03)

**Figure 5.5 Command Control Register**

A 16-bit register diagram, divided into "High-order (r02)" (bits 15-8) and "Low-order (r03)" (bits 7-0). Bit labels from bit 15 to bit 0: ABT, PSE, DDM, CDM, DRC, GBM (spanning bits 10-8), CRE, ARE, CEE, LPE, RFE, RRE, WRE, WEE. Callout lines lead to full names:

- Bit 15: ABORT (ABT)
- Bit 14: PAUSE (PSE)
- Bit 13: Data DMA Mode (DDM)
- Bit 12: Command DMA Mode (CDM)
- Bit 11: DMA Request Control (DRC)
- Bits 10-8: Graphic Bit Mode (GBM)
- Bit 7: Command Error Interrupt Enable (CRE)
- Bit 6: Area Detect Interrupt Enable (ARE)
- Bit 5: Command End Interrupt Enable (CEE)
- Bit 4: Light Pen Strobe Interrupt Enable (LPE)
- Bit 3: Read FIFO Full Interrupt Enable (RFE)
- Bit 2: Read FIFO Ready Interrupt Enable (RRE)
- Bit 1: Write FIFO Ready Interrupt Enable (WRE)
- Bit 0: Write FIFO Empty Interrupt Enable (WEE)

Bits 7-0 are collectively bracketed as "Interrupt Enable (IE)".

CCR controls command processing and enabling and disabling of interrupt requests. The 8 interrupt enable bits in the low byte of CCR correspond directly to the 8 status flags in the Status register.

When RES̄ is asserted, the ABT (abort) bit is initialized to 1 and all other CCR bits are initialized to 0.

---
*(source page 66)*

○ Abort (ABT: bit 15)

| ABT | Functions |
|---|---|
| 0 | ACRTC command execution is enabled. When ABT is changed from 0 to 1, the ACRTC cannot access the FIFOs. |
| 1 | ACRTC command execution is aborted and the read/write FIFOs are cleared. The status register (SR) is set to $23. |

○ Pause (PSE: bit 14)

| PSE | Functions |
|---|---|
| 0 | ACRTC command execution is resumed. |
| 1 | ACRTC command execution is halted until PSE is reset to 0. ACRTC DMA (Data and Command/Parameter) is halted until PSE is reset to 0. |

○ Data DMA Mode (DDM: bit 13)

| DDM | Functions |
|---|---|
| 0 | Data DMA transfer mode is disabled. DREQ̄ is not asserted even if the MPU issues DMA transfer commands. |
| 1 | Data DMA transfer mode is enabled. Whether DMA is burst or cycle steal mode is determined by DRC (bit 11 this register). DDM must be set before DMA data transfer commands are issued. |

Note: MPU must not access ACRTC FIFOs during cycle steal transfer.

○ Command DMA Mode (CDM: bit 12)

| CDM | Functions |
|---|---|
| 0 | Command/Parameter DMA transfer mode is disabled. Commands and parameters are issued under MPU program control. |
| 1 | Command/Parameter DMA transfer mode is enabled. Command/Parameter DMA mode is terminated when (a) the MPU resets CDM to 0 or (b) the DONĒ input is asserted (which also resets CDM to 0). |

Note: (a) Command/Parameter DMA transfers use cycle stealing DMA regardless of the state of DRC (bit 11 this register).
(b) Data DMA transfer commands cannot be issued using Command/Parameter DMA. Insure that the Commands and Parameters transferred by Command/Parameter DMA do not include DMA data transfer commands.

---
*(source page 67)*

○ DMA Request Control (DRC: bit 11)

| DRC | Functions |
|---|---|
| 0 | Burst Mode: DREQ̄ is designated as a level signal (burst mode). DRC = 0 is only valid for data DMA transfer commands. A maximum of 8 words/16 bytes data is transferred per DMA request. The ACRTC controls DREQ̄ by monitoring the empty state of the read/write FIFOs. Burst mode can only be used for Data DMA. |
| 1 | Cycle Steal Mode: DREQ̄ is designated as a pulse signal (cycle steal mode). DREQ̄ is output once for each word (16 bit data bus mode) or once for each byte (8 bit data bus mode) transfer. In the data DMA transfer mode, the ACRTC controls DREQ̄ as described above. In the command/parameter DMA transfer mode, the ACRTC will issue DREQ̄ when 1 word (byte) space remains in the FIFO. Thus, when DREQ̄ stops, the MPU can immediately make at least one access of the ACRTC write FIFO. |

○ Graphic Bit Mode (GBM: bit 10 - bit 8)

GBM defines the number of physical bits of frame buffer memory associated with a logical pixel. 1 bit per pixel is monochrome, while 16 bits per pixel allows a logical pixel to assume 1 of 64K possible colors or tones.

| GBM 10 | GBM 9 | GBM 8 | Mode | Number of colors displayed per pixel | Pixels/16 bit word |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 1 bit/pixel | 1 | 16 |
| 0 | 0 | 1 | 2 bits/pixel | 4 | 8 |
| 0 | 1 | 0 | 4 bits/pixel | 16 | 4 |
| 0 | 1 | 1 | 8 bits/pixel | 256 | 2 |
| 1 | 0 | 0 | 16 bits/pixel | 64K | 1 |
| ... | ... | ... | ← INVALID → | ← INVALID → | ← INVALID → |
| 1 | 1 | 1 | (invalid, continued) | | |

---
*(source page 68)*

○ Interrupt Enable Bit (IE: bit 7 - bit 0)

An IRQ̄ is generated when an event flag in the Status register and the corresponding interrupt enable bit are both set to 1.

| Bit | | Name | Set to 1 to enable interrupt for... |
|---|---|---|---|
| 7 | Command Error | CRE | Command Error |
| 6 | Area Detect | ARE | Clipping and Hitting detection |
| 5 | Command End | CEE | Command Termination |
| 4 | Light Pen Detect | LPE | LPSTB Asserted |
| 3 | Read FIFO Full | RFE | Read FIFO Full |
| 2 | Read FIFO Ready | RRE | Read FIFO Ready |
| 1 | Write FIFO Ready | WRE | Write FIFO Ready |
| 0 | Write FIFO Empty | WEE | Write FIFO Empty |

---
*(source page 69)*

## 5.6 Operation Mode Register (OMR: r04-r05)

**Figure 5.6 Operation Mode Register (OMR)**

A 16-bit register diagram, divided into "High-order (r04)" (bits 15-8) and "Low-order (r05)" (bits 7-0). Bit labels from bit 15 to bit 0: M/S, STR, ACP, WSS, CSK (spanning bits 11-10), DSK (spanning bits 9-8), RAM, GAI (spanning bits 6-4), ACM (spanning bits 3-2), RSM (spanning bits 1-0). Callout lines lead to full names:

- Bit 15: Master/Slave (M/S)
- Bit 14: Start (STR)
- Bit 13: Access Priority (ACP)
- Bit 12: Window Smooth Scroll (WSS)
- Bits 11-10: Cursor Display Skew (CSK)
- Bits 9-8: DISP Skew (DSK)
- Bit 7: RAM Mode (RAM)
- Bits 6-4: Graphic Address Increment Mode (GAI)
- Bits 3-2: Access Mode (ACM)
- Bits 1-0: Master Scan Mode (RSM)

OMR determines major operating parameters and modes of the ACRTC. The 2 most significant bits (M/S and STR) are reset to 0 and all other bits are unaffected by RES̄.

○ Master/Slave (M/S: bit 15)

M/S defines whether the ACRTC operates as a master or slave when combined with other ACRTCs or video generating devices. M/S is reset to 0 during RES̄. When a single ACRTC is used, M/S should be set to 1 and the EXSYNC̄ pin left open.

| M/S | Functions |
|---|---|
| 0 | Slave Mode: EXSYNC̄ is defined as an input. ACRTC internal operations are reset on the rising edge of the EXSYNC̄ input. For non-interlace modes, the masters VSYNC̄ should be connected to the EXSYNC̄ input. For interlaced modes, the VSYNC̄ of the masters odd field should be connected to the EXSYNC̄ input. In the specific case of multiple ACRTC synchronization, the master and all slaves ACRTCs EXSYNC̄ pins should be connected independent of interlace mode. |
| 1 | Master Mode: EXSYNC̄ is defined as an output. For non-interlace modes, the EXSYNC̄ output timing is the same as VSYNC̄ output timing. For interlace modes, the EXSYNC̄ output timing is generated by the VSYNC̄ output for the odd field. |

Note: HSYNC̄ and VSYNC̄ are always outputs regardless of the state of the M/S bit.

---
*(source page 70)*

○ Start (STR: bit 14)

The STR bit is used to start and stop ACRTC operation. STR is reset to 0 by ACRTC hardware RES̄. Initializing of registers which control basic ACRTC operation should only be performed when STR is reset to 0.

| STR | Functions |
|---|---|
| 0 | ACRTC display control and drawing operations are halted. DISP, CUD, VSYNC̄, etc. go to the inactive high level. HSYNC̄ is set to low level, and the DRAM refresh address is output on the MAD lines regardless of the state of the RAM mode bit (bit 7 of this register). The internal time base for CRT control signals is reset. |
| 1 | ACRTC starts display and drawing operations. Drawing commands halted when STR was reset to 0 are resumed. |

○ Drawing Access Priority (ACP: bit 13)

ACP determines whether or not the ACRTC executes drawing operations on the frame buffer during the display refresh period.

| ACP | Functions |
|---|---|
| 0 | Display priority mode: During the display period, the ACRTC halts drawing operations. thus, flashing due to simultaneous display and drawing access of the frame buffer is eliminated. Drawing operations are performed during horizontal and vertical retrace. If DRAM refresh mode is enabled (RAM bit is reset to 0) drawing is inhibited during the DRAM refresh period. In Interleaved Access Mode drawing can occur simultaneously with display, without 'flashing', since drawing and display access to the frame buffer is interleaved. In Superimposed Access Mode, flashless Background screen drawing may occur during idle Window display cycles. |
| 1 | Drawing priority mode: Drawing is performed during the display period. To reduce the 'flashing' effect caused by drawing-display contention the ACRTC may be programmed to drive the DISP̄ signals to the inactive high level during drawing operations. If the RAM bit is reset to 0 (DRAM refresh mode), drawing is inhibited during the DRAM refresh period. If the RAM bit is set to 1 (Static RAM mode), drawing is also performed during the DRAM refresh period. |

Note: Since the last cycle of HSYNC̄ low time is used as a video attribute output period, this cycle is never used for drawing regardless of the state of ACP and RAM bits.

---
*(source page 71)*

○ Window Smooth Scroll (WSS: bit 12)

WSS determines whether horizontal smooth scroll is applied to the Window screen. Window smooth scroll is only available in the Superimposed access mode. Therefore, if the Window screen is disabled, or the access mode is Single or Interleaved, WSS must be reset to 0. The horizontal smooth scroll is implemented by using four bits of SDA (Start Dot Address) programmed in the Window Start Address Register (SAR3). These bits are output on MAD12-MAD15 during the video attribute output period (last cycle of HSYNC̄ low) and are used to control an external circuit which modifies the parallel to serial converter (shift register) timing.

| WSS | Functions |
|---|---|
| 0 | Horizontal smooth scroll is not performed for the Window screen. One cycle Window screen prefetch does not occur. |
| 1 | Horizontal smooth scroll is performed for the Window screen. The Window display refresh cycle starts one cycle earlier than programmed in the Horizontal Window Register (HWR) Horizontal Display Start (HDS) field. |

○ Cursor Display Skew (CSK: bit 11 - bit 10)

CSK defines the delay time for CUD1̄ and CUD2̄ in units of memory cycle independent of frame buffer access mode (i.e. Single, Interleaved or Superimposed). The CUD1̄ and CUD2̄ skew allows compensating for delays due to frame buffer memory, character generator or other external logic access time.

In the Crosshair cursor mode, CSK = 00 should not be used.

| CSK 11 | CSK 10 | Functions |
|---|---|---|
| 0 | 0 | No skew. CUD2̄ output is always high. |
| 0 | 1 | CUD1̄, CUD2̄ are skewed by one memory cycle. |
| 1 | 0 | CUD1̄, CUD2̄ are skewed by two memory cycles. |
| 1 | 1 | CUD1̄, CUD2̄ are skewed by three memory cycles. |

○ DISP Skew (DSK: bit 9 - bit 8)

DSK defines the DISP1̄, DISP2̄ delay in units of memory cycle independent frame buffer access mode.

| DSK 9 | DSK 8 | Functions |
|---|---|---|
| 0 | 0 | No skew. |
| 0 | 1 | DISP1̄, DISP2̄ are skewed by one memory cycle. |
| 1 | 0 | DISP1̄, DISP2̄ are skewed by two memory cycles. |
| 1 | 1 | DISP1̄, DISP2̄ are skewed by three memory cycles. |

---
*(source page 72)*

○ RAM Mode (RAM: bit 7)

The RAM bit determines whether or not the ACRTC will place an 8 bit DRAM refresh address on the MAD outputs during HSYNC̄ low. In this context, HSYNC̄ low time is also referred to as the 'DRAM refresh period' except for the last cycle of HSYNC̄ low, which is referred to as the 'Attribute output period'. The refresh addressing mechanism is compatible with standard 16K, 64K and 256K bit DRAMs.

| RAM | Functions |
|---|---|
| 0 | Dynamic RAM mode: During the DRAM refresh period, the ACRTC outputs the 8 bit refresh address on MAD. Note that the particular MAD lines used for the DRAM refresh address are determined by the Graphic Address Increment (GAI) mode. The DRAM refresh address is decremented by 1 every refresh cycle. |
| 1 | Static RAM mode: No DRAM refresh address is placed on MAD. Drawing is performed during the DRAM refresh period (HSYNC̄ low - except the attribute output period) regardless of the Access Priority (ACP) definition. |

---
*(source page 73)*

○ Graphic Address Increment mode (GAI: bit 6 - bit 4)

As described earlier, using the Gaphic Bit Mode field in the Command Control Register (GBM in CCR), the number of physical frame buffer bits associated with a logical pixel can be selected as 1, 2, 4, 8 or 16.

However, when the frame buffer organization is fixed as 16 bit words, if 1 bit per pixel GBM is specified, each word contains 16 logical pixels. If 4 bits per pixel GBM is specified, each word contains only 4 logical pixels. thus, a '16 color' display compared to a monochrome display will require a 2CLK input which is 4 times faster to achieve the same logical pixel resolution.

A simple technique for solving this problem is to increase the number of frame buffer bits output for each display cycle. In the above example, if 4 words (64 bits) of frame buffer are accessed each display refresh cycle, the 'color' system 2CLK input is the same frequency as the 'monochrome' system which has equivalent logical pixel resolution.

GAI accomodates this technique and other special cases by modifying the frame buffer address increment used for each successive graphic screen display access.

GAI allows the display address increment to be 1, 2, 4 or 8 words (16-128 bits), 0 increment (display constant pattern) and increment every two display cycles (used when superimposing screens character and graphic screens).

GAI applies only to graphic screen display accesses. Graphic screen drawing accesses and character screen accesses used a fixed increment of 1 word.

| GAI 6 | GAI 5 | GAI 4 | Functions |
|---|---|---|---|
| 0 | 0 | 0 | Graphic screen display address incremented by 1 every display cycle. |
| 0 | 0 | 1 | Graphic screen display address incremented by 2 every display cycle. |
| 0 | 1 | 0 | Graphic screen display address incremented by 4 every display cycle. |
| 0 | 1 | 1 | Graphic screen display address incremented by 8 every display cycle. |
| 1 | 0 | 0 | Graphic screen display address not incremented. |
| 1 | 0 | 1 | Graphic screen display address not incremented. |
| 1 | 1 | 0 | Graphic screen display address not incremented. |
| 1 | 1 | 1 | Graphic screen display address incremented by 1 every two display cycles. |

---
*(source page 74)*

○ Access Mode (ACM: bit 3 - bit 2)

The ACRTC provides three frame buffer access modes — Single, Interleaved and Superimposed.

| ACM 3 | ACM 2 | Functions |
|---|---|---|
| 0 | x | Single Access Mode: The frame buffer is accessed once every display cycle. The Window screen access has higher priority than overlapped Background screen accesses. When ACP = 0 (display priority mode), drawing is not performed during the display period. |
| 1 | 0 | Interleaved Access Mode (Dual Access Mode 0): The frame buffer is accessed twice every display cycle. Display and drawing cycles are interleaved during each phase of the display cycle. Even if ACP = 0 (Display priority mode), 'flashless' drawing will occur during display period. The Window screen has highest priority as in Single Access Mode. |
| 1 | 1 | Superimposed Access Mode (Dual Access Mode 1): The frame buffer is accessed twice every display cycle. The first phase accesses the Background screen, the second phase accesses the Window screen. In this case the Background and Window screens have equal priority, and are superimposed. Drawing is performed during the second phase in which the Window screen is not being displayed even when ACP = 0. |

x = Don't care

Note: In Interleaved and Superimposed access modes the horizontal display width of the Background screen and the Window screen must be even. Also, for these modes, the relation between the starting position of the horizontal display on the Background screen and the starting position of the horizontal display on the Window screen must be even number/even number or odd number/odd number.

○ Raster Scan Mode (RSM: bit 1 - bit 0)

RSM selects the ACRTC raster scan mode.

| RSM 1 | RSM 0 | Functions |
|---|---|---|
| 0 | 0 | Non-Interlace Mode |
| 0 | 1 | Non-Interlace Mode |
| 1 | 0 | Interlace Sync Mode |
| 1 | 1 | Interlace Sync & Video Mode |

---
*(source page 75)*

## 5.7 Display Control Register (DCR: r06-r07)

**Figure 5.7 Display Control Register (DCR)**

A 16-bit register diagram, divided into "High-order (r06)" (bits 15-8) and "Low-order (r07)" (bits 7-0). Bit labels: bit 15 DSP, bit 14 SE1, bits 13-12 SE0, bits 11-10 SE2, bits 9-8 SE3, bits 7-0 ATR. Callout lines lead to full names:

- Bit 15: DISP Signal Control (DSP)
- Bit 14: Split Enable 1 (Base) (SE1)
- Bits 13-12: Split Enable 0 (Upper) (SE0)
- Bits 11-10: Split Enable 2 (Lower) (SE2)
- Bits 9-8: Split Enable 3 (Window) (SE3)
- Bits 7-0: Attribute Control (ATR)

DCR controls ACRTC screen organization and 8 bits of user defined video attributes.

Logically, the ACRTC has a Background screen (Upper, Base and Lower split screens) and a Window screen. When overlapping occurs, either the Window screen has priority (Single Access Mode, Interleaved Access Mode) or the Window screen and the Background screen have equal priority (Superimposed Access Mode).

DCR allows screens to be enabled, disabled and blanked. If the Upper, Lower and Window screens are disabled, they need not be defined. The Base screen must always be defined. When screens are blanked (DISP̄ timing output held inactive high), the display address is also inhibited. The ACRTC uses the idle frame buffer bus (MAD0-15 and MA16-19) for drawing operations.

---
*(source page 76)*

○ DISP̄ Signal Control (DSP: bit 15)

DSP defines the output mode of the DISP1̄ and DISP2̄ display timing signals.

| DSP | Functions |
|---|---|
| 0 | DISP1̄ is driven active low during the display period of the Background screen (combined horizontal and vertical display). DISP2̄ is controlled similarly for the Window screen. |
| 1 | DISP1̄ is driven active low during the horizontal display of both the Background and Window screens. DISP2̄ is driven active low during the vertical display period of both the Background and Window screens. Thus, DISP2̄ is high during vertical retrace. This allows another device which shares direct access to the frame buffer with the ACRTC to determine when the frame buffer is available. |

○ Split Enable 1 (SE1: bit 14)

SE1 allows the Base screen (screen 1) to be blanked. Drawing can occur when the Base screen is blanked since frame buffer display access is suppressed. Note that the Base screen parameters must be defined, even if the Base screen is always blanked.

| SE1 | Functions |
|---|---|
| 0 | The ACRTC inhibits the display enable timing (DISP1̄ and/or DISP2̄) and display address outputs associated with the Base screen. The area of the Base screen, though blanked, remains on the CRT screen. |
| 1 | The ACRTC outputs display enable timing and display addresses for the Base screen. |

---
*(source page 77)*

○ Split Enable 0 (SE0: bit 13 - bit 12)

SE0 allows the Upper split screen (screen 0) to be enabled, disabled and blanked. If always disabled, the Upper screen parameters need not be defined. When the Upper screen is blanked, drawing may occur since frame buffer display access is suppressed.

| SE0 13 | SE0 12 | Functions |
|---|---|---|
| 0 | x | The ACRTC disables the Upper screen. Therefore, the Background screen contains two parts maximum — the Base and Lower screens. The Base screen is moved upward by the number of rasters in the disabled Upper screen. |
| 1 | 0 | The display enable timing outputs and display address outputs are inhibited for the Upper screen. The area of the Upper screen, though blanked, remains on the CRT screen. |
| 1 | 1 | The ACRTC outputs display enable timing and display addresses for the Upper screen. |

x = Don't care

○ Split Enable 2 (SE2: bit 11 - bit 10)

SE2 allows the Lower split screen (screen 2) to be enabled, disabled and blanked. If always disabled, the Lower screen parameters need not be defined. When the Lower screen is blanked, drawing may occur since frame buffer display access is suppressed.

| SE2 11 | SE2 10 | Functions |
|---|---|---|
| 0 | x | The ACRTC disables the Lower screen. Therefore, the Background screen contains two parts maximum — the Base and Upper screens. |
| 1 | 0 | The display enable timing and display address outputs are inhibited for the Lower screen. The area of the Lower screen, though blanked, remains on the CRT screen. |
| 1 | 1 | The ACRTC outputs display enable timing and display addresses for the Lower screen. |

x = Don't care

---
*(source page 78)*

○ Split Enable 3 (SE3: bit 9 - bit 8)

SE3 allows enabling, disabling and blanking of the Window screen (screen 3). When disabled or blanked, the overlapped Background screens are displayed.

| SE3 9 | SE3 8 | Functions |
|---|---|---|
| 0 | x | The ACRTC disables the Window screen and overlapped Background screens (as defined by SE0, SE1 and SE2) are displayed. If always disabled, the Window screen parameters need not be defined. For Superimposed access mode the second (Window) phase of the display cycle is not used. The ACRTC may execute drawing operations during this second phase. |
| 1 | 0 | The ACRTC disables the display enable timing and display address outputs for the Window screen. The area of the Window screen, though blanked, remains on the CRT. However, Window screen parameters must be defined. For superimposed access modes, the overlapped Background screens are displayed. For Single and Interleaved access modes, the ACRTC may perform drawing during the display time for the blanked Window screen. |
| 1 | 1 | The ACRTC outputs the display enable timing and display addresses for the Window screen. |

x = Don't care

○ Attribute Control (ATR: bit 7 - bit 0)

These 8 bits can be freely programmed as user defined video attributes. These bits are output on MAD7 — MAD0 prior to the rising edge of HSYNC̄.

When programmed dynamically, ATR allows video attributes to be controlled on a raster by raster basis.

---
*(source page 79)*

## 5.8 Timing Control RAM (r80-9F)

These registers are used to define the overall screen and CRT timing signal characteristics, and parameters associated with the Base, Upper, Lower and Window screens.

Raster Count Register (RCR)
Horizontal Sync Register (HSR)
Horizontal Display Register (HDR)
Horizontal Window Register (HWR)
Vertical Sync Register (VSR)
Vertical Display Register (VDR)
Split Screen Width Register (SSW)
Vertical Window Display Register (VWR)
Blink Control Register (BCR)
Graphic Cursor Register (GCR)

---
*(source page 80)*

### 5.8.1 Raster Count Register (RCR: r80-r81)

**Figure 5.8 Raster Count Register (RCR)**

A 16-bit register diagram, divided into "High-order (r80)" (bits 15-8) and "Low-order (r81)" (bits 7-0). Bits 15-12 are shaded/hatched (unused). The remaining field, bits 11-0, is labeled "RC" and captioned "Raster Count".

RCR is a read-only register which contains the number of the raster currently being scanned on the CRT. Note that the initial RCR value after hardware RES̄ is undefined. If RCR read operation is desired, the HSW (Horizontal Sync Width) should be set greater than or equal to 3. RCR should only be read when HSYNC̄ is high.

The high order 4 bits of RCR are always 0.

RCR is updated depending on the ACRTC raster scan modes as shown.

| Scan Mode | Functions |
|---|---|
| Non-Interlace | RCR starts counting at 0 and increments by 1 sequentially. |
| Interlace Sync | RCR starts counting at 0 and increments by 1 sequentially in both the even and odd fields. Because a dummy raster is added to the even field, the maximum raster number for the even field is one greater than that for the odd field. |
| Interlace Sync and Video | RCR starts counting at 0 in the even field and at 1 in the odd field, and increments by 2 sequentially in both fields. The even field always has even raster numbers and the odd field always has odd raster numbers. A dummy raster is added to the even field as in the Interlace Sync Mode. |

---
*(source page 81)*

### 5.8.2 Horizontal Sync Register (HSR: r82-r83)

**Figure 5.9 Horizontal Sync Register (HSR)**

A 16-bit register diagram, divided into "High-order (r82)" (bits 15-8) and "Low-order (r83)" (bits 7-0). Bits 15-8 are labeled "HC". Bits 7-5 are shaded/hatched (unused). Bits 4-0 are labeled "HSW". Callouts: bits 15-8 → "Horizontal Cycle"; bits 4-0 → "Horizontal Sync Width".

HSR defines the Horizontal Cycle (HC) and Horizontal Sync Width (HSW).

○ Horizontal Cycle (HC: bit 15 - bit 8)

HC specifies the horizontal scan time (including the horizontal retrace period) in units of memory cycles. HC is set depending on the specifications of the CRT display device. If H memory cycles are to be specified, HC should be set to H-1. When using interlaced scan modes, H should be an even number.

| HC (MSB→LSB, 8 bits) | Display (Memory cycle No.) |
|---|---|
| 00000000 | 1 |
| 00000001 | 2 |
| ⋮ | ⋮ |
| 11111110 | 255 |
| 11111111 | 256 |

---
*(source page 82)*

○ Horizontal Sync Width (HSW: bit 4 - bit 0)

HSW specifies the HSYNC̄ active low time in units of memory cycles. HSW is set depending on the specifications of the CRT display device. Valid values for HSW are 2 - 31. When using the RCR register, HSW must be 3 or greater. When the ACRTC DRAM refresh feature is used, DRAM refresh timing should be factored into the choice of HSW.

| HSW (MSB→LSB, 5 bits) | Pulse width (Memory cycle No.) |
|---|---|
| 00000 | *1 |
| 00001 | *2 |
| 00010 | 2 |
| 00011 | 3 |
| ⋮ | ⋮ |
| 11110 | 30 |
| 11111 | 31 |

*1 Not used.
*2 Two memory cycles are assummed.

---
*(source page 83)*

### 5.8.3 Horizontal Display Register (HDR: r84-r85)
### Horizontal Window Display Register (HWR: r92-r93)

**Figure 5.10 Horizontal Display Register (HDR)**

A 16-bit register diagram, divided into "High-order (r84)" (bits 15-8, labeled "HDS") and "Low-order (r85)" (bits 7-0, labeled "HDW"). Callouts: HDS → "Horizontal Display Start"; HDW → "Horizontal Display Width".

**Figure 5.11 Horizontal Window Display Register (HWR)**

A 16-bit register diagram, divided into "High-order (r92)" (bits 15-8, labeled "HWS") and "Low-order (r93)" (bits 7-0, labeled "HWW"). Callouts: HWS → "Horizontal Window Start"; HWW → "Horizontal Window Width".

HDR specifies the horizontal display start position and horizontal display width in units of memory cycles.

HWR specifies the horizontal Window start position and horizontal Window width in units of memory cycles.

---
*(source page 84)*

○ Horizontal Display Start (HDS: r84)

HDS defines the interval between the rising edge of HSYNC̄ (Horizontal Front Porch) and the horizontal display starting point in units of memory cycles. If the Horizontal Display Start is HS memory cycles, HDS should be set to HS-1.

○ Horizontal Window Start (HWS: r92)

HWS defines the interval between the rising edge of HSYNC̄ and the horizontal Window display starting point in units of memory cycles. If the Horizontal Window Start is HS memory cycles, HWS should be set to HS-1.

| HDS/HWS (MSB→LSB, 8 bits) | Display width (Memory cycle No.) |
|---|---|
| 00000000 | 1 |
| 00000001 | 2 |
| ⋮ | ⋮ |
| 11111110 | 255 |
| 11111111 | 256 |

○ Horizontal Display Width (HDW: r85)

HDW defines the display period for one raster in units of memory cycles. If the Horizontal Display Width is HW memory cycles, HDW should be set to HW-1.

○ Horizontal Window Width (HWW: r93)

HWW defines the Window display period for one raster in units of memory cycles. If the Horizontal Window Width is HW memory cycles, HWW should be set to HW-1.

| HDW/HWW (MSB→LSB, 8 bits) | Display width (Memory cycle No.) |
|---|---|
| 00000000 | 1 |
| 00000001 | 2 |
| ⋮ | ⋮ |
| 11111110 | 255 |
| 11111111 | 256 |

---
*(source page 85)*

### 5.8.4 Vertical Sync Register (VSR: r86-r87)

**Figure 5.12 Vertical Sync Register (VSR)**

A 16-bit register diagram, divided into "High-order (r86)" (bits 15-8) and "Low-order (r87)" (bits 7-0). Bits 15-12 are shaded/hatched (unused). The remaining field, bits 11-0, is labeled "VC" and captioned "Vertical Cycle".

VSR defines the period of the vertical scan cycle in units of rasters.

○ Vertical Cycle (VC: bit 11 - bit 0)

VC defines the vertical scan cycle period (including vertical retrace) in units of rasters. VC is set depending on the specifications of the CRT display device. The way VC is programmed depends on the ACRTC raster scan mode. VC should be programmed with a non-zero value.

· Non-Interlace Mode
When the number of rasters in one frame is V, VC is set to V.

· Interlace Sync Mode
When the number of rasters in one field (even or odd) is V, VC is set to V. The total rasters in one frame is 2V+1 due to one dummy raster operation.

· Interlace Sync & Video Mode
When the number of rasters in one frame (even field + odd field + dummy raster) is V, VC is set to V.

---
*(source page 86)*

| VC (MSB→LSB, 12 bits) | Vertical cycle (Number of rasters) |
|---|---|
| 000000000000 | * |
| 000000000001 | 1 |
| 000000000010 | 2 |
| ⋮ | ⋮ |
| 111111111110 | 4094 |
| 111111111111 | 4095 |

* VC = 0 cannot be used.

### 5.8.5 Vertical Display Register (VDR: r88-r89)

**Figure 5.13 Vertical Display Register (VDR)**

A 16-bit register diagram, divided into "High-order (r88)" (bits 15-8, labeled "VDS") and "Low-order (r89)" (bits 7-0). Within the low-order byte, bits 7-5 are shaded/hatched (unused) and bits 4-0 are labeled "VSW". Callouts: VDS → "Vertical Display Start"; VSW → "Vertical Sync Width".

VDR defines vertical sync width (VSYNC̄ low period) and vertical display start and width in units of rasters.

---
*(source page 87)*

○ Vertical Sync Width (VSW: r89 bit 4 - bit 0)

VSW defines VSYNC̄ low pulse width in units of rasters. VSW is set depending on the CRT display device specification. VSW should be set to a non-zero value.

| VSW (MSB→LSB, 5 bits) | Pulse width (Number of raster) |
|---|---|
| 00000 | * |
| 00001 | 1 |
| 00010 | 2 |
| ⋮ | ⋮ |
| 11110 | 30 |
| 11111 | 31 |

* VSW = 0 cannot be used.

---
*(source page 88)*

○ Vertical Display Start (VDS: r88)

VDS defines the period from the rising edge of VSYNC̄ to the vertical display start position in units of rasters. If the vertical display start position is the VS raster, VDS is set to VS-1. The way to program VDS depends on ACRTC raster scan modes as described for VSR (r86-r87).

| VDS (MSB→LSB, 8 bits) | Display start (Number of rasters) |
|---|---|
| 00000000 | 1 |
| 00000001 | 2 |
| ⋮ | ⋮ |
| 11111110 | 255 |
| 11111111 | 256 |

---
*(source page 89)*

### 5.8.6 Vertical Window Display Register (VWR: r94-r97)

**Figure 5.14 Vertical Window Display Register (VWR)**

Two 16-bit register diagrams. The first, divided into "High-order (r94)" (bits 15-8, bits 15-12 shaded/hatched) and "Low-order (r95)" (bits 7-0); the combined field bits 11-0 is labeled "VWS" and captioned "Vertical Window Start". The second, divided into "High-order (r96)" (bits 15-8, bits 15-12 shaded/hatched) and "Low-order (r97)" (bits 7-0); the combined field bits 11-0 is labeled "VWW" and captioned "Vertical Window Width".

VWR is a read/write register that defines the vertical Window start position and width in units of rasters.

○ Vertical Window Start (VWS: r94-r95)

VWS defines the period from the rising edge of VSYNC̄ to the vertical Window start position in units of rasters. When the vertical Window start position is the VS raster, VWS is set to VS-1. Note that VWS must be greater than or equal to VDS.

| VWS (MSB→LSB, 12 bits) | Display start position (Number of rasters) |
|---|---|
| 000000000000 | 1 |
| 000000000001 | 2 |
| ⋮ | ⋮ |
| 111111111110 | 4095 |
| 111111111111 | 4096 |

---
*(source page 90)*

○ Vertical Window Width (VWW: r96-r97)

VWW defines the vertical display period of the Window screen in units of rasters. When the vertical window width is VW rasters, VWW is set to VW.

| VWW (MSB→LSB, 12 bits) | Display width (Number of rasters) |
|---|---|
| 000000000000 | * |
| 000000000001 | 1 |
| 000000000010 | 2 |
| ⋮ | ⋮ |
| 111111111110 | 4094 |
| 111111111111 | 4095 |

* VWW = 0 cannot be used.

### 5.8.7 Split Screen Width Register (SSW: r8A-r8F)

**Figure 5.15 Split Screen Width Register (SSW)**

Three 16-bit register diagrams, each divided into a High-order byte (bits 15-8, with bits 15-12 shaded/hatched) and Low-order byte (bits 7-0):
- High-order (r8A) / Low-order (r8B): combined field bits 11-0 labeled "SP1", captioned "Base Screen Width".
- High-order (r8C) / Low-order (r8D): combined field bits 11-0 labeled "SP0", captioned "Upper Screen Width".
- High-order (r8E) / Low-order (r8F): combined field bits 11-0 labeled "SP2", captioned "Lower Screen Width".

SSW defines the vertical width of the Upper (split screen 0), Base (split screen 1) and Lower (split screen 2) screens.

---
*(source page 91)*

○ Split Screen Width (SP0: r8C-r8D bit 11 - bit 0)
　　　　　　　　　(SP1: r8A-r8B bit 11 - bit 0)
　　　　　　　　　(SP2: r8E-r8F bit 11 - bit 0)

SP0, SP1 and SP2 define the vertical display period of the Upper, Base and Lower screens respectively in units of rasters. If the vertical screen width is SW rasters, SP0/SP1/SP2 are set to SW.

| SP0/SP1/SP2 (MSB→LSB, 12 bits) | Display width (Number of rasters) |
|---|---|
| 000000000000 | * |
| 000000000001 | 1 |
| 000000000010 | 2 |
| ⋮ | ⋮ |
| 111111111110 | 4094 |
| 111111111111 | 4095 |

* SP0/SP1/SP2 = 0 cannot be used.

### 5.8.8 Blink Control Register (BCR: r90-r91)

**Figure 5.16 Blink Control Register (BCR)**

A 16-bit register diagram, divided into "High-order (r90)" (bits 15-8) and "Low-order (r91)" (bits 7-0). Field labels: bits 15-12 BON1, bits 11-8 BOFF1, bits 7-4 BON2, bits 3-0 BOFF2. Callouts: BON1 → "Blink ON 1"; BOFF1 → "Blink OFF 1"; BON2 → "Blink ON 2"; BOFF2 → "Blink OFF 2".

BCR defines the blink on and off period for the BLINK1 and BLINK2 video attributes. BLINK1 and BLINK2 are output on MA18 and MA19 during each rasters video attribute output cycle.

---
*(source page 92)*

○ Blink ON (BON1: r90 bit 15 - bit 12)
　　　　　　(BON2: r91 bit 7 - bit 4)

BON(1/2) defines the BLINK(1/2) attribute active high (ON) period. The unit is 4 field periods. BLINK(1/2) is always low (OFF) when BON(1/2) = 0 is programmed.

| BON1 15 | BON1 14 | BON1 13 | BON1 12 | Blink "High" level (Field) |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | * |
| 0 | 0 | 0 | 1 | 8 |
| 0 | 0 | 1 | 0 | 12 |
| 0 | 0 | 1 | 1 | 16 |
| 0 | 1 | 0 | 0 | 20 |
| 0 | 1 | 0 | 1 | 24 |
| 0 | 1 | 1 | 0 | 28 |
| 0 | 1 | 1 | 1 | 32 |
| 1 | 0 | 0 | 0 | 36 |
| 1 | 0 | 0 | 1 | 40 |
| 1 | 0 | 1 | 0 | 44 |
| 1 | 0 | 1 | 1 | 48 |
| 1 | 1 | 0 | 0 | 52 |
| 1 | 1 | 0 | 1 | 56 |
| 1 | 1 | 1 | 0 | 60 |
| 1 | 1 | 1 | 1 | 64 |

(BON2, bits 7-6-5-4, has the identical pattern/values as BON1 above.)

* BLINK is always "Low"

---
*(source page 93)*

○ Blink OFF (BOFF1: r90 bit 11 - bit 8)
　　　　　　 (BOFF2: r91 bit 3 - bit 0)

BOFF(1/2) defines the BLINK(1/2) attribute active low (OFF) period. the unit is 4 field periods. BLINK(1/2) is always high (ON) when BON(1/2) ≠ 0 and BOFF(1/2) = 0 are programmed.

| BOFF1 11 | BOFF1 10 | BOFF1 9 | BOFF1 8 | Blink "Low" level (Field) |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | * |
| 0 | 0 | 0 | 1 | 8 |
| 0 | 0 | 1 | 0 | 12 |
| 0 | 0 | 1 | 1 | 16 |
| 0 | 1 | 0 | 0 | 20 |
| 0 | 1 | 0 | 1 | 24 |
| 0 | 1 | 1 | 0 | 28 |
| 0 | 1 | 1 | 1 | 32 |
| 1 | 0 | 0 | 0 | 36 |
| 1 | 0 | 0 | 1 | 40 |
| 1 | 0 | 1 | 0 | 44 |
| 1 | 0 | 1 | 1 | 48 |
| 1 | 1 | 0 | 0 | 52 |
| 1 | 1 | 0 | 1 | 56 |
| 1 | 1 | 1 | 0 | 60 |
| 1 | 1 | 1 | 1 | 64 |

(BOFF2, bits 3-2-1-0, has the identical pattern/values as BOFF1 above.)

* In the case of BON(1/2) ≠ 0, BLINK(1/2) will always become "HIGH" level.

---
*(source page 94)*

### 5.8.9 Graphic Cursor Register (GCR: r98-r9D)

**Figure 5.17 Graphic Cursor Register (GCR)**

Three 16-bit register diagrams:
- High-order (r98) / Low-order (r99): bits 15-8 labeled "CXE" (captioned "Cursor X End"), bits 7-0 labeled "CXS" (captioned "Cursor X Start").
- High-order (r9A) / Low-order (r9B): bits 15-12 shaded/hatched, bits 11-0 labeled "CYS" (captioned "Cursor Y Start").
- High-order (r9C) / Low-order (r9D): bits 15-12 shaded/hatched, bits 11-0 labeled "CYE" (captioned "Cursor Y End").

GCR defines the horizontal and vertical start and end positions for displaying a graphic cursor.

○ Cursor X Start (CXS: r99)

CXS defines the horizontal cursor start position from the falling edge of HSYNC̄ in units of memory cycles.

○ Cursor X End (CXE: r98)

CXE defines the horizontal cursor end position from the falling edge of HSYNC̄ in units of memory cycles.

○ Cursor Y Start (CYS: r9A, r9B bit 11 - bit 0)

CYS defines the vertical cursor start position from the rising edge of VSYNC̄ in units of rasters.

○ Cursor Y End (CYE: r9C, r9D bit 11 - bit 0)

CYE defines the vertical cursor end position from the rising edge of VSYNC̄ in units of rasters.

---
*(source page 95)*

### 5.8.10 ACRTC Working Register (r9E-9F)

Internal ACRTC work area. The host MPU must never access this register.

---
*(source page 96)*

## 5.9 Display Control RAM (rC0-rEF)

The Display Control RAM are registers containing parameters used by the ACRTC address generation logic. There are four sets of Raster Address, Memory Width and Start Address registers providing independent control for each of the four logical screens (Upper, Base, Lower and Window). Also, the Cursor Definition Register contains information for two separate cursors.

Raster Address Registers (RAR0-RAR3)
Memory Width Registers (MWR0-MWR3)
Start Address Registers (SAR0-SAR3)
Block Cursor Register (BCR)
Cursor Definition Register (CDR)
Zoom Factor Register (ZFR)
Light Pen Address Register (LPAR)

---
*(source page 97)*

### 5.9.1 Raster Address Register
(RAR0: rC0-rC1) (RAR1: rC8-rC9)
(RAR2: rD0-rD1) (RAR3: rD8-rD9)

**Figure 5.18 Raster Address Register (RAR)**

A 16-bit register diagram, divided into "High-order" (bits 15-8) and "Low-order" (bits 7-0). Bits 15-13 are shaded/hatched (unused). Bits 12-8 are labeled "LRA" (captioned "Last Raster Address"). Bits 7-5 are shaded/hatched (unused). Bits 4-0 are labeled "FRA" (captioned "First Raster Address").

Raster address register 0: LRA0 (rC0), FRA0 (rC1) — Upper Screen
Raster address register 1: LRA1 (rC8), FRA1 (rC9) — Base Screen
Raster address register 2: LRA2 (rD0), FRA2 (rD1) — Lower Screen
Raster address register 3: LRA3 (rD8), FRA3 (rD9) — Window

RAR specifies the raster addressing per character row (including line spacing) for character screens (CHR = high). RAR0-3 apply to screens 0-3, the Upper, Base, Lower and Window screens respectively.

○ First Raster Address (FRA: bit 4 - bit 0)

FRA determines the first raster line address of the character row, and can be set to any value between 0 and 31.

| FRA 4 | FRA 3 | FRA 2 | FRA 1 | FRA 0 | Raster address |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 0 | 1 | 1 |
| ⋮ | ⋮ | ⋮ | ⋮ | ⋮ | ⋮ |
| 1 | 1 | 1 | 1 | 0 | 30 |
| 1 | 1 | 1 | 1 | 1 | 31 |

---
*(source page 98)*

○ Last Raster Address (LRA: bit 12 - bit 8)

LRA determines the last raster line address of the character row, and can be set to any value between 0 and 31.

| LRA 12 | LRA 11 | LRA 10 | LRA 9 | LRA 8 | Raster address |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 0 | 1 | 1 |
| ⋮ | ⋮ | ⋮ | ⋮ | ⋮ | ⋮ |
| 1 | 1 | 1 | 1 | 0 | 30 |
| 1 | 1 | 1 | 1 | 1 | 31 |

The number of raster lines per character row is determined by the relation between FRA and LRA and also depends on the raster scan mode. In the following examples, FRA (=3) represents the first raster address in the even field.

Note that the relation between FRA and LRA is not restricted. FRA can be less, equal or greater than LRA as shown below. In this example, non-interlace mode is used.

---
*(source page 99)*

**Figure (raster address examples)**

i) Non-interlace mode: rasters 03,04,05,06,07,08 scanned sequentially. FRA:03, LRA:08, Number of rasters:6.

ii) Interlace sync mode: Even field rasters 03,04,05,06,07,08 and Odd field rasters (shown offset half a line, dashed) 03,04,05,06,07,08 — both fields scan the same FRA:03-LRA:08 range. Number of rasters:12 (6 per field × 2 fields).

iii) Interlace sync & Video mode: Even field rasters 03,05,07 (solid) interleaved with Odd field rasters 04,06,08 (dashed). FRA:03, LRA:08, Number of rasters:6 total (raster addresses split between the two fields).

Three additional small diagrams illustrate the FRA/LRA relationship is unrestricted:

- FRA < LRA: rasters 03 (FRA) through 08 (LRA) scanned in ascending order — normal case.
- FRA = LRA: a single raster 10 serves as both FRA and LRA — one-line character row.
- FRA > LRA: rasters wrap from 30 (FRA) through 31, 00, 01, 02, 03 (LRA) — the raster counter wraps around through its maximum value back to a lower LRA, still producing 6 rasters total.

---
*(source page 100)*

### 5.9.2 Memory Width Register
(MWR0: rC2-rC3) (MWR1: rCA-rCB)
(MWR2: rD2-rD3) (MWR3: rDA-rDB)

**Figure 5.19 Memory Width Register (MWR)**

A 16-bit register diagram, divided into "High-order" (bits 15-8) and "Low-order" (bits 7-0). Bit 15 is labeled "CHR" (captioned "Character/Graphic"). Bits 14-12 are shaded/hatched (unused). Bits 11-0 are labeled "MW" (captioned "Memory Width").

Memory Width Register 0: rC2, rC3 — Upper Screen
Memory Width Register 1: rCA, rCB — Base Screen
Memory Width Register 2: rD2, rD3 — Lower Screen
Memory Width Register 3: rDA, rDB — Window Screen

MWR defines the number of physical 16 bit frame buffer words which comprise all logical pixel X addresses for a single Y address. For example, if a screen is defined with 1024 logical pixel range in the X direction (X may very from 0 to 1023), and 4 bits per pixel are assumed, that screens MWR value should be 256.

MWR also determines whether the defined screen is a Character (CHR = high) or Graphic (CHR = low) screen. MWR0-3 apply to screens 0-3, the Upper, Base, Lower and Window screen respectively.

MWR should be greater than or equal to Horizontal Display Width (HDW - r85). MWR must be greater than HDW to perform horizontal smooth scroll. MWR maximum value is 4096.

○ Character/Graphic (CHR: bit 15)

| CHR | Functions |
|---|---|
| 0 | The screen is defined as GRAPHIC |
| 1 | The screen is defined as CHARACTER |

---
*(source page 101)*

○ Memory Width (MW: bit 11 - bit 0)

| MW (MSB→LSB, 12 bits) | Memory width (Number of words) |
|---|---|
| 000000000000 | 0 |
| 000000000001 | 1 |
| ⋮ | ⋮ |
| 111111111110 | 4094 |
| 111111111111 | 4095 |

---
*(source page 102)*

### 5.9.3 Start Address Register
(SAR0: rC4-rC7) (SAR1: rCC-rCF)
(SAR2: rD4-rD7) (SAR3: rDC-rDF)

**Figure 5.20 Start Address Register (SAR)**

Two 16-bit register diagrams:
- High-order/Low-order (first word): bits 15-12 shaded/hatched (unused); bits 11-8 labeled "SDA" (captioned "Start Dot Address"); bits 7-5 shaded/hatched (unused); bits 4-0 labeled "SAH/SRA" (captioned "Start Address High/Start Raster Address").
- High-order/Low-order (second word): all 16 bits (15-0) labeled "SAL" (captioned "Start Address Low").

Start Address Register 0: Upper Screen
Start Address Register 1: Base Screen
Start Address Register 2: Lower Screen
Start Address Register 3: Window Screen

SAR defines the first frame buffer address for each screen. SAR0-3 apply to screens 0-3, the Upper, Base, Lower and Window screens respectively.

Screens defined as Character have a 64K by 16 bit physical address space. Screens defined as Graphic have a 1M by 16 bit physical address space. In either case, SAR can take on any address. Frame Buffer addresses will 'wraparound' to 0 when the physical address space limit is reached independent of split screen position.

---
*(source page 103)*

○ Start Address Low (SAL: bit 15 - bit 0)

For Character screens, SAL contains the 16 bit start address. For Graphic screens, SAL contains the least significant 16 bits of the 20 bit start address.

○ Start Address High (SAH: bit 3 - bit 0)
Start Raster Address (SRA: bit 4 - bit 0)

For Character screens, SRA provides the 5 bit (0-31) start raster address.

i) Character Screen

(Diagram: a vertical raster-address ladder illustrating how SRA relates to the character row's FRA/LRA range — one example shows SRA=04 aligned with a sequence 04,05,06,07 where 07 is LRA and 02 is FRA (SRA within the row); a second stacked example shows the same pattern repeated: 03,04,05,06,07 (LRA), 02 (FRA), illustrating that SRA can take any value within or outside the FRA-LRA range to select the starting raster line for vertical smooth scroll.)

For Graphic screens, SAH provides the most significant 4 bits of the 20 bit start address.

ii) Graphic Screen

A 20-bit field diagram: bits 19 down to 15 labeled "SAH", bits 14 (shown as continuing from 15) down to 0 labeled "SAL" — i.e. SAH occupies bits 19-16(15) and SAL occupies the remaining lower bits, together forming the 20-bit start address.

Increment or decrement of SRA provides vertical smooth scroll with no additional external hardware.

---
*(source page 104)*

○ Start Dot Address (SDA: bit 11 - bit 8)

SDA is used to define a start dot horizontal offset (0-15). the contents of SDA are output on HSD0-3 (MAD8-11) during the video attribute output cycle of each horizontal scan. External circuitry which controls the parallel-serial converter (shift register) load and clock based on SDA and the corresponding HSD outputs allows horizontal smooth scroll for both Character and Graphic screens.

### 5.9.4 Block Cursor Register (BCUR: rE0-rE7)

**Figure 5.21 Block Cursor Register (BCUR)**

Two 16-bit register diagrams:
- First: all 16 bits (15-0) labeled "BCA" (captioned "Character Cursor Address").
- Second: bits 15-13 labeled "BCW" (captioned "Block Cursor Width"); bits 12-8 labeled "BCSR" (captioned "Block Cursor Start Raster"); bits 7-5 shaded/hatched (unused); bits 4-0 labeled "BCER" (captioned "Block Cursor End Raster").

Block Cursor Register 1 (BCUR1): rE0, rE1, rE2, rE3
Block Cursor Register 2 (BCUR2): rE4, rE5, rE6, rE7

BCUR defines the block cursor location (frame buffer physical memory address), start and end raster and block cursor length for two independent cursors. Depending on cursor mode, the ACRTC CUD1̄ and CUD2̄ lines can support the simultaneous display of both block cursors.

Should two (or more) screens be defined to contain the same frame buffer memory address, if the block cursor is located at that address, it will be displayed on both screens.

○ Block Cursor Address (BCA1: rE2-rE3) (BCA2: rE6-rE7)

BCA defines the 16 bit address for the block cursor. Note that the block cursor is only enabled for Character screens (CHR = high).

---
*(source page 105)*

○ Block Cursor Start Raster (BCSR: bit 12 - bit 8)

BCSR determines the 5 bit block cursor start raster address (0-31).

○ Block Cursor Width (BCW: bit 15 - bit 13)

BCW defines the block cursor width (1-8) in units of memory cycles.

| BCW 15 | BCW 14 | BCW 13 | Cursor width (Memory cycle) |
|---|---|---|---|
| 0 | 0 | 0 | 1 |
| 0 | 0 | 1 | 2 |
| ⋮ | ⋮ | ⋮ | ⋮ |
| 1 | 1 | 0 | 7 |
| 1 | 1 | 1 | 8 |

| BCSR 12 | BCSR 11 | BCSR 10 | BCSR 9 | BCSR 8 | Raster address |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 0 | 1 | 1 |
| ⋮ | ⋮ | ⋮ | ⋮ | ⋮ | ⋮ |
| 1 | 1 | 1 | 1 | 0 | 30 |
| 1 | 1 | 1 | 1 | 1 | 31 |

○ Block Cursor End Raster (BCER: bit 4 - bit 0)

BCER determines the 5 bit block cursor end raster address (0-31).

| BCER 4 | BCER 3 | BCER 2 | BCER 1 | BCER 0 | Raster address |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 0 | 1 | 1 |
| ⋮ | ⋮ | ⋮ | ⋮ | ⋮ | ⋮ |
| 1 | 1 | 1 | 1 | 0 | 30 |
| 1 | 1 | 1 | 1 | 1 | 31 |

---
*(source page 106)*

Based on FRA, LRA, BCSR and BCER, the block cursor can take on a number of different configurations as shown below.

**FRA ≤ LRA (FRA:02, LRA:08)**

Three raster-ladder diagrams (rasters 02 through 08), each showing which rasters are highlighted (marked with dots) as the block cursor:
- BCSR < BCER: BCSR:04, BCER:07 — rasters 04-07 highlighted (a contiguous block within the FRA-LRA range).
- BCSR = BCER: BCSR:07, BCER:07 — only raster 07 highlighted (a single-raster cursor, i.e. an underline cursor).
- BCSR > BCER: BCSR:07, BCER:04 — rasters 02-04 and 07-08 highlighted (the cursor wraps: everything outside the BCER-BCSR gap is highlighted, producing a split/double-bar appearance).

**FRA > LRA (FRA:30, LRA:04)**

Two further sets of three raster-ladder diagrams (rasters 30,31,00,01,02,03,04, wrapping through the raster counter's maximum):

First set:
- BCSR < BCER: BCSR:01, BCER:03 — rasters 01-03 highlighted.
- BCSR = BCER: BCSR:03, BCER:03 — only raster 03 highlighted.
- BCSR > BCER: BCSR:03, BCER:01 — rasters 30-01 and 03-04 highlighted (wraps around).

Second set:
- BCSR < BCER: BCSR:02, BCER:31 — rasters 30-31 and 00-02 highlighted.
- BCSR = BCER: BCSR:31, BCER:31 — only raster 31 highlighted.
- BCSR > BCER: BCSR:31, BCER:02 — rasters 30-31, 00-02 and 04 highlighted (i.e. all except the small gap between BCER and BCSR).

---
*(source page 107)*

### 5.9.5 Cursor Definition Register (CDR: rE8-rE9)

**Figure 5.22 Cursor Definition Register**

A 16-bit register diagram, divided into "High-order (rE8)" (bits 15-8) and "Low-order (rE9)" (bits 7-0). Bit labels: bits 15-14 CM, bits 13-11 CON1, bits 10-8 COFF1, bits 7-6 shaded/hatched (unused), bits 5-3 CON2, bits 2-0 COFF2. Callouts: CM → "Cursor Mode"; CON1 → "Cursor On1"; COFF1 → "Cursor Off1"; CON2 → "Cursor On2"; COFF2 → "Cursor Off2".

CDR defines the cursor types and the way in which the CUD1̄ and CUD2̄ outputs are controlled. Depending on CDR, up to three cursors may be simultaneously displayed. Cursor types are defined as follows.

BLOCK — The standard 'block' type (including underline) cursor typically used on alphanumeric displays.

GRAPHIC — The ACRTC may generate a rectangular cursor area of arbitrary X and Y dimension. Normally, this is used to enable an external cursor bit map circuit. In this case, the cursor may take on any user defined graphic shape.

CROSSHAIR — The ACRTC can display a crosshair cursor. The X and Y (horizontal and vertical) dimensions are independently programmable.

---
*(source page 108)*

○ Cursor Mode (CM: rE8 bit 15 - bit 14)

CM defines the type of cursor(s) to be displayed and the way in which the CUD1̄ and CUD2̄ outputs are interpreted.

| CM 15 | CM 14 | Functions |
|---|---|---|
| 0 | x | Block Cursor Mode: Block cursor 1 (defined in BCR1) is output on CUD1̄. Block cursor 2 (defined in BCR2) is output on CUD2̄. The Graphic cursor (defined in GCR) is not used. |
| 1 | 0 | Graphic Cursor Mode: Graphic Cursor (GCR) is output on CUD1̄. Block cursor 1 and 2 are combined and output on CUD2̄. |
| 1 | 1 | Crosshair Cursor Mode: The horizontal element is output on CUD1̄. The vertical element is output on CUD2̄. The Block cursor (BCR) is not used. |

x = Don't care.

---
*(source page 109)*

○ Cursor ON (CON1: rE8 bit 13 - bit 11)
　　　　　　 (CON2: rE9 bit 5 - bit 3)
Cursor OFF (COFF1: rE8 bit 10 - bit 8)
　　　　　　 (COFF2: rE9 bit 2 - bit 0)

CON and COFF determine the cursor blink timing. CON1/COFF1 apply to CUD1̄ and CON2/COFF2 apply to CUD2̄. The unit time is 4 field periods. In Crosshair Cursor Mode, CON1/COFF1 is used for blink timing and CON2/COFF2 are not used.

| CON1 13 | CON1 12 | CON1 11 | Blink "High" level (Field period) |
|---|---|---|---|
| 0 | 0 | 0 | * |
| 0 | 0 | 1 | 8 |
| 0 | 1 | 0 | 12 |
| 0 | 1 | 1 | 16 |
| 1 | 0 | 0 | 20 |
| 1 | 0 | 1 | 24 |
| 1 | 1 | 0 | 28 |
| 1 | 1 | 1 | 32 |

(CON2, bits 5-4-3, has the identical pattern/values as CON1 above.)

* Cursor is output at "Low" level.

| COFF1 10 | COFF1 9 | COFF1 8 | Blink "Low" level (Field period) |
|---|---|---|---|
| 0 | 0 | 0 | * |
| 0 | 0 | 1 | 8 |
| 0 | 1 | 0 | 12 |
| 0 | 1 | 1 | 16 |
| 1 | 0 | 0 | 20 |
| 1 | 0 | 1 | 24 |
| 1 | 1 | 0 | 28 |
| 1 | 1 | 1 | 32 |

(COFF2, bits 2-1-0, has the identical pattern/values as COFF1 above.)

* If "CON=000" is set, cursor is output at "High" level.

---
*(source page 110)*

### 5.9.6 Zoom Factor Register (ZFR: rEA)

**Figure 5.23 Zoom Factor Register (ZFR)**

A 16-bit register diagram, divided into "High-order (rEA)" (bits 15-8) and "Low-order (rEB)" (bits 7-0, all shaded/hatched — unused). Bits 15-12 labeled "HZF" (captioned "Horizontal Zoom Factor"); bits 11-8 labeled "VZF" (captioned "Vertical Zoom Factor").

ZFR determines the horizontal (memory cycle) and vertical (raster) multipliers (1 to 16) for zooming up. Zooming can only be applied to the Base screen. HZF and VZF should be set to 0 for no-zoom, and $F for 16 times zoom.

---
*(source page 111)*

○ Horizontal Zoom Factor (HZF: bit 15 - bit 12)

HZF defines the horizontal zoom factor in units of memory cycles. The ACRTC will output a same display address by HZF times. HZF is output as video attributes on MAD12-15 lines for use by an external circuit which controls shift clock timing.

| HZF 15 | HZF 14 | HZF 13 | HZF 12 | Factor of zooming up in the horizontal director (Magnitude) |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 |
| 0 | 0 | 0 | 1 | 2 |
| ⋮ | ⋮ | ⋮ | ⋮ | ⋮ |
| 1 | 1 | 1 | 0 | 15 |
| 1 | 1 | 1 | 1 | 16 |

○ Vertical Zoom Factor (VZF: bit 11 - bit 8)

VZF defines the vertical zoom factor. The ACRTC performs the vertical zoom by modifying its frame buffer address (Graphic screens) or raster address (Character screens) so that multiples of the same raster data are displayed.

| VZF 11 | VZF 10 | VZF 9 | VZF 8 | Factor of zooming up in the vertical director (Magnitude) |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 |
| 0 | 0 | 0 | 1 | 2 |
| ⋮ | ⋮ | ⋮ | ⋮ | ⋮ |
| 1 | 1 | 1 | 0 | 15 |
| 1 | 1 | 1 | 1 | 16 |

---
*(source page 112)*

### 5.9.7 Light Pen Address Register (LPAR: rEC-rEF)

**Figure 5.24 Light Pen Address Register (LPAR)**

Two 16-bit register diagrams:
- High-order (rEC) / Low-order (rED): bits 15-8 shaded/hatched (unused); bit 7 labeled "CHR" (captioned "Character"); bits 6-4 shaded/hatched (unused); bits 3-0 labeled "LPAH" (captioned "Light Pen Address 'High'").
- High-order (rEE) / Low-order (rEF): all 16 bits labeled "LPAL" (captioned "Light Pen Address 'Low'").

LPAR is a read only register. When the ACRTC LPSTB input is asserted, the current display address is latched into LPAR. The value in LPAR will differ from the actual display address under the light pen depending on various hardware delay times. Thus, the LPAR value should be adjusted by MPU software depending on system configuration. In Superimposed access mode, light pen strobes which occur within a superimposed Window/Background display cause the Background address to be latched.

○ Character/Graphic (CHR: rED bit 7)

CHR indicates whether the latched display address corresponds to a screen defined as Character or Graphic.

| CHR | Functions |
|---|---|
| 0 | LPAR contains Graphic screen address |
| 1 | LPAR contains Character screen address |

○ Light Pen Address High (LPAH: rED bit 3 - bit 0)

LPAH is only valid if CHR = 0 and contains the most significant 4 bits of the 20 bit Graphic screen display address.

○ Light Pen Address Low (LPAL: rEE-rEF)

If CHR = 0, LPAL contains the least significant 16 bits of the 20 bit Graphic screen display address. If CHR = 1, LPAL contains the 16 bit Character screen display address.

---
*(source page 113)*

## 5.10 Drawing Control Registers

The ACRTC refers to a number of registers during graphic drawing operations.

a) Pattern RAM

b) Drawing Parameter Registers
　Color 0 Register (CL0)
　Color 1 Register (CL1)
　Color Comparison Register (CCMP)
　Edge Color Register (EDG)
　Mask Register (MASK)
　Pattern RAM Control Register (PRC)
　Area Definition Register (ADR)
　Read/Write Pointer (RWP)
　Drawing Pointer (DP)
　Current Pointer (CP)

The Pattern RAM is accessed using the Read and Write Pattern (RPTN, WPTN) commands. The Drawing Parameter Registers are accessed using the Read and Write Parameter Register (RPR, WPR) commands.

### 5.10.1 Pattern RAM

The ACRTC includes 32 byte pattern RAM. The Pattern RAM is used for pre-defining data for the graphic drawing operations.

A 16 by 16 bit pattern (or 16 sets of 16 by 1 bit) can be stored in the Pattern RAM as a binary representation of screen data. In this case, a two entry color 'palette' corresponding to 0 and 1 data values is defined using the Color 0 (CL0) and Color 1 (CL1) registers.

To store color patterns in the Pattern RAM it is divided into four equal segments of either 4 by 4 bit patterns or 4 sets of 4 by 1 bit patterns. In this case, during drawing the color coded contents of the Pattern RAM are directly written to the frame buffer. The particular segment used is defined by the Pattern RAM Control register (PRC).

When multiple drawing commands use a common pattern, pattern continuity can be achieved by adjusting the pattern scanning pointer.

---
*(source page 114)*

### 5.10.2 Drawing Parameter Registers

**Figure 5.25 Drawing Parameter Registers**

A table listing the Drawing Parameter Register map, columns: Register No., Read/Write, Name of Register, Abbr., and the 16 data bits split into Data(H) [15-8] and Data(L) [7-0].

| Register No. | Read/Write | Name of Register | Abbr. | Data(H) [15-8] | Data(L) [7-0] |
|---|---|---|---|---|---|
| Pr00 | R/W | Color 0 | CL0 | CL0 (spans full 16 bits) | CL0 (cont.) |
| Pr01 | R/W | Color 1 | CL1 | CL1 (spans full 16 bits) | CL1 (cont.) |
| Pr02 | R/W | Color Comparison | CCMP | CCMP (spans full 16 bits) | CCMP (cont.) |
| Pr03 | R/W | Edge Color | EDG | EDG (spans full 16 bits) | EDG (cont.) |
| Pr04 | R/W | Mask | MASK | MASK (spans full 16 bits) | MASK (cont.) |
| Pr05–Pr07 | R/W | Pattern RAM Control | PRC | Pr05: PPY, PZCY, PPX, PZCX; Pr06: PSY, (always 0), PSX, (always 0); Pr07: PSE, PZY, PEX, PZX | (fields span both H/L nibbles as listed) |
| Pr08–Pr0B | R/W | Area Definition** | ADR | Pr08: XMIN; Pr09: YMIN; Pr0A: XMAX; Pr0B: YMAX (each spans full 16 bits) | (cont.) |
| Pr0C–Pr0D | R/W | Read Write Pointer | RWP | Pr0C: DN, (always 0), RWPH; Pr0D: RWPL, (always 0 in low nibble) | (as listed) |
| Pr0E–Pr0F | — | (unnamed) | — | — | — |
| Pr10–Pr11 | R | Drawing Pointer | DP | Pr10: DN, (always 0), DPAH; Pr11: DPAL, DPD | (as listed) |
| Pr12–Pr13 | R | Current Pointer** | CP | Pr12: X; Pr13: Y (each spans full 16 bits) | (cont.) |
| Pr14–Pr15 | — | (unnamed) | — | — | — |

\* R.... Register readable by a Read Parameter Register (RPR) command
W.... Register writable by a Write Parameter Register (WPR) command
—.... Access is not allowed
(hatched).... Always set to "0"
\*\*....... Set binary complements for negative values of X and Y axis.

---
*(source page 126)*

##### 5.10.2.1 Color 0 Register (CL0: Pr00)

**Figure 5.26 Color Register 0 (CL0)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr00 | CL0 (bits 15-0) | | | | | | | | | | | | | | | |

When logical drawing data = 0 in the pattern RAM, the contents of CL0 are stored in the frame buffer.

##### 5.10.2.2 Color 1 Register (CL1: Pr01)

**Figure 5.27 Color Register 1 (CL1)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr01 | CL1 (bits 15-0) | | | | | | | | | | | | | | | |

When logical drawing data = 1 in the pattern RAM, the contents of CL1 are stored in the frame buffer.

---
*(source page 127)*

##### 5.10.2.3 Color Comparison Register (CCMP: Pr02)

**Figure 5.28 Color Comparison Register (CCMP)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr02 | CCMP (bits 15-0) | | | | | | | | | | | | | | | |

CCMP defines a comparison color for use with conditional drawing operations. Conditional drawing applies various logical comparisons between the drawing data and CCMP to determine if drawing should occur.

##### 5.10.2.4 Edge Color Register (EDG: Pr03)

**Figure 5.29 Edge Color Register (EDG)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr03 | EDG (bits 15-0) | | | | | | | | | | | | | | | |

EDG defines the boundary edge color for use by the PAINT command. In one mode, the edge is defined as the color contained in EDG. In another mode, the edge is defined as any color except the color contained in EDG.

---
*(source page 128)*

##### 5.10.2.5 Mask Register (MASK: Pr04)

**Figure 5.30 Mask Register (MASK)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr04 | MASK (bits 15-0) | | | | | | | | | | | | | | | |

When performing data transfer and drawing of the frame buffer, MASK is used to mask bits upon which drawing and other logical operations should not be performed. If MASK bit is 0, the corresponding frame buffer bit is excluded from logic operation.

Note: Only DMOD, MOD, SCLR and SCPY command can use the MASK Register.

---
*(source page 129)*

##### 5.10.2.6 Pattern RAM Control Register (PRC: Pr05 - Pr07)

**Figure 5.31 Pattern RAM Control Register (PRC)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr05 | PPY (bits 15-12) | | | | PZCY (bits 11-8) | | | | PPX (bits 7-4) | | | | PZCS (bits 3-0) | | | |

- PPY = Pattern Point Y
- PZCY = Pattern Zoom Count Y
- PPX = Pattern Point X
- PZCS = Pattern Zoom Count X

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr06 | PSY (bits 15-12) | | | | 0 | 0 | 0 | 0 | PSX (bits 7-4) | | | | 0 | 0 | 0 | 0 |

- PSY = Pattern Start Y
- PSX = Pattern Start X

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr07 | PEY (bits 15-12) | | | | PZY (bits 11-8) | | | | PEX (bits 7-4) | | | | PZX (bits 3-0) | | | |

- PEY = Pattern End Y
- PZY = Pattern Zoom Y
- PEX = Pattern End X
- PZX = Pattern Zoom X

PRC specifies the size of the patterns used for drawing and the start point within the Pattern RAM for the pattern scan. The pattern size can be independently specified in the X and Y dimensions (maximum 16 by 16 bits).

---
*(source page 130)*

- Pattern Start X (PSX: Pr06 bit 7 - bit 4)
  Pattern Start Y (PSY: Pr06 bit 15 - bit 12)
  PSX and PSY specify the pattern scan starting point horizontal and vertical addresses respectively. These should be set to between 0-15 for Color Register indirect drawing and between 0-3 for Pattern RAM direct drawing.

- Pattern End X (PEX: Pr07 bit 7 - bit 4)
  Pattern End Y (PEY: Pr07 bit 15 - bit 8)
  PEX and PEY specify the pattern scan ending point horizontal and vertical addresses respectively. These should be set to between 0-15 for Color Register indirect drawing and between 0-3 for Pattern RAM direct drawing.

- Pattern Zoom X (PZX: Pr07 bit 3 - bit 0)
  Pattern Zoom Y (PZY: Pr07 bit 11 - bit 8)
  PZX and PZY specify the magnification coefficient applied to the contents of the Pattern RAM. PZX, PZY = 0 specifies by 1 magnification (no magnification) while PZX, PZY = $F specifies by 16 magnification.

- Pattern Zoom Count X (PZCX: Pr05 bit 3 - bit 0)
  Pattern Zoom Count Y (PZCY: Pr05 bit 11 - bit 8)
  PZCX and PZCY specify the initial magnification counter values in the horizontal and vertical dimensions respectively.
  Normally, PZCX and PZCY should be set to 0.

- Pattern Pointer X (PPX: Pr05 bit 7 - bit 4)
  Pattern Pointer Y (PPY: Pr05 bit 15 - bit 8)
  The current reference point within the Pattern RAM is specified by PPX and PPY. When using PPX, PPY to define a pattern scan starting point, the relationship PSX ≤ PPX ≤ PEX and PSY ≤ PPY ≤ PEY must be maintained.

---
*(source page 131)*

##### 5.10.2.7 Area Definition Register (ADR: Pr08 - Pr0B)

**Figure 5.32 Area Definition Register (ADR)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr08 | XMIN (bits 15-0) — X-Minimum | | | | | | | | | | | | | | | |
| Pr09 | YMIN (bits 15-0) — Y-Minimum | | | | | | | | | | | | | | | |
| Pr0A | XMAX (bits 15-0) — X-Maximum | | | | | | | | | | | | | | | |
| Pr0B | YMAX (bits 15-0) — Y-Maximum | | | | | | | | | | | | | | | |

ADR is used to define a drawing area using logical X-Y addresses relative to the origin defined with the ORG command. The ACRTC will check logical drawing addresses against ADR depending on the AREA mode specified in the graphic drawing command.

---
*(source page 132)*

##### 5.10.2.8 Read Write Pointer (RWP: Pr0C - Pr0D)

**Figure 5.33 Read Write Pointer (RWP)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr0C | DN (bits 15-14) | | (hatched, unused, bits 13-8) | | | | | | RWPH (bits 7-0) | | | | | | | |
| Pr0D | RWPL (bits 15-4) | | | | | | | | | | | (hatched, unused, bits 3-0) | | | | |

- DN = Display Number
- RWPH = Read/Write Pointer High
- RWPL = Read/Write Pointer Low

RWP specifies a 20 bit physical frame buffer for use with the data transfer commands.

- Display Number (DN: Pr0C bit 15 - bit 14)
  DN specifies the logical screen containing the data to be transferred.

  | DN bit 15 | DN bit 14 | Functions |
  |---|---|---|
  | 0 | 0 | Upper Screen |
  | 0 | 1 | Base Screen |
  | 1 | 0 | Lower Screen |
  | 1 | 1 | Window Screen |

- Read Write Pointer High (RWPH: Pr0C bit 7 - bit 0)
  Read Write Pointer Low (RWPL: Pr0D bit 15 - bit 4)
  RWPH and RWPL define the initial 20 bit frame buffer address used with the data transfer commands.

---
*(source page 133)*

##### 5.10.2.9 Drawing Pointer (DP: Pr10 - Pr11)

**Figure 5.34 Drawing Pointer (DP)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr10 | DN (bits 15-14) | | (hatched, unused, bits 13-8) | | | | | | DPAH (bits 7-0) | | | | | | | |
| Pr11 | DPAL (bits 15-4) | | | | | | | | | | | DPD (bits 3-0) | | | | |

- DN = Display Number
- DPAH = Drawing Pointer High
- DPAL = Drawing Pointer Low
- DPD = Drawing Pointer Dot Address

The ACRTC uses DP for containing the physical drawing address calculated during drawing commands. When executing a drawing command, DP is updated as the Current Pointer (CP), specifying the current logical X-Y drawing address, is moved.

- Display Number (DN: Pr10 bit 15 - bit 14)
  DN specifies the screen for graphic drawing. Interpretation is the same as DN in the Read Write Pointer (RWP) register.

- Drawing Pointer Address High (DPAH: Pr10 bit 7 - bit 0)
  Drawing Pointer Address Low (DPAL: Pr11 bit 15 - bit 4)
  DPAH and DPAL specify the 20 bit physical drawing pointer address.

---
*(source page 134)*

- Drawing Pointer Dot (DPD: Pr11 bit 3 - bit 0)
  DPD specifies the physical pixel address to locate a logical pixel within the 16 bit word addressed by DPAH, DPAL. Interpretation depends on the specified relationship between logical pixels and physical frame buffer bits as determined by the Graphic Bit Mode (GBM).

| GBM | Function of DPD |
|---|---|
| 1 bit/pixel | DPD specifies 1 of 16 logical pixels |
| 2 bits/pixel | DPD specifies 1 of 8 logical pixels using most significant 3 bits of DPD. The least significant bit is not used. |
| 4 bits/pixel | DPD specifies 1 of 4 logical pixels using most significant 2 bits of DPD. The 2 least significant bits are not used. |
| 8 bits/pixel | DPD specifies 1 of 2 logical pixels using the most significant bit of DPD. The 3 least significant bits are not used. |
| 16 bits/pixel | DPD is not used. |

##### 5.10.2.10 Current Pointer (CP: Pr12 - Pr13)

**Figure 5.35 Current Pointer (CP)**

| Bit | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Pr12 | X (bits 15-0) | | | | | | | | | | | | | | | |
| Pr13 | Y (bits 15-0) | | | | | | | | | | | | | | | |

CP specifies the logical X-Y coordinates of the current drawing address. As drawing proceeds, the ACRTC calculates the physical frame buffer address for each X-Y addressed logical pixel. the physical address corresponding to CP is stored in the Drawing Pointer (DP) register. Two-complement format is used to indicate positive and negative values.

---
*(source page 135)*

*(This page is landscape-oriented in the original, printed sideways with the vertical running head "6. COMMANDS" along the right edge.)*

**Figure 6.1 Command Set**

| Type | Mnemonic | Command Name | Operation Code (16 bits, MSB→LSB) | Parameter | # (words) | ~ (cycles) |
|---|---|---|---|---|---|---|
| Register Access Command | ORG | Origin | 0000 0100 0000 0000 | DPH DPL | 3 | 8 |
| Register Access Command | WPR | Write Parameter Register | 0000 1000 00 RN(6 bits) | D | 2 | 6 |
| Register Access Command | RPR | Read Parameter Register | 0000 1100 00 RN(6 bits) | — | 1 | 6 |
| Register Access Command | WPTN | Write Pattern RAM | 0001 1000 0000 0 PRA(3) | n | 2 | 4n+8 |
| Register Access Command | RPTN | Read Pattern RAM | 0001 1100 0000 0 PRA(3) | n | 1 | 4n+8 |
| Data Transfer Command | DRD | DMA Read | 0010 0100 0000 0000 | AX AY | 3 | (4x+8)y+12[x·y/8↑]+(62~68) |
| Data Transfer Command | DWT | DMA Write | 0010 1000 0000 0000 | AX AY | 3 | (4x+8)y+16[x·y/8↑]+34 |
| Data Transfer Command | DMOD | DMA Modify | 0010 1100 0000 0 MM(2) | AX AY | 3 | (4x+8)y+16[x·y/8↑]+34 |
| Data Transfer Command | RD | Read | 0100 0100 0000 0000 | — | 1 | 12 |
| Data Transfer Command | WT | Write | 0100 1000 0000 0000 | D | 2 | 8 |
| Data Transfer Command | MOD | Modify | 0100 1100 0000 0 MM(2) | D | 2 | 8 |
| Data Transfer Command | CLR | Clear | 0101 0100 0000 0000 | D AX AY | 4 | (2x+8)y+12 |
| Data Transfer Command | SCLR | Selective Clear | 0101 1000 0000 0 MM(2) | D AX AY | 4 | (4x+6)y+12 |
| Data Transfer Command | CPY | Copy | 0110 0S DSD(2) 0000 0000 | SAH SAL AX AY | 5 | (6x+10)y+12 |
| Data Transfer Command | SCPY | Selective Copy | 0111 0S DSD(2) 0000 0 MM(2) | SAH SAL AX AY | 5 | (6x+10)y+12 |
| Graphic Command | AMOVE | Absolute Move | 1000 0000 0000 0000 | X Y | 3 | 56 |
| Graphic Command | RMOVE | Relative Move | 1000 0100 0000 0000 | dX dY | 3 | 56 |
| Graphic Command | ALINE | Absolute Line | 1000 1000 AREA COL OPM | X Y | 3 | P·L+18 |
| Graphic Command | RLINE | Relative Line | 1000 1100 AREA COL OPM | dX dY | 3 | P·L+18 |
| Graphic Command | ARCT | Absolute Rectangle | 1001 0000 AREA COL OPM | X Y | 3 | 2P(A+B)+54 |
| Graphic Command | RRCT | Relative Rectangle | 1001 0100 AREA COL OPM | dX dY | 3 | 2P(A+B)+54 |
| Graphic Command | APLL | Absolute Polyline | 1001 1000 AREA COL OPM | n X1,Y1,...Xn,Yn | 2n+2 | Σ[P·L+16]+8 |
| Graphic Command | RPLL | Relative Polyline | 1001 1100 AREA COL OPM | n dX1,dY1,...dXn,dYn | 2n+2 | Σ[P·L+16]+P·Lo+20 |
| Graphic Command | APLG | Absolute Polygon | 1010 0000 AREA COL OPM | n X1,Y1,...Xn,Yn | 2n+2 | Σ[P·L+16]+P·Lo+20 |
| Graphic Command | RPLC | Relative Polygon | 1010 0100 AREA COL OPM | n dX1,dY1,...dXn,dYn | 2n+2 | Σ[P·L+16]+P·Lo+20 |
| Graphic Command | CRCL | Circle | 1010 1000 C AREA COL OPM | r | 2 | 8d+66 |
| Graphic Command | ELPS | Ellipse | 1010 1100 C AREA COL OPM | a b dX | 4 | 10d+90 |
| Graphic Command | AARC | Absolute Arc | 1011 0000 C AREA COL OPM | Xc Yc Xe Ye | 5 | 8d+18 |
| Graphic Command | RARC | Relative Arc | 1011 0100 C AREA COL OPM | dXc dYc dXe dYe | 5 | 8d+18 |
| Graphic Command | AEARC | Absolute Ellipse Arc | 1011 1000 C AREA COL OPM | a b Xc Yc Xe Ye | 7 | 10d+96 |
| Graphic Command | REARC | Relative Ellipse Arc | 1011 1100 C AREA COL OPM | a b dXc dYc dXe dYe | 7 | 10d+96 |
| Graphic Command | AFRCT | Absolute Filled Rectangle | 1100 0000 AREA COL OPM | X Y | 3 | (P·A+B)B+18 |
| Graphic Command | RFRCT | Relative Filled Rectangle | 1100 0100 AREA COL OPM | dX dY | 3 | (P·A+B)B+18 |
| Graphic Command | PAINT | Paint | 1100 100E AREA COL OPM | — | 1 | (18A+102)B-58 *1) |
| Graphic Command | DOT | Dot | 1100 1100 AREA COL OPM | — | 1 | 8 |
| Graphic Command | PTN | Pattern | 1101 SL SD AREA COL OPM | SZ *2) | 2 | (P·A+10)B+20 |
| Graphic Command | AGCPY | Absolute Graphic Copy | 1110 S DSD(2) AREA 00 OPM | Xs Ys DX DY | 5 | ((P+2)A+10)B+70 |
| Graphic Command | RGCPY | Relative Graphic Copy | 1111 S DSD(2) AREA 00 OPM | dXs dYs DX DY | 5 | ((P+2)A+10)B+70 |

Notes:
*1) In case of rectangular filling.

*2) SZ register layout: bits 15-8 = SZy, bits 7-0 = SZx (SZy, SZx: Pattern Size).

n: number of repetition. x/y: drawing words of x-direction/y-direction. L/Lo/d: sum of drawing dots. A/B: drawing dots of main/sub direction.

P = 4 (for OPM 000 ~ 011), P = 6 (for OPM 100 ~ 111).

E: [E=0 (stop at Edge color), E=1 (stop at excepting Edge color)]. C: [C=1 (clock wise), C=0 (reverse)]. [↑]: rounding up.

*(Note on this transcription: the Operation Code column in the original is a 16-bit bit-field diagram with vertical divider lines at irregular bit boundaries; field widths for AREA, COL, OPM, DSD, MM, RN, PRA, S, SL, SD, C and E vary by command and are not separately labeled with bit numbers on this page. The bit patterns above are transcribed left-to-right as printed; consult Section 6's per-command descriptions for the authoritative bit-field boundaries and encodings.)*

124 HITACHI · 6. COMMANDS

---
*(source page 136)*

### 6. Function of Commands

#### 6.1 Command Overview

The ACRTC interprets and processes commands issued by the MPU. These commands are classified into three groups.

1) Register Access Commands
2) Data Transfer Commands
3) Graphic Drawing Commands

#### 6.2 Command Format

ACRTC commands consist of a 16 bit op-code, optionally followed by 1 or more 16 bit parameters. When 8 bit MPU mode is used, commands, parameters and data are sent to and from the ACRTC in the order of high byte, low byte.

(a) 16 bit interface

In the case of 16 bit interface, first move the 16 bit operation code and then move necessary 16 bit parameters one by one.

**(a) 16 bit Interface**

| bit 15 | ... | bit 0 | |
|---|---|---|---|
| Operation Code | | | |
| P1 | | | ⎫ |
| ⋮ | | | ⎬ Parameter |
| Pn | | | ⎭ |

(b) 8 bit interface

In the case of 8 bit interface, first move the operation code's High byte and Low byte in this order and then move those of parameters in the same order.

**(b) 8 bit Interface**

| bit 7 | ... | bit 0 | |
|---|---|---|---|
| High | | | ⎫ |
| Low | | | ⎬ Operation Code |
| High (P1) | | | ⎫ |
| Low (P1) | | | ⎪ |
| ⋮ | | | ⎬ Parameter |
| High (Pn) | | | ⎪ |
| Low (Pn) | | | ⎭ |

---
*(source page 137)*

#### 6.3 Command Transfer Modes

Commands (and associated parameters) can be issued to the ACRTC in one of two ways — program transfer or DMA transfer.

##### 6.3.1 Program Transfer

Program Transfer occurs when the MPU specifies the FIFO entry address and then writes commands/parameters to the write FIFO under program control (RS = high, R/W̄, CS̄ = low). The MPU writes are normally synchronized with ACRTC FIFO status by software polling or interrupts.

- Software Polling (WFR, WFE interrupts disabled)
  a) MPU program checks the SR (Status Register) for Write FIFO Ready (WFR) flag = 1, and then writes one word of command or parameters.
  b) MPU program checks the SR (Status Register) for Write FIFO Empty (WFE) flag = 1, and then writes one to eight words of commands or parameters.

- Interrupt Driven (WFR, WFE interrupts enabled)
  a) MPU WFR interrupt service routine writes one word of command or parameters.
  b) MPU WFE interrupt service routine writes one to eight words of commands or parameters.

  In the specific case of Register Access Commands and an initially empty write FIFO, MPU writes need not be synchronized to the write FIFO status. The ACRTC can fetch and execute these commands faster than the MPU can issue them.

##### 6.3.2 Command DMA Transfer

Commands and parameters can be transferred from MPU system memory using an external DMAC. The MPU initiates and terminates Command DMA Transfer mode under software control (CDM bit of CCR). Command DMA can also be terminated by assertion of the ACRTC DONĒ signal. DONĒ is treated as an input in Command DMA Transfer Mode.

Using Command DMA Transfer, the ACRTC will issue cycle stealing DMA requests to the DMAC when the write FIFO is empty. The DMA data is automatically sent from system memory to the ACRTC write FIFO regardless of the contents of the Address Register.

---
*(source page 138)*

#### 6.4 Register Access Commands

Registers associated with the Drawing processor (the Pattern RAM and Drawing Parameter Registers) are accessed through the read and write FIFOs using the Register Access Commands.

**Figure 6.2 Register Access Commands**

| Command | Function |
|---|---|
| ORG | Inicialize the relation between the origin point in the X-Y coordinates and the physical address. |
| WPR | Write into the parameter register |
| RPR | Read the parameter register |
| WPTN | Write into the pattern RAM |
| RPTN | Read the pattern RAM |

---
*(source page 139)*

#### 6.5 Data Transfer Commands

Data Transfer Commands are used to move blocks of data between the MPU system memory and the ACRTC frame buffer or within the frame buffer itself. Before issuing these commands, a physical 20 bit frame buffer address must be specified in the RWP (Read Write Pointer) Drawing Parameter Register.

The DMA Data Transfer Commands (DRD, DWT and DMOD) are used to send large amounts of data between system and frame buffer memory. The programmer specifies the command and the X and Y logical pixel dimensions of the frame buffer data block. The ACRTC will automatically control the external DMAC to request data transfers via the read or write FIFOs. In Data DMA Transfer, the ACRTC DONĒ pin becomes an output which the ACRTC asserts to the external DMAC to terminate the transfer. Also, either cycle steal or burst DMA request mode can be used for data DMA (DRC bit of CCR).

Note that DMA data transfer can be performed without an external DMAC, i.e. under MPU program control. In this case, the data DMA handshaking (DREQ̄, DACK̄ and DONĒ) signals are disabled by resetting the DDM bit in CCR to 0. After issuing a DMA data transfer command, the MPU reads or writes the appropriate data to the ACRTC FIFOs under program control. The programmer must insure that the amount of data transferred equals the amount specified as parameters to the command. Also note that the ACRTC will go into an indefinite wait state after the last transfer of a DRD command. Then, the command should be aborted (by setting the ABT bit in CCR to 1) and the next command issued.

---
*(source page 140)*

**Figure 6.3 Data Transfer Commands**

| Command | Function |
|---|---|
| DRD | DMA read of the frame buffer data |
| DWT | DMA write into the frame buffer |
| DMOD | DMA modify of the frame buffer data (bit maskable) |
| RD | One word read from the frame buffer |
| WT | One word write into the frame buffer |
| MOD | One word modify of the frame buffer (bit maskable) |
| CLR | Clear of frame buffer area |
| SCLR | Clear of frame buffer area (bit maskable) |
| CPY | Copy of frame buffer area into another area |
| SCPY | Copy of frame buffer area into another area (bit maskable) |

**Figure 6.4 Data Transfer Command Format**

Operation Code (bit 15 - bit 0): | Command Code (bits 15-8) | 0 0 0 0 0 0 (bits 7-2) | MM (bits 1-0) |

Parameter (bit 15 - bit 0): | Parameter |

Parameter (bit 15 - bit 0): | Parameter |

---
*(source page 141)*

##### 6.5.1 Modify Mode

The DMOD, MOD, SCLR and SCPY commands allow 4 types of bit level logical operations to be applied to frame buffer data. The modify mode is encoded in the lower two bits (MM) of these op-codes. The bit positions within each frame buffer word to be modified are selectable using the mask register (MASK). Bits masked with 1 are modifiable, those masked with 0 are not.

| MM (bit 1) | MM (bit 0) | Modify Mode |
|---|---|---|
| 0 | 0 | REPLACE frame buffer data with command parameter data. |
| 0 | 1 | OR frame buffer data with command parameter data and rewirte to the frame buffer. |
| 1 | 0 | AND frame buffer data with command parameter data and rewrite to the frame buffer. |
| 1 | 1 | EOR frame buffer data with command parameter data and rewrite to the frame buffer. |

- Modify Mode Examples
  The following examples show the use of the REPLACE, OR, AND and EOR modify modes. The modifier data (issued as a prameter to the DMOD, MOD, SCLR and SCPY commands) and the non-masked data in the frame buffer are logically operated on, and the result is rewritten to the frame buffer.

---
*(source page 142)*

MM = 00 → `00` Replace

| MASK Register | 0000 | 111111 | 00000 |
|---|---|---|---|
| Read Data (Frame Buffer Data: before modified) | 0001 | 001000 | 110100 |
| Write Data (Frame Buffer Data: modified) | 0001 | 010111 | 110100 |
| Modifier Data (Set by COMMAND PARAMETER) | | 010111 | |

The read data bit positions for which the MASK register contains '1' is REPLACED with the command parameter modifier data. The result is rewritten to the read data location in the frame buffer.

**Figure 6.5(a) REPLACE Modify Mode**

---
*(source page 143)*

MM = 01 → `01` OR

| MASK Register | 0000 | 111111 | 00000 |
|---|---|---|---|
| Read Data (Frame Buffer Data: before modified) | 0001 | 001000 | 110100 |
| Write Data (Frame Buffer Data: modified) | 0001 | 011111 | 110100 |
| Modifier Data (Set by COMMAND PARAMETER) | | 010111 | |

(The masked bit positions of Read Data are combined with Modifier Data through an OR gate to produce Write Data; unmasked bit positions pass Read Data through unchanged.)

The read data bit positions for which the MASK register contains '1' is ORed with the command parameter modifier data. The result is rewritten to the read data location in the frame buffer.

**Figure 6.5(b) OR Mofify Mode**

---
*(source page 144)*

MM = 10 → `10` AND

| MASK Register | 0000 | 111111 | 00000 |
|---|---|---|---|
| Read Data (Frame Buffer Data: before modified) | 0001 | 001011 | 110100 |
| Write Data (Frame Buffer Data: modified) | 0001 | 000011 | 110100 |
| Modifier Data (Set by COMMAND PARAMETER) | | 010111 | |

(The masked bit positions of Read Data are combined with Modifier Data through an AND gate to produce Write Data; unmasked bit positions pass Read Data through unchanged.)

The read data bit positions for which the MASK register contains '1' is ANDed with the command parameter modifier data. The result is rewritten to the read data location in the frame buffer.

**Figure 6.5(c) AND Modify Mode**

---
*(source page 145)*

MM = 11 → `11` EOR

| MASK Register | 0000 | 111111 | 00000 |
|---|---|---|---|
| Read Data (Frame Buffer Data: before modified) | 0001 | 001000 | 110100 |
| Write Data (Frame Buffer Data: modified) | 0001 | 011100 | 110100 |
| Modifier Data (Set by COMMAND PARAMETER) | | 010100 | |

(The masked bit positions of Read Data are combined with Modifier Data through an EOR (exclusive-OR) gate to produce Write Data; unmasked bit positions pass Read Data through unchanged.)

The read data bit positions for which the MASK register contains '1' is EORed with the command parameter modifier data. The result is rewritten to the read data location in the frame buffer.

**Figure 6.5(d) EOR Modify Mode**

---
*(source page 146)*

#### 6.6 Graphic Drawing Commands

The ACRTC has 23 separate graphic drawing commands. Graphic drawing is performed by modifying the contents of the frame buffer based upon microcoded drawing algorithms in the ACRTC drawing processor.

Most coordinate parameters for graphic drawing commands are specified using logical pixel X-Y addressing. The complex task of translating a logical pixel address to a linear frame buffer word address, and further selecting the appropriate sub-field of the word (for example, a given logical pixel in 4 bits per logical pixel mode might reside in bits 8-11 of a frame buffer word) is performed at high speed by ACRTC hardware.

Many instructions allow specification of X-Y coordinates with either absolute or relative X-Y coordinates (e.g. ALINE and RLINE). In both cases, twos complement numbers are used to represent positive and negative values.

(a) Absolute Coordinate Specification
The screen address (X, Y) is specified in units of logical pixels relative to an origin point defined with the ORG command.

(b) Relative Coordinate Specification
The screen address (dX,dY) is specified in units of logical pixels relative to the current drawing pointer (CP) position.

A graphic drawing command consists of a 16 bit op-code and optionally 0 to 64K 16 bit parameters.

The 16 bit op-code consists of an 8 bit command code, an AREA Mode specifier (3 bits), a Color Mode specifier (2 bits) and an Operation Mode specifier (3 bits).

The Area Mode allows versatile clipping and hitting detection. A drawing area can be defined, and should drawing operations attempt to enter or leave that area, a number of programmable actions can be taken by the ACRTC.

The Color Mode determines whether the Pattern RAM is used indirectly to select Color Registers or is directly used as the color information.

The Operation Mode defines one of eight logical operations to be performed between the frame buffer read data and the color data in the Pattern RAM to determine the drawing data to be rewritten to the frame buffer.

---
*(source page 147)*

(i) Absolute Coordinate Specification
Specifies the addresses (x, y) based on the origin point set by the ORG command.

**Figure 6.6(a) Absolute Coordinate Specification**

*(Diagram: an X-Y axis pair with the Origin at the intersection (marked with an arrow labeled "Origin"); point (x, y) is shown up and to the right of the origin, with dashed lines dropping to x on the X-axis and y on the Y-axis.)*

(ii) Relative Coordinate Specification
Specifies the relative addresses (Δx, Δy) related to the current drawing point.

**Figure 6.6(b) Relative Coordinate Specification**

*(Diagram: an X-Y axis pair with the Origin at the intersection. The Current Pointer CP(x,y) is plotted at (x,y) via dashed lines from the axes. From CP, a solid arrow extends to point (x+Δx, y+Δy), with Δx and Δy marked as the horizontal and vertical legs of that displacement.)*

---
*(source page 148)*

**Figure 6.7 Graphic Drawing Commands**

| Command | Function |
|---|---|
| AMOVE / RMOVE | Movement of current points |
| ALINE / RLINE | Drawing of straight lines |
| ARCT / RRCT | Drawing of rectangles |
| APLL / RPLL | Drawing of polylines |
| APLG / RPLG | Drawing of polygons |
| CRCL | Drawing of circles |
| ELPS | Drawing of ellipses |
| AARC / RARC | Drawing of arcs |
| AEARC / REARC | Drawing of ellipse arcs |
| AFRCT / RFRCT | Painting of rectangle areas (Tiling) |
| PAINT | Painting of arbitrary areas (Tiling) |
| DOT | Making of dots |
| PTN | Drawing of basic patterns (rotation angle: 45°) |
| AGCPY / RGCPY | Graphic copy between frame memories (rotation angle: 90°/mirror turnover) |

**Figure 6.8 Graphic Drawing Command Format**

Operation Code (bit 15 - bit 0): | Command Code (bits 15-8) | AREA (bits 7-5) | COL (bits 4-3) | OPM (bits 2-0) |

Parameter (bit 15 - bit 0): | Parameter |

Parameter (bit 15 - bit 0): | Parameter |

---
*(source page 149)*

##### 6.6.1 Operation Mode

The Operation Mode (OPM bits) of the Graphic Drawing Command specify the logical drawing condition.

| OPM (2) | OPM (1) | OPM (0) | Operation Mode |
|---|---|---|---|
| 0 | 0 | 0 | REPLACE: Replaces the frame buffer data with the color data. |
| 0 | 0 | 1 | OR: ORs the frame buffer data with the color data. The result is rewritten to the frame buffer. |
| 0 | 1 | 0 | AND: ANDs the frame buffer data with the color data. The result is rewritten to the frame buffer. |
| 0 | 1 | 1 | EOR: EORs the frame buffer data with the color data. The result is rewritten to the frame buffer. |
| 1 | 0 | 0 | CONDITIONAL REPLACE (P=CCMP): When the frame buffer data at the drawing position (P) is equal to the comparison color (CCMP), the frame buffer data is replaced with the color data. |
| 1 | 0 | 1 | CONDITIONAL REPLACE (P≠CCMP): When the frame buffer data at the drawing position (P) is not equal to the comparison color (CCMP), the frame buffer data is replaced with the color data. |
| 1 | 1 | 0 | CONDITIONAL REPLACE (P<CL): When the frame buffer data at the drawing position (P) is less than the color register data (CL), the frame buffer data is replaced with the color data. |
| 1 | 1 | 1 | CONDITIONAL REPLACE (P>CL): When the frame buffer data at the drawing position (P) is greater than the color register data (CL), the frame buffer data is replaced with the color data. |

Following are examples of each of the eight operation modes. In these examples, 4 bits/logical pixel is assumed.

Figure 6.10 shows examples of a drawing pattern applied with various OPM modes.

---
*(source page 150)*

OPM = 000 → `000` Replace

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * | (bits 3-0; bit3=0, bit2=1, bits 1-0 = don't-care, selecting the second nibble)

| Read data (Frame Buffer data: before correction) | 0001 | 0010 | 0110100 |
|---|---|---|---|
| Write data (Frame Buffer data: after correction) | 0001 | 0101 | 0110100 |
| Color data (Color register) | | 0101 | |

(Bit alignment note: the read/write data rows are 16 bits split as 4+4+8; the highlighted 4-bit nibble selected by DPD (second nibble) is replaced by the 4-bit Color data value, other nibbles pass through unchanged.)

One pixel of the frame buffer read data is REPLACED with the corresponding color register data and the result is rewritten to the frame buffer read data location. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(a) REPLACE Operation Mode**

---
*(source page 151)*

OPM = 001 → `001` OR

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * |

| Read data (Frame buffer data: before correction) | 0001 | 0010 | 0110100 |
|---|---|---|---|
| Write data (Frame buffer data: after correction) | 0001 | 0111 | 0110100 |
| Color data (color register) | | 0101 | |

(The selected 4-bit nibble of Read data is combined with Color data through an OR gate to produce Write data; other nibbles pass through unchanged.)

One pixel of the frame buffer read data is ORed with the corresponding color register data and the result is rewritten to the frame buffer read data location. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(b) OR Operation Mode**

---
*(source page 152)*

OPM = 010 → `010` AND

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * |

| Read data (Frame buffer data: before correction) | 0001 | 0010 | 0110100 |
|---|---|---|---|
| Write data (Frame buffer data: after correction) | 0001 | 0000 | 0110100 |
| Color data (Color register) | | 0101 | |

(The selected 4-bit nibble of Read data is combined with Color data through an AND gate to produce Write data; other nibbles pass through unchanged.)

One pixel of the frame buffer read data is ANDed with the corresponding color register data and the result is rewritten to the frame buffer read data location. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(c) AND Operation Mode**

---
*(source page 153)*

OPM = 011 → `011` EOR

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * |

| Read data (Frame buffer data: before correction) | 0001 | 0010 | 0110100 |
|---|---|---|---|
| Write data (Frame buffer data: after correction) | 0001 | 0111 | 0110100 |
| Color data (color register) | | 0101 | |

(The selected 4-bit nibble of Read data is combined with Color data through an EOR gate to produce Write data; other nibbles pass through unchanged.)

One pixel of the frame buffer read data is EORed with the corresponding color register data and the result is rewritten to the frame buffer read data location. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(d) EOR Operation Mode**

---
*(source page 154)*

OPM = 100 → `100` Conditional Replacement (P = CCMP)

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * |

| Color Comparison Register data (CCMP) | | 0001 | |
|---|---|---|

Comparator: `=` compares the selected nibble of Read data against CCMP.

| Read data (Frame buffer data: before correction) | 0001 | 0001 | 0110100 |
|---|---|---|---|
| Write data (Frame buffer data: after correction) | 0001 | 0101 | 0110100 |
| Color data (Color register) | | 0101 | |

(A Y/N selector, driven by the comparator's equal/not-equal result, chooses between Color data (Y, equal) and the unmodified Read data (N, not equal) for the selected nibble; other nibbles pass Read data through unchanged.)

One pixel of the frame buffer read data is compared with the corresponding one pixel contents of the Color Comparison Register (CCMP). If equal, the read data is replaced with the color data and the result is rewritten to the read data location in the frame buffer. If not equal, the read data (unmodified) is rewritten to the read data location in the frame buffer. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(e) P=CCMP Operation Mode**

---
*(source page 155)*

OPM = 101 → `101` Conditional Replacement (P ≠ CCMP)

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * |

| Color Comparison Register (CMP) data | | 0100 | |
|---|---|---|

Comparator: `≠` compares the selected nibble of Read data against CCMP.

| Read data (Frame buffer data: before correction) | 0001 | 0010 | 0110100 |
|---|---|---|---|
| Write data (Frame buffer data: after correction) | 0001 | 0101 | 0110100 |
| Color data (Color register) | | 0101 | |

(A Y/N selector, driven by the comparator's not-equal/equal result, chooses between Color data (Y, not equal) and the unmodified Read data (N, equal) for the selected nibble; other nibbles pass Read data through unchanged.)

One pixel of the frame buffer read data is compared with the corresponding one pixel contents of the Color Comparison Register (CCMP). If not equal, the read data is replaced with the color data and the result is rewritten to the read data location in the frame buffer. If equal, the read data (unmodified) is rewritten to the read data location in the frame buffer. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(f) P ≠ CCMP Operation Mode**

---
*(source page 156)*

OPM = 110 → `110` Conditional Replacement (P < CL)

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * |

| Read data (Frame buffer data: before correction) | 0001 | 0010 | 0110100 |
|---|---|---|---|
| Write data (Frame buffer data: after correction) | 0001 | 0101 | 0110100 |
| Color data (Color register) | | 0101 | |

Comparator: `>` compares Color data against the selected nibble of Read data (i.e. tests whether Read data < Color data). A Y/N selector, driven by the comparison result, chooses between Color data (Y, Read data < Color data) and the unmodified Read data (N, Read data ≥ Color data) for the selected nibble; other nibbles pass Read data through unchanged.

One pixel of the frame buffer read data is compared with the corresponding one pixel contents of the color data (CL). If the read data is LESS than the color data, the read data is replaced with the color data and the result is rewritten to the read data location in the frame buffer. If the read data is GREATER than or EQUAL to the color data, the read data (unmodified) is rewritten to the read data location in the frame buffer. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(g) P<CL Operation Mode**

---
*(source page 157)*

OPM = 111 → `111` Conditional Replacement (P > CL)

DPD in DP (4 bit/pixel mode): | 0 | 1 | * | * |

| Read data (Frame buffer data: before correction) | 0000 | 0010 | 0110100 |
|---|---|---|---|
| Write data (Frame buffer data: after correction) | 0001 | 0001 | 0110100 |
| Color data (Color register) | | 0001 | |

Comparator: `<` compares Color data against the selected nibble of Read data (i.e. tests whether Read data > Color data). A Y/N selector, driven by the comparison result, chooses between Color data (Y, Read data > Color data) and the unmodified Read data (N, Read data ≤ Color data) for the selected nibble; other nibbles pass Read data through unchanged.

One pixel of the frame buffer read data is compared with the corresponding one pixel contents of the color data (CL). If the read data is GREATER than the color data, the read data is replaced with the color data and the result is rewritten to the read data location in the frame buffer. If the read data is LESS than or EQUAL to the color data, the read data (unmodified) is rewritten to the read data location in the frame buffer. The dot pointer serves to extract the pixel from the frame buffer word — in this example, 4 bits/pixel.

**Figure 6.9(h) P>CL Operation Mode**

---
*(source page 158)*

*(This page is a full-page illustration with no running body text other than the figure caption and labels.)*

**Figure 6.10 Operation Mode Example**

The figure shows a "Hi" drawing pattern (letters H and i, each drawn as a hatched shape inside a dashed bounding box, with the dot over the "i" as a small separate hatched square) applied to a picture memory that is white in its upper half and hatched (already containing data) in its lower half, under each of the four basic operation modes:

- **Drawing Pattern**: the source "Hi" pattern, shown as hatched glyph shapes within a dashed rectangle — this is the pattern data used as input to all four examples below.
- **Picture Memory before Drawing**: the destination frame buffer area before the operation, split horizontally — top half blank/white, bottom half hatched (pre-existing data).
- **Replacement**: the "Hi" pattern is written into the destination area, fully replacing whatever was there (both the blank top and hatched bottom portions of the destination show the clean "Hi" glyph shapes; the area outside the pattern glyphs but inside the bounding box is also hatched, matching the "replace" semantics of overwriting the whole box with pattern-derived data).
- **OR**: the "Hi" pattern is ORed with the destination. Where the destination was already hatched (bottom half), the result stays solidly hatched (OR with 1 stays 1); where the destination was blank (top half), only the glyph-shaped areas of the pattern become hatched, and the pattern's glyph outlines are still visible within the dashed box.
- **AND**: the "Hi" pattern is ANDed with the destination. Since the top half of the destination was blank (0), ANDing yields blank in the top half regardless of pattern; only in the bottom (previously hatched) half do the pattern's glyph shapes appear (hatched "n" and "i"-stem-like remnants of the letters, since the top portions of the strokes that fell in the blank region were zeroed out) — the result shows only the lower portions of the "Hi" glyphs surviving, since AND requires both the pattern bit and the previous destination bit to be set.
- **EOR**: the "Hi" pattern is EORed (exclusive-ORed) with the destination. In the top (blank) half, the glyph shapes appear hatched wherever the pattern has a 1 (same as OR there, since EOR with 0 equals the pattern value). In the bottom (previously hatched) half, the glyph shapes appear as blank/uncolored cutouts against the hatched background (since EOR with 1 inverts the pattern bit), producing a "negative" silhouette of the "Hi" glyphs against the solid hatched fill.

---
*(source page 159)*

##### 6.6.2 Color Mode

The Color Mode (COL bits) specify the source of the drawing color data as directly or indirectly (using the Color Registers) determined by the contents of the Pattern RAM.

| COL (1) | COL (0) | Color Mode |
|---|---|---|
| 0 | 0 | When Pattern RAM data = 0, Color Register 0 is used. When Pattern RAM data = 1, Color Register 1 is used. |
| 0 | 1 | When Pattern RAM data = 0, drawing is suppressed. When Pattern RAM data = 1, Color Register 1 is used. |
| 1 | 0 | When Pattern RAM data = 0, Color Register 0 is used. When Pattern RAM data = 1, drawing is suppressed. |
| 1 | 1 | Pattern RAM contents are directly used as color data. |

The Color Mode chooses the source for color information based on the contents (0 or 1) of a particular bit in the 16 bit by 16 bit (32 byte) Pattern RAM. A sub-pattern is specified by programming the Pattern RAM Control Register (PRC) with the start (PSX, PSY) and end (PEX, PEY) points which define the diagonal of the sub-pattern. Furthermore, a specific starting point for Pattern RAM scanning is specified by PPX and PPY.

*(Diagram: a square labeled "Pattern RAM" containing a smaller rectangle whose corners are labeled (PSX, PSY) at bottom-left and (PEX, PEY) at top-right; inside that rectangle a small square marks the current scan position (PPX, PPY).)*

Normally, the color registers (CL) should be loaded with one color data based on the number of bits per pixel. For example, if 4 bits/pixel are used, the 4 bit color pattern (e.g. 0001) should be replicated four times in the color register, i.e.

Color Register = `0001 0001 0001 0001`

In this way, color changes due to changing dot address are avoided.

---
*(source page 160)*

COL = 00

*(Diagram: "Color Information" (hatched bar) is driven by a multiplexer selecting between "Color Register 0" and "Color Register 1" (both hatched bars), controlled by a single Pattern RAM bit x, read from the Graphic Pattern RAM at the scan position (PPX, PPY) within the sub-pattern box defined by corners (PSX, PSY) and (PEX, PEY). When x = 0, Color Register 0 feeds Color Information; when x = 1, Color Register 1 feeds Color Information.)*

If the scanned Pattern RAM bit is equal '0', Color Register 0 (CL0) determines the color information. If the scanned Pattern RAM bit is equal '1', Color Register 1 (CL1) determines the color information.

**Figure 6.11(a) Color Mode = 00**

---
*(source page 161)*

COL = 01

*(Diagram, labeled (c): "Color Information" (hatched bar) is driven from "Color Register 1" (hatched bar) via a multiplexer position x=1; "Color Register 0" (unhatched, unused in this mode) is shown but not connected to Color Information. The multiplexer's select input x is read from the Graphic Pattern RAM at scan position (PPX, PPY) within the sub-pattern box bounded by (PSX, PSY) and (PEX, PEY).)*

If the scanned Pattern RAM bit is equal '0', the drawing operation is suppressed and the frame buffer is not changed. If the scanned Pattern RAM bit is equal '1', Color Register 1 (CL1) determines the color information.

**Figure 6.11(b) Color Mode = 01**

---
*(source page 162)*

COL = 10

*(Diagram, labeled (c): "Color Information" (hatched bar) is driven from "Color Register 0" (hatched bar) via a multiplexer position x=0; "Color Register 1" (unhatched, unused in this mode) is shown but not connected to Color Information. The multiplexer's select input x is read from the Graphic Pattern RAM at scan position (PPX, PPY) within the sub-pattern box bounded by (PSX, PSY) and (PEX, PEY).)*

If the scanned Pattern RAM bit is equal '1', the drawing operation is suppressed and the frame buffer is not changed. If the scanned Pattern RAM bit is equal '0', Color Register 0 (CL0) determines the color information.

**Figure 6.11(c) Color Mode = 10**

---
*(source page 163)*

COL = 11

*(Diagram: a tall "Pattern RAM" column of 16 rows, addressed on the left by PPX (a repeating 3,2,1,0 sub-index) and internally numbered 0 through F (hex) from bottom to top, grouped in fours corresponding to PPY values 0, 1, 2, 3 (shown as boxed digits on the right, bottom to top). To the right, a 3-D exploded view shows the same 16 entries remapped into a 4×4 grid of logical pixel positions, labeled with hex digits 0-F: bottom row 0,1,2,3; next row 4,5,6,7; next row 8,9,A,B; top row C,D,E,F — drawn as a stack of four 4-wide slices in perspective.)*

Below the diagrams: "Color Information" (hatched bar) is driven directly from "Bit Information on Pattern RAM" (hatched bar) — i.e. the Pattern RAM word at the selected 4×4 position feeds Color Information directly, with no register indirection.

**Figure 6.11(d) Color Mode = 11**

In the former three color modes (Pattern RAM indirect), the actual color information is stored in the color registers (CL0, CL1) and selection is based on the 0 or 1 bit value during Pattern RAM scanning.

In color mode = 11 (Pattern RAM direct), the Pattern RAM contents are directly used to generate color information. This is accomplished by remapping of the Pattern RAM so that it is interpreted as containing up to 4 by 4 logical pixel color patterns, each of which contains 16 bits of color information.

---
*(source page 164)*

Associated with this logical remapping of the Pattern RAM, the contents of the Pattern RAM Control Register (PRC) are interpreted differently. As shown below the pattern pointer, pattern start and pattern end (PPX, PPY, PSX, PSY, PEX and PEY) are restricted to specify a maximum 4 by 4 logical pixel pattern. Specifically, bits 15-14 and 7-6 must be set to 0.

| RN | Register Name | 15 | 14 | 13 12 | 11 10 9 8 | 7 | 6 | 5 4 | 3 2 1 0 |
|---|---|---|---|---|---|---|---|---|---|
| 05 | Pattern Control | 0 | 0 | PPY | PZCY | 0 | 0 | PPX | PZCX |
| 06 | Pattern Control | 0 | 0 | PSY | 0 0 0 0 | 0 | 0 | PSX | 0 0 0 0 |
| 07 | Pattern Control | 0 | 0 | PEY | PZY | 0 | 0 | PEX | PZX |

A pattern size less than 4 by 4 logical pixels can be specified (minimum is 1 by 1 logical pixel) as shown below. In this example a 2 by 4 logical pixel pattern is specified by setting PSX = 1, PSY = 0, PEX = 2 and PEY = 3.

| | col: PSX=1 | col: PEX=2 | |
|---|---|---|---|
| row PEY=3 | D | E | |
| row 2 | 9 | A | |
| row 1 | 5 | 6 | |
| row PSY=0 | 1 | 2 | |

As in color register indirect modes, normally one color is repeatedly assigned to the 16 bit color information depending on the number of bits per pixel. For example, when 4 bits per pixel are used, and color information for a pixel is 0001, the Patttern RAM should contain ...

`0001 0001 0001 0001`

This prevents color change due to changing dot address.

---
*(source page 165)*

##### 6.6.3 Area Mode

Prior to drawing, a drawing 'area' may be defined (Area Definition Register). Then, during Graphics Drawing operation the ACRTC will check if the drawing point is attempting to enter or exit the defined drawing area. Based on eight Area Modes, the ACRTC will take appropriate action for clipping or hitting.

| AREA (2) | AREA (1) | AREA (0) | Drawing Area Mode |
|---|---|---|---|
| 0 | 0 | 0 | Drawing is executed without Area checking. |
| 0 | 0 | 1 | When attempting to exit the Area, drawing is stopped and the ARD (Area Detect) and CED (Command End) flags are set. |
| 0 | 1 | 0 | Drawing suppressed outside the Area — drawing operation continues and the ARD flag is not set. |
| 0 | 1 | 1 | Drawing suppressed outside the Area — drawing operation continues and the ARD flag is set. |
| 1 | 0 | 0 | Same as AREA = 0 0 0. |
| 1 | 0 | 1 | When attempting to enter the Area, drawing is stopped and the ARD and CED (Command End) flags are set. |
| 1 | 1 | 0 | Drawing suppressed inside the Area — drawing operation continues and the ARD flag is not set. |
| 1 | 1 | 1 | Drawing suppressed inside the Area — drawing operation continues and the ARD flag is set. |

The following examples show execution of a CRCL (Circle) command using the various Area Modes. It is assumed that the Area Definition Register has been loaded to define the Area bounded by XMIN, YMIN and XMAX, YMAX.

---
*(source page 166)*

AREA = X00 : Area Mode

*(Diagram: a rectangle with corners (XMIN, YMIN) at bottom-left and (XMAX, YMAX) at top-right, labeled "Area Definition"; a circle centered inside the rectangle, roughly half of it extending outside the rectangle's left edge, with an arrow along the circle's circumference showing the drawing direction (counterclockwise from the 3 o'clock point) — the entire circle is drawn solid, indicating no area-based interruption.)*

Drawing is executed without area checking.

**Figure 6.12(a) Area Mode = X00**

---
*(source page 167)*

AREA = 001 : Area Mode

*(Diagram: same rectangle (XMIN,YMIN)-(XMAX,YMAX) labeled "Area Definition"; the circle is centered inside, extending outside the rectangle's left edge. The portion of the circle inside the rectangle is drawn solid with a directional arrow; the portion outside the rectangle (to the left) is drawn dashed, indicating drawing has stopped once the pointer exits the area.)*

Drawing is executed as long as the CP (Current Pointer) resides in the defined area. When the drawing operation causes the CP to go outside the defined area, the drawing instruction is terminated and the ARD (Area Detect) and CED (Command End) flags in the Status Register (SR) are set to '1'.

**Figure 6.12(b) Area Mode = 001**

---
*(source page 168)*

AREA = 010 : Area Mode

*(Diagram: same rectangle (XMIN,YMIN)-(XMAX,YMAX) labeled "Area Definition"; the circle is centered inside, extending outside the rectangle's left edge. The portion of the circle inside the rectangle is drawn solid with a directional arrow; the portion outside the rectangle (to the left) is drawn dashed, indicating drawing is suppressed there but the operation continues.)*

Wheh the CP (Current Pointer) is outside the defined area, drawing is suppressed but the drawing operation continues. When CP is inside the defined area, drawing operation is enabled. When the drawing instruction execution is completed, the CED (Command End) bit in the Status Register (SR) is set to '1'. The ARD bit (Area Detect) bit in the Status Register is not set to '1' at any time during the drawing instruction execution regardless of whether CP goes inside or outside the defined area.

**Figure 6.12(c) Area Mode = 010**

---
*(source page 169)*

AREA = 011 : Area Mode

*(Diagram: same rectangle (XMIN,YMIN)-(XMAX,YMAX) labeled "Area Definition"; the circle is centered inside, extending outside the rectangle's left edge. The portion of the circle inside the rectangle is drawn solid with a directional arrow; the portion outside the rectangle (to the left) is drawn dashed, indicating drawing is suppressed there but the operation continues — visually identical to Area Mode 010, differing only in the ARD flag behavior described below.)*

This mode is the same as AREA MODE = 010 in that drawing is enabled when CP (Current Pointer) is inside the defined area and suppressed when CP is outside the defined area. However, if at any time during the drawing instruction execution, CP goes outside the defined area, the ARD (Area Detect) bit in the Status Register (SR) will be set to '1'. The ARD bit can be monitored to determine when the CP goes outside the defined area.

**Figure 6.12(d) Area Mode = 011**

---
*(source page 170)*

AREA = 101 : Area Mode

*(Diagram: same rectangle (XMIN,YMIN)-(XMAX,YMAX) labeled "Area Definition"; a circle centered outside the rectangle, to the right, overlapping the rectangle's right edge. The portion of the circle outside the rectangle (to the right) is drawn solid with a directional arrow; the portion that would fall inside the rectangle is drawn dashed, indicating drawing stops once the pointer enters the area.)*

Drawing is executed as long as the CP (Current Pointer) resides outside the defined area. When the drawing operation causes the CP to go inside the defined area, the drawing instruction is terminated and the ARD (Area Detect) and CED (Command End) flags in the Status Register (SR) are set to '1'.

**Figure 6.12(e) Area Mode = 101**

---
*(source page 171)*

AREA = 110 : Area Mode

*(Diagram: same rectangle (XMIN,YMIN)-(XMAX,YMAX) labeled "Area Definition"; a circle centered outside the rectangle, to the right, overlapping the rectangle's right edge. The portion of the circle outside the rectangle (to the right) is drawn solid with directional arrows; the portion that would fall inside the rectangle is drawn dashed, indicating drawing is suppressed there but the operation continues.)*

When the CP (Current Pointer) is inside the defined area, drawing is suppressed but the drawing operation continues. When CP is outside the defined area, drawing operation is enabled. When the drawing instruction execution is completed, the CED (Command End) but in the Status Register (SR) is set to '1'. The ARD bit (Area Detect) bit in the Status Register is not set to '1' at any time during the drawing instruction execution regardless of whether CP goes inside or outside the defined area.

**Figure 6.12(f) Area Mode = 110**

---
*(source page 172)*

AREA = 111 : Area Mode

*(Diagram: same rectangle (XMIN,YMIN)-(XMAX,YMAX) labeled "Area Definition"; a circle centered outside the rectangle, to the right, overlapping the rectangle's right edge. The portion of the circle outside the rectangle (to the right) is drawn solid with directional arrows; the portion that would fall inside the rectangle is drawn dashed — visually identical to Area Mode 110, differing only in the ARD flag behavior described below.)*

This mode is the same as AREA MODE = 110 in that drawing is enabled when CP (Current Pointer) is outside the defined area and suppressed when CP is inside the defined area. However, if at any time during the drawing instruction execution, CP goes inside the defined area, the ARD (Area Detect) bit in the Status Register (SR) will be set to '1'. The ARD bit can be monitored to determine when the CP goes inside the defined area.

**Figure 6.12(g) Area Mode = 111**

---
*(source page 173)*

#### 6.7 Graphic Drawing Processor

ACRTC Graphic Drawing is performed in units of logical pixels which may be programmed to consist of 1, 2, 4, 8 or 16 physical bits in the frame buffer.

In order to draw, the ACRTC Drawing Processor uses three operation control units.

(a) Drawing Algorithm Control Unit
Interprets graphic commands and parameters and executes the appropriate microprogrammed drawing algorithm. Note that this unit calculates coordinates using logical pixel X-Y addressing.

(b) Drawing Address Generation Unit
Converts logical X-Y addresses from the DACU to a bit address in the frame buffer. The frame buffer is organized as sequential 16 bit words. The bit address consists of a 20 bit address (1M word address space) and 0-4 bits specifying the logical pixel bit address within the physical frame buffer word.

(c) Logic Operation Unit
Using the address calculated in (a) and (b), performs logical operations between the existing (read) data in the frame buffer and the drawing pattern in the Pattern RAM, and rewrites the results to the frame buffer.

*(Diagram: three boxes connected left to right — "Drawing Algorithm Control Unit" → "Drawing Address Generation Unit" → "Logic Operation Unit".)*

**Figure 6.13 Drawing Processor**

---
*(source page 174)*

**Figure 6.14(a) Bits per Pixel**

| Bit Mode | Data (bit) per pixel | Color or color image number | Number of pixels per word |
|---|---|---|---|
| 1 bit/pixel | 1 | 1 | 16 |
| 2 bit/pixel | 2 | 4 | 8 |
| 4 bit/pixel | 4 | 16 | 4 |
| 8 bit/pixel | 8 | 256 | 2 |
| 16 bit/pixel | 16 | 65536 | 1 |

---
*(source page 175)*

*(This page is landscape-oriented in the original, with the running head "164 HITACHI" printed sideways along the left edge.)*

**Figure 6.14(b) Pixel Physical Address Specification**

| Bit Mode | 1 Word Data Configuration (bit 15 - bit 0) | Linear Address / Dot Address (bit 23 - bit 0) | Operation Offset |
|---|---|---|---|
| 1 bit/pixel | 16 single-bit cells; "1 pixel data" arrow points at bit 0 (the rightmost cell) | bits 23-4 = memory address; bits 3-0 = dot address (all 4 bits significant) | 1 |
| 2 bit/pixel | 8 two-bit cells; "1 pixel data" arrow points at the rightmost 2-bit cell (bits 1-0) | bits 23-4 = memory address; bits 3-1 = dot address, bit 0 = don't care (*) | 2 |
| 4 bit/pixel | 4 four-bit cells; "1 pixel data" arrow points at the rightmost 4-bit cell (bits 3-0) | bits 23-4 = memory address; bits 3-2 = dot address, bits 1-0 = don't care (* *) | 4 |
| 8 bit/pixel | 2 eight-bit cells; "1 pixel data" arrow points at the rightmost 8-bit cell (bits 7-0) | bits 23-4 = memory address; bit 3 = dot address, bits 2-0 = don't care (* * *) | 8 |
| 16 bit/pixel | 1 sixteen-bit cell = "1 pixel data" (the whole word) | bits 23-4 = memory address; bits 3-0 = don't care (* * * *) (no dot address needed — one word is exactly one pixel) | 16 |

Note: `*` = don't care.

(For each bit mode, the "dot address" sub-field of the low-order linear-address bits selects which pixel-sized slice of the addressed 16-bit frame buffer word corresponds to the given logical pixel; as pixel size increases, fewer low-order bits are needed to select the slice, and the remainder are don't-care.)

---
*(source page 176)*

**Figure 6.14(c) Logical/Physical Addressing**

*(Diagram: five rows (a)-(e), each showing a "1 pixel data" field within a frame-buffer word (LSB at left, MSB at right, with the pixel field width MW marked), and lines fanning out to a stack of physical bit-plane squares on the right, each plane also marked width MW.)*

(a) 1 bit/pixel mode (GBM=000): the entire word is 1 pixel field of width MW (the whole word); maps to a single plane.

(b) 2 bit/pixel mode (GBM-001): pixel field of width MW (2 bits) maps to 2 planes.

(c) 4 bit/pixel mode (GBM=010): pixel field of width MW (4 bits) maps to 4 planes.

(d) 8 bit/pixel mode (GBM-011): pixel field of width MW (8 bits) maps to 8 planes.

(e) 16 bit/pixel mode (GBM=100): pixel field of width MW (16 bits, the whole word) maps to 16 planes.

In each case, the bits of the "1 pixel data" field (found at the low end of the frame buffer word) are individually routed, one bit per physical bit-plane, to the corresponding plane's frame buffer of width MW — i.e., in a multi-bit-per-pixel mode the pixel's bits are distributed one per plane rather than staying together in a single plane's word.

---
*(source page 177)*

#### 6.8 Graphic Drawing Operation

Since a logical pixel can consist of multiple bits of frame buffer, a logical pixel is said to contain color information. If a logical pixel is defined as 4 bits or frame buffer, 16 tones of gray scale or 16 colors can be associated with the logical pixel.

The ACRTC performs graphic drawing based on the unit of logical pixel including color information.

##### 6.8.1 Pattern RAM

The 16 by 16 bit Pattern RAM contains the color pattern for graphic drawing. A sub-pattern to be used can be specified by defining the Pattern Start X, Y and Pattern End X, Y addresses. Furthermore, a specific starting point for pattern scanning is defined with the Pattern Pointer X, Y addresses.

##### 6.8.2 One Pixel Drawing Operation

In this example, Color Regiser Indirect Drawing Mode is used.

Before the drawing color data. This data can be accessed by the MPU using the RPTN and WPTN (read and write Pattern RAM) commands. Also, the Drawing Parameter Registers must be initialized using the RPR and WPR (read and write Parameter Register) commands.

After the drawing command is issued, the ACRTC reads the 16 bit word in the frame buffer whose address was calculated by the Drawing Algorithm Control Unit (DACU) and Drawing Address Generation Unit (DAGU). Since the ACRTC reads 16 bit words from the frame buffer, in the case of 4 bits/logical pixel, 4 pixels are read at one time. However, the drawing is performed in units of one pixel. So, the ACRTC maintains an Internal Dot Pointer (IDP) which is used to mask the appropriate bits. In this example, the logical pixel is bits 4-7 of the word (Cc), so IDP contains is in bits 4-7 and 0s in other bits.

The IDP mask is also applied to the color registers to select one logical pixel (in this case 4 bits) of color information (C0 and C1).

Depending on the bit value in the Pattern RAM pointed to by Pattern Pointer X and Pattern Pointer Y, the color register is selected. If 0, Color Register 0 is used, if 1, Color Register 1 is used.

The fetched data (Cc) and selected color data (C0 and C1) are logically operated on based on 1 of 8 logical operation modes (OPM) specified with the drawing instruction. the resulting drawing data (Cy) is rewritten to the frame buffer.

---
*(source page 178)*

Color Register drawing normally specifies the 'background' color in CL0 and the 'foreground' or 'drawing' color in CL1. In this case, a dashed line can easily be drawn by loading the dash pattern (0's for OFF, 1s for ON) into the Pattern RAM.

Note in this example (4 bits/pixel) that the color values C0 and C1 are normally repeated in the other three 4 bit subfields of the color register so that as IDP varies, the same colors will be used. However, there is no restriction in this regard. Each of the four 4 bit logical pixel subfields of Color Register 0 and 1 could be loaded with a different color value. Thus, as IDP varies, different colors will be selected from CL0 and CL1.

*(Diagram: a "Pattern RAM" 16×16 grid addressed by PEY/PSY (rows) and PSX/PEX (columns, 0-15), with a dashed sub-window from (PSX,PSY) to (PEX,PEY) containing 8 sample rows of bit patterns (0010000, 010100, 100010, 111110, 100010, 100010, 100010, 000000 — 6-7 bits each as drawn). One row (111110) feeds into a 2:1 selector "x" with x=0 routing to "Color Register 0" and x=1 routing to "Color Register 1"; each Color Register is a 3-field word with its C0/C1 nibble hatched. A "DPD in DP" 4-bit field (shown as 1,0,*,*) selects which nibble of the Color Register feeds out. The selected Color Register nibble and the "Read Data" word (fields Ca, Cb, Cc, Cd — with Cc hatched, matching the DPD selection) both feed into the "Write Data" word (Ca, Cb, Cy, Cd — with Cy hatched), per the equations: Cy = f(C0, Cc) if x = 0; Cy = f(C1, Cc) if x = 1.)*

**Figure 6.15 One Pixel Drawing Operation**

---
*(source page 179)*

##### 6.8.3 Line Drawing Operation

The following describes an example of the LINE command using Color Register Indirect Drawing Mode and the 'Replace' operation mode.

For line drawing, the drawing pattern is limited to the 16 bit word pointed to by Pattern Pointer Y (PPY). A portion of the word can be extracted based on Pattern Start X and Pattern End X (PSX and PEX).

For the first pixel of the line, the Pattern RAM bit at PPX is used and Color Register 0 and 1 are selected based on this bits value. The selected color is drawn. Then the Pattern RAM pointer is incremented and operation continues until PPX = PEX. Then, PPX is reset to PSX and operation continues. Note that the Pattern RAM horizontal scanning direction is independent of pixel drawing direction.

The drawing pattern can be magnified using the Pattern Zoom Factor (PZX and PZY). For line drawing, only PZX is applicable. The example uses PZX = 0 which is 'by 1' magnification. If PZX = 1 (by 2 magnification) was specified, the selected portion of the Pattern RAM would have each bit scanned twice. Thus, the example '1111101010' pattern would be interpreted as '11111111100110011 00' during scanning.

##### 6.8.4 Plane Drawing Operation

Figure 6.17(b) shows a Plane drawing example which also uses Color Register Indirect Drawing Mode and Replace Operation Mode.

For plane drawing commands (AFRCT, RFRCT, PAINT and PTN) a two dimensional portion of the Pattern RAM bounded by PSX,PSY and PEX,PEY is used. Pattern scanning starts at PPX and PPY. As each pixel is drawn, the Pattern scanning point is incremented independent of pixel drawing direction. The two dimensional pattern can be independently magnified (i.e. each pattern point repeatedly scanned) in the X and Y directions using the Pattern Zoom Factor (PZX, PZY).

**Figure 6.16 Line and Plane Drawing Commands**

| Classification | Applicable Commands |
|---|---|
| Line drawing command | ALINE, RLINE, ARCT, RRCT, APLL, RPLL, APLG, RPLG, CRCL, ELPS, AARC, RARC, AEARC, REARC, DOT |
| Plane drawing command | AFRCT, RFRCT, PAINT, PTN |

---
*(source page 180)*

*(Diagram, left: a "Pattern RAM" square with PEY marking the top-right area and PSY marking a lower-left area on its left edge; inside, a dashed-outline row containing the bit pattern "1 1 1 1 1 0 1 0 1 0"; below the square, PSX and PEX mark column positions and an upward arrow labeled "Pattern Scan Start (PPX, PPY)" points into the row at the pattern's starting scan bit.)*

*(Diagram, right: an X-Y axis with a diagonal staircase of dots rising from a point labeled "Start" near the origin. The dots alternate between open circles (Color 0) and filled circles (Color 1), following the bit pattern from the Pattern RAM row (1=Color 1/filled, 0=Color 0/open, read in scan order): filled, filled, open, filled, open, open, open, filled, filled, filled, open, filled, filled, filled, filled — matching the drawn sequence of dots along the line from lower-left to upper-right.)*

Legend: ○ = Color 0, ● = Color 1.

**Figure 6.17(a) Line Drawing Example**

---
*(source page 170)*

**Figure 6.17(b) Plane Drawing Example**

*(Companion diagram to Fig 6.17(a), illustrating Plane Drawing rather than Line Drawing.)*

Left side — Pattern RAM diagram: a rectangular Pattern RAM block is addressed by inputs PEY (top, into the block) and PSY (lower left, into the block), with PSX and PEX entering from below. Inside the block, a dashed sub-rectangle marks the active pattern area, with its corners labeled (PEX, PEY) at the top right corner and (PSX, PSY) at the bottom left corner; the point (PPX, PPY) marks a position on the left edge of the dashed area. The Pattern RAM contents shown within the dashed area (7 rows × ~5-6 columns of bits) are:

| Row | Bit pattern |
|---|---|
| 1 | 0 0 1 0 0 0 |
| 2 | 0 1 0 1 0 0 |
| 3 | 1 0 0 0 1 0 |
| 4 | 1 0 0 0 1 0 |
| 5 | 0 1 0 1 0 0 |
| 6 | 0 0 1 0 0 0 |
| 7 | 0 0 0 0 0 0 |

Right side — a rectangular dot grid (rows of circles) plotted against X (horizontal) and Y (vertical) axes, with drawing starting at "Start" (bottom left) and proceeding to the right and upward, dashed lines continuing off the right edge of the grid indicating the pattern repeats/continues. Each dot is either open (○, Color 0) or filled (●, Color 1); the filled dots reproduce the same diagonal/checkerboard-like pattern shown in the Pattern RAM excerpt at left, tiled across the plane. Legend: ○ = Color 0, ● = Color 1.


---
*(source page 171)*

*(Chapter divider page. The page contains only a centered chapter title, no other text or figures, and no footer.)*

# FUNCTION OF COMMANDS


---
*(source page 172)*

*(Blank page — the verso of the "FUNCTION OF COMMANDS" chapter-divider page. No visible text, figures, or footer.)*


---
*(source page 173)*

*(Landscape-oriented page; running head "COMMANDS" reads sideways along the right margin. This page reprints, without its own figure caption, the same full command summary table given earlier as Figure 6.1 (Command Set) on page 135 — here serving as the lead-in reference table for the individual per-command description chapter that follows.)*

| TYPE | MNEMONIC | COMMAND NAME | OPERATION CODE | PARAMETER | # (words) | ~ (cycles) |
|---|---|---|---|---|---|---|
| Register Access Command | ORG | Origin | 0000 0100 0000 0000 | DPH DPL | 3 | 8 |
| | WPR | Write Parameter Register | 0000 1000 0000 RN | D | 2 | 6 |
| | RPR | Read Parameter Register | 0000 1100 0000 RN | | 1 | 6 |
| | WPTN | Write Pattern RAM | 0001 1000 0000 0000 PRA | n D1,...,Dn | n+2 | 4n+8 |
| | RPTN | Read Pattern RAM | 0001 1100 0000 0000 PRA | n | 2 | 4n+10 |
| Data Transfer Command | DRD | DMA Read | 0010 0100 0000 0000 0000 | AX AY | 3 | (4x+8)y+12[x·y/8↑]+(62~68) |
| | DWT | DMA Write | 0010 1000 0000 0000 0000 | AX AY | 3 | (4x+8)y+16[x·y/8↑]+34 |
| | DMOD | DMA Modify | 0010 1100 0000 0000 00 MM | AX AY | 3 | (4x+8)y+16[x·y/8↑]+34 |
| | RD | Read | 0100 0100 0000 0000 0000 | | 1 | 12 |
| | WT | Write | 0100 1000 0000 0000 0000 | D | 2 | 8 |
| | MOD | Modify | 0100 1100 0000 0000 00 MM | D | 2 | 8 |
| | CLR | Clear | 0101 0000 0000 0000 0000 | D AX AY | 4 | (2x+8)y+12 |
| | SCLR | Selective Clear | 0101 1100 0000 0000 0 MM | D AX AY | 4 | (4x+6)y+12 |
| | CPY | Copy | 0110 S DSD 0000 0000 | SAH SAL AX AY | 5 | (6x+10)y+12 |
| | SCPY | Selective Copy | 0111 S DSD 0000 00 MM | SAH SAL AX AY | 5 | (6x+10)y+12 |
| Graphic Command | AMOVE | Absolute Move | 1000 0000 0000 0000 0000 | X Y | 3 | 56 |
| | RMOVE | Relative Move | 1000 0100 0000 0000 0000 | dX dY | 3 | 56 |
| | ALINE | Absolute Line | 1000 1000 AREA COL OPM | X Y | 3 | P·L+18 |
| | RLINE | Relative Line | 1000 1100 AREA COL OPM | dX dY | 3 | P·L+18 |
| | ARCT | Absolute Rectangle | 1001 0000 AREA COL OPM | X Y | 3 | 2P(A+B)+54 |
| | RRCT | Relative Rectangle | 1001 0100 AREA COL OPM | dX dY | 3 | 2P(A+B)+54 |
| | APLL | Absolute Polyline | 1001 1000 AREA COL OPM | n X1,Y1,..Xn,Yn | 2n+2 | Σ[P·L+16]+8 |
| | RPLL | Relative Polyline | 1001 1100 AREA COL OPM | n dX1,dY1,..dXn,dYn | 2n+2 | Σ[P·L+16]+8 |
| | APLG | Absolute Polygon | 1010 0000 AREA COL OPM | n X1,Y1,..Xn,Yn | 2n+2 | Σ[P·L+16]+P·Lo+20 |
| | RPLG | Relative Polygon | 1010 0100 AREA COL OPM | n dX1,dY1,..dXn,dYn | 2n+2 | Σ[P·L+16]+P·Lo+20 |
| | CRCL | Circle | 1010 1000 C AREA COL OPM | r | 2 | 8d+66 |
| | ELPS | Ellipse | 1010 1100 C AREA COL OPM | a b dX | 4 | 10d+90 |
| | AARC | Absolute Arc | 1011 0000 C AREA COL OPM | Xc Yc Xe Ye | 5 | 8d+18 |
| | RARC | Relative Arc | 1011 0100 C AREA COL OPM | dXc dYc dXe dYe | 5 | 8d+18 |
| | AEARC | Absolute Ellipse Arc | 1011 1000 C AREA COL OPM | a b Xc Yc Xe Ye | 7 | 10d+96 |
| | REARC | Relative Ellipse Arc | 1011 1100 C AREA COL OPM | a b dXc dYc dXe dYe | 7 | 10d+96 |
| | AFRCT | Absolute Filled Rectangle | 1100 0000 AREA COL OPM | X Y | 3 | (P·A+B)B+18 |
| | RFRCT | Relative Filled Rectangle | 1100 0100 AREA COL OPM | dX dY | 3 | (P·A+B)B+18 |
| | PAINT | Paint | 1100 100 E AREA COL OPM | | 1 | (18A+102)B-58 *1) |
| | DOT | Dot | 1100 1100 AREA COL OPM | | 1 | 8 |
| | PTN | Pattern | 1101 SL SD AREA COL OPM | SZ | 2 | (P·A+10)B+20 *2) |
| | AGCPY | Absolute Graphic Copy | 1110 S DSD AREA 00 OPM | Xs Ys DX DY | 5 | ((P+2)A+10)B+70 |
| | RGCPY | Relative Graphic Copy | 1111 S DSD AREA 00 OPM | dXs dYs DX DY | 5 | ((P+2)A+10)B+70 |

\*1) In case of rectangular filling

\*2) SZ: [SZy (bits 15-8) | SZx (bits 7-0)]  SZy, SZx: Pattern Size

n: number of repetition  x/y: drawing words of x-direction/y-direction  L/Lo/d: sum of drawing dots  A/B: drawing dots of main/sub direction  P = {4: OPM-000~011, 6: OPM-100~111}

E: [E=0 (stop at Edge color), E=1 (stop at excepting Edge color)]  C: [C=1 (clock wise), C=0 (reverse)]  [↑]: rounding up


---
*(source page 174)*

*(First page of the individual command reference section. Each command is documented in this same tabular layout — header block with FUNCTION/MNEMONIC and a FORMAT block on the left, TYPE/WORD NUMBER/EXECUTION CYCLES on the right, and a DESCRIPTION section below — repeated once per command through the remainder of this chapter. The running header box in the top right of the page shows the command mnemonic; here: "ORG".)*

### [1] ORG (Origin)

PAGE: ORG-1

**\<FUNCTION\>**

Associates a logical X-Y screen origin with a physical frame buffer address.

**\<MNEMONIC\>**

ORG DPH,DPL

TYPE: Register Access Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0100 | 0000 | 0000 |

(\$0400)

COMMAND PARAMETERS:

| DPH (bits 15-0) |
|---|
| DPH |

| DPL (bits 15-0) |
|---|
| DPL |

WORD NUMBER: Wn = 3

EXECUTION CYCLES: Cn = 8

**\<DESCRIPTION\>**

The ORG command must be issued to the ACRTC prior to graphic drawing. ORG defines the logical X-Y coordinate origin upon which all graphic drawing addresses are based and sets the screen number in which to draw.

The DPH and DPL (Drawing Pointer High, Low) parameters establish the physical address in the frame buffer at which the origin is set. This physical address is composed of the following three components — DN (Screen Number) is a screen designator, DPAH, DPAL (Drawing Pointer Address High, Low) is a 20 bit address selecting one of 1 megawords in the frame buffer and DPD (Drawing Pointer Dot) specifies the bit field associated with the addressed logical pixel.

The ORG command initializes the Drawing Pointer (DP) to the origin and clears the Current Pointer (CP).


---
*(source page 175)*

### ORG (Origin) — continued

PAGE: ORG-2

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

DP (Drawing Pointer) address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | 0~0 | DPAH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| DPAL (12 bits) | DPD (4 bits) |

which together form (‖):

| DPH (16 bits) |
|---|

| DPL (16 bits) |
|---|

- The origin address of the X-Y coordinates is set with the 20-bit linear address using to DPAH and DPAL.
- DPD determines the dot position in 16-bit data addressed by DPAH/DPAL.
- DN sets screen number for drawing.

**Figure C1-1 ORG**


---
*(source page 176)*

### ORG (Origin) — continued

PAGE: ORG-3

**\<EXAMPLE\>**

The origin for the Upper screen (screen number 0) is set to bit position 4-7 at frame buffer word address \$25. 4 bits per logical pixel and Memory Width (MW) = \$10 are assumed.

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0100 | 0000 | 0000 |

(\$0400)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0010 | 0101 | 0100 |

(\$0254)

*(Below the parameter fields, a ruled hexadecimal-coordinate grid diagram illustrates the resulting origin: a horizontal axis labeled 0 through F across the top with row labels 0-5 down the left side; an X-Y crosshair is drawn with its origin marked at column 6, row 0 — labeled "ORG(0,0)" — with the +Y axis pointing up, -Y pointing down, +X pointing right, and -X pointing left from that origin point.)*

**Figure C1-2 ORG Execution Example**


---
*(source page 177)*

### [2] WPR (Write Parameter Register)

PAGE: WPR-1

**\<FUNCTION\>**

Write the contents of the Drawing Parameter Registers.

**\<MNEMONIC\>**

WPR (RN) D

TYPE: Register Access Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-5 | 4-0 |
|---|---|---|---|
| 0000 | 1000 | 000 | RN (5 bits) |

(\$080X)

COMMAND PARAMETERS:

| D (Data), bits 15-0 |
|---|

WORD NUMBER: Wn = 2

EXECUTION CYCLES: Cn = 6

**\<DESCRIPTION\>**

The Drawing Parameter Register number to be written is specified in the RN (Register Number) field of the op-code. The contents of the parameter (D) is written to the selected register.


---
*(source page 178)*

### WPR (Write Parameter Register) — continued

PAGE: WPR-2

**\<EXAMPLE\>**

The value \$1111 is written to the CL1 (Color 1) of the drawing parameter register.

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 1000 | 0000 | 0001 |

(\$0801)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 0001 | 0001 | 0001 |

(\$1111)

\<Color Register\> RN = 01

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 0001 | 0001 | 0001 |

**Figure C2-1 WPR Execution Example**


---
*(source page 179)*

### [3] RPR (Read Parameter Register)

PAGE: RPR-1

**\<FUNCTION\>**

Read the contents of the Drawing Parameter Registers.

**\<MNEMONIC\>**

RPR (RN)

TYPE: Register Access Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-5 | 4-0 |
|---|---|---|---|
| 0000 | 1100 | 000 | RN (5 bits) |

(\$0C0X)

COMMAND PARAMETERS:

— NON —

WORD NUMBER: Wn = 1

EXECUTION CYCLES: Cn = 6

**\<DESCRIPTION\>**

The Drawing Parameter Register number to be read is specified in the RN (Register Number) field of the command code. After execution, the contents of the specified Drawing Parameter Register is loaded into the Read FIFO.


---
*(source page 180)*

### RPR (Read Parameter Register) — continued

PAGE: RPR-2

**\<EXAMPLE\>**

The value \$1111 in the Drawing Parameter Register (Color Register 1: CL1) is loaded into the Read FIFO.

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 1100 | 0000 | 0001 |

(\$0C01)

COMMAND PARAMETER:

— NON —

\<Color Register 1\>:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 0001 | 0001 | 0001 |

\<Read FIFO\>:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 0001 | 0001 | 0001 |

**Figure C3-1 RPR Execution Example**


---
*(source page 181)*

### [4] WPTN (Write Pattern RAM)

PAGE: WPTN-1

**\<FUNCTION\>**

Write data to the Pattern RAM.

**\<MNEMONIC\>**

WPTN (PRA) n, D1, D2, ... Dn

TYPE: Register Access Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 1000 | 0000 | PRA |

(\$180X)

COMMAND PARAMETERS:

| n (Number of Words), bits 15-0 |
|---|

| D1 (Pattern Data), bits 15-0 |
|---|

⋮

| Dn (Pattern Data), bits 15-0 |
|---|

WORD NUMBER: Wn = n+2

EXECUTION CYCLES: Cn = 4n+8

**\<DESCRIPTION\>**

WPTN command is used to write data into the Pattern RAM.

Pattern RAM Address (PRA) of \$0~\$F is allocated to the Pattern RAM and each PRA represents 1 word (16 bits) of pattern RAM.

The PRA (Pattern RAM Address) field of the command code selects the Pattern RAM word address at which writing starts. The first parameter is n, the number of words to be written. This is followed by n data words (D1-Dn).

For the 8-bit interface, 1 word is divided into high and low bytes. The pattern data is sent in the order of the high byte, then the low byte. The first parameter n must be set to (the number of words) × 2. (In this case writing in unit of byte is not allowed.)


---
*(source page 182)*

### WPTN (Write Pattern RAM) — continued

PAGE: WPTN-2

**\<EXAMPLE\>**

Two words of data, \$2314 and \$5713, are written to the Pattern RAM beginning at address \$B.

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 1000 | 0000 | 1011 |

(\$180B)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0010 |

(\$0002)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0010 | 0011 | 0001 | 0100 |

(\$2314)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0101 | 0111 | 0001 | 0011 |

(\$5713)

*(Below the parameter fields, a diagram shows the Pattern RAM as a square grid: the vertical axis is labeled "Address" (0 at bottom to 15 at top) and the horizontal axis is labeled "bit ~" (0 at left, 15 at right), with "LSB" marked at the bottom-left corner and "MSB" at the bottom-right corner. A callout expands the bottom-right region of the grid (addresses 10-15) into a detailed bit-level table, populated MSB-to-LSB with the two written data words split across nibble columns, arranged right-to-left as: "1 1 0 0", "1 0 0 0", "1 1 1 0", "1 0 1 0" in row "12", and "0 0 1 0", "1 0 0 0", "1 1 0 0", "0 1 0 0" in row "11" — reflecting the hex digits of \$2314 and \$5713 written into the RAM starting at address \$B, with an arrow beneath pointing left to indicate the MSB→LSB fill direction.)*

**Figure C4-1 WPTN Execution Example**


---
*(source page 183)*

### [5] RPTN (Read Pattern RAM)

PAGE: RPTN-1

**\<FUNCTION\>**

Read Data from the Pattern RAM.

**\<MNEMONIC\>**

RPTN (PRA) n

TYPE: Register Access Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 1100 | 0000 | PRA |

(\$1C0X)

COMMAND PARAMETERS:

| n (Number of word), bits 15-0 |
|---|

WORD NUMBER: Wn = 2

EXECUTION CYCLES: Cn = 4n+10

**\<DESCRIPTION\>**

RPTN command is used to read the data in the Pattern RAM.

Pattern RAM address (PRA) of \$0~\$F is allocated to the Pattern RAM and each PRA represents 1 word (16 bits) of Pattern RAM.

The PRA (Pattern RAM Address) field of the command code select the Pattern RAM word address at which reading starts. The parameter n specifies the number of words to be read. The specified Pattern RAM contents are loaded into the Read FIFO.

For the 8 bit interface, 1 word of the pattern RAM is divided into high and the low bytes. The pattern data is put into the Read FIFO in the order of the high byte, the low byte.


---
*(source page 184)*

### RPTN (Read Pattern RAM) — continued

PAGE: RPTN-2

**\<EXAMPLE\>**

Two words of data, \$2314 and \$5713 from the Pattern RAM beginning from address \$B is placed in the Read FIFO.

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 1100 | 0000 | 1011 |

(\$1C0B)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0010 |

(\$0002)

*(Below the parameter fields, the same Pattern RAM grid diagram as Fig C4-1 (Address 0-15 vertical, bit 0-15 horizontal, LSB at bottom-left, MSB at bottom-right) with a callout expanding addresses 10-15 into a detailed bit table populated with the same nibble values as before — row "12": "1 1 0 0", "1 0 0 0", "1 1 1 0", "1 0 1 0"; row "11": "0 0 1 0", "1 0 0 0", "1 1 0 0", "0 1 0 0" — representing \$2314 and \$5713 stored starting at address \$B.)*

Read FIFO:

| 2 | 3 | 1 | 4 |
|---|---|---|---|
| 5 | 7 | 1 | 3 |

**Figure C5-1 RPTN Execution Example**


---
*(source page 185)*

### [6] DRD (DMA Read)

PAGE: DRD-1

**\<FUNCTION\>**

Transfer data from the frame buffer to the MPU system memory.

**\<MNEMONIC\>**

DRD AX, AY

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0010 | 0100 | 0000 | 0000 |

(\$2400)

COMMAND PARAMETERS:

| AX, bits 15-0 |
|---|

| AY, bits 15-0 |
|---|

WORD NUMBER: Wn = 3

EXECUTION CYCLES: Cn = (4x+8)y+12⌈xy/8⌉ + (62~68)

where x = |AX| + 1, y = |AY| + 1

**\<DESCRIPTION\>**

DRD command causes the ACRTC to enter DMA Data Transfer Mode in which the ACRTC will control the external DMAC to transfer data (in unit of words) from the rectangular area in the frame buffer to the MPU memory. The frame buffer data origin must be predefined in the Read Write Pointer (RWP). The parameters of the command define the frame buffer area to be read in units of physical frame buffer words. At the end of DRD command execution, RWP will be set to RWPe.


---
*(source page 186)*

### DRD (DMA Read) — continued

PAGE: DRD-2

*(Block diagram showing data flow for the DRD command: a "CPU Memory" block (drawn as a wavy-edged strip of memory with a hatched target region) on the left, connected by a curved arrow to a "Read FIFO" box inside an "ACRTC" block in the middle, which is connected by a curved arrow to a "Frame Buffer" block on the right. The Frame Buffer block shows a hatched rectangular region labeled with RWP at its bottom-left corner (start point), RWPe at its top-right corner (end point), and dimensions AX+1 (horizontal) and AY+1 (vertical) marking the read area.)*

\* If minus values are set in AX and AY, the read direction becomes negative.

**\<NOTE\>**

The status of the ACRTC Read FIFO should be checked to insure the Read FIFO is empty before the DRD command is issued. If any data is in the Read FIFO before the DRD command issued, that data is read out incorrectly by the DMAC as the first data of the DRD command.

Reading direction:

(1) X:+, Y:+ — *(diagram: two horizontal arrows pointing right, one above the other, with a vertical dashed arrow pointing up between/above them)*

(2) X:+, Y:− — *(diagram: two horizontal arrows pointing right, with a vertical dashed arrow pointing down)*

(3) X:−, Y:+ — *(diagram: two horizontal arrows pointing left, with a vertical dashed arrow pointing up)*

(4) X:−, Y:− — *(diagram: two horizontal arrows pointing left, with a vertical dashed arrow pointing down)*


---
*(source page 187)*

### [7] DWT (DMA Write)

PAGE: DWT-1

**\<FUNCTION\>**

Transfer data from the MPU system memory to the frame buffer.

**\<MNEMONIC\>**

DWT AX, AY

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0010 | 1000 | 0000 | 0000 |

(\$2800)

COMMAND PARAMETERS:

| AX, bits 15-0 |
|---|

| AY, bits 15-0 |
|---|

WORD NUMBER: Wn = 3

EXECUTION CYCLES: Cn = (4x+8)y+16⌈xy/8⌉ + 34

where x = |AX| + 1, y = |AY| + 1

**\<DESCRIPTION\>**

DWT command causes the ACRTC to enter DMA Data Transfer Mode in which the ACRTC will control the external DMAC to transfer data (in unit of words) from the MPU memory to the rectangular area in the frame buffer. The frame buffer data origin must be predefined in the Read Write Pointer (RWP). The parameters of the command (AX, AY) define the frame buffer area to be written in units of physical frame buffer words. At the end of DWT command execution, RWP will be set to RWPe.


---
*(source page 188)*

### DWT (DMA Write) — continued

PAGE: DWT-2

*(Block diagram showing data flow for the DWT command: a "System Memory" block (wavy-edged strip with a hatched source region) on the left, connected by a curved arrow to a "Write FIFO" box inside an "ACRTC" block in the middle, which is connected by a curved arrow to a "Frame Buffer" block on the right. The Frame Buffer block shows a hatched rectangular region with an internal arrow indicating fill direction, labeled with RWP at its bottom-left corner (start point), RWPe at its top-right corner (end point), and dimensions AX+1 (horizontal) and AY+1 (vertical) marking the write area.)*

\* For AX and AY, negative value can also be set.

**\<NOTE\>**

After DWT is issued, no further commands should be issued until the DMA data is transferred and the DWT command terminates.

Writing direction:

(1) X:+, Y:+ — *(diagram: two horizontal arrows pointing right, with a vertical dashed arrow pointing up)*

(2) X:+, Y:− — *(diagram: two horizontal arrows pointing right, with a vertical dashed arrow pointing down)*

(3) X:−, Y:+ — *(diagram: two horizontal arrows pointing left, with a vertical dashed arrow pointing up)*

(4) X:−, Y:− — *(diagram: two horizontal arrows pointing left, with a vertical dashed arrow pointing down)*


---
*(source page 189)*

### [8] DMOD (DMA Modify)

PAGE: DMOD-1

**\<FUNCTION\>**

Transfer data from the MPU system memory to the frame buffer subject to logical modification.

**\<MNEMONIC\>**

DMOD (MM) AX, AY

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-2 | 1-0 |
|---|---|---|---|
| 0010 | 1100 | 000000 | MM |

(\$2C0X)

COMMAND PARAMETERS:

| AX, bits 15-0 |
|---|

| AY, bits 15-0 |
|---|

WORD NUMBER: Wn = 3

EXECUTION CYCLES: Cn = (4x+8)y+16⌈xy/8⌉ + 34

where x = |AX| + 1, y = |AY| + 1

**\<DESCRIPTION\>**

DMOD causes the ACRTC to enter DMA Data Transfer Mode in which the ACRTC will control the external DMAC to modify data in the rectangular area in the frame buffer using data in the MPU memory (in unit of words). The frame buffer data origin must be predefined in the Read Write Pointer (RWP). The parameters of the command (AX, AY) define the frame buffer area to be written in units of physical frame buffer words. At the end of DMOD command execution, RWP will be set to RWPe.

The MM (Modify Mode) field of the command code specifies the DMA data transfer modify mode. Each pixel transferred from MPU system memory is logically operated on the corresponding pixel from the frame buffer, and the result is rewritten to the frame buffer. Logic operation can be enabled and disabled on a bit by bit basis based on the contents of the MASK register.


---
*(source page 190)*

### DMOD (DMA Modify) — continued

PAGE: DMOD-2

*(Block diagram showing data flow for the DMOD command: a "System Memory" block (wavy-edged strip with a hatched source region) on the left, connected by a curved arrow to a "Write FIFO" box inside an "ACRTC" block in the middle. Within the ACRTC block, the Write FIFO feeds into a "BMLU" (Bit Manipulation Logic Unit) box, which also receives input from a "Mask" box above it; the BMLU output is connected by a curved arrow to a "Frame Buffer" block on the right. The Frame Buffer block shows a hatched rectangular region with an internal arrow indicating fill direction, labeled with RWP at its bottom-left corner (start point), RWPe at its top-right corner (end point), and dimensions AX+1 (horizontal) and AY+1 (vertical) marking the modify area.)*

**\<NOTE\>**

Afrer [sic, "After"] DMOD is issued, no further commands should be issued until the DMA data is transferred and the DMOD command terminates.


---
*(source page 191)*

### [9] RD (Read)

PAGE: RD-1

**\<FUNCTION\>**

Read one word of data from the frame buffer and load the word into Read FIFO.

**\<MNEMONIC\>**

RD

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0100 | 0100 | 0000 | 0000 |

(\$4400)

COMMAND PARAMETER:

— NON —

WORD NUMBER: Wn = 1

EXECUTION CYCLES: Cn = 12

**\<DESCRIPTION\>**

RD reads one word (16 bits) of data from the frame buffer. The frame buffer address to be read must be predefined in the Read Write Pointer (RWP) before the RD command is issued. The results are loaded into the Read FIFO.

The result may be read from the Read FIFO by the MPU anytime after the RD command is issued. If the Read FIFO is full when the command is executed, the ACRTC will enter a wait state until space becomes available in the Read FIFO.

At the end of the RD command execution, the ACRTC increments RWP by one.


---
*(source page 192)*

### RD (Read) — continued

PAGE: RD-2

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

RWP (Read Write Pointer) address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | (hatched, unused) | RWPH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| RWPL (12 bits) | (hatched, unused) |

which together form (‖):

| DATA H (16 bits) |
|---|

| DATA L (16 bits) |
|---|

- RWPH and RWPL specifies the frame buffer address by setting the linear address of 20 bits.
- DN specifies screen numbers.

**Figure C9-1 RWP Set**

**\<EXAMPLE\>**

Read the frame buffer data, \$5555, at physical address \$56 in screen 0 (upper screen). For this example, Memory Width (MW) is assumed to be \$10.

RWP:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0101 | 0110 | 0000 |

(\$0560)

**Figure C9-2 Example of RWP Setting**

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0100 | 0100 | 0000 | 0000 |

(\$4400)

COMMAND PARAMETERS:

— NON —


---
*(source page 193)*

### RD (Read) — continued

PAGE: RD-3

Screen: 00

*(A hexadecimal-column ruler labeled 0 through F runs across the top, with row labels 0-A down the left side. An arrow drops from column "6" down to a small two-cell strip in row "5": the left cell is hatched and labeled "RWP (address \$56)"; the adjacent unhatched cell is labeled "RWPe (after execution)" — indicating the pointer address before and after the RD command executes.)*

Frame buffer data (below the RWP cell, an arrow points down to a 4-nibble row):

| 0101 | 0101 | 0101 | 0101 |
|---|---|---|---|

(\$5555)

*(A large downward block arrow leads from the frame buffer data row to the Read FIFO below.)*

Read FIFO, bits 15-0:

| 0101 0101 0101 0101 |
|---|

(\$5555)

B → (points to this word, the Bottom/most-recently-loaded entry of the FIFO)
T → (points below it, marking the Top/next-to-be-read position, currently empty)

**Figure C9-3 RD Execution Example**


---
*(source page 194)*

### [10] WT (Write)

PAGE: WT-1

**\<FUNCTION\>**

Write one word of data to the frame buffer.

**\<MNEMONIC\>**

WT D

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0100 | 1000 | 0000 | 0000 |

(\$4800)

COMMAND PARAMETERS:

| D (16 bits) |
|---|

WORD NUMBER: Wn = 2

EXECUTION CYCLES: Cn = 8

**\<DESCRIPTION\>**

WT writes one word (16 bits) of data to the frame buffer. The frame buffer address to be written must be predefined in the Read Write Pointer (RWP) before the WT command is issued. The command parameter (D) is the data to be written.

At the end of the WT command execution, the ACRTC increments the RWP by one.


---
*(source page 195)*

### WT (Write) — continued

PAGE: WT-2

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

RWP address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | (hatched, unused) | RWPH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| RWPL (12 bits) | (hatched, unused) |

which together form (‖):

| DATA H (16 bits) |
|---|

| DATA L (16 bits) |
|---|

- The frame memory is a 20-bit linear address separated into highorder RWPH (8 bits) and loworder RWPL (12 bits).
- Specify the Screen No. where drawing is executed.

**Figure C10-1 RWP Set**

**\<EXAMPLE\>**

Write the 16-bit data word \$5555 to frame buffer address \$56 on screen 0 (upper screen). For this example, Memory Width (MW) is assumed to be \$10.

RWP:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0101 | 0110 | 0000 |

(\$0560)

**Figure C10-2 Example of RWP Setting**

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0100 | 1000 | 0000 | 0000 |

(\$4800)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0101 | 0101 | 0101 | 0101 |

(\$5555)


---
*(source page 196)*

### WT (Write) — continued

PAGE: WT-3

*(A hexadecimal-column ruler labeled 0 through F runs across the top, with row labels 0-A down the left side. An arrow drops from column "6" down to a small two-cell strip in row "5": the left cell is hatched and labeled "RWP (Address 56)"; the adjacent unhatched cell is labeled "RWPe (after execution)". Below the RWP cell, an upward arrow feeds in the data word to be written:)*

| 0101 0101 0101 0101 |
|---|

(\$5555)

**Figure C10-3 WT Execution Example**


---
*(source page 197)*

### [11] MOD (Modify)

PAGE: MOD-1

**\<FUNCTION\>**

Perform logical operation on one word in the frame buffer.

**\<MNEMONIC\>**

MOD (MM) D

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-2 | 1-0 |
|---|---|---|---|
| 0100 | 1100 | 000000 | MM |

(\$4C0X)

COMMAND PARAMETER:

| D (16 bits) |
|---|

WORD NUMBER: Wn = 2

EXECUTION CYCLES: Cn = 8

**\<DESCRIPTION\>**

The MM (Modify Mode) field of the command code specifies the data transfer modify mode. This command performs logical operation on one word in the frame buffer with the data given the parameter and writes the result back in the frame buffer. The frame buffer word address to be modified must be predefined in the Read Write Pointer (RWP).

The word is read from the frame buffer, then the logical operation defined by MM is performed between the data read from the frame buffer and the command parameter (D) for those bits not masked in the MASK register, and the result is rewritten to the frame buffer.

At the end of the MOD command execution, the ACRTC increments the RWP by one.


---
*(source page 198)*

### MOD (Modify) — continued

PAGE: MOD-2

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

RWP address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | (hatched, unused) | RWPH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| RWPL (12 bits) | (hatched, unused) |

- The frame buffer 20-bit linear address is separated into high order RWPH (8 bits) and loworder RWPL (12 bits).
- Specify the Screen No. where drawing is executed.

**Figure C11-1 RWP Set**

**\<EXAMPLE\>**

OR all bits of the frame buffer word at physical address \$56 with the 16-bit data word \$AAAA. MM = 01 specifies OR modify mode. All bits are selected for logical operation by assuming the MASK register to \$FFFF. For this example, Memory Width (MW) is assumed to be \$10.


---
*(source page 199)*

### MOD (Modify) — continued

PAGE: MOD-3

**\<EXECUTION EXAMPLE\>**

RWP:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0101 | 0110 | 0000 |

(\$0560)

MASK:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 1111 | 1111 | 1111 | 1111 |

(\$FFFF)

**Figure C11-2 Examples of RWP and MASK Setting**

COMMAND CODE:

| 15-12 | 11-8 | 7-2 | 1-0 |
|---|---|---|---|
| 0100 | 1100 | 000000 | 01 |

(\$4C01)

COMMAND PARAMETER:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 1010 | 1010 | 1010 | 1010 |

(\$AAAA)


---
*(source page 200)*

### MOD (Modify) — continued

PAGE: MOD-4

**(A) MOD Command Read Cycle**

*(A hexadecimal-column ruler labeled 0 through F runs across the top, rows 0-6 down the left side. An arrow drops from column "6" to a hatched cell in row "5" labeled "RWP". A diagonal arrow rises from that cell to a 4-nibble row above it:)*

| 0101 | 0101 | 0101 | 0101 |
|---|---|---|---|

(\$5555)

**(B) MOD Command Write Cycle**

*(The same hexadecimal-column ruler and row layout, rows 1-6. An arrow drops from column "6" to a hatched cell in row "5" labeled with a diagonal arrow rising to a 4-nibble row above it:)*

| 1111 | 1111 | 1111 | 1111 |
|---|---|---|---|

(\$FFFF)

*(An adjacent unhatched cell to the right of the hatched "5" row cell is labeled "RWPe (After execution)".)*

**Figure C11-3 MOD Execution Example**


---
*(source page 201)*

### [12] CLR (Clear)

PAGE: CLR-1

**\<FUNCTION\>**

Initialize a frame buffer area with a data in the command parameter.

**\<MNEMONIC\>**

CLR D, AX, AY

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0101 | 1000 | 0000 | 0000 |

(\$5800)

COMMAND PARAMETERS:

| D (16 bits) |
|---|

| AX (16 bits) |
|---|

| AY (16 bits) |
|---|

WORD NUMBER: Wn = 4

EXECUTION CYCLES: Cn = (2x+8)y+12

where x = |AX| + 1, y = |AY| + 1

**\<DESCRIPTION\>**

The frame buffer area defined by the physical origin (RWP) and physical frame buffer word address (AX and AY) parameters is filled with the data parameter (D).

Since the ACRTC performs the clear using 16 bit words, multiple logical pixels (if 4 bits/pixel then 4 pixels) are cleared in one access. D is normally specified to contain multiple copies (if 4 bits/pixel then 4 copies) of the color information for a single color clear.

At the end of CLR command execution, RWP will be set to RWPe.


---
*(source page 202)*

### CLR (Clear) — continued

PAGE: CLR-2

*(Diagram with X-Y axes: a rectangle spans from the Y-axis origin to a point labeled (AX, AY) at its top-right corner, with AY+1 marking its height and AX+1 marking its width. A small notch cut into the bottom-left corner of the rectangle is labeled "RWP" — the starting point of the clear area, offset from the true origin.)*

AX: 2nd parameter
AY: 3rd parameter
(4-bits/pixel)

*(A downward double-arrow leads to a second, similar rectangle below, where the notch is now labeled "RWPe" at the top-left and "RWP" again at the bottom-left, illustrating the pointer's start and end positions after the clear completes.)*

RWP is set with a 2-word (32-bit) data, as shown in Fig. C12-1.

The RWP needs to be specified in advance as follows.


---
*(source page 203)*

### CLR (Clear) — continued

PAGE: CLR-3

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

RWP address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | (hatched, unused) | RWPH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| RWPL (12 bits) | (hatched, unused) |

- The frame buffer 20-bit linear address is separated into high order RWPH (8 bits) and low order RWPL (12 bits).
- Specify the Screen No. where drawing is executed.

**Figure C12-1 RWP Set**

**\<EXAMPLE\>**

For this example 4 bits per logical pixel is used, the Memory Width (MW) is \$10 and the clear operation is to start at address \$56 on screen 0.

RWP:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0101 | 0110 | 0000 |

(\$0560)

**Figure C12-2 Example of RWP Setting**

COMMAND CODE:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0101 | 1000 | 0000 | 0000 |

(\$5800)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 0001 | 0001 | 0001 |

(\$1111)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 1111 | 1111 | 1111 | 1100 |

(\$FFFC)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 1111 | 1111 | 1111 | 1010 |

(\$FFFA)


---
*(source page 204)*

### CLR (Clear) — continued

PAGE: CLR-4

Legend: | 0001 | = Clear data (pixel)

*(A hexadecimal-column ruler labeled 0 through E runs across the top, with row labels 0-B down the left side. Starting at row 5, column 2, a rectangular block of memory cells is filled with the repeating pattern "0001 0001 0001 0001 0001..." (the clear data) across 7 rows (5 through B) and, in the top row (5), a bracketed span of "5 words" from column 2 to column 6, labeled "RWP (Address \$56)" at its right edge. The full bracketed height of the block, from row 5 to row B, is labeled "7 words". At the bottom-left of the filled block (row B, column 2) a callout marks "Pc (address \$B2)", and at the bottom-right (row B, column 6-7) an arrow points to a cell labeled "RWPe (Address \$B6)".)*

**Figure C12-3 CLR Execution Example**


---
*(source page 205)*

### [13] SCLR (Selective Clear)

PAGE: SCLR-1

**\<FUNCTION\>**

Initialize a frame buffer area with a constant value subject to logical modification.

**\<MNEMONIC\>**

SCLR (MM) D, AX, AY

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11-8 | 7-2 | 1-0 |
|---|---|---|---|
| 0101 | 1100 | 000000 | MM |

(\$5C0X)

COMMAND PARAMETERS:

| D (16 bits) |
|---|

| AX (16 bits) |
|---|

| AY (16 bits) |
|---|

WORD NUMBER: Wn = 4

EXECUTION CYCLES: Cn = (4x+6)y+12

where x = |AX| + 1, y = |AY| + 1

**\<DESCRIPTION\>**

The MM (Modify Mode) field of the command code specifies the data transfer modify mode.

The frame buffer area defined by the RWP origin and the physical frame buffer word address (AX and AY) parameters is selectively cleared. The contents of the frame buffer are read, and that data is logically operated on with the D parameter (excepts bits masked in the MASK register) using the logical operation defined by MM. The result is rewritten to the frame buffer.

Since the ACRTC performs the selective clear using 16-bit words, multiple logical pixels (if 4 bits/pixel then 4 pixels) are cleared in one access. D is normally specified to contain multiple copies (if 4 bits/pixel then 4 copies) of the color information for a single color selective clear.

At the end of SCLR command execution, RWP will be set to RWPe.


---
*(source page 206)*

### SCLR (Selective Clear) — continued

PAGE: SCLR-2

**\<DESCRIPTION\>** (continued)

Legend: ○ = Modifier information; ○○○○ = 1st parameter; a "2" marker = 2nd parameter; a "4" marker = 3rd parameter (2nd/3rd parameters given in units of words).

*(Diagram: a grid of circles representing frame-buffer words, six rows tall. The top row shows an unhatched box labeled "RWPe" to its left, feeding into a row of circles; the fourth data row has its rightmost group of four circles boxed and labeled "Pc" (pointer to current word). A vertical arrow labeled "5" runs along the right side spanning several rows, indicating the number of rows (words in the Y direction). At the bottom, the leftmost group of four circles in the last row is boxed and labeled "Address location specified by RWP", with an arrow labeled "3" pointing right beneath the row, indicating the number of words in the X direction.)*

**Figure C13-1 Command Parameter Set**

The operation is specified by the above operation mode, and is set with bits 1, 0 in the command code.

This command can be utilized for clearing the character code, the specific attribute bits, and the specific color plane in the graphic display.

The RWP needs to be specified in advance as follows.

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

RWP address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | (hatched, unused) | RWPH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| RWPL (12 bits) | (hatched, unused) |

- The frame memory is a 20-bit linear address separated into high order RWPH (8 bits) and low order RWPL (12 bits).
- Specify the Screen No. where drawing is executed.

**Figure C13-2 RWP Set**


---
*(source page 207)*

### SCLR (Selective Clear) — continued

PAGE: SCLR-3

**\<EXAMPLE\>**

For this example 4 bits per logical pixel is used, the Memory Width (MW) is \$10, the MASK register contains \$F0F0 and the selective clear operation is to start at address \$56 on screen 0.

Based on MM, a logical operation (REPLACE, OR, AND or EOR) is defined and SCLR is executed as shown.

RWP:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0101 | 0110 | 0000 |

(\$0560)

MASK:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 1111 | 0000 | 1111 | 0000 |

(\$F0F0)

**Figure C13-3 Examples of RWP and MASK Setting**

*(Below, two small block diagrams illustrate the data-flow notation used in later figures. Left diagram: "Read Data" (marked ○) and "Modifier Data" (marked ▽) both feed into an "MM" box, whose output is "Write Data" (marked ●). Right diagram: "Read Data" (marked △) and "Modifier Data" (marked ▽) feed into an "MM" box, whose output is "Write Data" (marked ▲), noted as unit: pixel.)*

**Figure C13-4 Notation of Data**


---
*(source page 208)*

### SCLR (Selective Clear) — continued

PAGE: SCLR-4

**\<EXECUTION EXAMPLE\>**

COMMAND CODE:

| 15-12 | 11-8 | 7-2 | 1-0 |
|---|---|---|---|
| 0101 | 1100 | 000000 | MM |

(\$5C0X)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0001 | 0001 | 0001 | 0001 |

(\$1111)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 1111 | 1111 | 1111 | 1100 |

(\$FFFC)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 1111 | 1111 | 1111 | 1010 |

(\$FFFA)


---
*(source page 209)*

### SCLR (Selective Clear) — continued

PAGE: SCLR-5

**\<EXECUTION EXAMPLE\>** (continued)

1 pixel: | 0001 | = ▽ (Modifier data) → 1st parameter (Modifier Data) (\$1111) = | ▽ ▽ ▽ ▽ |

*(A hexadecimal-column ruler labeled 0 through 6 runs across the top of two stacked grids, with row labels down the left side.)*

**(A)** *(Rows 0-C, columns 0-6: rows 5-B are populated with markers — mostly ○ (open circles, meaning "read data"/unmodified), except a rectangular sub-block spanning rows 7-9, columns 2-6 which is filled with △ (open triangles, meaning cells selected for modification by the AX/AY rectangle). A bracket over row 5, columns 2-6, labeled "5 words", points to a boxed group of four circles at the right edge labeled "RWP (Address \$56)". A vertical bracket along the right side spanning rows 5-B is labeled "7 words". At bottom-left (row B, columns 0-1) a boxed group of circles is labeled "Pc (Address \$B2)".)*

Flow: the 1st parameter (Modifier Data, ▽▽▽▽) feeds into a "Mask" box, which feeds into an "MM" box, whose output feeds into diagram (B) below.

**(B)** *(The same grid layout, rows 0-C, columns 0-6, now populated with a mix of ● (filled circles, write data) and ○ (open circles) in rows 5-6 and A-B, and ▲ (filled triangles) and △ (open triangles) in rows 7-9 — reflecting the MASK register (\$F0F0) selectively replacing only the masked nibbles with the modifier data while leaving the unmasked nibbles as read-back data. The rightmost cell of row 5 is boxed and an arrow points from it to a box labeled "RWPe (Address \$C6)".)*

**Figure C13-5 SCLR Execution Example**


---
*(source page 210)*

### [14] CPY (Copy)

PAGE: CPY-1

**\<FUNCTION\>**

Copy frame buffer data from one area (source area) to another area (destination area).

**\<MNEMONIC\>**

CPY (S, DSD) SAH, SAL, AX, AY

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11 | 10-8 | 7-0 |
|---|---|---|---|
| 0110 | S | DSD | 00000000 |

(\$6X00)

COMMAND PARAMETERS:

| 15-8 | 7-0 |
|---|---|
| 00000000 | SAH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| SAL (12 bits) | 0000 |

| AX (16 bits) |
|---|

| AY (16 bits) |
|---|

WORD NUMBER: Wn = 5

EXECUTION CYCLES: Cn = (6x+10)y+12

where x = |AX| + 1, y = |AY| + 1

**\<DESCRIPTION\>**

The parameters to the command define the source area. The RWP must be predefined to point to the destination area (including screen number). The source area resides in the same screen as that of the destination area as defined in RWP.

The source area is defined by the origin address (SAH/SAL) and physical frame buffer word (AX and AY) dimensions.

To allow rotation and proper operation for overlapping during copying, the command code contains fields which define the source and destination scanning direction. The S (Source Scan Direction) and DSD (Destination Scan Direction) fields of the command code define the source and destination scanning direction respectively as shown next page.

At the end of the CPY command, RWP is set to RWPe.


---
*(source page 211)*

### CPY (Copy) — continued

PAGE: CPY-2

Pss address structure, bits 15-0:

| 15-8 | 7-0 |
|---|---|
| (hatched, unused) | SAH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| SAL (12 bits) | (hatched, unused) |

(1) Pss (SAH, SAL) is set to be a 20-bit linear address separated into 2 words, high order SAH (8 bits) and low order SAL (12 bits).

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

RWP address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | (hatched, unused) | RWPH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| RWPL (12 bits) | (hatched, unused) |

The frame buffer 20-bit linear address is separated into high order RWPH (8 bits) and low order RWPL (12 bits).

Specify the Screen No. where drawing is executed.

**Figure C14-1 Pss and RWP Set**


---
*(source page 212)*

### CPY (Copy) — continued

PAGE: CPY-3

**\<CPY Command Scan Direction\>**

As to CPY, the direction of pointer scanning is specified in command code. (The pointer functions in the unit of word).

(a) Scanning Direction of Source Area (S: Source Scan Direction)

COMMAND CODE:

| 15-12 | 11 | 10-0 |
|---|---|---|
| (unused) | S | (unused) |

**Table C14-1 Source Scan Direction**

Legend: ■ = Pss (source start pointer), □ = Pse (source end pointer).

**S = 0** (four panels, each a rectangle scanned row by row with a vertical arrow through the middle showing the primary top-to-bottom or bottom-to-top order, and horizontal arrows on each visible row showing that row is scanned left-to-right):
1. Pse at top-right (□), Pss at bottom-left (■), vertical arrow pointing up — scan proceeds bottom row to top row, each row left-to-right.
2. Pss at top-left (■), Pse at bottom-right (□), vertical arrow pointing down — scan proceeds top row to bottom row, each row left-to-right.
3. Pse at top-left (□), Pss at bottom-right (■), vertical arrow pointing up — scan proceeds bottom row to top row, each row right-to-left.
4. Pss at top-right (■), Pse at bottom-left (□), vertical arrow pointing down — scan proceeds top row to bottom row, each row right-to-left.

**S = 1** (four panels, each rotated 90° from the S=0 case: a horizontal arrow through the middle shows the primary left-to-right or right-to-left column order, and vertical arrows on each visible column show that column is scanned top-to-bottom):
1. Pss at bottom-left (■), Pse at top-right (□), horizontal arrow pointing right — scan proceeds left column to right column, each column top-to-bottom.
2. Pss at top-left (■), Pse at bottom-right (□), horizontal arrow pointing right — scan proceeds left column to right column, each column bottom-to-top then top-to-bottom (mixed per the drawn arrows).
3. Pse at top-left (□), Pss at bottom-right (■), horizontal arrow pointing left — scan proceeds right column to left column.
4. Pse at bottom-left (□), Pss at top-right (■), horizontal arrow pointing left — scan proceeds right column to left column, each column top-to-bottom.

As shown in Table C14-1, the scanning direction in frame buffer of the copy source area is decided by the relation between bit 11 in the command code and the Pss and the Pse.

(a) Scanning Direction of Destination Area (DSD: Destination Scan Direction)

COMMAND CODE:

| 15-11 | 10-8 | 7-0 |
|---|---|---|
| (unused) | DSD | (unused) |


---
*(source page 213)*

### CPY (Copy) — continued

PAGE: CPY-4

**Table C14-2 Destination Scan Direction**

Legend: ■ = RWP (destination start pointer), □ = RWPe (destination end pointer, after execution).

Eight panels, laid out the same way as Table C14-1's eight S=0/S=1 panels but labeled for the destination pointers instead of Pss/Pse:

- DSD = 000: □ at top-left, ■ at bottom-left, vertical arrow up — row-by-row, bottom-to-top, each row left-to-right.
- DSD = 001: ■ at top-left, □ at bottom-left, vertical arrow down — top-to-bottom, each row left-to-right.
- DSD = 010: □ at top-right, ■ at bottom-right, vertical arrow up — bottom-to-top, each row right-to-left.
- DSD = 011: ■ at top-right, □ at bottom-right, vertical arrow down — top-to-bottom, each row right-to-left.
- DSD = 100: ■ at bottom-left, □ at bottom-right, horizontal arrow right — column-by-column left-to-right, each column top-to-bottom.
- DSD = 101: ■ at top-left, □ at bottom-right, horizontal arrow right — left-to-right, each column bottom-to-top.
- DSD = 110: □ at bottom-left, ■ at bottom-right, horizontal arrow left — right-to-left, each column top-to-bottom.
- DSD = 111: □ at top-left, ■ at top-right, horizontal arrow left — right-to-left, each column bottom-to-top.

As shown in Table C14-2, the scanning direction in frame buffer of the destination area is decided by the relation between bit 10 to 8 in the command code and the RWP.

Upon termination of the command, RWPe, end point of the RWP moves as shown in Table C14-2.

**Relation to Linear Address**

Fig. C14-2 provides the relation between CPY and specified value when S = 1 and DSD = 000.

*(Diagram: on the right, a "Source Area" rectangle shows a hatched region of AX (width) by AY (height) words, with its bottom-left corner marked ■ and labeled "Pss (Linear Address)" = [SAH | SAL], and its top-right corner (after the hatched region) marked □ and labeled "Pse (Linear Address)" = [SAH | SAL] + [AX] − [AY × MW]. On the left, a destination rectangle shows a similarly-sized hatched region, with its bottom-left corner marked ■ labeled "RWP (Linear Address)" = [RWPH | RWPL], and its top-left corner marked □ labeled "RWPe (Linear Address)" = [RWPH | RWPL] − [AX × MW] − [MW]. A block arrow points from the source rectangle to the destination rectangle indicating the copy direction.)*

**Figure C14-2 Relations with Linear Addresses**


---
*(source page 214)*

### CPY (Copy) — continued

PAGE: CPY-5

**\<EXAMPLE\>**

For this example 4 bits per logical pixel is used, the Memory Width (MW) is \$10 and the copy operation source area (SAH/SAL) start is frame buffer address \$89 while the copy destination area (RWP) start is frame buffer address \$B0 on screen 0.

The source area scanning direction is specified as S = 1 and the destination area scanning direction is specified as DSD = 000.

RWP:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 1011 | 0000 | 0000 |

(\$0B00)

**Figure C14-3 Example of Read Write Pointer Setting**

COMMAND CODE:

| 15-12 | 11 | 10-8 | 7-0 |
|---|---|---|---|
| 0110 | 1 | 000 | 00000000 |

(\$6800)

COMMAND PARAMETERS:

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0000 |

(\$0000)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 1000 | 1001 | 0000 |

(\$0890)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0011 |

(\$0003)

| 15-12 | 11-8 | 7-4 | 3-0 |
|---|---|---|---|
| 0000 | 0000 | 0000 | 0110 |

(\$0006)


---
*(source page 215)*

### CPY (Copy) — continued

PAGE: CPY-6

*(Two hexadecimal-column grids illustrate the copy example from CPY-5.)*

**(A)** A ruler labeled 0 through B runs across the top, rows 0-B down the left side. Three consecutive rows (4, 5, 6), columns 8 through B/C, are populated with a run of filled circles (●) followed by a shorter run of open circles (○) — representing the source-area word contents before the copy, at the address range starting \$89.

**(B)** A ruler labeled 0 through C runs across the top of a taller diagram containing two separate regions:
- Left region (destination): rows 6-B, columns 0-7, showing a rectangular outline with a small notch at row 6-7 column 0 labeled "RWPe (Address \$70)" (open cell) and another notch at row A-B column 0 labeled "RWP (Address \$B0)" (filled cell); inside the outline, rows 9-B contain a triangular arrangement of open circles (○) — the copied pixel data after the transfer.
- Right region (source): rows 2-8, columns 8-C, showing a rectangular outline with a notch at row 2-3 column C labeled "Pse (Address \$2C)" (open cell) and another notch at row 7-8 column 8 labeled "Pss (Address \$89)" (filled cell); inside, rows 4-6 contain the same filled/open circle pattern as diagram (A), representing the source data being read.
- A block arrow points from the source region (right) to the destination region (left), indicating the direction of the copy.

**Figure C14-4 Example of CPY Execution**


---
*(source page 216)*

### [15] SCPY (Selective Copy)

PAGE: SCPY-1

**\<FUNCTION\>**

Copy frame buffer data from one area (source area) to another area (destination area) subject to logical modification. The source and destination areas must reside on the same screen.

**\<MNEMONIC\>**

SCPY (S, DSD, MM) SAH, SAL, AX, AY

TYPE: Data Transfer Command

**\<FORMAT\>**

COMMAND CODE (hexadecimal notation, bits 15-0):

| 15-12 | 11 | 10-8 | 7-2 | 1-0 |
|---|---|---|---|---|
| 0111 | S | DSD | 000000 | MM |

(\$7X0X)

COMMAND PARAMETERS:

| 15-8 | 7-0 |
|---|---|
| 00000000 | SAH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| SAL (12 bits) | 0000 |

| AX (16 bits) |
|---|

| AY (16 bits) |
|---|

WORD NUMBER: Wn = 5

EXECUTION CYCLES: Cn = (6x+10)y+12

where x = |AX| + 1, y = |AY| + 1

**\<DESCRIPTION\>**

The parameters to the command define the source area. The RWP must be predefined to point to the destination area (including screen number). The source area resides in the same screen as that of the destination area as defined in RWP.

The source area is defined by the origin address (SAH/SAL) and physical frame buffer word (AX and AY) dimensions.

To allow rotation and proper operation for overlapping during copying, the command code contains fields which define the source and destination scanning direction. The S (Source Scan Direction) and DSD (Destination Scan Direction) fields of the command code define the source and destination scanning direction respectively as shown next page.

The MM (Modify Mode) field of the command code specifies the data transfer modify mode. Based on MM, logical operation is performed (except for bits masked in the MASK register) between the source data and the destination data, and the result is written to the destination.

At the end of the CPY command, RWP is set to RWPe.


---
*(source page 217)*

### SCPY (Selective Copy) — continued

PAGE: SCPY-2

The source address and Read/Write Pointer need to be specified as follows prior to the execution.

Pss address structure, bits 15-0:

| 15-8 | 7-0 |
|---|---|
| (hatched, unused) | SAH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| SAL (12 bits) | (hatched, unused) |

(1) Pss (SAH, SAL) is set to be a 20-bit linear address separated into 2 words, high order SAH (8 bits) and low order SAL (12 bits).

DN (Screen Number) field:

| DN | Screen Number |
|---|---|
| 00 | Upper Screen |
| 01 | Base Screen |
| 10 | Lower Screen |
| 11 | Window Screen |

RWP address structure, bits 15-0:

| 15-14 | 13-8 | 7-0 |
|---|---|---|
| DN | (hatched, unused) | RWPH (8 bits) |

| 15-4 | 3-0 |
|---|---|
| RWPL (12 bits) | (hatched, unused) |

The frame buffer 20-bit linear address is separated into high order RWPH (8 bits) and low order RWPL (12 bits).

Specify the Screen No. where drawing is executed.

**Figure C15-1 Pss and RWP Set**


---
*(source page 218)*

### SCPY (Selective Copy) — continued

PAGE: SCPY-3

**\<SCPY Command Scan Direction\>**

As to SCPY, the direction of pointer scanning is specified in command code. (The pointer functions in the unit of word)

(a) Scanning Direction of Source Area (S: Source Scan Direction)

COMMAND CODE:

| 15-12 | 11 | 10-0 |
|---|---|---|
| (unused) | S | (unused) |

**Table C15-1 Source Scan Direction**

*(Identical in form to Table C14-1 on the CPY-3 page: eight panels split into S=0 and S=1 groups, each a rectangle with Pss (■) and Pse (□) marking two diagonal corners and arrows showing the raster scan order.)*

Legend: ■ = Pss, □ = Pse.

**S = 0** (four panels): (1) Pse top-right, Pss bottom-left, vertical arrow up, rows left-to-right. (2) Pss top-left, Pse bottom-right, vertical arrow down, rows left-to-right. (3) Pse top-left, Pss bottom-right, vertical arrow up, rows right-to-left. (4) Pss top-right, Pse bottom-left, vertical arrow down, rows right-to-left.

**S = 1** (four panels): (1) Pss bottom-left, Pse top-right, horizontal arrow right, columns top-to-bottom. (2) Pss top-left, Pse bottom-right, horizontal arrow right, columns bottom-to-top/top-to-bottom per column. (3) Pse top-left, Pss bottom-right, horizontal arrow left, columns bottom-to-top. (4) Pse bottom-left, Pss top-right, horizontal arrow left, columns top-to-bottom.

As shown in Table C15-1, the scanning direction in frame buffer of the copy source area is decided by the relation between bit 11 in the command code and the Pss and the Pse.


---
*(source page 219)*

### SCPY (Selective Copy) — continued

PAGE: SCPY-4

(b) Scanning Direction of Destination Area (DSD: Destination Scan Direction)

COMMAND CODE:

| 15-11 | 10-8 | 7-0 |
|---|---|---|
| (unused) | DSD | (unused) |

**Table C15-2 Destination Scan Direction**

*(Identical in form to Table C14-2 on the CPY-4 page: eight panels for DSD = 000 through 111, each a rectangle with RWP (■) and RWPe (□) marking two diagonal corners and arrows showing the scan order.)*

Legend: ■ = RWP, □ = RWPe.

- DSD = 000: RWPe top-left, RWP bottom-left, vertical arrow up, rows left-to-right.
- DSD = 001: RWP top-left, RWPe bottom-left, vertical arrow down, rows left-to-right.
- DSD = 010: RWPe top-right, RWP bottom-right, vertical arrow up, rows right-to-left.
- DSD = 011: RWP top-right, RWPe bottom-right, vertical arrow down, rows right-to-left.
- DSD = 100: RWP bottom-left, RWPe bottom-right, horizontal arrow right, columns top-to-bottom.
- DSD = 101: RWP top-left, RWPe bottom-right, horizontal arrow right, columns bottom-to-top.
- DSD = 110: RWPe bottom-left, RWP bottom-right, horizontal arrow left, columns top-to-bottom.
- DSD = 111: RWPe top-left, RWP top-right, horizontal arrow left, columns bottom-to-top.

As shown in Table C15-2, the scanning direction in frame buffer of the destination area is decided by the relation between bit 10 to 8 in the command code and the RWP.

Upon termination of the command, RWPe, end point of the RWP moves as shown in Table C15-2.

The operation is decided by the modify mode (MM) and is specified by bit "0" or "1" in the command code.


---
*(source page 220)*

**SCPY (Selective Copy)**  PAGE: SCPY-5

Relation to Linear Address

Fig. C15-2 provides the relation between SCPY and specified value when S = 1 and DSD = 000.

*(Diagram: top-left shows a hatched multi-row block with a vertical dividing line and a black marker on one row, labeled "RWP (Linear Address)" via boxes RWPH/RWPL pointing to the marker. Top-right shows a rectangular region built from rows of hatched (mask) and diagonal-hatched (data) cells, with corner labels: "Pse (Linear Address)" at top, computed as SAH/SAL boxes + AX box − AY×MW box, pointing to the top-right corner of the region; "Pss (Linear Address)" at bottom, shown as SAH/SAL boxes, pointing to a black marker at the bottom-left corner of the region. Side annotations show "AX+1" spanning the row width and "AY+1" spanning the column height (bracket). Below, an arrow labeled with "Read Data" (diagonal hatch) and "Modifier Data" (crosshatch) feeding into a box "MM", producing "Write Data" (dotted fill) below. At the bottom, a second hatched multi-row block similar to the top-left one, with "RWPe (Linear Address)" computed as RWPH/RWPL boxes − AX×MW box − MW box, pointing to a black marker on one row; the block shows a mix of hatched, dotted (write data), and a black marker cell.)*

**Figure C15-2 Relations with Linear Addresses**

---
*(source page 221)*

**SCPY (Selective Copy)**  PAGE: SCPY-6

<EXAMPLE>

For this example 4 bits per logical pixel is used, the Memory Width (MW) is $10, the MASK register contains $F0F0 and the copy operation source area (SAH/SAL) start is frame buffer address $85 while the copy destination area (RWP) start is frame buffer address $B0 on screen 0.

The source area scanning direction is specified as S = 1 and the destination area scanning direction is specified as DSD = 000.

RWP

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

($0000)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

($0B00)

MASK

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 |

($F0F0)

**Figure C15-3 RWP and MASK Setting**

*(Diagram: two side-by-side "MM" operation boxes illustrating the SCPY selective-write logic, each labeled "Read Data" and "Modifier Data" arrows into the box, with a "Write Data" arrow out. Left box: Read Data marked with open circle (○), Modifier Data marked with open triangle (▽), producing Write Data marked with a filled circle (●). Right box: Read Data marked with open triangle (△), Modifier Data marked with open triangle (▽), producing Write Data marked with a filled triangle (▲). Note: "(Unit: pixel)" appears beside the right box.)*

**Figure C15-4 Operation of SCPY**

---
*(source page 222)*

**SCPY (Selective Copy)**  PAGE: SCPY-7

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | M | M |

($780X)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

($0000)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 |

($0850)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |

($0001)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

($0006)

---
*(source page 223)*

**SCPY (Selective Copy)**  PAGE: SCPY-8

*(Diagram: Figure C15-5, two hex-addressed pixel grids (columns labeled 0-7, rows labeled 0-C in hex) illustrating an SCPY execution example, plus a side panel showing the modifier-data derivation.)*

*(A) Before Execution of SCPY: rows 3-6, columns roughly 4-6, contain a block of open-triangle-down (▽) symbols (the source/modifier pattern to be selectively copied — row 3 has 7 triangles, row 4 has 7, row 5 has 11 (extending further right), row 6 has 7. Rows A, B, C (spanning columns 0-6/7) contain alternating runs of open-triangle (△) and open-circle (○) symbols: row A reads △△△△○○○○△△△○○○△△△○○○△△△ (in runs of three-to-four), row B reads ○○○○△△△○○○△△△○○○△△△○○○ (an inverse/offset pattern to row A), row C is blank. A side legend shows a box "1 pixel = 0001" equal to the ▽ (modifier data) symbol.)*

*(B) After Execution of SCPY: the same two grids are shown post-execution, with pointer labels: "Pse (Address $26)" pointing to the top-right corner of a highlighted sub-block within the former ▽ region (rows 3-6, columns ~4-5); "Pss (Address $85)" pointing to a black-filled marker cell at the bottom-left of that sub-block (row 7/8 boundary, column ~4); "RWPe (Address $90)" pointing to the top-left of a block in the row A/B region (column 0); "RWP (Address $B0)" pointing to a black-filled marker cell in the row B/C boundary area (column 0). Within the highlighted sub-block (rows 3-6), the triangles are now split by a vertical boundary line — the left portion (columns ~4) shows the retained ▽ pattern, the right portion (column ~5-6) is blank/unmodified. In the row A/B destination area, the pattern is now shown split into column groups of 4, with each group showing a mix of the original △/○ symbols alternating with filled-circle (●) and filled-triangle (▲) symbols — the filled symbols mark pixels that were selectively overwritten by the copy (per the MM logic of Figure C15-4: where the underlying destination pixel was ○ and the modifier indicated copy, it becomes ●; where it was △, it becomes ▲), while unfilled △/○ pixels mark positions the mask left unchanged.)*

*(Side panel: box "1 pixel" = "0001" → equals ▽ (modifier Data) → arrow down to "1st Parameter ($1111)" = "(Modifier Data)" → arrow down to a box containing "▽▽▽▽" → arrow down to a box "Mask" → arrow down to a box "MM", with a line from the MM box pointing into the destination grid at the boundary between an unfilled and filled symbol run in row B, indicating where the mask/modifier data determines the selective copy output.)*

**Figure C15-5 Example of SCPY Execution**

---
*(source page 224)*

**[16] AMOVE (Absolute Move)**  PAGE: AMOVE-1  TYPE: Graphic Command

<FUNCTION>

Move the Current Pointer (CP) to an absolute logical pixel X-Y address.

<MNEMONIC>

AMOVE X, Y

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

hexadecimal notation ($8000)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| X (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Y (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=56

<DESCRIPTION>

The parameters (X, Y) of the AMOVE command specify the new value for the CP. The address is specified using logical pixel X-Y addresses relative to the origin defined by the ORG command.

*(Diagram: an X-Y coordinate plane with origin marked "ORG(0,0)" at lower-left. A point "CP(A,B)" is shown partway up from the origin, connected to the origin by a curved arrow labeled "B" (vertical) rising from a point "A" on the X axis, itself connected to the origin by a curved arrow labeled "X" — wait, more precisely: point A lies on the X axis at distance from ORG, with a curved arrow labeled "X" spanning ORG to a point further right on the X axis; a vertical curved arrow labeled "Y" spans from that point on the X axis up to the destination point "Pe(X,Y)" at upper right. A dashed line runs diagonally from CP(A,B) to Pe(X,Y), representing the move.)*

**Figure C16-1 Function of AMOVE Command**

---
*(source page 225)*

**AMOVE (Absolute Move)**  PAGE: AMOVE-2

<EXAMPLE>

If CP = (−13, −10) and AMOVE command is executed with parameters (X, Y) = (10, 2), then the CP is set to Pe as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

($8000)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

($000A)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |

($0002)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)" at the intersection. Point "CP(-13,-10)" is plotted at lower-left, connected by a dashed diagonal line to point "Pe(10,2)" at upper-right, near the X axis. Curved arrows along the path are labeled "10" (horizontal component) and "2" (vertical component, near Pe).)*

**Figure C16-2 Example of AMOVE Execution**

---
*(source page 226)*

**[17] RMOVE (Relative Move)**  PAGE: RMOVE-1  TYPE: Graphic Command

<FUNCTION>

Move the Current Pointer (CP) to a relative logical pixel X-Y address.

<MNEMONIC>

RMOVE dX, dY

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

hexadecimal notation ($8400)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dX (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dY (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=56

<DESCRIPTION>

The parameters (dX, dY) of the RMOVE command are used to calculate the new value for the CP. The address is specified using logical pixel X-Y displacements relative to CP.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Point "CP(A,B)" is shown above and right of the origin, connected to a point "A" on the X axis by vertical arrow "B", and "A" connected to ORG by the X axis itself. From CP(A,B), a curved arrow labeled "dX" extends right and a curved arrow labeled "dY" extends up to reach point "Pe(A+dX, B+dY)" at upper right; a dashed diagonal line connects CP to Pe.)*

**Figure C17-1 Function of RMOVE**

---
*(source page 227)*

**RMOVE (Relative Move)**  PAGE: RMOVE-2

<EXAMPLE>

If CP = (−13, −10) and RMOVE command is executed with parameters (X, Y) = (10, 2), then the CP is set to Pe as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

($8400)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

dX ($000A)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |

dY ($0002)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)" at the intersection. Below and left of the origin, point "CP(-13,-10)" connects via a dashed diagonal line to point "Pe(-3,-8)", with curved arrows labeled "10" (horizontal displacement) and "2" (vertical displacement) along the path.)*

**Figure C17-2 Example of RMOVE Execution**

---
*(source page 228)*

**[18] ALINE (Absolute Line)**  PAGE: ALINE-1  TYPE: Graphic Command

<FUNCTION>

Draw a straight line from CP to a command specified end point.

<MNEMONIC>

ALINE (AREA, COL, OPM) X, Y

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($88XX)

*(Note: bit fields 7-6 = AREA, 5-4 = COL, 3-0 = OPM, per the header column markers "8 7", "5 4", "3 2", "0".)*

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| X (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Y (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=P·L+18

<DESCRIPTION>

The parameters (X, Y) define the line end point as absolute logical pixel X-Y addresses relative to the origin defined with the ORG command.

As the line is drawn, CP is moved to Pe. However, the logical pixel at position Pe is not drawn.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Point "CP(A,B)" sits above a point "A" on the X axis (vertical distance "B"), and a diagonal line with an arrowhead rises from CP(A,B) to point "Pe(X,Y)" at upper right, which sits above a point on the X axis at horizontal distance "X" from the origin, with vertical distance "Y" marked on the right side.)*

**Figure C18-1 Function of ALINE**

---
*(source page 229)*

**ALINE (Absolute Line)**  PAGE: ALINE-2

<EXAMPLE>

If CP = (−13, −10) and ALINE command is executed with parameters (X, Y) = (10, 2), then a line is drawn and CP is set to Pe as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($88XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

X ($000A)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |

Y ($0002)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". A dashed vertical/horizontal reference line marks "-13" on the X axis (left of origin) and "-10" on a lower dashed horizontal line; point "CP(-13,-10)" sits at their intersection, lower left. A row of filled circles forms a straight diagonal line of drawn pixels rising from CP up through the origin area to point "Pe(10,2)" at upper right, marked with an open circle (undrawn endpoint) and dashed guide lines to "10" on the X axis and "2" on the Y axis.)*

**Figure C18-2 Example of ALINE Execution**

---
*(source page 230)*

**[19] RLINE (Relative Line)**  PAGE: RLINE-1  TYPE: Graphic Command

<FUNCTION>

Draw a straight line from CP to a command specified end point.

<MNEMONIC>

RLINE (AREA, COL, OPM) dX, dY

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($8CXX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dX (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dY (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=P·L+18

<DESCRIPTION>

The parameters (dX, dY) define the line end point as relative logical pixel X-Y displacements from the CP.

As the line is drawn, CP is moved to Pe. However, the logical pixel at position Pe is not drawn.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Point "CP(A,B)" sits above point "A" on the X axis (vertical distance "B"). A diagonal line with an arrowhead rises from CP(A,B) to point "Pe(A+dX, B+dY)" at upper right; curved arrows labeled "dX" (horizontal) and "dY" (vertical) mark the displacement components.)*

**Figure C19-1 Function of RLINE**

---
*(source page 231)*

**RLINE (Relative Line)**  PAGE: RLINE-2

<EXAMPLE>

If CP = (−13, −10) and RLINE command is executed with parameters (dX, dY) = (10, 2), then a line is drawn and CP is set to Pe as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 1 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($8CXX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

($000A)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |

($0002)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". Dashed reference lines mark "-13" and "-3" on the X axis, and "-10"/"-8" on horizontal guide lines. Point "CP(-13,-10)" at lower-left is joined by a row of filled circles (drawn pixels) rising diagonally to point "Pe(-3,-8)" marked with an open circle (undrawn endpoint), near the "-8" guide line.)*

**Figure C19-2 Example of RLINE Execution**

---
*(source page 232)*

**[20] ARCT (Absolute Rectangle)**  PAGE: ARCT-1  TYPE: Graphic Command

<FUNCTION>

Draw a rectangle defined by CP and the command specified diagonal point.

<MNEMONIC>

ARCT (AREA, COL, OPM) X, Y

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($90XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| X (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Y (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=2p(A+B)+54

<DESCRIPTION>

The parameters (X, Y) define the diagonal point of the rectangle as absolute logical pixel X-Y addresses relative to the origin defined by the ORG command.

As the rectangle is drawn, CP is moved to Pe (which is the same as CP). However, the logical pixel at position Pe is not drawn.

Drawing starts in the X direction first, and is drawn in the direction shown below. The initial X direction is determined by the relationship between CP and (X, Y).

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Point "CP(A,B)" sits at the lower-left corner of a rectangle, with "Pe(A,B)" marked at the same location (both labeled with arrows converging there). The rectangle extends right to the diagonal point "Pc(X,Y)" at upper-right. Arrows along the rectangle's edges show the drawing direction: rightward from CP along the bottom edge, then upward along the right edge to Pc, then leftward along the top edge, tracing the perimeter counterclockwise-from-bottom. Side annotations: "A" and "X" mark horizontal distances along the X axis from ORG; "B" and "Y" mark vertical distances.)*

**Figure C20-1 Function of ARCT**

---
*(source page 233)*

**ARCT (Absolute Polyline)**  PAGE: ARCT-2

*(Note: the page header reads "ARCT (Absolute Polyline)" — likely a typesetting inconsistency with page ARCT-1's "Absolute Rectangle" title; the command mnemonic and content remain ARCT (Absolute Rectangle).)*

<EXAMPLE>

If CP = (6, −6) and ACT command is executed with parameters (X, Y) = (−16, 10), then a rectangle is drawn and CP is set to Pe as shown below.

*(Note: "ACT" appears in the original text — likely an abbreviation/typo for ARCT.)*

<NOTE>

Drawing starts from the X-axis direction.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($90XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 |

($FFF0)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

($000A)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". A rectangle is drawn in open-circle pixel markers from corner "Pc(-16,10)" at upper-left, along the top edge rightward, down the right edge (labeled "16" along the top for horizontal extent and "10" along the left edge for vertical extent) to corner "Pe(6,-6)"/"CP(6,-6)" at lower-right, then along the bottom edge leftward back toward the starting column, and up the left edge back to Pc — forming a complete rectangular outline of circle markers. Arrows near Pc and near CP indicate the drawing start/end points and direction.)*

**Figure C20-2 Example of ARCT Execution**

---
*(source page 234)*

**[21] RRCT (Relative Rectangle)**  PAGE: RRCT-1  TYPE: Graphic Command

<FUNCTION>

Draw a rectangle defined by CP and the command specified diagonal point.

<MNEMONIC>

RRCT (AREA, COL, OPM) dX, dY

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($94XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dX (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dY (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=2P(A+B)+54

<DESCRIPTION>

The parameters (dX, dY) define the diagonal point of the rectangle as relative logical pixel X-Y displacements from the CP.

As the rectangle is drawn, CP is moved to Pe. However, the logical pixel at position Pe is not drawn.

Drawing starts in the X direction first, and is drawn in the direction show below. The initial X direction is determined by the relationship between CP and (dX, dY).

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Point "CP(A,B)" sits at the lower-left corner of a rectangle, with "Pe(A,B)" marked at the same location. The rectangle extends to diagonal point "Pc(A+dX, B+dY)" at upper-right. Arrows along the rectangle's edges show the drawing direction (rightward along the bottom via "dX", upward along the right edge via "dY", then leftward along the top back toward Pc). Side annotations "A" and "B" mark the offset of CP from ORG along the X and Y axes respectively.)*

**Figure C21-1 Function of RRCT**

---
*(source page 235)*

**RRCT (Relative Rectangular)**  PAGE: RRCT-2

<EXAMPLE>

If CP = (6, −6) and RRCT command is executed with parameters (dX, dY) = (−16, 10), then a rectangle is drawn and CP is set to Pe as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($94XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 |

dX ($FFF0)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

dY ($000A)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". A rectangle drawn with open-circle pixel markers has corner "Pc(-10,4)" at upper-left, extending right along the top edge, down the right side (marked "10" for vertical extent along the left edge and "16" for horizontal extent along the bottom edge) to corner "Pe(6,-6)"/"CP(6,-6)" at lower-right, then back left along the bottom and up the left edge to close the loop — forming a complete rectangular outline.)*

**Figure C21-2 Example of RRCT**

---
*(source page 236)*

**[22] APLL (Absolute Polyline)**  PAGE: APLL-1  TYPE: Graphic Command

<FUNCTION>

Draw a polyline (multiple contiguous segments) from the CP through command specified points.

<MNEMONIC>

APLL (AREA, COL, OPM) n, X1, Y1 ... Xn, Yn

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($98XX)

COMMAND PARAMETERS (each 16 bits):

| Parameter | Label |
|---|---|
| n | |
| X1 | P1 |
| Y1 | P1 |
| X2 | P2 |
| Y2 | P2 |
| ⋮ | ⋮ |
| Xn−1 | Pn−1 |
| Yn−1 | Pn−1 |
| Xn | Pe |
| Yn | Pe |

(the point list continues as P2n+1 total parameter words)

n is specified by the absolute value of a 16-bit binary number.

WORD NUMBER: Wn=2n+2

EXECUTION CYCLES: Cn=Σ(P·L+16)+8

---
*(source page 237)*

**APLL (Absolute Polyline)**  PAGE: APLL-2

<DESCRIPTION>

The first parameter (n) specifies the number of line segments, that is, n = 1 specifies one line segment. The following parameters (Xn, Yn) are absolute logical pixel X-Y addresses, which specify each segment's end point relative to the origin defined by the ORG command.

As the polyline is drawn, CP is moved to Pe. However, the logical pixel at position Pe is not drawn.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Starting at point "CP(A,B)", a solid polyline rises through vertex "P1(X1,Y1)" up to a peak at "P2(X2,Y2)", then descends through "P3(X3,Y3)" (solid segment), continues as a dashed line (indicating omitted intermediate segments) to "Pn-1(Xn-1,Yn-1)", then a final solid segment descends to the open-circle endpoint "Pe(Xn,Yn)". Curved arrows below the X axis mark the horizontal offsets X1, X2, X3, Xn-1, Xn from ORG to each vertex's X position; vertical arrows/labels B, Y1, Y2, Y3, Yn-1, Yn mark each point's height above the X axis.)*

**Figure C22-1 Function of APLL**

---
*(source page 238)*

**APLL (Absolute Polyline)**  PAGE: APLL-3

<EXECUTION EXAMPLE>

If the CP is at (−8, −6) on the split screen, n is set to 3, X1 to −4, Y1 to 4, X2 to 8, Y2 to 6, X3 to 16 and Y3 to −8, then the APLL command draws a poly line as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |

n ($0003)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |

X1 ($FFFC)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |

Y1 ($0004)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |

X2 ($0008)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

Y2 ($0006)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |

X3 ($0010)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 |

Y3 ($FFF8)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". Starting at "CP(-8,-6)" (lower-left), a line drawn with filled dot pixels rises through "P1(-4,4)" — with "4" marking the vertical rise and "4" the horizontal run from origin — to a plateau/peak near "P2(8,6)" (marked "6" and "8" for its position), then descends through the region toward endpoint "Pe(16,-8)" — marked "16" horizontally and "8" vertically — shown as an open circle. The dot-pattern traces a mountain-like profile: up-slope from CP to P1 to the peak near P2, then down-slope to Pe.)*

**Figure C22-2 Example of APLL Execution**

---
*(source page 239)*

**[23] RPLL (Relative Polyline)**  PAGE: RPLL-1  TYPE: Graphic Command

<FUNCTION>

RPLL command draws a polyline which connects the Start point, current pointer, and each relative coordinate point.

<MNEMONIC>

RPLL (AREA, COL, OPM) n, dX1, dY1, ... dXn, dYn

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($98XX)

*(Note: a stray "C" character appears in the left margin beside the command code row in the source scan — likely a printing artifact, not part of the bit field.)*

COMMAND PARAMETERS (each 16 bits):

| Parameter | Label |
|---|---|
| n | |
| dX1 | P1 |
| dY1 | P1 |
| dX2 | P2 |
| dY2 | P2 |
| ⋮ | ⋮ |
| dXn−1 | Pn−1 |
| dYn−1 | Pn−1 |
| dXn | Pe |
| dYn | Pe |

(the point list continues as P2n+1 total parameter words)

Set "n" in binary absolute values of 16 bits.

WORD NUMBER: Wn=2n+2

EXECUTION CYCLES: Cn=Σ(P·L+16)+8

---
*(source page 240)*

**RPLL (Relative Polyline)**  PAGE: RPLL-2

<DESCRIPTION>

As shown in figure below, the relative poly line command (RPLL) draws a poly line which connects the Start point CP, and each relative coordinate (P1, P2, P3, ....., Pn-1, Pe).

The total number of points is set in the 1st command parameter (n). X and Y components of each point are set in the command parameters in the order the lines are drawn. CP moves to the End point Pe as the lines are drawn. However, a dot is not drawn at Pe.

Point coordinates accumulate from CP as follows:

(X1, Y1) : (A+dX1, B+dY1)
(X2, Y2) : (X1+dX2, Y1+dY2)
(X3, Y3) : (X2+dX3, Y2+dY3)
(Xn-1, Yn-1) : (Xn-2+dXn-1, Yn-2+dYn-1)
(Xn, Yn) : (Xn-1+dXn, Yn-1+dYn)

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Starting at "CP(A,B)" (offset from ORG by "A" horizontally and "B" vertically), a solid polyline rises via displacement "dX1"/"dY1" to "P1(X1,Y1)", then via "dX2"/"dY2" to a peak at "P2(X2,Y2)", then descends via "dX3"/"dY3" to "P3(X3,Y3)" — this segment solid, followed by a dashed segment (omitted intermediate points) to "Pn-1(Xn-1,Yn-1)", then a final solid segment via "dXn"/"dYn" descends to the open-circle endpoint "Pe(Xn,Yn)".)*

**Figure C23-1 Function of RPLL**

---
*(source page 241)*

**RPLL (Relative Polyline)**  PAGE: RPLL-3

<EXECUTION EXAMPLE>

If the CP is at (−8, −6) on the split screen, dX1 is set to −4, dY1 to 4, dX2 to 8, dY2 to 6, dX3 to 16 and dY3 to −8, then the RPLL command draws a poly line as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($9CXX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |

($0003)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |

($FFFC)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |

($0004)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |

($0008)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

($0006)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |

($0010)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 |

($FFF8)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". Starting at "CP(-8,-6)" (lower-left, marked with displacements "4" and "4" to the next vertex), a line rises to "P1(-12,-2)", then a long diagonal (marked "8" and "6") crosses up through/near the origin to peak vertex "P2(-4,4)" at upper-left, then a very long diagonal (marked "16" and "8") crosses back down across the whole plot to the open-circle endpoint "Pe(12,-4)" at lower-right. Note: the resulting figure forms a large zigzag/bowtie shape rather than a simple polygon, since the cumulative relative offsets carry the path from lower-left up to upper-left then back across to lower-right.)*

**Figure C23-2 Example of RPLL Execution**

---
*(source page 242)*

**[24] APLG (Absolute Polygon)**  PAGE: APLG-1  TYPE: Graphic Command

<FUNCTION>

APLG draws a polygon which connects the initial point, CP, and each absolute coordinate.

<MNEMONIC>

APLG (AREA, COL, OPM) n, X1, Y1 ..... Xn, Yn

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($A0XX)

COMMAND PARAMETERS (each 16 bits):

| Parameter | Label |
|---|---|
| n | |
| X1 | P1 |
| Y1 | P1 |
| X2 | P2 |
| Y2 | P2 |
| ⋮ | ⋮ |
| Xn−1 | Pn−1 |
| Yn−1 | Pn−1 |
| Xn | Pn |
| Yn | Pn |

(the point list continues as P2n+1 total parameter words)

Set "n" in binary absolute values of 16 bits.

WORD NUMBER: Wn=2n+2

EXECUTION CYCLES: Cn=Σ(P·L+16)+P·L0+20

---
*(source page 243)*

**APLG (Absolute Polygon)**  PAGE: APLG-2

<DESCRIPTION>

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Starting at "CP(A,B)" (which coincides with "Pe(A,B)"), a solid polyline rises through "P1(X1,Y1)" up to peak "P2(X2,Y2)", descends through "P3(X3,Y3)" (solid), continues as a dashed line to "Pn-1(Xn-1,Yn-1)" (omitted intermediate points), then a solid segment reaches "Pn(Xn,Yn)" at far right — and finally a long closing straight line runs directly back from Pn to CP/Pe, closing the polygon. Curved arrows below the X axis mark horizontal offsets X1, X2, X3, Xn-1, Xn from ORG; vertical labels B, Y1, Y2, Y3, Yn-1, Yn mark each vertex's height.)*

**Figure C24-1 Function of APLG**

As shown in above figure, the APLG command draws a polygon line which connects the start point, CP, and each absolute coordinate (P1, P2 ....., Pn-1, Pn), then back to CP.

The total number of points are set in the first command parameter. X and Y components of each point are set in the command parameters in the order the lines are drawn. CP moves to the end point CPe to draw a poly line. However a dot is not drawn at Pe. CP is the same point as Pe.

---
*(source page 244)*

**APLG (Absolute Polygon)**  PAGE: APLG-3

<EXAMPLE>

If the CP is at (−8, −6) on the split screen, n is set to 3, X1 to −4, Y1 to 4, X2 to 8, Y2 to 6, X3 to 16 and Y3 to −8 in the command parameter. The APLG command draws a polygon line as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($A0XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |

($0003)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |

($FFFC)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |

($0004)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |

($0008)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

($0006)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |

($0010)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 |

($FFF8)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". "CP(-8,-6)" coincides with "Pe(-8,-6)" at lower-left. From CP, a solid line rises (offset "4","4") to "P1(-4,4)", continues up-right (offset "8","6") to peak "P2(8,6)", descends (offset "16","8") to "P3(16,-8)" at lower-right, then a closing line runs directly back left from P3 to CP/Pe — forming a triangular/quadrilateral closed polygon outline.)*

**Figure C24-2 Example of APLG Execution**

---
*(source page 245)*

**[25] RPLG (Relative Polygon)**  PAGE: RPLG-1  TYPE: Graphic Command

<FUNCTION>

APLG draws a polygon which connects the initial point, CP, and each relative coordinate.

*(Note: the FUNCTION text as printed refers to "APLG" — likely carried over from the previous command's template and left uncorrected in the source; the command being defined here is RPLG.)*

<MNEMONIC>

RPLG (AREA, COL, OPM) n, dX1, dY1, ... dXn, dYn

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 0 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($A4XX)

COMMAND PARAMETERS (each 16 bits):

| Parameter | Label |
|---|---|
| n | |
| dX1 | P1 |
| dY1 | P1 |
| dX2 | P2 |
| dY2 | P2 |
| ⋮ | ⋮ |
| dXn−1 | Pn−1 |
| dYn−1 | Pn−1 |
| dXn | Pn |
| dYn | Pn |

(the point list continues as P2n+1 total parameter words)

Set "n" in binary absolute values of 16 bits.

WORD NUMBER: Wn=2n+2

EXECUTION CYCLES: Cn=Σ(P·L+16)+P·L0+20

---
*(source page 246)*

**RPLG (Relative Polygon)**  PAGE: RPLG-2

<DESCRIPTION>

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. Starting at "CP(A,B)" (which coincides with "Pe(A,B)"), a solid line rises via displacement "dX1"/"dY1" to "P1(X1,Y1)", then via "dX2"/"dY2" to peak "P2(X2,Y2)", descends via "dX3"/"dY3" to "P3(X3,Y3)" — solid segment, followed by a dashed segment to "Pn-1(Xn-1,Yn-1)" (omitted intermediate points), then a solid segment via "dXn"/"dYn" reaches "Pn(Xn,Yn)" at far right — and a long closing straight line runs directly back from Pn to CP/Pe, closing the polygon.)*

Point coordinates accumulate from CP as follows:

(X1, Y1) : (A+dX1, B+dY1)
(X2, Y2) : (X1+dX2, Y1+dY2)
(X3, Y3) : (X2+dX3, Y2+dY3)
(Xn-1, Yn-1) : (Xn-2+dXn-1, Yn-2+dYn-1)
(Xn, Yn) : (Xn-1+dXn, Yn-1+dYn)

**Figure C25-1 Function of RPLG**

As shown in above figure, the RPLG command draws a polygon line which connects the start point, CP, and each related coordinate (P1, P2, P3, ..., Pn-1, Pn), then back to CP.

The total number of points are set in the first command parameter. X and Y components of each point are set in the command parameters in the order the lines are drawn. CP moves to the end point Pe as the lines are drawn. However a dot is not drawn at Pe. CP is the same point as Pe.

---
*(source page 247)*

**RPLG (Relative Polygon)**  PAGE: RPLG-3

<EXAMPLE>

If the CP is at (−8, −6) on the split screen, n is set to 3, dX1 to −4, dY1 to 4, dX2 to 8, dY2 to 6, dX3 to 16 and dY3 to −8 in the command parameter, then the RPLG command draws a polygon line as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 0 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($A4XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |

($0003)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |

($FFFC)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |

($0004)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |

($0008)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

($0006)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 |

($0010)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 |

($FFF8)

*(Diagram: X-Y coordinate axes with origin "ORG(0,0)". "CP(-8,-6)" coincides with "Pe(-8,-6)" at lower-center. From CP, a line rises (offset "4","4") to "P1(-12,-2)", then a diagonal (offset "8","6") crosses up through the origin area to peak "P2(-4,4)" at upper-left, then a long diagonal (offset "16","8") crosses back down across the plot to "P3(12,-4)" at lower-right, and a closing line runs directly back from P3 to CP/Pe — forming a bowtie-like closed polygon that crosses itself near the origin.)*

**Figure C25-2 Example of RPLG Execution**

---
*(source page 248)*

**[26] CRCL (Circle Command)**  PAGE: CRCL-1  TYPE: Graphic Command

<FUNCTION>

CRCL Command draws a circle of the radius R placing the CP at the center.

<MNEMONIC>

CRCL (C, AREA, COL, OPM) r

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 1 | 0 | 0 | C | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation: C=1: ($A9XX); C=0: ($A8XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| r (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=2

EXECUTION CYCLES: Cn=8d+66

<DESCRIPTION>

The Circle Command (CRCL) draws a circle placing the Current Pointer (CP) at the center. The command parameter r specifies a radius in units of pixels.

First the CP moves in the X-direction from the center for the length of the radius r. Now this point is named Ps. The circle drawing starts at Ps and finishes at P1 (=Ps). But, a dot is not drawn at P1. After the circle has been drawn, the CP moves back to the center and the command is finished. The position of the CP and Pe are the same.

Bit 8 (C) of the command code specifies whether a circle is drawn clockwise or counterclockwise. When C=1, it is drawn clockwise, when C=0, counterclockwise as shown next page.

The parameter radius r is allocated 16 bits, but only the low order 13 bits are effective.

---
*(source page 249)*

**CRCL (Circle Command)**  PAGE: CRCL-2

*(Diagram: two circle diagrams side by side, each on X-Y axes with origin "ORG(0,0)".)*

*(A) C=1: a circle is centered at "CP(A,B)"/"Pe(A,B)" (offset "A","B" from ORG). The point "P1(A+r,B)" = "Ps(A+r,B)" lies on the circle at the rightmost point (radius "r" marked from center to this point). A curved arrow inside the circle, from the bottom of the circle curving up and around to the right side, indicates clockwise drawing direction.)*

*(B) C=0: same layout — circle centered at "CP(A,B)"/"Pe(A,B)", with "Ps(A+r,B)" = "P1(A+r,B)" at the rightmost point, radius "r" marked. A curved arrow inside the circle indicates counterclockwise drawing direction (opposite curvature from (A)).)*

**Figure C26-1 Function of CRCL**

<EXAMPLE>

If the CP is (0, 0) on the split screen, and r is set to 7 in the command parameter, then the CRCL Command draws a circle as shown in figure below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($A8XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 |

($0007)

*(Diagram: an X-Y coordinate plane with a circle centered at "CP(0,0)"/"ORG(0,0)"/"Pe(0,0)" (all coincident at the origin). The circle's rightmost point is labeled "Ps(7,0)" (top label) and "P1(7,0)" (bottom label), with "7" marking the radius from center to that point along the X axis.)*

**Figure C26-2 Example of CRCL Execution**

---
*(source page 250)*

**[27] ELPS (Ellipse Command)**  PAGE: ELPS-1  TYPE: Graphic Command

<FUNCTION>

ELPS Command draws an ellipse placing the CP at the center.

<MNEMONIC>

ELPS (C, AREA, COL, OPM) a, b, DX

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 1 | 1 | 0 | C | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation: C=1: ($ADXX); C=0: ($ACXX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| a (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dX (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=4

EXECUTION CYCLES: Cn=10d+90

<DESCRIPTION>

The Ellipse Command (ELPS) draws an ellipse placing the current pointer (CP) at the center.

On the X-Y coordinates, if the center of an ellipse is CP (A, B), the major axis is dX, and the minor axis is dY. An ellipse is drawn according to Equation (1) as shown next page.

(X−A)²/dX² + (Y−B)²/dY² = 1 ............... (1)

In Equation (1), letting the ratio of squared dX and dY be a, b;

a : b = dX² : dY² ..................... (2)

Then substituting (2) for Equation (1):

(X−A)²/a + (Y−B)²/b = dX²/a ............ (3)

---
*(source page 251)*

**ELPS (Ellipse Command)**  PAGE: ELPS-2

The ELPS Command draws an ellipse according to Equation (3). The a, b, dX are specified in units of pixels.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. An ellipse is centered at "CP(A,B)", with "dX" marked as the horizontal semi-axis (from center to the right edge) and "dY" marked as the vertical semi-axis (from center to the top edge).)*

**Figure C27-1 Function of ELPS**

As shown in figure below, the CP moves in the X-direction from the center for the length of dX. This point is named Ps. The ellipse drawing starts at Ps and finishes at P1 (=Ps). But, the dot is not drawn at P1. After the ellipse has been drawn, the CP moves back to the center, and the command is finished. The first position of the CP and Pe are the same.

*(Diagram: two ellipse diagrams side by side on X-Y axes with origin "ORG(0,0)".)*

*(A) C=1: an ellipse centered at "CP(A,B)"/"Pe(A,B)" (offset "A" from ORG on the X axis), with semi-axes "dY" (vertical) and "dX" (horizontal, to the rightmost point). The rightmost point is labeled "P1(A+dX,B)" = "Ps(A+dX,B)". A curved arrow inside the ellipse indicates clockwise drawing direction.)*

*(B) C=0: same layout — ellipse centered at "CP(A,B)"/"Pe(A,B)", semi-axes "dY" and "dX", rightmost point labeled "Ps(A+dX,B)" = "P1(A+dX,B)". A curved arrow indicates counterclockwise drawing direction (opposite curvature from (A)).)*

**Figure C27-2 Drawing Direction of ELPS**

---
*(source page 252)*

**ELPS (Ellipse Command)**  PAGE: ELPS-3

<EXAMPLE>

Bit 8 (c) of the command code specifies whether an ellipse is drawn clockwise or counterclockwise. When C = 1, it is drawn clockwise, when C = 0, counterclockwise as shown in previous page.

If the bit length of a, b, dX are ℓa, ℓb, ℓdX, then the bit length of these parameters must be as follows;

ℓa + ℓdX ≤ 13
ℓb + ℓdX ≤ 13

<EXECUTION EXAMPLE>

If the absolute coordinate of CP is (16, 10) on the split screen, a is set to 9, b to 4, dX to 9 in the command parameter, then the ELPS Command (C = 0) draws an ellipse as shown below.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 0 | 1 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($ACXX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 1 |

a ($0009)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |

b ($0004)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 1 |

dX ($0009)

9 : 4 = 9² : 6²

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". An ellipse is centered at "CP(16,10)"/"Pe(16,10)" (offset "16" from ORG along X). Semi-axes are marked "6" (vertical, up from center) and "9" (horizontal, to the right). The rightmost point is labeled "Ps(25,10)" = "P1(25,10)". A vertical measurement "10" marks the center's height above the X axis. An arrow inside the ellipse near the bottom indicates the drawing direction (clockwise, consistent with the "10" downward marker and curve).)*

**Figure C27-3 Example of ELPS Execution**

---
*(source page 253)*

**[28] AARC (Absolute Arc)**  PAGE: AARC-1  TYPE: Graphic Command

<FUNCTION>

AARC draws an arc by current pointer (start point), end point, and center point of the absolute coordinate.

<MNEMONIC>

AARC (C, AREA, COL, OPM) Xc, Yc, Xe, Ye

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 1 | 0 | 0 | 0 | C | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation: C=1: ($B1XX); C=0: ($B0XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Xc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Yc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Xe (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ye (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=5

EXECUTION CYCLES: Cn=8d+18

<DESCRIPTION>

As shown in Fig. C28-1, the AARC command draws an arc from the current pointer, CP, to Pe of the absolute coordinate, the absolute coordinates CC (Xc, Yc) being the center point. The X and Y components of the absolute coordinates CC and Pe are set in the first and second parameters in units of pixels. After the arc drawing, current pointer moves to Pe. However a dot is not drawn at Pe. The command code bit 8 (C) selects whether an arc is drawn clockwise or counterclockwise. When C is "1", the arc is drawn clockwise, and when C is "0", the arc is drawn counterclockwise as shown in Fig. C28-1.

---
*(source page 254)*

**AARC (Absolute Arc)**  PAGE: AARC-2

The command parameters are allocated 16 bits, but only the low order 13 bits are effective.

*(Diagram: two arc diagrams side by side on X-Y axes with origin "ORG(0,0)".)*

*(A) C=1: point "CP(A,B)" (offset "A","B" from ORG) is connected by a dashed circular guide (radius from center "CC(Xc,Yc)") to open-circle endpoint "Pe(Xe,Ye)" at upper right. The center "CC(Xc,Yc)" is offset horizontally by "Xc" from ORG; "Pe" is offset by "Xe" and height "Ye". A curved arrow inside/along the dashed circle from CP up and around clockwise to Pe indicates the drawn arc's direction and extent — the solid arc traces roughly three-quarters of the circle clockwise from CP to Pe.)*

*(B) C=0: same elements — "CP(A,B)" offset "A","B" from ORG, center "CC(Xc,Yc)" offset "Xc" from ORG, endpoint "Pe(Xe,Ye)" offset "Xe"/height "Ye". Here the solid drawn arc is the shorter arc from CP counterclockwise up to Pe (a smaller portion of the circle than in (A)), with the remainder of the circle shown dashed.)*

**Figure C28-1 Function of AARC Command**

<EXAMPLE>

If the coordinate of CP is at (12, 4) on the split screen, Xc is set to 12, Yc to 10, Xe to 6, and Ye to 10 in the command parameter, then the AARC Command (C = 0) draws an arc as shown in figure next page.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($B0XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0 |

Xc ($000C)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

Yc ($000A)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

Xe ($0006)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |

Ye ($000A)

---
*(source page 255)*

**AARC (Absolute Arc)**  PAGE: AARC-3

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". Labeled "C=0" at top. Center point "CC(12,10)" (offset "12" horizontally from ORG, height "10"). Start point "CP(12,4)" lies directly below the center (vertical distance "10"). End point "Pe(6,10)" (open circle) lies to the upper-left, at the same height as the center (vertical distance "10" from the X axis, horizontal offset "6" from ORG). A solid arc runs counterclockwise from CP, up and around the right side of the circle, over the top, to Pe — tracing roughly three-quarters of the circle (the dashed remainder would be the short arc directly connecting CP to Pe on the left side, not drawn).)*

**Figure C28-2 Example of AARC Execution**

---
*(source page 256)*

**[29] RARC (Relative Arc)**  PAGE: RARC-1  TYPE: Graphic Command

<FUNCTION>

RARC draws an arc by current pointer (start point), end point, and center point of the relative coordinate.

<MNEMONIC>

RARC (C, AREA, COL, OPM) dXc, dYc, dXe, dYe

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 1 | 0 | 1 | 0 | C | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation: C=1: ($B5XX); C=0: ($B4XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dXc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dYc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dXe (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dYe (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=5

EXECUTION CYCLES: Cn=8d+18

<DESCRIPTION>

As shown in Fig. C29-1, the RARC command draws an arc from the current pointer, CP, to Pe (A+dXe, B+dYe) of the relative coordinates, the relative coordinates CC (A+dXc, B+dYc) being the center points. The X and Y components of the relative coordinates CC and Pe are set in the first and second parameters in units of pixels. CP moves to the end point Pe when an arc is drawn. However a dot is not drawn at Pe. The command code bit 8(C) selects whether an arc is drawn clockwise or counterclockwise. When C is "1", the arc is drawn clockwise, and when C is "0", the arc is drawn counterclockwise as shown in Fig. C29-2.

---
*(source page 257)*

**RARC (Relative Arc)**  PAGE: RARC-2

The command parameters are allocated 16 bits, but only the low order 13 bits are effective.

*(Diagram: two arc diagrams side by side on X-Y axes with origin "ORG(0,0)".)*

*(A) C=1: point "CP(A,B)" (offset "A","B" from ORG) connects via displacement "dXc"/"dYc" to center "CC(A+dXc,B+dYc)", and via displacement "dXe"/"dYe" (shown as arrows from CP) to open-circle endpoint "Pe(A+dXe,B+dYe)" at upper right, which lies on a dashed circle centered at CC. A solid arc traces most of the circle clockwise from CP to Pe.)*

*(B) C=0: same layout — "CP(A,B)" offset "A","B" from ORG, connecting via "dXc"/"dYc" to center "CC(A+dXc,B+dYc)" and via "dXe"/"dYe" to endpoint "Pe(A+dXe,B+dYe)". Here the solid drawn arc is the shorter arc from CP counterclockwise to Pe, with the remainder of the circle dashed.)*

**Figure C29-1 Function of RARC**

<EXAMPLE>

If the coordinate of CP is at (6, 10) on the split screen, dXc is set to 6, dYc to 0, dXe to 6, and dYe to 6 in the command parameter, then the RARC command (C = 0) draws an arc as shown next page.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 1 | 0 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($B4XX)

*(Note: the source scan shows "ODM" in the last field label — likely an OCR/print artifact for "OPM".)*

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

dXc ($0006)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

dYc ($0000)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

dXe ($0006)

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 |

dYe ($0006)

---
*(source page 258)*

**RARC (Relative Arc)**  PAGE: RARC-3

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". Labeled "C=0". Center point "CC(12,10)" is reached from "CP(6,10)" via a horizontal displacement of "6". End point "Pe(12,16)" (open circle) is reached from CC via a vertical displacement of "6". A solid arc runs counterclockwise from CP down and around the bottom/right of the circle, curving up to Pe — tracing roughly three-quarters of the circle.)*

**Figure C29-2 Example of RARC Execution**

---
*(source page 259)*

**[30] AEARC (Absolute Ellipse ARC)**  PAGE: AEARC-1  TYPE: Graphic Command

<FUNCTION>

AEARC draws an ellipse ARC.

<MNEMONIC>

AEARC (C, AREA, COL, OPM) a, b, Xc, Yc, Xe, Ye

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 1 | 1 | 0 | 0 | C | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation: C=1: ($B9XX); C=0: ($B8XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| a (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Xc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Yc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Xe (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Ye (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=7

EXECUTION CYCLES: Cn=10d+96

<DESCRIPTION>

The AEARC command draws an arc from the current pointer, CP, to Pe of the absolute coordinate, the absolute coordinates CC (Xc, Yc) being the center point. The X and Y components of the absolute coordinates CC and Pe are set in the command parameters in units of pixels.

CP moves to the end point Pe when an arc is drawn. However a dot is not drawn at Pe.

---
*(source page 260)*

**AEARC (Absolute Ellipse ARC)**  PAGE: AEARC-2

The command code bit 8(C) selects whether an arc is drawn clockwise or counterclockwise. When C is "1", the arc is drawn clockwise, and when C is "0", the arc is drawn counterclockwise as shown in Fig. C30-1.

*(Diagram: two ellipse-arc diagrams side by side on X-Y axes with origin "ORG(0,0)".)*

*(A) C=1: point "CP(A,B)" (offset "A","B" from ORG) lies on an ellipse centered at "CC(Xc,Yc)" (offset "Xc" from ORG along X, with semi-axes "dY" vertical and "dX" horizontal). Open-circle endpoint "Pe(Xe,Ye)" lies at upper right (offset "Xe" from ORG, height "Ye"), on a dashed portion of the ellipse. A solid arc traces from CP clockwise around most of the ellipse to Pe.)*

*(B) C=0: same layout — "CP(A,B)" offset "A","B" from ORG, ellipse centered at "CC(Xc,Yc)" with semi-axes "dY"/"dX", endpoint "Pe(Xe,Ye)" offset "Xe"/height "Ye" at upper right. Here the solid drawn arc is the shorter arc from CP counterclockwise to Pe, with the remainder of the ellipse dashed.)*

**Figure C30-1 Function of AEARC**

<RELATED EQUATIONS>

In the X-Y coordinate, let the center point of the ellipse be CC(Xc, Yc), let the length of the X-axis be dX, and let the length of the Y-axis be dY. Depending on (1), an ellipse ARC is drawn as shown in Fig. C30-2.

(X−Xc)²/dX² + (Y−Yc)²/dY² = 1 ............... (1)

When letting dX² and dY² be a and b,
then a : b = dX² : dY² .................... (2)
by substituting (2) for (1), the result is

(X−Xc)²/a + (Y−Yc)²/b = dX²/a .......... (3)

The AEARC draws an ellipse ARC according to Equation (3).

---
*(source page 261)*

**AEARC (Absolute Ellipse ARC)**  PAGE: AEARC-3

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". An ellipse is centered at "CC(Xc,Yc)", with semi-axes "dY" (vertical, up from center) and "dX" (horizontal, to the right).)*

**Figure C30-2 Notation of an Ellipse (1)**

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". Labeled "C=0". An ellipse is centered at "CC(Xc,Yc)", with semi-axes "dY" and "dX" marked from center. Point "CP(A,B)" lies on the ellipse at upper right, connected to the center by a radial line at angle "θ" (measured from the dX axis). Point "Pe(Xe,Ye)" (open circle) lies on the ellipse at lower left, connected to the center by a radial line at angle "α" (measured from the dX axis, on the opposite side). The solid portion of the ellipse (upper-right arc, from Pe counterclockwise through CP) is drawn; the remainder (lower arc) is dashed.)*

**Figure C30-3 Notation of an Ellipse (2)**

When setting CP (A, B) and CPe (Xe, Ye) as shown in Fig. C30-3 for an ellipse arc drawing, the following equations are applicable.

---
*(source page 262)*

**AEARC (Absolute Ellipse ARC)**  PAGE: AEARC-4

A = (dX·dY·cos θ) / √(dX²sin²θ + dY²cos²θ) + Xc .......... (4)

B = (dX·dY·sin θ) / √(dX²sin²θ + dY²cos²θ) + Yc .......... (5)

Xe = (dX·dY·cos α) / √(dX²sin²α + dY²cos²α) + Xc .......... (6)

Ye = (dX·dY·sin α) / √(dX²sin²α + dY²cos²α) + Yc .......... (7)

a, b, Xc, Yc, Xe and Ye are given as a parameter to the AEARC command in units of pixels.
When setting the command parameters, CC (Xc, Yc) of an ellipse, and CP (A, B) and Pe (Xe, Ye) and ellipse ARC must meet the above (4), (5), (6) and (7) equations.

---
*(source page 263)*

**[31] REARC (Relative Ellipse ARC)**  PAGE: REARC-1  TYPE: Graphic Command

<FUNCTION>

REARC draws an ellipse ARC.

<MNEMONIC>

REARC (C, AREA, COL, OPM) a, b, dXc, dYc, dXe, dYe

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 1 | 1 | 1 | 1 | 0 | C | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation: C=1: ($BDXX); C=0: ($BCXX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| a (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dXc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dYc (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dXe (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dYe (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=7

EXECUTION CYCLES: Cn=10d+96

<DESCRIPTION>

As shown in Fig. C31-1, the REARC command draws an arc from the current pointer, CP, to Pe (dXe, dYe) of the relative coordinate, the relative coordinates CC (dXc, dYc) being the center point.

The X and Y components of the relative coordinates CC and Pe are set in the command parameters in units of pixels.

---
*(source page 264)*

**REARC (Relative Ellipse ARC)**  PAGE: REARC-2

The command code bit 8 (C) selects whether an arc is drawn clockwise or counterclockwise. When C is "1", the arc is drawn clockwise, and when C is "0", the arc is drawn counterclockwise as shown in Fig. C31-1.

*(Diagram: two ellipse-arc diagrams side by side on X-Y axes with origin "ORG(0,0)".)*

*(A) C=1: point "CP(A,B)" (offset "A","B" from ORG) connects via displacement "dXc"/"dYc" to center "CC(A+dXc,B+dYc)" of an ellipse, and via displacement "dXe"/"dYe" to open-circle endpoint "Pe(A+dXe,B+dYe)" at upper right, lying on a dashed portion of the ellipse. A solid arc traces from CP clockwise around most of the ellipse to Pe.)*

*(B) C=0: same layout — "CP(A,B)" offset "A","B" from ORG, connecting via "dXc"/"dYc" to center "CC(A+dXc,B+dYc)" and via "dXe"/"dYe" to endpoint "Pe(A+dXe,B+dYe)". Here the solid drawn arc is the shorter arc from CP counterclockwise to Pe, with the remainder of the ellipse dashed.)*

**Figure C31-1 Function of REARC**

---
*(source page 265)*

**[32] AFRCT (Absolute Filled Rectangle)**  PAGE: AFRCT-1  TYPE: Graphic Command

<FUNCTION>

AFRCT command paints the rectangular area specified with CP (Current Pointer) and the command parameter (the absolute coordinates) according to a figure pattern stored in the Pattern RAM.

<MNEMONIC>

AFRC (AREA, COL, OPM) X, Y

*(Note: mnemonic printed as "AFRC" — likely a typesetting truncation of "AFRCT".)*

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($C0XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| X (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Y (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=(P·A+8)B+18

<DESCRIPTION>

The Absolute Filled Rectangle Command (AFRCT) paints the rectangle area according to the color information in the pattern RAM. The sizes of the rectangle are parallel to the coordinate axis. Two corner points on the diagonal are CP and Pc (X, Y) at the absolute coordinate point from the origin.

Pc (X, Y) expressed in the absolute X-Y coordinates from the origin are given by the command parameter in units of pixels.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. A hatched rectangle spans from "CP(A,B)" at lower-left (offset "X" from ORG along the X axis) to "Pc(X,Y)" at upper-right, with "Y" marking the rectangle's height. The open-circle point "Pe(A,Y+1)" sits just above CP's column, one row above the top of the hatched rectangle, connected by a dashed line to Pc — indicating the end pointer position after the fill.)*

**Figure C32-1 Function of AFRCT**

---
*(source page 266)*

**AFRCT (Absolute Filled Rectangle)**  PAGE: AFRCT-2

Painting in a rectangular area depends on the position of CP and Pc, as shown in Fig. C32-2. In Fig. C32-2, painting between CP and Pc is performed. CP is moved to Pe at the termination of the command. The drawing at the end point Pe is not performed.

*(Diagram: Figure C32-2 shows four small panels, each depicting a hatched horizontal rectangle with CP and Pc at diagonal corners and Pe marked with an open circle near Pc, connected by a dashed line — illustrating the four possible relative positions of CP and Pc (CP upper-left/Pc lower-right; CP upper-right/Pc lower-left; CP lower-right/Pc upper-left; CP lower-left/Pc upper-right), with the fill always spanning the rectangle between CP and Pc and Pe positioned adjacent to Pc on the side away from the fill.)*

**Figure C32-2 Painting Direction of AFRCT**

<EXAMPLE>

If the absolute coordinate of CP is (A, B) on the split screen, X is set to X1 and Y to Y1 in the command parameter, and the drawing parameter register for the pattern RAM is set to the following, the pattern start point (PSX, PSY), the pattern end point (PEX, PEY), the graphic pattern pointer (PPX, PPY), then, the rectangular area is painted with the AFRCT command as shown next page.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($C0XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| X1 ($XXXX) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Y1 ($XXXX) | | | | | | | | | | | | | | | |

---
*(source page 267)*

**AFRCT (Absolute Filled Rectangle)**  PAGE: AFRCT-3

*(Diagram: left side shows a "Pattern RAM" box with bit range labeled "bit 0" to "bit 15" and address range "PTN 0" to "PTN 15". Within it, a dashed inner rectangle marks the active pattern region bounded by "(PSX, PSY)" at its lower-left corner and "(PEX, PEY)" at its upper-right corner, with a smaller marker "(PPX, PPY)" (the graphic pattern pointer) positioned partway inside that region.)*

*(Right side: an X-Y coordinate plane with origin "ORG(0,0)". A rectangular grid area spans from "CP(A,B)" at upper-left to "Pc(X1,Y1)" at lower-right, filled with a repeating small "L"-shaped/bracket tile pattern arranged in rows and columns (the pattern from the Pattern RAM tiled across the rectangle). The open-circle point "Pe(A, Y1−1)" sits just below and left of the grid, at the row just past the bottom of the filled area.)*

**Figure C32-3 Example of AFRCT Execution**

---
*(source page 268)*

**[33] RFRCT (Relative Filled Rectangle)**  PAGE: RFRCT-1  TYPE: Graphic Command

<FUNCTION>

RFRCT command paints in the rectangular area specified with CP (Current Pointer) and the command parameter (the relative coordinates) according to a figure pattern stored in the Pattern RAM.

<MNEMONIC>

RFRCT (AREA, COL, OPM) dX, dY

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

hexadecimal notation ($C4XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dX (16 bits) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dY (16 bits) | | | | | | | | | | | | | | | |

WORD NUMBER: Wn=3

EXECUTION CYCLES: Cn=(P·A+8)B+18

<DESCRIPTION>

The Relative Filled Rectangle Command (RFRCT) paints the rectangular area according to the color information in the pattern RAM. The sizes of the rectangle are parallel to the coordinates axis. Two corner points on the diagonal are CP and Pe (A+dX, B+dY) at the relative coordinate point from CP.

Pe (dX, dY) expressed in the relative coordinate from CP is given by the command parameter in units of pixels.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)" at lower-left. A hatched rectangle spans from "CP(A,B)" at lower-left (with "dX" marking its width) to "Pc(A+dX,B+dY)" at upper-right ("dY" marking its height). The open-circle point "Pe(A,B+dY+1)" sits just above CP's column, one row above the top of the hatched rectangle, connected by a dashed line to Pc.)*

**Figure C33-1 Function of RFRCT**

---
*(source page 269)*

**RFRCT (Relative Filled Rectangle)**  PAGE: RFRCT-2

Painting in a rectangular area depends on the position of CP and Pe, as shown in Fig. C33-2. In Fig. C33-2, painting between CP and Pe is performed. CP is moved to Pe at the termination of the command. The drawing at the end point Pe is not performed.

*(Diagram: Figure C33-2 shows four small panels, each depicting a hatched horizontal rectangle with CP and Pc at diagonal corners and Pe marked with an open circle near Pc, connected by a dashed line — illustrating the four possible relative positions of CP and Pc (mirroring the AFRCT panel layout): CP upper-left/Pc lower-right; CP upper-right/Pc lower-left; CP lower-right/Pc upper-left; CP lower-left/Pc upper-right.)*

**Figure C33-2 Painting Direction of RFRCT**

<EXAMPLE>

If the absolute coordinate of CP is (A, B) on the split screen, dX is set to dX1 and dY to dY1 in the command parameter, and the drawing parameter register for the pattern RAM is set to the following, the pattern start point (PSX, PSY), the pattern end point (PEX, PEY), the graphic pattern pointer (PPX, PPY), then, the rectangular area is painted with the RFRCT command, as shown in Fig. C33-3.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($C4XX)

COMMAND PARAMETERS

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dX1 ($XXXX) | | | | | | | | | | | | | | | |

| 15 | | | | | | | | | | | | | | | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| dY1 ($XXXX) | | | | | | | | | | | | | | | |

---
*(source page 270)*

**RFRCT (Relative Freeform Rectangle Command)**  PAGE: RFRCT-3

*(Diagram: Pattern RAM diagram similar to Fig C32-3, showing a 4x4 grid labeled with PSX/PSY at the start corner and PEX/PEY at the end corner, alongside an execution-example grid on the right showing the freeform rectangle painted with the pattern, using dX1+1/dY1+1 labels to mark the pattern's repeat span along the two adjacent sides of the parallelogram.)*

**Figure C33-3 Pattern RAM and Execution Example of RFRCT (with pattern)**

---
*(source page 271)*

**[34] PAINT (Paint Command)**  PAGE: PAINT-1  TYPE: Graphic Command

<FUNCTION>

The PAINT command paints (fills) an enclosed area of the screen, starting from the Current Pointer (CP) position, with a specified color or pattern, until it reaches a boundary defined by the Edge Color.

<MNEMONIC>

PAINT

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | E | 0 | 0 | 0 | AREA | AREA | COL | COL | OPM | OPM | OPM | OPM |

($CXXX)

COMMAND PARAMETERS

None

WORD NUMBER: 1

EXECUTION CYCLES: (depends on the size and complexity of the painted area)

<DESCRIPTION>

The PAINT command fills the area surrounding the Current Pointer (CP) with the specified color, up to a boundary of the Edge Color. Painting proceeds outward from the CP in all directions until edge-color pixels are encountered on all sides.

If the Read FIFO overflows during the paint operation because the area being painted is too complex (i.e., it has too many separate line segments to paint simultaneously), the ACRTC suspends the operation and reports this condition; the remaining unpainted portion(s) of the figure can then be completed by issuing the PAINT command again with the CP repositioned to an unpainted area.

<Definition of Edge Color>

The E bit in the command code selects how the edge (boundary) color is determined:

E=0: The edge color is the single color value held in the Edge Color Register (EDG). Painting stops when a pixel matching EDG is encountered.

E=1: The edge color is defined as all colors except the value in the Edge Color Register (EDG). That is, painting stops as soon as a pixel NOT matching EDG is encountered — equivalently, only pixels equal to EDG's complement region get painted, so the fill effectively paints only through pixels of color EDG itself and stops elsewhere. (This mode is used to re-paint or flood only a specific existing color region.)

---
*(source page 272)*

**PAINT (Paint Command)**  PAGE: PAINT-2

*(Diagram: two overlapping circles, one outlined in red and one in blue, overlapping in the middle. A CP marker is shown inside one of the circles.)*

**Figure C34-1 Paint Function (E=0)** — with E=0, painting starting from CP inside the red circle fills only the region bounded by the Edge Color, stopping at the circle's outline.

*(Diagram: the same two overlapping circles (red and blue outlines), but shown with the paint spreading across the whole combined figure except the outline pixels themselves.)*

**Figure C34-2 Paint Function (E=1)** — with E=1, painting spreads through all pixels except those matching the Edge Color, filling both circles' interiors and the overlap region in one operation, stopping only at the outline pixels.

<Paint Using a Pattern>

The PAINT command can also fill the enclosed area using a pattern read from the Pattern RAM, instead of a solid color, by setting the appropriate Pattern/Color select bits.

*(Diagram: a Pattern RAM grid diagram similar to those used for AFRCT/RFRCT, alongside two overlapping ring/donut shapes rendered with a scalloped texture pattern rather than a solid fill, with a CP marker at the starting point inside one ring.)*

**Figure C34-3 Example of Paint Using a Pattern**

---
*(source page 273)*

**PAINT (Paint Command)**  PAGE: PAINT-3

<Paint Procedure>

The PAINT command fills an area by scanning horizontal lines outward from the CP, extending each line left and right until an edge-color pixel is reached, then moving to adjacent lines above and below and repeating, until the entire enclosed area is filled.

*(Diagram: a 5-panel sequence labeled (A) through (E), each showing a circle outline with the fill progressively growing as a set of horizontal lines, starting from a single line at point S near the CP in panel (A) and expanding upward and downward line-by-line through panels (B), (C), (D), until the circle is completely filled with horizontal lines in panel (E), reaching up to point Pe at the top of the circle.)*

**Figure C34-4 Paint Procedure**

<Complex Figure Painting>

When the figure to be painted has a complex shape (e.g., a shape with branches or narrow passages), the ACRTC must track multiple boundary coordinates simultaneously using an internal stack, since more than one paintable line segment may need to be resumed as the fill progresses.

*(Diagram: an irregular blob/amoeba-like outline shape, filled internally with horizontal fill lines, with 4 small dot markers placed at points along the outline representing coordinates that have been pushed onto the internal stack for later resumption.)*

**Figure C34-5 Paint Stack Function**

---
*(source page 274)*

**PAINT (Paint Command)**  PAGE: PAINT-4

When painting a complex figure, the ACRTC uses its Read FIFO as an internal stack to hold the coordinates of boundary points where the fill must resume after completing the current line segment. The stack can hold up to 4 coordinate sets, each stored as a 3-word entry:

| Word | Contents |
|---|---|
| 1 | CPx (X coordinate) |
| 2 | CPy (Y coordinate) |
| 3 | PPxy (packed flag/direction information for the pending segment) |

If the number of pending boundary points exceeds the 4-entry stack capacity, the Read FIFO overflows and the PAINT operation is suspended, as noted in PAINT-1. Two termination cases can occur:

① The entire enclosed figure is painted successfully and the stack empties normally — the command completes.

② The Read FIFO overflows before the figure is completely painted — the command terminates early, leaving part of the figure unpainted.

In case ②, it is recommended that the PAINT command be issued again with the CP repositioned inside one of the remaining unpainted areas, repeating as necessary until the entire figure has been filled.

---
*(source page 275)*

**PAINT (Paint Command)**  PAGE: PAINT-5

*(Diagram: a flowchart for painting complex figures using the PAINT command.)*

Flow: START → "WPR PS / WPR PE (Specify the pattern area)" → "WPR PP (Specify the pattern point)" → "AMOVE X,Y (Specify the start point)" → "PAINT" → decision "RFR flag = 1": if YES, branch to a sequence of three "Read FIFO" steps ("Read out the coordinate X", "Read out the coordinate Y", "Read out the pattern point"), which loop back to the "WPR PP" step; if NO, decision "CED flag = 1 and RFR flag = 0": if YES, go to END; if NO, loop back to the point just after "PAINT" (re-check RFR flag).

**Figure C34-6 Paint Flow of Complex Figures Using PAINT Command**

---
*(source page 276)*

**PAINT (Paint Command)**  PAGE: PAINT-6

<PAINT Area Detection Mode>

PAINT Area Detection modes have each of the following functions.

| AREA | PAINT Command Execution |
|---|---|
| 000 | Not check the specified area. |
| 001 | AREA flag is set and the command execution is truncated, if CP moves outside the specified area during painting. |
| 010 | Paint only inside the specified area. AREA flag is not set. |
| 011 | Paint only inside the specified area. If CP meets the edge of the specified area, AREA flag is set. |
| 100 | Not check the specified area. |
| 101 | AREA flag is set and the command execution is truncated, if CP moves inside the specified area. |
| 110 | Paint only outside the specified area. AREA flag is not set. |
| 111 | Paint only outside the specified area. If CP meets the edge of the specified area, AREA flag is set. |

---
*(source page 277)*

**PAINT (Paint Command)**  PAGE: PAINT-7

*(Diagram: five example diagrams (i) through (v), each showing an irregular blob-shaped figure positioned relative to a dashed rectangle labeled "Specified Area" with corners (XMIN,YMIN) and (XMAX,YMAX), and a CP marker inside the figure. Arrows and hatching indicate which portion of the figure gets painted under each AREA mode.)*

(i) AREA = 000, AREA = 100 — the entire figure is painted (hatched throughout), regardless of the specified area rectangle; CP is inside the figure near the top.

(ii) AREA = 001 (AREA flag is set) — figure shown unhatched (execution truncated once CP exits the specified area); CP is near the middle of the figure, roughly at the boundary of the dashed rectangle.

(iii) AREA = 010 (AREA flag is not changed), AREA = 011 (AREA flag is set) — only the portion of the figure inside the dashed rectangle is hatched (painted); CP is at the rectangle's right edge.

(iv) AREA = 101 (AREA flag is set) — figure shown unhatched; CP is inside the figure, inside the specified area boundary.

(v) AREA = 110 (AREA flag is not changed), AREA = 111 (AREA flag is set) — only the portion of the figure outside the dashed rectangle is hatched (painted); CP is at the rectangle's right edge, in the unhatched-boundary region.

**Figure C34-6A Paint Command Example with AREA Modes**

---
*(source page 278)*

**PAINT (Paint Command)**  PAGE: PAINT-8

<EXAMPLE>  (In the case of E = "0")

If a circle of the same color as specified in the edge color register (EDG) is drawn on the split screen, the pattern shown in Fig. C34-7 fetched from the pattern RAM is used and the pattern pointer (PP) is in the position shown in Fig. C34-7. Then the PAINT command with bit-8 = "0", CP in the position shown in Fig. C34-8 is executed as shown in Fig. C34-8.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($C8XX)

*(Diagram: a Pattern RAM grid (4x4-ish larger grid) with triangle markers filling most cells. "PE(PEX,PEY)" labels the top-right corner point of the pattern, "PP(PPX,PPY)" labels a point partway into the grid (with an arrow tracing from the bottom-left start diagonally to it), and "PS(PSX,PSY)" labels the bottom-left starting corner, marked with a circled dot.)*

**Figure C34-7 Setting of Pattern RAM**

---
*(source page 279)*

**PAINT (Paint Command)**  PAGE: PAINT-9

<EXECUTION EXAMPLE>  (In the case of E = "0")

*(Diagram: a large circular figure made up of concentric rings of small circle (○) and triangle (△) markers arranged in a scalloped, flower-like or gear-like pattern radiating from the center, representing the painted pattern fill. The outermost ring of circle markers is labeled "EDG" (pointing to one of the outer circle markers, upper right), marking the edge-color boundary. A "CP" label points via a line to a triangle marker near the bottom of the figure, which connects via a bent line up to a circled triangle marker near the lower-left of the pattern, indicating the paint start point and its path into the pattern fill.)*

**Figure C34-8 Example of PAINT Execution (E = "0")**

---
*(source page 280)*

**PAINT (Paint Command)**  PAGE: PAINT-10

<EXAMPLE>  (In the case of E = "1")

If a circle of the same color as specified in the edge color parameter register (EDG) is drawn on the split screen and the inside of the circle is also painted in the same color and the surround of the circle is not the same color as the edge, Fig. C34-10 (A), and the pattern shown in Fig. C34-9 is in the pattern RAM, the pattern pointer (PP) is in the position shown in Fig. C34-9. Then the PAINT command with bit 8 = "1", CP in the position shown in Fig. C34-10 (A) is executed as shown in Fig. C34-10 (B).

*(Diagram: a Pattern RAM grid with triangle markers filling most cells. "PE(PEX,PEY)" labels the top-right corner, "PP(PPX,PPY)" labels a point partway into the grid (with an arrow from the bottom-left start diagonally to it), and "PS(PSX,PSY)" labels the bottom-left starting corner, marked with a circled dot.)*

**Figure C34-9 Setting of Pattern RAM**

---
*(source page 281)*

**PAINT (Paint Command)**  PAGE: PAINT-11

*(Diagram (A): a large roughly-circular figure filled with a dense grid of alternating filled-circle (●) and open-circle (○) markers, representing two adjacent color regions. A ring of filled circles near the top is labeled "exceptional edge color" (pointing to several ● markers at the very top edge), and "EDG" labels one of the open-circle markers along the upper-right boundary. "CP" points via a diagonal line to a double-circled marker near the center of the figure.)*

*(Diagram (B): the same overall figure, but now rendered with filled-circle (●) markers around the outer ring and open-triangle (△) markers filling the interior, representing the pattern-fill result of the PAINT execution. A double-circled triangle marker sits at the center, corresponding to the CP position from diagram (A).)*

**Figure C34-10 Example of PAINT Execution (E = "1")**

---
*(source page 282)*

**[35] DOT (Dot Command)**  PAGE: DOT-1  TYPE: Graphic Command

<FUNCTION>

DOT Command marks a dot on the coordinates where the CP points.

<MNEMONIC>

DOT (AREA, COL, OPM)

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($CCXX)  (hexadecimal notation)

COMMAND PARAMETERS

— NON —

WORD NUMBER: Wn=1

EXECUTION CYCLES: Cn=8

<DESCRIPTION>

The Dot Command (DOT) marks a dot on the coordinate where the Current Pointer (CP) indicates. After dot drawing, the CP doesn't move. So, Pe, the dotting-finishing point, is the same point as the CP.

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". A single dot is marked at a point labeled both "CP(A,B)" and "Pe(A,B)" (coincident), somewhere up and to the right of the origin.)*

**Figure C35-1 Function of DOT**

---
*(source page 283)*

**DOT (Dot Command)**  PAGE: DOT-2

<EXAMPLE>

In the case of the absolute coordinate of the CP is (10, 8) on the split screen, the DOT Command marks a dot as shown in Fig. C35-2.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($CCXX)

COMMAND PARAMETERS

— NON —

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". A dot is marked at the point labeled "Pe(10,8)" / "CP(10,8)" (coincident), up and to the right of the origin.)*

**figure C35-2 Example of DOT Execution**

The LINE Commands and ARC Commands do not draw a dot at the finishing points, Pe. The DOT Command can be used to draw a dot at the Pe to draw a complete line or arc.

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

EXAMPLE

*(Diagram: two example line segments, side by side. Left: a line from "CP Start point" (bottom-left, filled dot) up to "End point Pe(X,Y)" (top-right, open circle — no dot drawn at the endpoint), labeled below with the command sequence "ALINE X,Y". Right: the same line from "CP Start point" to "End point Pe(X,Y)" but the endpoint is now a filled dot, labeled below with the command sequence "ALINE X,Y / DOT" — showing that following ALINE with DOT fills in the endpoint.)*

**Figure C35-3 DOT Command for the End Point**

---
*(source page 284)*

**[36] PTN (Pattern Command)**  PAGE: PTN-1  TYPE: Graphic Command

<FUNCTION>

The graphic pattern defined in the pattern RAM is drawn onto the rectangular area specified by the current pointer and by the pattern size.

<MNEMONIC>

PTN (SL, SD, AREA, COL, OPM) S

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | SL | SL | SL | SD | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($DXXX)  (hexadecimal notation)

COMMAND PARAMETERS

| 15 | ... | 8 | 7 | ... | 0 |
|---|---|---|---|---|---|
| SZ | SZy | | SZx | | |

SZx, SZy — Setting: 0~255; Meaning: 1~256, in units of pixels

WORD NUMBER: Wn=2

EXECUTION CYCLES: Cn=(P·A+10)·B+20

<DESCRIPTION>

As shown in Fig. C36-1, the Pattern command (PTN) is used to draw the graphic pattern defined in the pattern RAM onto the rectangular area specified by the current pointer (CP) and by the parameter (SZ: SZy, SZx). The pattern to be taken out of the pattern RAM is set by the pattern start point (PS) and pattern end point (PE).

The point at which to start pattern RAM scan to obtain color information is set by the pattern pointer (PP). The color information is set on color registers "0" and "1" for execution of pattern drawing.

Parameter SZ is divided into X component (SZx) and Y component (SZy), each component being set in units of pixels.

The PTN command has the CP scan direction set up in units of 45° in the operation code, together with the choice of 45° slanted pattern drawing. After pattern drawing, the CP is moved to the Pe (see Table C36-1).

---
*(source page 285)*

**PTN (Pattern Command)**  PAGE: PTN-2

*(Diagram: on the left, a small hatched square labeled "Pattern RAM" with a curved arrow pointing to a larger hatched diamond shape labeled "Frame Buffer" on an X-Y axis with origin "ORG(0,0)". The diamond's left vertex is at "CP", its bottom vertex is labeled with "SZx+1" along the lower-left edge, and its right vertex is labeled with "SZy+1" along the lower-right edge. Text at upper right reads "where, SL=0, SD=7".)*

**Figure C36-1 Function of PTN**

**Table C36-1 Directions of CP Scan**

*(A 4-row x 4-column table of small diagrams, organized by SL (0 or 1, two blocks of rows) and SD (000 through 111, 8 columns total split across two header rows "000/001/010/011" and "100/101/110/111"). Each cell shows a small rectangle or parallelogram (parallelogram when SL=1, indicating 45°-slanted pattern drawing) with an arrow indicating the CP scan direction, a filled dot marking the CP corner, and an open circle marking the Pe corner. The scan directions cycle through up, diagonal, left/right, and down/diagonal-reverse orientations as SD increments, with the shape rotating between upright rectangle (SD ending 00/01) and diagonal parallelogram forms (SD ending 10/11) — mirrored between the SL=0 (rectangle) and SL=1 (parallelogram) row-pairs.)*

Legend: ● = CP, ○ = Pe.

---
*(source page 286)*

**PTN (Pattern Command)**  PAGE: PTN-3

<Example of Command Execution>

From the pattern RAM, take out a pattern using the PS (PSX, PSY) and PE (PEX, PEY), and execute the PTN command.

(1) Where PP=PS, PZ=0, SZ=PE-PS, SL=0, SD=0

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($D0XX)

COMMAND PARAMETERS

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |

($0705)

*(Diagram: a Pattern RAM grid (7 rows x 6 columns of dots), with a scattered pattern of circled dots (⊙) representing "1" pixels among plain dots ("0" pixels), forming a rough diagonal/diamond arrangement. "PE(PEX,PEY)" labels the top-right area, "PTN 15" labels the top edge, "PTN 0" and "PS(PSX,PSY)=PP" label the bottom-left corner, "bit 0" and "bit 15" label the horizontal extent.)*

*(Diagram: a matching Frame Buffer grid showing the same dot pattern replicated exactly, with "Pe" labeling the top-left area and "CP" labeling the bottom-left corner — showing the pattern copied as-is from Pattern RAM into the Frame Buffer starting at CP.)*

**Figure C36-2 Example of PTN Execution (1)**

---
*(source page 287)*

**PTN (Pattern Command)**  PAGE: PTN-4

(2) Where PP≠PS, PZ=0, SZ=PE-PS, SL=0, SD=0

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($D0XX)

COMMAND PARAMETERS

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |

($0705)

*(Diagram: a Pattern RAM grid (same dot pattern as Fig C36-2) with "PE(PEX,PEY)" at top and "PS(PSX,PSY)" at bottom-left; unlike the previous figure, "PP(PPX,PPY)" is now labeled separately at a different point within the grid (an arrow curves from near PS over to the PP point), indicating the pattern scan starts mid-pattern rather than at PS.)*

*(Diagram: a matching Frame Buffer grid showing the resulting copied pattern, which is now rotated/offset (wrapped) relative to Fig C36-2's result because the scan started from the different PP position; "Pe" labels the top area and "CP" the bottom-left corner.)*

**Figure 36-3 Example of PTN Execution (2)**

---
*(source page 288)*

**PTN (Pattern Command)**  PAGE: PTN-5

(3) Where PP=PS, PZ=0, SZ<PE-PS, SL=0, SD=0

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($D0XX)

COMMAND PARAMETERS

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 1 |

($0403)

*(Diagram: the same Pattern RAM grid pattern as before, with "PE(PEX,PEY)" at top and "PS(PSX,PSY)=PP" at bottom-left, "PTN 15"/"PTN 0" and "bit 0"/"bit 15" labels.)*

*(Diagram: a smaller Frame Buffer grid (only 6 rows x 4 columns, since SZ is smaller than PE-PS) showing only a cropped subset of the pattern copied — the top-right portion of the full pattern is truncated because the specified size (SZ) is smaller than the full pattern extent (PE-PS). "Pe" labels the top-left area and "CP" the bottom-left corner.)*

**Figure 36-4 Example of PTN Execution (3)**

---
*(source page 289)*

**PTN (Pattern Command)**  PAGE: PTN-6

(4) Where PP=PS, PZ=0, SZ>PE-PS, SL=0, SD=0

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($D0XX)

COMMAND PARAMETERS

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 |

($0F0B)

*(Diagram: the same Pattern RAM grid pattern as before, with "PE(PEX,PEY)" at top and "PS(PSX,PSY)=PP" at bottom-left.)*

*(Diagram: a larger Frame Buffer grid (roughly 13 rows x 11 columns, since SZ is larger than PE-PS) showing the pattern tiled/repeated to fill the larger specified area — the base pattern block is repeated both horizontally and vertically to cover the full SZ extent, since SZ exceeds the source pattern's own size (PE-PS). "Pe" labels the top-left area and "CP" the bottom-left corner.)*

**Figure 36-5 Example of PTN Execution (4)**

---
*(source page 290)*

**PTN (Pattern Command)**  PAGE: PTN-7

(5) Where PP=PS, PZX=1, PZY=1, SZ>PE-PS, SL=0, SD=0

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($D0XX)

COMMAND PARAMETERS

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 1 | 1 |

($0F0B)

*(Diagram: the same Pattern RAM grid pattern as before, with "PE(PEX,PEY)" at top and "PS(PSX,PSY)=PP" at bottom-left.)*

*(Diagram: a larger Frame Buffer grid showing the pattern tiled to fill a larger area, but with the tiled pattern-instances offset diagonally from row to row (a "brick-like" staggered tiling) rather than aligned in a simple grid, because PZX=1 and PZY=1 introduce a diagonal stagger between successive pattern repeats. "Pe" and "CP" mark the top-left and bottom-left reference corners respectively.)*

**Figure 36-6 Example of PTN Execution (5)**

---
*(source page 291)*

**PTN (Pattern Command)**  PAGE: PTN-8

(6) Where PP=PS, PZ=0, SZ=PE-PS, SL=1, SD=0

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 1 | 0 | 0 | 0 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($D8XX)

COMMAND PARAMETERS

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |

($0705)

*(Diagram: the same Pattern RAM grid pattern as before, with "PE(PEX,PEY)" at top and "PS(PSX,PSY)=PP" at bottom-left.)*

*(Diagram: a Frame Buffer grid showing the pattern drawn at a 45° slant (SL=1) — the same pattern shape but sheared diagonally so that it runs from lower-left "CP" up to upper-right "Pe" along a 45° diagonal axis instead of the horizontal/vertical axes used in the earlier examples.)*

**Figure 36-7 Example of PTN Execution (6)**

---
*(source page 292)*

**PTN (Pattern Command)**  PAGE: PTN-9

(7) Where PP=PS, PZ=0, SZ=PE-PS, SL=0, SD=1

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 0 | 1 | 0 | 0 | 0 | 1 | AREA | AREA | AREA | COL | COL | OPM | OPM | OPM |

($D1XX)

COMMAND PARAMETERS

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |

($0705)

*(Diagram: the same Pattern RAM grid pattern as before, with "PE(PEX,PEY)" at top and "PS(PSX,PSY)=PP" at bottom-left.)*

*(Diagram: a much larger Frame Buffer grid (roughly 14 rows x 16 columns) showing the pattern's individual "1" pixels scattered widely apart from each other (spread out with large gaps between marked dots) rather than densely packed — reflecting SD=1's different pixel scan-spacing/direction setting, which spreads the pattern across a wider area than SD=0. "Pe" labels a point on the left side and "CP" labels a point near the bottom.)*

**Figure 36-8 Example of PTN Execution (7)**

---
*(source page 293)*

**[37] AGCPY (Absolute Graphic Copy)**  PAGE: AGCPY-1  TYPE: Graphic Command

<FUNCTION>

AGCPY command copies a rectangular area specified by the absolute coordinates to the address specified by CP (Current Pointer).

<MNEMONIC>

AGCPY (S, DSD, AREA, COL, OPM) Xs, Ys, DX, DY

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 0 | S | DSD | DSD | DSD | AREA | AREA | 0 | 0 | OPM | OPM | OPM | OPM |

($EXXX)  (hexadecimal notation)

COMMAND PARAMETERS

| Word | Contents |
|---|---|
| 1 | Xs (bits 15-0) |
| 2 | Ys (bits 15-0) |
| 3 | DX (bits 15-0) |
| 4 | DY (bits 15-0) |

WORD NUMBER: Wn=5

EXECUTION CYCLES: Cn=((P+2)A+10)B+70

<DESCRIPTION>

The Absolute Graphic Copy Command (AGCPY) copies data from a rectangular area in the frame buffer (the source area) to another location in the frame buffer (the destination area) with the initial starting point CP. The size of the source rectangular area is parallel to the coordinate axis. Two diagonal corner points are Pss (Xs, Ys) at the absolute coordinate point from the origin and Pse (Xs+DX, Ys+DY) at the relative coordinate point from Pss.

Pss (Xs, Ys) expressed by absolute X-Y coordinates from the origin are set in the command parameter in units of pixels.

Pse (DX, DY) expressed by relative X-Y coordinates from Pss are set in the command parameter in units of pixels.

---
*(source page 294)*

**AGCPY (Absolute Graphic Command)**  PAGE: AGCPY-2

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". A "Source area" rectangle sits to the right, with its bottom-left corner "Pss(Xs,Ys)" and top-right corner "Pse(Xs+DX,Ys+DY)"; four filled dots inside it represent sample pixels, with "DX" labeling the horizontal span and "DY" the vertical span at the top-right corner. Below/left, "Xs" and "Ys" are marked as the distances from ORG to Pss along the X and Y axes respectively. A "Destination area" rectangle sits to the upper-left, with its bottom-left corner "CP(A,B)" and top "Pe(A,B+DX+1)" (labeled with an open circle), containing four filled dots representing the copied pixels; "A" and "B" mark the distances from ORG to CP along the X and Y axes. A bold leftward arrow between the two rectangles indicates the direction of the copy operation, from the source area to the destination area. Text at the right reads "Direction of scan: S=1, DSD=000".)*

**Figure C37-1 Function of AGCPY**

<DIRECTION OF POINTER SCAN>

The direction of pointer scan is determined by S bit and DSD bit in the command code through the AGCPY command.

(a) S (Source Scan Direction)

COMMAND CODE

| 15 | ... | 11 | ... | 0 |
|---|---|---|---|---|
| | | S | | |

---
*(source page 295)*

**AGCPY (Absolute Graphic Command)**  PAGE: AGCPY-3

**Table C37-1 Direction of Source Data Scan**

*(A table of 8 small square diagrams split into two rows, S=0 (top row, 4 diagrams) and S=1 (bottom row, 4 diagrams). Each diagram shows a rectangle with a filled dot marking "Pss" and an open circle marking "Pse" at two of its corners, plus arrows indicating the scan direction across the rectangle: for S=0, the scans run vertically (up or down) combined with one horizontal edge arrow; for S=1, the scans run horizontally (left or right) combined with vertical double-arrows along one edge. The four columns in each row show Pss/Pse placed at the four different corner-pair combinations, producing the four possible scan direction variants.)*

Legend: ● = Pss, ○ = Pse.

The direction of scan on the frame buffer in the source area is determined with bit 11 in the command code and the position of Pss and Pse, as shown in Table C37-1.

(b) DSD (Destination Scan Direction)

COMMAND CODE

| 15 | ... | 10 9 8 | ... | 0 |
|---|---|---|---|---|
| | | DSD | | |

---
*(source page 296)*

**AGCPY (Absolute Graphic Copy)**  PAGE: AGCPY-4

**Table C37-2 Direction of Destination Data Scan**

*(A table of 8 small square diagrams arranged in two rows of four, labeled DSD=000, 001, 010, 011 (top row) and DSD=100, 101, 110, 111 (bottom row). Each diagram shows a rectangle with a filled dot marking "CP" and an open circle marking "Pe" at two of its corners, plus arrows indicating the scan direction: for DSD=000/001/010/011, the scans run vertically (up or down) combined with one horizontal edge arrow; for DSD=100/101/110/111, the scans run horizontally (left or right) combined with vertical double-arrows along one edge. The four columns in each row show CP/Pe placed at the four different corner-pair combinations, producing the eight possible scan direction variants.)*

Legend: ● = CP, ○ = Pe.

As shown Table C37-2, the direction of scan on the frame buffer in the destination area is determined with bits 10 through 8 in the command code and position of CP and Pe.

After termination of the command, Pe, the end point of CP, is moved to the point shown in Table C37-2.

<EXAMPLE>

If the absolute coordinates of CP is (4, 2) on the split screen, Xs is set to 18, Ys is set to 2, DX is set to 13 and DY is set to 7 in the command parameter. Then, the drawing is copied by the AGCPY command (S = 1, DSD = 000), as shown in Fig. C37-2 (B).

---
*(source page 297)*

**AGCPY (Absolute Graphic Copy)**  PAGE: AGCPY-5

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | AREA | AREA | 0 | 0 | OPM | OPM | OPM | OPM |

($E0XX)

COMMAND PARAMETERS

| Word | Value | Hex |
|---|---|---|
| 1 (Xs) | 0000 0000 0001 0010 | $0012 |
| 2 (Ys) | 0000 0000 0000 0010 | $0002 |
| 3 (DX) | 0000 0000 0000 1101 | $000D |
| 4 (DY) | 0000 0000 0000 0111 | $0007 |

*(Diagram (A) "Before Execution of AGCPY": an X-Y plane with origin "ORG(0,0)", showing a hatched rectangle with corners "(28,6)" (bottom-left, filled dot) and "(34,12)" (top-right, filled dot).)*

*(Diagram (B) "After Execution of AGCPY": an X-Y plane with origin "ORG(0,0)". A dashed "Destination area" rectangle runs from "CP(4,2)" (bottom-left) up to "Pe(4,16)" (top-left, open circle), containing a small hatched rectangle labeled with corners "(8,12)" and "(11,15)". To the right, "Pss(18,2)" (filled dot) sits at the base of a "Source area" hatched rectangle, with "18" marking the distance from ORG to Pss along X; a "2" marks a small vertical offset; "13" marks the horizontal span from Pss to below "Pse(31,9)" (open circle), and "7" marks the vertical span up to Pse. A dashed path connects CP up and across to Pss/Pse, indicating the copy source-to-destination relationship.)*

**Figure C37-2 Example of AGCPY Execution**

---
*(source page 298)*

**[38] RGCPY (Relative Graphic Copy)**  PAGE: RGCPY-1  TYPE: Graphic Command

<FUNCTION>

RGCPY command copy a rectangular area specified by the relative coordinates based on CP (Current Pointer) to an address specified by CP.

<MNEMONIC>

RGCPY (S, DSD, AREA, COL, OPM) dXs, dYs, DX, DY

<FORMAT>

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | S | DSD | DSD | DSD | AREA | AREA | 0 | 0 | OPM | OPM | OPM | OPM |

($FXXX)  (hexadecimal notation)

COMMAND PARAMETERS

| Word | Contents |
|---|---|
| 1 | dXs (bits 15-0) |
| 2 | dYs (bits 15-0) |
| 3 | DX (bits 15-0) |
| 4 | DY (bits 15-0) |

WORD NUMBER: Wn=5

EXECUTION CYCLES: Cn=((P+2)A+10)B+70

<DESCRIPTION>

The Relative Graphic Copy Command (RGCPY) copies data from an rectangular area in the frame buffer (the source area) to another location in the frame buffer (the destination area) with the initial starting point CP. The size of the source rectangular area is parallel to the coordinate axis. Two diagonal corner points are Pss (A+dXs, B+dYs) at the absolute coordinate point from CP and Pse (A+dXs+DX, B+dYs+DY) at the relative coordinate point from Pss.

Pss (dXs, dYs) expressed by the relative X-Y coordinates from CP are set in the command parameter in units of pixels.

Pse (DX, DY) expressed by the relative X-Y coordinates from Pss are set in the command parameter in units of pixels.

---
*(source page 299)*

**RGCPY (Relative Graphic Copy)**  PAGE: RGCPY-2

*(Diagram: an X-Y coordinate plane with origin "ORG(0,0)". A "Destination area" rectangle runs from "CP(A,B)" (bottom-left) up to "Pe(A,B+DX+1)" (top-left, open circle), with "A" and "B" marking the distances from ORG to CP along X and Y respectively, and four filled dots inside representing sample copied pixels. A bold leftward arrow points from the source area to the destination area. To the right, "Pss(A+dXs,B+dYs)" (filled dot) marks the base of a "Source area" rectangle, with "dXs" marking the horizontal offset from CP to Pss and "dYs" the vertical offset; "DX" labels the horizontal span of the source rectangle and "DY" the vertical span up to "Pse(A+dXs+DX,B+dYs+DY)" (open circle) at its top-right corner. Several filled dots inside the source rectangle represent sample source pixels. Text at the right reads "Direction of Scan: S=1, DSD=000".)*

**Figure C38-1 Function of RGCPY**

<DIRECTION OF POINTER SCAN>

S-bit and DSD bit in the RGCPY command have the same function as those in the AGCPY command. Refer to the description about the AGCPY command for details.

<EXECUTION EXAMPLE>

If the absolute coordinate of CP is (4, 2) on the split screen, dXs is set to 18, dYs to 2, DX to 12 and DY to 6 in the command parameter. Then, the drawing is executed by the RGCPY command (S = 1, DSD = 000), as shown in Fig. C38-2 (B).

---
*(source page 300)*

**RGCPY (Relative Graphic Copy)**  PAGE: RGCPY-3

COMMAND CODE

| 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | AREA | AREA | 0 | 0 | OPM | OPM | OPM | OPM |

($F0XX)

COMMAND PARAMETERS

| Word | Value | Hex |
|---|---|---|
| 1 (dXs) | 0000 0000 0001 0010 | $0012 |
| 2 (dYs) | 0000 0000 0000 0010 | $0002 |
| 3 (DX) | 0000 0000 0000 1100 | $000C |
| 4 (DY) | 0000 0000 0000 0110 | $0006 |

*(Diagram (A) "Before execution of RGCPY": an X-Y plane with origin "ORG(0,0)", showing a hatched rectangle with corners "(28,6)" (bottom-left, filled dot) and "(40,13)" (top-right, filled dot).)*

*(Diagram (B) "After execution of RGCPY": an X-Y plane with origin "ORG(0,0)". "CP(4,2)" (filled dot, bottom-left) connects via "18" to "Pss(22,4)" (filled dot), with a small vertical "2" offset. A dashed "Destination area" rectangle runs from CP up to "Pe(4,15)" (open circle), containing a small hatched rectangle at corners "(6,8)" and "(10,14)". To the right of Pss, "12" marks the horizontal span to below "Pse(34,10)" (open circle), and "6" marks the vertical span up to Pse, with a hatched "Source area" rectangle at that location.)*

**Figure C38-2 Example of RGCPY Execution**

---
*(source page 301)*

# USE OF ARC AND ELLIPSE ARC COMMAND

---
*(source page 302)*

*(This page is blank.)*

---
*(source page 303)*

○ Use of Arcs and Ellipse Arcs Commands

How to Calculate Parameters of Arc Commands

AARC Xc, Yc, Xe, Ye;
RARC dXc, dYc, dXe, dYe;

(Command Issuing Procedure)

CP is moved to the start point (CPx, CPy) by MOVE, then ARC is issued.

[Example 1] Given center coordinates (Xc, Yc), radius r, drawing start angle θ1 and drawing end angle θ2, calculate as follows (counterclockwise rotation):

*(Diagram: a circle with center "(Xc,Yc)" (dashed outline). A filled dot on the circle at the right marks the start point "(CPx,CPy)", with angle θ1 measured from the horizontal radius to the line from center to that point, and "r" labeling the radius along that horizontal line. An open circle above-left on the circle marks the end point "(Xe,Ye)", with angle θ2 measured counterclockwise from the horizontal to the line from center to that point. A tangent line extends outward from the end point.)*

(Parameter calculation: ① absolute addressing)

• Calculate the start point (CPx, CPy):
CPx = Xc + [r cos θ1 ↕]
CPy = Yc + [r sin θ1 ↕]

• Calculate the end point (Xe, Ye):
Xe = Xc + [R cos θ2 ↓]
Ye = Yc + [R sin θ2 ↓]  (where, R = √((CPx−Xc)²+(CPy−Yc)²) ≒ r)

(Parameter calculation: ② relative addressing)

• Calculate the start point (CPx, CPy):
CPx = Xc + [r cos θ1 ↕]
CPy = Yc + [r sin θ1 ↕]  Same as in absolute addressing

• Calculate the center coordinates (dXc, dYc):
dXc = − [r cos θ1 ↕]
dYc = − [r sin θ1 ↕]

• Calculate the end point (dXe, dYe):
dXe = dXc + [R cos θ2 ↓]
dYe = dYc + [R sin θ2 ↓]  where, (R = √((CPx−Xc)²+(CPy−Yc)²) ≒ r)

---
*(source page 304)*

[Example 2] Given center coordinates (Xc, Yc), start point (CPx, CPy) and drawing angle θ, calculate as follows (counterclockwise rotation):

*(Diagram: a circle with center "(Xc,Yc)" (dashed outline). A filled dot on the circle at the right marks the start point "(CPx,CPy)", with angle θ1 from the horizontal to the line from center to that point. An open circle above-left marks the end point "(Xe,Ye)", with angle θ measured from the start-point line to the end-point line. A tangent line extends outward from the end point.)*

(Parameter calculation: ① absolute addressing)

• Calculate the end point (Xe, Ye):
Xe = Xc + [R cos(θ+θ1) ↓]
Ye = Yc + [R sin(θ+θ1) ↓]
where, R = √((CPx−Xc)²+(CPy−Yc)²), θ1 = tan⁻¹((CPy−Yc)/(CPx−Xe))

(Parameter calculation: ② relative addressing)

• Calculate the center coordinates (dXc, dYc):
dXc = Xc − CPx
dYc = Yc − CPy

• Calculate the end point (dXe, dYe):
dXe = dXc + [R cos(θ+θ1) ↓]
dYe = dYc + [R sin(θ+θ1) ↓]
where, R = √((CPx−Xc)²+(CPy−Yc)²), θ1 = tan⁻¹((CPy−Yc)/(CPx−Xe))

[Example 3] Calculate parameters for an Arc that passes 3 points, (CPx, CPy), (X, Y) and (Xe, Ye).

*(Diagram: an arc passing through three points on an X-Y plane. "(Xc,Yc)" (open circle, bottom-left, the arc's start reference) connects to "(CPx,CPy)" (filled dot, bottom-right) via a horizontal baseline marked "ΔX" and vertical "ΔY". The arc itself passes through "(Xe,Ye)" (open circle, upper-left) and "(X,Y)" (open circle, top, marked with "dX" and "dY" to its right). "dXe" and "dYe" label the offsets from (Xc,Yc) to (Xe,Ye), and "r" labels a radius line from (Xc,Yc) to (X,Y).)*

(Parameter calculation: Relative addressing)

dX = X − CPx
dY = Y − CPy

dXe = Xe − CPx
dYe = Ye − CPy

---
*(source page 305)*

• Calculate the center coordinates (dXc, dYc):

ΔX² + ΔY² = r²
(ΔX + dX)² + (ΔY + dY)² = r²
(ΔX + dXe)² + (ΔY + dYe)² = r²

where,

dXc = [−ΔX ↕]
   = [½ · ((dX²+dY²)·dYe − (dXe²+dYe²)·dY) / (dX·dYe − dXe·dY) ↕]

dYc = [−ΔY ↕]
   = [½ · ((dXe²+dYe²)·dX − (dX²+dY²)·dXe) / (dX·dYe − dXe·dY) ↕]

---
*(source page 306)*

○ Calculating Parameters of Ellipse Arc Commands

AEARC a, b, Xc, Yc, Xe, Ye;
REARC a, b, dXc, dYc, dXe, dYe;

(Command Issuing Procedure)

[Example 1] Given center coordinates (Xc, Yc), X direction axial length A, Y direction axial length B, drawing start angle θ1 and drawing end angle θ2, calculate as follows (counterclockwise rotation):

*(Diagram: an ellipse with center "(Xc,Yc)" (dashed outline), with "A" labeling the horizontal semi-axis and "B" the vertical semi-axis. A filled dot on the ellipse at the right marks the start point "(CPx,CPy)", with angle θ1 from the horizontal to the line from center to that point. An open circle above-left marks the end point "(Xe,Ye)", with angle θ2 measured counterclockwise from the horizontal. A tangent line extends outward from the end point.)*

(Parameter calculation: ① absolute addressing)

• Calculate the axial length square ratio (a/b): The ratio should be an integral ratio satisfying a/b = A²/B².

• Calculate the start point (CPx, CPy):
CPx = Xc + [A cos θ1 ↕]
CPy = Yc + [B sin θ1 ↕]

• Calculate the end point (Xe, Ye):
Xe = Xc + [√a R′ cos θ2 ↓]
Ye = Yc + [√b R′ sin θ2 ↓]
where R′ = √((CPx−Xc)²/a + (CPy−Yc)²/b) ≒ A/√a or B/√b

(Parameter calculation: ② relative addressing)

• Calculate the start point (CPx, CPy):
CPx = Xc + [A cos θ1 ↓]
CPy = Yc + [B sin θ1 ↓]  Same as in absolute addressing

• Calculate the center coordinates (dXc, dYc):
dXc = − [A cos θ1 ↓]
dYc = − [B sin θ1 ↓]

• Calculate the end point (dXe, dYe):
dXe = dXc + [√a R′ cos θ2 ↓]
dYe = dYc + [√b R′ sin θ2 ↓]
where R′ = √((CPx−Xc)²/a + (CPy−Yc)²/b) ≒ A/√a or B/√b

---
*(source page 307)*

[Example 2] Given center coordinates (Xc, Yc), axial length square ratio a/b, drawing start point (CPx, CPy) and drawing angle θ, calculate as follows (counterclockwise rotation):

*(Diagram: an ellipse with center "(Xc,Yc)" (dashed outline). A filled dot on the ellipse at the right marks the start point "(CPx,CPy)", with angle θ1 from the horizontal to the line from center to that point. An open circle above-left marks the end point "(Xe,Ye)", with angle θ measured from the start-point line to the end-point line. A tangent line extends outward from the end point.)*

(parameter calculation: ① absolute addressing)

• Calculate the end point (Xe, Ye):
Xe = Xc + [√a R′ cos(θ+θ1) ↓]
Ye = Yc + [√b R′ sin(θ+θ1) ↓]
where R′ = √((CPx−Xc)²/a + (CPy−Yc)²/b)
θ1 = tan⁻¹(√(a/b) · (CPy−Yc)/(CPx−Xc))

(Parameter calculation: ② relative addressing)

• Calculate the center coordinates (dXc, dYc):
dXc = Xc − CPx
dYc = Yc − CPy

• Calculate the end point (dXe, dYe):
dXe = dXc + [√a R′ cos(θ+θ1) ↓]
dYe = dYc + [√b R′ sin(θ+θ1) ↓]
where R′ = √((CPx−Xc)²/a + (CPy−Yc)²/b)
θ1 = tan⁻¹(√(a/b) · (CPy−Yc)/(CPx−Xc))

[Example 3] Calculate parameters for an ellipse arc that passes 3 points, (CPx, CPy), (X, Y) and (Xe, Ye) (axial length square ratio: a/b).

*(Diagram: an ellipse arc passing through three points on an X-Y plane. "(Xc,Yc)" (open circle, bottom-left) connects to "(CPx,CPy)" (filled dot, bottom-right) via baseline "ΔX" and vertical "ΔY". The arc passes through "(Xe,Ye)" (open circle, upper-left) and "(X,Y)" (open circle, top, marked with "dX" and "dY"). "dXe" and "dYe" label offsets from (Xc,Yc) to (Xe,Ye), and "r" labels a line from (Xc,Yc) to (X,Y), with angle γ marked at (Xc,Yc).)*

(Parameter calculation: Relative addressing)

dX = X − CPx      dXe = Xe − CPx
dY = Y − CPy      dYe = Ye − CPy

---
*(source page 308)*

• Calculate the center coordinates (dXc, dYc):

ΔX²/a + ΔY²/b = r²
(ΔX+dX)²/a + (ΔY+dY)²/b = r²
(ΔX+dXe)²/a + (ΔY+dYe)²/b = r²

we get

dXc = [−ΔX ↕]
   = [1/(2b) · ((b·dX²+a·dY²)·dYe − (b·dXe²+a·dYe²)·dY) / (dX·dYe − dXe·dY) ↕]

dYc = [−ΔY ↕]
   = [1/(2a) · ((b·dXe²+a·dYe²)·dX − (b·dX²+a·dY²)·dXe) / (dX·dYe − dXe·dY) ↕]

Note:
[↕]: With sign unchanged, rounding the absolute value to the integer.
[↑]: With sign unchanged, round up the absolute value to the integer.
[↓]: With sign unchanged, truncate the absolute value to the integer.

---
