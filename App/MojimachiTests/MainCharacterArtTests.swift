import PracticeKit
import Testing
import UIKit

@testable import Mojimachi

/// 主人公3人の絵（アセットの SVG）が、すべてのポーズで読めて、色のある部分があることを確かめる。
@Suite("主人公の絵")
@MainActor
struct MainCharacterArtTests {
  @Test("3人 × 4ポーズ すべてに、色のある絵がある")
  func everyCharacterAndPoseHasArt() throws {
    #expect(MainCharacter.allCases.count == 3)
    #expect(CharacterPose.allCases.count == 4)
    for character in MainCharacter.allCases {
      for pose in CharacterPose.allCases {
        let name = character.assetName(pose)
        let image = try #require(UIImage(named: name), "\(name): 絵がない")
        let rendered = UIGraphicsImageRenderer(size: CGSize(width: 64, height: 64)).image { _ in
          image.draw(in: CGRect(x: 0, y: 0, width: 64, height: 64))
        }
        let cg = try #require(rendered.cgImage)
        var pixels = [UInt8](repeating: 0, count: cg.width * cg.height * 4)
        let context = try #require(
          CGContext(
            data: &pixels, width: cg.width, height: cg.height, bitsPerComponent: 8,
            bytesPerRow: cg.width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(cg, in: CGRect(x: 0, y: 0, width: cg.width, height: cg.height))
        let opaque = stride(from: 3, to: pixels.count, by: 4).filter { pixels[$0] > 128 }.count
        #expect(opaque > 200, "\(name): 色のある部分が少ない")
        #expect(pixels[3] < 10, "\(name): 背景が透明でない")
      }
    }
  }
}
