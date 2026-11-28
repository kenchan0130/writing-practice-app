"""めぐり Life3 の絵（だいどころ・いえの もの・おふろ・ぶんぼうぐ・てんき・季節の ぎょうじ・からだ）。
描き方は Content/Art/style-guide.md（part()/sil()/ink()。物には顔をつけない。本体は1つの部品。D185・D188）。
からだの4つは、これまでの からだの絵（て・みみ など）と同じく 顔つきの絵。"""
import math
from lib import Art, mirror, taper, smooth, O, EYE, SW
from words import (word, RED, RED_D, YEL, YEL2, BLUE, BLUE_D, SKY, WOOD, WOOD_D, WOOD_L, PINK, GREEN, CREAM, WHITE,
                   GREY, HUB, NAVY, SKIN, SKIN_D, HAIR, CHEEK,
                   c_rpoly, c_rect, c_circ, c_bar, c_line,
                   e2_rr, e2_poly, e2_seg, e2_cap, e2_line, e2_star, e2_face, e2_smile, e2_blossom,
                   d_circ, d_tf, d_rim, d_leaf, d_vein, d_blade, d_curve, d_arc, e1_arc, e1_line, e1_d, e1_cloud)

L3_STEEL, L3_STEEL_D = "#dfe6ec", "#b9c4cf"
L3_ORANGE, L3_ORANGE_D = "#f7a94b", "#e58f2c"
L3_LEAF, L3_LEAF_D = "#7cc36a", "#5fa64f"
L3_ICE, L3_ICE_D = "#cfeaf9", "#9fd0ee"
L3_SNOW, L3_SNOW_D = "#ffffff", "#d7ecf8"
L3_GOLD, L3_GOLD_D = "#f7c948", "#e0a92a"


class L3T:
    """Turn shapes around a point (degrees, clockwise on screen): paths with d(), points with p(), lines with ink()."""

    def __init__(self, deg, cx=256, cy=256):
        self.deg, self.cx, self.cy = deg, cx, cy
        self.c, self.s = math.cos(math.radians(deg)), math.sin(math.radians(deg))

    def d(self, path):
        return d_tf(d_tf(path, dx=-self.cx, dy=-self.cy), deg=self.deg, dx=self.cx, dy=self.cy)

    def p(self, x, y):
        x, y = x - self.cx, y - self.cy
        return x * self.c - y * self.s + self.cx, x * self.s + y * self.c + self.cy

    def cub(self, c):
        out = []
        for i in range(0, 8, 2):
            out += list(self.p(c[i], c[i + 1]))
        return tuple(out)

    def ink(self, a, cubics, w=7, s=1, e=1, col=O):
        a.ink([self.cub(c) for c in cubics], w, a=s, b=e, col=col)

    def shine(self, a, x0, y0, x1, y1, sw=8):
        (u, v), (m, n) = self.p(x0, y0), self.p(x1, y1)
        a.shine(f"M{u:.1f} {v:.1f} L{m:.1f} {n:.1f}", sw=sw)


# ---------------------------------------------------------------- だいどころ --
@word
def manaita():
    a = Art()
    BD, BD_D, BD_E, SLOT = "#f6dcae", "#e3b97c", "#c9965a", "#9a6a3a"
    top = e2_rr(56, 120, 340, 252, 44)
    tab = e2_rr(340, 170, 128, 128, 56)
    with a.part():                                      # board with a round grip at the right
        a.sil(e2_rr(56, 150, 340, 252, 44), BD_E)
        a.sil(e2_rr(340, 200, 128, 128, 56), BD_E)
        a.sil(top, BD)
        a.sil(tab, BD)
        a.blob(d_rim(top, 55, 75, 26), BD_D)
    a.blob(c_circ(420, 234, 24), SLOT)                  # the hanging hole
    with a.part(8):                                     # a carrot lying on the board
        a.sil(taper([(92, 300, 140, 284, 200, 270, 286, 256)], 66, 18), L3_ORANGE)
        a.sil(d_leaf(104, 296, 40, 236, 54, 0.1), L3_LEAF)
        a.sil(d_leaf(108, 304, 38, 318, 50, -0.1), L3_LEAF)
    a.ink([(150, 290, 168, 292, 176, 296, 186, 300)], 7, a=1, b=0, col=L3_ORANGE_D)
    for x, y in ((330, 214), (342, 304)):               # two slices
        with a.part(7):
            a.sil(d_circ(x, y, 42, 30), L3_ORANGE)
        a.blob(d_circ(x, y, 27, 18), "#fbc27e")
        a.dot(x, y, 5, L3_ORANGE_D)
    a.shine("M92 176 C140 150 220 144 290 146", sw=9)
    return a


@word
def shamoji():
    a = Art()
    t = L3T(-34)
    PD, PD_D = "#f6dcae", "#e3b97c"
    blade = ("M240 340 C240 300 148 280 148 196 C148 112 192 56 256 56 C320 56 364 112 364 196 "
             "C364 280 272 300 272 340 Z")
    with a.part():
        a.sil(t.d(taper([(256, 310, 256, 372, 256, 428, 256, 466)], 32, 30)), PD)
        a.sil(t.d(blade), PD)
        a.blob(t.d("M326 82 C354 112 364 150 364 196 C364 280 272 300 272 340 L256 340 C300 290 326 240 332 180 "
                   "C334 140 332 108 326 82 Z"), PD_D)
    with a.part(8):                                     # a mound of rice on the blade
        a.sil(t.d("M150 214 C140 140 190 96 256 96 C322 96 372 140 362 214 C352 236 320 226 300 240 "
                  "C280 254 236 254 214 240 C194 226 160 236 150 214 Z"), WHITE)
        a.blob(t.d("M300 112 C340 128 364 164 362 214 C352 236 320 226 300 240 C330 200 334 150 300 112 Z"), "#dbeaf4")
    for x, y, d in ((196, 170, 20), (246, 134, -30), (300, 158, 40), (226, 206, -10), (286, 208, 25), (330, 190, -35)):
        px, py = t.p(x, y)
        a.ink([(px - 9, py - 3, px - 3, py - 1, px + 3, py + 1, px + 9, py + 3)], 7, a=0.6, b=0.6, col="#d3dbe0")
    t.shine(a, 176, 304, 188, 340, sw=7)
    return a


@word
def otama():
    a = Art()
    S, SD = L3_STEEL, L3_STEEL_D
    with a.part():                                      # handle, bending up to the right
        a.sil(taper([(228, 318, 290, 270, 352, 200, 404, 96)], 26, 22), S)
        a.sil(c_circ(408, 84, 32) + " " + c_circ(408, 84, 13, ccw=True), S)
    rim = d_circ(176, 296, 138, 44)
    bowl = ("M38 296 C38 400 100 462 176 462 C252 462 314 400 314 296 C314 336 252 340 176 340 "
            "C100 340 38 336 38 296 Z")
    with a.part():                                      # bowl and its rim
        a.sil(bowl, S)
        a.sil(rim, S)
    a.blob(d_circ(176, 300, 118, 32), "#e8a85a")        # the soup
    a.blob(d_circ(150, 296, 70, 16), "#f0bb72")
    a.blob(d_rim(bowl, 60, 60, 30), SD)
    a.ink([(40, 304, 52, 330, 98, 338, 176, 340)], 8, a=1, b=0.4)
    a.shine("M76 366 C84 396 108 420 140 432", sw=9)
    return a


