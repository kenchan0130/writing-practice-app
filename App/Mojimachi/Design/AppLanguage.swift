import Foundation

/// 画面の言葉（D186）。字・ことば・声は日本語のまま、保護者用の画面などの案内だけを言語ごとに出す。
enum AppLanguage {
  /// いまの画面の言葉が英語か（アプリが対応している言語の中で、いちばん合うもの）。
  static var isEnglish: Bool {
    Bundle.main.preferredLocalizations.first == "en"
  }
}
