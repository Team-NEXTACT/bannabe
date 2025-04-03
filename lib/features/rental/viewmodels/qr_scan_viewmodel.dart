import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/rental.dart';
import '../../../data/repositories/accessory_repository.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../core/services/api_service.dart';
import 'package:dio/dio.dart';

class RentalItemResponse {
  final String name;
  final int price;
  final String currentStationName;

  RentalItemResponse({
    required this.name,
    required this.price,
    required this.currentStationName,
  });

  factory RentalItemResponse.fromJson(Map<String, dynamic> json) {
    return RentalItemResponse(
      name: json['name'] as String,
      price: json['price'] as int,
      currentStationName: json['currentStationName'] as String,
    );
  }
}

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
  RentalItemResponse? _rentalItemResponse;

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
  RentalItemResponse? get rentalItemResponse => _rentalItemResponse;

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
      // QR 코드에서 URL 확인
      if (!qrCode.startsWith('https://api.bannabe.io/rentals/')) {
        throw Exception('유효하지 않은 QR 코드입니다.');
      }

      // URL에서 토큰 추출
      final rentalItemToken = qrCode.split('/').last;

      // API 호출 시 validateStatus 추가
      final response = await ApiService.instance.get(
        '/rentals/$rentalItemToken',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          _rentalItemResponse =
              RentalItemResponse.fromJson(responseData['data']);

          final now = DateTime.now();
          _rental = Rental(
            name: _rentalItemResponse!.name,
            status: '대여중',
            rentalTimeHour: _rentalDuration,
            startTime: now,
            expectedReturnTime: now.add(Duration(hours: _rentalDuration)),
            token: rentalItemToken,
          );
        } else {
          throw Exception('대여 정보를 가져오는데 실패했습니다.');
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
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
        name: initialRental!.name,
        status: '반납',
        rentalTimeHour: initialRental!.rentalTimeHour,
        startTime: initialRental!.startTime,
        expectedReturnTime: initialRental!.expectedReturnTime,
        token: initialRental!.token,
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
