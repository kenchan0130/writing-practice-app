"""めぐり food2 の絵（くだもの・やさい・ごはん・おかし・はな・き・しぜん）。描き方は Content/Art/style-guide.md（D176）。"""
import math
from lib import Art, taper, smooth
from words import (word, d_circ, d_tf, d_rim, d_poly, d_leaf, d_vein, d_arc, d_curve, d_grain, d_blade, petal,
                   e1_d, e1_arc, e1_line, e2_rr, e2_poly, a_wool, GREEN, WHITE, LEAF1, LEAF2, BARK, BARK_D,
                   STONE, STONE_D, STONE_L)

F_STEM = "#8a5530"


def f_tfc(c, s=1.0, dx=0.0, dy=0.0, deg=0.0):
    """One cubic tuple scaled, turned (degrees) and moved, like d_tf does for paths (for ink())."""
    cs, sn = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    out = []
    for i in range(0, 8, 2):
        x, y = c[i], c[i + 1]
        out += [s * (x * cs - y * sn) + dx, s * (x * sn + y * cs) + dy]
    return tuple(out)


def f_pt(x, y, s=1.0, dx=0.0, dy=0.0, deg=0.0):
    cs, sn = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return s * (x * cs - y * sn) + dx, s * (x * sn + y * cs) + dy


def f_shine(a, c, sw=9):
    a.shine(f"M{c[0]:.1f} {c[1]:.1f} C{c[2]:.1f} {c[3]:.1f} {c[4]:.1f} {c[5]:.1f} {c[6]:.1f} {c[7]:.1f}", sw=sw)


# ------------------------------------------------------------- くだもの --
@word
def nashi():
    a = Art()
    Y, YD, SP = "#ecc968", "#d6aa48", "#c4953a"
    a.sil(taper([(256, 156, 254, 116, 262, 88, 282, 54)], 15, 20), F_STEM)
    body = ("M256 138 C332 126 428 178 428 290 C428 388 352 446 256 446 C160 446 84 388 84 290 "
            "C84 178 180 126 256 138 Z")
    with a.part():
        a.sil(body, Y)
        a.blob(d_rim(body, 42, 62, 32), YD)
        for x, y in ((150, 250), (206, 206), (300, 220), (352, 282), (244, 300), (176, 340), (300, 362),
                     (232, 400), (364, 366), (128, 310), (322, 300), (270, 256)):
            a.dot(x, y, 4.5, SP)
        a.ink([(226, 140, 240, 158, 272, 158, 286, 140)], 9, a=0, b=0)
    a.shine("M136 262 C134 226 152 194 184 176", sw=9)
    return a


@word
def kaki():
    a = Art()
    OR, ORD, CA, CAD = "#f6892f", "#dd6d1a", "#6aa84a", "#4f8a3a"
    body = ("M256 168 C366 160 440 210 440 304 C440 394 362 442 256 442 C150 442 72 394 72 304 "
            "C72 210 146 160 256 168 Z")
    with a.part():
        a.sil(body, OR)
        a.blob(d_rim(body, 42, 62, 32), ORD)
    with a.part(9):                                     # へた: 4 leaves seen a little from above
        a.sil(d_leaf(256, 190, 256, 118, 86), CA)
        a.sil(d_leaf(250, 186, 122, 204, 84, -0.2), CA)
        a.sil(d_leaf(262, 186, 390, 204, 84, 0.2), CA)
        a.sil(d_leaf(256, 182, 256, 276, 100), CA)
        d_vein(a, 248, 188, 136, 203, CAD, w=6, t0=0.1, t1=0.75)
        d_vein(a, 264, 188, 376, 203, CAD, w=6, t0=0.1, t1=0.75)
        d_vein(a, 256, 190, 256, 268, CAD, w=6, t0=0.1, t1=0.7)
    with a.part(8):
        a.sil(e2_rr(242, 150, 28, 40, 10), F_STEM)
    a.shine("M112 300 C110 262 126 232 152 214", sw=9)
    return a


@word
def sakuranbo():
    a = Art()
    R_, RD, ST = "#e23b4e", "#c2273d", "#8aa04a"
    with a.part(9):
        a.sil(taper([(160, 300, 156, 220, 206, 130, 276, 70)], 11, 13), ST)
        a.sil(taper([(350, 316, 352, 236, 322, 144, 276, 70)], 11, 13), ST)
    with a.part():
        a.sil(d_leaf(272, 76, 430, 96, 104, 0.25), GREEN)
        d_vein(a, 276, 78, 424, 96, "#58a24a", t1=0.76)
    for cx, cy in ((352, 380), (158, 364)):
        c = d_circ(cx, cy, 96, 92)
        with a.part():
            a.sil(c, R_)
            a.blob(d_rim(c, 45, 65, 26), RD)
            a.ink([(cx - 24, cy - 88, cx - 10, cy - 72, cx + 14, cy - 72, cx + 26, cy - 88)], 8, a=0, b=0)
        a.shine(f"M{cx - 66} {cy - 6} C{cx - 68} {cy - 34} {cx - 54} {cy - 56} {cx - 32} {cy - 66}", sw=9)
    return a


@word
def biwa():
    a = Art()
    OR, ORD, NV, LF, LFD = "#f8b44c", "#e5932c", "#9a6a34", "#5aa650", "#3f8a44"
    with a.part():
        a.sil(d_leaf(262, 128, 486, 190, 120, 0.15), LF)
        d_vein(a, 266, 130, 478, 188, LFD, t0=0.08, t1=0.8)
    with a.part():
        a.sil(d_leaf(250, 128, 36, 150, 112, -0.15), LF)
        d_vein(a, 246, 130, 46, 150, LFD, t0=0.08, t1=0.8)
    with a.part():
        a.sil(taper([(256, 52, 258, 90, 254, 120, 252, 160)], 26, 22, cap=False), "#a9794a")
        a.sil(taper([(254, 130, 290, 150, 320, 170, 336, 210)], 18, 14), "#a9794a")
        a.sil(taper([(254, 130, 220, 160, 196, 190, 184, 230)], 18, 14), "#a9794a")

    def fruit(cx, cy, s):
        d = d_tf("M0 -122 C60 -122 96 -60 96 12 C96 80 56 124 0 124 C-56 124 -96 80 -96 12 "
                 "C-96 -60 -60 -122 0 -122 Z", s, cx, cy)
        with a.part():
            a.sil(d, OR)
            a.blob(d_rim(d, 40, 64, 28 * s), ORD)
            for k in range(5):                           # the little star at the bottom of a loquat
                t = math.radians(90 + k * 72)
                x, y = cx + 6 * s, cy + 92 * s
                a.ink([e1_line(x, y, x + 20 * s * math.cos(t), y + 13 * s * math.sin(t))], 7 * s, a=1, b=0.3, col=NV)
        a.shine(f"M{cx - 64 * s:.0f} {cy + 6 * s:.0f} C{cx - 66 * s:.0f} {cy - 34 * s:.0f} {cx - 50 * s:.0f} {cy - 66 * s:.0f} {cx - 26 * s:.0f} {cy - 84 * s:.0f}", sw=9)

    fruit(346, 326, 0.96)
    fruit(176, 346, 1.0)
    return a


@word
def ichijiku():
    a = Art()
    PU, PUD, PUL, GRN = "#9a4f7c", "#7f3a64", "#b46a95", "#b9c56a"
    FIG = ("M0 -160 C22 -160 30 -128 46 -96 C72 -46 118 -6 118 62 C118 124 64 158 0 158 "
           "C-64 158 -118 124 -118 62 C-118 -6 -72 -46 -46 -96 C-30 -128 -22 -160 0 -160 Z")
    # whole fig (back, left)
    T = dict(s=1.12, dx=186, dy=268, deg=-10)
    d = d_tf(FIG, **T)
    with a.part():
        a.sil(d_tf("M-12 -150 L-10 -188 C-10 -198 12 -198 12 -188 L12 -150 Z", **T), "#8aa04a")
        a.sil(d, PU)
        a.blob(d_tf("M0 -160 C22 -160 30 -128 46 -96 C52 -84 60 -72 68 -60 C30 -40 -30 -40 -68 -60 "
                    "C-60 -72 -52 -84 -46 -96 C-30 -128 -22 -160 0 -160 Z", **T), GRN)
        a.blob(d_rim(d, 40, 60, 30), PUD)
        for c in ([(-40, -30, -70, 20, -76, 80, -52, 128)], [(0, -34, -6, 20, -6, 90, 0, 140)]):
            a.ink([f_tfc(c[0], **T)], 8, a=0, b=0, col=PUL)
    f_shine(a, f_tfc((-84, 70, -90, 30, -74, -6, -50, -36), **T))
    # half a fig (front, right): pale rim, red inside, seeds
    T = dict(s=1.0, dx=352, dy=312, deg=8)
    d = d_tf(FIG, **T)
    with a.part():
        a.sil(d, "#f8ebc8")
        a.blob(d_tf(FIG, s=0.86, dx=354, dy=318, deg=8), PU)
        a.blob(d_tf(FIG, s=0.8, dx=354, dy=320, deg=8), "#f8ebc8")
        a.blob(d_tf("M0 -96 C16 -96 26 -70 38 -44 C56 -8 84 20 84 62 C84 106 44 126 0 126 "
                    "C-44 126 -84 106 -84 62 C-84 20 -56 -8 -38 -44 C-26 -70 -16 -96 0 -96 Z", s=0.9, dx=354, dy=324, deg=8), "#e9627c")
        a.blob(d_circ(356, 372, 36, 40), "#f59aa0")
        for x, y in ((-30, 20), (30, 22), (-46, 66), (46, 66), (0, -6), (-22, 100), (24, 100), (0, -48),
                     (-18, 52), (20, 54), (0, 88)):
            px, py = f_pt(x, y, 0.9, 354, 324, 8)
            a.dot(px, py, 5, "#fbe6a8")
    return a


# --------------------------------------------------------------- やさい --
@word
def nasu():
    a = Art()
    PU, PUD, CA, CAD = "#7150ac", "#583a92", "#5aa650", "#3f8a44"
    T = dict(s=1.0, dx=250, dy=240, deg=32)
    d = d_tf("M0 -128 C44 -128 60 -84 68 -32 C80 30 128 64 128 138 C128 208 66 244 0 244 "
             "C-66 244 -128 208 -128 138 C-128 64 -80 30 -68 -32 C-60 -84 -44 -128 0 -128 Z", **T)
    with a.part():
        a.sil(d, PU)
        a.blob(d_rim(d, 60, 70, 34), PUD)
    with a.part():
        a.sil(d_tf(taper([(0, -140, 0, -170, 10, -196, 30, -216)], 30, 30), **T), CAD)
        a.sil(d_tf("M-74 -92 C-64 -150 64 -150 74 -92 L70 -24 L36 -76 L0 -12 L-36 -76 L-70 -24 Z", **T), CA)
        a.blob(d_tf("M10 -134 C44 -130 66 -112 72 -92 L70 -40 L40 -84 C34 -100 26 -118 10 -134 Z", **T), CAD)
    f_shine(a, f_tfc((-92, 150, -100, 100, -78, 50, -50, 14), **T), sw=10)
    return a


@word
def kyuuri():
    a = Art()
    G1, G2, G3, G4 = "#58a850", "#438f42", "#7cc46c", "#357a38"
    T = dict(s=1.0, dx=256, dy=256, deg=42)
    d = d_tf("M-52 -206 C-52 -246 52 -246 52 -206 C76 -80 76 80 52 206 C52 246 -52 246 -52 206 "
             "C-32 80 -32 -80 -52 -206 Z", **T)
    with a.part():
        a.sil(d_tf(taper([(0, -230, 0, -246, 4, -258, 12, -268)], 24, 22), **T), "#6a8f3a")
        a.sil(d, G1)
        a.blob(d_rim(d, 70, 60, 26), G2)
        a.blob(d_tf("M-30 -180 C-14 -80 -14 80 -30 180 C-18 80 -2 -80 -30 -180 Z", **T), G3)
        for x, y in ((14, -170), (36, -110), (6, -60), (40, -10), (12, 50), (38, 110), (10, 160), (-14, -120),
                     (-10, 0), (-12, 110)):
            px, py = f_pt(x, y, **T)
            a.dot(px, py, 6, G4)
        px, py = f_pt(0, 232, **T)
        a.dot(px, py, 9, "#f2d76a")
    return a


