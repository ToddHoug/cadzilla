; SPDX-License-Identifier: GPL-3.0-or-later
; Copyright (C) 2026 Todd Houg
;
; DM640.ASM -- the mode module for DDCZ640, the 640x480 copy of the CADzilla
; GSX driver. It links second, after DDCZ (whose first byte is the driver's
; entry), and names the czgfx mode descriptor that Open Workstation gives
; CZINIT. The machine's cad0 mode strap must be 640x480 to match.
;
        PUBLIC  DMDESC
        EXTRN   CZM640
;
        CSEG
DMDESC: DW      CZM640
;
        END
