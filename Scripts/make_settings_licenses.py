#!/usr/bin/env python3
"""iOS の「設定」アプリの もじまち のページに出す、ライセンスと出どころ（D196）を作る。

作るもの: App/Mojimachi/Settings.bundle（Root.plist・Licenses.plist・各ページの plist・ja/en の .strings）

もとにするもの（ここに書いた文は、もとのファイルが変わったら作り直す）:
- ライブラリ: App/Mojimachi.xcodeproj/.../Package.resolved（版）と、各パッケージの LICENSE（全文。写して使う）。
  LICENSE は、SwiftPM の checkouts があればそこから、なければ gh api で固定した版から取る。
- 声・効果音・書体: App/Mojimachi/Resources/{Voices,Sounds,Fonts} の NOTICE と OFL の全文。
- 文字のデータ: Content/Packs/hira/LICENSE（strokesvg の MIT と Klee One の OFL）と NOTICE.md のコミット。

使い方: python3 -I Scripts/make_settings_licenses.py [checkouts のフォルダ]
"""

import base64
import json
import plistlib
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "App/Mojimachi/Settings.bundle"
RESOLVED = ROOT / "App/Mojimachi.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
RES = ROOT / "App/Mojimachi/Resources"

# アプリに入らない（ビルド時のマクロだけ）ので載せないパッケージ。docs/dependencies.md の層 A の注。
EXCLUDE = {"swift-syntax"}

# 声のクレジットは、規約（VOICEVOX・猫使ビィ）どおりにこの形で出す。設定アプリの もじまち のページの一番上にも置く。
VOICE_CREDIT = "VOICEVOX:猫使ビィ"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8").replace("\r\n", "\n").strip("\n")


def drop_first_line(text: str) -> str:
    return text.split("\n", 1)[1].lstrip("\n")


# ---- ライセンス全文 ----------------------------------------------------------


def checkout_dirs() -> list[Path]:
    dirs = []
    if len(sys.argv) > 1:
        dirs.append(Path(sys.argv[1]))
    dirs.append(ROOT / "build/DerivedData/SourcePackages/checkouts")
    dd = Path.home() / "Library/Developer/Xcode/DerivedData"
    if dd.exists():
        dirs += sorted(dd.glob("Mojimachi-*/SourcePackages/checkouts"))
    return [d for d in dirs if d.exists()]


def fetch_file(pin: dict, names: list[str], dirs: list[Path]) -> tuple[str, str] | None:
    """(ファイル名, 中身)。checkouts にあって、版が同じものを使い、なければ gh api で取る。"""
    ident = pin["identity"]
    for d in dirs:
        pkg = d / ident
        for n in names:
            f = pkg / n
            if f.exists() and checkout_revision(pkg) in (None, pin["state"]["revision"]):
                return n, read(f)
    m = re.match(r"https://github\.com/([^/]+)/([^/.]+)", pin["location"])
    owner, repo = m.group(1), m.group(2)
    for n in names:
        r = subprocess.run(
            ["gh", "api", f"repos/{owner}/{repo}/contents/{n}?ref={pin['state']['revision']}", "--jq", ".content"],
            capture_output=True,
            text=True,
        )
        if r.returncode == 0 and r.stdout.strip():
            return n, base64.b64decode(r.stdout).decode("utf-8").replace("\r\n", "\n").strip("\n")
    return None


def checkout_revision(pkg: Path) -> str | None:
    head = pkg / ".git/HEAD"
    try:
        return head.read_text().strip()
    except OSError:
        return None


def spdx(text: str) -> str:
    if "Apache License" in text:
        return "Apache-2.0"
    if text.lstrip().startswith("MIT License") or "Permission is hereby granted, free of charge" in text:
        return "MIT"
    return "?"


# ---- ページの中身 ------------------------------------------------------------
# page = (id, ja の題, en の題, [(ja のグループの題, en の題, ja の本文, en の本文)])


