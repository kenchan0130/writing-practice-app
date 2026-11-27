"""めぐり animals2 の絵（どうぶつ・とり・むし・みずの いきもの）。描き方は Content/Art/style-guide.md（D176）。"""
import math

from lib import Art, mirror, shift, O, EYE, taper, smooth, at, limb_d
from words import (word, GROUND, note, WHITE, CREAM, PINK, PINK_IN, CHEEK, RED, YEL2, a_face, a_snout, a_wool, a_band,
                   hoofed, band, sym, toes, e1_sub, b_face, b_side_eye, b_bird_feet, b_antennae)

GROUND.update({"yagi", "roba", "shimauma", "sai", "inoshishi", "ookami", "koinu", "koneko", "nezumi",
               "harinezumi", "mogura", "wani"})

N2_BODY = ("M214 250 C262 214 392 214 444 240 C490 262 496 330 468 366 C446 388 380 382 330 384 "
           "C280 386 236 394 212 358 C196 326 198 280 214 250 Z")
N2_HEAD = "M190 100 C254 100 290 144 290 194 C290 250 246 286 190 286 C134 286 90 250 90 194 C90 144 126 100 190 100 Z"


def n2_mx(c, cx):
    """Mirror a cubic (8 numbers) around x = cx."""
    return tuple((2 * cx - v) if i % 2 == 0 else v for i, v in enumerate(c))


def n2_quad(a, col, shade, G=450, hoof=None, behind=None, inside=None, k=1.0, belly=None):
    """A side-view body with four legs (head goes on the left, at cx = 190). Far legs in the shade colour,
    near legs in the body's part. hoof = colour for hoofed legs, None = round paws. k = leg thickness."""
    w = lambda *v: [x * k for x in v]
    with a.part():
        if hoof:
            hoofed(a, [(304, 340), (310, 396), (312, 432)], w(52, 40, 34), G, shade, hoof, hh=18)
            hoofed(a, [(398, 340), (388, 392), (392, 432)], w(52, 40, 34), G, shade, hoof, hh=18)
        else:
            a.sil(limb_d([(302, 330), (308, 388), (312, 434)], w(54, 42, 34), G, foot=10, h=18), shade)
            a.sil(limb_d([(398, 330), (384, 374), (402, 408), (398, 434)], w(52, 42, 32, 30), G, foot=10, h=18), shade)
    with a.part():
        if behind:
            behind(a)
        a.sil(N2_BODY, col)
        if hoof:
            hoofed(a, [(250, 320), (250, 392), (250, 432)], w(80, 50, 40), G, col, hoof, hh=18)
            hoofed(a, [(444, 320), (440, 390), (444, 432)], w(96, 54, 40), G, col, hoof, hh=18)
        else:
            a.sil(limb_d([(246, 300), (246, 384), (244, 432)], w(80, 50, 40), G, foot=13, h=21), col)
            a.sil(limb_d([(440, 300), (430, 366), (452, 406), (448, 432)], w(100, 60, 38, 36), G, foot=14, h=21), col)
        a.blob("M290 386 C330 388 380 384 406 382 C400 372 398 364 398 356 C362 366 322 366 292 362 Z", belly or shade)
        if inside:
            inside(a)
        a.ink([(404, 390, 394, 358, 402, 322, 430, 300)], 9, a=1, b=0)
        a.ink([(282, 390, 290, 366, 288, 344, 278, 324)], 8, a=1, b=0)
        if not hoof:
            toes(a, 224, G)
            toes(a, 428, G)


# ------------------------------------------------------------ まきば --
@word
def yagi():
    a = Art()
    WH, WH_D, HORN, HOOF = "#fffaf0", "#e9dfcd", "#c9a877", "#6b5a50"
    n2_quad(a, WH, WH_D, hoof=HOOF,
            behind=lambda a: a.sil(taper([(462, 268, 486, 256, 500, 236, 500, 214)], 34, 16), WH))
    cx = 190
    HEADP = "M190 106 C242 106 274 142 274 188 C274 240 238 280 190 280 C142 280 106 240 106 188 C106 142 138 106 190 106 Z"
    with a.part():
        sym(a, taper([(166, 126, 158, 92, 138, 66, 108, 58)], 32, 13), HORN, cx)
        for s in (-1, 1):
            a.ink([n2_mx((150, 100, 158, 96, 164, 94, 170, 94), cx) if s > 0 else (150, 100, 158, 96, 164, 94, 170, 94)],
                  6, a=1, b=0, col="#a88a5c")
    with a.part():
        sym(a, "M124 178 C96 158 60 162 48 182 C64 206 100 206 128 196 Z", WH, cx)
        a.sil("M166 268 C170 296 180 318 190 332 C200 318 210 296 214 268 Z", WH)
        a.sil(HEADP, WH)
        sym(a, "M112 182 C96 172 78 174 68 184 C80 196 98 196 116 192 Z", PINK_IN, cx, sil=False)
        a.blob(HEADP, WH)
        a.ink([(182, 284, 184, 298, 187, 310, 190, 322)], 6, a=0, b=0, col=WH_D)
    a.ellipse(cx, 242, 36, 25, "#f7e4d2", sw=0, stroke="none")
    a.path("M180 230 L200 230 L190 241 Z", fill="#f28a9b", sw=5)
    a.path("M190 241 L190 248 M190 248 C185 258 174 258 172 250 M190 248 C195 258 206 258 208 250", sw=6)
    a_face(a, cx, 194, 40, 16, cheek=(60, 232, 13, 8))
    return a


@word
def roba():
    a = Art()
    GR, GR_D, MANE, MZ, HOOF = "#b3aaa3", "#978e88", "#6a5d56", "#f6efe4", "#4f433d"

    def behind(a):
        a.sil(taper([(462, 262, 508, 268, 528, 312, 520, 356)], 18, 12), GR)
        a.sil("M520 340 C500 356 502 392 522 406 C540 390 540 354 520 340 Z", MANE)

    with a.part():
        a.sil("M236 96 C290 110 322 168 312 250 L250 262 Z", MANE)
    n2_quad(a, GR, GR_D, hoof=HOOF, behind=behind, belly=MZ)
    cx = 190
    HEADP = ("M190 78 C246 78 274 116 272 162 C270 200 262 222 254 240 C244 268 222 282 190 282 "
             "C158 282 136 268 126 240 C118 222 110 200 108 162 C106 116 134 78 190 78 Z")
    ear = "M140 130 C112 84 112 26 134 -12 C166 20 184 74 184 118 Z"
    with a.part():
        sym(a, ear, GR, cx)
        a.sil(HEADP, GR)
        sym(a, "M146 112 C130 80 130 44 138 18 C158 44 168 80 168 106 Z", PINK_IN, cx, sil=False)
        a.blob(HEADP, GR)
    a.ellipse(cx, 240, 60, 38, MZ, sw=0, stroke="none")
    a.sil("M168 88 C172 66 208 66 212 88 C212 104 206 114 202 122 C200 110 194 108 190 120 "
          "C186 108 180 110 178 122 C174 114 168 104 168 88 Z", MANE)
    for s in (-1, 1):
        a.ellipse(cx + s * 20, 238, 6.5, 9.5, O, sw=0, stroke="none")
    a.path("M174 260 C185 269 195 269 206 260", sw=7)
    a_face(a, cx, 172, 42, 17, cheek=(60, 206, 14, 8))
    a.shine("M434 244 C452 248 466 262 470 284", sw=7)
    return a


@word
def shimauma():
    a = Art()
    WH, WH_D, BK, HOOF = "#fffdf8", "#e6e3ea", "#4a4656", "#3d3946"

    def behind(a):
        a.sil(taper([(462, 262, 508, 268, 528, 312, 520, 356)], 18, 12), WH)
        a.sil("M520 340 C500 356 502 392 522 406 C540 390 540 354 520 340 Z", BK)

    def inside(a):
        for x, y, L in ((300, 226, 80), (346, 222, 96), (392, 224, 92), (436, 236, 60)):
            a.ink([(x, y, x + 8, y + L * 0.3, x + 6, y + L * 0.7, x - 8, y + L)], 15, a=1, b=0, col=BK)
        a.ink([(490, 300, 474, 300, 462, 304, 452, 312)], 12, a=1, b=0, col=BK)
        for x, w in ((250, 22), (444, 22)):
            for y in (388, 410):
                a.ink([(x - w, y, x - w / 2, y + 2, x + w / 2, y + 2, x + w, y)], 8, a=1, b=1, col=BK)

    n2_quad(a, WH, WH_D, hoof=HOOF, behind=behind, inside=inside)
    cx = 190
    HEADP = ("M190 78 C246 78 274 116 272 162 C270 200 262 222 254 240 C244 268 222 282 190 282 "
             "C158 282 136 268 126 240 C118 222 110 200 108 162 C106 116 134 78 190 78 Z")
    with a.part():      # たてがみ（頭の後ろに立つ）
        a.sil("M150 100 C150 40 174 22 190 22 C206 22 230 40 230 100 Z", BK)
    with a.part():
        sym(a, "M142 118 C120 92 118 58 132 36 C158 50 176 84 178 110 Z", WH, cx)
        a.sil(HEADP, WH)
        sym(a, "M146 102 C134 84 132 64 138 50 C154 62 164 82 166 98 Z", BK, cx, sil=False)
        a.blob(HEADP, WH)
    for d in ((190, 78, 190, 92, 190, 108, 190, 124), (162, 83, 165, 94, 167, 104, 168, 116),
              (218, 83, 215, 94, 213, 104, 212, 116)):
        a.ink([d], 12, a=1, b=0, col=BK)
    for d in ((109, 176, 118, 176, 126, 177, 134, 180), (116, 206, 124, 204, 131, 203, 138, 203)):
        a.ink([d], 10, a=1, b=0, col=BK)
        a.ink([n2_mx(d, cx)], 10, a=1, b=0, col=BK)
    a.blob("M130 236 C150 222 230 222 250 236 C246 262 224 282 190 282 C156 282 134 262 130 236 Z", "#5a5566")
    for s in (-1, 1):
        a.ellipse(cx + s * 20, 244, 6.5, 9, "#2f2b38", sw=0, stroke="none")
    a.path("M176 264 C186 271 194 271 204 264", sw=6, stroke=WHITE)
    a_face(a, cx, 168, 42, 17, cheek=(62, 204, 14, 8))
    return a.flipped()


# ---------------------------------------------------------- どうぶつえん --
@word
def sai():
    a = Art()
    GY, GY_D, HORN = "#aab4bf", "#8f9aa6", "#f4ead6"

    def behind(a):
        a.sil(taper([(470, 262, 506, 266, 522, 300, 518, 336)], 16, 11), GY)
        a.sil("M518 324 C504 336 504 362 520 372 C534 360 534 336 518 324 Z", GY_D)

    def inside(a):
        a.ink([(330, 222, 318, 262, 320, 310, 336, 350)], 8, a=1, b=0, col=GY_D)
        a.shine("M424 244 C446 248 464 264 468 288", sw=7)

    n2_quad(a, GY, GY_D, behind=behind, inside=inside, k=1.18)
    cx = 190
    HEADP = "M190 104 C258 104 298 146 298 200 C298 262 250 298 190 298 C130 298 82 262 82 200 C82 146 122 104 190 104 Z"
    with a.part():
        sym(a, "M126 150 C98 130 86 96 96 70 C128 76 154 102 162 130 Z", GY, cx)
        a.sil(HEADP, GY)
        sym(a, "M124 132 C110 116 104 98 108 84 C126 90 140 106 146 122 Z", PINK_IN, cx, sil=False)
        a.blob(HEADP, GY)
    a.ellipse(cx, 258, 62, 34, "#c3ccd5", sw=0, stroke="none")
    with a.part(ow=8):
        a.sil("M158 262 C160 228 174 180 194 142 C208 180 220 228 222 262 C206 274 174 274 158 262 Z", HORN)
    a.blob("M200 190 C208 214 214 240 216 258 C210 262 204 264 198 266 C204 240 204 214 200 190 Z", "#e3d4b8")
    a.path("M176 282 C185 289 195 289 204 282", sw=7)
    a_face(a, cx, 204, 60, 16, cheek=(80, 244, 14, 8))
    a.shine("M118 168 C128 148 144 134 164 128")
    return a


