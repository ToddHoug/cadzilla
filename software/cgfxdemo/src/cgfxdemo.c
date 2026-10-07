/*
 * cgfxdemo.c -- CADzilla cz88gfx graphics library demo, in C
 *
 * software/z88demo's Z88DEMO.Z88 ported from z80asm to C, call for call,
 * on cz88gfx's C bindings (#include <cz88gfx.h>; software/cz88gfx/README.md,
 * "Using it from C"). The same ten screens, drawn by the same library
 * code, so each screen's frame, palette and overlay are identical, pixel
 * for pixel, to z88demo's. The port shows what changes between the two:
 *   - the G... macros are cz_ functions: GCOLOR c is cz_color(c), GBOX is
 *     cz_box(...), GMODE is cz_setmode(...), GOVL is cz_ovl()
 *   - "already in HL/DE" (CALL CZMOVE, CALL CZCRCL) is just a call with
 *     the computed arguments: cz_move(x, y), cz_circle_cp(r)
 *   - point and pattern tables are C arrays in the library's layout:
 *     { n, x0,y0, ... } and { n, w0, ... }
 *   - REPT and REPTI unrolled at assembly time are C loops
 *   - constants carry a CZ_ prefix: CZ_RED + CZ_BRIGHT, CZ_OM_EOR
 * Ten screens, each described on the console; press any key for the next
 * one, ESC (or ^C) to quit.
 *
 *   1  Palette & fills   all 256 palette entries as filled boxes, hues
 *                        top to bottom, black to full brightness left to
 *                        right, inside a white frame (cz_frect, cz_box)
 *   2  Lines             a 36-spoke starburst from a data table (cz_move,
 *                        cz_line) and 10 nested rectangles (cz_box)
 *   3  Polys & dots      a 5-point star and a hexagon (cz_polygon), a
 *                        triangle, a sine wave (cz_polyline) and 400
 *                        random dots (cz_dot)
 *   4  Curves            concentric circles, a rainbow of half circle arcs
 *                        drawn both ways round (cz_arc), five ellipses and
 *                        a spiral of elliptical arcs (cz_earc)
 *   5  Operation modes   eight panels of colored bands, each overdrawn by
 *                        two overlapping boxes in one operation mode
 *                        (cz_opm, cz_ccmp)
 *   6  Color modes &     a ring pattern filled in each color mode and a
 *      pattern RAM       4x4 color tile (cz_ldpat, cz_pscan, cz_cmode,
 *                        cz_bcol); dashed lines and shapes (cz_lstyle);
 *                        the pattern RAM as a picture (cz_ptn)
 *   7  Area, PAINT &     clipped circles, lines that stop at an area's
 *      copy              edge (cz_area, cz_getcp); a painted and flooded
 *                        pie chart (cz_paint, cz_flood); a picture copied
 *                        in all eight orientations (cz_copy)
 *   8  Overlay           screen 1 again, and on the overlay over it: a
 *                        grid, a circle, a patterned PAINT, a solid box
 *                        and a crosshair moved in CZ_OM_EOR (cz_ovl ...
 *                        cz_frame, cz_ovon, cz_ovpal)
 *   9  Overlay off       cz_ovoff, then cz_ovcls
 *  10  Text overlay      screen 2, and text on the overlay over it in both
 *                        fonts, scaled, turned and opaque (cz_font,
 *                        cz_tpos, cz_tattr, cz_text, cz_tstr, cz_tnl);
 *                        then a line of text on the frame itself
 *
 * Build on the host (cz88gfx release pinned in cz88gfx.version; see
 * cadzilla-build-zcc), then R CGFXDEMO.COM onto the disk and run it:
 *   tools/z88dk/zccbuild.sh software/cgfxdemo
 */
#include <cpm.h>
#include <cz88gfx.h>

#define CONIN   1       /* BDOS console input (waits, echoes) */
#define CONOUT  2
#define PSTRING 9
#define ESC     0x1B
#define CTLC    0x03

/* CR, LF -- spelled out: print() goes straight to the BDOS */
#define NL      "\015\012"

#define WHITE_B (CZ_WHITE + CZ_BRIGHT)

static int gx, gy;      /* a panel's corner (screens 5-7), the crosshair (8) */

/* ================= console ================= */

/* print -- a '$'-terminated string, BDOS function 9 */
static void print(const char *s)
{
    bdos(PSTRING, (int)s);
}

static void pchr(char c)
{
    bdos(CONOUT, c);
}

/* pdec -- n in decimal, without leading zeros */
static void pdec(unsigned int n)
{
    if (n >= 10)
        pdec(n / 10);
    pchr('0' + n % 10);
}

