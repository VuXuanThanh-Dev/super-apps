import 'models/word.dart';

/// Bài tập 2 (Chương 8): "Từ của ngày" — cùng một ngày luôn ra cùng một từ, ngày khác đổi từ.
/// Hàm thuần (không dùng Random) nên test được.
Word? wordOfTheDay(List<Word> words, DateTime day) {
  if (words.isEmpty) return null;
  final sorted = [...words]..sort((a, b) => a.id.compareTo(b.id));
  final dayNumber = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return sorted[dayNumber % sorted.length];
}
