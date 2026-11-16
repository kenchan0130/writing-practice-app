import Foundation

/// プログラムで作る単純な効果音（§3.9・D115）。音の波形だけを作り、鳴らすのはアプリが受け持つ。
public enum Tones {
  public static let sampleRate = 44_100.0

  /// ドレミ（ハ長調。ド = C5）の周波数。
  public static let scale: [Double] = [523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77]

  /// `index` 画目（0 から）の音。ド→レ→ミと高くなり、7画をこえたら1オクターブ上に続ける。
  public static func strokeFrequency(_ index: Int) -> Double {
    let i = max(index, 0)
    return scale[i % scale.count] * pow(2, Double(i / scale.count))
  }

  /// 1つの音。やわらかく始まり、すっと消える（耳に痛くないように、立ち上がりを 5ms とる）。
  public static func note(frequency: Double, duration: Double, volume: Double = 0.5) -> [Float] {
    let count = Int(duration * sampleRate)
    guard count > 0 else { return [] }
    let attack = Int(0.005 * sampleRate)
    return (0..<count).map { i in
      let t = Double(i) / sampleRate
      let envelope =
        i < attack ? Double(i) / Double(attack) : exp(-4 * Double(i - attack) / Double(count))
      // 基本の音に、少しだけ倍音を足して木琴のような音にする。
      let wave = sin(2 * .pi * frequency * t) + 0.25 * sin(4 * .pi * frequency * t)
      return Float(wave / 1.25 * envelope * volume)
    }
  }

  /// 1画書けた音（D54・§3.9）。
  public static func stroke(_ index: Int) -> [Float] {
    note(frequency: strokeFrequency(index), duration: 0.25)
  }

  /// ほめる音（ド・ミ・ソ・ドを順に）。
  public static func praise() -> [Float] {
    [scale[0], scale[2], scale[4], scale[0] * 2].flatMap {
      note(frequency: $0, duration: 0.14)
    } + note(frequency: scale[0] * 2, duration: 0.4)
  }

  /// ボタンの音（短く小さく）。
  public static func tap() -> [Float] {
    note(frequency: scale[4], duration: 0.06, volume: 0.3)
  }
}
