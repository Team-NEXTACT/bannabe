import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/rental.dart';
import '../../../data/repositories/accessory_repository.dart';
import '../../../data/repositories/station_repository.dart';

class QRScanViewModel extends ChangeNotifier {
  final AccessoryRepository _accessoryRepository;
  final int _rentalDuration;
  final bool isReturn;
  final dynamic initialRental;
  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  String? _error;
  Rental? _rental;
  bool _isReturnComplete = false;
  int _rating = 0;
  final _stationRepository = StationRepository.instance;

  QRScanViewModel({
    AccessoryRepository? accessoryRepository,
    required int rentalDuration,
    required this.isReturn,
    this.initialRental,
  })  : _accessoryRepository = accessoryRepository ?? AccessoryRepository(),
        _rentalDuration = rentalDuration {
    _checkCameraPermission();
  }

  bool get isProcessing => _isProcessing;
  bool get hasCameraPermission => _hasCameraPermission;
  String? get error => _error;
  Rental? get rental => _rental;
  bool get isReturnComplete => _isReturnComplete;
  int get rating => _rating;

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _hasCameraPermission = true;
      notifyListeners();
      return;
    }

    final result = await Permission.camera.request();
    _hasCameraPermission = result.isGranted;
    notifyListeners();
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    _hasCameraPermission = status.isGranted;
    notifyListeners();
    return status.isGranted;
  }

  Future<void> processRentalQRCode(String qrCode) async {
    if (_isProcessing) return;

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // QR 코드에서 액세서리 ID와 스테이션 ID, 시간당 가격 추출
      final parts = qrCode.split('_');
      if (parts.length != 3) {
        throw Exception('잘못된 QR 코드입니다.');
      }

      final scannedStationId = parts[0];
      final scannedAccessoryId = parts[1];
      final pricePerHour = int.parse(parts[2]);

      // 액세서리와 스테이션 정보 조회
      final accessory = await _accessoryRepository.get(scannedAccessoryId);
      final station =
          await _stationRepository.getStation(int.parse(scannedStationId));

      if (!accessory.isAvailable) {
        throw Exception('현재 대여할 수 없는 물품입니다.');
      }

      if (station == null) {
        throw Exception('스테이션 정보를 찾을 수 없습니다.');
      }

      _rental = Rental(
        id: 'rental-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'test-user-id',
        accessoryId: scannedAccessoryId,
        stationId: scannedStationId,
        accessoryName: accessory.name,
        stationName: station.name,
        totalPrice: pricePerHour,
        status: RentalStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> processReturnQRCode(String qrCode) async {
    if (initialRental == null) {
      _error = '반납할 대여 정보가 없습니다';
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // QR 코드에서 스테이션 ID 추출
      final stationId = qrCode.split('_')[0];

      // 반납 처리
      final now = DateTime.now();
      _rental = Rental(
        id: initialRental!.id,
        userId: initialRental!.userId,
        accessoryId: initialRental!.accessoryId,
        stationId: stationId,
        accessoryName: initialRental!.accessoryName,
        stationName: initialRental!.stationName,
        totalPrice: initialRental!.totalPrice,
        status: RentalStatus.completed,
        createdAt: initialRental!.createdAt,
        updatedAt: now,
      );
      _isReturnComplete = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _isProcessing = false;
    _rental = null;
    notifyListeners();
  }
}
