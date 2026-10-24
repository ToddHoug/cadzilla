#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Build one CADzilla software project, with no assistant and no typing at
# CP/M: its work/ machine and disks, its program, and the program on its disk.
#
#     tools/build.sh [--clean] [--verbose] <project-dir>
#
# <project-dir> is software/<toolchain>/<name>, or any path inside it (".", or
# its work/). Every project also has a build.sh of its own that runs this on
# itself, so `software/asm/hello/build.sh` works too.
#
# 1. The work/ machine (tools/altairsim/README.md, "Working on a project"):
#    - no work/ yet: sync_pristine.sh makes it -- the machine with the
#      project's machine.toml overlay, its own CP/M disk, a scratch disk;
#    - work/ already there: its disks are kept (they hold what was built on
#      them). Only the machine files are refreshed, with
#      sync_pristine.sh --machine-only, when machine.toml or pristine's
#      machine is newer than work/cadzilla.toml;
#    - a project pinning czgfx (czgfx.version) gets its pinned release as B:
#      from attach_libdisk.sh; czgfx itself gets its writable build disk;
#    - --clean re-syncs work/ from pristine first. That throws away
#      everything on the project's disks, so it is never the default.
# 2. z88dk and zcc projects are built on the host: tools/z88dk/z88build.sh or
#    zccbuild.sh. software/z88dk/cz88gfx, a host-built library with no disk,
#    runs its own tools/build.sh and stops there.
# 3. The CP/M side, by tools/altairsim/scripts/cpmsession.py, which drives
#    altairsim headlessly: ASM/M80/RMAC projects are assembled and linked in
#    CP/M on the project's disk and their outputs pulled back into build/; a
#    z88dk/zcc .COM is put on the disk. Either way the program ends up on A:,
#    so after a build
#        cd software/<toolchain>/<name>/work && altairsim cadzilla.toml
#    boots to A0> with it ready to run.
#
# CP/M sources (.ASM .MAC .INC .SUB in src/) with LF-only lines get CP/M's
# CR/LF first (crlf.sh): an LF-only source assembles to nothing, silently.
#
# Don't build a project whose work/ is loaded in another altairsim -- an
# assistant's MCP server, say. Both would write the same disk image.
#
# Exit status: 0 built, 1 failed, 2 usage or setup error.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SCRIPTS="$REPO_ROOT/tools/altairsim/scripts"

usage() {
  echo "Usage: $0 [--clean] [--verbose] <project-dir>" >&2
  exit 2
}

CLEAN=0
VERBOSE=()
ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --clean) CLEAN=1 ;;
    --verbose) VERBOSE=(--verbose) ;;
    -h|--help) sed -n '5,40p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) usage ;;
    *) [ -z "$ARG" ] || usage; ARG="$1" ;;
  esac
  shift
done
[ -n "$ARG" ] || usage

# The project: software/<toolchain>/<name>, found from any path inside it.
dir="$(cd "$ARG" 2>/dev/null && pwd -P)" || { echo "error: no directory $ARG" >&2; exit 2; }
PROJ=""
while [ "$dir" != "/" ]; do
  if [ "$(dirname "$(dirname "$dir")")" = "$REPO_ROOT/software" ]; then
    PROJ="$dir"
    break
  fi
  dir="$(dirname "$dir")"
done
if [ -z "$PROJ" ]; then
  echo "error: $ARG is not inside a project, software/<toolchain>/<name>/" >&2
  exit 2
fi
TC="$(basename "$(dirname "$PROJ")")"
REL="${PROJ#"$REPO_ROOT"/}"
case "$TC" in
  asm|m80|rmac|z88dk|zcc) ;;
  *) echo "error: $REL: unknown toolchain directory '$TC'" >&2; exit 2 ;;
esac

# sync_pristine.sh and attach_libdisk.sh find the repo from the current directory.
cd "$REPO_ROOT"
echo "== $REL"

# cz88gfx: a host-built library, no CP/M disk of its own.
if [ "$REL" = "software/z88dk/cz88gfx" ]; then
  exec software/z88dk/cz88gfx/tools/build.sh
fi

# 1. The work/ machine and its disks.
WORK="$PROJ/work"
TOML="$WORK/cadzilla.toml"
PRISTINE="$REPO_ROOT/tools/altairsim/pristine"
if [ "$CLEAN" -eq 1 ] || [ ! -f "$TOML" ]; then
  "$SCRIPTS/sync_pristine.sh" "$WORK" | sed 's/^/  /'
elif [ "$PROJ/machine.toml" -nt "$TOML" ] || [ "$PRISTINE/cadzilla.toml" -nt "$TOML" ] \
     || [ "$PRISTINE/cadzilla-real.toml" -nt "$WORK/cadzilla-real.toml" ]; then
  "$SCRIPTS/sync_pristine.sh" --machine-only "$WORK" | sed 's/^/  /'
fi
if [ "$REL" = "software/m80/czgfx" ]; then
  "$SCRIPTS/attach_libdisk.sh" --writable "$WORK" | sed 's/^/  /'
elif [ -f "$PROJ/czgfx.version" ]; then
  "$SCRIPTS/attach_libdisk.sh" "$WORK" | sed 's/^/  /'
fi

# 2. The host build (z88dk, zcc), which names the .COM to put on the disk.
NAME=()
case "$TC" in
  z88dk|zcc)
    script="$REPO_ROOT/tools/z88dk/z88build.sh"
    [ "$TC" = zcc ] && script="$REPO_ROOT/tools/z88dk/zccbuild.sh"
    out="$("$script" "$PROJ" 2>&1)" || { printf '%s\n' "$out" >&2; exit 1; }
    printf '%s\n' "$out" | sed 's/^/  /'
    com="$(printf '%s\n' "$out" | sed -n 's|^  build/\([A-Z0-9]*\)\.COM .*|\1|p' | head -n1)"
    if [ -z "$com" ]; then
      echo "error: $(basename "$script") didn't say which .COM it built" >&2
      exit 1
    fi
    NAME=(--name "$com")
    ;;
  *)
    shopt -s nullglob
    for f in "$PROJ"/src/*.ASM "$PROJ"/src/*.MAC "$PROJ"/src/*.INC "$PROJ"/src/*.SUB; do
      if grep -qv $'\r$' "$f"; then
        "$SCRIPTS/crlf.sh" "$f"
        echo "  gave ${f#"$REPO_ROOT"/} CR/LF line endings"
      fi
    done
    shopt -u nullglob
    ;;
esac

# 3. The CP/M side.
python3 "$SCRIPTS/cpmsession.py" build "$PROJ" "${NAME[@]}" "${VERBOSE[@]}"