static void pset(unsigned char f)
{
    print(f ? "set$" : "clear$");
}

/*
 * done -- wait for the screen to finish drawing, report a command error
 * if there was one, then wait for a key. Returns 1 if the key was ESC or
 * ^C (quit).
 *
 * The key is read with BDOS function 1, not 6 (direct I/O): while
 * function 9 prints, the BDOS polls the keyboard for ^S and keeps any
 * other key it finds in its own buffer, which function 1 reads and
 * function 6 bypasses.
 */
static int done(void)
{
    unsigned char k;

    if (cz_wait() & CZ_SR_CER) {
        print("  ACRTC COMMAND ERROR (CER) -- aborted" NL "$");
        cz_abort();
    } else {
        print("  drawn OK" NL "$");
    }
    print("  press a key (ESC quits)...$");
    k = bdos(CONIN, 0);
    print(NL "$");
    return k == ESC || k == CTLC;
}

/* ================= data ================= */

/* Starburst end points: 36 X,Y pairs on a circle of radius 240 */
static const int spokes[] = {
    512, 384, 508, 426, 498, 466, 480, 504,
    456, 538, 426, 568, 392, 592, 354, 610,
    314, 620, 272, 624, 230, 620, 190, 610,
    152, 592, 118, 568, 88, 538, 64, 504,
    46, 466, 36, 426, 32, 384, 36, 342,
    46, 302, 64, 264, 88, 230, 118, 200,
    152, 176, 190, 158, 230, 148, 272, 144,
    314, 148, 354, 158, 392, 176, 426, 200,
    456, 230, 480, 264, 498, 302, 508, 342
};

/* Point tables: the count, then X,Y pairs */
static const int star[] = { 10,
    240, 704, 202, 595, 88, 594, 179, 525, 146, 414,
    240, 480, 334, 414, 301, 525, 392, 594, 278, 595 };
static const int hexagon[] = { 6,
    928, 544, 856, 669, 712, 669, 640, 544, 712, 419, 856, 419 };
static const int tri[] = { 3, 480, 448, 576, 704, 400, 640 };
static const int dtri[] = { 3, 400, 24, 488, 24, 444, 184 };
static const int sine[] = { 33,
    64, 152, 93, 186, 122, 214, 150, 233,
    179, 240, 208, 233, 237, 214, 266, 186,
    294, 152, 323, 118, 352, 90, 381, 71,
    410, 64, 438, 71, 467, 90, 496, 118,
    525, 152, 554, 186, 582, 214, 611, 233,
    640, 240, 669, 233, 698, 214, 726, 186,
    755, 152, 784, 118, 813, 90, 842, 71,
    870, 64, 899, 71, 928, 90, 957, 118,
    986, 152 };

/* Screen 5: each panel's operation mode and color, and its two boxes
 * (offsets from the panel's corner) */
static const unsigned char pnltab[] = {
    CZ_OM_REP, WHITE_B,             /* replace */
    CZ_OM_OR, CZ_BRIGHT,            /* OR 31: each band's hue at full */
    CZ_OM_AND, 0xEF,                /* AND: level bit 4 off, 20 -> 4 */
    CZ_OM_EOR, 0xFF,                /* EOR: twice is back to the band */
    CZ_OM_EQ, WHITE_B,              /* only where P = CCMP: band 2 */
    CZ_OM_NE, WHITE_B,              /* everywhere but band 2 */
    CZ_OM_LT, CZ_RED + CZ_BRIGHT,   /* where P < 159: bands 0-4 */
    CZ_OM_GT, CZ_RED + CZ_BRIGHT    /* where P > 159: bands 5-7 */
};
static const int box1[] = { 40, 30, 150, 230 };
static const int box2[] = { 86, 122, 196, 322 };

/* Screen 6: the pattern box in each panel (offsets from its corner) */
static const int pbox[] = { 16, 24, 219, 303 };

/* Screen 7: the far ends of the area lines */
static const int outpts[] = {
    16, 170, 16, 16, 240, 16, 464, 16,
    464, 170, 464, 340, 240, 340, 16, 340 };

/* Pattern RAM tables: the count, then the words. Word n is row n, bottom
 * row first; bit 0 is the left column. */
static const unsigned int ring[] = { 16,       /* a 16x16 ring */
    0, 0, 0x07E0, 0x1FF8, 0x1E78, 0x381C, 0x381C, 0x300C,
    0x300C, 0x381C, 0x381C, 0x1E78, 0x1FF8, 0x07E0, 0, 0 };
