/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * dxfview.c -- DXFVIEW, an AutoCAD Release 10 DXF viewer for CADzilla
 *
 *   A0>DXFVIEW SHUTTLE.DXF          (.DXF is the default extension)
 *   A0>DXFVIEW SHUTTLE P            (start in the plan view)
 *
 * It reads the drawing's layers, blocks and saved view (dxfscan.c), loads
 * AutoCAD's 256 colors into the palette (aci.c), fits the drawing to the
 * 1024x768 screen and draws it. The view is the drawing's own *ACTIVE
 * viewport, which may be a 3D or perspective view, or the plan view
 * (looking down Z); V switches between them. Then keys:
 *
 *   +  -          zoom in, out (x2, about the center)
 *   W A S D       pan a quarter screen (also H J K L, vi style)
 *   F             fit the drawing to the screen again
 *   V             the saved view / the plan view
 *   R             redraw (from the display list)
 *   G             regen (the display list again, from the file)
 *   ESC  ^C  Q    quit
 *
 * As in AutoCAD, a REGEN turns the drawing into a display list of 2D
 * integer vectors (dxfent.c, render.c, dlist.c): it reads the whole file
 * and does all the floating point, so it is slow. A REDRAW draws the list
 * (dlist.c, DLRUN.Z88), and zooming and panning only redraw it: the list
 * is kept 4 to 16 times finer than the screen, so a zoom by 2 is a shift.
 * A regen is only needed to zoom in further than that, to pan beyond what
 * a zoomed-in list holds, or for the other view (V). The first view in
 * each mode costs one more pass, which measures the drawing's extents as
 * seen in that view. A key pressed during any of it stops it and is acted
 * on at once.
 *
 * DXFVIEW draws in wireframe. It does not draw linetypes, widths, fills,
 * 3D meshes or shapes, and it ignores extrusion directions (210/220/230).
 *
 * Build on the host (skill cadzilla-build-zcc), then copy the program and
 * a drawing onto the CP/M disk with R:
 *   tools/z88dk/zccbuild.sh software/zcc/dxfview      -> build/DXFVIEW.COM
 *   A0>R DXFVIEW.COM                          (hb0 HOSTDIR = build/)
 *   A0>R SHUTTLE.DXF                          (hb0 HOSTDIR = dxf/)
 */
#include <string.h>
#include <math.h>
#include <cpm.h>
#include <cz88gfx.h>
#include "dxfview.h"

#define ESC     0x1B
#define CTLC    0x03
#define ZOOMMAX 14

static char fname[20];
static unsigned char mode;
static unsigned char fitok[2];
static float fitcx[2], fitcy[2], fitsc[2];
static float mext[2][4];            /* each mode's measured extents */
static signed char zoom;            /* the scale is fit * 2^zoom */
static float cx, cy;                /* the view center, projected */

/* The display list: what view it was made for */
static unsigned char dlok;          /* there is one, for dlmode */
static unsigned char dlmode, dlk, dlfull;   /* k; it holds the whole drawing */
static signed char dlzoom;
static float rcx, rcy, rvs;         /* its center, virtual units per unit */

/* Console output through the BDOS (no stdio: it would cost 3K of code).
 * A \n prints as CR/LF. */
static void prs(char *s)
{
    for (; *s; s++) {
        if (*s == '\n')
            bdos(CPM_WCON, '\r');
        bdos(CPM_WCON, *s);
    }
}

static void prn(unsigned int n)
{
    char b[6], *p = b + 5;

    *p = 0;
    do
        *--p = '0' + n % 10;
    while (n /= 10);
    prs(p);
}

/* The file name and options from the command tail at 0080H. */
static int args(unsigned char *plan)
{
    char *t = (char *)0x80, *e;
    unsigned char n = *t++;
    char *p;

    t[n] = 0;
    while (*t == ' ')
        t++;
    for (e = t; *e && *e != ' '; e++)
        ;
    n = e - t;
    if (!n || n > 14)
        return 0;
    memcpy(fname, t, n);
    fname[n] = 0;
    if (!strchr(fname, '.'))
        strcat(fname, ".DXF");
    for (p = e; *p; p++)
        if (*p == 'P')
            *plan = 1;
    return 1;
}

