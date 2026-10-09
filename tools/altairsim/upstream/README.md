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
