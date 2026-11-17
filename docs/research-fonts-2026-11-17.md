# 表示用フォントの比べ（2026-11-17）

D59 は子どもが見るかなに Klee One を使うと決めている。ほかの候補と並べて見比べた。

## やり方

- フォントは google/fonts の `ofl/` から取った（raw.githubusercontent.com）。ライセンスは同じ場所の `METADATA.pb` と `OFL.txt` で確かめた。
- CoreText で登録し、同じ文を並べて PNG にした。
- 画像（作業用の置き場。リポジトリには入れていない）:
  - 文の見本: `/private/tmp/claude-501/-Users-tadayuki-ghq-github-com-kenchan0130-writing-practice-app/46204f94-9476-406f-a742-0fc4d65d2c15/scratchpad/fonts/out/compare-sample.png`
  - 「き さ ふ や ゆ そ り つ」の拡大: `/private/tmp/claude-501/-Users-tadayuki-ghq-github-com-kenchan0130-writing-practice-app/46204f94-9476-406f-a742-0fc4d65d2c15/scratchpad/fonts/out/compare-glyphs.png`
- 見たのは画像の目視だけ。字形の最終確認は M0 で、お手本（KanjiVG など）と重ねて行う。

## 候補の表

| フォント | 太さ | かわいさ | 4〜7歳の読みやすさ | 教科書の形との近さ | ファイル |
|---|---|---|---|---|---|
| Klee One | Regular / SemiBold | 高い。手書きのあたたかさ | 高い。SemiBold は小さい字でも線がはっきり | 高い。筆記のお手本に近く、線の終わりがはっきり | 8.7MB / 8.9MB |
| Zen Maru Gothic | Medium / Bold | 高い。丸くて太い | とても高い。UI の小さい字にも強い | 中から高。ゴシックの形で、ふだんの印刷の字に近い | 3.8MB / 3.8MB |
| M PLUS Rounded 1c | Medium / Bold | 中から高。まじめで丸い | 高い | 中から高。きれいだが線の終わりが丸く、止め・はねは見えにくい | 3.4MB / 3.5MB |
| Kiwi Maru | Medium | 高い。やわらかい明朝ふう | 中。線が細く、小さい字は弱い | 中から高。明朝の形でうろこ（かざり）が少ない | 5.1MB |
| Zen Kaku Gothic New | Medium | 低い（対照用） | 高い | 高い。くせが少ない | 2.3MB |
| BIZ UDPGothic | Regular | 低い | とても高い（UD） | 高い。くせが少ない | 4.7MB |
| BIZ UDPMincho | Regular | 低い | 高い | 高い。教科書体ではなく明朝 | 6.2MB |
| Yomogi | Regular | 高いが、くだけすぎ | 中。形が自由で、字の間もばらつく | 低い。線が崩れる（対照用） | 4.0MB |
| Zen Kurenaido | Regular | 中。クレヨンふう | 中。線が細い | 中。手書きふうで、ゆるい字がある | 4.3MB |
| Hiragino Sans（iPad 標準） | W4 / W6 | 低い | 高い | 高い | 入れなくてよい |

## 字ごとのメモ

- き・さ・ふ・や・ゆ・り・つ: 候補のほとんどは、画の分かれ方や終わりの形が教科書とそう違わない。Klee One は線の入りと終わりがはっきりしていて、いちばん「書いたとおり」に見える。
- そ: 上の部分がつながる形が多い。Klee One と Zen Kurenaido は手書きのつながり方。ゴシック系（Zen Maru・M+・Hiragino）は少しだけ印刷の形。どれも別の字に読み間違えることはない。教科書の手本と合わせるのは M0 で確かめる。
- Yomogi は「ね」「う」「き」が崩れ、子どもが形を覚える手本には向かない。
- Zen Kurenaido は線が細く、「う」「す」に手書きのくせがある。
- Zen Maru Gothic と M PLUS Rounded は、太くすると小さい字の中の細かい形（ふ・ゆ の内側）がつぶれやすい。Bold は看板向き。
- Kiwi Maru は字間が広めで、「！」「/」が小さく見える。
- 小さい UI の字（16pt 前後）: Klee One は細くて少し弱い。SemiBold なら読める。Zen Maru Gothic Medium が最も読みやすい。

## ライセンス

全部 SIL Open Font License 1.1（OFL）。アプリへの埋め込みと配布ができる。条件は、ライセンス文と著作権表示を付けることと、フォントそのものを単体で売らないこと。

| フォント | 著作権表示（OFL.txt） | 出典 |
|---|---|---|
| Klee One | The Klee Project Authors（Fontworks） | github.com/google/fonts/tree/main/ofl/kleeone |
| Zen Maru Gothic | The Zen Maru Gothic Project Authors | …/ofl/zenmarugothic |
| M PLUS Rounded 1c | M+ Fonts Project（森下浩司） | …/ofl/mplusrounded1c |
| Kiwi Maru | The Kiwi Maru Project Authors | …/ofl/kiwimaru |
| Zen Kaku Gothic New | The Zen Kaku Gothic Project Authors | …/ofl/zenkakugothicnew |
| BIZ UDPGothic / UDPMincho | The BIZ UDGothic / UDMincho Project Authors（モリサワ） | …/ofl/bizudpgothic, …/ofl/bizudpmincho |
| Yomogi | The Yomogi Project Authors | …/ofl/yomogi |
| Zen Kurenaido | The Zen Kurenaido Project Authors | …/ofl/zenkurenaido |

- Klee One の OFL.txt は、著作権表示の行に Reserved Font Name（予約名）を書いていない。ほかの候補も確認したが、使う前にもう一度 OFL.txt を読むこと（D59 にも同じ注意がある）。

## サイズと軽くする方法

- 日本語フォントは 1 つ 2〜9MB。Klee One は 2 つの太さで約 17.6MB と大きい。
- アプリで使う字は決まっている（ひらがな・カタカナ・ことばの字・数字・記号）。字を絞る（サブセット化。`pyftsubset` など）と、数百KB 程度まで小さくできる。
- 字を絞るのは OFL で許される。ただし予約名があれば名前を変える必要がある。
- 保護者の画面や自由な文字には使わず、iPad 標準を使えば、全部入りの大きなファイルは要らない。

## おすすめ

1. 子どもが見るかな（お手本、字幕、絵カード、地図、看板）: **Klee One**（Regular ＋ SemiBold）。D59 のまま。教科書の形に最も近く、手書きらしさがあり、かわいさも十分。字を絞って軽くする。
2. 小さい UI ラベル・ボタンの字（「つぎの ことば」「まちを みる」など）: **Zen Maru Gothic Medium**（見出しは Bold）。丸くて親しみやすく、小さくても読みやすい。形のくせも少ない。
3. 保護者の画面: iPad 標準（D59 のまま）。
4. 使わない: Yomogi（崩れすぎ）、Zen Kurenaido（細い・くせ）、Kiwi Maru（細く小さい字に弱い）。M PLUS Rounded は Zen Maru Gothic と役割が同じで、止め・はねが見えにくいので採らない。BIZ UD 系と Zen Kaku は「かわいさ」が足りない。

### トレードオフ

- 1 つだけにするなら Klee One。ただし小さい字で弱く、サイズも最大。
- 2 つ使うと、読みやすさとかわいさがそろうが、ライセンス表示とファイルが増える（字を絞れば数MB で収まる）。
- どちらも字形の最終確認は M0 で行う（き・さ・そ・ふ・り）。
