;
; DM1K.ASM -- the mode module for DDCZ1K, the 1024x768 copy of the CADzilla
; GSX driver. It links second, after DDCZ (whose first byte is the driver's
; entry), and names the czgfx mode descriptor that Open Workstation gives
; CZINIT. The machine's cad0 mode strap must be 1024x768 to match.
;
        PUBLIC  DMDESC
        EXTRN   CZM1K
;
        CSEG
DMDESC: DW      CZM1K
;
        END
