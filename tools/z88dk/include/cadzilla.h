/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * cadzilla.h -- the CADzilla board's I/O ports, for C programs built with
 * z88dk's zcc (tools/z88dk/zccbuild.sh puts this directory on the include
 * path of every zcc project: #include <cadzilla.h>).
 *
 * Sources: docs/cadzilla-manual.pdf (I/O map, MODE register, SW1), the
 * U45/U46/U60 decode equations in pld/src/, and the HD63484 and Bt453
 * datasheets in docs/datasheets/. Nothing here depends on czgfx.
 *
 * Every port is an __sfr: reading or assigning it compiles to ONE inline
 * IN or OUT instruction on the 8080, 8085 and Z80 -- no call, no shared
 * state, safe to use from main-line code and interrupt handlers alike:
 *
 *     unsigned char sr = CZ_ACRTC_SR;      // in  a,(CZ_BASE+0)
 *     CZ_MODE = CZ_MODE_HSPOL;             // out (CZ_BASE+1),a
 *
 * Two cautions, both about sequences rather than single accesses:
 *   - Polling loops: sccz80 widens the test around an __sfr read to 16 bits
 *     and calls library helpers on every pass. Poll in a .Z88 function
 *     instead (tools/z88dk/README.md, "Port I/O").
 *   - Multi-access sequences are not atomic: an ACRTC address-register write
 *     followed by data accesses, or a Bt453 address write followed by its
 *     three R,G,B accesses. If an interrupt handler also talks to the same
 *     chip, disable interrupts around the sequence.
 */
#ifndef CADZILLA_H
#define CADZILLA_H

/*
 * ---- The board's 8-port block ----
 *
 * SW1-1..SW1-5 set I/O address bits 7..3, so the board sits at an 8-port
 * aligned base anywhere in the 8-bit I/O space. 70H is the standard setting;
 * a board strapped elsewhere overrides it for the whole project with
 * -DCZ_BASE=0x.. in zcc.flags.
 */
#ifndef CZ_BASE
#define CZ_BASE 0x70
#endif

/* Port numbers, for code that needs the number itself (e.g. to hand to a
 * .Z88 routine). */
#define CZ_PORT_ACRTC_SR    (CZ_BASE + 0)   /* HD63484 RS=0: status (R)          */
#define CZ_PORT_ACRTC_AR    (CZ_BASE + 0)   /* HD63484 RS=0: address reg (W)     */
#define CZ_PORT_MODE        (CZ_BASE + 1)   /* board MODE register (W only)      */
#define CZ_PORT_ACRTC_DATA  (CZ_BASE + 2)   /* HD63484 RS=1: control reg / FIFO  */
                                            /* +3: reserved, not decoded         */
#define CZ_PORT_DAC_ADDR    (CZ_BASE + 4)   /* Bt453 C1C0=00: address register   */
#define CZ_PORT_DAC_PAL     (CZ_BASE + 5)   /* Bt453 C1C0=01: color palette RAM  */
                                            /* +6: Bt453 C1C0=10, the address    */
                                            /*     register again (use +4)       */
#define CZ_PORT_DAC_OVL     (CZ_BASE + 7)   /* Bt453 C1C0=11: overlay registers  */

/* The ports themselves. */
__sfr __at (CZ_BASE + 0) CZ_ACRTC_SR;       /* read:  ACRTC Status Register      */
__sfr __at (CZ_BASE + 0) CZ_ACRTC_AR;       /* write: ACRTC Address Register     */
__sfr __at (CZ_BASE + 1) CZ_MODE;           /* write only -- keep a copy         */
__sfr __at (CZ_BASE + 2) CZ_ACRTC_DATA;     /* the register AR selects / FIFO    */
__sfr __at (CZ_BASE + 4) CZ_DAC_ADDR;       /* palette / overlay address         */
__sfr __at (CZ_BASE + 5) CZ_DAC_PAL;        /* palette R,G,B (3 accesses each)   */
__sfr __at (CZ_BASE + 7) CZ_DAC_OVL;        /* overlay R,G,B (3 accesses each)   */

/*
 * ---- MODE register (CZ_MODE, write only) ----
 *
 * Board options outside the HD63484's own registers. It can't be read back,
 * so keep the last value written in a variable and update that. Bits 5-7
 * are reserved: write them as 0.
 */
#define CZ_MODE_HSPOL   0x01    /* HSYNC polarity: 0 = positive, 1 = negative pulse  */
#define CZ_MODE_VSPOL   0x02    /* VSYNC polarity: 0 = positive, 1 = negative pulse  */
#define CZ_MODE_AMODE   0x04    /* address mode: 0 = single, 1 = interleaved access  */
#define CZ_MODE_OLEN    0x08    /* overlay: 0 = blanked, 1 = shown over the frame    */
#define CZ_MODE_OLSEL   0x10    /* overlay SRAM half a CHR (drawing) screen          */
                                /* addresses: 0 = lower, 1 = upper 64K words.        */
                                /* Cleared by reset                                  */

/*
 * ---- HD63484 Status Register (CZ_ACRTC_SR) ----
 *
 * After a hardware reset CED, WFR and WFE are 1 and the rest 0.
 */
#define CZ_SR_WFE   0x01    /* write FIFO empty                                   */
#define CZ_SR_WFR   0x02    /* write FIFO ready: room for another write           */
#define CZ_SR_RFR   0x04    /* read FIFO ready: holds data to read                */
#define CZ_SR_RFF   0x08    /* read FIFO full                                     */
#define CZ_SR_LPD   0x10    /* light pen strobe detect (no light pen on board)    */
#define CZ_SR_CED   0x20    /* command end                                        */
#define CZ_SR_ARD   0x40    /* area detect; cleared by RPR or CCR ABT             */
#define CZ_SR_CER   0x80    /* command error; cleared by CCR ABT                  */

/*
 * ---- Bt453 overlay registers ----
 *
 * Write the register's address to CZ_DAC_ADDR, then its red, green and blue
 * values to CZ_DAC_OVL. Address xxxxxx00 is reserved. (Palette entries work
 * the same way: their address 00-FFH, then R,G,B to CZ_DAC_PAL. The address
 * register then steps to the next entry.)
 */
#define CZ_DAC_OVL_COLOR1   0x01
#define CZ_DAC_OVL_COLOR2   0x02
#define CZ_DAC_OVL_COLOR3   0x03

#endif /* CADZILLA_H */
