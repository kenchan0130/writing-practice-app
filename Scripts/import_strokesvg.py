#!/usr/bin/env python3
"""strokesvg（Klee One をなぞったかなの書き順データ）を、もじまちの文字のデータ（D106・D128）に直す。

使い方:
  python3 -I Scripts/import_strokesvg.py <strokesvg の dist/hiragana> <出力先のフォルダ> <strokesvg のコミット>

- 各画の中心線を、マス 0〜1000 の座標（y は下向き）の3次ベジェの並びに直す。
- 各画の輪郭（Klee One の形）は、お手本の表示に使うため SVG の path の文字のまま残す（座標は 1024 四方）。
  自分と交わる画は strokesvg で部品に分かれているので、輪郭は部品ごとの並びにする（中心線は最初の部品）。
- 終わり方（とめ・はね・はらい）は strokesvg にないので、空のまま出す（あとで AI が案を作り、人が確かめる）。
"""

import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

SVG_NS = "{http://www.w3.org/2000/svg}"
SOURCE_SIZE = 1024
GRID = 1000
SCALE = GRID / SOURCE_SIZE

TOKEN = re.compile(r"[MmCcSsLlHhVvQqTtZzAa]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?")


def parse_path(d):
    """SVG の path を、始点と3次ベジェの区間の並びにする（円弧は使っていない前提）。"""
    tokens = TOKEN.findall(d)
    i = 0
    cmd = None
    x = y = 0.0
    start = None
    segments = []
    last_ctrl = None
    last_cmd = None

    def num():
        nonlocal i
        value = float(tokens[i])
        i += 1
        return value

    while i < len(tokens):
        if re.fullmatch(r"[A-Za-z]", tokens[i]):
            cmd = tokens[i]
            i += 1
        if cmd in "Aa":
            raise ValueError("円弧（A）は扱えない")
        rel = cmd.islower()
        c = cmd.upper()
        if c == "M":
            nx, ny = num(), num()
            x, y = (x + nx, y + ny) if rel else (nx, ny)
            if start is not None:
                raise ValueError("1画に始点が2つある")
            start = (x, y)
            cmd = "l" if rel else "L"
            last_ctrl = None
        elif c == "L":
            nx, ny = num(), num()
            ex, ey = (x + nx, y + ny) if rel else (nx, ny)
            segments.append((x + (ex - x) / 3, y + (ey - y) / 3, x + 2 * (ex - x) / 3, y + 2 * (ey - y) / 3, ex, ey))
            x, y = ex, ey
            last_ctrl = None
        elif c in "HV":
            v = num()
            if c == "H":
                ex, ey = (x + v if rel else v), y
            else:
                ex, ey = x, (y + v if rel else v)
            segments.append((x + (ex - x) / 3, y + (ey - y) / 3, x + 2 * (ex - x) / 3, y + 2 * (ey - y) / 3, ex, ey))
            x, y = ex, ey
            last_ctrl = None
        elif c == "C":
            vals = [num() for _ in range(6)]
            if rel:
                vals = [vals[k] + (x if k % 2 == 0 else y) for k in range(6)]
            segments.append(tuple(vals))
            last_ctrl = (vals[2], vals[3])
            x, y = vals[4], vals[5]
        elif c == "S":
            vals = [num() for _ in range(4)]
            if rel:
                vals = [vals[k] + (x if k % 2 == 0 else y) for k in range(4)]
            if last_ctrl is not None and last_cmd in ("C", "S"):
                c1 = (2 * x - last_ctrl[0], 2 * y - last_ctrl[1])
            else:
                c1 = (x, y)
            segments.append((c1[0], c1[1], vals[0], vals[1], vals[2], vals[3]))
            last_ctrl = (vals[0], vals[1])
            x, y = vals[2], vals[3]
        elif c == "Q":
            vals = [num() for _ in range(4)]
            if rel:
                vals = [vals[k] + (x if k % 2 == 0 else y) for k in range(4)]
            qx, qy, ex, ey = vals
            segments.append((x + 2 / 3 * (qx - x), y + 2 / 3 * (qy - y), ex + 2 / 3 * (qx - ex), ey + 2 / 3 * (qy - ey), ex, ey))
            last_ctrl = None
            x, y = ex, ey
        elif c == "Z":
            last_ctrl = None
        else:
            raise ValueError(f"扱えない命令: {cmd}")
        last_cmd = c
    if start is None or not segments:
        raise ValueError("中心線が空")
    return start, segments


def scaled(v):
    return round(v * SCALE)


def convert(svg_path, commit):
    root = ET.parse(svg_path).getroot()
    char = root.get("data-strokesvg")
    outlines = {}
    for g in root.iter(f"{SVG_NS}g"):
        if g.get("data-strokesvg") == "shadows":
            for p in g.iter(f"{SVG_NS}path"):
                outlines[p.get("id")] = p.get("d")
    clip_to_outline = {}
    for clip in root.iter(f"{SVG_NS}clipPath"):
        use = clip.find(f"{SVG_NS}use")
        clip_to_outline[clip.get("id")] = use.get("href").lstrip("#")

    def clip_id(p):
        return re.search(r"url\(#([^)]+)\)", p.get("clip-path", "")).group(1)

    def order_of(el):
        m = re.search(r"--i:(\d+)", el.get("style", ""))
        return int(m.group(1)) if m else 0

    # 画は、strokes の直下の path か、自分と交わる画を部品に分けた g（最初の path が1画の中心線）。
    strokes_group = next(g for g in root.iter(f"{SVG_NS}g") if g.get("data-strokesvg") == "strokes")
    result = []
    for el in sorted(list(strokes_group), key=order_of):
        parts = [el] if el.tag == f"{SVG_NS}path" else list(el.iter(f"{SVG_NS}path"))
        start, segments = parse_path(parts[0].get("d"))
        result.append(
            {
                "start": [scaled(start[0]), scaled(start[1])],
                "segments": [[scaled(v) for v in seg] for seg in segments],
                "end": None,
                "outlines": [outlines[clip_to_outline[clip_id(p)]] for p in parts],
            }
        )
    code = f"{ord(char):04x}"
    return {
        "schema": 1,
        "id": f"hira.{code}",
        "char": char,
        "rev": 1,
        "source": {"name": "strokesvg", "commit": commit, "license": "OFL-1.1 (Klee One)"},
        "outlineViewBox": SOURCE_SIZE,
        "strokes": result,
        "orders": [list(range(len(result)))],
    }


def main():
    src, out, commit = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
    out.mkdir(parents=True, exist_ok=True)
    count = 0
    for svg in sorted(src.glob("*.svg")):
        data = convert(svg, commit)
        (out / f"{data['id']}.json").write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n")
        count += 1
    print(f"{count} 字を書き出した")


if __name__ == "__main__":
    main()
