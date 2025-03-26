class RentalItemDetailResponse {
  final bool success;
  final String message;
  final RentalItemDetail data;

  RentalItemDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RentalItemDetailResponse.fromJson(Map<String, dynamic> json) {
    return RentalItemDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: RentalItemDetail.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class RentalItemDetail {
  final String name;
  final String image;
  final String category;
  final String description;
  final int price;
  final int stock;

  RentalItemDetail({
    required this.name,
    required this.image,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
  });

  factory RentalItemDetail.fromJson(Map<String, dynamic> json) {
    return RentalItemDetail(
      name: json['name'] as String,
      image: json['image'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      stock: json['stock'] as int,
    );
  }
}
