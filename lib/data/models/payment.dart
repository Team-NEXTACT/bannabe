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

enum PaymentType {
  RENT, // 대여 결제
  OVERDUE, // 연체 결제
  EXTENSION // 연장 결제
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

class PaymentCheckoutUrlResponse {
  final bool success;
  final String message;
  final String htmlContent;
  final String orderId;
  final String customerKey;

  PaymentCheckoutUrlResponse({
    required this.success,
    required this.message,
    required this.htmlContent,
    required this.orderId,
    required this.customerKey,
  });

  factory PaymentCheckoutUrlResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCheckoutUrlResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      htmlContent: json['data'] as String,
      orderId: json['orderId'] as String,
      customerKey: json['customerKey'] as String,
    );
  }
}
