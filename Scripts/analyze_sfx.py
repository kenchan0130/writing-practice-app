#!/usr/bin/env python3 -I
"""効果音を耳ではなく波形から調べ、子ども向けとして「かわいい・安全」か「要確認」かを見積もる。
アプリには入らない開発用の道具。numpy / scipy / matplotlib が要る（docs/dependencies.md）。

使い方:
  python3 -I Scripts/analyze_sfx.py <Sounds フォルダ> <出力フォルダ> [レポート用 JSON]
  例: <venv>/bin/python3 -I Scripts/analyze_sfx.py App/Mojimachi/Resources/Sounds <scratch>/sfx/analysis

やること:
  1. afconvert で .caf を 48kHz モノラル 16bit WAV にする（出力フォルダの wav/）。
  2. 基準の音（SoundKit の Tones.swift と同じ式で作ったやさしい音）も作る。
  3. 音ごとに数値を出し、かわいさのスコア（0〜100）と「要確認」の印を付ける。
  4. 波形とスペクトログラムの PNG、一覧の contact sheet を作る。
  音量そろえの案 gain_db: アクティブ音量を中央値に寄せる量。ピークが -1dBFS を超えないように上げ幅を抑える（下げ幅は -12dB まで）。
  限界: 基本周波数（YIN）は、ノイズが多い音・声の高い音では取れない（"-" や 3000 は信用しない）。
  人の耳の代わりにはならない。最後は必ず耳で聞くこと。

スコア（透明な経験則。耳の代わりではない）:
  各項目を 0〜1 にして重みをかける。
    pitch   0.20  音の高さ。200Hz 以下は 0、800Hz 以上は 1。取れないとき（ノイズ）は 0.5。
    bright  0.15  スペクトルの重心。500Hz 以下は 0、3000Hz 以上は 1。
    short   0.10  長さ。0.6秒以下は 1、2.0秒以上は 0。
    attack  0.10  立ち上がり。2〜30ms が最良。0.5ms 未満（カチッ）は 0.3。長すぎる（200ms〜）も下げる。
    tonal   0.15  音のまとまり（平坦度が低い）。平坦度 0.02 以下で 1、0.3 以上で 0。
    sub     0.10  低音の少なさ。300Hz 未満のエネルギー比が 2% 以下で 1、40% 以上で 0。
    smooth  0.05  終わりがなめらか（最後の 20ms が小さい）。
    rough   0.05  ざらつきが少ない（20〜150Hz の振幅の揺れ）。
    clip    0.05  割れていない（ピーク -0.5dBFS 以下）。
    level   0.05  セット全体の音量とそろっている（中央値から ±3dB 以内で 1、±9dB で 0）。
  合計 ×100。
「要確認」の条件（どれかに当たったら印）:
  LOW   150Hz 未満のエネルギー比 > 10% または 300Hz 未満 > 35%
  NOISY 平坦度の中央値 > 0.25（ほぼノイズ）。ただし、ふわっと系（衣ずれ等）は意図なので理由に書く
  ROUGH 振幅の揺れの強さ > 0.35 かつ 平坦度 > 0.05（ガラガラ・うなり）
  ABRUPT 立ち上がり < 1ms かつ ピークが大きく（RMS 比のクレスト > 9dB）長さ > 0.3 秒（短い UI タップは除く）
  TAIL  -40dB までの余韻が 1.2 秒以上
  GROWL 基本周波数が 250Hz 未満で、音が長く 0.4 秒以上
  LOUD  アクティブ音量が中央値から ±4dB より外れる
  CLIP  ピークが -0.5dBFS を超える
"""

import csv
import json
import math
import os
import subprocess
import sys
import wave

import numpy as np
from scipy import signal

SR = 48_000


def decode(src, dst):
    subprocess.run(
        ["afconvert", "-f", "WAVE", "-d", f"LEI16@{SR}", "-c", "1", src, dst], check=True
    )


def read_wav(path):
    with wave.open(path, "rb") as w:
        assert w.getframerate() == SR and w.getnchannels() == 1
        data = np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(np.float64)
    return data / 32768.0


