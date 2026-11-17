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
| OtoLogic | OK（CC BY 4.0） | OK（人が確認） | 要（「OtoLogic」 https://otologic.jp） | OK | 2026-11-18 に人が落として使った（D158）。記録は `Content/Sounds/evidence/otologic-terms-2026-11-18.md` |
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

---

# 追加調べ: YouTuber がよく使う効果音の出どころ（2026-11-17）

きっかけ: 持ち主が「YouTube でよく使われる素材は使いやすいはず。もっとあるはず」と言った。上の章に無かったサイトを調べた。

**読み方の注意**
- 「YouTuber がよく使う」ことと「有料アプリに入れてよい」ことは別。YouTube 向けの許諾は、アプリの同梱を含まないことが多い。
- 規約本文を自分で読めたものは URL と短い引用を付けた。読めなかったものは**未確認**と書いた。検索結果や第三者の記事だけで知ったことは「第三者情報」と書いた。
- 規約は変わる。ダウンロードの日に、人が本文を読み直して日付を残す（上の「大事な注意」と同じ）。

## A. 結論の先出し

| 場所 | 有料アプリ | アプリに同梱 | 表記 | 加工 | 一言 |
|---|---|---|---|---|---|
| Springin' Sound Stock | OK（商用可） | ゲームは可。**自作の商用ソフトへの同梱は問い合わせが要る**と読める | 必須ではない | OK | 日本の YouTuber・ゲーム作者に人気。要問い合わせ |
| YouTube オーディオライブラリ | 未確認（YouTube 向け） | 未確認 | 音源ごと | 未確認 | **使わない**。YouTube の外は保証がない |
| OtoLogic | 未確認（公式 403） | 未確認 | **必要と見られる**（第三者情報） | 未確認 | 公式を人が読むまで保留 |
| 効果音工房・音人・くらげ工匠 | 未確認 | 未確認 | 未確認 | 未確認 | 公式ページが開けず、検索でも規約が出なかった |
| ニコニ・コモンズ | 素材ごと | 素材ごと | 素材ごと | 素材ごと | On-Jin の章のとおり、営利不可の素材がある。使わない |
| Epidemic Sound | 契約しだい | 未確認 | 不要（契約中） | 可 | YouTube 向け。アプリは別契約と見られる。避ける |
| Artlist | 契約しだい | 作品に組み込めば可（第三者情報） | 不要 | 可 | 年契約のみ。アプリの明記は未確認 |
| Envato Elements | 契約しだい | **未確認** | 不要 | 可 | 音が主体だと対象外。完成前に解約すると権利が消える |
| Storyblocks | 個人は解約後 NG | 未確認 | 不要 | 可 | 解約で権利が切れる契約がある。避ける |
| Motion Array | 契約しだい | 未確認（403） | 不要 | 可 | 未確認 |
| Uppbeat | 未確認 | 未確認 | 不要（有料時） | 可 | 音楽が中心。SE とアプリは未確認 |
| BBC Sound Effects | **不可** | 不可 | 必要 | — | 個人・教育・研究だけ（RemArc） |
| Soundsnap | OK（Pro は予算 50万ドルまで） | 「ゲームとアプリ」が明記 | 不要 | OK | 有料。解約後の扱いは本文に書かれていない |
| Pro Sound Effects | 買い切りは OK | アプリの扱いは未確認 | 不要 | OK | 買い切り（1人用）。瞑想アプリ等は禁止 |
| Boom Library | 買い切りは OK | **未確認** | 不要 | OK | 高品質。ゲーム・アプリの明記は読めなかった |
| 99Sounds | OK | 作品に組み込めば可 | 不要 | OK | 無料。ただし数は少なく、動物・乗り物は弱い |
| Soundly | OK（Free/Pro はゲームも可） | ゲームは明記。アプリは明記なし | 不要 | 未確認 | 音の検索ソフト。音は中の各ライブラリが元 |
| Pond5 | 買い切りは OK | **未確認** | 不要 | OK | 「デジタル専用ライセンス」の例外を読む必要がある |
| Videvo | 未確認 | 未確認 | 未確認 | 未確認 | Freepik に統合済み（301）。規約は未確認 |
| freesfx | 未確認 | 未確認 | 未確認 | 未確認 | 規約ページが 404。未確認 |

