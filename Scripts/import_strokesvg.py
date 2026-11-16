#!/usr/bin/env python3
"""strokesvg（Klee One をなぞったかなの書き順データ）を、もじまちの文字のデータ（D106・D128）に直す。

使い方:
  python3 -I Scripts/import_strokesvg.py <strokesvg の dist/hiragana> <出力先のフォルダ> <strokesvg のコミット>

- 各画の中心線を、マス 0〜1000 の座標（y は下向き）の3次ベジェの並びに直す。
- 各画の輪郭（Klee One の形）は、お手本の表示に使うため、閉じた部分ごとの「始点と3次ベジェの並び」にする（円弧も直す。座標は中心線と同じ 0〜1000）。
  自分と交わる画は strokesvg で部品に分かれているので、輪郭は部品の輪郭をすべて並べる（中心線は最初の部品）。
- 終わり方（とめ・はね・はらい）は strokesvg にないので、空のまま出す（あとで AI が案を作り、人が確かめる）。
"""

import json
import math
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

SVG_NS = "{http://www.w3.org/2000/svg}"
SOURCE_SIZE = 1024
GRID = 1000
SCALE = GRID / SOURCE_SIZE

TOKEN = re.compile(r"[MmCcSsLlHhVvQqTtZzAa]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?")
FLAG_TOKEN = re.compile(r"[01]")


def arc_to_cubics(x1, y1, rx, ry, phi_deg, large, sweep, x2, y2):
    """SVG の円弧を3次ベジェの並びにする（SVG 仕様 F.6 の中心の求め方）。"""
    if (x1, y1) == (x2, y2):
        return []
    if rx == 0 or ry == 0:
        return [(x1 + (x2 - x1) / 3, y1 + (y2 - y1) / 3, x1 + 2 * (x2 - x1) / 3, y1 + 2 * (y2 - y1) / 3, x2, y2)]
    phi = math.radians(phi_deg)
    cp, sp = math.cos(phi), math.sin(phi)
    dx, dy = (x1 - x2) / 2, (y1 - y2) / 2
    x1p, y1p = cp * dx + sp * dy, -sp * dx + cp * dy
    rx, ry = abs(rx), abs(ry)
    lam = (x1p ** 2) / (rx ** 2) + (y1p ** 2) / (ry ** 2)
    if lam > 1:
        rx, ry = rx * math.sqrt(lam), ry * math.sqrt(lam)
    num = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
    den = rx * rx * y1p * y1p + ry * ry * x1p * x1p
    coef = math.sqrt(max(0, num / den)) if den else 0
    if large == sweep:
        coef = -coef
    cxp, cyp = coef * rx * y1p / ry, -coef * ry * x1p / rx
    cx = cp * cxp - sp * cyp + (x1 + x2) / 2
    cy = sp * cxp + cp * cyp + (y1 + y2) / 2

    def angle(ux, uy, vx, vy):
        a = math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)
        return a

    t1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    dt = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if not sweep and dt > 0:
        dt -= 2 * math.pi
    elif sweep and dt < 0:
        dt += 2 * math.pi
    n = max(1, math.ceil(abs(dt) / (math.pi / 2)))
    step = dt / n
    k = 4 / 3 * math.tan(step / 4)
    result = []
    for i in range(n):
        a1, a2 = t1 + i * step, t1 + (i + 1) * step
        p1 = (math.cos(a1), math.sin(a1))
        p2 = (math.cos(a2), math.sin(a2))
        c1 = (p1[0] - k * p1[1], p1[1] + k * p1[0])
        c2 = (p2[0] + k * p2[1], p2[1] - k * p2[0])

        def tr(px, py):
            px, py = px * rx, py * ry
            return (cp * px - sp * py + cx, sp * px + cp * py + cy)

        q1, q2, q3 = tr(*c1), tr(*c2), tr(*p2)
        result.append((q1[0], q1[1], q2[0], q2[1], q3[0], q3[1]))
    last = result[-1]
    result[-1] = (last[0], last[1], last[2], last[3], x2, y2)
    return result


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


