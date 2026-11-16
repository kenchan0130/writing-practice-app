#!/bin/sh
# Xcode Cloud のビルドの前に動く（D142）。
# タグで始まったビルドなら、タグ（v1.2.3）からアプリのバージョン（1.2.3）を作る。
# ビルド番号（CFBundleVersion）は Xcode Cloud が自動で付ける。
set -eu

if [ -z "${CI_TAG:-}" ]; then
  echo "タグのないビルドなので、バージョンは Config/Version.xcconfig のまま"
  exit 0
fi

version="${CI_TAG#v}"
if ! printf '%s' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "タグ ${CI_TAG} は v<数字>.<数字>.<数字> の形ではないので止める" >&2
  exit 1
fi

config="${CI_PRIMARY_REPOSITORY_PATH}/App/Config/Version.xcconfig"
printf 'MARKETING_VERSION = %s\n' "$version" > "$config"
echo "バージョンを ${version} にした（タグ ${CI_TAG}）"
