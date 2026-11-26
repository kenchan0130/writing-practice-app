extension LearningLog {
  /// ことばごとの、書いた回数（いまのリセットの回数の行だけ。D82）。ずかんの★はこの数から決める。
  public var wordWriteCounts: [String: Int] {
    currentWords.reduce(into: [:]) { counts, record in counts[record.word, default: 0] += 1 }
  }

  /// 字を「書けた」とみなすか（もじから さがす。D181）。なぞって かけた（つぼみ）以上。
  public func canWrite(characterID: String) -> Bool {
    mapState(of: characterID) >= .traced
  }
}