static const unsigned int fglyph[] = { 16,     /* a framed F */
    0xFFFF, 0x8001, 0x8001, 0x800D, 0x800D, 0x800D, 0x800D, 0x800D,
    0x83FD, 0x83FD, 0x800D, 0x800D, 0x8FFD, 0x8FFD, 0x8001, 0xFFFF };
static const unsigned int ones[] = { 16,       /* all ones, as after cz_init */
    0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF,
    0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF };
/* A 4x4 CZ_CM_PRAM color tile, bottom row first: the eight hues at full
 * brightness, in two orders */
static const unsigned int tile1[] = { 16,
    CZ_TILE(159), CZ_TILE(223), CZ_TILE(95), CZ_TILE(127),
    CZ_TILE(63), CZ_TILE(191), CZ_TILE(31), CZ_TILE(255),
    CZ_TILE(223), CZ_TILE(95), CZ_TILE(127), CZ_TILE(159),
    CZ_TILE(191), CZ_TILE(31), CZ_TILE(255), CZ_TILE(63) };

/* ================= helpers ================= */

/* hue -- the color of hue h (0-7) at level lv: h*32 + lv */
#define hue(h, lv)  ((((h) & 7) << 5) | (lv))

/* pnlx -- gx = the left edge of panel column a AND 3: 16 + column*252 */
static void pnlx(unsigned char a)
{
    gx = 16 + (a & 3) * 252;
}

/* rfbox -- filled box, corners gx,gy plus the two dX,dY pairs at b */
static void rfbox(const int *b)
{
    cz_move(gx + b[0], gy + b[1]);
    cz_frect(gx + b[2], gy + b[3]);
}

/* solid -- pattern RAM all ones again, the full 16x16 scan window */
static void solid(void)
{
    cz_ldpat(ones, 0);
    cz_pscan(0, 0, 15, 15, 0, 0);
}

/* rand16 -- 16-bit xorshift (7,9,8), byte for byte as Z88DEMO's RAND */
static unsigned int seed = 0xACE1;

static unsigned int rand16(void)
{
    unsigned char h = seed >> 8, l = seed;

    h ^= (unsigned char)((h << 7) | (l >> 1));     /* x ^= x << 7 */
    l ^= (unsigned char)((l << 7) | (h >> 1));     /* x ^= x >> 9 */
    h ^= l;                                        /* x ^= x << 8 */
    seed = ((unsigned int)h << 8) | l;
    return seed;
}

/* ================= screen 1: palette & fills ================= */

/* 32 columns (levels) x 8 rows (hues), 28x80 pixel cells on a 32x90
 * pitch, hue 0 on top */
static void scr1(void)
{
    unsigned char c = 0;
    int x, y = 38 + 7 * 90;

    cz_cls(0);
    do {
        for (x = 2; ; x += 32) {
            cz_color(c);
            cz_move(x, y);
            cz_frect(x + 27, y + 79);
            if ((++c & 31) == 0)
                break;
        }
        y -= 90;
    } while (c);            /* wraps to 0 after all 256 */
    cz_color(WHITE_B);
    cz_box(0, 0, 1023, 767);
}

/* ================= screen 2: lines ================= */

static void scr2(void)
{
    unsigned char i, n;

    cz_cls(0);
    /* Starburst: 36 spokes from the centre (272,384), radius 240, one
     * color per spoke cycling through the 8 hues */
    for (i = 0; i < 36; i++) {
        cz_color(hue(i, CZ_BRIGHT));
        cz_move(272, 384);
        cz_line(spokes[2 * i], spokes[2 * i + 1]);
    }
    /* Nested rectangles, the corners and color from the counter n */
    for (n = 0; n < 10; n++) {
        cz_color((n % 8) * 32 + CZ_BRIGHT - (n / 8) * 12);
        cz_box(560 + n * 19, 160 + n * 19, 992 - n * 19, 608 - n * 19);
    }
    cz_color(WHITE_B);      /* an X corner to corner of the innermost */
    cz_seg(731, 331, 821, 437);
    cz_seg(731, 437, 821, 331);
}

/* ================= screen 3: polygons, polylines, dots ================= */

