---
name: new-cadzilla-project
description: Scaffolds a new 8080/CP/M software project in the CADzilla repo under software/<name>/, with a correctly CR/LF-terminated, CP/M-uppercased starter assembly source file, then drives the altairsim MCP server through a first assemble/load/run to prove the toolchain actually works before real development starts. Use this whenever the user wants to start a new CADzilla software project, add a new program under software/, or scaffold an 8080 assembly source file for this repo -- even if they just say "make a new project called X" or "let's write a program that does Y" without mentioning CP/M, altairsim, or assembly explicitly. Also use it if the user asks how to add a new program to the repo.
---

# New CADzilla project

Every CADzilla software project is 8080 assembly that assembles and runs
under CP/M 2.2 on the altairsim emulator, driven through altairsim's MCP
server. `tools/altairsim/README.md` documents the full workflow and the
gotchas found while building it; this skill exists so those gotchas don't
have to be rediscovered every time a new project starts. `software/hello/`
is a working reference example if anything here is ambiguous.

## 1. Get the project name

Ask the user if they haven't given one. The directory name follows this
repo's normal convention (`software/<name>/`, matching `software/hello`,
`software/firstdraw`) -- lowercase letters and digits, starting with a
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
.claude/skills/new-cadzilla-project/scripts/new_project.sh <name> [--cpm-name NAME] ["<welcome message>"]
```

This creates `software/<name>/{src,include,build,work}` (with `.gitkeep`
in `include/` and `build/`, since build output itself is gitignored per
the repo's existing `software/*/build/*` rule) and writes
`software/<name>/src/<NAME>.ASM`: a minimal BDOS-function-9 string-print
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
`software/firstdraw` shipped from this repo's initial commit) -- it fills
those in rather than refusing outright, but still won't overwrite a source
file that's already there with real content, and skips creating `work/` if
one's already there.

This is meant as a starting point the user then edits, not a finished
program -- say so, and point at the file, once it's created.

## 3. Prove the toolchain works

Don't stop at "the file exists" -- actually assemble, load, and run the
stub through the altairsim MCP tools, the same way `software/hello` was
verified, so the user starts editing a project that's already known to
build rather than discovering a toolchain problem later mixed in with
their own code changes.

First confirm the altairsim MCP tools are available (e.g. search for
`mcp__altairsim__run`). If they're not, the MCP server likely isn't
registered in this session yet -- stop and point the user at
`tools/altairsim/README.md`'s "Starting a session" section rather than
guessing at setup steps.

**Point the server at this project's own disk.** Step 2 already gave
`software/<name>/` its own `work/` directory (a fresh copy of the pristine
machine + disk, synced by the script itself), so there's nothing to reset
-- just switch the running server onto it and boot:

```
monitor {command: "CONFIG LOAD <repo-root>/software/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>"}
```

Note the prompt is `A0>`, not a plain `A>` -- this CP/M build boots off an
8MB virtual drive and numbers logical units (`A0>`, `B0>`, ...). Match
`until` against `A0>` for every call below; `until: "A>"` won't match it at
all, so every call would run to its full timeout instead of stopping
cleanly at the prompt.

Then, from a freshly-booted `A0>` prompt:

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/src"}
run {input: "R <NAME>.ASM\r", until: "A0>"}
run {input: "ASM <NAME>\r", until: "A0>", timeout_ms: 20000}
run {input: "LOAD <NAME>\r", until: "A0>"}
run {input: "<NAME>\r", until: "A0>"}
```

Confirm the welcome message actually appears in that last call's output --
that's the real proof the toolchain works, not just that each step
returned without an error. Then pull the build artifacts back:

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/build"}
run {input: "W <NAME>.COM\r", until: "A0>"}
run {input: "W <NAME>.HEX T\r", until: "A0>"}
run {input: "W <NAME>.PRN T\r", until: "A0>"}
monitor {command: "SET hb0 HOSTDIR=<repo-root>"}
```

End at a clean `A0>` prompt, then `monitor {command: "UNMOUNT
dsk0:drive0"}` (and `dsk0:drive1` if it ever gets mounted too) to flush
this project's working disk.

### Things that will bite you if you skip them

- **CP/M uppercases everything typed at its console** (a real BDOS
  behavior, not an altairsim quirk), so `R`/`W` can't be given a path like
  `software/<name>/src/<NAME>.ASM` directly -- it gets uppercased and then
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
  `tools/altairsim/scripts/sync_pristine.sh software/<name>/work` recovers
  it -- but that discards anything built there since the last sync, so
  treat an unplanned reset as a deliberate call, not a reflex, and check
  with the user first.
- **A long-lived MCP server may not be booted yet, or may be sitting at a
  stale prompt from whatever it was last doing.** `monitor {command: "SHOW
  MOUNTS"}` before assuming a `CONFIG LOAD` + boot is unnecessary, and
  `regs` if the guest seems unresponsive -- PC 0 with every register
  zeroed means nothing's booted yet, not that something's wrong.

## 4. Report back

Tell the user what was created, confirm the build/run check passed (quote
the actual console output), and remind them that `software/<name>/build/`
is gitignored (only `.gitkeep` is tracked) and that nothing has been
staged or committed -- per this repo's convention, only commit when asked.
