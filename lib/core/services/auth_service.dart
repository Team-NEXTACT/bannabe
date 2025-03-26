import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/models/user.dart';
import '../services/storage_service.dart';
import '../services/token_service.dart';

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

    // 토큰이 있는지 확인
    final hasToken = await TokenService.instance.hasAccessToken();
    if (!hasToken) {
      // 토큰이 없으면 저장된 사용자 정보도 삭제
      await StorageService.instance.remove('user');
      _currentUser = null;
      return;
    }

    // 저장된 사용자 정보가 있는지 확인
    final savedUser = await StorageService.instance.getObject('user');
    if (savedUser != null) {
      try {
        _currentUser = User.fromJson(savedUser);
        notifyListeners();
      } catch (e) {
        // 저장된 사용자 정보가 유효하지 않은 경우
        await StorageService.instance.remove('user');
        _currentUser = null;
      }
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      print('로그인 시도 - 이메일: $email');

      // API 호출로 로그인 요청
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      print('로그인 응답: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        print('로그인 성공 - 응답 데이터: $responseData');

        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];

          // JWT 토큰 저장
          if (userData['accessToken'] != null &&
              userData['refreshToken'] != null) {
            print('토큰 저장 시도');
            await TokenService.instance.setTokens(
              accessToken: userData['accessToken'],
              refreshToken: userData['refreshToken'],
            );
            print('토큰 저장 완료');

            // 저장된 토큰 확인
            final savedToken = await TokenService.instance.getAccessToken();
            print('저장 후 확인한 액세스 토큰: $savedToken');

            // 사용자 정보 설정
            _currentUser = User(
              id: userData['id'] ?? '',
              email: email,
              nickname: userData['nickname'],
              profileImageUrl: userData['profileImage'],
            );

            await StorageService.instance
                .setObject('user', _currentUser!.toJson());
            notifyListeners();
          } else {
            print(
                '토큰 누락: accessToken=${userData['accessToken']}, refreshToken=${userData['refreshToken']}');
            throw Exception('로그인 실패: 토큰 정보가 없습니다.');
          }
        } else {
          throw Exception('로그인 실패: 잘못된 응답 형식');
        }
      } else {
        throw Exception('로그인 실패: 서버 응답 오류');
      }
    } catch (e) {
      print('로그인 에러: ${e.toString()}');
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
      print('[DEBUG] 로그아웃 API 호출');

      // 토큰 가져오기
      final accessToken = await TokenService.instance.getAccessToken();
      final refreshToken = await TokenService.instance.getRefreshToken();

      if (accessToken == null) {
        throw Exception('로그아웃 실패: 인증 토큰이 없습니다.');
      }
      if (refreshToken == null) {
        throw Exception('로그아웃 실패: 리프레시 토큰이 없습니다.');
      }

      print('[DEBUG] 로그아웃 API 요청:');
      print('  - URL: ${_dio.options.baseUrl}/logout');
      print('  - Access Token: $accessToken');
      print('  - Refresh Token: $refreshToken');

      // 로그아웃 API 호출 (토큰 포함)
      final response = await _dio.post(
        '/logout',
        data: {
          'refreshToken': refreshToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => status! < 500, // 500 에러는 캐치하도록 설정
        ),
      );

      print('[DEBUG] 로그아웃 API 응답:');
      print('  - 상태 코드: ${response.statusCode}');
      print('  - 응답 데이터: ${response.data}');

      // 토큰 삭제
      await TokenService.instance.clearTokens();

      // 사용자 정보 삭제
      _currentUser = null;
      await StorageService.instance.remove('user');
      notifyListeners();
    } catch (e) {
      print('[DEBUG] 로그아웃 에러: $e');

      // API 호출이 실패하더라도 로컬 데이터는 삭제
      await TokenService.instance.clearTokens();
      _currentUser = null;
      await StorageService.instance.remove('user');
      notifyListeners();

      // 에러는 던지지 않고 로컬 로그아웃만 수행
      print('[DEBUG] 로컬 로그아웃 완료');
    }
  }

  // 사용자 정보 가져오기
  Future<void> fetchUserProfile() async {
    try {
      final response = await _dio.get('/profile');

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data;

        _currentUser = User(
          id: userData['id'] ?? '',
          email: userData['email'] ?? '',
          nickname: userData['nickname'],
          profileImageUrl: userData['profileImage'],
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : null,
          updatedAt: userData['updatedAt'] != null
              ? DateTime.parse(userData['updatedAt'])
              : null,
        );

        await StorageService.instance.setObject('user', _currentUser!.toJson());
        notifyListeners();
      }
    } catch (e) {
      print('사용자 정보 가져오기 실패: ${e.toString()}');
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

  // 현재 사용자 정보 업데이트
  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
