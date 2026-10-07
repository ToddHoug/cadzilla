#!/usr/bin/env bash
# Build a CADzilla zcc (C) project on the host: compile software/<name>/src/*.c
# with z88dk's zcc (+cpm, the sccz80 compiler and classic C library), assemble
# any src/*.Z88 modules with z80asm, and link them into
# software/<name>/build/<NAME>.COM, for the CPU the project's machine.toml puts
# in the emulator (8080, 8085 or Z80).
#
# Usage: zccbuild.sh software/<name>
#
# The project:
#   src/<name>.c     the main module: the one .c that defines main(). Its name,
#                    lowercase (zcc only takes a lowercase .c), uppercased is
#                    the CP/M-side program name: chello.c -> CHELLO.COM
#   src/*.c          any other C modules
#   src/*.Z88        any assembly modules (z80asm syntax, as for z88build.sh).
#                    Each starts with SECTION code_user and exports C-callable
#                    names with a leading underscore: PUBLIC _cpuid
#   src/, include/   searched for #include / INCLUDE files (.h, .INC), then
#                    tools/z88dk/include/ -- the shared <cadzilla.h> board
#                    port definitions
#   machine.toml     the cpu0 [[board]] block: type = "8080" | "8085" | "z80".
#                    The same block puts that CPU in the emulator, so the code
#                    and the machine always agree. No block = 8080 (pristine's).
#   zcc.flags        optional: extra zcc flags, e.g. -O3, -lm, -DDEBUG
#                    ('#' starts a comment)
#   cz88gfx.version  optional: the cz88gfx graphics library release it builds
#                    against ("1.1" or later, or "dev"). Puts cz88gfx.h on the
#                    include path (#include <cz88gfx.h>) and links CZ88GFX.LIB;
#                    only the modules the program uses go into the .COM. See
#                    software/cz88gfx/README.md, "Using it from C".
#
# Writes into build/ (gitignored), uppercase like every other build artifact:
#   <NAME>.COM   the program, ready for `R <NAME>.COM` in CP/M
#   <NAME>.MAP   the linker's map: every symbol, the C library's too, absolute
#   <NAME>.SYM   public labels plus the project's own locals in DR .SYM form,
#                for altairsim's `SYMBOLS LOAD` (C names keep their _: _MAIN)
#   <MOD>.LIS    each C module's listing, its C source interleaved with the
#                generated code; each .Z88 module's listing
#   CRT0.LIS     the CP/M startup code's listing
#   <MOD>.O      each .Z88 module's object
#
# The C compiler defines __8080, __8085 or __Z80, and __CPM__, for #ifdef.
# See tools/z88dk/README.md.
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
find_zcc
check_snap_path "$PROJ"
read_cpu "$PROJ"
read_cz88gfx "$PROJ"
zcc_clib

# Shared headers for every zcc project (cadzilla.h), after the project's own.
ZINC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/include"

# The cz88gfx graphics library, if the project pins it: cz88gfx.h (and
# CZ88GFX.INC, for the .Z88 modules) on the include path, CZ88GFX.LIB linked.
# Its C bindings start with release 1.1.
GFXINC=()
GFXLIB=()
if [ -n "$CZ88GFX" ]; then
  if [ ! -f "$CZ88INC/cz88gfx.h" ]; then
    echo "error: cz88gfx $CZ88GFX has no C bindings (no cz88gfx.h in $CZ88INC) -- pin release 1.1 or later in cz88gfx.version" >&2
    exit 1
  fi
  GFXINC=(-I"$CZ88INC")
  GFXLIB=(-l"$CZ88LIB")
fi