def build_pages() -> tuple[list, list]:
    content_pages = []
    lib_pages = []

    voices = drop_first_line(read(RES / "Voices/VOICES-NOTICE.txt"))
    content_pages.append(
        (
            "voice",
            f"声（{VOICE_CREDIT}）",
            f"Voices ({VOICE_CREDIT})",
            [
                (
                    VOICE_CREDIT,
                    VOICE_CREDIT,
                    voices,
                    "The voices in this app (readings of letters and words, and the characters' lines) were made with the speech synthesis software VOICEVOX.\n"
                    f"Credit: {VOICE_CREDIT}\n\n" + voices,
                )
            ],
        )
    )

    sounds = drop_first_line(read(RES / "Sounds/SOUNDS-NOTICE.txt"))
    sounds = "\n".join(l for l in sounds.split("\n") if "開発用" not in l).strip("\n")
    content_pages.append(
        (
            "sounds",
            "効果音",
            "Sound effects",
            [
                (
                    "効果音",
                    "Sound effects",
                    sounds,
                    "Sound effects come from the sources below: Taira Komori (Free Sound Effects), Freesound (CC0 only), OtoLogic (CC BY 4.0) and Conte de Fées.\n\n"
                    + sounds,
                )
            ],
        )
    )

    fonts = drop_first_line(read(RES / "Fonts/FONTS-NOTICE.txt"))
    fonts = fonts.replace("ライセンスの全文は、同じ場所の OFL-KleeOne.txt と OFL-ZenMaruGothic.txt にあります。", "ライセンスの全文は、下にあります。")
    kl = read(RES / "Fonts/OFL-KleeOne.txt")
    zm = read(RES / "Fonts/OFL-ZenMaruGothic.txt")
    en_fonts = "The app uses Klee One and Zen Maru Gothic under the SIL Open Font License 1.1. The full licence texts are below.\n\n" + fonts
    content_pages.append(
        (
            "fonts",
            "書体（Klee One・Zen Maru Gothic）",
            "Fonts (Klee One, Zen Maru Gothic)",
            [
                ("書体", "Fonts", fonts, en_fonts),
                ("Klee One（SIL OFL 1.1）", "Klee One (SIL OFL 1.1)", kl, kl),
                ("Zen Maru Gothic（SIL OFL 1.1）", "Zen Maru Gothic (SIL OFL 1.1)", zm, zm),
            ],
        )
    )

    notice = read(ROOT / "Content/Packs/hira/NOTICE.md")
    commit = re.search(r"コミット `([0-9a-f]{40})`", notice).group(1)
    lic = read(ROOT / "Content/Packs/hira/LICENSE")
    ja = (
        f"ひらがな・カタカナの書き順と字の形のデータは、strokesvg（https://github.com/zhengkyl/strokesvg 、コミット {commit}）をもとに作りました。\n"
        "strokesvg は MIT License（Copyright (c) 2024 Kyle）。かなの形は Klee One（Copyright 2020 The Klee Project Authors。SIL Open Font License 1.1）から作られています。ライセンスの全文は下にあります。\n\n"
        "書き順と画数の確認に、KanjiVG（https://kanjivg.tagaini.net/ 、CC BY-SA 3.0）を使いました。KanjiVG のデータは、アプリには入っていません。\n\n"
        "アルファベットと数字のデータは、自分たちで作りました。"
    )
    en = (
        f"The stroke order and shape data for hiragana and katakana is based on strokesvg (https://github.com/zhengkyl/strokesvg , commit {commit}), "
        "licensed under the MIT License (Copyright (c) 2024 Kyle). The kana shapes derive from Klee One (Copyright 2020 The Klee Project Authors, SIL Open Font License 1.1). The full licence texts are below.\n\n"
        "KanjiVG (https://kanjivg.tagaini.net/ , CC BY-SA 3.0) was used only to check stroke order and counts. No KanjiVG data is included in the app.\n\n"
        "The alphabet and digit data was made by the app's authors."
    )
    content_pages.append(
        (
            "strokes",
            "文字のデータ（strokesvg・Klee One）",
            "Letter data (strokesvg, Klee One)",
            [
                ("文字のデータ", "Letter data", ja, en),
                ("strokesvg・Klee One のライセンス", "strokesvg and Klee One licences", lic, lic),
            ],
        )
    )

    pins = json.loads(RESOLVED.read_text())["pins"]
    dirs = checkout_dirs()
    for pin in pins:
        ident = pin["identity"]
        if ident in EXCLUDE:
            continue
        got = fetch_file(pin, ["LICENSE", "LICENSE.md", "LICENSE.txt"], dirs)
        if got is None:
            sys.exit(f"{ident}: LICENSE が見つかりません")
        text = got[1]
        ver = pin["state"]["version"]
        title = f"{ident} {ver}（{spdx(text)}）"
        groups = [(f"{ident} {ver}", f"{ident} {ver}", f"{pin['location']}\n\n{text}", f"{pin['location']}\n\n{text}")]
        if ident == "sentry-cocoa":
            extra = fetch_file(pin, ["THIRD_PARTY_NOTICES.md"], dirs)
            if extra:
                groups.append(("sentry-cocoa third-party notices", "sentry-cocoa third-party notices", extra[1], extra[1]))
        lib_pages.append((ident, title, title, groups))
    return content_pages, lib_pages


