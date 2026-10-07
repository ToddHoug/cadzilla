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

if [ $# -ne 1 ]; then
  echo "Usage: $0 software/<name>" >&2
  exit 1
fi

PROJ="$(cd "$1" && pwd -P)"
SRC="$PROJ/src"
BUILD="$PROJ/build"
[ -d "$SRC" ] || { echo "error: $SRC does not exist" >&2; exit 1; }
mkdir -p "$BUILD"

# z80asm: the snap's name first, then a native install's.
if command -v z88dk.z88dk-z80asm >/dev/null 2>&1; then
  Z80ASM=z88dk.z88dk-z80asm
  SNAP=1
elif command -v z88dk-z80asm >/dev/null 2>&1; then
  Z80ASM=z88dk-z80asm
  SNAP=0
else
  echo "error: z88dk's z80asm not found (snap: z88dk.z88dk-z80asm, native: z88dk-z80asm)" >&2
  exit 1
fi

# The snap is confined to non-hidden paths under $HOME. Anywhere else (/tmp
# included) it reports "file not found" for files that plainly exist.
if [ "$SNAP" = 1 ]; then
  HOME_REAL="$(cd "$HOME" && pwd -P)"
  case "$PROJ/" in
    "$HOME_REAL"/*) ;;
    *)
      echo "error: $PROJ is outside \$HOME -- the z88dk snap can't see it" >&2
      exit 1
      ;;
  esac
  if [[ "${PROJ#"$HOME_REAL"/}" == .* || "${PROJ#"$HOME_REAL"/}" == */.* ]]; then
    echo "error: $PROJ is under a hidden directory -- the z88dk snap can't see it" >&2
    exit 1
  fi
fi

