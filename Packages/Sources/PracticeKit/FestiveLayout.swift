import ContentModel

/// 季節の飾りの置き方（§3.4・D53）。
public enum FestiveStyle: String, Sendable, Hashable, CaseIterable {
  /// はた のひもに つるす（うちわ・ふうりん・ちょうちん など）。上を支点に ゆれる。
  case hang
  /// 草の奥に立てる（こいのぼり・ゆきだるま・かどまつ など）。
  case stand
  /// 空にあがる（はなび）。
  case sky
}

/// 季節の飾り ひとつ分の置き場所。画面の絵に頼らない普通の値。
public struct FestiveSpot: Equatable, Sendable {
  public let index: Int
  public let style: FestiveStyle
  /// 物の中心の x。
  public let x: Double
  /// つるす物は絵の上のはし、立てる物は足もと、空の物は絵の真ん中の高さ（画面の高さに対する割合。0 が下）。
  public let yFraction: Double
  /// つるす物の、ひもの上のはし（はた のひもの高さ）。ほかは nil。
  public let ropeY: Double?
  public let scale: Double
}

/// はた 1枚（三角の小さな旗）。
public struct FestiveFlag: Equatable, Sendable {
  public let x: Double
  /// 旗の上のはし（ひもの高さ。割合）。
  public let yFraction: Double
  /// 色の番号（0 から `FestiveLayout.flagColors - 1`）。となりの旗とは ちがう色。
  public let color: Int
}

/// まちの上にわたす「おまつりの はた」（柱・ひも・旗）。季節の飾りが 1つでも出ているあいだ出る。
public struct FestiveGarland: Equatable, Sendable {
  /// 柱の x（左から）。となりどうしの柱のあいだに、ひもが たるんで かかる。
  public let poles: [Double]
  /// 柱の上のはしの高さ（割合）。
  public let poleTopY: Double
  public let flags: [FestiveFlag]
}

/// 飾りの ゆれ方（「動きを減らす」がオンなら nil で、止まる）。
public struct FestiveMotion: Equatable, Sendable {
  /// ゆれる角度（ラジアン。左右に この角度まで）。空の物は 0。
  public let angle: Double
  /// 大きさの ゆれ（1 ± この割合）。つるす物・立てる物は 0。
  public let pulse: Double
  /// ひとまわりの秒数。
  public let period: Double
}

/// 季節の飾りの置き場所の決まり（§3.4・D74）。
/// 陸のまちの左がわに、柱を4本立てて はた をわたし、その下に 6つの置き場所を作る。
public enum FestiveLayout {
  /// 出せる数（D74 の ほかの場所と同じく、超えた物は おもちゃばこ）。
  public static let capacity = 6
  /// ひものかかる間（柱と柱のあいだ）の数。1つの間に、置き場所が 2つ。
  public static let spans = 3
  /// はた のわたる幅（画面の何枚分か）と、陸のまちの左はしからの すきま。
  public static let areaScreens = 1.2
  public static let insetScreens = 0.12
  /// 柱の上のはし・足もと（丘と草の境目）の高さ。
  public static let poleTopY = 0.60
  public static let poleBaseY = 0.36
  /// ひもの たるみ（間の真ん中で、柱の上より これだけ低い）。
  public static let sag = 0.045
  /// つるす物の ひもの長さ。
  public static let stringLength = 0.012
  /// 立てる物の足もと（丘と草の境目のすぐ下）。
  public static let standY = 0.352
  /// 空の物の真ん中の高さ。
  public static let skyY = 0.76
  /// 1つの間の旗の数と、色の数。
  public static let flagsPerSpan = 7
  public static let flagColors = 5
  /// 置き場所の、間の中での位置（旗と旗のあいだ）。
  static let spotPositions: [Double] = [0.3125, 0.6875]

  private static let standWords: Set<String> = [
    "こいのぼり", "おひなさま", "たなばた", "すすき", "おつきみ", "かかし", "ゆきだるま", "かがみもち", "かどまつ", "だるま", "かまくら",
    "かぶと", "おみこし", "ゆきうさぎ",
    // めぐり town3（D202）。
    "きんぎょすくい", "やたい", "やぐら", "ぼんぼり", "おとしだま", "おみくじ",
  ]
  private static let skyWords: Set<String> = ["はなび"]
  private static let hangWords: Set<String> = [
    "うちわ", "ふうりん", "ちょうちん", "てるてるぼうず", "ちとせあめ",
    "ほおずき", "おにのめん", "つらら",
    // めぐり town3（D202）。
    "しめかざり",
  ]

