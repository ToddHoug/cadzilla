# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Shared helpers for the CADzilla z88dk build scripts -- sourced, not run:
#   tools/z88dk/z88build.sh   .Z88 assembly (z80asm)
#   tools/z88dk/zccbuild.sh   C (zcc), plus any .Z88 modules
#   software/z88dk/cz88gfx/tools/build.sh   the cz88gfx graphics library
# See tools/z88dk/README.md.

# find_z80asm: set Z80ASM (and SNAP=1 for the snap), the snap's name first,
# then a native install's.
find_z80asm() {
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
}

# find_zcc: set ZCC, z88dk's C compiler driver, the snap's name first, then a
# native install's.
find_zcc() {
  if command -v z88dk.zcc >/dev/null 2>&1; then
    ZCC=z88dk.zcc
  elif command -v zcc >/dev/null 2>&1; then
    ZCC=zcc
  else
    echo "error: z88dk's zcc not found (snap: z88dk.zcc, native: zcc)" >&2
    exit 1
  fi
}

# zcc_clib: set CLIB, zcc's CP/M C library for $CPU (lib/config/cpm.cfg). It
# also sets the compiler's and assembler's -m flag and defines __8080 /
# __8085 / __Z80.
zcc_clib() {
  case "$CPU" in
    8080) CLIB=8080 ;;
    8085) CLIB=8085 ;;
    z80)  CLIB=default ;;
  esac
}

# check_snap_path <dir>: the snap is confined to non-hidden paths under $HOME.
# Anywhere else (/tmp included) it reports "file not found" for files that
# plainly exist. A no-op unless SNAP=1.
check_snap_path() {
  [ "${SNAP:-0}" = 1 ] || return 0
  local home_real
  home_real="$(cd "$HOME" && pwd -P)"
  case "$1/" in
    "$home_real"/*) ;;
    *)
      echo "error: $1 is outside \$HOME -- the z88dk snap can't see it" >&2
      exit 1
      ;;
  esac
  if [[ "${1#"$home_real"/}" == .* || "${1#"$home_real"/}" == */.* ]]; then
    echo "error: $1 is under a hidden directory -- the z88dk snap can't see it" >&2
    exit 1
  fi
}

