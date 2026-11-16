import ParentGateKit
import SwiftUI

/// M0 前半の仮の入口（D135）。画面の行き来（D101）は M0 の画面の表を作ってから入れる。
struct ContentView: View {
  enum Screen: String, CaseIterable {
    case letter = "1もじ"
    case word = "ことば"
    case town = "まち"
  }

  @State private var screen: Screen = {
    #if DEBUG
      if let name = UserDefaults.standard.string(forKey: "screen"),
        let screen = Screen.allCases.first(where: { "\($0)" == name })
      {
        return screen
      }
    #endif
    return .letter
  }()

  @State private var gate = ParentGate(random: { Double.random(in: 0..<1) })
  @State private var showsGate = false
  @State private var showsParentArea = false
  @State private var showsProfilePicker = false
  /// 子どもの切り替えのために保護者用の確認を出しているか。
  @State private var gateForSwitch = false
  private let store = ProgressStore.shared

  var body: some View {
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
          ProfileFace(face: store.currentProfile?.face ?? ProgressStore.faces[0], size: 44)
        }
        .accessibilityLabel("つかう こを かえる")
        Picker("画面", selection: $screen) {
          ForEach(Screen.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
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
      switch screen {
      case .letter: WritingCanvasView()
      case .word: WordWritingView(onShowTown: { screen = .town })
      case .town: TownView()
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

  private func openParentArea() {
    if gate.isOpen(at: Date().timeIntervalSince1970) {
      showsParentArea = true
    } else {
      showsGate = true
    }
  }
}

#Preview {
  ContentView()
}
