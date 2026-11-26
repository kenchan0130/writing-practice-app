import ContentModel
import UIKit

/// ことばの絵（原作の SVG。D163）。ことばの一覧は WordCatalog。
/// 絵は `Assets.xcassets` の `word-<ローマ字>`。もとの SVG は `Content/Art/words/`。
enum WordArt {
  struct Item {
    let entry: WordEntry
    /// アセットの名前（`word-` を除いたローマ字）。
    let asset: String
    /// 種類の色（背景や、影絵が色づくときの色の候補）。
    let color: UIColor
  }

  private static let vehicleColor = UIColor(red: 0.85, green: 0.3, blue: 0.25, alpha: 1)
  private static let animalColor = UIColor(red: 0.62, green: 0.4, blue: 0.2, alpha: 1)
  private static let clothesColor = UIColor(red: 0.25, green: 0.45, blue: 0.85, alpha: 1)
  private static let flyerColor = UIColor(red: 0.3, green: 0.62, blue: 0.9, alpha: 1)
  private static let swimmerColor = UIColor(red: 0.2, green: 0.6, blue: 0.85, alpha: 1)
  private static let playColor = UIColor(red: 0.95, green: 0.6, blue: 0.25, alpha: 1)
  private static let bodyColor = UIColor(red: 0.93, green: 0.45, blue: 0.5, alpha: 1)
  private static let skyColor = UIColor(red: 0.35, green: 0.55, blue: 0.9, alpha: 1)
  private static let sceneryColor = UIColor(red: 0.4, green: 0.7, blue: 0.32, alpha: 1)

  private static let assets: [String: String] = [
    "そり": "sori", "くるま": "kuruma", "ふね": "fune", "でんしゃ": "densha",
    "じてんしゃ": "jitensha", "しんかんせん": "shinkansen", "うし": "ushi", "いぬ": "inu",
    "ねこ": "neko", "うま": "uma", "くま": "kuma", "しか": "shika", "りす": "risu",
    "ふく": "fuku", "くつ": "kutsu", "ぼうし": "boushi", "ゆかた": "yukata",
    "くつした": "kutsushita", "きもの": "kimono",
    "いかだ": "ikada", "しょうぼうしゃ": "shoubousha", "きゅうきゅうしゃ": "kyuukyuusha",
    "さる": "saru", "ぞう": "zou", "とら": "tora", "かば": "kaba", "きりん": "kirin",
    "らくだ": "rakuda", "ぶた": "buta", "ひつじ": "hitsuji", "たぬき": "tanuki",
    "きつね": "kitsune", "うさぎ": "usagi",
    "ひこうき": "hikouki", "ききゅう": "kikyuu", "はと": "hato", "すずめ": "suzume",
    "からす": "karasu", "さくら": "sakura", "ひまわり": "himawari", "たんぽぽ": "tanpopo",
    "りんご": "ringo", "みかん": "mikan", "いちご": "ichigo", "にんじん": "ninjin",
    "だいこん": "daikon", "かぼちゃ": "kabocha",
    "ちょう": "chou", "とんぼ": "tonbo", "はち": "hachi", "ほたる": "hotaru", "せみ": "semi",
    "かぶとむし": "kabutomushi", "てんとうむし": "tentoumushi", "かたつむり": "katatsumuri",
    "もも": "momo", "ぶどう": "budou", "すいか": "suika", "くり": "kuri", "だんご": "dango",
    "せんべい": "senbei", "わたあめ": "wataame", "おにぎり": "onigiri", "すし": "sushi",
    "うどん": "udon",
    "たこ": "tako", "いか": "ika", "かに": "kani", "かめ": "kame", "くじら": "kujira",
    "くらげ": "kurage", "いるか": "iruka", "さかな": "sakana", "ひとで": "hitode",
    "かえる": "kaeru", "めだか": "medaka", "ざりがに": "zarigani", "おたまじゃくし": "otamajakushi",
    "くも": "kumo", "にじ": "niji", "あめ": "ame", "ゆき": "yuki", "かみなり": "kaminari",
    "かぜ": "kaze", "たいよう": "taiyou", "ほし": "hoshi", "つき": "tsuki",
    "うちゅうじん": "uchuujin",
    "つみき": "tsumiki", "こま": "koma", "けんだま": "kendama", "ふうせん": "fuusen",
    "にんぎょう": "ningyou", "たいこ": "taiko", "ふえ": "fue", "すず": "suzu",
    "もっきん": "mokkin", "なわとび": "nawatobi", "てつぼう": "tetsubou", "とびばこ": "tobibako",
    "ぶらんこ": "burango", "すべりだい": "suberidai", "すなば": "sunaba",
    "あさがお": "asagao", "ばら": "bara", "やま": "yama", "たき": "taki", "いし": "ishi",
    "いけ": "ike", "くさ": "kusa", "まつ": "matsu", "どんぐり": "donguri", "はっぱ": "happa",
    "きのこ": "kinoko", "いえ": "ie", "がっこう": "gakkou", "びょういん": "byouin",
    "おしろ": "oshiro", "しんごう": "shingou", "ふみきり": "fumikiri", "がいとう": "gaitou",
    "て": "te", "あし": "ashi", "め": "me", "みみ": "mimi", "くち": "kuchi", "あたま": "atama",
    "おなか": "onaka", "ほっぺ": "hoppe",
    "にんじゃ": "ninja", "おひめさま": "ohimesama", "おうさま": "ousama",
    "まほうつかい": "mahoutsukai", "かいぞく": "kaizoku",
    "だいく": "daiku", "せんせい": "sensei", "おいしゃさん": "oishasan",
    "おまわりさん": "omawarisan", "しょうぼうし": "shouboushi",
  ]

