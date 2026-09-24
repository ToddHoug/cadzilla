---
name: cadzilla-build-m80
description: Builds and runs CADzilla programs with the Microsoft M80/L80 toolchain and the shared czgfx graphics library -- rebuilding the czgfx library disk when its sources changed, then assembling a consumer project's <NAME>.MAC with M80, linking it against the library with SUBMIT B:CZLINK, running it and pulling the .COM/.PRN back -- all by driving the altairsim MCP server. Use this whenever the user wants to build, run, test or debug a CADzilla project whose source is a .MAC file (software/gfxdemo, software/czgfx, anything scaffolded with --toolchain m80), change or extend the czgfx library (new primitive, new macro, new module), or asks how to share code/macros between CADzilla programs. For single-file .ASM projects (hello, firstdraw, drawdemo) use cadzilla-build-asm.
---

# Build with M80/L80 and the czgfx library

The pieces (full background is in `tools/altairsim/README.md`, "The M80/L80
toolchain", and in `software/czgfx/README.md`):

- **`software/czgfx/`** is the graphics library. Its sources are in `src/`
  (`CZGFX.INC`, `CZ*.MAC`, `CZBUILD.SUB`, `CZLINK.SUB`, `CZCHK.MAC`). It is
  built onto the **library disk** `software/czgfx/libdisk/CZGFX.DSK`, which
  czgfx's own `work/` mounts **writable** as drive 1 (B:).
- **Consumer projects** (`software/gfxdemo` is the example) mount the same
  disk as **B:, read-only**. They `INCLUDE B:CZGFX.INC`, and link with
  `SUBMIT B:CZLINK <NAME>`, which runs L80 with the library modules in
  `/S` search mode.

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
   - Its `cadzilla.toml` drive 1 must mount `../../czgfx/libdisk/CZGFX.DSK`
     with `readonly = true`. If it doesn't (for example after
     `sync_pristine.sh --machine-only`), run
     `tools/altairsim/scripts/attach_libdisk.sh software/<name>/work`.
   - czgfx itself uses `attach_libdisk.sh --writable software/czgfx/work`.
3. **CR/LF.** Run `tools/altairsim/scripts/crlf.sh` on every source you're
   about to `R`: the project's `src/*.MAC`, plus `software/czgfx/src/*`
   when rebuilding the library. It is idempotent. Files written on the host
   are LF-only, and LF-only source silently assembles to nothing.
4. **Is the library stale?** Check whether the library disk is missing, or
   any czgfx source is newer than it:
   ```bash
   find software/czgfx/src -newer software/czgfx/libdisk/CZGFX.DSK -type f
   ```
   If the disk is missing or this prints anything, do step 1 before step 2.
   Also do step 1 whenever the user changed the library.
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

- **Check `SHOW MOUNTS`.** drive0 must be `CPM22-8MB-56K-DEV.DSK` (in
  `czgfx/work`), and drive1 must be `../libdisk/CZGFX.DSK` without
  `(write-protected)`.
- **Don't use `until: "A0>"` on a SUBMIT.** SuperSUB echoes every line at
  an `A0>` prompt, so the call would stop after the first line. Leave
  `until` off, and the call stops when the guest goes idle at the end.
- **Check the CZBUILD output:**
  - every `M80` line is followed by `No Fatal error(s)`
  - the final L80 link of `CZCHK` (through `B:CZLINK`) prints no
    `?Undefined` and no `%Mult. Def.`
  - `CZCHK` expands every macro and references every entry point, so a
    clean link means the published header and modules agree.
- Pull the artifacts back, then close this machine:
  ```
  monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/czgfx/build"}
  run {input: "W *.REL\r", until: "A0>", timeout_ms: 20000}       # binary
  run {input: "W *.PRN T\r", until: "A0>", timeout_ms: 30000}
  run {input: "DIR B:\r", until: "A0>"}      # the 5 .RELs, CZGFX.INC, CZLINK.SUB
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
monitor {command: "SHOW MOUNTS"}   # drive1 = ../../czgfx/libdisk/CZGFX.DSK (write-protected)
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/src"}
run {input: "R <NAME>.MAC\r", until: "A0>", timeout_ms: 15000}
run {input: "M80 <NAME>,<NAME>=<NAME>\r", until: "A0>", timeout_ms: 60000}
run {input: "SUBMIT B:CZLINK <NAME>\r", timeout_ms: 60000}
run {input: "<NAME>\r", until: "A0>", timeout_ms: 30000}
```

- **A multi-module project** assembles each module with its own `M80`
  line. Then link the main module with L80 directly, listing the
  project's own modules and then `CZLINK`'s library list:
  `L80 MAIN,PART2,B:CZPOLY/S,...,B:CZCORE/S,MAIN/N/E`.
- **Passing an extra L80 switch.** `SUBMIT B:CZLINK <NAME> /M` passes `/M`
  as `$2`, which prints the link map.
- **Link check.** The L80 summary `[start end pages]` should show no
  `?Undefined`. A program that doesn't use a module doesn't get it: the
  link is smaller, with no error.
- **Checking the run:**
  - the program's console output should appear
  - graphics draw in the altairsim window, which the user sees
  - `board_get cad0` should show `status` with CER (80H) clear, `picture`
    as `640x480 at (0,0)` (or whichever mode was chosen), and `wiring` as
    `ok`
- **Key waits.**
  - Type a key with `run {input: " "}`.
  - To stop mid-way, match `until` on unique prompt text.
  - An ESC can't be typed through the `input` string, so step to the end
    with ordinary keys instead.
- **Checking 1024x768** (`GINIT CZM1K`): run
  `monitor {command: "SET cad0 mode=1024x768"}` first. `board_set` may
  report a malformed result even though the change took, so confirm it with
  `SHOW cad0`. Afterwards run `SET cad0 mode=640x480` again.
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
- `tools/altairsim/scripts/check_dsk.py software/<name>/work/*.DSK
  software/czgfx/libdisk/CZGFX.DSK` must say `ok` for every image
- confirm `git status tools/altairsim/pristine` is clean; if it isn't, stop
  and tell the user
- a consumer mounts the library disk read-only, so its modification time
  shouldn't change during a consumer session

Report what was built (library rebuilt or not), quote the console output,
and say the drives were unmounted. `build/`, `work/` and `libdisk/` are
gitignored. Don't commit unless asked.

## Changing the library

`software/czgfx/README.md` has the API and the extension recipe. In short:

- **New routine:** `PUBLIC` it in its module, add its `EXTRN` to the
  `IFNDEF CZLIB` block of `CZGFX.INC`, optionally add a `G...` macro,
  and exercise it in `CZCHK.MAC`.
- **New module:**
  1. Create `CZxxxx.MAC` starting with `CZLIB EQU 1` /
     `INCLUDE CZGFX.INC`.
  2. Add its `M80` and `PIP B:=` lines to `CZBUILD.SUB`.
  3. Insert it into `CZLINK.SUB` after every module that calls it and
     before every module it calls, because L80 searches in one pass.
- Then rebuild the library (step 1) and **relink every consumer**. A
  `.COM` contains the library code it was linked with.

## M80/L80 gotchas (all confirmed on this disk: M80/L80 3.44)

- **Globals are 6 characters.** L80 truncates `PUBLIC`/`EXTRN` names, so
  `LONGNAME1` and `LONGNAME2` collide as `%Mult. Def. Global LONGNA`.
  Keep global names to 6 characters or fewer. Keep local labels short too,
  following the repo's existing style.
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
