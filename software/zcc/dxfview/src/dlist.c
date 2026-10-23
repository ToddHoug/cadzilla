/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * dlist.c -- DXFVIEW's display list
 *
 * As in AutoCAD's display-list drivers, the drawing is turned into 2D
 * vectors once (a regen: dxfent.c and render.c, in floating point), and
 * every redraw, zoom and pan works from those vectors in integers.
 *
 * The coordinates are a virtual screen: 16-bit integers, -VMAX..VMAX, in
 * units of 1/2^k pixel at the zoom level the list was made at (k is 2,
 * 3 or 4), centered on that view's center. A redraw at a zoom 2^z
 * times that one shifts them right by s = k - z: zooming and panning cost
 * a shift and an add per coordinate, and nothing else. Zooming in further
 * than k steps, or panning out of the area a zoomed-in list covers, needs
 * a regen (dxfview.c).
 *
 * The list lives in the CADzilla's own frame memory, past the 1024x768
 * picture: from word address 60000H, in 256-word chunks. The 1.25 MB there
 * is never displayed and nothing else uses it. A regen writes it with the
 * ACRTC's DWT, 64 words at a time from RAM. A redraw reads each chunk back
 * with DRD (DLRUN.Z88's dl_load) and runs it through dl_run, the 8080 loop
 * that turns vertices into ACRTC line commands. It comes back here only
 * for the rarer records and the rare line that needs clipping in software.
 *
 * The list, in 16-bit words:
 *   X Y                    a vertex: X = 2x + pen (1 = draw from the last
 *                          vertex, 0 = move), Y = y
 *   8000H op+arg*256 ...   a record; 8000H is never a vertex's X:
 *     DL_COLOR             color arg
 *     DL_DOT    x y        one pixel
 *     DL_CIRCLE x y r
 *     DL_ARC    x y x1 y1 x2 y2    from x1,y1 round x,y to the ray through
 *                          x2,y2, arg = CZ_DIR_CCW or CZ_DIR_CW
 *     DL_TEXT   x y h gx gy n chars   text h high at x,y, direction arg
 *                          (0-7); too small to read, a line to gx,gy
 *     DL_NEXT              the rest of this chunk is unused
 *     DL_END               the end of the list
 * No record is split between chunks. Each chunk starts with a header, its
 * bounding box (xmin ymin xmax ymax), so a redraw zoomed in skips a chunk
 * that is all off the screen having read just those four words. For that,
 * a chunk never depends on the one before: it starts with the color, and
 * a line that goes on from the last chunk starts with a move to its start.
 */
#include <stdlib.h>
#include <string.h>
#include <cpm.h>
#include <cz88gfx.h>
#include "dxfview.h"

#define DL_COLOR    1
#define DL_DOT      2
#define DL_CIRCLE   3
#define DL_ARC      4
#define DL_TEXT     5
#define DL_NEXT     6
#define DL_END      7

#define ESCW        0x8000
#define TEXTMAX     120         /* characters kept in a DL_TEXT */
#define GUARD       1024        /* as DLRUN.Z88's guard band */

#define WBUF    64              /* words: the regen's write buffer */
#define HDR     4               /* words: a chunk's header */

/* A chunk read back goes in the DXF reader's buffer, idle in a redraw. */
#define dl_buf  ((unsigned int *)rd_buf)

unsigned int *dl_ptr, *dl_end;  /* dl_run(): the next word, the chunk's end */
int dl_cx2, dl_cy;              /* dl_run(): the view center, X doubled */
int dl_cx;                      /* dl_tx(): the same, not doubled */
unsigned char dl_sx, dl_sy;     /*   the shifts, X's one more for the pen */
int dl_px, dl_py;               /*   the last vertex on screen, */
unsigned char dl_pc, dl_cpok;   /*   its outcode, and CP there */
int dl_x0, dl_y0;               /*   a line for C to clip: x0,y0 to px,py */
unsigned int dl_lofs, dl_lcnt;  /* dl_load(): from which word, how many */

unsigned int dl_nchunks;        /* chunks in the list */
unsigned char dl_clipped;       /* the regen left something out */

static unsigned int wbuf[WBUF]; /* writing: words not yet in the chunk, */
static unsigned int nw;         /*   how many, */
static unsigned int nc;         /*   and how many the chunk holds already */
static int dl_col;              /*   the color last written, */
static int bx0, by0, bx1, by1;  /*   the chunk's bounding box so far, */
static int lvx, lvy;            /*   the last vertex, */
static unsigned char fresh;     /*   and a new chunk since it */
static unsigned char sh;        /* the redraw's shift */

extern void dl_load(unsigned int chunk) __z88dk_fastcall;
extern void dl_prep(void);
extern int dl_run(void);
extern int dl_tx(int x) __z88dk_fastcall;   /* a record's x, y on screen */
extern int dl_ty(int y) __z88dk_fastcall;

/* ---- writing (a regen) ---- */

/* Write n words at w to word ofs of chunk dl_nchunks: DWT under program
 * control, at RWP = base screen, word 60000H + chunk * 256 + ofs. */
static void dwt(unsigned int ofs, unsigned int *w, unsigned int n)
{
    cz_wpr(0x0C, 0x4000 | (0x60 + (dl_nchunks >> 4)));
    cz_wpr(0x0D, (((dl_nchunks & 0x0F) << 8) | ofs) << 4);
    cz_putw(0x2800);                /* DWT AX, AY */
    cz_putw(n - 1);
    cz_putw(0);
    while (n--)
        cz_putw(*w++);
}

static void flush(void)
{
    if (nw) {
        dwt(nc, wbuf, nw);
        nc += nw;
        nw = 0;
    }
}

static void put(unsigned int w)
{
    if (nw == WBUF)
        flush();
    wbuf[nw++] = w;
}

static void box(int x0, int y0, int x1, int y1)
{
    if (x0 < bx0)
        bx0 = x0;
    if (y0 < by0)
        by0 = y0;
    if (x1 > bx1)
        bx1 = x1;
    if (y1 > by1)
        by1 = y1;
}

static void newchunk(void)
{
    nc = HDR;
    bx0 = by0 = 32767;
    bx1 = by1 = -32767;
    fresh = 1;
}

/* The chunk is done: its header, then on to the next, in the same color. */
static void nextchunk(void)
{
    unsigned int h[HDR];

    flush();
    h[0] = bx0;
    h[1] = by0;
    h[2] = bx1;
    h[3] = by1;
    dwt(0, h, HDR);
    dl_nchunks++;
    newchunk();
    if (dl_col >= 0) {
        put(ESCW);
        put(DL_COLOR | (dl_col << 8));
    }
}

/* Room for n more words, and an end record after them, in the chunk? */
static void room(unsigned int n)
{
    if (nc + nw + n + 2 > DL_CHUNK) {
        put(ESCW);
        put(DL_NEXT);
        nextchunk();
    }
}

static void rec(unsigned char op, unsigned char arg, unsigned int n)
{
    room(n + 2);
    put(ESCW);
    put(op | (arg << 8));
}

void dl_reset(void)
{
    nw = 0;
    dl_nchunks = 0;
    dl_clipped = 0;
    dl_col = -1;
    newchunk();
}

void dl_finish(void)
{
    put(ESCW);
    put(DL_END);
    nextchunk();
}

void dl_color(unsigned char c)
{
    if (c != dl_col) {
        rec(DL_COLOR, c, 0);
        dl_col = c;
    }
}

static void vert(int x, int y, unsigned char pen)
{
    put((x << 1) | pen);
    put(y);
    box(x, y, x, y);
    lvx = x;
    lvy = y;
}

void dl_move(int x, int y)
{
    room(2);
    vert(x, y, 0);
    fresh = 0;
}

void dl_draw(int x, int y)
{
    room(4);
    if (fresh)                      /* a new chunk: from the last vertex */
        vert(lvx, lvy, 0);
    vert(x, y, 1);
    fresh = 0;
}

void dl_dot(int x, int y)
{
    rec(DL_DOT, 0, 2);
    put(x);
    put(y);
    box(x, y, x, y);
}

void dl_circle(int x, int y, unsigned int r)
{
    rec(DL_CIRCLE, 0, 3);
    put(x);
    put(y);
    put(r);
    box(x - r, y - r, x + r, y + r);
}

void dl_arc(int x, int y, int x1, int y1, int x2, int y2, unsigned char dir)
{
    int r = abs(x1 - x) + abs(y1 - y);   /* at least the radius */

    rec(DL_ARC, dir, 6);
    put(x);
    put(y);
    put(x1);
    put(y1);
    put(x2);
    put(y2);
    box(x - r, y - r, x + r, y + r);
}

void dl_text(int x, int y, unsigned int h, unsigned char dir, int gx, int gy,
             char *s)
{
    unsigned char n = strlen(s) > TEXTMAX ? TEXTMAX : strlen(s);
    unsigned char i;

    rec(DL_TEXT, dir, 6 + (n + 1) / 2);
    put(x);
    put(y);
    put(h);
    put(gx);
    put(gy);
    put(n);
    for (i = 0; i < n; i += 2)      /* low byte first, as in memory */
        put((unsigned char)s[i] | (i + 1 < n ? s[i + 1] << 8 : 0));
    box((x < gx ? x : gx) - h, (y < gy ? y : gy) - h,
        (x > gx ? x : gx) + h, (y > gy ? y : gy) + h);
}

/* ---- redrawing ---- */

static unsigned char outc(long x, long y)
{
    unsigned char c = 0;

    if (x < 0)
        c = 1;
    else if (x > SCRW - 1)
        c = 2;
    if (y < 0)
        c |= 4;
    else if (y > SCRH - 1)
        c |= 8;
    return c;
}

/* A screen line too far outside for the ACRTC to clip quickly: clip it
 * here (Cohen-Sutherland, in longs: it is rare) and draw what is left. */
static void clipline(long x1, long y1, long x2, long y2)
{
    unsigned char c1 = outc(x1, y1), c2 = outc(x2, y2), c;
    long x, y;

    while (c1 | c2) {
        if (c1 & c2)
            return;
        c = c1 ? c1 : c2;
        if (c & 1) {
            y = y1 + (y2 - y1) * (0 - x1) / (x2 - x1);
            x = 0;
        } else if (c & 2) {
            y = y1 + (y2 - y1) * (SCRW - 1 - x1) / (x2 - x1);
            x = SCRW - 1;
        } else if (c & 4) {
            x = x1 + (x2 - x1) * (0 - y1) / (y2 - y1);
            y = 0;
        } else {
            x = x1 + (x2 - x1) * (SCRH - 1 - y1) / (y2 - y1);
            y = SCRH - 1;
        }
        if (c == c1) {
            x1 = x;
            y1 = y;
            c1 = outc(x, y);
        } else {
            x2 = x;
            y2 = y;
            c2 = outc(x, y);
        }
    }
    cz_move((int)x1, (int)y1);
    cz_line((int)x2, (int)y2);
}

/* Is the screen point well inside the ACRTC's reach (the guard band)? */
static int inreach(int x, int y)
{
    return x > -GUARD && x < SCRW + GUARD && y > -GUARD && y < SCRH + GUARD;
}

/* The record at dl_ptr; 0 at the end of the chunk or the list. */
static unsigned char record(void)
{
    unsigned int *p = dl_ptr;
    unsigned char op = p[1], arg = p[1] >> 8, sc;
    int x, y, x1, y1, x2, y2;
    long r;
    unsigned int h;

    if (op == DL_COLOR) {
        cz_color(arg);
        dl_ptr = p + 2;
        return 1;
    }
    dl_cpok = 0;                    /* everything else moves the CP */
    switch (op) {
    case DL_DOT:
        x = dl_tx(p[2]);
        y = dl_ty(p[3]);
        if (!outc(x, y))
            cz_dot(x, y);
        dl_ptr = p + 4;
        return 1;
    case DL_CIRCLE:
        /* r is at most VMAX, so within CRCL's 13 bits at any shift: the
         * ACRTC draws it all, its area clip cutting what is off screen */
        x = dl_tx(p[2]);
        y = dl_ty(p[3]);
        r = p[4] >> sh;
        dl_ptr = p + 5;
        if (x + r < 0 || x - r > SCRW - 1 || y + r < 0 || y - r > SCRH - 1)
            return 1;
        if (!r)
            cz_dot(x, y);
        else
            cz_circle(x, y, (unsigned int)r);
        return 1;
    case DL_ARC:
        x = dl_tx(p[2]);
        y = dl_ty(p[3]);
        x1 = dl_tx(p[4]);
        y1 = dl_ty(p[5]);
        x2 = dl_tx(p[6]);
        y2 = dl_ty(p[7]);
        dl_ptr = p + 8;
        r = (long)abs(x1 - x) + abs(y1 - y);   /* at least the radius */
        if (x + r < 0 || x - r > SCRW - 1 || y + r < 0 || y - r > SCRH - 1)
            return 1;
        if (x1 == x2 && y1 == y2)
            return 1;               /* less than a pixel */
        cz_move(x1, y1);            /* (as DL_CIRCLE: the ACRTC draws it) */
        cz_arc(x, y, x2, y2, arg);
        return 1;
    case DL_TEXT:
        x = dl_tx(p[2]);
        y = dl_ty(p[3]);
        h = p[4] >> sh;
        x1 = dl_tx(p[5]);
        y1 = dl_ty(p[6]);
        dl_ptr = p + 8 + (p[7] + 1) / 2;
        if (h < 2)
            return 1;
        if (h < 6) {                /* too small to read: its baseline */
            if (inreach(x, y) && inreach(x1, y1)) {
                cz_move(x, y);
                cz_line(x1, y1);
            }
            return 1;
        }
        if (!inreach(x, y))
            return 1;
        /* height / 7, the font's capital: 37/256 is near enough */
        sc = h > 112 ? 16 : (unsigned char)((h * 37 + 128) >> 8);
        if (!sc)
            sc = 1;
        cz_tattr(sc, arg, 0);
        cz_tpos(x, y);
        cz_tstr((char *)(p + 8), p[7]);
        return 1;
    }
    return 0;                       /* DL_NEXT, DL_END */
}

/* Draw the list, centered on virtual x,y, shifted right s. A key pressed
 * meanwhile stops it (aborted). */
void dl_show(int x, int y, unsigned char s)
{
    unsigned int c;
    int r;

    sh = s;
    dl_cx = x;
    dl_cx2 = x << 1;
    dl_cy = y;
    dl_sx = s + 1;
    dl_sy = s;
    dl_prep();
    dl_px = dl_py = 0;
    dl_pc = 0x1F;                   /* no vertex yet */
    aborted = 0;
    dxf_flush();                    /* its buffer is about to be ours */
    for (c = 0; c < dl_nchunks; c++) {
        if (bdos(CPM_ICON, 0)) {
            aborted = 1;
            return;
        }
        dl_lofs = 0;                /* its header: is any of it on screen? */
        dl_lcnt = HDR;
        dl_load(c);
        if ((int)dl_buf[0] > (int)dl_buf[2] || dl_tx(dl_buf[2]) < 0
            || dl_tx(dl_buf[0]) > SCRW - 1 || dl_ty(dl_buf[3]) < 0
            || dl_ty(dl_buf[1]) > SCRH - 1)
            continue;
        dl_lofs = HDR;
        dl_lcnt = DL_CHUNK - HDR;
        dl_load(c);
        dl_ptr = dl_buf + HDR;
        dl_end = dl_buf + DL_CHUNK;
        dl_cpok = 0;
        while ((r = dl_run())) {
            if (r == 2) {
                clipline(dl_x0, dl_y0, dl_px, dl_py);
                continue;
            }
            if (!record()) {
                if ((dl_ptr[1] & 0xFF) == DL_END)
                    return;
                break;              /* DL_NEXT */
            }
        }
    }
}