def write_wav(path, x):
    pcm = (np.clip(x, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


# ---- 基準の音（Packages/Sources/SoundKit/Tones.swift と同じ式。サンプリング周波数だけ 48kHz） ----
def tone_note(freq, dur, vol=0.5):
    n = int(dur * SR)
    att = int(0.005 * SR)
    i = np.arange(n)
    t = i / SR
    env = np.where(i < att, i / att, np.exp(-4 * (i - att) / n))
    wave_ = np.sin(2 * np.pi * freq * t) + 0.25 * np.sin(4 * np.pi * freq * t)
    return wave_ / 1.25 * env * vol


SCALE = [523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77]


def references():
    praise = np.concatenate(
        [tone_note(f, 0.14) for f in (SCALE[0], SCALE[2], SCALE[4], SCALE[0] * 2)]
        + [tone_note(SCALE[0] * 2, 0.4)]
    )
    return {
        "ref_stroke_do": tone_note(SCALE[0], 0.25),
        "ref_stroke_so": tone_note(SCALE[4], 0.25),
        "ref_praise": praise,
        "ref_tap": tone_note(SCALE[4], 0.06, 0.3),
    }


# ---- 数値 ----
def db(x):
    return 20 * math.log10(max(x, 1e-9))


def frames(x, size, hop):
    n = 1 + max(0, (len(x) - size) // hop)
    pad = np.pad(x, (0, max(0, size + (n - 1) * hop - len(x))))
    idx = np.arange(size)[None, :] + hop * np.arange(n)[:, None]
    return pad[idx]


def yin(frame, fmin=80.0, fmax=3000.0, thr=0.15):
    """YIN。(周波数, 明瞭さ 0〜1) を返す。取れなければ (None, 0)。"""
    tau_max = int(SR / fmin)
    tau_min = int(SR / fmax)
    n = len(frame) - tau_max
    if n <= 0:
        return None, 0.0
    f = frame
    cs = np.concatenate([[0], np.cumsum(f * f)])
    d = np.zeros(tau_max + 1)
    for tau in range(1, tau_max + 1):
        e1 = cs[n] - cs[0]
        e2 = cs[n + tau] - cs[tau]
        d[tau] = e1 + e2 - 2 * float(np.dot(f[:n], f[tau : tau + n]))
    cm = np.ones_like(d)
    run = np.cumsum(d[1:])
    cm[1:] = d[1:] * np.arange(1, tau_max + 1) / np.maximum(run, 1e-12)
    for tau in range(tau_min, tau_max):
        if cm[tau] < thr:
            while tau + 1 < tau_max and cm[tau + 1] < cm[tau]:
                tau += 1
            return SR / tau, 1 - cm[tau]
    return None, 0.0


def analyze(x):
    r = {}
    n = len(x)
    r["dur"] = n / SR
    peak = np.max(np.abs(x))
    r["peak_db"] = db(peak)
    r["clip"] = bool(r["peak_db"] > -0.5)
    r["rms_db"] = db(math.sqrt(np.mean(x * x)))
    r["crest_db"] = r["peak_db"] - r["rms_db"]

    # 短時間 RMS（10ms）で包絡線
    hop = int(0.005 * SR)
    fr = frames(x, int(0.010 * SR), hop)
    env = np.sqrt(np.mean(fr * fr, axis=1))
    env_db = 20 * np.log10(np.maximum(env, 1e-9))
    top = env_db.max()
    # アクティブ音量: 最大から 40dB 以内のフレームの RMS
    act = env_db > top - 40
    r["active_rms_db"] = db(math.sqrt(np.mean(env[act] ** 2)))
    # 400ms の短時間ラウドネス（最大）
    w400 = frames(x, int(0.4 * SR), int(0.1 * SR))
    r["short_term_db"] = db(math.sqrt(np.max(np.mean(w400 * w400, axis=1))))

    # 立ち上がり 10%→90%（サンプル単位の絶対値を 1ms で平滑した包絡線）
    sm = int(0.0005 * SR)
    a = np.abs(x)
    a = np.convolve(a, np.ones(sm) / sm, mode="same") if sm > 1 else a
    pk_i = int(np.argmax(a))
    pk = a[pk_i]
    i10 = int(np.argmax(a[: pk_i + 1] >= 0.1 * pk))
    i90 = int(np.argmax(a[: pk_i + 1] >= 0.9 * pk))
    r["attack_ms"] = max(i90 - i10, 0) / SR * 1000
    r["peak_time_ms"] = pk_i / SR * 1000

    # 余韻: ピークのあと、10ms の包絡線が最後に -40dB を超える時刻 − ピークの時刻
    ipk = int(np.argmax(env_db))
    above = np.where(env_db > top - 40)[0]
    r["tail_s"] = (above.max() - ipk) * hop / SR if len(above) else 0.0
    last = x[-int(0.02 * SR) :]
    r["end_db"] = db(math.sqrt(np.mean(last * last))) - r["peak_db"]  # 最後の 20ms のピーク比

    # スペクトル（アクティブ部分の平均パワー）
    seg = x[: int(min(n, (above.max() + 2) * hop + SR * 0.01))] if len(above) else x
    f, p = signal.welch(seg, SR, nperseg=2048, noverlap=1536)
    tot = p.sum() + 1e-18
    r["centroid_hz"] = float((f * p).sum() / tot)
    r["low150"] = float(p[f < 150].sum() / tot)
    r["low300"] = float(p[f < 300].sum() / tot)
    r["high4k"] = float(p[f > 4000].sum() / tot)

    # 平坦度: 200〜8000Hz、各フレームの幾何平均/算術平均。エネルギーが大きいフレームの中央値
    fr2 = frames(x, 2048, 1024)
    e2 = np.mean(fr2 * fr2, axis=1)
    keep = e2 > e2.max() * 1e-3
    win = np.hanning(2048)
    spec = np.abs(np.fft.rfft(fr2 * win, axis=1)) ** 2 + 1e-18
    fb = np.fft.rfftfreq(2048, 1 / SR)
    band = (fb >= 200) & (fb <= 8000)
    sb = spec[:, band]
    flat = np.exp(np.mean(np.log(sb), axis=1)) / np.mean(sb, axis=1)
    r["flatness"] = float(np.median(flat[keep])) if keep.any() else 1.0

    # 基本周波数（YIN。1024サンプル窓、エネルギーが大きいフレームだけ）
    f0s = []
    for i in np.where(keep)[0][:: max(1, keep.sum() // 40)]:
        fr1 = x[i * 1024 : i * 1024 + 2048 + 600]
        if len(fr1) < 2048:
            continue
        hz, clar = yin(fr1[:2048], fmin=100.0, fmax=3000.0)
        if hz and clar > 0.7:
            f0s.append(hz)
    r["voiced_ratio"] = len(f0s) / max(1, len(np.where(keep)[0][:: max(1, keep.sum() // 40)]))
    if len(f0s) >= 2 and r["voiced_ratio"] >= 0.3:
        m = float(np.median(f0s))
        r["f0_hz"] = m
        cents = 1200 * np.log2(np.array(f0s) / m)
        r["f0_stab_cents"] = float(np.std(cents))
    else:
        r["f0_hz"] = None
        r["f0_stab_cents"] = None

    # ざらつき: 包絡線（整流 → 1kHz でローパス）の 20〜150Hz 成分の強さ ÷ 平均
    rect = np.abs(x)
    sos = signal.butter(2, 1000, "low", fs=SR, output="sos")
    e = signal.sosfiltfilt(sos, rect)
    sos2 = signal.butter(2, [20, 150], "band", fs=SR, output="sos")
    am = signal.sosfiltfilt(sos2, e)
    act_idx = np.arange(len(x))
    m = e[: int(min(n, (above.max() + 2) * hop))] if len(above) else e
    m_am = am[: len(m)]
    r["rough"] = float(np.std(m_am) / (np.mean(m) + 1e-9))
    return r


def clamp01(v):
    return max(0.0, min(1.0, v))


def lin(v, a, b):
    return clamp01((v - a) / (b - a))


def score(r, median_active):
    s = {}
    s["pitch"] = lin(r["f0_hz"], 200, 800) if r["f0_hz"] else 0.5
    s["bright"] = lin(r["centroid_hz"], 500, 3000)
    s["short"] = 1 - lin(r["dur"], 0.6, 2.0)
    a = r["attack_ms"]
    if a < 0.5:
        s["attack"] = 0.3
    elif a < 2:
        s["attack"] = 0.3 + 0.7 * (a - 0.5) / 1.5
    elif a <= 30:
        s["attack"] = 1.0
    elif a <= 200:
        s["attack"] = 1.0 - 0.3 * (a - 30) / 170
    else:
        s["attack"] = 0.5
    s["tonal"] = 1 - lin(r["flatness"], 0.02, 0.3)
    s["sub"] = 1 - lin(r["low300"], 0.02, 0.40)
    s["smooth"] = lin(-r["end_db"], 6, 30)
    s["rough"] = 1 - lin(r["rough"], 0.1, 0.5)
    s["clip"] = 0.0 if r["clip"] else 1.0
    s["level"] = 1 - lin(abs(r["active_rms_db"] - median_active), 3, 9)
    w = dict(pitch=.20, bright=.15, short=.10, attack=.10, tonal=.15, sub=.10, smooth=.05,
             rough=.05, clip=.05, level=.05)
    return 100 * sum(s[k] * w[k] for k in w), s


def flags(r, median_active, is_ui):
    out = []
    if r["low150"] > 0.10 or r["low300"] > 0.35:
        out.append("LOW")
    if r["flatness"] > 0.25:
        out.append("NOISY")
    if r["rough"] > 0.35 and r["flatness"] > 0.05:
        out.append("ROUGH")
    if r["attack_ms"] < 1 and r["crest_db"] > 9 and r["dur"] > 0.3 and not is_ui:
        out.append("ABRUPT")
    if r["tail_s"] >= 1.2:
        out.append("TAIL")
    if r["f0_hz"] and r["f0_hz"] < 250 and r["dur"] >= 0.4:
        out.append("GROWL")
    d = r["active_rms_db"] - median_active
    if abs(d) > 4:
        out.append("LOUD" if d > 0 else "QUIET")
    if r["clip"]:
        out.append("CLIP")
    return out


# ---- 図 ----
def plots(name, x, r, outdir):
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(2, 1, figsize=(6, 4), sharex=True, gridspec_kw={"height_ratios": [1, 2]})
    t = np.arange(len(x)) / SR
    ax[0].plot(t, x, lw=0.4)
    ax[0].set_ylim(-1, 1)
    ax[0].set_title(f"{name}  {r['dur']:.2f}s  peak {r['peak_db']:.1f}dB", fontsize=9)
    ax[1].specgram(x, NFFT=1024, Fs=SR, noverlap=768, cmap="magma", vmin=-110, vmax=-20)
    ax[1].set_ylim(0, 10000)
    ax[1].set_ylabel("Hz")
    ax[1].set_xlabel("s")
    fig.tight_layout()
    p = os.path.join(outdir, name + ".png")
    fig.savefig(p, dpi=80)
    plt.close(fig)
    return p


def contact_sheet(items, outpath):
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    cols = 5
    rows = math.ceil(len(items) / cols)
    fig, axs = plt.subplots(rows, cols, figsize=(cols * 3.2, rows * 2.2))
    for ax in axs.flat:
        ax.axis("off")
    for ax, (name, x, r, sc, fl) in zip(axs.flat, items):
        ax.axis("on")
        ax.specgram(x, NFFT=1024, Fs=SR, noverlap=768, cmap="magma", vmin=-110, vmax=-20)
        ax.set_ylim(0, 8000)
        ax.set_xticks([])
        ax.set_yticks([0, 2000, 4000, 8000])
        ax.tick_params(labelsize=6)
        ax.set_title(f"{name} {sc:.0f} {','.join(fl) or 'ok'}", fontsize=7,
                     color="red" if fl else "black")
    fig.tight_layout()
    fig.savefig(outpath, dpi=90)
    plt.close(fig)


UI = {"tap", "dialog", "locked", "appear"}


def main():
    sounds, outdir = sys.argv[1], sys.argv[2]
    jpath = sys.argv[3] if len(sys.argv) > 3 else os.path.join(outdir, "results.json")
    os.makedirs(os.path.join(outdir, "wav"), exist_ok=True)
    pngdir = os.path.join(outdir, "png")
    os.makedirs(pngdir, exist_ok=True)

    sigs = {}
    for fn in sorted(os.listdir(sounds)):
        if fn.endswith(".caf"):
            wav = os.path.join(outdir, "wav", fn[:-4] + ".wav")
            decode(os.path.join(sounds, fn), wav)
            sigs[fn[:-4]] = read_wav(wav)
    refs = references()
    for k, v in refs.items():
        write_wav(os.path.join(outdir, "wav", k + ".wav"), v)

    res = {k: analyze(v) for k, v in {**sigs, **refs}.items()}
    # 音量の中央値は 25 個の本番の音だけから
    med = float(np.median([res[k]["active_rms_db"] for k in sigs]))
    items = []
    for k, x in {**sigs, **refs}.items():
        r = res[k]
        sc, parts = score(r, med)
        fl = flags(r, med, k in UI or k.startswith("ref_"))
        r.update(score=sc, parts=parts, flags=fl, ref=k.startswith("ref_"),
                 gain_db=max(min(med - r["active_rms_db"], -1.0 - r["peak_db"]), -12.0))
        plots(k, x, r, pngdir)
        items.append((k, x, r, sc, fl))
    contact_sheet(items, os.path.join(outdir, "contact_sheet.png"))
    with open(jpath, "w") as f:
        json.dump({"median_active_db": med, "sounds": res}, f, ensure_ascii=False, indent=1)

    print(f"median active rms: {med:.1f} dB")
    hdr = "name           dur  peak  act  atk_ms tail  cent  low150 low300 f0     stab  flat  rough crest score gain  flags"
    print(hdr)
    for k, x, r, sc, fl in sorted(items, key=lambda i: i[3]):
        f0 = f"{r['f0_hz']:6.0f}" if r["f0_hz"] else "   -  "
        st = f"{r['f0_stab_cents']:5.0f}" if r["f0_stab_cents"] is not None else "  -  "
        print(f"{k:14s} {r['dur']:4.2f} {r['peak_db']:5.1f} {r['active_rms_db']:5.1f} {r['attack_ms']:6.1f} "
              f"{r['tail_s']:4.2f} {r['centroid_hz']:5.0f} {r['low150']:.3f}  {r['low300']:.3f}  {f0} {st} "
              f"{r['flatness']:.3f} {r['rough']:.2f} {r['crest_db']:5.1f} {sc:5.1f} {r['gain_db']:+.1f} {','.join(fl)}")


if __name__ == "__main__":
    main()
