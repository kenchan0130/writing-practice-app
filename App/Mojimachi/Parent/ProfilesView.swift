import RecordKit
import SwiftUI

/// 保護者用の画面の「子どもたち」（D16・D19・§5.3）。
struct ProfilesView: View {
  @Bindable private var store = ProgressStore.shared
  @State private var editing: Profile?

  var body: some View {
    Form {
      Section {
        ForEach(store.profiles.profiles) { profile in
          Button {
            editing = profile
          } label: {
            HStack(spacing: 16) {
              ProfileFace(face: profile.face, size: 44)
              VStack(alignment: .leading) {
                Text(profile.displayName.isEmpty ? "（呼び名なし）" : profile.displayName)
                Text("きょうの もくひょう \(profile.dailyGoal) 字").font(.caption)
                  .foregroundStyle(.secondary)
              }
              Spacer()
              if profile.id == store.currentProfileID {
                Text("いつも使う子").font(.caption.bold()).foregroundStyle(.tint)
              }
            }
          }
          .foregroundStyle(.primary)
        }
        if store.profiles.canAdd {
          Button("子どもを足す", systemImage: "plus") {
            let used = Set(store.profiles.profiles.map(\.face))
            let face = ProgressStore.faces.first { !used.contains($0) } ?? ProgressStore.faces[0]
            editing = Profile(name: "", face: face)
          }
        }
      } footer: {
        Text("6人まで登録できます。記録は子どもごとに分けて保存します。")
      }
      Section {
        Toggle("子どもの切り替えに確認を求める", isOn: $store.confirmsProfileSwitch)
      } footer: {
        Text("オンにすると、子どもを切り替えるときに保護者用の確認が出ます。")
      }
    }
    .navigationTitle("子どもたち")
    .sheet(item: $editing) { profile in
      NavigationStack {
        ProfileEditor(
          profile: profile, isNew: store.profiles.profile(profile.id) == nil,
          onDone: { editing = nil })
      }
    }
  }
}

/// プロフィールの追加・編集。
private struct ProfileEditor: View {
  @State var profile: Profile
  var isNew: Bool
  var onDone: () -> Void
  private let store = ProgressStore.shared

  var body: some View {
    Form {
      Section("呼び名") {
        TextField("ひらがなで（例: ゆうと）", text: $profile.name)
        Picker("つけることば", selection: $profile.honorific) {
          ForEach(Profile.Honorific.allCases, id: \.self) { h in
            Text(h == .none ? "なし" : h.suffix).tag(h)
          }
        }
        .pickerStyle(.segmented)
        if !profile.displayName.isEmpty {
          Text("画面では「\(profile.displayName)」と出ます（声では読みません）。")
            .font(.caption).foregroundStyle(.secondary)
        }
      }
      Section("顔") {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 12) {
          ForEach(ProgressStore.faces, id: \.self) { face in
            Button {
              profile.face = face
            } label: {
              ProfileFace(face: face, size: 60)
                .overlay {
                  if profile.face == face {
                    Circle().stroke(.tint, lineWidth: 4)
                  }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(face)
          }
        }
      }
      Section {
        Picker("利き手", selection: $profile.handedness) {
          Text("右").tag(Profile.Handedness.right)
          Text("左").tag(Profile.Handedness.left)
        }
        Picker("きょうの もくひょう", selection: $profile.dailyGoal) {
          ForEach(Profile.dailyGoals, id: \.self) { Text("\($0) 字").tag($0) }
        }
      }
      if !isNew {
        Section {
          Button("いつも使う子にする") {
            store.switchProfile(to: profile.id)
            onDone()
          }
          .disabled(store.currentProfileID == profile.id)
        }
        Section {
          HoldToConfirmButton(title: "この子の記録だけ リセット") {
            store.resetRecords(of: profile.id)
            onDone()
          }
          if store.profiles.profiles.count > 1 {
            HoldToConfirmButton(title: "この子を削除") {
              store.deleteProfile(profile.id)
              onDone()
            }
          }
        } footer: {
          Text("どちらも3秒長押しで実行します。リセットしても設定とまちは残ります。削除すると、この子の記録とまちも消えます。")
        }
      }
    }
    .navigationTitle(isNew ? "子どもを足す" : "子どもの設定")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) { Button("やめる", action: onDone) }
      ToolbarItem(placement: .confirmationAction) {
        Button(isNew ? "足す" : "保存") {
          if isNew { store.addProfile(profile) } else { store.updateProfile(profile) }
          onDone()
        }
      }
    }
  }
}

/// プロフィールの顔（仮の絵）。
struct ProfileFace: View {
  var face: String
  var size: CGFloat

  var body: some View {
    Image(systemName: face)
      .font(.system(size: size * 0.5))
      .foregroundStyle(.white)
      .frame(width: size, height: size)
      .background(Color.orange.gradient, in: .circle)
      .accessibilityHidden(true)
  }
}

/// 子どもの画面の、使う子を選ぶシート（顔の大きなボタン。2cm 角以上。D101）。
struct ProfilePicker: View {
  var onPick: (UUID) -> Void
  private let store = ProgressStore.shared

  var body: some View {
    VStack(spacing: 24) {
      Text("だれが かく？").font(.system(size: 36, weight: .bold))
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 24)], spacing: 24) {
        ForEach(store.profiles.profiles) { profile in
          Button {
            onPick(profile.id)
          } label: {
            VStack(spacing: 8) {
              ProfileFace(face: profile.face, size: 120)
              Text(profile.displayName).font(.title3.bold())
            }
            .frame(minWidth: 140, minHeight: 160)
          }
          .buttonStyle(.plain)
          .accessibilityLabel(profile.displayName.isEmpty ? "こども" : profile.displayName)
        }
      }
    }
    .padding(40)
  }
}
