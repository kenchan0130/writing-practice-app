/// ずかんの1つのことばの状態（D35・D74・D82）。
public enum ZukanState: Sendable, Hashable {
  /// 書いた。`stars` は★の数（1〜3）。
  case written(stars: Int)
  /// まだ書いていない（影絵で見せる）。
  case unwritten
  /// 鍵つき（影絵に鍵。押すと「おねがい」の画面）。
  case locked

  public var isWritten: Bool {
    if case .written = self { return true }
    return false
  }
}

/// ずかんの1つのことば。
public struct ZukanEntry: Sendable, Hashable, Identifiable {
  public let word: String
  public let state: ZukanState
  public var id: String { word }
}

/// ずかんの1つのテーマ。
public struct ZukanSection: Sendable, Hashable, Identifiable {
  public let theme: WordTheme
  public let entries: [ZukanEntry]
  public var id: String { theme.id }
}

/// ずかんの並べ方と★の数え方（D35・D74・D82。画面に頼らない）。
public enum Zukan {
  /// ★の数の上限（D82）。
  public static let maxStars = 3

  /// 書いた回数（記録の行の数）から★の数。1回でも書いていれば1、3回以上で3。書いていなければ 0。
  public static func stars(writtenCount: Int) -> Int {
    min(max(writtenCount, 0), maxStars)
  }

  public static func state(
    of word: String, writtenCounts: [String: Int], isLocked: (String) -> Bool
  ) -> ZukanState {
    let stars = stars(writtenCount: writtenCounts[word] ?? 0)
    if stars > 0 { return .written(stars: stars) }
    return isLocked(word) ? .locked : .unwritten
  }

  /// テーマごとのずかん。場所の順、テーマの順。絵のあることばだけ（地図と同じ。D166）。
  /// 1つのことばがいくつかのテーマに入っているときは、どのテーマにも出す。
  public static func sections(
    index: WordMapIndex, writtenCounts: [String: Int], isLocked: (String) -> Bool = { _ in false }
  ) -> [ZukanSection] {
    index.places.flatMap { place in
      index.themes(in: place).map { theme in
        ZukanSection(
          theme: theme,
          entries: index.words(in: theme).map {
            ZukanEntry(
              word: $0, state: state(of: $0, writtenCounts: writtenCounts, isLocked: isLocked))
          })
      }
    }
  }

  /// ずかんに出る、ことばの数（重ならない）。
  public static func distinctWords(in sections: [ZukanSection]) -> Set<String> {
    Set(sections.flatMap { $0.entries.map(\.word) })
  }
}
