;
; RHELLO.ASM -- CADzilla program, DRI RMAC + LINK-80 toolchain
;
; Build (cadzilla-build-rmac skill), from the files R'd onto A: from src/:
;   A0>SUBMIT RHELLO
; which runs RHELLO.SUB, RMAC on each module and then LINK:
;   RMAC PRINT -- PRINT.REL, PRINT.PRN, PRINT.SYM
;   RMAC RHELLO -- RHELLO.REL, RHELLO.PRN, RHELLO.SYM
;   LINK RHELLO,PRINT -- RHELLO.COM, RHELLO.SYM
; LINK RHELLO,PRINT[OP] would write RHELLO.PRL, a page-relocatable file
; (the format of a GSX-80 device driver), instead of the .COM.
;
        EXTRN   PRINT           ;in PRINT.ASM
;
CR      EQU     0DH
LF      EQU     0AH
;
        CSEG                    ;code: LINK places it at 0100H
START:  LXI     D,MSG
        CALL    PRINT
        LXI     D,LINKED
        CALL    PRINT
        RET                     ;back to the CCP
;
        DSEG                    ;data: LINK places it after the code
MSG:    DB      'Welcome to CADzilla: rhello!',CR,LF,'$'
LINKED: DB      'Linked by DRI LINK from two RMAC modules',CR,LF,'$'
;
        END     START
