import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap3_so_ghi_chu/core/platform/battery_channel.dart';

/// Test phía Dart của platform channel: giả lập phía native bằng setMockMethodCallHandler.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(BatteryChannel.channelName);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('getBatteryLevel trả 87', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return call.method == 'getBatteryLevel' ? 87 : null;
    });
    expect(await const BatteryChannel().batteryLevel(), 87);
    expect(calls, ['getBatteryLevel']);
  });

  test('native báo lỗi UNAVAILABLE → null', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => throw PlatformException(code: 'UNAVAILABLE'));
    expect(await const BatteryChannel().batteryLevel(), isNull);
  });

  test('không có code native (web, chưa đăng ký) → null', () async {
    expect(await const BatteryChannel().batteryLevel(), isNull);
  });

  test('Bài tập: isLowPowerMode', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => call.method == 'isLowPowerMode' ? true : null);
    expect(await const BatteryChannel().lowPowerMode(), isTrue);
  });
}
