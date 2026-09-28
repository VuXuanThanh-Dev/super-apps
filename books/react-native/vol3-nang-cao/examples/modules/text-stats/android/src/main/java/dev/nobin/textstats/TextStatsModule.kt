package dev.nobin.textstats

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

// Native module (Android) — chỉ chạy trong development build / app thật, KHÔNG có trong Expo Go.
class TextStatsModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("TextStats")

    Constant("platform") {
      "android"
    }

    Function("stats") { text: String ->
      val words = text.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }.size
      // codePointCount = số code point, cùng cách đếm với Array.from(text) bên JS
      mapOf("words" to words, "characters" to text.codePointCount(0, text.length))
    }
  }
}
