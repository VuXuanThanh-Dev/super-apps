import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Cấu hình chung cho mọi test (flutter_test tự nạp file này).
/// Chạm trượt (tap vào widget bị che / ngoài màn hình) → test FAIL thay vì chỉ cảnh báo.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetController.hitTestWarningShouldBeFatal = true;
  await testMain();
}
