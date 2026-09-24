#!/usr/bin/env bash
# Scaffold a new CADzilla software project: software/<name>/{src,include,build}
# plus a minimal starter assembly source file, correctly CR/LF-terminated and
# uppercased for CP/M.
#
# Usage: new_project.sh <project-name> [--toolchain asm|m80] [--cpm-name NAME] [welcome-message]
#
# --toolchain picks the assembler (default asm):
#   asm  DRI ASM.COM + LOAD.COM: one self-contained <NAME>.ASM, no INCLUDE,
#        no linker -- the original CP/M flow (cadzilla-build-asm skill).
#   m80  Microsoft M80 + L80: a relocatable <NAME>.MAC that INCLUDEs the
#        czgfx graphics library header from B: and links against its .REL
#        modules (cadzilla-build-m80 skill). The project's work machine gets
#        the czgfx library disk as drive 1 (B:), read-only.
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

while [ $# -gt 0 ]; do
  case "$1" in
    --toolchain)
      if [ $# -lt 2 ]; then
        echo "error: --toolchain needs a value (asm or m80)" >&2
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
  echo "Usage: $0 <project-name> [--toolchain asm|m80] [--cpm-name NAME] [welcome-message]" >&2
  exit 1
fi

case "$TOOLCHAIN" in
  asm) EXT="ASM" ;;
  m80) EXT="MAC" ;;
  *)
    echo "error: --toolchain must be asm or m80, not '$TOOLCHAIN'" >&2
    exit 1
    ;;
esac

MESSAGE="${MESSAGE:-Welcome to CADzilla: ${NAME}!}"

if [[ "$MESSAGE" == *"'"* ]]; then
  echo "error: welcome message can't contain a single quote -- it goes inside a DB '...' string in the source and would break the assembly" >&2
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

# Each project gets its own altairsim work directory (gitignored) -- its own
# persistent copy of the pristine machine + disk(s), so building this project
# never shares (and never fills up) another project's disk. Skip it if one's
# already there (e.g. re-running against an existing scaffold).
if [ ! -d "$PROJECT_DIR/work" ]; then
  "$REPO_ROOT/tools/altairsim/scripts/sync_pristine.sh" "$PROJECT_DIR/work"
fi

# An M80 project reads the czgfx library from drive B: -- point drive 1 of its
# machine at the library disk, read-only. (Idempotent, so it's also safe on
# an existing work/.)
if [ "$TOOLCHAIN" = "m80" ]; then
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
        GINIT                   ;640x480, default palette, screen cleared
        GCOLOR  WHITE+BRIGHT
        GBOX    0,0,639,479     ;frame around the whole screen
        GFBOX   280,200,360,280,BLUE+BRIGHT
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
"$REPO_ROOT/tools/altairsim/scripts/crlf.sh" "$ASM_PATH"

echo "Created/filled in $PROJECT_DIR"
if [ "$TOOLCHAIN" = "m80" ]; then
  echo "  src/$CPM_NAME.MAC   (CR/LF line endings, ready for M80.COM; uses czgfx from B:)"
else
  echo "  src/$CPM_NAME.ASM   (CR/LF line endings, ready for ASM.COM)"
fi
echo "  include/.gitkeep"
echo "  build/.gitkeep"
if [ "$TOOLCHAIN" = "m80" ]; then
  echo "  work/               (this project's own altairsim machine + disk; B: = czgfx library, read-only)"
else
  echo "  work/               (this project's own altairsim machine + disk(s))"
fi
echo
echo "CP/M-side name: $CPM_NAME"
