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
CP/M `A>` prompt. The same name is used consistently everywhere — no
renaming between host and CP/M. Directory names (`software/hello/`, `src/`,
`build/`) still follow this repo's normal lowercase convention
(`CLAUDE.md`); only the files themselves are uppercase.

This also sidesteps a real gotcha explained below: CP/M uppercases
everything you type at its console anyway, so a mixed-case CP/M-side name
could never be created from the command line in the first place.

## Layout

- `pristine/` — the read-only master copy of the CP/M machine definition
  (`cadzilla.toml`) and disk image (`cpm22b23-56k.dsk`, Mike Douglas's
  track-buffered CP/M 2.2b, already carrying `ASM.COM`, `LOAD.COM`,
  `DDT.COM`, and the host-bridge `R`/`W`/`HDIR.COM` utilities). **Never
  edit or boot these directly.** `cadzilla.toml` is a delta on altairsim's
  own `machines/cadzilla.toml` — the real board (8080, console, the
  HD63484/Bt453 graphics board) — with CP/M boot support layered on top
  (front panel, disk controller, host bridge, and a 56K+ROM memory map in
  place of the base's 64K of plain RAM). See the comments in the file
  itself for the full reasoning, including why its `cpu0` clock is forced
  back to flat-out despite the real board running at 2MHz.
- `work/` — **gitignored.** A working copy of the pristine files, created
  fresh at the start of a session. CP/M writes to its mounted disk in
  place with no undo, so all mutation happens here, never in `pristine/`.
- `DRIVING-WITH-AI.md` — altairsim's own guide for driving it via MCP
  (kept here for reference; canonical copy lives in `~/altairsim/docs/`).

## One-time setup (per machine)

The `claude` CLI isn't always on `PATH` in every environment (e.g. inside
the VS Code extension's sandboxed shell, it's bundled as a native binary
instead). If `claude --version` doesn't work, find the bundled binary
under `~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude`
and symlink it onto `PATH`:

```bash
ln -s ~/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude \
      ~/.local/bin/claude
```

## Starting a session

From the **repo root**:

```bash
cd /home/thoug/Projects/cadzilla
mkdir -p tools/altairsim/work
cp tools/altairsim/pristine/cadzilla.toml tools/altairsim/pristine/cpm22b23-56k.dsk tools/altairsim/work/

claude mcp add altairsim -- /home/thoug/altairsim/build/altairsim tools/altairsim/work/cadzilla.toml --mcp
claude mcp list   # confirm "altairsim" is registered and reachable
```

Registration uses local scope (the default) since it embeds an absolute,
machine-specific path to the altairsim binary — it's stored in your own
Claude config, not committed to the repo. A newly registered MCP server's
tools may not appear until the session/window is reloaded.

### Resuming a session — check the disk is actually mounted

Once registered, the `altairsim` MCP server is a long-lived process that
can easily outlive a single conversation — a later Claude Code session (or
even a later turn in the same one) may find the guest already booted and
sitting at `A>` from before. That's not the same as a fresh, working
machine: if the previous session ended cleanly with `UNMOUNT` (as it
should), the disk is gone from under a CP/M that's still technically
"running" and looks alive. Every disk access then fails with `Bdos Err On
A: Bad Sector`, which reads like corruption but isn't — there's simply
nothing mounted.

Check first: `monitor {command: "SHOW MOUNTS"}`. If `dsk0:drive0` shows
`(empty)`, mount it back — `monitor {command: "MOUNT dsk0:drive0
cpm22b23-56k.dsk"}` — and then do a clean reboot, `run {from: 0xFF00,
until: "A>"}`, before touching the disk again. The reboot isn't optional:
mounting a disk out from under a CP/M that's already running (rather than
through its own boot-time disk detection) makes BDOS defensively mark the
drive read-only (`Bdos Err On A: R/O`) until the next warm boot clears it.

### The host bridge (`R`/`W`) and CP/M's automatic uppercasing

