import 'package:dio/dio.dart';
import '../data/models/user.dart';

class AuthService {
  final Dio _dio;
  User? _currentUser;

  AuthService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'YOUR_API_BASE_URL',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ));

  User? get currentUser => _currentUser;

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/signin', data: {
        'email': email,
        'password': password,
      });

      _currentUser = User.fromJson(response.data['user']);
      // TODO: 토큰 저장 구현
      return _currentUser!;
    } catch (e) {
      throw Exception('로그인에 실패했습니다.');
    }
  }

  Future<void> signOut() async {
    try {
      await _dio.post('/auth/signout');
      _currentUser = null;
      // TODO: 토큰 삭제 구현
    } catch (e) {
      throw Exception('로그아웃에 실패했습니다.');
    }
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'name': name,
        'phoneNumber': phoneNumber,
      });

      _currentUser = User.fromJson(response.data['user']);
      // TODO: 토큰 저장 구현
      return _currentUser!;
    } catch (e) {
      throw Exception('회원가입에 실패했습니다.');
    }
  }

  // 개발용 임시 메서드
  Future<void> signInWithTestUser() async {
    _currentUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      nickname: '테스트 사용자',
      profileImageUrl: 'https://example.com/images/profile.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
