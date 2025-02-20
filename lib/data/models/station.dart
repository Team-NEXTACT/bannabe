import 'package:flutter/material.dart';

class Station {
  final int id; // PK (bigint)
  final String name; // 스테이션 이름
  final String address; // 스테이션 주소
  final double latitude; // 스테이션 위도
  final double longitude; // 스테이션 경도
  final String business_time; // 영업시간
  final String stations_status; // 스테이션 상태 (영업 중, 휴일,…)
  final String grade; // 스테이션 등급

  const Station({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.business_time,
    required this.stations_status,
    required this.grade,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      business_time: json['business_time'] as String? ?? '10:00 - 21:00',
      stations_status: json['stations_status'] as String? ?? '영업중',
      grade: json['grade'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'business_time': business_time,
      'stations_status': stations_status,
      'grade': grade,
    };
  }

  String get operatingHours => business_time;

  // 상태에 따른 색상
  Color get statusColor {
    switch (stations_status) {
      case '영업중':
        return Colors.green;
      case '준비중':
        return Colors.orange;
      case '운영 종료':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
