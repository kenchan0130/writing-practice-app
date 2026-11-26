import ContentModel
import Foundation
import PracticeKit

/// しりとりのことばの調べを表にする（`make shiritori-report`。D70）。
/// 字ごとに、始まることばの数と、キャラクターが続けられない行き止まりの字を出し、
/// 子どもがでたらめに選ぶしりとりを何千回も自動で遊んだ結果も出す。
let pool = ShiritoriPool(texts: WordCatalog.all.map(\.text))
let rows = ShiritoriAnalysis.rows(for: pool)

print("しりとりの字の表（ことば \(pool.words.count) 語）")
print("字 | 始まる | 使える | 終わる | 行き止まり")
for row in rows {
  print(
    "\(row.kana) | \(row.startCount) | \(row.usableStartCount) | \(row.endCount) | \(row.isDeadEnd ? "x" : "")"
  )
}

let deadEnds = ShiritoriAnalysis.deadEnds(for: pool)
print("")
print("行き止まりの字（ことばの終わりに出てくるもの）: \(deadEnds.map(String.init).joined(separator: " "))")
let thin = rows.filter { $0.usableStartCount < 3 && $0.kana != "ん" }.map { String($0.kana) }
print("使えることばが3語に満たない字: \(thin.joined(separator: " "))")

let simulation = ShiritoriAnalysis.simulate(pool: pool, rounds: 5000, seed: 1)
print("")
print("自動で \(simulation.rounds) 回遊んだ結果（子どもは候補からでたらめに選ぶ）")
print("5語まで続いた: \(simulation.finished) 回、まいった: \(simulation.gaveUp) 回")
print(
  "子どもが書いたことばは平均 \(String(format: "%.2f", Double(simulation.childWords) / Double(simulation.rounds))) 語"
)
