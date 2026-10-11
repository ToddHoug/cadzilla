#!/usr/bin/env python3
"""Generate docs/czgfx-guide.pdf: the czgfx graphics library user guide.

The palette chart is computed from czgfx's CZPAL tables, the font charts from
this directory's mkfont.py, and the screenshots are gfxdemo's own screens
(docs/images/czgfx/gfxdemo-NN.png), so all of them match what the board
draws. To refresh the screenshots after a library change: run gfxdemo on its
altairsim machine, take a `snapshot` at each screen, and render each with
    tools/altairsim/scripts/cadzilla_png.py <snapshot> docs/images/czgfx/gfxdemo-NN.png

Usage (from the repository root):
    python3 software/m80/czgfx/tools/mkguide.py
Needs ReportLab (the other manuals in docs/ are made the same way).
"""
import datetime
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
REPO = os.path.normpath(os.path.join(HERE, '..', '..', '..', '..'))
OUT = os.path.join(REPO, 'docs', 'czgfx-guide.pdf')
COVER = os.path.join(REPO, 'docs', 'images', 'cadzilla.png')
SHOTS = os.path.join(REPO, 'docs', 'images', 'czgfx')
INC = os.path.join(REPO, 'software', 'm80', 'czgfx', 'src', 'CZGFX.INC')
TITLE = 'czgfx Graphics Library User Guide'
REVISION = '1.0'
DATE = datetime.date.today().isoformat()


def library_version():
    """The version in CZGFX.INC (CZVERS EQU 0MMNNH) as 'MM.NN'."""
    with open(INC, encoding='latin-1') as f:
        m = re.search(r'^CZVERS\s+EQU\s+0?([0-9A-Fa-f]+)H', f.read(), re.M)
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


def ctable(rows, widths, header=True):
    """A table whose first column is code."""
    out = []
    for i, r in enumerate(rows):
        if header and i == 0:
            out.append(r)
        else:
            out.append([C(r[0])] + list(r[1:]))
    return table(out, widths, header)


def shot(n, caption, width=5.0 * inch):
    path = os.path.join(SHOTS, 'gfxdemo-%02d.png' % n)
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
                         'czgfx %s' % VERSION)
    canv.line(0.75 * inch, h - 0.6 * inch, w - 0.75 * inch, h - 0.6 * inch)
    canv.line(0.75 * inch, 0.6 * inch, w - 0.75 * inch, 0.6 * inch)
    canv.drawString(0.75 * inch, 0.45 * inch, 'CADzilla')
    canv.drawRightString(w - 0.75 * inch, 0.45 * inch, 'Page %d' % doc.page)
    canv.restoreState()


