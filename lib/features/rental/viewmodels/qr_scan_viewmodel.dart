import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/rental.dart';
import '../../../data/models/return_item_detail_response.dart';
import '../../../core/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../views/return_complete_screen.dart';

class RentalItemResponse {
  final String name;
  final int price;
  final String currentStationName;
  final int currentStationId;

  RentalItemResponse({
    required this.name,
    required this.price,
    required this.currentStationName,
    required this.currentStationId,
  });

  factory RentalItemResponse.fromJson(Map<String, dynamic> json) {
    return RentalItemResponse(
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      currentStationName: json['currentStationName']?.toString() ?? '',
      currentStationId: (json['currentStationId'] as num?)?.toInt() ?? 0,
    );
  }
}

class QRScanViewModel extends ChangeNotifier {
  final int _rentalDuration;
  final bool isReturn;
  final dynamic initialRental;
  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  String? _error;
  Rental? _rental;
  RentalItemResponse? _rentalItemResponse;
  ReturnItemDetailResponse? _returnItemDetail;

  QRScanViewModel({
    required int rentalDuration,
    required this.isReturn,
    this.initialRental,
  }) : _rentalDuration = rentalDuration {
    _checkCameraPermission();
  }

  bool get isProcessing => _isProcessing;
  bool get hasCameraPermission => _hasCameraPermission;
  String? get error => _error;
  Rental? get rental => _rental;
  RentalItemResponse? get rentalItemResponse => _rentalItemResponse;
  ReturnItemDetailResponse? get returnItemDetail => _returnItemDetail;

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
      if (!qrCode.startsWith('https://api.bannabe.io/rentals/')) {
        throw Exception('유효하지 않은 QR 코드입니다.');
      }

      final rentalItemToken = qrCode.split('/').last;

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
        throw response.data['message'] ?? '서버 응답 오류가 발생했습니다.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> processReturnQRCode(String qrCode, BuildContext context) async {
    if (_isProcessing) return;

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      if (!qrCode.startsWith('https://api.bannabe.io/rentals/')) {
        throw Exception('유효하지 않은 QR 코드입니다.');
      }

      final rentalItemToken = qrCode.split('/').last;
      print('Debug - rentalItemToken: $rentalItemToken');

      // 1. 반납할 물품 데이터 조회
      final detailResponse = await ApiService.instance.get(
        '/returns/$rentalItemToken',
        queryParameters: {
          'currentStationId':
              (initialRental as Map<String, dynamic>)['returnStationId'] ?? 4,
        },
        options: Options(validateStatus: (status) => status! < 500),
      );

      print('Debug - detailResponse status: ${detailResponse.statusCode}');
      print('Debug - detailResponse headers: ${detailResponse.headers}');
      print('Debug - detailResponse data: ${detailResponse.data}');

      if (detailResponse.statusCode == 200 && detailResponse.data != null) {
        _returnItemDetail =
            ReturnItemDetailResponse.fromJson(detailResponse.data);
        print('Debug - returnItemDetail: $_returnItemDetail');

        // 2. 반납 처리
        final currentStationId =
            (initialRental as Map<String, dynamic>)['returnStationId'] ?? 4;
        print('Debug - POST currentStationId: $currentStationId');

        final returnResponse = await ApiService.instance.post(
          '/returns/$rentalItemToken',
          data: {
            'returnStationId': currentStationId,
          },
          options: Options(validateStatus: (status) => status! < 500),
        );

        print('Debug - returnResponse: ${returnResponse.data}');

        if (returnResponse.statusCode == 200 && returnResponse.data != null) {
          final responseData = returnResponse.data;
          if (responseData['success'] == true) {
            // 반납 성공 시 ReturnCompleteScreen으로 이동
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ReturnCompleteScreen(),
              ),
            );
          } else {
            throw Exception('반납 처리에 실패했습니다.');
          }
        } else {
          throw returnResponse.data['message'] ?? '서버 응답 오류가 발생했습니다.';
        }
      } else {
        throw detailResponse.data['message'] ?? '물품 정보 조회에 실패했습니다.';
      }
    } catch (e) {
      print('Debug - Error: $e');
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
    _rentalItemResponse = null;
    _returnItemDetail = null;
    notifyListeners();
  }
}
