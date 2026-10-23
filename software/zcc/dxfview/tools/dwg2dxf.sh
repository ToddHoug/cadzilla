#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Convert AutoCAD drawings (.dwg, any release the converter reads) to
# AutoCAD Release 10 DXF for DXFVIEW, as
#
#     software/zcc/dxfview/dxf/<NAME>.DXF
#
# NAME is the drawing's name, uppercased (a CP/M 8.3 name, 8 characters at
# most), and the file has CP/M's CR/LF line endings, ready for R onto the
# project's CP/M disk. An existing .DXF of that name is replaced.
#
# The conversion is done by the Open Design Alliance's ODA File Converter,
# which is free but not open source, so it is not part of this repo:
# download the Linux AppImage from
# https://www.opendesign.com/guestfiles/oda_file_converter and put it at
# ~/Applications/ODAFileConverter.AppImage (or set ODAFC to its path).
# It is a Qt program and needs an X display even when run from a script:
# with no DISPLAY, it is run under xvfb-run if that is installed.
#
# Usage: dwg2dxf.sh <file.dwg>...
set -euo pipefail

ODAFC="${ODAFC:-$HOME/Applications/ODAFileConverter.AppImage}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/dxf"

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file.dwg>..." >&2
  exit 1
fi
if [ ! -x "$ODAFC" ]; then
  echo "error: no ODA File Converter at $ODAFC (see the comment at the top of $0)" >&2
  exit 1
fi
RUN=()
if [ -z "${DISPLAY:-}" ]; then
  if command -v xvfb-run >/dev/null; then
    RUN=(xvfb-run -a)
  else
    echo "error: the ODA File Converter needs an X display: set DISPLAY or install xvfb-run" >&2
    exit 1
  fi
fi

# The converter takes a directory, not files: give it one holding only the
# drawings named here.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir "$TMP/in" "$TMP/out"
for f in "$@"; do
  base="$(basename "$f")"
  name="${base%.*}"
  if [[ ! "${name^^}" =~ ^[A-Z0-9_-]{1,8}$ ]]; then
    echo "error: '$name' is not a CP/M name (8 letters/digits at most): rename $f first" >&2
    exit 1
  fi
  cp "$f" "$TMP/in/"
done

# in out version type recurse audit
"${RUN[@]}" "$ODAFC" "$TMP/in" "$TMP/out" ACAD10 DXF 0 1 >/dev/null 2>&1 || true

mkdir -p "$OUT"
RC=0
for f in "$@"; do
  base="$(basename "$f")"
  name="${base%.*}"
  dxf="$(find "$TMP/out" -maxdepth 1 -iname "$name.dxf" | head -1)"
  if [ -z "$dxf" ]; then
    echo "error: $base was not converted" >&2
    RC=1
    continue
  fi
  # $ACADVER is the HEADER's first variable: AC1006 is Release 10
  ver="$(awk '{ sub(/\r$/, "") } $0 == "$ACADVER" { getline; getline; sub(/\r$/, ""); print; exit }' "$dxf")"
  if [ "$ver" != "AC1006" ]; then
    echo "error: $base converted as $ver, not AC1006 (Release 10)" >&2
    RC=1
    continue
  fi
  dst="$OUT/${name^^}.DXF"
  sed 's/\r*$/\r/' "$dxf" > "$dst"
  echo "$f -> ${dst#"$PWD"/}  ($(wc -c < "$dst") bytes, $ver)"
done
exit "$RC"