# ---------------------------------------------------------------- もり --
@word
def inoshishi():
    a = Art()
    BR, BR_D, DK, SN = "#a8744e", "#8d5f3f", "#6b4530", "#d99a86"

    def behind(a):
        a.sil(taper([(468, 280, 498, 284, 516, 300, 522, 322)], 14, 10), BR)
        a.sil("M522 310 C510 322 512 344 526 352 C538 340 536 320 522 310 Z", DK)

    with a.part():      # せなかの たてがみ
        a.sil("M246 246 L262 196 L288 226 L310 186 L338 222 L364 190 L390 226 L416 204 L436 250 Z", DK)
    n2_quad(a, BR, BR_D, hoof=DK, behind=behind)
    cx = 190
    with a.part():
        sym(a, "M124 152 C100 126 90 94 100 72 C132 72 162 94 176 122 Z", BR, cx)
        a.sil(N2_HEAD, BR)
        sym(a, "M124 134 C110 114 104 96 108 84 C128 88 146 102 156 118 Z", DK, cx, sil=False)
        a.blob(N2_HEAD, BR)
        a.blob("M190 100 C214 100 226 112 226 126 C214 136 166 136 154 126 C154 112 166 100 190 100 Z", DK)
    with a.part(ow=7):   # きば
        sym(a, taper([(140, 256, 126, 250, 120, 234, 124, 216)], 18, 8), WHITE, cx)
    with a.part(ow=8):
        a.sil_ellipse(cx, 234, 46, 32, SN)
    for s in (-1, 1):
        a.ellipse(cx + s * 16, 234, 7, 11, "#9a5a4c", sw=0, stroke="none")
    a.path("M177 274 C185 280 195 280 203 274", sw=7)
    a_face(a, cx, 184, 58, 17, cheek=(82, 226, 13, 8))
    a.shine("M128 152 C140 134 158 124 178 120")
    return a


@word
def ookami():
    a = Art()
    GY, GY_D, DK, CR = "#a3adb8", "#87929e", "#5f6a76", "#f6f1e7"
    tail = [(456, 288, 516, 296, 546, 342, 528, 400)]

    def behind(a):
        a.sil(taper(tail, 46, 34), GY)

    n2_quad(a, GY, GY_D, behind=behind, belly=CR)
    cx = 190
    ear = "M112 152 L104 52 C103 42 114 38 122 44 L196 100 Z"
    inner = "M128 134 L122 76 L168 110 Z"
    HEADP = ("M190 96 C242 96 276 126 284 166 C288 186 304 198 304 208 C284 240 242 262 190 262 "
             "C138 262 96 240 76 208 C76 198 92 186 96 166 C104 126 138 96 190 96 Z")
    with a.part():
        sym(a, ear, GY, cx)
        a.sil(HEADP, GY)
        sym(a, inner, DK, cx, sil=False)
        a.blob(HEADP, GY)
        a.blob("M78 208 C110 198 140 204 160 214 C170 198 210 198 220 214 C240 204 270 198 302 208 "
               "C284 240 242 262 190 262 C138 262 96 240 78 208 Z", CR)
    a.blob("M178 236 C178 256 202 256 202 236 Z", "#f28a9b")
    a_snout(a, cx, 210, EYE, 14, m=0.8)
    a_face(a, cx, 168, 46, 17, cheek=(78, 206, 14, 8))
    a.shine("M130 140 C138 124 152 112 170 106")
    return a


# ------------------------------------------------------- いえの いきもの --
def n2_sit(a, col, shade, sock=None, G=456):
    """A baby animal sitting, seen from the front (head goes on top, cx = 256)."""
    cx = 256
    with a.part():
        a.sil("M256 250 C326 250 366 316 370 388 C372 436 340 456 256 456 C172 456 140 436 142 388 "
              "C146 316 186 250 256 250 Z", col)
        sym(a, "M158 414 C124 414 104 432 108 446 C112 456 126 458 160 458 L202 458 C202 436 186 414 158 414 Z", col, cx)
        for x in (226, 286):
            a.sil(f"M{x - 25} 300 L{x + 25} 300 L{x + 24} 420 C{x + 36} 428 {x + 36} 458 {x + 17} 458 "
                  f"L{x - 17} 458 C{x - 36} 458 {x - 36} 428 {x - 24} 420 Z", col)
        a.blob("M150 400 C150 430 170 446 200 450 L200 458 L160 458 C138 458 130 440 150 400 Z", shade)
        a.blob(mirror("M150 400 C150 430 170 446 200 450 L200 458 L160 458 C138 458 130 440 150 400 Z", cx), shade)
        if sock:
            for x in (226, 286):
                a.blob(f"M{x - 25} 424 C{x - 36} 432 {x - 36} 458 {x - 17} 458 L{x + 17} 458 C{x + 36} 458 {x + 36} 432 {x + 25} 424 "
                       f"C{x + 10} 418 {x - 10} 418 {x - 25} 424 Z", sock)
        a.ink([(256, 458, 256, 430, 256, 400, 256, 372)], 9, a=1, b=0)
        for s in (-1, 1):
            a.ink([(cx + s * 58, 458, cx + s * 58, 430, cx + s * 57, 400, cx + s * 54, 372)], 9, a=1, b=0)
            a.ink([(cx + s * 60, 420, cx + s * 80, 408, cx + s * 100, 410, cx + s * 112, 424)], 8, a=1, b=0)
        for x in (226, 286):
            for dx in (-9, 9):
                a.ink([(x + dx, G + 3, x + dx, G - 3, x + dx, G - 7, x + dx, G - 11)], 6, a=1, b=0)


@word
def koinu():
    a = Art()
    WH, WH_D, BR, PATCH = "#fff6e8", "#eadfcc", "#b8794a", "#e6b98a"
    cx = 256
    tail = [(352, 400, 400, 396, 428, 360, 424, 318)]
    with a.part():
        a.sil(taper(tail, 34, 22), WH)
    n2_sit(a, WH, WH_D)
    a.tube("M176 266 C210 296 302 296 336 266", "#4fa8e0", 26, 14)
    a.circle(256, 300, 12, YEL2, sw=8)
    HEADP = "M256 56 C344 56 392 108 392 172 C392 240 334 280 256 280 C178 280 120 240 120 172 C120 108 168 56 256 56 Z"
    a.sil(HEADP, WH)
    a.blob("M256 58 C212 58 172 74 148 106 C150 150 176 186 214 190 C246 192 262 160 262 120 C262 96 260 74 256 58 Z", PATCH)
    a.ellipse(cx, 222, 54, 40, WHITE, sw=0, stroke="none")
    with a.part():
        sym(a, "M176 70 C132 56 92 86 92 144 C92 194 118 222 140 208 C160 192 152 140 186 104 Z", BR, cx)
    a.blob("M242 244 C242 272 270 272 270 244 Z", "#f28a9b")
    a_snout(a, cx, 204, EYE, 19, m=0.9)
    a_face(a, cx, 170, 56, 20, cheek=(88, 218, 17, 10))
    a.shine("M300 78 C328 86 350 104 362 128")
    return a


@word
def koneko():
    a = Art()
    WH, WH_D, GY, GY_D = "#fffaf2", "#ebe3d6", "#b4bcc8", "#8e98a6"
    cx = 256
    tail = [(350, 420, 420, 424, 446, 372, 418, 330), (418, 330, 404, 312, 380, 318, 384, 340)]
    with a.part():
        a.sil(taper(tail, 34, 26), GY)
        for t in (0.3, 0.5, 0.7):
            a_band(a, tail, t, t + 0.07, 34, 26, GY_D)
    n2_sit(a, WH, WH_D)
    a.tube("M176 262 C210 292 302 292 336 262", "#f47c9a", 24, 12)
    a.circle(256, 296, 13, YEL2, sw=8)
    a.dot(256, 300, 4, O)
    ear = "M150 136 L138 38 C137 26 150 22 160 30 L236 84 Z"
    inner = "M164 118 L158 64 L206 98 Z"
    HEADP = "M256 60 C340 60 390 108 390 172 C390 238 332 276 256 276 C180 276 122 238 122 172 C122 108 172 60 256 60 Z"
    with a.part():
        sym(a, ear, GY, cx)
        a.sil(HEADP, WH)
        sym(a, inner, PINK_IN, cx, sil=False)
        a.blob(HEADP, WH)
        # 頭の上の 灰色: 頭の輪郭の 上の部分を そのまま切り出して、ふちに すき間を出さない
        lt = e1_sub((122, 172, 122, 108, 172, 60, 256, 60), 0.4, 1)
        rt = n2_mx(lt, cx)
        a.blob(f"M{lt[0]:.1f} {lt[1]:.1f} C{lt[2]:.1f} {lt[3]:.1f} {lt[4]:.1f} {lt[5]:.1f} 256 60 "
               f"C{rt[4]:.1f} {rt[5]:.1f} {rt[2]:.1f} {rt[3]:.1f} {rt[0]:.1f} {rt[1]:.1f} "
               f"C{rt[0] - 26:.1f} 124 316 124 296 116 C284 138 270 150 256 152 C242 150 228 138 216 116 "
               f"C196 124 {lt[0] + 26:.1f} 124 {lt[0]:.1f} {lt[1]:.1f} Z", GY)
        for d in ((256, 60, 256, 76, 256, 92, 256, 110), (226, 63, 228, 76, 230, 88, 232, 100), (286, 63, 284, 76, 282, 88, 280, 100)):
            a.ink([d], 10, a=1, b=0, col=GY_D)
    a.path("M244 206 L268 206 L256 220 Z", fill="#f28a9b", sw=6)
    a.path("M256 220 L256 228 M256 228 C250 240 236 240 234 230 M256 228 C262 240 276 240 278 230", sw=7)
    for d in ("M186 214 L128 204", "M186 228 L130 238"):
        a.path(d, sw=6)
        a.path(mirror(d, cx), sw=6)
    a_face(a, cx, 176, 54, 20, cheek=(84, 220, 16, 10))
    return a


@word
def nezumi():
    a = Art()
    GY, GY_D, PK, CR = "#b9bcc6", "#9da1ad", "#f5a9b5", "#f7f1ea"
    cx = 256
    G = 456
    tail = [(330, 420, 420, 440, 470, 400, 440, 350), (440, 350, 424, 324, 396, 334, 404, 356)]
    with a.part(ow=9):
        a.sil(taper(tail, 18, 10), PK)
    with a.part():
        sym(a, "M196 440 C170 438 156 446 158 452 C160 458 172 458 196 458 L232 458 C232 446 220 440 196 440 Z", PK, cx)
    with a.part():
        a.sil("M256 262 C316 262 346 318 346 380 C346 430 318 452 256 452 C194 452 166 430 166 380 "
              "C166 318 196 262 256 262 Z", GY)
        a.blob("M256 312 C294 312 312 346 312 384 C312 424 292 442 256 442 C220 442 200 424 200 384 "
               "C200 346 218 312 256 312 Z", CR)
    with a.part(ow=9):   # 手
        sym(a, "M214 330 C196 330 186 346 192 360 C198 372 220 372 228 360 C234 346 228 330 214 330 Z", GY, cx)
    HEADP = "M256 104 C330 104 372 146 372 198 C372 252 322 284 256 284 C190 284 140 252 140 198 C140 146 182 104 256 104 Z"
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 108, 106, 62, 60, GY)
        a.sil(HEADP, GY)
        for s in (-1, 1):
            a.ellipse(cx + s * 108, 108, 38, 37, PK, sw=0, stroke="none")
        a.blob(HEADP, GY)
    a.ellipse(cx, 236, 44, 30, CR, sw=0, stroke="none")
    a.path("M245 220 L267 220 L256 232 Z", fill="#f28a9b", sw=6)
    a.path("M256 232 L256 240 M256 240 C250 250 238 250 236 242 M256 240 C262 250 274 250 276 242", sw=6)
    for d in ("M196 232 L146 224", "M196 244 L148 252"):
        a.path(d, sw=5)
        a.path(mirror(d, cx), sw=5)
    a_face(a, cx, 192, 50, 18, cheek=(80, 232, 15, 9))
    a.shine("M186 150 C196 134 212 122 232 116")
    return a


