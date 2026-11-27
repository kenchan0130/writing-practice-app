import sys
import os
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "Content", "Art", "words")
sys.path.insert(0, HERE)
from lib import Art, mirror, shift, place, fit_params, O, EYE, SW

RED, RED_D = "#e5534b", "#c9403a"
YEL, YEL2 = "#f6d36b", "#f7c948"
BLUE, BLUE_D, SKY = "#4fa8e0", "#3f97d0", "#bfe6fa"
WOOD, WOOD_D = "#f2b56b", "#c97f3e"
PINK, PINK_IN, CHEEK = "#f7b3bd", "#f7a8b3", "#ff9aa8"
GREEN = "#7cc36a"
CREAM = "#fff4e2"
WHITE = "#ffffff"
GREY = "#5a4a42"
HUB = "#d8d2cc"
NAVY = "#34507e"

W = {}
GROUND = {"inu", "ushi", "zou", "kirin", "neko", "kuma"}  # side-view animals: feet stay on the old ground line


def word(f):
    W[f.__name__] = f
    return f


# ---------------------------------------------------------------- animals --
HEAD = "M256 92 C350 92 392 140 392 210 C392 280 340 318 256 318 C172 318 120 280 120 210 C120 140 162 92 256 92 Z"
BODY = ("M168 300 C168 280 200 270 256 270 C312 270 344 280 344 300 L352 432 C352 446 342 452 328 452 "
        "L282 452 C272 452 268 446 268 436 C268 398 244 398 244 436 C244 446 240 452 230 452 L184 452 "
        "C170 452 160 446 160 432 Z")
HOOF_L = "M161 424 L244 424 L244 436 C244 446 240 452 230 452 L184 452 C170 452 160 446 160 432 Z"
HOOF_R = mirror(HOOF_L)


def both(a, d, **kw):
    a.path(d, **kw)
    a.path(mirror(d), **kw)


def body(a, col, belly=None, hooves=None, toes=False):
    a.path(BODY, fill=col)
    if belly:
        a.ellipse(256, 372, 52, 44, belly, sw=0, stroke="none")
    if hooves:
        a.path(HOOF_L, fill=hooves, sw=9)
        a.path(HOOF_R, fill=hooves, sw=9)
        a.path(BODY)
    if toes:
        for x in (190, 214, 298, 322):
            a.line(x, 438, x, 452, sw=7)


# --- batch A helpers begin (saru tora kaba rakuda buta hitsuji tanuki kitsune usagi uma shika risu) ---
GROUND.update({"saru", "tora", "kaba", "rakuda", "buta", "hitsuji", "tanuki", "kitsune", "usagi", "uma", "shika", "risu"})


def a_face(a, cx, y, gap, r=17, cheek=None):
    """Two eyes of the same size and two cheeks, mirrored around cx. cheek = (dx, y, rx, ry)."""
    a.eye(cx - gap, y, r)
    a.eye(cx + gap, y, r)
    if cheek:
        dx, cy, rx, ry = cheek
        a.cheek(cx - dx, cy, rx, ry)
        a.cheek(cx + dx, cy, rx, ry)


def a_snout(a, cx, y, col=EYE, w=16, m=1.0, line=False):
    """A rounded-triangle nose (top at y) and a small 'w' mouth under it. m scales the mouth."""
    d = (f"M{cx - w} {y} C{cx - w} {y - w * 0.62} {cx + w} {y - w * 0.62} {cx + w} {y} "
         f"C{cx + w} {y + w * 0.7} {cx + w * 0.25} {y + w * 1.06} {cx} {y + w * 1.06} "
         f"C{cx - w * 0.25} {y + w * 1.06} {cx - w} {y + w * 0.7} {cx - w} {y} Z")
    if line:
        a.path(d, fill=col, sw=6)
    else:
        a.blob(d, col)
        a.dot(cx - w * 0.36, y - w * 0.12, w * 0.26, WHITE)
    y1 = y + w * 1.06
    y2 = y1 + 9 * m
    a.path(f"M{cx} {y1} L{cx} {y2} M{cx} {y2} C{cx - 6 * m} {y2 + 12 * m} {cx - 20 * m} {y2 + 12 * m} {cx - 24 * m} {y2 + 2 * m} "
           f"M{cx} {y2} C{cx + 6 * m} {y2 + 12 * m} {cx + 20 * m} {y2 + 12 * m} {cx + 24 * m} {y2 + 2 * m}", sw=7)


def a_wool(cx, cy, rx, ry, n, start=0.0, puff=0.62):
    """One closed fluffy outline: n round bumps along an ellipse (wool, a tail puff). One path, not circles."""
    import math
    pts = [(cx + rx * math.cos(start + 2 * math.pi * i / n), cy + ry * math.sin(start + 2 * math.pi * i / n)) for i in range(n)]
    f = lambda v: f"{v:.1f}"
    out = [f"M{f(pts[0][0])} {f(pts[0][1])}"]
    for i in range(n):
        (px, py), (qx, qy) = pts[i], pts[(i + 1) % n]
        tx, ty = qx - px, qy - py
        nx, ny = ty, -tx          # outward for a clockwise (on screen) walk
        k, e = puff, 0.12
        out.append(f"C{f(px + nx * k - tx * e)} {f(py + ny * k - ty * e)} {f(qx + nx * k + tx * e)} {f(qy + ny * k + ty * e)} {f(qx)} {f(qy)}")
    return " ".join(out) + " Z"


def a_band(a, cubics, t0, t1, w0, w1, col, k=6):
    """A stripe across a taper()-shaped tail that follows its curve (band() is straight; fine for thin tails only)."""
    ts = [t0 + (t1 - t0) * i / k for i in range(k + 1)]
    pts = [at(cubics, t, (w0 + (w1 - w0) * t) / 2 + 1) for t in ts] + [at(cubics, t, -(w0 + (w1 - w0) * t) / 2 - 1) for t in ts[::-1]]
    a.blob("M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z", col)


def a_ear_round(a, cx, dx, y, r, fill, inner, head, ir=0.5, shift_in=3):
    """Round ears in the same part as the head; the inner colour is hidden where the head covers it."""
    for s in (-1, 1):
        a.sil_ellipse(cx + s * dx, y, r, r - 1, fill)
    a.sil(head, fill)
    for s in (-1, 1):
        a.ellipse(cx + s * (dx - shift_in), y + 2, r * ir, r * ir - 1, inner, sw=0, stroke="none")
    a.blob(head, fill)
# --- batch A helpers end ---


@word
def uma():
    a = Art()
    CH, CH_D, MANE, MZ, HOOF = "#d9935a", "#bd7a45", "#7a4a2b", "#f2c49a", "#5f4a3e"
    G = 462
    neck = [(318, 304, 292, 270, 258, 232, 236, 190)]
    with a.part():
        hoofed(a, [(336, 320), (342, 380), (340, 412), (342, 444)], [46, 30, 32, 26], G, CH_D, HOOF, hh=20)
        hoofed(a, [(416, 320), (402, 372), (414, 408), (408, 444)], [46, 32, 30, 26], G, CH_D, HOOF, hh=20)
    with a.part():
        a.sil("M462 250 C524 240 560 300 548 372 C542 408 518 420 498 408 C514 372 506 326 456 300 Z", MANE)
        a.sil("M258 70 C290 80 310 112 312 150 C306 150 300 152 296 156 C318 156 340 176 342 206 "
              "C336 204 330 206 326 210 C348 210 372 228 374 258 L340 272 L260 200 L240 110 Z", MANE)
    with a.part():
        a.sil(taper(neck, 130, 96, cap=False), CH)
        a.sil("M262 252 C310 228 404 226 450 246 C490 264 494 320 470 346 C446 368 384 362 334 364 "
              "C296 366 262 366 246 342 C232 316 238 272 262 252 Z", CH)
        hoofed(a, [(288, 310), (284, 380), (282, 412), (280, 444)], [66, 36, 40, 30], G, CH, HOOF, hh=20)
        hoofed(a, [(452, 300), (450, 364), (468, 406), (462, 444)], [88, 44, 36, 30], G, CH, HOOF, hh=20)
        a.blob("M318 364 C350 366 390 364 420 358 C416 350 416 344 418 338 C386 348 350 348 320 344 Z", CH_D)
        a.ink([(422, 368, 412, 340, 420, 310, 442, 290)], 8, a=1, b=0)
        a.ink([(314, 368, 320, 348, 318, 330, 310, 314)], 7, a=1, b=0)
        a.shine("M430 262 C448 264 462 276 466 294", sw=7)
    cx = 196
    HEADP = ("M196 40 C252 40 280 80 278 128 C276 168 268 190 260 208 C250 234 228 246 196 246 "
             "C164 246 142 234 132 208 C124 190 116 168 114 128 C112 80 140 40 196 40 Z")
    with a.part():
        sym(a, "M142 86 C128 54 132 22 148 4 C170 20 182 48 182 74 Z", CH, cx)
        a.sil(HEADP, CH)
        sym(a, "M150 72 C142 52 144 32 150 22 C162 34 168 52 168 68 Z", PINK_IN, cx, sil=False)
        a.blob(HEADP, CH)
        a.blob("M196 62 C210 62 212 84 210 108 C208 134 212 150 216 166 L176 166 C180 150 184 134 182 108 C180 84 182 62 196 62 Z", WHITE)
    a.ellipse(cx, 204, 58, 36, MZ, sw=0, stroke="none")
    a.sil("M172 50 C176 28 216 28 220 50 C220 66 214 78 208 86 C208 74 202 70 196 82 "
          "C192 70 186 72 184 86 C178 78 172 66 172 50 Z", MANE)
    for s in (-1, 1):
        a.ellipse(cx + s * 20, 202, 6.5, 9.5, O, sw=0, stroke="none")
    a.path("M178 224 C189 233 203 233 214 224", sw=7)
    a_face(a, cx, 136, 42, 17, cheek=(58, 170, 14, 8))
    return a.flipped()


@word
def shika():
    a = Art()
    BR, BR_D, AN, HOOF = "#c98a52", "#ad7340", "#f0d9a8", "#5f4a3e"
    G = 470
    neck = [(318, 310, 292, 276, 258, 236, 232, 190)]
    with a.part():
        hoofed(a, [(336, 326), (346, 388), (346, 420), (350, 452)], [38, 24, 26, 20], G, BR_D, HOOF, hh=18)
        hoofed(a, [(414, 326), (398, 380), (408, 416), (400, 452)], [40, 26, 24, 20], G, BR_D, HOOF, hh=18)
    with a.part():
        a.sil("M468 262 C496 252 516 272 510 302 C494 304 474 296 462 284 Z", BR)
        a.sil(taper(neck, 112, 80, cap=False), BR)
        a.sil("M268 262 C314 240 404 238 448 256 C486 272 490 322 468 346 C444 366 386 360 338 362 "
              "C300 364 268 364 252 342 C238 318 244 280 268 262 Z", BR)
        hoofed(a, [(292, 316), (286, 386), (282, 420), (278, 452)], [54, 26, 30, 22], G, BR, HOOF, hh=18)
        hoofed(a, [(452, 306), (452, 370), (470, 414), (466, 452)], [74, 34, 28, 22], G, BR, HOOF, hh=18)
        a.blob("M484 272 C502 270 510 284 508 300 C498 300 488 294 480 286 Z", WHITE)
        a.blob("M318 362 C350 365 392 362 420 357 C390 344 348 345 318 362 Z", "#e6bd8e")
        for x, y, r in ((330, 270, 9), (366, 262, 10), (404, 264, 9), (438, 278, 8), (350, 294, 7), (390, 292, 8), (426, 304, 7)):
            a.ellipse(x, y, r, r - 1, CREAM, sw=0, stroke="none")
        a.ink([(424, 366, 414, 340, 422, 312, 444, 294)], 8, a=1, b=0)
        a.ink([(310, 366, 316, 348, 314, 332, 306, 318)], 7, a=1, b=0)
    cx = 200
    with a.part():
        for d in (taper([(172, 96, 160, 64, 142, 36, 118, 16)], 18, 12),
                  taper([(158, 66, 166, 48, 170, 32, 170, 14)], 13, 10),
                  taper([(140, 38, 126, 42, 110, 40, 96, 32)], 12, 10)):
            sym(a, d, AN, cx)
    HEADP = ("M200 76 C254 76 284 112 284 156 C284 184 274 206 260 222 C244 240 224 248 200 248 "
             "C176 248 156 240 140 222 C126 206 116 184 116 156 C116 112 146 76 200 76 Z")
    with a.part():
        sym(a, "M126 134 C96 108 56 112 44 134 C62 162 100 164 130 156 Z", BR, cx)
        a.sil(HEADP, BR)
        sym(a, "M114 138 C96 124 72 126 62 136 C76 150 98 152 118 148 Z", PINK_IN, cx, sil=False)
        a.blob(HEADP, BR)
    for x, y in ((182, 102), (200, 96), (218, 102)):
        a.dot(x, y, 5, CREAM)
    a.ellipse(cx, 214, 42, 28, CREAM, sw=0, stroke="none")
    a_snout(a, cx, 200, EYE, 14, m=0.85)
    a_face(a, cx, 154, 42, 16, cheek=(62, 192, 14, 8))
    a.shine("M138 132 C146 116 160 104 176 98")
    return a


@word
def risu():
    a = Art()
    OR, OR_D, TL, LT = "#d98a47", "#bf7436", "#eba460", "#f7dcb4"
    G = 454
    with a.part():
        a.sil("M320 440 C410 452 478 404 474 320 C470 262 440 236 452 188 C462 150 494 128 474 90 "
              "C454 56 398 58 384 96 C418 98 432 128 410 160 C380 204 382 252 372 300 C362 360 342 400 320 440 Z", TL)
        a.ink([(436, 104, 458, 128, 446, 166, 434, 196), (434, 196, 420, 236, 434, 272, 438, 318)], 14, a=0, b=0, col=LT)
    FOOTP = "M176 454 C158 454 158 430 178 426 C214 420 284 422 296 440 C300 448 296 454 288 454 Z"
    with a.part():
        a.sil("M236 240 C296 232 352 286 358 366 C362 420 334 454 286 454 L228 454 C198 454 186 424 190 376 "
              "C194 326 204 262 236 240 Z", OR)
        a.sil(FOOTP, OR)
        a.blob("M214 290 C200 330 196 376 202 410 C212 424 236 426 252 420 C260 388 258 330 238 288 Z", LT)
        a.blob(FOOTP, OR)
        a.ink([(196, 425, 232, 418, 282, 422, 297, 442)], 9, a=1, b=0.3)
        a.ink([(296, 336, 344, 336, 370, 388, 340, 438)], 9, a=0, b=0)
        toes(a, 180, G + 1, d=-1, gap=12, h=10)
    # acorn held at the chest; far hand behind it, near arm over it
    a.sil_ellipse(170, 338, 15, 13, OR_D)
    with a.part():
        a.sil("M168 334 C168 316 228 316 228 334 C228 368 212 384 198 384 C184 384 168 368 168 334 Z", "#b0682f")
        a.sil("M162 338 C160 304 236 304 234 338 Z", "#6b4a2e")
        a.sil(taper([(198, 312, 199, 306, 201, 300, 204, 294)], 8, 7), "#6b4a2e")
    with a.part():
        a.sil(taper([(262, 226, 284, 288, 262, 334, 224, 346)], 40, 30), OR)
    cx = 226
    HEADP = "M226 70 C290 70 328 110 328 160 C328 214 286 246 226 246 C166 246 124 214 124 160 C124 110 162 70 226 70 Z"
    with a.part():
        sym(a, "M150 120 C138 88 148 58 170 42 C190 62 198 88 192 112 Z", OR, cx)
        a.sil(HEADP, OR)
        sym(a, "M160 108 C154 88 160 70 170 60 C180 72 184 90 180 106 Z", PINK_IN, cx, sil=False)
        a.blob(HEADP, OR)
    a.ellipse(cx, 208, 62, 31, LT, sw=0, stroke="none")
    a_snout(a, cx, 194, EYE, 11, m=0.8)
    a.rect(cx - 6, 214, 12, 11, WHITE, rx=3, sw=5)
    a_face(a, cx, 158, 46, 17, cheek=(78, 200, 15, 9))
    a.shine("M150 136 C158 116 174 102 194 96")
    return a


# ------------------------------------------------------------- vehicles ----
RUN = "M60 395 L360 395 C425 395 452 352 440 318 C430 290 394 292 392 318 C391 336 410 342 421 333"


# --- batch C helpers begin ---
# のりもの・たてもの・こうえんの物（顔なし）。塗りだけを描いて、線は part() が付ける。
C_K = 0.5523


def c_rpoly(pts, r):
    """A polygon with rounded corners (one radius, or one per corner; 0 = sharp)."""
    n = len(pts)
    rs = list(r) if isinstance(r, (list, tuple)) else [r] * n
    out = []
    for i in range(n):
        p0, p1, p2 = pts[i - 1], pts[i], pts[(i + 1) % n]

        def toward(q, dist):
            dx, dy = q[0] - p1[0], q[1] - p1[1]
            L = (dx * dx + dy * dy) ** 0.5 or 1
            k = min(dist, L / 2) / L
            return p1[0] + dx * k, p1[1] + dy * k
        u, v = toward(p0, rs[i]), toward(p2, rs[i])
        out.append(("M" if i == 0 else "L") + f"{u[0]:.1f} {u[1]:.1f}")
        if rs[i] > 0:
            out.append(f"Q{p1[0]:g} {p1[1]:g} {v[0]:.1f} {v[1]:.1f}")
    return " ".join(out) + " Z"


def c_rect(x, y, w, h, r):
    return c_rpoly([(x, y), (x + w, y), (x + w, y + h), (x, y + h)], r)


def c_circ(cx, cy, r, ry=None, ccw=False):
    """A circle / ellipse as a path (ccw=True: a hole inside another shape)."""
    ry = ry or r
    k, j = r * C_K, ry * C_K
    if ccw:
        return (f"M{cx + r:g} {cy:g} C{cx + r:g} {cy - j:g} {cx + k:g} {cy - ry:g} {cx:g} {cy - ry:g} "
                f"C{cx - k:g} {cy - ry:g} {cx - r:g} {cy - j:g} {cx - r:g} {cy:g} "
                f"C{cx - r:g} {cy + j:g} {cx - k:g} {cy + ry:g} {cx:g} {cy + ry:g} "
                f"C{cx + k:g} {cy + ry:g} {cx + r:g} {cy + j:g} {cx + r:g} {cy:g} Z")
    return (f"M{cx + r:g} {cy:g} C{cx + r:g} {cy + j:g} {cx + k:g} {cy + ry:g} {cx:g} {cy + ry:g} "
            f"C{cx - k:g} {cy + ry:g} {cx - r:g} {cy + j:g} {cx - r:g} {cy:g} "
            f"C{cx - r:g} {cy - j:g} {cx - k:g} {cy - ry:g} {cx:g} {cy - ry:g} "
            f"C{cx + k:g} {cy - ry:g} {cx + r:g} {cy - j:g} {cx + r:g} {cy:g} Z")


def c_bar(x0, y0, x1, y1, w):
    """A straight bar with round ends (pipes, posts, rails)."""
    dx, dy = x1 - x0, y1 - y0
    L = (dx * dx + dy * dy) ** 0.5 or 1
    ux, uy = dx / L, dy / L
    h = w / 2
    nx, ny = -uy * h, ux * h
    k = h * 1.333
    return (f"M{x0 + nx:.1f} {y0 + ny:.1f} L{x1 + nx:.1f} {y1 + ny:.1f} "
            f"C{x1 + nx + ux * k:.1f} {y1 + ny + uy * k:.1f} {x1 - nx + ux * k:.1f} {y1 - ny + uy * k:.1f} {x1 - nx:.1f} {y1 - ny:.1f} "
            f"L{x0 - nx:.1f} {y0 - ny:.1f} "
            f"C{x0 - nx - ux * k:.1f} {y0 - ny - uy * k:.1f} {x0 + nx - ux * k:.1f} {y0 + ny - uy * k:.1f} {x0 + nx:.1f} {y0 + ny:.1f} Z")


def c_line(a, x0, y0, x1, y1, w=7, s=0.0, e=0.0, col=O):
    """A straight inner line that thins out at its ends (s, e: 0 = point, 1 = full width)."""
    a.ink([(x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)],
          w, a=s, b=e, col=col)


def c_glass(a, d, ow=6, col=SKY, glint=None):
    """A window: sky colour, a thin outline, and (glint = (x, y, len)) a short white slash."""
    with a.part(ow):
        a.sil(d, col)
    if glint:
        x, y, n = glint
        a.path(f"M{x} {y + n} L{x + n * 0.6:g} {y}", stroke=WHITE, sw=6, **{"stroke-opacity": "0.75"})


def c_wheel(a, cx, cy, r, hub=HUB):
    """A tyre with a pale hub. Call it on its own (own outline) or inside a part."""
    a.sil(c_circ(cx, cy, r), GREY)
    a.dot(cx, cy, r * 0.47, hub)
    a.dot(cx, cy, r * 0.17, "#a39a93")
    q = r * 0.74
    a.path(f"M{cx - q:g} {cy - q * 0.12:g} C{cx - q * 0.95:g} {cy - q * 0.55:g} {cx - q * 0.6:g} {cy - q * 0.9:g} {cx - q * 0.18:g} {cy - q * 0.98:g}",
           stroke=WHITE, sw=5, **{"stroke-opacity": "0.35"})


def c_lamp(a, cx, cy, rx, ry=None, col=YEL, ow=6):
    with a.part(ow):
        a.sil(c_circ(cx, cy, rx, ry), col)


def c_waves(a, y=392, x0=30, x1=482, n=5, amp=13, depth=36, col="#9fd3f2"):
    """A strip of water with round crests, in front of a boat."""
    w = (x1 - x0) / n
    top = [f"M{x0:g} {y:g}"]
    for i in range(n):
        xa = x0 + i * w
        top.append(f"C{xa + w * 0.18:g} {y - amp:g} {xa + w * 0.32:g} {y - amp:g} {xa + w * 0.5:g} {y:g} "
                   f"C{xa + w * 0.68:g} {y + amp:g} {xa + w * 0.82:g} {y + amp:g} {xa + w:g} {y:g}")
    d = " ".join(top) + (f" L{x1:g} {y + depth - 12:g} Q{x1:g} {y + depth:g} {x1 - 12:g} {y + depth:g} "
                         f"L{x0 + 12:g} {y + depth:g} Q{x0:g} {y + depth:g} {x0:g} {y + depth - 12:g} Z")
    with a.part():
        a.sil(d, col)
    for i in range(n):
        xa = x0 + i * w
        a.path(f"M{xa + w * 0.1:g} {y + 4:g} C{xa + w * 0.2:g} {y - amp * 0.3:g} {xa + w * 0.3:g} {y - amp * 0.3:g} {xa + w * 0.4:g} {y + 4:g}",
               stroke=WHITE, sw=6, **{"stroke-opacity": "0.85"})
# --- batch C helpers end ---


@word
def sori():
    a = Art()
    PLANK = "#f6c98b"
    DX, DY = 44, -54                                  # how far the far side sits from the near side
    run_near = [(64, 404, 160, 404, 250, 404, 330, 404), (330, 404, 420, 404, 462, 372, 452, 296)]
    run_far = [tuple(v + (DX if i % 2 == 0 else DY) for i, v in enumerate(c)) for c in run_near]
    with a.part():                                    # far runner and its posts
        a.sil(taper(run_far, 22, 22), RED_D)
        a.sil(c_circ(64 + DX, 404 + DY, 11), RED_D)
        for x in (120, 300):
            a.sil(c_rect(x + DX, 300 + DY, 26, 96, 6), "#b36d32")
    with a.part(9):                                   # the pull rope hangs between the two curls
        a.sil(taper([(452, 300, 492, 330, 532, 296, 496, 246)], 10, 10), YEL)
    with a.part():                                    # near posts
        for x in (120, 300):
            a.sil(c_rect(x, 300, 26, 96, 6), WOOD_D)
    with a.part():                                    # the seat: one slab, planks drawn with thin lines
        a.sil(c_rpoly([(136, 232), (398, 232), (352, 290), (352, 316), (92, 316), (92, 290)], [14, 16, 10, 10, 10, 10]), PLANK)
        a.blob(c_rpoly([(94, 292), (350, 292), (350, 314), (94, 314)], [0, 0, 8, 8]), WOOD_D)
        for k in (1, 2):
            dx, dy = DX * k / 3, -58 * k / 3
            c_line(a, 104 + dx, 290 + dy, 346 + dx, 290 + dy, 6, col=WOOD_D)
    a.shine("M156 246 L300 246", sw=6)
    with a.part():                                    # near runner with its curl
        a.sil(taper(run_near, 24, 24), RED)
        a.sil(c_circ(64, 404, 12), RED)
    a.shine("M86 399 L290 399", sw=5)
    return a


@word
def kuruma():
    a = Art()
    BODY_D = ("M66 322 C66 296 86 286 116 282 L150 278 C166 212 206 166 266 166 L306 166 C362 166 394 212 410 274 "
              "L438 280 C460 286 470 304 470 328 L470 346 Q470 374 442 374 L94 374 Q66 374 66 346 Z")
    with a.part():
        a.sil(BODY_D, RED)
        a.blob("M67 340 L469 340 L469 346 Q469 373 442 373 L94 373 Q67 373 67 346 Z", RED_D)
        a.blob(c_rect(66, 300, 12, 30, 5), "#f9b6bf")              # tail lamp
    c_glass(a, "M182 276 C194 232 222 198 262 196 L276 196 L276 276 Z", glint=(214, 232, 26))
    c_glass(a, "M300 196 L310 196 C348 198 372 232 382 276 L300 276 Z")
    c_line(a, 288, 286, 288, 362, 7)
    a.blob(c_rect(306, 300, 30, 11, 5), WHITE)                     # door handle
    c_lamp(a, 452, 312, 12, 15)
    a.shine("M214 180 C240 174 300 172 330 180")
    for x in (150, 380):
        c_wheel(a, x, 376, 52)
    return a


@word
def fune():
    a = Art()
    with a.part():                                    # funnel
        a.sil(c_rect(298, 84, 62, 110, 14), RED)
        a.blob(c_rect(298, 112, 62, 22, 0), WHITE)
    a.path("M212 166 L212 76", sw=9)                 # flag pole
    with a.part(8):
        a.sil(c_rpoly([(212, 74), (270, 96), (212, 118)], [0, 8, 0]), YEL2)
    with a.part():                                    # upper cabin
        a.sil(c_rect(176, 150, 176, 100, 22), WHITE)
    c_glass(a, c_rect(200, 170, 52, 34, 10), glint=(212, 178, 16))
    c_glass(a, c_rect(274, 170, 52, 34, 10))
    with a.part():                                    # lower cabin
        a.sil(c_rect(112, 222, 300, 96, 24), WHITE)
        a.blob("M112 284 L412 284 L412 300 L112 300 Z", "#e6edf3")
    for x in (176, 242, 308):
        c_glass(a, c_circ(x, 256, 17))
    with a.part():                                    # hull
        a.sil("M50 284 L462 284 Q482 284 478 302 C466 356 424 392 366 392 L146 392 C88 392 46 356 34 302 "
              "Q30 284 50 284 Z", BLUE)
        a.blob("M39 310 L473 310 C471 316 469 322 467 327 L45 327 C43 322 41 316 39 310 Z", WHITE)
        a.blob("M60 348 L452 348 C430 376 400 391 366 391 L146 391 C112 391 82 376 60 348 Z", BLUE_D)
    a.shine("M70 297 L230 297", sw=6)
    c_waves(a, 398, 28, 484, 5)
    return a


@word
def densha():
    a = Art()
    BODY, BODY_D, DOOR = "#fbf7ee", "#e6dfd0", "#ece5d6"
    with a.part():                                    # wheels (behind the body)
        for x in (124, 180, 332, 388):
            a.sil(c_circ(x, 384, 25), GREY)
    a.path("M262 126 L296 86 L330 126 M270 84 L322 84", sw=9)      # pantograph
    with a.part(8):
        a.sil(c_rect(258, 112, 76, 20, 6), "#8a949a")
    with a.part():
        a.sil(c_rpoly([(58, 126), (454, 126), (454, 378), (58, 378)], [70, 30, 26, 26]), BODY)
        a.blob("M59 288 L453 288 L453 318 L59 318 Z", "#8cc63f")
        a.blob(c_rpoly([(59, 346), (453, 346), (453, 377), (59, 377)], [0, 0, 25, 25]), BODY_D)
        a.blob(c_rect(160, 150, 62, 210, 8), DOOR)
        a.blob("M160 288 L222 288 L222 318 L160 318 Z", "#7ab536")
    c_glass(a, c_rpoly([(82, 158), (140, 158), (140, 258), (82, 258)], [34, 10, 10, 10]), glint=(98, 190, 24))
    c_glass(a, c_rect(170, 166, 42, 86, 8), ow=5)
    c_line(a, 191, 262, 191, 358, 6, s=0.6, e=0.6)
    c_glass(a, c_rect(240, 158, 82, 84, 12), glint=(256, 172, 22))
    c_glass(a, c_rect(342, 158, 82, 84, 12))
    c_lamp(a, 92, 346, 12, 11)
    a.shine("M118 142 L236 142")
    return a


@word
def shinkansen():
    a = Art()
    STRIPE = "#2a62b8"
    with a.part():
        for x in (150, 202, 376, 428):
            a.sil(c_circ(x, 364, 17), GREY)
    with a.part():
        a.sil("M36 334 C36 306 86 258 150 224 C206 194 262 172 330 172 L450 172 Q478 172 478 200 L478 336 "
              "Q478 364 450 364 L70 364 C48 364 36 352 36 334 Z", WHITE)
        a.blob("M39 342 L477 342 Q477 363 450 363 L70 363 C52 363 41 354 39 342 Z", "#dfe6ee")
        a.blob("M58 332 C130 306 204 294 280 294 L477 294 L477 318 L280 318 C204 318 130 324 58 332 Z", STRIPE)
    c_glass(a, "M170 240 C204 220 244 206 284 204 Q292 204 291 212 L288 236 Q287 244 278 244 C244 246 212 254 178 266 "
               "Q164 270 164 256 Q164 246 170 240 Z", col=NAVY)
    a.path("M190 244 C212 232 238 224 262 220", stroke=WHITE, sw=6, **{"stroke-opacity": "0.55"})
    for x in (318, 372, 426):
        c_glass(a, c_rect(x, 212, 36, 36, 10), ow=5)
    c_lamp(a, 92, 308, 13, 8, ow=5)
    a.shine("M140 244 C190 212 250 190 320 186")
    return a


@word
def jitensha():
    a = Art()
    FR, FR_D, STEEL_ = GREEN, "#5fa64f", "#b9c0c6"
    R, F, BB, S, H1, H2 = (130, 346), (386, 346), (246, 346), (212, 222), (334, 214), (344, 252)
    for cx, cy in (R, F):
        for i in range(8):                                         # spokes
            import math
            t = math.pi * i / 4 + 0.39
            a.line(cx, cy, cx + 68 * math.cos(t), cy + 68 * math.sin(t), sw=4, stroke="#c4bab2")
        with a.part():
            a.sil(c_circ(cx, cy, 84) + " " + c_circ(cx, cy, 69, ccw=True), GREY)
    with a.part():                                    # seat post, saddle
        a.sil(c_bar(S[0], S[1], 206, 196, 10), STEEL_)
    with a.part():
        a.sil("M168 188 C168 172 206 172 232 178 C248 182 250 196 238 200 C214 206 180 206 168 196 Z", "#6b4a2e")
    with a.part():                                    # stem and handlebar
        a.sil(c_bar(H1[0], H1[1], 326, 174, 10), STEEL_)
        a.sil(c_bar(300, 168, 340, 172, 10), STEEL_)
    with a.part():
        a.sil(c_bar(290, 166, 306, 168, 14), GREY)
    with a.part():                                    # frame: every tube in one part
        for p, q in ((R, BB), (R, S), (S, BB), (S, H1), (BB, H2), (H1, H2), (H2, F)):
            a.sil(c_bar(p[0], p[1], q[0], q[1], 15), FR)
    with a.part():                                    # basket
        a.sil(c_rpoly([(350, 158), (450, 158), (440, 232), (360, 232)], [10, 10, 16, 16]), YEL2)
        a.blob(c_rpoly([(354, 214), (446, 214), (440, 231), (360, 231)], [0, 0, 14, 14]), "#e9b43a")
    for x in (383, 417):
        c_line(a, x, 164, x, 226, 5, col="#d9a62a")
    c_line(a, 356, 188, 444, 188, 5, col="#d9a62a")
    with a.part(7):                                   # chain wheel, crank, pedal
        a.sil(c_circ(BB[0], BB[1], 21), HUB)
    a.dot(BB[0], BB[1], 7, "#a39a93")
    with a.part(7):
        a.sil(c_bar(BB[0], BB[1], 262, 384, 7), STEEL_)
    with a.part(7):
        a.sil(c_rect(244, 380, 44, 14, 6), GREY)
    for cx, cy in (R, F):
        with a.part(6):
            a.sil(c_circ(cx, cy, 11), HUB)
    return a


# --------------------------------------------------------------- clothes ---
# --- batch E2 helpers begin ---
# きるもの・あそぶもの・からだ の絵で使う小さな部品（新しい描き方。part()/sil()/ink()）。
def e2_f(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


def e2_rr(x, y, w, h, r):
    """A rounded rectangle as a path (for sil())."""
    k = r * 0.45
    p = [("M", x + r, y), ("L", x + w - r, y), ("C", x + w - k, y, x + w, y + k, x + w, y + r),
         ("L", x + w, y + h - r), ("C", x + w, y + h - k, x + w - k, y + h, x + w - r, y + h),
         ("L", x + r, y + h), ("C", x + k, y + h, x, y + h - k, x, y + h - r),
         ("L", x, y + r), ("C", x, y + k, x + k, y, x + r, y)]
    return " ".join(c[0] + " ".join(e2_f(v) for v in c[1:]) for c in p) + " Z"


def e2_poly(pts):
    return "M" + " L".join(f"{e2_f(x)} {e2_f(y)}" for x, y in pts) + " Z"


def e2_seg(x0, y0, x1, y1):
    """A straight line as a cubic (for ink() and taper())."""
    return (x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)


def e2_cap(x0, y0, x1, y1, w0, w1=None):
    """A bar with a round end at both sides (sticks, fingers, rails). Width w0 at the start, w1 at the end."""
    import math
    w1 = w0 if w1 is None else w1
    ang = math.atan2(y1 - y0, x1 - x0)
    pts = []
    for j in range(13):
        t = ang + math.pi / 2 + math.pi * j / 12
        pts.append((x0 + w0 / 2 * math.cos(t), y0 + w0 / 2 * math.sin(t)))
    for j in range(13):
        t = ang - math.pi / 2 + math.pi * j / 12
        pts.append((x1 + w1 / 2 * math.cos(t), y1 + w1 / 2 * math.sin(t)))
    return e2_poly(pts)


def e2_line(a, x0, y0, x1, y1, w=8, s=1, e=1, col=O):
    a.ink([e2_seg(x0, y0, x1, y1)], w, a=s, b=e, col=col)


def e2_ink2(a, cubics, w=8, s=0, e=0, cx=256, col=O):
    """The same inner line on both sides (mirror around x = cx)."""
    a.ink(cubics, w, a=s, b=e, col=col)
    a.ink([tuple((2 * cx - v) if i % 2 == 0 else v for i, v in enumerate(c)) for c in cubics], w, a=s, b=e, col=col)


def e2_star(cx, cy, ro, ri, rot=-90):
    import math
    pts = []
    for i in range(10):
        r = ro if i % 2 == 0 else ri
        t = math.radians(rot) + i * math.pi / 5
        pts.append((cx + r * math.cos(t), cy + r * math.sin(t)))
    return e2_poly(pts)


def e2_blossom(a, cx, cy, R, col="#ffd1dc", mid=YEL2, rot=-90):
    """A five-petal flower, fill only (pattern on cloth)."""
    import math
    for i in range(5):
        t = math.radians(rot) + i * 2 * math.pi / 5
        ux, uy = math.cos(t), math.sin(t)
        vx, vy = -uy, ux
        P = lambda u, v: f"{e2_f(cx + R * (u * ux + v * vx))} {e2_f(cy + R * (u * uy + v * vy))}"
        a.blob(f"M{P(0, 0)} C{P(0.2, 0.62)} {P(1.0, 0.56)} {P(1.0, 0)} C{P(1.0, -0.56)} {P(0.2, -0.62)} {P(0, 0)} Z", col)
    a.dot(cx, cy, R * 0.26, mid)


def e2_note(a, x, y, s=1.0, col="#7a6fe0"):
    """A music note with its own outline (head centre at x, y)."""
    with a.part(ow=8 * s):
        a.sil_ellipse(x, y, 21 * s, 16 * s, col)
        a.sil(e2_rr(x + 12 * s, y - 78 * s, 9 * s, 78 * s, 3 * s), col)
        a.sil(f"M{e2_f(x + 14 * s)} {e2_f(y - 78 * s)} C{e2_f(x + 34 * s)} {e2_f(y - 70 * s)} {e2_f(x + 58 * s)} {e2_f(y - 62 * s)} "
              f"{e2_f(x + 54 * s)} {e2_f(y - 34 * s)} C{e2_f(x + 46 * s)} {e2_f(y - 50 * s)} {e2_f(x + 30 * s)} {e2_f(y - 54 * s)} "
              f"{e2_f(x + 14 * s)} {e2_f(y - 58 * s)} Z", col)


def e2_smile(a, cx, y, w=14, sw=7):
    a.path(f"M{cx - w} {y} C{cx - w / 2} {y + w * 0.75} {cx + w / 2} {y + w * 0.75} {cx + w} {y}", sw=sw)


def e2_face(a, cx, cy, gap, r=15, cheek_dx=None, cheek_dy=None, w=13):
    """Front face of the body words and the doll: same-size eyes, cheeks, a small smile."""
    a.eye(cx - gap, cy, r)
    a.eye(cx + gap, cy, r)
    dx = cheek_dx or gap + r * 1.7
    dy = cheek_dy or r * 2.3
    a.cheek(cx - dx, cy + dy, r * 1.05, r * 0.62)
    a.cheek(cx + dx, cy + dy, r * 1.05, r * 0.62)
    e2_smile(a, cx, cy + r * 1.9, w)


def e2_collar(a, col, inside, edge=None, x=256, y=90, obi=252):
    """The crossed collar of a yukata / kimono laid flat (the viewer's right side is on top, like a 'y')."""
    k = 0.432
    a.blob(e2_poly([(x - 20, y), (x + 20, y), (x + 1, y + 46)]), inside)          # the inside of the back
    a.blob(e2_poly([(x - 52, y), (x - 18, y), (x + 12, y + 70), (x - 6, y + 106)]), col)   # under
    e2_line(a, x - 52, y, x - 16, y + 83, 7)
    e2_line(a, x - 18, y, x + 1, y + 44, 7)
    h = obi - y
    a.blob(e2_poly([(x + 54, y), (x + 20, y), (x + 20 - k * h, obi), (x + 54 - k * h, obi)]), col)  # over
    if edge:
        a.blob(e2_poly([(x + 31, y), (x + 20, y), (x + 20 - k * h, obi), (x + 31 - k * h, obi)]), edge)
    e2_line(a, x + 54, y, x + 54 - k * h, obi, 7)
    e2_line(a, x + 20, y, x + 20 - k * h, obi, 7)
# --- batch E2 helpers end ---


@word
def kutsu():
    a = Art()
    UP = ("M70 404 C50 356 84 316 138 314 C176 312 204 294 222 262 C228 250 240 242 254 240 "
          "L326 234 C352 232 368 254 368 290 L372 404 Z")

    def shoe(s, upper, shade, strap):
        with s.part():                                  # lining and heel loop (behind the upper)
            s.sil("M238 252 C236 224 262 210 292 210 C322 210 346 222 346 246 Z", "#9fd3f2")
            s.sil(taper([(336, 252, 336, 206, 380, 206, 380, 256)], 15, 15, cap=False), strap)
        with s.part():                                  # upper with the white toe cap
            s.sil(UP, upper)
            s.blob("M70 404 C50 356 84 316 138 314 C124 346 126 380 142 404 Z", WHITE)
            s.blob("M142 400 C220 374 300 370 371 378 L372 404 L142 404 Z", shade)
            s.ink([(138, 314, 124, 346, 126, 380, 142, 404)], 8, a=1, b=1)
        with s.part(ow=9):                              # two straps
            s.sil("M152 310 L192 298 L224 384 L188 396 Z", strap)
            s.sil("M206 288 L238 262 L280 352 L246 372 Z", strap)
        with s.part():                                  # sole
            s.sil(e2_rr(46, 398, 332, 46, 22), WHITE)
            s.blob(e2_rr(70, 417, 284, 9, 4), RED)

    shoe(a, BLUE_D, "#3585bd", "#e9b93a")
    front = Art()
    shoe(front, BLUE, BLUE_D, YEL2)
    place(a, front, -100, 42)
    a.shine("M202 330 C204 320 208 312 216 306")
    return a


@word
def fuku():
    a = Art()
    OR, OR_D, COL = "#f39a4a", "#df8236", "#fbc98a"
    with a.part():
        a.sil("M182 96 C202 126 310 126 330 96 L420 136 C434 143 438 154 433 168 L412 228 C407 242 394 246 383 239 "
              "L360 226 C358 290 360 360 362 420 C362 436 352 446 334 446 C290 450 222 450 178 446 "
              "C160 446 150 436 150 420 C152 360 154 290 152 226 L129 239 C118 246 105 242 100 228 "
              "L79 168 C74 154 78 143 92 136 Z", OR)
        a.blob("M151 396 C200 410 312 410 361 396 L362 420 C362 436 352 446 334 446 C290 450 222 450 178 446 "
               "C160 446 150 436 150 420 Z", OR_D)
        for d in ("M100 228 C105 242 118 246 129 239 L152 226 L152 210 L124 222 C114 226 104 222 98 214 Z",):
            a.blob(d, OR_D)
            a.blob(mirror(d), OR_D)
        a.blob("M182 96 C202 126 310 126 330 96 L348 104 C322 152 190 152 164 104 Z", COL)
        a.ink([(164, 104, 190, 152, 322, 152, 348, 104)], 7, a=1, b=1)
        e2_ink2(a, [e2_seg(110, 128, 143, 232)], 7, 1, 1)
        e2_ink2(a, [(152, 228, 154, 210, 160, 196, 172, 184)], 8, 1, 0)
    st = e2_star(256, 304, 54, 26)
    a.path(st, fill=YEL, stroke=YEL, sw=12)
    a.shine("M178 262 C176 296 176 330 178 360")
    return a


@word
def boushi():
    a = Art()
    BRIM, BRIM_D, CROWN_D = "#f9d867", "#e9bd3c", "#e9b62e"
    with a.part():
        a.sil_ellipse(256, 316, 200, 58, BRIM)
        a.blob("M126 318 C170 344 342 344 386 318 C380 350 320 362 256 362 C192 362 132 350 126 318 Z", BRIM_D)
    a.sil_ellipse(256, 120, 17, 13, RED)
    with a.part():
        a.sil("M136 306 C132 186 186 118 256 118 C326 118 380 186 376 306 C332 328 180 328 136 306 Z", YEL2)
        a.blob("M318 136 C362 170 380 232 376 306 C364 312 350 316 336 319 C344 250 344 186 318 136 Z", CROWN_D)
        a.blob("M137 266 C186 288 326 288 375 266 L376 306 C332 328 180 328 136 306 Z", RED)
        a.blob("M338 276 C352 273 364 270 375 266 L376 306 C364 312 350 316 336 319 Z", RED_D)
        a.ink([(137, 266, 186, 288, 326, 288, 375, 266)], 7, a=1, b=1)
    a.shine("M176 236 C176 198 192 168 216 150")
    return a


def sakura_dot(a, cx, cy, r=9, col="#ffd1dc"):
    import math
    for i in range(5):
        t = -math.pi / 2 + i * 2 * math.pi / 5
        a.dot(cx + r * math.cos(t), cy + r * math.sin(t), r * 0.75, col)
    a.dot(cx, cy, r * 0.4, YEL2)


GARMENT = ("M196 92 L316 92 L452 122 C462 124 466 132 466 142 L466 250 C466 262 458 268 446 268 L362 268 "
           "L362 462 C362 472 354 478 344 478 L168 478 C158 478 150 472 150 462 L150 268 L66 268 "
           "C54 268 46 262 46 250 L46 142 C46 132 50 124 60 122 Z")


@word
def yukata():
    a = Art()
    NAVY_D, OBI, OBI_D = "#293f66", "#f7a8b3", "#ee8a9c"
    with a.part():
        a.sil("M200 90 L312 90 L446 120 C460 123 466 132 466 146 L466 238 C466 258 454 270 434 270 L362 270 "
              "L364 456 C364 470 356 478 342 478 L170 478 C156 478 148 470 148 456 L150 270 L78 270 "
              "C58 270 46 258 46 238 L46 146 C46 132 52 123 66 120 Z", NAVY)
        a.blob("M148 440 L364 440 L364 456 C364 470 356 478 342 478 L170 478 C156 478 148 470 148 456 Z", NAVY_D)
        for d in ("M46 226 L150 250 L150 270 L78 270 C58 270 46 258 46 238 Z",):
            a.blob(d, NAVY_D)
            a.blob(mirror(d), NAVY_D)
        for x, y in ((92, 164), (136, 222), (420, 164), (376, 222), (178, 150), (334, 152), (188, 356), (318, 346),
                     (262, 410), (322, 436), (192, 432)):
            a.circle(x, y, 11, "none", stroke=WHITE, sw=6)
        e2_ink2(a, [e2_seg(150, 270, 150, 214)], 8, 1, 0)
        e2_line(a, 228, 300, 214, 478, 7)
        e2_collar(a, "#9fd3f2", NAVY_D)
    with a.part():                                      # obi
        a.sil(e2_rr(146, 252, 220, 52, 8), OBI)
        a.blob("M146 286 L366 286 L366 296 C366 300 362 304 358 304 L154 304 C150 304 146 300 146 296 Z", OBI_D)
    with a.part(ow=9):                                  # bow
        for d in ("M300 278 C268 240 212 248 214 280 C216 310 266 312 300 278 Z",
                  "M300 278 C332 240 388 248 386 280 C384 310 334 312 300 278 Z",
                  "M300 278 C320 306 334 346 326 386 C306 368 294 318 300 278 Z",
                  "M300 278 C282 306 264 340 270 376 C292 364 302 316 300 278 Z"):
            a.sil(d, OBI)
        a.ink([(286, 278, 268, 270, 250, 270, 236, 276)], 6, a=1, b=0)
        a.ink([(314, 278, 332, 270, 350, 270, 364, 276)], 6, a=1, b=0)
    a.sil_ellipse(300, 278, 15, 14, OBI_D)
    a.shine("M72 152 L72 214")
    return a


@word
def kimono():
    a = Art()
    K, K_D = "#e5534b", "#c9403a"
    SL = "M158 118 L66 118 C52 118 46 128 46 142 L46 356 C46 390 70 410 104 410 L158 410 Z"
    with a.part():                                      # long sleeves
        for d in (SL, mirror(SL)):
            a.sil(d, K)
        for d in ("M46 340 C60 372 100 384 158 384 L158 410 L104 410 C70 410 46 390 46 356 Z",):
            a.blob(d, K_D)
            a.blob(mirror(d), K_D)
        for x, y, r in ((92, 176, 17), (112, 268, 19), (84, 344, 15), (420, 176, 17), (400, 268, 19), (428, 344, 15)):
            e2_blossom(a, x, y, r)
        for x, y in ((74, 250), (122, 330), (438, 250), (390, 330)):
            a.dot(x, y, 7, YEL2)
    with a.part():                                      # body
        a.sil("M200 90 L312 90 L362 112 L364 456 C364 470 356 478 342 478 L170 478 C156 478 148 470 148 456 "
              "L150 112 Z", K)
        a.blob("M148 440 L364 440 L364 456 C364 470 356 478 342 478 L170 478 C156 478 148 470 148 456 Z", K_D)
        for x, y, r in ((188, 364, 17), (316, 384, 19), (262, 432, 15), (180, 180, 14), (334, 180, 14)):
            e2_blossom(a, x, y, r)
        for x, y in ((286, 348), (196, 420), (332, 440)):
            a.dot(x, y, 7, YEL2)
        e2_line(a, 228, 308, 214, 478, 7)
        e2_collar(a, WHITE, K_D, edge=K, obi=246)
    with a.part():                                      # obi
        a.sil(e2_rr(146, 244, 220, 66, 8), YEL2)
        a.blob("M146 252 C146 248 150 244 154 244 L358 244 C362 244 366 248 366 252 L366 258 L146 258 Z", "#f7a8b3")
        for x in (176, 216, 256, 296, 336):
            a.blob(f"M{x} 266 L{x + 13} 279 L{x} 292 L{x - 13} 279 Z", "#f6a04d")
        a.blob("M146 275 L366 275 L366 284 L146 284 Z", "#6cb6e8")
        a.blob("M146 298 L366 298 L366 302 C366 306 362 310 358 310 L154 310 C150 310 146 306 146 302 Z", "#e9b93a")
    a.sil_ellipse(256, 279, 15, 12, WHITE)
    a.shine("M70 146 L70 220")
    return a


@word
def kutsushita():
    a = Art()
    LEG = ("M200 104 L300 104 L300 296 C300 362 262 404 202 404 L120 404 C82 404 58 384 58 354 "
           "C58 322 82 300 120 300 L186 300 C196 300 200 294 200 284 Z")

    def sock(s, col, acc, cuff):
        with s.part():
            s.sil(LEG, col)
            s.blob("M120 300 C82 300 58 322 58 354 C58 384 82 404 120 404 C134 380 134 324 120 300 Z", acc)
            s.blob("M300 316 C298 368 264 404 212 404 C222 378 246 362 270 350 C286 342 296 332 300 316 Z", acc)
            s.blob(e2_poly([(200, 168), (300, 168), (300, 190), (200, 190)]), WHITE)
            s.blob(e2_poly([(200, 218), (300, 218), (300, 240), (200, 240)]), WHITE)
        with s.part():
            s.sil(e2_rr(188, 70, 124, 52, 16), cuff)
            for x in (220, 250, 280):
                e2_line(s, x, 84, x, 108, 7, 0.7, 0.7, col="#dcd5c8")

    sock(a, "#e2738b", "#e9b93a", "#f1ece2")
    front = Art()
    sock(front, "#f08aa0", YEL2, WHITE)
    place(a, front, -130, 40)
    a.shine("M86 300 L86 330")
    return a


# ------------------------------------------------------- more animals ------
@word
def saru():
    a = Art()
    BR, BRD, LT, MZ = "#b9794a", "#9c6238", "#f6dcb8", "#f0c291"
    tail = [(346, 428, 428, 442, 470, 392, 452, 330), (452, 330, 442, 292, 474, 268, 496, 292)]
    a.sil(taper(tail, 30, 22), BR)
    FOOT = "M126 376 C156 368 186 390 190 424 C194 456 172 474 140 472 C108 470 88 450 90 420 C92 398 106 382 126 376 Z"
    with a.part():
        a.sil("M256 236 C292 236 320 250 336 282 C354 316 368 366 366 402 C362 444 322 460 256 460 "
              "C190 460 150 444 146 402 C144 366 158 316 176 282 C192 250 220 236 256 236 Z", BR)
        sym(a, FOOT, BR, 256)
        a.blob("M256 286 C292 286 310 322 310 362 C310 408 292 436 256 436 C220 436 202 408 202 362 C202 322 220 286 256 286 Z", LT)
        for s in (-1, 1):
            a.ellipse(256 + s * 116, 426, 28, 31, LT, sw=0, stroke="none")
        a.ink([(186, 394, 172, 378, 146, 370, 124, 378)], 9, a=0, b=1)
        a.ink([(326, 394, 340, 378, 366, 370, 388, 378)], 9, a=0, b=1)
    with a.part():
        arm = taper([(200, 232, 162, 280, 150, 336, 158, 388)], 50, 42)
        sym(a, arm, BR, 256)
        for s in (-1, 1):
            a.ellipse(256 - s * 98, 390, 16, 15, LT, sw=0, stroke="none")
    cx = 256
    HEADP = "M256 60 C328 60 364 104 364 156 C364 214 318 244 256 244 C194 244 148 214 148 156 C148 104 184 60 256 60 Z"
    with a.part():
        a_ear_round(a, cx, 112, 160, 32, BR, LT, HEADP, ir=0.55, shift_in=-4)
    a.blob("M256 108 C286 84 336 102 336 148 C336 168 330 178 331 194 C332 216 300 232 256 232 "
           "C212 232 180 216 181 194 C182 178 176 168 176 148 C176 102 226 84 256 108 Z", LT)
    a.ellipse(cx, 202, 40, 24, MZ, sw=0, stroke="none")
    a.dot(248, 196, 3.5, O)
    a.dot(264, 196, 3.5, O)
    a.path("M236 210 C248 222 264 222 276 210", sw=7)
    a_face(a, cx, 160, 38, 16, cheek=(64, 196, 15, 9))
    a.shine("M178 110 C190 92 208 80 228 76")
    return a


# ---- the animals below: side / 3-4 view, smooth bezier outlines, real legs (D175) ----
# ---- pilot animals begin (fills first, outline by part(); see lib.Art.part) ----
from lib import limb, taper, smooth, at, bez_pts, limb_d


def hoofed(a, joints, widths, yg, fill, hoof, d=-1, hh=22):
    """A leg that ends in a hoof (inside a part): leg in `fill`, the last hh px in the hoof colour."""
    a.sil(limb_d(joints, widths, yg - 3, d, foot=3, h=hh), fill)
    x, w = joints[-1][0], widths[-1]
    l, r = x - w / 2 - 3, x + w / 2 + 3
    a.sil(f"M{l + 2} {yg - hh} L{r - 2} {yg - hh} C{r + 3} {yg - hh * 0.4} {r + 3} {yg - 4} {r - 3} {yg} "
          f"L{l + 3} {yg} C{l - 3} {yg - 4} {l - 3} {yg - hh * 0.4} {l + 2} {yg - hh} Z", hoof)


def band(a, cubics, t0, t1, w0, w1, col):
    """A stripe across a taper()-shaped tail or trunk, between fractions t0 and t1 of its length."""
    pts = []
    for t, sgn in ((t0, -1), (t0, 1), (t1, 1), (t1, -1)):
        pts.append(at(cubics, t, sgn * (w0 + (w1 - w0) * t) / 2))
    m0, m1 = at(cubics, t0, 0), at(cubics, t1, 0)
    (p0, p1, p2, p3) = pts
    a.blob(f"M{p0[0]:.1f} {p0[1]:.1f} L{p1[0]:.1f} {p1[1]:.1f} L{p2[0]:.1f} {p2[1]:.1f} L{p3[0]:.1f} {p3[1]:.1f} Z", col)


def sym(a, d, fill, cx, sil=True):
    """The same shape on both sides of the face (mirror around x = cx)."""
    for q in (d, mirror(d, cx)):
        (a.sil if sil else a.blob)(q, fill)


def toes(a, x, yg, d=-1, gap=11, h=11):
    """Two short toe notches on a paw (never more)."""
    for k in (0, 1):
        xx = x + d * (4 + k * gap)
        a.ink([(xx, yg + 1, xx, yg - h * 0.4, xx + d * 1, yg - h * 0.8, xx + d * 2, yg - h)], 6, a=1, b=0)


@word
def kuma():
    a = Art()
    BR, BRD, LT = "#b07a4f", "#966540", "#f2d2a9"
    with a.part():
        # torso with round shoulders; both arms start inside the shoulder mass
        a.sil("M256 238 C300 238 340 246 362 272 C388 304 392 350 386 396 C380 440 328 460 256 460 "
              "C184 460 132 440 126 396 C120 350 124 304 150 272 C172 246 212 238 256 238 Z", BR)
        a.sil(taper([(336, 304, 372, 300, 404, 262, 414, 206)], 76, 54), BR)
        a.sil(taper([(188, 296, 150, 318, 136, 356, 146, 392)], 70, 52), BR)
        # feet, soles to the viewer
        a.sil("M112 372 C142 364 176 386 180 422 C184 456 160 474 128 472 C96 470 74 450 76 418 C78 394 92 378 112 372 Z", BR)
        a.sil("M400 372 C370 364 336 386 332 422 C328 456 352 474 384 472 C416 470 438 450 436 418 C434 394 420 378 400 372 Z", BR)
        a.blob("M256 286 C304 286 326 326 326 368 C326 414 300 440 256 440 C212 440 186 414 186 368 C186 326 208 286 256 286 Z", LT)
        a.blob("M186 404 C200 436 226 448 256 448 C286 448 312 436 326 404 C330 430 322 452 256 456 C190 452 182 430 186 404 Z", BRD)
        for s_ in (-1, 1):
            a.ellipse(256 + s_ * 128, 424, 30, 33, LT, sw=0, stroke="none")
        a.ink([(176, 392, 160, 374, 132, 366, 110, 374)], 9, a=0, b=1)
        a.ink([(336, 392, 352, 374, 380, 366, 402, 374)], 9, a=0, b=1)
        a.ink([(166, 404, 182, 378, 184, 344, 174, 316)], 9, a=0.5, b=0)
        a.ink([(388, 318, 372, 330, 356, 334, 342, 330)], 8, a=1, b=0)
        a.ellipse(413, 208, 16, 15, LT, sw=0, stroke="none")
    with a.part():
        for x in (176, 336):
            a.sil_ellipse(x, 96, 36, 35, BR)
        a.sil("M256 62 C330 62 366 106 366 160 C366 218 318 246 256 246 C194 246 146 218 146 160 C146 106 182 62 256 62 Z", BR)
        for x in (176, 336):
            a.ellipse(x + (4 if x < 256 else -4), 98, 19, 18, LT, sw=0, stroke="none")
        a.blob("M256 62 C330 62 366 106 366 160 C366 218 318 246 256 246 C194 246 146 218 146 160 C146 106 182 62 256 62 Z", BR)
    a.ellipse(256, 204, 50, 37, LT, sw=0, stroke="none")
    a.path("M240 186 C240 176 272 176 272 186 C272 197 260 203 256 203 C252 203 240 197 240 186 Z", fill=EYE, sw=0, stroke="none")
    a.dot(250, 182, 4.5, WHITE)
    a.path("M256 203 L256 214 M256 214 C250 225 238 225 234 216 M256 214 C262 225 274 225 278 216", sw=7)
    a.eye(208, 150, 17)
    a.eye(304, 150, 17)
    a.cheek(182, 196, 17, 10)
    a.cheek(330, 196, 17, 10)
    a.shine("M186 118 C196 100 212 90 230 86")
    return a


@word
def inu():
    a = Art()
    TAN, TAN_D, EAR, EAR_D = "#f2c48d", "#d9a56c", "#b8794a", "#9a6238"
    G = 450
    with a.part():
        a.sil(limb_d([(300, 330), (306, 388), (310, 434)], [50, 38, 30], G, foot=10, h=18), TAN_D)
        a.sil(limb_d([(396, 330), (382, 374), (400, 408), (396, 434)], [48, 38, 28, 27], G, foot=10, h=18), TAN_D)
    with a.part():
        a.sil(taper([(452, 290, 500, 292, 522, 262, 524, 220)], 36, 22), TAN)
        a.sil("M214 262 C260 228 380 224 436 246 C482 264 490 324 462 358 C440 382 380 374 330 378 "
              "C280 382 236 392 212 356 C196 326 198 284 214 262 Z", TAN)
        a.sil(limb_d([(246, 300), (246, 384), (244, 432)], [76, 46, 36], G, foot=12, h=20), TAN)
        a.sil(limb_d([(438, 300), (428, 366), (450, 406), (446, 432)], [96, 58, 34, 32], G, foot=14, h=20), TAN)
        a.blob("M290 378 C330 380 380 378 404 376 C398 366 396 360 396 352 C360 362 320 362 290 358 Z", TAN_D)
        a.blob("M318 240 C350 232 384 238 394 256 C378 278 334 272 318 258 Z", EAR)
        a.ink([(402, 384, 392, 352, 400, 316, 430, 294)], 9, a=1, b=0)
        a.ink([(274, 386, 282, 362, 280, 340, 270, 320)], 8, a=1, b=0)
        toes(a, 226, G)
        toes(a, 428, G)
        a.shine("M424 280 C440 274 456 282 462 298", sw=7)
    cx = 190
    a.tube("M140 276 C160 306 220 306 240 276", RED, 26, 14)
    a.circle(cx, 306, 12, YEL2, sw=8)
    a.sil("M190 104 C254 104 286 146 286 196 C286 252 244 286 190 286 C136 286 94 252 94 196 C94 146 126 104 190 104 Z", TAN)
    a.ellipse(cx, 238, 46, 36, CREAM, sw=0, stroke="none")
    with a.part():
        sym(a, "M136 116 C100 100 62 124 62 176 C62 218 86 242 106 228 C122 214 116 168 144 138 Z", EAR, cx)
    a.path("M174 220 C174 210 206 210 206 220 C206 231 194 237 190 237 C186 237 174 231 174 220 Z", fill=EYE, sw=0, stroke="none")
    a.dot(184, 216, 4.5, WHITE)
    a.path("M190 237 L190 246 M190 246 C184 258 170 258 166 248 M190 246 C196 258 210 258 214 248", sw=7)
    a.path("M181 256 C181 272 199 272 199 256 Z", fill="#f28a9b", sw=6)
    a.eye(cx - 44, 192, 17)
    a.eye(cx + 44, 192, 17)
    a.cheek(cx - 68, 230, 16, 10)
    a.cheek(cx + 68, 230, 16, 10)
    a.shine("M130 150 C142 132 160 122 180 118")
    return a


@word
def ushi():
    a = Art()
    BLK, HOOF, LEG, SH = "#3b2f2a", "#7a5c4a", "#e8e0d4", "#ebe3d8"
    G = 450
    with a.part():
        hoofed(a, [(304, 330), (312, 390), (316, 432)], [60, 44, 36], G, LEG, HOOF)
        hoofed(a, [(404, 330), (388, 376), (406, 404), (400, 432)], [56, 46, 36, 34], G, LEG, HOOF)
        a.sil("M346 362 C336 400 376 414 392 392 C406 414 432 402 420 362 Z", PINK)
    with a.part():
        a.sil(taper([(488, 244, 544, 250, 556, 320, 540, 368)], 20, 12), WHITE)
        a.sil("M540 358 C520 372 520 404 538 418 C558 404 558 372 540 358 Z", BLK)
        a.sil("M222 240 C262 212 400 206 454 226 C498 242 508 300 498 346 C492 378 466 386 436 386 "
              "L262 386 C226 386 202 360 200 322 C198 286 204 256 222 240 Z", WHITE)
        hoofed(a, [(254, 310), (256, 392), (256, 432)], [84, 52, 42], G, WHITE, HOOF)
        hoofed(a, [(448, 300), (440, 372), (458, 404), (452, 432)], [104, 62, 42, 38], G, WHITE, HOOF)
        a.blob("M292 386 L414 386 C408 376 406 368 406 360 C366 370 330 370 296 364 Z", SH)
        a.blob("M306 222 C346 212 396 216 406 240 C400 276 346 286 322 266 C304 252 298 234 306 222 Z", BLK)
        a.blob("M444 262 C474 254 496 284 492 320 C484 342 456 338 450 316 C446 298 440 276 444 262 Z", BLK)
        a.ink([(408, 392, 396, 356, 404, 314, 432, 290)], 9, a=1, b=0)
        a.ink([(286, 392, 294, 364, 290, 338, 278, 318)], 8, a=1, b=0)
    cx = 190
    with a.part():
        sym(a, "M150 132 C134 116 132 92 142 82 C158 88 170 108 176 126 Z", "#fff1c9", cx)
    a.tube("M140 288 C160 318 220 318 240 288", RED, 26, 14)
    a.path("M177 322 C177 310 203 310 203 322 L207 344 L173 344 Z", fill=YEL2, sw=8)
    a.dot(cx, 348, 5, O)
    with a.part():
        sym(a, "M118 150 C86 126 50 134 40 156 C60 182 96 184 122 176 Z", WHITE, cx)
        a.sil("M190 112 C244 112 272 146 272 194 C272 226 266 250 252 266 L128 266 C114 250 108 226 108 194 "
              "C108 146 136 112 190 112 Z", WHITE)
        a.sil("M190 222 C234 222 262 240 262 264 C262 290 232 304 190 304 C148 304 118 290 118 264 C118 240 146 222 190 222 Z", PINK)
        sym(a, "M104 154 C86 142 66 146 58 156 C72 170 92 172 108 168 Z", PINK_IN, cx, sil=False)
        a.blob("M214 116 C248 122 268 146 271 180 C248 178 224 156 214 116 Z", BLK)
    for sgn in (-1, 1):
        a.ellipse(cx + sgn * 24, 258, 7, 10, O, sw=0, stroke="none")
    a.path("M170 284 C182 292 198 292 210 284", sw=7)
    a.eye(cx - 42, 188, 17)
    a.eye(cx + 42, 188, 17)
    a.cheek(cx - 62, 222, 15, 9)
    a.cheek(cx + 62, 222, 15, 9)
    a.shine("M130 150 C140 136 154 128 170 124")
    return a.flipped()


@word
def zou():
    a = Art()
    G_, GD, GL = "#a9b7c6", "#8c9db0", "#d3dde8"
    G = 450
    with a.part():
        a.sil(limb_d([(344, 340), (346, 400), (348, 436)], [76, 66, 62], G, foot=6, h=20), GD)
        a.sil(limb_d([(392, 340), (384, 400), (384, 436)], [76, 66, 62], G, foot=6, h=20), GD)
    with a.part():
        a.sil(taper([(492, 258, 528, 290, 534, 340, 526, 384)], 18, 10), G_)
        a.sil("M526 374 C512 384 512 410 526 420 C540 410 540 384 526 374 Z", "#6f7e90")
        a.sil("M236 176 C300 160 410 172 462 212 C504 246 508 318 488 360 C478 386 452 394 420 392 "
              "L270 392 C232 392 208 362 206 320 C204 268 214 204 236 176 Z", G_)
        a.sil(limb_d([(292, 320), (290, 398), (294, 436)], [96, 76, 70], G, foot=6, h=20), G_)
        a.sil(limb_d([(432, 310), (426, 392), (430, 436)], [108, 80, 72], G, foot=6, h=20), G_)
        a.blob("M332 392 L386 392 C382 382 382 372 384 362 C366 368 350 368 334 364 Z", GD)
        a.ink([(388, 398, 380, 362, 388, 322, 412, 298)], 9, a=1, b=0)
        a.ink([(330, 398, 338, 366, 336, 340, 326, 318)], 8, a=1, b=0)
        a.shine("M424 244 C448 248 466 266 470 292", sw=8)
    cx = 200
    ear = "M136 118 C92 70 24 100 26 172 C28 238 84 268 132 240 Z"
    with a.part():
        sym(a, ear, G_, cx)
        sym(a, "M118 136 C90 108 50 124 52 174 C54 220 90 240 120 222 Z", "#e8b9c1", cx, sil=False)
    trunk = [(200, 214, 200, 276, 198, 322, 178, 352), (178, 352, 162, 376, 126, 372, 128, 342)]
    with a.part():
        a.sil(taper(trunk, 62, 28), G_)
        a.sil("M200 88 C262 88 298 134 298 190 C298 246 258 282 200 282 C142 282 102 246 102 190 C102 134 138 88 200 88 Z", G_)
        for t in (0.34, 0.46, 0.58):
            h = (62 - 34 * t) / 2
            (x1, y1), (x2, y2) = at(trunk, t, -h), at(trunk, t, h * 0.2)
            a.ink([(x1, y1, x1 + (x2 - x1) * 0.3, y1 + (y2 - y1) * 0.3 + 4, x1 + (x2 - x1) * 0.7, y1 + (y2 - y1) * 0.7 + 4, x2, y2)], 7, a=1, b=0, col=GD)
    a.eye(cx - 52, 190, 17)
    a.eye(cx + 52, 190, 17)
    a.cheek(cx - 68, 228, 17, 10)
    a.cheek(cx + 68, 228, 17, 10)
    a.shine("M134 150 C146 126 166 110 190 104")
    return a


@word
def kirin():
    a = Art()
    Y, YD, SP, MANE = "#f8cf62", "#e3b448", "#c98a3e", "#a8672f"
    HOOF = "#7a5c4a"
    G = 490
    neck = [(380, 300, 330, 262, 270, 190, 240, 130)]
    with a.part():
        hoofed(a, [(346, 320), (350, 376), (350, 408), (354, 446), (354, 468)], [40, 24, 30, 20, 22], G, YD, HOOF, hh=18)
        hoofed(a, [(428, 320), (416, 372), (420, 404), (412, 446), (412, 468)], [42, 26, 30, 20, 22], G, YD, HOOF, hh=18)
        mane = [at(neck, t, 55 - 33 * t + 9) for t in (0.3, 0.45, 0.6, 0.75, 0.9, 1.0)]
        a.sil(smooth(mane + [at(neck, t, 0) for t in (1.0, 0.6, 0.3)]), MANE)
    with a.part():
        a.sil(taper([(468, 276, 500, 296, 510, 346, 500, 394)], 14, 8), Y)
        a.sil("M500 384 C484 396 484 424 500 434 C516 424 516 396 500 384 Z", HOOF)
        a.sil(taper(neck, 110, 44, cap=False), Y)
        a.sil("M290 262 C326 232 430 236 462 266 C488 292 482 340 452 352 C410 366 330 366 296 350 "
              "C270 332 268 286 290 262 Z", Y)
        hoofed(a, [(312, 310), (306, 376), (300, 408), (294, 446), (292, 468)], [56, 28, 34, 22, 24], G, Y, HOOF, hh=18)
        hoofed(a, [(450, 300), (450, 366), (468, 404), (472, 446), (474, 468)], [70, 34, 34, 22, 24], G, Y, HOOF, hh=18)
        a.blob("M336 362 C366 366 400 364 424 358 C420 350 420 344 422 338 C390 348 360 348 338 344 Z", YD)

        def spot(cx, cy, r, k=0):
            import math
            pts = []
            for i in range(7):
                ang = 0.3 + i * 2 * math.pi / 7
                rr = r * (0.85 + 0.25 * (((i * 7 + k * 3) % 5) / 4))
                pts.append((cx + rr * math.cos(ang), cy + rr * math.sin(ang)))
            a.blob(smooth(pts), SP)
        for cx, cy, r, k in ((340, 290, 19, 1), (400, 292, 21, 2), (368, 332, 13, 3), (440, 326, 14, 4), (306, 318, 11, 5),
                             (276, 186, 12, 1), (300, 222, 14, 2), (258, 156, 8, 3), (322, 250, 10, 4), (452, 284, 9, 2)):
            spot(cx, cy, r, k)
        a.ink([(426, 366, 416, 338, 422, 308, 442, 288)], 8, a=1, b=0)
        a.ink([(334, 366, 340, 346, 338, 328, 330, 312)], 7, a=1, b=0)
    cx = 228
    with a.part():
        for sgn in (-1, 1):
            a.sil(taper([(cx + sgn * 18, 40, cx + sgn * 19, 22, cx + sgn * 21, 6, cx + sgn * 23, -8)], 12, 12), Y)
            a.sil_ellipse(cx + sgn * 23, -12, 10, 9, MANE)
    with a.part():
        sym(a, "M180 62 C158 40 130 40 120 54 C132 74 160 80 182 76 Z", Y, cx)
        a.sil("M228 22 C268 22 288 52 288 86 C288 108 282 124 274 136 C262 154 246 160 228 160 "
              "C210 160 194 154 182 136 C174 124 168 108 168 86 C168 52 188 22 228 22 Z", Y)
        sym(a, "M168 60 C154 50 138 50 132 56 C142 66 156 68 170 66 Z", PINK_IN, cx, sil=False)
        a.blob("M186 122 C200 110 256 110 270 122 C276 132 268 148 256 154 C240 162 216 162 200 154 C188 148 180 132 186 122 Z", CREAM)
        for x, y in ((212, 40), (246, 44), (228, 56)):
            a.ellipse(x, y, 7, 6, SP, sw=0, stroke="none")
    for sgn in (-1, 1):
        a.ellipse(cx + sgn * 14, 128, 4.5, 6, O, sw=0, stroke="none")
    a.path("M212 142 C222 150 234 150 244 142", sw=6)
    a.eye(cx - 34, 88, 15)
    a.eye(cx + 34, 88, 15)
    a.cheek(cx - 44, 112, 12, 7)
    a.cheek(cx + 44, 112, 12, 7)
    return a.flipped()


@word
def neko():
    a = Art()
    OR, OR_D, STR = "#f6b26b", "#e29a50", "#d9843a"
    G = 454
    tail = [(414, 388, 478, 392, 488, 442, 444, 440), (444, 440, 424, 439, 410, 434, 402, 422)]
    with a.part():
        a.sil("M206 240 C292 220 396 262 424 346 C442 404 424 452 370 454 L190 454 "
              "C170 454 168 400 176 360 C184 318 184 270 206 240 Z", OR)
        # two thick front legs side by side, big round paws on the ground (cream socks)
        for x in (196, 252):
            a.sil(f"M{x - 8} 290 L{x + 24} 330 L{x + 23} 416 C{x + 35} 424 {x + 35} 454 {x + 16} 454 "
                  f"L{x - 18} 454 C{x - 37} 454 {x - 37} 424 {x - 23} 416 C{x - 24} 380 {x - 24} 330 {x - 8} 290 Z", OR)
        a.blob("M380 452 C410 444 424 424 428 394 C418 420 400 432 376 436 Z", OR_D)
        a.blob("M204 270 C196 306 198 336 208 362 C226 340 240 310 236 270 Z", CREAM)
        for x in (196, 252):
            a.blob(f"M{x - 24} 420 C{x - 36} 428 {x - 36} 454 {x - 18} 454 L{x + 16} 454 C{x + 34} 454 {x + 34} 428 {x + 24} 420 Z", CREAM)
        # haunch: one round mass; a clear hind paw on the ground in front of it
        a.blob("M302 454 C288 454 286 432 304 424 C326 415 364 419 371 438 C375 448 369 454 359 454 Z", CREAM)
        a.ink([(326, 300, 392, 290, 436, 352, 412, 404)], 9, a=0, b=0)
        a.ink([(293, 455, 281, 430, 312, 414, 342, 418), (342, 418, 366, 422, 380, 440, 371, 455)], 10, a=1, b=1)
        a.ink([(224, 455, 224, 420, 224, 380, 225, 344)], 10, a=1, b=0)
        a.ink([(281, 440, 280, 410, 278, 380, 272, 350)], 10, a=1, b=0)
        toes(a, 184, G + 1, d=1, gap=13, h=11)
        toes(a, 240, G + 1, d=1, gap=13, h=11)
        a.shine("M352 318 C370 312 388 322 396 340", sw=7)
    # tail comes round the haunch and lies in front of it; the patch hides the line at its root
    with a.part():
        a.sil(taper(tail, 36, 28), OR)
        for t in (0.42, 0.6, 0.78):
            band(a, tail, t, t + 0.05, 36, 28, STR)
    a.blob("M398 374 L450 376 L450 404 L398 402 Z", OR)
    a.tube("M152 248 C190 272 240 272 274 244", "#4fa8e0", 26, 14)
    a.circle(212, 276, 11, YEL2, sw=8)
    ear = "M134 144 L130 76 C130 66 140 62 148 68 L202 100 Z"
    inner = "M146 130 L144 92 L180 110 Z"
    HEADP = "M210 92 C266 90 302 126 302 168 C302 218 260 248 210 248 C160 248 118 218 118 168 C118 126 154 94 210 92 Z"
    with a.part():
        for d in (ear, mirror(ear, 210)):
            a.sil(d, OR)
        a.sil(HEADP, OR)
        for d in (inner, mirror(inner, 210)):
            a.blob(d, PINK_IN)
        a.blob(HEADP, OR)
    for d in ([(210, 92, 210, 104, 210, 116, 210, 130)], [(184, 96, 186, 106, 187, 114, 188, 124)], [(236, 96, 234, 106, 233, 114, 232, 124)]):
        a.ink(d, 10, a=1, b=0, col=STR)
    for d in ([(118, 190, 126, 191, 134, 193, 142, 194)], [(119, 214, 127, 213, 135, 211, 142, 210)],
              [(302, 190, 294, 191, 286, 193, 278, 194)], [(301, 214, 293, 213, 285, 211, 278, 210)]):
        a.ink(d, 9, a=1, b=0, col=STR)
    a.ellipse(210, 214, 44, 30, CREAM, sw=0, stroke="none")
    a.path("M198 196 L222 196 L210 210 Z", fill="#f28a9b", sw=6)
    a.path("M210 210 L210 218 M210 218 C204 230 190 230 188 220 M210 218 C216 230 230 230 232 220", sw=7)
    for d in ("M150 206 L96 196", "M150 218 L98 226"):
        a.path(d, sw=6)
        a.path(mirror(d, 210), sw=6)
    a.eye(162, 170, 19)
    a.eye(258, 170, 19)
    a.cheek(146, 214, 15, 9)
    a.cheek(274, 214, 15, 9)
    a.shine("M150 140 C158 124 172 112 190 106")
    return a


# ---- pilot animals end ----


@word
def tora():
    a = Art()
    OR, OR_D, ST = "#f4a340", "#dc8a2e", O
    G = 450
    tail = [(456, 296, 512, 300, 540, 262, 528, 214), (528, 214, 520, 186, 492, 190, 494, 214)]
    with a.part():
        a.sil(limb_d([(302, 330), (308, 388), (312, 434)], [56, 44, 36], G, foot=10, h=18), OR_D)
        a.sil(limb_d([(398, 330), (384, 374), (402, 408), (398, 434)], [54, 44, 34, 32], G, foot=10, h=18), OR_D)
    with a.part():
        a.sil(taper(tail, 36, 28), OR)
        a.sil("M214 256 C262 224 384 222 440 244 C486 262 494 326 466 362 C444 384 380 378 330 382 "
              "C280 386 236 394 212 358 C196 326 198 282 214 256 Z", OR)
        a.sil(limb_d([(246, 300), (246, 384), (244, 430)], [84, 54, 44], G, foot=14, h=22), OR)
        a.sil(limb_d([(440, 300), (430, 366), (452, 404), (448, 430)], [104, 64, 42, 40], G, foot=14, h=22), OR)
        a.blob("M290 383 C330 386 378 383 402 379 C372 364 322 365 290 383 Z", "#fbd49a")
        for t in (0.3, 0.48, 0.66):
            a_band(a, tail, t, t + 0.07, 36, 28, ST)
        for x, y in ((318, 230), (362, 228), (406, 232)):
            a.ink([(x, y - 4, x + 7, y + 16, x + 5, y + 36, x - 8, y + 56)], 15, a=1, b=0)
        a.ink([(490, 292, 472, 294, 458, 298, 448, 306)], 13, a=1, b=0)
        a.ink([(486, 328, 470, 328, 458, 330, 448, 336)], 12, a=1, b=0)
        a.ink([(402, 388, 392, 354, 400, 318, 430, 296)], 9, a=1, b=0)
        a.ink([(276, 388, 284, 364, 282, 342, 272, 322)], 8, a=1, b=0)
        toes(a, 222, G)
        toes(a, 426, G)
    cx = 190
    HEADP = "M190 100 C256 100 292 144 292 196 C292 252 246 284 190 284 C134 284 88 252 88 196 C88 144 124 100 190 100 Z"
    with a.part():
        a_ear_round(a, cx, 74, 124, 32, OR, CREAM, HEADP)
    for d in ([(190, 98, 190, 112, 190, 126, 190, 142)], [(160, 103, 163, 114, 165, 124, 167, 136)], [(220, 103, 217, 114, 215, 124, 213, 136)]):
        a.ink(d, 13, a=1, b=0)
    for d in ((89, 208, 98, 208, 106, 209, 114, 211), (96, 232, 104, 230, 111, 229, 118, 228)):
        a.ink([d], 11, a=1, b=0)
        a.ink([tuple(2 * cx - v if i % 2 == 0 else v for i, v in enumerate(d))], 11, a=1, b=0)
    a.ellipse(cx, 240, 52, 36, CREAM, sw=0, stroke="none")
    a_snout(a, cx, 224, "#f28a9b", 15, line=True)
    a_face(a, cx, 190, 46, 17, cheek=(66, 250, 14, 8))
    a.shine("M128 152 C140 134 158 124 178 120")
    return a


@word
def kaba():
    a = Art()
    P, PD, PL, NOS = "#a99bc4", "#8f80ad", "#c9bde0", "#6c5a8c"
    G = 450
    with a.part():
        a.sil(limb_d([(322, 350), (324, 408), (326, 436)], [72, 62, 58], G, foot=6, h=20), PD)
        a.sil(limb_d([(408, 350), (402, 408), (402, 436)], [72, 62, 58], G, foot=6, h=20), PD)
    with a.part():
        a.sil(taper([(496, 246, 522, 246, 540, 264, 540, 292)], 16, 10), P)
        a.sil("M216 232 C270 194 404 194 460 224 C508 250 514 330 488 372 C472 394 430 392 390 392 "
              "L270 392 C232 392 206 366 204 322 C202 286 204 254 216 232 Z", P)
        a.sil(limb_d([(270, 340), (268, 404), (270, 436)], [96, 76, 68], G, foot=6, h=20), P)
        a.sil(limb_d([(450, 330), (446, 402), (448, 436)], [108, 80, 70], G, foot=6, h=20), P)
        a.blob("M312 392 L408 392 C404 382 404 372 406 362 C376 370 344 370 314 364 Z", PD)
        a.ink([(410, 398, 402, 362, 410, 322, 434, 298)], 9, a=1, b=0)
        a.ink([(312, 398, 320, 366, 318, 340, 308, 318)], 8, a=1, b=0)
        a.shine("M430 232 C456 238 476 256 482 282", sw=8)
    cx = 190
    HEADP = ("M190 96 C236 96 262 124 264 160 C296 172 312 200 312 232 C312 280 262 306 190 306 "
             "C118 306 68 280 68 232 C68 200 84 172 116 160 C118 124 144 96 190 96 Z")
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 54, 106, 21, 25, P)
        a.sil(HEADP, P)
        for s in (-1, 1):
            a.ellipse(cx + s * 54, 108, 10, 14, PINK_IN, sw=0, stroke="none")
        a.blob(HEADP, P)
    a.ellipse(cx, 240, 108, 58, PL, sw=0, stroke="none")
    for s in (-1, 1):
        a.ellipse(cx + s * 34, 212, 9, 12, NOS, sw=0, stroke="none")
    a.path("M146 262 C168 282 212 282 234 262", sw=8)
    a_face(a, cx, 150, 40, 16, cheek=(90, 232, 16, 10))
    a.shine("M92 214 C96 196 108 182 124 176")
    return a.flipped()


@word
def rakuda():
    a = Art()
    T, TD, TL, HOOF = "#e0b070", "#c79754", "#f3d9a8", "#a87c48"
    G = 470
    neck = [(318, 330, 262, 346, 226, 300, 216, 214)]
    with a.part():
        hoofed(a, [(346, 330), (346, 392), (342, 422), (342, 452)], [40, 24, 28, 22], G, TD, HOOF, hh=16)
        hoofed(a, [(430, 330), (424, 390), (430, 420), (428, 452)], [42, 28, 26, 22], G, TD, HOOF, hh=16)
    with a.part():
        a.sil(taper([(480, 282, 514, 286, 530, 326, 524, 364)], 14, 9), T)
        a.sil("M524 356 C510 366 510 390 524 400 C538 390 538 366 524 356 Z", HOOF)
        a.sil(taper(neck, 92, 60, cap=False), T)
        a.sil("M270 300 C268 274 284 262 300 258 C306 210 350 208 358 256 C366 262 378 262 386 256 "
              "C394 206 442 208 448 260 C480 270 494 302 488 336 C482 362 454 372 422 372 L306 372 "
              "C280 372 268 340 270 300 Z", T)
        hoofed(a, [(312, 330), (304, 394), (298, 422), (292, 452)], [56, 28, 34, 24], G, T, HOOF, hh=16)
        hoofed(a, [(456, 320), (460, 386), (474, 420), (476, 452)], [70, 36, 30, 24], G, T, HOOF, hh=16)
        a.blob("M334 372 C364 374 400 372 428 368 C424 360 424 354 426 348 C394 358 362 358 336 354 Z", TD)
        a.ink([(430, 376, 420, 350, 428, 322, 448, 304)], 8, a=1, b=0)
        a.ink([(330, 376, 336, 358, 334, 342, 326, 328)], 7, a=1, b=0)
    cx = 206
    HEADP = ("M206 82 C252 82 274 112 274 150 C274 174 268 192 258 206 C246 224 228 232 206 232 "
             "C184 232 166 224 154 206 C144 192 138 174 138 150 C138 112 160 82 206 82 Z")
    with a.part():
        sym(a, "M150 120 C130 104 110 106 104 120 C116 136 136 138 152 134 Z", T, cx)
        a.sil("M184 92 C180 72 192 62 200 70 C204 58 220 60 220 74 C230 70 236 82 228 94 Z", TD)
        a.sil(HEADP, T)
        a.blob(HEADP, T)
        a.blob("M186 90 C184 76 192 68 200 74 C204 64 218 66 218 78 C226 76 230 84 226 92 C214 98 198 98 186 90 Z", TD)
    a.ellipse(cx, 207, 42, 21, TL, sw=0, stroke="none")
    for s in (-1, 1):
        a.ellipse(cx + s * 14, 201, 4.5, 6, O, sw=0, stroke="none")
    a.path("M190 214 C200 222 212 222 222 214", sw=6)
    a_face(a, cx, 148, 34, 15, cheek=(48, 178, 12, 7))
    a.shine("M160 128 C166 114 178 104 192 100")
    return a


@word
def buta():
    a = Art()
    P, PD, SN, HOOF = "#f9b4be", "#ee9aa8", "#f28a9b", "#c9707f"
    G = 450
    a.tube("M466 300 C500 306 538 288 534 256 C530 230 494 232 494 258 C494 280 522 284 540 268", P, 26, 10)
    with a.part():
        hoofed(a, [(304, 340), (310, 396), (312, 432)], [52, 40, 34], G, PD, HOOF, hh=18)
        hoofed(a, [(398, 340), (388, 392), (392, 432)], [52, 40, 34], G, PD, HOOF, hh=18)
    with a.part():
        a.sil("M214 250 C262 214 392 214 444 240 C490 262 496 330 468 366 C446 388 380 382 330 384 "
              "C280 386 236 394 212 358 C196 326 198 280 214 250 Z", P)
        hoofed(a, [(250, 320), (250, 392), (250, 432)], [80, 50, 40], G, P, HOOF, hh=18)
        hoofed(a, [(444, 320), (440, 390), (444, 432)], [96, 54, 40], G, P, HOOF, hh=18)
        a.blob("M290 386 C330 388 380 384 406 382 C400 372 398 364 398 356 C362 366 322 366 292 362 Z", PD)
        a.ink([(404, 390, 394, 358, 402, 322, 430, 300)], 9, a=1, b=0)
        a.ink([(282, 390, 290, 366, 288, 344, 278, 324)], 8, a=1, b=0)
        a.shine("M424 244 C446 248 464 264 468 288", sw=7)
    cx = 190
    HEADP = "M190 100 C254 100 290 144 290 194 C290 250 246 286 190 286 C134 286 90 250 90 194 C90 144 126 100 190 100 Z"
    with a.part():
        sym(a, "M124 152 C98 126 84 92 94 70 C128 68 162 92 178 120 Z", P, cx)
        a.sil(HEADP, P)
        sym(a, "M122 132 C106 112 98 94 102 82 C122 84 144 98 156 116 Z", PD, cx, sil=False)
        a.blob(HEADP, P)
    with a.part(ow=8):
        a.sil_ellipse(cx, 228, 44, 31, SN)
    for s in (-1, 1):
        a.ellipse(cx + s * 15, 228, 7, 11, "#b9566a", sw=0, stroke="none")
    a.path("M176 270 C185 277 195 277 204 270", sw=7)
    a_face(a, cx, 184, 56, 17, cheek=(76, 232, 15, 9))
    a.shine("M128 152 C140 134 158 124 178 120")
    return a


@word
def hitsuji():
    import math
    a = Art()
    FACE, FACE_D, WOOL, WOOL_D, HOOF = "#93796c", "#7b645a", "#fffaf0", "#efe6d6", "#4f3f38"
    G = 450
    with a.part():
        hoofed(a, [(318, 350), (320, 400), (322, 432)], [34, 28, 26], G, FACE_D, HOOF, hh=16)
        hoofed(a, [(404, 350), (398, 400), (400, 432)], [34, 28, 26], G, FACE_D, HOOF, hh=16)
    with a.part():
        hoofed(a, [(272, 350), (270, 400), (270, 432)], [38, 30, 28], G, FACE, HOOF, hh=16)
        hoofed(a, [(446, 350), (448, 400), (450, 432)], [38, 30, 28], G, FACE, HOOF, hh=16)
    with a.part():
        a.sil(a_wool(356, 298, 134, 82, 11, start=0.2), WOOL)
        a.blob("M252 350 C300 380 420 380 468 346 C450 372 400 384 356 384 C312 384 270 372 252 350 Z", WOOL_D)
        for x, y in ((316, 268), (398, 256), (430, 312), (350, 322)):
            a.ink([(x - 22, y + 8, x - 12, y - 8, x + 12, y - 8, x + 22, y + 8)], 7, col="#e2d6c2")
    cx = 190
    with a.part():
        sym(a, "M128 190 C98 170 62 174 52 194 C68 216 102 218 130 208 Z", FACE, cx)
        a.sil("M190 124 C238 124 264 158 264 200 C264 252 230 284 190 284 C150 284 116 252 116 200 "
              "C116 158 142 124 190 124 Z", FACE)
        sym(a, "M116 194 C100 184 80 186 72 196 C84 208 102 208 120 204 Z", PINK_IN, cx, sil=False)
    with a.part():
        a.sil(a_wool(190, 126, 62, 26, 7, start=math.pi / 2), WOOL)
    a.ellipse(cx, 246, 34, 24, "#b09a8e", sw=0, stroke="none")
    a.path("M180 234 L200 234 L190 245 Z", fill="#f28a9b", sw=5)
    a.path("M190 245 L190 252 M190 252 C185 262 174 262 172 254 M190 252 C195 262 206 262 208 254", sw=6)
    a_face(a, cx, 204, 36, 15, cheek=(54, 238, 13, 8))
    return a.flipped()


@word
def tanuki():
    a = Art()
    BR, BRD, DK, MASK, LT = "#b98a5e", "#a27548", "#5a4036", "#7d5c49", "#f1dcc0"
    tail = [(350, 424, 430, 436, 482, 392, 484, 306)]
    with a.part():
        a.sil(taper(tail, 80, 62), BR)
        a_band(a, tail, 0.5, 0.62, 80, 62, DK)
        a_band(a, tail, 0.76, 0.88, 80, 62, DK)
    FOOT = "M118 380 C146 372 178 392 182 426 C186 456 162 474 132 472 C102 470 82 452 84 422 C86 400 100 386 118 380 Z"
    with a.part():
        a.sil("M256 238 C300 238 340 246 362 272 C388 304 392 350 386 396 C380 440 328 460 256 460 "
              "C184 460 132 440 126 396 C120 350 124 304 150 272 C172 246 212 238 256 238 Z", BR)
        sym(a, FOOT, DK, 256)
        a.blob("M256 282 C306 282 330 324 330 368 C330 416 302 444 256 444 C210 444 182 416 182 368 C182 324 206 282 256 282 Z", LT)
        sym(a, FOOT, DK, 256, sil=False)
        a.ink([(176, 396, 162, 380, 138, 374, 118, 380)], 9, a=0, b=1)
        a.ink([(336, 396, 350, 380, 374, 374, 394, 380)], 9, a=0, b=1)
    with a.part():
        arm = [(184, 236, 150, 284, 164, 336, 216, 352)]
        sym(a, taper(arm, 50, 40), BR, 256)
        for q in (0,):
            d = taper([(196, 346, 204, 349, 210, 351, 216, 352)], 40, 40)
            sym(a, d, DK, 256, sil=False)
    cx = 256
    HEADP = "M256 66 C332 66 376 108 376 162 C376 214 324 246 256 246 C188 246 136 214 136 162 C136 108 180 66 256 66 Z"
    with a.part():
        a_ear_round(a, cx, 88, 92, 32, BR, DK, HEADP)
    a.blob("M256 118 C302 118 336 146 336 188 C336 222 302 240 256 240 C210 240 176 222 176 188 C176 146 210 118 256 118 Z", LT)
    sym(a, "M228 152 C200 140 158 156 148 190 C146 214 178 222 206 210 C226 200 240 178 228 152 Z", MASK, cx, sil=False)
    a_snout(a, cx, 200, EYE, 14, m=0.85)
    a_face(a, cx, 182, 54, 16, cheek=(92, 222, 14, 8))
    with a.part():
        a.sil("M226 66 C230 38 262 24 294 32 C292 60 262 80 226 66 Z", GREEN)
        a.ink([(232, 62, 250, 56, 270, 46, 286, 36)], 6, a=0.6, b=0, col="#4f9a45")
    a.shine("M160 132 C168 116 182 104 198 98")
    return a


@word
def kitsune():
    a = Art()
    OR, OR_D, DK = "#f08a3c", "#d97428", "#6b4a3a"
    G = 454
    with a.part():
        a.sil("M380 448 C472 454 524 392 514 308 C508 250 478 214 446 204 C428 236 424 290 410 336 "
              "C398 376 374 410 380 448 Z", OR)
        a.blob("M446 204 C478 214 508 250 514 308 C498 296 484 300 472 288 C460 296 446 284 430 286 "
               "C434 256 438 226 446 204 Z", WHITE)
    with a.part():
        a.sil("M206 240 C292 220 396 262 424 346 C442 404 424 452 370 454 L190 454 "
              "C170 454 168 400 176 360 C184 318 184 270 206 240 Z", OR)
        for x in (196, 252):
            a.sil(f"M{x - 8} 290 L{x + 24} 330 L{x + 23} 416 C{x + 35} 424 {x + 35} 454 {x + 16} 454 "
                  f"L{x - 18} 454 C{x - 37} 454 {x - 37} 424 {x - 23} 416 C{x - 24} 380 {x - 24} 330 {x - 8} 290 Z", OR)
        a.blob("M380 452 C410 444 424 424 428 394 C418 420 400 432 376 436 Z", OR_D)
        a.blob("M204 270 C196 306 198 336 208 362 C226 340 240 310 236 270 Z", CREAM)
        for x in (196, 252):
            a.blob(f"M{x - 24} 422 C{x - 36} 430 {x - 36} 454 {x - 18} 454 L{x + 16} 454 C{x + 34} 454 {x + 34} 430 {x + 24} 422 "
                   f"C{x + 10} 414 {x - 10} 414 {x - 24} 422 Z", DK)
        a.blob("M302 454 C288 454 286 432 304 424 C326 415 364 419 371 438 C375 448 369 454 359 454 Z", DK)
        a.ink([(326, 300, 392, 290, 436, 352, 412, 404)], 9, a=0, b=0)
        a.ink([(293, 455, 281, 430, 312, 414, 342, 418), (342, 418, 366, 422, 380, 440, 371, 455)], 10, a=1, b=1)
        a.ink([(224, 455, 224, 420, 224, 380, 225, 344)], 10, a=1, b=0)
        a.ink([(281, 440, 280, 410, 278, 380, 272, 350)], 10, a=1, b=0)
    cx = 210
    ear = "M130 152 L120 48 C119 38 130 34 138 40 L216 98 Z"
    inner = "M146 132 L139 74 L186 108 Z"
    HEADP = ("M210 96 C262 96 296 126 304 166 C308 186 324 198 324 208 C304 234 262 252 210 252 "
             "C158 252 116 234 96 208 C96 198 112 186 116 166 C124 126 158 96 210 96 Z")
    with a.part():
        sym(a, ear, OR, cx)
        a.sil(HEADP, OR)
        sym(a, inner, DK, cx, sil=False)
        a.blob(HEADP, OR)
        a.blob("M98 208 C130 198 160 204 180 214 C190 198 230 198 240 214 C260 204 290 198 322 208 "
               "C304 234 262 252 210 252 C158 252 116 234 98 208 Z", WHITE)
    a_snout(a, cx, 208, EYE, 13, m=0.75)
    a_face(a, cx, 168, 46, 17, cheek=(76, 204, 14, 8))
    a.shine("M150 140 C158 124 172 112 190 106")
    return a.flipped()


@word
def usagi():
    a = Art()
    W_, SH, SH2 = "#fffaf4", "#efe4dc", "#e6d8ce"
    G = 454
    with a.part():
        a.sil(a_wool(440, 398, 26, 24, 5, start=0.3), W_)
    with a.part():
        a.sil("M206 250 C292 244 392 284 420 356 C438 408 424 452 370 454 L190 454 "
              "C170 454 168 400 176 360 C184 318 184 280 206 250 Z", W_)
        a.blob("M380 452 C410 444 422 426 424 398 C416 420 400 432 376 436 Z", SH)
        a.ink([(330, 318, 392, 312, 432, 362, 410, 408)], 9, a=0, b=0)
        a.ink([(293, 455, 279, 432, 318, 418, 356, 420), (356, 420, 388, 424, 404, 442, 395, 455)], 10, a=1, b=1)
    for x in (204, 264):            # two short front legs, each its own part: round top, round paw
        a.sil(f"M{x - 23} 384 C{x - 23} 346 {x + 23} 346 {x + 23} 384 L{x + 23} 420 C{x + 34} 428 {x + 34} 454 {x + 15} 454 "
              f"L{x - 17} 454 C{x - 36} 454 {x - 36} 428 {x - 23} 420 Z", W_)
        toes(a, x - 12, G + 1, d=1, gap=13, h=11)
    cx = 210
    HEADP = "M210 86 C270 86 316 122 316 172 C316 226 268 258 210 258 C152 258 104 226 104 172 C104 122 150 86 210 86 Z"
    with a.part():
        sym(a, "M170 116 C140 82 130 6 160 -24 C200 -20 220 48 214 104 Z", W_, cx)
        a.sil(HEADP, W_)
        sym(a, "M176 92 C158 66 152 22 164 -2 C190 6 200 48 196 92 Z", PINK_IN, cx, sil=False)
        a.blob(HEADP, W_)
    a.ellipse(cx, 222, 38, 24, SH, sw=0, stroke="none")
    a.path("M198 206 L222 206 L210 219 Z", fill="#f28a9b", sw=6)
    a.path("M210 219 L210 226 M210 226 C204 238 190 238 188 228 M210 226 C216 238 230 238 232 228", sw=7)
    a_face(a, cx, 174, 50, 19, cheek=(76, 216, 16, 10))
    a.shine("M134 150 C142 130 158 114 178 106")
    return a


@word
def ikada():
    a = Art()
    LOG, LOG_D, END, RING, ROPE = "#e4a560", "#cf8c47", "#f7d9a4", "#c97f3e", "#fff0c4"
    DX, DY = 24, -34
    a.path("M286 196 L286 60", sw=10)                 # a pole with a small flag
    with a.part(8):
        a.sil(c_rpoly([(286, 58), (352, 84), (286, 112)], [0, 10, 0]), RED)
    # logs run left-right; back rows are higher and a little to the right
    for i in range(4, -1, -1):
        dx, dy = i * DX, i * DY
        x, y = 56 + dx, 318 + dy
        with a.part():
            a.sil(c_rect(x, y, 320, 62, 31), LOG)
            a.blob(c_rpoly([(x + 30, y + 44), (x + 296, y + 44), (x + 280, y + 61), (x + 30, y + 61)], [0, 14, 10, 10]), LOG_D)
            a.sil(c_circ(x + 26, y + 31, 24, 31), END)
        a.ellipse(x + 26, y + 31, 10, 14, "none", sw=5, stroke=RING)
        for rx_ in (138, 262):                        # the rope goes round each log
            a.blob(f"M{x + rx_} {y + 1} C{x + rx_ + 12} {y + 18} {x + rx_ + 12} {y + 44} {x + rx_} {y + 61} "
                   f"L{x + rx_ + 18} {y + 61} C{x + rx_ + 30} {y + 44} {x + rx_ + 30} {y + 18} {x + rx_ + 18} {y + 1} Z", ROPE)
        a.shine(f"M{x + 64} {y + 13} L{x + 118} {y + 13}", sw=5)
    c_waves(a, 392, 28, 484, 5)
    return a


@word
def shoubousha():
    a = Art()
    STEEL_ = "#e3e7ea"
    with a.part(7):                                   # ladder on the roof
        for dy in (0, 36):
            a.sil(c_bar(66, 196 + dy, 356, 132 + dy, 11), STEEL_)
        for t in (0.1, 0.3, 0.5, 0.7, 0.9):
            x, y = 66 + 290 * t, 196 - 64 * t
            a.sil(c_bar(x, y, x, y + 36, 9), STEEL_)
    with a.part():                                    # ladder rests
        for x in (96, 250):
            a.sil(c_rect(x, 214, 22, 40, 4), "#8a949a")
    with a.part():                                    # beacon
        a.sil(c_rpoly([(318, 208), (356, 208), (356, 250), (318, 250)], [16, 16, 0, 0]), "#ffd04a")
    a.path("M330 222 L330 236", stroke=WHITE, sw=6, **{"stroke-opacity": "0.8"})
    with a.part():                                    # box and cab: one body
        a.sil("M44 268 Q44 244 68 244 L370 244 C398 244 412 258 424 286 L446 294 Q468 302 468 324 L468 350 "
              "Q468 376 442 376 L70 376 Q44 376 44 350 Z", RED)
        a.blob("M45 314 L467 314 L467 334 L45 334 Z", WHITE)
        a.blob("M45 352 L467 352 Q466 375 442 375 L70 375 Q46 375 45 352 Z", RED_D)
        a.blob(c_rect(70, 262, 92, 38, 8), RED_D)                 # lockers on the box
        a.blob(c_rect(176, 262, 92, 38, 8), RED_D)
    c_line(a, 296, 250, 296, 370, 7, s=0.6, e=0.3)
    c_glass(a, "M316 262 L366 262 C382 262 392 272 400 292 Q402 298 394 298 L316 298 Q310 298 310 292 L310 268 Q310 262 316 262 Z",
            glint=(326, 270, 18))
    a.blob(c_rect(328, 340, 28, 10, 5), WHITE)
    c_lamp(a, 456, 320, 10, 13)
    a.shine("M70 256 L190 256", sw=6)
    for x in (118, 380):
        c_wheel(a, x, 378, 44)
    return a


@word
def kyuukyuusha():
    a = Art()
    W2, W2_D = "#fbf8f2", "#e7e1d6"
    with a.part():                                    # siren
        a.sil(c_rpoly([(306, 122), (366, 122), (366, 168), (306, 168)], [22, 22, 0, 0]), RED)
    a.path("M322 138 L322 152", stroke=WHITE, sw=7, **{"stroke-opacity": "0.7"})
    for x0, y0, x1, y1 in ((290, 118, 274, 104), (382, 118, 398, 104), (336, 104, 336, 86)):
        c_line(a, x0, y0, x1, y1, 9, s=0.9, e=0.3, col="#f6c548")
    with a.part():
        a.sil("M46 188 Q46 160 74 160 L370 160 C398 160 412 174 424 202 L444 258 C460 268 468 282 468 300 "
              "L468 348 Q468 376 440 376 L74 376 Q46 376 46 348 Z", W2)
        a.blob("M47 292 L467 292 L467 316 L47 316 Z", RED)
        a.blob("M47 346 L467 346 Q467 375 440 375 L74 375 Q47 375 47 346 Z", W2_D)
        a.blob(c_rect(140, 190, 30, 86, 7), RED)                  # red cross
        a.blob(c_rect(112, 218, 86, 30, 7), RED)
    c_line(a, 318, 166, 318, 370, 7, s=0.6, e=0.3)
    c_glass(a, "M344 184 L376 184 C390 184 398 192 404 208 L418 246 Q422 258 410 258 L344 258 Q336 258 336 250 "
               "L336 192 Q336 184 344 184 Z", glint=(350, 196, 22))
    c_glass(a, c_rect(228, 190, 66, 56, 10))
    a.blob(c_rect(338, 272, 28, 10, 5), "#b9c0c6")
    c_lamp(a, 456, 302, 10, 13)
    a.shine("M70 174 L210 174", sw=6)
    for x in (126, 384):
        c_wheel(a, x, 378, 44)
    return a


# ------------------------------------------------------------ flyers (D168) --
def bird_face(a, cx=256, cy=190, gap=56, blush_dx=92, blush=True):
    for s in (-1, 1):
        x = cx + s * gap
        a.ellipse(x, cy, 14, 17, EYE, sw=0, stroke="none")
        a.dot(x + 5, cy - 7, 5.5, "#ffffff")
        if blush:
            a.ellipse(cx + s * blush_dx, cy + 36, 16, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})


def bird_feet(a, col="#f29a76"):
    for x in (216, 296):
        a.path(f"M{x} 408 L{x} 436 M{x} 436 L{x-18} 442 M{x} 436 L{x} 446 M{x} 436 L{x+18} 442", stroke=col, sw=16)
        a.path(f"M{x} 408 L{x} 436 M{x} 436 L{x-18} 442 M{x} 436 L{x} 446 M{x} 436 L{x+18} 442", stroke=O, sw=0)
    return a


def bird_base(a, body, belly, wing, tail):
    # tail behind, feet, body, belly, wings, head
    a.path("M300 360 C350 372 392 392 408 430 C360 430 320 412 288 392 Z", fill=tail)
    for x in (214, 298):
        a.path(f"M{x} 400 L{x} 440 M{x} 440 L{x-20} 448 M{x} 440 L{x} 452 M{x} 440 L{x+20} 448", sw=22)
        a.path(f"M{x} 400 L{x} 440 M{x} 440 L{x-20} 448 M{x} 440 L{x} 452 M{x} 440 L{x+20} 448", stroke="#f4a37f", sw=10)
    a.ellipse(256, 322, 112, 100, body)
    a.ellipse(256, 350, 62, 56, belly, sw=0, stroke="none")
    for s in (-1, 1):
        d = "M156 300 C120 306 104 346 128 382 C152 392 176 372 184 340 Z"
        a.path(d if s < 0 else mirror(d), fill=wing)


# --- batch B helpers begin ---
def b_face(a, cx, cy, gap, r=16, cheek=None, mouth=None, white=False, mw=12, col=O):
    """Front face for birds, bugs and water life: two eyes of the same size, cheeks outside and below,
    a small smile between. white=True puts a white patch behind each eye (for dark bodies)."""
    for s in (-1, 1):
        if white:
            a.ellipse(cx + s * gap, cy, r * 1.42, r * 1.62, WHITE, sw=0, stroke="none")
        a.eye(cx + s * gap, cy, r)
    if cheek:
        for s in (-1, 1):
            a.cheek(cx + s * cheek[0], cy + cheek[1], r * 0.95, r * 0.58)
    if mouth is not None:
        y = cy + mouth
        a.path(f"M{cx - mw} {y} C{cx - mw * 0.45} {y + mw * 0.8} {cx + mw * 0.45} {y + mw * 0.8} {cx + mw} {y}",
               sw=7, stroke=col)


def b_side_eye(a, x, y, r=16, cheek=None):
    """One eye for a fish or dolphin drawn in pure profile (same eye as everywhere else)."""
    a.eye(x, y, r)
    if cheek:
        a.cheek(x + cheek[0], y + cheek[1], r * 0.95, r * 0.58)


def b_antennae(a, cx, c, r=9, w=8):
    """Two feelers with a ball at the end: c is the right-hand cubic (8 numbers), mirrored around cx."""
    for s in (-1, 1):
        q = tuple((cx + s * (v - cx)) if i % 2 == 0 else v for i, v in enumerate(c))
        a.ink([q], w, a=1, b=1)
        a.dot(q[6], q[7], r, O)


def b_bird_feet(a, xs, G, col="#f4a37f"):
    """Two small bird feet on the ground: a low dome with two notches (three toes)."""
    for x in xs:
        with a.part():
            a.sil(f"M{x - 28} {G} C{x - 34} {G - 16} {x - 14} {G - 26} {x} {G - 26} "
                  f"C{x + 14} {G - 26} {x + 34} {G - 16} {x + 28} {G} C{x + 14} {G + 4} {x - 14} {G + 4} {x - 28} {G} Z", col)
            for dx in (-10, 10):
                a.ink([(x + dx, G + 2, x + dx, G - 4, x + dx * 0.9, G - 9, x + dx * 0.8, G - 13)], 6, a=1, b=0)


def b_star(cx, cy, R, r, n=5, rot=-90.0, tip=10.0, k=0.84):
    """A star with soft round arms (for the starfish)."""
    import math
    pts = []
    for i in range(n):
        t = math.radians(rot + i * 360 / n)
        v = t - math.pi / n
        pts.append((cx + r * math.cos(v), cy + r * math.sin(v)))
        for dt, rr in (((-tip, R * k), (0, R), (tip, R * k)) if tip else ((0, R),)):
            u = t + math.radians(dt)
            pts.append((cx + rr * math.cos(u), cy + rr * math.sin(u)))
    return smooth(pts)


def b_claw(cx, cy, s=1, k=1.0):
    """A pincer for the crab and the crayfish: one round hand with a V notch at the top. (cx, cy) is the
    wrist at the bottom; s = +1 for the right-hand claw."""
    p = lambda dx, dy: f"{cx + s * dx * k:.1f} {cy + dy * k:.1f}"
    return (f"M{p(0, 0)} C{p(-56, 0)} {p(-72, -70)} {p(-36, -108)} C{p(-24, -120)} {p(-6, -112)} {p(-4, -88)} "
            f"L{p(4, -58)} L{p(16, -92)} C{p(20, -118)} {p(42, -122)} {p(52, -102)} C{p(72, -62)} {p(50, 0)} {p(0, 0)} Z")


def b_spiral(cx, cy, r0, r1, turns, start=0.0, n=9):
    """Cubics of a smooth spiral from radius r0 out to r1 (for the snail's shell)."""
    import math
    m = int(turns * n)
    pts = []
    for i in range(m + 1):
        t = i / m
        ang = math.radians(start) + t * turns * 2 * math.pi
        r = r0 + (r1 - r0) * t
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    out = []
    for i in range(m):
        p0, p1, p2, p3 = pts[max(i - 1, 0)], pts[i], pts[i + 1], pts[min(i + 2, m)]
        out.append((p1[0], p1[1], p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6,
                    p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6, p2[0], p2[1]))
    return out
# --- batch B helpers end ---


@word
def hato():
    a = Art()
    GR, GRD, LG, TL = "#b9c0c9", "#8b95a2", "#e3e7ec", "#7d8794"
    G = 458
    a.sil("M296 372 C350 384 402 404 424 446 C378 452 330 440 286 418 Z", TL)
    b_bird_feet(a, (212, 300), G)
    with a.part():
        a.sil("M256 64 C310 64 340 102 340 146 C340 176 334 196 350 220 C378 262 394 300 390 342 "
              "C384 404 326 436 256 436 C186 436 128 404 122 342 C118 300 134 262 162 220 "
              "C178 196 172 176 172 146 C172 102 202 64 256 64 Z", GR)
        a.blob("M174 216 C210 234 302 234 338 216 C356 240 368 256 376 276 C330 302 182 302 136 276 "
               "C144 256 156 240 174 216 Z", "#4fb59b")
        a.blob("M168 244 C214 262 298 262 344 244 C356 258 366 268 372 280 C326 300 186 300 140 280 "
               "C146 268 156 258 168 244 Z", "#a56fc4")
        a.blob("M256 296 C306 296 330 330 330 366 C330 404 300 426 256 426 C212 426 182 404 182 366 "
               "C182 330 206 296 256 296 Z", LG)
    with a.part():
        w = "M146 262 C112 290 98 340 116 392 C124 408 140 410 152 400 C180 374 192 326 186 290 C182 270 166 258 146 262 Z"
        sym(a, w, GRD, 256)
        for s in (-1, 1):
            for y0 in (0, 30):
                q = (118, 336 + y0, 136, 344 + y0, 156, 344 + y0, 176, 336 + y0)
                q = tuple((256 + s * (v - 256)) if i % 2 == 0 else v for i, v in enumerate(q))
                a.ink([q], 9, a=0.6, b=0.6, col="#5f6875")
    with a.part():
        a.sil("M238 166 C238 156 274 156 274 166 C274 184 264 196 256 196 C248 196 238 184 238 166 Z", "#f4b086")
        a.sil_ellipse(256, 164, 15, 8, "#fbf6f0")
    b_face(a, 256, 146, 46, 16, cheek=(70, 30))
    a.shine("M196 116 C204 100 218 88 236 82")
    return a


@word
def suzume():
    a = Art()
    BR, BRD, CAP, CR = "#c98f55", "#8f5a30", "#a85f34", "#f8ecd8"
    G = 456
    a.sil("M300 372 C346 384 388 402 404 438 C366 446 326 434 290 414 Z", BRD)
    b_bird_feet(a, (214, 298), G)
    with a.part():
        a.sil("M256 72 C326 72 364 116 364 170 C364 196 358 212 368 232 C388 270 394 304 388 340 "
              "C380 400 324 432 256 432 C188 432 132 400 124 340 C118 304 124 270 144 232 "
              "C154 212 148 196 148 170 C148 116 186 72 256 72 Z", CAP)
        # cream face and belly; the brown cap stays on top
        a.blob("M156 152 C186 116 326 116 356 152 C362 200 350 232 322 246 C290 258 222 258 190 246 "
               "C162 232 150 200 156 158 Z", CR)
        a.blob("M256 250 C330 250 380 290 378 344 C374 396 322 424 256 424 C190 424 138 396 134 344 "
               "C132 290 182 250 256 250 Z", BR)
        a.blob("M256 286 C304 286 330 322 330 360 C330 400 300 422 256 422 C212 422 182 400 182 360 "
               "C182 322 208 286 256 286 Z", CR)
        a.blob("M242 196 C238 210 244 226 256 226 C268 226 274 210 270 196 Z", EYE)
        for s in (-1, 1):
            a.ellipse(256 + s * 74, 196, 15, 13, EYE, sw=0, stroke="none")
    with a.part():
        w = "M140 268 C110 294 100 340 118 388 C126 402 140 404 150 394 C176 370 186 328 180 294 C176 276 160 264 140 268 Z"
        sym(a, w, BRD, 256)
        for s in (-1, 1):
            for y0 in (0, 28):
                q = (118, 332 + y0, 134, 340 + y0, 152, 340 + y0, 170, 332 + y0)
                q = tuple((256 + s * (v - 256)) if i % 2 == 0 else v for i, v in enumerate(q))
                a.ink([q], 9, a=0.6, b=0.6, col=CR)
    a.sil("M242 178 C242 170 270 170 270 178 C270 192 262 200 256 200 C250 200 242 192 242 178 Z", "#eaa86e")
    b_face(a, 256, 160, 46, 17)
    a.shine("M194 118 C204 102 218 92 236 86")
    return a


@word
def karasu():
    a = Art()
    BK, BKD, BKL = "#4a4656", "#37333f", "#625d70"
    G = 458
    a.sil("M296 366 C352 380 410 404 436 450 C384 456 330 440 284 414 Z", BKD)
    b_bird_feet(a, (212, 300), G, col="#8b8496")
    with a.part():
        # a small tuft of feathers on the head
        a.sil("M232 84 C230 60 240 40 256 30 C258 46 262 54 270 60 C278 48 290 42 304 42 C296 58 294 74 298 90 Z", BK)
        a.sil("M256 70 C318 70 350 112 350 160 C350 190 344 208 356 230 C380 270 392 306 388 344 "
              "C382 404 326 436 256 436 C186 436 130 404 124 344 C120 306 132 270 156 230 "
              "C168 208 162 190 162 160 C162 112 194 70 256 70 Z", BK)
        a.blob("M256 300 C304 300 328 332 328 368 C328 404 300 426 256 426 C212 426 184 404 184 368 "
               "C184 332 208 300 256 300 Z", BKL)
    with a.part():
        w = "M146 264 C112 292 98 344 116 398 C124 414 140 416 152 406 C180 378 192 328 186 292 C182 272 166 260 146 264 Z"
        sym(a, w, BKD, 256)
    with a.part():
        a.sil("M224 178 C224 164 288 164 288 178 C288 208 270 226 256 226 C242 226 224 208 224 178 Z", "#f7b547")
        a.ink([(228, 190, 244, 200, 268, 200, 284, 190)], 7, a=0.8, b=0.8)
    b_face(a, 256, 152, 50, 16, cheek=(84, 36), white=True)
    a.shine("M196 120 C206 104 220 94 238 88")
    return a


@word
def hikouki():
    a = Art()
    WG, WG_D, WG2 = "#8fb4dc", "#7aa1cc", "#b3cdea"
    with a.part():                                    # far wing
        a.sil(c_rpoly([(300, 230), (254, 146), (306, 146), (380, 228)], [0, 12, 12, 0]), WG2)
    with a.part():                                    # tail fin
        a.sil(c_rpoly([(72, 240), (40, 112), (104, 112), (196, 222)], [0, 16, 16, 0]), BLUE)
    with a.part():                                    # body
        a.sil("M56 258 C56 220 90 200 130 200 L378 200 C440 200 482 230 482 260 C482 290 440 312 378 312 "
              "L134 312 C92 312 56 294 56 258 Z", WHITE)
        a.blob("M66 284 L472 284 C456 300 420 311 378 311 L134 311 C102 311 78 302 66 284 Z", BLUE)
    c_glass(a, "M404 224 C432 226 452 238 462 254 Q464 258 458 258 L404 258 Q398 258 398 252 L398 230 Q398 224 404 224 Z")
    for x in (150, 204, 258, 312):
        c_glass(a, c_circ(x, 244, 14), ow=5)
    with a.part():                                    # tail plane
        a.sil(c_rpoly([(64, 250), (128, 250), (104, 280), (30, 280)], [0, 0, 10, 10]), WG)
    with a.part():                                    # near wing
        a.sil(c_rpoly([(290, 280), (188, 416), (252, 416), (386, 286)], [0, 14, 14, 0]), WG)
        a.blob(c_rpoly([(222, 372), (190, 415), (252, 415), (296, 372)], [0, 12, 12, 0]), WG_D)
    with a.part():                                    # engine on the near wing
        a.sil(c_rect(232, 334, 78, 46, 20), "#e9e4de")
        a.blob(c_rpoly([(288, 335), (309, 335), (309, 379), (288, 379)], [0, 19, 19, 0]), "#cfc8c0")
    a.shine("M130 214 L300 214")
    return a


def lens(w, y0=40, y1=316):
    return (f"M256 {y0} C{256+w} {y0+20} {256+w} {y1-70} 256 {y1} "
            f"C{256-w} {y1-70} {256-w} {y0+20} 256 {y0} Z")


@word
def kikyuu():
    a = Art()
    ENV = ("M256 40 C402 40 444 150 404 232 C382 272 322 300 298 316 L214 316 C190 300 130 272 108 232 "
           "C68 150 110 40 256 40 Z")
    # ropes and basket (behind the envelope)
    a.path("M222 312 L204 392 M290 312 L308 392", sw=8)
    with a.part():
        a.sil(c_rpoly([(190, 392), (322, 392), (310, 474), (202, 474)], [0, 0, 16, 16]), WOOD)
        a.blob(c_rpoly([(194, 448), (318, 448), (310, 473), (202, 473)], [0, 0, 14, 14]), WOOD_D)
    for x in (226, 256, 286):
        c_line(a, x, 406, x + (x - 256) * -0.1, 466, 5, col=WOOD_D)
    c_line(a, 196, 428, 316, 428, 5, col=WOOD_D)
    with a.part():
        a.sil(c_rect(176, 378, 160, 26, 12), WOOD_D)
    with a.part():
        a.sil(ENV, RED)
        a.blob(lens(165), WHITE)
        a.blob(lens(112), YEL2)
        a.blob(lens(60), BLUE)
        a.blob("M108 232 C130 272 190 300 214 316 L298 316 C322 300 382 272 404 232 C380 262 320 286 298 296 "
               "L214 296 C192 286 132 262 108 232 Z", "#000000", **{"fill-opacity": "0.12"})
    with a.part(8):
        a.sil(c_rect(208, 306, 96, 18, 8), "#f7efe0")
    a.shine("M150 150 C152 112 176 82 212 66")
    return a


# --------------------------------------------------------- scenery (D168) --
def petal(cx, cy, L, ang, w=1.0, notch=True):
    """A rounded petal pointing outward from (cx, cy) at angle `ang` (0 = up)."""
    import math
    c, s = math.cos(ang), math.sin(ang)

    def P(x, y):
        return f"{cx + x * c - y * s:.1f} {cy + x * s + y * c:.1f}"
    k = w * L
    if notch:
        return (f"M{P(0, 0)} C{P(-0.62*k, -0.1*L)} {P(-0.7*k, -0.9*L)} {P(-0.16*k, -L)} "
                f"L{P(0, -0.86*L)} L{P(0.16*k, -L)} C{P(0.7*k, -0.9*L)} {P(0.62*k, -0.1*L)} {P(0, 0)} Z")
    return (f"M{P(0, 0)} C{P(-0.7*k, -0.15*L)} {P(-0.6*k, -L)} {P(0, -L)} "
            f"C{P(0.6*k, -L)} {P(0.7*k, -0.15*L)} {P(0, 0)} Z")


def blossom(a, cx, cy, R, rot=0.0, col="#f9c3d0", vein="#ee8fa8"):
    import math
    for i in range(5):
        ang = rot + i * 2 * math.pi / 5
        a.path(petal(cx, cy, R, ang, w=0.78, notch=False), fill=col)
    for i in range(5):
        ang = rot + i * 2 * math.pi / 5
        a.path(f"M{cx + 0.2*R*math.sin(ang):.1f} {cy - 0.2*R*math.cos(ang):.1f} "
               f"L{cx + 0.55*R*math.sin(ang):.1f} {cy - 0.55*R*math.cos(ang):.1f}", stroke=vein, sw=6)
    a.circle(cx, cy, R * 0.2, "#f7d36b", sw=8)


# --- batch D helpers begin ---
# Helpers for the food and plant words (ringo ... kinoko). Paths here use only M / L / C / Z.
import math as _dm
from lib import _parse as _d_parse


def d_circ(cx, cy, rx, ry=None):
    """An ellipse as a bezier path (so it can go through d_rim / d_tf)."""
    ry = rx if ry is None else ry
    kx, ky = rx * 0.5523, ry * 0.5523
    return (f"M{cx - rx:.1f} {cy:.1f} C{cx - rx:.1f} {cy - ky:.1f} {cx - kx:.1f} {cy - ry:.1f} {cx:.1f} {cy - ry:.1f} "
            f"C{cx + kx:.1f} {cy - ry:.1f} {cx + rx:.1f} {cy - ky:.1f} {cx + rx:.1f} {cy:.1f} "
            f"C{cx + rx:.1f} {cy + ky:.1f} {cx + kx:.1f} {cy + ry:.1f} {cx:.1f} {cy + ry:.1f} "
            f"C{cx - kx:.1f} {cy + ry:.1f} {cx - rx:.1f} {cy + ky:.1f} {cx - rx:.1f} {cy:.1f} Z")


def d_tf(d, s=1.0, dx=0.0, dy=0.0, deg=0.0):
    """Scale, turn (degrees, clockwise on screen) and move a path."""
    c, sn = _dm.cos(_dm.radians(deg)), _dm.sin(_dm.radians(deg))
    out = []
    for cmd, v in _d_parse(d):
        q = []
        for i in range(0, len(v), 2):
            x, y = v[i], v[i + 1]
            q.append(f"{s * (x * c - y * sn) + dx:.1f} {s * (x * sn + y * c) + dy:.1f}")
        out.append(cmd + " ".join(q))
    return " ".join(out)


def d_poly(d, n=14):
    """Points along a closed path."""
    pts, cur = [], (0, 0)
    for cmd, v in _d_parse(d):
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
    if abs(pts[0][0] - pts[-1][0]) + abs(pts[0][1] - pts[-1][1]) < 0.5:
        pts.pop()
    return pts


def d_rim(d, ang, span, thick, inset=1.0, c=None):
    """A crescent of shade just inside the edge of shape d. It sits on the side that looks toward `ang`
    (degrees; 0 = right, 90 = down), reaches `span` degrees to each side, and is `thick` wide in the middle.
    Always stays inside the shape, so it never covers the outline."""
    P = d_poly(d)
    n = len(P)
    area = sum(P[i][0] * P[(i + 1) % n][1] - P[(i + 1) % n][0] * P[i][1] for i in range(n))
    sg = 1 if area > 0 else -1
    if c is None:
        xs = [p[0] for p in P]; ys = [p[1] for p in P]
        c = ((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2)
    diff = [((_dm.degrees(_dm.atan2(y - c[1], x - c[0])) - ang + 180) % 360) - 180 for x, y in P]
    ins = [abs(v) <= span for v in diff]
    i0 = next(i for i in range(n) if ins[i] and not ins[i - 1])
    outer, inner = [], []
    i = i0
    while ins[i % n] and i < i0 + n:
        k = i % n
        (xa, ya), (xb, yb) = P[k - 1], P[(k + 1) % n]
        tx, ty = xb - xa, yb - ya
        L = (tx * tx + ty * ty) ** 0.5 or 1
        nx, ny = sg * -ty / L, sg * tx / L
        u = (diff[k] + span) / (2 * span)
        w = thick * max(0.0, _dm.sin(_dm.pi * u)) ** 0.7
        outer.append((P[k][0] + nx * inset, P[k][1] + ny * inset))
        inner.append((P[k][0] + nx * (inset + w), P[k][1] + ny * (inset + w)))
        i += 1
    return "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in outer + inner[::-1]) + " Z"


def d_curve(pts):
    """Cubic pieces (for Art.ink) of a smooth open line through the points."""
    n = len(pts)
    out = []
    for i in range(n - 1):
        p0 = pts[max(i - 1, 0)]; p1 = pts[i]; p2 = pts[i + 1]; p3 = pts[min(i + 2, n - 1)]
        out.append((p1[0], p1[1], p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6,
                    p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6, p2[0], p2[1]))
    return out


def d_arc(cx, cy, r, a0, a1, r1=None, ky=1.0):
    """Cubic pieces of an arc from angle a0 to a1 (degrees; 0 = right, 90 = down). r1: end radius (spiral)."""
    r1 = r if r1 is None else r1
    m = max(2, int(abs(a1 - a0) / 15) + 1)
    pts = []
    for j in range(m + 1):
        t = j / m
        an = _dm.radians(a0 + (a1 - a0) * t)
        rr = r + (r1 - r) * t
        pts.append((cx + rr * _dm.cos(an), cy + rr * ky * _dm.sin(an)))
    return d_curve(pts)


def d_leaf(bx, by, tx, ty, w, skew=0.0):
    """A pointed leaf from its base (bx, by) to its tip; w = how fat it is."""
    vx, vy = tx - bx, ty - by
    L = (vx * vx + vy * vy) ** 0.5
    nx, ny = -vy / L, vx / L
    P = lambda t, k: f"{bx + vx * t + nx * k:.1f} {by + vy * t + ny * k:.1f}"
    k1, k2 = w * 0.75, w * 0.5
    return (f"M{P(0, 0)} C{P(0.14, k1 * (1 + skew))} {P(0.7, k2 * (1 + skew))} {P(1, 0)} "
            f"C{P(0.7, -k2 * (1 - skew))} {P(0.14, -k1 * (1 - skew))} {P(0, 0)} Z")


def d_vein(a, bx, by, tx, ty, col, w=7, t0=0.06, t1=0.8, bow=0.0):
    """The middle line of a leaf: thick at the base, fading toward the tip."""
    vx, vy = tx - bx, ty - by
    nx, ny = -vy * bow, vx * bow
    q = lambda t, k=0.0: (bx + vx * t + nx * k, by + vy * t + ny * k)
    (x0, y0), (x1, y1), (x2, y2), (x3, y3) = q(t0), q(t0 + (t1 - t0) / 3, 1), q(t0 + (t1 - t0) * 2 / 3, 1), q(t1)
    a.ink([(x0, y0, x1, y1, x2, y2, x3, y3)], w, a=0.9, b=0, col=col)


def d_grain(a, x, y, deg=0.0, col="#e2d9c2", L=9, w=8):
    """One grain of rice (a short fat mark)."""
    c, s = _dm.cos(_dm.radians(deg)) * L, _dm.sin(_dm.radians(deg)) * L
    a.ink([(x - c, y - s, x - c / 3, y - s / 3, x + c / 3, y + s / 3, x + c, y + s)], w, a=0.55, b=0.55, col=col)


def d_flower5(a, cx, cy, R, rot=0.0, col="#f9c3d0", vein="#ee8fa8", notch=True, w=0.8):
    """A five-petal flower as one part (one outline); short lines from the middle split the petals."""
    with a.part():
        for i in range(5):
            a.sil(petal(cx, cy, R, rot + i * 2 * _dm.pi / 5, w=w, notch=notch), col)
        for i in range(5):
            an = rot + (i + 0.5) * 2 * _dm.pi / 5
            sx, sy = _dm.sin(an), -_dm.cos(an)
            a.ink([(cx + sx * R * 0.1, cy + sy * R * 0.1, cx + sx * R * 0.2, cy + sy * R * 0.2,
                    cx + sx * R * 0.32, cy + sy * R * 0.32, cx + sx * R * 0.44, cy + sy * R * 0.44)], R * 0.09, a=1, b=0, col=vein)
        a.blob(d_circ(cx, cy, R * 0.2), vein)
        for i in range(5):
            an = rot + i * 2 * _dm.pi / 5
            a.dot(cx + _dm.sin(an) * R * 0.3, cy - _dm.cos(an) * R * 0.3, R * 0.06, "#f7c948")
        a.dot(cx, cy, R * 0.1, "#f7d36b")


def d_blade(x0, base, w, tx, ty):
    """A blade of grass: flat foot at (x0, base), curved to the tip (tx, ty)."""
    h = base - ty
    return (f"M{x0 - w / 2:.1f} {base} C{x0 - w / 2:.1f} {base - h * 0.5:.1f} {tx - (tx - x0) * 0.25 - w * 0.12:.1f} {ty + h * 0.28:.1f} {tx:.1f} {ty:.1f} "
            f"C{tx - (tx - x0) * 0.25 + w * 0.3:.1f} {ty + h * 0.3:.1f} {x0 + w / 2:.1f} {base - h * 0.5:.1f} {x0 + w / 2:.1f} {base} Z")
# --- batch D helpers end ---


@word
def sakura():
    a = Art()
    BR = "#9a6b4a"
    with a.part():
        a.sil(taper([(444, 474, 384, 424, 320, 380, 250, 310), (250, 310, 200, 260, 172, 222, 162, 176)], 30, 14), BR)
        a.sil(taper([(262, 322, 236, 326, 214, 330, 196, 334)], 18, 12), BR)
        a.sil(taper([(350, 400, 362, 372, 360, 330, 344, 300)], 16, 11), BR)
        a.ink([(424, 462, 384, 428, 340, 396, 300, 362)], 7, a=0, b=0, col="#7d5237")
    d_flower5(a, 168, 150, 90, 0.2)
    d_flower5(a, 340, 228, 100, 0.55)
    d_flower5(a, 196, 334, 70, 0.4)
    d_flower5(a, 398, 404, 62, 0.0)
    # a bud at the top of the twig
    a.sil("M262 60 C286 64 300 90 290 116 C270 122 248 104 250 78 C252 68 256 62 262 60 Z", "#f7a9bd")
    a.shine("M118 128 C122 110 134 96 150 90", sw=6)
    return a


@word
def himawari():
    import math
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    with a.part():
        a.sil("M244 300 L268 300 L268 470 C268 478 244 478 244 470 Z", LEAF)
        a.sil(d_leaf(262, 404, 408, 356, 92, 0.25), LEAF)
        a.sil(d_leaf(250, 404, 104, 356, 92, -0.25), LEAF)
        d_vein(a, 266, 402, 408, 356, LEAF_D, t0=0.05, t1=0.78)
        d_vein(a, 246, 402, 104, 356, LEAF_D, t0=0.05, t1=0.78)
    n = 12
    with a.part():
        for i in range(n):
            a.sil(petal(256, 190, 152, (i + 0.5) * 2 * math.pi / n, w=0.42, notch=False), "#f2b62e")
    with a.part():
        for i in range(n):
            a.sil(petal(256, 190, 142, i * 2 * math.pi / n, w=0.44, notch=False), YEL2)
        for i in range(n):
            an = (i + 0.5) * 2 * math.pi / n
            sx, sy = math.sin(an), -math.cos(an)
            a.ink([(256 + sx * 70, 190 + sy * 70, 256 + sx * 80, 190 + sy * 80, 256 + sx * 90, 190 + sy * 90, 256 + sx * 100, 190 + sy * 100)],
                  7, a=1, b=0, col="#e09a1c")
    with a.part():
        a.sil(d_circ(256, 190, 76), "#8a5530")
        a.blob(d_circ(256, 190, 54), "#6e4224")
        for r, cnt in ((22, 6), (40, 11)):
            for j in range(cnt):
                t = j * 2 * math.pi / cnt + r
                a.dot(256 + r * math.cos(t), 190 + r * math.sin(t), 6, "#b98255")
        a.dot(256, 190, 6, "#b98255")
        a.blob(d_rim(d_circ(256, 190, 76), 50, 70, 12), "#74441f")
    a.shine("M202 160 C208 140 222 126 240 120")
    return a


@word
def tanpopo():
    import math
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    leaf = ("M252 466 C226 468 204 462 190 452 L204 428 C182 432 164 426 152 416 L168 394 "
            "C144 396 124 388 112 376 L132 358 C110 354 92 344 84 330 C112 322 142 330 160 344 "
            "C186 364 214 384 236 404 C246 414 252 430 252 466 Z")
    with a.part():
        a.sil(leaf, LEAF)
        a.sil(mirror(leaf), LEAF)
        a.sil("M246 300 L266 300 L267 466 L245 466 Z", "#8fd07a")
        a.ink([(240, 452, 204, 420, 160, 376, 112, 340)], 8, a=0.8, b=0, col=LEAF_D)
        a.ink([(272, 452, 308, 420, 352, 376, 400, 340)], 8, a=0.8, b=0, col=LEAF_D)
    cx, cy = 256, 178
    n = 16
    with a.part():
        for i in range(n):
            a.sil(petal(cx, cy, 122, i * 2 * math.pi / n, w=0.3, notch=False), "#f7c948")
        for i in range(n):
            a.blob(petal(cx, cy, 92, (i + 0.5) * 2 * math.pi / n, w=0.34, notch=False), "#fbe07a")
        for i in range(10):
            a.blob(petal(cx, cy, 58, i * 2 * math.pi / 10, w=0.5, notch=False), "#f7c948")
        a.blob(d_circ(cx, cy, 26), "#f0b429")
    a.shine("M206 142 C212 124 224 110 240 104")
    return a


@word
def ringo():
    a = Art()
    a.sil(taper([(258, 160, 258, 122, 266, 94, 284, 64)], 15, 20), "#8a5530")
    with a.part():
        a.sil("M286 106 C304 50 366 32 410 56 C400 112 338 140 286 106 Z", GREEN)
        d_vein(a, 290, 102, 404, 60, "#58a24a", t1=0.76, bow=-0.04)
    body = ("M256 142 C296 98 404 104 412 224 C418 342 344 436 292 436 C272 436 264 428 256 428 "
            "C248 428 240 436 220 436 C168 436 94 342 100 224 C108 104 216 98 256 142 Z")
    with a.part():
        a.sil(body, RED)
        a.blob(d_rim(body, 40, 62, 30), RED_D)
        a.ink([(222, 138, 238, 158, 274, 158, 290, 138)], 9, a=0, b=0)
    a.shine("M152 220 C148 184 164 154 192 142", sw=9)
    return a


@word
def mikan():
    a = Art()
    OR, OR_D = "#f7931e", "#e57d12"
    with a.part():
        a.sil(d_leaf(262, 150, 392, 66, 88, 0.2), GREEN)
        d_vein(a, 262, 150, 392, 66, "#58a24a", t0=0.2, t1=0.8)
    body = "M96 292 C96 198 170 146 256 146 C342 146 416 198 416 292 C416 380 346 436 256 436 C166 436 96 380 96 292 Z"
    with a.part():
        a.sil(body, OR)
        a.blob(d_rim(body, 42, 62, 30), OR_D)
        for dx, dy in ((-72, 262), (-30, 356), (58, 300), (24, 392), (-96, 336), (96, 362), (-10, 230)):
            a.dot(256 + dx, dy - 20, 4, "#fbb657")
    # the green star where the stem was
    import math
    pts = []
    for i in range(10):
        r = 40 if i % 2 == 0 else 15
        t = -math.pi / 2 + i * math.pi / 5
        pts.append((256 + r * math.cos(t), 158 + r * 0.56 * math.sin(t)))
    with a.part(ow=9):
        a.sil("M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z", "#5aa84c")
        a.blob(d_circ(256, 157, 9, 6), "#3f8a3c")
    a.shine("M140 268 C140 230 164 196 200 178", sw=9)
    return a


@word
def ichigo():
    a = Art()
    body = "M256 456 C232 456 98 356 98 250 C98 186 156 156 256 164 C356 156 414 186 414 250 C414 356 280 456 256 456 Z"
    with a.part():
        a.sil(body, RED)
        a.blob(d_rim(body, 42, 58, 30), RED_D)
        seeds = [(176, 244), (256, 232), (336, 244), (138, 290), (216, 292), (296, 292), (368, 288),
                 (178, 340), (256, 342), (330, 338), (218, 390), (292, 388), (256, 428)]
        for x, y in seeds:
            a.ellipse(x, y, 8, 12, "#ffe18a", sw=0, stroke="none")
    top = ("M256 196 C230 202 196 190 148 162 C176 152 206 156 232 170 C214 150 204 130 200 104 "
           "C228 118 244 142 256 164 C268 142 284 118 312 104 C308 130 298 150 280 170 "
           "C306 156 336 152 364 162 C316 190 282 202 256 196 Z")
    with a.part():
        a.sil(taper([(256, 170, 256, 150, 258, 132, 262, 112)], 14, 16), "#5aa84c")
        a.sil(top, GREEN)
        a.ink([(256, 190, 232, 186, 204, 176, 180, 166)], 6, a=0.6, b=0, col="#58a24a")
        a.ink([(256, 190, 280, 186, 308, 176, 332, 166)], 6, a=0.6, b=0, col="#58a24a")
    a.shine("M134 262 C132 228 152 200 182 190", sw=9)
    return a


@word
def ninjin():
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    for bx, tx, ty, w, sk in ((244, 150, 62, 84, -0.2), (268, 370, 70, 84, 0.2), (256, 258, 18, 86, 0)):
        with a.part():
            a.sil(d_leaf(bx, 188, tx, ty, w, sk), LEAF)
            d_vein(a, bx, 188, tx, ty, LEAF_D, t0=0.2, t1=0.8)
    body = ("M256 158 C330 150 374 178 358 228 C336 306 298 400 269 456 C263 468 249 468 243 456 "
            "C214 400 176 306 154 228 C138 178 182 150 256 158 Z")
    with a.part():
        a.sil(body, "#f78d2e")
        a.blob(d_rim(body, 25, 62, 26), "#e07a1e")
        a.ink([(160, 248, 182, 254, 204, 254, 224, 248)], 8, a=1, b=0)
        a.ink([(331, 304, 312, 310, 294, 310, 278, 304)], 8, a=1, b=0)
        a.ink([(203, 366, 220, 371, 236, 371, 250, 366)], 8, a=1, b=0)
    a.shine("M188 212 C184 192 196 178 216 174", sw=9)
    return a


@word
def daikon():
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    for bx, tx, ty, w, sk in ((242, 126, 50, 104, -0.25), (270, 420, 112, 96, 0.25), (256, 262, 14, 100, 0)):
        with a.part():
            a.sil(d_leaf(bx, 214, tx, ty, w, sk), LEAF)
            d_vein(a, bx, 214, tx, ty, LEAF_D, t0=0.2, t1=0.82)
    body = ("M256 190 C318 186 340 218 334 268 C328 356 292 432 266 472 C261 480 251 480 246 472 "
            "C220 432 184 356 178 268 C172 218 194 186 256 190 Z")
    with a.part():
        a.sil(body, "#fbf8ef")
        a.blob("M182 264 C176 222 198 194 256 195 C314 194 336 222 330 264 C300 240 212 240 182 264 Z", "#cfe8b0")
        a.blob(d_rim(body, 25, 68, 22), "#e6dfcc")
        a.ink([(181, 300, 198, 305, 214, 305, 228, 300)], 7, a=1, b=0)
        a.ink([(322, 340, 306, 345, 292, 345, 280, 340)], 7, a=1, b=0)
        a.ink([(213, 398, 226, 402, 238, 402, 250, 398)], 7, a=1, b=0)
    a.shine("M204 262 C200 238 204 218 222 208", sw=9)
    return a


@word
def kabocha():
    a = Art()
    GRN, GRN_L, GRN_D = "#4f9a4a", "#63ad58", "#3f8440"
    a.sil(taper([(258, 166, 258, 132, 266, 108, 288, 86)], 28, 30), "#b3945a")
    body = ("M256 152 C330 130 430 150 440 250 C448 340 380 420 256 420 C132 420 64 340 72 250 "
            "C82 150 182 130 256 152 Z")
    with a.part():
        a.sil(body, GRN)
        a.blob("M256 158 C212 196 204 356 256 414 C308 356 300 196 256 158 Z", GRN_L)
        a.blob("M164 156 C116 204 112 316 152 384 C120 352 84 300 88 248 C92 204 124 170 164 156 Z", GRN_L)
        a.blob(d_rim(body, 40, 62, 30), GRN_D)
        a.ink([(256, 152, 212, 192, 204, 358, 256, 420)], 8, a=1, b=1)
        a.ink([(256, 152, 300, 192, 308, 358, 256, 420)], 8, a=1, b=1)
        a.ink([(176, 145, 124, 200, 118, 322, 162, 398)], 8, a=1, b=1)
        a.ink([(336, 145, 388, 200, 394, 322, 350, 398)], 8, a=1, b=1)
        for x, y in ((112, 300), (150, 250), (238, 330), (270, 240), (346, 300), (404, 262)):
            a.ellipse(x, y, 9, 6, "#a5d48c", sw=0, stroke="none")
    a.shine("M106 244 C106 208 124 182 150 170", sw=9)
    return a


# ------------------------------------------------------ bugs and food (D169) --
def bug_face(a, cx, cy, gap=20, r=9, smile=True, blush=True):
    """Small dot eyes and a smile for the bugs (same feel as the animals)."""
    for s in (-1, 1):
        x = cx + s * gap
        a.ellipse(x, cy, r, r * 1.2, EYE, sw=0, stroke="none")
        a.dot(x + 3, cy - 4, r * 0.38, "#ffffff")
        if blush:
            a.ellipse(cx + s * (gap + 20), cy + 16, 9, 6, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})
    if smile:
        a.path(f"M{cx-9} {cy+14} C{cx-4} {cy+22} {cx+4} {cy+22} {cx+9} {cy+14}", sw=6)


@word
def chou():
    a = Art()
    UP, UPD, LO, LOD = "#f8a551", "#ee8a35", "#f79abb", "#ee7ea6"
    cx = 256
    b_antennae(a, cx, (268, 150, 276, 108, 300, 82, 328, 78), r=11)
    with a.part():
        sym(a, "M250 262 C186 258 110 298 114 362 C118 424 206 424 238 358 C248 334 252 300 250 262 Z", LO, cx)
        for s in (-1, 1):
            a.ellipse(cx + s * 84, 350, 24, 22, "#fff4cf", sw=0, stroke="none")
    with a.part():
        sym(a, "M250 252 C236 150 150 68 84 96 C32 120 42 204 100 240 C150 268 210 272 250 264 Z", UP, cx)
        for s in (-1, 1):
            a.blob(f"M{cx + s * 176} 108 C{cx + s * 214} 128 {cx + s * 214} 192 {cx + s * 164} 232 "
                   f"C{cx + s * 196} 196 {cx + s * 200} 144 {cx + s * 176} 108 Z", UPD)
            a.ellipse(cx + s * 124, 168, 32, 30, "#fff4cf", sw=0, stroke="none")
            a.ellipse(cx + s * 124, 168, 15, 14, "#c35f9a", sw=0, stroke="none")
            a.ellipse(cx + s * 70, 226, 12, 11, "#fff4cf", sw=0, stroke="none")
    body = [(256, 200, 256, 280, 256, 340, 256, 400)]
    with a.part():
        a.sil(taper(body, 52, 20), "#8a5a44")
        for t in (0.42, 0.6, 0.78):
            band(a, body, t, t + 0.06, 52, 20, "#6e4532")
    a.sil("M256 126 C290 126 310 148 310 176 C310 206 288 224 256 224 C224 224 202 206 202 176 C202 148 222 126 256 126 Z", "#f7d9b4")
    b_face(a, cx, 176, 22, 11, cheek=(38, 18), mouth=18, mw=9)
    a.shine("M84 128 C98 110 118 100 140 98")
    return a


@word
def tonbo():
    a = Art()
    WG, WGD, HD = "#d3ecf8", "#a9d3ea", "#f08a4b"
    cx = 256
    with a.part():
        sym(a, "M248 236 C186 240 104 268 68 306 C52 328 70 348 98 340 C162 322 216 284 248 256 Z", WG, cx)
    with a.part():
        sym(a, "M248 210 C190 160 100 124 44 146 C20 158 26 190 58 204 C120 228 200 236 248 236 Z", WG, cx)
        for s in (-1, 1):
            m = lambda q: tuple((cx + s * (v - cx)) if i % 2 == 0 else v for i, v in enumerate(q))
            a.ink([m((236, 222, 180, 200, 120, 178, 66, 172))], 6, a=0.4, b=0, col=WGD)
            a.ellipse(cx + s * 186, 160, 13, 6, "#f29a76", sw=0, stroke="none")
    body = [(256, 160, 256, 260, 256, 380, 256, 466)]
    with a.part():
        a.sil(taper(body, 56, 18), RED)
        a.sil_ellipse(256, 216, 34, 46, RED)
        for t in (0.42, 0.56, 0.7, 0.84):
            band(a, body, t, t + 0.025, 56, 18, RED_D)
    a.sil("M256 82 C296 82 318 104 318 132 C318 162 292 180 256 180 C220 180 194 162 194 132 C194 104 216 82 256 82 Z", HD)
    b_face(a, cx, 130, 27, 13, cheek=(46, 20), mouth=20, mw=9)
    a.shine("M70 150 C92 140 116 138 140 142")
    return a


@word
def hachi():
    import math
    a = Art()
    BEE, BEE_D, BLK, WG = "#f9cd4e", "#eeb732", "#3b2f2a", "#d9effb"
    cx, cy, rx, ry = 318, 306, 132, 98
    hx = 164
    HEADP = (f"M{hx} 218 C{hx + 56} 218 {hx + 90} 256 {hx + 90} 304 C{hx + 90} 352 {hx + 54} 386 {hx} 386 "
             f"C{hx - 54} 386 {hx - 90} 352 {hx - 90} 304 C{hx - 90} 256 {hx - 56} 218 {hx} 218 Z")
    a.sil("M300 226 C258 168 262 88 314 78 C360 74 368 150 348 226 Z", WG)
    a.sil("M350 226 C352 166 392 106 436 120 C470 142 440 206 386 236 Z", WG)
    b_antennae(a, hx, (hx + 22, 232, hx + 26, 200, hx + 42, 180, hx + 56, 170), r=10)
    with a.part():
        # head, body and sting are one part: the head melts into the body (no line between them)
        a.sil(f"M{cx + rx - 12} 288 C{cx + rx + 20} 294 {cx + rx + 42} 306 {cx + rx + 52} 320 "
              f"C{cx + rx + 30} 328 {cx + rx + 10} 332 {cx + rx - 14} 330 Z", BLK)
        a.sil_ellipse(cx, cy, rx, ry, BEE)
        a.sil(HEADP, BEE)
        top = lambda x: cy - (ry - 1) * math.sqrt(max(0, 1 - ((x - cx) / (rx - 1)) ** 2))
        for x1, x2 in ((232, 280), (322, 362), (398, 426)):
            t1, t2 = top(x1), top(x2)
            b1, b2 = 2 * cy - t1, 2 * cy - t2
            a.blob(f"M{x1} {t1:.1f} A{rx - 1} {ry - 1} 0 0 1 {x2} {t2:.1f} Q{x2 + 22} {cy} {x2} {b2:.1f} "
                   f"A{rx - 1} {ry - 1} 0 0 1 {x1} {b1:.1f} Q{x1 + 22} {cy} {x1} {t1:.1f} Z", BLK)
        a.blob("M250 384 C296 402 370 400 420 368 C392 398 340 406 300 402 C278 400 262 394 250 384 Z", BEE_D)
        a.blob(HEADP, BEE)
    b_face(a, hx, 306, 36, 16, cheek=(60, 32), mouth=26, mw=11)
    a.shine(f"M{hx - 56} 270 C{hx - 50} 252 {hx - 36} 240 {hx - 18} 236")
    return a


@word
def hotaru():
    a = Art()
    BLK, BLK_L, WG, HD, GLOW = "#4a4458", "#625d70", "#dcf0fb", "#f0715f", "#ffe24d"
    hx = 172
    HEADP = (f"M{hx} 216 C{hx + 56} 216 {hx + 90} 254 {hx + 90} 302 C{hx + 90} 350 {hx + 54} 384 {hx} 384 "
             f"C{hx - 54} 384 {hx - 90} 350 {hx - 90} 302 C{hx - 90} 254 {hx - 56} 216 {hx} 216 Z")
    a.circle(420, 318, 92, "#fff2a6", sw=0, stroke="none", **{"fill-opacity": "0.55"})
    a.sil("M262 262 C232 190 262 110 316 100 C366 98 364 190 334 262 Z", WG)
    a.sil("M316 262 C322 196 366 138 410 152 C440 178 408 240 360 268 Z", WG)
    b_antennae(a, hx, (hx + 22, 230, hx + 26, 198, hx + 42, 178, hx + 56, 168), r=10)
    with a.part():
        # head, wing cases and the light are one part: the red head melts into the dark body
        a.sil("M330 250 C400 232 470 262 470 318 C470 374 404 396 334 372 Z", GLOW)
        a.sil("M352 250 C300 232 236 236 200 262 L200 362 C240 388 300 392 352 372 "
              "C366 334 366 288 352 250 Z", BLK)
        a.sil(HEADP, HD)
        a.blob("M352 250 C366 288 366 334 352 372 C372 372 384 366 392 356 C400 320 398 290 388 262 C378 254 366 250 352 250 Z", "#fff3a0")
        a.ink([(270, 252, 300, 248, 330, 252, 354, 260)], 7, a=0, b=0, col=BLK_L)
    b_face(a, hx, 302, 36, 16, cheek=(60, 32), mouth=26, mw=11)
    a.shine(f"M{hx - 56} 268 C{hx - 50} 250 {hx - 36} 238 {hx - 18} 234")
    a.shine("M420 276 C438 280 452 294 456 312", sw=7)
    return a


@word
def semi():
    a = Art()
    BR, BRD, BRL, WG, VEIN = "#946240", "#6f4a2e", "#e9b37c", "#eefaf8", "#a9d6cf"
    cx = 256
    m = lambda q, s: tuple((cx + s * (v - cx)) if i % 2 == 0 else v for i, v in enumerate(q))
    with a.part():
        for s in (-1, 1):
            a.sil(taper([m((330, 190, 356, 186, 376, 174, 388, 154), s)], 24, 14), BRD)
            a.sil(taper([m((346, 244, 372, 246, 392, 240, 406, 226), s)], 24, 14), BRD)
    with a.part():
        a.sil("M256 150 C324 150 356 192 352 250 C346 334 302 412 256 432 C210 412 166 334 160 250 "
              "C156 192 188 150 256 150 Z", BR)
        a.blob("M214 204 C228 190 244 204 256 220 C268 204 284 190 298 204 C294 230 276 246 256 250 C236 246 218 230 214 204 Z", BRL)
        for y, w_ in ((300, 50), (340, 40), (378, 28)):
            a.ink([(cx - w_, y, cx - w_ * 0.4, y + 12, cx + w_ * 0.4, y + 12, cx + w_, y)], 9, a=0.4, b=0.4, col=BRD)
    wing = ("M280 194 C336 186 378 236 390 312 C400 384 378 446 344 474 C314 444 288 382 276 310 "
            "C270 262 270 220 280 194 Z")
    for s in (-1, 1):
        with a.part():
            a.sil(wing if s > 0 else mirror(wing, cx), WG)
            a.ink([m((292, 214, 322, 270, 340, 350, 344, 450), s)], 6, a=0.3, b=0, col=VEIN)
            a.ink([m((306, 244, 340, 262, 364, 296, 376, 340), s)], 5, a=0, b=0, col=VEIN)
            a.ink([m((326, 320, 348, 340, 364, 370, 370, 404), s)], 5, a=0, b=0, col=VEIN)
    a.sil("M256 66 C322 66 364 94 364 132 C364 168 320 190 256 190 C192 190 148 168 148 132 C148 94 192 66 256 66 Z", BR)
    a.blob("M214 76 C240 68 272 68 298 76 C284 88 228 88 214 76 Z", BRL)
    b_face(a, cx, 132, 66, 15, cheek=(40, 26), mouth=16, mw=12)
    a.shine("M176 112 C186 96 202 86 222 82")
    return a


@word
def kabutomushi():
    a = Art()
    SH, SHD, HD, HN = "#6b4530", "#4f3222", "#96623c", "#4f3222"
    G = 440
    with a.part():
        for x, k in ((250, -1), (316, 0), (382, 1)):
            a.sil(taper([(x, 340, x + k * 6, 380, x + k * 12 - 6, 410, x + k * 14 - 22, 430)], 26, 14), SHD)
    with a.part():
        a.sil("M176 322 C168 222 246 172 332 178 C418 184 462 250 452 330 C402 358 250 360 176 322 Z", SH)
        a.blob("M176 322 C170 250 206 200 260 184 C248 232 246 300 258 348 C224 344 196 334 176 322 Z", "#7d5238")
        a.ink([(262, 184, 248, 232, 246, 300, 258, 350)], 8, a=1, b=1)
        a.ink([(330, 180, 380, 190, 424, 222, 446, 268)], 7, a=0, b=0, col=SHD)
    horn = [(168, 282, 128, 246, 104, 196, 108, 140)]
    with a.part():
        a.sil(taper([(236, 208, 226, 186, 212, 172, 196, 166)], 24, 10), HN)
        a.sil(taper(horn, 44, 30, cap=False), HN)
        a.sil(taper([(107, 152, 102, 130, 92, 114, 76, 106)], 30, 18), HN)
        a.sil(taper([(107, 152, 112, 128, 124, 112, 142, 104)], 30, 18), HN)
    a.sil("M160 244 C206 244 234 272 234 306 C234 342 204 364 160 364 C116 364 86 342 86 306 C86 272 114 244 160 244 Z", HD)
    b_face(a, 160, 306, 32, 13, cheek=(50, 26), mouth=22, mw=10)
    a.shine("M356 212 C388 220 414 242 426 272")
    return a


@word
def tentoumushi():
    a = Art()
    RD, RD_D, BLK = "#e8493f", "#cf3a35", "#3b2f2a"
    cx = 256
    with a.part():
        for s in (-1, 1):
            for y, dx, dy in ((250, 150, -22), (330, 164, 6), (404, 140, 34)):
                a.sil(taper([(cx + s * 100, y, cx + s * 124, y, cx + s * (dx - 12), y + dy * 0.6, cx + s * dx, y + dy)], 22, 14), BLK)
    b_antennae(a, cx, (272, 136, 280, 108, 296, 92, 314, 86), r=9)
    with a.part():
        a.sil("M256 184 C338 184 392 244 392 320 C392 398 334 450 256 450 C178 450 120 398 120 320 "
              "C120 244 174 184 256 184 Z", RD)
        a.blob("M146 390 C180 436 250 452 300 442 C340 434 368 412 382 384 C350 424 300 436 256 436 C212 436 172 420 146 390 Z", RD_D)
        a.ink([(256, 196, 256, 280, 256, 360, 256, 449)], 8, a=1, b=1)
        a.ellipse(cx, 252, 22, 21, BLK, sw=0, stroke="none")
        for x, y, r in ((70, 296, 23), (92, 372, 19), (42, 420, 15)):
            for s in (-1, 1):
                a.ellipse(cx + s * x, y, r, r, BLK, sw=0, stroke="none")
    a.sil("M256 116 C308 116 338 146 338 182 C338 214 302 232 256 232 C210 232 174 214 174 182 C174 146 204 116 256 116 Z", "#4a4458")
    b_face(a, cx, 174, 34, 13, cheek=(60, 26), white=True, mouth=27, mw=10, col=WHITE)
    a.shine("M150 306 C150 268 166 240 190 224")
    return a


@word
def katatsumuri():
    a = Art()
    SK, SK_D, SHL, SPI = "#f5dfb2", "#e6c98f", "#f4a261", "#d9742e"
    with a.part():
        for s in (-1, 1):
            st = [(146 + s * 22, 300, 146 + s * 24, 262, 146 + s * 36, 230, 146 + s * 44, 204)]
            a.sil(taper(st, 24, 18, cap=False), SK)
            a.sil_ellipse(146 + s * 46, 198, 18, 17, SK)
    with a.part():
        a.sil("M72 420 C64 346 92 286 146 286 C194 286 218 320 222 358 C226 386 250 398 290 398 L420 398 "
              "C466 400 500 430 504 458 L114 458 C88 458 74 444 72 420 Z", SK)
        a.blob("M104 458 L504 458 C500 446 494 438 486 430 C380 440 200 440 84 432 C88 446 94 454 104 458 Z", SK_D)
    with a.part():
        a.sil("M322 138 C394 138 446 192 446 266 C446 340 392 392 320 392 C248 392 196 340 196 266 "
              "C196 192 250 138 322 138 Z", SHL)
        a.blob("M214 320 C240 372 300 392 350 382 C396 372 430 336 442 296 C420 344 372 370 320 370 C272 370 236 350 214 320 Z", "#e88d49")
        sp = b_spiral(324, 270, 10, 88, 2.1, 200)
        for i, c in enumerate(sp):
            a.ink([c], 13, a=0 if i == 0 else 1, b=0 if i == len(sp) - 1 else 1, col=SPI)
    b_face(a, 146, 344, 25, 12, cheek=(44, 22), mouth=20, mw=9)
    a.shine("M250 196 C266 172 294 158 324 156")
    return a


@word
def momo():
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    with a.part():
        a.sil(d_leaf(232, 424, 70, 440, 96, -0.3), LEAF)
        a.sil(d_leaf(280, 424, 442, 440, 96, 0.3), LEAF)
        d_vein(a, 190, 428, 70, 440, LEAF_D, t0=0, t1=0.7)
        d_vein(a, 322, 428, 442, 440, LEAF_D, t0=0, t1=0.7)
    body = ("M256 96 C290 138 420 170 420 290 C420 388 340 446 256 446 C172 446 92 388 92 290 "
            "C92 170 222 138 256 96 Z")
    with a.part():
        a.sil(body, "#fcc9bf")
        a.blob(d_rim(body, 50, 80, 48), "#f8a4aa")
        a.ink([(256, 98, 232, 190, 234, 330, 262, 440)], 9, a=1, b=0, col="#de7482")
    a.shine("M130 290 C126 244 146 206 182 184", sw=9)
    return a


@word
def budou():
    import math
    a = Art()
    PU, PUD, LEAF = "#a46bd0", "#8a4fbc", "#6fbd5c"
    a.sil(taper([(256, 176, 252, 134, 262, 104, 290, 80)], 16, 20), "#8a6a3a")
    with a.part():
        a.sil("M290 96 C318 46 398 44 436 84 C420 142 340 156 290 96 Z", LEAF)
        d_vein(a, 294, 98, 428, 86, "#4f9e48", t1=0.76, bow=-0.05)
    R = 45
    rows = [(176, (176, 256, 336)), (240, (136, 216, 296, 376)), (304, (176, 256, 336)), (368, (216, 296)), (432, (256,))]
    gr = [(x, y) for y, xs in reversed(rows) for x in xs]
    with a.part():
        for x, y in gr:
            a.sil(d_circ(x, y, R), PU)
        for i, (x, y) in enumerate(gr):
            c = d_circ(x, y, R)
            a.blob(c, PU)
            a.blob(d_rim(c, 55, 85, 13, inset=0), PUD)
            a.dot(x - 15, y - 17, 8, "#c7a0ea")
            step = 5
            cov = []
            for k in range(360 // step):
                t = math.radians(k * step)
                px, py = x + (R + 5) * math.cos(t), y + (R + 5) * math.sin(t)
                cov.append(any((px - gx) ** 2 + (py - gy) ** 2 < R * R for gx, gy in gr[:i]))
            m = len(cov)
            if not any(cov) or all(cov):
                continue
            s0 = next(k for k in range(m) if cov[k] and not cov[k - 1])
            k = 0
            while k < m:
                if cov[(s0 + k) % m]:
                    j = k
                    while j < m and cov[(s0 + j) % m]:
                        j += 1
                    a.ink(d_arc(x, y, R - 3, (s0 + k) * step, (s0 + j - 1) * step), 7, a=0.7, b=0.7)
                    k = j
                else:
                    k += 1
    return a


@word
def suika():
    a = Art()
    with a.part():
        a.sil("M56 180 A200 200 0 0 0 456 180 Z", "#4f9a4a")
        a.blob("M77 180 A179 179 0 0 0 435 180 Z", "#f1f6d8")
        a.blob("M94 180 A162 162 0 0 0 418 180 Z", "#ec4b52")
        a.blob("M99.5 222 A162 162 0 0 0 412.5 222 A200 200 0 0 1 99.5 222 Z", "#d83d48")
    seed = lambda x, y: "M%d %d C%d %d %d %d %d %d C%d %d %d %d %d %d Z" % (
        x, y - 18, x + 12, y - 4, x + 10, y + 14, x, y + 20, x - 10, y + 14, x - 12, y - 4, x, y - 18)
    for x, y in ((186, 216), (256, 246), (326, 216), (220, 282), (292, 282)):
        a.blob(seed(x, y), EYE)
        a.dot(x - 3, y - 6, 2.5, "#8a7a72")
    a.shine("M116 204 C122 232 136 256 156 274", sw=9)
    return a


@word
def kuri():
    a = Art()
    body = ("M256 70 C286 90 312 120 350 160 C410 216 430 300 396 372 C368 430 316 452 256 452 "
            "C196 452 144 430 116 372 C82 300 102 216 162 160 C200 120 226 90 256 70 Z")
    with a.part():
        a.sil(body, "#9a5a30")
        a.blob(d_rim(body, 20, 70, 30), "#82481f")
        # the pale, rough bottom of a chestnut, with a wavy top edge
        a.blob("M124 376 C160 352 190 394 224 368 C250 348 270 394 300 368 C330 348 360 384 390 366 "
               "C366 426 316 449 256 449 C196 449 148 426 124 376 Z", "#e8c493")
        a.blob("M300 444 C340 434 370 408 388 370 C378 392 350 418 300 432 Z", "#d6ac74")
        a.blob("M256 74 C264 88 274 100 286 112 C270 118 242 118 226 112 C238 100 248 88 256 74 Z", "#6b3c1e")
    a.shine("M148 262 C146 228 162 198 188 178", sw=9)
    return a


@word
def dango():
    a = Art()
    a.sil(taper([(336, 56, 284, 190, 228, 336, 174, 474)], 13, 13), "#e0bb85")
    for x, y, c, cd in ((212, 374, "#a8d98a", "#8cc56e"), (256, 262, "#fffaf0", "#ebe2cf"), (300, 150, "#f7a8c0", "#ee8aa9")):
        with a.part():
            d = d_circ(x, y, 70, 68)
            a.sil(d, c)
            a.blob(d_rim(d, 55, 75, 22), cd)
    a.shine("M256 124 C266 106 284 96 302 96", sw=9)
    a.shine("M212 236 C222 220 238 210 254 208", sw=8)
    a.shine("M168 348 C178 332 194 322 210 320", sw=8)
    return a


@word
def senbei():
    a = Art()
    import math
    R = 190
    body = d_circ(256, 256, R)
    with a.part():
        a.sil(body, "#dc9a4c")
        a.blob(d_circ(256, 256, R - 20), "#f0bd75")
        for x, y, rx, ry in ((150, 200, 34, 24), (360, 330, 40, 28), (150, 330, 26, 20), (368, 176, 28, 22)):
            a.blob(d_circ(x, y, rx, ry), "#e8ad62")
        for x, y in ((140, 250), (182, 372), (356, 380), (338, 136), (106, 300), (404, 258), (168, 150)):
            a.dot(x, y, 7, "#c98a42")
        a.blob(d_rim(body, 45, 70, 20), "#c98540")
        x1, x2 = 196, 316
        h = lambda x: math.sqrt(R * R - (x - 256) ** 2)
        a.blob(f"M{x1} {256 - h(x1):.1f} A{R} {R} 0 0 1 {x2} {256 - h(x2):.1f} L{x2} {256 + h(x2):.1f} A{R} {R} 0 0 1 {x1} {256 + h(x1):.1f} Z",
               "#34423a")
        for x in (226, 256, 286):
            a.ink([(x, 104, x + 3, 200, x - 3, 310, x, 408)], 6, a=0, b=0, col="#50655a")
    a.shine("M116 216 C128 176 156 144 196 126", sw=9)
    return a


@word
def wataame():
    a = Art()
    import math
    a.sil("M245 250 L267 250 L265 480 C265 490 247 490 247 480 Z", "#f4e3c4")
    cx, cy = 256, 172
    angs = [-90, -50, -8, 36, 74, 112, 150, 192, 232]
    rad = [124, 132, 128, 132, 120, 118, 132, 128, 132]
    pts = [(cx + r * math.cos(math.radians(t)), cy + r * 0.9 * math.sin(math.radians(t))) for t, r in zip(angs, rad)]
    n = len(pts)
    d = f"M{pts[0][0]:.1f} {pts[0][1]:.1f} "
    for i in range(n):
        p, q = pts[i], pts[(i + 1) % n]
        rr = math.hypot(q[0] - p[0], q[1] - p[1]) * 0.6
        d += f"A{rr:.1f} {rr:.1f} 0 0 1 {q[0]:.1f} {q[1]:.1f} "
    with a.part():
        a.sil(d + "Z", "#f9b8d2")
        a.blob(d_circ(288, 200, 72, 60), "#f6a5c6")
        a.blob(d_circ(254, 168, 84, 68), "#f9b8d2")
        a.blob(d_circ(214, 128, 60, 44), "#fccbdf")
        a.ink(d_arc(266, 176, 62, 200, 520, r1=10), 9, a=0, b=0, col="#ee8db6")
        a.ink([(152, 196, 168, 240, 214, 262, 262, 250)], 9, a=0, b=0, col="#ee8db6")
        a.ink([(316, 80, 352, 96, 372, 130, 370, 164)], 9, a=0, b=0, col="#ee8db6")
    a.shine("M166 132 C180 104 206 86 236 80", sw=9)
    return a


@word
def onigiri():
    a = Art()
    body = ("M256 84 C292 84 312 118 362 198 C412 278 432 340 426 386 C420 424 392 436 360 436 L152 436 "
            "C120 436 92 424 86 386 C80 340 100 278 150 198 C200 118 220 84 256 84 Z")
    with a.part():
        a.sil(body, "#fffdf6")
        a.blob(d_rim(body, 20, 75, 30), "#ece5d0")
        for x, y, g in ((226, 186, 30), (286, 214, -30), (196, 258, -20), (316, 276, 30), (256, 150, 0), (140, 330, 30), (372, 344, -30)):
            d_grain(a, x, y, g)
        a.sil("M170 322 C170 304 180 296 196 296 L316 296 C332 296 342 304 342 322 L346 436 L166 436 Z", "#2f4a3a")
        a.blob("M316 296 C332 296 342 304 342 322 L346 436 L318 436 C322 390 320 340 312 296 Z", "#263d30")
        a.ink([(190, 330, 192, 360, 192, 390, 190, 418)], 7, a=0, b=0, col="#4a6a56")
    a.shine("M170 240 C192 196 214 154 240 122", sw=9)
    return a


@word
def sushi():
    a = Art()
    rice = "M120 290 C70 290 70 440 130 440 L382 440 C442 440 442 290 392 290 Z"
    with a.part():
        a.sil(rice, "#fffdf6")
        a.blob(d_rim(rice, 50, 70, 24), "#ece5d0")
        for x, y, g in ((142, 384, -30), (204, 410, 20), (270, 388, -25), (330, 412, 25), (384, 380, -30), (112, 410, 20)):
            d_grain(a, x, y, g)
    fish = "M54 270 C54 190 170 160 256 168 C342 160 458 190 458 270 C458 330 400 346 256 346 C112 346 54 330 54 270 Z"
    with a.part():
        a.sil(fish, "#ea5560")
        a.blob(d_rim(fish, 70, 80, 22), "#d2414e")
        for c in ([(160, 196, 176, 240, 168, 286, 140, 322)], [(250, 182, 270, 232, 264, 288, 238, 334)], [(346, 190, 366, 236, 362, 286, 338, 330)]):
            a.ink(c, 15, a=0.5, b=0.5, col="#f7a3a6")
    a.shine("M90 252 C92 224 114 204 148 194", sw=9)
    return a


@word
def udon():
    a = Art()
    BOWL = "#fffdf6"
    for c in ([(384, 36, 356, 96, 326, 160, 300, 216)], [(426, 54, 396, 110, 364, 166, 336, 218)]):
        a.sil(taper(c, 14, 12), "#d9a05f")
    a.sil(d_circ(256, 246, 204, 40), "#e9b36a")
    # noodles heaped up in the soup
    with a.part():
        a.sil("M100 252 C90 204 148 170 198 186 C226 148 302 148 328 186 C378 170 426 206 414 252 "
              "C380 276 136 276 100 252 Z", "#fbf0d4")
        for k in (0, 1, 2):
            o = k * 17
            a.ink([(116 + o, 250, 122 + o, 206 + o * 0.6, 196 - o * 0.3, 190 + o, 222 - o * 0.5, 236), (222 - o * 0.5, 236, 236, 262 - o * 0.3, 276, 262 - o * 0.5, 292 - o * 0.4, 240)], 8, a=0.3, b=0, col="#cfa968")
            a.ink([(404 - o, 244, 404 - o, 204 + o * 0.5, 350, 182 + o, 322 + o * 0.3, 216), (322 + o * 0.3, 216, 312, 232, 300, 246, 286 + o, 262)], 8, a=0.3, b=0, col="#cfa968")
            a.ink([(222 + o * 0.5, 178 + o * 0.9, 250, 160 + o, 286, 160 + o, 310 - o * 0.5, 182 + o * 0.9)], 8, a=0, b=0, col="#cfa968")
    # fish cake and green onion
    import math
    pts = [(190 + (36 if i % 2 == 0 else 31) * math.cos(i * math.pi / 8), 206 + (36 if i % 2 == 0 else 31) * math.sin(i * math.pi / 8)) for i in range(16)]
    with a.part(ow=9):
        a.sil(smooth(pts), "#fffdf6")
        a.ink(d_arc(190, 206, 20, 0, 500, r1=3), 7, a=0.6, b=0.6, col="#f58fb4")
    for x, y in ((292, 180), (334, 206), (258, 228)):
        with a.part(ow=8):
            a.sil(d_circ(x, y, 12), "#6fbd5c")
            a.dot(x, y, 5, "#d3efc2")
    body = ("M52 246 C52 268.1 143.3 286 256 286 C368.7 286 460 268.1 460 246 C460 372 384 446 256 446 "
            "C128 446 52 372 52 246 Z")
    with a.part():
        a.sil("M198 430 L314 430 L308 464 C308 470 204 470 204 464 Z", BOWL)
        a.sil(body, BOWL)
        a.blob(d_rim(body, 55, 55, 26), "#ebe4d2")
        a.blob("M66 310 C140 342 372 342 446 310 C440 332 436 342 430 354 C360 382 152 382 82 354 C76 342 72 332 66 310 Z", "#4fa8e0")
        a.blob("M200 448 L312 448 L308 464 C308 470 204 470 204 464 Z", "#ebe4d2")
    a.shine("M82 320 C92 362 116 392 148 410", sw=9)
    return a


# ------------------------------------------------------------- water life --
def sea_face(a, cx, cy, gap=44, r=14, mouth=True, blush_dx=None):
    """Dot eyes, smile and cheeks for the sea creatures."""
    for s in (-1, 1):
        x = cx + s * gap
        a.ellipse(x, cy, r, r * 1.2, EYE, sw=0, stroke="none")
        a.dot(x + 4, cy - 6, r * 0.38, "#ffffff")
        a.ellipse(cx + s * (blush_dx or gap + 38), cy + 30, 14, 9, CHEEK, sw=0, stroke="none",
                  **{"fill-opacity": "0.7"})
    if mouth:
        a.path(f"M{cx-12} {cy+22} C{cx-5} {cy+32} {cx+5} {cy+32} {cx+12} {cy+22}", sw=7)


@word
def tako():
    a = Art()
    R, RD, RL = "#ef5f55", "#d9463f", "#f9a39a"
    cx = 256
    m = lambda q, s: tuple((cx + s * (v - cx)) if i % 2 == 0 else v for i, v in enumerate(q))
    back = [[(336, 300, 342, 360, 356, 420, 392, 428), (392, 428, 418, 432, 428, 404, 408, 398)],
            [(380, 268, 430, 290, 462, 296, 480, 268), (480, 268, 492, 246, 474, 228, 458, 240)]]
    front = [[(296, 300, 290, 370, 296, 428, 330, 440), (330, 440, 356, 448, 368, 420, 348, 412)],
             [(366, 284, 388, 340, 420, 372, 454, 364), (454, 364, 482, 356, 484, 324, 460, 324)]]
    with a.part():
        for leg in back:
            for s in (-1, 1):
                a.sil(taper([m(c, s) for c in leg], 50, 24), RD)
    with a.part():
        for leg in front:
            for s in (-1, 1):
                a.sil(taper([m(c, s) for c in leg], 54, 26), R)
        a.sil("M256 52 C364 52 406 132 398 216 C394 264 372 300 346 324 L166 324 C140 300 118 264 114 216 "
              "C106 132 148 52 256 52 Z", R)
        a.ink([(256, 326, 256, 350, 256, 372, 256, 392)], 9, a=1, b=0)
        for x, y in ((190, 112), (326, 104), (356, 170)):
            a.ellipse(x, y, 10, 9, RD, sw=0, stroke="none")
    b_face(a, cx, 222, 56, 18, cheek=(98, 34))
    a.path("M244 250 C244 240 268 240 268 250 C268 262 244 262 244 250 Z", fill=RD, sw=7)
    a.shine("M160 160 C162 118 186 92 220 80")
    return a


@word
def ika():
    a = Art()
    WH, SH, PK = "#fffaf6", "#f1ddd8", "#f9c3cb"
    cx = 256
    m = lambda q, s: tuple((cx + s * (v - cx)) if i % 2 == 0 else v for i, v in enumerate(q))
    with a.part():
        # two long feeding arms with a leaf-shaped club (shadow colour, behind)
        for s in (-1, 1):
            a.sil(taper([m((296, 336, 338, 358, 322, 394, 356, 412), s), m((356, 412, 380, 426, 388, 440, 394, 460), s)],
                        26, 14, cap=False), SH)
            a.sil(mirror("M382 446 C394 434 416 444 422 466 C428 488 424 504 416 514 C400 508 382 490 378 470 "
                         "C376 460 376 452 382 446 Z", cx) if s < 0 else
                  "M382 446 C394 434 416 444 422 466 C428 488 424 504 416 514 C400 508 382 490 378 470 "
                  "C376 460 376 452 382 446 Z", SH)
    with a.part():
        # five short soft arms, waving and spread out
        for dx in (-54, -27, 0, 27, 54):
            x, ph = cx + dx, (1 if dx >= 0 else -1)
            a.sil(taper([(x, 334, x + 12 * ph + dx * 0.2, 366, x - 12 * ph + dx * 0.5, 398, x + dx * 0.7, 426),
                         (x + dx * 0.7, 426, x + dx * 0.8 + 10 * ph, 442, x + dx * 0.95 + 8 * ph, 456, x + dx * 1.05 - 2 * ph, 470)],
                        32, 10), WH)
    with a.part():
        a.sil("M256 22 C300 56 366 112 384 158 C350 178 300 170 256 160 C212 170 162 178 128 158 "
              "C146 112 212 56 256 22 Z", PK)
        a.sil("M256 44 C312 56 342 140 342 240 C342 300 338 334 328 356 C300 368 212 368 184 356 "
              "C174 334 170 300 170 240 C170 140 200 56 256 44 Z", WH)
        a.blob("M186 350 C214 362 298 362 326 350 C330 338 334 326 336 312 C300 328 212 328 176 312 C178 326 182 338 186 350 Z", SH)
    b_face(a, cx, 250, 46, 16, cheek=(76, 30), mouth=22)
    a.shine("M204 120 C198 156 196 190 198 220")
    return a


@word
def kani():
    a = Art()
    R, RD, RL = "#ef5f55", "#d9463f", "#f9a39a"
    cx = 256
    m = lambda q, s: tuple((cx + s * (v - cx)) if i % 2 == 0 else v for i, v in enumerate(q))
    with a.part():
        for s in (-1, 1):
            for i in range(3):
                q = (390, 306 + i * 22, 452 + i * 2, 286 + i * 26, 494 - i * 8, 314 + i * 32, 502 - i * 14, 392 + i * 24)
                a.sil(taper([m(q, s)], 34, 12), RD)
    with a.part():
        for s in (-1, 1):
            a.sil(taper([m((380, 262, 426, 250, 448, 216, 446, 176), s)], 38, 32, cap=False), R)
            a.sil(b_claw(cx + s * 190, 190, s, 1.05), R)
    with a.part():
        a.sil("M256 186 C352 186 432 226 432 300 C432 370 356 410 256 410 C156 410 80 370 80 300 "
              "C80 226 160 186 256 186 Z", R)
        a.blob("M100 350 C150 396 230 408 256 408 C300 408 370 394 412 350 C380 384 310 394 256 394 C200 394 134 384 100 350 Z", RD)
    b_face(a, cx, 284, 60, 19, cheek=(108, 36), mouth=30, mw=14)
    a.shine("M128 286 C132 254 156 228 190 214")
    return a


@word
def kame():
    a = Art()
    G_, GD, SH, SHL, RIM, CR = "#9bd672", "#7cbd58", "#4fa85a", "#79c96a", "#3d9150", "#f6ecc0"
    G = 452
    with a.part():
        a.sil(limb_d([(250, 350), (244, 392), (244, 432)], [60, 52, 48], G, foot=10, h=20), GD)
        a.sil(limb_d([(376, 350), (372, 392), (372, 432)], [60, 52, 48], G, foot=10, h=20), GD)
    with a.part():
        a.sil(taper([(440, 366, 466, 370, 486, 384, 498, 404)], 28, 10), G_)
        a.sil(taper([(250, 340, 196, 344, 150, 320, 132, 270)], 84, 70, cap=False), G_)
        a.sil("M170 350 C230 384 400 384 452 350 C452 392 410 404 310 404 C230 404 176 392 170 350 Z", CR)
        a.sil(limb_d([(200, 360), (192, 398), (192, 432)], [66, 56, 52], G, foot=12, h=22), G_)
        a.sil(limb_d([(420, 360), (424, 398), (424, 432)], [66, 56, 52], G, foot=12, h=22), G_)
    with a.part():
        a.sil("M150 362 C146 262 216 190 306 190 C396 190 466 262 462 362 C420 392 192 392 150 362 Z", SH)
        a.blob("M150 362 C192 392 420 392 462 362 C462 350 461 340 459 330 C410 358 202 358 153 330 C151 340 150 350 150 362 Z", RIM)
        hexa = lambda x, y, r: "M" + " L".join(f"{x + dx * r:.0f} {y + dy * r:.0f}" for dx, dy in (
            (-1, 0), (-0.5, -0.84), (0.5, -0.84), (1, 0), (0.5, 0.84), (-0.5, 0.84))) + " Z"
        a.blob(hexa(306, 262, 44), SHL)
        a.blob(hexa(220, 302, 30), SHL)
        a.blob(hexa(392, 302, 30), SHL)
    a.sil("M128 140 C180 140 214 176 214 222 C214 270 178 300 128 300 C78 300 42 270 42 222 C42 176 76 140 128 140 Z", G_)
    b_face(a, 128, 226, 36, 16, mouth=26, mw=11)
    for s in (-1, 1):
        a.ellipse(128 + s * 58, 256, 15, 9, "#f3b3a4", sw=0, stroke="none")
    a.shine("M196 300 C202 262 226 232 258 216")
    return a


@word
def kujira():
    a = Art()
    B, BD, BELLY, SP = "#5ab0e8", "#3f97d0", "#eaf6ff", "#a6dcf8"
    with a.part():
        for s in (-1, 1):
            a.sil(taper([(214, 150, 214, 110, 214 + s * 14, 82, 214 + s * 50, 78),
                         (214 + s * 50, 78, 214 + s * 74, 76, 214 + s * 84, 96, 214 + s * 80, 112)], 26, 20), SP)
    with a.part():
        a.sil(taper([(392, 340, 440, 336, 464, 296, 464, 250)], 80, 34, cap=False), B)
        a.sil("M464 268 C430 256 408 226 412 192 C440 192 458 212 464 234 C470 212 488 192 516 192 "
              "C520 226 498 256 464 268 Z", B)
        a.sil("M60 304 C56 206 136 146 250 146 C356 146 416 214 420 296 C422 364 350 410 240 410 "
              "C136 410 62 374 60 304 Z", B)
        a.blob("M66 330 C130 372 330 384 416 322 C410 374 344 408 240 408 C144 408 78 380 66 330 Z", BELLY)
        for x in (150, 200, 250):
            a.ink([(x, 366 + (x - 150) * 0.06, x + 4, 378, x + 10, 390, x + 18, 400)], 6, a=0, b=0, col="#b9d6ea")
    a.sil("M286 318 C292 356 322 378 356 370 C352 342 328 318 286 318 Z", BD)
    b_face(a, 150, 270, 40, 16, cheek=(66, 32), mouth=26)
    a.shine("M118 214 C142 186 180 170 222 166")
    return a


@word
def kurage():
    a = Art()
    P, PD, PL = "#f9b6d2", "#f59ac0", "#fde3ee"
    cx = 256
    with a.part():
        for dx, ph in ((-104, 1), (-36, -1), (36, 1), (104, -1)):
            x = cx + dx
            a.sil(taper([(x, 280, x - 22 * ph, 320, x + 22 * ph, 352, x, 392),
                         (x, 392, x - 18 * ph, 424, x + 14 * ph, 444, x + 4 * ph, 470)], 26, 14), PL)
    with a.part():
        for dx, ph in ((-70, -1), (0, 1), (70, -1)):
            x = cx + dx
            a.sil(taper([(x, 280, x - 20 * ph, 316, x + 20 * ph, 344, x, 376),
                         (x, 376, x - 12 * ph, 396, x + 8 * ph, 410, x + 2 * ph, 424)], 34, 18), PD)
    with a.part():
        a.sil("M82 286 C82 160 160 68 256 68 C352 68 430 160 430 286 C430 304 414 312 398 304 "
              "C380 294 362 294 344 306 C324 318 306 318 286 306 C268 296 244 296 226 306 "
              "C206 318 188 318 168 306 C150 294 132 294 114 304 C98 312 82 304 82 286 Z", P)
        a.blob("M96 270 C150 290 362 290 416 270 C420 286 416 296 404 296 C380 286 360 288 344 298 C324 310 306 310 286 298 "
               "C268 288 244 288 226 298 C206 310 188 310 168 298 C150 288 130 286 108 296 C96 296 92 286 96 270 Z", PD)
        for x, y, r in ((330, 140, 11), (372, 200, 9), (300, 104, 8)):
            a.ellipse(x, y, r, r, PL, sw=0, stroke="none")
    b_face(a, cx, 206, 56, 18, cheek=(100, 34), mouth=28)
    a.shine("M150 150 C166 114 196 92 232 84")
    return a


@word
def iruka():
    a = Art()
    B, BD, BELLY = "#7fb0e0", "#6594c8", "#eef6ff"
    with a.part():
        a.sil("M122 378 C90 372 58 390 46 424 C78 432 108 422 126 404 C126 432 142 456 172 466 "
              "C182 434 168 402 144 384 Z", B)
        a.sil("M262 166 C270 122 298 96 338 92 C328 118 336 142 360 158 Z", B)
        a.sil("M104 376 C116 270 210 150 330 150 C392 150 432 180 446 214 C468 216 494 228 500 244 "
              "C494 258 468 264 448 262 C428 296 380 314 320 304 C240 290 176 324 142 394 Z", B)
        a.blob("M448 262 C428 296 380 314 320 304 C246 292 184 320 150 380 C176 310 244 262 320 264 "
               "C372 268 418 262 444 244 C452 248 452 256 448 262 Z", BELLY)
    a.sil("M370 274 C362 310 334 342 294 356 C290 330 304 296 334 270 Z", BD)
    a.path("M440 246 C458 252 480 250 496 244", sw=7)
    b_side_eye(a, 404, 212, 15, cheek=(-4, 34))
    a.shine("M200 232 C230 196 272 176 316 172")
    return a


@word
def sakana():
    a = Art()
    OR, ORD, BELLY = "#f8a640", "#ee8727", "#ffe6ae"
    with a.part():
        a.sil("M136 256 C100 226 64 196 42 150 C28 200 28 312 42 362 C64 316 100 286 136 256 Z", ORD)
        a.sil("M214 150 C226 102 276 76 330 88 C320 110 326 130 346 146 Z", ORD)
        a.sil("M268 366 C268 408 244 432 208 430 C216 404 224 388 230 364 Z", ORD)
        a.sil("M112 256 C130 180 210 134 296 134 C380 134 444 192 458 256 C444 320 380 378 296 378 "
              "C210 378 130 332 112 256 Z", OR)
        a.blob("M150 310 C200 350 340 362 440 296 C410 350 350 376 296 376 C234 376 180 350 150 310 Z", BELLY)
        a.ink([(330, 150, 304, 200, 304, 300, 330, 360)], 8, a=0, b=0, col=ORD)
        for x, y in ((250, 216), (212, 256), (250, 296), (176, 226)):
            a.ink([(x + 16, y - 20, x + 34, y - 8, x + 34, y + 10, x + 16, y + 22)], 7, a=0, b=0, col=ORD)
        a.ink([(60, 200, 80, 220, 96, 236, 112, 248)], 6, a=0, b=0, col="#d9741c")
        a.ink([(60, 312, 80, 292, 96, 276, 112, 264)], 6, a=0, b=0, col="#d9741c")
    a.sil("M300 262 C276 268 260 290 264 316 C292 314 312 296 316 274 Z", ORD)
    a.path("M430 270 C440 280 452 278 458 268", sw=7)
    b_side_eye(a, 388, 228, 17, cheek=(2, 44))
    a.shine("M160 220 C178 184 216 162 262 156")
    return a


@word
def hitode():
    a = Art()
    OR, ORL = "#f7954f", "#fbbf8a"
    import math
    cx, cy = 256, 276
    a.sil(b_star(cx, cy, 232, 122, tip=0), OR)
    for k in range(5):
        ang = math.radians(-90 + k * 72)
        for t, r in ((0.5, 10), (0.7, 8)):
            a.ellipse(cx + 226 * t * math.cos(ang), cy + 226 * t * math.sin(ang), r, r, ORL, sw=0, stroke="none")
    b_face(a, cx, 272, 36, 15, cheek=(62, 26), mouth=22)
    return a


@word
def kaeru():
    a = Art()
    G_, GD, BELLY = "#7fcb6c", "#5fb257", "#eaf7cc"
    cx = 256
    with a.part():
        sym(a, "M134 316 C76 316 48 368 58 408 C64 440 94 456 150 456 L204 456 C204 392 182 328 134 316 Z", G_, cx)
        for s in (-1, 1):
            a.ink([(cx + s * 190, 392, cx + s * 170, 372, cx + s * 150, 366, cx + s * 130, 372)], 8, a=0, b=1)
    with a.part():
        for s in (-1, 1):
            a.sil_ellipse(cx + s * 84, 142, 60, 58, G_)
        a.sil("M256 146 C356 146 422 194 422 262 C422 300 400 328 372 342 C392 374 388 420 360 442 "
              "C330 458 182 458 152 442 C124 420 120 374 140 342 C112 328 90 300 90 262 C90 194 156 146 256 146 Z", G_)
        a.blob("M256 332 C310 332 340 368 336 406 C330 438 300 450 256 450 C212 450 182 438 176 406 "
               "C172 368 202 332 256 332 Z", BELLY)
    for s in (-1, 1):
        x = cx + s * 62
        with a.part():
            a.sil(f"M{x - 30} 458 C{x - 36} 438 {x - 16} 426 {x} 426 C{x + 16} 426 {x + 36} 438 {x + 30} 458 "
                  f"C{x + 14} 462 {x - 14} 462 {x - 30} 458 Z", G_)
            for dx in (-10, 10):
                a.ink([(x + dx, 460, x + dx, 452, x + dx * 0.9, 446, x + dx * 0.8, 440)], 6, a=1, b=0)
    for s in (-1, 1):
        a.ellipse(cx + s * 84, 142, 36, 38, WHITE, sw=0, stroke="none")
        a.eye(cx + s * 84, 144, 21)
        a.ellipse(cx + s * 122, 268, 18, 11, "#f3b3a4", sw=0, stroke="none")
    a.path("M192 254 C222 292 290 292 320 254", sw=8)
    a.shine("M118 248 C122 222 138 204 160 196")
    return a


@word
def medaka():
    a = Art()
    BODYC, BACK, BELLY, FIN = "#f6d77c", "#e9bd55", "#fff8dc", "#fbe9ae"
    with a.part():
        a.sil("M128 262 C104 236 76 218 46 208 C36 244 36 284 46 318 C76 308 104 290 128 262 Z", FIN)
        a.sil("M196 196 C196 162 220 146 248 150 C240 166 242 180 252 190 Z", FIN)
        a.sil("M286 330 C276 366 226 382 172 366 C182 348 192 332 200 318 Z", FIN)
        a.sil("M100 264 C122 208 200 180 290 180 C372 180 438 210 458 250 C442 300 372 336 290 340 "
              "C200 342 122 318 100 264 Z", BODYC)
        a.blob("M128 222 C180 192 250 180 290 180 C350 180 404 196 440 222 C380 204 220 202 128 222 Z", BACK)
        a.blob("M140 302 C200 328 340 334 440 280 C410 322 350 338 290 340 C230 340 176 326 140 302 Z", BELLY)
        a.ink([(338, 196, 320, 230, 320, 290, 338, 326)], 7, a=0, b=0, col=BACK)
        a.ink([(60, 240, 76, 250, 92, 256, 106, 260)], 5, a=0, b=0, col=BACK)
        a.ink([(60, 288, 76, 280, 92, 272, 106, 266)], 5, a=0, b=0, col=BACK)
    a.sil("M300 268 C280 272 268 288 270 308 C292 306 308 294 312 278 Z", FIN)
    a.ellipse(396, 240, 27, 30, WHITE, sw=0, stroke="none")
    a.path("M436 252 C444 248 452 242 456 234", sw=7)
    b_side_eye(a, 396, 242, 19, cheek=(-6, 46))
    a.shine("M170 218 C200 204 240 198 280 198")
    return a


@word
def zarigani():
    a = Art()
    R, RD = "#e9503f", "#cf3a35"
    cx = 256
    m = lambda q, s: tuple((cx + s * (v - cx)) if i % 2 == 0 else v for i, v in enumerate(q))
    for s in (-1, 1):
        a.path(f"M{cx + s * 20} 130 C{cx + s * 30} 96 {cx + s * 56} 76 {cx + s * 92} 72", sw=7)
    with a.part():
        for s in (-1, 1):
            for i in range(3):
                y = 270 + i * 30
                a.sil(taper([m((300, y, 330, y - 4, 356, y + 8, 374, y + 34), s)], 24, 10), RD)
    with a.part():
        for s in (-1, 1):
            a.sil(taper([m((306, 214, 350, 204, 380, 176, 384, 144), s)], 32, 28, cap=False), R)
            a.sil(b_claw(cx + s * 128, 152, s, 0.92), R)
    with a.part():
        a.sil("M214 398 C188 424 178 448 186 468 C222 484 290 484 326 468 C334 448 324 424 298 398 Z", R)
        a.ink([(236, 420, 230, 440, 226, 456, 224, 474)], 7, a=0, b=1)
        a.ink([(276, 420, 282, 440, 286, 456, 288, 474)], 7, a=0, b=1)
    for y, w_ in ((372, 50), (338, 56), (302, 62)):
        a.sil(f"M{cx - w_} {y - 14} C{cx - w_ - 8} {y + 10} {cx - w_ + 2} {y + 34} {cx - w_ + 14} {y + 40} "
              f"L{cx + w_ - 14} {y + 40} C{cx + w_ - 2} {y + 34} {cx + w_ + 8} {y + 10} {cx + w_} {y - 14} Z", R)
    with a.part():
        a.sil("M256 104 C276 118 300 124 318 150 C344 180 348 220 342 252 C336 292 304 314 256 314 "
              "C208 314 176 292 170 252 C164 220 168 180 194 150 C212 124 236 118 256 104 Z", R)
        a.ink([(190, 270, 226, 290, 286, 290, 322, 270)], 7, a=0, b=0, col=RD)
    b_face(a, cx, 212, 36, 15, cheek=(64, 28), mouth=24, mw=11)
    a.shine("M196 186 C202 164 216 150 234 142")
    return a


@word
def otamajakushi():
    a = Art()
    BK, BKL = "#45424f", "#6a667a"
    tail = [(300, 280, 370, 240, 400, 340, 474, 296)]
    with a.part():
        a.sil(taper(tail, 116, 30), BKL)
        a.sil(taper(tail, 66, 12), BK)
        a.sil("M214 104 C300 104 358 166 354 244 C350 316 292 358 214 358 C136 358 80 316 76 244 "
              "C72 166 128 104 214 104 Z", BK)
    b_face(a, 214, 226, 58, 17, cheek=(100, 44), white=True, mouth=40, mw=14, col=WHITE)
    a.shine("M128 176 C144 144 174 124 210 118")
    return a


# --------------------------------------------------------------------- sky --
import math


def sky_face(a, cx, cy, gap=44, r=14, blush_dx=None, mouth=True, sleepy=False):
    """Dot eyes (or closed sleepy eyes), smile and cheeks for the sky things."""
    for s in (-1, 1):
        x = cx + s * gap
        if sleepy:
            a.path(f"M{x-r} {cy} C{x-r*0.5} {cy+r*1.1} {x+r*0.5} {cy+r*1.1} {x+r} {cy}", sw=7)
        else:
            a.ellipse(x, cy, r, r * 1.2, EYE, sw=0, stroke="none")
            a.dot(x + 4, cy - 6, r * 0.38, "#ffffff")
        a.ellipse(cx + s * (blush_dx or gap + 38), cy + 30, 14, 9, CHEEK, sw=0, stroke="none",
                  **{"fill-opacity": "0.7"})
    if mouth:
        a.path(f"M{cx-12} {cy+22} C{cx-5} {cy+32} {cx+5} {cy+32} {cx+12} {cy+22}", sw=7)


def cloud_shape(a, parts, base, fill, shade=None):
    """Outlined cloud from circles (cx, cy, r) and a flat-bottomed base (x0, x1, ytop, ybot)."""
    x0, x1, yt, yb = base
    for cx, cy, r in parts:
        a.circle(cx, cy, r, fill)
    a.rect(x0, yt, x1 - x0, yb - yt, fill, rx=(yb - yt) / 2)
    # cover inner outlines
    for cx, cy, r in parts:
        a.circle(cx, cy, r - 5.5, fill, sw=0, stroke="none")
    a.rect(x0 + 5, yt + 5, x1 - x0 - 10, yb - yt - 10, fill, rx=(yb - yt) / 2 - 5, sw=0, stroke="none")
    if shade:
        a.path(f"M{x0+30} {yb-14} C{x0+120} {yb-2} {x1-120} {yb-2} {x1-30} {yb-14}", stroke=shade, sw=10,
               **{"stroke-opacity": "0.9"})


CLOUD_PARTS = [(150, 270, 66), (236, 210, 88), (336, 244, 74), (400, 296, 52)]
CLOUD_BASE = (130, 420, 270, 350)


# --- batch E1 helpers begin ---
from lib import _tx_path as e1_tx


def e1_tf(d, s=1.0, dx=0.0, dy=0.0, flip=False):
    """A path scaled by s and moved by (dx, dy); flip mirrors it around x = 256 first."""
    return e1_tx(mirror(d, 256) if flip else d, s, dx, dy)


def e1_tc(c, s=1.0, dx=0.0, dy=0.0, flip=False):
    """The same for one cubic tuple (for ink())."""
    return tuple((s * ((512 - v) if flip else v) + dx) if i % 2 == 0 else (s * v + dy) for i, v in enumerate(c))


def e1_sub(c, t0, t1):
    """The piece of a cubic (x0, y0, ..., x3, y3) between t0 and t1 (so a blob can follow an outline exactly)."""
    def split(P, t):
        l = lambda p, q: (p[0] + (q[0] - p[0]) * t, p[1] + (q[1] - p[1]) * t)
        p01, p12, p23 = l(P[0], P[1]), l(P[1], P[2]), l(P[2], P[3])
        p012, p123 = l(p01, p12), l(p12, p23)
        m = l(p012, p123)
        return [P[0], p01, p012, m], [m, p123, p23, P[3]]
    P = [(c[0], c[1]), (c[2], c[3]), (c[4], c[5]), (c[6], c[7])]
    if t0 > 0:
        P = split(P, t0)[1]
    if t1 < 1:
        P = split(P, (t1 - t0) / (1 - t0))[0]
    return tuple(v for p in P for v in p)


def e1_rev(cubics):
    return [(c[6], c[7], c[4], c[5], c[2], c[3], c[0], c[1]) for c in reversed(cubics)]


def e1_pt(c, t):
    s = e1_sub(c, 0, t)
    return s[6], s[7]


def e1_d(cubics, close=True, start="M"):
    """A path through a chain of cubics (a straight line is put in where two of them do not meet)."""
    out, cur = [], None
    for c in cubics:
        if cur is None:
            out.append(f"{start}{c[0]:.1f} {c[1]:.1f}")
        elif abs(cur[0] - c[0]) > 0.05 or abs(cur[1] - c[1]) > 0.05:
            out.append(f"L{c[0]:.1f} {c[1]:.1f}")
        out.append(f"C{c[2]:.1f} {c[3]:.1f} {c[4]:.1f} {c[5]:.1f} {c[6]:.1f} {c[7]:.1f}")
        cur = (c[6], c[7])
    return " ".join(out) + (" Z" if close else "")


def e1_arc(cx, cy, rx, a0, a1, ry=None):
    """Cubics along a circle/ellipse arc from angle a0 to a1 (degrees; 0 = right, 90 = down)."""
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


def e1_line(x0, y0, x1, y1):
    return (x0, y0, x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3, x0 + (x1 - x0) * 2 / 3, y0 + (y1 - y0) * 2 / 3, x1, y1)


def e1_round_poly(pts, ks):
    """A polygon with rounded corners; ks = how far (0..0.5) each corner is cut back along its sides."""
    n = len(pts)
    out = []
    for i, v in enumerate(pts):
        p, q = pts[i - 1], pts[(i + 1) % n]
        k = ks[i % len(ks)]
        ax, ay = v[0] + (p[0] - v[0]) * k, v[1] + (p[1] - v[1]) * k
        bx, by = v[0] + (q[0] - v[0]) * k, v[1] + (q[1] - v[1]) * k
        out.append(f"{'M' if i == 0 else 'L'}{ax:.1f} {ay:.1f} Q{v[0]:.1f} {v[1]:.1f} {bx:.1f} {by:.1f}")
    return " ".join(out) + " Z"


def e1_star(cx, cy, ro, ri, rot=-90, k=0.24, ki=0.14):
    """A five-point star with soft tips."""
    pts = []
    for i in range(10):
        t = math.radians(rot + i * 36)
        r = ro if i % 2 == 0 else ri
        pts.append((cx + math.cos(t) * r, cy + math.sin(t) * r))
    return e1_round_poly(pts, [k, ki])


def e1_face(a, cx, cy, gap, r=15, cheek_dx=None, cheek_dy=None, mouth=True, sleepy=False):
    """The pilot face for sky things: same-size shiny eyes set wide and low, small smile, cheeks outside."""
    for s in (-1, 1):
        x = cx + s * gap
        if sleepy:
            a.ink([(x - r, cy - 2, x - r * 0.5, cy + r * 0.9, x + r * 0.5, cy + r * 0.9, x + r, cy - 2)], 7.5, a=0.7, b=0.7)
        else:
            a.eye(x, cy, r)
        a.cheek(cx + s * (cheek_dx or gap + r * 2.3), cy + (cheek_dy or r * 2.0), r * 1.05, r * 0.62)
    if mouth:
        w, y = r * 0.8, cy + r * 1.45
        a.path(f"M{cx - w:.1f} {y:.1f} C{cx - w * 0.45:.1f} {y + w * 0.85:.1f} {cx + w * 0.45:.1f} {y + w * 0.85:.1f} "
               f"{cx + w:.1f} {y:.1f}", sw=7)


# one cloud outline: three lobes that meet in soft notches, flat bottom
E1_CLOUD = ("M150 352 C96 352 70 320 74 284 C78 248 110 226 146 232 C148 176 194 138 250 140 "
            "C296 142 332 168 346 206 C390 196 432 228 432 272 C466 278 480 312 466 334 C456 350 438 352 416 352 Z")
E1_CLOUD_SHADE = "M150 352 L416 352 C438 352 456 350 466 334 C400 336 200 338 90 331.5 C103 344 123 352 150 352 Z"
E1_CLOUD_INK = [(146, 232, 158, 232, 168, 238, 174, 248), (346, 206, 332, 210, 322, 220, 318, 232),
                (432, 272, 420, 272, 410, 278, 404, 288)]


def e1_cloud(a, fill, shade, s=1.0, dx=0.0, dy=0.0, flip=False, ow=SW):
    with a.part(ow):
        a.sil(e1_tf(E1_CLOUD, s, dx, dy, flip), fill)
        a.blob(e1_tf(E1_CLOUD_SHADE, s, dx, dy, flip), shade)
        for c in E1_CLOUD_INK:
            a.ink([e1_tc(c, s, dx, dy, flip)], max(6, 9 * s), a=1, b=0)


def e1_mountain(a, L, T, R, fill, snow_t, n=5):
    """A mountain inside a part: left slope L, rounded top T, right slope R (cubics, left to right).
    The snow cap follows the outline down to snow_t of each slope; one see-through shade lies over the right face."""
    a.sil(e1_d([L, T, R]), fill)
    pl, pr = e1_pt(L, 1 - snow_t), e1_pt(R, snow_t)
    pts = []
    for i in range(2 * n + 1):
        f = i / (2 * n)
        dip = (10 if i % 2 else -14) if 0 < i < 2 * n else 0
        pts.append((pr[0] + (pl[0] - pr[0]) * f, pr[1] + (pl[1] - pr[1]) * f + dip))
    edge = smooth(pts, closed=False).replace("M", "L", 1)
    a.blob(e1_d([e1_sub(L, 1 - snow_t, 1), T, e1_sub(R, 0, snow_t)], close=False) + " " + edge + " Z", WHITE)
    mx, my = e1_pt(T, 0.56)
    bx = L[0] + (R[6] - L[0]) * 0.68
    back = (bx, R[7], bx - (bx - mx) * 0.12, my + (R[7] - my) * 0.6, mx + (bx - mx) * 0.3, my + (R[7] - my) * 0.25, mx, my)
    a.blob(e1_d([e1_sub(T, 0.56, 1), R, back]), "#2f5fa8", **{"fill-opacity": "0.2"})


def e1_drop(a, x, y):
    with a.part(9):
        a.sil(f"M{x} {y} C{x-6} {y+26} {x-26} {y+44} {x-26} {y+66} C{x-26} {y+86} {x-12} {y+98} {x} {y+98} "
              f"C{x+12} {y+98} {x+26} {y+86} {x+26} {y+66} C{x+26} {y+44} {x+6} {y+26} {x} {y} Z", "#5ab4ea")
        a.blob(f"M{x} {y+98} C{x+12} {y+98} {x+26} {y+86} {x+26} {y+66} C{x+18} {y+80} {x+6} {y+89} {x-8} {y+92} "
               f"C{x-5} {y+96} {x-2} {y+98} {x} {y+98} Z", "#3f9ad6")
        a.ink([(x - 9, y + 46, x - 15, y + 56, x - 15, y + 66, x - 10, y + 74)], 7, col=WHITE)


def e1_stone(a, x, y, rx, ry):
    with a.part(9):
        a.sil(f"M{x-rx} {y+ry*0.3} C{x-rx} {y-ry*0.7} {x-rx*0.3} {y-ry} {x+rx*0.2} {y-ry*0.95} "
              f"C{x+rx*0.8} {y-ry*0.9} {x+rx} {y-ry*0.2} {x+rx} {y+ry*0.35} C{x+rx} {y+ry} {x-rx} {y+ry} {x-rx} {y+ry*0.3} Z", STONE)
        a.ink([(x - rx * 0.5, y - ry * 0.35, x - rx * 0.3, y - ry * 0.6, x, y - ry * 0.65, x + rx * 0.25, y - ry * 0.6)], 6, col=WHITE)


def e1_pad(a, cx, cy, rx, ry, a0):
    """A lily pad seen from above-front: an ellipse with a V cut at angle a0."""
    arc = e1_arc(cx, cy, rx, a0 + 22, a0 + 338, ry=ry)
    with a.part(9):
        a.sil(f"M{cx} {cy} L{arc[0][0]:.1f} {arc[0][1]:.1f} " + e1_d(arc, close=False, start="L") + " Z", LEAF1)
        for da in (120, 180, 240):
            t = math.radians(a0 + da)
            a.ink([e1_line(cx, cy, cx + rx * 0.72 * math.cos(t), cy + ry * 0.72 * math.sin(t))], 6, a=1, b=0, col=LEAF2)
# --- batch E1 helpers end ---


@word
def kumo():
    a = Art()
    e1_cloud(a, WHITE, "#cfe6f7")
    e1_face(a, 262, 282, 50, 16)
    a.shine("M190 196 C202 176 220 164 242 160")
    return a


@word
def niji():
    a = Art()
    cx, cy, R0, bw = 256, 392, 208, 30
    cols = ["#ee5b52", "#f7a94b", "#f6d36b", "#7cc36a", "#4fa8e0"]
    ri = R0 - bw * len(cols)
    ring = lambda ro: e1_d(e1_arc(cx, cy, ro, 180, 360) + e1_arc(cx, cy, ri, 360, 180))
    with a.part():
        a.sil(ring(R0), cols[0])
        for i in range(1, len(cols)):
            a.blob(ring(R0 - bw * i), cols[i])
    a.shine(e1_d(e1_arc(cx, cy, R0 - 13, 208, 250), close=False))
    e1_cloud(a, WHITE, "#cfe6f7", 0.5, -13, 270)
    e1_cloud(a, WHITE, "#cfe6f7", 0.5, 269, 270, flip=True)
    return a


@word
def ame():
    a = Art()
    e1_cloud(a, "#c9d9ea", "#a9bed4", 0.8, 35, -72)
    e1_face(a, 245, 152, 42, 14)
    a.shine("M186 86 C196 70 210 60 228 56")
    for x, y in ((170, 252), (250, 290), (330, 252)):
        e1_drop(a, x, y)
    return a


@word
def yuki():
    a = Art()
    ICE, ICE_L = "#a9d8f5", "#e6f4fd"
    cx = cy = 256
    arms, cores = [], []
    for ang in (90, 150, 210, 270, 330, 30):
        t = math.radians(ang)
        dx, dy = math.cos(t), math.sin(t)
        arms.append((e1_line(cx + dx * 40, cy + dy * 40, cx + dx * 214, cy + dy * 214), 30, 26))
        cores.append(e1_line(cx + dx * 96, cy + dy * 96, cx + dx * 204, cy + dy * 204))
        for k, ln in ((132, 62), (182, 42)):
            bx, by = cx + dx * k, cy + dy * k
            for sgn in (-1, 1):
                t2 = t + sgn * math.radians(52)
                arms.append((e1_line(bx, by, bx + math.cos(t2) * ln, by + math.sin(t2) * ln), 24, 22))
    with a.part():
        for c, w0, w1 in arms:
            a.sil(taper([c], w0, w1), ICE)
        for c in cores:
            a.ink([c], 8, col=ICE_L)
    hexa = [(cx + 92 * math.cos(math.radians(60 * i)), cy + 92 * math.sin(math.radians(60 * i))) for i in range(6)]
    with a.part():
        a.sil(e1_round_poly(hexa, [0.3]), WHITE)
        a.blob(e1_round_poly([(cx + (x - cx) * 0.82, cy + (y - cy) * 0.82) for x, y in hexa], [0.3]), ICE_L)
    e1_face(a, cx, cy - 8, 30, 12)
    a.shine("M212 214 C218 202 228 194 240 190", sw=6)
    return a


@word
def kaminari():
    a = Art()
    with a.part():
        a.sil("M300 180 L214 318 L266 318 L226 452 L342 292 L286 292 L332 180 Z", "#ffd84d")
        a.blob("M290 212 L232 306 L250 306 L302 212 Z", "#fff3b0")
        a.blob("M342 292 L226 452 L254 386 L320 292 Z", "#f7b731")
    e1_cloud(a, "#8c9db3", "#6f8099", 0.8, 35, -72)
    e1_face(a, 245, 152, 42, 14)
    for s in (-1, 1):
        x = 245 + s * 42
        a.ink([(x - s * 16, 126, x - s * 8, 127, x + s * 2, 130, x + s * 10, 134)], 7.5, a=0.6, b=0.6)
    a.shine("M186 86 C196 70 210 60 228 56")
    return a


@word
def kaze():
    a = Art()
    W1, W2, PUFF = "#8ec9f0", "#bfe3fa", "#e3f2fc"
    swirls = [
        ([(250, 196, 330, 196, 392, 196, 432, 188), (432, 188, 478, 178, 482, 122, 442, 118),
          (442, 118, 410, 116, 398, 152, 424, 160)], W1),
        ([(290, 262, 360, 258, 430, 262, 464, 282), (464, 282, 506, 308, 484, 362, 446, 350),
          (446, 350, 418, 340, 426, 306, 450, 310)], W2),
        ([(250, 322, 310, 326, 362, 344, 382, 374), (382, 374, 402, 412, 362, 440, 338, 416),
          (338, 416, 324, 398, 342, 380, 358, 392)], W1),
    ]
    for cub, col in swirls:
        with a.part(9):
            a.sil(taper(cub, 24, 13, n=72), col)
    with a.part():
        a.sil("M150 372 C104 372 76 338 84 300 C60 270 70 222 108 208 C112 160 160 128 206 140 "
              "C240 112 296 128 304 172 C340 184 350 232 326 258 C348 290 332 338 296 350 "
              "C286 366 266 372 246 372 Z", PUFF)
        for c in ((108, 208, 118, 204, 130, 206, 138, 212), (304, 172, 294, 172, 284, 176, 278, 184),
                  (296, 350, 290, 340, 282, 334, 272, 332)):
            a.ink([c], 9, a=1, b=0)
    cx, cy = 200, 244
    for s in (-1, 1):
        x = cx + s * 44
        a.ink([(x - 15, cy + 5, x - 8, cy - 9, x + 8, cy - 9, x + 15, cy + 5)], 7.5, a=0.7, b=0.7)
        a.cheek(cx + s * 78, cy + 36, 17, 10)
    a.ellipse(cx, cy + 46, 12, 15, "#d9645e", sw=7)
    a.shine("M118 236 C122 222 130 214 142 210")
    return a


@word
def taiyou():
    a = Art()
    cx = cy = 256
    with a.part():
        for i in range(12):
            t = math.radians(i * 30 - 90)
            ux, uy = math.cos(t), math.sin(t)
            px, py = -uy, ux
            tip = 222 if i % 2 == 0 else 200
            hw = 40 if i % 2 == 0 else 34
            b1 = (cx + ux * 112 + px * hw, cy + uy * 112 + py * hw)
            b2 = (cx + ux * 112 - px * hw, cy + uy * 112 - py * hw)
            tp = (cx + ux * tip, cy + uy * tip)
            t1 = (b1[0] + (tp[0] - b1[0]) * 0.72, b1[1] + (tp[1] - b1[1]) * 0.72)
            t2 = (b2[0] + (tp[0] - b2[0]) * 0.72, b2[1] + (tp[1] - b2[1]) * 0.72)
            a.sil(f"M{b1[0]:.1f} {b1[1]:.1f} L{t1[0]:.1f} {t1[1]:.1f} Q{tp[0]:.1f} {tp[1]:.1f} {t2[0]:.1f} {t2[1]:.1f} "
                  f"L{b2[0]:.1f} {b2[1]:.1f} Z", "#ffb347")
    with a.part():
        a.sil(e1_d(e1_arc(cx, cy, 128, 0, 360)), "#ffd84d")
        a.blob(e1_d(e1_arc(cx, cy, 128, -10, 110) + e1_arc(cx - 14, cy - 14, 126, 104, -4)), "#f9c22e")
    e1_face(a, cx, cy - 2, 48, 17)
    a.shine("M170 206 C182 178 206 160 236 154")
    return a


def star_path(cx, cy, ro, ri, rot=-90):
    pts = []
    for i in range(10):
        t = math.radians(rot + i * 36)
        r = ro if i % 2 == 0 else ri
        pts.append((cx + math.cos(t) * r, cy + math.sin(t) * r))
    return "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"


@word
def hoshi():
    a = Art()
    with a.part(12):
        a.sil(e1_star(256, 268, 226, 124), "#ffd84d")
        a.blob(e1_star(256, 262, 150, 84), "#ffe27a")
    e1_face(a, 256, 268, 46, 17)
    a.shine("M214 150 C222 132 234 116 248 104")
    return a


@word
def tsuki():
    a = Art()
    R1, c1 = 190, (240, 256)
    R2, c2 = 150, (345, 226)
    dx, dy = c2[0] - c1[0], c2[1] - c1[1]
    d = math.hypot(dx, dy)
    aa = (R1 * R1 - R2 * R2 + d * d) / (2 * d)
    h = math.sqrt(R1 * R1 - aa * aa)
    mx, my = c1[0] + aa * dx / d, c1[1] + aa * dy / d
    p1 = (mx + h * dy / d, my - h * dx / d)
    p2 = (mx - h * dy / d, my + h * dx / d)
    top, bot = (p1, p2) if p1[1] < p2[1] else (p2, p1)
    ang = lambda p, c: math.degrees(math.atan2(p[1] - c[1], p[0] - c[0])) % 360
    outer = e1_arc(c1[0], c1[1], R1, ang(top, c1), ang(bot, c1))          # round the left side
    inner = e1_arc(c2[0], c2[1], R2, ang(bot, c2), ang(top, c2))
    with a.part(12):
        a.sil(e1_d(outer + inner), "#ffe9a0")
        ab = ang(bot, c1)
        a.blob(e1_d(e1_arc(c1[0], c1[1], R1, 215, ab + 28) + e1_arc(c1[0] + 14, c1[1] - 12, R1 - 4, ab + 34, 210)), "#f7d886")
    for x, y, r in ((98, 352, 17), (160, 150, 13), (214, 398, 10)):
        a.ellipse(x, y, r, r * 0.9, "#f0cd72", sw=0, stroke="none")
    e1_face(a, 128, 246, 31, 14, cheek_dx=52, sleepy=True)
    for x, y, r, rot in ((420, 122, 34, -80), (456, 326, 24, -100)):
        with a.part(8):
            a.sil(e1_star(x, y, r, r * 0.55, rot), "#ffd84d")
    a.shine("M84 196 C92 164 108 140 130 124")
    return a


@word
def uchuujin():
    a = Art()
    G, GD, SUIT, SUIT_D = "#93d86f", "#74c255", "#a9b6f2", "#8695dc"
    cx, GY = 256, 478
    for s in (-1, 1):                         # antennae: stalk, then the ball over its end
        a.sil(taper([(cx + s * 52, 124, cx + s * 70, 100, cx + s * 88, 80, cx + s * 104, 58)], 14, 11), GD)
        a.sil(e1_d(e1_arc(cx + s * 108, 50, 21, 0, 360)), "#ffd84d")
        a.dot(cx + s * 108 - 6, 43, 5, WHITE)
    with a.part():                            # arms: one waves, one hangs
        a.sil(taper([(296, 384, 332, 398, 378, 390, 404, 350)], 38, 32), G)
        a.sil(taper([(216, 384, 184, 390, 164, 412, 162, 440)], 38, 32), G)
    with a.part():                            # suit and short legs in one piece
        a.sil("M200 362 C200 336 312 336 312 362 L318 440 C318 454 194 454 194 440 Z", SUIT)
        a.sil(limb_d([(228, 430), (226, 460)], [54, 46], GY, d=-1, foot=8, h=18), SUIT)
        a.sil(limb_d([(284, 430), (286, 460)], [54, 46], GY, d=1, foot=8, h=18), SUIT)
        a.blob("M194 460 C202 455 242 455 252 461 C254 472 250 478 240 478 L206 478 C194 478 190 470 194 460 Z", SUIT_D)
        a.blob(mirror("M194 460 C202 455 242 455 252 461 C254 472 250 478 240 478 L206 478 C194 478 190 470 194 460 Z", cx), SUIT_D)
        a.blob(e1_star(cx, 404, 22, 12), "#ffd84d")
        a.ink([(256, 479, 256, 468, 256, 458, 256, 446)], 8, a=1, b=0)
    HEADP = ("M256 100 C370 100 424 170 420 236 C416 306 340 354 256 354 C172 354 96 306 92 236 "
             "C88 170 142 100 256 100 Z")
    with a.part():
        a.sil(HEADP, G)
        a.blob("M108 290 C150 332 204 346 256 346 C308 346 362 332 404 290 C380 334 320 354 256 354 C192 354 132 334 108 290 Z", GD)
    for s in (-1, 1):                         # big almond eyes, the same on both sides
        a.blob(f"M{cx+s*30} 204 C{cx+s*58} 186 {cx+s*118} 198 {cx+s*128} 250 "
               f"C{cx+s*130} 284 {cx+s*84} 292 {cx+s*56} 270 C{cx+s*34} 252 {cx+s*26} 226 {cx+s*30} 204 Z", EYE)
        a.ellipse(cx + s * 84 + 8, 228, 14, 17, WHITE, sw=0, stroke="none")
        a.dot(cx + s * 84 - 12, 264, 6.5, WHITE)
        a.cheek(cx + s * 122, 300, 17, 10)
    a.path("M240 304 C247 314 265 314 272 304", sw=7)
    a.shine("M140 190 C152 160 182 138 220 130")
    return a

# -------------------------------------------------------------- plaything --
# こうえんで キャラクターが つかう もの（D173）。顔はつけない（にんぎょうだけ）。
WOOD_L = "#f7c98d"
SAND, SAND_D = "#f9e3a5", "#efcf7a"
STEEL, STEEL_D = "#dfe6ec", "#b9c4cf"
ORANGE, PURPLE = "#f7a94b", "#9b7fd1"


@word
def tsumiki():
    a = Art()
    GR, GR_D = "#7cc36a", "#62a853"

    def cube(x, y, col, dark):
        with a.part():
            a.sil(e2_rr(x, y, 160, 140, 18), col)
            a.blob(f"M{x} {y + 112} L{x + 160} {y + 112} L{x + 160} {y + 122} C{x + 160} {y + 132} {x + 152} {y + 140} {x + 142} {y + 140} "
                   f"L{x + 18} {y + 140} C{x + 8} {y + 140} {x} {y + 132} {x} {y + 122} Z", dark)

    cube(84, 330, RED, RED_D)
    cube(268, 330, BLUE, BLUE_D)
    a.dot(164, 394, 34, WHITE)
    a.blob(e2_rr(318, 364, 60, 58, 12), WHITE)
    with a.part():                                      # the arch block sits on both cubes
        a.sil("M194 188 L318 188 C330 188 336 194 336 206 L336 330 L300 330 C300 270 212 270 212 330 "
              "L176 330 L176 206 C176 194 182 188 194 188 Z", YEL)
        a.blob("M300 330 L336 330 L336 206 C336 198 333 192 328 190 C324 240 316 290 300 330 Z", "#e9bd3c")
    with a.part():                                      # roof
        a.sil("M256 84 L346 190 L166 190 Z", GR)
        a.blob("M256 84 L346 190 L300 190 C296 150 280 112 256 84 Z", GR_D)
    a.shine("M104 362 C104 350 112 346 124 346", sw=8)
    a.shine("M288 362 C288 350 296 346 308 346", sw=8)
    a.shine("M196 222 C196 212 202 208 212 208", sw=8)
    return a


@word
def koma():
    a = Art()
    TOP = "#ee6a62"
    with a.part():                                      # handle
        a.sil(e2_rr(232, 88, 48, 110, 16), WOOD)
        a.blob(e2_poly([(262, 92), (280, 100), (280, 198), (262, 198)]), WOOD_D)
    with a.part():                                      # tip
        a.sil("M236 380 L276 380 L262 462 C260 470 252 470 250 462 Z", "#b9c4cf")
        a.blob("M258 380 L276 380 L262 462 C260 468 257 468 256 466 Z", "#98a5b2")
    with a.part():                                      # body
        a.sil("M118 262 C118 204 192 182 256 182 C320 182 394 204 394 262 L394 296 "
              "C394 356 328 398 256 398 C184 398 118 356 118 296 Z", RED)
        a.blob("M118 262 C118 204 192 182 256 182 C320 182 394 204 394 262 C394 296 328 318 256 318 "
               "C184 318 118 296 118 262 Z", TOP)
        a.blob("M119 276 C166 316 346 316 393 276 L394 300 C394 306 393 312 392 317 C344 354 168 354 120 317 "
               "C119 312 118 306 118 300 Z", YEL)
        a.blob("M196 386 C240 398 300 394 340 370 C312 392 284 398 256 398 C234 398 214 394 196 386 Z", RED_D)
        a.ink([(119, 276, 166, 316, 346, 316, 393, 276)], 7, a=1, b=1)
        a.ink([(120, 317, 168, 354, 344, 354, 392, 317)], 7, a=1, b=1)
        a.blob("M196 230 C196 214 316 214 316 230 C316 246 196 246 196 230 Z", "#f6d36b")
        a.blob("M222 228 C222 220 290 220 290 228 C290 236 222 236 222 228 Z", TOP)
    a.shine("M150 250 C160 226 184 212 210 206")
    return a


@word
def kendama():
    a = Art()
    a.path("M352 334 C440 350 430 430 300 444", stroke="#8a6a50", sw=7)
    with a.part():                                      # handle and spike
        a.sil("M234 320 L278 320 C278 380 284 428 294 460 C298 474 288 484 274 484 L238 484 "
              "C224 484 214 474 218 460 C228 428 234 380 234 320 Z", WOOD)
        a.sil("M238 334 C242 296 250 262 256 240 C262 262 270 296 274 334 Z", WOOD)
        a.blob("M262 352 L278 352 C278 392 284 430 294 460 C298 474 288 484 274 484 L262 484 "
               "C270 444 266 396 262 352 Z", WOOD_D)
    with a.part():                                      # cross piece with a cup at each end
        a.sil("M148 290 C148 282 156 278 164 284 C190 304 222 312 256 312 C290 312 322 304 348 284 "
              "C356 278 364 282 364 290 L364 378 C364 386 356 390 348 384 C322 364 290 356 256 356 "
              "C222 356 190 364 164 384 C156 390 148 386 148 378 Z", WOOD_L)
        a.blob("M148 356 C190 340 222 334 256 334 C290 334 322 340 364 356 L364 378 C364 386 356 390 348 384 "
               "C322 364 290 356 256 356 C222 356 190 364 164 384 C156 390 148 386 148 378 Z", WOOD)
        e2_ink2(a, [(170, 290, 178, 320, 178, 348, 170, 378)], 6, 1, 1, col=WOOD_D)
    with a.part():                                      # ball on the spike
        a.sil_ellipse(256, 168, 86, 86, RED)
        a.blob("M338 144 C348 200 310 250 256 254 C296 240 326 200 322 150 C320 130 314 112 304 98 "
               "C322 108 334 124 338 144 Z", RED_D)
        a.blob("M232 250 C232 240 280 240 280 250 C272 254 264 254 256 254 C248 254 240 254 232 250 Z", "#8f2c27")
    a.shine("M200 136 C208 110 232 92 258 90")
    return a


@word
def fuusen():
    a = Art()

    def balloon(cx, cy, col, dark, s=1.0):
        w, h = 120 * s, 150 * s
        P = lambda u, v: f"{e2_f(cx + w * u)} {e2_f(cy + h * v)}"
        d = (f"M{P(0, -1)} C{P(0.9, -1)} {P(1, -0.2)} {P(0.62, 0.42)} C{P(0.4, 0.76)} {P(0.14, 0.9)} {P(0.08, 0.98)} "
             f"L{P(0.2, 1.12)} L{P(-0.2, 1.12)} L{P(-0.08, 0.98)} C{P(-0.14, 0.9)} {P(-0.4, 0.76)} {P(-0.62, 0.42)} "
             f"C{P(-1, -0.2)} {P(-0.9, -1)} {P(0, -1)} Z")
        with a.part():
            a.sil(d, col)
            a.blob(f"M{P(0.62, 0.42)} C{P(0.4, 0.76)} {P(0.14, 0.9)} {P(0.08, 0.98)} L{P(-0.08, 0.98)} "
                   f"C{P(0.12, 0.74)} {P(0.5, 0.5)} {P(0.84, -0.3)} C{P(0.9, -0.05)} {P(0.8, 0.16)} {P(0.62, 0.42)} Z", dark)
            a.ink([(cx - w * 0.07, cy + h * 0.99, cx - w * 0.02, cy + h * 1.01, cx + w * 0.02, cy + h * 1.01,
                    cx + w * 0.07, cy + h * 0.99)], 6, a=0.3, b=0.3)

    a.path("M344 276 C332 320 372 344 352 392 C344 412 348 430 356 446", sw=7)
    balloon(344, 180, BLUE, BLUE_D, 0.76)
    a.shine("M292 130 C298 108 314 94 334 90", sw=7)
    a.path("M190 380 C176 420 222 438 202 478 C198 486 198 492 200 498", sw=7)
    balloon(190, 214, RED, RED_D, 1.0)
    a.shine("M118 160 C126 124 152 100 186 94")
    return a


@word
def ningyou():
    a = Art()
    HAIR, HAIR_L, SKIN = "#3b3a45", "#5a5968", "#ffe3c9"
    with a.part():                                      # kimono
        a.sil("M256 256 C300 256 336 266 350 288 C374 322 390 360 390 392 C390 412 372 418 358 408 L352 402 "
              "L366 452 C368 464 360 472 348 472 L164 472 C152 472 144 464 146 452 L160 402 L154 408 "
              "C140 418 122 412 122 392 C122 360 138 322 162 288 C176 266 212 256 256 256 Z", RED)
        a.blob("M152 440 L360 440 L366 452 C368 464 360 472 348 472 L164 472 C152 472 144 464 146 452 Z", RED_D)
        for x, y in ((150, 356), (362, 356), (206, 424), (256, 446), (306, 424)):
            e2_blossom(a, x, y, 14)
        a.blob(e2_poly([(214, 262), (298, 262), (256, 340)]), WHITE)
        a.blob(e2_poly([(232, 262), (280, 262), (256, 308)]), "#f7a8b3")
        e2_line(a, 214, 262, 256, 340, 6, 1, 0.4)
        e2_line(a, 298, 262, 256, 340, 6, 1, 0.4)
        a.blob(e2_poly([(175, 352), (337, 352), (348, 394), (164, 394)]), YEL)
        a.blob(e2_poly([(171, 370), (341, 370), (343, 378), (169, 378)]), "#f6a04d")
        e2_ink2(a, [(160, 406, 162, 372, 172, 336, 190, 304)], 8, 1, 0)
        e2_line(a, 175, 352, 337, 352, 6)
        e2_line(a, 164, 394, 348, 394, 6)
    with a.part():                                      # bob hair and face in one part
        a.sil("M136 196 C126 94 194 54 256 54 C318 54 386 94 376 196 C374 240 362 270 350 282 "
              "L162 282 C150 270 138 240 136 196 Z", HAIR)
        a.sil("M256 96 C320 96 362 138 362 196 C362 252 318 290 256 290 C194 290 150 252 150 196 "
              "C150 138 192 96 256 96 Z", SKIN)
        a.blob("M146 206 C136 112 200 78 256 78 C312 78 376 112 366 206 C338 166 298 150 256 154 "
               "C214 150 174 166 146 206 Z", HAIR)
    a.shine("M184 118 C202 98 228 88 256 86", sw=7)
    e2_face(a, 256, 214, 48, 15, cheek_dx=76, cheek_dy=32)
    with a.part(ow=8):                                  # hair clip
        a.sil_ellipse(342, 118, 19, 19, "#ffd84d")
    e2_blossom(a, 342, 118, 22, col="#ffd84d", mid=RED)
    return a


@word
def taiko():
    a = Art()
    HEAD_D = "#f1d9b6"
    with a.part():                                      # legs
        for x in (112, 344):
            a.sil(e2_rr(x, 400, 56, 76, 14), WOOD)
            a.blob(e2_rr(x + 34, 404, 22, 72, 10), WOOD_D)
    with a.part():                                      # barrel
        a.sil("M108 190 C82 250 82 334 112 410 C150 434 362 434 400 410 C430 334 430 250 404 190 Z", RED)
        a.blob("M360 196 C388 250 390 340 366 424 C382 420 394 414 400 410 C430 334 430 250 404 190 Z", RED_D)
        for i in range(7):
            t = i / 6
            x = 132 + 248 * t
            dy = 20 * (1 - (2 * t - 1) ** 2)
            a.dot(x, 236 + dy, 9, YEL)
            a.dot(x, 376 + dy, 9, YEL)
    with a.part():                                      # drumhead
        a.sil_ellipse(256, 190, 150, 54, CREAM)
        a.blob("M132 204 C170 232 342 232 380 204 C352 250 160 250 132 204 Z", HEAD_D)
        a.ellipse(256, 188, 92, 28, HEAD_D, sw=0, stroke="none")
    a.sil(e2_cap(150, 62, 236, 176, 30, 24), WOOD)       # sticks
    a.sil(e2_cap(362, 62, 276, 176, 30, 24), WOOD)
    a.shine("M118 262 C112 300 114 340 124 374")
    return a


@word
def fue():
    a = Art()
    P = lambda t, off=0.0: (100 + 312 * t + off * 0.7071, 424 - 312 * t + off * 0.7071)
    S = lambda t0, t1: [e2_seg(*P(t0), *P(t1))]
    with a.part():
        a.sil(taper(S(0.16, 0.84), 56, 54, cap=False), CREAM)
        a.sil(taper(S(0.80, 1.02), 56, 34), BLUE)        # mouthpiece
        a.sil(taper(S(0.22, 0.0), 58, 82, cap=False), BLUE)   # bell end
        for t0, t1 in ((0.22, 0.80),):
            (x0, y0), (x1, y1) = P(t0, 14), P(t1, 14)
            (x2, y2), (x3, y3) = P(t1, 27), P(t0, 28)
            a.blob(e2_poly([(x0, y0), (x1, y1), (x2, y2), (x3, y3)]), "#f1dcbc")
        for t in (0.22, 0.80):
            (x0, y0), (x1, y1) = P(t, -29), P(t, 29)
            e2_line(a, x0, y0, x1, y1, 7)
        for t in (0.31, 0.40, 0.49, 0.58, 0.67):
            x, y = P(t, -3)
            a.dot(x, y, 11, EYE)
        (x0, y0), (x1, y1) = P(0.86, -4), P(0.91, -4)
        a.blob(e2_cap(x0, y0, x1, y1, 12), EYE)
    (x0, y0), (x1, y1) = P(0.30, -17), P(0.72, -17)
    a.shine(f"M{e2_f(x0)} {e2_f(y0)} L{e2_f(x1)} {e2_f(y1)}", sw=7)
    e2_note(a, 126, 214, 1.0, "#ee6a62")
    return a


@word
def suzu():
    a = Art()
    GOLD, GOLD_D = "#f7c948", "#e5a92d"
    with a.part():                                      # bell with its little loop
        a.sil(e2_rr(232, 172, 48, 60, 18), GOLD_D)
        a.sil_ellipse(256, 334, 134, 132, GOLD)
        a.blob("M384 300 C398 380 340 458 256 466 C324 446 368 384 364 308 C362 276 350 246 332 226 "
               "C360 242 378 268 384 300 Z", GOLD_D)
        a.blob("M124 352 C170 386 342 386 388 352 C389 358 390 364 390 370 C340 402 172 402 122 370 "
               "C122 364 123 358 124 352 Z", GOLD_D)
        a.blob("M228 398 C228 380 284 380 284 398 C284 412 270 416 262 418 L262 466 L250 466 L250 418 "
               "C242 416 228 412 228 398 Z", EYE)
    with a.part(ow=9):                                  # ribbon
        for d in ("M256 162 C226 110 160 104 158 142 C156 180 220 186 256 162 Z",
                  "M256 162 C286 110 352 104 354 142 C356 180 292 186 256 162 Z"):
            a.sil(d, RED)
        a.ink([(240, 160, 220, 150, 200, 146, 184, 148)], 6, a=1, b=0)
        a.ink([(272, 160, 292, 150, 312, 146, 328, 148)], 6, a=1, b=0)
    a.sil_ellipse(256, 162, 19, 18, RED_D)
    a.shine("M162 300 C172 266 198 242 230 234")
    return a


@word
def mokkin():
    a = Art()
    cols = [RED, ORANGE, YEL, GREEN, BLUE, PURPLE]
    with a.part():                                      # rails get closer to the right, like the bars
        a.sil(e2_cap(66, 214, 446, 266, 28), WOOD)
        a.sil(e2_cap(66, 376, 446, 324, 28), WOOD)
    with a.part():                                      # bars (one part: a single line between neighbours)
        for i, c in enumerate(cols):
            x = 84 + i * 62
            top = 150 + i * 16
            bot = 440 - i * 16
            a.sil(e2_rr(x, top, 52, bot - top, 16), c)
            a.blob(e2_rr(x + 36, top + 6, 16, bot - top - 12, 8), "#3b2f2a", fill_opacity="0.13")
            a.dot(x + 22, 217 + i * 8.5, 7, WHITE)
            a.dot(x + 22, 373 - i * 8.5, 7, WHITE)
    a.sil(e2_cap(330, 186, 420, 66, 16), WOOD)           # mallets
    a.sil(e2_cap(350, 210, 470, 122, 16), WOOD)
    a.sil_ellipse(424, 60, 30, 30, "#ee6a62")
    a.sil_ellipse(474, 118, 30, 30, BLUE)
    a.shine("M98 190 L98 260", sw=7)
    return a


@word
def nawatobi():
    a = Art()
    rope = [(150, 196, 96, 300, 110, 452, 256, 452), (256, 452, 402, 452, 416, 300, 362, 196)]
    with a.part():                                    # rope
        a.sil(taper(rope, 15, 15, n=64), RED)
    for s_ in (0, 1):                                 # handles, leaning out a little
        f = (lambda d: mirror(d)) if s_ else (lambda d: d)
        with a.part():
            a.sil(f(c_bar(120, 72, 150, 190, 46)), BLUE)
            a.blob(f("M99 70 C96 46 138 36 144 62 L154 100 L108 112 Z"), YEL)
        a.path(f("M114 136 L158 125"), stroke=BLUE_D, sw=6)
        a.path(f("M119 156 L163 145"), stroke=BLUE_D, sw=6)
    a.shine("M112 84 L120 112", sw=7)
    return a


@word
def tetsubou():
    a = Art()
    POST, POST_D, FOOT = BLUE, BLUE_D, "#8a8f98"
    # three posts, a high bar and a low bar
    with a.part():
        for x in (88, 256, 424):
            a.sil(c_circ(x, 450, 40, 13), FOOT)
    with a.part(8):                                   # bars (behind the posts)
        a.sil(c_bar(72, 140, 256, 140, 18), STEEL)
        a.sil(c_bar(256, 236, 440, 236, 18), STEEL)
    a.path("M100 136 L240 136 M270 232 L410 232", stroke=WHITE, sw=5, **{"stroke-opacity": "0.9"})
    for x, top in ((88, 110), (256, 110), (424, 206)):
        with a.part():
            a.sil(c_rpoly([(x - 16, top), (x + 16, top), (x + 16, 450), (x - 16, 450)], [14, 14, 4, 4]), POST)
            a.blob(c_rpoly([(x + 4, top + 6), (x + 15, top + 6), (x + 15, 449), (x + 4, 449)], [0, 8, 3, 0]), POST_D)
        a.path(f"M{x - 7} {top + 22} L{x - 7} {top + 120}", stroke=WHITE, sw=5, **{"stroke-opacity": "0.5"})
    return a


@word
def tobibako():
    a = Art()
    TOP, TOP_L, HOLE = "#b9754a", "#d99c70", "#b06a30"
    # tiers, bottom first; each is a little narrower than the one below
    for i in range(3, -1, -1):
        y = 186 + i * 68
        w0, w1 = 150 + i * 12, 162 + i * 12          # half widths at the top and bottom of the tier
        fill, shade = (WOOD_L, "#eeb878") if i % 2 == 0 else (WOOD, "#e3a257")
        with a.part():
            a.sil(c_rpoly([(256 - w0, y), (256 + w0, y), (256 + w1, y + 72), (256 - w1, y + 72)], 9), fill)
            a.blob(c_rpoly([(256 - w1 + 3, y + 56), (256 + w1 - 3, y + 56), (256 + w1 - 1, y + 71), (256 - w1 + 1, y + 71)], [0, 0, 7, 7]), shade)
        a.blob(c_rect(214, y + 22, 84, 26, 13), HOLE)
        a.blob(c_rpoly([(214, y + 22), (298, y + 22), (298, y + 34), (214, y + 34)], [13, 13, 0, 0]), "#8f5226")
    with a.part():                                    # cushion on the top
        a.sil("M100 190 C92 190 88 184 90 172 C96 110 150 82 256 82 C362 82 416 110 422 172 C424 184 420 190 412 190 Z", TOP)
        a.blob("M92 168 L420 168 C424 184 420 189 412 189 L100 189 C92 189 88 184 92 168 Z", "#a26238")
    a.path("M128 136 C170 106 342 106 384 136", stroke=TOP_L, sw=7)
    return a


@word
def burango():
    full, frame, seat, rope = swing_parts()
    return full


def swing_parts():
    """The whole swing, and the frame and the seat on their own (same fit, so they line up)."""
    def frame_part(a):
        with a.part():                                # the far legs
            for ax, bx in ((132, 204), (380, 308)):
                a.sil(c_bar(ax, 100, bx, 448, 24), RED_D)
        with a.part():                                # the beam and the near legs
            a.sil(c_bar(72, 100, 440, 100, 32), RED)
            for ax, bx in ((132, 62), (380, 450)):
                a.sil(c_bar(ax, 100, bx, 448, 26), RED)
        a.path("M92 93 L420 93", stroke=WHITE, sw=6, **{"stroke-opacity": "0.5"})

    def ropes_part(a, xs):
        with a.part(6):                               # ropes
            for x in xs:
                a.sil(c_bar(x, 100, x, 366, 6), "#b08a68")

    def seat_only(a):
        with a.part():
            a.sil(c_rect(194, 352, 124, 36, 14), YEL)
            a.blob(c_rpoly([(195, 374), (317, 374), (317, 387), (195, 387)], [0, 0, 13, 13]), "#eab94e")

    def hooks_part(a, xs):
        with a.part(7):
            for x in xs:
                a.sil(c_circ(x, 102, 10), STEEL)

    full = Art(); frame_part(full); ropes_part(full, (218, 294)); seat_only(full); hooks_part(full, (218, 294))
    frame = Art(); frame_part(frame)
    seat = Art(); seat_only(seat)                     # the seat on its own: it stays level and slides along the arc
    rope = Art(); ropes_part(rope, (218,)); hooks_part(rope, (218,))   # one rope with its hook; the app turns it about the hook
    return full, frame, seat, rope



def slide_art(chute_only=False):
    a = Art()
    if not chute_only:
        a.path("M78 136 L78 78 Q78 64 92 64 L184 64 Q198 64 198 78 L198 136", sw=11)   # rail
        with a.part(8):                               # rungs
            for y in (216, 282, 348, 414):
                a.sil(c_bar(96, y, 184, y, 8), "#e9b43a")
        with a.part():                                # posts
            for x in (92, 188):
                a.sil(c_bar(x, 160, x, 448, 22), YEL)
    return a


# the slide chute: cubic from the platform to the ground
SLIDE_CURVE = ((214, 170), (314, 200), (386, 330), (446, 404))


@word
def suberidai():
    a = slide_art()
    (x0, y0), (x1, y1), (x2, y2), (x3, y3) = SLIDE_CURVE
    chute = [(x0, y0, x1, y1, x2, y2, x3, y3), (x3, y3, x3 + 10, y3 + 5, x3 + 18, y3 + 5, 474, y3 + 5)]
    with a.part():
        a.sil(taper(chute, 40, 40, n=64), BLUE)
        a.sil(c_circ(x0, y0, 20), BLUE)
    a.blob(taper(chute, 16, 16, n=64), SKY)
    with a.part():                                    # platform, over the top of the chute
        a.sil(c_rect(66, 130, 168, 36, 12), RED)
        a.blob(c_rpoly([(67, 152), (233, 152), (233, 165), (67, 165)], [0, 0, 11, 11]), RED_D)
    return a


@word
def sunaba():
    a = Art()
    with a.part():                                    # wooden frame (back and sides), sand inside
        a.sil(c_rpoly([(108, 190), (404, 190), (456, 336), (56, 336)], [12, 12, 0, 0]), WOOD_D)
    with a.part(8):
        a.sil(c_rpoly([(132, 214), (380, 214), (424, 330), (88, 330)], [10, 10, 0, 0]), SAND)
        a.blob("M150 330 C168 262 240 250 276 330 Z", SAND_D)
    with a.part(8):                                   # shovel stuck in the sand hill
        a.sil(c_bar(206, 300, 170, 142, 13), WOOD)
        a.sil(c_circ(168, 128, 15), WOOD)
    with a.part(8):
        a.sil(c_rpoly([(184, 262), (236, 250), (252, 318), (212, 334)], [8, 8, 14, 14]), YEL)
    a.path("M344 196 C352 150 404 150 412 196", sw=8)             # bucket
    with a.part():
        a.sil(c_rpoly([(326, 196), (430, 196), (414, 312), (342, 312)], [8, 8, 14, 14]), RED)
        a.blob(c_rpoly([(331, 236), (425, 236), (422, 256), (334, 256)], 0), YEL)
        a.blob(c_rpoly([(340, 292), (417, 292), (414, 311), (342, 311)], [0, 0, 12, 12]), RED_D)
    a.path("M344 214 L346 228", stroke=WHITE, sw=7, **{"stroke-opacity": "0.6"})
    with a.part():                                    # front board
        a.sil(c_rpoly([(56, 330), (456, 330), (456, 444), (56, 444)], [8, 8, 20, 20]), WOOD)
        a.blob(c_rpoly([(57, 418), (455, 418), (455, 443), (57, 443)], [0, 0, 19, 19]), "#e3a257")
    for x in (156, 256, 356):
        c_line(a, x, 344, x, 430, 6, col=WOOD_D)
    a.shine("M78 346 L140 346", sw=6)
    return a


# ------------------------------------------------------- scenery (D174) --
LEAF1, LEAF2 = "#6fbd5c", "#4f9e48"
BARK, BARK_D = "#b47a4a", "#8f5c34"
STONE, STONE_D, STONE_L = "#c9c4bd", "#a8a29b", "#e4e0da"


@word
def yama():
    a = Art()
    with a.part():                            # far peak
        e1_mountain(a, (270, 440, 322, 384, 356, 284, 378, 236), (378, 236, 392, 206, 420, 206, 434, 236),
                    (434, 236, 458, 290, 498, 392, 534, 440), "#b4d0ee", 0.3, n=3)
    with a.part():                            # main peak: wide top, slopes that sag a little like ふじさん
        e1_mountain(a, (14, 440, 120, 404, 176, 270, 204, 150), (204, 150, 220, 100, 292, 100, 308, 150),
                    (308, 150, 336, 270, 392, 404, 498, 440), "#7aa5dc", 0.3)
    with a.part():                            # green foothills in front
        a.sil("M14 440 C52 396 124 390 176 420 C200 434 222 440 250 440 Z", "#8fd08a")
        a.sil("M304 440 C348 404 424 394 478 420 C508 434 524 438 534 440 Z", "#8fd08a")
        a.blob("M112 440 C140 420 170 420 196 430 C212 436 228 440 250 440 Z", "#74bd72")
        a.blob("M414 440 C444 420 472 420 494 428 C512 434 524 438 534 440 Z", "#74bd72")
    a.shine("M160 350 C170 332 180 312 189 292")
    return a


@word
def taki():
    a = Art()
    ROCK, ROCK_D, ROCK_L = "#b69a7e", "#967b63", "#c9b096"
    with a.part():                            # the cliff, one mass
        a.sil("M50 400 C38 300 40 196 54 108 L458 108 C472 196 474 300 462 400 Z", ROCK)
        a.blob("M156 120 L200 120 L196 398 L166 398 C156 300 152 200 156 120 Z", ROCK_D)
        a.blob("M312 120 L356 120 C360 200 356 300 346 398 L316 398 Z", ROCK_D)
        a.blob("M66 230 C90 222 118 222 140 230 C142 240 138 248 128 248 L76 248 C68 248 64 240 66 230 Z", ROCK_L)
        a.blob("M376 300 C398 292 424 292 446 300 C448 310 444 318 434 318 L386 318 C378 318 374 310 376 300 Z", ROCK_L)
        a.ink([(41, 320, 62, 314, 82, 320, 102, 314)], 8, a=1, b=0)
        a.ink([(471, 216, 450, 210, 430, 216, 410, 210)], 8, a=1, b=0)
    grass = ("M36 126 C28 98 50 84 84 84 L204 84 C210 100 204 122 192 128 C178 136 166 120 152 130 "
             "C138 140 122 122 106 132 C90 142 72 126 58 134 C46 138 38 134 36 126 Z")
    bush = "M60 92 C44 70 62 44 88 50 C98 26 138 28 144 54 C168 52 176 80 160 92 Z"
    for flip in (False, True):
        with a.part():
            a.sil(e1_tf(grass, flip=flip), LEAF1)
            a.sil(e1_tf(bush, flip=flip), LEAF2)
            a.ink([e1_tc((88, 50, 94, 58, 96, 66, 94, 74), flip=flip)], 8, a=1, b=0)
            a.ink([e1_tc((144, 54, 136, 58, 130, 64, 128, 72), flip=flip)], 8, a=1, b=0)
    with a.part():                            # pool
        a.sil(e1_d(e1_arc(256, 414, 204, 0, 360, ry=48)), "#6cc0ec")
        a.blob(e1_d(e1_arc(256, 414, 204, 10, 170, ry=48) + e1_arc(256, 406, 198, 172, 8, ry=42)), "#4fa9dc")
        a.ink([(86, 418, 120, 432, 160, 438, 200, 440)], 7, col=WHITE)
        a.ink([(330, 442, 364, 440, 396, 434, 420, 424)], 7, col=WHITE)
    with a.part(9):                           # falling water
        a.sil("M198 92 C232 102 280 102 314 92 L322 404 L190 404 Z", "#9fdcf7")
        a.blob("M198 92 C232 102 280 102 314 92 L315 112 C280 122 232 122 197 112 Z", "#c9ecfb")
        for x, y0, y1 in ((224, 136, 330), (256, 156, 376), (290, 128, 300)):
            a.ink([e1_line(x, y0, x, y1)], 9, col=WHITE)
    a.blob("M186 410 C170 390 190 368 212 378 C218 354 256 350 268 372 C288 356 322 366 322 390 "
           "C344 394 344 418 322 424 C290 434 214 434 196 424 C188 420 186 414 186 410 Z", WHITE)
    a.blob("M210 418 C240 426 280 426 316 416 C300 430 226 432 210 418 Z", "#d5effb")
    return a


@word
def ishi():
    a = Art()
    c1 = (92, 404, 70, 350, 96, 262, 158, 220)
    c2 = (158, 220, 210, 200, 290, 190, 344, 226)
    c3 = (344, 226, 392, 266, 416, 336, 402, 404)
    c4 = (402, 404, 394, 438, 350, 448, 262, 448)
    c5 = e1_line(262, 448, 196, 448)
    c6 = (196, 448, 132, 448, 102, 438, 92, 404)
    with a.part():
        a.sil(e1_d([c1, c2, c3, c4, c5, c6]), STONE)
        p = e1_pt(c2, 0.7)
        a.blob(e1_d([e1_sub(c2, 0.7, 1), c3, c4, (262, 448, 330, 430, 356, 330, p[0], p[1])]), STONE_D)
        a.blob("M132 300 C140 262 176 240 222 232 C262 226 296 232 300 240 C260 244 200 258 170 296 "
               "C158 312 148 322 140 322 C134 320 130 312 132 300 Z", STONE_L)
        q = e1_pt(c2, 0.34)
        a.ink([(q[0], q[1], q[0] + 6, q[1] + 26, q[0] - 12, q[1] + 44, q[0] + 2, q[1] + 66),
               (q[0] + 2, q[1] + 66, q[0] + 10, q[1] + 78, q[0] + 22, q[1] + 82, q[0] + 30, q[1] + 96)], 8, a=1, b=0)
        a.ink([(220, 449, 232, 430, 252, 420, 268, 400)], 8, a=1, b=0)
    with a.part():                            # small stone in front
        a.sil("M372 448 C360 412 384 380 422 374 C460 370 488 392 486 422 C484 440 472 448 454 448 Z", STONE_L)
        a.blob("M486 422 C484 440 472 448 454 448 L400 448 C440 444 468 430 478 396 C484 404 487 412 486 422 Z", STONE)
        a.ink([(400, 400, 408, 392, 420, 388, 432, 388)], 7, col=WHITE)
    with a.part(9):                           # grass tuft
        a.sil("M60 448 C56 414 44 392 22 380 C52 384 76 408 84 448 Z", LEAF2)
        a.sil("M76 448 C70 400 76 368 92 344 C96 380 104 414 104 448 Z", LEAF1)
        a.sil("M96 448 C100 420 114 400 136 392 C126 412 122 430 122 448 Z", LEAF2)
    return a


@word
def ike():
    a = Art()
    SAND, WATER, WATER_D = "#d2ab78", "#6cc0ec", "#4fa9dc"
    a.sil("M256 228 C382 224 494 270 492 346 C490 420 380 458 256 458 C132 458 22 420 20 346 "
          "C18 270 130 232 256 228 Z", SAND)
    with a.part(9):
        a.sil("M256 250 C366 246 466 284 464 344 C462 404 366 436 256 436 C146 436 50 404 48 344 "
              "C46 284 146 254 256 250 Z", WATER)
        a.blob("M48 344 C50 404 146 436 256 436 C366 436 462 404 464 344 C452 392 360 418 256 418 "
               "C152 418 60 392 48 344 Z", WATER_D)
        a.ink([(104, 316, 134, 292, 184, 280, 232, 280)], 8, col=WHITE)
        a.ink([(280, 412, 320, 412, 356, 406, 384, 396)], 7, col=WHITE)
    e1_pad(a, 200, 366, 56, 30, 300)
    e1_pad(a, 336, 356, 62, 32, 230)
    lot = (336, 344)                           # lotus on the right pad: back petals, side petals, front petal
    x, y = lot
    with a.part(8):
        sym(a, f"M{x} {y} C{x-40} {y-2} {x-58} {y-26} {x-52} {y-48} C{x-26} {y-44} {x-6} {y-26} {x} {y} Z", "#f7a3c4", x)
    with a.part(8):
        sym(a, f"M{x} {y+2} C{x-28} {y-12} {x-34} {y-46} {x-20} {y-66} C{x-2} {y-50} {x+4} {y-22} {x} {y+2} Z", "#f9b8d2", x)
    with a.part(8):
        a.sil(f"M{x} {y+6} C{x-22} {y-8} {x-20} {y-36} {x} {y-54} C{x+20} {y-36} {x+22} {y-8} {x} {y+6} Z", "#fcd3e3")
    for sx, sy, rx, ry in ((62, 318, 34, 22), (124, 438, 36, 21), (396, 440, 38, 21), (456, 322, 34, 22), (250, 232, 36, 19)):
        e1_stone(a, sx, sy, rx, ry)
    with a.part(9):                           # cattails
        a.sil(taper([(100, 352, 110, 320, 130, 296, 150, 286)], 16, 3), LEAF1)
        for x0, top, lean in ((50, 150, -8), (84, 112, 4), (116, 168, 14)):
            stem = [(x0, 344, x0, 290, x0 + lean, 230, x0 + lean, top - 22)]
            a.sil(taper(stem, 10, 8), LEAF2)
            a.sil(e1_d(e1_arc(x0 + lean, top + 34, 14, 0, 360, ry=40)), "#8a5a3a")
            a.ink([e1_line(x0 + lean - 5, top + 12, x0 + lean - 5, top + 40)], 5, col="#b07a52")
    return a


@word
def kusa():
    import math
    a = Art()
    G1, G2, G3 = "#8fd070", LEAF1, LEAF2
    B = 452
    # two small white flowers on thin stems, behind the grass
    for (fx, fy, sx) in ((84, 262, 130), (436, 214, 386)):
        a.sil(taper([(sx, B, sx - (sx - fx) * 0.2, B - 90, fx + (sx - fx) * 0.2, fy + 80, fx, fy)], 10, 8), G3)
    with a.part():
        a.sil(d_blade(256, B, 62, 250, 96), G3)
        a.sil(d_blade(168, B, 54, 108, 230), G3)
        a.sil(d_blade(348, B, 54, 408, 244), G3)
    with a.part():
        a.sil(d_blade(206, B, 56, 176, 172), G2)
        a.sil(d_blade(310, B, 56, 346, 160), G2)
        a.sil(d_blade(112, B, 50, 52, 330), G2)
        a.sil(d_blade(404, B, 50, 462, 322), G2)
    with a.part():
        a.sil(d_blade(160, B, 48, 138, 318), G1)
        a.sil(d_blade(258, B, 52, 268, 262), G1)
        a.sil(d_blade(356, B, 48, 382, 310), G1)
    for cx, cy in ((84, 258), (436, 210)):
        with a.part(ow=9):
            for i in range(5):
                t = -math.pi / 2 + i * 2 * math.pi / 5
                a.sil(d_circ(cx + 20 * math.cos(t), cy + 20 * math.sin(t), 16), WHITE)
            a.blob(d_circ(cx, cy, 14), WHITE)
            a.dot(cx, cy, 11, YEL2)
    return a


@word
def matsu():
    a = Art()
    GN, GN_D, GN_L = "#4e9a55", "#3d7f46", "#7cc17f"
    trunk = "M240 470 C222 420 276 380 250 330 C236 300 214 280 220 240 L266 240 C258 280 292 306 302 340 C316 390 282 430 298 470 Z"
    with a.part():
        a.sil(taper([(250, 316, 220, 290, 184, 262, 150, 246)], 34, 22), BARK)
        a.sil(taper([(276, 300, 306, 270, 340, 236, 372, 214)], 32, 22), BARK)
        a.sil(trunk, BARK)
        a.sil("M214 470 C214 458 232 452 268 452 C306 452 324 458 324 470 Z", BARK)
        a.blob("M266 244 C258 280 292 306 302 340 C316 390 282 430 298 468 L280 468 C266 430 292 390 278 340 C270 310 246 286 254 244 Z", BARK_D)
        a.ink([(236, 420, 244, 400, 250, 384, 250, 366)], 7, a=0, b=0, col=BARK_D)

    def pad(cx, cy, rx, ry):
        d = (f"M{cx - rx} {cy + ry * 0.45} C{cx - rx * 1.12} {cy - ry * 0.4} {cx - rx * 0.72} {cy - ry * 1.02} {cx - rx * 0.42} {cy - ry * 0.74} "
             f"C{cx - rx * 0.26} {cy - ry * 1.4} {cx + rx * 0.26} {cy - ry * 1.4} {cx + rx * 0.42} {cy - ry * 0.74} "
             f"C{cx + rx * 0.72} {cy - ry * 1.02} {cx + rx * 1.12} {cy - ry * 0.4} {cx + rx} {cy + ry * 0.45} "
             f"C{cx + rx * 0.9} {cy + ry * 1.05} {cx - rx * 0.9} {cy + ry * 1.05} {cx - rx} {cy + ry * 0.45} Z")
        with a.part():
            a.sil(d, GN)
            a.blob(d_rim(d, 90, 80, ry * 0.42), GN_D)
            for dx, dy in ((-0.5, -0.1), (0, -0.5), (0.5, -0.1), (-0.05, 0.15)):
                x, y = cx + dx * rx, cy + dy * ry
                a.ink([(x - 12, y + 8, x - 6, y, x - 2, y - 6, x, y - 12)], 7, a=0, b=0.6, col=GN_L)
                a.ink([(x + 12, y + 8, x + 6, y, x + 2, y - 6, x, y - 12)], 7, a=0, b=0.6, col=GN_L)

    pad(146, 234, 112, 56)
    pad(376, 198, 106, 52)
    pad(250, 122, 122, 60)
    return a


@word
def donguri():
    a = Art()

    def acorn(cx, cy, s, deg):
        T = lambda d: d_tf(d, s, cx, cy, deg)
        c, sn = math.cos(math.radians(deg)), math.sin(math.radians(deg))
        P = lambda x, y: (s * (x * c - y * sn) + cx, s * (x * sn + y * c) + cy)
        nut = T("M-84 -60 C-92 50 -44 122 -10 146 C-4 152 4 152 10 146 C44 122 92 50 84 -60 Z")
        with a.part():
            a.sil(nut, "#d9a35f")
            a.blob(d_rim(nut, 30 + deg, 70, 26 * s), "#c18544")
        cap = T("M-100 -44 C-104 -112 -46 -126 0 -126 C46 -126 104 -112 100 -44 C100 -30 88 -26 76 -30 "
                "C30 -42 -30 -42 -76 -30 C-88 -26 -100 -30 -100 -44 Z")
        with a.part():
            a.sil(T("M-9 -120 L-7 -150 C-7 -160 9 -160 9 -150 L9 -120 Z"), "#7a4f2a")
            a.sil(cap, "#9a6a3c")
            a.blob(d_rim(cap, 20 + deg, 70, 16 * s), "#835630")
            for dx, dy in ((-56, -74), (0, -92), (56, -74), (-28, -58), (28, -58), (-74, -52), (74, -52), (-28, -104), (28, -104)):
                x, y = P(dx, dy)
                a.dot(x, y, 6.5 * s, "#7a4f2a")
        (x0, y0), (x1, y1), (x2, y2), (x3, y3) = P(-56, -10), P(-58, 30), P(-44, 66), P(-26, 92)
        a.shine(f"M{x0:.1f} {y0:.1f} C{x1:.1f} {y1:.1f} {x2:.1f} {y2:.1f} {x3:.1f} {y3:.1f}", sw=9 if s > 1 else 7)

    import math
    acorn(206, 270, 1.4, -8)
    acorn(420, 372, 0.72, 16)
    return a


@word
def happa():
    a = Art()
    ST = "#8a6a3a"
    # the small orange leaf behind
    with a.part():
        a.sil(taper([(332, 468, 332, 432, 342, 410, 362, 390)], 12, 12), ST)
    leaf2 = "M362 400 C298 364 286 270 338 204 C412 226 450 330 394 398 C382 412 372 410 362 400 Z"
    with a.part():
        a.sil(leaf2, "#f2a24a")
        a.blob("M362 398 C372 408 382 408 392 396 C444 330 410 232 342 210 C372 276 370 340 362 398 Z", "#e58d32")
        a.ink([(362, 396, 362, 340, 366, 280, 342, 226)], 8, a=1, b=0, col="#c9741f")
        a.ink([(360, 330, 340, 322, 324, 306, 316, 288)], 6, a=1, b=0, col="#c9741f")
        a.ink([(364, 290, 384, 286, 400, 274, 408, 258)], 6, a=1, b=0, col="#c9741f")
    # the big green leaf
    with a.part():
        a.sil(taper([(172, 470, 172, 422, 186, 392, 214, 354)], 14, 14), ST)
    leaf = "M214 362 C118 332 78 220 120 116 C214 98 302 150 318 250 C326 332 270 394 214 362 Z"
    with a.part():
        a.sil(leaf, LEAF1)
        a.blob("M214 360 C268 390 324 330 316 250 C302 160 220 106 128 120 C160 200 190 290 214 360 Z", "#63b253")
        a.ink([(214, 358, 190, 284, 172, 212, 130, 128)], 10, a=1, b=0, col=LEAF2)
        for c in ([(196, 300, 168, 296, 142, 274, 130, 246)], [(180, 242, 206, 238, 230, 220, 242, 196)],
                  [(170, 204, 146, 198, 126, 180, 118, 156)], [(204, 322, 240, 322, 268, 300, 280, 270)]):
            a.ink(c, 8, a=1, b=0, col=LEAF2)
    a.shine("M150 156 C174 138 202 130 232 132", sw=9)
    return a


@word
def kinoko():
    a = Art()

    def shroom(cx, base, w, h, cap, cap_d, spots, stem="#fff4e2", stem_d="#f0dfc4", face=False):
        top = base - h
        sh = h * 0.5
        sd = (f"M{cx - w * 0.2} {top + sh * 0.7} C{cx - w * 0.2} {base - sh * 0.5} {cx - w * 0.3} {base} {cx - w * 0.17} {base} "
              f"L{cx + w * 0.17} {base} C{cx + w * 0.3} {base} {cx + w * 0.2} {base - sh * 0.5} {cx + w * 0.2} {top + sh * 0.7} Z")
        with a.part():
            a.sil(sd, stem)
            a.blob(d_rim(sd, 20, 60, w * 0.07), stem_d)
        cd = (f"M{cx - w * 0.5} {top + sh * 0.78} C{cx - w * 0.54} {top - sh * 0.1} {cx - w * 0.3} {top - sh * 0.22} {cx} {top - sh * 0.22} "
              f"C{cx + w * 0.3} {top - sh * 0.22} {cx + w * 0.54} {top - sh * 0.1} {cx + w * 0.5} {top + sh * 0.78} "
              f"C{cx + w * 0.5} {top + sh * 0.94} {cx + w * 0.4} {top + sh * 0.98} {cx + w * 0.32} {top + sh * 0.94} "
              f"C{cx + w * 0.12} {top + sh * 0.84} {cx - w * 0.12} {top + sh * 0.84} {cx - w * 0.32} {top + sh * 0.94} "
              f"C{cx - w * 0.4} {top + sh * 0.98} {cx - w * 0.5} {top + sh * 0.94} {cx - w * 0.5} {top + sh * 0.78} Z")
        with a.part():
            a.sil(cd, cap)
            a.blob(d_rim(cd, 30, 70, w * 0.09), cap_d)
            for dx, dy, r in spots:
                a.blob(d_circ(cx + w * dx, top + sh * dy, w * r, w * r * 0.9), "#fffaf0")
        if face:
            fy = base - h * 0.2
            a.eye(cx - w * 0.095, fy, 11)
            a.eye(cx + w * 0.095, fy, 11)
            a.cheek(cx - w * 0.16, fy + 20, 11, 7)
            a.cheek(cx + w * 0.16, fy + 20, 11, 7)
            a.path(f"M{cx - 9} {fy + 16} C{cx - 4} {fy + 24} {cx + 4} {fy + 24} {cx + 9} {fy + 16}", sw=6)

    for x0, tx, ty in ((84, 62, 404), (106, 122, 396), (432, 448, 400), (454, 474, 410)):
        a.sil(d_blade(x0, 452, 22, tx, ty), LEAF1)
    shroom(366, 450, 176, 196, "#d9a05b", "#c48a45", ((-0.2, 0.42, 0.08), (0.1, 0.16, 0.09), (0.3, 0.52, 0.06)))
    shroom(206, 450, 300, 330, "#e5534b", "#c9403a", ((-0.27, 0.5, 0.085), (0.02, 0.2, 0.1), (0.28, 0.5, 0.075), (-0.14, 0.02, 0.05)), face=True)
    a.shine("M84 214 C86 184 98 158 118 140", sw=9)
    return a


@word
def ie():
    a = Art()
    WALL, WALL_D = "#fff0d4", "#ecd8b2"
    with a.part():                                    # chimney
        a.sil(c_rect(322, 96, 58, 120, 4), "#c97f3e")
    with a.part():
        a.sil(c_rect(312, 78, 78, 28, 9), "#a8672f")
    with a.part():                                    # walls
        a.sil(c_rpoly([(92, 250), (420, 250), (420, 454), (92, 454)], [0, 0, 12, 12]), WALL)
        a.blob("M93 288 L419 288 L419 308 L93 308 Z", WALL_D)
    with a.part():                                    # roof
        a.sil("M256 92 Q270 92 282 102 L466 250 Q482 264 474 278 Q468 290 452 290 L60 290 Q44 290 38 278 "
              "Q30 264 46 250 L230 102 Q242 92 256 92 Z", RED)
        a.blob("M48 266 L464 266 Q478 268 473 278 Q468 289 452 289 L60 289 Q44 289 39 278 Q34 268 48 266 Z", RED_D)
    c_glass(a, c_circ(256, 204, 28))
    c_line(a, 232, 204, 280, 204, 5, s=1, e=1)
    c_line(a, 256, 180, 256, 228, 5, s=1, e=1)
    a.shine("M214 138 L160 182")
    with a.part(9):                                   # door
        a.sil("M132 454 L132 352 C132 322 196 322 196 352 L196 454 Z", WOOD_D)
    a.dot(180, 400, 7, YEL)
    for x in (236, 332):                              # windows
        c_glass(a, c_rect(x, 334, 68, 68, 9))
        c_line(a, x + 34, 338, x + 34, 398, 5, s=1, e=1)
        c_line(a, x + 4, 368, x + 64, 368, 5, s=1, e=1)
    for s_ in (0, 1):                                 # bushes at the corners
        d = "M44 460 C36 436 62 422 78 436 C92 426 112 438 108 460 Z"
        with a.part(9):
            a.sil(mirror(d) if s_ else d, LEAF1)
    return a


@word
def gakkou():
    a = Art()
    WALL, WALL_D, ROOF = "#fff0d4", "#ecd8b2", "#6f8fb8"
    a.path("M448 200 L448 84", sw=9)                 # flag
    with a.part(8):
        a.sil(c_rect(448, 86, 52, 38, 5), WHITE)
    a.dot(474, 105, 10, RED)
    with a.part():                                    # clock tower
        a.sil(c_rect(204, 82, 104, 130, 6), WALL)
    with a.part():
        a.sil(c_rpoly([(256, 20), (326, 86), (186, 86)], [12, 12, 12]), ROOF)
    with a.part(8):
        a.sil(c_circ(256, 138, 31), WHITE)
    c_line(a, 256, 138, 256, 116, 7, s=1, e=1)
    c_line(a, 256, 138, 272, 146, 7, s=1, e=1)
    with a.part():                                    # main building
        a.sil(c_rpoly([(40, 196), (472, 196), (472, 454), (40, 454)], [12, 12, 10, 10]), WALL)
        a.blob(c_rpoly([(41, 197), (471, 197), (471, 226), (41, 226)], [11, 11, 0, 0]), ROOF)
        a.blob("M41 226 L471 226 L471 238 L41 238 Z", WALL_D)
    for x in (64, 138, 314, 388):
        for y in (256, 350):
            c_glass(a, c_rect(x, y, 60, 62, 8), ow=5)
            c_line(a, x + 30, y + 3, x + 30, y + 59, 4, s=1, e=1)
    with a.part(9):                                   # entrance
        a.sil(c_rect(216, 336, 80, 118, 0), "#c97f3e")
    c_line(a, 256, 340, 256, 452, 6, s=1, e=1)
    with a.part(9):
        a.sil(c_rect(198, 306, 116, 34, 10), ROOF)
    return a


@word
def byouin():
    a = Art()
    WIN = "#bfe6fa"
    with a.part():                                    # main building
        a.sil(c_rpoly([(62, 160), (338, 160), (338, 454), (62, 454)], [14, 14, 10, 10]), WHITE)
        a.blob("M63 366 L337 366 L337 382 L63 382 Z", "#7fc0e8")
    with a.part():                                    # the wing on the right
        a.sil(c_rpoly([(318, 254), (452, 254), (452, 454), (318, 454)], [14, 14, 10, 10]), "#e3f1fa")
        a.blob(c_rpoly([(319, 420), (451, 420), (451, 453), (319, 453)], [0, 0, 9, 9]), "#cfe5f3")
    with a.part():                                    # red cross sign on the roof
        a.sil(c_rect(148, 60, 104, 104, 20), RED)
        a.blob(c_rect(189, 82, 22, 60, 6), WHITE)
        a.blob(c_rect(170, 101, 60, 22, 6), WHITE)
    for y in (196, 280):
        for x in (86, 162, 238):
            c_glass(a, c_rect(x, y, 48, 56, 8), ow=5, col=WIN)
    for x in (338, 392):
        c_glass(a, c_rect(x, 284, 42, 52, 8), ow=5, col=WIN)
    with a.part(8):                                   # entrance
        a.sil(c_rpoly([(154, 394), (246, 394), (246, 454), (154, 454)], [8, 8, 0, 0]), WIN)
    c_line(a, 200, 398, 200, 452, 5, s=1, e=1)
    a.shine("M84 176 L200 176", sw=6)
    with a.part(9):                                   # a bush
        a.sil("M22 460 C14 436 40 422 56 436 C70 426 90 438 86 460 Z", LEAF1)
    return a


@word
def oshiro():
    a = Art()
    ROOF, ROOF_D, WIN, GOLD = "#5d7894", "#486079", "#33425a", "#f6c548"
    cx = 256

    def roof(y, w, tw, h):
        """A tiled roof with turned-up eaves: bottom edge at y, half width w, top half width tw, height h."""
        d = (f"M{cx - w} {y - 12} Q{cx - w - 6} {y + 2} {cx - w + 16} {y + 4} C{cx - w / 2} {y + 10} {cx + w / 2} {y + 10} {cx + w - 16} {y + 4} "
             f"Q{cx + w + 6} {y + 2} {cx + w} {y - 12} C{cx + w - 34} {y - 16} {cx + tw + 10} {y - h + 16} {cx + tw} {y - h} "
             f"L{cx - tw} {y - h} C{cx - tw - 10} {y - h + 16} {cx - w + 34} {y - 16} {cx - w} {y - 12} Z")
        shade = (f"M{cx - w + 4} {y - 9} Q{cx - w} {y + 1} {cx - w + 16} {y + 3} C{cx - w / 2} {y + 9} {cx + w / 2} {y + 9} {cx + w - 16} {y + 3} "
                 f"Q{cx + w} {y + 1} {cx + w - 4} {y - 9} C{cx + w / 2} {y - 4} {cx - w / 2} {y - 4} {cx - w + 4} {y - 9} Z")
        with a.part():
            a.sil(d, ROOF)
            a.blob(shade, ROOF_D)

    with a.part():                                    # stone base
        a.sil(c_rpoly([(116, 370), (396, 370), (440, 454), (72, 454)], [8, 8, 12, 12]), "#b6b0a8")
        a.blob(c_rpoly([(82, 432), (430, 432), (439, 453), (73, 453)], [0, 0, 11, 11]), "#a39d95")
    for x0, y0, x1, y1 in ((100, 404, 206, 404), (306, 404, 412, 404), (160, 374, 156, 404), (352, 374, 356, 404),
                           (196, 404, 192, 432), (320, 404, 324, 432)):
        c_line(a, x0, y0, x1, y1, 5, col="#8f8981")
    with a.part(8):                                   # gate
        a.sil("M232 454 L232 412 C232 386 280 386 280 412 L280 454 Z", WIN)
    with a.part():                                    # first floor
        a.sil(c_rect(140, 296, 232, 78, 0), WHITE)
    for x in (170, 240, 310):
        a.blob(c_rect(x, 330, 32, 28, 6), WIN)
    with a.part():                                    # second floor
        a.sil(c_rect(176, 196, 160, 76, 0), WHITE)
    roof(306, 168, 96, 44)
    with a.part():                                    # small gable on the first roof
        a.sil(c_rpoly([(256, 256), (294, 302), (218, 302)], [8, 6, 6]), ROOF)
        a.blob(c_rpoly([(256, 276), (274, 297), (238, 297)], [4, 3, 3]), WHITE)
    for x in (200, 280):
        a.blob(c_rect(x, 226, 32, 26, 6), WIN)
    with a.part():                                    # top floor
        a.sil(c_rect(210, 100, 92, 72, 0), WHITE)
    roof(204, 130, 62, 42)
    a.blob(c_rect(240, 126, 32, 26, 6), WIN)
    for s_ in (0, 1):                                 # golden shachi on the ridge
        d = "M216 66 C202 54 206 30 226 28 C222 40 230 50 242 54 L242 68 Z"
        with a.part(8):
            a.sil(mirror(d) if s_ else d, GOLD)
    roof(108, 92, 34, 52)
    return a


SHINGOU_LAMPS = (140, 256, 372)   # x of the three lamps (green, yellow, red); y and r below
SHINGOU_Y, SHINGOU_R = 145, 42


@word
def shingou():
    a = Art()
    POLE, POLE_D, BOX = "#9aa5a8", "#7f8a8e", "#4a5560"
    with a.part():                                    # pole and its foot
        a.sil(c_rect(241, 200, 30, 334, 0), POLE)
        a.blob("M259 200 L270 200 L270 534 L259 534 Z", POLE_D)
        a.sil(c_rpoly([(218, 520), (294, 520), (306, 548), (206, 548)], [10, 10, 8, 8]), POLE_D)
    with a.part():                                    # signal box (lamps are lit by the app; the picture shows green)
        a.sil(c_bar(129, 145, 383, 145, 138), BOX)
        a.blob("M92 110 C104 92 122 86 142 86 L370 86 C390 86 408 92 420 110 C404 100 388 98 370 98 L142 98 "
               "C124 98 108 100 92 110 Z", "#66727e")
    with a.part():
        for cx, col in zip(SHINGOU_LAMPS, ("#58d36a", "#5e5320", "#6b2a28")):
            a.sil(c_circ(cx, SHINGOU_Y, SHINGOU_R - SW / 2), col)
    a.shine("M118 138 C122 124 132 116 144 114", sw=7)
    return a


FUMIKIRI_LAMPS = (84, 140)
FUMIKIRI_Y, FUMIKIRI_R = 233, 22


@word
def fumikiri():
    a = Art()
    YB, BLK, POST, BOX = "#f6d33a", "#33343a", "#f4f1ea", "#4a5560"

    def band(p, q, t0, t1, w):
        """A flat black band across a bar from p to q, between fractions t0 and t1."""
        dx, dy = q[0] - p[0], q[1] - p[1]
        L = (dx * dx + dy * dy) ** 0.5
        nx, ny = -dy / L * w / 2, dx / L * w / 2
        x0, y0, x1, y1 = p[0] + dx * t0, p[1] + dy * t0, p[0] + dx * t1, p[1] + dy * t1
        a.blob(f"M{x0 + nx:.1f} {y0 + ny:.1f} L{x1 + nx:.1f} {y1 + ny:.1f} L{x1 - nx:.1f} {y1 - ny:.1f} L{x0 - nx:.1f} {y0 - ny:.1f} Z", BLK)

    with a.part(8):                                   # sleepers and rails
        for x in (48, 130, 212, 294, 376, 458):
            a.sil(c_rect(x - 17, 432, 34, 46, 6), "#b3936f")
    with a.part(6):
        for y in (446, 464):
            a.sil(c_bar(22, y, 490, y, 9), "#aab3b8")
    with a.part():                                    # post
        a.sil(c_rect(96, 116, 28, 330, 4), POST)
        a.blob("M113 118 L123 118 L123 444 L113 444 Z", "#dcd7cc")
    with a.part():                                    # barrier arm
        a.sil(c_bar(124, 340, 470, 340, 28), YB)
        for x in (186, 256, 326, 396):
            a.blob(f"M{x} 326 L{x + 30} 326 L{x + 18} 354 L{x - 12} 354 Z", BLK)
    a.shine("M150 332 L172 332", sw=5)
    with a.part():
        a.sil(c_circ(110, 340, 22), POST)
    a.dot(110, 340, 8, "#8a949a")
    with a.part():                                    # warning lamps (lit by the app)
        a.sil(c_rect(48, 194, 128, 78, 26), BOX)
    with a.part():
        for cx in FUMIKIRI_LAMPS:
            a.sil(c_circ(cx, FUMIKIRI_Y, FUMIKIRI_R - SW / 2), "#e5534b")
    with a.part():                                    # crossbuck sign
        for p, q in (((52, 70), (168, 138)), ((168, 70), (52, 138))):
            a.sil(c_bar(p[0], p[1], q[0], q[1], 26), YB)
            band(p, q, 0.06, 0.24, 26)
            band(p, q, 0.76, 0.94, 26)
    return a


@word
def gaitou():
    a = Art()
    GREEN_D, GREEN_DD, GLOW = "#46665a", "#38544a", "#fff1a8"
    for x0, y0, x1, y1 in ((176, 112, 136, 100), (336, 112, 376, 100), (172, 160, 134, 178), (340, 160, 378, 178)):
        c_line(a, x0, y0, x1, y1, 11, s=0.9, e=0.2, col="#f6c548")
    with a.part():                                    # pole and foot: one shape
        a.sil("M184 468 C196 444 226 440 240 430 C246 380 247 300 247 210 L265 210 C265 300 266 380 272 430 "
              "C286 440 316 444 328 468 Q330 476 322 476 L190 476 Q182 476 184 468 Z", GREEN_D)
        a.blob("M257 212 L264 212 C264 300 265 380 271 431 C285 441 315 445 327 469 Q328 475 322 475 L262 475 "
               "C262 440 258 300 257 212 Z", GREEN_DD)
    with a.part():
        a.sil(c_rect(236, 286, 40, 18, 8), GREEN_D)
    with a.part():                                    # holder under the lamp
        a.sil(c_rpoly([(224, 186), (288, 186), (276, 220), (236, 220)], [4, 4, 8, 8]), GREEN_D)
    with a.part():                                    # glass
        a.sil("M206 100 C190 132 200 176 228 194 L284 194 C312 176 322 132 306 100 Z", GLOW)
        a.blob(c_circ(256, 148, 26, 32), "#ffe07a")
    a.path("M222 112 C212 132 214 158 226 174", stroke=WHITE, sw=8, **{"stroke-opacity": "0.8"})
    with a.part():                                    # cap
        a.sil("M200 104 Q190 104 196 94 L212 72 Q218 64 228 64 L284 64 Q294 64 300 72 L316 94 Q322 104 312 104 Z", GREEN_D)
    with a.part():
        a.sil(c_circ(256, 48, 13), GREEN_D)
    return a


@word
def asagao():
    import math
    a = Art()
    a.sil("M247 76 C247 66 265 66 265 76 L265 480 L247 480 Z", "#d6a56e")
    with a.part():
        a.sil(taper([(256, 452, 200, 420, 318, 372, 256, 330), (256, 330, 198, 292, 312, 250, 258, 208)], 13, 11), LEAF2)

    def leaf(bx, by, s):
        # heart-shaped leaf, tip pointing away from the stake (s = -1 left, 1 right)
        d = (f"M{bx} {by} C{bx + s * 6} {by - 44} {bx + s * 64} {by - 52} {bx + s * 82} {by - 20} "
             f"C{bx + s * 104} {by - 4} {bx + s * 112} {by + 22} {bx + s * 118} {by + 40} "
             f"C{bx + s * 84} {by + 52} {bx + s * 30} {by + 50} {bx} {by} Z")
        with a.part():
            a.sil(d, LEAF1)
            a.ink([(bx + s * 8, by + 4, bx + s * 40, by + 12, bx + s * 70, by + 22, bx + s * 96, by + 34)], 7, a=1, b=0, col=LEAF2)

    leaf(250, 404, -1)
    leaf(262, 300, 1)

    def bloom(cx, cy, r, col, col2):
        pts = []
        for i in range(10):
            t = -math.pi / 2 + i * math.pi / 5
            rr = r * (0.93 if i % 2 == 0 else 1.0)
            pts.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
        d = smooth(pts)
        with a.part():
            a.sil(d, col)
            a.blob(d_circ(cx, cy, r * 0.6), col2)
            for i in range(5):
                t = -math.pi / 2 + i * 2 * math.pi / 5
                c, s = math.cos(t), math.sin(t)
                w = r * 0.085
                a.blob(f"M{cx - s * w:.1f} {cy + c * w:.1f} L{cx + c * r * 0.86:.1f} {cy + s * r * 0.86:.1f} L{cx + s * w:.1f} {cy - c * w:.1f} Z", WHITE)
            a.blob(d_circ(cx, cy, r * 0.22), "#fff4b0")

    bloom(166, 184, 86, "#6f8be8", "#a9bbf5")
    bloom(352, 124, 66, "#d86ab8", "#efa6d8")
    bloom(350, 256, 52, "#6f8be8", "#a9bbf5")
    a.shine("M106 160 C112 136 128 118 150 110", sw=8)
    return a


@word
def bara():
    import math
    a = Art()
    RD, RL, RDD = "#e8505b", "#f2747d", "#cf3d4b"
    with a.part():
        a.sil(taper([(256, 300, 252, 360, 260, 430, 256, 496)], 16, 16), LEAF2)
        a.sil("M250 452 L228 444 L249 430 Z", LEAF2)
        a.sil("M262 372 L284 364 L263 350 Z", LEAF2)
    for bx, by, tx, ty in ((258, 432, 392, 404), (254, 392, 118, 364)):
        with a.part():
            a.sil(d_leaf(bx, by, tx, ty, 76, 0.2 if tx < 256 else -0.2), LEAF1)
            d_vein(a, bx, by, tx, ty, LEAF2, t0=0.12, t1=0.8)
    cx, cy = 256, 196

    def lobes(R, rot, k=0.9):
        pts = []
        for i in range(10):
            t = math.radians(rot) + i * math.pi / 5
            rr = R * (1.0 if i % 2 == 0 else k)
            pts.append((cx + rr * math.cos(t), cy + rr * math.sin(t)))
        return smooth(pts)

    outer = lobes(138, -90, 0.93)
    with a.part():
        a.sil(outer, RD)
        a.blob(d_rim(outer, 60, 80, 22), RDD)
        # five outer petals: a short line runs in from each dip of the edge
        for i in range(5):
            t = math.radians(-54 + i * 72)
            pts = [(cx + r * math.cos(t + k), cy + r * math.sin(t + k)) for r, k in ((130, 0), (118, 0.1), (106, 0.24), (97, 0.42))]
            a.ink(d_curve(pts), 9, a=1, b=0)
        a.blob(d_circ(cx, cy, 88), RL)
        for a0 in (-100, 20, 140):
            a.ink(d_arc(cx, cy, 88, a0, a0 + 112, r1=88), 9, a=0, b=0)
        a.blob(d_circ(cx, cy, 54), RD)
        for a0 in (-40, 140):
            a.ink(d_arc(cx, cy, 54, a0, a0 + 150, r1=54), 9, a=0, b=0)
        a.blob(d_circ(cx, cy, 26), RL)
        a.ink(d_arc(cx, cy, 26, 60, 400, r1=6), 8, a=0.3, b=0)
    a.shine("M150 156 C160 118 190 90 228 82", sw=9)
    return a


# ------------------------------------------------------------- からだ (D175) --
SKIN, SKIN_D = "#ffd9b8", "#f4b48e"
HAIR = "#6b4430"
LIPS, MOUTH_IN, TONGUE = "#ee6a7c", "#7d2c3c", "#f78fa5"


def blobs(a, parts, fill):
    """Draw several shapes as one outlined shape (no outline lines where they overlap).
    parts: ("c", cx, cy, r) | ("e", cx, cy, rx, ry) | ("t", x1, y1, x2, y2, width) | ("p", d)."""
    ow = SW * 2
    for pass_ in (0, 1):
        for part in parts:
            kind = part[0]
            col, sw = (O, ow) if pass_ == 0 else (fill, 0)
            if kind == "c":
                a.circle(part[1], part[2], part[3], col, sw=sw, stroke=O)
            elif kind == "e":
                a.ellipse(part[1], part[2], part[3], part[4], col, sw=sw, stroke=O)
            elif kind == "p":
                a.path(part[1], fill=col, sw=sw, stroke=O)
            elif kind == "t":
                x1, y1, x2, y2, w = part[1:]
                if pass_ == 0:
                    a.path(f"M{x1} {y1} L{x2} {y2}", sw=w + ow)
                else:
                    a.path(f"M{x1} {y1} L{x2} {y2}", stroke=fill, sw=w)


def cheeks(a, cx, cy, dx, rx=16, ry=10):
    for s in (-1, 1):
        a.ellipse(cx + s * dx, cy, rx, ry, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.75"})


def eyes(a, cx, cy, gap, r=15):
    for s in (-1, 1):
        x = cx + s * gap
        a.ellipse(x, cy, r, r * 1.2, EYE, sw=0, stroke="none")
        a.dot(x + 5, cy - 7, r * 0.37, "#ffffff")


def smile(a, cx, y, w=14):
    a.path(f"M{cx-w} {y} C{cx-w/2} {y+w*0.75} {cx+w/2} {y+w*0.75} {cx+w} {y}", sw=8)


def note(a, x, y, s=1.0, col="#7a6fe0"):
    """A little music note (head at x, y)."""
    a.path(f"M{x+16*s} {y} L{x+16*s} {y-70*s}", sw=9 * s)
    a.path(f"M{x+16*s} {y-70*s} C{x+30*s} {y-62*s} {x+52*s} {y-58*s} {x+50*s} {y-34*s}", sw=9 * s)
    a.ellipse(x, y, 20 * s, 15 * s, col, sw=8 * s)


@word
def te():
    a = Art()
    with a.part():                                      # palm, four fingers and the thumb: one hand
        a.sil("M150 340 C150 292 190 276 256 276 C322 276 364 292 364 340 L364 378 C364 432 316 462 256 462 "
              "C196 462 150 432 150 378 Z", SKIN)
        a.sil(e2_cap(192, 318, 168, 204, 58, 52), SKIN)
        a.sil(e2_cap(242, 306, 238, 162, 60, 54), SKIN)
        a.sil(e2_cap(296, 310, 308, 186, 58, 52), SKIN)
        a.sil(e2_cap(340, 334, 370, 250, 52, 46), SKIN)
        a.sil(e2_cap(190, 400, 104, 322, 64, 54), SKIN)
        a.blob("M190 446 C230 468 284 468 322 446 C302 458 280 462 256 462 C232 462 210 458 190 446 Z", SKIN_D)
    e2_face(a, 256, 366, 42, 15, cheek_dx=72, cheek_dy=32)
    a.shine("M230 262 C228 236 228 212 230 190")
    a.ink([(416, 176, 436, 204, 438, 238, 420, 266)], 11, a=0.6, b=0.6)
    a.ink([(450, 148, 480, 188, 482, 248, 454, 290)], 11, a=0.6, b=0.6)
    return a


@word
def ashi():
    a = Art()
    # the sole of a bare foot: one part, so the toes join the foot and only a rounded toe line shows
    toes_ = ((190, 166, 48, 52), (268, 150, 31, 36), (324, 166, 28, 32), (370, 194, 25, 29), (404, 232, 22, 26))
    with a.part():
        a.sil("M250 480 C200 480 174 444 178 394 C180 352 170 330 156 296 C138 250 138 178 198 158 "
              "C250 142 334 148 384 196 C414 226 406 300 392 342 C380 388 366 422 344 450 "
              "C326 472 290 480 250 480 Z", SKIN)
        for cx, cy, rx, ry in toes_:
            a.sil_ellipse(cx, cy, rx, ry, SKIN)
        a.blob("M204 430 C200 396 312 396 316 430 C316 458 292 472 256 472 C224 472 206 454 204 430 Z", SKIN_D,
               fill_opacity="0.45")
        import math
        for (cx, cy, rx, ry), (dx, dy, sx, sy) in zip(toes_, toes_[1:]):     # a short notch where two toes meet
            best = None
            for k in range(720):
                t = math.pi * k / 360
                x, y = cx + rx * math.cos(t), cy + ry * math.sin(t)
                err = abs(((x - dx) / sx) ** 2 + ((y - dy) / sy) ** 2 - 1)
                if err < 0.04 and (best is None or y < best[1]):
                    best = (x, y)
            x, y = best
            e2_line(a, x, y - 9, x + 2, y + 24, 10, 1, 0)
    e2_face(a, 268, 312, 42, 15, cheek_dx=74, cheek_dy=34)
    a.shine("M168 184 C166 164 172 146 184 136")
    return a


@word
def me():
    a = Art()
    IRIS, IRIS_D = "#8fc9a8", "#5da98a"
    a.sil(taper([(100, 138, 170, 70, 340, 66, 414, 132)], 20, 16), HAIR)     # eyebrow
    with a.part():
        a.sil("M62 276 C110 162 402 162 450 276 C402 388 110 388 62 276 Z", WHITE)
        a.blob("M62 276 C110 162 402 162 450 276 C400 214 112 214 62 276 Z", "#e8eef2")
        a.ellipse(256, 276, 78, 78, IRIS_D, sw=0, stroke="none")
        a.ellipse(256, 276, 62, 62, IRIS, sw=0, stroke="none")
        a.ellipse(256, 276, 36, 38, EYE, sw=0, stroke="none")
        a.dot(284, 246, 20, WHITE)
        a.dot(232, 304, 9, WHITE)
        a.ink([(62, 276, 110, 162, 402, 162, 450, 276)], 20, a=0.5, b=0.5)   # upper lid
    for x0, y0, x1, y1 in ((106, 216, 74, 186), (166, 190, 146, 150)):       # lashes
        a.blob(e2_cap(x0, y0, x1, y1, 14, 11), O)
        a.blob(e2_cap(512 - x0, y0, 512 - x1, y1, 14, 11), O)
    return a


@word
def mimi():
    a = Art()
    with a.part():
        a.sil("M286 88 C382 82 428 170 400 268 C382 334 344 356 334 406 C326 456 266 466 244 428 "
              "C224 394 214 360 214 300 C214 190 226 96 286 88 Z", SKIN)
        a.blob("M292 138 C340 140 366 190 348 246 C336 284 304 296 298 336 C294 360 264 360 260 334 "
               "C252 282 254 144 292 138 Z", SKIN_D, fill_opacity="0.75")
        a.ink([(300, 180, 330, 190, 334, 232, 312, 256), (312, 256, 300, 268, 294, 280, 292, 296)], 10,
              a=0, b=0, col="#e89a76")
    a.cheek(304, 400, 20, 13)
    a.shine("M246 160 C238 196 236 230 240 262")
    e2_note(a, 98, 196, 1.0)
    e2_note(a, 132, 352, 0.8, "#f0a23c")
    return a


@word
def kuchi():
    a = Art()
    RIM, IN = "#f58f9f", "#c2506a"
    with a.part():                                      # a child's big open smile: soft rim, inside, teeth, tongue
        a.sil("M82 196 C96 184 114 188 130 194 C212 222 300 222 382 194 C398 188 416 184 430 196 "
              "C442 208 442 228 438 246 C420 352 348 424 256 424 C164 424 92 352 74 246 C70 228 70 208 82 196 Z", RIM)
        a.blob("M106 214 C206 246 306 246 406 214 C410 226 410 238 408 250 C392 338 332 398 256 398 "
               "C180 398 120 338 104 250 C102 238 102 226 106 214 Z", IN)
        a.blob("M124 220 C212 246 300 246 388 220 C388 240 384 256 376 270 C300 288 212 288 136 270 "
               "C128 256 124 240 124 220 Z", WHITE)
        a.blob("M184 372 C200 330 312 330 328 372 C310 390 284 398 256 398 C228 398 202 390 184 372 Z", TONGUE)
        a.ink([(256, 350, 256, 360, 256, 370, 256, 382)], 7, a=0, b=0, col="#e0607a")
    return a


@word
def atama():
    a = Art()
    with a.part():                                      # ears, face and hair: one head
        a.sil_ellipse(94, 304, 38, 40, SKIN)
        a.sil_ellipse(418, 304, 38, 40, SKIN)
        a.sil("M256 120 C356 120 424 196 424 294 C424 392 350 462 256 462 C162 462 88 392 88 294 "
              "C88 196 156 120 256 120 Z", SKIN)
        a.sil("M90 270 C66 138 166 100 256 102 C346 100 446 138 422 270 C404 226 352 198 306 212 "
              "C280 182 224 188 202 214 C160 208 108 228 90 270 Z", HAIR)
        a.sil("M246 110 C222 58 262 14 308 34 C288 46 290 74 282 110 Z", HAIR)
        a.ellipse(88, 304, 17, 20, SKIN_D, sw=0, stroke="none")
        a.ellipse(424, 304, 17, 20, SKIN_D, sw=0, stroke="none")
    a.shine("M150 170 C170 148 196 138 224 136")
    e2_face(a, 256, 310, 62, 18, cheek_dx=106, cheek_dy=42, w=18)
    return a


@word
def onaka():
    a = Art()
    from lib import _tx_path
    SH_D = "#e9bd3c"
    with a.part():                                      # short legs
        a.sil(e2_cap(214, 430, 210, 484, 50, 46), SKIN)
        a.sil(e2_cap(298, 430, 302, 484, 50, 46), SKIN)
    with a.part():                                      # shorts
        a.sil("M164 404 C200 426 312 426 348 404 L354 452 C355 462 348 468 338 468 L272 468 L256 452 "
              "L240 468 L174 468 C164 468 157 462 158 452 Z", BLUE)
    with a.part():                                      # the round tummy is the star
        a.sil_ellipse(256, 366, 112, 84, SKIN)
        a.blob("M170 404 C204 436 308 436 342 404 C322 432 292 444 256 444 C220 444 190 432 170 404 Z", SKIN_D,
               fill_opacity="0.55")
    with a.part():                                      # arms: both hands hold the tummy
        a.sil(taper([(170, 296, 128, 318, 124, 366, 172, 380)], 44, 46), SKIN)
        a.sil(taper([(342, 296, 384, 318, 388, 366, 340, 380)], 44, 46), SKIN)
    with a.part():                                      # shirt, lifted over the tummy
        a.sil("M192 262 C214 254 298 254 320 262 C346 270 364 290 368 316 C370 328 362 336 350 332 "
              "C300 312 212 312 162 332 C150 336 142 328 144 316 C148 290 166 270 192 262 Z", YEL)
        a.blob("M146 310 C200 288 312 288 366 310 L368 316 C370 328 362 336 350 332 C300 312 212 312 162 332 "
               "C150 336 142 328 144 316 Z", SH_D)
    k, tx, ty = 0.62, 256 - 0.62 * 256, 2               # the head: the same child as あたま, smaller
    T = lambda d: _tx_path(d, k, tx, ty)
    with a.part():
        for x in (94, 418):
            a.sil_ellipse(k * x + tx, k * 304 + ty, k * 38, k * 40, SKIN)
        a.sil(T("M256 120 C356 120 424 196 424 294 C424 392 350 462 256 462 C162 462 88 392 88 294 "
                "C88 196 156 120 256 120 Z"), SKIN)
        a.sil(T("M90 270 C66 138 166 100 256 102 C346 100 446 138 422 270 C404 226 352 198 306 212 "
                "C280 182 224 188 202 214 C160 208 108 228 90 270 Z"), HAIR)
        a.sil(T("M246 110 C222 58 262 14 308 34 C288 46 290 74 282 110 Z"), HAIR)
        for x in (88, 424):
            a.ellipse(k * x + tx, k * 304 + ty, k * 17, k * 20, SKIN_D, sw=0, stroke="none")
    a.shine(T("M150 170 C170 148 196 138 224 136"), sw=6)
    e2_face(a, 256, k * 312 + ty, 38, 12, cheek_dx=66, cheek_dy=26, w=12)
    a.ellipse(256, 378, 7, 9, "#e89a76", sw=6)
    a.shine("M190 362 C194 344 206 332 222 326", sw=8)
    return a


@word
def hoppe():
    a = Art()
    with a.part():                                      # a face with puffed-up cheeks, hair on top
        a.sil("M256 104 C366 104 432 176 434 262 C466 276 476 320 462 358 C446 400 404 414 372 406 "
              "C342 438 300 452 256 452 C212 452 170 438 140 406 C108 414 66 400 50 358 C36 320 46 276 78 262 "
              "C80 176 146 104 256 104 Z", SKIN)
        a.sil("M74 270 C58 150 150 96 256 98 C362 96 454 150 438 270 C418 218 372 192 330 208 "
              "C300 182 212 182 182 208 C140 192 94 218 74 270 Z", HAIR)
    a.ellipse(122, 344, 52, 46, CHEEK, sw=0, stroke="none", fill_opacity="0.8")
    a.ellipse(390, 344, 52, 46, CHEEK, sw=0, stroke="none", fill_opacity="0.8")
    for s in (-1, 1):
        x = 256 + s * 78
        a.ink([(x - 26, 300, x - 16, 270, x + 16, 270, x + 26, 300)], 10, a=0.4, b=0.4)
        for k in (-1, 0, 1):
            cx = 256 + s * 134 + k * 19
            a.path(f"M{cx - 6} 358 L{cx + 6} 332", stroke=WHITE, sw=7)
    a.path("M232 340 C240 356 256 352 256 340 C256 352 272 356 280 340", sw=8)
    a.shine("M150 152 C176 126 210 114 244 112")
    return a


# ----------------------------------------------------- costumes (D178) ---
# --- batch H helpers begin (へんしん・おしごと: かぶる物と ふくの ひとそろい。人は描かない) ---
H_NECK_ROUND = "M212 200 C226 222 286 222 300 200"
H_NECK_FLAT = "M204 200 L308 200"
H_TOP = (" L352 212 C368 216 378 226 384 242 L424 356 C429 370 424 380 410 384 "
         "L382 392 C370 396 362 390 358 378 L346 318 C348 370 350 420 350 456 C350 472 342 480 326 480 "
         "L186 480 C170 480 162 472 162 456 C162 420 164 370 166 318 L154 378 C150 390 142 396 130 392 "
         "L102 384 C88 380 83 370 88 356 L128 242 C134 226 144 216 160 212 Z")
H_HEM = "M162 446 L350 446 L350 456 C350 472 342 480 326 480 L186 480 C170 480 162 472 162 456 Z"


def h_out(t):
    return 384 + 40 * t, 242 + 114 * t


def h_in(t):
    return 338 + 20 * t, 258 + 120 * t


def h_sleeve_band(a, t0, t1, col):
    """A band across both sleeves of h_top (t = 0 at the shoulder, 1 at the end of the sleeve)."""
    d = e2_poly([h_out(t0), h_out(t1), h_in(t1), h_in(t0)])
    a.blob(d, col)
    a.blob(mirror(d), col)


def h_cuff(a, col, t=0.84):
    (ox, oy), (ix, iy) = h_out(t), h_in(t)
    d = (f"M{e2_f(ox)} {e2_f(oy)} L424 356 C429 370 424 380 410 384 L382 392 C370 396 362 390 358 378 "
         f"L{e2_f(ix)} {e2_f(iy)} Z")
    a.blob(d, col)
    a.blob(mirror(d), col)


def h_band(a, y0, y1, col):
    """A band across the body of h_top (stays inside the side edges)."""
    xl = lambda y: 167 - 4 * min(1, max(0, (y - 318) / 138))
    a.blob(e2_poly([(xl(y0), y0), (512 - xl(y0), y0), (512 - xl(y1), y1), (xl(y1), y1)]), col)


def h_top(a, col, shade, cuff=None, flat=False):
    """Inside a part: a long-sleeved top laid flat. Shoulders at y = 200, hem at y = 480, centre x = 256."""
    a.sil((H_NECK_FLAT if flat else H_NECK_ROUND) + H_TOP, col)
    a.blob(H_HEM, shade)
    h_cuff(a, cuff or shade)
    e2_ink2(a, [(346, 326, 346, 302, 342, 284, 334, 270)], 8, 1, 0)


def h_gem(a, x, y, r, col):
    with a.part(ow=6):
        a.sil_ellipse(x, y, r, r, col)
    a.dot(x - r * 0.3, y - r * 0.3, r * 0.3, WHITE)
# --- batch H helpers end ---


@word
def ninja():
    a = Art()
    IN, IN_D, IN_L = "#4a4f8c", "#383c70", "#7f86c4"
    with a.part(ow=9):                                  # the tails of the knot (behind the hood)
        a.sil("M330 104 C356 84 386 82 404 96 C388 104 372 116 352 124 Z", RED)
        a.sil("M330 112 C360 116 384 134 392 158 C370 156 348 146 328 132 Z", RED_D)
    with a.part():                                      # hood
        a.sil("M256 34 C314 34 344 72 344 112 C344 152 312 178 256 178 C200 178 168 152 168 112 "
              "C168 72 198 34 256 34 Z", IN)
        a.blob("M310 52 C336 70 344 92 344 112 C344 152 312 178 256 178 C296 166 324 126 310 52 Z", IN_D)
        a.blob(e2_rr(168, 76, 176, 20, 0), RED)          # headband
        a.blob(e2_rr(318, 76, 26, 20, 0), RED_D)
    with a.part(ow=6):                                  # the opening for the eyes
        a.sil(e2_rr(198, 106, 116, 34, 17), "#2a2c52")
    with a.part(ow=6):                                  # forehead plate
        a.sil(e2_rr(226, 70, 60, 30, 8), "#dfe6ec")
    a.blob(e2_rr(226, 88, 60, 12, 6), "#b9c4cf")
    with a.part():                                      # top
        h_top(a, IN, IN_D, flat=True)
        e2_collar(a, IN_L, IN_D, x=256, y=200, obi=372)
    with a.part():                                      # sash
        a.sil(e2_rr(156, 368, 200, 40, 8), RED)
        a.blob(e2_rr(156, 392, 200, 16, 8), RED_D)
    with a.part(ow=9):                                  # knot
        a.sil("M208 388 C196 410 190 436 194 462 C212 452 224 424 226 392 Z", RED)
        a.sil("M214 388 C232 404 250 428 252 452 C232 448 214 428 206 398 Z", RED_D)
    a.sil_ellipse(214, 388, 16, 15, RED)
    a.shine("M196 96 C200 76 212 60 230 50")
    a.shine("M108 352 L130 290")
    return a


@word
def ohimesama():
    a = Art()
    PK, PK_D, PK_L, GOLD_D = "#f58fb0", "#e2709a", "#fcd3df", "#e9b62e"
    with a.part():                                      # tiara
        a.sil("M180 146 C180 118 194 96 210 82 C220 102 232 114 240 116 C244 90 250 62 256 44 "
              "C262 62 268 90 272 116 C280 114 292 102 302 82 C318 96 332 118 332 146 C332 158 324 164 312 164 "
              "L200 164 C188 164 180 158 180 146 Z", YEL2)
        a.blob("M181 140 L331 140 C332 142 332 144 332 146 C332 158 324 164 312 164 L200 164 "
               "C188 164 180 158 180 146 C180 144 180 142 181 140 Z", GOLD_D)
    for x, y in ((210, 80), (256, 42), (302, 80)):
        with a.part(ow=7):
            a.sil_ellipse(x, y, 11, 11, YEL2)
    h_gem(a, 256, 118, 15, PK)
    h_gem(a, 214, 130, 9, "#6cb6e8")
    h_gem(a, 298, 130, 9, "#6cb6e8")
    with a.part():                                      # puff sleeves
        a.sil_ellipse(178, 244, 48, 40, PK_L)
        a.sil_ellipse(334, 244, 48, 40, PK_L)
        a.blob("M132 256 C146 282 190 290 222 268 C200 300 140 296 132 256 Z", "#f7b3c8")
        a.blob(mirror("M132 256 C146 282 190 290 222 268 C200 300 140 296 132 256 Z"), "#f7b3c8")
    with a.part():                                      # skirt
        a.sil("M204 304 L308 304 C356 346 394 408 402 456 C404 472 394 482 380 480 C300 494 212 494 132 480 "
              "C118 482 108 472 110 456 C118 408 156 346 204 304 Z", PK)
        a.blob("M114 436 C200 456 312 456 398 436 L402 456 C404 472 394 482 380 480 C300 494 212 494 132 480 "
               "C118 482 108 472 110 456 Z", PK_L)
        a.ink([(114, 436, 200, 456, 312, 456, 398, 436)], 6, a=1, b=1, col=PK_D)
        a.ink([(230, 330, 222, 370, 210, 410, 196, 446)], 8, a=0, b=0, col=PK_D)
        a.ink([(282, 330, 290, 370, 302, 410, 316, 446)], 8, a=0, b=0, col=PK_D)
        for x, y in ((160, 420), (256, 432), (352, 420)):
            a.blob(e2_star(x, y, 13, 6), YEL)
    with a.part():                                      # bodice
        a.sil("M212 204 C232 228 280 228 300 204 L324 216 C320 252 314 286 310 314 L202 314 "
              "C198 286 192 252 188 216 Z", PK)
        a.blob("M200 208 L212 204 C232 228 280 228 300 204 L312 208 C292 250 220 250 200 208 Z", PK_L)
        a.ink([(200, 208, 220, 250, 292, 250, 312, 208)], 6, a=1, b=1, col=PK_D)
    with a.part():                                      # sash
        a.sil(e2_rr(198, 296, 116, 28, 8), YEL2)
    with a.part(ow=9):                                  # bow
        for d in ("M256 310 C232 280 190 286 192 310 C194 334 232 336 256 310 Z",
                  "M256 310 C280 280 322 286 320 310 C318 334 280 336 256 310 Z"):
            a.sil(d, YEL2)
    a.sil_ellipse(256, 310, 13, 12, GOLD_D)
    h_gem(a, 256, 268, 10, YEL)
    a.shine("M150 420 C156 396 166 376 180 356")
    return a


@word
def ousama():
    a = Art()
    GOLD_D, FUR, FUR_D = "#e9b62e", "#fffaf0", "#d9e6f0"
    with a.part():                                      # crown
        a.sil("M178 166 L160 76 C158 66 166 62 174 68 L212 104 L246 52 C252 44 260 44 266 52 L300 104 "
              "L338 68 C346 62 354 66 352 76 L334 166 Z", YEL2)
        a.blob("M172 136 L340 136 L334 166 L178 166 Z", GOLD_D)
        a.blob("M318 88 L338 68 C346 62 354 66 352 76 L334 166 L308 166 Z", GOLD_D)
    for x, y in ((166, 66), (256, 42), (346, 66)):
        with a.part(ow=7):
            a.sil_ellipse(x, y, 13, 13, RED)
    h_gem(a, 256, 150, 11, RED)
    h_gem(a, 214, 150, 8, "#6cb6e8")
    h_gem(a, 298, 150, 8, "#6cb6e8")
    with a.part():                                      # cloak
        a.sil("M190 236 C214 220 298 220 322 236 C374 292 412 384 420 452 C422 470 412 480 394 480 "
              "L118 480 C100 480 90 470 92 452 C100 384 138 292 190 236 Z", RED)
        a.blob("M322 236 C374 292 412 384 420 452 C422 470 412 480 394 480 L360 480 C372 400 360 300 322 236 Z", RED_D)
        a.blob("M95 438 L417 438 C420 444 420 448 420 452 C422 470 412 480 394 480 L118 480 "
               "C100 480 90 470 92 452 C92 448 92 444 95 438 Z", FUR)
        a.blob(e2_poly([(236, 250), (276, 250), (282, 440), (230, 440)]), FUR)
        a.blob("M118 470 L394 470 C402 470 410 468 416 462 C420 472 410 480 394 480 L118 480 "
               "C102 480 92 472 96 462 C102 468 110 470 118 470 Z", FUR_D)
        e2_line(a, 95, 438, 230, 438, 6)
        e2_line(a, 282, 438, 417, 438, 6)
        e2_line(a, 236, 262, 230, 438, 6)
        e2_line(a, 276, 262, 282, 438, 6)
        for x, y in ((256, 310), (250, 372), (262, 424), (130, 458), (190, 462), (322, 462), (382, 458), (256, 462)):
            a.ellipse(x, y, 5, 8, O, sw=0, stroke="none")
    with a.part():                                      # fur collar
        a.sil("M170 240 C170 214 206 198 256 198 C306 198 342 214 342 240 C342 264 322 280 298 272 "
              "C284 288 228 288 214 272 C190 280 170 264 170 240 Z", FUR)
        a.blob("M172 250 C184 266 200 268 214 262 C228 276 284 276 298 262 C312 268 328 266 340 250 "
               "C336 270 318 278 298 272 C284 288 228 288 214 272 C194 278 176 270 172 250 Z", FUR_D)
        for x, y in ((200, 234), (238, 246), (274, 246), (312, 234)):
            a.ellipse(x, y, 5, 8, O, sw=0, stroke="none")
    h_gem(a, 256, 276, 14, YEL2)
    a.shine("M146 400 C154 366 166 336 182 308")
    return a


@word
def mahoutsukai():
    a = Art()
    PU, PU_D, PU_L = "#8e6fd8", "#7257be", "#b39cf0"
    with a.part():                                      # brim
        a.sil_ellipse(256, 152, 116, 26, PU)
        a.blob("M146 158 C190 176 322 176 366 158 C350 172 310 178 256 178 C202 178 162 172 146 158 Z", PU_D)
    with a.part():                                      # cone, tip bent to the side
        a.sil("M192 148 C210 110 226 66 268 38 C292 24 322 30 330 48 C312 44 298 50 296 66 "
              "C300 96 310 122 322 148 C290 164 224 164 192 148 Z", PU)
        a.blob("M296 66 C300 96 310 122 322 148 C310 154 298 158 284 160 C286 126 284 96 274 70 Z", PU_D)
        a.blob("M202 126 C240 140 280 140 312 126 L322 148 C290 164 224 164 192 148 Z", YEL2)
        a.ink([(202, 126, 240, 140, 280, 140, 312, 126)], 6, a=1, b=1)
        a.blob(e2_star(252, 92, 17, 8), YEL)
    with a.part():                                      # robe with wide sleeves
        a.sil("M214 204 C230 224 282 224 298 204 L344 216 L438 328 C446 340 442 352 430 358 L392 378 "
              "C382 382 374 380 368 370 L342 326 L360 460 C362 474 354 482 342 482 L170 482 "
              "C158 482 150 474 152 460 L170 326 L144 370 C138 380 130 382 120 378 L82 358 "
              "C70 352 66 340 74 328 L168 216 Z", PU)
        a.blob("M155 444 L357 444 L360 460 C362 474 354 482 342 482 L170 482 C158 482 150 474 152 460 Z", PU_D)
        for d in ("M420 308 L438 328 C446 340 442 352 430 358 L392 378 C382 382 374 380 368 370 L356 350 Z",):
            a.blob(d, YEL2)
            a.blob(mirror(d), YEL2)
        a.blob("M202 208 L214 204 C230 224 282 224 298 204 L310 208 C296 262 216 262 202 208 Z", YEL2)
        a.blob("M222 214 C240 226 272 226 290 214 C280 240 232 240 222 214 Z", PU_D)
        a.ink([(202, 208, 216, 262, 296, 262, 310, 208)], 6, a=1, b=1)
        e2_ink2(a, [(342, 330, 338, 306, 332, 288, 322, 272)], 8, 1, 0)
        a.blob(e2_star(256, 340, 34, 16), YEL)
        for x, y, r in ((200, 410, 13), (312, 410, 13), (256, 432, 10), (124, 326, 11), (388, 326, 11)):
            a.blob(e2_star(x, y, r, r * 0.46), PU_L)
    a.shine("M222 118 C230 96 242 78 256 64")
    a.shine("M176 420 L184 350")
    return a


@word
def kaizoku():
    a = Art()
    BK, BK_D, BELT = "#4a4656", "#35323f", "#9c6238"
    with a.part():                                      # hat
        a.sil("M140 154 C136 108 186 50 256 44 C326 50 376 108 372 154 C370 172 356 178 340 172 "
              "C300 158 212 158 172 172 C156 178 142 172 140 154 Z", BK)
        a.blob("M312 68 C352 92 376 124 372 154 C370 172 356 178 340 172 C330 168 320 166 310 164 "
               "C330 136 332 100 312 68 Z", BK_D)
        a.ink([(160, 148, 160, 110, 200, 66, 256, 62), (256, 62, 312, 66, 352, 110, 352, 148)], 9, a=0.5, b=0.5, col=YEL2)
    a.circle(256, 88, 8, "none", stroke=WHITE, sw=7)    # anchor mark
    a.path("M256 96 L256 138 M240 108 L272 108 M232 122 C236 142 276 142 280 122", stroke=WHITE, sw=7)
    with a.part():                                      # striped shirt
        h_top(a, CREAM, "#f1e2c8")
        for y in (236, 284, 332, 444):
            h_band(a, y, y + 22, RED)
        for t in (0.2, 0.52):
            h_sleeve_band(a, t, t + 0.16, RED)
        e2_ink2(a, [(346, 326, 346, 302, 342, 284, 334, 270)], 8, 1, 0)
    with a.part(ow=9):                                  # neckerchief
        a.sil("M206 202 C226 226 286 226 306 202 L318 206 C300 232 280 250 256 262 C232 250 212 232 194 206 Z", RED)
    with a.part():                                      # belt
        a.sil(e2_rr(156, 398, 200, 36, 8), BELT)
    with a.part(ow=7):
        a.sil(e2_rr(232, 392, 48, 48, 10), YEL2)
    a.blob(e2_rr(246, 406, 20, 20, 5), BELT)
    a.shine("M176 132 C180 104 196 82 218 68")
    a.shine("M108 352 L130 290")
    return a


@word
def daiku():
    a = Art()
    HEL, HEL_D, SH, SH_D, BELT, POUCH = "#f7c948", "#e5ae22", "#8cc0ea", "#6ea9da", "#9c6238", "#c98a4e"
    with a.part():                                      # hard hat
        a.sil("M166 150 C166 86 204 42 256 42 C308 42 346 86 346 150 Z", HEL)
        a.blob("M312 64 C336 86 346 116 346 150 L318 150 C324 118 322 90 312 64 Z", HEL_D)
        a.blob(e2_rr(242, 42, 28, 96, 0), "#fbdc78")
        e2_line(a, 242, 50, 242, 138, 6, 0, 1, col=HEL_D)
        e2_line(a, 270, 50, 270, 138, 6, 0, 1, col=HEL_D)
    with a.part():                                      # brim
        a.sil(e2_rr(142, 140, 228, 30, 15), HEL)
        a.blob(e2_rr(142, 156, 228, 14, 7), HEL_D)
    with a.part(ow=6):                                  # safety mark
        a.sil_ellipse(256, 104, 24, 24, WHITE)
    a.blob(e2_rr(250, 88, 12, 32, 2), "#3aa35c")
    a.blob(e2_rr(240, 98, 32, 12, 2), "#3aa35c")
    with a.part():                                      # work shirt
        h_top(a, SH, SH_D)
        a.blob("M200 203 L212 200 C226 222 286 222 300 200 L312 203 C304 226 284 246 256 262 C228 246 208 226 200 203 Z", WHITE)
        a.blob("M222 212 C240 224 272 224 290 212 C282 232 270 244 256 252 C242 244 230 232 222 212 Z", SH_D)
        a.ink([(200, 203, 208, 226, 228, 246, 256, 262)], 6, a=1, b=1)
        a.ink([(312, 203, 304, 226, 284, 246, 256, 262)], 6, a=1, b=1)
        e2_line(a, 256, 262, 256, 392, 6, 1, 1)
        for y in (296, 340):
            a.dot(270, y, 6, WHITE)
    with a.part():                                      # tool belt
        a.sil(e2_rr(154, 388, 204, 30, 8), BELT)
    with a.part(ow=7):                                  # pencil and folding ruler
        a.sil(e2_poly([(196, 420), (196, 364), (205, 348), (214, 364), (214, 420)]), RED)
        a.sil(e2_rr(292, 344, 22, 80, 4), YEL)
        a.sil(e2_rr(318, 356, 22, 68, 4), YEL)
    a.blob(e2_poly([(199, 362), (205, 350), (211, 362)]), "#f6dcb8")
    for y in (358, 372, 386):
        e2_line(a, 292, y, 304, y, 4)
        e2_line(a, 318, y + 10, 330, y + 10, 4)
    with a.part(ow=9):                                  # pouches
        a.sil("M176 404 L236 404 L236 452 C236 464 228 470 218 470 L194 470 C184 470 176 464 176 452 Z", POUCH)
        a.sil("M276 404 L340 404 L340 452 C340 464 332 470 322 470 L294 470 C284 470 276 464 276 452 Z", POUCH)
    a.blob(e2_rr(176, 404, 60, 14, 0), BELT)
    a.blob(e2_rr(276, 404, 64, 14, 0), BELT)
    a.shine("M190 122 C192 96 204 74 222 60")
    a.shine("M108 352 L130 290")
    return a


@word
def sensei():
    a = Art()
    SH, SH_D, AP, AP_D, AP_L = "#fff0b8", "#f3d98a", "#f7a8b3", "#ee8a9c", "#fcd3df"
    with a.part():                                      # shirt
        h_top(a, SH, SH_D)
        a.blob("M200 203 L212 200 C226 222 286 222 300 200 L312 203 C296 240 216 240 200 203 Z", WHITE)
        a.ink([(200, 203, 216, 240, 296, 240, 312, 203)], 6, a=1, b=1)
    with a.part():                                      # apron
        a.sil(e2_poly([(214, 206), (232, 204), (236, 250), (216, 250)]), AP)
        a.sil(e2_poly([(298, 206), (280, 204), (276, 250), (296, 250)]), AP)
        a.sil("M214 244 L298 244 C300 268 302 290 304 308 C324 308 338 310 346 318 L348 474 "
              "C348 486 340 492 330 492 L182 492 C172 492 164 486 164 474 L166 318 C174 310 188 308 208 308 "
              "C210 290 212 268 214 244 Z", AP)
        a.blob("M164 458 L348 458 L348 474 C348 486 340 492 330 492 L182 492 C172 492 164 486 164 474 Z", AP_D)
    with a.part(ow=6):                                  # pocket
        a.sil("M206 384 L306 384 L306 430 C306 442 298 448 288 448 L224 448 C214 448 206 442 206 430 Z", AP_L)
    a.blob(e2_rr(206, 384, 100, 12, 0), WHITE)
    with a.part(ow=6):                                  # tulip name tag
        a.sil("M238 264 C244 270 250 272 251 266 C252 262 254 258 256 256 C258 258 260 262 261 266 "
              "C262 272 268 270 274 264 C278 288 270 300 256 300 C242 300 234 288 238 264 Z", RED)
    with a.part(ow=6):                                  # a chick patch on the pocket
        a.sil_ellipse(256, 420, 17, 15, YEL)
    a.dot(250, 417, 2.6, O)
    a.dot(262, 417, 2.6, O)
    a.blob(e2_poly([(252, 423), (260, 423), (256, 429)]), "#f6a04d")
    a.shine("M186 440 L188 360")
    a.shine("M108 352 L130 290")
    return a


@word
def oishasan():
    a = Art()
    CO, CO_D, SH, TUBE, SIL = "#ffffff", "#d7e6f2", "#9fd3f2", "#5a6a80", "#cfd6dd"
    band = [(172, 152, 180, 84, 332, 84, 340, 152)]
    with a.part():                                      # head mirror: band and disc
        a.sil(taper(band, 24, 24, cap=False), "#6ea9da")
    with a.part():
        a.sil_ellipse(256, 96, 44, 44, SIL)
        a.ellipse(256, 96, 30, 30, "#eef4f8", sw=0, stroke="none")
        a.dot(256, 96, 8, TUBE)
    a.shine("M232 86 C236 78 242 72 250 70")
    with a.part():                                      # white coat
        h_top(a, CO, CO_D)
        a.blob(e2_poly([(214, 204), (298, 204), (256, 292)]), SH)
        a.blob("M200 203 L212 200 C222 216 234 222 246 222 L256 292 C232 270 210 240 200 203 Z", CO)
        a.blob(mirror("M200 203 L212 200 C222 216 234 222 246 222 L256 292 C232 270 210 240 200 203 Z"), CO)
        a.blob(e2_poly([(246, 222), (266, 222), (262, 240), (270, 280), (256, 292), (242, 280), (250, 240)]), "#e5534b")
        a.ink([(200, 203, 210, 240, 232, 270, 256, 292)], 6, a=1, b=1)
        a.ink([(312, 203, 302, 240, 280, 270, 256, 292)], 6, a=1, b=1)
        e2_line(a, 256, 292, 256, 480, 6, 1, 1)
        for y in (330, 384, 438):
            a.dot(272, y, 6, CO_D)
            a.circle(272, y, 6, "none", sw=4)
    with a.part(ow=5):                                  # pockets
        a.sil(e2_rr(288, 296, 44, 40, 6), CO)
        a.sil(e2_rr(180, 400, 56, 50, 8), CO)
    with a.part(ow=5):                                  # pen
        a.sil(e2_rr(304, 280, 10, 28, 3), BLUE)
    with a.part(ow=6):                                  # stethoscope
        a.sil(taper([(214, 206, 204, 260, 204, 316, 222, 344), (222, 344, 236, 362, 262, 356, 268, 336)], 11, 11, cap=False), TUBE)
        a.sil(taper([(298, 206, 306, 250, 300, 300, 268, 336)], 11, 11, cap=False), TUBE)
        a.sil(taper([(222, 346, 214, 366, 212, 384, 212, 400)], 11, 11, cap=False), TUBE)
    with a.part(ow=7):
        a.sil_ellipse(212, 408, 22, 22, SIL)
    a.dot(212, 408, 11, "#eef4f8")
    a.shine("M108 352 L130 290")
    return a


@word
def omawarisan():
    a = Art()
    NV, NV_D, VIS = "#34507e", "#293f66", "#2a2f45"
    with a.part():                                      # cap
        a.sil("M160 112 C156 72 204 48 256 48 C308 48 356 72 352 112 C350 126 340 134 328 136 L326 166 "
              "L186 166 L184 136 C172 134 162 126 160 112 Z", NV)
        a.blob("M184 136 L328 136 L326 166 L186 166 Z", NV_D)
        a.blob("M320 62 C344 74 354 92 352 112 C350 126 340 134 328 136 L308 136 C324 114 328 88 320 62 Z", NV_D)
        a.ink([(184, 136, 232, 144, 280, 144, 328, 136)], 6, a=1, b=1)
        a.blob(e2_rr(186, 146, 140, 8, 0), YEL2)
    with a.part():                                      # visor
        a.sil("M182 164 C210 156 302 156 330 164 C346 180 326 194 256 194 C186 194 166 180 182 164 Z", VIS)
    a.shine("M214 180 C230 184 250 186 270 186", sw=6)
    with a.part(ow=6):                                  # badge
        a.sil(e2_star(256, 102, 26, 14), YEL2)
    a.dot(256, 102, 6, "#e5ae22")
    with a.part():                                      # uniform
        h_top(a, NV, NV_D)
        a.blob(e2_poly([(214, 204), (298, 204), (256, 288)]), SKY)
        a.blob("M200 203 L212 200 C222 216 234 222 246 222 L256 288 C232 268 210 240 200 203 Z", NV)
        a.blob(mirror("M200 203 L212 200 C222 216 234 222 246 222 L256 288 C232 268 210 240 200 203 Z"), NV)
        a.blob(e2_poly([(246, 222), (266, 222), (262, 240), (268, 276), (256, 288), (244, 276), (250, 240)]), NV_D)
        a.ink([(200, 203, 210, 240, 232, 268, 256, 288)], 6, a=1, b=1)
        a.ink([(312, 203, 302, 240, 280, 268, 256, 288)], 6, a=1, b=1)
        e2_line(a, 256, 288, 256, 480, 6, 1, 1)
        for y in (322, 356, 440):
            a.dot(256, y, 9, YEL2)
        h_sleeve_band(a, 0.74, 0.8, YEL2)
    with a.part(ow=6):                                  # chest badge
        a.sil(e2_star(306, 302, 20, 10), YEL2)
    with a.part():                                      # belt
        a.sil(e2_rr(156, 380, 200, 34, 8), VIS)
    with a.part(ow=7):
        a.sil(e2_rr(234, 376, 44, 42, 8), YEL2)
    a.blob(e2_rr(247, 389, 18, 16, 4), "#e5ae22")
    a.shine("M186 104 C190 86 202 72 220 64")
    a.shine("M108 352 L130 290")
    return a


@word
def shouboushi():
    a = Art()
    OR, OR_D, HEL, HEL_D, REF, SILV = "#f28c38", "#d97324", "#e8eef3", "#bcc8d3", "#fbe36a", "#e8eef3"
    with a.part():                                      # neck flap (behind the helmet)
        a.sil("M176 130 L336 130 L352 192 C354 202 348 208 338 208 L174 208 C164 208 158 202 160 192 Z", OR)
        a.blob("M158 186 L354 186 L352 192 C354 202 348 208 338 208 L174 208 C164 208 158 202 160 192 Z", REF)
    with a.part():                                      # helmet
        a.sil("M166 150 C166 86 204 42 256 42 C308 42 346 86 346 150 Z", HEL)
        a.blob("M312 64 C336 86 346 116 346 150 L318 150 C324 118 322 90 312 64 Z", HEL_D)
        a.blob(e2_poly([(170, 122), (342, 122), (346, 150), (166, 150)]), RED)
        e2_line(a, 170, 122, 342, 122, 6)
    with a.part():                                      # brim
        a.sil(e2_rr(142, 142, 228, 28, 14), HEL)
        a.blob(e2_rr(142, 156, 228, 14, 7), HEL_D)
    with a.part(ow=6):                                  # badge
        a.sil(e2_star(256, 92, 30, 15), YEL2)
    a.dot(256, 92, 7, "#e5ae22")
    with a.part():                                      # coat
        h_top(a, OR, OR_D)
        h_band(a, 286, 314, REF)
        h_band(a, 294, 306, SILV)
        h_band(a, 410, 438, REF)
        h_band(a, 418, 430, SILV)
        h_sleeve_band(a, 0.56, 0.78, REF)
        h_sleeve_band(a, 0.63, 0.71, SILV)
        a.blob("M200 203 L212 200 C226 222 286 222 300 200 L312 203 C298 246 214 246 200 203 Z", NAVY)
        a.ink([(200, 203, 214, 246, 298, 246, 312, 203)], 6, a=1, b=1)
        a.blob(e2_rr(244, 236, 24, 244, 0), OR_D)
        e2_line(a, 244, 240, 244, 480, 6, 1, 1)
        e2_line(a, 268, 240, 268, 480, 6, 1, 1)
        e2_ink2(a, [(346, 326, 346, 302, 342, 284, 334, 270)], 8, 1, 0)
    for y in (262, 350, 386):
        with a.part(ow=5):
            a.sil(e2_rr(238, y, 36, 14, 5), SILV)
    a.shine("M186 116 C188 92 200 72 218 60")
    a.shine("M108 352 L130 290")
    return a


# ---- household (いえの なか。D185) ----
# いえの なかの物。顔はつけない。たなの物は少し上から、ゆかの物は下をそろえて、かべの物は正面から。
def hs_glint(a, x, y, n, w=7, op="0.8"):
    """A short white slash (glass, bubbles)."""
    a.path(f"M{x} {y + n} L{x + n * 0.6:g} {y}", stroke=WHITE, sw=w, **{"stroke-opacity": op})


@word
def nabe():
    a = Art()
    POT, POT_D, POT_L, KNOB = "#ef6a4a", "#d5512f", "#f58a68", "#5a4a42"
    with a.part():                                      # side handles
        a.sil(e2_rr(34, 262, 110, 44, 20), KNOB)
        a.sil(e2_rr(368, 262, 110, 44, 20), KNOB)
    with a.part():                                      # lid knob
        a.sil(e2_rr(218, 92, 76, 62, 22), KNOB)
        a.blob(e2_rr(230, 100, 30, 12, 6), "#8a7a70")
    body = ("M92 240 L420 240 L420 368 C420 414 388 440 342 440 L170 440 C124 440 92 414 92 368 Z")
    with a.part():                                      # body
        a.sil(body, POT)
        a.blob("M372 240 L420 240 L420 368 C420 414 388 440 342 440 L170 440 C150 440 132 434 118 424 "
               "C200 432 300 430 344 412 C366 400 372 380 372 350 Z", POT_D)
    with a.part():                                      # lid
        a.sil("M96 232 C96 168 168 132 256 132 C344 132 416 168 416 232 Z", POT)
        a.blob("M340 148 C386 166 416 194 416 232 L372 232 C372 200 362 172 340 148 Z", POT_D)
    with a.part():                                      # rim of the lid
        a.sil(e2_rr(76, 218, 360, 36, 18), POT_L)
        a.blob(e2_rr(76, 238, 360, 16, 8), POT)
    a.shine("M150 204 C156 180 176 164 204 156")
    a.shine("M122 292 L122 372", sw=9)
    return a


@word
def owan():
    a = Art()
    R, RD, IN, GOLD = "#d9453c", "#bd332e", "#3d2a26", "#f7c948"
    with a.part(7):                                     # steam
        a.sil(taper([(206, 150, 180, 120, 226, 96, 200, 62)], 20, 8), WHITE)
        a.sil(taper([(300, 150, 330, 116, 280, 90, 308, 52)], 20, 8), WHITE)
    a.sil(d_circ(256, 236, 204, 52), IN)                # inside of the bowl
    with a.part(7):                                     # soup
        a.sil(d_circ(256, 244, 170, 36), "#e8a85a")
    a.blob(d_circ(236, 238, 110, 16), "#f0bb72")
    for x, y in ((190, 240), (300, 232)):               # tofu
        with a.part(5):
            a.sil(e2_rr(x - 20, y - 14, 40, 26, 6), "#fffdf6")
    for x, y in ((250, 256), (350, 250), (238, 226)):   # green onion
        a.dot(x, y, 9, "#6fbd5c")
        a.dot(x, y, 3.5, "#d3efc2")
    body = ("M52 236 C52 264.7 143.3 288 256 288 C368.7 288 460 264.7 460 236 C460 356 384 428 256 428 "
            "C128 428 52 356 52 236 Z")
    with a.part():
        a.sil("M190 410 L322 410 L314 458 C314 466 198 466 198 458 Z", R)
        a.sil(body, R)
        a.blob(d_rim(body, 55, 55, 30), RD)
        a.blob("M196 440 L316 440 L314 458 C314 466 198 466 198 458 Z", RD)
        a.ink([(70, 310, 150, 348, 362, 348, 442, 310)], 9, a=1, b=1, col=GOLD)
        a.ink([(204, 436, 230, 442, 282, 442, 308, 436)], 6, a=0, b=0)
    a.shine("M84 312 C94 352 116 380 146 398", sw=9)
    return a


@word
def hashi():
    a = Art()
    WD, WD_D, TOP_C, REST, REST_D = "#f3c98f", "#dba865", "#e5534b", "#8fcdea", "#6db4d6"
    with a.part():                                      # chopstick rest
        a.sil("M106 296 C122 268 160 276 186 304 C214 334 262 372 268 404 C272 432 240 444 214 424 "
              "C186 402 150 380 122 350 C104 330 98 312 106 296 Z", REST)
        a.blob("M122 350 C150 380 186 402 214 424 C240 444 272 432 268 404 C262 420 240 422 220 406 "
               "C192 384 150 360 122 330 C114 322 108 310 106 296 C98 312 104 330 122 350 Z", REST_D)
    a.dot(140, 312, 9, WHITE)
    a.dot(232, 396, 9, WHITE)

    def stick(tx, ty, ex, ey):
        P = lambda t, k, w: (tx + (ex - tx) * t + k * w * 0.7071 / 2, ty + (ey - ty) * t + k * w * 0.7071 / 2)
        wid = lambda t: 14 + 20 * t
        quad = lambda t0, t1: e2_poly([P(t0, -1, wid(t0)), P(t1, -1, wid(t1)), P(t1, 1, wid(t1)), P(t0, 1, wid(t0))])
        with a.part():
            a.sil(e2_cap(tx, ty, ex, ey, 14, 34), WD)
            a.blob(e2_cap(tx + (ex - tx) * 0.62, ty + (ey - ty) * 0.62, ex, ey, wid(0.62), 34), TOP_C)
            a.blob(quad(0.56, 0.62), YEL2)
            a.blob(quad(0.76, 0.80), YEL2)
            a.blob(quad(0.84, 0.88), YEL2)
            a.blob(e2_poly([P(0.02, 0.2, wid(0.02)), P(0.56, 0.2, wid(0.56)), P(0.56, 1, wid(0.56)), P(0.02, 1, wid(0.02))]), WD_D)

    stick(96, 396, 412, 80)
    stick(152, 440, 456, 136)
    return a


@word
def osara():
    a = Art()
    PL, PL_D = "#fffdf6", "#e6dfd0"
    with a.part():
        a.sil(d_circ(256, 282, 214, 138), PL_D)         # the under side shows as a thick edge
        a.sil(d_circ(256, 262, 214, 138), PL)
    a.blob(c_circ(256, 262, 196, 122) + " " + c_circ(256, 262, 164, 96, ccw=True), BLUE)
    import math
    for i in range(12):
        t = math.radians(i * 30 + 15)
        a.dot(256 + 180 * math.cos(t), 262 + 109 * math.sin(t), 8, WHITE)
    well = d_circ(256, 266, 132, 74)
    a.blob(well, "#f3ecdd")
    a.blob(d_circ(256, 272, 124, 66), PL)
    a.ink(e1_arc(256, 266, 132, 200, 340, ry=74), 6, a=0, b=0, col="#cfc5b0")
    a.shine("M150 252 C160 224 190 206 226 200", sw=8)
    return a


@word
def yakan():
    a = Art()
    Y, YD, DK = "#f9cf4f", "#e6b22e", "#5a4a42"
    with a.part():                                      # handle
        a.sil(taper([(150, 230, 136, -18, 376, -18, 362, 230)], 26, 26, cap=False), DK)
        body = ("M256 176 C340 176 398 204 404 262 L410 366 C412 414 380 438 334 438 L178 438 C132 438 100 414 102 366 "
            "L108 262 C114 204 172 176 256 176 Z")
    with a.part():                                      # spout and body
        a.sil("M132 330 C92 322 66 290 52 232 L98 214 C110 252 126 268 150 268 Z", Y)
        a.sil(body, Y)
        a.blob("M356 196 C384 210 400 232 404 262 L410 366 C412 414 380 438 334 438 L178 438 C160 438 144 434 132 428 "
               "C220 432 310 428 344 408 C366 394 370 370 368 340 L364 262 C364 236 362 214 356 196 Z", YD)
        a.ink([(110, 300, 118, 292, 124, 280, 126, 268)], 7, a=1, b=0)
    with a.part(8):                                     # spout mouth
        a.sil("M44 236 L104 210 L98 196 L40 222 Z", YD)
    with a.part():                                      # lid
        a.sil(e2_rr(180, 160, 152, 30, 15), Y)
        a.blob(e2_rr(180, 176, 152, 14, 7), YD)
    with a.part():                                      # knob
        a.sil(c_circ(256, 140, 20), DK)
    a.shine("M136 276 C140 246 156 224 182 212")
    return a


@word
def sekken():
    a = Art()
    SP, SP_D, SP_L, DISH, DISH_D = "#f9b6d2", "#ee93bb", "#fdd7e6", "#9fd3f2", "#7fbfe6"
    for x, y, r in ((112, 150, 40), (404, 126, 50), (318, 58, 26)):   # bubbles
        with a.part(6):
            a.sil(c_circ(x, y, r), "#dff2fc")
        a.path(f"M{x - r * 0.5:g} {y - r * 0.1:g} C{x - r * 0.5:g} {y - r * 0.4:g} {x - r * 0.3:g} {y - r * 0.55:g} {x - r * 0.05:g} {y - r * 0.58:g}",
               stroke=WHITE, sw=max(4, r * 0.16))
    dish = ("M40 372 C40 350 70 340 110 340 L402 340 C442 340 472 350 472 372 C472 424 400 458 256 458 "
            "C112 458 40 424 40 372 Z")
    with a.part():                                      # dish
        a.sil(dish, DISH)
        a.blob(d_rim(dish, 70, 70, 26), DISH_D)
        a.blob(d_circ(256, 372, 190, 26), "#c4e6f8")
    with a.part():                                      # soap
        a.sil(e2_rr(104, 200, 304, 190, 60), SP_D)
        a.sil(e2_rr(104, 184, 304, 170, 60), SP)
    a.blob(e2_rr(150, 220, 212, 98, 44), SP_L)
    a.blob(e2_rr(160, 232, 192, 86, 38), SP)
    with a.part(6):                                     # foam on the soap
        a.sil(c_circ(366, 196, 22), WHITE)
        a.sil(c_circ(392, 222, 14), WHITE)
        a.sil(c_circ(340, 180, 12), WHITE)
    a.shine("M130 262 C128 236 138 216 160 206", sw=8)
    return a


@word
def haburashi():
    a = Art()
    H, HD, CUP, CUP_D, CUP_IN = "#f47c7c", "#dc5f66", "#8fcdea", "#6db4d6", "#4f93b8"
    T = lambda d: d_tf(d, 1, 250, 410, 13)
    a.sil(d_circ(256, 304, 122, 30), CUP_IN)            # inside of the cup (behind the brush)
    with a.part():                                      # handle and head
        a.sil(T(e2_rr(-19, -350, 38, 350, 19)), H)
        a.sil(T(e2_rr(-24, -356, 48, 150, 22)), H)
        a.blob(T(e2_rr(4, -350, 15, 344, 7)), HD)
    with a.part(8):                                     # bristles
        a.sil(T(e2_rr(-90, -344, 70, 124, 12)), WHITE)
        for y in (-313, -282, -251):
            a.blob(T(e2_rr(-90, y - 3, 62, 6, 3)), "#bcd3e2")
        a.blob(T(e2_rr(-90, -344, 16, 124, 8)), "#dfeaf2")
    with a.part(7):                                     # toothpaste
        a.sil(T("M-106 -330 C-122 -326 -124 -302 -108 -300 C-124 -292 -120 -268 -104 -270 C-118 -260 -112 -240 -96 -244 "
                "L-90 -330 Z"), "#7fd6c4")
    cup = ("M134 304 C134 320.6 188.6 334 256 334 C323.4 334 378 320.6 378 304 L360 440 C358 458 346 466 330 466 "
           "L182 466 C166 466 154 458 152 440 Z")
    with a.part():                                      # front of the cup
        a.sil(cup, CUP)
        a.blob("M330 326 C352 322 370 314 378 304 L360 440 C358 458 346 466 330 466 L300 466 C318 430 328 380 330 326 Z", CUP_D)
        a.blob("M142 366 C200 384 312 384 370 366 L366 396 C310 414 202 414 146 396 Z", WHITE)
    a.shine("M160 350 L168 420", sw=8)
    return a


@word
def kushi():
    a = Art()
    C, CD, CL = "#f7a94b", "#e58f2c", "#fbc57f"
    with a.part(9):
        for i in range(8):
            x = 88 + i * 48
            w = 30 if i in (0, 7) else 22
            a.sil(e2_cap(x, 230, x, 404 if i in (0, 7) else 396, w, w - 6), C)
        a.sil("M56 236 C52 150 120 104 256 104 C392 104 460 150 456 236 C456 250 448 256 436 256 L76 256 "
              "C64 256 56 250 56 236 Z", C)
        a.blob("M58 222 L454 222 C456 228 456 232 456 236 C456 250 448 256 436 256 L76 256 C64 256 56 250 56 236 "
               "C56 232 56 228 58 222 Z", CD)
    for x, y in ((176, 172), (256, 164), (336, 172)):
        a.blob(e2_star(x, y, 20, 9), WHITE)
    a.shine("M92 196 C96 160 126 138 170 128", sw=8)
    return a


@word
def isu():
    a = Art()
    CU, CU_D = "#ee6a62", "#d4504c"
    with a.part():                                      # back legs
        a.sil(e2_rr(150, 290, 28, 142, 10), WOOD_D)
        a.sil(e2_rr(354, 290, 28, 142, 10), WOOD_D)
    with a.part():                                      # backrest
        a.sil(e2_rr(150, 110, 30, 190, 12), WOOD)
        a.sil(e2_rr(352, 110, 30, 190, 12), WOOD)
        a.sil("M150 122 C150 92 170 78 200 78 L332 78 C362 78 382 92 382 122 L382 160 C382 172 376 178 364 178 "
              "L168 178 C156 178 150 172 150 160 Z", WOOD)
        a.sil(e2_rr(156, 216, 220, 26, 10), WOOD)
        a.blob("M150 150 L382 150 L382 160 C382 172 376 178 364 178 L168 178 C156 178 150 172 150 160 Z", "#e3a257")
        a.blob(e2_rr(362, 180, 20, 110, 6), "#e3a257")
    a.blob(e2_star(266, 118, 24, 11), CREAM)
    with a.part():                                      # seat and front legs
        a.sil(e2_rr(104, 330, 30, 142, 10), WOOD)
        a.sil(e2_rr(306, 330, 30, 142, 10), WOOD)
        a.sil(c_rpoly([(98, 314), (150, 268), (388, 268), (388, 300), (340, 344), (98, 344)], [10, 10, 10, 10, 10, 10]), WOOD)
        a.blob(e2_poly([(338, 316), (387, 272), (387, 300), (338, 343)]), WOOD_D)
        a.blob(e2_rr(100, 316, 238, 27, 4), "#e3a257")
        a.blob(e2_rr(322, 344, 13, 126, 5), "#e3a257")
        a.blob(e2_rr(120, 344, 13, 126, 5), "#e3a257")
    with a.part(8):                                     # cushion
        a.sil(c_rpoly([(122, 316), (164, 276), (372, 276), (330, 316)], 14), CU_D)
        a.sil(c_rpoly([(122, 306), (164, 266), (372, 266), (330, 306)], 14), CU)
    a.path("M176 280 L312 280", stroke=WHITE, sw=6, **{"stroke-opacity": "0.5"})
    return a


@word
def tsukue():
    a = Art()
    SH = "#e3a257"
    with a.part():                                      # back legs
        a.sil(e2_rr(124, 240, 26, 196, 8), WOOD_D)
        a.sil(e2_rr(362, 240, 26, 196, 8), WOOD_D)
    with a.part():                                      # front legs and the board under the top
        a.sil(e2_rr(74, 240, 36, 232, 10), WOOD)
        a.sil(e2_rr(402, 240, 36, 232, 10), WOOD)
        a.sil(e2_rr(74, 240, 364, 104, 10), WOOD)
        a.blob(e2_rr(96, 250, 14, 220, 6), SH)
        a.blob(e2_rr(424, 250, 14, 220, 6), SH)
        a.blob(e2_rr(74, 244, 364, 16, 0), SH)
    with a.part(6):                                     # drawer
        a.sil(e2_rr(150, 266, 212, 62, 8), WOOD_L)
    with a.part(6):
        a.sil(c_circ(256, 297, 14), RED)
    with a.part():                                      # top
        a.sil(c_rpoly([(48, 214), (98, 160), (414, 160), (464, 214), (464, 240), (48, 240)], [10, 12, 12, 10, 10, 10]), WOOD_L)
        a.blob(c_rpoly([(49, 216), (463, 216), (463, 239), (49, 239)], [0, 0, 9, 9]), WOOD)
        c_line(a, 49, 215, 463, 215, 6, 1, 1)
    a.path("M120 180 L330 180", stroke=WHITE, sw=7, **{"stroke-opacity": "0.55"})
    return a


@word
def futon():
    a = Art()
    MAT, MAT_D, Q, Q_D, CUFF, PIL, PIL_D = "#fffaf0", "#e9dfcc", "#f9c3d0", "#f0a3b8", "#fff4e2", "#fde49a", "#f2c96a"
    P = lambda u, v: (36 + 400 * u + 44 * v, 410 - 190 * v)   # a point on the top of the mattress
    with a.part():                                      # mattress
        a.sil(c_rpoly([P(0, 0), P(0, 1), P(1, 1), (480, 250), (436, 442), (36, 442)], [12, 18, 18, 10, 12, 12]), MAT)
        a.blob(c_rpoly([(37, 414), (435, 414), (435, 441), (37, 441)], [0, 0, 10, 10]), MAT_D)
    with a.part():                                      # pillow
        a.sil(c_rpoly([(63, 376), P(0.05, 0.8), P(0.3, 0.8), (163, 376)], 34), PIL_D)
        a.sil(c_rpoly([P(0.05, 0.22), P(0.05, 0.8), P(0.3, 0.8), P(0.3, 0.22)], 34), PIL)
        a.ink([(104, 330, 112, 322, 124, 318, 136, 320)], 6, a=0, b=0, col=PIL_D)   # a soft dent
    with a.part():                                      # quilt
        a.sil("M200 404 C210 350 228 280 244 228 C320 216 420 216 492 228 C500 250 492 280 484 304 C472 346 458 398 448 452 "
              "C380 464 270 464 204 454 C196 446 196 424 200 404 Z", Q)
        a.blob("M200 412 C270 426 380 426 456 412 C453 426 450 440 448 452 C380 464 270 464 204 454 C196 446 196 428 200 412 Z", Q_D)
        for u, v in ((0.62, 0.2), (0.8, 0.36), (0.98, 0.18), (0.6, 0.62), (0.8, 0.76), (0.97, 0.56)):
            x, y = P(u, v)
            e2_blossom(a, x, y, 21, col=WHITE, mid=YEL2)
        a.blob("M200 404 C210 350 228 280 244 228 C262 225 280 223 298 222 C282 276 264 346 254 404 C250 426 252 446 258 460 "
               "C238 458 220 457 204 454 C196 446 196 424 200 404 Z", CUFF)
        a.ink([(298, 222, 282, 276, 264, 346, 254, 404)], 7, a=1, b=0.6)
    return a


@word
def tansu():
    a = Art()
    SH, KN = "#e3a257", "#c9403a"
    with a.part():                                      # feet
        a.sil(e2_rr(112, 420, 50, 52, 10), WOOD_D)
        a.sil(e2_rr(350, 420, 50, 52, 10), WOOD_D)
    with a.part():                                      # body
        a.sil(e2_rr(92, 84, 328, 356, 16), WOOD)
        a.blob(e2_rr(392, 100, 28, 340, 12), SH)
        a.blob(e2_rr(92, 414, 328, 26, 12), SH)
    for i in range(3):                                  # drawers
        y = 128 + i * 98
        with a.part(6):
            a.sil(e2_rr(118, y, 276, 82, 10), WOOD_L)
        a.blob(e2_rr(120, y + 64, 272, 16, 8), "#efb878")
        for x in (190, 322):
            with a.part(6):
                a.sil(c_circ(x, y + 40, 14), KN)
            a.dot(x - 4, y + 36, 4, "#f0908a")
    with a.part():                                      # top
        a.sil(e2_rr(76, 64, 360, 42, 14), WOOD_L)
        a.blob(e2_rr(76, 88, 360, 18, 9), WOOD)
    a.path("M104 80 L300 80", stroke=WHITE, sw=7, **{"stroke-opacity": "0.55"})
    return a


@word
def tokei():
    a = Art()
    FR, FR_D, FACE, FACE_D = "#4fa8e0", "#3f8fc8", "#fffaf0", "#ece2cf"
    import math
    with a.part():
        a.sil(c_circ(256, 256, 204), FR)
        a.blob(d_rim(d_circ(256, 256, 204), 50, 70, 26), FR_D)
    with a.part(7):
        a.sil(c_circ(256, 256, 158), FACE)
    a.blob(c_circ(256, 256, 158) + " " + c_circ(256, 266, 152, ccw=True), FACE_D)
    for i in range(12):
        t = math.radians(i * 30)
        ux, uy = math.cos(t), math.sin(t)
        if i % 3 == 0:
            a.blob(e2_cap(256 + 112 * ux, 256 + 112 * uy, 256 + 136 * ux, 256 + 136 * uy, 14), RED)
        else:
            a.dot(256 + 128 * ux, 256 + 128 * uy, 7, "#b9a58f")
    for ang, ln, w in ((-150, 74, 22), (-30, 112, 15)):  # hour hand, minute hand (10:10)
        t = math.radians(ang)
        a.blob(e2_cap(256 - 16 * math.cos(t), 256 - 16 * math.sin(t), 256 + ln * math.cos(t), 256 + ln * math.sin(t), w, w * 0.6), O)
    a.dot(256, 256, 15, RED)
    a.dot(256, 256, 6, "#f7a09a")
    a.shine("M92 220 C102 164 138 118 190 94", sw=9)
    return a


@word
def kagami():
    a = Art()
    FR, FR_D, FR_L = "#f7c948", "#e0a92a", "#fbe08a"
    frame = d_circ(256, 276, 168, 206)
    with a.part():                                      # crest on the top
        a.sil(c_circ(256, 62, 34), FR)
        a.sil(c_circ(204, 84, 24), FR)
        a.sil(c_circ(308, 84, 24), FR)
    a.dot(256, 60, 13, RED)
    with a.part():                                      # frame
        a.sil(frame, FR)
        a.blob(d_rim(frame, 50, 70, 22), FR_D)
    glass = d_circ(256, 276, 130, 168)
    c_glass(a, glass, ow=7, col="#cdeaf9")
    a.blob(d_rim(glass, 230, 70, 22), "#e6f5fd")
    a.blob(d_rim(glass, 50, 70, 26), "#aeddf5")
    a.path("M196 268 L262 172", stroke=WHITE, sw=14, **{"stroke-opacity": "0.85"})
    a.path("M232 292 L282 220", stroke=WHITE, sw=8, **{"stroke-opacity": "0.85"})
    a.path("M286 384 L316 340", stroke=WHITE, sw=8, **{"stroke-opacity": "0.7"})
    a.shine("M106 236 C112 176 138 124 180 98", sw=7)
    return a


def omochabako():
    """The toy box of the room (a part, not a word): Content/Art/parts/omochabako.svg."""
    a = Art()
    SH, BR, BR_D = "#e3a257", "#b9794a", "#9c6238"
    with a.part():                                      # lid, open at the back
        a.sil(c_rpoly([(66, 290), (40, 96), (472, 96), (446, 290)], [0, 22, 22, 0]), WOOD_D)
        a.blob(c_rpoly([(92, 290), (72, 124), (440, 124), (420, 290)], [0, 12, 12, 0]), "#b56f35")
    with a.part():                                      # ball
        a.sil(c_circ(150, 234, 62), RED)
        a.blob("M96 204 C130 222 172 222 206 206 C210 216 212 226 212 236 C172 252 128 252 88 236 C88 224 90 214 96 204 Z", WHITE)
    with a.part():                                      # block
        a.sil(d_tf(e2_rr(-48, -48, 96, 96, 12), 1, 262, 226, -12), BLUE)
    a.dot(262, 224, 20, WHITE)
    with a.part():                                      # teddy: the ears and the top of the head
        a.sil(c_circ(326, 186, 26), BR)
        a.sil(c_circ(414, 186, 26), BR)
        a.sil(c_circ(370, 250, 66), BR)
    a.dot(326, 188, 12, "#f2c49a")
    a.dot(414, 188, 12, "#f2c49a")
    with a.part():                                      # box
        a.sil(e2_rr(54, 274, 404, 204, 18), WOOD)
        a.blob(e2_rr(54, 274, 404, 34, 0), WOOD_L)
        a.blob(e2_rr(54, 446, 404, 32, 14), SH)
        a.blob(e2_rr(430, 308, 28, 150, 0), SH)
        c_line(a, 54, 308, 458, 308, 6, 1, 1)
    with a.part(7):                                     # star
        a.sil(e1_star(256, 388, 62, 30), YEL2)
    a.path("M78 291 L240 291", stroke=WHITE, sw=7, **{"stroke-opacity": "0.5"})
    return a


def write_toy_box():
    out = os.path.join(HERE, "..", "..", "Content", "Art", "parts")
    os.makedirs(out, exist_ok=True)
    open(os.path.join(out, "omochabako.svg"), "w").write(omochabako().svg())


def write_swing_parts():
    """The frame and the seat of the swing go to Content/Art/parts/ (D173). Same fit as burango.svg."""
    full, frame, seat, rope = swing_parts()
    params = fit_params([full])
    out = os.path.join(HERE, "..", "..", "Content", "Art", "parts")
    os.makedirs(out, exist_ok=True)
    open(os.path.join(out, "burango-frame.svg"), "w").write(frame.svg(params=params))
    open(os.path.join(out, "burango-seat.svg"), "w").write(seat.svg(params=params))
    open(os.path.join(out, "burango-rope.svg"), "w").write(rope.svg(params=params))
    s, tx, ty = params
    print("swing hooks (fractions of the image):", [(round((s * x + tx) / 512, 4), round((s * 102 + ty) / 512, 4)) for x in (218, 294)],
          "rope length:", round(s * (366 - 102) / 512, 4))
    s2, tx2, ty2 = fit_params([W["suberidai"]()])
    print("slide curve:", [(round((s2 * x + tx2) / 512, 4), round((s2 * y + ty2) / 512, 4)) for x, y in SLIDE_CURVE])


def print_lamps():
    """Where the app lights the lamps (D174): fractions of the image come from these 512 px numbers."""
    for name, xs, y, r, sw in (("shingou", SHINGOU_LAMPS, SHINGOU_Y, SHINGOU_R, 11),
                               ("fumikiri", FUMIKIRI_LAMPS, FUMIKIRI_Y, FUMIKIRI_R, 11)):
        s1, tx1, ty1 = fit_params([W[name]()])
        print(name, "lamps (x, y, r in 512 px; r = lamp without its outline):",
              [(round(s1 * x + tx1, 1), round(s1 * y + ty1, 1), round(s1 * (r - sw / 2), 1)) for x in xs])


# ---------------------------------------------------------- word batches --
# めぐりごとの絵は Scripts/art/words_<名前>.py に書く（`from words import word, ...` で同じ @word が使える）。
# ここで名前順に全部読み込むので、このファイルに足す行はいらない。
def load_batches():
    import glob
    import importlib
    sys.modules.setdefault("words", sys.modules[__name__])   # `python words.py` でも、batch から `import words` が同じ W を指す
    for path in sorted(glob.glob(os.path.join(HERE, "words_*.py"))):
        importlib.import_module(os.path.basename(path)[:-3])


load_batches()


if __name__ == "__main__":
    names = sys.argv[1:] or list(W)
    if not sys.argv[1:] or "omochabako" in names:      # the toy box is a part, not a word
        write_toy_box()
    names = [n for n in names if n != "omochabako"]
    for n in names:
        art = W[n]()
        open(os.path.join(OUT, f"{n}.svg"), "w").write(art.svg(params=art.ground_params()) if n in GROUND else art.svg())
    if not sys.argv[1:] or "burango" in names:
        write_swing_parts()
    if not sys.argv[1:] or "shingou" in names or "fumikiri" in names:
        print_lamps()