@word
def negi():
    a = Art()
    WH, WHD, G1, G2, G3 = "#fffdf4", "#e9e2cc", "#63b058", "#46964a", "#8ccf7a"
    T = dict(s=1.0, dx=236, dy=276, deg=38)
    with a.part():                                      # back leaves
        a.sil(d_tf(taper([(-14, 10, -30, -70, -70, -150, -124, -206)], 66, 18), **T), G2)
        a.sil(d_tf(taper([(14, 10, 32, -60, 80, -120, 140, -150)], 66, 18), **T), G2)
    with a.part():                                      # the long middle leaf
        a.sil(d_tf(taper([(0, 20, 0, -80, 6, -180, 14, -268)], 80, 20), **T), G1)
        a.ink([f_tfc((-12, -10, -12, -90, -6, -170, 6, -230), **T)], 10, a=0, b=0, col=G3)
    stalk = d_tf("M-42 -10 L42 -10 L44 196 C44 226 -44 226 -44 196 Z", **T)
    with a.part():
        a.sil(stalk, WH)
        a.blob(d_tf("M-42 -10 L42 -10 L43 44 C14 58 -14 58 -43 44 Z", **T), "#cfe8a8")
        a.blob(d_rim(stalk, 80, 60, 20), WHD)
        a.ink([f_tfc((-16, 70, -16, 110, -16, 150, -16, 190), **T)], 7, a=0, b=0, col=WHD)
    with a.part(7):                                     # roots
        for x1, y1 in ((-40, 266), (-12, 278), (16, 274), (42, 260)):
            a.sil(d_tf(taper([(x1 * 0.5, 208, x1 * 0.7, 226, x1 * 0.9, 244, x1, y1)], 10, 6), **T), "#d9c49a")
    return a


@word
def tamanegi():
    a = Art()
    ON, OND, ONL, ONK = "#e6a552", "#cb8538", "#f4c98a", "#b9742e"
    body = ("M256 150 C272 176 304 190 350 210 C420 242 444 304 424 364 C402 426 332 448 256 448 "
            "C180 448 110 426 88 364 C68 304 92 242 162 210 C208 190 240 176 256 150 Z")
    with a.part(8):                                     # roots
        for x in (-30, -10, 10, 30):
            a.sil(taper([(256 + x * 0.5, 440, 256 + x * 0.7, 456, 256 + x, 466, 256 + x * 1.2, 478)], 9, 6), "#d9c49a")
    with a.part():
        a.sil(taper([(256, 190, 252, 140, 262, 96, 282, 58)], 44, 12), ONL)
        a.sil(body, ON)
        a.blob(d_rim(body, 40, 62, 32), OND)
        for c in ([(256, 170, 190, 220, 170, 360, 232, 444)], [(256, 170, 322, 220, 342, 360, 280, 444)],
                  [(240, 180, 130, 240, 104, 350, 176, 430)], [(272, 180, 382, 240, 408, 350, 336, 430)]):
            a.ink(c, 7, a=0.2, b=0.2, col=ONK)
        a.ink([(256, 172, 252, 140, 258, 110, 272, 80)], 7, a=0.2, b=0, col=ONK)
    a.shine("M128 322 C126 286 142 256 172 238", sw=9)
    return a


@word
def jagaimo():
    a = Art()
    P, PD, EYE_ = "#dfba78", "#c69c57", "#a67c42"

    def eye(x, y, s=1.0):
        a.blob(d_circ(x, y, 12 * s, 7 * s), EYE_)
        a.ink([(x - 18 * s, y - 8 * s, x - 8 * s, y - 16 * s, x + 8 * s, y - 16 * s, x + 18 * s, y - 8 * s)], 6 * s, a=0, b=0, col=EYE_)

    small = ("M332 330 C356 300 420 296 454 326 C486 356 484 410 452 432 C420 452 362 448 338 420 "
             "C318 396 314 356 332 330 Z")
    with a.part():
        a.sil(small, P)
        a.blob(d_rim(small, 50, 70, 22), PD)
        eye(420, 352, 0.8)
        eye(386, 408, 0.7)
    big = ("M96 262 C84 180 168 128 252 134 C300 138 330 126 368 146 C420 174 438 250 404 318 "
           "C374 380 318 394 268 408 C210 424 150 418 118 372 C100 344 100 300 96 262 Z")
    with a.part():
        a.sil(big, P)
        a.blob(d_rim(big, 50, 62, 34), PD)
        eye(190, 220)
        eye(310, 200, 0.9)
        eye(250, 310)
        eye(160, 340, 0.8)
        eye(350, 290, 0.8)
    a.shine("M132 252 C134 214 156 184 190 168", sw=9)
    return a


@word
def satsumaimo():
    a = Art()
    P, PD, PL = "#b84a72", "#9b355b", "#d27596"
    T = dict(s=1.0, dx=256, dy=256, deg=-24)
    d = d_tf("M-236 14 C-196 -30 -130 -86 -20 -92 C90 -98 180 -50 236 2 C190 56 110 96 0 96 "
             "C-110 96 -180 60 -236 14 Z", **T)
    with a.part(8):                                     # thin root ends
        a.sil(d_tf(taper([(-220, 12, -238, 16, -252, 24, -262, 38)], 14, 6), **T), PD)
        a.sil(d_tf(taper([(224, 2, 240, 0, 252, -8, 260, -20)], 14, 6), **T), PD)
    with a.part():
        a.sil(d, P)
        a.blob(d_rim(d, 80, 70, 30), PD)
        for c in ((-120, -30, -110, -20, -96, -16, -80, -18), (20, 30, 34, 40, 50, 42, 66, 38),
                  (100, -40, 112, -30, 126, -28, 140, -32), (-60, 50, -48, 58, -34, 58, -22, 52)):
            a.ink([f_tfc(c, **T)], 8, a=0, b=0, col=PD)
    f_shine(a, f_tfc((-150, -20, -110, -54, -60, -70, -10, -70), **T), sw=10)
    return a


@word
def toumorokoshi():
    a = Art()
    Y, YD, YL, H1, H2 = "#f9d04c", "#e6ae2c", "#fde58c", "#8fd070", "#6bb558"
    cob = ("M256 46 C316 46 348 130 348 246 C348 340 316 410 256 432 C196 410 164 340 164 246 "
           "C164 130 196 46 256 46 Z")
    with a.part():
        a.sil(cob, Y)
        a.blob(d_rim(cob, 20, 60, 26), YD)
        for x, bow in ((212, -16), (256, 0), (300, 16)):   # rows of grains
            a.ink([(x - bow * 0.4, 70, x + bow, 160, x + bow, 300, x - bow * 0.4, 400)], 6, a=0, b=0, col=YD)
        for y in range(98, 400, 44):
            a.ink([(172, y + 8, 220, y - 10, 292, y - 10, 340, y + 8)], 6, a=0, b=0, col=YD)
        for y in range(120, 380, 44):
            for x in (190, 234, 278):
                a.dot(x, y - 8, 5, YL)
    for s in (-1, 1):
        d = (f"M{256 + s * 6} 470 C{256 + s * 80} 468 {256 + s * 178} 400 {256 + s * 190} 232 "
             f"C{256 + s * 150} 280 {256 + s * 96} 330 {256 + s * 52} 356 C{256 + s * 24} 380 {256 - s * 10} 420 {256 + s * 6} 470 Z")
        with a.part():
            a.sil(d, H2)
            a.ink([(256 + s * 20, 452, 256 + s * 80, 430, 256 + s * 150, 360, 256 + s * 180, 262)], 7, a=0.3, b=0, col="#4f9e48")
    front = "M256 478 C214 470 196 420 204 352 C224 372 244 380 256 380 C268 380 288 372 308 352 C316 420 298 470 256 478 Z"
    with a.part():
        a.sil(front, H1)
        a.ink([(256, 470, 252, 440, 252, 410, 256, 384)], 7, a=0.6, b=0, col=H2)
    a.shine("M192 220 C192 170 204 124 226 92", sw=9)
    return a


@word
def renkon():
    a = Art()
    SK, SKD, CUT, HOLE, NODE = "#ead8b2", "#d2bc90", "#fbf4e2", "#b9a078", "#a8875a"
    # two whole pieces behind, joined by a dark knot
    for d, rim in (("M40 150 C30 110 60 80 110 84 C170 88 214 110 228 150 C240 190 210 222 160 222 "
                    "C100 222 50 196 40 150 Z", 60),):
        with a.part():
            a.sil(d, SK)
            a.blob(d_rim(d, 60, 70, 22), SKD)
    with a.part(8):
        a.sil(d_tf(e2_rr(-14, -30, 28, 60, 12), 1, 232, 172, -24), NODE)
    seg = ("M236 176 C262 124 340 110 396 140 C440 164 470 216 464 270 L276 330 C226 300 214 226 236 176 Z")
    with a.part():
        a.sil(seg, SK)
        a.blob("M396 140 C440 164 470 216 464 270 L420 286 C430 236 420 180 396 140 Z", SKD)
    # the cut side: a round slice with holes
    cx, cy, R = 300, 322, 132
    pts = []
    for i in range(16):
        t = i * math.pi / 8
        r = R * (1.0 if i % 2 == 0 else 0.94)
        pts.append((cx + r * math.cos(t), cy + r * 0.98 * math.sin(t)))
    slice_ = smooth(pts)
    with a.part():
        a.sil(slice_, CUT)
        a.blob(d_rim(slice_, 50, 70, 16), "#ecdfc0")
        holes = [(cx, cy, 20, 20)]
        for i in range(8):
            t = math.radians(-90 + i * 45)
            big = i % 2 == 0
            holes.append((cx + 78 * math.cos(t), cy + 76 * math.sin(t), 25 if big else 17, 27 if big else 18))
        for x, y, rx, ry in holes:
            a.blob(d_circ(x, y, rx, ry), HOLE)
            a.blob(d_circ(x + 2, y + 4, rx - 4, ry - 6), "#cdb68c")
    return a


@word
def edamame():
    a = Art()
    G1, G2, G3, GD = "#8fd070", "#6fb85a", "#b4e39a", "#4f9e48"
    POD = ("M-206 8 C-198 -44 -152 -70 -112 -54 C-92 -90 -20 -94 0 -58 C24 -92 98 -84 114 -46 "
           "C152 -58 200 -30 208 6 C200 42 152 62 112 50 C82 72 20 74 0 54 C-24 76 -92 72 -112 50 "
           "C-152 64 -198 46 -206 8 Z")

    def pod(T, col, dark):
        d = d_tf(POD, **T)
        with a.part():
            a.sil(d_tf(taper([(-196, 6, -216, 4, -232, -4, -246, -18)], 16, 12), **T), GD)
            a.sil(d, col)
            a.blob(d_rim(d, 80 + T["deg"], 70, 24), dark)
            for x in (-112, 0, 112):
                a.blob(d_tf(d_circ(x - 14, -22, 30, 14), **T), G3)
            for x in (-56, 56):
                a.ink([f_tfc((x, -62, x - 10, -30, x - 10, 26, x, 58), **T)], 8, a=1, b=1, col=GD)

    pod(dict(s=0.96, dx=268, dy=196, deg=-34), G2, "#5aa24c")
    pod(dict(s=1.0, dx=250, dy=318, deg=14), G1, G2)
    return a


# ------------------------------------------------------ ごはん・のみもの --
def f_steam(a, xs, y0=150, h=96, w=20):
    """Two or three soft wisps of steam (white, thin outline)."""
    with a.part(7):
        for i, x in enumerate(xs):
            k = -1 if i % 2 else 1
            a.sil(taper([(x, y0, x - 28 * k, y0 - h * 0.34, x + 22 * k, y0 - h * 0.62, x - 4 * k, y0 - h)], w, 8), WHITE)


def f_bowl(a, col, dark, cy=250, rx=176, depth=180, foot=56, band=None):
    """A rice bowl seen a little from above: call after the food. Returns nothing; draws foot + body + shade."""
    x0, x1 = 256 - rx, 256 + rx
    by = cy + depth
    body = (f"M{x0} {cy} C{x0} {cy + 24} {x0 + rx * 0.45:.0f} {cy + 42} 256 {cy + 42} C{x1 - rx * 0.45:.0f} {cy + 42} {x1} {cy + 24} {x1} {cy} "
            f"C{x1} {cy + depth * 0.62:.0f} {256 + rx * 0.62:.0f} {by} 256 {by} C{256 - rx * 0.62:.0f} {by} {x0} {cy + depth * 0.62:.0f} {x0} {cy} Z")
    with a.part():
        a.sil(f"M{256 - foot} {by - 16} L{256 + foot} {by - 16} L{256 + foot - 6} {by + 30} C{256 + foot - 6} {by + 38} {256 - foot + 6} {by + 38} {256 - foot + 6} {by + 30} Z", col)
        a.sil(body, col)
        if band:
            band(body)
        a.blob(d_rim(body, 55, 55, 28), dark)
        a.blob(f"M{256 - foot + 4} {by + 14} L{256 + foot - 4} {by + 14} L{256 + foot - 6} {by + 30} C{256 + foot - 6} {by + 38} {256 - foot + 6} {by + 38} {256 - foot + 6} {by + 30} Z", dark)
        a.ink([(256 - foot + 10, by + 10, 256 - 20, by + 16, 256 + 20, by + 16, 256 + foot - 10, by + 10)], 6, a=0, b=0)