## B. くわしい確認

### B.1 日本の YouTuber 向けサイト

**Springin' Sound Stock（SHIKUMI DESIGN）** — https://www.springin.org/sound-stock/ ／ 規約と FAQ https://www.springin.org/sound-stock/guideline/ （2026-11-17 に確認。改定日の記載なし、フッターは ©2026）
- 約1,000点以上の BGM・効果音。カテゴリに「ボタン・システム」「自然・動物」「機械・乗り物」「生活」「演出」「声」がある（カテゴリ一覧はトップページのリンク）。もじまちに向く種類がそろう。
- 商用: 第4条は「商用か否かに関わらず」使えると読める。収益化した動画、有料ゲームが例に挙がる。
- 同梱: ゲームは可。FAQ は「素材ファイルを目立ちにくい配置に」と求める。**自分の商用ソフトに音を組み込むときは問い合わせフォームから連絡が要り、料金がかかる場合がある**と読める。もじまちは「ゲーム」ではなく「ソフト」に当たる可能性があるので、**使う前に必ずメールで問い合わせる**。
- 禁止（再配布にあたる）: 「ユーザーが自由に効果音を鳴らせるアプリ、再生が主な機能のアプリ」。もじまちは当たらない。
- 表記: 「クレジットは必須ではありません」。ただし第4条は、会社が指定したら従うと定める。報告は不要。
- 加工: 「問題ありません」。加工した素材を配る・売るのは禁止。
- AI 条項: 規約に書かれていない。未成年: 保護者の同意の条項があるだけ。子ども向けアプリの禁止は無い。
- 費用: 無料（上の問い合わせで有料になる可能性）。
- 判定: **人気・音の種類・無料の3点で有力**。ただし「アプリ同梱は問い合わせ」が条件。返事を保存できれば第2候補に上がる。

**YouTube オーディオライブラリ** — https://support.google.com/youtube/answer/3376882 （2026-11-17 に確認）
- 「The Audio Library is found exclusively in YouTube Studio.」YouTube の外の使い方は書かれていない。
- 「YouTube can't give legal guidance, including guidance on issues with music that can occur off the platform.」
- 第三者情報: 標準ライセンスの音は YouTube 向け。CC BY の音は他の場所でも使えるが、表記が要り、ゲーム・アプリは音ごとに確かめる必要がある。
- 判定: **アプリには使わない**。実質 YouTube 専用と見る。

**OtoLogic** — https://otologic.jp/free/license.html ／ https://otologic.jp/ （どちらも 403。再試行したが読めず）
- 第三者情報: あるアプリの説明に「OtoLogic の素材はクレジット表記が必須」とある。検索結果の別の作者の規約も、OtoLogic の名前を書くよう求めている。公式の条件ではない。
- 判定: **未確認**。有名で音がきれいなので、人が公式ページを読み、「アプリ同梱・表記の形・加工」を確かめる価値が高い。表記が前提なら「このアプリについて」に載せられる。

**効果音工房・音人（otojin）・くらげ工匠（フリー効果音素材）** — 公式 URL が開けなかった（名前解決失敗、証明書エラー）。検索でも規約は出なかった。
- すべて**未確認**。実在と現在の規約は、人がブラウザで開いて確かめる。確かめる点は、商用・アプリ同梱・表記・再配布の4つ。
- 「SoundEffect-Lab」は効果音ラボの英語名で、上の章と同じサイト。別の名前の兄弟サイトは見つからなかった。

**ニコニ・コモンズ**
- 素材ごとに使える範囲を作者が決める仕組み。On-Jin の規約にも「ニコニ・コモンズ経由の素材は営利利用不可」とある（上の On-Jin の章）。
- 2026年のサービス終了や規約変更の公式発表は、検索では見つからなかった。
- 判定: 素材ごとの条件がばらばらで、有料アプリには向かない。**使わない**。

### B.2 有料サブスク（YouTuber に人気）

共通の問題: 契約が切れた後の権利、アプリ（配る製品）に入れてよいか、子ども向けか。多くは「動画」前提の規約。以下は主に第三者情報と検索結果。

