import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Khung có thanh tab dưới đáy. `shell` là nội dung của tab đang chọn.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Bấm lại tab đang mở → quay về trang đầu của tab đó.
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Việc cần làm'),
          NavigationDestination(icon: Icon(Icons.science_outlined), label: 'Lab'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
