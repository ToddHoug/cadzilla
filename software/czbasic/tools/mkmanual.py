#!/usr/bin/env python3
"""Generate docs/czbasic-manual.pdf: the CZBASIC graphics extensions reference.

Documents only the CADzilla (CZ...) statements and functions CZBASIC adds to
the MBASIC 5.21 language. The palette chart is computed from czgfx's CZPAL
tables and the character chart from this directory's mkfont.py glyphs, so both
match what the board draws.

Usage (from the repository root):
    python3 software/czbasic/tools/mkmanual.py
Needs ReportLab (the existing docs/cadzilla-manual.pdf is made the same way).
"""
import datetime
import importlib.util
import os
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
REPO = os.path.normpath(os.path.join(HERE, '..', '..', '..'))
OUT = os.path.join(REPO, 'docs', 'czbasic-manual.pdf')
COVER = os.path.join(REPO, 'docs', 'images', 'cadzilla.png')
TITLE = 'CZBASIC Graphics Extensions Reference'
REVISION = '1.0'
DATE = datetime.date.today().isoformat()

# ---------------------------------------------------------------- styles

ss = getSampleStyleSheet()
BODY = ParagraphStyle('body', parent=ss['BodyText'], fontName='Helvetica',
                      fontSize=10, leading=13.5, spaceAfter=6)
SMALL = ParagraphStyle('small', parent=BODY, fontSize=8.5, leading=11)
CELL = ParagraphStyle('cell', parent=BODY, fontSize=9, leading=11.5,
                      spaceAfter=0)
CELLB = ParagraphStyle('cellb', parent=CELL, fontName='Helvetica-Bold',
                       textColor=colors.white)
H1 = ParagraphStyle('h1', parent=ss['Heading1'], fontName='Helvetica-Bold',
                    fontSize=18, leading=22, spaceBefore=6, spaceAfter=10)
H2 = ParagraphStyle('h2', parent=ss['Heading2'], fontName='Helvetica-Bold',
                    fontSize=13, leading=16, spaceBefore=12, spaceAfter=6)
STMT = ParagraphStyle('stmt', parent=H2, fontSize=12.5, spaceBefore=14,
                      spaceAfter=4, textColor=colors.HexColor('#1a1a1a'))
LABEL = ParagraphStyle('label', parent=BODY, fontName='Helvetica-Bold',
                       fontSize=9.5, spaceBefore=4, spaceAfter=2)
CODE = ParagraphStyle('code', fontName='Courier', fontSize=9, leading=11.5,
                      leftIndent=8, spaceAfter=6, spaceBefore=2)
SYNTAX = ParagraphStyle('syntax', fontName='Courier-Bold', fontSize=10,
                        leading=13)
NOTE = ParagraphStyle('note', parent=BODY, fontSize=9.5, leading=12.5,
                      leftIndent=10, textColor=colors.HexColor('#333333'))
TOC1 = ParagraphStyle('toc1', parent=BODY, fontName='Helvetica-Bold',
                      fontSize=10, leading=12, leftIndent=0, spaceBefore=3,
                      spaceAfter=0)
TOC2 = ParagraphStyle('toc2', parent=BODY, fontSize=9, leading=10.5,
                      leftIndent=16, spaceBefore=0, spaceAfter=0)

DARK = colors.HexColor('#2b2b2b')
GRID = colors.HexColor('#b8b8b8')
SHADE = colors.HexColor('#f0f0f0')
BOXBG = colors.HexColor('#f4f4f4')


def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def P(text, style=BODY):
    return Paragraph(text, style)


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


class Doc(SimpleDocTemplate):
    """Headings go into the table of contents and the PDF outline."""

    def afterFlowable(self, f):
        if isinstance(f, Paragraph) and f.style.name in ('h1', 'h2', 'stmt'):
            text = f.getPlainText()
            level = 0 if f.style.name == 'h1' else 1
            key = 'k%d' % id(f)
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(text, key, level=level, closed=True)
            if f.style.name != 'stmt':
                self.notify('TOCEntry', (level, text, self.page, key))


def on_page(canv, doc):
    w, h = letter
    canv.saveState()
    canv.setStrokeColor(GRID)
    canv.setLineWidth(0.5)
    canv.setFont('Helvetica', 8)
    canv.setFillColor(colors.HexColor('#555555'))
    canv.drawString(0.75 * inch, h - 0.55 * inch, TITLE)
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
    # axes
    d.add(Line(x0, y0, x0 + 90, y0, strokeColor=colors.HexColor('#f0c040'),
               strokeWidth=2))
    d.add(Polygon([x0 + 90, y0 - 4, x0 + 98, y0, x0 + 90, y0 + 4],
                  fillColor=colors.HexColor('#f0c040'), strokeWidth=0))
    d.add(Line(x0, y0, x0, y0 + 70, strokeColor=colors.HexColor('#f0c040'),
               strokeWidth=2))
    d.add(Polygon([x0 - 4, y0 + 70, x0, y0 + 78, x0 + 4, y0 + 70],
                  fillColor=colors.HexColor('#f0c040'), strokeWidth=0))
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
    import math
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


def load_font():
    sys.dont_write_bytecode = True      # (no __pycache__ beside mkfont.py)
    spec = importlib.util.spec_from_file_location(
        'mkfont', os.path.join(HERE, 'mkfont.py'))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.G