@word
def zaru():
    a = Art()
    BM, BM_D, BM_L = "#ecc982", "#cf9f55", "#f6dca3"
    rim = d_circ(256, 190, 200, 58)
    body = ("M56 190 C58 300 130 416 256 416 C382 416 454 300 456 190 C456 240 370 250 256 250 C142 250 56 240 56 190 Z")
    with a.part(8):                                     # greens heaped up, behind the rim
        a.sil("M130 190 C110 130 160 90 214 110 C230 70 300 66 316 110 C368 92 410 138 380 190 Z", L3_LEAF)
    a.blob("M254 100 C256 130 250 160 256 190", L3_LEAF_D)
    with a.part():
        a.sil(body, BM)
        a.sil(rim, BM_D)
        a.blob(d_rim(body, 60, 70, 34), BM_D)
    a.blob(d_circ(256, 194, 176, 44), "#a8773a")        # the inside of the basket
    with a.part(8):
        a.sil("M130 190 C110 140 160 108 214 124 C230 90 300 86 316 124 C368 112 400 150 380 196 C340 224 170 224 130 190 Z",
              L3_LEAF)
    a.ink([(256, 130, 252, 156, 258, 180, 256, 204)], 7, a=0.8, b=0, col=L3_LEAF_D)
    a.ink([(196, 150, 210, 164, 214, 182, 210, 198)], 6, a=0.8, b=0, col=L3_LEAF_D)
    a.ink([(318, 148, 306, 164, 302, 182, 306, 198)], 6, a=0.8, b=0, col=L3_LEAF_D)
    for xr in (96, 150, 204, 258, 312, 366, 420):          # ribs: from the rim, curving in to the bottom
        k = 0.34
        xb = 256 + (xr - 256) * k
        a.ink([(xr, 258, xr + (xb - xr) * 0.1, 320, xb + (xr - xb) * 0.2, 380, xb, 410)], 8, a=0.2, b=0.2, col=BM_D)
    a.ink([(74, 292, 150, 318, 362, 318, 438, 292)], 8, a=0.3, b=0.3, col=BM_D)
    a.ink([(112, 348, 180, 368, 332, 368, 400, 348)], 8, a=0.3, b=0.3, col=BM_D)
    for x, y in ((220, 450), (300, 462)):                # drops of water
        a.blob(f"M{x} {y - 16} C{x - 8} {y} {x - 12} {y + 10} {x - 12} {y + 18} C{x - 12} {y + 26} {x - 6} {y + 30} {x} {y + 30} "
               f"C{x + 6} {y + 30} {x + 12} {y + 26} {x + 12} {y + 18} C{x + 12} {y + 10} {x + 8} {y} {x} {y - 16} Z", "#6fbde8")
    a.shine("M96 250 C108 300 134 340 168 366", sw=9)
    return a


@word
def reizouko():
    a = Art()
    F, FD, HAN, INN = "#e3f1fa", "#bcd8ea", "#8d9ba6", "#fff3c9"
    with a.part():                                      # feet
        a.sil(e2_rr(110, 452, 56, 30, 8), GREY)
        a.sil(e2_rr(310, 452, 56, 30, 8), GREY)
    body = e2_rr(90, 30, 290, 430, 36)
    with a.part():
        a.sil(body, F)
        a.blob(d_rim(body, 20, 55, 34), FD)
    e2_line(a, 90, 178, 380, 178, 9, 0.2, 0.2)          # the line between the two doors
    with a.part(7):                                     # handle of the top door
        a.sil(e2_rr(332, 92, 24, 62, 12), HAN)
    a.blob(e2_rr(106, 196, 258, 244, 12), INN)          # the lower door stands open: light, shelves and food
    for y in (290, 366):
        a.blob(e2_rr(106, y, 258, 12, 6), "#d9c98a")
    with a.part(6):
        a.sil(c_rpoly([(130, 246), (182, 246), (182, 290), (130, 290)], 6), WHITE)
    a.blob(e2_rr(130, 246, 52, 14, 4), BLUE)
    with a.part(6):
        a.sil(c_circ(250, 334, 28), RED)
    with a.part(6):
        a.sil(c_circ(316, 340, 22), L3_LEAF)
    with a.part():                                      # the open door, seen from the side
        a.sil("M366 190 L478 226 C484 228 488 234 488 242 L488 424 C488 432 484 438 478 440 L366 452 Z", FD)
        a.blob("M366 190 L392 198 L392 448 L366 452 Z", F)
    with a.part(7):
        a.sil(e2_rr(400, 270, 20, 100, 10), HAN)
    for x, y, col, k in ((130, 100, RED, 0), (184, 126, YEL2, 1)):   # magnets
        with a.part(6):
            a.sil(e2_star(x, y, 26, 12) if k == 0 else c_circ(x, y, 20), col)
    a.shine("M118 70 C116 100 116 130 118 150", sw=9)
    return a


@word
def yunomi():
    a = Art()
    C, CD, TEA, TEA_D, BAND = "#fffaf0", "#e6dfd0", "#a9d27a", "#8ab85a", "#5b8fd6"
    with a.part(7):                                     # steam
        a.sil(taper([(214, 150, 190, 120, 236, 96, 212, 50)], 22, 8), WHITE)
        a.sil(taper([(300, 150, 324, 116, 280, 90, 304, 44)], 22, 8), WHITE)
    body = ("M116 190 C116 190 124 440 184 452 C218 458 294 458 328 452 C388 440 396 190 396 190 Z")
    rim = d_circ(256, 190, 140, 40)
    with a.part():
        a.sil(body, C)
        a.sil(rim, C)
        a.blob(d_rim(body, 20, 70, 40), CD)
    a.blob(d_circ(256, 192, 122, 29), TEA)
    a.blob(d_circ(236, 190, 74, 12), "#c3e29a")
    a.blob(e1_d(e1_arc(256, 192, 122, 20, 160, 29), close=False) + " Z", TEA_D)
    a.blob("M122 300 C170 316 342 316 390 300 L388 342 C340 358 172 358 124 342 Z", BAND)   # an indigo band
    for i in range(5):
        a.dot(164 + i * 46, 329, 7, WHITE)
    a.shine("M138 240 C142 290 150 340 160 386", sw=9)
    return a


# ------------------------------------------------------------- いえの もの --
@word
def kasa():
    a = Art()
    BL, BLD, LT, SH = "#4fa8e0", "#3f8fc8", "#bfe6fa", "#8fcdea"
    DOME = ("M40 250 C40 130 140 70 256 70 C372 70 472 130 472 250 C450 222 386 222 364 250 "
            "C342 222 278 222 256 250 C234 222 170 222 148 250 C126 222 62 222 40 250 Z")
    WD = "#b9794a"
    with a.part():                                      # handle: a long shaft with a hook
        a.sil(taper([(256, 240, 256, 330, 256, 392, 256, 420)], 16, 16), WD)
        a.sil(taper([(256, 410, 256, 480, 172, 484, 172, 428)], 18, 18), WD)
    with a.part(8):                                     # the tip
        a.sil(e2_rr(246, 34, 20, 50, 8), GREY)
    with a.part():
        a.sil(DOME, LT)
        a.blob("M256 70 C140 70 40 130 40 250 C62 222 126 222 148 250 C148 150 189 70 256 70 Z", BL)
        a.blob("M256 70 L256 250 C278 222 342 222 364 250 C364 150 323 70 256 70 Z", BL)
        a.blob("M256 70 C372 70 472 130 472 250 C450 222 386 222 364 250 C364 170 330 100 256 70 Z", SH)
        a.blob("M256 70 C140 70 40 130 40 250 C62 222 126 222 148 250 C148 170 182 100 256 70 Z", BLD)
    a.ink([(256, 70, 189, 70, 148, 150, 148, 250)], 8, a=0, b=1)
    a.ink([(256, 70, 256, 120, 256, 190, 256, 250)], 8, a=0, b=1)
    a.ink([(256, 70, 323, 70, 364, 150, 364, 250)], 8, a=0, b=1)
    a.shine("M92 196 C100 160 130 130 170 112", sw=9)
    return a


