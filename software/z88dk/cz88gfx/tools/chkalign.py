#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Checks the ACRTC port accesses of cz88gfx (1.5): the opcode fetched right
# after an IN or OUT to the ACRTC must have A1 = 0 after port 70H (ACRSR)
# and A1 = 1 after port 72H (ACRDAT), wherever the linker puts the library.
# See the comment at the top of src/CZPORT.Z88 for the reason.
#
# Three checks:
#   1. No module but CZPORT has an IN or OUT to port 70H or 72H (the build's
#      listings, build/CZ*.LIS).
#   2. In CZPORT, assuming its section starts at an address that is a
#      multiple of 4, every access is followed by a fetch with the right A1.
#      That holds at every link base because the section is aligned
#      (SECTION code_home, ALIGN 4).
#   3. In every linked program map given (default: the check programs and the
#      PAD*.MAP programs build.sh links at four link bases), CZPORT really
#      did land at an address that is a multiple of 4, and every access
#      address passes the rule.
#
# Usage: chkalign.py [-b <build dir>] [<program>.MAP ...]
# Exit status 1 if any access breaks the rule.
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(HERE, "..", "build")
PORTS = {0x70: 0, 0x72: 1}          # port -> wanted A1 of the next fetch
ALIGN = 4                           # what CZPORT's section is aligned to
PORTMOD = "CZPORT"
ANCHOR = "CZWREG"                   # the label at offset 0 of CZPORT's code


def accesses(path):
    """(offset, 'IN'|'OUT', port) of every ACRTC access in a listing, and
    the offset of each label."""
    found, labels = [], {}
    for line in open(path, errors="replace"):
        m = re.match(r"\s*\d+\s+([0-9a-f]{4})\s+([0-9a-f]+)\s+(.*)", line)
        if not m:
            continue
        off, byt, text = int(m.group(1), 16), m.group(2), m.group(3)
        lab = re.match(r"(\w+):\s*(.*)", text)
        if lab:
            labels[lab.group(1)] = off
            text = lab.group(2)
        mn = text.split(None, 1)[0].upper() if text.strip() else ""
        if mn in ("IN", "OUT") and len(byt) == 4 and byt[:2] in ("db", "d3") \
                and int(byt[2:], 16) in PORTS:
            found.append((off, mn, int(byt[2:], 16)))
    return found, labels


def rule(addr, port):
    """True if the fetch after the access at addr is right."""
    return ((addr + 2) >> 1) & 1 == PORTS[port]


def main():
    args = sys.argv[1:]
    build = BUILD
    if args[:1] == ["-b"]:
        build, args = args[1], args[2:]
    bad = 0

    # 1. only CZPORT touches the ACRTC
    lis = sorted(glob.glob(os.path.join(build, "CZ*.LIS")))
    if not any(os.path.basename(f) == PORTMOD + ".LIS" for f in lis):
        print("error: no %s.LIS in %s" % (PORTMOD, build))
        return 1
    for f in lis:
        mod = os.path.basename(f)[:-4]
        if mod == PORTMOD:
            continue
        for off, op, port in accesses(f)[0]:
            print("%s +%04X: %s %02XH is outside %s" % (mod, off, op, port, PORTMOD))
            bad += 1

    # 2. CZPORT at any base that is a multiple of ALIGN
    acc, labels = accesses(os.path.join(build, PORTMOD + ".LIS"))
    if labels.get(ANCHOR) != 0:
        print("error: %s is not at offset 0 of %s" % (ANCHOR, PORTMOD))
        bad += 1
    for off, op, port in acc:
        if not rule(off, port):
            print("%s +%04X: %s %02XH is followed by a fetch with A1=%d" %
                  (PORTMOD, off, op, port, ((off + 2) >> 1) & 1))
            bad += 1
    print("%s: %d ACRTC accesses, each fetch after one has the right A1 at any base "
          "that is a multiple of %d" % (PORTMOD, len(acc), ALIGN))

    # 3. the linked programs
    maps = args or sorted(glob.glob(os.path.join(build, "CHK*.MAP")) +
                          glob.glob(os.path.join(build, "CCHK*.MAP")) +
                          glob.glob(os.path.join(build, "PAD*.MAP")))
    for mp in maps:
        base = None
        for line in open(mp, errors="replace"):
            m = re.match(r"%s\s+= \$([0-9A-Fa-f]+) ; addr" % ANCHOR, line)
            if m:
                base = int(m.group(1), 16)
                break
        if base is None:
            continue                # this program did not link CZPORT
        name = os.path.basename(mp)
        if base % ALIGN:
            print("%s: %s is at %04X, not a multiple of %d" % (name, PORTMOD, base, ALIGN))
            bad += 1
            continue
        mbad = 0
        for off, op, port in acc:
            if not rule(base + off, port):
                print("%s: %04X %s %02XH: next fetch %04X has A1=%d" %
                      (name, base + off, op, port, base + off + 2, ((base + off + 2) >> 1) & 1))
                mbad += 1
        bad += mbad
        print("%s: %s at %04X, %d accesses%s" %
              (name, PORTMOD, base, len(acc), "" if not mbad else ", %d wrong" % mbad))
    if bad:
        print("FAIL: %d ACRTC access(es) can be followed by a wrong-A1 fetch" % bad)
        return 1
    print("ok: every ACRTC access is followed by a fetch with the right A1")
    return 0


sys.exit(main())
