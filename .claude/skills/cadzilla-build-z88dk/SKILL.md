---
name: cadzilla-build-z88dk
description: Builds, runs and debugs a CADzilla software project that uses the z88dk host toolchain -- a <NAME>.Z88 source in Intel (8080) and/or Zilog (Z80) mnemonics, assembled on the HOST by z88dk's z80asm via tools/z88dk/z88build.sh for the 8080, 8085 or Z80 named in the project's machine.toml, then copied onto the project's own CP/M disk with R and run on an altairsim machine carrying that same CPU, all through the altairsim MCP server. Use this whenever the user wants to build, rebuild, run, test or debug a CADzilla program whose source is a .Z88 file (software/zhello, anything scaffolded with --toolchain z88dk), retarget one to another CPU, or asks about assembling for the 8085 or Z80, mixing Intel and Zilog mnemonics, or cross-assembling on the host. For .ASM projects use cadzilla-build-asm; for .MAC projects use cadzilla-build-m80.
---

# Build a CADzilla project with z88dk (host cross-assembler)

These projects are `software/<name>/src/*.Z88`. z88dk's `z80asm` assembles
them **on the host**, for the 8080, 8085 or Z80, straight into
`build/<NAME>.COM`. altairsim then only copies that `.COM` onto the project's
own CP/M disk with `R` and runs it, on an emulated CPU of the same type.
`tools/z88dk/README.md` has the background and the syntax traps. The reference
project is `software/zhello` (Z80).

## 0. Before building

- **Find the names.** The project is `software/<name>/`. The main module is
  the `src/*.Z88` with an `ORG`, and its name is the program's CP/M name,
  e.g. `src/ZHELLO.Z88` gives `ZHELLO.COM`. Look in `src/`; don't guess.
- **The CPU** is the `cpu0` block in `software/<name>/machine.toml`
  (`type = "8080" | "8085" | "z80"`). The build reads it for z80asm's `-m`
  flag, and the work machine gets it as its CPU card. To retarget, edit that
  block, then run `tools/altairsim/scripts/sync_pristine.sh --machine-only
  software/<name>/work` so the emulator follows.
- **The project needs its own `work/`.** If it's missing, create it with
  `tools/altairsim/scripts/sync_pristine.sh software/<name>/work`.

## 1. Build on the host

```bash
tools/z88dk/z88build.sh software/<name>
```

- It prints `z88dk: <NAME> for <cpu>`, then the `.COM` size. Any error exits
  non-zero, deletes `build/<NAME>.COM`, and leaves the listings in `build/`.
  Fix errors here; don't go near the emulator until it builds.
- Read the warnings:
  - `JP x is z80asm's unconditional jump` / `CP x is z80asm's compare`: the
    file uses Intel mnemonics, and z80asm gives these two their Zilog meaning.
    If Intel jump-if-plus or call-if-plus was meant, write `JP P,x` or
    `CALL P,x`. If the Zilog meaning was meant, `JMP x` or `CPI x` silences
    the warning.
  - `interpreting indirect value as immediate` is a **build error** here.
    For the 8080/8085, z80asm assembles `ld sp,(nn)` as `ld sp,nn`. Rewrite
    it with 8080 instructions (`LHLD nn` / `SPHL`).
- `error: ... outside $HOME`: the z88dk snap can only see non-hidden paths
  under `$HOME` (never `/tmp`).

## 2. Boot the project's machine, copy the `.COM` in, run it

The altairsim MCP tools must be loaded (`mcp__altairsim__run`). If they
aren't, point the user at `tools/altairsim/README.md`'s "Starting a
session".

```
monitor {command: "SHOW MOUNTS"}
monitor {command: "CONFIG LOAD <repo-root>/software/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>", timeout_ms: 10000}
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/build"}
run {input: "R <NAME>.COM\r", until: "A0>", timeout_ms: 15000}
run {input: "<NAME>\r", until: "A0>", timeout_ms: 20000}
```

- **Never `CONFIG LOAD` or `MOUNT` anything under
  `tools/altairsim/pristine/`.** If another project's disks are still
  mounted, take that session to idle and `UNMOUNT` its drives first.
- The prompt is `A0>`, not `A>`.
- `R` reports `N records`. `R: <NAME>.COM: no such file` means the build
  failed (no `.COM`) or `HOSTDIR` points at the wrong directory.
- **Check the CPU:** the `CONFIG LOAD` output shows its register line. A Z80
  shows `IX`/`IY` and the alternate bank; an 8085 shows its extra `V`/`K`
  flags. `monitor {command: "SHOW cpu0"}` names the core.
- Confirm the program's own console output appears in the last call. That is
  the real proof. A starter program prints `Built for <X>, running on <Y>`,
  and the two should match.
- `W` is only for files the program writes in CP/M. Pull them into `build/`
  (binary, never with `T` for binary data).

## 3. Debugging

```
monitor {command: "SYMBOLS LOAD <repo-root>/software/<name>/build/<NAME>.SYM"}
monitor {command: "BREAK START"}
run {input: "<NAME>\r", timeout_ms: 15000}        # stops: "breakpoint", pc 0x0100
monitor {command: "DISASM START 8"}
```

- `<NAME>.SYM` holds the program labels, uppercased. `<NAME>.MAP` and the
  `.LIS` files in `build/` have everything else.
- Symbols outlive `CONFIG LOAD`. When done, run `NOBREAK` and `SYMBOLS CLEAR`.

## 4. Close the session (always, unless told to leave it open)

```
run {timeout_ms: 5000}                      # no input, no until -> stopped: "idle"
monitor {command: "UNMOUNT dsk0:drive0"}
monitor {command: "UNMOUNT dsk0:drive1"}
```

- Stopping on `A0>` is not idle. The BIOS writes its buffered track only
  after the prompt. Before any `UNMOUNT`, `CONFIG LOAD` or `reset`, do a
  `run` with no input that reports `stopped: "idle"`.
- Then run `tools/altairsim/scripts/check_dsk.py software/<name>/work/*.DSK`,
  which should say `ok`, and check that `git status tools/altairsim/pristine`
  is clean.
- Never interrupt `R`/`W` mid-transfer. If a `run` times out, call `run`
  again with no input.

Report the CPU, what was built and run, the console output, and that the
session was unmounted. `build/` and `work/` are gitignored. Don't commit
unless asked.

## Timing

`work/cadzilla.toml` runs flat out. For real-time behaviour, `CONFIG LOAD`
`work/cadzilla-real.toml` instead. It is the same machine with the same CPU,
at 2 MHz with real ACRTC draw times. Copy the `.COM` in under `cadzilla.toml`
first; it stays on the disk.
