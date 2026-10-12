; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
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
MSG:    DB      'Welcome to CADzilla!',CR,LF,'$'
;
        END     START
