import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../../app/routes.dart';
import '../../../features/rental/views/active_rentals_view.dart';
import '../../../features/rental/views/rental_history_view.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 회원 정보 필드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user?.name}님',
                            style: AppTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.editProfile);
                      },
                      child: const Text('회원정보 수정'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. My 필드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ActiveRentalsView(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.access_time_filled),
                        label: const Text('대여 현황'),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RentalHistoryView(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('대여 내역'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. 고객지원 필드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '고객지원',
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSupportButton(
                          '이용 약관',
                          Icons.description,
                          onPressed: () {
                            // TODO: 이용 약관 페이지로 이동
                          },
                        ),
                        _buildSupportButton(
                          '개인정보 처리방침',
                          Icons.security,
                          onPressed: () {
                            // TODO: 개인정보 처리방침 페이지로 이동
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSupportButton(
                          '공지사항',
                          Icons.notifications,
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.noticeList);
                          },
                        ),
                        _buildSupportButton(
                          '자주 묻는 질문',
                          Icons.help,
                          onPressed: () {
                            // TODO: FAQ 페이지로 이동
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSupportButton(
                          '전화문의',
                          Icons.phone,
                          onPressed: () {
                            // TODO: 전화문의 기능 구현
                          },
                        ),
                        _buildSupportButton(
                          '1:1 채팅상담',
                          Icons.chat,
                          onPressed: () {
                            // TODO: 채팅상담 페이지로 이동
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. 베너 광고
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '광고 영역',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. 로그아웃 버튼
              ElevatedButton(
                onPressed: () async {
                  await AuthService.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(Routes.login);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.error,
                ),
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildSupportButton(
    String label,
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
