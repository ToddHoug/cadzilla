#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Todd Houg
"""Generate docs/cadzilla-manual.pdf: the CADzilla board user reference manual.

Documents the board's I/O address map, MODE register, SW1 configuration DIP
switch, frame buffer, and HD63484 feature support. Keep this in sync with the
"Board specification" section of the top-level README.md -- the two are meant
to say the same thing in two forms.

Usage (from the repository root):
    python3 tools/mkmanual.py
Needs ReportLab (same as software/m80/czbasic/tools/mkmanual.py).
"""
import os

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (Image, PageBreak, Paragraph,
                                SimpleDocTemplate, Spacer, Table, TableStyle)

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, '..'))
IMG = os.path.join(REPO, 'docs', 'images', 'cadzilla.png')
OUT = os.path.join(REPO, 'docs', 'cadzilla-manual.pdf')

PAGE_W, PAGE_H = letter
MARGIN = 0.85 * inch

REVISION = '1.2'
DATE = '2026-10-01'

styles = getSampleStyleSheet()

styles.add(ParagraphStyle(
    name="CZTitle", parent=styles["Title"], fontSize=28, leading=32,
    spaceAfter=6, textColor=colors.HexColor("#1a1a1a"),
))
styles.add(ParagraphStyle(
    name="CZSubtitle", parent=styles["Normal"], fontSize=14, leading=18,
    alignment=1, textColor=colors.HexColor("#555555"), spaceAfter=4,
))
styles.add(ParagraphStyle(
    name="CZMeta", parent=styles["Normal"], fontSize=9, leading=12,
    alignment=1, textColor=colors.HexColor("#888888"),
))
styles.add(ParagraphStyle(
    name="CZH1", parent=styles["Heading1"], fontSize=16, leading=20,
    spaceBefore=18, spaceAfter=8, textColor=colors.HexColor("#1a1a1a"),
    borderColor=colors.HexColor("#cccccc"), borderWidth=0,
))
styles.add(ParagraphStyle(
    name="CZBody", parent=styles["Normal"], fontSize=10, leading=14.5,
    spaceAfter=8, textColor=colors.HexColor("#222222"),
))
styles.add(ParagraphStyle(
    name="CZNote", parent=styles["Normal"], fontSize=9, leading=13,
    spaceAfter=8, textColor=colors.HexColor("#555555"), leftIndent=10,
))
styles.add(ParagraphStyle(
    name="CZItalicBody", parent=styles["Normal"], fontSize=10, leading=14.5,
    spaceAfter=8, textColor=colors.HexColor("#333333"), fontName="Helvetica-Oblique",
))
styles.add(ParagraphStyle(
    name="CZCell", parent=styles["Normal"], fontSize=9, leading=12,
    textColor=colors.HexColor("#222222"),
))
styles.add(ParagraphStyle(
    name="CZCellHead", parent=styles["Normal"], fontSize=9, leading=12,
    textColor=colors.white, fontName="Helvetica-Bold",
))
styles.add(ParagraphStyle(
    name="CZCellMono", parent=styles["Normal"], fontSize=9, leading=12,
    fontName="Courier", textColor=colors.HexColor("#222222"),
))

HEADER_BG = colors.HexColor("#20303d")
ROW_ALT = colors.HexColor("#f4f6f7")
GRID = colors.HexColor("#cfd6da")


def cell(text, style="CZCell"):
    return Paragraph(text, styles[style])


def make_table(headers, rows, col_widths, header_bg=HEADER_BG):
    data = [[cell(h, "CZCellHead") for h in headers]]
    for r in rows:
        data.append([cell(c) if not c.startswith("`") else cell(c.strip("`"), "CZCellMono") for c in r])
    t = Table(data, colWidths=col_widths, repeatRows=1)
    style = [
        ("BACKGROUND", (0, 0), (-1, 0), header_bg),
        ("GRID", (0, 0), (-1, -1), 0.5, GRID),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]
    for i in range(1, len(data)):
        if i % 2 == 0:
            style.append(("BACKGROUND", (0, i), (-1, i), ROW_ALT))
    t.setStyle(TableStyle(style))
    return t