@word
def houki():
    a = Art()
    t = L3T(17)
    ST, ST_D, BAND = "#ecc863", "#d4a640", "#e5534b"
    with a.part():                                      # handle
        a.sil(t.d(taper([(256, 20, 256, 120, 256, 220, 256, 320)], 24, 26)), WOOD)
    head = ("M210 292 L302 292 C322 340 372 396 380 464 L372 478 L340 466 L312 484 L284 468 L256 486 L228 468 "
            "L200 484 L172 466 L140 478 L132 464 C140 396 190 340 210 292 Z")
    with a.part():
        a.sil(t.d(head), ST)
        a.blob(t.d("M302 292 C322 340 372 396 380 464 L372 478 L340 466 C340 400 322 340 280 296 Z"), ST_D)
        for x in (172, 214, 256, 298, 340):
            t.ink(a, [(256 + (x - 256) * 0.3, 350, 256 + (x - 256) * 0.7, 400, x, 430, x, 462)], 7, 0.2, 0.9, ST_D)
    with a.part(7):                                     # the band
        a.sil(t.d(e2_rr(198, 296, 116, 40, 12)), BAND)
    a.blob(t.d(e2_rr(210, 304, 92, 10, 5)), "#f08a84")
    t.shine(a, 262, 60, 262, 200, sw=7)
    return a


@word
def kagi():
    a = Art()
    t = L3T(-36)
    G, GD = L3_GOLD, L3_GOLD_D
    with a.part():
        a.sil(t.d(c_circ(124, 256, 92) + " " + c_circ(124, 256, 38, ccw=True)), G)
        a.sil(t.d(e2_rr(190, 234, 270, 44, 16)), G)
        a.sil(t.d(e2_rr(190, 222, 34, 68, 10)), G)
        a.sil(t.d(e2_rr(366, 262, 38, 62, 10)), G)
        a.sil(t.d(e2_rr(420, 262, 36, 44, 10)), G)
        a.blob(t.d(e2_rr(200, 262, 256, 16, 8)), GD)
        a.blob(t.d(d_rim(c_circ(124, 256, 92), 70, 80, 22)), GD)
    t.shine(a, 244, 246, 340, 246, sw=8)
    a.shine(f"M{t.p(66, 232)[0]:.1f} {t.p(66, 232)[1]:.1f} L{t.p(86, 192)[0]:.1f} {t.p(86, 192)[1]:.1f}", sw=8)
    return a


@word
def makura():
    a = Art()
    P, PD, ST, TS = "#bfe3f7", "#98cbe8", "#fffaf0", "#fde49a"
    body = ("M56 150 C150 112 362 112 456 150 C482 220 482 306 456 376 C362 414 150 414 56 376 "
            "C30 306 30 220 56 150 Z")
    with a.part(8):                                     # a tassel tied to each corner
        for cx, cy, sx, sy in ((56, 150, -1, -1), (456, 150, 1, -1), (56, 376, -1, 1), (456, 376, 1, 1)):
            a.sil(e2_cap(cx, cy, cx + sx * 26, cy + sy * 26, 34, 44), TS)
    with a.part():
        a.sil(body, P)
        a.blob(d_rim(body, 60, 80, 34), PD)
    for x0, y0, x1, y1 in ((56, 150, 96, 176), (456, 150, 416, 176), (56, 376, 96, 350), (456, 376, 416, 350)):
        a.ink([e1_line(x0, y0, x1, y1)], 9, a=1, b=0, col=PD)       # the pinched corners
    a.blob(e2_star(156, 232, 34, 15), ST)
    a.blob(e2_star(268, 288, 40, 18), "#fde49a")
    a.blob(e2_star(366, 218, 28, 12), ST)
    a.blob(e2_star(204, 330, 22, 10), ST)
    a.shine("M92 200 C92 232 98 262 108 290", sw=9)
    return a


@word
def denwa():
    a = Art()
    BASE, BASE_D, HS, HS_D = RED, RED_D, "#34507e", "#273d63"
    with a.part():
        a.sil("M60 462 C60 410 96 356 148 340 L364 340 C416 356 452 410 452 462 C452 478 442 486 426 486 "
              "L86 486 C70 486 60 478 60 462 Z", BASE)
        a.blob(d_rim("M60 462 C60 410 96 356 148 340 L364 340 C416 356 452 410 452 462 C452 478 442 486 426 486 "
                     "L86 486 C70 486 60 478 60 462 Z", 40, 60, 30), BASE_D)
    with a.part(7):                                     # the cradle
        a.sil(e2_rr(128, 318, 40, 34, 10), GREY)
        a.sil(e2_rr(344, 318, 40, 34, 10), GREY)
    with a.part(8):                                     # the dial
        a.sil(c_circ(256, 424, 62), "#fff4e2")
    for i in range(7):
        t = math.radians(150 + i * 40)
        a.dot(256 + 42 * math.cos(t), 424 + 42 * math.sin(t), 8, "#cdbfa8")
    a.dot(256, 424, 18, BASE_D)
    cord = [(150, 340), (110, 350), (130, 310), (84, 300), (110, 260), (66, 250), (96, 214), (60, 198)]
    a.path(smooth(cord, closed=False), sw=14, stroke=O)            # the curly cord
    a.path(smooth(cord, closed=False), sw=7, stroke="#8a7a70")
    t = L3T(-10, 256, 150)
    with a.part():                                      # the receiver, lifted: a grip and two round ends
        a.sil(t.d(taper([(130, 170, 170, 100, 342, 100, 382, 170)], 54, 54, cap=False)), HS)
        a.sil(t.d(e2_rr(76, 150, 100, 110, 38)), HS)
        a.sil(t.d(e2_rr(336, 150, 100, 110, 38)), HS)
        a.blob(t.d("M150 118 C190 84 322 84 362 118 L366 138 C324 110 188 110 146 138 Z"), HS_D)
    for cx in (126, 386):                               # the speaker and the mouthpiece
        for k in range(3):
            x, y = t.p(cx, 184 + k * 22)
            a.dot(x, y, 6, "#8fa6c8")
    x0, y0 = t.p(190, 112)
    x1, y1 = t.p(320, 112)
    a.shine(f"M{x0:.1f} {y0:.1f} L{x1:.1f} {y1:.1f}", sw=8)
    return a


@word
def kanazuchi():
    a = Art()
    t = L3T(34)
    ST, STD, STL = "#c3cfd9", "#9aaab8", "#aebbc7"
    with a.part():                                      # handle
        a.sil(t.d(taper([(256, 170, 256, 260, 256, 360, 256, 446)], 40, 34)), WOOD)
        a.blob(t.d("M270 190 C276 270 276 360 268 440 L256 446 C262 360 262 270 256 190 Z"), WOOD_D)
    with a.part():                                      # a head with a flat face on both sides
        a.sil(t.d(e2_rr(138, 80, 236, 96, 8)), ST)
        a.sil(t.d(e2_rr(104, 68, 50, 120, 10)), ST)
        a.sil(t.d(e2_rr(358, 68, 50, 120, 10)), ST)
        a.blob(t.d(e2_rr(138, 144, 236, 32, 8)), STD)
        a.blob(t.d(e2_rr(104, 156, 50, 32, 10)), STD)
        a.blob(t.d(e2_rr(358, 156, 50, 32, 10)), STD)
        a.blob(t.d(e2_rr(366, 76, 14, 104, 6)), STL)
    t.shine(a, 170, 106, 330, 106, sw=9)
    return a


