.DEFAULT_GOAL := help
PACKAGES := Packages

.PHONY: help
help: ## コマンドの一覧を出す
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-16s %s\n", $$1, $$2}'

.PHONY: test
test: ## 画面や端末に頼らない部品のテストを動かす（PR の前に必ず通す。D129・D130）
	swift test --package-path $(PACKAGES)

.PHONY: build
build: ## 部品をビルドする
	swift build --package-path $(PACKAGES)

.PHONY: app-build
app-build: ## アプリを iPad のシミュレータ向けにビルドする（署名なし）
	xcodebuild build -project App/Mojimachi.xcodeproj -scheme Mojimachi -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO -skipMacroValidation -quiet

.PHONY: app-test
app-test: ## アプリの購入の流れを、iPad のシミュレータで確かめる（StoreKit の試し用の設定。署名なし）
	xcodebuild test -project App/Mojimachi.xcodeproj -scheme Mojimachi -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' CODE_SIGNING_ALLOWED=NO -skipMacroValidation -quiet

.PHONY: format
format: ## swift-format で書式を整える
	swift format --in-place --recursive --parallel $(PACKAGES)

.PHONY: lint
lint: ## swift-format で書式を確かめる
	swift format lint --strict --recursive --parallel $(PACKAGES)

.PHONY: judge-report
judge-report: ## 判定の効き方を、わざと崩した線で表にする（D79・D107。正解の付いた線が集まったらそれも足す）
	swift run --package-path $(PACKAGES) JudgeReport Content/Packs/hira

.PHONY: content-check
content-check: ## 文字とことばのデータを確かめる（D66・D106・D114。ことばの決まり D68・D70・D75 はことばのデータができたら足す）
	swift test --package-path $(PACKAGES) --filter ContentModelTests
