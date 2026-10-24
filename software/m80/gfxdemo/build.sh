#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
# Build this project -- its work/ machine and disks, and its program -- with
# tools/build.sh. Options: --clean (re-sync work/ from pristine first),
# --verbose (echo the CP/M session).
exec "$(dirname "${BASH_SOURCE[0]}")/../../../tools/build.sh" "$(dirname "${BASH_SOURCE[0]}")" "$@"
