import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../../data/models/station_response.dart';
import '../../data/models/rental_item_detail_response.dart';

class StationService with ChangeNotifier {
  static final StationService _instance = StationService._internal();
  static StationService get instance => _instance;

  StationService._internal();

  // 스테이션의 대여 가능 아이템 조회
  Future<StationResponse> getStationRentalItems(int stationId) async {
    try {
      final response = await ApiService.instance.get('/stations/$stationId');

      if (response.statusCode == 200 && response.data != null) {
        final stationResponse = StationResponse.fromJson(response.data);

        if (stationResponse.success) {
          return stationResponse;
        } else {
          throw stationResponse.message;
        }
      } else {
        throw '대여 가능한 물품 목록을 불러오는데 실패했습니다.';
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          throw responseData['message'] as String;
        }
      }
      throw '대여 가능한 물품 목록을 불러오는데 실패했습니다: ${e.toString()}';
    }
  }

  // 스테이션의 특정 아이템 상세 정보 조회
  Future<RentalItemDetailResponse> getRentalItemDetail(
      int stationId, int itemTypeId) async {
    try {
      final response = await ApiService.instance
          .get('/stations/$stationId/items/$itemTypeId');

      if (response.statusCode == 200 && response.data != null) {
        final itemDetailResponse =
            RentalItemDetailResponse.fromJson(response.data);

        if (itemDetailResponse.success) {
          return itemDetailResponse;
        } else {
          throw itemDetailResponse.message;
        }
      } else {
        throw '대여 물품 상세 정보를 불러오는데 실패했습니다.';
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          throw responseData['message'] as String;
        }
      }
      throw '대여 물품 상세 정보를 불러오는데 실패했습니다: ${e.toString()}';
    }
  }
}
