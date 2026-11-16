import ContentModel
import ParentGateKit
import SwiftUI

/// 仮のホームと、画面の行き来（D101）。ホームのボタン3つから入り、「←」でホームへ戻る。
struct ContentView: View {
  enum Screen: String, CaseIterable {
    case letter = "もじ"
    case word = "ことば"
    case town = "まち"
    case closet = "クローゼット"
  }

  /// nil はホーム。
  @State private var screen: Screen? = {
    #if DEBUG
      // 確かめ用: `-screen word|town|letter|closet` でその画面を直接開く。
      if let name = UserDefaults.standard.string(forKey: "screen"),
        let screen = Screen.allCases.first(where: { "\($0)" == name })
      {
        return screen
      }
    #endif
    return nil
  }()

  @State private var activity = WritingActivity()
  @State private var gate = ParentGate(random: { Double.random(in: 0..<1) })
  @State private var showsGate = false
  @State private var showsParentArea = false
  @State private var showsProfilePicker = false
  /// 子どもの切り替えのために保護者用の確認を出しているか。
  @State private var gateForSwitch = false
  private let store = ProgressStore.shared

  var body: some View {
    Group {
      if let screen {
        VStack(spacing: 0) {
          HStack {
            BackButton(activity: activity) { self.screen = nil }
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
    .sheet(isPresented: $showsGate) {
      ParentGateSheet(
        gate: $gate,
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
    .sheet(isPresented: $showsProfilePicker) {
      ProfilePicker { id in
        store.switchProfile(to: id)
        showsProfilePicker = false
      }
    }
    .fullScreenCover(isPresented: $showsParentArea) {
      ParentAreaView {
        gate.close()
        showsParentArea = false
      }
    }
    #if DEBUG
      .onAppear {
        if UserDefaults.standard.bool(forKey: "showGate") { showsGate = true }
        if UserDefaults.standard.string(forKey: "openParent") != nil {
          DebugSeed.records()
          showsParentArea = true
        }
      }
    #endif
  }

  @ViewBuilder
  private func content(_ screen: Screen) -> some View {
    switch screen {
    case .letter: WritingCanvasView(activity: activity)
    case .word:
      WordWritingView(activity: activity) { kind in
        self.screen = kind == .clothes ? .closet : .town
      }
    case .town: TownView()
    case .closet: TownView(layer: .closet)
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
      HStack(spacing: 40) {
        HomeButton(title: "もじ", systemImage: "character.book.closed.fill", color: .orange) {
          screen = .letter
        }
        HomeButton(title: "ことば", systemImage: "text.bubble.fill", color: .blue) {
          screen = .word
        }
        HomeButton(title: "まち", systemImage: "house.fill", color: .green) {
          screen = .town
        }
      }
      .padding(.horizontal, 32)
      Spacer()
    }
  }

  private func openParentArea() {
    if gate.isOpen(at: Date().timeIntervalSince1970) {
      showsParentArea = true
    } else {
      showsGate = true
    }
  }
}

/// ホームの大きなボタン（約104pt 以上。D101）。
private struct HomeButton: View {
  var title: String
  var systemImage: String
  var color: Color
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 16) {
        Image(systemName: systemImage).font(.system(size: 72, weight: .bold))
        Text(title).font(.system(size: 36, weight: .bold))
      }
      .foregroundStyle(.white)
      .frame(maxWidth: 280, minHeight: 240)
      .frame(maxWidth: .infinity)
      .background(color.gradient, in: .rect(cornerRadius: 36))
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  ContentView()
}
