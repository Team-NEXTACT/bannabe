class StationResponse {
  final bool success;
  final String message;
  final StationData data;

  StationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StationResponse.fromJson(Map<String, dynamic> json) {
    return StationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: StationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class StationData {
  final List<RentalItem> rentalItems;

  StationData({
    required this.rentalItems,
  });

  factory StationData.fromJson(Map<String, dynamic> json) {
    return StationData(
      rentalItems: (json['rentalItems'] as List<dynamic>)
          .map((item) => RentalItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RentalItem {
  final int itemTypeId;
  final String name;
  final String image;
  final String category;
  final int stock;

  RentalItem({
    required this.itemTypeId,
    required this.name,
    required this.image,
    required this.category,
    required this.stock,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      itemTypeId: json['itemTypeId'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      category: json['category'] as String,
      stock: json['stock'] as int,
    );
  }
}
