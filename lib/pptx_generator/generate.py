#!/usr/bin/env python3
# Source: Noto Sans SC TTF bundled from Google Fonts (noto-cjk), converted to TTF via fonttools.
# Font is physically embedded into each .pptx output so it renders on Windows projectors
# without requiring font installation.

import base64
import json
import os
import sys
import tempfile
import zipfile

from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Inches, Pt
from lxml import etree

FONT_SIZE_MAP = {"small": 28, "medium": 36, "large": 48}
FONT_NAME = "Noto Sans SC"
FONT_PATH = os.path.join(os.path.dirname(__file__), "fonts", "NotoSansSC-Regular.ttf")
FONT_ZIP_NAME = "ppt/fonts/NotoSansSC-Regular.ttf"


def hex_to_rgb(hex_color):
    """Parse a hex color string (#rrggbb) into an RGBColor."""
    h = hex_color.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return RGBColor(r, g, b)


def set_ea_font(run, typeface):
    """Set the East Asian font element on a run's rPr so PowerPoint routes CJK glyphs correctly."""
    rPr = run._r.get_or_add_rPr()
    ea_elem = rPr.find(qn("a:ea"))
    if ea_elem is None:
        ea_elem = etree.SubElement(rPr, qn("a:ea"))
    ea_elem.set("typeface", typeface)


def add_slide(prs, slide_data, theme):
    """Add a single content slide to the presentation."""
    blank_layout = prs.slide_layouts[6]  # blank layout
    slide = prs.slides.add_slide(blank_layout)

    # Set background color
    bg_rgb = hex_to_rgb(theme["background_color"])
    background = slide.background
    fill = background.fill
    fill.solid()
    fill.fore_color.rgb = bg_rgb

    # Handle optional background image
    bg_b64 = theme.get("background_image_base64")
    if bg_b64:
        img_bytes = base64.b64decode(bg_b64)
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp_img:
            tmp_img.write(img_bytes)
            tmp_img_path = tmp_img.name
        try:
            slide.shapes.add_picture(
                tmp_img_path,
                Inches(0), Inches(0),
                width=prs.slide_width,
                height=prs.slide_height,
            )
        finally:
            if os.path.exists(tmp_img_path):
                os.unlink(tmp_img_path)

    # Determine font sizes
    font_size_key = theme.get("font_size", "medium")
    chinese_pt = FONT_SIZE_MAP.get(font_size_key, FONT_SIZE_MAP["medium"])
    pinyin_pt = round(chinese_pt * 0.6)
    text_rgb = hex_to_rgb(theme["text_color"])

    # Text box: 10% margins, 80% width/height
    slide_w = prs.slide_width
    slide_h = prs.slide_height
    margin = 0.1
    txBox = slide.shapes.add_textbox(
        left=int(slide_w * margin),
        top=int(slide_h * margin),
        width=int(slide_w * 0.8),
        height=int(slide_h * 0.8),
    )
    tf = txBox.text_frame
    tf.word_wrap = True

    content = slide_data.get("content", "")
    pinyin = slide_data.get("pinyin", "")

    # Interleave pinyin above each Chinese line, matching the preview's ruby-annotation layout
    first_para = True

    def add_text_paragraph(text_lines, font_pt, is_first):
        nonlocal first_para
        for i, line in enumerate(text_lines):
            if is_first and i == 0:
                para = tf.paragraphs[0]
                is_first = False
            else:
                para = tf.add_paragraph()
            para.alignment = PP_ALIGN.CENTER
            run = para.add_run()
            run.text = line
            run.font.name = FONT_NAME
            run.font.size = Pt(font_pt)
            run.font.color.rgb = text_rgb
            set_ea_font(run, FONT_NAME)
        return is_first

    content_lines = content.split("\n") if content else []
    pinyin_lines = pinyin.split("\n") if pinyin else []

    for i, chinese_line in enumerate(content_lines):
        p_line = pinyin_lines[i] if i < len(pinyin_lines) else ""
        if p_line:
            first_para = add_text_paragraph([p_line], pinyin_pt, first_para)
        if chinese_line:
            first_para = add_text_paragraph([chinese_line], chinese_pt, first_para)


def embed_cjk_font(pptx_path):
    """Post-process the .pptx ZIP to embed the Noto Sans SC TTF binary.

    Steps:
    1. Read the saved .pptx into memory as a ZIP
    2. Add ppt/fonts/NotoSansSC-Regular.ttf from the bundled font file
    3. Update [Content_Types].xml to register the font part
    4. Add a relationship in ppt/_rels/presentation.xml.rels pointing to the font
    5. Write the modified ZIP back to pptx_path (via a temp file to avoid corruption)
    """
    tmp_path = pptx_path + ".tmp"
    with zipfile.ZipFile(pptx_path, "r") as zin, \
         zipfile.ZipFile(tmp_path, "w", compression=zipfile.ZIP_DEFLATED) as zout:

        existing_names = set(zin.namelist())

        # Copy all existing entries, patching XML where needed
        for item in zin.infolist():
            data = zin.read(item.filename)

            if item.filename == "[Content_Types].xml":
                # Register the font part type if not already present
                font_override = (
                    '<Override PartName="/ppt/fonts/NotoSansSC-Regular.ttf" '
                    'ContentType="application/x-fontdata"/>'
                )
                if b"NotoSansSC" not in data:
                    data = data.replace(b"</Types>", font_override.encode() + b"</Types>")

            elif item.filename == "ppt/_rels/presentation.xml.rels":
                # Add a font relationship if not already present
                font_rel = (
                    '<Relationship Id="rFontNoto" '
                    'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/font" '
                    'Target="fonts/NotoSansSC-Regular.ttf"/>'
                )
                if b"NotoSansSC" not in data:
                    data = data.replace(b"</Relationships>", font_rel.encode() + b"</Relationships>")

            zout.writestr(item, data)

        # Add the font binary (skip if somehow already present)
        if FONT_ZIP_NAME not in existing_names:
            zout.write(FONT_PATH, FONT_ZIP_NAME)

    # Replace original with modified
    os.replace(tmp_path, pptx_path)


def main():
    try:
        payload = json.loads(sys.stdin.read())
        deck = payload["deck"]
        output_path = payload["output_path"]
        theme = deck["theme"]

        # Validate output directory exists
        out_dir = os.path.dirname(os.path.abspath(output_path))
        if not os.path.isdir(out_dir):
            raise FileNotFoundError(f"Output directory does not exist: {out_dir}")

        # Create presentation (16:9 widescreen)
        prs = Presentation()
        prs.slide_width = Inches(13.33)
        prs.slide_height = Inches(7.5)

        # Add slides for each song's lyric blocks
        for song in deck.get("songs", []):
            for slide_data in song.get("slides", []):
                add_slide(prs, slide_data, theme)

        prs.save(output_path)
        embed_cjk_font(output_path)

    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
