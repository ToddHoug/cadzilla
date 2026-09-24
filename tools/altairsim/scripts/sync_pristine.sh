#!/usr/bin/env bash
# Copy the pristine altairsim machine definition and disk image(s) into a
# work directory, creating it if needed.
#
# Used for two things:
#   - Setting up a new project's own software/<name>/work/ the first time
#     (each project gets its own persistent CP/M disk, so projects don't
#     share -- and don't fill up -- a single common disk).
#   - Resetting a work directory back to a known-clean state if it ends up
#     corrupted (see "Don't force-interrupt a disk operation in flight" in
#     tools/altairsim/README.md). This discards everything built there
#     since the last sync, so only do it deliberately.
#
# --machine-only copies just cadzilla.toml and leaves the destination's
# disks (and everything built on them) alone -- for picking up a change to
# the pristine machine definition in an existing work directory.
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

shopt -s nullglob
disks=("$PRISTINE"/*.DSK "$PRISTINE"/*.dsk "$PRISTINE"/*.img "$PRISTINE"/*.imd)
if [ ${#disks[@]} -eq 0 ]; then
  echo "error: no disk images found in $PRISTINE" >&2
  exit 1
fi

mkdir -p "$DEST"
if [ "$(cd "$DEST" && pwd -P)" = "$(cd "$PRISTINE" && pwd -P)" ]; then
  echo "error: $DEST is the pristine directory itself -- pick a work/ directory" >&2
  exit 1
fi

# Pristine is never written: keep it read-only on the host so altairsim can
# only ever mount it WRITE-PROTECTED if something points at it by mistake.
# Git doesn't track write permission, so re-assert it on every sync.
chmod a-w "$PRISTINE/cadzilla.toml" "${disks[@]}"

# cp carries the read-only mode over to new files -- the work copies are
# meant to be written, so make them writable again.
cp -f "$PRISTINE/cadzilla.toml" "$DEST/"
chmod u+w "$DEST/cadzilla.toml"
if [ "$MACHINE_ONLY" -eq 1 ]; then
  echo "Synced pristine machine (disks untouched) into $DEST:"
  printf '  %s\n' "$(basename "$PRISTINE/cadzilla.toml")"
  exit 0
fi

cp -f "${disks[@]}" "$DEST/"
for d in "${disks[@]}"; do
  chmod u+w "$DEST/$(basename "$d")"
done

echo "Synced pristine machine + disk(s) into $DEST:"
printf '  %s\n' "$(basename "$PRISTINE/cadzilla.toml")"
for d in "${disks[@]}"; do
  printf '  %s\n' "$(basename "$d")"
done
