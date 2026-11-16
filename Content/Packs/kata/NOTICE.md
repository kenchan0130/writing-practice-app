# カタカナのデータの出どころ（D128・D144）

- 元のデータ: [strokesvg](https://github.com/zhengkyl/strokesvg)（コミット `e4c2c91034e03c9c2f4e95f14f2361a948f52cd0`）の `dist/katakana`（81字。長音「ー」と「ヴ」を含む）。
- strokesvg のかなの SVG は、Klee One（Copyright 2020 The Klee Project Authors。SIL Open Font License 1.1）から作られている。それ以外は MIT License。全文は同じフォルダの `LICENSE`。strokesvg は「ク・グ・ム・ル・レ」の形を Klee One から少し直している。
- `Scripts/import_strokesvg.py <dist/katakana> Content/Packs/kata <コミット> kata` で、中心線と輪郭をマス 0〜1000 の3次ベジェに直した（円弧も3次ベジェにした）。
- 画数は、教科書の画数と照らして82字すべてが一致することを、テスト（`ContentModelTests`）で確かめている。
- 書き順・画数・画の向きを KanjiVG と自動で照らし合わせ、82字すべてが一致した（`kanjivg-check.md`）。
- 小さい「ッ」は strokesvg にないので、`Scripts/make_small_kana.py` で「ツ」を縮めて作った（strokesvg の小さい字と同じ、0.75 倍で下にそろえる置き方）。
- 終わり方（とめ・はね・はらい）は、まだ空（D145 のヒントに使う）。