# ---- 書き出し ----------------------------------------------------------------


def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def write_strings(path: Path, entries: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("".join(f'"{esc(k)}" = "{esc(v)}";\n' for k, v in entries.items()), encoding="utf-8")


def write_plist(path: Path, obj: dict) -> None:
    path.write_bytes(plistlib.dumps(obj, fmt=plistlib.FMT_XML, sort_keys=False))


def main() -> None:
    content_pages, lib_pages = build_pages()
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)
    ja: dict[str, str] = {}
    en: dict[str, str] = {}

    def pane_entry(pid: str, ja_title: str, en_title: str) -> dict:
        ja[f"title.{pid}"] = ja_title
        en[f"title.{pid}"] = en_title
        return {"Type": "PSChildPaneSpecifier", "Title": f"title.{pid}", "File": f"Lic_{pid}"}

    for pid, ja_title, en_title, groups in content_pages + lib_pages:
        specs = []
        for i, (gj, ge, bj, be) in enumerate(groups):
            ja[f"group.{pid}.{i}"], en[f"group.{pid}.{i}"] = gj, ge
            ja[f"footer.{pid}.{i}"], en[f"footer.{pid}.{i}"] = bj, be
            specs.append({"Type": "PSGroupSpecifier", "Title": f"group.{pid}.{i}", "FooterText": f"footer.{pid}.{i}"})
        ja[f"title.{pid}"] = ja_title
        en[f"title.{pid}"] = en_title
        write_plist(
            OUT / f"Lic_{pid}.plist",
            {"StringsTable": "Licenses", "Title": f"title.{pid}", "PreferenceSpecifiers": specs},
        )

    lic_specs = [{"Type": "PSGroupSpecifier", "Title": "licenses.content"}]
    lic_specs += [pane_entry(p[0], p[1], p[2]) for p in content_pages]
    lic_specs += [{"Type": "PSGroupSpecifier", "Title": "licenses.libraries"}]
    lic_specs += [pane_entry(p[0], p[1], p[2]) for p in lib_pages]
    ja["licenses.title"], en["licenses.title"] = "ライセンス", "Acknowledgements"
    ja["licenses.content"], en["licenses.content"] = "声・効果音・書体・文字のデータ", "Voices, sounds, fonts, letter data"
    ja["licenses.libraries"], en["licenses.libraries"] = "ライブラリ", "Libraries"
    write_plist(
        OUT / "Licenses.plist",
        {"StringsTable": "Licenses", "Title": "licenses.title", "PreferenceSpecifiers": lic_specs},
    )

    # もじまち のページの一番上。声のクレジットはここにも出す（規約）。
    root = {
        "StringsTable": "Root",
        "Title": "root.title",
        "PreferenceSpecifiers": [
            {"Type": "PSGroupSpecifier", "Title": "root.group", "FooterText": "root.voice"},
            {"Type": "PSChildPaneSpecifier", "Title": "root.licenses", "File": "Licenses"},
        ],
    }
    write_plist(OUT / "Root.plist", root)
    root_ja = {
        "root.title": "もじまち",
        "root.group": "",
        "root.voice": f"声: {VOICE_CREDIT}",
        "root.licenses": "ライセンス",
    }
    root_en = {**root_ja, "root.licenses": "Acknowledgements", "root.voice": f"Voice: {VOICE_CREDIT}"}
    write_strings(OUT / "ja.lproj/Root.strings", root_ja)
    write_strings(OUT / "en.lproj/Root.strings", root_en)
    write_strings(OUT / "ja.lproj/Licenses.strings", ja)
    write_strings(OUT / "en.lproj/Licenses.strings", en)
    print(f"{OUT.relative_to(ROOT)}: {len(content_pages)} 件の出どころ、{len(lib_pages)} 件のライブラリ")


if __name__ == "__main__":
    main()
