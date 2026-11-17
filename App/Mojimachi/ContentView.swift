import ComposableArchitecture
import ContentModel
import ParentGateKit
import RecordKit
import SwiftUI

/// 仮のホームと、画面の行き来（D101）。ホームのボタン3つから入り、「←」でホームへ戻る。
struct ContentView: View {
  enum Screen: String, CaseIterable {
    case map = "もじ"
    case card = "字のカード"
    case letter = "かく"
    case word = "ことば"
    case town = "まち"
    case closet = "クローゼット"
  }

  /// nil はホーム。
  @State private var screen: Screen? = {
    #if DEBUG
      // 確かめ用: `-screen word|town|letter|closet|map` でその画面を直接開く。
      // `-mapChar そ` でその字のカードを開く。
      if let name = UserDefaults.standard.string(forKey: "screen"),
        let screen = Screen.allCases.first(where: { "\($0)" == name })
      {
        return screen
      }
      if let char = UserDefaults.standard.string(forKey: "mapChar")?.first,
        KanaTable.script(of: char) != nil
      {
        return .card
      }
    #endif
    return nil
  }()

  @State private var mapSelection: MapSelection = {
    var selection = MapSelection()
    #if DEBUG
      // 確かめ用: `-mapChar ニ` でその字の文字、`-mapScript katakana`、`-mapPage extra`、`-mapHalf 1`。
      let defaults = UserDefaults.standard
      if let char = defaults.string(forKey: "mapChar")?.first,
        let script = KanaTable.script(of: char)
      {
        selection.script = script
      }
      if defaults.string(forKey: "mapScript") == "katakana" { selection.script = .katakana }
      if defaults.string(forKey: "mapPage") == "extra" { selection.page = .extra }
      selection.half = defaults.integer(forKey: "mapHalf")
    #endif
    return selection
  }()
  /// 字のカードで選んでいる字（書く画面へ入る字）。
  @State private var cardChar: Character? = {
    #if DEBUG
      return UserDefaults.standard.string(forKey: "mapChar")?.first
    #else
      return nil
    #endif
  }()
  /// ことば画面を字のカードから開いたか（「←」の戻り先）。
  @State private var wordFromCard = false
  @State private var wordStart: String?
  @State private var activity = WritingActivity()
  @State private var gateStore = Store(initialState: ParentGateFeature.State()) {
    ParentGateFeature()
  }
  @State private var showsGate = false
  @State private var showsParentArea = false
  @State private var showsProfilePicker = false
  /// 子どもの切り替えのために保護者用の確認を出しているか。
  @State private var gateForSwitch = false
  private let store = ProgressStore.shared
  private var gate: ParentGate { gateStore.gate }

  var body: some View {
    Group {
      if store.isWaitingForFirstImport {
        PreparingView()
      } else if let screen {
        VStack(spacing: 0) {
          HStack {
            BackButton(activity: activity) { goBack() }
            Spacer()
          }
          .padding(.horizontal, 32)
          .padding(.top, 12)
          content(screen)
        }
      } else {
        home
      }
    }
    .childBackground()
    .task {
      // 2台目の最初の起動では、iCloud からの取り込みを最大10秒待つ（D63）。
      while store.isWaitingForFirstImport {
        try? await Task.sleep(for: .milliseconds(250))
        store.tickFirstImportWait()
      }
    }
    // 子どもの画面のダイアログは、標準のシートではなく独自のポップな見た目で出す（D155）。
    .onChange(of: showsGate) { _, shows in
      if shows {
        PopPresenter.shared.show(id: "gate") {
          ParentGateSheet(
            store: gateStore,
            onPassed: {
              showsGate = false
              if gateForSwitch {
                gateForSwitch = false
                showsProfilePicker = true
              } else {
                showsParentArea = true
              }
            },
            onCancel: {
              showsGate = false
              gateForSwitch = false
            })
        }
      } else {
        PopPresenter.shared.dismiss(id: "gate")
      }
    }
    .onChange(of: showsProfilePicker) { _, shows in
      if shows {
        PopPresenter.shared.show(
          id: "profile", dismissesOnBackdrop: true, onDismiss: { showsProfilePicker = false }
        ) {
          ProfilePicker { id in
            store.switchProfile(to: id)
            showsProfilePicker = false
          }
        }
      } else {
        PopPresenter.shared.dismiss(id: "profile")
      }
    }
    .overlay { PopHost() }
    .fullScreenCover(isPresented: $showsParentArea) {
      ParentAreaView {
        gateStore.send(.close)
        showsParentArea = false
      }
    }
    #if DEBUG
      .onAppear {
        if UserDefaults.standard.bool(forKey: "showGate") { showsGate = true }
        // 確かめ用: `-seedRecords 3` できょうの字を3つ入れる。
        let seeded = UserDefaults.standard.integer(forKey: "seedRecords")
        if seeded > 0 { DebugSeed.today(count: seeded) }
        // 確かめ用: `-seedGrowth YES` で、あ行・か行を「はな」、さ行を「つぼみ」、た行を「め」にする。
        if UserDefaults.standard.bool(forKey: "seedGrowth") { DebugSeed.growth() }
        // 確かめ用: `-seedSamples YES` で見本の記録を入れる。iCloud の同期が動いているときは入れない
        // （本物のデータに混ざって iCloud に上がるため）。`-localOnlyStore YES` などと一緒に使う。
        if UserDefaults.standard.bool(forKey: "seedSamples"), !store.isSyncRunning {
          DebugSeed.records()
        }
        if UserDefaults.standard.string(forKey: "openParent") != nil { showsParentArea = true }
      }
    #endif
  }

