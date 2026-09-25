# tools/altairsim — CADzilla's 8080/CP/M build-and-run environment

Every `software/<project>` in this repo is 8080 assembly meant to assemble
and run under CP/M 2.2. Before it ever touches real S100/Altair hardware,
it's built and exercised on [altairsim](https://github.com/) (installed
locally at `~/altairsim`), driven by an AI assistant through altairsim's
built-in MCP server. This directory holds everything that workflow needs.

## Naming convention

**Files that pass through the CP/M toolchain are UPPERCASE on both the
host and the CP/M side** — everything under `software/<project>/src/` and
`software/<project>/build/` (`HELLO.ASM`, `HELLO.COM`, `HELLO.HEX`,
`HELLO.PRN`, ...), and every `ASM`/`LOAD`/run/`W` argument typed at the
CP/M console. The same name is used consistently everywhere — no renaming
between host and CP/M. Directory names (`software/hello/`, `src/`,
`build/`, `work/`) still follow this repo's normal lowercase convention
(`CLAUDE.md`); only the files themselves are uppercase.

This also sidesteps a real gotcha explained below: CP/M uppercases
everything you type at its console anyway, so a mixed-case CP/M-side name
could never be created from the command line in the first place.

## Layout

- `pristine/` — the read-only master copy of the CP/M machine definition
  (`cadzilla.toml`) and disk images (`CPM22-8MB-56K-DEV.DSK`,
  `BLANK-8MB.DSK`). **Never edit or boot these directly** — always work
  against a copy in a project's own `work/` (below). CP/M writes to a
  mounted disk in place, so booting or `CONFIG LOAD`-ing
  `pristine/cadzilla.toml`, or `MOUNT`-ing a pristine `.DSK`, writes
  whatever you build straight into the master image (this has happened:
  HELLO project files ended up in the pristine CP/M disk). As a guard the
  pristine files are kept **read-only on the host** (`sync_pristine.sh`
  re-applies `chmod a-w` on every run, since git doesn't track write
  permission), and altairsim then mounts them `WRITE-PROTECTED`. If CP/M
  ever reports a write-protect error, the wrong disk is mounted — fix
  the path, never the permissions. `git status tools/altairsim/pristine`
  should always be clean after a session. `cadzilla.toml` is a
  delta on altairsim's own `machines/cadzilla.toml` — the real board with
  its console, front panel, flat-out CPU, host bridge, an empty disk
  controller and 56K of RAM — adding only what CP/M needs to boot: the
  DBL boot PROM at FF00, this project's disks in drives 0 and 1, the
  `RUN FF00` startup and the console's Backspace mapping — plus the
  monitor resolution (cad0 `mode = "1024x768"`), stated explicitly rather
  than inherited from the base (see "Display resolution"). See the comments
  in the file itself for the full reasoning. `CPM22-8MB-56K-DEV.DSK` (drive 0) is an 8MB virtual hard disk
  carrying CP/M itself (`ASM.COM`, `LOAD.COM`, `DDT.COM`, Microsoft's
  `M80`/`L80`/`LIB80`/`CREF80.COM`, the host-bridge `R`/`W`/`HDIR.COM`, and
  more disk tools than the old 8" floppy image had room for) — the "56K" in its name is the CP/M memory footprint (RAM
  0000-DFFF), not the disk capacity; `BLANK-8MB.DSK` (drive 1) is a second,
  empty 8MB volume for scratch space.
- `scripts/sync_pristine.sh [--machine-only] <dest-dir>` — copies the
  pristine machine + disk(s) into any destination directory, creating it
  if needed. Used to set up a new project's own `work/`, and to recover a
  work directory that's ended up in a bad state. `--machine-only` copies
  just `cadzilla.toml` and leaves the destination's disks alone — use it to
  pick up a change to the pristine machine definition in every existing
  `software/*/work/` without losing what's been built there. Either way,
  if the directory above `<dest-dir>` has a `machine.toml` (the project's
  tracked overlay, `software/<project>/machine.toml`), it is appended to
  the copied `cadzilla.toml` — see "Display resolution". It makes the
  copies writable, keeps pristine read-only, and refuses to target
  `pristine/` itself.