  /// そのことばの飾りの置き方。季節の飾りでなければ nil。
  public static func style(for word: String) -> FestiveStyle? {
    if hangWords.contains(word) { return .hang }
    if standWords.contains(word) { return .stand }
    if skyWords.contains(word) { return .sky }
    return nil
  }

  /// はた のわたる はんい（陸のまちの中に収まる）。
  public static func area(landMinX: Double, landWidth: Double, screenWidth: Double)
    -> ClosedRange<Double>
  {
    let inset = min(screenWidth * insetScreens, max(landWidth, 0) / 10)
    let width = max(min(screenWidth * areaScreens, landWidth - inset * 2), 0)
    return (landMinX + inset)...(landMinX + inset + width)
  }

  /// その x での、ひもの高さ（割合）。柱のところが いちばん高く、間の真ん中が いちばん低い。
  public static func ropeY(at x: Double, in area: ClosedRange<Double>) -> Double {
    let span = (area.upperBound - area.lowerBound) / Double(spans)
    guard span > 0 else { return poleTopY }
    let offset = min(max(x - area.lowerBound, 0), area.upperBound - area.lowerBound)
    let t = (offset / span).truncatingRemainder(dividingBy: 1)
    return poleTopY - sag * 4 * t * (1 - t)
  }

  /// 置き場所の x（番号の順。左から）。
  public static func spotX(index: Int, in area: ClosedRange<Double>) -> Double {
    let slot = ((index % capacity) + capacity) % capacity
    let span = (area.upperBound - area.lowerBound) / Double(spans)
    let perSpan = spotPositions.count
    return area.lowerBound + span * (Double(slot / perSpan) + spotPositions[slot % perSpan])
  }

  /// 置き場所。番号（0〜5）と置き方から決まる。同じ番号なら、置き方がちがっても x は同じ（重ならない）。
  public static func spot(index: Int, style: FestiveStyle, in area: ClosedRange<Double>)
    -> FestiveSpot
  {
    let slot = ((index % capacity) + capacity) % capacity
    let x = spotX(index: slot, in: area)
    switch style {
    case .hang:
      let rope = ropeY(at: x, in: area)
      return FestiveSpot(
        index: slot, style: style, x: x, yFraction: rope - stringLength, ropeY: rope, scale: 0.78)
    case .stand:
      return FestiveSpot(
        index: slot, style: style, x: x, yFraction: standY, ropeY: nil, scale: 0.85)
    case .sky:
      return FestiveSpot(index: slot, style: style, x: x, yFraction: skyY, ropeY: nil, scale: 0.95)
    }
  }

  /// 柱と旗。旗は ひもに沿って同じ間で並び、置き場所の真上には来ない。
  public static func garland(in area: ClosedRange<Double>) -> FestiveGarland {
    let span = (area.upperBound - area.lowerBound) / Double(spans)
    let poles = (0...spans).map { area.lowerBound + span * Double($0) }
    var flags: [FestiveFlag] = []
    for s in 0..<spans {
      for k in 1...flagsPerSpan {
        let x = area.lowerBound + span * (Double(s) + Double(k) / Double(flagsPerSpan + 1))
        flags.append(
          FestiveFlag(x: x, yFraction: ropeY(at: x, in: area), color: flags.count % flagColors))
      }
    }
    return FestiveGarland(poles: poles, poleTopY: poleTopY, flags: flags)
  }

  /// 立てる物が まちの横で ふさぐはば（背景の木・家を そこに出さないために使う）。
  public static func standSpan(_ spot: FestiveSpot, objectWidth: Double) -> ClosedRange<Double> {
    let half = objectWidth * spot.scale * 0.45
    return (spot.x - half)...(spot.x + half)
  }

  /// ゆれ方。「動きを減らす」がオンなら nil（止まる）。
  public static func motion(_ style: FestiveStyle, reduceMotion: Bool) -> FestiveMotion? {
    guard !reduceMotion else { return nil }
    switch style {
    case .hang: return FestiveMotion(angle: 0.1, pulse: 0, period: 3.2)
    case .stand: return FestiveMotion(angle: 0.025, pulse: 0, period: 4.4)
    case .sky: return FestiveMotion(angle: 0, pulse: 0.06, period: 2.6)
    }
  }
}