@word
def harinezumi():
    a = Art()
    SP, SP_D, CR, CR_D = "#a5754f", "#7e5536", "#fbe6c8", "#efd2aa"
    G = 452
    # とげ: だ円の上半分に沿って、長い・短いを かわるがわる
    pts = []
    n = 13
    for i in range(n + 1):
        t = math.pi * (1.06 - 1.12 * i / n)
        for k, r in ((0, 1.0), (0.5, 1.2)):
            if i == n and k:
                break
            u = math.pi * (1.06 - 1.12 * (i + k) / n)
            pts.append((306 + 176 * r * math.cos(u), 372 - 196 * r * math.sin(u)))
    spikes = "M" + " L".join(f"{x:.0f} {y:.0f}" for x, y in pts) + " L470 420 L150 420 Z"
    with a.part():
        for x in (236, 420):
            a.sil(f"M{x - 30} {G} C{x - 36} {G - 18} {x - 16} {G - 30} {x} {G - 30} C{x + 16} {G - 30} {x + 36} {G - 18} {x + 30} {G} "
                  f"C{x + 14} {G + 4} {x - 14} {G + 4} {x - 30} {G} Z", CR_D)
    with a.part():
        a.sil(spikes, SP)
        for x, y in ((300, 250), (360, 236), (410, 280), (330, 310), (396, 344), (446, 330), (270, 196), (340, 180)):
            a.ink([(x - 10, y + 18, x - 4, y + 6, x + 2, y - 6, x + 8, y - 18)], 9, a=0.8, b=0, col=SP_D)
    with a.part():
        a.sil("M214 232 C290 232 330 290 330 350 C330 410 300 440 230 440 C160 440 98 420 62 372 "
              "C56 362 60 352 72 348 C104 338 122 312 138 282 C154 252 180 232 214 232 Z", CR)
        a.blob("M150 420 C200 438 262 440 300 420 C286 436 262 440 230 440 C200 440 172 434 150 420 Z", CR_D)
        for x in (150, 300):
            a.sil(f"M{x - 30} {G} C{x - 36} {G - 18} {x - 16} {G - 30} {x} {G - 30} C{x + 16} {G - 30} {x + 36} {G - 18} {x + 30} {G} "
                  f"C{x + 14} {G + 4} {x - 14} {G + 4} {x - 30} {G} Z", CR)
    with a.part(ow=8):
        sym(a, "M150 262 C132 252 118 262 120 280 C124 294 142 296 152 286 Z", SP_D, 214)
    a.sil_ellipse(66, 360, 17, 15, EYE)
    a.dot(61, 355, 5, WHITE)
    a.path("M96 392 C110 404 128 404 140 394", sw=7)
    a.eye(150, 330, 17)
    a.eye(250, 330, 17)
    a.cheek(130, 372, 15, 9)
    a.cheek(272, 372, 15, 9)
    return a


@word
def mogura():
    a = Art()
    BR, BR_D, PK, DIRT, DIRT_D = "#8a6a58", "#6f5345", "#f7b0b4", "#c58c55", "#a8733f"
    cx = 256
    with a.part():
        a.sil("M256 96 C336 96 380 156 384 236 C388 320 380 400 372 440 L140 440 C132 400 124 320 128 236 "
              "C132 156 176 96 256 96 Z", BR)
        a.blob("M340 150 C372 190 378 300 368 420 L372 440 C380 400 388 320 384 236 C382 196 368 166 340 150 Z", BR_D)
    with a.part():      # つちの やま
        a.sil("M40 452 C52 396 110 372 160 384 C196 356 316 356 352 384 C402 372 460 396 472 452 "
              "C420 462 92 462 40 452 Z", DIRT)
        a.blob("M40 452 C92 462 420 462 472 452 C468 436 460 424 450 414 C400 440 112 440 62 414 C52 424 44 436 40 452 Z", DIRT_D)
        for x, y in ((120, 410), (392, 408), (256, 392)):
            a.ellipse(x, y, 12, 7, "#dba76e", sw=0, stroke="none")
    with a.part():      # ほる 手
        for s in (-1, 1):
            x = cx + s * 132
            a.sil(f"M{x - 44} 372 C{x - 52} 330 {x - 30} 306 {x - 26} 290 L{x - 12} 318 L{x} 284 L{x + 12} 318 L{x + 26} 290 "
                  f"C{x + 30} 306 {x + 52} 330 {x + 44} 372 C{x + 30} 390 {x - 30} 390 {x - 44} 372 Z", PK)
    a.ellipse(cx, 262, 62, 44, "#a98a78", sw=0, stroke="none")
    with a.part(ow=8):
        a.sil("M256 222 C280 222 292 238 286 254 C280 270 266 280 256 280 C246 280 232 270 226 254 C220 238 232 222 256 222 Z", PK)
    a.dot(248, 240, 6, WHITE)
    a.path("M244 294 C250 300 262 300 268 294", sw=7)
    for d in ("M206 262 L160 254", "M206 276 L162 286"):
        a.path(d, sw=5)
        a.path(mirror(d, cx), sw=5)
    a_face(a, cx, 196, 54, 14, cheek=(84, 238, 14, 8))
    a.shine("M178 164 C190 142 208 126 232 118")
    return a


@word
def wani():
    a = Art()
    G_, GD, BELLY, RIDGE = "#7dc56a", "#5ea955", "#f4efb8", "#4e9a4f"
    G = 440
    with a.part():
        a.sil(limb_d([(244, 372), (254, 404), (254, 424)], [48, 40, 36], G, foot=12, h=18), GD)
        a.sil(limb_d([(372, 372), (382, 404), (382, 424)], [48, 40, 36], G, foot=12, h=18), GD)
    with a.part():      # せなかの ぎざぎざ
        a.sil("M226 262 L250 216 L276 254 L302 216 L328 258 L352 226 L378 272 L400 246 L420 300 Z", RIDGE)
    with a.part():
        a.sil(taper([(396, 346, 470, 356, 528, 314, 512, 226)], 92, 18), G_)
        a.sil("M40 330 C40 298 66 288 104 288 C136 288 152 280 170 262 C200 236 260 236 310 250 "
              "C370 262 430 290 446 340 C452 384 420 410 370 412 C300 416 200 414 140 406 C80 400 40 380 40 330 Z", G_)
        a.sil(limb_d([(200, 380), (194, 408), (194, 424)], [54, 44, 40], G, foot=13, h=19), G_)
        a.sil(limb_d([(416, 380), (422, 408), (422, 424)], [54, 44, 40], G, foot=13, h=19), G_)
        a.blob("M62 378 C110 398 200 406 300 406 C350 406 400 400 432 386 C420 404 396 410 370 412 "
               "C300 416 200 414 140 406 C108 402 80 394 62 378 Z", BELLY)
        a.ink([(42, 344, 84, 360, 134, 362, 180, 350)], 9, a=1, b=0)
        for x in (72, 104, 136):
            a.blob(f"M{x - 10} 357 L{x + 10} 359 L{x} 377 Z", WHITE)
    with a.part():      # 目の こぶ
        for x in (178, 246):
            a.sil_ellipse(x, 240, 38, 38, G_)
    a.blob("M146 262 C170 240 260 240 282 266 C250 286 180 286 146 262 Z", G_)
    for x in (178, 246):
        a.ellipse(x, 238, 24, 25, WHITE, sw=0, stroke="none")
        a.eye(x, 240, 15)
    for x in (58, 86):
        a.ellipse(x, 308, 5, 7, GD, sw=0, stroke="none")
    a.ellipse(212, 312, 17, 10, "#f3b3a4", sw=0, stroke="none")
    a.shine("M310 270 C346 276 384 290 408 310")
    return a


@word
def hebi():
    a = Art()
    G_, GD, YL = "#8fd06e", "#69b356", "#f7e58a"
    body = [(150, 330, 190, 236, 250, 236, 290, 330), (290, 330, 330, 424, 390, 424, 430, 330),
            (430, 330, 455, 276, 492, 258, 528, 282)]
    with a.part():
        a.sil(taper(body, 86, 22), G_)
        for t in (0.2, 0.38, 0.56, 0.74):
            x, y = at(body, t)
            r = 15 - t * 8
            a.ellipse(x, y, r * 1.3, r, GD, sw=0, stroke="none")
    with a.part(ow=7):   # した
        a.sil("M110 390 L104 430 L92 448 L110 440 L128 448 L116 430 Z", "#ef6a78")
    a.sil("M150 216 C214 216 252 258 252 310 C252 366 208 398 150 398 C92 398 48 366 48 310 C48 258 86 216 150 216 Z", G_)
    a.blob("M92 372 C122 392 178 392 208 372 C192 392 172 398 150 398 C128 398 108 392 92 372 Z", YL)
    b_face(a, 150, 306, 46, 18, mouth=38, mw=13)
    for s in (-1, 1):
        a.ellipse(150 + s * 74, 342, 16, 10, "#f3b3a4", sw=0, stroke="none")
    a.shine("M84 280 C92 258 108 242 130 234")
    return a


@word
def azarashi():
    a = Art()
    GY, GY_D, SPOT, WH = "#dfe6ee", "#bcc8d6", "#a9b6c6", "#ffffff"
    with a.part():      # おびれ
        a.sil("M430 372 C470 356 500 318 500 276 C520 296 532 300 552 296 C548 340 520 392 470 414 Z", GY_D)
    with a.part():
        a.sil("M190 150 C262 150 300 196 316 250 C380 270 440 310 468 372 C480 410 450 430 400 432 "
              "L150 432 C96 432 64 392 64 300 C64 212 112 150 190 150 Z", GY)
        a.blob("M110 410 C180 432 380 432 460 400 C452 422 430 430 400 432 L150 432 C132 432 120 424 110 410 Z", GY_D)
        for x, y, r in ((350, 320, 15), (396, 362, 12), (318, 372, 10), (424, 322, 9)):
            a.ellipse(x, y, r * 1.2, r, SPOT, sw=0, stroke="none")
    with a.part():      # まえびれ
        a.sil("M246 372 C250 410 280 440 322 446 C330 420 316 386 286 366 Z", GY_D)
    cx = 190
    a.ellipse(cx, 296, 50, 34, WH, sw=0, stroke="none")
    a.sil("M176 274 C176 264 204 264 204 274 C204 284 196 290 190 290 C184 290 176 284 176 274 Z", EYE)
    a.path("M190 290 L190 298 M190 298 C184 310 170 310 168 300 M190 298 C196 310 210 310 212 300", sw=7)
    for s in (-1, 1):
        for dy in (-6, 8):
            a.dot(cx + s * 34, 296 + dy, 3.5, O)
    a_face(a, cx, 244, 56, 19, cheek=(84, 292, 15, 9))
    a.shine("M104 240 C112 208 134 184 164 174")
    return a


