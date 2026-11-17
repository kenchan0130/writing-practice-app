#!/usr/bin/env python3 -I
"""効果音の素材を、アプリに入れる形（Opus in CAF・モノラル・48kHz）に整える（D111・D149・D156・D158）。

使い方:
  python3 -I Scripts/process_sfx.py <素材の raw フォルダ> App/Mojimachi/Resources/Sounds

raw フォルダは `<源>/<元のファイル>` の形。源ごとの置き場:
  komori/mp3/<名前>.mp3     https://taira-komori.net/sound/<フォルダ>/<名前>.mp3 （curl でそのまま取れる）
  freesound/mp3/<番号>.mp3  https://freesound.org/s/<番号>/ のページにある高音質プレビュー（cdn.freesound.org/previews/…-hq.mp3）
  otologic/<名前>.mp3       https://otologic.jp/sounds/se/pre2/<名前>.mp3 （OtoLogic。CC BY 4.0。「OtoLogic」https://otologic.jp のクレジットが要る）
  conte/<cute/…/xxx.mp3>    こんとどぅふぇ（https://conte-de-fees.com/）の音の集まりから使う分だけ。
                            再配布が禁止なので、素材そのものはリポジトリに入れない。
  Freesound のページの HTML はリポジトリに入れない（サイトの鍵が入っていて GitHub に止められる）。
  出どころ・ライセンスの記録は Content/Sounds/provenance.csv と Content/Sounds/evidence/ に手で書く。

やること（ffmpeg・afconvert・afinfo だけ。どれも Mac にある。素材は音のデータとしてだけ扱う）:
  1. 先頭の無音を切る・長さを切る・最後を 60ms フェードアウト・モノラル 48kHz。
  2. 音量をそろえる: アクティブ音量（最大から 40dB 以内の 10ms 枠の RMS。Scripts/analyze_sfx.py と同じ測り方）を
     TARGET_ACTIVE_DB（前の 25 個の中央値 -18.5dB）にそろえる。ピークは PEAK_CEIL_DB（-1.5dBFS。Opus の行き過ぎの余裕を含めて -1dBFS 以下）まで。
     ピークが先に着く短い音は、軽いリミッターで MAX_LIMIT_DB（4dB）まで押さえて近づける。
  3. Opus 32kbps in CAF。
"""
import array
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
import wave

FFMPEG = shutil.which("ffmpeg") or "/opt/homebrew/bin/ffmpeg"
SR = 48000

TARGET_ACTIVE_DB = -18.5  # 前の 25 個のアクティブ音量の中央値
PEAK_CEIL_DB = -1.5  # ピークの上限（Opus にして少し行き過ぎても -1dBFS 以下）
MAX_LIMIT_DB = 4.0  # リミッターで押さえてよい量
FADE = 0.06

# 名前, 源, 元ファイル, 開始秒(None は先頭の無音を自動で切る), 長さ(秒)[, 速さ（1.5 なら高く短くなる。省略は 1）]
# 名前は SoundPlayer.Effect の fileName と同じ（ファイル名は半角英数字）。きもの は ゆかた の音を使う。
ITEMS = [
  # ことばの変身（D43・D53）
  ("word_sori", "freesound", "369506.mp3", None, 0.9),
  ("word_kuruma", "freesound", "721413.mp3", None, 0.8),
  ("word_fune", "freesound", "564697.mp3", None, 1.0),  # おもちゃのクラクション（高めのぷー）。低い汽笛 468846 から入れ替え（D156）
  ("word_densha", "freesound", "591842.mp3", None, 0.7),
  ("word_jitensha", "komori", "bicycle_bell1.mp3", None, 1.0),
  ("word_shinkansen", "otologic", "Motion-Swish09-07(High-Short).mp3", None, 1.4),  # OtoLogic の高めのスウィッシュ。Freesound #683101 から入れ替え（D158）
  ("word_ushi", "freesound", "667470.mp3", 2.6, 1.0, 1.7),  # アニメ調の牛を 1.7 倍の速さ（高く短く）。小森平 cow1（低い）から入れ替え
  ("word_inu", "komori", "dog1a.mp3", None, 1.0),
  ("word_neko", "komori", "cat1a.mp3", None, 1.4),
  ("word_uma", "freesound", "269571.mp3", None, 1.5),
  ("word_kuma", "komori", "panda.mp3", None, 1.4),
  ("word_shika", "freesound", "351113.mp3", 5.9, 1.0),  # しかのミューという声（吠え声の続く 696777 から入れ替え）
  ("word_risu", "freesound", "443826.mp3", None, 0.45),
  # 着るもの・はくもの: こんとどぅふぇの「かわいい」から。きもの は ゆかた の音を使う。
  ("word_fuku", "conte", "cute/fluffy/fluffy_03.mp3", None, 1.2),
  ("word_kutsu", "conte", "cute/piece_place/piece_place_06.mp3", None, 1.2),
  ("word_boushi", "conte", "cute/wink/wink_12.mp3", None, 1.2),
  ("word_yukata", "conte", "cute/fluffy/fluffy_09.mp3", None, 1.2),
  ("word_kutsushita", "conte", "cute/zip/zip_06.mp3", None, 1.2),
  # ことばの変身・共通
  ("gather", "conte", "cute/windchime/windchime_11.mp3", None, 1.3),
  ("appear", "otologic", "Water_Drop03-4(High-Dry).mp3", None, 0.5),  # OtoLogic の水滴。こんとどぅふぇ pop_08 から入れ替え（D158）
  # ほめる（D152）
  ("sparkle", "otologic", "Onoma-Flash17-2(High).mp3", None, 0.7),  # OtoLogic のきらっ。こんとどぅふぇ sparkle_06 から入れ替え（D158）
  ("confetti", "otologic", "Bell_Accent16-1(High).mp3", None, 1.2),  # OtoLogic のベル。こんとどぅふぇ success_15 から入れ替え（D158）
  # 画面
  ("tap", "conte", "cute/tap/tap_01.mp3", None, 0.25),
  ("dialog", "conte", "cute/bubble/bubble_11.mp3", None, 0.5),
  ("locked", "conte", "cute/bounce/bounce_15.mp3", None, 0.7),
]


