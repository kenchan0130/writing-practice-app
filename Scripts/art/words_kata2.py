"""めぐり kata2 の絵（カタカナで書くのがふつうの どうぶつ・ふく・たべもの・はな・やさい・くだもの。D205）。
描き方は Content/Art/style-guide.md（part()/sil()/ink()）。生きものは顔をつけ、物と植物は顔をつけない。"""
import math

from lib import Art, mirror, place, taper, smooth, at, limb_d, O, EYE
from words import (word, GROUND, e2_star, WHITE, CREAM, PINK, PINK_IN, CHEEK, RED, RED_D, YEL, YEL2, SKY, GREEN, WOOD, WOOD_D,
                   BLUE, BLUE_D, NAVY, a_face, a_snout, a_band, a_ear_round, sym, toes, band, b_face, b_side_eye,
                   c_rect, c_circ, c_rpoly, c_line, e2_rr, e2_poly, e2_line, d_circ, d_tf, d_rim, d_poly, d_leaf, d_vein,
                   d_arc, d_curve, petal, LEAF1, LEAF2)
from words_animals2 import N2_BODY

GROUND.update({"raion", "panda", "gorira", "koara", "kangaruu", "pengin", "hamusutaa"})

K_STEM = "#8a5530"


def k_mx(c, cx):
    """Mirror one cubic (8 numbers) around x = cx."""
    return tuple((2 * cx - v) if i % 2 == 0 else v for i, v in enumerate(c))


def k_star_pts(cx, cy, R, r, n, rot=-90.0):
    pts = []
    for i in range(n * 2):
        t = math.radians(rot + i * 180.0 / n)
        rr = R if i % 2 == 0 else r
        pts.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
    return pts


def k_poly(pts):
    return "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"


# ================================================================ どうぶつ ==
@word
def raion():
    a = Art()
    TAN, TAN_D, MANE, MANE_D = "#f2b45c", "#d9953c", "#b8692f", "#9a5424"
    G = 450
    tail = [(456, 296, 512, 300, 540, 262, 528, 214)]
    with a.part():                                       # 奥の脚
        a.sil(limb_d([(302, 330), (308, 388), (312, 434)], [56, 44, 36], G, foot=10, h=18), TAN_D)
        a.sil(limb_d([(398, 330), (384, 374), (402, 408), (398, 434)], [54, 44, 34, 32], G, foot=10, h=18), TAN_D)
    with a.part():
        a.sil(taper(tail, 30, 18), TAN)
        a.sil("M528 236 C502 226 500 182 528 150 C556 182 554 226 528 236 Z", MANE)   # しっぽの ふさ
        a.sil(N2_BODY, TAN)
        a.sil(limb_d([(246, 300), (246, 384), (244, 430)], [84, 54, 44], G, foot=14, h=22), TAN)
        a.sil(limb_d([(440, 300), (430, 366), (452, 404), (448, 430)], [104, 64, 42, 40], G, foot=14, h=22), TAN)
        a.blob("M290 386 C330 388 378 385 402 381 C372 366 322 367 290 386 Z", "#fbdca0")
        a.ink([(402, 388, 392, 354, 400, 318, 430, 296)], 9, a=1, b=0)
        a.ink([(276, 388, 284, 364, 282, 342, 272, 322)], 8, a=1, b=0)
        toes(a, 222, G)
        toes(a, 426, G)
    cx, cy = 190, 190
    tufts = []
    for i in range(16):                                  # たてがみ（とがった房）
        t0 = math.radians(i * 22.5 - 90)
        t1 = math.radians(i * 22.5 - 90 + 11.25)
        tufts.append((cx + 106 * math.cos(t0), cy + 98 * math.sin(t0)))
        tufts.append((cx + 142 * math.cos(t1), cy + 134 * math.sin(t1)))
    with a.part():
        a.sil(k_poly(tufts), MANE)
        for k in (0, 5, 9, 12):
            t = math.radians(k * 22.5 - 90 + 11.25)
            a.ink([(cx + 112 * math.cos(t), cy + 106 * math.sin(t), cx + 120 * math.cos(t), cy + 114 * math.sin(t),
                    cx + 130 * math.cos(t), cy + 124 * math.sin(t), cx + 138 * math.cos(t), cy + 132 * math.sin(t))],
                  8, a=1, b=0, col=MANE_D)
    HEADP = "M190 100 C256 100 292 144 292 196 C292 252 246 284 190 284 C134 284 88 252 88 196 C88 144 124 100 190 100 Z"
    with a.part():
        a_ear_round(a, cx, 70, 122, 30, TAN, CREAM, HEADP)
    a.ellipse(cx, 238, 52, 38, CREAM, sw=0, stroke="none")
    a_snout(a, cx, 222, "#8a4a3a", 15, line=True)
    a_face(a, cx, 186, 46, 17, cheek=(70, 246, 14, 8))
    a.shine("M130 150 C140 134 156 124 176 120")
    return a


@word
def panda():
    a = Art()
    BK, BK_D, GR = "#3d3a42", "#2f2c34", "#8cc063"
    cx = 256
    with a.part():                                       # たけ
        a.sil(taper([(412, 470, 412, 400, 412, 300, 412, 210)], 30, 28), GR)
        a.sil(d_leaf(412, 216, 470, 150, 54, 0.1), "#6aa046")
        a.sil(d_leaf(412, 216, 366, 144, 54, -0.1), "#6aa046")
        for y in (300, 390):
            a.ink([(398, y, 406, y + 4, 418, y + 4, 426, y)], 8, a=1, b=1, col="#5a8a3c")
    with a.part():                                       # 体
        a.sil("M256 244 C334 244 376 312 378 386 C380 436 344 458 256 458 C168 458 132 436 134 386 "
              "C136 312 178 244 256 244 Z", WHITE)
        a.blob("M140 410 C150 440 190 456 256 456 C322 456 362 440 372 410 C366 446 330 460 256 460 "
               "C182 460 146 446 140 410 Z", "#e3e3ea")
    with a.part():                                       # あし（くろ）
        for s in (-1, 1):
            a.sil(f"M{cx + s * 70} 408 C{cx + s * 70} 380 {cx + s * 118} 376 {cx + s * 132} 404 "
                  f"C{cx + s * 150} 436 {cx + s * 130} 462 {cx + s * 96} 462 C{cx + s * 70} 462 {cx + s * 62} 432 {cx + s * 70} 408 Z", BK)
    with a.part():                                       # うで（くろ）
        a.sil(taper([(190, 286, 166, 312, 160, 356, 172, 400)], 64, 52), BK)
        a.sil(taper([(322, 286, 356, 296, 384, 320, 400, 352)], 64, 52), BK)
    cy = 158
    HEADP = "M256 66 C340 66 384 108 384 164 C384 222 332 256 256 256 C180 256 128 222 128 164 C128 108 172 66 256 66 Z"
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 108, 92, 40, 38, BK)
        a.sil(HEADP, WHITE)
    for s in (-1, 1):                                    # 目のまわりの くろ
        a.blob(f"M{cx + s * 70} {cy - 8} C{cx + s * 70} {cy - 40} {cx + s * 28} {cy - 28} {cx + s * 22} {cy + 8} "
               f"C{cx + s * 20} {cy + 40} {cx + s * 76} {cy + 56} {cx + s * 84} {cy + 18} C{cx + s * 88} {cy} "
               f"{cx + s * 80} {cy - 6} {cx + s * 70} {cy - 8} Z", BK)
        a.ellipse(cx + s * 50, cy + 10, 23, 26, WHITE, sw=0, stroke="none")
        a.eye(cx + s * 50, cy + 10, 15)
    a.cheek(cx - 104, cy + 64, 15, 9)
    a.cheek(cx + 104, cy + 64, 15, 9)
    a_snout(a, cx, 192, BK, 13)
    a.shine("M176 104 C190 88 208 78 230 74")
    return a


