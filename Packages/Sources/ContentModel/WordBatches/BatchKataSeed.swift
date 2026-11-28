/// めぐり「KataSeed」（D199）: カタカナのことばの はじめの1語「バス」。おためしのことば（D90・D92）。
/// カタカナのことばは、字のとおりカタカナで持つ（D7）。文字の種類は字から決まるので、印はいらない。
/// カタカナのことばは、カタカナパックを買うと書ける。「バス」だけは、パックがなくても書ける（D93）。
/// このあとのカタカナのことば（パトカー・タクシーなど）は、同じ形のめぐりに足す（`Content/README.md`）。
extension WordBatch {
  static let kataSeed = WordBatch(
    name: "kataSeed",
    entries: [WordEntry("バス", .vehicle)],
    themeWords: ["norimono": ["バス"]],
    notes: ["バス": "バスは たくさんの ひとを のせて はしるよ"],
    artNames: ["バス": "basu"]
  )
}
