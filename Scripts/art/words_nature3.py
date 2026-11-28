"""めぐり nature3 の絵（さかな・うみの しぜん・いけの いきもの・はな・き・とり・どうぶつの あかちゃん・くさむらの むし）。
描き方は Content/Art/style-guide.md（D176）。"""
import math

from words_animals2 import n2_sit, n2_quad, N2_HEAD
from lib import Art, mirror, shift, O, EYE, taper, smooth, at, limb_d
from words import (word, GROUND, WHITE, CREAM, PINK, PINK_IN, CHEEK, RED, YEL2, SKY, a_face, a_snout, a_wool, a_band,
                   hoofed, band, sym, toes, b_face, b_side_eye, b_bird_feet, b_antennae,
                   d_circ, d_tf, d_rim, d_poly, d_leaf, d_vein, d_arc, d_curve, d_blade, petal, e1_sub,
                   LEAF1, LEAF2, BARK, BARK_D, STONE, STONE_D, STONE_L, SAND, SAND_D)

N3_GREEN_D = "#46964a"


def n3_mx(c, cx):
    """Mirror a cubic (8 numbers) around x = cx."""
    return tuple((2 * cx - v) if i % 2 == 0 else v for i, v in enumerate(c))


def n3_rays(a, cx0, cy0, n, r0, r1, w, col, ang0=0.0, ang1=math.pi * 2, ky=1.0):
    """Short tapered lines fanning out from a point (fins, petals' veins)."""
    for i in range(n):
        t = ang0 + (ang1 - ang0) * (i + 0.5) / n
        a.ink([(cx0 + math.cos(t) * r0, cy0 + math.sin(t) * r0 * ky, cx0 + math.cos(t) * (r0 * 0.7 + r1 * 0.3),
                cy0 + math.sin(t) * (r0 * 0.7 + r1 * 0.3) * ky, cx0 + math.cos(t) * (r0 * 0.3 + r1 * 0.7),
                cy0 + math.sin(t) * (r0 * 0.3 + r1 * 0.7) * ky, cx0 + math.cos(t) * r1, cy0 + math.sin(t) * r1 * ky)],
              w, a=1, b=0, col=col)


# ------------------------------------------------------------ さかな・かい --
@word
def tai():
    a = Art()
    RD, RD_D, BELLY, FIN, BL = "#f2675b", "#d94f47", "#ffd2c8", "#f58a7e", "#6fb7e8"
    with a.part():
        a.sil("M124 256 C92 226 60 180 14 150 C30 200 40 240 56 256 C40 272 30 312 14 362 C60 332 92 286 124 256 Z", FIN)
        a.sil("M170 176 C200 112 260 76 300 80 C334 82 352 96 376 126 C344 132 318 130 298 142 C276 134 252 134 232 146 "
              "C208 144 188 158 170 176 Z", FIN)
        a.sil("M262 380 C268 416 248 446 208 448 C220 424 226 404 230 374 Z", FIN)
        a.sil("M104 256 C118 190 194 140 290 132 C380 126 454 162 476 232 C486 262 478 296 456 316 "
              "C422 358 360 388 290 388 C196 388 120 336 104 256 Z", RD)
        a.blob("M146 318 C206 374 330 386 432 330 C402 372 352 392 290 390 C220 390 168 364 146 318 Z", BELLY)
        for x, y in ((214, 190), (252, 168), (290, 160), (232, 222), (272, 204), (318, 190), (196, 238)):
            a.dot(x, y, 7, BL)
        a.ink([(376, 160, 356, 220, 358, 280, 380, 336)], 8, a=0.2, b=0.2, col=RD_D)
        for c in ((200, 150, 206, 134, 214, 124, 226, 114), (252, 138, 256, 120, 264, 108, 276, 100), (296, 136, 304, 122, 314, 114, 326, 108)):
            a.ink([c], 6, a=0, b=0, col=RD_D)
        for c in ((30, 196, 54, 214, 84, 238, 108, 256), (30, 316, 54, 298, 84, 274, 108, 256)):
            a.ink([c], 6, a=0, b=0, col=RD_D)
    a.sil("M318 306 C294 312 280 336 286 366 C312 362 332 344 336 318 Z", FIN)
    a.path("M468 268 C474 278 484 276 488 266", sw=7)
    b_side_eye(a, 416, 228, 17, cheek=(-2, 44))
    a.shine("M178 222 C200 188 238 164 284 158")
    return a


@word
def sanma():
    a = Art()
    BL, BL_D, SV, YL = "#4a72a8", "#365b8e", "#e8eef5", "#f7c948"
    with a.part():
        a.sil("M96 256 C70 236 46 206 16 176 C28 220 34 244 44 256 C34 270 28 294 16 336 C46 306 70 276 96 256 Z", BL_D)
        a.sil("M120 230 C140 204 172 200 196 214 L190 236 C168 232 144 234 120 236 Z", BL_D)
        a.sil("M120 282 C140 308 172 312 196 298 L190 276 C168 280 144 278 120 276 Z", BL_D)
        a.sil("M86 256 C130 224 230 210 330 214 C400 216 450 232 486 252 L496 258 L484 266 C450 288 400 304 330 306 "
              "C230 306 130 290 86 256 Z", BL)
        a.blob("M110 266 C170 296 260 300 340 296 C410 292 454 280 486 264 L484 266 C450 298 400 312 330 312 "
               "C230 312 140 296 110 266 Z", SV)
        a.blob("M430 238 C450 244 470 252 490 256 L484 264 C462 268 440 266 424 262 Z", YL)
        a.ink([(150, 244, 250, 236, 340, 238, 420, 246)], 6, a=0, b=0, col=BL_D)
    a.sil("M270 300 C264 326 244 344 218 348 C224 328 234 312 246 298 Z", BL_D)
    b_side_eye(a, 424, 250, 13, cheek=(-4, 28))
    a.shine("M170 226 C220 218 270 216 320 220")
    return a


@word
def ei():
    a = Art()
    BL, BL_D, TAIL, DOT = "#8fb2d6", "#6f95c0", "#7b9fc8", "#e6f0fa"
    with a.part(ow=8):
        a.sil(taper([(256, 340, 256, 400, 262, 450, 252, 500)], 34, 8), TAIL)
    with a.part():
        a.sil("M256 100 C300 100 330 136 366 168 C410 190 470 212 500 254 C462 276 420 296 380 316 C338 340 296 372 256 372 "
              "C216 372 174 340 132 316 C92 296 50 276 12 254 C42 212 102 190 146 168 C182 136 212 100 256 100 Z", BL)
        a.blob("M30 262 C70 288 112 306 150 326 C190 352 226 372 256 372 C226 346 190 312 150 290 C112 268 70 266 30 262 Z", BL_D)
        a.blob("M482 262 C442 288 400 306 362 326 C322 352 286 372 256 372 C286 346 322 312 362 290 C400 268 442 266 482 262 Z", BL_D)
        for x, y in ((150, 232), (190, 270), (362, 232), (322, 270), (256, 304), (116, 258), (396, 258)):
            a.dot(x, y, 8, DOT)
        a.ink([(256, 372, 256, 346, 256, 322, 256, 300)], 8, a=1, b=0, col=BL_D)
    cx = 256
    b_face(a, cx, 218, 44, 17, cheek=(70, 36), mouth=40, mw=13)
    a.shine("M200 150 C214 130 232 118 252 114")
    return a


@word
def uni():
    a = Art()
    PU, PU_D, PU_L, SP = "#8a63b8", "#6a4a98", "#a883d2", "#5d4285"
    cx, cy = 256, 276
    with a.part():
        n = 15
        for i in range(n):
            t = -math.pi / 2 + 2 * math.pi * i / n
            x0, y0 = cx + math.cos(t) * 90, cy + math.sin(t) * 90
            x1, y1 = cx + math.cos(t) * 206, cy + math.sin(t) * 206
            a.sil(taper([(x0, y0, x0 + (x1 - x0) * 0.33, y0 + (y1 - y0) * 0.33, x0 + (x1 - x0) * 0.66, y0 + (y1 - y0) * 0.66, x1, y1)], 30, 7), SP)
        a.sil(d_circ(cx, cy, 128), PU)
        a.blob(d_rim(d_circ(cx, cy, 128), 70, 70, 22), PU_D)
        a.blob(d_circ(cx - 38, cy - 54, 30, 18), PU_L)
    b_face(a, cx, 290, 50, 20, cheek=(86, 36), mouth=34, mw=13)
    a.shine("M178 218 C190 196 210 182 232 176")
    return a


# ---------------------------------------------------------- うみの しぜん --


@word
def nami():
    a = Art()
    W1, W1D, W1L, FOAM = "#4fa8e0", "#3a8cc8", "#8fd0f4", "#ffffff"
    wave = ("M24 440 C24 330 80 256 168 206 C232 170 292 110 372 100 C444 92 492 144 468 206 "
            "C458 176 424 168 398 188 C376 206 392 236 410 252 C440 282 462 330 482 440 Z")
    with a.part():
        a.sil(wave, W1)
        a.blob(d_rim(wave, 120, 80, 40), W1D)
        a.blob("M60 400 C80 340 130 290 200 250 C170 300 150 350 150 440 L60 440 Z", W1L)
        a.sil("M168 206 C232 170 292 110 372 100 C444 92 492 144 468 206 C458 176 424 168 398 188 C376 206 392 236 410 252 "
              "C380 232 346 214 316 218 C270 222 224 222 168 206 Z", FOAM)
        for x, y in ((130, 260), (96, 300), (236, 290)):
            a.dot(x, y, 7, WHITE)
        a.ink([(320, 128, 350, 114, 390, 112, 420, 128)], 8, a=0, b=0, col=W1L)
    a.shine("M70 360 C86 316 120 280 164 252", sw=8)
    return a


# ------------------------------------------------------ いけ・たんぼの いきもの --