static void scr3(void)
{
    unsigned int i, r, a, b;

    cz_cls(0);
    cz_color(CZ_YELLOW + CZ_BRIGHT);    /* 5-point star */
    cz_polygon(star);
    cz_color(CZ_CYAN + CZ_BRIGHT);      /* hexagon */
    cz_polygon(hexagon);
    cz_color(CZ_MAGENTA + CZ_BRIGHT);   /* triangle */
    cz_polygon(tri);
    cz_color(CZ_GREEN + CZ_BRIGHT);     /* sine wave, 33 points */
    cz_polyline(sine);
    cz_color(CZ_WHITE + 16);            /* axis under the wave */
    cz_seg(64, 152, 987, 152);
    /* 400 dots in the band between the shapes and the wave, at random
     * positions, colors cycling through the palette */
    for (i = 0; i < 400; i++) {
        a = rand16() & 511;             /* X = 102 + a + a/2 */
        r = rand16();
        b = r & 63;                     /* Y = 282 + b + b/2 */
        cz_color((r >> 8) | 16);        /* never too dark */
        cz_dot(102 + a + a / 2, 282 + b + b / 2);
    }
}

/* ================= screen 4: curves ================= */

static const unsigned char rainbow[] = {
    CZ_RED, CZ_ORANGE, CZ_YELLOW, CZ_GREEN,
    CZ_CYAN, CZ_BLUE, CZ_MAGENTA, CZ_WHITE };

static void scr4(void)
{
    unsigned char n;

    cz_cls(0);
    /* 13 concentric circles round (240,440), radius 16 to 208, one hue each */
    for (n = 0; n < 13; n++) {
        cz_color(hue(n, CZ_BRIGHT));
        cz_move(240, 440);
        cz_circle_cp(16 + n * 16);
    }
    /* A rainbow: eight half circles round (240,24), radius 180 down to 75.
     * Even ones start on the right and run counter-clockwise, odd ones
     * start on the left and run clockwise -- both over the top. */
    for (n = 0; n < 8; n++) {
        cz_color(rainbow[n] + CZ_BRIGHT);
        if (n % 2) {
            cz_move(60 + n * 15, 24);
            cz_arc(240, 24, 420 - n * 15, 24, CZ_DIR_CW);
        } else {
            cz_move(420 - n * 15, 24);
            cz_arc(240, 24, 60 + n * 15, 24, CZ_DIR_CCW);
        }
    }
    /* Five ellipses round (756,580), from wide and flat to narrow and tall */
    for (n = 0; n < 5; n++) {
        cz_color(((n + 1) % 8) * 32 + CZ_BRIGHT);
        cz_ellipse(756, 580, 240 - n * 40, 20 + n * 40);
    }
    /* A spiral of 12 elliptical half arcs with semi-axes 4:3, round two
     * centres 14 apart, each arc starting where the last ended, 14 wider */
    cz_move(747, 200);
    for (n = 0; n < 12; n++) {
        cz_color(CZ_CYAN + 9 + n * 2);
        if (n % 2)
            cz_earc(4, 3, 747, 200, 747 + 14 + n * 14, 200, CZ_DIR_CCW);
        else
            cz_earc(4, 3, 733, 200, 733 - 14 - n * 14, 200, CZ_DIR_CCW);
    }
}

/* ================= screen 5: operation modes ================= */

/* bands -- eight 236 x 44 bands from gx,gy up, colors hue*32+20 */
static void bands(void)
{
    unsigned char b;
    int y = gy;

    for (b = 0; b < 8; b++) {
        cz_color(hue(b, 20));
        cz_move(gx, y);
        cz_frect(gx + 235, y + 43);
        y += 44;
    }
}

/* Eight 236 x 352 panels, each eight bands, then two overlapping boxes
 * drawn in the panel's operation mode and color. CZ_OM_EQ/NE compare
 * with CCMP = band 2's color. */
static void scr5(void)
{
    unsigned char k;

    cz_cls(0);
    cz_ccmp(CZ_GREEN + 20);
    for (k = 0; k < 8; k++) {
        pnlx(k);
        gy = k < 4 ? 400 : 16;
        bands();
        cz_opm(pnltab[2 * k]);
        cz_color(pnltab[2 * k + 1]);
        rfbox(box1);
        rfbox(box2);
        cz_setmode(0);
    }
}

/* ================= screen 6: color modes and pattern RAM ================= */

/* s6pnl -- panel a's eight bars, hue*32+12, from (gx+2,420) up to 747 */
static void s6pnl(unsigned char a)
{
    unsigned char b;
    int x;

    pnlx(a);
    gy = 420;
    x = gx + 2;
    for (b = 0; b < 8; b++) {
        cz_color(hue(b, 12));
        cz_move(x, 420);
        cz_frect(x + 28, 747);
        x += 29;
    }
}

/* s6box -- panel a's pattern box, the pattern pointer reset so the
 * tiling starts at its corner */
static void s6box(unsigned char a)
{
    pnlx(a);
    cz_pptr(0, 0);
    rfbox(pbox);
}

