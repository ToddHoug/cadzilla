;
; PRINT.ASM -- a second module of a CADzilla RMAC project: print the
; '$'-terminated string at DE with BDOS function 9.
;
        PUBLIC  PRINT
;
BDOS    EQU     0005H
PSTRING EQU     9
;
        CSEG
PRINT:  MVI     C,PSTRING
        JMP     BDOS            ;BDOS returns to our caller
;
        END