@word
def gohan():
    a = Art()
    BL, BLD, RICE, RICE_D = "#5f97d6", "#4a7fc0", "#fffdf6", "#ece5d0"
    f_steam(a, (206, 306), y0=112, h=92)
    a.sil(d_circ(256, 250, 176, 40), "#3f6aa8")
    mound = ("M98 258 C86 196 130 150 180 150 C196 112 250 96 286 122 C330 104 384 134 384 176 "
             "C420 190 430 232 414 258 C380 282 132 282 98 258 Z")
    with a.part():
        a.sil(mound, RICE)
        a.blob(d_rim(mound, 10, 60, 22), RICE_D)
        for x, y, g in ((170, 196, 30), (226, 150, -20), (286, 168, 30), (340, 196, -30), (214, 226, 20),
                        (296, 232, -20), (150, 240, -30), (370, 240, 20), (256, 196, 0)):
            d_grain(a, x, y, g)
        a.ink([(180, 152, 190, 160, 196, 172, 196, 184)], 7, a=1, b=0, col="#d9cfb4")
        a.ink([(384, 178, 372, 182, 362, 190, 356, 202)], 7, a=1, b=0, col="#d9cfb4")

    def band(body):
        a.blob("M88 300 C150 338 362 338 424 300 C420 322 414 338 406 352 C340 384 172 384 106 352 C98 338 92 322 88 300 Z", WHITE)
        for x, y in ((140, 340), (198, 354), (256, 358), (314, 354), (372, 340)):
            a.dot(x, y, 9, BL)
    f_bowl(a, BL, BLD, band=band)
    a.shine("M104 316 C112 356 134 388 164 408", sw=9)
    return a


@word
def tamago():
    a = Art()
    SH, SHD, YK, YKD = "#fff3dc", "#edd9b4", "#f9b233", "#ee9a1e"
    egg = d_tf("M0 -150 C66 -150 112 -60 112 20 C112 94 66 140 0 140 C-66 140 -112 94 -112 20 "
               "C-112 -60 -66 -150 0 -150 Z", 1.2, 196, 232, -12)
    with a.part():
        a.sil(egg, SH)
        a.blob(d_rim(egg, 40, 64, 34), SHD)
    a.shine("M104 240 C100 190 116 142 148 110", sw=10)
    # half a shell with the yolk in it (front, right)
    with a.part():
        a.sil("M246 360 L270 330 L296 362 L322 328 L350 362 L378 328 L404 360 L432 332 L460 362 "
              "C460 430 416 468 352 468 C290 468 246 430 246 360 Z", SH)
        a.blob("M460 362 C460 430 416 468 352 468 C322 468 296 460 276 444 C340 452 408 430 432 372 Z", SHD)
    with a.part(9):
        a.sil("M276 366 C276 322 312 300 352 300 C392 300 430 322 430 366 C400 392 306 392 276 366 Z", YK)
        a.blob("M430 366 C400 392 306 392 276 366 C310 378 394 378 418 340 C426 348 430 356 430 366 Z", YKD)
    with a.part():
        a.sil("M246 360 L270 340 L296 372 L322 342 L350 374 L378 342 L404 372 L432 342 L460 362 "
              "C460 430 416 468 352 468 C290 468 246 430 246 360 Z", SH)
        a.blob("M460 362 C460 430 416 468 352 468 C322 468 296 460 276 444 C340 452 408 430 438 366 Z", SHD)
    a.shine("M306 334 C316 322 330 316 346 314", sw=7)
    return a


@word
def gyuunyuu():
    a = Art()
    BL, BLD, WH, WHD, GL = "#4fa8e0", "#3f97d0", "#fffdf6", "#e6e2d6", "#d6eefb"
    # carton
    with a.part():
        a.sil("M96 196 L170 96 L286 96 L360 196 L360 440 C360 452 352 460 340 460 L116 460 C104 460 96 452 96 440 Z", WH)
        a.sil(e2_rr(164, 60, 128, 44, 8), WH)
        a.blob("M286 96 L360 196 L360 440 C360 452 352 460 340 460 L300 460 L300 196 L250 96 Z", WHD)
        a.blob("M96 196 L170 96 L250 96 L300 196 Z", BL)
        a.blob("M250 96 L286 96 L360 196 L300 196 Z", BLD)
        a.blob("M96 380 L300 380 L300 460 L116 460 C104 460 96 452 96 440 Z", BL)
        a.blob("M300 380 L360 380 L360 440 C360 452 352 460 340 460 L300 460 Z", BLD)
        a.ink([e1_line(300, 196, 300, 458)], 6, a=1, b=1)
        a.ink([e1_line(98, 196, 358, 196)], 6, a=1, b=1)
        a.ink([e1_line(168, 100, 290, 100)], 6, a=1, b=1)
        # cow spots
        a.blob("M96 236 C130 226 162 244 158 272 C178 292 160 324 132 318 C120 334 106 334 96 330 Z", "#4a4656")
        a.blob("M212 250 C238 234 278 250 272 280 C294 300 270 332 244 322 C222 342 194 320 204 296 C192 280 198 260 212 250 Z", "#4a4656")
        a.blob("M150 346 C168 334 192 344 190 362 C200 370 196 380 186 380 L140 380 C132 366 138 352 150 346 Z", "#4a4656")
    # glass of milk
    with a.part():
        a.sil("M312 286 L460 286 L446 452 C445 462 437 468 426 468 L346 468 C335 468 327 462 326 452 Z", GL)
        a.blob("M318 330 L454 330 L446 452 C445 462 437 468 426 468 L346 468 C335 468 327 462 326 452 Z", WH)
        a.blob("M454 330 L446 452 C445 462 437 468 426 468 L400 468 C414 440 424 380 426 330 Z", WHD)
        a.ink([(318, 330, 360, 340, 412, 340, 454, 330)], 6, a=1, b=1, col="#c9c4b4")
    a.shine("M340 306 L348 430", sw=8)
    a.shine("M150 176 L186 126", sw=8)
    return a


@word
def ocha():
    a = Art()
    CUP, CUPD, TEA, TEAD, NAVY_, SAU, SAUD = "#f6ecd8", "#e2d3b6", "#b9d05a", "#9cb840", "#3f5f9a", "#b47a4a", "#8f5c34"
    f_steam(a, (214, 300), y0=130, h=96)
    with a.part():                                      # wooden saucer
        a.sil(d_circ(256, 432, 214, 46), SAU)
        a.blob(d_rim(d_circ(256, 432, 214, 46), 70, 80, 16), SAUD)
        a.blob(d_circ(256, 424, 150, 26), SAUD)
    a.sil(d_circ(256, 178, 150, 38), "#cdbd9c")
    with a.part(7):
        a.sil(d_circ(256, 186, 128, 28), TEA)
        a.blob("M128 186 C128 170 185 158 256 158 C327 158 384 170 384 186 C350 172 162 172 128 186 Z", TEAD)
    with a.part(6):                                     # a tea stalk standing up: good luck
        a.sil(e2_rr(276, 164, 9, 30, 4), "#7a8a3a")
    body = ("M106 178 C106 198 173 216 256 216 C339 216 406 198 406 178 C406 260 398 350 372 410 "
            "C366 424 350 432 256 432 C162 432 146 424 140 410 C114 350 106 260 106 178 Z")
    with a.part():
        a.sil(body, CUP)
        a.blob(d_rim(body, 30, 60, 28), CUPD)
        a.blob("M109 250 C170 284 342 284 403 250 C402 270 400 290 397 310 C340 342 172 342 115 310 C112 290 110 270 109 250 Z", NAVY_)
        for x, y in ((150, 296), (202, 310), (256, 314), (310, 310), (362, 296)):
            a.blob(d_arc_fill(x, y), WHITE)
    a.shine("M130 236 C132 290 140 340 154 384", sw=9)
    return a


def d_arc_fill(x, y, r=17):
    """A small half-moon (wave pattern on a cup)."""
    return f"M{x - r} {y + 6} C{x - r} {y - 16} {x + r} {y - 16} {x + r} {y + 6} C{x + r * 0.5} {y - 4} {x - r * 0.5} {y - 4} {x - r} {y + 6} Z"


@word
def omochi():
    a = Art()
    MO, MOD, BRN, BRN2 = "#fffaf0", "#ece2cc", "#e8c48a", "#d9a35f"
    with a.part():                                      # the grill net
        for x in (60, 136, 212, 288, 364, 440):
            a.sil(e2_rr(x, 404, 12, 62, 6), "#9aa5a8")
        a.sil(e2_rr(40, 396, 432, 16, 8), "#b9c2c6")
        a.sil(e2_rr(40, 456, 432, 16, 8), "#b9c2c6")
    block = ("M110 300 C110 270 130 258 160 258 L352 258 C382 258 402 270 402 300 L408 388 C408 410 392 420 370 420 "
             "L142 420 C120 420 104 410 104 388 Z")
    puff = "M176 268 C120 200 150 92 256 92 C362 92 392 200 336 268 Z"
    with a.part():
        a.sil(puff, MO)
        a.sil(block, MO)
        a.blob(d_rim(block, 60, 60, 24), MOD)
        a.blob("M336 268 C376 220 372 150 330 116 C346 160 340 220 306 262 Z", MOD)
        a.blob(d_circ(236, 150, 44, 30), BRN)
        a.blob(d_circ(244, 146, 22, 14), BRN2)
        a.blob(d_circ(160, 300, 26, 14), BRN)
        a.blob(d_circ(340, 330, 30, 16), BRN)
        a.ink([(176, 268, 190, 276, 204, 278, 220, 274)], 8, a=1, b=0)
        a.ink([(336, 268, 322, 276, 308, 278, 292, 274)], 8, a=1, b=0)
    a.shine("M168 190 C172 156 190 130 216 116", sw=9)
    return a


@word
def obentou():
    a = Art()
    BOX, BOXD, IN_, RICE = "#e5534b", "#c9403a", "#b8352f", "#fffdf6"
    with a.part():
        a.sil(e2_rr(40, 132, 432, 316, 56), BOX)
        a.blob("M40 360 L472 360 L472 392 C472 424 448 448 416 448 L96 448 C64 448 40 424 40 392 Z", BOXD)
    with a.part(7):
        a.sil(e2_rr(66, 154, 380, 216, 36), IN_)
    with a.part(7):                                     # rice on the left
        rice = e2_rr(78, 164, 176, 196, 28)
        a.sil(rice, RICE)
        a.blob(d_rim(rice, 50, 70, 14), "#ece5d0")
        for x, y, g in ((110, 200, 30), (216, 206, -30), (112, 300, -20), (214, 316, 30), (130, 250, 0), (204, 262, 20)):
            d_grain(a, x, y, g)
    with a.part(6):
        a.sil(d_circ(166, 262, 27, 25), "#d83a48")
        a.blob(d_circ(158, 254, 8, 6), "#f08a92")
    # right: rolled egg, broccoli, tomato, meatball
    for x in (270, 348):
        with a.part(7):
            a.sil(e2_rr(x, 168, 70, 78, 18), "#f9d55a")
            a.ink(d_arc(x + 35, 207, 22, 180, 560, r1=4), 6, a=0.5, b=0, col="#e5ac2e")
    with a.part(7):
        a.sil("M270 320 C256 300 270 276 292 280 C300 258 336 258 342 282 C366 280 374 308 358 322 C356 344 340 356 314 356 C290 356 272 344 270 320 Z", "#5aa84c")
        a.blob("M358 322 C356 344 340 356 314 356 C300 356 288 352 280 344 C312 346 340 336 350 310 C354 314 357 318 358 322 Z", "#44903e")
        for x, y in ((296, 300), (326, 296), (310, 324)):
            a.dot(x, y, 6, "#8ccf7a")
    with a.part(7):
        a.sil(d_circ(404, 316, 36, 36), "#ef4d44")
        a.blob(d_rim(d_circ(404, 316, 36, 36), 50, 70, 12), "#d53a36")
    with a.part(6):
        a.sil("M404 290 L392 282 L402 284 L404 274 L408 284 L418 282 L408 290 Z", "#5aa84c")
    a.dot(390, 304, 6, "#f9a39a")
    a.shine("M70 400 L70 372", sw=8)
    a.shine("M84 420 L200 420", sw=8)
    return a


def f_lumpy(pts, amp, seed=1):
    """A fluffy closed outline: bumps pushed out along a polygon of points (tempura batter, ohagi)."""
    n = len(pts)
    cx = sum(p[0] for p in pts) / n
    cy = sum(p[1] for p in pts) / n
    out = []
    for i, (x, y) in enumerate(pts):
        q = pts[(i + 1) % n]
        mx, my = (x + q[0]) / 2, (y + q[1]) / 2
        k = amp * (0.7 + 0.3 * math.sin(seed * 2.1 + i * 1.7))
        L = math.hypot(mx - cx, my - cy) or 1
        out.append((x, y))
        out.append((mx + (mx - cx) / L * k, my + (my - cy) / L * k))
    return smooth(out)