static void scr6(void)
{
    cz_cls(0);
    /* Four panels of bars, each with a box filled with the ring pattern
     * in one color mode -- CZ_CM_SEL, CL1, CL0 -- and, in the last, a 4x4
     * color tile in CZ_CM_PRAM, each cell zoomed to 8x8 */
    s6pnl(0);
    s6pnl(1);
    s6pnl(2);
    s6pnl(3);
    cz_ldpat(ring, 0);
    cz_color(CZ_YELLOW + CZ_BRIGHT);
    cz_bcol(CZ_BLUE + 10);
    s6box(0);                       /* CZ_CM_SEL is cz_init's color mode */
    cz_cmode(CZ_CM_CL1);
    s6box(1);
    cz_cmode(CZ_CM_CL0);
    s6box(2);
    cz_ldpat(tile1, 0);
    cz_pscan(0, 0, 3, 3, 7, 7);
    cz_cmode(CZ_CM_PRAM);
    s6box(3);

    /* Line styles in CZ_CM_CL1, so the gaps leave the black alone; then
     * one in CZ_CM_SEL, which draws its gaps in CL0 */
    cz_cmode(CZ_CM_CL1);
    cz_color(WHITE_B);
    cz_lstyle(0xFFFF, 0);
    cz_seg(32, 376, 480, 376);
    cz_color(CZ_YELLOW + CZ_BRIGHT);
    cz_lstyle(0xFF00, 0);
    cz_seg(32, 352, 480, 352);
    cz_color(CZ_GREEN + CZ_BRIGHT);
    cz_lstyle(0xF0F0, 0);
    cz_seg(32, 328, 480, 328);
    cz_color(CZ_CYAN + CZ_BRIGHT);
    cz_lstyle(0xCCCC, 0);
    cz_seg(32, 304, 480, 304);
    cz_color(CZ_MAGENTA + CZ_BRIGHT);
    cz_lstyle(0xAAAA, 0);
    cz_seg(32, 280, 480, 280);
    cz_color(CZ_ORANGE + CZ_BRIGHT);
    cz_lstyle(0x11FF, 0);           /* 9 on, 3 off, 1 on, 3 off */
    cz_seg(32, 256, 480, 256);
    cz_color(CZ_RED + CZ_BRIGHT);
    cz_lstyle(0xF0F0, 3);
    cz_seg(32, 232, 480, 232);
    cz_cmode(CZ_CM_SEL);
    cz_bcol(CZ_BLUE + CZ_BRIGHT);
    cz_color(CZ_RED + CZ_BRIGHT);
    cz_lstyle(0xFF00, 1);
    cz_seg(32, 208, 480, 208);

    /* The pattern pointer runs on round a shape's corners: a dashed box,
     * a dashed circle and a dotted triangle */
    cz_cmode(CZ_CM_CL1);
    cz_color(CZ_YELLOW + CZ_BRIGHT);
    cz_lstyle(0xF0F0, 0);
    cz_box(40, 24, 200, 184);
    cz_color(CZ_CYAN + CZ_BRIGHT);
    cz_lstyle(0xFF00, 0);
    cz_circle(300, 104, 80);
    cz_color(CZ_GREEN + CZ_BRIGHT);
    cz_lstyle(0x3333, 0);
    cz_polygon(dtri);

    /* cz_ptn draws the pattern RAM itself, a framed F zoomed x4 to 64x64,
     * white on blue: turned 0, 90, 180 and 270 degrees; slanted, turned
     * 90 and slanted, and turned 45 */
    cz_setmode(0);
    cz_ldpat(fglyph, 0);
    cz_pscan(0, 0, 15, 15, 3, 3);
    cz_color(WHITE_B);
    cz_bcol(CZ_BLUE + 8);
    cz_ptn(544, 300, 64, 64, 0);
    cz_ptn(727, 300, 64, 64, 2);
    cz_ptn(847, 363, 64, 64, 4);
    cz_ptn(904, 363, 64, 64, 6);
    cz_ptn(544, 60, 64, 64, CZ_PTSLNT);
    cz_ptn(760, 60, 64, 64, 2 + CZ_PTSLNT);
    cz_ptn(904, 60, 64, 64, 1);
    cz_setmode(0);
    solid();
}

/* ================= screen 7: area modes, PAINT and copy ================= */

/* s7cir -- 12 circles round (240,560), radius 16 to 192, and two
 * diagonals, in the current color and mode */
static void s7cir(void)
{
    unsigned int r;

    for (r = 16; r != 208; r += 16) {
        cz_move(240, 560);
        cz_circle_cp(r);
    }
    cz_seg(40, 380, 440, 740);
    cz_seg(40, 740, 440, 380);
}