  static let words: [Item] = WordCatalog.all.map { entry in
    let color: UIColor =
      switch entry.kind {
      case .vehicle: vehicleColor
      case .animal: animalColor
      case .clothes: clothesColor
      case .flyer: flyerColor
      case .scenery: sceneryColor
      case .swimmer: swimmerColor
      case .sky: skyColor
      case .plaything: playColor
      case .bodyAction: bodyColor
      }
    return Item(entry: entry, asset: assets[entry.text] ?? "", color: color)
  }

  /// 絵のあることば。地図に出すものは、ここから決める（D166）。
  private static let wordsWithArt: Set<String> = Set(
    assets.filter { UIImage(named: "word-" + $0.value) != nil }.keys)

  /// そのことばに絵があるか（しりとりに出すことばを決める。D182）。
  static func hasArt(_ word: String) -> Bool { wordsWithArt.contains(word) }

  /// まちの地図・テーマ・ことばの出し分け（D166）。絵のあることばだけが出る。
  static let index: WordMapIndex = {
    let known = wordsWithArt
    return WordMapIndex { known.contains($0) }
  }()

  /// 空を飛ぶ物の動き方（D168）。鳥ははばたき、ひこうきはすべり、ききゅうはゆっくり上下する。
  enum FlyerStyle { case bird, plane, balloon }

  static func flyerStyle(_ word: String) -> FlyerStyle {
    switch word {
    case "ひこうき": .plane
    case "ききゅう": .balloon
    default: .bird
    }
  }

  /// 水の生きものの動き方（D170）。fish=横にゆれて泳ぐ、dolphin=なみのようにはねる、bob=その場でゆれる、
  /// jelly=ふわっと上下、crab=横に歩く、turtle=ゆっくりかく、star=ほとんど動かない、frog=はねる、tadpole=ぴくぴく。
  enum SwimStyle { case fish, dolphin, whale, bob, jelly, crab, turtle, star, frog, tadpole }

  static func swimStyle(_ word: String) -> SwimStyle {
    switch word {
    case "いるか": .dolphin
    case "くじら": .whale
    case "たこ": .bob
    case "くらげ": .jelly
    case "かに", "ざりがに": .crab
    case "かめ": .turtle
    case "ひとで": .star
    case "かえる": .frog
    case "おたまじゃくし": .tadpole
    default: .fish
    }
  }

  /// こうえんの物の使われ方（D173）。まちでも変身のあとでも、その物らしく小さく動く。
  /// swing=座るところが ゆれる、slide=ボールが すべりおりる、top=回る、kendama=玉が はねる、
  /// balloon=ふわふわ、doll=ゆれて おどる、blocks=ぐらっとして、もどる、
  /// drum=はずんで音符、flute=かたむいて音符、bell=ゆれて音符、xylophone=はずんで音符、
  /// rope=とぶ、bar=ほんの少し ゆれる、box=ぴょんと とびこえられる、sandbox=バケツが うなずく。
  enum PlayStyle {
    case swing, slide, top, kendama, balloon, doll, blocks
    case drum, flute, bell, xylophone, rope, bar, box, sandbox
  }

