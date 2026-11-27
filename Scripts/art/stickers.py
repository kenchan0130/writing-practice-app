"""ステッカー 24枚と「おたのしみ ボックス」の絵（§3.3・D54）。

描き方は ことばの絵と同じ（D176。`Content/Art/style-guide.md`）: 部品は塗りだけで描き、線は部品の外側にだけ付ける。
ステッカーらしく、絵のまわりに白いふちを付ける（`stickerize()`）。

使い方: python3 -I Scripts/art/stickers.py [name...]   （名前を省くと全部）
  SVG は Content/Art/stickers/ と Content/Art/parts/（otanoshimi-box・otanoshimi-lid）に出る。
  アプリへ写すのは Scripts/art/stickers.sh。
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.dont_write_bytecode = True
from lib import Art, fit_params, taper, O  # noqa: E402
from words import (  # noqa: E402
    c_bar, c_circ, c_rpoly, d_leaf, d_rim, d_tf, d_vein, e1_arc, e1_cloud, e1_d, e1_face, e1_star, e2_rr, b_spiral,
)

OUT = os.path.join(HERE, "..", "..", "Content", "Art", "stickers")
PARTS = os.path.join(HERE, "..", "..", "Content", "Art", "parts")

RED, RED_D = "#e5534b", "#c9403a"
YEL, YEL_L, YEL_D = "#ffd84d", "#ffe27a", "#f2b930"
PINK, PINK_D, PINK_L = "#f7778f", "#e45c78", "#ffc2d1"
BLUE, BLUE_D, SKY = "#4fa8e0", "#3f8fc8", "#bfe6fa"
GREEN, GREEN_D = "#7cc36a", "#58a24a"
PURPLE, PURPLE_D = "#9b7fd1", "#7f63b8"
ORANGE, ORANGE_D = "#f7a94b", "#e88f2c"
CREAM, WHITE = "#fff4e2", "#ffffff"
WOOD, WOOD_D = "#f2b56b", "#c97f3e"
BROWN = "#8a5530"

S = {}
ORDER = []


def sticker(f):
    S[f.__name__] = f
    ORDER.append(f.__name__)
    return f


def stickerize(a, border=22, edge=5):
    """White die-cut edge: every shape is drawn again behind the art, fatter and white, with a thin warm rim."""
    back = []
    for col, extra in (("#e3d3c2", border + edge), (WHITE, border)):
        for tag, g, attrs in a.els:
            sw = float(attrs.get("stroke-width", 0)) + 2 * extra
            fill = "none" if attrs.get("fill", "none") == "none" else col
            back.append((tag, dict(g), {"fill": fill, "stroke": col, "stroke-width": sw,
                                        "stroke-linejoin": "round", "stroke-linecap": "round"}))
    a.els[0:0] = back
    return a


def arc_pts(cx, cy, r, a0, a1, n=28):
    return [(cx + r * math.cos(math.radians(a0 + (a1 - a0) * i / n)), cy + r * math.sin(math.radians(a0 + (a1 - a0) * i / n)))
            for i in range(n + 1)]


def poly(pts):
    return "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"


def heart_d(cx, cy, s):
    """A plump heart: (cx, cy) is its middle, s its half width."""
    P = lambda x, y: f"{cx + x * s:.1f} {cy + y * s:.1f}"
    return (f"M{P(0, 0.92)} C{P(-0.62, 0.42)} {P(-1, 0.02)} {P(-1, -0.36)} C{P(-1, -0.72)} {P(-0.74, -0.94)} {P(-0.46, -0.94)} "
            f"C{P(-0.26, -0.94)} {P(-0.08, -0.82)} {P(0, -0.62)} C{P(0.08, -0.82)} {P(0.26, -0.94)} {P(0.46, -0.94)} "
            f"C{P(0.74, -0.94)} {P(1, -0.72)} {P(1, -0.36)} C{P(1, 0.02)} {P(0.62, 0.42)} {P(0, 0.92)} Z")


def sparkle(a, x, y, r, col=YEL):
    """A small four-point twinkle."""
    k = r * 0.28
    a.sil(f"M{x} {y - r} Q{x + k} {y - k} {x + r} {y} Q{x + k} {y + k} {x} {y + r} "
          f"Q{x - k} {y + k} {x - r} {y} Q{x - k} {y - k} {x} {y - r} Z", col)


# ------------------------------------------------------------- stickers --
@sticker
def hoshi():
    a = Art()
    with a.part(12):
        a.sil(e1_star(256, 268, 226, 124), YEL)
        a.blob(e1_star(256, 262, 150, 84), YEL_L)
    e1_face(a, 256, 262, 46, 17)
    a.shine("M214 150 C222 132 234 116 248 104")
    return a


@sticker
def heart():
    a = Art()
    d = heart_d(256, 262, 204)
    with a.part(12):
        a.sil(d, PINK)
        a.blob(d_rim(d, 40, 66, 34), PINK_D)
    e1_face(a, 256, 236, 52, 17, cheek_dx=96)
    a.shine("M118 196 C120 150 146 112 186 98", sw=10)
    return a


@sticker
def hana():
    a = Art()
    with a.part(12):
        for i in range(6):
            t = math.radians(-90 + i * 60)
            a.sil(c_circ(256 + 138 * math.cos(t), 256 + 138 * math.sin(t), 86), PINK_L)
    for i in range(6):
        t = math.radians(-90 + i * 60)
        a.dot(256 + 176 * math.cos(t), 256 + 176 * math.sin(t), 16, "#ffe0e8")
    with a.part(10):
        a.sil(c_circ(256, 256, 112), YEL)
        a.blob(d_rim(c_circ(256, 256, 112), 45, 70, 22), YEL_D)
    e1_face(a, 256, 246, 40, 15)
    return a


@sticker
def niji():
    a = Art()
    cx, cy, R0, bw = 256, 372, 214, 32
    cols = ["#ee5b52", "#f7a94b", "#f6d36b", "#7cc36a", "#4fa8e0"]
    ri = R0 - bw * len(cols)
    ring = lambda ro: e1_d(e1_arc(cx, cy, ro, 180, 360) + e1_arc(cx, cy, ri, 360, 180))
    with a.part(12):
        a.sil(ring(R0), cols[0])
        for i in range(1, len(cols)):
            a.blob(ring(R0 - bw * i), cols[i])
    a.shine(e1_d(e1_arc(cx, cy, R0 - 14, 208, 250), close=False))
    e1_cloud(a, WHITE, "#cfe6f7", 0.52, -22, 244)
    e1_cloud(a, WHITE, "#cfe6f7", 0.52, 268, 244, flip=True)
    return a


@sticker
def kumo():
    a = Art()
    e1_cloud(a, WHITE, "#cfe6f7", ow=12)
    e1_face(a, 262, 276, 50, 16, sleepy=True)
    a.shine("M190 196 C202 176 220 164 242 160")
    with a.part(8):
        sparkle(a, 426, 150, 40)
    with a.part(7):
        sparkle(a, 92, 204, 24, "#ffe27a")
    return a


@sticker
def taiyou():
    a = Art()
    with a.part(12):
        for i in range(10):
            t = math.radians(i * 36 - 90)
            n = (-math.sin(t), math.cos(t))
            bx, by = 256 + 150 * math.cos(t), 256 + 150 * math.sin(t)
            tx, ty = 256 + 236 * math.cos(t), 256 + 236 * math.sin(t)
            a.sil(c_rpoly([(bx + n[0] * 40, by + n[1] * 40), (tx, ty), (bx - n[0] * 40, by - n[1] * 40)], [0, 16, 0]), ORANGE)
        a.sil(c_circ(256, 256, 160), YEL)
        a.blob(d_rim(c_circ(256, 256, 160), 45, 70, 26), YEL_D)
    e1_face(a, 256, 248, 54, 18)
    a.shine("M152 214 C160 176 184 148 216 136", sw=9)
    return a


@sticker
def tsuki():
    a = Art()
    # crescent: big circle minus a circle pushed to the upper right
    c1, r1, c2, r2 = (236, 262), 196, (330, 214), 156
    d = math.hypot(c2[0] - c1[0], c2[1] - c1[1])
    al = math.acos((r1 * r1 + d * d - r2 * r2) / (2 * r1 * d))
    be = math.acos((r2 * r2 + d * d - r1 * r1) / (2 * r2 * d))
    base = math.degrees(math.atan2(c2[1] - c1[1], c2[0] - c1[0]))
    outer = arc_pts(c1[0], c1[1], r1, base + math.degrees(al), base + 360 - math.degrees(al), 60)
    inner = arc_pts(c2[0], c2[1], r2, base - math.degrees(be), base - 360 + math.degrees(be), 44)
    with a.part(12):
        a.sil(poly(outer + inner), YEL)
    a.blob(poly(arc_pts(c1[0], c1[1], r1 - 4, 100, 200, 30) + arc_pts(c1[0] + 26, c1[1] - 10, r1 - 2, 200, 100, 30)), YEL_D)
    for s in (-1, 1):                                    # closed, sleepy eyes
        x = 150 + s * 38
        a.ink([(x - 15, 286, x - 8, 300, x + 8, 300, x + 15, 286)], 8, a=0.7, b=0.7)
    a.cheek(88, 318, 15, 9)
    a.path("M140 322 C146 332 156 332 162 322", sw=7)
    with a.part(9):
        a.sil(e1_star(372, 196, 62, 32), "#fff3b0")
    with a.part(7):
        sparkle(a, 420, 330, 26, WHITE)
    return a


@sticker
def onpu():
    a = Art()
    with a.part(12):
        a.sil(d_tf(c_circ(0, 0, 66, 50), 1, 154, 392, -20), PURPLE)
        a.sil(d_tf(c_circ(0, 0, 66, 50), 1, 360, 344, -20), PURPLE)
        a.sil(c_bar(206, 380, 206, 150, 30), PURPLE)
        a.sil(c_bar(412, 332, 412, 102, 30), PURPLE)
        a.sil(poly([(191, 138), (427, 86), (427, 170), (191, 222)]), PURPLE)
    a.blob(poly([(196, 196), (424, 146), (424, 168), (196, 218)]), PURPLE_D)
    a.shine("M112 376 C118 360 132 350 148 348", sw=8)
    a.shine("M318 328 C324 312 338 302 354 300", sw=8)
    return a


@sticker
def ribbon():
    a = Art()
    loop = "M256 256 C200 168 108 136 66 166 C40 186 40 326 66 346 C108 376 200 344 256 256 Z"
    tail = "M232 280 C204 330 168 392 120 440 L196 432 L222 484 C250 420 268 350 272 290 Z"
    tails, loops = Art(), Art()
    with tails.part(12):
        tails.sil(tail, RED_D)
    with loops.part(12):
        loops.sil(loop, RED)
        loops.blob("M246 256 C206 214 150 196 110 206 C100 230 100 282 110 306 C150 316 206 298 246 256 Z", RED_D)
    a.els += tails.els + tails.flipped().els + loops.els + loops.flipped().els
    with a.part(12):
        a.sil(e2_rr(206, 200, 100, 112, 40), "#f0685f")
    a.shine("M92 196 C104 180 122 172 142 172", sw=9)
    a.shine("M226 232 C230 222 238 216 248 214", sw=8)
    return a


@sticker
def oukan():
    a = Art()
    body = c_rpoly([(92, 400), (64, 180), (168, 268), (256, 120), (344, 268), (448, 180), (420, 400)], [18, 16, 0, 18, 0, 16, 18])
    with a.part(12):
        a.sil(body, YEL)
        a.blob(c_rpoly([(96, 400), (88, 340), (424, 340), (416, 400)], [16, 0, 0, 16]), YEL_D)
        a.sil(c_circ(64, 172, 28), YEL)
        a.sil(c_circ(256, 110, 30), YEL)
        a.sil(c_circ(448, 172, 28), YEL)
    with a.part(7):
        a.sil(c_circ(256, 370, 24), RED)
    with a.part(7):
        a.sil(c_circ(166, 370, 18), BLUE)
    with a.part(7):
        a.sil(c_circ(346, 370, 18), GREEN)
    e1_face(a, 256, 274, 40, 14, cheek_dx=78)
    a.shine("M110 300 C106 268 104 244 104 226", sw=9)
    return a


@sticker
def cake():
    a = Art()
    # a cupcake: striped cup, swirl of cream, a cherry on top
    cup = c_rpoly([(124, 300), (388, 300), (352, 462), (160, 462)], [10, 10, 26, 26])
    with a.part(12):
        a.sil(cup, "#7fc8f0")
        for x0, x1 in ((166, 184), (232, 240), (296, 290), (352, 334)):
            a.blob(poly([(x0 - 12, 304), (x0 + 12, 304), (x1 + 10, 458), (x1 - 10, 458)]), "#5aaede")
    cream = ("M96 300 C76 262 104 226 148 226 C140 180 184 150 226 166 C240 128 300 128 316 170 "
             "C360 152 398 186 384 228 C426 232 440 272 416 300 Z")
    with a.part(12):
        a.sil(cream, CREAM)
        a.blob("M96 300 C92 290 90 280 92 270 C180 290 330 290 420 270 C422 280 420 290 416 300 Z", "#f3dcc0")
        a.ink([(148, 226, 160, 226, 172, 232, 180, 242)], 8, a=1, b=0)
        a.ink([(384, 228, 370, 228, 358, 234, 350, 244)], 8, a=1, b=0)
    with a.part(10):
        a.sil(c_circ(262, 122, 44), RED)
    a.path("M266 84 C270 60 286 44 306 38", sw=9)
    a.shine("M238 112 C242 100 250 94 260 92", sw=7)
    for x, y, col in ((176, 262, PINK), (250, 216, BLUE), (322, 262, GREEN), (222, 276, YEL), (300, 214, PINK)):
        a.dot(x, y, 9, col)
    e1_face(a, 256, 366, 40, 14, cheek_dx=74)
    return a


@sticker
def ice():
    a = Art()
    cone = c_rpoly([(160, 268), (352, 268), (256, 492)], [8, 8, 22])
    with a.part(12):
        a.sil(cone, WOOD)
        for (x0, y0, x1, y1) in ((196, 276, 300, 400), (252, 276, 328, 344), (316, 276, 212, 400), (260, 276, 184, 344)):
            a.ink([(x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)],
                  7, a=1, b=1, col=WOOD_D)
    with a.part(12):
        a.sil(c_circ(256, 126, 96), "#ffe9a8")
        a.blob(d_rim(c_circ(256, 126, 96), 20, 60, 24), "#f5d27c")
    scoop = ("M132 286 C108 286 100 258 118 242 C108 168 170 116 256 116 C342 116 404 168 394 242 "
             "C412 258 404 286 380 286 C356 300 334 276 312 288 C292 300 270 276 250 288 C228 300 204 276 184 288 C166 298 148 296 132 286 Z")
    with a.part(12):
        a.sil(scoop, PINK_L)
        a.blob(d_rim(scoop, 30, 56, 26), "#f59ab2")
    e1_face(a, 256, 216, 44, 15)
    a.shine("M150 204 C158 172 180 150 208 142", sw=9)
    a.shine("M200 84 C210 66 226 56 244 54", sw=8)
    return a


@sticker
def ame():
    a = Art()
    for s in (-1, 1):
        w = c_rpoly([(256 + s * 110, 256), (256 + s * 236, 160), (256 + s * 220, 256), (256 + s * 236, 352)], [0, 20, 0, 20])
        with a.part(12):
            a.sil(w, "#bfe6fa")
        a.ink([(256 + s * 130, 256, 256 + s * 160, 248, 256 + s * 190, 232, 256 + s * 214, 208)], 7, a=1, b=0, col=BLUE)
        a.ink([(256 + s * 130, 256, 256 + s * 160, 264, 256 + s * 190, 280, 256 + s * 214, 304)], 7, a=1, b=0, col=BLUE)
    with a.part(12):
        a.sil(c_circ(256, 256, 132), WHITE)
        a.ink(b_spiral(256, 256, 8, 124, 2.2, start=-90), 30, a=0.5, b=0.2, col=PINK)
    a.shine("M170 214 C180 178 204 156 236 148", sw=9)
    return a


@sticker
def donut():
    a = Art()
    ring = c_circ(256, 256, 204) + " " + c_circ(256, 256, 62, ccw=True)
    with a.part(12):
        a.sil(ring, WOOD)
    icing_pts = []
    for i in range(48):
        t = 2 * math.pi * i / 48
        r = 176 + 14 * math.sin(8 * t)
        icing_pts.append((256 + r * math.cos(t), 256 + r * math.sin(t)))
    from lib import smooth
    a.blob(smooth(icing_pts) + " " + c_circ(256, 256, 84, ccw=True), PINK_L)
    for i, col in enumerate([RED, YEL, BLUE, GREEN, WHITE, PURPLE, YEL, BLUE, RED, GREEN, WHITE, PURPLE]):
        t = 2 * math.pi * i / 12 + 0.2
        r = 128 + (10 if i % 2 else -8)
        x, y = 256 + r * math.cos(t), 256 + r * math.sin(t)
        a.path(c_bar(x - 9 * math.cos(t * 3), y - 9 * math.sin(t * 3), x + 9 * math.cos(t * 3), y + 9 * math.sin(t * 3), 12),
               fill=col, sw=0, stroke="none")
    a.shine("M104 216 C116 160 152 118 204 100", sw=9)
    return a


@sticker
def ringo():
    a = Art()
    a.sil(taper([(258, 158, 258, 122, 266, 96, 282, 68)], 15, 20), BROWN)
    with a.part(12):
        a.sil(d_leaf(288, 104, 408, 52, 76, 0.2), GREEN)
        d_vein(a, 288, 104, 408, 52, GREEN_D, t0=0.15, t1=0.78)
    body = ("M256 142 C296 98 404 104 412 224 C418 342 344 436 292 436 C272 436 264 428 256 428 "
            "C248 428 240 436 220 436 C168 436 94 342 100 224 C108 104 216 98 256 142 Z")
    with a.part(12):
        a.sil(body, "#a6d95a")
        a.blob(d_rim(body, 40, 62, 30), "#86c240")
        a.ink([(222, 138, 238, 158, 274, 158, 290, 138)], 9, a=0, b=0)
    e1_face(a, 256, 274, 54, 17)
    a.shine("M152 220 C148 184 164 154 192 142", sw=9)
    return a


@sticker
def ichigo():
    a = Art()
    body = "M256 456 C232 456 98 356 98 250 C98 186 156 156 256 164 C356 156 414 186 414 250 C414 356 280 456 256 456 Z"
    with a.part(12):
        a.sil(body, RED)
        a.blob(d_rim(body, 42, 58, 30), RED_D)
        for x, y in ((150, 248), (362, 248), (176, 356), (336, 356), (256, 420), (216, 396), (296, 396), (132, 300), (380, 300)):
            a.ellipse(x, y, 7, 11, "#ffe18a", sw=0, stroke="none")
    top = ("M256 196 C230 202 196 190 148 162 C176 152 206 156 232 170 C214 150 204 130 200 104 "
           "C228 118 244 142 256 164 C268 142 284 118 312 104 C308 130 298 150 280 170 "
           "C306 156 336 152 364 162 C316 190 282 202 256 196 Z")
    with a.part(12):
        a.sil(taper([(256, 170, 256, 150, 258, 132, 262, 112)], 14, 16), GREEN_D)
        a.sil(top, GREEN)
    e1_face(a, 256, 286, 50, 17, cheek_dx=92)
    a.shine("M134 262 C132 228 152 200 182 190", sw=9)
    return a


@sticker
def sakuranbo():
    a = Art()
    a.path("M176 300 C190 200 240 120 322 76", sw=12)
    a.path("M352 330 C356 230 346 140 322 76", sw=12)
    with a.part(12):
        a.sil(d_leaf(322, 78, 452, 96, 78, -0.1), GREEN)
        d_vein(a, 322, 78, 452, 96, GREEN_D, t0=0.12, t1=0.8)
    for cx, cy in ((168, 366), (354, 388)):
        with a.part(12):
            a.sil(c_circ(cx, cy, 96), RED)
            a.blob(d_rim(c_circ(cx, cy, 96), 40, 64, 24), RED_D)
        e1_face(a, cx, cy + 2, 30, 12, cheek_dx=58, cheek_dy=22)
        a.shine(f"M{cx - 62} {cy - 22} C{cx - 58} {cy - 46} {cx - 44} {cy - 62} {cx - 24} {cy - 70}", sw=8)
    return a


@sticker
def kinoko():
    a = Art()
    stem = "M180 292 C176 360 160 420 176 446 C196 474 316 474 336 446 C352 420 336 360 332 292 Z"
    with a.part(12):
        a.sil(stem, CREAM)
        a.blob(d_rim(stem, 30, 60, 22), "#f1dcbc")
    cap = "M56 286 C56 150 150 62 256 62 C362 62 456 150 456 286 C456 320 420 328 256 328 C92 328 56 320 56 286 Z"
    with a.part(12):
        a.sil(cap, RED)
        a.blob(d_rim(cap, 50, 60, 30), RED_D)
        for x, y, r in ((160, 190, 34), (290, 132, 30), (372, 234, 28), (232, 256, 22), (110, 276, 18)):
            a.blob(c_circ(x, y, r, r * 0.9), WHITE)
    e1_face(a, 256, 384, 38, 14, cheek_dx=70)
    a.shine("M98 240 C104 190 132 146 172 120", sw=9)
    return a


@sticker
def clover():
    a = Art()
    a.sil(taper([(262, 290, 268, 360, 296, 428, 348, 480)], 24, 20), GREEN_D)
    with a.part(12):
        for ang in (0, 90, 180, 270):
            a.sil(d_tf(heart_d(0, -102, 88), 1, 256, 262, ang + 180), GREEN)
    for ang in (0, 90, 180, 270):
        t = math.radians(ang - 90)
        x1, y1 = 256 + 132 * math.cos(t), 262 + 132 * math.sin(t)
        a.ink([(256, 262, 256 + 50 * math.cos(t), 262 + 50 * math.sin(t), 256 + 100 * math.cos(t), 262 + 100 * math.sin(t), x1, y1)],
              9, a=1, b=0, col=GREEN_D)
    a.shine("M196 122 C204 108 216 100 230 98", sw=8)
    return a


@sticker
def rocket():
    a = Art()
    flame = "M210 404 C196 444 226 470 256 500 C286 470 316 444 302 404 Z"
    with a.part(10):
        a.sil(flame, ORANGE)
        a.blob("M232 410 C226 436 242 452 256 468 C270 452 286 436 280 410 Z", YEL)
    for s in (-1, 1):
        with a.part(12):
            a.sil(c_rpoly([(256 + s * 96, 300), (256 + s * 190, 420), (256 + s * 96, 404)], [0, 24, 0]), RED)
    body = "M256 36 C340 100 368 210 352 400 C352 410 344 416 334 416 L178 416 C168 416 160 410 160 400 C144 210 172 100 256 36 Z"
    with a.part(12):
        a.sil(body, WHITE)
        a.blob("M256 36 C296 66 322 106 338 156 L174 156 C190 106 216 66 256 36 Z", RED)
        a.blob(d_rim(body, 10, 50, 26), "#dfe6ec")
        a.blob(e2_rr(160, 372, 192, 44, 8), BLUE)
    with a.part(9):
        a.sil(c_circ(256, 246, 58), BLUE_D)
        a.blob(c_circ(256, 246, 44), SKY)
    e1_face(a, 256, 240, 20, 9, cheek_dx=34, cheek_dy=14, mouth=True)
    a.shine("M196 300 C190 250 192 210 204 172", sw=9)
    return a


@sticker
def fuusen():
    a = Art()
    a.path("M256 372 C236 410 280 436 256 492", sw=9)
    body = "M256 36 C356 36 420 110 420 200 C420 290 340 356 256 356 C172 356 92 290 92 200 C92 110 156 36 256 36 Z"
    with a.part(12):
        a.sil(c_rpoly([(236, 350), (276, 350), (290, 390), (222, 390)], [0, 0, 12, 12]), BLUE_D)
        a.sil(body, BLUE)
        a.blob(d_rim(body, 40, 62, 32), BLUE_D)
    e1_face(a, 256, 206, 54, 17)
    a.shine("M146 176 C150 124 180 86 222 72", sw=10)
    return a


@sticker
def present():
    a = Art()
    with a.part(12):
        a.sil(e2_rr(96, 244, 320, 220, 20), GREEN)
        a.blob(e2_rr(96, 244, 320, 30, 0), GREEN_D)
        a.blob(e2_rr(226, 244, 60, 220, 0), YEL)
    with a.part(12):
        a.sil(e2_rr(72, 170, 368, 84, 22), "#8fd47c")
        a.blob(e2_rr(222, 170, 68, 84, 0), YEL)
    for s in (-1, 1):
        loop = c_rpoly([(256, 168), (256 + s * 130, 60), (256 + s * 150, 150)], [0, 40, 36])
        with a.part(12):
            a.sil(loop, YEL)
            a.blob(c_rpoly([(256 + s * 20, 160), (256 + s * 112, 92), (256 + s * 124, 142)], [0, 20, 18]), YEL_D)
    with a.part(10):
        a.sil(c_circ(256, 160, 34, 30), YEL)
    a.eye(176, 350, 14)
    a.eye(336, 350, 14)
    a.cheek(138, 384, 14, 9)
    a.cheek(374, 384, 14, 9)
    a.path("M244 372 C250 382 262 382 268 372", sw=7)
    a.shine("M112 196 C120 186 132 182 146 182", sw=8)
    return a


@sticker
def enpitsu():
    a = Art()
    # drawn upright, then turned
    b = Art()
    with b.part(12):
        b.sil(c_rpoly([(196, 92), (316, 92), (316, 150), (196, 150)], [26, 26, 0, 0]), PINK_L)
        b.sil(e2_rr(196, 140, 120, 34, 0), "#cfd6dc")
        b.sil(e2_rr(196, 170, 120, 220, 0), YEL)
        b.blob(e2_rr(276, 170, 40, 220, 0), YEL_D)
        b.sil(poly([(196, 388), (316, 388), (256, 492)]), "#f6d9b0")
        b.blob(poly([(236, 458), (276, 458), (256, 492)]), "#4a3428")
    for tag, g, attrs in b.els:
        if tag == "path":
            g = {"d": d_tf(g["d"], 1, 256 - (256 * math.cos(math.radians(35)) - 292 * math.sin(math.radians(35))),
                           292 - (256 * math.sin(math.radians(35)) + 292 * math.cos(math.radians(35))), 35)}
        a.els.append((tag, g, attrs))
    e1_face(a, 262, 284, 26, 12, cheek_dx=50, cheek_dy=20)
    a.shine("M300 150 C296 172 284 196 268 216", sw=8)
    with a.part(7):
        sparkle(a, 120, 150, 30)
    with a.part(7):
        sparkle(a, 400, 380, 24, "#ffe27a")
    return a


@sticker
def hanamaru():
    a = Art()
    with a.part(10):
        a.sil(c_circ(256, 256, 226), WHITE)
    R = "#ee5b52"
    spiral = b_spiral(256, 262, 6, 122, 2.6, start=200)
    a.path(e1_d(spiral, close=False), stroke=R, sw=22)
    n = 8
    x0, y0 = spiral[-1][6], spiral[-1][7]
    a0 = math.degrees(math.atan2(y0 - 262, x0 - 256))
    d = f"M{x0:.1f} {y0:.1f}"
    for i in range(n):
        t0 = math.radians(a0 + i * 360 / n)
        t1 = math.radians(a0 + (i + 1) * 360 / n)
        tm = (t0 + t1) / 2
        r = 122
        ex, ey = 256 + r * math.cos(t1), 262 + r * math.sin(t1)
        c1 = (256 + 218 * math.cos(tm - 0.3), 262 + 218 * math.sin(tm - 0.3))
        c2 = (256 + 218 * math.cos(tm + 0.3), 262 + 218 * math.sin(tm + 0.3))
        d += f" C{c1[0]:.1f} {c1[1]:.1f} {c2[0]:.1f} {c2[1]:.1f} {ex:.1f} {ey:.1f}"
    a.path(d, stroke=R, sw=22)
    return a


# ------------------------------------------------------ おたのしみ ボックス --
def treat_box():
    """The surprise box: (whole, body, lid). The lid is its own picture so the app can pop it off."""
    def body(a):
        with a.part(12):
            a.sil(e2_rr(84, 236, 344, 236, 26), ORANGE)
            a.blob(e2_rr(84, 236, 344, 36, 0), ORANGE_D)
            a.blob(e2_rr(84, 430, 344, 42, 22), ORANGE_D)
            a.blob(e2_rr(222, 236, 68, 236, 0), "#fff3b0")
        with a.part(9):
            a.sil(e1_star(256, 352, 74, 38), YEL)
            a.blob(e1_star(256, 350, 46, 24), YEL_L)
        e1_face(a, 256, 350, 16, 7, cheek_dx=28, cheek_dy=12)
        a.shine("M110 300 C108 286 108 276 110 266", sw=8)

    def lid(a):
        with a.part(12):
            a.sil(e2_rr(60, 168, 392, 92, 26), "#ffbe63")
            a.blob(e2_rr(60, 228, 392, 32, 20), ORANGE_D)
            a.blob(e2_rr(220, 168, 72, 92, 0), "#fff3b0")
        for s in (-1, 1):
            loop = c_rpoly([(256, 166), (256 + s * 124, 64), (256 + s * 146, 150)], [0, 40, 36])
            with a.part(12):
                a.sil(loop, RED)
                a.blob(c_rpoly([(256 + s * 22, 158), (256 + s * 108, 96), (256 + s * 120, 142)], [0, 20, 18]), RED_D)
        with a.part(10):
            a.sil(c_circ(256, 158, 34, 30), "#f0685f")
        a.shine("M84 200 C88 190 96 184 108 184", sw=8)

    whole, b, l = Art(), Art(), Art()
    body(whole); lid(whole); body(b); lid(l)
    return whole, b, l


def write_treat_box():
    os.makedirs(PARTS, exist_ok=True)
    whole, b, l = treat_box()
    params = fit_params([whole])
    open(os.path.join(PARTS, "otanoshimi-box.svg"), "w").write(b.svg(params=params))
    open(os.path.join(PARTS, "otanoshimi-lid.svg"), "w").write(l.svg(params=params))


if __name__ == "__main__":
    names = sys.argv[1:] or ORDER
    os.makedirs(OUT, exist_ok=True)
    for n in names:
        if n == "otanoshimi":
            continue
        open(os.path.join(OUT, f"{n}.svg"), "w").write(stickerize(S[n]()).svg())
    if not sys.argv[1:] or "otanoshimi" in names:
        write_treat_box()