def n2_strip_like(cubics, w0, w1, f0, f1, t0=0.0, t1=1.0, k=24):
    ts = [t0 + (t1 - t0) * i / k for i in range(k + 1)]
    hw = lambda t: (w0 + (w1 - w0) * t) / 2
    pts = [at(cubics, t, hw(t) * f0) for t in ts] + [at(cubics, t, hw(t) * f1) for t in ts[::-1]]
    return "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"


# ---------------------------------------------------------- はな・きの なかま --
def n3_petals(a, cx, cy, R, n, rot=0.0, w=0.8, col=WHITE, notch=False):
    for i in range(n):
        a.sil(petal(cx, cy, R, rot + i * 2 * math.pi / n, w=w, notch=notch), col)


def n3_line(x0, y0, x1, y1):
    return (x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)


@word
def hasu():
    a = Art()
    PK, PK_D, PK_L, LF, LFD, STEM = "#f7a8c4", "#ea7ba1", "#fde0ea", "#5fae58", "#3f8a44", "#6fb165"
    leaf = d_circ(130, 410, 118, 44)
    with a.part():
        a.sil(taper([(258, 330, 258, 390, 258, 440, 258, 486)], 22, 22, cap=False), LFD)
        a.sil(taper([(412, 300, 414, 380, 414, 440, 414, 486)], 16, 16, cap=False), LFD)
        a.sil(taper([(130, 416, 156, 440, 196, 460, 236, 476)], 12, 12, cap=False), LFD)
    with a.part():
        a.sil(leaf, LF)
        a.blob(d_rim(leaf, 70, 80, 14), LFD)
        n3_rays(a, 130, 410, 9, 14, 92, 7, LFD, ang0=math.pi * 0.05, ang1=math.pi * 1.95, ky=0.38)
    base = (258, 350)
    with a.part():
        for ang, L in ((-0.9, 150), (0.9, 150), (-0.45, 196), (0.45, 196)):
            tx, ty = base[0] + math.sin(ang) * L, base[1] - math.cos(ang) * L
            a.sil(d_leaf(base[0], base[1], tx, ty, 78, 0), PK_L)
    with a.part():
        for ang, L in ((-1.05, 120), (1.05, 120), (-0.5, 156), (0.5, 156), (0, 200)):
            tx, ty = base[0] + math.sin(ang) * L, base[1] + 12 - math.cos(ang) * L
            a.sil(d_leaf(base[0], base[1] + 12, tx, ty, 84, 0), PK)
            d_vein(a, base[0], base[1] + 12, tx, ty, PK_D, w=6, t0=0.2, t1=0.72)
    with a.part(9):       # つぼみ
        a.sil(petal(412, 330, 100, 0.0, w=0.5, notch=False), PK)
        a.blob(petal(412, 330, 100, 0.0, w=0.28, notch=False), PK_L)
        a.sil("M388 318 C396 334 428 334 436 318 C432 344 392 344 388 318 Z", LF)
    return a


@word
def ine():
    a = Art()
    GR, GRD, GOLD, GOLD_D, GOLD_L = "#8fcf6a", "#63ad4f", "#f2c94c", "#d9a62a", "#ffe28a"

    def stalk(x0, top, bend, hang):
        # stem
        a.sil(taper([(x0, 486, x0 + 4, 430, x0 + bend * 0.2, 380, x0 + bend * 0.6, top + 20)], 18, 12, cap=False), GR)
        # drooping ear: grains along an arc
        tx, ty = x0 + bend * 0.6, top + 20
        pts = [(tx, ty), (tx + bend * 0.35, ty - 24), (tx + bend * 0.85, ty - 10), (tx + bend * 1.1, ty + hang * 0.5),
               (tx + bend * 1.18, ty + hang)]
        for i in range(0, 14):
            t = i / 13
            # quadratic-ish bezier through pts
            u = 1 - t
            x = u**3 * pts[0][0] + 3 * u * u * t * pts[1][0] + 3 * u * t * t * pts[3][0] + t**3 * pts[4][0]
            y = u**3 * pts[0][1] + 3 * u * u * t * pts[1][1] + 3 * u * t * t * pts[3][1] + t**3 * pts[4][1]
            for d in (-9, 9):
                a.sil_ellipse(x + d, y, 12, 17, GOLD)
    with a.part():
        for x0, top, bend, hang in ((170, 120, 90, 200), (300, 76, 110, 220), (236, 190, -90, 170)):
            stalk(x0, top, bend, hang)
        for x, tx, ty in ((120, 40, 300), (330, 470, 330)):
            a.sil(d_blade(x, 490, 36, tx, ty), GR)
        a.sil(d_blade(220, 490, 34, 90, 250), GRD)
        a.sil(d_blade(300, 490, 34, 410, 260), GRD)
        a.sil(d_blade(256, 490, 36, 256, 330), GR)
    return a


@word
def higanbana():
    a = Art()
    RD, RD_D, STEM, STEMD = "#e8383d", "#c42a30", "#7ab55a", "#5a9a45"

    def flower(cx, cy, R, n=6, rot=0.0):
        with a.part():
            for i in range(n):
                ang = rot + (i - (n - 1) / 2) * (2 * math.pi / n) * 0.62 - math.pi / 2
                sgn = 1 if math.cos(ang) >= 0 else -1
                ex, ey = cx + math.cos(ang) * R, cy + math.sin(ang) * R
                a.sil(taper([(cx, cy, cx + math.cos(ang) * R * 0.4, cy + math.sin(ang) * R * 0.4 - R * 0.1,
                              cx + math.cos(ang) * R * 0.85, cy + math.sin(ang) * R * 0.85 - R * 0.25,
                              ex + sgn * R * 0.12, ey + R * 0.1)], R * 0.2, R * 0.07), RD)
        for i in range(8):
            ang = rot + (i - 3.5) * 0.4 - math.pi / 2
            ex, ey = cx + math.cos(ang) * R * 1.12, cy + math.sin(ang) * R * 1.12
            a.ink([(cx, cy, cx + math.cos(ang) * R * 0.5, cy + math.sin(ang) * R * 0.5 - 12,
                    cx + math.cos(ang) * R * 0.95, cy + math.sin(ang) * R * 0.95 - 20, ex, ey)], 6, a=1, b=0.6, col=RD_D)
            a.dot(ex, ey, 6, "#f4c2a0")
    with a.part():
        a.sil(taper([(256, 490, 256, 440, 256, 380, 256, 330)], 22, 18, cap=False), STEM)
        a.sil(taper([(396, 490, 396, 450, 394, 420, 390, 380)], 16, 14, cap=False), STEM)
        a.sil(d_blade(90, 492, 30, 40, 300), STEMD)
        a.sil(d_blade(160, 492, 30, 130, 370), STEMD)
        a.sil(d_blade(460, 492, 30, 480, 320), STEMD)
    flower(396, 380, 70, rot=0.3)
    flower(256, 300, 120, rot=0.0)
    return a


# ---------------------------------------------------------------- とりの なかま --
N3_PIN = ("M256 64 C310 64 340 102 340 146 C340 176 334 196 350 220 C378 262 394 300 390 342 "
          "C384 404 326 436 256 436 C186 436 128 404 122 342 C118 300 134 262 162 220 "
          "C178 196 172 176 172 146 C172 102 202 64 256 64 Z")
N3_PIN_HEAD = ("M256 64 C310 64 340 102 340 146 C340 176 334 196 350 220 C320 240 192 240 162 220 "
               "C178 196 172 176 172 146 C172 102 202 64 256 64 Z")
N3_ROUND = ("M256 72 C326 72 364 116 364 170 C364 196 358 212 368 232 C388 270 394 304 388 340 "
            "C380 400 324 432 256 432 C188 432 132 400 124 340 C118 304 124 270 144 232 "
            "C154 212 148 196 148 170 C148 116 186 72 256 72 Z")
N3_BELLY = ("M256 296 C306 296 330 330 330 366 C330 404 300 426 256 426 C212 426 182 404 182 366 "
            "C182 330 206 296 256 296 Z")
N3_WING = "M146 262 C112 290 98 340 116 392 C124 408 140 410 152 400 C180 374 192 326 186 290 C182 270 166 258 146 262 Z"
N3_TAIL = "M296 372 C350 384 402 404 424 446 C378 452 330 440 286 418 Z"
N3_BEAK = "M238 166 C238 156 274 156 274 166 C274 184 264 196 256 196 C248 196 238 184 238 166 Z"


def n3_wings(a, col, line, d=N3_WING, rows=(0, 30)):
    with a.part():
        sym(a, d, col, 256)
        for s in (-1, 1):
            for y0 in rows:
                q = (118, 336 + y0, 136, 344 + y0, 156, 344 + y0, 176, 336 + y0)
                a.ink([q if s < 0 else n3_mx(q, 256)], 9, a=0.6, b=0.6, col=line)


@word
def kawasemi():
    a = Art()
    BL, BL_D, BL_L, OR, BEAK = "#2fa6c8", "#1f86a8", "#7fd6ee", "#f59a4a", "#3b3a46"
    with a.part(ow=8):       # 止まり木
        a.sil(taper([(80, 452, 200, 440, 360, 448, 470, 436)], 24, 20), "#a07148")
    with a.part(ow=8):
        for x in (232, 288):
            a.sil(f"M{x - 8} 396 L{x + 8} 396 L{x + 8} 436 C{x + 20} 438 {x + 22} 450 {x + 6} 450 L{x - 14} 450 C{x - 24} 446 {x - 16} 436 {x - 8} 436 Z", "#e5534b")
    with a.part():
        a.sil(taper([(330, 340, 370, 380, 400, 420, 410, 470)], 50, 30), BL_D)
    body = ("M180 140 C240 100 330 120 370 190 C400 250 400 330 370 380 C340 420 230 428 190 390 "
            "C150 350 146 250 172 180 Z")
    with a.part():
        a.sil(body, OR)
        a.blob("M196 160 C250 130 330 146 360 200 C390 260 392 320 372 366 C348 316 330 250 296 214 C264 182 228 176 196 160 Z", BL)
        a.blob("M196 160 C232 150 262 156 280 168 C262 196 244 226 232 262 C216 232 204 196 196 160 Z", BL_L)
        a.blob("M332 200 C356 236 366 286 358 338 C342 300 330 250 316 214 Z", BL_D)
        a.ink([(300, 250, 330, 290, 350, 330, 358, 360)], 7, a=0.2, b=0.2, col="#1b6f8f")
    with a.part(ow=8):       # くちばし
        a.sil("M190 196 C150 192 80 186 24 214 C80 226 150 236 192 242 Z", BEAK)
    with a.part():
        a.sil("M170 224 C176 204 200 192 220 196 C232 220 226 262 200 276 C182 270 168 252 170 224 Z", WHITE)
    b_side_eye(a, 222, 176, 17, cheek=(-12, 40))
    a.shine("M214 128 C236 118 262 118 284 128")
    return a


