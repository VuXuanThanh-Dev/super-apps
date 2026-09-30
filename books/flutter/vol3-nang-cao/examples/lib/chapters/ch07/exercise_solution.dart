import '../../core/logging/app_logger.dart';
import '../../core/logging/redact.dart';

/// Bài 1 Chương 7: xuất nhật ký thành văn bản để người dùng gửi kèm báo lỗi.
/// Chỉ lấy từ mức [minLevel] trở lên, mỗi dòng: "HH:mm:ss [level] message — error". Lỗi cũng được che.
String exportLogs(Iterable<LogRecord> records, {LogLevel minLevel = LogLevel.info}) {
  String two(int n) => n.toString().padLeft(2, '0');
  return records
      .where((r) => r.level.index >= minLevel.index)
      .map((r) {
        final t = '${two(r.time.hour)}:${two(r.time.minute)}:${two(r.time.second)}';
        final err = r.error == null ? '' : ' — ${redact('${r.error}')}';
        return '$t [${r.level.name}] ${r.message}$err';
      })
      .join('\n');
}
