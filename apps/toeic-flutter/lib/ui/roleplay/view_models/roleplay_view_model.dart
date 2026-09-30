import 'package:flutter/foundation.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/models/dataset.dart';

/// Tính năng 5 — hội thoại nhập vai: chọn vai của mình, câu của vai đó bị che;
/// tự nói trước rồi chạm để xem lại.
class RoleplayViewModel extends ChangeNotifier {
  RoleplayViewModel({required String roleplayId, required DatasetRepository dataset, required this._tts})
    : roleplay = dataset.roleplayById(roleplayId);

  final Roleplay? roleplay;
  final TtsService _tts;

  String? _myRole;
  final Set<int> _revealed = {};

  String? get myRole => _myRole;

  void setMyRole(String? role) {
    _myRole = role;
    _revealed.clear();
    notifyListeners();
  }

  bool isHidden(int line) => _myRole != null && roleplay!.lines[line].speaker == _myRole && !_revealed.contains(line);

  void reveal(int line) {
    _revealed.add(line);
    notifyListeners();
  }

  Future<void> speak(String text) => _tts.speak(text);
}
