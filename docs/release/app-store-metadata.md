# App Store 登録の内容（下書き）

元の決めごと: `docs/design.md` の §10（D39・D40）、§5（D2・D45・D89〜D91・D98）、§6.4（D73）、D51・D65・D86・D103・D123・D124・D179。2026-11-27 時点のコードと照らして書いた。**人が App Store Connect に入れる前に、「要更新」の印を全部確かめる。** 何かを送ったり提出したりはしていない。

状態の書き方: 【要更新】= 公開の直前に実際の数や状態に直す。【要確認】= 人が Apple の最新の画面や規約で確かめる。【TODO】= 人が決める。

## 1. 基本情報

| 項目 | 内容 | 出どころ |
|---|---|---|
| アプリ名 | **もじまち：ひらがな・カタカナ書き順練習**（19文字。上限30）。**決定（D183）**。端末のホームに出る名前（`CFBundleDisplayName`）は「もじまち」のまま | D40・D136・D183。いま ASC には「もじまち」だけなので、公開前に ASC の名前をこれに変える【人】 |
| サブタイトル | 楽しく書いて、きれいな字が身につく知育アプリ（22文字。上限30） | D42 |
| バンドル ID | `io.github.kenchan0130.mojimachi` | D136 |
| SKU | `mojimachi` | D136 |
| プライマリ言語 | 日本語。**英語（米国。English (U.S.)）を追加する（D186）**。ストアの文面は多言語で出す（D183）。アプリの画面は、保護者用の画面などを英語にした（D186）。字・ことば・声は日本語のまま | D30・D136・D183・D186 |
| カテゴリ | プライマリ: 教育。**Kids カテゴリ**に入れ、年齢帯は「5歳以下」 | D51・D86（審査後は変えられない）。`INFOPLIST_KEY_LSApplicationCategoryType = public.app-category.education` |
| 年齢制限（レーティング） | 4+（下の §7） | |
| 対応端末 | iPad のみ（`TARGETED_DEVICE_FAMILY = 2`）。iPadOS 26 以上。Apple シリコンの Mac には「iPad 版」で出す。Vision Pro には出さない | D13・D14・D100。ASC の「Vision Pro の提供」はオフにする【要確認】 |
| 価格 | 無料（アプリ内課金あり） | D2 |
| 配信する国 | 全世界から **EU 27か国と中国本土を除く**。香港・台湾は配信。米国は配信（年齢確認の最新の案内に対応。`release-checklist.md`） | D52・D65 |
| サポート URL | `https://kenchan0130.github.io/apps/mojimachi` | D73・`docs/operations.md` |
| プライバシーポリシー URL | 日本語: `https://kenchan0130.github.io/apps/mojimachi/privacy`。英語: `https://kenchan0130.github.io/apps/mojimachi/privacy/en`（D186。アプリの英語の画面のリンクもこちら。本文は `privacy-policy.ja.md`・`privacy-policy.en.md`。英語のページは公開済み（2026-11-28。D198）。共通のポリシーのページ `https://kenchan0130.github.io/apps/privacy` の `#mojimachi` へ移る。URL は変えない） | D73・D186 |
| マーケティング URL | 置かない（サポートページで足りる） | |
| 著作権 | `2026 kenchan0130`（ASC に入れた。2026-11-28） | 済 |
| 販売者名 | 本名（D50・D65） | |
| 提供開始 | 手動で公開（`docs/operations.md`） | |

## 2. 日本語の文面

### 検索に使う欄

| 欄 | 文面 | 文字数 |
|---|---|---|
| プロモーションテキスト（上限170。審査なしで変えられる） | 書いた字が、ぱっと動きだす。ひらがなは ぜんぶ無料。広告なし・月額なし。ことばを書いて、自分だけの「まち」を にぎやかにしよう。 | 66 |
| キーワード（上限100。画面には出ない） | `幼児,子供,あいうえお,なぞり書き,文字,勉強,書き方,アルファベット,英語,ABC,数字,平仮名,五十音,50音,ドリル,手書き,ペン,しりとり,図鑑,保育園,幼稚園,入学準備,年長,年中` | 95文字（UTF-8 で229バイト） |
| キーワード（バイトの上限だった場合） | `幼児,子供,あいうえお,なぞり書き,五十音,平仮名,英語,ABC,数字,しりとり` | 40文字（96バイト） |

