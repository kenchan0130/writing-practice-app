import sys
import os
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "Content", "Art", "words")
sys.path.insert(0, HERE)
from lib import Art, mirror, shift, place, O, EYE

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


@word
def ushi():
    a = Art()
    a.path("M340 400 C385 400 400 370 392 345", sw=10)
    a.path("M392 345 C378 330 386 312 400 320 C414 312 420 332 404 344 Z", fill=O, sw=6)
    a.path(BODY, fill=WHITE)
    a.path("M300 322 C326 314 344 330 344 352 C346 384 320 396 302 386 C284 376 280 336 300 322 Z", fill="#3b2f2a", sw=0, stroke="none")
    a.ellipse(204, 404, 24, 14, "#3b2f2a", sw=0, stroke="none")
    a.path(HOOF_L, fill="#6b5446", sw=9)
    a.path(HOOF_R, fill="#6b5446", sw=9)
    a.path(BODY)
    # horns, ears
    a.path("M178 120 C160 100 160 70 176 64 C190 72 200 96 204 110 Z", fill="#fff1c9")
    a.path(mirror("M178 120 C160 100 160 70 176 64 C190 72 200 96 204 110 Z"), fill="#fff1c9")
    ear = "M140 160 C110 150 66 158 60 178 C70 200 112 204 142 192 Z"
    inner = "M128 168 C110 166 88 170 82 178 C92 188 112 190 130 186 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=WHITE)
    for d in (inner, mirror(inner)):
        a.blob(d, PINK_IN)
    a.path(HEAD, fill=WHITE)
    # patches stay inside the head
    a.blob("M146 160 C150 128 182 106 226 104 C236 128 222 156 196 166 C176 174 156 172 146 160 Z", "#3b2f2a")
    a.ellipse(338, 132, 28, 18, "#3b2f2a", sw=0, stroke="none")
    a.path(HEAD)
    a.path("M236 98 C238 82 252 78 256 90 C262 76 278 82 276 98", fill=WHITE, sw=9)
    # bell
    a.path("M200 306 C230 322 282 322 312 306", stroke=RED, sw=14)
    a.path("M240 320 C240 304 272 304 272 320 L278 348 L234 348 Z", fill=YEL2, sw=9)
    a.dot(256, 352, 6, O)
    # muzzle and face
    a.ellipse(256, 258, 104, 56, PINK)
    a.ellipse(220, 252, 11, 15, O, sw=0, stroke="none")
    a.ellipse(292, 252, 11, 15, O, sw=0, stroke="none")
    a.path("M236 284 C248 294 264 294 276 284", sw=8)
    a.shine("M196 228 C210 220 226 220 236 224")
    a.face(cy=180, blush_y=222)
    return a


@word
def inu():
    a = Art()
    TAN, EAR = "#f2c48d", "#b8794a"
    a.tube("M336 404 C378 398 404 360 396 318 C394 306 400 296 410 292", TAN, 40, 20)
    body(a, TAN, belly=CREAM, toes=True)
    a.path(HEAD, fill=TAN)
    a.ellipse(256, 252, 76, 52, CREAM)
    ear = "M164 108 C120 104 92 146 96 214 C98 250 130 256 142 232 C152 210 160 168 190 116 Z"
    a.path(ear, fill=EAR)
    a.path(mirror(ear), fill=EAR)
    a.path("M236 226 C236 214 276 214 276 226 C276 240 262 246 256 246 C250 246 236 240 236 226 Z", fill=EYE, sw=0, stroke="none")
    a.dot(248, 224, 5, WHITE)
    a.path("M256 246 L256 260 M256 260 C250 274 232 274 230 262 M256 260 C262 274 280 274 282 262", sw=7)
    a.face(cy=178, gap=56, blush_y=222, blush_dx=100)
    a.path("M200 310 C230 328 282 328 312 310", stroke=RED, sw=16)
    a.circle(256, 338, 13, YEL2, sw=8)
    a.shine("M232 108 C250 102 270 102 284 106")
    return a


@word
def neko():
    a = Art()
    OR, STR = "#f6b26b", "#d9843a"
    a.tube("M338 420 C392 424 420 386 410 336 C402 300 420 274 446 284", OR, 40, 20)
    body(a, OR, belly=CREAM, toes=True)
    ear = "M140 168 L150 72 C152 64 160 62 166 66 L236 104 Z"
    inner = "M158 140 L164 92 L214 112 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=OR)
    for d in (inner, mirror(inner)):
        a.blob(d, PINK_IN)
    a.path(HEAD, fill=OR)
    for d in ("M256 98 L256 128", "M230 102 L234 124", "M282 102 L278 124"):
        a.path(d, stroke=STR, sw=10)
    a.ellipse(256, 246, 58, 40, CREAM, sw=0, stroke="none")
    a.path("M244 226 L268 226 L256 240 Z", fill="#f28a9b", sw=6)
    a.path("M256 240 L256 248 M256 248 C250 260 236 260 234 250 M256 248 C262 260 276 260 278 250", sw=7)
    for d in ("M180 228 L118 220", "M180 244 L120 252"):
        a.path(d, sw=6)
        a.path(mirror(d), sw=6)
    a.face(cy=182, gap=58, blush_y=222, blush_dx=104)
    a.shine("M150 170 C152 152 160 138 172 128")
    return a


@word
def kuma():
    a = Art()
    BR, LT = "#b07a4f", "#f2d2a9"
    body(a, BR, belly=LT, toes=True)
    for x in (156, 356):
        a.circle(x, 116, 42, BR)
        a.dot(x, 118, 22, LT)
    a.path(HEAD, fill=BR)
    a.ellipse(256, 252, 64, 46, LT)
    a.ellipse(256, 232, 20, 14, EYE, sw=0, stroke="none")
    a.dot(250, 228, 4.5, WHITE)
    a.path("M256 246 L256 258 M256 258 C250 270 236 270 234 260 M256 258 C262 270 276 270 278 260", sw=7)
    a.face(cy=178, gap=58, blush_y=224, blush_dx=102)
    a.shine("M150 170 C152 152 160 138 172 128")
    return a


