import 'dataset.dart';

/// Chỉ mục trong bộ nhớ trên một [Dataset] (tạo một lần khi mở app) — port từ Task 5 (DataIndex.ts).
class DataIndex {
  DataIndex(this.dataset) {
    for (final w in dataset.words) {
      wordsById[w.id] = w;
      wordsByText[w.word.toLowerCase()] = w;
    }
    for (final f in dataset.families) {
      familiesById[f.id] = f;
    }
    for (final c in dataset.collocations) {
      (collocationsByFamily[c.family] ??= []).add(c);
    }
    for (final t in dataset.topics) {
      topicsByCode[t.code] = t;
    }
  }

  final Dataset dataset;
  final Map<String, Word> wordsById = {};
  final Map<String, Word> wordsByText = {};
  final Map<String, Family> familiesById = {};
  final Map<String, List<Collocation>> collocationsByFamily = {};
  final Map<String, Topic> topicsByCode = {};

  List<Topic> get topics => dataset.topics;
  List<Word> get words => dataset.words;
  List<Passage> get passages => dataset.passages;

  List<Word> familyMembers(String familyId) {
    final f = familiesById[familyId];
    if (f == null) return const [];
    return [for (final id in f.members) ?wordsById[id]];
  }

  List<Collocation> collocationsForWord(Word word) => [for (final fid in word.families) ...?collocationsByFamily[fid]];

  List<Word> wordsInTopic(String code) => dataset.words.where((w) => w.topic == code).toList();

  List<Family> familiesInTopic(String code) => dataset.families.where((f) => f.topic == code).toList();

  Word? wordByKey(String key) => wordsByText[key.toLowerCase()];
}
