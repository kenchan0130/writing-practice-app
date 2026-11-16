import AVFoundation
import SoundKit

/// 効果音を鳴らす（§3.9・D76）。ほかのアプリの音を止めない `.ambient` にする。
/// おとなしモードでは鳴らさない。音が出なくても、子どもの画面にはエラーを出さない（D117）。
final class SoundPlayer {
  static let shared = SoundPlayer()

  enum Effect: Hashable {
    case stroke(Int)
    case praise
    case tap
  }

  private let engine = AVAudioEngine()
  private let player = AVAudioPlayerNode()
  private let format = AVAudioFormat(standardFormatWithSampleRate: Tones.sampleRate, channels: 1)!
  private var cache: [Effect: AVAudioPCMBuffer] = [:]
  private var started = false
  /// 最後に鳴らした音（確かめ用）。
  private(set) var lastPlayed: Effect?

  private init() {
    engine.attach(player)
    engine.connect(player, to: engine.mainMixerNode, format: format)
  }

  func play(_ effect: Effect) {
    let store = ProgressStore.shared
    guard !store.quietMode, store.effectVolume > 0, let buffer = buffer(for: effect) else { return }
    guard start() else { return }
    player.volume = Float(store.effectVolume)
    player.scheduleBuffer(buffer, at: nil, options: [])
    if !player.isPlaying { player.play() }
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

  private func buffer(for effect: Effect) -> AVAudioPCMBuffer? {
    if let cached = cache[effect] { return cached }
    let samples: [Float] =
      switch effect {
      case .stroke(let i): Tones.stroke(i)
      case .praise: Tones.praise()
      case .tap: Tones.tap()
      }
    guard
      let buffer = AVAudioPCMBuffer(
        pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)),
      let channel = buffer.floatChannelData?[0]
    else { return nil }
    buffer.frameLength = AVAudioFrameCount(samples.count)
    samples.withUnsafeBufferPointer { channel.update(from: $0.baseAddress!, count: samples.count) }
    cache[effect] = buffer
    return buffer
  }
}
