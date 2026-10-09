# tools/altairsim/upstream/ — where pristine's third-party tools came from

This directory is a local cache, gitignored apart from this README. It holds
the upstream archives and disk images that tools on
`tools/altairsim/pristine/CPM22SYS.DSK` were taken from. The tools
themselves are tracked only as part of that disk image.

`tools/altairsim/scripts/fetch_upstream.sh` recreates the cache:
- it downloads each file;
- it checks each one against the SHA-256s below and fails on any mismatch;
- it extracts the tools, uppercased, into `DRI/`.

Re-running it is cheap: files that are already present and correct are
kept.

## Files

| File | From | SHA-256 |
|---|---|---|
| `yazecpm3.zip` | <https://cpm.retropc.se/cpm/download/yazecpm3.zip>: YAZE-AG's CP/M 3 set, on the mirror of www.cpm.z80.de (the "Unofficial CP/M Web Site"), whose own certificate is self-signed | `0aca05ba29c7d7df3ca108fcd0809fb80d1bde1a28cf3695f968d1ef0887ecd4` |
| `Z80PACK-CPM3-2.DSK` | z80pack's `cpmsim/disks/library/cpm3-2.dsk` at commit `2ab004f8e578` (<https://github.com/udo-munk/z80pack>): CP/M 3 disk 2, an 8" IBM 3740 image (`cpmls -f ibm-3740`). Kept for reference only | `45164c4403d70fc2fd17e3184386014e35f61107a2fbf591cd106d3a5234f33e` |

Both were retrieved on 2026-10-08.

## DRI RMAC/LINK package (on the pristine disk since 2026-10-08)

All four tools come from `yazecpm3.zip` (`yaze-cpm3/*.com`):

| Tool | Version | Size | SHA-256 |
|---|---|---|---|
| `RMAC.COM` | RMAC 1.1 (patched; see below) | 13568 | `d3132c8e356d0c8e71b53757445e7ef89e55dfda9dbda11c48cf7ede6c2c40f3` |
| `LINK.COM` | LINK-80 1.31 | 15744 | `714115910168df0900a41698551d518c921fe8329dae78378756f2445a4dc175` |
| `LIB.COM` | LIB 1.1 | 7168 | `2a7d7214b675396abaabc42b653d14bb07be409d9639a2e890ed08b9ad3edac5` |
| `XREF.COM` | XREF 1.3 | 15488 | `75bb1b8cb9aa6474583b02befe6d31fb476c11109ee034a34f8eb737e13ced7a` |

`LINK.COM` is byte-identical on the z80pack disk. That disk has no
`LIB.COM` or `XREF.COM`.

**The two RMACs differ.** The z80pack disk's `RMAC.COM`
(`c83f1cac01c5c1ca1af6c61a3fd156c8a49a46f290bd1a9f176c36946bb0435a`) is the
unpatched release. The YAZE copy, the one used here, differs in 38 bytes:
- At 08DDH, `CPI 40H / CNZ 15E7H` becomes `ANI 0FCH / CALL 0128H`, and a
  jump near 08FBH is redirected to 012EH.
- New code sits in the formerly zeroed bytes at 0128H. It does
  `CPI 40H / CNZ 15E7H / RET`, then
  `LDA 350AH / ANI 3 / ORI 40H / CALL 2516H / JMP 1002H`.

  So the patch masks off two low bits before the 40H test, and adds a
  path that merges a 2-bit value from 350AH into an item type. That looks
  like a DRI fix to how RMAC classifies relocatable items. Its origin is
  not documented.
- The serial-number field (01A2H) is filled in as `654321`.
- A few trailing bytes that look like uninitialized buffer space also
  differ.

`MAC.COM` also differs between the two sets (10 bytes, including the
serial field). It is not taken from here, because the pristine disk
already has its own `MAC.COM`.

## GSX-80 runtime and GSXTEST, for software/ddcz (local only)

These files are for developing the CADzilla GSX driver. Unlike the DRI
tools above, **none of them goes onto the pristine disk.** They are `R`'d
onto the driver project's own `work/` disk only.

