import Foundation

/// 同期まわりの小さな計算（D194）。画面や Core Data に頼らない。

/// 保存の「作った人」の名前。自分の保存か、iCloud から届いた変更かを見分ける（D194）。
public enum HistoryAuthor {
  /// このアプリが自分で保存した変更の印。
  public static let app = "mojimachi.app"

  /// 自分の行を変えない、同期の仕組みの書き出しの印。見ても読み直しは要らない。
  public static let exportPrefix = "NSCloudKitMirroringDelegate.export"

  /// 変更の作った人の中に、自分以外（iCloud から届いたもの）があるか。
  /// 自分の保存と、iCloud への書き出しの印だけなら、画面を読み直さなくてよい。
  public static func hasRemote(authors: [String?]) -> Bool {
    authors.contains { author in
      guard let author else { return true }
      return author != app && !author.hasPrefix(exportPrefix)
    }
  }
}

/// 読み直しの依頼を1つにまとめる（デバウンス）。短い間にたくさん届いても、読み直しは1回にする。
public struct ReloadCoalescer: Sendable, Equatable {
  /// まとめる間の時間（秒）。
  public var interval: TimeInterval
  private var pending = false

  public init(interval: TimeInterval = 0.5) {
    self.interval = interval
  }

  /// 読み直しの依頼が来た。タイマーを始めるべきなら true（すでに待っているなら false）。
  public mutating func request() -> Bool {
    guard !pending else { return false }
    pending = true
    return true
  }

  /// タイマーが切れた。読み直すべきなら true。
  public mutating func fire() -> Bool {
    guard pending else { return false }
    pending = false
    return true
  }

  /// 待っている依頼があるか。
  public var isPending: Bool { pending }
}

/// iCloud のアカウントが変わったかを見分ける（D194）。
/// サインアウトやアカウントの切り替えのとき、システムは端末の中の同期の行を消すことがある。
/// 次の起動で子どもが0人に見えても、黙って新しく始めないで、保護者に知らせる。
public enum ICloudAccountWatch {
  public enum Outcome: Sendable, Equatable {
    /// 変わっていない（または、まだ分からない）。
    case none
    /// 前のアカウントとは別のアカウントになった。
    case changed
    /// 前はサインインしていたが、いまはしていない。
    case signedOut
  }

  /// - Parameters:
  ///   - previous: 前に覚えたアカウントの印（なければ nil）。
  ///   - current: いまのアカウントの印（サインインしていなければ nil）。
  ///   - accountKnown: いまのアカウントの状態が確かめられたか（確かめられないときは何もしない）。
  public static func evaluate(previous: String?, current: String?, accountKnown: Bool) -> Outcome {
    guard accountKnown, let previous else { return .none }
    guard let current else { return .signedOut }
    return previous == current ? .none : .changed
  }

  /// 起動のとき、記録が空なのに、前は子どもがいた（データが消えたかもしれない）。
  public static func lostLocalData(hadProfilesBefore: Bool, loadedProfileCount: Int) -> Bool {
    hadProfilesBefore && loadedProfileCount == 0
  }
}

/// 最初の子（まだ保存していない仮の子）を、iCloud から届いた本物の子に入れ替える（D194）。
public enum ProfileAdoption {
  public struct Result: Sendable, Equatable {
    /// 使う子。
    public var currentID: UUID
    /// 仮の子を捨てるか。
    public var dropPlaceholder: Bool
  }

  /// - Parameters:
  ///   - placeholder: まだ何も操作されていない仮の子の ID（なければ nil）。
  ///   - current: いま使っている子。
  ///   - loaded: 保存先から読んだ子たち。
  ///   - preferred: 「いつも使う子」として覚えている ID。
  public static func resolve(
    placeholder: UUID?, current: UUID, loaded: [Profile], preferred: UUID?
  ) -> Result {
    guard let placeholder, !loaded.isEmpty, !loaded.contains(where: { $0.id == placeholder })
    else {
      // 仮の子がいない、または本物がまだ届いていない。いまの子が残っていればそのまま。
      let keep = loaded.contains { $0.id == current } || loaded.isEmpty
      return Result(currentID: keep ? current : loaded[0].id, dropPlaceholder: false)
    }
    let list = ProfileList(profiles: loaded)
    let chosen = list.current(preferred: preferred)?.id ?? loaded[0].id
    return Result(currentID: chosen, dropPlaceholder: true)
  }
}
