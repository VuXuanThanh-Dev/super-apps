import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Future: một giá trị trong tương lai (≈ Promise).
Future<String> fetchGreeting(String name, {Duration delay = const Duration(milliseconds: 50)}) async {
  await Future<void>.delayed(delay);
  if (name.isEmpty) throw ArgumentError('Thiếu tên');
  return 'Xin chào $name';
}

/// Chạy song song và chờ tất cả (≈ Promise.all / forkJoin).
Future<List<String>> greetAll(List<String> names) => Future.wait([for (final n in names) fetchGreeting(n)]);

/// Stream: nhiều giá trị theo thời gian (≈ Observable). `async*` + `yield` tạo stream dễ dàng.
Stream<int> countdown(int from, {Duration interval = const Duration(seconds: 1)}) async* {
  for (var i = from; i >= 0; i--) {
    yield i;
    if (i > 0) await Future<void>.delayed(interval);
  }
}

/// StreamBuilder: widget build lại mỗi khi stream phát giá trị (≈ async pipe).
class CountdownView extends StatefulWidget {
  const CountdownView({super.key, this.from = 5});

  final int from;

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView> {
  // Tạo stream MỘT lần trong State — nếu tạo trong build, mỗi lần build sẽ đếm lại từ đầu.
  late final Stream<int> _stream = countdown(widget.from);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(connectionState: ConnectionState.done) => const Text('Hết giờ!'),
        AsyncSnapshot(:final data?) => Text('Còn $data giây'),
        _ => const Text('Chuẩn bị…'),
      },
    );
  }
}

/// Hàm tốn CPU: đếm từ dài trong văn bản lớn.
int countLongWords(String text) => text.split(RegExp(r'\s+')).where((w) => w.length >= 8).length;

/// Chạy trong isolate khác để không làm đứng UI (trên web: chạy cùng luồng).
Future<int> countLongWordsInBackground(String text) => compute(countLongWords, text);
