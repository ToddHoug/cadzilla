---
name: new-cadzilla-project
description: Scaffolds a new 8080/8085/Z80 CP/M software project in the CADzilla repo under software/<toolchain>/<name>/, with a starter source file for any of the five toolchains -- the original DRI ASM.COM (single .ASM), DRI RMAC + LINK-80 (relocatable .ASM modules plus a <NAME>.SUB build script; LINK can also write .PRL, e.g. GSX drivers), Microsoft M80/L80 with the shared czgfx graphics library (.MAC, library disk on B:), the z88dk host cross-assembler for the 8080, 8085 or Z80 with Intel and/or Zilog mnemonics (.Z88, --cpu; pins the cz88gfx graphics library, czgfx ported to z80asm), or the z88dk zcc C compiler for the 8080, 8085 or Z80 (lowercase .c plus a .Z88 module, --cpu) -- then builds it with its own build.sh and runs it through the altairsim MCP server to prove the toolchain actually works before real development starts. Use this whenever the user wants to start a new CADzilla software project, add a new program under software/, or scaffold an 8080/8085/Z80 assembly or C program for this repo -- even if they just say "make a new project called X" or "let's write a program that does Y" without mentioning CP/M, altairsim, or assembly explicitly. Also use it if the user asks how to add a new program to the repo.
---

# New CADzilla project

Every CADzilla software project is 8080 assembly that assembles and runs
under CP/M 2.2 on the altairsim emulator, driven through altairsim's MCP
server. `tools/altairsim/README.md` documents the full workflow and the
gotchas found while building it; this skill exists so those gotchas don't
have to be rediscovered every time a new project starts.

There are five toolchains. The project is built for one of them:

| `--toolchain` | Source | Build skill | Reference project |
|---|---|---|---|
| `asm` (default) | one self-contained `<NAME>.ASM`; DRI `ASM.COM` + `LOAD.COM`; no INCLUDE, no macros, no linker | `cadzilla-build-asm` | `software/asm/hello` |
| `rmac` | relocatable `<NAME>.ASM` + a second module `PRINT.ASM` (`CSEG`/`DSEG`, `EXTRN`/`PUBLIC`, no `ORG`); DRI `RMAC` + `LINK` 1.31, run by the tracked `<NAME>.SUB` (`SUBMIT <NAME>`); `LINK ...[OP]` writes a `.PRL` (the GSX-80 driver format) | `cadzilla-build-rmac` | `software/rmac/rhello` |
| `m80` | relocatable `<NAME>.MAC`; Microsoft `M80` + `L80`; `INCLUDE B:CZGFX.INC`, the czgfx graphics macros and library, linked with `SUBMIT B:CZLINK` | `cadzilla-build-m80` | `software/m80/gfxdemo` |
| `z88dk` | `<NAME>.Z88` (plus any other `.Z88` modules); z88dk's `z80asm`, run **on the host** by `tools/z88dk/z88build.sh`; Intel and/or Zilog mnemonics; targets the 8080, 8085 or Z80 (`--cpu`); draws with **cz88gfx** (czgfx ported to z80asm), pinned in `cz88gfx.version` | `cadzilla-build-z88dk` | `software/z88dk/zhello`, `software/z88dk/z88demo` (draws) |
| `zcc` | **C**: lowercase `<name>.c` (plus any other `.c` and `.Z88` modules); z88dk's `zcc`, run **on the host** by `tools/z88dk/zccbuild.sh`; targets the 8080, 8085 or Z80 (`--cpu`); draws with **cz88gfx**'s C bindings (`#include <cz88gfx.h>`), pinned in `cz88gfx.version` | `cadzilla-build-zcc` | `software/zcc/chello`, `software/zcc/cgfxdemo` (draws) |

