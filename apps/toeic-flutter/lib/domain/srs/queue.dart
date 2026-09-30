// Port từ Task 5 (flashcards/queue.ts).
import '../models/dataset.dart';
import '../models/user_data.dart';

/// Hàng đợi ôn: thẻ đến hạn trước (hạn cũ nhất trước), rồi từ mới (chưa ôn) tối đa [newLimit].
/// Bỏ qua từ không có nghĩa Việt lẫn định nghĩa.
List<Word> buildQueue(List<Word> words, List<Card> cards, {required int today, required int newLimit}) {
  final byWord = {for (final c in cards) c.word: c};
  final studyable = words.where((w) => w.vi != null || w.definition != null).toList();
  final due = studyable.where((w) {
    final c = byWord[w.key];
    return c != null && c.due <= today;
  }).toList()..sort((a, b) => (byWord[a.key]?.due ?? 0).compareTo(byWord[b.key]?.due ?? 0));
  final fresh = studyable.where((w) => !byWord.containsKey(w.key)).take(newLimit);
  return [...due, ...fresh];
}