# --------------------------------------------------------- おふろ・みじたく --
@word
def ofuro():
    a = Art()
    TB, TB_D, WT, WT_D = "#fffaf0", "#dbe7ef", "#8fd0f2", "#6db9e6"
    with a.part(7):                                     # steam
        a.sil(taper([(120, 170, 94, 136, 140, 112, 114, 64)], 22, 8), WHITE)
        a.sil(taper([(206, 160, 232, 126, 188, 102, 214, 54)], 22, 8), WHITE)
    with a.part(8):                                     # the tap and a drop
        a.sil(taper([(404, 230, 404, 150, 394, 96, 336, 96)], 30, 26), L3_STEEL)
        a.sil(e2_rr(318, 84, 36, 50, 10), L3_STEEL_D)
    a.blob("M336 150 C330 164 324 172 324 182 C324 192 330 198 336 198 C342 198 348 192 348 182 C348 172 342 164 336 150 Z",
           "#5ab4ea")
    rim = d_circ(256, 256, 224, 58)
    body = ("M32 256 C32 330 42 380 60 410 C72 432 100 442 136 442 L376 442 C412 442 440 432 452 410 "
            "C470 380 480 330 480 256 Z")
    with a.part():
        a.sil(e2_rr(70, 436, 66, 30, 14), L3_GOLD)
        a.sil(e2_rr(376, 436, 66, 30, 14), L3_GOLD)
    with a.part():
        a.sil(body, TB)
        a.sil(rim, TB)
        a.blob(d_rim(body, 30, 70, 40), TB_D)
    a.blob(d_circ(256, 260, 192, 36), WT)               # water
    a.blob(d_circ(228, 256, 112, 13), "#b4e1f7")
    a.blob(e1_d(e1_arc(256, 260, 192, 20, 160, 36), close=False) + " Z", WT_D)
    for x, y, r in ((150, 262, 20), (194, 270, 12), (300, 258, 22), (352, 270, 13), (250, 274, 9)):   # bubbles
        with a.part(5):
            a.sil(c_circ(x, y, r), "#eaf7fd")
    a.shine("M62 320 C66 360 74 392 86 416", sw=9)
    return a


@word
def oke():
    a = Art()
    WD, WDD, BD = "#f2c98d", "#d9a45f", "#9a6a3a"
    body = "M94 196 L124 440 C128 466 188 478 256 478 C324 478 384 466 388 440 L418 196 Z"
    rim = d_circ(256, 196, 162, 46)
    with a.part():
        a.sil(body, WD)
        a.sil(rim, WD)
        a.blob(d_rim(body, 15, 60, 44), WDD)
    for x in (150, 205, 256, 307, 362):                 # staves
        a.ink([(256 + (x - 256) * 1.02, 240, 256 + (x - 256) * 0.96, 320, 256 + (x - 256) * 0.9, 400, 256 + (x - 256) * 0.86, 470)],
              7, a=0.2, b=0.3, col=WDD)
    a.blob("M102 266 C150 288 362 288 410 266 L406 310 C358 332 154 332 106 310 Z", BD)    # hoops
    a.blob("M118 396 C160 416 352 416 394 396 L392 436 C350 456 162 456 120 436 Z", BD)
    a.blob(d_circ(256, 200, 142, 32), "#7fc4ea")        # water
    a.blob(d_circ(234, 198, 84, 12), "#a9dcf5")
    a.blob(e1_d(e1_arc(256, 200, 142, 20, 160, 32), close=False) + " Z", "#5fb0de")
    with a.part(7):                                     # a ladle dipped in the bucket
        a.sil(taper([(318, 196, 360, 140, 420, 80, 484, 34)], 24, 20), WOOD)
        a.sil(d_circ(300, 200, 46, 22), WOOD_D)
    a.blob(d_circ(300, 198, 34, 14), "#7fc4ea")
    for x, y, r in ((200, 206, 10),):
        with a.part(5):
            a.sil(c_circ(x, y, r), "#eaf7fd")
    a.shine("M108 300 C112 350 118 392 126 430", sw=9)
    return a


@word
def megane():
    a = Art()
    FR, FR_D, LENS = "#f7a94b", "#e58f2c", "#d6effb"
    CX = (150, 362)
    for cx in CX:
        a.blob(c_circ(cx, 262, 78), LENS)
        a.path(f"M{cx - 44} {262 + 36} L{cx + 20} {262 - 50}", stroke=WHITE, sw=11, **{"stroke-opacity": "0.85"})
        a.path(f"M{cx - 10} {262 + 50} L{cx + 36} {262 - 4}", stroke=WHITE, sw=7, **{"stroke-opacity": "0.85"})
    with a.part():
        for cx in CX:
            a.sil(c_circ(cx, 262, 98) + " " + c_circ(cx, 262, 68, ccw=True), FR)
        a.sil(taper([(240, 236, 248, 214, 264, 214, 272, 236)], 22, 22, cap=False), FR)
        a.sil(taper([(66, 232, 50, 238, 36, 250, 24, 268)], 26, 22), FR)
        a.sil(taper([(446, 232, 462, 238, 476, 250, 488, 268)], 26, 22), FR)
        for cx in CX:
            a.blob(d_rim(c_circ(cx, 262, 98), 60, 80, 14), FR_D)
    for cx in CX:
        a.shine(f"M{cx - 86} 244 C{cx - 80} 214 {cx - 58} 192 {cx - 30} 182", sw=8)
    return a


@word
def tsumekiri():
    a = Art()
    lv = L3T(22, 400, 262)                             # the lever opens wide around its pin
    S, SD, GD = L3_STEEL, L3_STEEL_D, "#f7c948"
    NAIL = "#ffe3dc"
    with a.part():                                      # a fingertip with a nail, waiting to be cut
        a.sil(e2_cap(168, 500, 168, 392, 104, 96), SKIN)
        a.blob("M126 420 C126 390 210 390 210 420 L210 450 C210 462 126 462 126 450 Z", SKIN_D)
    with a.part(6):
        a.sil(e2_rr(128, 372, 80, 70, 34), NAIL)
    a.shine("M142 400 C142 388 150 380 162 378", sw=7)
    with a.part():                                      # lower body: a long bar with a rounded cutting tip
        a.sil("M84 288 C84 256 110 246 140 246 L430 246 C456 246 470 262 470 282 C470 304 456 318 430 318 "
              "L140 318 C110 318 84 322 84 288 Z", SD)
    a.blob("M92 296 C108 306 124 308 148 308 L430 308 C448 308 460 300 466 290 C462 308 448 318 430 318 L140 318 "
           "C108 318 90 314 84 288 Z", "#98a8b6")
    with a.part():                                      # the lever, raised at an angle, with a ring at the end
        a.sil(lv.d(c_rpoly([(70, 226), (400, 226), (476, 238), (476, 292), (400, 298), (70, 298)], [36, 6, 34, 34, 6, 36])), S)
        a.blob(lv.d(e2_rr(70, 270, 406, 28, 14)), "#c9d3dc")
    a.blob(lv.d(d_circ(440, 262, 28, 19)), "#8d9ba6")
    a.blob(lv.d(d_circ(440, 265, 22, 14)), "#fff4e2")
    px, py = lv.p(400, 262)
    with a.part(6):
        a.sil(c_circ(px, py, 20), GD)
    a.dot(px, py, 7, "#e0a92a")
    x0, y0 = lv.p(110, 244)
    x1, y1 = lv.p(320, 244)
    a.shine(f"M{x0:.1f} {y0:.1f} L{x1:.1f} {y1:.1f}", sw=9)
    with a.part(7):                                     # a clipped crescent of nail
        a.sil("M250 420 C276 392 328 396 350 428 C320 414 280 414 250 420 Z", WHITE)
    return a