@word
def dachou():
    a = Art()
    BK, BK_D, WH, NK, NK_D, BEAK, LEG = "#4a4656", "#37333f", "#fffdf8", "#f6c9b8", "#e8a898", "#f7c9a9", "#f1b9a4"
    G = 470
    with a.part(ow=8):
        for x, k in ((276, 8), (336, -4)):
            a.sil(taper([(x, 330, x + k, 380, x + k * 0.6, 430, x + k * 0.4, G - 20)], 40, 26), LEG)
            a.sil(f"M{x + k * 0.4 - 22} {G - 24} C{x + k * 0.4 - 22} {G - 6} {x + k * 0.4 - 10} {G} {x + k * 0.4 + 6} {G} L{x + k * 0.4 + 44} {G} C{x + k * 0.4 + 54} {G} {x + k * 0.4 + 52} {G - 14} {x + k * 0.4 + 38} {G - 18} Z", LEG)
    with a.part():
        a.sil("M470 250 C514 240 536 270 530 308 C524 340 494 346 470 330 Z", WH)
    with a.part():       # くび
        a.sil(taper([(250, 272, 224, 230, 232, 170, 214, 110)], 46, 30, cap=False), NK)
    with a.part():       # からだ
        a.sil("M230 300 C230 232 308 196 388 204 C460 212 500 262 492 320 C484 370 420 384 340 384 C270 384 230 356 230 300 Z", BK)
        a.blob("M246 330 C280 372 380 386 470 350 C436 388 360 394 300 388 C262 380 244 356 246 330 Z", BK_D)
        for x, y in ((420, 230), (454, 262), (456, 308)):
            a.ink([(x - 20, y, x - 8, y - 12, x + 8, y - 12, x + 20, y)], 8, a=0.6, b=0.6, col="#6a6578")
        a.sil("M236 268 C226 244 238 214 262 204 C268 232 262 256 252 278 Z", WH)
    with a.part():       # はね（白い おばね）
        a.sil("M330 270 C380 250 450 262 470 306 C440 352 370 360 330 330 C318 310 318 286 330 270 Z", WH)
        a.ink([(350, 300, 380, 292, 420, 292, 450, 304)], 8, a=1, b=0, col="#d8dce6")
    with a.part():
        a.sil_ellipse(204, 108, 50, 44, NK)
        a.sil("M164 118 C150 112 128 114 114 122 C128 136 150 138 164 134 Z", BEAK)
    b_side_eye(a, 208, 98, 14, cheek=(10, 24))
    a.ink([(184, 82, 190, 76, 198, 74, 208, 74)], 6, a=1, b=0.6, col=O)
    return a


GROUND.update({"dachou"})


@word
def oshidori():
    a = Art()
    OR, OR_D, CR, GN, GN_D, PU, WH, RDB, BR = "#f28c3a", "#d86f22", "#fff4de", "#2f9d74", "#1f7a5a", "#7a5aa6", "#fffdf8", "#e5534b", "#a85f34"
    with a.part():
        a.sil("M150 334 C150 296 200 280 260 280 C330 274 410 276 462 244 C490 296 478 372 414 398 "
              "C340 418 230 414 182 394 C160 382 150 358 150 334 Z", CR)
        a.blob("M150 334 C150 300 190 284 240 281 C250 320 240 370 214 404 C200 400 190 398 182 394 C160 382 150 358 150 334 Z", PU)
        a.blob("M196 398 C250 414 350 416 420 394 C380 412 300 420 240 412 C222 410 208 406 196 398 Z", "#e6d6bc")
    with a.part():       # 帆のような おばね
        a.sil("M300 330 C300 250 340 190 410 170 C430 224 424 292 400 346 C370 358 330 354 300 330 Z", OR)
        a.ink([(330, 322, 350, 272, 376, 226, 408, 186)], 8, a=0, b=0, col=OR_D)
        a.ink([(310, 324, 322, 280, 342, 240, 372, 206)], 7, a=0, b=0, col=OR_D)
    with a.part():
        a.sil("M280 322 C310 288 370 282 420 296 C414 336 380 364 336 366 C304 366 284 346 280 322 Z", "#c9b08a")
        a.ink([(298, 330, 330, 316, 368, 312, 402, 316)], 7, a=0, b=0.6, col="#8f7e62")
    with a.part(ow=8):
        a.sil("M118 206 C84 202 52 212 38 228 C54 246 88 250 122 238 Z", RDB)
    with a.part():
        a.sil("M176 140 C218 140 246 170 246 210 C246 236 238 256 228 272 C232 284 232 292 228 300 "
              "C200 312 150 312 124 300 C120 292 120 284 124 272 C112 256 106 236 106 210 C106 170 134 140 176 140 Z", GN)
        a.sil("M246 214 C280 214 310 236 326 270 C290 262 262 280 232 292 Z", OR)
        a.sil("M132 270 C100 292 96 320 108 342 C132 330 156 312 168 290 Z", OR)
        a.blob("M124 272 C150 284 202 284 228 272 C232 284 232 292 228 300 C200 312 150 312 124 300 C120 292 120 284 124 272 Z", WHITE)
        a.blob("M118 222 C132 176 176 156 232 164 C246 168 250 174 250 182 C204 176 160 192 142 232 Z", WHITE)
        a.blob("M150 168 C166 150 206 146 232 158 C206 156 176 162 156 180 Z", GN_D)
    b_side_eye(a, 160, 202, 14)
    a.ellipse(170, 238, 13, 8, "#f3b3a4", sw=0, stroke="none")
    a.shine("M132 190 C138 172 152 160 170 154")
    return a


# ---------------------------------------------------------- どうぶつの あかちゃん --
N3_HEAD = "M256 56 C344 56 392 108 392 172 C392 240 334 280 256 280 C178 280 120 240 120 172 C120 108 168 56 256 56 Z"


@word
def kobuta():
    a = Art()
    P, PD, SN, SND = "#f9b4be", "#ee9aa8", "#f28a9b", "#c9707f"
    cx = 256
    with a.part(ow=8):
        a.sil(taper([(356, 410, 420, 420, 446, 380, 420, 350), (420, 350, 400, 330, 376, 346, 394, 360)], 22, 14), P)
    n2_sit(a, P, PD)
    ear = "M170 100 C144 80 108 88 90 112 L64 164 C98 164 138 156 166 136 Z"
    with a.part():
        sym(a, ear, P, cx)
        a.sil(N3_HEAD, P)
        sym(a, "M158 110 C140 98 116 102 104 118 L90 146 C112 146 138 140 156 124 Z", PD, cx, sil=False)
        a.blob(N3_HEAD, P)
    with a.part(ow=8):
        a.sil_ellipse(cx, 224, 56, 42, SN)
    for s in (-1, 1):
        a.ellipse(cx + s * 20, 224, 8, 13, SND, sw=0, stroke="none")
    a.path("M236 270 C248 280 264 280 276 270", sw=7)
    a_face(a, cx, 172, 62, 20, cheek=(100, 226, 16, 10))
    a.shine("M300 78 C328 86 350 104 362 128")
    return a


# ---------------------------------------------------------- くさむらの むし --
def n3_hopper(a, col, dark, light, wing_col, wing_ink, ant, ant_r=8, body=None, wing=None, stripe=None, face_dark=None,
              cerci=False, tail_len=0):
    """A cricket / katydid seen from the side, head on the left (like the grasshopper in animals2)."""
    G = 444
    body = body or "M210 250 C270 232 400 240 520 330 C440 370 300 380 220 360 C196 330 194 280 210 250 Z"
    wing = wing or "M250 252 C330 236 440 262 536 318 C460 330 340 324 262 300 C248 288 244 266 250 252 Z"
    with a.part(ow=8):
        for x in (236, 286):
            a.sil(taper([(x, 340, x - 6, 376, x - 18, 410, x - 34, 436)], 20, 11), dark)
    with a.part():
        a.sil(body, col)
        a.blob("M230 350 C300 372 420 364 506 332 C440 368 300 380 222 360 Z", light)
        if cerci:
            a.sil("M500 322 C524 316 540 322 552 336 C532 336 514 336 500 334 Z", dark)
    with a.part():
        a.sil(wing, wing_col)
        a.ink([wing_ink], 7, a=0, b=0, col=dark)
        if stripe:
            a.blob(stripe, light)
    with a.part():
        a.sil(taper([(340, 330, 372, 270, 404, 214, 440, 160)], 54, 24), col)
        a.sil(taper([(440, 162, 452, 250, 468, 340, 490, 432)], 20, 12), dark)
        a.sil("M480 424 L520 432 C526 438 522 444 514 444 L476 444 Z", dark)
        a.ink([(352, 320, 378, 276, 402, 236, 428, 196)], 7, a=0, b=0, col=dark)
    b_antennae(a, 150, ant, r=ant_r)
    HEAD = "M150 150 C212 150 244 192 244 246 C244 312 206 356 150 356 C94 356 56 312 56 246 C56 192 88 150 150 150 Z"
    a.sil(HEAD, face_dark or col)
    b_face(a, 150, 246, 40, 18, mouth=38, mw=12, white=bool(face_dark))
    for s in (-1, 1):
        a.ellipse(150 + s * 64, 284, 15, 9, "#f3b3a4", sw=0, stroke="none")
    a.shine("M90 220 C98 196 114 178 136 170")


