enum AccessoryCategory {
  charger,
  cable,
  dock,
  powerBank,
  etc,
}

class Accessory {
  final String itemTypeId;
  final String name;
  final String description;
  final int price;
  final AccessoryCategory category;
  final int stock;
  final String imageUrl;

  Accessory({
    required this.itemTypeId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.imageUrl,
  });

  factory Accessory.fromJson(Map<String, dynamic> json) {
    return Accessory(
      itemTypeId: json['itemTypeId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      category: AccessoryCategory.values[json['category'] as int],
      stock: json['stock'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemTypeId': itemTypeId,
      'name': name,
      'description': description,
      'price': price,
      'category': category.index,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }

  bool get isAvailable => stock > 0;
}
