import ContentModel
import EntitlementKit
import RecordKit
import SwiftUI

/// 保護者向けの学習記録（D25・§3.8）。ほかの子との比較や平均は出さない（D24）。
struct LearningRecordView: View {
  private let store = ProgressStore.shared
  private let purchases = PurchaseStore.shared
  @State private var replaying: ReplayItem?

  private var log: LearningLog { store.log }

  var body: some View {
    List {
      Section("今日 / 今週") {
        summaryRow("今日", log.today(now: Date(), calendar: .current))
        summaryRow("今週", log.thisWeek(now: Date(), calendar: .current))
      }
      // 使える文字の地図（ひらがな・カタカナ・ABC と数字）。鍵がかかっている文字は鍵の印で出す。
      ForEach(KanaScript.allCases, id: \.self) { script in
        Section {
          CharacterMapGrid(
            map: log.map, script: script,
            isLocked: { !purchases.entitlements.canWrite($0, in: script.entitlementScript) })
        } header: {
          Text(String(localized: "文字の地図（\(script.title)）"))
        } footer: {
          if script == KanaScript.allCases.last { MapLegend() }
        }
      }
      Section("苦手な字") {
        let weak = log.weakCharacters
        if weak.isEmpty {
          Text("今はありません").foregroundStyle(.secondary)
        }
        ForEach(weak, id: \.characterID) { item in
          HStack(spacing: 16) {
            Text(Self.char(item.characterID)).font(.system(size: 36, weight: .bold))
            VStack(alignment: .leading) {
              Text("最近 \(item.misses) 回 書き直し")
              Text(item.reasons.map(RecordMapping.label).joined(separator: "・"))
                .foregroundStyle(.secondary)
            }
            Spacer()
            Button("書いた動きを見る") { replaying = ReplayItem(weak: item) }
              .disabled(!item.latestMiss.hasStrokes && item.latestMiss.strokes == nil)
          }
        }
      }
      Section {
        let album = log.album
        if album.isEmpty {
          Text("字を書くと、ここに並びます").foregroundStyle(.secondary)
        }
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], spacing: 16) {
          ForEach(album, id: \.characterID) { entry in AlbumCard(entry: entry) }
        }
      } header: {
        Text("成長アルバム")
      } footer: {
        Text("はじめて書いた字と、最近の字を並べています。")
      }
    }
    .navigationTitle("学習記録")
    .sheet(item: $replaying) { replay in
      let item = replay.weak
      VStack(spacing: 16) {
        Text("「\(Self.char(item.characterID))」を書いた動き").font(.title2.bold())
        // 線のデータは一覧に入れていないので、開いたときに読む。
        StrokeReplay(strokes: store.strokes(of: item.latestMiss) ?? [])
          .frame(width: 360, height: 360)
        Button("閉じる") { replaying = nil }
      }
      .padding(32)
      .pausesParentTimeout()
    }
  }

  private func summaryRow(_ title: LocalizedStringKey, _ summary: PeriodSummary) -> some View {
    LabeledContent(title) {
      Text("\(summary.characters) 字・ことば \(summary.words) 個・\(summary.days) 日")
    }
  }

  /// 字の ID（`hira.3042`）を字に戻す。
  static func char(_ id: String) -> String {
    guard let hex = id.split(separator: ".").last, let value = UInt32(hex, radix: 16),
      let scalar = Unicode.Scalar(value)
    else { return id }
    return String(Character(scalar))
  }
}

/// 再生する苦手な字（シートに渡すため）。
private struct ReplayItem: Identifiable {
  var weak: WeakCharacter
  var id: String { weak.characterID }
}

/// 文字の地図（§3.8）。4つの状態で色分けする。鍵のかかった字は、色をつけず鍵の印を出す。
private struct CharacterMapGrid: View {
  var map: [String: MapState]
  var script: KanaScript
  var isLocked: (Character) -> Bool

  /// 地図の並び（行ごと。空きは nil）。かなは「あ行・か行 …」を横に並べる。ABC は左から右。
  private var rows: [[Character?]] {
    switch script {
    case .hiragana, .katakana:
      let table = KanaTable.main(script)
      // 表は あ行が右の列。行ごとに（あ行から）並べ直す。
      return (0..<table.columnCount).reversed().map { column in table.cells.map { $0[column] } }
    case .abc:
      return AbcTable.Page.allCases.flatMap { AbcTable.grid($0).cells }
    }
  }

  var body: some View {
    Grid(horizontalSpacing: 6, verticalSpacing: 6) {
      ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
        GridRow {
          ForEach(Array(row.enumerated()), id: \.offset) { _, char in
            if let char {
              cell(char)
            } else {
              Color.clear.frame(width: 44, height: 44)
            }
          }
        }
      }
    }
    .padding(.vertical, 8)
  }

  private func cell(_ char: Character) -> some View {
    let locked = isLocked(char)
    let id = KanaTable.characterID(char, script: script) ?? ""
    let state = map[id] ?? .notYet
    return Text(String(char))
      .font(.title3.bold())
      .foregroundStyle(locked ? Color.secondary : Color.primary)
      .frame(width: 44, height: 44)
      .background(
        locked ? Color.gray.opacity(0.12) : MapLegend.color(state), in: .rect(cornerRadius: 8)
      )
      .overlay(alignment: .topTrailing) {
        if locked {
          Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(.secondary)
            .padding(3)
        }
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(
        locked
          ? String(localized: "\(String(char))、ロックされています")
          : String(localized: "\(String(char))、\(MapLegend.name(state))"))
  }
}

