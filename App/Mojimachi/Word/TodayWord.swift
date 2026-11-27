import ContentModel
import EntitlementKit
import Foundation
import PracticeKit
import SoundKit
import SwiftUI

/// きょうの ことば（D35・D54・D182）。毎日、主人公が1つのことばを持ってくる。
/// 選び方は `PracticeKit` の `DailyWord`。同じ子・同じ日なら、いつ開いても同じことばになる。
enum TodayWord {
  /// きょうの日。
  static func day(now: Date = Date(), calendar: Calendar = .current) -> CalendarDay {
    #if DEBUG
      // 確かめ用: `-today 2026-07-20` でその日にする。
      if let text = UserDefaults.standard.string(forKey: "today") {
        let parts = text.split(separator: "-").compactMap { Int($0) }
        if parts.count == 3 { return CalendarDay(year: parts[0], month: parts[1], day: parts[2]) }
      }
    #endif
    let parts = calendar.dateComponents([.year, .month, .day], from: now)
    return CalendarDay(year: parts.year ?? 1970, month: parts.month ?? 1, day: parts.day ?? 1)
  }

  /// iPad の地域が日本か。日本のときだけ、季節で選ぶ（D54）。
  static var isJapan: Bool {
    #if DEBUG
      // 確かめ用: `-todayRegion US` で、地域を決める。
      if let region = UserDefaults.standard.string(forKey: "todayRegion") { return region == "JP" }
    #endif
    return Locale.current.region?.identifier == "JP"
  }

  /// その日・その子で、いちど出したことば。あとで購入記録が読み込まれても、その日は変えない（D194）。
  private static var chosen: [String: String] = [:]
  /// アプリを起動した時刻（購入記録の読み込みを待つ目安）。
  private static let launchedAt = Date()
  nonisolated static let unlockedKey = "todayWordUnlockedScripts"

  /// 使える文字の種類。起動の直後は購入記録がまだ空なので、前に分かっていた分を使う（D194）。
  /// 読み込めたら、それを覚える。読み込みが5秒たっても空なら、覚えていた分を捨てる。
  @MainActor private static func unlockedScripts(
    entitlements: Entitlements, defaults: UserDefaults, now: Date
  ) -> Set<Script> {
    if !entitlements.purchases.isEmpty {
      let live = Set(Script.allCases.filter(entitlements.isUnlocked))
      defaults.set(live.map(\.rawValue).sorted(), forKey: unlockedKey)
      return live
    }
    let remembered = Set(
      (defaults.stringArray(forKey: unlockedKey) ?? []).compactMap(Script.init(rawValue:)))
    if now.timeIntervalSince(launchedAt) > 5, !remembered.isEmpty {
      defaults.removeObject(forKey: unlockedKey)
      return Set(Script.allCases.filter(entitlements.isUnlocked))
    }
    return remembered.union(Script.allCases.filter(entitlements.isUnlocked))
  }

  /// きょうのことば。選べることばがなければ nil。
  /// いちど出したことばは、その日は変えない。起動の直後（購入記録が読めるまで）は、前に分かっていた
  /// 使える文字で選ぶ。そのため、買っている家庭でも、あとから ことばが入れ替わらない（D194）。
  @MainActor static func word(
    store: ProgressStore = .shared, entitlements: Entitlements = PurchaseStore.shared.entitlements,
    defaults: UserDefaults = .standard, now: Date = Date(), calendar: Calendar = .current
  ) -> String? {
    let key = "\(day(now: now, calendar: calendar))|\(store.currentProfileID.uuidString)"
    if let word = chosen[key] { return word }
    let unlocked = unlockedScripts(entitlements: entitlements, defaults: defaults, now: now)
    let picked = pick(store: store, unlocked: unlocked, now: now, calendar: calendar)
    if let picked { chosen[key] = picked }
    return picked
  }

  @MainActor private static func pick(
    store: ProgressStore, unlocked: Set<Script>, now: Date, calendar: Calendar
  ) -> String? {
    let startOfDay = calendar.startOfDay(for: now)
    // きょう書いた分は入れない。書くと選び直しになって、開くたびに変わってしまうため。
    let written = Set(store.log.currentWords.filter { $0.date < startOfDay }.map(\.word))
    let candidates = WordArt.words.map(\.entry.text).filter { text in
      WordArt.hasArt(text)
        && (ShiritoriWords.script(of: text).map { unlocked.contains($0) } ?? false)
    }
    return DailyWord.pick(
      from: candidates, writtenBeforeToday: written, day: day(now: now, calendar: calendar),
      childID: store.currentProfileID.uuidString, isJapan: isJapan)
  }
}

/// ホームの「きょうの ことば」の絵カード（押すと、そのことばを書く画面へ。D35・D101）。
struct TodayWordCard: View {
  var word: String
  var action: () -> Void

  var body: some View {
    Button {
      SoundPlayer.shared.play(.tap)
      action()
    } label: {
      VStack(spacing: 6) {
        Text("きょうの ことば").font(.ui(24, bold: true)).foregroundStyle(Theme.inkSoft)
        HStack(spacing: 12) {
          Image(WordArt.assetName(for: word)).resizable().scaledToFit()
            .frame(width: 84, height: 84)
            .accessibilityHidden(true)
          Text(word).font(.learning(40)).foregroundStyle(Theme.ink)
            .lineLimit(1).minimumScaleFactor(0.5)
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
      .frame(maxWidth: 300, minHeight: 140)
      .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
      .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(Theme.accent, lineWidth: 4))
      .softShadow()
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("きょうの ことば")
    .accessibilityValue(word)
    .accessibilityAddTraits(.isButton)
    .accessibilityIdentifier("todayWordCard")
  }
}
