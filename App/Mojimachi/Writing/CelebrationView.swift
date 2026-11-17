import JudgeKit
import SwiftUI

/// 1字書けたときのごほうび（D152）。画面を少し暗くして、大きなはなまる・星・ほめ言葉・紙ふぶきを出す。
/// D43 の変身とは別の、1字ごとの小さなごほうび。
struct CelebrationView: View {
  var rating: Rating
  var char: Character
  /// 押したら閉じる（自動で進むのもやめる。D154）。
  var onTap: () -> Void
  /// 確かめ用: この秒数で止めて見せる。nil なら動かす。
  var frozenAt: Double?

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var started = Date()

  static func praise(_ rating: Rating) -> String {
    switch rating {
    case .maru: "いいね！"
    case .nijumaru: "すごい！"
    case .hanamaru: "かんぺき！"
    }
  }

  static func stars(_ rating: Rating) -> Int {
    switch rating {
    case .maru: 1
    case .nijumaru: 2
    case .hanamaru: 3
    }
  }

  var body: some View {
    TimelineView(.animation(paused: reduceMotion || frozenAt != nil)) { timeline in
      let t = reduceMotion ? 10 : (frozenAt ?? timeline.date.timeIntervalSince(started))
      ZStack {
        Color.black.opacity(0.42).ignoresSafeArea()
        VStack(spacing: 24) {
          ZStack {
            HanamaruMark(rating: rating, progress: min(max(t / 0.45, 0), 1), petalsShown: t > 0.45)
            Text(String(char))
              .font(.learning(150))
              .foregroundStyle(.white)
              .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
              .opacity(min(max((t - 0.1) / 0.3, 0), 1))
          }
          .frame(width: 320, height: 320)
          HStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { index in
              let shown = index < Self.stars(rating)
              let appear = min(max((t - 0.5 - Double(index) * 0.15) / 0.25, 0), 1)
              Image(systemName: shown ? "star.fill" : "star")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(shown ? Theme.yellow : Color.white.opacity(0.5))
                .scaleEffect(shown ? 0.4 + 0.6 * appear + 0.25 * sin(appear * .pi) : 1)
                .opacity(shown ? appear : 1)
            }
          }
          .accessibilityHidden(true)
          Text(Self.praise(rating))
            .font(.ui(64, bold: true))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
            .scaleEffect(0.8 + 0.2 * min(max((t - 0.4) / 0.3, 0), 1))
            .opacity(min(max((t - 0.4) / 0.3, 0), 1))
        }
        if !reduceMotion { Confetti(time: t) }
      }
    }
    .contentShape(.rect)
    .onTapGesture(perform: onTap)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Self.praise(rating))
    .accessibilityAddTraits(.isButton)
    .transition(.opacity)
  }
}

/// 赤い大きな丸。ぐるっと描く。はなまるは外にはなびら、にじゅうまるは二重の丸。
private struct HanamaruMark: View {
  var rating: Rating
  var progress: Double
  var petalsShown: Bool

  var body: some View {
    ZStack {
      if rating == .hanamaru {
        // はなびら（外の丸）。
        ForEach(0..<10, id: \.self) { index in
          let angle = Double(index) / 10 * 2 * .pi
          Circle()
            .stroke(Theme.red, lineWidth: 10)
            .frame(width: 66, height: 66)
            .offset(x: cos(angle) * 132, y: sin(angle) * 132)
            .scaleEffect(petalsShown ? 1 : 0.2)
            .opacity(petalsShown ? 1 : 0)
            .animation(
              .spring(duration: 0.4, bounce: 0.4).delay(Double(index) * 0.02), value: petalsShown)
        }
      }
      Circle()
        .trim(from: 0, to: progress)
        .stroke(Theme.red, style: StrokeStyle(lineWidth: 26, lineCap: .round))
        .rotationEffect(.degrees(-90))
        .frame(width: rating == .hanamaru ? 200 : 270, height: rating == .hanamaru ? 200 : 270)
      if rating == .nijumaru {
        Circle()
          .trim(from: 0, to: progress)
          .stroke(Theme.red, style: StrokeStyle(lineWidth: 18, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .frame(width: 200, height: 200)
      }
    }
  }
}

/// 紙ふぶき（SwiftUI の Canvas。1秒ちょっとで落ちる）。決まった式で動かすので、同じ時刻なら同じ絵になる。
private struct Confetti: View {
  var time: Double
  private static let count = 70
  private static let lifetime = 1.6

  /// 0〜1 のばらつき（添字と種類で決まる）。
  private static func random(_ index: Int, _ kind: Int) -> Double {
    let x = sin(Double(index * 131 + kind * 977)) * 43758.5453
    return x - floor(x)
  }

  var body: some View {
    Canvas { context, size in
      guard time < Self.lifetime else { return }
      for index in 0..<Self.count {
        let delay = Self.random(index, 1) * 0.25
        let local = time - delay
        guard local > 0 else { continue }
        let startX = Self.random(index, 2) * size.width
        let speed = size.height * (0.55 + 0.4 * Self.random(index, 3))
        let x = startX + sin(local * 4 + Self.random(index, 4) * 6) * 24
        let y = -30 + local * speed * 1.1
        let fade = min(1, max(0, (Self.lifetime - time) / 0.5))
        let side = 12 + 10 * Self.random(index, 5)
        var piece = context
        piece.opacity = fade
        piece.translateBy(x: x, y: y)
        piece.rotate(by: .radians(local * (3 + 4 * Self.random(index, 6)) + Self.random(index, 7)))
        let color = Theme.confetti[index % Theme.confetti.count]
        if index % 3 == 0 {
          piece.fill(
            Path(
              ellipseIn: CGRect(x: -side / 2, y: -side / 2, width: side * 0.8, height: side * 0.8)),
            with: .color(color))
        } else {
          piece.fill(
            Path(CGRect(x: -side / 2, y: -side / 4, width: side, height: side / 2)),
            with: .color(color))
        }
      }
    }
    .allowsHitTesting(false)
    .ignoresSafeArea()
  }
}

/// 画の数の点（D152）。書いた画の分だけ色づく。
struct StrokeDots: View {
  var total: Int
  var done: Int

  var body: some View {
    HStack(spacing: 14) {
      ForEach(0..<total, id: \.self) { index in
        let filled = index < done
        Text("\(index + 1)")
          .font(.ui(22, bold: true))
          .foregroundStyle(filled ? Color.white : Theme.inkSoft)
          .frame(width: 44, height: 44)
          .background(filled ? Theme.pink : Color.white.opacity(0.8), in: .circle)
          .overlay(Circle().stroke(filled ? Theme.pink : Theme.inkSoft.opacity(0.5), lineWidth: 3))
          .scaleEffect(filled ? 1 : 0.9)
          .animation(.spring(duration: 0.3, bounce: 0.5), value: filled)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(total)かく のうち \(done)かく")
  }
}
