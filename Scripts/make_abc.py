#!/usr/bin/env python3 -I
"""アルファベット（大文字・小文字）と数字 0〜9 の文字のデータを作る（D180）。

使い方（Mac で。輪郭を作るのに Scripts/abc_outline.swift を呼ぶ）:
  python3 -I Scripts/make_abc.py Content/Packs/abc

字の形は、このファイルの中に線と円弧で書いてある（フォントはなぞっていない）。
日本の小学校の英語の教科書の手書きの形（a と g は1階建て、棒と丸の組み合わせ）と、
算数の教科書の数字の形に合わせる。形を直すときは、このファイルを直して作り直す。

マスは 0〜1000（y は下向き）。
  アルファベットは4本の線に合わせる: 上の線 70、中の線 340、基本の線 660、下の線 930（およそ 5:6:5）。
  数字は 140〜860 の高さで、マスのまん中に書く。
1字のデータ:
  strokes     お手本の画（中心線 + お手本に見せる輪郭）。順番がお手本の書き順。
  orders      同じ画で、正解にする書き順（先頭がお手本）。
  alternates  画数や画の分け方がちがう、正解にする書き方（中心線だけ。D66）。
  mirrorCheck 左右対称に近い字は false（鏡の字を見ない）。
"""
import json
import math
import os
import subprocess
import sys

TOP, MID, BASE, DESC = 70, 340, 660, 930
CAP_MID = 365
DIGIT_TOP, DIGIT_BOTTOM = 140, 860
LETTER_WIDTH = 54
DIGIT_WIDTH = 60
REV = 1


class P:
  """1画の中心線。始点と3次ベジェの並び。"""

  def __init__(self, x, y):
    self.start = (float(x), float(y))
    self.cur = self.start
    self.segs = []
    self.dir = None  # いまの向き（長さ1）

  def _add(self, c1, c2, end):
    self.segs.append((c1, c2, end))
    d = (end[0] - c2[0], end[1] - c2[1])
    if abs(d[0]) + abs(d[1]) < 1e-6:
      d = (end[0] - c1[0], end[1] - c1[1])
    n = math.hypot(*d)
    if n > 1e-6:
      self.dir = (d[0] / n, d[1] / n)
    self.cur = end

  def L(self, x, y):
    """まっすぐな線。"""
    a, b = self.cur, (float(x), float(y))
    c1 = (a[0] + (b[0] - a[0]) / 3, a[1] + (b[1] - a[1]) / 3)
    c2 = (a[0] + (b[0] - a[0]) * 2 / 3, a[1] + (b[1] - a[1]) * 2 / 3)
    self._add(c1, c2, b)
    return self

  def C(self, x1, y1, x2, y2, x, y):
    self._add((float(x1), float(y1)), (float(x2), float(y2)), (float(x), float(y)))
    return self

  def A(self, cx, cy, rx, ry, a0, a1, smooth=False):
    """だ円の弧。角度は度（0 が右、90 が下、180 が左、270 が上）。a0 < a1 は時計回り。
    いまの点が弧の始まりと違えば、線でつなぐ（smooth なら、向きを合わせた曲線でつなぐ）。"""
    def pt(a):
      r = math.radians(a)
      return (cx + rx * math.cos(r), cy + ry * math.sin(r))

    def tan(a):
      r = math.radians(a)
      return (-rx * math.sin(r), ry * math.cos(r))

    first = pt(a0)
    gap = math.hypot(first[0] - self.cur[0], first[1] - self.cur[1])
    if gap > 0.5:
      if smooth and self.dir is not None:
        sign = 1 if a1 > a0 else -1
        t = tan(a0)
        n = math.hypot(*t)
        end_dir = (sign * t[0] / n, sign * t[1] / n)
        k = gap * 0.38
        c1 = (self.cur[0] + self.dir[0] * k, self.cur[1] + self.dir[1] * k)
        c2 = (first[0] - end_dir[0] * k, first[1] - end_dir[1] * k)
        self._add(c1, c2, first)
      else:
        self.L(*first)
    else:
      self.cur = first if not self.segs else self.cur
    pieces = max(1, math.ceil(abs(a1 - a0) / 90))
    step = (a1 - a0) / pieces
    k = 4 / 3 * math.tan(math.radians(step) / 4)
    for i in range(pieces):
      s, e = a0 + step * i, a0 + step * (i + 1)
      p0, p1 = pt(s), pt(e)
      t0, t1 = tan(s), tan(e)
      self._add((p0[0] + k * t0[0], p0[1] + k * t0[1]), (p1[0] - k * t1[0], p1[1] - k * t1[1]), p1)
    return self

  def copy(self):
    q = P(*self.start)
    q.cur, q.segs, q.dir = self.cur, list(self.segs), self.dir
    return q

  def then(self, other):
    """別の線を続けて1画にする（離れていれば線でつなぐ。もどり書きにも使う）。"""
    q = self.copy()
    if math.hypot(other.start[0] - q.cur[0], other.start[1] - q.cur[1]) > 0.5:
      q.L(*other.start)
    for seg in other.segs:
      q._add(*seg)
    return q

  def json(self, end="tome"):
    def r(v):
      return int(round(v))

    return {
      "start": [r(self.start[0]), r(self.start[1])],
      "segments": [[r(c1[0]), r(c1[1]), r(c2[0]), r(c2[1]), r(e[0]), r(e[1])] for c1, c2, e in self.segs],
      "end": end,
    }


