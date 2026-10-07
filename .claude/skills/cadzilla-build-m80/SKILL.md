---
name: cadzilla-build-m80
description: Builds and runs CADzilla programs with the Microsoft M80/L80 toolchain and the shared czgfx graphics library -- rebuilding and releasing the czgfx library disk when its sources changed, then assembling a consumer project's <NAME>.MAC with M80, linking it against the czgfx release it pins with SUBMIT B:CZLINK, running it and pulling the .COM/.PRN back -- all by driving the altairsim MCP server. Use this whenever the user wants to build, run, test or debug a CADzilla project whose source is a .MAC file (software/gfxdemo, software/czgfx, anything scaffolded with --toolchain m80), change or extend the czgfx library (new primitive, new macro, new module), or asks how to share code/macros between CADzilla programs. For single-file .ASM projects (hello, firstdraw, drawdemo) use cadzilla-build-asm; for .Z88 projects (z88dk host cross-assembler, 8080/8085/Z80) use cadzilla-build-z88dk.
---

# Build with M80/L80 and the czgfx library

The pieces (full background is in `tools/altairsim/README.md`, "The M80/L80
toolchain", and in `software/czgfx/README.md`):

- **`software/czgfx/`** is the graphics library. Its sources are in `src/`
  (`CZGFX.INC`, `CZ*.MAC`, `CZBUILD.SUB`, `CZLINK.SUB`, `CZCHK.MAC`). Its
  fourteen modules are combined with **LIB80** into one library, `CZGFX.REL`.
  That library, the header and `CZLINK.SUB` go onto the **build disk**
  `software/czgfx/libdisk/CZGFXLIB.DSK`, which czgfx's own `work/` mounts
  **writable** as drive 1 (B:). `software/czgfx/tools/release.sh`
  snapshots it as a tracked, never-changed **release**,
  `software/czgfx/releases/CZGFXLIB-<version>.DSK`, named by `CZVERS` in
  `CZGFX.INC`.
- **Consumer projects** (`software/gfxdemo` is the example) pin a release
  in `software/<name>/czgfx.version`. Each mounts **its own copy**,
  `work/CZGFXLIB-<version>.DSK`, as **B:, read-only**. They
  `INCLUDE B:CZGFX.INC`, and link with `SUBMIT B:CZLINK <NAME>`, which
  is `L80 <NAME>,B:CZGFX/S,<NAME>/N/E`. L80's library search loads only
  the modules the program uses.
- **A czgfx change reaches a consumer only when the consumer's pin moves.**
  Don't rebuild or relink consumers just because the library changed.

Only one machine runs in the MCP server at a time. Finish one machine
before you `CONFIG LOAD` the next: do a `run` with no input and no `until`
that ends `stopped: "idle"`, then UNMOUNT both drives. Stopping on the
`A0>` prompt isn't enough, because the BIOS writes its last track after the
prompt is printed; see step 3.

## 0. Preflight (host side)

1. **Names.** The project directory is `software/<name>/`. The source is
   `src/<NAME>.MAC`, uppercase and at most 8 characters. Look in `src/`
   rather than guessing.
2. **The project must be wired to the library.**
   - `software/<name>/work/` must exist. If not, run
     `tools/altairsim/scripts/sync_pristine.sh software/<name>/work`.
   - It must have a pin, `software/<name>/czgfx.version` (e.g. `1.0`, or
     `dev` for the current build disk).
   - Its `cadzilla.toml` drive 1 must mount `CZGFXLIB-<version>.DSK`, a
     file in `work/` itself, with `readonly = true`. If it doesn't (for
     example after `sync_pristine.sh --machine-only`, or after a pin
     change), run `tools/altairsim/scripts/attach_libdisk.sh software/<name>/work`.
     A `dev` pin needs that run again after every library rebuild, to
     refresh the copy.
   - czgfx itself uses `attach_libdisk.sh --writable software/czgfx/work`
     (its build disk, no pin).
   - **czgfx's work disk must have LIB80.COM.** It's on the pristine disk
     from 2026-09-24. An older `software/czgfx/work` doesn't have it, and
     CZBUILD's `LIB80` lines then fail with `LIB80?`. To fix that:
     1. run `sync_pristine.sh software/czgfx/work`; it only discards build
        intermediates
     2. run `attach_libdisk.sh --writable software/czgfx/work` again
     Consumers need only M80 and L80, which every work disk has.
