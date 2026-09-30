// Bỏ dấu tiếng Việt để tìm kiếm "có dấu hoặc không dấu" (giống Tập 1, Chương 3).
const _accents = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final Map<String, String> _lookup = {
  for (final e in _accents.entries)
    for (final ch in e.value.split('')) ch: e.key,
};

extension VietnameseText on String {
  /// "Đàm phán" → "dam phan".
  String get withoutAccents => toLowerCase().split('').map((c) => _lookup[c] ?? c).join();
}
