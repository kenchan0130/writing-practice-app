# スクリーンショットの計画

元の決めごと: `docs/design.md` §10.2（D40）の「スクリーンショット」の行、D24（学年・年齢を画面に出さない）、D72（語数は実際の数）、D98（金額を書かない）、D103（⑦は「広告なし・課金は おとなだけ」）、D118（英語版）。コードは 2026-11-27 時点。**ここに書いた起動の引数は、DEBUG ビルドだけで効く**（`#if DEBUG`。リリースのビルドでは効かない）。

## 1. 大きさと端末

| 枠 | シミュレータの例 | 画像の大きさ（縦×横。ASC で確かめる【要確認】） |
|---|---|---|
| 13インチ iPad（必須） | iPad Pro 13-inch (M5)（名前は `xcrun simctl list devices available` で調べる） | 2064×2752（縦向き）／2752×2064（横向き） |
| 11インチ iPad（13インチがあれば、なくてもよい） | iPad Pro 11-inch (M5) | 1668×2420／1668×2388／1640×2360（縦向き） |

- 向き: **縦向きと横向きの両方を撮る（D183 で決定）**。13インチは 2064×2752（縦）と 2752×2064（横）、11インチも両方。同じ画面を2つの向きで撮り、ASC には向きごとに入れる（上限10枚。向きごとの構成は、①〜⑧のうち効く画面を選ぶ）。ホームの並びと「まち」は横向きのほうが広く見える。文字の地図は縦向きでも10列が入る（D125）。向きを変えたあと、`screenshot` の前に画面が組み直されるのを待つ。ストアの文面は多言語で出す（D183）ので、画面の中の字（日本語）は同じでも、スクリーンショットの説明の文字は言語ごとに作る【あとで】。
- 最大10枚。最初の3枚で決まる（D40）。
- 外観は明るい（ライト）。`xcrun simctl ui <udid> appearance light`。
- 時計とバッテリーは整える: `xcrun simctl status_bar <udid> override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularMode notSupported`。
- 子どもの画面に学年・年齢を出さない（D24）。写り込むもの（呼び名）に、本名や実在の子の名前を使わない。呼び名は「ゆうと」「さくら」などの作り物にする。

## 2. 撮り方の型

```sh
UDID=<対象のシミュレータの ID>
APP=io.github.kenchan0130.mojimachi

# ビルドとインストール（署名なし。手元の iPad のシミュレータ）
make app-build
xcrun simctl install "$UDID" <DerivedData の .../Debug-iphonesimulator/Mojimachi.app>

# 起動（共通の引数 + その画面の引数）
xcrun simctl terminate "$UDID" "$APP" 2>/dev/null
xcrun simctl launch "$UDID" "$APP" <共通の引数> <その画面の引数>

# 撮る
xcrun simctl io "$UDID" screenshot --type=png <出力先>.png
```

向きの切り替えは `simctl` では出来ない。Simulator の「Device > Rotate」か、iOS シミュレータの制御ツール（`rotate`）を使う。

### 共通の引数

| 引数 | 効果 |
|---|---|
| `-skipOnboarding YES` | はじめての流れを出さない（`ProgressStore.swift`。`-screen`・`-openParent`・`-mapChar` のときも出さない） |
| `-inMemoryStore YES` | 保存しないで動かす（前の撮影の記録が残らない） |
| `-localOnlyStore YES` | iCloud に触れない |
| `-penColor blue`（など） | ペンの色を決める。`PenColor` の名前（例: `red`・`blue`） |
| `-fakePurchases none` | 何も買っていない状態。`katakana,abc,all` でそれぞれ持っている状態 |
| `-today 2026-07-20` | 「きょうの ことば」の日を決める（季節のことばも決まる） |
| `-todayRegion JP` | 日本の季節で選ぶ（日本以外の地域だと季節で選ばない。D54） |
| `-uiTesting YES` | 動きを止める。**動きを撮る画面では付けない**。静止した画面（地図・保護者用の画面）だけ付けてよい |

撮る前に、どの画面も 1 回は目で確かめる。シミュレータでは Apple Pencil も指の線も書けないので、線は引数で「書いたことにする」（下の表の `-simulateWord`・`-simulateWriting`）。

## 3. 画面の一覧