@word
def tenpura():
    a = Art()
    BT, BTD, BTL, TAIL, TAILD = "#f4c768", "#dfa444", "#fbe19a", "#f0624a", "#d84a38"

    def ebi(T, seed):
        with a.part():                                  # tail fan
            a.sil(d_tf("M150 -8 C196 -70 250 -66 262 -40 C240 -34 224 -22 214 -4 C230 4 246 20 262 44 "
                       "C240 64 190 52 150 12 Z", **T), TAIL)
            a.ink([f_tfc((168, 0, 190, -2, 204, -4, 214, -4), **T)], 7, a=0.6, b=1, col=TAILD)
        body = [(-230, 0), (-200, -44), (-140, -62), (-70, -62), (0, -56), (70, -46), (130, -34), (168, -16),
                (170, 14), (130, 36), (70, 50), (0, 60), (-70, 66), (-140, 64), (-200, 44)]
        d = d_tf(f_lumpy(body, 14, seed), **T)
        with a.part():
            a.sil(d, BT)
            a.blob(d_rim(d, 90 + T["deg"], 75, 22), BTD)
            for x, y in ((-170, -14), (-100, -24), (-30, -18), (40, -14), (104, -6), (-130, 22), (-50, 26), (30, 24)):
                px, py = f_pt(x, y, **T)
                a.blob(d_circ(px, py, 13, 9), BTL)
            for x, y in ((-70, 0), (0, 4), (80, 10), (-150, 6)):
                px, py = f_pt(x, y, **T)
                a.dot(px, py, 5, BTD)

    ebi(dict(s=0.92, dx=276, dy=176, deg=-30), 1)
    ebi(dict(s=0.96, dx=244, dy=318, deg=-22), 2)
    return a


@word
def tamagoyaki():
    a = Art()
    Y, YD, YL, YK = "#f9d55a", "#e9b63a", "#fde994", "#e5a82e"

    def piece(x, y, w, h, depth):
        # the far side (thickness) first, then the cut face with the roll
        with a.part():
            a.sil(e2_rr(x + depth, y - depth * 0.55, w, h, 36), Y)
            a.sil(e2_rr(x, y, w, h, 36), Y)
            a.blob(e2_rr(x + depth, y - depth * 0.55, w, h, 36), YD)
            a.blob(e2_rr(x, y, w, h, 36), YL)
        with a.part(1):
            pass
        cx, cy = x + w / 2, y + h / 2
        a.ink(d_arc(cx, cy, w * 0.36, 200, 520, r1=w * 0.2, ky=h / w), 9, a=0.2, b=0.2, col=YK)
        a.ink(d_arc(cx + 4, cy, w * 0.2, 160, 500, r1=w * 0.05, ky=h / w), 8, a=0.2, b=0, col=YK)
        a.blob(d_circ(x + w * 0.22, y + h * 0.2, 16, 9), WHITE)

    piece(206, 150, 196, 170, 70)
    piece(44, 250, 206, 180, 64)
    return a


@word
def oden():
    a = Art()
    KN, KND, RD_, RDD, CK, CKD, CKB, CKBD = "#b9b4ae", "#9a948e", "#f6e3b0", "#e3c888", "#fffaf0", "#e9dcc0", "#c98a4a", "#ad6f34"
    T = dict(s=1.0, dx=256, dy=256, deg=18)
    a.sil(d_tf(e2_rr(-8, -236, 16, 480, 8), **T), "#e0bb85")
    tri = d_tf("M0 -216 C14 -216 24 -206 34 -190 L128 -44 C140 -24 128 -8 106 -8 L-106 -8 C-128 -8 -140 -24 -128 -44 "
               "L-34 -190 C-24 -206 -14 -216 0 -216 Z", **T)
    with a.part():
        a.sil(tri, KN)
        a.blob(d_rim(tri, 70, 70, 22), KND)
        for x, y in ((-26, -130), (24, -96), (-56, -50), (56, -40), (0, -168), (-6, -52), (-70, -30 + 2)):
            px, py = f_pt(x, y, **T)
            a.dot(px, py, 5, "#6f6a66")
    ball = d_tf(d_circ(0, 82, 96, 90), **T)
    with a.part():
        a.sil(ball, RD_)
        a.blob(d_rim(ball, 60, 70, 24), RDD)
    tube = d_tf(e2_rr(-116, 164, 232, 96, 34), **T)
    with a.part():
        a.sil(tube, CK)
        a.blob(d_rim(tube, 80, 60, 16), CKD)
        a.blob(d_tf("M-70 164 L70 164 C62 196 62 228 70 260 L-70 260 C-62 228 -62 196 -70 164 Z", **T), CKB)
        a.blob(d_tf("M30 164 L70 164 C62 196 62 228 70 260 L30 260 C36 228 36 196 30 164 Z", **T), CKBD)
        for x in (-40, -10, 16):
            a.ink([f_tfc((x, 176, x - 6, 200, x - 6, 224, x, 248), **T)], 6, a=0, b=0, col=CKBD)
    f_shine(a, f_tfc((-70, -60, -62, -92, -48, -120, -30, -144), **T), sw=8)
    f_shine(a, f_tfc((-64, 86, -64, 56, -48, 32, -24, 20), **T), sw=8)
    return a


# ---------------------------------------------------------------- おかし --
@word
def kakigoori():
    a = Art()
    ICE, ICED, SY, SYD, GL, GLD = "#f6fbff", "#d6eafa", "#f0566a", "#d93f58", "#bfe6fa", "#9dd3f2"
    mound = ("M96 262 C76 214 104 176 146 172 C150 116 204 80 256 80 C308 80 362 116 366 172 "
             "C408 176 436 214 416 262 Z")
    with a.part():
        a.sil(mound, ICE)
        a.blob(d_rim(mound, 30, 50, 26), ICED)
        a.blob("M146 176 C150 116 204 80 256 80 C308 80 362 116 366 176 C366 204 344 212 336 190 "
               "C330 226 296 232 290 200 C284 240 244 244 240 206 C232 236 200 232 198 200 C188 222 150 212 146 176 Z", SY)
        a.blob("M366 176 C366 204 344 212 336 190 C332 214 316 224 304 216 C330 196 340 150 322 108 C348 124 364 148 366 176 Z", SYD)
        a.ink([(146, 174, 138, 190, 136, 208, 142, 226)], 7, a=1, b=0, col="#b9d8ee")
        a.ink([(366, 174, 374, 190, 376, 208, 370, 226)], 7, a=1, b=0, col="#b9d8ee")
    with a.part():                                      # glass dish with a foot
        a.sil(e2_rr(176, 446, 160, 26, 12), GL)
        a.sil(e2_rr(240, 380, 32, 76, 6), GL)
        a.sil("M70 256 L442 256 C442 330 380 392 256 392 C132 392 70 330 70 256 Z", GL)
        a.blob("M442 256 C442 330 380 392 256 392 C236 392 218 390 200 386 C300 380 380 330 400 256 Z", GLD)
        a.blob(e2_rr(256, 380, 16, 76, 0), GLD)
        a.ink([e1_line(72, 256, 440, 256)], 6, a=1, b=1)
    a.shine("M102 280 C112 320 136 350 170 368", sw=9)
    a.shine("M186 116 C200 104 216 98 234 96", sw=8)
    return a


@word
def dorayaki():
    a = Art()
    TOP, TOPD, EDGE, EDGED, AN = "#b9743a", "#9c5c28", "#f0c27a", "#dba55a", "#5a3a34"
    with a.part():                                      # bottom cake
        a.sil("M52 300 C52 372 140 420 256 420 C372 420 460 372 460 300 Z", EDGE)
        a.blob("M52 330 C70 388 150 420 256 420 C362 420 442 388 460 330 C430 372 350 396 256 396 C162 396 82 372 52 330 Z", TOP)
    with a.part(8):                                     # sweet bean paste
        a.sil("M50 282 C50 334 140 366 256 366 C372 366 462 334 462 282 Z", AN)
        for x, y in ((120, 328), (190, 346), (270, 352), (350, 342), (410, 322)):
            a.blob(d_circ(x, y, 12, 7), "#7a524a")
    top = "M44 262 C44 176 136 118 256 118 C376 118 468 176 468 262 C468 300 376 328 256 328 C136 328 44 300 44 262 Z"
    with a.part():
        a.sil(top, EDGE)
        a.blob("M62 246 C70 176 150 132 256 132 C362 132 442 176 450 246 C440 276 362 298 256 298 C150 298 72 276 62 246 Z", TOP)
        a.blob("M450 246 C440 276 362 298 256 298 C220 298 188 296 160 290 C270 290 390 262 414 186 C436 204 448 224 450 246 Z", TOPD)
        a.blob(d_rim(top, 70, 60, 12), EDGED)
    a.shine("M104 222 C120 186 154 162 200 150", sw=9)
    return a


@word
def taiyaki():
    a = Art()
    TY, TYD, TYL, LN = "#e3a354", "#c98438", "#f3c986", "#a8662a"
    body = ("M36 262 C40 180 120 130 210 130 C230 100 290 96 316 130 C352 146 380 176 396 196 "
            "C424 176 456 150 484 144 C478 196 478 232 480 262 C478 292 478 328 484 380 "
            "C456 374 424 348 396 328 C364 366 300 392 210 392 C120 392 40 344 36 262 Z")
    with a.part():
        a.sil(body, TY)
        a.blob(d_rim(body, 80, 75, 26), TYD)
        a.blob("M84 216 C110 176 160 156 210 152 C170 172 130 196 106 238 C96 240 86 230 84 216 Z", TYL)
        # scales
        for col_x, ys in ((236, (190, 246, 302)), (292, (218, 274, 330)), (348, (232, 288))):
            for y in ys:
                a.ink(d_arc(col_x - 30, y, 34, -62, 62), 7, a=0.4, b=0.4, col=LN)
        a.ink([(186, 150, 206, 200, 206, 320, 186, 372)], 8, a=0.6, b=0.6, col=LN)   # gill
        for c in ([(408, 214, 430, 200, 452, 184, 470, 170)], [(412, 262, 434, 262, 454, 262, 472, 262)],
                  [(408, 310, 430, 324, 452, 340, 470, 354)]):
            a.ink(c, 7, a=0.3, b=0.6, col=LN)
        a.ink([(222, 132, 250, 122, 284, 122, 306, 134)], 7, a=0, b=0, col=LN)
        a.ink([(56, 290, 74, 300, 92, 300, 108, 290)], 8, a=0.6, b=0.2, col=LN)      # mouth
    with a.part(7):
        a.sil(d_circ(124, 226, 22, 22), TYL)
    a.dot(124, 226, 10, LN)
    return a


@word
def manjuu():
    a = Art()
    MJ, MJD, AN, ANL = "#fff6ea", "#eadcc4", "#5a3a34", "#7a524a"
    whole = "M40 330 C40 230 100 150 196 150 C292 150 352 230 352 330 C352 372 300 392 196 392 C92 392 40 372 40 330 Z"
    with a.part():
        a.sil(whole, MJ)
        a.blob(d_rim(whole, 60, 70, 30), MJD)
        a.blob(d_circ(196, 186, 22, 12), "#f7a8b3")
    a.shine("M84 290 C88 240 114 204 152 186", sw=9)
    half = "M268 444 C232 444 220 420 222 388 C226 310 280 250 352 250 C424 250 478 310 482 388 C484 420 472 444 436 444 Z"
    with a.part():
        a.sil(half, MJ)
        a.blob("M290 430 C262 430 250 414 252 388 C256 326 298 280 352 280 C406 280 448 326 452 388 C454 414 442 430 414 430 Z", AN)
        for x, y in ((300, 380), (350, 330), (404, 384), (350, 400), (322, 344), (384, 350)):
            a.blob(d_circ(x, y, 13, 8), ANL)
    return a


@word
def youkan():
    a = Art()
    YK, YKT, YKD, PL, PLD = "#6e2f3c", "#8f4656", "#55212c", "#dcebd6", "#bcd3b6"
    plate = e2_rr(30, 330, 452, 120, 40)
    with a.part():
        a.sil(plate, PL)
        a.blob(d_rim(plate, 80, 70, 20), PLD)
        a.blob(e2_rr(62, 352, 388, 62, 26), PLD)

    def block(x, y, w, h, dx, dy):
        with a.part():
            a.sil(e2_poly([(x, y), (x + dx, y - dy), (x + w + dx, y - dy), (x + w + dx, y + h - dy), (x + w, y + h), (x, y + h)]), YK)
            a.blob(e2_poly([(x, y), (x + dx, y - dy), (x + w + dx, y - dy), (x + w, y)]), YKT)
            a.blob(e2_poly([(x + w, y), (x + w + dx, y - dy), (x + w + dx, y + h - dy), (x + w, y + h)]), YKD)
            a.ink([e1_line(x + 2, y, x + w, y)], 6, a=1, b=1, col=YKD)
        a.path(f"M{x + 16} {y + 22} L{x + 16} {y + h - 30}", stroke=WHITE, sw=8, **{"stroke-opacity": "0.45"})

    block(170, 186, 220, 190, 60, 50)
    block(84, 250, 60, 150, 60, 50)
    with a.part(7):                                     # a wooden pick
        a.sil(e2_poly([(330, 420), (470, 396), (474, 408), (334, 434)]), "#d9a86a")
    return a