@word
def tenugui():
    a = Art()
    CL, CL_D, DOT = "#3f73c1", "#2f5a9c", "#fffaf0"
    with a.part():                                      # the back half hangs a little shorter, to the right
        a.sil("M190 96 L440 96 L446 340 C400 358 350 332 306 350 C262 366 226 342 184 356 Z", CL_D)
    front = ("M70 96 L340 96 C350 190 350 300 344 430 C300 450 250 420 206 440 C160 458 112 428 64 448 "
             "C58 330 58 210 70 96 Z")
    with a.part():
        a.sil(front, CL)
        a.blob("M270 96 L340 96 C350 190 350 300 344 430 C300 450 250 420 206 440 C250 380 268 240 270 96 Z", CL_D)
    for x, y, r in ((106, 150, 17), (176, 134, 11), (246, 160, 16), (310, 140, 11), (128, 226, 10), (206, 232, 17),
                    (290, 252, 11), (100, 306, 16), (176, 322, 11), (250, 330, 17), (318, 346, 10),
                    (128, 392, 12), (206, 396, 16), (278, 408, 10)):
        a.dot(x, y, r, DOT)                             # mame-shibori: dots of several sizes
    for x in range(90, 340, 40):                        # loose threads at the cut edge
        a.ink([(x, 436, x - 2, 452, x + 2, 464, x, 474)], 6, a=0.2, b=0, col=CL)
    for x in (110, 420):                                # two small stands for the bar
        with a.part(7):
            a.sil(e2_rr(x - 16, 80, 32, 60, 10), WOOD_D)
    with a.part(8):                                     # the bar it hangs over
        a.sil(e2_rr(30, 56, 452, 40, 20), WOOD)
        a.blob(e2_rr(30, 82, 452, 14, 7), WOOD_D)
    a.shine("M70 72 L420 72", sw=7)
    return a


# ------------------------------------------------------------- ぶんぼうぐ --
@word
def hanko():
    a = Art()
    PAP, PAP_D, INK, INK_D = "#fffaf0", "#e6dfd0", "#e5534b", "#c9403a"
    with a.part():                                      # paper
        a.sil(e2_rr(70, 330, 392, 148, 14), PAP)
        a.blob(e2_rr(70, 452, 392, 26, 12), PAP_D)
    with a.part(7):                                     # the print: a ring and a star
        a.sil(c_circ(348, 404, 56) + " " + c_circ(348, 404, 38, ccw=True), INK)
    a.blob(e2_star(348, 404, 28, 13), INK)
    with a.part():                                      # the stamp
        a.sil(e2_rr(146, 64, 92, 214, 40), WOOD)
        a.blob("M214 100 C228 140 232 220 218 270 L238 270 L238 104 Z", WOOD_D)
        a.sil(e2_rr(122, 262, 140, 36, 12), WOOD_D)
        a.sil(e2_rr(130, 296, 124, 40, 12), INK)
    a.blob(e2_rr(138, 322, 108, 12, 6), INK_D)
    a.shine("M168 100 C166 150 166 200 170 246", sw=9)
    return a


@word
def fuutou():
    a = Art()
    t = L3T(-6)
    EV, EV_D, FL, FL_D = "#fffaf0", "#e6dfd0", "#f6e9c9", "#e0d0a6"
    with a.part(8):                                     # a letter peeking out behind
        a.sil(t.d(e2_rr(96, 64, 320, 130, 12)), "#ffffff")
    for k in range(2):
        a.blob(t.d(e2_rr(130, 92 + k * 30, 200 - k * 50, 10, 5)), "#cbbfae")
    body = e2_rr(54, 150, 404, 290, 24)
    with a.part():                                      # the back of the envelope
        a.sil(t.d(body), EV)
        a.blob(t.d(e2_rr(54, 400, 404, 40, 20)), EV_D)
    for xa, ya, xb, yb in ((60, 436, 236, 312), (452, 436, 276, 312)):
        a.ink([t.cub(e1_line(xa, ya, xb, yb))], 7, a=0.3, b=0.1, col=EV_D)
    with a.part(8):                                     # the triangle flap, closed
        a.sil(t.d(c_rpoly([(54, 160), (458, 160), (256, 346)], [24, 24, 34])), FL)
        a.blob(t.d("M256 346 L458 160 L458 190 L276 340 Z"), FL_D)
    px, py = t.p(256, 322)
    with a.part(6):                                     # a heart seal
        a.sil(d_tf("M0 24 C-40 -4 -30 -36 0 -18 C30 -36 40 -4 0 24 Z", 1.0, px, py), RED)
    a.shine(*([f"M{t.p(80, 178)[0]:.1f} {t.p(80, 178)[1]:.1f} L{t.p(170, 178)[0]:.1f} {t.p(170, 178)[1]:.1f}"]), sw=8)
    return a


# ------------------------------------------------------------------ てんき --
def l3_cube(a, x, y, w, h, dx, dy, front, top, side, ow=SW):
    """An ice cube seen from the upper right: the front, the top and the right side in one part."""
    with a.part(ow):
        a.sil(c_rpoly([(x, y), (x + w, y), (x + w, y + h), (x, y + h)], 24), front)
        a.sil(c_rpoly([(x + 4, y + 2), (x + dx + 4, y - dy), (x + w + dx, y - dy), (x + w, y + 2)], [10, 24, 18, 4]), top)
        a.sil(c_rpoly([(x + w - 2, y + 2), (x + w + dx, y - dy), (x + w + dx, y + h - dy - 24), (x + w - 2, y + h)], [4, 18, 24, 24]), side)


@word
def koori():
    a = Art()
    PUD, PUD_D = "#a9dcf5", "#7fc4ea"
    with a.part(9):                                     # a puddle of melted water
        a.sil(d_circ(256, 432, 224, 40), PUD)
    a.blob(d_circ(220, 428, 130, 14), "#cdeafa")
    l3_cube(a, 62, 190, 212, 218, 76, 62, L3_ICE, "#eaf7fd", L3_ICE_D)
    l3_cube(a, 286, 292, 124, 126, 46, 38, L3_ICE, "#eaf7fd", L3_ICE_D)
    a.path("M100 236 L128 226", stroke=WHITE, sw=11, **{"stroke-opacity": "0.9"})
    a.path("M100 262 L112 258", stroke=WHITE, sw=11, **{"stroke-opacity": "0.9"})
    a.path("M312 330 L332 324", stroke=WHITE, sw=9, **{"stroke-opacity": "0.9"})
    return a


@word
def shizuku():
    a = Art()
    LF, LF_D, DR, DR_D = L3_LEAF, L3_LEAF_D, "#5ab4ea", "#3f9ad6"
    with a.part():                                      # a leaf holding the drop
        a.sil(d_leaf(40, 410, 472, 396, 188, 0.05), LF)
        a.blob("M40 410 C130 440 360 446 472 396 C380 420 140 420 40 410 Z", LF_D)
    d_vein(a, 50, 410, 462, 398, LF_D, w=9, t0=0.04, t1=0.9)
    drop = ("M256 48 C240 130 144 200 144 300 C144 366 192 410 256 410 C320 410 368 366 368 300 C368 200 272 130 256 48 Z")
    with a.part():
        a.sil(drop, DR)
        a.blob(d_rim(drop, 60, 70, 36), DR_D)
    a.blob(c_circ(200, 262, 14), WHITE)
    a.shine("M232 150 C216 184 190 212 176 236", sw=9)
    return a


