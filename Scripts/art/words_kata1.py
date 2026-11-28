"""めぐり Kata1 の絵（カタカナのことば: のりもの・はたらく くるま・たてもの・まちの もの・スポーツ・がっき・いえの物。D204）。
描き方は Content/Art/style-guide.md（part()/sil()/ink()。本体は1つの部品。顔はつけない。ロボットだけ顔つき）。
実在の会社・商品・ロゴは描かない。"""
import math
from lib import Art, mirror, taper, smooth, O, EYE, SW
from words import (word, RED, RED_D, YEL, YEL2, BLUE, BLUE_D, SKY, WOOD, WOOD_D, PINK, GREEN, CREAM, WHITE, GREY, HUB, NAVY,
                   c_rpoly, c_rect, c_circ, c_bar, c_line, c_glass, c_wheel, c_lamp, c_waves,
                   e2_rr, e2_poly, e2_seg, e2_cap, e2_line,
                   d_circ, d_tf, d_rim)

K_STEEL, K_STEEL_D = "#dfe6ec", "#b9c4cf"
K_YEL, K_YEL_D = "#f7c948", "#e0a92a"
K_DARK, K_DARK_D = "#4a5163", "#383e4d"
K_ORANGE = "#f7a94b"
K_STONE, K_STONE_D = "#c9d1d8", "#a9b3bc"
K_GREEN, K_GREEN_D = "#7cc36a", "#5fa64f"


def R(d, deg, cx=256, cy=256):
    """Turn a path around (cx, cy) by deg degrees (clockwise on screen)."""
    return d_tf(d_tf(d, dx=-cx, dy=-cy), deg=deg, dx=cx, dy=cy)


def RP(x, y, deg, cx=256, cy=256):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    x, y = x - cx, y - cy
    return x * c - y * s + cx, x * s + y * c + cy


def k_line(a, x0, y0, x1, y1, w=6, s=1, e=1, col=O, deg=0, cx=256, cy=256):
    (u, v), (m, n) = RP(x0, y0, deg, cx, cy), RP(x1, y1, deg, cx, cy)
    a.ink([e2_seg(u, v, m, n)], w, a=s, b=e, col=col)


# ----------------------------------------------------------- はたらく くるま --
@word
def patokaa():
    """A police car: white top, black lower body, a red beacon on the roof."""
    a = Art()
    W2, BLK = "#fbf8f2", "#3d3f4a"
    BODY_D = ("M66 322 C66 296 86 286 116 282 L150 278 C166 212 206 166 266 166 L306 166 C362 166 394 212 410 274 "
              "L438 280 C460 286 470 304 470 328 L470 346 Q470 374 442 374 L94 374 Q66 374 66 346 Z")
    with a.part(8):                                    # the beacon sits on the roof
        a.sil(c_rpoly([(236, 120), (302, 120), (310, 172), (228, 172)], [26, 26, 0, 0]), RED)
    a.path("M254 134 L254 152", stroke=WHITE, sw=7, **{"stroke-opacity": "0.7"})
    with a.part():
        a.sil(BODY_D, W2)
        a.blob("M66 326 L470 326 L470 346 Q470 373 442 373 L94 373 Q67 373 66 346 Z", BLK)
        a.blob(c_rect(66, 300, 12, 30, 5), "#f9b6bf")
    c_glass(a, "M182 276 C194 232 222 198 262 196 L276 196 L276 276 Z", glint=(214, 232, 26))
    c_glass(a, "M300 196 L310 196 C348 198 372 232 382 276 L300 276 Z")
    c_line(a, 288, 286, 288, 362, 7, col=O)
    a.blob(c_rect(306, 322, 30, 11, 5), WHITE)
    c_lamp(a, 452, 312, 12, 15)
    a.shine("M214 180 C240 174 300 172 330 180")
    for x in (150, 380):
        c_wheel(a, x, 376, 52)
    return a


@word
def takushii():
    """A taxi: a yellow car with a lit sign on the roof and a checker band."""
    a = Art()
    BODY_D = ("M66 322 C66 296 86 286 116 282 L150 278 C166 212 206 166 266 166 L306 166 C362 166 394 212 410 274 "
              "L438 280 C460 286 470 304 470 328 L470 346 Q470 374 442 374 L94 374 Q66 374 66 346 Z")
    with a.part(8):                                    # roof sign
        a.sil(c_rect(224, 124, 84, 50, 14), "#fff3b0")
        a.blob(c_rect(224, 150, 84, 24, 0), K_ORANGE)
    with a.part():
        a.sil(BODY_D, K_YEL)
        a.blob("M67 340 L469 340 L469 346 Q469 373 442 373 L94 373 Q67 373 67 346 Z", K_YEL_D)
        a.blob(c_rect(66, 300, 12, 30, 5), "#f9b6bf")
        for i in range(25):                            # the checker band
            a.blob(c_rect(84 + i * 14, 304 + (i % 2) * 14, 14, 14, 0), NAVY)
    c_glass(a, "M182 276 C194 232 222 198 262 196 L276 196 L276 276 Z", glint=(214, 232, 26))
    c_glass(a, "M300 196 L310 196 C348 198 372 232 382 276 L300 276 Z")
    c_line(a, 288, 286, 288, 362, 7)
    a.blob(c_rect(306, 346, 30, 11, 5), WHITE)
    c_lamp(a, 452, 312, 12, 15)
    a.shine("M214 180 C240 174 300 172 330 180")
    for x in (150, 380):
        c_wheel(a, x, 376, 52)
    return a


@word
def torakku():
    """A box truck: a tall white box with an orange band, a blue cab."""
    a = Art()
    CAB, CAB_D = "#4a9fe0", "#3a84c4"
    with a.part():                                     # the box
        a.sil(c_rpoly([(36, 118), (322, 118), (322, 372), (36, 372)], [18, 18, 4, 4]), "#fbf8f2")
        a.blob(c_rect(37, 250, 284, 36, 0), K_ORANGE)
        a.blob(c_rect(37, 340, 284, 31, 0), "#e6dfd0")
        a.blob("M300 120 L321 120 L321 372 L300 372 Z", "#e6dfd0")
    with a.part():                                     # the cab
        a.sil("M300 214 L380 214 C406 214 420 228 432 256 L452 296 C470 306 478 322 478 340 L478 360 Q478 376 460 376 "
              "L300 376 Z", CAB)
        a.blob("M301 346 L477 346 L477 360 Q477 375 460 375 L301 375 Z", CAB_D)
    c_glass(a, "M334 232 L378 232 C392 232 400 240 408 256 L420 280 Q422 288 412 288 L334 288 Q326 288 326 280 L326 240 Q326 232 334 232 Z",
            glint=(342, 242, 20))
    c_line(a, 322, 296, 322, 366, 6)
    a.blob(c_rect(340, 322, 26, 10, 5), WHITE)
    c_lamp(a, 466, 330, 10, 13)
    a.shine("M52 134 L190 134", sw=6)
    for x in (92, 176, 404):
        c_wheel(a, x, 380, 40)
    return a