@word
def uma():
    a = Art()
    CH, MANE, MZ = "#d9935a", "#7a4a2b", "#f2c49a"
    HD = ("M256 72 C332 72 366 118 364 178 C362 220 354 248 352 270 C348 306 312 324 256 324 "
          "C200 324 164 306 160 270 C158 248 150 220 148 178 C146 118 180 72 256 72 Z")
    a.path("M338 372 C384 362 408 322 400 286 C432 304 446 356 428 398 C416 424 384 434 350 424 Z", fill=MANE)
    a.path(BODY, fill=CH)
    a.path(HOOF_L, fill="#6b5446", sw=9)
    a.path(HOOF_R, fill="#6b5446", sw=9)
    a.path(BODY)
    ear = "M178 116 C166 84 170 52 184 38 C204 52 216 80 216 100 Z"
    inner = "M184 100 C178 82 180 64 186 56 C196 66 202 82 202 96 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=CH)
    for d in (inner, mirror(inner)):
        a.blob(d, PINK_IN)
    a.path("M214 74 C262 42 336 58 366 112 C394 164 388 236 368 300 L334 300 C344 238 344 168 304 112 Z", fill=MANE)
    a.path(HD, fill=CH)
    a.blob("M244 130 C244 166 238 196 234 222 L278 222 C274 196 268 166 268 130 Z", WHITE)
    a.path("M206 92 C222 66 290 66 306 92 L298 128 L280 110 L266 140 L252 112 L236 136 L226 108 L212 122 Z", fill=MANE)
    a.ellipse(256, 268, 92, 54, MZ)
    a.ellipse(222, 264, 9, 13, EYE, sw=0, stroke="none")
    a.ellipse(290, 264, 9, 13, EYE, sw=0, stroke="none")
    a.path("M238 292 C250 302 262 302 274 292", sw=8)
    a.face(cy=178, gap=60, blush_y=216, blush_dx=92)
    a.shine("M168 200 C166 180 168 160 176 146")
    return a


@word
def shika():
    a = Art()
    BR, AN = "#c98a52", "#f0d9a8"
    for d in ("M208 116 C198 84 178 62 150 46", "M188 84 C200 66 204 50 200 34", "M170 66 C150 68 132 62 118 48"):
        a.tube(d, AN, 32, 12)
        a.tube(mirror(d), AN, 32, 12)
    a.path(BODY, fill=BR)
    a.ellipse(256, 372, 48, 42, CREAM, sw=0, stroke="none")
    for x, y in ((190, 316), (322, 316), (184, 352), (328, 352), (200, 386), (312, 386)):
        a.dot(x, y, 8, CREAM)
    a.path(HOOF_L, fill="#6b5446", sw=9)
    a.path(HOOF_R, fill="#6b5446", sw=9)
    a.path(BODY)
    ear = "M140 162 C110 144 64 146 54 168 C62 196 108 204 142 192 Z"
    inner = "M128 168 C108 162 84 164 76 172 C86 184 108 188 128 184 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=BR)
    for d in (inner, mirror(inner)):
        a.blob(d, PINK_IN)
    a.path(HEAD, fill=BR)
    for x, y in ((226, 116), (256, 108), (286, 116)):
        a.dot(x, y, 7, CREAM)
    a.ellipse(256, 254, 62, 44, CREAM)
    a.ellipse(256, 236, 18, 13, EYE, sw=0, stroke="none")
    a.dot(250, 232, 4, WHITE)
    a.path("M256 249 L256 260 M256 260 C250 272 236 272 234 262 M256 260 C262 272 276 272 278 262", sw=7)
    a.face(cy=180, gap=58, blush_y=224, blush_dx=102)
    return a


@word
def risu():
    a = Art()
    OR, TL, LT = "#d98a47", "#eba460", "#f7dcb4"
    a.path("M320 440 C410 452 478 404 474 320 C470 262 440 236 452 188 C462 150 494 128 474 90 "
           "C454 56 398 58 384 96 C418 98 432 128 410 160 C380 204 382 252 372 300 C362 360 342 400 320 440 Z", fill=TL)
    a.path("M424 116 C446 128 448 160 434 192 C418 232 432 270 440 316", stroke=LT, sw=12)
    body(a, OR, belly=LT, toes=True)
    ear = "M168 132 C158 98 168 72 190 58 C206 76 212 100 206 124 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=OR)
    a.blob("M178 116 C174 96 180 82 190 74 C198 86 200 102 196 116 Z", PINK_IN)
    a.blob(mirror("M178 116 C174 96 180 82 190 74 C198 86 200 102 196 116 Z"), PINK_IN)
    a.path(HEAD, fill=OR)
    a.ellipse(256, 254, 86, 50, LT)
    a.dot(256, 232, 10, EYE)
    a.path("M256 242 L256 250 M256 250 C250 262 236 262 234 252 M256 250 C262 262 276 262 278 252", sw=7)
    a.rect(249, 258, 14, 14, WHITE, rx=3, sw=5)
    a.face(cy=180, gap=58, blush_y=226, blush_dx=104)
    # acorn held at the chest
    a.path("M226 350 C226 330 286 330 286 350 C286 388 270 404 256 404 C242 404 226 388 226 350 Z", fill="#b0682f")
    a.path("M220 352 C220 324 292 324 292 352 Z", fill="#6b4a2e")
    a.path("M256 330 L262 316", sw=8)
    a.ellipse(222, 374, 18, 14, OR, sw=9)
    a.ellipse(290, 374, 18, 14, OR, sw=9)
    a.shine("M150 170 C152 152 160 138 172 128")
    return a


# ------------------------------------------------------------- vehicles ----
RUN = "M60 395 L360 395 C425 395 452 352 440 318 C430 290 394 292 392 318 C391 336 410 342 421 333"