/* A key: BDOS 1, so a key the BDOS kept while printing isn't lost. */
static int key(void)
{
    int k = bdos(CPM_RCON, 0) & 0x7F;

    if (k >= 'a' && k <= 'z')
        k -= 'a' - 'A';
    return k;
}

static float pow2(signed char n)
{
    float f = 1.0;

    for (; n > 0; n--)
        f *= 2.0;
    for (; n < 0; n++)
        f *= 0.5;
    return f;
}

/* Measure the drawing in the current view and fit it to the screen. */
static void fit(void)
{
    float w, h, sx, sy;

    if (!fitok[mode]) {
        prs("Measuring");
        measuring = 1;
        vscale = 1.0;
        vcx = vcy = 0.0;
        walk_all();
        measuring = 0;
        prs("\n");
        w = ext[2] - ext[0];
        h = ext[3] - ext[1];
        if (w < 0.0) {                  /* nothing visible */
            ext[0] = ext[1] = 0.0;
            w = h = 0.0;
        }
        sx = w > 0.0 ? (SCRW - 1) / w : 1e30;
        sy = h > 0.0 ? (SCRH - 1) / h : 1e30;
        if (sx > sy)
            sx = sy;
        if (sx >= 1e30)
            sx = 1.0;
        fitsc[mode] = sx * 0.95;
        fitcx[mode] = ext[0] + w / 2.0;
        fitcy[mode] = ext[1] + h / 2.0;
        fitok[mode] = 1;
        memcpy(mext[mode], ext, sizeof ext);
    }
    cx = fitcx[mode];
    cy = fitcy[mode];
    zoom = 0;
}

/* The view's center in the display list's units, and its shift: 0 if the
 * list can't show this view and a regen is needed. */
static int listed(int *vx, int *vy, unsigned char *s)
{
    float x, y, hw, hh;
    signed char sh;

    if (!dlok || dlmode != mode)
        return 0;
    sh = dlk - (zoom - dlzoom);
    if (sh < 0)
        return 0;                       /* zoomed in past its precision */
    x = (cx - rcx) * rvs;
    y = (cy - rcy) * rvs;
    if (x < -VMAX || x > VMAX || y < -VMAX || y > VMAX)
        return 0;
    if (!dlfull) {                      /* it holds only part: is the view in it? */
        hw = SCRW / 2 * pow2(sh);
        hh = SCRH / 2 * pow2(sh);
        if (x - hw < -VMAX || x + hw > VMAX || y - hh < -VMAX || y + hh > VMAX)
            return 0;
    }
    *vx = (int)(x < 0.0 ? x - 0.5 : x + 0.5);
    *vy = (int)(y < 0.0 ? y - 0.5 : y + 0.5);
    *s = sh;
    return 1;
}

/* Regenerate the display list for the view. Its resolution, 2^k units a
 * pixel: as fine as still holds the whole drawing, up to 16. If not even 4
 * does (the view is zoomed well in), 4 anyway: the list then holds the
 * 2000 pixels round the view, five pans each way, and a regen costs a
 * whole pass over the file however little of it is in view. */
static void regen(void)
{
    float sc = fitsc[mode] * pow2(zoom), e, t, *x = mext[mode];
    unsigned char k;

    e = fabs(x[0] - cx);
    if ((t = fabs(x[2] - cx)) > e)
        e = t;
    if ((t = fabs(x[1] - cy)) > e)
        e = t;
    if ((t = fabs(x[3] - cy)) > e)
        e = t;
    e *= sc;                            /* the drawing's reach, in pixels */
    for (k = 4; k > 2 && e * pow2(k) > VMAX * 0.98; k--)
        ;
    vsub = pow2(k);
    vscale = sc * vsub;
    vcx = cx;
    vcy = cy;
    prs("Regenerating");
    walk_all();
    prs("\n");
    dlok = !aborted;
    dlmode = mode;
    dlk = k;
    dlzoom = zoom;
    rcx = cx;
    rcy = cy;
    rvs = vscale;
    dlfull = !dl_clipped;
}

