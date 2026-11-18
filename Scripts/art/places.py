"""まちの地図の場所の絵（SVG）。words.py と同じ決まり（平らな色・輪郭・丸い角・白い光を1つ）。"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "Content", "Art", "places")
sys.path.insert(0, HERE)
from lib import Art, mirror, O, EYE  # noqa: E402

RED, RED_D = "#e5534b", "#c9403a"
YEL, YEL2 = "#f6d36b", "#f7c948"
BLUE, BLUE_D, SKY = "#4fa8e0", "#3f97d0", "#bfe6fa"
WOOD, WOOD_D = "#f2b56b", "#c97f3e"
PINK, CHEEK = "#f7b3bd", "#ff9aa8"
GREEN, GREEN_D = "#7cc36a", "#5fae56"
CREAM, WHITE = "#fff4e2", "#ffffff"
GREY, GREY_L = "#8f8a86", "#d8d2cc"
NAVY = "#34507e"
ORANGE = "#f59a4a"

P = {}


def place(f):
    P[f.__name__] = f
    return f


def grass(a, cx=256, cy=420, rx=215, ry=46, col=GREEN):
    a.ellipse(cx, cy, rx, ry, col)


def cloud(a, x, y, s=1.0, fill=WHITE):
    d = (f"M{x-60*s} {y+22*s} C{x-86*s} {y+22*s} {x-90*s} {y-18*s} {x-56*s} {y-18*s} "
         f"C{x-52*s} {y-52*s} {x-4*s} {y-58*s} {x+8*s} {y-30*s} C{x+30*s} {y-52*s} {x+74*s} {y-34*s} {x+62*s} {y-4*s} "
         f"C{x+92*s} {y-2*s} {x+86*s} {y+22*s} {x+60*s} {y+22*s} Z")
    a.path(d, fill=fill)


def tree(a, x, y, s=1.0, crown=GREEN):
    a.rect(x - 12 * s, y - 30 * s, 24 * s, 60 * s, "#b8794a", rx=6 * s)
    a.circle(x, y - 62 * s, 54 * s, crown)
    a.circle(x - 36 * s, y - 30 * s, 34 * s, crown)
    a.circle(x + 36 * s, y - 30 * s, 34 * s, crown)
    a.circle(x, y - 62 * s, 54 * s, crown, sw=0, stroke="none")
    a.circle(x - 36 * s, y - 30 * s, 34 * s, crown, sw=0, stroke="none")
    a.circle(x + 36 * s, y - 30 * s, 34 * s, crown, sw=0, stroke="none")


def star(a, cx, cy, r, fill=YEL):
    k = r * 0.38
    a.path(f"M{cx} {cy-r} L{cx+k} {cy-k} L{cx+r} {cy} L{cx+k} {cy+k} L{cx} {cy+r} L{cx-k} {cy+k} "
           f"L{cx-r} {cy} L{cx-k} {cy-k} Z", fill=fill, sw=7)


@place
def eki():
    a = Art()
    # ホームと線路
    a.rect(60, 372, 392, 30, GREY_L, rx=10)
    a.rect(60, 402, 392, 26, GREY, rx=10)
    # たてもの
    a.rect(110, 210, 292, 164, CREAM, rx=14)
    a.path("M92 218 L256 118 L420 218 Z", fill=RED)
    a.path("M92 218 L420 218", sw=11)
    # とけい
    a.circle(256, 184, 36, WHITE)
    a.path("M256 184 L256 162 M256 184 L272 192", sw=9)
    # ドアと窓
    a.path("M222 374 L222 296 C222 270 290 270 290 296 L290 374 Z", fill=BLUE)
    a.path("M256 276 L256 374", sw=8)
    a.rect(132, 252, 62, 54, SKY, rx=10)
    a.rect(318, 252, 62, 54, SKY, rx=10)
    # きっぷの目印の旗
    a.shine("M138 232 C160 226 176 226 190 230")
    return a


@place
def michi():
    a = Art()
    # あるくところ
    a.rect(50, 226, 412, 120, GREY_L, rx=20)
    # みち（よこだん）
    a.rect(50, 320, 412, 112, GREY, rx=22)
    for x in (92, 188, 284, 380):
        a.rect(x, 366, 60, 16, WHITE, rx=7, sw=0, stroke="none")
    # ポスト
    a.rect(98, 120, 92, 160, RED, rx=34)
    a.rect(98, 120, 92, 44, RED_D, rx=22)
    a.rect(116, 188, 56, 12, O, rx=5, sw=0, stroke="none")
    a.rect(124, 230, 40, 26, CREAM, rx=6, sw=8)
    a.rect(110, 280, 68, 22, GREY, rx=8)
    # しんごう
    a.rect(364, 190, 16, 130, GREY, rx=6)
    a.rect(330, 60, 84, 150, "#5a4a42", rx=24)
    a.circle(372, 98, 19, RED, sw=6)
    a.circle(372, 134, 19, YEL, sw=6)
    a.circle(372, 170, 19, GREEN, sw=6)
    a.shine("M116 140 L116 206", sw=7)
    return a


@place
def sora():
    a = Art()
    # にじ
    arcs = ((196, RED), (164, ORANGE), (132, YEL), (100, GREEN), (68, BLUE))
    a.path("M60 372 A196 196 0 0 1 452 372", sw=64, stroke=O)
    for r, col in arcs:
        a.path(f"M{256-r} 372 A{r} {r} 0 0 1 {256+r} 372", stroke=col, sw=28)
    # くも
    cloud(a, 120, 366, 1.1)
    cloud(a, 396, 372, 1.0)
    a.shine("M70 350 C74 338 86 330 98 328")
    return a


@place
def dobutsuen():
    a = Art()
    # きりん
    a.rect(206, 150, 100, 270, YEL, rx=40)
    for cx, cy, r in ((236, 250, 17), (282, 300, 15), (240, 340, 18), (284, 214, 12)):
        a.ellipse(cx, cy, r, r * 0.9, WOOD_D, sw=0, stroke="none")
    # あたま
    a.ellipse(256, 126, 82, 64, YEL)
    a.ellipse(256, 150, 52, 36, "#fbe4a0", sw=0, stroke="none")
    a.ellipse(238, 150, 6, 9, O, sw=0, stroke="none")
    a.ellipse(274, 150, 6, 9, O, sw=0, stroke="none")
    for s in (-1, 1):
        x = 256 + s * 38
        a.line(x, 74, x + s * 10, 36, sw=11)
        a.circle(x + s * 10, 34, 11, WOOD_D, sw=8)
    for s in (-1, 1):
        a.path(f"M{256+s*70} 118 C{256+s*104} 100 {256+s*112} 142 {256+s*74} 144 Z", fill=YEL, sw=9)
    a.ellipse(224, 124, 11, 14, EYE, sw=0, stroke="none")
    a.ellipse(288, 124, 11, 14, EYE, sw=0, stroke="none")
    a.dot(228, 119, 4, WHITE)
    a.dot(292, 119, 4, WHITE)
    a.ellipse(206, 146, 16, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.ellipse(306, 146, 16, 10, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.7"})
    a.path("M246 170 C252 178 260 178 266 170", sw=8)
    a.shine("M196 96 C210 84 228 80 244 82")
    # かきね
    a.rect(60, 372, 392, 40, WOOD, rx=12)
    a.path("M96 372 L96 424 M160 372 L160 424 M224 372 L224 424 M288 372 L288 424 M352 372 L352 424 M416 372 L416 424", sw=9)
    return a


@place
def makiba():
    a = Art()
    grass(a, cy=410, rx=220, ry=50)
    # こや
    a.rect(120, 232, 272, 170, RED, rx=12)
    a.path("M96 246 L130 150 L256 110 L382 150 L416 246 Z", fill=RED_D)
    a.path("M96 246 L416 246", sw=11)
    a.circle(256, 188, 26, CREAM)
    # とびら（バツ）
    a.rect(190, 286, 132, 116, WHITE, rx=8)
    a.path("M190 286 L322 402 M322 286 L190 402", sw=9)
    a.path("M190 286 L322 286 L322 402 L190 402 Z", sw=9)
    # さく
    for x in (60, 108, 404, 452):
        a.rect(x - 14, 362, 28, 68, WOOD, rx=10)
    a.shine("M138 270 C140 256 146 246 156 238")
    return a


@place
def mori():
    a = Art()
    grass(a, cy=440, rx=214, ry=40)
    tree(a, 138, 380, 1.3, GREEN)
    tree(a, 386, 368, 1.1, GREEN_D)
    # きのこ
    a.rect(226, 380, 60, 58, CREAM, rx=16)
    a.path("M176 392 C176 306 336 306 336 392 Z", fill=RED)
    for cx, cy, r in ((216, 360, 12), (258, 342, 13), (304, 366, 11)):
        a.circle(cx, cy, r, WHITE, sw=0, stroke="none")
    a.shine("M102 296 C104 268 120 252 142 246")
    return a


@place
def ie():
    a = Art()
    grass(a, cy=420, rx=215, ry=44)
    # えんとつ
    a.rect(330, 120, 44, 80, "#b8794a", rx=8)
    # いえ
    a.rect(112, 230, 288, 180, CREAM, rx=14)
    a.path("M84 244 L256 100 L428 244 Z", fill=ORANGE)
    a.path("M84 244 L428 244", sw=11)
    a.path("M222 410 L222 336 C222 300 290 300 290 336 L290 410 Z", fill=WOOD)
    a.dot(276, 360, 6, O)
    a.rect(136, 270, 62, 58, SKY, rx=10)
    a.rect(314, 270, 62, 58, SKY, rx=10)
    a.path("M167 270 L167 328 M136 299 L198 299", sw=7)
    a.path("M345 270 L345 328 M314 299 L376 299", sw=7)
    # まるまど
    a.circle(256, 196, 22, SKY)
    a.shine("M128 392 L128 270")
    return a


@place
def umi():
    a = Art()
    # くじら
    body = ("M90 330 C70 250 130 190 240 190 C340 190 420 238 424 310 C426 370 380 410 300 414 "
            "C190 420 110 400 90 330 Z")
    a.path("M404 292 C440 262 470 250 470 214 C440 220 424 232 404 262 Z", fill=BLUE_D)
    a.path("M404 292 C436 294 470 300 478 340 C440 350 418 330 404 310 Z", fill=BLUE_D)
    a.path(body, fill=BLUE)
    a.path("M120 370 C170 396 290 400 380 380 C400 376 420 350 424 322 C410 356 380 372 300 378 C210 384 150 370 120 340 Z",
           fill=CREAM, sw=0, stroke="none")
    a.path(body)
    # しおふき
    a.path("M226 182 L226 138 M226 138 C200 128 190 108 196 92 M226 138 C252 128 262 108 256 92", stroke=SKY, sw=18)
    a.path("M226 182 L226 138 M226 138 C200 128 190 108 196 92 M226 138 C252 128 262 108 256 92", stroke=BLUE, sw=7)
    a.face(cx=190, cy=286, gap=42, mouth_y=326, blush_y=318, blush_dx=76, r=14)
    a.shine("M122 300 C120 270 140 244 170 232")
    # なみ
    a.path("M40 410 C80 380 120 440 170 410 C220 380 260 440 310 410 C360 380 400 440 450 410 C470 400 480 398 490 400 L490 470 L40 470 Z",
           fill=BLUE_D)
    return a


@place
def kawa():
    a = Art()
    # みず
    a.ellipse(256, 380, 214, 78, BLUE)
    a.path("M96 392 C120 380 150 380 172 392", stroke=WHITE, sw=8, **{"stroke-opacity": "0.6"})
    a.path("M340 400 C364 390 392 390 414 400", stroke=WHITE, sw=8, **{"stroke-opacity": "0.6"})
    # はす
    a.ellipse(256, 380, 118, 40, GREEN)
    a.path("M256 380 L330 350", sw=9)
    # かえる
    a.ellipse(256, 300, 92, 76, "#8ed06f")
    a.ellipse(256, 322, 60, 40, "#d4f0b8", sw=0, stroke="none")
    for s in (-1, 1):
        x = 256 + s * 52
        a.circle(x, 218, 38, "#8ed06f")
        a.circle(x, 218, 24, WHITE, sw=7)
        a.ellipse(x + s * 2, 220, 11, 13, EYE, sw=0, stroke="none")
        a.dot(x + s * 2 + 4, 215, 4, WHITE)
        a.ellipse(256 + s * 78, 304, 14, 9, CHEEK, sw=0, stroke="none", **{"fill-opacity": "0.8"})
    a.path("M214 296 C240 332 272 332 298 296", sw=9)
    # てあし
    for s in (-1, 1):
        a.ellipse(256 + s * 62, 374, 36, 16, "#8ed06f")
    a.shine("M196 270 C200 252 212 242 226 238")
    # はな
    for dx in (-1, 1):
        pass
    return a


@place
def omise():
    a = Art()
    # みせ
    a.rect(100, 190, 312, 220, CREAM, rx=14)
    # ひさし
    n = 6
    w = 312 / n
    for i in range(n):
        x0 = 100 + i * w
        col = RED if i % 2 == 0 else WHITE
        a.path(f"M{x0} 130 L{x0+w} 130 L{x0+w} 200 C{x0+w} 226 {x0} 226 {x0} 200 Z", fill=col, sw=9)
    a.path("M100 130 L412 130", sw=11)
    a.rect(132, 244, 108, 90, SKY, rx=10)
    a.path("M286 410 L286 276 C286 248 366 248 366 276 L366 410 Z", fill=WOOD)
    # はこ・くだもの
    a.rect(110, 338, 150, 72, WOOD, rx=12)
    a.circle(146, 334, 25, RED, sw=9)
    a.circle(196, 330, 25, ORANGE, sw=9)
    a.circle(236, 340, 22, YEL2, sw=9)
    a.shine("M130 250 L130 320", sw=6)
    return a


@place
def koen():
    a = Art()
    grass(a, cy=424, rx=222, ry=42)
    # ぶらんこ
    a.path("M106 424 L190 150 L256 150", stroke=O, sw=40)
    a.path("M406 424 L322 150 L256 150", stroke=O, sw=40)
    a.path("M106 424 L190 150 L256 150", stroke=RED, sw=18)
    a.path("M406 424 L322 150 L256 150", stroke=RED, sw=18)
    for x in (222, 290):
        a.line(x, 156, x, 316, sw=8)
    a.rect(190, 316, 64, 18, YEL, rx=8)
    a.rect(258, 316, 64, 18, BLUE, rx=8)
    # ボール
    a.circle(256, 394, 26, YEL)
    a.path("M232 388 C246 402 266 402 280 388", sw=7)
    a.shine("M130 360 L168 250", sw=6)
    return a


@place
def uchu():
    a = Art()
    # わくせい
    a.circle(120, 340, 78, "#9d8de0")
    a.circle(96, 316, 14, "#b9acf0", sw=0, stroke="none")
    a.circle(144, 372, 18, "#b9acf0", sw=0, stroke="none")
    a.ellipse(120, 340, 112, 26, "none", sw=34)
    a.ellipse(120, 340, 112, 26, "none", sw=14, stroke=YEL)
    # ロケット
    a.path("M320 90 C376 138 392 220 380 330 L260 330 C248 220 264 138 320 90 Z", fill=WHITE)
    a.path("M320 90 C348 114 364 146 372 180 L268 180 C276 146 292 114 320 90 Z", fill=RED)
    a.path("M268 180 L372 180", sw=9)
    a.circle(320, 244, 34, SKY)
    a.path("M262 290 C226 300 210 340 214 380 L262 344 Z", fill=RED)
    a.path("M378 290 C414 300 430 340 426 380 L378 344 Z", fill=RED)
    a.path("M276 330 L364 330 L350 360 L290 360 Z", fill=GREY_L)
    a.path("M300 366 C296 400 316 428 320 440 C324 428 344 400 340 366 Z", fill=YEL2)
    a.shine("M276 214 C274 200 276 190 282 180", sw=6)
    star(a, 80, 140, 22)
    star(a, 168, 90, 14)
    star(a, 442, 120, 16)
    star(a, 440, 280, 12)
    return a


def petal(a, cx, cy, r, ang, fill):
    import math
    x = cx + r * math.cos(ang)
    y = cy + r * math.sin(ang)
    a.circle(x, y, r * 0.62, fill)


@place
def kisetsu():
    a = Art()
    # ぽーる
    a.rect(100, 70, 22, 360, WOOD_D, rx=8)
    a.circle(111, 66, 18, YEL2)
    a.ellipse(111, 436, 70, 22, GREEN)
    # はる（さくら）
    a.path("M122 100 L420 100 L388 150 L420 200 L122 200 Z", fill=PINK)
    import math
    cx, cy = 262, 150
    for i in range(5):
        ang = -math.pi / 2 + i * 2 * math.pi / 5
        a.circle(cx + 28 * math.cos(ang), cy + 28 * math.sin(ang), 20, WHITE, sw=8)
    a.circle(cx, cy, 11, YEL2, sw=6)
    # あき（もみじ）
    a.path("M122 230 L420 230 L388 280 L420 330 L122 330 Z", fill=ORANGE)
    a.path("M270 252 L282 276 L306 266 L296 290 L318 300 L292 304 L296 316 L270 306 L244 316 L248 304 L222 300 L244 290 L234 266 L258 276 Z", fill=RED, sw=7)
    a.shine("M140 118 L140 184", sw=6)
    return a


if __name__ == "__main__":
    names = sys.argv[1:] or list(P)
    os.makedirs(OUT, exist_ok=True)
    for n in names:
        with open(os.path.join(OUT, f"{n}.svg"), "w") as f:
            f.write(P[n]().svg())