- `scripts/attach_libdisk.sh [--writable] <work-dir>` — points drive 1
  (CP/M `B:`) of a work machine at the czgfx library disk
  `software/czgfx/libdisk/CZGFX.DSK` (read-only unless `--writable`),
  creating that disk from `pristine/BLANK-8MB.DSK` if it doesn't exist
  yet. See "The M80/L80 toolchain" below. Re-run it after
  `sync_pristine.sh --machine-only`, which puts the pristine drive 1 back.
- `scripts/check_dsk.py <image.DSK>...` — checks every sector of a CP/M
  disk image for a valid stop byte and checksum; exit status 1 on any bad
  sector. Run it on a project's disks after a session. A bad sector means
  the disk was unmounted while the BIOS was still flushing (see "Ending a
  session").
- `scripts/crlf.sh <file>...` — gives text files CP/M's CR/LF line
  endings in place (idempotent). Run it on every `.ASM`/`.MAC`/`.INC`/`.SUB`
  before `R`: files written on this host are LF-only, and an LF-only
  source assembles to nothing without an error.
- `DRIVING-WITH-AI.md` — altairsim's own guide for driving it via MCP
  (kept here for reference; canonical copy lives in `~/altairsim/docs/`).

**Every `software/<project>/` also has its own `work/`** — a project's
private, gitignored copy of the pristine machine + disk(s), created once
(by the `new-cadzilla-project` skill, or by hand with `sync_pristine.sh`)
and then persisting across sessions for that project alone. Because each
project's disk is its own, switching between projects never means
resetting anything — you just point the server at a different project's
`work/cadzilla.toml`.

## One-time setup (per machine)

The `claude` CLI isn't always on `PATH` in every environment (e.g. inside
the VS Code extension's sandboxed shell, it's bundled as a native binary
instead, and the exact path changes as the extension updates versions). If
`claude --version` doesn't work, find the current bundled binary under
`~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude`
and symlink it onto `PATH` (re-run this if the extension updates and the
symlink goes stale):

```bash
ln -sf ~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude \
       ~/.local/bin/claude
```

## Starting a session

From the **repo root**:

```bash
cd /home/thoug/Projects/cadzilla
claude mcp add altairsim -- /home/thoug/altairsim/build/altairsim -m cadzilla --mcp
claude mcp list   # confirm "altairsim" is registered and reachable
```

(Migrating from an older registration that pointed at a
`tools/altairsim/work/cadzilla.toml` file? `claude mcp remove altairsim`
first, then add it as above.)

Registration uses local scope (the default) since it embeds an absolute,
machine-specific path to the altairsim binary — it's stored in your own
Claude config, not committed to the repo. A newly registered MCP server's
tools may not appear until the session/window is reloaded.