@word
def sori():
    a = Art()
    a.tube(shift(RUN, 48, -52), RED_D, 40, 18)
    a.rect(160, 270, 28, 80, "#b36d32", rx=8)
    a.rect(345, 270, 28, 80, "#b36d32", rx=8)
    a.rect(110, 320, 32, 80, WOOD_D, rx=8)
    a.rect(295, 320, 32, 80, WOOD_D, rx=8)
    for dx, dy in ((52, -54), (26, -27), (0, 0)):
        a.path(shift("M100 324 L350 324 L350 342 L100 342 Z", dx, dy), fill=WOOD_D)
        a.path(shift("M118 306 L368 306 L350 324 L100 324 Z", dx, dy), fill=WOOD)
    a.shine("M132 315 L330 315", sw=6)
    a.tube(RUN, RED, 44, 22)
    rope = "M424 314 C468 322 494 292 480 256 C468 226 440 214 452 184 C460 166 478 160 492 164"
    a.tube(rope, YEL, 22, 8)
    a.circle(424, 314, 11, YEL, sw=9)
    return a


@word
def kuruma():
    a = Art()
    a.path("M64 330 C64 302 84 292 114 290 L156 288 C176 240 208 206 262 204 L318 204 C362 204 388 240 404 284 "
           "L432 290 C454 294 462 312 462 334 L462 352 C462 364 454 370 442 370 L84 370 C72 370 64 362 64 350 Z", fill=RED)
    a.path("M184 284 C196 254 218 232 252 230 L282 230 L282 284 Z", fill=SKY, sw=9)
    a.path("M302 230 L318 230 C346 230 364 254 376 284 L302 284 Z", fill=SKY, sw=9)
    a.path("M292 292 L292 352", sw=8)
    a.rect(312, 304, 26, 10, WHITE, rx=5, sw=6)
    a.ellipse(446, 318, 12, 14, YEL)
    a.rect(58, 312, 16, 26, "#f28a9b", rx=6, sw=8)
    a.shine("M226 214 C250 210 290 210 316 212")
    for x in (150, 376):
        a.circle(x, 372, 48, GREY)
        a.circle(x, 372, 18, HUB, sw=8)
    return a


@word
def fune():
    a = Art()
    a.rect(304, 110, 52, 86, RED, rx=10)
    a.rect(304, 128, 52, 18, WHITE, sw=0, stroke="none")
    a.rect(304, 110, 52, 86, "none", rx=10)
    a.path("M226 176 L226 92", sw=10)
    a.path("M226 94 L276 112 L226 130 Z", fill=YEL2, sw=9)
    a.rect(190, 170, 154, 64, WHITE, rx=16)
    a.rect(212, 186, 46, 30, SKY, rx=8, sw=8)
    a.rect(276, 186, 46, 30, SKY, rx=8, sw=8)
    a.rect(132, 222, 262, 82, WHITE, rx=18)
    for x in (178, 240, 302):
        a.circle(x, 262, 17, SKY, sw=9)
    a.path("M40 290 L472 290 C462 348 420 382 366 384 L160 384 C104 384 62 348 40 290 Z", fill=BLUE)
    a.path("M52 316 L462 316", stroke=WHITE, sw=10)
    a.path("M30 392 C56 370 86 370 112 390 C138 410 168 410 194 390 C220 370 250 370 276 390 "
           "C302 410 332 410 358 390 C384 370 414 370 440 390 C454 400 470 404 482 400 L482 424 "
           "C470 432 452 432 440 424 C414 406 384 406 358 424 C332 442 302 442 276 424 C250 406 220 406 194 424 "
           "C168 442 138 442 112 424 C86 406 56 406 30 424 Z", fill="#9fd3f2")
    a.shine("M110 302 L250 302")
    return a


@word
def densha():
    a = Art()
    for x in (140, 196, 340, 396):
        a.circle(x, 380, 22, GREY, sw=9)
    a.path("M262 126 L298 84 L334 126 M276 84 L320 84", sw=9)
    a.rect(266, 116, 62, 12, GREY, rx=4, sw=7)
    a.path("M70 176 C70 144 92 126 124 126 L440 126 C456 126 464 136 464 152 L464 356 C464 368 456 376 444 376 "
           "L96 376 C80 376 70 366 70 350 Z", fill="#f4f1ea")
    a.rect(76, 286, 382, 30, "#8cc63f", sw=0, stroke="none")
    a.path("M70 176 C70 144 92 126 124 126 L440 126 C456 126 464 136 464 152 L464 356 C464 368 456 376 444 376 "
           "L96 376 C80 376 70 366 70 350 Z")
    a.path("M86 182 C86 162 98 150 116 150 L142 150 L142 252 L86 252 Z", fill=SKY, sw=9)
    a.rect(162, 150, 54, 206, "#e1ddd3", rx=6, sw=9)
    a.rect(172, 166, 34, 60, SKY, rx=5, sw=7)
    a.rect(236, 156, 80, 76, SKY, rx=10, sw=9)
    a.rect(334, 156, 80, 76, SKY, rx=10, sw=9)
    a.ellipse(100, 336, 12, 10, YEL)
    a.shine("M246 168 L276 168")
    return a


@word
def shinkansen():
    a = Art()
    for x in (150, 200, 390, 440):
        a.circle(x, 352, 16, GREY, sw=8)
    BODYP = ("M36 326 C60 278 124 222 206 206 C246 198 286 196 326 196 L462 196 C474 196 480 204 480 216 "
             "L480 334 C480 346 472 352 460 352 L62 352 C40 352 28 340 36 326 Z")
    a.path(BODYP, fill=WHITE)
    a.blob("M70 300 C130 286 200 278 270 278 L476 278 L476 294 L270 294 C206 294 140 300 64 316 Z", "#2a62b8")
    a.blob("M60 324 C140 312 200 308 270 308 L476 308 L476 316 L270 316 C200 316 140 320 54 334 Z", "#2a62b8")
    a.path(BODYP)
    a.path("M168 230 C200 216 240 210 272 212 L268 242 C232 242 198 248 166 258 Z", fill=NAVY, sw=9)
    for x in (300, 340, 380, 420):
        a.rect(x, 222, 26, 28, SKY, rx=8, sw=7)
    a.ellipse(84, 312, 12, 7, YEL, sw=6)
    a.shine("M186 236 C206 228 224 224 240 222", sw=6)
    a.shine("M120 236 C150 220 190 210 230 206")
    return a


