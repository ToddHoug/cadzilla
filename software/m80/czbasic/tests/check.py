#!/usr/bin/env python3
"""Compare a CZBASIC test run with MBASIC 5.21's expected output.

The altairsim MCP server returns guest console output inside the `run`
result (a console log file stays empty under MCP), so a run is checked by
pasting that `output` string -- still JSON-escaped, exactly as the result
shows it -- on stdin:

    python3 tests/check.py T01 <<'EOF'
    CZBASIC T01\r\r\n...Bytes free\r\n 0  1 ...\r\n\r\nA0>
    EOF

Everything up to the banner's "Bytes free" line and the trailing
"\\r\\nA0>" prompt is dropped; the rest must equal expected/<T>.OUT, which
holds the program's output as MBASIC printed it (see README.md, Testing).
Prints OK or a line diff; exits 1 on a difference.

    python3 tests/check.py --all <<'EOF'
    ...the output of SUBMIT RUNALL...
    EOF

checks a whole RUNALL.SUB transcript instead: it is split at each
"A0>CZBASIC <name>" command and every part is compared as above.
"""
import difflib
import json
import os
import re
import sys


def body(raw):
    if ' Bytes free\r\n' in raw:
        raw = raw.split(' Bytes free\r\n', 1)[1]
    if raw.endswith('\r\nA0>'):
        raw = raw[:-len('\r\nA0>')]
    return raw


def check(name, raw):
    here = os.path.dirname(os.path.abspath(__file__))
    want = open(os.path.join(here, 'expected', name + '.OUT'), 'rb').read().decode('latin-1')
    got = body(raw)
    if got == want:
        print(name, 'OK')
        return 0
    for line in difflib.unified_diff(want.split('\r\n'), got.split('\r\n'),
                                     'MBASIC', 'CZBASIC', lineterm='', n=1):
        print(repr(line)[1:-1] if line[:1] in ' +-' and not line.startswith(('---', '+++')) else line)
    return 1


def main(argv):
    if len(argv) != 1:
        sys.exit(__doc__)
    text = sys.stdin.read().strip()
    raw = json.loads('"' + text + '"') if '\\r' in text or '\\n' in text else text
    if argv[0] != '--all':
        return check(argv[0].upper(), raw)
    parts = re.split(r'A0>CZBASIC (\w+)\r*\n', raw)
    bad = 0
    for name, out in zip(parts[1::2], parts[2::2]):
        if out.endswith('A0>'):         # the last one: SUBMIT's final prompt
            out = out[:-3]
        bad |= check(name.upper(), out + 'A0>')
    print(len(parts) // 2, 'tests,', 'FAILED' if bad else 'all OK')
    return bad


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
