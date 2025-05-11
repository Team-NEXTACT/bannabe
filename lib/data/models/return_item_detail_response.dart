class ReturnItemDetailResponse {
  final bool success;
  final String message;
  final ReturnItemDetailData data;

  ReturnItemDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReturnItemDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReturnItemDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ReturnItemDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ReturnItemDetailData {
  final String rentalItemName;
  final RentalHistory rentalHistory;
  final RentalStation rentalStation;

  ReturnItemDetailData({
    required this.rentalItemName,
    required this.rentalHistory,
    required this.rentalStation,
  });

  factory ReturnItemDetailData.fromJson(Map<String, dynamic> json) {
    return ReturnItemDetailData(
      rentalItemName: json['rentalItemName'] as String,
      rentalHistory:
          RentalHistory.fromJson(json['rentalHistory'] as Map<String, dynamic>),
      rentalStation:
          RentalStation.fromJson(json['rentalStation'] as Map<String, dynamic>),
    );
  }
}

class RentalHistory {
  final String status;
  final int rentalTime;
  final DateTime startTime;
  final DateTime expectedReturnTime;

  RentalHistory({
    required this.status,
    required this.rentalTime,
    required this.startTime,
    required this.expectedReturnTime,
  });

  factory RentalHistory.fromJson(Map<String, dynamic> json) {
    return RentalHistory(
      status: json['status'] as String,
      rentalTime: json['rentalTime'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      expectedReturnTime: DateTime.parse(json['expectedReturnTime'] as String),
    );
  }
}

class RentalStation {
  final String rentalStationName;
  final String currentStationName;

  RentalStation({
    required this.rentalStationName,
    required this.currentStationName,
  });

  factory RentalStation.fromJson(Map<String, dynamic> json) {
    return RentalStation(
      rentalStationName: json['rentalStationName'] as String,
      currentStationName: json['currentStationName'] as String,
    );
  }
}
