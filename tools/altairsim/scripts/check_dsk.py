#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
"""Check altairsim 8MB Altair CP/M disk images for malformed sectors.

Every 137-byte sector on these images is in one of the two 88-DCDD
layouts, each closed by a 0FFH stop byte and a checksum of its 128 data
bytes:

  system-track layout   data at 3..130, 0FFH at 131, checksum at 132
  data-track layout     checksum at 4, data at 7..134, 0FFH at 135

A sector that matches neither was half-written -- in practice, because the
disk was UNMOUNTed (or the machine CONFIG LOADed/reset) while the CP/M BIOS
was still flushing its track buffer. CP/M then reports "Bdos Err On A: Bad
Sector" on the next boot. The cure for the cause is to let the guest go
idle at A0> before unmounting (see tools/altairsim/README.md, "Ending a
session").

Usage: check_dsk.py <image.DSK>...   (exit status 1 if any sector is bad)
"""
import sys

SECTOR = 137
PER_TRACK = 32


def bad_sectors(path):
    data = open(path, "rb").read()
    bad = []
    for i in range(len(data) // SECTOR):
        s = data[i * SECTOR:(i + 1) * SECTOR]
        system = s[131] == 0xFF and s[132] == sum(s[3:131]) & 0xFF
        datatrk = s[135] == 0xFF and s[4] == sum(s[7:135]) & 0xFF
        if not (system or datatrk):
            bad.append((i // PER_TRACK, i % PER_TRACK))
    return bad


def main(paths):
    if not paths:
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    status = 0
    for path in paths:
        bad = bad_sectors(path)
        if bad:
            status = 1
            where = ", ".join("track %d sector %d" % ts for ts in bad[:8])
            more = " ..." if len(bad) > 8 else ""
            print("%s: %d BAD sector(s): %s%s" % (path, len(bad), where, more))
        else:
            print("%s: ok" % path)
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