@word
def jitensha():
    a = Art()
    FR = GREEN
    for cx in (140, 386):
        a.circle(cx, 340, 82, "none", sw=34)
        a.circle(cx, 340, 82, "none", stroke=GREY, sw=16)
        for d in ((0, -1), (1, 0), (0.7, 0.7), (-0.7, 0.7), (-0.7, -0.7), (0.7, -0.7), (-1, 0), (0, 1)):
            a.line(cx, 340, cx + 66 * d[0], 340 + 66 * d[1], sw=5, stroke="#b8aca4")
        a.circle(cx, 340, 12, HUB, sw=7)
    a.tube("M140 340 L250 340 L218 222 L140 340 M218 222 L340 230 L250 340 M340 230 L386 340", FR, 32, 14)
    a.tube("M218 222 L210 196", GREY, 26, 10)
    a.path("M176 196 C176 180 236 180 246 192 C246 206 190 210 176 196 Z", fill="#6b4a2e")
    a.tube("M340 230 L330 178", GREY, 26, 10)
    a.tube("M302 172 L346 172", GREY, 26, 10)
    a.rect(350, 168, 96, 62, YEL2, rx=12)
    a.path("M382 172 L382 226 M414 172 L414 226 M352 198 L444 198", stroke="#d9a62a", sw=6)
    a.rect(350, 168, 96, 62, "none", rx=12)
    a.circle(250, 340, 18, HUB, sw=8)
    a.rect(238, 368, 40, 14, GREY, rx=5, sw=7)
    a.path("M250 340 L258 372", sw=8)
    return a


# --------------------------------------------------------------- clothes ---
@word
def kutsu():
    a = Art()
    UP = ("M70 404 C48 352 86 314 140 314 C178 314 202 298 216 280 C226 268 232 256 236 246 "
          "L328 238 C352 236 368 258 368 296 L370 404 Z")
    LOOP = "M346 252 C350 236 366 234 372 246 C376 256 370 266 362 270"

    def shoe(upper):
        s = Art()
        s.path("M232 258 C230 236 242 222 258 222 C274 222 282 236 282 252 Z", fill="#9fd3f2")
        s.tube(LOOP, YEL2, 22, 8)
        s.path(UP, fill=upper)
        s.path("M70 404 C48 352 86 314 140 314 C126 346 128 380 144 404 Z", fill=WHITE)
        s.path(UP)
        s.path("M154 308 L194 298 L224 384 L188 394 Z", fill=YEL2, sw=9)
        s.path("M206 290 L234 262 L276 352 L244 372 Z", fill=YEL2, sw=9)
        s.rect(46, 398, 330, 44, WHITE, rx=22)
        s.path("M72 420 L350 420", stroke=RED, sw=7)
        return s

    place(a, shoe(BLUE_D), 118, -46)
    place(a, shoe(BLUE))
    a.shine("M300 290 C302 280 306 272 314 266")
    return a


@word
def fuku():
    a = Art()
    a.path("M182 96 C202 122 310 122 330 96 L420 136 C432 142 436 152 432 164 L410 228 C406 240 394 244 384 238 "
           "L360 224 L360 420 C360 436 350 444 334 444 L178 444 C162 444 152 436 152 420 L152 224 L128 238 "
           "C118 244 106 240 102 228 L80 164 C76 152 80 142 92 136 Z", fill="#f39a4a")
    a.tube("M184 98 C204 136 308 136 328 98", "#fbc98a", 30, 12)
    a.path("M106 204 L150 186", sw=8)
    a.path(mirror("M106 204 L150 186"), sw=8)
    # star
    import math
    pts = []
    for i in range(10):
        r = 52 if i % 2 == 0 else 24
        t = -math.pi / 2 + i * math.pi / 5
        pts.append(f"{256 + r * math.cos(t):.1f} {300 + r * math.sin(t):.1f}")
    a.path("M" + " L".join(pts) + " Z", fill=YEL, sw=9)
    a.shine("M176 250 C174 290 174 330 176 360")
    return a


@word
def boushi():
    a = Art()
    a.ellipse(256, 312, 196, 56, "#f9d867")
    a.path("M138 304 C138 182 188 118 256 118 C324 118 374 182 374 304 C330 324 182 324 138 304 Z", fill=YEL2)
    a.path("M140 270 C188 290 324 290 372 270 L374 304 C330 324 182 324 138 304 Z", fill=RED)
    a.circle(256, 120, 13, YEL2, sw=9)
    a.shine("M178 230 C178 196 192 168 214 150")
    return a


def sakura(a, cx, cy, r=9, col="#ffd1dc"):
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
    a.path(GARMENT, fill=NAVY)
    for x, y in ((92, 160), (420, 160), (120, 226), (392, 226), (180, 150), (334, 150), (190, 350), (322, 350),
                 (256, 400), (190, 440), (322, 440), (300, 200)):
        a.circle(x, y, 10, "none", stroke=WHITE, sw=6)
    a.path("M150 268 L150 252 M362 252 L362 268", sw=8)
    a.tube("M219 104 L268 214", "#9fd3f2", 30, 14)
    a.tube("M293 104 L226 254", "#9fd3f2", 30, 14)
    a.path("M226 300 L212 476", sw=8)
    a.rect(150, 252, 212, 52, "#f7a8b3")
    for d in ("M300 278 C336 244 384 252 382 280 C380 306 336 310 300 278 Z",
              "M300 278 C264 244 216 252 218 280 C220 306 264 310 300 278 Z",
              "M300 278 C318 306 330 344 322 380 C304 366 296 316 300 278 Z",
              "M300 278 C282 306 266 340 272 372 C292 362 300 316 300 278 Z"):
        a.path(d, fill="#f7a8b3", sw=9)
    a.circle(300, 278, 12, "#f28a9b", sw=8)
    a.path(GARMENT)
    a.shine("M70 150 L70 230")
    return a