The server starts on altairsim's **built-in `cadzilla` machine** (`-m
cadzilla`): the real board with its console, front panel, host bridge and
an empty disk controller — **no disks mounted and no boot PROM**, so
nothing can be written anywhere until you choose a project. The first
real step of any session is always `CONFIG LOAD`-ing the project you're
about to work on (see "Working on a project" below). No repo file is
named in the registration, so nothing in the repo has to exist for the
server to start, and no project's disks are held open by a server that
outlives its session.

### Resuming a session — check the disk is actually mounted

Once registered, the `altairsim` MCP server is a long-lived process that
can easily outlive a single conversation — a later Claude Code session (or
even a later turn in the same one) may find the guest already booted and
sitting at a prompt from before. That's not the same as a fresh, working
machine: if the previous session ended cleanly with `UNMOUNT` (as it
should), the disk is gone from under a CP/M that's still technically
"running" and looks alive. Every disk access then fails with `Bdos Err On
A: Bad Sector`, which reads like corruption but isn't — there's simply
nothing mounted. It's also possible to find the guest sitting at PC 0 with
every register zeroed and nothing booted at all (a fresh server process
that was never driven through a boot yet) — `regs` tells the two apart.

Check first: `monitor {command: "SHOW MOUNTS"}`. On a freshly started
server every drive shows `(empty)` — that's the built-in machine, as
expected. Either way, if `dsk0:drive0` isn't your project's disk, don't
`MOUNT` a disk by hand: `CONFIG LOAD` the project's own
`work/cadzilla.toml` again (it mounts both of that project's disks,
resolved against its own `work/`) and do a clean boot, `run {from:
0xFF00, until: "A0>"}`, before touching the disk. The boot isn't
optional: a disk mounted out from under a CP/M that's already running
(rather than through its own boot-time disk detection) makes BDOS
defensively mark the drive read-only (`Bdos Err On A: R/O`) until the
next warm boot clears it.

## Working on a project — each one has its own disk

Every project's `work/` is its own persistent copy of the pristine
machine + disk(s) (see "Layout" above), so there's no shared state to
reset when switching between projects — just point the server at the
project you're working on:

```
monitor {command: "CONFIG LOAD <repo-root>/software/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>"}
```

(`CONFIG LOAD` swaps the running server's machine definition without
restarting the MCP connection or needing a session reload — safe to use
any time you're at a clean prompt, between commands.) The mount-and-reboot
notes above still apply per project: `SHOW MOUNTS` before assuming a
`CONFIG LOAD` alone leaves you ready to go.

If a project doesn't have a `work/` yet (an existing project from before
per-project disks, or one someone set up by hand without it), create one
the same way the `new-cadzilla-project` skill does:

```bash
tools/altairsim/scripts/sync_pristine.sh software/<name>/work
```

### Display resolution — each project pins its own

The CADzilla board drives a fixed-frequency VESA monitor chosen by cad0's
`mode` strap: **640x480, 800x600 or 1024x768**. A program programs the
ACRTC's timing for one of those, and the machine's strap has to agree. The
board does **not** reject a mismatch: a program timed for one mode on a
monitor strapped for another still "runs", but its picture lands in the
wrong place in the monitor's frame. (That happened when altairsim's own
board default moved from 640x480 to 1024x768: every project inherited the
new strap silently.)

So the resolution is stated, never inherited:

- **Pristine** `cadzilla.toml` sets `mode = "1024x768"` explicitly — the
  default for new projects.
- **Each project** that draws pins its own in a small tracked overlay,
  `software/<project>/machine.toml`:
  ```toml
  [[board]]
  id   = "cad0"
  mode = "1024x768"   # or 640x480 / 800x600
  ```
  `sync_pristine.sh` appends it to the project's `work/cadzilla.toml` on
  every sync (a later `[[board]]` block for the same id overrides the
  pristine one), so it survives resyncs and fresh clones. The overlay may
  only contain `[[board]]` tables; the script refuses anything else. The
  `new-cadzilla-project` skill writes one for every new project
  (`--mode`, default 1024x768).
- **The code must match.** czgfx programs pass the matching descriptor to
  `GINIT`: `CZM640`, `CZM800` or `CZM1K` (bare `GINIT` means `CZM640`, so
  always name it). ASM programs carry their own register table — the
  values for each mode are in altairsim's `docs/boards/cadzilla.md`.

To **change** a project's resolution: edit its `machine.toml` and its
code, then `sync_pristine.sh --machine-only software/<name>/work` (plus
`attach_libdisk.sh` again for an M80 project) and `CONFIG LOAD` it. To
**check** one: `board_get cad0` after a run — `mode` is the strap, and
`picture` should read the mode's full size `at (0,0)` with `wiring` `ok`. A
picture anywhere else, or smaller than the mode, means program and strap
disagree. To try another mode for one session without changing anything,
`monitor {command: "SET cad0 mode=800x600"}` works until the next `CONFIG
LOAD`.

### The prompt is `A0>`, not `A>`

`CPM22-8MB-56K-DEV.DSK` boots a CP/M build for an 8MB virtual drive, which
numbers logical units — the prompt is `A0>` (or `B0>` after `B:`), not the
plain `A>` of the old 8" floppy image. Every `until` in a `run` call needs
to match `A0>` — matching against `A>` simply never matches, so the call
runs to its full timeout instead of stopping cleanly at the prompt.

## The host bridge (`R`/`W`) and CP/M's automatic uppercasing

`R`/`W` genuinely do support subdirectory paths and a rename argument (e.g.
`R SUBDIR/FOO.TXT` works, and `W FOO.BIN RENAMED.BIN` really does create
`RENAMED.BIN`) — confirmed by testing directly against an **uppercase**
scratch subdirectory. The catch is CP/M itself: the CCP reads the command
line through BDOS function 10 (buffered console input), which **uppercases
every lowercase letter you type** before any program — including `R`/`W`
— ever sees it. Since this repo's directories and filenames are lowercase
by convention (per `CLAUDE.md`), any path or filename typed at the prompt
gets uppercased first and then fails a case-sensitive lookup against the
real lowercase host paths (`R software/hello/src/hello.asm HELLO.ASM`
becomes `R SOFTWARE/HELLO/SRC/HELLO.ASM HELLO.ASM` internally, and
`software/` on the host doesn't match `SOFTWARE/`).

There's no way around the uppercasing from inside CP/M — instead, repoint
`hb0` at the exact directory you need with `SET hb0 HOSTDIR=<abs path>`
(a `monitor` command, entered outside CP/M's console and therefore not
subject to its uppercasing) before each `R`/`W`, and use bare filenames:

```
monitor {command: "CONFIG LOAD /home/thoug/Projects/cadzilla/software/<proj>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>"}                                  # boot CP/M