- 名前とサブタイトルにある語（もじまち・ひらがな・カタカナ・書き順・練習・楽しく・書いて・きれいな・字・知育）は、キーワードに入れない（D40）。
- 「図鑑」は、ずかんが出るまで外す【要更新】（いまのアプリにずかんはない。D179 のあとの実装状況を確かめる）。
- 「年長」「年中」「入学準備」はキーワード欄だけにする（D41）。説明文・画像には年齢や学年を書かない（D24）。
- ほかの会社の名前や商標は入れない。
- ASC が受け付ける上限（文字かバイトか）を、入れるときに確かめる【要確認】。

### 最初のバージョンの「このバージョンの新機能」（上限4,000）

```
はじめてのリリースです。
ひらがなは、すべて無料。書いた字が うごきだす、文字の練習アプリです。
・ひらがな・カタカナ・アルファベットと数字を、書き順どおりに練習
・書いたことばが、まちで うごきだす
・「きょうの ことば」と「しりとり」
・保護者用の画面が、英語でも使えます
```

### 説明文（上限4,000）

説明の最初の3行は D98 のとおり。**金額は書かない。今後足す言語の予告もしない。**

```
ひらがなは、すべて無料。
カタカナやアルファベットは、少し試してから、買い切りで追加できます。
広告なし・月額なし。

「もじまち」は、書いた字が うごきだす、文字の練習アプリです。

【書くと、ことばが うごきだす】
「でんしゃ」と書くと、書いた線が集まって、電車が走りだします。書いたものは「わたしのまち」にならんで、まちが にぎやかになっていきます。くつやぼうしは、キャラクターに着せられます。

【ていねいな書き順の練習】
・お手本を「みる → なぞる → うすく → じぶんで」の順に、少しずつ練習します
・書き順、はじめの位置、向きを、やさしく見守ります
・まちがえても、しかりません。「もういちど かいてみよう」と声をかけます
・とめ・はね・はらいは、まちがいにしません。ヒントとして見せます
・判定の厳しさは、保護者が子どもに合わせて選べます

【文字の地図】
・ひらがな（無料）／カタカナ／アルファベット（大文字・小文字）と数字
・あいうえお順の表と、おすすめの順で選べます
・書けた字は、たね → め → つぼみ → はな と育ちます

【ことばで あそぶ】
・【要更新: 実際の語数】約300のことばを、場所とテーマから選んで書けます
・ひらがなのことばは、どのテーマも無料です
・「きょうの ことば」と「しりとり」で、毎日ちがうことばに出会えます
・声で読んでくれるので、字が読めなくても遊べます

【保護者の方へ】
・広告も、ほかの会社の分析ツールも入っていません
・購入や設定は、かけ算の確認を通った保護者用の画面だけでできます。子どもの画面には、価格も購入ボタンも出ません
・カタカナ・アルファベットと数字は、おためしの字とことばで試してから、買い切りで追加できます。月額はありません
・学習の記録は、iPad と、保護者の iCloud の中だけに保存します（オフにもできます）。運営者は見られません
・子どもが書いた字の記録と、育ちを見られます
・家族のiPadで使えます（ファミリー共有）。Apple Pencil にも、指にも対応しています

プライバシーポリシー: https://kenchan0130.github.io/apps/mojimachi/privacy
```

- 「ずかん」「すうじ あそび」「えいごの ことば」「カタカナのことば」は、いまのコードにまだない。出すときに説明へ足す。**ないものは書かない**（D72）。
- 「ファミリー共有」は、全商品で有効にしたときだけ書く（D89）。
- 「Apple Pencil にも、指にも」は、実機で確かめてから【要確認】。
- 施設向け版は書かない（D72）。

## 3. 英語の文面（ASC の「English (U.S.)」。D186）

アプリは日本語を学ぶ人のための道具で、子どもの画面・声は日本語のまま。保護者用の画面と、ストアの文面だけを英語にした（D186）。名前・サブタイトル・キーワードは D40・D118 のとおり。訳は AI が作り、別のモデルの AI が確かめる。用語は `docs/glossary.md` に合わせる。他の言語（中国語・韓国語など）は、この英語を元に、同じ決まり（D186）で足せる。

