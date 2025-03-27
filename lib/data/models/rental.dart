enum RentalStatus {
  active, // 대여중
  completed, // 반납 완료
  overdue, // 연체
  overdueCompleted, // 연체 결제
}

class Rental {
  final String name;
  final String status;
  final int rentalTimeHour;
  final DateTime startTime;
  final DateTime expectedReturnTime;
  final String token;

  Rental({
    required this.name,
    required this.status,
    required this.rentalTimeHour,
    required this.startTime,
    required this.expectedReturnTime,
    required this.token,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      name: json['name'] as String,
      status: json['status'] as String,
      rentalTimeHour: json['rentalTimeHour'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      expectedReturnTime: DateTime.parse(json['expectedReturnTime'] as String),
      token: json['token'] as String,
    );
  }

  String get formattedRentalTime {
    final startTimeStr = startTime.toString().substring(0, 16);
    final endTimeStr = expectedReturnTime.toString().substring(0, 16);
    return '$startTimeStr ~ $endTimeStr';
  }

  // 남은 시간 계산
  Duration get remainingTime {
    final remaining = expectedReturnTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isActive => status == '대여중';
  bool get isCompleted => status == '반납';
  bool get isOverdue => remainingTime == Duration.zero && isActive;

  int get overdueFee {
    if (!isOverdue) return 0;
    final rentalDuration = Duration(hours: rentalTimeHour);
    final actualDuration = expectedReturnTime.difference(startTime);
    final overdueDuration = actualDuration - rentalDuration;
    // 1.5배 연체료
    return (overdueDuration.inHours > 0
            ? (overdueDuration.inHours *
                (rentalTimeHour * 1000 ~/ rentalDuration.inHours) *
                1.5)
            : 0)
        .toInt();
  }

  Duration get overdueDuration {
    if (!isOverdue) return Duration.zero;
    final rentalDuration = Duration(hours: rentalTimeHour);
    final actualDuration = expectedReturnTime.difference(startTime);
    return actualDuration - rentalDuration;
  }

  Duration get totalRentalTime {
    // 시간당 1000원으로 계산
    final hours = rentalTimeHour;
    return Duration(hours: hours > 0 ? hours : 1); // 최소 1시간
  }
}
