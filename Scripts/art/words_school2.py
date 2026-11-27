"""めぐり School2 の絵（ぶんぼうぐ・あそぶ物・のりもの・たてもの・まちの もの・季節の ぎょうじ）。
描き方は Content/Art/style-guide.md（part()/sil()/ink()。顔はつけない。本体は1つの部品）。"""
import math
from lib import Art, mirror, taper, smooth, O, EYE, SW
from words import (word, RED, RED_D, YEL, YEL2, BLUE, BLUE_D, SKY, WOOD, WOOD_D, PINK, GREEN, CREAM, WHITE, GREY, HUB, NAVY,
                   c_rpoly, c_rect, c_circ, c_bar, c_line, c_glass, c_wheel, c_lamp,
                   e2_rr, e2_poly, e2_seg, e2_cap, e2_line, e2_star, e2_blossom, e2_note,
                   d_circ, d_tf, d_rim, d_leaf, d_blade)

S2_STEEL, S2_STEEL_D = "#dfe6ec", "#b9c4cf"
S2_ORANGE, S2_PURPLE = "#f7a94b", "#9b7fd1"
S2_LEAF, S2_LEAF_D = "#7cc36a", "#5fa64f"
S2_WALL, S2_WALL_D = "#fff0d4", "#ecd8b2"
S2_SNOW, S2_SNOW_D = "#ffffff", "#d7ecf8"


class S2T:
    """Turn shapes around a point (degrees, clockwise on screen): paths with d(), points with p(), lines with seg()."""

    def __init__(self, deg, cx=256, cy=256):
        self.deg, self.cx, self.cy = deg, cx, cy
        self.c, self.s = math.cos(math.radians(deg)), math.sin(math.radians(deg))

    def d(self, path):
        return d_tf(d_tf(path, dx=-self.cx, dy=-self.cy), deg=self.deg, dx=self.cx, dy=self.cy)

    def p(self, x, y):
        x, y = x - self.cx, y - self.cy
        return x * self.c - y * self.s + self.cx, x * self.s + y * self.c + self.cy

    def seg(self, x0, y0, x1, y1):
        return e2_seg(*self.p(x0, y0), *self.p(x1, y1))

    def line(self, a, x0, y0, x1, y1, w=7, s=1, e=1, col=O):
        a.ink([self.seg(x0, y0, x1, y1)], w, a=s, b=e, col=col)

    def shine(self, a, x0, y0, x1, y1, sw=7):
        (u, v), (m, n) = self.p(x0, y0), self.p(x1, y1)
        a.shine(f"M{u:.1f} {v:.1f} L{m:.1f} {n:.1f}", sw=sw)


def s2_pencil(a, t, x0, x1, y, w, col, col_d, eraser=True):
    """A pencil lying along y from its tip x0 to its end x1 (w wide), turned by t."""
    h = w / 2
    cone = w * 1.05
    with a.part():
        a.sil(t.d(f"M{x0 + cone} {y - h} L{x0 + 10} {y - 5} Q{x0} {y} {x0 + 10} {y + 5} L{x0 + cone} {y + h} Z"), "#f6d7a8")
        end = x1 - (w * 0.95 if eraser else 0)
        a.sil(t.d(e2_poly([(x0 + cone, y - h), (end, y - h), (end, y + h), (x0 + cone, y + h)])), col)
        a.blob(t.d(e2_poly([(x0 + cone, y + h * 0.3), (end, y + h * 0.3), (end, y + h), (x0 + cone, y + h)])), col_d)
        a.blob(t.d(f"M{x0 + cone * 0.36} {y - h * 0.3} L{x0 + 10} {y - 5} Q{x0} {y} {x0 + 10} {y + 5} L{x0 + cone * 0.36} {y + h * 0.3} "
                   f"C{x0 + cone * 0.3} {y + 3} {x0 + cone * 0.3} {y - 3} {x0 + cone * 0.36} {y - h * 0.3} Z"), GREY)
        if eraser:
            a.sil(t.d(e2_poly([(end, y - h), (end + w * 0.4, y - h), (end + w * 0.4, y + h), (end, y + h)])), S2_STEEL)
            a.sil(t.d(c_rpoly([(end + w * 0.4, y - h), (x1, y - h), (x1, y + h), (end + w * 0.4, y + h)], [0, h * 0.6, h * 0.6, 0])), "#f7a8b3")
            t.line(a, end, y - h, end, y + h, 6)
            t.line(a, end + w * 0.4, y - h, end + w * 0.4, y + h, 6)
    t.shine(a, x0 + cone + 14, y - h * 0.5, end - 20, y - h * 0.5, sw=max(5, w * 0.1))


# ------------------------------------------------------------ ぶんぼうぐ --
@word
def enpitsu():
    a = Art()
    s2_pencil(a, S2T(-42), 30, 482, 256, 84, YEL2, "#e9a93a")
    return a


@word
def hasami():
    a = Art()
    piv = (256, 250)

    def piece(deg, col, col_d):
        t = S2T(deg, *piv)
        with a.part():
            a.sil(t.d("M226 272 L236 48 Q256 6 276 48 L286 272 Z"), S2_STEEL)
            a.blob(t.d("M258 34 Q268 36 276 50 L286 272 L258 272 Z"), S2_STEEL_D)
            a.sil(t.d(c_circ(256, 392, 70, 84) + " " + c_circ(256, 398, 36, 48, ccw=True)), col)
            a.sil(t.d(e2_poly([(228, 264), (284, 264), (292, 330), (220, 330)])), col)
            a.blob(t.d(d_rim(c_circ(256, 392, 70, 84), 60, 60, 16)), col_d)

    piece(-24, BLUE, BLUE_D)
    piece(24, RED, RED_D)
    with a.part(7):
        a.sil(c_circ(piv[0], piv[1], 15), "#8a949a")
    a.dot(piv[0] - 4, piv[1] - 4, 5, WHITE)
    t = S2T(24, *piv)
    t.shine(a, 244, 80, 240, 210, sw=7)
    return a


@word
def nori():
    a = Art()
    G1, G2 = "#63b86a", "#4a9f55"
    with a.part():                                      # the cap, lying beside the stick
        a.sil(c_rpoly([(330, 372), (452, 372), (446, 458), (336, 458)], [14, 14, 18, 18]), S2_ORANGE)
        a.blob(c_rpoly([(410, 373), (451, 373), (445, 457), (404, 457)], [0, 14, 18, 0]), "#e58d32")
    c_line(a, 356, 388, 356, 444, 6, s=0.4, e=0.4, col="#c9741f")
    c_line(a, 378, 388, 378, 444, 6, s=0.4, e=0.4, col="#c9741f")
    with a.part():                                      # glue coming out of the tube
        a.sil("M150 150 C150 84 290 84 290 150 L290 200 L150 200 Z", "#fdfdf6")
        a.blob("M252 104 C276 114 290 130 290 150 L290 200 L262 200 C266 166 264 130 252 104 Z", "#dfe9ee")
    with a.part():                                      # the collar
        a.sil(e2_rr(128, 176, 184, 52, 14), "#e9eef2")
        a.blob(e2_rr(262, 180, 46, 44, 10), "#cfd8de")
    with a.part():                                      # the tube
        a.sil(c_rpoly([(110, 216), (330, 216), (330, 458), (110, 458)], [14, 14, 30, 30]), G1)
        a.blob(c_rpoly([(276, 217), (329, 217), (329, 457), (276, 457)], [0, 13, 29, 0]), G2)
        a.blob(e2_rr(111, 286, 218, 96, 0), WHITE)
        a.blob(e2_rr(276, 286, 53, 96, 0), "#e3ebe6")
        a.blob(e2_star(196, 334, 34, 15), YEL2)
    a.shine("M134 240 L134 440", sw=8)
    a.shine("M176 128 C182 114 196 106 212 104", sw=7)
    return a


@word
def fudebako():
    a = Art()
    C, C_D, C_L, IN = BLUE, BLUE_D, "#7fc0ea", "#2f4a73"
    with a.part():                                      # lid (open, behind)
        a.sil(c_rpoly([(92, 92), (420, 92), (456, 250), (56, 250)], [22, 22, 6, 6]), C_L)
        a.blob(c_rpoly([(112, 110), (400, 110), (426, 232), (86, 232)], [14, 14, 6, 6]), "#a9d6f2")
        a.blob(e2_star(256, 168, 40, 18), YEL2)
    with a.part():                                      # inside of the tray
        a.sil(e2_poly([(56, 246), (456, 246), (456, 318), (56, 318)]), IN)
    t = S2T(0)
    s2_pencil(a, S2T(-3, 256, 270), 84, 420, 270, 30, RED, RED_D)
    s2_pencil(a, t, 96, 380, 300, 30, YEL2, "#e9a93a")
    with a.part():                                      # eraser
        a.sil(e2_rr(392, 280, 50, 34, 8), WHITE)
        a.blob(e2_rr(392, 280, 26, 34, 6), "#7fc0ea")
    with a.part():                                      # tray front
        a.sil(c_rpoly([(46, 306), (466, 306), (466, 430), (46, 430)], [10, 10, 30, 30]), C)
        a.blob(c_rpoly([(47, 392), (465, 392), (465, 429), (47, 429)], [0, 0, 29, 29]), C_D)
    with a.part(8):                                     # clasp
        a.sil(e2_rr(226, 292, 60, 44, 12), YEL2)
    a.shine("M74 330 L74 384", sw=8)
    return a


@word
def jougi():
    a = Art()
    t = S2T(-24)
    with a.part():                                      # triangle behind
        a.sil(c_rpoly([(120, 120), (120, 400), (400, 400)], [14, 14, 14]) + " " +
              c_rpoly([(176, 250), (260, 344), (176, 344)], [8, 8, 8]), "#8fd0ee")
        a.blob("M124 386 L386 386 L398 398 L124 398 Z", "#6db8dc")
    with a.part():                                      # ruler
        a.sil(t.d(e2_rr(34, 214, 444, 104, 14)), YEL)
        a.blob(t.d(e2_rr(34, 290, 444, 28, 10)), "#e9bd3c")
        for i in range(12):
            x = 64 + i * 32
            L = 34 if i % 2 == 0 else 20
            t.line(a, x, 216, x, 216 + L, 6, 1, 1)
    x, y = t.p(440, 276)
    with a.part(6):
        a.sil(c_circ(x, y, 12), CREAM)
    t.shine(a, 60, 268, 300, 268, sw=7)
    return a


@word
def enogu():
    a = Art()
    with a.part():                                      # palette
        a.sil("M250 196 C376 190 478 250 474 338 C470 420 372 462 250 462 C128 462 34 416 38 330 "
              "C42 250 130 202 250 196 Z " + c_circ(130, 372, 30, 24, ccw=True), "#fbf6ea")
        a.blob("M250 462 C372 462 470 420 474 338 C456 400 364 436 250 438 C150 438 70 410 44 360 "
               "C60 424 140 462 250 462 Z", "#e6dccb")
    for x, y, c, cd in ((150, 286, RED, RED_D), (236, 262, YEL2, "#e5a92d"), (326, 276, "#63b86a", "#4a9f55"),
                        (396, 324, BLUE, BLUE_D)):
        with a.part(8):
            a.sil(smooth([(x - 34, y), (x - 18, y - 24), (x + 16, y - 26), (x + 36, y - 4), (x + 22, y + 24), (x - 14, y + 24)]), c)
            a.blob(d_rim(c_circ(x, y, 34, 25), 50, 60, 9), cd)
        a.dot(x - 12, y - 10, 6, WHITE)
    t = S2T(-38, 300, 150)                              # a tube lying across the top
    with a.part():
        a.sil(t.d(e2_rr(96, 132, 34, 36, 8)), WHITE)                                     # cap
        a.sil(t.d(c_rpoly([(126, 126), (176, 104), (430, 96), (430, 204), (176, 196), (126, 174)], [6, 16, 4, 4, 16, 6])), "#f48a9a")
        a.blob(t.d(c_rpoly([(176, 168), (430, 176), (430, 203), (176, 195)], [0, 0, 4, 12])), "#e0707f")
        a.blob(t.d(e2_poly([(216, 104), (330, 100), (330, 200), (216, 196)])), WHITE)
        a.sil(t.d(e2_rr(424, 86, 26, 128, 8)), S2_STEEL)                                # crimped end
    t.line(a, 126, 128, 126, 172, 6)
    x, y = t.p(272, 150)
    a.blob(e2_blossom_path(x, y, 24), "#f48a9a")
    t.shine(a, 190, 116, 400, 110, sw=6)
    return a


def e2_blossom_path(cx, cy, R):
    """A round paint splash (five lobes), one path."""
    pts = []
    for i in range(10):
        r = R if i % 2 == 0 else R * 0.62
        an = -math.pi / 2 + i * math.pi / 5
        pts.append((cx + r * math.cos(an), cy + r * math.sin(an)))
    return smooth(pts)


