#!/usr/bin/env python3
import os
import re
import json
import urllib.request
import tempfile
import pymupdf  # fitz
import pdfplumber

QUESTION_SOURCES = {
    ("car", "zh"): {
        "url": "https://ws.thb.gov.tw/Download.ashx?u=LzAwMS9VcGxvYWQvNDM2L3JlbGZpbGUvMTI4MjMvMzAwMDQzLzNlNTY4MzA4LTcxZjctNDMzZC04NDg5LTVjYTZmYTQ0ODY5MS5wZGY%3d&n=5rG96LuK562G6Kmm6aGM5bqrX%2bWFrOWRijExNS4wNi45LnBkZg%3d%3d&icon=..pdf",
        "total_questions": 1090,
        "architectures": [
            ((1, 424), "架構一 正確觀念與態度"),
            ((425, 654), "架構二 主動停讓文化"),
            ((655, 1090), "架構三 安全駕駛能力")
        ]
    },
    ("car", "en"): {
        "url": "https://ws.thb.gov.tw/Download.ashx?u=LzAwMS9VcGxvYWQvNDM2L3JlbGZpbGUvMTI4MjMvMzAwMDQyL2ZlMzk5YjE4LTBlZWItNDVlZC1hYWQzLTIzZDY4ZmQ4N2Y4Yi5wZGY%3d&n=5rG96LuK562G6Kmm6aGM5bqrX%2biLseaWh%2bWujOaVtOeJiF8xMTXlubRf5ZCr5ZyW56S6XzEwOTDpoYwucGRm&icon=..pdf",
        "total_questions": 1090,
        "architectures": [
            ((1, 424), "SECTION 1 CORRECT CONCEPTS AND ETHICS"),
            ((425, 654), "SECTION 2 PROACTIVE YIELDING CULTURE"),
            ((655, 1090), "SECTION 3 SAFE DRIVING ABILITY")
        ]
    },
    ("motorcycle", "zh"): {
        "url": "https://ws.thb.gov.tw/Download.ashx?u=LzAwMS9VcGxvYWQvNDM2L3JlbGZpbGUvMTI4MjMvMjg5NzYwLzY0YjU0ODk2LWZlMDctNDZiNS1iNzVkLWY5ZmIxZGUwMTM1Zi5wZGY%3d&n=5qmf6LuK6aeV54Wn562G6Kmm6aGM5bqrKOWFqOmDqDgwNOmhjCktMTE1MDIxOC5wZGY%3d&icon=..pdf",
        "total_questions": 806,
        "architectures": [
            ((1, 480), "架構一 正確觀念與態度"),
            ((481, 572), "架構二 主動停讓文化"),
            ((573, 806), "架構三 安全駕駛能力")
        ]
    },
    ("motorcycle", "en"): {
        "url": "https://ws.thb.gov.tw/Download.ashx?u=LzAwMS9VcGxvYWQvNDM2L3JlbGZpbGUvMTI4MjMvMjg5NzU5LzBkNzIwZjk1LTIzNDItNGVhNC1hZTQyLTQ0Nzk4YTNkNWFhNC5wZGY%3d&n=TW90b3JjeWNsZV9MaWNlbnNlX1dyaXR0ZW5fVGVzdF9RdWVzdGlvbl9CYW5rX0VuZ2xpc2gwMTI3LnBkZg%3d%3d&icon=..pdf",
        "total_questions": 806,
        "architectures": [
            ((1, 480), "SECTION 1 CORRECT CONCEPTS AND ETHICS"),
            ((481, 572), "SECTION 2 PROACTIVE YIELDING CULTURE"),
            ((573, 806), "SECTION 3 SAFE DRIVING ABILITY")
        ]
    }
}

BASE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "questions", "v2")

def get_architecture(qnum, arch_list):
    for (start, end), arch in arch_list:
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
    print(f"Downloaded to {dest_path}")