@word
def shoberukaa():
    """An excavator: a yellow cab on crawler tracks, a long arm with a bucket."""
    a = Art()
    DARK = "#4a4f5c"
    with a.part(8):                                    # arm: boom, stick
        a.sil(taper([(250, 250, 300, 160, 340, 110, 400, 108)], 40, 30), K_YEL)
        a.sil(taper([(396, 112, 440, 112, 470, 170, 468, 262)], 28, 24), K_YEL)
    with a.part(8):                                    # bucket
        a.sil("M444 250 L500 250 C506 300 486 350 436 360 C418 362 414 346 430 330 C446 312 448 280 444 250 Z", "#8f9aa5")
    a.blob("M476 262 C486 300 474 332 450 348 C466 326 472 296 468 262 Z", "#707b86")
    with a.part(8):                                    # the arm cylinder
        a.sil(c_bar(268, 224, 350, 150, 16), "#cdd3d8")
    with a.part():                                     # the tracks
        a.sil(c_rect(60, 346, 372, 92, 46), DARK)
    for x in (110, 190, 270, 350):
        a.dot(x, 392, 22, "#8b93a3")
        a.dot(x, 392, 8, "#5d6572")
    with a.part():                                     # the house and the cab
        a.sil(c_rpoly([(60, 254), (300, 254), (320, 342), (60, 342)], [26, 14, 0, 0]), K_YEL)
        a.sil(c_rpoly([(150, 142), (260, 142), (290, 254), (150, 254)], [16, 14, 0, 0]), K_YEL)
        a.blob("M61 318 L319 318 L320 342 L61 342 Z", K_YEL_D)
        a.blob(c_rect(61, 270, 70, 36, 0), "#b9a85c")
    c_glass(a, "M172 160 L248 160 L268 240 L172 240 Z", glint=(184, 172, 26))
    a.shine("M76 268 L120 268", sw=6)
    return a


@word
def burudoozaa():
    """A bulldozer: crawler tracks, a cab with a flat roof, an exhaust pipe and a wide blade in front."""
    a = Art()
    DARK = "#4a4f5c"
    with a.part(8):                                    # the arms that hold the blade
        a.sil(c_bar(330, 330, 440, 340, 24), "#8f9aa5")
    with a.part(8):                                    # exhaust pipe
        a.sil(c_rect(330, 170, 22, 100, 8), "#8a949a")
    with a.part():                                     # the tracks
        a.sil(c_rect(70, 340, 340, 100, 50), DARK)
    for x in (122, 196, 270, 346):
        a.dot(x, 390, 22, "#8b93a3")
        a.dot(x, 390, 8, "#5d6572")
    with a.part():                                     # hood and cab
        a.sil(c_rpoly([(90, 176), (270, 176), (276, 262), (404, 262), (404, 350), (90, 350)], [14, 14, 0, 12, 0, 0]), K_YEL)
        a.blob("M91 322 L403 322 L403 350 L91 350 Z", K_YEL_D)
    with a.part(7):                                    # the roof
        a.sil(c_rpoly([(82, 134), (286, 134), (286, 168), (82, 168)], [12, 12, 4, 4]), "#d9b130")
    c_glass(a, c_rpoly([(112, 196), (252, 196), (252, 300), (112, 300)], [10, 10, 4, 4]), glint=(124, 208, 30))
    with a.part(8):                                    # the blade
        a.sil(c_rpoly([(420, 236), (492, 226), (494, 392), (420, 400)], [8, 14, 14, 8]), "#8f9aa5")
        a.blob(c_rect(421, 238, 24, 160, 0), K_STEEL_D)
    return a


@word
def herikoputaa():
    """A helicopter: a red body, a round glass cockpit, a tail with a rotor, long blades on top and two skids."""
    a = Art()
    with a.part(8):                                    # the skids and the legs
        a.sil(c_bar(150, 392, 360, 392, 18), "#5d6572")
        a.sil(c_bar(210, 348, 206, 392, 14), "#5d6572")
        a.sil(c_bar(306, 348, 310, 392, 14), "#5d6572")
    with a.part(8):                                    # the mast and the blades
        a.sil(c_bar(266, 150, 266, 190, 22), "#5d6572")
        a.sil(c_rpoly([(52, 122), (480, 122), (480, 150), (52, 150)], [14, 14, 14, 14]), "#8f9aa5")
    with a.part():                                     # tail boom, fin and the body
        a.sil(taper([(150, 250, 100, 238, 40, 212, -10, 184)], 50, 20), RED_D)
        a.sil("M-40 112 L16 148 L8 200 L-26 196 Z", RED)
        a.sil("M120 214 C120 190 160 176 220 176 L340 176 C410 176 440 232 440 280 C440 330 400 352 340 352 L180 352 C130 352 112 300 120 214 Z", RED)
        a.blob("M118 306 C140 336 170 346 190 346 L388 346 C416 340 434 320 440 296 C420 330 390 342 340 342 L180 342 C150 342 126 328 118 306 Z", RED_D)
    c_glass(a, "M330 190 C380 190 420 226 426 286 L330 286 Z", glint=(346, 206, 30))
    c_glass(a, c_rect(176, 206, 70, 62, 10), glint=(186, 214, 22))
    c_glass(a, c_rect(260, 206, 56, 62, 10))
    a.blob(c_rect(120, 292, 308, 14, 0), WHITE, **{"fill-opacity": "0.85"})
    with a.part(7):                                    # the tail rotor
        a.sil(c_circ(-22, 160, 12, 40), "#8f9aa5")
    a.shine("M186 192 L280 192", sw=6)
    return a


@word
def roketto():
    """A rocket standing up: red nose, white body with a round window, three fins and a flame."""
    a = Art()
    with a.part(8):                                    # the flame
        a.sil("M226 392 C214 430 236 462 256 486 C276 462 298 430 286 392 Z", "#f7a94b")
    a.blob("M240 396 C236 426 246 446 256 462 C266 446 276 426 272 396 Z", "#ffe27a")
    with a.part():                                     # side fins
        a.sil("M190 300 C150 320 126 360 124 408 L192 380 Z", RED)
        a.sil("M322 300 C362 320 386 360 388 408 L320 380 Z", RED)
    with a.part():                                     # the body
        a.sil("M256 44 C320 90 346 170 346 250 L346 392 L166 392 L166 250 C166 170 192 90 256 44 Z", "#fbf8f2")
        a.blob("M310 110 C336 160 346 210 346 250 L346 392 L316 392 L316 250 C316 190 308 150 290 100 Z", "#e6dfd0")
        a.blob("M256 44 C288 68 310 100 322 134 L190 134 C202 100 224 68 256 44 Z", RED)
        a.blob(c_rect(166, 346, 180, 46, 0), "#4fa8e0")
    with a.part():                                     # centre fin
        a.sil("M232 380 L280 380 L284 414 L228 414 Z", RED_D)
    with a.part(8):                                    # the window
        a.sil(c_circ(256, 216, 44), "#8f9aa5")
    with a.part(5):
        a.sil(c_circ(256, 216, 30), SKY)
    a.path("M240 206 C244 196 250 192 258 192", stroke=WHITE, sw=7, **{"stroke-opacity": "0.8"})
    a.shine("M196 160 C198 146 204 130 212 120", sw=6)
    return a


