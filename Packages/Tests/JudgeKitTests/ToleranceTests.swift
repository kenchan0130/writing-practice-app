import ContentModel
import Foundation
import Testing

@testable import JudgeKit

/// 形のしきい値が、字の大きさに合っているか・子どものぶれと傾きに耐えるか（D192）。
@Suite("判定のしきい値（字の大きさ・ぶれ・傾き）")
struct ToleranceTests {
  static let hira = EndingAnalysisTests.pack("hira")
  static let kata = EndingAnalysisTests.pack("kata")
  static let abc = EndingAnalysisTests.pack("abc")

  static func model(_ data: CharacterData) -> [Polyline] {
    data.strokes.map { Geometry.polyline(of: $0) }
  }

  static func letter(_ char: String) throws -> CharacterData {
    try #require(abc.first { $0.char == char })
  }

  static func size(_ lines: [Polyline]) -> Double {
    guard let b = Geometry.bounds(of: lines) else { return 0 }
    return max(b.max.x - b.min.x, b.max.y - b.min.y)
  }

  /// 字全体を、外枠の中心のまわりに回す。
  static func rotated(_ lines: [Polyline], degrees: Double) -> [Polyline] {
    guard let b = Geometry.bounds(of: lines) else { return lines }
    let c = (b.min + b.max) * 0.5
    let r = degrees * .pi / 180
    return lines.map { line in
      line.map { p in
        let d = p - c
        return Point(c.x + d.x * cos(r) - d.y * sin(r), c.y + d.x * sin(r) + d.y * cos(r))
      }
    }
  }

  @Test("字の大きさに合わせた倍率: 大きい字は 1、小さい小文字は下限まで小さくなる")
  func sizeScale() throws {
    #expect(Judge.sizeScale(of: Self.model(try JudgeTests.character("き"))) == 1)
    let a = Judge.sizeScale(of: Self.model(try Self.letter("a")))
    #expect(a <= 0.7 && a >= Judge.minimumScale)
    #expect(Judge.sizeScale(of: Self.model(try Self.letter("o"))) == Judge.minimumScale)
    #expect(Judge.sizeScale(of: Self.model(try Self.letter("A"))) > 0.8)
  }

  @Test("まぎらわしい字（小さい字）は、お手本どおりに書いても はじめて で別の字にならない")
  func confusablePairsFail() throws {
    let pairs = [
      ("a", "o"), ("o", "a"), ("c", "a"), ("n", "o"), ("e", "m"), ("m", "w"), ("w", "m"),
      ("u", "v"), ("v", "u"), ("n", "h"), ("h", "n"), ("e", "v"), ("w", "e"), ("c", "o"),
      ("o", "c"), ("n", "m"), ("m", "n"), ("r", "n"), ("s", "z"), ("z", "s"),
    ]
    for (written, model) in pairs {
      let result = Judge(character: try Self.letter(model))
        .judge(written: Self.model(try Self.letter(written)), preset: .hajimete)
      #expect(!result.passed, "\(written) を \(model) として書いたことになる")
    }
  }

  @Test("ひとつの円は a・c・n・o の どれにもならない（o は円そのもの）")
  func circleOnlyPassesO() throws {
    let circle: Polyline = (0...48).map { i in
      let t = Double(i) / 48 * 2 * .pi
      return Point(500 + 160 * sin(t), 500 - 160 * cos(t))
    }
    for char in ["a", "c", "n", "m", "e", "v", "w", "u"] {
      let result = Judge(character: try Self.letter(char)).judge(
        written: [circle], preset: .hajimete)
      #expect(!result.passed, "\(char)")
    }
  }

  @Test("ジグザグの線は e・m・v・w にならない")
  func zigzagFails() throws {
    let zigzag: Polyline = [
      Point(300, 300), Point(380, 620), Point(460, 300), Point(540, 620), Point(620, 300),
      Point(700, 620),
    ]
    for char in ["e", "m", "v", "w", "n", "u"] {
      let result = Judge(character: try Self.letter(char)).judge(
        written: [zigzag], preset: .hajimete)
      #expect(!result.passed, "\(char)")
    }
  }

