#!/usr/bin/env bash
# Build the cz88gfx library on the host with z88dk's z80asm:
#
#     software/z88dk/cz88gfx/src/CZ*.Z88  ->  software/z88dk/cz88gfx/build/CZ88GFX.LIB
#
# then check it the way czgfx's CZBUILD.SUB does (LIB80 /U and the CZCHK
# link): src/CZ88CHK.Z88, which expands every macro in CZ88GFX.INC and
# references every entry point, is linked against the new library for the
# 8080, 8085 and Z80. So is src/czcchk.c, which calls every C entry point in
# src/cz88gfx.h (the CZC*.Z88 modules), compiled by zcc. A broken macro, a
# wrong prototype or a missing PUBLIC fails here, not in the first project
# that uses it.
#
# The library is 8080 code (Intel mnemonics, assembled -m8080), which
# z80asm links unchanged into an 8080, 8085 or Z80 program.
#
# Writes into build/ (gitignored), uppercase like every build artifact:
#   CZ88GFX.LIB              the library (what a release snapshots)
#   CZ*.O, CZ*.LIS           per-module objects and listings
#   CHK8080.COM/.MAP, CHK8085..., CHKZ80...   the link check, per CPU
#   CCHK8080.COM/.MAP, CCHK8085..., CCHKZ80...  the C check, per CPU
#
# A project pinned to "dev" (cz88gfx.version) links this build directly;
# tools/release.sh snapshots it as a numbered release.
#
# Usage: build.sh
set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
# shellcheck source=../../../../tools/z88dk/z88common.sh
. "$REPO_ROOT/tools/z88dk/z88common.sh"

if [ $# -ne 0 ]; then
  echo "Usage: $0" >&2
  exit 1
fi

LIBDIR="$(cd "$REPO_ROOT/software/z88dk/cz88gfx" && pwd -P)"
SRC="$LIBDIR/src"
BUILD="$LIBDIR/build"
mkdir -p "$BUILD"

find_z80asm
check_snap_path "$LIBDIR"

# The library modules: every .Z88 but the check program (the one with an ORG).
shopt -s nullglob
MODS=()
for f in "$SRC"/*.Z88; do
  grep -qiE '^[^;]*[[:space:]]ORG[[:space:]]' "$f" || MODS+=("$(basename "$f")")
done
shopt -u nullglob
[ ${#MODS[@]} -gt 0 ] || { echo "error: no library modules in $SRC" >&2; exit 1; }

for f in "${MODS[@]}" CZ88CHK.Z88; do lint_jp_cp "$SRC/$f"; done

# Start clean, so a failed build can't leave an old library looking current.
find "$BUILD" -maxdepth 1 -type f ! -name .gitkeep \
  \( -name '*.o' -o -name '*.O' -o -name '*.lis' -o -name '*.LIS' \
     -o -name '*.map' -o -name '*.MAP' -o -name '*.COM' -o -name '*.LIB' \) -delete

uppercase() {
  local f
  for f in "$BUILD"/*.o "$BUILD"/*.lis "$BUILD"/*.map; do
    [ -e "$f" ] || continue
    local base="${f%.*}" ext="${f##*.}"
    mv -f "$f" "$base.${ext^^}"
  done
}

echo "cz88gfx: ${#MODS[@]} modules -> build/CZ88GFX.LIB (8080 code)"
RC=0
OUT="$(
  cd "$SRC"
  "$Z80ASM" -m8080 -I"$SRC" -O"$BUILD" -l -x="$BUILD/CZ88GFX.LIB" "${MODS[@]}" 2>&1
)" || RC=$?
[ -n "$OUT" ] && printf '%s\n' "$OUT" >&2
uppercase
[ "$RC" -eq 0 ] || exit "$RC"
check_indirect_immediate "$OUT" "$BUILD/CZ88GFX.LIB"

# The link check, once per CPU a project can pick.
shopt -s nullglob
for CPU in 8080 8085 z80; do
  chk="CHK${CPU^^}"
  OUT="$(
    cd "$SRC"
    "$Z80ASM" -m"$CPU" -I"$SRC" -O"$BUILD" -b -m -l="$BUILD/CZ88GFX.LIB" \
      -o="$BUILD/$chk.COM" CZ88CHK.Z88 2>&1
  )" || RC=$?
  [ -n "$OUT" ] && printf '%s\n' "$OUT" >&2
  rm -f "$BUILD/CZ88CHK.o"
  [ -f "$BUILD/$chk.map" ] && mv -f "$BUILD/$chk.map" "$BUILD/$chk.MAP"
  if [ "$RC" -ne 0 ]; then
    echo "error: the link check (CZ88CHK.Z88) failed for the $CPU" >&2
    exit "$RC"
  fi
  check_indirect_immediate "$OUT" "$BUILD/$chk.COM"
  echo "  check: build/$chk.COM links ($(stat -c %s "$BUILD/$chk.COM") bytes)"
done
shopt -u nullglob

# The C bindings' check, likewise: src/czcchk.c calls every entry point in
# cz88gfx.h, compiled by zcc for each CPU's C library and linked against the
# new library.
find_zcc
ZINC="$REPO_ROOT/tools/z88dk/include"
for CPU in 8080 8085 z80; do
  zcc_clib
  chk="CCHK${CPU^^}"
  OUT="$(
    cd "$SRC"
    "$ZCC" +cpm -clib="$CLIB" -I"$SRC" -I"$ZINC" -m -o "$BUILD/$chk.COM" \
      czcchk.c -l"$BUILD/CZ88GFX.LIB" 2>&1
  )" || RC=$?
  [ -n "$OUT" ] && printf '%s\n' "$OUT" >&2
  [ -f "$BUILD/$chk.map" ] && mv -f "$BUILD/$chk.map" "$BUILD/$chk.MAP"
  if [ "$RC" -ne 0 ] || [ ! -f "$BUILD/$chk.COM" ]; then
    echo "error: the C bindings' check (czcchk.c) failed for the $CPU" >&2
    exit "$(( RC ? RC : 1 ))"
  fi
  echo "  check: build/$chk.COM links (C, $(stat -c %s "$BUILD/$chk.COM") bytes)"
done

SIZE="$(stat -c %s "$BUILD/CZ88GFX.LIB")"
echo "  build/CZ88GFX.LIB  $SIZE bytes; build/CZ*.LIS listings"
hex="$(sed -nE 's/^CZ88VER[[:space:]]+EQU[[:space:]]+0?([0-9A-Fa-f]{1,4})H.*/\1/p' "$SRC/CZ88GFX.INC" | head -n1)"
v=$((16#${hex:-0}))
echo "  CZ88VER $((v >> 8)).$((v & 255)): pin \"dev\" to use this build, or tools/release.sh to release it"
