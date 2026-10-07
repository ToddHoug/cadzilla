#!/usr/bin/env bash
# Scaffold a new CADzilla software project: software/<name>/{src,include,build}
# plus a minimal starter assembly source file, correctly CR/LF-terminated and
# uppercased for CP/M.
#
# Usage: new_project.sh <project-name> [--toolchain asm|m80|z88dk] [--cpu 8080|8085|z80] [--mode WxH] [--cpm-name NAME] [welcome-message]
#
# --mode is the display resolution: 640x480, 800x600 or 1024x768 (default,
# the pristine machine's). It is written to the project's tracked
# software/<name>/machine.toml overlay as cad0's `mode` strap, which
# sync_pristine.sh applies to work/cadzilla.toml; an m80 stub's GINIT gets the
# matching czgfx descriptor. An existing machine.toml is never overwritten.
#
# --toolchain picks the assembler (default asm):
#   asm  DRI ASM.COM + LOAD.COM: one self-contained <NAME>.ASM, no INCLUDE,
#        no linker -- the original CP/M flow (cadzilla-build-asm skill).
#   m80  Microsoft M80 + L80: a relocatable <NAME>.MAC that INCLUDEs the
#        czgfx graphics library header from B: and links against its .REL
#        modules (cadzilla-build-m80 skill). The project pins the newest
#        czgfx release in software/<name>/czgfx.version, and its work machine
#        gets its own copy of that release as drive 1 (B:), read-only.
#   z88dk  z88dk's z80asm, run on the HOST (tools/z88dk/z88build.sh): a
#        <NAME>.Z88 in Intel and/or Zilog mnemonics, built straight to
#        build/<NAME>.COM, which altairsim then only R's onto the disk and runs
#        (cadzilla-build-z88dk skill). No czgfx.
#
# --cpu (z88dk only; default 8080) is the target CPU: 8080, 8085 or z80. It is
# written to machine.toml as a cpu0 [[board]] block, which both puts that CPU in
# the emulator and gives z80asm its -m flag. An existing machine.toml's cpu0
# wins over --cpu, as its mode wins over --mode.
#
# --cpm-name is for when <project-name> itself doesn't fit CP/M's 8.3 limit
# (8 characters before the extension) -- e.g. `new_project.sh firstdraw
# --cpm-name FIRSTDRW`. Without it, the CP/M-side name is just <project-name>
# uppercased.
set -euo pipefail

NAME=""
MESSAGE=""
CPM_NAME_OVERRIDE=""
TOOLCHAIN="asm"
MODE="1024x768"
CPU=""

while [ $# -gt 0 ]; do
  case "$1" in
    --mode)
      if [ $# -lt 2 ]; then
        echo "error: --mode needs a value (640x480, 800x600 or 1024x768)" >&2
        exit 1
      fi
      MODE="$2"
      shift 2
      ;;
    --cpu)
      if [ $# -lt 2 ]; then
        echo "error: --cpu needs a value (8080, 8085 or z80)" >&2
        exit 1
      fi
      CPU="$2"
      shift 2
      ;;
    --toolchain)
      if [ $# -lt 2 ]; then
        echo "error: --toolchain needs a value (asm, m80 or z88dk)" >&2
        exit 1
      fi
      TOOLCHAIN="$2"
      shift 2
      ;;
    --cpm-name)
      if [ $# -lt 2 ]; then
        echo "error: --cpm-name needs a value" >&2
        exit 1
      fi
      CPM_NAME_OVERRIDE="$2"
      shift 2
      ;;
    *)
      if [ -z "$NAME" ]; then
        NAME="$1"
      elif [ -z "$MESSAGE" ]; then
        MESSAGE="$1"
      else
        echo "error: unexpected extra argument '$1'" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$NAME" ]; then
  echo "Usage: $0 <project-name> [--toolchain asm|m80|z88dk] [--cpu 8080|8085|z80] [--mode WxH] [--cpm-name NAME] [welcome-message]" >&2
  exit 1
fi