**For anything that draws on the CADzilla board, use a toolchain with a
graphics library: `m80` (czgfx), `z88dk` (cz88gfx) or `zcc` (cz88gfx from
C).** Both libraries
already do the board setup and the drawing primitives, which an `asm`
project would have to copy in whole (as `firstdraw` and `drawdemo` did).
They have the same routines and macros. `m80` builds with the period tools
inside CP/M; `z88dk` builds on the host and can target the 8085 or Z80.
`asm` is fine for small console-only programs. **Use `rmac` when the user wants a linker or separately assembled modules with DRI's tools, or a `.PRL` (a GSX-80 device driver, an MP/M program).** It has no graphics library. **Use `z88dk` when the
target is an 8085 or a Z80, when the user wants Zilog mnemonics or Z80
instructions, or when they ask for host-side cross-assembly.** **Use `zcc`
when the user wants to write C**; it draws with cz88gfx through
`cz88gfx.h` (release 1.1 or later). If
the user hasn't said which toolchain and it isn't obvious from what the
program does, ask.

## 1. Get the project name

Ask the user if they haven't given one. The directory name follows this
repo's normal convention (`software/<toolchain>/<name>/`, matching `software/asm/hello`,
`software/asm/firstdraw`) -- lowercase letters and digits, starting with a
letter. The CP/M-side `<NAME>.ASM` is that same name uppercased, and CP/M's
8.3 format caps it at 8 characters -- if the project name itself is longer
(e.g. "firstdraw" is 9), don't silently truncate or slugify it: keep the
project name the user wants and ask them to either shorten it or pick an
explicit CP/M-side abbreviation instead (the script's `--cpm-name` option
below handles this).

## 2. Scaffold it

Run the bundled script rather than creating the directories and source
file by hand -- it handles the CP/M-uppercasing and the CR/LF line-ending
requirement correctly, which are easy to get wrong by hand (writing the
`.ASM` file with a normal editor/Write tool leaves LF-only line endings,
which `ASM.COM` accepts silently and then assembles into nothing):

```bash
.claude/skills/new-cadzilla-project/scripts/new_project.sh <name> [--toolchain asm|m80|z88dk|zcc|rmac] [--cpu 8080|8085|z80] [--mode WxH] [--cpm-name NAME] ["<welcome message>"]
```

`--cpu` (z88dk and zcc only, default `8080`) is the target CPU. The script
writes it to `machine.toml` as a `cpu0` `[[board]]` block (`type = "z80"`
etc.). That block both replaces the emulated CPU card in `work/cadzilla.toml`
and gives `z88build.sh` its `-m` flag (`zccbuild.sh`: its C library), so the
code and the machine always agree. An
existing `machine.toml`'s `cpu0` wins over `--cpu`. A z88dk project also
gets the newest cz88gfx release pinned in its tracked `cz88gfx.version`
(an existing pin is kept; with no release yet, no pin), so it can
`INCLUDE "CZ88GFX.INC"` and draw. A zcc project gets the same pin, so it can
`#include <cz88gfx.h>` and draw from C. The library links only what a
program uses, so a program that draws nothing carries none of it. The z88dk starter
`src/<NAME>.Z88` (LF line endings, which z80asm accepts) prints the message
and then `Built for <X>, running on <Y>`. `<Y>` comes from detecting the CPU
at run time, so the line proves the build target and the emulated CPU match.
It uses Intel mnemonics for the 8080/8085 and Zilog ones (with IX, which is
Z80-only) for the Z80. Its welcome message can't contain `"` or `$`.

With `--toolchain zcc`, the C source is **lowercase**: zcc only takes a
lowercase `.c`, and the file never reaches CP/M. `--cpm-name` still sets the
program name, and the file is that name lowercased. The script writes two
files:
- `src/<name>.c` prints the message and then `Built for <X>, running on <Y>`,
  using `printf`.
- `src/CPUID.Z88` is an assembly module the C code calls to find `<Y>`. It
  shows the C-to-assembly calling convention.

The message can't contain `"`, `\` or `%`.