@word
def koorogi():
    a = Art()
    BR, BRD, BRL = "#7a5236", "#53382a", "#a8815c"
    n3_hopper(a, BR, BRD, BRL, "#5e4030", (280, 280, 350, 290, 430, 300, 500, 314), (172, 150, 190, 100, 232, 60, 290, 40),
              ant_r=7, cerci=True, face_dark=BR)
    return a


@word
def kirigirisu():
    a = Art()
    G_, GD, GL, WING = "#86c85a", "#5ea545", "#d8f0b4", "#a9d880"
    n3_hopper(a, G_, GD, GL, WING, (270, 276, 360, 282, 450, 296, 520, 316), (178, 150, 160, 90, 210, 40, 330, 20),
              ant_r=6, body="M210 250 C280 238 420 250 540 336 C450 372 300 380 220 360 C196 330 194 280 210 250 Z",
              wing="M246 252 C340 232 470 260 560 322 C470 336 350 330 258 302 C244 288 240 266 246 252 Z",
              stripe="M270 262 C340 252 440 268 520 308 C470 290 380 282 300 288 Z")
    return a


@word
def dangomushi():
    a = Art()
    GY, GYD, GYL, LEG = "#8e95aa", "#6b7289", "#c6cbd9", "#5a6075"
    with a.part(ow=8):
        for i, x in enumerate((160, 210, 260, 310, 360)):
            a.sil(taper([(x, 396, x - 6, 420, x - 12, 440, x - 18, 452)], 20, 11), LEG)
    dome = "M60 410 C56 270 150 190 260 190 C360 190 440 250 450 410 Z"
    with a.part():
        a.sil(dome, GY)
        a.blob(d_rim(dome, 60, 80, 34), GYD)
        for i, x in enumerate((130, 190, 250, 310, 370)):
            a.ink([(x + 30, 214 + abs(x - 250) * 0.15, x + 14, 280, x + 8, 340, x + 12, 404)], 9, a=0.2, b=1, col=GYD)
        a.blob("M80 406 C120 394 360 394 440 406 L450 410 L60 410 Z", GYL)
        a.blob("M130 230 C160 208 210 198 250 198 C210 216 170 250 150 292 Z", GYL)
    with a.part():
        a.sil("M400 268 C456 268 494 304 494 354 C494 404 456 436 400 436 C344 436 306 404 306 354 C306 304 344 268 400 268 Z", GY)
        a.blob(d_rim("M400 268 C456 268 494 304 494 354 C494 404 456 436 400 436 C344 436 306 404 306 354 C306 304 344 268 400 268 Z", 70, 70, 22), GYD)
    b_antennae(a, 400, (420, 274, 436, 236, 462, 214, 492, 208), r=8)
    b_face(a, 400, 352, 42, 17, cheek=(72, 32), mouth=32, mw=12, white=True)
    a.shine("M340 318 C348 298 364 286 384 280")
    return a


@word
def minomushi():
    a = Art()
    BR, BRD, BRL, HD, TW = "#a8744a", "#7d522f", "#d09a64", "#f3d6b0", "#8a5a34"
    with a.part(ow=5):
        a.sil(taper([(256, 0, 256, 36, 256, 70, 256, 112)], 8, 8, cap=False), "#7a6a5a")
    with a.part():
        a.sil("M256 108 C320 108 386 132 400 220 C412 290 420 340 440 386 C388 410 128 410 72 386 C92 340 100 290 112 220 C126 132 192 108 256 108 Z", BR)
        a.blob(d_rim("M256 108 C320 108 386 132 400 220 C412 290 420 340 440 386 C388 410 128 410 72 386 C92 340 100 290 112 220 C126 132 192 108 256 108 Z", 60, 70, 40), BRD)
        for i, (x0, y0) in enumerate(((150, 160), (210, 140), (290, 142), (350, 168), (130, 240), (200, 220), (260, 210), (330, 230),
                                       (370, 250), (110, 320), (180, 300), (250, 296), (320, 304), (390, 330), (160, 370), (240, 372), (330, 376))):
            dx = 38 if i % 2 else 30
            a.ink([(x0, y0, x0 + dx * 0.3, y0 + 14, x0 + dx * 0.7, y0 + 30, x0 + dx * (0.9 if i % 2 else 0.5), y0 + 56)], 11, a=0, b=0.6, col=BRL)
        a.blob("M100 380 C150 400 360 400 412 380 C380 396 140 396 100 380 Z", BRD)
    with a.part():
        a.sil("M256 336 C324 336 366 366 366 410 C366 454 318 480 256 480 C194 480 146 454 146 410 C146 366 188 336 256 336 Z", HD)
    b_face(a, 256, 410, 42, 17, cheek=(76, 30), mouth=30, mw=12)
    return a


def n3_wader(a, body, wing, beak, leg, belly_shade, beak_len=70, neck_w=34):
    """A standing wading bird (heron / stork) seen from the side, head on the left."""
    G = 470
    with a.part(ow=8):
        for x, k in ((290, 6), (344, -4)):
            a.sil(taper([(x, 360, x + k, 400, x + k * 0.6, 440, x + k * 0.4, G - 14)], 18, 12), leg)
            a.sil(f"M{x + k * 0.4 - 24} {G - 16} C{x + k * 0.4 - 24} {G - 2} {x + k * 0.4 - 12} {G} {x + k * 0.4 + 4} {G} "
                  f"L{x + k * 0.4 + 40} {G} C{x + k * 0.4 + 50} {G} {x + k * 0.4 + 48} {G - 12} {x + k * 0.4 + 36} {G - 16} Z", leg)
    with a.part(ow=8):
        a.sil(taper([(172, 108, 140, 104, 96, 112, 120 - beak_len, 124)], 26, 8), beak)
    with a.part():
        a.sil(taper([(256, 290, 230, 250, 252, 200, 214, 150), (214, 150, 200, 130, 196, 118, 192, 108)], neck_w + 14, neck_w - 4, cap=False), body)
        a.sil_ellipse(194, 106, 42, 38, body)
        a.sil("M236 300 C236 244 316 214 396 222 C456 230 490 276 484 324 C476 370 420 384 346 384 C280 384 236 358 236 300 Z", body)
        a.blob("M250 336 C284 372 380 384 462 352 C432 386 360 392 306 388 C270 382 250 360 250 336 Z", belly_shade)
    with a.part():
        a.sil("M300 280 C350 256 440 262 468 304 C444 350 370 362 318 340 C300 326 292 300 300 280 Z", wing)
        a.ink([(322, 300, 360, 296, 410, 298, 452, 308)], 8, a=1, b=0, col=belly_shade)
    b_side_eye(a, 190, 100, 13, cheek=(10, 22))


@word
def sagi():
    a = Art()
    n3_wader(a, "#fffdf8", "#f1f3f8", "#f7c948", "#4a4656", "#dfe6f0")
    return a


GROUND.update({"sagi"})


# ================================================== みなおし（Fable の指摘。D201） ==
# ---- さかな・かい
@word
def sake():
    a = Art()
    SV, SV_D, BELLY, FIN, DOT, PK = "#b9c8da", "#7e95b0", "#f4f7fb", "#8aa0ba", "#3a4560", "#f3a090"
    with a.part():
        a.sil("M120 256 C92 226 62 190 14 166 C28 214 36 240 52 256 C36 272 28 298 14 346 C62 322 92 286 120 256 Z", FIN)
        a.sil("M214 190 C236 150 276 134 318 136 C306 156 304 174 308 196 Z", FIN)
        a.sil("M376 196 C392 176 412 168 430 172 C424 186 420 196 424 208 Z", FIN)
        a.sil("M268 332 C270 372 250 398 214 400 C224 376 230 358 232 326 Z", FIN)
        a.sil("M96 256 C132 204 214 176 304 176 C390 176 446 198 470 232 L494 236 C486 252 474 258 462 262 "
              "C478 270 484 282 476 296 C440 336 372 346 296 346 C206 346 134 318 96 256 Z", SV)
        a.blob("M130 296 C196 336 296 344 390 328 C430 320 458 308 474 292 C440 338 372 352 296 352 C220 352 160 332 130 296 Z", BELLY)
        a.blob("M96 256 C130 216 190 192 250 186 C240 206 236 226 240 246 C190 244 140 250 96 256 Z", SV_D)
        for x, y in ((190, 222), (230, 214), (276, 212), (322, 216), (364, 224), (250, 246), (300, 244), (346, 250), (396, 238)):
            a.dot(x, y, 6, DOT)
        a.ink([(380, 200, 362, 240, 364, 286, 384, 326)], 8, a=0.2, b=0.2, col=SV_D)
        a.ink([(170, 262, 240, 270, 330, 270, 420, 262)], 8, a=0, b=0, col=PK)
    with a.part(ow=8):       # かぎ形の あご
        a.sil("M456 258 C470 270 488 274 496 262 C500 280 486 296 464 296 Z", SV_D)
    a.sil("M304 304 C282 312 270 336 276 364 C300 360 318 342 322 314 Z", FIN)
    b_side_eye(a, 426, 222, 14, cheek=(-4, 34))
    a.shine("M170 230 C204 206 250 192 300 190")
    return a


