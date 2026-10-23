/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * render.c -- DXFVIEW: from drawing coordinates to the display list
 *
 * This is the regen's floating point. A point goes through one 3x4
 * transform (an XF) to eye coordinates: the blocks' INSERTs and the view,
 * multiplied together as the walker goes down into a block. Then:
 *   - a parallel view keeps eye x,y; a perspective view (VPORT 71 bit 0)
 *     divides them by the depth, after clipping a line at a near plane;
 *   - the regen's scale and center (vscale, vcx, vcy), folded into the
 *     root transform by r_begin(), map that to the display list's virtual
 *     screen (dlist.c): integers, -VMAX..VMAX, 2^k to a pixel;
 *   - lines are clipped to that and put in the list as vertices;
 *   - circles and arcs whose transform is a plan similarity (the usual 2D
 *     case) go in the list as circles and arcs, for the ACRTC to draw.
 *     Any other circle (a 3D view, a non-uniform scale) goes in as short
 *     lines.
 * Anything clipped sets dl_clipped: the list does not hold the whole
 * drawing. With `measuring` set, nothing goes in the list: the projected
 * points only grow ext[], the extents that the view is fitted to.
 */
#include <math.h>
#include <cz88gfx.h>
#include "dxfview.h"

#define TWOPI   6.2831853

unsigned char measuring;
float ext[4];
float vscale, vcx, vcy;
float vsub;
unsigned char persp;
XF view;

static XF scr;                  /* view, scaled to pixels: the root XF */
static float sx0, sy0;          /* the screen center's offset */
static float znear;              /* perspective: the near plane's depth */
static float ex, ey, ez;        /* eye(): the last point */
static float cx_, cy_;          /* project(): the last point on screen */
static unsigned char pen;       /* r_to: a previous point */
static float pex, pey, pez;     /*   its eye coordinates */
static float psx, psy;          /*   on screen, */
static unsigned char pin;       /*   if it is in front of the camera */
static int lastx, lasty;        /* the last vertex in the list, */
static unsigned char lastok;    /*   if a line may follow on from it */
static int curcol;

/* Every point comes through here, so it does no more float work than it
 * must: z is 0 for all 2D geometry, and the depth is only needed for a
 * perspective view. */
static void eye(XF *t, float x, float y, float z)
{
    float *m = t->m;

    ex = m[0] * x + m[1] * y + m[3];
    ey = m[4] * x + m[5] * y + m[7];
    if (z != 0.0) {
        ex += m[2] * z;
        ey += m[6] * z;
    }
    if (persp) {
        ez = m[8] * x + m[9] * y + m[11];
        if (z != 0.0)
            ez += m[10] * z;
    }
}

void xf_mul(XF *r, XF *a, XF *b)
{
    float *ra = r->m, *am = a->m, *bm = b->m;
    unsigned char i;

    for (i = 0; i < 12; i += 4) {
        ra[i] = am[i] * bm[0] + am[i + 1] * bm[4] + am[i + 2] * bm[8];
        ra[i + 1] = am[i] * bm[1] + am[i + 1] * bm[5] + am[i + 2] * bm[9];
        ra[i + 2] = am[i] * bm[2] + am[i + 1] * bm[6] + am[i + 2] * bm[10];
        ra[i + 3] = am[i] * bm[3] + am[i + 1] * bm[7] + am[i + 2] * bm[11]
                    + am[i + 3];
    }
    xf_sim(r);
}

/* Does t map the XY plane onto the screen as a similarity (a rotation and
 * a uniform scale, perhaps mirrored)? Then a circle stays a circle. */
void xf_sim(XF *t)
{
    float *m = t->m;
    float tol = (fabs(m[0]) + fabs(m[1])) * 1e-4;

    t->sim = 0;
    if (persp)
        return;
    if (fabs(m[0] - m[5]) <= tol && fabs(m[1] + m[4]) <= tol)
        t->sim = 1;
    else if (fabs(m[0] + m[5]) <= tol && fabs(m[1] - m[4]) <= tol)
        t->sim = -1;
}

/* The view: plan (WCS, looking down Z) or the drawing's saved *ACTIVE
 * viewport, AutoCAD's DVIEW: eye Z along the view direction, eye X
 * level (in the WCS XY plane), then turned by the twist angle. A
 * perspective view puts the camera at target + direction. */
