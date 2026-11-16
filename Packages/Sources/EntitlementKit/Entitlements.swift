import Foundation

/// 課金の権利の決まり（D89・D91・D94・D95・D96・§5.2）。StoreKit に頼らない部品。
/// 購入の記録（Apple の購入記録から作る）を受け取り、使える文字と、購入画面に出す商品を決める。

/// 文字の種類（パック）。ひらがなはいつも無料。
public enum Script: String, Sendable, Hashable, Codable, CaseIterable {
  case hiragana
  case katakana
  /// アルファベットと数字（ABC・すうじ パック）。
  case abc

  /// 有料のパック（ひらがな以外）。
  public static let paid: [Script] = [.katakana, .abc]
}

/// 商品（M1。D91）。
public enum ProductID: String, Sendable, Hashable, Codable, CaseIterable {
  case katakanaPack = "io.github.kenchan0130.mojimachi.pack.katakana"
  case abcPack = "io.github.kenchan0130.mojimachi.pack.abc"
  /// ぜんぶ ひらく（これからの もじも）。
  case allOpen = "io.github.kenchan0130.mojimachi.all"
  /// ぜんぶ ひらく（パックを 1つ もっている ひと）。
  case allOpenForOneOwner = "io.github.kenchan0130.mojimachi.all.owner1"

  /// パックの商品が開く文字。「ぜんぶ」は nil。
  public var script: Script? {
    switch self {
    case .katakanaPack: .katakana
    case .abcPack: .abc
    case .allOpen, .allOpenForOneOwner: nil
    }
  }

  public var isAllOpen: Bool { script == nil }

  /// 円（D91 の M1 の価格。表示は StoreKit の価格を使い、これは確かめ用）。
  public var yen: Int {
    switch self {
    case .katakanaPack, .abcPack, .allOpenForOneOwner: 250
    case .allOpen: 500
    }
  }
}

/// 購入の記録1つ。
public struct Purchase: Sendable, Hashable {
  public var product: ProductID
  /// Apple の購入記録の最初の購入日（D96）。
  public var originalPurchaseDate: Date
  /// 返金などで取り消されたか。
  public var revoked: Bool

  public init(product: ProductID, originalPurchaseDate: Date, revoked: Bool = false) {
    self.product = product
    self.originalPurchaseDate = originalPurchaseDate
    self.revoked = revoked
  }
}

/// 権利。
public struct Entitlements: Sendable, Hashable {
  /// M3 の値上げの日（D96）。まだ決まっていなければ nil（値上げ前として扱う）。
  public var priceRiseDate: Date?
  public private(set) var purchases: [Purchase]

  public init(purchases: [Purchase], priceRiseDate: Date? = nil) {
    self.purchases = purchases
    self.priceRiseDate = priceRiseDate
  }

  /// 取り消されていない購入。
  private var active: [Purchase] { purchases.filter { !$0.revoked } }

  /// 持っているパック（取り消されていないもの）。
  public var ownedPacks: Set<Script> { Set(active.compactMap(\.product.script)) }

  /// 全部開いているか（D89・D96）:
  /// 「ぜんぶ」を持っている（どの段でも。パックの返金後もそのまま使える）、
  /// または値上げ前に2つのパックを両方買っていた。
  public var allOpen: Bool {
    if active.contains(where: \.product.isAllOpen) { return true }
    let beforeRise = active.filter { purchase in
      guard purchase.product.script != nil else { return false }
      guard let rise = priceRiseDate else { return true }
      return purchase.originalPurchaseDate < rise
    }
    return Set(beforeRise.compactMap(\.product.script)).isSuperset(of: Script.paid)
  }

  /// 文字の種類が全部使えるか。
  public func isUnlocked(_ script: Script) -> Bool {
    script == .hiragana || allOpen || ownedPacks.contains(script)
  }

  /// 字が書けるか。鍵がかかっていても、おためしの字とおためしのことばの中は書ける（D90・D94）。
  public func canWrite(_ char: Character, in script: Script, insideTrialWord: Bool = false) -> Bool
  {
    isUnlocked(script) || insideTrialWord || Trial.characters(for: script).contains(char)
  }

  /// 使えるものの数（購入画面に出す。D95）。
  public var unlockedScriptCount: Int {
    Script.allCases.filter(isUnlocked).count
  }

  /// 購入画面に出す商品（D95。M1）。上から順に並べる。
  public var offers: [ProductID] {
    if allOpen { return [] }
    switch ownedPacks.count {
    case 0: return [.allOpen, .katakanaPack, .abcPack]
    default: return [.allOpenForOneOwner]
    }
  }
}

/// おためし（D90・D94）。公開後は減らさない（増やすのはよい）。
public enum Trial {
  /// おためしの字（固定の一覧。見せる順）。
  public static func characters(for script: Script) -> [Character] {
    switch script {
    case .hiragana: []
    case .katakana: ["ニ", "ト", "ロ", "コ", "ハ"]
    case .abc: ["L", "T", "I", "E", "F", "1", "7", "4"]
    }
  }

  /// おためしのことば（文字ごとに1語。変身まで体験できる）。
  public static func word(for script: Script) -> String? {
    switch script {
    case .hiragana: nil
    case .katakana: "バス"
    case .abc: "cat"
    }
  }
}
