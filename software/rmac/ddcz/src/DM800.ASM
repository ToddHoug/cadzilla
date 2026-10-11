;
; DM800.ASM -- the mode module for DDCZ800, the 800x600 copy of the CADzilla
; GSX driver. It links second, after DDCZ (whose first byte is the driver's
; entry), and names the czgfx mode descriptor that Open Workstation gives
; CZINIT. The machine's cad0 mode strap must be 800x600 to match.
;
        PUBLIC  DMDESC
        EXTRN   CZM800
;
        CSEG
DMDESC: DW      CZM800
;
        END