`--mode` is the display resolution: `1024x768` (default), `800x600` or
`640x480`. The script writes it to the project's tracked
`software/<toolchain>/<name>/machine.toml` overlay (cad0's `mode` strap), which
`sync_pristine.sh` appends into `work/cadzilla.toml`. Only ask about it if
the user mentions a resolution or it matters for what they're building;
otherwise take the default. If the project already has a `machine.toml`,
it's kept and its mode wins over `--mode`.

With `--toolchain rmac`, the script writes three CR/LF files instead of one
`.ASM`:
- `src/<NAME>.ASM`, the main module. It has `EXTRN PRINT`, code in `CSEG`
  and its two messages in `DSEG`, and prints them through `PRINT`.
- `src/PRINT.ASM`, the second module: `PUBLIC PRINT`, BDOS function 9.
  `PRINT` is therefore a reserved program name.
- `src/<NAME>.SUB`, the build: `RMAC PRINT`, `RMAC <NAME>`,
  `LINK <NAME>,PRINT`.

The message can't contain `'` or `$`, as for `asm`.

With `--toolchain m80`, the script also pins the newest czgfx release
(from `software/m80/czgfx/releases/`) in the project's tracked
`software/<toolchain>/<name>/czgfx.version`, keeping an existing pin. It then runs
`tools/altairsim/scripts/attach_libdisk.sh` on the new `work/`, which copies
that release into `work/` as `CZGFXLIB-<version>.DSK` and mounts it as drive
1 (B:), read-only. The project builds against that copy, so later czgfx
changes don't touch it until its pin is moved. It writes `src/<NAME>.MAC` instead of `.ASM`. The stub:
- `INCLUDE`s `B:CZGFX.INC` and calls `GINIT` with the czgfx descriptor
  for the project's mode (`CZM1K`, `CZM800` or `CZM640`)
- draws a frame round the whole screen and a centered filled box, then
  waits for `GWAIT`
- prints the message and returns to CP/M

This creates `software/<toolchain>/<name>/{src,include,build,work}` (with `.gitkeep`
in `include/` and `build/`, since build output itself is gitignored per
the repo's existing `software/*/*/build/*` rule), `software/<toolchain>/<name>/machine.toml`
(tracked), the project's own `build.sh` (tracked; it runs `tools/build.sh`
on the project), and writes
`software/<toolchain>/<name>/src/<NAME>.ASM`: a minimal BDOS-function-9 string-print
stub, self-contained (no `INCLUDE` -- `ASM.COM` doesn't support it) and
free of underscores in any symbol name (`ASM.COM` silently resolves an
underscored symbol to 0 instead of erroring, which is a much worse failure
mode than a normal typo). The welcome message defaults to `Welcome to
CADzilla: <name>!` if not given. `--cpm-name` overrides the CP/M-side name
when the project name itself doesn't fit CP/M's 8.3 limit (e.g. `firstdraw
--cpm-name FIRSTDRW`).

`work/` is this project's own altairsim machine + disk(s) -- a fresh copy
of `tools/altairsim/pristine/`, gitignored, that belongs to this project
alone. Every project gets its own, so building one never shares (or fills
up) another project's disk, and there's nothing to reset when switching
between projects.

The script is also safe to run against a directory that already exists as
an empty scaffold (`src`/`include`/`build` holding only `.gitkeep`, like
`software/asm/firstdraw` shipped from this repo's initial commit) -- it fills
those in rather than refusing outright, but still won't overwrite a source
file that's already there with real content, and skips creating `work/` if
one's already there.

This is meant as a starting point the user then edits, not a finished
program -- say so, and point at the file, once it's created.

## 3. Prove the toolchain works

Don't stop at "the file exists". Build the stub and run it, so the user
starts editing a project that is already known to build. Otherwise a
toolchain problem turns up later, mixed in with their own code changes.

**Build it with its own `build.sh`.** It is the same for every toolchain:

```bash
software/<toolchain>/<name>/build.sh
```

It refreshes `work/`. A z88dk/zcc stub is built on the host; an asm, m80
or rmac stub is assembled and linked in CP/M on the project's own disk. In
both cases a headless altairsim (`tools/altairsim/scripts/cpmsession.py`)
does the CP/M side, and the MCP server isn't used. The outputs land in
`build/`, the program stays on `A:`, and the disks are unmounted and
checked. Expect exit 0 and a last line
`<NAME>: built on .../work (transcript build/<NAME>.LOG)`. On exit 1 it
prints the error lines; the full CP/M session is in `build/<NAME>.LOG`.

**Then run it over MCP.** First confirm the altairsim MCP tools are
available (e.g. search for `mcp__altairsim__run`). If they're not, the MCP
server likely isn't registered in this session yet. Stop and point the user
at `tools/altairsim/README.md`'s "Starting a session" section rather than
guessing at setup steps.

```
monitor {command: "CONFIG LOAD <repo-root>/software/<toolchain>/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>"}
run {input: "<NAME>\r", until: "A0>"}
```

The first-run check, by toolchain:
- **asm:** the welcome message appears in the last call's output. That's
  the real proof the toolchain works, not just that each step returned
  without an error.
- **z88dk and zcc:** the welcome message and `Built for <X>, running on <X>`,
  with the same CPU twice: the one given to `--cpu`.
- **rmac:** the welcome message, then `Linked by DRI LINK from two RMAC
  modules`.
- **m80:** the stub's message appears, and `board_get cad0` shows `status`
  with CER clear and `picture` as the project's mode at full size
  `at (0,0)` (e.g. `1024x768 at (0,0)`).

Never `CONFIG LOAD` or `MOUNT` anything under `tools/altairsim/pristine/`.
CP/M would write this project's files straight into the master disk image.
Pristine is read-only on the host, so a `WRITE-PROTECTED` mount or a CP/M
write-protect error means the wrong path is loaded: fix the path, not the
permissions. The prompt is `A0>`, not a plain `A>`. Match `until` against
`A0>`; `until: "A>"` never matches, so every call would run to its full
timeout.

Then close the session:
1. `run {timeout_ms: 5000}` with no input and no `until`, which must report
   `stopped: "idle"`;
2. `monitor {command: "UNMOUNT dsk0:drive0"}` and `dsk0:drive1`.

Stopping on the `A0>` match isn't enough: the BIOS writes its last buffered
track only after the prompt is printed, and unmounting before that finishes
has left a half-written sector (`Bdos Err On A: Bad Sector` at the next
boot). Close the session before any rebuild, too: `build.sh` must never run
while the MCP server has the same `work/` loaded.

The toolchain's `cadzilla-build-*` skill has the build-by-hand steps over
MCP, for looking at a single build step.

### Things that will bite you if you skip them

- **CP/M uppercases everything typed at its console** (a real BDOS
  behavior, not an altairsim quirk), so `R`/`W` can't be given a path like
  `software/<toolchain>/<name>/src/<NAME>.ASM` directly -- it gets uppercased and then
  fails a case-sensitive lookup against this repo's lowercase directories.
  That's why `hb0` gets repointed at the exact directory first, and only
  bare filenames get typed at the CP/M prompt.
- **Never use `W`'s text (`T`) flag on the `.COM` file.** It trims at the
  first `1A` (`^Z`) byte found anywhere in the data, which corrupts binary
  content that happens to contain that byte value. Binary mode (no `T`,
  the default) is byte-exact; `T` is only for genuine text (`.HEX`/`.PRN`).
- **Never force-interrupt a disk operation in flight** -- don't call
  `reset` or `CONFIG LOAD` because a `run` call timed out. If a call times
  out mid-`ASM`/`LOAD`/`R`/`W`, call `run` again with no `input` to keep
  draining it rather than resetting; interrupting mid-write has corrupted
  a project's `.COM` file before (left it with a directory entry showing 0
  records, so CP/M ran stale leftover memory instead of the program). If
  this project's working disk does end up in a bad state,
  `tools/altairsim/scripts/sync_pristine.sh software/<toolchain>/<name>/work` recovers
  it -- but that discards anything built there since the last sync, so
  treat an unplanned reset as a deliberate call, not a reflex, and check
  with the user first.
- **A long-lived MCP server may not be booted yet, or may be sitting at a
  stale prompt from whatever it was last doing.** `monitor {command: "SHOW
  MOUNTS"}` before assuming a `CONFIG LOAD` + boot is unnecessary, and
  `regs` if the guest seems unresponsive -- PC 0 with every register
  zeroed means nothing's booted yet, not that something's wrong. A fresh
  server runs altairsim's built-in `cadzilla` machine with every drive
  `(empty)` and no boot PROM; that's expected, and the project's
  `CONFIG LOAD` above is what gives it disks.

## 4. Report back

Tell the user what was created, confirm the build/run check passed (quote
the actual console output), and remind them that `software/<toolchain>/<name>/build/`
is gitignored (only `.gitkeep` is tracked) and that nothing has been
staged or committed -- per this repo's convention, only commit when asked.