# The resolution: the czgfx descriptor for it, and the m80 stub's frame and a
# centered box (an eighth of the width) in that mode's coordinates.
set_mode() {
  case "$1" in
    640x480)  CZMODE="CZM640"; XMAX=639;  YMAX=479; BOX="280,200,360,280" ;;
    800x600)  CZMODE="CZM800"; XMAX=799;  YMAX=599; BOX="350,250,450,350" ;;
    1024x768) CZMODE="CZM1K";  XMAX=1023; YMAX=767; BOX="448,320,576,448" ;;
    *)
      echo "error: mode must be 640x480, 800x600 or 1024x768, not '$1'" >&2
      exit 1
      ;;
  esac
  MODE="$1"
}
set_mode "$MODE"

case "$TOOLCHAIN" in
  asm) EXT="ASM" ;;
  m80) EXT="MAC" ;;
  z88dk) EXT="Z88" ;;
  *)
    echo "error: --toolchain must be asm, m80 or z88dk, not '$TOOLCHAIN'" >&2
    exit 1
    ;;
esac

# The target CPU: only the z88dk toolchain assembles for anything but the 8080.
if [ "$TOOLCHAIN" = "z88dk" ]; then
  CPU="${CPU:-8080}"
  case "$CPU" in
    8080|8085|z80) ;;
    *)
      echo "error: --cpu must be 8080, 8085 or z80, not '$CPU'" >&2
      exit 1
      ;;
  esac
elif [ -n "$CPU" ]; then
  echo "error: --cpu is for --toolchain z88dk only (ASM.COM and M80 assemble 8080 code)" >&2
  exit 1
fi

MESSAGE="${MESSAGE:-Welcome to CADzilla: ${NAME}!}"

if [ "$TOOLCHAIN" = "z88dk" ]; then
  if [[ "$MESSAGE" == *'"'* ]]; then
    echo "error: welcome message can't contain a double quote -- it goes inside a DB \"...\" string in the source and would break the assembly" >&2
    exit 1
  fi
elif [[ "$MESSAGE" == *"'"* ]]; then
  echo "error: welcome message can't contain a single quote -- it goes inside a DB '...' string in the source and would break the assembly" >&2
  exit 1
fi
if [[ "$MESSAGE" == *'$'* ]]; then
  echo "error: welcome message can't contain a \$ -- BDOS function 9 stops printing at the first one" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PROJECT_DIR="$REPO_ROOT/software/$NAME"

# This repo's directory-naming convention (CLAUDE.md): lowercase, matching the
# existing software/hello, software/firstdraw. Keep it simple and predictable
# rather than trying to slugify arbitrary input.
if [[ ! "$NAME" =~ ^[a-z][a-z0-9]*$ ]]; then
  echo "error: '$NAME' must be lowercase letters/digits, starting with a letter" >&2
  exit 1
fi

# The CP/M-side name is the project name, uppercased (CLAUDE.md: files that
# pass through the CP/M toolchain are uppercase on both the host and the
# CP/M side) -- unless --cpm-name gave an explicit one, for when the project
# name itself is too long for CP/M's 8.3 format.
if [ -n "$CPM_NAME_OVERRIDE" ]; then
  CPM_NAME="$(printf '%s' "$CPM_NAME_OVERRIDE" | tr '[:lower:]' '[:upper:]')"
else
  CPM_NAME="$(printf '%s' "$NAME" | tr '[:lower:]' '[:upper:]')"
fi

if [[ ! "$CPM_NAME" =~ ^[A-Z][A-Z0-9]*$ ]]; then
  echo "error: CP/M-side name '$CPM_NAME' must be letters/digits only, starting with a letter (no underscores -- ASM.COM silently resolves those to 0 instead of erroring)" >&2
  exit 1
