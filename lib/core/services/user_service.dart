import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class UserService with ChangeNotifier {
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;

  User? _currentUser;
  User? get currentUser => _currentUser;

  UserService._internal();

  // 사용자 프로필 정보 가져오기
  Future<void> fetchUserProfile() async {
    try {
      final response = await ApiService.instance.get('/users/me');

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data;
        _currentUser = User.fromJson(userData);
        await StorageService.instance.setObject('user', _currentUser!.toJson());
        notifyListeners();
      }
    } catch (e) {
      print('사용자 정보 가져오기 실패: ${e.toString()}');
      _currentUser = await _getCurrentUser();
      notifyListeners();
    }
  }

  // 닉네임 변경
  Future<void> changeNickname(String nickname) async {
    try {
      print('닉네임 변경 요청 - URL: /users/me/nickname');
      print('요청 데이터: ${{'nickname': nickname}}');

      final response = await ApiService.instance.patch(
        '/users/me/nickname',
        data: {'nickname': nickname},
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.data}');
      print('응답 헤더: ${response.headers}');

      if (response.statusCode == 200) {
        final currentUser = await _getCurrentUser();
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(nickname: nickname);
          await StorageService.instance.setObject('user', updatedUser.toJson());
          _currentUser = updatedUser;
          notifyListeners();
        }
      } else {
        throw Exception('닉네임 변경 실패: 서버 응답 오류');
      }
    } catch (e) {
      print('에러 상세 정보:');
      if (e is DioException) {
        print('요청 데이터: ${e.requestOptions.data}');
        print('요청 헤더: ${e.requestOptions.headers}');
        print('응답 상태 코드: ${e.response?.statusCode}');
        print('응답 데이터: ${e.response?.data}');

        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            throw responseData['message'] as String;
          }
        }
      }
      throw '닉네임 변경 실패: ${e.toString()}';
    }
  }

  // 비밀번호 변경
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final response = await ApiService.instance.put(
        '/users/me/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'newPasswordConfirm': newPasswordConfirm,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('비밀번호 변경 실패: 서버 응답 오류');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          throw responseData['message'] as String;
        }
      }
      throw '비밀번호 변경 실패: ${e.toString()}';
    }
  }

  // 현재 사용자 정보 가져오기
  Future<User?> _getCurrentUser() async {
    final savedUser = await StorageService.instance.getObject('user');
    if (savedUser != null) {
      try {
        return User.fromJson(savedUser);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