@word
def parashuuto():
    """A parachute: a striped round canopy, strings and a small wooden crate."""
    a = Art()
    for x in (112, 200, 312, 400):                     # the strings
        a.path(f"M{x} 270 L256 410", stroke="#6b5a50", sw=6)
    with a.part():                                     # the canopy
        a.sil("M40 262 C40 130 140 56 256 56 C372 56 472 130 472 262 C440 238 408 238 380 262 C356 240 326 240 300 262 "
              "C284 244 228 244 212 262 C186 240 156 240 132 262 C104 238 72 238 40 262 Z", RED)
        a.blob("M132 262 C140 190 176 100 226 62 L256 56 C228 110 212 180 212 262 C186 240 156 240 132 262 Z", WHITE)
        a.blob("M300 262 C300 180 284 110 256 56 C290 62 330 100 354 150 C372 190 380 230 380 262 C356 240 326 240 300 262 Z", WHITE)
        a.blob("M440 190 C456 214 468 240 472 262 C460 252 450 246 440 244 Z", RED_D)
    a.shine("M92 168 C112 128 150 98 196 82", sw=8)
    with a.part(8):                                    # the crate
        a.sil(c_rect(206, 398, 100, 76, 10), WOOD)
        a.blob(c_rect(207, 440, 98, 33, 0), WOOD_D)
    a.blob(c_rect(244, 398, 24, 76, 0), RED)
    a.blob(c_rect(207, 424, 98, 14, 0), RED)
    return a


# ------------------------------------------------------------- のりもの --
@word
def yotto():
    """A sailboat: a white main sail, a red jib, a blue hull and a little flag."""
    a = Art()
    with a.part(7):                                    # the mast
        a.sil(c_bar(252, 50, 252, 372, 14), "#8a6a4a")
    with a.part(6):                                    # the flag
        a.sil(c_rpoly([(256, 34), (316, 52), (256, 70)], [0, 6, 0]), YEL2)
    with a.part():                                     # the jib
        a.sil("M236 96 C150 150 104 230 92 344 L236 344 Z", RED)
        a.blob("M236 190 C190 224 154 270 136 344 L236 344 Z", "#cf433c")
    with a.part():                                     # the main sail
        a.sil("M270 76 C352 138 410 236 426 344 L270 344 Z", WHITE)
        a.blob("M360 186 C396 246 416 300 426 344 L394 344 C388 300 374 250 340 194 Z", "#e6edf3")
    with a.part():                                     # the hull
        a.sil("M62 350 L452 350 C440 410 396 440 340 440 L174 440 C118 440 74 410 62 350 Z", BLUE)
        a.blob("M66 376 L448 376 C446 382 444 388 442 394 L72 394 C70 388 68 382 66 376 Z", WHITE)
        a.blob("M92 414 C110 430 140 436 174 436 L340 436 C372 436 398 428 416 414 C396 426 366 430 340 430 L174 430 C150 430 118 424 92 414 Z", BLUE_D)
    a.shine("M84 362 L220 362", sw=6)
    c_waves(a, y=444, x0=20, x1=492, n=5, amp=11, depth=34)
    return a


@word
def booto():
    """A rowing boat seen from the side: a long low red hull with raised ends, a white stripe, a seat plank and two raised oars."""
    a = Art()
    with a.part():                                     # the hull
        a.sil("M22 212 C100 252 412 252 490 212 C486 286 446 344 382 352 L132 352 C66 344 26 286 22 212 Z", RED)
        a.blob("M30 248 C110 280 402 280 482 248 C480 262 478 274 474 286 C400 304 112 304 38 286 C34 274 32 262 30 248 Z", WHITE)
        a.blob("M70 330 C100 346 130 350 150 350 L378 350 C410 346 438 336 460 310 C430 334 404 340 380 340 L140 340 C110 340 90 336 70 330 Z", RED_D)
    with a.part(8):                                    # the seat plank
        a.sil(c_rpoly([(206, 206), (306, 206), (306, 244), (206, 244)], [6, 6, 0, 0]), WOOD)
    a.shine("M60 232 C100 250 160 258 210 258", sw=5)
    with a.part(8):                                    # oars raised from the seat
        a.sil(c_bar(212, 228, 74, 130, 13), WOOD_D)
        a.sil(e2_cap(74, 130, 40, 94, 44, 34), WOOD)
        a.sil(c_bar(300, 228, 438, 130, 13), WOOD_D)
        a.sil(e2_cap(438, 130, 472, 94, 44, 34), WOOD)
    c_waves(a, y=346, x0=14, x1=498, n=5, amp=11, depth=40)
    return a

@word
def baiku():
    """A motorbike seen from the side: two wheels, a red tank, a black seat, a headlight and an exhaust."""
    a = Art()
    DARKM = "#5d6572"
    for x in (126, 392):
        c_wheel(a, x, 372, 62)
    with a.part(8):                                    # the exhaust
        a.sil(taper([(238, 372, 190, 372, 120, 360, 70, 352)], 26, 40), "#aab3bb")
    with a.part(8):                                    # the rear arm and the front fork
        a.sil(c_bar(196, 336, 126, 372, 18), DARKM)
        a.sil(c_bar(352, 220, 392, 372, 20), "#aab3bb")
    with a.part(8):                                    # the front fender
        a.sil(taper([(342, 318, 366, 292, 440, 292, 462, 330)], 18, 14), RED_D)
    with a.part():                                     # engine, tank and seat
        a.sil(c_rpoly([(182, 292), (338, 292), (346, 392), (186, 396)], [10, 10, 24, 24]), DARKM)
        a.blob(c_circ(264, 350, 34), "#8b93a3")
        a.blob(c_circ(264, 350, 14), DARKM)
        a.sil("M184 258 C204 214 292 204 352 224 C364 252 346 294 334 304 L198 304 Z", RED)
        a.blob("M300 232 C340 236 356 250 346 286 L330 304 L300 304 Z", RED_D)
    with a.part(8):                                    # the seat
        a.sil("M96 266 C110 244 160 238 206 246 L200 292 L104 296 C96 290 94 278 96 266 Z", "#3d3f4a")
    with a.part(8):                                    # the handlebar and the headlight
        a.sil(c_bar(350, 214, 316, 190, 14), "#aab3bb")
        a.sil(c_circ(408, 258, 28, 26), YEL)
    a.path("M396 246 C400 240 408 236 416 238", stroke=WHITE, sw=6, **{"stroke-opacity": "0.8"})
    a.shine("M214 238 C236 228 270 224 300 228", sw=7)
    return a


@word
def monoreeru():
    """A monorail: a white train riding over one thick beam, held up by a pillar."""
    a = Art()
    with a.part():                                     # the pillar
        a.sil(c_rpoly([(210, 398), (302, 398), (312, 480), (200, 480)], [0, 0, 6, 6]), K_STEEL)
        a.blob("M280 398 L302 398 L312 480 L290 480 Z", K_STEEL_D)
    with a.part():                                     # the beam
        a.sil(c_rect(20, 352, 472, 52, 8), K_STONE)
        a.blob(c_rect(21, 386, 470, 17, 0), K_STONE_D)
    for x0, x1, nose in ((24, 252, False), (262, 484, True)):
        with a.part():
            if nose:
                a.sil("M262 222 L400 222 C446 222 484 262 484 322 L484 348 L262 348 Z", "#fbf8f2")
                a.blob(c_rect(263, 300, 220, 24, 0), K_ORANGE)
                a.blob(c_rect(263, 326, 220, 21, 0), "#e6dfd0")
            else:
                a.sil(c_rpoly([(24, 222), (252, 222), (252, 348), (24, 348)], [20, 6, 6, 20]), "#fbf8f2")
                a.blob(c_rect(25, 300, 226, 24, 0), K_ORANGE)
                a.blob(c_rect(25, 326, 226, 21, 0), "#e6dfd0")
    for x in (50, 128, 206):
        c_glass(a, c_rect(x, 244, 58, 42, 10), glint=(x + 8, 250, 18) if x == 50 else None)
    for x in (286, 360):
        c_glass(a, c_rect(x, 244, 58, 42, 10))
    c_glass(a, "M430 244 L446 244 C462 244 470 260 470 286 L430 286 Z", glint=(436, 252, 16))
    c_lamp(a, 470, 326, 8, 10)
    with a.part(6):                                    # wheels under the body
        for x in (66, 190, 330, 430):
            a.sil(c_rect(x, 346, 34, 16, 6), "#5d6572")
    a.shine("M44 232 L170 232", sw=6)
    return a