D40 の①〜⑧の案に、いまのアプリでできる画面を当てた。**「できる」= 引数だけで撮れる。「手作業」= 引数で出せない部分があり、撮る人が操作する。「まだ」= 機能がまだない。**

| 順 | メッセージ（案。日本語） | 何を撮るか | 起動の引数（共通の引数に足す） | 状態 |
|---|---|---|---|---|
| ① | かいた字が うごきだす | 「でんしゃ」を書いたあとの変身（線が集まって電車になる途中、または走りだした場面） | `-screen word -startWord でんしゃ -simulateWord YES`。変身の途中の1コマは、起動してから `simctl io screenshot` を短い間隔で繰り返して、いちばん良い1枚を選ぶ | 手作業（変身の途中で止める引数はない。`-freezeCelebration` は字ごとのほめ言葉を止めるだけ） |
| ② | あいうえお順も、かんたんな順も | 文字の地図（ひらがなの50音表。字は 1.5cm 角以上で並ぶ）。カタカナのページ、ABC のページも別の1枚に使える | `-screen map`、カタカナ: `-screen map -mapScript katakana`、ABC: `-screen map -mapScript abc`（ほかに `-mapPage lower`・`digits`、狭いときは `-mapHalf 1`） | できる。「おすすめ順」の表示は、まだない（`docs/screens.md`）ので、見出しは「あいうえお順で、ならんでいます」などにする |
| ③ | 書いたもので、じぶんだけの まちに | 「わたしのまち」に物がたくさん並んだ景色 | `-screen town -seedTown YES`。景色を変えるときは `-townScroll 0.5`（0〜1。まちの途中から見る）。空の景色: `-skyWord くも` など | できる（`-seedTown` は同期が動いていないときだけ。`-localOnlyStore YES` が要る） |
| ④ | まちがえても しからない | 1文字を書く画面で、「もういちど かいてみよう」と出ている場面 | `-screen letter -mapChar あ -simulateUntil nazoru`（「なぞる」の手前まで進める）。判定が合わなかったときの声かけの場面は、手作業で撮る | 手作業（合わなかった場面はシミュレータでは作れない。線を書けないため） |
| ⑤ | 〇〇のことば（ひらがなのことばは無料） | ことばのカード（絵カードが並ぶ画面） | `-screen wordCards -place ie -theme fuku`（`-place` と `-theme` に場所とテーマの ID。ID は `WordMap` から調べる） | できる。**【要更新】文字の「〇〇」は、公開時の語数にする（D72。いまは139語、目標は約300語）** |
| ⑥ | せいちょう アルバム | 保護者用の画面の「学習記録」。アルバム（育ちの名前の「はな」「つぼみ」）と、文字の地図の色 | `-openParent records -seedGrowth YES -seedSamples YES -seedRecords 3` | できる。保護者用の画面は、かけ算の確認のあと（`-openParent` は確認を飛ばして開く。DEBUG だけ） |
| ⑦ | 広告なし・課金は おとなだけ（D103） | 子どもの画面（ホーム）が主役で、「広告なし」「購入は保護者用の画面だけ」と書いた説明。購入画面は、あとで足す1枚にしてもよい | ホーム: 引数なし（共通の引数だけ）。購入画面: `-openParent purchase -fakePurchases none` | できる（ホーム）。購入画面を使うときは、**金額を載せない**（D98。国ごとに変わる）。商品名を載せるなら、ASC に入れた名前で撮る |
| ⑧ | Apple Pencil にも、指にも | 書く画面（字を書いている途中）と、Apple Pencil か指の絵 | 書く画面: `-screen letter -mapChar あ -simulateUntil usuku -penColor blue`（途中まで）。Apple Pencil を持つ手の写真や絵は、別に用意する | 手作業（Pencil は写真か絵を足す。シミュレータの画面だけでは伝わらない） |
| 予備 | ひらがなは ぜんぶ 無料 | ホーム。ほめられた場面（星、スタンプ、「はなまる」の育ち） | `-skipOnboarding YES -seedRecords 3 -seedGrowth YES -today 2026-07-20` | できる |
| 予備 | しりとり | キャラクターとのしりとり（3枚の候補） | `-screen shiritori` | できる |
| まだ | ずかん | 集めたことばを見返す | ― | **まだ**（コードにない。出ないなら撮らない） |
| まだ | すうじ あそび | 数字を書くと、まちにりんごが出る | ― | **まだ** |

