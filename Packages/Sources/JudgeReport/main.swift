import ContentModel
import Foundation
import JudgeKit

/// 判定の効き方を、わざと崩した線で確かめる（`make judge-report`。D79・D107）。
/// 正解の付いた子どもの線（D120）が集まるまでの目安。集まったら、その線のセットでも同じ表を出す。
///
/// 使い方: swift run --package-path Packages JudgeReport <パックのフォルダ>

struct Distortion {
  var name: String
  /// この崩し方を、どの設定まで合格にしたいか（nil はどの設定でも合格にしたくない）。
  var shouldPassUpTo: JudgePreset?
  /// どの設定から不合格にしたいか（nil は不合格にしたくない）。合格と不合格のあいだの設定は、どちらでもよい。
  var shouldFailFrom: JudgePreset?
  /// 1画の字には当てはまらない崩し方（字全体の位置合わせで吸収される）。
  var needsMultipleStrokes = false
  var apply: ([Polyline]) -> [Polyline]
}

func jitter(_ lines: [Polyline], amplitude: Double) -> [Polyline] {
  lines.enumerated().map { s, line in
    line.enumerated().map { i, p in
      Point(
        // 手書きのぶれに近い、ゆるやかな揺れ。
        p.x + amplitude * sin(Double(i) * 0.25 + Double(s) * 1.7),
        p.y + amplitude * cos(Double(i) * 0.31 + Double(s) * 2.3))
    }
  }
}

/// 長い画（いちばん長い画）だけを崩す。
func longestIndex(_ lines: [Polyline]) -> Int {
  lines.indices.max { length(lines[$0]) < length(lines[$1]) } ?? 0
}

func length(_ line: Polyline) -> Double {
  zip(line, line.dropFirst()).reduce(0) {
    let dx = $1.1.x - $1.0.x
    let dy = $1.1.y - $1.0.y
    return $0 + (dx * dx + dy * dy).squareRoot()
  }
}

let distortions: [Distortion] = [
  Distortion(name: "お手本どおり", shouldPassUpTo: .kicchiri, shouldFailFrom: nil) { $0 },
  Distortion(name: "小さなぶれ（15）", shouldPassUpTo: .kicchiri, shouldFailFrom: nil) {
    jitter($0, amplitude: 15)
  },
  Distortion(name: "ぶれ（35）", shouldPassUpTo: .shikkari, shouldFailFrom: nil) {
    jitter($0, amplitude: 35)
  },
  Distortion(name: "曲線を直線でつなぐ", shouldPassUpTo: nil, shouldFailFrom: .naretekita) { lines in
    // お手本の点を4つに1つだけ残して直線でつなぐ（丸みがつぶれる）。
    lines.map { line in
      line.enumerated().filter { $0.offset % 16 == 0 || $0.offset == line.count - 1 }.map(\.element)
    }
  },
  Distortion(name: "長い画を2本に分けて書く", shouldPassUpTo: .naretekita, shouldFailFrom: .shikkari) {
    lines in
    var out = lines
    let i = longestIndex(lines)
    let half = lines[i].count / 2
    out.replaceSubrange(i...i, with: [Array(lines[i][...half]), Array(lines[i][(half + 1)...])])
    return out
  },
  Distortion(
    name: "1画目と2画目をつなげて書く", shouldPassUpTo: .naretekita, shouldFailFrom: .shikkari,
    needsMultipleStrokes: true
  ) { lines in
    var out = lines
    out.replaceSubrange(0...1, with: [lines[0] + lines[1]])
    return out
  },
  Distortion(name: "長い画を半分で止める", shouldPassUpTo: nil, shouldFailFrom: .hajimete) { lines in
    var out = lines
    let i = longestIndex(lines)
    out[i] = Array(lines[i].prefix(max(2, lines[i].count / 2)))
    return out
  },
  Distortion(name: "長い画を大きくゆがめる", shouldPassUpTo: nil, shouldFailFrom: .hajimete) {
    lines in
    var out = lines
    let i = longestIndex(lines)
    out[i] = lines[i].enumerated().map { k, p in
      Point(p.x + 250 * sin(Double(k) / Double(max(lines[i].count - 1, 1)) * .pi), p.y)
    }
    return out
  },
  Distortion(
    name: "1画を大きくずらす（200）", shouldPassUpTo: nil, shouldFailFrom: .hajimete,
    needsMultipleStrokes: true
  ) {
    lines in
    var out = lines
    let i = longestIndex(lines)
    out[i] = lines[i].map { Point($0.x + 200, $0.y + 120) }
    return out
  },
]