# read_cpu <project>: set CPU from the cpu0 [[board]] block in the project's
# machine.toml, else pristine's 8080. Exits on anything but 8080|8085|z80.
read_cpu() {
  CPU="8080"
  if [ -f "$1/machine.toml" ]; then
    local found
    found="$(awk '
      /^[[:space:]]*\[\[board\]\]/ { if (id == "cpu0" && type != "") cpu = type; id = ""; type = ""; next }
      /^[[:space:]]*\[/            { if (id == "cpu0" && type != "") cpu = type; id = ""; type = ""; next }
      /^[[:space:]]*id[[:space:]]*=/   { s = $0; sub(/#.*/, "", s); gsub(/.*=[[:space:]]*"|".*/, "", s); id = s }
      /^[[:space:]]*type[[:space:]]*=/ { s = $0; sub(/#.*/, "", s); gsub(/.*=[[:space:]]*"|".*/, "", s); type = s }
      END { if (id == "cpu0" && type != "") cpu = type; print cpu }
    ' "$1/machine.toml")"
    [ -n "$found" ] && CPU="$found"
  fi
  case "$CPU" in
    8080|8085|z80) ;;
    *)
      echo "error: machine.toml's cpu0 type is '$CPU' -- this toolchain targets 8080, 8085 or z80" >&2
      exit 1
      ;;
  esac
}

# read_cz88gfx <project>: the cz88gfx graphics library, if the project pins it
# in cz88gfx.version: a release ("1.0" -> software/z88dk/cz88gfx/releases/1.0/) or
# "dev" (software/z88dk/cz88gfx's own src/ and build/, warning if that build is older
# than its sources). Sets CZ88GFX to the pin, CZ88INC to the directory holding
# CZ88GFX.INC (and, from 1.1, cz88gfx.h), CZ88LIB to the library, and CZ88FLAGS
# to the z80asm flags that put CZ88INC on the include path and link CZ88LIB;
# all empty without a pin. Exits on a pin that names no release.
read_cz88gfx() {
  CZ88GFX=""
  CZ88INC=""
  CZ88LIB=""
  CZ88FLAGS=()
  local pin="$1/cz88gfx.version"
  [ -f "$pin" ] || return 0
  local root inc lib
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)/software/z88dk/cz88gfx"
  CZ88GFX="$(sed 's/#.*//' "$pin" | tr -d ' \t\r' | grep -v '^$' | head -n1)"
  if [ "$CZ88GFX" = dev ]; then
    inc="$root/src"
    lib="$root/build/CZ88GFX.LIB"
    if [ ! -f "$lib" ]; then
      echo "error: cz88gfx.version is 'dev' but there is no $lib -- run software/z88dk/cz88gfx/tools/build.sh" >&2
      exit 1
    fi
    if [ -n "$(find "$root/src" -type f -newer "$lib" | head -n1)" ]; then
      echo "warning: cz88gfx's sources are newer than its dev build -- run software/z88dk/cz88gfx/tools/build.sh" >&2
    fi
  else
    inc="$root/releases/$CZ88GFX"
    lib="$inc/CZ88GFX.LIB"
    if [[ ! "$CZ88GFX" =~ ^[0-9]+\.[0-9]+$ ]] || [ ! -f "$lib" ]; then
      echo "error: cz88gfx.version pins '$CZ88GFX', which is not a release in $root/releases/ ($(ls "$root/releases" 2>/dev/null | tr '\n' ' ')) or 'dev'" >&2
      exit 1
    fi
  fi
  CZ88INC="$inc"
  CZ88LIB="$lib"
  CZ88FLAGS=(-I"$inc" -l="$lib")
}

# read_flags <file>: set FLAGS from an optional flags file -- one line or
# several, '#' comments allowed.
read_flags() {
  FLAGS=()
  if [ -f "$1" ]; then
    read -r -a FLAGS <<< "$(sed 's/#.*//' "$1" | tr '\n' ' ')"
  fi
}

# lint_jp_cp <file>: z80asm reads JP and CP with their Zilog meanings (jump,
# compare). In a file written with Intel mnemonics, `JP x` / `CP x` was
# probably meant as Intel's jump-if-plus / call-if-plus, which z80asm spells
# JP P,x / CALL P,x. A warning, not an error: a file may mix the two styles on
# purpose. <file> is reported as given.
lint_jp_cp() {
  awk -v file="$(basename "$1")" '
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
  ' "$1" >&2
}

# check_indirect_immediate <output> <com>: one z80asm warning is really a
# wrong-code error. For the 8080/8085 it assembles `ld sp,(nn)` -- a Z80 load
# of SP from memory -- as `ld sp,nn`, loading SP with the ADDRESS, and only
# warns. Fail the build instead (deleting <com>).
check_indirect_immediate() {
  if grep -q 'interpreting indirect value as immediate' <<< "$1"; then
    rm -f "$2"
    echo "error: z80asm turned an indirect operand into an immediate one (above) -- on the $CPU that is different code; rewrite it with $CPU instructions" >&2
    exit 1
  fi
}

# write_sym <map> <sym> [<srcdir>]: the DR .SYM file altairsim's SYMBOLS LOAD
# reads, "XXXX NAME" per line, from z80asm's map -- address labels only, never
# constants (so BDOS stays 0005 in a DISASM), and never z80asm's own
# __head/__tail/... With <srcdir> (a C build, whose map also holds the whole C
# library's internals), only public labels and the locals of modules whose
# source is in <srcdir> are kept.
write_sym() {
  local files=""
  if [ -n "${3:-}" ]; then
    files="$(cd "$3" && ls -1 | tr '\n' '/')"
  fi
  awk -v srcdir="${3:-}" -v files="/$files" '
    $2 == "=" && $4 == ";" && $5 == "addr," && $1 !~ /^__/ {
      if (srcdir != "" && $6 != "public,") {
        n = split($0, f, ",")                     # ..., module, section, file:line
        file = f[n]; sub(/^[[:space:]]*/, "", file); sub(/:.*/, "", file)
        if (file == "" || index(files, "/" file "/") == 0) next
      }
      v = toupper($3); sub(/^\$/, "", v); while (length(v) < 4) v = "0" v
      print v, toupper($1)
    }' "$1" > "$2"
}
