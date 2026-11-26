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

# アプリのテストの共通の設定。`SIM=<udid>` で別のシミュレータを使える（既定は名前で選ぶ）。
comma := ,
SIM ?=
APP_DESTINATION := $(if $(SIM),platform=iOS Simulator$(comma)id=$(SIM),platform=iOS Simulator$(comma)name=iPad Pro 11-inch (M5))
APP_DERIVED := build/DerivedData
APP_TEST_FLAGS := -project App/Mojimachi.xcodeproj -scheme Mojimachi -destination '$(APP_DESTINATION)' -derivedDataPath $(APP_DERIVED) CODE_SIGNING_ALLOWED=NO -skipMacroValidation
APP_TEST_WORKERS ?= 2
APP_TEST_TIMEOUT ?= 900
# 固まったら止める（秒）。
TIMEOUT := python3 -I Scripts/run_with_timeout.py $(APP_TEST_TIMEOUT)

.PHONY: app-build-for-testing
app-build-for-testing: ## アプリのテストをビルドだけする（build/DerivedData に置く。署名なし）
	$(TIMEOUT) xcodebuild build-for-testing $(APP_TEST_FLAGS) -quiet

.PHONY: app-test
app-test: app-build-for-testing ## アプリの単体テストと UI テストを、iPad のシミュレータで確かめる（並列。約2〜3分。15分で打ち切る）
	$(TIMEOUT) xcodebuild test-without-building $(APP_TEST_FLAGS) -parallel-testing-enabled YES -parallel-testing-worker-count $(APP_TEST_WORKERS)

.PHONY: app-test-ui
app-test-ui: app-build-for-testing ## UI テストの一部だけ動かす（例: make app-test-ui ONLY=FlowWordUITests）
	$(TIMEOUT) xcodebuild test-without-building $(APP_TEST_FLAGS) -parallel-testing-enabled YES -parallel-testing-worker-count $(APP_TEST_WORKERS) $(if $(ONLY),-only-testing:MojimachiUITests/$(ONLY),-only-testing:MojimachiUITests)

.PHONY: format
format: ## swift-format で書式を整える
	swift format --in-place --recursive --parallel $(PACKAGES)

.PHONY: lint
lint: ## swift-format で書式を確かめる
	swift format lint --strict --recursive --parallel $(PACKAGES)

.PHONY: judge-report
judge-report: ## 判定の効き方を、わざと崩した線で表にする（D79・D107。正解の付いた線が集まったらそれも足す）
	swift run --package-path $(PACKAGES) JudgeReport Content/Packs/hira

.PHONY: shiritori-report
shiritori-report: ## しりとりの字ごとのことばの数と、行き止まりの字を出す（D70）
	swift run --package-path $(PACKAGES) ShiritoriReport

.PHONY: content-check
content-check: ## 文字とことばのデータを確かめる（D66・D106・D114。ことばの決まり D68・D70・D75 はことばのデータができたら足す）
	swift test --package-path $(PACKAGES) --filter ContentModelTests
