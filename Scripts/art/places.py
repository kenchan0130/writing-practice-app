"""まちの地図の場所の絵（SVG）。ことばの絵と同じ描き方（D176。`Content/Art/style-guide.md`）:
部品は塗りだけ（`part()`・`sil()`）、線は部品の外側に自動で付く。中の線は先の細い線（`ink()`）。"""
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "Content", "Art", "places")
sys.path.insert(0, HERE)
from lib import Art, mirror, taper, at, O, EYE  # noqa: E402

RED, RED_D = "#e5534b", "#c9403a"
YEL, YEL2, YEL_D = "#f6d36b", "#f7c948", "#e9b53c"
BLUE, BLUE_D, SKY = "#5ab0e8", "#3f97d0", "#bfe6fa"
WOOD, WOOD_D, BARK = "#f2b56b", "#c97f3e", "#b8794a"
PINK, CHEEK = "#f7b3bd", "#ff9aa8"
G1, G2, G3 = "#8fd070", "#6fbd5c", "#4f9e48"
CREAM, WHITE = "#fff4e2", "#ffffff"
WALL, WALL_D = "#fff0d4", "#ecd8b2"
GREY, GREY_L, GREY_D = "#a8a29c", "#d8d2cc", "#857f7a"
ORANGE, ORANGE_D = "#f59a4a", "#e07f30"

P = {}


def place(f):
    P[f.__name__] = f
    return f


# ------------------------------------------------------------- 形の道具 --
_TOK = re.compile(r"[MLCQZ]|-?\d*\.?\d+(?:e-?\d+)?")
_F = lambda v: f"{v:.1f}".rstrip("0").rstrip(".")


def _cmds(d):
    cmd, nums, res = None, [], []
    for t in _TOK.findall(d):
        if t.isalpha():
            if cmd:
                res.append((cmd, nums))
            cmd, nums = t, []
        else:
            nums.append(float(t))
    if cmd:
        res.append((cmd, nums))
    return res


def tf(d, s=1.0, dx=0.0, dy=0.0, rot=0.0, flip=None):
    """パスを動かす: （flip があれば x = flip で左右に返し）rot 度まわし、s 倍して、(dx, dy) ずらす。"""
    c, sn = math.cos(math.radians(rot)), math.sin(math.radians(rot))
    out = []
    for cmd, n in _cmds(d):
        vals = []
        for i in range(0, len(n), 2):
            x, y = n[i], n[i + 1]
            if flip is not None:
                x = 2 * flip - x
            vals += [s * (x * c - y * sn) + dx, s * (x * sn + y * c) + dy]
        out.append(cmd + " ".join(_F(v) for v in vals))
    return " ".join(out)


def tc(cub, s=1.0, dx=0.0, dy=0.0, rot=0.0, flip=None):
    c, sn = math.cos(math.radians(rot)), math.sin(math.radians(rot))
    r = []
    for i in range(0, 8, 2):
        x, y = cub[i], cub[i + 1]
        if flip is not None:
            x = 2 * flip - x
        r += [s * (x * c - y * sn) + dx, s * (x * sn + y * c) + dy]
    return tuple(r)


def poly(d, n=14):
    """パスを点の列にする（rim 用）。"""
    pts, cur = [], (0.0, 0.0)
    for cmd, v in _cmds(d):
        if cmd in "ML":
            for i in range(0, len(v), 2):
                cur = (v[i], v[i + 1]); pts.append(cur)
        elif cmd == "C":
            for i in range(0, len(v), 6):
                x0, y0 = cur
                x1, y1, x2, y2, x3, y3 = v[i:i + 6]
                for j in range(1, n + 1):
                    t = j / n; u = 1 - t
                    pts.append((u**3 * x0 + 3 * u * u * t * x1 + 3 * u * t * t * x2 + t**3 * x3,
                                u**3 * y0 + 3 * u * u * t * y1 + 3 * u * t * t * y2 + t**3 * y3))
                cur = (x3, y3)
        elif cmd == "Q":
            for i in range(0, len(v), 4):
                x0, y0 = cur
                x1, y1, x2, y2 = v[i:i + 4]
                for j in range(1, n + 1):
                    t = j / n; u = 1 - t
                    pts.append((u * u * x0 + 2 * u * t * x1 + t * t * x2, u * u * y0 + 2 * u * t * y1 + t * t * y2))
                cur = (x2, y2)
    return pts


