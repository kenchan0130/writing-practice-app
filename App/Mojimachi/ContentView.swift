import ComposableArchitecture
import ContentModel
import EntitlementKit
import ParentGateKit
import PracticeKit
import RecordKit
import SoundKit
import SwiftUI

/// 仮のホームと、画面の行き来（D101）。ホームのボタン3つから入り、「←」でホームへ戻る。
struct ContentView: View {
  enum Screen: String, CaseIterable {
    case map = "もじ"
    case card = "字のカード"
    case letter = "かく"
    case word = "ことば"
    case shiritori = "しりとり"
    case shiritoriWord = "しりとりの ことば"
    case places = "まちの地図"
    case themes = "テーマ"
    case wordCards = "ことばのカード"
    case zukan = "ずかん"
    case letterWords = "もじから さがす"
    case town = "まち"
    case house = "いえ"
    case closet = "クローゼット"
  }

  /// nil はホーム。
  @State private var screen: Screen? = {
    #if DEBUG
      // 確かめ用: `-screen word|town|house|letter|closet|map|places|themes|wordCards` でその画面を直接開く。
      // `-mapChar そ` でその字のカードを開く。`-place ie`・`-theme fuku` でまちの地図の場所・テーマを選ぶ。
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
      // 確かめ用: `-mapChar ニ` でその字の文字、`-mapScript katakana|abc`、`-mapPage extra`（ABC は `lower`・`digits`）、`-mapHalf 1`。
      let defaults = UserDefaults.standard
      if let char = defaults.string(forKey: "mapChar")?.first, KanaTable.script(of: char) != nil {
        selection = MapSelection(showing: char)
      }
      if let script = defaults.string(forKey: "mapScript").flatMap(KanaScript.init(rawValue:)) {
        selection.script = script
      }
      if defaults.string(forKey: "mapPage") == "extra" { selection.page = .extra }
      if let page = defaults.string(forKey: "mapPage").flatMap(AbcTable.Page.init(rawValue:)) {
        selection.abcPage = page
      }
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
  /// ことばの入口（まちの地図 → テーマ → ことばのカード）で選んだ場所とテーマ（D166）。
  @State private var selectedPlace: Place? = {
    #if DEBUG
      return UserDefaults.standard.string(forKey: "place").flatMap { WordMap.place(id: $0) }
    #else
      return nil
    #endif
  }()
  @State private var selectedTheme: WordTheme? = {
    #if DEBUG
      return UserDefaults.standard.string(forKey: "theme").flatMap { WordMap.theme(id: $0) }
    #else
      return nil
    #endif
  }()
  /// ことば画面をテーマのことばのカードから開いたか（「←」の戻り先）。
  @State private var wordFromCards = false
  /// ことば画面をずかんから開いたか（「←」の戻り先。D181）。
  @State private var wordFromZukan = false
  /// ことば画面を「もじから さがす」から開いたか（「←」の戻り先。D181）。
  @State private var wordFromLetterWords = false
  @State private var wordStart: String? = {
    #if DEBUG
      // 確かめ用: `-screen word -startWord やま` でそのことばの書く画面を開く（`-simulateWord YES` と一緒に）。
      return UserDefaults.standard.string(forKey: "startWord")
    #else
      return nil
    #endif
  }()
  /// クローゼットを、いえから開いたか（「←」の戻り先。D185）。
  @State private var closetFromHouse = false
  /// ことば画面を、ホームの「きょうの ことば」から開いたか（「←」の戻り先）。
  @State private var wordFromToday = false
  /// しりとりの流れ（D35・D45・D70）。書く画面へ行って戻っても、同じ回を続けるため、ここで持つ。
  @State private var shiritoriStore = Store(initialState: ShiritoriFeature.State()) {
    ShiritoriFeature()
  }
  @State private var activity = WritingActivity()
  @State private var gateStore = Store(initialState: ParentGateFeature.State()) {
    ParentGateFeature()
  }
  /// 鍵の画面に出しているもの（nil なら出さない。D160）。元の画面の上に重ねる。
  @State private var lockedScript: Script?
  @State private var showsGate = false
  @State private var showsParentArea = false
  @Environment(\.scenePhase) private var scenePhase
  /// はじめての流れ（D23）。出していないときは nil。
  @State private var onboarding: OnboardingStage?
  @State private var showsProfilePicker = false
  /// 子どもの切り替えのために保護者用の確認を出しているか。
  @State private var gateForSwitch = false
  private let store = ProgressStore.shared
  private var gate: ParentGate { gateStore.gate }

  var body: some View {
    Group {
      if store.isWaitingForFirstImport {
        PreparingView()
      } else if let onboarding {
        switch onboarding {
        case .adult:
          OnboardingAdultView { evaluateOnboarding(after: .adult) }
        case .child:
          OnboardingChildView { evaluateOnboarding(after: .child) }
        }
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
    // iCloud の取り込みを待ち終わってから決める（D63）。選んだ子が変わったときも決め直す（D23）。
    .onChange(of: store.isWaitingForFirstImport, initial: true) { evaluateOnboarding() }
    .onChange(of: store.currentProfileID) { evaluateOnboarding() }
    // 鍵の画面を重ねているあいだは、後ろの画面を VoiceOver などから隠す（D160）。
    .accessibilityHidden(lockedScript != nil)
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
    .overlay {
      if let lockedScript {
        LockScreenView(script: lockedScript) { self.lockedScript = nil }
          .transition(.opacity)
      }
    }
    .animation(.easeOut(duration: 0.2), value: lockedScript)
    .overlay { PopHost() }
    .fullScreenCover(isPresented: $showsParentArea) {
      ParentAreaView(
        onClose: {
          gateStore.send(.close)
          showsParentArea = false
        },
        onActivity: { gateStore.send(.touched) })
    }
    // 保護者用の画面は、5分操作がなければ閉じる（D49）。開いているあいだ1秒ごとと、アプリに戻ったときに確かめる。
    .onChange(of: showsParentArea) { _, shows in
      if shows { gateStore.send(.parentAreaOpened) }
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active, showsParentArea { gateStore.send(.checkExpiry) }
    }
    .task(id: showsParentArea) {
      guard showsParentArea else { return }
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(1))
        gateStore.send(.checkExpiry)
      }
    }
    .onChange(of: gateStore.parentAreaExpired) { _, expired in
      if expired { showsParentArea = false }
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
        // 確かめ用: `-seedTown YES` で、5つの型を まち・クローゼットに置く（`debugSeedTown`。D168）。
        if UserDefaults.standard.bool(forKey: "seedTown"), !store.isSyncRunning {
          debugSeedTown(store)
        }
        // 確かめ用: `-seedZukan YES` で、ずかんの★と書けた字を入れる（`-inMemoryStore YES` などと一緒に）。
        if UserDefaults.standard.bool(forKey: "seedZukan"), !store.isSyncRunning {
          DebugSeed.zukan()
        }
        if UserDefaults.standard.string(forKey: "openParent") != nil { showsParentArea = true }
      }
    #endif
  }

  @ViewBuilder
  private func content(_ screen: Screen) -> some View {
    switch screen {
    case .map:
      MapView(
        selection: $mapSelection,
        onSelect: { char in
          cardChar = char
          self.screen = .card
        },
        onLocked: { lockedScript = $0 }
      )
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
            wordFromCards = false
            wordFromToday = false
            wordFromZukan = false
            wordFromLetterWords = false
            self.screen = .word
          },
          onSearch: { self.screen = .letterWords })
      }
    case .letter:
      WritingCanvasView(activity: activity, start: cardChar, onLocked: { lockedScript = $0 })
    case .word:
      WordWritingView(
        activity: activity, start: wordStart,
        choices: wordFromCards ? selectedTheme.map { WordArt.index.words(in: $0) } : nil
      ) { kind in
        wordFromCard = false
        wordFromCards = false
        wordFromToday = false
        wordFromZukan = false
        wordFromLetterWords = false
        closetFromHouse = false
        // 服はクローゼット、いえの物は いえの なか、ほかは まち（D53・D185）。
        self.screen =
          switch kind {
          case .clothes: .closet
          case .furniture: .house
          default: .town
          }
      }
    case .shiritori:
      ShiritoriView(
        store: shiritoriStore, character: store.mainCharacter,
        pool: ShiritoriWords.pool(entitlements: PurchaseStore.shared.entitlements),
        onWrite: { word in
          wordStart = word
          self.screen = .shiritoriWord
        },
        onLocked: { lockedScript = $0 })
    case .shiritoriWord:
      // しりとりで選んだことばだけを書く。書き終えたら「つぎへ」で しりとりの画面へ戻る（D182）。
      WordWritingView(
        activity: activity, start: wordStart, locksWord: true, choices: wordStart.map { [$0] },
        finishButton: .init(title: "つぎへ", systemImage: "arrow.right.circle.fill")
      ) { _ in
        wordStart = nil
        shiritoriStore.send(.wordWritten)
        self.screen = .shiritori
      }
    case .zukan:
      ZukanView(
        onWrite: { text in
          wordStart = text
          wordFromCard = false
          wordFromCards = false
          wordFromLetterWords = false
          wordFromZukan = true
          self.screen = .word
        },
        onLocked: { lockedScript = $0 })
    case .letterWords:
      if let cardChar {
        LetterWordsView(char: cardChar) { text in
          wordStart = text
          wordFromCard = false
          wordFromCards = false
          wordFromZukan = false
          wordFromLetterWords = true
          self.screen = .word
        }
      }
    case .places:
      PlacesView(
        onSelect: { place in
          selectedPlace = place
          switch WordArt.index.entrance(of: place) {
          case .words(let theme):
            selectedTheme = theme
            self.screen = .wordCards
          case .themes:
            self.screen = .themes
          case nil:
            break
          }
        },
        onShiritori: { self.screen = .shiritori },
        onZukan: { self.screen = .zukan })
    case .themes:
      if let selectedPlace {
        ThemesView(place: selectedPlace) { theme in
          selectedTheme = theme
          self.screen = .wordCards
        }
      }
    case .wordCards:
      if let selectedTheme {
        WordCardsView(theme: selectedTheme) { text in
          wordStart = text
          wordFromCard = false
          wordFromCards = true
          wordFromToday = false
          wordFromZukan = false
          wordFromLetterWords = false
          self.screen = .word
        }
      }
    case .town: TownView(onHouse: { self.screen = .house })
    case .house:
      HouseView {
        closetFromHouse = true
        self.screen = .closet
      }
    case .closet: TownView(layer: .closet)
    }
  }

  /// 「←」で一つ前へ（D101）。書く画面は字のカード、字のカードは文字の地図、地図はホーム。
  /// しりとりは、書く画面 → しりとり → まちの地図（D182）。
  /// ことばは、書く画面 → ことばのカード → テーマ（場所に2つ以上あるとき）→ まちの地図 → ホーム（D166）。
  private func goBack() {
    switch screen {
    case .letter: screen = cardChar == nil ? nil : .card
    case .card: screen = .map
    case .word where wordFromCard:
      wordFromCard = false
      wordStart = nil
      screen = .card
    case .word where wordFromZukan:
      wordFromZukan = false
      wordStart = nil
      screen = .zukan
    case .word where wordFromLetterWords:
      wordFromLetterWords = false
      wordStart = nil
      screen = .letterWords
    case .letterWords: screen = .card
    case .zukan: screen = .places
    case .word where wordFromCards:
      wordFromCards = false
      wordStart = nil
      screen = .wordCards
    case .word where wordFromToday:
      wordFromToday = false
      wordStart = nil
      screen = nil
    case .shiritoriWord:
      // 書き終えていないので、選び直せる。
      wordStart = nil
      shiritoriStore.send(.pickCancelled)
      screen = .shiritori
    case .shiritori:
      shiritoriStore.send(.left)
      screen = .places
    case .wordCards:
      if let selectedPlace, case .themes = WordArt.index.entrance(of: selectedPlace) {
        screen = .themes
      } else {
        screen = .places
      }
    case .themes: screen = .places
    // まち → いえ → クローゼット（§3.1）。「←」で1つずつ戻る。
    case .house: screen = .town
    case .closet where closetFromHouse:
      closetFromHouse = false
      screen = .house
    default: screen = nil
    }
    if screen == nil {
      cardChar = nil
      selectedPlace = nil
      selectedTheme = nil
    }
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
        HomeCharacter(reachedGoal: goalReached, todayWord: todayWord) { word in
          wordStart = word
          wordFromCard = false
          wordFromCards = false
          wordFromToday = true
          screen = .word
          Task {
            await VoicePlayer.shared.speak(sequence: [VoiceLine.todayWord.text, word])
          }
        }
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
          wordFromCards = false
          wordFromZukan = false
          wordFromLetterWords = false
          selectedPlace = nil
          selectedTheme = nil
          screen = .places
        }
        HomeButton(title: "まち", systemImage: "house.fill", color: Theme.green) {
          screen = .town
        }
      }
      .padding(.horizontal, 32)
      Spacer()
    }
  }

  /// きょうの ことば（D35）。
  private var todayWord: String? { TodayWord.word() }
  /// きょうの もくひょう（D17）。いまの子の字の数。
  private var goal: Int { store.currentProfile?.dailyGoal ?? 5 }
  /// きょう練習した字の数（同じ字は1つ。§3.8）。
  private var todayCount: Int {
    store.log.today(now: Date(), calendar: .current).characters
  }
  private var goalReached: Bool { todayCount >= goal }

  /// はじめての流れを出すか決める。流れの途中では決め直さず、終わったときだけ次を決める。
  private func evaluateOnboarding(after finished: OnboardingStage? = nil) {
    guard finished != nil || onboarding == nil else { return }
    let next = store.onboardingStage
    // 前半を終えたら、すぐ後半へ。後半を終えたら（または「←」で抜けたら）ホームへ。
    onboarding = finished == .child ? nil : next
    if finished == .child { screen = nil }
  }

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
      MainCharacterArt(character: ProgressStore.shared.mainCharacter, size: 220)
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

/// ホームのキャラクター。目標に届いたら よろこぶ絵にする（D164）。
/// ことばを1つ持っていて、押すと そのことばを書く画面へ（きょうの ことば。D35）。
private struct HomeCharacter: View {
  var reachedGoal: Bool
  var todayWord: String?
  var onTodayWord: (String) -> Void
  /// はじめての流れで選んだキャラクター（D39）。
  private var character: MainCharacter { ProgressStore.shared.mainCharacter }

  var body: some View {
    VStack(spacing: 12) {
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
        // キャラクターを押しても、きょうの ことばへ（D35）。
        Button {
          if let todayWord { onTodayWord(todayWord) }
        } label: {
          MainCharacterArt(character: character, size: 220, pose: reachedGoal ? .happy : .normal)
        }
        .buttonStyle(.plain)
        .disabled(todayWord == nil)
        .padding(.top, 12)
      }
      .accessibilityElement(children: .combine)
      if let todayWord {
        TodayWordCard(word: todayWord) { onTodayWord(todayWord) }
      }
    }
    .frame(width: 300)
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