@word
def maguro():
    a = Art()
    NV, NV_D, SV, YL = "#44649f", "#334f86", "#e3ebf5", "#f7c948"
    with a.part():
        a.sil("M118 256 C94 206 66 150 22 104 C40 176 50 226 56 256 C50 286 40 336 22 408 C66 362 94 306 118 256 Z", NV_D)
        for x in (150, 184, 218):
            a.sil(f"M{x} 150 L{x + 30} 122 L{x + 28} 158 Z", YL)
            a.sil(f"M{x} 362 L{x + 30} 390 L{x + 28} 354 Z", YL)
        a.sil("M236 140 C268 80 322 50 384 44 C366 80 360 116 366 150 Z", NV_D)
        a.sil("M90 256 C140 160 250 118 350 120 C430 124 486 176 500 256 C486 336 430 388 350 392 C250 394 140 352 90 256 Z", NV)
        a.blob("M118 284 C184 358 270 392 350 392 C430 388 478 350 494 282 C470 366 410 404 350 404 C250 404 170 362 118 284 Z", SV)
        a.blob("M140 276 C210 330 300 350 400 326 C440 314 472 294 490 266 C470 340 420 388 350 392 C260 394 180 348 140 276 Z", SV)
        a.ink([(392, 150, 374, 210, 374, 280, 394, 350)], 9, a=0.2, b=0.2, col=NV_D)
    a.sil("M300 330 C262 340 232 372 236 414 C284 408 320 376 330 338 Z", NV_D)
    a.path("M480 268 C488 280 496 278 500 268", sw=7)
    b_side_eye(a, 434, 232, 19, cheek=(-4, 44))
    a.shine("M190 216 C236 178 296 164 350 166")
    return a


def n3_iwashi_one(a, dx, dy, s, BL, BL_D, SV, DOT):
    T = lambda d: d_tf(d, s, dx, dy)
    P = lambda x, y: (s * x + dx, s * y + dy)
    with a.part():
        a.sil(T("M124 256 C98 228 70 196 24 172 C40 216 46 240 58 256 C46 272 40 296 24 340 C70 316 98 284 124 256 Z"), BL_D)
        a.sil(T("M214 178 C236 148 270 138 308 142 C298 158 296 172 298 186 Z"), BL_D)
        a.sil(T("M104 256 C140 196 226 168 318 170 C400 172 462 206 488 256 C462 306 400 340 318 342 C226 344 140 316 104 256 Z"), BL)
        a.blob(T("M126 286 C186 330 280 344 360 336 C420 328 466 296 484 262 C470 312 410 346 330 348 C240 350 160 326 126 286 Z"), SV)
        for x in (200, 250, 300, 350):
            x2, y2 = P(x, 244)
            a.dot(x2, y2, 11 * s, DOT)
    a.sil(T("M290 316 C276 342 254 358 230 360 C240 338 252 320 266 308 Z"), BL_D)
    ex, ey = P(426, 232)
    a.eye(ex, ey, 15 * s)


@word
def iwashi():
    a = Art()
    BL, BL_D, SV, DOT = "#4f84b8", "#3a6a9d", "#eaf1f8", "#2f3a58"
    n3_iwashi_one(a, 160, -150, 0.62, "#6a9cc8", "#5483b0", SV, DOT)
    n3_iwashi_one(a, -70, 236, 0.7, "#5a8cbd", "#4474a6", SV, DOT)
    n3_iwashi_one(a, 40, 40, 0.82, BL, BL_D, SV, DOT)
    return a


@word
def asari():
    a = Art()
    SH, SH_D, SH_L, BR, IN = "#e9d1a2", "#d2b07a", "#f6e6c4", "#8d6a45", "#f7cdb4"
    fan = ("M256 150 C230 150 214 160 210 176 C150 200 78 262 66 330 C68 360 100 384 160 392 C190 402 222 404 256 404 "
           "C290 404 322 402 352 392 C412 384 444 360 446 330 C434 262 362 200 302 176 C298 160 282 150 256 150 Z")
    back = d_tf(d_tf(fan, 1, -256, -150), 1, 256, 140, deg=9)
    with a.part():
        a.sil(back, IN)
        a.blob(d_rim(back, -90, 70, 22), SH_D)
    with a.part():
        a.sil(fan, SH)
        a.blob(d_rim(fan, 70, 80, 28), SH_D)
        a.blob("M232 154 C244 146 268 146 280 154 C278 168 268 176 256 176 C244 176 234 168 232 154 Z", SH_L)
        for ang in range(-58, 62, 22):
            t = math.radians(90 + ang)
            a.ink([(256 + math.cos(t) * 40, 176 + math.sin(t) * 40, 256 + math.cos(t) * 90, 176 + math.sin(t) * 100,
                    256 + math.cos(t) * 150, 176 + math.sin(t) * 160, 256 + math.cos(t) * 200, 176 + math.sin(t) * 210)],
                  8, a=0, b=1, col=BR)
        for r in (110, 170):
            a.ink(d_arc(256, 176, r, 44, 136, ky=0.95), 7, a=0, b=0, col=BR)
    b_face(a, 256, 330, 58, 20, cheek=(98, 36), mouth=38, mw=13)
    a.shine("M118 310 C128 276 156 246 196 230")
    return a


# ---- うみ・なみ
@word
def umi():
    a = Art()
    W1, W1D, SUN, SAND, SANDD = "#5cb8ec", "#3f9fdc", "#ffd24d", "#f9e3a5", "#e8c978"
    with a.part():
        a.sil("M110 250 C110 170 170 116 256 116 C342 116 402 170 402 250 Z", SUN)
    a.blob("M170 232 C184 188 214 160 258 154 C226 176 202 204 196 238 Z", "#ffe58a")
    sea = "M30 250 L482 250 L482 400 L30 400 Z"
    with a.part():
        a.sil(sea, W1)
        a.blob("M30 250 L482 250 L482 280 C400 292 300 270 256 280 C190 292 100 272 30 282 Z", W1D)
        for (x, y) in ((120, 316), (310, 302), (400, 328), (210, 332)):
            a.ink([(x - 40, y + 6, x - 22, y - 12, x + 22, y - 12, x + 40, y + 6)], 8, a=0, b=0, col=WHITE)
    beach = ("M30 372 C110 350 190 366 256 358 C330 348 420 360 482 374 L482 440 C482 458 466 470 446 470 "
             "L66 470 C46 470 30 458 30 440 Z")
    with a.part():
        a.sil(beach, SAND)
        a.blob("M30 424 C150 446 360 446 482 420 L482 440 C482 458 466 470 446 470 L66 470 C46 470 30 458 30 440 Z", SANDD)
        a.ink([(40, 376, 120, 358, 190, 372, 256, 364)], 9, a=0.4, b=0.2, col=WHITE)
        a.ink([(256, 364, 330, 354, 420, 366, 474, 378)], 9, a=0.2, b=0.4, col=WHITE)
        for x, y in ((120, 412), (210, 430), (330, 418), (410, 436)):
            a.dot(x, y, 5, SANDD)
    with a.part(8):
        a.sil("M376 420 C374 400 392 388 412 388 C432 388 448 400 446 420 C432 428 392 428 376 420 Z", "#f9b9c4")
    return a


# ---- いけ・たんぼ
@word
def dojou():
    a = Art()
    BR, BR_D, BELLY, FIN = "#c2a06a", "#9d7d4c", "#f1e2bd", "#b08e5a"
    body = [(420, 250, 340, 380, 250, 400, 190, 330), (190, 330, 140, 270, 100, 230, 40, 262)]
    with a.part():
        a.sil(taper(body, 86, 14), BR)
        a.blob(n2_strip_like(body, 86, 14, 0.4, 0.95, 0.1, 0.9), BELLY)
        for t in (0.22, 0.4, 0.58, 0.76):
            p = at(body, t, 0)
            a.dot(p[0], p[1] - 10, 6, BR_D)
    cx = 410
    for s in (-1, 1):       # 大きな ひげ
        a.ink([(cx + s * 70, 286, cx + s * 120, 280, cx + s * 160, 296, cx + s * 186, 330)], 12, a=1, b=0.5, col=BR_D)
        a.ink([(cx + s * 64, 312, cx + s * 110, 326, cx + s * 150, 350, cx + s * 168, 386)], 12, a=1, b=0.5, col=BR_D)
    with a.part():
        a.sil("M410 168 C468 168 502 206 502 252 C502 298 466 330 410 330 C354 330 318 298 318 252 C318 206 352 168 410 168 Z", BR)
        a.blob("M338 298 C362 322 458 322 482 298 C466 324 440 332 410 332 C380 332 354 324 338 298 Z", BELLY)
    b_face(a, cx, 246, 46, 17, mouth=36, mw=13)
    for s in (-1, 1):
        a.ellipse(cx + s * 76, 278, 14, 8, "#e9a3a8", sw=0, stroke="none")
    a.shine("M346 226 C356 204 376 190 398 184")
    return a


@word
def renge():
    a = Art()
    PK, PK_D, LF, LFD = "#f08ac0", "#d65ea0", "#63b058", "#3f8a44"

    def head(cx, cy, R, rot=0.0):
        n = 11
        with a.part():
            for i in range(n):
                ang = rot + i * 2 * math.pi / n
                bx, by = cx + math.sin(ang) * R * 0.52, cy - math.cos(ang) * R * 0.52
                a.sil(petal(bx, by, R * 0.5, ang, w=0.62, notch=False), PK)
            a.sil_ellipse(cx, cy, R * 0.42, R * 0.42, "#f6a6cf")
        for i in range(n):
            ang = rot + i * 2 * math.pi / n
            bx, by = cx + math.sin(ang) * R * 0.52, cy - math.cos(ang) * R * 0.52
            a.blob(petal(bx, by, R * 0.22, ang, w=0.5, notch=False), WHITE)
            a.ink([(bx, by, bx + math.sin(ang) * R * 0.14, by - math.cos(ang) * R * 0.14,
                    bx + math.sin(ang) * R * 0.28, by - math.cos(ang) * R * 0.28, bx + math.sin(ang) * R * 0.4, by - math.cos(ang) * R * 0.4)],
                  5, a=1, b=0, col=PK_D)
        a.dot(cx, cy, R * 0.16, "#f8d84a")

    def leaves(x, y0, y1):
        with a.part():
            a.sil(taper([(x, y0, x, y0 + 30, x, y1 - 40, x, y1)], 14, 14, cap=False), LFD)
        for k, (yy, s) in enumerate(((y0 + 50, -1), (y0 + 50, 1), (y0 + 100, -1), (y0 + 100, 1))):
            with a.part(8):
                a.sil(d_circ(x + s * (46 + k * 4), yy + 14, 26 + k * 2, 20), LF)
    leaves(256, 270, 490)
    leaves(120, 340, 490)
    leaves(396, 330, 490)
    head(120, 300, 70, 0.2)
    head(396, 290, 74, 0.5)
    head(256, 190, 104, 0.1)
    return a


