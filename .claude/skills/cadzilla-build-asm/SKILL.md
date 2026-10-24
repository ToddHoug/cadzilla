---
name: cadzilla-build-asm
description: Builds, runs and pulls back an existing CADzilla software project that uses the original CP/M toolchain -- Digital Research ASM.COM + LOAD.COM, a single self-contained <NAME>.ASM -- built on that project's own work/ disk by its build.sh (headless altairsim), then run and debugged by driving the altairsim MCP server. Use this whenever the user wants to assemble, rebuild, run, test or debug a CADzilla program whose source is a single self-contained .ASM file with ORG 0100H (software/asm/hello, software/asm/firstdraw, software/asm/drawdemo, or any project scaffolded with --toolchain asm), even if they just say "build hello", "rerun firstdraw", or "try my change to DRAWDEMO". For projects with a .MAC source that use the czgfx library, use cadzilla-build-m80 instead; for .Z88 sources (z88dk, 8080/8085/Z80, assembled on the host) use cadzilla-build-z88dk; for C (.c) sources use cadzilla-build-zcc; for relocatable .ASM modules linked by DRI RMAC + LINK (a <NAME>.SUB in src/, e.g. software/rmac/rhello, --toolchain rmac) use cadzilla-build-rmac.
---

# Build a CADzilla project with ASM.COM (the original CP/M toolchain)

These projects are one self-contained `software/asm/<name>/src/<NAME>.ASM`,
assembled by DRI `ASM.COM` into a `.HEX` + `.PRN` and turned into a `.COM`
by `LOAD.COM`, all inside CP/M 2.2 on altairsim. They have no INCLUDE, no
macros and no linker. For shared code, see `cadzilla-build-m80`. For
relocatable `.ASM` modules linked by DRI LINK, see `cadzilla-build-rmac`.
Such projects have a `<NAME>.SUB` in `src/` and no `ORG`. Reference
examples: `software/asm/hello` (minimal), `software/asm/firstdraw` and
`software/asm/drawdemo` (graphics). `tools/altairsim/README.md` has the
full background.

## 0. Before touching the emulator

- **Find the names.** The project directory is `software/asm/<name>/` (lowercase).
  The source is `src/<NAME>.ASM`, uppercase and at most 8 characters, e.g.
  `firstdraw` → `FIRSTDRW.ASM`. Look in `src/` rather than guessing.
- **CR/LF.** `build.sh` gives an LF-only source CR/LF itself. For a build by
  hand, run `tools/altairsim/scripts/crlf.sh software/asm/<name>/src/<NAME>.ASM`
  (idempotent). An LF-only file assembles to nothing with no error: the
  address `ASM` prints before `USE FACTOR` stays at `0100`.
- **The project's `work/`** is created by `build.sh` if it's missing.

## Build: the project's `build.sh`

```bash
software/asm/<name>/build.sh
```

- **First, make sure the MCP server hasn't got this project's `work/`
  loaded** (`monitor {command: "SHOW MOUNTS"}`). If it has, close that
  session out (step 4) before building: two altairsims must never write one
  disk.
- What it does, with a headless altairsim
  (`tools/altairsim/scripts/cpmsession.py`, not the MCP server):
  1. creates or refreshes `work/`;
  2. runs `R`, `ASM` and `LOAD` on the project's own disk;
  3. pulls `<NAME>.COM`, `.HEX` and `.PRN` into `build/`;
  4. unmounts, and checks the disks.

  The program stays on `A:`.