def process_pdf(pdf_path, vehicle_type, lang, cfg):
    output_dir = os.path.join(BASE_DIR, vehicle_type, lang)
    images_dir = os.path.join(output_dir, "images")
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(images_dir, exist_ok=True)

    doc = pymupdf.open(pdf_path)
    print(f"Processing {vehicle_type}/{lang}: {len(doc)} pages.")

    questions = []
    is_motorcycle_zh = (vehicle_type == "motorcycle" and lang == "zh")

    with pdfplumber.open(pdf_path) as pdf:
        for page_idx, page in enumerate(pdf.pages):
            fitz_page = doc[page_idx]
            page_images = fitz_page.get_image_info(hashes=False, xrefs=True)

            tabs = page.find_tables()
            for tab in tabs:
                extracted = tab.extract()
                for i, (row_obj, row_data) in enumerate(zip(tab.rows, extracted)):
                    if not row_data:
                        continue

                    non_empty = [c.strip() for c in row_data if c and c.strip()]
                    if not non_empty:
                        continue

                    c0 = (row_data[0] or '').strip()
                    c1 = (row_data[1] or '').strip() if len(row_data) > 1 else ''

                    if c0.isdigit():
                        qnum = int(c0)
                        ans = c1

                        # motorcycle_zh split row check where answer is in the row below
                        if not ans and is_motorcycle_zh and i + 1 < len(extracted):
                            next_row = extracted[i+1]
                            if next_row and len(next_row) > 1:
                                next_c0 = (next_row[0] or '').strip()
                                next_c1 = (next_row[1] or '').strip()
                                if next_c0 == '' and next_c1.isdigit():
                                    ans = next_c1

                        rest_cells = [c.strip() for c in row_data[1:] if c and c.strip()]
                        if not ans and rest_cells:
                            first_rest = rest_cells[0]
                            if first_rest.isdigit() or (first_rest.startswith('(') and first_rest.endswith(')') and first_rest[1:-1].isdigit()):
                                ans = first_rest
                                rest_cells = rest_cells[1:]

                        text_part = ' '.join(rest_cells)
                        ans_clean = ans.replace('(', '').replace(')', '').strip()
                        raw_ans = ans

                        if not ans_clean:
                            m = re.match(r'^\s*\(([1-3])\)\s*', text_part)
                            if m:
                                ans_clean = m.group(1)
                                raw_ans = f"({ans_clean})"
                                text_part = text_part[m.end():].strip()

                        top = row_obj.bbox[1]
                        bottom = row_obj.bbox[3]
                        matched_imgs = []
                        for img in page_images:
                            cy = (img['bbox'][1] + img['bbox'][3]) / 2
                            if top - 2 <= cy <= bottom + 2:
                                matched_imgs.append(img)
                        matched_imgs.sort(key=lambda img: (img['bbox'][1], img['bbox'][0]))

                        questions.append({
                            'num': qnum,
                            'answer': ans_clean,
                            'raw_answer': raw_ans,
                            'text_parts': [text_part] if text_part else [],
                            'images_info': matched_imgs,
                            'page': page_idx + 1,
                            'architecture': get_architecture(qnum, cfg["architectures"])
                        })
                    elif questions and c0 == '' and not (is_motorcycle_zh and c1.isdigit()):
                        text_part = ' '.join(c.strip() for c in row_data[1:] if c and c.strip())
                        if text_part:
                            questions[-1]['text_parts'].append(text_part)

    print(f"Extracted {len(questions)} questions for {vehicle_type}/{lang}.")

    total_images_extracted = 0
    for q in questions:
        q['text'] = ' '.join(' '.join(q['text_parts']).split()).strip()
        del q['text_parts']
        q['options'] = parse_options(q['text'])

        img_rel_paths = []
        num_imgs = len(q['images_info'])
        for idx, img_info in enumerate(q['images_info']):
            xref = img_info['xref']
            pix = pymupdf.Pixmap(doc, xref)
            if pix.n >= 5 or pix.colorspace.name == 'DeviceGray':
                pix = pymupdf.Pixmap(pymupdf.csRGB, pix)

            if num_imgs == 1:
                fname = f"{q['num']}.png"
            else:
                fname = f"{q['num']}_{idx+1}.png"

            fpath = os.path.join(images_dir, fname)
            pix.save(fpath)
            img_rel_paths.append(f"images/{fname}")
            total_images_extracted += 1

        q['images'] = img_rel_paths
        del q['images_info']

    print(f"Saved {total_images_extracted} images to {images_dir}.")

    # Write questions.json
    json_path = os.path.join(output_dir, "questions.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)
    print(f"Saved {json_path}")

    # Write questions.txt
    txt_path = os.path.join(output_dir, "questions.txt")
    with open(txt_path, "w", encoding="utf-8") as f:
        for q in questions:
            f.write(f"{q['num']:04d} {q['answer']} {q['text']}\n")
    print(f"Saved {txt_path}")

def main():
    for (vehicle_type, lang), cfg in QUESTION_SOURCES.items():
        with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp_file:
            tmp_pdf_path = tmp_file.name

        try:
            download_pdf(cfg["url"], tmp_pdf_path)
            process_pdf(tmp_pdf_path, vehicle_type, lang, cfg)
        finally:
            if os.path.exists(tmp_pdf_path):
                os.remove(tmp_pdf_path)

if __name__ == "__main__":
    main()
