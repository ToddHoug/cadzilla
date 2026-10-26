; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
; CZDIAG.INC -- czdiag: board ports, ACRTC bits and opcodes, CP/M
;
; czdiag is standalone: it links neither czgfx nor cz88gfx, so a library
; bug can't hide (or fake) a hardware fault. These equates repeat what
; tools/z88dk/include/cadzilla.h and czgfx's CZGFX.INC define.
;
; The board's I/O base is set by SW1-1..5. The 8080 IN and OUT take the
; port as an immediate byte, so it is fixed at build time: for another
; base put -DCZBASE=0x.. in the project's z88dk.flags.
;
        IFNDEF  CZBASE
CZBASE  EQU     70H
        ENDIF
;
; ---- board I/O map ----
;
ACRSR   EQU     CZBASE+0        ;ACRTC RS=0: AR (write) / SR (read)
MODEREG EQU     CZBASE+1        ;MODE register, U41 (write only)
ACRDAT  EQU     CZBASE+2        ;ACRTC RS=1: register data / FIFOs
NODEC   EQU     CZBASE+3        ;not decoded
DACADR  EQU     CZBASE+4        ;Bt453 address register (C1C0 = 00)
DACPAL  EQU     CZBASE+5        ;Bt453 palette RAM R,G,B (01)
DACAD2  EQU     CZBASE+6        ;Bt453 address register again (10)
DACOVL  EQU     CZBASE+7        ;Bt453 overlay colors R,G,B (11)
;
; ---- MODE register bits ----
;
MDHSP   EQU     01H             ;HSPOL: 1 = negative horizontal sync
MDVSP   EQU     02H             ;VSPOL: 1 = negative vertical sync
MDAMOD  EQU     04H             ;AMODE: interleaved -- never set by czdiag
MDOLEN  EQU     08H             ;OLEN: overlay shown
MDOLSL  EQU     10H             ;OLSEL: overlay half a CHR screen reaches
;
; ---- ACRTC status register ----
;
SRWFE   EQU     01H             ;write FIFO empty
SRWFR   EQU     02H             ;write FIFO ready (not full)
SRRFR   EQU     04H             ;read FIFO ready (holds data)
SRRFF   EQU     08H             ;read FIFO full
SRLPD   EQU     10H             ;light pen strobe detected
SRCED   EQU     20H             ;command end
SRARD   EQU     40H             ;area detect
SRCER   EQU     80H             ;command error
SRIDLE  EQU     23H             ;after reset or abort: CED WFR WFE
;
; ---- ACRTC control registers (AR values) ----
;
RCCR    EQU     02H             ;command control
ROMR    EQU     04H             ;operation mode
RDCR    EQU     06H             ;display control (r07 = ATR, free)
RRCR    EQU     80H             ;raster count (read only)
;
OMRSTP  EQU     80B0H           ;OMR: M/S=1, STR=0, SRAM, GAI +8, single
OMRRUN  EQU     0C0B0H          ;the same, STR=1
CCR8BP  EQU     0300H           ;CCR: GBM=011 8 bpp, no interrupts
CCRABT  EQU     8300H           ;the same with ABT
;
; ---- ACRTC commands (high bytes or whole words) ----
;
OPORG   EQU     0400H           ;ORG DPH DPL
OPWPR   EQU     0800H           ;WPR (RN) D
OPRPR   EQU     0C00H           ;RPR (RN)
OPWPTN  EQU     1800H           ;WPTN (PRA) n(bytes), D1..
OPRPTN  EQU     1C00H           ;RPTN (PRA) n(words)
OPDRD   EQU     2400H           ;DRD AX AY (program-controlled DMA read)
OPDWT   EQU     2800H           ;DWT AX AY, D1..
OPRD    EQU     4400H           ;RD (the word at RWP)
OPWT    EQU     4800H           ;WT D
OPCLR   EQU     5800H           ;CLR D AX AY
OPAMOV  EQU     8000H           ;AMOVE X Y
OPALIN  EQU     8800H           ;ALINE X Y
OPARCT  EQU     9000H           ;ARCT X Y
OPAFRC  EQU     0C000H          ;AFRCT X Y
OPBAD   EQU     0000H           ;not a command: must set CER
;
; RWP's screen field (Pr0C bits 15-14)
;
DNUPR   EQU     00H             ;upper screen: the overlay's CHR screen
DNBASE  EQU     40H             ;base screen: the frame buffer
;
; ---- a display mode's descriptor (TABLES.Z88) ----
;
MDMODE  EQU     0               ;DB MODE register value
MDRTAB  EQU     1               ;DW its control register table
MDDTAB  EQU     3               ;DW its drawing parameters: DPMLEN words,
                                ;   then the overlay's ORG (3 words)
MDXMAX  EQU     5               ;DW X max
MDYMAX  EQU     7               ;DW Y max
MDWMAX  EQU     9               ;DW words per raster - 1
MDHCYC  EQU     11              ;DW memory cycles per raster (HC + 1)
MDVC    EQU     13              ;DW rasters per frame (VC)
MDPCLK  EQU     15              ;DW its pixel clock, kHz
MDNAME  EQU     17              ;DW its name, a $-string
;
DPMLEN  EQU     7               ;frame words of a mode's parameters
;
; ---- CP/M ----
;
BDOS    EQU     0005H
CTAIL   EQU     0080H           ;command tail: length, then the text
CR      EQU     0DH
LF      EQU     0AH
ESC     EQU     1BH
CTLC    EQU     03H
