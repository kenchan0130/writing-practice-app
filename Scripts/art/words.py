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
        sakura_dot(a, x, y, r)
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


@word
def hato():
    a = Art()
    GR, GRD, LG = "#b9c0c9", "#8b95a2", "#dde2e8"
    bird_base(a, GR, LG, GRD, "#7d8794")
    # iridescent neck collar (green and purple), under the head
    a.ellipse(256, 236, 84, 50, "#4fb59b", sw=0, stroke="none")
    a.ellipse(256, 246, 66, 32, "#a56fc4", sw=0, stroke="none")
    a.path("M256 82 C310 82 338 120 338 160 C338 204 300 238 256 238 C212 238 174 204 174 160 C174 120 202 82 256 82 Z", fill=GR)
    bird_face(a, cy=150, gap=44, blush_dx=72)
    a.path("M234 170 L278 170 C278 188 268 200 256 200 C244 200 234 188 234 170 Z", fill="#f4b086", sw=9)
    a.ellipse(256, 168, 14, 8, "#f6efe8", sw=0, stroke="none")
    a.shine("M196 120 C204 104 216 94 232 88")
    return a


@word
def suzume():
    a = Art()
    BR, BRD, CAP = "#c98f55", "#8f5a30", "#b5683a"
    bird_base(a, BR, "#f6e8d2", BRD, "#8f5a30")
    a.path("M130 340 L172 330 M126 360 L170 352", stroke="#f6e8d2", sw=7)
    a.path("M256 82 C310 82 338 120 338 160 C338 204 300 238 256 238 C212 238 174 204 174 160 C174 120 202 82 256 82 Z", fill="#f6e8d2")
    # chestnut cap and nape
    a.path("M256 82 C306 82 336 116 338 150 C316 128 290 122 256 122 C222 122 196 128 174 150 C176 116 206 82 256 82 Z", fill=CAP, sw=0, stroke="none")
    a.path("M256 82 C310 82 338 120 338 160 C338 204 300 238 256 238 C212 238 174 204 174 160 C174 120 202 82 256 82 Z")
    # black bib and cheek spots
    a.path("M232 198 C232 222 280 222 280 198 C268 206 244 206 232 198 Z", fill=EYE, sw=0, stroke="none")
    for s in (-1, 1):
        a.dot(256 + s * 74, 186, 11)
    bird_face(a, cy=150, gap=44, blush=False)
    a.path("M240 168 L272 168 C272 182 266 190 256 190 C246 190 240 182 240 168 Z", fill="#f2b788", sw=8)
    a.shine("M196 118 C204 102 216 92 232 86")
    return a