def line(*pts):
  p = P(*pts[0])
  for x, y in pts[1:]:
    p.L(x, y)
  return p


def arc(cx, cy, rx, ry, a0, a1):
  r = math.radians(a0)
  return P(cx + rx * math.cos(r), cy + ry * math.sin(r)).A(cx, cy, rx, ry, a0, a1)


def dot(x, y):
  """点（i・j）。長さのない線にして、どの向きに書いても向きの間違いにしない。"""
  return P(x, y).L(x, y)


def s_curve(cx, top, mid, bottom, rx_top, rx_bottom, a_start=325, a_end=505):
  """S の形: 上の丸を左回り、下の丸を右回り。"""
  ry1, ry2 = (mid - top) / 2, (bottom - mid) / 2
  p = arc(cx, top + ry1, rx_top, ry1, a_start, 110)
  p.A(cx, mid + ry2, rx_bottom, ry2, 290, a_end, smooth=True)
  return p


# ---- 字の形 ----------------------------------------------------------------
# それぞれ { "strokes": [お手本の画], "orders": [...], "alternates": [[...], ...], "mirror": bool } を返す。

def glyphs():
  g = {}

  def put(char, strokes, orders=None, alternates=None, mirror=True):
    g[char] = {
      "strokes": strokes,
      "orders": orders or [list(range(len(strokes)))],
      "alternates": alternates or [],
      "mirror": mirror,
    }

  T, M, B, D, CM = TOP, MID, BASE, DESC, CAP_MID

  # ---- 大文字 ----
  put("A", [line((500, T), (285, B)), line((500, T), (715, B)), line((358, 460), (642, 460))], mirror=False)
  b_stem = line((330, T), (330, B))
  b_top = P(330, T).L(470, T).A(470, 210, 170, 140, 270, 450).L(330, 350)
  b_bottom = P(330, 350).L(490, 350).A(490, 505, 195, 155, 270, 450).L(330, B)
  put("B", [b_stem, b_top.then(b_bottom)], alternates=[[b_stem, b_top, b_bottom]])
  put("C", [arc(525, CM, 245, 295, 310, 50)])
  put("D", [line((310, T), (310, B)), P(310, T).L(410, T).A(410, CM, 290, 295, 270, 450).L(310, B)])
  e_stem, e_top = line((340, T), (340, B)), line((340, T), (680, T))
  e_mid, e_bottom = line((340, CM), (640, CM)), line((340, B), (680, B))
  put(
    "E", [e_stem, e_top, e_mid, e_bottom], orders=[[0, 1, 2, 3], [1, 0, 2, 3]],
    alternates=[[line((340, T), (340, B), (680, B)), e_top, e_mid]])
  f_stem, f_top, f_mid = line((360, T), (360, B)), line((360, T), (690, T)), line((360, CM), (650, CM))
  put(
    "F", [f_stem, f_top, f_mid], orders=[[0, 1, 2], [1, 0, 2]],
    alternates=[[line((690, T), (360, T), (360, B)), f_mid]])
  g_arc = arc(510, CM, 245, 295, 310, 0)
  put("G", [g_arc, line((540, CM), (755, CM))], alternates=[[g_arc.then(line((755, CM), (540, CM)))]])
  put("H", [line((300, T), (300, B)), line((700, T), (700, B)), line((300, CM), (700, CM))], mirror=False)
  put(
    "I", [line((500, T), (500, B)), line((385, T), (615, T)), line((385, B), (615, B))],
    orders=[[0, 1, 2], [1, 0, 2]], mirror=False)
  put("J", [P(610, T).L(610, 480).A(450, 480, 160, 180, 0, 160)])
  k_stem = line((330, T), (330, B))
  put(
    "K", [k_stem, line((680, T), (330, 420)), line((428, 322), (700, B))],
    alternates=[[k_stem, line((680, T), (345, 405), (700, B))]])
  put("L", [line((340, T), (340, B), (690, B))], alternates=[[line((340, T), (340, B)), line((340, B), (690, B))]])
  m_left, m_right = line((270, T), (270, B)), line((730, T), (730, B))
  put(
    "M", [m_left, line((270, T), (500, B)), line((730, T), (500, B)), m_right],
    alternates=[[m_left, line((270, T), (500, B), (730, T), (730, B))]],
    mirror=False)
  n_left, n_diag, n_right = line((300, T), (300, B)), line((300, T), (700, B)), line((700, T), (700, B))
  put(
    "N", [n_left, n_diag, n_right], orders=[[0, 1, 2], [0, 2, 1]],
    alternates=[[n_left, line((300, T), (700, B), (700, T))]])
  put("O", [arc(500, CM, 260, 295, 270, -90)], mirror=False)
  put("P", [line((340, T), (340, B)), P(340, T).L(470, T).A(470, 225, 200, 155, 270, 450).L(340, 380)])
  put("Q", [arc(500, CM, 260, 295, 270, -90), line((565, 490), (750, 690))])
  r_stem = line((330, T), (330, B))
  r_bowl = P(330, T).L(470, T).A(470, 220, 190, 150, 270, 450)
  put(
    "R", [r_stem, r_bowl.copy().L(425, 370).L(700, B)],
    alternates=[[r_stem, r_bowl.copy().L(330, 370), line((425, 370), (700, B))]])
  put("S", [s_curve(500, T, 360, B, 175, 195)])
  put("T", [line((270, T), (730, T)), line((500, T), (500, B))], orders=[[0, 1], [1, 0]], mirror=False)
  put("U", [P(300, T).L(300, 450).A(500, 450, 200, 210, 180, 0).L(700, T)], mirror=False)
  put(
    "V", [line((285, T), (500, B), (715, T))],
    alternates=[[line((285, T), (500, B)), line((715, T), (500, B))]], mirror=False)
  put(
    "W", [line((190, T), (345, B), (500, T), (655, B), (810, T))],
    alternates=[
      [line((190, T), (345, B), (500, T)), line((500, T), (655, B), (810, T))],
      [line((190, T), (345, B)), line((500, T), (345, B)), line((500, T), (655, B)), line((810, T), (655, B))],
    ], mirror=False)
  put("X", [line((300, T), (700, B)), line((700, T), (300, B))], orders=[[0, 1], [1, 0]], mirror=False)
  put(
    "Y", [line((285, T), (500, 380)), line((715, T), (500, 380), (500, B))],
    alternates=[
      [line((285, T), (500, 380)), line((715, T), (500, 380)), line((500, 380), (500, B))],
      [line((285, T), (500, 380), (715, T)), line((500, 380), (500, B))],
    ], mirror=False)
  put("Z", [line((290, T), (710, T), (290, B), (710, B))])

  # ---- 小文字（丸は 中の線〜基本の線。丸の中心は y=500） ----
  def bowl(cx, rx=150):
    """a・d・g・q の丸: 右上から左回りに回って、棒の所へもどる。"""
    return arc(cx, 500, rx, 160, 315, -10)

  a_bowl = bowl(480)
  put("a", [a_bowl.then(line((630, M), (630, B)))], alternates=[[a_bowl, line((630, M), (630, B))]])
  b_stem = line((350, T), (350, B))
  b_bowl = arc(500, 500, 150, 160, 180, 540)
  put("b", [b_stem.then(b_bowl)], alternates=[[b_stem, b_bowl]])
  put("c", [arc(515, 500, 155, 160, 315, 45)])
  d_bowl = bowl(470)
  put("d", [d_bowl.then(line((620, T), (620, B)))], alternates=[[d_bowl, line((620, T), (620, B))]])
  put("e", [P(350, 500).L(650, 500).A(500, 500, 150, 160, 0, -315)])
  put("f", [arc(600, 180, 100, 110, 310, 180).L(500, B), line((370, M), (630, M))])
  g_tail = P(630, M).L(630, 790).A(480, 790, 150, 140, 0, 150)
  put("g", [a_bowl.then(g_tail)], alternates=[[a_bowl, g_tail]])
  h_stem = line((350, T), (350, B))
  h_arch = P(350, 480).A(490, 480, 140, 140, 180, 360).L(630, B)
  put("h", [h_stem.then(h_arch)], alternates=[[h_stem, h_arch]])
  put("i", [line((500, M), (500, B)), dot(500, 205)], mirror=False)
  put("j", [P(560, M).L(560, 790).A(430, 790, 130, 140, 0, 150), dot(560, 205)])
  k_stem = line((360, T), (360, B))
  put(
    "k", [k_stem, line((630, M), (360, 525), (650, B))],
    alternates=[[k_stem, line((630, M), (360, 525)), line((446, 468), (650, B))]])
  put("l", [line((500, T), (500, B))], mirror=False)
  m_stem = line((270, M), (270, B))
  m_arch1 = P(270, 455).A(385, 455, 115, 115, 180, 360).L(500, B)
  m_arch2 = P(500, 455).A(615, 455, 115, 115, 180, 360).L(730, B)
  put(
    "m", [m_stem.then(m_arch1).then(m_arch2)],
    alternates=[[m_stem, m_arch1.then(m_arch2)], [m_stem, m_arch1, m_arch2]])
  n_stem = line((360, M), (360, B))
  n_arch = P(360, 480).A(500, 480, 140, 140, 180, 360).L(640, B)
  put("n", [n_stem.then(n_arch)], alternates=[[n_stem, n_arch]])
  put("o", [arc(500, 500, 155, 160, 270, -90)], mirror=False)
  p_stem = line((350, M), (350, D))
  put("p", [p_stem.then(b_bowl)], alternates=[[p_stem, b_bowl]])
  q_stem = line((630, M), (630, D))
  put("q", [a_bowl.then(q_stem)], alternates=[[a_bowl, q_stem]])
  r_stem = line((410, M), (410, B))
  r_arch = P(410, 480).A(540, 480, 130, 140, 180, 300)
  put("r", [r_stem.then(r_arch)], alternates=[[r_stem, r_arch]])
  put("s", [s_curve(500, M, 500, B, 125, 135)])
  put(
    "t", [P(480, 160).L(480, 560).A(580, 560, 100, 100, 180, 70), line((350, M), (620, M))],
    orders=[[0, 1], [1, 0]])
  u_cup = P(360, M).L(360, 520).A(500, 520, 140, 140, 180, 0).L(640, M)
  u_stem = line((640, M), (640, B))
  put("u", [u_cup.then(u_stem)], alternates=[[u_cup, u_stem]])
  put(
    "v", [line((350, M), (500, B), (650, M))],
    alternates=[[line((350, M), (500, B)), line((650, M), (500, B))]], mirror=False)
  put(
    "w", [line((250, M), (375, B), (500, M), (625, B), (750, M))],
    alternates=[
      [line((250, M), (375, B), (500, M)), line((500, M), (625, B), (750, M))],
      [line((250, M), (375, B)), line((500, M), (375, B)), line((500, M), (625, B)), line((750, M), (625, B))],
    ], mirror=False)
  put("x", [line((360, M), (640, B)), line((640, M), (360, B))], orders=[[0, 1], [1, 0]], mirror=False)
  put("y", [line((360, M), (500, B)), line((640, M), (382, D))])
  put("z", [line((360, M), (640, M), (360, B), (640, B))])

  # ---- 数字（算数の教科書の形。140〜860） ----
  DT, DB = DIGIT_TOP, DIGIT_BOTTOM
  put("0", [arc(500, 500, 215, 360, 270, -90)], mirror=False)
  put("1", [line((500, DT), (500, DB))], mirror=False)
  put("2", [arc(500, 335, 200, 195, 195, 405).L(300, DB).L(720, DB)])
  put("3", [arc(480, 310, 185, 170, 205, 440).A(480, 670, 215, 190, 280, 510)])
  put("4", [line((450, DT), (260, 600), (750, 600)), line((610, DT), (610, DB))])
  put(
    "5", [P(360, DT).L(335, 455).A(490, 620, 225, 240, 225, 500), line((360, DT), (700, DT))],
    orders=[[0, 1], [1, 0]])
  put("6", [P(640, 145).C(470, 210, 290, 430, 290, 640).A(500, 640, 210, 220, 180, -175)])
  seven = P(280, DT).L(720, DT).C(640, 330, 530, 580, 490, DB)
  put("7", [seven], alternates=[[line((280, DT), (280, 260)), seven]])
  eight = arc(500, 310, 165, 170, 330, 125)
  eight.A(500, 670, 200, 190, 305, 595, smooth=True)
  eight.A(500, 310, 165, 170, 55, -30, smooth=True)
  put("8", [eight], mirror=False)
  put("9", [arc(490, 340, 200, 200, 0, -360).C(690, 560, 660, 740, 590, DB)])
  return g