3. **CR/LF.** Run `tools/altairsim/scripts/crlf.sh` on every source you're
   about to `R`: the project's `src/*.MAC`, plus `software/czgfx/src/*`
   when rebuilding the library. It is idempotent. Files written on the host
   are LF-only, and LF-only source silently assembles to nothing.
4. **Only when working on czgfx itself (or a `dev` pin): is the build disk
   stale?** Check whether it is missing, or any czgfx source is newer:
   ```bash
   find software/czgfx/src -newer software/czgfx/libdisk/CZGFXLIB.DSK -type f
   ```
   If so, do step 1. A consumer pinned to a release never needs this. It
   builds against its own copy of that release.
5. The altairsim MCP tools must be loaded (`mcp__altairsim__run`). If they
   aren't, point the user at the README's "Starting a session".

**Pristine rule:** never `CONFIG LOAD` or `MOUNT` anything under
`tools/altairsim/pristine/`. Use only a project's own `work/`.

## 1. Rebuild the library (czgfx's own machine)

```
monitor {command: "CONFIG LOAD <repo-root>/software/czgfx/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>", timeout_ms: 10000}
monitor {command: "SHOW MOUNTS"}
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/czgfx/src"}
run {input: "R *.*\r", until: "A0>", timeout_ms: 30000}
run {input: "SUBMIT CZBUILD\r", timeout_ms: 180000}
```

- **Check `SHOW MOUNTS`.** drive0 must be `CPM22SYS.DSK` (in
  `czgfx/work`), and drive1 must be `../libdisk/CZGFXLIB.DSK` without
  `(write-protected)`.
- **Don't use `until: "A0>"` on a SUBMIT.** SuperSUB echoes every line at
  an `A0>` prompt, so the call would stop after the first line. Leave
  `until` off, and the call stops when the guest goes idle at the end.
- **Check the CZBUILD output:**
  - every `M80` line is followed by `No Fatal error(s)`
  - `LIB80 CZGFX/U/E` prints **nothing**. If it prints
    `Unsatisfied external request(s):` and a list of names, a module is
    missing from the `LIB80 CZGFX=...` line.
  - the final L80 link of `CZCHK` (through `B:CZLINK`) prints no
    `?Undefined` and no `%Mult. Def.`
  - `CZCHK` expands every macro and references every entry point, so a
    clean link means the published header and modules agree.
- Pull the artifacts back, then close this machine:
  ```
  monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/czgfx/build"}
  run {input: "W *.REL\r", until: "A0>", timeout_ms: 20000}       # binary
  run {input: "W *.PRN T\r", until: "A0>", timeout_ms: 30000}
  run {input: "DIR B:\r", until: "A0>"}      # CZGFX.REL, CZGFX.INC, CZLINK.SUB
  run {timeout_ms: 5000}                      # idle: lets the BIOS finish its last write
  monitor {command: "UNMOUNT dsk0:drive0"}
  monitor {command: "UNMOUNT dsk0:drive1"}
  ```
- **Scan the `.PRN`s for error flags.** M80 marks a bad line with a letter
  in column 1:
  ```bash
  for f in software/czgfx/build/*.PRN; do tr -d '\r' <"$f" | grep -nE '^[A-Z%?]' | grep -vE ':(Macros|Symbols|No Fatal)'; done
  ```
  Apart from the macro-name rows of the symbol table, this should print nothing.

## 2. Build and run the consumer (its own machine)

```
monitor {command: "CONFIG LOAD <repo-root>/software/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>", timeout_ms: 10000}
monitor {command: "SHOW MOUNTS"}   # drive1 = CZGFXLIB-<version>.DSK (write-protected)
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/src"}
run {input: "R <NAME>.MAC\r", until: "A0>", timeout_ms: 15000}
run {input: "M80 <NAME>,<NAME>=<NAME>\r", until: "A0>", timeout_ms: 60000}
run {input: "SUBMIT B:CZLINK <NAME>\r", timeout_ms: 60000}
run {input: "<NAME>\r", until: "A0>", timeout_ms: 30000}
```

