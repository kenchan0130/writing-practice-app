#!/bin/sh
# ステッカーと おたのしみ ボックスの絵（SVG）を作り直し、アプリの Assets.xcassets へ写す（Mac だけ）。
# 使い方: Scripts/art/stickers.sh
# SVG は Content/Art/stickers/ と Content/Art/parts/、一覧は Content/Art/sheet-stickers.png。
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
WORK=${TMPDIR:-/tmp}/mojimachi-art
ASSETS="$ROOT/App/Mojimachi/Assets.xcassets"
mkdir -p "$WORK"
python3 -I "$HERE/stickers.py"
imageset() { # $1 = SVG のファイル、$2 = アセットの名前
  dir="$ASSETS/$2.imageset"
  file=$(basename "$1")
  mkdir -p "$dir"
  cp "$1" "$dir/$file"
  cat > "$dir/Contents.json" <<JSON
{
  "images": [
    {
      "filename": "$file",
      "idiom": "universal"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  },
  "properties": {
    "preserves-vector-representation": true
  }
}
JSON
}
NAMES=$(python3 -I -c "import sys; sys.path.insert(0, '$HERE'); sys.dont_write_bytecode = True; import stickers; print(' '.join(stickers.ORDER))")
for n in $NAMES; do
  imageset "$ROOT/Content/Art/stickers/$n.svg" "sticker-$n"
done
imageset "$ROOT/Content/Art/parts/otanoshimi-box.svg" "part-otanoshimi-box"
imageset "$ROOT/Content/Art/parts/otanoshimi-lid.svg" "part-otanoshimi-lid"
swiftc -O "$HERE/sheetstickers.swift" -o "$WORK/sheetstickers"
"$WORK/sheetstickers" "$ROOT/Content/Art/stickers" "$ROOT/Content/Art/parts" "$ROOT/Content/Art/sheet-stickers.png" $NAMES
echo "一覧: $ROOT/Content/Art/sheet-stickers.png"
