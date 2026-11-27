"""左右を反転しても形が変わらない字に、鏡の字を見分けない印（mirrorCheck=false）を付ける（D107・D192）。

「ー」「ニ」のようにまっすぐな線だけの字は、少し傾くと鏡に映した形と見分けられず、
正しく書いても「鏡の字」になってしまう。データを作り直したら、もう一度動かす。

使い方: python3 -I Scripts/set_mirror_check.py Content/Packs
"""

import json
import sys
from pathlib import Path

# (パック, 字)。アルファベットと数字の印は make_abc.py が付ける。
SYMMETRIC = [("kata", "ー"), ("kata", "ニ")]


def main():
    packs = Path(sys.argv[1])
    for pack, char in SYMMETRIC:
        path = packs / pack / f"{pack}.{ord(char):04x}.json"
        data = json.loads(path.read_text())
        data["mirrorCheck"] = False
        path.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n")
        print(f"{char} は鏡の字を見ない")


if __name__ == "__main__":
    main()