# ------------------------------------------------------------ 季節の ぎょうじ --
@word
def kabuto():
    a = Art()
    NV, NV_D, RD, RD_D = "#34507e", "#273d63", "#e5534b", "#c9403a"
    G, GD = L3_GOLD, L3_GOLD_D
    with a.part():                                      # stand
        a.sil(e2_rr(96, 440, 320, 46, 14), WOOD_D)
        a.sil(e2_rr(130, 420, 252, 34, 12), WOOD)
    with a.part(9):                                     # the crest: two curved horns
        a.sil(taper([(250, 190, 230, 120, 190, 70, 130, 48)], 30, 8), G)
        a.sil(taper([(262, 190, 282, 120, 322, 70, 382, 48)], 30, 8), G)
    with a.part():                                      # the neck guard flares out
        a.sil("M112 340 L400 340 L432 424 C410 438 386 426 360 438 C332 426 306 440 280 430 L232 430 "
              "C206 440 180 426 152 438 C126 426 102 438 80 424 Z", RD)
        a.blob("M360 340 L400 340 L432 424 C410 438 386 426 360 438 Z", RD_D)
    for y in (368, 394):
        a.ink([(100 - (y - 340) * 0.0, y, 190, y + 8, 322, y + 8, 412, y)], 7, a=0.3, b=0.3, col=G)
    with a.part():                                      # the bowl
        a.sil("M122 340 C122 230 184 150 256 150 C328 150 390 230 390 340 Z", NV)
        a.blob("M330 160 C372 196 390 260 390 340 L340 340 C340 260 326 196 296 156 Z", NV_D)
    with a.part(9):                                     # the brim and its gold trim
        a.sil(e2_rr(100, 310, 312, 40, 18), NV_D)
    a.blob(e2_rr(106, 322, 300, 12, 6), G)
    with a.part(8):                                     # the badge
        a.sil(c_circ(256, 244, 32), G)
    a.dot(256, 244, 14, RD)
    a.shine("M150 280 C152 240 174 200 210 178", sw=9)
    return a


@word
def omikoshi():
    a = Art()
    RD, RD_D, G, GD = "#d9453c", "#b3342f", L3_GOLD, L3_GOLD_D
    with a.part():                                      # carrying poles
        a.sil(e2_rr(18, 428, 476, 26, 12), WOOD_D)
        a.sil(e2_rr(18, 462, 476, 26, 12), WOOD_D)
    with a.part():                                      # base
        a.sil(e2_rr(104, 372, 304, 66, 10), RD)
        a.blob(e2_rr(104, 420, 304, 18, 8), RD_D)
    a.blob(e2_rr(104, 372, 304, 14, 6), G)
    with a.part():                                      # body with gold pillars
        a.sil(e2_rr(132, 236, 248, 144, 8), RD)
        a.blob("M350 244 L380 244 L380 380 L350 380 Z", RD_D)
        a.sil(e2_rr(130, 232, 28, 150, 8), G)
        a.sil(e2_rr(354, 232, 28, 150, 8), G)
        a.sil(e2_rr(130, 232, 252, 24, 8), G)
    a.blob(e2_rr(188, 284, 136, 82, 6), RD_D)           # the door
    e2_line(a, 256, 284, 256, 366, 7, 1, 1, col=G)
    a.dot(238, 326, 7, G)
    a.dot(274, 326, 7, G)
    with a.part():                                      # the roof: a gold shape with upturned corners
        a.sil("M58 246 C124 242 186 180 256 160 C326 180 388 242 454 246 C448 262 420 262 398 254 "
              "L114 254 C92 262 64 262 58 246 Z", G)
        a.blob("M256 160 C326 180 388 242 454 246 C448 262 420 262 398 254 L330 254 C340 210 306 176 256 160 Z", GD)
    for x in (146, 196, 256, 316, 366):                 # ridges of the roof
        a.ink([(256 + (x - 256) * 0.1, 172, 256 + (x - 256) * 0.45, 190, x, 222, x + (x - 256) * 0.06, 252)], 7, a=0, b=0.8, col=GD)
    with a.part(8):                                     # the top ornament
        a.sil(c_circ(256, 100, 24), G)
        a.sil(e2_rr(246, 112, 20, 56, 8), G)
    for x in (66, 446):                                 # bells at the corners
        with a.part(6):
            a.sil(c_circ(x, 276, 14), G)
    a.shine("M120 222 C150 214 180 200 206 184", sw=7)
    return a


def l3_pod(a, cx, cy, s, rot=0.0):
    """A Chinese lantern plant pod: a pointed lantern with ridges."""
    P = "M0 -110 C70 -110 98 -40 92 30 C86 90 42 126 0 150 C-42 126 -86 90 -92 30 C-98 -40 -70 -110 0 -110 Z"
    OR, ORD = "#f7893a", "#e0662a"
    with a.part():
        a.sil(d_tf(P, s, cx, cy, rot), OR)
        a.blob(d_tf("M60 -80 C98 -30 96 20 88 50 C80 100 42 130 0 150 C40 100 58 40 60 -80 Z", s, cx, cy, rot), ORD)
    for k in (-0.5, 0.5):
        pts = [(k * 150, -96), (k * 190, -20), (k * 170, 70), (k * 40, 140)]
        c = (pts[0][0], pts[0][1], pts[1][0], pts[1][1], pts[2][0], pts[2][1], pts[3][0], pts[3][1])
        cc = d_tf(f"M{c[0]} {c[1]} L{c[2]} {c[3]} L{c[4]} {c[5]} L{c[6]} {c[7]}", s, cx, cy, rot)
        nums = [float(v) for v in cc.replace("M", "").replace("L", " ").split()]
        a.ink([tuple(nums)], 7, a=0.2, b=0, col=ORD)
    a.ink([(cx, cy - 106 * s, cx, cy - 40 * s, cx, cy + 40 * s, cx, cy + 140 * s)], 7, a=0.2, b=0, col=ORD)


@word
def hoozuki():
    a = Art()
    ST, LF, LFD = "#8aa04a", L3_LEAF, L3_LEAF_D
    with a.part(8):                                     # stem and two stalks (the top is where it hangs from)
        a.sil(taper([(256, 18, 256, 60, 262, 96, 262, 140)], 16, 14), ST)
        a.sil(taper([(262, 130, 240, 170, 214, 190, 196, 214)], 14, 12), ST)
        a.sil(taper([(262, 130, 296, 160, 326, 176, 340, 200)], 14, 12), ST)
    with a.part():
        a.sil(d_leaf(262, 60, 410, 36, 74, 0.1), LF)
    d_vein(a, 266, 58, 400, 38, LFD, w=7, t0=0.06, t1=0.8)
    l3_pod(a, 196, 330, 1.0)
    l3_pod(a, 340, 310, 0.9, rot=4)
    with a.part(6):                                     # the cap on each pod
        a.sil(e2_rr(176, 208, 40, 22, 10), LF)
        a.sil(e2_rr(322, 194, 36, 20, 9), LF)
    return a


@word
def oninomen():
    a = Art()
    FACE, FACE_D, CHK = "#e5534b", "#c9403a", "#f08a84"
    HR, HORN, HORN_D = "#4a3a34", "#fff0c8", "#e9cf8a"
    with a.part(8):                                     # the ring it hangs from
        a.sil(c_circ(256, 38, 28) + " " + c_circ(256, 38, 12, ccw=True), L3_GOLD)
    with a.part(9):                                     # horns
        a.sil("M150 132 C148 92 166 58 184 40 C194 76 216 98 224 134 Z", HORN)
        a.sil("M362 132 C364 92 346 58 328 40 C318 76 296 98 288 134 Z", HORN)
    head = d_circ(256, 282, 186, 196)
    with a.part():
        a.sil(head, FACE)
        a.blob(d_rim(head, 40, 70, 34), FACE_D)
    a.blob("M84 250 C96 140 172 98 256 98 C340 98 416 140 428 250 C402 204 366 186 336 198 C306 160 206 160 176 198 "
           "C146 186 110 204 84 250 Z", HR)               # curly hair
    a.sil(taper([(132, 240, 160, 214, 196, 212, 222, 226)], 22, 14), HR)
    a.sil(taper([(380, 240, 352, 214, 316, 212, 290, 226)], 22, 14), HR)
    for cx in (176, 336):                               # eyes
        a.ellipse(cx, 276, 38, 34, WHITE, sw=8)
        a.eye(cx + (6 if cx < 256 else -6), 278, 17)
    with a.part(7):                                     # nose
        a.sil(c_circ(256, 330, 26), FACE_D)
    a.ellipse(116, 352, 30, 20, CHK, sw=0, stroke="none", **{"fill-opacity": "0.8"})
    a.ellipse(396, 352, 30, 20, CHK, sw=0, stroke="none", **{"fill-opacity": "0.8"})
    with a.part(8):                                     # the big smile with two small tusks
        a.sil("M150 378 C190 448 322 448 362 378 C324 398 188 398 150 378 Z", "#7d2c3c")
    a.blob("M196 408 L210 384 L224 412 Z", WHITE)
    a.blob("M316 408 L302 384 L288 412 Z", WHITE)
    a.shine("M110 220 C120 190 142 168 170 156", sw=8)
    return a


