#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
"""Gather every CADzilla program onto one bootable 8MB CP/M demo disk.

    tools/demodisk.py [--build] [--cpu z80|8080|8085] [--verbose]

It writes demodisk/ at the top of the repo. That directory is gitignored, and
its disk is made again from scratch on every run:
  CADZILLA.DSK        pristine's CP/M 2.2 (62K) system disk (CP/M, DDT, PIP,
                      STAT, the dev tools, R/W) plus every program below and
                      a README.TXT listing them
  cadzilla.toml       a machine that boots it: 1024x768, the --cpu CPU (z80 by
                      default, which runs both the 8080 and the Z80 programs)
  cadzilla-real.toml  the same at 2 MHz, drawing at the board's real speed
  CADZILLA.LOG        the CP/M session that made the disk

    cd demodisk && altairsim cadzilla.toml

What goes on the disk:
  - From every project under software/<toolchain>/ that runs on a machine
    (one with a machine.toml), except the hello examples (*hello):
    - its build/*.COM and *.PRL;
    - the directories its cpmbuild.conf `put`s (dxfview's drawings);
    - its EXTRAS below.
    The libraries (czgfx, cz88gfx) have no machine.toml, so their
    link-check programs are left off.
  - A project is left off, with a warning, when the machine can't run it.
    That is either its CPU (a Z80 or an 8085 also runs 8080 code) or its cad0
    mode (the machine is strapped 1024x768).
  - With the GSX driver (software/rmac/ddcz) come GSX-80 and its test
    programs from the local upstream cache. The GSX clients (GSX_CLIENTS)
    are GENGRAF'd on the disk. Without the cache
    (tools/altairsim/scripts/fetch_upstream.sh) the clients are left off.

A project is first built with tools/build.sh if build/ has no program, or a
file in its src/ or include/ is newer than that program. --build rebuilds
every one.

Don't run this while an altairsim has demodisk/ loaded (an assistant's MCP
server, say): the new disk replaces the one it has mounted.

Exit status: 0 made, 1 a build or the CP/M session failed, 2 usage or setup.
"""
import argparse
import fcntl
import fnmatch
import shutil
import subprocess
import sys
import time
import tomllib
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SCRIPTS = REPO / "tools" / "altairsim" / "scripts"
PRISTINE = REPO / "tools" / "altairsim" / "pristine"
UPSTREAM_GSX = REPO / "tools" / "altairsim" / "upstream" / "GSX"
OUT = REPO / "demodisk"
DISK = "CADZILLA.DSK"
MODE = "1024x768"

sys.dont_write_bytecode = True                      # no __pycache__ in tools/
sys.path.insert(0, str(SCRIPTS))
import cpmsession                                   # noqa: E402
from cpmsession import BuildError, Session, SetupError   # noqa: E402

# Which CPUs' code each machine CPU runs
RUNS = {"z80": {"z80", "8080"}, "8085": {"8085", "8080"}, "8080": {"8080"}}

# Files a project's program needs beside it, relative to the project
EXTRAS = {
    "m80/czbasic": ["src/CZDEMO.BAS", "demos/*.BAS"],
    "rmac/ddcz": ["src/ASSIGN.SYS"],
}
# Projects whose program is a GSX client, to GENGRAF on the disk
GSX_CLIENTS = {"zcc/cgsxdemo"}
# What the GSX driver brings from the upstream cache
GSX_RUNTIME = ["GSX.SYS", "GENGRAF.COM", "GSXTEST.COM", "DEMOGRAF.COM"]