@word
def keeburukaa():
    """A funicular: one red car tilted on a steep mountain track, with the cable going up the slope."""
    a = Art()
    c, sn = math.cos(math.radians(30)), math.sin(math.radians(30))

    def P(s_, t_):
        return (40 + c * s_ - sn * t_, 410 - sn * s_ - c * t_)
    with a.part():                                     # the mountain
        a.sil(c_rpoly([P(-30, -2), P(540, -2), (500, 480), (14, 480)], [6, 6, 10, 10]), K_GREEN)
        a.blob(c_rpoly([P(300, -2), P(540, -2), (500, 480), (330, 480)], [0, 0, 6, 0]), K_GREEN_D)
    for k in range(0, 520, 40):                        # sleepers
        a.blob(c_rpoly([P(k, 0), P(k + 16, 0), P(k + 16, 14), P(k, 14)], 2), "#8a6a4a")
    with a.part(6):                                    # the rail
        a.sil(c_rpoly([P(-30, 8), P(540, 8), P(540, 24), P(-30, 24)], 4), "#5d6572")
    with a.part(5):                                    # the cable going up from the car
        a.sil(c_rpoly([P(300, 56), P(560, 56), P(560, 66), P(300, 66)], 3), "#3d3f4a")
    with a.part(8):                                    # the car
        a.sil(c_rpoly([P(110, 24), P(330, 24), P(330, 150), P(110, 150)], [10, 10, 24, 24]), RED)
        a.blob(c_rpoly([P(111, 24), P(329, 24), P(329, 44), P(111, 44)], 2), RED_D)
        a.blob(c_rpoly([P(111, 100), P(329, 100), P(329, 118), P(111, 118)], 0), WHITE)
    for s0 in (128, 224):
        c_glass(a, c_rpoly([P(s0, 64), P(s0 + 80, 64), P(s0 + 80, 112), P(s0, 112)], 8))
    for s0 in (150, 280):                              # the wheels
        x, y = P(s0, 22)
        c_wheel(a, x, y, 22)
    x, y = P(340, 62)
    a.dot(x, y, 10, "#8a949a")
    for tx, ty in ((330, 330), (426, 372)):             # small trees
        with a.part(7):
            a.sil(c_bar(tx, ty + 34, tx, ty + 70, 12), "#8a6a4a")
            a.sil(c_circ(tx, ty + 8, 30, 36), K_GREEN_D)
    return a

@word
def ropuwei():
    """A gondola hanging from a cable: a red cabin with big windows, a hanger and a pulley."""
    a = Art()
    a.path("M20 118 L492 76", stroke="#5d6572", sw=12)
    a.path("M20 118 L492 76", stroke="#8b93a3", sw=5)
    with a.part(8):                                    # the pulley and the hanger
        a.sil(c_circ(256, 98, 26), "#8a949a")
        a.sil(c_bar(256, 110, 256, 190, 18), "#5d6572")
    with a.part(8):
        a.sil(c_rpoly([(190, 170), (322, 170), (322, 194), (190, 194)], [10, 10, 0, 0]), "#5d6572")
    with a.part():                                     # the cabin
        a.sil("M120 206 C120 190 130 190 150 190 L362 190 C382 190 392 190 392 206 L404 350 C404 376 392 392 366 392 L146 392 C120 392 108 376 108 350 Z", RED)
        a.blob("M109 352 L403 352 C402 378 390 391 366 391 L146 391 C122 391 110 378 109 352 Z", RED_D)
        a.blob(c_rect(110, 318, 292, 20, 0), WHITE)
    c_glass(a, c_rpoly([(140, 216), (240, 216), (240, 306), (140, 306)], [14, 8, 4, 8]), glint=(150, 226, 26))
    c_glass(a, c_rpoly([(272, 216), (372, 216), (372, 306), (272, 306)], [8, 14, 8, 4]))
    a.shine("M130 202 L210 202", sw=6)
    return a


# ------------------------------------------------------------ まちの もの --
def k_windows(a, x0, y0, cols, rows, w, h, dx, dy, lit=(), col=SKY):
    for r in range(rows):
        for c in range(cols):
            x, y = x0 + c * dx, y0 + r * dy
            with a.part(5):
                a.sil(c_rect(x, y, w, h, 6), "#ffe58a" if (r, c) in lit else col)


@word
def biru():
    """A tall office building with a stepped roof, a grid of windows and a glass door."""
    a = Art()
    WALL, WALL_D = "#b7c6d8", "#98aac0"
    with a.part():                                     # the low wing and the tower
        a.sil(c_rpoly([(300, 230), (440, 230), (440, 470), (300, 470)], [6, 6, 0, 0]), "#c9d6e4")
        a.sil(c_rpoly([(100, 70), (330, 70), (330, 470), (100, 470)], [10, 10, 0, 0]), WALL)
        a.blob("M290 72 L330 72 L330 470 L290 470 Z", WALL_D)
    with a.part(7):                                    # the roof box and the antenna
        a.sil(c_rpoly([(160, 40), (270, 40), (270, 72), (160, 72)], [8, 8, 0, 0]), K_STEEL)
    with a.part(5):
        a.sil(c_bar(215, 10, 215, 42, 8), "#8a949a")
    k_windows(a, 122, 100, 3, 5, 50, 38, 70, 56, lit={(1, 1), (3, 0), (2, 2)})
    k_windows(a, 322, 252, 2, 3, 44, 34, 58, 56, lit={(1, 0)})
    with a.part(7):                                    # the door
        a.sil(c_rpoly([(176, 410), (254, 410), (254, 470), (176, 470)], [10, 10, 0, 0]), SKY)
    c_line(a, 215, 414, 215, 468, 5)
    a.path("M120 90 L120 380", stroke=WHITE, sw=5, **{"stroke-opacity": "0.5"})
    return a


@word
def hoteru():
    """A hotel: a tall slim rose-coloured tower with balconies, a striped awning and a navy bed sign on top."""
    a = Art()
    with a.part(8):                                    # the roof sign (a bed on navy)
        a.sil(c_rpoly([(150, 30), (362, 30), (362, 104), (150, 104)], [16, 16, 0, 0]), NAVY)
    a.blob(c_rect(172, 70, 168, 16, 4), WHITE)         # the mattress
    a.blob(c_rect(166, 46, 12, 42, 4), WHITE)          # the head board
    a.blob(c_rect(184, 52, 38, 18, 8), "#ffd1dc")      # the pillow
    a.blob(c_rect(334, 58, 12, 30, 4), WHITE)          # the foot board
    with a.part():
        a.sil(c_rpoly([(168, 104), (344, 104), (344, 470), (168, 470)], [8, 8, 0, 0]), "#f4a6b8")
        a.blob(c_rect(316, 106, 27, 362, 0), "#dd8aa0")
        a.blob(c_rect(169, 102, 174, 20, 0), "#b65a76")
    for r in range(5):
        for c in range(2):
            x, y = 190 + c * 74, 138 + r * 52
            with a.part(5):
                a.sil(c_rect(x, y, 54, 30, 6), "#ffe58a" if (r, c) in ((1, 0), (3, 1)) else SKY)
            a.blob(c_rect(x - 5, y + 30, 64, 9, 3), "#fff0f4")
    with a.part(8):                                    # the striped awning over the door
        a.sil("M196 392 L316 392 L332 428 L180 428 Z", NAVY)
        a.blob("M216 392 L240 392 L236 428 L208 428 Z", WHITE)
        a.blob("M272 392 L296 392 L304 428 L276 428 Z", WHITE)
    with a.part(7):
        a.sil(c_rpoly([(224, 428), (288, 428), (288, 470), (224, 470)], [10, 10, 0, 0]), SKY)
    c_line(a, 256, 432, 256, 468, 5)
    return a

