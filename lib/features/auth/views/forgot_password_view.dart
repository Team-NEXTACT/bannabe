import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/widgets/loading_animation.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/routes.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // 인증코드 발송
  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();

    // 이메일 형식 검사
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        _error = '올바른 이메일 형식이 아닙니다.';
        _success = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final result = await AuthService.instance.sendVerificationCode(email);

      if (result) {
        setState(() {
          _codeSent = true;
          _success = '인증코드가 이메일로 발송되었습니다. (유효시간: 10분)';
        });
      } else {
        setState(() {
          _error = '인증코드 발송에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _error = '인증코드 발송에 실패했습니다: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 인증코드 검증
  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _error = '인증코드를 입력해주세요.';
        _success = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final result = await AuthService.instance.verifyCode(email, code);

      if (result) {
        // 인증 성공 시 비밀번호 재설정 페이지로 이동
        if (mounted) {
          Navigator.of(context).pushNamed(
            Routes.resetPassword,
            arguments: {
              'email': email,
              'code': code,
            },
          );
        }
      } else {
        setState(() {
          _error = '인증코드가 올바르지 않습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _error = '인증코드 검증에 실패했습니다: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 찾기'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                '비밀번호를 잊으셨나요?',
                style: AppTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '가입하신 이메일 주소를 입력하시면\n인증코드를 보내드립니다.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
                enabled: !_codeSent, // 인증코드 발송 후에는 이메일 수정 불가
              ),
              const SizedBox(height: 16),
              if (_codeSent) ...[
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '인증코드 입력',
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
              ],
              if (_error != null) ...[
                Text(
                  _error!,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              if (_success != null) ...[
                Text(
                  _success!,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              if (_isLoading)
                const HoneyLoadingAnimation(isStationSelected: false)
              else
                ElevatedButton(
                  onPressed: _codeSent ? _verifyCode : _sendVerificationCode,
                  child: Text(_codeSent ? '인증코드 확인' : '인증코드 발송'),
                ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _sendVerificationCode,
                  child: const Text('인증코드 재발송'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