@word
def ohagi():
    a = Art()
    AN, AND, ANL, KI, KID = "#6d3d48", "#562c38", "#8f5a66", "#ecc674", "#d6a94e"
    plate = d_circ(256, 388, 232, 70)
    with a.part():
        a.sil(plate, "#fffaf0")
        a.blob(d_rim(plate, 80, 80, 18), "#e6dcc6")
        a.blob(d_circ(256, 380, 170, 40), "#eee5d0")
    k = [(230, 250), (250, 180), (310, 140), (380, 140), (440, 180), (458, 250), (440, 310), (380, 340), (310, 340), (250, 310)]
    d = f_lumpy(k, 8, 3)
    with a.part():                                      # きなこ（うしろ）
        a.sil(d, KI)
        a.blob(d_rim(d, 50, 75, 26), KID)
        for x, y in ((300, 200), (350, 180), (400, 210), (330, 250), (390, 270), (420, 250)):
            a.dot(x, y, 4, "#fbe6a8")
    k = [(54, 300), (74, 224), (136, 180), (206, 180), (270, 224), (290, 300), (270, 366), (206, 400), (136, 400), (74, 366)]
    d = f_lumpy(k, 12, 1)
    with a.part():                                      # つぶあん（まえ）
        a.sil(d, AN)
        a.blob(d_rim(d, 50, 75, 28), AND)
        for x, y, g in ((120, 230, -20), (180, 218, 10), (230, 262, 40), (100, 290, 60), (160, 280, 0), (214, 330, 20),
                        (130, 346, -30), (176, 366, 10)):
            a.blob(d_tf(d_circ(0, 0, 17, 11), 1, x, y, g), ANL)
            px, py = f_pt(-6, -4, 1, x, y, g)
            a.dot(px, py, 3.5, "#c79aa4")
    return a


@word
def yakiimo():
    a = Art()
    SK, SKD, YL, YLD, YLL = "#9a3f62", "#7f2f50", "#f9d55a", "#eab53a", "#fde994"
    f_steam(a, (150, 256, 362), y0=150, h=100)

    def half(T, flip):
        k = -1 if flip else 1
        skin = d_tf("M-150 0 C-150 -70 -80 -104 0 -104 C80 -104 150 -70 150 0 C150 60 100 150 0 196 "
                    "C-100 150 -150 60 -150 0 Z", **T)
        with a.part():
            a.sil(skin, SK)
            a.blob(d_rim(skin, 90 + T["deg"] - 30 * k, 60, 26), SKD)
        face = d_tf(d_circ(0, -6, 128, 80), **T)
        with a.part(7):
            a.sil(face, YL)
            a.blob(d_rim(face, 60, 80, 20), YLD)
            a.blob(d_tf(d_circ(-30, -26, 46, 22), **T), YLL)
            for c in ((-70, 10, -50, 22, -26, 26, -4, 22), (30, -10, 48, 2, 68, 4, 86, -2)):
                a.ink([f_tfc(c, **T)], 7, a=0, b=0, col=YLD)

    half(dict(s=0.94, dx=356, dy=300, deg=24), True)
    half(dict(s=1.0, dx=166, dy=300, deg=-20), False)
    return a


@word
def konpeitou():
    a = Art()

    def candy(cx, cy, r, col, dark, rot=0.0):
        d = a_wool(cx, cy, r * 0.84, r * 0.84, 11, start=rot, puff=0.5)
        with a.part():
            a.sil(d, col)
            a.blob(d_rim(d, 50, 80, r * 0.24), dark)
            a.blob(d_circ(cx, cy, r * 0.5), col)
        a.shine(f"M{cx - r * 0.46:.0f} {cy - r * 0.06:.0f} C{cx - r * 0.46:.0f} {cy - r * 0.3:.0f} {cx - r * 0.32:.0f} {cy - r * 0.46:.0f} {cx - r * 0.1:.0f} {cy - r * 0.5:.0f}", sw=8)

    candy(346, 146, 96, "#fff0a8", "#f2d66a", 0.2)
    candy(136, 170, 104, "#f9b6cf", "#f093b6", 0.0)
    candy(384, 356, 108, "#b8e2f7", "#8ccdf0", 0.4)
    candy(176, 384, 100, "#bfe8a8", "#98d47c", 0.1)
    candy(262, 262, 88, "#fffdf6", "#e2dccb", 0.3)
    return a


@word
def kashiwamochi():
    a = Art()
    LF, LFD, LFB, MO, MOD = "#6fae52", "#4f9040", "#5a9a46", "#fffaf0", "#ece2cc"
    with a.part():                                      # the back of the leaf peeks out behind the rice cake
        a.sil("M36 330 C16 290 40 262 72 270 L120 330 Z", LFB)
        a.sil("M476 330 C496 290 472 262 440 270 L392 330 Z", LFB)
        a.sil("M210 130 C220 96 292 96 302 130 L290 170 L222 170 Z", LFB)
    mochi = "M70 336 C58 204 150 112 256 112 C362 112 454 204 442 336 C420 380 92 380 70 336 Z"
    with a.part():
        a.sil(mochi, MO)
        a.blob(d_rim(mochi, 10, 60, 26), MOD)
    a.shine("M118 262 C128 216 156 180 196 160", sw=9)
    front = ("M50 322 C36 276 74 250 108 272 C118 226 190 222 206 262 C222 226 290 226 306 262 "
             "C322 222 394 226 404 272 C438 250 476 276 462 322 C448 396 360 444 256 444 C152 444 64 396 50 322 Z")
    with a.part():                                      # the leaf in front, folded up from below
        a.sil("M244 436 L268 436 L266 474 C266 482 246 482 246 474 Z", LFD)
        a.sil(front, LF)
        a.blob(d_rim(front, 80, 70, 26), LFD)
        a.ink([(256, 440, 254, 390, 254, 330, 256, 270)], 9, a=1, b=0, col=LFD)
        for s_ in (-1, 1):
            a.ink([(256, 420, 256 + s_ * 40, 390, 256 + s_ * 76, 330, 256 + s_ * 94, 282)], 7, a=0.6, b=0, col=LFD)
            a.ink([(256, 432, 256 + s_ * 80, 420, 256 + s_ * 150, 370, 256 + s_ * 178, 300)], 7, a=0.6, b=0, col=LFD)
    return a


# ------------------------------------------------------------------ はな --
def f_petals(a, cx, cy, R, n, rot=0.0, w=0.8, col=WHITE, notch=False):
    """n petals around (cx, cy) as shapes of the current part (one outline)."""
    for i in range(n):
        a.sil(petal(cx, cy, R, rot + i * 2 * math.pi / n, w=w, notch=notch), col)


def f_petal_lines(a, cx, cy, R, n, rot, col, r0=0.14, r1=0.5, w=7):
    """Short lines from the middle, between the petals."""
    for i in range(n):
        an = rot + (i + 0.5) * 2 * math.pi / n
        sx, sy = math.sin(an), -math.cos(an)
        a.ink([e1_line(cx + sx * R * r0, cy + sy * R * r0, cx + sx * R * r1, cy + sy * R * r1)], w, a=1, b=0, col=col)


@word
def ajisai():
    a = Art()
    B0, B0D, LF, LFD = "#7f9be8", "#6481d6", "#5aa650", "#3f8a44"
    with a.part():
        a.sil(taper([(256, 300, 256, 360, 256, 420, 256, 486)], 20, 20, cap=False), LFD)
    for bx, tx, ty, sk in ((246, 40, 420, -0.2), (266, 472, 420, 0.2)):
        with a.part():
            a.sil(d_leaf(bx, 372, tx, ty, 170, sk), LF)
            d_vein(a, bx, 374, tx, ty, LFD, t0=0.1, t1=0.8)
            for t in (0.36, 0.58):
                mx, my = bx + (tx - bx) * t, 374 + (ty - 374) * t
                k = 1 if tx > bx else -1
                a.ink([e1_line(mx, my, mx + k * 30, my - 34)], 6, a=1, b=0, col=LFD)
                a.ink([e1_line(mx, my, mx + k * 16, my + 36)], 6, a=1, b=0, col=LFD)
    ball = a_wool(256, 200, 172, 148, 11, start=0.3, puff=0.46)
    with a.part():
        a.sil(ball, B0)
        a.blob(d_rim(ball, 60, 80, 30), B0D)
        flo = [(256, 196, "#b3c6f8"), (160, 150, "#c9b0f2"), (352, 150, "#c9b0f2"), (150, 250, "#a3bdf6"),
               (362, 250, "#a3bdf6"), (256, 94, "#a3bdf6"), (256, 298, "#c9b0f2"), (88, 200, "#b3c6f8"), (424, 200, "#b3c6f8")]
        for i, (x, y, c) in enumerate(flo):
            R = 52 if i < 7 else 38
            for k in range(4):
                a.blob(petal(x, y, R, math.radians(45 + k * 90 + i * 20), w=0.95, notch=False), c)
            a.dot(x, y, 7, "#fff4b0")
    a.shine("M118 150 C132 116 158 90 192 76", sw=9)
    return a


@word
def sumire():
    a = Art()
    V, VD, VL, LF, LFD = "#8d68d8", "#7350c4", "#b79df0", "#63b058", "#46964a"
    with a.part(9):                                     # stems
        a.sil(taper([(246, 470, 236, 380, 200, 300, 176, 226)], 12, 10), LFD)
        a.sil(taper([(266, 470, 290, 400, 330, 330, 350, 276)], 12, 10), LFD)
    HEART = "M0 -50 C8 -74 30 -92 62 -76 C108 -50 96 40 0 86 C-96 40 -108 -50 -62 -76 C-30 -92 -8 -74 0 -50 Z"
    for x, y, s_, deg in ((112, 402, 1.0, 50), (404, 410, 0.95, -52), (256, 418, 0.8, 0)):
        d = d_tf(HEART, s_, x, y, deg)
        with a.part():
            a.sil(d, LF)
            a.blob(d_rim(d, 90, 70, 16 * s_), LFD)
            a.ink([f_tfc((0, -44, 0, -10, 0, 30, 0, 66), s_, x, y, deg)], 7, a=1, b=0, col=LFD)

    def bloom(cx, cy, s_, deg):
        T = dict(s=s_, dx=cx, dy=cy, deg=deg)
        with a.part():
            for d in (d_circ(-40, -56, 46, 52), d_circ(40, -56, 46, 52)):
                a.sil(d_tf(d, **T), VD)
        with a.part():
            for d in (d_circ(-64, 12, 50, 42), d_circ(64, 12, 50, 42)):
                a.sil(d_tf(d, **T), V)
            a.sil(d_tf("M0 -10 C40 -10 62 26 58 64 C54 96 28 112 0 112 C-28 112 -54 96 -58 64 C-62 26 -40 -10 0 -10 Z", **T), V)
            a.blob(d_tf("M0 -6 C22 -6 34 14 30 40 C26 62 12 70 0 70 C-12 70 -26 62 -30 40 C-34 14 -22 -6 0 -6 Z", **T), VL)
            a.blob(d_tf("M0 -8 C14 -8 20 4 18 20 C16 32 8 36 0 36 C-8 36 -16 32 -18 20 C-20 4 -14 -8 0 -8 Z", **T), WHITE)
            for c in ((0, 26, 0, 40, 0, 56, 0, 72), (-10, 24, -14, 36, -18, 48, -22, 58), (10, 24, 14, 36, 18, 48, 22, 58)):
                a.ink([f_tfc(c, **T)], 5, a=0.6, b=0, col=VD)
            a.ink([f_tfc((-22, 0, -40, 10, -52, 30, -54, 50), **T)], 7, a=1, b=0, col=VD)
            a.ink([f_tfc((22, 0, 40, 10, 52, 30, 54, 50), **T)], 7, a=1, b=0, col=VD)
        px, py = f_pt(0, 2, **T)
        a.dot(px, py, 9 * s_, "#f7c948")

    bloom(170, 156, 1.18, -8)
    bloom(356, 232, 0.92, 10)
    return a


@word
def yuri():
    a = Art()
    WH, PK, PKD, LF, LFD = "#fffaf4", "#fbd6de", "#f2a3b6", "#63b058", "#46964a"
    with a.part():
        a.sil(taper([(256, 250, 262, 330, 256, 410, 256, 490)], 20, 20, cap=False), LFD)
        a.sil(taper([(256, 420, 300, 380, 344, 330, 372, 262)], 12, 10), LFD)
    for bx, by, tx, ty, w in ((256, 400, 96, 330, 62), (256, 452, 430, 430, 60), (256, 462, 90, 452, 56)):
        with a.part():
            a.sil(d_leaf(bx, by, tx, ty, w), LF)
            d_vein(a, bx, by, tx, ty, LFD, t0=0.1, t1=0.8)
    with a.part():                                      # a bud
        a.sil(d_leaf(372, 276, 400, 150, 74), "#eaf2c8")
        d_vein(a, 372, 276, 400, 150, "#b9cf8a", t0=0.2, t1=0.8)
    cx, cy, R = 232, 186, 178
    for rot, col in ((30, "#f6ecdf"), (-30, WH)):       # three petals behind, three in front
        with a.part():
            for i in range(3):
                an = math.radians(rot + i * 120)
                tx, ty = cx + R * math.sin(an), cy - R * math.cos(an)
                a.sil(d_leaf(cx, cy, tx, ty, 150), col)
            for i in range(3):
                an = math.radians(rot + i * 120)
                tx, ty = cx + R * math.sin(an), cy - R * math.cos(an)
                a.blob(d_leaf(cx, cy, cx + (tx - cx) * 0.56, cy + (ty - cy) * 0.56, 60), PK)
                d_vein(a, cx, cy, tx, ty, PKD, w=7, t0=0.16, t1=0.8)
    for i in range(6):                                  # stamens
        an = math.radians(i * 60 + 12)
        x1, y1 = cx + 62 * math.sin(an), cy - 62 * math.cos(an)
        a.ink([e1_line(cx, cy, x1, y1)], 6, a=1, b=1, col="#9ac46a")
        with a.part(5):
            a.sil(d_tf(d_circ(0, 0, 14, 8), 1, x1, y1, math.degrees(an)), "#e8843a")
    a.dot(cx, cy, 14, "#b9d47a")
    return a


