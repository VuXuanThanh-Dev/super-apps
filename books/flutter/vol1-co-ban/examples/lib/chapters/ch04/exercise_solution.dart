import 'package:flutter/material.dart';

/// Bài 1 Chương 4: nút Thích. Số lượt thích là "giá trị suy ra" (derived) — không lưu state thứ hai.
class LikeButton extends StatefulWidget {
  const LikeButton({super.key, this.initialLikes = 0});

  final int initialLikes;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final likes = widget.initialLikes + (_liked ? 1 : 0);
    return TextButton.icon(
      onPressed: () => setState(() => _liked = !_liked),
      icon: Icon(_liked ? Icons.favorite : Icons.favorite_border, semanticLabel: _liked ? 'Bỏ thích' : 'Thích'),
      label: Text('$likes'),
    );
  }
}
