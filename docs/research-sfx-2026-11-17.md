# 効果音の素材サイト調べ（2026-11-17）

方針: BGM はやめる。効果音だけにする。単純な音は SoundKit（プログラム）で作り、物や動物の音は、無料で商用に使える効果音サイトから選ぶ。AI で作らない。

この文書は調べた記録で、決定ではない。決めるときは `docs/design.md` に D 番号を足し、§3.9・D29・D62・D115 を直す。

**大事な注意**: 規約は予告なく変わる。ダウンロードするときに、人が規約ページをもう一度開いて確かめ、日付を記録する。この調べで読めなかったページ（後の「未確認」）は、必ず自分の目で読む。

## 1. 必要な音（design.md から）

- §3.9「効果音」: 単純な音（ド→レ→ミ、ボタン、ほめる音）はプログラム。鳴き声や物の音は外から。1画ごとに音が鳴り、書いている間は線を引く小さな音。
- D115: 効果音は約100〜200個。出どころ（サービス名・サイト・日・指示の文）を記録し、表示が必要な素材は「このアプリについて」に載せる。形式は Opus。
- D62: 声は Opus モノラル。効果音も劣化に問題がない範囲で圧縮する。つまり**加工（変換・短くする・音量を揃える）が許される素材**だけを選ぶ。
- D128: 出どころの記録の前例（ライセンス全文の表示、「このアプリについて」）。

## 2. 比べる軸と結論の先出し

アプリの中に音ファイルを入れて売ることは、多くのサイトで「素材としての再配布」にあたらない。禁じられているのは、素材そのものを第三者が取り出せる形で配る・売ること。ただし「音ファイルがむき出しで入る」点を明記しているのは効果音ラボだけだった。他は「作品に組み込む」ことを許す書き方にとどまる。不安なら問い合わせる。

| 場所 | 有料アプリ | アプリに同梱 | クレジット | 加工・圧縮 | 気をつける点 |
|---|---|---|---|---|---|
| 効果音ラボ | OK | OK（明記） | 不要 | OK | AI 学習禁止、効果音が主役のアプリはNG |
| OtoLogic | 未確認 | 未確認 | 未確認 | 未確認 | 公式ページが取れなかった |
| 魔王魂 | OK | 作品に組み込めば可 | 「可能な限り」表記 | OK | 主に音楽。SE の個別規約を見る |
| ポケットサウンド | OK | OK（ゲームOK、アプリは明記なし） | **必要**（無料）。なしは有料 | OK | 直リンク禁止 |
| On-Jin | 事業は連絡が必要 | 組込のみ可 | 任意（※1） | 組込制作なら可 | 販売は「連絡が必要」に当たる |
| 無料効果音で遊ぼう!（小森平） | OK | OK（アプリを明記） | 規約に明確な要求なし | OK | 読み取りが不完全 |
| OpenTracks（旧 DOVA-SYNDROME） | 素材ごと | 素材ごと | 不要（任意） | 素材ごと | 2026-09-15 に改名。音源ごとのライセンスを見る |
| Pixabay | OK | OK（単品配布のみ禁止） | 不要 | OK | 単品で配るのは禁止 |
| Freesound（CC0だけ） | OK | OK | 不要 | OK | 1ファイルずつ CC0 か確かめる |
| Zapsplat | 無料は表記が要る | OK（ゲーム・アプリ） | 無料は必要 | OK | 未確認が多い |
| Mixkit | OK（※2） | 未確認 | 不要（※2） | 未確認 | 公式の規約本文を読めなかった |
| Sonniss GDC | OK | OK | 不要（歓迎） | OK（編集版を配るのはNG） | AI 学習禁止 |
| Kenney | OK | OK | 不要 | OK | CC0 |
| OpenGameArt（CC0） | 素材ごと | 素材ごと | CC0 は不要 | CC0 は OK | 投稿者の自己申告。出どころの確認が要る |

※1 On-Jin は「音がシステムの中で外から見える場合は著作表記と二次配布禁止の表記が必須」。iOS アプリの中身は取り出せるので、表記する前提で考える。
※2 Mixkit は公式情報ページの要約と第三者の記事による。規約本文は未確認。

## 3. 各サイトのくわしい確認

### 3.1 日本のサイト

