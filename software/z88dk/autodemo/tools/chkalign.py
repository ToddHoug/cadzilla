#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Checks where a built program's cz88gfx library puts its ACRTC IN/OUT
# instructions. On the real board the opcode fetched right after an access
# to the ACRTC must have A1 = 0 after port 70H (status/address) and A1 = 1
# after port 72H (data); an IN breaking that is suspected of corrupting the
# fetch (see the padding at the end of src/AUTODEMO.Z88). Library module
# addresses come from build/<NAME>.MAP and the instruction offsets from the
# dev library's listings (software/z88dk/cz88gfx/build/*.LIS), which match
# release 1.4. Usage:
#   python3 software/z88dk/autodemo/tools/chkalign.py [build/AUTODEMO.MAP]
# Exit status 1 if any IN breaks the rule.
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
MAP = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "..", "build", "AUTODEMO.MAP")
LIS = os.path.join(HERE, "..", "..", "cz88gfx", "build")
PORTS = {0x70: 0, 0x72: 1}          # port -> wanted A1 of the next fetch

syms = {}
for line in open(MAP):
    m = re.match(r"(\w+)\s+= \$([0-9A-F]+) ; addr, (\w+), , (\w*),", line)
    if m:
        syms[(m.group(4), m.group(1))] = int(m.group(2), 16)
mods = sorted({k[0] for k in syms if k[0] and k[0] != os.path.basename(MAP).split(".")[0]})

bad_in = bad_out = n = 0
for mod in mods:
    off, ins = {}, []
    for line in open(os.path.join(LIS, mod + ".LIS")):
        m = re.match(r"\s*\d+\s+([0-9a-f]{4})\s+([0-9a-f]+)\s*(.*)", line)
        if not m:
            continue
        o, b = int(m.group(1), 16), m.group(2)
        lab = re.match(r"(\w+):", m.group(3))
        if lab:
            off[lab.group(1)] = o
        if len(b) >= 4 and b[:2] in ("db", "d3") and int(b[2:4], 16) in PORTS:
            ins.append((o, "IN" if b[:2] == "db" else "OUT", int(b[2:4], 16)))
    base = next((a - off[n_] for (mm, n_), a in syms.items() if mm == mod and n_ in off), None)
    if base is None:
        continue
    for o, op, port in ins:
        n += 1
        nxt = base + o + 2
        ok = ((nxt >> 1) & 1) == PORTS[port]
        if not ok:
            print("%s %04X %s %02XH: next fetch %04X has A1=%d" % (mod, base + o, op, port, nxt, (nxt >> 1) & 1))
            if op == "IN":
                bad_in += 1
            else:
                bad_out += 1
print("%d ACRTC accesses: %d IN and %d OUT break the rule" % (n, bad_in, bad_out))
sys.exit(1 if bad_in else 0)
