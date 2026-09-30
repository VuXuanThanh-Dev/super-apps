import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch03/dart_basics.dart';
import 'package:tap1_viec_can_lam/chapters/ch03/exercise_solution.dart';

void main() {
  group('Chương 3 — Dart cho TypeScript developer', () {
    test('null safety: ?? và tryParse', () {
      expect(greet(null), 'Xin chào, bạn!');
      expect(greet('Nobin'), 'Xin chào, Nobin!');
      expect(parseScore(' 785 '), 785);
      expect(parseScore('abc'), isNull);
    });

    test('record: minMax và parseEntry', () {
      final (min, max) = minMax([5, 1, 9, 3]);
      expect((min, max), (1, 9));
      expect(parseEntry('negotiate (v)'), (word: 'negotiate', pos: 'v'));
      expect(parseEntry('không có từ loại'), isNull);
      expect(() => minMax([]), throwsArgumentError);
    });

    test('switch expression với relational pattern', () {
      expect(describeScore(950), 'Xuất sắc');
      expect(describeScore(785), 'Tốt');
      expect(describeScore(600), 'Khá');
      expect(describeScore(300), 'Cần cố gắng');
      expect(describeScore(1000), 'Điểm không hợp lệ');
    });

    test('sealed class + pattern matching', () {
      expect(renderState(const Loading()), 'Đang tải…');
      expect(renderState(const Success([])), 'Chưa có từ nào');
      expect(renderState(const Success(['a', 'b'])), 'Có 2 từ: a, b');
      expect(renderState(const Failure('mất mạng')), 'Lỗi: mất mạng');
    });

    test('class: named constructor, primary constructor (Dart 3.13)', () {
      final v = Vocabulary.fromMap({'word': 'invoice', 'meaning': 'hóa đơn'});
      expect(v.toString(), 'invoice = hóa đơn (cấp 1)');
      const pair = WordPair('deadline', 'hạn chót');
      expect(pair.display, 'deadline → hạn chót');
    });

    test('extension: bỏ dấu tiếng Việt', () {
      expect('Đàm phán'.withoutAccents, 'dam phan');
      expect('Hóa đơn ƯU TIÊN'.withoutAccents, 'hoa don uu tien');
    });

    test('collection if / for / spread', () {
      expect(buildMenu(loggedIn: false, extra: ['cài đặt']), ['Trang chủ', 'Đăng nhập', 'CÀI ĐẶT', 'Giới thiệu']);
    });

    test('async/await', () async {
      final v = await fetchWord('budget');
      expect(v.meaning, 'nghĩa của budget');
      await expectLater(fetchWord(''), throwsArgumentError);
    });

    test('Bài 1: diện tích Shape', () {
      expect(area(const Rectangle(2, 3)), 6);
      expect(area(const Circle(1)), closeTo(3.14159, 0.0001));
    });

    test('Bài 2: countWords', () {
      expect(countWords('Deadline, deadline! Hạn chót.'), {'deadline': 2, 'hạn': 1, 'chót': 1});
    });
  });
}