@word
def depaato():
    """A department store: a wide building with arched windows, hanging banners, flags on the roof and a big entrance."""
    a = Art()
    for x, col in ((120, RED), (392, BLUE)):           # rooftop flags
        with a.part(5):
            a.sil(c_bar(x, 36, x, 120, 8), "#8a949a")
        with a.part(6):
            a.sil(c_rpoly([(x, 36), (x + 62, 54), (x, 72)], [0, 6, 0]), col)
    with a.part():
        a.sil(c_rpoly([(40, 110), (472, 110), (472, 470), (40, 470)], [12, 12, 0, 0]), "#f4c9a0")
        a.blob(c_rect(441, 112, 30, 358, 0), "#e0ac82")
        a.blob(c_rect(41, 108, 430, 24, 0), "#e5534b")
    for c in range(5):                                 # arched windows
        x = 70 + c * 76
        with a.part(5):
            a.sil(f"M{x} 234 L{x} 196 C{x} 166 {x + 50} 166 {x + 50} 196 L{x + 50} 234 Z", SKY)
    for x, col in ((88, "#4fa8e0"), (178, "#7cc36a"), (268, "#f7c948"), (358, "#e5534b")):   # banners
        with a.part(6):
            a.sil(f"M{x} 262 L{x + 58} 262 L{x + 58} 340 L{x + 29} 322 L{x} 340 Z", col)
    with a.part(8):                                    # the entrance with a canopy
        a.sil(c_rpoly([(160, 376), (352, 376), (366, 410), (146, 410)], [6, 6, 0, 0]), "#f7c948")
    with a.part(7):
        a.sil(c_rpoly([(176, 410), (336, 410), (336, 470), (176, 470)], [10, 10, 0, 0]), SKY)
    c_line(a, 256, 414, 256, 468, 5)
    c_line(a, 216, 414, 216, 468, 4)
    c_line(a, 296, 414, 296, 468, 4)
    return a


@word
def tawaa():
    """A tall observation tower: slim legs, a round deck, a thin tower and a spire with a red tip."""
    a = Art()
    with a.part(8):                                    # the spire
        a.sil(taper([(256, 40, 256, 70, 256, 100, 256, 150)], 8, 18), "#d65a52")
    with a.part():                                     # the upper tower
        a.sil("M240 146 L272 146 L286 250 L226 250 Z", WHITE)
        a.blob("M262 146 L272 146 L286 250 L270 250 Z", "#e6edf3")
    with a.part(8):                                    # the small deck
        a.sil(c_circ(256, 196, 40, 16), "#d65a52")
    with a.part(8):                                    # the big deck
        a.sil(c_circ(256, 262, 66, 22), "#4fa8e0")
        a.blob(c_rect(190, 258, 132, 24, 0), SKY)
    with a.part():                                     # the lower tower and legs
        a.sil("M226 280 L286 280 L300 350 L330 470 L276 470 L256 380 L236 470 L182 470 L212 350 Z", WHITE)
        a.blob("M270 280 L286 280 L300 350 L330 470 L300 470 L282 360 Z", "#e6edf3")
    with a.part(8):
        a.sil(c_rpoly([(160, 462), (352, 462), (352, 482), (160, 482)], [6, 6, 8, 8]), "#8f9aa5")
    for x in (228, 256, 284):
        a.dot(x, 262, 6, WHITE)
    return a


@word
def tonneru():
    """A tunnel: a green hill with a stone arch, a dark opening and a road coming out."""
    a = Art()
    with a.part():                                     # the mountain
        a.sil("M20 446 C50 350 130 250 206 150 C226 120 286 120 306 150 C382 250 462 350 492 446 Z", GREEN)
        a.blob("M340 196 C410 280 462 364 492 446 L436 446 C420 370 380 290 320 220 Z", K_GREEN_D)
        a.blob("M206 150 C226 120 286 120 306 150 C316 164 326 178 336 192 C318 176 300 184 280 170 C262 182 244 176 226 190 C214 178 208 160 206 150 Z", WHITE)
    for x, y in ((74, 396), (440, 396)):               # small trees
        with a.part(7):
            a.sil(c_bar(x, y, x, y + 46, 14), "#8a6a4a")
            a.sil("M%d %d C%d %d %d %d %d %d C%d %d %d %d %d %d Z" % (x - 36, y + 10, x - 36, y - 40, x - 10, y - 66, x, y - 76, x + 10, y - 66, x + 36, y - 40, x + 36, y + 10), K_GREEN_D)
    with a.part(8):                                    # the arch
        a.sil("M150 446 L150 350 C150 286 196 252 256 252 C316 252 362 286 362 350 L362 446 Z", K_STONE)
    with a.part(6):                                    # the opening
        a.sil("M184 446 L184 356 C184 314 214 290 256 290 C298 290 328 314 328 356 L328 446 Z", "#3c4658")
    a.blob("M210 446 L220 360 C222 334 238 322 256 322 C274 322 290 334 292 360 L302 446 Z", "#4d5870")
    a.dot(256, 350, 12, "#ffe58a")
    with a.part(8):                                    # the road
        a.sil("M140 446 L372 446 L452 490 L60 490 Z", "#6b7480")
    a.blob("M242 458 L270 458 L278 474 L234 474 Z", WHITE)
    return a


@word
def posuto():
    """A red post box: a round-topped red body, a mail slot with a flap, a small door and a stand."""
    a = Art()
    with a.part(8):
        a.sil(c_rpoly([(160, 440), (352, 440), (362, 470), (150, 470)], [4, 4, 8, 8]), "#8f9aa5")
    with a.part():
        a.sil("M150 440 L150 170 C150 100 198 58 256 58 C314 58 362 100 362 170 L362 440 Z", RED)
        a.blob("M318 66 C350 96 362 130 362 170 L362 440 L328 440 L328 170 C328 126 320 96 300 62 Z", RED_D)
    with a.part(8):                                    # the mail slot with its flap
        a.sil(c_rpoly([(180, 150), (332, 150), (332, 196), (180, 196)], [16, 16, 16, 16]), "#3d3f4a")
    with a.part(7):
        a.sil(c_rpoly([(172, 136), (340, 136), (344, 166), (168, 166)], [14, 14, 6, 6]), RED_D)
    with a.part(7):                                    # the small door
        a.sil(c_rpoly([(196, 300), (316, 300), (316, 420), (196, 420)], [10, 10, 6, 6]), "#e5534b")
    a.blob(c_rect(210, 316, 92, 12, 4), "#d4413a")
    with a.part(5):                                    # the white envelope mark
        a.sil(c_rect(222, 224, 68, 46, 6), WHITE)
    a.path("M224 230 L256 252 L288 230", stroke=GREY, sw=5)
    a.dot(298, 380, 7, YEL)
    a.shine("M174 130 C178 106 192 86 212 76", sw=7)
    return a


