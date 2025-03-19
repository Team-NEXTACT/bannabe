import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../services/storage_service.dart';
import '../services/token_service.dart';

class UserService with ChangeNotifier {
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8080/v1",
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  User? _currentUser;

  User? get currentUser => _currentUser;

  UserService._internal();

  // 사용자 프로필 정보 가져오기
  Future<void> fetchUserProfile() async {
    try {
      final response = await _dio.get('/users/me');

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data;
        _currentUser = User.fromJson(userData);
        await StorageService.instance.setObject('user', _currentUser!.toJson());
        notifyListeners();
      }
    } catch (e) {
      print('사용자 정보 가져오기 실패: ${e.toString()}');
      // 에러 발생 시 저장된 사용자 정보 로드
      _currentUser = await _getCurrentUser();
      notifyListeners();
    }
  }

  // 닉네임 변경
  Future<void> changeNickname(String nickname) async {
    try {
      final accessToken =
          await TokenService.instance.getAccessToken(); // 토큰 가져오기

      final response = await _dio.patch(
        '/users/me/nickname',
        data: {'nickname': nickname},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        // 현재 사용자 정보 업데이트
        final currentUser = await _getCurrentUser();
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(nickname: nickname);
          await StorageService.instance.setObject('user', updatedUser.toJson());
        }
      } else {
        throw Exception('닉네임 변경 실패: 서버 응답 오류');
      }
    } catch (e) {
      throw Exception('닉네임 변경 실패: ${e.toString()}');
    }
  }

  // 비밀번호 변경
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final accessToken =
          await TokenService.instance.getAccessToken(); // 토큰 가져오기

      final response = await _dio.put(
        '/users/me/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'newPasswordConfirm': newPasswordConfirm,
        }, options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
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