  @ViewBuilder
  private func content(_ screen: Screen) -> some View {
    switch screen {
    case .map:
      MapView(selection: $mapSelection) { char in
        cardChar = char
        self.screen = .card
      }
      #if DEBUG
        .frame(
          maxWidth: UserDefaults.standard.double(forKey: "mapMaxWidth") > 0
            ? UserDefaults.standard.double(forKey: "mapMaxWidth") : .infinity)
      #endif
    case .card:
      if let cardChar {
        CharacterCardView(
          char: cardChar,
          onWrite: { self.screen = .letter },
          onWord: { text in
            wordStart = text
            wordFromCard = true
            self.screen = .word
          })
      }
    case .letter: WritingCanvasView(activity: activity, start: cardChar)
    case .word:
      WordWritingView(activity: activity, start: wordStart) { kind in
        wordFromCard = false
        self.screen = kind == .clothes ? .closet : .town
      }
    case .town: TownView()
    case .closet: TownView(layer: .closet)
    }
  }

  /// 「←」で一つ前へ（D101）。書く画面は字のカード、字のカードは文字の地図、地図はホーム。
  private func goBack() {
    switch screen {
    case .letter: screen = cardChar == nil ? nil : .card
    case .card: screen = .map
    case .word where wordFromCard:
      wordFromCard = false
      wordStart = nil
      screen = .card
    default: screen = nil
    }
    if screen == nil { cardChar = nil }
  }

  /// ホーム: 大きなボタン3つ。顔と歯車は上に置く。
  private var home: some View {
    VStack(spacing: 0) {
      HStack {
        // 使う子（D16）。押すと切り替えのシートを出す。
        Button {
          if store.confirmsProfileSwitch, !gate.isOpen(at: Date().timeIntervalSince1970) {
            gateForSwitch = true
            showsGate = true
          } else {
            showsProfilePicker = true
          }
        } label: {
          ProfileFace(face: store.currentProfile?.face ?? ProgressStore.faces[0], size: 64)
            .frame(minWidth: 104, minHeight: 104)
        }
        .accessibilityLabel("つかう こを かえる")
        Spacer()
        // 保護者用の入口（D49）。子どもが押しにくい小さな印を、2秒の長押しで開く（§5.3）。
        Image(systemName: "gearshape")
          .font(.title3)
          .foregroundStyle(.secondary)
          .padding(8)
          .contentShape(.rect)
          .onLongPressGesture(minimumDuration: 2) { openParentArea() }
          .accessibilityLabel("保護者用の画面")
          .accessibilityAddTraits(.isButton)
          .accessibilityAction { openParentArea() }
      }
      .padding(.horizontal, 32)
      .padding(.top, 12)
      Spacer()
      HStack(alignment: .top, spacing: 32) {
        HomeCharacter(reachedGoal: goalReached)
        VStack(spacing: 20) {
          TodayGoalCard(goal: goal, done: todayCount)
          // 文字の種類ごとの育ちの名前（D151）。
          VStack(spacing: 8) {
            ForEach(KanaScript.allCases, id: \.self) { script in
              GrowthBadge(summary: ScriptGrowthSummary(script: script, log: store.log), size: 22)
            }
          }
          StampCard(days: store.log.stampWeek(now: Date(), calendar: .current))
        }
      }
      .padding(.horizontal, 32)
      Spacer()
      HStack(spacing: 40) {
        HomeButton(title: "もじ", systemImage: "character.book.closed.fill", color: Theme.accent) {
          screen = .map
        }
        HomeButton(title: "ことば", systemImage: "text.bubble.fill", color: Theme.blue) {
          wordStart = nil
          wordFromCard = false
          screen = .word
        }
        HomeButton(title: "まち", systemImage: "house.fill", color: Theme.green) {
          screen = .town
        }
      }
      .padding(.horizontal, 32)
      Spacer()
    }
  }

  /// きょうの もくひょう（D17）。いまの子の字の数。
  private var goal: Int { store.currentProfile?.dailyGoal ?? 5 }
  /// きょう練習した字の数（同じ字は1つ。§3.8）。
  private var todayCount: Int {
    store.log.today(now: Date(), calendar: .current).characters
  }
  private var goalReached: Bool { todayCount >= goal }