**効果音ラボ** — https://soundeffect-lab.info/agreement/ （2026-11-17 に確認）
- 「個人、法人、公的機関問わず無料で使用可能（商用利用無料）」
- アプリに操作音として入れるのは再配布に当たらない。「アプリに操作音として効果音を組み込む（音源ファイルむき出しでも可）」が例にある。
- クレジット・報告・リンク不要（「禁止ではなく任意」）。
- 改変して使うのは問題ない。改変したものを再配布するのは禁止。
- 禁止: アダルト・公序良俗に反する作品、違法行為、**AI 学習用データとしての利用**、直リンク、音商標登録。
- 「効果音が重要な役割を果たすコンテンツ」は再配布と同じ扱い。もじまちは音が主役のアプリではないので当たらないと考えられるが、効果音を鳴らす遊びを作るときは注意する。
- 動画編集アプリの標準素材として入れるのは再配布。
- 子ども向け・ストアに関する禁止は見つからなかった。
- 企業は「再配布禁止、許可できる場合あり」。大量に使う場合の連絡義務は書かれていない。

**OtoLogic** — https://otologic.jp/free/license.html
- 公式ページが 403 で読めなかった。**未確認**。ダウンロード前に人が読む。「商用可・クレジット表記が必要（CC BY 4.0 の形）」と記憶している人が多いが、この調べでは裏づけが取れていない。信じて使わない。

**魔王魂** — https://maou.audio/rule/
- 「商用でも制限無く無料で使えます。」報告不要。
- 「素材の改変はご自由に」。長さ・音量・ピッチの変更を含む。
- 「可能な限り『音楽：魔王魂』みたいに著作表記して下さい。」ライバー系アプリは必須。
- 「曲単品を再配布するのはNG」。
- 「生成AIに魔王魂の音楽を学習させる行為はいかなる場合でも違反」。
- ページは音楽が中心。効果音は別の規約が付く場合があるので、SE のページを確かめる。

**ポケットサウンド** — https://pocket-se.info/rules/
- 「販売用ゲームへの利用、YouTube収益化できます」「基本無料・商用可・加工OK」。
- 無料の条件は「作品でのクレジット表記、またはポケットサウンドへのリンク」。できないときは有償（効果音1つ550円など）。
- 禁止: 「音素材そのものの二次配布・転売」、直リンク。
- アプリの明記はない（ゲームは OK）。AI の条項なし。
- 使うなら「このアプリについて」に載せる。または有償にして表記をなくす。

**On-Jin** — https://on-jin.com/kiyaku.php
- 個人・サークル・学校などは営利・非営利を問わず使える。**企業は連絡が必要**。
- 「作品、製品を事業・営利・商用として制作、または販売する場合」は連絡が必要な場合に当たる。有料アプリは当たる。
- 「素材として販売や公開、配信するなど、第三者が取得できる状態にする事はできません」。ただし「自主制作作品などに組込制作をする場合に限り、加工、公開や販売をしても構いません」。
- 直 URL で音を設定するのは禁止。ニコニ・コモンズ経由の素材は営利利用不可。
- 主な利用がグレーなので、第一候補にしない。

**無料効果音で遊ぼう!（小森平）** — https://taira-komori.net/ （規約は welcome.html。2026-11-17 に確認、文字化けで一部読めず）
- 使い道に「ゲーム、アプリ、動画、広告」を挙げ、商用・非営利とも可。加工・変換・製品への組み込みも可。海外利用も可。
- 禁止: 自作と偽ること、素材そのものの再配布・転売、犯罪、Scratch での使用。
- クレジットの要不要は読み取れなかった。連絡先: komoritaira@gmail.com。ダウンロード前に原文を読む（文字コード Shift_JIS）。
- 古い URL taira-komori.jpn.org は taira-komori.net に移っている。
- 動物・乗り物・日常の音が多く、もじまちの変身の音に向く。

**OpenTracks（旧 DOVA-SYNDROME）** — https://opentracks.com/help/articles/terms/ ／ 改名のお知らせ https://opentracks.com/news/detail/7
- 2026-09-15 に DOVA-SYNDROME から OpenTracks に改名。旧 URL は転送される。規約は名前と URL の表記以外は変わっていない。
- 「用途・営利・非営利を問わず無料で自由に」。「著作権・提供等の表示は不要」。
- 禁止: サイトの内容を複製して公開、「非権利者が当サイトの音源を二次的に公開・配布する行為」、音源 URL への直リンク、bot での収集。
- 音源の使い方は「音源利用ライセンス」が別にあり、**音源ごと**に決まる。そのページは読めなかった。SE は約1,283件。
- アプリへの同梱は規約に明記なし。音源ごとのライセンスを見て、迷えば問い合わせる。

### 3.2 海外のサイト

**Pixabay** — https://pixabay.com/service/license-summary/
- 「Use Content without having to attribute the author」（表記不要）。
- 禁止: 「sell or distribute Content ... on a Standalone basis」。「Standalone」は創作の手が入っていないこと。
- 商標つき素材を商品にするのは不可。要約は法的な拘束力がなく、本文は利用規約にある。
- 音声の効果音も同じ規約。投稿者が他人の音を上げる例もあるため、重要な音は聞き覚えのある有名な音に似ていないか確かめる。

