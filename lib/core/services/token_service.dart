import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  static TokenService get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TokenService._internal();

  // 액세스 토큰과 리프레시 토큰 저장
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    print('TokenService - 토큰 저장 시도');
    print('저장할 액세스 토큰: $accessToken');
    print('저장할 리프레시 토큰: $refreshToken');

    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    print('TokenService - 토큰 저장 완료');
  }

  // 액세스 토큰 가져오기
  Future<String?> getAccessToken() async {
    print('TokenService - 액세스 토큰 가져오기 시도');
    final token = await _storage.read(key: 'access_token');
    print('TokenService - 가져온 액세스 토큰: $token');
    return token;
  }

  // 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    print('TokenService - 리프레시 토큰 가져오기 시도');
    final token = await _storage.read(key: 'refresh_token');
    print('TokenService - 가져온 리프레시 토큰: $token');
    return token;
  }

  // 토큰 삭제 (로그아웃 시 사용)
  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // 액세스 토큰 존재 여부 확인
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // 리프레시 토큰 존재 여부 확인
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }
}
