/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * cz88gfx.h -- the cz88gfx graphics library for C programs built with
 * z88dk's zcc (tools/z88dk/zccbuild.sh): #include <cz88gfx.h>.
 *
 * cz88gfx is CADzilla's graphics library: the board setup, drawing, text
 * and overlay routines of czgfx in z80asm, as 8080 code that runs on the
 * 8080, 8085 and Z80 alike. These are its C entry points. Each one is a
 * few instructions in a CZC*.Z88 module that takes the arguments off the
 * stack and jumps into the same routine an assembly program calls, so a
 * C program draws exactly what the .Z88 one does, at the same speed. A
 * program pins a release in its cz88gfx.version (1.1 or later has these
 * bindings), and zccbuild.sh puts this header on the include path and
 * links CZ88GFX.LIB. Only the modules a program uses are linked in. See
 * software/z88dk/cz88gfx/README.md, "Using it from C".
 *
 * Conventions, as in the assembly library:
 *   - The origin is the BOTTOM-LEFT pixel: x runs 0..cz_xmax left to
 *     right, y runs 0..cz_ymax bottom to top.
 *   - Colors are palette indexes, 0..255. With the default palette an
 *     index is hue + level: CZ_RED + CZ_BRIGHT, CZ_BLUE + 10.
 *   - Everything but cz_move/cz_rmove draws in the current drawing mode
 *     (cz_setmode: operation, color and area modes; cz_init resets it).
 *   - The ACRTC draws while the program goes on. cz_wait() waits for it.
 *   - The library is assembled for the board at I/O base 70H.
 *
 * Calling conventions (sccz80): one-argument entries are
 * __z88dk_fastcall (the argument in HL); entries with more are
 * __smallc __z88dk_callee (pushed left to right, popped by the entry).
 * Nothing here needs the Z80's IX or IY.
 */
#ifndef CZ88GFX_H
#define CZ88GFX_H

#include <cadzilla.h>       /* the board's ports and the CZ_SR_ status bits */

#define CZ88GFX_VERSION 0x0101  /* this header's release: major, minor */

/* ---- setup ---- */

/* The mode descriptors: cz_init(CZ_M1K). The mode must match the monitor
 * the project's machine is strapped for (machine.toml cad0 `mode`). */
extern unsigned char cz_m640[], cz_m800[], cz_m1k[];
#define CZ_M640 cz_m640     /* 640x480  */
#define CZ_M800 cz_m800     /* 800x600  */
#define CZ_M1K  cz_m1k      /* 1024x768 */

/* The current mode's largest x and y (set by cz_init). Read only. */
extern unsigned int cz_xmax, cz_ymax;

/* Set up the board, palette, drawing parameters and overlay for the mode;
 * clear the screen to color 0. */
extern void cz_init(const void *mode) __z88dk_fastcall;
extern void cz_cls(unsigned char c) __z88dk_fastcall;     /* clear to color c */
extern void cz_pal(unsigned char i, unsigned char r, unsigned char g,
                   unsigned char b) __smallc __z88dk_callee;
extern void cz_paldef(void);                    /* the default palette again */

/* ---- the default palette: index = hue + level (0..31) ---- */

#define CZ_ORANGE   0
#define CZ_BLUE     32
#define CZ_GREEN    64
#define CZ_CYAN     96
#define CZ_RED      128
#define CZ_MAGENTA  160
#define CZ_YELLOW   192
#define CZ_WHITE    224
#define CZ_BRIGHT   31

/* ---- drawing ---- */

extern void cz_color(unsigned char c) __z88dk_fastcall;   /* the drawing color, CL1 */
extern void cz_move(int x, int y) __smallc __z88dk_callee;   /* the CP to x,y */
extern void cz_line(int x, int y) __smallc __z88dk_callee;   /* CP to x,y; x,y not drawn */
extern void cz_rect(int x, int y) __smallc __z88dk_callee;   /* outline, corners CP, x,y */
extern void cz_frect(int x, int y) __smallc __z88dk_callee;  /* filled, corners CP, x,y */
extern void cz_dot(int x, int y) __smallc __z88dk_callee;    /* one pixel */
extern void cz_rmove(int dx, int dy) __smallc __z88dk_callee;  /* relative to the CP */
extern void cz_rline(int dx, int dy) __smallc __z88dk_callee;
extern void cz_rrect(int dx, int dy) __smallc __z88dk_callee;
extern void cz_rfrect(int dx, int dy) __smallc __z88dk_callee;
extern void cz_seg(int x1, int y1, int x2, int y2) __smallc __z88dk_callee;
extern void cz_box(int x1, int y1, int x2, int y2) __smallc __z88dk_callee;
extern void cz_fbox(int x1, int y1, int x2, int y2,
                    unsigned char c) __smallc __z88dk_callee;  /* sets the color */

/* Point tables: int t[] = { n, x0,y0, x1,y1, ... }, n >= 2 points. */
extern void cz_polyline(const int *t) __z88dk_fastcall;   /* open */
extern void cz_polygon(const int *t) __z88dk_fastcall;    /* closed */