@word
def tsubaki():
    a = Art()
    RD, RL, RDD, LF, LFD, LFL = "#e2404f", "#ee6a74", "#c62d40", "#3f9450", "#2f7a42", "#63b46e"
    for bx, by, tx, ty, sk in ((230, 330, 44, 440, -0.15), (282, 330, 468, 440, 0.15), (200, 150, 60, 44, 0.1)):
        with a.part():
            a.sil(d_leaf(bx, by, tx, ty, 150, sk), LF)
            d_vein(a, bx, by, tx, ty, LFL, t0=0.2, t1=0.84)
    cx, cy = 268, 226

    def lobes(R, rot, k=0.9, n=5):
        pts = []
        for i in range(2 * n):
            t = math.radians(rot) + i * math.pi / n
            rr = R * (1.0 if i % 2 == 0 else k)
            pts.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
        return smooth(pts)

    outer = lobes(168, -90, 0.9)
    with a.part():
        a.sil(outer, RD)
        a.blob(d_rim(outer, 60, 80, 26), RDD)
        for i in range(5):
            t = math.radians(-54 + i * 72)
            pts = [(cx + r * math.cos(t + k), cy + r * math.sin(t + k)) for r, k in ((154, 0), (136, 0.08), (116, 0.2), (98, 0.36))]
            a.ink(d_curve(pts), 9, a=1, b=0)
        inner = lobes(104, -54, 0.9)
        a.blob(inner, RL)
        for i in range(5):
            t = math.radians(-18 + i * 72)
            a.ink([e1_line(cx + 96 * math.cos(t), cy + 96 * math.sin(t), cx + 60 * math.cos(t), cy + 60 * math.sin(t))], 8, a=0.6, b=0, col=RDD)
    with a.part(8):                                     # the tuft of yellow stamens
        puck = a_wool(cx, cy, 44, 44, 10, puff=0.3)
        a.sil(puck, "#f9d55a")
        a.blob(d_circ(cx, cy, 30), "#fbe38a")
        for i in range(8):
            t = i * math.pi / 4
            a.dot(cx + 26 * math.cos(t), cy + 26 * math.sin(t), 5, "#e9a92a")
        a.dot(cx, cy, 6, "#e9a92a")
    a.shine("M146 190 C156 146 184 112 224 96", sw=9)
    return a


@word
def ume():
    a = Art()
    BR, BRD, PK, PKD = "#7a5240", "#5f3d2e", "#f7a3c0", "#e56f97"
    with a.part():
        a.sil(taper([(40, 480, 110, 430, 150, 380, 210, 340)], 40, 30, cap=False), BR)
        a.sil(taper([(200, 344, 260, 330, 300, 330, 350, 300)], 30, 24, cap=False), BR)
        a.sil(taper([(340, 304, 390, 260, 430, 200, 470, 120)], 24, 12), BR)
        a.sil(taper([(206, 344, 196, 280, 170, 220, 160, 150)], 22, 12), BR)
        a.blob(taper([(60, 478, 120, 436, 160, 392, 214, 352)], 12, 10, cap=False), BRD)
        a.ink([(130, 410, 140, 398, 150, 392, 162, 390)], 7, a=0, b=0, col=BRD)

    def bud(x, y, r):
        with a.part(8):
            a.sil(d_circ(x, y, r), "#f08aae")
            a.blob(d_circ(x - r * 0.3, y - r * 0.3, r * 0.3), "#f9c0d4")
        with a.part(7):
            a.sil(f"M{x - r} {y + r * 0.2} C{x - r * 0.4} {y + r * 1.3} {x + r * 0.4} {y + r * 1.3} {x + r} {y + r * 0.2} C{x + r * 0.4} {y + r * 0.7} {x - r * 0.4} {y + r * 0.7} {x - r} {y + r * 0.2} Z", "#a8553a")

    bud(278, 300, 24)
    bud(452, 134, 20)
    bud(96, 414, 22)

    def bloom(cx, cy, R, rot):
        with a.part():
            f_petals(a, cx, cy, R, 5, rot, w=1.0, col=PK)
            f_petal_lines(a, cx, cy, R, 5, rot, PKD, r0=0.2, r1=0.56, w=R * 0.09)
            a.blob(d_circ(cx, cy, R * 0.24), "#f9d7e4")
            for i in range(10):                         # long stamens with yellow tips
                an = rot + i * math.pi / 5
                x1, y1 = cx + R * 0.5 * math.sin(an), cy - R * 0.5 * math.cos(an)
                a.ink([e1_line(cx, cy, x1, y1)], R * 0.045, a=1, b=1, col=PKD)
                a.dot(x1, y1, R * 0.06, "#f7c948")
            a.dot(cx, cy, R * 0.09, "#e56f97")

    bloom(150, 150, 104, 0.2)
    bloom(350, 232, 112, 0.5)
    return a


@word
def nanohana():
    a = Art()
    Y, YD, LF, LFD, BUD = "#fbdc4a", "#eab82a", "#7cc36a", "#4f9e48", "#a9d46a"
    with a.part():
        a.sil(taper([(256, 190, 252, 290, 260, 390, 256, 490)], 22, 22, cap=False), LFD)
    for bx, by, tx, ty, sk in ((250, 430, 78, 330, -0.3), (262, 458, 440, 372, 0.3), (252, 350, 150, 268, -0.2)):
        with a.part():
            a.sil(d_leaf(bx, by, tx, ty, 110, sk), LF)
            d_vein(a, bx, by, tx, ty, LFD, t0=0.12, t1=0.8)
    with a.part(9):                                     # buds at the very top
        for x, y in ((230, 60), (282, 60), (256, 40), (206, 84), (306, 84)):
            a.sil(d_circ(x, y, 22, 26), BUD)

    def bloom(cx, cy, R, rot):
        with a.part():
            f_petals(a, cx, cy, R, 4, rot, w=1.1, col=Y)
            f_petal_lines(a, cx, cy, R, 4, rot, YD, r0=0.16, r1=0.5, w=7)
            a.dot(cx, cy, R * 0.2, "#b9d05a")
            a.dot(cx, cy, R * 0.09, "#7a9a2a")

    bloom(150, 196, 66, 0.3)
    bloom(362, 196, 66, 0.5)
    bloom(190, 110, 62, 0.8)
    bloom(322, 110, 62, 0.1)
    bloom(256, 218, 74, 0.785)
    bloom(256, 132, 60, 0.4)
    return a


@word
def suisen():
    a = Art()
    WH, WHD, CUP, CUPD, LF, LFD = "#fffdf0", "#efe6c8", "#f9b233", "#e98f1a", "#63b058", "#46964a"
    with a.part():
        a.sil(d_blade(150, 486, 46, 60, 190), LFD)
        a.sil(d_blade(372, 486, 46, 470, 230), LFD)
    with a.part():
        a.sil(taper([(240, 486, 236, 400, 220, 320, 200, 250)], 16, 14, cap=False), LF)
        a.sil(taper([(272, 486, 290, 380, 330, 280, 356, 200)], 16, 14, cap=False), LF)
    with a.part():
        a.sil(d_blade(206, 486, 50, 150, 110), LF)
        a.sil(d_blade(310, 486, 50, 420, 300), LF)
        a.ink([(204, 470, 198, 380, 184, 280, 162, 170)], 7, a=0, b=0, col=LFD)

    def bloom(cx, cy, R, rot):
        with a.part():
            f_petals(a, cx, cy, R, 6, rot, w=0.86, col=WH)
            for i in range(6):
                a.blob(petal(cx, cy, R * 0.62, rot + i * math.pi / 3, w=0.5), WHD)
            f_petal_lines(a, cx, cy, R, 6, rot, "#d9cda4", r0=0.3, r1=0.6, w=6)
        with a.part(8):
            cup = a_wool(cx, cy, R * 0.34, R * 0.34, 9, puff=0.34)
            a.sil(cup, CUP)
            a.blob(d_circ(cx, cy, R * 0.22), CUPD)
            a.dot(cx, cy, R * 0.07, "#fbe38a")

    bloom(356, 150, 100, 0.26)
    bloom(190, 200, 128, 0.0)
    return a


# --------------------------------------------------------- き・くさ・きのこ --
@word
def ki():
    a = Art()
    G1, G2, G3 = LEAF1, LEAF2, "#8fd070"
    trunk = "M220 290 L292 290 C292 380 304 430 346 470 L166 470 C208 430 220 380 220 290 Z"
    with a.part():
        a.sil(trunk, BARK)
        a.blob("M262 290 L292 290 C292 380 304 430 346 470 L300 470 C272 430 262 380 262 290 Z", BARK_D)
        a.ink([(236, 400, 240, 380, 242, 360, 240, 340)], 7, a=0, b=0, col=BARK_D)
    crown = ("M92 252 C40 232 40 160 94 142 C88 80 166 40 222 74 C254 24 348 30 364 92 "
             "C428 84 472 150 438 200 C482 234 458 302 402 300 C374 334 300 334 276 304 "
             "C240 336 168 330 146 296 C114 298 92 278 92 252 Z")
    with a.part():
        a.sil(crown, G1)
        a.blob(d_rim(crown, 70, 80, 34), G2)
        a.ink([(94, 144, 110, 150, 124, 162, 130, 178)], 9, a=1, b=0, col=G2)
        a.ink([(222, 76, 228, 92, 226, 108, 218, 122)], 9, a=1, b=0, col=G2)
        a.ink([(364, 94, 352, 106, 346, 120, 348, 136)], 9, a=1, b=0, col=G2)
        a.ink([(436, 202, 420, 204, 406, 212, 398, 226)], 9, a=1, b=0, col=G2)
        a.ink([(276, 302, 272, 286, 262, 274, 248, 268)], 9, a=1, b=0, col=G2)
        for x, y in ((160, 200), (250, 150), (330, 210), (210, 250)):
            a.blob(d_tf(d_leaf(0, 0, 44, -20, 30), 1, x, y, 0), G3)
    a.shine("M104 196 C108 160 132 132 166 122", sw=9)
    return a


@word
def take():
    a = Art()
    G1, G2, G3, LF, LFD = "#7cc36a", "#5fa851", "#a9de92", "#63b058", "#46964a"

    def leaves(x, y, k):
        with a.part(9):
            a.sil(taper([(x, y, x + k * 30, y - 16, x + k * 56, y - 24, x + k * 80, y - 28)], 9, 7), LFD)
            for tx, ty in ((k * 170, -86), (k * 190, -20), (k * 150, 36)):
                a.sil(d_leaf(x + k * 70, y - 26, x + tx, y + ty, 44), LF)
            for tx, ty in ((k * 170, -86), (k * 190, -20), (k * 150, 36)):
                d_vein(a, x + k * 70, y - 26, x + tx, y + ty, LFD, w=5, t0=0.1, t1=0.75)

    leaves(140, 160, -1)
    leaves(380, 250, 1)
    leaves(262, 96, 1)

    def culm(x, top, w, col, dark):
        ys = list(range(476, top, -106))
        with a.part():
            for i, y in enumerate(ys):
                y0 = max(top, y - 100)
                a.sil(e2_rr(x - w / 2, y0, w, y - y0, 9), col)
            for i, y in enumerate(ys):
                y0 = max(top, y - 100)
                a.blob(e2_rr(x + w * 0.16, y0, w * 0.34, y - y0, 8), dark)
                a.blob(e2_rr(x - w * 0.34, y0 + 12, w * 0.14, max(8, y - y0 - 24), 4), G3)

    culm(140, 60, 66, G1, G2)
    culm(384, 150, 60, G1, G2)
    culm(262, 20, 80, G1, G2)
    return a