# The CPU: the cpu0 [[board]] block in machine.toml, else pristine's 8080.
CPU="8080"
if [ -f "$PROJ/machine.toml" ]; then
  FOUND="$(awk '
    /^[[:space:]]*\[\[board\]\]/ { if (id == "cpu0" && type != "") cpu = type; id = ""; type = ""; next }
    /^[[:space:]]*\[/            { if (id == "cpu0" && type != "") cpu = type; id = ""; type = ""; next }
    /^[[:space:]]*id[[:space:]]*=/   { s = $0; sub(/#.*/, "", s); gsub(/.*=[[:space:]]*"|".*/, "", s); id = s }
    /^[[:space:]]*type[[:space:]]*=/ { s = $0; sub(/#.*/, "", s); gsub(/.*=[[:space:]]*"|".*/, "", s); type = s }
    END { if (id == "cpu0" && type != "") cpu = type; print cpu }
  ' "$PROJ/machine.toml")"
  [ -n "$FOUND" ] && CPU="$FOUND"
fi
case "$CPU" in
  8080|8085|z80) ;;
  *)
    echo "error: machine.toml's cpu0 type is '$CPU' -- this toolchain targets 8080, 8085 or z80" >&2
    exit 1
    ;;
esac

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
FLAGS=()
if [ -f "$PROJ/z88dk.flags" ]; then
  read -r -a FLAGS <<< "$(sed 's/#.*//' "$PROJ/z88dk.flags" | tr '\n' ' ')"
fi

# Lint: z80asm reads JP and CP with their Zilog meanings (jump, compare). In a
# file written with Intel mnemonics, `JP x` / `CP x` was probably meant as
# Intel's jump-if-plus / call-if-plus, which z80asm spells JP P,x / CALL P,x.
# A warning, not an error: a file may mix the two styles on purpose.
lint() {
  awk -v file="$1" '
    function strip(s,    out, i, c, q) {
      out = ""; q = ""
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (q != "") { if (c == q) q = ""; continue }
        if (c == "\"" || c == "\x27") { q = c; continue }
        if (c == ";") break
        out = out c
      }
      return out
    }
    {
      line[NR] = strip($0)
      if (toupper(line[NR]) ~ /(^|[[:space:]:])(MOV|MVI|LXI|LDA|STA|LHLD|SHLD|LDAX|STAX|XCHG|INR|DCR|INX|DCX|DAD|ADI|SUI|ANI|XRI|ORI|ANA|XRA|ORA|CMP|JMP|HLT|PCHL|SPHL|XTHL)[[:space:]]/)
        intel = 1
    }
    END {
      if (!intel) exit
      for (n = 1; n <= NR; n++) {
        s = toupper(line[n])
        if (match(s, /(^|[[:space:]:])(JP|CP)[[:space:]]+[^[:space:]]/)) {
          op = substr(s, RSTART, RLENGTH); sub(/^[[:space:]:]*/, "", op); sub(/[[:space:]].*/, "", op)
          arg = substr(s, RSTART + RLENGTH - 1); sub(/[[:space:]]+$/, "", arg)
          if (arg ~ /,/) continue                                   # JP cc,x
          if (op == "JP" && arg ~ /^\((HL|IX|IY)\)$/) continue      # JP (HL)
          if (op == "CP" && arg ~ /^(A|B|C|D|E|H|L|IXH|IXL|IYH|IYL|\((HL|IX|IY).*\))$/) continue   # CP r
          if (op == "JP")
            printf "%s:%d: warning: JP %s is z80asm'"'"'s unconditional jump; Intel jump-if-plus is JP P,%s (or write JMP %s)\n", file, n, arg, arg, arg
          else
            printf "%s:%d: warning: CP %s is z80asm'"'"'s compare; Intel call-if-plus is CALL P,%s (or write CPI %s)\n", file, n, arg, arg, arg
        }
      }
    }
  ' "$SRC/$1" >&2
}
for f in "${ALL[@]}"; do lint "$f"; done

# Start clean of this program's outputs, so a failed build can't leave an old
# .COM behind looking current.
rm -f "$BUILD/$NAME.COM" "$BUILD/$NAME.MAP" "$BUILD/$NAME.SYM"

echo "z88dk: $NAME for $CPU (${MAIN[0]}${OTHERS[*]:+ + ${OTHERS[*]}})"
# Run from src/ with bare names: -O keeps a source's relative path, so this is
# what puts the objects and listings straight into build/.
RC=0
OUT="$(
  cd "$SRC"
  "$Z80ASM" -m"$CPU" -I"$SRC" -I"$PROJ/include" -O"$BUILD" -b -l -m \
    -o="$BUILD/$NAME.COM" "${FLAGS[@]}" "${MAIN[0]}" "${OTHERS[@]}" 2>&1
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

# One z80asm warning is really a wrong-code error. For the 8080/8085 it
# assembles `ld sp,(nn)` -- a Z80 load of SP from memory -- as `ld sp,nn`,
# loading SP with the ADDRESS, and only warns. Fail the build instead.
if grep -q 'interpreting indirect value as immediate' <<< "$OUT"; then
  rm -f "$BUILD/$NAME.COM"
  echo "error: z80asm turned an indirect operand into an immediate one (above) -- on the $CPU that is different code; rewrite it with $CPU instructions" >&2
  exit 1
fi

# The DR .SYM file altairsim's SYMBOLS LOAD reads: "XXXX NAME" per line, the
# program labels only (z80asm's own __head/__tail/... left out too).
if [ -f "$BUILD/$NAME.MAP" ]; then
  awk '$2 == "=" && $4 == ";" && $5 == "addr," && $1 !~ /^__/ {
         v = toupper($3); sub(/^\$/, "", v); while (length(v) < 4) v = "0" v
         print v, toupper($1)
       }' "$BUILD/$NAME.MAP" > "$BUILD/$NAME.SYM"
fi

SIZE="$(stat -c %s "$BUILD/$NAME.COM")"
echo "  build/$NAME.COM  $SIZE bytes ($(( (SIZE + 127) / 128 )) CP/M records)"
echo "  build/$NAME.SYM  $(wc -l < "$BUILD/$NAME.SYM") labels  (SYMBOLS LOAD)"
echo "  build/$NAME.MAP, build/*.LIS"
