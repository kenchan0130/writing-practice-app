import SwiftUI

/// ステッカーの絵と名前（§3.3・D54）。絵は `Scripts/art/stickers.py`、名前の一覧は `TreatBox.stickers`。
enum StickerArt {
  /// 押せる部分の、いちばん小さい大きさ（2cm 角。D101）。
  static let minimumTarget: CGFloat = 104

  static func assetName(_ sticker: String) -> String { "sticker-\(sticker)" }

  /// 読み上げ用の名前（VoiceOver）。
  static func name(_ sticker: String) -> String {
    switch sticker {
    case "hoshi": "ほし"
    case "heart": "ハート"
    case "hana": "はな"
    case "niji": "にじ"
    case "kumo": "くも"
    case "taiyou": "たいよう"
    case "tsuki": "つき"
    case "onpu": "おんぷ"
    case "ribbon": "リボン"
    case "oukan": "おうかん"
    case "cake": "ケーキ"
    case "ice": "アイス"
    case "ame": "あめ"
    case "donut": "ドーナツ"
    case "ringo": "りんご"
    case "ichigo": "いちご"
    case "sakuranbo": "さくらんぼ"
    case "kinoko": "きのこ"
    case "clover": "クローバー"
    case "rocket": "ロケット"
    case "fuusen": "ふうせん"
    case "present": "プレゼント"
    case "enpitsu": "えんぴつ"
    case "hanamaru": "はなまる"
    default: ""
    }
  }

  /// 1枚ずつ決まった、少しの かたむき（ラジアン。-0.14〜0.14）。手で貼ったように見せる。
  static func tilt(of id: UUID) -> CGFloat {
    let bytes = withUnsafeBytes(of: id.uuid) { Array($0) }
    let value = bytes.reduce(0) { ($0 &* 31 &+ Int($1)) % 1000 }
    return (CGFloat(value) / 999 - 0.5) * 0.28
  }
}