- 並べ方（D40）: ①変身 → ②地図 → ③まち が最初の3枚。④〜⑧はその後ろ。
- 英語版（D118・D186）: 保護者用の画面などを英語にした（D186）ので、英語のストアには**英語の画面を撮って**使う。作り方は §3b。

## 3b. 英語（en）のスクリーンショット（D186）

画面は、起動の引数で言語を英語にして撮る。`simctl launch` の最後（アプリの引数のあと）ではなく、**アプリの引数の前**に `-AppleLanguages (en) -AppleLocale en_US` を付ける。

```sh
xcrun simctl terminate "$UDID" "$APP" 2>/dev/null
xcrun simctl launch "$UDID" "$APP" -AppleLanguages "(en)" -AppleLocale en_US <共通の引数> <その画面の引数>
xcrun simctl io "$UDID" screenshot --type=png <出力先>-en.png
```

- 字・ことば・声・字幕・ほめ言葉は日本語のまま（D186）。英語になるのは、ホームのボタン（Letters・Words・Town）・道具のボタン（Try again・Done!）・保護者用の画面・購入の画面など。
- 日本語版と同じ引数で撮れる（`-openParent records` など。DEBUG だけ）。
- 画像の上に重ねる説明の文字（D40）は、下の表の英語の案を使う。1枚1メッセージ。金額・年齢・学年は入れない（D24・D98）。
- 撮るのは、日本語版と同じ①〜⑧のうち、画面の言葉が効くもの。最初の3枚は、日本語と同じ並び（①変身 → ②地図 → ③まち）。

| 順 | 説明の文字（英語の案） | 画面（英語で撮る） |
|---|---|---|
| ① | Letters you write come alive | 「でんしゃ」の変身（日本語の字は同じ。ボタンだけ英語） |
| ② | Hiragana, katakana, ABC and numbers | 文字の地図（`-screen map`。上のつまみは Hiragana・Katakana・ABC） |
| ③ | Your words build your own town | `-screen town -seedTown YES` |
| ④ | Never scolded, always "try again" | 書く画面（`-screen letter -mapChar あ`）。ボタンは Try again |
| ⑤ | Hundreds of words to write (hiragana words are free) | `-screen wordCards -place ie -theme fuku`。語数は公開時の数に（D72） |
| ⑥ | See how your child is growing | `-openParent records -seedGrowth YES -seedSamples YES -seedRecords 3`（英語の「Learning Record」） |
| ⑦ | No ads. Purchases are for grown-ups only | ホーム（引数なし）、または `-openParent purchase -fakePurchases none`（**金額を載せない**） |
| ⑧ | Works with Apple Pencil and fingers | 書く画面＋Pencil の写真か絵 |

- 英語の保護者用の画面が撮れること（切れ・はみ出しがないこと）は、`l10n` の確認で見た（11インチ縦向き）。13インチ・横向きは、撮るときにもう一度見る。
- 日本語の画面の説明の文字は §3 の表。英語の説明の文字は、翻訳の確認（別のモデルの AI）を通してから使う。

## 4. 撮影の手順（あとで自動にするとき）

1. 13インチと11インチのシミュレータを作る（上の表の端末）。
2. 画面ごとに、`terminate → launch（引数）→ 待つ（動く画面は 3〜6 秒）→ screenshot` を回す。
3. 手作業の画面（①④⑧）は、撮る人が操作して撮る。
4. 画像に説明の文字を重ねる（D40: 1枚1メッセージ。文字は大きく、保護者が読む前提。日本語は上の表のとおり）。
5. 出力の名前の例: `docs/release/shots/<端末>/<順>-<名前>.png`（置き場はまだない。画像を作ったら置き場を決める）。`Originals/` は元データ用（D112）なので使わない。
6. 画面ごとの1行説明と引数を、このファイルに残す。引数を変えたら、ここも直す。

## 5. 注意

- 画像に、価格・年齢・学年・ほかの会社の名前・商標を入れない（D24・D40・D98）。
- 画像に出る字・絵・声字幕は、D121 のとおり人が見た素材だけにする。
- スクリーンショットの内容は、そのまま App Store の約束になる。**まだない機能（ずかん・すうじ あそび・カタカナのことば・えいごの ことば）を載せない**（D72）。
- 説明に書く語数は、撮影の直前に `Assets.xcassets/word-*` の数を数え直す。
- アプリのアイコンの画像が、いまのプロジェクトにない（`release-checklist.md`）。スクリーンショットの前に作る。