  /// 揺れ方を変えて4回、はじめて でどれだけ合格するか（`make judge-report` と同じ式）。
  static func passRate(
    _ characters: [CharacterData], amplitude: (CharacterData) -> Double, preset: JudgePreset
  ) -> (passed: Int, total: Int) {
    var passed = 0
    var total = 0
    for data in characters {
      let judge = Judge(character: data)
      for phase in 0..<4 {
        let lines = Judge.jittered(Self.model(data), amplitude: amplitude(data), phase: phase)
        total += 1
        if judge.judge(written: lines, preset: preset).passed { passed += 1 }
      }
    }
    return (passed, total)
  }

  @Test("子どもらしいぶれ（50）は、ひらがな・カタカナで、じぶんで はじめて でほとんど合格")
  func wobbleKana() {
    let hira = Self.passRate(Self.hira, amplitude: { _ in 50 }, preset: .hajimete)
    let kata = Self.passRate(Self.kata, amplitude: { _ in 50 }, preset: .hajimete)
    #expect(Double(hira.passed) / Double(hira.total) >= 0.93, "ひらがな \(hira)")
    #expect(Double(kata.passed) / Double(kata.total) >= 0.93, "カタカナ \(kata)")
  }

  @Test("アルファベットも、ぶれ（35）は はじめて で95%以上、ぶれ（50）は80%以上合格")
  func wobbleAbc() {
    let light = Self.passRate(Self.abc, amplitude: { _ in 35 }, preset: .hajimete)
    #expect(Double(light.passed) / Double(light.total) >= 0.95, "35: \(light)")
    let heavy = Self.passRate(Self.abc, amplitude: { _ in 50 }, preset: .hajimete)
    #expect(Double(heavy.passed) / Double(heavy.total) >= 0.8, "50: \(heavy)")
    let relative = Self.passRate(
      Self.abc, amplitude: { Self.size(Self.model($0)) * 0.06 }, preset: .hajimete)
    #expect(Double(relative.passed) / Double(relative.total) >= 0.95, "字の6%: \(relative)")
  }