**Epidemic Sound** — https://www.epidemicsound.com/ （規約本文は未確認。search で第三者の転載のみ）
- 第三者情報: 契約中に公開した動画は、解約後もずっと使える。契約の後に公開した動画は対象外。体験期間にダウンロードした音は、体験期間のみ。
- ゲーム・アプリは、企業向けの別プランの扱いと見られる。もじまちのアプリ同梱は未確認。
- 判定: 動画向け。**避ける**。使うなら、アプリ同梱と解約後の扱いを、メールで書面にしてもらう。

**Artlist** — https://artlist.io/ ／ 規約 PDF https://artlist.io/media/w5mglb2w/pro-license-current-02092024.pdf （本文は読めず）
- 第三者情報: 「効果音は、ゲームやアプリなど作品に組み込む場合だけ配布できる。単品の配布は禁止」。解約後も、契約中に使い終えた作品は使える。
- Artlist 自身の Pro ライセンスは「契約が切れた後も、ずっと収益化できる」と書く（PDF の文言。第三者の引用）。
- 費用: Creator Pro は年契約のみ（約 199 ドル / 年。第三者情報）。
- 判定: アプリ同梱の明記が確認できていない。**未確認のため第2候補にも入れない**。

**Envato Elements** — https://help.elements.envato.com/hc/en-us/articles/360000621483 （403。検索結果の要約のみ）
- 第三者情報: 「契約中に完成した作品（End Product）に入れた音は、ずっと使える。完成前に解約すると権利が終わる」。
- 音は「大きな音声映像の作品の一部」として使う前提。**音そのものが主な価値の製品は対象外**。
- アプリの扱いは、論点が複数あり**未確認**。
- 判定: 避ける。

**Storyblocks** — https://www.storyblocks.com/license （2026-11-17 に確認）
- 個人・小規模事業のライセンスは、解約後に使い続けることが「No」。「You cannot stockpile assets for use after your Storyblocks subscription ends.」
- 「games」は用途に挙がるが、アプリの明記はない。
- 判定: **避ける**（解約で権利が切れる契約がある）。

**Motion Array** — https://motionarray.com/license/ （403）
- 第三者情報: 解約後は、完成した作品は使える。アプリ・ゲームの扱いは**未確認**。

**Uppbeat** — https://uppbeat.io/uppbeat-basic-license （429 で読めず）
- 第三者情報: 解約前に公開した作品は引き続き使える。解約前にダウンロードして使っていない音は、新しい作品に使えない。ゲームの扱いは書かれていない。主な素材は音楽。
- 判定: **未確認**。

### B.3 効果音ライブラリ（欧米のプロ向け）

**Soundsnap** — https://www.soundsnap.com/licence （2026-11-17 に確認）
- 「Pro covers video games and apps with budgets up to $500,000」（Pro は予算 50万ドルまでのゲームとアプリ）。
- 商用・収益化は可。
- 禁止: 音をそのまま再配布・転売。「mobile applications, plugins, or similar products」の拡張パックを作ること。**AI・機械学習の学習は特別な許諾が要る**。
- 解約後: 「perpetual (for the duration of the applicable copyright)」だが「revocable」とも書かれる。解約で切れるとは書かれていない。ただし明記もない。**メールで確認する**。
- 表記: 不要（読み取った範囲）。子ども向けの条項は見つからなかった。
- 費用: 有料の月額（金額は未確認）。
- 音: 動物・乗り物・生活音が大量にあり、実録音が中心。
- 判定: **有料の予備として最有力**。1か月だけ契約して必要な音をまとめ、解約後の権利をメールで保存する運用が考えられる。

**Pro Sound Effects** — https://www.prosoundeffects.com/ （ライセンスのページは 404。別の部分のページを読んだ）
- 「1-user royalty-free unlimited commercial usage, forever」（買い切り）。
- 契約型は「while you are subscribed」だけ有効。「Any project created while subscribed will stay covered」。
- 禁止: 「Re-sell sound effects files in any way」、AI・機械学習の学習、「relaxation or meditation apps」と「soundboard」への組み込み。
- もじまちは禁止の用途に当たらないが、**ゲーム・アプリの明記は読めなかった**。
- BBC の音を商用で使いたい人は、ここ（有料）に誘導される（第三者情報）。
- 判定: 買い切りなら解約の問題がない。個別の音を買う予備。

