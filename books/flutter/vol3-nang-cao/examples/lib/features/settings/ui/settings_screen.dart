import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/platform/battery_channel.dart';
import '../../auth/ui/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int? _battery;
  bool _batteryLoaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadBattery());
  }

  Future<void> _loadBattery() async {
    final level = await context.read<BatteryChannel>().batteryLevel();
    if (!mounted) return;
    setState(() {
      _battery = level;
      _batteryLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final logger = context.watch<AppLogger>();
    final timeouts = {Duration(seconds: 30): '30 giây', Duration(minutes: 1): '1 phút', Duration(minutes: 5): '5 phút'};
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.battery_std),
            title: const Text('Pin (platform channel)'),
            subtitle: Text(
              !_batteryLoaded
                  ? 'Đang đọc…'
                  : _battery == null
                  ? 'Không hỗ trợ trên nền tảng này'
                  : '$_battery%',
            ),
          ),
          const Divider(),
          Text('Tự khóa khi ở nền quá', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<Duration>(
            segments: [for (final e in timeouts.entries) ButtonSegment(value: e.key, label: Text(e.value))],
            selected: {auth.autoLockAfter},
            onSelectionChanged: (s) => auth.setAutoLockAfter(s.first),
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Text('Nhật ký (${logger.records.length})', style: Theme.of(context).textTheme.titleSmall),
              ),
              TextButton(
                // Gây một lỗi bất đồng bộ để thấy PlatformDispatcher.onError ghi lại (Chương 7).
                onPressed: () => Future<void>.error(StateError('Lỗi thử nghiệm')),
                child: const Text('Gây lỗi thử'),
              ),
              TextButton(onPressed: logger.clear, child: const Text('Xóa')),
            ],
          ),
          for (final r in logger.records.reversed.take(20))
            ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(r.toString())),
        ],
      ),
    );
  }
}