@word
def kimono():
    a = Art()
    K = "#e5534b"
    sleeve = "M150 122 L60 122 C50 122 46 130 46 140 L46 360 C46 392 70 410 100 410 L150 410 Z"
    a.path(sleeve, fill=K)
    a.path(mirror(sleeve), fill=K)
    a.path("M196 92 L316 92 L362 112 L362 462 C362 472 354 478 344 478 L168 478 C158 478 150 472 150 462 "
           "L150 112 Z", fill=K)
    for x, y, r in ((86, 170, 10), (118, 250, 11), (80, 330, 10), (122, 380, 8), (426, 170, 10), (394, 250, 11),
                    (432, 330, 10), (390, 380, 8), (186, 360, 11), (322, 380, 12), (250, 430, 11), (196, 444, 8),
                    (322, 446, 9), (184, 150, 8), (330, 150, 8)):
        sakura(a, x, y, r)
    for x, y in ((104, 292), (408, 292), (282, 352), (214, 404)):
        a.circle(x, y, 9, YEL2, sw=0, stroke="none")
    a.tube("M219 104 L268 214", WHITE, 34, 18)
    a.tube("M293 104 L226 254", WHITE, 34, 18)
    a.path("M231 104 L274 196", stroke=K, sw=10)
    a.path("M281 104 L230 232", stroke=K, sw=10)
    a.path("M226 300 L212 476", sw=8)
    a.rect(150, 244, 212, 66, YEL2)
    a.path("M150 244 L362 244 L362 256 L150 256 Z", fill="#f7a8b3", sw=8)
    for x in (184, 232, 280, 328):
        a.path(f"M{x} 266 L{x + 14} 280 L{x} 294 L{x - 14} 280 Z", fill="#f6a04d", sw=0, stroke="none")
    a.path("M150 282 L362 282", stroke="#6cb6e8", sw=10)
    a.rect(150, 244, 212, 66, "none")
    a.path("M196 92 L316 92 L362 112 L362 462 C362 472 354 478 344 478 L168 478 C158 478 150 472 150 462 L150 112 Z")
    a.shine("M70 150 L70 230")
    return a


@word
def kutsushita():
    a = Art()
    P, ACC = "#f08aa0", YEL2

    def sock(col):
        s = Art()
        LEG = ("M200 104 L300 104 L300 300 C300 362 262 404 202 404 L118 404 C80 404 58 384 58 354 "
               "C58 322 82 300 118 300 L200 300 Z")
        s.path(LEG, fill=col)
        s.blob("M118 300 C82 300 58 322 58 354 C58 384 80 404 118 404 C132 380 132 324 118 300 Z", ACC)
        s.blob("M300 320 C300 370 266 404 214 404 C222 380 246 364 272 352 C286 344 296 334 300 320 Z", ACC)
        s.rect(200, 170, 100, 22, WHITE, sw=0, stroke="none")
        s.rect(200, 222, 100, 22, WHITE, sw=0, stroke="none")
        s.path(LEG)
        s.rect(190, 72, 120, 48, WHITE, rx=14)
        for x in (220, 250, 280):
            s.path(f"M{x} 84 L{x} 108", stroke="#e1ddd3", sw=6)
        return s

    place(a, sock("#e2738b"), 130, -40)
    place(a, sock(P))
    a.shine("M214 260 L214 290")
    return a




# ------------------------------------------------------- more animals ------
@word
def saru():
    a = Art()
    BR, LT = "#b9794a", "#f6dcb8"
    a.tube("M340 410 C398 420 430 380 416 330 C406 296 430 276 452 292", BR, 40, 20)
    body(a, BR, belly=LT, toes=True)
    for x in (122, 390):
        a.circle(x, 214, 38, BR)
        a.circle(x, 214, 20, LT, sw=0, stroke="none")
    a.path(HEAD, fill=BR)
    a.path("M256 150 C292 118 346 150 336 200 C330 240 360 262 336 286 C312 314 200 314 176 286 "
           "C152 262 182 240 176 200 C166 150 220 118 256 150 Z", fill=LT)
    a.ellipse(256, 262, 52, 34, "#f0c291", sw=0, stroke="none")
    a.dot(240, 258, 5, EYE)
    a.dot(272, 258, 5, EYE)
    a.path("M232 284 C246 296 266 296 280 284", sw=8)
    a.face(cy=204, gap=40, blush_y=250, blush_dx=94, r=14)
    a.shine("M150 150 C152 134 160 122 172 114")
    return a


@word
def zou():
    a = Art()
    G, GL = "#a9b7c6", "#d3dde8"
    a.tube("M340 410 C376 410 392 394 394 372", G, 30, 14)
    body(a, G, belly=GL, toes=True)
    for s in (1, -1):
        d = "M150 130 C70 100 36 150 44 214 C52 270 100 292 150 262 Z"
        i = "M138 160 C96 146 74 174 80 212 C86 246 114 258 140 242 Z"
        if s == -1:
            d, i = mirror(d), mirror(i)
        a.path(d, fill=G)
        a.blob(i, PINK_IN)
    a.path(HEAD, fill=G)
    a.tube("M256 196 C256 250 254 290 258 322 C262 348 292 352 298 330", G, 64, 42)
    for y in (252, 280, 308):
        a.path(f"M242 {y} L270 {y}", stroke=O, sw=6)
    a.face(cy=170, gap=60, blush_y=226, blush_dx=96)
    a.shine("M168 130 C184 112 204 104 224 100")
    return a


