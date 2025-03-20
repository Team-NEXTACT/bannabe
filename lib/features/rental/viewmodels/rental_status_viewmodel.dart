import 'package:flutter/foundation.dart';
import '../../../data/models/rental.dart';
import '../../../core/services/auth_service.dart';

class RentalStatusViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Rental> _activeRentals = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Rental> get activeRentals => _activeRentals;

  RentalStatusViewModel() {
    _loadActiveRentals();
  }

  Future<void> _loadActiveRentals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        _error = '로그인이 필요합니다';
        return;
      }

      // TODO: 실제 API 연동
      await Future.delayed(const Duration(seconds: 1));
      _activeRentals = [
        Rental(
          id: 'R123',
          userId: user.id,
          accessoryId: 'A1',
          stationId: 'S1',
          accessoryName: '보조배터리 10000mAh',
          stationName: '강남역점',
          totalPrice: 3000,
          status: RentalStatus.active,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now(),
        ),
        Rental(
          id: 'R124',
          userId: user.id,
          accessoryId: 'A2',
          stationId: 'S2',
          accessoryName: '충전케이블 (C타입)',
          stationName: '홍대입구역점',
          totalPrice: 4000,
          status: RentalStatus.active,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => _loadActiveRentals();
}
