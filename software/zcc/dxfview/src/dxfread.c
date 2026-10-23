/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (C) 2026 Todd Houg
 *
 * dxfread.c -- DXFVIEW's DXF reader
 *
 * A DXF file is a list of pairs of lines: a group code (an integer) and
 * its value. dxf_next() reads one pair into dxf_code and dxf_val, and
 * notes the file offset it started at in dxf_off. dxf_seek() goes back to
 * such an offset, which is how a block is drawn: DXFVIEW remembers where
 * each block's entities start and jumps there for every INSERT.
 *
 * The file is read through z88dk's CP/M open/read/lseek, 512 bytes at a
 * time into its own buffer, and split into lines by rdline() in
 * RDLINE.Z88. Lines may end in CR/LF or LF. A ^Z (CP/M's end of text) or
 * the real end of the file ends it.
 */
#include <fcntl.h>
#include <string.h>
#include "dxfview.h"

#define BUFSZ   512
#define CTLZ    0x1A

int dxf_code;
char dxf_val[VALMAX];
long dxf_off;

/* The buffer, shared with RDLINE.Z88's rdline(). */
unsigned char rd_buf[BUFSZ];
unsigned char *rd_ptr, *rd_end;     /* the next byte, the end of the data */
unsigned char rd_eof;

static int fd = -1;
static long bstart;                 /* the file offset of rd_buf[0] */

extern int rdline(char *s) __z88dk_fastcall;

int dxf_open(char *name)
{
    fd = open(name, O_RDONLY, 0);
    if (fd == -1)
        return 0;
    bstart = 0;
    rd_ptr = rd_end = rd_buf;
    rd_eof = 0;
    return 1;
}

void dxf_close(void)
{
    if (fd != -1)
        close(fd);
    fd = -1;
}

/* Forget what is in the buffer (a redraw is about to use it). */
void dxf_flush(void)
{
    rd_ptr = rd_end = rd_buf;
}

/* Refill the buffer; 0 at the end of the file. rdline() calls this. */
int rd_fill(void)
{
    int n;

    bstart += rd_end - rd_buf;
    rd_ptr = rd_end = rd_buf;
    n = read(fd, rd_buf, BUFSZ);
    if (n <= 0) {
        rd_eof = 1;
        return 0;
    }
    rd_end = rd_buf + n;
    return 1;
}

void dxf_seek(long off)
{
    long base;

    if (off >= bstart && off < bstart + (rd_end - rd_buf)) {
        rd_ptr = rd_buf + (unsigned int)(off - bstart);
        return;
    }
    base = off & ~127L;             /* a whole CP/M record */
    lseek(fd, base, SEEK_SET);
    bstart = base;
    rd_end = rd_buf;
    rd_eof = 0;
    if (rd_fill() && off - base < rd_end - rd_buf)
        rd_ptr = rd_buf + (unsigned int)(off - base);
    else
        rd_ptr = rd_end;
}

int dxf_next(void)
{
    if (rd_eof) {
        dxf_code = 0;
        strcpy(dxf_val, "EOF");
        return 0;
    }
    dxf_off = bstart + (rd_ptr - rd_buf);
    if (!rdline(dxf_val) || (dxf_code = dxf_int(), !rdline(dxf_val))) {
        dxf_code = 0;
        strcpy(dxf_val, "EOF");
        return 0;
    }
    return 1;
}

int dxf_is(char *s)
{
    return strcmp(dxf_val, s) == 0;
}

int dxf_int(void)
{
    char *p = dxf_val;
    int n = 0;
    unsigned char neg = 0;

    while (*p == ' ')
        p++;
    if (*p == '-') {
        neg = 1;
        p++;
    }
    while (*p >= '0' && *p <= '9')
        n = (n << 3) + (n << 1) + (*p++ - '0');
    return neg ? -n : n;
}

static const float n10[] = {
    1.0, 1e-1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7, 1e-8, 1e-9
};

static const float p10[] = {
    1.0, 10.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0, 10000000.0,
    100000000.0, 1000000000.0
};

/* A number: [-]digits[.digits][E[+-]digits]. The first eight significant
 * digits (a float holds about seven) are collected as two 16-bit groups of
 * four, using shifts and adds, and converted once. So a value costs a few
 * float operations, not a 32-bit multiply per digit. */
float dxf_float(void)
{
    char *p = dxf_val;
    unsigned int hi = 0, lo = 0, d;
    unsigned char nsig = 0, nlo = 0, neg = 0, eneg = 0, frac = 0;
    int scale = 0, e = 0;
    float f;

    while (*p == ' ')
        p++;
    if (*p == '-') {
        neg = 1;
        p++;
    } else if (*p == '+')
        p++;
    for (;; p++) {
        if (*p == '.') {
            frac = 1;
            continue;
        }
        d = *p - '0';
        if (d > 9)
            break;
        if (nsig < 8) {
            if (nsig || d) {            /* x10 as shifts: no multiply */
                if (nsig < 4)
                    hi = (hi << 3) + (hi << 1) + d;
                else {
                    lo = (lo << 3) + (lo << 1) + d;
                    nlo++;
                }
                nsig++;
            }
            if (frac)
                scale--;
        } else if (!frac)
            scale++;
    }
    if (*p == 'E' || *p == 'e') {
        p++;
        if (*p == '-') {
            eneg = 1;
            p++;
        } else if (*p == '+')
            p++;
        while (*p >= '0' && *p <= '9')
            e = e * 10 + (*p++ - '0');
        scale += eneg ? -e : e;
    }
    f = (float)hi;
    if (nlo)
        f = f * p10[nlo] + (float)lo;
    if (nsig) {
        while (scale > 9) {
            f *= 1e9;
            scale -= 9;
        }
        while (scale < -9) {
            f *= 1e-9;
            scale += 9;
        }
        if (scale > 0)
            f *= p10[scale];
        else if (scale < 0)
            f *= n10[-scale];       /* a multiply is cheaper than a divide */
    }
    return neg ? -f : f;
}
