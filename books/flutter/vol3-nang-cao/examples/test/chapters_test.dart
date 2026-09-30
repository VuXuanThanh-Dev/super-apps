import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap3_so_ghi_chu/chapters/ch01/dependency_rules.dart';
import 'package:tap3_so_ghi_chu/chapters/ch02/exercise_solution.dart';
import 'package:tap3_so_ghi_chu/chapters/ch02/rebuild_demo.dart';
import 'package:tap3_so_ghi_chu/chapters/ch04/exercise_solution.dart';
import 'package:tap3_so_ghi_chu/chapters/ch04/security_utils.dart';
import 'package:tap3_so_ghi_chu/chapters/ch05/versioning.dart';
import 'package:tap3_so_ghi_chu/chapters/ch06/force_update.dart';

import 'helpers.dart';

void main() {
  group('Ch.1 — luật phụ thuộc (feature-first)', () {
    test('phát hiện vi phạm trong mã giả', () {
      final v = checkDependencyRules({
        'features/notes/data/x.dart':
            "import 'package:flutter/material.dart';\nimport '../../auth/data/pin_repository.dart';",
        'features/notes/ui/y.dart': "import 'package:flutter/material.dart';",
      });
      expect(v, hasLength(2));
    });

    test('Bài 1: core không được import features', () {
      expect(
        checkDependencyRules({'core/x.dart': "import '../features/auth/data/pin_repository.dart';"}),
        hasLength(1),
      );
    });

    test('mã thật của app không vi phạm', () {
      final lib = Directory('lib');
      final sources = {
        for (final f in lib.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')))
          f.path.substring(lib.path.length + 1).replaceAll(r'\', '/'): f.readAsStringSync(),
      };
      expect(sources.keys, contains('features/auth/data/pin_repository.dart'));
      expect(checkDependencyRules(sources), isEmpty);
    });
  });

  group('Ch.2 — performance', () {
    testWidgets('const không build lại; không const thì build lại', (tester) async {
      BuildCounter.counts.clear();
      await pumpApp(tester, const RebuildDemo());
      await tester.tap(find.text('setState'));
      await tester.pump();
      await tester.tap(find.text('setState'));
      await tester.pump();
      expect(BuildCounter.counts, {'const': 1, 'không const': 3});
    });

    testWidgets('Bài 1: child của AnimatedBuilder chỉ build một lần', (tester) async {
      BuildCounter.counts.clear();
      await pumpApp(tester, const SpinningLogo());
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(BuildCounter.counts['logo'], 1);
      await tester.pumpWidget(const SizedBox()); // gỡ để dừng animation lặp
    });
  });

  group('Ch.4 — bảo mật', () {
    test('parseNoteDeepLink chỉ nhận định dạng cho phép', () {
      expect(parseNoteDeepLink(Uri.parse('sochichu://notes/abc-1')), 'abc-1');
      expect(parseNoteDeepLink(Uri.parse('https://nobin.dev/notes/abc')), 'abc');
      expect(parseNoteDeepLink(Uri.parse('https://evil.com/notes/abc')), isNull);
      // Uri.parse CHUẨN HÓA "../.." → path chỉ còn "/etc" → id "etc". An toàn vì id chỉ dùng để tra cứu,
      // không bao giờ ghép thành đường dẫn file. Bài học: kiểm tra SAU khi parse, trên giá trị cuối cùng.
      expect(parseNoteDeepLink(Uri.parse('sochichu://notes/../../etc')), 'etc');
      expect(parseNoteDeepLink(Uri.parse('sochichu://notes/a/b')), isNull);
      expect(parseNoteDeepLink(Uri.parse('sochichu://notes/ABC')), isNull);
    });

    test('Bài 1: isWeakPin', () {
      for (final weak in ['0000', '1234', '9876', '2580', '111111']) {
        expect(isWeakPin(weak), isTrue, reason: weak);
      }
      expect(isWeakPin('2468'), isFalse);
      expect(isWeakPin('739104'), isFalse);
    });
  });

  group('Ch.5–6 — version', () {
    test('bumpBuildNumber và bumpVersion', () {
      expect(bumpBuildNumber('1.2.3+4'), '1.2.3+5');
      expect(() => bumpBuildNumber('1.2'), throwsFormatException);
      expect(bumpVersion('1.2.3+9', part: 'patch'), '1.2.4+1');
      expect(bumpVersion('1.2.3+9', part: 'minor'), '1.3.0+1');
      expect(bumpVersion('1.2.3', part: 'major'), '2.0.0+1');
    });

    test('compareVersions / needsForceUpdate', () {
      expect(compareVersions('1.10.0', '1.9.9'), greaterThan(0));
      expect(compareVersions('1.2.3+7', '1.2.3+1'), 0);
      expect(needsForceUpdate(installed: '1.2.0', minimumSupported: '1.3.0'), isTrue);
      expect(needsForceUpdate(installed: '2.0.0', minimumSupported: '1.3.0'), isFalse);
    });
  });
}