static void scr7(void)
{
    unsigned char ard1, ard2, nstop, nstpi, i;
    int x, y, fstx, fsty;

    cz_cls(0);
    /* Top left: an area (96,440)-(384,680). 12 circles and two diagonals,
     * drawn twice: yellow in CZ_AM_CLPD (inside it only), then blue in
     * CZ_AM_HOLD (outside it only). cz_getcp clears ARD. */
    cz_area(96, 440, 384, 680);
    cz_getcp(&x, &y);
    cz_setmode(CZ_AM_CLPD);
    cz_color(CZ_YELLOW + CZ_BRIGHT);
    s7cir();
    ard1 = cz_wait() & CZ_SR_ARD;
    cz_getcp(&x, &y);
    cz_setmode(CZ_AM_HOLD);
    cz_color(CZ_BLUE + CZ_BRIGHT);
    s7cir();
    ard2 = cz_wait() & CZ_SR_ARD;
    cz_setmode(0);
    cz_color(CZ_WHITE + 16);
    cz_box(95, 439, 385, 681);

    /* Bottom left: an area (112,60)-(368,280). Eight green lines from its
     * centre outwards in CZ_AM_STOP stop as they leave it: a red ring on
     * each one's CP. Eight cyan lines from outside inwards in CZ_AM_STPI
     * stop as they enter it: a smaller yellow ring there. */
    cz_box(111, 59, 369, 281);
    cz_area(112, 60, 368, 280);
    cz_getcp(&x, &y);
    nstop = nstpi = 0;
    for (i = 0; i < 8; i++) {
        gx = outpts[2 * i];
        gy = outpts[2 * i + 1];
        cz_setmode(CZ_AM_STOP);     /* out from the centre */
        cz_color(CZ_GREEN + CZ_BRIGHT);
        cz_move(240, 170);
        cz_line(gx, gy);
        if (cz_wait() & CZ_SR_ARD)
            nstop++;
        cz_getcp(&x, &y);           /* where it stopped */
        if (i == 0) {
            fstx = x;
            fsty = y;
        }
        cz_setmode(0);
        cz_color(CZ_RED + CZ_BRIGHT);
        cz_circle_cp(7);
        cz_setmode(CZ_AM_STPI);     /* in from the far end */
        cz_color(CZ_CYAN + CZ_BRIGHT);
        cz_move(gx, gy);
        cz_line(240, 170);
        if (cz_wait() & CZ_SR_ARD)
            nstpi++;
        cz_getcp(&x, &y);
        cz_setmode(0);
        cz_color(CZ_YELLOW + CZ_BRIGHT);
        cz_circle_cp(3);
    }
    cz_afull();

    /* Top right: a pie chart -- a white circle and five spokes, then each
     * wedge painted out to the white. PAINT also stops at CL0 and CL1, so
     * cz_bcol sets CL0 for each wedge. */
    cz_color(WHITE_B);
    cz_circle(760, 580, 150);
    cz_seg(760, 580, 912, 580);
    cz_seg(760, 580, 708, 723);
    cz_seg(760, 580, 617, 528);
    cz_seg(760, 580, 708, 437);
    cz_seg(760, 580, 876, 482);
    cz_color(CZ_RED + CZ_BRIGHT);
    cz_bcol(CZ_RED + CZ_BRIGHT);
    cz_paint(806, 646, WHITE_B);
    cz_color(CZ_GREEN + CZ_BRIGHT);
    cz_bcol(CZ_GREEN + CZ_BRIGHT);
    cz_paint(687, 614, WHITE_B);
    cz_ldpat(ring, 0);
    cz_color(CZ_YELLOW + CZ_BRIGHT);
    cz_bcol(CZ_ORANGE + 12);
    cz_paint(703, 523, WHITE_B);
    cz_ldpat(tile1, 0);
    cz_pscan(0, 0, 3, 3, 3, 3);
    cz_cmode(CZ_CM_PRAM);
    cz_paint(781, 503, WHITE_B);
    cz_setmode(0);
    solid();
    cz_color(CZ_BLUE + CZ_BRIGHT);
    cz_bcol(CZ_BLUE + CZ_BRIGHT);
    cz_paint(835, 553, WHITE_B);
    cz_ldpat(ring, 0);
    cz_cmode(CZ_CM_CL1);
    cz_color(CZ_YELLOW + CZ_BRIGHT);
    cz_bcol(CZ_RED + 4);
    cz_flood(835, 553, CZ_BLUE + CZ_BRIGHT);
    cz_setmode(0);
    solid();

    /* Bottom right: a 64x64 picture at (544,250), copied in the other
     * seven orientations, then onto a green box in CZ_OM_EOR, and through
     * an area in CZ_AM_CLIP that lets only its middle 32x32 by */
    cz_fbox(544, 250, 607, 313, CZ_BLUE + 6);
    cz_fbox(544, 250, 555, 313, CZ_RED + CZ_BRIGHT);
    cz_fbox(544, 250, 607, 261, CZ_YELLOW + CZ_BRIGHT);
    cz_fbox(588, 294, 603, 309, CZ_GREEN + CZ_BRIGHT);
    cz_color(WHITE_B);
    cz_seg(556, 262, 607, 300);
    cz_copy(544, 250, 607, 313, 719, 250, CZ_CP_MIRX);
    cz_copy(544, 250, 607, 313, 768, 313, CZ_CP_MIRY);
    cz_copy(544, 250, 607, 313, 943, 313, CZ_CP_R180);
    cz_copy(544, 250, 607, 313, 544, 150, CZ_CP_TRAN);
    cz_copy(544, 250, 607, 313, 656, 213, CZ_CP_R270);
    cz_copy(544, 250, 607, 313, 831, 150, CZ_CP_R90);
    cz_copy(544, 250, 607, 313, 943, 213, CZ_CP_ATRN);
    cz_fbox(544, 40, 607, 103, CZ_GREEN + 8);
    cz_opm(CZ_OM_EOR);
    cz_copy(544, 250, 607, 313, 544, 40, CZ_CP_NORM);
    cz_setmode(0);
    cz_area(672, 56, 703, 87);
    cz_amode(CZ_AM_CLIP);
    cz_copy(544, 250, 607, 313, 656, 40, CZ_CP_NORM);
    cz_setmode(0);
    cz_afull();

    /* What the area modes reported */
    print("  AMCLPD: ARD $");
    pset(ard1);
    print(", AMHOLD: ARD $");
    pset(ard2);
    print(NL "  AMSTOP stopped $");
    pdec(nstop);
    print(" of 8 lines, the first at $");
    pdec(fstx);
    pchr(',');
    pdec(fsty);
    print("; AMSTPI stopped $");
    pdec(nstpi);
    print(" of 8" NL "$");
}

