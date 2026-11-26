import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lib import Art, mirror, place, fit_params, O, EYE

OUT = os.path.join(HERE, "..", "..", "Content", "Art", "characters")
YEL = "#f6d36b"
CHEEK = "#ff9aa8"
MOUTH = "#f28a9b"
ZCOL = "#9fb3e6"
POSES = ("normal", "wave", "happy", "sleep", "blink")


def sparkle(a, cx, cy, r):
    k = r * 0.3
    a.path(f"M{cx} {cy-r} L{cx+k} {cy-k} L{cx+r} {cy} L{cx+k} {cy+k} L{cx} {cy+r} L{cx-k} {cy+k} "
           f"L{cx-r} {cy} L{cx-k} {cy-k} Z", fill=YEL, sw=6)


def zee(a, x, y, s):
    p = [(0, 0), (1, 0), (1, .2), (.38, .8), (1, .8), (1, 1), (0, 1), (0, .8), (.62, .2), (0, .2)]
    a.path("M" + " L".join(f"{x + s * u:.1f} {y + s * v:.1f}" for u, v in p) + " Z", fill=ZCOL, sw=6)


def face(a, pose, cx, cy, gap, mouth="smile", dx_blush=None):
    dxb = dx_blush or gap + 34
    if pose in ("happy",):
        for s in (-1, 1):
            x = cx + s * gap
            a.path(f"M{x-14} {cy+6} C{x-8} {cy-12} {x+8} {cy-12} {x+14} {cy+6}", sw=8)
    elif pose in ("sleep", "blink"):  # blink: eyes shut for a moment, mouth still smiling (D175)
        for s in (-1, 1):
            x = cx + s * gap
            a.path(f"M{x-14} {cy} C{x-8} {cy+12} {x+8} {cy+12} {x+14} {cy}", sw=8)
    else:
        for s in (-1, 1):
            x = cx + s * gap
            a.ellipse(x, cy, 14, 17, EYE, sw=0, stroke="none")
            a.dot(x + 5, cy - 7, 5.2, "#ffffff")
    for s in (-1, 1):
        a.ellipse(cx + s * dxb, cy + 32, 16, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.75"})
    my = cy + 34
    if pose == "sleep":
        a.ellipse(cx, my + 4, 7, 8, MOUTH, sw=6)
    elif pose == "happy" or mouth == "open":
        a.path(f"M{cx-18} {my-2} C{cx-18} {my+26} {cx+18} {my+26} {cx+18} {my-2} Z", fill=MOUTH, sw=7)
    else:
        a.path(f"M{cx-13} {my} C{cx-6} {my+10} {cx+6} {my+10} {cx+13} {my}", sw=8)


def arms(a, pose, col, lx, ly, rx, ry):
    """Stubby arms from shoulder points (lx,ly) left and (rx,ry) right."""
    if pose in ("normal", "sleep", "blink"):
        L, R = (lx - 22, ly + 30), (rx + 22, ry + 30)
    elif pose == "wave":
        L, R = (lx - 22, ly + 30), (rx + 40, ry - 54)
    else:
        L, R = (lx - 40, ly - 54), (rx + 40, ry - 54)
    for (sx, sy), (ex, ey) in (((lx, ly), L), ((rx, ry), R)):
        a.tube(f"M{sx} {sy} L{ex} {ey}", col, 46, 24)
    if pose == "wave":
        ex, ey = R
        a.path(f"M{ex+30} {ey-30} C{ex+42} {ey-16} {ex+44} {ey} {ex+40} {ey+14}", sw=7)
        a.path(f"M{ex-14} {ey-40} C{ex} {ey-50} {ex+16} {ey-50} {ex+28} {ey-44}", sw=7)
    if pose == "happy":
        sparkle(a, L[0] - 40, L[1] - 40, 22)
        sparkle(a, R[0] + 40, R[1] - 30, 18)


# ---------------------------------------------------------------- とん ----
def ton(pose):
    C, D = "#f07a4a", "#c9542e"
    a = Art()
    lift = -26 if pose == "happy" else 0
    b = Art()
    for x in (196, 316):
        b.ellipse(x, 424, 38, 18, D)
    arms(b, pose, C, 114, 330, 398, 330)
    body = ("M122 424 C98 424 88 406 92 378 C102 282 154 204 228 186 C242 174 250 160 256 142 "
            "C262 160 270 174 284 186 C358 204 410 282 420 378 C424 406 414 424 390 424 Z")
    b.path(body, fill=C)
    b.ellipse(256, 210, 13, 12, O, sw=0, stroke="none")       # the ink dot ("とめ")
    b.shine("M150 330 C150 300 160 270 176 246")
    face(b, pose, 256, 300, 50)
    place(a, b, 0, lift)
    if pose == "sleep":
        zee(a, 360, 120, 44)
        zee(a, 414, 78, 30)
    return a


# ---------------------------------------------------------------- るん ----
def run(pose):
    C, D = "#58b2ea", "#2f86c4"
    a = Art()
    lift = -30 if pose == "happy" else 0
    b = Art()
    # the "はね" antenna: straight up, then a sharp flick up-left
    if pose == "sleep":
        b.tube("M256 178 L262 128 C266 104 284 96 300 108", D, 34, 14)
    else:
        b.tube("M256 178 L258 120", D, 34, 14)
        b.path("M248 128 C246 98 234 82 206 72 C240 66 272 84 270 124 Z", fill=D, sw=10)
    for x in (212, 300):
        b.ellipse(x, 430, 32, 20, D)
    arms(b, pose, C, 144, 320, 368, 320)
    body = "M256 172 C334 172 376 232 376 304 C376 376 328 432 256 432 C184 432 136 376 136 304 C136 232 178 172 256 172 Z"
    b.path(body, fill=C)
    b.shine("M168 300 C166 270 176 240 194 222")
    face(b, pose, 256, 292, 48, mouth="open")
    place(a, b, 0, lift)
    if pose == "sleep":
        zee(a, 356, 140, 44)
        zee(a, 410, 96, 30)
    return a


# ---------------------------------------------------------------- ひら ----
def hira(pose):
    C, LEAF, VEIN = "#7cc36a", "#f2b84b", "#c98a2a"
    a = Art()
    lift = -26 if pose == "happy" else 0
    b = Art()
    # leaf on the head (ひらひら)
    leaf = "M258 176 C240 140 250 104 290 88 C306 120 298 160 258 176 Z"
    b.path(leaf, fill=LEAF)
    b.path("M262 168 C270 140 280 118 288 100", stroke=VEIN, sw=6)
    arms(b, pose, C, 150, 300, 362, 300)
    # body ending in a sweeping, thinning tail (the "はらい")
    body = ("M256 168 C330 168 376 220 376 286 C376 330 362 360 344 382 C384 398 430 392 470 356 "
            "C452 420 388 452 300 444 C204 436 136 370 136 286 C136 220 182 168 256 168 Z")
    if pose == "sleep":
        body = ("M256 168 C330 168 376 220 376 286 C376 330 362 360 344 382 C380 408 404 440 380 470 "
                "C350 466 330 452 300 444 C204 436 136 370 136 286 C136 220 182 168 256 168 Z")
    b.path(body, fill=C)
    b.shine("M168 290 C166 262 176 234 194 216")
    face(b, pose, 250, 282, 46)
    place(a, b, 0, lift)
    if pose == "sleep":
        zee(a, 360, 120, 44)
        zee(a, 414, 78, 30)
    return a


CHARS = {"ton": ton, "run": run, "hira": hira}

if __name__ == "__main__":
    for name, f in CHARS.items():
        arts = {p: f(p) for p in POSES}
        prm = fit_params(arts.values())
        for p, art in arts.items():
            open(f"{OUT}/{name}-{p}.svg", "w").write(art.svg(params=prm))