fi
if [ "${#CPM_NAME}" -gt 8 ]; then
  if [ -n "$CPM_NAME_OVERRIDE" ]; then
    echo "error: '$CPM_NAME' is ${#CPM_NAME} characters -- CP/M 8.3 filenames allow at most 8 before the extension." >&2
  else
    echo "error: '$NAME' is ${#CPM_NAME} characters -- CP/M 8.3 filenames allow at most 8 before the extension. Pick a shorter name, or keep this one and give an explicit --cpm-name NAME (8 characters or fewer)." >&2
  fi
  exit 1
fi
case "$CPM_NAME" in
  CON|PRN|AUX|LST|RDR|PUN)
    echo "error: '$CPM_NAME' is a reserved CP/M device name -- pick another" >&2
    exit 1
    ;;
esac

# The directory itself may already exist -- e.g. an empty scaffold checked in
# ahead of time (software/firstdraw's src/include/build with only .gitkeep in
# them). That's fine to fill in. What's NOT fine is clobbering a source file
# that's already there with real content in it.
ASM_PATH="$PROJECT_DIR/src/$CPM_NAME.$EXT"
if [ -e "$ASM_PATH" ]; then
  echo "error: $ASM_PATH already exists -- not overwriting it" >&2
  exit 1
fi

mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/include" "$PROJECT_DIR/build"
touch "$PROJECT_DIR/include/.gitkeep" "$PROJECT_DIR/build/.gitkeep"

