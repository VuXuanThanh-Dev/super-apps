// Port từ Task 5 (storage/dates.ts). "Số ngày" (day number) = số ngày kể từ 1970-01-01 theo ngày
// ĐỊA PHƯƠNG, nên ôn lúc 23:59 và 00:01 là hai ngày khác nhau.

String localDayString(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

int dayNumberFromString(String s) {
  final parts = s.split('-').map(int.tryParse).toList();
  final y = parts.isNotEmpty ? parts[0] ?? 1970 : 1970;
  final m = parts.length > 1 ? parts[1] ?? 1 : 1;
  final d = parts.length > 2 ? parts[2] ?? 1 : 1;
  return DateTime.utc(y, m, d).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

int dayNumber(DateTime d) => dayNumberFromString(localDayString(d));

String dayStringFromNumber(int n) => DateTime.fromMillisecondsSinceEpoch(
  n * Duration.millisecondsPerDay,
  isUtc: true,
).toIso8601String().substring(0, 10);

/// Đồng hồ có thể thay trong test.
typedef Clock = DateTime Function();
