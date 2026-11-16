# ひらがなのデータの出どころ（D127・D128）

- 元のデータ: [strokesvg](https://github.com/zhengkyl/strokesvg)（コミット `e4c2c91034e03c9c2f4e95f14f2361a948f52cd0`）の `dist/hiragana`。
- strokesvg のかなの SVG は、Klee One（Copyright 2020 The Klee Project Authors。SIL Open Font License 1.1）から作られている。それ以外は MIT License。全文は同じフォルダの `LICENSE`。
- `Scripts/import_strokesvg.py` で、各画の中心線と輪郭（Klee One の形）を、マス 0〜1000 の3次ベジェに直した（輪郭の円弧も3次ベジェにした）。
- 画数は、小学校の教科書の画数と照らして79字すべてが一致することを、テスト（`ContentModelTests`）で確かめている。
- 書き順・画数・画の向きを KanjiVG と自動で照らし合わせ、79字すべてが一致した（`kanjivg-check.md`。D144）。
- 小さい「っ」は strokesvg にないので、あとで作る。
- 終わり方（とめ・はね・はらい）は strokesvg にないので、まだ空。
- アプリの「このアプリについて」に、strokesvg（MIT）と Klee One（OFL の全文と著作権の表示）を載せる。
