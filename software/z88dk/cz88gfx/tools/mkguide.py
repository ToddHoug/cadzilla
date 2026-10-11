#!/usr/bin/env python3
"""Generate docs/cz88gfx-guide.pdf: the cz88gfx graphics library user guide.

One guide for both of cz88gfx's languages: assembly (z88dk's z80asm,
CZ88GFX.INC) and C (z88dk's zcc, cz88gfx.h). The C functions are stubs over
the same routines, so the chapters describe each feature once and show both
forms side by side; the appendices give each language its own reference.

What is computed rather than written out, so that it matches the library:
  - the palette chart, from the default palette tables (as CZPALD loads it);
  - the font charts, from this directory's mkfont.py;
  - Appendix C, the C function reference: every prototype in src/cz88gfx.h,
    with its calling convention, and the stub module that defines it (from
    the PUBLICs and DEFCs in src/CZC*.Z88);
  - the version, from CZ88VER in src/CZ88GFX.INC.
The screenshots, docs/images/cz88gfx/cgfxdemo-NN.png, are cgfxdemo's own
screens (z88demo's are identical). To refresh them after a library change:
run cgfxdemo on its altairsim machine, take a `snapshot` at each screen, and
render each with
    tools/altairsim/scripts/cadzilla_png.py <snapshot> docs/images/cz88gfx/cgfxdemo-NN.png

Usage (from the repository root):
    python3 software/z88dk/cz88gfx/tools/mkguide.py
Needs ReportLab (the other manuals in docs/ are made the same way).
"""
import datetime
import glob
import importlib.util
import math
import os
import re
import sys

from reportlab.graphics.shapes import (Circle, Drawing, Line, Polygon, Rect,
                                       String)
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (CondPageBreak, Image, KeepTogether, PageBreak,
                                Paragraph, Preformatted, SimpleDocTemplate,
                                Spacer, Table, TableStyle)
from reportlab.platypus.tableofcontents import TableOfContents

HERE = os.path.dirname(os.path.abspath(__file__))
LIBDIR = os.path.normpath(os.path.join(HERE, '..'))
REPO = os.path.normpath(os.path.join(LIBDIR, '..', '..', '..'))
OUT = os.path.join(REPO, 'docs', 'cz88gfx-guide.pdf')
COVER = os.path.join(REPO, 'docs', 'images', 'cadzilla.png')
SHOTS = os.path.join(REPO, 'docs', 'images', 'cz88gfx')
INC = os.path.join(LIBDIR, 'src', 'CZ88GFX.INC')
HDR = os.path.join(LIBDIR, 'src', 'cz88gfx.h')
STUBS = os.path.join(LIBDIR, 'src', 'CZC*.Z88')
TITLE = 'cz88gfx Graphics Library User Guide'
REVISION = '1.0'
DATE = datetime.date.today().isoformat()


def library_version():
    """The version in CZ88GFX.INC (CZ88VER EQU 0MMNNH) as 'MM.NN'."""
    with open(INC, encoding='latin-1') as f:
        m = re.search(r'^CZ88VER\s+EQU\s+0?([0-9A-Fa-f]+)H', f.read(), re.M)
    v = int(m.group(1), 16)
    return '%d.%d' % (v >> 8, v & 255)


VERSION = library_version()

# ---------------------------------------------------------------- styles

ss = getSampleStyleSheet()
BODY = ParagraphStyle('body', parent=ss['BodyText'], fontName='Helvetica',
                      fontSize=10, leading=13.5, spaceAfter=6)
SMALL = ParagraphStyle('small', parent=BODY, fontSize=8.5, leading=11)
CAPTION = ParagraphStyle('caption', parent=SMALL, alignment=TA_CENTER,
                         textColor=colors.HexColor('#444444'), spaceAfter=10)
CELL = ParagraphStyle('cell', parent=BODY, fontSize=9, leading=11.5,
                      spaceAfter=0)
CELLB = ParagraphStyle('cellb', parent=CELL, fontName='Helvetica-Bold',
                       textColor=colors.white)
H1 = ParagraphStyle('h1', parent=ss['Heading1'], fontName='Helvetica-Bold',
                    fontSize=18, leading=22, spaceBefore=6, spaceAfter=10,
                    keepWithNext=1)
H2 = ParagraphStyle('h2', parent=ss['Heading2'], fontName='Helvetica-Bold',
                    fontSize=13, leading=16, spaceBefore=12, spaceAfter=6,
                    keepWithNext=1)
CODE = ParagraphStyle('code', fontName='Courier', fontSize=8.8, leading=11,
                      leftIndent=8, spaceAfter=6, spaceBefore=2)
DCODE = ParagraphStyle('dcode', parent=CODE, fontSize=7.9, leading=9.8,
                       leftIndent=0, spaceAfter=0, spaceBefore=0)
NOTE = ParagraphStyle('note', parent=BODY, fontSize=9.5, leading=12.5,
                      leftIndent=10, textColor=colors.HexColor('#333333'))
BULLET = ParagraphStyle('bullet', parent=BODY, leftIndent=14,
                        bulletIndent=4, spaceAfter=3)
TOC1 = ParagraphStyle('toc1', parent=BODY, fontName='Helvetica-Bold',
                      fontSize=10, leading=12, leftIndent=0, spaceBefore=3,
                      spaceAfter=0)
TOC2 = ParagraphStyle('toc2', parent=BODY, fontSize=9, leading=10.5,
                      leftIndent=16, spaceBefore=0, spaceAfter=0)

DARK = colors.HexColor('#2b2b2b')
GRID = colors.HexColor('#b8b8b8')
SHADE = colors.HexColor('#f0f0f0')
WIDTH = 6.9 * inch


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def C(s):
    """Inline code."""
    return '<font face="Courier">%s</font>' % esc(s)


def P(text, style=BODY):
    return Paragraph(text, style)


def bullets(items):
    return [Paragraph(t, BULLET, bulletText='•') for t in items]


def code(text):
    """A code block (plain text, not markup)."""
    return Preformatted(text.strip('\n'), CODE)


def table(rows, widths, header=True, style=CELL):
    data = []
    for i, row in enumerate(rows):
        st = CELLB if (header and i == 0) else style
        data.append([c if not isinstance(c, str) else P(c, st) for c in row])
    t = Table(data, colWidths=widths, repeatRows=1 if header else 0)
    cmds = [('GRID', (0, 0), (-1, -1), 0.5, GRID),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 5),
            ('RIGHTPADDING', (0, 0), (-1, -1), 5),
            ('TOPPADDING', (0, 0), (-1, -1), 3),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 3)]
    if header:
        cmds.append(('BACKGROUND', (0, 0), (-1, 0), DARK))
        for r in range(2, len(rows), 2):
            cmds.append(('BACKGROUND', (0, r), (-1, r), SHADE))
    t.setStyle(TableStyle(cmds))
    return t


def ctable(rows, widths, header=True, cols=1):
    """A table whose first `cols` columns are code."""
    out = []
    for i, r in enumerate(rows):
        if header and i == 0:
            out.append(r)
        else:
            out.append([C(x) if k < cols and x else x
                        for k, x in enumerate(r)])
    return table(out, widths, header)


def dual(asm, c, asm_title='Assembly (z80asm)', c_title='C (zcc)'):
    """The same thing in both languages, side by side."""
    half = WIDTH / 2
    t = Table([[P(asm_title, CELLB), P(c_title, CELLB)],
               [Preformatted(asm.strip('\n'), DCODE),
                Preformatted(c.strip('\n'), DCODE)]],
              colWidths=[half, half])
    t.setStyle(TableStyle([
        ('GRID', (0, 0), (-1, -1), 0.5, GRID),
        ('BACKGROUND', (0, 0), (-1, 0), DARK),
        ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor('#fafafa')),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5)]))
    return KeepTogether([t, Spacer(1, 8)])


def shot(n, caption, width=5.0 * inch):
    path = os.path.join(SHOTS, 'cgfxdemo-%02d.png' % n)
    img = Image(path, width=width, height=width * 768 / 1024)
    img.hAlign = 'CENTER'
    return KeepTogether([img, Spacer(1, 4), P(caption, CAPTION)])


def figure(drawing, caption):
    drawing.hAlign = 'CENTER'
    return KeepTogether([drawing, Spacer(1, 2), P(caption, CAPTION)])


class Doc(SimpleDocTemplate):
    """Headings go into the table of contents and the PDF outline."""

    def afterFlowable(self, f):
        if isinstance(f, Paragraph) and f.style.name in ('h1', 'h2'):
            text = f.getPlainText()
            level = 0 if f.style.name == 'h1' else 1
            key = 'k%d' % id(f)
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(text, key, level=level, closed=True)
            self.notify('TOCEntry', (level, text, self.page, key))


def on_page(canv, doc):
    w, h = letter
    canv.saveState()
    canv.setStrokeColor(GRID)
    canv.setLineWidth(0.5)
    canv.setFont('Helvetica', 8)
    canv.setFillColor(colors.HexColor('#555555'))
    canv.drawString(0.75 * inch, h - 0.55 * inch, TITLE)
    canv.drawRightString(w - 0.75 * inch, h - 0.55 * inch,
                         'cz88gfx %s' % VERSION)
    canv.line(0.75 * inch, h - 0.6 * inch, w - 0.75 * inch, h - 0.6 * inch)
    canv.line(0.75 * inch, 0.6 * inch, w - 0.75 * inch, 0.6 * inch)
    canv.drawString(0.75 * inch, 0.45 * inch, 'CADzilla')
    canv.drawRightString(w - 0.75 * inch, 0.45 * inch, 'Page %d' % doc.page)
    canv.restoreState()


def on_cover(canv, doc):
    pass


# ---------------------------------------------------------------- the C API

def c_api():
    """Every function and data declaration in cz88gfx.h, with its calling
    convention and the stub module that defines it.

    Returns (functions, data): functions is a list of (name, prototype,
    convention, module, alias); data a list of (name, declaration,
    module)."""
    with open(HDR, encoding='latin-1') as f:
        src = f.read()
    src = re.sub(r'/\*.*?\*/', ' ', src, flags=re.S)
    defs = {}                               # C name -> (module, is a DEFC)
    for path in sorted(glob.glob(STUBS)):
        mod = os.path.splitext(os.path.basename(path))[0]
        with open(path, encoding='latin-1') as f:
            text = f.read()
        for m in re.finditer(r'^\s*PUBLIC\s+(.+)$', text, re.M):
            for name in m.group(1).split(';')[0].split(','):
                name = name.strip()
                if name.startswith('_'):
                    alias = re.search(r'^\s*DEFC\s+%s\s*=' % re.escape(name),
                                      text, re.M) is not None
                    defs[name[1:]] = (mod, alias)
    funcs, data = [], []
    for m in re.finditer(r'\bextern\s+([^;]+);', src):
        decl = ' '.join(m.group(1).split())
        if '(' in decl:
            name = re.search(r'(\w+)\s*\(', decl).group(1)
            conv = ('fastcall' if '__z88dk_fastcall' in decl else
                    'callee' if '__z88dk_callee' in decl else 'no arguments')
            proto = re.sub(r'\s*__\w+', '', decl).strip()
            mod, alias = defs.get(name, ('?', False))
            funcs.append((name, proto, conv, mod, alias))
        else:
            mod = '?'
            for part in decl.split(','):
                n = re.search(r'(\w+)\s*(\[\])?\s*$', part).group(1)
                mod = defs.get(n, (mod,))[0]
            data.append((decl, mod))
    missing = [f[0] for f in funcs if f[3] == '?']
    if missing:
        sys.exit('mkguide: no stub module defines %s' % ', '.join(missing))
    return funcs, data


