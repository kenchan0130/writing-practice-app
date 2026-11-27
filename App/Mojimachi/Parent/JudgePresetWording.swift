import JudgeKit

/// 判定のおまかせ設定の名前と説明（D22・D84）。保護者用の画面と、はじめての流れで同じものを使う。
extension JudgePreset {
  var title: String {
    switch self {
    case .hajimete: String(localized: "はじめて", comment: "判定の段階")
    case .naretekita: String(localized: "なれてきた", comment: "判定の段階")
    case .shikkari: String(localized: "しっかり", comment: "判定の段階")
    case .kicchiri: String(localized: "きっちり", comment: "判定の段階")
    }
  }

  var detail: String {
    switch self {
    case .hajimete: String(localized: "いちばんやさしい判定です。線を分けて書いても、つなげて書いても、形が合えば合格にします。")
    case .naretekita: String(localized: "少し形をよく見ます。線を分けたり、つなげたりしても合格にします。")
    case .shikkari: String(localized: "形をしっかり見ます。線を分けたり、つなげたりすると、画数の違いにします。")
    case .kicchiri: String(localized: "いちばん厳しい判定です。形を細かく見て、画数の違いも合格にしません。")
    }
  }
}
