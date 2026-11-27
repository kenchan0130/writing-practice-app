import Testing

@testable import ContentModel

@Suite("ことばのめぐり")
struct WordBatchTests {
  @Test("めぐりの名前が重ならず、土台が先頭")
  func names() {
    let names = WordBatch.all.map(\.name)
    #expect(Set(names).count == names.count)
    #expect(names.first == "base")
  }

  @Test("ことばが、めぐりをまたいで重ならない")
  func noDuplicates() {
    var seen: [String: String] = [:]
    for batch in WordBatch.all {
      for entry in batch.entries {
        #expect(
          seen[entry.text] == nil, "\(entry.text) が \(seen[entry.text] ?? "") と \(batch.name) にある")
        seen[entry.text] = batch.name
      }
    }
  }

  @Test("めぐりのことばは、テーマ・説明・絵の名前がそろう")
  func complete() {
    for batch in WordBatch.all {
      let words = Set(batch.entries.map(\.text))
      for (themeID, themeWords) in batch.themeWords {
        #expect(WordMap.theme(id: themeID) != nil, "\(batch.name): テーマ \(themeID) がない")
        for w in themeWords {
          #expect(words.contains(w), "\(batch.name): \(themeID) の「\(w)」がめぐりにない")
        }
      }
      for key in Array(batch.notes.keys) + Array(batch.artNames.keys) + Array(batch.seasons.keys)
        + Array(batch.crawlers)
      {
        #expect(words.contains(key), "\(batch.name): めぐりにないことば「\(key)」")
      }
      // 土台は、テーマ側に書いてある。
      guard batch.name != "base" else { continue }
      for w in words {
        #expect(batch.themeWords.values.contains { $0.contains(w) }, "\(batch.name): 「\(w)」のテーマがない")
        #expect(batch.notes[w] != nil, "\(batch.name): 「\(w)」の説明がない")
        #expect(batch.artNames[w] != nil, "\(batch.name): 「\(w)」の絵の名前がない")
      }
    }
  }

  @Test("つないだ結果の順は、土台が先")
  func order() {
    #expect(Array(WordCatalog.all.prefix(WordCatalog.baseEntries.count)) == WordCatalog.baseEntries)
  }
}

extension WordBatchTests {
  @Test("絵の名前は、ことばの間で重ならない")
  func uniqueArtNames() {
    let names = Array(WordCatalog.batchArtNames.values)
    #expect(Set(names).count == names.count)
  }
}
