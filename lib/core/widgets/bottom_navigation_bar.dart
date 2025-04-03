import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../features/rental/views/qr_scan_view.dart';
import '../services/token_service.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) async {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.of(context).pushReplacementNamed(Routes.home);
            break;
          case 1:
            Navigator.of(context).pushReplacementNamed(Routes.map);
            break;
          case 2:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QRScanView(
                  rentalDuration: 0,
                  isReturn: false,
                ),
              ),
            );
            break;
          case 3:
            final hasToken = await TokenService.instance.hasAccessToken();
            if (!hasToken) {
              Navigator.of(context).pushReplacementNamed(Routes.login);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.mypage);
            }
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: '스테이션',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'QR 스캔',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
    );
  }
}