# The project's own board straps, tracked in git: above all the monitor
# resolution, which the program's code has to agree with. Written before the
# work/ sync below so the overlay goes straight into work/cadzilla.toml.
OVERLAY="$PROJECT_DIR/machine.toml"
if [ -e "$OVERLAY" ]; then
  EXISTING="$(sed -n 's/^[[:space:]]*mode[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$OVERLAY" | tail -n1)"
  if [ -n "$EXISTING" ]; then
    set_mode "$EXISTING"
  fi
  if [ "$TOOLCHAIN" = "z88dk" ]; then
    # Its cpu0 block, read as tools/z88dk/z88build.sh reads it.
    EXISTING_CPU="$(awk '
      /^[[:space:]]*\[/ { if (id == "cpu0" && type != "") cpu = type; id = ""; type = ""; next }
      /^[[:space:]]*id[[:space:]]*=/   { s = $0; sub(/#.*/, "", s); gsub(/.*=[[:space:]]*"|".*/, "", s); id = s }
      /^[[:space:]]*type[[:space:]]*=/ { s = $0; sub(/#.*/, "", s); gsub(/.*=[[:space:]]*"|".*/, "", s); type = s }
      END { if (id == "cpu0" && type != "") cpu = type; print cpu }
    ' "$OVERLAY")"
    if [ -n "$EXISTING_CPU" ]; then
      CPU="$EXISTING_CPU"
    else
      echo "warning: $OVERLAY has no cpu0 block -- the machine and z88build.sh both use pristine's 8080" >&2
      CPU="8080"
    fi
    echo "Keeping existing $OVERLAY (mode $MODE, cpu $CPU)"
  else
    echo "Keeping existing $OVERLAY (mode $MODE)"
  fi
else
  if [ "$TOOLCHAIN" = "m80" ]; then
    AGREE="GINIT $CZMODE in src/$CPM_NAME.MAC must agree with it"
  else
    AGREE="if the program programs the ACRTC, its timing must agree with it"
  fi
  cat > "$OVERLAY" <<EOF
# software/$NAME's own straps on top of tools/altairsim/pristine/cadzilla.toml.
# tools/altairsim/scripts/sync_pristine.sh appends this to work/cadzilla.toml
# (a later [[board]] block for the same id overrides pristine's). Only
# [[board]] tables may appear here.
#
# The monitor resolution: 640x480, 800x600 or 1024x768 --
# $AGREE.
[[board]]
id   = "cad0"
mode = "$MODE"
EOF
  if [ "$TOOLCHAIN" = "z88dk" ]; then
    cat >> "$OVERLAY" <<EOF

# The CPU: 8080, 8085 or z80. A \`type\` replaces pristine's cpu0 outright, so
# clock_hz is restated (flat out; cadzilla-real.toml still sets 2 MHz on top).
# tools/z88dk/z88build.sh reads this same block for z80asm's -m flag, so the
# code and the emulated CPU always agree.
[[board]]
type     = "$CPU"
id       = "cpu0"
clock_hz = 0
EOF
  fi
fi

# Each project gets its own altairsim work directory (gitignored) -- its own
# persistent copy of the pristine machine + disk(s), so building this project
# never shares (and never fills up) another project's disk. If one's already
# there (e.g. re-running against an existing scaffold), keep its disks and just
# refresh its machine file so the overlay above is in it.
if [ ! -d "$PROJECT_DIR/work" ]; then
  "$REPO_ROOT/tools/altairsim/scripts/sync_pristine.sh" "$PROJECT_DIR/work"
else
  "$REPO_ROOT/tools/altairsim/scripts/sync_pristine.sh" --machine-only "$PROJECT_DIR/work"
fi

# An M80 project reads the czgfx library from drive B:, from its own copy of a
# czgfx release in work/. It pins the release in its tracked czgfx.version --
# the newest one, for a new project; an existing pin is never changed -- and
# attach_libdisk.sh copies that release in and mounts it, read-only.
# (Idempotent, so it's also safe on an existing work/.)
if [ "$TOOLCHAIN" = "m80" ]; then
  PIN="$PROJECT_DIR/czgfx.version"
  if [ ! -f "$PIN" ]; then
    LATEST="$(ls "$REPO_ROOT/software/czgfx/releases" 2>/dev/null \
              | sed -nE 's/^CZGFXLIB-([0-9]+\.[0-9]+)\.DSK$/\1/p' | sort -V | tail -n1)"
    if [ -z "$LATEST" ]; then
      echo "error: no czgfx release in software/czgfx/releases -- release one first" >&2
      exit 1
    fi
    echo "$LATEST" > "$PIN"
    echo "Pinned czgfx $LATEST in $PIN"
  fi
  "$REPO_ROOT/tools/altairsim/scripts/attach_libdisk.sh" "$PROJECT_DIR/work"
fi

if [ "$TOOLCHAIN" = "m80" ]; then
# A minimal czgfx starter: set up the board, draw a frame and a filled box,
# wait for the drawing to finish, then print the message and return to CP/M.
# Relocatable (CSEG, no ORG) -- L80 places it at 0100H.
cat > "$ASM_PATH" <<EOF
;
; $CPM_NAME.MAC -- CADzilla program using the czgfx graphics library
;
; Build (czgfx library disk mounted as B:, see cadzilla-build-m80):
;   A0>M80 $CPM_NAME,$CPM_NAME=$CPM_NAME
;   A0>SUBMIT B:CZLINK $CPM_NAME
;
        INCLUDE B:CZGFX.INC
;
BDOS    EQU     0005H
PSTRING EQU     9
CR      EQU     0DH
LF      EQU     0AH
;
        CSEG
;
START:  LXI     H,0             ;keep CCP's stack, run on our own
        DAD     SP
        SHLD    OLDSP
        LXI     SP,STACK
;
        GINIT   $CZMODE          ;$MODE (= machine.toml), screen cleared
        GCOLOR  WHITE+BRIGHT
        GBOX    0,0,$XMAX,$YMAX     ;frame around the whole screen
        GFBOX   $BOX,BLUE+BRIGHT
        GWAIT                   ;let the ACRTC finish drawing
;
        LXI     D,MSG
        MVI     C,PSTRING
        CALL    BDOS
        LHLD    OLDSP
        SPHL
        RET
;
MSG:    DB      '$MESSAGE',CR,LF,'\$'
;
OLDSP:  DS      2
        DS      64
STACK:
;
        END     START
EOF
elif [ "$TOOLCHAIN" = "z88dk" ]; then
# A z88dk starter: print the message, then the CPU it was assembled for and the
# CPU it finds itself running on. Intel mnemonics for the 8080/8085, Zilog for
# the Z80 (with Z80-only instructions, so a wrong -m fails the build). No
# CR/LF needed -- z80asm runs on the host and takes either line ending.
if [ "$CPU" = "z80" ]; then
cat > "$ASM_PATH" <<EOF
; $CPM_NAME.Z88 -- CADzilla program, z88dk toolchain
;
; Built on the host by z88dk's z80asm, then copied onto the CP/M disk and run
; (cadzilla-build-z88dk skill):
;   tools/z88dk/z88build.sh software/$NAME       -> build/$CPM_NAME.COM
;   A0>R $CPM_NAME.COM                          (hb0 HOSTDIR = build/)
;   A0>$CPM_NAME
;
; The target CPU ($CPU) is machine.toml's cpu0 block: it is both the emulated
; CPU and z80asm's -m flag. z80asm takes Intel and Zilog mnemonics alike, even
; mixed in one file -- but JP and CP always mean the Zilog jump and compare
; (tools/z88dk/README.md).
;
; The program prints the CPU it was built for and the one it is running on;
; the two should always match.
;
        ORG     0100H           ;a CP/M .COM
;
BDOS    EQU     0005H
PSTRING EQU     9
CR      EQU     0DH
LF      EQU     0AH
;
start:  ld      ix,0            ;keep CCP's stack, run on our own. IX is
        add     ix,sp           ;Z80-only, so -m8080/-m8085 refuse these
        ld      (oldsp),ix      ;(z80asm makes 8080 code for some others)
        ld      sp,stack
        ld      de,MSG
        call    print
        ld      de,BUILT
        call    print
;
; Which CPU is this? 7FH+1 overflows: the Z80 sets P/V for that, the 8080 and
; 8085 set P for parity, and 80H has odd parity, so P is clear.
        ld      a,7fh
        inc     a
        ld      de,CZ80
        jp      pe,show
; The 8085's ANA always sets AC; the 8080's sets it from bit 3 of the operands,
; which are 0 here. AC is bit 4 of the flags byte PUSH PSW saves.
        xor     a
        and     a
        push    af
        pop     hl
        ld      a,l
        and     10h
        ld      de,C8085
        jp      nz,show
        ld      de,C8080
show:   call    print
        ld      sp,(oldsp)
        ret                     ;back to the CCP
;
print:  ld      c,PSTRING       ;print the \$-terminated string at DE
        jp      BDOS
;
MSG:    DB      "$MESSAGE",CR,LF,"\$"
BUILT:  DB      "Built for "
        IFDEF   __CPU_Z80__     ;z80asm defines one of these, from -m
        DB      "Z80"
        ENDIF
        IFDEF   __CPU_8085__
        DB      "8085"
        ENDIF
        IFDEF   __CPU_8080__
        DB      "8080"
        ENDIF
        DB      ", running on \$"
CZ80:   DB      "Z80",CR,LF,"\$"
C8085:  DB      "8085",CR,LF,"\$"
C8080:  DB      "8080",CR,LF,"\$"
;
oldsp:  DS      2
        DS      64
stack:
EOF
else
cat > "$ASM_PATH" <<EOF
; $CPM_NAME.Z88 -- CADzilla program, z88dk toolchain
;
; Built on the host by z88dk's z80asm, then copied onto the CP/M disk and run
; (cadzilla-build-z88dk skill):
;   tools/z88dk/z88build.sh software/$NAME       -> build/$CPM_NAME.COM
;   A0>R $CPM_NAME.COM                          (hb0 HOSTDIR = build/)
;   A0>$CPM_NAME
;
; The target CPU ($CPU) is machine.toml's cpu0 block: it is both the emulated
; CPU and z80asm's -m flag. z80asm takes Intel and Zilog mnemonics alike, even
; mixed in one file -- but JP and CP always mean the Zilog jump and compare
; (tools/z88dk/README.md).
;
; The program prints the CPU it was built for and the one it is running on;
; the two should always match.
;
        ORG     0100H           ;a CP/M .COM
;
BDOS    EQU     0005H
PSTRING EQU     9
CR      EQU     0DH
LF      EQU     0AH
;
START:  LXI     D,MSG
        CALL    PRINT
        LXI     D,BUILT
        CALL    PRINT
;
; Which CPU is this? 7FH+1 overflows: the Z80 sets P/V for that, the 8080 and
; 8085 set P for parity, and 80H has odd parity, so P is clear.
        MVI     A,7FH
        INR     A
        LXI     D,CZ80
        JPE     SHOW
; The 8085's ANA always sets AC; the 8080's sets it from bit 3 of the operands,
; which are 0 here. AC is bit 4 of the flags byte PUSH PSW saves.
        XRA     A
        ANA     A
        PUSH    PSW
        POP     H
        MOV     A,L
        ANI     10H
        LXI     D,C8085
        JNZ     SHOW
        LXI     D,C8080
SHOW:   CALL    PRINT
        RET                     ;back to the CCP
;
PRINT:  MVI     C,PSTRING       ;print the \$-terminated string at DE
        JMP     BDOS
;
MSG:    DB      "$MESSAGE",CR,LF,"\$"
BUILT:  DB      "Built for "
        IFDEF   __CPU_Z80__     ;z80asm defines one of these, from -m
        DB      "Z80"
        ENDIF
        IFDEF   __CPU_8085__
        DB      "8085"
        ENDIF
        IFDEF   __CPU_8080__
        DB      "8080"
        ENDIF
        DB      ", running on \$"
CZ80:   DB      "Z80",CR,LF,"\$"
C8085:  DB      "8085",CR,LF,"\$"
C8080:  DB      "8080",CR,LF,"\$"
EOF
fi
else
# A minimal, self-contained starter: BDOS function 9 prints a '$'-terminated
# string. No INCLUDE (ASM.COM doesn't support it) and no underscores in any
# symbol name (ASM.COM silently resolves those to 0 instead of erroring).
cat > "$ASM_PATH" <<EOF
        ORG     0100H
;
BDOS    EQU     0005H
PSTRING EQU     9
CR      EQU     0DH
LF      EQU     0AH
;
START:  LXI     D,MSG
        MVI     C,PSTRING
        CALL    BDOS
        RET
;
MSG:    DB      '$MESSAGE',CR,LF,'\$'
;
        END     START
EOF
fi

# CP/M's assemblers require CR/LF line endings -- an LF-only file silently
# assembles to nothing at all, with no error (ASM.COM: just an empty "000H
# USE FACTOR").
if [ "$TOOLCHAIN" != "z88dk" ]; then
  "$REPO_ROOT/tools/altairsim/scripts/crlf.sh" "$ASM_PATH"
fi

echo "Created/filled in $PROJECT_DIR"
if [ "$TOOLCHAIN" = "m80" ]; then
  echo "  src/$CPM_NAME.MAC   (CR/LF line endings, ready for M80.COM; uses czgfx from B:)"
elif [ "$TOOLCHAIN" = "z88dk" ]; then
  echo "  src/$CPM_NAME.Z88   (for z80asm on the host: tools/z88dk/z88build.sh software/$NAME)"
else
  echo "  src/$CPM_NAME.ASM   (CR/LF line endings, ready for ASM.COM)"
fi
echo "  include/.gitkeep"
echo "  build/.gitkeep"
if [ "$TOOLCHAIN" = "z88dk" ]; then
  echo "  machine.toml        (tracked: cad0 mode = $MODE, cpu0 = $CPU)"
else
  echo "  machine.toml        (tracked: cad0 mode = $(grep -E '^mode' "$OVERLAY" | sed 's/.*"\(.*\)".*/\1/'))"
fi
if [ "$TOOLCHAIN" = "m80" ]; then
  echo "  work/               (this project's own altairsim machine + disk; B: = czgfx library, read-only)"
else
  echo "  work/               (this project's own altairsim machine + disk(s))"
fi
echo
echo "CP/M-side name: $CPM_NAME"