@word
def fude():
    a = Art()
    t = S2T(-45)
    BAM, BAM_D = "#e9c98a", "#cfa962"
    with a.part():                                      # an ink stroke on the paper
        a.sil(taper([(70, 420, 130, 470, 230, 474, 300, 440)], 30, 8), "#4a4038")
    with a.part():                                      # loop at the end
        a.sil(t.d(c_circ(468, 256, 22, 16) + " " + c_circ(470, 256, 9, 6, ccw=True)), RED)
    with a.part():
        a.sil(t.d(e2_rr(186, 226, 266, 60, 12)), BAM)                                    # bamboo handle
        a.blob(t.d(e2_rr(186, 264, 266, 22, 10)), BAM_D)
        a.sil(t.d(e2_rr(150, 220, 48, 72, 10)), "#6f5a4c")                               # ferrule
        a.sil(t.d("M154 222 C110 218 60 236 22 262 Q14 268 26 270 C70 280 116 290 154 290 Z"), "#fbf3df")   # hair
        a.blob(t.d("M96 230 C66 238 42 250 22 262 Q14 268 26 270 C52 276 78 282 104 286 C92 268 90 248 96 230 Z"), "#4a4038")
    for x in (270, 356):
        t.line(a, x, 228, x, 284, 6, 1, 1, col="#b08a4a")
    t.line(a, 150, 224, 150, 288, 6)
    t.shine(a, 214, 240, 430, 240, sw=6)
    return a


@word
def hon():
    a = Art()
    COVER, COVER_D, PAGE, PAGE_D = RED, RED_D, "#fffaf0", "#eadfca"
    with a.part():                                      # cover
        a.sil(c_rpoly([(40, 150), (472, 150), (472, 416), (40, 416)], [16, 16, 16, 16]), COVER)
        a.blob(c_rpoly([(41, 392), (471, 392), (471, 415), (41, 415)], [0, 0, 15, 15]), COVER_D)
    left = "M256 150 C214 116 126 112 62 132 L62 380 C126 360 214 364 256 398 Z"
    with a.part():                                      # pages
        a.sil(left, PAGE)
        a.sil(mirror(left), PAGE)
        a.blob("M256 150 C240 136 222 128 204 124 C226 150 232 300 236 384 C244 388 250 392 256 398 Z", PAGE_D)
        a.blob(mirror("M256 150 C240 136 222 128 204 124 C226 150 232 300 236 384 C244 388 250 392 256 398 Z"), PAGE_D)
        c_line(a, 256, 152, 256, 396, 7, s=1, e=1)
    for i, y in enumerate((184, 224, 264, 304)):
        a.ink([(92, y, 120, y - 10, 160, y - 12, 196 - (40 if i == 3 else 0), y - 4)], 9, a=0.6, b=0.6, col="#c9b79a")
    a.blob(e2_star(360, 216, 44, 20), YEL2)             # a picture on the right page
    for i, y in enumerate((300, 338)):
        a.ink([(420, y, 392, y - 10, 352, y - 12, 316 + (36 if i == 1 else 0), y - 4)], 9, a=0.6, b=0.6, col="#c9b79a")
    with a.part(7):                                     # ribbon
        a.sil("M236 386 L236 462 L256 444 L276 462 L276 386 Z", BLUE)
    return a


@word
def nendo():
    a = Art()
    with a.part():                                      # board
        a.sil(c_rpoly([(60, 356), (452, 356), (486, 452), (26, 452)], [12, 12, 16, 16]), "#f7c98d")
        a.blob(c_rpoly([(34, 430), (478, 430), (485, 451), (27, 451)], [0, 0, 15, 15]), WOOD_D)
    with a.part():                                      # a blue block
        a.sil(e2_rr(274, 268, 170, 124, 30), BLUE)
        a.blob(d_rim(e2_rr(274, 268, 170, 124, 30), 50, 70, 20), BLUE_D)
    with a.part():                                      # a rolled log of clay
        a.sil(e2_rr(60, 286, 230, 100, 50), "#63b86a")
        a.blob(d_rim(e2_rr(60, 286, 230, 100, 50), 70, 60, 18), "#4a9f55")
        a.blob(c_circ(110, 336, 30, 36), "#8ad08f")
    with a.part():                                      # a ball on the block
        a.sil(c_circ(350, 220, 62), RED)
        a.blob(d_rim(c_circ(350, 220, 62), 50, 70, 16), RED_D)
    with a.part():                                      # a yellow star cut from clay
        a.sil(c_rpoly([(round(300 + r * math.cos(math.radians(-90 + i * 36)), 1), round(398 + r * math.sin(math.radians(-90 + i * 36)), 1))
                       for i, r in ((i, 48 if i % 2 == 0 else 26) for i in range(10))], 7), YEL2)
    a.shine("M318 196 C324 182 336 174 350 172", sw=7)
    a.shine("M150 304 L240 304", sw=7)
    return a


# ------------------------------------------- おもちゃ・がっき・スポーツ・こうえん --
@word
def origami():
    """An origami crane on two sheets of coloured paper."""
    a = Art()
    with a.part():
        a.sil(S2T(-12, 190, 380).d(e2_rr(70, 290, 200, 180, 10)), "#f7a8b3")
    with a.part():
        a.sil(S2T(10, 330, 380).d(e2_rr(230, 296, 200, 176, 10)), "#8fd0ee")
    C, C_D, C_DD = "#f7c948", "#e9a93a", "#d98f28"
    with a.part():                                      # far wing
        a.sil("M250 300 L330 96 L352 300 Z", C_D)
    with a.part():                                      # tail, body, neck and head: one folded shape
        a.sil("M250 350 L74 168 L182 300 Z", C_D)                                        # tail
        a.sil("M262 350 L424 136 L470 190 L430 174 L330 300 Z", C)                       # neck and beak
        a.sil("M176 300 L336 300 L256 396 Z", C)                                         # body
        a.blob("M256 396 L336 300 L256 300 Z", C_D)
        c_line(a, 256, 302, 256, 392, 6, s=1, e=0.3, col=C_DD)
        c_line(a, 424, 140, 430, 174, 5, s=1, e=1, col=C_DD)
    with a.part():                                      # near wing
        a.sil("M176 300 L196 70 L310 300 Z", C)
        a.blob("M196 70 L310 300 L246 300 Z", C_D)
        c_line(a, 196, 74, 246, 298, 5, s=1, e=0.4, col=C_DD)
    a.shine("M190 130 L186 250", sw=7)
    return a


@word
def takeuma():
    a = Art()
    BAM, BAM_D, NODE = "#8fca6a", "#6fae4f", "#4f8f3a"

    def pole(x, lean):
        t = S2T(lean, x, 470)
        with a.part():
            a.sil(t.d(e2_rr(x - 17, 40, 34, 432, 14)), BAM)
            a.blob(t.d(e2_rr(x + 3, 44, 13, 424, 6)), BAM_D)
            for y in (150, 260, 372):
                t.line(a, x - 17, y, x + 17, y, 6, 1, 1, col=NODE)
        d = -1
        with a.part():                                  # footrest, tied on with red rope
            a.sil(t.d(c_rpoly([(x - d * 20, 318), (x - d * 96, 318), (x - d * 96, 350), (x - d * 20, 372)], [4, 10, 10, 4])), WOOD)
            a.blob(t.d(c_rpoly([(x - d * 20, 350), (x - d * 96, 340), (x - d * 96, 350), (x - d * 20, 372)], [0, 0, 8, 4])), WOOD_D)
        with a.part(8):
            a.sil(t.d(e2_rr(x - 22, 322, 44, 44, 8)), RED)
        t.line(a, x - 20, 344, x + 20, 344, 5, 1, 1, col=RED_D)
        t.shine(a, x - 8, 60, x - 8, 136, sw=6)

    pole(130, -4)
    pole(320, 4)
    return a


@word
def nuigurumi():
    """A stuffed rabbit with a patch and stitches (a toy, so it may have a face)."""
    a = Art()
    C, C_D, IN = "#f9c9d2", "#eeaab8", "#fbe3e7"
    with a.part():                                      # ears, head
        for s_ in (-1, 1):
            a.sil(S2T(s_ * 12, 256 + s_ * 60, 170).d(e2_rr(256 + s_ * 60 - 30, 22, 60, 170, 30)), C)
        a.sil(c_circ(256, 210, 112, 96), C)
        for s_ in (-1, 1):
            a.blob(S2T(s_ * 12, 256 + s_ * 60, 170).d(e2_rr(256 + s_ * 60 - 13, 44, 26, 96, 13)), IN)
    with a.part():                                      # legs
        for s_ in (-1, 1):
            a.sil(c_circ(256 + s_ * 70, 436, 52, 40), C)
    for s_ in (-1, 1):
        a.blob(c_circ(256 + s_ * 74, 440, 26, 20), IN)
    with a.part():                                      # body and arms
        a.sil("M256 270 C330 270 356 330 350 390 C346 436 310 452 256 452 C202 452 166 436 162 390 C156 330 182 270 256 270 Z", C)
        for s_ in (-1, 1):
            a.sil(S2T(s_ * -34, 256 + s_ * 96, 330).d(e2_rr(256 + s_ * 96 - 28, 290, 56, 100, 28)), C)
        a.blob(c_circ(256, 380, 54, 50), IN)
    with a.part(7):                                     # patch
        a.sil(e2_rr(280, 330, 44, 44, 8), "#8fd0ee")
    for (x0, y0, x1, y1) in ((274, 342, 286, 342), (318, 362, 330, 362), (302, 324, 302, 336), (302, 368, 302, 380)):
        c_line(a, x0, y0, x1, y1, 5, s=1, e=1)
    with a.part(8):                                     # ribbon
        a.sil("M256 286 C232 262 200 264 202 286 C204 308 236 306 256 286 Z", RED)
        a.sil("M256 286 C280 262 312 264 310 286 C308 308 276 306 256 286 Z", RED)
    a.sil(c_circ(256, 286, 12), RED_D)
    a.eye(256 - 44, 206, 15)
    a.eye(256 + 44, 206, 15)
    a.cheek(256 - 74, 240, 15, 9)
    a.cheek(256 + 74, 240, 15, 9)
    a.blob(c_circ(256, 232, 9, 7), "#e58a9a")
    a.path("M256 239 L256 246 M256 246 C250 254 240 254 236 248 M256 246 C262 254 272 254 276 248", sw=6)
    return a


@word
def kazaguruma():
    a = Art()
    cx, cy = 256, 190
    with a.part():                                      # stick
        a.sil(e2_rr(246, 190, 20, 290, 9), WOOD)
        a.blob(e2_rr(256, 196, 9, 282, 4), WOOD_D)
    cols = ((RED, RED_D), (YEL2, "#e5a92d"), ("#63b86a", "#4a9f55"), (BLUE, BLUE_D))
    R = 164
    with a.part():                                      # four sails, one outline
        for i, (c, cd) in enumerate(cols):
            t = S2T(i * 90, cx, cy)
            a.sil(t.d(f"M{cx} {cy} L{cx} {cy - R} C{cx + 70} {cy - R + 6} {cx + 112} {cy - 80} {cx + 104} {cy - 22} Z"), c)
        for i, (c, cd) in enumerate(cols):
            t = S2T(i * 90, cx, cy)
            a.blob(t.d(f"M{cx} {cy} L{cx + 62} {cy - 76} C{cx + 96} {cy - 70} {cx + 106} {cy - 44} {cx + 104} {cy - 22} Z"), cd)
            a.ink([t.seg(cx, cy, cx + 100, cy - 22)], 7, a=0.3, b=1)
            a.ink([t.seg(cx, cy, cx, cy - R + 4)], 7, a=0.3, b=1)
    with a.part(8):
        a.sil(c_circ(cx, cy, 20), WHITE)
    a.dot(cx, cy, 8, "#8a949a")
    a.shine(f"M{cx + 18} {cy - 138} C{cx + 46} {cy - 132} {cx + 68} {cy - 112} {cx + 80} {cy - 88}", sw=7)
    return a


@word
def kamihikouki():
    a = Art()
    P, P_D, P_DD = "#fdfdf8", "#dfe9f0", "#c2d2de"
    with a.part(7):                                     # speed lines
        for y, x0, x1 in ((330, 40, 150), (384, 90, 190), (436, 60, 130)):
            a.sil(e2_cap(x0, y, x1, y - (x1 - x0) * 0.35, 12), "#bfe6fa")
    with a.part():                                      # far wing
        a.sil("M476 96 L170 196 L262 262 Z", P_D)
    with a.part():                                      # keel (the fold underneath)
        a.sil("M476 96 L262 262 L250 372 Z", P_DD)
    with a.part():                                      # near wing
        a.sil("M476 96 L60 300 L250 300 Z", P)
        a.blob("M476 96 L250 300 L196 300 Z", P_D)
    c_line(a, 470, 100, 252, 298, 6, s=0.4, e=1)
    a.shine("M150 270 L330 180", sw=7)
    return a


