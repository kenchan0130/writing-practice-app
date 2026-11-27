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
  /// しりとりを始めるとき（キャラクター。D57）。
  case shiritoriStart
  /// キャラクターがことばを出すとき。続けて案内役がことばを読む（D57）。
  case shiritoriKore
  /// 子どもの番になったとき。
  case shiritoriYourTurn
  /// キャラクターが続けられなかったとき（子どもの勝ち。D70）。
  case shiritoriGiveUp
  /// 子どもが勝ったとき。
  case shiritoriWin
  /// 1回が終わったとき（D70）。
  case shiritoriEnd
  /// ホームで、きょうのことばを見せるとき（D35）。
  case todayWord
  /// ずかんで、まだ書いていないことば（影絵）を触ったとき（D181）。
  case zukanHint
  /// もじから さがすで「ん」「を」を押したとき（D45・D181）。
  case noWordsN
  case noWordsWo
  /// おたのしみ ボックスが あけられるようになったとき（§3.3・§3.5）。
  case treatBoxReady
  /// まだ あけられない おたのしみ ボックスを押したとき。
  case treatBoxNotYet
  /// おたのしみ ボックスを あける画面を開いたとき。
  case treatBoxOpen
  /// ステッカーが出たとき。
  case treatBoxGot
  /// きょうは もう あけた おたのしみ ボックスを押したとき（ステッカーの使い方）。
  case stickerHint
  /// 夜に まちを開いたとき（主人公が眠そうにする。§3.5）。
  case townSleepy

  public var text: String {
    switch self {
    case .onboardingWho: "だれと いっしょに かく？"
    case .onboardingLike: "なにが すき？"
    case .onboardingDone: "できたね！ まちに きたよ"
    case .onboardingHello: "こんにちは！ いっしょに かこうね"
    case .locked: "この もじで あそびたいときは、おとなのひとに おねがいしてね"
    case .lockThanks: "おねがい できたよ"
    case .shiritoriStart: "しりとり しよう！"
    case .shiritoriKore: "これ！"
    case .shiritoriYourTurn: "つぎは どれに する？"
    case .shiritoriGiveUp: "うーん……まいった！"
    case .shiritoriWin: "すごい！ かったね！"
    case .shiritoriEnd: "きょうは ここまで！ たのしかったね"
    case .todayWord: "きょうの ことばは これ！"
    case .zukanHint: "かいて みよう"
    case .noWordsN: "『ん』から はじまる ことばは ないんだ"
    case .noWordsWo: "『を』は ことばの はじめには つかわないんだ"
    case .treatBoxReady: "おたのしみ ボックスが あけられるよ！"
    case .treatBoxNotYet: "きょうの もくひょうの ほしを ぜんぶ ひからせると、あけられるよ"
    case .treatBoxOpen: "なにが でるかな？"
    case .treatBoxGot: "やったね！ ステッカーが でたよ！"
    case .stickerHint: "ステッカーは、まちや ずかんに はれるよ"
    case .townSleepy: "ふわあ…… ねむく なってきたね"
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
