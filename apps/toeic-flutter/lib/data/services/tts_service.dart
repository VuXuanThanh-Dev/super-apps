import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Đọc to một từ (text-to-speech). Interface để test dùng bản giả.
abstract interface class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setRate(double rate);
}

/// Bản thật dùng package flutter_tts (AVSpeechSynthesizer trên iOS, TextToSpeech trên Android,
/// Web Speech API trên web).
class FlutterTtsService implements TtsService {
  FlutterTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.awaitSpeakCompletion(true);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // Đọc được cả khi iPhone bật chế độ im lặng (README của flutter_tts: setIosAudioCategory).
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
    }
    _ready = true;
  }

  @override
  Future<void> speak(String text) async {
    await _ensureReady();
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<void> setRate(double rate) async {
    await _ensureReady();
    await _tts.setSpeechRate(rate);
  }
}