# README.TXT's line for each file; anything else is listed by name alone
DESCRIBE = {
    "FIRSTDRW.COM": "first light: palette, border and a test pattern",
    "DRAWDEMO.COM": "every ACRTC drawing command, a screen each",
    "GFXDEMO.COM": "the czgfx library demo, ten screens",
    "TESTPAT.COM": "board bring-up test patterns, from a menu",
    "CZDIAG.COM": "board diagnostics, PASS/FAIL: CZDIAG ALL (destructive)",
    "CZBASIC.COM": "MBASIC 5.21 compatible BASIC with CZ graphics",
    "CZDEMO.BAS": "CZBASIC CZDEMO: a tour of the CZ statements",
    "STARBRST.BAS": "CZBASIC STARBRST: lines from the centre",
    "XORBAND.BAS": "CZBASIC XORBAND: XOR drawing",
    "SHAPES.BAS": "CZBASIC SHAPES: polygon, PAINT, FLOOD, CZPOINT",
    "PALANIM.BAS": "CZBASIC PALANIM: palette animation",
    "DDCZ1K.PRL": "GSX driver, 1024x768 (ASSIGN.SYS workstation 01)",
    "DDCZ800.PRL": "GSX driver, 800x600 (workstation 02)",
    "DDCZ640.PRL": "GSX driver, 640x480 (workstation 03)",
    "ASSIGN.SYS": "GSX workstation numbers to drivers",
    "Z88DEMO.COM": "GFXDEMO ported to z80asm and cz88gfx",
    "CGFXDEMO.COM": "GFXDEMO in C, pixel-identical",
    "CGSXDEMO.COM": "a GSX-80 client in C, through DDCZ1K",
    "DXFVIEW.COM": "DXF viewer: DXFVIEW SHUTTLE; +- zoom, WASD pan, Q",
    "SHUTTLE.DXF": "the Shuttle stack on the pad, 3D",
    "COLUMBIA.DXF": "the orbiter Columbia, 2D",
    "TEST.DXF": "every entity DXFVIEW handles",
    "GSX.SYS": "GSX-80 1.0 GDOS (DRI)",
    "GENGRAF.COM": "attaches the GSX loader: GENGRAF NAME (DRI)",
    "GSXTEST.COM": "GSX test, a screen per function (John Elliott)",
    "DEMOGRAF.COM": "GSX business-graphics demo (DRI)",
}


def board(toml, id_):
    """The [[board]] table with this id in a machine.toml, or {}."""
    with open(toml, "rb") as f:
        boards = tomllib.load(f).get("board", [])
    return next((b for b in boards if b.get("id") == id_), {})


class Project:
    def __init__(self, path):
        self.path = path
        self.key = f"{path.parent.name}/{path.name}"
        machine = path / "machine.toml"
        self.cpu = board(machine, "cpu0").get("type", "8080").lower()
        self.mode = board(machine, "cad0").get("mode", MODE)
        conf = cpmsession.read_conf(path / "cpmbuild.conf")
        self.puts = conf.get("put", "").split()

    def programs(self):
        build = self.path / "build"
        if not build.is_dir():
            return []
        return sorted(f for f in build.iterdir()
                      if f.is_file() and f.suffix in (".COM", ".PRL"))

    def stale(self):
        progs = self.programs()
        if not progs:
            return True
        built = min(f.stat().st_mtime for f in progs)
        for d in ("src", "include"):
            for f in (self.path / d).rglob("*"):
                if f.is_file() and f.stat().st_mtime > built:
                    return True
        return False

    def files(self):
        """Everything of this project's that goes on the disk."""
        out = self.programs()
        for d in self.puts:
            out += sorted(f for f in (self.path / d).iterdir() if f.is_file())
        for pat in EXTRAS.get(self.key, []):
            out += sorted(self.path.glob(pat))
        return out


def find_projects():
    found = []
    for p in sorted((REPO / "software").glob("*/*")):
        if (p / "machine.toml").is_file() and not p.name.endswith("hello"):
            found.append(Project(p))
    return found


def build_projects(projects, rebuild_all):
    for p in projects:
        if rebuild_all or p.stale():
            r = subprocess.run([str(REPO / "tools" / "build.sh"), str(p.path)])
            if r.returncode != 0:
                raise BuildError(f"tools/build.sh software/{p.key} failed")
            if not p.programs():
                raise BuildError(f"software/{p.key}: still no .COM or .PRL in build/")


