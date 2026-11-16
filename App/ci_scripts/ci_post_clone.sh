#!/bin/sh
# Xcode Cloud でリポジトリを取ったあとに動く。
# TCA などのマクロ（ビルドのときに動くコード）の信頼の確認を飛ばす。手元の Makefile の
# -skipMacroValidation と同じ。マクロの版は Package.resolved で固定している（2026-11-17 ユーザーの判断）。
set -eu
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
