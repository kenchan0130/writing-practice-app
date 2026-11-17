import AVFoundation
import SoundKit

/// 効果音を鳴らす（§3.9・D76・D149）。ほかのアプリの音を止めない `.ambient` にする。
/// おとなしモードでは鳴らさない。音が出なくても、子どもの画面にはエラーを出さない（D117）。
/// ド→レ→ミなどの単純な音は SoundKit で作り、鳴き声や物の音は配布素材（Opus の CAF。
/// `Resources/Sounds`、出どころは `Content/Sounds/provenance.csv`）を起動時に読み込んで鳴らす。
final class SoundPlayer {
  static let shared = SoundPlayer()

  enum Effect: Hashable {
    case stroke(Int)
    case praise
    case tap
    /// ことばごとの変身の音（鳴き声・乗り物・服）。
    case word(String)
    /// 粒が物の形に集まる。
    case gather
    /// 物ができあがる。
    case appear
    /// 1字書けたごほうび。
    case sparkle
    case confetti
    /// ダイアログがふわっと出る。
    case dialog
    /// 鍵のかかったものを押した（やさしい「ぼよん」）。
    case locked

    /// 素材のファイル名（拡張子なし）。素材のない音は nil。
    var sampleName: String? {
      switch self {
      case .stroke, .praise: nil
      case .tap: "tap"
      case .word(let text): SoundPlayer.wordSamples[text]
      case .gather: "gather"
      case .appear: "appear"
      case .sparkle: "sparkle"
      case .confetti: "confetti"
      case .dialog: "dialog"
      case .locked: "locked"
      }
    }
  }

  /// ことば → 素材のファイル名。
  static let wordSamples: [String: String] = [
    "そり": "word_sori", "くるま": "word_kuruma", "ふね": "word_fune", "でんしゃ": "word_densha",
    "じてんしゃ": "word_jitensha", "しんかんせん": "word_shinkansen",
    "うし": "word_ushi", "いぬ": "word_inu", "ねこ": "word_neko", "うま": "word_uma",
    "くま": "word_kuma", "しか": "word_shika", "りす": "word_risu",
    "ふく": "word_fuku", "くつ": "word_kutsu", "ぼうし": "word_boushi", "ゆかた": "word_yukata",
    "くつした": "word_kutsushita", "きもの": "word_yukata",
  ]

  private static let sampleRate = 48_000.0
  /// 重なって鳴らせる数（ごほうびの星の音と紙ふぶきなど）。
  private static let voices = 4

  private let engine = AVAudioEngine()
  private let toneFormat = AVAudioFormat(
    standardFormatWithSampleRate: Tones.sampleRate, channels: 1)!
  private let sampleFormat = AVAudioFormat(
    standardFormatWithSampleRate: SoundPlayer.sampleRate, channels: 1)!
  private let tonePlayer = AVAudioPlayerNode()
  private var samplePlayers: [AVAudioPlayerNode] = []
  private var nextVoice = 0
  private var cache: [Effect: AVAudioPCMBuffer] = [:]
  /// 素材のバッファ（ファイル名 → バッファ）。
  private var samples: [String: AVAudioPCMBuffer] = [:]
  private var started = false
  /// 最後に鳴らした音（確かめ用）。
  private(set) var lastPlayed: Effect?

  private init() {
    engine.attach(tonePlayer)
    engine.connect(tonePlayer, to: engine.mainMixerNode, format: toneFormat)
    for _ in 0..<Self.voices {
      let node = AVAudioPlayerNode()
      engine.attach(node)
      engine.connect(node, to: engine.mainMixerNode, format: sampleFormat)
      samplePlayers.append(node)
    }
    loadSamples()
  }

  /// 起動時に呼ぶ。素材を読み込んで、すぐ鳴らせるようにしておく（D111）。
  func preload() {}

  /// 素材を全部読み込む（約200KB。読めなかった音は鳴らさない）。
  private func loadSamples() {
    var names = Set(Self.wordSamples.values)
    for name in ["tap", "gather", "appear", "sparkle", "confetti", "dialog", "locked"] {
      names.insert(name)
    }
    for name in names {
      guard let url = Bundle.main.url(forResource: name, withExtension: "caf"),
        let file = try? AVAudioFile(forReading: url),
        let buffer = AVAudioPCMBuffer(
          pcmFormat: sampleFormat, frameCapacity: AVAudioFrameCount(file.length)),
        file.processingFormat.sampleRate == Self.sampleRate,
        file.processingFormat.channelCount == 1,
        (try? file.read(into: buffer)) != nil
      else { continue }
      samples[name] = buffer
    }
  }

  func play(_ effect: Effect) {
    let store = ProgressStore.shared
    guard !store.quietMode, store.effectVolume > 0 else { return }
    let volume = Float(store.effectVolume)
    if let name = effect.sampleName, let buffer = samples[name] {
      guard start() else { return }
      let node = samplePlayers[nextVoice]
      nextVoice = (nextVoice + 1) % samplePlayers.count
      node.volume = volume
      node.scheduleBuffer(buffer, at: nil, options: .interrupts)
      if !node.isPlaying { node.play() }
    } else if let buffer = toneBuffer(for: effect) {
      guard start() else { return }
      tonePlayer.volume = volume
      tonePlayer.scheduleBuffer(buffer, at: nil, options: [])
      if !tonePlayer.isPlaying { tonePlayer.play() }
    } else {
      return
    }
    lastPlayed = effect
    #if DEBUG
      NSLog("[sound] %@", String(describing: effect))
    #endif
  }

  private func start() -> Bool {
    if started, engine.isRunning { return true }
    do {
      try AVAudioSession.sharedInstance().setCategory(.ambient)
      try AVAudioSession.sharedInstance().setActive(true)
      try engine.start()
      started = true
      return true
    } catch {
      return false
    }
  }

  /// 素材のない音（と、素材が読めなかった `.tap`）は、プログラムで作った音を使う。
  private func toneBuffer(for effect: Effect) -> AVAudioPCMBuffer? {
    if let cached = cache[effect] { return cached }
    let samples: [Float]
    switch effect {
    case .stroke(let i): samples = Tones.stroke(i)
    case .praise: samples = Tones.praise()
    case .tap: samples = Tones.tap()
    default: return nil
    }
    guard
      let buffer = AVAudioPCMBuffer(
        pcmFormat: toneFormat, frameCapacity: AVAudioFrameCount(samples.count)),
      let channel = buffer.floatChannelData?[0]
    else { return nil }
    buffer.frameLength = AVAudioFrameCount(samples.count)
    samples.withUnsafeBufferPointer { channel.update(from: $0.baseAddress!, count: samples.count) }
    cache[effect] = buffer
    return buffer
  }
}
