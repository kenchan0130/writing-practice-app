import JudgeKit
import RecordKit
import SwiftUI

/// はじめての流れの前半: おとなの設定（D23。約1分）。
/// おとなだけが見る画面なので、ふつうの日本語で書く（D157）。どの画面も飛ばせる。
struct OnboardingAdultView: View {
  var onFinish: () -> Void

  private enum Page: Int, CaseIterable {
    case profile
    case judge
    case parentArea
    case handoff
  }

  @Bindable private var store = ProgressStore.shared
  @State private var page = Page.profile
  @State private var profile: Profile = ProgressStore.shared.currentProfile
    ?? Profile(name: "", face: ProgressStore.faces[0])

  var body: some View {
    VStack(spacing: 0) {
      pageDots
        .padding(.top, 24)
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          switch page {
          case .profile: profilePage
          case .judge: judgePage
          case .parentArea: parentAreaPage
          case .handoff: handoffPage
          }
        }
        .frame(maxWidth: 680, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
      }
      .scrollBounceBehavior(.basedOnSize)
      buttons
        .frame(maxWidth: 680)
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
    .foregroundStyle(Theme.ink)
  }

  // MARK: - 進み具合

  private var pageDots: some View {
    HStack(spacing: 10) {
      ForEach(Page.allCases, id: \.rawValue) { item in
        Circle()
          .fill(item == page ? Theme.accent : Theme.accent.opacity(0.25))
          .frame(width: 12, height: 12)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(page.rawValue + 1) / \(Page.allCases.count)")
  }

  // MARK: - 1 お子さんのプロフィール

  private var profilePage: some View {
    Group {
      VStack(alignment: .leading, spacing: 8) {
        Text("おとなのひとと いっしょに はじめてね")
          .font(.largeTitle.bold())
          .accessibilityAddTraits(.isHeader)
        Text("最初に、お子さんのことを教えてください。どれも飛ばせて、あとから保護者用の画面で変えられます。")
          .foregroundStyle(.secondary)
      }
      VStack(alignment: .leading, spacing: 12) {
        Text("呼び名").font(.headline)
        TextField("ひらがなで（例: ゆうと）", text: $profile.name)
          .textFieldStyle(.roundedBorder)
          .font(.title3)
          .autocorrectionDisabled()
          .accessibilityIdentifier("onboardingNickname")
        Picker("呼び名の敬称", selection: $profile.honorific) {
          ForEach(Profile.Honorific.allCases, id: \.self) { honorific in
            Text(honorific == .none ? "なし" : honorific.suffix).tag(honorific)
          }
        }
        .pickerStyle(.segmented)
        if !profile.displayName.isEmpty {
          Text("画面では「\(profile.displayName)」と出ます（声では読みません）。")
            .font(.footnote).foregroundStyle(.secondary)
        }
      }
      VStack(alignment: .leading, spacing: 12) {
        Text("顔").font(.headline)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 12)], spacing: 12) {
          ForEach(ProgressStore.faces, id: \.self) { face in
            Button {
              profile.face = face
            } label: {
              ProfileFace(face: face, size: 64)
                .overlay {
                  if profile.face == face {
                    Circle().stroke(Theme.accent, lineWidth: 5).padding(-4)
                  }
                }
                .frame(width: 76, height: 76)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(face)
            .accessibilityAddTraits(profile.face == face ? .isSelected : [])
          }
        }
      }
      VStack(alignment: .leading, spacing: 12) {
        Text("利き手").font(.headline)
        Picker("利き手", selection: $profile.handedness) {
          Text("右").tag(Profile.Handedness.right)
          Text("左").tag(Profile.Handedness.left)
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("onboardingHandedness")
      }
    }
  }

  // MARK: - 2 判定のきびしさ

  private var judgePage: some View {
    Group {
      VStack(alignment: .leading, spacing: 8) {
        Text("判定の厳しさ").font(.largeTitle.bold())
          .accessibilityAddTraits(.isHeader)
        Text("迷ったときは「はじめて」のままで大丈夫です。上達したら、保護者用の画面でお知らせします。")
          .foregroundStyle(.secondary)
      }
      VStack(spacing: 12) {
        ForEach(JudgePreset.allCases, id: \.self) { preset in
          presetCard(preset)
        }
      }
    }
  }

  private func presetCard(_ preset: JudgePreset) -> some View {
    let selected = store.preset == preset
    return Button {
      store.preset = preset
    } label: {
      HStack(alignment: .top, spacing: 16) {
        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
          .font(.title2)
          .foregroundStyle(selected ? Theme.accent : Color.secondary)
        VStack(alignment: .leading, spacing: 4) {
          Text(preset.title).font(.title3.bold())
          Text(preset.detail).font(.callout).foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
        }
        Spacer(minLength: 0)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(.white.opacity(0.85), in: .rect(cornerRadius: 20))
      .overlay {
        RoundedRectangle(cornerRadius: 20)
          .stroke(selected ? Theme.accent : Color.clear, lineWidth: 3)
      }
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(selected ? .isSelected : [])
    .accessibilityIdentifier("onboardingPreset-\(preset.rawValue)")
  }

  // MARK: - 3 保護者用の画面と iCloud

  private var parentAreaPage: some View {
    Group {
      Text("保護者用の画面").font(.largeTitle.bold())
        .accessibilityAddTraits(.isHeader)
      HStack(alignment: .center, spacing: 20) {
        Image(systemName: "gearshape")
          .font(.system(size: 44))
          .foregroundStyle(Theme.inkSoft)
          .frame(width: 88, height: 88)
          .background(.white.opacity(0.85), in: .circle)
        VStack(alignment: .leading, spacing: 6) {
          Text("ホーム画面の歯車を、2秒間長押しすると開きます。")
            .font(.title3.bold())
          Text("お子さんが間違って開かないように、かけ算の確認があります。学習記録や判定の変更は、ここから行います。")
            .foregroundStyle(.secondary)
        }
      }
      HStack(alignment: .center, spacing: 20) {
        Image(systemName: "person.2.fill")
          .font(.system(size: 40))
          .foregroundStyle(Theme.inkSoft)
          .frame(width: 88, height: 88)
          .background(.white.opacity(0.85), in: .circle)
        Text("ほかのお子さんは、保護者用の画面の「子どもたち」から追加できます（最大6人）。")
      }
      VStack(alignment: .leading, spacing: 12) {
        Label("記録は この iPad と あなたの iCloud にだけ保存します", systemImage: "lock.fill")
          .font(.headline)
        Toggle("iCloud に保存する", isOn: $store.syncsWithICloud)
          .accessibilityIdentifier("onboardingICloud")
        Text("切り替えは、次にアプリを開いたときから効きます。あとから「学習記録の管理」で変えられます。")
          .font(.footnote).foregroundStyle(.secondary)
      }
      .padding(16)
      .background(.white.opacity(0.85), in: .rect(cornerRadius: 20))
    }
  }

  // MARK: - 4 わたす

  private var handoffPage: some View {
    VStack(spacing: 24) {
      Image(systemName: "ipad.and.arrow.forward")
        .font(.system(size: 96))
        .foregroundStyle(Theme.accent)
        .accessibilityHidden(true)
      Text("お子さんに iPad をわたしてください")
        .font(.largeTitle.bold())
        .multilineTextAlignment(.center)
        .accessibilityAddTraits(.isHeader)
      Text("ここからは、お子さんが自分で進めます。")
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 40)
  }

  // MARK: - ボタン

  private var buttons: some View {
    HStack(spacing: 16) {
      if page != .profile, page != .handoff {
        Button("もどる") { move(by: -1) }
          .buttonStyle(.bordered)
          .controlSize(.extraLarge)
      }
      Spacer()
      switch page {
      case .profile:
        Button("あとで設定する") { move(by: 1) }
          .buttonStyle(.bordered)
          .controlSize(.extraLarge)
          .accessibilityIdentifier("onboardingSkip")
        Button("次へ") {
          store.updateProfile(profile)
          move(by: 1)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .tint(Theme.accent)
        .foregroundStyle(.white)
        .accessibilityIdentifier("onboardingNext")
      case .judge:
        Button("あとで設定する") { move(by: 1) }
          .buttonStyle(.bordered)
          .controlSize(.extraLarge)
          .accessibilityIdentifier("onboardingSkip")
        Button("次へ") { move(by: 1) }
          .buttonStyle(.borderedProminent)
          .controlSize(.extraLarge)
          .tint(Theme.accent)
        .foregroundStyle(.white)
          .accessibilityIdentifier("onboardingNext")
      case .parentArea:
        Button("次へ") { move(by: 1) }
          .buttonStyle(.borderedProminent)
          .controlSize(.extraLarge)
          .tint(Theme.accent)
        .foregroundStyle(.white)
          .accessibilityIdentifier("onboardingNext")
      case .handoff:
        Button("はじめる") {
          store.finishAdultOnboarding()
          onFinish()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .tint(Theme.accent)
        .foregroundStyle(.white)
        .accessibilityIdentifier("onboardingStart")
        Spacer()
      }
    }
  }

  private func move(by delta: Int) {
    guard let next = Page(rawValue: page.rawValue + delta) else { return }
    withAnimation(.easeInOut(duration: 0.2)) { page = next }
  }
}
