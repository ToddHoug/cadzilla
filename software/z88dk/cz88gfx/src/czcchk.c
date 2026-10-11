/*
 * czcchk.c -- the C bindings' build check (software/z88dk/cz88gfx/tools/build.sh)
 *
 * The C counterpart of CZ88CHK.Z88: it calls every entry point in
 * cz88gfx.h and names every constant, and build.sh compiles and links it
 * against the new CZ88GFX.LIB for the 8080, 8085 and Z80. A wrong
 * prototype or a missing PUBLIC fails the library build, not the first C
 * program that uses it. It is only linked, never run.
 */
#include <cz88gfx.h>

static const int tri[] = { 3, 10, 10, 100, 10, 55, 90 };
static const unsigned int pat[] = { 2, 0x0FF0, CZ_TILE(CZ_RED + CZ_BRIGHT) };

int main(void)
{
    int x, y;

    cz_init(CZ_M1K);
    cz_init(CZ_M800);
    cz_init(CZ_M640);
    cz_cls(CZ_ORANGE + CZ_BLUE + CZ_GREEN + CZ_CYAN);
    cz_pal(1, 2, 3, 4);
    cz_paldef();

    cz_color(CZ_RED + CZ_MAGENTA + CZ_YELLOW + CZ_WHITE + CZ_BRIGHT);
    cz_move(cz_xmax, cz_ymax);
    cz_line(1, 2);
    cz_rect(1, 2);
    cz_frect(1, 2);
    cz_dot(1, 2);
    cz_rmove(-1, -2);
    cz_rline(-1, -2);
    cz_rrect(-1, -2);
    cz_rfrect(-1, -2);
    cz_seg(1, 2, 3, 4);
    cz_box(1, 2, 3, 4);
    cz_fbox(1, 2, 3, 4, 5);
    cz_polyline(tri);
    cz_polygon(tri);
    if (cz_wait() & CZ_SR_CER)
        cz_abort();

    cz_circle(1, 2, 3);
    cz_circle_cp(3);
    cz_ellipse(1, 2, 3, 4);
    cz_ellipse_cp(3, 4);
    cz_arc(1, 2, 3, 4, CZ_DIR_CCW);
    cz_rarc(1, 2, 3, 4, CZ_DIR_CW);
    cz_earc(4, 3, 1, 2, 3, 4, CZ_DIR_CCW);
    cz_rearc(4, 3, 1, 2, 3, 4, CZ_DIR_CW);

    cz_paint(1, 2, 3);
    cz_flood(1, 2, 3);
    cz_paint_cp(3);
    cz_flood_cp(3);
    cz_copy(1, 2, 3, 4, 5, 6, CZ_CP_NORM + CZ_CP_MIRY + CZ_CP_MIRX + CZ_CP_R180);
    cz_copy(1, 2, 3, 4, 5, 6, CZ_CP_TRAN + CZ_CP_R270 + CZ_CP_R90 + CZ_CP_ATRN);

    cz_setmode(CZ_OM_REP + CZ_CM_SEL + CZ_AM_NONE);
    cz_opm(CZ_OM_OR + CZ_OM_AND + CZ_OM_EOR + CZ_OM_EQ);
    cz_opm(CZ_OM_NE + CZ_OM_LT + CZ_OM_GT);
    cz_cmode(CZ_CM_CL1 + CZ_CM_CL0 + CZ_CM_PRAM);
    cz_amode(CZ_AM_STOP + CZ_AM_CLIP + CZ_AM_CLPD + CZ_AM_STPI);
    cz_amode(CZ_AM_HOLE + CZ_AM_HOLD);
    cz_bcol(1);
    cz_ccmp(2);
    cz_area(1, 2, 3, 4);
    cz_afull();
    cz_getcp(&x, &y);
    if (cz_rdot(x, y) < 0 || (cz_wait() & CZ_SR_ARD))
        cz_abort();

    cz_ldpat(pat, 0);
    cz_pscan(0, 0, 15, 15, 0, 0);
    cz_pptr(1, 2);
    cz_pdef();
    cz_lstyle(0xF0F0, 1);
    cz_ptn(1, 2, 16, 16, CZ_PTSLNT);
    cz_ptn_cp(16, 16, 0);

    cz_ovpal(1, 2, 3);
    cz_ovl();
    cz_color(CZ_OVSET + CZ_OVCLR);
    cz_frame();
    cz_ovcls();
    cz_ovon();
    cz_ovoff();

    cz_font(CZ_F8);
    cz_font(CZ_F11);
    cz_tpos(1, 2);
    cz_tattr(2, 0, CZ_TXOPAQ);
    cz_text("check");
    cz_tstr("check", 5);
    cz_tchr('A');
    cz_tnl();

    cz_putw(CZ88GFX_VERSION);
    cz_cmd(0xCC);
    cz_wpr(1, 2);
    cz_wreg(2, 0x0300);
    return 0;
}
