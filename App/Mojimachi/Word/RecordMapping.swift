import JudgeKit
import RecordKit

/// 判定の結果を、学習記録の形に直す（§3.8）。
enum RecordMapping {
  static func reason(_ issue: JudgeIssue) -> CharacterRecord.Reason {
    switch issue {
    case .strokeCount: .strokeCount
    case .order: .order
    case .direction: .direction
    case .mirrored: .mirrored
    case .shape, .deviation: .shape
    }
  }

  /// 書いた線を、記録に残す形にする（整数のマス目に丸めて小さくする。D44）。
  static func strokes(_ lines: [Polyline]) -> [[[Double]]]? {
    guard !lines.isEmpty else { return nil }
    return lines.map { line in line.map { [$0.x.rounded(), $0.y.rounded()] } }
  }

  /// 保護者に見せる理由のことば。
  static func label(_ reason: CharacterRecord.Reason) -> String {
    switch reason {
    case .strokeCount: "画数"
    case .order: "書き順"
    case .direction: "画の向き"
    case .mirrored: "左右の向き"
    case .shape: "形"
    case .ending: "とめ・はね・はらい"
    }
  }
}
