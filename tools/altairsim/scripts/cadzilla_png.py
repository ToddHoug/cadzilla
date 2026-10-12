#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
"""Render the CADzilla board's picture from an altairsim snapshot to a PNG.

The picture is rebuilt from the board's own state in the snapshot (altairsim's
`snapshot` MCP tool, or SNAPSHOT at the monitor):
  - the ACRTC's 2 MB frame memory, 8 bits a pixel;
  - the Bt453's palette RAM, so colors are what the program loaded;
  - the 1 bpp overlay SRAM, drawn in Bt453 overlay color 2, but only if
    the MODE register's OLEN bit (3) is on, as on the board.

It assumes the layout czgfx programs: one base screen, starting at frame word
0, single access, (width / 2) words a raster. Pass --size for 640x480 or
800x600; the default is 1024x768.

This reads altairsim's snapshot format directly. The board's state is written
as the ACRTC (ending with its frame memory, a 0x200000-byte length-prefixed
blob), then the Bt453 (palette RAM 256x3, overlay registers 4x3, address,
phase, 3 pending bytes), then the MODE register, then the overlay SRAM (a
0x40000-byte blob). If altairsim changes that layout, this needs to follow.

Usage:
  cadzilla_png.py <snapshot> <out.png> [--size WxH] [--crop x0,y0,x1,y1]
                  [--zoom N] [--no-overlay]
"""
import argparse
import struct
import sys

from PIL import Image

FRAME = 0x200000
OVERLAY = 0x40000
BT453 = 768 + 12 + 1 + 1 + 3


def board_state(data):
    """(frame, palette, overlay color 2, MODE, overlay) from a snapshot."""
    kf, ko = struct.pack('<I', FRAME), struct.pack('<I', OVERLAY)
    best = None
    i = data.find(kf)
    while i >= 0:                      # the last frame-sized blob that the
        end = i + 4 + FRAME            # overlay blob follows closely: an
        if end <= len(data):           # earlier match can be a coincidence
            j = data.find(ko, end, end + 4096)
            if j >= 0:
                best = (i, j)
        i = data.find(kf, i + 1)
    if best is None:
        raise ValueError('no CADzilla board state found in the snapshot')
    i, j = best
    mode = data[j - 1]
    dac = data[j - 1 - BT453:j - 1]
    palette = list(dac[:768])
    ovcolor = tuple(dac[768 + 6:768 + 9])           # overlay register 2
    return data[i + 4:i + 4 + FRAME], palette, ovcolor, mode, data[j + 4:j + 4 + OVERLAY]


def render(snapshot, width=1024, height=768, overlay=True):
    with open(snapshot, 'rb') as f:
        frame, palette, ovcolor, mode, ovl = board_state(f.read())
    img = Image.frombytes('P', (width, height), frame[:width * height])
    img.putpalette(palette)
    img = img.convert('RGB')
    if overlay and mode & 0x08:
        # overlay bit p (frame pixel p) is word p >> 4, bit p & 15, words little-
        # endian: byte 2k holds pixels 16k..16k+7, bit 0 first. PIL's 1-bit
        # images are MSB first, so reverse the bits of every byte.
        rev = bytes(int('{:08b}'.format(b)[::-1], 2) for b in range(256))
        bits = ovl[:width * height // 8].translate(rev)
        mask = Image.frombytes('1', (width, height), bits)
        img.paste(Image.new('RGB', (width, height), ovcolor), (0, 0), mask)
    return img


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument('snapshot')
    ap.add_argument('out')
    ap.add_argument('--size', default='1024x768')
    ap.add_argument('--crop', help='x0,y0,x1,y1 in picture pixels, top-left origin')
    ap.add_argument('--zoom', type=int, default=1)
    ap.add_argument('--no-overlay', action='store_true')
    a = ap.parse_args(argv)
    w, h = (int(v) for v in a.size.lower().split('x'))
    img = render(a.snapshot, w, h, overlay=not a.no_overlay)
    if a.crop:
        img = img.crop(tuple(int(v) for v in a.crop.split(',')))
    if a.zoom > 1:
        img = img.resize((img.width * a.zoom, img.height * a.zoom), Image.NEAREST)
    img.save(a.out, optimize=True)
    print(a.out)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