void view_setup(unsigned char mode)
{
    float *m = view.m;
    float zx, zy, zz, xx, xy, xz, yx, yy, yz, n, c, s, t, cx, cy, cz;
    unsigned char i;

    for (i = 0; i < 12; i++)
        m[i] = 0.0;
    m[0] = m[5] = m[10] = 1.0;
    persp = 0;
    if (mode != VIEW_SAVED || !vp_found) {
        xf_sim(&view);
        return;
    }
    n = sqrt(vp_dir[0] * vp_dir[0] + vp_dir[1] * vp_dir[1]
             + vp_dir[2] * vp_dir[2]);
    if (n == 0.0) {
        xf_sim(&view);
        return;
    }
    zx = vp_dir[0] / n;
    zy = vp_dir[1] / n;
    zz = vp_dir[2] / n;
    t = sqrt(zx * zx + zy * zy);
    if (t < 1e-6) {
        xx = 1.0;
        xy = 0.0;
    } else {
        xx = -zy / t;
        xy = zx / t;
    }
    xz = 0.0;
    yx = zy * xz - zz * xy;
    yy = zz * xx - zx * xz;
    yz = zx * xy - zy * xx;
    t = -vp_twist * (TWOPI / 360.0);
    c = cos(t);
    s = sin(t);
    m[0] = c * xx - s * yx;
    m[1] = c * xy - s * yy;
    m[2] = c * xz - s * yz;
    m[4] = s * xx + c * yx;
    m[5] = s * xy + c * yy;
    m[6] = s * xz + c * yz;
    m[8] = zx;
    m[9] = zy;
    m[10] = zz;
    cx = vp_tgt[0];
    cy = vp_tgt[1];
    cz = vp_tgt[2];
    if (vp_persp) {
        persp = 1;
        cx += vp_dir[0];
        cy += vp_dir[1];
        cz += vp_dir[2];
        znear = n * 0.01;
    }
    m[3] = -(m[0] * cx + m[1] * cy + m[2] * cz);
    m[7] = -(m[4] * cx + m[5] * cy + m[6] * cz);
    m[11] = -(m[8] * cx + m[9] * cy + m[10] * cz);
    xf_sim(&view);
}

/* Start a pass. The view's x and y rows are scaled once here, and in a
 * parallel view the offset is added too, so a point needs no more than
 * the one transform. A measuring pass works in projected units (vscale 1,
 * no offset); a regen in the display list's virtual screen units, the
 * regen's center (vcx, vcy) at 0,0. */
XF *r_begin(void)
{
    unsigned char i;

    pen = 0;
    lastok = 0;
    curcol = -1;
    if (measuring) {
        sx0 = sy0 = 0.0;
        ext[0] = ext[1] = 1e30;
        ext[2] = ext[3] = -1e30;
    } else {
        sx0 = -vcx * vscale;
        sy0 = -vcy * vscale;
    }
    for (i = 0; i < 4; i++) {
        scr.m[i] = view.m[i] * vscale;
        scr.m[i + 4] = view.m[i + 4] * vscale;
        scr.m[i + 8] = view.m[i + 8];
    }
    if (!persp) {
        scr.m[3] += sx0;
        scr.m[7] += sy0;
    }
    xf_sim(&scr);
    return &scr;
}

void r_color(unsigned char c)
{
    if (c != curcol && !measuring) {
        dl_color(c);
        curcol = c;
    }
}

/* Project the eye point (ex, ey, ez) into cx_, cy_: one divide, however
 * many lines meet there. 0 if it is behind the near plane. */
static unsigned char project(void)
{
    float w;

    if (!persp) {
        cx_ = ex;
        cy_ = ey;
        return 1;
    }
    if (ez > -znear)
        return 0;
    w = -1.0 / ez;
    cx_ = sx0 + ex * w;
    cy_ = sy0 + ey * w;
    return 1;
}

/* Grow the extents by the eye point. */
static void grow(void)
{
    if (!project())
        return;
    if (cx_ < ext[0])
        ext[0] = cx_;
    if (cx_ > ext[2])
        ext[2] = cx_;
    if (cy_ < ext[1])
        ext[1] = cy_;
    if (cy_ > ext[3])
        ext[3] = cy_;
}

