import json
import os
import re
import time

import requests
from bs4 import BeautifulSoup

# ------------------------------------------------------
# Bible structure for جميع الأسفار (66 Books)
# ------------------------------------------------------
# Format: "BOOK_CODE": (Number of chapters)
BIBLE_STRUCTURE = {
    "GEN": 50, "EXO": 40, "LEV": 27, "NUM": 36, "DEU": 34,
    "JOS": 24, "JDG": 21, "RUT": 4,  "1SA": 31, "2SA": 24,
    "1KI": 22, "2KI": 25, "1CH": 29, "2CH": 36, "EZR": 10,
    "NEH": 13, "EST": 10, "JOB": 42, "PSA": 150, "PRO": 31,
    "ECC": 12, "SNG": 8,  "ISA": 66, "JER": 52, "LAM": 5,
    "EZK": 48, "DAN": 12, "HOS": 14, "JOL": 3,  "AMO": 9,
    "OBA": 1,  "JON": 4,  "MIC": 7,  "NAM": 3,  "HAB": 3,
    "ZEP": 3,  "HAG": 2,  "ZEC": 14, "MAL": 4,
    "MAT": 28, "MRK": 16, "LUK": 24, "JHN": 21, "ACT": 28,
    "ROM": 16, "1CO": 16, "2CO": 13, "GAL": 6,  "EPH": 6,
    "PHP": 4,  "COL": 4,  "1TH": 5,  "2TH": 3,  "1TI": 6,
    "2TI": 4,  "TIT": 3,  "PHM": 1,  "HEB": 13, "JAS": 5,
    "1PE": 5,  "2PE": 3,  "1JN": 5,  "2JN": 1,  "3JN": 1,
    "JUD": 1,  "REV": 22
}

TRANSLATION = 67  # المشتركة translation ID

# ------------------------------------------------------
# Cleaning Arabic text
# ------------------------------------------------------
def clean_arabic(text):
    text = re.sub(r"[\u200b\u200c\u200d\u200e\u200f]", "", text)
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s+([،.؟])", r"\1", text)
    return text.strip()

# ------------------------------------------------------
# Extract verses: (verse number + text)
# ------------------------------------------------------
def extract_verses(text):
    pattern = r"(\d+)\s+([^0-9]+)"
    matches = re.findall(pattern, text)
    return {num: t.strip() for num, t in matches}

# ------------------------------------------------------
# Start scraping everything
# ------------------------------------------------------
os.makedirs("output", exist_ok=True)

for book, total_chapters in BIBLE_STRUCTURE.items():
    print(f"\n📘 BOOK: {book} ({total_chapters} chapters)")
    for chapter in range(1, total_chapters + 1):

        url = f"https://www.bible.com/ar/bible/{TRANSLATION}/{book}.{chapter}.%D8%A7%D9%84%D9%85%D8%B4%D8%AA%D8%B1%D9%83%D8%A9"

        print(f"   → Fetching {book} {chapter} ...")

        try:
            html = requests.get(url).text
        except:
            print("     ❌ Connection Error, retrying...")
            time.sleep(2)
            continue

        soup = BeautifulSoup(html, "html.parser")
        data_attr = f"{book}.{chapter}"

        chapter_div = soup.find("div", {"data-usfm": data_attr})
        if not chapter_div:
            print(f"     ❌ Not found — skipping.")
            continue

        raw = chapter_div.get_text(" ", strip=True)
        cleaned = clean_arabic(raw)
        verses = extract_verses(cleaned)

        # Save as JSON
        output = {
            "book": book,
            "chapter": chapter,
            "verses": verses
        }

        filename = f"bible/output/{book}_{chapter}.json"
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(output, f, ensure_ascii=False, indent=4)

        print(f"     ✔ Saved {filename}")

        # Gentle delay to avoid rate-limiting
        time.sleep(0.3)

print("\n🎉 DONE! Full Bible downloaded — JSON created for every chapter.")
