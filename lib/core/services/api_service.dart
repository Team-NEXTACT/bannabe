import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import 'token_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;

  late final Dio _dio;
  final String _baseUrl = 'http://10.0.2.2:8080/v1'; // 개발 환경 기본 URL

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 요청 인터셉터 설정
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 스테이션 관련 API는 토큰 체크 스킵
          if (options.path.startsWith('/stations')) {
            return handler.next(options);
          }

          // 액세스 토큰이 있으면 헤더에 추가
          final accessToken = await TokenService.instance.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          } else {
            // 토큰이 없으면 로그인 페이지로 이동
            _navigateToLogin();
            return handler.reject(
              DioException(
                requestOptions: options,
                error: '인증 토큰이 없습니다.',
              ),
            );
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // 401 에러 처리 (토큰 만료)
          if (error.response?.statusCode == 401) {
            // 리프레시 토큰이 있는지 확인
            final refreshToken = await TokenService.instance.getRefreshToken();
            if (refreshToken != null) {
              try {
                // 리프레시 토큰으로 새 액세스 토큰 요청
                final response = await _dio.post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                  options: Options(headers: {'Authorization': null}),
                );

                if (response.statusCode == 200) {
                  // 새 토큰 저장
                  await TokenService.instance.setTokens(
                    accessToken: response.data['accessToken'],
                    refreshToken: response.data['refreshToken'],
                  );

                  // 원래 요청 재시도
                  final opts = error.requestOptions;
                  final newAccessToken =
                      await TokenService.instance.getAccessToken();
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';

                  final newResponse = await _dio.fetch(opts);
                  return handler.resolve(newResponse);
                }
              } catch (e) {
                // 리프레시 토큰도 만료된 경우
                await TokenService.instance.clearTokens();
                _navigateToLogin();
              }
            } else {
              // 리프레시 토큰이 없는 경우
              _navigateToLogin();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // 로그인 페이지로 이동
  void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.login,
        (route) => false,
      );
    }
  }

  // 전역 NavigatorKey
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // GET 요청
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(path,
          queryParameters: queryParameters, options: options);
    } on DioException {
      rethrow;
    }
  }

  // POST 요청
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.post(path, data: data, options: options);
    } on DioException {
      rethrow;
    }
  }

  // PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  // DELETE 요청
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  // PATCH 요청
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException {
      rethrow;
    }
  }
}
