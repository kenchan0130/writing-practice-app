"""めぐり Town3 の絵（のりもの・たてもの・まちの もの・むかしの あそび・がっき・おまつり・おしょうがつ）。
描き方は Content/Art/style-guide.md（part()/sil()/ink()。顔はつけない。本体は1つの部品）。"""
import math
from lib import Art, mirror, taper, smooth, O, EYE, SW
from words import (word, RED, RED_D, YEL, YEL2, BLUE, BLUE_D, SKY, WOOD, WOOD_D, PINK, GREEN, CREAM, WHITE, GREY, HUB, NAVY,
                   c_rpoly, c_rect, c_circ, c_bar, c_line, c_glass, c_wheel, c_lamp, c_waves,
                   e2_rr, e2_poly, e2_seg, e2_cap, e2_line, e2_star, e2_blossom, e2_note,
                   d_circ, d_tf, d_rim, d_leaf, d_blade)

T3_STEEL, T3_STEEL_D = "#dfe6ec", "#b9c4cf"
T3_ORANGE, T3_PURPLE = "#f7a94b", "#9b7fd1"
T3_LEAF, T3_LEAF_D = "#7cc36a", "#5fa64f"
T3_WALL, T3_WALL_D = "#fff0d4", "#ecd8b2"
T3_BROWN, T3_BROWN_D = "#a8672f", "#85502a"
T3_GOLD, T3_GOLD_D = "#f7c948", "#e0a92a"
T3_STONE, T3_STONE_D = "#c9d1d8", "#a9b3bc"


def T3R(d, deg, cx=256, cy=256):
    """Turn a path around (cx, cy) by deg degrees (clockwise on screen)."""
    return d_tf(d_tf(d, dx=-cx, dy=-cy), deg=deg, dx=cx, dy=cy)


def t3_pt(x, y, deg, cx=256, cy=256):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    x, y = x - cx, y - cy
    return x * c - y * s + cx, x * s + y * c + cy


def t3_line(a, x0, y0, x1, y1, w=6, s=1, e=1, col=O, deg=0, cx=256, cy=256):
    (u, v), (m, n) = t3_pt(x0, y0, deg, cx, cy), t3_pt(x1, y1, deg, cx, cy)
    a.ink([e2_seg(u, v, m, n)], w, a=s, b=e, col=col)


def t3_ground(a, x0=40, x1=472, y=456, h=22):
    with a.part(7):
        a.sil(c_rpoly([(x0, y), (x1, y), (x1, y + h), (x0, y + h)], [4, 4, 10, 10]), "#8f9aa5")


# ---------------------------------------------------------------- のりもの --
@word
def chikatetsu():
    """A subway train coming out of a round tunnel, seen from the front."""
    a = Art()
    with a.part():                                      # the tunnel mouth
        a.sil("M50 460 L50 220 C50 110 150 52 256 52 C362 52 462 110 462 220 L462 460 Z", T3_STONE)
        a.blob("M96 460 L96 232 C96 150 164 100 256 100 C348 100 416 150 416 232 L416 460 Z", "#3c4658")
        a.blob("M350 74 C420 104 462 160 462 230 L462 460 L430 460 L430 232 C430 160 400 104 350 74 Z", T3_STONE_D)
    with a.part(8):                                     # the rails
        a.sil(c_rpoly([(30, 452), (482, 452), (482, 480), (30, 480)], [4, 4, 10, 10]), "#8f9aa5")
    with a.part():                                      # the train front
        a.sil(c_rpoly([(136, 214), (376, 214), (376, 440), (136, 440)], [70, 70, 18, 18]), "#fbf7ee")
        a.blob(c_rect(137, 372, 238, 44, 0), "#2a62b8")
        a.blob(c_rpoly([(137, 416), (375, 416), (375, 439), (137, 439)], [0, 0, 16, 16]), "#e6dfd0")
    c_glass(a, c_rpoly([(160, 242), (352, 242), (352, 330), (160, 330)], [34, 34, 10, 10]), ow=7, glint=(176, 258, 34))
    with a.part(6):                                     # the roof lamp
        a.sil(c_circ(256, 224, 18), YEL)
    c_lamp(a, 174, 392, 22, col=YEL)
    c_lamp(a, 338, 392, 22, col=YEL)
    c_line(a, 256, 340, 256, 416, 5, s=0.6, e=0.6)
    a.shine("M150 274 C152 250 166 232 190 224", sw=7)
    return a


@word
def sensuikan():
    """A yellow submarine under the waves: periscope, tower, round windows and a propeller."""
    a = Art()
    Y, Y_D = "#f6c948", "#e0a92a"
    with a.part(8):                                     # periscope
        a.sil(c_bar(268, 214, 268, 100, 20), "#8a949a")
        a.sil(c_bar(268, 100, 322, 100, 20), "#8a949a")
        a.sil(c_rect(312, 88, 22, 26, 6), SKY)
    with a.part(8):                                     # the tail fin and propeller
        a.sil("M86 276 L40 204 L86 220 L132 270 Z", Y_D)
        a.sil("M86 330 L40 396 L88 380 L132 322 Z", Y_D)
        a.sil(c_circ(58, 303, 14, 52), "#8a949a")
    with a.part():                                      # tower
        a.sil(c_rpoly([(210, 222), (330, 222), (344, 268), (196, 268)], [22, 22, 0, 0]), Y)
    with a.part():                                      # hull
        a.sil(c_circ(260, 316, 212, 100), Y)
        a.blob("M96 346 C130 408 392 418 440 346 C420 388 330 410 260 412 C190 412 122 396 96 346 Z", Y_D)
    for x in (150, 258, 366):
        with a.part(6):
            a.sil(c_circ(x, 310, 30), SKY)
        a.shine(f"M{x - 16} {306} C{x - 14} {290} {x - 4} {282} {x + 6} {282}", sw=6)
    a.shine("M140 262 C170 236 220 226 260 226", sw=8)
    c_waves(a, y=424, x0=30, x1=482, n=5, amp=12, depth=44)
    return a


@word
def toudai():
    """A lighthouse: a tall red-and-white tower, a glass lantern room and two beams of light."""
    a = Art()
    with a.part(8):                                     # rocks
        a.sil("M70 470 C80 428 130 414 178 420 L338 420 C388 414 432 428 442 470 Z", "#8f9aa5")
    a.blob("M300 424 C380 418 430 430 442 470 L330 470 Z", "#7a858f")
    # beams of light
    a.blob("M180 120 L40 60 L40 150 Z", YEL, **{"fill-opacity": "0.55"})
    a.blob("M332 120 L472 60 L472 150 Z", YEL, **{"fill-opacity": "0.55"})
    tower = "M190 424 L218 190 L294 190 L322 424 Z"
    with a.part():                                      # tower
        a.sil(tower, WHITE)
        a.blob("M290 190 L294 190 L322 424 L296 424 Z", "#e9e1d5")
    for y0, y1 in ((420, 360), (326, 266), (232, 192)):
        t0, t1 = (y0 - 190) / 234, (y1 - 190) / 234
        xl0, xr0 = 218 - 28 * t0, 294 + 28 * t0
        xl1, xr1 = 218 - 28 * t1, 294 + 28 * t1
        a.blob(f"M{xl0:.1f} {y0} L{xl1:.1f} {y1} L{xr1:.1f} {y1} L{xr0:.1f} {y0} Z", RED)
    a.blob("M296 360 L289 266 L291 266 L322 360 Z", RED_D)
    with a.part(7):                                     # gallery
        a.sil(c_rpoly([(196, 178), (316, 178), (324, 198), (188, 198)], [4, 4, 4, 4]), "#3d3f4a")
    with a.part():                                      # lantern room
        a.sil(c_rect(214, 112, 84, 70, 8), "#fff3b0")
        a.blob(c_rect(266, 112, 32, 70, 0), YEL)
    c_line(a, 256, 116, 256, 180, 6, s=1, e=1)
    with a.part():                                      # the cap
        a.sil("M256 56 Q268 56 276 68 L310 112 L202 112 L236 68 Q244 56 256 56 Z", RED)
        a.sil(c_circ(256, 52, 12), "#3d3f4a")
    with a.part(8):                                     # door
        a.sil(c_rpoly([(240, 370), (272, 370), (272, 424), (240, 424)], [16, 16, 0, 0]), T3_BROWN)
    return a


@word
def koujou():
    """A factory: a saw-tooth roof, two tall chimneys with white smoke and a big door."""
    a = Art()
    W_, W_D, ROOF, ROOF_D = "#e7edf2", "#c9d3dc", "#e5534b", "#c9403a"
    for cx, cy, r in ((148, 118, 28), (186, 78, 34), (350, 98, 28), (386, 56, 30)):
        with a.part(7):
            a.sil(c_circ(cx, cy, r), WHITE)
    with a.part():                                      # chimneys
        a.sil(c_rpoly([(122, 132), (172, 132), (178, 330), (116, 330)], [2, 2, 0, 0]), "#d9625a")
        a.sil(c_rpoly([(324, 112), (374, 112), (380, 330), (318, 330)], [2, 2, 0, 0]), "#d9625a")
        a.blob(c_rect(122, 150, 50, 14, 0), WHITE)
        a.blob(c_rect(324, 130, 50, 14, 0), WHITE)
    with a.part():                                      # the long wall
        a.sil(c_rect(40, 300, 432, 160, 4), W_)
        a.blob(c_rect(41, 420, 430, 40, 0), W_D)
    with a.part():                                      # saw-tooth roof
        a.sil("M32 304 L32 240 L128 288 L128 240 L224 288 L224 240 L320 288 L320 240 L416 288 L416 240 L480 270 L480 304 Z", ROOF)
        a.blob("M32 292 L480 292 L480 304 L32 304 Z", ROOF_D)
    with a.part(9):                                     # big door
        a.sil(c_rpoly([(196, 360), (316, 360), (316, 460), (196, 460)], [10, 10, 0, 0]), "#8aa6c6")
    for x in (216, 236, 256, 276, 296):
        c_line(a, x, 366, x, 456, 4, s=0.5, e=0.5, col="#6f8cb0")
    c_glass(a, c_rect(70, 336, 84, 56, 6), ow=5, glint=(80, 346, 18))
    c_glass(a, c_rect(358, 336, 84, 56, 6), ow=5, glint=(368, 346, 18))
    return a