# ---- どうぶつの あかちゃん
@word
def koushi():
    a = Art()
    WH, WH_D, BR, PK, HOOF = "#fffaf0", "#ebe0cc", "#a9714a", "#f7b3bd", "#8a7060"

    def behind(a):
        a.sil(taper([(462, 270, 500, 280, 514, 320, 506, 376)], 22, 14), WH)
        a.sil("M498 360 C486 372 490 398 506 408 C520 396 520 370 508 360 Z", BR)

    def inside(a):
        a.blob("M264 232 C310 216 358 232 372 270 C376 300 346 318 312 312 C274 304 248 262 264 232 Z", BR)
        a.blob("M392 332 C424 322 452 340 450 366 C436 378 400 370 392 332 Z", BR)

    n2_quad(a, WH, WH_D, hoof=HOOF, behind=behind, inside=inside, belly=PK, k=0.9)
    cx = 190
    with a.part():
        sym(a, "M124 170 C92 148 56 158 48 184 C66 206 104 204 130 192 Z", BR, cx)
        a.sil("M168 104 C160 80 166 60 176 52 C186 66 190 86 186 106 Z", "#f6e7c4")
        a.sil("M212 104 C220 80 214 60 204 52 C194 66 190 86 194 106 Z", "#f6e7c4")
        a.sil(N2_HEAD, WH)
        a.blob("M178 100 C150 104 124 124 112 156 C124 182 152 188 170 170 C186 150 186 124 178 100 Z", BR)
    a.ellipse(cx, 240, 46, 34, PK, sw=0, stroke="none")
    for s in (-1, 1):
        a.ellipse(cx + s * 15, 240, 6, 10, "#c9707f", sw=0, stroke="none")
    a.path("M176 262 C185 269 195 269 204 262", sw=6)
    a_face(a, cx, 192, 40, 16, cheek=(62, 226, 13, 8))
    a.shine("M236 118 C260 126 276 144 282 166")
    return a


# ---- くさむらの いきもの
def n3_caterpillar(a, GN, GND, GNL, HD, LF, LFD, DOT, face_y_shift=0):
    leaf = "M20 470 C60 410 180 390 300 410 C400 424 470 440 492 480 C420 500 120 500 20 470 Z"
    with a.part():
        a.sil(leaf, LF)
        a.blob(d_rim(leaf, 90, 80, 14), LFD)
        a.ink([(40, 468, 160, 452, 330, 454, 480, 476)], 8, a=0.6, b=0, col=LFD)
    with a.part(ow=8):
        for x in (236, 296, 356, 416):
            a.sil(taper([(x, 430, x - 4, 440, x - 6, 448, x - 6, 458)], 18, 12), GND)
    segs = [(430, 388, 52), (384, 378, 56), (338, 370, 60), (292, 366, 62), (246, 362, 62), (204, 364, 60)]
    with a.part():
        for x, y, r in segs[::-1]:
            a.sil_ellipse(x + 8, y, r * 0.8, r, GN)
        for x, y, r in segs[:-1]:
            a.ink([(x - r * 0.4, y - r * 0.9, x - r * 0.55, y - r * 0.3, x - r * 0.55, y + r * 0.3, x - r * 0.4, y + r * 0.9)], 8, a=0.2, b=0.2, col=GND)
        a.blob("M170 410 C230 440 330 440 456 410 C410 440 300 456 230 446 Z", GNL)
        for x, y, r in segs[1:5]:
            a.dot(x + 10, y + r * 0.72, 7, DOT)
    cx = 150
    with a.part():
        a.sil("M150 262 C212 262 244 304 244 358 C244 418 206 454 150 454 C94 454 56 418 56 358 C56 304 88 262 150 262 Z", HD)
    b_antennae(a, cx, (176, 270, 190, 232, 210, 208, 236, 200), r=8)
    b_face(a, cx, 362, 40, 18, mouth=36, mw=12)
    for s in (-1, 1):
        a.ellipse(cx + s * 64, 394, 15, 9, "#f3b3a4", sw=0, stroke="none")
    a.shine("M90 330 C98 306 114 288 136 280")


@word
def aomushi():
    a = Art()
    n3_caterpillar(a, "#8fd45a", "#62b043", "#c8f09a", "#a6e070", "#5fae58", "#3f8a44", "#f7f2a0")
    return a


@word
def kaiko():
    a = Art()
    n3_caterpillar(a, "#fbf6ea", "#d9ceb4", "#ffffff", "#f3ead8", "#6fbf5a", "#46964a", "#8a7a60")
    return a


@word
def mimizu():
    a = Art()
    PKR, PKD, BAND, SOIL, SOILD = "#e8a0a0", "#c97878", "#f3c0b8", "#9a6a44", "#7a5030"
    mound = "M20 470 C40 420 130 396 256 396 C382 396 472 420 492 470 C440 494 72 494 20 470 Z"
    with a.part():
        a.sil(mound, SOIL)
        a.blob(d_rim(mound, 90, 80, 16), SOILD)
        for x, y in ((90, 446), (180, 466), (330, 462), (420, 444), (250, 436)):
            a.dot(x, y, 6, SOILD)
    body = [(430, 410, 480, 300, 400, 270, 330, 320), (330, 320, 270, 360, 220, 320, 200, 250), (200, 250, 190, 190, 140, 170, 96, 196)]
    with a.part():
        a.sil(taper(body, 56, 52), PKR)
        for t in (0.08, 0.16, 0.24, 0.32, 0.4, 0.48, 0.56, 0.64, 0.72, 0.8):
            p0, p1 = at(body, t, 26), at(body, t, -26)
            a.ink([(p0[0], p0[1], p0[0] * 0.67 + p1[0] * 0.33, p0[1] * 0.67 + p1[1] * 0.33, p0[0] * 0.33 + p1[0] * 0.67,
                    p0[1] * 0.33 + p1[1] * 0.67, p1[0], p1[1])], 6, a=0.4, b=0.4, col=PKD)
        a.blob(n2_strip_like(body, 56, 52, -0.9, 0.9, 0.84, 0.94), BAND)
    cx = 96
    b_face(a, 118, 188, 22, 14, mouth=34, mw=10)
    a.shine("M440 330 C444 300 420 280 392 278", sw=8)
    return a


@word
def kamikirimushi():
    a = Art()
    BK, BKD, WHT, LEG = "#3d3a4f", "#2a283a", "#f6f1e2", "#2a283a"
    cx = 256
    with a.part(ow=7):
        for s in (-1, 1):
            a.sil(taper([(cx + s * 100, 350, cx + s * 150, 360, cx + s * 190, 392, cx + s * 210, 430)], 24, 12), LEG)
            a.sil(taper([(cx + s * 110, 300, cx + s * 170, 296, cx + s * 214, 316, cx + s * 236, 350)], 22, 12), LEG)
    for s in (-1, 1):
        a.ink([(cx + s * 40, 120, cx + s * 120, 40, cx + s * 220, 40, cx + s * 250, 130)], 9, a=1, b=0.5, col=LEG)
        a.ink([(cx + s * 30, 128, cx + s * 80, 80, cx + s * 150, 80, cx + s * 200, 150)], 8, a=1, b=0.5, col=LEG)
    body = "M256 150 C330 150 378 210 378 300 C378 400 330 462 256 462 C182 462 134 400 134 300 C134 210 182 150 256 150 Z"
    with a.part():
        a.sil(body, BK)
        a.blob(d_rim(body, 70, 80, 28), BKD)
        for x, y in ((200, 290), (312, 290), (190, 360), (322, 360), (256, 410)):
            a.dot(x, y, 12, WHT)
        a.ink([(256, 214, 256, 280, 256, 360, 256, 450)], 7, a=0, b=0.4, col=BKD)
    with a.part():
        a.sil("M256 100 C316 100 352 136 352 184 C352 224 312 248 256 248 C200 248 160 224 160 184 C160 136 196 100 256 100 Z", BK)
    b_face(a, cx, 176, 46, 18, cheek=(72, 30), mouth=34, mw=12, white=True)
    return a