@word
def koto():
    a = Art()
    t = S2T(-18)
    BODY, BODY_D, END = "#d9a05b", "#bf8442", "#7a4a2b"
    with a.part():                                      # legs
        for x in (86, 410):
            a.sil(t.d(e2_rr(x, 300, 30, 60, 8)), END)
    with a.part():                                      # long body
        a.sil(t.d(e2_rr(20, 196, 472, 124, 26)), BODY)
        a.blob(t.d(e2_rr(20, 284, 472, 36, 18)), BODY_D)
        a.blob(t.d(c_rpoly([(20, 196), (66, 196), (66, 320), (20, 320)], [26, 0, 0, 26])), END)
        a.blob(t.d(c_rpoly([(446, 196), (492, 196), (492, 320), (446, 320)], [0, 26, 26, 0])), END)
    for i in range(5):                                  # strings and their bridges
        y = 214 + i * 15
        t.line(a, 66, y, 446, y, 4, 1, 1, col="#fff4e2")
    for i in range(5):
        x, y = 150 + i * 56, 214 + i * 15
        px, py = t.p(x, y)
        with a.part(5):
            a.sil(S2T(-18, px, py).d(e2_poly([(px - 9, py + 8), (px, py - 12), (px + 9, py + 8)])), WHITE)
    e2_note(a, 372, 104, 0.9, "#ee6a62")
    t.shine(a, 90, 206, 250, 206, sw=5)
    return a


@word
def tekkin():
    a = Art()
    with a.part():                                      # the wooden case
        a.sil(c_rpoly([(40, 150), (472, 196), (472, 372), (40, 418)], [22, 22, 22, 22]), "#f7c98d")
        a.blob(c_rpoly([(41, 384), (471, 342), (471, 371), (41, 417)], [0, 0, 21, 21]), WOOD_D)
    with a.part(9):                                     # silver bars, shorter to the right
        for i in range(8):
            x = 66 + i * 49
            top, bot = 172 + i * 6.4, 396 - i * 6.4
            a.sil(e2_rr(x, top, 38, bot - top, 10), S2_STEEL)
            a.blob(e2_rr(x + 24, top + 5, 12, bot - top - 10, 6), S2_STEEL_D)
            a.dot(x + 17, top + 22, 5.5, GREY)
            a.dot(x + 17, bot - 22, 5.5, GREY)
    a.sil(e2_cap(300, 150, 398, 46, 14), WOOD)           # mallets
    a.sil(e2_cap(350, 168, 470, 92, 14), WOOD)
    a.sil_ellipse(402, 42, 26, 26, RED)
    a.sil_ellipse(474, 90, 26, 26, RED)
    a.shine("M76 196 L76 250", sw=6)
    return a


@word
def ukiwa():
    a = Art()
    cx, cy, rx, ry = 256, 262, 214, 168
    hx, hy = 96, 62
    ring = c_circ(cx, cy, rx, ry) + " " + c_circ(cx, cy - 16, hx, hy, ccw=True)
    with a.part():
        a.sil(ring, WHITE)
        for i in range(6):                              # red stripes
            a0 = math.radians(i * 60 + 12)
            a1 = math.radians(i * 60 + 42)
            pts = [(cx + rx * 1.02 * math.cos(a0), cy + ry * 1.02 * math.sin(a0)), (cx + rx * 1.02 * math.cos((a0 + a1) / 2) * 1.03, cy + ry * 1.05 * math.sin((a0 + a1) / 2)),
                   (cx + rx * 1.02 * math.cos(a1), cy + ry * 1.02 * math.sin(a1)),
                   (cx + hx * 0.96 * math.cos(a1), cy - 16 + hy * 0.96 * math.sin(a1)), (cx + hx * 0.96 * math.cos(a0), cy - 16 + hy * 0.96 * math.sin(a0))]
            a.blob(e2_poly(pts), RED)
        a.blob(d_rim(c_circ(cx, cy, rx, ry), 70, 75, 30), "#4a3428", fill_opacity="0.12")
    # the outline again, so the stripes never cover it
    a.path(c_circ(cx, cy, rx, ry), sw=11)
    a.path(c_circ(cx, cy - 16, hx, hy), sw=11)
    a.blob(c_circ(cx, cy - 16, hx - 5, hy - 5), "#9fd3f2")
    a.path(f"M{cx - 50} {cy - 20} C{cx - 30} {cy - 32} {cx - 10} {cy - 8} {cx + 10} {cy - 20}", stroke=WHITE, sw=7, **{"stroke-opacity": "0.85"})
    a.shine("M92 200 C112 156 152 126 200 114", sw=9)
    return a


@word
def tamaire():
    a = Art()
    with a.part():                                      # pole and foot
        a.sil(e2_rr(244, 250, 24, 200, 8), S2_STEEL)
        a.sil(c_rpoly([(150, 446), (362, 446), (382, 478), (130, 478)], [8, 8, 10, 10]), "#8a949a")
        a.blob(e2_rr(256, 254, 11, 190, 5), S2_STEEL_D)
    BAS, BAS_D = "#f2c078", "#d99e50"
    with a.part():                                      # basket
        a.sil("M120 132 L392 132 L352 276 C348 290 164 290 160 276 Z", BAS)
        a.blob("M352 132 L392 132 L352 276 C350 284 300 288 256 288 C300 280 322 270 326 256 Z", BAS_D)
        for x in (190, 256, 322):
            c_line(a, x - (256 - x) * 0.18, 150, x, 282, 5, s=1, e=1, col="#b87a34")
        for y in (180, 226):
            a.ink([(134 + (y - 132) * 0.28, y, 200, y + 10, 312, y + 10, 378 - (y - 132) * 0.28, y)], 5, a=1, b=1, col="#b87a34")
    with a.part():                                      # balls in the basket
        for x, y, c in ((196, 118, RED), (256, 104, WHITE), (316, 118, RED), (228, 132, WHITE), (288, 132, RED)):
            a.sil(c_circ(x, y, 30), c)
    with a.part():
        a.sil(e2_rr(108, 118, 296, 30, 15), BAS_D)       # rim
    for x, y, c in ((84, 404, WHITE), (430, 330, RED), (60, 250, RED)):     # balls in the air / on the ground
        with a.part():
            a.sil(c_circ(x, y, 32), c)
        a.shine(f"M{x - 16} {y - 6} C{x - 14} {y - 16} {x - 6} {y - 20} {x + 2} {y - 20}", sw=6)
    return a


@word
def tsunahiki():
    a = Art()
    ROPE, ROPE_D = "#e9c98a", "#b88a48"
    y, h = 226, 34
    with a.part(8):                                     # the line on the ground
        a.sil(e2_rr(238, 372, 36, 100, 10), WHITE)
    with a.part():                                      # ribbon tails behind the rope
        a.sil("M236 240 L200 372 L236 350 L256 388 L276 350 L312 372 L276 240 Z", RED_D)
    with a.part():                                      # a straight, tight rope with frayed ends
        a.sil(e2_poly([(52, y - h), (460, y - h), (460, y + h), (52, y + h)]), ROPE)
        a.sil(f"M60 {y - h} L14 {y - h - 26} Q4 {y} 14 {y + h + 26} L60 {y + h} Z", ROPE)
        a.sil(f"M452 {y - h} L498 {y - h - 26} Q508 {y} 498 {y + h + 26} L452 {y + h} Z", ROPE)
        a.blob(e2_poly([(52, y + h * 0.35), (460, y + h * 0.35), (460, y + h), (52, y + h)]), "#d9b56f")
        for i in range(11):                             # twists
            x = 84 + i * 34
            if 220 < x < 290:
                continue
            a.ink([(x + 12, y - h, x + 6, y - h * 0.4, x - 6, y + h * 0.4, x - 12, y + h)], 8, a=1, b=1, col=ROPE_D)
        for x0, x1 in ((60, 22), (452, 490)):
            for dy in (-14, 14):
                c_line(a, x0 + (x1 - x0) * 0.3, y + dy * 0.8, x1, y + dy * 1.6, 6, s=0.3, e=1, col=ROPE_D)
    with a.part(8):                                     # binding near the ends
        a.sil(e2_rr(48, y - h - 6, 22, h * 2 + 12, 8), RED)
        a.sil(e2_rr(442, y - h - 6, 22, h * 2 + 12, 8), RED)
    with a.part():                                      # the red mark in the middle
        a.sil(e2_rr(222, y - h - 12, 68, h * 2 + 24, 14), RED)
        a.blob(e2_rr(222, y + 14, 68, h + 10, 12), RED_D)
    a.shine(f"M96 {y - 18} L200 {y - 18}", sw=6)
    return a


@word
def untei():
    a = Art()
    C, C_D = BLUE, BLUE_D
    with a.part():                                      # far legs
        a.sil(c_bar(140, 110, 120, 452, 22), C_D)
        a.sil(c_bar(460, 110, 480, 452, 22), C_D)
    with a.part():                                      # near legs and the two rails
        a.sil(c_bar(56, 176, 34, 470, 26), C)
        a.sil(c_bar(376, 176, 398, 470, 26), C)
        a.sil(c_bar(56, 176, 376, 176, 26), C)
        a.sil(c_bar(140, 110, 460, 110, 22), C)
    with a.part(8):                                     # rungs
        for i in range(5):
            x = 84 + i * 62
            a.sil(c_bar(x, 176, x + 84, 110, 15), YEL2)
    for x, y in ((34, 470), (398, 470), (120, 452), (480, 452)):          # feet
        with a.part(8):
            a.sil(e2_rr(x - 22, y - 10, 44, 22, 8), GREY)
    return a


@word
def funsui():
    a = Art()
    WAT, WAT_D, STONE, STONE_D = "#9fd3f2", "#6db8e0", "#e3e7ea", "#b9c4cf"
    with a.part(8):                                     # water jets
        a.sil("M244 250 C240 170 244 110 256 60 C268 110 272 170 268 250 Z", WAT)
        for s_ in (-1, 1):
            a.sil(f"M{256 + s_ * 12} 240 C{256 + s_ * 30} 150 {256 + s_ * 110} 120 {256 + s_ * 150} 196 C{256 + s_ * 158} 214 {256 + s_ * 150} 232 {256 + s_ * 140} 236 "
                  f"C{256 + s_ * 132} 180 {256 + s_ * 70} 170 {256 + s_ * 34} 244 Z", WAT)
    with a.part():                                      # top bowl and stem
        a.sil(e2_rr(236, 250, 40, 110, 8), STONE)
        a.sil("M168 236 L344 236 C344 276 306 296 256 296 C206 296 168 276 168 236 Z", STONE)
        a.blob("M306 236 L344 236 C344 276 306 296 256 296 C290 286 306 264 306 236 Z", STONE_D)
    with a.part():                                      # basin
        a.sil(c_circ(256, 372, 214, 50), WAT)
        a.sil("M42 372 C42 400 138 422 256 422 C374 422 470 400 470 372 L452 440 C446 462 370 476 256 476 C142 476 66 462 60 440 Z", STONE)
        a.blob("M400 410 C436 402 462 390 470 372 L452 440 C448 454 420 464 380 470 C394 450 400 430 400 410 Z", STONE_D)
        a.ink([(42, 372, 42, 400, 138, 422, 256, 422)], 7, a=1, b=1)
        a.ink([(256, 422, 374, 422, 470, 400, 470, 372)], 7, a=1, b=1)
    for x, y in ((150, 366), (350, 370), (256, 386)):
        a.path(f"M{x - 24} {y} C{x - 12} {y - 8} {x + 12} {y + 8} {x + 24} {y}", stroke=WHITE, sw=6, **{"stroke-opacity": "0.9"})
    for x, y in ((92, 150), (420, 150), (330, 70)):     # drops
        with a.part(6):
            a.sil(f"M{x} {y - 16} C{x + 12} {y - 2} {x + 12} {y + 12} {x} {y + 12} C{x - 12} {y + 12} {x - 12} {y - 2} {x} {y - 16} Z", WAT)
    return a


@word
def sanrinsha():
    a = Art()
    FR, FR_D = RED, RED_D
    with a.part():                                      # far back wheel
        c_wheel(a, 392, 400, 52)
    with a.part():                                      # frame: one bent tube from the fork to the back axle, with the seat post
        a.sil(c_bar(160, 220, 132, 392, 22), FR)
        a.sil(taper([(156, 250, 220, 250, 280, 300, 340, 392)], 26, 26, cap=True), FR)
        a.sil(c_bar(300, 300, 300, 262, 18), FR)
    with a.part():                                      # seat
        a.sil(c_rpoly([(250, 236), (360, 236), (366, 270), (244, 270)], [14, 16, 12, 12]), NAVY)
    with a.part():                                      # handlebar with grips
        a.sil(c_bar(110, 190, 220, 172, 18), S2_STEEL)
        a.sil(c_bar(166, 182, 160, 226, 18), S2_STEEL)
    with a.part(8):
        a.sil(c_bar(96, 192, 124, 188, 24), YEL2)
        a.sil(c_bar(206, 174, 234, 170, 24), YEL2)
    with a.part():                                      # big front wheel with pedals
        c_wheel(a, 132, 392, 76, hub=YEL)
    with a.part(7):
        a.sil(e2_rr(96, 384, 36, 16, 6), GREY)
    with a.part():                                      # near back wheel
        c_wheel(a, 340, 412, 56)
    a.shine("M196 262 C230 272 260 300 284 338", sw=6)
    return a


