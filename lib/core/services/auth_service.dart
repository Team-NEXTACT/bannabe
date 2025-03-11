import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/models/user.dart';
import '../services/storage_service.dart';
import '../../data/repositories/auth_repository.dart';

class AuthService with ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  static Future<void> initialize() async {
    await _instance._init();
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8080/v1/auth",
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthService._internal();

  Future<void> _init() async {
    await StorageService.instance.init();
    // 저장된 사용자 정보가 있는지 확인
    final savedUser = await StorageService.instance.getObject('user');
    if (savedUser != null) {
      try {
        _currentUser = User.fromJson(savedUser);
      } catch (e) {
        // 저장된 사용자 정보가 유효하지 않은 경우
        await StorageService.instance.remove('user');
      }
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      // API 호출로 로그인 요청
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        // 서버 응답에서 사용자 ID만 추출
        final userData = response.data;

        // 사용자 정보 설정 (ID만 저장)
        _currentUser = User(
          id: userData['id'] ?? '',
          email: email,
        );

        // 토큰이 있다면 저장
        if (userData['token'] != null) {
          await StorageService.instance.setString('token', userData['token']);
        }

        await StorageService.instance.setObject('user', _currentUser!.toJson());
        notifyListeners();
      } else {
        throw Exception('로그인 실패: 서버 응답 오류');
      }
    } catch (e) {
      throw Exception('로그인 실패: ${e.toString()}');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // API 호출로 회원가입 요청
      final response = await _dio.post('/register', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('회원가입 실패: 서버 응답 오류 (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('회원가입 실패: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      _currentUser = null;
      await StorageService.instance.remove('user');
      await StorageService.instance.remove('token');
      notifyListeners();
    } catch (e) {
      throw Exception('로그아웃 실패: ${e.toString()}');
    }
  }

  // 테스트용 사용자 설정
  void setTestUser(String email) {
    _currentUser = User(
      id: 'test-user-id',
      email: email,
      nickname: '반나비',
      profileImageUrl: 'assets/images/profile.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // 인증코드 메일발송
  Future<bool> sendVerificationCode(String email) async {
    try {
      final response = await _dio.post('/send-code', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('인증코드 발송 실패: ${e.toString()}');
    }
  }

  // 인증코드 검증
  Future<bool> verifyCode(String email, String authCode) async {
    try {
      final response = await _dio.post('/verify-code', data: {
        'email': email,
        'authCode': authCode,
      });

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('인증코드 검증 실패: ${e.toString()}');
    }
  }

  // 비밀번호 변경(재설정)
  Future<bool> resetPassword(String email, String authCode, String newPassword,
      String newPasswordConfirm) async {
    try {
      final response = await _dio.put('/reset-password', data: {
        'email': email,
        'authCode': authCode,
        'newPassword': newPassword,
        'newPasswordConfirm': newPasswordConfirm,
      });

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      // DioError에서 서버 응답 메시지 추출
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          // Exception 객체 대신 문자열을 직접 throw
          throw responseData['message'] as String;
        }
      }
      throw '비밀번호 재설정 실패: ${e.toString()}';
    }
  }
}