@word
def gorira():
    a = Art()
    BK, BK_D, CH, FACE = "#625d68", "#4c4852", "#827d89", "#c9bab0"
    cx = 256
    with a.part():
        a.sil("M256 236 C344 230 408 266 414 342 C420 410 384 450 256 450 C128 450 92 410 98 342 "
              "C104 266 168 230 256 236 Z", BK)
        a.sil(taper([(140, 276, 88, 316, 70, 380, 86, 430)], 92, 70), BK)
        a.sil(taper([(372, 276, 424, 316, 442, 380, 426, 430)], 92, 70), BK)
        a.sil("M76 424 C70 450 90 468 112 466 C136 464 144 444 134 426 C124 414 90 410 76 424 Z", BK)
        a.sil("M436 424 C442 450 422 468 400 466 C376 464 368 444 378 426 C388 414 422 410 436 424 Z", BK)
        a.sil_ellipse(190, 450, 56, 24, BK)
        a.sil_ellipse(322, 450, 56, 24, BK)
        a.blob("M256 290 C306 290 336 322 334 366 C332 410 298 436 256 436 C214 436 180 410 178 366 "
               "C176 322 206 290 256 290 Z", CH)
        a.ink([(148, 292, 160, 312, 164, 338, 156, 364)], 9, a=1, b=0, col=BK_D)
        a.ink([(364, 292, 352, 312, 348, 338, 356, 364)], 9, a=1, b=0, col=BK_D)
    HEADP = "M256 74 C328 74 368 118 368 176 C368 234 324 264 256 264 C188 264 144 234 144 176 C144 118 184 74 256 74 Z"
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 114, 178, 20, 28, BK)
        a.sil(HEADP, BK)
        a.sil("M256 52 C300 52 330 72 336 108 L176 108 C182 72 212 52 256 52 Z", BK)    # あたまの もりあがり
    a.blob("M256 126 C304 126 334 152 332 196 C330 238 298 258 256 258 C214 258 182 238 180 196 "
           "C178 152 208 126 256 126 Z", FACE)
    a.path("M196 150 C216 136 296 136 316 150", sw=0, stroke="none")
    a.blob("M188 160 C204 138 308 138 324 160 C300 152 212 152 188 160 Z", BK)         # まゆ
    for s in (-1, 1):
        a.ellipse(cx + s * 44, 178, 20, 24, WHITE, sw=0, stroke="none")
        a.eye(cx + s * 44, 178, 14)
        a.ellipse(cx + s * 14, 222, 6.5, 8.5, O, sw=0, stroke="none")
    a.path("M214 238 C236 252 276 252 298 238", sw=7)
    a.cheek(cx - 76, 214, 13, 8)
    a.cheek(cx + 76, 214, 13, 8)
    a.shine("M170 112 C184 94 204 84 226 80")
    return a


@word
def koara():
    a = Art()
    GY, GY_D, BELLY, EARIN, LF = "#b4b9c6", "#979dac", "#f1f1f4", "#f7f3f5", "#7fb59a"
    cx = 256
    with a.part():                                       # えだ
        a.sil(taper([(20, 462, 140, 452, 360, 456, 492, 440)], 38, 30), "#a9794a")
        a.sil(d_leaf(440, 446, 506, 384, 48, 0.2), LF)
        a.sil(d_leaf(452, 448, 440, 372, 46, -0.1), LF)
    with a.part():
        a.sil("M256 248 C326 248 366 312 368 384 C370 430 336 452 256 452 C176 452 142 430 144 384 "
              "C146 312 186 248 256 248 Z", GY)
        a.blob("M256 300 C294 300 316 336 316 376 C316 420 290 444 256 444 C222 444 196 420 196 376 "
               "C196 336 218 300 256 300 Z", BELLY)
        for s in (-1, 1):
            a.sil(taper([(cx + s * 70, 296, cx + s * 100, 326, cx + s * 104, 372, cx + s * 78, 420)], 58, 48), GY)
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 72, 450, 52, 24, GY)
        a.ink([(176, 448, 182, 430, 192, 416, 204, 410)], 6, a=1, b=0, col=GY_D)
    HEADP = "M256 80 C334 80 376 126 376 182 C376 240 330 268 256 268 C182 268 136 240 136 182 C136 126 178 80 256 80 Z"
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 118, 108, 58, 56, GY)
        a.sil(HEADP, GY)
    for s in (-1, 1):
        a.ellipse(cx + s * 118, 110, 36, 35, EARIN, sw=0, stroke="none")
        for dy, dx in ((-14, 4), (6, 12), (20, -4)):
            a.ink([(cx + s * (118 + dx) - 18, 110 + dy, cx + s * (118 + dx) - 6, 110 + dy - 6,
                    cx + s * (118 + dx) + 6, 110 + dy - 6, cx + s * (118 + dx) + 18, 110 + dy)], 5, a=0, b=0, col="#cfc7cc")
    a.blob(HEADP, GY)
    a.ellipse(cx, 196, 30, 36, "#3c3440", sw=0, stroke="none")                          # おおきな はな
    a.dot(cx - 10, 182, 7, WHITE)
    a.path("M222 246 C236 262 276 262 290 246", sw=7)
    a.eye(cx - 60, 170, 15)
    a.eye(cx + 60, 170, 15)
    a.cheek(cx - 86, 218, 14, 8)
    a.cheek(cx + 86, 218, 14, 8)
    a.shine("M168 116 C180 100 198 90 218 86")
    return a


@word
def kangaruu():
    a = Art()
    BR, BR_D, CR, POUCH = "#d99a5c", "#bd7d40", "#f8e6c4", "#c8864a"
    G = 468
    with a.part():                                       # しっぽ
        a.sil(taper([(372, 392, 420, 430, 460, 452, 512, 462)], 76, 22), BR_D)
    with a.part():                                       # 体と あし
        a.sil("M222 214 C282 200 358 236 386 312 C408 372 400 430 346 448 L262 452 C214 444 200 386 200 336 "
              "C196 286 198 238 222 214 Z", BR)
        a.sil("M312 436 C270 428 206 432 150 444 C126 450 124 470 150 472 L338 472 C362 470 362 448 340 438 Z", BR)
        a.blob("M222 330 C262 330 316 356 330 410 C330 436 296 446 262 448 C226 440 208 400 206 360 Z", CR)
        a.ink([(344, 444, 360, 420, 356, 384, 334, 358)], 9, a=1, b=0)
        a.ink([(150, 463, 200, 462, 250, 462, 300, 462)], 6, a=0.6, b=0.6, col=BR_D)
    with a.part():                                       # ふくろ
        a.sil("M214 328 C230 322 290 326 306 346 C312 388 280 410 252 408 C226 404 208 372 214 328 Z", POUCH)
    with a.part(ow=9):                                   # あかちゃんの かお
        for s in (-1, 1):
            a.sil_ellipse(252 + s * 28, 322, 8, 15, BR)
        a.sil("M252 316 C282 316 298 334 296 354 C294 376 276 384 252 384 C228 384 210 376 208 354 "
              "C206 334 222 316 252 316 Z", BR)
    a.eye(236, 350, 9)
    a.eye(272, 350, 9)
    a.dot(254, 364, 5, "#3c3440")
    cx = 190
    with a.part():                                       # みみ
        for s in (-1, 1):
            a.sil(f"M{cx + s * 40} 98 C{cx + s * 62} 60 {cx + s * 62} 14 {cx + s * 44} 2 "
                  f"C{cx + s * 22} 22 {cx + s * 14} 66 {cx + s * 14} 100 Z", BR)
    HEADP = "M190 74 C232 74 254 112 252 152 C250 192 226 208 190 208 C154 208 130 192 128 152 C126 112 148 74 190 74 Z"
    a.sil(HEADP, BR)
    for s in (-1, 1):
        a.blob(f"M{cx + s * 36} 92 C{cx + s * 52} 62 {cx + s * 52} 28 {cx + s * 44} 18 "
               f"C{cx + s * 28} 34 {cx + s * 24} 66 {cx + s * 24} 94 Z", PINK_IN)
    a.blob(HEADP, BR)
    a.ellipse(cx, 178, 36, 26, CR, sw=0, stroke="none")
    a.path("M176 160 C176 152 204 152 204 160 C204 170 196 176 190 176 C184 176 176 170 176 160 Z", fill="#3c3440", sw=0, stroke="none")
    a.path("M190 178 L190 186 M190 186 C184 196 172 196 170 188 M190 186 C196 196 208 196 210 188", sw=6)
    a_face(a, cx, 136, 38, 15, cheek=(56, 170, 13, 8))
    return a


@word
def pengin():
    a = Art()
    BK, FT, BEAK = "#3f4a5e", "#f7a94b", "#f7a94b"
    cx = 256
    with a.part():                                       # あし
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 60, 462, 48, 17, FT)
    with a.part():                                       # はね
        for s in (-1, 1):
            a.sil(f"M{cx + s * 112} 236 C{cx + s * 160} 280 {cx + s * 174} 346 {cx + s * 154} 396 "
                  f"C{cx + s * 128} 386 {cx + s * 106} 330 {cx + s * 100} 270 Z", BK)
    with a.part():
        a.sil("M256 62 C338 62 386 136 388 240 C390 352 352 454 256 454 C160 454 122 352 124 240 "
              "C126 136 174 62 256 62 Z", BK)
    a.blob("M256 178 C236 140 186 138 172 176 C158 216 160 290 166 350 C172 418 210 446 256 446 "
           "C302 446 340 418 346 350 C352 290 354 216 340 176 C326 138 276 140 256 178 Z", WHITE)
    a.blob("M300 400 C324 380 336 350 340 316 C346 368 330 414 296 436 Z", "#dfe3ee")
    a.path("M232 204 C236 188 276 188 280 204 C280 226 266 240 256 244 C246 240 232 226 232 204 Z", fill=BEAK, sw=7)
    a.path("M240 214 C250 220 262 220 272 214", sw=5, stroke="#d98a2e")
    a.eye(cx - 54, 170, 16)
    a.eye(cx + 54, 170, 16)
    a.cheek(cx - 86, 214, 14, 8)
    a.cheek(cx + 86, 214, 14, 8)
    a.shine("M172 108 C192 84 220 74 250 72")
    return a