@word
def ido():
    """A well: a round stone wall, a little wooden roof over a rope and a bucket."""
    a = Art()
    with a.part():                                      # the stone wall
        a.sil("M104 330 C104 290 408 290 408 330 L408 440 C408 480 104 480 104 440 Z", T3_STONE)
        a.blob("M290 380 C330 390 380 380 408 350 L408 440 C408 470 330 478 290 478 Z", T3_STONE_D)
        a.blob("M104 330 C104 354 408 354 408 330 C408 306 104 306 104 330 Z", "#3c4658")
    for x, y in ((140, 370), (214, 394), (292, 372), (360, 400), (176, 436), (264, 442), (344, 446)):
        c_line(a, x, y, x + 44, y, 6, s=0.5, e=0.5, col="#8f9aa5")
    c_line(a, 180, 372, 180, 410, 6, s=0.5, e=0.5, col="#8f9aa5")
    c_line(a, 322, 380, 322, 420, 6, s=0.5, e=0.5, col="#8f9aa5")
    with a.part(8):                                     # posts and the roof
        a.sil(c_bar(124, 306, 124, 140, 24), T3_BROWN)
        a.sil(c_bar(388, 306, 388, 140, 24), T3_BROWN)
    with a.part():
        a.sil("M256 40 Q270 40 282 52 L452 148 Q464 158 452 164 L60 164 Q48 158 60 148 L230 52 Q242 40 256 40 Z", "#d9625a")
        a.blob("M60 148 L452 148 Q464 156 452 164 L60 164 Q48 156 60 148 Z", "#b94a44")
    with a.part(7):                                     # the beam and the rope
        a.sil(c_bar(124, 186, 388, 186, 20), WOOD_D)
    a.ink([e2_seg(256, 190, 256, 262)], 7, a=1, b=1, col="#8a6a4a")
    with a.part(7):                                     # the bucket
        a.sil(c_rpoly([(222, 262), (290, 262), (284, 318), (228, 318)], [8, 8, 10, 10]), WOOD)
    a.blob(c_rect(222, 262, 68, 12, 4), "#c9873f")
    c_line(a, 226, 288, 286, 288, 6, s=1, e=1, col="#8a5530")
    return a


@word
def fuusha():
    """A windmill: a round white tower, a red cap and four lattice sails."""
    a = Art()
    cx, cy = 256, 168
    sail = "M-18 -20 L-18 -190 L26 -190 L26 -20 Z"
    for deg in (28, 118, 208, 298):
        def T(d, deg=deg):
            return d_tf(d, deg=deg, dx=cx, dy=cy)
        with a.part(7):
            a.sil(T(sail), "#fff4e2")
        a.blob(T("M26 -20 L26 -190 L10 -190 L10 -20 Z"), "#ecd8b2")
        a.blob(T("M-8 -20 L-8 -190 L-1 -190 L-1 -20 Z"), "#a8672f")
        for y in (-60, -100, -140, -178):
            a.blob(T(f"M-18 {y} L26 {y} L26 {y + 7} L-18 {y + 7} Z"), "#a8672f")
    with a.part():                                      # the tower (drawn after the sails' roots)
        a.sil("M176 456 L206 206 Q256 190 306 206 L336 456 Z", "#fff0d4")
        a.blob("M290 206 L306 206 L336 456 L304 456 Z", "#ecd8b2")
    with a.part():                                      # cap
        a.sil("M196 214 C196 160 316 160 316 214 L316 226 L196 226 Z", RED)
        a.blob("M280 168 C310 176 316 200 316 226 L290 226 Z", RED_D)
    with a.part(7):
        a.sil(c_circ(cx, cy + 10, 22), T3_GOLD)
    with a.part(8):                                     # door and window
        a.sil(c_rpoly([(232, 380), (284, 380), (284, 456), (232, 456)], [26, 26, 0, 0]), T3_BROWN)
    c_glass(a, c_rpoly([(238, 290), (274, 290), (274, 336), (238, 336)], [18, 18, 6, 6]), ow=6, glint=(244, 300, 16))
    return a


@word
def hata():
    """A flag on a tall pole with a gold ball, standing on a small round stand."""
    a = Art()
    with a.part(8):                                     # the stand
        a.sil("M150 470 C150 430 362 430 362 470 Z", "#8f9aa5")
    with a.part(8):                                     # pole
        a.sil(c_bar(206, 448, 206, 70, 18), "#e9eef2")
    with a.part(8):
        a.sil(c_circ(206, 52, 24), T3_GOLD)
    a.shine("M196 40 C198 34 204 30 210 30", sw=6)
    flag = "M224 90 C284 70 336 120 396 96 C448 76 470 84 470 84 L470 276 C470 276 448 268 396 288 C336 312 284 262 224 284 Z"
    with a.part(8):
        a.sil(flag, "#9b7fd1")
        a.blob("M224 238 C284 218 336 266 396 244 C448 224 470 232 470 232 L470 276 C470 276 448 268 396 288 C336 312 284 262 224 284 Z", "#7f63b8")
        a.blob(e2_star(344, 184, 52, 22), YEL2)
    a.ink([(250, 120, 300, 118, 340, 136, 400, 116)], 7, a=0, b=0.5, col="#ffffff")
    return a


@word
def kanransha():
    """A Ferris wheel: a big round rim with spokes, eight coloured cars and two legs."""
    a = Art()
    cx, cy, R = 256, 196, 150
    with a.part(8):                                     # legs
        a.sil(c_bar(cx, cy, 130, 462, 22), "#8f9aa5")
        a.sil(c_bar(cx, cy, 382, 462, 22), "#8f9aa5")
        a.sil(c_bar(110, 462, 154, 462, 28), "#6f7b86")
        a.sil(c_bar(358, 462, 402, 462, 28), "#6f7b86")
    cols = ["#e5534b", "#f7c948", "#4fa8e0", "#7cc36a", "#f7a94b", "#9b7fd1", "#f7a8b3", "#4fa8e0"]
    with a.part():                                      # the rim
        a.sil(c_circ(cx, cy, R) + " " + c_circ(cx, cy, R - 20, ccw=True), "#fbf7ee")
        a.sil(c_circ(cx, cy, 86) + " " + c_circ(cx, cy, 70, ccw=True), "#fbf7ee")
        for k in range(8):
            ang = math.radians(k * 45 + 22.5)
            a.sil(c_bar(cx, cy, cx + R * math.cos(ang), cy + R * math.sin(ang), 12), "#fbf7ee")
    a.blob(d_rim(c_circ(cx, cy, R) + " " + c_circ(cx, cy, R - 20, ccw=True), 40, 70, 12), "#e6dfd0")
    for k in range(8):                                  # cars hang from the rim
        ang = math.radians(k * 45 + 22.5)
        x, y = cx + R * math.cos(ang), cy + R * math.sin(ang)
        with a.part(6):
            a.sil(c_rpoly([(x - 28, y + 8), (x + 28, y + 8), (x + 26, y + 58), (x - 26, y + 58)], [14, 14, 8, 8]), cols[k])
        a.blob(c_rect(x - 17, y + 20, 34, 18, 5), SKY)
    with a.part(8):
        a.sil(c_circ(cx, cy, 30), T3_GOLD)
    a.shine("M120 170 C130 130 156 100 196 84", sw=8)
    return a


# ------------------------------------------------------- むかしの あそび --
def t3_card(a, cx, cy, w, h, deg, border, fill, pic, ow=7):
    """A card turned by deg around its own centre (the picture is drawn by pic(a, p) with p(x, y) = a point on the card)."""
    def P(x, y):
        return t3_pt(cx + x, cy + y, deg, cx, cy)
    d = T3R(c_rect(cx - w / 2, cy - h / 2, w, h, 16), deg, cx, cy)
    with a.part(ow):
        a.sil(d, border)
    a.blob(T3R(c_rect(cx - w / 2 + 12, cy - h / 2 + 12, w - 24, h - 24, 8), deg, cx, cy), fill)
    pic(P)


@word
def otedama():
    """Three little cloth bean bags with stitching and patterns."""
    a = Art()

    def pillow(cx, cy, r):
        k, m = 1.12, 0.45
        return (f"M{cx - r:.1f} {cy - r:.1f} C{cx - r * m:.1f} {cy - r * k:.1f} {cx + r * m:.1f} {cy - r * k:.1f} {cx + r:.1f} {cy - r:.1f} "
                f"C{cx + r * k:.1f} {cy - r * m:.1f} {cx + r * k:.1f} {cy + r * m:.1f} {cx + r:.1f} {cy + r:.1f} "
                f"C{cx + r * m:.1f} {cy + r * k:.1f} {cx - r * m:.1f} {cy + r * k:.1f} {cx - r:.1f} {cy + r:.1f} "
                f"C{cx - r * k:.1f} {cy + r * m:.1f} {cx - r * k:.1f} {cy - r * m:.1f} {cx - r:.1f} {cy - r:.1f} Z")

    def bag(cx, cy, col, col_d, pattern):
        r = 68
        with a.part():
            a.sil(pillow(cx, cy, r), col)
            a.blob(d_rim(pillow(cx, cy, r), 45, 70, 20), col_d)
        for t in (-0.62, -0.31, 0, 0.31, 0.62):         # stitches along the top and the bottom
            a.ink([e2_seg(cx + t * r - 8, cy - r * 0.8, cx + t * r + 8, cy - r * 0.8)], 5, a=1, b=1, col=WHITE)
            a.ink([e2_seg(cx + t * r - 8, cy + r * 0.8, cx + t * r + 8, cy + r * 0.8)], 5, a=1, b=1, col=WHITE)
        pattern(cx, cy, r)

    def dots(cx, cy, r):
        for dx, dy in ((-0.4, -0.15), (0.35, -0.2), (-0.1, 0.25), (0.45, 0.2), (-0.5, 0.2)):
            a.dot(cx + dx * r, cy + dy * r, r * 0.11, WHITE)

    def stripes(cx, cy, r):
        for k in (-0.4, 0, 0.4):
            a.blob(c_rect(cx + k * r - 7, cy - r * 0.45, 14, r * 0.9, 4), WHITE)

    def squares(cx, cy, r):
        for dx, dy in ((-0.38, -0.05), (0.38, -0.05)):
            a.blob(c_rect(cx + dx * r - r * 0.18, cy + dy * r - r * 0.18, r * 0.36, r * 0.36, 6), WHITE)

    bag(156, 384, "#e5534b", "#c9403a", dots)
    bag(356, 384, "#4fa8e0", "#3f97d0", stripes)
    bag(256, 226, "#f7c948", "#e0a92a", squares)
    a.shine("M212 176 C220 162 236 154 254 152", sw=7)
    return a


