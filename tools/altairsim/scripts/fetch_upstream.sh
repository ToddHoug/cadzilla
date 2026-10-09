#!/usr/bin/env bash
# Fetch the upstream archives and disk images that third-party CP/M tools on
# the pristine system disk were taken from, into tools/altairsim/upstream/,
# and extract those tools there.
#
# upstream/ is a local, gitignored cache: only its README.md (provenance,
# hashes, licence) is tracked. The tools themselves are tracked only as part
# of pristine/CPM22SYS.DSK. This script recreates the cache on a fresh clone,
# for re-checking the tools or for R-ing them onto an existing project's
# work/ disk (see "The DRI RMAC/LINK toolchain" in tools/altairsim/README.md).
#
# Every download and every extracted tool is checked against a pinned
# SHA-256; any mismatch is an error. Already-present files that match are
# kept, so re-running is cheap.
#
#   upstream/yazecpm3.zip        YAZE-AG's CP/M 3 set (www.cpm.z80.de mirror)
#   upstream/Z80PACK-CPM3-2.DSK  z80pack's CP/M 3 disk 2, kept for reference
#                                (8" IBM 3740 image: cpmls -f ibm-3740)
#   upstream/DRI/RMAC.COM LINK.COM LIB.COM XREF.COM
#                                extracted from yazecpm3.zip, uppercased
#
# Usage: fetch_upstream.sh
set -euo pipefail

if [ $# -ne 0 ]; then
  echo "Usage: $0" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
UP="$REPO_ROOT/tools/altairsim/upstream"

YAZE_URL="https://cpm.retropc.se/cpm/download/yazecpm3.zip"
YAZE_SHA="0aca05ba29c7d7df3ca108fcd0809fb80d1bde1a28cf3695f968d1ef0887ecd4"
# Pinned to the z80pack commit that last changed the image (2024-07-24)
Z80PACK_URL="https://raw.githubusercontent.com/udo-munk/z80pack/2ab004f8e5780531ecda08bf567c9e136030067a/cpmsim/disks/library/cpm3-2.dsk"
Z80PACK_SHA="45164c4403d70fc2fd17e3184386014e35f61107a2fbf591cd106d3a5234f33e"

# The tools taken from yazecpm3.zip: CP/M name, name in the zip, SHA-256
tools=(
  "RMAC.COM yaze-cpm3/rmac.com d3132c8e356d0c8e71b53757445e7ef89e55dfda9dbda11c48cf7ede6c2c40f3"
  "LINK.COM yaze-cpm3/link.com 714115910168df0900a41698551d518c921fe8329dae78378756f2445a4dc175"
  "LIB.COM  yaze-cpm3/lib.com  2a7d7214b675396abaabc42b653d14bb07be409d9639a2e890ed08b9ad3edac5"
  "XREF.COM yaze-cpm3/xref.com 75bb1b8cb9aa6474583b02befe6d31fb476c11109ee034a34f8eb737e13ced7a"
)

sha() { sha256sum "$1" | cut -d' ' -f1; }

# fetch <url> <dest> <sha256>: download unless dest is already there and right
fetch() {
  local url="$1" dest="$2" want="$3"
  if [ -f "$dest" ] && [ "$(sha "$dest")" = "$want" ]; then
    echo "  ok      $(basename "$dest")"
    return
  fi
  curl -sSfL -o "$dest.part" "$url"
  if [ "$(sha "$dest.part")" != "$want" ]; then
    echo "error: $url: SHA-256 $(sha "$dest.part"), expected $want" >&2
    rm -f "$dest.part"
    exit 1
  fi
  mv -f "$dest.part" "$dest"
  echo "  fetched $(basename "$dest")"
}

mkdir -p "$UP/DRI"
echo "Upstream cache $UP:"
fetch "$YAZE_URL" "$UP/yazecpm3.zip" "$YAZE_SHA"
fetch "$Z80PACK_URL" "$UP/Z80PACK-CPM3-2.DSK" "$Z80PACK_SHA"

for t in "${tools[@]}"; do
  read -r name member want <<<"$t"
  dest="$UP/DRI/$name"
  unzip -p "$UP/yazecpm3.zip" "$member" > "$dest.part"
  if [ "$(sha "$dest.part")" != "$want" ]; then
    echo "error: $member in yazecpm3.zip: SHA-256 $(sha "$dest.part"), expected $want" >&2
    rm -f "$dest.part"
    exit 1
  fi
  mv -f "$dest.part" "$dest"
  echo "  ok      DRI/$name"
done
