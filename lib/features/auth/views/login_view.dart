import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/loading_animation.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = '이메일과 비밀번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 서버에 로그인 요청
      await AuthService.instance.signInWithEmail(email, password);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.mypage);
      }
    } catch (e) {
      setState(() {
        _error = '로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Bannabee',
                  style: AppTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                  ),
                  autocorrect: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                  ),
                  autocorrect: false,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                if (_isLoading)
                  const HoneyLoadingAnimation(isStationSelected: false)
                else
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('로그인'),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '아직 계정이 없으신가요?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.terms);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.forgotPassword);
                  },
                  child: const Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                // 카카오 로그인 버튼
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 45,
                    child: Material(
                      color: Colors.transparent,
                      child: Ink.image(
                        image: const AssetImage(
                            'assets/images/kakao_login_medium_wide.png'),
                        fit: BoxFit.cover,
                        child: InkWell(
                          onTap: () {
                            // TODO: 카카오 로그인 구현
                            print('카카오 로그인 버튼 클릭됨');
                          },
                          splashColor: Colors.black.withOpacity(0.08),
                          highlightColor: Colors.black.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 구글 로그인 버튼
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: 구글 로그인 구현
                            print('구글 로그인 버튼 클릭됨');
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/google_logo.svg',
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: Color(0xFF1F1F1F),
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