@word
def benchi():
    """A park bench seen from the front: a slatted back, a slatted seat, arm rests and metal legs."""
    a = Art()
    with a.part(8):                                    # legs and arm rests
        a.sil(c_rpoly([(78, 214), (110, 214), (110, 450), (78, 450)], [6, 6, 8, 8]), "#6b7b8a")
        a.sil(c_rpoly([(402, 214), (434, 214), (434, 450), (402, 450)], [6, 6, 8, 8]), "#6b7b8a")
        a.sil(c_bar(58, 258, 130, 258, 22), "#6b7b8a")
        a.sil(c_bar(382, 258, 454, 258, 22), "#6b7b8a")
    for y in (100, 148, 196):                          # the back slats
        with a.part(8):
            a.sil(c_rpoly([(54, y), (458, y), (458, y + 40), (54, y + 40)], [14, 14, 14, 14]), WOOD)
        a.blob(c_rect(60, y + 26, 392, 10, 4), WOOD_D)
    for y in (296, 348):                               # the seat slats
        with a.part(8):
            a.sil(c_rpoly([(46, y), (466, y), (466, y + 44), (46, y + 44)], [14, 14, 14, 14]), WOOD)
        a.blob(c_rect(52, y + 30, 408, 10, 4), WOOD_D)
    a.shine("M76 112 L220 112", sw=5)
    return a


# ------------------------------------------------------- スポーツ・あそび --
def k_pol(r, deg, cx=256, cy=256):
    return cx + r * math.cos(math.radians(deg)), cy + r * math.sin(math.radians(deg))


@word
def booru():
    """A ball: white with dark patches and thin seams (the classic football pattern)."""
    a = Art()
    Rr = 190
    face = d_circ(256, 256, Rr)
    with a.part():
        a.sil(face, WHITE)
        a.blob(d_rim(face, 40, 80, 30), "#dde5ee")
        a.blob(c_rpoly([k_pol(60, -90 + 72 * i) for i in range(5)], 10), NAVY)
        for i in range(5):
            phi = -90 + 72 * i
            pts = [k_pol(112, phi), k_pol(148, phi + 28), k_pol(184, phi + 14), k_pol(184, phi - 14), k_pol(148, phi - 28)]
            a.blob(c_rpoly(pts, 8), NAVY)
    for i in range(5):
        phi = -90 + 72 * i
        (x0, y0), (x1, y1) = k_pol(58, phi), k_pol(112, phi)
        a.ink([e2_seg(x0, y0, x1, y1)], 7, a=1, b=1)
        (x0, y0), (x1, y1) = k_pol(150, phi + 29), k_pol(150, phi + 43)
        a.ink([e2_seg(x0, y0, x1, y1)], 7, a=1, b=1)
    a.shine("M120 160 C140 118 180 88 226 76", sw=9)
    return a


@word
def toranporin():
    """A trampoline: a round blue mat with a red pad, springs around it and short legs."""
    a = Art()
    with a.part(8):                                    # back legs
        for x in (166, 346):
            a.sil(c_rpoly([(x - 14, 290), (x + 14, 290), (x + 14, 410), (x - 14, 410)], [4, 4, 8, 8]), K_DARK)
    with a.part(8):                                    # front legs
        for x in (96, 416):
            a.sil(c_rpoly([(x - 18, 296), (x + 18, 296), (x + 20, 452), (x - 20, 452)], [4, 4, 10, 10]), "#8f9aa5")
    with a.part():
        a.sil(d_circ(256, 262, 228, 84), RED)
        a.blob(d_circ(256, 258, 200, 66), "#c5ccd4")
        a.blob("M30 270 C40 320 120 346 256 346 C392 346 472 320 482 270 C470 302 390 326 256 326 C122 326 42 302 30 270 Z", RED_D)
    for i in range(30):                                # springs
        t = math.radians(i * 12)
        x0, y0 = 256 + 168 * math.cos(t), 258 + 56 * math.sin(t)
        x1, y1 = 256 + 196 * math.cos(t), 258 + 65 * math.sin(t)
        a.ink([e2_seg(x0, y0, x1, y1)], 6, a=1, b=1, col="#5d6572")
    with a.part(6):
        a.sil(d_circ(256, 258, 168, 56), BLUE)
    a.blob(d_circ(236, 246, 100, 22), "#8ccdf5")
    a.shine("M70 240 C90 214 140 200 190 196", sw=8)
    return a


@word
def sukii():
    """A pair of skis with two poles: red and blue skis with bindings, yellow grips and round baskets."""
    a = Art()
    POLE = "#5d6572"
    for x, deg in ((96, -22), (416, -22)):            # the poles, leaning the other way
        with a.part(6):
            a.sil(R(c_bar(x, 56, x, 462, 11), deg), POLE)
        with a.part(6):
            a.sil(R(c_rpoly([(x - 14, 44), (x + 14, 44), (x + 14, 130), (x - 14, 130)], [10, 10, 8, 8]), deg), YEL2)
        with a.part(6):
            a.sil(R(d_circ(x, 414, 30, 11), deg), "#8f9aa5")
    for x, col, dark in ((206, RED, RED_D), (306, BLUE, BLUE_D)):
        cub = [(x, 474, x, 320, x, 160, x + 6, 90), (x + 6, 90, x + 8, 60, x + 24, 44, x + 52, 40)]
        with a.part():
            a.sil(R(taper(cub, 40, 20), 18), col)
        with a.part(6):
            a.sil(R(c_rpoly([(x - 24, 280), (x + 24, 280), (x + 24, 340), (x - 24, 340)], [12, 12, 10, 10]), 18), K_DARK)
    return a


@word
def raketto():
    """A tennis racket with a string net and a tennis ball."""
    a = Art()
    DEG = -36
    FR, HAND = "#e5534b", "#3d3f4a"
    outer, inner = d_circ(256, 160, 104, 132), d_circ(256, 160, 80, 108)
    # the head ring: an outer ellipse with the inner one cut out (drawn the other way round)
    ring = R(outer, DEG, 256, 260) + " " + R(c_circ(256, 160, 80, 108, ccw=True), DEG, 256, 260)
    a.blob(R(inner, DEG, 256, 260), "#eaf6ff")
    with a.part():
        a.sil(ring, FR)
        a.sil(R("M214 268 L298 268 L276 352 L236 352 Z", DEG, 256, 260), FR)
    for i in range(-3, 4):                             # strings
        k_line(a, 256 + i * 22, 70, 256 + i * 22, 250, 4, 1, 1, "#8f9aa5", DEG, 256, 260)
    for j in range(-3, 4):
        y = 160 + j * 30
        half = 78 * math.sqrt(max(0.0, 1 - ((y - 160) / 106) ** 2))
        k_line(a, 256 - half, y, 256 + half, y, 4, 1, 1, "#8f9aa5", DEG, 256, 260)
    with a.part():
        a.sil(R(c_rpoly([(236, 346), (276, 346), (280, 468), (232, 468)], [4, 4, 14, 14]), DEG, 256, 260), HAND)
    for y in (368, 392, 416, 440):
        k_line(a, 238, y, 276, y + 10, 5, 1, 1, "#8f9aa5", DEG, 256, 260)
    with a.part():                                     # the ball
        a.sil(c_circ(392, 418, 46), "#d9e84f")
    a.path("M356 402 C380 420 382 444 366 454", stroke=WHITE, sw=7)
    a.path("M428 388 C406 404 404 428 420 446", stroke=WHITE, sw=7)
    return a


