import ExpoModulesCore

// Native module (iOS) — chỉ chạy trong development build / app thật, KHÔNG có trong Expo Go.
// Tạo khung bằng: npx create-expo-module@latest --local (template MIT của Expo).
public class TextStatsModule: Module {
  public func definition() -> ModuleDefinition {
    Name("TextStats")

    // Hằng số đọc được từ JS: TextStats.platform
    Constant("platform") {
      "ios"
    }

    // Hàm đồng bộ gọi qua JSI: TextStats.stats("xin chào")
    Function("stats") { (text: String) -> [String: Int] in
      let words = text.split(whereSeparator: { $0.isWhitespace }).count
      // unicodeScalars = code point, cùng cách đếm với Array.from(text) bên JS
      return ["words": words, "characters": text.unicodeScalars.count]
    }
  }
}