@word
def hanetsuki():
    """A decorated wooden paddle (hagoita) and the feathered shuttlecock."""
    a = Art()
    deg, cx, cy = -28, 230, 270
    face = "M170 110 C170 70 340 70 340 110 L340 330 C340 370 170 370 170 330 Z"
    with a.part():
        a.sil(T3R(face, deg, cx, cy), "#f2b56b")
        a.sil(T3R(c_rpoly([(232, 340), (278, 340), (272, 480), (238, 480)], [6, 6, 12, 12]), deg, cx, cy), "#d98a47")
    a.blob(T3R("M184 116 C184 90 326 90 326 116 L326 326 C326 354 184 354 184 326 Z", deg, cx, cy), "#fbe3c3")
    # a pink camellia-like flower on the face
    fx, fy = t3_pt(255, 214, deg, cx, cy)
    e2_blossom(a, fx, fy, 70, col="#f7a8b3", mid=YEL2, rot=-90 + deg)
    for ang in (160, 20):
        lx, ly = t3_pt(255 + 82 * math.cos(math.radians(ang)), 214 + 68 * math.sin(math.radians(ang)) + 30, deg, cx, cy)
        a.blob(d_leaf(lx, ly, lx + 36 * (1 if ang < 90 else -1), ly + 30, 22), GREEN)
    t3_line(a, 232, 340, 278, 340, 8, s=1, e=1, col="#b86f2f", deg=deg, cx=cx, cy=cy)
    a.shine(f"M{t3_pt(196, 150, deg, cx, cy)[0]:.1f} {t3_pt(196, 150, deg, cx, cy)[1]:.1f} "
            f"L{t3_pt(196, 260, deg, cx, cy)[0]:.1f} {t3_pt(196, 260, deg, cx, cy)[1]:.1f}", sw=7)
    # the shuttlecock
    sx, sy = 400, 130
    with a.part(7):
        for dx, col in ((-34, "#e5534b"), (0, "#ffffff"), (34, "#4fa8e0")):
            a.sil(f"M{sx} {sy} L{sx + dx * 1.5 - 14:.0f} {sy - 78} Q{sx + dx * 1.5:.0f} {sy - 96} {sx + dx * 1.5 + 14:.0f} {sy - 78} Z", col)
        a.sil(c_circ(sx, sy + 8, 32), "#3d3f4a")
    a.shine(f"M{sx - 18} {sy} C{sx - 16} {sy - 12} {sx - 8} {sy - 18} {sx + 2} {sy - 18}", sw=6)
    return a


@word
def darumaotoshi():
    """A tower of four coloured blocks with a daruma head on top, and a small wooden hammer."""
    a = Art()
    blocks = [("#4fa8e0", 424), ("#7cc36a", 376), ("#f7c948", 328), ("#e5534b", 280)]
    for col, y in blocks:
        with a.part(7):
            a.sil(c_rpoly([(176, y), (336, y), (336, y + 48), (176, y + 48)], [8, 8, 8, 8]), col)
        a.blob(c_rect(180, y + 4, 152, 10, 4), WHITE, **{"fill-opacity": "0.35"})
    with a.part():                                      # the daruma head
        a.sil(c_circ(256, 170, 100, 96), "#e5534b")
        a.blob(d_rim(c_circ(256, 170, 100, 96), 40, 70, 24), "#c9403a")
    a.blob("M170 168 C170 138 210 126 256 126 C302 126 342 138 342 168 C342 206 304 220 256 220 C208 220 170 206 170 168 Z", "#fff4e2")
    for sx in (-1, 1):
        a.ellipse(256 + sx * 42, 168, 14, 17, EYE, sw=0, stroke="none")
        a.dot(256 + sx * 42 + 5, 160, 5, WHITE)
        a.path(f"M{256 + sx * 70} 140 C{256 + sx * 52} 126 {256 + sx * 30} 128 {256 + sx * 22} 138", sw=7)
    a.blob("M242 190 C250 196 262 196 270 190 L256 204 Z", "#e5534b")
    with a.part(8):                                     # hammer
        a.sil(c_bar(382, 410, 432, 280, 18), "#c97f3e")
        a.sil(c_rpoly([(370, 410), (462, 438), (446, 470), (354, 442)], [12, 12, 12, 12]), "#f2b56b")
    a.blob(c_rpoly([(360, 436), (452, 462), (446, 470), (354, 442)], [0, 0, 8, 8]), "#c97f3e")
    return a


@word
def kamishibai():
    """A wooden picture-story stage with its doors open, showing a sun over a green hill, on a stand."""
    a = Art()
    with a.part(8):                                     # stand
        a.sil(c_bar(150, 396, 112, 478, 20), T3_BROWN)
        a.sil(c_bar(362, 396, 400, 478, 20), T3_BROWN)
        a.sil(c_bar(256, 410, 256, 478, 20), T3_BROWN)
    with a.part():                                      # the box and open doors
        a.sil(c_rpoly([(62, 74), (450, 74), (450, 402), (62, 402)], [14, 14, 14, 14]), "#c97f3e")
        a.sil("M62 90 L18 62 L18 330 L62 360 Z", "#f2b56b")
        a.sil("M450 90 L494 62 L494 330 L450 360 Z", "#f2b56b")
    a.blob(c_rpoly([(62, 78), (450, 78), (450, 140), (62, 140)], [14, 14, 0, 0]), "#e0a066")
    with a.part(8):
        a.sil(c_rect(94, 112, 324, 262, 8), "#a0dcf8")
    a.blob("M94 300 C150 250 220 260 270 292 C330 330 380 296 418 280 L418 374 L94 374 Z", "#7cc36a")
    a.blob("M94 332 C170 306 260 330 418 322 L418 374 L94 374 Z", "#5fa64f")
    a.blob(c_circ(344, 184, 38), YEL2)
    for k in range(8):
        ang = math.radians(k * 45 + 10)
        a.blob(c_bar(344 + 48 * math.cos(ang), 184 + 48 * math.sin(ang), 344 + 62 * math.cos(ang), 184 + 62 * math.sin(ang), 10), YEL2)
    # a little house
    a.blob(c_rect(150, 262, 70, 52, 4), "#fff0d4")
    a.blob("M140 266 L185 224 L230 266 Z", "#e5534b")
    a.blob(c_rect(176, 286, 20, 28, 3), T3_BROWN)
    # clouds
    a.blob(c_circ(160, 170, 20) + " " + c_circ(184, 160, 24) + " " + c_circ(210, 172, 18), WHITE)
    a.dot(124, 122, 1, O)
    c_line(a, 36, 130, 36, 300, 6, s=1, e=1, col="#c98a3e")
    c_line(a, 476, 130, 476, 300, 6, s=1, e=1, col="#c98a3e")
    return a


# ---------------------------------------------------------------- がっき --
@word
def shamisen():
    """A shamisen: a square body with a pale skin, a long dark neck, three pegs, three strings, and a plectrum."""
    a = Art()
    WD, WD_D = "#8a5530", "#6f4326"
    with a.part(8):                                     # the neck
        a.sil(c_rpoly([(242, 96), (270, 96), (276, 320), (236, 320)], [4, 4, 0, 0]), "#3b2f2a")
    with a.part(8):                                     # the peg box and pegs
        a.sil(c_rpoly([(232, 30), (280, 30), (284, 112), (228, 112)], [14, 14, 6, 6]), "#3b2f2a")
        for y in (52, 70, 88):
            a.sil(c_bar(212, y, 230, y, 12), "#fbf7ee")
    with a.part(8):
        a.sil(c_rpoly([(284, 52), (300, 52), (300, 88), (284, 88)], [4, 4, 4, 4]), "#fbf7ee")
    with a.part():                                      # the body
        a.sil(c_rpoly([(160, 300), (352, 300), (352, 478), (160, 478)], [26, 26, 26, 26]), WD)
        a.blob(d_rim(c_rpoly([(160, 300), (352, 300), (352, 478), (160, 478)], [26, 26, 26, 26]), 50, 60, 18), WD_D)
    a.blob(c_rpoly([(182, 322), (330, 322), (330, 456), (182, 456)], [14, 14, 14, 14]), "#fff4e2")
    a.blob(d_rim(c_rpoly([(182, 322), (330, 322), (330, 456), (182, 456)], [14, 14, 14, 14]), 50, 60, 12), "#ecd8b2")
    a.blob(c_circ(256, 360, 12, 9), "#d9c9a4")
    a.blob(c_circ(256, 392, 12, 9), "#d9c9a4")
    with a.part(6):                                     # the bridge
        a.sil(c_rpoly([(214, 404), (298, 404), (298, 420), (214, 420)], [6, 6, 6, 6]), "#fbf7ee")
    for dx in (-12, 0, 12):                             # strings
        a.ink([e2_seg(256 + dx * 0.4, 112, 256 + dx * 1.2, 412)], 4, a=1, b=1, col="#f2e6c9")
    with a.part(7):                                     # the plectrum
        a.sil("M388 300 L458 300 Q474 340 440 420 Q432 432 422 420 Q388 360 388 300 Z", "#fbf7ee")
    a.blob("M388 300 L458 300 L458 316 L388 316 Z", "#ecd8b2")
    a.shine("M236 140 L240 280", sw=5)
    return a


@word
def tatebue():
    """A recorder-like school flute lying at a slant: a beak, seven holes and a bell end."""
    a = Art()
    deg = -34
    body = c_rpoly([(100, 232), (410, 220), (410, 292), (100, 280)], [8, 8, 8, 8])
    with a.part():
        a.sil(T3R(body, deg), "#fbf7ee")
        a.sil(T3R(c_rpoly([(386, 214), (466, 196), (466, 316), (386, 298)], [14, 14, 14, 14]), deg), "#fbf7ee")
        a.sil(T3R("M20 238 C20 226 40 224 110 226 L110 286 C40 286 20 284 20 272 Z", deg), "#8a5530")
    a.blob(T3R(c_rpoly([(386, 214), (400, 212), (400, 300), (386, 298)], [0, 0, 0, 0]), deg), "#e6dfd0")
    for x in (170, 330):                                # joints
        a.blob(T3R(c_rpoly([(x, 224), (x + 16, 224), (x + 16, 288), (x, 288)], [0, 0, 0, 0]), deg), "#8a5530")
    for k, x in enumerate((206, 236, 266, 296, 336, 366, 396)):
        u, v = t3_pt(x, 255, deg)
        a.ellipse(u, v, 12, 14, "#4a3428", sw=0, stroke="none")
    u, v = t3_pt(150, 255, deg)
    a.blob(f"M{u - 14:.1f} {v - 4:.1f} L{u + 14:.1f} {v - 4:.1f} L{u + 14:.1f} {v + 10:.1f} L{u - 14:.1f} {v + 10:.1f} Z", "#4a3428")
    p0, p1 = t3_pt(120, 240, deg), t3_pt(380, 238, deg)
    a.shine(f"M{p0[0]:.1f} {p0[1]:.1f} L{p1[0]:.1f} {p1[1]:.1f}", sw=7)
    return a


# ------------------------------------------------------------- うんどう --
@word
def wanage():
    """A ring toss: a wooden base with a peg, and coloured rings on it and in the air."""
    a = Art()
    with a.part(8):                                     # base
        a.sil(c_rpoly([(90, 420), (422, 420), (440, 470), (72, 470)], [10, 10, 12, 12]), "#c97f3e")
    a.blob(c_rpoly([(90, 420), (422, 420), (428, 438), (84, 438)], [10, 10, 0, 0]), "#f2b56b")
    with a.part(8):                                     # peg
        a.sil(c_rpoly([(240, 150), (272, 150), (276, 430), (236, 430)], [14, 14, 0, 0]), "#8a5530")

    def ring(cx, cy, rx, ry, col, th=18):
        with a.part(8):
            a.sil(c_circ(cx, cy, rx, ry) + " " + c_circ(cx, cy, rx - th, ry - th * 0.5, ccw=True), col)

    ring(256, 392, 128, 38, "#e5534b")
    ring(256, 342, 106, 32, "#f7c948")
    ring(256, 296, 86, 26, "#4fa8e0")
    with a.part(8):                                     # a ring thrown through the air
        a.sil(T3R(c_circ(396, 138, 78, 46) + " " + c_circ(396, 138, 58, 32, ccw=True), -26, 396, 138), "#7cc36a")
    a.shine("M168 384 C210 376 240 374 262 376", sw=7)
    return a


