import '../../domain/lookup/dictionary.dart';
import '../../domain/models/data_index.dart';
import '../../domain/models/dataset.dart';
import '../services/content_service.dart';

/// Bộ dữ liệu TOEIC + nội dung công khai, đã nạp vào bộ nhớ khi mở app (chỉ đọc, offline).
/// Mọi truy vấn là đồng bộ (synchronous) vì dữ liệu đã ở trong RAM.
class DatasetRepository {
  factory DatasetRepository({required Dataset dataset, required PublicContent content}) {
    final index = DataIndex(dataset);
    return DatasetRepository._(
      index,
      content,
      Dictionary(
        index: index,
        functionWords: content.functionWords,
        genericGlosses: content.genericGlosses,
        irregular: content.irregular,
      ),
    );
  }

  DatasetRepository._(this.index, this.content, this.dictionary);

  final DataIndex index;
  final PublicContent content;
  final Dictionary dictionary;

  bool get isSample => index.dataset.isSample;
  List<Roleplay> get roleplays => content.roleplays;

  LookupResult lookup(String raw) => dictionary.lookup(raw);

  Roleplay? roleplayById(String id) => roleplays.where((d) => d.id == id).firstOrNull;
  Passage? passageById(String id) => index.passages.where((p) => p.id == id).firstOrNull;
}