let arguments = CommandLine.arguments
guard arguments.count > 1 else {
  print("使い方: JudgeReport <パックのフォルダ>")
  exit(2)
}
let directory = URL(fileURLWithPath: arguments[1])
let files = try FileManager.default.contentsOfDirectory(
  at: directory, includingPropertiesForKeys: nil
)
.filter { $0.pathExtension == "json" }
.sorted { $0.lastPathComponent < $1.lastPathComponent }
let characters = try files.map {
  try JSONDecoder().decode(CharacterData.self, from: Data(contentsOf: $0))
}

print("# 判定の効き方（わざと崩した線。\(characters.count) 字）\n")
print("合格した字の割合。◎は合格にしたい設定、×は不合格にしたい設定、－はどちらでもよい設定。\n")
let presets = JudgePreset.allCases
print("| 崩し方 | " + presets.map(\.rawValue).joined(separator: " | ") + " |")
print("|---|" + presets.map { _ in "---" }.joined(separator: "|") + "|")
var mistakes = 0
for distortion in distortions {
  var cells: [String] = []
  for (index, preset) in presets.enumerated() {
    var passed = 0
    let targets = characters.filter { character in
      if distortion.needsMultipleStrokes, character.strokes.count <= 1 { return false }
      // 不合格にしたい崩し方は、実際に形が大きく変わった字（いちばん離れた点が 60 以上）だけを数える。
      // もともと直線に近い字は、直線でつないでも形が変わらないため。
      guard distortion.shouldFailFrom != nil else { return true }
      let original = character.strokes.map { $0.centerlinePoints() }
      let distorted = distortion.apply(original)
      guard original.count == distorted.count else { return true }
      return zip(original, distorted).contains { Judge.deviation($0, $1) >= 60 }
    }
    for character in targets {
      let lines = distortion.apply(character.strokes.map { $0.centerlinePoints() })
      if Judge(character: character).judge(written: lines, preset: preset).passed { passed += 1 }
    }
    let rate = targets.isEmpty ? 0 : Double(passed) / Double(targets.count)
    let passWanted = distortion.shouldPassUpTo.map { index <= presets.firstIndex(of: $0)! } ?? false
    let failWanted = distortion.shouldFailFrom.map { index >= presets.firstIndex(of: $0)! } ?? false
    let mark: String
    if passWanted {
      mark = "◎"
      if rate < 0.9 { mistakes += 1 }
    } else if failWanted {
      mark = "×"
      if rate > 0.1 { mistakes += 1 }
    } else {
      mark = "－"
    }
    cells.append(String(format: "%@ %.0f%%", mark, rate * 100))
  }
  print("| \(distortion.name) | " + cells.joined(separator: " | ") + " |")
}
print("\nねらいから外れたマス: \(mistakes)（◎は90%以上、×は10%以下をねらう）")

if arguments.contains("--stats") {
  print("\n## 画の形の違い（字ごとのいちばん悪い画の、10%・50%・90% の位置）\n")
  for distortion in distortions {
    var means: [Double] = []
    var maxes: [Double] = []
    for character in characters
    where !distortion.needsMultipleStrokes || character.strokes.count > 1 {
      let lines = distortion.apply(character.strokes.map { $0.centerlinePoints() })
      let result = Judge(character: character).judge(written: lines, preset: .hajimete)
      if let worst = result.shapeDistances.max() { means.append(worst) }
      if let worst = result.maxDistances.max() { maxes.append(worst) }
    }
    means.sort()
    maxes.sort()
    func at(_ v: [Double], _ q: Double) -> Double {
      v.isEmpty ? .nan : v[Int(Double(v.count - 1) * q)]
    }
    print(
      String(
        format: "- %@: 平均 %.0f / %.0f / %.0f、いちばん離れた点 %.0f / %.0f / %.0f",
        distortion.name, at(means, 0.1), at(means, 0.5), at(means, 0.9), at(maxes, 0.1),
        at(maxes, 0.5), at(maxes, 0.9)))
  }
}
