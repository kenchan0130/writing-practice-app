import Foundation

/// 子の行がシステムに消されたときの判断（D197）。画面や Core Data に頼らない。
///
/// iCloud のサインアウトやアカウントの切り替えのとき、システムは端末の中の同期の行を消すことがある
/// （避ける方法はない）。行は `profileID` でつながっているだけなので、子の行が消えたあとに
/// 書き続けると、前の子の名前の行が、次のアカウントの iCloud に上がってしまう。

/// プロフィールの行の保存の結果。
public enum ProfileWriteOutcome: Sendable, Equatable {
  /// 前からある行を直した。
  case updated
  /// 新しく行を足した。
  case inserted
  /// 行が無かったので、何も書かなかった。
  case missing
  /// 保存先が読めなかった（開き直しの間など）。消えたとは決めず、何も書かない。
  case unreadable
}

/// プロフィールの保存を「直す」と「足す」に分ける（D197）。
public enum ProfileWrite {
  /// 直す。行が無いときは足さずに `missing`（消えた子を、名前つきでよみがえらせない）。
  /// 保存先が読めなかったときは、行が無いとは言わず `unreadable`。
  public static func update(canRead: Bool, rowExists: Bool) -> ProfileWriteOutcome {
    guard canRead else { return .unreadable }
    return rowExists ? .updated : .missing
  }

  /// 足す。はっきり作るとき（子を足す、最初の子を保存する、はじめての流れ）だけ使う。
  /// 同じ ID の行がもうあれば、二重にせず直す。
  public static func insert(rowExists: Bool) -> ProfileWriteOutcome {
    rowExists ? .updated : .inserted
  }
}

public enum ProfileVanish {
  /// いまの子の行が消えているか。まだ保存していない最初の子（D194）は、消えたとは言わない。
  public static func isVanished(profileID: UUID, placeholderID: UUID?, rowExists: Bool) -> Bool {
    profileID != placeholderID && !rowExists
  }

  /// その子に関わる記録を書いてよいか。
  public enum WriteGate: Sendable, Equatable {
    /// 保存先に書く。
    case write
    /// 切り替えを待っている間。画面の中だけ変えて、保存先には書かない。
    case memoryOnly
    /// 書かない（子の行が消えている）。
    case drop
  }

  /// - Parameters:
  ///   - switchPending: 消えたと分かって、切り替えを待っている。
  ///   - isPlaceholder: まだ保存していない最初の子（これから保存する）。
  ///   - rowExists: 保存先に、子の行があるか。
  public static func writeGate(switchPending: Bool, isPlaceholder: Bool, rowExists: Bool)
    -> WriteGate
  {
    if switchPending { return .memoryOnly }
    if isPlaceholder || rowExists { return .write }
    return .drop
  }

  /// 保存先から子を読み直したときの扱い。
  public enum ReloadAction: Sendable, Equatable {
    /// 0人だが、いまの子はまだ保存していない最初の子。そのまま待つ（D63・D194）。
    case keepPlaceholder
    /// 保存していた子が、全員消えた。名前のない新しい子にする。
    case vanished
    /// いまの子だけ消えて、ほかの子が残っている（ほかの iPad が消したのかもしれない）。
    /// 書く画面を出てから、残っている子に切り替える。
    case currentGone
    /// ふつうに読み直す（届いた子との入れ替えは `ProfileAdoption`）。
    case adopt
  }

  public static func reloadAction(placeholderID: UUID?, currentID: UUID, loadedIDs: [UUID])
    -> ReloadAction
  {
    guard loadedIDs.isEmpty else {
      let gone = currentID != placeholderID && !loadedIDs.contains(currentID)
      return gone ? .currentGone : .adopt
    }
    return currentID == placeholderID ? .keepPlaceholder : .vanished
  }

  /// 画面を切り替える時期。
  public enum SwitchTiming: Sendable, Equatable {
    case now
    /// 書く画面を出ているあいだは、出てから切り替える。
    case deferred
  }

  public static func switchTiming(isWriting: Bool) -> SwitchTiming {
    isWriting ? .deferred : .now
  }
}
