import ComposableArchitecture
import ContentModel
import EntitlementKit
import PracticeKit

/// しりとりの流れ（D35・D45・D70。§3.10）。決まりと1回の状態は `PracticeKit` の `ShiritoriRound` に任せ、
/// ここは「いまどの画面か」（書く画面へ行っている途中か）を持つ。
@Reducer
nonisolated struct ShiritoriFeature {
  @ObservableState
  struct State: Equatable {
    /// 回を始めたか。しりとりの画面を出るときに戻す。
    var started = false
    var round: ShiritoriRound
    var generator: SeededGenerator
    /// 書く画面へ渡している、子どもが選んだことば。
    var chosen: String?
    /// 画面の声の合図。番が進むたび（新しい回も）に増える。
    var turn = 0

    init(seed: UInt64 = .random(in: .min ... .max)) {
      var generator = SeededGenerator(seed: seed)
      round = ShiritoriRound(pool: ShiritoriPool(words: []), using: &generator)
      self.generator = generator
    }

    mutating func startRound(pool: ShiritoriPool) {
      var generator = self.generator
      round = ShiritoriRound(pool: pool, using: &generator)
      self.generator = generator
      chosen = nil
      turn += 1
    }
  }

  enum Action: Equatable {
    /// 画面が開いた。回を始める（すでに始めていれば、続きから）。
    case appeared(ShiritoriPool)
    /// 子どもが候補を選んだ（これから書く）。
    case picked(String)
    /// 書く画面から「←」で戻った。書き終えていないので、選び直せる。
    case pickCancelled
    /// 書く画面で書き終えた。続けて、キャラクターが言う。
    case wordWritten
    /// 「もういっかい」。
    case newRound
    /// しりとりの画面を出た。
    case left
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .appeared(let pool):
        guard !state.started else { return .none }
        state.started = true
        state.startRound(pool: pool)
        return .none

      case .picked(let word):
        guard !state.round.isOver, state.round.cards.contains(where: { $0.text == word }) else {
          return .none
        }
        state.chosen = word
        return .none

      case .pickCancelled:
        state.chosen = nil
        return .none

      case .wordWritten:
        guard let word = state.chosen else { return .none }
        state.chosen = nil
        var generator = state.generator
        state.round.childWrote(word, using: &generator)
        state.generator = generator
        state.turn += 1
        return .none

      case .newRound:
        state.startRound(pool: state.round.pool)
        return .none

      case .left:
        state = State(seed: state.generator.next())
        return .none
      }
    }
  }
}

/// しりとりに使うことば（アプリ側の決まり。D182・D199）。絵があって、ひらがなかカタカナで書けることばを集める。
/// えいごの ことばは入れない（日本語だけ。D45）。
/// 続ける音は、ことばの読み（カタカナはひらがな）で決める。「ー」はその前の字の音、小さい字は大きい字の音（`ShiritoriKana`）。
enum ShiritoriWords {
  /// ことばの字がすべてひらがななら `.hiragana`、すべてカタカナなら `.katakana`、そのほか（英語など）は nil。
  static func script(of text: String) -> Script? {
    switch WordText.script(of: text) {
    case .hiragana: .hiragana
    case .katakana: .katakana
    case .abc, nil: nil
    }
  }

  /// 鍵のかかったことばは、影絵で出る（押すと「おねがい」。D3・D45）。
  /// おためしのことば（バス）は、書けることばに入れる（D93）。
  @MainActor static func pool(entitlements: Entitlements) -> ShiritoriPool {
    let texts = WordArt.words.map(\.entry.text).filter(WordArt.hasArt)
    return ShiritoriPool(
      texts: texts.filter { script(of: $0) != nil },
      isLocked: { text in !WordAccess.canWrite(text, entitlements: entitlements) })
  }
}
