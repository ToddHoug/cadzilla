#!/usr/bin/env bash
# Build a CADzilla z88dk project on the host: assemble software/<name>/src/*.Z88
# with z88dk's z80asm into software/<name>/build/<NAME>.COM, for the CPU the
# project's machine.toml puts in the emulator (8080, 8085 or Z80).
#
# Usage: z88build.sh software/<name>
#
# The project:
#   src/<NAME>.Z88   the main module: the one .Z88 with an ORG (ORG 0100H for a
#                    CP/M .COM). Its name is the CP/M-side program name.
#   src/*.Z88        any other modules, linked after it (PUBLIC/EXTERN)
#   src/, include/   searched for INCLUDE files (.INC)
#   machine.toml     the cpu0 [[board]] block: type = "8080" | "8085" | "z80".
#                    The same block puts that CPU in the emulator, so the code
#                    and the machine always agree. No block = 8080 (pristine's).
#   z88dk.flags      optional: extra z80asm flags, e.g. -ucase or -no-synth
#                    ('#' starts a comment)
#   cz88gfx.version  optional: the cz88gfx graphics library release it builds
#                    against ("1.0", or "dev" for software/cz88gfx's own
#                    build). Puts CZ88GFX.INC on the include path and links
#                    CZ88GFX.LIB; only the library modules the program
#                    references go into the .COM. See
#                    software/cz88gfx/README.md.
#
# Writes into build/ (gitignored), uppercase like every other build artifact:
#   <NAME>.COM   the program, ready for `R <NAME>.COM` in CP/M
#   <NAME>.MAP   z80asm's map: every symbol, absolute
#   <NAME>.SYM   the map's program labels in DR .SYM form, for altairsim's
#                `SYMBOLS LOAD` (constants are left out, so BDOS stays 0005)
#   *.LIS, *.O   per-module listings and objects
#
# z80asm predefines __CPU_8080__, __CPU_8085__ or __CPU_Z80__ (and
# __CPU_INTEL__ / __CPU_ZILOG__) for IFDEF. See tools/z88dk/README.md.
set -euo pipefail
# shellcheck source=z88common.sh
. "$(dirname "${BASH_SOURCE[0]}")/z88common.sh"

if [ $# -ne 1 ]; then
  echo "Usage: $0 software/<name>" >&2
  exit 1
fi

PROJ="$(cd "$1" && pwd -P)"
SRC="$PROJ/src"
BUILD="$PROJ/build"
[ -d "$SRC" ] || { echo "error: $SRC does not exist" >&2; exit 1; }
mkdir -p "$BUILD"

find_z80asm
check_snap_path "$PROJ"
read_cpu "$PROJ"
read_cz88gfx "$PROJ"

# The modules: the main one has the ORG, the rest follow it.
shopt -s nullglob
ALL=()
for f in "$SRC"/*.Z88; do ALL+=("$(basename "$f")"); done
shopt -u nullglob
if [ ${#ALL[@]} -eq 0 ]; then
  echo "error: no .Z88 sources in $SRC" >&2
  exit 1
fi
MAIN=()
OTHERS=()
for f in "${ALL[@]}"; do
  if grep -qiE '^[^;]*[[:space:]]ORG[[:space:]]' "$SRC/$f"; then
    MAIN+=("$f")
  else
    OTHERS+=("$f")
  fi
done
if [ ${#MAIN[@]} -ne 1 ]; then
  echo "error: exactly one .Z88 in $SRC must have an ORG (the main module); found ${#MAIN[@]}: ${MAIN[*]:-none}" >&2
  exit 1
fi
NAME="${MAIN[0]%.Z88}"
if [[ ! "$NAME" =~ ^[A-Z][A-Z0-9]{0,7}$ ]]; then
  echo "error: main module '${MAIN[0]}' must be an uppercase CP/M 8.3 name (1-8 letters/digits)" >&2
  exit 1
fi

# Extra flags, one line or several, '#' comments allowed.
read_flags "$PROJ/z88dk.flags"

# Lint: JP x / CP x in a file written with Intel mnemonics (z88common.sh).
for f in "${ALL[@]}"; do lint_jp_cp "$SRC/$f"; done

# Start clean of this program's outputs, so a failed build can't leave an old
# .COM behind looking current.
rm -f "$BUILD/$NAME.COM" "$BUILD/$NAME.MAP" "$BUILD/$NAME.SYM"

echo "z88dk: $NAME for $CPU (${MAIN[0]}${OTHERS[*]:+ + ${OTHERS[*]}})${CZ88GFX:+, cz88gfx $CZ88GFX}"
# Run from src/ with bare names: -O keeps a source's relative path, so this is
# what puts the objects and listings straight into build/.
RC=0
OUT="$(
  cd "$SRC"
  "$Z80ASM" -m"$CPU" -I"$SRC" -I"$PROJ/include" -O"$BUILD" -b -l -m \
    -o="$BUILD/$NAME.COM" "${CZ88FLAGS[@]}" "${FLAGS[@]}" "${MAIN[0]}" "${OTHERS[@]}" 2>&1
)" || RC=$?
[ -n "$OUT" ] && printf '%s\n' "$OUT" >&2

# Uppercase names for the outputs, as for every build artifact in this repo --
# a failed build's listings too, since they show where it failed.
for f in "${ALL[@]}"; do
  base="${f%.Z88}"
  if [ -f "$BUILD/$base.lis" ]; then mv -f "$BUILD/$base.lis" "$BUILD/$base.LIS"; fi
  if [ -f "$BUILD/$base.o" ]; then mv -f "$BUILD/$base.o" "$BUILD/$base.O"; fi
done
if [ -f "$BUILD/$NAME.map" ]; then mv -f "$BUILD/$NAME.map" "$BUILD/$NAME.MAP"; fi

[ "$RC" -eq 0 ] || exit "$RC"

# `ld sp,(nn)` assembled as `ld sp,nn` for the 8080/8085 -- an error here.
check_indirect_immediate "$OUT" "$BUILD/$NAME.COM"

# The DR .SYM file for altairsim's SYMBOLS LOAD: the program labels only.
if [ -f "$BUILD/$NAME.MAP" ]; then
  write_sym "$BUILD/$NAME.MAP" "$BUILD/$NAME.SYM"
fi

SIZE="$(stat -c %s "$BUILD/$NAME.COM")"
echo "  build/$NAME.COM  $SIZE bytes ($(( (SIZE + 127) / 128 )) CP/M records)"
echo "  build/$NAME.SYM  $(wc -l < "$BUILD/$NAME.SYM") labels  (SYMBOLS LOAD)"
echo "  build/$NAME.MAP, build/*.LIS"
