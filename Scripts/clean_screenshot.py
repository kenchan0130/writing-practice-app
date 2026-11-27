"""App Store 用の画像を仕上げる（Scripts/make_screenshots.sh から呼ぶ）。
iPadOS が窓の大きさを変えるために出す小さな弧（縦向きは右下、横向きは右上）を、隣の背景の色で塗りつぶし、
アルファのない PNG にして書き戻す。弧のまわりが無地でなければ、塗らずに失敗する。
使い方: python3 -I Scripts/clean_screenshot.py <画像.png> <portrait|landscape>   （ffmpeg が要る）"""
import subprocess, sys

path, orient = sys.argv[1], sys.argv[2]
probe = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "csv=p=0", path],
                       capture_output=True, text=True, check=True).stdout.strip().split(",")
w, h = int(probe[0]), int(probe[1])
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-f", "rawvideo", "-pix_fmt", "rgb24", "-"], capture_output=True, check=True).stdout

def px(x, y):
    i = (y * w + x) * 3
    return tuple(raw[i:i + 3])

def close(a, b, tol=6):
    return max(abs(x - y) for x, y in zip(a, b)) <= tol

class Fallback(Exception):
    pass

def fail(msg):
    raise Fallback(msg)

def hexc(c):
    return "0x%02x%02x%02x" % c


def finish_boxes(boxes):
    vf = ",".join(f"drawbox=x={x}:y={y}:w={bw}:h={bh}:color={hexc(c)}:t=fill" for x, y, bw, bh, c in boxes)
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", path, "-vf", vf, "-pix_fmt", "rgb24", "-f", "image2", path + ".tmp.png"], check=True)
    subprocess.run(["mv", path + ".tmp.png", path], check=True)

def finish_mask():
    """四角で塗ると背景の影などを壊すとき: 弧だけ（灰色の点と、そのまわり4px）を、同じ行の左右の隣の色をつないで塗る。"""
    img = bytearray(raw)
    x0 = w - 70
    ys = range(0, 70) if orient == "landscape" else range(h - 70, h)
    def gray(x, y):
        r, g, b = px(x, y)
        return abs(r - g) < 8 and abs(g - b) < 8 and r < 215
    xs0 = w - 58 if orient == "landscape" else x0   # 横向きは、電池を巻き込まない
    core = {(x, y) for y in ys for x in range(xs0, w) if gray(x, y)}
    if not core:
        sys.exit(f"{path}: 弧が見つからない")
    mask = {(x + dx, y + dy) for x, y in core for dx in range(-4, 5) for dy in range(-4, 5)
            if xs0 <= x + dx < w and ys.start <= y + dy < ys.stop}
    for y in ys:
        row = sorted(x for x, yy in mask if yy == y)
        if not row:
            continue
        # つながった区間ごとに、両隣の色をつなぐ
        runs, start = [], row[0]
        for a, b in zip(row, row[1:] + [None]):
            if b != a + 1:
                runs.append((start, a))
                start = b
        for xa, xb in runs:
            left = px(xa - 1, y) if xa > 0 else px(xb + 1, y)
            right = px(xb + 1, y) if xb + 1 < w else left
            for x in range(xa, xb + 1):
                t = (x - xa + 1) / (xb - xa + 2)
                i = (y * w + x) * 3
                img[i:i + 3] = bytes(round(l + (r - l) * t) for l, r in zip(left, right))
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{w}x{h}", "-i", "-",
                    "-pix_fmt", "rgb24", "-f", "image2", path + ".tmp.png"], input=bytes(img), check=True)
    subprocess.run(["mv", path + ".tmp.png", path], check=True)

try:
    # 塗る四角（x, y, 幅, 高さ, 色）。弧は角から約 60px の中。
    if orient == "landscape":
        # 電池の右端（角から約 53px）を避けて2つに分ける。弧の下の何もない帯と同じ色で塗る。
        color = px(w - 30, 90)
        for y in range(70, 110, 4):
            for x in range(w - 90, w, 4):
                if not close(px(x, y), color):
                    fail("角が無地ではない")
        boxes = [(w - 58, 0, 58, 24, color), (w - 52, 0, 52, 66, color)]
    else:
        # 右下。弧の左（x = w-64）と右の端（x = w-3）の色を行ごとに調べ、境目の位置（無地の1本の縦の帯のことがある）を上の行から探す。
        x0, y0 = w - 64, h - 66
        left, right = px(x0, y0 - 1), px(w - 3, y0 - 1)
        xb = w
        for x in range(x0, w - 3):
            if not close(px(x, y0 - 1), left):
                xb = x
                break
        if xb != w and not close(px(xb + 4, y0 - 1), right):
            fail("境目が分からない")
        for y in range(y0, h, 2):
            if not close(px(x0, y), left) or not close(px(w - 3, y), right):
                fail("角が無地ではない")
        if xb != w and not (close(px(xb - 4, h - 1), left) and close(px(xb + 4, h - 1), right)):
            fail("境目が下まで続かない")
        boxes = [(x0, y0, xb - x0, 66, left)] + ([(xb, y0, w - xb, 66, right)] if xb != w else [])
    finish_boxes(boxes)
except Fallback as e:
    print(f"{path}: {e}。弧だけを塗る")
    finish_mask()
