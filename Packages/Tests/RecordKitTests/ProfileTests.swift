import Foundation
import Testing

@testable import RecordKit

@Suite("プロフィール")
struct ProfileTests {
  @Test("呼び名に くん・ちゃん・さん を付ける。名前がなければ空")
  func displayName() {
    #expect(Profile(name: "ゆうと", honorific: .kun, face: "a").displayName == "ゆうとくん")
    #expect(Profile(name: "はな", honorific: .chan, face: "a").displayName == "はなちゃん")
    #expect(Profile(name: "りょう", honorific: .none, face: "a").displayName == "りょう")
    #expect(Profile(name: "  ", honorific: .kun, face: "a").displayName == "")
  }

  @Test("きょうの もくひょうは 3・5・10 のどれか")
  func dailyGoal() {
    #expect(Profile(name: "a", face: "a", dailyGoal: 10).dailyGoal == 10)
    #expect(Profile(name: "a", face: "a", dailyGoal: 7).dailyGoal == 5)
  }

  @Test("6人まで足せる（D19）")
  func maxSix() {
    var list = ProfileList()
    for i in 0..<6 {
      let added = list.add(Profile(name: "\(i)", face: "a"))
      #expect(added)
    }
    #expect(!list.canAdd)
    let seventh = list.add(Profile(name: "7", face: "a"))
    #expect(!seventh)
    #expect(list.profiles.count == 6)
  }

  @Test("最後の1人は消さない。いつも使う子がいなくなれば最初の子")
  func removeAndCurrent() {
    let a = Profile(name: "a", face: "a")
    let b = Profile(name: "b", face: "b")
    var list = ProfileList(profiles: [a, b])
    #expect(list.current(preferred: b.id) == b)
    let removedB = list.remove(b.id)
    #expect(removedB)
    #expect(list.current(preferred: b.id) == a)
    let removedLast = list.remove(a.id)
    #expect(!removedLast)
  }

  @Test("直すと、同じ ID のプロフィールが変わる")
  func update() {
    var a = Profile(name: "a", face: "a")
    var list = ProfileList(profiles: [a])
    a.name = "あお"
    list.update(a)
    #expect(list.profiles.first?.name == "あお")
  }

  @Test("ペンの色は8色で、色の値は0〜1、重ならない")
  func penColors() {
    #expect(PenColor.allCases.count == 8)
    #expect(Set(PenColor.allCases.map(\.label)).count == 8)
    for color in PenColor.allCases {
      let c = color.rgb
      #expect((0...1).contains(c.red) && (0...1).contains(c.green) && (0...1).contains(c.blue))
      #expect(PenColor(rawValue: color.rawValue) == color)
    }
    #expect(PenColor.default == .blue)
  }

  @Test("ペンの色は保存して読み戻せる。古いデータ（色なし）も読める")
  func penColorCoding() throws {
    let profile = Profile(name: "a", face: "a", penColor: .pink)
    let data = try JSONEncoder().encode(profile)
    #expect(try JSONDecoder().decode(Profile.self, from: data).penColor == .pink)
    let old =
      #"{"id":"11111111-1111-1111-1111-111111111111","name":"a","honorific":"none","face":"a","handedness":"right","dailyGoal":5}"#
    #expect(try JSONDecoder().decode(Profile.self, from: Data(old.utf8)).penColor == nil)
    #expect(Profile(name: "a", face: "a").penColor == nil)
  }
}
