// Bỏ dấu tiếng Việt để "hop dong" tìm được "hợp đồng" (giống app mẫu Tập 2 của sách).
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