/* ================= screen 8: the overlay ================= */

/* xhair -- an 81-pixel crosshair centred on gx,gy, in the current mode
 * (in CZ_OM_EOR its centre, drawn by both lines, toggles back off) */
static void xhair(void)
{
    cz_move(gx - 40, gy);
    cz_line(gx + 41, gy);
    cz_move(gx, gy - 40);
    cz_line(gx, gy + 41);
}

/* Screen 1's palette on the frame, then on the overlay above it, in
 * yellow: a grid every 64 pixels, a circle, a box painted with the ring
 * pattern and a solid one, and a crosshair stepped across in CZ_OM_EOR --
 * each drawn, then drawn again to undraw it, the last one left. At 1 bpp
 * the colors are CZ_OVSET and CZ_OVCLR; PAINT also stops at CL0 and CL1,
 * so CL0 goes to CZ_OVSET too. */
static void scr8(void)
{
    unsigned char c;
    int n;

    scr1();
    cz_ovpal(255, 255, 0);
    cz_ovl();
    cz_color(CZ_OVSET);
    cz_bcol(CZ_OVSET);
    cz_box(96, 96, 288, 256);       /* (painted before the grid crosses it) */
    cz_ldpat(ring, 0);
    cz_cmode(CZ_CM_CL1);
    cz_paint(192, 176, CZ_OVSET);
    cz_setmode(0);
    solid();
    cz_move(736, 96);
    cz_frect(928, 256);
    for (n = 1; n <= 15; n++)
        cz_seg(n * 64, 0, n * 64, 767);
    for (n = 1; n <= 11; n++)
        cz_seg(0, n * 64, 1023, n * 64);
    cz_circle(512, 384, 200);
    cz_setmode(CZ_OM_EOR);
    gx = gy = 200;
    for (c = 20; ; ) {
        xhair();                    /* draw it */
        if (--c == 0)
            break;                  /* (the last one stays) */
        xhair();                    /* undraw it */
        gx += 25;
        gy += 15;
    }
    cz_setmode(0);
    cz_frame();
    cz_ovon();
}

/* ================= screen 9: the overlay off ================= */

/* cz_ovoff hides the overlay: screen 8's picture shows through untouched.
 * cz_ovcls then clears the overlay, hidden or not. */
static void scr9(void)
{
    cz_ovoff();
    cz_ovcls();
}