monitor {command: "SET hb0 HOSTDIR=/home/thoug/Projects/cadzilla/software/<proj>/src"}
run {input: "R <NAME>.ASM\r", until: "A0>"}                       # host -> CP/M

run {input: "ASM <NAME>\r", until: "A0>", timeout_ms: 20000}      # assemble
run {input: "LOAD <NAME>\r", until: "A0>"}                        # -> .COM
run {input: "<NAME>\r", until: "A0>"}                              # run, capture output

monitor {command: "SET hb0 HOSTDIR=/home/thoug/Projects/cadzilla/software/<proj>/build"}
run {input: "W <NAME>.COM\r", until: "A0>"}                       # CP/M -> host (binary)
run {input: "W <NAME>.HEX T\r", until: "A0>"}                     # (text)
run {input: "W <NAME>.PRN T\r", until: "A0>"}                     # (text)
```

Since source and build filenames are uppercase on both sides (per the
naming convention above), `R`/`W` need no rename argument at all — the
bare CP/M-side name already matches the desired host filename exactly.
(A rename argument, if you ever use one, is uppercased the same way as
everything else typed at the CP/M console — another reason to just name
things uppercase deliberately rather than fight it.)

**`W` matches an existing host file case-insensitively for overwrite.** If
a lowercase file already exists in the target directory, a `W` whose
(uppercased) name matches it case-insensitively overwrites *that* file in
place — it does not create a separate uppercase-named file alongside it.
Be aware of this if a target directory might already hold a same-named
file in a different case.

**Binary transfers are byte-exact**, verified by round-tripping a 512-byte
file covering the full `00`–`FF` byte range through `R` then `W` with no
`T` flag (identical SHA-256 before and after, including bytes `0D`, `0A`,
and `1A` that text mode treats specially). The only wrinkle is inherent to
CP/M itself, not the host bridge: files are stored in 128-byte records, so
a file whose length isn't a multiple of 128 gets padded with trailing `1A`
(`^Z`) bytes up to the next record boundary on the way in — `W`'d back out
in binary mode, it comes back padded to that same boundary, not its
original length. **Never use the `T` (text) flag on binary data** — it
trims at the *first* `1A` byte found anywhere in the file (not just
trailing padding), which will truncate genuine binary content that happens
to contain that byte value; only use `T` for real text (`.ASM`/`.HEX`/`.PRN`),
where it correctly trims the real trailing `^Z` padding.

Other notes (see `DRIVING-WITH-AI.md` for the full detail):
- Source files must use **CR/LF** line endings — `ASM.COM` silently
  produces an empty assembly on LF-only files.
- `ASM.COM` symbol names can't contain underscores (silently resolve to
  `0`) and are case-insensitive (watch for accidental collisions).
- `ASM.COM` has no `INCLUDE` directive — each `.asm` file is
  self-contained. Projects that need shared code use M80/L80 instead
  (next section).
- If output looks wrong, debug in place rather than guessing:
  `monitor {command: "BREAK <addr>"}`, `STEP`, `DISASM`, `HISTORY`,
  `regs`.

## The M80/L80 toolchain and the czgfx library disk

The pristine CP/M disk also carries Microsoft's MACRO-80 package:
- **M80.COM** (MACRO-80 3.44), the assembler
- **L80.COM** (LINK-80 3.44), the linker
- **LIB80.COM**, the librarian
- **CREF80.COM**, the cross-reference lister

LIB80 and CREF80 were added to the pristine disk on 2026-09-24 from
`MASM-80.ZIP`, after being validated on a separate test disk. That zip's
M80/L80 are byte-identical to the copies already on the disk. The
additions are:

| File | SHA-256 |
|---|---|
| `LIB80.COM` | `28f5af4a73e5317af265abde3d58658df13090bd28a59dafeb5a061f4623aaba` |
| `CREF80.COM` | `2e616ed60957d3179aca7a1acf0dfcf9e11cc4fbcddb7aacb216cdd8eff72218` |

Work disks copied before that date don't have the two new tools;
re-running `sync_pristine.sh` on a work dir brings them in, but that also
discards what's built on that disk.

- **LIB80** combines `.REL` modules into one library:
  - `LIB80 LIB=MOD1,MOD2,.../E` builds it
  - `LIB80 LIB/L/E` lists its modules, entry points and cross-references
  - `LIB80 LIB/U/E` lists the unresolved externals
  - L80 then searches it with `LIB/S`. Keep the module order right
    (callers before callees), because L80 searches in one pass.
- **CREF80** produces a cross-reference listing:
  - assemble with `M80 X,X=X/C`, which writes `X.CRF` instead of `X.PRN`
  - then `CREF80 X=X` writes `X.PRN`, the numbered listing plus a symbol
    table in which `#` marks the defining line

