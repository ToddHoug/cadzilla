        .XLIST                  ;(.LIST again at the end of this file)
;
; BASIC.INC -- CZBASIC: shared equates and macros
;
; Every CZBASIC module INCLUDEs this file. It holds no code and no
; EXTRNs: each module declares the globals it uses itself.
;
; Program text format (the same as Microsoft BASIC-80 5.21, so binary
; SAVE files are interchangeable): each line is
;       DW link (address of the next line; 0 ends the program)
;       DW line number
;       tokens ..., 0
; with numeric constants stored in binary after a constant token
; (TCxxx below) and functions after a 0FFH prefix. CADzilla
; extensions use a 0FEH prefix (MBASIC never emits it).
;
; ---- CP/M ----
;
WBOOT   EQU     0000H           ;warm boot
BDOS    EQU     0005H           ;BDOS entry; (0006H) = top of the TPA
DFCB    EQU     005CH           ;default FCB
DBUFF   EQU     0080H           ;default buffer / command tail
;
CR      EQU     0DH
LF      EQU     0AH
BS      EQU     08H
TAB     EQU     09H
CTRLC   EQU     03H
CTRLO   EQU     0FH
CTRLR   EQU     12H
CTRLS   EQU     13H
CTRLU   EQU     15H
CTRLX   EQU     18H
CTRLZ   EQU     1AH
ESC     EQU     1BH
DEL     EQU     7FH
;
; ---- value types: VALTYP = the size of the value in bytes ----
;
VTINT   EQU     2               ;integer, FACLO..FACLO+1
VTSTR   EQU     3               ;string: FACLO = descriptor address
VTSNG   EQU     4               ;single, FACLO..FAC (MBF)
VTDBL   EQU     8               ;double, DFAC..FAC (MBF)
;
; A string descriptor is 3 bytes: DB length, DW address.
;
; ---- constant tokens in program text ----
;
TCOCT   EQU     0BH             ;&O constant, DW value
TCHEX   EQU     0CH             ;&H constant, DW value
TCPTR   EQU     0DH             ;line pointer (run time), DW address
TCLIN   EQU     0EH             ;line number, DW number
TCBYT   EQU     0FH             ;integer 10..255, DB value
TCDIG   EQU     11H             ;integers 0..9 are 11H..1AH
TCINT   EQU     1CH             ;integer, DW value
TCSNG   EQU     1DH             ;single, 4 bytes MBF
TCDBL   EQU     1FH             ;double, 8 bytes MBF
;
; ---- statement tokens ----
;
TKEND   EQU     81H
TKFOR   EQU     82H
TKNEXT  EQU     83H
TKDATA  EQU     84H
TKINPU  EQU     85H
TKDIM   EQU     86H
TKREAD  EQU     87H
TKLET   EQU     88H
TKGOTO  EQU     89H
TKRUN   EQU     8AH
TKIF    EQU     8BH
TKREST  EQU     8CH             ;RESTORE
TKGOSU  EQU     8DH
TKRETU  EQU     8EH
TKREM   EQU     8FH
TKSTOP  EQU     90H
TKPRIN  EQU     91H
TKCLEA  EQU     92H
TKLIST  EQU     93H
TKNEW   EQU     94H
TKON    EQU     95H
TKNULL  EQU     96H
TKWAIT  EQU     97H
TKDEF   EQU     98H
TKPOKE  EQU     99H
TKCONT  EQU     9AH
TKOUT   EQU     9DH
TKLPRI  EQU     9EH
TKLLIS  EQU     9FH
TKWIDT  EQU     0A1H
TKELSE  EQU     0A2H
TKTRON  EQU     0A3H
TKTROF  EQU     0A4H
TKSWAP  EQU     0A5H
TKERAS  EQU     0A6H
TKEDIT  EQU     0A7H
TKERRO  EQU     0A8H            ;ERROR
TKRESU  EQU     0A9H            ;RESUME
TKDELE  EQU     0AAH
TKAUTO  EQU     0ABH
TKRENU  EQU     0ACH
TKDFST  EQU     0ADH            ;DEFSTR
TKDFIN  EQU     0AEH            ;DEFINT
TKDFSN  EQU     0AFH            ;DEFSNG
TKDFDB  EQU     0B0H            ;DEFDBL
TKLINE  EQU     0B1H
TKWHIL  EQU     0B4H            ;stored as TKWHIL,TKPLUS
TKWEND  EQU     0B5H
TKCALL  EQU     0B6H
TKWRIT  EQU     0B7H
TKCOMM  EQU     0B8H            ;COMMON
TKCHAI  EQU     0B9H            ;CHAIN
TKOPTI  EQU     0BAH            ;OPTION
TKRAND  EQU     0BBH            ;RANDOMIZE
TKSYST  EQU     0BDH
TKOPEN  EQU     0BFH
TKFIEL  EQU     0C0H
TKGET   EQU     0C1H
TKPUT   EQU     0C2H
TKCLOS  EQU     0C3H
TKLOAD  EQU     0C4H
TKMERG  EQU     0C5H
TKFILE  EQU     0C6H            ;FILES
TKNAME  EQU     0C7H
TKKILL  EQU     0C8H
TKLSET  EQU     0C9H
TKRSET  EQU     0CAH
TKSAVE  EQU     0CBH
TKRESE  EQU     0CCH            ;RESET
TKLAST  EQU     0CCH            ;last statement token
;
; ---- other keywords ----
;
TKTO    EQU     0CEH
TKTHEN  EQU     0CFH
TKTAB   EQU     0D0H            ;TAB(
TKSTEP  EQU     0D1H
TKUSR   EQU     0D2H
TKFN    EQU     0D3H
TKSPC   EQU     0D4H            ;SPC(
TKNOT   EQU     0D5H
TKERL   EQU     0D6H
TKERR   EQU     0D7H
TKSTRS  EQU     0D8H            ;STRING$
TKUSIN  EQU     0D9H            ;USING
TKINST  EQU     0DAH            ;INSTR
TKQUOT  EQU     0DBH            ;' (stored as ':',TKREM,TKQUOT)
TKVARP  EQU     0DCH            ;VARPTR
TKINKY  EQU     0DDH            ;INKEY$
;
; ---- operators (precedence in BEVAL.MAC) ----
;
TKGT    EQU     0EFH
TKEQ    EQU     0F0H
TKLT    EQU     0F1H
TKPLUS  EQU     0F2H
TKMINU  EQU     0F3H
TKMUL   EQU     0F4H
TKDIV   EQU     0F5H
TKPOW   EQU     0F6H
TKAND   EQU     0F7H
TKOR    EQU     0F8H
TKXOR   EQU     0F9H
TKEQV   EQU     0FAH
TKIMP   EQU     0FBH
TKMOD   EQU     0FCH
TKIDIV  EQU     0FDH            ;\
;
; ---- prefixes ----
;
TKCZ    EQU     0FEH            ;CADzilla extension: 0FEH, 80H+n
TKFUNC  EQU     0FFH            ;function: 0FFH, 80H+n
;
; ---- function numbers (stored after 0FFH as 80H+n) ----
;
FNLEFT  EQU     81H
FNRIGH  EQU     82H
FNMID   EQU     83H
FNSGN   EQU     84H
FNINT   EQU     85H
FNABS   EQU     86H
FNSQR   EQU     87H
FNRND   EQU     88H
FNSIN   EQU     89H
FNLOG   EQU     8AH
FNEXP   EQU     8BH
FNCOS   EQU     8CH
FNTAN   EQU     8DH
FNATN   EQU     8EH
FNFRE   EQU     8FH
FNINP   EQU     90H
FNPOS   EQU     91H
FNLEN   EQU     92H
FNSTR   EQU     93H
FNVAL   EQU     94H
FNASC   EQU     95H
FNCHR   EQU     96H
FNPEEK  EQU     97H
FNSPAC  EQU     98H
FNOCT   EQU     99H
FNHEX   EQU     9AH
FNLPOS  EQU     9BH
FNCINT  EQU     9CH
FNCSNG  EQU     9DH
FNCDBL  EQU     9EH
FNFIX   EQU     9FH
FNCVI   EQU     0ABH
FNCVS   EQU     0ACH
FNCVD   EQU     0ADH
FNEOF   EQU     0AFH
FNLOC   EQU     0B0H
FNLOF   EQU     0B1H
FNMKI   EQU     0B2H
FNMKS   EQU     0B3H
FNMKD   EQU     0B4H
FNLAST  EQU     0B4H
;
; ---- CADzilla extension tokens (after 0FEH) ----
;
; Statements 81H.., functions from CZFUN0 up. The keyword spellings
; are in BTOKEN.MAC, the handlers in BGFX*.MAC.
;
XKINIT  EQU     81H             ;CZINIT
XKCLS   EQU     82H             ;CZCLS
XKCOL   EQU     83H             ;CZCOLOR
XKPAL   EQU     84H             ;CZPAL
XKMODE  EQU     85H             ;CZMODE
XKAREA  EQU     86H             ;CZAREA
XKMOVE  EQU     87H             ;CZMOVE
XKRMOV  EQU     88H             ;CZRMOVE
XKDOT   EQU     89H             ;CZDOT
XKLINE  EQU     8AH             ;CZLINE
XKRLIN  EQU     8BH             ;CZRLINE
XKRECT  EQU     8CH             ;CZRECT
XKFRCT  EQU     8DH             ;CZFRECT
XKCIRC  EQU     8EH             ;CZCIRCLE
XKELLI  EQU     8FH             ;CZELLIPSE
XKARC   EQU     90H             ;CZARC
XKEARC  EQU     91H             ;CZEARC
XKPOLY  EQU     92H             ;CZPOLY
XKPLIN  EQU     93H             ;CZPLINE
XKPANT  EQU     94H             ;CZPAINT
XKFLOD  EQU     95H             ;CZFLOOD
XKCOPY  EQU     96H             ;CZCOPY
XKPAT   EQU     97H             ;CZPAT
XKLSTY  EQU     98H             ;CZLSTYLE
XKPSCN  EQU     99H             ;CZPSCAN
XKPTN   EQU     9AH             ;CZPTN
XKTEXT  EQU     9BH             ;CZTEXT
XKWAIT  EQU     9CH             ;CZWAIT
XKSLST  EQU     9CH             ;last statement
XKFUN0  EQU     0C0H            ;first function
XKPNT   EQU     0C0H            ;CZPOINT(x,y)
XKXMAX  EQU     0C1H            ;CZXMAX
XKYMAX  EQU     0C2H            ;CZYMAX
XKXPOS  EQU     0C3H            ;CZXPOS
XKYPOS  EQU     0C4H            ;CZYPOS
XKFLST  EQU     0C4H            ;last function
;
; ---- error numbers (MBASIC's) ----
;
ENF     EQU     1               ;NEXT without FOR
ESN     EQU     2               ;Syntax error
ERG     EQU     3               ;RETURN without GOSUB
EOD     EQU     4               ;Out of DATA
EFC     EQU     5               ;Illegal function call
EOV     EQU     6               ;Overflow
EOM     EQU     7               ;Out of memory
EUL     EQU     8               ;Undefined line number
EBS     EQU     9               ;Subscript out of range
EDD     EQU     10              ;Duplicate Definition
EDZ     EQU     11              ;Division by zero
EID     EQU     12              ;Illegal direct
ETM     EQU     13              ;Type mismatch
EOS     EQU     14              ;Out of string space
ELS     EQU     15              ;String too long
EST     EQU     16              ;String formula too complex
ECN     EQU     17              ;Can't continue
EUF     EQU     18              ;Undefined user function
ENR     EQU     19              ;No RESUME
ERE     EQU     20              ;RESUME without error
EUE     EQU     21              ;Unprintable error
EMO     EQU     22              ;Missing operand
EBO     EQU     23              ;Line buffer overflow
EFN     EQU     26              ;FOR without NEXT
EWH     EQU     29              ;WHILE without WEND
EWE     EQU     30              ;WEND without WHILE
EFO     EQU     50              ;FIELD overflow
EIE     EQU     51              ;Internal error
EBN     EQU     52              ;Bad file number
EFF     EQU     53              ;File not found
EBM     EQU     54              ;Bad file mode
EAO     EQU     55              ;File already open
EIO     EQU     57              ;Disk I/O error
EFE     EQU     58              ;File already exists
EDF     EQU     61              ;Disk full
EEF     EQU     62              ;Input past end
EBR     EQU     63              ;Bad record number
EBF     EQU     64              ;Bad file name
EDS     EQU     66              ;Direct statement in file
ETF     EQU     67              ;Too many files
;
; ---- control stack frames (on the 8080 stack) ----
;
; Each frame starts (lowest address) with a word: low byte = the
; frame's token, high byte = its size in bytes. NEXT, RETURN and WEND
; walk them upward from the stack pointer to the base (STKBAS).
;
FSGOSU  EQU     6               ;GOSUB: id, DW line, DW text pointer
FSWHIL  EQU     6               ;WHILE: id, DW line, DW text pointer
;
; ---- page zero helpers: RST 1..6 (installed by CZBASIC.MAC) ----
;
; SYNCHK c  -- (HL) must be c: then CHRGET, else Syntax error
; CHRGET    -- HL+1, skip blanks: A = char, Z if ':' or 0 (end of
;              statement), C if a digit 0..9
; COMPAR    -- compare HL with DE: Z if equal, C if HL < DE (A lost)
; OUTCHR    -- output A to the current device (all registers kept)
; GETYPE    -- test VALTYP: M int, Z string, NC double, else single
;              (C, P, NZ); A = VALTYP-3
; FSIGN     -- sign of FAC: A = 0 (Z) zero, 1 positive, 0FFH negative
;
SYNCHK  MACRO   CH
        RST     1
        DB      CH
        ENDM
CHRGET  MACRO
        RST     2
        ENDM
COMPAR  MACRO
        RST     3
        ENDM
OUTCHR  MACRO
        RST     4
        ENDM
GETYPE  MACRO
        RST     5
        ENDM
FSIGN   MACRO
        RST     6
        ENDM
;
; ERROR e -- raise error number e
;
ERROR   MACRO   EN
        MVI     E,EN
        JMP     ERRORE##
        ENDM
;
        .LIST
