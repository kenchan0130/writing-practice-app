import StrokeKit
import SwiftUI

/// 入力の部品（UIKit）を SwiftUI の画面に付ける（D109）。窓の座標を、付けた画面の座標に直して渡す。
struct StrokeInputGesture: UIGestureRecognizerRepresentable {
  var onEvent: (StrokeInputEvent, (CGPoint) -> CGPoint) -> Void

  final class Coordinator {
    let converter: CoordinateSpaceConverter
    init(converter: CoordinateSpaceConverter) {
      self.converter = converter
    }
  }

  func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
    Coordinator(converter: converter)
  }

  func makeUIGestureRecognizer(context: Context) -> StrokeInputRecognizer {
    StrokeInputRecognizer(target: nil, action: nil)
  }

  func updateUIGestureRecognizer(_ recognizer: StrokeInputRecognizer, context: Context) {
    let converter = context.coordinator.converter
    let onEvent = self.onEvent
    recognizer.onEvent = { event in
      onEvent(event) { converter.convert(globalPoint: $0) }
    }
  }
}
