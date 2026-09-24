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
# Usage: sync_pristine.sh <dest-dir>
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <dest-dir>" >&2
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
cp "$PRISTINE/cadzilla.toml" "$DEST/"
cp "${disks[@]}" "$DEST/"

echo "Synced pristine machine + disk(s) into $DEST:"
printf '  %s\n' "$(basename "$PRISTINE/cadzilla.toml")"
for d in "${disks[@]}"; do
  printf '  %s\n' "$(basename "$d")"
done
