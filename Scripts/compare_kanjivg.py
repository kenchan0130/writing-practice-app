#!/usr/bin/env python3
"""文字のデータの書き順と画の向きを、KanjiVG と照らし合わせる（D66・D128）。

使い方:
  python3 -I Scripts/compare_kanjivg.py <KanjiVG の kanji フォルダ> <パックのフォルダ> [出力の Markdown]

字の形は違ってよいので、画ごとに「書き始めと書き終わりの位置」と「向き」だけを比べる。
- 画数が違う
- 書き順が違う（各画を KanjiVG の画に1対1で当て、位置の差の合計がいちばん小さい当て方の並びがずれる）
- 向きが逆（書き始めが KanjiVG の書き終わりに近い）
のどれかがある字を一覧にする。
"""

import importlib.util
import itertools
import json
import math
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("import_strokesvg", HERE / "import_strokesvg.py")
strokesvg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(strokesvg)

KVG_SIZE = 109
GRID = 1000
SVG_NS = "{http://www.w3.org/2000/svg}"


def endpoints(start, segments):
    return (start[0], start[1]), (segments[-1][4], segments[-1][5])


def kanjivg_strokes(path):
    root = ET.parse(path).getroot()
    result = []
    for p in root.iter(f"{SVG_NS}path"):
        pid = p.get("id", "")
        if "-s" not in pid:
            continue
        start, segments = strokesvg.parse_path(p.get("d"))
        s = GRID / KVG_SIZE
        (x0, y0), (x1, y1) = endpoints(start, segments)
        result.append(((x0 * s, y0 * s), (x1 * s, y1 * s)))
    return result


def ours(data):
    out = []
    for st in data["strokes"]:
        out.append(endpoints(st["start"], st["segments"]))
    return out


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def direction(stroke):
    (x0, y0), (x1, y1) = stroke
    n = math.hypot(x1 - x0, y1 - y0) or 1
    return ((x1 - x0) / n, (y1 - y0) / n)


def compare(data, kvg):
    issues = []
    mine = ours(data)
    if len(mine) != len(kvg):
        return [f"画数が違う（データ {len(mine)}、KanjiVG {len(kvg)}）"]
    # 各画を KanjiVG の画に1対1で当てる。位置（書き始めと書き終わり）の差の合計がいちばん小さい当て方を選ぶ。
    n = len(mine)

    def cost(i, j):
        m, k = mine[i], kvg[j]
        return min(dist(m[0], k[0]) + dist(m[1], k[1]), dist(m[0], k[1]) + dist(m[1], k[0]))

    best_total, assigned = None, None
    for perm in itertools.permutations(range(n)):
        total = sum(cost(i, perm[i]) for i in range(n))
        if best_total is None or total < best_total:
            best_total, assigned = total, list(perm)
    for i, j in enumerate(assigned):
        m, k = mine[i], kvg[j]
        forward = dist(m[0], k[0]) + dist(m[1], k[1])
        backward = dist(m[0], k[1]) + dist(m[1], k[0])
        if backward < forward * 0.6:
            issues.append(f"{i + 1}画目の向きが逆の可能性")
    if assigned != list(range(len(kvg))):
        issues.append(f"書き順が違う可能性（各画に近い KanjiVG の画: {[a + 1 for a in assigned]}）")
    for i, (m, k) in enumerate(zip(mine, kvg)):
        dm, dk = direction(m), direction(k)
        cos = dm[0] * dk[0] + dm[1] * dk[1]
        if cos < 0 and f"{i + 1}画目の向きが逆の可能性" not in issues:
            issues.append(f"{i + 1}画目の向きが KanjiVG と大きく違う（cos {cos:.2f}）")
    return issues


def main():
    kvg_dir, pack_dir = Path(sys.argv[1]), Path(sys.argv[2])
    report_path = Path(sys.argv[3]) if len(sys.argv) > 3 else None
    lines = ["# KanjiVG との照らし合わせ（自動）", "", "| 字 | 気になる点 |", "|---|---|"]
    checked = flagged = 0
    for f in sorted(pack_dir.glob("*.json")):
        data = json.loads(f.read_text())
        kvg_file = kvg_dir / f"{ord(data['char']):05x}.svg"
        if not kvg_file.exists():
            lines.append(f"| {data['char']} | KanjiVG にない |")
            flagged += 1
            continue
        checked += 1
        issues = compare(data, kanjivg_strokes(kvg_file))
        if issues:
            flagged += 1
            lines.append(f"| {data['char']} | {'／'.join(issues)} |")
    lines += ["", f"{checked} 字を比べ、{flagged} 字に気になる点があった。"]
    text = "\n".join(lines) + "\n"
    if report_path:
        report_path.write_text(text)
    print(text)


if __name__ == "__main__":
    main()