def fig_font(glyphs):
    px, cols = 2.4, 16
    cw, chh = 8 * px + 12, 8 * px + 16
    rows = (95 + cols - 1) // cols
    d = Drawing(cols * cw, rows * chh)
    for i, c in enumerate(range(0x20, 0x7F)):
        col, row = i % cols, i // cols
        ox = col * cw + 6
        oy = (rows - 1 - row) * chh + 12
        d.add(Rect(ox - 1, oy - 1, 8 * px + 2, 8 * px + 2,
                   fillColor=colors.HexColor('#f4f4f4'),
                   strokeColor=colors.HexColor('#d0d0d0'), strokeWidth=0.4))
        g = ['.....'] + list(glyphs[chr(c)])      # 8 rows, blank top row
        for gy, line in enumerate(g):
            for gx, ch in enumerate(line):
                if ch == '#':
                    d.add(Rect(ox + gx * px, oy + (7 - gy) * px, px, px,
                               fillColor=DARK, strokeColor=None))
        d.add(String(ox + 4 * px, oy - 9, '%02X' % c, fontName='Helvetica',
                     fontSize=6, textAnchor='middle',
                     fillColor=colors.HexColor('#666666')))
    return d


# ---------------------------------------------------------------- content

def stmt(name, syntax, desc, args=None, notes=None, pen=None, example=None,
         errors=None):
    """One statement's reference entry, kept together where it fits."""
    parts = [P(esc(name), STMT)]
    box = Table([[P(esc(s), SYNTAX)] for s in syntax], colWidths=[6.9 * inch])
    box.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, -1), BOXBG),
                             ('BOX', (0, 0), (-1, -1), 0.5, GRID),
                             ('LEFTPADDING', (0, 0), (-1, -1), 8),
                             ('TOPPADDING', (0, 0), (-1, -1), 3),
                             ('BOTTOMPADDING', (0, 0), (-1, -1), 3)]))
    parts += [box, Spacer(1, 5)]
    for d in desc:
        parts.append(P(d))
    if args:
        parts.append(table([['Argument', 'Meaning']] + args,
                           [1.2 * inch, 5.7 * inch]))
        parts.append(Spacer(1, 4))
    if pen:
        parts.append(P('<b>Pen afterwards:</b> ' + pen, NOTE))
    for n in notes or []:
        parts.append(P(n, NOTE))
    if errors:
        parts.append(P('<b>Errors:</b> ' + errors, NOTE))
    head, tail = parts[:4], parts[4:]
    out = [CondPageBreak(1.6 * inch), KeepTogether(head)] + tail
    if example:
        out.append(KeepTogether([P('Example', LABEL), code(example)]))
    return out


