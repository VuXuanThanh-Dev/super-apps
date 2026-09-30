import 'package:flutter/material.dart';

/// Navigator cơ bản (imperative): push một màn hình và NHẬN KẾT QUẢ khi nó pop.
class ColorPickerHome extends StatefulWidget {
  const ColorPickerHome({super.key});

  @override
  State<ColorPickerHome> createState() => _ColorPickerHomeState();
}

class _ColorPickerHomeState extends State<ColorPickerHome> {
  String _picked = 'chưa chọn';

  Future<void> _pick() async {
    // push trả về Future: hoàn thành khi màn hình kia gọi Navigator.pop(context, value).
    final result = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (context) => const ColorChoiceScreen()));
    if (!mounted) return; // widget có thể đã bị gỡ trong lúc chờ
    setState(() => _picked = result ?? 'đã hủy');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Màu: $_picked'),
          const SizedBox(height: 12),
          FilledButton(onPressed: _pick, child: const Text('Chọn màu')),
        ],
      ),
    );
  }
}

class ColorChoiceScreen extends StatelessWidget {
  const ColorChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn một màu')),
      body: ListView(
        children: [
          for (final c in const ['Đỏ', 'Xanh lá', 'Xanh dương'])
            ListTile(title: Text(c), onTap: () => Navigator.pop(context, c)),
        ],
      ),
    );
  }
}
