import 'package:flutter/material.dart';

/// ListView.builder chỉ tạo widget cho các dòng đang hiện trên màn hình (lazy),
/// nên 1.000 dòng vẫn nhẹ. Giống `@for` + virtual scroll của Angular CDK.
class ContactList extends StatelessWidget {
  const ContactList({super.key, this.count = 1000});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemExtent: 56, // biết trước chiều cao → cuộn nhanh hơn
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(child: Text('${(i % 26) + 1}')),
        title: Text('Liên hệ ${i + 1}'),
      ),
    );
  }
}

/// CustomScrollView + slivers: app bar co giãn + danh sách có tiêu đề nhóm.
class SectionedWordList extends StatelessWidget {
  const SectionedWordList({super.key, required this.groups});

  final Map<String, List<String>> groups;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        const SliverAppBar.medium(title: Text('Từ vựng theo chữ cái'), pinned: true, automaticallyImplyLeading: false),
        for (final entry in groups.entries) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(entry.key, style: text.titleMedium),
            ),
          ),
          SliverList.builder(
            itemCount: entry.value.length,
            itemBuilder: (context, i) => ListTile(title: Text(entry.value[i])),
          ),
        ],
      ],
    );
  }
}

/// Vuốt để xóa (Dismissible). Key PHẢI ổn định và duy nhất (không dùng index).
class SwipeList extends StatefulWidget {
  const SwipeList({super.key, required this.initial});

  final List<String> initial;

  @override
  State<SwipeList> createState() => _SwipeListState();
}

class _SwipeListState extends State<SwipeList> {
  late final List<String> _items = [...widget.initial];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (context, i) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = _items[i];
        return Dismissible(
          key: ValueKey(item),
          onDismissed: (_) => setState(() => _items.remove(item)),
          background: ColoredBox(color: Theme.of(context).colorScheme.errorContainer),
          child: ListTile(title: Text(item)),
        );
      },
    );
  }
}