  static func playStyle(_ word: String) -> PlayStyle {
    switch word {
    case "ぶらんこ": .swing
    case "すべりだい": .slide
    case "こま": .top
    case "けんだま": .kendama
    case "ふうせん": .balloon
    case "にんぎょう": .doll
    case "つみき": .blocks
    case "たいこ": .drum
    case "ふえ": .flute
    case "すず": .bell
    case "もっきん": .xylophone
    case "なわとび": .rope
    case "てつぼう": .bar
    case "とびばこ": .box
    default: .sandbox
    }
  }

  /// 景色になる物のうち、風でゆれる物（花・草・木・はっぱ）。ほかは、ぽんと出て ひとはずみする（D168・D174）。
  static func sways(_ word: String) -> Bool {
    ["さくら", "ひまわり", "たんぽぽ", "あさがお", "ばら", "くさ", "まつ", "はっぱ"].contains(word)
  }

  /// 大きな景色（D174）の倍率。丘と草の境目に立ち、背景の木・家と同じ奥に描く。
  /// やまは、背景の家の2.5倍ほど。ふつうの景色の倍率（0.7）にこの倍をかける。
  static func landmarkFactor(_ word: String) -> Double? {
    switch word {
    case "やま": 6.0
    case "たき": 2.8
    case "がっこう", "びょういん", "おしろ": 2.2
    default: nil
    }
  }

  /// 小さくて見えにくい景色の倍率（D174）。ふつうの景色は 1。
  static func scenerySizeFactor(_ word: String) -> Double {
    switch word {
    case "ふみきり": 1.6
    case "しんごう": 1.3
    default: 1
    }
  }

  /// ことばの絵のアセットの名前（SwiftUI の `Image(...)` に渡す）。
  static func assetName(for word: String) -> String {
    "word-" + (assets[word] ?? "")
  }

  static func assetName(_ item: Item) -> String { "word-" + item.asset }

  /// ことばの絵（もとの色のまま）。無ければ nil。
  static func uiImage(for word: String) -> UIImage? {
    UIImage(named: assetName(for: word))
  }

  /// ことばの絵を、`size` 四方の透明な画像にする（縦横の比を保ち、真ん中に置く）。
  /// ベクターのまま描くので、大きさに合わせてくっきり出る。
  static func image(word: String, size: CGFloat) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
    return renderer.image { _ in
      guard let art = uiImage(for: word) else { return }
      let s = art.size
      let scale = min(size / max(s.width, 1), size / max(s.height, 1))
      let w = s.width * scale
      let h = s.height * scale
      art.draw(in: CGRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h))
    }
  }

  /// 絵のアセット（キャラクターなど）を、`size` 四方の透明な画像にする。無ければ nil。
  static func image(asset: String, size: CGFloat) -> UIImage? {
    guard let art = UIImage(named: asset) else { return nil }
    return UIGraphicsImageRenderer(size: CGSize(width: size, height: size)).image { _ in
      let s = art.size
      let scale = min(size / max(s.width, 1), size / max(s.height, 1))
      let w = s.width * scale
      let h = s.height * scale
      art.draw(in: CGRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h))
    }
  }

  /// 画像の色のある部分から、線が集まる先の点を取る（D55・D110）。座標は画像の左上が原点。
  static func targetPoints(in image: UIImage, count: Int) -> [CGPoint] {
    guard let cg = image.cgImage else { return [] }
    let width = cg.width
    let height = cg.height
    var pixels = [UInt8](repeating: 0, count: width * height * 4)
    guard
      let context = CGContext(
        data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { return [] }
    context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
    var opaque: [CGPoint] = []
    let step = max(1, Int((Double(width * height) / Double(count * 6)).squareRoot()))
    for y in stride(from: 0, to: height, by: step) {
      for x in stride(from: 0, to: width, by: step) where pixels[(y * width + x) * 4 + 3] > 128 {
        // CGContext は下が原点なので、上を原点に直す。
        opaque.append(
          CGPoint(
            x: CGFloat(x) / CGFloat(width) * image.size.width,
            y: CGFloat(height - 1 - y) / CGFloat(height) * image.size.height))
      }
    }
    guard opaque.count > count else { return opaque }
    // 決まった順に間引く（毎回同じ結果にする）。
    let stride = Double(opaque.count) / Double(count)
    return (0..<count).map { opaque[Int(Double($0) * stride)] }
  }
}
