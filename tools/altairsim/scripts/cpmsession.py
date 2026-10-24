#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
"""Build the CP/M side of a CADzilla project headlessly, on its own work/ machine.

This is the build an assistant does over altairsim's MCP server (the
cadzilla-build-* skills), done by a program instead: it starts
`altairsim <project>/work/cadzilla.toml --mcp` as a child process, speaks
its line-delimited JSON-RPC on stdio, and types at CP/M one line per `run`,
waiting for the A0> prompt each time. No person and no assistant is needed.

What it does, by toolchain (the directory above the project):
  asm    R *.* from src/, ASM <N>, LOAD <N>; W <N>.COM, <N>.HEX, <N>.PRN
  m80    R *.* from src/, M80 <N>,<N>=<N>, SUBMIT B:CZLINK <N>; W <N>.COM, <N>.PRN
  rmac   R *.* from src/, SUBMIT <N>; W what <N>.SUB's LINK lines make
         (.COM, or .PRL with [OP]), *.PRN and *.SYM
  z88dk, zcc
         built on the host already (tools/build.sh); R build/<N>.COM onto A:
Stale outputs are ERA'd on A: and deleted from build/ first, so a failed
build can never pull back, or leave behind, an old program.

A project that doesn't fit the default takes an optional, tracked
cpmbuild.conf beside its src/ -- key = value lines, '#' comments:
  name   = CZBASIC                  the program name (default: the one source
                                    in src/, or the rmac project's .SUB)
  submit = CZBBLD                   build with SUBMIT <this> instead
  binary = CZBASIC.COM *.REL        W these back as binary (wildcards allowed)
  text   = *.PRN                    W these back with T
  put    = dxf                      also R every file in these project dirs

CP/M's tools return no exit status, so success is judged from what they
print (M80's "No Fatal error(s)", L80's ?/% lines, ASM and RMAC error
flags, LINK's UNDEFINED SYMBOLS, the CCP's "NAME?") and from every named
binary output arriving in build/. The whole transcript goes to
build/<N>.LOG.

The session ends as every session must (tools/altairsim/README.md, "Ending
a session"): a run with no input until the guest is idle, so the BIOS has
flushed its track buffer, then UNMOUNT both drives; then check_dsk.py checks
every image. work/.lock keeps two builds off one disk. Don't build a project
whose work/ is loaded in another altairsim at the same time (an assistant's
MCP server, say): both would write the same image.

Usage: cpmsession.py build <project-dir> [--name N] [--verbose]
Exit status: 0 built, 1 the build failed, 2 couldn't run at all.
"""
import argparse
import fcntl
import fnmatch
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent
PROMPT = "A0>"
BOOT = 0xFF00


class SetupError(Exception):
    """Couldn't run the build at all (exit 2)."""


class BuildError(Exception):
    """The build ran and failed (exit 1)."""


def find_altairsim():
    """$ALTAIRSIM, then PATH, then ~/altairsim/build/altairsim."""
    env = os.environ.get("ALTAIRSIM")
    if env:
        if os.access(env, os.X_OK):
            return env
        raise SetupError(f"$ALTAIRSIM is {env}, which is not an executable")
    found = shutil.which("altairsim")
    if found:
        return found
    home = Path.home() / "altairsim" / "build" / "altairsim"
    if os.access(home, os.X_OK):
        return str(home)
    raise SetupError("altairsim not found: set $ALTAIRSIM, put it on PATH, "
                     "or build it at ~/altairsim/build/altairsim")