# ------------------------------------------------------------- のりもの --
@word
def basha():
    """A coach (no horse: the horse is its own word)."""
    a = Art()
    C, C_D, GOLD = "#f48a9a", "#e0707f", YEL2

    def spoked(cx, cy, r):
        with a.part():
            a.sil(c_circ(cx, cy, r) + " " + c_circ(cx, cy, r - 16, ccw=True), GOLD)
        with a.part(6):
            for k in range(4):
                an = math.radians(k * 45)
                a.sil(c_bar(cx - (r - 12) * math.cos(an), cy - (r - 12) * math.sin(an), cx + (r - 12) * math.cos(an), cy + (r - 12) * math.sin(an), 9), GOLD)
        with a.part(6):
            a.sil(c_circ(cx, cy, 15), "#e5a92d")

    with a.part():                                      # shafts to the front
        a.sil(c_bar(60, 330, 200, 350, 16), WOOD_D)
    with a.part():                                      # crown on the roof
        a.sil("M250 96 L262 60 L282 84 L302 54 L322 84 L342 60 L354 96 Z", GOLD)
    with a.part():                                      # body
        a.sil("M176 150 C176 118 198 100 232 100 L372 100 C406 100 428 118 428 150 L428 300 C428 348 396 372 352 372 "
              "L252 372 C208 372 176 348 176 300 Z", C)
        a.blob("M392 106 C414 114 428 128 428 150 L428 300 C428 348 396 372 352 372 L320 372 C366 360 390 336 392 296 Z", C_D)
        a.blob("M177 250 L427 250 L427 268 L177 268 Z", GOLD)
    c_glass(a, c_rpoly([(214, 136), (286, 136), (286, 222), (214, 222)], [22, 10, 6, 6]), glint=(226, 150, 18))
    c_glass(a, c_rpoly([(318, 136), (390, 136), (390, 222), (318, 222)], [10, 22, 6, 6]))
    with a.part(7):                                     # door handle
        a.sil(c_circ(302, 300, 9), GOLD)
    with a.part(8):                                     # lantern
        a.sil(e2_rr(142, 176, 30, 44, 10), "#fff1a8")
    spoked(200, 400, 62)
    spoked(396, 388, 76)
    a.shine("M196 140 C198 126 208 118 222 116", sw=7)
    return a


@word
def kikansha():
    a = Art()
    BLK, BLK_D, REDL = "#4f5a66", "#3e4853", RED
    with a.part(8):                                     # smoke
        a.sil("M134 96 C112 96 104 70 124 60 C122 36 156 26 170 44 C190 30 216 46 208 68 C226 78 216 104 196 100 C184 112 150 112 134 96 Z", WHITE)
        a.blob("M196 100 C216 104 226 78 208 68 C206 84 190 92 170 92 C156 96 144 98 134 96 C150 112 184 112 196 100 Z", "#d7ecf8")
    with a.part():                                      # chimney
        a.sil("M124 128 L196 128 L186 214 L134 214 Z", BLK)
        a.sil(e2_rr(114, 118, 92, 26, 10), REDL)
    with a.part():                                      # dome
        a.sil("M246 214 C246 178 298 178 298 214 Z", YEL2)
    with a.part():                                      # cab
        a.sil(c_rpoly([(330, 110), (472, 110), (472, 380), (330, 380)], [8, 8, 8, 8]), REDL)
        a.blob(c_rpoly([(331, 330), (471, 330), (471, 379), (331, 379)], [0, 0, 7, 7]), RED_D)
    with a.part():
        a.sil(e2_rr(314, 92, 174, 32, 12), BLK)          # cab roof
    c_glass(a, e2_rr(362, 152, 78, 76, 12), glint=(374, 166, 20))
    with a.part():                                      # boiler
        a.sil(c_rpoly([(70, 206), (340, 206), (340, 380), (70, 380)], [60, 0, 0, 30]), BLK)
        a.blob(c_rpoly([(71, 336), (339, 336), (339, 379), (71, 379)], [0, 0, 0, 29]), BLK_D)
        for x in (150, 236):
            a.blob(e2_rr(x, 207, 16, 172, 0), YEL2)
    c_lamp(a, 68, 262, 20, 24)
    with a.part():                                      # cowcatcher
        a.sil("M40 372 L120 372 L120 440 L22 440 Z", REDL)
    with a.part():                                      # footboard
        a.sil(e2_rr(96, 372, 388, 26, 10), "#8a949a")
    for x, r in ((170, 44), (262, 44)):
        c_wheel(a, x, 420, r, hub=RED)
    c_wheel(a, 394, 404, 62, hub=RED)
    with a.part(7):                                     # coupling rod
        a.sil(c_bar(170, 428, 394, 428, 14), S2_STEEL)
    a.shine("M110 232 C150 222 230 222 300 226", sw=7)
    return a


def s2_truck_wheels(a, xs, y=392, r=44):
    for x in xs:
        c_wheel(a, x, y, r)


@word
def hashigosha():
    """A ladder truck: the long ladder is raised high (the fire engine of the base words carries its ladder flat)."""
    a = Art()
    with a.part(7):                                     # long raised ladder with a basket
        for off in (-16, 16):
            a.sil(c_bar(150 + off * 0.5, 268 - off, 440 + off * 0.5, 62 - off, 12), S2_STEEL)
        for t in (0.12, 0.28, 0.44, 0.6, 0.76, 0.92):
            x, y = 150 + 290 * t, 268 - 206 * t
            a.sil(c_bar(x - 8, y + 16, x + 8, y - 16, 9), S2_STEEL)
    with a.part():                                      # basket at the top
        a.sil(c_rpoly([(406, 28), (486, 28), (480, 92), (412, 92)], [8, 8, 12, 12]), YEL2)
        a.blob(c_rpoly([(408, 66), (484, 66), (480, 91), (412, 91)], [0, 0, 11, 11]), "#e5a92d")
    with a.part():                                      # turntable
        a.sil(c_rpoly([(110, 250), (206, 250), (216, 296), (100, 296)], [10, 10, 4, 4]), "#8a949a")
    with a.part():                                      # beacon
        a.sil(c_rpoly([(356, 222), (394, 222), (394, 262), (356, 262)], [16, 16, 0, 0]), "#ffd04a")
    with a.part():                                      # body and cab
        a.sil("M36 310 Q36 286 60 286 L300 286 L300 262 Q300 252 312 252 L402 252 C430 252 444 266 454 294 L468 302 Q480 310 480 326 "
              "L480 364 Q480 390 454 390 L62 390 Q36 390 36 364 Z", RED)
        a.blob("M37 326 L479 326 L479 346 L37 346 Z", WHITE)
        a.blob("M37 364 L479 364 Q478 389 454 389 L62 389 Q38 389 37 364 Z", RED_D)
    c_line(a, 300, 290, 300, 384, 7, s=0.6, e=0.3)
    c_glass(a, "M330 268 L398 268 C414 268 424 278 432 298 Q434 306 426 306 L330 306 Q322 306 322 298 L322 276 Q322 268 330 268 Z",
            glint=(336, 276, 18))
    c_lamp(a, 468, 334, 9, 12)
    s2_truck_wheels(a, (120, 392))
    return a


@word
def yuubinsha():
    """A red mail van with the white 〒 mark."""
    a = Art()
    with a.part():
        a.sil("M50 196 Q50 166 80 166 L330 166 C372 166 400 186 420 230 L446 286 Q470 292 470 318 L470 356 Q470 384 442 384 "
              "L78 384 Q50 384 50 356 Z", RED)
        a.blob("M51 344 L469 344 L469 356 Q469 383 442 383 L78 383 Q51 383 51 356 Z", RED_D)
        a.blob(c_circ(170, 262, 60), WHITE)
        for d in (e2_rr(138, 228, 64, 13, 5), e2_rr(134, 250, 72, 13, 5), e2_rr(163, 256, 14, 46, 5)):
            a.blob(d, RED)
    c_line(a, 270, 172, 270, 378, 7, s=0.6, e=0.3)
    c_glass(a, "M292 190 L334 190 C362 190 380 204 394 236 L408 268 Q412 278 400 278 L292 278 Q284 278 284 270 L284 198 Q284 190 292 190 Z",
            glint=(300, 202, 22))
    c_lamp(a, 458, 320, 9, 13)
    a.blob(e2_rr(300, 300, 30, 10, 5), WHITE)
    s2_truck_wheels(a, (136, 372), y=386, r=46)
    a.shine("M76 184 L220 184", sw=6)
    return a


@word
def hikousen():
    a = Art()
    C, C_D, ST = "#fdfdf8", "#dfe9f0", RED
    with a.part():                                      # tail fins
        a.sil("M410 208 L486 140 Q496 134 496 148 L496 250 Z", ST)
        a.sil("M410 300 L486 368 Q496 374 496 360 L496 262 Z", ST)
    hull = "M28 254 C28 168 150 126 270 126 C390 126 476 190 476 254 C476 318 390 382 270 382 C150 382 28 340 28 254 Z"
    with a.part():                                      # gondola under the hull
        a.sil(c_rpoly([(190, 366), (330, 366), (314, 432), (206, 432)], [6, 6, 20, 20]), BLUE)
    for x in (220, 262):
        c_glass(a, e2_rr(x, 388, 30, 26, 8), ow=5)
    with a.part():                                      # hull
        a.sil(hull, C)
        a.blob(d_rim(hull, 80, 80, 44), C_D)
        a.blob("M36 222 C150 196 370 196 468 222 L476 262 C372 236 150 236 29 266 Z", ST)
    a.blob(e2_star(214, 296, 30, 13), YEL2)
    a.shine("M70 204 C104 168 160 148 220 142", sw=8)
    return a


# ---------------------------------------------------- たてもの・まちの もの --
def s2_bush(a, x, flip=False):
    d = f"M{x} 460 C{x - 8} 436 {x + 18} 422 {x + 34} 436 C{x + 48} 426 {x + 68} 438 {x + 64} 460 Z"
    with a.part(9):
        a.sil(mirror(d, x + 32) if flip else d, S2_LEAF)


def s2_windows(a, xs, ys, w=56, h=58, ow=5, cross=True):
    for x in xs:
        for y in ys:
            c_glass(a, c_rect(x, y, w, h, 8), ow=ow)
            if cross:
                c_line(a, x + w / 2, y + 3, x + w / 2, y + h - 3, 4, s=1, e=1)


@word
def jinja():
    """A shrine: the red torii in front, the small hall behind it."""
    a = Art()
    VER, VER_D, ROOF, ROOF_D = "#e5534b", "#c9403a", "#5d7894", "#486079"
    with a.part():                                      # hall
        a.sil(c_rect(176, 300, 160, 150, 4), S2_WALL)
        a.blob(c_rect(232, 350, 48, 100, 0), "#a8672f")
    with a.part():
        a.sil("M256 214 Q268 214 278 222 L372 290 Q384 300 376 310 L136 310 Q128 300 140 290 L234 222 Q244 214 256 214 Z", ROOF)
        a.blob("M140 296 L372 296 Q382 302 376 310 L136 310 Q130 302 140 296 Z", ROOF_D)
    with a.part():                                      # steps
        a.sil(c_rpoly([(150, 440), (362, 440), (376, 470), (136, 470)], [4, 4, 8, 8]), "#e3e7ea")
    with a.part():                                      # torii: two posts and the lower beam
        a.sil(c_rpoly([(96, 150), (132, 150), (140, 470), (88, 470)], [0, 0, 6, 6]), VER)
        a.sil(c_rpoly([(380, 150), (416, 150), (424, 470), (372, 470)], [0, 0, 6, 6]), VER)
        a.sil(c_rect(60, 176, 392, 34, 6), VER)
        a.blob(c_rect(122, 150, 14, 318, 0), VER_D)
        a.blob(c_rect(406, 150, 14, 318, 0), VER_D)
    with a.part():                                      # the top beam, curved up at the ends
        a.sil("M30 90 C120 112 392 112 482 90 L474 142 C390 154 122 154 38 142 Z", VER)
        a.sil("M22 70 C120 94 392 94 490 70 L486 100 C392 122 120 122 26 100 Z", "#3d3f4a")
    with a.part(8):                                     # the plaque
        a.sil(c_rect(234, 140, 44, 50, 6), YEL2)
    a.shine("M104 230 L104 400", sw=6)
    return a


@word
def kouban():
    """A police box: small, with the round red lamp over the door and a gold star."""
    a = Art()
    C, C_D, ROOF = "#eef3f6", "#cfdbe3", NAVY
    with a.part():
        a.sil(c_rpoly([(78, 200), (434, 200), (434, 454), (78, 454)], [8, 8, 10, 10]), C)
        a.blob(c_rect(79, 408, 354, 45, 0), "#8aa6c6")
    with a.part():                                      # flat roof
        a.sil(c_rpoly([(52, 150), (460, 150), (460, 214), (52, 214)], [14, 14, 10, 10]), ROOF)
        a.blob(c_rect(53, 196, 406, 17, 0), "#293f66")
    with a.part(8):                                     # the red lamp on top
        a.sil(c_rect(226, 122, 60, 32, 6), "#8a949a")
    with a.part():
        a.sil(c_circ(256, 96, 38), RED)
    a.shine("M234 86 C238 76 246 70 256 68", sw=6)
    a.blob(e2_star(256, 182, 24, 11), YEL2)
    with a.part(9):                                     # the open doorway
        a.sil(c_rpoly([(206, 268), (306, 268), (306, 454), (206, 454)], [10, 10, 0, 0]), "#5f7fa8")
    c_glass(a, c_rect(220, 284, 72, 80, 6), ow=5, glint=(230, 296, 22))
    s2_windows(a, (106, 344), (286,), w=64, h=76)
    for x in (106, 344):
        c_line(a, x + 3, 324, x + 61, 324, 4, s=1, e=1)
    s2_bush(a, 26)
    return a