@word
def yukiusagi():
    a = Art()
    S, SD, BERRY = L3_SNOW, L3_SNOW_D, "#d9453c"
    with a.part(9):                                     # ears: two green leaves
        a.sil(d_leaf(204, 230, 150, 50, 80, 0.1), L3_LEAF)
        a.sil(d_leaf(308, 230, 362, 50, 80, -0.1), L3_LEAF)
    d_vein(a, 200, 220, 154, 62, L3_LEAF_D, w=7, t0=0.1, t1=0.85)
    d_vein(a, 312, 220, 358, 62, L3_LEAF_D, w=7, t0=0.1, t1=0.85)
    body = ("M92 392 C92 290 160 214 256 214 C352 214 420 290 420 392 C420 450 350 472 256 472 C162 472 92 450 92 392 Z")
    with a.part():
        a.sil(body, S)
        a.blob(d_rim(body, 60, 80, 36), SD)
    for cx in (196, 316):                               # berry eyes
        a.dot(cx, 340, 24, BERRY)
        a.dot(cx + 8, 330, 8, WHITE)
    a.ink([(150, 440, 190, 452, 250, 456, 300, 452)], 8, a=0, b=0, col="#b5d8ee")
    a.blob(e2_star(402, 160, 26, 9), "#9fd0ee")
    a.blob(e2_star(110, 190, 18, 6), "#9fd0ee")
    return a


@word
def tsurara():
    a = Art()
    IC, ICD, ICL = L3_ICE, L3_ICE_D, "#eaf7fd"
    with a.part(8):                                     # the ring and cord it hangs from
        a.sil(c_circ(256, 38, 26) + " " + c_circ(256, 38, 11, ccw=True), L3_STEEL_D)
    with a.part(6):
        a.sil(taper([(256, 56, 220, 72, 160, 92, 106, 112)], 10, 8, cap=False), WOOD_D)
        a.sil(taper([(256, 56, 292, 72, 352, 92, 406, 112)], 10, 8, cap=False), WOOD_D)
    with a.part():                                      # a stick with snow on it
        a.sil(e2_rr(70, 104, 372, 40, 18), WOOD)
        a.blob(e2_rr(70, 128, 372, 16, 8), WOOD_D)
    with a.part(8):
        a.sil("M84 112 C96 70 140 74 166 90 C190 62 250 62 276 88 C300 66 360 70 380 94 C410 80 440 96 436 112 Z", WHITE)
    a.blob("M300 90 C320 76 360 74 380 94 C410 82 440 96 436 112 L370 112 C360 96 330 90 300 90 Z", L3_SNOW_D)

    def icicle(x, y0, w, length):
        h = w / 2
        return (f"M{x - h} {y0} C{x - h} {y0 + length * 0.4} {x - h * 0.4} {y0 + length * 0.8} {x} {y0 + length} "
                f"C{x + h * 0.4} {y0 + length * 0.8} {x + h} {y0 + length * 0.4} {x + h} {y0} Z")
    with a.part():
        for x, w, ln in ((112, 52, 150), (178, 58, 250), (256, 64, 332), (334, 58, 224), (400, 52, 130)):
            a.sil(icicle(x, 136, w, ln), IC)
    for x, w, ln in ((112, 52, 150), (178, 58, 250), (256, 64, 332), (334, 58, 224), (400, 52, 130)):
        h = w / 2
        a.blob(f"M{x + h * 0.2} 142 C{x + h} {136 + ln * 0.3} {x + h * 0.6} {136 + ln * 0.7} {x} {136 + ln - 6} "
               f"C{x + h * 0.4} {136 + ln * 0.8} {x + h} {136 + ln * 0.4} {x + h} 142 Z", ICD)
        a.ink([(x - h * 0.45, 156, x - h * 0.5, 156 + ln * 0.22, x - h * 0.35, 156 + ln * 0.4, x - h * 0.2, 156 + ln * 0.52)],
              8, a=0.3, b=0, col=WHITE)
    a.blob("M178 436 C174 450 168 458 168 466 C168 474 174 480 180 480 C186 480 192 474 192 466 C192 458 186 450 182 436 Z"
           .replace("M178 436", "M180 424").replace("182 436", "180 424"), "#5ab4ea")
    return a


# ------------------------------------------------------------------ からだ --
@word
def hiza():
    a = Art()
    SOCK, SOCK_D, SHOE, SHOE_D = "#fffaf0", "#e6dfd0", RED, RED_D
    with a.part():                                      # the bent leg: thigh, shin and a round knee
        a.sil(e2_cap(150, 202, 352, 202, 150, 134), SKIN)
        a.sil(taper([(352, 216, 354, 290, 346, 350, 338, 404)], 134, 92, cap=False), SKIN)
        a.sil_ellipse(352, 222, 88, 82, SKIN)
        a.blob("M280 292 C320 312 392 312 436 280 C420 316 384 332 336 326 C312 322 292 308 280 292 Z", SKIN_D)
    with a.part():                                      # shoe and sock
        a.sil(e2_rr(282, 436, 196, 62, 30), SHOE)
        a.blob(e2_rr(282, 474, 196, 24, 12), "#fffaf0")
        a.blob("M282 452 C282 442 294 436 310 436 L344 436 L344 474 L282 474 Z", SHOE_D)
    with a.part():
        a.sil(e2_rr(288, 364, 112, 86, 22), SOCK)
        a.blob(e2_rr(288, 424, 112, 26, 12), SOCK_D)
    a.blob(e2_rr(288, 386, 112, 12, 6), BLUE)
    with a.part():                                      # shorts
        a.sil("M54 118 L218 118 C246 150 244 252 220 286 L54 286 Z", BLUE)
        a.blob("M200 118 L218 118 C246 150 244 252 220 286 L202 286 C222 252 224 150 200 118 Z", BLUE_D)
    with a.part(7):                                     # one bandage on the knee
        a.sil(d_tf(e2_rr(-70, -26, 140, 52, 22), 1, 352, 222, -30), "#f1cf9a")
    a.blob(d_tf(e2_rr(-24, -26, 48, 52, 0), 1, 352, 222, -30), "#e0b878")
    for k in (-1, 1):
        for j in (-1, 0, 1):
            x, y = d_tf("M%d %d" % (k * 46, j * 14), 1, 352, 222, -30)[1:].split()
            a.dot(float(x), float(y), 3.5, "#c79a5a")
    a.shine("M290 196 C292 172 312 154 340 148", sw=8)
    return a


