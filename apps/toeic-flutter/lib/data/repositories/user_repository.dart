import 'package:flutter/foundation.dart';

import '../../domain/models/user_data.dart';
import '../../utils/result.dart';

/// Dữ liệu học của người dùng (nguồn sự thật — source of truth). Docs chính thức: repository trả về
/// `Result` để lỗi được xử lý rõ ràng; view model không gọi thẳng service.
///
/// [changes] báo cho view model (Home, Saved…) biết dữ liệu đã đổi để tải lại.
abstract class UserRepository {
  Listenable get changes;

  Future<Result<List<SavedWord>>> savedWords();
  Future<Result<bool>> isSaved(String word);
  Future<Result<void>> setSaved(String word, {required bool saved});

  Future<Result<List<Card>>> cards();
  Future<Result<void>> saveCard(Card card);

  Future<Result<void>> recordAnswer(String word, {required bool correct, required int day});
  Future<Result<List<WordStat>>> wordStats();

  Future<Result<void>> recordActivity(String day, ActivityKind kind);
  Future<Result<List<ActivityDay>>> activity();

  /// Xoá toàn bộ tiến độ (từ đã lưu, thẻ, thống kê).
  Future<Result<void>> reset();
}
