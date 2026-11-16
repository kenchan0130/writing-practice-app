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

.PHONY: format
format: ## swift-format で書式を整える
	swift format --in-place --recursive --parallel $(PACKAGES)

.PHONY: lint
lint: ## swift-format で書式を確かめる
	swift format lint --strict --recursive --parallel $(PACKAGES)

.PHONY: judge-report
judge-report: ## 判定の誤りの割合を表で出す（D107・D120。判定の部品ができたら作る）
	@echo "judge-report: 判定の部品（JudgeKit）ができたら実装する" && exit 1

.PHONY: content-check
content-check: ## 文字とことばのデータを確かめる（D68・D70・D75・D106・D114。データができたら作る）
	@echo "content-check: 文字とことばのデータができたら実装する" && exit 1