# The assembly equivalent of each C function, for Appendix C.
MACRO_OF = {
    'cz_init': 'GINIT', 'cz_cls': 'GCLS', 'cz_pal': 'GPAL',
    'cz_paldef': 'CALL CZPALD', 'cz_color': 'GCOLOR', 'cz_move': 'GMOVE',
    'cz_line': 'GLINE', 'cz_rect': 'GRECT', 'cz_frect': 'GFRECT',
    'cz_dot': 'GDOT', 'cz_rmove': 'GRMOVE', 'cz_rline': 'GRLINE',
    'cz_rrect': 'GRRECT', 'cz_rfrect': 'GRFRCT', 'cz_seg': 'GSEG',
    'cz_box': 'GBOX', 'cz_fbox': 'GFBOX', 'cz_polyline': 'GPLT',
    'cz_polygon': 'GPLG', 'cz_wait': 'GWAIT', 'cz_abort': 'GABORT',
    'cz_circle': 'GCIRC', 'cz_circle_cp': 'CALL CZCRCL',
    'cz_ellipse': 'GELLIP', 'cz_ellipse_cp': 'CALL CZELPS',
    'cz_arc': 'GARC', 'cz_rarc': 'GRARC', 'cz_earc_sq': 'GEARC',
    'cz_rearc_sq': 'GREARC', 'cz_paint': 'GPAINT', 'cz_flood': 'GFLOOD',
    'cz_paint_cp': 'CALL CZPANT', 'cz_flood_cp': 'CALL CZFLOD',
    'cz_copy': 'GCOPY', 'cz_setmode': 'GMODE', 'cz_opm': 'GOPM',
    'cz_cmode': 'GCMODE', 'cz_amode': 'GAMODE', 'cz_bcol': 'GBCOL',
    'cz_ccmp': 'GCCMP', 'cz_area': 'GAREA', 'cz_afull': 'GAFULL',
    'cz_getcp': 'GGETCP', 'cz_rdot': 'GRDOT', 'cz_ldpat': 'GLDPAT',
    'cz_pscan': 'GPSCAN', 'cz_pptr': 'GPPTR', 'cz_pdef': 'GPDEF',
    'cz_lstyle': 'GLSTYL', 'cz_ptn': 'GPTN', 'cz_ptn_cp': 'CALL CZPTN',
    'cz_ovon': 'GOVON', 'cz_ovoff': 'GOVOFF', 'cz_ovl': 'GOVL',
    'cz_frame': 'GFRAME', 'cz_ovcls': 'GOVCLS', 'cz_ovpal': 'GOVPAL',
    'cz_font': 'GFONT', 'cz_tpos': 'GTPOS', 'cz_tattr': 'GTATTR',
    'cz_text': 'GTEXT', 'cz_tstr': 'GTSTR', 'cz_tchr': 'GTCHR',
    'cz_tnl': 'GTNL', 'cz_putw': 'CALL CZPUTW', 'cz_cmd': 'CALL CZCMD',
    'cz_wpr': 'CALL CZWPR', 'cz_wreg': 'CALL CZWREG'}


# ---------------------------------------------------------------- figures

def fig_coords():
    d = Drawing(440, 190)
    x0, y0, sw, sh = 70, 25, 300, 150
    d.add(Rect(x0, y0, sw, sh, fillColor=colors.HexColor('#1c1c28'),
               strokeColor=DARK, strokeWidth=1))
    gold = colors.HexColor('#f0c040')
    d.add(Line(x0, y0, x0 + 90, y0, strokeColor=gold, strokeWidth=2))
    d.add(Polygon([x0 + 90, y0 - 4, x0 + 98, y0, x0 + 90, y0 + 4],
                  fillColor=gold, strokeWidth=0))
    d.add(Line(x0, y0, x0, y0 + 70, strokeColor=gold, strokeWidth=2))
    d.add(Polygon([x0 - 4, y0 + 70, x0, y0 + 78, x0 + 4, y0 + 70],
                  fillColor=gold, strokeWidth=0))
    d.add(String(x0 + 100, y0 + 4, '+X', fontName='Helvetica-Bold',
                 fontSize=9, fillColor=colors.white))
    d.add(String(x0 + 6, y0 + 74, '+Y', fontName='Helvetica-Bold',
                 fontSize=9, fillColor=colors.white))
    d.add(Circle(x0, y0, 3, fillColor=colors.white, strokeWidth=0))
    d.add(Circle(x0 + sw, y0 + sh, 3, fillColor=colors.white, strokeWidth=0))
    d.add(String(x0 - 4, y0 - 14, '0,0', fontName='Helvetica', fontSize=9,
                 textAnchor='middle'))
    d.add(String(x0 + sw + 4, y0 + sh + 6, 'CZXMAX,CZYMAX  (C: cz_xmax,cz_ymax)',
                 fontName='Helvetica', fontSize=9, textAnchor='middle'))
    d.add(String(x0 + sw / 2, y0 + sh / 2 + 4, 'the screen',
                 fontName='Helvetica', fontSize=10, textAnchor='middle',
                 fillColor=colors.HexColor('#c8c8d8')))
    d.add(String(x0 + sw / 2, y0 + sh / 2 - 10,
                 '(CZXMAX+1) x (CZYMAX+1) pixels',
                 fontName='Helvetica', fontSize=8.5, textAnchor='middle',
                 fillColor=colors.HexColor('#a8a8b8')))
    return d


HUES = [('ORANGE', 0, (1, 2, 0)), ('BLUE', 32, (0, 0, 1)),
        ('GREEN', 64, (0, 1, 0)), ('CYAN', 96, (0, 1, 1)),
        ('RED', 128, (1, 0, 0)), ('MAGENTA', 160, (1, 0, 1)),
        ('YELLOW', 192, (1, 1, 0)), ('WHITE', 224, (1, 1, 1))]
LEVTAB = [0, 8, 16, 25, 33, 41, 49, 58, 66, 74, 82, 90, 99, 107, 115, 123,
          132, 140, 148, 156, 165, 173, 181, 189, 197, 206, 214, 222, 230,
          239, 247, 255]


def palette_rgb(index):
    """The default palette entry, as CZPALD (CZPAL.Z88) loads it."""
    hue, level = divmod(index, 32)
    lv = LEVTAB[level]
    return tuple(0 if c == 0 else (lv if c == 1 else lv >> 1)
                 for c in HUES[hue][2])


def fig_palette():
    cw, ch, lx = 11.5, 14, 62
    d = Drawing(lx + 32 * cw + 6, 8 * ch + 26)
    for h, (name, base, _) in enumerate(HUES):
        y = (7 - h) * ch + 14
        d.add(String(0, y + 3.5, '%s %d' % (name, base), fontName='Helvetica',
                     fontSize=7.5))
        for lv in range(32):
            r, g, b = palette_rgb(base + lv)
            d.add(Rect(lx + lv * cw, y, cw - 1, ch - 2,
                       fillColor=colors.Color(r / 255, g / 255, b / 255),
                       strokeColor=None))
    for lv in (0, 8, 16, 24, 31):
        d.add(String(lx + lv * cw + cw / 2 - 0.5, 3, '+%d' % lv,
                     fontName='Helvetica', fontSize=7, textAnchor='middle'))
    return d


def fig_directions():
    d = Drawing(200, 150)
    cx, cy, r = 100, 75, 52
    d.add(Circle(cx, cy, 3, fillColor=DARK, strokeWidth=0))
    for k in range(8):
        a = math.radians(45 * k)
        ex, ey = cx + r * math.cos(a), cy + r * math.sin(a)
        d.add(Line(cx, cy, ex, ey, strokeColor=DARK, strokeWidth=1.2))
        hx, hy = math.cos(a), math.sin(a)
        px, py = -hy, hx
        d.add(Polygon([ex, ey, ex - 7 * hx + 3.5 * px, ey - 7 * hy + 3.5 * py,
                       ex - 7 * hx - 3.5 * px, ey - 7 * hy - 3.5 * py],
                      fillColor=DARK, strokeWidth=0))
        d.add(String(cx + (r + 12) * math.cos(a),
                     cy + (r + 12) * math.sin(a) - 3, str(k),
                     fontName='Helvetica-Bold', fontSize=9,
                     textAnchor='middle'))
    return d


def fig_mode_byte():
    """The drawing mode byte: AREA (7-5), COL (4-3), OPM (2-0)."""
    d = Drawing(330, 60)
    cw = 36
    x0 = 20
    fields = [(0, 3, 'AREA', '#4a6fa5'), (3, 2, 'COL', '#5f9e5f'),
              (5, 3, 'OPM', '#b0703a')]
    for start, n, name, col in fields:
        d.add(Rect(x0 + start * cw, 18, n * cw, 24,
                   fillColor=colors.HexColor(col), strokeColor=DARK,
                   strokeWidth=0.8))
        d.add(String(x0 + (start + n / 2) * cw, 26, name,
                     fontName='Helvetica-Bold', fontSize=10,
                     textAnchor='middle', fillColor=colors.white))
    for b in range(8):
        d.add(String(x0 + (b + 0.5) * cw, 46, str(7 - b),
                     fontName='Helvetica', fontSize=8, textAnchor='middle'))
    d.add(String(x0, 4, 'the low byte of every drawing command (CZDM)',
                 fontName='Helvetica', fontSize=8))
    return d


