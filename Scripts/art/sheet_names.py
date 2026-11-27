"""一覧の画像（sheet-all.png）に並べることばと絵の名前を、アプリのデータから集めて書き出す。

使い方: python3 -I Scripts/art/sheet_names.py <出力の tsv>
土台のことば（App/Mojimachi/Word/WordArt.swift の baseAssets）のあとに、
めぐり（Packages/Sources/ContentModel/WordBatches/*.swift の artNames）を WordBatch.all の順に並べる。
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
PAIR = re.compile(r'"([^"\x00-\x7f]+)"\s*:\s*"([a-z0-9_-]+)"')


def block(text, start):
    i = text.index(start)
    depth = 0
    first = i + len(start) - 1 if start.endswith('[') else text.index('[', i)
    for j in range(first, len(text)):
        if text[j] == '[':
            depth += 1
        elif text[j] == ']':
            depth -= 1
            if depth == 0:
                return text[i:j]
    raise ValueError(start)


def main(out):
    pairs = PAIR.findall(block((ROOT / 'App/Mojimachi/Word/WordArt.swift').read_text(), 'baseAssets: [String: String] = ['))
    registry = (ROOT / 'Packages/Sources/ContentModel/WordBatch.swift').read_text()
    order = re.findall(r'\.(\w+)', block(registry, 'static let all: [WordBatch] = ['))
    batches = {}
    for f in sorted((ROOT / 'Packages/Sources/ContentModel/WordBatches').glob('*.swift')):
        t = f.read_text()
        m = re.search(r'static let (\w+)\s*=\s*WordBatch', t)
        if m and 'artNames:' in t:
            batches[m.group(1)] = PAIR.findall(block(t, 'artNames: ['))
    for name in order:
        pairs += batches.get(name, [])
    seen, rows = set(), []
    for kana, romaji in pairs:
        if romaji not in seen:
            seen.add(romaji)
            rows.append(f'{romaji}\t{kana}')
    pathlib.Path(out).write_text('\n'.join(rows) + '\n')
    print(f'{len(rows)} words')


if __name__ == '__main__':
    main(sys.argv[1])
