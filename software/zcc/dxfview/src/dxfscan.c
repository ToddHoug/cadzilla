/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * dxfscan.c -- DXFVIEW's first pass over a DXF file
 *
 * It reads the file up to the start of the ENTITIES section and keeps:
 *   - every LAYER: its color (negative = off) and whether it is frozen
 *   - the *ACTIVE VPORT's view: direction, target, twist, perspective
 *   - every BLOCK: its name and the file offset of its header, so an
 *     INSERT can seek straight to it
 *   - the offset of the first entity in ENTITIES
 * The tables and the names' pool come from the heap, once: they are not
 * part of the .COM, which the CCP must load below itself. One drawing is
 * opened per run, so they are never freed.
 */
#include <stdlib.h>
#include <string.h>
#include "dxfview.h"

#define POOLMAX 6144            /* the names' pool: at most, */
#define POOLMIN 768             /*   and at least */

struct layer *layers;
int nlayers;
struct block *blocks;
int nblocks;
long ents_off;

unsigned char vp_found;
float vp_dir[3], vp_tgt[3], vp_twist;
unsigned char vp_persp;

static char *pool;
static unsigned int poolsz, pooltop;
static int lastlay;

static unsigned char hash(char *s)
{
    unsigned char h = 0;

    while (*s)
        h += *s++;
    return h;
}

/* A copy of s in the pool, or 0 if the pool is full. */
static char *save(char *s)
{
    unsigned int n = strlen(s) + 1;
    char *p;

    if (pooltop + n > poolsz)
        return 0;
    p = pool + pooltop;
    memcpy(p, s, n);
    pooltop += n;
    return p;
}

int find_layer(char *name)
{
    unsigned char h;
    int i;

    if (lastlay < nlayers && strcmp(layers[lastlay].name, name) == 0)
        return lastlay;
    h = hash(name);
    for (i = 0; i < nlayers; i++)
        if (layers[i].hash == h && strcmp(layers[i].name, name) == 0)
            return lastlay = i;
    return -1;
}

int find_block(char *name)
{
    unsigned char h = hash(name);
    int i;

    for (i = 0; i < nblocks; i++)
        if (blocks[i].hash == h && strcmp(blocks[i].name, name) == 0)
            return i;
    return -1;
}

static void add_layer(char *name, int color, unsigned char flags)
{
    int i = find_layer(name);

    if (i < 0) {
        if (nlayers == LAYMAX || !(name = save(name)))
            return;
        i = nlayers++;
        layers[i].name = name;
        layers[i].hash = hash(name);
    }
    layers[i].color = color;
    layers[i].flags = flags;
}

/* A LAYER record; the current pair is its 0 LAYER. Leaves the next 0. */
static void layer_rec(void)
{
    char name[VALMAX];
    int color = 7;
    unsigned char flags = 0;

    name[0] = 0;
    while (dxf_next() && dxf_code != 0) {
        if (dxf_code == 2)
            strcpy(name, dxf_val);
        else if (dxf_code == 62)
            color = dxf_int();
        else if (dxf_code == 70)
            flags = dxf_int();
    }
    if (name[0])
        add_layer(name, color, flags);
}

/* A VPORT record. Only the first *ACTIVE one is kept: with several tiled
 * viewports, that is the current one. */
static void vport_rec(void)
{
    unsigned char active = 0;
    float d[3], t[3], tw = 0.0;
    unsigned char mode = 0;

    d[0] = d[1] = t[0] = t[1] = t[2] = 0.0;
    d[2] = 1.0;
    while (dxf_next() && dxf_code != 0) {
        switch (dxf_code) {
        case 2:  active = dxf_is("*ACTIVE"); break;
        case 16: d[0] = dxf_float(); break;
        case 26: d[1] = dxf_float(); break;
        case 36: d[2] = dxf_float(); break;
        case 17: t[0] = dxf_float(); break;
        case 27: t[1] = dxf_float(); break;
        case 37: t[2] = dxf_float(); break;
        case 51: tw = dxf_float(); break;
        case 71: mode = dxf_int(); break;
        }
    }
    if (active && !vp_found) {
        vp_found = 1;
        memcpy(vp_dir, d, sizeof d);
        memcpy(vp_tgt, t, sizeof t);
        vp_twist = tw;
        vp_persp = mode & 1;
    }
}

/* A BLOCK header; the current pair is its 0 BLOCK. Only the name and
 * where the header is are kept: an INSERT reads the base point there. */
static void block_rec(void)
{
    char name[VALMAX];
    long off = dxf_off;
    struct block *b;

    name[0] = 0;
    while (dxf_next() && dxf_code != 0)
        if (dxf_code == 2)
            strcpy(name, dxf_val);
    if (!name[0] || nblocks == BLKMAX || find_block(name) >= 0)
        return;
    b = &blocks[nblocks];
    if (!(b->name = save(name)))
        return;
    b->hash = hash(name);
    b->off = off;
    nblocks++;
}

int scan_init(void)
{
    layers = malloc(LAYMAX * sizeof(struct layer));
    blocks = malloc(BLKMAX * sizeof(struct block));
    if (!layers || !blocks)
        return 0;
    /* the pool gets what is left */
    for (poolsz = POOLMAX; poolsz >= POOLMIN; poolsz -= 256)
        if ((pool = malloc(poolsz)))
            return 1;
    return 0;
}

int scan(void)
{
    unsigned char sec = 0;      /* 1 TABLES, 2 BLOCKS, 0 anything else */

    nlayers = nblocks = 0;
    pooltop = 0;
    lastlay = 0;
    vp_found = 0;
    add_layer("0", 7, 0);       /* always there, and always index 0 */

    if (!dxf_next())
        return 0;
    for (;;) {
        if (dxf_code != 0) {
            if (!dxf_next())
                return 0;
            continue;
        }
        if (dxf_is("EOF"))
            return 0;
        if (dxf_is("SECTION")) {
            if (!dxf_next())
                return 0;
            sec = 0;
            if (dxf_is("ENTITIES")) {
                dxf_next();
                ents_off = dxf_off;
                return 1;
            }
            if (dxf_is("TABLES"))
                sec = 1;
            else if (dxf_is("BLOCKS"))
                sec = 2;
            continue;
        }
        if (sec == 1 && dxf_is("LAYER"))
            layer_rec();
        else if (sec == 1 && dxf_is("VPORT"))
            vport_rec();
        else if (sec == 2 && dxf_is("BLOCK"))
            block_rec();
        else if (!dxf_next())
            return 0;
    }
}
