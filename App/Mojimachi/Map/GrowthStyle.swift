import ContentModel
import RecordKit
import SwiftUI

/// 字の育ち方（たね・め・つぼみ・はな。D151）の見た目。色だけに頼らず、形の違う絵も付ける（D36）。
extension GrowthStage {
  var symbol: String {
    switch self {
    case .seed: "circle.fill"
    case .sprout: "leaf.fill"
    case .bud: "drop.fill"
    case .flower: "camera.macro"
    }
  }

  var tint: Color {
    switch self {
    case .seed: Color(red: 0.62, green: 0.48, blue: 0.36)
    case .sprout: Theme.green
    case .bud: Color(red: 0.95, green: 0.55, blue: 0.7)
    case .flower: Theme.pink
    }
  }

  /// 地図のマスの色。
  var fill: Color {
    switch self {
    case .seed: Color.white.opacity(0.75)
    case .sprout: Theme.green.opacity(0.22)
    case .bud: Color(red: 0.95, green: 0.55, blue: 0.7).opacity(0.22)
    case .flower: Theme.yellow.opacity(0.55)
    }
  }
}

extension MapState {
  var fill: Color { growth.fill }
  /// 凡例や読み上げに使う名前（「たね」など）。
  var label: String { growth.name }
}

/// 育ちの小さな絵（マスの角や凡例に置く）。
struct GrowthIcon: View {
  var stage: GrowthStage
  var size: CGFloat

  var body: some View {
    Image(systemName: stage.symbol)
      // たねは小さな点にして、うるさくしない。
      .font(.system(size: stage == .seed ? size * 0.45 : size, weight: .bold))
      .foregroundStyle(stage.tint)
      .frame(width: size, height: size)
      .accessibilityHidden(true)
  }
}

/// 行の字がすべて「はな」になった印（はなばたけ。D151）。
struct GardenMarker: View {
  var size: CGFloat = 32

  var body: some View {
    HStack(spacing: 0) {
      Image(systemName: "camera.macro").foregroundStyle(Theme.pink)
      Image(systemName: "camera.macro").foregroundStyle(Theme.yellow)
      Image(systemName: "camera.macro").foregroundStyle(Theme.pink)
    }
    .font(.system(size: size * 0.6, weight: .bold))
    .frame(height: size)
    .accessibilityElement()
    .accessibilityLabel("はなばたけ")
  }
}

/// 文字の種類ごとの育ち（「ひらがなの ふたば」。D151）。「はな」の数と字の数で決める。
struct ScriptGrowthSummary: Equatable {
  var script: KanaScript
  var flowers: Int
  var total: Int
  var stage: ScriptGrowth

  init(script: KanaScript, log: LearningLog) {
    let ids = KanaTable.all(script).compactMap { KanaTable.characterID($0, script: script) }
    let states = ids.map { log.mapState(of: $0) }
    self.script = script
    flowers = states.filter { $0 == .wroteAlone }.count
    total = ids.count
    stage = ScriptGrowth.stage(flowers: flowers, total: total)
  }

  /// 「ひらがなの たね」。
  var title: String { "\(script.title)の \(stage.name)" }

  var symbol: String {
    switch stage {
    case .seed: GrowthStage.seed.symbol
    case .sprout2: GrowthStage.sprout.symbol
    case .bud: GrowthStage.bud.symbol
    case .garden: GrowthStage.flower.symbol
    }
  }

  var tint: Color {
    switch stage {
    case .seed: GrowthStage.seed.tint
    case .sprout2: GrowthStage.sprout.tint
    case .bud: GrowthStage.bud.tint
    case .garden: GrowthStage.flower.tint
    }
  }
}

/// 育ちの名前の札（地図の上とホームに出す）。
struct GrowthBadge: View {
  var summary: ScriptGrowthSummary
  var size: CGFloat = 28

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: summary.symbol)
        .font(.system(size: size, weight: .bold))
        .foregroundStyle(summary.tint)
      Text(summary.title).font(.ui(size, bold: true)).foregroundStyle(Theme.ink)
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 10)
    .background(.white.opacity(0.85), in: .capsule)
    .softShadow()
    .accessibilityElement(children: .combine)
  }
}
