// Mô hình dữ liệu (domain models) — cùng schema với Task 5 (apps/toeic/src/data/types.ts).
// Bất biến (immutable): mọi field là `final`. Docs chính thức khuyên dùng model bất biến
// (app-architecture/recommendations: "Use immutable data models").

/// Một chủ đề / unit, ví dụ "T01 · Contracts & Negotiations".
class Topic {
  const Topic({required this.code, required this.book, required this.en, required this.vi});

  final String code;
  final String book; // tap1 | tap2 | sample | mine
  final String en;
  final String vi;

  Map<String, Object?> toJson() => {'code': code, 'book': book, 'en': en, 'vi': vi};
}

/// Một họ từ (word family), ví dụ agree → agreement, disagree…
class Family {
  const Family({
    required this.id,
    required this.headword,
    required this.topic,
    required this.book,
    required this.band850,
    required this.members,
    this.tip,
    this.page,
  });

  final String id;
  final String headword;
  final String topic;
  final String book;
  final bool band850;
  final List<String> members; // id của các từ, headword đứng đầu
  final String? tip;
  final int? page;

  Map<String, Object?> toJson() => {
    'id': id,
    'headword': headword,
    'topic': topic,
    'book': book,
    'band850': band850,
    'members': members,
    'tip': tip,
    'page': page,
  };
}

/// Một dạng từ (word form) có trong bộ dữ liệu.
class Word {
  const Word({
    required this.id,
    required this.word,
    required this.lemma,
    required this.pos,
    required this.topic,
    required this.book,
    required this.family,
    required this.families,
    required this.isHead,
    this.ipa,
    this.ipaSource,
    this.definition,
    this.example,
    this.vi,
    this.note,
  });

  final String id;
  final String word;
  final String lemma;
  final String pos; // "n", "v", "adj", "n/v"…
  final String? ipa;
  final String? ipaSource; // book | cmudict
  final String? definition; // định nghĩa tiếng Anh đơn giản (tự viết, Task 5)
  final String? example; // câu ví dụ (tự viết, Task 5)
  final String? vi; // nghĩa tiếng Việt ngắn
  final String? note;
  final String topic;
  final String book;
  final String family; // id họ từ chính
  final List<String> families;
  final bool isHead;

  /// Khoá dùng cho dữ liệu người dùng (đã lưu, thẻ SM-2): chữ thường của từ.
  String get key => word.toLowerCase();

  Map<String, Object?> toJson() => {
    'id': id,
    'word': word,
    'lemma': lemma,
    'pos': pos,
    'ipa': ipa,
    'ipaSource': ipaSource,
    'definition': definition,
    'example': example,
    'vi': vi,
    'note': note,
    'topic': topic,
    'book': book,
    'family': family,
    'families': families,
    'isHead': isHead,
  };
}

/// Cụm từ hay đi cùng nhau (collocation), ví dụ "reach an agreement".
class Collocation {
  const Collocation({
    required this.id,
    required this.family,
    required this.phrase,
    required this.vi,
    required this.example,
  });

  final String id;
  final String family;
  final String phrase;
  final String vi;
  final String example;

  Map<String, Object?> toJson() => {'id': id, 'family': family, 'phrase': phrase, 'vi': vi, 'example': example};
}

class Question {
  const Question({required this.question, required this.options, required this.answer});

  final String question;
  final List<String> options;
  final int answer; // chỉ số trong options

  Map<String, Object?> toJson() => {'question': question, 'options': options, 'answer': answer};
}

/// Bài đọc ngắn kiểu TOEIC (tự viết, Task 5).
class Passage {
  const Passage({
    required this.id,
    required this.topic,
    required this.title,
    required this.text,
    required this.questions,
  });

  final String id;
  final String topic;
  final String title;
  final String text;
  final List<Question> questions;

  Map<String, Object?> toJson() => {
    'id': id,
    'topic': topic,
    'title': title,
    'text': text,
    'questions': [for (final q in questions) q.toJson()],
  };
}

/// Định nghĩa dự phòng (WordNet 3.0) cho từ không có trong sách.
class Gloss {
  const Gloss({required this.pos, required this.definition});

  factory Gloss.fromJson(Map<String, Object?> json) =>
      Gloss(pos: json['pos'] as String? ?? '', definition: json['definition'] as String? ?? '');

  final String pos;
  final String definition;

  Map<String, Object?> toJson() => {'pos': pos, 'definition': definition};
}

/// Toàn bộ bộ dữ liệu (bản riêng từ sách, hoặc bản mẫu).
class Dataset {
  const Dataset({
    required this.version,
    required this.source,
    required this.topics,
    required this.families,
    required this.words,
    required this.collocations,
    required this.passages,
    required this.glosses,
  });

  final int version;
  final String source; // private | sample
  final List<Topic> topics;
  final List<Family> families;
  final List<Word> words;
  final List<Collocation> collocations;
  final List<Passage> passages;
  final Map<String, Gloss> glosses;

  bool get isSample => source == 'sample';

  /// Xuất lại đúng schema JSON của Task 5 (dùng trong test "import không mất dữ liệu").
  Map<String, Object?> toJson() => {
    'version': version,
    'source': source,
    'topics': [for (final t in topics) t.toJson()],
    'families': [for (final f in families) f.toJson()],
    'words': [for (final w in words) w.toJson()],
    'collocations': [for (final c in collocations) c.toJson()],
    'passages': [for (final p in passages) p.toJson()],
    'glosses': {for (final e in glosses.entries) e.key: e.value.toJson()},
  };
}

/// Từ chức năng thường gặp (the, of, do…) — tự viết ở Task 5.
class FunctionWord {
  const FunctionWord({required this.pos, required this.definition, required this.vi});

  factory FunctionWord.fromJson(Map<String, Object?> json) => FunctionWord(
    pos: json['pos'] as String? ?? '',
    definition: json['definition'] as String? ?? '',
    vi: json['vi'] as String? ?? '',
  );

  final String pos;
  final String definition;
  final String vi;
}

class RoleplayLine {
  const RoleplayLine({required this.speaker, required this.text});

  final String speaker;
  final String text;
}

/// Hội thoại nhập vai (roleplay) — tự viết ở Task 5.
class Roleplay {
  const Roleplay({
    required this.id,
    required this.category,
    required this.title,
    required this.setting,
    required this.lines,
  });

  factory Roleplay.fromJson(Map<String, Object?> json) => Roleplay(
    id: json['id'] as String,
    category: json['category'] as String? ?? '',
    title: json['title'] as String? ?? '',
    setting: json['setting'] as String? ?? '',
    lines: [
      for (final l in (json['lines'] as List<Object?>? ?? const []).cast<Map<String, Object?>>())
        RoleplayLine(speaker: l['speaker'] as String? ?? '', text: l['text'] as String? ?? ''),
    ],
  );

  final String id;
  final String category; // office | meeting | email | phone
  final String title;
  final String setting;
  final List<RoleplayLine> lines;

  /// Các vai trong hội thoại (theo thứ tự xuất hiện).
  List<String> get speakers =>
      [for (final l in lines) l.speaker].fold<List<String>>([], (acc, s) => acc.contains(s) ? acc : (acc..add(s)));
}
