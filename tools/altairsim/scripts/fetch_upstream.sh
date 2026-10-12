#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
#
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
# and, for the GSX driver work (software/rmac/ddcz) -- never tracked, never put on
# pristine, since GSX-80's licence status is unsettled (upstream/README.md):
#
#   upstream/gsx80-1.0.tgz       z80pack's GSX-80 1.0 disk, as downloaded
#   upstream/GSX80-1.0.DSK       the disk image out of it (cpmls -f ibm-3740)
#   upstream/gsxtest.zip         John Elliott's GSXTEST 2 (zlib licence)
#   upstream/GSX/                the files R'd onto a work disk: GSX.SYS,
#                                GENGRAF.COM, DEMOGRAF.COM, GSXTEST.COM, plus
#                                reference sources (DDXTEK.FOR, XTEK.MAC,
#                                GSXTEST.ASM, SINES.ASM, GSXTEST.TXT)
#   upstream/drgraph.tgz         z80pack's DR Graph disk, as downloaded
#   upstream/DRGRAPH.DSK         the disk image out of it
#   upstream/DRGRAPH/            DR Graph's program, overlays, menu and table,
#                                and its sample charts (no file type: SAMPLE1 ...)
#   upstream/drdraw.tgz, DRDRAW.DSK, DRDRAW/
#                                the same for DRI's DR Draw, plus its own GSX.SYS
#                                (GSX-80 1.1). It needs CP/M Plus, a Z80 and about
#                                61K of TPA, so it doesn't run here yet
#                                (software/rmac/ddcz/README.md)
#
# Extracting from the GSX disk image needs cpmtools (cpmcp).
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

GSX_URL="https://www.icl1900.co.uk/unix4fun/z80pack/ftp/gsx80-1.0.tgz"
GSX_SHA="4d928ff9873d9f3d79209fcfded321fc7dc80de0a0c0ab4b8fd9453b057f4e3d"
GSX_DSK_MEMBER="disks/library/gsx80-1.0.dsk"
# John Elliott updates GSXTEST now and then; a new upload fails this pin --
# check what changed, then move the pin (and the GSXTEST lines below).
GSXTEST_URL="https://seasip.info/Cpm/software/GSXTEST.ZIP"
GSXTEST_SHA="012c9f154a62c30d6e7e65c6c6c3c6ab716f9fa3564110a0e574ed586e4e9760"

DRG_URL="https://www.icl1900.co.uk/unix4fun/z80pack/ftp/drgraph.tgz"
DRG_SHA="17c84b5b5c38d20f95ee2b2e8cbc1d54d09cc8aecf7b2f39635d2a9014c43627"
DRG_DSK_MEMBER="disks/library/drgraph.dsk"
DRG_DSK_SHA="be6b6056b4f39b81566a0f828790b11f6713583ac4832a63ef71f17b5b989595"
DRD_URL="https://www.icl1900.co.uk/unix4fun/z80pack/ftp/drdraw.tgz"
DRD_SHA="68f7960e43343437c7be27dfd9ffa459b019cba3e260a616648e630542a2f345"
DRD_DSK_MEMBER="disks/library/drdraw.dsk"
DRD_DSK_SHA="5a0553599c8ec2e04d92837a01e73988acb4cbe06725518f9f38d97234d250de"

# Files for upstream/GSX/: CP/M name, name on the GSX disk, SHA-256
gsxdisk=(
  "GSX.SYS      gsx.sys      efffe2b551cc80e520cc2b939976a695e600658ae1cc366791d16e1ac6f896a4"
  "GENGRAF.COM  gengraf.com  211b52540ec06d792f9b930e018634e4d2e1cb78c11f355df695e29335ece6af"
  "DEMOGRAF.COM demograf.com 64d3eeec4066c5dbf972f0a25ee70abd5454c83080eee42e8dcbf700bbfbe327"
  "DDXTEK.FOR   ddxtek.for   43404aae2dca5523167a67e7f2fdccbecea665d70236ea978f81455b75dd4ea7"
  "XTEK.MAC     xtek.mac     9858c8c5474f30fdb0423e24a9e23622a457fce4d982b298d515b6b5ae531590"
)
# ... and from gsxtest.zip: CP/M name, name in the zip, SHA-256
gsxtest=(
  "GSXTEST.COM gsxtest.com 8b8a27753d4a0df5791a5abecb309eccf5516a56e2a2a95021e482e416b704b9"
  "GSXTEST.ASM gsxtest.asm 5026ffa63eb0d737cccdbc91b10a418e67c5cd86fe0a86449efa3a6134dca97f"
  "SINES.ASM   sines.asm   a844a49877ac0450e4fcfb0a72fc1056425e233ba51c0aac53df09a8dd18ddb8"
  "GSXTEST.TXT gsxtest.txt d1be58b47f1d9718526f9b34d884799aa8632744a7d425bbdab73fa78b6c936f"
  "GSXTEST.LIC COPYING     2744c3723a324431a306621ee323b94dce746b07d273cb9c1f3ca97b0e7c0de6"
)

