import 'dart:async';

import 'package:flutter/material.dart';

/// RxJS `debounceTime(300)` cho callback: chỉ chạy sau khi người dùng ngừng gõ [delay].
class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}

/// RxJS: `source.pipe(map(trim), filter(len >= 2), distinctUntilChanged())`
/// Dart Stream có sẵn map / where / distinct.
Stream<String> searchTerms(Stream<String> source) => source.map((s) => s.trim()).where((s) => s.length >= 2).distinct();

/// Ô tìm kiếm có debounce.
class SearchBox extends StatefulWidget {
  const SearchBox({super.key, required this.onSearch, this.delay = const Duration(milliseconds: 300)});

  final ValueChanged<String> onSearch;
  final Duration delay;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final Debouncer _debouncer = Debouncer(widget.delay);

  @override
  void dispose() {
    _debouncer.dispose(); // giống takeUntilDestroyed()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(labelText: 'Tìm kiếm', prefixIcon: Icon(Icons.search)),
      onChanged: (text) => _debouncer(() => widget.onSearch(text)),
    );
  }
}
