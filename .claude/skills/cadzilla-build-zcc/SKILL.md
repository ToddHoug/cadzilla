---
name: cadzilla-build-zcc
description: Builds, runs and debugs a CADzilla software project written in C with the z88dk zcc toolchain -- lowercase src/*.c sources (plus optional .Z88 assembly modules), compiled on the HOST by z88dk's zcc (sccz80 + the classic CP/M C library) via tools/z88dk/zccbuild.sh for the 8080, 8085 or Z80 named in the project's machine.toml, then copied onto the project's own CP/M disk with R and run on an altairsim machine carrying that same CPU, built by the project's build.sh and run and debugged through the altairsim MCP server. Use this whenever the user wants to build, rebuild, run, test or debug a CADzilla program whose source is a .c file (software/zcc/chello, software/zcc/cgfxdemo, anything scaffolded with --toolchain zcc), draw on the board from C with cz88gfx's C bindings (#include <cz88gfx.h>, cz_ functions), retarget a C program to another CPU, call assembly from C, or asks about writing C for the 8080, 8085, Z80 or CP/M in this repo. To change the C bindings themselves (software/z88dk/cz88gfx), use cadzilla-build-z88dk. For .Z88-only projects use cadzilla-build-z88dk; for .ASM use cadzilla-build-asm (or cadzilla-build-rmac when src/ has a <NAME>.SUB driving DRI RMAC + LINK); for .MAC use cadzilla-build-m80.
---

# Build a CADzilla C project with z88dk (zcc)

These projects are `software/zcc/<name>/src/*.c`, plus any `src/*.Z88` assembly
modules. z88dk's `zcc` compiles them **on the host** for the 8080, 8085 or Z80,
straight into `build/<NAME>.COM`. altairsim then only copies that `.COM` onto
the project's own CP/M disk with `R` and runs it, on an emulated CPU of the
same type. `tools/z88dk/README.md` ("C with zcc") has the background. The
reference project is `software/zcc/chello` (8080).

## 0. Before building

- **Find the names.** The project is `software/zcc/<name>/`. The main module is
  the `src/*.c` that defines `main()`. Its name, uppercased, is the program's
  CP/M name: `src/chello.c` gives `CHELLO.COM`. Look in `src/`; don't guess.
- **C sources are lowercase** (`.c`, `.h`): zcc doesn't recognise `.C`. They
  never reach CP/M, so the repo's uppercase rule doesn't apply to them. `.Z88`
  modules and every build output are uppercase as usual.
- **The CPU** is the `cpu0` block in `software/zcc/<name>/machine.toml`
  (`type = "8080" | "8085" | "z80"`). The build reads it to pick zcc's C
  library (`-clib=8080`, `-clib=8085` or `-clib=default` for the Z80), and the
  work machine gets it as its CPU card. To retarget, edit that block and
  rebuild. `build.sh` sees that `machine.toml` is newer and refreshes
  `work/`'s machine (`sync_pristine.sh --machine-only`), so the emulator
  follows.
- **The project's `work/`** is created by `build.sh` if it's missing.

## 1. Build: the project's `build.sh`

```bash
software/zcc/<name>/build.sh
```

- **First, make sure the MCP server hasn't got this project's `work/`
  loaded** (`monitor {command: "SHOW MOUNTS"}`). If it has, close that
  session out (step 4) before building: two altairsims must never write one
  disk.
- What it does:
  1. creates or refreshes `work/`;
  2. runs `tools/z88dk/zccbuild.sh` on the host;
  3. puts `build/<NAME>.COM` on the project's `A:` with a headless altairsim
     (`tools/altairsim/scripts/cpmsession.py`, not the MCP server), plus
     anything its `cpmbuild.conf` names with `put` (dxfview's `dxf/`
     drawings);
  4. unmounts, and checks the disks.
- `zccbuild.sh` prints `zcc: <NAME> for <cpu> (<modules>)`, then the `.COM`
  size. Any error exits non-zero and deletes `build/<NAME>.COM`. Fix errors
  here; don't go near the emulator until it builds.
- `tools/z88dk/zccbuild.sh software/zcc/<name>` alone is a host-only build.
  Its `.COM` then still needs the `R` in step 2.
- Compiler messages name files relative to `src/` (`chello.c:12:5: ...`).
- Its own errors and warnings:
  - `zcc only accepts lowercase .c/.h`: rename the file.
  - `exactly one .c ... must define main()`: the main module is found by a
    plain search for `main(`.
  - `the program uses the C library's inp()/outp()` (8080/8085): switch to an
    `__sfr __at` port or a `.Z88` polling function (see "C on these CPUs").
  - `<MOD>.Z88: warning: no SECTION`: start the module with
    `SECTION code_user`, or its code lands wherever the linker puts the
    unnamed section.
  - `JP x is z80asm's unconditional jump` and the `interpreting indirect value
    as immediate` error apply to `.Z88` modules exactly as in
    `cadzilla-build-z88dk`.
- Z80-only code is refused for an 8080/8085 build. That covers inline
  `#asm` / `.Z88` code using IX, IY or `exx`, and `-compiler=sdcc`.
- `error: ... outside $HOME`: the z88dk snap can only see non-hidden paths
  under `$HOME` (never `/tmp`).

## 2. Boot the project's machine and run it

The altairsim MCP tools must be loaded (`mcp__altairsim__run`). If they
aren't, point the user at `tools/altairsim/README.md`'s "Starting a
session".

`build.sh` already put the `.COM` on `A:`:

```
monitor {command: "SHOW MOUNTS"}
monitor {command: "CONFIG LOAD <repo-root>/software/zcc/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>", timeout_ms: 10000}
run {input: "<NAME>\r", until: "A0>", timeout_ms: 20000}
```

After a host-only `zccbuild.sh`, copy the `.COM` in by hand before running
it:

```
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/zcc/<name>/build"}
run {input: "R <NAME>.COM\r", until: "A0>", timeout_ms: 15000}
```

- **Never `CONFIG LOAD` or `MOUNT` anything under
  `tools/altairsim/pristine/`.** If another project's disks are still
  mounted, take that session to idle and `UNMOUNT` its drives first.
- **`CONFIG LOAD` resets `hb0`'s `HOSTDIR`.** Set it again after every
  `CONFIG LOAD`.
- **Check that `R` reports `N records`.** If it says
  `R: <NAME>.COM: no such file`, the `.COM` already on the disk, from an
  earlier build, is what will run.
- The prompt is `A0>`, not `A>`.
- **Check the CPU:** the `CONFIG LOAD` output shows its register line. A Z80
  shows `IX`/`IY` and the alternate bank; an 8085 shows its extra `V`/`K`
  flags.
- Confirm the program's own console output appears in the last call. That is
  the real proof. The starter prints `Built for <X>, running on <Y>`, and the
  two should match.
- A C program's `exit()`, or a return from `main()`, goes back to the CCP.
  `A0>` comes back as usual.
- `W` is only for files the program writes in CP/M. Pull them into `build/`
  (binary, never with `T` for binary data).

## 3. Debugging

```
monitor {command: "SYMBOLS LOAD <repo-root>/software/zcc/<name>/build/<NAME>.SYM"}
monitor {command: "BREAK _MAIN"}
run {input: "<NAME>\r", timeout_ms: 15000}        # stops: "breakpoint" at main()
monitor {command: "DISASM _MAIN 8"}
```

- **C names carry a leading underscore and are uppercased:** `main()` is
  `_MAIN`, `cpuid()` is `_CPUID`. `<NAME>.SYM` holds:
  - every public label, the C library's included (`PRINTF`, ...);
  - the locals of the project's own modules.
- In `build/`:
  - `<MOD>.LIS` is each C module's generated code, with its C source
    interleaved. The addresses in it are module-relative.
  - `<NAME>.MAP` has every symbol at its absolute address.
  - `CRT0.LIS` is the CP/M startup code.
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
- Then run `tools/altairsim/scripts/check_dsk.py software/zcc/<name>/work/*.DSK`,
  which should say `ok`, and check that `git status tools/altairsim/pristine`
  is clean.
- Never interrupt `R`/`W` mid-transfer. If a `run` times out, call `run`
  again with no input.

Report the CPU, what was built and run, the console output, and that the
session was unmounted. `build/` and `work/` are gitignored. Don't commit
unless asked.

## C on these CPUs

- **The compiler is sccz80** for all three CPUs; it is the only z88dk
  compiler with 8080/8085 back ends. It handles C89 and most of C99, with
  `int` at 16 bits and `long` at 32. `float` needs `-lm` in `zcc.flags`
  (checked for the 8080 and Z80).
  `-compiler=sdcc` works for the Z80 only, and the asm calling convention
  below changes with it.
- **`zcc.flags`** (tracked, optional) adds zcc flags, one line or several;
  `#` starts a comment. Examples: `-O3`, `-DDEBUG`, `-lm`,
  `-pragma-define:...`.
- **Size:** a `printf` hello is about 7 KB. With floats (`-lm`) it is about
  15 KB on the 8080 and 12 KB on the Z80. The 62K CP/M leaves about 51 KB
  (0100H-CDFFH) for program, data and stack; a `work/` disk synced before
  2026-10-08 is still the 56K system, about 45 KB. The `.COM` size is printed on every build.
- **`#ifdef`:** zcc defines `__8080`, `__8085` or `__Z80`, and `__CPM__`.
- **`\n` prints as CR/LF** on the CP/M console; the library adds the CR.
- **Calling assembly from C** (`src/CPUID.Z88` is the worked example):
  - `SECTION code_user`, and `PUBLIC _name` for the C function `name`.
  - Arguments are pushed left to right, 2 bytes each (a `char` too), and
    the caller pops them. On entry the last argument is at `SP+2`.
  - The result goes back in HL (a `char` in L, a `long` in DEHL).
  - AF, BC, DE and HL are free to change; on a Z80, keep IX and IY.
  - Declare the function in C (`extern int cpuid(void);`).
- **Inline assembly** works too: `#asm` ... `#endasm` inside a function. It
  uses the same z80asm syntax and CPU limits.
- **Port I/O to the CADzilla board** must be interrupt-safe and add no
  overhead when polling. `tools/z88dk/README.md` "Port I/O" has the examples.
  - **One read or write:** `#include <cadzilla.h>` (the shared header in
    `tools/z88dk/include/`, on every zcc project's include path). Then use a
    port like a variable: `sr = CZ_ACRTC_SR;`, `CZ_MODE = CZ_MODE_OLEN;`.
    Each use is one inline `IN`/`OUT` on all three CPUs.
    - Ports: `CZ_ACRTC_SR`/`CZ_ACRTC_AR`, `CZ_MODE` (write only, so keep a
      copy), `CZ_ACRTC_DATA`, `CZ_DAC_ADDR`, `CZ_DAC_PAL`, `CZ_DAC_OVL`.
    - Bits: `CZ_MODE_*`, `CZ_SR_*`, `CZ_DAC_OVL_COLOR1..3`; `CZ_PORT_*` are
      the port numbers.
    - The base is `CZ_BASE` = 0x70. Override it with `-DCZ_BASE=0x..` in
      `zcc.flags`.
    - A multi-access sequence (address, then data) isn't atomic. Disable
      interrupts around it if an interrupt handler uses the same chip.
  - **A polling loop** (wait for an ACRTC status bit) goes in a `.Z88`
    function: `in a,(70h)` / `and 02h` / `jp z,loop`. A C loop around an
    `__sfr` read costs 9 instructions and two library calls per pass.
  - **Never use the C library's `inp()`/`outp()` on the 8080/8085.** They
    call a shared self-modifying RAM stub, which is slow and not
    interrupt-safe. `zccbuild.sh` fails such a build (the `iotmp` error), and
    `inp()` doesn't even link there (`undefined symbol: inp_fastcall`).
- **Graphics: cz88gfx's C bindings** (release 1.1 and later).
  `software/zcc/cgfxdemo` is the worked example.
  - **Setup:** pin a release in `cz88gfx.version` (`echo 1.1 > ...`), then
    `#include <cz88gfx.h>`. `zccbuild.sh` adds the include path and links
    `CZ88GFX.LIB`; its first line names the pin, and a 1.0 pin is an error.
  - **Calls:** `cz_init(CZ_M1K)`, `cz_color(c)`, `cz_move/line/box/fbox`,
    `cz_circle`, `cz_arc`, `cz_paint`, `cz_copy`, `cz_text`,
    `cz_ovl()`/`cz_frame()`, `cz_wait()`, and the rest. Each is the
    `G...` macro's verb with a `cz_` prefix. Constants are `CZ_` (`CZ_RED +
    CZ_BRIGHT`, `CZ_OM_EOR`, `CZ_AM_CLIP`).
  - **Tables** are C arrays in the library's layout: `{n, x0,y0, ...}`.
  - **Under the hood:** each function is a few instructions of assembly
    jumping into the library routine. Draw with these, not with C loops
    over `<cadzilla.h>` ports, which are bigger and slower.
  - **Reference:** `software/z88dk/cz88gfx/README.md`, "Using it from C", has the
    API table.
  - **To verify a drawing,** snapshot the machine and decode it with
    `tools/altairsim/scripts/cadzilla_png.py`.

## Timing

`work/cadzilla.toml` runs flat out. For real-time behaviour, `CONFIG LOAD`
`work/cadzilla-real.toml` instead. It is the same machine with the same CPU,
at 2 MHz with real ACRTC draw times. Copy the `.COM` in under `cadzilla.toml`
first; it stays on the disk.