@word
def kawauso():
    a = Art()
    BR, BR_D, CR = "#a9794f", "#8c6240", "#f8e7c9"
    with a.part():
        a.sil(taper([(410, 372, 470, 380, 520, 360, 556, 312)], 60, 18), BR_D)
    with a.part():
        a.sil("M190 150 C262 150 304 196 314 250 C372 262 432 300 452 356 C464 404 440 430 396 432 "
              "L190 432 C120 432 72 380 72 300 C72 212 116 150 190 150 Z", BR)
        a.blob("M190 332 C236 332 280 356 290 432 L190 432 C140 432 110 410 100 380 C120 352 150 332 190 332 Z", CR)
    with a.part():      # 手と 足
        for x in (150, 230):
            a.sil(f"M{x - 26} 370 C{x - 30} 350 {x - 14} 340 {x} 340 C{x + 14} 340 {x + 30} 350 {x + 26} 370 C{x + 20} 386 {x - 20} 386 {x - 26} 370 Z", BR)
        a.sil("M352 410 C352 392 372 384 396 386 C424 388 440 404 436 422 C432 438 356 438 352 410 Z", BR)
    cx = 190
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 104, 206, 22, 20, BR_D)
    a.blob("M190 150 C262 150 300 196 306 250 C300 300 250 320 190 320 C130 320 82 300 76 250 C82 196 118 150 190 150 Z", BR)
    a.ellipse(cx, 280, 56, 36, CR, sw=0, stroke="none")
    a.sil("M174 258 C174 246 206 246 206 258 C206 270 197 276 190 276 C183 276 174 270 174 258 Z", EYE)
    a.path("M190 276 L190 284 M190 284 C184 296 170 296 168 286 M190 284 C196 296 210 296 212 286", sw=7)
    for s in (-1, 1):
        for dy in (-6, 8):
            a.dot(cx + s * 36, 282 + dy, 3.5, O)
    a_face(a, cx, 226, 56, 18, cheek=(86, 272, 15, 9))
    a.shine("M106 232 C114 204 134 184 162 174")
    return a


@word
def koumori():
    a = Art()
    PU, PU_D, WING, IN = "#8c7fb5", "#6f6396", "#6a5f8f", "#f7b3bd"
    cx = 256
    wing = ("M210 250 C170 170 100 140 -10 160 C18 200 30 244 26 300 C56 280 84 286 104 318 "
            "C126 292 154 294 174 326 C192 306 212 308 224 330 Z")
    with a.part():
        sym(a, wing, WING, cx)
        for s in (-1, 1):
            for c in ((212, 256, 160, 244, 118, 270, 104, 312), (212, 256, 190, 270, 176, 296, 174, 320)):
                q = c if s < 0 else n2_mx(c, cx)
                a.ink([q], 7, a=0, b=0.6, col="#4f4670")
    with a.part():
        sym(a, "M226 430 C214 430 208 440 212 448 L246 448 C246 438 238 430 226 430 Z", PU_D, cx)
    HEADP = ("M256 130 C330 130 370 176 370 232 C370 268 356 290 340 304 C356 340 350 400 320 424 "
             "C296 440 216 440 192 424 C162 400 156 340 172 304 C156 290 142 268 142 232 C142 176 182 130 256 130 Z")
    ear = "M158 196 C136 150 138 96 160 62 C198 80 228 116 236 150 Z"
    with a.part():
        sym(a, ear, PU, cx)
        a.sil(HEADP, PU)
        sym(a, "M170 172 C158 142 158 112 168 92 C190 108 208 130 214 152 Z", IN, cx, sil=False)
        a.blob(HEADP, PU)
        a.blob("M256 326 C290 326 308 350 306 380 C304 412 284 428 256 428 C228 428 208 412 206 380 C204 350 222 326 256 326 Z", "#b3a8d6")
    a.path("M238 262 C246 272 266 272 274 262", sw=7)
    for x in (243, 269):
        a.blob(f"M{x - 6} 268 L{x + 6} 268 L{x} 282 Z", WHITE)
    a_face(a, cx, 226, 52, 19, cheek=(84, 262, 15, 9))
    a.shine("M186 196 C194 176 210 162 230 154")
    return a


@word
def musasabi():
    a = Art()
    BR, BR_D, CR, PAW = "#b9834f", "#96683c", "#fbeccb", "#8a5c36"
    cx = 256
    with a.part():      # しっぽ
        a.sil("M226 400 C214 450 226 500 256 512 C286 500 298 450 286 400 Z", BR_D)
    with a.part():      # ひまく と 手足
        a.sil("M256 196 C200 196 130 176 70 140 C52 132 40 146 46 162 C70 220 80 300 60 380 "
              "C56 398 70 408 86 400 C140 376 200 400 256 420 C312 400 372 376 426 400 "
              "C442 408 456 398 452 380 C432 300 442 220 466 162 C472 146 460 132 442 140 C382 176 312 196 256 196 Z", BR)
        a.blob("M256 236 C210 236 150 222 104 200 C118 250 122 310 110 362 C160 350 210 366 256 384 "
               "C302 366 352 350 402 362 C390 310 394 250 408 200 C362 222 302 236 256 236 Z", CR)
    for x, y in ((62, 150), (450, 150), (72, 388), (440, 388)):
        a.sil_ellipse(x, y, 22, 20, PAW)
    HEADP = "M256 70 C326 70 366 112 366 162 C366 216 318 248 256 248 C194 248 146 216 146 162 C146 112 186 70 256 70 Z"
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 86, 90, 30, 30, BR)
        a.sil(HEADP, BR)
        for s in (-1, 1):
            a.ellipse(cx + s * 84, 92, 15, 15, PINK_IN, sw=0, stroke="none")
        a.blob(HEADP, BR)
    a.ellipse(cx, 204, 46, 30, CR, sw=0, stroke="none")
    a_snout(a, cx, 192, "#f28a9b", 11, m=0.7, line=True)
    a_face(a, cx, 158, 50, 19, cheek=(80, 198, 15, 9))
    a.shine("M190 118 C200 102 216 90 236 84")
    return a


# ---------------------------------------------------------------- とり --
N2_PIN = ("M256 64 C310 64 340 102 340 146 C340 176 334 196 350 220 C378 262 394 300 390 342 "
          "C384 404 326 436 256 436 C186 436 128 404 122 342 C118 300 134 262 162 220 "
          "C178 196 172 176 172 146 C172 102 202 64 256 64 Z")
N2_PIN_HEAD = ("M256 64 C310 64 340 102 340 146 C340 176 334 196 350 220 C320 240 192 240 162 220 "
               "C178 196 172 176 172 146 C172 102 202 64 256 64 Z")
N2_ROUND = ("M256 72 C326 72 364 116 364 170 C364 196 358 212 368 232 C388 270 394 304 388 340 "
            "C380 400 324 432 256 432 C188 432 132 400 124 340 C118 304 124 270 144 232 "
            "C154 212 148 196 148 170 C148 116 186 72 256 72 Z")
N2_BELLY = ("M256 296 C306 296 330 330 330 366 C330 404 300 426 256 426 C212 426 182 404 182 366 "
            "C182 330 206 296 256 296 Z")
N2_WING = "M146 262 C112 290 98 340 116 392 C124 408 140 410 152 400 C180 374 192 326 186 290 C182 270 166 258 146 262 Z"
N2_TAIL = "M296 372 C350 384 402 404 424 446 C378 452 330 440 286 418 Z"
N2_BEAK = "M238 166 C238 156 274 156 274 166 C274 184 264 196 256 196 C248 196 238 184 238 166 Z"


def n2_wings(a, col, line, d=N2_WING, rows=(0, 30)):
    with a.part():
        sym(a, d, col, 256)
        for s in (-1, 1):
            for y0 in rows:
                q = (118, 336 + y0, 136, 344 + y0, 156, 344 + y0, 176, 336 + y0)
                a.ink([q if s < 0 else n2_mx(q, 256)], 9, a=0.6, b=0.6, col=line)


@word
def hiyoko():
    a = Art()
    YL, YL_D, OR = "#ffe07a", "#f3c64c", "#f59a4a"
    b_bird_feet(a, (214, 298), 458, OR)
    with a.part():
        a.sil("M246 96 C236 70 242 46 258 34 C268 50 270 74 264 96 Z", YL)
        a.sil("M262 98 C266 76 280 62 298 58 C300 76 292 92 278 104 Z", YL)
        a.sil("M256 84 C350 84 408 156 408 256 C408 364 348 438 256 438 C164 438 104 364 104 256 "
              "C104 156 162 84 256 84 Z", YL)
        a.blob("M140 360 C180 420 250 440 310 428 C350 420 382 392 398 350 C366 400 310 420 256 420 C206 420 164 398 140 360 Z", YL_D)
    with a.part():
        sym(a, "M116 250 C86 262 72 304 88 340 C98 356 118 354 128 340 C142 312 142 278 132 258 Z", YL_D, 256)
    a.sil("M228 250 C238 236 274 236 284 250 C274 270 264 280 256 280 C248 280 238 270 228 250 Z", OR)
    b_face(a, 256, 214, 62, 21, cheek=(96, 36))
    a.shine("M160 180 C172 150 194 128 224 116")
    return a


@word
def niwatori():
    a = Art()
    WH, WH_D, BEAK, FEET = "#fffaf0", "#e6dccb", "#f7c948", "#f2b33d"
    with a.part():      # おばね
        a.sil("M310 340 C350 300 376 250 372 196 C404 214 420 250 416 284 C442 270 468 280 478 304 "
              "C482 340 462 364 440 372 C452 384 452 400 440 410 C410 424 370 424 336 420 Z", WH)
        a.ink([(356, 356, 384, 334, 404, 310, 416, 284)], 8, a=0, b=1, col="#cdbfa8")
        a.ink([(372, 392, 398, 388, 422, 382, 440, 372)], 8, a=0, b=1, col="#cdbfa8")
    b_bird_feet(a, (212, 300), 458, FEET)
    with a.part():      # とさか
        a.sil("M216 92 C198 52 226 28 248 52 C250 20 290 20 292 54 C316 34 336 62 316 96 Z", RED)
    with a.part():
        a.sil(N2_PIN, WH)
        a.blob("M150 392 C190 430 250 438 256 436 C326 436 384 404 390 342 C372 396 320 420 256 420 C212 420 174 410 150 392 Z", WH_D)
    n2_wings(a, WH_D, "#cdbfa8")
    with a.part(ow=8):  # あごの 赤い ひだ
        a.sil("M242 190 C236 212 244 236 256 236 C268 236 276 212 270 190 Z", RED)
    a.sil(N2_BEAK, BEAK)
    b_face(a, 256, 146, 46, 16, cheek=(70, 30))
    return a


@word
def ahiru():
    a = Art()
    WH, WH_D, OR = "#fffdf2", "#e9e2cf", "#f7a13d"
    a.sil("M300 380 C340 384 380 380 410 362 C408 400 380 430 330 436 Z", WH)
    b_bird_feet(a, (210, 302), 458, OR)
    with a.part():
        a.sil(N2_ROUND, WH)
        a.blob("M150 390 C190 426 250 434 256 432 C324 432 380 400 388 340 C370 392 320 416 256 416 C212 416 174 406 150 390 Z", WH_D)
    n2_wings(a, WH_D, "#cfc5ae", d=shift(N2_WING, 0, 4))
    with a.part():      # ひらたい くちばし
        a.sil("M206 196 C206 174 306 174 306 196 C306 222 284 236 256 236 C228 236 206 222 206 196 Z", OR)
        a.ink([(212, 204, 240, 216, 272, 216, 300, 204)], 6, a=0.5, b=0.5, col="#d9822a")
        for s in (-1, 1):
            a.ellipse(256 + s * 12, 190, 3.5, 5, "#c9731f", sw=0, stroke="none")
    b_face(a, 256, 152, 52, 18, cheek=(84, 36))
    return a


