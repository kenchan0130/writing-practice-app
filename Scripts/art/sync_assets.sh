#!/bin/sh
# ことばの絵（Content/Art/words/*.svg）を、アプリの Assets.xcassets の word-<名前>.imageset へ写す。
# 使い方: Scripts/art/sync_assets.sh [name...]   （名前を省くと全部）
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
NAMES=${*:-$(ls "$ROOT/Content/Art/words" | sed 's/\.svg$//')}
for n in $NAMES; do
  dir="$ROOT/App/Mojimachi/Assets.xcassets/word-$n.imageset"
  [ -d "$dir" ] || { echo "imageset がない: word-$n"; continue; }
  cp "$ROOT/Content/Art/words/$n.svg" "$dir/$n.svg"
done