| File | From | SHA-256 |
|---|---|---|
| `gsx80-1.0.tgz` | <https://www.icl1900.co.uk/unix4fun/z80pack/ftp/gsx80-1.0.tgz>, Udo Munk's z80pack: GSX-80 1.0 on a CP/M 2.2 disk, with his xterm Tektronix driver | `4d928ff9873d9f3d79209fcfded321fc7dc80de0a0c0ab4b8fd9453b057f4e3d` |
| `GSX80-1.0.DSK` | the disk image in that archive (`disks/library/gsx80-1.0.dsk`), an 8" IBM 3740 image | (extracted) |
| `gsxtest.zip` | <https://seasip.info/Cpm/software/GSXTEST.ZIP>: John Elliott's GSXTEST 2, a GSX driver test program, built with RMAC + LINK-80 | `012c9f154a62c30d6e7e65c6c6c3c6ab716f9fa3564110a0e574ed586e4e9760` |

| `drgraph.tgz` | <https://www.icl1900.co.uk/unix4fun/z80pack/ftp/drgraph.tgz>, z80pack: DRI's DR Graph 1.0 (19 May 83), a GSX chart program, on a CP/M disk | `17c84b5b5c38d20f95ee2b2e8cbc1d54d09cc8aecf7b2f39635d2a9014c43627` |
| `DRGRAPH.DSK` | the disk image in that archive (`disks/library/drgraph.dsk`), an 8" IBM 3740 image | `be6b6056b4f39b81566a0f828790b11f6713583ac4832a63ef71f17b5b989595` |

All four were retrieved on 2026-10-08. `DRGRAPH/` holds DR Graph's files,
uppercased: `GRAPH.COM`, its overlays, `GRAPHY.MNU`, `GRAPHZ.TBL` and the
sample charts (`SAMPLE1`, ...: no file type, so `R` them one by one). Its own
`GSX.SYS`, `ASSIGN.SYS` and drivers are left out. DR Graph is DRI's and is
treated like GSX-80: local only. John Elliott updates GSXTEST from time to
time. A new upload fails its pin; check what changed, then move the pins
in `fetch_upstream.sh`.

Extracted into `GSX/`:
- **From the GSX disk:**
  - `GSX.SYS`: "GSX-80 1.0 15 Nov 82", the GDOS;
  - `GENGRAF.COM`, which attaches the GSX loader to a program;
  - `DEMOGRAF.COM`, a GENGRAF'd CBASIC demo;
  - `DDXTEK.FOR` and `XTEK.MAC`, Munk's driver source: a FORTRAN-80 body
    and an RMAC entry module. It is the reference for the CP/M-80 driver
    entry convention.
- **From gsxtest.zip:**
  - `GSXTEST.COM`, already GENGRAF'd;
  - its RMAC source `GSXTEST.ASM` and `SINES.ASM`;
  - its documentation `GSXTEST.TXT` (what each test screen should look
    like);
  - its licence, `GSXTEST.LIC`.

**Licences.**
- **GSX-80** (`GSX.SYS`, `GENGRAF.COM`) carries DRI's 1982 copyright. It is
  not part of the CP/M 3 distribution, and whether DRDOS, Inc.'s 2022 grant
  for "CP/M and its derivatives" covers it hasn't been settled. Keep it to
  this local cache and the driver project's `work/` disk.
- **DEMOGRAF** is from the same disk and gets the same treatment.
- **Munk's driver source** says "All Rights Granted".
- **GSXTEST** is under the zlib licence (`GSXTEST.LIC`).

## Licence

RMAC, LINK, LIB and XREF were shipped as part of the CP/M 3 (CP/M Plus)
distribution. The current licence is the July 2022 statement by Bryan
Sparks, President of DRDOS, Inc., the successor in interest to Digital
Research. It grants "a right to use, distribute, modify, enhance, and
otherwise make available in a nonexclusive manner CP/M and its
derivatives". It replaces the 2001 Lineo/Caldera email, which limited
distribution to the Unofficial CP/M Web Site. See
<http://www.cpm.z80.de/license.html>.

GSX-80 is a separate DRI product. Whether "CP/M and its derivatives"
covers it has not been settled here. Decide that before adding any GSX
files to the pristine disk.
