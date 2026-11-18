#!/usr/bin/env python3 -I
"""声のファイルを VOICEVOX で作って、アプリに入れる形にする（D162）。

使い方（VOICEVOX のエンジンを http://localhost:50021 で動かしておく）:
  python3 -I Scripts/make_voices.py Content/Voices/lines.csv App/Mojimachi/Resources/Voices Content/Voices/provenance.csv

lines.csv の列: id, text, style(normal|ochitsuki), reading, aliases
  text      アプリが `VoicePlayer` に渡す文字。字幕にも出る。
  reading   空でなければ、これを読ませる（は→ハ、ちいさい つ など）。
  aliases   同じ声を使う別の文字（カタカナなど。空白なしで1字ずつ）。
やること:
  1. 声は 猫使ビィ。ノーマル（speaker 58）かおちつき（59）。速さ・高さ・抑揚はエンジンの初期値のまま。
  2. 前後の無音を切る・最後を 30ms フェードアウト・モノラル 48kHz。
  3. 音量をそろえる（Scripts/process_sfx.py の level() をそのまま使う。アクティブ音量 -18.5dB、ピーク -1.5dBFS 以下）。
  4. Opus 24kbps in CAF。
  5. 文字→ファイル名の表 `voices.json` と、出どころの表（provenance.csv）を書く。
"""
import csv
import datetime
import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request

ENGINE = "http://localhost:50021"
STYLES = {"normal": 58, "ochitsuki": 59}
STYLE_NAMES = {"normal": "ノーマル", "ochitsuki": "おちつき"}
SPEAKER = "猫使ビィ"
BITRATE = "24000"
FADE = 0.03

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("process_sfx", os.path.join(HERE, "process_sfx.py"))
sfx = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sfx)


def post(path, params, body=None):
  url = ENGINE + path + "?" + urllib.parse.urlencode(params)
  headers = {"Content-Type": "application/json"} if body is not None else {}
  data = json.dumps(body).encode() if body is not None else b""
  req = urllib.request.Request(url, data=data, headers=headers, method="POST")
  with urllib.request.urlopen(req, timeout=60) as r:
    return r.read()


def synthesize(text, speaker, dest):
  query = json.loads(post("/audio_query", {"speaker": speaker, "text": text}))
  wav = post("/synthesis", {"speaker": speaker}, query)
  with open(dest, "wb") as f:
    f.write(wav)
  return query["kana"]


def trim(inp, name, tmp):
  """前後の無音を切り、最後をフェードアウト。モノラル 48kHz の WAV にする。"""
  out = os.path.join(tmp, name + ".trim.wav")
  cut = "silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.03"
  # 末尾は、反転して先頭と同じに切る
  filt = f"{cut},areverse,{cut},areverse"
  sfx.run([sfx.FFMPEG, "-y", "-i", inp, "-af", filt, "-ac", "1", "-ar", str(sfx.SR), "-c:a", "pcm_s16le", out])
  dur = len(sfx.read_samples(out)) / sfx.SR
  fade = os.path.join(tmp, name + ".fade.wav")
  af = f"afade=t=out:st={max(dur - FADE, 0):.4f}:d={FADE}"
  sfx.run([sfx.FFMPEG, "-y", "-i", out, "-af", af, "-ac", "1", "-ar", str(sfx.SR), "-c:a", "pcm_s16le", fade])
  return fade


def main():
  if len(sys.argv) != 4:
    print(__doc__)
    sys.exit(2)
  lines_path, out_dir, prov_path = sys.argv[1:4]
  version = json.loads(urllib.request.urlopen(ENGINE + "/version").read())
  today = datetime.date.today().isoformat()
  os.makedirs(out_dir, exist_ok=True)
  with open(lines_path, newline="", encoding="utf-8") as f:
    rows = list(csv.DictReader(f))

  manifest = {}
  prov = []
  report = []
  with tempfile.TemporaryDirectory() as tmp:
    for r in rows:
      name = "voice_" + r["id"]
      speaker = STYLES[r["style"]]
      said = r["reading"] or r["text"]
      raw = os.path.join(tmp, name + ".raw.wav")
      kana = synthesize(said, speaker, raw)
      wav = trim(raw, name, tmp)
      norm, info = sfx.level(wav, name, tmp)
      dest = os.path.join(out_dir, name + ".caf")
      sfx.run(["afconvert", "-f", "caff", "-d", "opus", "-b", BITRATE, norm, dest])
      d = subprocess.run(["afinfo", dest], capture_output=True, text=True).stdout
      dur = float(re.search(r"estimated duration: ([\d.]+)", d).group(1))
      peak, active = sfx.measure(sfx.read_samples(norm))
      rms_ok = active > -30 and peak < -1.0 and dur > 0.15
      report.append((name, dur, os.path.getsize(dest), peak, active, rms_ok))
      print(f'{name}: {r["text"]} [{kana}] {dur:.2f}s {os.path.getsize(dest)}B ピーク{peak:.1f} アクティブ{active:.1f}dB{"" if rms_ok else "  ← 要確認"}')
      for key in [r["text"]] + list(r["aliases"]):
        assert key not in manifest, f"文字がかぶっています: {key}"
        manifest[key] = name
      prov.append([name + ".caf", r["text"], said if r["reading"] else "", SPEAKER, f'{speaker}（{STYLE_NAMES[r["style"]]}）', version, today])

  with open(os.path.join(out_dir, "voices.json"), "w", encoding="utf-8") as f:
    json.dump({"engine": version, "files": manifest}, f, ensure_ascii=False, indent=1, sort_keys=True)
    f.write("\n")
  with open(prov_path, "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f, lineterminator="\n")
    w.writerow(["file", "text", "reading override", "speaker", "style id", "engine version", "date"])
    w.writerows(prov)
  total = sum(x[2] for x in report)
  print(f"{len(report)} 個、合計 {total} バイト、最長 {max(x[1] for x in report):.2f}s、最短 {min(x[1] for x in report):.2f}s")
  bad = [x[0] for x in report if not x[5]]
  if bad:
    print("要確認:", bad)
    sys.exit(1)


if __name__ == "__main__":
  main()
