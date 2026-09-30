// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Theo mẫu `Command` của docs chính thức (flutter/website:
// examples/app-architecture/command/lib/command.dart, giấy phép BSD). Chú thích tiếng Việt do sách thêm.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Bọc một hành động bất đồng bộ của ViewModel: biết đang chạy ([running]), lỗi ([error]),
/// xong ([completed]); chặn bấm nhiều lần. View lắng nghe Command để hiện spinner / lỗi.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  bool get error => _result is Error;
  bool get completed => _result is Ok;
  Result<T>? get result => _result;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return; // chặn bấm liên tục
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

final class Command0<T> extends Command<T> {
  Command0(this._action);
  final CommandAction0<T> _action;
  Future<void> execute() => _execute(_action);
}

final class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final CommandAction1<T, A> _action;
  Future<void> execute(A argument) => _execute(() => _action(argument));
}