**Freesound** — https://freesound.org/help/faq/
- CC0: 表記不要・商用可。CC BY: 商用可・表記必要。CC BY-NC: 商用不可（有料アプリでは使えない）。Sampling+: 広告に使えない。
- **CC0 だけ**に絞り、検索で License = Creative Commons 0 を選ぶ。1ファイルずつ、ページのライセンスの表示を保存する。
- 投稿者が他人の音を上げている可能性が残る。重要な音には使わない、または複数の候補を聞き比べる。

**Zapsplat** — https://www.zapsplat.com/license-type/standard-license/ （公式ページが 403 で読めず、検索結果と第三者の記事による）
- 無料のスタンダード・ライセンスは**表記が必要**。有料（Gold）で表記がなくなり WAV が使える。ゲーム・アプリ・ソフトに使える。
- 「このアプリについて」に Zapsplat を載せられるなら使える。公式の本文を読むまで確定しない。

**Mixkit** — https://mixkit.co/license/ （「Sound Effects Free License」に本文のリンクがあるが、取れなかった）
- 第三者の記事では「商用可・表記不要」。再配布の条項は未確認。ダウンロード時に本文を読む。

**Sonniss GDC** — https://sonniss.com/gameaudiogdc
- 「completely royalty-free for any commercial work」。表記は「always appreciated, but never required」。
- 「You cannot resell or redistribute the sound effects themselves, including edited versions」だが「sell them inside your finished game, film, or app」は可。
- 「Use for AI/ML training is strictly prohibited」。
- 最新の旧バンドルは GDC 2024。GDC 2025 はなし。GDC 2026 は別ページ。容量が大きい（数十 GB）ので、必要な音だけ取り出す。音は効果音ラボなどより質が高く、リアルな動物・乗り物・布の音が多い。

**Kenney** — https://kenney.nl/support
- 「all game assets ... are public domain licensed (CC0)」「free to use ... even in commercial projects」「Attribution is not required」。
- 音のパック: Interface Sounds、UI Audio、Digital Audio、Impact Sounds、Casino Audio、RPG Audio、Music Jingles など（https://kenney.nl/assets/category:Audio ）。ボタン・ほめる音の候補。動物や乗り物の音はほぼない。

**OpenGameArt（CC0 だけ）** — https://opengameart.org/
- FAQ が 403 で読めなかった。CC0 の作品は表記不要・商用可だが、投稿者の自己申告。作品のページのライセンスと出どころを保存する。第一候補にしない。

## 4. おすすめ

### 主な素材（まずここから探す）

1. **効果音ラボ**: 表記不要、アプリに同梱できる（音ファイルむき出しも明記）。ボタン、ほめる音、日常の音（布・ドア・水・人の動き）を中心に。禁止の「AI 学習」には使わないので問題ない。
2. **Kenney（CC0）**: ボタンや UI の音。
3. **Sonniss GDC（2024 以前と 2026）**: 動物・乗り物・衣服のような、リアルな物の音。表記不要、アプリに入れてよい。
4. **無料効果音で遊ぼう!（小森平）**: 動物の鳴き声、乗り物、日常の音。アプリの使用を明記。クレジットの扱いだけ原文で確かめる。

### 予備

- **Freesound（CC0 のみ）**: 足りない音を1つずつ探す。
- **Pixabay**: 足りない音を探す。単品で配らなければよい。
- **OpenTracks の SE**: 音源ごとのライセンスで「商用可・同梱可」と書いてあるものだけ。
- **ポケットサウンド**: 表記を載せる前提で。気に入った音だけ。

### 避ける・あと回し

- OtoLogic（規約未確認。確認できたら予備に入れる）、On-Jin（企業・販売は連絡が必要）、Zapsplat 無料（表記必要。載せるなら可）、Mixkit（本文を読んでから）、OpenGameArt（出どころの不安）、Freesound の CC BY（表記が増える）、CC BY-NC（使えない）。

### 表記の置き場所

表記が必要な素材は「このアプリについて」に載せる（D115、D128 と同じ）。子どもの画面には出さない。表記不要の素材も、記録は残す。表記を最小にするため、主な素材は表記不要のものにそろえる。

## 5. 必要な音と探し方