private struct MapLegend: View {
  static func color(_ state: MapState) -> Color {
    switch state {
    case .notYet: Color.gray.opacity(0.12)
    case .practicing: Color.yellow.opacity(0.35)
    case .traced: Color.green.opacity(0.3)
    case .wroteAlone: Color.blue.opacity(0.35)
    }
  }

  static func name(_ state: MapState) -> String {
    switch state {
    case .notYet: String(localized: "まだ（たね）")
    case .practicing: String(localized: "練習中（め）")
    case .traced: String(localized: "なぞって書けた（つぼみ）")
    case .wroteAlone: String(localized: "何も見ないで書けた（はな）")
    }
  }

  var body: some View {
    HStack(spacing: 12) {
      ForEach([MapState.notYet, .practicing, .traced, .wroteAlone], id: \.self) { state in
        HStack(spacing: 4) {
          RoundedRectangle(cornerRadius: 3).fill(Self.color(state)).frame(width: 14, height: 14)
          Text(Self.name(state))
        }
      }
    }
  }
}

/// 成長アルバムの1文字（D83）。
private struct AlbumCard: View {
  var entry: AlbumEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(LearningRecordView.char(entry.characterID)).font(.title2.bold())
        Spacer()
        if let date = entry.firstSoloPass {
          Label(date.formatted(date: .numeric, time: .omitted), systemImage: "seal.fill")
            .foregroundStyle(.pink)
            .font(.caption.bold())
        }
      }
      HStack(spacing: 8) {
        page("最初", entry.first, traced: entry.firstWasTraced)
        Image(systemName: "arrow.right").foregroundStyle(.secondary)
        page("最近", entry.latest, traced: false)
      }
    }
    .padding(12)
    .background(.background.secondary, in: .rect(cornerRadius: 12))
  }

  private func page(_ title: LocalizedStringKey, _ record: CharacterRecord, traced: Bool)
    -> some View
  {
    VStack(spacing: 4) {
      LazyStrokeThumbnail(record: record)
        .frame(width: 80, height: 80)
      Text(title).font(.caption)
      if traced {
        Text("なぞって書いた").font(.caption2).foregroundStyle(.secondary)
      }
    }
  }
}

/// 線のデータを、表示するときに読んで出す絵（一覧には線を入れていない。D194）。
private struct LazyStrokeThumbnail: View {
  var record: CharacterRecord
  @State private var strokes: [[[Double]]] = []

  var body: some View {
    StrokeThumbnail(strokes: strokes)
      .task(id: record.id) { strokes = ProgressStore.shared.strokes(of: record) ?? [] }
  }
}

/// 記録した線の小さな絵。
private struct StrokeThumbnail: View {
  var strokes: [[[Double]]]

  var body: some View {
    Canvas { context, size in
      context.stroke(
        Path(CGRect(origin: .zero, size: size)), with: .color(.orange.opacity(0.4)), lineWidth: 1)
      let scale = size.width / 1000
      for stroke in strokes {
        context.stroke(
          StrokeReplay.path(stroke, scale: scale), with: .color(CanvasDrawing.inkColor),
          style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
      }
    }
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
  }
}

/// 子どもが書いた動きの再生（§3.8）。画を順に、点の数に合わせて少しずつ描く。
struct StrokeReplay: View {
  var strokes: [[[Double]]]
  @State private var start = Date()

  static func path(_ points: [[Double]], scale: Double, upTo count: Int? = nil) -> Path {
    var path = Path()
    let shown = points.prefix(count ?? points.count).filter { $0.count == 2 }
    guard let first = shown.first else { return path }
    path.move(to: CGPoint(x: first[0] * scale, y: first[1] * scale))
    for p in shown.dropFirst() { path.addLine(to: CGPoint(x: p[0] * scale, y: p[1] * scale)) }
    return path
  }

  var body: some View {
    TimelineView(.animation) { timeline in
      Canvas { context, size in
        CanvasDrawing.guide(in: &context, size: size)
        let scale = size.width / 1000
        // 1点を 1/60 秒、画のあいだを 0.4 秒として、繰り返し再生する。
        let total = strokes.reduce(0) { $0 + Double($1.count) / 60 + 0.4 } + 1
        var t = timeline.date.timeIntervalSince(start).truncatingRemainder(dividingBy: total)
        for stroke in strokes {
          let count = min(stroke.count, Int(t * 60))
          context.stroke(
            Self.path(stroke, scale: scale, upTo: count), with: .color(CanvasDrawing.inkColor),
            style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
          t -= Double(stroke.count) / 60 + 0.4
          if t < 0 { break }
        }
      }
    }
    .background(Color(red: 0.98, green: 0.96, blue: 0.92))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .accessibilityLabel("書いた動きの再生")
  }
}
