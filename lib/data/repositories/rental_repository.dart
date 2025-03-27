import '../models/rental.dart';
import 'base_repository.dart';
import '../../core/services/api_service.dart';

class RentalRepository implements BaseRepository<Rental> {
  static final RentalRepository _instance = RentalRepository._internal();
  static RentalRepository get instance => _instance;

  RentalRepository._internal();

  @override
  Future<Rental> get(String id) async {
    // TODO: Implement actual API call
    throw UnimplementedError();
  }

  @override
  Future<List<Rental>> getAll() async {
    // TODO: Implement actual API call
    throw UnimplementedError();
  }

  @override
  Future<Rental> create(Rental rental) async {
    // TODO: Implement actual API call
    throw UnimplementedError();
  }

  @override
  Future<Rental> update(Rental rental) async {
    // TODO: Implement actual API call
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) async {
    // TODO: Implement actual API call
    throw UnimplementedError();
  }

  Future<List<Rental>> getActiveRentals() async {
    try {
      final response =
          await ApiService.instance.get('/users/me/rentals/active');
      print('대여 현황 응답: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> rentals = responseData['data']['rentals'] ?? [];
          return rentals.map((json) => Rental.fromJson(json)).toList();
        }
      }
      throw Exception('대여 정보를 가져오는데 실패했습니다');
    } catch (e) {
      print('대여 현황 에러: $e');
      throw '대여 정보를 가져오는데 실패했습니다: ${e.toString()}';
    }
  }

  Future<List<Rental>> getRecentRentals() async {
    try {
      final response = await ApiService.instance.get('/users/me/rentals');
      print('대여 내역 응답: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> rentals = responseData['data']['content'] ?? [];
          return rentals.map((json) => Rental.fromJson(json)).toList();
        }
      }
      throw Exception('대여 기록을 가져오는데 실패했습니다');
    } catch (e) {
      print('대여 내역 에러: $e');
      throw '대여 기록을 가져오는데 실패했습니다: ${e.toString()}';
    }
  }
}