def outlines(items):
  """中心線を太らせた輪郭を、Scripts/abc_outline.swift（CoreGraphics）で作る。"""
  here = os.path.dirname(os.path.abspath(__file__))
  result = subprocess.run(
    ["swift", os.path.join(here, "abc_outline.swift")], input=json.dumps(items), capture_output=True, text=True)
  if result.returncode != 0:
    sys.stderr.write(result.stderr)
    sys.exit(1)
  return json.loads(result.stdout)


def main():
  if len(sys.argv) != 2:
    print(__doc__)
    sys.exit(2)
  out_dir = sys.argv[1]
  os.makedirs(out_dir, exist_ok=True)
  all_glyphs = glyphs()
  expected = [chr(c) for c in range(0x41, 0x5B)] + [chr(c) for c in range(0x61, 0x7B)] + list("0123456789")
  assert sorted(all_glyphs) == sorted(expected), "字が足りないか、多い"
  items = []
  for char in expected:
    width = DIGIT_WIDTH if char.isdigit() else LETTER_WIDTH
    items.append({"width": width, "strokes": [s.json() for s in all_glyphs[char]["strokes"]]})
  shapes = outlines(items)
  for char, shape in zip(expected, shapes):
    glyph = all_glyphs[char]
    strokes = []
    for stroke, outline in zip(glyph["strokes"], shape):
      data = stroke.json()
      data["outline"] = outline
      strokes.append(data)
    data = {
      "schema": 1,
      "id": "abc.%x" % ord(char),
      "char": char,
      "rev": REV,
      "source": {"name": "make_abc.py", "license": "自分たちで作った形（公開しない。D180）"},
      "strokes": strokes,
      "orders": glyph["orders"],
    }
    if glyph["alternates"]:
      data["alternates"] = [[s.json() for s in alt] for alt in glyph["alternates"]]
    if not glyph["mirror"]:
      data["mirrorCheck"] = False
    path = os.path.join(out_dir, data["id"] + ".json")
    with open(path, "w", encoding="utf-8") as f:
      json.dump(data, f, ensure_ascii=False, indent=1)
      f.write("\n")
  print(f"{len(expected)} 字を {out_dir} に書いた")


if __name__ == "__main__":
  main()
