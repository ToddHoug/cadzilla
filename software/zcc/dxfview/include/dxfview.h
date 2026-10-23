/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * dxfview.h -- DXFVIEW's shared types, state and prototypes
 *
 * The modules:
 *   dxfview.c   main: the view, the keys, the console
 *   dxfread.c   the DXF reader: group code/value pairs, byte offsets, seeks
 *   dxfscan.c   pass 1: the header, the LAYER and VPORT tables, the blocks
 *   dxfent.c    the entity walker: blocks, INSERTs, layers and colors
 *   render.c    3D -> the display list: the view, projection, clipping
 *   dlist.c     the display list: written by a regen, drawn by a redraw
 *               (DLRUN.Z88: its 8080 inner loop)
 *   aci.c       AutoCAD's 256 standard colors (ACI) for the palette
 */
#ifndef DXFVIEW_H
#define DXFVIEW_H

#define SCRW    1024            /* the screen, cz_init(CZ_M1K) */
#define SCRH    768

/* ---- dxfread.c ---- */

#define VALMAX  256             /* a value line, NUL included */

extern int dxf_code;            /* the current pair: its group code */
extern char dxf_val[VALMAX];    /*   and value, trailing CR/LF gone */
extern long dxf_off;            /* the file offset of its code line */

int dxf_open(char *name);       /* 0 = cannot open */
void dxf_close(void);
int dxf_next(void);             /* read the next pair; 0 = end of file */
void dxf_seek(long off);        /* the next dxf_next() reads at off */
void dxf_flush(void);           /* forget the buffer's contents */
float dxf_float(void);          /* dxf_val as a number */
int dxf_int(void);              /* dxf_val as an integer */
int dxf_is(char *s);            /* dxf_val == s */
extern unsigned char rd_buf[];  /* its 512-byte buffer (a redraw's, too) */

/* ---- dxfscan.c ---- */

#define LAYMAX  96
#define BLKMAX  160
#define LF_FROZEN 1             /* LAYER group 70, bit 0 */

struct layer {
    char *name;
    unsigned char hash;
    int color;                  /* negative = the layer is off */
    unsigned char flags;
};

struct block {
    char *name;
    unsigned char hash;
    long off;                   /* the offset of its BLOCK header */
};

extern struct layer *layers;    /* LAYMAX of them, from the heap */
extern int nlayers;
extern struct block *blocks;    /* BLKMAX of them, from the heap */
extern int nblocks;
extern long ents_off;           /* the first entity of ENTITIES */

/* The *ACTIVE viewport's view (VPORT 16/26/36, 17/27/37, 51, 71). */
extern unsigned char vp_found;
extern float vp_dir[3], vp_tgt[3], vp_twist;
extern unsigned char vp_persp;

int scan_init(void);            /* the tables; 0 = not enough memory */
int scan(void);                 /* 0 = not a usable DXF file */
int find_layer(char *name);     /* index, -1 if not found */
int find_block(char *name);     /* index, -1 if not found */

/* ---- render.c ---- */

/* A 3x4 transform, row-major: x' = m[0]x + m[1]y + m[2]z + m[3], ... */
typedef struct {
    float m[12];
    signed char sim;            /* 1 = a plan similarity, -1 mirrored, 0 neither */
} XF;

/* A character's advance per unit of text height: the 8x8 font draws a
 * 7-pixel-high capital in an 8-pixel cell. */
#define TEXTW   1.1428571

#define VIEW_PLAN   0
#define VIEW_SAVED  1

extern unsigned char measuring; /* 1 = measure extents, don't draw */
extern float ext[4];            /* the measured extents: x0 y0 x1 y1 */
extern float vscale, vcx, vcy;  /* the regen: scale, center (projected) */
extern float vsub;              /* virtual units per pixel: 2^dl_k */
extern unsigned char persp;
extern XF view;                 /* WCS -> eye */

void view_setup(unsigned char mode);
void xf_mul(XF *r, XF *a, XF *b);   /* r = a * b, r may not be a or b */
void xf_sim(XF *t);                 /* set t->sim */
void r_color(unsigned char c);
XF *r_begin(void);                  /* before a pass: the root transform */
void r_up(void);                    /* lift the pen */
void r_to(XF *t, float x, float y, float z);  /* move or draw to x,y,z */
void r_point(XF *t, float x, float y, float z);
void r_arc(XF *t, float cx, float cy, float cz, float r, float a0, float a1);
void r_text(XF *t, float x, float y, float z, float h, float rot, char *s);

/* ---- dlist.c ---- */

#define DL_CHUNK 256            /* words: a chunk of the list */
#define VMAX    8000            /* the virtual screen: -VMAX..VMAX */

extern unsigned int dl_nchunks; /* the list's size, in chunks */
extern unsigned char dl_clipped; /* the regen left something out */

void dl_reset(void);            /* start a list */
void dl_finish(void);           /* end it */
void dl_color(unsigned char c);
void dl_move(int x, int y);
void dl_draw(int x, int y);
void dl_dot(int x, int y);
void dl_circle(int x, int y, unsigned int r);
void dl_arc(int x, int y, int x1, int y1, int x2, int y2, unsigned char dir);
void dl_text(int x, int y, unsigned int h, unsigned char dir, int gx, int gy,
             char *s);
void dl_show(int x, int y, unsigned char s);  /* redraw: center, shift */

/* ---- dxfent.c ---- */

extern unsigned char aborted;   /* a key was pressed during a draw */
extern unsigned int nents;      /* entities drawn in the last pass */
void walk_all(void);            /* measure, or regen the display list */

/* ---- aci.c ---- */

void aci_load(void);            /* AutoCAD's colors into the palette */

#endif /* DXFVIEW_H */
