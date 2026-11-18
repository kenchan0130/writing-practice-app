import ContentModel
import JudgeKit
import PracticeKit
import SpriteKit
import SwiftUI

/// ことばを書く画面（試作。D46・D55）。1字ずつ書き、物が下から色づき、書けたら変身する（D43）。
struct WordWritingView: View {
  @State private var model: WordModel
  @State private var transform: TransformScene?
  @State private var transformFinished = false
  /// 置いたあとに見せる画面へ行く（服はクローゼット、ほかはまち。D101）。
  var onShowPlaced: (WordKind) -> Void = { _ in }
  /// ことばを選ばせず、決めたことばだけを書く（はじめての流れ。D23）。
  private let locksWord: Bool

  init(
    activity: WritingActivity = WritingActivity(),
    start: String? = nil,
    locksWord: Bool = false,
    onShowPlaced: @escaping (WordKind) -> Void = { _ in }
  ) {
    _model = State(initialValue: WordModel(activity: activity, start: start))
    self.locksWord = locksWord
    self.onShowPlaced = onShowPlaced
  }

  var body: some View {
    VStack(spacing: 20) {
      header
      ZStack {
        GeometryReader { proxy in
          let side =
            min(proxy.size.width, proxy.size.height) * (ProgressStore.shared.largeGrid ? 1 : 0.85)
          canvas
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
              model.side = side
              #if DEBUG
                if UserDefaults.standard.bool(forKey: "simulateWord") { model.simulateWriting() }
              #endif
            }
            .onChange(of: side) { _, newValue in model.side = newValue }
        }
        if model.wordDone {
          transformView
        }
        if let rating = model.charPraise, !model.wordDone {
          SmallPraise(rating: rating)
        }
      }
      StrokeDots(
        total: model.currentCharacter?.strokes.count ?? 0, done: model.strokes.count
      )
      .frame(height: 48)
      .opacity(model.wordDone ? 0 : 1)
      if !locksWord { wordPicker }
      buttons
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 24)
    .defersSystemGestures(on: .all)
    .overlay(alignment: penStandAlignment()) { PenStandButton().padding(24) }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    .onAppear {
      // はじめての起動の最初のことばの前に、1回だけ選ぶ（D88）。選ぶまで閉じない（D155）。
      if ProgressStore.shared.needsPenColorChoice {
        PopPresenter.shared.show(id: "firstPen") {
          PenColorPicker(title: "ペンの いろを えらぼう") { color in
            ProgressStore.shared.setPenColor(color)
            PopPresenter.shared.dismiss(id: "firstPen")
          }
        }
      }
    }
    .onChange(of: model.wordDone) { _, done in
      if !done {
        transform = nil
        transformFinished = false
      }
    }
  }

  /// ことばの字と、色づいていく物（D55）。
  private var header: some View {
    HStack(spacing: 24) {
      HStack(spacing: 4) {
        ForEach(Array(model.word.enumerated()), id: \.offset) { index, char in
          let done = index < (model.flow?.index ?? 0)
          let current = index == (model.flow?.index ?? -1) && !model.wordDone
          Text(String(char))
            .font(.learning(52))
            .foregroundStyle(done ? Theme.pink : current ? Theme.ink : Theme.inkSoft)
            .padding(6)
            .background(
              current ? Theme.yellow.opacity(0.4) : .clear, in: .rect(cornerRadius: 14))
        }
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(model.word)
      .accessibilityIdentifier("wordHeader")
      Spacer()
      ColoringSilhouette(
        symbol: model.symbol, progress: model.progress, color: Color(uiColor: model.artColor)
      )
      .frame(width: 140, height: 100)
    }
  }

  private var canvas: some View {
    TimelineView(.animation(paused: model.hintStroke == nil)) { timeline in
      Canvas { context, size in
        CanvasDrawing.guide(in: &context, size: size)
        let scale = size.width / 1000
        if let character = model.currentCharacter, !model.wordDone {
          switch model.mode {
          case .nazoru:
            context.fill(
              CanvasDrawing.outline(character.strokes, scale: scale),
              with: .color(.gray.opacity(0.4)))
          case .usuku:
            context.stroke(
              CanvasDrawing.outline(character.strokes, scale: scale),
              with: .color(.gray.opacity(0.5)), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
          default:
            break
          }
        }
        for stroke in model.strokes { CanvasDrawing.ink(stroke, in: &context) }
        CanvasDrawing.ink(model.recorder.current, in: &context)
        // 書き始めの印（番号）は、書いた線より上に描く。前の画の線で番号が隠れないように。
        if let character = model.currentCharacter, !model.wordDone, model.mode != .jibunde,
          let flow = model.flow,
          flow.expectedStroke < character.strokes.count
        {
          let pulse =
            model.hintStroke == nil
            ? 0 : (sin(timeline.date.timeIntervalSinceReferenceDate * 6) + 1) * 6
          CanvasDrawing.startMarker(
            for: character.strokes[flow.expectedStroke], number: flow.expectedStroke + 1,
            in: &context, scale: size.width / 1000, pulse: pulse)
        }
      }
    }
    .background(Theme.paper)
    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.paper))
    .overlay(
      RoundedRectangle(cornerRadius: Theme.Radius.paper).stroke(
        Theme.accent.opacity(0.7), lineWidth: 4)
    )
    .softShadow()
    .gesture(StrokeInputGesture { event, convert in model.handle(event, convert: convert) })
    .accessibilityLabel("もじを かく ばしょ")
  }

  /// 変身（SpriteKit。D110）。子どもが書いた字の線を、ことばの字の並びに置いて使う。
  private var transformView: some View {
    GeometryReader { proxy in
      SpriteView(
        scene: scene(for: proxy.size), options: [.allowsTransparency]
      )
      .background(.white.opacity(0.85), in: .rect(cornerRadius: 12))
    }
  }

  private func scene(for size: CGSize) -> TransformScene {
    if let transform { return transform }
    let count = max(model.writtenCharacters.count, 1)
    let cell = min(size.width / CGFloat(count), size.height * 0.4)
    let originX = (size.width - cell * CGFloat(count)) / 2
    let side = CGFloat(max(model.side, 1))
    var lines: [[CGPoint]] = []
    var colors: [UIColor] = []
    for (index, strokes) in model.writtenCharacters.enumerated() {
      let left: CGFloat = originX + CGFloat(index) * cell
      let top: CGFloat = size.height * 0.05
      for stroke in strokes {
        let points: [CGPoint] = stroke.map { point in
          let x: CGFloat = left + point.location.x / side * cell
          let y: CGFloat = top + point.location.y / side * cell
          return CGPoint(x: x, y: y)
        }
        lines.append(points)
        colors.append((stroke.first?.color ?? .default).uiColor)
      }
    }
    let image = PlaceholderArt.image(
      symbol: model.symbol, size: 600, color: model.artColor)
    let scene = TransformScene(
      size: size, lines: lines, colors: colors, objectImage: image, kind: model.kind,
      word: model.word)
    scene.onFinished = { transformFinished = true }
    DispatchQueue.main.async { transform = scene }
    return scene
  }

  /// ことばを選ぶ（乗り物・四つ足・服をまたぐ。大きい絵のボタンを横に並べる）。
  private var wordPicker: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(PlaceholderArt.words, id: \.entry.text) { item in
            WordPickButton(item: item, selected: item.entry.text == model.word) {
              model.select(item.entry.text)
            }
            .id(item.entry.text)
          }
        }
        .padding(.horizontal, 4)
      }
      // 選んだことばが見えるように、横に送る。
      .onAppear { proxy.scrollTo(model.word, anchor: .center) }
      .onChange(of: model.word) { _, word in
        withAnimation { proxy.scrollTo(word, anchor: .center) }
      }
    }
    .frame(height: 112)
  }

  private var buttons: some View {
    HStack(spacing: 32) {
      if model.wordDone {
        if transformFinished {
          ChildToolButton(
            title: model.kind == .clothes ? "クローゼットを みる" : "まちを みる",
            systemImage: model.kind == .clothes ? "hanger" : "house.fill", color: Theme.green
          ) {
            let kind = model.kind
            model.placeInTown()
            onShowPlaced(kind)
          }
        }
        if !locksWord {
          ChildToolButton(
            title: "もういっこ", systemImage: "arrow.right.circle.fill", color: Theme.accent
          ) {
            model.nextWord()
          }
        }
      } else {
        // どの段階でも、ことばを最初から書き直せる（D154 と同じ考え方）。
        ChildToolButton(title: "やりなおす", systemImage: "arrow.counterclockwise") {
          model.restartWord()
        }
        if model.mode == .jibunde {
          ChildToolButton(
            title: "できた！", systemImage: "checkmark.circle.fill", color: Theme.green,
            highlighted: model.highlightsDone
          ) { model.judgeNow() }
        }
      }
    }
    .frame(minHeight: 120)
  }
}

