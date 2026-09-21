#!/usr/bin/env bash
# Scaffold a new CADzilla software project: software/<name>/{src,include,build}
# plus a minimal starter assembly source file, correctly CR/LF-terminated and
# uppercased for CP/M's ASM.COM.
#
# Usage: new_project.sh <project-name> [welcome-message]
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <project-name> [welcome-message]" >&2
  exit 1
fi

NAME="$1"
MESSAGE="${2:-Welcome to CADzilla: ${1}!}"

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

if [ -e "$PROJECT_DIR" ]; then
  echo "error: $PROJECT_DIR already exists" >&2
  exit 1
fi

# The CP/M-side name is the same name, uppercased (CLAUDE.md: files that pass
# through the CP/M toolchain are uppercase on both the host and the CP/M side).
# CP/M's 8.3 format allows at most 8 characters before the extension.
CPM_NAME="$(printf '%s' "$NAME" | tr '[:lower:]' '[:upper:]')"
if [ "${#CPM_NAME}" -gt 8 ]; then
  echo "error: '$NAME' is ${#CPM_NAME} characters -- CP/M 8.3 filenames allow at most 8 before the extension. Pick a shorter name." >&2
  exit 1
fi
case "$CPM_NAME" in
  CON|PRN|AUX|LST|RDR|PUN)
    echo "error: '$CPM_NAME' is a reserved CP/M device name -- pick another" >&2
    exit 1
    ;;
esac

mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/include" "$PROJECT_DIR/build"
touch "$PROJECT_DIR/include/.gitkeep" "$PROJECT_DIR/build/.gitkeep"

ASM_PATH="$PROJECT_DIR/src/$CPM_NAME.ASM"

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

echo "Created $PROJECT_DIR"
echo "  src/$CPM_NAME.ASM   (CR/LF line endings, ready for ASM.COM)"
echo "  include/.gitkeep"
echo "  build/.gitkeep"
echo
echo "CP/M-side name: $CPM_NAME"