`R`/`W` genuinely do support subdirectory paths and a rename argument (e.g.
`R SUBDIR/FOO.TXT` works, and `W FOO.BIN RENAMED.BIN` really does create
`RENAMED.BIN`) — confirmed by testing directly against an **uppercase**
scratch subdirectory. The catch is CP/M itself: the CCP reads the command
line through BDOS function 10 (buffered console input), which **uppercases
every lowercase letter you type** before any program — including `R`/`W`
— ever sees it. Since this repo's directories and filenames are lowercase
by convention (per `CLAUDE.md`), any path or filename typed at the `A>`
prompt gets uppercased first and then fails a case-sensitive lookup against
the real lowercase host paths (`R software/hello/src/hello.asm HELLO.ASM`
becomes `R SOFTWARE/HELLO/SRC/HELLO.ASM HELLO.ASM` internally, and
`software/` on the host doesn't match `SOFTWARE/`).

There's no way around the uppercasing from inside CP/M — instead, repoint
`hb0` at the exact directory you need with `SET hb0 HOSTDIR=<abs path>`
(a `monitor` command, entered outside CP/M's console and therefore not
subject to its uppercasing) before each `R`/`W`, and use bare filenames:

```
run {from: 0xFF00, until: "A>"}                                   # boot CP/M

monitor {command: "SET hb0 HOSTDIR=/home/thoug/Projects/cadzilla/software/<proj>/src"}
run {input: "R <NAME>.ASM\r", until: "A>"}                        # host -> CP/M

run {input: "ASM <NAME>\r", until: "A>", timeout_ms: 20000}       # assemble
run {input: "LOAD <NAME>\r", until: "A>"}                         # -> .COM
run {input: "<NAME>\r", until: "A>"}                               # run, capture output

monitor {command: "SET hb0 HOSTDIR=/home/thoug/Projects/cadzilla/software/<proj>/build"}
run {input: "W <NAME>.COM\r", until: "A>"}                        # CP/M -> host (binary)
run {input: "W <NAME>.HEX T\r", until: "A>"}                      # (text)
run {input: "W <NAME>.PRN T\r", until: "A>"}                      # (text)
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
  self-contained.
- If output looks wrong, debug in place rather than guessing:
  `monitor {command: "BREAK <addr>"}`, `STEP`, `DISASM`, `HISTORY`,
  `regs`.

## Adding a new program

1. `software/<name>/{src,include,build}` — create the directory
   layout (`build/` needs a `.gitkeep`; it's gitignored otherwise), using
   this repo's normal lowercase directory-naming convention.
2. Write `software/<name>/src/<NAME>.ASM` (CR/LF line endings, uppercase
   filename per the naming convention above).
3. Drive the build/run/debug loop above through the MCP tools, repointing
   `hb0` between the source directory (for `R`) and `build/` (for `W`).
   The pulled-back `<NAME>.COM`/`.HEX`/`.PRN` land in `build/` already
   named correctly — no renaming needed.

## Ending a session

Make sure you're back at the `A>` prompt, then flush the working disk's
track buffer to the host file:

```
monitor {command: "UNMOUNT dsk0:drive0"}
```

**Don't force-interrupt a disk operation in flight.** `reset` or `CONFIG
LOAD` mid-`ASM`/`LOAD`/`R`/`W` (e.g. because a `run` call timed out) can
leave the in-memory disk in a half-written state — observed once as a
`.COM` file left with a directory entry showing 0 records despite `LOAD`
having reported a successful write moments earlier, which then made CCP
jump into stale leftover memory instead of the program. If a call times
out, let it keep running (call `run` again with no `input` to keep
draining) rather than resetting; if the disk does end up in a suspect
state, the fix is to restore `work/` from `pristine/` and rebuild rather
than debugging the corruption:

```bash
cp tools/altairsim/pristine/cpm22b23-56k.dsk tools/altairsim/work/
```

(`monitor {command: "CONFIG LOAD <path-to-toml>"}` reloads the running
server's machine definition without restarting the MCP connection — handy
after editing the `.toml`, but treat it the same as a reset for this
purpose: only do it between commands, at a clean `A>` prompt.)

`work/` is gitignored, so nothing needs to be cleaned up in git — the next
session just re-copies from `pristine/`.
