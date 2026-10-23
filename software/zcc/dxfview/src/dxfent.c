/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * dxfent.c -- DXFVIEW's entity walker
 *
 * walk() reads entities from the current pair (a 0 pair) to the ENDSEC,
 * ENDBLK or EOF that ends them, through a transform (render.c's XF):
 *   LINE, 3DLINE, POINT, CIRCLE, ARC, TRACE, SOLID, 3DFACE, TEXT, ATTRIB
 *   POLYLINE ... VERTEX ... SEQEND, with bulges (arcs); 3D meshes and
 *     spline frame points are skipped
 *   INSERT, MINSERT arrays (70/71, 44/45) and DIMENSION: the walker
 *     remembers where it is, seeks to the block, walks it through the
 *     INSERT's transform, and seeks back
 * Anything else is skipped. The layer and color rules are AutoCAD's:
 *   - an entity on a frozen or off layer is not drawn; an INSERT on a
 *     frozen layer hides its whole block
 *   - in a block, an entity on layer 0 is on the INSERT's layer
 *   - color 256 is BYLAYER, color 0 BYBLOCK (the INSERT's color)
 * The color is the palette index: aci.c loads AutoCAD's colors.
 */
#include <string.h>
#include <math.h>
#include <cpm.h>
#include "dxfview.h"

#define DEPTHMAX 8
#define DEG     (6.2831853 / 360.0)

enum {
    T_OTHER, T_END, T_LINE, T_POINT, T_CIRCLE, T_ARC, T_TRACE, T_SOLID,
    T_3DFACE, T_TEXT, T_ATTRIB, T_POLYLINE, T_VERTEX, T_SEQEND, T_INSERT,
    T_DIM
};

static const char *const tnames[] = {
    "ENDSEC", "ENDBLK", "EOF", "LINE", "3DLINE", "POINT", "CIRCLE", "ARC",
    "TRACE", "SOLID", "3DFACE", "TEXT", "ATTRIB", "POLYLINE", "VERTEX",
    "SEQEND", "INSERT", "DIMENSION", 0
};
static const unsigned char ttypes[] = {
    T_END, T_END, T_END, T_LINE, T_LINE, T_POINT, T_CIRCLE, T_ARC,
    T_TRACE, T_SOLID, T_3DFACE, T_TEXT, T_ATTRIB, T_POLYLINE, T_VERTEX,
    T_SEQEND, T_INSERT, T_DIM
};

unsigned char aborted;
unsigned int nents;

/* The fields of the entity just read. A recursive walk() overwrites
 * them, so an INSERT copies what it needs first. */
static unsigned char etype;
static float px[4], py[4], pz[4];       /* groups 10-13, 20-23, 30-33 */
static float f40, f41, f42, f43, f44, f45, f50, f51;
static int i62, i70, i71, i72;
static int elay, eblk;
static char etext[VALMAX];

static unsigned char poll;

static unsigned char classify(void)
{
    unsigned char i;

    for (i = 0; tnames[i]; i++)
        if (dxf_is((char *)tnames[i]))
            return ttypes[i];
    return T_OTHER;
}

/* Read the current entity's fields, up to the next 0 pair. */
static void fields(void)
{
    unsigned char i;

    for (i = 0; i < 4; i++)
        px[i] = py[i] = pz[i] = 0.0;
    f40 = f44 = f45 = f50 = f51 = 0.0;
    f41 = f43 = 1.0;
    f42 = etype == T_INSERT ? 1.0 : 0.0;
    i62 = 256;
    i70 = i71 = i72 = 0;
    elay = 0;
    eblk = -1;
    etext[0] = 0;
    while (dxf_next() && dxf_code != 0) {
        if (etype == T_OTHER || etype == T_SEQEND)
            continue;
        switch (dxf_code) {
        case 1:  strcpy(etext, dxf_val); break;
        case 2:  eblk = find_block(dxf_val); break;
        case 8:  elay = find_layer(dxf_val); break;
        case 10: case 11: case 12: case 13:
            px[dxf_code - 10] = dxf_float(); break;
        case 20: case 21: case 22: case 23:
            py[dxf_code - 20] = dxf_float(); break;
        case 30: case 31: case 32: case 33:
            pz[dxf_code - 30] = dxf_float(); break;
        case 40: f40 = dxf_float(); break;
        case 41: f41 = dxf_float(); break;
        case 42: f42 = dxf_float(); break;
        case 43: f43 = dxf_float(); break;
        case 44: f44 = dxf_float(); break;
        case 45: f45 = dxf_float(); break;
        case 50: f50 = dxf_float(); break;
        case 51: f51 = dxf_float(); break;
        case 62: i62 = dxf_int(); break;
        case 70: i70 = dxf_int(); break;
        case 71: i71 = dxf_int(); break;
        case 72: i72 = dxf_int(); break;
        }
    }
}

/* A polyline segment from (x1,y1) to (x2,y2) with bulge b, the pen at
 * x1,y1: a straight line, or an arc of 4*atan(b) (b > 0 counter-clockwise). */
static void pseg(XF *t, float x1, float y1, float x2, float y2, float z, float b)
{
    float th, ch, d, cx, cy, a0, w;

    if (b == 0.0) {
        r_to(t, x2, y2, z);
        return;
    }
    if (b < 0.0) {                      /* clockwise = CCW the other way */
        w = x1; x1 = x2; x2 = w;
        w = y1; y1 = y2; y2 = w;
        b = -b;
    }
    ch = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    if (ch == 0.0)
        return;
    th = 4.0 * atan(b);
    d = ch / (2.0 * tan(th / 2.0));     /* the center's distance off the chord */
    cx = (x1 + x2) / 2.0 - (y2 - y1) / ch * d;
    cy = (y1 + y2) / 2.0 + (x2 - x1) / ch * d;
    a0 = atan2(y1 - cy, x1 - cx);
    r_arc(t, cx, cy, z, ch / (2.0 * sin(th / 2.0)), a0, a0 + th);
}

static void walk(XF *m, int inlay, unsigned char incol, unsigned char depth);

/* The POLYLINE just read; its VERTEXes follow. */
static void polyline(XF *t, unsigned char hidden)
{
    unsigned char closed = i70 & 1, skip = hidden || (i70 & (16 | 64));
    unsigned char first = 1, is3d = i70 & 8;
    float x0 = 0.0, y0 = 0.0, z0 = 0.0, xp = 0.0, yp = 0.0, zp = 0.0, bp = 0.0;
    float elev = pz[0];                 /* a 2D polyline's Z is its own */

    r_up();
    while (dxf_code == 0 && dxf_is("VERTEX")) {
        etype = T_VERTEX;
        fields();
        if (skip || (i70 & 16))         /* a spline frame point */
            continue;
        if (!is3d)
            pz[0] = elev;
        if (first) {
            x0 = px[0];
            y0 = py[0];
            z0 = pz[0];
            r_to(t, x0, y0, z0);
            first = 0;
        } else {
            pseg(t, xp, yp, px[0], py[0], zp, bp);
            if (bp != 0.0) {
                r_up();
                r_to(t, px[0], py[0], pz[0]);
            }
        }
        xp = px[0];
        yp = py[0];
        zp = pz[0];
        bp = f42;
    }
    if (closed && !first)
        pseg(t, xp, yp, x0, y0, zp, bp);
    r_up();
    if (dxf_code == 0 && dxf_is("SEQEND")) {
        etype = T_SEQEND;
        fields();
    }
}

/* Outline the corners 0..3 in order a, b, c, d; edge bit n of vis clear =
 * the edge after corner n is drawn (3DFACE's group 70). */
static void quad(XF *t, unsigned char a, unsigned char b, unsigned char c,
                 unsigned char d, unsigned char vis)
{
    unsigned char k[5], i;

    k[0] = a; k[1] = b; k[2] = c; k[3] = d; k[4] = a;
    r_up();
    for (i = 0; i < 4; i++) {
        if (vis & (1 << i)) {
            r_up();
            continue;
        }
        if (i == 0 || vis & (1 << (i - 1)))
            r_to(t, px[k[i]], py[k[i]], pz[k[i]]);
        r_to(t, px[k[i + 1]], py[k[i + 1]], pz[k[i + 1]]);
    }
    r_up();
}

/* An INSERT, MINSERT or DIMENSION just read: walk its block once per
 * array cell, then come back to the entity after it. */
static void insert(XF *m, int lay, unsigned char col, unsigned char depth)
{
    XF l, c;
    float ix = px[0], iy = py[0], iz = pz[0], sx = f41, sy = f42, sz = f43;
    float cs = f44, rs = f45, rot = f50, co, sn, vx, vy, bx = 0.0, by = 0.0;
    int ncol = i70 > 1 ? i70 : 1, nrow = i71 > 1 ? i71 : 1, i, j;
    long back = dxf_off, first;

    /* the BLOCK header, for its base point; its entities follow */
    dxf_seek(blocks[eblk].off);
    dxf_next();
    l.m[11] = 0.0;
    while (dxf_next() && dxf_code != 0) {
        if (dxf_code == 10)
            bx = dxf_float();
        else if (dxf_code == 20)
            by = dxf_float();
        else if (dxf_code == 30)
            l.m[11] = dxf_float();
    }
    first = dxf_off;

    if (etype == T_DIM) {               /* the block is in WCS already */
        ix = iy = iz = 0.0;
        sx = sy = sz = 1.0;
        rot = 0.0;
    }
    co = cos(rot * DEG);
    sn = sin(rot * DEG);
    l.m[0] = co * sx; l.m[1] = -sn * sy; l.m[2] = 0.0;
    l.m[4] = sn * sx; l.m[5] = co * sy;  l.m[6] = 0.0;
    l.m[8] = 0.0;     l.m[9] = 0.0;      l.m[10] = sz;
    l.m[11] = iz - sz * l.m[11];       /* (l.m[11]: the base point's z) */
    for (j = 0; j < nrow && !aborted; j++)
        for (i = 0; i < ncol && !aborted; i++) {
            vx = i * cs - sx * bx;
            vy = j * rs - sy * by;
            l.m[3] = ix + co * vx - sn * vy;
            l.m[7] = iy + sn * vx + co * vy;
            xf_mul(&c, m, &l);
            dxf_seek(first);
            dxf_next();
            walk(&c, lay, col, depth + 1);
        }
    dxf_seek(back);
    dxf_next();
}

static void walk(XF *m, int inlay, unsigned char incol, unsigned char depth)
{
    int lay, lc, col;
    unsigned char hidden, frozen;
    float a0, a1, x, y, w;

    for (;;) {
        if (dxf_code != 0) {
            if (!dxf_next())
                return;
            continue;
        }
        etype = classify();
        if (etype == T_END)
            return;
        if (!(++poll & 7)) {
            if (bdos(CPM_ICON, 0)) {
                aborted = 1;
                return;
            }
            if (!poll)                  /* a dot every 256: still going */
                bdos(CPM_WCON, '.');
        }
        fields();

        lay = elay ? elay : inlay;      /* layer 0 in a block: the INSERT's */
        if (lay < 0) {                  /* not in the LAYER table */
            lc = 7;
            frozen = 0;
        } else {
            lc = layers[lay].color;
            frozen = layers[lay].flags & LF_FROZEN;
        }
        hidden = frozen || lc < 0;
        col = i62;
        if (col == 256)
            col = lc < 0 ? -lc : lc;
        else if (col == 0)
            col = incol;
        else if (col < 0)
            col = -col;
        if (col < 1 || col > 255)
            col = 7;

        if (etype == T_POLYLINE) {
            r_color(col);
            polyline(m, hidden);
            nents++;
            continue;
        }
        if (etype == T_INSERT || etype == T_DIM) {
            if (eblk >= 0 && !frozen && depth < DEPTHMAX) {
                insert(m, lay, col, depth);
                if (aborted)
                    return;
                nents++;
            }
            continue;
        }
        if (hidden)
            continue;
        r_color(col);
        switch (etype) {
        case T_LINE:
            r_up();
            r_to(m, px[0], py[0], pz[0]);
            r_to(m, px[1], py[1], pz[1]);
            r_up();
            break;
        case T_POINT:
            r_point(m, px[0], py[0], pz[0]);
            break;
        case T_CIRCLE:
            r_arc(m, px[0], py[0], pz[0], f40, 0.0, 6.2831853);
            break;
        case T_ARC:
            a0 = f50 * DEG;
            a1 = f51 * DEG;
            if (a1 <= a0)
                a1 += 6.2831853;
            r_arc(m, px[0], py[0], pz[0], f40, a0, a1);
            break;
        case T_3DFACE:
            quad(m, 0, 1, 2, 3, i70);
            break;
        case T_TRACE:
        case T_SOLID:
            quad(m, 0, 1, 3, 2, 0);
            break;
        case T_ATTRIB:
            if (i70 & 1)                /* invisible */
                break;
            /* fall through */
        case T_TEXT:
            x = px[0];
            y = py[0];
            if (i72 && i72 != 3 && i72 != 5) {
                /* centered, right or middle: from the alignment point */
                w = f40 * TEXTW * strlen(etext);
                if (i72 != 2)
                    w /= 2.0;
                a0 = f50 * DEG;
                x = px[1] - cos(a0) * w;
                y = py[1] - sin(a0) * w;
                if (i72 == 4) {
                    x += sin(a0) * f40 / 2.0;
                    y -= cos(a0) * f40 / 2.0;
                }
            }
            r_text(m, x, y, pz[0], f40, f50 * DEG, etext);
            break;
        default:
            continue;
        }
        nents++;
    }
}

void walk_all(void)
{
    XF *root;

    aborted = 0;
    nents = 0;
    poll = 0;
    root = r_begin();
    if (!measuring)
        dl_reset();
    dxf_seek(ents_off);
    dxf_next();
    walk(root, 0, 7, 0);
    r_up();
    if (!measuring)
        dl_finish();
}