static void status(void)
{
    prs(fname);
    prs(mode == VIEW_SAVED ? (persp ? ": perspective" : ": saved") : ": plan");
    prs(" view, zoom ");
    if (zoom >= 0) {
        prs("x");
        prn(1u << zoom);
    } else {
        prs("1/");
        prn(1u << -zoom);
    }
    prs(", ");
    prn(nents);
    prs(" entities, display list ");
    prn((dl_nchunks + 1) / 2);
    prs(aborted ? "K (stopped)\n" : "K\n");
}

int main(void)
{
    unsigned char plan = 0, quit = 0, redo, sh;
    int k, vx, vy;

    if (!args(&plan)) {
        prs("usage: DXFVIEW file[.DXF] [P]\n"
            "  draws an AutoCAD R10 DXF drawing; P starts in plan view\n");
        return 1;
    }
    if (!scan_init()) {
        prs("DXFVIEW: not enough memory\n");
        return 1;
    }
    if (!dxf_open(fname)) {
        prs("DXFVIEW: can't open ");
        prs(fname);
        prs("\n");
        return 1;
    }
    prs("DXFVIEW: reading ");
    prs(fname);
    prs("...\n");
    if (!scan()) {
        prs("DXFVIEW: no ENTITIES section\n");
        dxf_close();
        return 1;
    }
    prn(nlayers);
    prs(" layers, ");
    prn(nblocks);
    prs(" blocks");
    if (vp_found)
        prs(vp_persp ? ", a saved perspective view" : ", a saved view");
    prs("\n+/- zoom, WASD pan, F fit, V view, R redraw, ESC quit\n");

    cz_init(CZ_M1K);
    aci_load();
    cz_font(CZ_F8);
    cz_amode(CZ_AM_CLIP);           /* the area is the whole screen */

    mode = vp_found && !plan ? VIEW_SAVED : VIEW_PLAN;
    view_setup(mode);
    fit();
    while (!quit) {
        if (!aborted && !listed(&vx, &vy, &sh)) {
            regen();
            if (!aborted && !listed(&vx, &vy, &sh))
                aborted = 1;            /* (can't happen) */
        }
        if (!aborted) {
            cz_cls(0);
            dl_show(vx, vy, sh);
            if (cz_wait() & CZ_SR_CER)
                cz_abort();
        }
        status();

        /* the key that stopped the drawing, or the next one */
        do {
            redo = 1;
            k = key();
            aborted = 0;
            switch (k) {
            case '+': case '=':
                if (zoom < ZOOMMAX)
                    zoom++;
                break;
            case '-': case '_':
                if (zoom > -ZOOMMAX)
                    zoom--;
                break;
            case 'W': case 'K': cy += SCRH / 4 / (fitsc[mode] * pow2(zoom)); break;
            case 'S': case 'J': cy -= SCRH / 4 / (fitsc[mode] * pow2(zoom)); break;
            case 'A': case 'H': cx -= SCRW / 4 / (fitsc[mode] * pow2(zoom)); break;
            case 'D': case 'L': cx += SCRW / 4 / (fitsc[mode] * pow2(zoom)); break;
            case 'F':
                fit();
                break;
            case 'V':
                if (!vp_found) {
                    redo = 0;
                    break;
                }
                mode = mode == VIEW_SAVED ? VIEW_PLAN : VIEW_SAVED;
                view_setup(mode);
                fit();
                break;
            case 'R':
                break;
            case 'G':                   /* REGEN, as AutoCAD's command */
                dlok = 0;
                break;
            case ESC: case CTLC: case 'Q':
                quit = 1;
                break;
            default:
                redo = 0;
            }
        } while (!redo);
        prs("\n");
    }
    dxf_close();
    cz_cls(0);
    return 0;
}
