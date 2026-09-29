# Known differences from MBASIC 5.21

Test programs avoid these; each is a place where CZBASIC is deliberately
more accurate than, or simply different from, the reference.

- **Double-precision constants are converted exactly.** MBASIC's number
  reader accumulates rounding error, so `PRINT .99999949#` shows
  `.9999994900000002` there; CZBASIC shows `.99999949`. (Removed from T11.)
- **Open files survive a CHAIN to an ASCII program.** MBASIC documents
  that CHAIN leaves files open, and it does when the chained program was
  SAVEd in binary. But when the program is an ASCII file, MBASIC's
  loading upsets file #1: a following `PRINT #1` gives *Bad file mode*
  and what was written before the CHAIN is lost. CZBASIC loads programs
  through its own FCB, so files stay open either way. (CF1 chains to a
  binary program, CF2B, so both agree; CH1 does no file I/O.)
- **An ASCII program whose last line has no CR/LF.** STARTRK.BAS ends
  `9999 END` straight into the ^Z padding. MBASIC's LOAD leaves that
  line pending in its input buffer, and the next line typed at the
  console is appended to it (`LOAD "STARTRK"` then `SAVE "X"` gives a
  line `9999 ENDSAVE "X"` and saves nothing). CZBASIC ends the line at
  the end of the file. Apart from that line, STARTRK round-trips
  identically both ways: MBASIC binary -> CZBASIC LOAD -> SAVE ,A, and
  CZBASIC binary -> MBASIC LOAD -> SAVE ,A, both equal MBASIC's own
  SAVE ,A listing.
- **RND's sequence.** RND returns uniform numbers in [0,1) with MBASIC's
  rules (RND(0) repeats the last, a negative argument reseeds, RANDOMIZE
  asks for a seed), but not MBASIC's actual sequence: MBASIC keeps more
  than 24 bits of state (its first RND(1) is 4112455.5/2^24), and its
  generator has not been matched. A program that never RANDOMIZEs gets
  a different, but again fixed, series (STARTRK deals a different
  galaxy). No test prints RND values.
