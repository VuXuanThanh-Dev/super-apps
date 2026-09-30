import 'dart:math' as math;

/// Bài 1: sealed class Shape + diện tích bằng switch expression.
sealed class Shape {
  const Shape();
}

final class Circle extends Shape {
  const Circle(this.radius);
  final double radius;
}

final class Rectangle extends Shape {
  const Rectangle(this.width, this.height);
  final double width, height;
}

double area(Shape shape) => switch (shape) {
  Circle(:final radius) => math.pi * radius * radius,
  Rectangle(:final width, :final height) => width * height,
};

/// Bài 2: đếm số lần xuất hiện của mỗi từ (không phân biệt hoa thường, bỏ dấu câu).
Map<String, int> countWords(String text) {
  final counts = <String, int>{};
  final words = text.toLowerCase().split(RegExp(r"[^a-zA-ZÀ-ỹ']+")).where((w) => w.isNotEmpty);
  for (final w in words) {
    counts.update(w, (n) => n + 1, ifAbsent: () => 1);
  }
  return counts;
}