  private func openParentArea() {
    if gate.isOpen(at: Date().timeIntervalSince1970) {
      showsParentArea = true
    } else {
      showsGate = true
    }
  }
}

/// 最初の取り込みを待つあいだの画面（D63）。エラーや数字は出さず、やさしく待つ。
private struct PreparingView: View {
  var body: some View {
    VStack(spacing: 32) {
      Image(systemName: "pawprint.fill")
        .font(.system(size: 96))
        .foregroundStyle(.white)
        .frame(width: 180, height: 180)
        .background(Theme.pink.gradient, in: .circle)
        .symbolEffect(.pulse)
      Text("もうすぐ あそべるよ")
        .font(.ui(36, bold: true))
        .foregroundStyle(Theme.ink)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement(children: .combine)
  }
}

/// ホームの大きなボタン（約104pt 以上。D101）。丸い大きな形とやわらかい影（D152）。
private struct HomeButton: View {
  var title: String
  var systemImage: String
  var color: Color
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 16) {
        Image(systemName: systemImage).font(.system(size: 72, weight: .bold))
        Text(title).font(.ui(40, bold: true))
      }
      .foregroundStyle(.white)
      .frame(maxWidth: 280, minHeight: 200)
      .frame(maxWidth: .infinity)
      .background(color.gradient, in: .rect(cornerRadius: Theme.Radius.button))
      .softShadow()
    }
    .buttonStyle(.plain)
  }
}

/// ホームのキャラクター。絵はまだ仮（SF Symbol）。キャラクター3人は D134 の Rive で作る。
private struct HomeCharacter: View {
  var reachedGoal: Bool

  var body: some View {
    VStack(spacing: 12) {
      Text(reachedGoal ? "すごい！\nできたね！" : "たのしく\nかこうね！")
        .font(.ui(30, bold: true))
        .foregroundStyle(Theme.ink)
        .multilineTextAlignment(.center)
        .padding(20)
        .background(.white, in: .rect(cornerRadius: Theme.Radius.card))
        .overlay(alignment: .bottom) {
          Image(systemName: "arrowtriangle.down.fill")
            .foregroundStyle(.white)
            .offset(y: 14)
        }
        .softShadow()
      Image(systemName: reachedGoal ? "party.popper.fill" : "pawprint.fill")
        .font(.system(size: 96))
        .foregroundStyle(.white)
        .frame(width: 180, height: 180)
        .background(Theme.pink.gradient, in: .circle)
        .softShadow()
        .padding(.top, 12)
    }
    .frame(width: 300)
    .accessibilityElement(children: .combine)
  }
}

/// きょうの もくひょう: 星の数が目標、光った星が書けた字。ことばは短く、数字は使わない（D17）。
private struct TodayGoalCard: View {
  var goal: Int
  var done: Int

  var body: some View {
    VStack(spacing: 12) {
      Text("きょうの もくひょう").font(.ui(28, bold: true)).foregroundStyle(Theme.ink)
      HStack(spacing: 8) {
        ForEach(0..<goal, id: \.self) { index in
          Image(systemName: index < done ? "star.fill" : "star")
            .font(.system(size: goal > 5 ? 36 : 48))
            .foregroundStyle(index < done ? Theme.yellow : Color.gray.opacity(0.5))
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding(20)
    .background(.white.opacity(0.85), in: .rect(cornerRadius: Theme.Radius.card))
    .softShadow()
    .accessibilityElement(children: .combine)
  }
}

/// スタンプカード: こんしゅうの7日。練習した日にスタンプ。休んだ日は空のまま（D17）。
private struct StampCard: View {
  var days: [StampDay]

  private static let names = ["にち", "げつ", "か", "すい", "もく", "きん", "ど"]

  var body: some View {
    VStack(spacing: 12) {
      Text("スタンプカード").font(.ui(28, bold: true)).foregroundStyle(Theme.ink)
      HStack(spacing: 6) {
        ForEach(days, id: \.date) { day in
          VStack(spacing: 6) {
            Text(Self.names[Calendar.current.component(.weekday, from: day.date) - 1])
              .font(.ui(18, bold: true))
              .foregroundStyle(Theme.inkSoft)
            Image(systemName: day.stamped ? "heart.circle.fill" : "circle.dashed")
              .font(.system(size: 40))
              .foregroundStyle(day.stamped ? Theme.pink : Color.gray.opacity(0.4))
              .padding(3)
              .background {
                if day.isToday { Circle().stroke(Theme.accent, lineWidth: 4) }
              }
          }
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding(20)
    .background(.white.opacity(0.85), in: .rect(cornerRadius: Theme.Radius.card))
    .softShadow()
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  ContentView()
}