def stage(projects, cpu, stagedir):
    """Copy the disk's files into stagedir; returns (sections, gengraf, warnings)."""
    warnings, sections, gengraf, seen = [], [], [], {}
    has_driver = any(p.key == "rmac/ddcz" for p in projects)
    gsx = has_driver and all((UPSTREAM_GSX / f).is_file() for f in GSX_RUNTIME)
    if has_driver and not gsx:
        warnings.append("no GSX-80 in tools/altairsim/upstream/GSX (run "
                        "tools/altairsim/scripts/fetch_upstream.sh): "
                        "GSX clients left off")

    def add(section, f):
        name = f.name.upper()
        if name in seen:
            raise SetupError(f"{name} comes from both {seen[name]} and {f}")
        seen[name] = f
        shutil.copyfile(f, stagedir / name)
        section[1].append(name)

    for p in projects:
        if p.cpu not in RUNS[cpu]:
            warnings.append(f"software/{p.key} left off: it needs a {p.cpu}, "
                            f"the machine is a {cpu}")
            continue
        if p.mode != MODE:
            warnings.append(f"software/{p.key} left off: it draws at {p.mode}, "
                            f"the machine is strapped {MODE}")
            continue
        if p.key in GSX_CLIENTS:
            if not gsx:
                continue
            gengraf += [f.stem for f in p.programs()]
        section = (f"software/{p.key}" + ("" if p.cpu == "8080" else f" ({p.cpu.upper()})"), [])
        for f in p.files():
            add(section, f)
        sections.append(section)
    if gsx:
        section = ("GSX-80 runtime (tools/altairsim/upstream/GSX, local only)", [])
        for f in GSX_RUNTIME:
            add(section, UPSTREAM_GSX / f)
        sections.append(section)
    return sections, gengraf, warnings


def readme(sections, cpu, gengraf):
    lines = [
        "CADzilla demo disk",
        "==================",
        "",
        f"Made {time.strftime('%Y-%m-%d')} by tools/demodisk.py. Every CADzilla",
        "program, on the CP/M 2.2 system disk (DDT, PIP, STAT, the",
        "assemblers and R/W are here too). Its machine is a "
        f"{cpu.upper()} at {MODE}:",
        "    cd demodisk && altairsim cadzilla.toml",
        "    cd demodisk && altairsim cadzilla-real.toml   (2 MHz, real speed)",
        "",
        "The demos step through screens: a key for the next, ESC or ^C quits.",
    ]
    if gengraf:
        lines.append("GENGRAF has been run on " + ", ".join(gengraf) + ".")
    for title, names in sections:
        lines += ["", title]
        for n in names:
            lines.append(f"  {n:<14}{DESCRIBE.get(n, '')}".rstrip())
    text = "\r\n".join(lines) + "\r\n"
    data = text.encode("ascii")
    return data + b"\x1a" * (-len(data) % 128 or 128)


MACHINE = """\
# The CADzilla demo disk's machine, written by tools/demodisk.py (edit that,
# not this). It boots CP/M 2.2 (62K) from {disk} on the CADzilla board at
# {mode}, on a {cpu_name}. It is the pristine machine with this disk alone in
# drive 0, the CPU replaced:
#
#     cd demodisk && altairsim cadzilla.toml         (flat out)
#     cd demodisk && altairsim cadzilla-real.toml    (2 MHz, real drawing speed)

[machine]
name = "cadzilla-demo"
base = "cadzilla"
startup = ["RUN FF00"]

[console]
bsdel = "bs"

[[board]]
id   = "cad0"
mode = "{mode}"

[[board]]
type     = "{cpu}"
id       = "cpu0"
clock_hz = 0

[[board]]
id = "dsk0"

  [[board.drive]]
  unit  = 0
  mount = "{disk}"

[[board]]
type = "memory"
id   = "mem0"
fill = "random"

  [[board.region]]
  type = "ram"
  at   = 0000
  size = "62K"

  [[board.region]]
  type  = "rom"
  at    = FF00
  mount = "builtin:dbl"
"""