@word
def guroobu():
    """A baseball glove (brown leather, laces, a wrist strap) holding a ball."""
    a = Art()
    LEA, LEA_D, LACE = "#cd8545", "#a8672f", "#6e4320"
    fingers = [((148, 286), (120, 112)), ((214, 276), (196, 76)), ((282, 276), (278, 80)), ((346, 286), (358, 112))]
    palm = smooth([(112, 276), (388, 276), (420, 370), (386, 452), (300, 480), (216, 480), (132, 452), (98, 370)])
    with a.part():
        for (bx, by), (tx, ty) in fingers:
            a.sil(e2_cap(bx, by, tx, ty, 66, 58), LEA)
        a.sil(e2_cap(410, 380, 458, 236, 70, 58), LEA)  # the thumb
        a.sil(palm, LEA)
        a.blob(d_circ(256, 366, 104, 80), LEA_D)
    for (bx, by), (tx, ty) in fingers:                 # laces on the finger tips
        a.ink([e2_seg(bx + (tx - bx) * 0.2, by + (ty - by) * 0.2 + 0, tx - (tx - bx) * 0.05, ty + 30)], 7, a=0.6, b=0.2, col=LACE)
    with a.part(7):                                    # the strap
        a.sil(c_rpoly([(150, 440), (362, 440), (352, 474), (160, 474)], [6, 6, 10, 10]), "#7a4a22")
    a.dot(256, 458, 8, YEL)
    with a.part():                                     # the ball
        a.sil(c_circ(256, 370, 48), WHITE)
    a.path("M222 340 C240 360 240 384 222 402", stroke=RED, sw=6)
    a.path("M290 340 C272 360 272 384 290 402", stroke=RED, sw=6)
    a.shine("M110 300 L112 250", sw=7)
    return a


# ------------------------------------------------------------------- がっき --
@word
def piano():
    """An upright piano seen from the front: a dark case, a music sheet, white and black keys, two legs."""
    a = Art()
    BODY, BODY_D = "#4a5163", "#383e4d"
    with a.part(8):
        for x in (66, 410):
            a.sil(c_rpoly([(x, 380), (x + 36, 380), (x + 36, 470), (x, 470)], [0, 0, 8, 8]), BODY_D)
    with a.part(8):                                    # the pedals
        for x in (224, 270):
            a.sil(c_rpoly([(x, 386), (x + 18, 386), (x + 22, 430), (x - 4, 430)], [4, 4, 8, 8]), K_YEL)
    with a.part():
        a.sil(c_rpoly([(36, 56), (476, 56), (476, 96), (36, 96)], [10, 10, 4, 4]), "#5d6580")
        a.sil(c_rpoly([(50, 96), (462, 96), (462, 392), (50, 392)], [0, 0, 14, 14]), BODY)
        a.blob(c_rect(426, 98, 36, 292, 0), BODY_D)
        a.blob(c_rect(126, 112, 260, 92, 10), BODY_D)
    with a.part(6):                                    # the music sheet
        a.sil(c_rpoly([(176, 118), (336, 118), (336, 198), (176, 198)], [4, 4, 4, 4]), WHITE)
    for y in (138, 152, 166):
        a.ink([e2_seg(190, y, 322, y)], 4, a=1, b=1, col="#8f9aa5")
    for x, y in ((204, 166), (236, 152), (268, 138), (300, 152)):
        a.dot(x, y, 7, NAVY)
        a.ink([e2_seg(x + 6, y, x + 6, y - 30)], 4, a=1, b=1, col=NAVY)
    with a.part(6):                                    # the keys
        a.sil(c_rpoly([(70, 226), (442, 226), (442, 340), (70, 340)], [2, 2, 12, 12]), WHITE)
    for i in range(1, 14):
        x = 70 + i * 372 / 14
        a.ink([e2_seg(x, 232, x, 336)], 4, a=1, b=1, col="#8f9aa5")
    for i in (0, 1, 3, 4, 5, 7, 8, 10, 11, 12):
        x = 70 + (i + 1) * 372 / 14
        a.blob(c_rect(x - 9, 226, 18, 66, 4), "#2c2f3a")
    a.shine("M62 108 L190 108", sw=6)
    return a


@word
def gitaa():
    """An acoustic guitar leaning to the side: a wooden body, a round sound hole, a long neck and tuning pegs."""
    a = Art()
    DEG = 32
    BODY, BODY_D, NECK = "#e59a4c", "#c97f3e", "#6e4320"
    half = [(310, 232), (338, 270), (326, 318), (304, 346), (310, 372), (346, 408), (364, 452), (336, 488)]
    pts = [(256, 224)] + half + [(256, 498)] + [(512 - x, y) for x, y in reversed(half)]
    body = smooth(pts)
    with a.part(8):                                    # neck and headstock
        a.sil(R(c_rpoly([(236, 50), (276, 50), (276, 260), (236, 260)], [0, 0, 0, 0]), DEG), NECK)
        a.sil(R(c_rpoly([(226, 4), (286, 4), (284, 66), (228, 66)], [14, 14, 6, 6]), DEG), "#4a3428")
    with a.part():
        a.sil(R(body, DEG), BODY)
        a.blob(R(c_circ(256, 372, 44), DEG), BODY_D)
    with a.part(6):                                    # the sound hole
        a.sil(R(c_circ(256, 372, 32), DEG), "#3c2f2a")
    with a.part(6):                                    # the bridge
        a.sil(R(c_rpoly([(212, 440), (300, 440), (300, 460), (212, 460)], [6, 6, 6, 6]), DEG), "#4a3428")
    for dx in (-10, -4, 2, 8):                         # strings
        k_line(a, 256 + dx, 40, 256 + dx * 2.2, 446, 3, 1, 1, "#f1f1f1", DEG)
    for y in (96, 140, 184, 228):                      # frets
        k_line(a, 238, y, 274, y, 4, 1, 1, "#d8d2cc", DEG)
    for dy in (14, 34, 54):                            # tuning pegs
        for dx in (-34, 34):
            x, y = RP(256 + dx, dy + 4, DEG)
            a.dot(x, y, 9, "#e8dfcf")
    return a


@word
def kasutanetto():
    """Castanets: a red shell above a blue shell joined at the left, with a white elastic loop."""
    a = Art()
    with a.part(8):                                    # the elastic loop
        a.sil(d_circ(60, 340, 40, 58), "#fff0d4")
    a.blob(d_circ(60, 340, 22, 38), "#ffffff")
    a.blob("M52 306 C46 326 46 354 52 374 C36 362 34 318 52 306 Z", "#d8d2cc")
    with a.part():                                     # the lower shell
        a.sil("M62 286 L452 286 C452 370 372 414 257 414 C142 414 62 370 62 286 Z", BLUE)
        a.blob("M62 286 L452 286 C452 296 451 304 449 312 L65 312 C63 304 62 296 62 286 Z", "#8ccdf5")
        a.blob(d_circ(257, 300, 168, 12), BLUE_D)
        a.blob("M90 352 C130 392 190 408 257 408 C330 408 390 390 424 350 C386 380 330 392 257 392 C180 392 126 380 90 352 Z", BLUE_D)
    with a.part():                                     # the upper shell, a little open on the right
        a.sil(R("M62 266 C62 186 142 140 257 140 C372 140 452 186 452 266 Z", -10, 64, 270), RED)
        a.blob(R("M62 266 L452 266 C452 258 451 252 449 246 L65 246 C63 252 62 258 62 266 Z", -10, 64, 270), "#ffb3ab")
        a.blob(R("M300 150 C390 160 448 200 452 266 L420 266 C416 210 372 168 300 150 Z", -10, 64, 270), RED_D)
    a.dot(96, 290, 9, "#fff0d4")
    a.shine(R("M110 214 C140 180 190 162 240 158", -10, 64, 270), sw=9)
    return a