# The modules. zcc matches suffixes case-sensitively, so a .C or .H is a
# mistake here, not a style choice.
shopt -s nullglob
CS=()
ZS=()
for f in "$SRC"/*.c; do CS+=("$(basename "$f")"); done
for f in "$SRC"/*.Z88; do ZS+=("$(basename "$f")"); done
UPPER=("$SRC"/*.C "$SRC"/*.H)
shopt -u nullglob
if [ ${#UPPER[@]} -gt 0 ]; then
  echo "error: zcc only accepts lowercase .c/.h -- rename: ${UPPER[*]##*/}" >&2
  exit 1
fi
if [ ${#CS[@]} -eq 0 ]; then
  echo "error: no .c sources in $SRC" >&2
  exit 1
fi

# The main module defines main() -- found by a plain search for "main(" outside
# // and block-comment-looking lines, which is good enough for a project's own
# sources.
MAIN=()
OTHERS=()
for f in "${CS[@]}"; do
  if grep -vE '^[[:space:]]*(//|/?\*)' "$SRC/$f" | grep -qE '(^|[^[:alnum:]_])main[[:space:]]*\('; then
    MAIN+=("$f")
  else
    OTHERS+=("$f")
  fi
done
if [ ${#MAIN[@]} -ne 1 ]; then
  echo "error: exactly one .c in $SRC must define main() (the main module); found ${#MAIN[@]}: ${MAIN[*]:-none}" >&2
  exit 1
fi
BASE="${MAIN[0]%.c}"
if [[ ! "$BASE" =~ ^[a-z][a-z0-9]{0,7}$ ]]; then
  echo "error: main module '${MAIN[0]}' must be a lowercase CP/M 8.3 name (1-8 letters/digits) -- it names the .COM" >&2
  exit 1
fi
NAME="$(printf '%s' "$BASE" | tr '[:lower:]' '[:upper:]')"

# Listings are named after the module, uppercased: a chello.c and a CHELLO.Z88
# would both want CHELLO.LIS.
for z in "${ZS[@]}"; do
  for c in "${CS[@]}"; do
    if [ "${z%.Z88}" = "$(printf '%s' "${c%.c}" | tr '[:lower:]' '[:upper:]')" ]; then
      echo "error: $c and $z share a name -- rename one (their listings would both be ${z%.Z88}.LIS)" >&2
      exit 1
    fi
  done
done

read_flags "$PROJ/zcc.flags"

# Start clean of this program's outputs, so a failed build can't leave an old
# .COM behind looking current.
rm -f "$BUILD/$NAME.COM" "$BUILD/$NAME.MAP" "$BUILD/$NAME.SYM" "$BUILD/CRT0.LIS"

echo "zcc: $NAME for $CPU (${MAIN[0]}${OTHERS[*]:+ + ${OTHERS[*]}}${ZS[*]:+ + ${ZS[*]}})${CZ88GFX:+, cz88gfx $CZ88GFX}"

# Uppercase names for the outputs, as for every build artifact in this repo --
# after a failed build too, since the listings show where it failed. zcc writes
# a C module's listing beside its source; it never belongs in src/.
tidy() {
  local f base
  for f in "${CS[@]}"; do
    base="$(printf '%s' "${f%.c}" | tr '[:lower:]' '[:upper:]')"
    if [ -f "$SRC/$f.lis" ]; then mv -f "$SRC/$f.lis" "$BUILD/$base.LIS"; fi
  done
  for f in "${ZS[@]}"; do
    base="${f%.Z88}"
    if [ -f "$BUILD/$base.lis" ]; then mv -f "$BUILD/$base.lis" "$BUILD/$base.LIS"; fi
    if [ -f "$BUILD/$base.o" ]; then mv -f "$BUILD/$base.o" "$BUILD/$base.O"; fi
    rm -f "$BUILD/$base.o.lis"                     # the linker's copy of $base.lis
  done
  if [ -f "$BUILD/$NAME.map" ]; then mv -f "$BUILD/$NAME.map" "$BUILD/$NAME.MAP"; fi
  if [ -f "$BUILD/$NAME.lis" ]; then mv -f "$BUILD/$NAME.lis" "$BUILD/CRT0.LIS"; fi
}

# The assembly modules, for the same CPU, into build/<MOD>.o (lowercase until
# the link: zcc only takes a lowercase .o). Run from src/ with bare names: -O
# keeps a source's relative path, so this puts them straight into build/.
OBJS=()
for f in "${ZS[@]}"; do
  lint_jp_cp "$SRC/$f"
  if ! grep -qiE '^[[:space:]]*SECTION[[:space:]]' "$SRC/$f"; then
    echo "$f: warning: no SECTION -- its code lands wherever the linker puts the unnamed section; start it with SECTION code_user" >&2
  fi
  RC=0
  OUT="$(cd "$SRC" && "$Z80ASM" -m"$CPU" -I"$SRC" -I"$PROJ/include" "${GFXINC[@]}" -I"$ZINC" -O"$BUILD" -l "$f" 2>&1)" || RC=$?
  [ -n "$OUT" ] && printf '%s\n' "$OUT" >&2
  if [ "$RC" -ne 0 ]; then tidy; exit "$RC"; fi
  check_indirect_immediate "$OUT" "$BUILD/$NAME.COM"
  OBJS+=("$BUILD/${f%.Z88}.o")
done

# Compile and link. -o with no -create-app writes the raw binary, ORG 0100H:
# the .COM itself. --list --c-code-in-asm gives each C module a listing with
# its source interleaved; -m, the map.
RC=0
OUT="$(
  cd "$SRC"
  "$ZCC" +cpm -clib="$CLIB" -I"$SRC" -I"$PROJ/include" "${GFXINC[@]}" -I"$ZINC" -m --list --c-code-in-asm \
    -o "$BUILD/$NAME.COM" "${FLAGS[@]}" "${MAIN[0]}" "${OTHERS[@]}" "${OBJS[@]}" "${GFXLIB[@]}" 2>&1
)" || RC=$?
[ -n "$OUT" ] && printf '%s\n' "$OUT" >&2
tidy
if [ "$RC" -ne 0 ]; then
  rm -f "$BUILD/$NAME.COM"
  exit "$RC"
fi
check_indirect_immediate "$OUT" "$BUILD/$NAME.COM"
[ -f "$BUILD/$NAME.COM" ] || { echo "error: zcc reported success but wrote no $NAME.COM" >&2; exit 1; }

# The C library's 8080/8085 inp()/outp() can't use a fixed-port IN/OUT, so they
# build one in a shared 3-byte RAM stub (iotmp) and call it: slow, and an
# interrupt handler doing port I/O mid-call corrupts it. CADzilla code must be
# interrupt-safe, so refuse it; their only user is that stub.
if [ -f "$BUILD/$NAME.MAP" ] && grep -qE '^iotmp[[:space:]]' "$BUILD/$NAME.MAP"; then
  rm -f "$BUILD/$NAME.COM"
  echo "error: the program uses the C library's inp()/outp(), which on the $CPU go through a shared self-modifying stub -- slow and not interrupt-safe. Declare the port with __sfr __at (one inline IN/OUT), or poll it in a .Z88 module (tools/z88dk/README.md, \"Port I/O\")" >&2
  exit 1
fi

# The DR .SYM file for altairsim's SYMBOLS LOAD: public labels (the C
# library's included) and the project's own locals -- not the library's.
if [ -f "$BUILD/$NAME.MAP" ]; then
  write_sym "$BUILD/$NAME.MAP" "$BUILD/$NAME.SYM" "$SRC"
fi

SIZE="$(stat -c %s "$BUILD/$NAME.COM")"
echo "  build/$NAME.COM  $SIZE bytes ($(( (SIZE + 127) / 128 )) CP/M records)"
echo "  build/$NAME.SYM  $(wc -l < "$BUILD/$NAME.SYM") labels  (SYMBOLS LOAD)"
echo "  build/$NAME.MAP, build/*.LIS"