@word
def rakko():
    a = Art()
    BR, BR_D, CR, FACE = "#8a6244", "#6f4c33", "#d9b48c", "#f1d9b8"
    WATER, WATER_D = "#bfe6fa", "#8fcdf0"
    with a.part():                                       # しっぽ
        a.sil(taper([(430, 330, 466, 326, 490, 310, 504, 286)], 44, 22), BR)
    with a.part():                                       # からだ（あおむけ）
        a.sil("M130 292 C180 244 370 246 434 296 C470 326 456 388 400 398 L210 400 C150 392 104 340 130 292 Z", BR)
        a.blob("M170 306 C220 280 350 282 404 316 C420 350 396 384 340 388 L222 388 C176 380 150 340 170 306 Z", CR)
    with a.part(ow=9):                                   # かい
        a.sil("M236 322 C250 296 314 296 330 322 C340 348 322 364 284 366 C246 364 226 348 236 322 Z", "#fbe9ee")
        for dx in (-26, -9, 9, 26):
            a.ink([(283, 362, 283 + dx * 0.4, 346, 283 + dx * 0.8, 330, 283 + dx, 314)], 6, a=1, b=0, col="#e8a9bb")
    with a.part(ow=9):                                   # て
        for x in (242, 326):
            a.sil_ellipse(x, 344, 22, 17, BR)
    cx = 170
    HEADP = "M170 108 C234 108 266 150 266 196 C266 246 224 276 170 276 C116 276 74 246 74 196 C74 150 106 108 170 108 Z"
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 78, 128, 24, 22, BR)
        a.sil(HEADP, FACE)
    a.ellipse(cx, 232, 46, 32, "#fffaf0", sw=0, stroke="none")
    a.path("M154 214 C154 204 186 204 186 214 C186 224 178 230 170 230 C162 230 154 224 154 214 Z", fill="#3c3440", sw=0, stroke="none")
    a.path("M170 230 L170 238 M170 238 C164 248 152 248 150 240 M170 238 C176 248 188 248 190 240", sw=6)
    a_face(a, cx, 178, 44, 15, cheek=(68, 226, 13, 8))
    a.shine("M104 160 C114 142 130 130 150 124")
    a.blob("M40 396 C70 376 100 376 130 396 C160 416 190 416 220 396 C250 376 280 376 310 396 C340 416 370 416 400 396 "
           "C420 384 440 382 472 392 C490 412 488 452 460 464 L62 464 C34 456 28 420 40 396 Z", WATER)
    a.blob("M52 432 C80 416 110 416 140 432 C170 448 200 448 230 432 C260 416 290 416 320 432 C350 448 380 448 410 432 "
           "C430 422 446 420 470 428 C468 448 462 458 452 462 L66 462 C56 456 54 444 52 432 Z", WATER_D)
    a.path("M60 396 C76 386 96 386 112 396", sw=6, stroke=WHITE, **{"stroke-opacity": "0.85"})
    a.path("M296 394 C312 384 332 384 348 394", sw=6, stroke=WHITE, **{"stroke-opacity": "0.85"})
    return a


@word
def ashika():
    a = Art()
    BODY, DARK, BELLY = "#7b8594", "#5f6a78", "#aeb7c3"
    pts = [(98, 170), (136, 130), (200, 106), (262, 124), (292, 190), (320, 286), (342, 376), (382, 428), (452, 440),
           (480, 470), (384, 476), (290, 464), (238, 420), (228, 340), (226, 262), (204, 218), (150, 208)]
    with a.part():                                       # うしろの ひれ
        a.sil("M360 430 C400 404 460 408 498 436 C480 474 410 480 372 458 Z", DARK)
    with a.part():
        a.sil(smooth(pts), BODY)
        a.blob("M204 222 C226 270 228 340 238 410 C262 450 330 466 386 466 C320 450 286 430 270 380 C260 320 262 262 236 226 Z", BELLY)
        a.ink([(300, 230, 310, 280, 326, 330, 342, 376)], 8, a=0, b=0, col=DARK)
    with a.part(9):                                      # まえびれ
        a.sil(taper([(252, 300, 206, 322, 168, 354, 148, 402)], 44, 22), DARK)
    with a.part(9):                                      # ボール
        a.sil(c_circ(104, 96, 46), WHITE)
        for ang, col in ((0, RED), (60, YEL2), (120, BLUE), (180, RED), (240, YEL2), (300, BLUE)):
            r0, r1 = math.radians(ang), math.radians(ang + 60)
            a.blob(f"M104 96 L{104 + 46 * math.cos(r0):.1f} {96 + 46 * math.sin(r0):.1f} "
                   f"L{104 + 46 * math.cos(r1):.1f} {96 + 46 * math.sin(r1):.1f} Z", col)
    a.shine("M74 84 C80 72 92 64 104 62", sw=8)
    a.dot(104, 168, 8, "#2f2b38")
    a.eye(178, 150, 15)
    a.cheek(196, 192, 13, 8)
    for dy in (-4, 8):
        a.ink([(122, 182 + dy, 100, 188 + dy, 76, 196 + dy, 54, 206 + dy)], 5, a=1, b=0.3, col=O)
    a.shine("M160 126 C176 114 194 110 214 112", sw=7)
    return a


@word
def hamusutaa():
    a = Art()
    TAN, TAN_D, CR, PK = "#f2c48d", "#d9a56c", "#fff1dc", "#f5a9b5"
    cx = 256
    with a.part(ow=9):                                   # あし
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 70, 454, 34, 14, PK)
    BODY = ("M256 118 C366 118 424 198 424 298 C424 398 366 456 256 456 C146 456 88 398 88 298 C88 198 146 118 256 118 Z")
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 104, 138, 38, 36, TAN)
        a.sil(BODY, TAN)
        for s in (-1, 1):
            a.ellipse(cx + s * 100, 142, 22, 21, PK, sw=0, stroke="none")
        a.blob("M256 118 C320 118 372 150 396 210 C340 170 172 170 116 210 C140 150 192 118 256 118 Z", TAN_D)
        a.blob("M256 236 C332 236 380 296 380 352 C380 414 334 448 256 448 C178 448 132 414 132 352 "
               "C132 296 180 236 256 236 Z", CR)
    a.path("M240 214 C240 204 272 204 272 214 C272 224 262 230 256 230 C250 230 240 224 240 214 Z", fill="#f28a9b", sw=0, stroke="none")
    a.path("M256 230 L256 238 M256 238 C250 248 238 248 236 240 M256 238 C262 248 274 248 276 240", sw=6)
    for d in ("M190 226 L150 216", "M190 240 L150 244"):
        a.path(d, sw=5)
        a.path(mirror(d, cx), sw=5)
    a.eye(cx - 62, 186, 17)
    a.eye(cx + 62, 186, 17)
    a.cheek(cx - 100, 236, 18, 11)
    a.cheek(cx + 100, 236, 18, 11)
    with a.part(ow=9):                                   # ひまわりの たね
        a.sil("M256 318 C288 318 300 356 288 392 C278 414 234 414 224 392 C212 356 224 318 256 318 Z", "#ebe3d4")
        for dx in (-14, 0, 14):
            a.ink([(256 + dx, 324, 256 + dx * 1.2, 346, 256 + dx * 1.2, 370, 256 + dx * 0.9, 398)], 8, a=0.4, b=0.2, col="#5a4a42")
    with a.part(ow=9):
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 34, 380, 18, 16, TAN)
    a.shine("M150 168 C166 148 190 134 216 130")
    return a