class Session:
    """One altairsim --mcp child process, driven like the MCP tools."""

    def __init__(self, toml, log, verbose=False):
        self.log = log
        self.verbose = verbose
        self.transcript = []          # (step, output) for every guest command
        toml = Path(toml).resolve()
        self.proc = subprocess.Popen(
            [find_altairsim(), str(toml), "--mcp"], cwd=str(toml.parent),
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, bufsize=1)
        self.next_id = 0
        self._rpc("initialize", {"protocolVersion": "2024-11-05", "capabilities": {},
                                 "clientInfo": {"name": "cpmsession", "version": "1"}})
        self._send({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})

    def _send(self, msg):
        try:
            self.proc.stdin.write(json.dumps(msg) + "\n")
            self.proc.stdin.flush()
        except BrokenPipeError:
            raise SetupError("altairsim exited: " + self.proc.stderr.read().strip())

    def _rpc(self, method, params):
        self.next_id += 1
        self._send({"jsonrpc": "2.0", "id": self.next_id, "method": method, "params": params})
        while True:
            line = self.proc.stdout.readline()
            if not line:
                raise SetupError("altairsim exited: " + self.proc.stderr.read().strip())
            reply = json.loads(line)
            if reply.get("id") != self.next_id:
                continue                      # a notification
            if "error" in reply:
                raise SetupError(f"altairsim {method}: {reply['error'].get('message')}")
            return reply["result"]

    def tool(self, name, args):
        result = self._rpc("tools/call", {"name": name, "arguments": args})
        text = "".join(c.get("text", "") for c in result.get("content", []))
        if result.get("isError"):
            raise SetupError(f"altairsim {name} {args}: {text.strip()}")
        return result.get("structuredContent", {}), text

    def monitor(self, command):
        _, text = self.tool("monitor", {"command": command})
        self._note(f"monitor {command}", text)
        return text

    def run(self, timeout_ms, **args):
        sc, _ = self.tool("run", dict(args, timeout_ms=timeout_ms))
        return sc.get("output", ""), sc.get("stopped", "")

    def _note(self, step, output):
        self.transcript.append((step, output))
        with open(self.log, "a", newline="") as f:
            f.write(f"\n===== {step}\n{output}\n")
        if self.verbose:
            print(f"===== {step}\n{output}", flush=True)

    def boot(self):
        out, stopped = self.run(15000, **{"from": BOOT, "until": PROMPT})
        self._note("boot", out)
        if stopped != "match":
            raise SetupError(f"CP/M didn't boot to {PROMPT} (stopped: {stopped})")

    def hostdir(self, path):
        self.monitor(f"SET hb0 HOSTDIR={path}")

    def cmd(self, line, timeout_s=120):
        """Type one CP/M command line and wait for the next A0> prompt."""
        out, stopped = self.run(min(timeout_s * 1000, 600000), input=line + "\r", until=PROMPT)
        deadline = time.monotonic() + timeout_s
        while stopped == "timeout" and time.monotonic() < deadline:
            more, stopped = self.run(min(timeout_s * 1000, 600000), until=PROMPT)
            out += more
        self._note(line, out)
        if stopped != "match":
            self._unstick()
            raise BuildError(f"'{line}' never got back to {PROMPT} (stopped: {stopped}); "
                             f"it ended with: {out.strip()[-200:]!r}")
        return out

    def submit(self, line, timeout_s=600):
        """A SUBMIT: SuperSUB echoes A0> on every line, so wait for idle instead."""
        out, stopped = self.run(min(timeout_s * 1000, 600000), input=line + "\r")
        deadline = time.monotonic() + timeout_s
        # Idle only counts once a further run prints nothing and the prompt is last.
        while time.monotonic() < deadline:
            if stopped == "idle" and out.rstrip().endswith(PROMPT):
                more, stopped = self.run(2000)
                if not more:
                    break
                out += more
                continue
            if stopped not in ("idle", "timeout"):
                break
            if stopped == "idle":
                break                         # waiting for input, not at the prompt
            more, stopped = self.run(min(timeout_s * 1000, 600000))
            out += more
        self._note(line, out)
        if not out.rstrip().endswith(PROMPT):
            self._unstick()
            raise BuildError(f"'{line}' didn't finish at {PROMPT} (stopped: {stopped}); "
                             f"it ended with: {out.strip()[-200:]!r}")
        return out

    def _unstick(self):
        """A program waiting for input (L80's * prompt, say): ^C back to the CCP."""
        out, _ = self.run(5000, input="\u0003", until=PROMPT)
        self._note("^C", out)

    def close(self):
        """Idle (the BIOS flushes its last track), then unmount both drives."""
        if self.proc.poll() is not None:
            return
        try:
            for _ in range(10):
                out, stopped = self.run(5000)
                if stopped == "idle" and not out:
                    break
            self.monitor("UNMOUNT dsk0:drive0")
            self.monitor("UNMOUNT dsk0:drive1")
        finally:
            self.proc.stdin.close()
            try:
                self.proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                self.proc.kill()


# ---- the project and its recipe ----------------------------------------------

def read_conf(path):
    conf = {}
    if path.is_file():
        for n, raw in enumerate(path.read_text().splitlines(), 1):
            line = raw.split("#", 1)[0].strip()
            if not line:
                continue
            if "=" not in line:
                raise SetupError(f"{path}:{n}: expected key = value")
            key, value = (s.strip() for s in line.split("=", 1))
            if key not in ("name", "submit", "binary", "text", "put"):
                raise SetupError(f"{path}:{n}: unknown key '{key}'")
            conf[key] = value
    return conf


def sources(src, ext):
    return sorted(p.stem for p in src.iterdir() if p.suffix == ext and p.is_file())


