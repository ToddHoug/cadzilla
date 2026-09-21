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

This creates `software/<name>/{src,include,build}` (with `.gitkeep` in
`include/` and `build/`, since build output itself is gitignored per the
repo's existing `software/*/build/*` rule) and writes
`software/<name>/src/<NAME>.ASM`: a minimal BDOS-function-9 string-print
stub, self-contained (no `INCLUDE` -- `ASM.COM` doesn't support it) and
free of underscores in any symbol name (`ASM.COM` silently resolves an
underscored symbol to 0 instead of erroring, which is a much worse failure
mode than a normal typo). The welcome message defaults to `Welcome to
CADzilla: <name>!` if not given. `--cpm-name` overrides the CP/M-side name
when the project name itself doesn't fit CP/M's 8.3 limit (e.g. `firstdraw
--cpm-name FIRSTDRW`).

The script is also safe to run against a directory that already exists as
an empty scaffold (`src`/`include`/`build` holding only `.gitkeep`, like
`software/firstdraw` shipped from this repo's initial commit) -- it fills
those in rather than refusing outright, but still won't overwrite a source
file that's already there with real content.

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

**Check the disk is actually mounted before assuming a boot is enough.**
`monitor {command: "SHOW MOUNTS"}` -- if `dsk0:drive0` shows `(empty)`,
that's not a fresh machine, it's a previous session that ended (correctly)
with `UNMOUNT`: CP/M itself may still be sitting at its console prompt
from before, appearing to respond, while every disk access silently fails
(`Bdos Err On A: Bad Sector`) because there's nothing under it any more.
Mounting the disk back with `monitor {command: "MOUNT dsk0:drive0
cpm22b23-56k.dsk"}` isn't quite enough by itself either -- CP/M defensively
marks a drive read-only (`Bdos Err On A: R/O`) when a disk appears without
going through its own disk-change handling. After a `MOUNT`, always follow
with a clean reboot (`run {from: 0xFF00, until: "A>"}`) before touching the
disk again, even if the console already looked alive.

Then, from a confirmed-mounted, freshly-booted `A>` prompt:

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/src"}
run {input: "R <NAME>.ASM\r", until: "A>"}
run {input: "ASM <NAME>\r", until: "A>", timeout_ms: 20000}
run {input: "LOAD <NAME>\r", until: "A>"}
run {input: "<NAME>\r", until: "A>"}
```

Confirm the welcome message actually appears in that last call's output --
that's the real proof the toolchain works, not just that each step
returned without an error. Then pull the build artifacts back:

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/build"}
run {input: "W <NAME>.COM\r", until: "A>"}
run {input: "W <NAME>.HEX T\r", until: "A>"}
run {input: "W <NAME>.PRN T\r", until: "A>"}
monitor {command: "SET hb0 HOSTDIR=<repo-root>"}
```

End at a clean `A>` prompt, then `monitor {command: "UNMOUNT
dsk0:drive0"}` to flush the working disk.

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
  the working disk does end up in a bad state, restore it from the
  pristine master rather than debugging the corruption -- this discards
  anything built since the last clean run, so only do it as a deliberate
  reset, and check with the user first if any other in-progress project's
  disk state might be lost:
  `cp tools/altairsim/pristine/cpm22b23-56k.dsk tools/altairsim/work/`.

## 4. Report back

Tell the user what was created, confirm the build/run check passed (quote
the actual console output), and remind them that `software/<name>/build/`
is gitignored (only `.gitkeep` is tracked) and that nothing has been
staged or committed -- per this repo's convention, only commit when asked.