def fig_transforms():
    """An F, and where the copy's eight transforms put it."""
    F = ['#####', '#....', '####.', '#....', '#....']   # top first
    pts = [(x, 4 - y) for y, row in enumerate(F) for x, c in enumerate(row)
           if c == '#']                                   # bottom-left origin
    maps = [('NORM', lambda i, j: (i, j)), ('MIRX', lambda i, j: (-i, j)),
            ('MIRY', lambda i, j: (i, -j)), ('R180', lambda i, j: (-i, -j)),
            ('TRAN', lambda i, j: (j, i)), ('R270', lambda i, j: (j, -i)),
            ('R90', lambda i, j: (-j, i)), ('ATRN', lambda i, j: (-j, -i))]
    px, cellw, cellh = 6, 84, 98
    d = Drawing(4 * cellw, 2 * cellh)
    for k, (name, f) in enumerate(maps):
        cx0 = (k % 4) * cellw
        cy0 = (1 - k // 4) * cellh
        d.add(Rect(cx0 + 4, cy0 + 24, cellw - 8, cellh - 28,
                   fillColor=colors.HexColor('#f6f6f6'),
                   strokeColor=colors.HexColor('#d0d0d0'), strokeWidth=0.4))
        tp = [f(i, j) for (i, j) in pts]
        xs, ys = [p_[0] for p_ in tp], [p_[1] for p_ in tp]
        ox = cx0 + cellw / 2 - (min(xs) + max(xs) + 1) * px / 2
        oy = cy0 + 24 + (cellh - 28) / 2 - (min(ys) + max(ys) + 1) * px / 2
        for (x, y) in tp:
            d.add(Rect(ox + x * px, oy + y * px, px - 0.6, px - 0.6,
                       fillColor=DARK, strokeColor=None))
        d.add(Circle(ox + px / 2, oy + px / 2, 2.2,
                     fillColor=colors.HexColor('#d04040'), strokeWidth=0))
        d.add(String(cx0 + cellw / 2, cy0 + 13, 'CP' + name,
                     fontName='Courier-Bold', fontSize=8.5,
                     textAnchor='middle'))
        d.add(String(cx0 + cellw / 2, cy0 + 3, 'CZ_CP_' + name,
                     fontName='Courier', fontSize=7.5, textAnchor='middle'))
    return d


def load_fonts():
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location(
        'mkfont', os.path.join(HERE, 'mkfont.py'))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def fig_font(mk, which):
    name, table_, cw, ch, gw, gr = [f for f in mk.FONTS if f[0] == which][0][:6]
    px, cols = 2.2, 16
    bw, bh = cw * px + 10, ch * px + 14
    rows = (95 + cols - 1) // cols
    d = Drawing(cols * bw, rows * bh)
    for i, c in enumerate(range(0x20, 0x7F)):
        col, row = i % cols, i // cols
        ox = col * bw + 5
        oy = (rows - 1 - row) * bh + 11
        d.add(Rect(ox - 1, oy - 1, cw * px + 2, ch * px + 2,
                   fillColor=colors.HexColor('#f4f4f4'),
                   strokeColor=colors.HexColor('#d0d0d0'), strokeWidth=0.4))
        for r, bits in enumerate(mk.bottom_up(table_[chr(c)])):
            for x in range(gw):
                if (bits >> x) & 1:
                    d.add(Rect(ox + x * px, oy + r * px, px, px,
                               fillColor=DARK, strokeColor=None))
        d.add(String(ox + cw * px / 2, oy - 8, '%02X' % c,
                     fontName='Helvetica', fontSize=5.5, textAnchor='middle',
                     fillColor=colors.HexColor('#666666')))
    return d


# ---------------------------------------------------------------- content

def build():
    mk = load_fonts()
    funcs, data = c_api()
    story = []
    ctr = dict(alignment=TA_CENTER)

    # ---- cover
    story.append(Spacer(1, 0.9 * inch))
    if os.path.exists(COVER):
        img = Image(COVER, width=2.6 * inch, height=2.6 * inch)
        img.hAlign = 'CENTER'
        story.append(img)
    story.append(Spacer(1, 0.35 * inch))
    story.append(P('cz88gfx', ParagraphStyle('ct', parent=H1, fontSize=30,
                                              leading=36, **ctr)))
    story.append(P('Graphics Library User Guide',
                   ParagraphStyle('cs', parent=H2, fontSize=15,
                                  textColor=colors.HexColor('#444444'),
                                  **ctr)))
    story.append(Spacer(1, 0.25 * inch))
    story.append(P(
        'The graphics library for the CADzilla S-100 graphics board '
        '(Hitachi HD63484 ACRTC and Brooktree Bt453 RAMDAC), for 8080, 8085 '
        'and Z80 programs written in assembly or C and built on the host with '
        'z88dk',
        ParagraphStyle('cd', parent=BODY, fontSize=11, leading=15, **ctr)))
    story.append(Spacer(1, 0.3 * inch))
    story.append(P('Library version %s &middot; document revision %s '
                   '&middot; %s' % (VERSION, REVISION, DATE),
                   ParagraphStyle('cr', parent=SMALL,
                                  textColor=colors.HexColor('#888888'),
                                  **ctr)))
    story.append(PageBreak())

    # ---- contents
    story.append(P('Contents', ParagraphStyle('ch', parent=H1)))
    toc = TableOfContents()
    toc.levelStyles = [TOC1, TOC2]
    story.append(toc)
    story.append(PageBreak())

    # ================================================== 1. introduction
    story.append(P('1. Introduction', H1))
    story.append(P(
        'cz88gfx is the graphics library for CADzilla programs built on the '
        'host with <b>z88dk</b>, in either of two languages: assembly, '
        'assembled by z88dk\'s z80asm, and <b>C</b>, compiled by z88dk\'s zcc. '
        'It sets up the board and gives a program the whole of the ACRTC\'s '
        'drawing processor: lines, rectangles, polygons, circles, ellipses '
        'and arcs, area fills and copies, the pattern RAM, the operation, '
        'color and area modes, a one-bit overlay plane and text in two '
        'fonts. The same library serves the 8080, 8085 and Z80.'))
    story.append(P(
        'This guide is for programmers using the library from either '
        'language. It explains the board\'s model as far as a program needs '
        'it, then each group of calls, showing the assembly and the C form '
        'side by side, with the screens of the demo programs as worked '
        'examples. The appendices give each language its own reference and '
        'explain how the library is built and extended.'))

    story.append(P('1.1 What cz88gfx is', H2))
    story.append(P('cz88gfx comes in three parts:'))
    story.extend(bullets([
        C('CZ88GFX.INC') + ', the header an assembly program INCLUDEs: the '
        'board\'s equates, an EXTERN for every library symbol, and the '
        + C('G...') + ' macros.',
        C('cz88gfx.h') + ', the header a C program #includes: a prototype for '
        'every C function, and the ' + C('CZ_') + ' constants.',
        C('CZ88GFX.LIB') + ', a z80asm library: fourteen graphics modules '
        'and, from release 1.1, fifteen small modules of C bindings. The '
        'linker takes only the modules a program uses, so a program that '
        'draws only boxes gets no curve, text or font code, and an assembly '
        'program never carries the C bindings (Appendix B lists the modules '
        'and their sizes).']))
    story.append(P(
        'The library is 8080 code, in Intel mnemonics. z80asm links it '
        'unchanged into an 8080, 8085 or Z80 program, so one library serves '
        'every CPU a project can pick. It is linked on the host: nothing is '
        'mounted or copied in CP/M. Each project pins a numbered release, so '
        'a new cz88gfx version reaches a program only when the program moves '
        'to it (chapter 13).'))
    story.append(P(
        'cz88gfx is a port of <b>czgfx</b>, the library for programs built '
        'with Microsoft M80/L80 inside CP/M (' + C('docs/czgfx-guide.pdf') +
        '). The routines, names, register conventions and macros are the '
        'same, and its graphics modules assemble to the same bytes as czgfx '
        '1.0\'s. The two libraries share no files: a change to one doesn\'t '
        'reach the other.'))

    story.append(P('1.2 One library, two languages', H2))
    story.append(P(
        'The C functions are not a second implementation. Each is a few '
        'instructions of assembly that take the C arguments off the stack and '
        'jump into the routine an assembly program calls. A C program '
        'therefore draws exactly what the assembly one does, at the same '
        'speed: <b>cgfxdemo</b> (C) draws <b>z88demo</b>\'s (assembly) ten '
        'screens identically, pixel for pixel, and both match czgfx\'s '
        'gfxdemo.'))
    story.append(P(
        'Why not drive the board from C directly? The board\'s ports are '
        'available to C as variables (' + C('<cadzilla.h>') + '), but sccz80, '
        'z88dk\'s C compiler for these CPUs, widens every port test to 16 '
        'bits: waiting for room in the ACRTC\'s FIFO costs 9 instructions and '
        'two library calls per pass in C, and 3 instructions in the library. '
        'A drawing library written in C would be bigger and slower than one '
        'it can simply call.'))
    story.append(table([
        ['Language', 'Build', 'Header', 'Example'],
        ['Assembly (' + C('.Z88') + ')', C('tools/z88dk/z88build.sh'),
         C('INCLUDE "CZ88GFX.INC"'), C('software/z88dk/z88demo')],
        ['C (' + C('.c') + ')', C('tools/z88dk/zccbuild.sh'),
         C('#include <cz88gfx.h>'), C('software/zcc/cgfxdemo')]],
        [1.2 * inch, 1.9 * inch, 1.9 * inch, 1.9 * inch]))
    story.append(Spacer(1, 6))

    story.append(P('1.3 The board, in brief', H2))
    story.append(P(
        'CADzilla pairs two chips of the mid 1980s. The <b>HD63484 ACRTC</b> '
        '(Advanced CRT Controller) generates the display and has a '
        'microcoded drawing processor: the host writes 16-bit commands '
        'and their parameters into an 8-word FIFO, and the chip draws into '
        'its own 2 MB of frame memory, which the CPU never addresses '
        'directly. The <b>Bt453</b> RAMDAC turns each 8-bit pixel into a '
        'color through its 256-entry palette. A separate one-bit '
        '<b>overlay</b> plane can be shown over the picture in a color of '
        'its own. The board decodes eight I/O ports from ' + C('70H') + ':'))
    story.append(table([
        ['Port', 'Assembly', 'C (' + C('<cadzilla.h>') + ')', 'Use'],
        ['70H', C('ACRSR'), C('CZ_ACRTC_SR / _AR'),
         'ACRTC status (in) / address register (out)'],
        ['71H', C('MODEREG'), C('CZ_MODE'), 'the board\'s MODE register: '
         'sync polarity, access mode, overlay enable and select (write-only)'],
        ['72H', C('ACRDAT'), C('CZ_ACRTC_DATA'),
         'ACRTC control register data / the command FIFO'],
        ['74H', C('DACADR'), C('CZ_DAC_ADDR'), 'Bt453 address register'],
        ['75H', C('DACPAL'), C('CZ_DAC_PAL'), 'Bt453 palette RAM (R, G, B)'],
        ['77H', C('DACOVL'), C('CZ_DAC_OVL'), 'Bt453 overlay colors (R, G, B)']],
        [0.5 * inch, 0.9 * inch, 1.6 * inch, 3.9 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'cz88gfx programs the board for 8 bits a pixel, one screen, at '
        '640x480, 800x600 or 1024x768. A program never needs the ports '
        'itself, but they are there if it does. The library is assembled for '
        'the board at I/O base ' + C('70H') + '.'))

    story.append(P('1.4 About this guide', H2))
    story.append(P(
        'It describes cz88gfx %s. Macro, routine and function names, '
        'constants, commands and source are set in ' % VERSION + C('Courier') +
        '. "CP" is the ACRTC\'s current drawing pointer. Paths are relative to '
        'the CADzilla repository. The library\'s own reference, kept with the '
        'sources, is ' + C('software/z88dk/cz88gfx/README.md') + '; the toolchain '
        'itself is described in ' + C('tools/z88dk/README.md') + '.'))

    # ================================================== 2. getting started
    story.append(CondPageBreak(4 * inch))
    story.append(P('2. Getting started', H1))
    story.append(P('2.1 A project that uses cz88gfx', H2))
    story.append(P(
        'CADzilla programs run under CP/M 2.2 on the altairsim emulator (or '
        'on the real board), each project with its own machine and disks in '
        'its ' + C('work/') + ' directory. A z88dk project is built on the '
        'host; CP/M only receives the finished ' + C('.COM') + '. A new '
        'project, assembly or C, is scaffolded with:'))
    story.append(code('''
.claude/skills/new-cadzilla-project/scripts/new_project.sh myprog \\
        --toolchain z88dk --cpu z80 --mode 1024x768     # assembly
.claude/skills/new-cadzilla-project/scripts/new_project.sh myprog \\
        --toolchain zcc --cpu z80 --mode 1024x768       # C'''))
    story.append(P('That creates, under ' + C('software/z88dk/myprog/') + ' (or, for C, '
                   + C('software/zcc/myprog/') + '):'))
    story.append(table([
        ['File', 'What it is'],
        [C('src/MYPROG.Z88') + ' or ' + C('src/myprog.c'), 'a starter '
         'program. C sources are lowercase (zcc takes only a lowercase '
         + C('.c') + '); everything else is uppercase'],
        [C('machine.toml'), 'the monitor resolution the project is strapped '
         'for, and the CPU, 8080, 8085 or Z80 (tracked). The build and the '
         'emulator both follow it'],
        [C('cz88gfx.version'), 'the cz88gfx release the project builds '
         'against, e.g. ' + C(VERSION) + ' (tracked)'],
        [C('build/'), 'the build\'s output: ' + C('MYPROG.COM') + ', its map, '
         'listings and symbols (gitignored)'],
        [C('work/'), 'its altairsim machine and CP/M disks (gitignored)']],
        [1.9 * inch, 5.0 * inch]))

    story.append(P('2.2 A first program', H2))
    story.append(P(
        'The same complete program in each language: it sets up the board, '
        'draws a frame round the screen and a blue box in the middle, and '
        'waits for the drawing to finish.'))
    story.append(dual('''
        INCLUDE "CZ88GFX.INC"
        ORG     0100H
START:  GINIT   CZM1K
        GCOLOR  WHITE+BRIGHT
        GBOX    0,0,1023,767
        GFBOX   448,320,576,448,BLUE+BRIGHT
        GWAIT
        RET                     ;to CP/M
''', '''
#include <cz88gfx.h>

int main(void)
{
    cz_init(CZ_M1K);
    cz_color(CZ_WHITE + CZ_BRIGHT);
    cz_box(0, 0, 1023, 767);
    cz_fbox(448, 320, 576, 448,
            CZ_BLUE + CZ_BRIGHT);
    cz_wait();
    return 0;
}
'''))
    story.append(P('It is built on the host, against the release the '
                   'project pins:'))
    story.append(code('''
$ tools/z88dk/z88build.sh software/z88dk/myprog      # assembly
z88dk: MYPROG for z80 (MYPROG.Z88), cz88gfx %s
$ tools/z88dk/zccbuild.sh software/zcc/myprog        # C
zcc: MYPROG for z80 (myprog.c), cz88gfx %s''' % (VERSION, VERSION)))
    story.append(P(
        'Either way the result is ' + C('build/MYPROG.COM') + '. In altairsim, '
        'point the host bridge at ' + C('build/') + ', copy it onto the '
        'project\'s disk with ' + C('R') + ' and run it:'))
    story.append(code('''
A0>R MYPROG.COM
A0>MYPROG'''))
    story.append(P(
        C('build/MYPROG.MAP') + ' shows which library modules went in, and '
        + C('build/MYPROG.SYM') + ' holds the symbols for altairsim\'s '
        + C('SYMBOLS LOAD') + '. The ' + C('cadzilla-build-z88dk') + ' and '
        + C('cadzilla-build-zcc') + ' skills drive the whole cycle.'))

    # ================================================== 3. conventions
    story.append(CondPageBreak(4 * inch))
    story.append(P('3. Conventions', H1))
    story.append(P('3.1 Coordinates and colors', H2))
    story.append(P(
        'The library puts the drawing origin at the <b>bottom-left</b> pixel. '
        'X runs from 0 to ' + C('CZXMAX') + ' left to right, Y from 0 to '
        + C('CZYMAX') + ' bottom to top. These are words in the library that '
        'setup fills in for the mode (1023 and 767 at 1024x768): '
        + C('LHLD CZXMAX') + ' in assembly, ' + C('cz_xmax') + ' in C. A '
        'color is a palette index, 0-255 (chapter 4).'))
    story.append(figure(fig_coords(), 'Figure 1. Screen coordinates.'))

    story.append(P('3.2 In assembly', H2))
    story.extend(bullets([
        'X goes in HL, Y in DE, a color in A. Every routine preserves BC, DE '
        'and HL unless its entry says otherwise, and clobbers A and the '
        'flags. A few macros clobber registers of their own; Appendix A says '
        'which.',
        '<b>Every macro argument is required.</b> z80asm\'s macros can\'t '
        'test for a blank argument. To pass a computed value, load the '
        'registers and call the routine the macro names: '
        + C('LXI D,420') + ' / ' + C('CALL CZMOVE') + '. To draw round the CP, '
        + C('LXI H,7') + ' / ' + C('CALL CZCRCL') + '. A default is written '
        'out: ' + C('GMODE 0') + ', ' + C('GTATTR 2,0,0') + '.',
        'A list is one argument in parentheses: '
        + C('GPTS TRI,(480,448,576,704,400,640)') + '. When the list is the '
        'macro\'s only argument (' + C('GPLINE') + ', ' + C('GPOLY') + '), '
        'double the parentheses: ' + C('GPOLY ((400,24,488,24,444,184))') +
        '. An argument that starts with "(" must end with its ")": write '
        + C('0+(N % 8)*32') + ', not ' + C('(N % 8)*32+1') + '.',
        'Strings are double-quoted: ' + C('GTEXT "Hello"') + '; single quotes '
        'are for one character.',
        'Library names are plain: the header declares them all EXTERN, so '
        + C('CALL CZLDW') + ' and ' + C('LHLD CZXMAX') + ' just work, and an '
        'EXTERN nothing uses links nothing in. Every library global is '
        + C('CZ') + ' plus up to four characters; the header also defines '
        'the hue constants, ' + C('OP...') + ', ' + C('OM...') + ', '
        + C('CM...') + ', ' + C('AM...') + ', ' + C('CP...') + ', the port '
        'names and ' + C('SR...') + ' (Appendix D). Don\'t reuse these names; '
        'z80asm is case-sensitive.',
        '<b>z80asm traps.</b> ' + C('JP x') + ' and ' + C('CP x') + ' are '
        'Zilog\'s unconditional jump and compare, not Intel\'s jump/call if '
        'plus (the build warns). An assembly-time counter is ' + C('DEFL') +
        ', and must be parenthesized, ' + C('N DEFL (N+1)') + ': z80asm '
        'substitutes its text, so after two ' + C('N DEFL N+1') + ', '
        + C('N*19') + ' is 0+1+1*19.']))

    story.append(P('3.3 In C', H2))
    story.extend(bullets([
        'Coordinates are ' + C('int') + ' (relative moves can be negative); '
        'colors, modes and other byte values ' + C('unsigned char') + '; '
        'sizes and radii ' + C('unsigned int') + '.',
        'Each macro is a function named ' + C('cz_') + ' plus its verb: '
        + C('GCOLOR') + ' is ' + C('cz_color') + ', ' + C('GBOX') + ' '
        + C('cz_box') + ', ' + C('GOVL') + ' ' + C('cz_ovl') + '; '
        + C('GMODE') + ' is ' + C('cz_setmode') + '. Where assembly calls a '
        'routine "at the CP", C has a ' + C('_cp') + ' function: '
        + C('cz_circle_cp(r)') + '. Appendix C lists them all.',
        'Constants carry ' + C('CZ_') + ': ' + C('CZ_RED + CZ_BRIGHT') + ', '
        + C('CZ_OM_EOR') + ', ' + C('CZ_CM_CL1') + ', ' + C('CZ_AM_CLIP') +
        ', ' + C('CZ_CP_R90') + ', ' + C('CZ_DIR_CW') + '. ' + C('cz88gfx.h') +
        ' includes ' + C('<cadzilla.h>') + ', which adds the ports and the '
        'status bits ' + C('CZ_SR_CER') + ', ' + C('CZ_SR_ARD') + ' and so on.',
        'Point and pattern tables are C arrays in the library\'s own layout, '
        'the count first: ' + C('static const int tri[] = { 3, 480,448, '
        '576,704, 400,640 };') + '.',
        'Calling conventions (sccz80): a one-argument function is '
        + C('__z88dk_fastcall') + ', its argument in HL; one with more is '
        + C('__smallc __z88dk_callee') + ', which pushes the arguments left to '
        'right and leaves the function to pop them, so a call site has no '
        'clean-up code. The header declares this; a program just calls. '
        'Nothing uses the Z80\'s IX or IY.',
        'Don\'t define names of your own beginning ' + C('cz_') + ' or '
        + C('CZ_') + '. The library never calls the BDOS; console I/O is '
        'the program\'s.']))

    story.append(P('3.4 Waiting, and errors', H2))
    story.append(P(
        'Drawing calls only send commands; the ACRTC draws them from its '
        'FIFO while the program goes on. ' + C('GWAIT') + ' / '
        + C('cz_wait()') + ' waits until the FIFO is empty and the last '
        'command has ended, and returns the status register: in assembly in '
        'A, with <b>Z</b> if the drawing ended cleanly and <b>NZ</b> on a '
        'command error; in C as the return value, where '
        + C('cz_wait() & CZ_SR_CER') + ' tests for the error (CER, status bit '
        '7: an undefined command or a bad parameter). ' + C('GABORT') + ' / '
        + C('cz_abort()') + ' stops the chip, flushes the FIFOs and clears '
        'CER. On the real board, and in altairsim with '
        + C('draw_rate = "real"') + ', drawing takes time, and waiting is '
        'also how a program knows it has finished.'))

    # ================================================== 4. display setup
    story.append(CondPageBreak(4 * inch))
    story.append(P('4. Setting up the display', H1))
    story.append(P('4.1 Setup and the display modes', H2))
    story.append(P(
        C('GINIT mode') + ' / ' + C('cz_init(mode)') + ' sets up the whole '
        'board for one display mode: the MODE register, the ACRTC\'s timing '
        'and display registers, the default palette, the drawing parameters, '
        'the overlay, and a clear screen. The mode is a descriptor in the '
        'library:'))
    story.append(ctable([
        ['Assembly', 'C', 'Mode', 'Screen'],
        ['CZM640', 'CZ_M640', 'VESA 640x480 @ 60 Hz', 'X 0-639, Y 0-479'],
        ['CZM800', 'CZ_M800', 'VESA 800x600 @ 60 Hz', 'X 0-799, Y 0-599'],
        ['CZM1K', 'CZ_M1K', 'VESA 1024x768 @ 60 Hz', 'X 0-1023, Y 0-767']],
        [1.0 * inch, 1.0 * inch, 2.4 * inch, 2.5 * inch], cols=2))
    story.append(Spacer(1, 6))
    story.append(P(
        'The monitor is fixed-frequency, chosen by a strap (in altairsim, '
        'cad0\'s ' + C('mode') + ' in the project\'s ' + C('machine.toml') +
        '; 1024x768 by default). The descriptor must match it: the board '
        'doesn\'t reject a mismatch, the picture just lands in the wrong '
        'place in the monitor\'s frame (altairsim\'s ' + C('board_get cad0') +
        ' shows the picture\'s position). Setup clobbers all registers; a '
        'descriptor of your own goes in HL for ' + C('CALL CZINIT') + ', or '
        'to ' + C('cz_init') + ' as a pointer.'))
    story.append(P(
        'After setup: the screen is color 0; the drawing color (CL1) is 255, '
        'white; CL0 and CCMP are 0; the drawing mode is replace with no area '
        'checking; the pattern RAM is all ones; the area is the whole screen; '
        'the overlay is clear, hidden and white; and drawing goes to the '
        'frame.'))
    story.append(P('4.2 Clearing', H2))
    story.append(P(
        C('GCLS c') + ' / ' + C('cz_cls(c)') + ' clears the whole screen to '
        'color c with the ACRTC\'s block clear, the fastest way to fill the '
        'screen. ' + C('GOVCLS') + ' / ' + C('cz_ovcls()') + ' clears the '
        'overlay (chapter 10).'))
    story.append(P('4.3 Colors and the palette', H2))
    story.append(P(
        'A pixel is a palette index, 0-255. ' + C('GCOLOR c') + ' / '
        + C('cz_color(c)') + ' sets the drawing color. Setup loads a default '
        'palette of eight hues with 32 brightness levels each: <b>index = '
        'hue + level</b>, where the hue is one of the constants below and '
        'the level runs from 0 (black) to ' + C('BRIGHT') + ' / '
        + C('CZ_BRIGHT') + ' (31). ' + C('CYAN+BRIGHT') + ' / '
        + C('CZ_CYAN + CZ_BRIGHT') + ' is full cyan; ' + C('RED+16') + ' / '
        + C('CZ_RED + 16') + ' a half-bright red.'))
    story.append(figure(fig_palette(),
                        'Figure 2. The default palette, as setup loads it. '
                        'In C the hues are CZ_ORANGE ... CZ_WHITE.'))
    story.append(P(
        C('GPAL i,r,g,b') + ' / ' + C('cz_pal(i, r, g, b)') + ' sets palette '
        'entry i to any color (0-255 each component; the macro clobbers BC '
        'and E). Changing an entry recolors everything already drawn in it '
        'at once, which makes palette animation cheap. ' + C('CALL CZPALD') +
        ' / ' + C('cz_paldef()') + ' loads the default palette again.'))
    story.append(shot(1, 'Demo screen 1: all 256 entries of the default '
                         'palette as filled boxes, in a white frame '
                         '(GFRECT, GBOX / cz_frect, cz_box).'))

    # ================================================== 5. drawing
    story.append(CondPageBreak(4 * inch))
    story.append(P('5. Lines, rectangles and polygons', H1))
    story.append(P('5.1 The drawing pointer', H2))
    story.append(P(
        'The ACRTC draws from its current drawing pointer, the CP. A move '
        'sets it; the drawing calls draw from it and most leave it at their '
        'end point. Each comes in an absolute form, to x,y, and a relative '
        'one, by dx,dy from the CP:'))
    story.append(_ptr_table())
    story.append(Spacer(1, 6))
    story.append(P(
        'Because a line\'s end point isn\'t drawn, a closed shape drawn from '
        'lines lights each corner exactly once, which matters when drawing '
        'in EOR mode. In assembly, with X and Y already in HL and DE, call '
        'the routine directly: ' + C('CZMOVE') + ', ' + C('CZLINE') + ', '
        + C('CZRECT') + ', ' + C('CZFRCT') + ', ' + C('CZDOT') + ' and the '
        'relative ' + C('CZRMOV') + ', ' + C('CZRLIN') + ', ' + C('CZRRCT')
        + ', ' + C('CZRFRC') + '. Three calls combine a move with a drawing:'))
    story.append(ctable([
        ['Assembly', 'C', 'Does'],
        ['GSEG x1,y1,x2,y2', 'cz_seg(x1, y1, x2, y2)',
         'a line from x1,y1 to x2,y2 (x2,y2 not drawn)'],
        ['GBOX x1,y1,x2,y2', 'cz_box(x1, y1, x2, y2)',
         'a rectangle outline with corners x1,y1 and x2,y2'],
        ['GFBOX x1,y1,x2,y2,c', 'cz_fbox(x1, y1, x2, y2, c)',
         'a filled rectangle in color c (which becomes the drawing color)']],
        [1.75 * inch, 2.15 * inch, 3.0 * inch], cols=2))
    story.append(P('5.2 Polylines and polygons', H2))
    story.append(P(
        'A polyline is drawn through a list of points; a polygon is closed '
        'back to its first point. The library takes a <b>point table</b>: '
        'the number of points, then the X,Y pairs, at least 2 points.'))
    story.append(dual('''
        GPOLY   ((240,704,202,595,88,594))
        GPLG    TRI     ;from a table
        GPLT    SINE    ;open, from a table
        ...
        GPTS    TRI,(480,448,576,704,400,640)
SINE:   DW      33      ;by hand: the count,
        DW      64,152,93,186,...  ;the pairs
''', '''
static const int tri[] =
    { 3, 480,448, 576,704, 400,640 };
static const int sine[] =
    { 33, 64,152, 93,186, ... };

cz_polygon(tri);
cz_polyline(sine);
'''))
    story.append(P(
        'In assembly ' + C('GPLINE') + ' and ' + C('GPOLY') + ' place their '
        'points inline (and jump over them); ' + C('GPLT tbl') + ' and '
        + C('GPLG tbl') + ' draw from a table, which ' + C('GPTS') + ' builds. '
        'A macro call must fit on one line, so write a longer table\'s '
        + C('DW') + 's by hand in the same layout. These macros clobber HL. '
        'In C, ' + C('cz_polyline(t)') + ' and ' + C('cz_polygon(t)') + ' '
        'take the array.'))
    story.append(shot(2, 'Demo screen 2: a 36-spoke starburst from a data '
                         'table (lines from the centre), and ten nested '
                         'rectangles from a loop (GBOX / cz_box).'))
    story.append(shot(3, 'Demo screen 3: a star, a hexagon and a triangle '
                         '(polygons), a sine wave (a polyline) and 400 '
                         'random dots.'))

    # ================================================== 6. curves
    story.append(CondPageBreak(4 * inch))
    story.append(P('6. Circles, ellipses and arcs', H1))
    story.append(ctable([
        ['Assembly', 'C', 'Draws'],
        ['GCIRC x,y,r', 'cz_circle(x, y, r)', 'a circle of radius r centred '
         'on x,y; the CP is left at the centre'],
        ['CALL CZCRCL (HL = r)', 'cz_circle_cp(r)', 'the same, round the CP'],
        ['GELLIP x,y,rx,ry', 'cz_ellipse(x, y, rx, ry)', 'an ellipse with '
         'semi-axes rx (along X) and ry (along Y), each up to 4095'],
        ['CALL CZELPS (HL, DE)', 'cz_ellipse_cp(rx, ry)', 'the same, round '
         'the CP'],
        ['GARC xc,yc,xe,ye,dir', 'cz_arc(xc, yc, xe, ye, dir)', 'an arc from '
         'the CP round the centre xc,yc to where it meets the ray from the '
         'centre through xe,ye'],
        ['GRARC ...', 'cz_rarc(...)', 'the same, the centre and xe,ye '
         'relative to the CP'],
        ['GEARC rx,ry,xc,yc,xe,ye,dir', 'cz_earc(rx, ry, xc, yc, xe, ye, dir)',
         'an arc of an ellipse whose semi-axes are in the ratio rx:ry'],
        ['GREARC ...', 'cz_rearc(...)', 'the same, relative to the CP']],
        [2.25 * inch, 2.45 * inch, 2.2 * inch], cols=2))
    story.append(Spacer(1, 6))
    story.extend(bullets([
        'An arc starts at the CP, and its radius is the CP\'s distance from '
        'the centre. It runs counter-clockwise (' + C('DIRCCW') + ' / '
        + C('CZ_DIR_CCW') + ') or clockwise (' + C('DIRCW') + ' / '
        + C('CZ_DIR_CW') + '), and stops at the ray through xe,ye, so xe,ye '
        'need not be exactly on the curve. The CP is left at xe,ye, which is '
        'not drawn.',
        'For an elliptical arc only the ratio rx:ry matters (each at most '
        '90): the size comes from the CP. Started on the ellipse\'s '
        'horizontal axis, a distance d from the centre, the arc lies on the '
        'ellipse with semi-axes d along X and d * ry / rx along Y.',
        'The chip takes the squares of rx and ry. The macro computes them at '
        'assembly time; in C, ' + C('cz_earc') + ' and ' + C('cz_rearc') +
        ' are macros that square their arguments (at compile time for '
        'constants, and so evaluate each twice) for the functions '
        + C('cz_earc_sq') + ' and ' + C('cz_rearc_sq') + '.',
        'Circles and ellipses are drawn in order round the curve, so a '
        'dashed line style runs along them (chapter 8).',
        'The arc macros clobber HL.']))
    story.append(shot(4, 'Demo screen 4: concentric circles, a rainbow of '
                         'half-circle arcs drawn both ways round, ellipses, '
                         'and a spiral of elliptical half arcs.'))

    # ================================================== 7. drawing modes
    story.append(CondPageBreak(4 * inch))
    story.append(P('7. Drawing modes', H1))
    story.append(P(
        'Every ACRTC drawing command carries a mode in its low byte. cz88gfx '
        'keeps that byte, ' + C('CZDM') + ', and adds it to every drawing '
        'command it sends (all but the moves). Setup resets it to 0: '
        'replace, two-color pattern, no area checking.'))
    story.append(figure(fig_mode_byte(), 'Figure 3. The drawing mode byte.'))
    story.append(P(
        C('GMODE m') + ' / ' + C('cz_setmode(m)') + ' sets the whole byte, '
        'e.g. ' + C('GMODE OMEOR+CMCL1+AMCLIP') + ' / '
        + C('cz_setmode(CZ_OM_EOR + CZ_CM_CL1 + CZ_AM_CLIP)') + '; 0 resets '
        'it. ' + C('GOPM') + ', ' + C('GCMODE') + ' and ' + C('GAMODE') + ' / '
        + C('cz_opm') + ', ' + C('cz_cmode') + ' and ' + C('cz_amode') +
        ' each set one field and keep the others.'))
    story.append(P('7.1 Operation modes', H2))
    story.append(P('The operation mode says how the color C being drawn meets '
                   'the pixel P already there:'))
    story.append(ctable([
        ['Assembly', 'C', 'Result'],
        ['OMREP', 'CZ_OM_REP', 'C (replace)'],
        ['OMOR', 'CZ_OM_OR', 'P OR C'],
        ['OMAND', 'CZ_OM_AND', 'P AND C'],
        ['OMEOR', 'CZ_OM_EOR', 'P XOR C: drawing the same thing twice '
         'restores the picture'],
        ['OMEQ', 'CZ_OM_EQ', 'C only where P = CCMP (GCCMP c / cz_ccmp(c))'],
        ['OMNE', 'CZ_OM_NE', 'C only where P is not CCMP'],
        ['OMLT', 'CZ_OM_LT', 'C only where P < C'],
        ['OMGT', 'CZ_OM_GT', 'C only where P > C']],
        [1.1 * inch, 1.2 * inch, 4.6 * inch], cols=2))
    story.append(Spacer(1, 4))
    story.append(P('The logic and comparisons work on the palette index.',
                   NOTE))
    story.append(shot(5, 'Demo screen 5: in each panel, two overlapping '
                         'boxes drawn over colored bands in one operation '
                         'mode. Top: replace, OR, AND, EOR (where the boxes '
                         'overlap, EOR restores the bands). Bottom: =CCMP, '
                         '<>CCMP, <C, >C.'))
    story.append(P('7.2 Color modes', H2))
    story.append(P(
        'The ACRTC draws every pixel through its pattern RAM (chapter 8). '
        'The color mode says what each pattern bit draws. With setup\'s '
        'all-ones pattern, every mode but CL0-only simply draws in CL1. CL0 '
        'is set with ' + C('GBCOL c') + ' / ' + C('cz_bcol(c)') + '.'))
    story.append(ctable([
        ['Assembly', 'C', 'A 1 bit draws', 'A 0 bit draws'],
        ['CMSEL', 'CZ_CM_SEL', 'CL1 (the drawing color)', 'CL0'],
        ['CMCL1', 'CZ_CM_CL1', 'CL1', 'nothing: the pattern is transparent'],
        ['CMCL0', 'CZ_CM_CL0', 'nothing', 'CL0'],
        ['CMPRAM', 'CZ_CM_PRAM', 'the pattern RAM is a 4x4 tile of colors', '']],
        [1.0 * inch, 1.2 * inch, 2.4 * inch, 2.3 * inch], cols=2))
    story.append(P('7.3 Area modes', H2))
    story.append(P(
        'The area modes check each pixel against a rectangle, set with '
        + C('GAREA x1,y1,x2,y2') + ' / ' + C('cz_area(x1, y1, x2, y2)') +
        ' (low and high corners, both inside) and reset to the whole screen '
        'with ' + C('GAFULL') + ' / ' + C('cz_afull()') + ':'))
    story.append(ctable([
        ['Assembly', 'C', 'Effect'],
        ['AMNONE', 'CZ_AM_NONE', 'no checking'],
        ['AMCLIP', 'CZ_AM_CLIP', 'draw only inside the area'],
        ['AMHOLE', 'CZ_AM_HOLE', 'draw only outside it'],
        ['AMCLPD', 'CZ_AM_CLPD', 'as AMCLIP, and set ARD if a pixel was '
         'dropped'],
        ['AMHOLD', 'CZ_AM_HOLD', 'as AMHOLE, and set ARD if a pixel was '
         'dropped'],
        ['AMSTOP', 'CZ_AM_STOP', 'stop at the first pixel outside the area, '
         'and set ARD'],
        ['AMSTPI', 'CZ_AM_STPI', 'stop at the first pixel inside the area, '
         'and set ARD']],
        [1.1 * inch, 1.3 * inch, 4.5 * inch], cols=2))
    story.append(Spacer(1, 6))
    story.append(P(
        'ARD is status bit 6. After waiting, ' + C('ANI SRARD') + ' tests it '
        'in assembly, ' + C('cz_wait() & CZ_SR_ARD') + ' in C. After a stop '
        'the CP is the pixel where the drawing stopped; ' + C('GGETCP') +
        ' / ' + C('cz_getcp(&x, &y)') + ' reads it back (chapter 12), and '
        'also clears ARD.'))

    # ================================================== 8. pattern RAM
    story.append(CondPageBreak(4 * inch))
    story.append(P('8. The pattern RAM', H1))
    story.append(P(
        'The ACRTC draws every pixel, of lines and fills alike, through its '
        '16-word pattern RAM. Setup fills it with ones, so everything draws '
        'in CL1 until a program loads a pattern of its own.'))
    story.append(P('8.1 Layout and the pattern pointer', H2))
    story.extend(bullets([
        'In the bit color modes word n is pattern <b>row n</b> and bit m '
        'its <b>column m</b>. Row 0 is the first row drawn (the bottom of a '
        'fill), bit 0 the leftmost pixel.',
        'A pattern pointer walks the RAM: one bit per pixel along a line '
        '(continuing round the corners of a rectangle, polygon or circle), '
        'one row per raster in a fill.',
        C('GPSCAN x0,y0,x1,y1,zx,zy') + ' / '
        + C('cz_pscan(x0, y0, x1, y1, zx, zy)') + ' sets the window it walks, '
        'columns x0..x1 and rows y0..y1, and a zoom that draws each bit zx+1 '
        'times across and zy+1 times up (0,0: none). It also puts the '
        'pointer at the window\'s start.',
        'The pointer is <b>live</b>: it stays where the last drawing left '
        'it. Reset it with ' + C('GPPTR x,y') + ' / ' + C('cz_pptr(x, y)') +
        ' before a fill whose tiling must line up. ' + C('GPDEF') + ' / '
        + C('cz_pdef()') + ' puts everything back as setup left it.']))
    story.append(P('8.2 Loading patterns', H2))
    story.append(P(
        'A <b>pattern table</b> is the number of words, then the words. '
        'Loading one fills the pattern RAM from a given word (0: the start). '
        'A color tile for ' + C('CMPRAM') + ' / ' + C('CZ_CM_PRAM') + ' is a '
        'pattern table of 16 words, each a color in both bytes, its first '
        'four the bottom row.'))
    story.append(dual('''
        GLDPAT  RING,0
        GPSCAN  0,0,15,15,0,0
        GCMODE  CMCL1   ;0 bits transparent
        GFBOX   100,100,300,200,YELLOW+BRIGHT
        ...
        GPAT    RING,(0,0,07E0H,1FF8H,...)
        GTILE   TILE,(159,223,95,127,...)
''', '''
static const unsigned int ring[] =
    { 16, 0, 0, 0x07E0, 0x1FF8, ... };
static const unsigned int tile[] =
    { 16, CZ_TILE(159), CZ_TILE(223), ... };

cz_ldpat(ring, 0);
cz_pscan(0, 0, 15, 15, 0, 0);
cz_cmode(CZ_CM_CL1);
cz_fbox(100, 100, 300, 200,
        CZ_YELLOW + CZ_BRIGHT);
'''))
    story.append(P(
        'In assembly ' + C('GPAT') + ' and ' + C('GTILE') + ' build the '
        'tables and ' + C('GLDPAT') + ' clobbers HL. In C, '
        + C('CZ_TILE(c)') + ' makes a tile word from a color. '
        + C('GPSCAN') + ' takes constants; with the window in a 6-byte '
        'table at run time, ' + C('CALL CZPSCN') + '. ' + C('cz_pscan') +
        ' takes run-time values.'))
    story.append(P('8.3 Line styles', H2))
    story.append(P(
        C('GLSTYL pat,zoom') + ' / ' + C('cz_lstyle(pat, zoom)') + ' is the '
        'quick way to dashed lines: pattern row 0 becomes the 16-bit style '
        '(bit 0 first), the window becomes 16x1 and the pointer is reset. '
        'Fills use the style too, so set it back with '
        + C('GLSTYL 0FFFFH,0') + ' / ' + C('cz_lstyle(0xFFFF, 0)') + ' (or the '
        'pattern defaults) afterwards. In ' + C('CMCL1') + ' the gaps leave '
        'the picture alone; in ' + C('CMSEL') + ' they draw in CL0.'))
    story.append(dual('''
        GCMODE  CMCL1
        GLSTYL  0F0F0H,0        ;4 on, 4 off
        GBOX    40,24,200,184
        GLSTYL  0FFFFH,0        ;solid
''', '''
cz_cmode(CZ_CM_CL1);
cz_lstyle(0xF0F0, 0);    /* 4 on, 4 off */
cz_box(40, 24, 200, 184);
cz_lstyle(0xFFFF, 0);    /* solid */
'''))
    story.append(P('8.4 Drawing the pattern itself', H2))
    story.append(P(
        C('GPTN x,y,w,h,dir') + ' / ' + C('cz_ptn(x, y, w, h, dir)') + ' '
        'draws the pattern RAM as a w x h picture (1-256 each) with its '
        'corner at x,y. Its rows run in direction dir, 45 degrees apart '
        'counter-clockwise from +X, and are stacked 90 degrees further round; '
        'adding ' + C('PTSLNT') + ' / ' + C('CZ_PTSLNT') + ' stacks them only '
        '45 degrees round, slanting the picture. A diagonal direction leaves '
        'gaps between pixels, as the chip\'s PTN does. Text (chapter 11) is '
        'drawn this way. ' + C('cz_ptn_cp(w, h, dir)') + ' draws at the CP.'))
    story.append(figure(fig_directions(), 'Figure 4. Directions 0-7, used by '
                                          'the pattern drawing and text.'))
    story.append(shot(6, 'Demo screen 6. Top: a ring pattern filled in '
                         'CMSEL, CMCL1 and CMCL0, and a 4x4 color tile in '
                         'CMPRAM. Bottom left: line styles, and dashes '
                         'running round a box, a circle and a triangle. '
                         'Bottom right: the pattern drawn turned 0, 90, 180 '
                         'and 270 degrees, slanted, and at 45 degrees.'))

    # ================================================== 9. paint and copy
    story.append(CondPageBreak(4 * inch))
    story.append(P('9. PAINT, flood and copy', H1))
    story.append(P('9.1 Painting areas', H2))
    story.append(P(
        C('GPAINT x,y,e') + ' / ' + C('cz_paint(x, y, e)') + ' fills outward '
        'from x,y, in the current color, pattern and modes, up to pixels of '
        'the edge color e. ' + C('GFLOOD x,y,c') + ' / '
        + C('cz_flood(x, y, c)') + ' instead fills the connected region of '
        'color c round x,y, recoloring one shape. From the CP: '
        + C('CALL CZPANT') + ' / ' + C('CZFLOD') + ' with the color in A, '
        + C('cz_paint_cp(e)') + ' / ' + C('cz_flood_cp(c)') + '.'))
    story.extend(bullets([
        '<b>CL0 and CL1 are edges too.</b> The chip also stops at any pixel '
        'already in CL0 or CL1. After setup CL0 is 0, so painting over black '
        'paints nothing until CL0 is set to something else. For a solid '
        'fill, set it to the fill color.',
        '<b>Outlines must be closed.</b> The fill is 4-connected, so an '
        '8-connected outline (lines, circles) holds it, but a line\'s end '
        'point isn\'t drawn: run spokes a pixel past a circle.',
        '<b>On the real board</b>, PAINT keeps only four pending seed points '
        'and hands any more to the host, which cz88gfx doesn\'t do, so a '
        'complicated area may be left partly unfilled. altairsim has no such '
        'limit.']))
    story.append(P('9.2 Copying blocks', H2))
    story.append(P(
        C('GCOPY x1,y1,x2,y2,xd,yd,t') + ' / '
        + C('cz_copy(x1, y1, x2, y2, xd, yd, t)') + ' copies the rectangle '
        'with corners x1,y1 and x2,y2 so that corner x1,y1 lands on xd,yd, '
        'transformed by t (' + C('CPNORM') + ' / ' + C('CZ_CP_NORM') + ': as '
        'it is). The operation and area modes apply at the destination; the '
        'color mode doesn\'t, since the source pixel is the color. The macro '
        'clobbers HL.'))
    story.append(figure(fig_transforms(),
                        'Figure 5. The copy\'s transforms, shown on an F. The '
                        'red dot is the source corner x1,y1, which lands on '
                        'xd,yd.'))
    story.append(shot(7, 'Demo screen 7. Top left: circles clipped to an '
                         'area (AMCLPD, yellow) and to outside it (AMHOLD, '
                         'blue). Bottom left: lines that stop at the edge of '
                         'an area (AMSTOP, AMSTPI), ringed where the CP was '
                         'read back. Top right: a pie chart painted solid, '
                         'patterned and flood-recolored. Bottom right: a '
                         'picture copied in all eight orientations, in EOR, '
                         'and clipped.'))

    # ================================================== 10. overlay
    story.append(CondPageBreak(4 * inch))
    story.append(P('10. The overlay', H1))
    story.append(P(
        'The board has a second plane over the 8-bit picture: the '
        '<b>overlay</b>, one bit per pixel in its own memory. Wherever a bit '
        'is set and the overlay is shown, the Bt453 shows the overlay color '
        'instead of the pixel\'s palette color; a clear bit lets the picture '
        'through. So what is drawn on the overlay can be shown, hidden, '
        'recolored or erased without disturbing the picture under it: a '
        'cursor, a grid, selection marks, rubber-band lines, text.'))
    story.append(ctable([
        ['Assembly', 'C', 'Does'],
        ['GOVON / GOVOFF', 'cz_ovon() / cz_ovoff()',
         'show / hide the overlay; what is drawn in it stays'],
        ['GOVPAL r,g,b', 'cz_ovpal(r, g, b)',
         'the overlay color (the macro clobbers BC, E)'],
        ['GOVL', 'cz_ovl()', 'draw on the overlay from here on'],
        ['GFRAME', 'cz_frame()', 'draw on the frame again'],
        ['GOVCLS', 'cz_ovcls()', 'clear the whole overlay, from either']],
        [1.5 * inch, 1.9 * inch, 3.5 * inch], cols=2))
    story.append(Spacer(1, 6))
    story.extend(bullets([
        'Between the switch to the overlay and back, every drawing call draws '
        'on the overlay, with the frame\'s own coordinates.',
        'Overlay pixels are one bit, so the only colors are ' + C('OVSET') +
        ' / ' + C('CZ_OVSET') + ' (on) and ' + C('OVCLR') + ' / '
        + C('CZ_OVCLR') + ' (off).',
        'EOR toggles bits: drawing a shape twice undraws it, the classic '
        'moving cursor.',
        'Patterns, the area modes and PAINT work on the overlay (set CL0 to '
        + C('OVSET') + ' before painting); color tiles mean nothing at one '
        'bit a pixel. The copy works within the overlay, not between the '
        'planes.',
        'Both switches wait for the ACRTC to finish, since they change its '
        'pixel depth, and leave the CP at 0,0: move afterwards.']))
    story.append(dual('''
        GOVPAL  255,255,0       ;yellow
        GOVL
        GCOLOR  OVSET
        GMODE   OMEOR
        CALL    XHAIR   ;draw a crosshair
        CALL    XHAIR   ;undraw it
        GMODE   0
        GFRAME
        GOVON
''', '''
cz_ovpal(255, 255, 0);   /* yellow */
cz_ovl();
cz_color(CZ_OVSET);
cz_setmode(CZ_OM_EOR);
xhair();                 /* draw */
xhair();                 /* undraw */
cz_setmode(0);
cz_frame();
cz_ovon();
'''))
    story.append(shot(8, 'Demo screen 8: the palette of screen 1 on the '
                         'frame, and on the overlay in yellow a grid, a '
                         'circle, a patterned and a solid box, and a '
                         'crosshair moved in EOR. Hiding the overlay shows '
                         'screen 1 unchanged.'))
    story.append(P(
        'How it works: the overlay has no display cycles of its own; each '
        'frame fetch also reads the overlay word for the same 16 pixels. '
        'The ACRTC draws it through a character (CHR) screen that the board '
        'routes to the overlay memory and never displays; setup gives it the '
        'frame\'s coordinates. Switching to the overlay sets the chip to 1 '
        'bit a pixel, and back to 8, after waiting, so that queued commands '
        'run at the depth they were sent for.', NOTE))

    # ================================================== 11. text
    story.append(CondPageBreak(4 * inch))
    story.append(P('11. Text', H1))
    story.append(P(
        'cz88gfx draws text a character at a time with the ACRTC\'s PTN '
        'command: each glyph is unpacked into the pattern RAM and PTN draws '
        'the character cell at the pen. That brings scaling (the pattern '
        'zoom, 1-16 times), turning (PTN\'s direction, in 45-degree steps) '
        'and the drawing modes with it. Text goes on whichever plane is being '
        'drawn, frame or overlay, in CL1.'))
    story.append(P('11.1 Fonts', H2))
    story.append(P(
        'A font is chosen by naming it, and naming it is also what links it '
        'in, so a program carries only the fonts it uses. Both cover '
        'characters 20H-7EH; others draw as a blank.'))
    story.append(ctable([
        ['Assembly', 'C', 'Cell', 'Glyphs', 'Bytes'],
        ['CZF8', 'CZ_F8', '8x8', '5x7, no true descenders', '480'],
        ['CZF11', 'CZ_F11', '9x11', '7x10: capitals 8 rows, 2 descender rows',
         '860']],
        [0.9 * inch, 0.9 * inch, 0.6 * inch, 3.8 * inch, 0.7 * inch], cols=2))
    story.append(Spacer(1, 6))
    story.append(figure(fig_font(mk, 'CZF8'), 'Figure 6. CZF8, the 8x8 font.'))
    story.append(figure(fig_font(mk, 'CZF11'),
                        'Figure 7. CZF11, the 9x11 font.'))
    story.append(P('11.2 Drawing text', H2))
    story.append(ctable([
        ['Assembly', 'C', 'Does'],
        ['GFONT f', 'cz_font(f)', 'draw text in font f (the macro clobbers HL)'],
        ['GTPOS x,y', 'cz_tpos(x, y)', 'put the pen at x,y: the bottom-left '
         'corner of the next character\'s cell; also the start of the line'],
        ['GTATTR s,d,f', 'cz_tattr(s, d, f)', 'scale 1-16, direction 0-7, '
         'flags 0 or opaque (the macro clobbers BC)'],
        ['GTEXT "text"', 'cz_text("text")', 'draw the text at the pen. The '
         'macro places it inline (clobbers HL, B); the function takes a '
         'NUL-terminated string, 255 characters at most'],
        ['GTSTR (HL, B)', 'cz_tstr(s, n)', 'draw n characters from s'],
        ['GTCHR c', 'cz_tchr(c)', 'draw one character'],
        ['GTNL', 'cz_tnl()', 'a new line: the start of the line moves one '
         'line on, and the pen goes there']],
        [1.3 * inch, 1.5 * inch, 4.1 * inch], cols=2))
    story.append(Spacer(1, 6))
    story.append(dual('''
        GOVL                    ;on the overlay
        GCOLOR  OVSET
        GFONT   CZF11
        GTATTR  2,0,0           ;scale 2, +X
        GTPOS   24,730
        GTEXT   "CADzilla text overlay"
        GTNL                    ;the next line
        GFRAME
''', '''
cz_ovl();                 /* on the overlay */
cz_color(CZ_OVSET);
cz_font(CZ_F11);
cz_tattr(2, 0, 0);        /* scale 2, +X */
cz_tpos(24, 730);
cz_text("CADzilla text overlay");
cz_tnl();                 /* the next line */
cz_frame();
'''))
    story.extend(bullets([
        'After each character the pen moves one cell width times the scale '
        'along the direction; a string is characters x cell width x scale '
        'long. A new line moves one cell height times the scale, 90 degrees '
        'clockwise from the direction (down, for ordinary text).',
        'Both fonts have a blank top row and blank right-hand columns, so '
        'text set at the cell pitch doesn\'t touch.',
        '<b>Transparent</b> text (the default) leaves the picture alone in '
        'a glyph\'s 0 bits. <b>Opaque</b> text (' + C('TXOPAQ') + ' / '
        + C('CZ_TXOPAQ') + ') draws the whole cell, the 0 bits in CL0: for '
        'text rewritten in place, such as a status line. On the overlay, set '
        'CL0 to ' + C('OVCLR') + '.',
        'The color mode is forced only while a string is drawn; the '
        'operation and area modes apply as usual.',
        'A string leaves the pattern RAM as setup does, and moves the CP: '
        'load your own pattern, and move, afterwards.',
        'Choose a font first: until then, text draws nothing (in assembly, '
        'the calls return C).']))
    story.append(shot(10, 'Demo screen 10: screen 2 on the frame, and on '
                          'the overlay a 9x11 title at scale 2, both fonts '
                          'scaled up, both character sets (three lines '
                          'each), text turned 90 and 45 degrees, and an '
                          'opaque status line rewritten in place. The red '
                          'line is drawn on the frame itself.'))
    story.append(P(
        'Size: the string-drawing core (' + C('CZTXT') + ', 444 bytes) is all '
        'a program that only draws strings needs; the pen, attribute, '
        'character and newline calls are a separate module (' + C('CZTXL') +
        '). An assembly program that wants to stay small can store the pen, '
        'scale and direction into the text state ' + C('CZTST') + ' itself, '
        'at offsets +0/+2 (pen X, Y), +8 (scale), +9 (direction) and +10 '
        '(flags), and call ' + C('CZTFNT') + ' and ' + C('CZTSTR') + ' '
        'directly.', NOTE))

    # ================================================== 12. reading back
    story.append(P('12. Reading back', H1))
    story.append(ctable([
        ['Assembly', 'C', 'Returns'],
        ['GGETCP', 'cz_getcp(&x, &y)', 'the CP: in HL and DE, or into x and '
         'y. It also clears ARD.'],
        ['GRDOT x,y', 'cz_rdot(x, y)', 'the pixel at x,y: its palette index '
         '(in A, NC). Off the screen: C with A = 0; in C, -1']],
        [1.3 * inch, 1.6 * inch, 4.0 * inch], cols=2))
    story.append(Spacer(1, 6))
    story.append(P(
        'Both read through the ACRTC\'s read FIFO, after everything sent '
        'before them has been drawn. Reading a pixel reads the frame, '
        'whichever plane is being drawn.'))

    # ================================================== 13. versions
    story.append(CondPageBreak(4 * inch))
    story.append(P('13. Library versions', H1))
    story.append(P(
        'cz88gfx is released in numbered versions, and each program builds '
        'against the release it pins. A new cz88gfx version therefore reaches '
        'a program only when the program moves to it.'))
    story.append(table([
        ['Where', 'What'],
        [C('CZ88GFX.INC: CZ88VER') + '<br/>' + C('cz88gfx.h: CZ88GFX_VERSION'),
         'the version: ' + C('0101H') + ' / ' + C('0x0101') + ' is 1.1, major '
         'in the high byte, minor in the low. A program can check it at '
         'assembly or compile time.'],
        [C('software/z88dk/cz88gfx/releases/<v>/'), 'the releases: '
         + C('CZ88GFX.LIB') + ', ' + C('CZ88GFX.INC') + ' and (1.1 on) '
         + C('cz88gfx.h') + ', tracked, read-only and never changed'],
        [C('software/<toolchain>/<project>/cz88gfx.version'), 'the pin: one line, e.g. '
         + C(VERSION) + ', or ' + C('dev') + ' for the library\'s own current '
         'build']],
        [2.9 * inch, 4.0 * inch]))
    story.append(Spacer(1, 6))
    story.append(table([
        ['Release', 'What changed'],
        ['1.0', 'czgfx 1.0 ported to z80asm'],
        ['1.1', 'the C bindings: ' + C('cz88gfx.h') + ' and the ' + C('CZC*') +
         ' modules. The graphics modules are byte for byte 1.0\'s. A C '
         'program needs 1.1 or later.']],
        [0.9 * inch, 6.0 * inch]))
    story.append(P('13.1 Moving a program to another release', H2))
    story.append(code('''
echo %s > software/z88dk/myprog/cz88gfx.version
tools/z88dk/z88build.sh software/z88dk/myprog        (or zccbuild.sh)''' % VERSION))
    story.append(P(
        'The build puts that release on the include path and links its '
        'library; nothing needs mounting or copying. A program\'s '
        + C('.COM') + ' keeps the library code it was built with until it is '
        'rebuilt. A pin of ' + C('dev') + ' builds against the library\'s '
        'own ' + C('src/') + ' and ' + C('build/') + ', and warns if that '
        'build is older than its sources.'))
    story.append(P('13.2 Making a release', H2))
    story.append(P(
        'Raise ' + C('CZ88VER') + ' in ' + C('CZ88GFX.INC') + ' and '
        + C('CZ88GFX_VERSION') + ' in ' + C('cz88gfx.h') + ' together, '
        'rebuild the library (Appendix E), then run '
        + C('software/z88dk/cz88gfx/tools/release.sh') + '. It copies the library '
        'and both headers into ' + C('releases/<major>.<minor>/') + ', '
        'read-only, and refuses to overwrite an existing release, to release '
        'a library older than its sources, or to release when the two '
        'version numbers disagree. Add the new release to git.'))

    # ================================================== appendices
    story.append(PageBreak())
    story.append(P('Appendix A. Macro reference (assembly)', H1))
    story.append(P(
        'Every argument is required. The register form of each macro, for '
        'computed arguments, is in Appendix B.'))
    rows = [['Macro', 'Does']]
    for s, d in [
        ('GINIT mode', 'set up the board for CZM640, CZM800 or CZM1K; clear. '
         'Clobbers all'),
        ('GCLS c', 'clear the screen to c'),
        ('GCOLOR c', 'drawing color (CL1)'),
        ('GBCOL c', 'background color CL0'),
        ('GCCMP c', 'compare color for OMEQ/OMNE'),
        ('GPAL i,r,g,b', 'set a palette entry. Clobbers BC, E'),
        ('GWAIT', 'wait for the drawing to finish: A = status, Z = OK'),
        ('GABORT', 'abort: flush the FIFOs, clear CER'),
        ('GMOVE x,y  GRMOVE dx,dy', 'move the CP'),
        ('GLINE x,y  GRLINE dx,dy', 'line from the CP (end not drawn)'),
        ('GRECT x,y  GRRECT dx,dy', 'rectangle outline from the CP'),
        ('GFRECT x,y  GRFRCT dx,dy', 'filled rectangle from the CP'),
        ('GDOT x,y', 'one pixel'),
        ('GSEG x1,y1,x2,y2', 'a line'),
        ('GBOX x1,y1,x2,y2', 'a rectangle outline'),
        ('GFBOX x1,y1,x2,y2,c', 'a filled rectangle in color c'),
        ('GPLINE ((pts))  GPOLY ((pts))', 'polyline / polygon, points inline. '
         'Clobbers HL'),
        ('GPTS name,(pts)', 'define a point table'),
        ('GPLT tbl  GPLG tbl', 'polyline / polygon from a table. HL ends past '
         'it'),
        ('GCIRC x,y,r', 'circle'),
        ('GELLIP x,y,rx,ry', 'ellipse'),
        ('GARC xc,yc,xe,ye,dir  GRARC', 'circular arc from the CP. '
         'Clobbers HL'),
        ('GEARC rx,ry,xc,yc,xe,ye,dir  GREARC', 'elliptical arc from the CP. '
         'Clobbers HL'),
        ('GMODE m', 'the whole drawing mode'),
        ('GOPM op  GCMODE cm  GAMODE am', 'one field of the drawing mode'),
        ('GAREA x1,y1,x2,y2  GAFULL', 'the area / the whole screen'),
        ('GGETCP', 'read the CP: HL, DE. Clears ARD'),
        ('GRDOT x,y', 'read a pixel: A; C if off the screen'),
        ('GPAT name,(w...)  GTILE name,(c...)', 'define a pattern / color '
         'tile'),
        ('GLDPAT tbl,pra', 'load the pattern RAM from word pra. Clobbers HL'),
        ('GPSCAN x0,y0,x1,y1,zx,zy', 'pattern window and zoom. Clobbers HL'),
        ('GPPTR x,y', 'pattern pointer. Clobbers HL'),
        ('GPDEF', 'pattern RAM, window and pointer as after setup'),
        ('GLSTYL pat,zoom', 'line style'),
        ('GPTN x,y,w,h,dir', 'draw the pattern RAM'),
        ('GPAINT x,y,e', 'paint out to edge color e'),
        ('GFLOOD x,y,c', 'recolor the region of color c'),
        ('GCOPY x1,y1,x2,y2,xd,yd,t', 'copy a block. Clobbers HL'),
        ('GOVON  GOVOFF', 'show / hide the overlay'),
        ('GOVPAL r,g,b', 'overlay color. Clobbers BC, E'),
        ('GOVL  GFRAME', 'draw on the overlay / the frame'),
        ('GOVCLS', 'clear the overlay'),
        ('GFONT f', 'choose a font, CZF8 or CZF11. Clobbers HL'),
        ('GTPOS x,y', 'text pen'),
        ('GTATTR s,d,f', 'text scale, direction, flags (0 or TXOPAQ). '
         'Clobbers BC'),
        ('GTEXT "text"', 'draw inline text. Clobbers HL, B'),
        ('GTSTR  GTCHR c', 'draw B characters at HL / one character'),
        ('GTNL', 'new line')]:
        rows.append([C(s), d])
    story.append(table(rows, [3.3 * inch, 3.6 * inch]))

    story.append(PageBreak())
    story.append(P('Appendix B. Modules and routines', H1))
    story.append(P(
        'The routines behind the macros, by module, with each module\'s size '
        'in cz88gfx %s. Assembly calls them by name; a program links only '
        'the modules it uses, plus the ones those call.' % VERSION))
    rows = [['Module', 'Bytes', 'Routines and data']]
    for m, b, r in [
        ('CZCORE', 167, 'CZWREG (B = register, HL = value), CZPUTW (HL to the '
         'FIFO), CZWAIT, CZXY / CZXYM (A = opcode, HL, DE), CZCMD (A = '
         'opcode, with the mode), CZWPR (A = drawing register, HL), CZSEND '
         '(HL = table, BC = words), CZRTAB, CZLDW, CZABT; data CZDM'),
        ('CZINIT', 566, 'CZINIT (HL = descriptor), CZCLS (A), CZOCLS, CZPDEF; '
         'data CZM640 CZM800 CZM1K, CZXMAX, CZYMAX, CZMREG (the MODE '
         'register), CZDPB'),
        ('CZPAL', 129, 'CZPALD (default palette), CZPALS (A = index, B/C/E = '
         'R/G/B)'),
        ('CZDRAW', 66, 'CZCOL (A), CZMOVE, CZLINE, CZRECT, CZFRCT, CZDOT, '
         'CZRMOV, CZRLIN, CZRRCT, CZRFRC (HL = X, DE = Y)'),
        ('CZPOLY', 49, 'CZPLL, CZPLG (HL = point table)'),
        ('CZCURV', 192, 'CZCRCL (HL = r), CZELPS (HL = rx, DE = ry), CZARC '
         '(A = OPAARC/OPRARC/OPAEAR/OPREAR + DIRCW, HL = table)'),
        ('CZFILL', 51, 'CZPANT (A = edge), CZFLOD (A = region), CZGCPY (A = '
         'transform, +10H relative; HL = table Xs,Ys,DX,DY)'),
        ('CZPAT', 149, 'CZLPAT (A = word, HL = table), CZLSTY (HL = style, A = '
         'zoom), CZPTN (HL = size, A = direction), CZPSCN (HL = 6-byte table)'),
        ('CZMODE', 246, 'CZOPM, CZCMOD, CZAMOD (A), CZCOL0, CZCCMP (A), '
         'CZAMIN, CZAMAX (HL, DE), CZAFUL, CZGCP, CZRDOT'),
        ('CZOVL', 78, 'CZOVON, CZOVOF, CZOPAL (B/C/E = R/G/B), CZOVL, CZFRM'),
        ('CZTXT', 444, 'CZTFNT (HL = font), CZTSTR (HL = text, B = length); '
         'data CZTST'),
        ('CZTXL', 149, 'CZTPOS (HL, DE), CZTATR (A = scale, B = direction, '
         'C = flags), CZTCHR (A), CZTNL'),
        ('CZFNT8', 480, 'data CZF8, the 8x8 font'),
        ('CZFN11', 860, 'data CZF11, the 9x11 font')]:
        rows.append([C(m), str(b), esc(r)])
    story.append(table(rows, [0.9 * inch, 0.6 * inch, 5.4 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'A program that only sets up the screen and draws a line is 953 bytes '
        'of library (CZCORE, CZINIT, CZPAL and CZDRAW). The C bindings\' '
        'modules, ' + C('CZC*') + ', add 660 bytes in all, of which a program '
        'links only those it uses (Appendix C).'))

    story.append(PageBreak())
    story.append(P('Appendix C. C function reference', H1))
    story.append(P(
        'Every function in ' + C('cz88gfx.h') + ', with the macro or routine '
        'it stands for (whose description it shares), its calling convention '
        'and the stub module that defines it. This table is generated from '
        'the header and the stubs themselves.'))
    story.extend(bullets([
        '<b>fastcall</b>: one argument, passed in HL.',
        '<b>callee</b>: the arguments pushed left to right, popped by the '
        'function; no clean-up at the call site.',
        '<b>alias</b>: the library routine itself under a C name (a '
        + C('DEFC') + '), with no stub code at all.']))
    rows = [['Prototype', 'Assembly', 'Convention', 'Module']]
    for name, proto, conv, mod, alias in funcs:
        rows.append([C(proto), C(MACRO_OF.get(name, '')),
                     conv + (', alias' if alias else ''), C(mod)])
    story.append(table(rows, [3.65 * inch, 1.1 * inch, 1.15 * inch,
                              1.0 * inch], style=ParagraphStyle(
                                  'cellsm', parent=CELL, fontSize=8,
                                  leading=10)))
    story.append(Spacer(1, 6))
    story.append(P('Data, and the macros the header defines:'))
    rows = [['Declaration', 'What it is']]
    for decl, mod in data:
        what = ''
        if 'cz_m640' in decl:
            what = 'the mode descriptors; ' + C('CZ_M640') + ', '
            what += C('CZ_M800') + ', ' + C('CZ_M1K') + ' name them'
        elif 'cz_xmax' in decl:
            what = 'the current mode\'s largest x and y (read only)'
        elif 'cz_f8' in decl:
            what = 'the fonts; ' + C('CZ_F8') + ', ' + C('CZ_F11') + ' name '
            what += 'them, and naming one links it in'
        rows.append([C(decl), what])
    rows.append([C('cz_earc(rx, ry, xc, yc, xe, ye, dir)') + '<br/>'
                 + C('cz_rearc(...)'), 'macros: ' + C('cz_earc_sq') + ' / '
                 + C('cz_rearc_sq') + ' with rx, ry squared'])
    rows.append([C('CZ_TILE(c)'), 'a color tile word: c in both bytes'])
    story.append(table(rows, [3.9 * inch, 3.0 * inch]))
    story.append(P(
        'C equivalents of the register forms: ' + C('cz_circle_cp') + ', '
        + C('cz_ellipse_cp') + ', ' + C('cz_paint_cp') + ', '
        + C('cz_flood_cp') + ' and ' + C('cz_ptn_cp') + ' work at the CP. '
        + C('cz_putw') + ', ' + C('cz_cmd') + ', ' + C('cz_wpr') + ' and '
        + C('cz_wreg') + ' send to the ACRTC directly, for the commands the '
        'library has no call for (Appendix G).', NOTE))

    story.append(PageBreak())
    story.append(P('Appendix D. Equates and constants', H1))
    story.append(P('Besides the macros and functions, the headers define:'))
    rows = [['Group', 'Assembly (CZ88GFX.INC)', 'C (cz88gfx.h, cadzilla.h)']]
    for g, a, c in [
        ('Ports', 'CZBASE (70H), ACRSR, MODEREG, ACRDAT, DACADR, DACPAL, '
         'DACOVL', 'CZ_BASE, CZ_ACRTC_SR / _AR, CZ_MODE, CZ_ACRTC_DATA, '
         'CZ_DAC_ADDR, CZ_DAC_PAL, CZ_DAC_OVL; CZ_PORT_... numbers'),
        ('Status bits', 'SRWFE 01H, SRWFR 02H, SRRFR 04H, SRCED 20H, SRARD '
         '40H, SRCER 80H', 'CZ_SR_WFE ... CZ_SR_CER (also RFF, LPD)'),
        ('MODE bits', 'MDOLEN 08H, MDOLSL 10H', 'CZ_MODE_HSPOL, VSPOL, AMODE, '
         'OLEN, OLSEL'),
        ('Hues', 'ORANGE BLUE GREEN CYAN RED MAGENTA YELLOW WHITE (0-224); '
         'BRIGHT 31', 'CZ_ORANGE ... CZ_WHITE; CZ_BRIGHT'),
        ('Operation modes', 'OMREP OMOR OMAND OMEOR OMEQ OMNE OMLT OMGT (0-7)',
         'CZ_OM_REP ... CZ_OM_GT'),
        ('Color modes', 'CMSEL 00H, CMCL1 08H, CMCL0 10H, CMPRAM 18H',
         'CZ_CM_SEL, _CL1, _CL0, _PRAM'),
        ('Area modes', 'AMNONE 00H, AMSTOP 20H, AMCLIP 40H, AMCLPD 60H, '
         'AMSTPI 0A0H, AMHOLE 0C0H, AMHOLD 0E0H',
         'CZ_AM_NONE, _STOP, _CLIP, _CLPD, _STPI, _HOLE, _HOLD'),
        ('Copy transforms', 'CPNORM CPMIRY CPMIRX CPR180 CPTRAN CPR270 CPR90 '
         'CPATRN (0-7)', 'CZ_CP_NORM ... CZ_CP_ATRN'),
        ('Directions', 'DIRCCW 0, DIRCW 1; PTSLNT 8',
         'CZ_DIR_CCW, CZ_DIR_CW; CZ_PTSLNT'),
        ('Overlay, text', 'OVSET 0FFH, OVCLR 0; TXOPAQ 1',
         'CZ_OVSET, CZ_OVCLR; CZ_TXOPAQ'),
        ('Mode descriptors, fonts', 'CZM640 CZM800 CZM1K; CZF8 CZF11',
         'CZ_M640 CZ_M800 CZ_M1K; CZ_F8 CZ_F11'),
        ('Opcodes', 'OPMOVE OPRMOV OPLINE OPRLIN OPRECT OPRRCT OPAPLL OPAPLG '
         'OPCRCL OPELPS OPAARC OPRARC OPAEAR OPREAR OPFRCT OPRFRC OPPANT OPDOT '
         'OPPTN OPAGCP OPRGCP OPRD (command high bytes); CMDDOT', '(none: use '
         'the values with cz_cmd)'),
        ('Version', 'CZ88VER (0101H for 1.1)', 'CZ88GFX_VERSION (0x0101)')]:
        rows.append([g, C(a), C(c)])
    story.append(table(rows, [1.2 * inch, 2.85 * inch, 2.85 * inch]))

    story.append(PageBreak())
    story.append(P('Appendix E. Building and extending the library', H1))
    story.append(P('Everything runs on the host:'))
    story.append(code('''
software/z88dk/cz88gfx/tools/build.sh'''))
    story.extend(bullets([
        'It assembles every module in ' + C('src/') + ' (8080 code, '
        + C('-m8080') + ') into ' + C('build/CZ88GFX.LIB') + ', with '
        'listings, and lints the sources for ' + C('JP') + '/' + C('CP') + '.',
        'It links ' + C('CZ88CHK.Z88') + ' against the new library for the '
        '8080, 8085 and Z80. CZ88CHK expands every macro, references every '
        'entry point and makes every register-form call.',
        'It compiles ' + C('czcchk.c') + ' with zcc for each CPU\'s C library '
        'and links it against the new library. It calls every C function and '
        'names every constant.',
        'So a broken macro, a wrong prototype or a missing PUBLIC fails the '
        'library build, not the first program. The build is good when it '
        'ends with six ' + C('check: ... links') + ' lines and the library '
        'size.']))
    story.append(P('E.1 Adding to the library', H2))
    story.extend(bullets([
        '<b>A routine:</b> make it PUBLIC in its module, add it to the '
        'header\'s EXTERN block, add a macro if it helps, and exercise it in '
        + C('CZ88CHK.Z88') + '.',
        '<b>Its C function:</b> a stub in the matching ' + C('CZC*.Z88') +
        ' module, or a ' + C('DEFC') + ' alias when the routine needs nothing '
        'but HL; its prototype in ' + C('cz88gfx.h') + '; a call in '
        + C('czcchk.c') + '.',
        '<b>A module:</b> create ' + C('src/CZxxxx.Z88') + ' (INCLUDE '
        '"CZ88GFX.INC", ' + C('SECTION code_user') + ', its PUBLICs) and add '
        'its names to the header\'s EXTERN block; give it C bindings in a '
        'new ' + C('src/CZCxxxx.Z88') + ' of its own, so a C program that '
        'doesn\'t use it doesn\'t link it. ' + C('build.sh') + ' picks up '
        'every module; z80asm has no module order to keep.',
        '<b>A font:</b> draw its glyphs in ' + C('tools/mkfont.py') + ', '
        'which writes the font modules.',
        'Try a change in a program pinned to ' + C('dev') + ' (z88demo, or '
        'cgfxdemo for C), checking the pictures as well as the build, then '
        'release it (chapter 13).']))
    story.append(P('E.2 How the C stubs work', H2))
    story.extend(bullets([
        'A one-argument (fastcall) stub moves the argument from HL to where '
        'the routine wants it, e.g. ' + C('MOV A,L') + ' / '
        + C('JMP CZCOL') + '.',
        'A stub whose arguments fit the registers pops them straight in: the '
        'return address, then the arguments last first, then the return '
        'address back, and a jump to the routine (7-11 bytes).',
        'A longer call uses ' + C('CZCPOP') + ' (module ' + C('CZCARG') + '), '
        'which moves C argument words into the static block ' + C('CZCAV') +
        ' in their declared order: often the very parameter table the '
        'routine takes, as for the arcs and the copy. Like the library\'s own '
        'state, this makes the library non-reentrant: don\'t draw from an '
        'interrupt handler.',
        'The stubs are 8080 code and in ' + C('SECTION code_user') + ', the '
        'section zcc\'s CP/M startup places with the program. They use only '
        'AF, BC, DE and HL, which sccz80 lets a function change.']))

    story.append(P('Appendix F. Porting from czgfx', H1))
    story.append(P(
        'An M80 program for czgfx ports to cz88gfx\'s assembly side line for '
        'line (z88demo is gfxdemo ported this way); for C, see Appendix C.'))
    rows = [['czgfx (M80)', 'cz88gfx (z80asm)']]
    for a, b in [
        ('INCLUDE B:CZGFX.INC / CSEG / END START',
         'INCLUDE "CZ88GFX.INC" / ORG 0100H / (no END)'),
        ('CALL CZLDW##, LHLD CZXMAX##', 'CALL CZLDW, LHLD CZXMAX'),
        ('GINIT', 'GINIT CZM640 (always name the mode)'),
        ('GCLS, GMODE', 'GCLS 0, GMODE 0'),
        ('GCOLOR (A set), and the like', 'CALL CZCOL, CZCOL0, CZCCMP, CZOPM, '
         'CZCMOD, CZAMOD, CZTCHR'),
        ('GMOVE (HL, DE set), and the like', 'CALL CZMOVE, CZLINE, CZRECT, '
         'CZFRCT, CZDOT, CZRDOT, CZTPOS'),
        ('GMOVE ,420', 'LXI D,420 / CALL CZMOVE'),
        ('GCIRC  /  GCIRC ,,7', 'CALL CZCRCL  /  LXI H,7 / CALL CZCRCL'),
        ('GTATTR 2  /  GTATTR 1,2', 'GTATTR 2,0,0  /  GTATTR 1,2,0'),
        ('GLDPAT t / GLSTYL p / GPTN x,y,w,h', 'GLDPAT t,0 / GLSTYL p,0 / '
         'GPTN x,y,w,h,0'),
        ('GPSCAN x0,y0,x1,y1', 'GPSCAN x0,y0,x1,y1,0,0'),
        ('GARC xc,yc,xe,ye', 'GARC xc,yc,xe,ye,DIRCCW'),
        ('GCOPY x1,y1,x2,y2,xd,yd', 'GCOPY x1,y1,x2,y2,xd,yd,CPNORM'),
        ('GPOLY <x0,y0,...>', 'GPOLY ((x0,y0,...))'),
        ('GPTS n,<...>', 'GPTS n,(...)'),
        ('GTEXT <\'text\'>', 'GTEXT "text"'),
        ('GCOLOR <(N MOD 8)*32>', 'GCOLOR 0+(N % 8)*32'),
        ('N SET N+1', 'N DEFL (N+1)'),
        ('IRP V,<a,b> ... ENDM  /  REPT n ... ENDM',
         'REPTI V,a,b ... ENDR  /  REPT n ... ENDR'),
        ('DB \'text\',CR,LF,\'$\'', 'DB "text",CR,LF,\'$\'')]:
        rows.append([C(a), C(b)])
    story.append(table(rows, [3.45 * inch, 3.45 * inch]))

    story.append(P('Appendix G. Limits', H1))
    story.extend(bullets([
        'No calls for the ACRTC\'s word-address block commands (CPY, SCPY, '
        'DRD, DWT, DMOD), WT and MOD, or the read-backs other than the CP and '
        'a pixel. The copy covers copying on the screen. For the rest, send '
        'the command yourself: ' + C('CZCMD') + ' and ' + C('CZPUTW') + ' in '
        'assembly, ' + C('cz_cmd') + ' and ' + C('cz_putw') + ' in C.',
        'PAINT\'s four-seed limit on the real chip (9.1).',
        'It is 8080 code everywhere: a Z80 program runs the same code an 8080 '
        'one does.',
        'The C bindings are for sccz80, the compiler ' + C('zccbuild.sh') +
        ' uses; zcc\'s ' + C('-compiler=sdcc') + ' (Z80 only) is untested '
        'with them.',
        'The library is assembled for I/O base 70H; ' + C('-DCZ_BASE') + ' '
        'moves only ' + C('<cadzilla.h>') + '\'s ports.',
        'Only the overlay\'s lower half (' + C('MDOLSL') + ' = 0) is used, '
        'since the screen starts at frame word 0.',
        'Switching the ACRTC\'s pixel depth while the display runs (the '
        'overlay switches) is fine in altairsim, but has not yet been checked '
        'on the real board.']))
    return story


def _ptr_table():
    """Chapter 5's table of the CP calls, the two forms on separate lines."""
    def two(a, b):
        return C(a) + '<br/>' + C(b)
    return table([
        ['Assembly', 'C', 'Draws', 'CP afterwards'],
        [two('GMOVE x,y', 'GRMOVE dx,dy'), two('cz_move(x, y)',
                                               'cz_rmove(dx, dy)'),
         'nothing: moves the CP', 'x,y'],
        [two('GLINE x,y', 'GRLINE dx,dy'), two('cz_line(x, y)',
                                               'cz_rline(dx, dy)'),
         'a line from the CP, its end point <b>not</b> drawn', 'x,y'],
        [two('GRECT x,y', 'GRRECT dx,dy'), two('cz_rect(x, y)',
                                               'cz_rrect(dx, dy)'),
         'a rectangle outline, corners CP and x,y', 'unchanged'],
        [two('GFRECT x,y', 'GRFRCT dx,dy'), two('cz_frect(x, y)',
                                                'cz_rfrect(dx, dy)'),
         'a filled rectangle, both corners included',
         'one row past the far edge'],
        [C('GDOT x,y'), C('cz_dot(x, y)'), 'one pixel', 'x,y']],
        [1.3 * inch, 1.6 * inch, 2.5 * inch, 1.5 * inch])


def main():
    doc = Doc(OUT, pagesize=letter, title=TITLE, author='CADzilla Project',
              subject='cz88gfx graphics library %s' % VERSION,
              leftMargin=0.8 * inch, rightMargin=0.8 * inch,
              topMargin=0.85 * inch, bottomMargin=0.85 * inch)
    doc.multiBuild(build(), onFirstPage=on_cover, onLaterPages=on_page)
    print(OUT)


if __name__ == '__main__':
    main()
