import '../models/rental.dart';
import 'base_repository.dart';

class RentalRepository implements BaseRepository<Rental> {
  static final RentalRepository _instance = RentalRepository._internal();
  static RentalRepository get instance => _instance;

  RentalRepository._internal();

  @override
  Future<Rental> get(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return Rental(
      id: id,
      userId: 'test-user-id',
      accessoryId: 'A1',
      stationId: 'S1',
      accessoryName: '보조배터리 10000mAh',
      stationName: '강남역점',
      totalPrice: 5000,
      status: RentalStatus.active,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<Rental>> getAll() async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      Rental(
        id: 'rental-1',
        userId: 'test-user-id',
        accessoryId: 'A1',
        stationId: 'S1',
        accessoryName: '보조배터리 10000mAh',
        stationName: '강남역점',
        totalPrice: 5000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      Rental(
        id: 'rental-2',
        userId: 'test-user-id',
        accessoryId: 'A2',
        stationId: 'S2',
        accessoryName: '충전케이블 (C타입)',
        stationName: '홍대입구역점',
        totalPrice: 7000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<Rental> create(Rental rental) async {
    await Future.delayed(const Duration(seconds: 1));
    return rental;
  }

  @override
  Future<Rental> update(Rental rental) async {
    await Future.delayed(const Duration(seconds: 1));
    return rental;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<Rental>> getByUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      Rental(
        id: 'rental-1',
        userId: userId,
        accessoryId: 'A1',
        stationId: 'S1',
        accessoryName: '보조배터리 10000mAh',
        stationName: '강남역점',
        totalPrice: 5000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      Rental(
        id: 'rental-2',
        userId: userId,
        accessoryId: 'A2',
        stationId: 'S2',
        accessoryName: '충전케이블 (C타입)',
        stationName: '홍대입구역점',
        totalPrice: 7000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<List<Rental>> getActiveRentals() async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      Rental(
        id: 'R1',
        userId: 'test@test.com',
        accessoryId: 'powerbank-1',
        stationId: 'S1',
        accessoryName: '노트북용 보조배터리',
        stationName: '강남역점',
        totalPrice: 3000,
        status: RentalStatus.active,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Rental(
        id: 'R2',
        userId: 'test@test.com',
        accessoryId: 'cable-3',
        stationId: 'S2',
        accessoryName: 'C to C 케이블',
        stationName: '홍대입구역점',
        totalPrice: 500,
        status: RentalStatus.active,
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  Future<List<Rental>> getRentalHistory(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      Rental(
        id: 'rental-1',
        userId: userId,
        accessoryId: 'A1',
        stationId: 'S1',
        accessoryName: '보조배터리 10000mAh',
        stationName: '강남역점',
        totalPrice: 5000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Rental(
        id: 'rental-2',
        userId: userId,
        accessoryId: 'A2',
        stationId: 'S2',
        accessoryName: '충전케이블 (C타입)',
        stationName: '홍대입구역점',
        totalPrice: 7000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<List<Rental>> getRecentRentals() async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();

    return [
      Rental(
        id: 'R3',
        userId: 'test@test.com',
        accessoryId: 'charger-1',
        stationId: 'S1',
        accessoryName: '노트북 고출력 충전기',
        stationName: '강남역점',
        returnStationId: 'S2',
        returnStationName: '홍대입구역점',
        totalPrice: 2000,
        status: RentalStatus.overdue,
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Rental(
        id: 'R4',
        userId: 'test@test.com',
        accessoryId: 'dock-3',
        stationId: 'S2',
        accessoryName: '멀티 독 (Type-C)',
        stationName: '홍대입구역점',
        returnStationId: 'S1',
        returnStationName: '강남역점',
        totalPrice: 2000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Rental(
        id: 'R5',
        userId: 'test@test.com',
        accessoryId: 'powerbank-2',
        stationId: 'S3',
        accessoryName: '휴대폰용 보조배터리',
        stationName: '명동점',
        returnStationId: 'S4',
        returnStationName: '여의도역점',
        totalPrice: 1500,
        status: RentalStatus.overdueCompleted,
        createdAt: now.subtract(const Duration(days: 3, hours: 5)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Rental(
        id: 'R6',
        userId: 'test@test.com',
        accessoryId: 'etc-1',
        stationId: 'S4',
        accessoryName: '발표용 리모콘',
        stationName: '여의도역점',
        totalPrice: 1000,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 4, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
