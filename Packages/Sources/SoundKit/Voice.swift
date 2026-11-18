import Foundation

/// 声で言う文のうち、文字で決まっているもの（D162）。画面の文字が変わらないので、ここにまとめる。
/// 字のデータから作る読み（1字・ことば）は、`VoiceManifest` が文字から探す。
public enum VoiceLine: String, CaseIterable, Sendable {
  case onboardingWho
  case onboardingLike
  case onboardingDone
  case onboardingHello
  /// 鍵のかかった字を触ったとき。
  case locked
  /// 鍵の画面で「おねがい」を押したあと。
  case lockThanks

  public var text: String {
    switch self {
    case .onboardingWho: "だれと いっしょに かく？"
    case .onboardingLike: "なにが すき？"
    case .onboardingDone: "できたね！ まちに きたよ"
    case .onboardingHello: "こんにちは！ いっしょに かこうね"
    case .locked: "この もじで あそびたいときは、おとなのひとに おねがいしてね"
    case .lockThanks: "おねがい できたよ"
    }
  }
}

/// 声の文字から、声のファイル名（拡張子なし）を引く表（D162）。表は `Scripts/make_voices.py` が書く `voices.json`。
public struct VoiceManifest: Sendable, Equatable {
  /// 声を作ったエンジンの版。
  public let engine: String
  public let files: [String: String]

  public init(engine: String, files: [String: String]) {
    self.engine = engine
    self.files = files
  }

  private struct Payload: Decodable {
    let engine: String
    let files: [String: String]
  }

  public init(json: Data) throws {
    let payload = try JSONDecoder().decode(Payload.self, from: json)
    self.init(engine: payload.engine, files: payload.files)
  }

  /// 文字をそろえる: 前後の空白を除き、続く空白を1つにし、合成文字（が など）をひとつの形にする。
  public static func normalize(_ text: String) -> String {
    text.precomposedStringWithCanonicalMapping
      .split(whereSeparator: { $0.isWhitespace })
      .joined(separator: " ")
  }

  /// 文字の声のファイル名。なければ nil。
  public func fileName(for text: String) -> String? {
    files[Self.normalize(text)]
  }
}
