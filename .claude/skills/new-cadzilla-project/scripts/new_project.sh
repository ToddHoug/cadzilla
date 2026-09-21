#!/usr/bin/env bash
# Scaffold a new CADzilla software project: software/<name>/{src,include,build}
# plus a minimal starter assembly source file, correctly CR/LF-terminated and
# uppercased for CP/M's ASM.COM.
#
# Usage: new_project.sh <project-name> [--cpm-name NAME] [welcome-message]
#
# --cpm-name is for when <project-name> itself doesn't fit CP/M's 8.3 limit
# (8 characters before the extension) -- e.g. `new_project.sh firstdraw
# --cpm-name FIRSTDRW`. Without it, the CP/M-side name is just <project-name>
# uppercased.
set -euo pipefail

NAME=""
MESSAGE=""
CPM_NAME_OVERRIDE=""

while [ $# -gt 0 ]; do
  case "$1" in
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
  echo "Usage: $0 <project-name> [--cpm-name NAME] [welcome-message]" >&2
  exit 1
fi

MESSAGE="${MESSAGE:-Welcome to CADzilla: ${NAME}!}"

if [[ "$MESSAGE" == *"'"* ]]; then
  echo "error: welcome message can't contain a single quote -- it goes inside a DB '...' string in the .ASM source and would break the assembly" >&2
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
ASM_PATH="$PROJECT_DIR/src/$CPM_NAME.ASM"
if [ -e "$ASM_PATH" ]; then
  echo "error: $ASM_PATH already exists -- not overwriting it" >&2
  exit 1
fi

mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/include" "$PROJECT_DIR/build"
touch "$PROJECT_DIR/include/.gitkeep" "$PROJECT_DIR/build/.gitkeep"

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

# ASM.COM requires CR/LF line endings -- an LF-only file silently assembles to
# nothing at all, with no error, just an empty "000H USE FACTOR".
sed -i 's/$/\r/' "$ASM_PATH"

echo "Created/filled in $PROJECT_DIR"
echo "  src/$CPM_NAME.ASM   (CR/LF line endings, ready for ASM.COM)"
echo "  include/.gitkeep"
echo "  build/.gitkeep"
echo
echo "CP/M-side name: $CPM_NAME"
