import '../../domain/models/word.dart';

/// Nguồn sự thật (source of truth) cho từ vựng. UI chỉ biết interface này.
/// Docs chính thức: "Use abstract repository classes" — để có bản SQLite và bản giả (fake) cho test.
abstract interface class WordRepository {
  /// Tìm theo từ hoặc nghĩa (có dấu / không dấu). Rỗng = tất cả.
  Future<List<Word>> search({String query = '', bool favoritesOnly = false});

  Future<Word?> getById(int id);

  /// Đảo trạng thái yêu thích, trả về từ sau khi đổi.
  Future<Word> toggleFavorite(int id);

  /// Ghi một lần ôn: nhớ đúng hay sai.
  Future<void> recordReview(int wordId, {required bool correct, DateTime? at});

  /// Các từ nên ôn trước: từ hay sai → từ chưa ôn → từ đã thuộc.
  Future<List<Word>> dueForReview({int limit = 10});

  Future<ReviewStats> stats({DateTime? now});

  /// Bài tập 1 (Chương 8): xóa toàn bộ lịch sử ôn, trả về số lượt đã xóa.
  Future<int> resetProgress();
}

/// Không tìm thấy từ theo id.
class WordNotFoundException implements Exception {
  const WordNotFoundException(this.id);
  final int id;
  @override
  String toString() => 'Không có từ id=$id';
}