@word
def inko():
    a = Art()
    GR, GR_D, GRL, YL, BLU, BEAK = "#6fcf62", "#4fae52", "#a9e58a", "#ffe36b", "#4fa8e0", "#f7a94b"
    cx = 256
    with a.part(ow=9):                                   # とまりぎ
        a.sil(taper([(60, 438, 180, 434, 340, 434, 452, 438)], 26, 26), "#a9794a")
    with a.part():                                       # しっぽ
        a.sil(taper([(256, 360, 262, 410, 276, 450, 306, 494)], 54, 24), BLU)
    b_feet = [(210, 436), (300, 436)]
    with a.part(ow=8):
        for x, y in b_feet:
            a.sil(f"M{x - 26} {y} C{x - 30} {y - 16} {x - 12} {y - 26} {x} {y - 26} C{x + 12} {y - 26} {x + 30} {y - 16} {x + 26} {y} "
                  f"C{x + 12} {y + 6} {x - 12} {y + 6} {x - 26} {y} Z", BEAK)
    with a.part():
        a.sil("M256 190 C336 190 374 268 374 336 C374 396 332 430 256 430 C180 430 138 396 138 336 "
              "C138 268 176 190 256 190 Z", GR)
        a.blob("M256 250 C310 250 336 300 336 346 C336 396 304 420 256 420 C208 420 176 396 176 346 "
               "C176 300 202 250 256 250 Z", GRL)
        for s in (-1, 1):
            a.sil(f"M{cx + s * 106} 262 C{cx + s * 152} 306 {cx + s * 156} 384 {cx + s * 118} 420 "
                  f"C{cx + s * 90} 396 {cx + s * 82} 330 {cx + s * 84} 276 Z", GR_D)
            for y in (310, 342, 374):
                a.ink([(cx + s * 104, y, cx + s * 114, y + 6, cx + s * 126, y + 6, cx + s * 136, y)], 6, a=0, b=0, col="#3c8a42")
    HEADP = "M256 68 C328 68 366 110 366 166 C366 224 320 258 256 258 C192 258 146 224 146 166 C146 110 184 68 256 68 Z"
    a.sil(HEADP, YL)
    a.blob("M256 68 C324 68 358 100 364 140 C330 108 182 108 148 140 C154 100 188 68 256 68 Z", GR)
    for s in (-1, 1):
        a.blob(f"M{cx + s * 72} 186 C{cx + s * 72} 172 {cx + s * 100} 172 {cx + s * 102} 188 "
               f"C{cx + s * 102} 204 {cx + s * 76} 206 {cx + s * 72} 186 Z", "#6fb7e8")
        a.ellipse(cx + s * 50, 156, 24, 27, WHITE, sw=0, stroke="none")
        a.eye(cx + s * 50, 156, 14)
    a.path("M234 186 C238 170 274 170 278 186 C278 206 266 218 256 222 C246 218 234 206 234 186 Z", fill=BEAK, sw=7)
    a.cheek(cx - 100, 214, 13, 8)
    a.cheek(cx + 100, 214, 13, 8)
    a.shine("M178 112 C194 94 214 84 238 80")
    return a


# ==================================================================== ふく ==
@word
def zubon():
    a = Art()
    JN, JN_D, JN_L, ST = "#5b8fd0", "#3f6fb0", "#8db4e8", "#f7d36b"
    with a.part():
        a.sil("M148 72 L364 72 C370 72 374 76 375 82 L398 440 C399 454 390 464 376 464 L304 464 C292 464 286 456 284 446 "
              "L262 214 C260 206 252 206 250 214 L228 446 C226 456 220 464 208 464 L136 464 C122 464 113 454 114 440 "
              "L137 82 C138 76 142 72 148 72 Z", JN)
        a.blob("M148 72 L364 72 C370 72 374 76 375 82 L376 104 L136 104 L137 82 C138 76 142 72 148 72 Z", JN_D)
        for x0, x1 in ((124, 224), (288, 388)):
            a.blob(f"M{x0} 424 L{x1} 424 L{x1 + 3} 446 C{x1 + 4} 460 {x1 - 6} 464 {x1 - 14} 464 L{x0 + 14} 464 "
                   f"C{x0 + 4} 464 {x0 - 4} 456 {x0 - 3} 446 Z", JN_L)
        a.ink([(256, 108, 256, 140, 256, 176, 256, 206)], 7, a=1, b=0, col=JN_D)
        a.ink([(150, 140, 170, 152, 196, 160, 224, 160)], 7, a=1, b=0, col=JN_D)
        a.ink([(362, 140, 342, 152, 316, 160, 288, 160)], 7, a=1, b=0, col=JN_D)
        a.ink([(236, 214, 234, 280, 230, 360, 228, 424)], 7, a=0, b=0, col=JN_D)
        a.ink([(276, 214, 278, 280, 282, 360, 284, 424)], 7, a=0, b=0, col=JN_D)
    a.blob(e2_rr(238, 78, 36, 20, 8), ST)
    for x in (160, 220, 292, 352):
        a.blob(e2_rr(x - 6, 62, 12, 48, 5), JN_L)
    a.shine("M148 130 L160 330", sw=7)
    return a


@word
def sukaato():
    a = Art()
    PK, PK_D, PK_L = "#f58aa5", "#e0698a", "#ffc4d2"
    with a.part():
        a.sil("M178 84 L334 84 C340 84 344 88 346 94 L438 408 C442 420 438 430 428 436 "
              "C410 456 380 440 350 456 C320 470 290 446 256 458 C222 470 192 446 162 456 C132 440 102 456 84 436 "
              "C74 430 70 420 74 408 L166 94 C168 88 172 84 178 84 Z", PK)
        a.blob("M178 84 L334 84 C340 84 344 88 346 94 L354 122 L158 122 L166 94 C168 88 172 84 178 84 Z", PK_D)
        a.blob("M96 422 C130 432 150 420 162 432 C192 448 222 434 256 442 C290 434 320 448 350 432 C362 420 382 432 416 422 "
               "L428 436 C410 456 380 440 350 456 C320 470 290 446 256 458 C222 470 192 446 162 456 C132 440 102 456 84 436 Z", PK_D)
        for x0, y0, x1, y1 in ((226, 130, 196, 404), (256, 130, 256, 420), (286, 130, 316, 404),
                               (196, 130, 128, 396), (316, 130, 384, 396)):
            a.ink([(x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)],
                  8, a=0, b=0, col=PK_D)
    for x, y in ((200, 200), (312, 200), (256, 250), (160, 300), (352, 300), (220, 340), (292, 340), (256, 398), (128, 380), (384, 380)):
        a.dot(x, y, 10, PK_L)
    a.shine("M186 100 L136 360", sw=7)
    return a


@word
def kooto():
    a = Art()
    GN, GN_D, GN_L, BT = "#4aa36a", "#388552", "#7cc596", "#f7d36b"
    with a.part():
        a.sil("M168 96 C200 82 312 82 344 96 L372 440 C374 458 364 466 350 466 L162 466 C148 466 138 458 140 440 Z", GN)
        a.sil("M158 104 C112 112 86 152 78 212 L58 392 C56 406 64 416 78 418 L126 424 C140 424 146 416 148 404 "
              "L168 236 Z", GN)
        a.sil("M354 104 C400 112 426 152 434 212 L454 392 C456 406 448 416 434 418 L386 424 C372 424 366 416 364 404 "
              "L344 236 Z", GN)
        a.blob("M58 392 L148 404 C146 416 140 424 126 424 L78 418 C64 416 56 406 58 392 Z", GN_D)
        a.blob("M454 392 L364 404 C366 416 372 424 386 424 L434 418 C448 416 456 406 454 392 Z", GN_D)
        a.blob("M140 428 L372 428 L374 440 C374 458 364 466 350 466 L162 466 C148 466 138 458 140 440 Z", GN_D)
        a.ink([(168, 236, 150, 300, 146, 350, 148, 404)], 8, a=0.6, b=0, col=GN_D)
        a.ink([(344, 236, 362, 300, 366, 350, 364, 404)], 8, a=0.6, b=0, col=GN_D)
    with a.part(ow=9):                                   # えり
        a.sil("M200 90 L256 190 L312 90 C292 78 220 78 200 90 Z", "#fff4e2")
        a.sil("M186 96 L226 154 L256 192 L230 120 Z", GN_L)
        a.sil("M326 96 L286 154 L256 192 L282 120 Z", GN_L)
    for y in (240, 300, 360, 420):
        a.circle(256, y, 15, BT, sw=8)
        a.dot(256, y, 4, "#d9a92e")
    for s in (-1, 1):
        a.path(f"M{256 + s * 70} 318 L{256 + s * 118} 318 L{256 + s * 116} 366 L{256 + s * 72} 366 Z", sw=7, stroke=GN_D, fill="none")
    a.shine("M178 120 L170 220", sw=7)
    return a