@word
def takenoko():
    a = Art()
    S1, S1D, S1L, TIP, TIPD, BASE = "#c08a50", "#99673a", "#d6a468", "#7cc36a", "#5fa851", "#f6e2b0"
    body = ("M256 36 C296 96 404 250 404 372 C404 440 344 468 256 468 C168 468 108 440 108 372 "
            "C108 250 216 96 256 36 Z")
    P = d_poly(body, 40)

    def edge(y, side):
        """x of the outline at height y (side: -1 left, 1 right)."""
        xs = [p[0] for p in P if abs(p[1] - y) < 9 and (p[0] - 256) * side > 0]
        return (max(xs) if side > 0 else min(xs)) if xs else 256

    tips = [(1, 132), (-1, 196), (1, 262), (-1, 326)]
    with a.part(9):                                     # green tips of the sheaths, poking out of the outline
        a.sil(d_leaf(256, 70, 262, 4, 40), TIP)
        for k, y in tips:
            x = edge(y, k)
            a.sil(d_leaf(x - k * 14, y + 16, x + k * 30, y - 44, 40), TIP)
    with a.part():
        a.sil(body, S1)
        a.blob(d_rim(body, 30, 60, 30), S1D)
        a.blob("M108 380 C150 404 362 404 404 380 C400 440 344 468 256 468 C168 468 112 440 108 380 Z", BASE)
        for x in (150, 192, 234, 278, 320, 362):
            a.dot(x, 432 - abs(x - 256) * 0.06, 7, "#b0486a")
        a.ink([(110, 380, 160, 404, 352, 404, 402, 380)], 7, a=1, b=1)
        a.blob("M256 40 C268 58 280 76 290 96 L222 96 C232 76 244 58 256 40 Z", TIP)
        ys = [y for _, y in tips] + [384]
        for i, (k, y) in enumerate(tips):               # each sheath wraps across the shoot, down to the next tip
            x0 = edge(y, k)
            y1 = ys[i + 1]
            x1 = edge(y1, -k)
            c = (x0, y, x0 - k * 70, y + 4, x1 + k * 90, y1 - 30, x1, y1)
            sh = (x0, y + 12, x0 - k * 70, y + 18, x1 + k * 90, y1 - 14, x1, y1 + 10)
            a.ink([sh], 16, a=0.5, b=0.5, col=S1D)
            a.ink([c], 8, a=1, b=1)
        a.ink([(236, 110, 230, 130, 226, 150, 224, 168)], 7, a=0, b=0, col=S1D)
    a.shine("M206 226 C192 262 180 300 174 340", sw=9)
    return a


def f_momiji(a, cx, cy, s, deg, col, dark, stem=True):
    """A maple leaf: seven pointed lobes in one outline, veins from the middle."""
    T = dict(s=s, dx=cx, dy=cy, deg=deg)
    lobes = [(0, 200, 96), (44, 184, 88), (-44, 184, 88), (90, 150, 80), (-90, 150, 80), (136, 96, 60), (-136, 96, 60)]
    with a.part(max(7, 11 * min(1, s + 0.2))):
        if stem:
            a.sil(d_tf(taper([(0, 20, 4, 70, 0, 110, -14, 150)], 12, 10), **T), "#a8553a")
        for an, L, w in lobes:
            t = math.radians(an)
            a.sil(d_tf(d_leaf(0, 10, L * math.sin(t), 10 - L * math.cos(t), w), **T), col)
        a.sil(d_tf(d_circ(0, 10, 50), **T), col)
        for an, L, w in lobes:
            t = math.radians(an)
            a.ink([f_tfc(e1_line(0, 10, L * 0.8 * math.sin(t), 10 - L * 0.8 * math.cos(t)), **T)], 7 * s, a=1, b=0, col=dark)


def f_ichou(a, cx, cy, s, deg, col, dark, light):
    """A ginkgo leaf: a fan with a notch in the middle."""
    T = dict(s=s, dx=cx, dy=cy, deg=deg)
    fan = ("M0 80 C-50 40 -150 10 -196 -66 C-176 -130 -90 -166 -16 -150 L0 -92 L16 -150 "
           "C90 -166 176 -130 196 -66 C150 10 50 40 0 80 Z")
    d = d_tf(fan, **T)
    with a.part(max(7, 11 * min(1, s + 0.2))):
        a.sil(d_tf(taper([(0, 60, 0, 110, 8, 150, 26, 190)], 18, 12), **T), dark)
        a.sil(d, col)
        a.blob(d_tf("M-196 -66 C-176 -130 -90 -166 -16 -150 L-10 -128 C-80 -140 -150 -112 -176 -60 Z", **T), light)
        for tx, ty in ((-150, -70), (-96, -118), (-40, -124), (40, -124), (96, -118), (150, -70)):
            a.ink([f_tfc((0, 70, tx * 0.2, 30, tx * 0.6, ty * 0.5, tx, ty), **T)], 6 * s, a=0.8, b=0, col=dark)


@word
def momiji():
    a = Art()
    f_momiji(a, 372, 356, 0.52, 28, "#f39a3c", "#d97a22")
    f_momiji(a, 226, 236, 1.08, -10, "#e8503f", "#c43a30")
    a.shine("M150 250 C140 220 136 190 138 164", sw=8)
    return a


@word
def ichou():
    a = Art()
    f_ichou(a, 376, 366, 0.5, 30, "#f6c13a", "#d99a1c", "#fbdc72")
    f_ichou(a, 230, 226, 1.05, -8, "#f9d24a", "#e0a422", "#fde68a")
    return a


@word
def matsubokkuri():
    a = Art()
    C1, C2, C3 = "#a8703f", "#8a5830", "#cf9a62"
    with a.part():                                      # a sprig of needles behind
        for tx, ty in ((440, 80), (470, 130), (482, 190), (404, 48)):
            a.sil(taper([(330, 150, 370, 140, 410, 120, tx, ty)], 10, 5), LEAF2)
    with a.part():
        a.sil(e2_rr(240, 36, 32, 60, 10), C2)
    rows = [(404, 60, 2), (350, 112, 3), (292, 142, 4), (232, 146, 4), (172, 122, 3), (120, 80, 2)]
    with a.part():                                      # the core, so no gaps show between the scales
        a.sil(d_circ(256, 262, 126, 170), C2)
    for y, hw, n in rows:                               # scales like roof tiles: lower rows first
        for i in range(n):
            x = 256 + (i - (n - 1) / 2) * (2 * hw / max(n - 1, 1)) * (0.5 if n > 1 else 0) * 2 * 0.5 if n > 1 else 256
            x = 256 + (i - (n - 1) / 2) * (hw * 2 / n)
            w = hw * 2 / n * 0.62 + 10
            d = (f"M{x - w} {y - 30} C{x - w} {y - 56} {x + w} {y - 56} {x + w} {y - 30} "
                 f"C{x + w} {y + 10} {x + w * 0.4} {y + 34} {x} {y + 34} C{x - w * 0.4} {y + 34} {x - w} {y + 10} {x - w} {y - 30} Z")
            with a.part(8):
                a.sil(d, C1)
                a.blob(f"M{x - w * 0.7} {y + 8} C{x - w * 0.3} {y + 30} {x + w * 0.3} {y + 30} {x + w * 0.7} {y + 8} "
                       f"C{x + w * 0.3} {y + 18} {x - w * 0.3} {y + 18} {x - w * 0.7} {y + 8} Z", C3)
                a.blob(d_circ(x + w * 0.5, y - 16, w * 0.3, 20), C2)
    return a


