#!/usr/bin/env python3
"""子どもの画面の書体（D153）を、アプリで使う字だけに減らす。

使い方（fonttools が入った python で。アプリには入らない道具）:
  python3 -I Scripts/subset_fonts.py <google/fonts の ofl フォルダ> App/Mojimachi/Resources/Fonts

<ofl フォルダ> には kleeone/ と zenmarugothic/ がある（https://github.com/google/fonts の ofl/）。
入れる字:
  - ひらがな・カタカナ全部（小さい字・濁音・ー を含む）、ASCII の記号と英数字、日本語の句読点と記号
  - App/ と Packages/Sources/ の Swift の文字列に出てくる字（かな・漢字）
  - Content/Packs の文字の見出しの字
OFL は予約された名前（RFN）がなく、字を減らして配ることができる。
"""

import re
import sys
from pathlib import Path

from fontTools import subset

FONTS = [
    ("kleeone", "KleeOne-Regular"),
    ("kleeone", "KleeOne-SemiBold"),
    ("zenmarugothic", "ZenMaruGothic-Medium"),
    ("zenmarugothic", "ZenMaruGothic-Bold"),
]

# 文字列のリテラル（"..." の中。エスケープ込み）。
LITERAL = re.compile(r'"((?:[^"\\\n]|\\.)*)"')
# かな・漢字・全角記号（ASCII は別に全部入れる）。
NON_ASCII = re.compile(r"[^\x00-\x7f]")


def swift_strings(root: Path) -> str:
    texts = []
    for path in sorted(root.rglob("*.swift")):
        if ".build" in path.parts:
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            texts.extend(LITERAL.findall(line))
    return "".join(texts)


def needed_characters(repo: Path) -> str:
    chars = set()
    # ひらがな・カタカナ（ぁ〜ゖ、ァ〜ヺ、ー、ゝゞヽヾ）。
    chars.update(chr(c) for c in range(0x3041, 0x3097))
    chars.update(chr(c) for c in range(0x30A1, 0x30FB))
    chars.update("ーゝゞヽヾ")
    # ASCII（空白から ~ まで）。
    chars.update(chr(c) for c in range(0x20, 0x7F))
    # 日本語の句読点と記号。
    chars.update("、。，．・：；？！゛゜「」『』（）［］【】〜～…‥―ー　×○◯●◎★☆♪→←↑↓＜＞＋－＝")
    # 画面の文字列（アプリと部品）。
    for sub in ("App", "Packages/Sources"):
        chars.update(NON_ASCII.findall(swift_strings(repo / sub)))
    # 文字のデータの字（ファイル名 hira.3042.json などの字）。
    for pack in sorted((repo / "Content/Packs").glob("*/*.json")):
        m = re.match(r"^[a-z]+\.([0-9a-f]{4,5})\.json$", pack.name)
        if m:
            chars.add(chr(int(m.group(1), 16)))
    # 制御文字・サロゲートなど、字でないものは外す。
    return "".join(sorted(c for c in chars if c.isprintable() or c == "　"))


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    source, out = Path(sys.argv[1]), Path(sys.argv[2])
    repo = Path(__file__).resolve().parent.parent
    text = needed_characters(repo)
    out.mkdir(parents=True, exist_ok=True)
    print(f"字の数: {len(text)}")
    for folder, name in FONTS:
        options = subset.Options()
        # 使う機能だけ残す（全部残すと関連する別の字形まで入って大きくなる）。
        options.layout_features = ["kern", "palt", "vert", "vkrn", "vpal", "locl", "ccmp"]
        options.name_IDs = ["*"]
        options.notdef_outline = True
        options.glyph_names = False
        options.hinting = False
        options.desubroutinize = True
        font = subset.load_font(str(source / folder / f"{name}.ttf"), options)
        subsetter = subset.Subsetter(options)
        subsetter.populate(text=text)
        subsetter.subset(font)
        target = out / f"{name}.ttf"
        subset.save_font(font, str(target), options)
        print(f"{target.name}: {target.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