- **A multi-module project** assembles each module with its own `M80`
  line. Then link the main module with L80 directly, listing the
  project's own modules and then `CZLINK`'s library list:
  `L80 MAIN,PART2,B:CZGFX/S,MAIN/N/E`.
- **Link map.** `SUBMIT B:CZLINK <NAME> /M` passes `/M` as `$2`, and L80
  prints the map of loaded globals. After a map, L80 waits at its `*`
  prompt even though `/E` is on the line, so send `run {input: "/E\r"}`
  to finish the link.
- **Link check.** The L80 summary `[start end pages]` should show no
  `?Undefined`. A program that doesn't use a module doesn't get it: the
  link is smaller, with no error. For example, a GINIT + GBOX program has
  no `CZPLL`/`CZPLG` in its map.
- **Library symbols outside the macros:** write them `NAME##`
  (`CALL CZLDW##`, `LHLD CZXMAX##`). Don't `EXTRN` library names you don't
  use, because M80 turns every `EXTRN` into a link request and L80 then
  loads that module whether anything calls it or not.
- **Checking the run:**
  - the program's console output should appear
  - graphics draw in the altairsim window, which the user sees
  - `board_get cad0` should show `status` with CER (80H) clear, `mode`
    matching the project's `machine.toml` (1024x768 unless it says
    otherwise), `picture` as that mode's full size `at (0,0)` (e.g.
    `1024x768 at (0,0)`), and `wiring` as `ok`. A picture that's smaller
    or offset means the `GINIT` descriptor and the strap disagree — see
    "Display resolution" in `tools/altairsim/README.md`
- **Key waits.**
  - Type a key with `run {input: " "}`.
  - To stop mid-way, match `until` on unique prompt text.
  - An ESC can't be typed through the `input` string, so step to the end
    with ordinary keys instead.
- **Resolution.** The monitor strap comes from the machine file: pristine's
  1024x768, or the project's own `software/<name>/machine.toml` overlay,
  which `sync_pristine.sh` appends to `work/cadzilla.toml`. The program's
  `GINIT` must name the matching descriptor (`CZM640`, `CZM800`, `CZM1K`).
  To change it for good, edit `machine.toml` and the `GINIT`, then
  `sync_pristine.sh --machine-only software/<name>/work` and
  `attach_libdisk.sh software/<name>/work` again before the `CONFIG LOAD`.
  To try another mode for one session only, `monitor {command: "SET cad0
  mode=800x600"}` (it lasts until the next `CONFIG LOAD`). `board_set` may
  report a malformed result even though the change took, so confirm it
  with `SHOW cad0`.
- Pull the artifacts back:
  ```
  monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/build"}
  run {input: "W <NAME>.COM\r", until: "A0>"}        # binary -- NEVER with T
  run {input: "W <NAME>.PRN T\r", until: "A0>"}
  monitor {command: "SET hb0 HOSTDIR=<repo-root>"}
  ```

## 3. Close out (always, unless told to leave it open)

- `run {timeout_ms: 5000}`, with no input and no `until`, must report
  `stopped: "idle"`
- `UNMOUNT dsk0:drive0` and `UNMOUNT dsk0:drive1`
- `tools/altairsim/scripts/check_dsk.py software/<name>/work/*.DSK` must say
  `ok` for every image (for czgfx itself, add
  `software/czgfx/libdisk/CZGFXLIB.DSK`)
- confirm `git status tools/altairsim/pristine` is clean; if it isn't, stop
  and tell the user
- a consumer mounts its library copy read-only, so the copy's modification
  time shouldn't change during a consumer session

Report what was built (library rebuilt or not), quote the console output,
and say the drives were unmounted. `build/`, `work/` and `libdisk/` are
gitignored; `releases/` and each project's `czgfx.version` are tracked.
Don't commit unless asked.

## Changing the library

`software/czgfx/README.md` has the API and the extension recipe. In short:

- **New routine:** `PUBLIC` it in its module, optionally add a `G...`
  macro that calls it as `NAME##`, and exercise it in `CZCHK.MAC`. The
  header has no `EXTRN` block and must not get one.