def build():
    glyphs = load_font()
    story = []

    # ---- cover
    story.append(Spacer(1, 0.9 * inch))
    if os.path.exists(COVER):
        img = Image(COVER, width=2.6 * inch, height=2.6 * inch)
        img.hAlign = 'CENTER'
        story.append(img)
    story.append(Spacer(1, 0.35 * inch))
    ctr = dict(alignment=TA_CENTER)
    story.append(P('CZBASIC', ParagraphStyle('ct', parent=H1, fontSize=28,
                                              leading=34, **ctr)))
    story.append(P('Graphics Extensions Reference',
                   ParagraphStyle('cs', parent=H2, fontSize=15,
                                  textColor=colors.HexColor('#444444'),
                                  **ctr)))
    story.append(Spacer(1, 0.25 * inch))
    story.append(P('The CZ statements and functions that CZBASIC 1.0 adds to '
                   'Microsoft BASIC-80 (MBASIC) 5.21 for the CADzilla S-100 '
                   'graphics board: Hitachi HD63484 ACRTC and Brooktree Bt453 '
                   'video DAC',
                   ParagraphStyle('cd', parent=BODY, fontSize=11, leading=15,
                                  **ctr)))
    story.append(Spacer(1, 0.3 * inch))
    story.append(P('Document revision %s &middot; %s' % (REVISION, DATE),
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

    # ---- 1. introduction
    story.append(P('1. Introduction', H1))
    story.append(P(
        'CZBASIC runs programs written for Microsoft BASIC-80 (MBASIC) 5.21 '
        'under CP/M, and adds statements and functions for drawing on the '
        'CADzilla board. Their names all begin with <b>CZ</b>. This manual '
        'documents only those extensions. For the rest of the language '
        '&mdash; PRINT, FOR, GOSUB, files, EDIT and so on &mdash; see '
        'Microsoft\'s <i>BASIC-80 Reference Manual</i> for version 5.21: '
        'CZBASIC follows it.'))
    story.append(P('1.1 Starting CZBASIC', H2))
    story.append(code('''
A0>CZBASIC                start at command level (Ok)
A0>CZBASIC CZDEMO         load and run CZDEMO.BAS
A0>CZBASIC BIGPROG /X     no graphics: more memory for programs'''))
    story.append(P(
        'CZBASIC accepts MBASIC\'s switches (<font face="Courier">/F:</font> '
        'files, <font face="Courier">/M:</font> highest address, '
        '<font face="Courier">/S:</font> record size) and one of its own, '
        '<font face="Courier">/X</font>. With /X the memory that holds the '
        'graphics code (3,743 bytes) is given to programs instead, for large '
        'programs that don\'t draw; any CZ statement or function then gives '
        '<i>Illegal function call</i>.'))
    story.append(P('1.2 A first program', H2))
    story.append(code('''
10 CZINIT                         ' set up the board, clear the screen
20 CZRECT 0,0,CZXMAX,CZYMAX,255   ' a white frame round the screen
30 FOR R=20 TO 300 STEP 20
40   CZCIRCLE CZXMAX\\2,CZYMAX\\2,R,64+R\\12   ' green circles
50 NEXT
60 CZTEXT 20,CZYMAX-40,"HELLO, CADZILLA",192+31,3
70 CZWAIT'''))
    story.append(P(
        'Every graphics program starts with <b>CZINIT</b>, which programs the '
        'board for the monitor, loads the default palette and clears the '
        'screen. The drawing statements then take pixel coordinates and an '
        'optional color. The sample program <font face="Courier">'
        'CZDEMO.BAS</font> tours most of them.'))

    # ---- 2. concepts
    story.append(PageBreak())
    story.append(P('2. Concepts', H1))
    story.append(P('2.1 The screen and coordinates', H2))
    story.append(P(
        'Coordinates are pixels. <b>0,0 is the bottom-left pixel</b>; X grows '
        'to the right and <b>Y grows upward</b>, as on graph paper (not '
        'downward as on many other computers). The largest coordinates are '
        'the functions <b>CZXMAX</b> and <b>CZYMAX</b>, which depend on the '
        'mode CZINIT set:'))
    story.append(fig_coords())
    story.append(table([
        ['CZINIT', 'Pixels', 'CZXMAX', 'CZYMAX'],
        ['CZINIT or CZINIT 1024', '1024 x 768', '1023', '767'],
        ['CZINIT 800', '800 x 600', '799', '599'],
        ['CZINIT 640', '640 x 480', '639', '479']],
        [2.2 * inch, 1.5 * inch, 1.3 * inch, 1.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'The mode must match the monitor the board is set up for (the '
        'project\'s machine is strapped for 1024 x 768 unless it says '
        'otherwise). Write programs in terms of CZXMAX and CZYMAX and they '
        'work in every mode.'))
    story.append(P(
        'Coordinates may be negative or beyond the screen; a shape can lie '
        'partly off it. Nothing is clipped unless you ask for it, though, and '
        'the parts off the screen can land elsewhere in video memory, even '
        'reappearing on the screen. To keep drawing inside the screen, turn '
        'on clipping with an area mode: <font face="Courier">CZMODE 0,0,2'
        '</font> (see 2.5 and CZAREA).'))

    story.append(P('2.2 Arguments', H2))
    story.append(P(
        'Every argument of a CZ statement is a numeric expression: a '
        'constant, a variable, or any formula. It is rounded to a whole '
        'number the way CINT rounds (1.5 becomes 2, -1.5 becomes -2) and must '
        'lie in -32768 to 32767, else <i>Overflow</i>. Arguments shown in '
        'square brackets in the syntax may be left off, together with every '
        'argument after them. Colors, palette values and similar small '
        'numbers use the low 8 bits of the value (0 to 255).'))
    story.append(P(
        'Plain constants and simple variables as arguments are the fastest; '
        'a formula works just as well but has to be worked out first.'))

    story.append(P('2.3 Colors and the palette', H2))
    story.append(P(
        'The board shows 256 colors at once. A color is a <b>palette '
        'index</b>, 0 to 255, and the Bt453 palette maps each index to one '
        'of 16.7 million shades (CZPAL changes it). CZINIT loads the '
        '<b>default palette</b>: eight hues of 32 brightness levels, '
        '<b>index = hue + level</b>, level 0 being black and 31 the '
        'brightest:'))
    story.append(fig_palette())
    story.append(Spacer(1, 6))
    story.append(P(
        'So 224+31 = 255 is bright white, 128+31 = 159 bright red and 32+16 = '
        '48 a medium blue. Index 0 (and every level 0) is black.'))
    story.append(P(
        'The <b>drawing color</b> is set by <b>CZCOLOR</b> and stays until '
        'changed; CZINIT makes it 255. Most drawing statements also take an '
        'optional color as their last argument, which is used for that '
        'statement only:'))
    story.append(code('''
CZCOLOR 128+31                  ' red from now on
CZLINE 0,0,100,100              ' red
CZLINE 0,100,100,0,32+31        ' blue, this line only
CZLINE 50,0,50,100              ' red again'''))
    story.append(P(
        'CZCOLOR also sets the <b>background color</b> (CL0), used by '
        'patterns and line styles for their 0 bits (see 2.6); CZINIT makes it '
        '0, black.'))

    story.append(P('2.4 The pen', H2))
    story.append(P(
        'The board keeps a current position, the <b>pen</b>. CZMOVE and '
        'CZRMOVE move it; CZLINE TO and CZRLINE draw from it; most other '
        'statements move it as they draw. The functions <b>CZXPOS</b> and '
        '<b>CZYPOS</b> read it back. Each statement\'s entry says where it '
        'leaves the pen. CZINIT puts it at 0,0.'))

    story.append(P('2.5 Drawing modes', H2))
    story.append(P(
        '<b>CZMODE</b> <i>op</i>, <i>cm</i>, <i>am</i> sets three things '
        'that apply to all drawing from then on (CZINIT sets all three to 0):'))
    story.append(table([
        ['op', 'Operation: how the color C being drawn meets the pixel P '
         'already there'],
        ['0', 'Replace: P becomes C (normal drawing)'],
        ['1', 'OR: P becomes P OR C'],
        ['2', 'AND: P becomes P AND C'],
        ['3', 'Exclusive OR: P becomes P XOR C. Drawing the same shape twice '
         'restores the screen: rubber-band lines, blinking cursors.'],
        ['4', 'Draw only on pixels of color 0 (the compare color, CCMP, which '
         'CZINIT sets to 0)'],
        ['5', 'Draw only on pixels that are not color 0'],
        ['6', 'Draw only where P &lt; C'],
        ['7', 'Draw only where P &gt; C']],
        [0.6 * inch, 6.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(table([
        ['cm', 'Color mode: what each bit of the pattern draws (see 2.6)'],
        ['0', 'A 1 bit draws the drawing color, a 0 bit the background color'],
        ['1', 'A 1 bit draws the drawing color, a 0 bit leaves the screen '
         'alone (a transparent pattern)'],
        ['2', 'A 0 bit draws the background color, a 1 bit leaves the screen '
         'alone'],
        ['3', 'The pattern RAM is a 4 x 4 tile of colors: word row*4+column '
         'holds a color in both bytes (color*257)']],
        [0.6 * inch, 6.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(table([
        ['am', 'Area mode: checked against the rectangle CZAREA sets (the '
         'whole screen after CZINIT)'],
        ['0', 'No checking'],
        ['1', 'Stop drawing at the first pixel outside the area'],
        ['2', 'Draw only inside the area (clip)'],
        ['3', 'As 2, and note that something was clipped'],
        ['5', 'Stop drawing at the first pixel inside the area'],
        ['6', 'Draw only outside the area (a hole)'],
        ['7', 'As 6, and note that something was left out'],
        ['4', 'Not used']],
        [0.6 * inch, 6.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'After a stop mode has stopped a drawing, CZXPOS and CZYPOS give the '
        'pixel where it stopped. The "note" in modes 3 and 7 is a status '
        'flag of the ACRTC that BASIC does not read; for BASIC, 3 acts as 2 '
        'and 7 as 6.'))

    story.append(P('2.6 Patterns and line styles', H2))
    story.append(P(
        'The ACRTC draws every pixel through a 16 x 16 bit <b>pattern '
        'RAM</b>: 16 words, word <i>n</i> being row <i>n</i> of the pattern '
        'and bit <i>m</i> its column <i>m</i> (bit 0 is the leftmost pixel, '
        'row 0 the bottom row of a fill). A pattern <b>pointer</b> walks it '
        'as the chip draws: one bit per pixel along a line (carrying on round '
        'the corners of a rectangle, polygon or circle) and one row per '
        'raster in a fill, inside a <b>scan window</b>. Each bit then draws '
        'as the color mode says.'))
    story.append(P(
        'CZINIT fills the pattern RAM with ones and opens the window to all '
        '16 x 16, so everything is drawn solid in the drawing color. '
        '<b>CZLSTYLE</b> sets a dashed line style, <b>CZPAT</b> loads the '
        'pattern RAM, <b>CZPSCAN</b> sets the window and zoom, and '
        '<b>CZPTN</b> draws the pattern RAM itself as a small picture. '
        'Line styles and patterns apply to fills too. CZTEXT uses the '
        'pattern RAM for its characters and leaves it solid again, so set a '
        'pattern or line style again after CZTEXT.'))

    story.append(P('2.7 Drawing and BASIC run side by side', H2))
    story.append(P(
        'A CZ statement hands its drawing to the ACRTC and BASIC carries on '
        'while the chip draws. The chip always finishes one drawing before '
        'the next, and CZPOINT, CZXPOS and CZYPOS see the results of all the '
        'drawing before them. <b>CZWAIT</b> waits until everything has been '
        'drawn: use it before timing a drawing, and at the end of a program.'))

    story.append(P('2.8 Errors', H2))
    story.append(table([
        ['Error', 'When'],
        ['Syntax error', 'Too few or too many arguments, a missing comma or '
         'parenthesis, or CZPAL or CZAREA with 1 to 3 arguments'],
        ['Illegal function call', 'A value out of range (each entry lists '
         'its limits), or any CZ keyword when CZBASIC was started with /X'],
        ['Type mismatch', 'A string where a number is needed, or a CZPOLY / '
         'CZPLINE array that is not an integer (%) array'],
        ['Overflow', 'An argument outside -32768 to 32767']],
        [1.6 * inch, 5.3 * inch]))
    story.append(Spacer(1, 6))
    story.append(P(
        'CZ errors are ordinary BASIC errors: ON ERROR GOTO traps them, and '
        'ERR and ERL report them. The CZ keywords are reserved words, so a '
        'variable name cannot begin with CZ.'))

    # ---- 3. statements
    story.append(CondPageBreak(4 * inch))
    story.append(P('3. Statements', H1))
    story.append(P(
        'The statements in groups: setting up, color, modes, the pen, '
        'lines, shapes, fills, copying, patterns and text. Appendix A lists '
        'them all on one page.'))

    story.append(P('3.1 Setting up', H2))
    story += stmt('CZINIT', ['CZINIT [mode]'], [
        'Sets the board up for a display mode and clears the screen to black. '
        'Also loads the default palette and puts everything back to its '
        'starting state: drawing color 255, background color 0, CZMODE 0,0,0, '
        'the area the whole screen, the pattern RAM solid, the pen at 0,0.'],
        args=[['mode', '1024 (the default), 800 or 640: the screen width. '
               'It must match the monitor the board drives.']],
        errors='Illegal function call for any other mode.',
        example='10 CZINIT          \' 1024 x 768\n'
                '10 CZINIT 640      \' 640 x 480')
    story += stmt('CZCLS', ['CZCLS [c]'], [
        'Clears the whole screen to color c. Nothing else changes.'],
        args=[['c', 'The color, 0-255 (default 0, black)']],
        example='CZCLS             \' black\nCZCLS 32+4        \' dark blue')
    story += stmt('CZWAIT', ['CZWAIT'], [
        'Waits until the ACRTC has finished all the drawing given to it. '
        'Drawing statements return as soon as the chip has their commands, '
        'so use CZWAIT before measuring how long a drawing takes, before '
        'reading the board with INP, and at the end of a program.'])

    story.append(P('3.2 Color and palette', H2))
    story += stmt('CZCOLOR', ['CZCOLOR fg[,bg]'], [
        'Sets the drawing color, which stays until the next CZCOLOR or '
        'CZINIT, and optionally the background color that patterns and line '
        'styles draw for their 0 bits.'],
        args=[['fg', 'Drawing color, 0-255'],
              ['bg', 'Background color, 0-255 (unchanged if left off)']],
        example='CZCOLOR 192+31          \' bright yellow\n'
                'CZCOLOR 255,32+8        \' white, dark blue background')
    story += stmt('CZPAL', ['CZPAL i,r,g,b', 'CZPAL'], [
        'Sets palette entry i to the color with red, green and blue r, g, b. '
        'Everything already drawn in color i changes at once, which makes '
        'palette animation cheap. CZPAL with no arguments loads the default '
        'palette again.'],
        args=[['i', 'Palette index, 0-255'],
              ['r, g, b', 'Red, green and blue, 0-255 each']],
        errors='Syntax error with 1, 2 or 3 arguments.',
        example='CZPAL 1,255,128,0        \' index 1: orange\n'
                'FOR K=0 TO 255:CZPAL 255,K,K,255:NEXT   \' entry 255: blue to white\n'
                'CZPAL                    \' the default palette again')

    story.append(P('3.3 Modes and the area', H2))
    story += stmt('CZMODE', ['CZMODE op[,cm[,am]]'], [
        'Sets the operation, color and area modes that all drawing uses from '
        'then on. The values are in section 2.5. Modes left off are 0.'],
        args=[['op', 'Operation mode, 0-7 (0 replace, 1 OR, 2 AND, 3 XOR, '
               '4-7 conditional)'],
              ['cm', 'Color mode, 0-3'],
              ['am', 'Area mode, 0-7']],
        example='CZMODE 3                 \' XOR\n'
                'CZLINE 0,0,500,300       \' draw it...\n'
                'CZLINE 0,0,500,300       \' ...and XOR again: it is gone\n'
                'CZMODE 0,0,2             \' replace, clipped to the area')
    story += stmt('CZAREA', ['CZAREA x1,y1,x2,y2', 'CZAREA'], [
        'Sets the area rectangle the area modes test, with corners x1,y1 '
        '(bottom left) and x2,y2 (top right), both inside it. CZAREA with no '
        'arguments makes the area the whole screen again. The area only '
        'matters while CZMODE has an area mode set.'],
        errors='Syntax error with 1, 2 or 3 arguments.',
        example='CZAREA 100,100,400,300\nCZMODE 0,0,2             \' draw only '
                'inside it\nCZCIRCLE 250,200,180      \' a clipped circle\n'
                'CZMODE 0:CZAREA')

    story.append(P('3.4 The pen', H2))
    story += stmt('CZMOVE', ['CZMOVE x,y'], [
        'Moves the pen to x,y without drawing.'], pen='x,y')
    story += stmt('CZRMOVE', ['CZRMOVE dx,dy'], [
        'Moves the pen by dx across and dy up, without drawing.'],
        pen='moved by dx,dy')

    story.append(P('3.5 Dots and lines', H2))
    story += stmt('CZDOT', ['CZDOT x,y[,c]'], ['Sets one pixel.'],
                  args=[['x, y', 'The pixel'],
                        ['c', 'Color for this dot (default: the drawing '
                         'color)']],
                  pen='x,y',
                  example='FOR X=0 TO CZXMAX STEP 4:CZDOT X,CZYMAX\\2:NEXT')
    story += stmt('CZLINE', ['CZLINE x1,y1,x2,y2[,c]', 'CZLINE TO x,y[,c]'], [
        'Draws a straight line from x1,y1 to x2,y2, both ends included. '
        'CZLINE TO draws from the pen to x,y instead, so a chain of CZLINE '
        'TO statements draws a connected path.'],
        args=[['x1,y1 / x2,y2', 'The two ends'],
              ['c', 'Color for this line']],
        pen='the end point (x2,y2 or x,y)',
        notes=['Lines follow the line style (CZLSTYLE) and the drawing mode. '
               'In XOR mode a chain of CZLINE TO lines draws each shared '
               'corner twice, which XORs it back out.'],
        example='CZMOVE 100,100\nCZLINE TO 300,100:CZLINE TO 200,273:'
                'CZLINE TO 100,100   \' a triangle')
    story += stmt('CZRLINE', ['CZRLINE dx,dy[,c]'], [
        'Draws a line from the pen to the point dx across and dy up from it, '
        'both ends included.'],
        pen='the end point',
        example='CZMOVE 10,10:FOR I=1 TO 20:CZRLINE 20,0:CZRLINE 0,20:NEXT '
                '\' stairs')

    story.append(P('3.6 Rectangles', H2))
    story += stmt('CZRECT', ['CZRECT x1,y1,x2,y2[,c]'], [
        'Draws the outline of the rectangle with opposite corners x1,y1 and '
        'x2,y2 (any two opposite corners).'],
        pen='x1,y1',
        example='CZRECT 0,0,CZXMAX,CZYMAX,255     \' frame the screen')
    story += stmt('CZFRECT', ['CZFRECT x1,y1,x2,y2[,c]'], [
        'Fills the rectangle with opposite corners x1,y1 and x2,y2, in the '
        'current pattern (solid unless CZPAT or CZLSTYLE changed it).'],
        pen='just past the edge at y2 (the ACRTC\'s fill leaves it there); '
            'use CZMOVE before relying on it',
        example='FOR I=0 TO 7:CZFRECT 40+I*120,60,140+I*120,260,I*32+31:NEXT')

    story.append(P('3.7 Circles, ellipses and arcs', H2))
    story += stmt('CZCIRCLE', ['CZCIRCLE x,y,r[,c]'], [
        'Draws a circle of radius r centred on x,y.'],
        args=[['x, y', 'The centre'], ['r', 'The radius in pixels']],
        pen='the centre, x,y',
        example='FOR R=20 TO 360 STEP 20:CZCIRCLE 512,384,R,64+R\\12:NEXT')
    story += stmt('CZELLIPSE', ['CZELLIPSE x,y,rx,ry[,c]'], [
        'Draws an ellipse centred on x,y with semi-axes rx across and ry '
        'up (the radius along X and along Y).'],
        args=[['rx, ry', 'The semi-axes, 0-4095']],
        pen='the centre, x,y',
        example='CZELLIPSE 512,384,200,80,160+31')
    story += stmt('CZARC', ['CZARC xc,yc,xs,ys,xe,ye[,c[,dir]]'], [
        'Draws part of a circle centred on xc,yc. It starts at xs,ys, so the '
        'radius is the distance from the centre to xs,ys, and runs round to '
        'where the circle meets the ray from the centre through xe,ye.'],
        args=[['xc, yc', 'The centre'],
              ['xs, ys', 'The start point, on the circle'],
              ['xe, ye', 'Any point on the ray where the arc ends'],
              ['dir', '0 (default): counter-clockwise; any other value: '
               'clockwise']],
        pen='xe,ye',
        example='CZARC 300,300,400,300,300,400      \' a quarter circle, '
                'counter-clockwise')
    story += stmt('CZEARC', ['CZEARC xc,yc,rx,ry,xs,ys,xe,ye[,c[,dir]]'], [
        'As CZARC, but on an ellipse centred on xc,yc whose semi-axes are in '
        'the ratio rx:ry. Only the ratio matters: the size comes from the '
        'start point xs,ys.'],
        args=[['rx, ry', 'The ratio of the semi-axes, each 0-90'],
              ['dir', '0: counter-clockwise; other: clockwise']],
        pen='xe,ye',
        errors='Illegal function call if rx or ry is over 90.',
        example='CZEARC 800,600,2,1,880,600,800,640,255     \' a quarter of a '
                'wide ellipse')

    story.append(P('3.8 Polygons and polylines', H2))
    story += stmt('CZPOLY', ['CZPOLY a%(i),n[,c]'], [
        'Draws a closed polygon through n points held in an integer array: '
        'element i is the first point\'s X, i+1 its Y, i+2 the second '
        'point\'s X, and so on. The last point is joined back to the first.'],
        args=[['a%(i)', 'The first element of the points, in an integer (%) '
               'array; 2n elements from there are used'],
              ['n', 'The number of points, at least 2']],
        pen='the first point',
        errors='Type mismatch if the array is not an integer array; Illegal '
               'function call if n is less than 2.',
        example='10 DIM P%(7)\n20 FOR I=0 TO 7:READ P%(I):NEXT\n'
                '30 DATA 300,500,400,500,350,600,300,500\n'
                '40 CZPOLY P%(0),4,64+20')
    story += stmt('CZPLINE', ['CZPLINE a%(i),n[,c]'], [
        'As CZPOLY, but open: the last point is not joined back to the '
        'first.'],
        pen='the last point',
        example='CZPLINE P%(0),3,255')

    story.append(P('3.9 Filling areas', H2))
    story += stmt('CZPAINT', ['CZPAINT x,y,edge[,c]'], [
        'Fills outward from x,y until it reaches pixels of color edge, in '
        'color c or the drawing color and the current pattern. The outline '
        'must be closed: the fill spreads up, down, left and right, so an '
        'outline of lines or a circle holds it.'],
        args=[['x, y', 'A point inside the area'],
              ['edge', 'The color of the outline'],
              ['c', 'The fill color']],
        notes=['The fill also stops at pixels already in the fill color.',
               'On the real board the ACRTC can fill only a limited number of '
               'separate spans at once, so a very complicated area may be '
               'left partly unfilled; fill it in pieces if it is.'],
        example='CZCIRCLE 400,400,50,96+31\nCZPAINT 400,400,96+31,128+20    '
                '\' fill the circle red')
    story += stmt('CZFLOOD', ['CZFLOOD x,y,region[,c]'], [
        'Recolors the connected region of color region that contains x,y: '
        'every other color is its edge. Use it to change the color of one '
        'shape.'],
        args=[['region', 'The color of the region to fill'],
              ['c', 'Its new color']],
        example='CZFLOOD 400,400,128+20,192+31   \' the red circle turns '
                'yellow')

    story.append(P('3.10 Copying', H2))
    story += stmt('CZCOPY', ['CZCOPY x1,y1,x2,y2,xd,yd[,t]'], [
        'Copies the rectangle with corners x1,y1 and x2,y2 so that its '
        'corner x1,y1 lands on xd,yd, turned or mirrored as t says. The '
        'operation and area modes apply where it lands (so XOR and clipping '
        'work); the color mode does not, since the pixels bring their own '
        'colors.'],
        args=[['t', 'The transform, 0-7: 0 as it is, 1 flipped top to '
               'bottom, 2 mirrored left to right, 3 turned 180 degrees, 4 '
               'transposed (mirrored in the diagonal), 5 turned 90 degrees '
               'clockwise, 6 turned 90 degrees counter-clockwise, 7 mirrored '
               'in the other diagonal']],
        pen='moved; use CZMOVE before relying on it',
        example='CZCOPY 100,100,200,200,250,100        \' a copy beside it\n'
                'CZCOPY 100,100,200,200,450,100,2      \' mirrored')

    story.append(P('3.11 Patterns', H2))
    story += stmt('CZPAT', ['CZPAT start,w0[,w1...]'], [
        'Loads up to 16 words into the pattern RAM, from word start on. Each '
        'word is one row of the pattern (bit 0 the leftmost pixel). Words '
        'are 16-bit numbers: &amp;H constants are handy, and -1 is all '
        'ones.'],
        args=[['start', 'The first word to load, 0-15'],
              ['w0, w1, ...', 'The words (up to 16)']],
        example="CZPAT 0,&HAAAA,&H5555          ' a checkerboard, two rows\n"
                "CZPSCAN 0,0,15,1               ' repeat just those rows\n"
                "CZFRECT 20,300,80,360          ' a shaded box")
    story += stmt('CZLSTYLE', ['CZLSTYLE pat[,zoom]'], [
        'Sets a line style: the 16 bits of pat, bit 0 first, repeat along '
        'every line, the 1 bits drawn and the 0 bits drawn in the background '
        'color (or skipped in color mode 1). Each bit covers zoom+1 pixels. '
        'CZLSTYLE -1 is solid again.'],
        args=[['pat', 'The style, 16 bits'],
              ['zoom', '0-15 (default 0): each bit drawn zoom+1 times']],
        notes=['CZLSTYLE loads pattern row 0 and a 16 x 1 scan window, so '
               'fills use the style too until CZLSTYLE -1.'],
        example="CZLSTYLE &HF0F0             ' dashes\n"
                "CZLINE 20,400,300,400\n"
                "CZLSTYLE &HF0F0,2           ' longer dashes\n"
                "CZLSTYLE -1                 ' solid")
    story += stmt('CZPSCAN', ['CZPSCAN x0,y0,x1,y1[,zx,zy]'], [
        'Sets the scan window, the part of the pattern RAM the pattern '
        'pointer walks: columns x0 to x1 and rows y0 to y1. Each bit is drawn '
        'zx+1 times across and zy+1 times up. Also puts the pointer at '
        'x0,y0.'],
        args=[['x0, y0, x1, y1', 'The window, 0-15 each'],
              ['zx, zy', 'The zoom, 0-15 each (default 0)']],
        example='CZPSCAN 0,0,15,15            \' all of it again')
    story += stmt('CZPTN', ['CZPTN x,y,w,h[,dir]'], [
        'Draws the pattern RAM itself as a picture w pixels wide and h high '
        'with its corner at x,y, from the pattern pointer. It can be turned '
        'in 45-degree steps; adding 8 to dir slants the rows 45 degrees '
        'instead of 90. A diagonal pattern has gaps between its pixels, as '
        'the chip draws it.'],
        args=[['w, h', 'The size, 1-256'],
              ['dir', '0-7: the rows run dir x 45 degrees counter-clockwise '
               'from +X (default 0); +8 slants them']],
        pen='one row past the last row drawn',
        example='CZPAT 0,&H0FF0,&H1FF8,&H3FFC,&H7FFE\n'
                'CZPSCAN 0,0,15,3             \' those 4 rows, pointer at 0,0\n'
                'CZPTN 900,700,16,4\n'
                'CZPAT 0,-1,-1,-1,-1:CZPSCAN 0,0,15,15   \' solid again')

    story.append(P('3.12 Text', H2))
    story += stmt('CZTEXT', ['CZTEXT x,y,s$[,c[,scale[,dir]]]'], [
        'Draws the string s$ in CZBASIC\'s 8 x 8 font with the bottom-left '
        'corner of its first character at x,y. Only the characters\' own '
        'pixels are drawn: the background shows through. Each character is '
        'scale times bigger than 8 x 8 pixels, and the text can run in any of '
        'eight directions.'],
        args=[['s$', 'The text: characters 32-126 (others draw as spaces)'],
              ['c', 'Color for this text'],
              ['scale', '1-16 (default 1): each pixel of the font becomes a '
               'scale x scale block'],
              ['dir', '0-7 (default 0): the text runs dir x 45 degrees '
               'counter-clockwise from +X, the characters turned with it']],
        notes=['Each character takes 8 x scale pixels along the line; the '
               'font\'s letters are 5 pixels wide and 7 high, with room for '
               'descenders and the gap to the next character.',
               'CZTEXT draws in the current operation and area modes. It '
               'uses the pattern RAM and leaves it solid, so a pattern or '
               'line style must be set again afterwards.'],
        errors='Illegal function call if scale is 0 or more than 16.',
        example='CZTEXT 20,720,"CZBASIC ON CADZILLA",255,2\n'
                'FOR D=0 TO 7:CZTEXT 512,384,"  DIRECTION",96+31,2,D:NEXT')
    story.append(KeepTogether([
        P('Text directions (dir):', LABEL), fig_directions()]))
    story.append(CondPageBreak(3 * inch))
    story.append(P('The CZTEXT character set (characters 20H-7EH):', LABEL))
    story.append(fig_font(glyphs))

    # ---- 4. functions
    story.append(PageBreak())
    story.append(P('4. Functions', H1))
    story += stmt('CZPOINT', ['CZPOINT(x,y)'], [
        'Returns the color of the pixel at x,y, 0-255, or -1 if x,y is off '
        'the screen. It reads the screen as it is after all the drawing '
        'before it.'],
        example='IF CZPOINT(X,Y)=0 THEN CZDOT X,Y,255   \' only on black')
    story += stmt('CZXMAX, CZYMAX', ['CZXMAX', 'CZYMAX'], [
        'The largest X and Y of the screen in the current mode (1023 and 767 '
        'after CZINIT 1024). They take no arguments.'],
        example='CZRECT 0,0,CZXMAX,CZYMAX')
    story += stmt('CZXPOS, CZYPOS', ['CZXPOS', 'CZYPOS'], [
        'The pen\'s current X and Y. After an area stop mode has stopped a '
        'drawing, they give the pixel where it stopped.'],
        example='CZCIRCLE 300,200,50:PRINT CZXPOS;CZYPOS     \' 300 200')

    # ---- 5. examples
    story.append(PageBreak())
    story.append(P('5. Example programs', H1))
    story.append(P('5.1 A star burst', H2))
    story.append(code('''
10 CZINIT:CX=CZXMAX\\2:CY=CZYMAX\\2
20 FOR I=0 TO 63:A=I*6.28318/64
30   CZLINE CX,CY,CX+300*COS(A),CY+300*SIN(A),(I MOD 8)*32+31
40 NEXT
50 CZWAIT'''))
    story.append(P('5.2 A rubber band with XOR', H2))
    story.append(P(
        'Drawing in XOR mode twice leaves the screen as it was, so a line can '
        'be moved over a picture without damaging it:'))
    story.append(code('''
10 CZINIT:CZCIRCLE 512,384,200,64+31:CZMODE 3
20 FOR X=100 TO 900 STEP 4
30   CZLINE 512,100,X,600,255    ' draw it
40   CZLINE 512,100,X,600,255    ' and take it away again
50 NEXT
60 CZMODE 0:CZWAIT'''))
    story.append(P('5.3 Shapes, paint and flood', H2))
    story.append(code('''
10 CZINIT
20 DIM P%(11):FOR I=0 TO 5:A=I*6.28318/6
30   P%(2*I)=512+150*COS(A):P%(2*I+1)=384+150*SIN(A):NEXT
40 CZPOLY P%(0),6,255              ' a white hexagon
50 CZPAINT 512,384,255,128+20      ' filled red
60 CZFLOOD 512,384,128+20,32+24    ' then recolored blue
70 CZWAIT'''))
    story.append(P('5.4 Reading the screen', H2))
    story.append(code('''
10 CZINIT:CZFRECT 200,200,300,300,96+31
20 N=0:FOR X=190 TO 310:IF CZPOINT(X,250)<>0 THEN N=N+1
30 NEXT:PRINT N;"pixels are cyan"       ' 101'''))
    story.append(P('5.5 Palette animation', H2))
    story.append(P(
        'Changing a palette entry recolors everything drawn in it at once, '
        'without redrawing:'))
    story.append(code('''
10 CZINIT:FOR R=10 TO 350 STEP 10:CZCIRCLE 512,384,R,R\\10:NEXT
20 FOR T=1 TO 100:FOR I=1 TO 35
30   CZPAL I,(I+T)*7 AND 255,0,255-((I+T)*7 AND 255)
40 NEXT:NEXT:CZPAL'''))

    # ---- appendix
    story.append(PageBreak())
    story.append(P('Appendix A. Quick reference', H1))
    rows = [['Statement / function', 'Does']]
    for s, d in [
        ('CZINIT [640|800|1024]', 'set up the board, clear, defaults'),
        ('CZCLS [c]', 'clear the screen to c'),
        ('CZWAIT', 'wait for the drawing to finish'),
        ('CZCOLOR fg[,bg]', 'drawing and background colors'),
        ('CZPAL i,r,g,b | CZPAL', 'set a palette entry | default palette'),
        ('CZMODE op[,cm[,am]]', 'operation, color and area modes'),
        ('CZAREA x1,y1,x2,y2 | CZAREA', 'the area | the whole screen'),
        ('CZMOVE x,y  /  CZRMOVE dx,dy', 'move the pen'),
        ('CZDOT x,y[,c]', 'a pixel'),
        ('CZLINE x1,y1,x2,y2[,c]', 'a line, both ends drawn'),
        ('CZLINE TO x,y[,c]', 'a line from the pen'),
        ('CZRLINE dx,dy[,c]', 'a line relative to the pen'),
        ('CZRECT x1,y1,x2,y2[,c]', 'rectangle outline'),
        ('CZFRECT x1,y1,x2,y2[,c]', 'filled rectangle'),
        ('CZCIRCLE x,y,r[,c]', 'circle'),
        ('CZELLIPSE x,y,rx,ry[,c]', 'ellipse'),
        ('CZARC xc,yc,xs,ys,xe,ye[,c[,dir]]', 'arc of a circle'),
        ('CZEARC xc,yc,rx,ry,xs,ys,xe,ye[,c[,dir]]', 'arc of an ellipse'),
        ('CZPOLY a%(i),n[,c]', 'closed polygon from an array'),
        ('CZPLINE a%(i),n[,c]', 'open polyline from an array'),
        ('CZPAINT x,y,edge[,c]', 'fill out to an edge color'),
        ('CZFLOOD x,y,region[,c]', 'recolor a region'),
        ('CZCOPY x1,y1,x2,y2,xd,yd[,t]', 'copy a block, turned or mirrored'),
        ('CZPAT start,w0[,w1...]', 'load the pattern RAM'),
        ('CZLSTYLE pat[,zoom]', 'line style'),
        ('CZPSCAN x0,y0,x1,y1[,zx,zy]', 'pattern scan window and zoom'),
        ('CZPTN x,y,w,h[,dir]', 'draw the pattern RAM'),
        ('CZTEXT x,y,s$[,c[,scale[,dir]]]', 'text in the 8 x 8 font'),
        ('CZPOINT(x,y)', 'a pixel\'s color, -1 off the screen'),
        ('CZXMAX  CZYMAX', 'the largest X and Y'),
        ('CZXPOS  CZYPOS', 'the pen position')]:
        rows.append(['<font face="Courier">%s</font>' % esc(s), d])
    story.append(table(rows, [3.6 * inch, 3.3 * inch]))
    story.append(Spacer(1, 10))
    story.append(P(
        'Colors: index = hue + level; hues 0 orange, 32 blue, 64 green, '
        '96 cyan, 128 red, 160 magenta, 192 yellow, 224 white; levels 0-31. '
        'Coordinates: 0,0 at the bottom left, Y up.', SMALL))
    return story


def main():
    doc = Doc(OUT, pagesize=letter, title=TITLE, author='CADzilla Project',
              subject='CZBASIC graphics extensions',
              leftMargin=0.8 * inch, rightMargin=0.8 * inch,
              topMargin=0.85 * inch, bottomMargin=0.85 * inch)
    doc.multiBuild(build(), onFirstPage=on_cover, onLaterPages=on_page)
    print(OUT)


if __name__ == '__main__':
    main()