- **Exit 0** means built.
- **Exit 1** means the build failed. It prints the error lines (ASM's flag
  lines, LOAD's `ERROR:`), and the whole session is in `build/<NAME>.LOG`.
  A failed build's `.COM` is erased, not pulled back. Fix the source and
  rerun.
- `--clean` re-syncs `work/` from pristine first. That discards the disk, so
  ask first.

Then run and debug it over MCP: step 1, then the run line of step 2. The
`R`/`ASM`/`LOAD` lines of step 2, and step 3, are the manual fallback, for
looking at a build step itself.
- The altairsim MCP tools must be loaded (`mcp__altairsim__run`). If they
  aren't, point the user at the README's "Starting a session" instead of
  guessing at setup.

## 1. Point the server at the project's own disk and boot

```
monitor {command: "SHOW MOUNTS"}            # what is mounted right now?
monitor {command: "CONFIG LOAD <repo-root>/software/asm/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>", timeout_ms: 10000}
monitor {command: "SHOW MOUNTS"}            # drive0 must be this project's work/ disk
```

- **Never `CONFIG LOAD` or `MOUNT` anything under
  `tools/altairsim/pristine/`.** CP/M would write this project's files
  into the master disk.
- A `(write-protected ... THE HOST WON'T LET US WRITE IT)` mount means the
  wrong path is loaded. Fix the path, never the permissions.
- If another project's disks are still mounted, return that session to `A0>`
  and `UNMOUNT` its drives first.
- The prompt is `A0>`, not `A>`. Match `until` against `A0>`.

## 2. Assemble, load, run

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/asm/<name>/src"}
run {input: "R <NAME>.ASM\r", until: "A0>", timeout_ms: 15000}
run {input: "ASM <NAME>\r", until: "A0>", timeout_ms: 30000}
run {input: "LOAD <NAME>\r", until: "A0>", timeout_ms: 15000}
run {input: "<NAME>\r", until: "A0>", timeout_ms: 20000}
```

- Check `ASM`'s output. It ends in `END OF ASSEMBLY`, and the first
  line after the banner is the next free address, which is `0120` for
  hello. `0100` means nothing was assembled, i.e. an LF-only source. Error
  lines start with a one-letter flag. (`000H USE FACTOR` is normal for
  small programs.) `LOAD` should report sensible
  `FIRST ADDRESS` / `LAST ADDRESS` values.
- Confirm the program's own console output appeared in the last call. That
  is the real proof it ran.
- Graphics programs draw in the altairsim video window, which the user can
  see. Also check `board_get cad0`:
  - `status` should have CER (80H) clear
  - `mode` should match the project's `machine.toml` (1024x768 unless it
    says otherwise), and `picture` should be that mode's full size
    `at (0,0)` -- smaller or offset means the program's register table and
    the strap disagree (see "Display resolution" in
    `tools/altairsim/README.md`)
  - `wiring` should be `ok`
- If a program waits for a key, type one with `run {input: " "}`. To stop
  mid-way, match `until` on a unique piece of its prompt text.

## 3. Pull the artifacts back

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/asm/<name>/build"}
run {input: "W <NAME>.COM\r", until: "A0>"}         # binary -- NEVER with T
run {input: "W <NAME>.HEX T\r", until: "A0>"}
run {input: "W <NAME>.PRN T\r", until: "A0>"}
monitor {command: "SET hb0 HOSTDIR=<repo-root>"}
```

## 4. Close the session (always, unless told to leave it open)

```
run {timeout_ms: 5000}                      # no input, no until -> stopped: "idle"
monitor {command: "UNMOUNT dsk0:drive0"}
monitor {command: "UNMOUNT dsk0:drive1"}
```

**Stopping on `A0>` is not the same as idle.** This CP/M BIOS keeps the
last track it wrote in a RAM buffer, and writes it to the disk only once
the CCP waits for console input, which happens *after* the `A0>` prompt is
printed. A `run` that stopped on `until: "A0>"` can therefore still have
that write outstanding. Unmounting then either loses it, or cuts it short
halfway through a sector, and the next boot says
`Bdos Err On A: Bad Sector`. This has happened to `software/m80/gfxdemo/work`.
So before any `UNMOUNT`, `CONFIG LOAD` or `reset`, run once with no input
and no `until`, and check that it reports `stopped: "idle"`.

UNMOUNT flushes the disk image to the host file; if you skip it, work on
the project's disk can be lost. Then:
- run `tools/altairsim/scripts/check_dsk.py software/asm/<name>/work/*.DSK`,
  which should say `ok`
- confirm `git status tools/altairsim/pristine` is clean; if it isn't, stop
  and tell the user

Report what was built and run, quote the console output, and say the
session was unmounted. `build/` and `work/` are gitignored. Don't commit
unless asked.

## ASM.COM gotchas

- **No `INCLUDE`, no macros, no linker.** Every `.ASM` carries its own
  equates and routines. If the user wants shared code, that's the M80 flow.
- **Underscores in symbols silently resolve to 0.** No error, just wrong
  code.
- Symbols are case-insensitive, so watch for accidental collisions.
- **`DB -1` assembles wrong** (to `0CH`, not `0FFH`). Write negative values
  as `0-1`, as firstdraw does (`0-479`).
- **LF-only source assembles to nothing.** Run `crlf.sh`.
- **`W ... T` on a `.COM` corrupts it.** T mode trims at the first `1AH`
  byte. Binary (the default) is byte-exact but padded to 128 bytes.
- CP/M uppercases everything typed at its prompt, so point `hb0 HOSTDIR`
  at the exact directory and type only bare file names. Never type paths.
- **Idle before unmount.** A `run` that matched `A0>` may still have the
  BIOS's track write outstanding. Before `UNMOUNT`, `CONFIG LOAD` or
  `reset`, always do one `run` with no input that ends `stopped: "idle"`.
- **Don't interrupt a disk operation.** If a `run` times out mid-`ASM`,
  `LOAD`, `R` or `W`, call `run` again with no input to let it finish.
  Never `reset` or `CONFIG LOAD` mid-write. A corrupted work disk is
  recovered with `sync_pristine.sh software/asm/<name>/work`, but that discards
  everything on it, so ask the user first.
- Mixing BDOS function 9 (print) with function 6 (direct console input)
  loses a key typed while text is still printing. The BDOS stashes it in a
  buffer that function 6 bypasses, and it turns up later at the CCP
  prompt. Read keys with function 1 when that matters.