def rim(d, ang, span, thick, c=None, inset=0.5):
    """形 d のふちの内側に付ける、三日月の影。ang（度。0 = 右、90 = 下）の向きのふちに、左右 span 度ずつ。
    形の真ん中へ向かって厚みを取るので、ふちからはみ出さない。"""
    pts = poly(d)
    if c is None:
        xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
        c = ((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2)
    n = len(pts)
    diff = [((math.degrees(math.atan2(y - c[1], x - c[0])) - ang + 180) % 360) - 180 for x, y in pts]
    ins = [abs(v) <= span for v in diff]
    if all(ins) or not any(ins):
        return ""
    i0 = next(i for i in range(n) if ins[i] and not ins[i - 1])
    outer, inner = [], []
    i = i0
    while ins[i % n] and i < i0 + n:
        x, y = pts[i % n]
        vx, vy = c[0] - x, c[1] - y
        L = math.hypot(vx, vy) or 1
        u = (diff[i % n] + span) / (2 * span)
        w = thick * max(0.0, math.sin(math.pi * u)) ** 0.7
        outer.append((x + vx / L * inset, y + vy / L * inset))
        inner.append((x + vx / L * (inset + w), y + vy / L * (inset + w)))
        i += 1
    return "M" + " L".join(f"{_F(x)} {_F(y)}" for x, y in outer + inner[::-1]) + " Z"


def rpoly(pts, r):
    """角の丸い多角形（r は1つ、または角ごと。0 = とがった角）。"""
    n = len(pts)
    rs = list(r) if isinstance(r, (list, tuple)) else [r] * n
    out = []
    for i in range(n):
        p0, p1, p2 = pts[i - 1], pts[i], pts[(i + 1) % n]

        def toward(q, dist):
            dx, dy = q[0] - p1[0], q[1] - p1[1]
            L = math.hypot(dx, dy) or 1
            k = min(dist, L / 2) / L
            return p1[0] + dx * k, p1[1] + dy * k
        u, v = toward(p0, rs[i]), toward(p2, rs[i])
        out.append(("M" if i == 0 else "L") + f"{_F(u[0])} {_F(u[1])}")
        if rs[i] > 0:
            out.append(f"Q{_F(p1[0])} {_F(p1[1])} {_F(v[0])} {_F(v[1])}")
    return " ".join(out) + " Z"


def rect(x, y, w, h, r=0):
    return rpoly([(x, y), (x + w, y), (x + w, y + h), (x, y + h)], r)


def circ(cx, cy, rx, ry=None):
    ry = rx if ry is None else ry
    kx, ky = rx * 0.5523, ry * 0.5523
    return (f"M{_F(cx - rx)} {_F(cy)} C{_F(cx - rx)} {_F(cy - ky)} {_F(cx - kx)} {_F(cy - ry)} {_F(cx)} {_F(cy - ry)} "
            f"C{_F(cx + kx)} {_F(cy - ry)} {_F(cx + rx)} {_F(cy - ky)} {_F(cx + rx)} {_F(cy)} "
            f"C{_F(cx + rx)} {_F(cy + ky)} {_F(cx + kx)} {_F(cy + ry)} {_F(cx)} {_F(cy + ry)} "
            f"C{_F(cx - kx)} {_F(cy + ry)} {_F(cx - rx)} {_F(cy + ky)} {_F(cx - rx)} {_F(cy)} Z")


def arc(cx, cy, rx, a0, a1, ry=None):
    """円弧に沿った三次ベジェの列（度。0 = 右、90 = 下）。"""
    ry = ry or rx
    n = max(1, int(math.ceil(abs(a1 - a0) / 90)))
    res = []
    for i in range(n):
        t0 = math.radians(a0 + (a1 - a0) * i / n)
        t1 = math.radians(a0 + (a1 - a0) * (i + 1) / n)
        k = 4 / 3 * math.tan((t1 - t0) / 4)
        c0, s0, c1, s1 = math.cos(t0), math.sin(t0), math.cos(t1), math.sin(t1)
        res.append((cx + rx * c0, cy + ry * s0, cx + rx * (c0 - k * s0), cy + ry * (s0 + k * c0),
                    cx + rx * (c1 + k * s1), cy + ry * (s1 - k * c1), cx + rx * c1, cy + ry * s1))
    return res


def chain(cubics, close=True):
    out, cur = [], None
    for c in cubics:
        if cur is None:
            out.append(f"M{_F(c[0])} {_F(c[1])}")
        elif abs(cur[0] - c[0]) > 0.05 or abs(cur[1] - c[1]) > 0.05:
            out.append(f"L{_F(c[0])} {_F(c[1])}")
        out.append(f"C{_F(c[2])} {_F(c[3])} {_F(c[4])} {_F(c[5])} {_F(c[6])} {_F(c[7])}")
        cur = (c[6], c[7])
    return " ".join(out) + (" Z" if close else "")


def seg(x0, y0, x1, y1):
    return (x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)


def line(a, x0, y0, x1, y1, w=6, s=1.0, e=1.0, col=O):
    a.ink([seg(x0, y0, x1, y1)], w, a=s, b=e, col=col)


def wool(cx, cy, rx, ry, n, start=0.0, puff=0.62):
    """だ円に沿った、もこもこの1本の輪郭。"""
    pts = [(cx + rx * math.cos(start + 2 * math.pi * i / n), cy + ry * math.sin(start + 2 * math.pi * i / n)) for i in range(n)]
    out = [f"M{_F(pts[0][0])} {_F(pts[0][1])}"]
    for i in range(n):
        (px, py), (qx, qy) = pts[i], pts[(i + 1) % n]
        tx, ty = qx - px, qy - py
        nx, ny = ty, -tx
        k, e = puff, 0.12
        out.append(f"C{_F(px + nx * k - tx * e)} {_F(py + ny * k - ty * e)} {_F(qx + nx * k + tx * e)} {_F(qy + ny * k + ty * e)} {_F(qx)} {_F(qy)}")
    return " ".join(out) + " Z"


def star_d(cx, cy, r, k=0.5, rot=-90, n=5, round_=0.22):
    pts = []
    for i in range(2 * n):
        rr = r if i % 2 == 0 else r * k
        t = math.radians(rot + 180 * i / n)
        pts.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
    return rpoly(pts, [r * round_, r * round_ * 0.5] * n)


# ------------------------------------------------------------ よく使う物 --
def glass(a, d, ow=6, col=SKY):
    with a.part(ow):
        a.sil(d, col)


def glint(a, x, y, n=18, w=6):
    a.path(f"M{_F(x)} {_F(y + n)} L{_F(x + n * 0.6)} {_F(y)}", stroke=WHITE, sw=w, **{"stroke-opacity": "0.75"})


def face(a, cx, cy, gap, r=15, cheek=None, mouth=None, mw=None, col=O, cheek_col=None):
    """正面の顔: 同じ大きさの目を2つ、外側の下にほほ、間に小さな口。cheek = (dx, dy)。mouth = 目からの下がり。"""
    for s in (-1, 1):
        a.eye(cx + s * gap, cy, r)
    if cheek:
        for s in (-1, 1):
            if cheek_col:
                a.ellipse(cx + s * cheek[0], cy + cheek[1], r * 0.95, r * 0.58, cheek_col, sw=0, stroke="none")
            else:
                a.cheek(cx + s * cheek[0], cy + cheek[1], r * 0.95, r * 0.58)
    if mouth is not None:
        w, y = mw or r * 0.8, cy + mouth
        a.path(f"M{_F(cx - w)} {_F(y)} C{_F(cx - w * 0.45)} {_F(y + w * 0.85)} {_F(cx + w * 0.45)} {_F(y + w * 0.85)} {_F(cx + w)} {_F(y)}",
               sw=max(4, r * 0.45), stroke=col)


CLOUD = ("M150 352 C96 352 70 320 74 284 C78 248 110 226 146 232 C148 176 194 138 250 140 "
         "C296 142 332 168 346 206 C390 196 432 228 432 272 C466 278 480 312 466 334 C456 350 438 352 416 352 Z")
CLOUD_SHADE = "M150 352 L416 352 C438 352 456 350 466 334 C400 336 200 338 90 331.5 C103 344 123 352 150 352 Z"
CLOUD_INK = [(146, 232, 158, 232, 168, 238, 174, 248), (346, 206, 332, 210, 322, 220, 318, 232),
             (432, 272, 420, 272, 410, 278, 404, 288)]


def cloud(a, s=1.0, dx=0.0, dy=0.0, flip=False, fill=WHITE, shade="#cfe6f7", ow=11):
    """雲: こぶが出会う所をくぼませた1本の輪郭。もとの形は x 70〜480、y 140〜352。"""
    fl = 275 if flip else None
    with a.part(ow):
        a.sil(tf(CLOUD, s, dx, dy, flip=fl), fill)
        a.blob(tf(CLOUD_SHADE, s, dx, dy, flip=fl), shade)
        for c in CLOUD_INK:
            a.ink([tc(c, s, dx, dy, flip=fl)], max(5, 9 * s), a=1, b=0)


def island(a, cx, cy, rx, ry, col=G1, shade=G2, tufts=()):
    """足もとの草の島。下に影、草のしるしを少し。"""
    d = circ(cx, cy, rx, ry)
    with a.part():
        a.sil(d, col)
        a.blob(rim(d, 90, 80, ry * 0.42), shade)
        for x, y in tufts:
            tuft(a, x, y, shade)


def tuft(a, x, y, col=G2, s=1.0):
    for dx, lean in ((-9, -7), (0, 0), (9, 7)):
        a.ink([(x + dx * s, y, x + dx * s, y - 6 * s, x + (dx + lean * 0.5) * s, y - 12 * s, x + (dx + lean) * s, y - 16 * s)],
              5 * s, a=1, b=0, col=col)


CROWN = ("M-74 62 C-116 62 -128 10 -94 -12 C-110 -62 -60 -98 -22 -78 C-4 -114 64 -110 72 -66 "
         "C114 -64 126 -6 94 16 C116 52 86 66 62 62 Z")
CROWN_INK = [(-94, -12, -80, -10, -70, -2, -64, 10), (-22, -78, -14, -68, -12, -58, -16, -46),
             (72, -66, 60, -62, 52, -54, 48, -42)]
PINE = ("M0 -150 C12 -118 40 -90 58 -76 C46 -72 38 -72 30 -74 C44 -46 66 -20 82 -8 C68 -2 56 -4 44 -8 "
        "C58 22 84 46 102 58 C60 72 -60 72 -102 58 C-84 46 -58 22 -44 -8 C-56 -4 -68 -2 -82 -8 "
        "C-66 -20 -44 -46 -30 -74 C-38 -72 -46 -72 -58 -76 C-40 -90 -12 -118 0 -150 Z")


def tree(a, x, base, s=1.0, col=G2, shade=G3, trunk=BARK, h=70):
    """丸い木。みきは下へ少し広がる。葉は、こぶが3つの1本の輪郭。"""
    with a.part():
        a.sil(f"M{_F(x - 13 * s)} {_F(base - h * s - 20 * s)} L{_F(x + 13 * s)} {_F(base - h * s - 20 * s)} "
              f"C{_F(x + 13 * s)} {_F(base - 20 * s)} {_F(x + 16 * s)} {_F(base - 6 * s)} {_F(x + 24 * s)} {_F(base)} "
              f"L{_F(x - 24 * s)} {_F(base)} C{_F(x - 16 * s)} {_F(base - 6 * s)} {_F(x - 13 * s)} {_F(base - 20 * s)} {_F(x - 13 * s)} {_F(base - h * s - 20 * s)} Z",
              trunk)
    cy = base - h * s - 50 * s
    d = tf(CROWN, s, x, cy)
    with a.part():
        a.sil(d, col)
        a.blob(rim(d, 55, 75, 26 * s), shade)
        for c in CROWN_INK:
            a.ink([tc(c, s, x, cy)], max(5, 8 * s), a=1, b=0)
    a.shine(tf("M-78 -30 C-78 -52 -62 -68 -42 -70", s, x, cy), sw=max(5, 7 * s))


def pine(a, x, base, s=1.0, col=G3, shade="#3f8a40", trunk=BARK):
    with a.part():
        a.sil(rect(x - 13 * s, base - 50 * s, 26 * s, 50 * s, 3), trunk)
    d = tf(PINE, s, x, base - 96 * s)
    with a.part():
        a.sil(d, col)
        a.blob(tf("M30 -74 C44 -46 66 -20 82 -8 C68 -2 56 -4 44 -8 C58 22 84 46 102 58 C80 66 50 70 20 71 "
                  "C40 40 30 10 22 -8 C30 -30 24 -56 14 -74 C22 -72 26 -72 30 -74 Z", s, x, base - 96 * s), shade)


def bush(a, x, base, s=1.0, col=G2, shade=G3, flip=False, ow=9):
    d = tf("M-58 0 C-70 -30 -44 -52 -20 -40 C-8 -66 36 -64 42 -34 C66 -34 72 -8 58 0 Z", s, x, base, flip=0 if flip else None)
    with a.part(ow):
        a.sil(d, col)
        a.blob(rim(d, 60, 70, 12 * s), shade)
        a.ink([tc((-20, -40, -12, -34, -10, -26, -12, -18), s, x, base, flip=0 if flip else None)], max(4, 7 * s), a=1, b=0)


def flower(a, x, y, r=13, col=WHITE, mid=YEL2, stem=None):
    if stem:
        a.ink([(x, y, x - 2, y + stem * 0.4, x + 2, y + stem * 0.7, x, y + stem)], 5, a=1, b=1, col=G3)
    with a.part(5):
        a.sil(wool(x, y, r * 0.72, r * 0.72, 5, start=-math.pi / 2, puff=0.55), col)
    a.dot(x, y, r * 0.34, mid)


# ------------------------------------------------------------------ えき --
@place
def eki():
    a = Art()
    # 奥の電車（たてものの右から顔を出す）
    with a.part():
        a.sil(rpoly([(286, 262), (470, 262), (470, 404), (286, 404)], [0, 34, 14, 0]), CREAM)
        a.blob("M287 348 L469 348 L469 366 L287 366 Z", G2)
        a.blob(rpoly([(287, 384), (469, 384), (469, 403), (287, 403)], [0, 0, 13, 0]), "#e4d9c4")
    glass(a, rpoly([(404, 284), (452, 284), (452, 334), (404, 334)], [8, 18, 8, 8]))
    glass(a, rect(340, 284, 48, 50, 8))
    glint(a, 350, 294, 16)
    with a.part(6):
        a.sil(circ(444, 376, 9), YEL2)
    # たてもの
    with a.part():                                    # とけいの塔
        a.sil(rect(150, 100, 104, 120, 6), WALL)
    with a.part():
        a.sil(rpoly([(202, 44), (272, 108), (132, 108)], [12, 12, 12]), RED)
        a.blob(rpoly([(246, 86), (270, 107), (160, 107), (236, 100)], [0, 10, 0, 0]), RED_D)
    with a.part():                                    # かべ
        a.sil(rpoly([(70, 236), (334, 236), (334, 404), (70, 404)], [0, 0, 8, 8]), WALL)
        a.blob("M71 262 L333 262 L333 278 L71 278 Z", WALL_D)
    with a.part():                                    # やね
        a.sil(rpoly([(86, 176), (318, 176), (360, 252), (44, 252)], [14, 14, 14, 14]), RED)
        a.blob(rpoly([(54, 234), (350, 234), (359, 251), (45, 251)], [0, 0, 12, 12]), RED_D)
    a.shine("M92 196 L74 228")
    with a.part(8):                                   # とけい
        a.sil(circ(202, 160, 36), WHITE)
    line(a, 202, 160, 202, 138, 7)
    line(a, 202, 160, 220, 168, 7)
    a.dot(202, 160, 5, O)
    with a.part(9):                                   # 入口
        a.sil("M162 404 L162 322 C162 284 242 284 242 322 L242 404 Z", "#7a5a48")
        a.blob("M172 404 L172 324 C172 298 232 298 232 324 L232 404 Z", "#fbe2a6")
    line(a, 202, 300, 202, 402, 6)
    for x in (92, 262):                               # まど
        glass(a, rect(x, 300, 50, 54, 8))
        glint(a, x + 10, 310, 16)
    # ホーム（きいろい線）
    with a.part():
        a.sil(rect(30, 398, 452, 50, 12), GREY_L)
        a.blob("M36 408 L476 408 L476 420 L36 420 Z", YEL2)
        a.blob(rpoly([(31, 430), (481, 430), (481, 447), (31, 447)], [0, 0, 11, 11]), GREY)
    return a


# ------------------------------------------------------------------ みち --
@place
def michi():
    a = Art()
    hill = ("M30 408 C30 300 140 228 256 228 C372 228 482 300 482 408 C482 434 462 450 436 450 "
            "L76 450 C50 450 30 434 30 408 Z")
    road = "M118 449 C150 392 300 372 262 318 C240 286 232 262 236 230 L290 232 C292 262 306 280 336 312 C420 396 372 420 380 449 Z"
    with a.part():
        a.sil(hill, G1)
        a.blob(rim(hill, 90, 75, 30), G2)
        a.blob(road, "#8f8a86")
        mid = [(248, 449, 280, 396, 360, 372, 300, 316), (300, 316, 268, 286, 262, 262, 263, 232)]
        for t0, t1, w in ((0.05, 0.17, 16), (0.27, 0.38, 13), (0.5, 0.6, 10), (0.7, 0.78, 8), (0.87, 0.93, 6)):
            pts = [at(mid, t0, w / 2), at(mid, t1, w * 0.42), at(mid, t1, -w * 0.42), at(mid, t0, -w / 2)]
            a.blob("M" + " L".join(f"{_F(x)} {_F(y)}" for x, y in pts) + " Z", WHITE)
        tuft(a, 80, 400, G2)
        tuft(a, 440, 372, G2)
    # ポスト（ひだり）
    with a.part():
        a.sil(rect(100, 356, 44, 26, 6), GREY)
    with a.part():
        a.sil("M72 362 L72 266 C72 222 172 222 172 266 L172 362 C172 370 166 374 158 374 L86 374 C78 374 72 370 72 362 Z", RED)
        a.blob("M152 240 C166 248 171 256 171 266 L171 362 C171 369 166 373 158 373 L140 373 C150 366 152 356 152 344 Z", RED_D)
        a.blob(rect(92, 276, 60, 13, 6), "#7a2a26")
    with a.part(6):
        a.sil(rect(102, 306, 40, 28, 6), CREAM)
    a.shine("M88 262 C90 252 96 246 104 242")
    # しんごう（みぎ）
    with a.part():
        a.sil(rect(398, 150, 20, 190, 6), GREY)
        a.blob(rect(410, 151, 7, 188, 3), GREY_D)
    with a.part():
        a.sil(rect(322, 66, 172, 78, 34), "#5d6470")
        a.blob(rim(rect(322, 66, 172, 78, 34), 90, 80, 12), "#4b525d")
    for x, col in ((358, "#4cc7a0"), (408, YEL2), (458, RED)):
        with a.part(6):
            a.sil(circ(x, 105, 20), col)
        a.dot(x - 6, 98, 5, WHITE, **{"fill-opacity": "0.7"})
    return a


# ------------------------------------------------------------------ そら --
@place
def sora():
    a = Art()
    cx, cy, R0, bw = 256, 384, 212, 23
    cols = ["#ee5b52", "#f7a94b", "#f6d36b", "#7cc36a", "#4fa8e0"]
    ri = R0 - bw * len(cols)
    ring = lambda ro: chain(arc(cx, cy, ro, 180, 360) + arc(cx, cy, ri, 360, 180))
    with a.part():                                    # にじ
        a.sil(ring(R0), cols[0])
        for i in range(1, len(cols)):
            a.blob(ring(R0 - bw * i), cols[i])
    a.shine(chain(arc(cx, cy, R0 - 11, 206, 246), close=False))
    # おひさま（にじの中からのぼる）
    sx, sy, sr = 256, 344, 58
    rays = []
    for i in range(12):
        t0 = math.radians(i * 30 - 90)
        for rr, dt in ((sr + (4 if i in (5, 6, 7) else 28), 0), (sr + 4, 15)):
            t = t0 + math.radians(dt)
            rays.append((sx + rr * math.cos(t), sy + rr * math.sin(t)))
    with a.part(9):
        a.sil(rpoly(rays, [9, 3] * 12), YEL2)
    with a.part(9):
        d = circ(sx, sy, sr)
        a.sil(d, "#ffdf6b")
        a.blob(rim(d, 50, 70, 13), YEL2)
    face(a, sx, sy - 6, 26, 13, cheek=(42, 22), mouth=18)
    a.shine("M214 314 C220 302 230 294 242 290", sw=6)
    # くも（にじの足もと）
    cloud(a, 0.52, -22, 262)
    cloud(a, 0.52, 248, 262, flip=True)
    return a


# ---------------------------------------------------------- どうぶつえん --
@place
def dobutsuen():
    a = Art()
    island(a, 256, 460, 236, 18)
    GY, GY_D, GSPOT, MUZ = "#f8d568", "#eab94a", "#c9853c", "#fdeab4"
    LI, LI_D, MANE, MANE_D = "#f8cd6e", "#e9b755", "#d98a3d", "#bf7430"
    # きりん（くびと顔）
    gx = 350
    neck = [(gx, 448, gx, 380, gx + 2, 300, gx, 220)]
    with a.part():
        a.sil(taper([(gx - 48, 430, gx - 46, 360, gx - 42, 290, gx - 40, 226)], 16, 14, cap=False), "#c9853c")   # たてがみ
    with a.part():
        nd = taper(neck, 104, 74, cap=False)
        a.sil(nd, GY)
        a.blob(taper([(gx + 40, 448, gx + 38, 380, gx + 34, 300, gx + 28, 220)], 22, 16, cap=False), GY_D)
        for x, y, r in ((gx - 22, 396, 17), (gx + 16, 352, 15), (gx - 20, 312, 13), (gx + 14, 420, 12)):
            a.blob(rpoly([(x - r, y - r * 0.7), (x + r * 0.5, y - r), (x + r, y + r * 0.4), (x - r * 0.3, y + r)], r * 0.6), GSPOT)
    with a.part(8):                                   # つの
        for s in (-1, 1):
            a.sil(taper([(gx + s * 24, 132, gx + s * 26, 112, gx + s * 28, 96, gx + s * 30, 82)], 16, 14, cap=False), GY)
            a.sil(circ(gx + s * 30, 76, 12), GSPOT)
    with a.part(9):                                   # みみ
        for s in (-1, 1):
            ear = "M286 172 C258 146 226 148 212 166 C226 190 260 196 290 190 Z"
            a.sil(tf(ear, flip=gx) if s > 0 else ear, GY)
        for s in (-1, 1):
            inn = "M276 174 C258 160 238 160 228 168 C240 180 258 184 278 182 Z"
            a.blob(tf(inn, flip=gx) if s > 0 else inn, PINK)
    head = ("M350 112 C400 112 426 146 426 186 C426 210 418 228 410 240 C414 278 388 300 350 300 "
            "C312 300 286 278 290 240 C282 228 274 210 274 186 C274 146 300 112 350 112 Z")
    with a.part():
        a.sil(head, GY)
        a.blob(circ(gx, 262, 48, 33), MUZ)
        a.blob(rpoly([(gx - 14, 126), (gx + 12, 122), (gx + 18, 142), (gx - 6, 148)], 9), GSPOT)
    face(a, gx, 198, 34, 15, cheek=(56, 30))
    a.dot(gx - 14, 254, 4.5, "#8a5a36")
    a.dot(gx + 14, 254, 4.5, "#8a5a36")
    a.path(f"M{gx - 12} 274 C{gx - 5} 283 {gx + 5} 283 {gx + 12} 274", sw=6)
    a.shine("M296 160 C302 144 314 134 328 130", sw=6)
    # ライオン（さくの上に顔と手）
    lx = 150
    with a.part():
        a.sil(f"M{lx - 62} 452 C{lx - 66} 400 {lx - 40} 372 {lx} 372 C{lx + 40} 372 {lx + 66} 400 {lx + 62} 452 Z", LI)
    md = wool(lx, 296, 88, 86, 11, start=0.2, puff=0.5)
    with a.part():
        a.sil(md, MANE)
        a.blob(rim(md, 70, 80, 22), MANE_D)
    with a.part(9):
        for s in (-1, 1):
            a.sil(circ(lx + s * 48, 250, 20, 19), LI)
        hd = circ(lx, 302, 66, 60)
        a.sil(hd, LI)
        for s in (-1, 1):
            a.blob(circ(lx + s * 46, 252, 10, 9), "#f3a48f")
        a.blob(hd, LI)
        a.blob(circ(lx, 326, 30, 22), CREAM)
    face(a, lx, 298, 30, 14, cheek=(50, 26))
    a.blob(f"M{lx - 11} 312 C{lx - 11} 304 {lx + 11} 304 {lx + 11} 312 C{lx + 11} 318 {lx + 3} 323 {lx} 323 C{lx - 3} 323 {lx - 11} 318 {lx - 11} 312 Z", "#8a5a36")
    a.path(f"M{lx} 323 L{lx} 329 M{lx} 329 C{lx - 4} 337 {lx - 14} 337 {lx - 17} 330 M{lx} 329 C{lx + 4} 337 {lx + 14} 337 {lx + 17} 330", sw=5.5)
    # さく（1つの部品）
    with a.part(9):
        for y in (378, 428):
            a.sil(rect(40, y, 432, 22, 8), WOOD)
        for x in (44, 240, 436):
            a.sil(rpoly([(x, 356), (x + 32, 356), (x + 32, 466), (x, 466)], [13, 13, 5, 5]), WOOD)
        for y in (378, 428):
            a.blob(f"M46 {y + 14} L466 {y + 14} L466 {y + 21} L46 {y + 21} Z", "#e09d4f")
        for x in (44, 240, 436):
            a.blob(rpoly([(x + 22, 358), (x + 31, 364), (x + 31, 465), (x + 22, 465)], [0, 8, 4, 0]), "#e09d4f")
            a.blob(rect(x + 1, 378, 21, 14, 0), WOOD)
            a.blob(rect(x + 1, 428, 21, 14, 0), WOOD)
    for s in (-1, 1):                                 # ライオンの手
        with a.part(8):
            a.sil(rpoly([(lx + s * 40 - 17, 366), (lx + s * 40 + 17, 366), (lx + s * 40 + 17, 394), (lx + s * 40 - 17, 394)], [14, 14, 12, 12]), LI)
        line(a, lx + s * 40, 382, lx + s * 40, 393, 5, s=0, e=1)
    return a


# ---------------------------------------------------------------- まきば --
@place
def makiba():
    a = Art()
    island(a, 256, 416, 228, 44, tufts=((120, 440), (330, 446)))
    BARN, BARN_D, ROOF, ROOF_D = "#e5534b", "#c9403a", "#8a6a58", "#74574a"
    # サイロ
    with a.part():
        a.sil(rect(338, 190, 78, 214, 4), CREAM)
        a.blob(rect(392, 191, 23, 212, 0), "#eadcc4")
        for y in (250, 310, 366):
            a.blob(rect(339, y, 76, 7, 0), "#e0cfb2")
    with a.part():
        d = "M330 196 C330 140 356 112 377 112 C398 112 424 140 424 196 Z"
        a.sil(d, ROOF)
        a.blob(rim(d, 20, 60, 14), ROOF_D)
    # こや
    with a.part():
        a.sil(rpoly([(96, 240), (330, 240), (330, 410), (96, 410)], [0, 0, 6, 6]), BARN)
        a.blob("M97 262 L329 262 L329 276 L97 276 Z", BARN_D)
        a.blob(rect(304, 262, 25, 147, 0), BARN_D)
    with a.part():
        roof = rpoly([(213, 98), (318, 140), (352, 250), (74, 250), (108, 140)], [14, 14, 12, 12, 14])
        a.sil(roof, ROOF)
        a.blob(rpoly([(84, 232), (342, 232), (351, 249), (75, 249)], [0, 0, 10, 10]), ROOF_D)
    with a.part(8):
        a.sil(rpoly([(213, 128), (292, 160), (310, 232), (116, 232), (134, 160)], [8, 8, 0, 0, 8]), BARN)
    with a.part(6):
        a.sil(circ(213, 190, 24), CREAM)
    line(a, 213, 168, 213, 212, 5)
    line(a, 191, 190, 235, 190, 5)
    with a.part(8):                                   # とびら
        a.sil(rect(158, 288, 110, 122, 6), WHITE)
        a.blob(rect(166, 296, 94, 114, 2), "#d9483f")
    for x0, y0, x1, y1 in ((166, 296, 260, 410), (260, 296, 166, 410)):
        line(a, x0, y0, x1, y1, 9, col=WHITE)
    line(a, 213, 296, 213, 410, 5)
    a.shine("M112 292 L112 350", sw=6)
    # さく（ひだり）
    with a.part(9):
        for y in (396, 420):
            a.sil(rect(34, y, 112, 14, 6), WOOD)
        for x in (40, 84, 128):
            a.sil(rpoly([(x, 376), (x + 20, 376), (x + 20, 448), (x, 448)], [9, 9, 4, 4]), WOOD)
    # ひつじ（みぎ手前）
    sx, sy = 384, 390
    with a.part(8):
        for x in (sx - 30, sx - 8, sx + 22, sx + 44):
            a.sil(rpoly([(x - 8, sy + 20), (x + 8, sy + 20), (x + 8, sy + 50), (x - 8, sy + 50)], [0, 0, 7, 7]), "#6b5548")
    wd = wool(sx + 8, sy, 62, 42, 11, start=0.1, puff=0.5)
    with a.part(9):
        a.sil(wd, WHITE)
        a.blob(rim(wd, 80, 80, 13), "#dfe9f2")
    hx, hy = sx - 42, sy - 4
    with a.part(8):
        e = "M-28 -12 C-46 -20 -60 -14 -64 -2 C-52 6 -36 4 -24 -2 Z"
        a.sil(tf(e, dx=hx, dy=hy), "#f6d9b8")
        a.sil(tf(e, dx=hx, dy=hy, flip=0), "#f6d9b8")
        a.sil(tf("M0 -38 C26 -38 40 -20 40 0 C40 26 24 40 0 40 C-24 40 -40 26 -40 0 C-40 -20 -26 -38 0 -38 Z", dx=hx, dy=hy), "#f6d9b8")
    with a.part(7):
        a.sil(wool(hx, hy - 34, 24, 12, 5, start=0.3, puff=0.55), WHITE)
    face(a, hx, hy, 17, 9, cheek=(28, 14))
    a.path(f"M{hx - 6} {hy + 20} C{hx - 3} {hy + 25} {hx + 3} {hy + 25} {hx + 6} {hy + 20}", sw=4.5)
    return a


# ------------------------------------------------------------------ もり --
@place
def mori():
    a = Art()
    island(a, 256, 424, 228, 42, tufts=((330, 450), (96, 430)))
    pine(a, 262, 398, 1.5)
    tree(a, 128, 420, 1.12, col=G2, shade=G3)
    tree(a, 392, 414, 1.0, col="#8fd070", shade=G2, h=60)
    # きのこ（まんなか手前）
    with a.part(9):
        sd = "M238 392 C238 420 230 444 244 446 L286 446 C300 444 292 420 292 392 Z"
        a.sil(sd, CREAM)
        a.blob("M280 394 C280 420 286 438 280 445 L286 445 C299 443 291 420 291 394 Z", "#f0dfc4")
    with a.part(9):
        cap = ("M190 396 C184 340 222 312 265 312 C308 312 346 340 340 396 C340 408 330 410 322 406 "
               "C290 396 240 396 208 406 C200 410 190 408 190 396 Z")
        a.sil(cap, RED)
        a.blob(rim(cap, 30, 70, 16), RED_D)
        for x, y, r in ((226, 362, 12), (268, 340, 14), (310, 370, 10)):
            a.blob(circ(x, y, r, r * 0.9), "#fffaf0")
    a.shine("M204 368 C206 350 216 338 228 332", sw=6)
    bush(a, 398, 446, 0.7)
    flower(a, 150, 440, 13, stem=None)
    flower(a, 184, 452, 11, col="#ffd5e0")
    return a


# ---------------------------------------------------------------- おうち --
@place
def ie():
    a = Art()
    island(a, 256, 420, 228, 44, tufts=((108, 440),))
    # けむり
    with a.part(7):
        a.sil(wool(366, 78, 20, 15, 6, puff=0.5), WHITE)
    with a.part(7):
        a.sil(wool(392, 44, 14, 11, 5, puff=0.5), WHITE)
    with a.part():                                    # えんとつ
        a.sil(rect(332, 112, 50, 110, 4), BARK)
        a.blob(rect(366, 113, 15, 108, 0), "#a3683d")
    with a.part():
        a.sil(rect(322, 100, 70, 24, 8), "#a8672f")
    with a.part():                                    # かべ
        a.sil(rpoly([(110, 240), (402, 240), (402, 416), (110, 416)], [0, 0, 10, 10]), WALL)
        a.blob("M111 272 L401 272 L401 290 L111 290 Z", WALL_D)
    with a.part():                                    # やね
        a.sil("M256 86 Q270 86 282 96 L440 238 Q456 252 448 266 Q442 278 426 278 L86 278 Q70 278 64 266 "
              "Q56 252 72 238 L230 96 Q242 86 256 86 Z", ORANGE)
        a.blob("M72 256 L440 256 Q452 258 447 267 Q442 277 426 277 L86 277 Q70 277 65 267 Q60 258 72 256 Z", ORANGE_D)
    a.shine("M218 130 L170 172")
    glass(a, circ(256, 196, 27))
    line(a, 232, 196, 280, 196, 5)
    line(a, 256, 172, 256, 220, 5)
    with a.part(9):                                   # ドア
        a.sil("M218 416 L218 342 C218 302 294 302 294 342 L294 416 Z", "#d98a4e")
        a.blob("M278 322 C288 328 293 334 293 342 L293 415 L278 415 Z", "#c2743a")
    with a.part(5):
        a.sil(circ(256, 344, 13), SKY)
    a.dot(280, 376, 6, YEL2)
    for x in (134, 318):                              # まど（花の箱つき）
        glass(a, rect(x, 304, 60, 58, 8))
        line(a, x + 30, 308, x + 30, 358, 5)
        line(a, x + 4, 333, x + 56, 333, 5)
        with a.part(6):
            a.sil(rect(x - 4, 362, 68, 18, 5), "#c97f3e")
        for i, col in enumerate((RED, YEL2, PINK)):
            a.dot(x + 12 + i * 18, 358, 7.5, col)
    # ふみ石と しげみ
    with a.part(6):
        a.sil(circ(256, 434, 26, 9), GREY_L)
    with a.part(6):
        a.sil(circ(238, 454, 20, 7), GREY_L)
    bush(a, 86, 424, 0.72)
    bush(a, 428, 424, 0.72, flip=True)
    return a


# ------------------------------------------------------------------ うみ --
@place
def umi():
    a = Art()
    B, BD, BELLY, SP = "#5ab0e8", "#3f97d0", "#eaf6ff", "#a6dcf8"
    s, dx, dy = 0.86, 14, 6
    T = lambda d: tf(d, s, dx, dy)
    C = lambda *c: tc(c, s, dx, dy)
    with a.part(9):                                   # しおふき
        for k in (-1, 1):
            a.sil(T(taper([(214, 150, 214, 110, 214 + k * 14, 82, 214 + k * 50, 78),
                           (214 + k * 50, 78, 214 + k * 74, 76, 214 + k * 84, 96, 214 + k * 80, 112)], 26, 20)), SP)
    with a.part():                                    # くじら
        a.sil(T(taper([(392, 340, 440, 336, 464, 296, 464, 250)], 80, 34, cap=False)), B)
        a.sil(T("M464 268 C430 256 408 226 412 192 C440 192 458 212 464 234 C470 212 488 192 516 192 "
                "C520 226 498 256 464 268 Z"), B)
        a.sil(T("M60 304 C56 206 136 146 250 146 C356 146 416 214 420 296 C422 364 350 410 240 410 "
                "C136 410 62 374 60 304 Z"), B)
        a.blob(T("M66 330 C130 372 330 384 416 322 C410 374 344 408 240 408 C144 408 78 380 66 330 Z"), BELLY)
    face(a, s * 150 + dx, s * 262 + dy, s * 40, 15, cheek=(s * 66, 28), mouth=24)
    a.shine(T("M118 214 C142 186 180 170 222 166"))
    # なみ（奥・手前）
    def waves(x0, x1, y, n, amp, bottom, col, shade):
        w = (x1 - x0) / n
        d = [f"M{_F(x0)} {_F(y)}"]
        for i in range(n):
            xa, xb = x0 + i * w, x0 + (i + 1) * w
            d.append(f"C{_F(xa + w * 0.18)} {_F(y - amp)} {_F(xa + w * 0.58)} {_F(y - amp)} {_F(xa + w * 0.72)} {_F(y - amp * 0.1)} "
                     f"C{_F(xa + w * 0.8)} {_F(y + amp * 0.5)} {_F(xa + w * 0.94)} {_F(y + amp * 0.3)} {_F(xb)} {_F(y)}")
        d.append(f"L{_F(x1)} {_F(bottom - 16)} Q{_F(x1)} {_F(bottom)} {_F(x1 - 16)} {_F(bottom)} L{_F(x0 + 16)} {_F(bottom)} "
                 f"Q{_F(x0)} {_F(bottom)} {_F(x0)} {_F(bottom - 16)} Z")
        with a.part():
            a.sil(" ".join(d), col)
            if shade:
                a.blob(rpoly([(x0 + 1, bottom - 22), (x1 - 1, bottom - 22), (x1 - 1, bottom - 1), (x0 + 1, bottom - 1)], [0, 0, 15, 15]), shade)
            for i in range(n):
                xa = x0 + i * w
                a.ink([(xa + w * 0.2, y - amp * 0.45, xa + w * 0.34, y - amp * 0.75, xa + w * 0.5, y - amp * 0.72, xa + w * 0.6, y - amp * 0.4)],
                      5, a=0, b=0, col=WHITE)
    waves(30, 482, 372, 5, 20, 452, "#7cc4ee", None)
    waves(30, 482, 406, 4, 22, 456, BD, "#3489c2")
    return a


# ------------------------------------------------------------------ かわ --
@place
def kawa():
    a = Art()
    with a.part():                                    # 奥の山
        a.sil("M44 360 C60 190 210 170 262 330 Z", "#7fc98a")
        a.sil("M226 340 C280 150 440 180 472 360 Z", "#66b877")
        a.ink([(262, 330, 254, 306, 246, 288, 236, 272)], 8, a=1, b=0)
    land = ("M28 380 C28 322 120 290 256 290 C392 290 484 322 484 380 C484 426 440 452 372 460 "
            "L140 460 C72 452 28 426 28 380 Z")
    river = ("M238 291 C222 322 330 334 318 366 C304 402 168 404 140 460 L372 460 C380 428 440 396 404 348 "
             "C380 316 300 322 284 291 Z")
    with a.part():
        a.sil(land, G1)
        a.blob(rim(land, 90, 80, 22), G2)
        a.blob(river, "#6cc0ec")
        a.blob("M140 460 C146 448 158 438 174 430 L388 430 C380 440 374 450 372 460 Z", "#4fa9dc")
        a.ink([(236, 412, 256, 402, 280, 402, 300, 412)], 7, a=0, b=0, col=WHITE)
        a.ink([(312, 440, 328, 432, 346, 432, 362, 440)], 6, a=0, b=0, col=WHITE)
        a.ink([(290, 322, 302, 316, 316, 316, 328, 322)], 5, a=0, b=0, col=WHITE)
        tuft(a, 440, 420, G2)
        tuft(a, 70, 372, G2)
    # はし（たいこばし）
    with a.part(9):
        for x, y in ((262, 352), (318, 328), (378, 330), (430, 356)):
            a.sil(rect(x - 7, y - 30, 14, 46, 6), RED)
        a.sil(taper([(242, 340, 290, 276, 400, 278, 448, 344)], 13, 13), RED)
        a.sil(taper([(230, 388, 286, 318, 404, 320, 458, 386)], 34, 34), "#f0a070")
        a.blob(taper([(235, 395, 288, 328, 403, 330, 453, 393)], 11, 11, cap=False), "#d9814f")
    # かえる（ひだり手前）
    FG, FB = "#7fcb6c", "#eaf7cc"
    k, fx, fy = 0.44, 12, 246
    T = lambda d: tf(d, k, fx, fy)
    cxl = 256
    leg = "M134 316 C76 316 48 368 58 408 C64 440 94 456 150 456 L204 456 C204 392 182 328 134 316 Z"
    with a.part(9):
        a.sil(T(leg), FG)
        a.sil(T(mirror(leg, cxl)), FG)
    with a.part(9):
        for sg in (-1, 1):
            a.sil(T(circ(cxl + sg * 84, 142, 60, 58)), FG)
        a.sil(T("M256 146 C356 146 422 194 422 262 C422 300 400 328 372 342 C392 374 388 420 360 442 "
                "C330 458 182 458 152 442 C124 420 120 374 140 342 C112 328 90 300 90 262 C90 194 156 146 256 146 Z"), FG)
        a.blob(T("M256 332 C310 332 340 368 336 406 C330 438 300 450 256 450 C212 450 182 438 176 406 "
                 "C172 368 202 332 256 332 Z"), FB)
    for sg in (-1, 1):
        ex, ey = k * (cxl + sg * 84) + fx, k * 144 + fy
        a.blob(T(circ(cxl + sg * 84, 142, 38, 40)), WHITE)
        a.eye(ex, ey, 11)
        a.ellipse(k * (cxl + sg * 126) + fx, k * 270 + fy, 8.5, 5.5, "#f3b3a4", sw=0, stroke="none")
    a.path(T("M196 256 C226 292 286 292 316 256"), sw=5.5)
    a.shine(T("M118 248 C122 222 138 204 160 196"), sw=5)
    # がま（みぎ）
    for x, top, h in ((452, 300, 110), (430, 330, 84)):
        a.ink([(x, top + h, x - 2, top + h * 0.6, x + 2, top + h * 0.3, x, top)], 6, a=1, b=1, col=G3)
        with a.part(6):
            a.sil(rect(x - 9, top - 4, 18, 42, 9), "#9b6238")
    with a.part(7):                                   # 石
        a.sil("M276 446 C272 428 292 418 310 424 C326 428 330 446 320 450 C306 454 284 454 276 446 Z", GREY_L)
        a.blob("M296 450 C312 446 320 438 320 430 C330 438 328 448 320 450 C312 452 304 452 296 450 Z", GREY)
    return a


# ---------------------------------------------------------------- おみせ --
@place
def omise():
    a = Art()
    with a.part():                                    # かんばん
        a.sil(rect(150, 62, 212, 74, 16), "#5cbfae")
        a.blob(rpoly([(151, 116), (361, 116), (361, 135), (151, 135)], [0, 0, 15, 15]), "#46a595")
    with a.part(6):                                   # かんばんの りんご
        a.sil("M256 82 C270 74 290 82 290 100 C290 116 276 126 256 122 C236 126 222 116 222 100 C222 82 242 74 256 82 Z", RED)
    a.ink([(256, 84, 256, 78, 260, 72, 266, 70)], 5, a=1, b=1)
    a.dot(244, 96, 4.5, WHITE, **{"fill-opacity": "0.7"})
    with a.part():                                    # みせ
        a.sil(rpoly([(76, 130), (436, 130), (436, 440), (76, 440)], [10, 10, 10, 10]), WALL)
        a.blob(rpoly([(77, 410), (435, 410), (435, 439), (77, 439)], [0, 0, 9, 9]), WALL_D)
    # まどと ドア
    glass(a, rect(104, 262, 150, 100, 10))
    glint(a, 120, 276, 22)
    with a.part(9):
        a.sil("M292 440 L292 300 C292 262 396 262 396 300 L396 440 Z", "#d98a4e")
        a.blob("M376 280 C390 286 395 292 395 300 L395 439 L376 439 Z", "#c2743a")
    glass(a, "M312 360 L312 304 C312 284 376 284 376 304 L376 360 Z", ow=5)
    a.dot(380, 392, 6.5, YEL2)
    # ひさし（しま）
    n, x0, x1, y0, y1 = 6, 56, 456, 150, 226
    w = (x1 - x0) / n
    top = [f"M{x0 + 22} {y0 - 22} L{x1 - 22} {y0 - 22} L{x1} {y1 - 14}"]
    bot = []
    for i in range(n - 1, -1, -1):
        xa, xb = x0 + i * w, x0 + (i + 1) * w
        bot.append(f"C{_F(xb)} {y1 + 24} {_F(xa)} {y1 + 24} {_F(xa)} {y1 - 14}")
    aw = " ".join(top + bot) + " Z"
    with a.part():
        a.sil(aw, WHITE)
        for i in range(0, n, 2):
            xa, xb = x0 + i * w, x0 + (i + 1) * w
            ta = x0 + 22 + (x1 - x0 - 44) * i / n
            tb = x0 + 22 + (x1 - x0 - 44) * (i + 1) / n
            a.blob(f"M{_F(ta)} {y0 - 22} L{_F(tb)} {y0 - 22} L{_F(xb)} {y1 - 14} C{_F(xb)} {y1 + 24} {_F(xa)} {y1 + 24} {_F(xa)} {y1 - 14} Z", RED)
        for i in range(1, n):
            xa = x0 + i * w
            a.ink([seg(xa, y1 + 2, xa, y1 - 22)], 7, a=1, b=0)
    a.shine(f"M{x0 + 34} {y0 - 6} L{x0 + 20} {y1 - 30}", sw=6)
    # はこと くだもの
    for x, y, r, col, cd in ((132, 372, 25, RED, RED_D), (228, 372, 25, YEL2, YEL_D), (180, 362, 28, ORANGE, ORANGE_D)):
        d = circ(x, y, r, r * 0.94)
        with a.part(8):
            a.sil(d, col)
            a.blob(rim(d, 45, 70, 8), cd)
        a.dot(x - r * 0.35, y - r * 0.4, r * 0.18, WHITE, **{"fill-opacity": "0.7"})
    a.ink([(180, 336, 180, 330, 184, 324, 190, 322)], 5, a=1, b=1)
    with a.part():
        a.sil(rpoly([(92, 384), (268, 384), (258, 452), (102, 452)], [8, 8, 10, 10]), WOOD)
        a.blob(rpoly([(94, 430), (266, 430), (258, 451), (102, 451)], [0, 0, 9, 9]), "#e09d4f")
        line(a, 96, 408, 264, 408, 5, col=WOOD_D)
    return a


# -------------------------------------------------------------- こうえん --
@place
def koen():
    a = Art()
    island(a, 256, 424, 228, 42, tufts=((60, 426), (290, 454)))
    tree(a, 100, 400, 1.0, col=G2, shade=G3, h=84)
    FR, FR_D = "#e5534b", "#c9403a"
    # ぶらんこ: 奥のあし → くさりと いす → 手前のわく
    with a.part():
        a.sil(taper([seg(252, 150, 284, 400)], 20, 20), FR_D)
        a.sil(taper([seg(436, 150, 404, 400)], 20, 20), FR_D)
    for x, col, cd in ((300, YEL2, YEL_D), (388, BLUE, BLUE_D)):
        line(a, x - 24, 150, x - 24, 318, 6)
        line(a, x + 24, 150, x + 24, 318, 6)
        with a.part(8):
            a.sil(rect(x - 36, 312, 72, 22, 9), col)
            a.blob(rect(x - 34, 324, 68, 9, 4), cd)
    with a.part():
        a.sil(taper([seg(236, 142, 200, 436)], 24, 24), FR)
        a.sil(taper([seg(452, 142, 484, 436)], 24, 24), FR)
        a.sil(rect(220, 128, 248, 28, 14), FR)
        a.blob(rect(232, 146, 224, 9, 4), FR_D)
    a.shine("M230 180 L212 320", sw=6)
    # ボール
    with a.part(9):
        a.sil(circ(344, 432, 30), YEL2)
        a.blob("M316 424 C332 436 356 436 372 424 C376 436 372 448 364 454 C348 446 332 444 318 446 C314 438 314 430 316 424 Z", RED)
    a.dot(332, 416, 5, WHITE, **{"fill-opacity": "0.75"})
    flower(a, 150, 446, 12)
    flower(a, 420, 458, 12, col="#ffd5e0")
    return a


# -------------------------------------------------------------- うちゅう --
@place
def uchu():
    a = Art()
    NIGHT, NIGHT_D = "#3b4a8c", "#2f3b74"
    bg = circ(256, 262, 206, 200)
    with a.part():                                    # よぞら
        a.sil(bg, NIGHT)
        a.blob(rim(bg, 70, 80, 34), NIGHT_D)
        for x, y, r in ((120, 150, 4), (210, 96, 3.5), (396, 150, 4), (420, 330, 3.5), (150, 420, 3.5), (330, 428, 4), (90, 262, 3), (246, 200, 3)):
            a.dot(x, y, r, "#dfe6ff")
    # わくせい（わ つき）
    px, py, pr = 134, 318, 62
    ring_o = tf(circ(0, 0, 104, 26), rot=-18, dx=px, dy=py)
    with a.part(8):                                   # わ（奥）
        a.sil(ring_o, YEL2)
    with a.part(9):
        d = circ(px, py, pr)
        a.sil(d, "#b49cf0")
        a.blob(rim(d, 45, 80, 16), "#957cdb")
        a.blob(tf(rect(-50, -30, 100, 12, 6), rot=-18, dx=px, dy=py), "#cdbcf8")
    front = tf(chain(arc(0, 0, 104, 0, 180, ry=26) + arc(0, 0, 80, 180, 0, ry=12)), rot=-18, dx=px, dy=py)
    with a.part(8):                                   # わ（手前）
        a.sil(front, YEL2)
    # ロケット（ななめ）
    R = lambda d: tf(d, rot=24, dx=316, dy=250)
    with a.part(9):                                   # ほのお
        a.sil(R("M-30 112 C-34 150 -10 176 0 206 C10 176 34 150 30 112 Z"), ORANGE)
        a.blob(R("M-14 114 C-16 138 -6 152 0 170 C6 152 16 138 14 114 Z"), YEL)
    with a.part():                                    # はね
        a.sil(R("M-46 40 C-86 54 -98 96 -92 136 L-40 104 Z"), RED)
        a.sil(R("M46 40 C86 54 98 96 92 136 L40 104 Z"), RED)
    with a.part():
        a.sil(R(rpoly([(-38, 100), (38, 100), (28, 126), (-28, 126)], [0, 0, 8, 8])), GREY)
    with a.part():                                    # からだ
        body = "M0 -168 C44 -128 60 -60 54 30 C52 64 48 88 44 106 L-44 106 C-48 88 -52 64 -54 30 C-60 -60 -44 -128 0 -168 Z"
        a.sil(R(body), WHITE)
        a.blob(R("M0 -168 C22 -148 38 -120 46 -86 L-46 -86 C-38 -120 -22 -148 0 -168 Z"), RED)
        a.blob(R("M30 -84 L46 -84 C56 -40 58 0 54 30 C52 64 48 88 44 105 L24 105 C34 60 38 -20 30 -84 Z"), "#dfe6ee")
        a.blob(R("M-51 62 L51 62 L48 82 L-48 82 Z"), BLUE)
    with a.part(7):
        a.sil(R(circ(0, -16, 30)), "#7a8496")
    a.blob(R(circ(0, -16, 21)), SKY)
    a.path(R("M-10 -10 L4 -26"), stroke=WHITE, sw=6, **{"stroke-opacity": "0.8"})
    # ほし と つき
    for x, y, r in ((112, 150, 24), (420, 236, 18), (238, 86, 15)):
        with a.part(7):
            a.sil(star_d(x, y, r), YEL)
    return a


# ---------------------------------------------------------- きせつ の はた --
@place
def kisetsu():
    a = Art()
    island(a, 150, 448, 110, 20)
    with a.part():                                    # ぽーる
        a.sil(rect(96, 70, 24, 384, 8), WOOD_D)
        a.blob(rect(110, 72, 9, 380, 4), "#a8672f")
    with a.part(8):
        a.sil(circ(108, 58, 20), YEL2)
    a.dot(102, 52, 5, WHITE, **{"fill-opacity": "0.7"})
    # はた（4つの きせつ）
    x0, x1, xm = 120, 468, 294
    yt, ym, yb = 96, 216, 336
    wave = lambda y, xa, xb, s: f"C{_F(xa + (xb - xa) * 0.33)} {_F(y - 16 * s)} {_F(xa + (xb - xa) * 0.67)} {_F(y + 16 * s)} {_F(xb)} {_F(y)}"
    top_l, top_r = wave(yt, x0, xm, 1), wave(yt, xm, x1, 1)
    flag = f"M{x0} {yt} {top_l} {top_r} L{x1} {yb} {wave(yb, x1, xm, -1)} {wave(yb, xm, x0, -1)} Z"
    q_tr = f"M{xm} {yt} {top_r} L{x1} {ym} {wave(ym, x1, xm, -1)} Z"
    q_bl = f"M{x0} {ym} {wave(ym, x0, xm, 1)} L{xm} {yb} {wave(yb, xm, x0, -1)} Z"
    q_br = f"M{xm} {ym} {wave(ym, xm, x1, 1)} L{x1} {yb} {wave(yb, x1, xm, -1)} Z"
    with a.part():
        a.sil(flag, "#f9bfcc")                        # はる
        a.blob(q_tr, "#8fd3f4")                       # なつ
        a.blob(q_bl, "#f7a94b")                       # あき
        a.blob(q_br, "#cfe3f7")                       # ふゆ
    # はる: さくら
    cx, cy = 207, 156
    with a.part(6):
        a.sil(wool(cx, cy, 25, 25, 5, start=-math.pi / 2, puff=0.6), WHITE)
    a.dot(cx, cy, 8, YEL2)
    # なつ: おひさま
    cx, cy = 381, 156
    rays = []
    for i in range(10):
        t0 = math.radians(i * 36 - 90)
        for rr, dt in ((40, 0), (27, 18)):
            t = t0 + math.radians(dt)
            rays.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
    with a.part(6):
        a.sil(rpoly(rays, [5, 2] * 10), YEL2)
        a.blob(circ(cx, cy, 20), "#ffe27a")
    # あき: もみじ
    cx, cy = 207, 272
    with a.part(6):
        a.sil(tf("M0 -40 L11 -16 L34 -24 L24 0 L42 12 L18 16 L20 34 L0 24 L-20 34 L-18 16 L-42 12 L-24 0 L-34 -24 L-11 -16 Z", 0.92, cx, cy), RED)
    a.ink([(cx, cy + 20, cx, cy + 28, cx + 2, cy + 36, cx + 6, cy + 42)], 5, a=1, b=1)
    # ふゆ: ゆきだるま
    cx, cy = 381, 276
    with a.part(6):
        a.sil(circ(cx, cy + 14, 26, 23), WHITE)
        a.sil(circ(cx, cy - 22, 19, 18), WHITE)
        a.blob(rim(circ(cx, cy + 14, 26, 23), 70, 70, 7), "#d6e6f5")
    a.dot(cx - 7, cy - 24, 3.2, EYE)
    a.dot(cx + 7, cy - 24, 3.2, EYE)
    a.blob(rect(cx - 16, cy - 8, 32, 8, 4), RED)
    a.shine(f"M{x0 + 18} {yt + 18} L{x0 + 18} {yt + 80}", sw=6)
    return a


if __name__ == "__main__":
    names = sys.argv[1:] or list(P)
    os.makedirs(OUT, exist_ok=True)
    for n in names:
        with open(os.path.join(OUT, f"{n}.svg"), "w") as f:
            f.write(P[n]().svg())
