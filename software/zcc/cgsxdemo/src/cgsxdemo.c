/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * cgsxdemo.c -- a GSX-80 client in C, for the CADzilla GSX driver
 * (software/rmac/ddcz): text, polylines, markers, a bar, a circle, pie slices,
 * a filled polygon and a palette change, all through z88dk's GSX bindings
 * in <cpm.h> (gios_*), in normalized device coordinates (0-32767, origin
 * bottom left), so the same program draws on any GSX device.
 *
 * Compiled on the host by z88dk's zcc (cadzilla-build-zcc skill):
 *   tools/z88dk/zccbuild.sh software/zcc/cgsxdemo   -> build/CGSXDEMO.COM
 * then, on a CP/M disk carrying GSX-80 (GSX.SYS, GENGRAF.COM), the driver
 * and its ASSIGN.SYS -- software/rmac/ddcz's work/ disk, say:
 *   A0>R CGSXDEMO.COM                           (hb0 HOSTDIR = build/)
 *   A0>GENGRAF CGSXDEMO                         (attach the GSX loader)
 *   A0>CGSXDEMO
 * It draws, waits for a key, and closes the workstation.
 *
 * Only gios() (and gios_text()) are called: on an 8080, z88dk's
 * gios_1pm/gios_1px/gios_2px (and the gios_draw, gios_t_size... macros
 * built on them) return to the wrong address. They keep their return
 * address in AF with POP PSW / PUSH PSW, and the 8080's flags byte can't
 * hold every value (bit 1 is always 1, bits 3 and 5 always 0), so 069FH
 * comes back as 0697H. They work on a Z80. The helpers below fill the GSX
 * arrays themselves instead.
 */
#include <stdio.h>
#include <cpm.h>

/* An attribute: one intin value, no points */
static void attr(int fn, int value)
{
    gios_intin[0] = value;
    gios_ctl.n_ptsin = 0;
    gios_ctl.n_intin = 1;
    gios(fn);
}

/* A function taking one point (x, y), no intin */
static void onept(int fn, int x, int y)
{
    gios_ptsin[0] = x;
    gios_ptsin[1] = y;
    gios_ctl.n_ptsin = 1;
    gios_ctl.n_intin = 0;
    gios(fn);
}

/* A function taking two points */
static void twopts(int fn, int x0, int y0, int x1, int y1)
{
    gios_ptsin[0] = x0;
    gios_ptsin[1] = y0;
    gios_ptsin[2] = x1;
    gios_ptsin[3] = y1;
    gios_ctl.n_ptsin = 2;
    gios_ctl.n_intin = 0;
    gios(fn);
}

/* Text s with its baseline starting at x, y */
static void text(int x, int y, char *s)
{
    gios_text(s);                       /* intin, n_intin (and n_ptsin = 1) */
    gios_ptsin[0] = x;
    gios_ptsin[1] = y;
    gios(GSX_TEXT);
}

/* Character height h (NDC) */
static void theight(int h)
{
    onept(GSX_T_SIZE, 0, h);
}

/* A line from x0, y0 to x1, y1 */
static void line(int x0, int y0, int x1, int y1)
{
    twopts(GSX_POLYLINE, x0, y0, x1, y1);
}

/* A filled bar, corners x0, y0 and x1, y1 */
static void bar(int x0, int y0, int x1, int y1)
{
    gios_ctl.special = DRAW_BAR;
    twopts(GSX_DRAW, x0, y0, x1, y1);
}

/* A circle round x, y, radius r */
static void circle(int x, int y, int r)
{
    gios_ptsin[0] = x;      gios_ptsin[1] = y;
    gios_ptsin[2] = x + r;  gios_ptsin[3] = y;
    gios_ptsin[4] = r;      gios_ptsin[5] = 0;
    gios_ctl.n_ptsin = 3;
    gios_ctl.n_intin = 0;
    gios_ctl.special = DRAW_CIRCLE;
    gios(GSX_DRAW);
}

/* A pie slice round x, y, radius r, from angle a0 to a1 (tenths of a
 * degree, counter-clockwise from east). The driver works the arc out from
 * the angles; the start and end points are filled in for drivers that use
 * them instead. */
