enum RentalStatus {
  active,
  completed,
  cancelled,
}

class Rental {
  final String id;
  final String userId;
  final String accessoryId;
  final String stationId;
  final String accessoryName;
  final String stationName;
  final int totalPrice;
  final RentalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rental({
    required this.id,
    required this.userId,
    required this.accessoryId,
    required this.stationId,
    required this.accessoryName,
    required this.stationName,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] as String,
      userId: json['userId'] as String,
      accessoryId: json['accessoryId'] as String,
      stationId: json['stationId'] as String,
      accessoryName: json['accessoryName'] as String,
      stationName: json['stationName'] as String,
      totalPrice: json['totalPrice'] as int,
      status: RentalStatus.values.firstWhere(
        (e) => e.toString() == 'RentalStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accessoryId': accessoryId,
      'stationId': stationId,
      'accessoryName': accessoryName,
      'stationName': stationName,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Duration get remainingTime {
    final rentalDuration = const Duration(hours: 24);
    final elapsedTime = DateTime.now().difference(createdAt);
    return rentalDuration - elapsedTime;
  }

  Duration get totalRentalTime {
    // 시간당 1000원으로 계산
    final hours = totalPrice ~/ 1000;
    return Duration(hours: hours);
  }

  String get formattedRentalTime {
    // 시간당 가격으로 대여 시간 계산
    final hours = totalPrice ~/ 1000;

    if (status == RentalStatus.active) {
      return '$hours시간';
    } else {
      return '$hours시간 이용';
    }
  }

  String get accessoryNameFromId {
    switch (accessoryId) {
      case 'A1':
        return '아이폰 충전기';
      case 'A2':
        return '보조배터리';
      case 'A3':
        return '안드로이드 충전기';
      case 'A4':
        return 'C타입 충전기';
      default:
        return '알 수 없는 악세서리';
    }
  }

  String get stationNameFromId {
    switch (stationId) {
      case 'S1':
        return '강남역점';
      case 'S2':
        return '홍대입구역점';
      case 'S3':
        return '명동점';
      case 'S4':
        return '여의도역점';
      default:
        return '알 수 없는 스테이션';
    }
  }
}
