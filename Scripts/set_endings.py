"""画の終わり方（とめ・はね・はらい）の下書きを、文字のデータに書き込む（D145）。

教科書でよく教える終わり方を、人の手で表にしたもの。迷う画は None にして、ヒントを出さない。
人が確かめるまでは下書き（D66）。
はねは、お手本の線に急なかどがある画だけにする（なだらかな J 字のはね〔か・も・ふ〕や、く の字に折れる画〔ふ・や〕は、
書いた線から見分けられないので None。D192）。データを作り直したら、もう一度動かす。

使い方: python3 -I Scripts/set_endings.py Content/Packs/hira
"""

import json
import sys
from pathlib import Path

T, N, R = "tome", "hane", "harai"

# M0 の字（PackLibrary.m0Characters）。
ENDINGS = {
    "そ": [R],
    "り": [N, R],
    "く": [T],
    "る": [T],
    "ま": [T, T, T],
    "ふ": [None, None, None, T],
    "ね": [T, T],
    "て": [None],
    "ん": [None],
    "し": [R],
    "や": [None, None, None],
    "か": [None, T, T],
    "せ": [T, N, T],
    "う": [T, R],
    "い": [N, T],
    "ぬ": [T, T],
    "こ": [N, T],
    "す": [T, R],
    "ほ": [N, T, T, None],
    "ゆ": [None, R],
    "た": [T, R, T, T],
    "つ": [R],
    "き": [T, T, N, T],
    "も": [None, T, T],
    "の": [R],
    "で": [None, T, T],
    "じ": [R, T, T],
    "ぼ": [N, T, T, None, T, T],
}


def main():
    folder = Path(sys.argv[1])
    for char, ends in ENDINGS.items():
        path = folder / f"hira.{ord(char):04x}.json"
        data = json.loads(path.read_text())
        if len(data["strokes"]) != len(ends):
            raise SystemExit(f"{char}: 画数 {len(data['strokes'])} と表 {len(ends)} が合わない")
        for stroke, end in zip(data["strokes"], ends):
            stroke["end"] = end
        path.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n")
    print(f"{len(ENDINGS)} 字に終わり方の下書きを書き込んだ")


if __name__ == "__main__":
    main()
