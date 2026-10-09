---
name: cadzilla-build-rmac
description: Builds, runs and debugs a CADzilla software project that uses Digital Research's relocating toolchain -- RMAC (RMAC 1.1) + LINK-80 (LINK 1.31), plus LIB and XREF -- inside CP/M 2.2 on altairsim: relocatable .ASM modules (CSEG/DSEG, PUBLIC/EXTRN, no ORG) assembled by RMAC and linked by DRI LINK into a .COM, or with LINK's [OP] option into a .PRL (page-relocatable, the format of GSX-80 device drivers), driven by the project's own <NAME>.SUB through the altairsim MCP server. Use this whenever the user wants to build, rebuild, run, test or debug a CADzilla project whose src/ has a <NAME>.SUB next to its .ASM modules (software/rhello, anything scaffolded with --toolchain rmac), make a .PRL or a GSX driver, link RMAC and M80 modules together, build a LIB library, or asks about RMAC, DRI LINK, LIB or XREF on this repo's CP/M. A single self-contained .ASM with ORG 0100H and no .SUB is the ASM.COM flow (cadzilla-build-asm); .MAC is cadzilla-build-m80; .Z88 is cadzilla-build-z88dk; .c is cadzilla-build-zcc.
---

# Build a CADzilla project with DRI RMAC + LINK

These projects are relocatable 8080 `.ASM` modules in `software/<name>/src/`.
They are assembled by DRI **RMAC** and linked by DRI **LINK-80**, all inside
CP/M 2.2 on altairsim. The project's tracked `src/<NAME>.SUB` lists the
build: one `RMAC` line per module, then the `LINK`.

- **What tells this flow apart from `cadzilla-build-asm`:** both use `.ASM`,
  but an RMAC project has the `.SUB`, uses `CSEG`/`DSEG` and `EXTRN`, and
  has no `ORG`.
- **Why it exists:** `LINK [OP]` writes a `.PRL`, the format of a GSX-80
  device driver, which Microsoft's L80 can't make.
- **Reference project:** `software/rhello`, with two modules (`RHELLO.ASM`
  calls `PRINT` in `PRINT.ASM`).

Background is in "The DRI RMAC/LINK toolchain" in `tools/altairsim/README.md`.

## 0. Before touching the emulator

- **Find the names.** The project directory is `software/<name>/`, in
  lowercase. The program is `<NAME>`, uppercase and at most 8 characters,
  and its build script is `src/<NAME>.SUB`. Read the `.SUB` to see the
  modules and the link line. Look rather than guess.
- **CR/LF.** Run
  `tools/altairsim/scripts/crlf.sh software/<name>/src/*.ASM software/<name>/src/*.SUB`
  after any host edit. It is idempotent.
  - An LF-only `.ASM` makes RMAC print garbage `S` and `E` error lines, a
    run of `^Z` characters and `NO SPACE`.
  - An LF-only `.SUB` breaks SUBMIT.
- **The project needs its own `work/`.** If `software/<name>/work/` is
  missing, create it with
  `tools/altairsim/scripts/sync_pristine.sh software/<name>/work`.
- **The tools must be on its disk.** RMAC, LINK, LIB and XREF were added to
  pristine on 2026-10-08. A `work/` copied before then lacks them, and
  `RMAC?` at the prompt is the symptom. Fix it without losing builds:
  1. run `tools/altairsim/scripts/fetch_upstream.sh`;
  2. on the booted machine, `SET hb0 HOSTDIR=<repo-root>/tools/altairsim/upstream/DRI`;
  3. `R` the four `.COM`s.
- The altairsim MCP tools must be loaded (`mcp__altairsim__run`). If they
  aren't, point the user at the README's "Starting a session" instead of
  guessing at setup.

## 1. Point the server at the project's own disk and boot

```
monitor {command: "SHOW MOUNTS"}            # what is mounted right now?
monitor {command: "CONFIG LOAD <repo-root>/software/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>", timeout_ms: 10000}
monitor {command: "SHOW MOUNTS"}            # drive0 must be this project's work/ disk
```

- **Never `CONFIG LOAD` or `MOUNT` anything under
  `tools/altairsim/pristine/`.** A `(write-protected ...)` mount means the
  wrong path is loaded. Fix the path, never the permissions.
- If another project's disks are still mounted, return that session to
  `A0>` and `UNMOUNT` its drives first.
- The prompt is `A0>`, not `A>`.