@word
def tsukushi():
    a = Art()
    ST, STD, HK, HD, HDD = "#f3ddb0", "#e0c48c", "#8f6a48", "#c99a62", "#8f6a3c"
    for x0, tx, ty, w in ((70, 40, 400, 30), (120, 150, 380, 28), (400, 430, 390, 30), (450, 482, 410, 26), (300, 320, 404, 24)):
        a.sil(d_blade(x0, 480, w, tx, ty), LEAF1)

    def stalk(x, top, lean, s=1.0):
        w = 38 * s
        xt = x + lean
        with a.part():
            a.sil(taper([(x, 480, x, 400, xt, top + 200, xt, top + 96)], w, w * 0.8, cap=False), ST)
            a.blob(taper([(x + w * 0.24, 480, x + w * 0.24, 400, xt + w * 0.2, top + 200, xt + w * 0.2, top + 96)], w * 0.3, w * 0.26, cap=False), STD)
        n = int((480 - top - 120) // 90)
        for i in range(n):                              # はかま（ぎざぎざの えり）
            y = 440 - i * 90
            xx = x + lean * min(1, max(0, (400 - y) / max(1, 400 - top - 200))) if y < 400 else x
            hw = w * 0.62
            pts = [(xx - hw, y), (xx - hw - 6, y - 44), (xx - hw * 0.5, y - 26), (xx, y - 50), (xx + hw * 0.5, y - 26),
                   (xx + hw + 6, y - 44), (xx + hw, y)]
            with a.part(8):
                a.sil(e2_poly(pts), HK)
        head = d_circ(xt, top + 62, 40 * s, 70 * s)
        with a.part():
            a.sil(head, HD)
            a.blob(d_rim(head, 30, 70, 14 * s), "#b08450")
            for r in range(5):
                for c in range(3 if r % 2 else 2):
                    px = xt + (c - (1 if r % 2 else 0.5)) * 24 * s
                    py = top + 20 * s + r * 22 * s
                    a.dot(px, py, 6 * s, HDD)

    stalk(380, 210, 14, 0.86)
    stalk(140, 150, -10, 0.92)
    stalk(256, 30, 4, 1.06)
    return a


# ---------------------------------------------------------------- しぜん --
@word
def iwa():
    a = Art()
    R1, R1L, R1D, R1DD, MOSS, MOSSD = "#b9b0a4", "#d6cfc6", "#968c80", "#7f766c", "#7cc36a", "#5fa851"
    small = [(30, 452), (48, 368), (104, 330), (164, 352), (190, 452)]
    with a.part():
        a.sil(e2_poly(small), R1)
        a.blob(e2_poly([(48, 368), (104, 330), (164, 352), (112, 380)]), R1L)
        a.blob(e2_poly([(164, 352), (190, 452), (130, 452), (112, 380)]), R1D)
    big = [(112, 452), (128, 262), (206, 124), (318, 76), (420, 150), (478, 320), (466, 452)]
    with a.part():
        a.sil(e2_poly(big), R1)
        a.blob(e2_poly([(128, 262), (206, 124), (318, 76), (300, 190), (212, 280)]), R1L)
        a.blob(e2_poly([(318, 76), (420, 150), (478, 320), (466, 452), (380, 452), (372, 300), (300, 190)]), R1D)
        a.blob(e2_poly([(372, 300), (478, 320), (466, 452), (380, 452)]), R1DD)
        a.ink([e1_line(212, 280, 300, 190)], 7, a=0.4, b=0.4, col=R1D)
        a.ink([(212, 280, 220, 330, 206, 380, 222, 450)], 8, a=0.4, b=1)
        a.ink([(300, 190, 330, 240, 360, 270, 372, 300)], 7, a=0.4, b=0.2, col=R1DD)
    moss = ("M196 140 L206 124 L318 76 L420 150 L432 184 C416 200 396 180 380 190 C362 204 344 176 322 180 "
            "C300 184 290 156 268 158 C244 160 234 186 212 176 C200 170 194 154 196 140 Z")
    with a.part():
        a.sil(moss, MOSS)
        a.blob("M318 76 L420 150 L432 184 C416 200 396 180 380 190 C372 150 350 110 318 76 Z", MOSSD)
    with a.part(9):
        a.sil(d_blade(420, 452, 26, 448, 380), LEAF2)
        a.sil(d_blade(444, 452, 26, 486, 400), LEAF1)
        a.sil(d_blade(398, 452, 24, 386, 404), LEAF1)
    a.shine("M150 270 L196 186", sw=9)
    return a


@word
def mori():
    a = Art()
    D1, D1D, D2, D2D, G1, G1D = "#3f9458", "#2f7a48", "#57a862", "#43904e", "#7cc36a", "#5fa851"
    PINE = "M0 -210 L78 -96 L44 -96 L108 12 L66 12 L128 118 L-128 118 L-66 12 L-108 12 L-44 -96 L-78 -96 Z"

    def pine(x, y, s_, col, dark):
        with a.part():
            a.sil(e2_rr(x - 16 * s_, y + 100 * s_, 32 * s_, 80 * s_, 6), BARK_D)
            a.sil(d_tf(PINE, s_, x, y), col)
            a.blob(d_tf("M0 -210 L78 -96 L44 -96 L108 12 L66 12 L128 118 L40 118 L24 12 L44 12 L10 -96 L26 -96 Z", s_, x, y), dark)

    pine(120, 240, 0.9, D2, D2D)
    pine(400, 250, 0.86, D2, D2D)
    pine(256, 232, 1.08, D1, D1D)

    def round_tree(x, y, s_):
        with a.part():
            a.sil(e2_rr(x - 18 * s_, y + 40 * s_, 36 * s_, 110 * s_, 6), BARK)
        crown = d_tf("M-104 26 C-140 -6 -116 -66 -70 -66 C-60 -120 30 -136 62 -90 C112 -96 140 -34 106 4 "
                     "C124 44 84 82 40 66 C10 96 -50 92 -64 60 C-92 64 -110 48 -104 26 Z", s_, x, y)
        with a.part():
            a.sil(crown, G1)
            a.blob(d_rim(crown, 70, 80, 24 * s_), G1D)
            a.ink([f_tfc((-70, -64, -58, -58, -50, -46, -48, -32), s_, x, y)], 8, a=1, b=0, col=G1D)
            a.ink([f_tfc((62, -88, 54, -76, 52, -62, 56, -48), s_, x, y)], 8, a=1, b=0, col=G1D)

    round_tree(180, 330, 0.9)
    round_tree(346, 340, 0.82)
    ground = "M20 470 C40 430 120 420 180 436 C230 420 300 420 340 438 C400 420 472 432 492 470 Z"
    with a.part():
        a.sil(ground, "#8fd08a")
        a.blob("M250 470 C300 446 360 440 420 448 C456 452 480 460 492 470 Z", "#74bd72")
    return a


@word
def shima():
    a = Art()
    W1, W1D, SAND, SANDD, TR, TRD, PL, PLD = "#6cc0ec", "#4fa9dc", "#f7e2a4", "#e9c878", "#b98452", "#96673c", "#55b060", "#3d9150"
    sea = d_circ(256, 404, 240, 74)
    with a.part():
        a.sil(sea, W1)
        a.blob(d_rim(sea, 90, 85, 24), W1D)
        a.ink([(50, 414, 80, 430, 112, 442, 150, 448)], 8, col=WHITE)
        a.ink([(350, 456, 394, 450, 430, 438, 456, 420)], 8, col=WHITE)
    sand = "M76 398 C92 300 180 258 268 258 C356 258 428 306 440 398 C390 426 126 426 76 398 Z"
    with a.part():
        a.sil(sand, SAND)
        a.blob(d_rim(sand, 60, 70, 26), SANDD)
        for x, y in ((170, 340), (230, 380), (330, 356), (140, 390)):
            a.dot(x, y, 5, SANDD)
    trunk = [(300, 310, 296, 250, 270, 180, 236, 124)]
    with a.part():
        a.sil(taper(trunk, 44, 28, cap=False), TR)
        for t in (0.2, 0.4, 0.6, 0.8):
            from lib import at
            x0, y0 = at(trunk, t, -17 + t * 4)
            x1, y1 = at(trunk, t, 17 - t * 4)
            a.ink([(x0, y0, x0 + (x1 - x0) * 0.3, y0 + 8, x0 + (x1 - x0) * 0.7, y1 + 8, x1, y1)], 6, a=1, b=1, col=TRD)
    top = (236, 118)
    for tx, ty, w, sk, col in ((70, 150, 70, -0.5, PLD), (420, 170, 70, 0.5, PLD), (120, 40, 66, -0.3, PL),
                               (380, 50, 66, 0.3, PL), (250, 6, 60, 0, PL)):
        with a.part():
            a.sil(d_leaf(top[0], top[1], tx, ty, w, sk), col)
            d_vein(a, top[0], top[1], tx, ty, "#2f7a42", w=6, t0=0.1, t1=0.8)
    with a.part(8):
        a.sil(d_circ(222, 136, 20), "#8a5a34")
        a.sil(d_circ(256, 138, 20), "#9a6a3c")
    a.shine("M112 370 C124 330 150 302 186 288", sw=9)
    return a


@word
def hatake():
    a = Art()
    SO, SOD, RG, RGD, RGL, LF, LFD = "#9a6a42", "#7f5432", "#bd8a5a", "#a17044", "#d3a474", "#6fbd5c", "#4f9e48"
    base = e2_rr(26, 150, 460, 320, 44)
    with a.part():
        a.sil(base, SO)
        a.blob(d_rim(base, 80, 80, 26), SOD)
    for i, y in enumerate((196, 296, 396)):
        ridge = e2_rr(52, y - 34, 408, 68, 34)
        with a.part():
            a.sil(ridge, RG)
            a.blob(e2_rr(60, y + 4, 392, 28, 14), RGD)
            a.blob(e2_rr(84, y - 26, 300, 12, 6), RGL)
        for x in (112, 208, 304, 400):
            x += (i % 2) * 0
            with a.part(8):                             # a sprout: two leaves on a short stem
                a.sil(e2_rr(x - 5, y - 40, 10, 34, 4), LFD)
                a.sil(d_leaf(x, y - 36, x - 40, y - 78, 34, -0.3), LF)
                a.sil(d_leaf(x, y - 36, x + 40, y - 78, 34, 0.3), LF)
                a.ink([e1_line(x, y - 40, x - 28, y - 68)], 5, a=1, b=0, col=LFD)
                a.ink([e1_line(x, y - 40, x + 28, y - 68)], 5, a=1, b=0, col=LFD)
    return a


@word
def kaigara():
    a = Art()
    S1, S1D, S1L, RIB = "#fbcfc0", "#f2a896", "#fde6dc", "#ec9482"
    hx, hy, R = 216, 420, 330
    n = 7
    pts = []
    a0, a1 = -152, -28
    for i in range(2 * n + 1):
        t = math.radians(a0 + (a1 - a0) * i / (2 * n))
        r = R * (0.95 if i % 2 == 0 else 1.0)
        pts.append((hx + r * math.cos(t), hy + r * math.sin(t)))
    top = smooth(pts, closed=False)
    (lx, ly), (rx, ry) = pts[0], pts[-1]
    fan = (top + f" C{rx - 10} {ry + 70} {hx + 110} {hy - 40} {hx + 54} {hy - 8} L{hx + 70} {hy + 26} L{hx - 70} {hy + 26} "
           f"L{hx - 54} {hy - 8} C{hx - 110} {hy - 40} {lx + 10} {ly + 70} {lx} {ly} Z")
    with a.part():
        a.sil(fan, S1)
        a.blob(e2_poly([(hx - 54, hy - 8), (hx + 54, hy - 8), (hx + 70, hy + 26), (hx - 70, hy + 26)]), S1D)
        for i in range(0, 2 * n + 1, 2):
            t = math.radians(a0 + (a1 - a0) * i / (2 * n))
            a.ink([e1_line(hx + 60 * math.cos(t), hy + 60 * math.sin(t) + 20, hx + R * 0.93 * math.cos(t), hy + R * 0.93 * math.sin(t))],
                  7, a=0.4, b=1, col=RIB)
        for rr in (150, 230):
            a.ink(d_arc(hx, hy, rr, -140, -40), 12, a=0, b=0, col=S1L)
    a.shine("M70 250 C84 216 104 186 130 162", sw=9)
    # a small spiral shell in front
    T = dict(s=0.92, dx=396, dy=380, deg=-36)
    cone = d_tf("M0 -120 C30 -84 76 -30 84 30 C90 76 50 100 0 100 C-50 100 -90 76 -84 30 C-76 -30 -30 -84 0 -120 Z", **T)
    with a.part():
        a.sil(cone, "#f8e4b4")
        a.blob(d_rim(cone, 60, 70, 20), "#e6c888")
        for y, hw in ((-66, 34), (-22, 62), (28, 82)):
            a.ink([f_tfc((-hw, y, -hw * 0.4, y + 22, hw * 0.4, y + 22, hw, y), **T)], 9, a=1, b=1, col="#d99a5a")
    with a.part(7):
        a.sil(d_tf(d_circ(14, 62, 36, 22), **T), "#f6b8a6")
    return a


@word
def kirikabu():
    a = Art()
    TOP, TOPD, RING = "#f6dfae", "#e6c888", "#d2a868"
    with a.part(9):
        a.sil(d_blade(52, 460, 26, 30, 400), LEAF2)
        a.sil(d_blade(74, 460, 26, 86, 388), LEAF1)
        a.sil(d_blade(448, 460, 26, 474, 398), LEAF2)
        a.sil(d_blade(428, 460, 26, 420, 404), LEAF1)
    side = ("M100 214 C100 300 96 372 40 440 C36 452 44 460 56 460 L456 460 C468 460 476 452 472 440 "
            "C416 372 412 300 412 214 Z")
    with a.part():
        a.sil(side, BARK)
        a.blob("M330 240 L412 214 C412 300 416 372 472 440 C476 452 468 460 456 460 L372 460 C344 400 332 320 330 240 Z", BARK_D)
        for c in ([(160, 290, 164, 330, 160, 370, 150, 410)], [(236, 300, 232, 350, 240, 400, 236, 440)],
                  [(300, 296, 306, 330, 300, 370, 306, 404)]):
            a.ink(c, 8, a=0, b=0, col=BARK_D)
        a.ink([(40, 442, 70, 432, 96, 414, 110, 388)], 8, a=1, b=0)
        a.ink([(472, 442, 442, 432, 416, 414, 402, 388)], 8, a=1, b=0)
    face = d_circ(256, 214, 158, 62)
    with a.part():
        a.sil(face, TOP)
        a.blob(d_rim(face, 70, 80, 14), TOPD)
        a.ink(d_arc(256, 214, 116, 0, 330, ky=0.39), 7, a=0, b=0, col=RING)
        a.ink(d_arc(256, 214, 74, 40, 380, ky=0.39), 7, a=0, b=0, col=RING)
        a.ink(d_arc(256, 214, 34, 100, 420, r1=6, ky=0.39), 7, a=0, b=0, col=RING)
    with a.part(9):                                     # a new shoot
        a.sil(taper([(372, 214, 384, 180, 388, 150, 384, 116)], 12, 10), LEAF2)
        a.sil(d_leaf(384, 130, 446, 76, 54, 0.2), LEAF1)
        a.sil(d_leaf(384, 150, 324, 98, 50, -0.2), LEAF1)
        d_vein(a, 384, 130, 446, 76, LEAF2, w=6, t0=0.12, t1=0.75)
        d_vein(a, 384, 150, 324, 98, LEAF2, w=6, t0=0.12, t1=0.75)
    return a


@word
def mizutamari():
    a = Art()
    W1, W1D, W1L, DR = "#8fd2f4", "#6cbce8", "#c9ecfb", "#6cc0ec"
    puddle = ("M40 372 C24 322 100 290 176 304 C226 270 334 278 374 308 C446 296 492 344 468 392 "
              "C446 436 344 446 282 436 C208 458 66 436 40 372 Z")
    with a.part():
        a.sil(puddle, W1)
        a.blob(d_rim(puddle, 90, 85, 22), W1D)
        a.ink(d_arc(250, 366, 108, 200, 340, ky=0.3), 9, a=0, b=0, col=WHITE)
        a.ink(d_arc(250, 366, 108, 20, 160, ky=0.3), 9, a=0, b=0, col=WHITE)
        a.ink(d_arc(250, 366, 56, 0, 360, ky=0.3), 8, a=0.5, b=0.5, col=WHITE)
        a.blob(d_circ(110, 352, 34, 9), W1L)
        a.blob(d_circ(400, 370, 40, 10), W1L)
    with a.part(8):                                     # a little splash in the middle
        a.sil("M236 362 C228 334 240 312 250 290 C260 312 272 334 264 362 Z", W1L)
        a.sil(d_circ(206, 322, 11, 13), W1L)
        a.sil(d_circ(294, 318, 11, 13), W1L)

    def drop(x, y, s_):
        d = d_tf("M0 -62 C20 -28 40 -6 40 20 C40 44 22 60 0 60 C-22 60 -40 44 -40 20 C-40 -6 -20 -28 0 -62 Z", s_, x, y)
        with a.part():
            a.sil(d, DR)
            a.blob(d_rim(d, 50, 70, 12 * s_), "#4fa9dc")
        a.shine(f"M{x - 20 * s_:.0f} {y + 22 * s_:.0f} C{x - 22 * s_:.0f} {y + 6 * s_:.0f} {x - 16 * s_:.0f} {y - 8 * s_:.0f} {x - 8 * s_:.0f} {y - 20 * s_:.0f}", sw=7)

    drop(128, 170, 1.0)
    drop(256, 110, 1.2)
    drop(384, 184, 0.9)
    return a


@word
def ochiba():
    a = Art()

    def oval(x, y, s_, deg, col, dark):
        T = dict(s=s_, dx=x, dy=y, deg=deg)
        with a.part(9):
            a.sil(d_tf(taper([(0, 96, 0, 120, 4, 140, 12, 160)], 12, 10), **T), "#8a5a34")
            a.sil(d_tf(d_leaf(0, 110, 0, -130, 190), **T), col)
            a.ink([f_tfc((0, 100, 0, 30, 0, -40, 0, -100), **T)], 8 * s_, a=1, b=0, col=dark)
            for y0, k in ((50, 1), (0, -1), (-40, 1)):
                a.ink([f_tfc(e1_line(0, y0, k * 50, y0 - 40), **T)], 6 * s_, a=1, b=0, col=dark)

    oval(140, 190, 0.9, -50, "#c98a4a", "#a56a30")
    f_ichou(a, 366, 176, 0.62, 30, "#f9d24a", "#e0a422", "#fde68a")
    oval(376, 350, 0.86, 62, "#f2a24a", "#d6802a")
    f_ichou(a, 130, 370, 0.56, -40, "#f6c13a", "#d99a1c", "#fbdc72")
    f_momiji(a, 256, 280, 0.86, 8, "#e8503f", "#c43a30")
    return a
