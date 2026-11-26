"""主人公3人（とん・るん・ひら）の絵。ことばの絵と同じ描き方（part / sil / ink。D176・D177）。

使い方: python3 -I Scripts/art/chars.py   → Content/Art/characters/<名前>-<ポーズ>.svg
ポーズを入れかえても体が動かないように、1人の5つのポーズは同じ倍率・同じ位置で書き出す
（体の真ん中は x = 256、足の下は y = FLOOR）。
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lib import Art, taper, O

OUT = os.path.join(HERE, "..", "..", "Content", "Art", "characters")
YEL = "#ffd84d"
CHEEK = "#ff9aa8"
MOUTH, TONGUE = "#9c3f3c", "#ff8f9c"
ZCOL = "#9fb3e6"
WHITE = "#ffffff"
POSES = ("normal", "wave", "happy", "sleep", "blink")
CX = 256
G = 480          # 足の下（描くときの座標）
FLOOR = 488      # 書き出した絵の足の下（512 の中。線の外側まで）
MARGIN = 10


# ------------------------------------------------------------ 共通の部品 ----
def sparkle(a, cx, cy, r):
    """きらきら（4つの先がある星。辺は内側にへこむ）。"""
    k = r * 0.2
    d = (f"M{cx} {cy - r} Q{cx + k} {cy - k} {cx + r} {cy} Q{cx + k} {cy + k} {cx} {cy + r} "
         f"Q{cx - k} {cy + k} {cx - r} {cy} Q{cx - k} {cy - k} {cx} {cy - r} Z")
    with a.part(6):
        a.sil(d, YEL)


def zee(a, x, y, s):
    """ねむりの Z。"""
    p = [(0, 0), (1, 0), (1, .22), (.42, .78), (1, .78), (1, 1), (0, 1), (0, .78), (.58, .22), (0, .22)]
    with a.part(6):
        a.sil("M" + " L".join(f"{x + s * u:.1f} {y + s * v:.1f}" for u, v in p) + " Z", ZCOL)


def zzz(a, x, y):
    zee(a, x, y, 40)
    zee(a, x + 48, y - 40, 27)


def foot(fx, w=40, h=46):
    """体の下からのぞく、小さな丸い足（上は体に隠れる）。"""
    return (f"M{fx - w} {G - h * 0.42:g} C{fx - w} {G - h:g} {fx + w} {G - h:g} {fx + w} {G - h * 0.42:g} "
            f"C{fx + w} {G + 1} {fx - w} {G + 1} {fx - w} {G - h * 0.42:g} Z")


def arm(sx, sy, s, up, w0=46, w1=38):
    """体の中の肩 (sx, sy) から生える短い腕。s = -1 左 / +1 右。up = 上げる。先の丸みが手。"""
    if up:
        c = [(sx, sy - 14, sx + s * 30, sy - 24, sx + s * 62, sy - 50, sx + s * 70, sy - 104)]
    else:
        c = [(sx, sy, sx + s * 22, sy + 2, sx + s * 44, sy + 10, sx + s * 52, sy + 36)]
    return taper(c, w0 + (6 if up else 0), w1 + (4 if up else 0)), c


def arms(a, pose, col, dx, sy):
    """両腕（体と同じ部品の中で呼ぶ）。肩は (CX ± dx, sy)。手の先の場所を返す。"""
    up_l = pose == "happy"
    up_r = pose in ("happy", "wave")
    dl, cl = arm(CX - dx, sy, -1, up_l)
    dr, cr = arm(CX + dx, sy, 1, up_r)
    a.sil(dl, col)
    a.sil(dr, col)
    return (cl[0][6], cl[0][7]), (cr[0][6], cr[0][7])


def wave_marks(a, hx, hy):
    """振っている手のまわりの、短い2本の線。"""
    a.path(f"M{hx + 40} {hy - 34} C{hx + 52} {hy - 22} {hx + 56} {hy - 6} {hx + 52} {hy + 10}", sw=7)
    a.path(f"M{hx - 34} {hy - 44} C{hx - 22} {hy - 56} {hx - 4} {hy - 60} {hx + 12} {hy - 56}", sw=7)


def face(a, pose, cy, gap=54, r=23, cheek=CHEEK, cheek_op=0.9, mouth="smile"):
    """顔。目は左右同じ大きさ。normal / wave は つやのある目、happy は「＾＾」、sleep / blink は とじた目。"""
    for s in (-1, 1):
        x = CX + s * gap
        if pose == "happy":
            a.path(f"M{x - 20} {cy + 9} C{x - 12} {cy - 16} {x + 12} {cy - 16} {x + 20} {cy + 9}", sw=9)
        elif pose in ("sleep", "blink"):
            a.path(f"M{x - 20} {cy - 2} C{x - 12} {cy + 16} {x + 12} {cy + 16} {x + 20} {cy - 2}", sw=9)
        else:
            a.eye(x, cy, r)
        a.ellipse(CX + s * (gap + 42), cy + 38, 20, 12, cheek, sw=0, stroke="none", **{"fill-opacity": cheek_op})
    my = cy + 38
    if pose == "sleep":                       # 小さな「お」の口
        with a.part(5):
            a.sil(f"M{CX - 7} {my + 7} C{CX - 7} {my - 3} {CX + 7} {my - 3} {CX + 7} {my + 7} "
                  f"C{CX + 7} {my + 17} {CX - 7} {my + 17} {CX - 7} {my + 7} Z", MOUTH)
    elif pose == "happy" or (mouth == "open" and pose in ("normal", "wave", "blink")):
        k = 1.0 if pose == "happy" else 0.78  # あいた口と舌
        w, h = 22 * k, 30 * k
        with a.part(5):
            a.sil(f"M{CX - w:g} {my - 4} C{CX - w:g} {my - 4 + h * 1.25:g} {CX + w:g} {my - 4 + h * 1.25:g} {CX + w:g} {my - 4} Z", MOUTH)
        ty = my - 4 + h * 0.62
        a.blob(f"M{CX - w * 0.52:g} {ty:g} C{CX - w * 0.3:g} {ty - h * 0.22:g} {CX + w * 0.3:g} {ty - h * 0.22:g} {CX + w * 0.52:g} {ty:g} "
               f"C{CX + w * 0.3:g} {ty + h * 0.3:g} {CX - w * 0.3:g} {ty + h * 0.3:g} {CX - w * 0.52:g} {ty:g} Z", TONGUE)
    else:
        a.path(f"M{CX - 15} {my} C{CX - 7} {my + 12} {CX + 7} {my + 12} {CX + 15} {my}", sw=7)


def extras(a, pose, lh, rh, zx, zy):
    if pose == "wave":
        wave_marks(a, rh[0], rh[1])
    elif pose == "happy":
        sparkle(a, lh[0] - 8, lh[1] - 66, 24)
        sparkle(a, rh[0] + 12, rh[1] - 64, 19)
        sparkle(a, rh[0] - 34, rh[1] - 92, 12)
    elif pose == "sleep":
        zzz(a, zx, zy)


# ---------------------------------------------------------------- とん ----
def ton(pose):
    """とめ: 赤だいだいの インクのしずく。ひたいに点。"""
    C, D = "#f07a4a", "#d55f33"
    a = Art()
    with a.part():                            # 足（体の奥）
        a.sil(foot(CX - 56), D)
        a.sil(foot(CX + 56), D)
    with a.part():                            # 体と腕は1つの部品
        lh, rh = arms(a, pose, C, 122, 362)
        a.sil("M264 98 C274 98 278 108 280 120 C288 166 318 188 342 216 C384 262 406 318 406 372 "
              "C406 428 360 456 256 456 C152 456 106 428 106 372 C106 318 128 262 170 216 "
              "C196 188 240 168 248 120 C250 108 254 98 264 98 Z", C)
        a.blob("M384 286 C400 318 406 346 406 372 C406 428 360 456 256 456 C222 456 194 453 172 447 "
               "C236 450 322 446 360 414 C390 388 392 334 384 286 Z", D)   # 影（右と下）
    a.blob("M256 222 C266 222 272 229 272 238 C272 248 265 254 256 254 C247 254 240 248 240 238 "
           "C240 229 246 222 256 222 Z", O)   # とめの点
    a.dot(261, 233, 3.6, WHITE, **{"fill-opacity": "0.7"})
    a.shine("M140 344 C144 306 162 272 188 246")
    face(a, pose, 326, cheek="#ffa39b")
    extras(a, pose, lh, rh, zx=352, zy=150)
    return a


# ---------------------------------------------------------------- るん ----
def run(pose):
    """はね: 空いろ。頭の上に、ぴんと はねた アンテナ。"""
    C, D = "#58b2ea", "#3a94d4"
    a = Art()
    if pose == "sleep":                       # ねむると アンテナが たれる
        a.sil(taper([(256, 190, 256, 150, 268, 112, 300, 108), (300, 108, 322, 106, 334, 122, 330, 140)], 30, 14), D)
    else:                                     # まっすぐ上へ、そこから左上へ はねる
        a.sil("M240 190 L243 128 C244 104 230 88 196 76 C244 58 276 86 274 128 L272 190 Z", D)
    with a.part():
        a.sil(foot(CX - 52), D)
        a.sil(foot(CX + 52), D)
    with a.part():
        lh, rh = arms(a, pose, C, 100, 340)
        a.sil("M256 166 C332 166 382 226 386 304 C390 392 334 456 256 456 C178 456 122 392 126 304 "
              "C130 226 180 166 256 166 Z", C)
        a.blob("M374 250 C384 272 386 290 386 304 C390 392 334 456 256 456 C226 456 200 448 180 434 "
               "C240 452 322 436 354 376 C374 338 378 292 374 250 Z", D)
    a.shine("M158 300 C160 262 176 232 200 212")
    face(a, pose, 304, cheek="#f9a8c4", mouth="open")
    extras(a, pose, lh, rh, zx=352, zy=140)
    return a


# ---------------------------------------------------------------- ひら ----
def hira(pose):
    """はらい: わかばいろ。すっと流れる しっぽと、頭の上の金色の葉。"""
    C, D = "#7cc36a", "#62a853"
    LEAF, LEAF_D, VEIN = "#f6c453", "#e9a93a", "#c98a2a"
    a = Art()
    with a.part(9):                           # 葉（頭の奥）
        a.sil("M250 176 C226 136 240 88 292 62 C318 106 302 158 250 176 Z", LEAF)
        a.blob("M250 176 C290 150 300 104 292 62 C318 106 302 158 250 176 Z", LEAF_D)
        a.ink([(254, 168, 264, 136, 276, 108, 288, 78)], 6, a=1, b=0, col=VEIN)
    with a.part():                            # しっぽ（体の奥から、右へ すっと はらう）
        a.sil(taper([(300, 420, 366, 470, 440, 448, 482, 376)], 84, 3, cap=False), C)
        a.blob(taper([(330, 452, 380, 474, 436, 452, 474, 396)], 26, 2, cap=False), D)
    with a.part():
        a.sil(foot(CX - 54), D)
        a.sil(foot(CX + 46), D)
    with a.part():                            # 体と腕は1つの部品
        lh, rh = arms(a, pose, C, 104, 334)
        a.sil("M256 160 C336 160 388 216 390 294 C392 380 338 456 254 456 C172 456 120 380 122 294 "
              "C124 216 176 160 256 160 Z", C)
        a.blob("M378 244 C388 266 390 282 390 294 C392 380 338 456 254 456 C224 456 198 448 178 434 "
               "C238 452 324 434 356 372 C376 334 382 288 378 244 Z", D)
    a.shine("M160 286 C162 250 178 220 202 202")
    face(a, pose, 300, cheek="#f3b3a4", cheek_op=1)
    extras(a, pose, lh, rh, zx=356, zy=140)
    return a


CHARS = {"ton": ton, "run": run, "hira": hira}


def fit(arts):
    """1人の全部のポーズに同じ倍率と位置。体の真ん中 x = 256、足の下 y = FLOOR。"""
    bs = [a._bbox() for a in arts]
    x0 = min(b[0] for b in bs); y0 = min(b[1] for b in bs)
    x1 = max(b[2] for b in bs); y1 = max(b[3] for b in bs)
    half = 256 - MARGIN
    s = min(half / (CX - x0), half / (x1 - CX), (FLOOR - MARGIN) / (y1 - y0))
    return s, 256 - s * CX, FLOOR - s * y1


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else OUT
    for name, f in CHARS.items():
        arts = {p: f(p) for p in POSES}
        prm = fit(arts.values())
        for p, art in arts.items():
            open(f"{out}/{name}-{p}.svg", "w").write(art.svg(params=prm))
