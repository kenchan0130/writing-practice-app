#!/bin/sh
# アプリのアイコンを作り直す（Mac だけ）。
# SVG を Content/Art/icon/ に出し、1024px の すきとおらない PNG を AppIcon.appiconset に入れる。
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
WORK=${TMPDIR:-/tmp}/mojimachi-art
SET="$ROOT/App/Mojimachi/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$WORK"
python3 -I "$HERE/icon.py"
swiftc -O "$HERE/render.swift" -o "$WORK/render-icon"
for n in app-icon app-icon-dark app-icon-tinted; do
  "$WORK/render-icon" "$ROOT/Content/Art/icon/$n.svg" "$SET/$n.png" 1024 opaque
  sips -g hasAlpha "$SET/$n.png" | tail -1
done