@word
def ribon():
    a = Art()
    RB, RB_D, RB_L = "#f2678a", "#d94a70", "#ff9db6"
    loop = ("M246 244 C210 170 120 126 76 168 C34 208 50 318 108 338 C160 354 220 296 246 270 Z")
    with a.part():                                       # しっぽ（さがる はね）
        a.sil("M236 282 C224 340 200 392 160 436 L214 450 L246 410 L252 290 Z", RB)
        a.sil(mirror("M236 282 C224 340 200 392 160 436 L214 450 L246 410 L252 290 Z", 256), RB)
    with a.part():
        a.sil(loop, RB)
        a.sil(mirror(loop, 256), RB)
        a.blob("M246 244 C214 190 150 160 108 178 C140 196 188 226 246 270 Z", RB_L)
        a.blob(mirror("M246 244 C214 190 150 160 108 178 C140 196 188 226 246 270 Z", 256), RB_L)
        a.ink([(236, 258, 190, 238, 140, 244, 100, 280)], 8, a=1, b=0, col=RB_D)
        a.ink([(276, 258, 322, 238, 372, 244, 412, 280)], 8, a=1, b=0, col=RB_D)
        a.ink([(228, 330, 212, 372, 192, 404, 170, 428)], 7, a=1, b=0, col=RB_D)
        a.ink([(284, 330, 300, 372, 320, 404, 342, 428)], 7, a=1, b=0, col=RB_D)
    with a.part():
        a.sil(e2_rr(222, 222, 68, 86, 28), RB_D)
    a.blob("M236 236 C240 230 252 228 258 230 C248 240 244 262 244 290 C238 280 232 256 236 236 Z", RB_L)
    return a


def k_boot(s, main, shade, trim):
    with s.part():
        s.sil("M212 66 L338 66 L344 300 C346 340 372 360 386 392 C392 408 392 436 374 436 L92 436 "
              "C60 436 46 408 62 386 C80 362 140 358 190 336 C210 326 214 306 214 280 Z", main)
        s.blob("M62 386 C46 408 60 436 92 436 L374 436 C392 436 392 408 386 392 L380 384 C300 412 130 418 62 386 Z", shade)
        s.blob("M300 70 L338 66 L344 300 C346 340 372 360 386 392 L360 392 C340 360 312 340 308 300 Z", shade)
        s.ink([(214, 280, 216, 306, 206, 326, 190, 336)], 8, a=0, b=1, col=shade)
    with s.part(ow=9):
        s.sil("M200 50 C230 36 320 36 350 50 C362 70 354 96 342 104 L214 104 C198 96 190 70 200 50 Z", trim)
    s.blob("M70 428 L384 428 L384 440 L70 440 Z", "#5a4a42")


@word
def buutsu():
    a = Art()
    BR, BR_D, FUR = "#b0703c", "#8a5530", "#fff4e2"
    k_boot(a, "#8a5530", "#6f4326", "#e8dcc8")
    front = Art()
    k_boot(front, BR, BR_D, FUR)
    place(a, front, -50, 34)
    a.shine("M262 180 L262 280")
    return a


@word
def mafuraa():
    a = Art()
    RD, RD_D, WH = "#e5534b", "#c9403a", "#fff4e2"
    with a.part():
        a.sil("M70 130 C130 214 382 214 442 130 C456 166 450 208 428 236 C370 296 142 296 84 236 C62 208 58 166 70 130 Z", RD)
    with a.part():                                       # さがる はし（ながい）
        a.sil("M312 262 C346 278 386 276 414 264 L440 440 L350 456 Z", RD)
    with a.part():                                       # みじかい はし
        a.sil("M196 270 C226 282 262 282 286 270 L296 392 L214 400 Z", RD)
    for (x0, x1, y0, y1) in ((330, 428, 316, 330), (342, 432, 366, 380)):
        a.blob(f"M{x0} {y0} L{x1 + 4} {y0 - 6} L{x1 + 6} {y1 - 4} L{x0 + 4} {y1 + 8} Z", WH)
    a.blob("M205 330 L291 324 L293 344 L207 350 Z", WH)
    a.blob("M334 410 L436 402 L440 424 L338 434 Z", WH)
    a.blob("M350 456 L440 440 L441 444 L351 462 Z", RD_D)
    for x in (360, 380, 400, 420, 436):
        a.ink([(x, 450, x + 2, 462, x + 4, 474, x + 6, 484)], 8, a=1, b=0.4, col=RD)
    for x in (222, 244, 266, 288):
        a.ink([(x, 394, x + 2, 408, x + 3, 420, x + 4, 430)], 8, a=1, b=0.4, col=RD)
    a.ink([(100, 214, 200, 258, 330, 258, 420, 214)], 8, a=0.3, b=0.3, col=RD_D)
    a.shine("M92 168 C110 204 160 232 220 244", sw=7)
    return a


# ================================================== やさい・くだもの・はな ==
def k_hatch(a, cx, cy, rx, ry, deg, gap, col, w=6, margin=10, spread=None):
    """Parallel thin lines across an ellipse (net, diamonds), cut short so they stay inside the shape."""
    dx, dy = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    nx, ny = -dy, dx
    span = spread or max(rx, ry)
    n = int(span / gap) + 1
    for i in range(-n, n + 1):
        d = i * gap
        px, py = nx * d, ny * d
        A = (dx / rx) ** 2 + (dy / ry) ** 2
        B = 2 * (px * dx / rx ** 2 + py * dy / ry ** 2)
        C = (px / rx) ** 2 + (py / ry) ** 2 - 1
        disc = B * B - 4 * A * C
        if disc <= 0:
            continue
        t0 = (-B - math.sqrt(disc)) / (2 * A) + margin
        t1 = (-B + math.sqrt(disc)) / (2 * A) - margin
        if t1 - t0 < 16:
            continue
        x0, y0, x1, y1 = cx + px + dx * t0, cy + py + dy * t0, cx + px + dx * t1, cy + py + dy * t1
        a.ink([(x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)],
              w, a=0.5, b=0.5, col=col)


@word
def tomato():
    a = Art()
    TM, TM_D, SEPAL = "#ef4b3f", "#cf3a30", "#5aa84c"
    body = "M256 128 C384 106 442 198 438 296 C434 396 358 448 256 448 C154 448 78 396 74 296 C70 198 128 106 256 128 Z"
    with a.part():
        a.sil(body, TM)
        a.blob(d_rim(body, 42, 62, 32), TM_D)
        a.ink([(200, 140, 226, 158, 286, 158, 312, 140)], 8, a=0, b=0)
    with a.part(9):
        for k in range(5):
            t = math.radians(-90 + 72 * k + 36)
            tip = (256 + 100 * math.cos(t), 150 + 48 * math.sin(t))
            a.sil(d_leaf(256, 150, tip[0], tip[1], 44), SEPAL)
        a.sil(taper([(256, 154, 254, 128, 258, 106, 270, 84)], 18, 14), "#3c8a42")
    a.shine("M130 262 C128 220 150 182 188 160", sw=9)
    return a


@word
def kyabetsu():
    a = Art()
    LT, MID, DK, VEIN = "#bfe486", "#9fd45f", "#74b94a", "#e4f5c8"
    ball = d_circ(256, 266, 188, 178)
    with a.part():
        a.sil(ball, LT)
        a.blob(d_rim(ball, 40, 62, 28), MID)
        a.ink([(256, 86, 230, 120, 200, 140, 170, 150)], 8, a=0, b=0, col=DK)
    with a.part():                                       # そとの はっぱ（ひだり）
        a.sil("M92 330 C50 250 76 170 150 126 C132 196 156 274 214 336 C230 396 200 450 160 452 C124 450 100 396 92 330 Z", DK)
        a.ink([(100, 330, 120, 260, 148, 200, 170, 150)], 8, a=0, b=0, col=VEIN)
    with a.part():                                       # そとの はっぱ（みぎ）
        a.sil("M420 330 C462 250 436 170 362 126 C380 196 356 274 298 336 C282 396 312 450 352 452 C388 450 412 396 420 330 Z", DK)
        a.ink([(412, 330, 392, 260, 364, 200, 342, 150)], 8, a=0, b=0, col=VEIN)
    for t in (-0.6, -0.3, 0, 0.3, 0.6):
        x = 256 + 150 * t
        a.ink([(256, 436, 256 + (x - 256) * 0.4, 380, x, 330, x * 1.0 + (x - 256) * 0.1, 270)], 8, a=1, b=0, col=VEIN)
    a.ink([(180, 200, 220, 170, 290, 170, 336, 202)], 7, a=0.2, b=0.2, col=VEIN)
    a.shine("M150 270 C152 232 170 200 200 182", sw=9)
    return a


