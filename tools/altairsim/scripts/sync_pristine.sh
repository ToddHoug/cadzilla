#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Copy the pristine altairsim machine definition and disk images into a
# work directory, creating it if needed.
#
# The disks are copied by role (see tools/altairsim/README.md, "Disk images"):
#   pristine/CPM22SYS.DSK -> <dest-dir>/CPM22SYS.DSK  the A: disk: CP/M 2.2 + tools
#   pristine/EMPTY.DSK    -> <dest-dir>/SCRATCH.DSK   the B: disk: empty scratch
# (an M80 project then points B: at the czgfx library disk instead, with
# attach_libdisk.sh, which also removes the unused SCRATCH.DSK).
#
# Used for two things:
#   - Setting up a new project's own software/<toolchain>/<name>/work/ the first time
#     (each project gets its own persistent CP/M disk, so projects don't
#     share -- and don't fill up -- a single common disk).
#   - Resetting a work directory back to a known-clean state if it ends up
#     corrupted (see "Don't force-interrupt a disk operation in flight" in
#     tools/altairsim/README.md). This discards everything built there
#     since the last sync, so only do it deliberately.
#
# --machine-only copies just the machine files (cadzilla.toml and
# cadzilla-real.toml) and leaves the destination's disks (and everything built
# on them) alone -- for picking up a change to the pristine machine definition
# in an existing work directory.
#
# cadzilla-real.toml is copied as is: it is a delta with base = "cadzilla.toml",
# so in <dest-dir> it builds on the cadzilla.toml beside it (overlay included)
# and only switches the CPU to 2 MHz and cad0 to draw_rate = "real".
#
# Project overlay: if the directory above <dest-dir> holds a machine.toml
# (i.e. software/<toolchain>/<project>/machine.toml, tracked in git), it is appended to
# the copied cadzilla.toml. That is how a project pins its own board straps --
# above all cad0's `mode`, the monitor resolution its code programs -- so they
# survive every sync and a fresh clone. A later [[board]] block for the same
# id overrides the pristine one. The overlay may contain only [[board]]
# tables (and their [[board.x]] / [board.x] sub-tables): anything before its
# first [[board]] would otherwise attach to whatever table pristine ends with.
#
# Usage: sync_pristine.sh [--machine-only] <dest-dir>
set -euo pipefail

MACHINE_ONLY=0
if [ "${1:-}" = "--machine-only" ]; then
  MACHINE_ONLY=1
  shift
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 [--machine-only] <dest-dir>" >&2
  exit 1
fi

DEST="$1"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PRISTINE="$REPO_ROOT/tools/altairsim/pristine"

if [ ! -f "$PRISTINE/cadzilla.toml" ]; then
  echo "error: $PRISTINE/cadzilla.toml not found" >&2
  exit 1
fi

# The templates and the names their work copies get
SYSDSK="$PRISTINE/CPM22SYS.DSK"
EMPTYDSK="$PRISTINE/EMPTY.DSK"
for t in "$SYSDSK" "$EMPTYDSK"; do
  if [ ! -f "$t" ]; then
    echo "error: $t not found" >&2
    exit 1
  fi
done
disks=("$SYSDSK" "$EMPTYDSK")
copies=("CPM22SYS.DSK" "SCRATCH.DSK")

mkdir -p "$DEST"
if [ "$(cd "$DEST" && pwd -P)" = "$(cd "$PRISTINE" && pwd -P)" ]; then
  echo "error: $DEST is the pristine directory itself -- pick a work/ directory" >&2
  exit 1
fi

# Pristine is never written: keep it read-only on the host so altairsim can
# only ever mount it WRITE-PROTECTED if something points at it by mistake.
# Git doesn't track write permission, so re-assert it on every sync.
machines=("$PRISTINE/cadzilla.toml")
[ -f "$PRISTINE/cadzilla-real.toml" ] && machines+=("$PRISTINE/cadzilla-real.toml")
chmod a-w "${machines[@]}" "${disks[@]}"

OVERLAY="$(cd "$DEST/.." && pwd -P)/machine.toml"
if [ -f "$OVERLAY" ]; then
  first="$(grep -vE '^[[:space:]]*(#|$)' "$OVERLAY" | head -n1 || true)"
  if [ -n "$first" ] && ! printf '%s\n' "$first" | grep -qE '^[[:space:]]*\[\[board\]\][[:space:]]*(#.*)?$'; then
    echo "error: $OVERLAY must start with a [[board]] table (found: $first)" >&2
    exit 1
  fi
  bad="$(grep -E '^[[:space:]]*\[' "$OVERLAY" \
         | grep -vE '^[[:space:]]*(\[\[board(\.[A-Za-z_]+)?\]\]|\[board\.[A-Za-z_.]+\])[[:space:]]*(#.*)?$' \
         | head -n1 || true)"
  if [ -n "$bad" ]; then
    echo "error: $OVERLAY may only contain [[board]] tables and their sub-tables (found: $bad)" >&2
    exit 1
  fi
fi

# cp carries the read-only mode over to new files -- the work copies are
# meant to be written, so make them writable again.
cp -f "${machines[@]}" "$DEST/"
for m in "${machines[@]}"; do
  chmod u+w "$DEST/$(basename "$m")"
done
if [ -f "$OVERLAY" ]; then
  {
    printf '\n# ==== project overlay: %s ====\n' "$(realpath --relative-to="$REPO_ROOT" "$OVERLAY")"
    printf '# (appended by tools/altairsim/scripts/sync_pristine.sh -- edit that file, not this copy)\n\n'
    cat "$OVERLAY"
  } >> "$DEST/cadzilla.toml"
fi
if [ "$MACHINE_ONLY" -eq 1 ]; then
  echo "Synced pristine machine (disks untouched) into $DEST:"
  printf '  %s\n' "$(basename "$PRISTINE/cadzilla.toml")"
  [ -f "$OVERLAY" ] && printf '  + overlay %s\n' "$(realpath --relative-to="$REPO_ROOT" "$OVERLAY")"
  for m in "${machines[@]:1}"; do printf '  %s\n' "$(basename "$m")"; done
  exit 0
fi

for i in "${!disks[@]}"; do
  cp -f "${disks[$i]}" "$DEST/${copies[$i]}"
  chmod u+w "$DEST/${copies[$i]}"
done

echo "Synced pristine machine + disk(s) into $DEST:"
printf '  %s\n' "$(basename "$PRISTINE/cadzilla.toml")"
[ -f "$OVERLAY" ] && printf '  + overlay %s\n' "$(realpath --relative-to="$REPO_ROOT" "$OVERLAY")"
for m in "${machines[@]:1}"; do printf '  %s\n' "$(basename "$m")"; done
for i in "${!disks[@]}"; do
  printf '  %s (from %s)\n' "${copies[$i]}" "$(basename "${disks[$i]}")"
done
