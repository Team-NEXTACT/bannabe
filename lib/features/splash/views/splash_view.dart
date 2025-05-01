import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final String text = "BANNABEE";

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(text.length, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween(begin: 0.0, end: -18.0)
          .chain(
            CurveTween(curve: Curves.easeInOut),
          )
          .animate(controller);
    }).toList();

    _startWaveAnimation();

    // 3초 후 홈으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  void _startWaveAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _controllers[i].reverse();
    }

    // 반복 호출로 계속 파도타기
    Future.delayed(const Duration(milliseconds: 500), _startWaveAnimation);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(text.length, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animations[index].value),
                  child: Text(
                    text[index],
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.5,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
