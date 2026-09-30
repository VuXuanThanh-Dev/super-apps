// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Lấy nguyên mẫu `Result` từ docs chính thức (flutter/website:
// examples/app-architecture/result/lib/result.dart, giấy phép BSD). Chú thích tiếng Việt do sách thêm.

/// Kết quả của một thao tác có thể lỗi: [Ok] (có giá trị) hoặc [Error] (có exception).
/// Dùng `switch` để xử lý cả hai nhánh — compiler bắt buộc đủ nhánh vì `sealed`.
sealed class Result<T> {
  const Result();

  /// Tạo kết quả thành công.
  const factory Result.ok(T value) = Ok._;

  /// Tạo kết quả lỗi.
  const factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Error<T> extends Result<T> {
  const Error._(this.error);

  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
