import 'rental.dart';

class User {
  final String? id;
  final String email;
  final String? nickname;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Rental> rentals;

  User({
    this.id,
    required this.email,
    this.nickname,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.rentals = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImage'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      rentals: json['rentals'] != null
          ? (json['rentals'] as List)
              .map((rental) => Rental.fromJson(rental))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profileImage': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Rental>? rentals,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rentals: rentals ?? this.rentals,
    );
  }

  List<Rental> get activeRentals =>
      rentals.where((rental) => rental.status == RentalStatus.active).toList();
  List<Rental> get completedRentals => rentals
      .where((rental) => rental.status == RentalStatus.completed)
      .toList();
  bool get hasActiveRental => activeRentals.isNotEmpty;
}