@word
def yubi():
    a = Art()
    t = L3T(10, 256, 420)                               # the hand leans a little
    with a.part():                                      # a sleeve
        a.sil(t.d(e2_rr(140, 430, 232, 70, 22)), YEL)
        a.blob(t.d(e2_rr(140, 472, 232, 28, 14)), "#e9bd3c")
    with a.part():                                      # a fist with one chubby finger raised, the thumb tucked in front
        a.sil(t.d(e2_cap(250, 340, 250, 210, 84, 76)), SKIN)
        a.sil_ellipse(*t.p(256, 392), 140, 100, SKIN)
        for cx, cy, rx, ry in ((340, 336, 46, 40), (382, 372, 42, 38)):
            a.sil_ellipse(*t.p(cx, cy), rx, ry, SKIN)
        a.sil(t.d(e2_cap(136, 396, 190, 330, 64, 56)), SKIN)
        a.blob(t.d("M122 440 C172 480 320 482 392 440 C350 470 250 478 190 470 C160 466 136 456 122 440 Z"), SKIN_D)
    t.ink(a, [(150, 372, 176, 346, 206, 340, 232, 350)], 8, 0.3, 0.3, SKIN_D)      # the thumb
    t.ink(a, [(318, 304, 332, 312, 352, 312, 366, 304)], 8, 0.3, 0.3, SKIN_D)
    t.ink(a, [(362, 340, 376, 348, 394, 348, 406, 340)], 8, 0.3, 0.3, SKIN_D)
    e2_face(a, *t.p(262, 410), 46, 15, cheek_dx=76, cheek_dy=34, w=14)
    x0, y0 = t.p(230, 290)
    x1, y1 = t.p(230, 244)
    a.shine(f"M{x0:.1f} {y0:.1f} L{x1:.1f} {y1:.1f}", sw=9)
    for ang in (-60, -20, 20, 60):                      # an "I've got it!" burst over the fingertip
        c, s = math.cos(math.radians(ang - 90)), math.sin(math.radians(ang - 90))
        cx, cy = t.p(250, 190)
        a.ink([e1_line(cx + c * 66, cy + s * 66, cx + c * 106, cy + s * 106)], 10, a=1, b=0.3, col="#f7a94b")
    return a


@word
def obon():
    a = Art()
    TR, TR_D, TR_E = "#d9453c", "#b3342f", "#8c2a26"
    outer = d_circ(256, 320, 232, 116)
    with a.part():                                      # a round lacquer tray
        a.sil(d_circ(256, 352, 232, 116), TR_E)
        a.sil(outer, TR_D)
    a.blob(d_circ(256, 324, 202, 94), TR)
    a.blob(d_rim(d_circ(256, 324, 202, 94), 60, 70, 20), TR_D)
    with a.part(8):                                     # a bowl of rice and a cup of tea
        a.sil("M120 250 C120 330 160 366 214 366 C268 366 308 330 308 250 Z", WHITE)
        a.sil(d_circ(214, 250, 94, 28), WHITE)
    a.blob(d_circ(214, 244, 76, 20), "#fffdf6")
    a.blob("M150 234 C160 196 268 196 280 234 C260 222 172 222 150 234 Z", WHITE)
    a.blob("M130 296 C170 312 262 312 300 296 L296 316 C262 332 168 332 134 316 Z", "#7fbf6a")
    with a.part(8):
        a.sil("M330 270 L330 330 C330 358 346 366 372 366 C398 366 414 358 414 330 L414 270 Z", "#fffaf0")
        a.sil(d_circ(372, 270, 42, 14), "#fffaf0")
    a.blob(d_circ(372, 270, 34, 10), "#a9d27a")
    a.shine("M120 330 C122 346 130 358 146 366", sw=8)
    return a


@word
def senpuuki():
    a = Art()
    GD, BLD, BS, BS_D = L3_STEEL, "#8fcdea", L3_ORANGE, L3_ORANGE_D
    with a.part():                                      # stand and base
        a.sil(e2_rr(236, 330, 40, 120, 12), GD)
        a.sil(e2_rr(130, 430, 252, 52, 26), BS)
        a.blob(e2_rr(130, 462, 252, 20, 10), BS_D)
    cx, cy = 256, 190
    with a.part(8):                                     # three blades inside the guard
        for k in range(3):
            ang = math.radians(-90 + k * 120)
            a.sil(d_leaf(cx, cy, cx + 128 * math.cos(ang), cy + 128 * math.sin(ang), 84, 0.2), BLD)
    with a.part():                                      # the guard: an outer and an inner ring
        a.sil(c_circ(cx, cy, 164) + " " + c_circ(cx, cy, 148, ccw=True), GD)
        a.sil(c_circ(cx, cy, 92) + " " + c_circ(cx, cy, 78, ccw=True), GD)
    for k in range(8):                                  # spokes
        ang = math.radians(k * 45 + 22)
        a.ink([e1_line(cx + 40 * math.cos(ang), cy + 40 * math.sin(ang), cx + 152 * math.cos(ang), cy + 152 * math.sin(ang))],
              8, a=1, b=1, col="#b9c4cf")
    with a.part(7):
        a.sil(c_circ(cx, cy, 34), BS)
    a.dot(cx, cy, 12, BS_D)
    a.shine("M120 150 C130 110 160 82 200 70", sw=9)
    return a


@word
def bansoukou():
    a = Art()
    t = L3T(-18)
    BD, BD_D, PAD = "#f1cf9a", "#dcb578", "#fff4e2"
    with a.part():
        a.sil(t.d(e2_rr(30, 176, 452, 152, 70)), BD)
        a.blob(t.d(e2_rr(30, 296, 452, 32, 16)), BD_D)
    with a.part(6):                                     # the pad in the middle
        a.sil(t.d(e2_rr(176, 192, 160, 120, 10)), PAD)
    a.blob(t.d(e2_rr(186, 202, 140, 100, 6)), "#f4e3c4")
    for x in range(84, 176, 30):                        # tiny holes
        for y in (218, 252, 286):
            px, py = t.p(x, y)
            a.dot(px, py, 5, BD_D)
    for x in range(366, 460, 30):
        for y in (218, 252, 286):
            px, py = t.p(x, y)
            a.dot(px, py, 5, BD_D)
    px, py = t.p(256, 252)
    a.blob(d_tf("M0 20 C-34 -4 -26 -32 0 -16 C26 -32 34 -4 0 20 Z", 0.8, px, py), "#f08a84")
    t.shine(a, 70, 206, 150, 206, sw=8)
    return a


@word
def zoukin():
    a = Art()
    CL, CL_D, TH = "#e6dfcf", "#c9c0aa", "#b3a68a"
    cloth = ("M70 150 C130 124 200 160 262 140 C324 120 390 156 442 134 L452 372 C390 394 326 364 262 386 "
             "C198 408 134 372 62 396 Z")
    with a.part():
        a.sil(cloth, CL)
        a.blob("M360 130 L442 134 L452 372 C390 394 326 364 262 386 C330 330 356 230 360 130 Z", CL_D)
    a.blob("M70 150 C130 124 200 160 262 140 C324 120 390 156 442 134 L440 164 C390 186 324 152 262 172 "
           "C200 192 132 156 72 182 Z", "#f1ecdf")
    a.ink([(86, 212, 200, 236, 330, 200, 428, 224)], 6, a=0.1, b=0.1, col=TH)       # double stitching
    a.ink([(86, 336, 200, 360, 330, 324, 428, 348)], 6, a=0.1, b=0.1, col=TH)
    for k in range(8):
        x = 96 + k * 44
        a.ink([e1_line(x, 224 + (k % 3), x + 16, 222 + (k % 3))], 6, a=1, b=1, col=CL)
    with a.part(7):                                     # a fold lifted at the corner
        a.sil("M368 392 L452 372 L420 460 C400 440 380 420 368 392 Z", CL_D)
    for x, y in ((118, 440), (170, 466)):               # drops
        a.blob(f"M{x} {y - 16} C{x - 9} {y} {x - 12} {y + 8} {x - 12} {y + 14} C{x - 12} {y + 22} {x - 6} {y + 26} {x} {y + 26} "
               f"C{x + 6} {y + 26} {x + 12} {y + 22} {x + 12} {y + 14} C{x + 12} {y + 8} {x + 9} {y} {x} {y - 16} Z", "#6fbde8")
    a.shine("M92 176 C96 220 98 262 100 300", sw=8)
    return a