@word
def shakutorimushi():
    a = Art()
    GN, GND, GNL, BR, BRD = "#9bd05a", "#6aa83e", "#d6f0a4", "#a07148", "#7c5434"
    with a.part():
        a.sil(taper([(10, 430, 140, 404, 380, 420, 506, 392)], 30, 22, cap=False), BR)
        a.ink([(30, 424, 150, 402, 380, 418, 490, 392)], 7, a=0, b=0, col=BRD)
    body = [(430, 410, 440, 270, 400, 150, 310, 140), (310, 140, 230, 140, 190, 230, 176, 380)]
    with a.part(ow=8):
        a.sil(taper([(436, 404, 440, 412, 442, 418, 440, 424)], 24, 14), GND)
    with a.part():
        a.sil(taper(body, 62, 56), GN)
        for t in (0.15, 0.3, 0.45, 0.6, 0.75, 0.88):
            p0, p1 = at(body, t, 31), at(body, t, -31)
            a.ink([(p0[0], p0[1], p0[0] * 0.67 + p1[0] * 0.33, p0[1] * 0.67 + p1[1] * 0.33, p0[0] * 0.33 + p1[0] * 0.67,
                    p0[1] * 0.33 + p1[1] * 0.67, p1[0], p1[1])], 6, a=0.4, b=0.4, col=GND)
        a.blob(n2_strip_like(body, 62, 56, -0.9, -0.5, 0.1, 0.9), GNL)
    with a.part(ow=8):
        a.sil(taper([(176, 384, 176, 396, 176, 404, 176, 412)], 34, 26), GND)
    with a.part():
        a.sil("M176 270 C232 270 262 308 262 354 C262 404 224 436 176 436 C128 436 90 404 90 354 C90 308 120 270 176 270 Z", "#aee06e")
    b_antennae(a, 176, (200, 276, 214, 246, 230, 228, 252, 222), r=8)
    b_face(a, 176, 356, 38, 17, mouth=36, mw=12)
    a.shine("M118 322 C126 302 142 288 162 282")
    return a


@word
def namekuji():
    a = Art()
    BD, BDD, BDL, WET = "#c4b098", "#a08c72", "#e2d4bc", "#ffffff"
    body = [(480, 440, 380, 400, 280, 400, 200, 380)]
    with a.part():
        a.sil("M30 450 C30 380 90 330 170 328 C250 324 330 350 400 376 C450 394 490 410 492 446 C490 464 470 470 440 470 L70 470 C46 470 30 464 30 450 Z", BD)
        a.blob(d_rim("M30 450 C30 380 90 330 170 328 C250 324 330 350 400 376 C450 394 490 410 492 446 C490 464 470 470 440 470 L70 470 C46 470 30 464 30 450 Z", 70, 80, 22), BDD)
        for x, y, r in ((300, 376, 10), (360, 396, 9), (250, 360, 8), (420, 420, 8)):
            a.dot(x, y, r, BDD)
        a.blob("M60 450 C100 462 180 466 260 462 C200 470 100 472 60 450 Z", BDL)
    for s_x, s_y in ((70, 330), (130, 322)):
        a.ink([(s_x + 30, 346, s_x + 24, 320, s_x + 10, 290, s_x - 6, 260)], 10, a=1, b=1, col=BDD)
    a.dot(64, 258, 10, BDD)
    a.dot(124, 250, 10, BDD)
    b_face(a, 96, 400, 30, 16, cheek=(52, 24), mouth=26, mw=10)
    a.shine("M190 360 C240 354 290 366 332 384", sw=8)
    return a


# ---- いけ・たんぼ
@word
def funa():
    a = Art()
    OL, OL_D, BELLY, FIN, SC = "#b9b48c", "#8f8a64", "#f2ecd0", "#a09a70", "#9a9570"
    with a.part():
        a.sil("M110 256 C84 222 56 186 12 160 C28 206 38 238 52 256 C38 274 28 306 12 352 C56 326 84 290 110 256 Z", FIN)
        a.sil("M170 176 C200 120 280 90 360 112 C384 120 396 136 404 156 L360 168 L300 164 L240 172 Z", FIN)
        a.sil("M262 372 C268 410 248 438 208 440 C220 416 226 396 230 366 Z", FIN)
        a.sil("M96 256 C124 190 206 150 300 150 C394 150 462 196 484 256 C462 316 394 366 300 366 C206 366 124 322 96 256 Z", OL)
        a.blob("M134 306 C196 354 322 366 424 316 C396 356 352 372 300 372 C226 372 168 346 134 306 Z", BELLY)
        for x, y in ((220, 216), (270, 210), (320, 214), (370, 232), (240, 256), (292, 252), (344, 262), (196, 270)):
            a.ink([(x - 18, y - 6, x - 8, y + 12, x + 8, y + 12, x + 18, y - 6)], 7, a=0.3, b=0.3, col=SC)
        a.ink([(380, 184, 360, 240, 362, 290, 384, 336)], 8, a=0.2, b=0.2, col=OL_D)
    a.sil("M312 304 C288 310 274 334 280 362 C306 358 326 340 330 314 Z", FIN)
    a.path("M462 272 C470 282 480 280 484 270", sw=7)
    b_side_eye(a, 424, 232, 17, cheek=(-2, 42))
    a.shine("M178 226 C204 190 246 168 296 164")
    return a


@word
def tanbo():
    a = Art()
    EARTH, EARTHD, WATER, WATERD, SPR, SPRD = "#a8794c", "#86603a", "#9ad8f0", "#6cc0e4", "#6fc05a", "#46964a"
    out = "M40 190 C40 160 80 140 256 140 C432 140 472 160 472 190 L500 420 C502 450 470 468 440 468 L72 468 C42 468 10 450 12 420 Z"
    with a.part():
        a.sil(out, EARTH)
        a.blob(d_rim(out, 90, 70, 20), EARTHD)
    inner = "M70 206 C70 186 110 174 256 174 C402 174 442 186 442 206 L468 410 C470 428 450 440 430 440 L82 440 C62 440 42 428 44 410 Z"
    with a.part(8):
        a.sil(inner, WATER)
        a.blob("M120 220 C180 206 330 206 392 220 C340 230 170 230 120 220 Z", "#d4f0fa")
        for row, (y, k, n) in enumerate(((236, 0.62, 5), (310, 0.82, 5), (392, 1.0, 4))):
            for i in range(n):
                x = 256 + (i - (n - 1) / 2) * (84 * k + 14)
                for dx, dy in ((-10, 0), (0, -12), (10, 0)):
                    a.sil(d_blade(x + dx * k, y + 6 * k, 10 * k, x + dx * k * 2.2, y - (30 + dy) * k), SPR)
    a.ink([(110, 420, 160, 414, 220, 418, 260, 414)], 7, a=0, b=0, col=WHITE)
    return a


@word
def gama():
    a = Art()
    LF, LFD, HEAD, HEADD, STEM = "#7cc36a", "#46964a", "#8a5a34", "#6a4228", "#6fa85a"
    with a.part():
        for x, tx, ty in ((70, 20, 250), (120, 70, 190), (400, 470, 220), (440, 500, 280)):
            a.sil(d_blade(x, 490, 30, tx, ty), LFD)
    with a.part():
        for x, ty, bend in ((190, 80, -10), (270, 40, 6), (350, 110, 12)):
            a.sil(taper([(x, 490, x + bend * 0.4, 400, x + bend, 260, x + bend, ty + 90)], 16, 12, cap=False), STEM)
    with a.part():
        for x, ty, bend in ((190, 80, -10), (270, 40, 6), (350, 110, 12)):
            a.sil(f"M{x + bend - 24} {ty + 90} L{x + bend - 24} {ty + 24} C{x + bend - 24} {ty - 6} {x + bend + 24} {ty - 6} {x + bend + 24} {ty + 24} L{x + bend + 24} {ty + 90} C{x + bend + 24} {ty + 108} {x + bend - 24} {ty + 108} {x + bend - 24} {ty + 90} Z", HEAD)
    for x, ty, bend in ((190, 80, -10), (270, 40, 6), (350, 110, 12)):
        a.ink([(x + bend + 10, ty + 20, x + bend + 12, ty + 50, x + bend + 12, ty + 74, x + bend + 8, ty + 92)], 8, a=0, b=0, col=HEADD)
        a.ink([(x + bend + 4, ty - 4, x + bend + 6, ty - 30, x + bend + 2, ty - 50, x + bend, ty - 70)], 5, a=1, b=0, col=STEM)
    with a.part():
        for x, tx, ty in ((256, 120, 330), (300, 420, 340), (220, 256, 270)):
            a.sil(d_blade(x, 492, 36, tx, ty), LF)
    return a


@word
def inago():
    a = Art()
    n3_hopper(a, "#a9c44c", "#6f8a30", "#e6efb0", "#8a9a3c", (270, 280, 350, 290, 430, 300, 500, 314),
              (176, 150, 168, 96, 206, 56, 280, 40), ant_r=7,
              stripe="M262 266 C330 252 430 266 520 316 C440 284 340 282 270 290 Z")
    return a


@word
def amagaeru():
    a = Art()
    GN, GND, GNL, BELLY, PADS, LF, LFD = "#7fd35a", "#58b03c", "#b4ee90", "#f6f0d0", "#f6a8b8", "#4fa650", "#37893f"
    leaf = "M20 470 C40 410 140 392 256 400 C372 392 472 410 492 470 C420 498 92 498 20 470 Z"
    with a.part():
        a.sil(leaf, LF)
        a.blob(d_rim(leaf, 90, 80, 14), LFD)
    with a.part():
        for s in (-1, 1):       # うしろあし
            a.sil(taper([(256 + s * 120, 400, 256 + s * 190, 380, 256 + s * 200, 430, 256 + s * 150, 452)], 56, 34), GND)
    with a.part():
        a.sil("M256 170 C340 170 404 230 404 320 C404 410 340 456 256 456 C172 456 108 410 108 320 C108 230 172 170 256 170 Z", GN)
        a.blob("M178 330 C190 396 322 396 334 330 C318 420 194 420 178 330 Z", BELLY)
        a.blob("M140 250 C150 214 190 190 230 184 C190 210 168 240 164 280 Z", GNL)
    with a.part(8):
        for s in (-1, 1):
            a.sil_ellipse(256 + s * 98, 450, 40, 20, PADS)
            for x in (-18, 0, 18):
                a.sil_ellipse(256 + s * (150 + x * 0.6), 456, 0.1, 0.1, PADS) if False else None
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(256 + s * 70, 190, 52, 52, GN)
    b_face(a, 256, 212, 70, 24, cheek=(104, 84), mouth=118, mw=40)
    a.ink([(176, 276, 220, 268, 292, 268, 336, 276)], 0.1, col=GND)
    a.shine("M150 160 C170 130 210 116 248 120")
    return a


