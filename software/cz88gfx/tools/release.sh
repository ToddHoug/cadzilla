#!/usr/bin/env bash
# Release the cz88gfx library: snapshot the built library and its header,
# software/cz88gfx/build/CZ88GFX.LIB and src/CZ88GFX.INC, as the immutable,
# tracked
#
#     software/cz88gfx/releases/<major>.<minor>/CZ88GFX.LIB
#     software/cz88gfx/releases/<major>.<minor>/CZ88GFX.INC
#
# named by the version in src/CZ88GFX.INC (CZ88VER EQU 0MMNNH: major MM,
# minor NN, both decimal in the name -- 0100H is 1.0, 010AH is 1.10).
#
# Projects pin a release in their software/<project>/cz88gfx.version, and
# tools/z88dk/z88build.sh builds them against it, so a release is never
# changed once made: to release again, raise CZ88VER in CZ88GFX.INC,
# rebuild (tools/build.sh), then run this.
#
# It refuses to:
#   - overwrite an existing release
#   - release a library older than any of its sources (rebuild first)
#
# The release is made read-only on the host. Add it to git yourself:
#     git add software/cz88gfx/releases/<version>
#
# Usage: release.sh
set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
LIBDIR="$REPO_ROOT/software/cz88gfx"
INC="$LIBDIR/src/CZ88GFX.INC"
LIB="$LIBDIR/build/CZ88GFX.LIB"
RELDIR="$LIBDIR/releases"

if [ $# -ne 0 ]; then
  echo "Usage: $0" >&2
  exit 1
fi

# CZ88VER EQU     0MMNNH  ->  MM.NN, decimal
hex="$(sed -nE 's/^CZ88VER[[:space:]]+EQU[[:space:]]+0?([0-9A-Fa-f]{1,4})H.*/\1/p' "$INC" | head -n1)"
if [ -z "$hex" ]; then
  echo "error: no 'CZ88VER EQU ...H' line in $INC" >&2
  exit 1
fi
v=$((16#$hex))
VERSION="$((v >> 8)).$((v & 255))"
RELEASE="$RELDIR/$VERSION"

if [ ! -f "$LIB" ]; then
  echo "error: $LIB not found -- build the library first (tools/build.sh)" >&2
  exit 1
fi
newer="$(find "$LIBDIR/src" -type f -newer "$LIB" | head -n1)"
if [ -n "$newer" ]; then
  echo "error: $newer is newer than the library -- rebuild it first (tools/build.sh)" >&2
  exit 1
fi
if [ -e "$RELEASE" ]; then
  echo "error: release $VERSION already exists ($RELEASE) -- raise CZ88VER in CZ88GFX.INC" >&2
  exit 1
fi

mkdir -p "$RELEASE"
cp "$LIB" "$INC" "$RELEASE/"
chmod a-w "$RELEASE/CZ88GFX.LIB" "$RELEASE/CZ88GFX.INC" "$RELEASE"
REL="$(realpath --relative-to="$REPO_ROOT" "$RELEASE")"
echo "Released cz88gfx $VERSION as $REL/"
echo "  git add $REL"
