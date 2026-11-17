import SwiftUI

/// 子どもの画面の見た目の決まり（D152・D153）。色・角の丸み・影・書体をここにまとめる。
/// 保護者用の画面（Form・List）は iPad 標準のまま使い、ここは使わない。
enum Theme {
  // MARK: - 色

  /// 画面の背景（温かいクリーム色）。
  static let background = Color(red: 1.0, green: 0.965, blue: 0.87)
  /// 書く場所の紙の色。
  static let paper = Color(red: 1.0, green: 0.99, blue: 0.96)
  /// 文字の色（真っ黒にしない茶色がかった濃い色）。
  static let ink = Color(red: 0.25, green: 0.18, blue: 0.14)
  /// 文字の色（弱め）。
  static let inkSoft = Color(red: 0.25, green: 0.18, blue: 0.14).opacity(0.6)
  /// 主な色（オレンジ）。
  static let accent = Color(red: 0.98, green: 0.58, blue: 0.2)
  /// 書き始めの印・はなまるのピンク。
  static let pink = Color(red: 0.96, green: 0.38, blue: 0.55)
  /// はなまるの赤。
  static let red = Color(red: 0.9, green: 0.25, blue: 0.25)
  static let green = Color(red: 0.36, green: 0.7, blue: 0.4)
  static let blue = Color(red: 0.3, green: 0.6, blue: 0.9)
  static let yellow = Color(red: 1.0, green: 0.8, blue: 0.25)
  /// 紙ふぶきの色。
  static let confetti: [Color] = [pink, yellow, blue, green, accent]

  // MARK: - 角の丸み・影

  enum Radius {
    static let button: CGFloat = 36
    static let card: CGFloat = 28
    static let cell: CGFloat = 16
    static let paper: CGFloat = 24
  }

  /// やわらかい影（ボタン・カードに付ける）。
  struct Shadow {
    var color: Color
    var radius: CGFloat
    var y: CGFloat
    static let soft = Shadow(color: .black.opacity(0.12), radius: 8, y: 4)
  }
}

extension Font {
  /// 字を学ぶところの書体（Klee One。D153）。小さいときは細くて読みにくいので SemiBold にする。
  static func learning(_ size: CGFloat) -> Font {
    .custom(size < 40 ? "KleeOne-SemiBold" : "KleeOne-Regular", fixedSize: size)
  }

  /// ボタン・ラベルなどの書体（Zen Maru Gothic。D153）。`bold` は見出し用。
  static func ui(_ size: CGFloat, bold: Bool = false) -> Font {
    .custom(bold ? "ZenMaruGothic-Bold" : "ZenMaruGothic-Medium", fixedSize: size)
  }
}

extension View {
  /// やわらかい影。
  func softShadow(_ shadow: Theme.Shadow = .soft) -> some View {
    self.shadow(color: shadow.color, radius: shadow.radius, y: shadow.y)
  }

  /// 子どもの画面の背景。
  func childBackground() -> some View {
    background(Theme.background.ignoresSafeArea())
  }
}

/// 大きな丸いボタンの見た目（子どもの画面。押せる部分は 104pt 以上。D101）。
struct PillButtonStyle: ButtonStyle {
  var color: Color = Theme.accent
  var minWidth: CGFloat = 140
  var highlighted = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.ui(28, bold: true))
      .foregroundStyle(.white)
      .padding(.horizontal, 28)
      .frame(minWidth: minWidth, minHeight: 104)
      .background(color, in: .rect(cornerRadius: Theme.Radius.button))
      .softShadow()
      .scaleEffect(configuration.isPressed ? 0.96 : highlighted ? 1.06 : 1)
      .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
  }
}

/// 子どもが押す道具のボタン（絵と短い字。押せる部分は 104pt 以上。D101・D152）。
struct ChildToolButton: View {
  var title: String
  var systemImage: String
  var color: Color = Theme.blue
  var highlighted = false
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 6) {
        Image(systemName: systemImage).font(.system(size: 34, weight: .bold))
        Text(title).font(.ui(22, bold: true))
      }
      .foregroundStyle(.white)
      .padding(.horizontal, 20)
      .frame(minWidth: 120, minHeight: 110)
      .background(color, in: .rect(cornerRadius: Theme.Radius.button))
      .softShadow()
    }
    .buttonStyle(.plain)
    .scaleEffect(highlighted ? 1.08 : 1)
    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: highlighted)
  }
}