Unlike `ASM.COM`, M80 has `INCLUDE`, real macros (`MACRO`,
`REPT`, `IRP`, `LOCAL`, `IFNB`...), `PUBLIC`/`EXTRN`, and emits
relocatable `.REL` modules that L80 links into a `.COM`. That's what makes
a shared library possible:

- **`software/czgfx/`** is the CADzilla graphics-primitive library. It has
  three parts:
  - the `CZGFX.INC` header: board equates and the `G...` drawing macros
  - `CZGFX.REL`, a LIB80 library of its five modules
  - `CZLINK.SUB`, the link script (`L80 $1,B:CZGFX/S,$1/N$2/E`)

  API reference: `software/czgfx/README.md`.
- czgfx builds all of that onto its own **library disk**,
  `software/czgfx/libdisk/CZGFX.DSK` (gitignored — a build product).
  czgfx's own `work/` mounts it **writable** as drive 1.
- Every M80 consumer project mounts the same disk as **`B:`, read-only**
  (`readonly = true` in its `work/cadzilla.toml`; `SHOW MOUNTS` says
  `(write-protected)`), `INCLUDE`s `B:CZGFX.INC`, and links with
  `SUBMIT B:CZLINK <NAME>` — so it never lists library modules itself,
  and L80's `/S` search pulls in only the modules the program uses.
  `software/gfxdemo/` is the working example.

```
drive 0  A:  software/<project>/work/CPM22-8MB-56K-DEV.DSK   the project's own disk
drive 1  B:  software/czgfx/libdisk/CZGFX.DSK                 czgfx library (read-only here)
```

