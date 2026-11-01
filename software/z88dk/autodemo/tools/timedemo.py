#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
"""Time AUTODEMO's screens on the real Altair: run it, timestamp each banner.

The Altair must be at A0> with the serial console on /dev/ttyUSB0 (9600 8N1)
and no other program (the serial MCP server included) holding the port.
It types AUTODEMO, notes when each screen's banner arrives, and after the
given number of full cycles (default 3) sends Q. It prints the time from the
command to the first banner (disk load and GINIT) and each screen's duration
(banner to the next banner, so it includes the screen's own setup), with
the per-cycle totals. For the simulator, the same figure is the T-states
between two banners in `run until:` calls under work/cadzilla-real.toml, divided
by 2,000,000. If the console is silent for 45 s it gives up and sends
nothing (the board has hung: see the notes in src/AUTODEMO.Z88).

Standard library only (termios); the host timestamps include the roughly
20 ms a banner takes to print at 9600 baud, the same for every screen.

Usage: python3 software/z88dk/autodemo/tools/timedemo.py [CYCLES]
Exit status: 0 done, 2 no A0> prompt, 3 hung.
"""
import os
import re
import select
import sys
import termios
import time

PORT = "/dev/ttyUSB0"
CYCLES = int(sys.argv[1]) if len(sys.argv) > 1 else 3

fd = os.open(PORT, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
a = termios.tcgetattr(fd)
a[0] = 0                                  # iflag raw
a[1] = 0                                  # oflag raw
a[2] = termios.CS8 | termios.CREAD | termios.CLOCAL
a[3] = 0                                  # lflag raw
a[4] = a[5] = termios.B9600
a[6][termios.VMIN] = 0
a[6][termios.VTIME] = 0
termios.tcsetattr(fd, termios.TCSANOW, a)
termios.tcflush(fd, termios.TCIOFLUSH)


def send(data, gap=0.010):
    for b in data:
        os.write(fd, bytes([b]))
        time.sleep(gap)


buf = b""
last = time.monotonic()


def pump(timeout):
    """Read what is there; returns [(t, bytes)]."""
    global last
    r, _, _ = select.select([fd], [], [], timeout)
    if not r:
        return None
    d = os.read(fd, 256)
    t = time.monotonic()
    if d:
        last = t
    return t, d


def wait_for(pattern, limit):
    global buf
    end = time.monotonic() + limit
    while time.monotonic() < end:
        got = pump(0.2)
        if got:
            buf += got[1]
            if pattern in buf:
                return True
    return False


# 1. is it at the prompt?
send(b"\r", 0.0)
if not wait_for(b"A0>", 3):
    print("NO PROMPT: console says", buf[-80:])
    sys.exit(2)
buf = b""
t_cmd = time.monotonic()
send(b"AUTODEMO", 0.010)
send(b"\r", 0.0)
t_cmd = time.monotonic()

banners = []                               # (t, number, name)
line = b""
last = time.monotonic()
need = 7 * CYCLES + 1
while len(banners) < need:
    if time.monotonic() - last > 45:
        print("HUNG: no console output for 45 s after", banners[-1:] or "start")
        sys.exit(3)
    got = pump(0.2)
    if not got:
        continue
    t, d = got
    line += d
    while b"\n" in line:
        l, line = line.split(b"\n", 1)
        m = re.match(rb"\s*(\d)  ([a-z ]+)\r?$", l)
        if m:
            banners.append((t, int(m.group(1)), m.group(2).decode()))

send(b"Q", 0.0)
wait_for(b"A0>", 20)

print("start -> banner 1 (load from disk + GINIT): %.2f s" % (banners[0][0] - t_cmd))
rows = {}
for (t0, n0, _), (t1, n1, _) in zip(banners, banners[1:]):
    rows.setdefault(n0, []).append(t1 - t0)
for n in range(1, 8):
    v = rows.get(n, [])
    print("screen %d: %s  mean %.2f s" % (n, " ".join("%.2f" % x for x in v), sum(v) / len(v)))
tot = [sum(rows[n][c] for n in range(1, 8)) for c in range(CYCLES)]
print("cycle totals: " + " ".join("%.2f" % x for x in tot))