| 必要な音 | 主な出どころ | 検索の言葉（日本語 / 英語） |
|---|---|---|
| ボタン、タップ | SoundKit（プログラム）。足りなければ Kenney Interface Sounds | ボタン、決定 / click, button |
| ほめる音、正解 | SoundKit。かわいい鐘は効果音ラボ | ジャジャーン、きらきら / sparkle, chime, success |
| 1画ごとのド・レ・ミ | SoundKit（プログラム。素材は使わない） | — |
| 書いている音（線を引く音） | 効果音ラボ、Sonniss | 鉛筆、書く、クレヨン / pencil, scribble, chalk |
| 変身の演出 | 効果音ラボ、Kenney | 変身、ポン、キラキラ / transform, poof, magic |
| 乗り物（車・電車・飛行機・船） | 小森平、Sonniss | 車、電車、飛行機、クラクション / car horn, train, airplane, ship |
| 四つ足の動物（犬・猫・牛・馬・羊など） | 小森平、Sonniss、Freesound CC0 | 犬、猫、鳴き声 / dog bark, cat meow, cow, horse, sheep |
| 衣服（ふく、くつ、ぼうし） | 効果音ラボ、Sonniss | 衣擦れ、布、ファスナー / cloth rustle, zipper |
| キャラクターの反応（わあ、ぴょん、びっくり） | 効果音ラボ、Kenney | ジャンプ、びっくり、ぽよん / boing, jump, surprise, cartoon |
| 場所に入る・町の音 | 効果音ラボ、小森平 | ドア、足音、鳥 / door, footsteps, birds |
| 失敗・やり直し（強くしない） | SoundKit | やさしい音にする（D117: エラーを出さない） |

動物の鳴き声は、本物の録音に近いものと、かわいくした声がある。4〜7歳向けなので、驚かせる大きな音や怖い音は選ばない。音量を揃える（ラウドネスを合わせる）ことも忘れない。

## 6. 出どころの記録の形式（D128 にならう）

音ごとに1行（`Content/Audio/sfx-provenance.csv` のような一覧）。ファイル名は音のIDと同じにする。

| 項目 | 例 |
|---|---|
| 音のID | `sfx_animal_dog_01` |
| 使う場面 | 変身: 犬 |
| 元のサイト名 | 効果音ラボ |
| 元の作品の URL（その音のページ） | https://soundeffect-lab.info/... |
| 作者 | （サイトの表示どおり。不明なら「サイト名」） |
| 元の名前（ファイル名） | dog1.mp3 |
| ライセンス名と規約の URL | 効果音ラボ利用規約 / https://soundeffect-lab.info/agreement/ |
| 規約を読んだ日 | 2026-11-17 |
| ダウンロードした日 | 2026-11-17 |
| 表記が必要か | 不要 |
| 加工の内容 | 前後を切る、音量をそろえる、Opus 変換（64 kbps モノラル） |
| 規約の控え | `Content/Audio/licenses/soundeffect-lab-2026-11-17.png` か PDF |
| 確認した人 | |

規約ページは、保存（スクリーンショットか PDF）を残す。後で規約が変わっても、ダウンロード時点の条件が分かる。CC0 は、作品のページのライセンス表示も保存する。

## 7. 次にやること

1. 読めなかったページを人が読む: OtoLogic、Mixkit、Zapsplat、OpenGameArt、OpenTracks の「音源利用ライセンス」、小森平の welcome.html（原文）。
2. 実際に使う音を決めてから、その音のサイトの規約をもう一度読み、日付を記録する。
3. 小森平・On-Jin・OpenTracks など「アプリ」の明記が弱い素材は、使う前にメールで問い合わせて返事を保存する。
4. design.md の BGM と効果音の行（§3.9、D115）を、「BGM なし、効果音は無料素材」に直す新しい D 番号を足す。音量の設定からも BGM をなくす。

## 出典

- 効果音ラボ: https://soundeffect-lab.info/agreement/
- 魔王魂: https://maou.audio/rule/
- ポケットサウンド: https://pocket-se.info/rules/
- On-Jin: https://on-jin.com/kiyaku.php
- 無料効果音で遊ぼう!: https://taira-komori.net/welcome.html
- OpenTracks 利用規約: https://opentracks.com/help/articles/terms/
- OpenTracks 改名のお知らせ: https://opentracks.com/news/detail/7
- Pixabay: https://pixabay.com/service/license-summary/
- Freesound: https://freesound.org/help/faq/
- Zapsplat: https://www.zapsplat.com/license-type/standard-license/
- Mixkit: https://mixkit.co/license/
- Sonniss: https://sonniss.com/gameaudiogdc
- Kenney: https://kenney.nl/support ／ https://kenney.nl/assets/category:Audio
- OpenGameArt: https://opengameart.org/
- OtoLogic: https://otologic.jp/free/license.html