@word
def tora():
    a = Art()
    OR, ST = "#f4a340", "#4a3428"
    a.tube("M338 410 C396 420 432 380 420 326 C414 300 428 282 450 288", OR, 40, 20)
    a.path("M404 372 L424 360 M420 338 L440 330", stroke=ST, sw=9)
    body(a, OR, belly=CREAM, toes=True)
    for y in (300, 338, 376):
        a.path(f"M168 {y} L196 {y + 6}", stroke=ST, sw=10)
        a.path(mirror(f"M168 {y} L196 {y + 6}"), stroke=ST, sw=10)
    for x in (146, 366):
        a.circle(x, 124, 38, OR)
        a.dot(x, 126, 18, CREAM)
    a.path(HEAD, fill=OR)
    # forehead stripes
    a.path("M256 100 L256 136 M226 106 L232 134 M286 106 L280 134", stroke=ST, sw=10)
    # cheek stripes
    for d in ("M126 206 L162 214", "M130 238 L164 238"):
        a.path(d, stroke=ST, sw=9)
        a.path(mirror(d), stroke=ST, sw=9)
    a.ellipse(256, 254, 76, 52, CREAM, sw=0, stroke="none")
    a.path("M236 226 C236 214 276 214 276 226 C276 240 262 246 256 246 C250 246 236 240 236 226 Z", fill="#f28a9b", sw=6)
    a.path("M256 246 L256 258 M256 258 C250 272 232 272 230 262 M256 258 C262 272 280 272 282 262", sw=7)
    a.face(cy=182, gap=56, blush_y=226, blush_dx=106)
    a.shine("M150 176 C152 158 160 144 172 134")
    return a


@word
def kaba():
    a = Art()
    G, GL = "#a99bc4", "#d9cfe8"
    a.tube("M340 416 C366 418 380 406 382 390", G, 28, 12)
    body(a, G, belly=GL, toes=True)
    for x in (158, 354):
        a.ellipse(x, 112, 26, 34, G)
        a.ellipse(x, 116, 11, 18, PINK_IN, sw=0, stroke="none")
    a.path(HEAD, fill=G)
    a.ellipse(256, 262, 132, 80, "#c3b6dc")
    for x in (222, 290):
        a.ellipse(x, 240, 9, 12, "#6c5a8c", sw=0, stroke="none")
    a.path("M214 296 C236 316 276 316 298 296", sw=8)
    a.face(cy=170, gap=62, blush_y=212, blush_dx=112)
    a.shine("M178 128 C194 112 214 104 234 100")
    return a


@word
def kirin():
    a = Art()
    Y, SP = "#f8cf62", "#c98a3e"
    a.tube("M340 410 C366 412 378 398 378 382", Y, 28, 12)
    # neck behind head, then body
    a.path("M214 190 L298 190 L304 300 L208 300 Z", fill=Y, sw=0, stroke="none")
    body(a, Y, belly=CREAM, toes=True)
    for x, y, r in ((190, 320, 14), (320, 340, 16), (214, 392, 12), (306, 410, 12), (256, 300, 12)):
        a.ellipse(x, y, r, r * 0.85, SP, sw=0, stroke="none")
    a.path("M214 190 L208 282", sw=11)
    a.path("M298 190 L304 282", sw=11)
    for x, y, r in ((236, 226, 11), (272, 252, 12), (240, 278, 10)):
        a.ellipse(x, y, r, r * 0.85, SP, sw=0, stroke="none")
    # horns and ears
    for s in (1, -1):
        d = "M232 80 L228 40"
        a.path(d if s == 1 else mirror(d), sw=10)
        a.circle(228 if s == 1 else 284, 36, 12, SP, sw=8)
        e = "M184 118 C150 100 126 112 124 134 C140 150 168 148 186 140 Z"
        a.path(e if s == 1 else mirror(e), fill=Y)
        a.blob("M174 124 C158 116 144 120 140 130 C150 138 164 138 176 134 Z" if s == 1 else mirror("M174 124 C158 116 144 120 140 130 C150 138 164 138 176 134 Z"), PINK_IN)
    a.ellipse(256, 130, 80, 70, Y)
    for x, y, r in ((226, 84, 9), (288, 90, 8)):
        a.ellipse(x, y, r, r, SP, sw=0, stroke="none")
    a.ellipse(256, 168, 52, 36, CREAM)
    a.dot(240, 164, 5, EYE)
    a.dot(272, 164, 5, EYE)
    a.path("M240 182 C250 192 262 192 272 182", sw=7)
    a.face(cy=124, gap=42, blush_y=158, blush_dx=70, r=13)
    a.shine("M196 96 C206 86 220 80 234 78")
    return a