/* Wait for drawing to end: the status register. CZ_SR_CER set = a command
 * error (clear it with cz_abort); CZ_SR_ARD = an area mode's report. */
extern unsigned char cz_wait(void);
extern void cz_abort(void);     /* stop, flush the FIFOs, clear CER */

/* ---- curves ---- */

extern void cz_circle(int x, int y, unsigned int r) __smallc __z88dk_callee;
extern void cz_circle_cp(unsigned int r) __z88dk_fastcall;          /* round the CP */
extern void cz_ellipse(int x, int y, unsigned int rx,
                       unsigned int ry) __smallc __z88dk_callee;   /* rx, ry 0..4095 */
extern void cz_ellipse_cp(unsigned int rx, unsigned int ry) __smallc __z88dk_callee;

/* Arc from the CP round the centre xc,yc (radius = the CP's distance) to
 * the ray through xe,ye; CP = xe,ye, not drawn. cz_rarc: relative. */
#define CZ_DIR_CCW  0
#define CZ_DIR_CW   1
extern void cz_arc(int xc, int yc, int xe, int ye,
                   unsigned char dir) __smallc __z88dk_callee;
extern void cz_rarc(int xc, int yc, int xe, int ye,
                    unsigned char dir) __smallc __z88dk_callee;

/* Elliptical arc on semi-axes in the ratio rx:ry (each at most 90; only
 * the ratio matters). The macros square them -- for constants, at compile
 * time; each argument is used twice. The _sq forms take a = rx*rx,
 * b = ry*ry themselves. */
extern void cz_earc_sq(unsigned int a, unsigned int b, int xc, int yc, int xe,
                       int ye, unsigned char dir) __smallc __z88dk_callee;
extern void cz_rearc_sq(unsigned int a, unsigned int b, int xc, int yc, int xe,
                        int ye, unsigned char dir) __smallc __z88dk_callee;
#define cz_earc(rx, ry, xc, yc, xe, ye, dir) \
        cz_earc_sq((rx) * (rx), (ry) * (ry), xc, yc, xe, ye, dir)
#define cz_rearc(rx, ry, xc, yc, xe, ye, dir) \
        cz_rearc_sq((rx) * (rx), (ry) * (ry), xc, yc, xe, ye, dir)

/* ---- PAINT and copy ---- */

/* Fill round x,y out to pixels of color edge / recolor the region of
 * color c round x,y. Both also stop at CL0 and CL1 (the chip's rule). */
extern void cz_paint(int x, int y, unsigned char edge) __smallc __z88dk_callee;
extern void cz_flood(int x, int y, unsigned char c) __smallc __z88dk_callee;
extern void cz_paint_cp(unsigned char edge) __z88dk_fastcall;   /* from the CP */
extern void cz_flood_cp(unsigned char c) __z88dk_fastcall;

/* Copy the rectangle x1,y1..x2,y2 so that x1,y1 lands on xd,yd. */
#define CZ_CP_NORM  0   /* as it is */
#define CZ_CP_MIRY  1   /* flipped top to bottom */
#define CZ_CP_MIRX  2   /* mirrored left to right */
#define CZ_CP_R180  3   /* turned 180 degrees */
#define CZ_CP_TRAN  4   /* transposed */
#define CZ_CP_R270  5   /* turned 90 degrees clockwise */
#define CZ_CP_R90   6   /* turned 90 degrees counter-clockwise */
#define CZ_CP_ATRN  7   /* mirrored in the other diagonal */
extern void cz_copy(int x1, int y1, int x2, int y2, int xd, int yd,
                    unsigned char t) __smallc __z88dk_callee;

/* ---- the drawing mode: area + color mode + operation ---- */

#define CZ_OM_REP   0x00    /* operation: P = C */
#define CZ_OM_OR    0x01    /* P = P OR C */
#define CZ_OM_AND   0x02    /* P = P AND C */
#define CZ_OM_EOR   0x03    /* P = P XOR C (twice restores P) */
#define CZ_OM_EQ    0x04    /* P = C where P = CCMP (cz_ccmp) */
#define CZ_OM_NE    0x05    /* P = C where P <> CCMP */
#define CZ_OM_LT    0x06    /* P = C where P < C */
#define CZ_OM_GT    0x07    /* P = C where P > C */
#define CZ_CM_SEL   0x00    /* color: pattern 1 = CL1, 0 = CL0 */
#define CZ_CM_CL1   0x08    /* 1 = CL1, 0 = left alone */
#define CZ_CM_CL0   0x10    /* 0 = CL0, 1 = left alone */
#define CZ_CM_PRAM  0x18    /* the pattern RAM is a 4x4 color tile */
#define CZ_AM_NONE  0x00    /* area: no checking */
#define CZ_AM_STOP  0x20    /* stop at the first pixel outside; ARD */
#define CZ_AM_CLIP  0x40    /* draw only inside */
#define CZ_AM_CLPD  0x60    /* draw only inside; ARD if any outside */
#define CZ_AM_STPI  0xA0    /* stop at the first pixel inside; ARD */
#define CZ_AM_HOLE  0xC0    /* draw only outside */
#define CZ_AM_HOLD  0xE0    /* draw only outside; ARD if any inside */