def run(cmd):
  subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def source_path(raw, src, fname):
  if src in ("komori", "freesound"):
    return os.path.join(raw, src, "mp3", fname)
  return os.path.join(raw, src, fname)


def read_samples(path):
  with wave.open(path, "rb") as w:
    a = array.array("h")
    a.frombytes(w.readframes(w.getnframes()))
  return [v / 32768.0 for v in a]


def measure(x):
  """(ピーク dB, アクティブ音量 dB)。analyze_sfx.py と同じ: 10ms 枠・5ms ずらしの RMS で、最大から 40dB 以内の枠の RMS。"""
  size, hop = int(0.010 * SR), int(0.005 * SR)
  env = []
  for s in range(0, max(len(x) - size, 0) + 1, hop):
    fr = x[s : s + size]
    env.append(math.sqrt(sum(v * v for v in fr) / len(fr)))
  top = max(env)
  act = [e for e in env if e > top * 10 ** (-40 / 20)]
  peak = max(abs(v) for v in x)
  to_db = lambda v: 20 * math.log10(max(v, 1e-9))
  return to_db(peak), to_db(math.sqrt(sum(e * e for e in act) / len(act)))


def trim(inp, name, start, length, tmp, speed=1.0):
  """先頭の無音を切り、長さを切り、最後をフェードアウト。モノラル 48kHz の WAV にする。"""
  wav = os.path.join(tmp, name + ".wav")
  filt = ["silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.01"]
  if speed != 1.0:
    # 速さ（高さ）を変える。先に変えるので、開始秒・長さは変えたあとの時間で書く
    pre = [f"aresample={SR}", f"asetrate={SR * speed:.0f}", f"aresample={SR}"]
  else:
    pre = []
  if start is not None:
    filt = [f"atrim=start={start}", "asetpts=PTS-STARTPTS"]
  filt = pre + filt + [
    f"atrim=end={length}",
    "asetpts=PTS-STARTPTS",
    f"afade=t=out:st={max(length - FADE, 0)}:d={FADE}",
  ]
  run([FFMPEG, "-y", "-i", inp, "-af", ",".join(filt), "-ac", "1", "-ar", str(SR), "-c:a", "pcm_s16le", wav])
  return wav


def level(wav, name, tmp):
  """アクティブ音量を TARGET_ACTIVE_DB にそろえた WAV と、(ピーク dB, 元のアクティブ dB, 掛けた dB, 押さえた dB) を返す。"""
  peak, active = measure(read_samples(wav))
  want = TARGET_ACTIVE_DB - active
  headroom = PEAK_CEIL_DB - peak  # ピークを上限に着けるまでに上げられる量
  gain = min(want, headroom + MAX_LIMIT_DB)  # 足りない分はリミッターで押さえて最大 4dB まで
  limited = max(0.0, gain - headroom)
  out = os.path.join(tmp, name + ".norm.wav")
  # limited > 0 のときは、ピークがはみ出る分を alimiter で押さえる（先読み 5ms・戻り 50ms）
  limit = 10 ** (PEAK_CEIL_DB / 20)
  af = f"volume={gain}dB,alimiter=limit={limit:.4f}:attack=5:release=50:level=disabled"
  run([FFMPEG, "-y", "-i", wav, "-af", af, "-ac", "1", "-ar", str(SR), "-c:a", "pcm_s16le", out])
  return out, (peak, active, gain, limited)


def process_one(raw, out_dir, tmp, item):
  name, src, fname, start, length = item[:5]
  speed = item[5] if len(item) > 5 else 1.0
  wav = trim(source_path(raw, src, fname), name, start, length, tmp, speed)
  norm, info = level(wav, name, tmp)
  dest = os.path.join(out_dir, name + ".caf")
  run(["afconvert", "-f", "caff", "-d", "opus", "-b", "32000", norm, dest])
  d = subprocess.run(["afinfo", dest], capture_output=True, text=True).stdout
  dur = re.search(r"estimated duration: ([\d.]+)", d).group(1)
  after = measure(read_samples(norm))
  print(f"{name}: {dur}s, {os.path.getsize(dest)} bytes, 元 ピーク{info[0]:.1f} アクティブ{info[1]:.1f}dB, 掛けた{info[2]:+.1f}dB（リミッター{info[3]:.1f}dB）, 後 ピーク{after[0]:.1f} アクティブ{after[1]:.1f}dB")


def main():
  if len(sys.argv) != 3:
    print(__doc__)
    sys.exit(2)
  raw, out_dir = sys.argv[1], sys.argv[2]
  os.makedirs(out_dir, exist_ok=True)
  with tempfile.TemporaryDirectory() as tmp:
    for item in ITEMS:
      process_one(raw, out_dir, tmp, item)


if __name__ == "__main__":
  main()