def write_machine(d, cpu):
    (d / "cadzilla.toml").write_text(MACHINE.format(
        disk=DISK, mode=MODE, cpu=cpu, cpu_name=cpu.upper()))
    shutil.copyfile(PRISTINE / "cadzilla-real.toml", d / "cadzilla-real.toml")


def close(session):
    """cpmsession's close, for a machine with drive 0 alone."""
    for _ in range(10):
        out, stopped = session.run(5000)
        if stopped == "idle" and not out:
            break
    session.monitor("UNMOUNT dsk0:drive0")


def make_disk(builddir, stagedir, gengraf, log, verbose):
    """The CP/M session: R everything onto a copy of the system disk."""
    shutil.copyfile(PRISTINE / "CPM22SYS.DSK", builddir / DISK)
    (builddir / DISK).chmod(0o644)
    session = Session(builddir / "cadzilla.toml", log, verbose)
    try:
        session.boot()
        mounts = session.monitor("SHOW MOUNTS")
        if "pristine" in mounts or "write-protected" in mounts:
            raise SetupError("drive 0 isn't the new writable demo disk:\n" + mounts)
        session.hostdir(stagedir)
        session.cmd("R *.*", 600)
        for name in gengraf:
            session.cmd(f"GENGRAF {name}")
        session.cmd("DIR")
        close(session)
    finally:
        session.proc.stdin.close()
        try:
            session.proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            session.proc.kill()
    errors = cpmsession.scan(session.transcript)
    if errors:
        raise BuildError("\n".join(errors))
    r = subprocess.run([sys.executable, str(SCRIPTS / "check_dsk.py"), str(builddir / DISK)],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise BuildError("the new disk has bad sectors:\n" + r.stdout + r.stderr)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--build", action="store_true", help="rebuild every project first")
    ap.add_argument("--cpu", choices=sorted(RUNS), default="z80",
                    help="the machine's CPU (default z80)")
    ap.add_argument("--verbose", action="store_true", help="echo the CP/M transcript")
    args = ap.parse_args()

    OUT.mkdir(exist_ok=True)
    lock = open(OUT / ".lock", "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        print("error: another demodisk.py is running", file=sys.stderr)
        return 2
    builddir = OUT / ".build"
    log = OUT / "CADZILLA.LOG"
    try:
        projects = find_projects()
        build_projects(projects, args.build)
        shutil.rmtree(builddir, ignore_errors=True)
        stagedir = builddir / "stage"
        stagedir.mkdir(parents=True)
        sections, gengraf, warnings = stage(projects, args.cpu, stagedir)
        (stagedir / "README.TXT").write_bytes(readme(sections, args.cpu, gengraf))
        write_machine(builddir, args.cpu)
        log.write_text(f"tools/demodisk.py  ({time.strftime('%Y-%m-%d %H:%M:%S')})\n")
        print(f"== demodisk/{DISK}: {sum(len(n) for _, n in sections) + 1} files")
        make_disk(builddir, stagedir, gengraf, log, args.verbose)
        (builddir / DISK).replace(OUT / DISK)
        write_machine(OUT, args.cpu)
        shutil.rmtree(builddir)
    except SetupError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2
    except BuildError as e:
        print(f"error: {e}", file=sys.stderr)
        if log.exists():
            print(f"  transcript: {log.relative_to(REPO)}", file=sys.stderr)
        return 1
    finally:
        lock.close()
    for title, names in sections:
        print(f"  {title}: {' '.join(names)}")
    for w in warnings:
        print(f"  warning: {w}")
    print(f"  boot it: cd demodisk && altairsim cadzilla.toml   ({args.cpu}, {MODE})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
