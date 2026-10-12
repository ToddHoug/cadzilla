#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Give text files CP/M's CR/LF line endings, in place. Running it again on a
# file that already has them changes nothing.
#
# CP/M's assemblers (ASM.COM, M80.COM) and SUBMIT need CR/LF. An LF-only
# source assembles to nothing at all, with no error -- and files written by an
# ordinary editor (or the Write tool) on this host are LF-only. Run this on
# every .ASM/.MAC/.INC/.SUB before R-ing it onto a CP/M disk.
#
# Usage: crlf.sh <file>...
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file>..." >&2
  exit 1
fi

for f in "$@"; do
  sed -i 's/\r*$/\r/' "$f"
done