@word
def piiman():
    a = Art()
    GR, GR_D, ST = "#5cb85a", "#3f9a44", "#3c8a42"
    body = ("M198 126 C148 138 118 196 122 272 C126 350 150 438 198 446 C226 450 242 418 256 418 C270 418 286 450 314 446 "
            "C362 438 386 350 390 272 C394 196 364 138 314 126 C292 120 270 136 256 136 C242 136 220 120 198 126 Z")
    with a.part():
        a.sil(taper([(256, 140, 252, 112, 262, 88, 290, 70)], 36, 24), ST)
        a.sil(body, GR)
        a.blob(d_rim(body, 38, 64, 34), GR_D)
        a.ink([(230, 330, 236, 366, 240, 396, 244, 420)], 8, a=0.2, b=0, col=GR_D)
        a.ink([(282, 330, 276, 366, 272, 396, 268, 420)], 8, a=0.2, b=0, col=GR_D)
    a.blob("M222 128 C238 118 274 118 292 128 C282 150 232 150 222 128 Z", ST)
    a.shine("M160 230 C158 196 172 162 198 146", sw=9)
    return a


@word
def chuurippu():
    a = Art()
    PT, PT_L, PT_D, LF, LF_D = "#f2506e", "#ff7a92", "#d93a58", "#6fbd5c", "#4f9e48"
    with a.part():
        a.sil(taper([(256, 240, 254, 320, 258, 400, 256, 476)], 22, 18, cap=False), LF)
        a.sil(d_leaf(250, 474, 110, 250, 74, -0.1), LF)
        a.sil(d_leaf(262, 474, 410, 290, 66, 0.1), LF)
        d_vein(a, 246, 468, 120, 260, LF_D, t0=0.1, t1=0.8)
        d_vein(a, 266, 468, 404, 296, LF_D, t0=0.1, t1=0.8)
    with a.part():
        a.sil("M168 106 C214 128 238 180 232 244 C204 262 156 250 142 206 C134 170 146 130 168 106 Z", PT_D)
        a.sil("M344 106 C298 128 274 180 280 244 C308 262 356 250 370 206 C378 170 366 130 344 106 Z", PT_D)
    with a.part():
        a.sil("M256 54 C298 98 326 154 318 226 C306 262 206 262 194 226 C186 154 214 98 256 54 Z", PT)
        a.blob("M256 54 C290 96 312 142 314 192 C296 150 268 120 256 120 Z", PT_L)
        a.ink([(256, 130, 252, 170, 252, 212, 256, 250)], 7, a=0, b=0, col=PT_D)
    a.sil_ellipse(256, 262, 40, 14, LF)
    a.shine("M214 150 C220 128 232 108 244 96", sw=8)
    return a


def k_flower(a, cx, cy, R, n, col, vein, center, w=0.46, rot=0.0):
    with a.part():
        for i in range(n):
            a.sil(petal(cx, cy, R, rot + i * 2 * math.pi / n, w=w, notch=True), col)
        for i in range(n):
            an = rot + (i + 0.5) * 2 * math.pi / n
            sx, sy = math.sin(an), -math.cos(an)
            a.ink([(cx + sx * R * 0.2, cy + sy * R * 0.2, cx + sx * R * 0.34, cy + sy * R * 0.34,
                    cx + sx * R * 0.48, cy + sy * R * 0.48, cx + sx * R * 0.6, cy + sy * R * 0.6)], R * 0.06, a=1, b=0, col=vein)
        a.blob(d_circ(cx, cy, R * 0.22), center)
    a.dot(cx - R * 0.06, cy - R * 0.06, R * 0.05, "#fff0a8")


@word
def kosumosu():
    a = Art()
    with a.part():
        a.sil(taper([(256, 280, 250, 350, 262, 420, 256, 480)], 16, 14, cap=False), "#6fbd5c")
        a.sil(d_leaf(256, 440, 150, 372, 56, -0.1), "#6fbd5c")
        a.sil(d_leaf(256, 410, 366, 340, 56, 0.1), "#6fbd5c")
        d_vein(a, 252, 436, 160, 376, "#4f9e48", w=6, t0=0.1, t1=0.8)
        d_vein(a, 258, 408, 356, 344, "#4f9e48", w=6, t0=0.1, t1=0.8)
    k_flower(a, 256, 190, 168, 8, "#f77fb0", "#e0558c", "#f7c948", w=0.5)
    a.shine("M150 130 C164 112 184 98 206 92", sw=8)
    return a


@word
def kuroobaa():
    a = Art()
    LF, LF_D, VEIN = "#5cb85a", "#3f9a44", "#a9e58a"
    heart = "M0 0 C-70 -16 -84 -108 -32 -118 C-12 -120 -2 -106 0 -92 C2 -106 12 -120 32 -118 C84 -108 70 -16 0 0 Z"
    cx, cy = 256, 236
    with a.part():
        a.sil(taper([(256, 250, 262, 330, 282, 410, 316, 480)], 22, 16, cap=False), LF_D)
    with a.part():
        for deg in (0, 120, 240):
            a.sil(d_tf(heart, 1.7, cx, cy, deg), LF)
        for deg in (0, 120, 240):
            t = math.radians(deg - 90)
            ca, sa = math.cos(t), math.sin(t)
            a.ink([(cx + ca * 22, cy + sa * 22, cx + ca * 70, cy + sa * 70, cx + ca * 112, cy + sa * 112,
                    cx + ca * 150, cy + sa * 150)], 8, a=0.8, b=0, col=VEIN)
        for deg in (60, 180, 300):
            t = math.radians(deg - 90)
            ca, sa = math.cos(t), math.sin(t)
            a.ink([(cx, cy, cx + ca * 14, cy + sa * 14, cx + ca * 28, cy + sa * 28, cx + ca * 42, cy + sa * 42)],
                  9, a=1, b=0, col=LF_D)
    a.shine("M196 120 C214 98 238 88 258 86", sw=8)
    return a


# ================================================================ たべもの ==
PLATE, PLATE_IN = "#fbf8f2", "#ece6da"


def k_plate(a, cx=256, cy=404, rx=232, ry=82):
    with a.part():
        a.sil_ellipse(cx, cy, rx, ry, PLATE)
    a.ellipse(cx, cy - 4, rx * 0.72, ry * 0.68, PLATE_IN, sw=0, stroke="none")


def k_about(d, s, deg, cx, cy, tx=0.0, ty=0.0):
    """Scale and turn a path around (cx, cy), then move it by (tx, ty)."""
    c, sn = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    dx = cx - s * (cx * c - cy * sn) + tx
    dy = cy - s * (cx * sn + cy * c) + ty
    return d_tf(d, s, dx, dy, deg)


@word
def omuraisu():
    a = Art()
    YL, YL_D, KC = "#ffd84a", "#f2b630", "#e5534b"
    k_plate(a)
    dome = ("M104 392 C94 294 170 212 256 212 C342 212 418 294 408 392 C396 432 326 440 256 440 "
            "C186 440 116 432 104 392 Z")
    with a.part():
        a.sil(dome, YL)
        a.blob(d_rim(dome, 50, 62, 34), YL_D)
    a.ink([(150, 330, 164, 262, 200, 252, 214, 306), (214, 306, 226, 356, 246, 352, 258, 296),
           (258, 296, 268, 240, 304, 236, 314, 296), (314, 296, 324, 348, 348, 340, 362, 278)], 20, a=0.3, b=0.3, col=KC)
    a.shine("M138 340 C134 296 156 254 196 232", sw=9)
    with a.part(7):                                      # はたの ようじ
        a.sil(taper([(334, 252, 336, 200, 338, 150, 340, 96)], 8, 8), "#c9a46a")
    with a.part(7):
        a.sil("M342 96 L420 96 L408 118 L420 140 L342 140 Z", BLUE)
    a.blob(e2_star(374, 118, 14, 6), YEL2)
    return a


@word
def hanbaagu():
    a = Art()
    BR, BR_D, SC = "#9a5530", "#7a4020", "#6b3418"
    k_plate(a)
    patty = d_circ(272, 358, 160, 100)
    with a.part():
        a.sil(patty, BR)
        a.blob(d_rim(patty, 60, 62, 30), BR_D)
    a.blob("M150 352 C150 308 206 280 272 280 C338 280 394 308 394 348 C394 380 340 396 300 392 C284 410 262 396 240 394 "
           "C190 390 150 380 150 352 Z", "#b8662f")
    k_hatch(a, 272, 346, 112, 62, 35, 38, "#4a2410", 13, 14, 120)
    a.blob("M186 322 C200 304 232 294 262 292 C232 300 208 314 196 332 Z", "#e0a060")
    with a.part(8):                                      # ブロッコリー
        a.sil(taper([(110, 458, 112, 430, 114, 410, 116, 390)], 22, 24, cap=False), "#8cc063")
        a.sil(d_circ(116, 364, 60, 44), "#4f9e48")
        a.sil(d_circ(86, 384, 32, 28), "#4f9e48")
        a.sil(d_circ(148, 386, 32, 28), "#4f9e48")
    with a.part(8):                                      # にんじん
        a.sil(c_circ(386, 440, 36, 20), "#f7931e")
        a.sil(c_circ(440, 424, 30, 18), "#f7931e")
    a.blob(c_circ(386, 440, 20, 10), "#fdb84e")
    a.blob(c_circ(440, 424, 16, 9), "#fdb84e")
    return a


