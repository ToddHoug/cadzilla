#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Set up a fresh clone of CADzilla: check what the software needs, then build
# every project under software/ -- its work/ machine and disks, and its
# program -- with tools/build.sh.
#
#     tools/setup.sh [--check] [--clean] [--with-gsx] [--verbose]
#
#   --check     check the dependencies only; build nothing
#   --clean     re-sync every work/ from pristine first, throwing away what
#               was built on the project disks (tools/build.sh --clean)
#   --with-gsx  also fetch the GSX-80 runtime and the other upstream archives
#               into tools/altairsim/upstream/ (fetch_upstream.sh), for running
#               GSX programs; building never needs them
#   --verbose   echo every CP/M session
#
# Nothing is installed: a missing dependency is reported with how to get it.
# Without z88dk, the z88dk and zcc projects are skipped and the rest built.
# Running it again is safe and quick to reason about: a work/ that exists
# keeps its disks, and each program is rebuilt onto them.
#
# Afterwards, any project runs by hand from its work/:
#     cd software/asm/hello/work && altairsim cadzilla.toml
#
# Exit status: 0 all good, 1 a build failed, 2 a required dependency is missing.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$REPO_ROOT"

CHECK_ONLY=0
GSX=0
PASS=()
for a in "$@"; do
  case "$a" in
    --check) CHECK_ONLY=1 ;;
    --clean) PASS+=(--clean) ;;
    --verbose) PASS+=(--verbose) ;;
    --with-gsx) GSX=1 ;;
    -h|--help) sed -n '5,27p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Usage: $0 [--check] [--clean] [--with-gsx] [--verbose]" >&2; exit 2 ;;
  esac
done

# ---- dependencies --------------------------------------------------------------

MISSING=0
ok()   { printf '  %-10s ok       %s\n' "$1" "$2"; }
miss() { printf '  %-10s MISSING  %s\n' "$1" "$2"; MISSING=1; }
opt()  { printf '  %-10s optional %s\n' "$1" "$2"; }

echo "Checking dependencies"

if [ "${BASH_VERSINFO[0]}" -gt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -ge 4 ]; }; then
  ok bash "$BASH_VERSION"
else
  miss bash "$BASH_VERSION is too old: 4.4 or later"
fi

if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys; sys.exit(sys.version_info < (3, 8))'; then
  ok python3 "$(python3 -c 'import platform; print(platform.python_version())')"
else
  miss python3 "3.8 or later, e.g. sudo apt install python3"
fi

if realpath --relative-to=/ / >/dev/null 2>&1; then
  ok coreutils "GNU realpath"
else
  miss coreutils "GNU coreutils (realpath --relative-to)"
fi

# altairsim: the same search as cpmsession.py
ALTAIRSIM_BIN="${ALTAIRSIM:-}"
[ -n "$ALTAIRSIM_BIN" ] || ALTAIRSIM_BIN="$(command -v altairsim || true)"
[ -n "$ALTAIRSIM_BIN" ] || ALTAIRSIM_BIN="$HOME/altairsim/build/altairsim"
if [ -x "$ALTAIRSIM_BIN" ]; then
  # cadzilla-real.toml needs cad0's draw_rate strap; an older binary lacks it.
  if "$ALTAIRSIM_BIN" -m cadzilla --set "cad0 draw_rate=real" -x QUIT >/dev/null 2>&1; then
    ok altairsim "$("$ALTAIRSIM_BIN" --version | head -n1)  ($ALTAIRSIM_BIN)"
  else
    miss altairsim "$ALTAIRSIM_BIN is too old (no cadzilla board with draw_rate): rebuild it"
  fi
  # The CADzilla video window needs an altairsim built with SDL3 and a real
  # windowing backend (X11/Wayland). Without one it builds headless: every
  # build here still works, but a program's graphics are never shown.
  # SHOW VERSION's video row says which (altairsim's docs/devguide/building.md).
  video="$("$ALTAIRSIM_BIN" -n -x 'SHOW VERSION' 2>/dev/null | sed -n 's/^[[:space:]]*video[[:space:]]*//p')"
  case "$video" in
    *windowed*)
      ok video "$video"
      if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
        opt video "no DISPLAY or WAYLAND_DISPLAY here (ssh?): the window opens only in a desktop session"
      fi
      ;;
    *)
      printf '  %-10s warning  %s\n' video "${video:-unknown} -- builds work, but no graphics window. Build SDL3 with altairsim's tools/build-sdl3-static.sh (needs the X11/Wayland dev packages in its docs/building-linux.md), then rebuild altairsim with -DCMAKE_PREFIX_PATH=\$HOME/opt/sdl3-static; README.md, \"Getting started\", has the steps"
      ;;
  esac
