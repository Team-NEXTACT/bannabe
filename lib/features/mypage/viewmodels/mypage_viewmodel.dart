import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';

class MyPageViewModel extends ChangeNotifier {
  final _authService = AuthService.instance;
  final _userRepository = UserRepository();
  final _storageService = StorageService.instance;

  User? _user;
  String? _error;
  bool _isLoading = false;

  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;

  MyPageViewModel() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 마이페이지 진입 시 선택 정보 삭제
      await _storageService.clearSelections();

      if (!_authService.isAuthenticated) {
        _user = null;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final currentUser = _authService.currentUser;
      if (currentUser?.id == null) {
        _error = '사용자 ID를 찾을 수 없습니다.';
        _user = null;
      } else {
        final user = await _userRepository.get(currentUser!.id!);
        _user = user;
        _error = null;
      }
    } catch (e) {
      _error = '사용자 정보를 불러오는데 실패했습니다.';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
