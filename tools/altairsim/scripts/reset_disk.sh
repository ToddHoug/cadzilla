#!/usr/bin/env bash
# Reset the altairsim working CP/M disk back to the pristine master.
#
# The working disk (tools/altairsim/work/cpm22b23-56k.dsk) is shared scratch
# space: every project's ASM/LOAD writes to the same image, so free space
# keeps shrinking as more projects get built on it. Each project's real,
# permanent output already lives on the host (software/<project>/src/ and
# .../build/), so the disk itself is disposable -- run this before starting
# work on a NEW project, or switching to a DIFFERENT existing one, rather
# than letting it keep accumulating. No need to run it to keep iterating on
# the same project within a session.
#
# This only resets the HOST FILE. If a disk is currently mounted in a
# running altairsim MCP session, UNMOUNT it first (`monitor {command:
# "UNMOUNT dsk0:drive0"}`) so the file isn't overwritten out from under a
# live mount, then after this script runs, MOUNT the fresh copy back and do
# a clean reboot -- see tools/altairsim/README.md.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PRISTINE="$REPO_ROOT/tools/altairsim/pristine/cpm22b23-56k.dsk"
WORK="$REPO_ROOT/tools/altairsim/work/cpm22b23-56k.dsk"

if [ ! -f "$PRISTINE" ]; then
  echo "error: $PRISTINE not found" >&2
  exit 1
fi

mkdir -p "$(dirname "$WORK")"
cp "$PRISTINE" "$WORK"
echo "Reset $WORK from pristine."
