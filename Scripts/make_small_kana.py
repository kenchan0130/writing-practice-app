"""strokesvg にない小さい字（っ・ッ）を、元の字を縮めて作る。

strokesvg の小さい字（ゃ・ゅ・ャ など）は、元の字のおよそ 0.75 倍で、
下を y=890 あたりにそろえ、横は真ん中に置かれている。同じ置き方で作る。

使い方: python3 -I Scripts/make_small_kana.py Content/Packs
"""

import json
import sys
from pathlib import Path

SCALE = 0.75
BOTTOM = 890
CENTER_X = 500

# 作る字: (パック, 元の字, 小さい字)
TARGETS = [("hira", "つ", "っ"), ("kata", "ツ", "ッ")]


def points(data):
    for stroke in data["strokes"]:
        yield stroke["start"]
        for seg in stroke["segments"]:
            for i in range(0, len(seg), 2):
                yield seg[i : i + 2]


def make(base):
    xs, ys = zip(*points(base))
    cx = (min(xs) + max(xs)) / 2
    bottom = max(ys)

    def tx(x):
        return round((x - cx) * SCALE + CENTER_X)

    def ty(y):
        return round((y - bottom) * SCALE + BOTTOM)

    def pair_list(values):
        return [tx(v) if i % 2 == 0 else ty(v) for i, v in enumerate(values)]

    strokes = []
    for stroke in base["strokes"]:
        new = dict(stroke)
        new["start"] = pair_list(stroke["start"])
        new["segments"] = [pair_list(s) for s in stroke["segments"]]
        if stroke.get("outline"):
            new["outline"] = [
                {"start": pair_list(sub["start"]), "segments": [pair_list(s) for s in sub["segments"]]}
                for sub in stroke["outline"]
            ]
        strokes.append(new)
    return strokes


def main():
    packs = Path(sys.argv[1])
    for pack, big, small in TARGETS:
        base = json.loads((packs / pack / f"{pack}.{ord(big):04x}.json").read_text())
        code = f"{ord(small):04x}"
        data = dict(base)
        data["id"] = f"{pack}.{code}"
        data["char"] = small
        data["source"] = dict(base["source"], derivedFrom=big)
        data["strokes"] = make(base)
        out = packs / pack / f"{pack}.{code}.json"
        out.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n")
        print(f"{small} を {out} に書き出した")


if __name__ == "__main__":
    main()