@word
def karee():
    a = Art()
    RC, CU, CU_D = "#fffdf6", "#b5651d", "#8f4c12"
    k_plate(a)
    puddle = ("M96 400 C84 340 150 300 230 304 C310 296 410 310 424 372 C432 420 360 446 280 446 "
              "C200 450 112 444 96 400 Z")
    with a.part():
        a.sil(puddle, CU)
        a.blob(d_rim(puddle, 70, 70, 22), CU_D)
    rice = "M120 366 C108 296 164 244 226 254 C272 262 290 318 284 372 C250 396 160 396 120 366 Z"
    with a.part():
        a.sil(rice, RC)
        a.blob("M120 366 C160 396 250 396 284 372 C282 384 246 400 204 400 C164 400 128 386 120 366 Z", "#e6e0d2")
    for x, y in ((160, 300), (206, 286), (246, 316), (180, 338), (226, 350), (140, 340)):
        a.ink([(x - 8, y, x - 3, y - 3, x + 3, y - 3, x + 8, y)], 6, a=0.5, b=0.5, col="#d8d0be")
    with a.part(8):
        a.sil(e2_rr(318, 326, 46, 34, 12), "#f7931e")
        a.sil("M366 362 C388 348 418 360 414 384 C410 406 378 410 364 396 C354 384 356 370 366 362 Z", "#e8c477")
        a.sil(e2_rr(300, 392, 40, 30, 12), "#f7931e")
    with a.part(7):                                      # スプーン
        a.sil(taper([(400, 428, 432, 380, 456, 330, 470, 262)], 20, 14), "#dfe6ec")
        a.sil_ellipse(392, 432, 34, 22, "#dfe6ec")
    a.blob(c_circ(386, 428, 20, 12), "#b5651d")
    a.shine("M262 330 C270 316 290 308 316 306", sw=8)
    return a


@word
def supagetti():
    a = Art()
    NO, NO_D, SA, SA_D = "#f7d56a", "#e0b040", "#e5534b", "#c9403a"
    k_plate(a)
    nest = "M112 408 C98 310 172 236 256 236 C340 236 414 310 400 408 C386 442 320 446 256 446 C192 446 126 442 112 408 Z"
    with a.part():
        a.sil(nest, NO)
        a.blob(d_rim(nest, 60, 62, 30), NO_D)
        for rx, y, a0, a1 in ((132, 330, 190, 350), (104, 360, 200, 340), (76, 388, 190, 350), (120, 312, 20, 160),
                              (92, 346, 20, 160), (62, 376, 20, 160), (146, 372, 210, 330), (150, 400, 200, 340)):
            a.ink(d_arc(256, y, rx, a0, a1, rx * 0.95, 0.42), 9, a=0.5, b=0.5, col="#c9962a")
    sauce = "M186 276 C184 240 228 222 256 230 C290 220 330 240 326 278 C316 312 198 312 186 276 Z"
    with a.part():
        a.sil(sauce, SA)
        a.blob(d_rim(sauce, 60, 60, 16), SA_D)
    with a.part(7):
        a.sil(d_leaf(262, 232, 326, 196, 40, 0.2), "#5cb85a")
    a.shine("M206 262 C214 248 228 240 244 238", sw=7)
    with a.part(7):                                      # フォーク
        a.sil(taper([(360, 300, 392, 240, 420, 180, 440, 110)], 22, 16), "#dfe6ec")
        for dx in (-14, 0, 14):
            a.sil(taper([(352 + dx * 0.4, 312, 346 + dx, 284, 344 + dx * 1.3, 262, 346 + dx * 1.5, 244)], 9, 8), "#dfe6ec")
    return a


@word
def piza():
    a = Art()
    CR, CR_D, SA, CH, CH_D = "#e2a45a", "#c98a40", "#e5534b", "#ffd45c", "#f0b93c"
    with a.part():
        a.sil(c_circ(256, 256, 206), CR)
        a.blob(d_rim(c_circ(256, 256, 206), 50, 70, 26), CR_D)
        a.blob(c_circ(256, 256, 176), SA)
        a.blob(c_circ(256, 256, 164), CH)
        a.blob(d_rim(c_circ(256, 256, 164), 50, 70, 18), CH_D)
    for (x, y) in ((190, 170), (320, 190), (160, 300), (290, 306), (360, 330), (240, 232)):
        a.blob(c_circ(x, y, 32), "#d9453a")
        a.dot(x - 8, y - 6, 5, "#b8302a")
        a.dot(x + 10, y + 4, 5, "#b8302a")
    for (x, y) in ((264, 150), (212, 360), (350, 250)):
        a.blob(c_circ(x, y, 26) + " " + c_circ(x, y, 14, ccw=True), "#5cb85a")
    for (x, y) in ((140, 220), (320, 360), (400, 250)):
        a.blob(c_circ(x, y, 16, 12) + " " + c_circ(x, y, 7, 5, ccw=True), "#3d3a42")
    for deg in (0, 60, 120):
        t = math.radians(deg - 90)
        a.ink([(256 - 164 * math.cos(t), 256 - 164 * math.sin(t), 256 - 100 * math.cos(t), 256 - 100 * math.sin(t),
                256 + 100 * math.cos(t), 256 + 100 * math.sin(t), 256 + 164 * math.cos(t), 256 + 164 * math.sin(t))],
              7, a=0.3, b=0.3, col=CH_D)
    a.shine("M120 190 C140 150 176 118 218 104", sw=9)
    return a


@word
def hottokeeki():
    a = Art()
    SIDE, TOP, SY = "#f3cf8e", "#e0a050", "#c8741a"
    with a.part():
        a.sil_ellipse(256, 470, 240, 50, PLATE)
    for y in (392, 332, 272):
        slab = (f"M100 {y} C100 {y - 26} 150 {y - 36} 256 {y - 36} C362 {y - 36} 412 {y - 26} 412 {y} L412 {y + 46} "
                f"C412 {y + 70} 362 {y + 80} 256 {y + 80} C150 {y + 80} 100 {y + 70} 100 {y + 46} Z")
        with a.part():
            a.sil(slab, SIDE)
            a.blob(d_circ(256, y, 156, 36), TOP)
            a.blob(f"M100 {y + 34} C150 {y + 62} 362 {y + 62} 412 {y + 34} L412 {y + 46} C412 {y + 70} 362 {y + 80} 256 {y + 80} "
                   f"C150 {y + 80} 100 {y + 70} 100 {y + 46} Z", "#e8b66a")
    with a.part(8):
        a.sil("M128 276 C128 252 190 242 256 242 C322 242 384 252 384 276 C384 300 362 304 354 326 C350 346 334 346 330 328 "
              "C326 310 304 312 296 302 C278 314 256 308 238 302 C222 318 218 350 206 350 C196 350 194 326 188 314 "
              "C170 306 128 302 128 276 Z", SY)
    a.blob("M170 262 C196 252 236 250 262 252 C230 256 196 262 176 274 Z", "#f0a040")
    with a.part(8):
        a.sil(e2_rr(220, 196, 74, 50, 10), "#fff0a0")
        a.blob(e2_rr(220, 232, 74, 14, 8), "#f2d96a")
    return a


@word
def pan():
    a = Art()
    CRUST, CRUMB = "#d99a4e", "#fff0cc"
    slice_d = ("M112 252 C74 214 98 146 170 148 C198 126 314 126 342 148 C414 146 438 214 400 252 L400 412 "
               "C400 438 386 450 362 450 L150 450 C126 450 112 438 112 412 Z")
    back = k_about(slice_d, 1.0, 9, 256, 300, 62, -8)
    with a.part():
        a.sil(back, "#c98a40")
        a.sil(k_about(slice_d, 0.84, 9, 256, 300, 62, -8), "#f6e0b0")
    with a.part():
        a.sil(slice_d, CRUST)
    a.blob(k_about(slice_d, 0.84, 0, 256, 300), CRUMB)
    a.blob("M112 252 C74 214 98 146 170 148 C130 170 128 224 156 250 Z", "#e8b86a")
    for x, y in ((190, 250), (270, 220), (320, 290), (220, 330), (300, 380), (180, 392), (350, 232), (250, 280)):
        a.dot(x, y, 4.5, "#efd9a6")
    a.shine("M150 190 C170 166 200 156 236 156", sw=9)
    return a


