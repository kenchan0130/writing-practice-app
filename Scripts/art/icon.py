"""アプリのアイコン。ことばの絵・主人公と同じ描き方（part / sil / ink。D176・D177・D184）。

使い方: python3 -I Scripts/art/icon.py [出すフォルダ]
  → Content/Art/icon/app-icon.svg（ふつう）・app-icon-dark.svg（ダーク）・app-icon-tinted.svg（色あい用の白黒）
  → フォルダを渡すと、くらべる用の案（option-a.svg・option-b.svg・option-c.svg）もそこに出す
主人公を変えるとき（D76 の3案）: option_a(who="run") / option_a(who="hira")
絵は 512 の四角いっぱいに背景を塗る（すきとおる所なし）。角の丸みは iOS が付けるので描かない。
PNG にするとき: Scripts/art/icon.sh
"""
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import chars
from lib import Art, O, _tx_path, bez_pts

OUT = os.path.join(HERE, "..", "..", "Content", "Art", "icon")
WHITE = "#ffffff"
f = lambda v: f"{v:.1f}".rstrip("0").rstrip(".")


# ------------------------------------------------------------ 共通の部品 ----
def put(dst, src, s=1.0, tx=0.0, ty=0.0, skip=0):
    """src の絵を s 倍にして (tx, ty) にずらし、dst に足す。線の太さも s 倍。skip = 後ろから捨てる数。"""
    els = src.els[:len(src.els) - skip] if skip else src.els
    for tag, g, a in els:
        g, a = dict(g), dict(a)
        if tag == "path":
            g["d"] = _tx_path(g["d"], s, tx, ty)
        elif tag in ("circle", "ellipse"):
            g["cx"] = s * g["cx"] + tx; g["cy"] = s * g["cy"] + ty
            for k in ("r", "rx", "ry"):
                if k in g:
                    g[k] = s * g[k]
        if "stroke-width" in a:
            a["stroke-width"] = round(float(a["stroke-width"]) * s, 2)
        dst.els.append((tag, g, a))


def stroke_d(cubics, w, s=1.0, tx=0.0, ty=0.0, n=48):
    """太さ w の、両はしが丸い線の輪郭（1本の閉じた形）。cubics は三次ベジェのつながり。"""
    p = bez_pts(cubics, n)
    r = w / 2
    L = [(x + nx * r, y + ny * r) for x, y, nx, ny in p]
    R = [(x - nx * r, y - ny * r) for x, y, nx, ny in p]

    def cap(x, y, nx, ny, sign):
        a0 = math.atan2(ny, nx)
        return [(x + r * math.cos(a0 - sign * math.pi * j / 10), y + r * math.sin(a0 - sign * math.pi * j / 10))
                for j in range(1, 10)]
    x, y, nx, ny = p[-1]
    end = cap(x, y, nx, ny, 1)
    x, y, nx, ny = p[0]
    start = cap(x, y, -nx, -ny, 1)
    pts = L + end + R[::-1] + start
    return "M" + " L".join(f"{f(s * u + tx)} {f(s * v + ty)}" for u, v in pts) + " Z"


def poly(pts, ox, oy, ang, s=1.0):
    """(u, v) の点の形を、ang 度まわして (ox, oy) に置く。"""
    c, d = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    return "M" + " L".join(f"{f(ox + s * (u * c - v * d))} {f(oy + s * (u * d + v * c))}" for u, v in pts) + " Z"


# 「も」の3本の線（1000 の四角の中。書き順どおり）
MO = [
    [(455, 95, 440, 300, 345, 520, 372, 700), (372, 700, 392, 868, 610, 930, 730, 810),
     (730, 810, 782, 752, 786, 668, 748, 600)],
    [(196, 372, 320, 384, 460, 372, 584, 342)],
    [(178, 566, 310, 584, 446, 570, 572, 538)],
]

def kana(a, strokes, w, s, tx, ty, fill=WHITE, shadow=None, sh=(7, 9), ow=11):
    """太い丸い線で書いた かな。3本は1つの部品（外側だけに線）。shadow = 右下に落とす影の色。"""
    ds = [stroke_d(c, w, s, tx, ty) for c in strokes]
    if shadow:
        for c in strokes:
            a.blob(stroke_d(c, w + 2 * ow / s, s, tx + sh[0], ty + sh[1]), shadow)
    with a.part(ow):
        for d in ds:
            a.sil(d, fill)


