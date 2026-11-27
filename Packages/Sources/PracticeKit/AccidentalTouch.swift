import ContentModel
import Foundation
import JudgeKit

/// 書いたつもりのない、ごく短い接触（ちょんと触れた・手が当たった）を、1画として数えない決まり（D191）。
/// 濁点・半濁点、i と j の点のような、本当に短い画は残す。座標はマス 0〜1000。
public struct AccidentalTouch: Sendable, Equatable {
  /// これより短い線で、しかも短い時間で終わった接触は、画として数えない。0 なら何も捨てない。
  public var minLength: Double
  /// 捨てるのは、この秒数より短い接触だけ（ゆっくり動かした線は書いた線として扱う）。
  public var maxDuration: Double
  /// この近く（マス 0〜1000）から始まった接触は、短くても捨てない。いまの画や、濁点などの短い画の書き始め。
  public var protectedStarts: [Point]

  public init(minLength: Double, maxDuration: Double = 0.4, protectedStarts: [Point] = []) {
    self.minLength = minLength
    self.maxDuration = maxDuration
    self.protectedStarts = protectedStarts
  }

  /// 守る場所の半径（マス 0〜1000）。
  static let protectRadius = 90.0
  /// これより短いお手本の画（濁点・半濁点など）は、じぶんで でも書き始めを守る。
  static let shortStrokeLength = 600.0

  /// 何も捨てない。
  public static let none = AccidentalTouch(minLength: 0)

  /// お手本のいちばん短い画の長さが、これより短い字（i・j の点）は、点をちょんと打つので、何も捨てない。
  static let dotLikeLength = 40.0
  /// お手本のいちばん短い画の、この割合より短い接触を捨てる。
  static let ratio = 0.12
  static let lowerLimit = 12.0
  static let upperLimit = 30.0

  /// その字に合う決まり。いちばん短いお手本の画に合わせる（濁点などの短い画は、これより十分に長い）。
  /// - Parameter expectedStroke: ②③で、次に書く画の番号。④（nil）では、短い画の書き始めを守る。
  public init(character: CharacterData, expectedStroke: Int? = nil) {
    self.init(shortestModelLength: Self.shortestModelLength(of: character))
    guard minLength > 0 else { return }
    if let expectedStroke {
      protectedStarts =
        character.strokes.indices.contains(expectedStroke)
        ? character.strokes[expectedStroke].centerlinePoints(stepsPerSegment: 1).prefix(1).map {
          $0
        }
        : []
    } else {
      let lines = character.strokes.map { $0.centerlinePoints(stepsPerSegment: 4) }
      let longest = lines.map(Self.length(of:)).max() ?? 0
      protectedStarts = lines.compactMap { line in
        let length = Self.length(of: line)
        return length < Self.shortStrokeLength && length < longest * 0.5 ? line.first : nil
      }
    }
  }

  static func length(of line: Polyline) -> Double {
    zip(line, line.dropFirst()).reduce(0.0) { total, pair in
      let dx = pair.1.x - pair.0.x
      let dy = pair.1.y - pair.0.y
      return total + (dx * dx + dy * dy).squareRoot()
    }
  }

  public init(shortestModelLength: Double) {
    if shortestModelLength < Self.dotLikeLength {
      self = .none
    } else {
      self.init(
        minLength: min(max(shortestModelLength * Self.ratio, Self.lowerLimit), Self.upperLimit))
    }
  }

  /// お手本のいちばん短い画の長さ。
  public static func shortestModelLength(of character: CharacterData) -> Double {
    character.strokes.map { length(of: $0.centerlinePoints(stepsPerSegment: 4)) }.min() ?? 0
  }

  /// 画として数えない接触か。`length` は線の長さ（マス 0〜1000）、`duration` は触れていた秒数。
  public func isAccidental(length: Double, duration: Double) -> Bool {
    minLength > 0 && length < minLength && duration < maxDuration
  }

  /// 点の並びと時刻から見る。
  public func isAccidental(line: Polyline, times: [Double]) -> Bool {
    if let first = line.first,
      protectedStarts.contains(where: {
        hypot($0.x - first.x, $0.y - first.y) <= Self.protectRadius
      })
    {
      return false
    }
    let length = Self.length(of: line)
    let duration = (times.last ?? 0) - (times.first ?? 0)
    return isAccidental(length: length, duration: duration)
  }
}
