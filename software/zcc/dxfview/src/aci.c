/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * aci.c -- AutoCAD's 256 standard colors (the ACI), into the palette
 *
 * DXFVIEW loads them into the Bt453, so a DXF color number is the palette
 * index: 1 red, 2 yellow, 3 green, 4 cyan, 5 blue, 6 magenta, 7 white,
 * 8 and 9 grays, 250-255 six grays, and 0 the black background. 10-249 are
 * 24 hues 15 degrees apart, ten each: five shades (full, 65%, 50%, 30%,
 * 15%), each full and then pastel (halfway to white). Those are computed,
 * not stored: the table would be 768 bytes of a tight TPA.
 */
#include <cz88gfx.h>
#include "dxfview.h"

static const unsigned char fixed[] = {      /* 0-9, then 250-255 */
    0, 0, 0,  255, 0, 0,  255, 255, 0,  0, 255, 0,  0, 255, 255,
    0, 0, 255,  255, 0, 255,  255, 255, 255,  128, 128, 128,  192, 192, 192,
    51, 51, 51,  91, 91, 91,  132, 132, 132,  173, 173, 173,
    214, 214, 214,  255, 255, 255
};
static const unsigned char ramp[] = { 0, 63, 127, 191, 255 };
static const unsigned char shade[] = { 255, 165, 127, 76, 38 };

static unsigned char lvl(unsigned char c, unsigned char v, unsigned char pastel)
{
    if (pastel)
        c = (c >> 1) + 127 + (c & 1);   /* (255 + c) / 2, in 8 bits: sccz80
                                           loses bit 8 of the 16-bit sum */
    return (unsigned int)c * v / 255;
}

void aci_load(void)
{
    const unsigned char *p = fixed;
    unsigned char i, h, f, u, d, r, g, b, v;

    for (i = 0; i < 10; i++, p += 3)
        cz_pal(i, p[0], p[1], p[2]);
    for (i = 250; i; i++, p += 3)
        cz_pal(i, p[0], p[1], p[2]);
    for (i = 10; i < 250; i++) {
        h = (i - 10) / 10;              /* the hue, 0-23: six sectors of 4 */
        f = h & 3;
        u = ramp[f];                    /* rising, and falling, in it */
        d = ramp[4 - f];
        switch (h >> 2) {
        case 0:  r = 255; g = u;   b = 0;   break;
        case 1:  r = d;   g = 255; b = 0;   break;
        case 2:  r = 0;   g = 255; b = u;   break;
        case 3:  r = 0;   g = d;   b = 255; break;
        case 4:  r = u;   g = 0;   b = 255; break;
        default: r = 255; g = 0;   b = d;   break;
        }
        v = shade[((i - 10) % 10) >> 1];
        f = (i - 10) & 1;               /* odd: pastel */
        cz_pal(i, lvl(r, v, f), lvl(g, v, f), lvl(b, v, f));
    }
}
