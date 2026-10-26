---
name: cadzilla-demo-disk
description: Gathers every CADzilla program -- the drawing demos and examples from all the software projects (firstdraw, drawdemo, gfxdemo, testpat, czbasic and its .BAS demos, the ddcz GSX drivers with the GSX-80 runtime, z88demo, cgfxdemo, cgsxdemo, dxfview and its drawings), but not the hello examples or the libraries' link checks -- onto one bootable 8MB CP/M 2.2 disk image, demodisk/CADZILLA.DSK, with a machine that boots it (Z80 by default, 1024x768), by running tools/demodisk.py, which first rebuilds any project whose program is missing or out of date. The image is gitignored and made again from scratch every run. Use this whenever the user wants a demo disk, a debug disk, all the programs on one disk, to show off or try every program, to refresh/regather/rebuild the demo disk, or to boot or run something from it. To build or debug one project on its own work/ disk, use that project's cadzilla-build-* skill instead.
---

# The CADzilla demo disk

`tools/demodisk.py` puts every CADzilla program on one bootable 8MB CP/M
disk, so they can all be run, shown or debugged from one machine. It writes
`demodisk/` at the top of the repo. The directory is gitignored, and the disk
is made again from scratch on every run, so it is never edited by hand.

| File | What |
|---|---|
| `CADZILLA.DSK` | pristine's 62K CP/M 2.2 system disk (DDT, PIP, STAT, the assemblers, R/W), plus every program and a `README.TXT` listing them |
| `cadzilla.toml` | the machine that boots it: drive 0 alone, 1024x768, the `--cpu` CPU (Z80 by default), flat out |
| `cadzilla-real.toml` | the same at 2 MHz, drawing at the board's real speed: for watching the demos |
| `CADZILLA.LOG` | the CP/M session that made the disk |

## What goes on it

The script finds this itself; nothing needs to be listed by hand when a
project is added.
- **Included:** every `software/<toolchain>/<name>/` with a `machine.toml`.
  It brings:
  - its `build/*.COM` and `*.PRL`;
  - what its `cpmbuild.conf` `put`s (dxfview's `dxf/`);
  - its `EXTRAS` in the script (czbasic's `.BAS` demos, ddcz's `ASSIGN.SYS`).
- **Left off:**
  - the hello examples (`*hello`);
  - the libraries (czgfx, cz88gfx), which have no `machine.toml`, so their
    link-check programs too;
  - a project the machine can't run, with a warning: its `cpu0` (a Z80 or
    8085 machine also runs 8080 code) or its cad0 `mode` (the disk's machine
    is 1024x768).
- **GSX:**
  - With ddcz come `GSX.SYS`, `GENGRAF.COM`, `GSXTEST.COM` and
    `DEMOGRAF.COM` from `tools/altairsim/upstream/GSX/`.
  - The GSX clients (`GSX_CLIENTS`: cgsxdemo) are `GENGRAF`'d on the disk.
  - Without the upstream cache, the clients are left off with a warning;
    `tools/altairsim/scripts/fetch_upstream.sh` fetches it.
  - The cache is local only (its licence is unsettled), which is one reason
    the image is never tracked.

A new program needing more than its `.COM` on the disk gets an `EXTRAS`
entry. A new GSX client gets a `GSX_CLIENTS` entry. A `DESCRIBE` line gives
it a description in `README.TXT`.

## Make it

1. **Check nothing has the disks loaded.** The script may rebuild projects,
   which writes their `work/` disks, and it replaces `demodisk/CADZILLA.DSK`.
   Run `monitor {command: "SHOW MOUNTS"}`. If a project's `work/` or
   `demodisk/` is mounted, close that session out first (below).
2. Run:

   ```bash
   tools/demodisk.py              # rebuild only what's out of date
   tools/demodisk.py --build      # rebuild every project first
   tools/demodisk.py --cpu 8080   # an 8080 machine (Z80 programs left off)
   ```

   - A project is rebuilt with `tools/build.sh` if `build/` has no program,
     or a file in its `src/` or `include/` is newer than it.
   - The whole run takes about two minutes with six rebuilds, and seconds
     without.
   - `--verbose` echoes the CP/M session.
3. Read what it prints:
   - each project and the files it put on the disk;
   - any **warnings**, about a project left off or a missing GSX cache.
     Pass these on to the user.
   - Exit 0 means the disk was made and its sectors checked.
   - Exit 1 means a build or the CP/M session failed. The error lines
     follow; the session is in `demodisk/CADZILLA.LOG`, a project build's
     in its `build/<NAME>.LOG`. The old disk is kept: the new one is made in
     `demodisk/.build/` and moved into place only when it is good.
   - Exit 2 is a setup error.

## Boot it

A person runs:

```
cd demodisk && altairsim cadzilla.toml         # or cadzilla-real.toml
A0>TYPE README.TXT
```

Over MCP:
- `monitor {command: "CONFIG LOAD <repo>/demodisk/cadzilla.toml"}`
- `run {from: 0xFF00, until: "A0>"}`
- type the program, e.g. `run {input: "DXFVIEW TEST\r", timeout_ms: 60000}`.

To check a picture, `snapshot` it and render it with
`tools/altairsim/scripts/cadzilla_png.py <snap> <out.png>`.

Running programs writes to the image, as on any CP/M disk. That's fine: the
next `tools/demodisk.py` makes it again.

**Close the session out** when done. Get back to `A0>`, `run` with no input
until it is idle, then `monitor {command: "UNMOUNT dsk0:drive0"}`. Unmounting
while the BIOS is still flushing leaves a bad sector;
`tools/altairsim/scripts/check_dsk.py demodisk/CADZILLA.DSK` finds one.