else
  miss altairsim "not found: build it at ~/altairsim/build/altairsim, put it on PATH, or set \$ALTAIRSIM"
fi

# z88dk: the same lookups the z88dk build scripts use
Z88DK=1
# shellcheck source=z88dk/z88common.sh
if ( . tools/z88dk/z88common.sh; find_z80asm; find_zcc; check_snap_path "$REPO_ROOT" ) 2>/dev/null; then
  ok z88dk "$( . tools/z88dk/z88common.sh; find_z80asm; command -v "$Z80ASM")"
else
  Z88DK=0
  why="$( ( . tools/z88dk/z88common.sh; find_z80asm; find_zcc; check_snap_path "$REPO_ROOT" ) 2>&1 | head -n1 || true)"
  printf '  %-10s skipped  %s\n' z88dk "${why#error: } -- sudo snap install z88dk --edge; the z88dk and zcc projects won't be built"
fi

if [ -d tools/altairsim/upstream/GSX ]; then
  ok gsx "tools/altairsim/upstream/ (fetch_upstream.sh)"
else
  opt gsx "the GSX-80 runtime, to run GSX programs: tools/setup.sh --with-gsx"
fi
if [ -e "$HOME/Applications/ODAFileConverter.AppImage" ]; then
  ok oda "ODA File Converter (dxfview's tools/dwg2dxf.sh)"
else
  opt oda "ODA File Converter, only for converting new DWGs for dxfview"
fi

if [ "$MISSING" -ne 0 ]; then
  echo "Install what is MISSING above, then run $0 again." >&2
  exit 2
fi
[ "$CHECK_ONLY" -eq 1 ] && exit 0

if [ "$GSX" -eq 1 ]; then
  echo
  tools/altairsim/scripts/fetch_upstream.sh
fi

# ---- build -------------------------------------------------------------------

# The libraries first: cz88gfx, then czgfx (whose build disk only czgfx's own
# work/ and a `dev` pin use -- the other projects build against releases).
PROJECTS=()
[ -d software/z88dk/cz88gfx ] && PROJECTS+=(software/z88dk/cz88gfx)
[ -d software/m80/czgfx ] && PROJECTS+=(software/m80/czgfx)
for p in software/*/*/; do
  p="${p%/}"
  case "$p" in software/z88dk/cz88gfx|software/m80/czgfx) continue ;; esac
  [ -d "$p/src" ] && PROJECTS+=("$p")
done

RESULTS=()
FAILED=0
for p in "${PROJECTS[@]}"; do
  echo
  case "$p" in
    software/z88dk/*|software/zcc/*)
      if [ "$Z88DK" -eq 0 ]; then
        echo "== $p: skipped (no z88dk)"
        RESULTS+=("skipped  $p")
        continue
      fi
      ;;
  esac
  start=$SECONDS
  if tools/build.sh "${PASS[@]}" "$p"; then
    RESULTS+=("built    $p  ($((SECONDS - start))s)")
  else
    RESULTS+=("FAILED   $p  (see $p/build/*.LOG)")
    FAILED=1
  fi
done

echo
echo "Summary"
printf '  %s\n' "${RESULTS[@]}"
echo
cat <<'EOF'
Each project's program is on its own CP/M disk. To run one by hand:
    cd software/asm/hello/work && altairsim cadzilla.toml
    A0>HELLO
Ctrl-E stops the machine and gives you the altairsim> monitor (RUN carries
on); QUIT leaves. Wait at A0> a moment before Ctrl-E: the BIOS writes its
last disk track only then. Rebuild one project with its own build.sh, e.g.
software/m80/gfxdemo/build.sh.
EOF
exit "$FAILED"
