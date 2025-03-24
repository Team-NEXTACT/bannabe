import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/models/user.dart';
import '../../data/models/bookmark_response.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

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
      print('프로필 조회 응답: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          _currentUser = User.fromJson(userData);
          await StorageService.instance
              .setObject('user', _currentUser!.toJson());

          // AuthService의 currentUser도 업데이트
          AuthService.instance.updateCurrentUser(_currentUser!);

          notifyListeners();
        } else {
          throw '사용자 정보 조회 실패: ${responseData['message'] ?? '알 수 없는 오류'}';
        }
      }
    } catch (e) {
      print('사용자 정보 가져오기 실패: ${e.toString()}');
      // 에러 발생 시 저장된 사용자 정보 로드
      _currentUser = await _getCurrentUser();
      if (_currentUser != null) {
        AuthService.instance.updateCurrentUser(_currentUser!);
      }
      notifyListeners();
    }
  }

  // 닉네임 변경
  Future<void> changeNickname(String nickname) async {
    try {
      final response = await ApiService.instance.patch(
        '/users/me/nickname',
        data: {'nickname': nickname},
      );

      if (response.statusCode == 200) {
        // 현재 사용자 정보 업데이트
        final currentUser = await _getCurrentUser();
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(nickname: nickname);
          await StorageService.instance.setObject('user', updatedUser.toJson());
          _currentUser = updatedUser;

          // AuthService의 currentUser도 업데이트
          AuthService.instance.updateCurrentUser(updatedUser);

          notifyListeners();
        }
      } else {
        throw Exception('닉네임 변경 실패: 서버 응답 오류');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          throw responseData['message'] as String;
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

  // 북마크한 스테이션 목록 조회
  Future<List<BookmarkStation>> getBookmarkedStations() async {
    try {
      final response =
          await ApiService.instance.get('/users/me/stations/bookmark');

      if (response.statusCode == 200 && response.data != null) {
        final bookmarkResponse = BookmarkResponse.fromJson(response.data);
        return bookmarkResponse.data.bookmarks;
      } else {
        throw Exception('북마크 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          throw responseData['message'] as String;
        }
      }
      throw '북마크 목록을 불러오는데 실패했습니다: ${e.toString()}';
    }
  }

  // 북마크 삭제
  Future<void> removeBookmark(int bookmarkId) async {
    try {
      final response = await ApiService.instance.delete(
        '/users/me/stations/bookmark/$bookmarkId',
      );

      if (response.statusCode != 200) {
        throw Exception('북마크 삭제에 실패했습니다.');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          throw responseData['message'] as String;
        }
      }
      throw '북마크 삭제에 실패했습니다: ${e.toString()}';
    }
  }
}