/* The Cohen-Sutherland outcode of a point against the virtual screen. */
static unsigned char outcode(float x, float y)
{
    unsigned char c = 0;

    if (x < -VMAX)
        c = 1;
    else if (x > VMAX)
        c = 2;
    if (y < -VMAX)
        c |= 4;
    else if (y > VMAX)
        c |= 8;
    return c;
}

static int iround(float f)
{
    return f < 0.0 ? -(int)(0.5 - f) : (int)(f + 0.5);
}

/* Put the line x1,y1 - x2,y2 in the display list, clipped to the virtual
 * screen. A polyline's vertices follow on from each other: only a break
 * in it costs a move. */
static void sline(float x1, float y1, float x2, float y2)
{
    unsigned char c1 = outcode(x1, y1), c2 = outcode(x2, y2), c;
    float x, y;
    int ix1, iy1, ix2, iy2;

    while (c1 | c2) {
        dl_clipped = 1;
        if (c1 & c2)
            return;
        c = c1 ? c1 : c2;
        if (c & 1) {
            y = y1 + (y2 - y1) * (-VMAX - x1) / (x2 - x1);
            x = -VMAX;
        } else if (c & 2) {
            y = y1 + (y2 - y1) * (VMAX - x1) / (x2 - x1);
            x = VMAX;
        } else if (c & 4) {
            x = x1 + (x2 - x1) * (-VMAX - y1) / (y2 - y1);
            y = -VMAX;
        } else {
            x = x1 + (x2 - x1) * (VMAX - y1) / (y2 - y1);
            y = VMAX;
        }
        if (c == c1) {
            x1 = x;
            y1 = y;
            c1 = outcode(x, y);
        } else {
            x2 = x;
            y2 = y;
            c2 = outcode(x, y);
        }
    }
    ix1 = iround(x1);
    iy1 = iround(y1);
    ix2 = iround(x2);
    iy2 = iround(y2);
    if (!lastok || ix1 != lastx || iy1 != lasty)
        dl_move(ix1, iy1);
    dl_draw(ix2, iy2);
    lastx = ix2;
    lasty = iy2;
    lastok = 1;
}

/* The eye-space segment a-b that crosses the near plane: clip it there,
 * project, and put it in the list. */
static void eline(float ax, float ay, float az, float bx, float by, float bz)
{
    float t;

    if (persp) {
        if (az > -znear) {
            if (bz > -znear)
                return;
            t = (-znear - az) / (bz - az);
            ax += (bx - ax) * t;
            ay += (by - ay) * t;
            az = -znear;
        } else if (bz > -znear) {
            t = (-znear - bz) / (az - bz);
            bx += (ax - bx) * t;
            by += (ay - by) * t;
            bz = -znear;
        }
        ax = sx0 - ax / az;
        ay = sy0 - ay / az;
        bx = sx0 - bx / bz;
        by = sy0 - by / bz;
    }
    sline(ax, ay, bx, by);
}

void r_up(void)
{
    pen = 0;
}

void r_to(XF *t, float x, float y, float z)
{
    unsigned char in;

    eye(t, x, y, z);
    if (measuring) {
        grow();
        return;
    }
    in = project();
    if (pen) {
        if (in && pin)
            sline(psx, psy, cx_, cy_);
        else if (in || pin)
            eline(pex, pey, pez, ex, ey, ez);
    }
    pex = ex;
    pey = ey;
    pez = ez;
    psx = cx_;
    psy = cy_;
    pin = in;
    pen = 1;
}

void r_point(XF *t, float x, float y, float z)
{
    eye(t, x, y, z);
    if (measuring) {
        grow();
        return;
    }
    if (!project())
        return;
    if (outcode(cx_, cy_))
        dl_clipped = 1;
    else {
        dl_dot(iround(cx_), iround(cy_));
        lastok = 0;
    }
}

/* A circle (a1 - a0 >= 2 pi) or a counter-clockwise arc from a0 to a1
 * (radians, a1 > a0) round cx,cy,cz, in the entity's XY plane. */