def parse_outline(d):
    """輪郭の path を、閉じた部分ごとの「始点と3次ベジェの並び」にする（円弧も直す）。"""
    tokens = TOKEN.findall(d)
    # 円弧の旗（0/1）がつながって書かれることがあるので、A の引数は1文字ずつ読む。
    i = 0
    x = y = 0.0
    sx = sy = 0.0
    cmd = None
    subpaths = []
    current = None
    last_ctrl = None
    last_c = None

    def num():
        nonlocal i
        v = float(tokens[i])
        i += 1
        return v

    def flag():
        nonlocal i
        t = tokens[i]
        if t in ("0", "1"):
            i += 1
            return int(t)
        # "01" のように2つの旗がつながった数として読まれた場合
        tokens[i] = t[1:]
        return int(t[0])

    while i < len(tokens):
        if re.fullmatch(r"[A-Za-z]", tokens[i]):
            cmd = tokens[i]
            i += 1
        rel = cmd.islower()
        c = cmd.upper()
        if c == "M":
            nx, ny = num(), num()
            x, y = (x + nx, y + ny) if rel else (nx, ny)
            sx, sy = x, y
            current = {"start": (x, y), "segments": []}
            subpaths.append(current)
            cmd = "l" if rel else "L"
            last_ctrl = None
        elif c == "Z":
            if (x, y) != (sx, sy):
                current["segments"].append((x + (sx - x) / 3, y + (sy - y) / 3, x + 2 * (sx - x) / 3, y + 2 * (sy - y) / 3, sx, sy))
            x, y = sx, sy
            last_ctrl = None
        elif c == "A":
            rx, ry, phi = num(), num(), num()
            large, sweep = flag(), flag()
            nx, ny = num(), num()
            ex, ey = (x + nx, y + ny) if rel else (nx, ny)
            current["segments"].extend(arc_to_cubics(x, y, rx, ry, phi, large, sweep, ex, ey))
            x, y = ex, ey
            last_ctrl = None
        else:
            # 1区間だけを parse_path に任せる
            if c in "LHV":
                if c == "L":
                    nx, ny = num(), num()
                    ex, ey = (x + nx, y + ny) if rel else (nx, ny)
                elif c == "H":
                    v = num()
                    ex, ey = (x + v if rel else v), y
                else:
                    v = num()
                    ex, ey = x, (y + v if rel else v)
                current["segments"].append((x + (ex - x) / 3, y + (ey - y) / 3, x + 2 * (ex - x) / 3, y + 2 * (ey - y) / 3, ex, ey))
                x, y = ex, ey
                last_ctrl = None
            elif c == "C":
                vals = [num() for _ in range(6)]
                if rel:
                    vals = [vals[k] + (x if k % 2 == 0 else y) for k in range(6)]
                current["segments"].append(tuple(vals))
                last_ctrl = (vals[2], vals[3])
                x, y = vals[4], vals[5]
            elif c == "S":
                vals = [num() for _ in range(4)]
                if rel:
                    vals = [vals[k] + (x if k % 2 == 0 else y) for k in range(4)]
                c1 = (2 * x - last_ctrl[0], 2 * y - last_ctrl[1]) if last_ctrl is not None and last_c in ("C", "S") else (x, y)
                current["segments"].append((c1[0], c1[1], vals[0], vals[1], vals[2], vals[3]))
                last_ctrl = (vals[0], vals[1])
                x, y = vals[2], vals[3]
            elif c in "QT":
                if c == "Q":
                    vals = [num() for _ in range(4)]
                    if rel:
                        vals = [vals[k] + (x if k % 2 == 0 else y) for k in range(4)]
                    qx, qy, ex, ey = vals
                else:
                    nx, ny = num(), num()
                    ex, ey = (x + nx, y + ny) if rel else (nx, ny)
                    if last_ctrl is not None and last_c in ("Q", "T"):
                        qx, qy = 2 * x - last_ctrl[0], 2 * y - last_ctrl[1]
                    else:
                        qx, qy = x, y
                current["segments"].append((x + 2 / 3 * (qx - x), y + 2 / 3 * (qy - y), ex + 2 / 3 * (qx - ex), ey + 2 / 3 * (qy - ey), ex, ey))
                last_ctrl = (qx, qy)
                x, y = ex, ey
            else:
                raise ValueError(f"扱えない命令: {cmd}")
        last_c = c
    return subpaths


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
                "outline": [
                    {"start": [scaled(sp["start"][0]), scaled(sp["start"][1])], "segments": [[scaled(v) for v in seg] for seg in sp["segments"]]}
                    for p in parts
                    for sp in parse_outline(outlines[clip_to_outline[clip_id(p)]])
                ],
            }
        )
    code = f"{ord(char):04x}"
    return {
        "schema": 1,
        "id": f"hira.{code}",
        "char": char,
        "rev": 1,
        "source": {"name": "strokesvg", "commit": commit, "license": "OFL-1.1 (Klee One)"},
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
