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

There is no graphics library for this toolchain yet. czgfx is M80 `.REL` code,
which z80asm can't link.

## Install

z88dk is installed as a snap: `sudo snap install z88dk --edge`. The assembler
is `z88dk.z88dk-z80asm`. `z88build.sh` uses that name, or `z88dk-z80asm` from
a native install if there is no snap.

**The snap is confined.** It sees only non-hidden paths under `$HOME`. For any
other path, `/tmp` included, it says `file not found` about files that plainly
exist. The repo lives under `$HOME`, so builds work. `z88build.sh` refuses a
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
