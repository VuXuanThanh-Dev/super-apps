import 'package:flutter/material.dart';

/// StatelessWidget: chỉ phụ thuộc vào tham số truyền vào (giống component "dumb" trong Angular).
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.following,
    required this.onFollow,
  });

  final String name;
  final String role;
  final bool following;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(name.characters.first)),
        title: Text(name),
        subtitle: Text(role),
        trailing: FilledButton.tonal(onPressed: onFollow, child: Text(following ? 'Đang theo dõi' : 'Theo dõi')),
      ),
    );
  }
}

/// Cha giữ state `following` (lifting state up).
class ProfileDemo extends StatefulWidget {
  const ProfileDemo({super.key});

  @override
  State<ProfileDemo> createState() => _ProfileDemoState();
}

class _ProfileDemoState extends State<ProfileDemo> {
  bool _following = false;

  @override
  Widget build(BuildContext context) => ProfileCard(
    name: 'Nobin',
    role: 'Frontend lead',
    following: _following,
    onFollow: () => setState(() => _following = !_following),
  );
}
