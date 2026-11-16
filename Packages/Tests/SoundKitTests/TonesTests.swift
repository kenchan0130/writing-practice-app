import Testing

@testable import SoundKit

@Suite("効果音")
struct TonesTests {
  @Test("1画ごとにド→レ→ミと高くなる（§3.9）")
  func rising() {
    let freqs = (0..<10).map(Tones.strokeFrequency)
    #expect(zip(freqs, freqs.dropFirst()).allSatisfy { $0 < $1 })
    #expect(abs(Tones.strokeFrequency(0) - 523.25) < 0.01)
    #expect(abs(Tones.strokeFrequency(7) - 1046.5) < 0.01, "8画目は1オクターブ上のド")
  }

  @Test("音の長さどおりの数の点を作り、大きさは 1 をこえない")
  func lengthAndClip() {
    let samples = Tones.stroke(2)
    #expect(samples.count == Int(0.25 * Tones.sampleRate))
    #expect(samples.allSatisfy { abs($0) <= 1 })
    #expect(samples.contains { abs($0) > 0.1 }, "ちゃんと鳴る")
  }

  @Test("始まりと終わりが小さく、ぷつっと鳴らない")
  func softEdges() {
    let samples = Tones.note(frequency: 440, duration: 0.3)
    #expect(abs(samples[0]) < 0.01)
    let tail = samples.suffix(50).map { abs($0) }.max() ?? 1
    #expect(tail < 0.05)
  }

  @Test("ほめる音は、ふつうの1画の音より長い")
  func praiseIsLonger() {
    #expect(Tones.praise().count > Tones.stroke(0).count)
    #expect(Tones.tap().count < Tones.stroke(0).count)
  }
}
