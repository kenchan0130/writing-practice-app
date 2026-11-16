import AVFoundation
import Observation

/// 声を読み上げる（§3.9・D27・D57）。
/// 仮の実装: AI で作った声のファイル（D115）ができるまで、端末の読み上げ（ja-JP）で代わりにする。
/// ほかのアプリの音を止めない `.ambient`。おとなしモードでは鳴らさない。
/// 字幕（吹き出し）は、設定がオンなら 約2秒 出す。声が出なくても、子どもの画面にはエラーを出さない（D117）。
@Observable
final class VoicePlayer {
  static let shared = VoicePlayer()

  /// 画面に出す字幕。nil なら出さない。
  private(set) var caption: String?
  /// 字幕を出す時間（秒）。
  static let captionSeconds = 2.0

  @ObservationIgnored private let synthesizer = AVSpeechSynthesizer()
  @ObservationIgnored private var captionTask: Task<Void, Never>?

  private init() {}

  func speak(_ text: String) {
    let store = ProgressStore.shared
    guard !text.isEmpty else { return }
    if store.showsSubtitles { showCaption(text) }
    guard !store.quietMode, store.voiceVolume > 0 else { return }
    try? AVAudioSession.sharedInstance().setCategory(.ambient)
    try? AVAudioSession.sharedInstance().setActive(true)
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
    utterance.volume = Float(store.voiceVolume)
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
    utterance.pitchMultiplier = 1.15
    if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
    synthesizer.speak(utterance)
    #if DEBUG
      NSLog("[voice] %@", text)
    #endif
  }

  private func showCaption(_ text: String) {
    caption = text
    captionTask?.cancel()
    captionTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(Self.captionSeconds))
      guard !Task.isCancelled else { return }
      self?.caption = nil
    }
  }
}
