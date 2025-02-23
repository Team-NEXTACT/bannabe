enum RentalStatus {
  active, // 대여중
  completed, // 반납 완료
  overdue, // 연체
  overdueCompleted, // 연체 결제
}

class Rental {
  final String id;
  final String userId;
  final String accessoryId;
  final String stationId;
  final String accessoryName;
  final String stationName;
  final String? returnStationId;
  final String? returnStationName;
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
    this.returnStationId,
    this.returnStationName,
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
      returnStationId: json['returnStationId'] as String?,
      returnStationName: json['returnStationName'] as String?,
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
      'returnStationId': returnStationId,
      'returnStationName': returnStationName,
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

  bool get isOverdue {
    return status == RentalStatus.overdue;
  }

  int get overdueFee {
    if (!isOverdue) return 0;
    final rentalDuration = Duration(hours: totalPrice ~/ 1000);
    final actualDuration = updatedAt.difference(createdAt);
    final overdueDuration = actualDuration - rentalDuration;
    // 1.5배 연체료
    return (overdueDuration.inHours > 0
            ? (overdueDuration.inHours *
                (totalPrice ~/ rentalDuration.inHours) *
                1.5)
            : 0)
        .toInt();
  }

  Duration get overdueDuration {
    if (!isOverdue) return Duration.zero;
    final rentalDuration = Duration(hours: totalPrice ~/ 1000);
    final actualDuration = updatedAt.difference(createdAt);
    return actualDuration - rentalDuration;
  }

  Duration get totalRentalTime {
    // 시간당 1000원으로 계산
    final hours = totalPrice ~/ 1000;
    return Duration(hours: hours > 0 ? hours : 1); // 최소 1시간
  }

  String get formattedRentalTime {
    // 시간당 가격으로 대여 시간 계산
    final hours = totalPrice ~/ 1000;

    if (status == RentalStatus.overdue) {
      return '${hours > 0 ? hours : 1}시간 (연체)';
    } else {
      return '${hours > 0 ? hours : 1}시간 이용';
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