/// 物の影絵が、下から少しずつ色づく（D55）。
private struct ColoringSilhouette: View {
  var symbol: String
  var progress: Double
  var color: Color = .red

  var body: some View {
    let image = Image(systemName: symbol).resizable().scaledToFit()
    image.foregroundStyle(.gray.opacity(0.3))
      .overlay {
        GeometryReader { proxy in
          image.foregroundStyle(color)
            .mask(alignment: .bottom) {
              Rectangle().frame(height: proxy.size.height * progress)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
      }
      .animation(.easeInOut(duration: 0.5), value: progress)
      .accessibilityHidden(true)
  }
}

/// ことばを選ぶ絵のボタン（約104pt 以上。D101）。
private struct WordPickButton: View {
  var item: PlaceholderArt.Item
  var selected: Bool
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: item.symbol)
          .font(.system(size: 40))
          .foregroundStyle(Color(uiColor: item.color))
          .frame(height: 48)
        Text(item.entry.text).font(.learning(22)).foregroundStyle(Theme.ink)
          .lineLimit(1).minimumScaleFactor(0.6)
      }
      .frame(width: 108, height: 108)
      .background(
        selected ? Theme.yellow.opacity(0.5) : Color.white.opacity(0.7),
        in: .rect(cornerRadius: 20)
      )
      .overlay {
        if selected { RoundedRectangle(cornerRadius: 20).stroke(Theme.accent, lineWidth: 4) }
      }
    }
    .buttonStyle(.plain)
  }
}

/// 字が1つ書けたときの小さなごほうび（D152）。ことば全部が書けたときは、変身（D43）に任せる。
private struct SmallPraise: View {
  var rating: Rating
  @State private var appeared = false

  var body: some View {
    VStack(spacing: 8) {
      Circle()
        .stroke(Theme.red, lineWidth: 14)
        .frame(width: 120, height: 120)
      HStack(spacing: 6) {
        ForEach(0..<CelebrationView.stars(rating), id: \.self) { _ in
          Image(systemName: "star.fill").font(.system(size: 30)).foregroundStyle(Theme.yellow)
        }
      }
      Text(CelebrationView.praise(rating)).font(.ui(30, bold: true)).foregroundStyle(Theme.ink)
    }
    .padding(24)
    .background(.white.opacity(0.9), in: .rect(cornerRadius: Theme.Radius.card))
    .softShadow()
    .scaleEffect(appeared ? 1 : 0.5)
    .opacity(appeared ? 1 : 0)
    .onAppear { withAnimation(.spring(duration: 0.35, bounce: 0.4)) { appeared = true } }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}