## 6. 撮った結果（2026-11-27 の撮り直し）

`Scripts/make_screenshots.sh` で、`docs/release/screenshots/<ja|en>/<13|11>-<portrait|landscape>/NN-<画面>.png` に 72 枚（2言語 × 2サイズ × 2向き × 9 枚）。8画面＋おまけの夕方のまち。大きさは 13インチ 2064×2752／2752×2064、11インチ 1668×2420／2420×1668。**アルファなし（RGB の PNG）**。端末は iOS 27.0 の iPad Pro 13-inch (M5)・11-inch (M5)（毎回作って、撮り終わったら消す）。iOS 27.1 のランタイムは入っているが、iPad のシミュレータを作れない（2026-11-27 時点）ので 27.0 を使う。アプリのコードは main のまま（変えていない）。

- 画面と引数（共通の引数は §2）:
  - 01-word（でんしゃ）: `-screen word -startWord でんしゃ -simulateWord YES`
  - 02-map: `-screen map -uiTesting YES`
  - 03-town: `-screen town -seedTown YES -townScroll 0.2 -townHour 13 -seedStickers 6 -seedStickersPlaced YES`（昼の13時。ステッカー6枚のうち4枚をまちに貼る。季節の飾り〈こいのぼり・ゆきだるま・はなび・ちょうちん・かどまつ・ふうりん〉も出る）
  - 04-letter（なぞる手前）/ 08-writing（うすく）: `-screen letter -mapChar あ -simulateUntil nazoru|usuku`
  - 05-wordcards: 13インチの縦は「むし」12枚（`-place mori -theme mushi`）。横と11インチの縦は「そら・てんき」8枚（`-place sora -theme sora-tenki`）。**カードは、横向き（4列）は2行まで、11インチの縦（3列）は3行までしか切れずに入らない**ので、8枚のテーマにした。
  - 06-records: `-openParent records -seedGrowth YES -seedSamples YES -uiTesting YES`（成長アルバムに、書き直しの見本が入る。縦向きは下に出る）
  - 07-home: `-seedRecords 5 -seedGrowth YES -seedStickers 4 -seedStickersPlaced YES`（目標の星が5つ光って、上に「おたのしみ ボックス」が出る）
  - 09-town-evening（おまけ）: 03 と同じで `-townHour 19`（夜のまち。月と星）。9枚目。要らなければ ASC に入れない。
- **向きの切り替え**: DEBUG の `-orientation landscape|portrait`（`ContentView.swift`）。撮る用のビルドだけ `INFOPLIST_KEY_UIRequiresFullScreen=YES`（iPadOS 26 の窓のモードだと向きを変えられない）。`simctl io screenshot` は縦の画像のまま出すので、横向きは `sips -r 270` で回す。
- **窓の大きさを変える弧**（縦は右下、横は右上）は、全画面のビルドでも消えない。`Scripts/clean_screenshot.py`（ffmpeg が要る）が、弧のまわりが無地なら四角で隣の背景の色に塗り、無地でなければ弧だけを両隣の色でつないで塗る（11インチの縦の「むし」12枚で後者を使ったが、8枚に変えたので今は使わない）。目で全画像を見て、跡がないことを確かめた。
- 撮ってから見た確認（全72枚の一覧と、各セットの原寸）: 切れているもの・空の画面・デバッグの文字・動きの途中はなし。残る「切れ」は、スクロールの画面が自然に切れているだけ（01-word の下の絵の列、11インチ横向きの 06-records の文字の地図の最下行）。
- 見え方のメモ（アプリ側。今回は直さない）: 横向きの 06-records は、文字の地図が左に小さく寄って右が空き、成長アルバムは画面の外（下）にある。01-word は、電車の絵が小さく見える向き・大きさがある（11インチ横）。
- ① 変身の途中の1コマ、④ 合わなかったときの声かけ、⑧ Pencil の絵は、引数で出せないので撮っていない。⑦ の購入画面（`-openParent purchase`）も撮っていない。