**Boom Library** — https://www.boomlibrary.com/?p=269603 （一部のみ）
- 「Yes, our sounds come with a royalty-free perpetual license.」解約後は、完成した作品はそのまま使える。
- 「The products are only available for commercial customers」。ゲーム・アプリ・AI の条項は**未確認**。EULA を人が読む。
- 判定: 高品質。個別に買うなら予備。

**Soundly** — https://getsoundly.com/faq/can-i-use-the-sounds-in-a-video-game （2026-11-17 に確認）
- 「cleared for commercial use, including video games」（Free と Pro の音）。Pro 契約中に作ったゲームは、解約後も使える。
- アプリ（ゲーム以外）は明記なし。Freesound を足した場合は CC0 だけに絞る。
- 判定: 音の探しやすいソフト（Mac・Windows）。音の権利は、中の各ライブラリの条件による。「ゲームは可」は、有料アプリの根拠として近いが、確定ではない。**未確認が残る**。

**Pond5** — https://www.pond5.com/legal/license/20170301 ／ https://www.pond5.com/help/en/articles/10086102-all-about-our-licenses （検索結果の要約のみ）
- 標準ライセンスは「永遠・全メディア・世界」。サブスクで取った音にも個別ライセンスが付く。
- 「Digital Only Licenses」に例外がある。ゲーム・アプリは**未確認**。
- 判定: 個別に買えば解約の問題はない。ただし値段と条件を読んでから。

**99Sounds** — https://www.99sounds.org/license/ （2026-11-17 に確認）
- 「royalty-free for personal and commercial projects」。表記は「not obligatory」。加工可。
- 禁止: 音ファイルを売る・配る（無料でも）。**「noise apps, white noise apps, sleep sound apps」への利用は不可**。
- もじまちは当たらない。ただし数が少なく、動物・乗り物は弱い（ライブラリの内容は個別に見る）。
- 判定: 補助。

**BBC Sound Effects**（RemArc） — https://sound-effects.bbcrewind.co.uk/licensing （ツールが取得を拒否）
- 第三者情報: 個人・教育・研究だけ。商用は不可。研究に AI の学習は含まれない。商用は有料の Pro Sound Effects へ誘導。
- 判定: **有料アプリには使えない**。

**Videvo** — https://www.videvo.net/royalty-free-sound-effects/ は https://www.freepik.com/audio/sound-effects に転送された（301）。Freepik の規約は未読。**未確認**。

**freesfx**（https://freesfx.co.uk/info/eula/）— 404。**未確認**。

### B.4 すでに調べた Mixkit と、再試行の結果

- Mixkit: ページに「Sound Effects Free License」と「View License」があるだけで、本文は読めなかった（https://mixkit.co/license/）。前の章のとおり**未確認**。

## C. 読めなかったもの（人が見る）

OtoLogic、効果音工房・音人・くらげ工匠、Artlist の PDF、Envato の各ヘルプ、Motion Array、Uppbeat、BBC、Pro Sound Effects、Boom Library の EULA、Pond5 の Digital Only、Videvo・Freepik、freesfx、Mixkit、Springin' の問い合わせフォーム。

## D. 見直したおすすめ（上の「おすすめ」を更新）

条件: よく使われている、使いやすい、有料アプリに入れても安全。

### 順位

