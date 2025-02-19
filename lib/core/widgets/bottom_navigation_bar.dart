import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../services/auth_service.dart';
import '../../features/rental/views/qr_scan_view.dart';

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
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.of(context).pushReplacementNamed(Routes.home);
            break;
          case 1:
            Navigator.of(context).pushReplacementNamed(Routes.rental);
            break;
          case 2:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QRScanView(rentalDuration: 0, isReturn: false,),
              ),
            );
            break;
          case 3:
            final user = AuthService.instance.currentUser;
            if (user?.email != null) {
              Navigator.of(context).pushReplacementNamed(Routes.mypage);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.login);
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
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: '대여',
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
