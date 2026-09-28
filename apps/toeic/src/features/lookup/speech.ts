import * as Speech from 'expo-speech';

/** Text-to-speech with the device voice (works offline on iOS with installed voices). */
export function speak(text: string, rate = 0.9): void {
  void Speech.stop();
  Speech.speak(text, { language: 'en-US', rate });
}