| 順位 | 場所 | 役目 | 安全の根拠 | 残る不安 |
|---|---|---|---|---|
| 1（主） | **効果音ラボ** | ボタン・ほめる音・日常の音 | 「音源ファイルむき出しでも可」と明記。表記不要。YouTuber が一番よく使う | AI 学習の禁止は問題なし |
| 2（主） | **Springin' Sound Stock** | 動物・乗り物・生活・かわいい音 | 商用可、表記は必須でない。日本でよく使われる | **アプリ同梱は問い合わせが要る**。返事を保存する |
| 3（主） | **Kenney（CC0）** | UI の音 | パブリックドメイン | 動物・乗り物は無い |
| 4（主） | **小森平** | 動物・乗り物・日常 | アプリの使用を明記 | 表記の要不要を原文で確認 |
| 5（予備・無料） | **Sonniss GDC** | 実録音の物の音 | 表記不要、アプリ可 | 容量が大きい。AI 学習禁止 |
| 6（予備・無料） | **Freesound（CC0 のみ）／Pixabay** | 足りない音 | 上の章のとおり | 1ファイルずつ確認 |
| 7（予備・有料） | **Soundsnap Pro（1か月）** | 動物・乗り物の足りない分 | 「games and apps」が明記 | 解約後の権利をメールで確認。値段未確認 |
| 8（予備・有料） | **Pro Sound Effects の買い切り**、**Boom Library** | 高品質の個別の音 | 買い切りで永続 | ゲーム・アプリの明記が未確認 |
| 保留 | **OtoLogic** | 人が公式を読めたら第2群に入れる | — | 未確認。表記が前提なら使える可能性 |
| 使わない | YouTube オーディオライブラリ、Epidemic、Storyblocks、Envato、Artlist、Motion Array、Uppbeat、BBC、ニコニ・コモンズ | — | YouTube・動画向け。アプリ同梱が未確認または不可 | — |

**理由**: 有料サブスク（Epidemic など）は、解約後の権利と「アプリに同梱できるか」が読み取れない。無料の日本サイトは、アプリでの使用が明記されているものが多く、約100〜200個の需要にも足りる。まず無料で足りるか確かめ、足りない動物・乗り物だけ有料で補う。

### 持ち主がやること

1. **Springin' Sound Stock に問い合わせる**（日本語のフォーム https://www.springin.org/contact/ ）。「有料の子ども向け iPad アプリの中に、効果音を約N個、Opus に変換して入れたい。再生は書く練習の中だけで、ユーザーが自由に鳴らす機能はない。許可と費用を教えてほしい」。返事（メールの全文）を保存する。**Claude は送信しない**（メッセージ送信は持ち主の許可が要るため）。
2. **OtoLogic の公式ページ**を自分のブラウザで読み、表記の形を確かめる（Claude の取得は 403）。
3. **小森平** welcome.html を原文で読み、クレジットの要不要を確かめる。必要ならメールで聞く（komoritaira@gmail.com）。
4. 有料の予備を使うなら、**アカウント作成・支払い・規約への同意**（Soundsnap または Pro Sound Effects）。持ち主が行う。サブスクの場合は、解約後の権利について、メールで書面をもらう。
5. ダウンロード日に、規約ページの保存（スクリーンショットか PDF）を残す。

### Claude ができること

- 無料サイトの音の候補探し（音名・URL・長さの一覧にする）。ダウンロードは、持ち主の許可を得てから。
- 音量をそろえ、前後を切り、Opus に変換する作業。
- 出どころの記録（`sfx-provenance.csv`）の作成と、「このアプリについて」の文面。
- 問い合わせメールの下書き（送るのは持ち主）。
- 規約の再確認の一覧作り。

### 新しい出典

- YouTube オーディオライブラリ: https://support.google.com/youtube/answer/3376882
- Springin' Sound Stock: https://www.springin.org/sound-stock/ ／ https://www.springin.org/sound-stock/guideline/
- Storyblocks: https://www.storyblocks.com/license
- Soundsnap: https://www.soundsnap.com/licence
- Soundly: https://getsoundly.com/faq/can-i-use-the-sounds-in-a-video-game
- 99Sounds: https://www.99sounds.org/license/
- Pro Sound Effects: https://www.prosoundeffects.com/
- Boom Library: https://www.boomlibrary.com/?p=269603
- Artlist（第三者情報）: https://artlist.io/media/w5mglb2w/pro-license-current-02092024.pdf
- Envato（第三者情報）: https://help.elements.envato.com/hc/en-us/articles/360000621483
- Epidemic Sound: https://www.epidemicsound.com/
- Pond5: https://www.pond5.com/legal/license/20170301
- BBC（第三者情報）: https://sound-effects.bbcrewind.co.uk/licensing