| 欄 | 文面 | 文字数（上限） |
|---|---|---|
| 名前 | Mojimachi: Hiragana Writing | 27（30） |
| サブタイトル | Write kana, watch them move | 27（30） |
| プロモーションテキスト（審査なしで変えられる） | Letters you write come alive. Hiragana is free. No ads, no subscription. Write words and fill your own little town. | 115（170） |
| キーワード | `katakana,japanese,stroke order,tracing,alphabet,ABC,numbers,preschool,kids,nihongo,handwriting` | 94（100） |
| サポート URL | `https://kenchan0130.github.io/apps/mojimachi` | |
| プライバシーポリシー URL | `https://kenchan0130.github.io/apps/mojimachi/privacy/en` | |
| 著作権 | `2026 kenchan0130` | 済 |

- 名前とサブタイトルにある語（mojimachi・hiragana・writing・write・kana・watch・move）は、キーワードに入れない。
- 日本のストアで英語の欄が検索に使われるかを確かめ、使われるなら日本語の検索語を補う【要確認】（D40）。
- 端末の言語が英語でも、App Store の「年齢」「国」の設定は日本語版と同じ。

### 英語の説明文（上限4,000）

最初に「日本語を学ぶアプリで、子ども向けの画面と声は日本語」と書く（D118）。**金額は書かない。今後足す言語の予告もしない。**

```
Mojimachi helps young children learn to write Japanese hiragana, katakana, and the alphabet. Please note: the child-facing screens and voices are in Japanese. The parent area is available in English.

Hiragana is completely free.
You can try a few letters from each pack for free, then add Katakana, the alphabet and numbers with a one-time purchase.
No ads. No subscriptions.

Write a word, and the lines you drew gather and turn into a moving picture. What you write joins "My Town", which grows busier with every word.

GENTLE STROKE-ORDER PRACTICE
- Learn each letter step by step: watch, trace, trace a faint guide, then write on your own
- Gentle feedback on stroke order, starting point, and direction
- Mistakes are never scolded. The app simply says "Let's try again"
- Stop, hook, and sweep endings are shown as hints, not mistakes
- Parents can choose how strict the feedback is

LETTER MAP
- Hiragana (free), katakana, alphabet (upper and lower case), and numbers
- Choose from the a-i-u-e-o (gojuon) chart or a suggested order
- Each letter grows from seed to sprout to bud to flower

WORDS
- [UPDATE: actual number] About 300 words to write, arranged by place and theme
- All hiragana words are free
- "Word of the Day" and Shiritori (a Japanese word-chain game) bring new words every day
- Words are read aloud in Japanese, so children who cannot read yet can play

FOR PARENTS (IN ENGLISH)
- No ads and no third-party analytics
- Purchases and settings are only in the parent area, behind a multiplication question. Child screens never show prices or buy buttons
- Try a few letters and one word from each paid pack first. One-time purchases, no subscription
- Learning records are stored only on the iPad and in the parent's own iCloud (you can turn this off). The developer cannot see them
- See which letters your child has written, how they improved, and which ones are tricky
- Works with Apple Pencil or a finger
- Crash reports are sent only when the app crashes, with no names or records

Privacy policy: https://kenchan0130.github.io/apps/mojimachi/privacy/en
```

- 「Shiritori」「ずかん」の扱い: ずかんはコードにある（D181）が、説明には入れていない。出す版で足す。**ないものは書かない**（D72）。
- 「Family Sharing」は、全商品で有効にしたときだけ書く（D89）。

### 英語の「このバージョンの新機能」（最初のバージョン）

```
Welcome to Mojimachi!
- Practice hiragana, katakana, and the alphabet with the right stroke order
- Words you write come alive in your own little town
- Word of the Day and Shiritori
- The parent area is available in English
```

### 英語の App のプライバシー（栄養成分表示）の答え

§6 と同じ答えを、ASC の英語の画面の言葉で書く。

