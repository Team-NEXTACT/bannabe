class RentalSuccessSimpleResponse {
  final int amount;
  final String itemName;
  final int rentalTime;
  final String stationName;

  RentalSuccessSimpleResponse({
    required this.amount,
    required this.itemName,
    required this.rentalTime,
    required this.stationName,
  });

  factory RentalSuccessSimpleResponse.fromJson(Map<String, dynamic> json) {
    return RentalSuccessSimpleResponse(
      amount: json['totalAmount'] as int,
      itemName: json['itemName'] as String,
      rentalTime: json['rentalTime'] as int,
      stationName: json['rentalStationName'] as String,
    );
  }
}