void r_arc(XF *t, float cx, float cy, float cz, float r, float a0, float a1)
{
    float sx, sy, rs, sweep = a1 - a0, step, c, s, vx, vy, w, x2, y2;
    unsigned char full = sweep >= TWOPI - 1e-6;
    int n;

    /* the radius (at most), at the center's depth: t's x and y rows are
     * in virtual units already */
    rs = r * sqrt(t->m[0] * t->m[0] + t->m[4] * t->m[4]);
    w = r * sqrt(t->m[1] * t->m[1] + t->m[5] * t->m[5]);
    if (w > rs)
        rs = w;
    eye(t, cx, cy, cz);
    if (persp)
        rs = ez < -znear ? rs / -ez : 0.0;

    if (!measuring && t->sim && project()) {
        sx = cx_;
        sy = cy_;
        if (sx + rs < -VMAX || sx - rs > VMAX || sy + rs < -VMAX
            || sy - rs > VMAX) {
            dl_clipped = 1;             /* all of it off the list */
            return;
        }
        if (rs < 0.5) {
            r_point(t, cx, cy, cz);
            return;
        }
        if (fabs(sx) + rs <= VMAX && fabs(sy) + rs <= VMAX) {
            /* a similarity: the radius is just that of X */
            w = r * sqrt(t->m[0] * t->m[0] + t->m[4] * t->m[4]);
            lastok = 0;
            if (full) {
                dl_circle(iround(sx), iround(sy), iround(w));
                return;
            }
            eye(t, cx + r * cos(a0), cy + r * sin(a0), cz);
            project();
            vx = cx_;
            vy = cy_;
            eye(t, cx + r * cos(a1), cy + r * sin(a1), cz);
            project();
            dl_arc(iround(sx), iround(sy), iround(vx), iround(vy),
                   iround(cx_), iround(cy_),
                   t->sim > 0 ? CZ_DIR_CCW : CZ_DIR_CW);
            return;
        }
        /* partly off the list: as lines, clipped */
    }

    /* As lines. A chord of angle d is at most rs*d*d/8 from the circle:
     * keep that under half a pixel at the regen's zoom. */
    n = (int)(sweep * sqrt(rs / vsub) * 0.5) + 1;
    if (n < 4)
        n = 4;
    else if (n > 128)
        n = 128;
    step = sweep / n;
    c = cos(step);
    s = sin(step);
    vx = r * cos(a0);
    vy = r * sin(a0);
    r_up();
    r_to(t, cx + vx, cy + vy, cz);
    while (n--) {
        w = vx * c - vy * s;
        vy = vx * s + vy * c;
        vx = w;
        r_to(t, cx + vx, cy + vy, cz);
    }
    r_up();
}

/* Text at x,y,z, h high, its baseline at rot radians: in the list with
 * its height, its direction (the nearest 45 degrees) and the end of its
 * baseline, for when it is too small to read. */
void r_text(XF *t, float x, float y, float z, float h, float rot, char *s)
{
    float gx, gy, bx, by, ux, uy, len, hp, a, c = cos(rot), sn = sin(rot);
    unsigned char n = 0, dir;

    while (s[n] && n < 255)
        n++;
    if (!n)
        return;
    len = h * TEXTW * n;
    if (measuring) {
        r_point(t, x, y, z);
        r_point(t, x + c * len, y + sn * len, z);
        r_point(t, x - sn * h, y + c * h, z);
        return;
    }
    eye(t, x - sn * h, y + c * h, z);
    if (!project())
        return;
    ux = cx_;
    uy = cy_;
    eye(t, x + c * h, y + sn * h, z);
    if (!project())
        return;
    bx = cx_;
    by = cy_;
    eye(t, x + c * len, y + sn * len, z);       /* the end of the baseline */
    if (!project() || outcode(cx_, cy_))
        goto out;
    gx = cx_;
    gy = cy_;
    eye(t, x, y, z);                            /* the start: cx_, cy_ */
    if (!project() || outcode(cx_, cy_))
        goto out;
    hp = sqrt((ux - cx_) * (ux - cx_) + (uy - cy_) * (uy - cy_));
    if (hp < 1.0 || hp > 16000.0)
        return;
    a = atan2(by - cy_, bx - cx_);
    if (a < 0.0)
        a += TWOPI;
    dir = (unsigned char)(int)(a * (8.0 / TWOPI) + 0.5) & 7;
    dl_text(iround(cx_), iround(cy_), (unsigned int)(hp + 0.5), dir,
            iround(gx), iround(gy), s);
    lastok = 0;
    return;
out:
    dl_clipped = 1;
}
