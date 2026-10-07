# tools/z88dk — the host cross-assembler toolchain

CADzilla's third toolchain. The other two, DRI `ASM.COM` and Microsoft
`M80`/`L80`, run inside CP/M on altairsim and assemble 8080 code only. This
one assembles on the **host** with [z88dk](https://github.com/z88dk/z88dk)'s
`z80asm`, which:

- targets the **8080, 8085 or Z80**;
- takes **Intel (8080) and Zilog (Z80) mnemonics** alike, even mixed in one
  file. `MVI A,1` and `LD A,1` assemble to the same bytes;
- has `INCLUDE`, `MACRO`, `IF`/`IFDEF`, multi-module linking
  (`PUBLIC`/`EXTERN`) and libraries.

altairsim is still where the program runs. It is also how files get onto and
off the project's CP/M disk: the host bridge's `R` and `W`. The source never
enters CP/M, only the finished `.COM`.

```
src/<NAME>.Z88 ──z88build.sh (host)──► build/<NAME>.COM ──R──► A: on work/CPM22SYS.DSK ──► A0><NAME>
```

The `cadzilla-build-z88dk` skill drives all of this. To start a project, use
the `new-cadzilla-project` skill with `--toolchain z88dk --cpu 8080|8085|z80`.
`software/zhello` is the reference project.

Programs draw with **cz88gfx** (`software/cz88gfx/`), czgfx ported to z80asm
and built into a z80asm library on the host. A project pins a cz88gfx release
in its `cz88gfx.version`, and `z88build.sh` puts `CZ88GFX.INC` on the include
path and links the library. See [Graphics: cz88gfx](#graphics-cz88gfx) below.
czgfx itself, as M80 `.REL` code, can't be linked by z80asm. It stays the
library for the M80 flow.

The same z88dk also compiles **C** for the same three CPUs, and C programs
draw with cz88gfx too, through its C bindings (release 1.1 on): see
[C with zcc](#c-with-zcc) below.

## Install

z88dk is installed as a snap: `sudo snap install z88dk --edge`. The assembler
is `z88dk.z88dk-z80asm`, and the C compiler driver is `z88dk.zcc`. The build
scripts use those names, or `z88dk-z80asm` and `zcc` from a native install if
there is no snap.

**The snap is confined.** It sees only non-hidden paths under `$HOME`. For any
other path, `/tmp` included, it says `file not found` about files that plainly
exist. The repo lives under `$HOME`, so builds work. The build scripts refuse a
project outside `$HOME` with a clear message rather than a baffling one. For
scratch experiments, use `~/snap/z88dk/common/`.

## A project

`software/<name>/`, laid out as for the other toolchains:

| Path | |
|---|---|
| `src/<NAME>.Z88` | the main module: the one `.Z88` with an `ORG` (`ORG 0100H` for a CP/M `.COM`). Its name, uppercase and 8 characters at most, is the CP/M program name |
| `src/*.Z88` | any other modules, linked after the main one |
| `src/`, `include/` | searched for `INCLUDE`d files (`.INC`) |
| `machine.toml` | tracked: the monitor resolution (cad0 `mode`) **and the CPU** (cpu0 `type`) |
| `z88dk.flags` | optional, tracked: extra z80asm flags, e.g. `-ucase`; `#` starts a comment |
| `cz88gfx.version` | optional, tracked: the cz88gfx release it builds against (`1.0`), or `dev`. See [Graphics: cz88gfx](#graphics-cz88gfx) |
| `build/` | build output, gitignored |
| `work/` | the project's own altairsim machine and disks, gitignored |

The `.Z88` extension names the toolchain, not the CPU. The source never passes
through CP/M, so it needs no CR/LF line endings; z80asm takes either.

### The CPU is stated once, in `machine.toml`

```toml
[[board]]
type     = "z80"          # 8080 | 8085 | z80
id       = "cpu0"
clock_hz = 0
```

This one block does two jobs:

- `sync_pristine.sh` appends it to `work/cadzilla.toml`, where a `type` with
  an existing id **replaces** pristine's 8080 with that CPU card. CP/M 2.2 is
  8080 code, so it boots unchanged on the 8085 and Z80 cores.
  `work/cadzilla-real.toml` still sets 2 MHz on top.
- `z88build.sh` reads it for z80asm's `-m8080`, `-m8085` or `-mz80`.

So the code and the emulated CPU can't disagree. With no cpu0 block, both use
pristine's 8080. To change the CPU, edit the block, then run
`tools/altairsim/scripts/sync_pristine.sh --machine-only software/<name>/work`
and rebuild.

z80asm defines one of `__CPU_8080__`, `__CPU_8085__` or `__CPU_Z80__` (and
`__CPU_INTEL__` or `__CPU_ZILOG__`) for `IFDEF`. One source can therefore carry
CPU-specific paths.

## Building

```bash
tools/z88dk/z88build.sh software/<name>
```

It writes into `build/`, using uppercase names like every other build artifact
in this repo:

| File | |
|---|---|
| `<NAME>.COM` | the program, ready for `R` |
| `<NAME>.MAP` | z80asm's map: every symbol, at its absolute address |
| `<NAME>.SYM` | the map's program labels in DR `.SYM` form, for altairsim's `SYMBOLS LOAD`. Constants are left out, so `BDOS` stays `0005` in a `DISASM` |
| `*.LIS`, `*.O` | each module's listing and object file |

It exits non-zero on any error. A failed build deletes `<NAME>.COM`, so an old
one can't pass for current. Its listings stay in `build/` to show where it
failed.

## Running on altairsim

From a clean `A0>` on the project's own machine:

```
monitor {command: "CONFIG LOAD <repo-root>/software/<name>/work/cadzilla.toml"}
run {from: 0xFF00, until: "A0>"}
monitor {command: "SET hb0 HOSTDIR=<repo-root>/software/<name>/build"}
run {input: "R <NAME>.COM\r", until: "A0>"}      # binary: byte-exact
run {input: "<NAME>\r", until: "A0>"}
```

- `W` is only needed for files the program itself writes in CP/M.
- End the session as for any project: `run {}` until `stopped: "idle"`,
  `UNMOUNT` both drives, then run `check_dsk.py`. See
  `tools/altairsim/README.md`.
- To debug, `monitor {command: "SYMBOLS LOAD <repo-root>/software/<name>/build/<NAME>.SYM"}`.
  Then `BREAK START`, `DISASM START`, and so on work by name. Symbols are kept
  across `CONFIG LOAD`; `SYMBOLS CLEAR` drops them.

## Traps, mostly when porting DRI ASM or M80 source

z80asm is a Zilog-first assembler that also accepts Intel mnemonics. Where the
two disagree, the Zilog meaning wins:

- **`JP x` is an unconditional jump, and `CP x` is a compare.** To Intel, both
  are conditional (jump if plus, call if plus). In z80asm, write `JP P,x` and
  `CALL P,x`, or use `JMP` and `CPI` for the other meaning.
  `z88build.sh` warns about a one-operand `JP`/`CP` in any file that uses Intel
  mnemonics.
- **Strings take double quotes:** `DB "text",CR,LF,"$"`. `'A'` is a character
  constant, and `DB 'AB'` is an error.
- **Labels need a colon** (`START: ...`). `EQU` names don't (`BDOS EQU 5`).
- **Symbols are case-sensitive.** `Start` and `START` are two labels. Add
  `-ucase` to `z88dk.flags` for ASM-style case folding.
- **z80asm writes 8080 code for some Z80 instructions when it targets the
  8080/8085.** For example, `ld (nn),sp`, `ld bc,(nn)` and `djnz` become
  multi-instruction 8080 sequences. They are bigger and slower than they look,
  so check the `.LIS`. Others, such as IX/IY and `exx`, are refused outright.
  `-no-synth` in `z88dk.flags` turns the conversion off.
- **One conversion is wrong.** For the 8080/8085, z80asm assembles
  `ld sp,(nn)` as `ld sp,nn`: it loads SP with the *address*, and only warns
  (`interpreting indirect value as immediate`). `z88build.sh` makes that
  warning a build error.
- Hex is `0FFH`, `$FF` or `0xFF`. `$` alone is the current address.
- **`DEFL` substitutes text, not a value.** After `N DEFL 0` and two
  `N DEFL N+1`, `N*19` is `0+1+1*19` = 20, not 38. Parenthesize:
  `N DEFL (N+1)`. This is M80's `SET`, so it bites when porting `REPT` loops.
- **Macro arguments:** no `IFB`/`IFNB` (a macro can't test for a blank
  argument), and no `<...>` grouping. A list is one parenthesized argument,
  and `REPTI` walks it. A macro's only argument written `(a,b)` is read as
  the call's own argument list, so double it: `M ((a,b))`. `IRP` is `REPTI`;
  `REPT`/`REPTI` end with `ENDR`; `MOD` is `%`. M80's `NAME##` external is
  `EXTERN NAME`, and an `EXTERN` nothing uses links nothing in.

## Graphics: cz88gfx

`software/cz88gfx/` is czgfx ported to z80asm: the same 8080 routines,
names and register conventions, in a z80asm library (`CZ88GFX.LIB`) that
links into an 8080, 8085 or Z80 program. Its README has the API, and a
table for porting czgfx code. `software/z88demo/` is gfxdemo ported to it.

- **Using it:** pin a release, `echo 1.1 > software/<name>/cz88gfx.version`
  (`new_project.sh --toolchain z88dk` pins the newest one). Then
  `INCLUDE "CZ88GFX.INC"` and draw. `z88build.sh` adds
  `-I software/cz88gfx/releases/1.1` and `-l=.../CZ88GFX.LIB`, and its
  first line names the pin. Only the library modules the program uses go
  into the `.COM`; the `.MAP` lists them, and the `.SYM` includes their
  labels.
- **Macros:** every argument is required (z80asm can't test for a blank
  one). czgfx's "already in a register" forms are a plain `CALL CZxxxx`.
- **From C:** see [Graphics from C](#graphics-from-c).
- **Changing it:** `software/cz88gfx/tools/build.sh` builds
  `build/CZ88GFX.LIB`, and links its check programs (assembly and C)
  against it for all three CPUs. A project pinned to `dev` builds against
  that. Then raise `CZ88VER` (and `cz88gfx.h`'s `CZ88GFX_VERSION`) and run
  `tools/release.sh` to make a release, `releases/<major>.<minor>/`.

## C with zcc

`tools/z88dk/zccbuild.sh` builds a C project with z88dk's `zcc`:
- it compiles with **sccz80**, z88dk's only compiler for the 8080 and 8085;
- it links the classic CP/M C library (stdio, files, malloc);
- it links any `.Z88` assembly modules the project has.

As with `.Z88`, everything happens on the host. altairsim only `R`s the
`.COM` onto the disk and runs it. The `cadzilla-build-zcc` skill drives it,
and `software/chello` is the reference project. To start a C project, use the
`new-cadzilla-project` skill with `--toolchain zcc --cpu 8080|8085|z80`.

```
src/<name>.c, src/*.c ──────────────────────────┐
src/*.Z88 ──z80asm -m<cpu>──► build/<MOD>.O ────┴─zcc +cpm (host)──► build/<NAME>.COM ──R──► A0><NAME>
```

### A C project

| Path | |
|---|---|
| `src/<name>.c` | the main module: the one `.c` that defines `main()`. Its name, lowercase and 8 characters at most, uppercased is the CP/M program name: `chello.c` → `CHELLO.COM` |
| `src/*.c` | other C modules |
| `src/*.Z88` | optional assembly modules: z80asm syntax, the same CPU, and the same lint as for `z88build.sh` |
| `src/`, `include/` | searched for `#include` (`.h`) and `INCLUDE` files |
| `machine.toml` | tracked: cad0 `mode` and the cpu0 `type`, as above |
| `zcc.flags` | optional, tracked: extra zcc flags, e.g. `-O3`, `-lm`, `-DDEBUG`, `-pragma-define:...`; `#` starts a comment |
| `cz88gfx.version` | optional, tracked: the cz88gfx release it draws with, `1.1` or later (or `dev`). See [Graphics from C](#graphics-from-c) |

**C sources are lowercase.** zcc matches suffixes case-sensitively and won't
take a `.C` or `.H`. The repo's uppercase rule is for files that reach a CP/M
disk; these never leave the host. `.Z88` modules and every build output stay
uppercase.

The cpu0 block picks zcc's CP/M C library, which also sets its `-m` flag and a
predefined macro:

| cpu0 `type` | zcc | defines |
|---|---|---|
| `8080` | `-clib=8080` | `__8080` |
| `8085` | `-clib=8085` | `__8085` |
| `z80` | `-clib=default` | `__Z80` |

`__CPM__` is defined for all three.

### Building

```bash
tools/z88dk/zccbuild.sh software/<name>
```

It writes into `build/`:

| File | |
|---|---|
| `<NAME>.COM` | the program, ready for `R`; the raw binary at `0100H` |
| `<NAME>.MAP` | every symbol at its absolute address, the C library's too |
| `<NAME>.SYM` | DR `.SYM` for `SYMBOLS LOAD`: every public label, and the locals of the project's own modules. C names are uppercased with their `_`, so `main()` is `_MAIN` |
| `<MOD>.LIS` | each C module's generated code with its C source interleaved; each `.Z88` module's listing |
| `CRT0.LIS` | the CP/M startup code's listing |
| `<MOD>.O` | each `.Z88` module's object |

It exits non-zero on any error, and a failed build deletes `<NAME>.COM`.
Running the program is the same as for a `.Z88` project (above).

### Calling assembly from C

`src/CPUID.Z88`, the starter's module, is the worked example.

- **Start the module with `SECTION code_user`.** Without a `SECTION`, the code
  lands wherever the linker puts the unnamed section. `zccbuild.sh` warns about
  that.
- **Names:** the C function `cpuid()` is the assembly label `_cpuid`, made
  `PUBLIC`. Declare it in C as `extern int cpuid(void);`.
- **sccz80 calling convention:**
  - arguments are pushed **left to right**, 2 bytes each (a `char` too), and
    the caller pops them, so on entry the last argument is at `SP+2`;
  - the result goes back in HL (a `char` in L, a `long` in DEHL);
  - AF, BC, DE and HL are free to change; on a Z80, keep IX and IY.
- **Inline assembly:** `#asm` ... `#endasm` inside a C function also works.

### Graphics from C

A zcc project draws with **cz88gfx**, the same library the `.Z88` programs
use, through its C bindings (release 1.1 and later):

```c
#include <cz88gfx.h>

cz_init(CZ_M1K);
cz_color(CZ_WHITE + CZ_BRIGHT);
cz_box(0, 0, 1023, 767);
cz_wait();
```

- **Pinning:** `echo 1.1 > software/<name>/cz88gfx.version`.
  `new_project.sh --toolchain zcc` pins the newest release.
- **What `zccbuild.sh` does with the pin:**
  - it puts the release on the include path, for `cz88gfx.h` and, for the
    project's `.Z88` modules, `CZ88GFX.INC`;
  - it links `CZ88GFX.LIB`;
  - its first line names the pin;
  - a 1.0 pin (no C bindings) is an error.
- **How it works:** each `cz_` function is a few instructions of assembly
  that jump into the library's own routine. It is not a C reimplementation,
  which would be bigger and slower (see [Port I/O](#port-io)). So a C
  program draws exactly what the assembly one does: `software/cgfxdemo`
  draws z88demo's ten screens pixel for pixel.
- **Further reading:** `software/cz88gfx/README.md`, "Using it from C", has
  the API, the conventions and the sizes. `docs/cz88gfx-guide.pdf` is the
  user guide, for assembly and C alike.

### Port I/O

CADzilla code must be interrupt-safe and must not add overhead to port
polling. So there are two rules for port access from C, and one ban.

**One read or write: the ports in `<cadzilla.h>`.**
`tools/z88dk/include/cadzilla.h` declares every board port as an `__sfr`, and
`zccbuild.sh` puts it on every zcc project's include path. Each port works
like a variable. sccz80 compiles each use to one inline `IN`/`OUT` on all
three CPUs, with no call and no shared state:

```c
#include <cadzilla.h>

unsigned char sr = CZ_ACRTC_SR;           /* in  a,(70h) */
if (sr & CZ_SR_CER) ...
CZ_MODE = CZ_MODE_HSPOL | CZ_MODE_VSPOL;  /* out (71h),a */
```

The header holds:

| Kind | Names |
|---|---|
| ports | `CZ_ACRTC_SR` / `CZ_ACRTC_AR` (+0), `CZ_MODE` (+1), `CZ_ACRTC_DATA` (+2), `CZ_DAC_ADDR` (+4), `CZ_DAC_PAL` (+5), `CZ_DAC_OVL` (+7) |
| port numbers | `CZ_PORT_*`, the same ports as numbers |
| MODE bits | `CZ_MODE_HSPOL`, `VSPOL`, `AMODE`, `OLEN`, `OLSEL`. MODE is write only, so keep a copy |
| ACRTC status bits | `CZ_SR_WFE` … `CZ_SR_CER` |
| Bt453 overlay registers | `CZ_DAC_OVL_COLOR1`..`3` |

- Its values come from the board manual, the PLD equations and the datasheets.
  It doesn't depend on czgfx or cz88gfx.
- The base is `CZ_BASE`, `0x70` by default. For a board strapped elsewhere
  (SW1-1..5), put `-DCZ_BASE=0x..` in the project's `zcc.flags`.
- Each access is atomic, but a **sequence** isn't. That covers an address
  register write followed by data, or a Bt453 address followed by R,G,B. If an
  interrupt handler uses the same chip, disable interrupts around the
  sequence.
- Tested in altairsim:
  - the status register reads `23H` after reset (CED, WFR, WFE);
  - a palette entry and an overlay color read back what was written;
  - the board shows the MODE bits that were written.

**A polling loop: a `.Z88` function.** The access is inline, but sccz80
widens the test around it to 16 bits. `while (!(CZ_ACRTC_SR & CZ_SR_WFR));`
costs 9 instructions and two library calls (`l_and`, `l_lneg`) per pass on the
8080; `-O3` doesn't change that. In assembly it is 3 instructions:

```asm
        SECTION code_user
        PUBLIC  _acrtc_wait_wfr
_acrtc_wait_wfr:                        ; void acrtc_wait_wfr(void)
        in      a,(70h)                 ; CZ_ACRTC_SR
        and     02h                     ; CZ_SR_WFR: write FIFO ready
        jp      z,_acrtc_wait_wfr
        ret
```

**The ban: the C library's `inp()`/`outp()` on the 8080/8085.** The 8080's
`IN`/`OUT` take only a fixed port, so the library builds an `IN port`/`RET`
or `OUT port`/`RET` stub in a shared 3-byte RAM buffer (`iotmp`) and calls it.
That is slow. It is also not interrupt-safe: an interrupt handler that does
port I/O in the middle of a call rewrites the stub.

`zccbuild.sh` fails an 8080/8085 build that links `iotmp`. `inp()` doesn't
link there anyway: `<stdlib.h>` maps it to `inp_fastcall`, which only the Z80
library exports. On the Z80 both are plain `IN`/`OUT (C)` and safe, but
`__sfr` is still better, because it avoids the call.

### Library notes

- A `printf` hello is about 7 KB. With floats (`-lm`), it is about 15 KB on the
  8080 and 12 KB on the Z80.
- `\n` prints as CR/LF on the CP/M console.
- For port I/O, see [Port I/O](#port-io): use `__sfr __at`, not
  `inp()`/`outp()`.
- `-compiler=sdcc` in `zcc.flags` works for the Z80 only, and it changes the
  calling convention.
- For graphics, use cz88gfx's C bindings; see
  [Graphics from C](#graphics-from-c). czgfx itself is M80 `.REL` code and
  can't be linked.
