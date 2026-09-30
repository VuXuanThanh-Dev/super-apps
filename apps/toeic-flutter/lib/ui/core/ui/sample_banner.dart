import 'package:flutter/material.dart';

/// Hiện khi app đang dùng bộ dữ liệu MẪU (private-data rỗng).
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('sample-banner'),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Sample data (16 words). Build the full dataset: bash tools/build_data.sh · '
          'Đang dùng dữ liệu mẫu — xem README để tạo dữ liệu đầy đủ.',
          style: TextStyle(color: scheme.onSecondaryContainer),
        ),
      ),
    );
  }
}
