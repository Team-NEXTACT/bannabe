import '../models/station.dart';
import '../../core/services/api_service.dart';

class StationRepository {
  static final StationRepository _instance = StationRepository._internal();
  static StationRepository get instance => _instance;

  StationRepository._internal();

  Future<List<Station>> getNearbyStations() async {
    try {
      final response = await ApiService.instance.get('/stations');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> stationsJson = response.data['data']['stations'];
        return stationsJson.map((json) => Station.fromJson(json)).toList();
      } else {
        throw '스테이션 목록을 불러오는데 실패했습니다.';
      }
    } catch (e) {
      throw '스테이션 목록을 불러오는데 실패했습니다: ${e.toString()}';
    }
  }

  Future<Station?> getStation(int stationId) async {
    try {
      final response = await ApiService.instance.get('/stations/$stationId');

      if (response.statusCode == 200 && response.data != null) {
        final stationJson = response.data['data']['station'];
        return Station.fromJson(stationJson);
      } else {
        throw '스테이션 정보를 불러오는데 실패했습니다.';
      }
    } catch (e) {
      throw '스테이션 정보를 불러오는데 실패했습니다: ${e.toString()}';
    }
  }
}
