#!/bin/sh
# ことばの絵（SVG）を作り直し、確かめ用の画像を作る。
# 使い方: Scripts/art/run.sh [name...]   （名前を省くと全部。Mac だけ）
# SVG は Content/Art/words/ に出る。確かめ用の PNG は一時フォルダに出して、その場所を表示する。
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
WORK=${TMPDIR:-/tmp}/mojimachi-art
mkdir -p "$WORK"
python3 -I "$HERE/words.py" "$@"
[ -x "$WORK/render" ] || swiftc -O "$HERE/render.swift" -o "$WORK/render"
NAMES=${*:-$(ls "$ROOT/Content/Art/words" | sed 's/\.svg$//')}
for n in $NAMES; do
  cp "$ROOT/Content/Art/words/$n.svg" "$WORK/$n.svg"
  "$WORK/render" "$WORK/$n.svg" "$WORK/$n-512.png" 512
  "$WORK/render" "$WORK/$n.svg" "$WORK/$n-120.png" 120
  "$WORK/render" "$WORK/$n.svg" "$WORK/$n-sil.png" 512 sil
done
echo "確かめ用の画像: $WORK"
echo "一覧を作るとき: cd $WORK && swiftc -O $HERE/sheetall.swift -o sheetall && ./sheetall"
