#!/usr/bin/env python3 -I
"""効果音の素材を、アプリに入れる形（Opus in CAF・モノラル・48kHz）に整える（D111・D149）。

使い方:
  python3 -I Scripts/process_sfx.py <素材の raw フォルダ> App/Mojimachi/Resources/Sounds

raw フォルダは `<源>/mp3/<元のファイル>` の形（源: komori, freesound）。
道具は ffmpeg（先頭の無音を切る・長さを切る・フェードアウト・ピークをそろえる）と
afconvert（Opus の CAF）と afinfo。どれも Mac にある。素材は音のデータとしてだけ扱う。
出どころは App/Mojimachi/Resources/Sounds/provenance.csv に書く（手で更新する）。
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile

FFMPEG = shutil.which("ffmpeg") or "/opt/homebrew/bin/ffmpeg"

# 名前, 源, 元ファイル, 開始秒(省略は先頭の無音を自動で切る), 長さ(秒), ピーク(dBFS)
# 名前は SoundPlayer.Effect の fileName と同じ（ファイル名は半角英数字）。きもの は ゆかた の音を使う。
ITEMS = [
  # ことばの変身（D43・D53）
  ("word_sori", "freesound", "369506.mp3", None, 0.9, -3),
  ("word_kuruma", "freesound", "721413.mp3", None, 0.8, -3),
  ("word_fune", "freesound", "468846.mp3", None, 1.6, -3),
  ("word_densha", "freesound", "591842.mp3", None, 0.7, -3),
  ("word_jitensha", "komori", "bicycle_bell1.mp3", None, 1.0, -3),
  ("word_shinkansen", "freesound", "683101.mp3", None, 1.4, -4),
  ("word_ushi", "komori", "cow1.mp3", None, 1.8, -3),
  ("word_inu", "komori", "dog1a.mp3", None, 1.0, -3),
  ("word_neko", "komori", "cat1a.mp3", None, 1.4, -3),
  ("word_uma", "freesound", "269571.mp3", None, 1.5, -3),
  ("word_kuma", "komori", "panda.mp3", None, 1.4, -3),
  ("word_shika", "freesound", "696777.mp3", None, 1.5, -3),
  ("word_risu", "freesound", "443826.mp3", None, 0.45, -3),
  ("word_fuku", "komori", "rustle_of_clothes.mp3", None, 1.1, -5),
  ("word_kutsu", "komori", "put_shoes.mp3", None, 0.9, -4),
  ("word_boushi", "freesound", "516830.mp3", None, 0.55, -4),
  ("word_yukata", "freesound", "320144.mp3", None, 1.2, -5),
  ("word_kutsushita", "freesound", "494797.mp3", None, 0.4, -4),
  # ことばの変身・共通
  ("gather", "freesound", "511485.mp3", None, 1.3, -5),
  ("appear", "komori", "poyo.mp3", None, 0.8, -3),
  # ほめる（D152）
  ("sparkle", "freesound", "462095.mp3", None, 1.8, -5),
  ("confetti", "komori", "party_popper1.mp3", None, 0.8, -5),
  # 画面
  ("tap", "freesound", "878244.mp3", None, 0.25, -8),
  ("dialog", "freesound", "878253.mp3", None, 0.5, -7),
  ("locked", "freesound", "277290.mp3", None, 0.7, -6),
]


def run(cmd):
  subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def process(raw, out_dir, tmp):
  for name, src, fname, start, length, peak in ITEMS:
    inp = os.path.join(raw, src, "mp3", fname)
    wav = os.path.join(tmp, name + ".wav")
    # 1) 先頭の無音を切り、長さを切って、最後を 60ms でフェードアウト、モノラル 48kHz。
    fade = 0.06
    filt = ["silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.01"]
    if start is not None:
      filt = [f"atrim=start={start}"]
    filt += [
      f"atrim=end={length}",
      "asetpts=PTS-STARTPTS",
      f"afade=t=out:st={max(length - fade, 0)}:d={fade}",
    ]
    run([FFMPEG, "-y", "-i", inp, "-af", ",".join(filt), "-ac", "1", "-ar", "48000", wav])
    # 2) ピークをそろえる。
    probe = subprocess.run(
      [FFMPEG, "-i", wav, "-af", "volumedetect", "-f", "null", "-"],
      capture_output=True, text=True,
    ).stderr
    max_db = float(re.search(r"max_volume: (-?[\d.]+) dB", probe).group(1))
    gain = peak - max_db
    norm = os.path.join(tmp, name + ".norm.wav")
    run([FFMPEG, "-y", "-i", wav, "-af", f"volume={gain}dB,alimiter=limit=0.95", "-ac", "1", "-ar", "48000", norm])
    # 3) Opus in CAF。
    dest = os.path.join(out_dir, name + ".caf")
    run(["afconvert", "-f", "caff", "-d", "opus", "-b", "32000", norm, dest])
    info = subprocess.run(["afinfo", dest], capture_output=True, text=True).stdout
    dur = re.search(r"estimated duration: ([\d.]+)", info).group(1)
    print(f"{name}: {dur}s, {os.path.getsize(dest)} bytes")


def main():
  if len(sys.argv) != 3:
    print(__doc__)
    sys.exit(2)
  raw, out_dir = sys.argv[1], sys.argv[2]
  os.makedirs(out_dir, exist_ok=True)
  with tempfile.TemporaryDirectory() as tmp:
    process(raw, out_dir, tmp)


if __name__ == "__main__":
  main()
