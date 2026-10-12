#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Give a project's altairsim work machine the czgfx library as drive 1 (CP/M B:).
#
# The czgfx project (software/m80/czgfx/) builds the CADzilla graphics library --
# the CZGFX.INC macro header plus the relocatable CZGFX.REL and the CZLINK.SUB
# link script -- onto a disk image. An M80 project INCLUDEs B:CZGFX.INC and
# links with SUBMIT B:CZLINK <NAME>.
#
# A project builds against a RELEASE of the library that it chooses, in its
# own work/ -- so work/ is self-contained, and a czgfx change reaches a project
# only when the project moves to a new release:
#
#   software/<toolchain>/<project>/czgfx.version   the pin (tracked): a release number such
#                                      as 1.0, or `dev` for the current build
#   software/m80/czgfx/releases/CZGFXLIB-<version>.DSK
#                                      the releases (tracked, never changed),
#                                      made by software/m80/czgfx/tools/release.sh
#   software/<toolchain>/<project>/work/CZGFXLIB-<version>.DSK
#                                      the project's own copy, mounted as B:,
#                                      read-only (CZGFXLIB-DEV.DSK for `dev`)
#
# This copies the pinned release into work/ (again if the copy differs), points
# drive 1 of work/cadzilla.toml at it, read-only, and removes:
#   - copies of other releases in work/ that are still identical to their
#     release, or for a `dev` copy to the current build (anything else is
#     kept, with a note)
#   - the work dir's unused SCRATCH.DSK, if it is an untouched copy of the
#     pristine EMPTY.DSK
# `dev` copies the current build, software/m80/czgfx/libdisk/CZGFXLIB.DSK, and
# refreshes it on every run: for trying out an unreleased library.
#
# --writable is for software/m80/czgfx/work itself, where the library is built: it
# mounts the build disk software/m80/czgfx/libdisk/CZGFXLIB.DSK writable (creating
# it from the pristine EMPTY.DSK if it doesn't exist yet), with no pin.
#
# Re-run this after `sync_pristine.sh --machine-only <work-dir>` (which puts
# the pristine drive 1, SCRATCH.DSK, back) and after changing the pin.
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
LIBDIR="$REPO_ROOT/software/m80/czgfx/libdisk"
LIBDISK="$LIBDIR/CZGFXLIB.DSK"
RELDIR="$REPO_ROOT/software/m80/czgfx/releases"
EMPTY="$PRISTINE/EMPTY.DSK"
TOML="$WORK/cadzilla.toml"

if [ ! -f "$TOML" ]; then
  echo "error: $TOML not found -- create the work dir with sync_pristine.sh first" >&2
  exit 1
fi
if [ "$(cd "$WORK" && pwd -P)" = "$(cd "$PRISTINE" && pwd -P)" ]; then
  echo "error: $WORK is the pristine directory itself -- never attach anything there" >&2
  exit 1
fi

if [ "$WRITABLE" -eq 1 ]; then
  # czgfx's own machine: the build disk, shared with nothing but release.sh
  if [ ! -f "$LIBDISK" ]; then
    if [ ! -f "$EMPTY" ]; then
      echo "error: $EMPTY not found -- can't create the library disk" >&2
      exit 1
    fi
    mkdir -p "$LIBDIR"
    cp "$EMPTY" "$LIBDISK"
    chmod u+w "$LIBDISK"
    echo "Created empty library disk $LIBDISK (build it from software/m80/czgfx)"
  fi
  MOUNT="$(realpath --relative-to="$(cd "$WORK" && pwd -P)" "$LIBDISK")"
else
  # A project: its pinned release, copied into work/
  PIN="$(cd "$WORK/.." && pwd -P)/czgfx.version"
  if [ ! -f "$PIN" ]; then
    echo "error: $PIN not found -- pin a czgfx release, e.g.:" >&2
    echo "  echo 1.0 > $PIN      (releases: $(ls "$RELDIR" 2>/dev/null | tr '\n' ' '))" >&2
    exit 1
  fi
  VERSION="$(grep -vE '^[[:space:]]*(#|$)' "$PIN" | head -n1 | tr -d '[:space:]')"
  if [ "$VERSION" = "dev" ]; then
    SRC="$LIBDISK"
    TAG="DEV"
  else
    SRC="$RELDIR/CZGFXLIB-$VERSION.DSK"
    TAG="$VERSION"
  fi
  if [ ! -f "$SRC" ]; then
    echo "error: czgfx $VERSION (pinned in $PIN) not found: $SRC" >&2
    echo "  releases: $(ls "$RELDIR" 2>/dev/null | tr '\n' ' ')" >&2
    exit 1
  fi
  MOUNT="CZGFXLIB-$TAG.DSK"
  LOCAL="$WORK/$MOUNT"
  if [ ! -f "$LOCAL" ] || ! cmp -s "$SRC" "$LOCAL"; then
    cp -f "$SRC" "$LOCAL"
    chmod u+w "$LOCAL"
    echo "Copied czgfx $VERSION into $LOCAL"
  fi
  # Copies of other releases: drop them while they still match their release
  shopt -s nullglob
  for old in "$WORK"/CZGFXLIB-*.DSK; do
    [ "$(basename "$old")" = "$MOUNT" ] && continue
    rel="$RELDIR/$(basename "$old")"
    [ "$(basename "$old")" = "CZGFXLIB-DEV.DSK" ] && rel="$LIBDISK"
    if [ -f "$rel" ] && cmp -s "$rel" "$old"; then
      rm -f "$old"
      echo "Removed $old (czgfx $(basename "$old" .DSK | sed 's/^CZGFXLIB-//'), no longer pinned)"
    else
      echo "Note: $old is no longer mounted -- kept (not an unchanged release)"
    fi
  done
fi

# Rewrite the [[board.drive]] block whose unit is 1: its mount becomes the
# library disk, any existing readonly/writeprotect line is dropped, and
# readonly = true is added back unless --writable.
tmp="$(mktemp)"
awk -v rel="$MOUNT" -v ro="$WRITABLE" '
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
  echo "Attached $MOUNT as drive 1 (B:, writable) in $TOML"
else
  echo "Attached $MOUNT as drive 1 (B:, read-only) in $TOML"
fi

# The scratch disk B: used to be is now unmounted: drop it if it is untouched.
SCRATCH="$WORK/SCRATCH.DSK"
if [ -f "$SCRATCH" ]; then
  if [ -f "$EMPTY" ] && cmp -s "$SCRATCH" "$EMPTY"; then
    rm -f "$SCRATCH"
    echo "Removed the unused, untouched $SCRATCH"
  else
    echo "Note: $SCRATCH is no longer mounted but has been written to -- kept"
  fi
fi