@word
def fukurou():
    a = Art()
    BR, BR_D, CR, BEAK = "#b98556", "#8a5c36", "#f9ead0", "#f7b84a"
    BODY = ("M256 96 C296 96 326 82 348 46 C374 96 390 150 390 222 C394 270 396 310 390 344 "
            "C382 402 324 436 256 436 C188 436 130 402 122 344 C116 310 118 270 122 222 "
            "C122 150 138 96 164 46 C186 82 216 96 256 96 Z")
    b_bird_feet(a, (214, 298), 458, "#f4a37f")
    with a.part():
        a.sil(BODY, BR)
        a.blob("M256 250 C312 250 340 300 338 356 C336 404 304 426 256 426 C208 426 176 404 174 356 "
               "C172 300 200 250 256 250 Z", CR)
        for x, y in ((230, 310), (282, 310), (256, 346), (224, 382), (288, 382)):
            a.ink([(x - 13, y - 6, x - 6, y + 6, x + 6, y + 6, x + 13, y - 6)], 8, a=0.4, b=0.4, col="#d9b88a")
        for s in (-1, 1):
            a.ellipse(256 + s * 58, 184, 60, 62, CR, sw=0, stroke="none")
    n2_wings(a, BR_D, "#6b4526", d=shift(N2_WING, -4, 6))
    a.sil("M240 214 C240 204 272 204 272 214 C272 232 264 244 256 244 C248 244 240 232 240 214 Z", BEAK)
    for s in (-1, 1):
        a.eye(256 + s * 58, 186, 25)
        a.cheek(256 + s * 96, 236, 15, 9)
    return a


@word
def washi():
    a = Art()
    BR, BR_D, WH, YL = "#7a543a", "#5c3e2a", "#fffaf0", "#f7c948"
    wing = ("M176 246 C130 180 76 132 4 118 C0 176 12 228 36 270 C22 278 18 296 26 312 "
            "C16 322 16 340 28 352 C76 372 136 364 184 336 Z")
    with a.part():
        sym(a, wing, BR_D, 256)
        for s in (-1, 1):
            for c in ((36, 270, 70, 262, 104, 262, 136, 272), (26, 312, 66, 306, 106, 308, 144, 318)):
                a.ink([c if s < 0 else n2_mx(c, 256)], 8, a=1, b=0, col="#3f2a1c")
    b_bird_feet(a, (212, 300), 458, YL)
    with a.part():
        a.sil(N2_PIN, BR)
        a.blob(N2_PIN_HEAD, WH)
        a.blob("M256 300 C300 300 324 332 324 366 C324 402 298 424 256 424 C214 424 188 402 188 366 C188 332 212 300 256 300 Z", "#93694b")
    with a.part():
        a.sil("M234 162 C234 148 278 148 278 162 C278 190 268 210 258 216 C254 218 250 216 248 212 "
              "C240 198 234 182 234 162 Z", YL)
    b_face(a, 256, 140, 48, 16, cheek=(72, 32))
    for s in (-1, 1):   # きりっとした まゆ
        a.ink([(256 + s * 68, 112, 256 + s * 56, 112, 256 + s * 42, 116, 256 + s * 30, 122)], 8, a=0.6, b=0.6)
    return a


@word
def kiji():
    a = Art()
    GN, GN_D, PU, RD, BR, BR_D = "#3f9a76", "#2f7c5e", "#6f6fc4", "#e5534b", "#c9a06a", "#8f6a3c"
    tail = [(300, 400, 400, 436, 500, 380, 540, 250)]
    with a.part():
        a.sil(taper(tail, 56, 14), BR)
        for t in (0.3, 0.44, 0.58, 0.72, 0.86):
            a_band(a, tail, t, t + 0.05, 56, 14, BR_D)
    b_bird_feet(a, (212, 300), 458, "#b9a58f")
    with a.part():
        sym(a, "M206 84 C196 60 200 40 212 28 C226 44 232 64 230 84 Z", GN_D, 256)
        a.sil(N2_PIN, GN)
        a.blob("M174 216 C210 234 302 234 338 216 C356 240 368 256 376 276 C330 302 182 302 136 276 "
               "C144 256 156 240 174 216 Z", PU)
        a.blob("M168 232 C214 250 298 250 344 232 C348 238 352 242 356 248 C310 266 202 266 156 248 C160 242 164 238 168 232 Z", WHITE)
        a.blob(N2_BELLY, "#57b48e")
        for s in (-1, 1):
            a.ellipse(256 + s * 48, 150, 34, 36, RD, sw=0, stroke="none")
    n2_wings(a, BR, BR_D)
    a.sil(N2_BEAK, "#f6e7c4")
    b_face(a, 256, 148, 48, 16)
    a.shine("M196 112 C204 98 218 88 236 82")
    return a


@word
def kotori():
    a = Art()
    BL, BL_D, CR, OR = "#7fc8f0", "#4fa3d8", "#fff6e0", "#f59a4a"
    a.sil(N2_TAIL, BL_D)
    b_bird_feet(a, (214, 298), 456, "#f4a37f")
    with a.part():
        a.sil("M250 86 C238 60 246 40 262 30 C272 46 272 68 266 86 Z", BL)
        a.sil(N2_ROUND, BL)
        a.blob("M256 262 C310 262 336 310 334 360 C332 402 302 424 256 424 C210 424 180 402 178 360 "
               "C176 310 202 262 256 262 Z", CR)
    n2_wings(a, BL_D, "#dff2fc", d=shift(N2_WING, -6, 6), rows=(0, 28))
    a.sil(shift(N2_BEAK, 0, 22), OR)
    b_face(a, 256, 164, 50, 18, cheek=(78, 34))
    a.shine("M194 118 C204 102 218 92 236 86")
    return a


@word
def oumu():
    a = Art()
    PK, PK_D, WH, WH_D, BEAK = "#f9aeb0", "#ee8f96", "#fff8f0", "#eadfd2", "#f1e6d2"
    with a.part():      # かんむりの はね
        for ang, L in ((-38, 100), (-14, 120), (10, 122), (34, 104)):
            r = math.radians(ang - 90)
            bx, by = 256 + 30 * math.sin(math.radians(ang)), 96
            tx, ty = bx + L * math.cos(r), by + L * math.sin(r)
            nx, ny = -math.sin(r) * 20, math.cos(r) * 20
            mx, my = (bx + tx) / 2, (by + ty) / 2
            a.sil(f"M{bx - nx:.0f} {by - ny:.0f} C{mx - nx * 1.3:.0f} {my - ny * 1.3:.0f} {tx - nx * 0.4:.0f} {ty - ny * 0.4:.0f} {tx:.0f} {ty:.0f} "
                  f"C{tx + nx * 0.4:.0f} {ty + ny * 0.4:.0f} {mx + nx * 1.3:.0f} {my + ny * 1.3:.0f} {bx + nx:.0f} {by + ny:.0f} Z", "#ff7f6e")
            a.ellipse(mx + (tx - bx) * 0.12, my + (ty - by) * 0.12, 9, 9, YEL2, sw=0, stroke="none")
    a.sil(N2_TAIL, WH)
    b_bird_feet(a, (212, 300), 458, "#a9b0ba")
    with a.part():
        a.sil(N2_PIN, PK)
        a.blob(N2_BELLY, "#fcc9c8")
    n2_wings(a, WH, WH_D)
    with a.part():
        a.sil("M232 160 C232 146 280 146 280 160 C280 190 268 208 258 214 C254 216 250 214 248 210 "
              "C238 196 232 180 232 160 Z", BEAK)
        a.ink([(238, 176, 248, 182, 264, 182, 274, 176)], 6, a=0.5, b=0.5, col="#b9a98c")
    b_face(a, 256, 140, 50, 17, cheek=(74, 32))
    a.shine("M196 116 C204 100 218 88 236 82")
    return a


@word
def kujaku():
    a = Art()
    GN, GN_D, BL, BL_D, YL = "#52b98c", "#3a9a72", "#3f78d8", "#2f5fb8", "#f4d65c"
    cx = 256
    with a.part():
        a.sil(a_wool(cx, 248, 226, 204, 13, start=math.pi / 2 + math.pi / 13), GN)
        a.blob(a_wool(cx, 260, 150, 140, 11, start=math.pi / 2), GN_D)
        for k in range(7):
            t = math.radians(196 + k * 24.7)
            x, y = cx + 178 * math.cos(t), 252 + 164 * math.sin(t)
            a.ellipse(x, y, 27, 27, YL, sw=0, stroke="none")
            a.ellipse(x, y + 3, 17, 17, BL, sw=0, stroke="none")
            a.ellipse(x, y + 6, 8, 8, "#2b2f6a", sw=0, stroke="none")
            a.ink([(x, y + 26, (x + cx) / 2, (y + 300) / 2, cx, 300, cx, 300)], 5, a=0.8, b=0, col=GN_D)
    b_bird_feet(a, (216, 296), 458, "#b9a58f")
    for dx in (-24, 0, 24):   # かんむり
        a.ink([(cx + dx * 0.4, 96, cx + dx * 0.6, 76, cx + dx * 0.9, 60, cx + dx, 48)], 7, a=1, b=1)
        a.sil_ellipse(cx + dx, 44, 10, 10, BL)
    BODY = ("M256 90 C304 90 330 122 330 162 C330 188 324 206 336 226 C358 264 370 300 366 340 "
            "C362 400 314 436 256 436 C198 436 150 400 146 340 C142 300 154 264 176 226 "
            "C188 206 182 188 182 162 C182 122 208 90 256 90 Z")
    with a.part():
        a.sil(BODY, BL)
        a.blob("M256 300 C296 300 316 332 316 366 C316 402 292 424 256 424 C220 424 196 402 196 366 C196 332 216 300 256 300 Z", "#6f9ff0")
        for s in (-1, 1):
            a.ellipse(cx + s * 42, 160, 26, 30, WHITE, sw=0, stroke="none")
    a.sil(shift(N2_BEAK, 0, 16), "#f6e7c4")
    b_face(a, cx, 160, 42, 15, cheek=(64, 34))
    return a


def n2_flyer(a, wing, wing_col, tail, tail_col, body_col, wing_ink, belly, inside=None, tips=None):
    """A bird flying toward us: wings out to both sides, tail below (cx = 256)."""
    with a.part():
        sym(a, tail, tail_col, 256)
    with a.part():
        sym(a, wing, wing_col, 256)
        if tips:
            sym(a, tips, "#4a4656", 256, sil=False)
        for s in (-1, 1):
            for c in wing_ink:
                a.ink([c if s < 0 else n2_mx(c, 256)], 8, a=0, b=1, col=O)
    BODY = ("M256 96 C328 96 370 140 370 194 C370 228 356 250 340 266 C356 298 352 356 326 392 "
            "C306 416 206 416 186 392 C160 356 156 298 172 266 C156 250 142 228 142 194 C142 140 184 96 256 96 Z")
    with a.part():
        a.sil(BODY, body_col)
        a.blob("M256 262 C300 262 322 296 322 334 C322 376 298 404 256 404 C214 404 190 376 190 334 "
               "C190 296 212 262 256 262 Z", belly)
        if inside:
            inside(a)


@word
def tsubame():
    a = Art()
    NV, NV_D, WH, RD = "#4a68a8", "#34508a", "#fffaf2", "#e5534b"
    wing = ("M196 250 C150 196 92 140 10 112 C24 180 58 240 104 280 C92 290 92 304 102 314 "
            "C140 326 180 322 208 304 Z")
    tail = "M232 380 C226 430 208 474 176 506 C222 494 252 456 262 400 Z"

    def inside(a):
        a.blob("M256 204 C300 204 322 226 318 252 C312 280 286 292 256 292 C226 292 200 280 194 252 C190 226 212 204 256 204 Z", RD)
        a.blob("M256 96 C290 96 316 106 336 122 C316 150 290 162 256 162 C222 162 196 150 176 122 C196 106 222 96 256 96 Z", NV_D)

    n2_flyer(a, wing, NV_D, tail, NV_D, NV, [(104, 280, 132, 284, 160, 280, 186, 268)], WH, inside)
    a.sil("M244 208 C244 201 268 201 268 208 C268 218 261 225 256 225 C251 225 244 218 244 208 Z", "#f7c948")
    b_face(a, 256, 180, 54, 17, cheek=(86, 34), white=True)
    a.shine("M186 150 C196 132 212 120 232 112")
    return a


