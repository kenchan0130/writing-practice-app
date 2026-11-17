#if DEBUG
  import Foundation
  import RecordKit

  /// 確かめ用の学習記録（`-openRecords YES`）。お手本の線を少しずらして、書いた線の代わりにする。
  enum DebugSeed {
    /// きょうの字を `count` 字と、きのうの1字を足す（ホームの確かめ用。`-seedRecords N`）。
    static func today(count: Int) {
      let store = ProgressStore.shared
      let now = Date()
      let chars = Array("あいうえおかきくけこ")
      for (i, char) in chars.prefix(count).enumerated() {
        store.record(
          CharacterRecord(
            date: now.addingTimeInterval(Double(i)),
            characterID: "hira.\(String(char.unicodeScalars.first!.value, radix: 16))",
            stage: .nazoru, passed: true))
      }
      store.record(
        CharacterRecord(
          date: now.addingTimeInterval(-86_400), characterID: "hira.3055", stage: .nazoru,
          passed: true))
    }

    /// 育ちの確かめ用（`-seedGrowth YES`）。あ行・か行は「はな」、さ行は「つぼみ」、た行は「め」。
    static func growth() {
      let store = ProgressStore.shared
      guard store.log.characters.isEmpty else { return }
      let now = Date()
      func id(_ char: Character) -> String {
        "hira.\(String(char.unicodeScalars.first!.value, radix: 16))"
      }
      for char in "あいうえおかきくけこ" {
        store.record(
          CharacterRecord(date: now, characterID: id(char), stage: .jibunde, passed: true))
      }
      for char in "さしすせそ" {
        store.record(
          CharacterRecord(date: now, characterID: id(char), stage: .nazoru, passed: true))
      }
      for char in "たちつてと" {
        store.record(
          CharacterRecord(date: now, characterID: id(char), stage: .nazoru, passed: false))
      }
    }

    static func records() {
      let store = ProgressStore.shared
      guard store.log.characters.isEmpty else { return }
      let now = Date()
      func lines(_ char: Character, wobble: Double) -> [[[Double]]]? {
        PackLibrary.hiragana(char)?.strokes.enumerated().map { s, stroke in
          stroke.centerlinePoints().enumerated().map { i, p in
            [p.x + wobble * sin(Double(i) * 0.7 + Double(s)), p.y + wobble * cos(Double(i) * 0.5)]
          }
        }
      }
      func id(_ char: Character) -> String {
        "hira.\(String(char.unicodeScalars.first!.value, radix: 16))"
      }
      for (offset, char) in "そりくるまふねてんし".enumerated() {
        let day = now.addingTimeInterval(Double(offset - 10) * 86_400)
        store.record(
          CharacterRecord(
            date: day, characterID: id(char), stage: .nazoru, passed: true,
            strokes: lines(char, wobble: 30)))
        if offset % 2 == 0 {
          store.record(
            CharacterRecord(
              date: day.addingTimeInterval(3_600), characterID: id(char), stage: .jibunde,
              passed: true, strokes: lines(char, wobble: 8)))
        }
      }
      for hour in 0..<3 {
        store.record(
          CharacterRecord(
            date: now.addingTimeInterval(Double(hour - 3) * 3_600), characterID: id("き"),
            stage: .jibunde, passed: false, reasons: hour == 2 ? [.mirrored] : [.order],
            strokes: lines("き", wobble: 20)))
      }
      store.record(WordRecord(date: now, word: "くるま"))
    }
  }
#endif