def program_name(proj, tc, conf):
    if conf.get("name"):
        return conf["name"].upper()
    src = proj / "src"
    if tc in ("z88dk", "zcc"):
        raise SetupError("a z88dk/zcc build needs --name (tools/build.sh passes it)")
    ext = {"asm": ".ASM", "m80": ".MAC", "rmac": ".SUB"}[tc]
    names = sources(src, ext)
    if len(names) == 1:
        return names[0]
    guess = proj.name.upper()
    if guess in names:
        return guess
    raise SetupError(f"can't tell the program in {src} ({' '.join(names) or f'no {ext}'}): "
                     f"add 'name =' to {proj / 'cpmbuild.conf'}")


def link_outputs(sub):
    """The files a .SUB's DRI LINK lines write: LINK OUT=A,B[OP] -> OUT.PRL, LINK A,B -> A.COM."""
    outs = []
    for line in sub.read_text(errors="replace").splitlines():
        m = re.match(r"\s*LINK\s+([^\s\[]+)(\[[^\]]*\])?", line, re.I)
        if not m:
            continue
        first = m.group(1).split(",")[0]
        name = first.split("=")[0] if "=" in first else first
        opts = (m.group(2) or "").upper()
        ext = ".PRL" if re.search(r"\bOP\b", opts.strip("[]").replace(",", " ")) else ".COM"
        outs.append(name.upper() + ext)
    return outs


def recipe(proj, tc, name, conf):
    """(binary outputs, text outputs) to W back, for the toolchain's default build."""
    if tc == "asm":
        binary, text = [f"{name}.COM"], [f"{name}.HEX", f"{name}.PRN"]
    elif tc == "m80":
        binary, text = [f"{name}.COM"], [f"{name}.PRN"]
    elif tc == "rmac":
        sub = proj / "src" / f"{conf.get('submit', name)}.SUB"
        if not sub.is_file():
            raise SetupError(f"no {sub}")
        binary, text = link_outputs(sub) or [f"{name}.COM"], ["*.PRN", "*.SYM"]
    else:
        binary, text = [], []
    if "binary" in conf:
        binary = conf["binary"].upper().split()
    if "text" in conf:
        text = conf["text"].upper().split()
    return binary, text


# What a failed step prints. Every pattern was checked against the real tools
# on the pristine disk; ERA's NO FILE is expected, so ERA output isn't scanned.
ERRORS = [
    (r"Bdos Err.*", "BDOS error"),
    (r"^\s*[A-Z0-9$]{1,8}(\.[A-Z0-9$]{0,3})?\?\s*$", "CP/M doesn't know this command"),
    (r"^\s*\d+ Fatal error\(s\).*", "M80"),
    (r"^\s*[?%].*", "L80/M80/LIB80"),
    (r"\d+ Undefined Global.*", "L80"),
    (r"Unsatisfied external.*", "LIB80"),
    (r"UNDEFINED SYMBOLS.*", "LINK"),
    (r"NO SOURCE FILE.*", "ASM/RMAC"),
    (r"NO (DIRECTORY )?SPACE.*|DISK (FULL|READ ERROR|WRITE ERROR).*", "disk"),
    (r"^[A-Z] ?[0-9A-F]{4}['\"*]?\s.*", "ASM/M80/RMAC error flag"),
    (r"^\s*(ERROR|Error|error)\b.*", "error"),
    (r"can.t open.*|not found.*|No such file.*", "R/W host bridge"),
]


def scan(transcript):
    found = []
    for step, out in transcript:
        if step.startswith(("ERA ", "monitor ", "boot", "^C")):
            continue
        for line in out.replace("\r", "").split("\n"):
            # the command echo itself is not output
            if line.strip() == step or line.startswith(PROMPT):
                continue
            for pattern, what in ERRORS:
                if re.search(pattern, line):
                    found.append(f"  [{what}] {step}: {line.strip()}")
                    break
    return found


def remove_stale(build, patterns):
    for pat in patterns:
        for f in build.iterdir():
            if f.is_file() and fnmatch.fnmatch(f.name.upper(), pat):
                f.unlink()