# --------------------------------------------------------------- おまつり --
def t3_goldfish(a, cx, cy, s=1.0, flip=False, deg=0):
    f = -1 if flip else 1

    def P(x, y):
        return t3_pt(cx + f * x * s, cy + y * s, deg, cx, cy)

    def path(pts_cmds):
        return pts_cmds

    tail = ("M" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(-30, 0)]) +
            " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(-60, -34), (-92, -44), (-100, -26)]) +
            " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(-84, -10), (-84, 10), (-100, 26)]) +
            " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(-92, 44), (-60, 34), (-30, 0)]) + " Z")
    body = ("M" + f"{P(60, 0)[0]:.1f} {P(60, 0)[1]:.1f}" +
            " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(60, -36), (24, -42), (-8, -34)]) +
            " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(-32, -26), (-40, -10), (-36, 0)]) +
            " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(-40, 10), (-32, 26), (-8, 34)]) +
            " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(24, 42), (60, 36), (60, 0)]) + " Z")
    fin = ("M" + f"{P(10, -34)[0]:.1f} {P(10, -34)[1]:.1f}" +
           " C" + " ".join(f"{P(x, y)[0]:.1f} {P(x, y)[1]:.1f}" for x, y in [(0, -62), (-22, -62), (-30, -44)]) + " Z")
    with a.part(6 * max(s, 0.7)):
        a.sil(tail, "#f9954a")
        a.sil(fin, "#f9954a")
        a.sil(body, "#ff8a3d")
    ex, ey = P(34, -8)
    a.dot(ex, ey, 7 * s, EYE)
    a.dot(ex + 2 * s, ey - 2 * s, 2.6 * s, WHITE)
    bx, by = P(14, 12)
    a.blob(c_circ(bx, by, 12 * s, 9 * s), "#ffb677", **{"fill-opacity": "0.8"})


@word
def kingyosukui():
    """A goldfish-scooping pool: a round blue tub, two goldfish and a paper scoop (poi) with a handle."""
    a = Art()
    with a.part():                                      # tub
        a.sil(c_circ(256, 330, 220, 120), "#e5534b")
    a.blob(c_circ(256, 330, 196, 100), "#bfe6fa")
    a.blob(c_circ(256, 346, 196, 100), "#9fd3f2", **{"fill-opacity": "0.6"})
    a.blob(c_circ(256, 330, 196, 100), "#bfe6fa", **{"fill-opacity": "0.5"})
    t3_goldfish(a, 168, 350, 1.0, flip=False)
    t3_goldfish(a, 336, 392, 0.9, flip=True, deg=8)
    a.path("M100 330 C150 308 200 306 250 318", stroke="#ffffff", sw=6, **{"stroke-opacity": "0.8"})
    a.path("M330 300 C360 296 392 304 414 318", stroke="#ffffff", sw=6, **{"stroke-opacity": "0.8"})
    with a.part(7):                                     # the poi
        a.sil(T3R(c_circ(364, 150, 66) + " " + c_circ(364, 150, 52, ccw=True), -20, 364, 150), "#f7c948")
        a.sil(T3R(c_bar(364, 200, 316, 296, 16), 0), "#f7c948")
    a.blob(c_circ(364, 150, 53), "#fffdf5", **{"fill-opacity": "0.85"})
    a.blob(c_circ(364, 150, 53), "#fffdf5", **{"fill-opacity": "0.5"})
    a.shine("M322 126 C330 106 348 94 370 92", sw=6)
    return a


@word
def yatai():
    """A festival stall: a red-and-white striped awning, a counter with apple candies, and a lantern."""
    a = Art()
    with a.part(8):                                     # posts
        a.sil(c_bar(86, 160, 86, 470, 20), T3_BROWN)
        a.sil(c_bar(426, 160, 426, 470, 20), T3_BROWN)
    with a.part():                                      # the counter
        a.sil(c_rpoly([(60, 360), (452, 360), (452, 470), (60, 470)], [10, 10, 6, 6]), "#4fa8e0")
        a.blob(c_rect(61, 360, 390, 22, 0), "#3f97d0")
        a.blob(c_rect(61, 440, 390, 29, 0), "#3f97d0")
    # apple candies on sticks
    for i, x in enumerate((140, 214, 288, 362)):
        a.ink([e2_seg(x, 300, x, 362)], 8, a=1, b=1, col="#f2b56b")
        with a.part(7):
            a.sil(c_circ(x, 284, 36), "#e5534b" if i % 2 == 0 else "#f7a8b3")
        a.shine(f"M{x - 20} 282 C{x - 18} 266 {x - 8} 256 {x + 4} 254", sw=6)
    with a.part():                                      # the striped awning
        a.sil("M36 150 L86 52 L426 52 L476 150 Z", WHITE)
        for k in range(0, 6):
            x0 = 36 + k * 73.3
            a.blob(f"M{x0 + 0:.1f} 150 L{36 + 50 * (k * 73.3) / 440:.1f} {150 - 98 * (k * 73.3) / 440 * 0 - 98 * 0 :.1f} Z", WHITE)
    a.blob("M36 150 L86 52 L170 52 L130 150 Z", "#e5534b")
    a.blob("M200 150 L212 52 L296 52 L270 150 Z", "#e5534b")
    a.blob("M340 150 L342 52 L426 52 L410 150 Z", "#e5534b")
    with a.part():                                      # scalloped edge
        a.sil("M30 146 L482 146 L482 168 C464 188 440 188 424 168 C410 188 386 188 370 168 C352 188 332 188 316 168 "
              "C300 188 280 188 262 168 C246 188 226 188 208 168 C192 188 170 188 154 168 C138 188 118 188 102 168 "
              "C86 188 64 188 48 168 L30 168 Z", "#e5534b")
    for x in (102, 208, 316, 424):
        a.blob(c_circ(x - 24, 168, 16, 14), WHITE)
    return a


# --------------------------------------------------------------- おしょうがつ --
@word
def shimekazari():
    """A New Year rope wreath: a twisted straw ring with white paper zigzags, a bitter orange, green leaves and a red bow."""
    a = Art()
    S, S_D = "#e8c36a", "#c9a24a"
    with a.part(7):                                     # fern leaves at the top
        a.sil(d_leaf(256, 160, 140, 60, 40), "#5fa64f")
        a.sil(d_leaf(256, 160, 372, 60, 40), "#5fa64f")
        a.sil(d_leaf(256, 160, 256, 40, 40), "#7cc36a")
    ring = c_circ(256, 240, 190, 150) + " " + c_circ(256, 240, 130, 98, ccw=True)
    with a.part():                                      # the straw ring
        a.sil(ring, S)
    a.blob(d_rim(ring, 40, 70, 24), S_D)
    for k in range(14):                                 # twist marks
        ang = math.radians(k * 360 / 14 + 8)
        x0, y0 = 256 + 134 * math.cos(ang), 240 + 102 * math.sin(ang)
        x1, y1 = 256 + 186 * math.cos(ang + 0.1), 240 + 146 * math.sin(ang + 0.1)
        a.ink([e2_seg(x0, y0, x1, y1)], 7, a=0.4, b=0.4, col="#a98530")
    # the paper zigzags (shide)
    for x in (130, 256, 382):
        with a.part(6):
            for k, o in enumerate((0, -9, 9, -9)):
                a.sil(c_rpoly([(x - 14 + o, 368 + k * 24), (x + 14 + o, 368 + k * 24), (x + 14 + o, 396 + k * 24), (x - 14 + o, 396 + k * 24)], [3, 3, 3, 3]), WHITE)
    # the orange
    with a.part(8):
        a.sil(c_circ(256, 288, 52), "#f7a94b")
    a.shine("M222 280 C226 264 238 256 252 254", sw=7)
    a.blob(d_leaf(256, 238, 300, 214, 22), GREEN)
    # red bow
    with a.part(7):
        a.sil("M256 128 C220 90 168 100 184 140 C196 160 230 148 256 128 Z", RED)
        a.sil("M256 128 C292 90 344 100 328 140 C316 160 282 148 256 128 Z", RED)
        a.sil(c_circ(256, 130, 18), RED_D)
    return a


# ------------------------------------------------------------ まちの おみせ --
@word
def sentou():
    """A public bath: a tall chimney, a gabled roof, a blue curtain at the door and a steam mark."""
    a = Art()
    with a.part():                                      # chimney
        a.sil(c_rpoly([(386, 50), (430, 50), (440, 300), (376, 300)], [4, 4, 0, 0]), "#d9625a")
        a.blob(c_rect(386, 90, 44, 14, 0), WHITE)
    for cx, cy, r in ((400, 40, 22), (432, 14, 18)):
        with a.part(6):
            a.sil(c_circ(cx, cy, r), WHITE)
    with a.part():                                      # building
        a.sil(c_rect(50, 250, 412, 220, 6), "#fff0d4")
        a.blob(c_rect(51, 436, 410, 33, 0), "#ecd8b2")
    with a.part():                                      # gabled roof
        a.sil("M256 118 Q268 118 278 128 L430 240 Q446 252 430 258 L82 258 Q66 252 82 240 L234 128 Q244 118 256 118 Z", "#5d7894")
        a.blob("M82 244 L430 244 Q446 250 430 258 L82 258 Q66 250 82 244 Z", "#486079")
    with a.part(7):                                     # the steam mark on the gable
        a.sil(c_circ(256, 196, 30), "#fffdf5")
    for dx in (-10, 0, 10):
        a.ink([(256 + dx, 212, 250 + dx, 200, 262 + dx, 192, 256 + dx, 180)], 5, a=0.8, b=0.8, col="#e5534b")
    with a.part(8):                                     # door
        a.sil(c_rect(176, 296, 160, 174, 6), "#8aa6c6")
    with a.part(6):                                     # the blue curtain halves
        a.sil(c_rpoly([(180, 290), (252, 290), (252, 400), (180, 400)], [4, 4, 4, 4]), "#2a62b8")
        a.sil(c_rpoly([(260, 290), (332, 290), (332, 400), (260, 400)], [4, 4, 4, 4]), "#2a62b8")
    for dx in (-10, 0, 10):
        a.ink([(216 + dx, 380, 210 + dx, 360, 222 + dx, 340, 216 + dx, 320)], 5, a=0.8, b=0.8, col="#ffffff")
        a.ink([(296 + dx, 380, 290 + dx, 360, 302 + dx, 340, 296 + dx, 320)], 5, a=0.8, b=0.8, col="#ffffff")
    c_glass(a, c_rect(76, 300, 70, 70, 6), ow=5, glint=(84, 310, 18))
    c_glass(a, c_rect(366, 300, 70, 70, 6), ow=5, glint=(374, 310, 18))
    return a


@word
def ginkou():
    """A bank: a wide pediment on columns, a big gold coin sign and wide steps."""
    a = Art()
    with a.part():                                      # steps
        a.sil(c_rpoly([(60, 430), (452, 430), (472, 470), (40, 470)], [4, 4, 8, 8]), T3_STONE)
    with a.part():                                      # body
        a.sil(c_rect(80, 210, 352, 222, 4), "#fdf6e6")
        a.blob(c_rect(81, 210, 350, 20, 0), "#e6dccb")
    with a.part():                                      # pediment
        a.sil("M256 62 L458 180 Q470 190 458 200 L54 200 Q42 190 54 180 Z", "#7fb08f")
        a.blob("M54 190 L458 190 Q470 194 458 200 L54 200 Q44 194 54 190 Z", "#629577")
    with a.part(7):
        a.sil(c_circ(256, 144, 42), T3_GOLD)
    a.blob(c_circ(256, 144, 30), T3_GOLD_D)
    a.blob(c_circ(256, 144, 24), T3_GOLD)
    a.blob(e2_star(256, 144, 14, 6), WHITE)
    for x in (110, 190, 322, 402):                      # columns
        with a.part(7):
            a.sil(c_rpoly([(x - 14, 214), (x + 14, 214), (x + 12, 430), (x - 12, 430)], [2, 2, 2, 2]), "#fbf7ee")
    with a.part(9):                                     # door
        a.sil(c_rpoly([(222, 300), (290, 300), (290, 430), (222, 430)], [30, 30, 0, 0]), "#8aa6c6")
    c_line(a, 256, 306, 256, 428, 5, s=1, e=1)
    return a


@word
def yakkyoku():
    """A pharmacy: a white building with a green cross sign, a bottle in the window and a green awning."""
    a = Art()
    G = "#4cae6e"
    with a.part():
        a.sil(c_rpoly([(50, 170), (462, 170), (462, 470), (50, 470)], [8, 8, 8, 8]), "#fbf7ee")
        a.blob(c_rect(51, 436, 410, 33, 0), "#e6dfd0")
    with a.part(8):                                     # the cross sign
        a.sil(e2_poly([(226, 40), (286, 40), (286, 76), (322, 76), (322, 136), (286, 136), (286, 172), (226, 172), (226, 136), (190, 136), (190, 76), (226, 76)]), G)
    a.blob(e2_poly([(236, 50), (276, 50), (276, 86), (312, 86), (312, 126), (276, 126), (276, 162), (236, 162), (236, 126), (200, 126), (200, 86), (236, 86)]), "#6fcb8e")
    with a.part():                                      # awning
        a.sil("M38 196 L474 196 L474 218 C458 242 436 242 420 218 C404 242 382 242 366 218 C350 242 328 242 312 218 "
              "C296 242 274 242 258 218 C242 242 220 242 204 218 C188 242 166 242 150 218 C134 242 112 242 96 218 C80 242 58 242 38 218 Z", G)
    with a.part(8):                                     # window
        a.sil(c_rect(86, 262, 236, 176, 8), "#bfe6fa")
    with a.part(8):                                     # door
        a.sil(c_rpoly([(350, 270), (432, 270), (432, 470), (350, 470)], [10, 10, 0, 0]), "#8aa6c6")
    a.dot(366, 376, 6, T3_GOLD)
    for x, h, col in ((130, 70, "#f7c948"), (190, 90, "#e5534b"), (250, 62, "#4fa8e0")):   # bottles
        with a.part(6):
            a.sil(c_rpoly([(x - 24, 436 - h), (x + 24, 436 - h), (x + 24, 436), (x - 24, 436)], [8, 8, 4, 4]), col)
            a.sil(c_rect(x - 12, 436 - h - 22, 24, 24, 4), WHITE)
        a.blob(c_rect(x - 14, 436 - h * 0.7, 28, h * 0.35, 3), WHITE)
    return a




# ---------------------------------------------- やりなおした ことば（D202 の見直し）--
@word
def seisousha():
    """A garbage truck facing right: a rounded, sloping rear with a dark loading opening, a small cab."""
    a = Art()
    G, G_D = "#63b86a", "#4a9f55"
    with a.part():                                      # the packer body: round top, sloping back
        a.sil("M34 330 C20 250 46 170 120 150 C170 138 230 140 290 150 L296 392 L52 392 C40 392 36 386 34 372 Z", G)
        a.blob("M52 392 L296 392 L296 338 L40 338 Z", G_D)
        a.blob(d_rim("M34 330 C20 250 46 170 120 150 C170 138 230 140 290 150 L296 392 L52 392 C40 392 36 386 34 372 Z", 300, 40, 18), G_D)
    with a.part(7):                                     # the loading opening (a dark mouth with a lip)
        a.sil(c_rpoly([(34, 290), (130, 290), (136, 372), (40, 372)], [8, 8, 8, 8]), "#3c4658")
    a.blob("M46 306 L120 306 L124 360 L50 360 Z", "#2a3140")
    with a.part(7):                                     # the lip
        a.sil(c_rpoly([(24, 280), (140, 280), (140, 296), (24, 296)], [6, 6, 6, 6]), "#8a949a")
    with a.part(6):                                     # a bag sticking out of the mouth
        a.sil(c_circ(80, 306, 26, 20), "#f7f3e8")
    c_line(a, 70, 296, 90, 292, 5, s=1, e=1, col="#cfc7b5")
    with a.part():                                      # cab
        a.sil(c_rpoly([(290, 214), (396, 214), (452, 292), (466, 392), (290, 392)], [10, 30, 10, 10, 0]), "#fbf7ee")
        a.blob("M290 340 L466 340 L466 392 L290 392 Z", "#e6dfd0")
    c_glass(a, c_rpoly([(318, 238), (386, 238), (426, 296), (318, 296)], [8, 22, 6, 6]), ow=6, glint=(330, 252, 26))
    with a.part(6):
        a.sil(c_rpoly([(452, 336), (472, 336), (472, 360), (452, 360)], [4, 4, 4, 4]), YEL)
    with a.part(6):                                     # the orange warning light
        a.sil(c_circ(200, 150, 18, 14), T3_ORANGE)
    with a.part(7):                                     # the bin mark
        a.sil(c_circ(220, 262, 48), WHITE)
    a.blob(c_rpoly([(198, 254), (242, 254), (237, 292), (203, 292)], [4, 4, 8, 8]), G)
    a.blob(c_rect(194, 244, 52, 11, 5), G_D)
    for cx in (130, 394):
        with a.part(8):
            c_wheel(a, cx, 400, 46)
    a.shine("M70 230 C84 190 124 170 170 164", sw=8)
    return a


@word
def eki():
    """A platform with a canopy and a station sign, rails, and a train waiting with a friendly front."""
    a = Art()
    with a.part(8):                                     # the rails
        a.sil(c_rpoly([(26, 452), (486, 452), (486, 480), (26, 480)], [4, 4, 10, 10]), "#8f9aa5")
    for x in range(48, 470, 52):
        a.blob(c_rect(x, 462, 28, 14, 3), "#6f7b86")
    with a.part():                                      # the train (side view, nose on the right)
        a.sil("M40 262 L388 262 C430 262 466 292 470 340 L470 430 C470 440 462 446 452 446 L48 446 C40 446 34 440 34 430 L34 270 C34 266 36 262 40 262 Z", "#fbf7ee")
        a.blob(c_rect(35, 372, 435, 38, 0), "#2a62b8")
        a.blob("M35 410 L470 410 L470 430 C470 440 462 446 452 446 L48 446 C40 446 34 440 34 430 Z", "#e6dfd0")
    for x in (60, 150, 240):
        c_glass(a, c_rpoly([(x, 284), (x + 70, 284), (x + 70, 348), (x, 348)], [10, 10, 6, 6]), ow=6, glint=(x + 8, 296, 22))
    c_glass(a, c_rpoly([(342, 284), (410, 284), (440, 336), (342, 336)], [10, 22, 6, 6]), ow=6, glint=(352, 296, 22))
    with a.part(6):
        a.sil(c_circ(448, 392, 16, 14), YEL)
    c_line(a, 322, 270, 322, 440, 6, s=1, e=1)
    with a.part(8):                                     # the platform edge in front
        a.sil(c_rpoly([(20, 426), (492, 426), (492, 458), (20, 458)], [4, 4, 4, 4]), "#c9d1d8")
    a.blob(c_rect(24, 430, 464, 10, 0), YEL2)
    with a.part(8):                                     # canopy posts and roof
        a.sil(c_bar(60, 90, 60, 300, 16), "#8f9aa5")
        a.sil(c_bar(256, 90, 256, 300, 16), "#8f9aa5")
    with a.part():
        a.sil("M20 96 L52 44 L292 44 L324 96 Z", "#d9625a")
        a.blob("M20 84 L324 84 L324 96 L20 96 Z", "#b94a44")
    with a.part(8):                                     # the station sign and a clock
        a.sil(c_rpoly([(344, 40), (476, 40), (476, 120), (344, 120)], [12, 12, 12, 12]), "#2a62b8")
    a.blob(c_circ(410, 80, 28), WHITE)
    c_line(a, 410, 80, 410, 60, 6, s=1, e=1)
    c_line(a, 410, 80, 426, 86, 6, s=1, e=1)
    return a


@word
def otera():
    """A temple hall with curved roofs, and in front a little bell tower with a great hanging bell."""
    a = Art()
    ROOF, ROOF_D = "#5d7894", "#486079"
    with a.part():
        a.sil(c_rpoly([(40, 432), (452, 432), (470, 466), (22, 466)], [4, 4, 8, 8]), T3_STONE)
    with a.part():
        a.sil(c_rect(80, 280, 292, 154, 4), "#fff0d4")
        a.blob(c_rect(80, 396, 292, 38, 0), "#ecd8b2")
    for x in (76, 170, 266, 356):
        with a.part(7):
            a.sil(c_rpoly([(x, 276), (x + 16, 276), (x + 16, 436), (x, 436)], [2, 2, 2, 2]), "#d9625a")
    with a.part(9):
        a.sil(c_rect(184, 316, 80, 118, 4), T3_BROWN)
    a.blob(c_rect(222, 316, 42, 118, 0), T3_BROWN_D)
    c_line(a, 224, 324, 224, 430, 6, s=1, e=1, col="#5a3a1c")
    with a.part():
        a.sil("M0 322 C20 304 50 296 80 280 L226 232 L372 280 C402 296 432 304 452 322 C430 322 400 316 370 318 L82 318 C52 316 22 322 0 322 Z", ROOF)
        a.blob("M4 318 C24 318 52 314 82 312 L370 312 C400 314 428 318 448 318 C428 324 400 322 370 322 L82 322 C52 322 24 324 4 318 Z", ROOF_D)
    with a.part():
        a.sil("M110 252 C140 240 180 200 226 124 C272 200 312 240 342 252 L320 258 L132 258 Z", ROOF)
    with a.part(7):
        a.sil(c_circ(226, 100, 22, 30), T3_GOLD)
        a.sil(c_bar(226, 120, 226, 150, 14), T3_GOLD)
    # the bell tower in front on the right
    with a.part(8):
        a.sil(c_bar(344, 250, 336, 470, 18), T3_BROWN)
        a.sil(c_bar(478, 250, 486, 470, 18), T3_BROWN)
        a.sil(c_bar(340, 300, 482, 300, 14), T3_BROWN)
    with a.part(8):                                     # the bell hangs from the beam
        a.sil(c_bar(411, 296, 411, 330, 12), "#3d3f4a")
        a.sil("M376 440 C376 400 384 356 411 342 C438 356 446 400 446 440 Z", "#b8884a")
        a.sil(c_rpoly([(368, 436), (454, 436), (454, 452), (368, 452)], [8, 8, 8, 8]), "#8a6a3a")
    a.blob("M426 360 C438 380 440 410 440 436 L424 436 C428 410 428 384 420 358 Z", "#d9a463")
    c_line(a, 380, 390, 442, 390, 6, s=0.6, e=0.6, col="#6f5326")
    with a.part(8):                                     # the striking log
        a.sil(c_bar(330, 408, 392, 396, 14), "#8a5530")
    with a.part():                                      # tower roof
        a.sil("M411 196 Q422 196 432 206 L494 268 Q502 278 490 280 L332 280 Q320 278 328 268 L390 206 Q400 196 411 196 Z", ROOF)
        a.blob("M328 270 L494 270 Q502 276 490 280 L332 280 Q320 276 328 270 Z", ROOF_D)
    return a


@word
def ohajiki():
    """Flat glass pieces on a mat, and a finger about to flick one."""
    a = Art()
    with a.part(8):
        a.sil(c_rpoly([(30, 230), (482, 230), (482, 470), (30, 470)], [20, 20, 20, 20]), "#f7e7c6")
    discs = [(104, 330, 54, "#e5534b"), (214, 420, 50, "#4fa8e0"), (190, 306, 44, "#f7c948"),
             (310, 360, 52, "#7cc36a"), (96, 436, 40, "#9b7fd1"), (400, 420, 46, "#f7a94b")]
    for x, y, r, col in discs:
        with a.part(7):
            a.sil(c_circ(x, y, r), col)
        a.blob(c_circ(x, y, r * 0.66), WHITE, **{"fill-opacity": "0.4"})
        a.shine(f"M{x - r * 0.6:.0f} {y - r * 0.1:.0f} C{x - r * 0.55:.0f} {y - r * 0.5:.0f} {x - r * 0.3:.0f} {y - r * 0.7:.0f} {x + r * 0.05:.0f} {y - r * 0.74:.0f}", sw=5)
    # a thumb and an index finger, the finger curled back behind the thumb and about to flick the green piece
    with a.part(7):
        a.sil(e2_cap(500, 60, 372, 214, 60), "#f6c9a8")
    with a.part(7):
        a.sil(e2_cap(470, 20, 410, 230, 50), "#f6c9a8")
    a.blob(e2_cap(386, 220, 372, 236, 30), "#fde8d6")
    for k in range(3):
        a.ink([e2_seg(340 - k * 24, 300 + k * 22, 306 - k * 24, 322 + k * 22)], 7, a=1, b=0.3, col=O)
    return a


@word
def karuta():
    """Picture cards scattered on the floor, and a hand slapping one of them."""
    a = Art()

    def apple(P):
        x, y = P(0, 8)
        a.blob(c_circ(x, y, 40, 38), RED)
        a.blob(d_leaf(*P(0, -28), *P(26, -52), 14), GREEN)

    def star(P):
        x, y = P(0, 0)
        a.blob(e2_star(x, y, 44, 19, rot=-70), YEL2)

    def flower(P):
        x, y = P(0, 0)
        e2_blossom(a, x, y, 40, col="#ffd1dc", mid=YEL2)

    def fish(P):
        x, y = P(0, 0)
        a.blob(c_circ(x, y, 40, 24), "#4fa8e0")
        a.blob(e2_poly([P(30, 0), P(54, -18), P(54, 18)]), "#4fa8e0")
        a.dot(*P(-18, -6), 5, EYE)

    t3_card(a, 120, 160, 150, 190, -14, "#4fa8e0", "#fff8ea", apple, ow=6)
    t3_card(a, 330, 130, 150, 190, 10, "#7cc36a", "#fff8ea", flower, ow=6)
    t3_card(a, 90, 372, 150, 190, 12, "#e5534b", "#fff8ea", star, ow=6)
    t3_card(a, 300, 360, 150, 190, -8, "#f7a94b", "#fff8ea", fish, ow=6)
    t3_card(a, 438, 250, 120, 150, 70, "#9b7fd1", "#fff8ea", star, ow=6)
    # a hand coming down on the middle: palm and four fingers
    deg, cx, cy = -20, 250, 258
    with a.part(7):
        a.sil(T3R(c_rpoly([(190, 262), (310, 262), (316, 360), (184, 360)], [16, 16, 30, 30]), deg, cx, cy), "#f6c9a8")
        for k, (x0, ln) in enumerate(((198, 78), (234, 92), (270, 88), (304, 70))):
            a.sil(T3R(e2_cap(x0, 268, x0, 268 - ln, 30), deg, cx, cy), "#f6c9a8")
        a.sil(T3R(e2_cap(190, 330, 150, 296, 30), deg, cx, cy), "#f6c9a8")
    return a


@word
def tsuzumi():
    """A small hourglass drum: two pale skins, a thin waist and criss-cross cords."""
    a = Art()
    BR, BR_D = "#c97f3e", "#a8672f"
    with a.part():                                      # the waist (body)
        a.sil("M120 108 C190 150 214 214 214 256 C214 298 190 362 120 404 L392 404 C322 362 298 298 298 256 C298 214 322 150 392 108 Z", BR)
        a.blob("M392 108 C322 150 298 214 298 256 C298 298 322 362 392 404 L360 404 C310 360 282 298 282 256 C282 214 310 150 360 108 Z", BR_D)
    with a.part():
        a.sil(c_circ(256, 108, 140, 34), "#d9625a")
    a.blob(c_circ(256, 108, 112, 22), "#fff4e2")
    with a.part():
        a.sil(c_circ(256, 404, 140, 34), "#d9625a")
    a.blob(c_circ(256, 404, 112, 22), "#fff4e2")
    for k in range(6):
        x0 = 150 + k * 42
        x1 = 150 + (k + 0.5) * 42
        a.ink([(x0, 130, x0 + 10, 190, 246 + (k - 2.5) * 12, 220, 256 + (k - 2.5) * 12, 256)], 9, a=1, b=0.8, col="#e5534b")
        a.ink([(256 + (k - 2.5) * 12, 256, 266 + (k - 2.5) * 12, 292, x1 + 14, 350, x1, 386)], 9, a=0.8, b=1, col="#e5534b")
    a.shine("M150 100 C190 92 230 90 262 92", sw=6)
    return a


@word
def temari():
    """A thread ball with a flower, a cord loop on top and a tassel below, beside a smaller ball."""
    a = Art()
    # the cord loop and the tassel
    with a.part(7):
        a.sil(c_circ(206, 54, 30, 38) + " " + c_circ(206, 58, 15, 24, ccw=True), "#f7c948")
    with a.part(7):
        a.sil(c_rpoly([(190, 462), (222, 462), (226, 494), (186, 494)], [4, 4, 8, 8]), "#e5534b")
    big = c_circ(206, 262, 170)
    with a.part():
        a.sil(big, "#f7a8b3")
        a.blob(d_rim(big, 40, 80, 36), "#ee8a9c")
    for col, deg, ry in (("#e5534b", 0, 0.34), ("#4fa8e0", 60, 0.34), ("#f7c948", 120, 0.34)):
        a.blob(T3R(c_circ(206, 262, 166, 166 * ry) + " " + c_circ(206, 262, 166 - 24, 166 * ry - 8, ccw=True), deg, 206, 262), col)
    for k in range(6):
        ang = math.radians(k * 60 + 30)
        x, y = 206 + 108 * math.cos(ang), 262 + 108 * math.sin(ang)
        a.blob(e2_poly([(x, y - 13), (x + 10, y), (x, y + 13), (x - 10, y)]), WHITE)
    a.dot(206, 262, 24, WHITE)
    e2_blossom(a, 206, 262, 32, col="#ffd1dc", mid=YEL2)
    a.shine("M92 200 C102 164 128 134 164 116", sw=8)
    small = c_circ(404, 396, 84)
    with a.part():
        a.sil(small, "#9bd3a0")
        a.blob(d_rim(small, 40, 80, 20), "#74b87c")
    for k in range(5):
        a.ink([e2_seg(404 - 70 + k * 35, 330 - (0 if k else 0), 404 - 70 + k * 35, 462)], 7, a=0.2, b=0.2, col="#fff4e2")
    a.blob(c_circ(404, 396, 22), "#f7c948")
    a.shine("M342 366 C348 346 362 334 380 328", sw=6)
    return a


@word
def sugoroku():
    """A paper scroll game board with a winding path of steps, a piece and a flag, and a big dice beside it."""
    a = Art()
    deg, cx, cy = -8, 230, 240
    with a.part():
        a.sil(T3R("M60 70 C60 40 120 40 120 70 L120 90 L400 90 C400 40 440 40 440 70 L440 410 C440 440 400 440 400 410 L120 410 C120 440 60 440 60 410 Z", deg, cx, cy), "#fff4e2")
    a.blob(T3R("M56 70 C56 40 124 40 124 70 L124 100 L60 100 Z", deg, cx, cy), "#e8c98a")
    a.blob(T3R("M436 70 C436 40 404 40 404 70 L404 100 L440 100 Z", deg, cx, cy), "#e8c98a")
    path = [(150, 140), (210, 140), (270, 140), (330, 140), (380, 190), (330, 240), (270, 240), (210, 240), (150, 240),
            (130, 300), (180, 340), (240, 340), (300, 340), (360, 340)]
    cols = ["#e5534b", "#f7c948", "#4fa8e0", "#7cc36a", "#f7a94b", "#9b7fd1", "#f7a8b3"]
    for i, (x, y) in enumerate(path):
        u, v = t3_pt(x, y, deg, cx, cy)
        a.blob(c_circ(u, v, 24), cols[i % len(cols)])
        a.blob(c_circ(u, v, 15), WHITE, **{"fill-opacity": "0.35"})
    u, v = t3_pt(360, 340, deg, cx, cy)
    with a.part(6):                                     # the goal flag
        a.sil(c_bar(u, v, u, v - 56, 8), "#8a5530")
        a.sil(e2_poly([(u + 2, v - 56), (u + 40, v - 44), (u + 2, v - 32)]), RED)
    u, v = t3_pt(150, 140, deg, cx, cy)
    with a.part(7):                                     # the playing piece
        a.sil("M" + f"{u - 14} {v + 6} C{u - 14} {v - 24} {u + 14} {v - 24} {u + 14} {v + 6} L{u + 20} {v + 22} L{u - 20} {v + 22} Z", "#3f5fa8")
        a.sil(c_circ(u, v - 28, 14), "#3f5fa8")
    with a.part(8):                                     # the dice
        a.sil(e2_poly([(330, 400), (410, 380), (462, 418), (382, 440)]), WHITE)
        a.sil(e2_poly([(330, 400), (382, 440), (382, 500), (330, 462)]), "#e6e9ee")
        a.sil(e2_poly([(382, 440), (462, 418), (462, 478), (382, 500)]), "#cfd6dd")
    for (x, y) in ((390, 406), (418, 400)):
        a.dot(x, y, 7, RED)
    for (x, y) in ((344, 428), (356, 452)):
        a.dot(x, y, 6, O)
    for (x, y) in ((396, 458), (420, 450), (410, 478)):
        a.dot(x, y, 6, O)
    return a


@word
def otoshidama():
    """A white pochi-bukuro with a red daruma and a red-and-gold knot, and a pink one behind."""
    a = Art()
    deg = -10
    with a.part():
        a.sil(T3R(c_rpoly([(250, 70), (450, 70), (450, 400), (250, 400)], [14, 14, 14, 14]), 14, 350, 235), "#f7a8b3")
    for k in range(3):
        x, y = t3_pt(350, 150 + k * 90, 14, 350, 235)
        e2_blossom(a, x, y, 24, col="#fff4e2", mid=YEL2)
    env = T3R(c_rpoly([(70, 110), (310, 110), (310, 470), (70, 470)], [16, 16, 16, 16]), deg, 190, 290)
    with a.part():
        a.sil(env, "#fffdf5")
        a.blob(d_rim(env, 40, 70, 18), "#e6dfd0")
    # a small folded flap line at the top
    p0, p1 = t3_pt(86, 160, deg, 190, 290), t3_pt(294, 160, deg, 190, 290)
    a.ink([e2_seg(*p0, *p1)], 6, a=1, b=1, col="#d9cfbd")
    # the daruma
    x, y = t3_pt(190, 330, deg, 190, 290)
    with a.part(7):
        a.sil(c_circ(x, y, 66, 62), RED)
    a.blob(c_circ(x, y - 4, 44, 36), "#fff4e2")
    for sx in (-1, 1):
        a.dot(x + sx * 18, y - 6, 7, EYE)
    a.blob(c_circ(x, y + 22, 7, 5), RED_D)
    # mizuhiki knot: red and gold cords tied in a bow at the top
    kx, ky = t3_pt(190, 150, deg, 190, 290)
    with a.part(6):
        a.sil(c_circ(kx - 30, ky, 24, 18), RED)
        a.sil(c_circ(kx + 30, ky, 24, 18), RED)
    a.blob(c_circ(kx - 30, ky, 12, 8), "#fffdf5")
    a.blob(c_circ(kx + 30, ky, 12, 8), "#fffdf5")
    with a.part(6):
        a.sil(c_circ(kx, ky, 16), T3_GOLD)
    a.ink([(kx, ky + 8, kx - 8, ky + 36, kx - 20, ky + 50, kx - 22, ky + 70)], 8, a=1, b=0.6, col=T3_GOLD)
    a.ink([(kx, ky + 8, kx + 8, ky + 36, kx + 20, ky + 50, kx + 22, ky + 70)], 8, a=1, b=0.6, col=RED)
    return a


@word
def omikuji():
    """A hexagonal wooden fortune tube with a numbered stick coming out, and a folded paper tied to a twig."""
    a = Art()
    # hexagonal tube: three visible faces
    with a.part():
        a.sil(c_rpoly([(100, 150), (190, 150), (190, 470), (100, 470)], [6, 0, 0, 6]), "#d9954e")
        a.sil(c_rpoly([(190, 150), (280, 150), (280, 470), (190, 470)], [0, 0, 0, 0]), "#c97f3e")
        a.sil(c_rpoly([(280, 150), (370, 150), (370, 470), (280, 470)], [0, 6, 6, 0]), "#a8672f")
        a.sil("M100 150 L145 120 L325 120 L370 150 Z", "#e6b074")
    a.blob("M145 120 L325 120 L335 128 L135 128 Z", "#f2c98f")
    a.ink([(100, 250, 200, 262, 270, 262, 370, 250)], 6, a=1, b=1, col="#7a4a1f")
    a.ink([(100, 360, 200, 372, 270, 372, 370, 360)], 6, a=1, b=1, col="#7a4a1f")
    a.ink([(100, 440, 200, 450, 270, 450, 370, 440)], 6, a=1, b=1, col="#7a4a1f")
    with a.part(7):                                     # the hole and the stick
        a.sil(c_circ(235, 136, 40, 11), "#3b2f2a")
    with a.part(8):
        a.sil(c_rpoly([(216, 14), (252, 14), (254, 140), (214, 140)], [8, 8, 0, 0]), "#f2e6c9")
    a.blob(c_rect(216, 14, 36, 50, 0), RED)
    a.blob(c_circ(234, 100, 9), RED)
    # a twig with a paper fortune tied on it
    with a.part(7):
        a.sil(c_bar(372, 250, 490, 214, 14), "#8a5530")
    with a.part(6):
        a.sil("M410 232 L440 224 L452 340 L420 350 Z", "#fffdf5")
    a.blob("M410 232 L440 224 L442 256 L412 264 Z", "#f7a8b3")
    with a.part(6):                                     # the tie knot
        a.sil(c_circ(428, 232, 14), "#fffdf5")
    a.blob(c_circ(430, 232, 5), RED)
    a.ink([e2_seg(420, 280, 444, 272)], 5, a=1, b=1, col="#b8a98a")
    a.ink([e2_seg(422, 304, 446, 298)], 5, a=1, b=1, col="#b8a98a")
    return a


# ---- まちの おみせ（品物を 外に 大きく、屋根の形を 変える）----
def t3_shop_door(a, x, y0=250, y1=470):
    with a.part(8):
        a.sil(c_rpoly([(x, y0), (x + 78, y0), (x + 78, y1), (x, y1)], [10, 10, 0, 0]), "#c97f3e")
    a.blob(c_rect(x + 42, y0, 36, y1 - y0, 0), "#a8672f")
    a.dot(x + 14, (y0 + y1) / 2 + 20, 6, T3_GOLD)


@word
def yaoya():
    """A greengrocer with a flat roof and a big basket of vegetables out front."""
    a = Art()
    with a.part():
        a.sil(c_rect(60, 118, 392, 252, 6), "#fff0d4")
    with a.part(8):                                     # a flat parapet roof
        a.sil(c_rpoly([(36, 78), (476, 78), (476, 124), (36, 124)], [10, 10, 4, 4]), "#4f9a5a")
    with a.part(8):                                     # the sign: a tomato
        a.sil(c_rpoly([(190, 20), (322, 20), (322, 84), (190, 84)], [14, 14, 6, 6]), WHITE)
    a.blob(c_circ(256, 56, 22, 20), RED)
    a.blob(e2_star(256, 40, 11, 5), GREEN)
    with a.part():                                      # awning
        a.sil("M50 130 L462 130 L462 160 C446 184 424 184 408 160 C392 184 370 184 354 160 C338 184 316 184 300 160 "
              "C284 184 262 184 246 160 C230 184 208 184 192 160 C176 184 154 184 138 160 C122 184 100 184 84 160 C70 178 56 178 50 160 Z", "#7cc36a")
    t3_shop_door(a, 370, 220)
    c_glass(a, c_rect(386, 238, 46, 56, 6), ow=5, glint=(392, 248, 14))
    # the big basket
    with a.part(8):
        a.sil("M40 360 L330 360 L316 470 L56 470 Z", "#c97f3e")
    for k in range(4):
        a.ink([e2_seg(72 + k * 62, 372, 80 + k * 56, 462)], 7, a=1, b=1, col="#8a5530")
    for y in (398, 430):
        a.ink([e2_seg(50, y, 322, y)], 6, a=1, b=1, col="#8a5530")
    for x, y, r, col in ((96, 346, 42, RED), (172, 332, 46, "#7cc36a"), (252, 346, 42, RED), (318, 352, 34, T3_ORANGE)):
        with a.part(7):
            a.sil(c_circ(x, y, r), col)
    a.blob(e2_star(96, 322, 14, 6), GREEN)
    a.blob(e2_star(252, 322, 14, 6), GREEN)
    a.ink([(172, 290, 176, 320, 168, 344, 172, 372)], 6, a=0.4, b=0.4, col="#5fa64f")
    return a


@word
def sakanaya():
    """A fishmonger with a lean-to roof and one big fish on ice out front."""
    a = Art()
    with a.part():
        a.sil(c_rect(60, 150, 392, 220, 6), "#fff0d4")
    with a.part(8):                                     # a slanting roof
        a.sil("M36 150 L36 96 L476 40 L476 150 Z", "#4fa8e0")
    a.blob("M36 130 L476 130 L476 150 L36 150 Z", "#3f97d0")
    with a.part(8):
        a.sil(c_circ(130, 72, 40, 30), WHITE)
    a.blob("M104 72 C118 54 146 54 158 72 C146 90 118 90 104 72 Z", "#4fa8e0")
    a.blob(e2_poly([(150, 72), (170, 58), (170, 86)]), "#4fa8e0")
    a.dot(116, 68, 3.5, WHITE)
    t3_shop_door(a, 360, 200)
    c_glass(a, c_rect(376, 218, 46, 56, 6), ow=5, glint=(382, 228, 14))
    c_glass(a, c_rect(86, 210, 170, 80, 8), ow=7, glint=(96, 222, 22))
    with a.part(8):                                     # the ice tray
        a.sil(c_rpoly([(30, 380), (350, 380), (336, 470), (44, 470)], [10, 10, 10, 10]), "#e6f4fb")
    a.blob(c_rect(40, 440, 300, 28, 8), "#bfe6fa")
    for x in (80, 150, 220, 290):
        a.blob(c_circ(x, 392, 14, 8), WHITE)
    # the big fish
    with a.part(8):
        a.sil("M40 410 C100 340 250 340 320 410 C250 480 100 480 40 410 Z", "#6f9fc8")
        a.sil("M310 410 L398 342 L398 478 Z", "#6f9fc8")
        a.sil("M150 360 C170 330 210 326 232 352 Z", "#5f8eb8")
    a.blob("M52 420 C120 470 250 470 318 420 C250 456 120 456 52 420 Z", "#fbf7ee")
    a.blob(c_circ(96, 400, 12, 14), WHITE)
    a.dot(98, 402, 7, EYE)
    c_line(a, 138, 372, 150, 450, 6, s=0.6, e=0.6, col="#4f7aa0")
    for k in range(4):
        c_line(a, 190 + k * 28, 372, 196 + k * 28, 410, 5, s=0.5, e=0.5, col="#8fb8d8")
    a.shine("M70 382 C110 356 170 350 220 360", sw=8)
    return a


@word
def honya():
    """A tall narrow bookshop with a pointed gable roof, and a tall stack of books out front."""
    a = Art()
    with a.part():
        a.sil(c_rect(150, 150, 262, 320, 6), "#fff0d4")
    with a.part(8):                                     # the gable roof
        a.sil("M120 160 L281 30 L442 160 Z", T3_ORANGE)
    a.blob("M120 148 L442 148 L442 160 L120 160 Z", "#e58d32")
    with a.part(7):                                     # a round sign: an open book
        a.sil(c_circ(281, 118, 30), WHITE)
    a.blob("M262 124 C272 110 278 110 281 122 C284 110 290 110 300 124 L300 112 C290 98 284 98 281 108 C278 98 272 98 262 112 Z", RED)
    t3_shop_door(a, 316, 250)
    c_glass(a, c_rect(332, 268, 46, 52, 6), ow=5, glint=(338, 278, 14))
    with a.part(8):                                     # window with books
        a.sil(c_rect(170, 220, 130, 150, 8), "#bfe6fa")
    cols = ["#e5534b", "#4fa8e0", "#f7c948", "#7cc36a", "#9b7fd1"]
    for row, y in enumerate((248, 316)):
        a.blob(c_rect(176, y + 48, 118, 6, 0), "#c97f3e")
        for k in range(5):
            with a.part(5):
                a.sil(c_rect(182 + k * 22, y + (k % 2) * 6, 18, 48 - (k % 2) * 6, 2), cols[(k + row) % 5])
    # the tall stack of books out front (left)
    stack = [("#e5534b", 440, 150), ("#4fa8e0", 396, 170), ("#f7c948", 352, 140), ("#7cc36a", 308, 160),
             ("#9b7fd1", 264, 150), ("#f7a94b", 220, 130)]
    for col, y, w in stack:
        x0 = 112 - w / 2 + ((y // 44) % 3 - 1) * 8
        with a.part(7):
            a.sil(c_rpoly([(x0, y), (x0 + w, y), (x0 + w, y + 40), (x0, y + 40)], [6, 6, 6, 6]), col)
        a.blob(c_rect(x0 + 8, y + 12, w - 16, 5, 2), WHITE, **{"fill-opacity": "0.5"})
        a.blob(c_rect(x0 + w - 12, y + 4, 8, 32, 0), WHITE, **{"fill-opacity": "0.25"})
    return a


@word
def hanaya():
    """A flower shop with a round dome awning and three big buckets of flowers out front."""
    a = Art()
    with a.part():
        a.sil(c_rect(70, 150, 372, 320, 6), "#fff0d4")
    with a.part(8):                                     # the dome awning
        a.sil("M50 250 C50 110 462 110 462 250 Z", WHITE)
    a.blob("M50 250 C50 110 462 110 462 250 Z", "#f7a8b3")
    for x, y in ((130, 200), (200, 160), (312, 160), (382, 200), (256, 200)):
        e2_blossom(a, x, y, 14, col=WHITE, mid=YEL2)
    with a.part(7):
        a.sil("M44 244 L468 244 L468 266 L44 266 Z", "#e5798c")
    with a.part(8):
        a.sil(c_circ(256, 70, 36), WHITE)
    e2_blossom(a, 256, 70, 24, col="#f7a8b3", mid=YEL2)
    c_glass(a, c_rect(90, 290, 110, 100, 8), ow=6, glint=(100, 302, 20))
    t3_shop_door(a, 330, 280)
    # three big buckets of flowers
    for x, col, col2 in ((110, "#e5534b", "#fff3b0"), (250, "#f7c948", "#e5534b"), (390, "#9b7fd1", "#fff4e2")):
        for dx, h in ((-34, 70), (0, 100), (34, 60)):
            a.ink([e2_seg(x + dx * 0.4, 400, x + dx, 400 - h)], 8, a=1, b=1, col="#5fa64f")
        for dx, h, r in ((-34, 70, 34), (0, 100, 40), (34, 60, 32)):
            e2_blossom(a, x + dx, 396 - h, r, col=col, mid=col2)
        with a.part(8):
            a.sil(c_rpoly([(x - 56, 396), (x + 56, 396), (x + 44, 472), (x - 44, 472)], [6, 6, 10, 10]), "#4fa8e0")
        a.blob(c_rect(x - 52, 404, 104, 12, 3), "#3f97d0")
    return a


@word
def omochaya():
    """A toy shop with a stepped roof and a star on a pole, and a big teddy bear out front."""
    a = Art()
    with a.part():
        a.sil(c_rect(60, 170, 392, 300, 6), "#fff0d4")
    with a.part(8):                                     # a stepped roof
        a.sil("M50 176 L50 124 L120 124 L120 84 L210 84 L210 44 L302 44 L302 84 L392 84 L392 124 L462 124 L462 176 Z", "#9b7fd1")
    a.blob("M50 160 L462 160 L462 176 L50 176 Z", "#7f63b8")
    with a.part(6):                                     # the pole and the star
        a.sil(c_bar(256, 44, 256, 8, 8), "#8a5530")
    a.blob(e2_star(256, 100, 30, 13), YEL2)
    c_glass(a, c_rect(86, 214, 130, 100, 8), ow=6, glint=(96, 226, 20))
    t3_shop_door(a, 360, 240)
    # toys on the window sill
    with a.part(6):
        a.sil(c_rect(100, 276, 40, 38, 4), "#4fa8e0")
        a.sil(c_rect(146, 290, 38, 24, 4), "#f7c948")
    # a big teddy bear out front
    BR, BR_L = "#b9794a", "#f2d2a9"
    with a.part(8):
        a.sil(c_circ(182, 404, 76, 66), BR)
        a.sil(c_circ(100, 446, 30, 26), BR)
        a.sil(c_circ(264, 446, 30, 26), BR)
        a.sil(c_circ(100, 336, 24), BR)
        a.sil(c_circ(264, 336, 24), BR)
        a.sil(c_circ(182, 330, 72, 66), BR)
    a.blob(c_circ(100, 336, 12), BR_L)
    a.blob(c_circ(264, 336, 12), BR_L)
    a.blob(c_circ(182, 424, 44, 38), BR_L)
    a.blob(c_circ(182, 352, 30, 24), BR_L)
    a.eye(150, 318, 11)
    a.eye(214, 318, 11)
    a.blob(c_circ(182, 344, 10, 7), O)
    a.path("M170 360 C176 368 188 368 194 360", sw=6)
    with a.part(7):                                     # a red bow
        a.sil("M182 392 C150 372 142 410 182 400 C222 410 214 372 182 392 Z", RED)
    # a ball beside the bear
    with a.part(7):
        a.sil(c_circ(398, 430, 44), "#e5534b")
    a.blob(e2_star(398, 430, 20, 9), WHITE)
    return a


@word
def yagura():
    """A festival tower: a wooden frame, a red-and-white curtain around the top and lanterns on strings."""
    a = Art()
    WD = "#c97f3e"
    with a.part(8):                                     # legs and braces
        a.sil(c_bar(130, 260, 70, 470, 22), WD)
        a.sil(c_bar(382, 260, 442, 470, 22), WD)
        a.sil(c_bar(100, 360, 412, 360, 16), WD)
        a.sil(c_bar(80, 430, 432, 430, 16), WD)
        a.sil(c_bar(116, 300, 420, 430, 12), "#8a5530")
        a.sil(c_bar(396, 300, 92, 430, 12), "#8a5530")
    with a.part(8):                                     # the pole with the top lantern string
        a.sil(c_bar(256, 40, 256, 160, 14), "#8a5530")
    for x, y in ((40, 200), (472, 200)):                # strings of lanterns
        a.ink([(256, 46, 200, 70, 90, 110, x, y - 20)], 5, a=1, b=1, col=O)
    for (x, y) in ((100, 120), (60, 168), (156, 80), (412, 120), (452, 168), (356, 80)):
        with a.part(6):
            a.sil(c_circ(x, y, 22, 28), "#e5534b")
        a.blob(c_rect(x - 8, y - 4, 16, 8, 3), "#fff3b0")
    with a.part(8):                                     # the platform with its curtain
        a.sil(c_rpoly([(60, 200), (452, 200), (452, 270), (60, 270)], [8, 8, 8, 8]), WHITE)
    for k in range(0, 8, 2):
        a.blob(c_rect(60 + k * 49, 200, 49, 70, 0), RED)
    with a.part(8):                                     # the platform floor and the drum
        a.sil(c_rpoly([(40, 190), (472, 190), (472, 212), (40, 212)], [8, 8, 4, 4]), "#8a5530")
    with a.part(8):
        a.sil(c_rect(206, 140, 100, 56, 14), "#d9625a")
        a.sil(c_circ(256, 140, 56, 12), "#fff4e2")
    a.dot(256, 140, 5, O)
    return a


@word
def bonbori():
    """A paper lantern on a stand for the Doll Festival: a glowing pink box with a painted blossom."""
    a = Art()
    WD = "#8a5530"
    with a.part(8):                                     # the stand
        a.sil(c_bar(256, 360, 256, 440, 16), WD)
        a.sil(c_rpoly([(150, 440), (362, 440), (382, 476), (130, 476)], [8, 8, 10, 10]), WD)
    with a.part():                                      # roof
        a.sil("M256 52 Q268 52 280 62 L402 140 Q414 150 402 156 L110 156 Q98 150 110 140 L232 62 Q244 52 256 52 Z", T3_GOLD)
        a.blob("M110 142 L402 142 Q414 148 402 156 L110 156 Q98 148 110 142 Z", T3_GOLD_D)
    with a.part():                                      # the paper body
        a.sil(c_rpoly([(140, 156), (372, 156), (372, 366), (140, 366)], [4, 4, 14, 14]), "#fde6ec")
        a.blob(c_rect(256, 158, 114, 206, 0), "#f9c8d4")
    with a.part(7):                                     # frame
        a.sil(c_rpoly([(130, 156), (152, 156), (152, 372), (130, 372)], [4, 4, 4, 4]), WD)
        a.sil(c_rpoly([(360, 156), (382, 156), (382, 372), (360, 372)], [4, 4, 4, 4]), WD)
        a.sil(c_rpoly([(130, 356), (382, 356), (382, 376), (130, 376)], [4, 4, 4, 4]), WD)
    e2_blossom(a, 256, 260, 54, col="#ffffff", mid=YEL2)
    e2_blossom(a, 196, 200, 20, col="#ffffff", mid=YEL2)
    a.shine("M168 190 L168 330", sw=6)
    return a
