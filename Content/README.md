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

## カタカナのことば（D199）

カタカナのことば（バス・パトカー・タクシー）は、ひらがなのことばと**同じめぐりの形**で書く。足すものが違うのは、字だけ。

- `entries` に `WordEntry("パトカー", .vehicle)` のように、**字のとおりカタカナ**で書く（D7）。文字の種類（カタカナ）は、字から決まる（`WordText.script(of:)`）。印や別の一覧は足さない。長音「ー」と小さい字（ャ・ュ・ョ・ッ）も、カタカナの字として数える。
- `themeWords` には、そのテーマのことばを書く。テーマの中では、ひらがなのことば → おためしのことば（バス）→ 鍵のカタカナのことば の順に自動で並ぶので、書く順は気にしなくてよい（D93）。
- 字は、`Content/Packs/kata` に全部ある。書けない字（ヴ のように地図にない字など）がないか、`make test` が見る。
- しりとりでは、読み（ひらがな）で続く。「ー」はその前の字の音、小さい字は大きい字の音。「ん」で終わることばは使われない。
- 絵（`artNames` はローマ字。バスは `basu`）、ずかんの説明（`notes`）、声（`word_<ローマ字>`・`zukan_<ローマ字>`）は、ひらがなのことばと同じ。声の読みを直すときは、`lines.csv` の4列目に `kana:` で書く。
- 見本は `WordBatches/BatchKataSeed.swift`（バス）と `Scripts/art/words_kataseed.py`。
- カタカナのパックを持っていないと、バスのほかは鍵がかかる。おためしのことばを増やすときは、`Trial`（`EntitlementKit`）を直し、D90 を見る。

## えいごの ことば（D199）

えいごの ことばは、日本語のことばの**絵を使い回す**。絵も声の説明もいらず、`EnglishWord` を足すだけ。

- `WordBatch(..., english: [EnglishWord("cat", japanese: "ねこ"), ...])` に足す。見本は `WordBatches/BatchEnglishSeed.swift`（はじめの20語）。つづきの78語は `WordBatches/BatchEnglish2.swift`（D203）。さらに足すときは、新しいめぐり（`entries: []` でよい）の `english` に足し、`WordBatch.all` に1行足す。
- `text` は**小文字**の英字、3〜5文字のやさしいことば（D203 で5文字まで）。`japanese` は、絵を借りる日本語のことば（`WordCatalog` にあって、絵のあるもの。カタカナのことばでもよい。bus は「バス」）。書くのは `abc` パックの小文字（`Content/Packs/abc`）。
- 動きの種類（まちでの動き・変身）と季節は、借りる日本語のことばと同じ。しりとりには出ない。
- そのテーマに、借りる日本語のことばがあれば、テーマの画面に「ABC」の旗が出る。パックがなければ cat だけが開き、ほかは影絵に鍵。
- 声: `Content/Voices/lines.csv` に `english_<ことば>,<ことば>,ochitsuki,<読み>,` の行を足す（D180 と同じ猫使ビィ。エンジンの英語の読みで読む）。読みが合わないときだけ、4列目に `kana:` の読みを書く（`kana:ベ'ア`）。そのあと、4. のコマンドで声を作り直す。
- `EnglishWords` を読む `KatakanaAndEnglishWordTests` が、重なり・小文字・字数・借りる先を確かめる。

## ステッカーと おたのしみ ボックス（D190）

- 絵: `Scripts/art/stickers.sh`（Mac だけ）。`Scripts/art/stickers.py` で SVG を作り（`Content/Art/stickers/`・`Content/Art/parts/otanoshimi-*.svg`）、
  アプリの `sticker-<名前>.imageset`・`part-otanoshimi-*.imageset` へ写し、一覧（`Content/Art/sheet-stickers.png`）を作る。
- ステッカーを足すとき: `stickers.py` に `@sticker` の関数を足し、`TreatBox.stickers`（`Packages/Sources/PracticeKit/TreatBox.swift`）の**最後に**同じ名前を足し、
  `StickerArt.name`（`App/Mojimachi/Treat/StickerArt.swift`）に読み上げ用の名前を足す。数を決めているテスト（`TreatBoxTests`）も直す。
- 描き方の決まりは `Content/Art/style-guide.md` の「ステッカーと おたのしみ ボックス」。