def pencil(a, x, y, ang, s=1.0, body="#ffc93c", body_d="#f0a92a", ow=9):
    """えんぴつ。しんの先が (x, y)。ang 度（0 = 先が左、じくは右へ）。"""
    W = 30                                    # じくの太さの半分
    with a.part(ow):
        a.sil(poly([(0, 0), (58, -W), (58, W)], x, y, ang, s), "#f6d7a8")                    # 木の先
        a.sil(poly([(58, -W), (250, -W), (250, W), (58, W)], x, y, ang, s), body)            # じく
        a.sil(poly([(250, -W), (276, -W), (276, W), (250, W)], x, y, ang, s), "#c9ced6")     # 金具
        a.sil(poly([(276, -W), (300, -W), (312, -W + 10), (312, W - 10), (300, W), (276, W)], x, y, ang, s), "#ff9aa8")
        a.blob(poly([(58, 8), (250, 8), (250, W), (58, W)], x, y, ang, s), body_d)           # 影（下の面）
        a.blob(poly([(0, 0), (22, -11.4), (22, 11.4)], x, y, ang, s), O)                     # しん
    a.blob(poly([(70, -W + 7), (236, -W + 7), (236, -W + 13), (70, -W + 13)], x, y, ang, s), "#fff1b8")  # つや


def house(a, x, y, w, h, wall, roof, door=None):
    """線のない小さな家（まちの気配）。(x, y) は下の真ん中。"""
    a.blob(f"M{x - w / 2} {y} L{x - w / 2} {y - h * .55} L{x + w / 2} {y - h * .55} L{x + w / 2} {y} Z", wall)
    a.blob(f"M{x - w * .64} {y - h * .52} L{x} {y - h} L{x + w * .64} {y - h * .52} Z", roof)
    if door:
        a.blob(f"M{x - w * .12} {y} L{x - w * .12} {y - h * .3} C{x - w * .12} {y - h * .42} {x + w * .12} {y - h * .42} "
               f"{x + w * .12} {y - h * .3} L{x + w * .12} {y} Z", door)


def house_l(a, x, y, w, h, wall, roof, door, win, ow=7):
    """細い線のある小さな家。壁と屋根は1つの部品。(x, y) は下の真ん中。"""
    e = h * 0.5                                   # 軒の高さ
    with a.part(ow):
        a.sil(f"M{x - w / 2} {y} L{x - w / 2} {y - e - 4} L{x + w / 2} {y - e - 4} L{x + w / 2} {y} Z", wall)
        a.sil(f"M{x - w * .66} {y - e} C{x - w * .7} {y - e - 6} {x - w * .1} {y - h - 2} {x} {y - h} "
              f"C{x + w * .1} {y - h - 2} {x + w * .7} {y - e - 6} {x + w * .66} {y - e} Z", roof)
    dw = w * 0.15
    a.blob(f"M{x - dw} {y} L{x - dw} {y - e * .42} C{x - dw} {y - e * .7} {x + dw} {y - e * .7} {x + dw} {y - e * .42} "
           f"L{x + dw} {y} Z", door)
    disc(a, x, y - e - (h - e) * 0.42, w * 0.085, win)


def sparkle(a, cx, cy, r, col, ow=6):
    """きらきら（chars.sparkle と同じ形。色を選べる）。"""
    k = r * 0.2
    with a.part(ow):
        a.sil(f"M{cx} {cy - r} Q{cx + k} {cy - k} {cx + r} {cy} Q{cx + k} {cy + k} {cx} {cy + r} "
              f"Q{cx - k} {cy + k} {cx - r} {cy} Q{cx - k} {cy - k} {cx} {cy - r} Z", col)


def hill(y0, y1, yb=530):
    return f"M-10 {y0} C120 {y1} 392 {y1} 522 {y0} L522 {yb} L-10 {yb} Z"


def bg(a, col):
    a.blob("M-10 -10 L522 -10 L522 522 L-10 522 Z", col)


def disc(a, cx, cy, r, col):
    k = r * 0.5523
    a.blob(f"M{cx - r} {cy} C{cx - r} {cy - k} {cx - k} {cy - r} {cx} {cy - r} C{cx + k} {cy - r} {cx + r} {cy - k} {cx + r} {cy} "
           f"C{cx + r} {cy + k} {cx + k} {cy + r} {cx} {cy + r} C{cx - k} {cy + r} {cx - r} {cy + k} {cx - r} {cy} Z", col)


PAL = {
    "light": dict(bg="#ffcb45", glow="#ffdf7e", hill="#fff4d8", hill_d="#ffe7b0", kana=WHITE, sh="#f2a52c",
                  wall="#fffaf0", roof1="#f07a4a", roof2="#58b2ea", roof3="#7cc36a", door="#e9b97a", win="#ffe9a8", spark=WHITE),
    "dark": dict(bg="#2c2742", glow="#3c3560", hill="#463e6c", hill_d="#3a3360", kana="#fff6e0", sh="#1d1930",
                 wall="#8d84b5", roof1="#f07a4a", roof2="#58b2ea", roof3="#7cc36a", door="#463e6c", win="#ffd84d", spark="#ffd84d"),
    # 色あい用（iOS が色をかぶせる。白黒で描く）
    "tinted": dict(bg="#0c0c0c", glow="#1a1a1a", hill="#2b2b2b", hill_d="#1f1f1f", kana=WHITE, sh="#000000",
                   wall="#8a8a8a", roof1="#bdbdbd", roof2="#bdbdbd", roof3="#bdbdbd", door="#2b2b2b", win="#2b2b2b",
                   spark=WHITE),
}