def check_disks(proj):
    images = sorted((proj / "work").glob("*.DSK"))
    if proj.name == "czgfx" and proj.parent.name == "m80":
        images.append(proj / "libdisk" / "CZGFXLIB.DSK")
    images = [str(p) for p in images if p.exists()]
    r = subprocess.run([sys.executable, str(SCRIPTS / "check_dsk.py"), *images],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise BuildError("a work disk has bad sectors:\n" + r.stdout + r.stderr)


def build(proj, name_arg, verbose):
    proj = proj.resolve()
    tc = proj.parent.name
    if tc not in ("asm", "m80", "rmac", "z88dk", "zcc"):
        raise SetupError(f"{proj} is not under software/<toolchain>/")
    work, src, out = proj / "work", proj / "src", proj / "build"
    if not (work / "cadzilla.toml").is_file():
        raise SetupError(f"no {work / 'cadzilla.toml'} -- run tools/build.sh, which makes it")
    if "pristine" in work.parts:
        raise SetupError("refusing to touch pristine/")
    conf = read_conf(proj / "cpmbuild.conf")
    if name_arg:
        conf["name"] = name_arg
    name = program_name(proj, tc, conf)
    binary, text = recipe(proj, tc, name, conf)
    out.mkdir(exist_ok=True)
    log = out / f"{name}.LOG"
    log.write_text(f"cpmsession.py build {proj}  ({time.strftime('%Y-%m-%d %H:%M:%S')})\n")

    try:
        session = run_build(proj, tc, name, conf, binary, text, log, verbose)
    except BuildError as e:
        e.log = log
        raise
    check_disks(proj)
    errors = scan(session.transcript)
    missing = [p for p in binary if not any(
        fnmatch.fnmatch(f.name.upper(), p) for f in out.iterdir())]
    if errors:
        missing = []                      # not pulled back on purpose
    if errors or missing:
        msg = "\n".join(errors)
        if missing:
            msg += ("\n" if msg else "") + "  no " + ", ".join(missing) + " in build/"
        e = BuildError(msg)
        e.log = log
        raise e
    return name, log


def run_build(proj, tc, name, conf, binary, text, log, verbose):
    """The CP/M session itself; returns it, closed, for its transcript."""
    work, src, out = proj / "work", proj / "src", proj / "build"
    lock = open(work / ".lock", "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        lock.close()
        raise SetupError(f"{work} is being built by another cpmsession.py")

    session = None
    try:
        session = Session(work / "cadzilla.toml", log, verbose)
        session.boot()
        mounts = session.monitor("SHOW MOUNTS")
        if "pristine" in mounts or re.search(r"drive0 .*write-protected", mounts):
            raise SetupError("drive 0 isn't this project's writable work disk:\n" + mounts)

        if tc in ("z88dk", "zcc"):
            session.hostdir(out)
            session.cmd(f"ERA {name}.COM")
            session.cmd(f"R {name}.COM")
        else:
            session.hostdir(src)
            for pat in binary:
                session.cmd(f"ERA {pat}")
            remove_stale(out, binary)
            session.cmd("R *.*", 300)
        for d in conf.get("put", "").split():
            session.hostdir(proj / d)
            session.cmd("R *.*", 300)
        if tc not in ("z88dk", "zcc"):
            if conf.get("put"):
                session.hostdir(src)      # a .SUB may W into src/ (czbasic's CZL does)
            if conf.get("submit"):
                session.submit(f"SUBMIT {conf['submit']}")
            elif tc == "asm":
                session.cmd(f"ASM {name}")
                session.cmd(f"LOAD {name}")
            elif tc == "m80":
                session.cmd(f"M80 {name},{name}={name}")
                session.submit(f"SUBMIT B:CZLINK {name}")
            else:
                session.submit(f"SUBMIT {name}")
            # A failed build's program never leaves CP/M: it is ERA'd there and
            # not pulled back. Its listings are, to show where it failed.
            failed = scan(session.transcript)
            session.hostdir(out)
            for pat in binary:
                session.cmd(f"ERA {pat}" if failed else f"W {pat}")
            for pat in text:
                session.cmd(f"W {pat} T")
        session.cmd("DIR " + (f"{name}.*" if tc in ("z88dk", "zcc") else "*.*"))
    finally:
        if session:
            session.close()
        lock.close()
    return session


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build", help="build a project's CP/M side on its work/ machine")
    b.add_argument("project")
    b.add_argument("--name", help="the program name (z88dk/zcc: the .COM to put on A:)")
    b.add_argument("--verbose", action="store_true", help="echo the CP/M transcript")
    args = ap.parse_args()
    proj = Path(args.project)
    try:
        name, log = build(proj, args.name, args.verbose)
    except SetupError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2
    except BuildError as e:
        print(f"error: the CP/M build of {proj} failed:\n{e}", file=sys.stderr)
        if getattr(e, "log", None):
            print(f"  transcript: {e.log}", file=sys.stderr)
        return 1
    print(f"  {name}: built on {proj / 'work'} (transcript build/{log.name})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