sha() { sha256sum "$1" | cut -d' ' -f1; }

# check <file> <sha256> <what>: move <file>.part into place if it's right
check() {
  local dest="$1" want="$2" what="$3"
  if [ "$(sha "$dest.part")" != "$want" ]; then
    echo "error: $what: SHA-256 $(sha "$dest.part"), expected $want" >&2
    rm -f "$dest.part"
    exit 1
  fi
  mv -f "$dest.part" "$dest"
}

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
  check "$dest" "$want" "$member in yazecpm3.zip"
  echo "  ok      DRI/$name"
done

# GSX-80 1.0 and GSXTEST, for software/rmac/ddcz
if ! command -v cpmcp >/dev/null; then
  echo "error: cpmcp not found -- install cpmtools (it reads the GSX-80 disk image)" >&2
  exit 1
fi
mkdir -p "$UP/GSX"
fetch "$GSX_URL" "$UP/gsx80-1.0.tgz" "$GSX_SHA"
fetch "$GSXTEST_URL" "$UP/gsxtest.zip" "$GSXTEST_SHA"
tar -xzOf "$UP/gsx80-1.0.tgz" "$GSX_DSK_MEMBER" > "$UP/GSX80-1.0.DSK"
echo "  ok      GSX80-1.0.DSK"
for t in "${gsxdisk[@]}"; do
  read -r name member want <<<"$t"
  dest="$UP/GSX/$name"
  rm -f "$dest.part"
  cpmcp -f ibm-3740 "$UP/GSX80-1.0.DSK" "0:$member" "$dest.part"
  check "$dest" "$want" "$member on GSX80-1.0.DSK"
  echo "  ok      GSX/$name"
done
for t in "${gsxtest[@]}"; do
  read -r name member want <<<"$t"
  dest="$UP/GSX/$name"
  unzip -p "$UP/gsxtest.zip" "$member" > "$dest.part"
  check "$dest" "$want" "$member in gsxtest.zip"
  echo "  ok      GSX/$name"
done

# DR Graph and DR Draw (GSX-80 applications, to try the driver with):
# everything on their disks but their own drivers and ASSIGN.SYS, which the
# driver work replaces, and their GSX.SYS unless <keep> is "gsx". DR Graph is
# run with GSX-80 1.0 from GSX/; DR Draw's GSX loader is 1.1's and wants its
# own GSX.SYS (1.1). The disk images are pinned; the files come off them as
# they are.
# app <NAME> <url> <sha> <member> <dsk sha> [<keep>]
app() {
  local name="$1" url="$2" want="$3" member="$4" dwant="$5" keep="${6:-}" tgz dsk f n=0 cpm
  tgz="$UP/$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]').tgz"
  dsk="$UP/$name.DSK"
  mkdir -p "$UP/$name"
  fetch "$url" "$tgz" "$want"
  tar -xzOf "$tgz" "$member" > "$dsk.part"
  check "$dsk" "$dwant" "$member in $(basename "$tgz")"
  echo "  ok      $name.DSK"
  for f in $(cpmls -f ibm-3740 "$dsk" | grep -v '^[0-9]*:$'); do
    case "$f" in assign.sys|*.prl) continue ;; esac
    if [ "$f" = gsx.sys ] && [ "$keep" != gsx ]; then continue; fi
    cpm="$(printf '%s' "$f" | tr '[:lower:]' '[:upper:]')"
    rm -f "$UP/$name/$cpm"
    cpmcp -f ibm-3740 "$dsk" "0:$f" "$UP/$name/$cpm"
    n=$((n + 1))
  done
  echo "  ok      $name/ ($n files)"
}
app DRGRAPH "$DRG_URL" "$DRG_SHA" "$DRG_DSK_MEMBER" "$DRG_DSK_SHA"
app DRDRAW "$DRD_URL" "$DRD_SHA" "$DRD_DSK_MEMBER" "$DRD_DSK_SHA" gsx