@word
def karasu():
    a = Art()
    BK, BKD, BKL = "#46424f", "#34303c", "#5d5868"
    bird_base(a, BK, BKL, BKD, "#34303c")
    a.path("M256 80 C312 80 344 120 344 164 C344 208 304 240 256 240 C208 240 168 208 168 164 C168 120 200 80 256 80 Z", fill=BK)
    a.ellipse(206, 126, 8, 5, BKL, sw=0, stroke="none")
    for s in (-1, 1):
        x = 256 + s * 46
        a.ellipse(x, 154, 20, 24, "#ffffff", sw=0, stroke="none")
        a.ellipse(x + s * 1, 156, 13, 17, EYE, sw=0, stroke="none")
        a.dot(x + 5, 148, 5.5, "#ffffff")
        a.ellipse(256 + s * 86, 190, 15, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.8"})
    a.path("M222 176 C222 164 290 164 290 176 C290 206 270 218 256 218 C242 218 222 206 222 176 Z", fill="#ffb347", sw=9)
    a.path("M234 190 C246 200 266 200 278 190", sw=7)
    a.shine("M196 112 C206 98 218 90 234 84")
    return a


@word
def hikouki():
    a = Art()
    WG, WG2 = "#8fb4dc", "#b3cdea"
    # far wing and tail plane (behind)
    a.path("M300 226 L262 150 L312 150 L372 224 Z", fill=WG2)
    # tail fin
    a.path("M70 236 L44 124 L102 124 L178 216 Z", fill=BLUE)
    # body
    a.path("M64 252 C64 224 88 212 122 212 L396 212 C444 212 478 236 478 260 C478 284 444 300 396 300 L116 300 C84 300 64 282 64 252 Z", fill=WHITE)
    a.path("M80 280 C90 292 104 294 120 294 L396 294 C426 294 452 284 466 270 L80 270 Z", fill=BLUE, sw=0, stroke="none")
    a.path("M64 252 C64 224 88 212 122 212 L396 212 C444 212 478 236 478 260 C478 284 444 300 396 300 L116 300 C84 300 64 282 64 252 Z")
    # cockpit and windows
    a.path("M404 232 C426 232 442 242 452 256 L404 256 Z", fill=SKY, sw=9)
    for x in range(140, 360, 44):
        a.circle(x, 246, 13, SKY, sw=8)
    # near wing and engine
    a.path("M286 284 L190 410 L248 410 L372 288 Z", fill=WG)
    a.rect(232, 338, 64, 42, "#e6e0da", rx=18)
    a.path("M246 346 L246 372", stroke="#ffffff", sw=6, **{"stroke-opacity": "0.6"})
    a.shine("M120 226 L300 226")
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
    a.path("M222 312 L204 392 M290 312 L308 392 M256 316 L256 392", sw=8)
    a.path("M184 388 L328 388 L316 462 C314 470 308 474 300 474 L212 474 C204 474 198 470 196 462 Z", fill=WOOD)
    a.path("M190 416 L322 416 M194 444 L318 444", sw=7)
    for x in (230, 256, 282):
        a.path(f"M{x} 388 L{x} 474", sw=6)
    a.rect(176, 378, 160, 24, WOOD_D, rx=10, sw=9)
    a.path(ENV, fill=RED)
    a.path(lens(165), fill=WHITE, sw=0, stroke="none")
    a.path(lens(112), fill=YEL2, sw=0, stroke="none")
    a.path(lens(60), fill=BLUE, sw=0, stroke="none")
    a.path(ENV)
    a.path("M214 316 L298 316", sw=11)
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


@word
def sakura():
    a = Art()
    a.path("M440 470 C380 420 320 380 250 310 C200 260 170 220 160 170", sw=34)
    a.path("M440 470 C380 420 320 380 250 310 C200 260 170 220 160 170", stroke="#9a6b4a", sw=16)
    a.path("M250 310 C230 320 210 326 196 330", sw=26)
    a.path("M250 310 C230 320 210 326 196 330", stroke="#9a6b4a", sw=11)
    blossom(a, 168, 150, 88, 0.2)
    blossom(a, 340, 230, 100, 0.55)
    blossom(a, 392, 408, 66, 0.0)
    blossom(a, 196, 330, 70, 0.4)
    return a


@word
def himawari():
    import math
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    a.path("M256 300 C256 340 252 380 256 420", sw=40)
    a.path("M256 300 C256 340 252 380 256 420", stroke=LEAF, sw=18)
    for s in (-1, 1):
        d = "M256 372 C300 346 352 342 390 366 C354 402 298 408 256 386 Z"
        a.path(d if s > 0 else mirror(d), fill=LEAF)
        v = "M270 376 C310 366 340 366 366 370"
        a.path(v if s > 0 else mirror(v), stroke=LEAF_D, sw=6)
    n = 12
    for i in range(n):
        a.path(petal(256, 190, 150, i * 2 * math.pi / n, w=0.46, notch=False), fill="#f4c23a")
    for i in range(n):
        a.path(petal(256, 190, 136, (i + 0.5) * 2 * math.pi / n, w=0.46, notch=False), fill=YEL2)
    a.circle(256, 190, 74, "#8a5530")
    a.circle(256, 190, 50, "#6e4224", sw=0, stroke="none")
    for r, cnt in ((20, 6), (36, 12)):
        for j in range(cnt):
            t = j * 2 * math.pi / cnt + r
            a.dot(256 + r * math.cos(t), 190 + r * math.sin(t), 5.5, "#b98255")
    a.dot(256, 190, 5.5, "#b98255")
    a.shine("M204 156 C210 134 226 118 246 112")
    return a


@word
def tanpopo():
    import math
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    # toothed leaves at the base
    leaf = ("M250 462 L196 452 L206 426 L160 424 L170 396 L124 388 L146 364 L96 346 L150 338 "
            "L186 372 L226 392 L252 420 Z")
    a.path(leaf, fill=LEAF)
    a.path(mirror(leaf), fill=LEAF)
    a.path("M256 462 L256 300", sw=34)
    a.path("M256 462 L256 300", stroke="#8fd07a", sw=14)
    n = 22
    pts = []
    for i in range(n * 2):
        r = 116 if i % 2 == 0 else 92
        t = i * math.pi / n
        pts.append(f"{256 + r * math.sin(t):.1f} {180 - r * math.cos(t):.1f}")
    a.path("M" + " L".join(pts) + " Z", fill="#f7c948")
    for i in range(n):
        t = i * 2 * math.pi / n
        a.path(f"M{256 + 40 * math.sin(t):.1f} {180 - 40 * math.cos(t):.1f} "
               f"L{256 + 84 * math.sin(t):.1f} {180 - 84 * math.cos(t):.1f}", stroke="#fbe07a", sw=9)
    a.circle(256, 180, 30, "#f0b429", sw=0, stroke="none")
    a.shine("M206 140 C214 120 228 106 246 100")
    return a


@word
def ringo():
    a = Art()
    a.path("M260 140 C262 110 268 86 282 60", sw=30)
    a.path("M260 140 C262 110 268 86 282 60", stroke="#8a5530", sw=12)
    a.path("M282 96 C312 46 372 40 404 62 C386 116 326 132 282 96 Z", fill=GREEN)
    a.path("M296 92 C328 78 360 72 386 70", stroke="#58a24a", sw=6)
    a.path("M256 142 C296 98 404 104 412 224 C418 342 344 436 292 436 C272 436 264 428 256 428 "
           "C248 428 240 436 220 436 C168 436 94 342 100 224 C108 104 216 98 256 142 Z", fill=RED)
    a.path("M326 392 C366 368 392 316 398 258 C384 330 350 372 306 398 Z", fill=RED_D, sw=0, stroke="none")
    a.shine("M152 214 C148 178 164 150 192 138")
    return a


@word
def mikan():
    a = Art()
    OR, OR_D = "#f7931e", "#e57d12"
    a.path("M96 290 C96 190 170 140 256 140 C342 140 416 190 416 290 C416 380 346 436 256 436 C166 436 96 380 96 290 Z", fill=OR)
    a.path("M330 408 C376 380 408 330 410 280 C404 350 372 394 316 420 Z", fill=OR_D, sw=0, stroke="none")
    for dx, dy in ((-70, 250), (-30, 350), (60, 290), (30, 380), (-90, 330), (100, 350)):
        a.dot(256 + dx, dy - 20, 3.5, "#f9b24f")
    a.path("M256 144 L256 112", sw=26)
    a.path("M256 144 L256 112", stroke="#6aa84f", sw=10)
    star = "M256 150 C236 148 214 136 198 120 C226 112 244 124 256 150 C268 124 286 112 314 120 C298 136 276 148 256 150 Z"
    a.path(star, fill=GREEN)
    a.path("M262 112 C290 76 340 62 372 74 C356 112 306 126 262 112 Z", fill=GREEN)
    a.path("M278 106 C308 94 336 88 360 82", stroke="#58a24a", sw=6)
    a.shine("M140 262 C140 224 164 190 200 172")
    return a


@word
def ichigo():
    a = Art()
    a.path("M256 456 C176 420 98 340 98 250 C98 186 150 150 256 162 C362 150 414 186 414 250 C414 340 336 420 256 456 Z", fill=RED)
    a.path("M330 410 C376 372 406 316 406 262 C396 330 360 380 312 420 Z", fill=RED_D, sw=0, stroke="none")
    seeds = [(176, 238), (256, 226), (336, 238), (136, 282), (216, 286), (296, 286), (376, 282),
             (176, 334), (256, 338), (336, 334), (216, 386), (296, 386), (256, 424)]
    for x, y in seeds:
        a.ellipse(x, y, 8, 12, "#ffe18a", sw=0, stroke="none")
    # green top
    a.path("M256 170 L256 116", sw=26)
    a.path("M256 170 L256 116", stroke="#6aa84f", sw=10)
    top = ("M256 190 C230 196 196 186 150 160 C176 152 206 154 232 168 C214 148 204 128 200 104 "
           "C228 118 244 142 256 164 C268 142 284 118 312 104 C308 128 298 148 280 168 "
           "C306 154 336 152 362 160 C316 186 282 196 256 190 Z")
    a.path(top, fill=GREEN)
    a.shine("M138 250 C136 220 156 192 186 182")
    return a


@word
def ninjin():
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    for d in ("M250 160 C214 140 168 110 160 56 C206 62 248 96 266 156 Z",
              "M240 160 C230 110 238 60 262 22 C292 62 296 118 280 160 Z",
              "M262 162 C300 124 352 98 396 100 C382 148 330 176 270 172 Z"):
        a.path(d, fill=LEAF)
    a.path("M256 150 C340 140 370 170 352 210 C320 310 290 400 264 462 C258 474 250 474 246 462 "
           "C220 400 188 310 160 210 C142 170 172 140 256 150 Z", fill="#f78d2e")
    a.path("M318 240 C298 332 280 398 264 444 C294 394 312 326 322 252 Z", fill="#e07a1e", sw=0, stroke="none")
    for y, x0, x1 in ((222, 190, 236), (292, 212, 252), (360, 232, 262)):
        a.path(f"M{x0} {y} L{x1} {y}", stroke="#e07a1e", sw=8)
    a.shine("M192 188 C190 172 202 162 220 160")
    return a


@word
def daikon():
    a = Art()
    LEAF, LEAF_D = "#6fbd5c", "#4f9e48"
    for d, v in (("M246 196 C190 170 134 120 126 48 C196 58 246 108 262 190 Z", "M236 180 C202 144 170 108 144 66"),
                 ("M246 196 C232 140 238 80 262 20 C296 82 298 144 272 196 Z", "M258 180 C252 130 254 84 262 44"),
                 ("M266 196 C316 164 372 128 422 116 C410 176 340 212 270 206 Z", "M278 190 C320 168 366 146 404 132")):
        a.path(d, fill=LEAF)
        a.path(v, stroke=LEAF_D, sw=6)
    a.path("M256 186 C310 182 330 214 324 262 C318 354 288 434 264 474 C260 482 252 482 248 474 "
           "C224 434 194 354 188 262 C182 214 202 182 256 186 Z", fill="#f8f5ec")
    a.path("M190 270 C186 218 202 186 256 190 C310 186 326 218 322 270 C296 242 216 242 190 270 Z",
           fill="#cfe8b0", sw=0, stroke="none")
    a.path("M302 270 C296 350 282 410 262 462 C292 420 316 350 320 280 Z", fill="#e9e3d2", sw=0, stroke="none")
    for y, x0, x1 in ((300, 214, 238), (352, 226, 248), (404, 240, 256)):
        a.path(f"M{x0} {y} L{x1} {y}", stroke="#d8d0bb", sw=7)
    a.path("M256 186 C310 182 330 214 324 262 C318 354 288 434 264 474 C260 482 252 482 248 474 "
           "C224 434 194 354 188 262 C182 214 202 182 256 186 Z")
    a.shine("M210 236 C208 216 208 202 226 196")
    return a


@word
def kabocha():
    a = Art()
    GRN, GRN_D, ORG = "#4f9a4a", "#3b7f3b", "#f0a030"
    a.path("M262 150 C264 118 276 94 298 74", sw=32)
    a.path("M262 150 C264 118 276 94 298 74", stroke="#8a6a3a", sw=14)
    body = ("M256 152 C330 130 430 150 440 250 C448 340 380 420 256 420 C132 420 64 340 72 250 "
            "C82 150 182 130 256 152 Z")
    a.path(body, fill=GRN)
    # lobes: lighter segments with ribs
    a.path("M256 152 C214 190 204 360 256 420 C308 360 298 190 256 152 Z", fill="#f4a93c", sw=0, stroke="none")
    a.path("M256 152 C214 190 204 360 256 420", sw=8)
    a.path("M256 152 C298 190 308 360 256 420", sw=8)
    a.path("M170 148 C122 200 118 320 160 392", sw=7)
    a.path("M342 148 C390 200 394 320 352 392", sw=7)
    # orange lower part (ripe kabocha)
    for x, y in ((112, 330), (404, 336), (150, 270), (368, 264), (150, 366), (362, 372)):
        a.ellipse(x, y, 10, 7, "#f4a93c", sw=0, stroke="none")
    a.path(body)
    a.path("M254 150 L264 150", sw=10)
    a.shine("M118 230 C118 196 142 170 176 160")
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
    UP, LO = "#f6a04d", "#f58fb4"
    up = "M250 232 C214 130 110 70 64 126 C34 180 84 262 250 262 Z"
    lo = "M250 258 C170 262 100 308 118 372 C136 432 224 404 250 316 Z"
    # antennae behind
    for s in (-1, 1):
        a.path(f"M{256+s*12} 150 C{256+s*20} 100 {256+s*48} 76 {256+s*74} 74", sw=8)
        a.circle(256 + s * 76, 74, 11, O, sw=0, stroke="none")
    for d in (lo, mirror(lo)):
        a.path(d, fill=LO)
    for d in (up, mirror(up)):
        a.path(d, fill=UP)
    for s in (-1, 1):
        x = 256 + s * 1
        a.circle(256 + s * 120, 160, 26, "#fff4cf", sw=0, stroke="none")
        a.circle(256 + s * 120, 160, 12, "#c35f9a", sw=0, stroke="none")
        a.circle(256 + s * 96, 342, 18, "#fff4cf", sw=0, stroke="none")
    a.path("M256 150 C284 150 290 190 288 250 C286 330 276 396 256 410 C236 396 226 330 224 250 C222 190 228 150 256 150 Z", fill="#8a5a44")
    a.circle(256, 160, 40, "#f5d6b0")
    bug_face(a, 256, 162, gap=17, r=8)
    a.shine("M88 126 C106 108 130 100 152 104")
    return a


@word
def tonbo():
    a = Art()
    WG = "#cfeaf7"
    up = "M246 196 C200 140 120 118 58 138 C40 164 90 214 246 222 Z"
    lo = "M246 228 C190 232 118 262 78 306 C86 338 150 336 246 262 Z"
    for d in (lo, mirror(lo), up, mirror(up)):
        a.path(d, fill=WG)
    for s in (-1, 1):
        a.path(f"M{256+s*20} 196 C{256+s*100} 176 {256+s*150} 160 {256+s*190} 148", stroke="#a9d3ea", sw=5)
        a.path(f"M{256+s*20} 244 C{256+s*80} 262 {256+s*120} 282 {256+s*160} 308", stroke="#a9d3ea", sw=5)
    a.path("M256 120 C282 120 290 150 288 200 C286 300 274 400 256 470 C238 400 226 300 224 200 C222 150 230 120 256 120 Z", fill=RED)
    for y in (232, 282, 332, 382):
        a.path(f"M{231-(y-232)*0.03:.0f} {y} L{281+(y-232)*0.03*-1:.0f} {y}", stroke=RED_D, sw=7)
    a.circle(256, 128, 40, "#f08a4b")
    bug_face(a, 256, 130, gap=21, r=9)
    a.shine("M70 140 C92 128 120 126 148 132")
    return a


@word
def hachi():
    a = Art()
    BEE, BLK, WG = "#f7c948", "#3b2f2a", "#d6eefb"
    cx, cy, rx, ry = 322, 300, 134, 100
    # wings behind
    a.path("M290 214 C240 150 250 70 306 66 C352 70 350 160 330 214 Z", fill=WG)
    a.path("M340 214 C340 150 380 90 428 106 C456 150 410 206 366 222 Z", fill=WG)
    # stinger
    a.path(f"M{cx+rx-6} 300 L{cx+rx+46} 316 L{cx+rx-4} 330 Z", fill=BLK)
    a.ellipse(cx, cy, rx, ry, BEE)
    import math
    def ytop(x):
        return cy - ry * math.sqrt(max(0, 1 - ((x - cx) / rx) ** 2))
    for x1, x2 in ((258, 296), (336, 374), (410, 436)):
        t1, t2 = ytop(x1), ytop(x2)
        b1, b2 = 2 * cy - t1, 2 * cy - t2
        a.path(f"M{x1} {t1:.1f} A{rx} {ry} 0 0 1 {x2} {t2:.1f} L{x2} {b2:.1f} A{rx} {ry} 0 0 1 {x1} {b1:.1f} Z", fill=BLK, sw=0, stroke="none")
    a.ellipse(cx, cy, rx, ry, "none")
    # antennae, head
    for dx in (-26, 26):
        a.path(f"M{136+dx} 238 C{136+dx} 200 {136+dx*2} 182 {136+dx*2} 168", sw=8)
        a.circle(136 + dx * 2, 164, 9, O, sw=0, stroke="none")
    a.circle(140, 302, 76, BEE)
    bug_face(a, 140, 300, gap=28, r=11)
    a.shine("M92 262 C100 244 116 234 134 232")
    return a


@word
def hotaru():
    a = Art()
    BLK, WG = "#4a4458", "#d9eefb"
    cx, cy = 300, 290
    # wings behind
    a.path("M250 280 C226 190 276 108 330 104 C380 104 366 200 330 280 Z", fill=WG)
    a.path("M300 280 C300 200 360 130 404 146 C430 190 390 250 352 284 Z", fill=WG)
    # glowing tail (bright, with a soft halo)
    a.circle(412, 326, 76, "#fff2a6", sw=0, stroke="none", **{"fill-opacity": "0.55"})
    a.path("M330 262 C390 238 456 270 456 322 C456 372 396 396 336 366 Z", fill="#ffe14d")
    a.path("M344 260 C300 250 250 262 214 290 C204 320 214 350 244 372 C284 390 322 380 342 366 Z", fill=BLK)
    a.ellipse(262, 330, 6, 6, BLK, sw=0, stroke="none") if False else None
    a.path("M342 262 C354 296 354 334 340 366", sw=8)
    # legs
    for x in (252, 292):
        a.path(f"M{x} 372 L{x-10} 412", stroke=O, sw=12)
    # head
    a.circle(160, 300, 74, "#f08a4b")
    bug_face(a, 160, 300, gap=28, r=11)
    for dx in (-24, 24):
        a.path(f"M{160+dx} 232 C{160+dx} 200 {160+dx*2} 182 {160+dx*2} 168", sw=8)
        a.circle(160 + dx * 2, 164, 9, O, sw=0, stroke="none")
    a.shine("M112 262 C120 244 136 234 154 232")
    return a


@word
def semi():
    a = Art()
    BR, BRD, WG = "#8a5a3a", "#6b4429", "#f4fcfb"
    # legs (behind)
    for x in (230, 280, 330):
        a.path(f"M{x} 330 L{x-14} 392", sw=22)
        a.path(f"M{x} 330 L{x-14} 392", stroke=BRD, sw=10)
    # body
    a.path("M170 252 C190 190 270 170 340 190 C420 212 456 290 440 340 C380 372 250 372 190 336 C168 316 162 280 170 252 Z", fill=BR)
    a.path("M250 336 C320 350 390 346 436 330", stroke="#e8a66a", sw=9)
    a.path("M230 196 C240 250 238 300 226 334", stroke=BRD, sw=7)
    # wings over the back
    a.path("M214 214 C250 150 380 140 476 200 C486 240 400 306 252 312 C224 290 206 252 214 214 Z", fill=WG, **{"fill-opacity": "0.9"})
    a.path("M250 226 C320 212 396 220 452 226", stroke="#b6d9d3", sw=5)
    a.path("M246 270 C320 262 396 258 462 236", stroke="#b6d9d3", sw=5)
    a.path("M300 214 C292 250 280 290 268 316", stroke="#b6d9d3", sw=5)
    # head
    a.ellipse(150, 270, 80, 66, BR)
    a.path("M176 214 C190 232 192 250 188 266", stroke="#e8a66a", sw=9)
    bug_face(a, 150, 270, gap=28, r=11)
    a.shine("M100 252 C104 230 120 218 142 214")
    return a


@word
def kabutomushi():
    a = Art()
    SH, SHD, HD = "#5b3a28", "#3f2a1e", "#7a4a2e"
    for x in (240, 300, 360):
        a.path(f"M{x} 350 L{x-6} 420 L{x-22} 432", sw=24)
        a.path(f"M{x} 350 L{x-6} 420 L{x-22} 432", stroke=SHD, sw=12)
    # shell (dome)
    a.path("M170 310 C170 210 250 170 330 178 C416 186 452 250 446 322 C400 350 250 352 170 310 Z", fill=SH)
    a.path("M312 180 C318 230 318 290 310 340", stroke=O, sw=8)
    # horn (behind head, rises up and curls forward)
    a.path("M132 270 C100 220 96 150 128 104 C160 80 190 90 196 108 C170 112 150 140 156 190 C160 230 176 260 176 290 Z", fill=SHD)
    a.ellipse(160, 304, 70, 58, HD)
    bug_face(a, 154, 304, gap=24, r=10)
    a.shine("M350 214 C380 218 408 238 420 268")
    return a


@word
def tentoumushi():
    a = Art()
    RD = "#e5453b"
    for dx in (-22, 22):
        a.path(f"M{256+dx*0.6} 140 C{256+dx*1.2} 106 {256+dx*2} 92 {256+dx*2.6} 84", sw=8)
        a.circle(256 + dx * 2.6, 82, 8, O, sw=0, stroke="none")
    # round red dome, seen from the back with the head peeking at the top
    a.circle(256, 316, 128, RD)
    a.path("M256 190 L256 444", stroke=O, sw=8)
    for x, y, r in ((190, 270, 20), (322, 270, 20), (176, 352, 18), (336, 352, 18), (222, 410, 16), (290, 410, 16)):
        a.circle(x, y, r, "#3b2f2a", sw=0, stroke="none")
    a.ellipse(256, 176, 76, 54, "#4a4458")
    for s in (-1, 1):
        a.ellipse(256 + s * 30, 168, 20, 22, "#ffffff", sw=0, stroke="none")
        a.ellipse(256 + s * 30 + s * 2, 172, 9, 11, EYE, sw=0, stroke="none")
        a.dot(256 + s * 30 + 4, 166, 3.5, "#ffffff")
    a.path("M242 200 C250 210 262 210 270 200", stroke="#ffffff", sw=6)
    a.shine("M160 300 C158 262 172 236 196 222")
    return a


@word
def katatsumuri():
    a = Art()
    SK, SHL, SPI = "#f2d9a8", "#f4a261", "#d9742e"
    # eye stalks
    for dx in (-24, 24):
        a.tube(f"M{140+dx} 290 C{140+dx} 240 {140+dx*1.6} 214 {140+dx*1.8} 190", SK, 30, 12)
        a.circle(140 + dx * 1.8, 184, 17, SK)
        a.dot(140 + dx * 1.8, 186, 6)
    # body with a raised head
    a.path("M70 424 C70 340 96 284 150 284 C196 284 224 312 226 352 L250 392 L440 392 C476 392 476 458 440 458 L112 458 C86 458 70 444 70 424 Z", fill=SK)
    bug_face(a, 146, 336, gap=22, r=9)
    # shell
    a.circle(318, 262, 124, SHL)
    a.path("M318 264 C318 238 350 238 352 266 C352 306 292 312 284 262 C276 208 340 190 372 236 C406 288 366 354 306 346 C240 336 228 262 262 214", stroke=SPI, sw=12)
    a.shine("M246 188 C262 164 292 150 322 150")
    return a


@word
def momo():
    a = Art()
    LEAF = "#6fbd5c"
    body = ("M256 150 C340 116 424 178 412 282 C402 376 326 440 262 442 C190 444 108 384 100 284 "
            "C92 180 176 118 256 150 Z")
    a.path("M258 150 C262 124 276 108 296 100", sw=24)
    a.path("M258 150 C262 124 276 108 296 100", stroke="#8a6a3a", sw=10)
    a.path("M296 104 C322 70 380 62 410 86 C396 126 340 140 296 112 Z", fill=LEAF)
    a.path("M304 100 C336 88 372 86 396 90", stroke="#4f9e48", sw=6)
    a.path(body, fill="#fcc5bb")
    a.path("M412 282 C402 376 326 440 262 442 C230 442 196 430 170 410 C260 420 360 360 380 220 C400 230 414 252 412 282 Z", fill="#f79fa4", sw=0, stroke="none")
    a.path(body)
    a.path("M256 150 C230 210 232 330 270 438", sw=7)
    a.shine("M130 270 C124 228 142 190 180 168")
    return a


@word
def budou():
    a = Art()
    PU, PUD, LEAF = "#a46bd0", "#8a4fbc", "#6fbd5c"
    # stem and leaf behind
    a.path("M256 170 C252 130 262 100 290 78", sw=26)
    a.path("M256 170 C252 130 262 100 290 78", stroke="#8a6a3a", sw=12)
    a.path("M290 90 C322 52 398 50 430 84 C420 138 340 154 290 108 Z", fill=LEAF)
    a.path("M300 96 C340 82 388 78 418 86", stroke="#4f9e48", sw=6)
    rows = [(174, (176, 256, 336)), (238, (136, 216, 296, 376)), (302, (176, 256, 336)), (366, (216, 296)), (430, (256,))]
    for y, xs in reversed(rows):
        for x in xs:
            a.circle(x, y, 44, PU)
    a.shine("M222 160 C228 146 240 138 254 136")
    return a


@word
def suika():
    a = Art()
    a.path("M56 180 A200 200 0 0 0 456 180 Z", fill="#4f9a4a")
    a.path("M76 180 A180 180 0 0 0 436 180 Z", fill="#f1f6d8", sw=0, stroke="none")
    a.path("M92 180 A164 164 0 0 0 420 180 Z", fill="#ec4b52", sw=0, stroke="none")
    # darker stripes on the rind
    a.path("M56 180 A200 200 0 0 0 456 180 Z")
    seed = lambda x, y, r: "M%d %d C%d %d %d %d %d %d C%d %d %d %d %d %d Z" % (
        x, y - 18, x + 12, y - 4, x + 10, y + 14, x, y + 20, x - 10, y + 14, x - 12, y - 4, x, y - 18)
    for x, y in ((190, 220), (256, 250), (322, 220), (222, 290), (290, 290)):
        a.path(seed(x, y, 0), fill=EYE, sw=0, stroke="none")
    a.shine("M118 214 C130 262 160 296 200 318")
    return a


@word
def kuri():
    a = Art()
    body = ("M256 70 C286 90 312 120 350 160 C410 216 430 300 396 372 C368 430 316 452 256 452 "
            "C196 452 144 430 116 372 C82 300 102 216 162 160 C200 120 226 90 256 70 Z")
    a.path(body, fill="#9a5a30")
    # lighter base (the flat bottom of a chestnut) with a wavy top edge
    a.path("M126 372 C160 350 190 392 224 366 C250 346 270 392 300 366 C330 346 360 380 388 360 "
           "C368 424 316 452 256 452 C196 452 146 424 126 372 Z", fill="#e8c493", sw=0, stroke="none")
    a.path("M256 70 C262 84 270 96 280 108 C268 112 244 112 232 108 C242 96 250 84 256 70 Z", fill="#6b3c1e", sw=0, stroke="none")
    a.path(body)
    a.shine("M148 250 C148 222 162 196 186 176")
    return a


@word
def dango():
    a = Art()
    a.tube("M340 40 L172 476", "#e0bb85", 26, 12)
    pts = [(300, 150, "#f7a8c0"), (256, 262, "#fffaf0"), (212, 374, "#a8d98a")]
    for x, y, c in pts:
        a.circle(x, y, 68, c)
    a.shine("M258 120 C272 104 292 100 308 104")
    return a


@word
def senbei():
    a = Art()
    import math
    R = 190
    a.circle(256, 256, R, "#e8a95b")
    a.circle(256, 256, R - 26, "#f0bd75", sw=0, stroke="none")
    for x, y in ((156, 190), (196, 332), (350, 340), (332, 160), (112, 280), (400, 250)):
        a.circle(x, y, 9, "#c98a42", sw=0, stroke="none")
    x1, x2 = 206, 306
    h = lambda x: math.sqrt(R * R - (x - 256) ** 2)
    a.path(f"M{x1} {256-h(x1):.1f} A{R} {R} 0 0 1 {x2} {256-h(x2):.1f} L{x2} {256+h(x2):.1f} A{R} {R} 0 0 1 {x1} {256+h(x1):.1f} Z",
           fill="#34423a", sw=0, stroke="none")
    for x in (232, 256, 280):
        a.path(f"M{x} {256-h(x)+24:.1f} L{x} {256+h(x)-24:.1f}", stroke="#4d6054", sw=5)
    a.circle(256, 256, R, "none")
    a.shine("M120 210 C132 170 160 140 200 124")
    return a


@word
def wataame():
    a = Art()
    import math
    a.tube("M256 250 L256 484", "#f4e3c4", 36, 18)
    cx, cy, R, n = 256, 170, 124, 9
    pts = [(cx + R * math.cos(2 * math.pi * i / n - math.pi / 2), cy + R * 0.92 * math.sin(2 * math.pi * i / n - math.pi / 2)) for i in range(n)]
    d = f"M{pts[0][0]:.1f} {pts[0][1]:.1f} " + " ".join(
        f"A58 58 0 0 1 {pts[(i+1) % n][0]:.1f} {pts[(i+1) % n][1]:.1f}" for i in range(n)) + " Z"
    a.path(d, fill="#f9b8d2")
    a.path("M256 100 C316 100 334 164 290 188 C248 208 206 172 232 142 C252 122 284 138 274 160", stroke="#f08fb8", sw=9)
    a.path("M170 190 C180 240 230 252 262 238", stroke="#f08fb8", sw=9)
    a.shine("M168 130 C184 100 214 80 248 76")
    return a


@word
def onigiri():
    a = Art()
    body = ("M256 84 C292 84 312 118 362 198 C412 278 432 340 426 386 C420 424 392 436 360 436 L152 436 "
            "C120 436 92 424 86 386 C80 340 100 278 150 198 C200 118 220 84 256 84 Z")
    a.path(body, fill="#fffdf6")
    for x, y, d in ((230, 190, 1), (284, 214, -1), (206, 262, -1), (300, 274, 1), (256, 168, 0)):
        a.path(f"M{x-7} {y+d*5} L{x+7} {y-d*5}", stroke="#e4ddca", sw=8)
    a.path("M362 198 C412 278 432 340 426 386 C420 424 392 436 360 436 L300 436 C360 380 360 280 330 150 Z", fill="#efe9d6", sw=0, stroke="none")
    a.path("M104 332 C150 318 362 318 408 332 C422 366 428 394 424 404 C418 428 392 436 360 436 L152 436 "
           "C120 436 94 428 88 404 C84 394 90 366 104 332 Z", fill="#2f4a3a", sw=0, stroke="none")
    a.path("M130 372 L382 372", stroke="#4a6a56", sw=6)
    a.path(body)
    a.shine("M168 236 C192 190 214 150 242 118")
    return a


@word
def sushi():
    a = Art()
    a.path("M120 290 C70 290 70 440 130 440 L382 440 C442 440 442 290 392 290 Z", fill="#fffdf6")
    for x, y in ((150, 388), (210, 408), (276, 390), (336, 408), (386, 378)):
        a.path(f"M{x-7} {y+5} L{x+7} {y-5}", stroke="#e4ddca", sw=8)
    a.path("M376 300 C428 300 442 380 400 430 C430 420 446 350 392 290 Z", fill="#efe9d6", sw=0, stroke="none")
    a.path("M120 290 C70 290 70 440 130 440 L382 440 C442 440 442 290 392 290 Z", "none")
    a.path("M54 270 C54 190 170 160 256 168 C342 160 458 190 458 270 C458 330 400 346 256 346 C112 346 54 330 54 270 Z", fill="#e8505b")
    for d in ("M150 190 C168 240 160 290 128 332", "M240 172 C262 226 256 290 226 344", "M340 176 C362 226 358 288 330 342"):
        a.path(d, stroke="#f9a0a0", sw=14)
    a.path("M54 270 C54 190 170 160 256 168 C342 160 458 190 458 270 C458 330 400 346 256 346 C112 346 54 330 54 270 Z", "none")
    a.shine("M92 250 C94 222 116 202 150 192")
    return a


@word
def udon():
    a = Art()
    # chopsticks behind
    a.tube("M380 40 L300 210", "#d9a05f", 24, 10)
    a.tube("M420 56 L330 214", "#d9a05f", 24, 10)
    # bowl
    a.path("M196 460 L316 460", sw=24)
    a.path("M52 246 L460 246 C460 372 384 446 256 446 C128 446 52 372 52 246 Z", fill="#fffdf6")
    a.path("M64 300 C140 330 372 330 448 300 C440 328 436 336 432 346 C360 372 152 372 80 346 C76 336 70 328 64 300 Z", fill="#4fa8e0", sw=0, stroke="none")
    a.path("M52 246 L460 246 C460 372 384 446 256 446 C128 446 52 372 52 246 Z", "none")
    a.ellipse(256, 246, 204, 40, "#e9b36a")
    # noodles heaped up
    for d in ("M110 250 C100 190 160 170 190 214 C216 252 270 250 270 200 C270 160 320 160 330 204 C338 240 380 236 396 212",
              "M130 258 C140 214 190 206 210 236 C230 266 290 262 300 226 C310 196 350 196 366 224 C376 244 392 250 404 244"):
        a.tube(d, "#fbf0d4", 50, 28)
    a.circle(190, 200, 34, "#fffdf6")
    a.circle(190, 200, 15, "#f58fb4", sw=0, stroke="none")
    for x, y in ((290, 176), (330, 200), (236, 238)):
        a.circle(x, y, 13, "#6fbd5c", sw=7)
    a.shine("M84 330 C96 366 118 390 148 408")
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
    R, RD = "#ee5b52", "#d9443f"
    # 8 legs fanning out under the head, tips curled
    legs = [(-200, 0, -1), (-146, 40, -1), (-92, 60, -1), (-36, 64, -1),
            (36, 64, 1), (92, 60, 1), (146, 40, 1), (200, 0, 1)]
    for dx, dy, s in legs:
        x0 = 256 + dx * 0.55
        x1 = 256 + dx
        yb = 360 + dy
        a.path(f"M{x0} 330 C{x0} 390 {x1} {yb-10} {x1} {yb+54} C{x1} {yb+94} {x1+s*22} {yb+90} {x1+s*30} {yb+66}",
               fill="none", sw=52)
        a.path(f"M{x0} 330 C{x0} 390 {x1} {yb-10} {x1} {yb+54} C{x1} {yb+94} {x1+s*22} {yb+90} {x1+s*30} {yb+66}",
               stroke=R, sw=30)
    # head
    a.path("M256 56 C376 56 410 150 396 238 C386 306 330 340 256 340 C182 340 126 306 116 238 C102 150 136 56 256 56 Z", fill=R)
    for x, y in ((190, 118), (320, 106), (356, 176)):
        a.circle(x, y, 9, RD, sw=0, stroke="none")
    sea_face(a, 256, 224, gap=54, r=16, blush_dx=96)
    a.shine("M164 150 C166 112 188 88 220 78")
    return a


@word
def ika():
    a = Art()
    BODYC, TOPC = "#fdf1ee", "#f6a9b4"
    # tentacles
    for i, dx in enumerate((-70, -36, 0, 36, 70)):
        x = 256 + dx
        a.path(f"M{x} 330 C{x+dx*0.2} 380 {x+dx*0.4} 400 {x+dx*0.5} 440", fill="none", sw=40)
        a.path(f"M{x} 330 C{x+dx*0.2} 380 {x+dx*0.4} 400 {x+dx*0.5} 440", stroke=BODYC, sw=18)
    # triangle fins on a pointed head
    a.path("M256 20 L386 150 L322 170 Z", fill=TOPC)
    a.path("M256 20 L126 150 L190 170 Z", fill=TOPC)
    a.path("M256 40 C318 40 344 150 340 250 C338 310 300 346 256 346 C212 346 174 310 172 250 C168 150 194 40 256 40 Z",
           fill=BODYC)
    a.path("M256 60 C256 130 256 210 256 280", stroke=TOPC, sw=7, **{"stroke-opacity": "0.8"})
    sea_face(a, 256, 252, gap=46, r=15, blush_dx=80)
    a.shine("M200 110 C196 150 196 190 200 220")
    return a


@word
def kani():
    a = Art()
    R, RD = "#ee5b52", "#d9443f"
    # legs (3 each side): out, then down
    for s in (-1, 1):
        for i, (y, ex, ey) in enumerate(((330, 200, 388), (352, 214, 418), (372, 222, 448))):
            d = f"M{256+s*120} {y} L{256+s*ex} {y+8} L{256+s*(ex+4)} {ey}"
            a.tube(d, R, 30, 12)
    # arms with claws
    for s in (-1, 1):
        a.path(f"M{256+s*96} 250 C{256+s*150} 220 {256+s*170} 190 {256+s*168} 156", sw=38)
        a.path(f"M{256+s*96} 250 C{256+s*150} 220 {256+s*170} 190 {256+s*168} 156", stroke=R, sw=18)
        cx = 256 + s * 168
        d = (f"M{cx} 160 C{cx-s*58} 160 {cx-s*74} 90 {cx-s*36} 56 C{cx-s*20} 44 {cx} 70 {cx} 92 "
             f"C{cx} 70 {cx+s*24} 40 {cx+s*44} 58 C{cx+s*78} 92 {cx+s*54} 160 {cx} 160 Z")
        a.path(d, fill=R)
    # shell
    a.path("M256 170 C376 170 430 240 430 310 C430 380 350 410 256 410 C162 410 82 380 82 310 C82 240 136 170 256 170 Z", fill=R)
    for x, y in ((170, 360), (256, 380), (342, 360)):
        a.circle(x, y, 9, RD, sw=0, stroke="none")
    sea_face(a, 256, 270, gap=62, r=17, blush_dx=112)
    a.shine("M130 280 C134 250 156 222 188 208")
    return a


@word
def kame():
    a = Art()
    G, GD, SH, SHL = "#8fcf6d", "#6fb552", "#4fa85a", "#7ccb6a"
    # flippers and tail
    a.path("M120 330 C70 330 56 390 106 408 C140 418 170 392 176 360 Z", fill=G)
    a.path("M392 330 C442 330 456 390 406 408 C372 418 342 392 336 360 Z", fill=G)
    a.path("M146 420 C120 430 118 470 156 472 C186 472 196 440 190 420 Z", fill=G)
    a.path("M366 420 C392 430 394 470 356 472 C326 472 316 440 322 420 Z", fill=G)
    a.path("M250 400 C256 430 266 440 276 446 C262 446 248 436 244 412 Z", fill=G, sw=8)
    # head
    a.path("M256 56 C320 56 346 108 340 156 C334 196 300 214 256 214 C212 214 178 196 172 156 C166 108 192 56 256 56 Z", fill=G)
    sea_face(a, 256, 128, gap=36, r=13, blush_dx=66)
    # shell
    a.path("M96 340 C96 244 164 190 256 190 C348 190 416 244 416 340 C416 392 350 420 256 420 C162 420 96 392 96 340 Z", fill=SH)
    # shell pattern: hexagon plates
    a.path("M256 232 L306 262 L306 322 L256 352 L206 322 L206 262 Z", fill=SHL, sw=9)
    a.path("M256 232 L256 200 M306 262 L350 240 M306 322 L352 346 M256 352 L256 400 M206 322 L160 346 M206 262 L162 240", sw=9)
    a.shine("M130 320 C130 278 152 244 186 224")
    return a


@word
def kujira():
    a = Art()
    B, BD, BELLY = "#5ab0e8", "#3f97d0", "#e8f6ff"
    # water spout
    for dx, dy in ((-34, 0), (0, -26), (34, 0)):
        a.path(f"M{200+dx*0.2} 140 C{200+dx*0.6} {100+dy} {200+dx*1.4} {80+dy} {200+dx*1.8} {96+dy}", stroke="#9bd6f6", sw=26)
    # tail
    a.path("M400 300 C440 290 456 250 450 214 C478 224 496 252 480 290 C470 316 440 330 410 334 Z", fill=B)
    a.path("M400 300 C398 270 430 238 450 214 C428 230 408 236 396 232 Z", fill=B, sw=0, stroke="none")
    # body
    a.path("M60 300 C60 200 140 140 256 140 C372 140 430 220 424 310 C418 380 340 410 240 410 C140 410 60 376 60 300 Z", fill=B)
    # belly
    a.path("M74 340 C130 392 330 408 414 350 C400 388 330 412 240 412 C150 412 92 386 74 340 Z", fill=BELLY, sw=0, stroke="none")
    a.path("M60 300 C60 200 140 140 256 140 C372 140 430 220 424 310 C418 380 340 410 240 410 C140 410 60 376 60 300 Z", "none")
    # fin
    a.path("M200 330 C214 366 250 380 276 366 C264 342 236 326 200 330 Z", fill=BD)
    sea_face(a, 160, 270, gap=34, r=14, blush_dx=70)
    a.shine("M128 214 C150 188 186 172 224 168")
    return a


@word
def kurage():
    a = Art()
    P, PL = "#f9b6d2", "#fde0ec"
    # wavy tentacles
    for dx in (-84, -42, 0, 42, 84):
        x = 256 + dx
        d = f"M{x} 300 C{x-18} 340 {x+18} 372 {x} 410 C{x-14} 440 {x+10} 452 {x} 470"
        a.path(d, sw=26)
        a.path(d, stroke=PL, sw=9)
    # frilly oral arms
    a.path("M170 292 C190 332 222 332 232 296 C242 336 270 336 280 296 C290 332 322 332 342 292 Z", fill=PL, sw=9)
    # dome
    a.path("M80 292 C80 160 160 70 256 70 C352 70 432 160 432 292 C400 316 372 300 344 316 C316 332 292 304 256 316 C220 304 196 332 168 316 C140 300 112 316 80 292 Z", fill=P)
    a.path("M164 120 C188 90 224 78 256 78", stroke="#ffffff", sw=7, **{"stroke-opacity": "0.6"})
    for x, y in ((330, 150), (370, 220), (300, 110)):
        a.circle(x, y, 9, "#f58fb4", sw=0, stroke="none", **{"fill-opacity": "0.8"})
    sea_face(a, 256, 214, gap=56, r=16, blush_dx=100)
    return a


@word
def iruka():
    a = Art()
    B, BD, BELLY = "#7fa9d6", "#6a93c2", "#eef6ff"
    BODYD = ("M74 164 C130 236 230 206 312 174 C362 154 412 150 438 180 C454 186 488 200 494 220 "
             "C488 238 458 244 438 244 C412 322 322 352 240 330 C150 306 100 236 74 194 Z")
    # tail flukes (the tail is lifted, like a jump)
    a.path("M78 164 C50 154 26 124 34 92 C64 98 92 128 104 168 Z", fill=BD)
    a.path("M78 194 C48 208 26 238 36 270 C66 258 94 232 104 196 Z", fill=BD)
    a.path(BODYD, fill=B)
    # light belly
    a.path("M126 244 C170 290 262 314 340 296 C390 284 420 266 440 246 C414 322 322 352 240 330 C186 314 150 280 126 244 Z",
           fill=BELLY, sw=0, stroke="none")
    a.path(BODYD, "none")
    # dorsal fin and flipper
    a.path("M240 196 C250 150 290 126 330 128 C320 152 326 168 342 180 Z", fill=BD)
    a.path("M286 326 C274 360 294 388 334 392 C338 362 328 338 310 326 Z", fill=BD)
    # face
    a.ellipse(394, 198, 14, 17, EYE, sw=0, stroke="none")
    a.dot(398, 191, 5, "#ffffff")
    a.ellipse(404, 244, 15, 9, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.path("M430 228 C448 242 474 238 486 222", sw=7)
    a.shine("M196 250 C226 232 262 222 298 212")
    return a


@word
def sakana():
    a = Art()
    OR, ORD, BELLY = "#f7a23b", "#ee8727", "#ffe3a8"
    # tail
    a.path("M120 256 C80 214 50 190 36 150 C34 212 34 300 36 362 C50 322 80 298 120 256 Z", fill=ORD)
    # body (faces right)
    a.path("M96 256 C112 176 200 132 292 132 C376 132 440 190 456 256 C440 322 376 380 292 380 C200 380 112 336 96 256 Z", fill=OR)
    # belly
    a.path("M130 300 C190 352 330 372 440 296 C400 360 340 382 290 382 C220 382 160 350 130 300 Z", fill=BELLY, sw=0, stroke="none")
    a.path("M96 256 C112 176 200 132 292 132 C376 132 440 190 456 256 C440 322 376 380 292 380 C200 380 112 336 96 256 Z", "none")
    # fins
    a.path("M230 140 C238 96 280 70 330 84 C318 104 322 124 336 140 Z", fill=ORD)
    a.path("M250 300 C250 346 218 376 186 372 C198 344 208 322 220 300 Z", fill=ORD)
    # gill + scales
    a.path("M214 196 C196 228 196 284 214 316", sw=8)
    for x, y in ((266, 220), (310, 256), (266, 290), (346, 212)):
        a.path(f"M{x-14} {y} C{x-8} {y-12} {x+8} {y-12} {x+14} {y}", stroke=ORD, sw=7)
    # face
    a.ellipse(380, 232, 15, 18, EYE, sw=0, stroke="none")
    a.dot(384, 225, 5.5, "#ffffff")
    a.ellipse(386, 286, 15, 9, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.path("M426 262 C438 274 454 270 460 258", sw=7)
    a.shine("M150 214 C166 184 204 162 252 158")
    return a


@word
def hitode():
    a = Art()
    OR, ORD = "#f58f4a", "#e8793a"
    import math
    pts = []
    for k in range(10):
        ang = -math.pi / 2 + k * math.pi / 5
        r = 230 if k % 2 == 0 else 112
        pts.append((256 + r * math.cos(ang), 280 + r * math.sin(ang)))
    d = "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"
    a.path(d, fill=OR, sw=40)  # rounded corners via a thick outline
    a.path(d, fill=OR, sw=0, stroke="none")
    a.path(d, stroke=OR, sw=22)
    # bumps
    for k in range(5):
        ang = -math.pi / 2 + k * 2 * math.pi / 5
        for t in (0.42, 0.62, 0.8):
            a.circle(256 + 230 * t * math.cos(ang), 280 + 230 * t * math.sin(ang), 8, ORD, sw=0, stroke="none")
    sea_face(a, 256, 270, gap=40, r=14, blush_dx=76)
    a.shine("M214 150 C226 120 246 100 262 88")
    return a


@word
def kaeru():
    a = Art()
    G, GD, BELLY = "#7cc96a", "#5fb257", "#e6f6c8"
    # back legs
    a.path("M112 330 C60 330 48 410 110 430 L196 430 C196 380 170 330 112 330 Z", fill=G)
    a.path("M400 330 C452 330 464 410 402 430 L316 430 C316 380 342 330 400 330 Z", fill=G)
    for s in (-1, 1):
        for dx in (0, 22, 44):
            a.circle(256 + s * (190 - dx * 0.2) - s * 0, 440, 0.01, G, sw=0, stroke="none")
    # body
    a.path("M256 150 C372 150 420 240 410 330 C402 400 330 440 256 440 C182 440 110 400 102 330 C92 240 140 150 256 150 Z", fill=G)
    a.path("M170 340 C200 420 312 420 342 340 C330 380 290 396 256 396 C222 396 182 380 170 340 Z", fill=BELLY, sw=0, stroke="none")
    # front feet
    for s in (-1, 1):
        a.path(f"M{256+s*92} 418 C{256+s*130} 420 {256+s*140} 456 {256+s*108} 460 C{256+s*84} 462 {256+s*70} 442 {256+s*72} 418 Z", fill=G)
    # big eyes on top
    for s in (-1, 1):
        a.circle(256 + s * 86, 128, 62, G)
    for s in (-1, 1):
        a.circle(256 + s * 86, 128, 40, "#ffffff", sw=8)
        a.ellipse(256 + s * 86 + s * 4, 132, 18, 22, EYE, sw=0, stroke="none")
        a.dot(256 + s * 86 + s * 4 + 6, 122, 7, "#ffffff")
    for s in (-1, 1):
        a.ellipse(256 + s * 120, 280, 18, 11, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.75"})
    a.path("M196 262 C226 306 286 306 316 262", sw=9)
    a.shine("M130 260 C128 226 146 196 176 182")
    return a


@word
def medaka():
    a = Art()
    BODYC, BELLY, FIN = "#f3d98a", "#fff6d6", "#f9e8ae"
    # tail (small)
    a.path("M120 256 C96 226 74 212 56 196 C58 236 58 276 56 316 C74 300 96 286 120 256 Z", fill=FIN)
    # slim body
    a.path("M92 256 C112 190 200 160 290 160 C372 160 436 208 450 256 C436 304 372 352 290 352 C200 352 112 322 92 256 Z", fill=BODYC)
    a.path("M130 296 C190 332 330 346 440 280 C402 340 340 354 290 354 C220 354 160 332 130 296 Z", fill=BELLY, sw=0, stroke="none")
    a.path("M92 256 C112 190 200 160 290 160 C372 160 436 208 450 256 C436 304 372 352 290 352 C200 352 112 322 92 256 Z", "none")
    # little fins
    a.path("M260 166 C268 138 296 124 322 130 C314 144 318 158 326 168 Z", fill=FIN)
    a.path("M252 316 C250 346 226 366 204 360 C214 342 222 326 232 314 Z", fill=FIN)
    # large eye (medaka = big eyes)
    a.circle(384, 236, 28, "#ffffff", sw=8)
    a.ellipse(390, 238, 15, 18, EYE, sw=0, stroke="none")
    a.dot(396, 230, 6, "#ffffff")
    a.ellipse(380, 296, 15, 9, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.path("M414 274 C424 286 438 284 442 272", sw=7)
    a.shine("M150 214 C170 192 204 180 244 178")
    return a


@word
def zarigani():
    a = Art()
    R, RD = "#e8493f", "#cf3a35"
    # tail fan at the bottom
    a.path("M214 380 L190 460 C216 476 296 476 322 460 L298 380 Z", fill=R)
    a.path("M214 380 C200 430 196 450 190 460 M256 384 L256 470 M298 380 C312 430 316 450 322 460", sw=7)
    # segmented abdomen
    a.path("M196 270 C190 330 200 360 214 384 L298 384 C312 360 322 330 316 270 Z", fill=R)
    for y in (312, 346):
        a.path(f"M200 {y} C240 {y+14} 272 {y+14} 312 {y}", sw=7)
    # legs
    for s in (-1, 1):
        for y in (286, 318, 350):
            a.tube(f"M{256+s*56} {y} L{256+s*104} {y+18}", R, 22, 8)
    # big claws
    for s in (-1, 1):
        a.path(f"M{256+s*56} 200 C{256+s*110} 190 {256+s*130} 160 {256+s*132} 126", sw=32)
        a.path(f"M{256+s*56} 200 C{256+s*110} 190 {256+s*130} 160 {256+s*132} 126", stroke=R, sw=14)
        cx = 256 + s * 132
        d = (f"M{cx} 130 C{cx-s*50} 130 {cx-s*60} 70 {cx-s*28} 36 C{cx-s*14} 26 {cx} 50 {cx} 70 "
             f"C{cx} 48 {cx+s*18} 26 {cx+s*36} 42 C{cx+s*64} 74 {cx+s*46} 130 {cx} 130 Z")
        a.path(d, fill=R)
    # head / carapace
    a.path("M256 124 C328 124 352 176 346 236 C342 276 304 296 256 296 C208 296 170 276 166 236 C160 176 184 124 256 124 Z", fill=R)
    # antennae
    for s in (-1, 1):
        a.path(f"M{256+s*22} 128 C{256+s*30} 100 {256+s*50} 80 {256+s*74} 70", sw=7)
    sea_face(a, 256, 206, gap=36, r=13, blush_dx=66)
    a.shine("M196 168 C200 150 214 138 232 134")
    return a


@word
def otamajakushi():
    a = Art()
    BK, BKL = "#3b3a45", "#55546a"
    # wavy tail
    a.path("M300 300 C360 260 400 340 450 300 C470 284 480 296 482 316 C470 350 420 396 366 366 C340 352 320 350 296 346 Z", fill=BK)
    # round head/body
    a.path("M256 100 C350 100 398 176 392 252 C388 320 330 356 256 356 C182 356 124 320 120 252 C114 176 162 100 256 100 Z", fill=BK)
    # face: white eyes (so they show on black), smile and cheeks
    for s in (-1, 1):
        a.ellipse(256 + s * 62, 220, 24, 28, "#ffffff", sw=0, stroke="none")
        a.ellipse(256 + s * 62 + s * 2, 224, 13, 16, EYE, sw=0, stroke="none")
        a.dot(256 + s * 62 + 5, 214, 6, "#ffffff")
        a.ellipse(256 + s * 106, 282, 17, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.8"})
    a.path("M226 276 C240 296 272 296 286 276", stroke="#ffffff", sw=8)
    a.shine("M168 170 C184 138 216 118 252 114")
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


@word
def kumo():
    a = Art()
    cloud_shape(a, CLOUD_PARTS, CLOUD_BASE, "#ffffff", shade="#cfe6f7")
    sky_face(a, 262, 268, gap=50, r=15, blush_dx=92)
    a.shine("M170 236 C176 214 192 200 212 196")
    return a


@word
def niji():
    a = Art()
    cx, cy = 256, 400
    bands = [(190, "#ee5b52"), (158, "#f7a94b"), (126, "#f6d36b"), (94, "#7cc36a"), (62, "#4fa8e0")]
    mid = 126
    a.path(f"M{cx-mid} {cy} A{mid} {mid} 0 0 1 {cx+mid} {cy}", sw=(190 - 62) + 32 + 11, stroke_linecap="butt")
    for r, col in bands:
        a.path(f"M{cx-r} {cy} A{r} {r} 0 0 1 {cx+r} {cy}", stroke=col, sw=32, stroke_linecap="butt")
    for s in (-1, 1):
        x = cx + s * 126
        cloud_shape(a, [(x - 50, 392, 40), (x, 366, 54), (x + 52, 392, 40)],
                    (x - 90, x + 92, 392, 440), "#ffffff", shade="#cfe6f7")
    return a


@word
def ame():
    a = Art()
    parts = [(160, 190, 58), (240, 140, 78), (330, 168, 66), (388, 210, 46)]
    cloud_shape(a, parts, (140, 410, 190, 250), "#c9d9ea", shade="#a9bed4")
    sky_face(a, 262, 176, gap=46, r=14, blush_dx=86)
    def drop(x, y):
        return (f"M{x} {y} C{x-8} {y+22} {x-24} {y+40} {x-24} {y+60} C{x-24} {y+84} {x-8} {y+98} {x} {y+98} "
                f"C{x+8} {y+98} {x+24} {y+84} {x+24} {y+60} C{x+24} {y+40} {x+8} {y+22} {x} {y} Z")
    for x, y in ((190, 290), (270, 320), (350, 290)):
        a.path(drop(x, y), fill="#5ab4ea", sw=9)
        a.path(f"M{x-10} {y+52} C{x-14} {y+64} {x-12} {y+72} {x-6} {y+78}", stroke="#ffffff", sw=6,
               **{"stroke-opacity": "0.7"})
    return a


@word
def yuki():
    a = Art()
    ICE, ICE_L = "#a9d8f5", "#e6f4fd"
    for ang in (90, 150, 210, 270, 330, 30):
        t = math.radians(ang)
        dx, dy = math.cos(t), math.sin(t)
        x1, y1 = 256 + dx * 215, 256 + dy * 215
        a.tube(f"M256 256 L{x1:.1f} {y1:.1f}", ICE, 36, 16)
        # little branches
        for k in (0.62, 0.84):
            bx, by = 256 + dx * 215 * k, 256 + dy * 215 * k
            for sgn in (-1, 1):
                t2 = t + sgn * math.radians(50)
                ex, ey = bx + math.cos(t2) * 46, by + math.sin(t2) * 46
                a.tube(f"M{bx:.1f} {by:.1f} L{ex:.1f} {ey:.1f}", ICE, 28, 12)
    a.circle(256, 256, 86, "#ffffff")
    a.circle(256, 256, 70, ICE_L, sw=0, stroke="none")
    sky_face(a, 256, 246, gap=32, r=11, blush_dx=58)
    a.shine("M206 220 C212 200 226 188 244 184")
    return a


@word
def kaminari():
    a = Art()
    parts = [(150, 190, 56), (232, 140, 76), (326, 164, 66), (388, 206, 46)]
    cloud_shape(a, parts, (130, 410, 186, 244), "#8c9db3", shade="#6f8099")
    sky_face(a, 258, 172, gap=46, r=14, blush_dx=86)
    bolt = "M290 232 L214 330 L262 330 L226 454 L330 308 L280 308 L324 232 Z"
    a.path(bolt, fill="#ffd84d", sw=11)
    a.path("M286 246 L238 316", stroke="#fff3b0", sw=7)
    return a


@word
def kaze():
    a = Art()
    # blowing face
    a.circle(190, 250, 120, "#e3f2fc")
    a.circle(190, 250, 108, "#e3f2fc", sw=0, stroke="none")
    for s in (-1, 1):
        x = 190 + s * 46
        a.path(f"M{x-16} 232 C{x-8} 220 {x+8} 220 {x+16} 232", sw=8)
        a.ellipse(190 + s * 86, 282, 18, 11, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.ellipse(190, 290, 17, 21, "#d9645e", sw=8, stroke=O)
    a.shine("M118 214 C128 186 150 168 176 162")
    # swirling wind lines to the right
    W1, W2 = "#8ec9f0", "#bfe3fa"
    a.tube("M300 214 C356 204 400 204 428 190 C458 172 440 140 414 150 C396 158 404 178 420 176", W1, 30, 14)
    a.tube("M312 262 C380 262 430 270 454 288 C478 306 456 338 428 326 C408 316 416 296 432 300", W2, 30, 14)
    a.tube("M296 312 C340 322 372 340 380 366 C386 392 358 404 344 388", W1, 28, 12)
    return a


@word
def taiyou():
    a = Art()
    cx = cy = 256
    for i in range(12):
        t = math.radians(i * 30)
        ux, uy = math.cos(t), math.sin(t)
        px, py = -uy, ux
        b = 128
        tip = 218
        pts = (f"M{cx+ux*b+px*30:.1f} {cy+uy*b+py*30:.1f} L{cx+ux*tip:.1f} {cy+uy*tip:.1f} "
               f"L{cx+ux*b-px*30:.1f} {cy+uy*b-py*30:.1f} Z")
        a.path(pts, fill="#ffb347", sw=9)
    a.circle(cx, cy, 124, "#ffd84d")
    a.circle(cx, cy, 112, "#ffd84d", sw=0, stroke="none")
    sky_face(a, cx, cy - 8, gap=48, r=15, blush_dx=88)
    a.shine("M168 200 C180 172 206 154 238 148")
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
    a.path(star_path(256, 268, 220, 124), fill="#ffd84d", sw=14)
    sky_face(a, 256, 270, gap=44, r=14, blush_dx=82)
    a.shine("M206 160 C214 138 232 120 252 112")
    return a


@word
def tsuki():
    a = Art()
    R1, c1 = 190, (240, 256)
    R2, c2 = 150, (330, 226)
    dx, dy = c2[0] - c1[0], c2[1] - c1[1]
    d = math.hypot(dx, dy)
    aa = (R1 * R1 - R2 * R2 + d * d) / (2 * d)
    h = math.sqrt(R1 * R1 - aa * aa)
    mx, my = c1[0] + aa * dx / d, c1[1] + aa * dy / d
    p1 = (mx + h * dy / d, my - h * dx / d)
    p2 = (mx - h * dy / d, my + h * dx / d)
    # outer arc the long way round the left, then back along the inner circle
    top, bot = (p1, p2) if p1[1] < p2[1] else (p2, p1)
    path = (f"M{top[0]:.1f} {top[1]:.1f} A{R1} {R1} 0 1 0 {bot[0]:.1f} {bot[1]:.1f} "
            f"A{R2} {R2} 0 0 1 {top[0]:.1f} {top[1]:.1f} Z")
    a.circle(c1[0], c1[1], R1 + 7, "none", sw=0, stroke="none")  # keeps the whole outer arc inside the fit
    a.path(path, fill="#ffe9a0", sw=14)
    a.circle(130, 330, 20, "#f4d27a", sw=0, stroke="none")
    a.circle(188, 140, 14, "#f4d27a", sw=0, stroke="none")
    sky_face(a, 150, 250, gap=30, r=12, blush_dx=54, sleepy=True)
    a.path(star_path(412, 120, 30, 15), fill="#ffd84d", sw=8)
    a.path(star_path(448, 330, 22, 11), fill="#ffd84d", sw=8)
    a.shine("M92 220 C94 180 110 150 138 130")
    return a


@word
def uchuujin():
    a = Art()
    G, GD = "#93d86f", "#7cc65a"
    # antennae
    for s in (-1, 1):
        a.path(f"M{256+s*60} 130 C{256+s*84} 90 {256+s*100} 70 {256+s*112} 52", sw=9)
        a.circle(256 + s * 114, 46, 20, "#ffd84d", sw=9)
    # little body
    a.path("M196 372 C196 350 220 342 256 342 C292 342 316 350 316 372 L324 430 C324 446 314 452 300 452 "
           "L212 452 C198 452 188 446 188 430 Z", fill="#a9b6f2")
    a.path("M216 372 L204 430 M296 372 L308 430", stroke="#8695dc", sw=7)
    for s in (-1, 1):
        a.circle(256 + s * 70, 400, 22, G, sw=9)
    # big head
    a.path("M256 100 C370 100 424 170 420 236 C416 306 340 354 256 354 C172 354 96 306 92 236 "
           "C88 170 142 100 256 100 Z", fill=G)
    # big glossy eyes
    for s in (-1, 1):
        a.path(f"M{256+s*30} 200 C{256+s*58} 184 {256+s*118} 196 {256+s*128} 250 "
               f"C{256+s*130} 284 {256+s*84} 292 {256+s*56} 270 C{256+s*34} 252 {256+s*26} 222 {256+s*30} 200 Z",
               fill=EYE, sw=0, stroke="none")
        a.ellipse(256 + s * 92, 226, 14, 18, "#ffffff", sw=0, stroke="none")
        a.dot(256 + s * 66, 262, 7, "#ffffff")
        a.ellipse(256 + s * 126, 296, 17, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.75"})
    a.path("M232 302 C244 318 268 318 280 302", sw=8)
    a.shine("M138 190 C150 160 180 138 218 130")
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
    # bottom: red and blue cubes; then a yellow cube; a green roof on top
    a.rect(84, 330, 160, 140, RED, rx=16)
    a.rect(268, 330, 160, 140, BLUE, rx=16)
    a.rect(176, 190, 160, 140, YEL, rx=16)
    a.path("M170 196 L256 84 L342 196 Z", fill="#7cc36a")
    # marks on the blocks
    a.circle(164, 400, 34, WHITE, sw=7)
    a.rect(318, 372, 60, 56, WHITE, rx=10, sw=7)
    a.path("M214 316 C214 276 298 276 298 316", stroke=O, sw=8, fill="#ffffff")
    a.shine("M104 360 C104 348 112 344 124 344", sw=8)
    a.shine("M288 350 C288 342 294 338 304 338", sw=8)
    return a


@word
def koma():
    a = Art()
    # handle, body, stripe, spike
    a.rect(232, 92, 48, 96, WOOD, rx=14)
    a.path("M242 120 L270 120", stroke=WOOD_D, sw=7)
    a.path("M240 392 L256 466 L272 392 Z", fill="#9aa5b1", sw=10)
    a.path("M120 262 C120 206 192 184 256 184 C320 184 392 206 392 262 L392 300 "
           "C392 356 328 396 256 396 C184 396 120 356 120 300 Z", fill=RED)
    a.path("M122 278 C170 316 342 316 390 278 L392 316 C342 354 170 354 120 316 Z", fill=YEL, sw=8)
    a.path("M120 262 C120 206 192 184 256 184 C320 184 392 206 392 262 C392 296 328 316 256 316 "
           "C184 316 120 296 120 262 Z", fill="#ee6a62", sw=0, stroke="none")
    a.path("M120 262 C120 206 192 184 256 184 C320 184 392 206 392 262 L392 300 "
           "C392 356 328 396 256 396 C184 396 120 356 120 300 Z")
    a.shine("M162 238 C176 218 206 206 240 202")
    return a


@word
def kendama():
    a = Art()
    # string from the handle to the ball
    a.path("M320 236 C430 270 410 380 292 408", stroke="#8a6a50", sw=7)
    # handle (ken): a stick with a spike on the top and a cup at each side
    a.tube("M256 480 L256 330", WOOD, 64, 40)
    for s in (-1, 1):
        x = 256 + s * 78
        a.path(f"M{x-46} 318 C{x-46} 372 {x+46} 372 {x+46} 318 Z", fill=WOOD_L)
        a.ellipse(x, 318, 46, 15, "#a9672f")
    a.tube("M200 336 L312 336", WOOD, 44, 24)
    a.path("M246 330 L256 236 L266 330 Z", fill=WOOD, sw=10)
    # ball skewered on the spike, with a hole at the bottom
    a.circle(256, 170, 84, RED)
    a.ellipse(256, 244, 20, 11, "#a9362f", sw=7)
    a.shine("M204 130 C212 106 236 90 260 88")
    return a


@word
def fuusen():
    a = Art()
    def balloon(cx, cy, col, dark, s=1.0, tilt=0):
        w, h = 120 * s, 150 * s
        d = (f"M{cx} {cy-h} C{cx+w*0.9} {cy-h} {cx+w} {cy-h*0.2} {cx+w*0.62} {cy+h*0.42} "
             f"C{cx+w*0.4} {cy+h*0.76} {cx+w*0.12} {cy+h*0.9} {cx+10*s} {cy+h*0.98} "
             f"L{cx+22*s} {cy+h*1.1} L{cx-22*s} {cy+h*1.1} L{cx-10*s} {cy+h*0.98} "
             f"C{cx-w*0.12} {cy+h*0.9} {cx-w*0.4} {cy+h*0.76} {cx-w*0.62} {cy+h*0.42} "
             f"C{cx-w} {cy-h*0.2} {cx-w*0.9} {cy-h} {cx} {cy-h} Z")
        return d
    # blue balloon behind
    a.path("M350 470 C320 430 372 410 340 372", sw=7)
    a.path(balloon(344, 188, BLUE, BLUE_D, 0.74), fill=BLUE)
    a.shine("M296 124 C306 106 324 96 344 94", sw=7)
    # red balloon in front
    a.path("M196 486 C160 452 224 436 190 396", sw=7)
    a.path(balloon(190, 214, RED, RED_D, 1.0), fill=RED)
    a.shine("M120 150 C132 118 160 100 194 96")
    return a


@word
def ningyou():
    a = Art()
    HAIR, SKIN = "#3b3a45", "#ffe3c9"
    # back hair (bob)
    a.path("M148 190 C140 96 196 66 256 66 C316 66 372 96 364 190 C362 236 350 262 342 270 "
           "L170 270 C162 262 150 236 148 190 Z", fill=HAIR)
    # kimono
    a.path("M172 282 C172 270 204 264 256 264 C308 264 340 270 340 282 L378 448 C380 462 368 470 354 470 "
           "L158 470 C144 470 132 462 134 448 Z", fill=RED)
    for x, y in ((196, 410), (256, 440), (316, 410), (176, 340), (336, 340)):
        a.circle(x, y, 11, "#ffd1d6", sw=0, stroke="none")
    # collar and obi
    a.path("M222 266 L256 332 L290 266", stroke=WHITE, sw=20)
    a.path("M222 266 L256 332 L290 266", sw=7)
    a.rect(152, 352, 208, 44, YEL, rx=8)
    a.path("M256 352 L256 396", sw=6)
    # face
    a.ellipse(256, 188, 98, 92, SKIN)
    a.path("M158 188 C152 118 204 88 256 88 C308 88 360 118 354 188 C324 160 292 146 256 150 "
           "C220 146 188 160 158 188 Z", fill=HAIR)
    for s in (-1, 1):
        a.ellipse(256 + s * 42, 204, 11, 14, EYE, sw=0, stroke="none")
        a.dot(256 + s * 42 + 4, 198, 4, WHITE)
        a.ellipse(256 + s * 68, 232, 17, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.75"})
    a.path("M244 238 C250 246 262 246 268 238", sw=7)
    # a hair clip
    a.circle(330, 112, 15, "#ffd84d", sw=7)
    a.shine("M196 112 C214 100 236 96 258 96", sw=7)
    return a


@word
def taiko():
    a = Art()
    # legs
    for x in (116, 340):
        a.rect(x, 410, 56, 64, WOOD, rx=12)
    # body (barrel)
    a.path("M108 190 C84 250 84 330 112 410 C150 432 362 432 400 410 C428 330 428 250 404 190 Z", fill=RED)
    for y in (232, 352):
        a.path(f"M96 {y} C150 {y+22} 362 {y+22} 416 {y}", stroke=RED_D, sw=7)
    for i in range(9):
        t = i / 8
        x = 128 + 256 * t
        a.circle(x, 222 + 16 * (1 - (2 * t - 1) ** 2) + 6, 8, YEL, sw=6)
        a.circle(x, 372 + 16 * (1 - (2 * t - 1) ** 2) + 6, 8, YEL, sw=6)
    a.path("M108 190 C84 250 84 330 112 410 C150 432 362 432 400 410 C428 330 428 250 404 190")
    # drumhead
    a.ellipse(256, 190, 148, 52, CREAM)
    a.ellipse(256, 190, 100, 32, "#f3dcbb", sw=6)
    a.circle(256, 190, 12, RED, sw=0, stroke="none")
    # sticks
    a.tube("M150 70 L232 172", WOOD, 40, 22)
    a.tube("M362 70 L280 172", WOOD, 40, 22)
    a.circle(150, 70, 14, WOOD_L, sw=8)
    a.circle(362, 70, 14, WOOD_L, sw=8)
    return a


@word
def fue():
    a = Art()
    def P(t):
        return 100 + 312 * t, 424 - 312 * t
    x0, y0 = P(0.0)
    x1, y1 = P(1.0)
    # body
    a.tube(f"M{x0:.0f} {y0:.0f} L{x1:.0f} {y1:.0f}", "#fff4e2", 76, 54)
    # mouthpiece and bell end
    ax, ay = P(0.80)
    a.tube(f"M{ax:.0f} {ay:.0f} L{x1:.0f} {y1:.0f}", BLUE, 76, 54)
    bx, by = P(0.2)
    a.tube(f"M{x0:.0f} {y0:.0f} L{bx:.0f} {by:.0f}", BLUE, 76, 54)
    # holes
    for t in (0.32, 0.41, 0.50, 0.60, 0.69):
        x, y = P(t)
        a.circle(x, y, 11, EYE, sw=0, stroke="none")
    # ring bands
    for t in (0.20, 0.80):
        x, y = P(t)
        a.line(x - 22, y - 22, x + 22, y + 22, sw=9)
    a.shine("M150 330 L300 180", sw=7)
    # a little note
    a.circle(120, 200, 20, "#ee6a62", sw=8)
    a.path("M138 196 L138 96 C158 112 178 112 188 140", sw=10)
    return a


@word
def suzu():
    a = Art()
    GOLD, GOLD_D = "#f7c948", "#e5a92d"
    # ribbon and ring
    a.path("M256 140 C204 70 150 90 170 140 C184 170 236 150 256 140 Z", fill=RED)
    a.path("M256 140 C308 70 362 90 342 140 C328 170 276 150 256 140 Z", fill=RED)
    a.circle(256, 144, 20, RED_D, sw=8)
    a.circle(256, 196, 30, "none", sw=9)
    # bell body
    a.circle(256, 330, 134, GOLD)
    a.circle(256, 330, 122, GOLD, sw=0, stroke="none")
    a.path("M126 360 C170 392 342 392 386 360", stroke=GOLD_D, sw=8)
    a.ellipse(256, 392, 26, 14, EYE, sw=8)
    a.line(256, 406, 256, 462, sw=9)
    a.shine("M164 290 C174 262 198 242 226 236")
    return a


@word
def mokkin():
    a = Art()
    cols = [RED, ORANGE, YEL, GREEN, BLUE, PURPLE]
    # rails
    a.tube("M64 252 L448 252", WOOD, 40, 20)
    a.tube("M64 380 L448 380", WOOD, 40, 20)
    for i, c in enumerate(cols):
        x = 84 + i * 62
        top = 150 + i * 16
        bot = 440 - i * 16
        a.path(f"M{x} {top+14} C{x} {top} {x+52} {top} {x+52} {top+14} L{x+52} {bot-14} "
               f"C{x+52} {bot} {x} {bot} {x} {bot-14} Z", fill=c)
        a.circle(x + 26, 252, 7, WHITE, sw=0, stroke="none")
        a.circle(x + 26, 380, 7, WHITE, sw=0, stroke="none")
    # mallets
    a.tube("M424 56 L330 182", WOOD, 30, 14)
    a.tube("M474 112 L344 206", WOOD, 30, 14)
    a.circle(424, 56, 28, "#ee6a62", sw=9)
    a.circle(474, 112, 28, "#4fa8e0", sw=9)
    return a


@word
def nawatobi():
    a = Art()
    # rope
    d = "M160 150 C60 470 452 470 352 150"
    a.path(d, sw=30)
    a.path(d, stroke=RED, sw=14)
    a.path(d, stroke=WHITE, sw=5, stroke_dasharray="18 18", **{"stroke-opacity": "0.9"})
    # handles
    for x in (150, 362):
        a.rect(x - 22, 56, 44, 130, BLUE, rx=20)
        a.rect(x - 22, 56, 44, 34, YEL, rx=16)
        a.path(f"M{x-22} 122 L{x+22} 122", stroke=BLUE_D, sw=6)
    a.shine("M138 110 L138 168", sw=7)
    a.shine("M350 110 L350 168", sw=7)
    return a


@word
def tetsubou():
    a = Art()
    # posts
    for x in (140, 372):
        a.tube(f"M{x} 130 L{x} 440", BLUE, 52, 30)
        a.ellipse(x, 448, 52, 18, "#8a8f98")
    # bar with end caps
    a.tube("M72 130 L440 130", STEEL, 50, 28)
    for x in (72, 440):
        a.circle(x, 130, 20, STEEL_D, sw=8)
    a.path("M96 124 L416 124", stroke=WHITE, sw=7, **{"stroke-opacity": "0.8"})
    # braces
    a.path("M140 360 L100 440 M372 360 L412 440", sw=10)
    return a


@word
def tobibako():
    a = Art()
    # cushion on the top
    a.path("M84 150 C84 100 128 82 256 82 C384 82 428 100 428 150 L428 190 L84 190 Z", fill="#b9754a")
    a.path("M100 140 C150 120 362 120 412 140", stroke="#d99c70", sw=7)
    for x in (140, 256, 372):
        a.circle(x, 164, 6, "#8a5530", sw=0, stroke="none")
    # tiers
    for i in range(4):
        y = 190 + i * 70
        fill = WOOD if i % 2 == 0 else WOOD_L
        a.rect(76 - i * 4, y, 360 + i * 8, 70, fill, rx=10)
        a.rect(214, y + 18, 84, 34, "#c97f3e", rx=16, sw=8)
    return a


@word
def burango():
    full, frame, seat = swing_parts()
    return full


def swing_parts():
    """The whole swing, and the frame and the seat on their own (same fit, so they line up)."""
    def frame_part(a):
        a.tube("M70 100 L442 100", RED, 50, 30)
        for ax, bx0, bx1 in ((132, 60, 204), (380, 308, 452)):
            a.tube(f"M{ax} 100 L{bx0} 450", RED, 44, 24)
            a.tube(f"M{ax} 100 L{bx1} 450", RED, 44, 24)
            a.path(f"M{bx0+6} 450 L{bx0-14} 450 M{bx1+14} 450 L{bx1-6} 450", sw=10)
        a.tube("M70 100 L442 100", RED, 50, 30)

    def seat_part(a):
        for x, bx in ((218, 214), (294, 298)):
            a.path(f"M{x} 100 L{bx} 354", stroke="#8a6a50", sw=11)
        a.rect(196, 350, 120, 36, YEL, rx=14)
        a.circle(218, 104, 11, STEEL, sw=7)
        a.circle(294, 104, 11, STEEL, sw=7)

    full = Art(); frame_part(full); seat_part(full)
    frame = Art(); frame_part(frame)
    seat = Art(); seat_part(seat)
    return full, frame, seat



def slide_art(chute_only=False):
    a = Art()
    if not chute_only:
        # posts and ladder
        for x in (92, 188):
            a.tube(f"M{x} 150 L{x} 452", YEL, 40, 20)
        for y in (220, 290, 360, 430):
            a.line(92, y, 188, y, sw=12)
        # platform and rail
        a.rect(70, 130, 160, 32, RED, rx=10)
        a.path("M74 130 L74 70 M74 74 L196 74 M196 74 L196 130", sw=11)
    return a


# the slide chute: cubic from the platform to the ground
SLIDE_CURVE = ((214, 170), (314, 200), (386, 330), (446, 404))


@word
def suberidai():
    a = slide_art()
    (x0, y0), (x1, y1), (x2, y2), (x3, y3) = SLIDE_CURVE
    d = f"M{x0} {y0} C{x1} {y1} {x2} {y2} {x3} {y3} L474 {y3}"
    a.path(d, sw=60)
    a.path(d, stroke=BLUE, sw=36)
    a.path(d, stroke=SKY, sw=10, **{"stroke-opacity": "0.9"})
    # redraw the ladder over the chute start
    a.rect(70, 130, 160, 32, RED, rx=10)
    return a


@word
def sunaba():
    a = Art()
    # outer frame (back), sand, front board
    a.path("M104 196 L408 196 L452 332 L60 332 Z", fill=WOOD_D)
    a.path("M126 216 L386 216 L424 318 L88 318 Z", fill=SAND)
    a.path("M164 318 C178 258 246 238 292 318 Z", fill=SAND_D, sw=0, stroke="none")
    # bucket (on the sand)
    a.path("M332 190 C346 150 396 150 410 190", sw=8)
    a.path("M326 206 L416 206 L402 308 L340 308 Z", fill=RED)
    a.ellipse(371, 206, 45, 12, RED_D)
    a.path("M336 250 L408 250", stroke=YEL, sw=14)
    # shovel
    a.tube("M214 318 L170 134", WOOD, 30, 14)
    a.circle(166, 118, 15, WOOD, sw=8)
    a.path("M196 286 L246 296 L252 346 L206 340 Z", fill=YEL)
    # front board
    a.path("M60 332 L452 332 L452 420 C452 434 442 442 428 442 L84 442 C70 442 60 434 60 420 Z", fill=WOOD)
    for x in (150, 256, 362):
        a.path(f"M{x} 350 L{x} 424", stroke=WOOD_D, sw=7)
    return a


# ------------------------------------------------------- scenery (D174) --
LEAF1, LEAF2 = "#6fbd5c", "#4f9e48"
BARK, BARK_D = "#b47a4a", "#8f5c34"
STONE, STONE_D, STONE_L = "#c9c4bd", "#a8a29b", "#e4e0da"


@word
def yama():
    a = Art()
    a.path("M250 440 C300 340 336 262 366 226 C388 200 406 200 428 228 C462 272 500 350 526 440 Z", fill="#b4d0ee")
    a.path("M366 226 C388 200 406 200 428 228 C440 244 452 264 464 286 C440 280 430 296 410 284 C396 300 380 284 366 226 Z",
           fill=WHITE, sw=0, stroke="none")
    a.path("M250 440 C300 340 336 262 366 226 C388 200 406 200 428 228 C462 272 500 350 526 440 Z", "none")
    main = "M14 440 C76 346 146 222 210 126 C234 90 266 90 288 126 C346 216 420 346 480 440 Z"
    a.path(main, fill="#7aa5dc")
    a.path("M258 94 C270 98 280 108 288 126 C346 216 420 346 480 440 L338 440 C330 340 300 196 258 94 Z",
           fill="#6590c6", sw=0, stroke="none")
    a.path("M160 210 C176 180 196 148 210 126 C234 90 266 90 288 126 C304 150 318 178 330 206 "
           "C316 224 302 204 288 224 C274 198 258 224 244 206 C230 226 214 206 200 226 C184 206 170 226 160 210 Z",
           fill=WHITE)
    a.path(main, "none")
    # green foothills
    a.path("M14 440 C60 400 120 396 168 424 C190 436 214 440 240 440 Z", fill="#8fd08a")
    a.path("M300 440 C340 410 408 396 462 424 C474 432 480 438 480 440 Z", fill="#8fd08a")
    a.shine("M122 330 C140 292 156 262 172 240")
    return a


@word
def taki():
    a = Art()
    ROCK, ROCK_D = "#b69a7e", "#8f7660"
    # left and right cliffs
    a.path("M40 120 L186 120 L186 396 L40 396 Z", fill=ROCK)
    a.path("M326 120 L472 120 L472 396 L326 396 Z", fill=ROCK)
    # water falling
    a.path("M186 120 L326 120 L326 410 L186 410 Z", fill="#9fdcf7", sw=0, stroke="none")
    for x in (222, 256, 290):
        a.path(f"M{x} 150 L{x} 380", stroke=WHITE, sw=9, **{"stroke-opacity": "0.85"})
    a.path("M186 120 L186 396 M326 120 L326 396", sw=11)
    # tops: grass and a bush
    a.path("M40 120 C40 92 60 84 90 84 L186 84 L186 120 Z", fill=LEAF1)
    a.path("M326 84 L420 84 C452 84 472 92 472 120 L326 120 Z", fill=LEAF1)
    a.circle(100, 78, 34, LEAF2)
    a.circle(430, 78, 34, LEAF2)
    a.path("M186 112 C220 130 292 130 326 112", sw=9)
    # pool
    a.ellipse(256, 410, 190, 50, "#6cc0ec")
    a.path("M96 410 C150 424 210 428 256 426", stroke=WHITE, sw=8, **{"stroke-opacity": "0.8"})
    for x, y, r in ((226, 398, 24), (268, 392, 30), (306, 404, 20)):
        a.circle(x, y, r, WHITE, sw=0, stroke="none", **{"fill-opacity": "0.9"})
    a.shine("M70 160 L70 330")
    return a


@word
def ishi():
    a = Art()
    big = "M86 400 C70 330 96 250 160 214 C210 186 290 186 336 222 C392 266 408 340 392 400 C380 436 340 446 260 446 L190 446 C130 446 94 436 86 400 Z"
    a.path(big, fill=STONE)
    a.path("M336 222 C392 266 408 340 392 400 C380 436 340 446 260 446 L240 446 C330 430 350 330 316 206 Z",
           fill=STONE_D, sw=0, stroke="none")
    a.path(big)
    a.path("M170 270 C190 244 226 232 262 236", stroke=WHITE, sw=10, **{"stroke-opacity": "0.7"})
    a.path("M220 330 L248 350 L242 384", stroke=STONE_D, sw=8)
    small = "M376 446 C366 410 384 378 422 372 C456 368 484 390 482 420 C480 440 468 446 452 446 Z"
    a.path(small, fill=STONE_L)
    a.path("M404 392 C416 386 432 386 442 392", stroke=WHITE, sw=7, **{"stroke-opacity": "0.8"})
    a.path("M30 448 C60 420 70 436 90 408 M60 448 C70 424 90 428 100 410", stroke=LEAF2, sw=9)
    a.path("M420 448 L492 448", stroke=LEAF2, sw=9)
    return a


@word
def ike():
    a = Art()
    a.ellipse(256, 340, 232, 112, "#c9a06d")
    a.ellipse(256, 334, 210, 96, "#6cc0ec")
    a.path("M96 322 C130 292 190 280 240 284", stroke=WHITE, sw=9, **{"stroke-opacity": "0.75"})
    # rim stones
    for x, y, rx, ry in ((60, 336, 36, 24), (118, 436, 36, 22), (400, 438, 38, 22), (458, 336, 36, 24), (256, 226, 36, 20)):
        a.ellipse(x, y, rx, ry, STONE)
    # lily pads
    for cx, cy, rot in ((190, 346, 0), (320, 380, 1)):
        a.path(f"M{cx} {cy} L{cx+60} {cy-18} C{cx+66} {cy+24} {cx+30} {cy+52} {cx} {cy+46} C{cx-30} {cy+52} {cx-66} {cy+24} {cx-60} {cy-18} Z"
               if False else f"M{cx} {cy} L{cx+54} {cy-16} C{cx+58} {cy+26} {cx+26} {cy+44} {cx} {cy+40} C{cx-28} {cy+44} {cx-58} {cy+26} {cx-54} {cy-16} Z",
               fill=LEAF1)
    # lotus flower
    for d in ("M326 330 C300 312 296 280 322 264 C340 280 342 310 326 330 Z",
              "M326 330 C352 312 356 280 330 264 C312 280 310 310 326 330 Z",
              "M326 336 C296 336 276 312 284 292 C312 296 330 316 326 336 Z",
              "M326 336 C356 336 376 312 368 292 C340 296 322 316 326 336 Z"):
        a.path(d, fill="#f9b8d2", sw=9)
    a.circle(326, 328, 10, YEL2, sw=0, stroke="none")
    # reeds
    for x, top, lean in ((52, 140, -10), (84, 112, 6), (116, 150, 14)):
        a.path(f"M{x} 330 C{x} 260 {x+lean} 200 {x+lean} {top+30}", stroke=LEAF2, sw=10)
        a.path(f"M{x+lean} {top+60} L{x+lean} {top}", stroke="#8a5a3a", sw=26)
    return a


@word
def kusa():
    a = Art()
    G1, G2, G3 = "#8fd070", LEAF1, LEAF2

    def tuft(cx, base, h, w, col, lean=0):
        # a clump of three blades
        for dx, hh, ln in ((-0.5, 0.72, -1), (0.5, 0.78, 1), (0, 1.0, lean)):
            x0 = cx + dx * w
            tip = (cx + dx * w * 1.6 + ln * w * 0.55, base - h * hh)
            a.path(f"M{x0 - w*0.28:.0f} {base} C{x0 - w*0.2:.0f} {base - h*hh*0.5:.0f} {tip[0] - ln*w*0.2:.0f} {tip[1] + h*0.2:.0f} {tip[0]:.0f} {tip[1]:.0f} "
                   f"C{tip[0] + w*0.1:.0f} {tip[1] + h*0.3:.0f} {x0 + w*0.3:.0f} {base - h*hh*0.5:.0f} {x0 + w*0.28:.0f} {base} Z", fill=col, sw=9)

    tuft(120, 452, 200, 46, G1, -1)
    tuft(392, 452, 190, 46, G1, 1)
    tuft(256, 452, 330, 62, G2)
    # tiny white flowers
    for cx, cy in ((70, 300), (446, 330), (330, 150)):
        for i in range(5):
            import math
            t = -math.pi / 2 + i * 2 * math.pi / 5
            a.dot(cx + 15 * math.cos(t), cy + 15 * math.sin(t), 12, WHITE)
        a.dot(cx, cy, 9, YEL2)
    a.path("M60 454 L452 454", sw=11)
    return a


@word
def matsu():
    a = Art()
    trunk = "M246 470 C226 420 276 380 250 330 C236 300 214 280 220 250 L262 250 C256 280 290 306 300 340 C314 390 276 430 292 470 Z"
    a.path(trunk, fill=BARK)
    a.path("M262 250 C256 280 290 306 300 340 C314 390 276 430 292 470 L276 470 C262 430 290 390 276 340 C268 310 244 286 250 250 Z",
           fill=BARK_D, sw=0, stroke="none")
    a.path(trunk, "none")
    a.path("M214 470 C240 462 296 462 322 470", sw=10)

    def tier(cx, cy, rx, ry):
        a.ellipse(cx, cy, rx, ry, "#4e9a55")
        a.path(f"M{cx-rx+16} {cy+ry*0.35} C{cx-rx*0.4} {cy+ry*0.9} {cx+rx*0.4} {cy+ry*0.9} {cx+rx-16} {cy+ry*0.35}",
               stroke="#3d7f46", sw=8)
        for dx in (-0.5, 0, 0.5):
            a.path(f"M{cx+dx*rx-10} {cy-ry*0.3} L{cx+dx*rx} {cy-ry*0.55} L{cx+dx*rx+10} {cy-ry*0.3}",
                   stroke="#7cc17f", sw=7)

    tier(150, 226, 110, 54)
    tier(374, 190, 104, 50)
    tier(250, 118, 118, 56)
    a.path("M120 182 C110 172 116 156 128 152", stroke=WHITE, sw=0, **{"stroke-opacity": "0"})
    return a


@word
def donguri():
    a = Art()

    def acorn(cx, cy, s, rot=0):
        # cap
        a.path(f"M{cx} {cy-110*s} L{cx} {cy-140*s}", sw=14 * s + 4)
        a.path(f"M{cx-96*s} {cy-48*s} C{cx-96*s} {cy-112*s} {cx-44*s} {cy-120*s} {cx} {cy-120*s} "
               f"C{cx+44*s} {cy-120*s} {cx+96*s} {cy-112*s} {cx+96*s} {cy-48*s} Z", fill="#9a6a3c")
        for dx, dy in ((-52, -76), (0, -90), (52, -76), (-26, -58), (26, -58), (-70, -60), (70, -60)):
            a.circle(cx + dx * s, cy + dy * s, 6 * s, "#7a4f2a", sw=0, stroke="none")
        # nut
        a.path(f"M{cx-86*s} {cy-48*s} C{cx-92*s} {cy+60*s} {cx-40*s} {cy+130*s} {cx} {cy+150*s} "
               f"C{cx+40*s} {cy+130*s} {cx+92*s} {cy+60*s} {cx+86*s} {cy-48*s} Z", fill="#d9a35f")
        a.path(f"M{cx+86*s} {cy-48*s} C{cx+92*s} {cy+60*s} {cx+40*s} {cy+130*s} {cx} {cy+150*s} "
               f"C{cx+20*s} {cy+120*s} {cx+60*s} {cy+40*s} {cx+50*s} {cy-48*s} Z", fill="#c18544", sw=0, stroke="none")
        a.path(f"M{cx-86*s} {cy-48*s} C{cx-92*s} {cy+60*s} {cx-40*s} {cy+130*s} {cx} {cy+150*s} "
               f"C{cx+40*s} {cy+130*s} {cx+92*s} {cy+60*s} {cx+86*s} {cy-48*s} Z", "none")
        a.path(f"M{cx-96*s} {cy-48*s} C{cx-96*s} {cy-112*s} {cx-44*s} {cy-120*s} {cx} {cy-120*s} "
               f"C{cx+44*s} {cy-120*s} {cx+96*s} {cy-112*s} {cx+96*s} {cy-48*s} Z", "none")
        a.shine(f"M{cx-60*s} {cy-10*s} C{cx-62*s} {cy+30*s} {cx-44*s} {cy+66*s} {cx-24*s} {cy+90*s}")

    acorn(206, 270, 1.4)
    acorn(420, 380, 0.7)
    return a


@word
def happa():
    a = Art()
    # small orange leaf behind
    a.path("M330 470 C330 430 340 410 362 392", sw=22)
    a.path("M330 470 C330 430 340 410 362 392", stroke="#8a6a3a", sw=9)
    a.path("M362 396 C300 360 290 270 340 210 C410 230 446 330 392 396 C380 410 370 408 362 396 Z", fill="#f2a24a")
    a.path("M362 394 C360 340 366 280 340 222", stroke="#d9822a", sw=7)
    # big green leaf
    a.path("M170 470 C170 420 184 390 214 352", sw=26)
    a.path("M170 470 C170 420 184 390 214 352", stroke="#8a6a3a", sw=11)
    leaf = "M214 360 C120 330 80 220 122 120 C214 100 300 150 316 250 C324 330 270 392 214 360 Z"
    a.path(leaf, fill=LEAF1)
    a.path("M214 360 C270 392 324 330 316 250 C300 300 260 340 214 360 Z", fill=LEAF2, sw=0, stroke="none")
    a.path(leaf, "none")
    a.path("M214 352 C190 280 172 210 134 134", stroke=LEAF2, sw=9)
    for d in ("M190 296 C162 292 138 270 126 244", "M178 238 C204 232 226 214 236 192",
              "M168 196 C142 190 122 170 116 148", "M204 322 C240 320 266 296 276 268"):
        a.path(d, stroke=LEAF2, sw=7)
    a.shine("M150 150 C176 130 204 122 234 126")
    return a


@word
def kinoko():
    a = Art()

    def shroom(cx, base, w, h, cap, spot, stem="#fff4e2", face=False):
        top = base - h
        sh = h * 0.5
        a.path(f"M{cx-w*0.22} {base} C{cx-w*0.2} {base-sh*0.7} {cx-w*0.26} {top+sh*0.9} {cx-w*0.3} {top+sh*0.7} "
               f"L{cx+w*0.3} {top+sh*0.7} C{cx+w*0.26} {top+sh*0.9} {cx+w*0.2} {base-sh*0.7} {cx+w*0.22} {base} Z", fill=stem)
        a.path(f"M{cx-w*0.5} {top+sh*0.8} C{cx-w*0.52} {top-sh*0.1} {cx-w*0.3} {top-sh*0.2} {cx} {top-sh*0.2} "
               f"C{cx+w*0.3} {top-sh*0.2} {cx+w*0.52} {top-sh*0.1} {cx+w*0.5} {top+sh*0.8} "
               f"C{cx+w*0.3} {top+sh*1.0} {cx-w*0.3} {top+sh*1.0} {cx-w*0.5} {top+sh*0.8} Z", fill=cap)
        for dx, dy, r in ((-0.26, 0.2, 0.09), (0.04, -0.02, 0.1), (0.28, 0.24, 0.08), (-0.06, 0.5, 0.07)):
            a.circle(cx + w * dx, top + sh * dy + sh * 0.35, w * r, spot, sw=0, stroke="none")
        if face:
            fy = base - h * 0.22
            for s in (-1, 1):
                a.ellipse(cx + s * w * 0.1, fy, 8, 10, EYE, sw=0, stroke="none")
                a.ellipse(cx + s * w * 0.19, fy + 18, 10, 6, "#ff9aa8", sw=0, stroke="none", **{"fill-opacity": "0.7"})
            a.path(f"M{cx-9} {fy+14} C{cx-4} {fy+22} {cx+4} {fy+22} {cx+9} {fy+14}", sw=6)

    shroom(354, 450, 180, 200, "#d9a05b", "#fff4e2")
    shroom(206, 450, 300, 330, "#e5534b", WHITE, face=True)
    a.path("M60 452 C80 430 100 440 116 452 M410 452 C426 436 446 440 460 452", stroke=LEAF2, sw=9)
    return a


@word
def ie():
    a = Art()
    a.rect(88, 248, 336, 204, "#fff0d4", rx=6)
    a.path("M424 248 L424 452 L330 452 L330 248 Z", fill="#f1dfbd", sw=0, stroke="none")
    a.rect(88, 248, 336, 204, "none", rx=6)
    # chimney
    a.path("M326 150 L326 90 L384 90 L384 190 Z", fill="#c97f3e")
    a.rect(318, 76, 74, 24, "#a8672f", rx=6)
    # roof
    a.path("M44 266 L256 96 L468 266 C468 278 458 284 446 284 L66 284 C54 284 44 278 44 266 Z", fill=RED)
    a.path("M256 96 L468 266 C468 278 458 284 446 284 L380 284 Z", fill=RED_D, sw=0, stroke="none")
    a.path("M44 266 L256 96 L468 266 C468 278 458 284 446 284 L66 284 C54 284 44 278 44 266 Z", "none")
    a.circle(256, 218, 30, SKY)
    a.path("M226 218 L286 218 M256 188 L256 248", sw=8)
    # door and windows
    a.path("M130 452 L130 346 C130 322 188 322 188 346 L188 452 Z", fill=WOOD_D)
    a.circle(176, 400, 7, YEL, sw=0, stroke="none")
    a.rect(236, 330, 66, 66, SKY, rx=6)
    a.path("M269 330 L269 396 M236 363 L302 363", sw=7)
    a.rect(334, 330, 66, 66, SKY, rx=6)
    a.path("M367 330 L367 396 M334 363 L400 363", sw=7)
    a.path("M70 452 L442 452", sw=11)
    a.path("M40 454 C60 432 76 440 90 454 M430 454 C444 436 462 440 474 454", stroke=LEAF2, sw=9)
    return a


@word
def gakkou():
    a = Art()
    # clock tower
    a.rect(206, 70, 100, 120, "#fff0d4", rx=6)
    a.path("M196 76 L256 22 L316 76 Z", fill="#6f8fb8")
    a.circle(256, 126, 34, WHITE)
    a.path("M256 126 L256 102 M256 126 L274 136", sw=8)
    # main building
    a.rect(40, 188, 432, 262, "#fff0d4", rx=8)
    a.path("M40 188 L472 188 L472 214 L40 214 Z", fill="#6f8fb8", sw=11)
    for x in (66, 146):
        for y in (240, 340):
            a.rect(x, y, 60, 66, SKY, rx=6)
            a.path(f"M{x+30} {y} L{x+30} {y+66}", sw=6)
    for x in (386, 306):
        for y in (240, 340):
            a.rect(x, y, 60, 66, SKY, rx=6)
            a.path(f"M{x+30} {y} L{x+30} {y+66}", sw=6)
    # entrance
    a.rect(214, 330, 84, 120, "#c97f3e", rx=6)
    a.path("M256 330 L256 450", sw=7)
    a.rect(194, 296, 124, 34, "#6f8fb8", rx=8)
    a.path("M30 452 L482 452", sw=11)
    # flag pole
    a.path("M452 190 L452 90", sw=9)
    a.path("M452 94 L496 94 L496 126 L452 126 Z", fill=WHITE, sw=8)
    a.circle(474, 110, 9, RED, sw=0, stroke="none")
    return a


@word
def byouin():
    a = Art()
    a.rect(64, 160, 270, 292, WHITE, rx=8)
    a.path("M334 160 L334 452 L290 452 L290 160 Z", fill="#e9eef4", sw=0, stroke="none")
    a.rect(64, 160, 270, 292, "none", rx=8)
    a.rect(318, 254, 130, 198, "#eaf4fb", rx=8)
    # red cross sign on top
    a.rect(150, 66, 98, 98, RED, rx=14)
    a.path("M199 90 L199 140 M174 115 L224 115", stroke=WHITE, sw=22)
    for y in (196, 276):
        for x in (92, 176, 252):
            a.rect(x, y, 52, 56, SKY, rx=6)
    for x in (338, 392):
        a.rect(x, 282, 40, 50, SKY, rx=6)
    a.path("M64 378 L334 378", stroke="#7fc0e8", sw=14)
    # entrance
    a.rect(156, 386, 88, 66, "#bfe6fa", rx=6)
    a.path("M200 386 L200 452", sw=7)
    a.path("M40 452 L472 452", sw=11)
    a.path("M360 392 L428 392 L428 452 L360 452 Z", fill="#e5f3fb", sw=0, stroke="none")
    return a


@word
def oshiro():
    a = Art()
    ROOF, ROOF_D = "#5d7894", "#486079"
    # stone base
    a.path("M60 450 L110 350 L402 350 L452 450 Z", fill="#b6b0a8")
    for x in (170, 256, 342):
        a.path(f"M{x} 352 L{x - (x - 256) * 0.0 + (x - 256) * 0.2:.0f} 450", stroke="#8f8981", sw=6)
    a.path("M92 400 L420 400", stroke="#8f8981", sw=6)
    # tiers (bottom to top)
    a.rect(132, 266, 248, 84, WHITE, rx=4)
    a.path("M100 266 C100 252 112 246 128 246 L384 246 C400 246 412 252 412 266 L430 296 L82 296 Z", fill=ROOF)
    a.rect(172, 168, 168, 78, WHITE, rx=4)
    a.path("M146 168 C146 154 158 148 174 148 L338 148 C354 148 366 154 366 168 L384 196 L128 196 Z", fill=ROOF)
    a.rect(212, 76, 88, 72, WHITE, rx=4)
    a.path("M182 76 C198 52 228 40 256 36 C284 40 314 52 330 76 L344 104 L168 104 Z", fill=ROOF)
    # roof highlights
    for y, x0, x1 in ((266, 100, 412), (168, 146, 366)):
        pass
    # windows
    for x in (170, 236, 302):
        a.rect(x, 292 + 16, 40, 34, "#33425a", rx=6)
    for x in (220, 270):
        a.rect(x - 14, 204, 28, 30, "#33425a", rx=6)
    a.rect(242, 110, 28, 28, "#33425a", rx=6)
    # gold ornaments (shachi) at the top
    a.path("M214 50 C200 34 212 18 226 24 C222 36 226 44 232 48 Z", fill="#f6c548", sw=8)
    a.path("M298 50 C312 34 300 18 286 24 C290 36 286 44 280 48 Z", fill="#f6c548", sw=8)
    # entrance
    a.path("M236 450 L236 392 C236 372 276 372 276 392 L276 450 Z", fill="#33425a")
    return a


SHINGOU_LAMPS = (140, 256, 372)   # x of the three lamps (green, yellow, red); y and r below
SHINGOU_Y, SHINGOU_R = 145, 42


@word
def shingou():
    a = Art()
    # pole
    a.tube("M256 200 L256 540", "#9aa5a8", 34, 16)
    a.path("M214 540 L298 540", sw=18)
    # signal box (lamps are lit by the app; the picture shows green)
    a.rect(60, 76, 392, 138, "#4a5560", rx=66)
    a.path("M70 124 C70 98 94 86 116 86 L250 86", stroke="#6c7884", sw=8, **{"stroke-opacity": "0.8"})
    for cx, col in zip(SHINGOU_LAMPS, ("#58d36a", "#5e5320", "#6b2a28")):
        a.circle(cx, SHINGOU_Y, SHINGOU_R, col)
    a.shine("M120 132 C126 118 138 110 150 108")
    for cx in SHINGOU_LAMPS:
        a.path(f"M{cx-48} 100 C{cx-28} 90 {cx+28} 90 {cx+48} 100", sw=8)
    return a


FUMIKIRI_LAMPS = (84, 140)
FUMIKIRI_Y, FUMIKIRI_R = 233, 22


@word
def fumikiri():
    a = Art()
    # rails and sleepers
    for x in (48, 130, 212, 294, 376, 458):
        a.rect(x - 16, 430, 32, 46, "#a58a6c", rx=4, sw=8)
    a.path("M20 446 L492 446 M20 462 L492 462", stroke="#8a949a", sw=10)
    # post
    a.tube("M110 440 L110 140", "#f4f1ea", 40, 20)
    a.path("M92 440 L92 330 M128 440 L128 330", stroke="none", sw=0)
    # crossbuck sign
    a.path("M54 112 L170 176 M170 112 L54 176", stroke=O, sw=40)
    a.path("M54 112 L170 176 M170 112 L54 176", stroke=WHITE, sw=22)
    # signal box with two red lamps
    a.rect(52, 196, 120, 74, "#4a5560", rx=22)
    for cx in FUMIKIRI_LAMPS:
        a.circle(cx, FUMIKIRI_Y, FUMIKIRI_R, "#e5534b")
    a.path("M110 270 L110 290", sw=12)
    # barrier arm (striped)
    a.path("M120 340 L470 340", sw=48)
    a.path("M120 340 L470 340", stroke="#f6d33a", sw=26)
    for x in (178, 238, 298, 358, 418):
        a.path(f"M{x} 340 L{x+22} 340", stroke="#33343a", sw=26)
    a.path("M120 340 L470 340", stroke="none", sw=0)
    a.circle(110, 340, 20, "#f4f1ea")
    return a


@word
def gaitou():
    a = Art()
    GREEN_D = "#46665a"
    a.path("M180 470 C200 440 232 436 256 436 C280 436 312 440 332 470 Z", fill=GREEN_D)
    a.path("M232 440 C240 400 244 300 244 190 L268 190 C268 300 272 400 280 440 Z", fill=GREEN_D)
    a.tube("M256 200 C256 150 256 110 256 96", GREEN_D, 40, 22)
    # lamp cage
    a.path("M196 100 L316 100 L296 70 L216 70 Z", fill=GREEN_D)
    a.path("M226 70 C226 54 286 54 286 70", sw=10)
    a.circle(256, 38, 12, GREEN_D)
    a.path("M204 100 C190 130 200 176 226 190 L286 190 C312 176 322 130 308 100 Z", fill="#fff1a8")
    a.path("M226 190 L286 190 L276 210 L236 210 Z", fill=GREEN_D)
    a.path("M226 112 C214 132 218 160 230 176", stroke=WHITE, sw=9, **{"stroke-opacity": "0.75"})
    for dx, dy in ((-76, -10), (76, -10), (-70, 70), (70, 70)):
        pass
    for x1, y1, x2, y2 in ((150, 120, 118, 112), (362, 120, 394, 112), (150, 168, 122, 184), (362, 168, 390, 184)):
        a.path(f"M{x1} {y1} L{x2} {y2}", stroke="#f6c548", sw=9)
    return a


@word
def asagao():
    import math
    a = Art()
    # stake and vine
    a.path("M256 480 L256 70", stroke=O, sw=24)
    a.path("M256 480 L256 70", stroke="#d6a56e", sw=10)
    a.path("M256 440 C190 400 330 360 256 320 C190 280 330 240 256 200", stroke=LEAF2, sw=12)
    # leaves
    for d in ("M256 410 C200 400 160 430 166 462 C204 480 252 450 256 410 Z",
              "M256 300 C312 290 352 318 346 350 C310 368 262 340 256 300 Z"):
        a.path(d, fill=LEAF1, sw=9)

    def bloom(cx, cy, r, col, col2):
        a.circle(cx, cy, r, col)
        a.circle(cx, cy, r * 0.62, col2, sw=0, stroke="none")
        for i in range(5):
            t = -math.pi / 2 + i * 2 * math.pi / 5
            a.path(f"M{cx} {cy} L{cx + r*0.9*math.cos(t):.1f} {cy + r*0.9*math.sin(t):.1f}", stroke=WHITE, sw=r * 0.12)
        a.circle(cx, cy, r * 0.2, "#fff4b0", sw=0, stroke="none")

    bloom(170, 180, 82, "#6f8be8", "#a9bbf5")
    bloom(350, 120, 62, "#d86ab8", "#efa6d8")
    bloom(346, 250, 50, "#6f8be8", "#a9bbf5")
    return a


@word
def bara():
    import math
    a = Art()
    a.path("M256 300 C250 360 262 420 256 484", stroke=O, sw=26)
    a.path("M256 300 C250 360 262 420 256 484", stroke=LEAF2, sw=12)
    for y, s in ((380, -1), (440, 1)):
        a.path(f"M{256 + s*4} {y} L{256 + s*22} {y-10} L{256 + s*6} {y-18}", fill=LEAF2, sw=7)
    for d in ("M256 410 C316 380 380 392 404 440 C350 464 282 450 256 410 Z",
              "M256 360 C196 330 132 346 112 396 C170 414 238 400 256 360 Z"):
        a.path(d, fill=LEAF1, sw=9)
    a.path("M270 408 C320 410 358 420 386 436", stroke=LEAF2, sw=6)
    a.path("M242 362 C190 362 156 372 130 388", stroke=LEAF2, sw=6)
    # rose bloom
    cx, cy = 256, 196
    a.circle(cx, cy, 134, "#e8505b")
    for k, (r, col) in enumerate(((100, "#f06a74"), (68, "#e8505b"), (38, "#f06a74"))):
        a.circle(cx, cy, r, col, sw=9)
    a.path(f"M{cx-60} {cy+10} C{cx-60} {cy-50} {cx+20} {cy-70} {cx+60} {cy-20}", stroke=O, sw=9)
    a.path(f"M{cx-30} {cy+40} C{cx+20} {cy+70} {cx+80} {cy+30} {cx+84} {cy-20}", stroke=O, sw=9)
    a.path(f"M{cx-18} {cy-6} C{cx-8} {cy-26} {cx+20} {cy-18} {cx+14} {cy+6}", stroke=O, sw=8)
    # sepals under the bloom
    for d in ("M200 320 C190 340 196 358 214 364 C214 346 214 332 222 320 Z",
              "M312 320 C322 340 316 358 298 364 C298 346 298 332 290 320 Z"):
        a.path(d, fill=LEAF1, sw=8)
    a.shine("M150 150 C160 112 192 84 232 78")
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
    # palm and four fingers and the thumb, drawn as one hand
    blobs(a, [
        ("t", 256, 330, 256, 372, 200),
        ("t", 178, 300, 168, 168, 46), ("t", 232, 290, 232, 118, 48),
        ("t", 288, 296, 296, 142, 46), ("t", 336, 316, 352, 214, 40),
        ("t", 158, 360, 92, 288, 50),
    ], SKIN)
    for x1, y1, x2, y2 in ((168, 166, 168, 150), (232, 116, 232, 98), (296, 140, 296, 124)):
        pass
    eyes(a, 256, 352, 42)
    cheeks(a, 256, 384, 70)
    smile(a, 256, 380)
    # little shine on the palm
    a.shine("M196 300 C192 282 196 262 206 248")
    # waving marks
    a.path("M404 150 C426 176 428 212 410 240", sw=9)
    a.path("M436 122 C468 160 470 220 442 262", sw=9)
    return a


@word
def ashi():
    a = Art()
    # the sole of a bare foot: five round toes behind the foot, and a little face
    for cx, cy, r in ((172, 200, 50), (244, 166, 38), (300, 172, 34), (346, 192, 30), (380, 224, 26)):
        a.circle(cx, cy, r, SKIN)
    a.ellipse(256, 346, 118, 140, SKIN)
    a.ellipse(256, 412, 70, 34, SKIN_D, sw=0, stroke="none", **{"fill-opacity": "0.5"})
    eyes(a, 256, 330, 42)
    cheeks(a, 256, 372, 74)
    smile(a, 256, 368)
    a.shine("M162 300 C158 340 164 372 178 396")
    return a


@word
def me():
    a = Art()
    # eyebrow, white of the eye, iris, pupil, shine and lashes
    a.path("M96 150 C150 70 360 66 416 150", sw=18, stroke=HAIR)
    a.path("M70 270 C130 168 382 168 442 270 C382 372 130 372 70 270 Z", fill=WHITE)
    a.circle(256, 268, 84, "#8fc9a8")
    a.circle(256, 268, 58, "#5da98a", sw=0, stroke="none")
    a.circle(256, 268, 36, EYE, sw=0, stroke="none")
    a.circle(228, 238, 20, WHITE, sw=0, stroke="none")
    a.circle(284, 296, 10, WHITE, sw=0, stroke="none")
    a.path("M70 270 C130 168 382 168 442 270", sw=16)
    for x1, y1, x2, y2 in ((118, 216, 74, 176), (176, 188, 150, 140), (336, 188, 362, 140), (394, 216, 438, 176)):
        a.path(f"M{x1} {y1} L{x2} {y2}", sw=12)
    return a


@word
def mimi():
    a = Art()
    # the ear, its curls, and a few music notes
    blobs(a, [
        ("p", "M280 90 C380 80 430 170 400 270 C380 340 340 360 330 410 C322 460 262 470 240 430 "
              "C220 394 210 360 210 300 C210 190 220 100 280 90 Z"),
    ], SKIN)
    a.path("M286 138 C340 136 366 190 346 250 C334 288 296 296 292 340", sw=10, stroke=SKIN_D)
    a.ellipse(284, 330, 30, 20, SKIN_D, sw=0, stroke="none")
    a.path("M296 186 C316 190 322 214 310 236", sw=8, stroke=SKIN_D)
    a.ellipse(310, 400, 22, 14, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.75"})
    a.shine("M246 150 C236 190 234 226 238 262")
    note(a, 96, 190, 1.0)
    note(a, 130, 350, 0.8, "#f0a23c")
    return a


@word
def kuchi():
    a = Art()
    # smiling open mouth: lips, dark inside, teeth, tongue
    a.path("M66 214 C122 184 196 204 256 238 C316 204 390 184 446 214 C446 346 360 440 256 440 "
           "C152 440 66 346 66 214 Z", fill=LIPS)
    a.path("M112 240 C170 224 220 250 256 266 C292 250 342 224 400 240 C392 330 330 396 256 396 "
           "C182 396 120 330 112 240 Z", fill=MOUTH_IN)
    a.path("M142 250 C190 242 226 262 256 276 C286 262 322 242 370 250 C368 270 360 290 346 300 "
           "C316 286 286 312 256 318 C226 312 196 286 166 300 C152 290 144 270 142 250 Z",
           fill=WHITE, sw=7)
    a.ellipse(256, 370, 70, 40, TONGUE, sw=0, stroke="none")
    a.path("M256 334 L256 372", stroke="#e0607a", sw=7)
    a.shine("M104 222 C140 212 170 216 196 226")
    return a


@word
def atama():
    a = Art()
    # a child's head: ears, round face, hair with a tuft, eyes and a smile
    blobs(a, [("c", 90, 300, 40), ("c", 422, 300, 40), ("e", 256, 290, 168, 172)], SKIN)
    a.circle(90, 300, 20, SKIN_D, sw=0, stroke="none")
    a.circle(422, 300, 20, SKIN_D, sw=0, stroke="none")
    a.path("M92 262 C70 130 170 100 256 102 C346 100 442 130 420 262 C402 222 350 196 306 210 "
           "C280 180 224 186 202 212 C160 208 110 226 92 262 Z", fill=HAIR)
    a.path("M248 108 C226 56 262 14 306 34 C286 46 288 74 280 108 Z", fill=HAIR)
    a.shine("M150 168 C170 146 196 136 224 134")
    eyes(a, 256, 300, 60)
    cheeks(a, 256, 340, 104, rx=20, ry=12)
    smile(a, 256, 340, 18)
    return a


@word
def onaka():
    a = Art()
    # a round tummy sticking out between a shirt hem and shorts, with a belly button
    a.ellipse(256, 300, 170, 150, SKIN)
    a.path("M112 60 C112 44 128 40 148 40 L364 40 C384 40 400 44 400 60 L406 174 "
           "C350 218 162 218 106 174 Z", fill=YEL)
    a.path("M106 408 C162 452 350 452 406 408 L400 490 C400 504 384 508 364 508 L148 508 "
           "C128 508 112 504 112 490 Z", fill=BLUE)
    a.path("M140 100 L152 100", stroke="#ffffff", sw=10, **{"stroke-opacity": "0.5"})
    a.path("M140 470 C180 484 210 488 244 488", stroke="#ffffff", sw=9, **{"stroke-opacity": "0.5"})
    a.path("M234 316 C240 296 272 296 278 316 C272 338 240 338 234 316 Z", fill=SKIN_D, sw=8)
    cheeks(a, 256, 350, 100, rx=18, ry=12)
    a.shine("M130 270 C126 310 136 346 156 372")
    a.circle(462, 270, 14, "#ffffff", sw=7)
    a.circle(484, 226, 9, "#ffffff", sw=6)
    return a


@word
def hoppe():
    a = Art()
    # a round face with puffed-up cheeks, closed happy eyes, a tiny mouth
    blobs(a, [
        ("p", "M256 100 C380 100 446 190 446 290 C446 390 362 450 256 450 C150 450 66 390 66 290 "
              "C66 190 132 100 256 100 Z"),
        ("c", 118, 342, 66), ("c", 394, 342, 66),
    ], SKIN)
    a.path("M70 262 C60 150 150 96 256 98 C362 96 452 150 442 262 C418 214 372 190 330 206 "
           "C300 180 212 180 182 206 C140 190 94 214 70 262 Z", fill=HAIR)
    a.circle(124, 342, 50, "#ff9aa8", sw=0, stroke="none", **{"fill-opacity": "0.75"})
    a.circle(388, 342, 50, "#ff9aa8", sw=0, stroke="none", **{"fill-opacity": "0.75"})
    for s in (-1, 1):
        x = 256 + s * 82
        a.path(f"M{x-24} 296 C{x-14} 268 {x+14} 268 {x+24} 296", sw=9)
        for k in (-1, 0, 1):
            a.path(f"M{256 + s*134 + k*18 - 6} 366 L{256 + s*134 + k*18 + 6} 340", stroke="#ffffff", sw=7)
    a.path("M232 340 C240 356 256 352 256 340 C256 352 272 356 280 340", sw=8)
    a.shine("M150 150 C176 124 210 112 244 110")
    return a



def write_swing_parts():
    """The frame and the seat of the swing go to Content/Art/parts/ (D173). Same fit as burango.svg."""
    full, frame, seat = swing_parts()
    params = fit_params([full])
    out = os.path.join(HERE, "..", "..", "Content", "Art", "parts")
    os.makedirs(out, exist_ok=True)
    open(os.path.join(out, "burango-frame.svg"), "w").write(frame.svg(params=params))
    open(os.path.join(out, "burango-seat.svg"), "w").write(seat.svg(params=params))
    s, tx, ty = params
    print("swing pivot (fraction of the image):", round((s * 256 + tx) / 512, 4), round((s * 100 + ty) / 512, 4))
    s2, tx2, ty2 = fit_params([W["suberidai"]()])
    print("slide curve:", [(round((s2 * x + tx2) / 512, 4), round((s2 * y + ty2) / 512, 4)) for x, y in SLIDE_CURVE])


def print_lamps():
    """Where the app lights the lamps (D174): fractions of the image come from these 512 px numbers."""
    for name, xs, y, r, sw in (("shingou", SHINGOU_LAMPS, SHINGOU_Y, SHINGOU_R, 11),
                               ("fumikiri", FUMIKIRI_LAMPS, FUMIKIRI_Y, FUMIKIRI_R, 11)):
        s1, tx1, ty1 = fit_params([W[name]()])
        print(name, "lamps (x, y, r in 512 px; r = lamp without its outline):",
              [(round(s1 * x + tx1, 1), round(s1 * y + ty1, 1), round(s1 * (r - sw / 2), 1)) for x in xs])


if __name__ == "__main__":
    names = sys.argv[1:] or list(W)
    for n in names:
        open(os.path.join(OUT, f"{n}.svg"), "w").write(W[n]().svg())
    if not sys.argv[1:] or "burango" in names:
        write_swing_parts()
    if not sys.argv[1:] or "shingou" in names or "fumikiri" in names:
        print_lamps()