extern void cz_setmode(unsigned char m) __z88dk_fastcall;  /* the whole mode */
extern void cz_opm(unsigned char m) __z88dk_fastcall;      /* one field of it */
extern void cz_cmode(unsigned char m) __z88dk_fastcall;
extern void cz_amode(unsigned char m) __z88dk_fastcall;
extern void cz_bcol(unsigned char c) __z88dk_fastcall;     /* CL0 (cz_init: 0) */
extern void cz_ccmp(unsigned char c) __z88dk_fastcall;     /* CCMP */
extern void cz_area(int x1, int y1, int x2, int y2) __smallc __z88dk_callee;
extern void cz_afull(void);                                /* the whole screen */
extern void cz_getcp(int *x, int *y) __smallc __z88dk_callee;  /* clears ARD */
extern int cz_rdot(int x, int y) __smallc __z88dk_callee;  /* color, -1 off screen */

/* ---- the pattern RAM ---- */

/* Pattern tables: unsigned t[] = { n, w0, ... }, word n is row n (row 0
 * drawn first, at the bottom), bit m its column m (bit 0 leftmost). In
 * CZ_CM_PRAM each word is a color in both bytes: CZ_TILE(c). */
#define CZ_TILE(c)  ((unsigned int)(c) * 0x101U)
#define CZ_PTSLNT   8       /* cz_ptn dir: slant the rows 45 degrees */
extern void cz_ldpat(const unsigned int *t,
                     unsigned char pra) __smallc __z88dk_callee;  /* from word pra */
extern void cz_pscan(unsigned char x0, unsigned char y0, unsigned char x1,
                     unsigned char y1, unsigned char zx,
                     unsigned char zy) __smallc __z88dk_callee;   /* window, zoom */
extern void cz_pptr(unsigned char x, unsigned char y) __smallc __z88dk_callee;
extern void cz_pdef(void);      /* all ones, 16x16, no zoom, pointer 0,0 */
extern void cz_lstyle(unsigned int pat,
                      unsigned char zoom) __smallc __z88dk_callee;  /* 0xFFFF,0: solid */
extern void cz_ptn(int x, int y, unsigned int w, unsigned int h,
                   unsigned char dir) __smallc __z88dk_callee;   /* w, h 1..256 */
extern void cz_ptn_cp(unsigned int w, unsigned int h,
                      unsigned char dir) __smallc __z88dk_callee;

/* ---- the 1 bpp overlay ---- */

#define CZ_OVSET    0xFF    /* cz_color(CZ_OVSET): overlay bits on */
#define CZ_OVCLR    0x00    /* off */
extern void cz_ovon(void);      /* show the overlay */
extern void cz_ovoff(void);     /* hide it; what is drawn stays */
extern void cz_ovl(void);       /* draw on the overlay; CP = 0,0 */
extern void cz_frame(void);     /* draw on the frame again; CP = 0,0 */
extern void cz_ovcls(void);     /* clear the overlay */
extern void cz_ovpal(unsigned char r, unsigned char g,
                     unsigned char b) __smallc __z88dk_callee;

/* ---- text ---- */

/* The fonts: naming one links it in. */
extern unsigned char cz_f8[], cz_f11[];
#define CZ_F8   cz_f8       /* 8x8 cell, 5x7 glyphs */
#define CZ_F11  cz_f11      /* 9x11 cell, 7x10 glyphs with descenders */
#define CZ_TXOPAQ   1       /* cz_tattr flag: the cell's 0 bits in CL0 */
extern void cz_font(const void *f) __z88dk_fastcall;
extern void cz_tpos(int x, int y) __smallc __z88dk_callee;  /* the pen: cell bottom-left */
extern void cz_tattr(unsigned char scale, unsigned char dir,
                     unsigned char flags) __smallc __z88dk_callee;  /* 1-16, 0-7 */
extern void cz_text(const char *s) __z88dk_fastcall;    /* up to the NUL, 255 max */
extern void cz_tstr(const char *s, unsigned char n) __smallc __z88dk_callee;
extern void cz_tchr(char c) __z88dk_fastcall;
extern void cz_tnl(void);       /* a new line */

/* ---- raw ACRTC access ---- */

extern void cz_putw(unsigned int w) __z88dk_fastcall;  /* a word to the FIFO */
extern void cz_cmd(unsigned char op) __z88dk_fastcall; /* command op + the mode */
extern void cz_wpr(unsigned char r,
                   unsigned int v) __smallc __z88dk_callee;  /* drawing parameter */
extern void cz_wreg(unsigned char r,
                    unsigned int v) __smallc __z88dk_callee; /* control register */

#endif /* CZ88GFX_H */