def on_cover(canv, doc):
    pass


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
    d.add(String(x0 + sw + 4, y0 + sh + 6, 'CZXMAX,CZYMAX',
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
    """The default palette entry, as czgfx's CZPALD loads it."""
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
    """An F, and where GCOPY's eight transforms put it."""
    F = ['#####', '#....', '####.', '#....', '#....']   # top first
    pts = [(x, 4 - y) for y, row in enumerate(F) for x, c in enumerate(row)
           if c == '#']                                   # bottom-left origin
    maps = [('CPNORM', lambda i, j: (i, j)), ('CPMIRX', lambda i, j: (-i, j)),
            ('CPMIRY', lambda i, j: (i, -j)), ('CPR180', lambda i, j: (-i, -j)),
            ('CPTRAN', lambda i, j: (j, i)), ('CPR270', lambda i, j: (j, -i)),
            ('CPR90', lambda i, j: (-j, i)), ('CPATRN', lambda i, j: (-j, -i))]
    px, cellw, cellh = 6, 84, 92
    d = Drawing(4 * cellw, 2 * cellh)
    for k, (name, f) in enumerate(maps):
        cx0 = (k % 4) * cellw
        cy0 = (1 - k // 4) * cellh
        d.add(Rect(cx0 + 4, cy0 + 16, cellw - 8, cellh - 20,
                   fillColor=colors.HexColor('#f6f6f6'),
                   strokeColor=colors.HexColor('#d0d0d0'), strokeWidth=0.4))
        tp = [f(i, j) for (i, j) in pts]
        xs, ys = [p_[0] for p_ in tp], [p_[1] for p_ in tp]
        ox = cx0 + cellw / 2 - (min(xs) + max(xs) + 1) * px / 2
        oy = cy0 + 16 + (cellh - 20) / 2 - (min(ys) + max(ys) + 1) * px / 2
        for (x, y) in tp:
            d.add(Rect(ox + x * px, oy + y * px, px - 0.6, px - 0.6,
                       fillColor=DARK, strokeColor=None))
        d.add(Circle(ox + px / 2, oy + px / 2, 2.2,
                     fillColor=colors.HexColor('#d04040'), strokeWidth=0))
        d.add(String(cx0 + cellw / 2, cy0 + 4, name, fontName='Courier-Bold',
                     fontSize=8.5, textAnchor='middle'))
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
    story = []
    ctr = dict(alignment=TA_CENTER)

    # ---- cover
    story.append(Spacer(1, 0.9 * inch))
    if os.path.exists(COVER):
        img = Image(COVER, width=2.6 * inch, height=2.6 * inch)
        img.hAlign = 'CENTER'
        story.append(img)
    story.append(Spacer(1, 0.35 * inch))
    story.append(P('czgfx', ParagraphStyle('ct', parent=H1, fontSize=30,
                                            leading=36, **ctr)))
    story.append(P('Graphics Library User Guide',
                   ParagraphStyle('cs', parent=H2, fontSize=15,
                                  textColor=colors.HexColor('#444444'),
                                  **ctr)))
    story.append(Spacer(1, 0.25 * inch))
    story.append(P(
        'The 8080 graphics library for the CADzilla S-100 graphics board '
        '(Hitachi HD63484 ACRTC and Brooktree Bt453 RAMDAC), for programs '
        'written with Microsoft M80/L80 under CP/M 2.2',
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
        'czgfx is the graphics library for CADzilla programs written in 8080 '
        'assembly with Microsoft MACRO-80 (M80) and LINK-80 (L80) under '
        'CP/M. It sets up the board and gives a program the whole of the '
        'ACRTC\'s drawing processor through short macros: lines, '
        'rectangles, polygons, circles, ellipses and arcs, area fills and '
        'copies, the pattern RAM, the operation, color and area modes, a '
        'one-bit overlay plane and text in two fonts.'))
    story.append(P(
        'This guide is for programmers using the library. It explains the '
        'board\'s model as far as a program needs it, then each group of '
        'calls, with the screens of the <b>gfxdemo</b> program '
        '(' + C('software/m80/gfxdemo') + ') as worked examples. The appendices '
        'list every macro, routine and equate, and explain how the library '
        'itself is built and extended.'))

    story.append(P('1.1 What czgfx is', H2))
    story.append(P('czgfx comes in two parts:'))
    story.extend(bullets([
        C('CZGFX.INC') + ', the header a program INCLUDEs: the board\'s '
        'equates and the ' + C('G...') + ' macros.',
        C('CZGFX.REL') + ', a LIB80 library of fourteen relocatable '
        'modules. L80\'s library search links in only the modules a program '
        'uses, so a program that draws only boxes gets no curve, text or '
        'font code (Appendix B lists the modules and their sizes).']))
    story.append(P(
        'Both, with the link script ' + C('CZLINK.SUB') + ', are on the '
        'library disk, which a program mounts as CP/M drive ' + C('B:') +
        '. Each project keeps its own copy of a numbered release of that '
        'disk, so a new czgfx version reaches a program only when the '
        'program chooses to move to it (chapter 13).'))

    story.append(P('1.2 The board, in brief', H2))
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
    story.append(ctable([
        ['Port', 'Name', 'Use'],
        ['70H', C('ACRSR'), 'ACRTC address register (out) / status (in)'],
        ['71H', C('MODEREG'), 'the board\'s MODE register: sync polarity, '
         'access mode, overlay enable and select (write-only)'],
        ['72H', C('ACRDAT'), 'ACRTC control register data / the command FIFO'],
        ['74H', C('DACADR'), 'Bt453 address register'],
        ['75H', C('DACPAL'), 'Bt453 palette RAM (R, G, B)'],
        ['77H', C('DACOVL'), 'Bt453 overlay colors (R, G, B)']],
        [0.7 * inch, 1.0 * inch, 5.2 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'czgfx programs the board for 8 bits a pixel, one screen, at '
        '640x480, 800x600 or 1024x768. A program never needs the ports '
        'itself, but the names are in the header if it does.'))

    story.append(P('1.3 About this guide', H2))
    story.append(P(
        'It describes czgfx %s. Macro and routine names, equates, CP/M '
        'commands and source are set in ' % VERSION + C('Courier') + '. '
        '"CP" is the ACRTC\'s current drawing pointer. Paths are relative to '
        'the CADzilla repository. The library\'s own reference, kept with '
        'the sources, is ' + C('software/m80/czgfx/README.md') + '.'))

    # ================================================== 2. getting started
    story.append(CondPageBreak(4 * inch))
    story.append(P('2. Getting started', H1))
    story.append(P('2.1 A project that uses czgfx', H2))
    story.append(P(
        'CADzilla programs are built and run under CP/M 2.2 on the altairsim '
        'emulator (or on the real board), each project with its own machine '
        'and disks in its ' + C('work/') + ' directory. A new M80 project is '
        'scaffolded with:'))
    story.append(code('''
.claude/skills/new-cadzilla-project/scripts/new_project.sh myprog \\
        --toolchain m80 --mode 1024x768'''))
    story.append(P('That creates, under ' + C('software/m80/myprog/') + ':'))
    story.append(table([
        ['File', 'What it is'],
        [C('src/MYPROG.MAC'), 'a starter program that draws a frame and a box'],
        [C('machine.toml'), 'the monitor resolution the project is strapped '
         'for (tracked)'],
        [C('czgfx.version'), 'the czgfx release the project builds against, '
         'e.g. ' + C('1.0') + ' (tracked)'],
        [C('work/'), 'its altairsim machine: ' + C('CPM22SYS.DSK') + ' as '
         + C('A:') + ', and its own copy of the pinned library, '
         + C('CZGFXLIB-1.0.DSK') + ', as ' + C('B:') + ', read-only'
         ' (gitignored)']],
        [1.6 * inch, 5.3 * inch]))

    story.append(P('2.2 A first program', H2))
    story.append(P('A complete program: it sets up the board, draws a frame '
                   'round the screen and a blue box in the middle, and waits '
                   'for the drawing to finish.'))
    story.append(code('''
        INCLUDE B:CZGFX.INC     ;equates and macros
;
        CSEG                    ;relocatable -- no ORG
START:  GINIT   CZM1K           ;1024x768, default palette, screen cleared
        GCOLOR  WHITE+BRIGHT
        GBOX    0,0,1023,767    ;a frame round the screen
        GFBOX   448,320,576,448,BLUE+BRIGHT
        GWAIT                   ;Z = drawn cleanly, NZ = command error
        RET                     ;back to CP/M
;
        END     START'''))
    story.append(P('It is assembled with M80 and linked against the library '
                   'with the link script on ' + C('B:') + ':'))
    story.append(code('''
A0>M80 MYPROG,MYPROG=MYPROG
No Fatal error(s)
A0>SUBMIT B:CZLINK MYPROG
A0>L80 MYPROG,B:CZGFX/S,MYPROG/N/E
Link-80  3.44  09-Dec-81  Copyright (c) 1981 Microsoft
...
A0>MYPROG'''))
    story.append(P(
        C('CZLINK.SUB') + ' is ' + C('L80 $1,B:CZGFX/S,$1/N$2/E') + ': '
        'the program, then a search of the library (' + C('/S') + '), '
        'writing ' + C('MYPROG.COM') + '. A second argument is passed to '
        'L80 as an extra switch: ' + C('SUBMIT B:CZLINK MYPROG /M') + ' '
        'prints the link map, which shows which library modules were loaded. '
        'After a map L80 waits at its ' + C('*') + ' prompt; type '
        + C('/E') + ' to finish.'))
    story.append(P(
        'A program of several modules assembles each with M80 and links '
        'them all before the library: '
        + C('L80 MAIN,PART2,B:CZGFX/S,MAIN/N/E') + '.'))

    # ================================================== 3. conventions
    story.append(P('3. Conventions', H1))
    story.append(P('3.1 Coordinates', H2))
    story.append(P(
        'GINIT puts the drawing origin at the <b>bottom-left</b> pixel. X runs '
        'from 0 to ' + C('CZXMAX') + ' left to right, Y from 0 to '
        + C('CZYMAX') + ' bottom to top. ' + C('CZXMAX') + ' and '
        + C('CZYMAX') + ' are words in the library that GINIT sets for the '
        'mode (1023 and 767 at 1024x768); read them as '
        + C('LHLD CZXMAX##') + '.'))
    story.append(figure(fig_coords(), 'Figure 1. Screen coordinates.'))

    story.append(P('3.2 Registers and arguments', H2))
    story.extend(bullets([
        'X goes in HL, Y in DE, a color (palette index) in A.',
        'Every routine preserves BC, DE and HL unless its entry says '
        'otherwise, and clobbers A and the flags. A few macros clobber '
        'registers of their own; Appendix A says which.',
        'A macro argument left <b>blank</b> means "already in the register": '
        + C('GLINE ,100') + ' draws to X = HL, Y = 100, and ' + C('GCOLOR')
        + ' alone takes the color in A. That is how computed values go '
        'through the macros.',
        'The exception: for a shape drawn round a point (' + C('GCIRC') + ', '
        + C('GELLIP') + ', ' + C('GPAINT') + ', ' + C('GFLOOD') + ', '
        + C('GPTN') + ') leaving both x and y blank means "at the CP", with '
        'no move. ' + C('GCIRC') + ' alone is a circle round the CP, radius '
        'in HL.',
        'An argument with spaces or commas in it goes in angle brackets: '
        + C('GCOLOR <(N MOD 8)*32+BRIGHT>') + ', '
        + C('GPOLY <100,100,150,100,125,140>') + '.']))

    story.append(P('3.3 Names', H2))
    story.extend(bullets([
        'Library routines and data outside the macros are written '
        + C('NAME##') + ', M80\'s inline external: ' + C('CALL CZLDW##') +
        ', ' + C('LHLD CZXMAX##') + '. Don\'t ' + C('EXTRN') + ' library '
        'names you don\'t use: M80 turns every ' + C('EXTRN') + ' into a link '
        'request, and L80 then loads that module whether anything calls it '
        'or not.',
        'Global names are significant to 6 characters (L80 keeps only the '
        'first 6). Every czgfx global is ' + C('CZ') + ' and up to four more; '
        'don\'t define ' + C('CZ...') + ' names of your own.',
        'The header also defines, without a prefix, the hue constants '
        '(' + C('ORANGE BLUE GREEN CYAN RED MAGENTA YELLOW WHITE') + ' and '
        + C('BRIGHT') + '), the opcodes ' + C('OP...') + ', the mode values '
        + C('OM...') + ', ' + C('CM...') + ' and ' + C('AM...') + ', the '
        'copy transforms ' + C('CP...') + ', the port names, the status '
        'bits ' + C('SR...') + ' and a few more (Appendix C). Don\'t reuse '
        'them in a program.',
        'The library never calls the BDOS: console I/O is the program\'s.']))

    story.append(P('3.4 Waiting, and errors', H2))
    story.append(P(
        'Drawing macros only send commands; the ACRTC draws them from its '
        'FIFO. ' + C('GWAIT') + ' waits until the FIFO is empty and the last '
        'command has ended, and returns the status register in A: <b>Z</b> '
        'if the drawing ended cleanly, <b>NZ</b> on a command error (CER, '
        'status bit 7: an undefined command or a bad parameter). A program '
        'normally ends each picture with ' + C('GWAIT') + '. '
        + C('GABORT') + ' stops the chip, flushes the FIFOs and clears CER. '
        'On the real board, and in altairsim with ' + C('draw_rate = "real"')
        + ', drawing takes time, and ' + C('GWAIT') + ' is also how a '
        'program knows it has finished.'))

    # ================================================== 4. display setup
    story.append(CondPageBreak(4 * inch))
    story.append(P('4. Setting up the display', H1))
    story.append(P('4.1 GINIT and the display modes', H2))
    story.append(P(
        C('GINIT mode') + ' sets up the whole board for one display mode: '
        'the MODE register, the ACRTC\'s timing and display registers, the '
        'default palette, the drawing parameters, the overlay, and a clear '
        'screen. The mode is a descriptor in the library:'))
    story.append(ctable([
        ['Descriptor', 'Mode', 'Screen'],
        ['CZM640', 'VESA 640x480 @ 60 Hz', 'X 0-639, Y 0-479'],
        ['CZM800', 'VESA 800x600 @ 60 Hz', 'X 0-799, Y 0-599'],
        ['CZM1K', 'VESA 1024x768 @ 60 Hz', 'X 0-1023, Y 0-767']],
        [1.4 * inch, 2.4 * inch, 3.1 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'The monitor is fixed-frequency, chosen by a strap (in altairsim, '
        'cad0\'s ' + C('mode') + ' in the project\'s ' + C('machine.toml') +
        '; 1024x768 by default). The descriptor must match it: the board '
        'doesn\'t reject a mismatch, the picture just lands in the wrong '
        'place in the monitor\'s frame. Always name the descriptor: '
        + C('GINIT') + ' with no argument means ' + C('CZM640') + '. '
        + C('GINIT') + ' clobbers all registers.'))
    story.append(P(
        'After ' + C('GINIT') + ': the screen is color 0; the drawing color '
        '(CL1) is 255, white; CL0 and CCMP are 0; the drawing mode is replace '
        'with no area checking; the pattern RAM is all ones; the area is the '
        'whole screen; the overlay is clear, hidden and white; and drawing '
        'goes to the frame.'))
    story.append(P('4.2 Clearing', H2))
    story.append(P(
        C('GCLS [c]') + ' clears the whole screen to color c (default 0) '
        'with the ACRTC\'s block clear, the fastest way to fill the screen. '
        + C('GOVCLS') + ' clears the overlay (chapter 10).'))
    story.append(P('4.3 Colors and the palette', H2))
    story.append(P(
        'A pixel is a palette index, 0-255. ' + C('GCOLOR c') + ' sets the '
        'drawing color. GINIT loads a default palette of eight hues with 32 '
        'brightness levels each: <b>index = hue + level</b>, where the hue '
        'is one of the constants below and the level runs from 0 (black) to '
        + C('BRIGHT') + ' (31). ' + C('GCOLOR CYAN+BRIGHT') + ' is full '
        'cyan; ' + C('GCOLOR RED+16') + ' a half-bright red.'))
    story.append(figure(fig_palette(),
                        'Figure 2. The default palette, as GINIT loads it.'))
    story.append(P(
        C('GPAL i,r,g,b') + ' sets palette entry i to any color (0-255 each '
        'component, clobbers BC and E). Changing an entry recolors '
        'everything already drawn in it at once, which makes palette '
        'animation cheap. ' + C('CALL CZPALD##') + ' loads the default '
        'palette again.'))
    story.append(shot(1, 'gfxdemo screen 1: all 256 entries of the default '
                         'palette as filled boxes (GFBOX), in a white frame '
                         '(GBOX).'))

    # ================================================== 5. drawing
    story.append(CondPageBreak(4 * inch))
    story.append(P('5. Lines, rectangles and polygons', H1))
    story.append(P('5.1 The drawing pointer', H2))
    story.append(P(
        'The ACRTC draws from its current drawing pointer, the CP. '
        + C('GMOVE x,y') + ' moves it; the drawing macros draw from it and '
        'most leave it at their end point. Each comes in an absolute form, '
        'to x,y, and a relative one, by dx,dy from the CP:'))
    story.append(ctable([
        ['Absolute', 'Relative', 'Draws', 'CP afterwards'],
        ['GMOVE x,y', 'GRMOVE dx,dy', 'nothing: moves the CP', 'x,y'],
        ['GLINE x,y', 'GRLINE dx,dy', 'a line from the CP, its end point '
         '<b>not</b> drawn', 'x,y'],
        ['GRECT x,y', 'GRRECT dx,dy', 'a rectangle outline, corners CP and '
         'x,y', 'unchanged'],
        ['GFRECT x,y', 'GRFRCT dx,dy', 'a filled rectangle, both corners '
         'included', 'one row past the far edge'],
        ['GDOT x,y', '', 'one pixel', 'x,y']],
        [1.1 * inch, 1.25 * inch, 2.9 * inch, 1.65 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'Because a line\'s end point isn\'t drawn, a closed shape drawn from '
        'lines lights each corner exactly once, which matters when drawing '
        'in EOR mode. Three macros combine a move with a drawing:'))
    story.append(ctable([
        ['Macro', 'Does'],
        ['GSEG x1,y1,x2,y2', 'a line from x1,y1 to x2,y2 (x2,y2 not drawn)'],
        ['GBOX x1,y1,x2,y2', 'a rectangle outline with corners x1,y1 and '
         'x2,y2'],
        ['GFBOX x1,y1,x2,y2[,c]', 'a filled rectangle, in color c if given']],
        [2.2 * inch, 4.7 * inch]))
    story.append(P('5.2 Polylines and polygons', H2))
    story.append(P(
        'A polyline is drawn through a list of points, a polygon is closed '
        'back to its first point. The points can be inline, or in a named '
        'table built once in the data:'))
    story.append(code('''
        GPOLY   <240,704,202,595,88,594,179,525,146,414>   ;inline
        GPLG    TRI                                        ;from a table
        ...
        GPTS    TRI,<480,448,576,704,400,640>              ;the table'''))
    story.append(P(
        C('GPLINE') + ' and ' + C('GPOLY') + ' place their points inline (and '
        'jump over them); ' + C('GPLT tbl') + ' and ' + C('GPLG tbl') + ' '
        'draw from a table. A table is ' + C('DW n') + ' followed by n X,Y '
        'pairs; ' + C('GPTS') + ' builds one. A list too long for one source '
        'line can be written out with ' + C('DW') + ' by hand in the same '
        'layout. At least 2 points; these macros clobber HL.'))
    story.append(shot(2, 'gfxdemo screen 2: a 36-spoke starburst from a data '
                         'table (GMOVE, GLINE), and nested rectangles unrolled '
                         'at assembly time with REPT (GBOX).'))
    story.append(shot(3, 'gfxdemo screen 3: a star and a hexagon (GPOLY), a '
                         'triangle from a table (GPTS, GPLG), a sine wave '
                         '(GPLT) and 400 random dots (GDOT).'))

    # ================================================== 6. curves
    story.append(CondPageBreak(4 * inch))
    story.append(P('6. Circles, ellipses and arcs', H1))
    story.append(ctable([
        ['Macro', 'Draws'],
        ['GCIRC x,y,r', 'a circle of radius r centred on x,y; the CP is left '
         'at the centre'],
        ['GELLIP x,y,rx,ry', 'an ellipse with semi-axes rx (along X) and ry '
         '(along Y), each up to 4095'],
        ['GARC xc,yc,xe,ye[,DIRCW]', 'an arc from the CP round the centre '
         'xc,yc to where it meets the ray from the centre through xe,ye'],
        ['GRARC', 'the same, the centre and xe,ye relative to the CP'],
        ['GEARC rx,ry,xc,yc,xe,ye[,DIRCW]', 'an arc of an ellipse whose '
         'semi-axes are in the ratio rx:ry'],
        ['GREARC', 'the same, relative to the CP']],
        [2.5 * inch, 4.4 * inch]))
    story.append(Spacer(1, 6))
    story.extend(bullets([
        'An arc starts at the CP, and its radius is the CP\'s distance from '
        'the centre. It runs counter-clockwise, or clockwise with '
        + C('DIRCW') + ', and stops at the ray through xe,ye, so xe,ye need '
        'not be exactly on the curve. The CP is left at xe,ye, which is not '
        'drawn.',
        'For an elliptical arc only the ratio rx:ry matters (each at most '
        '90): the size comes from the CP. Started on the ellipse\'s '
        'horizontal axis, a distance d from the centre, the arc lies on the '
        'ellipse with semi-axes d along X and d * ry / rx along Y.',
        'Circles and ellipses are drawn in order round the curve, so a '
        'dashed line style runs along them (chapter 8).',
        'The arc macros clobber HL.']))
    story.append(shot(4, 'gfxdemo screen 4: concentric circles (GCIRC), a '
                         'rainbow of half-circle arcs drawn both ways round '
                         '(GARC, DIRCW), ellipses (GELLIP), and a spiral of '
                         'elliptical half arcs (GEARC).'))

    # ================================================== 7. drawing modes
    story.append(CondPageBreak(4 * inch))
    story.append(P('7. Drawing modes', H1))
    story.append(P(
        'Every ACRTC drawing command carries a mode in its low byte. czgfx '
        'keeps that byte, ' + C('CZDM') + ', and adds it to every drawing '
        'command it sends (all but the moves). ' + C('GINIT') + ' resets it '
        'to 0: replace, two-color pattern, no area checking.'))
    story.append(figure(fig_mode_byte(), 'Figure 3. The drawing mode byte.'))
    story.append(P(
        C('GMODE m') + ' sets the whole byte, e.g. '
        + C('GMODE OMEOR+CMCL1+AMCLIP') + '; ' + C('GMODE') + ' alone resets '
        'it. ' + C('GOPM') + ', ' + C('GCMODE') + ' and ' + C('GAMODE') +
        ' each set one field and keep the others.'))
    story.append(P('7.1 Operation modes', H2))
    story.append(P('The operation mode says how the color C being drawn meets '
                   'the pixel P already there:'))
    story.append(ctable([
        ['Value', 'Result'],
        ['OMREP', 'C (replace)'],
        ['OMOR', 'P OR C'],
        ['OMAND', 'P AND C'],
        ['OMEOR', 'P XOR C: drawing the same thing twice restores the picture'],
        ['OMEQ', 'C only where P = CCMP (set with GCCMP c)'],
        ['OMNE', 'C only where P is not CCMP'],
        ['OMLT', 'C only where P < C'],
        ['OMGT', 'C only where P > C']],
        [1.2 * inch, 5.7 * inch]))
    story.append(Spacer(1, 4))
    story.append(P('The logic and comparisons work on the palette index.',
                   NOTE))
    story.append(shot(5, 'gfxdemo screen 5: in each panel, two overlapping '
                         'boxes drawn over colored bands in one operation '
                         'mode. Top: replace, OR, AND, EOR (where the boxes '
                         'overlap, EOR restores the bands). Bottom: =CCMP, '
                         '<>CCMP, <C, >C.'))
    story.append(P('7.2 Color modes', H2))
    story.append(P(
        'The ACRTC draws every pixel through its pattern RAM (chapter 8). '
        'The color mode says what each pattern bit draws. With GINIT\'s '
        'all-ones pattern, every mode but CMCL0 simply draws in CL1.'))
    story.append(ctable([
        ['Value', 'A 1 bit draws', 'A 0 bit draws'],
        ['CMSEL', 'CL1 (GCOLOR)', 'CL0 (GBCOL)'],
        ['CMCL1', 'CL1', 'nothing: the pattern is transparent'],
        ['CMCL0', 'nothing', 'CL0'],
        ['CMPRAM', 'the pattern RAM is a 4x4 tile of colors (GTILE)', '']],
        [1.2 * inch, 3.0 * inch, 2.7 * inch]))
    story.append(P('7.3 Area modes', H2))
    story.append(P(
        'The area modes check each pixel against a rectangle, set with '
        + C('GAREA x1,y1,x2,y2') + ' (low and high corners, both inside) and '
        'reset to the whole screen with ' + C('GAFULL') + ':'))
    story.append(ctable([
        ['Value', 'Effect'],
        ['AMNONE', 'no checking'],
        ['AMCLIP', 'draw only inside the area'],
        ['AMHOLE', 'draw only outside it'],
        ['AMCLPD / AMHOLD', 'as AMCLIP / AMHOLE, and set ARD if a pixel was '
         'dropped'],
        ['AMSTOP', 'stop at the first pixel outside the area, and set ARD'],
        ['AMSTPI', 'stop at the first pixel inside the area, and set ARD']],
        [1.6 * inch, 5.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'ARD is status bit 6: after ' + C('GWAIT') + ', ' + C('ANI SRARD') +
        ' tests it. After a stop the CP is the pixel where the drawing '
        'stopped; ' + C('GGETCP') + ' reads it back into HL and DE, and also '
        'clears ARD.'))

    # ================================================== 8. pattern RAM
    story.append(CondPageBreak(4 * inch))
    story.append(P('8. The pattern RAM', H1))
    story.append(P(
        'The ACRTC draws every pixel, of lines and fills alike, through its '
        '16-word pattern RAM. GINIT fills it with ones, so everything draws '
        'in CL1 until a program loads a pattern of its own.'))
    story.append(P('8.1 Layout and the pattern pointer', H2))
    story.extend(bullets([
        'In the bit color modes word n is pattern <b>row n</b> and bit m '
        'its <b>column m</b>. Row 0 is the first row drawn (the bottom of a '
        'fill), bit 0 the leftmost pixel.',
        'A pattern pointer walks the RAM: one bit per pixel along a line '
        '(continuing round the corners of a rectangle, polygon or circle), '
        'one row per raster in a fill.',
        C('GPSCAN x0,y0,x1,y1[,zx,zy]') + ' sets the window it '
        'walks, columns x0..x1 and rows y0..y1, and optionally a zoom that '
        'draws each bit zx+1 times across and zy+1 times up. It also puts '
        'the pointer at the window\'s start.',
        'The pointer is <b>live</b>: it stays where the last drawing left '
        'it. Reset it with ' + C('GPPTR x,y') + ' before a fill whose tiling '
        'must line up. ' + C('GPDEF') + ' puts everything back as GINIT left '
        'it.']))
    story.append(P('8.2 Loading patterns', H2))
    story.append(code('''
        GLDPAT  RING            ;load a 16x16 pattern from row 0
        GPSCAN  0,0,15,15       ;the whole pattern, pointer at 0,0
        GCMODE  CMCL1           ;1 bits in CL1, 0 bits transparent
        GFBOX   100,100,300,200
        ...
        GPAT    RING,<0,0,07E0H,1FF8H,1E78H,381CH,381CH,300CH,...>'''))
    story.append(P(
        C('GPAT name,<w0,...>') + ' defines a pattern table (' + C('DW n') +
        ', then n words); ' + C('GLDPAT tbl[,pra]') + ' loads it from '
        'pattern word pra (default 0). ' + C('GTILE name,<c0,...,c15>') +
        ' defines a 4x4 color tile for ' + C('CMPRAM') + ': 16 palette '
        'indexes, c0..c3 its bottom row.'))
    story.append(P('8.3 Line styles', H2))
    story.append(P(
        C('GLSTYL pat[,zoom]') + ' is the quick way to dashed lines: pattern '
        'row 0 becomes the 16-bit style (bit 0 first), the window becomes '
        '16x1 and the pointer is reset. Fills use the style too, so set it '
        'back with ' + C('GLSTYL 0FFFFH') + ' (or ' + C('GPDEF') + ') '
        'afterwards. In ' + C('CMCL1') + ' the gaps leave the picture alone; '
        'in ' + C('CMSEL') + ' they draw in CL0.'))
    story.append(code('''
        GCMODE  CMCL1
        GLSTYL  0F0F0H          ;4 on, 4 off
        GBOX    40,24,200,184   ;the dashes run on round the corners
        GLSTYL  0FFFFH          ;solid again'''))
    story.append(P('8.4 Drawing the pattern itself: GPTN', H2))
    story.append(P(
        C('GPTN x,y,w,h[,dir]') + ' draws the pattern RAM as a w x h picture '
        'with its corner at x,y. Its rows run in direction dir, 45 degrees '
        'apart counter-clockwise from +X, and are stacked 90 degrees further '
        'round; adding ' + C('PTSLNT') + ' stacks them only 45 degrees round, '
        'slanting the picture. A diagonal direction leaves gaps between '
        'pixels, as the chip\'s PTN does. Text (chapter 11) is drawn this '
        'way.'))
    story.append(figure(fig_directions(), 'Figure 4. Directions 0-7, used by '
                                          'GPTN and text.'))
    story.append(shot(6, 'gfxdemo screen 6. Top: a ring pattern filled in '
                         'CMSEL, CMCL1 and CMCL0, and a 4x4 color tile in '
                         'CMPRAM. Bottom left: GLSTYL line styles, and dashes '
                         'running round a box, a circle and a triangle. '
                         'Bottom right: GPTN turned 0, 90, 180 and 270 '
                         'degrees, slanted, and at 45 degrees.'))

    # ================================================== 9. paint and copy
    story.append(CondPageBreak(4 * inch))
    story.append(P('9. PAINT, flood and copy', H1))
    story.append(P('9.1 Painting areas', H2))
    story.append(P(
        C('GPAINT x,y,e') + ' fills outward from x,y, in the current color, '
        'pattern and modes, up to pixels of the edge color e. '
        + C('GFLOOD x,y,c') + ' instead fills the connected region of color '
        'c round x,y, recoloring one shape.'))
    story.extend(bullets([
        '<b>CL0 and CL1 are edges too.</b> The chip also stops at any pixel '
        'already in CL0 or CL1. After GINIT CL0 is 0, so painting over black '
        'paints nothing until ' + C('GBCOL') + ' sets CL0 to something else. '
        'For a solid fill, set it to the fill color.',
        '<b>Outlines must be closed.</b> The fill is 4-connected, so an '
        '8-connected outline (lines, circles) holds it, but a line\'s end '
        'point isn\'t drawn: run spokes a pixel past a circle.',
        '<b>On the real board</b>, PAINT keeps only four pending seed points '
        'and hands any more to the host, which czgfx doesn\'t do, so a '
        'complicated area may be left partly unfilled. altairsim has no such '
        'limit.']))
    story.append(P('9.2 Copying blocks', H2))
    story.append(P(
        C('GCOPY x1,y1,x2,y2,xd,yd[,t]') + ' copies the rectangle with '
        'corners x1,y1 and x2,y2 so that corner x1,y1 lands on xd,yd, '
        'transformed by t. The operation and area modes apply at the '
        'destination; the color mode doesn\'t, since the source pixel is '
        'the color. The macro clobbers HL.'))
    story.append(figure(fig_transforms(),
                        'Figure 5. GCOPY\'s transforms, shown on an F. The red '
                        'dot is the source corner x1,y1, which lands on xd,yd.'))
    story.append(shot(7, 'gfxdemo screen 7. Top left: circles clipped to an '
                         'area (AMCLPD, yellow) and to outside it (AMHOLD, '
                         'blue). Bottom left: lines that stop at the edge of an '
                         'area (AMSTOP, AMSTPI), ringed where GGETCP found them. '
                         'Top right: a pie chart painted solid, patterned and '
                         'flood-recolored. Bottom right: a picture copied in all '
                         'eight orientations, in EOR, and clipped.'))

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
        ['Macro', 'Does'],
        ['GOVON / GOVOFF', 'show / hide the overlay; what is drawn in it stays'],
        ['GOVPAL r,g,b', 'the overlay color (clobbers BC, E)'],
        ['GOVL', 'draw on the overlay from here on'],
        ['GFRAME', 'draw on the frame again'],
        ['GOVCLS', 'clear the whole overlay, from either']],
        [1.6 * inch, 5.3 * inch]))
    story.append(Spacer(1, 6))
    story.extend(bullets([
        'Between ' + C('GOVL') + ' and ' + C('GFRAME') + ' every drawing '
        'macro draws on the overlay, with the frame\'s own coordinates.',
        'Overlay pixels are one bit, so the only colors are ' + C('OVSET') +
        ' (on) and ' + C('OVCLR') + ' (off): ' + C('GCOLOR OVSET') + ' draws, '
        + C('GCOLOR OVCLR') + ' erases.',
        C('OMEOR') + ' toggles bits: drawing a shape twice undraws it, the '
        'classic moving cursor.',
        'Patterns, the area modes and ' + C('GPAINT') + ' work on the '
        'overlay (set ' + C('GBCOL OVSET') + ' before painting); '
        + C('CMPRAM') + ' tiles mean nothing at one bit a pixel. '
        + C('GCOPY') + ' copies within the overlay, not between the planes.',
        C('GOVL') + ' and ' + C('GFRAME') + ' wait for the ACRTC to finish, '
        'since they switch its pixel depth, and leave the CP at 0,0: '
        + C('GMOVE') + ' afterwards.']))
    story.append(code('''
        GOVPAL  255,255,0       ;yellow
        GOVL                    ;draw on the overlay
        GCOLOR  OVSET
        GMODE   OMEOR
        CALL    XHAIR           ;draw a crosshair...
        CALL    XHAIR           ;...and undraw it: the picture is untouched
        GMODE
        GFRAME                  ;back to the frame
        GOVON                   ;show the overlay'''))
    story.append(shot(8, 'gfxdemo screen 8: the palette of screen 1 on the '
                         'frame, and on the overlay in yellow a grid, a circle, '
                         'a patterned and a solid box, and a crosshair moved '
                         'in EOR. Hiding the overlay (GOVOFF) shows screen 1 '
                         'unchanged.'))
    story.append(P(
        'How it works: the overlay has no display cycles of its own; each '
        'frame fetch also reads the overlay word for the same 16 pixels. '
        'The ACRTC draws it through a character (CHR) screen that the board '
        'routes to the overlay memory and never displays; GINIT sets it up '
        'with the frame\'s coordinates. ' + C('GOVL') + ' switches the chip '
        'to 1 bit a pixel and ' + C('GFRAME') + ' back to 8, after waiting, '
        'so that queued commands run at the depth they were sent for.', NOTE))

    # ================================================== 11. text
    story.append(CondPageBreak(4 * inch))
    story.append(P('11. Text', H1))
    story.append(P(
        'czgfx draws text a character at a time with the ACRTC\'s PTN '
        'command: each glyph is unpacked into the pattern RAM and PTN draws '
        'the character cell at the pen. That brings scaling (the pattern '
        'zoom, 1-16 times), turning (PTN\'s direction, in 45-degree steps) '
        'and the drawing modes with it. Text goes on whichever plane is being '
        'drawn, frame or overlay, in CL1.'))
    story.append(P('11.1 Fonts', H2))
    story.append(P(
        'A font is chosen by naming it with ' + C('GFONT') + ', and naming it '
        'is also what links it in, so a program carries only the fonts it '
        'uses. Both cover characters 20H-7EH; others draw as a blank.'))
    story.append(ctable([
        ['Font', 'Cell', 'Glyphs', 'Bytes'],
        ['CZF8', '8x8', '5x7, no true descenders', '480'],
        ['CZF11', '9x11', '7x10: capitals 8 rows, 2 descender rows', '860']],
        [1.0 * inch, 0.8 * inch, 4.2 * inch, 0.9 * inch]))
    story.append(Spacer(1, 6))
    story.append(figure(fig_font(mk, 'CZF8'), 'Figure 6. CZF8, the 8x8 font.'))
    story.append(figure(fig_font(mk, 'CZF11'),
                        'Figure 7. CZF11, the 9x11 font.'))
    story.append(P('11.2 Drawing text', H2))
    story.append(ctable([
        ['Macro', 'Does'],
        ['GFONT f', 'draw text in font f, CZF8 or CZF11 (clobbers HL)'],
        ['GTPOS x,y', 'put the pen at x,y: the bottom-left corner of the next '
         'character\'s cell; also the start of the line'],
        ['GTATTR s[,d[,TXOPAQ]]', 'scale 1-16, direction 0-7, and opaque '
         'cells (clobbers BC)'],
        ['GTEXT <\'text\'>', 'draw the text, placed inline, at the pen '
         '(clobbers HL, B)'],
        ['GTSTR', 'draw the B characters at HL'],
        ['GTCHR [c]', 'draw one character (blank: in A)'],
        ['GTNL', 'a new line: the start of the line moves one line on, and '
         'the pen goes there']],
        [2.0 * inch, 4.9 * inch]))
    story.append(Spacer(1, 6))
    story.append(code('''
        GOVL                    ;a title on the overlay
        GCOLOR  OVSET
        GFONT   CZF11
        GTATTR  2               ;scale 2, along +X
        GTPOS   24,730
        GTEXT   <'CADzilla text overlay'>
        GTNL                    ;the next line, under it
        GFRAME'''))
    story.extend(bullets([
        'After each character the pen moves one cell width times the scale '
        'along the direction; a string is characters x cell width x scale '
        'long. ' + C('GTNL') + ' moves one cell height times the scale, 90 '
        'degrees clockwise from the direction (down, for ordinary text).',
        'Both fonts have a blank top row and blank right-hand columns, so '
        'text set at the cell pitch doesn\'t touch.',
        '<b>Transparent</b> text (the default) leaves the picture alone in '
        'a glyph\'s 0 bits. <b>Opaque</b> text (' + C('TXOPAQ') + ') draws '
        'the whole cell, the 0 bits in CL0 (' + C('GBCOL') + '): for text '
        'rewritten in place, such as a status line. On the overlay, use '
        + C('GBCOL OVCLR') + '.',
        'The color mode is forced only while a string is drawn; the '
        'operation and area modes apply as usual.',
        'A string leaves the pattern RAM as GINIT does, and moves the CP: '
        'load your own pattern, and ' + C('GMOVE') + ', afterwards.',
        'Choose a font first: until ' + C('GFONT') + ', ' + C('GTEXT') + ', '
        + C('GTSTR') + ' and ' + C('GTCHR') + ' return C and draw nothing.']))
    story.append(shot(10, 'gfxdemo screen 10: screen 2 on the frame, and on '
                          'the overlay a 9x11 title at scale 2, both fonts '
                          'scaled up, both character sets (three lines each, '
                          'GTNL), text turned 90 and 45 degrees, and an opaque '
                          'status line rewritten in place. The red line is '
                          'drawn on the frame itself.'))
    story.append(P(
        'Size: the string-drawing core (' + C('CZTXT') + ', 444 bytes) is all '
        'a program that only draws strings needs; the pen, attribute, '
        'character and newline calls are a separate module (' + C('CZTXL') +
        '). A program that wants to stay small can store the pen, scale and '
        'direction into the text state ' + C('CZTST') + ' itself, at offsets '
        '+0/+2 (pen X, Y), +8 (scale), +9 (direction) and +10 (flags), and '
        'call ' + C('CZTFNT') + ' and ' + C('CZTSTR') + ' directly, as '
        'CZBASIC does.', NOTE))

    # ================================================== 12. reading back
    story.append(P('12. Reading back', H1))
    story.append(ctable([
        ['Macro', 'Returns'],
        ['GGETCP', 'the CP: HL = X, DE = Y. It also clears ARD.'],
        ['GRDOT x,y', 'the pixel at x,y: A = its palette index, NC; or C (A = '
         '0) if x,y is off the screen']],
        [1.6 * inch, 5.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'Both read through the ACRTC\'s read FIFO, after everything sent '
        'before them has been drawn. ' + C('GRDOT') + ' reads the frame, '
        'whichever plane is being drawn.'))

    # ================================================== 13. versions
    story.append(CondPageBreak(4 * inch))
    story.append(P('13. Library versions', H1))
    story.append(P(
        'czgfx is released in numbered versions, and each program builds '
        'against the release it chooses, from its own copy. A new czgfx '
        'version therefore reaches a program only when the program moves to '
        'it, and a program\'s ' + C('work/') + ' directory is self-contained.'))
    story.append(table([
        ['Where', 'What'],
        [C('CZGFX.INC: CZVERS'), 'the version: ' + C('CZVERS EQU 0100H') +
         ' is 1.0, major in the high byte, minor in the low. A program can '
         'check it at assembly time.'],
        [C('software/m80/czgfx/releases/CZGFXLIB-<v>.DSK'), 'the releases: '
         'library disks, one per version, tracked and never changed'],
        [C('software/<toolchain>/<project>/czgfx.version'), 'the pin: one line, e.g. '
         + C('1.0') + ', or ' + C('dev') + ' for the current, unreleased '
         'build'],
        [C('software/<toolchain>/<project>/work/CZGFXLIB-<v>.DSK'), 'the project\'s own '
         'copy of its pinned release, mounted as ' + C('B:') + ', read-only']],
        [2.9 * inch, 4.0 * inch]))
    story.append(P('13.1 Moving a program to another release', H2))
    story.append(code('''
echo 1.1 > software/m80/myprog/czgfx.version
tools/altairsim/scripts/attach_libdisk.sh software/m80/myprog/work'''))
    story.append(P(
        'then rebuild and relink the program. ' + C('attach_libdisk.sh') +
        ' copies the pinned release into ' + C('work/') + ', mounts it, and '
        'removes copies of releases no longer pinned. A program\'s '
        + C('.COM') + ' keeps the library code it was linked with until it '
        'is relinked.'))
    story.append(P('13.2 Making a release', H2))
    story.append(P(
        'Raise ' + C('CZVERS') + ' in ' + C('CZGFX.INC') + ', rebuild the '
        'library (Appendix D), then run ' + C('software/m80/czgfx/tools/release.sh')
        + '. It snapshots the build disk as ' +
        C('releases/CZGFXLIB-<major>.<minor>.DSK') + ', read-only, and refuses '
        'to overwrite an existing release or to release a build disk older '
        'than its sources. Add the new release to git.'))

    # ================================================== appendices
    story.append(PageBreak())
    story.append(P('Appendix A. Macro reference', H1))
    rows = [['Macro', 'Does']]
    for s, d in [
        ('GINIT [mode]', 'set up the board for CZM640 (default), CZM800 or '
         'CZM1K; clear. Clobbers all'),
        ('GCLS [c]', 'clear the screen to c (default 0)'),
        ('GCOLOR [c]', 'drawing color (CL1)'),
        ('GBCOL [c]', 'background color CL0'),
        ('GCCMP [c]', 'compare color for OMEQ/OMNE'),
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
        ('GFBOX x1,y1,x2,y2[,c]', 'a filled rectangle'),
        ('GPLINE <pts>  GPOLY <pts>', 'polyline / polygon, points inline. '
         'Clobbers HL'),
        ('GPTS name,<pts>', 'define a point table'),
        ('GPLT tbl  GPLG tbl', 'polyline / polygon from a table'),
        ('GCIRC x,y,r', 'circle'),
        ('GELLIP x,y,rx,ry', 'ellipse'),
        ('GARC xc,yc,xe,ye[,DIRCW]  GRARC', 'circular arc from the CP. '
         'Clobbers HL'),
        ('GEARC rx,ry,xc,yc,xe,ye[,DIRCW]  GREARC', 'elliptical arc from the '
         'CP. Clobbers HL'),
        ('GMODE [m]', 'the whole drawing mode'),
        ('GOPM op  GCMODE cm  GAMODE am', 'one field of the drawing mode'),
        ('GAREA x1,y1,x2,y2  GAFULL', 'the area / the whole screen'),
        ('GGETCP', 'read the CP: HL, DE. Clears ARD'),
        ('GRDOT x,y', 'read a pixel: A; C if off the screen'),
        ('GPAT name,<w...>  GTILE name,<c...>', 'define a pattern / color '
         'tile'),
        ('GLDPAT tbl[,pra]', 'load the pattern RAM'),
        ('GPSCAN x0,y0,x1,y1[,zx,zy]', 'pattern window and zoom. Clobbers HL'),
        ('GPPTR x,y', 'pattern pointer. Clobbers HL'),
        ('GPDEF', 'pattern RAM, window and pointer as after GINIT'),
        ('GLSTYL pat[,zoom]', 'line style'),
        ('GPTN x,y,w,h[,dir]', 'draw the pattern RAM'),
        ('GPAINT x,y,e', 'paint out to edge color e'),
        ('GFLOOD x,y,c', 'recolor the region of color c'),
        ('GCOPY x1,y1,x2,y2,xd,yd[,t]', 'copy a block. Clobbers HL'),
        ('GOVON  GOVOFF', 'show / hide the overlay'),
        ('GOVPAL r,g,b', 'overlay color. Clobbers BC, E'),
        ('GOVL  GFRAME', 'draw on the overlay / the frame'),
        ('GOVCLS', 'clear the overlay'),
        ('GFONT f', 'choose a font, CZF8 or CZF11. Clobbers HL'),
        ('GTPOS x,y', 'text pen'),
        ('GTATTR s[,d[,TXOPAQ]]', 'text scale, direction, opaque. Clobbers BC'),
        ('GTEXT <\'text\'>', 'draw inline text. Clobbers HL, B'),
        ('GTSTR  GTCHR [c]', 'draw B characters at HL / one character'),
        ('GTNL', 'new line')]:
        rows.append([C(s), d])
    story.append(table(rows, [3.3 * inch, 3.6 * inch]))

    story.append(PageBreak())
    story.append(P('Appendix B. Modules and routines', H1))
    story.append(P(
        'The routines behind the macros, by module, with each module\'s size '
        'in czgfx %s. Call them as ' % VERSION + C('NAME##') + '. A program '
        'links only the modules it uses, plus the ones those call.'))
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
        ('CZDRAW', 66, 'CZCOL, CZMOVE, CZLINE, CZRECT, CZFRCT, CZDOT, CZRMOV, '
         'CZRLIN, CZRRCT, CZRFRC'),
        ('CZPOLY', 49, 'CZPLL, CZPLG (HL = point table)'),
        ('CZCURV', 192, 'CZCRCL (HL = r), CZELPS (HL = rx, DE = ry), CZARC '
         '(A = OPAARC/OPRARC/OPAEAR/OPREAR + DIRCW, HL = table)'),
        ('CZFILL', 51, 'CZPANT (A = edge), CZFLOD (A = region), CZGCPY (A = '
         'transform, +10H relative; HL = table)'),
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

    story.append(P('Appendix C. Equates', H1))
    story.append(P('The header defines, besides the macros:'))
    rows = [['Group', 'Names']]
    for g, n in [
        ('Ports', 'CZBASE (70H), ACRSR, MODEREG, ACRDAT, DACADR, DACPAL, '
         'DACOVL'),
        ('Status bits', 'SRWFE 01H, SRWFR 02H, SRRFR 04H, SRCED 20H, SRARD 40H, '
         'SRCER 80H'),
        ('MODE bits', 'MDOLEN 08H (overlay shown), MDOLSL 10H'),
        ('Hues', 'ORANGE 0, BLUE 32, GREEN 64, CYAN 96, RED 128, MAGENTA 160, '
         'YELLOW 192, WHITE 224; BRIGHT 31'),
        ('Operation modes', 'OMREP OMOR OMAND OMEOR OMEQ OMNE OMLT OMGT (0-7)'),
        ('Color modes', 'CMSEL 00H, CMCL1 08H, CMCL0 10H, CMPRAM 18H'),
        ('Area modes', 'AMNONE 00H, AMSTOP 20H, AMCLIP 40H, AMCLPD 60H, AMSTPI '
         '0A0H, AMHOLE 0C0H, AMHOLD 0E0H'),
        ('Copy transforms', 'CPNORM CPMIRY CPMIRX CPR180 CPTRAN CPR270 CPR90 '
         'CPATRN (0-7)'),
        ('Directions', 'DIRCCW 0, DIRCW 1 (curves); PTSLNT 8 (GPTN)'),
        ('Overlay, text', 'OVSET 0FFH, OVCLR 0; TXOPAQ 1'),
        ('Opcodes', 'OPMOVE OPRMOV OPLINE OPRLIN OPRECT OPRRCT OPAPLL OPAPLG '
         'OPCRCL OPELPS OPAARC OPRARC OPAEAR OPREAR OPFRCT OPRFRC OPPANT OPDOT '
         'OPPTN OPAGCP OPRGCP OPRD (command high bytes); CMDDOT'),
        ('Version', 'CZVERS (0100H for 1.0)')]:
        rows.append([g, C(n)])
    story.append(table(rows, [1.5 * inch, 5.4 * inch]))

    story.append(PageBreak())
    story.append(P('Appendix D. Building and extending the library', H1))
    story.append(P(
        'The library is built on czgfx\'s own altairsim machine '
        '(' + C('software/m80/czgfx/work/') + '), which mounts the build disk '
        + C('libdisk/CZGFXLIB.DSK') + ' writable as ' + C('B:') + '. From '
        'a clean ' + C('A0>') + ', with the sources in CR/LF:'))
    story.append(code('''
A0>R *.*                  (the sources, from software/m80/czgfx/src)
A0>SUBMIT CZBUILD'''))
    story.append(P(C('CZBUILD.SUB') + ':'))
    story.extend(bullets([
        'assembles each module with M80;',
        'combines them with LIB80 into ' + C('CZGFX.REL') + ', in single-pass '
        'search order: every module before the modules it calls;',
        'checks the library with ' + C('LIB80 CZGFX/U/E') + ', which prints '
        'nothing when no external is left unsatisfied;',
        'copies ' + C('CZGFX.REL') + ', ' + C('CZGFX.INC') + ' and '
        + C('CZLINK.SUB') + ' onto ' + C('B:') + ';',
        'assembles ' + C('CZCHK.MAC') + ' against the header as published on '
        + C('B:') + ' and links it. CZCHK expands every macro and references '
        'every entry point, so a broken macro, a missing PUBLIC or a wrong '
        'module order fails the library build, not the first program.']))
    story.append(P('The build is good when every assembly prints '
                   + C('No Fatal error(s)') + ', ' + C('LIB80 /U') + ' prints '
                   'nothing, and L80 prints no ' + C('?Undefined') + ' or '
                   + C('%Mult. Def.') + '.'))
    story.append(P('D.1 Adding to the library', H2))
    story.extend(bullets([
        '<b>A routine:</b> make it PUBLIC in its module, add a macro if it '
        'helps (calling it as ' + C('NAME##') + ', never through an EXTRN in '
        'the header), and exercise it in ' + C('CZCHK.MAC') + '.',
        '<b>A module:</b> create ' + C('CZxxxx.MAC') + ' (INCLUDE CZGFX.INC, '
        'its PUBLICs, an EXTRN for each routine it calls), add its M80 line '
        'to ' + C('CZBUILD.SUB') + ', and add it to the LIB80 list after every '
        'module that calls it and before every module it calls.',
        '<b>A font:</b> draw its glyphs in ' + C('tools/mkfont.py') + ', which '
        'writes the font modules; run it, then CR/LF the output.',
        'Then release the change (chapter 13).']))
    story.append(P('D.2 M80 and L80 notes', H2))
    story.extend(bullets([
        'Global names are 6 characters: ' + C('LONGNAME1') + ' and '
        + C('LONGNAME2') + ' collide.',
        'Every EXTRN is a link request, used or not.',
        'Use ' + C('LOCAL') + ' for labels in a macro, never ' + C('SET') +
        ' for a label that is referenced forward: its value leaks from the '
        'previous expansion.',
        C('CSEG') + ' with no ' + C('ORG') + ': L80 places the program at '
        '0100H.',
        'Source must have CR/LF line ends; LF-only source assembles to '
        'nothing, silently.']))

    story.append(P('Appendix E. Limits', H1))
    story.extend(bullets([
        'No routines for the ACRTC\'s word-address block commands (CPY, SCPY, '
        'DRD, DWT, DMOD), WT and MOD, or the read-backs other than the CP and '
        'a pixel. ' + C('GCOPY') + ' covers copying on the screen. For the '
        'rest, send the command yourself with ' + C('CZCMD##') + ' or '
        + C('CZPUTW##') + ' and its parameters with ' + C('CZPUTW##') + '.',
        'PAINT\'s four-seed limit on the real chip (9.1).',
        'Only the overlay\'s lower half (' + C('MDOLSL') + ' = 0) is used, '
        'since czgfx\'s screen starts at frame word 0.',
        'Switching the ACRTC\'s pixel depth while the display runs (GOVL, '
        'GFRAME) is fine in altairsim; CADzilla uses no zoom or cursors, but '
        'it has not yet been checked on the real board.']))
    return story


def main():
    doc = Doc(OUT, pagesize=letter, title=TITLE, author='CADzilla Project',
              subject='czgfx graphics library %s' % VERSION,
              leftMargin=0.8 * inch, rightMargin=0.8 * inch,
              topMargin=0.85 * inch, bottomMargin=0.85 * inch)
    doc.multiBuild(build(), onFirstPage=on_cover, onLaterPages=on_page)
    print(OUT)


if __name__ == '__main__':
    main()
