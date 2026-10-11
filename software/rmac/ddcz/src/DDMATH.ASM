;
; DDMATH.ASM -- CADzilla GSX driver: arithmetic.
;
        PUBLIC  MUL,UDIV,MULDIV,NEGHL,NEG32,CPSGN,ISIN,ICOS,SMULQ
;
        CSEG
;
; MUL -- HL:DE = BC * DE, unsigned 16 x 16 -> 32 (HL the high word).
; Keeps BC.
;
MUL:    LXI     H,0
        MVI     A,16
MULLP:  PUSH    PSW
        MOV     A,E             ;the multiplier's low bit
        RAR
        JNC     MULSH           ;(CY = 0 then)
        DAD     B               ;(CY = the carry out)
MULSH:  MOV     A,H             ;CY:HL:DE >>= 1
        RAR
        MOV     H,A
        MOV     A,L
        RAR
        MOV     L,A
        MOV     A,D
        RAR
        MOV     D,A
        MOV     A,E
        RAR
        MOV     E,A
        POP     PSW
        DCR     A
        JNZ     MULLP
        RET
;
; UDIV -- DE:HL = DE:HL / BC, unsigned 32 / 16 (DE the high word); BC
; must be 1-7FFFH. The remainder is left in DVR. Keeps BC.
;
UDIV:   SHLD    DVQ
        XCHG
        SHLD    DVQ+2
        LXI     H,0             ;the remainder
        MVI     A,32
        STA     DVN
UDV1:   PUSH    H               ;the quotient-to-be <<= 1; CY = its top bit
        LXI     H,DVQ
        ORA     A
        MOV     A,M
        RAL
        MOV     M,A
        INX     H
        MOV     A,M
        RAL
        MOV     M,A
        INX     H
        MOV     A,M
        RAL
        MOV     M,A
        INX     H
        MOV     A,M
        RAL
        MOV     M,A
        POP     H               ;remainder = remainder * 2 + that bit
        MOV     A,L
        RAL
        MOV     L,A
        MOV     A,H
        RAL
        MOV     H,A
        MOV     A,L             ;remainder >= BC? subtract, quotient bit 1
        SUB     C
        MOV     E,A
        MOV     A,H
        SBB     B
        JC      UDV2
        MOV     H,A
        MOV     L,E
        LDA     DVQ
        ORI     1
        STA     DVQ
UDV2:   LDA     DVN
        DCR     A
        STA     DVN
        JNZ     UDV1
        SHLD    DVR
        LHLD    DVQ+2
        XCHG
        LHLD    DVQ
        RET
;
; MULDIV -- HL = BC * DE / HL, unsigned (HL 1-7FFFH; the quotient's low
; word). Keeps nothing.
;
MULDIV: PUSH    H
        CALL    MUL
        POP     B
        XCHG                    ;DE:HL = the product
        JMP     UDIV
;
; NEGHL -- HL = -HL; NEG32 -- DE:HL = -DE:HL
;
NEGHL:  MOV     A,L
        CMA
        MOV     L,A
        MOV     A,H
        CMA
        MOV     H,A
        INX     H
        RET
NEG32:  MOV     A,E
        CMA
        MOV     E,A
        MOV     A,D
        CMA
        MOV     D,A
        CALL    NEGHL
        MOV     A,H
        ORA     L
        RNZ
        INX     D               ;the low word wrapped: carry into the high
        RET
;
; CPSGN -- C if HL < DE, signed. Keeps BC, DE, HL.
;
CPSGN:  MOV     A,H
        XRA     D
        JM      CPS1
        MOV     A,L             ;the same sign: compare as unsigned
        SUB     E
        MOV     A,H
        SBB     D
        RET
CPS1:   MOV     A,H             ;different signs: HL < DE if HL is negative
        RAL
        RET
;
; ISIN -- HL = sin(HL degrees) * 32767; ICOS -- the cosine. Any angle.
;
ICOS:   LXI     D,90
        DAD     D
ISIN:   MOV     A,H             ;into 0-359
        ORA     A
        JP      IS1
        LXI     D,360
        DAD     D
        JMP     ISIN
IS1:    LXI     D,360
        CALL    SUBGE
        JNC     IS1
        MVI     B,0             ;B = 1: negative (180-359)
        LXI     D,180
        CALL    SUBGE
        JC      IS2
        INR     B
IS2:    MOV     A,L             ;HL = 0-179: over 90 is 180 - HL
        CPI     91
        JC      IS3
        MOV     A,L
        CMA
        ADI     181             ;180 - L
        MOV     L,A
IS3:    MVI     H,0
        DAD     H
        LXI     D,SINTAB
        DAD     D
        MOV     A,M
        INX     H
        MOV     H,M
        MOV     L,A
        MOV     A,B
        ORA     A
        RZ
        JMP     NEGHL
;
; SUBGE -- if HL >= DE (unsigned): HL -= DE, NC; else C, HL kept
SUBGE:  MOV     A,L
        SUB     E
        MOV     C,A
        MOV     A,H
        SBB     D
        RC
        MOV     H,A
        MOV     L,C
        RET
;
; SMULQ -- HL = DE * HL / 32768, rounded: DE a length (0-7FFFH), HL a
; signed fraction from ISIN/ICOS
;
SMULQ:  MOV     A,H
        STA     SQSGN
        ORA     A
        JP      SQ1
        CALL    NEGHL
SQ1:    MOV     B,H             ;BC = |HL|
        MOV     C,L
        CALL    MUL             ;HL:DE = BC * DE
        PUSH    H               ;+ 4000H, then >> 15
        LXI     H,4000H
        DAD     D
        XCHG
        POP     H
        JNC     SQ2
        INX     H
SQ2:    DAD     H               ;HL = HL:DE >> 15
        MOV     A,D
        RLC
        ANI     1
        ORA     L
        MOV     L,A
        LDA     SQSGN
        ORA     A
        RP
        JMP     NEGHL
;
; sin(0-90 degrees) * 32767
SINTAB: DW      0,572,1144,1715,2286,2856,3425,3993
        DW      4560,5126,5690,6252,6813,7371,7927,8481
        DW      9032,9580,10126,10668,11207,11743,12275,12803
        DW      13328,13848,14364,14876,15383,15886,16383,16876
        DW      17364,17846,18323,18794,19260,19720,20173,20621
        DW      21062,21497,21925,22347,22762,23170,23571,23964
        DW      24351,24730,25101,25465,25821,26169,26509,26841
        DW      27165,27481,27788,28087,28377,28659,28932,29196
        DW      29451,29697,29934,30162,30381,30591,30791,30982
        DW      31163,31335,31498,31650,31794,31927,32051,32165
        DW      32269,32364,32448,32523,32587,32642,32687,32722
        DW      32747,32762,32767
;
        DSEG
DVQ:    DS      4               ;UDIV's quotient (the dividend, shifting)
DVR:    DS      2               ;UDIV's remainder
DVN:    DS      1
SQSGN:  DS      1
;
        END
