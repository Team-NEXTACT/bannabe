import '../models/station.dart';

class StationRepository {
  static final StationRepository _instance = StationRepository._internal();
  static StationRepository get instance => _instance;

  StationRepository._internal();

  Future<List<Station>> getNearbyStations() async {
    // TODO: 실제 API 연동
    await Future.delayed(const Duration(seconds: 1));
    return [
      const Station(
        id: 1,
        name: '강남역점',
        address: '서울특별시 강남구 강남대로 396',
        latitude: 37.498095,
        longitude: 127.027610,
        business_time: '10:00 - 21:00',
        stations_status: '영업중',
        grade: '1',
      ),
      const Station(
        id: 2,
        name: '홍대입구역점',
        address: '서울특별시 마포구 양화로 160',
        latitude: 37.557192,
        longitude: 126.924618,
        business_time: '10:00 - 21:00',
        stations_status: '영업중',
        grade: '1',
      ),
      const Station(
        id: 3,
        name: '커피빈 강남역먹자골목점',
        address: '서울특별시 강남구 강남대로 414',
        latitude: 37.499723,
        longitude: 127.027428,
        business_time: '07:00 - 22:00',
        stations_status: '영업중',
        grade: '1',
      ),
      const Station(
        id: 4,
        name: '스타벅스 강남GT타워점',
        address: '서울특별시 강남구 테헤란로 134',
        latitude: 37.498688,
        longitude: 127.026013,
        business_time: '07:00 - 22:00',
        stations_status: '영업중',
        grade: '1',
      ),
    ];
  }

  Future<Station?> getStation(int id) async {
    final stations = await getNearbyStations();
    return stations.firstWhere(
      (station) => station.id == id,
      orElse: () => throw Exception('Station not found'),
    );
  }
}