@word
def rakuda():
    a = Art()
    T, TL = "#e0b070", "#f3d9a8"
    for x in (176, 232, 340, 396):
        a.rect(x, 340, 36, 112, T, rx=14)
    a.tube("M418 330 C440 340 448 366 440 394", T, 26, 10)
    a.tube("M214 300 C180 270 164 230 164 190", T, 82, 60)
    a.path("M170 330 C160 296 182 284 200 280 C196 214 252 208 262 274 C276 280 296 280 304 276 "
           "C306 210 366 208 372 280 C410 286 424 316 420 350 C418 376 396 384 372 384 L190 384 "
           "C168 384 156 360 170 330 Z", fill=T)
    a.blob("M176 300 C190 288 228 290 236 312 C226 336 190 344 176 330 Z", T)
    a.ellipse(260, 350, 54, 24, TL, sw=0, stroke="none")
    a.circle(168, 108, 16, T)
    a.ellipse(128, 164, 70, 58, T)
    a.ellipse(104, 190, 46, 34, TL)
    a.dot(94, 186, 5, EYE)
    a.dot(118, 188, 5, EYE)
    a.path("M86 208 C100 218 120 218 132 208", sw=7)
    a.ellipse(120, 140, 11, 14, EYE, sw=0, stroke="none")
    a.dot(124, 134, 4, WHITE)
    a.ellipse(160, 176, 14, 9, "#ff9aa8", sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.shine("M84 136 C96 124 112 120 126 122")
    return a


@word
def buta():
    a = Art()
    P, PD = "#f9b4be", "#f28a9b"
    a.path("M340 410 C376 408 386 380 366 370 C348 362 340 382 360 386", sw=10)
    body(a, P, belly="#fdd3d8", toes=False)
    for x in (190, 214, 298, 322):
        a.line(x, 438, x, 452, sw=7)
    ear = "M148 150 C110 112 92 94 96 80 C128 66 170 92 192 118 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=P)
    a.path(HEAD, fill=P)
    a.ellipse(256, 236, 62, 38, PD)
    a.ellipse(236, 236, 8, 13, "#b9566a", sw=0, stroke="none")
    a.ellipse(276, 236, 8, 13, "#b9566a", sw=0, stroke="none")
    a.path("M236 288 C248 298 264 298 276 288", sw=8)
    a.face(cy=176, gap=62, blush_y=222, blush_dx=106)
    a.shine("M168 130 C184 114 204 106 224 102")
    return a


@word
def hitsuji():
    a = Art()
    FACE, WOOL = "#8a7468", "#fffaf0"
    for x in (190, 298):
        a.rect(x - 8, 380, 40, 72, FACE, rx=12)
    # wool body: overlapping circles, outlined then filled
    puffs = [(170, 330, 54), (342, 330, 54), (200, 380, 50), (312, 380, 50), (256, 390, 54),
             (150, 270, 46), (362, 270, 46), (256, 300, 70)]
    for x, y, r in puffs:
        a.circle(x, y, r, WOOL)
    for x, y, r in puffs:
        a.circle(x, y, r - 5, WOOL, sw=0, stroke="none")
    # ears
    for s in (1, -1):
        e = "M150 190 C108 168 70 188 74 214 C96 232 134 228 154 218 Z"
        a.path(e if s == 1 else mirror(e), fill=FACE)
        i = "M138 196 C112 186 94 196 94 208 C108 216 126 214 140 210 Z"
        a.blob(i if s == 1 else mirror(i), PINK_IN)
    # head wool top
    for x, y, r in ((200, 98, 34), (256, 84, 38), (312, 98, 34)):
        a.circle(x, y, r, WOOL)
    for x, y, r in ((200, 98, 29), (256, 84, 33), (312, 98, 29)):
        a.circle(x, y, r, WOOL, sw=0, stroke="none")
    a.path("M256 120 C320 120 346 160 340 214 C334 268 300 292 256 292 C212 292 178 268 172 214 C166 160 192 120 256 120 Z", fill=FACE)
    a.ellipse(256, 244, 40, 28, "#b5a296", sw=0, stroke="none")
    a.path("M246 236 L266 236 L256 246 Z", fill="#f28a9b", sw=5)
    a.path("M240 264 C250 274 262 274 272 264", sw=7)
    a.face(cy=196, gap=42, blush_y=238, blush_dx=76, r=13)
    a.shine("M190 160 C198 148 210 140 224 136")
    return a


@word
def tanuki():
    a = Art()
    BR, DK, LT = "#b98a5e", "#5a4036", "#f1dcc0"
    a.path("M330 420 C380 438 440 410 440 350 C440 316 412 304 392 314 C372 324 360 372 338 396 Z", fill=BR)
    a.path("M404 330 C420 336 424 360 416 384", stroke=DK, sw=14)
    body(a, BR, belly=LT, toes=False)
    for x in (190, 214, 298, 322):
        a.line(x, 438, x, 452, sw=7)
    for x in (156, 356):
        a.circle(x, 118, 38, BR)
        a.dot(x, 120, 18, DK)
    a.path(HEAD, fill=BR)
    a.path("M256 150 C300 150 330 174 330 214 C330 258 300 292 256 292 C212 292 182 258 182 214 C182 174 212 150 256 150 Z", fill=LT, sw=0, stroke="none")
    for s in (1, -1):
        m = "M214 186 C186 184 150 196 142 226 C140 250 170 258 196 246 C214 236 226 214 214 186 Z"
        a.blob(m if s == 1 else mirror(m), DK)
    a.ellipse(256, 262, 40, 28, LT, sw=0, stroke="none")
    a.ellipse(256, 236, 16, 11, EYE, sw=0, stroke="none")
    a.dot(251, 233, 3.5, WHITE)
    a.path("M256 246 L256 256 M256 256 C250 268 238 268 236 260 M256 256 C262 268 274 268 276 260", sw=7)
    for s in (1, -1):
        x = 256 + s * 52
        a.ellipse(x, 220, 14, 17, "#f8f4ee", sw=0, stroke="none")
        a.ellipse(x, 224, 10, 13, EYE, sw=0, stroke="none")
        a.dot(x + 3, 218, 3.5, WHITE)
        a.ellipse(256 + s * 98, 262, 14, 9, "#ff9aa8", sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.shine("M168 150 C176 134 190 122 206 116")
    return a


@word
def kitsune():
    a = Art()
    OR, DK = "#f08a3c", "#6b4a3a"
    tail = ("M330 424 C390 450 462 410 462 340 C462 290 436 262 416 258 C398 284 380 330 356 370 Z")
    a.path(tail, fill=OR)
    a.blob("M416 258 C436 262 462 290 462 340 C462 358 458 374 450 388 C446 350 432 316 408 290 C410 278 412 268 416 258 Z", WHITE)
    a.path(tail)
    body(a, OR, belly=CREAM, toes=False)
    for x in (190, 214, 298, 322):
        a.line(x, 438, x, 452, sw=7)
    ear = "M136 190 L132 52 C132 44 140 42 146 46 L236 100 Z"
    inner = "M156 150 L152 84 L204 114 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=OR)
    for d in (inner, mirror(inner)):
        a.blob(d, DK)
    a.path(HEAD, fill=OR)
    # white cheeks and muzzle
    a.path("M120 222 C150 214 186 236 226 262 C240 272 246 290 256 308 C214 322 150 296 124 252 Z", fill=WHITE, sw=0, stroke="none")
    a.path(mirror("M120 222 C150 214 186 236 226 262 C240 272 246 290 256 308 C214 322 150 296 124 252 Z"), fill=WHITE, sw=0, stroke="none")
    a.ellipse(256, 282, 44, 30, WHITE, sw=0, stroke="none")
    a.path(HEAD)
    a.ellipse(256, 262, 34, 22, WHITE, sw=0, stroke="none")
    a.path("M240 234 C240 224 272 224 272 234 C272 246 262 252 256 252 C250 252 240 246 240 234 Z", fill=EYE, sw=0, stroke="none")
    a.path("M256 252 L256 264 M256 264 C250 276 236 276 234 266 M256 264 C262 276 276 276 278 266", sw=7)
    a.face(cy=186, gap=58, blush_y=226, blush_dx=100)
    a.shine("M170 130 C180 118 194 110 210 106")
    return a


@word
def usagi():
    a = Art()
    W, SH = "#fffaf4", "#efe4dc"
    a.circle(372, 396, 30, W)
    body(a, W, belly=SH, toes=True)
    ear = "M196 130 C170 100 160 30 190 6 C226 8 240 70 236 118 Z"
    inner = "M200 104 C186 80 182 44 194 26 C214 32 222 64 220 100 Z"
    for d in (ear, mirror(ear)):
        a.path(d, fill=W)
    for d in (inner, mirror(inner)):
        a.blob(d, PINK_IN)
    a.path(HEAD, fill=W)
    a.ellipse(256, 262, 44, 30, SH, sw=0, stroke="none")
    a.path("M244 240 L268 240 L256 252 Z", fill="#f28a9b", sw=6)
    a.path("M256 252 L256 262 M256 262 C250 274 238 274 236 266 M256 262 C262 274 274 274 276 266", sw=7)
    a.rect(248, 266, 7, 12, WHITE, rx=2, sw=5)
    a.rect(257, 266, 7, 12, WHITE, rx=2, sw=5)
    a.face(cy=190, gap=58, blush_y=232, blush_dx=102)
    a.shine("M160 150 C164 132 172 118 184 108")
    return a


@word
def ikada():
    a = Art()
    LOG, END, RING = "#e4a560", "#f7d9a4", "#c97f3e"
    # logs run left-right; back rows are higher and a little to the right
    for i in range(4, -1, -1):
        dx, dy = i * 30, 50 - i * 40
        a.rect(60 + dx, 290 + dy, 300, 64, LOG, rx=32)
        a.ellipse(92 + dx, 322 + dy, 24, 30, END)
        a.ellipse(92 + dx, 322 + dy, 10, 14, "none", sw=6, stroke=RING)
        for rx_ in (160, 300):
            a.rect(rx_ + dx, 284 + dy, 20, 76, YEL, rx=8, sw=8)
    # ropes across the front log
    a.path("M30 396 C56 376 86 376 112 396 C138 416 168 416 194 396 C220 376 250 376 276 396 "
           "C302 416 332 416 358 396 C384 376 414 376 440 396 C454 406 470 410 482 406 L482 428 "
           "C470 436 452 436 440 428 C414 410 384 410 358 428 C332 446 302 446 276 428 C250 410 220 410 194 428 "
           "C168 446 138 446 112 428 C86 410 56 410 30 428 Z", fill="#9fd3f2")
    return a


@word
def shoubousha():
    a = Art()
    # ladder on the roof of the box
    a.path("M70 214 L360 150", sw=24, stroke=O)
    a.path("M70 214 L360 150", sw=8, stroke="#d8d2cc")
    a.path("M70 244 L360 180", sw=24, stroke=O)
    a.path("M70 244 L360 180", sw=8, stroke="#d8d2cc")
    for t in (0.12, 0.3, 0.48, 0.66, 0.84):
        x = 70 + 290 * t
        a.path(f"M{x:.0f} {214 - 64 * t:.0f} L{x:.0f} {244 - 64 * t:.0f}", sw=8)
    # box body and cab
    a.path("M40 270 C40 256 50 250 64 250 L292 250 L292 372 L40 372 Z", fill=RED)
    a.path("M292 250 L370 250 C392 250 408 262 420 288 L452 300 C462 304 466 314 466 326 L466 358 "
           "C466 366 460 372 452 372 L292 372 Z", fill=RED)
    a.path("M312 270 L366 270 C380 270 390 280 398 298 L312 298 Z", fill=SKY, sw=9)
    a.rect(40, 316, 252, 20, WHITE, sw=0, stroke="none")
    a.path("M40 316 L292 316 M40 336 L292 336", sw=7)
    a.rect(330, 316, 26, 10, WHITE, rx=5, sw=6)
    a.ellipse(458, 328, 10, 14, YEL)
    a.rect(300, 232, 52, 22, YEL2, rx=8, sw=9)
    a.rect(318, 216, 16, 18, RED, rx=6, sw=8)
    a.shine("M62 270 L180 270")
    for x in (112, 372):
        a.circle(x, 376, 40, GREY)
        a.circle(x, 376, 15, HUB, sw=8)
    return a


@word
def kyuukyuusha():
    a = Art()
    W2 = "#f7f4ee"
    a.path("M50 190 C50 170 62 160 80 160 L318 160 L318 372 L50 372 Z", fill=W2)
    a.path("M318 160 L378 160 C398 160 412 172 424 200 L450 266 C460 274 466 284 466 298 L466 352 "
           "C466 364 458 372 446 372 L318 372 Z", fill=W2)
    a.rect(50, 296, 416, 22, RED, sw=0, stroke="none")
    a.path("M50 296 L466 296 M50 318 L466 318", sw=7)
    a.path("M338 180 L378 180 C390 180 398 188 406 208 L424 258 L338 258 Z", fill=SKY, sw=9)
    # red cross on the box
    a.rect(156, 190, 28, 84, RED, rx=6, sw=8)
    a.rect(128, 218, 84, 28, RED, rx=6, sw=8)
    a.ellipse(454, 300, 10, 14, YEL)
    a.rect(334, 276, 26, 10, WHITE, rx=5, sw=6)
    # siren on the roof
    a.rect(318, 132, 54, 30, RED, rx=10)
    a.rect(330, 116, 30, 20, "#ff7a72", rx=8, sw=8)
    a.path("M300 118 L286 108 M390 118 L404 108", sw=8)
    a.shine("M70 178 L230 178")
    for x in (126, 380):
        a.circle(x, 376, 40, GREY)
        a.circle(x, 376, 15, HUB, sw=8)
    return a


if __name__ == "__main__":
    names = sys.argv[1:] or list(W)
    for n in names:
        open(os.path.join(OUT, f"{n}.svg"), "w").write(W[n]().svg())