# ---- いろいろな とり
def n3_perch(a, body, belly, wing, wing_line, tail_c, beak_c, rx=96, ry=80, hr=60, tail_end=(480, 440), tail_w=(52, 26),
             beak_len=44, crest=None, brow=None, ring=False, cheek_c=None, bars=None, branch=True, G=432):
    hx, hy = 196, 236
    bx, by = 300, 322
    if branch:
        with a.part(ow=8):
            a.sil(taper([(30, G + 10, 160, G, 360, G + 12, 490, G - 4)], 26, 22), "#a07148")
            a.sil(d_leaf(420, G - 6, 500, G - 70, 40, 0.1), "#6fbf5a")
    with a.part():
        a.sil(taper([(bx + 40, by + 20, bx + 110, by + 60, tail_end[0] - 40, tail_end[1] - 50, tail_end[0], tail_end[1])], tail_w[0], tail_w[1]), tail_c)
    with a.part(ow=8):
        for x in (bx - 20, bx + 24):
            a.sil(taper([(x, by + ry - 10, x, by + ry + 8, x - 2, G - 14, x - 2, G)], 14, 10), "#e4b08e")
            a.sil(f"M{x - 20} {G + 2} C{x - 20} {G - 10} {x + 6} {G - 10} {x + 14} {G - 6} L{x + 14} {G + 4} Z", "#e4b08e")
    with a.part():
        if crest:
            a.sil(crest, body)
        a.sil_ellipse(bx, by, rx, ry, body)
        a.sil_ellipse(hx, hy, hr, hr, body)
        a.sil_ellipse(hx + 46, hy + 52, hr * 0.9, hr * 0.8, body)
        a.blob(d_circ(bx - 10, by + ry * 0.4, rx * 0.74, ry * 0.5), belly)
        a.blob(d_circ(hx + 8, hy + hr * 0.55, hr * 0.6, hr * 0.36), belly)
        if bars:
            for i in range(bars):
                y = by + 20 + i * 18
                a.ink([(bx - 70, y, bx - 40, y + 8, bx + 10, y + 8, bx + 40, y)], 7, a=0.3, b=0.3, col=wing_line)
    with a.part():
        a.sil(f"M{bx - 60} {by - 40} C{bx} {by - 78} {bx + 110} {by - 40} {bx + 150} {by + 40} C{bx + 100} {by + 58} {bx + 10} {by + 40} {bx - 60} {by + 6} Z", wing)
        for k in range(3):
            a.ink([(bx + 20 + k * 22, by - 36 + k * 4, bx + 50 + k * 22, by - 8 + k * 8, bx + 80 + k * 20, by + 12 + k * 6, bx + 120 + k * 12, by + 30 + k * 8)],
                  7, a=0, b=1, col=wing_line)
    with a.part(ow=8):
        a.sil(f"M{hx - hr + 6} {hy - 6} L{hx - hr - beak_len} {hy + 10} L{hx - hr + 4} {hy + 20} Z", beak_c)
    if brow:
        a.ink([(hx - 40, hy - 26, hx - 20, hy - 34, hx + 6, hy - 34, hx + 34, hy - 22)], 9, a=0.5, b=1, col=brow)
    if ring:
        a.ellipse(hx - 10, hy - 6, 26, 26, WHITE, sw=0, stroke="none")
    if cheek_c:
        a.ellipse(hx + 6, hy + 22, 22, 14, cheek_c, sw=0, stroke="none")
    a.eye(hx - 10, hy - 6, 14)
    a.cheek(hx + 30, hy + 20, 12, 8)
    a.shine(f"M{hx - 20} {hy - hr + 18} C{hx} {hy - hr + 6} {hx + 24} {hy - hr + 8} {hx + 40} {hy - hr + 20}", sw=7)


@word
def uguisu():
    a = Art()
    n3_perch(a, "#98984e", "#ece6c8", "#7a7a3a", "#b9b878", "#7a7a3a", "#6a4a3a", rx=92, ry=66, hr=54, tail_end=(496, 452),
             tail_w=(46, 22), beak_len=36, brow="#f4eecc")
    return a


@word
def mejiro():
    a = Art()
    n3_perch(a, "#a6c85a", "#f6f1dc", "#7fa63e", "#cbe48a", "#7fa63e", "#8a8f96", rx=104, ry=96, hr=70, tail_end=(450, 420),
             tail_w=(56, 30), beak_len=34, ring=True, cheek_c=None)
    return a


@word
def kakkou():
    a = Art()
    n3_perch(a, "#9aa5b4", "#f1efe8", "#7a8698", "#cfd6e0", "#7a8698", "#4a4656", rx=106, ry=62, hr=48, tail_end=(506, 462),
             tail_w=(58, 40), beak_len=40, bars=4)
    return a


@word
def hiyodori():
    a = Art()
    crest = "M180 190 C168 160 176 134 192 120 C196 140 206 150 214 164 C224 146 240 138 254 138 C246 156 244 176 238 196 Z"
    n3_perch(a, "#8d8f9d", "#e8e4dc", "#6f7282", "#b6b8c6", "#6f7282", "#4a4656", rx=98, ry=74, hr=58, tail_end=(498, 454),
             tail_w=(54, 36), beak_len=40, crest=crest, cheek_c="#d98a5a")
    return a


@word
def chidori():
    a = Art()
    G = 460
    BR, BRD, WH, LEG = "#c7b496", "#8d7a5c", "#fffdf8", "#f1a98a"
    with a.part(ow=8):
        for x in (280, 332):
            a.sil(taper([(x, 360, x, 400, x - 4, 440, x - 4, G - 10)], 14, 10), LEG)
            a.sil(f"M{x - 4 - 24} {G + 2} C{x - 4 - 24} {G - 12} {x - 4 + 4} {G - 14} {x - 4 + 18} {G - 8} L{x - 4 + 18} {G + 2} Z", LEG)
    with a.part():
        a.sil(taper([(380, 330, 430, 340, 470, 360, 500, 384)], 44, 20), BRD)
    hx, hy = 188, 214
    with a.part():
        a.sil_ellipse(310, 300, 112, 90, BR)
        a.sil_ellipse(hx, hy, 66, 62, WH)
        a.sil_ellipse(236, 286, 76, 66, WH)
        a.blob(d_circ(300, 330, 84, 50), WH)
        a.blob("M260 230 C320 190 420 230 424 300 C380 280 310 270 264 280 Z", BR)
    with a.part():
        a.sil("M290 270 C340 250 420 270 448 320 C410 346 330 340 296 316 Z", BRD)
        a.ink([(320, 288, 360, 284, 400, 292, 432, 312)], 7, a=1, b=0, col=BR)
    with a.part(ow=8):
        a.sil("M132 210 L96 220 L132 232 Z", "#3a3550")
    a.blob("M136 196 C150 190 176 190 214 196 L214 212 C176 208 150 208 136 214 Z", "#3a3550")
    a.eye(172, 208, 13)
    a.cheek(210, 240, 11, 7)
    a.ink([(200, 266, 220, 276, 250, 278, 276, 270)], 8, a=0.5, b=0.5, col=BRD)
    return a


GROUND.add("chidori")


@word
def taka():
    a = Art()
    BR, BR_D, BR_L, CR, BEAK, BAR = "#8a5e3c", "#6a452a", "#a9794f", "#f8ecd6", "#f7c948", "#b98a62"
    with a.part():       # むこうがわの はね
        a.sil("M300 250 C330 170 400 110 480 90 C482 130 462 170 430 200 C410 222 384 240 350 262 Z", BR_D)
    with a.part():       # おび 状の おばね
        a.sil("M360 300 C410 310 470 340 502 392 C470 408 420 400 380 380 Z", BR_D)
        for c in ((380, 330, 410, 340, 440, 356, 470, 376),):
            a.ink([c], 7, a=0, b=0, col=BR)
    with a.part():
        a.sil("M180 260 C190 210 270 190 340 220 C400 246 396 310 350 330 C290 356 196 330 180 260 Z", BR)
        a.blob("M196 290 C230 330 320 346 372 308 C340 350 250 352 206 312 Z", CR)
        for x in (250, 290, 330):
            a.ink([(x - 22, 300 + (x - 250) * 0.1, x - 4, 312 + (x - 250) * 0.1, x + 14, 312 + (x - 250) * 0.1, x + 30, 298 + (x - 250) * 0.1)], 6, a=0.3, b=0.3, col=BAR)
    with a.part():       # てまえの はね（ひろげた）
        a.sil("M268 250 C250 160 190 100 100 70 C90 110 100 160 130 196 C112 206 110 224 124 236 C150 240 170 236 186 224 "
              "C176 240 180 256 196 262 C230 270 262 268 288 256 Z", BR_L)
        a.sil("M268 250 C290 230 330 226 360 240 C340 262 300 270 268 266 Z", BR_L)
        for c in ((130, 196, 180, 220, 230, 244, 272, 256), (124, 236, 170, 250, 220, 262, 262, 268)):
            a.ink([c], 8, a=0, b=1, col=BR_D)
        a.ink([(112, 120, 150, 150, 190, 190, 236, 238)], 7, a=0, b=0.5, col=BR_D)
    with a.part():
        a.sil("M150 232 C150 196 176 170 208 170 C240 170 260 198 254 232 C248 262 222 280 192 278 C164 276 150 256 150 232 Z", CR)
        a.sil("M158 220 C156 184 184 160 214 164 C236 168 250 186 252 204 C230 190 192 194 158 220 Z", BR)
    with a.part(ow=8):
        a.sil("M158 232 C132 226 112 236 108 258 C112 270 124 272 134 262 C142 252 152 246 162 246 Z", BEAK)
    a.eye(190, 218, 15)
    a.ink([(160, 198, 176, 196, 196, 198, 214, 206)], 8, a=0.2, b=0.8, col=BR_D)
    a.cheek(222, 244, 11, 7)
    return a
