import Observation
import SwiftUI

/// 子どもの画面のダイアログ（D155）。iPadOS 標準の `alert`・`confirmationDialog`・シートは使わず、
/// 角の丸いカード・キャラクターと短い言葉・大きなボタン・ふわっと出る動き・暗い後ろで出す。
/// 画面のどこからでも `PopPresenter.shared` で出し、いちばん上の `PopHost` が描く。
@MainActor
@Observable
final class PopPresenter {
  static let shared = PopPresenter()

  private(set) var id: String?
  private(set) var content: AnyView?
  /// 後ろを押して閉じてよいか（害のないものだけ true）。
  private(set) var dismissesOnBackdrop = false
  private var onDismiss: (() -> Void)?

  /// ダイアログを出す。`id` が同じものを出し直すと置きかえる。
  func show<Content: View>(
    id: String, dismissesOnBackdrop: Bool = false, onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.id = id
    self.content = AnyView(content())
    self.dismissesOnBackdrop = dismissesOnBackdrop
    self.onDismiss = onDismiss
  }

  /// `id` のダイアログを閉じる（ほかのダイアログに置きかわっていたら何もしない）。
  func dismiss(id: String) {
    guard self.id == id else { return }
    clear()
  }

  /// 後ろを押して閉じたとき。
  fileprivate func backdropTapped() {
    guard dismissesOnBackdrop else { return }
    let handler = onDismiss
    clear()
    handler?()
  }

  private func clear() {
    id = nil
    content = nil
    onDismiss = nil
  }

  /// 短い言葉と、ボタン1つの案内（鍵の字など。D150）。
  func notice(_ message: String, button: String = "わかった") {
    show(id: "notice") {
      PopMessage(message: message, buttonTitle: button) { [weak self] in
        self?.dismiss(id: "notice")
      }
    }
  }
}

/// いちばん上に置く。ダイアログがあるときだけ、暗い後ろとカードを出す。
struct PopHost: View {
  private let presenter = PopPresenter.shared
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    ZStack {
      if let content = presenter.content {
        Color.black.opacity(0.42)
          .ignoresSafeArea()
          .contentShape(.rect)
          .onTapGesture { presenter.backdropTapped() }
          .transition(.opacity)
          .accessibilityHidden(true)
        content
          .padding(32)
          .frame(maxWidth: 600)
          .background(Theme.paper, in: .rect(cornerRadius: 44))
          .overlay(
            RoundedRectangle(cornerRadius: 44).stroke(Theme.accent.opacity(0.7), lineWidth: 5)
          )
          .softShadow(Theme.Shadow(color: .black.opacity(0.25), radius: 20, y: 10))
          .padding(24)
          .accessibilityElement(children: .contain)
          .accessibilityAddTraits(.isModal)
          .transition(
            reduceMotion ? .opacity : .scale(scale: 0.6).combined(with: .opacity)
          )
          .id(presenter.id)
      }
    }
    .animation(
      reduceMotion ? .easeOut(duration: 0.15) : .spring(duration: 0.4, bounce: 0.45),
      value: presenter.id)
  }
}

/// キャラクターと短い言葉と、大きなボタン1つ。
struct PopMessage: View {
  var message: String
  var buttonTitle: String
  var action: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: "pawprint.fill")
        .font(.system(size: 52))
        .foregroundStyle(.white)
        .frame(width: 104, height: 104)
        .background(Theme.pink.gradient, in: .circle)
        .softShadow()
        .accessibilityHidden(true)
      Text(message)
        .font(.ui(34, bold: true))
        .foregroundStyle(Theme.ink)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
      Button(action: action) { Text(buttonTitle) }
        .buttonStyle(PillButtonStyle(color: Theme.green, minWidth: 240))
        .accessibilityIdentifier("popDialogButton")
    }
  }
}
