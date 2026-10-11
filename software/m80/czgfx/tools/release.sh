#!/usr/bin/env bash
# Release the czgfx library: snapshot the built library disk,
# software/m80/czgfx/libdisk/CZGFXLIB.DSK, as the immutable, tracked
#
#     software/m80/czgfx/releases/CZGFXLIB-<major>.<minor>.DSK
#
# named by the version in src/CZGFX.INC (CZVERS EQU 0MMNNH: major MM,
# minor NN, both decimal in the name -- 0100H is 1.0, 010AH is 1.10).
#
# Projects pin a release in their software/<toolchain>/<project>/czgfx.version and
# build against their own copy of it (tools/altairsim/scripts/
# attach_libdisk.sh), so a release is never changed once made: to release
# again, raise CZVERS in CZGFX.INC, rebuild the library (cadzilla-build-m80,
# SUBMIT CZBUILD on czgfx's own machine), then run this.
#
# It refuses to:
#   - overwrite an existing release
#   - release a library disk older than any of its sources (rebuild first)
#
# The release is made read-only on the host. Add it to git yourself:
#     git add software/m80/czgfx/releases/CZGFXLIB-<version>.DSK
#
# Usage: release.sh
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CZGFX="$REPO_ROOT/software/m80/czgfx"
INC="$CZGFX/src/CZGFX.INC"
LIBDISK="$CZGFX/libdisk/CZGFXLIB.DSK"
RELDIR="$CZGFX/releases"

if [ $# -ne 0 ]; then
  echo "Usage: $0" >&2
  exit 1
fi

# CZVERS  EQU     0MMNNH  ->  MM.NN, decimal
hex="$(tr -d '\r' < "$INC" | sed -nE 's/^CZVERS[[:space:]]+EQU[[:space:]]+0?([0-9A-Fa-f]{1,4})H.*/\1/p' | head -n1)"
if [ -z "$hex" ]; then
  echo "error: no 'CZVERS EQU ...H' line in $INC" >&2
  exit 1
fi
v=$((16#$hex))
VERSION="$((v >> 8)).$((v & 255))"
RELEASE="$RELDIR/CZGFXLIB-$VERSION.DSK"

if [ ! -f "$LIBDISK" ]; then
  echo "error: $LIBDISK not found -- build the library first (SUBMIT CZBUILD)" >&2
  exit 1
fi
newer="$(find "$CZGFX/src" -type f -newer "$LIBDISK" | head -n1)"
if [ -n "$newer" ]; then
  echo "error: $newer is newer than the library disk -- rebuild the library first" >&2
  exit 1
fi
if [ -e "$RELEASE" ]; then
  echo "error: release $VERSION already exists ($RELEASE) -- raise CZVERS in CZGFX.INC" >&2
  exit 1
fi

mkdir -p "$RELDIR"
cp "$LIBDISK" "$RELEASE"
chmod a-w "$RELEASE"
echo "Released czgfx $VERSION as $(realpath --relative-to="$REPO_ROOT" "$RELEASE")"
echo "  git add $(realpath --relative-to="$REPO_ROOT" "$RELEASE")"