  @Test("傾きを直す前に合格する線は、傾きを直す設定でも必ず合格（回して悪くなることがない）")
  func rotationNeverHurts() {
    for preset in [JudgePreset.hajimete, .naretekita] {
      var plain = JudgeConfig.preset(preset)
      plain.rotationTolerance = 0
      let tilted = JudgeConfig.preset(preset)
      for data in Self.hira + Self.kata + Self.abc {
        let judge = Judge(character: data)
        for amplitude in [20.0, 35, 50] {
          for phase in 0..<3 {
            let lines = Judge.jittered(Self.model(data), amplitude: amplitude, phase: phase)
            let aligned = Geometry.align(
              lines.map { Geometry.resample($0) },
              to: Self.model(data).map { Geometry.resample($0) })
            if judge.evaluate(aligned, config: plain).passed {
              #expect(
                judge.evaluate(aligned, config: tilted).passed,
                "\(data.char) \(preset) \(amplitude) \(phase)")
            }
          }
        }
      }
    }
  }

  @Test("閉じた画（o）は、開いたままの線では通らない")
  func endpointsMatter() throws {
    // 開いたままの線（始めと終わりが大きく離れる）は、閉じた画 o にならない。
    let o = try Self.letter("o")
    let open: Polyline = (0...40).map { i in
      let t = Double(i) / 40 * 1.45 * .pi
      return Point(500 + 160 * sin(t), 500 - 160 * cos(t))
    }
    #expect(!Judge(character: o).judge(written: [open], preset: .hajimete).passed)
  }

  @Test("なぞる は、お手本から 70 ずれても通る（ひらがな・カタカナ）")
  func traceOffset() {
    var passed = 0
    var total = 0
    for data in Self.hira + Self.kata {
      let judge = Judge(character: data)
      for (index, line) in Self.model(data).enumerated() {
        let shifted = line.map { Point($0.x + 70 * 0.7, $0.y + 70 * 0.7) }
        total += 1
        if judge.judgeStroke(shifted, expected: index, preset: .hajimete) == .ok { passed += 1 }
      }
    }
    #expect(Double(passed) / Double(total) >= 0.97, "\(passed)/\(total)")
  }

  @Test("字全体が10度かたむいても、じぶんで はじめて で合格（濁点の字も）")
  func tiltedAtHajimete() {
    var failed: [String] = []
    var total = 0
    for data in Self.hira + Self.kata + Self.abc {
      let judge = Judge(character: data)
      for angle in [-10.0, 10.0] {
        total += 1
        let result = judge.judge(
          written: Self.rotated(Self.model(data), degrees: angle), preset: .hajimete)
        if !result.passed { failed.append("\(data.char)@\(Int(angle))") }
      }
    }
    #expect(Double(failed.count) / Double(total) <= 0.02, "\(failed)")
    for char in ["ぜ", "ば", "ぼ", "ズ", "ポ"] {
      let data = (Self.hira + Self.kata).first { $0.char == char }!
      for angle in [-10.0, 10.0] {
        let result = Judge(character: data).judge(
          written: Self.rotated(Self.model(data), degrees: angle), preset: .hajimete)
        #expect(result.passed, "\(char)@\(Int(angle)): \(result.issues)")
      }
    }
  }

  @Test("「ー」と「ニ」は、少し傾いても鏡の字にならない")
  func longMarkNotMirrored() throws {
    for char in ["ー", "ニ"] {
      let data = try #require(Self.kata.first { $0.char == char })
      #expect(data.mirrorCheck == false, "\(char)")
      for angle in [-6.0, 6.0] {
        for preset in [JudgePreset.hajimete, .naretekita] {
          let result = Judge(character: data).judge(
            written: Self.rotated(Self.model(data), degrees: angle), preset: preset)
          #expect(!result.issues.contains(.mirrored), "\(char)@\(Int(angle)) \(preset)")
          #expect(result.passed, "\(char)@\(Int(angle)) \(preset): \(result.issues)")
        }
      }
    }
  }

  @Test("i・j の点は、1点のタップでも短い線でも、なぞる・うすく・じぶんで で通る")
  func dotsAcceptTaps() throws {
    for char in ["i", "j"] {
      let data = try Self.letter(char)
      let judge = Judge(character: data)
      let dot = try #require(Self.model(data).last?.first)
      #expect(judge.isDot(1), "\(char)")
      #expect(!judge.isDot(0), "\(char)")
      for preset in JudgePreset.allCases {
        #expect(
          judge.judgeStroke([dot], expected: 1, preset: preset) == .ok, "\(char) タップ \(preset)")
        let tick = [dot, Point(dot.x + 8, dot.y + 12)]
        #expect(
          judge.judgeStroke(tick, expected: 1, preset: preset) == .ok, "\(char) 短い線 \(preset)")
        let near = [Point(dot.x + 30, dot.y + 20)]
        #expect(judge.judgeStroke(near, expected: 1, preset: .hajimete) == .ok, "\(char) 近く")
        // 遠く離れた点は、点の位置ではない。
        #expect(
          judge.judgeStroke([Point(dot.x + 300, dot.y + 300)], expected: 1, preset: preset) != .ok)
        // 点でない画は、1点では通らない。
        #expect(judge.judgeStroke([dot], expected: 0, preset: preset) == .wrongStroke)
      }
      // じぶんで: 点をタップで打っても合格。
      var lines = Self.model(data)
      lines[1] = [dot]
      for preset in [JudgePreset.hajimete, .shikkari] {
        let result = judge.judge(written: lines, preset: preset)
        #expect(result.passed, "\(char) じぶんで \(preset): \(result.issues)")
      }
    }
  }

  @Test("濁点・半濁点は、短い線でも、なぞる・うすく で通る")
  func dakutenMarks() throws {
    for (char, marks) in [("ば", [3, 4]), ("ぱ", [3]), ("ざ", [3, 4])] {
      let data = try #require(Self.hira.first { $0.char == char })
      let judge = Judge(character: data)
      for index in marks {
        let line = Self.model(data)[index]
        #expect(
          judge.judgeStroke(line, expected: index, preset: .hajimete) == .ok, "\(char) \(index)")
        guard Geometry.length(of: line) < 250 else { continue }
        let half = Array(line[(line.count / 4)..<(line.count * 3 / 4)])
        let check = judge.judgeStroke(half, expected: index, preset: .hajimete)
        #expect(check == .ok, "\(char) \(index) 短い線: \(check)")
      }
    }
  }
}