def k_tri_sand(a, cx, top, H, base):
    """One triangular sandwich seen from the cut side: bread, lettuce, tomato, cheese, ham, bread in bands."""
    def hw(f):
        return base / 2 * f

    def y(f):
        return top + H * f

    def band(f0, f1, col):
        a.blob(f"M{cx - hw(f0):.1f} {y(f0):.1f} L{cx + hw(f0):.1f} {y(f0):.1f} L{cx + hw(f1):.1f} {y(f1):.1f} "
               f"L{cx - hw(f1):.1f} {y(f1):.1f} Z", col)

    with a.part():
        a.sil(f"M{cx:.1f} {top:.1f} L{cx + base / 2:.1f} {top + H:.1f} L{cx - base / 2:.1f} {top + H:.1f} Z", "#fde9b8")
    band(0.78, 1.0, "#fde9b8")
    band(0.68, 0.78, "#ff9db6")
    band(0.60, 0.68, "#ffd45c")
    band(0.50, 0.60, "#ef4b3f")
    band(0.40, 0.50, "#6fbd5c")
    band(0.0, 0.40, "#fde9b8")
    for f0, f1 in ((0.0, 0.40), (0.78, 1.0)):                  # パンの みみ
        for sgn in (-1, 1):
            a.blob(f"M{cx + sgn * hw(f0):.1f} {y(f0):.1f} L{cx + sgn * hw(f1):.1f} {y(f1):.1f} "
                   f"L{cx + sgn * (hw(f1) - 22):.1f} {y(f1):.1f} L{cx + sgn * (hw(f0) + 0):.1f} {y(f0) + 4:.1f} Z", "#e1a85a")
    a.blob(f"M{cx - base / 2:.1f} {top + H - 14:.1f} L{cx + base / 2:.1f} {top + H - 14:.1f} L{cx + base / 2:.1f} {top + H:.1f} "
           f"L{cx - base / 2:.1f} {top + H:.1f} Z", "#e1a85a")
    for x in (-0.5, -0.15, 0.2, 0.5):
        a.dot(cx + x * hw(0.55), y(0.55), 4, "#ffd8c8")


@word
def sandoicchi():
    a = Art()
    k_tri_sand(a, 330, 150, 210, 330)
    k_tri_sand(a, 190, 250, 210, 330)
    return a


@word
def kukkii():
    a = Art()
    DG, DG_D, CH = "#e2a95f", "#c98f45", "#5a3820"

    def cookie(cx, cy, r, chips):
        pts = [(cx + (r + (6 if i % 2 else -4)) * math.cos(i * math.pi / 7), cy + (r + (6 if i % 2 else -4)) * math.sin(i * math.pi / 7))
               for i in range(14)]
        d = smooth(pts)
        with a.part():
            a.sil(d, DG)
            a.blob(d_rim(d, 50, 66, 18), DG_D)
        for dx, dy, rr in chips:
            a.blob(d_circ(cx + dx, cy + dy, rr, rr * 0.8), CH)
            a.blob(d_circ(cx + dx - rr * 0.3, cy + dy - rr * 0.3, rr * 0.3, rr * 0.22), "#8a6244")

    cookie(176, 188, 118, ((-30, -30, 18), (36, -50, 16), (-60, 34, 14), (40, 30, 18), (0, 76, 12)))
    cookie(346, 168, 100, ((-20, -30, 15), (30, 10, 17), (-30, 40, 13), (24, -52, 11)))
    cookie(290, 336, 132, ((-50, -40, 20), (30, -60, 17), (60, 6, 20), (-70, 30, 16), (0, 40, 19), (36, 78, 14), (-26, 88, 13)))
    a.shine("M110 168 C112 130 140 100 184 90", sw=9)
    return a


@word
def keeki():
    a = Art()
    SP, SP_D, CRM, JAM = "#f9d98a", "#e6b862", "#fffaf0", "#e5534b"
    with a.part():
        a.sil_ellipse(256, 456, 240, 42, PLATE)
    face = e2_rr(90, 270, 330, 150, 14)
    with a.part():
        a.sil(face, SP)
        a.blob(e2_rr(90, 306, 330, 22, 0), CRM)
        a.blob(e2_rr(90, 368, 330, 22, 0), JAM)
        a.blob(e2_rr(90, 398, 330, 22, 10), SP_D)
        a.ink([(100, 340, 160, 332, 220, 346, 260, 340)], 5, a=0, b=0, col=SP_D)
    with a.part():
        a.sil("M90 272 C110 214 150 196 190 196 L440 196 C436 230 428 250 420 272 Z", CRM)
        a.sil("M90 272 C100 252 140 250 200 256 C260 262 340 252 420 272 Z", CRM)
    with a.part(8):                                      # いちご
        a.sil("M256 150 C286 150 300 178 292 208 C284 236 266 248 256 248 C246 248 228 236 220 208 C212 178 226 150 256 150 Z", RED)
        a.sil(d_leaf(256, 154, 292, 126, 34, 0.1), "#5cb85a")
        a.sil(d_leaf(256, 154, 220, 126, 34, -0.1), "#5cb85a")
    for x, y in ((244, 188), (268, 190), (256, 214), (240, 218), (272, 220)):
        a.dot(x, y, 3.5, "#ffe9b0")
    with a.part(8):
        a.sil("M366 226 C354 196 372 180 390 184 C408 178 424 196 412 226 Z", CRM)
    a.shine("M114 296 L114 396", sw=7)
    return a


@word
def doonatsu():
    a = Art()
    DG, DG_D, IC, IC_D = "#e8b66a", "#c98f45", "#ff8fb3", "#f2709c"
    with a.part():
        a.sil(c_circ(256, 256, 206) + " " + c_circ(256, 256, 58, ccw=True), DG)
    pts = [(256 + (176 + (8 if i % 2 else -4)) * math.cos(i * math.pi / 8), 256 + (176 + (8 if i % 2 else -4)) * math.sin(i * math.pi / 8))
           for i in range(16)]
    a.blob(smooth(pts) + " " + c_circ(256, 256, 78, ccw=True), IC)
    a.blob(d_rim(smooth(pts), 50, 60, 20), IC_D)
    cols = ["#ffffff", "#ffe36b", "#6fb7e8", "#8cc063", "#f7a94b"]
    for k, (x, y, ang) in enumerate(((150, 170, 20), (216, 120, 100), (306, 122, 60), (370, 190, 150), (392, 296, 30),
                                     (330, 380, 110), (230, 396, 70), (150, 346, 130), (120, 260, 0), (282, 178, 40), (186, 214, 80))):
        c, s = math.cos(math.radians(ang)) * 14, math.sin(math.radians(ang)) * 14
        a.ink([(x - c, y - s, x - c / 3, y - s / 3, x + c / 3, y + s / 3, x + c, y + s)], 9, a=1, b=1, col=cols[k % 5])
    a.shine("M120 220 C128 170 164 128 214 108", sw=9)
    return a


@word
def chokoreeto():
    a = Art()
    CH, CH_D, CH_L = "#8a5334", "#6b3d22", "#a8704a"
    bar = e2_rr(110, 40, 292, 330, 22)
    with a.part():
        a.sil(bar, CH)
    for r in range(4):
        for c in range(3):
            x, y = 124 + c * 94, 54 + r * 80
            a.blob(e2_rr(x, y, 80, 68, 10), CH_L)
            a.blob(e2_rr(x + 6, y + 8, 70, 58, 8), CH)
            a.blob("M%d %d L%d %d L%d %d L%d %d Z" % (x + 8, y + 62, x + 74, y + 62, x + 70, y + 54, x + 12, y + 54), CH_D)
    with a.part():                                       # つつみがみ
        a.sil("M96 300 C140 316 200 292 256 304 C312 316 372 292 416 306 L416 448 C416 464 404 472 388 472 L124 472 "
              "C108 472 96 464 96 448 Z", "#e5534b")
        a.blob("M96 300 C140 316 200 292 256 304 C312 316 372 292 416 306 L416 330 C372 316 312 340 256 328 "
               "C200 316 140 340 96 324 Z", "#dfe6ec")
        a.blob("M96 430 L416 430 L416 448 C416 464 404 472 388 472 L124 472 C108 472 96 464 96 448 Z", "#c9403a")
    a.blob(e2_rr(166, 372, 180, 46, 12), "#fff4e2")
    a.blob(e2_rr(180, 384, 152, 6, 3), "#e5534b")
    a.blob(e2_rr(200, 398, 112, 6, 3), "#e5534b")
    a.shine("M128 84 L128 150", sw=7)
    return a
