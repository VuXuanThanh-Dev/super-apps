import 'package:flutter/foundation.dart';

/// Một từ vựng. Model bất biến (docs chính thức: "Use immutable data models").
@immutable
class Word {
  const Word({
    required this.id,
    required this.text,
    required this.partOfSpeech,
    required this.meaning,
    this.example = '',
    this.favorite = false,
    this.reviewCount = 0,
    this.correctCount = 0,
  });

  final int id;
  final String text;
  final String partOfSpeech; // n, v, adj, adv…
  final String meaning; // nghĩa tiếng Việt
  final String example;
  final bool favorite;
  final int reviewCount;
  final int correctCount;

  /// Tỉ lệ nhớ đúng (0..1). Chưa ôn lần nào → 0.
  double get accuracy => reviewCount == 0 ? 0 : correctCount / reviewCount;

  /// Đọc một dòng SQLite. SQLite không có kiểu bool → lưu 0/1.
  factory Word.fromRow(Map<String, Object?> row) => Word(
    id: row['id']! as int,
    text: row['text']! as String,
    partOfSpeech: row['pos']! as String,
    meaning: row['meaning']! as String,
    example: (row['example'] as String?) ?? '',
    favorite: (row['favorite'] as int? ?? 0) == 1,
    reviewCount: row['review_count'] as int? ?? 0,
    correctCount: row['correct_count'] as int? ?? 0,
  );

  Word copyWith({bool? favorite, int? reviewCount, int? correctCount}) => Word(
    id: id,
    text: text,
    partOfSpeech: partOfSpeech,
    meaning: meaning,
    example: example,
    favorite: favorite ?? this.favorite,
    reviewCount: reviewCount ?? this.reviewCount,
    correctCount: correctCount ?? this.correctCount,
  );

  @override
  bool operator ==(Object other) =>
      other is Word &&
      other.id == id &&
      other.text == text &&
      other.partOfSpeech == partOfSpeech &&
      other.meaning == meaning &&
      other.example == example &&
      other.favorite == favorite &&
      other.reviewCount == reviewCount &&
      other.correctCount == correctCount;

  @override
  int get hashCode => Object.hash(id, text, partOfSpeech, meaning, example, favorite, reviewCount, correctCount);

  @override
  String toString() => 'Word($id, $text)';
}

/// Thống kê cho màn hình Ôn tập.
@immutable
class ReviewStats {
  const ReviewStats({required this.totalWords, required this.favorites, required this.reviewedToday});
  final int totalWords;
  final int favorites;
  final int reviewedToday;

  @override
  bool operator ==(Object other) =>
      other is ReviewStats &&
      other.totalWords == totalWords &&
      other.favorites == favorites &&
      other.reviewedToday == reviewedToday;

  @override
  int get hashCode => Object.hash(totalWords, favorites, reviewedToday);

  @override
  String toString() => 'ReviewStats($totalWords, $favorites, $reviewedToday)';
}
