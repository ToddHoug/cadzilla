#!/usr/bin/env bash
# Point drive 1 (CP/M B:) of a project's altairsim work machine at the czgfx
# library disk, software/czgfx/libdisk/CZGFX.DSK.
#
# The czgfx project (software/czgfx/) builds the CADzilla graphics library --
# the CZGFX.INC macro header plus the relocatable .REL modules and the
# CZLINK.SUB link script -- onto that disk. Every M80 project that uses the
# library mounts the same disk as B:, INCLUDEs B:CZGFX.INC and links with
# SUBMIT B:CZLINK <NAME>.
#
# Consumers get the disk READ-ONLY (readonly = true in the machine file): the
# guest can read it, and a stray write is refused at the controller instead
# of reaching the host file. Only software/czgfx/work itself attaches it with
# --writable, because that is where the library is rebuilt.
#
# If the library disk doesn't exist yet it is created as a copy of the
# pristine BLANK-8MB.DSK (pristine is only read, never written).
#
# Re-run this after `sync_pristine.sh --machine-only <work-dir>`: that
# restores the pristine cadzilla.toml, whose drive 1 is BLANK-8MB.DSK again.
# Running it twice is harmless.
#
# Usage: attach_libdisk.sh [--writable] <work-dir>
set -euo pipefail

WRITABLE=0
if [ "${1:-}" = "--writable" ]; then
  WRITABLE=1
  shift
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 [--writable] <work-dir>" >&2
  exit 1
fi

WORK="$1"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PRISTINE="$REPO_ROOT/tools/altairsim/pristine"
LIBDIR="$REPO_ROOT/software/czgfx/libdisk"
LIBDISK="$LIBDIR/CZGFX.DSK"
TOML="$WORK/cadzilla.toml"

if [ ! -f "$TOML" ]; then
  echo "error: $TOML not found -- create the work dir with sync_pristine.sh first" >&2
  exit 1
fi
if [ "$(cd "$WORK" && pwd -P)" = "$(cd "$PRISTINE" && pwd -P)" ]; then
  echo "error: $WORK is the pristine directory itself -- never attach anything there" >&2
  exit 1
fi

if [ ! -f "$LIBDISK" ]; then
  if [ ! -f "$PRISTINE/BLANK-8MB.DSK" ]; then
    echo "error: $PRISTINE/BLANK-8MB.DSK not found -- can't create the library disk" >&2
    exit 1
  fi
  mkdir -p "$LIBDIR"
  cp "$PRISTINE/BLANK-8MB.DSK" "$LIBDISK"
  chmod u+w "$LIBDISK"
  echo "Created empty library disk $LIBDISK (build it from software/czgfx)"
fi

REL="$(realpath --relative-to="$(cd "$WORK" && pwd -P)" "$LIBDISK")"

# Rewrite the [[board.drive]] block whose unit is 1: its mount becomes the
# library disk, any existing readonly/writeprotect line is dropped, and
# readonly = true is added back unless --writable.
tmp="$(mktemp)"
awk -v rel="$REL" -v ro="$WRITABLE" '
  /^[[:space:]]*\[\[board\.drive\]\]/ { unit1 = 0 }
  /^[[:space:]]*\[\[board\]\]/        { unit1 = 0 }
  /^[[:space:]]*unit[[:space:]]*=[[:space:]]*1[[:space:]]*$/ { unit1 = 1; print; next }
  unit1 && /^[[:space:]]*(readonly|writeprotect)[[:space:]]*=/ { next }
  unit1 && /^[[:space:]]*#.*czgfx library disk/ { next }
  unit1 && /^[[:space:]]*mount[[:space:]]*=/ {
    print "  # czgfx library disk (CP/M B:) -- managed by tools/altairsim/scripts/attach_libdisk.sh"
    print "  mount = \"" rel "\""
    if (ro == 0) print "  readonly = true"
    done = 1
    next
  }
  { print }
  END { if (!done) exit 3 }
' "$TOML" > "$tmp" || {
  rc=$?
  rm -f "$tmp"
  if [ "$rc" -eq 3 ]; then
    echo "error: no drive with unit = 1 and a mount line found in $TOML" >&2
  fi
  exit 1
}
cat "$tmp" > "$TOML"
rm -f "$tmp"

if [ "$WRITABLE" -eq 1 ]; then
  echo "Attached $REL as drive 1 (B:, writable) in $TOML"
else
  echo "Attached $REL as drive 1 (B:, read-only) in $TOML"
fi