| ASC の質問 | 答え |
|---|---|
| Do you or your third-party partners collect data from this app? | Yes |
| Data used to track you | None. The app does not use App Tracking Transparency |
| Data linked to you | Contact Info > Email Address (optional, only if a parent writes it in the contact form); User Content > Other User Content (the text of the contact form). Purpose: App Functionality (customer support) |
| Data not linked to you | Diagnostics > Crash Data. Purpose: App Functionality. Collected through Sentry only when the app crashes. No user ID, IP address, breadcrumbs, performance data, sessions, or recordings. Do not select "Performance Data" or "Other Diagnostic Data" |
| Data not collected | Name and nickname (they stay on the iPad and in the parent's iCloud and never reach the developer), learning records, lines the child drew, purchases, identifiers, usage data, advertising data, location, contacts, photos, audio, health, financial info |
| Age rating | 4+. In-app controls: Parental controls = Yes (parental gate before purchases, settings and external links). Age assurance = No |

## 4. 課金アイテム（コードから）

`Packages/Sources/EntitlementKit/Entitlements.swift` と `App/Mojimachi.storekit`（M1。D91）。全部「消耗しない」（買い切り）で、ファミリー共有を有効にする。

| 商品 ID | 種類 | 価格（円） | 参照名（storekit） | 見せる相手 |
|---|---|---|---|---|
| `io.github.kenchan0130.mojimachi.pack.katakana` | 消耗しない | 250 | Katakana pack | 何も持っていない人 |
| `io.github.kenchan0130.mojimachi.pack.abc` | 消耗しない | 250 | ABC pack | 何も持っていない人 |
| `io.github.kenchan0130.mojimachi.all` | 消耗しない | 500 | All | 何も持っていない人 |
| `io.github.kenchan0130.mojimachi.all.owner1` | 消耗しない | 250 | All for one-pack owners | パックを1つ持っている人 |

- 価格の段階（250円・500円）が円の段階にあることを、ASC で確かめる（D89）【要確認】。
- 課金のプロモーションは使わない（D76）。審査用のメモで、同じ効果の商品が並ぶ理由を書く。
- 表示名は日本語・英語とも2〜30文字（D89）。D98 の名前の案:

| 商品 | 日本語の表示名（D98） | 英語の表示名（`Mojimachi.storekit` の `en_US` と同じ。D186。用語集: すべての文字＝All Letters） | 説明（D98） |
|---|---|---|---|
| katakana | カタカナ | Katakana | カタカナの字が書けます。（ことばを入れたら足す）／ Write all the Katakana letters. |
| abc | アルファベットと数字 | Alphabet and Numbers | アルファベットと数字の字が書けます。（えいごのことばを入れたら足す）／ Write the alphabet letters and numbers. |
| all | すべての文字 | All Letters | いまある文字と、これから追加する文字が、すべて使えます。／ Every letter now, plus letters added later.（ASC の説明は55字まで。アプリの購入画面の英語は長い文のまま） |
| all.owner1 | すべての文字（1つ購入済みの方） | All Letters (pack owners) | 同上 |

- **名前と説明は D98 にそろえた（D183）**: `Mojimachi.storekit`・購入画面（`PurchaseView.swift`。StoreKit の名前を優先して出す）・この表。説明は、いまのアプリにある中身（字）だけを書く。カタカナ・ABC のことば、すうじ あそび、ずかんは、作ってから足す（D72）。ASC にも、この名前と説明を入れた（2026-11-27）。
- 各商品に、審査用のスクリーンショット（保護者用の購入画面）が要る。
- 子どもの画面に価格・購入は出ない。購入は保護者用の画面の「購入」だけ（確認済み。§8）。

## 5. 最初のリリース（M1）の中身【要更新】

D179: 約300語で出す。約1,000語はアップデートで足す。

| 項目 | 目標 | 2026-11-27 のいま | メモ |
|---|---|---|---|
| ことばの数 | 約300語 | **305語**（`Assets.xcassets/word-*`。2026-11-27） | 説明文・スクリーンショット⑤は実際の数に（D72）。数が変わったら、説明の両言語と画像の数を直す |
| ひらがな | 全部（無料） | 字のデータ80ファイル（にごる・ちいさい字を含む。NOTICE などを除いて確認する） | 【要更新】字数を数えて確かめる |
| カタカナ | 約90字 | 82ファイル | 同上。購入画面の「約90文字」の言い方と合わせる（D95） |
| アルファベットと数字 | 52字＋数字（D180: 62字） | 63ファイル（README を除くと62字） | |
| カタカナのことば・えいごの ことば・すうじ あそび・ずかん | 設計にある（D45） | **コードにまだない** | 出さないなら説明・課金の説明から外す。出すなら作る |
| 声 | 日本語の声1人（VOICEVOX:猫使ビィ。D162） | 入っている | 「設定」アプリの もじまち のページの一番上にクレジットあり（D196） |

## 6. App のプライバシー（栄養成分表示）の答え

App Store Connect の「App のプライバシー」。D73・D103・D124・D148 とコードから出した。**Sentry の有無で答えが変わる。**

### 前提（コードで確かめたこと）

| 確かめたこと | 結果 |
|---|---|
| 外へ通信するコード（`URLSession` など） | アプリ本体にはない。通信は Apple の部品（StoreKit・CloudKit）と、アプリ内ブラウザで開くリンクだけ |
| 分析・広告・追跡のライブラリ | なし（`docs/dependencies.md` の一覧は TCA と同じ作者のライブラリ、Apple のライブラリだけ） |
| Sentry | **入れた**（D183。`sentry-cocoa` 9.36.0）。DSN が空のビルドと DEBUG では動かない。動くときも、落ちたときの情報だけ。ID・ユーザー・端末の名前・操作の記録・性能・セッション・録画は送らない（`CrashReportingTests`）。オフにするスイッチはない |
| MetricKit | 使っていない |
| 外部リンク | `SupportView.swift` の 5 つだけ（Google フォーム3つ、サポート、プライバシーポリシー）。すべて保護者用の画面の中 |
| 権限の確認（位置・カメラ・マイク・写真・連絡先） | なし。`NSFaceIDUsageDescription` は日本語と英語で入れた（`InfoPlist.xcstrings`。D183・D186。保護者用の確認の「iPad のパスコードも求める」用） |
| iCloud | 自分の非公開データベースだけ（`privateCloudDatabase`）。共有・公開データベースは使わない（D148） |

### 答え

| 質問 | 答え |
|---|---|
| トラッキングに使うデータはあるか | **いいえ**。ATT（`NSUserTrackingUsageDescription`）は使わない |
| データを収集するか | **はい**（診断と、お問い合わせのフォーム） |

| データの種類 | 収集 | ユーザに関連付け | 追跡 | 目的 | 根拠 |
|---|---|---|---|---|---|
| 診断 > クラッシュデータ | **はい**（Sentry。D183） | **いいえ**（ユーザに関連付けない） | **いいえ**（追跡に使わない） | アプリの機能 | D103・D123・D183。ID・IP・パンくず・性能・セッション・録画は送らない。`PrivacyInfo.xcprivacy` の `NSPrivacyCollectedDataTypeCrashData`（Linked: false・Tracking: false・AppFunctionality）と同じ答え。**診断のうち「性能データ」「その他の診断データ」は、「いいえ」**（Sentry の部品は自分の申告にこれらを含むが、このアプリは送る設定にしていない） |
| 連絡先情報 > メールアドレス | はい（任意。フォームに書いたときだけ） | はい | いいえ | アプリの機能（お客様サポート） | D124。既存アプリの申告に合わせる【要確認】 |
| ユーザコンテンツ > カスタマーサポート | はい（フォームの本文） | はい | いいえ | アプリの機能 | D124。ASC に「カスタマーサポート」の項目があるので、こちらにした（2026-11-27 に ASC へ入力・公開） |

収集しないと答えるもの（根拠つき）:

| データ | 理由 |
|---|---|
| 名前・呼び名 | 呼び名は iPad と保護者の iCloud の中だけ。運営者に届かない。CloudKit の非公開データベースは、運営者が読めないので「収集」に当たらない（Apple の定義に沿って最新の案内で確かめる【要確認】） |
| 学習記録・書いた線 | 同上（iPad と iCloud の中だけ） |
| 購入 | Apple が処理する。運営者は個人を特定できる購入記録を受け取らない |
| 識別子（デバイス ID・ユーザ ID） | 送らない。IDFA は使わない |
| 使用状況データ・広告データ・位置情報・連絡先・写真・動画・音声・健康・金融 | 扱わない |

メモ:
- お問い合わせは Google フォームを使う。フォームは Google が運営するので、Apple の定義で「アプリが収集する」に当たるかを、提出前に確かめる（D73 の「任意のフィードバックの例外」の条件）。当たらないと分かれば、2つの行は外せる。申告しすぎる側は安全。
- 「データの収集なし」で出せる形にはしていない（D103）。なので、スクリーンショット⑦は「広告なし・課金は おとなだけ」にする（D103）。

## 7. 年齢制限の質問票の答え（ASC。2025年からの新しい質問票）

最新の質問票の文言は ASC で確かめる【要確認】。下はコンテンツから考えた答え。Kids カテゴリなので 4+ になるはず。

| 質問 | 答え |
|---|---|
| アプリ内コントロール: 保護者による制限（ペアレンタルコントロール） | **あり**（保護者用の確認。課金・設定・外部リンクの前） |
| アプリ内コントロール: 年齢確認（年齢保証） | なし（Apple の年齢範囲の API は、米国の対応を決めるときに見直す。D65） |
| 暴力（漫画・リアル・銃や武器） | なし |
| 性的な内容・ヌード | なし |
| 冒涜・下品なユーモア | なし |
| 恐怖・ホラー | なし |
| アルコール・たばこ・薬物 | なし |
| 医療・健康に関する情報 | なし |
| ギャンブル（疑似も含む） | なし |
| ルートボックス | なし |
| コンテスト・懸賞 | なし |
| ユーザー生成コンテンツ・チャット・メッセージ | なし（ほかの人と見せ合う機能はない） |
| 制限のないウェブアクセス | **なし**（開けるのは、運営者のページと Google フォームだけ。しかも保護者用の画面の中） |
| 広告 | なし |
| 結果 | 4+ |

## 8. Kids カテゴリの審査の確認表（ガイドライン 1.3・5.1.4・3.1.1）

| 決まり | このアプリ | 確かめた場所 | 状態 |
|---|---|---|---|
| 第三者の広告を入れない | 入れていない | 依存の一覧、ソース検索 | OK |
| 第三者の分析を入れない | 分析は入っていない。ただし **Sentry が、落ちたときだけクラッシュの情報を第三者（Sentry）に送る**（D183）。1.3 で却下される報告がある（D103） | `CrashReporting.swift` | 【要確認】審査用のメモに書く。却下に備え、外した版をすぐ出せる作りにする（D123。`CrashReporting.start()` を消して依存を外すだけ） |
| 個人情報・端末の情報を第三者に送らない | 通信は Apple の部品だけ。例外は、クラッシュの情報（Sentry。端末の名前・ID は消し、送る文脈は許す項目だけ。D193）と、Google フォーム（保護者が任意に送る。フォームの URL には、調べるためにアプリの版と iPadOS の版だけを入れる。端末の ID・機種名は入れない。D193 で D183 を変更） | `FeedbackForm.swift`・`CrashReporting.swift` | OK。審査用のメモで説明する |
| 外部リンクの前に保護者用の確認 | 5つのリンクはすべて保護者用の画面の中。入口は歯車の2秒長押し＋かけ算 | `SupportView.swift`・`ContentView.swift` | OK。ただし下の2点に注意 |
| 購入の前に保護者用の確認 | 購入は保護者用の画面の「購入」だけ。子どもの画面に価格も購入ボタンもない | `PurchaseView.swift`・`LockScreenView` | OK。ただし下の2点に注意 |
| 保護者用の確認が子どもに解けない | 漢数字の「2桁×1桁」のかけ算。3回まちがえると30秒待つ。iPad の確認が要るときは、それが通るまで開かない。子どもの切り替えに使ったあとはすぐ閉じる（D193） | `ParentGateKit` | OK |
| 保護者用の画面の有効時間（5分）が守られる | 守られる（D183）。操作のたびに5分先へ延び、開いているあいだ1秒ごとと、アプリに戻ったときに確かめて閉じる | `ParentGateFeature.swift`・`ContentView.swift`・`ParentAreaView.swift`。テスト: `ParentGateFeatureTests`・`ParentAreaTimeoutUITests` | OK |
| 権限（位置・カメラ・マイクなど）を求めない | 求めない | Info.plist | OK |
| プッシュ通知で子どもを誘導しない | 通知は使わない。`remote-notification` は iCloud 同期の裏の更新のためだけ（許可の確認は出ない） | `Info-extra.plist` | OK。審査用のメモに書く |
| プライバシーポリシーがある・アプリの中からも行ける | 保護者用の画面の「サポート」にリンク。ページは公開済み（2026-11-28。D198） | `SupportView.swift` | 済 |
| 子どもの画面にエラー・価格・「かう」を出さない | 出さない | D3・D117 | OK |
| 評価のお願いを子どもに出さない | 保護者用の画面の「アプリを評価する」だけ | `SupportView.swift` | OK |
| 収集を最小にする | 呼び名は任意。年齢・学年・生年月日は聞かない | `Profile.swift` | OK |
| プライバシーマニフェスト（`PrivacyInfo.xcprivacy`） | 入れた（D183。`App/Mojimachi/PrivacyInfo.xcprivacy`。`UserDefaults`・`CA92.1`、クラッシュデータ） | `PrivacyInfo.xcprivacy` | OK。アーカイブしたあと、Xcode の「プライバシーレポート」で、Sentry の部品の分もまとまって見えることを確かめる【人】 |
| アプリのアイコン | **画像がない**（別の作業で描く。P1） | | **直す必要あり** |

## 9. 審査用のメモ（App Review Information の下書き）

連絡先（名前・電話・メール）は、個人情報保護士のアプリと同じものを ASC に入れた（2026-11-28。ここには書かない）。サインインは要らない。

日本語でも英語でも書く。下は英語（審査する人向け）。

```
Mojimachi is a handwriting practice app for young children (Kids category, age 5 and under). Child-facing screens and voices are in Japanese. No sign-in is needed.

HOW TO OPEN THE PARENT AREA
Everything that involves purchases, settings, external links, and learning records is in the parent area. On the Home screen, press and hold the small gear icon at the top right for 2 seconds. Then answer the multiplication question written in kanji numerals (for example "十四かける六" = 14 x 6 = 84) with the number pad.

IN-APP PURCHASES
Purchases are only in Parent Area > Purchase (購入), after the parental gate. Child-facing screens never show prices or buy buttons. When a child taps a locked letter, the app only says "ask a grown-up" and records the wish. It never opens a purchase screen. We do not use promoted in-app purchases.
There are four non-consumable products. "All Letters (One Pack Owned)" is shown only after the user owns one pack, as a cheaper way to get the second pack. In the sandbox, buy one pack first to see it.

EXTERNAL LINKS
All links are in Parent Area > Support, behind the parental gate: the support page, the privacy policy, and a Google Form for contact. Links open in Safari, outside the app. A parent decides whether to send it.

DATA
No ads. No third-party analytics. Crash information only (crash location, app and OS versions, device model family) is sent to Sentry, only when the app crashes. No user ID, no IP address stored, no breadcrumbs, no sessions, no screen recordings. It is not linked to any user and not used for tracking. The contact form link carries no app version or device information.
Learning records are stored on the device and, if enabled, in the user's own iCloud private database (CloudKit). The developer cannot read them.
The app uses the remote-notification background mode only for CloudKit sync. It never asks for notification permission.

FAMILY SHARING AND ASK TO BUY
All products support Family Sharing and work with Ask to Buy.
```

## 10. 公開前に ASC に入れる、そのほか

| 項目 | 内容 |
|---|---|
| 輸出コンプライアンス | 標準の暗号（HTTPS・CloudKit）だけ。免除。`ITSAppUsesNonExemptEncryption = NO` を Info.plist に入れた（`INFOPLIST_KEY_ITSAppUsesNonExemptEncryption`。D183）。毎回の質問は出ない |
| コンテンツの権利 | 第三者のコンテンツを含む → はい。権利は持っている（書体 OFL、文字のデータ OFL/MIT、効果音、声 VOICEVOX:猫使ビィ。出どころは「設定」アプリの もじまち のページ（D196）と `Content/*/provenance.csv`）。声と効果音の規約（表示の義務）を公開前に読み直す（D81）【人】 |
| 広告識別子（IDFA） | 使わない |
| アクセシビリティの表示（Nutrition label） | VoiceOver・文字の大きさ・字幕など、実際に確かめたものだけ申告する（D36）【要確認】 |
| アプリ内イベント | 最初は作らない（D76）。日本のストアだけ、購入を含まない内容で、あとで |
| カスタムプロダクトページ | 最初は作らない。公開後に作る（D40） |
| プロダクトページの最適化（アイコンの比較） | 公開後（D76） |
| 教育機関向けの割引 | 施設向け版を作るときの最初の提出で設定する（D99）。今回は不要 |
| スクリーンショット | `screenshots-plan.md` |
| プレビュー動画 | 15秒。書く → 変身 → まち。音なしでも伝わる（D40）【人】 |