@word
def toshokan():
    """A library: columns, wide steps, and an open book over the door."""
    a = Art()
    ROOF, ROOF_D, STONE, STONE_D = "#7fb08f", "#629577", "#fdf6e6", "#e6dccb"
    with a.part():                                      # walls
        a.sil(c_rect(70, 214, 372, 220, 4), STONE)
        a.blob(c_rect(71, 214, 370, 22, 0), STONE_D)
    with a.part():                                      # roof (a low triangle)
        a.sil("M256 78 Q268 78 280 86 L468 190 Q482 198 476 210 Q472 220 458 220 L54 220 Q40 220 36 210 Q30 198 44 190 L232 86 Q244 78 256 78 Z", ROOF)
        a.blob("M44 196 L468 196 Q480 200 476 210 Q472 219 458 219 L54 219 Q40 219 36 210 Q32 200 44 196 Z", ROOF_D)
    # the open book on the gable
    with a.part(7):
        a.sil("M256 130 C240 118 216 116 200 122 L200 172 C216 166 240 168 256 180 C272 168 296 166 312 172 L312 122 C296 116 272 118 256 130 Z", WHITE)
    c_line(a, 256, 132, 256, 178, 5, s=1, e=1)
    with a.part(9):                                     # door
        a.sil(c_rpoly([(222, 300), (290, 300), (290, 434), (222, 434)], [30, 30, 0, 0]), "#a8672f")
    c_line(a, 256, 304, 256, 432, 5, s=1, e=1)
    with a.part():                                      # four columns
        for x in (96, 166, 318, 388):
            a.sil(c_rect(x, 232, 30, 202, 6), WHITE)
            a.blob(c_rect(x + 19, 234, 10, 198, 0), "#dfe5ea")
    with a.part():                                      # steps
        a.sil(c_rpoly([(52, 424), (460, 424), (460, 448), (52, 448)], [6, 6, 0, 0]), STONE_D)
        a.sil(c_rpoly([(30, 446), (482, 446), (482, 472), (30, 472)], [6, 6, 8, 8]), STONE)
    return a


@word
def youchien():
    """A kindergarten: a low, colourful building with a tulip sign and a round door."""
    a = Art()
    C, C_D, ROOF, ROOF_D = "#fff0d4", "#ecd8b2", "#f7a94b", "#e58d32"
    with a.part():
        a.sil(c_rpoly([(52, 236), (460, 236), (460, 454), (52, 454)], [6, 6, 10, 10]), C)
        a.blob(c_rect(53, 414, 406, 39, 0), "#f9c9d2")
    with a.part():                                      # roof: a wide scalloped awning shape
        a.sil("M256 96 Q270 96 284 104 L476 218 Q492 228 486 242 Q480 254 464 254 L48 254 Q32 254 26 242 Q20 228 36 218 L228 104 Q242 96 256 96 Z", ROOF)
        a.blob("M36 230 L476 230 Q490 234 486 242 Q480 253 464 253 L48 253 Q32 253 26 242 Q22 234 36 230 Z", ROOF_D)
    with a.part(8):                                     # tulip sign on the gable
        a.sil(c_circ(256, 176, 44), WHITE)
    a.blob("M236 160 L246 172 L256 158 L266 172 L276 160 L276 180 C276 196 236 196 236 180 Z", RED)
    a.blob(e2_rr(253, 190, 6, 20, 2), S2_LEAF_D)
    with a.part(9):                                     # round-top double door
        a.sil("M206 454 L206 350 C206 286 306 286 306 350 L306 454 Z", "#63b86a")
    c_line(a, 256, 306, 256, 452, 6, s=1, e=1)
    a.dot(244, 384, 6, YEL2)
    a.dot(268, 384, 6, YEL2)
    for x, col in ((84, "#8fd0ee"), (360, "#8fd0ee")):
        c_glass(a, c_rect(x, 296, 68, 68, 12), ow=5, col=col)
        c_line(a, x + 34, 300, x + 34, 360, 4, s=1, e=1)
        c_line(a, x + 4, 330, x + 64, 330, 4, s=1, e=1)
    for x, c in ((70, RED), (116, YEL2), (378, BLUE), (424, RED)):          # flowers along the wall
        a.blob(e2_rr(x - 2, 426, 5, 26, 2), S2_LEAF_D)
        with a.part(6):
            a.sil(c_circ(x, 420, 13), c)
        a.dot(x, 420, 5, WHITE)
    return a


@word
def yuubinkyoku():
    """A post office: a red-roofed box of a building with the 〒 mark and a post box outside."""
    a = Art()
    C, C_D = "#fff0d4", "#ecd8b2"
    with a.part():
        a.sil(c_rpoly([(60, 190), (400, 190), (400, 454), (60, 454)], [6, 6, 10, 10]), C)
        a.blob(c_rect(61, 250, 338, 16, 0), C_D)
    with a.part():                                      # sign board across the top
        a.sil(c_rpoly([(40, 100), (420, 100), (420, 250), (40, 250)], [18, 18, 10, 10]), RED)
        a.blob(c_rpoly([(41, 222), (419, 222), (419, 249), (41, 249)], [0, 0, 9, 9]), RED_D)
        for d in (e2_rr(176, 124, 108, 18, 6), e2_rr(168, 156, 124, 18, 6), e2_rr(220, 164, 20, 66, 6)):
            a.blob(d, WHITE)
    with a.part(9):                                     # glass door
        a.sil(c_rect(180, 318, 100, 136, 4), SKY)
    c_line(a, 230, 322, 230, 452, 5, s=1, e=1)
    a.path("M192 334 L204 316", stroke=WHITE, sw=6, **{"stroke-opacity": "0.75"})
    s2_windows(a, (84, 310), (322,), w=68, h=64)
    with a.part():                                      # the post box outside
        a.sil(c_rect(446, 420, 24, 50, 4), RED_D)
        a.sil(c_rpoly([(418, 300), (498, 300), (498, 426), (418, 426)], [20, 20, 8, 8]), RED)
        a.blob(c_rpoly([(476, 302), (497, 318), (497, 425), (476, 425)], [0, 0, 7, 0]), RED_D)
    a.blob(e2_rr(432, 334, 52, 12, 6), "#3b2f2a")
    a.blob(e2_rr(436, 366, 44, 30, 4), WHITE)
    return a


@word
def kanban():
    """A shop signboard on two legs, with an arrow and a flower."""
    a = Art()
    with a.part():                                      # legs
        a.sil(c_rect(118, 300, 34, 176, 6), WOOD_D)
        a.sil(c_rect(360, 300, 34, 176, 6), WOOD_D)
    with a.part():                                      # board
        a.sil(c_rect(36, 70, 440, 270, 30), "#f7c98d")
        a.blob(c_rpoly([(37, 300), (475, 300), (475, 339), (37, 339)], [0, 0, 29, 29]), WOOD)
    with a.part(8):                                     # white panel
        a.sil(c_rect(70, 100, 372, 190, 18), CREAM)
    with a.part(8):                                     # arrow
        a.sil("M110 180 L250 180 L250 146 L326 200 L250 254 L250 220 L110 220 Z", RED)
    with a.part(7):                                     # flower
        for i in range(5):
            an = math.radians(-90 + i * 72)
            a.sil(c_circ(382 + 24 * math.cos(an), 196 + 24 * math.sin(an), 17), "#f7a8b3")
    a.dot(382, 196, 12, YEL2)
    with a.part(8):                                     # grass at the feet
        a.sil("M84 480 C76 456 102 442 118 456 C132 446 152 458 148 480 Z", S2_LEAF)
        a.sil("M364 480 C356 456 382 442 398 456 C412 446 432 458 428 480 Z", S2_LEAF)
    a.shine("M58 110 C60 96 70 90 84 88", sw=7)
    return a


@word
def denchuu():
    """A utility pole: crossarms, insulators, a transformer and sagging wires, with a sparrow on the wire."""
    a = Art()
    POLE, POLE_D = "#b9a898", "#9a8878"
    for y0, x_end, y_end in ((98, 20, 132), (98, 492, 132), (168, 20, 206), (168, 492, 206)):   # wires
        xs = 130 if x_end < 256 else 382
        a.ink([(xs, y0 - 12, xs + (x_end - xs) * 0.4, y0 + 30, xs + (x_end - xs) * 0.8, y_end + 6, x_end, y_end)], 6, a=1, b=1)
    with a.part():                                      # pole
        a.sil(c_rpoly([(240, 40), (272, 40), (280, 478), (232, 478)], [8, 8, 6, 6]), POLE)
        a.blob(c_rpoly([(260, 42), (272, 42), (279, 477), (264, 477)], [0, 6, 5, 0]), POLE_D)
    with a.part():                                      # transformer
        a.sil(c_rect(280, 214, 70, 96, 14), "#8a949a")
        a.blob(c_rect(328, 216, 21, 92, 10), "#6f7a82")
    for y, w in ((98, 280), (168, 280)):
        with a.part():                                  # crossarm
            a.sil(c_rect(256 - w / 2, y, w, 24, 8), "#8a6a4a")
        with a.part(7):                                 # insulators
            for x in (256 - w / 2 + 18, 256 + w / 2 - 18, 196, 316):
                a.sil(c_rect(x - 9, y - 22, 18, 24, 6), WHITE)
    with a.part(7):                                     # steps on the pole
        for y in (340, 392):
            a.sil(c_bar(222, y, 290, y, 10), "#8a949a")
    # a small sparrow on the left wire
    with a.part(8):
        a.sil("M52 120 C52 96 84 90 96 108 L110 106 L100 118 C100 136 60 142 52 120 Z", "#c98a52")
    a.blob("M70 120 C70 112 92 110 96 116 C94 128 76 132 70 120 Z", CREAM)
    a.dot(88, 106, 4, EYE)
    return a


@word
def hodoukyou():
    """A footbridge over the road: stairs on both sides, a railing, and the road under it."""
    a = Art()
    C, C_D, RAIL = "#a7dfc0", "#7cc5a0", "#63b0d8"
    with a.part():                                      # road
        a.sil(c_rect(20, 420, 472, 58, 10), "#8a949a")
    for x in (120, 232, 344):
        a.blob(e2_rr(x, 444, 48, 10, 5), WHITE)
    with a.part():                                      # pillars
        for x in (150, 334):
            a.sil(c_rect(x, 230, 28, 196, 4), "#cfd8de")
    with a.part():                                      # deck and the two stairs: one shape
        a.sil("M20 426 L20 396 L116 196 Q122 184 136 184 L376 184 Q390 184 396 196 L492 396 L492 426 L452 426 L374 250 "
              "L138 250 L60 426 Z", C)
        a.blob("M124 226 L388 226 L398 250 L114 250 Z", C_D)
        for i in range(1, 5):                           # steps
            for s_ in (-1, 1):
                x = 256 + s_ * (132 + i * 24)
                c_line(a, x - s_ * 12, 204 + i * 44, x + s_ * 14, 204 + i * 44, 6, s=1, e=1, col="#5fa588")
    with a.part(8):                                     # railing
        a.sil("M26 356 L110 150 Q116 136 132 136 L380 136 Q396 136 402 150 L486 356 L466 364 L384 162 Q380 156 374 156 "
              "L138 156 Q132 156 128 162 L46 364 Z", RAIL)
        for x in (176, 256, 336):
            a.sil(c_rect(x - 6, 150, 12, 40, 3), RAIL)
    a.shine("M150 204 L330 204", sw=6)
    return a