## 2. Assemble, link, run

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/src"}
run {input: "R *.*\r", until: "A0>", timeout_ms: 30000}       # every module + the .SUB
run {input: "SUBMIT <NAME>\r", timeout_ms: 120000}            # no until: stops when idle
run {input: "<NAME>\r", until: "A0>", timeout_ms: 20000}
```

- **`SUBMIT` is SuperSUB.** It echoes each line at an `A0>` prompt, so
  `until: "A0>"` would stop after the first line. Let the run stop on
  `idle`.
- **SUBMIT doesn't stop on an error**, so read the whole output.
  - Each `RMAC` prints its banner, then any error lines, then an address
    and `END OF ASSEMBLY`.
  - An error line starts with a one-letter flag in column 1, followed by
    the address, the code and the source line, e.g.
    `U0000 110000    X: LXI D,NOSUCH`. `U` means an undefined symbol, and
    a bad register name such as `MOV Q,A` is a `U` too.
  - The address before `USE FACTOR` is where the last segment ended, so it
    isn't a check that code was assembled. Read the `.PRN` if in doubt.
  - `LINK` prints its global symbols, then `CODE SIZE` and `DATA SIZE` with
    their address ranges. An `UNDEFINED SYMBOLS:` list means an `EXTRN`
    nobody `PUBLIC`s, or a module missing from the link line. LINK still
    finishes and prints the sizes, so treat it as a failed link.
- **The program's own console output is the proof it ran.** For rhello it
  is two lines: the welcome message, then
  `Linked by DRI LINK from two RMAC modules`.
- For a single change you can run the steps by hand instead of SUBMIT:
  `RMAC <MOD>` per changed module, then the `LINK` line from the `.SUB`.

### Other outputs

- **`.PRL`** (a GSX driver, an MP/M program): `LINK OUT=<MOD>,...[OP]`.
  - The file is a 256-byte header (bytes 1–2: the image length), then the
    image linked for **0100H**, then a relocation bitmap with one bit per
    byte, MSB first.
  - A set bit marks the high byte of a relocatable address. The loader adds
    (load page − 1) to each such byte.
  - The image is byte-identical to the `.COM` the same link makes, which
    makes a handy check after `W`-ing both back.
- **Library:** `LIB L=MOD1,MOD2` builds `L.REL`. `LINK MAIN,L[S]` searches
  it and loads only the modules that are needed.
- **Cross-reference:** `XREF <MOD>` reads `<MOD>.PRN` and `<MOD>.SYM` and
  writes `<MOD>.XRF`.
- **Mixing with Microsoft's tools works in both directions.** DRI LINK
  links M80 `.REL` files, and L80 links RMAC's. That's the route for F80
  (FORTRAN-80) or M80 code in a `.PRL`.

## 3. Pull the artifacts back

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/build"}
run {input: "W <NAME>.COM\r", until: "A0>"}         # binary -- NEVER with T (same for .PRL, .REL)
run {input: "W <NAME>.PRN T\r", until: "A0>"}       # and each other module's .PRN
run {input: "W <NAME>.SYM T\r", until: "A0>"}       # LINK's symbol table
monitor {command: "SET hb0 HOSTDIR=<repo-root>"}
```

## 4. Close the session (always, unless told to leave it open)

```
run {timeout_ms: 5000}                      # no input, no until -> stopped: "idle"
monitor {command: "UNMOUNT dsk0:drive0"}
monitor {command: "UNMOUNT dsk0:drive1"}
```

**Stopping on `A0>` is not the same as idle.** The BIOS writes its last
buffered track only after the prompt is printed. Unmounting before that
finishes leaves a half-written sector, and the next boot then says
`Bdos Err On A: Bad Sector`. Then:
- `tools/altairsim/scripts/check_dsk.py software/<name>/work/*.DSK` should
  say `ok`;
- `git status tools/altairsim/pristine` should be clean. If it isn't, stop
  and tell the user.

Report what was built and run, quote the console output, and say the
session was unmounted. `build/` and `work/` are gitignored. Don't commit
unless asked.

## RMAC / LINK gotchas

- **Relocatable source.** Use `CSEG`/`DSEG` and no `ORG`: LINK puts code at
  0100H and data after it. `END START` in the main module sets the entry
  point.
  - If `START` is the first byte of the code, the code starts at 0100H.
  - If it isn't, LINK puts a `JMP START` at 0100H and the code at 0103H,
    so `CODE SIZE` shows `(0103-...)`.
- **Global names: keep `PUBLIC`/`EXTRN` names to 6 characters**, the most a
  `.REL` file carries. M80 and L80 have the same limit.
- **Modules link in the order given.** Put the main module first on the
  `LINK` line, as `<NAME>.SUB` does.
- **RMAC's source type is `.ASM`.** `RMAC X` writes `X.REL`, `X.PRN` and
  `X.SYM` to the current drive.
- **Don't trust RMAC to catch everything.** A duplicated label assembled
  without a flag in testing. Check the `.PRN` when something odd happens.
- **No underscores in symbols.** ASM.COM silently resolves them to 0. RMAC
  hasn't been tested on this, so just avoid them.
- **`W ... T` on a `.COM`, `.PRL` or `.REL` corrupts it.** Text mode trims
  at the first `1AH` byte.
- CP/M uppercases everything typed at its prompt, so point `hb0 HOSTDIR` at
  the exact directory and type only bare file names.
- **Don't interrupt a disk operation.** If a `run` times out mid-RMAC,
  LINK, `R` or `W`, call `run` again with no input. Never `reset` or
  `CONFIG LOAD` mid-write. `sync_pristine.sh software/<name>/work` recovers
  a corrupted disk but discards everything built on it, so ask first.
