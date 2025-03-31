enum PaymentMethod {
  card,
  bank,
  point,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class Payment {
  final String id;
  final String userId;
  final String rentalId;
  final int amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.userId,
    required this.rentalId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rentalId: json['rentalId'] as String,
      amount: json['amount'] as int,
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['method'],
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'rentalId': rentalId,
      'amount': amount,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Payment copyWith({
    String? id,
    String? userId,
    String? rentalId,
    int? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rentalId: rentalId ?? this.rentalId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaymentCalculateRequest {
  final String rentalItemToken;
  final int rentalTime;

  PaymentCalculateRequest({
    required this.rentalItemToken,
    required this.rentalTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'rentalItemToken': rentalItemToken,
      'rentalTime': rentalTime,
    };
  }
}

class PaymentCalculateResponse {
  final String rentalItemToken;
  final int pricePerHour;
  final int rentalTime;
  final int amount;

  PaymentCalculateResponse({
    required this.rentalItemToken,
    required this.pricePerHour,
    required this.rentalTime,
    required this.amount,
  });

  factory PaymentCalculateResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCalculateResponse(
      rentalItemToken: json['rentalItemToken'] as String,
      pricePerHour: json['pricePerHour'] as int,
      rentalTime: json['rentalTime'] as int,
      amount: json['amount'] as int,
    );
  }
}