/* ================= screen 10: a text overlay ================= */

/* chset -- the character set, 20H-7FH (7FH draws as a blank), as three
 * lines of 32 from the pen */
static void chset(void)
{
    static char ascii[96];
    unsigned char i;

    for (i = 0; i < 96; i++)
        ascii[i] = 0x20 + i;
    for (i = 0; i < 96; i += 32) {
        cz_tstr(ascii + i, 32);
        cz_tnl();
    }
}

/* Screen 2's lines on the frame; on the overlay above them, in white: a
 * title, each font at a larger scale, the whole character set of each,
 * text turned 90 and 45 degrees, and an opaque status line written, then
 * rewritten in place. Then, back on the frame, a line of text in red. */
static void scr10(void)
{
    scr2();
    cz_ovcls();
    cz_ovpal(255, 255, 255);
    cz_ovl();
    cz_color(CZ_OVSET);
    cz_bcol(CZ_OVCLR);
    cz_font(CZ_F11);
    cz_tattr(2, 0, 0);
    cz_tpos(24, 730);
    cz_text("CADzilla text overlay");
    cz_tattr(3, 0, 0);
    cz_tpos(300, 650);
    cz_text("CZF11 x3");
    cz_font(CZ_F8);
    cz_tattr(4, 0, 0);
    cz_tpos(24, 650);
    cz_text("CZF8 x4");
    cz_font(CZ_F11);
    cz_tattr(1, 0, 0);
    cz_tpos(24, 110);
    chset();
    cz_font(CZ_F8);
    cz_tpos(340, 110);
    chset();
    cz_tattr(2, 2, 0);
    cz_tpos(1012, 150);
    cz_text("turned 90");
    cz_tattr(1, 1, 0);
    cz_tpos(290, 400);
    cz_text("45 degrees, along a spoke");
    cz_tattr(2, 0, CZ_TXOPAQ);
    cz_tpos(620, 40);
    cz_text("STATUS: WORKING");
    cz_tpos(620, 40);
    cz_text("STATUS: READY  ");
    cz_frame();
    cz_color(CZ_RED + CZ_BRIGHT);
    cz_tattr(2, 0, 0);
    cz_tpos(620, 130);
    cz_text("and text on the frame");
    cz_ovon();
}

/* ================= main ================= */

int main(void)
{
    print("CGFXDEMO -- CADzilla cz88gfx library demo (z88dk C)" NL "$");
    cz_init(CZ_M1K);        /* 1024x768, default palette, screen cleared */

    print("Screen 1: palette & fills -- 256 cz_frect cells, cz_box frame" NL "$");
    scr1();
    if (done()) goto bye;
    print("Screen 2: lines -- cz_line starburst, cz_box nest" NL "$");
    scr2();
    if (done()) goto bye;
    print("Screen 3: cz_polygon star + hexagon + triangle, cz_polyline sine, cz_dot" NL "$");
    scr3();
    if (done()) goto bye;
    print("Screen 4: curves -- cz_circle circles, cz_arc rainbow (CCW and CW)," NL
          "  cz_ellipse ellipses, cz_earc spiral" NL "$");
    scr4();
    if (done()) goto bye;
    print("Screen 5: operation modes (cz_opm) -- top: replace OR AND EOR," NL
          "  bottom: =CCMP <>CCMP <C >C" NL "$");
    scr5();
    if (done()) goto bye;
    print("Screen 6: color modes SEL CL1 CL0 PRAM (cz_ldpat, CZ_TILE)," NL
          "  cz_lstyle line styles, cz_ptn turned and slanted" NL "$");
    scr6();
    if (done()) goto bye;
    print("Screen 7: cz_area clip/hole and stop lines, cz_paint/cz_flood pie," NL
          "  cz_copy in 8 orientations, with EOR and clipped" NL "$");
    scr7();
    if (done()) goto bye;
    print("Screen 8: the overlay (cz_ovl..cz_frame, cz_ovon) -- a grid, circle," NL
          "  patterned and solid boxes and an EOR crosshair, over screen 1" NL "$");
    scr8();
    if (done()) goto bye;
    print("Screen 9: cz_ovoff -- the picture under the overlay is untouched;" NL
          "  then cz_ovcls clears it" NL "$");
    scr9();
    if (done()) goto bye;
    print("Screen 10: a text overlay (cz_font CZ_F8/CZ_F11, cz_text, cz_tnl) over" NL
          "  screen 2 -- scaled, turned, opaque -- and text on the frame" NL "$");
    scr10();
    done();
bye:
    print("CGFXDEMO done." NL "$");
    return 0;
}