- **New module:**
  1. Create `CZxxxx.MAC`, starting with `INCLUDE CZGFX.INC`, its
     `PUBLIC`s, and `EXTRN`s only for what it calls.
  2. Add its `M80` line to `CZBUILD.SUB`.
  3. Insert it into the `LIB80 CZGFX=...` list there, after every module
     that calls it and before every module it calls, because L80 searches
     the library in one pass. `LIB80 /U` flags a mistake. `CZLINK.SUB`
     doesn't change.
- Then rebuild the library (step 1). To try the change in a consumer
  before releasing it, pin that consumer to `dev`.
- **Releasing.**
  1. Raise `CZVERS` in `CZGFX.INC` (major high byte, minor low byte).
  2. Rebuild (step 1).
  3. Run `software/czgfx/tools/release.sh`. It refuses a stale build disk
     or an existing version.
  4. `git add` the new `releases/CZGFXLIB-<version>.DSK`.
- **Moving a consumer to the new release.** Do this only for the consumers
  the user wants moved:
  1. edit its `czgfx.version`;
  2. run `attach_libdisk.sh` on its `work/`;
  3. rebuild and relink it (step 2).

  A `.COM` contains the library code it was linked with, so the other
  consumers stay on what they pinned.

## M80/L80 gotchas (all confirmed on this disk: M80/L80 3.44)

- **Globals are 6 characters.** L80 truncates `PUBLIC`/`EXTRN` names, so
  `LONGNAME1` and `LONGNAME2` collide as `%Mult. Def. Global LONGNA`.
  Keep global names to 6 characters or fewer. Keep local labels short too,
  following the repo's existing style.
- **Every `EXTRN` is a link request.** M80 emits an `EXTRN` even when
  nothing uses it, and L80 loads the defining module. Tested: an unused
  `EXTRN CZPLL` added CZPOLY's 51 bytes. Use `NAME##` for library
  references.
- **LIB80:**
  - `LIB80 LIB=A,B,C/E` builds a library
  - `LIB80 LIB/L/E` lists its modules, entry points and cross-references
  - `LIB80 LIB/U/E` lists unsatisfied externals, and prints nothing when
    the library is complete
  - it runs silently on success
- **`M80 <rel>,<prn>=<src>`.** The default source extension is `.MAC`, and
  `No Fatal error(s)` is the success line.
- **Relocatable code.** Use `CSEG` with no `ORG`; L80 puts the `.COM` at
  0100H with a jump to the `END <label>` entry.
- **Macro arguments.**
  - An argument containing spaces or commas goes in `<...>`, as in
    `GCOLOR <(N MOD 8)*32>` or `GPOLY <x,y,...>`.
  - `IFNB <ARG>` tests for a blank argument.
  - `LOCAL` gives unique labels per expansion. Never use `SET` for a label
    that is forward-referenced inside a macro: its value leaks from the
    previous expansion.
  - `REPT` together with `N SET N+1` unrolls at assembly time.
- `.XLIST`/`.LIST` inside `CZGFX.INC` keep the header out of every
  listing, while macro expansions still list (`+` lines).
- **SUBMIT is SuperSUB V1.1.** It reads a `.SUB` from `B:`, supports
  `$1`/`$2`, and a `SUBMIT` on the last line of a `.SUB` works (chaining).
- **Never write to B: from a consumer.** It is write-protected, and the
  guest isn't told; writes are simply refused. Library changes happen
  only on czgfx's machine.
- **Read keys with BDOS function 1, not 6.** When function 9 print output is
  mixed with function 6 input, a key typed while text is still printing is
  swallowed into the BDOS buffer and turns up later at the CCP prompt.
- **Idle before unmount.** This CP/M BIOS keeps the
last track it wrote in a RAM buffer, and writes it to the disk only once
the CCP waits for console input, which happens *after* the `A0>` prompt is
printed. A `run` that stopped on `until: "A0>"` can therefore still have
that write outstanding. Unmounting then either loses it, or cuts it short
halfway through a sector, and the next boot says
`Bdos Err On A: Bad Sector`. This has happened to `software/gfxdemo/work`.
So before any `UNMOUNT`, `CONFIG LOAD` or `reset`, run once with no input
and no `until`, and check that it reports `stopped: "idle"`.
- **CR/LF, uppercase names, and the `W` rules are the same as for ASM.**
  Never use `T` on a `.COM`, type only bare file names at the prompt, and
  don't interrupt a disk operation: if `run` times out, call `run` again
  with no input.