Build a consumer (from a clean `A0>` on the project's own machine):

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<proj>/src"}
run {input: "R <NAME>.MAC\r", until: "A0>"}
run {input: "M80 <NAME>,<NAME>=<NAME>\r", until: "A0>", timeout_ms: 60000}   # -> .REL + .PRN
run {input: "SUBMIT B:CZLINK <NAME>\r", timeout_ms: 60000}                 # -> .COM (no until: stops when idle)
run {input: "<NAME>\r", until: "A0>"}
```

then `W <NAME>.COM` (binary) and `W <NAME>.PRN T` into `build/` as usual.

**Rebuild the library first when it's stale** — if anything in
`software/czgfx/src/` is newer than `libdisk/CZGFX.DSK`, or the disk
doesn't exist yet: `CONFIG LOAD` czgfx's own `work/cadzilla.toml`, boot,
`R *.*` from `czgfx/src`, `SUBMIT CZBUILD`, `W` the `.REL`/`.PRN` into
`czgfx/build`, and unmount both drives *before* switching the server to a
consumer project. The `cadzilla-build-m80` skill has the full procedure.

M80/L80 gotchas (the `cadzilla-build-m80` skill has more):
- **Global names are 6 characters.** L80 keeps only the first 6 of a
  `PUBLIC`/`EXTRN` name — `LONGNAME1` and `LONGNAME2` link as one
  `%Mult. Def. Global LONGNA`.
- **Every `EXTRN` is a link request.** M80 emits even an unused `EXTRN`,
  and L80 then loads the module that defines it, so a header full of
  `EXTRN`s defeats library pruning. Reference library symbols inline as
  `NAME##` instead; that's what the czgfx macros do.
- With `/M` (link map), L80 stops at its `*` prompt after the map, even
  with `/E` on the line; type `/E` to finish.
- M80's default source extension is `.MAC`; the command is
  `M80 <rel>,<prn>=<src>`. Success prints `No Fatal error(s)`; also
  scan the `.PRN` for a flag letter in column 1.
- **L80 searches libraries in one pass**, both across `/S` files on the
  command line and across the modules inside a LIB80 library: a module
  must come after every module that references it. czgfx's library is
  built in that order, high-level first and `CZCORE` last, by the
  `LIB80 CZGFX=...` line in `CZBUILD.SUB`.
- Source must be relocatable: `CSEG`, no `ORG` — L80 puts the program at
  0100H.
- `SUBMIT` here is SuperSUB; it echoes each line at an `A0>` prompt, so
  don't use `until: "A0>"` on a `SUBMIT` — let the `run` stop when idle.

## Adding a new program

(The `new-cadzilla-project` skill automates all of this, including setting
up the project's own `work/` — this is the manual version if you're not
using it.)

1. `software/<name>/{src,include,build}` — create the directory
   layout (`build/` needs a `.gitkeep`; it's gitignored otherwise), using
   this repo's normal lowercase directory-naming convention.
2. Write `software/<name>/src/<NAME>.ASM` (CR/LF line endings, uppercase
   filename per the naming convention above).
3. If it draws, write `software/<name>/machine.toml` pinning cad0's `mode`
   to the resolution the code programs (see "Display resolution").
4. `tools/altairsim/scripts/sync_pristine.sh software/<name>/work` — give
   the new project its own disk (with the overlay applied).
5. `monitor {command: "CONFIG LOAD <repo-root>/software/<name>/work/cadzilla.toml"}`,
   then drive the build/run/debug loop above through the MCP tools,
   repointing `hb0` between the source directory (for `R`) and `build/`
   (for `W`). The pulled-back `<NAME>.COM`/`.HEX`/`.PRN` land in `build/`
   already named correctly — no renaming needed.

## Ending a session

Let the guest go idle at the `A0>` prompt, then unmount, which flushes the
disk image to the host file:

```
run {}                                      # no input, no until: must say stopped: "idle"
monitor {command: "UNMOUNT dsk0:drive0"}
```

**Stopping on `A0>` is not the same as idle.** This CP/M BIOS keeps the
last track it wrote in a RAM buffer, and writes it to the disk only once
the CCP waits for console input, which happens *after* the `A0>` prompt is
printed. A `run` that stopped on `until: "A0>"` can therefore still have
that write outstanding. Unmounting then either loses it, or cuts it short
halfway through a sector, and the next boot says
`Bdos Err On A: Bad Sector`. This has happened to `software/gfxdemo/work`.
So before any `UNMOUNT`, `CONFIG LOAD` or `reset`, run once with no input
and no `until`, and check that it reports `stopped: "idle"`.

Afterwards, `tools/altairsim/scripts/check_dsk.py software/<name>/work/*.DSK`
should say `ok`.

(And `dsk0:drive1` too — `BLANK-8MB.DSK`, or the czgfx library disk on
an M80 project.)

**Don't force-interrupt a disk operation in flight.** `reset` or `CONFIG
LOAD` mid-`ASM`/`LOAD`/`R`/`W` (e.g. because a `run` call timed out) can
leave the in-memory disk in a half-written state — observed once as a
`.COM` file left with a directory entry showing 0 records despite `LOAD`
having reported a successful write moments earlier, which then made CCP
jump into stale leftover memory instead of the program. If a call times
out, let it keep running (call `run` again with no `input` to keep
draining) rather than resetting; if a project's working disk does end up
in a suspect state, the fix is the same sync used to set it up —
restore it from `pristine/` and rebuild rather than debugging the
corruption:

```bash
tools/altairsim/scripts/sync_pristine.sh software/<name>/work
```

(This discards everything built on that project's disk since the last
sync, so treat it as a deliberate reset, not a reflex.)

Every project's `work/` is gitignored, so nothing needs to be cleaned up
in git — a fresh copy just needs `sync_pristine.sh` re-run against it.