@word
def kamome():
    a = Art()
    WH, WH_D, GY, YL = "#fffdf8", "#e3e6ee", "#b4bfcd", "#f7c948"
    wing = ("M200 256 C150 190 86 110 6 84 C0 100 2 118 10 134 C36 204 76 262 126 296 "
            "C160 314 190 314 210 300 Z")
    tips = "M6 84 C0 100 2 118 10 134 C22 166 38 196 56 222 C66 176 56 126 6 84 Z"
    tail = "M236 380 L262 380 L262 400 Z"

    def inside(a):
        a.blob("M196 380 C220 404 292 404 316 380 C306 404 286 414 256 414 C226 414 206 404 196 380 Z", WH_D)
        for x in (228, 284):   # たたんだ 足
            a.blob(f"M{x - 16} 398 C{x - 16} 384 {x + 16} 384 {x + 16} 398 C{x + 12} 408 {x - 12} 408 {x - 16} 398 Z", YL)

    n2_flyer(a, wing, GY, tail, GY, WH, [(126, 296, 150, 292, 172, 284, 190, 270)], WH, inside, tips=tips)
    with a.part():
        a.sil("M236 206 C236 194 276 194 276 206 C276 228 266 244 256 246 C246 244 236 228 236 206 Z", YL)
        a.ellipse(256, 232, 6, 5, RED, sw=0, stroke="none")
    b_face(a, 256, 178, 52, 17, cheek=(84, 36))
    return a


@word
def tsuru():
    a = Art()
    WH, WH_D, BK, RD, BEAK, LEG = "#fffdf8", "#e3e6ee", "#4a4656", "#e5534b", "#e2c98a", "#6b6470"
    G = 478
    neck = [(270, 300, 214, 280, 250, 210, 220, 160), (220, 160, 206, 134, 196, 118, 186, 104)]
    with a.part(ow=8):
        for x, k in ((300, -6), (348, 8)):
            a.sil(f"M{x - 8} 330 L{x + 8} 330 L{x + 8 + k} {G - 10} L{x + 8 + k} {G} L{x - 34 + k} {G} "
                  f"C{x - 34 + k} {G - 8} {x - 20 + k} {G - 12} {x - 8 + k} {G - 12} Z", LEG)
    with a.part():      # くろい おばね
        a.sil("M392 246 C446 244 492 284 500 350 C474 338 454 344 440 362 C424 342 404 334 380 330 Z", BK)
    with a.part(ow=8):
        a.sil(taper([(160, 100, 120, 104, 86, 112, 46, 124)], 26, 7), BEAK)
    with a.part():
        a.sil(taper(neck, 50, 36, cap=False), WH)
        a.sil_ellipse(180, 96, 44, 42, WH)
        a.sil("M250 252 C292 222 384 222 424 256 C452 284 442 332 400 346 C350 360 290 358 256 338 "
              "C232 322 230 278 250 252 Z", WH)
        a_band(a, neck, 0.22, 0.86, 50, 38, BK)
        a.blob("M146 78 C156 54 204 54 214 78 C200 68 160 68 146 78 Z", RD)
        a.blob("M148 76 C158 50 202 50 212 76 C218 86 216 92 212 96 C200 70 160 70 148 96 C144 92 142 86 148 76 Z", RD)
        a.blob("M262 330 C300 350 370 350 410 338 C380 354 300 358 262 330 Z", WH_D)
        a.ink([(300, 262, 340, 300, 390, 310, 432, 296)], 8, a=0, b=1, col="#cfd4de")
    b_side_eye(a, 170, 100, 12, cheek=(8, 24))
    return a


@word
def hakuchou():
    a = Art()
    WH, WH_D, OR, BK = "#fffdf8", "#dfe6f0", "#f59a4a", "#3b3640"
    neck = [(250, 350, 160, 340, 150, 250, 204, 204), (204, 204, 240, 170, 226, 124, 190, 112)]
    with a.part(ow=8):
        a.sil("M150 104 C116 108 88 124 70 148 C100 152 130 144 156 130 Z", OR)
    with a.part():
        a.sil(taper(neck, 58, 40, cap=False), WH)
        a.sil_ellipse(180, 110, 44, 42, WH)
        a.sil("M196 344 C196 310 240 296 290 300 C340 300 420 300 470 262 C500 300 492 380 430 410 "
              "C360 432 260 428 220 406 C200 392 194 366 196 344 Z", WH)
        a.blob("M214 392 C260 420 370 424 440 396 C420 412 400 418 380 422 C320 432 250 426 220 406 Z", WH_D)
        a.blob("M146 96 C140 108 142 122 150 130 C158 126 164 118 166 108 C162 100 154 96 146 96 Z", BK)
    with a.part():      # もちあげた はね
        a.sil("M286 318 C320 250 410 222 492 240 C490 300 450 356 386 372 C340 380 300 356 286 318 Z", WH)
        for c in ((330, 320, 370, 296, 420, 284, 470, 280), (340, 346, 376, 330, 416, 322, 452, 320)):
            a.ink([c], 8, a=0, b=1, col="#cfd8e6")
    b_side_eye(a, 184, 104, 12, cheek=(10, 24))
    return a


@word
def kamo():
    a = Art()
    BODY, BODY_D, CHEST, GN, YL, BL = "#d6c8b0", "#b9a88c", "#a66a44", "#2f9d74", "#f7c948", "#4f7fd8"
    with a.part():
        a.sil("M150 334 C150 296 200 280 260 280 C330 274 410 276 462 236 C490 286 478 372 414 398 "
              "C340 418 230 414 182 394 C160 382 150 358 150 334 Z", BODY)
        a.blob("M150 334 C150 300 190 284 240 281 C250 320 240 370 214 404 C200 400 190 398 182 394 C160 382 150 358 150 334 Z", CHEST)
        a.blob("M462 236 C478 262 482 296 470 330 C452 316 436 290 430 262 C442 256 452 248 462 236 Z", "#4a4656")
        a.blob("M196 398 C250 414 350 416 420 394 C380 412 300 420 240 412 C222 410 208 406 196 398 Z", BODY_D)
    with a.part():
        a.sil("M270 318 C300 280 370 270 430 286 C424 336 390 370 340 374 C304 374 278 352 270 318 Z", BODY_D)
        a.blob("M380 300 C396 296 412 296 426 300 C422 320 414 336 402 348 C392 334 384 318 380 300 Z", BL)
        a.ink([(296, 330, 320, 316, 346, 310, 372, 310)], 7, a=0, b=0.6, col="#8f7e62")
    with a.part(ow=8):
        a.sil("M118 206 C84 200 52 208 36 224 C52 244 88 248 122 238 Z", YL)
    with a.part():
        a.sil("M176 140 C218 140 246 170 246 210 C246 236 238 256 228 272 C232 284 232 292 228 300 "
              "C200 312 150 312 124 300 C120 292 120 284 124 272 C112 256 106 236 106 210 C106 170 134 140 176 140 Z", GN)
        a.blob("M124 272 C150 284 202 284 228 272 C232 284 232 292 228 300 C200 312 150 312 124 300 C120 292 120 284 124 272 Z", WHITE)
    b_side_eye(a, 160, 200, 14)
    a.ellipse(170, 238, 13, 8, "#f3b3a4", sw=0, stroke="none")
    a.shine("M132 190 C138 172 152 160 170 154")
    return a


@word
def kitsutsuki():
    a = Art()
    WOODC, WOOD_D, BK, WH, RD, GY = "#b98556", "#96683c", "#4a4656", "#fbf6ee", "#e5534b", "#8a8f9a"
    with a.part():
        a.sil("M44 24 C76 18 116 18 150 24 L156 488 C120 494 76 494 40 488 Z", WOODC)
        a.blob("M120 22 C132 22 142 23 150 24 L156 488 C146 490 136 491 124 492 Z", WOOD_D)
        for x, y in ((70, 90), (96, 210), (66, 330), (98, 420)):
            a.ink([(x, y - 22, x + 6, y - 8, x + 6, y + 8, x, y + 22)], 8, a=0, b=0, col=WOOD_D)
    with a.part(ow=8):  # あし
        for y in (318, 356):
            a.sil(taper([(250, y + 6, 214, y + 4, 184, y, 156, y - 8)], 16, 12), GY)
    with a.part():      # おばね（木に つっぱる）
        a.sil("M286 396 C270 440 240 474 166 492 C232 496 300 480 340 420 Z", BK)
    with a.part():
        a.sil("M250 190 C314 178 376 232 384 312 C390 372 352 424 300 424 C250 424 216 382 214 322 "
              "C212 272 220 222 250 190 Z", WH)
    with a.part():
        a.sil("M300 196 C352 210 388 262 388 320 C388 372 362 408 328 420 C316 364 312 300 300 196 Z", BK)
        for x, y in ((344, 270), (352, 312), (346, 354), (336, 390)):
            a.ellipse(x, y, 13, 8, WH, sw=0, stroke="none")
    with a.part(ow=8):
        a.sil(taper([(196, 150, 180, 152, 166, 156, 152, 162)], 30, 8), "#c9ccd4")
    with a.part():
        a.sil_ellipse(244, 150, 66, 64, WH)
        a.blob("M244 86 C280 86 306 112 310 146 C312 180 300 200 284 210 C290 176 280 150 262 140 "
               "C240 130 214 124 190 114 C202 96 222 86 244 86 Z", BK)
        a.blob("M244 86 C270 86 290 98 300 116 C280 110 250 108 224 112 C210 114 198 114 190 114 C202 96 222 86 244 86 Z", RD)
    b_side_eye(a, 226, 154, 14, cheek=(10, 28))
    return a


# ------------------------------------------------------ みずの いきもの --
def n2_strip(cubics, w0, w1, f0, f1, t0=0.0, t1=1.0, k=24):
    """A band along a taper()-shaped body: between f0 and f1 of its half-width (-1 = left edge, +1 = right
    edge of travel), from t0 to t1 of its length. For a belly stripe or a fin ridge."""
    ts = [t0 + (t1 - t0) * i / k for i in range(k + 1)]
    hw = lambda t: (w0 + (w1 - w0) * t) / 2
    pts = [at(cubics, t, hw(t) * f0) for t in ts] + [at(cubics, t, hw(t) * f1) for t in ts[::-1]]
    return "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"


@word
def kingyo():
    a = Art()
    RD, RD_D, FIN, BELLY = "#f0614d", "#d94a3c", "#f98f76", "#fff0d8"
    with a.part():
        a.sil("M156 256 C120 196 76 150 22 116 C4 166 12 220 44 256 C12 292 4 346 22 396 C76 362 120 316 156 256 Z", FIN)
        a.sil("M214 150 C222 94 274 62 334 74 C324 102 332 128 352 146 Z", FIN)
        a.sil("M268 380 C268 424 244 450 206 448 C214 420 222 400 228 376 Z", FIN)
        a.sil("M134 256 C144 172 218 120 302 120 C390 120 454 184 464 256 C454 328 390 392 302 392 "
              "C218 392 144 340 134 256 Z", RD)
        a.blob("M170 318 C220 366 350 378 446 300 C420 362 360 390 302 390 C246 390 198 364 170 318 Z", BELLY)
        for c in ((40, 150, 70, 180, 100, 212, 128, 240), (30, 256, 60, 256, 90, 256, 120, 256), (40, 362, 70, 332, 100, 300, 128, 272)):
            a.ink([c], 7, a=0, b=0, col=RD_D)
        for x, y in ((252, 210), (214, 256), (252, 302), (290, 256)):
            a.ink([(x + 16, y - 20, x + 34, y - 8, x + 34, y + 10, x + 16, y + 22)], 7, a=0, b=0, col=RD_D)
    a.sil("M318 270 C292 276 276 300 280 328 C310 326 330 306 334 282 Z", FIN)
    a.path("M440 278 C448 288 458 286 464 276", sw=7)
    b_side_eye(a, 396, 226, 19, cheek=(2, 46))
    a.shine("M180 214 C198 176 236 152 282 146")
    return a