static void pie(int x, int y, int r, int a0, int a1)
{
    gios_ptsin[0] = x;  gios_ptsin[1] = y;
    gios_ptsin[2] = x;  gios_ptsin[3] = y;
    gios_ptsin[4] = x;  gios_ptsin[5] = y;
    gios_ptsin[6] = r;  gios_ptsin[7] = 0;
    gios_intin[0] = a0; gios_intin[1] = a1;
    gios_ctl.n_ptsin = 4;
    gios_ctl.n_intin = 2;
    gios_ctl.special = DRAW_PIESLICE;
    gios(GSX_DRAW);
}

/* A five-pointed star, filled (even-odd: its middle stays open) */
static int star[] = {
    19000, 11000,  21500, 3000,  23500, 11000,  18500, 6000,  24500, 6000
};

static void fillstar(void)
{
    int i;
    for (i = 0; i < 10; i++)
        gios_ptsin[i] = star[i];
    gios_ctl.n_ptsin = 5;
    gios_ctl.n_intin = 0;
    gios(GSX_POLYGON);
}

/* Color index i to R, G, B (tenths of a percent) */
static void setcolor(int i, int r, int g, int b)
{
    gios_intin[0] = i;
    gios_intin[1] = r;
    gios_intin[2] = g;
    gios_intin[3] = b;
    gios_ctl.n_ptsin = 0;
    gios_ctl.n_intin = 4;
    gios(GSX_PALETTE);
}

int main(void)
{
    int i;

    gios_open(1);                       /* workstation 1 (ASSIGN.SYS) */

    /* the title */
    attr(GSX_T_COLOR, GSX_YELLOW);
    theight(1400);
    text(2000, 29500, "CADzilla GSX from C");
    theight(500);
    attr(GSX_T_COLOR, GSX_WHITE);
    text(2000, 27500, "z88dk gios_* -> GSX-80 -> DDCZ");

    /* a fan of lines in the 7 colors, then in the 5 linetypes */
    for (i = 1; i <= 7; i++) {
        attr(GSX_L_COLOR, i);
        line(2000, 14000, 2000 + i * 1300, 24000);
    }
    attr(GSX_L_COLOR, GSX_WHITE);
    for (i = 1; i <= 5; i++) {
        attr(GSX_L_STYLE, i);
        line(14000, 24000 - i * 1500, 24000, 24000 - i * 1500);
    }
    attr(GSX_L_STYLE, 1);

    /* a row of markers, types 1-5 */
    attr(GSX_M_COLOR, GSX_CYAN);
    onept(GSX_M_HEIGHT, 0, 900);
    for (i = 1; i <= 5; i++) {
        attr(GSX_M_TYPE, i);
        onept(GSX_MARKERS, 25500 + (i - 1) * 1400, 22000);
    }

    /* a hatched bar, and a solid one in a color set from RGB */
    attr(GSX_F_STYLE, F_HATCH);
    attr(GSX_F_INDEX, 3);
    attr(GSX_F_COLOR, GSX_GREEN);
    bar(2000, 3000, 7000, 11000);
    setcolor(8, 1000, 500, 0);          /* color 8: orange */
    attr(GSX_F_STYLE, F_FULL);
    attr(GSX_F_COLOR, 8);
    bar(8000, 3000, 13000, 11000);

    /* a solid circle, and four pie slices */
    attr(GSX_F_COLOR, GSX_BLUE);
    circle(29000, 7500, 2800);
    for (i = 0; i < 4; i++) {
        attr(GSX_F_STYLE, i == 0 ? F_FULL : F_PATTERN);
        attr(GSX_F_INDEX, i + 2);
        attr(GSX_F_COLOR, i + 1);
        pie(29000, 16500, 3200, i * 900, i * 900 + 900);
    }

    /* a filled star, halftone */
    attr(GSX_F_STYLE, F_PATTERN);
    attr(GSX_F_INDEX, 4);
    attr(GSX_F_COLOR, GSX_MAGENTA);
    fillstar();

    gios_ctl.n_ptsin = 0;
    gios_ctl.n_intin = 0;
    gios(GSX_OUTPUT);

    printf("Press RETURN to finish\n");
    getchar();
    gios_ctl.n_ptsin = 0;
    gios_ctl.n_intin = 0;
    gios(GSX_CLOSE);
    return 0;
}