@word
def robotto():
    """A friendly robot: a square head with a screen face and an antenna, a chest panel, claw arms and short legs."""
    a = Art()
    SIL, SIL_D, BL = "#cdd8e6", "#a9b9cc", "#4a9fe0"
    with a.part(8):                                    # the arms
        a.sil(c_bar(150, 270, 92, 346, 36), SIL_D)
        a.sil(c_bar(362, 270, 420, 346, 36), SIL_D)
    with a.part(8):
        a.sil(c_circ(84, 364, 28), RED)
        a.sil(c_circ(428, 364, 28), RED)
    with a.part(8):                                    # the legs
        a.sil(c_rpoly([(186, 410), (240, 410), (240, 456), (186, 456)], [0, 0, 6, 6]), SIL_D)
        a.sil(c_rpoly([(272, 410), (326, 410), (326, 456), (272, 456)], [0, 0, 6, 6]), SIL_D)
        a.sil(c_rpoly([(166, 448), (252, 448), (252, 480), (166, 480)], [12, 12, 12, 12]), K_DARK)
        a.sil(c_rpoly([(260, 448), (346, 448), (346, 480), (260, 480)], [12, 12, 12, 12]), K_DARK)
    with a.part():                                     # the body
        a.sil(c_rpoly([(146, 240), (366, 240), (366, 420), (146, 420)], [20, 20, 28, 28]), SIL)
        a.blob(c_rect(330, 242, 35, 176, 0), SIL_D)
    with a.part(6):
        a.sil(c_rpoly([(186, 266), (326, 266), (326, 356), (186, 356)], [14, 14, 14, 14]), BL)
    for x, col in ((218, RED), (256, YEL), (294, GREEN)):
        a.dot(x, 302, 12, col)
    a.blob(c_rect(206, 330, 100, 10, 4), WHITE)
    with a.part(7):                                    # the neck and the antenna
        a.sil(c_rect(232, 222, 48, 26, 4), SIL_D)
        a.sil(c_bar(256, 90, 256, 52, 10), "#8f9aa5")
        a.sil(c_circ(256, 40, 18), RED)
    with a.part():                                     # the head
        a.sil(c_rpoly([(150, 86), (362, 86), (362, 230), (150, 230)], [34, 34, 22, 22]), SIL)
        a.blob(c_rect(330, 90, 31, 138, 0), SIL_D)
        a.sil(c_rpoly([(130, 128), (150, 128), (150, 188), (130, 188)], [6, 0, 0, 6]), SIL_D)
        a.sil(c_rpoly([(362, 128), (382, 128), (382, 188), (362, 188)], [0, 6, 6, 0]), SIL_D)
    with a.part(6):
        a.sil(c_rpoly([(172, 112), (340, 112), (340, 206), (172, 206)], [24, 24, 24, 24]), "#2f4a78")
    for x in (222, 290):
        a.eye(x, 156, 15)
    a.path("M238 184 C246 194 266 194 274 184", stroke="#8ef0ff", sw=6)
    a.shine("M166 100 L250 100", sw=6)
    return a


# ---------------------------------------------------------------- いえの物 --
@word
def taoru():
    """A soft towel hung over a bar: a long front panel with two stripes, a shorter back panel and a fringe."""
    a = Art()
    with a.part(7):                                    # the towel bar with end caps
        a.sil(c_bar(40, 96, 472, 96, 22), "#8f9aa5")
        a.sil(c_circ(40, 96, 22), "#6b7480")
        a.sil(c_circ(472, 96, 22), "#6b7480")
    with a.part():                                     # the back panel (a little shorter, shifted right)
        a.sil("M214 100 C222 160 206 230 222 300 C230 330 224 352 232 372 L356 378 C366 340 350 330 364 296 "
              "C378 240 366 160 372 100 Z", "#8ccdf5")
        a.blob("M330 110 C338 180 334 250 340 330 L360 340 C372 290 356 240 368 180 L368 110 Z", "#6fb8e8")
    with a.part():                                     # the front panel hanging in front
        a.sil("M120 98 C112 170 128 250 120 320 C116 360 126 392 118 428 C150 440 190 424 226 436 "
              "C262 446 296 428 330 436 C344 410 336 380 346 346 C356 300 340 230 350 170 C354 140 348 118 340 98 Z", "#4fa8e0")
        a.blob("M300 104 C312 180 304 250 312 330 C318 372 312 410 326 432 L336 434 C346 410 338 380 348 346 C358 300 342 230 352 170 C356 140 348 118 340 98 Z", "#3f97d0")
        a.blob(c_rect(110, 340, 252, 24, 0), WHITE)
        a.blob(c_rect(110, 374, 252, 14, 0), K_ORANGE)
    for i in range(12):                                # fringe
        x = 126 + i * 19
        a.ink([e2_seg(x, 430, x + (i % 3 - 1) * 3, 462)], 7, a=1, b=0.4, col=O)
    a.blob("M120 98 C122 112 340 112 342 98 L342 126 C330 140 130 140 120 126 Z", "#6fb8e8")
    for x, y in ((160, 196), (210, 250), (264, 206), (180, 296), (258, 290)):   # pile texture
        a.ink([e2_seg(x, y, x + 16, y + 6)], 6, a=0.4, b=0.4, col="#3a84c4")
    a.shine("M140 150 C136 200 144 250 138 300", sw=7)
    return a

@word
def kureyon():
    """Three crayons standing like a fan: red, blue and yellow, each with a paper wrapper and a round tip."""
    a = Art()

    def crayon(cx, base, h, deg, col, tint, dark):
        w2 = 38
        tip = base - h
        with a.part():
            a.sil(R(c_rpoly([(cx - w2, tip + 70), (cx + w2, tip + 70), (cx + w2, base), (cx - w2, base)], [0, 0, 8, 8]), deg, cx, base), tint)
            a.sil(R(f"M{cx - w2} {tip + 72} L{cx - 28} {tip + 22} C{cx - 20} {tip - 14} {cx + 20} {tip - 14} {cx + 28} {tip + 22} L{cx + w2} {tip + 72} Z", deg, cx, base), col)
            a.blob(R(c_rect(cx - w2 + 1, tip + 130, 2 * w2 - 2, 120, 0), deg, cx, base), WHITE)
            a.blob(R(c_rect(cx + 14, tip + 74, 24, h - 74, 0), deg, cx, base), dark)
        for k in range(3):
            y = tip + 160 + k * 30
            (x0, y0), (x1, y1) = RP(cx - 24, y, deg, cx, base), RP(cx + 8, y, deg, cx, base)
            a.ink([e2_seg(x0, y0, x1, y1)], 6, a=1, b=1, col=col)
        (x0, y0), (x1, y1) = RP(cx - w2 + 6, tip + 80, deg, cx, base), RP(cx - w2 + 6, tip + 125, deg, cx, base)
        a.path(f"M{x0:.1f} {y0:.1f} L{x1:.1f} {y1:.1f}", stroke=WHITE, sw=6, **{"stroke-opacity": "0.7"})
    crayon(140, 470, 330, -20, BLUE, "#86c4ee", BLUE_D)
    crayon(372, 470, 330, 20, YEL2, "#fadc84", "#e0a92a")
    crayon(256, 480, 420, 0, RED, "#f0827b", RED_D)
    return a