@word
def koi():
    a = Art()
    WH, WH_D, RD, BK, FIN = "#fffaf0", "#e6e0d2", "#f0614d", "#4a4656", "#f7d9c8"
    with a.part():
        a.sil("M96 256 C64 222 38 190 14 150 C0 216 0 296 14 362 C38 322 64 290 96 256 Z", FIN)
        a.sil("M190 172 C220 118 300 108 356 142 C344 152 340 162 342 172 Z", FIN)
        a.sil("M250 348 C250 386 230 408 198 408 C206 386 210 368 214 346 Z", FIN)
        a.sil("M72 256 C100 186 190 150 292 150 C392 150 470 198 492 256 C470 314 392 362 292 362 "
              "C190 362 100 326 72 256 Z", WH)
        a.blob("M110 300 C180 350 340 356 450 300 C420 340 360 360 292 360 C212 360 150 340 110 300 Z", WH_D)
        a.blob("M376 200 C402 204 424 218 438 236 C416 246 388 242 368 226 C360 214 364 204 376 200 Z", RD)
        a.blob("M250 172 C296 166 330 186 332 214 C326 244 276 252 244 232 C222 216 224 184 250 172 Z", RD)
        a.blob("M142 226 C170 214 200 226 204 250 C200 276 164 284 140 268 C124 256 126 236 142 226 Z", RD)
        a.blob("M262 284 C284 276 306 286 306 302 C302 318 272 322 256 310 C248 300 252 290 262 284 Z", BK)
        a.blob("M196 196 C210 190 224 196 224 206 C220 216 204 218 194 212 C190 206 192 200 196 196 Z", BK)
        for c in ((30, 190, 50, 214, 70, 234, 90, 250), (30, 322, 50, 298, 70, 278, 90, 262)):
            a.ink([c], 6, a=0, b=0, col="#e2b8a2")
    a.sil("M330 290 C306 296 292 316 296 340 C322 338 340 322 344 300 Z", FIN)
    a.ink([(476, 282, 486, 296, 486, 312, 476, 322)], 8, a=1, b=0.5)
    a.path("M466 270 C474 278 484 274 490 262", sw=7)
    b_side_eye(a, 424, 240, 16, cheek=(-2, 40))
    return a


@word
def namazu():
    a = Art()
    GY, GY_D, BELLY = "#858a9c", "#696e80", "#f6efe0"
    cx = 320
    body = [(330, 320, 230, 380, 110, 340, 70, 210)]
    with a.part():
        a.sil("M84 226 C50 220 20 196 8 158 C50 150 96 170 112 212 Z", GY_D)
        a.sil("M150 300 C150 250 180 226 216 226 C214 256 204 286 186 312 Z", GY_D)
        a.sil(taper(body, 170, 40, cap=False), GY)
        a.sil("M320 176 C412 176 476 230 476 304 C476 376 412 420 320 420 C228 420 164 376 164 304 "
              "C164 230 228 176 320 176 Z", GY)
        a.blob("M196 366 C250 410 390 410 444 366 C424 404 380 420 320 420 C260 420 216 404 196 366 Z", BELLY)
    for s in (-1, 1):
        for c, w in (((cx + 64, 338, cx + 112, 348, cx + 172, 336, cx + 196, 286), 10), ((cx + 40, 362, cx + 62, 388, cx + 74, 420, cx + 70, 452), 9)):
            q = c if s > 0 else n2_mx(c, cx)
            a.ink([q], w, a=1, b=0.6)
    a.path(f"M{cx - 62} 340 C{cx - 30} 370 {cx + 30} 370 {cx + 62} 340", sw=8)
    b_face(a, cx, 276, 64, 17)
    for s in (-1, 1):
        a.ellipse(cx + s * 100, 320, 16, 10, "#e9a3a8", sw=0, stroke="none")
    a.shine("M214 250 C226 222 250 202 282 194")
    return a


@word
def same():
    a = Art()
    B, BD, BELLY = "#86a6c9", "#6485ad", "#f5f9fd"
    with a.part():
        a.sil("M104 262 C76 220 54 166 46 104 C86 128 120 180 138 244 C124 296 98 352 62 394 C58 342 76 302 104 262 Z", B)
        a.sil("M250 172 C262 112 300 70 352 60 C342 100 348 142 372 174 Z", B)
        a.sil("M100 262 C140 196 230 160 320 160 C402 160 462 196 494 250 C472 310 402 350 320 352 "
              "C230 354 140 322 100 262 Z", B)
        a.blob("M136 294 C200 338 330 348 430 318 C454 310 474 290 488 262 C470 310 402 350 320 351 C244 353 176 332 136 294 Z", BELLY)
        for x in (352, 372, 392):
            a.ink([(x, 216, x - 8, 236, x - 8, 260, x, 280)], 7, a=0, b=0, col=BD)
    a.sil("M306 314 C302 354 276 388 234 400 C236 368 250 334 276 308 Z", BD)
    a.path("M430 290 C448 298 470 292 484 274", sw=7)
    for x in (444, 462):
        a.blob(f"M{x - 6} 295 L{x + 6} 294 L{x + 1} 307 Z", "#ffffff")
    b_side_eye(a, 424, 228, 16, cheek=(-6, 36))
    a.shine("M170 232 C200 200 250 180 300 176")
    return a


@word
def fugu():
    a = Art()
    TOP, TOP_D, WH, SP = "#ecc76a", "#d3a94a", "#fffaf0", "#b98a36"
    cx = 256
    with a.part():
        a.sil("M404 268 C446 236 482 230 500 240 C488 266 488 292 500 318 C482 328 446 322 404 292 Z", TOP_D)
        sym(a, "M116 270 C78 258 50 276 44 304 C72 320 102 314 124 298 Z", TOP_D, cx)
        a.sil("M228 108 C232 78 258 62 284 66 C280 86 286 100 298 112 Z", TOP_D)
        a.sil("M256 100 C352 100 420 172 420 262 C420 352 352 424 256 424 C160 424 92 352 92 262 "
              "C92 172 160 100 256 100 Z", TOP)
        a.blob("M100 296 C150 322 362 322 412 296 C400 366 338 420 256 420 C174 420 112 366 100 296 Z", WH)
        for x, y, r in ((170, 164, 15), (256, 138, 17), (342, 164, 15), (212, 176, 9), (300, 176, 9)):
            a.ellipse(x, y, r, r * 0.8, SP, sw=0, stroke="none")
        for x, y in ((190, 356), (256, 372), (322, 356), (224, 396), (288, 396)):
            a.ink([(x - 10, y - 5, x - 4, y + 5, x + 4, y + 5, x + 10, y - 5)], 7, a=0.4, b=0.4, col="#e2d6c2")
    with a.part(ow=7):
        a.sil_ellipse(cx, 286, 15, 12, "#f28a9b")
    b_face(a, cx, 232, 64, 21, cheek=(102, 40))
    a.shine("M130 220 C140 182 166 150 204 132")
    return a


@word
def unagi():
    a = Art()
    DK, DK_D, BELLY, FIN = "#66758f", "#4f5d76", "#f6efe0", "#8fa0bb"
    body = [(380, 300, 330, 400, 262, 410, 222, 320), (222, 320, 190, 250, 130, 240, 96, 300),
            (96, 300, 78, 336, 52, 352, 24, 344)]
    with a.part():
        a.sil(taper(body, 92, 22), DK)
        a.blob(n2_strip(body, 92, 22, 0.45, 0.97, 0.12, 0.96), BELLY)
        a.blob(n2_strip(body, 92, 22, -0.97, -0.6, 0.2, 0.96), FIN)
    cx = 392
    with a.part():      # むなびれ
        sym(a, "M300 290 C262 284 238 300 236 324 C262 336 290 328 308 312 Z", FIN, cx)
    a.sil("M392 176 C456 176 496 218 496 268 C496 322 452 356 392 356 C332 356 288 322 288 268 C288 218 328 176 392 176 Z", DK)
    a.blob("M318 322 C350 346 434 346 466 322 C448 346 424 356 392 356 C360 356 336 346 318 322 Z", BELLY)
    b_face(a, cx, 262, 48, 18, mouth=36, mw=13)
    for s in (-1, 1):
        a.ellipse(cx + s * 76, 296, 15, 9, "#e9a3a8", sw=0, stroke="none")
    a.shine("M324 240 C332 218 348 202 370 194")
    return a


@word
def ebi():
    a = Art()
    RD, RD_D, LT = "#f47c5c", "#de5f44", "#fbb49c"
    # からだは、おから あたまへ 節を 重ねる（手前の 節の 線が 出るように、節ごとに 部品を 分ける）
    arc = [(330, 150, 420, 190, 440, 330, 330, 392)]
    with a.part(ow=7):   # ひげ
        a.sil(taper([(170, 170, 120, 130, 90, 80, 100, 26)], 12, 6), RD_D)
        a.sil(taper([(180, 160, 150, 110, 150, 60, 180, 20)], 12, 6), RD_D)
    with a.part(ow=8):   # あし
        for i, x in enumerate((196, 228, 260, 292)):
            a.sil(taper([(x, 250, x - 6, 280, x - 16, 300, x - 30, 314)], 16, 9), RD_D)
    with a.part():      # おの おうぎ
        a.sil("M330 380 C290 372 250 384 226 410 C250 426 290 430 322 420 C300 440 296 462 304 480 C336 470 360 440 360 400 Z", RD_D)
    widths = (112, 104, 92, 78)
    for i in range(4):
        t = 1 - i * 0.24
        x, y = at(arc, t)
        w = widths[::-1][i]
        with a.part():
            a.sil_ellipse(x, y, w * 0.62, w * 0.56, RD)
            a.blob(f"M{x - w * 0.3:.0f} {y + w * 0.4:.0f} C{x:.0f} {y + w * 0.56:.0f} {x + w * 0.4:.0f} {y + w * 0.4:.0f} {x + w * 0.56:.0f} {y + w * 0.1:.0f} "
                   f"C{x + w * 0.4:.0f} {y + w * 0.3:.0f} {x:.0f} {y + w * 0.46:.0f} {x - w * 0.3:.0f} {y + w * 0.4:.0f} Z", RD_D)
    with a.part():      # あたま（こうら）
        a.sil("M250 96 C330 96 386 140 386 196 C386 250 340 276 270 276 C200 276 140 258 110 214 "
              "C96 194 104 176 124 172 C160 164 176 140 196 120 C212 104 230 96 250 96 Z", RD)
        a.blob("M150 240 C200 266 300 270 356 238 C336 264 306 276 270 276 C222 276 180 266 150 240 Z", LT)
        a.sil("M118 180 L60 150 L112 208 Z", RD)
    a.eye(204, 180, 18)
    a.eye(296, 180, 18)
    a.cheek(180, 222, 15, 9)
    a.cheek(322, 222, 15, 9)
    a.path("M238 216 C246 226 256 226 264 216", sw=7)
    a.shine("M214 128 C230 114 250 108 272 108")
    return a