@word
def jidouhanbaiki():
    a = Art()
    C, C_D = RED, RED_D
    with a.part():
        a.sil(c_rect(96, 40, 320, 436, 28), C)
        a.blob(c_rpoly([(366, 42), (415, 60), (415, 450), (366, 474)], [0, 20, 20, 0]), C_D)
    with a.part(7):                                     # the window with the drinks
        a.sil(c_rect(124, 70, 222, 190, 14), "#fdf6e6")
    drinks = (("#f7a94b", 0), ("#63b86a", 1), (BLUE, 0), ("#f48a9a", 1), (YEL2, 0), ("#9b7fd1", 1), ("#f7a94b", 1), (BLUE, 0))
    for i, (c, can) in enumerate(drinks):
        x = 140 + (i % 4) * 50
        y = 86 + (i // 4) * 88
        with a.part(5):
            if can:
                a.sil(c_rect(x, y + 10, 30, 50, 6), c)
            else:
                a.sil(c_rpoly([(x + 8, y), (x + 22, y), (x + 22, y + 14), (x + 30, y + 24), (x + 30, y + 60), (x, y + 60), (x, y + 24), (x + 8, y + 14)], [3, 3, 4, 6, 6, 6, 6, 4]), c)
        a.blob(e2_rr(x + 4, y + 30, 22, 14, 3), WHITE)
        a.dot(x + 15, y + 72, 5, "#4fa8e0" if i % 3 else RED)
    c_line(a, 128, 168, 342, 168, 5, s=1, e=1, col="#d9cdb8")
    with a.part(7):                                     # coin slot panel
        a.sil(c_rect(362, 96, 36, 110, 10), "#e9eef2")
    a.blob(e2_rr(374, 112, 12, 26, 4), "#3b2f2a")
    a.dot(380, 172, 9, YEL2)
    with a.part(7):                                     # the door where the drink comes out
        a.sil(c_rect(140, 372, 190, 62, 12), "#3b2f2a")
    a.blob(e2_rr(152, 384, 166, 20, 8), "#6f5a52")
    with a.part(7):                                     # a wide label band
        a.sil(c_rect(124, 284, 222, 60, 12), WHITE)
    a.blob(e2_star(160, 314, 20, 9), YEL2)
    a.blob(e2_rr(190, 304, 130, 9, 4), "#f7a8b3")
    a.blob(e2_rr(190, 320, 90, 9, 4), "#f7a8b3")
    a.shine("M112 70 L112 220", sw=7)
    return a


# ------------------------------------------------- はる・なつの ぎょうじ --
def s2_carp(a, x, y, L, H, col, col_d, belly):
    """One carp streamer flying to the right from its ring at (x, y)."""
    body = (f"M{x} {y - H / 2} C{x + L * 0.3} {y - H * 0.72} {x + L * 0.6} {y - H * 0.5} {x + L * 0.78} {y - H * 0.2} "
            f"L{x + L} {y - H * 0.56} C{x + L * 0.94} {y - H * 0.1} {x + L * 0.94} {y + H * 0.2} {x + L} {y + H * 0.62} "
            f"L{x + L * 0.78} {y + H * 0.24} C{x + L * 0.6} {y + H * 0.56} {x + L * 0.3} {y + H * 0.72} {x} {y + H / 2} Z")
    with a.part(9):
        a.sil(body, col)
        a.blob(f"M{x} {y + H * 0.08} C{x + L * 0.3} {y + H * 0.2} {x + L * 0.6} {y + H * 0.16} {x + L * 0.78} {y + H * 0.04} "
               f"L{x + L * 0.78} {y + H * 0.24} C{x + L * 0.6} {y + H * 0.56} {x + L * 0.3} {y + H * 0.72} {x} {y + H / 2} Z", belly)
        a.blob(c_circ(x + L * 0.02, y, H * 0.14, H * 0.5), WHITE)                          # the open mouth
        for i in range(3):                                                                # scales
            sx = x + L * (0.34 + i * 0.15)
            a.ink([(sx, y - H * 0.34, sx + H * 0.26, y - H * 0.22, sx + H * 0.26, y - H * 0.02, sx, y + H * 0.06)], 6, a=1, b=1, col=col_d)
    with a.part(5):
        a.sil(c_circ(x + L * 0.16, y - H * 0.12, H * 0.17), WHITE)
    a.dot(x + L * 0.17, y - H * 0.12, H * 0.09, EYE)


@word
def koinobori():
    a = Art()
    with a.part():                                      # pole
        a.sil(c_rpoly([(92, 70), (112, 70), (116, 480), (88, 480)], [4, 4, 6, 6]), "#e9eef2")
        a.blob(c_rpoly([(104, 72), (112, 72), (115, 479), (106, 479)], [0, 4, 5, 0]), "#c5d0d8")
    with a.part(7):                                     # the arrow wheel on top
        for k in range(4):
            an = math.radians(k * 45 + 10)
            a.sil(c_bar(102 - 42 * math.cos(an), 52 - 42 * math.sin(an), 102 + 42 * math.cos(an), 52 + 42 * math.sin(an), 11), YEL2)
    with a.part(7):
        a.sil(c_circ(102, 52, 15), RED)
    s2_carp(a, 116, 150, 360, 92, "#4f5a66", "#2f3640", "#aab4be")
    s2_carp(a, 116, 264, 316, 82, RED, RED_D, "#f7a8b3")
    s2_carp(a, 116, 366, 250, 68, BLUE, BLUE_D, "#bfe6fa")
    return a


@word
def ohinasama():
    """The pair of hina dolls on a red step, in front of a gold screen."""
    a = Art()
    GOLD, GOLD_D, SKIN = "#f9dc7a", "#e9bd3c", "#ffe7d1"
    with a.part():                                      # folding screen
        a.sil(c_rpoly([(50, 70), (462, 70), (462, 360), (50, 360)], [10, 10, 0, 0]), GOLD)
        for x in (152, 256, 360):
            c_line(a, x, 76, x, 356, 6, s=1, e=1, col=GOLD_D)
    with a.part():                                      # red step
        a.sil(c_rpoly([(20, 350), (492, 350), (492, 440), (20, 440)], [8, 8, 12, 12]), RED)
        a.blob(c_rect(21, 404, 470, 12, 0), GOLD_D)
        a.blob(c_rpoly([(21, 416), (491, 416), (491, 439), (21, 439)], [0, 0, 11, 11]), RED_D)

    def doll(cx, robe, robe_d, inner, lady):
        with a.part():                                  # robe: a wide rounded triangle
            a.sil(f"M{cx} 214 C{cx + 60} 214 {cx + 100} 300 {cx + 104} 346 Q{cx + 104} 356 {cx + 92} 356 L{cx - 92} 356 "
                  f"Q{cx - 104} 356 {cx - 104} 346 C{cx - 100} 300 {cx - 60} 214 {cx} 214 Z", robe)
            a.blob(f"M{cx + 50} 246 C{cx + 82} 280 {cx + 100} 320 {cx + 104} 346 Q{cx + 104} 356 {cx + 92} 356 L{cx + 40} 356 "
                   f"C{cx + 62} 330 {cx + 64} 286 {cx + 50} 246 Z", robe_d)
            a.blob(e2_poly([(cx - 26, 232), (cx + 26, 232), (cx, 280)]), inner)
            a.ink([(cx - 30, 230, cx - 18, 252, cx - 8, 268, cx, 282)], 6, a=1, b=0.4)
            a.ink([(cx + 30, 230, cx + 18, 252, cx + 8, 268, cx, 282)], 6, a=1, b=0.4)
        if lady:
            with a.part():                              # long black hair behind the head
                a.sil(f"M{cx - 60} 170 C{cx - 66} 110 {cx + 66} 110 {cx + 60} 170 L{cx + 66} 250 L{cx - 66} 250 Z", "#3b2f2a")
        with a.part():
            a.sil(c_circ(cx, 178, 54, 52), SKIN)
        if lady:
            a.blob(f"M{cx - 54} 172 C{cx - 52} 128 {cx + 52} 128 {cx + 54} 172 C{cx + 30} 146 {cx - 30} 146 {cx - 54} 172 Z", "#3b2f2a")
            with a.part(7):                             # crown
                a.sil(f"M{cx - 30} 132 L{cx - 34} 96 L{cx - 14} 114 L{cx} 88 L{cx + 14} 114 L{cx + 34} 96 L{cx + 30} 132 Z", GOLD)
            a.dot(cx, 112, 6, RED)
            with a.part(7):                             # fan
                a.sil(f"M{cx} 330 L{cx - 46} 286 C{cx - 20} 268 {cx + 20} 268 {cx + 46} 286 Z", GOLD)
        else:
            a.blob(f"M{cx - 52} 166 C{cx - 50} 132 {cx + 50} 132 {cx + 52} 166 C{cx + 30} 150 {cx - 30} 150 {cx - 52} 166 Z", "#3b2f2a")
            with a.part(7):                             # tall black cap
                a.sil(e2_rr(cx - 16, 84, 32, 54, 12), "#3b2f2a")
            with a.part(7):                             # flat sceptre
                a.sil(e2_rr(cx - 9, 268, 18, 66, 6), "#f2c078")
        a.eye(cx - 20, 184, 9)
        a.eye(cx + 20, 184, 9)
        a.cheek(cx - 34, 200, 10, 6)
        a.cheek(cx + 34, 200, 10, 6)
        a.path(f"M{cx - 7} 202 C{cx - 3} 208 {cx + 3} 208 {cx + 7} 202", sw=5)

    doll(152, "#7a6fd0", "#6258b8", WHITE, False)
    doll(360, "#f48a9a", "#e0707f", "#fff1a8", True)
    for x in (40, 472):                                 # peach blossoms
        e2_blossom(a, x, 330, 18, col="#ffd1dc")
    return a


@word
def hanabi():
    a = Art()
    cx, cy = 256, 256
    cols = (RED, YEL2, "#f48a9a", "#63b86a", BLUE, "#9b7fd1")
    with a.part(9):                                     # long rays
        for i in range(12):
            t = S2T(i * 30, cx, cy)
            L0, L1 = (70, 214) if i % 2 == 0 else (64, 160)
            a.sil(t.d(f"M{cx - 9} {cy - L0} C{cx - 16} {cy - L1 + 30} {cx - 18} {cy - L1 + 6} {cx} {cy - L1} "
                      f"C{cx + 18} {cy - L1 + 6} {cx + 16} {cy - L1 + 30} {cx + 9} {cy - L0} Z"), cols[i % 6])
    with a.part(7):                                     # sparks at the tips
        for i in range(12):
            an = math.radians(i * 30 + 15 - 90)
            r = 190
            a.sil(c_circ(cx + r * math.cos(an), cy + r * math.sin(an), 11), cols[(i + 3) % 6])
    with a.part(8):                                     # the bright middle
        a.sil(c_rpoly([(round(cx + r * math.cos(math.radians(-90 + i * 30)), 1), round(cy + r * math.sin(math.radians(-90 + i * 30)), 1))
                       for i, r in ((i, 52 if i % 2 == 0 else 30) for i in range(12))], 5), "#fff1a8")
    a.dot(cx, cy, 16, WHITE)
    return a


@word
def uchiwa():
    a = Art()
    with a.part():                                      # handle
        a.sil(e2_rr(238, 300, 36, 180, 14), "#e9c98a")
        a.blob(e2_rr(256, 304, 16, 172, 8), "#cfa962")
    face = "M256 36 C390 36 470 110 470 204 C470 290 396 346 256 346 C116 346 42 290 42 204 C42 110 122 36 256 36 Z"
    with a.part():
        a.sil(face, "#eaf6fd")
        a.blob("M44 232 C90 206 130 258 180 232 C230 206 270 258 320 232 C370 206 420 250 468 226 C458 300 388 345 256 345 "
               "C124 345 52 300 44 232 Z", "#8fd0ee")
        a.blob("M52 280 C96 260 136 300 186 280 C236 260 276 300 326 280 C372 262 420 290 452 274 C424 322 360 345 256 345 "
               "C152 345 82 322 52 280 Z", "#63b0d8")
        for x in (150, 256, 362):                       # ribs showing through the paper
            c_line(a, 256 + (x - 256) * 0.2, 340, x, 56 + abs(x - 256) * 0.2, 4, s=1, e=0.2, col="#cfe5f3")
    # a goldfish
    with a.part(7):
        a.sil("M246 150 C246 112 320 104 344 140 C356 124 386 118 392 132 C380 144 380 164 394 176 C384 190 356 182 344 166 "
              "C320 200 246 190 246 150 Z", RED)
    a.blob("M262 160 C280 176 316 176 336 160 C320 188 268 186 262 160 Z", "#f7a8b3")
    a.dot(272, 142, 7, WHITE)
    a.dot(273, 142, 4, EYE)
    for x, y, r in ((200, 110, 9), (176, 150, 6), (214, 172, 5)):      # bubbles
        with a.part(5):
            a.sil(c_circ(x, y, r), WHITE)
    a.shine("M84 150 C100 110 132 82 172 66", sw=8)
    return a


@word
def fuurin():
    a = Art()
    GL, GL_D = "#cfeefa", "#9fd3f2"
    with a.part(7):                                     # string and loop
        a.sil(e2_rr(251, 40, 10, 70, 4), "#8a6a4a")
        a.sil(c_circ(256, 34, 16) + " " + c_circ(256, 34, 7, ccw=True), RED)
    with a.part(7):                                     # the string down to the paper
        a.sil(e2_rr(252, 250, 8, 80, 3), "#8a6a4a")
    with a.part():                                      # paper strip, blowing a little
        a.sil("M226 322 L290 322 C292 370 300 420 312 470 L242 480 C240 430 232 372 226 322 Z", "#fdf6e6")
        a.blob("M226 322 L290 322 L292 350 L228 350 Z", "#f48a9a")
        for i, y in enumerate((380, 410, 440)):
            a.ink([(250 + i * 2, y, 262 + i * 2, y - 6, 276 + i * 2, y - 6, 288 + i * 2, y - 2)], 6, a=0.5, b=0.5, col="#8fd0ee")
    with a.part(7):                                     # clapper
        a.sil(c_circ(256, 262, 13), "#8a949a")
    dome = "M256 96 C340 96 386 150 386 214 C386 240 380 250 368 250 L144 250 C132 250 126 240 126 214 C126 150 172 96 256 96 Z"
    with a.part():                                      # glass dome
        a.sil(dome, GL)
        a.blob(d_rim(dome, 30, 70, 26), GL_D)
        a.blob("M127 222 L385 222 C384 240 380 249 368 249 L144 249 C132 249 128 240 127 222 Z", "#63b0d8")
    for x, y, c in ((196, 176, RED), (300, 150, RED), (262, 196, "#f48a9a")):      # painted dots (little fish)
        a.blob(f"M{x - 18} {y} C{x - 10} {y - 14} {x + 8} {y - 12} {x + 14} {y} L{x + 26} {y - 10} L{x + 26} {y + 10} L{x + 14} {y} "
               f"C{x + 8} {y + 12} {x - 10} {y + 14} {x - 18} {y} Z", c)
    a.shine("M156 196 C160 158 182 130 214 118", sw=9)
    e2_note(a, 420, 330, 0.8, "#63b0d8")
    return a


@word
def chouchin():
    a = Art()
    C, C_D, CAP = "#ee5d50", "#d0463c", "#3b2f2a"
    with a.part(7):                                     # handle
        a.sil("M206 96 C206 30 306 30 306 96 L290 96 C290 52 222 52 222 96 Z", "#8a6a4a")
    with a.part(7):                                     # tassel
        a.sil(e2_rr(250, 420, 12, 30, 4), YEL2)
        a.sil("M236 444 L276 444 L282 496 L230 496 Z", YEL2)
    c_line(a, 248, 454, 246, 492, 4, s=1, e=1, col="#e5a92d")
    c_line(a, 264, 454, 266, 492, 4, s=1, e=1, col="#e5a92d")
    body = "M256 96 C380 96 430 176 430 258 C430 340 380 420 256 420 C132 420 82 340 82 258 C82 176 132 96 256 96 Z"
    with a.part():
        a.sil(body, C)
        a.blob(d_rim(body, 20, 70, 40), C_D)
        for y, w in ((160, 150), (210, 170), (258, 174), (306, 170), (356, 150)):      # ribs
            a.ink([(256 - w, y, 256 - w * 0.5, y + 16, 256 + w * 0.5, y + 16, 256 + w, y)], 6, a=1, b=1, col="#b8362e")
        a.blob(c_circ(256, 258, 62), "#fff1a8")           # a bright round crest
        a.blob(e2_star(256, 258, 40, 18), RED)
    with a.part():                                      # caps
        a.sil(e2_rr(186, 80, 140, 36, 12), CAP)
        a.sil(e2_rr(196, 402, 120, 32, 12), CAP)
    a.shine("M118 220 C126 180 150 148 184 130", sw=9)
    return a


@word
def tanabata():
    """A bamboo branch with paper strips, a paper chain and a star."""
    a = Art()
    BAM, BAM_D = "#8fca6a", "#5f9e45"
    stem = [(210, 478, 220, 360, 244, 220, 300, 60)]
    br1 = [(232, 300, 190, 270, 150, 220, 96, 190)]
    br2 = [(258, 210, 310, 190, 370, 190, 428, 160)]
    br3 = [(222, 380, 280, 360, 340, 350, 400, 310)]
    from lib import at
    with a.part(8):                                     # leaves
        for bx, by, tx, ty in ((96, 190, 36, 150), (120, 200, 70, 250), (160, 232, 150, 160), (428, 160, 488, 120),
                               (400, 172, 440, 220), (340, 188, 350, 126), (300, 62, 340, 16), (296, 90, 240, 50),
                               (400, 310, 462, 290), (360, 332, 380, 380), (270, 150, 220, 110)):
            a.sil(d_leaf(bx, by, tx, ty, 34), BAM)
    with a.part(8):
        for c in (br1, br2, br3):
            a.sil(taper(c, 12, 8), BAM_D)
    with a.part():
        a.sil(taper(stem, 26, 14), BAM)
    for t in (0.25, 0.5, 0.75):
        (x0, y0), (x1, y1) = at(stem, t, 12), at(stem, t, -12)
        a.ink([e2_seg(x0, y0, x1, y1)], 6, a=1, b=1, col=BAM_D)

    def strip(x, y, col, L=96):
        a.path(f"M{x} {y} L{x} {y + 22}", sw=5)
        with a.part(7):
            a.sil(e2_rr(x - 17, y + 20, 34, L, 4), col)
        c_line(a, x, y + 36, x, y + L, 4, s=1, e=1, col="#ffffff")

    strip(110, 200, "#f48a9a")
    strip(180, 250, YEL2, 80)
    strip(330, 196, "#8fd0ee")
    strip(410, 176, "#f7a94b", 84)
    strip(300, 358, "#c5a3e8", 76)
    strip(380, 326, RED, 88)
    a.path("M258 104 L258 122", sw=5)
    with a.part(7):
        a.sil(e2_star(258, 152, 34, 15), YEL2)
    return a


@word
def teruterubouzu():
    a = Art()
    C, C_D = "#ffffff", "#d7ecf8"
    with a.part(7):                                     # string
        a.sil(e2_rr(251, 20, 10, 80, 4), "#8a6a4a")
    skirt = ("M196 250 C150 300 110 380 96 452 C120 470 150 440 176 462 C200 482 230 446 256 466 C282 446 312 482 336 462 "
             "C362 440 392 470 416 452 C402 380 362 300 316 250 Z")
    with a.part():
        a.sil(skirt, C)
        a.sil(c_circ(256, 172, 104, 100), C)
        a.blob(d_rim(c_circ(256, 172, 104, 100), 50, 60, 22), C_D)
        a.blob("M336 290 C372 340 402 400 416 452 C392 470 362 440 336 462 C330 466 324 468 318 468 C340 410 346 350 336 290 Z", C_D)
        for x0, x1 in ((214, 190), (256, 256), (298, 322)):
            a.ink([(x0, 290, x0 - (x0 - x1) * 0.3, 330, x1, 380, x1 - (x0 - x1) * 0.2, 430)], 6, a=0.6, b=0, col="#b9d8ea")
    with a.part(8):                                     # ribbon at the neck
        a.sil(e2_rr(190, 250, 132, 26, 12), BLUE)
        a.sil("M256 264 C230 244 200 250 204 274 C208 296 238 288 256 264 Z", BLUE)
        a.sil("M256 264 C282 244 312 250 308 274 C304 296 274 288 256 264 Z", BLUE)
    a.sil(c_circ(256, 266, 11), BLUE_D)
    a.eye(256 - 40, 170, 14)
    a.eye(256 + 40, 170, 14)
    a.cheek(256 - 66, 200, 15, 9)
    a.cheek(256 + 66, 200, 15, 9)
    a.path("M240 198 C246 210 266 210 272 198", sw=7)
    return a


# ------------------------------------------------- あき・ふゆの ぎょうじ --
def s2_plume(a, cubics, w=40, col="#f3e2b8", col_d="#d9c08a"):
    """One feathery ear of pampas grass along a curve (fat in the middle, pointed at the tip)."""
    from lib import bez_pts
    p = bez_pts(cubics, 24)
    L, R = [], []
    n = len(p) - 1
    for i, (x, y, nx, ny) in enumerate(p):
        t = i / n
        k = max(0.0, math.sin(math.pi * t ** 0.8)) ** 0.8
        h = max(1.5, w * k / 2)
        L.append((x + nx * h, y + ny * h)); R.append((x - nx * h, y - ny * h))
    d = "M" + " L".join(f"{u:.1f} {v:.1f}" for u, v in L + R[::-1]) + " Z"
    a.sil(d, col)
    return p


def s2_susuki(a, stalks, plume_w=40):
    ST = "#c9a35a"
    with a.part(8):
        for st, pl in stalks:
            a.sil(taper(st, 9, 7), ST)
    ps = []
    with a.part(9):
        for st, pl in stalks:
            ps.append(s2_plume(a, pl, plume_w))
    for p in ps:                                        # short barbs along each ear
        for i in range(4, len(p) - 4, 4):
            x, y, nx, ny = p[i]
            a.ink([e2_seg(x - nx * 3, y - ny * 3, x + nx * plume_w * 0.24, y + ny * plume_w * 0.24)], 4, a=1, b=0, col="#d9c08a")


@word
def susuki():
    a = Art()
    with a.part(8):                                     # long leaves
        for x0, tx, ty in ((226, 96, 300), (250, 150, 240), (270, 400, 276), (290, 440, 340), (240, 60, 380)):
            a.sil(d_blade(x0, 476, 24, tx, ty), S2_LEAF)
    stalks = [
        ([(238, 476, 232, 380, 214, 280, 176, 196)], [(176, 196, 150, 140, 108, 96, 52, 82)]),
        ([(256, 476, 256, 360, 262, 250, 276, 170)], [(276, 170, 288, 110, 320, 62, 372, 36)]),
        ([(272, 476, 282, 390, 310, 310, 350, 250)], [(350, 250, 384, 200, 430, 172, 480, 170)]),
        ([(248, 476, 240, 400, 226, 330, 206, 280)], [(206, 280, 182, 232, 138, 204, 86, 206)]),
    ]
    s2_susuki(a, stalks, 44)
    with a.part(8):                                     # a tuft at the foot
        a.sil("M176 484 C168 456 200 440 218 456 C232 436 280 436 294 456 C312 440 344 456 336 484 Z", S2_LEAF_D)
    return a


@word
def otsukimi():
    """Moon viewing: the full moon, white dumplings on a wooden stand, pampas grass."""
    a = Art()
    with a.part():                                      # moon
        a.sil(c_circ(330, 150, 124), "#fbe38a")
        a.blob(d_rim(c_circ(330, 150, 124), 40, 70, 26), "#f2cf5c")
    for x, y, r in ((290, 110, 20), (360, 190, 26), (372, 96, 12)):
        a.blob(c_circ(x, y, r), "#f2cf5c")
    stalks = [
        ([(70, 476, 66, 400, 60, 330, 70, 270)], [(70, 270, 76, 220, 100, 180, 140, 160)]),
        ([(52, 476, 44, 410, 36, 360, 30, 320)], [(30, 320, 22, 270, 30, 226, 56, 196)]),
    ]
    s2_susuki(a, stalks, 34)
    with a.part():                                      # the wooden stand
        a.sil(c_rpoly([(190, 404), (370, 404), (384, 478), (176, 478)], [4, 4, 8, 8]), "#f2c078")
        a.blob(c_circ(280, 444, 24), "#a8672f")
        a.sil(c_rect(140, 372, 280, 36, 8), "#f7d39a")
        a.blob(c_rect(141, 392, 278, 15, 6), "#e0b06a")
    with a.part():                                      # dumplings: 3 + 2 + 1
        for x, y in ((208, 344), (280, 344), (352, 344), (244, 292), (316, 292), (280, 240)):
            a.sil(c_circ(x, y, 38), WHITE)
        for x, y in ((208, 344), (280, 344), (352, 344), (244, 292), (316, 292), (280, 240)):
            a.blob(d_rim(c_circ(x, y, 38), 60, 60, 10), "#e3e9ee")
        for (x0, y0, x1, y1) in ((230, 322, 244, 330), (300, 322, 316, 330), (266, 270, 280, 278)):
            a.ink([(x0 - 22, y0 + 14, x0 - 8, y0 + 24, x1 + 2, y1 + 18, x1 + 14, y1 + 4)], 6, a=0, b=0, col="#b9c4cf")
    a.shine("M258 222 C262 212 270 206 280 204", sw=6)
    return a


@word
def kakashi():
    a = Art()
    STRAW, STRAW_D, KIM, KIM_D = "#f2d27a", "#d9b24f", "#5b7fc0", "#4668a8"
    with a.part():                                      # pole
        a.sil(c_rect(244, 300, 24, 180, 6), WOOD_D)
    with a.part():                                      # straw hands
        for s_ in (-1, 1):
            x = 256 + s_ * 212
            a.sil(f"M{256 + s_ * 170} 226 L{x + s_ * 26} 196 L{x + s_ * 18} 226 L{x + s_ * 30} 250 L{x + s_ * 14} 262 L{256 + s_ * 170} 270 Z", STRAW)
    with a.part():                                      # kimono on the cross pole
        a.sil("M70 208 Q70 196 82 196 L430 196 Q442 196 442 208 L442 286 Q442 298 430 298 L340 298 L346 400 Q346 412 334 412 "
              "L178 412 Q166 412 166 400 L172 298 L82 298 Q70 298 70 286 Z", KIM)
        a.blob("M300 300 L340 298 L346 400 Q346 411 334 411 L296 411 C304 376 304 336 300 300 Z", KIM_D)
        for x, y in ((120, 230), (170, 262), (392, 230), (342, 262), (212, 340), (290, 364), (236, 384)):   # splash pattern
            a.blob(e2_rr(x - 12, y - 4, 24, 8, 3), WHITE)
            a.blob(e2_rr(x - 4, y - 12, 8, 24, 3), WHITE)
        a.blob(e2_poly([(226, 198), (286, 198), (256, 252)]), CREAM)
        a.ink([(224, 198, 234, 220, 246, 240, 256, 254)], 6, a=1, b=0.5)
        a.ink([(288, 198, 278, 220, 266, 240, 256, 254)], 6, a=1, b=0.5)
    with a.part(8):                                     # rope belt
        a.sil(e2_rr(168, 320, 176, 22, 8), RED)
    with a.part():                                      # head: a round cloth bag
        a.sil(c_circ(256, 136, 76, 72), "#fdf0d8")
        a.blob(d_rim(c_circ(256, 136, 76, 72), 50, 60, 16), "#ecd8b2")
    a.eye(256 - 30, 136, 12)
    a.eye(256 + 30, 136, 12)
    a.cheek(256 - 48, 160, 12, 7)
    a.cheek(256 + 48, 160, 12, 7)
    a.path("M238 162 C246 174 266 174 274 162", sw=7)
    with a.part():                                      # straw hat
        a.sil("M256 14 C290 14 316 46 322 82 L376 96 Q392 102 380 112 C320 128 192 128 132 112 Q120 102 136 96 L190 82 "
              "C196 46 222 14 256 14 Z", STRAW)
        a.blob("M136 100 C200 112 312 112 376 100 Q390 104 380 112 C320 128 192 128 132 112 Q122 104 136 100 Z", STRAW_D)
        a.ink([(192, 82, 230, 90, 282, 90, 320, 82)], 6, a=1, b=1, col=STRAW_D)
    with a.part(8):                                     # grass at the foot
        a.sil("M196 484 C188 460 214 446 230 460 C244 450 268 450 282 460 C298 446 324 460 316 484 Z", S2_LEAF)
    return a


@word
def daruma():
    a = Art()
    C, C_D, FACE, GOLD = "#e5453c", "#c4332c", "#fff1e0", "#f7c948"
    body = "M256 40 C376 40 446 130 446 250 C446 380 372 472 256 472 C140 472 66 380 66 250 C66 130 136 40 256 40 Z"
    with a.part():
        a.sil(body, C)
        a.blob(d_rim(body, 40, 70, 46), C_D)
        a.blob("M256 96 C336 96 380 140 380 204 C380 262 330 296 256 296 C182 296 132 262 132 204 C132 140 176 96 256 96 Z", FACE)
        for s_ in (-1, 1):                              # gold swirls on the belly
            a.ink([(256 + s_ * 40, 440, 256 + s_ * 90, 420, 256 + s_ * 120, 380, 256 + s_ * 130, 330)], 12, a=0.2, b=0.2, col=GOLD)
            a.ink([(256 + s_ * 26, 404, 256 + s_ * 60, 392, 256 + s_ * 80, 368, 256 + s_ * 86, 340)], 10, a=0.2, b=0.2, col=GOLD)
        a.blob(e2_rr(246, 330, 20, 100, 8), GOLD)
    for s_ in (-1, 1):                                  # big friendly eyebrows
        a.ink([(256 + s_ * 28, 140, 256 + s_ * 50, 118, 256 + s_ * 84, 120, 256 + s_ * 104, 146)], 15, a=0.5, b=0.3)
    a.eye(256 - 56, 196, 22)
    a.eye(256 + 56, 196, 22)
    a.cheek(256 - 92, 244, 17, 10)
    a.cheek(256 + 92, 244, 17, 10)
    a.blob(c_circ(256, 232, 10, 8), "#e58a7a")
    a.path("M234 256 C244 270 268 270 278 256", sw=8)
    a.shine("M108 180 C122 130 156 92 200 74", sw=10)
    return a


@word
def kamakura():
    a = Art()
    dome = ("M256 70 C380 70 470 170 470 300 L470 410 Q470 430 450 430 L62 430 Q42 430 42 410 L42 300 "
            "C42 170 132 70 256 70 Z")
    with a.part():                                      # snow on the ground
        a.sil("M20 470 C8 430 60 410 100 420 C140 396 372 396 412 420 C452 410 504 430 492 470 Z", S2_SNOW)
        a.blob("M30 456 C120 470 392 470 482 456 L492 470 L20 470 Z", S2_SNOW_D)
    with a.part():
        a.sil(dome, S2_SNOW)
        a.blob(d_rim(dome, 30, 60, 40), S2_SNOW_D)
        for x0, y0, x1, y1 in ((110, 200, 150, 190), (330, 130, 380, 140), (90, 330, 130, 326), (392, 300, 430, 304), (196, 120, 240, 112)):
            a.ink([e2_seg(x0, y0, x1, y1)], 6, a=0.4, b=0.4, col="#c2dcec")
    with a.part():                                      # the warm doorway
        a.sil("M168 430 L168 320 C168 236 344 236 344 320 L344 430 Z", "#f7a94b")
        a.blob("M196 430 L196 326 C196 270 316 270 316 326 L316 430 Z", "#fbd58a")
    with a.part(8):                                     # a candle lantern inside
        a.sil(c_rect(236, 372, 40, 58, 8), "#fff7c8")
        a.sil(c_rect(228, 360, 56, 16, 6), "#a8672f")
    a.blob(c_circ(256, 404, 8, 12), "#f7a94b")
    a.shine("M90 250 C104 190 140 140 190 112", sw=9)
    return a


@word
def kadomatsu():
    a = Art()
    BAM, BAM_D, CUT, STRAW, STRAW_D = "#8fca6a", "#6fae4f", "#eef7d6", "#f2d27a", "#d9b24f"
    PINE, PINE_D = "#4f9a5c", "#3d7d49"
    with a.part():                                      # pine sprays behind
        for cx, cy, r in ((130, 250, 64), (382, 250, 64), (176, 196, 50), (336, 196, 50)):
            pts = []
            for i in range(14):
                rr = r if i % 2 == 0 else r * 0.62
                an = math.radians(i * 360 / 14)
                pts.append((cx + rr * math.cos(an), cy + rr * math.sin(an)))
            a.sil(c_rpoly([(round(x, 1), round(y, 1)) for x, y in pts], 4), PINE)
        for cx, cy, r in ((130, 250, 64), (382, 250, 64)):
            a.blob(c_circ(cx, cy, r * 0.36), PINE_D)

    def bamboo(x, top, w=62):
        with a.part():
            a.sil(f"M{x - w / 2} 330 L{x - w / 2} {top + 70} L{x + w / 2} {top} L{x + w / 2} 330 Z", BAM)
            a.blob(f"M{x + w * 0.16} {top + 24} L{x + w / 2} {top} L{x + w / 2} 330 L{x + w * 0.16} 330 Z", BAM_D)
            a.blob(f"M{x - w / 2 + 5} {top + 68} C{x - w * 0.2} {top + 30} {x + w * 0.2} {top + 6} {x + w / 2 - 5} {top + 4} "
                   f"C{x + w * 0.24} {top + 40} {x - w * 0.1} {top + 62} {x - w / 2 + 5} {top + 68} Z", CUT)
            for y in (top + 130, top + 210):
                if y < 320:
                    c_line(a, x - w / 2, y, x + w / 2, y, 6, s=1, e=1, col="#4f8f3a")

    bamboo(196, 96)
    bamboo(316, 130)
    bamboo(256, 36)
    with a.part():                                      # straw wrap
        a.sil(c_rpoly([(118, 316), (394, 316), (378, 476), (134, 476)], [10, 10, 14, 14]), STRAW)
        a.blob(c_rpoly([(340, 318), (393, 318), (377, 475), (330, 475)], [0, 9, 13, 0]), STRAW_D)
        for x in (170, 214, 256, 298):
            c_line(a, x, 322, x + (x - 256) * -0.06, 470, 5, s=1, e=1, col=STRAW_D)
    with a.part(8):                                     # rope bands
        for y in (346, 424):
            a.sil(e2_rr(114 + (y - 316) * 0.1, y, 284 - (y - 316) * 0.2, 22, 10), "#b88a48")
    with a.part(7):                                     # red plum blossom
        for i in range(5):
            an = math.radians(-90 + i * 72)
            a.sil(c_circ(256 + 20 * math.cos(an), 392 + 20 * math.sin(an), 15), RED)
    a.dot(256, 392, 9, YEL2)
    return a


@word
def chitoseame():
    """The long bag of thousand-year candy, with red and white candy sticks."""
    a = Art()
    with a.part(8):                                     # carrying string
        a.sil("M176 150 C176 4 336 4 336 150 L320 150 C320 28 192 28 192 150 Z", RED)
    with a.part(8):                                     # candy sticks
        for x, c in ((214, WHITE), (256, "#f48a9a"), (298, WHITE)):
            a.sil(e2_rr(x - 15, 56, 30, 150, 13), c)
    for x in (214, 298):
        for y in (72, 104):
            a.blob(e2_poly([(x - 14, y + 12), (x + 14, y), (x + 14, y + 12), (x - 14, y + 24)]), RED)
    bag = c_rpoly([(150, 150), (362, 150), (362, 480), (150, 480)], [6, 6, 12, 12])
    with a.part():
        a.sil(bag, "#fdf6e6")
        a.blob(c_rect(151, 150, 210, 60, 0), RED)
        a.blob(c_rpoly([(151, 436), (361, 436), (361, 479), (151, 479)], [0, 0, 11, 11]), RED)
        a.blob(c_circ(256, 268, 44), RED)                 # the rising sun
        a.blob("M196 420 C196 380 226 360 256 360 C286 360 316 380 316 420 Z", "#4f9a5c")   # a pine hill
        a.blob("M222 420 C222 396 240 384 256 384 C272 384 290 396 290 420 Z", "#3d7d49")
        for x in (182, 330):
            a.blob(e2_star(x, 180, 16, 7), YEL2)
        a.blob(e2_rr(236, 170, 40, 20, 6), YEL2)
    a.shine("M168 230 L168 400", sw=7)
    return a


@word
def yukidaruma():
    a = Art()
    with a.part():                                      # stick arms
        a.sil(c_bar(150, 320, 56, 250, 14), "#8a6a4a")
        a.sil(c_bar(84, 270, 60, 300, 10), "#8a6a4a")
        a.sil(c_bar(362, 320, 456, 250, 14), "#8a6a4a")
        a.sil(c_bar(428, 270, 452, 300, 10), "#8a6a4a")
    lower = c_circ(256, 356, 136, 122)
    upper = c_circ(256, 176, 104, 98)
    with a.part():
        a.sil(lower, S2_SNOW)
        a.blob(d_rim(lower, 50, 70, 34), S2_SNOW_D)
    for y in (330, 380):
        with a.part(6):
            a.sil(c_circ(256, y, 13), BLUE)
    with a.part():
        a.sil(upper, S2_SNOW)
        a.blob(d_rim(upper, 50, 70, 26), S2_SNOW_D)
    with a.part():                                      # scarf
        a.sil("M158 240 C200 272 312 272 354 240 L362 268 C316 304 196 304 150 268 Z", RED)
        a.sil("M300 280 L340 270 L356 352 L318 362 Z", RED)
        a.blob("M318 362 L356 352 L352 332 L314 342 Z", RED_D)
    with a.part():                                      # bucket hat
        a.sil("M176 96 L190 22 Q192 12 202 12 L310 12 Q320 12 322 22 L336 96 Z", BLUE)
        a.blob("M294 13 L310 13 Q320 13 322 22 L336 96 L300 96 Z", BLUE_D)
        a.sil(e2_rr(160, 88, 192, 26, 12), BLUE_D)
    a.eye(256 - 40, 164, 13)
    a.eye(256 + 40, 164, 13)
    a.cheek(256 - 66, 194, 15, 9)
    a.cheek(256 + 66, 194, 15, 9)
    with a.part(7):                                     # carrot nose
        a.sil("M240 186 C240 176 254 174 260 178 L296 194 C300 196 298 202 294 202 L254 204 C246 204 240 196 240 186 Z", "#f7a94b")
    a.path("M234 220 C246 232 268 232 278 222", sw=7)
    return a


@word
def kagamimochi():
    a = Art()
    WD, WD_D = "#f7d39a", "#e0b06a"
    with a.part():                                      # wooden stand
        a.sil(c_rpoly([(150, 400), (362, 400), (372, 478), (140, 478)], [4, 4, 8, 8]), WD)
        a.blob(c_circ(256, 440, 22), "#a8672f")
        a.sil(c_rect(96, 366, 320, 38, 8), WD)
        a.blob(c_rect(97, 388, 318, 15, 6), WD_D)
    with a.part(8):                                     # red-edged paper hanging over the stand
        a.sil("M130 366 L382 366 L412 420 L340 392 L256 420 L172 392 L100 420 Z", WHITE)
        a.blob("M100 420 L130 366 L144 366 L116 414 Z", RED)
        a.blob("M412 420 L382 366 L368 366 L396 414 Z", RED)
    with a.part(8):                                     # green fern leaves
        a.sil(d_leaf(170, 366, 60, 340, 44), "#63b86a")
        a.sil(d_leaf(342, 366, 452, 340, 44), "#63b86a")
    low = "M256 250 C360 250 420 286 420 326 C420 358 370 374 256 374 C142 374 92 358 92 326 C92 286 152 250 256 250 Z"
    up = "M256 160 C332 160 374 190 374 222 C374 250 336 266 256 266 C176 266 138 250 138 222 C138 190 180 160 256 160 Z"
    with a.part():
        a.sil(low, WHITE)
        a.blob(d_rim(low, 60, 70, 22), "#e3e9ee")
    with a.part():
        a.sil(up, WHITE)
        a.blob(d_rim(up, 60, 70, 18), "#e3e9ee")
    with a.part(8):                                     # leaf
        a.sil(d_leaf(262, 84, 322, 50, 30), "#63b86a")
    with a.part():                                      # the orange on top
        a.sil(c_circ(256, 128, 58, 52), "#f7a94b")
        a.blob(d_rim(c_circ(256, 128, 58, 52), 50, 70, 14), "#e58d32")
    a.dot(256, 84, 7, "#4f9a5c")
    a.shine("M214 116 C220 100 232 92 246 90", sw=7)
    return a
