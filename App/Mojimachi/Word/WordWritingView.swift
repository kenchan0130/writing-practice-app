import ContentModel
import PracticeKit
import SpriteKit
import SwiftUI

/// ことばを書く画面（試作。D46・D55）。1字ずつ書き、物が下から色づき、書けたら変身する（D43）。
struct WordWritingView: View {
  @State private var model = WordModel()
  @State private var transform: TransformScene?
  @State private var transformFinished = false
  @State private var showsFirstPenPicker = ProgressStore.shared.needsPenColorChoice
  var onShowTown: () -> Void = {}
  /// ペンの色。画面の再描画のきっかけになるよう、ここで読む。
  private var ink: Color { ProgressStore.shared.penColor.color }

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
      }
      buttons
    }
    .padding(32)
    .defersSystemGestures(on: .all)
    .overlay(alignment: penStandAlignment()) { PenStandButton().padding(24) }
    .overlay(alignment: .top) { CaptionBubble().padding(.top, 12) }
    .sheet(isPresented: $showsFirstPenPicker) {
      // はじめての起動の最初のことばの前に、1回だけ選ぶ（D88）。
      PenColorPicker(title: "ペンの いろを えらぼう") { color in
        ProgressStore.shared.setPenColor(color)
        showsFirstPenPicker = false
      }
      .presentationDetents([.medium])
      .interactiveDismissDisabled()
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
            .font(.system(size: 44, weight: .bold))
            .foregroundStyle(done ? Color.accentColor : current ? .primary : .secondary)
            .padding(6)
            .background(current ? Color.yellow.opacity(0.3) : .clear, in: .rect(cornerRadius: 10))
        }
      }
      Spacer()
      ColoringSilhouette(symbol: model.symbol, progress: model.progress)
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
          if model.mode != .jibunde, let flow = model.flow,
            flow.expectedStroke < character.strokes.count
          {
            let pulse =
              model.hintStroke == nil
              ? 0 : (sin(timeline.date.timeIntervalSinceReferenceDate * 6) + 1) * 6
            CanvasDrawing.startMarker(
              for: character.strokes[flow.expectedStroke], in: &context, scale: scale,
              pulse: pulse)
          }
        }
        let color = ink
        for stroke in model.strokes { CanvasDrawing.ink(stroke, in: &context, color: color) }
        CanvasDrawing.ink(model.recorder.current, in: &context, color: color)
      }
    }
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
    .clipShape(RoundedRectangle(cornerRadius: 12))
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
      }
    }
    let image = PlaceholderArt.image(
      symbol: model.symbol, size: 600, color: UIColor(red: 0.85, green: 0.3, blue: 0.25, alpha: 1))
    let scene = TransformScene(
      size: size, lines: lines, objectImage: image,
      inkColor: ProgressStore.shared.penColor.uiColor)
    scene.onFinished = { transformFinished = true }
    DispatchQueue.main.async { transform = scene }
    return scene
  }

  private var buttons: some View {
    HStack(spacing: 32) {
      if model.wordDone {
        if transformFinished {
          WordButton(title: "まちに おく", systemImage: "house.fill") {
            model.placeInTown()
            onShowTown()
            model.nextWord()
          }
        }
        WordButton(title: "つぎの ことば", systemImage: "arrow.right.circle.fill") {
          model.nextWord()
        }
      } else if model.mode == .jibunde {
        WordButton(title: "できた！", systemImage: "checkmark.circle.fill") { model.judgeNow() }
      }
    }
    .frame(minHeight: 120)
  }
}

/// 物の影絵が、下から少しずつ色づく（D55）。
private struct ColoringSilhouette: View {
  var symbol: String
  var progress: Double

  var body: some View {
    let image = Image(systemName: symbol).resizable().scaledToFit()
    image.foregroundStyle(.gray.opacity(0.3))
      .overlay {
        GeometryReader { proxy in
          image.foregroundStyle(.red)
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

/// 子どもが押すボタン（2cm 角以上。D101）。
private struct WordButton: View {
  var title: String
  var systemImage: String
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: systemImage).font(.system(size: 36, weight: .bold))
        Text(title).font(.headline)
      }
      .frame(minWidth: 120, minHeight: 120)
    }
    .buttonStyle(.bordered)
    .buttonBorderShape(.roundedRectangle(radius: 24))
  }
}
