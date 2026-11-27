#!/bin/bash
# App Store 用のスクリーンショットを撮り直す（docs/release/screenshots-plan.md）。
# 使い方: Scripts/make_screenshots.sh   （repo のルートで。シミュレータを作って、撮って、消す。DEBUG ビルドだけで効く引数を使う）
set -euo pipefail
cd "$(dirname "$0")/.."
APP=io.github.kenchan0130.mojimachi
OUT=docs/release/screenshots
# iPad のシミュレータが作れる、いちばん新しい OS（2026-11-27 時点では 27.0。27.1 は iPad を作れない）
RT=${RUNTIME:-com.apple.CoreSimulator.SimRuntime.iOS-27-0}
DD=build/DerivedData

xcodebuild build -project App/Mojimachi.xcodeproj -scheme Mojimachi -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath $DD CODE_SIGNING_ALLOWED=NO -skipMacroValidation -quiet \
  INFOPLIST_KEY_UIRequiresFullScreen=YES   # 窓のモードだと向きを変えられないので、撮る用のビルドだけ全画面にする
APPPATH=$DD/Build/Products/Debug-iphonesimulator/Mojimachi.app

COMMON=(-skipOnboarding YES -inMemoryStore YES -localOnlyStore YES -penColor blue -fakePurchases none -today 2026-07-20 -todayRegion JP)
# 名前|待つ秒数|引数…（-uiTesting は動きを撮る画面には付けない）。ONLY="01-word 07-home" で一部だけ撮り直せる。
# 05-wordcards は向きと大きさで変える（13インチの縦は12枚、横と11インチの縦は8枚までしか切れずに入らない）→ 下の WORDCARDS_*。
# 03-town は、昼（13時）に、ステッカーを貼った まち。09-town-evening は、おまけの夕方（19時）。
STICKERS="-seedStickers 6 -seedStickersPlaced YES"
SCREENS=(
  "01-word|14|-screen word -startWord でんしゃ -simulateWord YES"
  "02-map|8|-screen map -uiTesting YES"
  "03-town|8|-screen town -seedTown YES -townScroll 0.2 -townHour 13 $STICKERS"
  "04-letter|8|-screen letter -mapChar あ -simulateUntil nazoru"
  "05-wordcards|8|@wordcards"
  "06-records|10|-openParent records -seedGrowth YES -seedSamples YES -uiTesting YES"
  "07-home|14|-seedRecords 5 -seedGrowth YES -seedStickers 4 -seedStickersPlaced YES"
  "08-writing|8|-screen letter -mapChar あ -simulateUntil usuku"
  "09-town-evening|8|-screen town -seedTown YES -townScroll 0.2 -townHour 19 $STICKERS"
)
WORDCARDS_portrait="-screen wordCards -place mori -theme mushi"
WORDCARDS_landscape="-screen wordCards -place sora -theme sora-tenki"
WORDCARDS_portrait_11="-screen wordCards -place sora -theme sora-tenki"   # 11インチの縦は3列なので、12枚だと4行目が切れる
SIZES=("13|iPad-Pro-13-inch-M5-12GB" "11|iPad-Pro-11-inch-M5-12GB")

for sz in "${SIZES[@]}"; do
  size=${sz%%|*}
  if [ -n "${SIZE_ONLY:-}" ] && [ "$SIZE_ONLY" != "$size" ]; then continue; fi   # SIZE_ONLY=11 で、そのサイズだけ撮り直せる
  type=com.apple.CoreSimulator.SimDeviceType.${sz#*|}
  UDID=$(xcrun simctl create "shot$size" "$type" "$RT")
  trap 'xcrun simctl delete "$UDID"' EXIT
  xcrun simctl boot "$UDID"; xcrun simctl bootstatus "$UDID" >/dev/null
  xcrun simctl ui "$UDID" appearance light
  xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularMode notSupported
  xcrun simctl install "$UDID" "$APPPATH"
  for lang in ja en; do
    locale=ja_JP; [ $lang = en ] && locale=en_US
    for orient in portrait landscape; do
      dir=$OUT/$lang/$size-$orient; mkdir -p "$dir"
      for entry in "${SCREENS[@]}"; do
        name=${entry%%|*}; rest=${entry#*|}; wait=${rest%%|*}; argstr=${rest#*|}
        if [ "$argstr" = "@wordcards" ]; then v=WORDCARDS_${orient}_$size; [ -z "${!v:-}" ] && v=WORDCARDS_$orient; argstr=${!v}; fi
        read -r -a args <<<"$argstr"
        if [ -n "${ONLY:-}" ] && [[ " $ONLY " != *" $name "* ]]; then continue; fi
        xcrun simctl terminate "$UDID" $APP 2>/dev/null || true
        xcrun simctl launch "$UDID" $APP -AppleLanguages "($lang)" -AppleLocale $locale \
          -orientation $orient "${COMMON[@]}" "${args[@]}" >/dev/null
        sleep "$wait"
        xcrun simctl io "$UDID" screenshot --type=png "$dir/$name.png" 2>/dev/null
        # simctl は端末の向きのまま（縦の画像）で出す。横向きは画像を回して直す。
        [ $orient = landscape ] && sips -r 270 "$dir/$name.png" >/dev/null
        # 窓の大きさを変える弧を塗り、アルファのない PNG にする（App Store Connect はアルファを受け付けない）。
        python3 -I Scripts/clean_screenshot.py "$dir/$name.png" $orient
      done
    done
  done
  xcrun simctl delete "$UDID"; trap - EXIT
done
