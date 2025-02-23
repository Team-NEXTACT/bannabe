import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../services/storage_service.dart';
import '../../data/repositories/auth_repository.dart';

class AuthService with ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  static Future<void> initialize() async {
    await _instance._init();
  }

  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthService._internal();

  Future<void> _init() async {
    await StorageService.instance.init();
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      _currentUser = User(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        name: fbUser.displayName ?? '사용자',
        phoneNumber: fbUser.phoneNumber ?? '',
        profileImageUrl: '', // 프로필 이미지 URL은 별도로 관리 필요
        createdAt: DateTime.now(), // Firebase에 저장된 시간으로 업데이트 가능
        updatedAt: DateTime.now(),
        rentals: [],
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        _currentUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ?? '사용자',
          phoneNumber: fbUser.phoneNumber ?? '',
          profileImageUrl: '', // 프로필 이미지 URL 추가 가능
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          rentals: [],
        );
        await StorageService.instance.setObject('user', _currentUser!.toJson());
      }
    } catch (e) {
      throw Exception('로그인 실패: ${e.toString()}');
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        // 사용자 이름 업데이트
        await fbUser.updateDisplayName(name);

        _currentUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          name: name,
          phoneNumber: phoneNumber,
          profileImageUrl: '', // 프로필 이미지 URL 추가 가능
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          rentals: [],
        );
        await StorageService.instance.setObject('user', _currentUser!.toJson());
      }
    } catch (e) {
      throw Exception('회원가입 실패: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      await StorageService.instance.remove('user');
    } catch (e) {
      throw Exception('로그아웃 실패: ${e.toString()}');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    try {
      await user.updateDisplayName(name);
      // TODO: phoneNumber 업데이트는 Firebase에서 직접 지원하지 않으므로
      // 필요한 경우 Firestore나 다른 데이터베이스에 저장
    } catch (e) {
      throw Exception('프로필 업데이트에 실패했습니다: $e');
    }
  }

  // 테스트용 사용자 설정
  void setTestUser(String email) {
    _currentUser = User(
      id: 'test-user-id',
      email: email,
      name: '반나비',
      phoneNumber: '010-1234-5678',
      profileImageUrl: 'assets/images/profile.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
}