@word
def amenbo():
    a = Art()
    BR, BR_D, RIP = "#8a6a52", "#6b4f3c", "#9fd3f2"
    feet = ((60, 150), (452, 150), (40, 390), (472, 390), (170, 420), (342, 420))
    for x, y in feet:           # みずの わ
        a.ellipse(x, y + 6, 46, 16, "none", sw=7, stroke=RIP)
    with a.part(ow=7):
        for (x, y), (bx, by, kx, ky) in zip(feet, ((216, 262, 120, 150), (296, 262, 392, 150), (216, 286, 110, 290),
                                                    (296, 286, 402, 290), (230, 300, 190, 340), (282, 300, 322, 340))):
            a.sil(taper([(bx, by, (bx + kx) / 2, (by + ky) / 2 - 10, kx, ky, kx, ky)], 14, 12, cap=False), BR_D)
            a.sil(taper([(kx, ky, (kx + x) / 2, (ky + y) / 2 - 16, x, y - 4, x, y)], 12, 9), BR_D)
    with a.part():
        a.sil("M256 150 C296 150 318 190 318 250 C318 330 292 400 256 430 C220 400 194 330 194 250 "
              "C194 190 216 150 256 150 Z", BR)
        a.blob("M256 250 C280 250 296 290 290 340 C284 380 270 410 256 426 C242 410 228 380 222 340 C216 290 232 250 256 250 Z", "#a98466")
        a.ink([(256, 262, 256, 310, 256, 360, 256, 420)], 7, a=0, b=1, col=BR_D)
    b_antennae(a, 256, (272, 116, 284, 92, 302, 78, 322, 76), r=8)
    a.sil("M256 96 C300 96 326 122 326 154 C326 186 298 204 256 204 C214 204 186 186 186 154 C186 122 212 96 256 96 Z", BR)
    b_face(a, 256, 150, 32, 14, cheek=(54, 22), mouth=24, mw=10)
    return a


# ---------------------------------------------------------------- むし --
@word
def ari():
    a = Art()
    BK, BK_D, LEG = "#55506a", "#3f3a50", "#3f3a50"
    G = 440
    with a.part(ow=8):
        for x, k in ((262, -1), (300, 0), (338, 1)):
            a.sil(taper([(x, 330, x + k * 14, 360, x + k * 26 - 4, 396, x + k * 30 - 16, 430)], 20, 12), LEG)
    with a.part():
        a.sil_ellipse(430, 316, 96, 76, BK)
        a.sil_ellipse(300, 322, 62, 46, BK)
        a.blob("M360 356 C400 392 470 392 510 350 C490 386 460 392 430 392 C400 392 376 380 360 356 Z", BK_D)
        a.ink([(350, 286, 344, 306, 344, 332, 352, 352)], 8, a=1, b=1, col=BK_D)
        a.ink([(430, 244, 418, 290, 418, 340, 430, 388)], 7, a=0.4, b=0.4, col=BK_D)
    b_antennae(a, 160, (184, 196, 196, 160, 214, 136, 240, 126), r=9)
    a.sil("M160 190 C226 190 262 232 262 284 C262 340 218 372 160 372 C102 372 58 340 58 284 C58 232 94 190 160 190 Z", BK)
    b_face(a, 160, 278, 42, 17, cheek=(70, 34), white=True, mouth=36, mw=12, col=WHITE)
    a.shine("M398 262 C420 252 446 256 466 272")
    return a


@word
def batta():
    a = Art()
    G_, GD, GL, WING = "#8fcf6a", "#63ad4f", "#d8f0b4", "#6fba58"
    G = 444
    with a.part(ow=8):  # 前の あし
        for x in (236, 286):
            a.sil(taper([(x, 340, x - 6, 376, x - 18, 410, x - 34, 436)], 20, 11), GD)
    with a.part():
        a.sil("M210 250 C270 232 400 240 520 330 C440 370 300 380 220 360 C196 330 194 280 210 250 Z", G_)
        a.blob("M230 350 C300 372 420 364 506 332 C440 368 300 380 222 360 Z", GL)
    with a.part():      # はね
        a.sil("M250 252 C330 236 440 262 536 318 C460 330 340 324 262 300 C248 288 244 266 250 252 Z", WING)
        a.ink([(280, 280, 350, 290, 430, 300, 500, 314)], 7, a=0, b=0, col=GD)
    with a.part():      # うしろあし（おおきく まがる）
        a.sil(taper([(340, 330, 372, 270, 404, 214, 440, 160)], 54, 24), G_)
        a.sil(taper([(440, 162, 452, 250, 468, 340, 490, 432)], 20, 12), GD)
        a.sil("M480 424 L520 432 C526 438 522 444 514 444 L476 444 Z", GD)
        a.ink([(352, 320, 378, 276, 402, 236, 428, 196)], 7, a=0, b=0, col=GD)
    b_antennae(a, 150, (172, 150, 190, 110, 220, 80, 262, 70), r=8)
    a.sil("M150 150 C212 150 244 192 244 246 C244 312 206 356 150 356 C94 356 56 312 56 246 C56 192 88 150 150 150 Z", G_)
    b_face(a, 150, 246, 40, 18, mouth=38, mw=12)
    for s in (-1, 1):
        a.ellipse(150 + s * 64, 284, 15, 9, "#f3b3a4", sw=0, stroke="none")
    a.shine("M90 220 C98 196 114 178 136 170")
    return a


@word
def kamakiri():
    a = Art()
    G_, GD, GL = "#8fcf6a", "#63ad4f", "#d8f0b4"
    cx = 256
    with a.part(ow=8):  # あし
        for s in (-1, 1):
            for c in ((cx + s * 30, 330, cx + s * 80, 340, cx + s * 110, 390, cx + s * 120, 446),
                      (cx + s * 24, 380, cx + s * 50, 400, cx + s * 60, 430, cx + s * 64, 470)):
                a.sil(taper([c], 18, 10), GD)
    with a.part():      # おなか と むね
        a.sil("M256 300 C310 300 330 360 320 420 C312 462 286 488 256 496 C226 488 200 462 192 420 "
              "C182 360 202 300 256 300 Z", G_)
        a.sil("M228 200 L284 200 L290 330 L222 330 Z", G_)
        a.blob("M256 330 C284 330 296 370 290 420 C284 456 270 478 256 488 C242 478 228 456 222 420 C216 370 228 330 256 330 Z", GL)
        for y in (372, 410, 446):
            a.ink([(226, y, 244, y + 8, 268, y + 8, 286, y)], 6, a=0, b=0, col=GD)
    with a.part():      # かま
        for s in (-1, 1):
            m = (lambda c: c) if s < 0 else (lambda c: n2_mx(c, cx))
            a.sil(taper([m((232, 250, 190, 270, 150, 262, 120, 226))], 34, 26, cap=False), G_)
            a.sil(taper([m((122, 232, 86, 190, 80, 130, 108, 80))], 40, 12), G_)
        for s in (-1, 1):
            for t in (0.3, 0.5, 0.7):
                c = (122, 232, 86, 190, 80, 130, 108, 80)
                x, y = at([c], t, -12)
                x2, y2 = at([c], t + 0.06, -26)
                if s > 0:
                    x, x2 = 2 * cx - x, 2 * cx - x2
                a.ink([(x, y, (x + x2) / 2, (y + y2) / 2, x2, y2, x2, y2)], 7, a=1, b=0, col=GD)
    b_antennae(a, cx, (270, 84, 280, 56, 298, 40, 322, 36), r=7, w=7)
    a.sil("M256 80 C300 80 356 96 372 124 C380 140 372 160 356 176 C330 204 290 232 256 232 "
          "C222 232 182 204 156 176 C140 160 132 140 140 124 C156 96 212 80 256 80 Z", G_)
    b_face(a, cx, 140, 68, 19, mouth=52, mw=12)
    for s in (-1, 1):
        a.ellipse(cx + s * 44, 184, 13, 8, "#f3b3a4", sw=0, stroke="none")
    return a


@word
def kuwagata():
    a = Art()
    SH, SH_D, HD, JAW = "#4f4a5c", "#3a3646", "#5f5a70", "#3a3646"
    cx = 256
    with a.part():
        for s in (-1, 1):
            for y, dx, dy in ((282, 150, -26), (346, 166, 8), (410, 142, 40)):
                a.sil(taper([(cx + s * 96, y, cx + s * 122, y, cx + s * (dx - 12), y + dy * 0.6, cx + s * dx, y + dy)], 24, 14), SH_D)
    with a.part():      # おおあご
        jaw = [(224, 170, 170, 150, 150, 90, 190, 36)]
        sym(a, taper(jaw, 40, 16), JAW, cx)
        sym(a, "M176 116 L206 108 L186 86 Z", JAW, cx)
    with a.part():
        a.sil("M256 250 C330 250 372 296 372 362 C372 432 322 478 256 478 C190 478 140 432 140 362 "
              "C140 296 182 250 256 250 Z", SH)
        a.blob("M170 430 C200 466 250 480 300 470 C330 462 352 444 364 420 C340 452 300 464 256 464 C220 464 190 452 170 430 Z", SH_D)
        a.ink([(256, 256, 256, 330, 256, 400, 256, 477)], 8, a=1, b=1, col=SH_D)
    with a.part():      # むね
        a.sil("M166 216 C190 196 322 196 346 216 C366 240 360 272 340 284 C300 296 212 296 172 284 C152 272 146 240 166 216 Z", SH)
    a.sil("M256 130 C310 130 340 156 340 190 C340 224 306 244 256 244 C206 244 172 224 172 190 C172 156 202 130 256 130 Z", HD)
    b_face(a, cx, 186, 36, 14, cheek=(62, 24), white=True, mouth=28, mw=10, col=WHITE)
    a.shine("M168 344 C170 316 184 292 206 278")
    return a


@word
def suzumushi():
    a = Art()
    BK, BK_D, WING, WING_D = "#5a4a48", "#43363a", "#b98f6a", "#96704c"
    with a.part(ow=7):   # ながい ひげ
        a.sil(taper([(150, 250, 110, 200, 60, 170, 6, 170)], 10, 5), "#fff6e6")
        a.sil(taper([(170, 240, 150, 180, 110, 130, 60, 100)], 10, 5), "#fff6e6")
    with a.part(ow=8):
        for x in (250, 300):
            a.sil(taper([(x, 380, x - 6, 404, x - 18, 424, x - 34, 440)], 18, 10), BK_D)
        a.sil(taper([(380, 372, 420, 330, 450, 310, 474, 316)], 30, 16), BK_D)
        a.sil(taper([(474, 316, 486, 360, 496, 400, 512, 440)], 14, 10), BK_D)
    with a.part():      # たてた はね（ならして いる）
        a.sil("M250 330 C230 250 260 150 340 110 C410 140 440 230 420 330 C370 356 300 356 250 330 Z", WING)
        a.blob("M340 110 C410 140 440 230 420 330 C400 342 380 348 360 350 C388 280 380 180 340 110 Z", WING_D)
        for c in ((270, 300, 290, 240, 310, 180, 340, 126), (310, 330, 330, 270, 340, 200, 344, 140), (360, 334, 376, 280, 376, 220, 356, 150)):
            a.ink([c], 6, a=0, b=0, col="#7a5a3c")
    with a.part():
        a.sil("M210 330 C270 316 390 320 450 366 C430 404 300 414 230 400 C204 382 200 350 210 330 Z", BK)
    a.sil("M160 230 C218 230 250 270 250 318 C250 372 212 404 160 404 C108 404 70 372 70 318 C70 270 102 230 160 230 Z", BK)
    b_face(a, 160, 314, 40, 17, cheek=(66, 32), white=True, mouth=36, mw=12, col=WHITE)
    note(a, 440, 60, 1.3)
    note(a, 496, 150, 1.0, col="#f47c9a")
    return a