def gray(art):
    """絵の色をぜんぶ白黒にする（色あい用）。明るさはそのまま。"""
    def g(m):
        r, gr, b = (int(m.group(1)[i:i + 2], 16) for i in (0, 2, 4))
        v = round(0.299 * r + 0.587 * gr + 0.114 * b)
        return f"#{v:02x}{v:02x}{v:02x}"
    for _, _, a in art.els:
        for k in ("fill", "stroke"):
            if k in a and a[k].startswith("#"):
                a[k] = re.sub(r"#([0-9a-fA-F]{6})", g, a[k])
    return art


def town(a, P, y, xs=(70, 132, 400, 452)):
    """丘の上の小さな家。"""
    roofs = [P["roof2"], P["roof3"], P["roof3"], P["roof2"]]
    for i, x in enumerate(xs):
        big = i % 2 == 0
        dy = 0.0009 * (x - 256) ** 2                  # 丘の丸みに合わせて下げる
        house(a, x, y + dy, 50 if big else 40, 62 if big else 46, P["wall"], roofs[i % 4], P["door"])


# ---------------------------------------------------------------- 案 A ----
def option_a(mode="light", who="ton"):
    """大きな「も」と、手を振る主人公。下に丘。"""
    P = PAL[mode]
    a = Art()
    bg(a, P["bg"])
    disc(a, 256, 236, 236, P["glow"])
    a.blob(hill(430, 388), P["hill"])
    house_l(a, 78, 421, 66, 84, P["wall"], P["roof2"], P["door"], P["win"])
    a.blob("M322 471 C322 461 454 461 454 471 C454 481 322 481 322 471 Z", P["hill_d"])   # 足もとの影
    kana(a, MO, 118, 0.43, 2, 14, P["kana"], P["sh"], ow=11)
    c = getattr(chars, who)("wave")
    put(a, c, 0.54, 388 - 256 * 0.54, 476 - 480 * 0.54, skip=2)
    sparkle(a, 410, 100, 32, P["spark"])
    sparkle(a, 456, 166, 18, P["spark"])
    return a


# ---------------------------------------------------------------- 案 B ----
def option_b(mode="light", who="ton"):
    """大きな主人公と えんぴつ。書いた線の上に立つ。後ろに まちの家。"""
    P = PAL[mode]
    a = Art()
    bg(a, P["bg"])
    disc(a, 256, 250, 232, P["glow"])
    a.blob(hill(410, 372), P["hill_d"])
    town(a, P, 384)
    a.blob(hill(446, 414), P["hill"])
    line = [(52, 452, 130, 420, 210, 468, 300, 446), (300, 446, 330, 438, 350, 432, 372, 430)]
    a.blob(stroke_d(line, 44, 1, 6, 8), P["sh"])
    with a.part(10):
        a.sil(stroke_d(line, 24), P["kana"])
    pencil(a, 366, 440, -78, 0.92)
    c = getattr(chars, who)("wave")
    put(a, c, 0.80, 236 - 256 * 0.80, 432 - 480 * 0.80, skip=2)
    return a


# ---------------------------------------------------------------- 案 C ----
def option_c(mode="light", who=None):
    """3人が まちの丘にならぶ。"""
    P = PAL[mode]
    a = Art()
    bg(a, P["bg"])
    disc(a, 256, 250, 232, P["glow"])
    a.blob(hill(330, 286), P["hill_d"])
    town(a, P, 300, xs=(84, 150, 372, 432))
    a.blob(hill(420, 380), P["hill"])
    put(a, chars.run("normal"), 0.46, 122 - 256 * 0.46, 436 - 480 * 0.46)
    put(a, chars.hira("normal"), 0.46, 386 - 256 * 0.46, 436 - 480 * 0.46)
    put(a, chars.ton("wave"), 0.60, 256 - 256 * 0.60, 462 - 480 * 0.60, skip=2)
    return a


OPTIONS = {"a": option_a, "b": option_b, "c": option_c}
FINAL = option_a


def write(path, art):
    open(path, "w").write(art.svg(params=(1, 0, 0)))


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    write(f"{OUT}/app-icon.svg", FINAL("light"))
    write(f"{OUT}/app-icon-dark.svg", FINAL("dark"))
    write(f"{OUT}/app-icon-tinted.svg", gray(FINAL("tinted")))
    if len(sys.argv) > 1:                     # くらべる用の案（フォルダを渡したときだけ）
        for k, fn in OPTIONS.items():
            write(f"{sys.argv[1]}/option-{k}.svg", fn())
