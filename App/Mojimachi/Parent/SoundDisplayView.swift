import SwiftUI

/// 保護者用の画面の「音と表示」（§3.9・§5.3）。
struct SoundDisplayView: View {
  @Bindable private var store = ProgressStore.shared

  var body: some View {
    Form {
      Section {
        volume("声", $store.voiceVolume)
        volume("BGM", $store.bgmVolume)
        volume("効果音", $store.effectVolume)
        Toggle("おとなしモード", isOn: $store.quietMode)
      } header: {
        Text("音")
      } footer: {
        Text("おとなしモードでは、声も含めてすべての音を止めます。iPad が消音のときも音は出ません。")
      }
      Section {
        Toggle("字幕（吹き出し）を出す", isOn: $store.showsSubtitles)
        Picker("お手本の速さ", selection: $store.modelSpeed) {
          Text("ゆっくり").tag(ProgressStore.ModelSpeed.slow)
          Text("ふつう").tag(ProgressStore.ModelSpeed.normal)
          Text("はやい").tag(ProgressStore.ModelSpeed.fast)
        }
        Toggle("マスを大きくする", isOn: $store.largeGrid)
      } header: {
        Text("表示")
      }
      Section {
        Toggle("筆圧を使う", isOn: $store.usesPressure)
      } footer: {
        Text("筆圧を取れるペンでは、筆圧で線の太さを変えます。合否には使いません。")
      }
    }
    .navigationTitle("音と表示")
  }

  private func volume(_ title: String, _ value: Binding<Double>) -> some View {
    LabeledContent(title) {
      Slider(value: value, in: 0...1)
        .frame(maxWidth: 320)
        .disabled(store.quietMode)
        .accessibilityLabel("\(title)の音量")
    }
  }
}
