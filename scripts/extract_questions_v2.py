#!/usr/bin/env python3
import os
import re
import json
import urllib.request
import tempfile
import fitz  # pymupdf
import pdfplumber

PDF_URL = "https://ws.thb.gov.tw/Download.ashx?u=LzAwMS9VcGxvYWQvNDM2L3JlbGZpbGUvMTI4MjMvMzAwMDQzLzNlNTY4MzA4LTcxZjctNDMzZC04NDg5LTVjYTZmYTQ0ODY5MS5wZGY%3d&n=5rG96LuK562G6Kmm6aGM5bqrX%2bWFrOWRijExNS4wNi45LnBkZg%3d%3d&icon=..pdf"

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "questions", "v2")
IMAGES_DIR = os.path.join(OUTPUT_DIR, "images")

ARCHITECTURE_MAP = {
    (1, 424): "架構一 正確觀念與態度",
    (425, 654): "架構二 主動停讓文化",
    (655, 1090): "架構三 安全駕駛能力"
}

def get_architecture(qnum):
    for (start, end), arch in ARCHITECTURE_MAP.items():
        if start <= qnum <= end:
            return arch
    return ""

def parse_options(text):
    normalized = text.replace('（', '(').replace('）', ')')
    normalized = normalized.replace('１', '1').replace('２', '2').replace('３', '3')

    matches = list(re.finditer(r'\(([1-3])\)', normalized))
    if not matches:
        return {}

    options = {}
    for i, match in enumerate(matches):
        opt_num = match.group(1)
        start = match.end()
        end = matches[i+1].start() if i+1 < len(matches) else len(normalized)
        opt_text = normalized[start:end].strip()
        options[opt_num] = opt_text

    return options

def download_pdf(url, dest_path):
    print(f"Downloading PDF from {url}...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response, open(dest_path, 'wb') as out_file:
        out_file.write(response.read())
    print(f"PDF downloaded to {dest_path}")

def process_pdf(pdf_path):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(IMAGES_DIR, exist_ok=True)

    doc = fitz.open(pdf_path)
    print(f"Opened PDF with {len(doc)} pages.")

    questions = []
    current_q = None

    with pdfplumber.open(pdf_path) as pdf:
        for page_idx, page in enumerate(pdf.pages):
            fitz_page = doc[page_idx]
            page_images = fitz_page.get_image_info(hashes=False, xrefs=True)

            tabs = page.find_tables()
            for tab in tabs:
                extracted = tab.extract()
                for row_obj, row_data in zip(tab.rows, extracted):
                    if not row_data:
                        continue

                    c0 = (row_data[0] or '').strip()
                    c1 = (row_data[1] or '').strip() if len(row_data) > 1 else ''
                    text_part = (row_data[-1] or '').strip() if len(row_data) > 2 else ''

                    if len(row_data) > 3:
                        text_part = ' '.join(c.strip() for c in row_data[2:] if c and c.strip())

                    if c0.isdigit():
                        qnum = int(c0)
                        top = row_obj.bbox[1]
                        bottom = row_obj.bbox[3]

                        matched_imgs = []
                        for img in page_images:
                            cy = (img['bbox'][1] + img['bbox'][3]) / 2
                            if top - 2 <= cy <= bottom + 2:
                                matched_imgs.append(img)
                        matched_imgs.sort(key=lambda img: (img['bbox'][1], img['bbox'][0]))

                        ans_clean = c1.replace('(', '').replace(')', '').strip()
                        raw_ans = c1
                        if not ans_clean:
                            m = re.match(r'^\s*\(([1-3])\)\s*', text_part)
                            if m:
                                ans_clean = m.group(1)
                                raw_ans = f"({ans_clean})"
                                text_part = text_part[m.end():].strip()

                        current_q = {
                            'num': qnum,
                            'answer': ans_clean,
                            'raw_answer': raw_ans,
                            'text_parts': [text_part] if text_part else [],
                            'images_info': list(matched_imgs),
                            'page': page_idx + 1,
                            'architecture': get_architecture(qnum)
                        }
                        questions.append(current_q)
                    elif current_q is not None and c0 == '':
                        if text_part:
                            current_q['text_parts'].append(text_part)

    print(f"Extracted {len(questions)} questions.")

    total_images_extracted = 0
    for q in questions:
        q['text'] = ' '.join(q['text_parts']).strip()
        del q['text_parts']
        q['options'] = parse_options(q['text'])

        img_rel_paths = []
        num_imgs = len(q['images_info'])
        for idx, img_info in enumerate(q['images_info']):
            xref = img_info['xref']
            pix = fitz.Pixmap(doc, xref)
            if pix.n >= 5 or pix.colorspace.name == 'DeviceGray':
                pix = fitz.Pixmap(fitz.csRGB, pix)

            if num_imgs == 1:
                fname = f"{q['num']}.png"
            else:
                fname = f"{q['num']}_{idx+1}.png"

            fpath = os.path.join(IMAGES_DIR, fname)
            pix.save(fpath)
            img_rel_paths.append(f"images/{fname}")
            total_images_extracted += 1

        q['images'] = img_rel_paths
        del q['images_info']

    print(f"Extracted {total_images_extracted} images into {IMAGES_DIR}.")

    # Write questions.json
    json_path = os.path.join(OUTPUT_DIR, "questions.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)
    print(f"Saved {json_path}")

    # Write questions.txt
    txt_path = os.path.join(OUTPUT_DIR, "questions.txt")
    with open(txt_path, "w", encoding="utf-8") as f:
        for q in questions:
            # Format: QNUM ANSWER TEXT
            f.write(f"{q['num']:04d} {q['answer']} {q['text']}\n")
    print(f"Saved {txt_path}")

def main():
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp_file:
        tmp_pdf_path = tmp_file.name

    try:
        download_pdf(PDF_URL, tmp_pdf_path)
        process_pdf(tmp_pdf_path)
    finally:
        if os.path.exists(tmp_pdf_path):
            os.remove(tmp_pdf_path)

if __name__ == "__main__":
    main()
