# Content

パックのデータ（JSON）とアプリに入れる圧縮後の素材を置く（D106・D112）。

## ことばの「めぐり」（何人かで同時にことばを足すとき）

ことばは、**めぐり（バッチ）ごとに自分のファイルへ**書く。同じ行を触らないので、ぶつからない。
めぐりの名前は `<Name>`（Swift）と `<name>`（Python・小文字）で使う。

### めぐりごとに足すファイル

- `Packages/Sources/ContentModel/WordBatches/Batch<Name>.swift`: `WordBatch` を1つ宣言する。
  ことば（`entries`・種類つき）、入るテーマ（`themeWords`: テーマ ID → ことば。テーマ内の順は、土台のことば、めぐりの順）、
  ずかんの説明（`notes`）、絵の名前（`artNames`: ことば → ローマ字）、季節の印（`seasons`）、はうことば（`crawlers`）。
  今までのことばは `WordBatch.base` で、動かさない。
- `Scripts/art/words_<name>.py`: そのめぐりの絵。`from words import word, ...` して `@word` の関数を書く
  （`words.py` が `words_*.py` を名前順に自動で読む。`words.py` に足す行はいらない）。
- `Content/Art/references-<name>.md` は作らず、`Content/Art/references.md` の**最後に**「## <めぐり名>」の節を足す。

### 流れとコマンド

1. `WordBatch` を書き、`WordBatch.all`（`WordBatch.swift`）に `.<name>` を1行足す。これが共有する唯一のコードの行。
2. 絵: `Scripts/art/run.sh <ことば名...>`（SVG は `Content/Art/words/` に出る。確かめ用の PNG の場所も出る）。
   一覧の画像は、`run.sh` の最後に出る手順で作る。
3. アプリに写す: `Scripts/art/sync_assets.sh <ことば名...>`（先に Xcode で `word-<名前>.imageset` を足しておく）。
4. 声: ことばと、ずかんの説明（`zukan_<ローマ字>`）の行を `Content/Voices/lines.csv` の**最後に足し**、
   `python3 -I Scripts/make_voices.py Content/Voices/lines.csv App/Mojimachi/Resources/Voices Content/Voices/provenance.csv`。
5. `make test` と `make content-check`。重なったことば・テーマや説明や絵の名前のないことばは、`WordBatchTests` が見つける。

### ぶつかったときの直し方（共有するのは次のところだけ）

- `WordBatch.all` の行: 両方の行を残す（順がことばの順になる）。
- `Content/Voices/lines.csv`: 行は足すだけなので、両方の行を残す。
- `App/Mojimachi/Resources/Voices/voices.json`・`provenance.csv`: 手で直さず、どちらか片方を取って、4. のコマンドで作り直す。
- `Content/Art/references.md`: 節は最後に足すだけなので、両方の節を残す。
- 画面の数を決めているテスト（`WordCatalogTests` の語数、`WordMapTests` のテーマ数など）は、マージの後に合う数へ直す。
