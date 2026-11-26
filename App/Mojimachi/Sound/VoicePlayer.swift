import AVFoundation
import Observation
import SoundKit

/// 声を鳴らす（§3.9・D27・D57・D162）。
/// 声は VOICEVOX（猫使ビィ）で前もって作ってアプリに入れたファイル。文字から、表（voices.json）で探す。
/// ほかのアプリの音を止めない `.ambient`。おとなしモードでは鳴らさない。
/// 字幕（吹き出し）は、設定がオンなら 約2秒 出す。声が出なくても、子どもの画面にはエラーを出さない（D117）。
@Observable
final class VoicePlayer {
  static let shared = VoicePlayer()

  /// 画面に出す字幕。nil なら出さない。
  private(set) var caption: String?
  /// 字幕を出す最も短い時間（秒）。
  static let captionSeconds = UITesting.seconds(2.0, uiTesting: 0.3)

  /// 声の表。読めなければ空（声は出ないが、画面は止めない。D117）。
  let manifest: VoiceManifest
  @ObservationIgnored private var player: AVAudioPlayer?
  @ObservationIgnored private var captionTask: Task<Void, Never>?

  private init() {
    manifest = Self.loadManifest()
  }

  private static func loadManifest() -> VoiceManifest {
    if let url = Bundle.main.url(forResource: "voices", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let manifest = try? VoiceManifest(json: data)
    {
      return manifest
    }
    #if DEBUG
      NSLog("[voice] voices.json が読めません")
    #endif
    return VoiceManifest(engine: "", files: [:])
  }

  /// 声のファイルの場所。なければ nil。
  func url(for text: String) -> URL? {
    guard let name = manifest.fileName(for: text) else { return nil }
    return Bundle.main.url(forResource: name, withExtension: "caf")
  }

  /// 決まった文を言う。
  func speak(_ line: VoiceLine) {
    speak(line.text)
  }

  /// 字・ことばを言う。
  func speak(_ text: String) {
    let store = ProgressStore.shared
    guard !text.isEmpty else { return }
    // 字幕は、声が終わるまで出す（短い声でも 約2秒）。
    let duration = url(for: text).flatMap { try? AVAudioPlayer(contentsOf: $0) }?.duration ?? 0
    if store.showsSubtitles { showCaption(text, seconds: max(Self.captionSeconds, duration + 0.5)) }
    guard !store.quietMode, store.voiceVolume > 0 else { return }
    guard let url = url(for: text) else {
      #if DEBUG
        NSLog("[voice] ⚠️⚠️⚠️ 声のファイルがありません: %@", text)
      #endif
      return
    }
    try? AVAudioSession.sharedInstance().setCategory(.ambient)
    try? AVAudioSession.sharedInstance().setActive(true)
    player?.stop()
    player = try? AVAudioPlayer(contentsOf: url)
    player?.volume = Float(store.voiceVolume)
    player?.play()
    #if DEBUG
      NSLog("[voice] %@", text)
    #endif
  }

  /// 順に言う（しりとり: 「これ！」→ことば、など。D57）。1つ言い終わってから次を言う。
  /// 呼んだ `Task` が取り消されたら、そこで止める。
  func speak(sequence texts: [String]) async {
    for text in texts {
      guard !Task.isCancelled else { return }
      speak(text)
      let duration = url(for: text).flatMap { try? AVAudioPlayer(contentsOf: $0) }?.duration ?? 0.8
      try? await Task.sleep(for: .seconds(duration + 0.2))
    }
  }

  private func showCaption(_ text: String, seconds: Double) {
    caption = text
    captionTask?.cancel()
    captionTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(seconds))
      guard !Task.isCancelled else { return }
      self?.caption = nil
    }
  }
}
