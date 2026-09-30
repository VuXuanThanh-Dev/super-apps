import 'package:flutter/material.dart';

/// Row / Column / Expanded / Padding — tương đương Flexbox.
class PriceCard extends StatelessWidget {
  const PriceCard({super.key, required this.title, required this.price, required this.features});

  final String title;
  final String price;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Expanded chiếm hết chỗ còn lại (giống flex: 1).
                Expanded(child: Text(title, style: text.titleLarge)),
                Text(price, style: text.titleLarge?.copyWith(color: scheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            for (final f in features)
              Row(
                children: [
                  Icon(Icons.check, size: 18, color: scheme.tertiary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(f)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Adaptive layout: số cột theo bề rộng (breakpoint giống Material 3 window size classes).
int columnsForWidth(double width) {
  if (width >= 840) return 3; // expanded
  if (width >= 600) return 2; // medium
  return 1; // compact (điện thoại dọc)
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder cho biết ràng buộc (constraints) mà cha trao cho widget này.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsForWidth(constraints.maxWidth);
        return GridView.count(
          crossAxisCount: columns,
          childAspectRatio: columns == 1 ? 2.4 : 1.4,
          padding: const EdgeInsets.all(8),
          children: children,
        );
      },
    );
  }
}

/// Dùng màu và chữ từ Theme — không viết mã màu cứng, để dark mode tự đúng.
class ThemeSwatch extends StatelessWidget {
  const ThemeSwatch({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget chip(String label, Color bg, Color fg) => Chip(
      label: Text(label, style: TextStyle(color: fg)),
      backgroundColor: bg,
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip('primary', scheme.primary, scheme.onPrimary),
        chip('secondary', scheme.secondary, scheme.onSecondary),
        chip('tertiary', scheme.tertiary, scheme.onTertiary),
        chip('error', scheme.error, scheme.onError),
        chip('surface', scheme.surfaceContainerHighest, scheme.onSurface),
      ],
    );
  }
}

class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const cards = [
      PriceCard(title: 'Miễn phí', price: '0đ', features: ['Học Tập 1', 'App Việc Cần Làm']),
      PriceCard(title: 'Chăm chỉ', price: '1 giờ/ngày', features: ['Tập 2', 'SQLite, TTS', 'Thông báo']),
      PriceCard(title: 'Chuyên gia', price: '2 giờ/ngày', features: ['Tập 3', 'CI/CD', 'Phát hành']),
    ];
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(8), child: ThemeSwatch()),
        Expanded(child: AdaptiveGrid(children: cards)),
      ],
    );
  }
}