def on_page(canvas, doc):
    canvas.saveState()
    if doc.page > 1:
        canvas.setStrokeColor(colors.HexColor("#cccccc"))
        canvas.setLineWidth(0.5)
        canvas.line(MARGIN, PAGE_H - 0.55 * inch, PAGE_W - MARGIN, PAGE_H - 0.55 * inch)
        canvas.setFont("Helvetica", 8)
        canvas.setFillColor(colors.HexColor("#888888"))
        canvas.drawString(MARGIN, PAGE_H - 0.45 * inch, "CADzilla User Reference Manual")
        canvas.line(MARGIN, 0.6 * inch, PAGE_W - MARGIN, 0.6 * inch)
        canvas.drawRightString(PAGE_W - MARGIN, 0.45 * inch, f"Page {doc.page - 1}")
        canvas.drawString(MARGIN, 0.45 * inch, "CADzilla")
    canvas.restoreState()


def build():
    doc = SimpleDocTemplate(
        OUT, pagesize=letter,
        leftMargin=MARGIN, rightMargin=MARGIN, topMargin=MARGIN, bottomMargin=MARGIN,
        title="CADzilla User Reference Manual", author="CADzilla Project",
    )

    story = []

    # --- Title page ---
    story.append(Spacer(1, 0.4 * inch))
    story.append(Image(IMG, width=2.6 * inch, height=2.6 * inch, hAlign="CENTER"))
    story.append(Spacer(1, 0.3 * inch))
    story.append(Paragraph("CADzilla", styles["CZTitle"]))
    story.append(Paragraph("<para alignment='center'>User Reference Manual</para>",
                            ParagraphStyle(name="CZTitleCenter", parent=styles["CZTitle"],
                                           fontSize=16, textColor=colors.HexColor("#555555"))))
    story.append(Spacer(1, 0.15 * inch))
    story.append(Paragraph(
        "S-100 bus graphics controller board &mdash; Hitachi HD63484 ACRTC "
        "&amp; Brooktree Bt453 video DAC",
        styles["CZSubtitle"]))
    story.append(Spacer(1, 0.6 * inch))
    story.append(Paragraph(f"Document revision {REVISION} &middot; {DATE}", styles["CZMeta"]))
    story.append(PageBreak())

    # --- Preface ---
    story.append(Paragraph("Preface", styles["CZH1"]))
    story.append(Paragraph(
        "CADzilla exists for one reason: to enjoy the graphics board design "
        "process the way I did it forty years ago. The circuit architecture, "
        "schematic design, and PCB layout were all done by hand, with no AI "
        "assistance &mdash; the way boards like this were designed back then.",
        styles["CZItalicBody"]))
    story.append(Paragraph(
        "Every component on the board, aside from the modern SRAM used for the "
        "frame buffer, is a part that would have been available in 1984, when "
        "the Hitachi HD63484 was released and the S-100 bus was still a going "
        "concern. As far as I could find, no one had ever built an "
        "HD63484-based S-100 board &mdash; so I built one.",
        styles["CZItalicBody"]))
    story.append(Paragraph(
        "AI did play a role, but not in the hardware: it made it possible to "
        "build a CP/M software development environment and toolchain for the "
        "board that I could never have put together on my own.",
        styles["CZItalicBody"]))

    # --- 1. Overview ---
    story.append(Paragraph("1. Overview", styles["CZH1"]))
    story.append(Paragraph(
        "CADzilla is an S-100 bus board built around the Hitachi HD63484 Advanced "
        "CRT Controller (ACRTC) paired with a Brooktree Bt453 video DAC. The board "
        "carries 2 MBytes of video frame buffer memory and supports 8-bit-per-pixel "
        "(256-color) display modes at resolutions up to 1024&times;768.",
        styles["CZBody"]))
    story.append(Paragraph(
        "The board occupies a single, jumper/switch-selectable 8-byte block of "
        "S-100 I/O space. This manual documents that I/O map, the board's MODE "
        "register, the SW1 configuration DIP switch, and the set of HD63484 "
        "features the board does and does not support.",
        styles["CZBody"]))

    # --- 2. I/O Address Map ---
    story.append(Paragraph("2. I/O Address Map", styles["CZH1"]))
    story.append(Paragraph(
        "The board decodes a single 8-byte-aligned base I/O address, set by SW1 "
        "(see Section 4). All board registers are addressed as offsets from that "
        "base address:",
        styles["CZBody"]))
    io_headers = ["Offset", "Register", "Access"]
    io_rows = [
        ["`Base + 0`", "HD63484 Address/Status Register (RS = 0)", "Read/Write"],
        ["`Base + 1`", "MODE Register (board configuration &mdash; see Section 3)", "Write only"],
        ["`Base + 2`", "HD63484 Control/FIFO Register (RS = 1)", "Read/Write"],
        ["`Base + 3`", "Reserved / not decoded", "&mdash;"],
        ["Base + 4 &ndash; Base + 7", "Bt453 video DAC registers", "Read/Write"],
    ]
    story.append(make_table(io_headers, io_rows, [1.3 * inch, 3.6 * inch, 1.1 * inch]))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "RS is the HD63484 register-select input: RS = 0 selects the address/"
        "status register at Base + 0, RS = 1 selects the control/FIFO register "
        "at Base + 2.",
        styles["CZNote"]))

    # --- 3. MODE Register ---
    story.append(Paragraph("3. MODE Register (Base + 1, write only)", styles["CZH1"]))
    story.append(Paragraph(
        "The MODE register configures board-level options that are outside the "
        "HD63484's own register set. It is write-only.",
        styles["CZBody"]))
    mode_headers = ["Bit", "Name", "Description"]
    mode_rows = [
        ["0", "HSPOL", "Horizontal sync polarity: 0 = positive sync pulse, 1 = negative sync pulse"],
        ["1", "VSPOL", "Vertical sync polarity: 0 = positive sync pulse, 1 = negative sync pulse"],
        ["2", "AMODE", "Address mode: 0 = single access mode, 1 = interleaved access mode"],
        ["3", "OLEN", "Overlay enable: 0 = overlay plane blanked (shift register loads zeros), "
                       "1 = overlay pixels displayed over the frame buffer"],
        ["4", "OLSEL", "Overlay select: 0 = lower half, 1 = upper half of the overlay memory "
                        "&mdash; selects which 64K-word half of the 128K-word overlay SRAM a "
                        "drawing-mode CHR screen addresses"],
        ["5&ndash;7", "&mdash;", "Reserved, write as 0"],
    ]
    story.append(make_table(mode_headers, mode_rows, [0.6 * inch, 0.9 * inch, 4.5 * inch]))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "The overlay (U19, 1 bit per pixel, mapped 1:1 onto frame-buffer pixels) "
        "is drawn by targeting an ACRTC screen with the CHR bit set in its Memory "
        "Width register. A CHR screen only has a 64K-word address space, so OLSEL "
        "selects which 64K-word half of the 128K-word overlay SRAM that screen "
        "addresses. OLSEL is cleared to 0 by reset. A CHR screen must never be "
        "displayed &mdash; overlay display is driven by the frame buffer's own "
        "display cycles, independent of OLSEL.",
        styles["CZNote"]))

    # --- 4. SW1 Configuration DIP Switch ---
    story.append(Paragraph("4. Configuration DIP Switch (SW1)", styles["CZH1"]))
    story.append(Paragraph(
        "SW1 is an 8-position DIP switch that sets the board's I/O base address "
        "and host interface options.",
        styles["CZBody"]))
    sw_headers = ["Switch", "Function", "On", "Off"]
    sw_rows = [
        ["SW1-1 &ndash; SW1-5", "I/O base address (address bits 7:3)",
         "&mdash;", "&mdash;"],
        ["SW1-6", "HD63484 host bus width",
         "8-bit host interface: DACK* follows RESET*, so it is low during reset",
         "16-bit host interface: DACK* is pulled high"],
        ["SW1-7", "16-bit address decode enable",
         "Decodes the full 16-bit I/O address (A15&ndash;A8 must be 00h)",
         "Decodes only the 8-bit I/O address"],
        ["SW1-8", "Interrupt enable",
         "HD63484 interrupt request connected to the S-100 bus",
         "Interrupt request disconnected from the S-100 bus"],
    ]
    story.append(make_table(sw_headers, sw_rows,
                             [1.05 * inch, 1.35 * inch, 1.85 * inch, 1.85 * inch]))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "SW1-1 through SW1-5 map directly to address bits 7 down to 3 of the "
        "board's I/O base address; the low three address bits (2:0) are fixed "
        "at zero, so the board's registers always occupy an 8-byte-aligned "
        "block (Base + 0 through Base + 7) somewhere in the 256-byte S-100 "
        "8-bit I/O space.",
        styles["CZNote"]))

    # --- 5. Frame Buffer ---
    story.append(Paragraph("5. Frame Buffer", styles["CZH1"]))
    fb_headers = ["Property", "Value"]
    fb_rows = [
        ["Memory type", "2 MBytes of SRAM &mdash; no refresh cycles required"],
        ["Pixel depth", "8 bits per pixel only"],
        ["Graphics Address Increment (GAI)", "8"],
        ["Maximum display resolution", "1024 &times; 768"],
    ]
    story.append(make_table(fb_headers, fb_rows, [2.6 * inch, 3.4 * inch]))

    # --- 6. Feature Support Summary ---
    story.append(Paragraph("6. HD63484 Feature Support Summary", styles["CZH1"]))
    story.append(Paragraph(
        "CADzilla implements a deliberately reduced subset of the HD63484's "
        "capabilities, matched to the board's fixed 8-bit-per-pixel, "
        "SRAM-based frame buffer. The table below summarizes what is and is "
        "not supported.",
        styles["CZBody"]))
    feat_headers = ["Feature", "Status"]
    feat_rows = [
        ["Pixel depth", "8 bits per pixel only (GAI = 8)"],
        ["Frame buffer refresh", "Not required (SRAM frame buffer)"],
        ["Cursors", "Not supported"],
        ["Superimposed (dual-screen) access mode", "Not supported"],
        ["Light pen", "Not supported"],
        ["Zooming", "Not supported"],
        ["Video attributes", "Not supported"],
        ["External sync", "Not supported"],
        ["DMA transfers", "Not supported"],
        ["Interrupts", "Supported (enabled via SW1-8, see Section 4)"],
    ]
    story.append(make_table(feat_headers, feat_rows, [3.6 * inch, 2.4 * inch]))

    # --- 7. Revision History ---
    story.append(Paragraph("7. Revision History", styles["CZH1"]))
    rev_headers = ["Revision", "Date", "Notes"]
    rev_rows = [
        ["1.0", "2026-09-23", "Initial I/O map, MODE register, SW1, and feature support documentation."],
        ["1.1", "2026-09-24", "Added Preface with the board's design philosophy; renamed manual title."],
        ["1.2", "2026-10-01",
         "Corrected SW1-6: it selects HD63484 host bus width directly (On = 8-bit, "
         "DACK* follows RESET*; Off = 16-bit, DACK* pulled high), not a reset-time "
         "mode select. Clarified SW1-7's A15-A8 = 00h requirement. Documented MODE "
         "register bit 4 (OLSEL), which selects the upper or lower half of the "
         "overlay memory for drawing access, and resolved OLEN's prior TBD status."],
    ]
    story.append(make_table(rev_headers, rev_rows, [0.9 * inch, 0.9 * inch, 4.2 * inch]))

    doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
    print("wrote", OUT)


if __name__ == "__main__":
    build()
